; 
; WACCM-X files from Hanli
; polar plots of NO in density
; monthly mean
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
lstyr=2002
ledmn=1
leddy=1
ledyr=2002
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
dir='/Volumes/earth/harvey/WACCM_data/Datfiles/Datfiles_Liu/WAX3548T08CO_2x.cam2.h0.'

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
      syr=string(FORMAT='(i4)',iyr)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
;
; read WACCM data
;
      if sdy ne '01' then goto,jump
      spawn,'ls '+dir+syr+'-'+smn+'.nc',ncfiles
          sdate=syr+'-'+smn
          ncfile=ncfiles(0)
          ncid=ncdf_open(ncfile)
          result0=ncdf_inquire(ncid)
          for idim=0,result0.ndims-1 do begin
              ncdf_diminq,ncid,idim,name,dim
              if name eq 'lon' then nc=dim
              if name eq 'lat' then nr=dim
              if name eq 'lev' then nl=dim
              if name eq 'time' then nt=dim
;             print,'read ',name,' dimension ',dim
          endfor
;
; loop over variables
;
          for ivar=0,result0.nvars-1 do begin
              result=ncdf_varinq(ncid,ivar)
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
              if result.name eq 'PS' then psfc=data	;/100.
              if result.name eq 'T' then tgrd=data
              if result.name eq 'U' then ugrd=data
              if result.name eq 'V' then vgrd=data
              if result.name eq 'CO' then cogrd=data
              if result.name eq 'NOY' then noygrd=data
              if result.name eq 'NO' then nogrd=data
;             if result.name eq 'QRL_TOT' then qrtgrd=data
;             if result.name eq 'QRS_TOT' then qrsgrd=data
;             if result.name eq 'O3' then  o3grd=data
              if result.name eq 'Z3' then  zgrd=data/1000.

;             print,ivar,result.name,min(data),max(data)
          endfor
          ncdf_close,ncid
;
;============================================================
; Calculate Pressure : pgrd(i,j,k) = A(k)*PO + B(k)*PS(i,j)
;============================================================
          pgrd        = fltarr(nc,nr,nl)
          Pzero       = P0      ;/100.
          FOR ilon = 0, nc-1 DO $
              FOR ilat = 0, nr-1 DO $
                  FOR ialt = 0, nl-1 DO $
                      pgrd(ilon,ilat,ialt) = hyam(ialt)*Pzero + hybm(ialt)*PSFC(ilon,ilat)
;
; compute atmospheric density
;
; p=rho R T -> rho=P/RT where R=287 J/K kg. Pressure in Pascals.
;
rho=pgrd/(tgrd*287.)
;
; to convert species from (NO molecules/air molecules) to g/cm3
; assume the molecular weight of one molecule of air is 29 grams (weight of O is 16, weight of N is 14, atm is 80% N2 and 20% O2)
; (mol NO/mol air) * (1 molecule air/29 grams) * (1000 g air/1 kg air) * (AIR DENSITY/m^3 air) * (30 grams NO/1 molecule NO) = (grams NO/m^3 air)
;
no_conc=nogrd * (1./29.) * (1000./1.) * rho * 30.
no_conc=no_conc/1.e6                                 ; divide by 1.e6 for m-3 to cm-3
;
; atomic weight of carbon is 12 so CO is 28
;
co_conc=cogrd * (1./29.) * (1000./1.) * rho * 28.
co_conc=co_conc/1.e6                                 ; divide by 1.e6 for m-3 to cm-3
;
; select pressure level
;
       x=fltarr(nc+1)
       x(0:nc-1)=alon(0:nc-1)
       x(nc)=alon(0)+360.

    q1=reform(no_conc(*,*,0))      ; NO at top level
    q=0.*fltarr(nc+1,nr)
    q(0:nc-1,0:nr-1)=q1(0:nc-1,0:nr-1)
    q(nc,*)=q(0,*)

for ilev=0L,50L do begin
    slev=strcompress(lev(ilev),/remove_all)+'hPa'

; save postscript version
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='polar_nh_no+co_dens_'+sdate+'_'+slev+'_WAX3548T08CO.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
    endif

    zavg=mean(zgrd(*,nr/2:nr-1,ilev))
    szavg=string(FORMAT='(i3)',zavg)+'km'
;   noy1=reform(noygrd(*,*,ilev))*1.e6
    no1=reform(no_conc(*,*,ilev))
    no=0.*fltarr(nc+1,nr)
    no(0:nc-1,0:nr-1)=no1(0:nc-1,0:nr-1)
    no(nc,*)=no(0,*)
    no1d=reform(co_conc(*,*,ilev))
    nod=0.*fltarr(nc+1,nr)
    nod(0:nc-1,0:nr-1)=no1d(0:nc-1,0:nr-1)
    nod(nc,*)=nod(0,*)
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
    xyouts,.3,.8,'WAX3548T08CO '+sdate+' '+slev+' ('+szavg+')',/normal,color=0,charsize=1.5
    MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='NO',charsize=1.5,color=0,/noborder	;,limit=[60.,0.,90.,360.]
imin=min(no(*,nr/2:nr-1))
imax=max(no(*,nr/2:nr-1))
print,sdate,'  NO ',imin,imax
;imin=3.e-16
;imax=2.e-15
    nlvls=11
    level=imin+((imax-imin)/float(nlvls))*findgen(nlvls+1)
nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,no,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
    contour,no,x,alat,/overplot,levels=level,/follow,c_labels=0*level,/noeras,color=0
;   contour,z,x,alat,/overplot,levels=10+findgen(150),/follow,c_labels=0*findgen(150),/noeras,color=mcolor
    MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,charsize=1.5,color=0,/noborder
    contour,q,x,alat,/overplot,levels=1.8e-15,/follow,c_labels=0,/noeras,color=mcolor,thick=5
    contour,speed,x,alat,/overplot,levels=30.+10.*findgen(30),/follow,c_labels=0,/noeras,color=mcolor,thick=3
;   contour,speed,x,alat,/overplot,levels=[25.],/follow,c_labels=0,/noeras,color=0,thick=3
;   contour,speed,x,alat,/overplot,levels=[50.],/follow,c_labels=0,/noeras,color=icolmax*.45,thick=3
;   contour,speed,x,alat,/overplot,levels=[75.],/follow,c_labels=0,/noeras,color=icolmax*.65,thick=3
;   contour,speed,x,alat,/overplot,levels=[100.],/follow,c_labels=0,/noeras,color=icolmax*.7,thick=3
;   contour,speed,x,alat,/overplot,levels=[150.],/follow,c_labels=0,/noeras,color=icolmax*.9,thick=3
;   contour,speed,x,alat,/overplot,levels=[200.],/follow,c_labels=0,/noeras,color=icolmax,thick=3
;   drawvectors,nc+1,nr,x,alat,u,v,20,1

    imin=min(level)
    imax=max(level)
    ymnb=ymn-cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn+0.05,xmx-0.05,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='(g/cm3)',charsize=1.,color=0,xticks=3
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
    MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='CO',charsize=1.5,color=0,/noborder	;,limit=[60.,0.,90.,360.]
imin=min(nod(*,nr/2:nr-1))
imax=max(nod(*,nr/2:nr-1))
    nlvls=11
    level=imin+((imax-imin)/float(nlvls))*findgen(nlvls+1)
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,nod,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
index=where(level gt 0.)
if index(0) ne -1L then contour,nod,x,alat,/overplot,levels=level(index),/follow,c_labels=0*level(index),/noeras,color=0
index=where(level lt 0.)
if index(0) ne -1L then contour,nod,x,alat,/overplot,levels=level(index),/follow,c_labels=0*level(index),/noeras,color=mcolor,c_linestyle=5
    MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,charsize=1.5,color=0,/noborder	;,limit=[60.,0.,90.,360.]
;   contour,q,x,alat,/overplot,levels=[1.e-15],/follow,c_labels=0,/noeras,color=mcolor,thick=5
;   contour,z,x,alat,/overplot,nlevels=20,/follow,c_labels=0,/noeras,color=0,thick=3
    contour,speed,x,alat,/overplot,levels=30.+10.*findgen(30),/follow,c_labels=0,/noeras,color=mcolor,thick=3
;   contour,speed,x,alat,/overplot,levels=[25.],/follow,c_labels=0,/noeras,color=0,thick=3
;   contour,speed,x,alat,/overplot,levels=[50.],/follow,c_labels=0,/noeras,color=icolmax*.45,thick=3
;   contour,speed,x,alat,/overplot,levels=[75.],/follow,c_labels=0,/noeras,color=icolmax*.65,thick=3
;   contour,speed,x,alat,/overplot,levels=[100.],/follow,c_labels=0,/noeras,color=icolmax*.7,thick=3
;   contour,speed,x,alat,/overplot,levels=[150.],/follow,c_labels=0,/noeras,color=icolmax*.9,thick=3
;   contour,speed,x,alat,/overplot,levels=[200.],/follow,c_labels=0,/noeras,color=icolmax,thick=3
;   drawvectors,nc+1,nr,x,alat,u,v,20,1
;velovect,u,v,x,alat,color=0,/overplot,length=2
    imin=min(level)
    imax=max(level)
    ymnb=ymn-cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn+0.05,xmx-0.05,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='(g/cm3)',charsize=1.,color=0,xticks=3
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
       spawn,'convert -trim polar_nh_no+co_dens_'+sdate+'_'+slev+'_WAX3548T08CO.ps -rotate -90 polar_nh_no+co_dens_'+sdate+'_'+slev+'_WAX3548T08CO.jpg'
       spawn,'rm -f polar_nh_no+co_dens_'+sdate+'_'+slev+'_WAX3548T08CO.ps'
    endif
endfor	; loop over pressure

goto, jump

end
