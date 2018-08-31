; 
; cross polar plots and polar plots
; WACCM files from with AOA1 set to latitude and AOA2 set to altitude
; polar plots each timestep
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
xlen=0.35
ylen=0.35
cbaryoff=0.03
cbarydel=0.02
!NOERAS=-1
lstmn=1
lstdy=1
lstyr=2002
ledmn=3
leddy=29
ledyr=2002
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting date (monl, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (monl, day, year) ',ledmn,leddy,ledyr
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
monl=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
dir='/Volumes/data/WACCM/Traject_Season.cam2.h1.'

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
;     syr=string(FORMAT='(i4)',iyr)
      syr='0001'
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
;
; read WACCM data
;
      spawn,'ls '+dir+syr+'-'+smn+'-'+sdy+'-*.nc',ncfiles
      for ifile=0L,n_elements(ncfiles)-1L do begin
result=strsplit(ncfiles(ifile),'-',/extract)
result2=strsplit(result(3),'.',/extract)
sec=result2(0)
shrs=string(FORMAT='(f5.1)',float(sec)/3600.+((idy-1)*24.))
          sdate=syr+'-'+smn+'-'+sdy+'-'+sec
          ncfile=ncfiles(ifile)
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
              if result.name eq 'CH4' or result.name eq 'CO' or result.name eq 'H' or result.name eq 'H2O' or result.name eq 'NO2' or $
                 result.name eq 'NOX' or result.name eq 'NOY' or result.name eq 'QRS_TOT' or result.name eq 'QRL_TOT' or $
                 result.name eq 'O3' or result.name eq 'VTH2d' or result.name eq 'WTH2d' or result.name eq 'UV2d' or result.name eq 'UW2d' or $
                 result.name eq 'OH' or result.name eq 'HO2' or result.name eq 'MSKtem' or result.name eq 'N2O' then goto,jumpvar
              if result.name eq 'P0' then p0=data
              if result.name eq 'lat' then alat=data
              if result.name eq 'lon' then alon=data
              if result.name eq 'lev' then lev=data
              if result.name eq 'ilev' then ilev=data
              if result.name eq 'time' then time=data
              if result.name eq 'datesec' then time=data
              if result.name eq 'hyai' then hyai=data
              if result.name eq 'hybi' then hybi=data
              if result.name eq 'hyam' then hyam=data
              if result.name eq 'hybm' then hybm=data
              if result.name eq 'date' then date=data
              if result.name eq 'PS' then psfc=data	;/100.
              if result.name eq 'T' then tgrd=data
              if result.name eq 'U' then ugrd=data
              if result.name eq 'V' then vgrd=data
              if result.name eq 'AOA1' then aoa1grd=data
              if result.name eq 'AOA2' then aoa2grd=data
              if result.name eq 'e' then egrd=data
;             if result.name eq 'NOY' then noygrd=data
              if result.name eq 'NO' then nogrd=data
;             if result.name eq 'QRL_TOT' then qrtgrd=data
;             if result.name eq 'QRS_TOT' then qrsgrd=data
;             if result.name eq 'O3' then  o3grd=data
              if result.name eq 'Z3' then  zgrd=data/1000.

;             print,ivar,result.name,min(data),max(data)
jumpvar:
          endfor
;print,'zgrd ',max(zgrd)
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
; to convert species from (NO molecules/air molecules) to NO molecules/cm3
; assume the molecular weight of one molecule of air is 29 grams (weight of O is 16, weight of N is 14, atm is 80% N2 and 20% O2)
; (mol NO/mol air) * (1 molecule air/29 grams) * (1000 g air/1 kg air) * (AIR DENSITY/m^3 air) * (Avagadros #/1 mole NO) = (molecules NO/m^3 air)
; Avagadros # = 6.022e23
;
no_conc=nogrd * (1./29.) * (1000./1.) * rho * 6.022e23
no_conc=no_conc/1.e6                                 ; divide by 1.e6 for m-3 to cm-3
;
stime=strcompress(long(time),/remove_all)
x=fltarr(nc+1)
x(0:nc-1)=alon(0:nc-1)
x(nc)=alon(0)+360.

    q1=reform(no_conc(*,*,0))      ; NO at top level
    q=0.*fltarr(nc+1,nr)
    q(0:nc-1,0:nr-1)=q1(0:nc-1,0:nr-1)
    q(nc,*)=q(0,*)

    speedgrd=sqrt(ugrd^2+vgrd^2)


if icount eq 0L then begin
   nomin=fltarr(nl)
   nomax=fltarr(nl)
   emin=fltarr(nl)
   emax=fltarr(nl)
   height0grd=aoa2grd
   z0grd=zgrd
endif
if icount gt 0 then aoa2grd=aoa2grd-height0grd
;
; zonal mean AOA2=Altitude
;
;aoa2yz=0.*fltarr(nr,nl)
;for k=0L,nl-1L do begin
;for j=0L,nr-1L do begin
;    aoa2yz(j,k)=mean(aoa2grd(*,j,k))
;endfor
;endfor
;
; NH mean altitude of pressure surfaces
;
zlev=fltarr(nl)
for k=0L,nl-1L do zlev(k)=mean(z0grd(*,nr/2:nr-1,k))	; on first day
;
; user enters desired longitude
;
if icount eq 0L then begin
;   print,alon
    rlon1=180.
;   read,' Enter longitude ',rlon1
    index1=where(alon eq rlon1)
    if index1(0) eq -1 then stop,'Bad Longitude'
    ilon1=index1(0)
    rlon2=rlon1+180.
    if rlon2 gt max(alon) then rlon2=rlon2-360.
    index2=where(alon eq rlon2)
    ilon2=index2(0)
    slon1=' '+strcompress(string(rlon1),/remove_all)+' E'
    slon2=' '+strcompress(string(rlon2),/remove_all)+' E'
;   print,'longitudes ',rlon1,rlon2
    x=fltarr(nc+1)
    x(0:nc-1)=alon(0:nc-1)
    x(nc)=alon(0)+360.
    x2d=fltarr(nc+1,nr)
    y2d=fltarr(nc+1,nr)
    for i=0,nc do y2d(i,*)=alat
    for j=0,nr-1 do x2d(*,j)=x
    xyz=fltarr(nr,nl)
    yyz=fltarr(nr,nl)
    for i=0,nr-1 do yyz(i,*)=zlev
    for j=0,nl-1 do xyz(*,j)=alat
endif
;
; cross pole altitude arrays
;
eyz=fltarr(nr,nl)
uyz=fltarr(nr,nl)
speedyz=fltarr(nr,nl)
tyz=fltarr(nr,nl)
noyz=fltarr(nr,nl)
aoa1yz=fltarr(nr,nl)
aoa2yz=fltarr(nr,nl)
for k=0,nl-1 do begin
    eyz(0:nr/2-1,k)=egrd(ilon1,nr/2:nr-1,k)
    eyz(nr/2:nr-1,k)=egrd(ilon2,nr/2:nr-1,k)
    eyz(nr/2:nr-1,k)=reverse(eyz(nr/2:nr-1,k))

    speedyz(0:nr/2-1,k)=speedgrd(ilon1,nr/2:nr-1,k)
    speedyz(nr/2:nr-1,k)=speedgrd(ilon2,nr/2:nr-1,k)
    speedyz(nr/2:nr-1,k)=reverse(speedyz(nr/2:nr-1,k))

    uyz(0:nr/2-1,k)=ugrd(ilon1,nr/2:nr-1,k)
    uyz(nr/2:nr-1,k)=ugrd(ilon2,nr/2:nr-1,k)
    uyz(nr/2:nr-1,k)=reverse(uyz(nr/2:nr-1,k))

    tyz(0:nr/2-1,k)=tgrd(ilon1,nr/2:nr-1,k)
    tyz(nr/2:nr-1,k)=tgrd(ilon2,nr/2:nr-1,k)
    tyz(nr/2:nr-1,k)=reverse(tyz(nr/2:nr-1,k))

    noyz(0:nr/2-1,k)=no_conc(ilon1,nr/2:nr-1,k)
    noyz(nr/2:nr-1,k)=no_conc(ilon2,nr/2:nr-1,k)
    noyz(nr/2:nr-1,k)=reverse(noyz(nr/2:nr-1,k))

    aoa1yz(0:nr/2-1,k)=aoa1grd(ilon1,nr/2:nr-1,k)
    aoa1yz(nr/2:nr-1,k)=aoa1grd(ilon2,nr/2:nr-1,k)
    aoa1yz(nr/2:nr-1,k)=reverse(aoa1yz(nr/2:nr-1,k))

    aoa2yz(0:nr/2-1,k)=aoa2grd(ilon1,nr/2:nr-1,k)
    aoa2yz(nr/2:nr-1,k)=aoa2grd(ilon2,nr/2:nr-1,k)
    aoa2yz(nr/2:nr-1,k)=reverse(aoa2yz(nr/2:nr-1,k))
endfor

   tagged=where(aoa2yz gt 0.8)

for ilev=5L,5L do begin	;nl-1L do begin
    slev=string(FORMAT='(f13.6)',lev(ilev))+'hPa'
    slev0=string(format='(i2.2)',ilev)

; save postscript version
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='polar_no_'+sdate+'_'+slev0+'_waccm_Traject_Season_2pan_cross_pole.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
    endif

    zavg=zlev(ilev)
    szavg=string(FORMAT='(i3)',zavg)+'km'
print,sdate,' ',slev,' ',szavg,' ',zlev(ilev)

    no1=reform(no_conc(*,*,ilev))
    no=0.*fltarr(nc+1,nr)
    no(0:nc-1,0:nr-1)=no1(0:nc-1,0:nr-1)
    no(nc,*)=no(0,*)
    e1=reform(egrd(*,*,ilev))
    e=0.*fltarr(nc+1,nr)
    e(0:nc-1,0:nr-1)=e1(0:nc-1,0:nr-1)
    e(nc,*)=e(0,*)
    u1=reform(ugrd(*,*,ilev))
    u=0.*fltarr(nc+1,nr)
    u(0:nc-1,0:nr-1)=u1(0:nc-1,0:nr-1)
    u(nc,*)=u(0,*)
    v1=reform(vgrd(*,*,ilev))
    v=0.*fltarr(nc+1,nr)
    v(0:nc-1,0:nr-1)=v1(0:nc-1,0:nr-1)
    v(nc,*)=v(0,*)
    aoa1a=reform(aoa1grd(*,*,ilev))
    aoa2a=reform(aoa2grd(*,*,ilev))
    aoa1=0.*fltarr(nc+1,nr)
    aoa1(0:nc-1,0:nr-1)=aoa1a(0:nc-1,0:nr-1)
    aoa1(nc,*)=aoa1(0,*)
    aoa2=0.*fltarr(nc+1,nr)
    aoa2(0:nc-1,0:nr-1)=aoa2a(0:nc-1,0:nr-1)
    aoa2(nc,*)=aoa2(0,*)

    z1=reform(zgrd(*,*,ilev))
    z=0.*fltarr(nc+1,nr)
    z(0:nc-1,0:nr-1)=z1(0:nc-1,0:nr-1)
    z(nc,*)=z(0,*)
    speed=sqrt(u^2+v^2)
;print,'Max Speed at ',lev(ilev),zavg,max(speed)

    erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    xyouts,.15,.8,'WACCM-4 '+sdate+'     '+slev+' ('+szavg+')',/normal,color=0,charsize=1.5
    MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='NO',charsize=1.5,color=0,/noborder
index=where(alat ge 20.)
imin=min(no(*,index))
imax=max(no(*,index))
;if icount eq 0L then begin
;   nomin(ilev)=imin-.5*imin
;   nomax(ilev)=imax+.1*imax
;endif
;print,sdate,'  NO ',imin,imax
;imin=nomin(ilev)
;imax=nomax(ilev)
    nlvls=11
    level=imin+((imax-imin)/float(nlvls))*findgen(nlvls+1)
;level=1.e6+5.e7*findgen(11)
;imin=min(level)
;imax=max(level)

nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,no,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
    contour,no,x,alat,/overplot,levels=level,/follow,c_labels=0*level,/noeras,color=0
;   contour,z,x,alat,/overplot,levels=10+findgen(150),/follow,c_labels=0*findgen(150),/noeras,color=mcolor
    oplot,rlon1+0*findgen(90),findgen(91),psym=0,color=mcolor,thick=5
    oplot,rlon2+0*findgen(90),findgen(91),psym=0,color=mcolor,thick=5
    MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,color=mcolor
;   contour,q,x,alat,/overplot,levels=1.8e-15,/follow,c_labels=0,/noeras,color=mcolor,thick=5
;   contour,speed,x,alat,/overplot,levels=50.+50.*findgen(30),/follow,c_labels=0,/noeras,color=mcolor,thick=3
;   drawvectors,nc+1,nr,x,alat,u,v,20,1
    imin=min(level)
    imax=max(level)
    ymnb=ymn-cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn+0.05,xmx-0.05,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='(molecules/cm3)',charsize=1.,color=0,xticks=3
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
index=where(yyz gt 60)
imin=min(noyz(index))
imax=max(noyz(index))
    nlvls=11
    level=[0.,imin+((imax-imin)/float(nlvls))*findgen(nlvls+1)]
;level=1.e6+2.5e7*findgen(21)
imin=min(level)
imax=max(level)
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*icolmax/nlvls
    contour,noyz,alat,zlev,yrange=[40.,max(zlev)],levels=level,c_color=col1,/cell_fill,/noeras,color=0,ytitle='Altitude (km)',title='NO',$
            xtitle=slon1+'       Latitude      '+slon2,xtickname=['Eq','30','60','NP','60','30','Eq'],xticks=6
index=where(level gt 0)
    contour,noyz,alat,zlev,/overplot,levels=level(index),/follow,c_labels=0*level(index),/noeras,color=0
index=where(level lt 0)
if index(0) ne -1L then contour,noyz,alat,zlev,/overplot,levels=level(index),/follow,c_labels=0*level(index),/noeras,color=mcolor,c_linestyle=5
index=where(uyz lt 0.)
if index(0) ne -1L then speedyz(index)=-1.*speedyz(index)
;   contour,speedyz,alat,zlev,/overplot,levels=[25,50,75,100],/follow,/noeras,color=mcolor,c_labels=[0,0,0,0]
;   contour,speedyz,alat,zlev,/overplot,levels=[-100,-75,-50,-25],/follow,/noeras,color=mcolor,c_linestyle=5,c_labels=[0,0,0,0]
;   contour,aoa1yz,alat,zlev,/overplot,levels=0.1*findgen(10),/follow,/noeras,color=mcolor
;   contour,aoa2yz,alat,zlev,/overplot,levels=0.1*findgen(10),/follow,/noeras,color=mcolor
    if tagged(0) ne -1L then oplot,xyz(tagged),yyz(tagged),psym=3,color=mcolor

    oplot,alat,zavg+0.*alat,psym=0,color=mcolor,thick=3
;   drawvectors,nc+1,nr,x,alat,u,v,20,1
;velovect,u,v,x,alat,color=0,/overplot,length=2
    imin=min(level)
    imax=max(level)
    ymnb=ymn-cbaryoff-0.05
    ymxb=ymnb+cbarydel
    set_viewport,xmn+0.05,xmx-0.05,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],charsize=1.,color=0,xtitle='(molecules/cm3)'
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
       spawn,'convert -trim polar_no_'+sdate+'_'+slev0+'_waccm_Traject_Season_2pan_cross_pole.ps -rotate -90 polar_no_'+sdate+'_'+slev0+'_waccm_Traject_Season_2pan_cross_pole.jpg'
       spawn,'rm -f polar_no_'+sdate+'_'+slev0+'_waccm_Traject_Season_2pan_cross_pole.ps'
    endif
jumplev:
endfor	; loop over pressure
icount=1
endfor	; loop over time steps
goto, jump

end
