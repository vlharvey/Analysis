; 
; polar plots of WACCM CO in support of CHARM.
; difference plots between daily averages
;
@stddat
@kgmt
@ckday
@kdate

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
!NOERAS=-1
device,decompose=0
nxdim=700
nydim=700
xorig=[0.075,0.525]
yorig=[0.3,0.3]
xlen=0.4
ylen=0.4
cbaryoff=0.03
cbarydel=0.02
!NOERAS=-1
lstmn=1
lstdy=1
lstyr=2001
ledmn=1
leddy=15
ledyr=2001
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
dir='/Volumes/earth/harvey/WACCM_data/Datfiles/Datfiles_CHARM/wa4_charm_30min.cam2.h2.0001-'

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop over days --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
;
; read WACCM data
;
      spawn,'ls '+dir+smn+'-'+sdy+'*.nc',ncfiles
      nsteps=n_elements(ncfiles)
      dlon=360./float(nsteps)
      for istep=0L,nsteps-1L do begin
          isec=long(60.*30.*istep)
          ssec=string(FORMAT='(i5.5)',isec)
          sdate=smn+'-'+sdy
          ncfile=ncfiles(istep)
          ncid=ncdf_open(ncfile)
          result0=ncdf_inquire(ncid)
          for idim=0,result0.ndims-1 do begin
              ncdf_diminq,ncid,idim,name,dim
              if name eq 'lon' then nc=dim
              if name eq 'lat' then nr=dim
              if name eq 'lev' then nl=dim
              if name eq 'time' then nt=dim
              print,'read ',name,' dimension ',dim
          endfor
;
; loop over variables
;
          for ivar=0,result0.nvars-1 do begin
              result=ncdf_varinq(ncid,ivar)
;             if result.name ne 'T' and result.name ne 'U' and result.name ne 'V' then $

              ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
              if result.name eq 'P0' then p0=data
              if result.name eq 'lat' then alat=data
              if result.name eq 'lon' then alon=data
              if result.name eq 'lev' then lev=data
              if result.name eq 'ilev' then ilev=data
              if result.name eq 'time' then time=data
              if result.name eq 'hyai' then hyai=data
              if result.name eq 'hybi' then hybi=data
              if result.name eq 'hyam' then hyam=data
              if result.name eq 'hybm' then hybm=data
              if result.name eq 'date' then date=data
              if result.name eq 'PS' then psfc=data/100.
;             if result.name eq 'T' then tgrd=data
              if result.name eq 'U' then ugrd=data
              if result.name eq 'V' then vgrd=data
;             if result.name eq 'CH4' then ch4grd=data
;             if result.name eq 'NOY' then noygrd=data
              if result.name eq 'CO' then noygrd=data
;             if result.name eq 'QRL_TOT' then qrtgrd=data
;             if result.name eq 'QRS_TOT' then qrsgrd=data
;             if result.name eq 'O3' then  o3grd=data
              if result.name eq 'Z3' then  zgrd=data/1000.

              print,ivar,result.name,min(data),max(data)
          endfor
          ncdf_close,ncid
;
;============================================================
; Calculate Pressure : pgrd(i,j,k) = A(k)*PO + B(k)*PS(i,j)
;============================================================
;         pgrd        = fltarr(nc,nr,nl)
;         Pzero       = P0/100.
;         FOR ilon = 0, nc-1 DO $
;             FOR ilat = 0, nr-1 DO $
;                 FOR ialt = 0, nl-1 DO $
;                     pgrd(ilon,ilat,ialt) = hyam(ialt)*Pzero + hybm(ialt)*PSFC(ilon,ilat,itime)
;
; select pressure level
;
    if icount eq 0L then begin
       rlev=0.0014584575
;      print,lev
;      read,'Enter pressure surface ',rlev
       zindex=where(abs(lev-rlev) eq min(abs(lev-rlev)))
       ilev=zindex(0)
       slev=string(FORMAT='(f8.5)',lev(ilev))+'hPa'
       x=fltarr(nc+1)
       x(0:nc-1)=alon(0:nc-1)
       x(nc)=alon(0)+360.
       icount=1L
;      goto,jumpstep
noyold=noygrd
    endif
;   noydiff=100.*(noygrd-noyold)/noygrd
    noydiff=noygrd-noyold

for ilev=0L,20L do begin
    slev=string(FORMAT='(f7.5)',lev(ilev))+'hPa'

; save postscript version
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='polar_nh_co_charm_'+sdate+'_'+slev+'_diff.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
    endif

    zavg=mean(zgrd(*,nr/2:nr-1,ilev))
    szavg=string(FORMAT='(i3)',zavg)+'km'
    noy1=reform(noygrd(*,*,ilev))*1.e6
    noy=0.*fltarr(nc+1,nr)
    noy(0:nc-1,0:nr-1)=noy1(0:nc-1,0:nr-1)
    noy(nc,*)=noy(0,*)
    noy1d=reform(noydiff(*,*,ilev))*1.e6
    noyd=0.*fltarr(nc+1,nr)
    noyd(0:nc-1,0:nr-1)=noy1d(0:nc-1,0:nr-1)
    noyd(nc,*)=noyd(0,*)
    u1=reform(ugrd(*,*,ilev))
    u=0.*fltarr(nc+1,nr)
    u(0:nc-1,0:nr-1)=u1(0:nc-1,0:nr-1)
    u(nc,*)=u(0,*)
    v1=reform(vgrd(*,*,ilev))
    v=0.*fltarr(nc+1,nr)
    v(0:nc-1,0:nr-1)=v1(0:nc-1,0:nr-1)
    v(nc,*)=v(0,*)
    z1=reform(zgrd(*,*,ilev))
    z=0.*fltarr(nc+1,nr)
    z(0:nc-1,0:nr-1)=z1(0:nc-1,0:nr-1)
    z(nc,*)=z(0,*)
    speed=sqrt(u^2+v^2)

    erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    xyouts,.3,.8,'WACCM '+sdate+' '+slev+' ('+szavg+')',/normal,color=0,charsize=1.5
    MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='CO',charsize=1.5,color=0,/noborder	;,limit=[60.,0.,90.,360.]
;   MAP_SET,0,0,0,/noeras,/grid,/contin,title='CO',charsize=1.5,color=0,/noborder
imin=min(noy(*,nr/2:nr-1))
imax=max(noy(*,nr/2:nr-1))
;imin=200.	; ilev=0 (143km)
;imax=1000.	; ilev=0 
;imin=0.
;imax=250.
;   nlvls=16	; ilev=0
    nlvls=25
    level=imin+((imax-imin)/float(nlvls))*findgen(nlvls+1)
nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,noy,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
    contour,noy,x,alat,/overplot,levels=level,/follow,c_labels=0*level,/noeras,color=0
;    contour,z,x,alat,/overplot,levels=10+findgen(150),/follow,c_labels=0*findgen(150),/noeras,color=mcolor
    MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,charsize=1.5,color=0,/noborder
;   MAP_SET,0,0,0,/noeras,/grid,/contin,charsize=1.5,color=0,/noborder	;,limit=[60.,0.,90.,360.]
    contour,speed,x,alat,/overplot,levels=[50.],/follow,c_labels=0,/noeras,color=0,thick=3
    contour,speed,x,alat,/overplot,levels=[100.],/follow,c_labels=0,/noeras,color=icolmax*.45,thick=3
    contour,speed,x,alat,/overplot,levels=[150.],/follow,c_labels=0,/noeras,color=icolmax*.65,thick=3
    contour,speed,x,alat,/overplot,levels=[200.],/follow,c_labels=0,/noeras,color=icolmax*.7,thick=3
    contour,speed,x,alat,/overplot,levels=[250.],/follow,c_labels=0,/noeras,color=icolmax*.9,thick=3
    contour,speed,x,alat,/overplot,levels=[300.],/follow,c_labels=0,/noeras,color=icolmax,thick=3
    drawvectors,nc+1,nr,x,alat,u,v,20,1

;IVECTOR, u, v, x, alat, /overplot, /STREAMLINES, $ 
;   X_STREAMPARTICLES=10, Y_STREAMPARTICLES=10, $ 
;   HEAD_SIZE=0.1, STREAMLINE_NSTEPS=200 

xlon=-dlon*istep+180.
if xlon lt 0. then xlon=xlon+360.
if xlon gt 360. then xlon=xlon-360.

    imin=min(level)
    imax=max(level)
    ymnb=ymn-cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn+0.05,xmx-0.05,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='(ppmv)',charsize=1.5,color=0
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
    endfor

    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='CO Difference',charsize=1.5,color=0,/noborder	;,limit=[60.,0.,90.,360.]
;   MAP_SET,0,0,0,/noeras,/grid,/contin,title='CO Difference',charsize=1.5,color=0,/noborder
imin=-1.
imax=1.
    nlvls=21
    level=imin+0.1*findgen(nlvls)
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,noyd,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
index=where(level gt 0.)
if index(0) ne -1L then contour,noyd,x,alat,/overplot,levels=level(index),/follow,c_labels=0*level(index),/noeras,color=0
index=where(level lt 0.)
if index(0) ne -1L then contour,noyd,x,alat,/overplot,levels=level(index),/follow,c_labels=0*level(index),/noeras,color=mcolor,c_linestyle=5
;    contour,z,x,alat,/overplot,levels=10+findgen(150),/follow,c_labels=0*findgen(150),/noeras,color=mcolor
    MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,charsize=1.5,color=0,/noborder	;,limit=[60.,0.,90.,360.]
;   MAP_SET,0,0,0,/noeras,/grid,/contin,charsize=1.5,color=0,/noborder
;   contour,z,x,alat,/overplot,nlevels=20,/follow,c_labels=0,/noeras,color=0,thick=3
;   contour,z,x,alat,/overplot,levels=[106.5],/follow,c_labels=0,/noeras,color=0,thick=3
;   contour,z,x,alat,/overplot,levels=[107.],/follow,c_labels=0,/noeras,color=icolmax*.2,thick=3
;   contour,z,x,alat,/overplot,levels=[107.5],/follow,c_labels=0,/noeras,color=icolmax*.3,thick=3
;   contour,z,x,alat,/overplot,levels=[108.],/follow,c_labels=0,/noeras,color=icolmax*.3,thick=3
;   contour,z,x,alat,/overplot,levels=[108.5],/follow,c_labels=0,/noeras,color=icolmax*.9,thick=3
;   contour,z,x,alat,/overplot,levels=[109.],/follow,c_labels=0,/noeras,color=icolmax,thick=3
;   drawvectors,nc+1,nr,x,alat,u,v,20,1
;velovect,u,v,x,alat,color=0,/overplot,length=2
    imin=min(level)
    imax=max(level)
    ymnb=ymn-cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn+0.05,xmx-0.05,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='(ppmv)',charsize=1.5,color=0
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
    endfor

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim polar_nh_co_charm_'+sdate+'_'+slev+'_diff.ps -rotate -90 polar_nh_co_charm_'+sdate+'_'+slev+'_diff.jpg'
       spawn,'rm -f polar_nh_co_charm_'+sdate+'_'+slev+'_diff.ps'
    endif
endfor	; loop over pressure

jumpstep:
if iday eq 2 then noyold=noygrd

    endfor	; loop over daily timesteps
goto, jump

end
