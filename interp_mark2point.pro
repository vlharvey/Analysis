;
; input x,y,date,time and output marker profile
;
@calcelat2d
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc3

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='ps'
read,'setplot=',setplot
nxdim=700
nydim=700
xorig=[0.05,0.6]
yorig=[0.35,0.35]
xlen=0.4
ylen=0.4
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
pthout='/aura2/harvey/Analysis/Marker_profiles/'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
lstmn=1L & lstdy=1L & lstyr=9L
ledmn=2L & leddy=1L & ledyr=10L
lstday=0L & ledday=0L
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
;read,' Enter starting year ',lstyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
kcount=0L
time=12.
;read,' Enter UT time (0-24 hours) ',time
stime=strcompress(string(time))
time=time/24.   ; convert to fractional day
slat=-67.57 & slon=291.88       ; rothera
;read,' Enter longitude, latitude, theta ',slon,slat
sloc='('+string(FORMAT='(f6.2)',slon)+','+string(FORMAT='(f6.2)',slat)+')'
if slat lt 0. then ihem=-1
if slat gt 0. then ihem=1

re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
ks=1.931853d-3
ecc=0.081819
gamma45=9.80
nr=91L
yeq=findgen(nr)
latcircle=fltarr(nr)
hem_frac=fltarr(nr)
for j=0,nr-1 do begin
    hy=re*dtr
    dx=re*cos(yeq(j)*dtr)*360.*dtr
    latcircle(j)=dx*hy
endfor
;
; need latcircle fully initialized
;
for j=0,nr-1 do begin
    index=where(yeq ge yeq(j))
    if index(0) ne -1 then hem_frac(j)=total(latcircle(index))/hem_area
    if yeq(j) eq 0. then hem_frac(j)=1.
endfor

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' normal termination condition '
      if iyr ge 2000 then iyr1=iyr-2000
      if iyr lt 2000 then iyr1=iyr-1900
;
; calculate day of year
;
z = kgmt(imn,idy,iyr,jday)
;
; determine 2 bounding dates in (month, day, year) format
; based on fractional year and day and analyses valid at 12Z
;
if time lt 0.5 then begin
    jday0=jday-1.0
    jday1=jday
    tscale=time+0.5
endif
if time ge 0.5 then begin
    jday0=jday
    jday1=jday+1.0
    tscale=time-0.5
endif
iyr0=iyr
iyr1=iyr
kdate,float(jday0),iyr0,imn0,idy0
ckday,jday0,iyr0
kdate,float(jday1),iyr1,imn1,idy1
ckday,jday1,iyr1
if iyr0 lt 2000 then iyr0=iyr0-1900
if iyr0 ge 2000 then iyr0=iyr0-2000
if iyr1 lt 2000 then iyr1=iyr1-1900
if iyr1 ge 2000 then iyr1=iyr1-2000
;
; read UKMO data on day 0
;
newday=0L
sdate=string(FORMAT='(i4,i2.2,i2.2)',iyr,imn,idy)
ifile=diru+string(FORMAT='(a4,i2.2,a1,i2.2,a4)',mon(imn0-1L),idy0,'_',iyr0,'.nc3')
print,'file 1 ',ifile
dum=findfile(ifile)
if dum(0) ne '' then begin
   rd_ukmo_nc3,ifile,ncw,nrw,nthw,alon,alat,th,pvold,pold,msfold,$
               uold,vold,qold,qdfold,markold,vpold,sfold,iflag
   index=where(markold lt -1.)
   if index(0) ne -1L then markold(index)=-1.0*markold(index)/markold(index)	; anticyclones= -1
   markold=smooth(markold,3,/edge_truncate)
endif
;
; read UKMO data on day 1
;
ifile=diru+string(FORMAT='(a4,i2.2,a1,i2.2,a4)',mon(imn1-1L),idy1,'_',iyr1,'.nc3')
print,'file 2 ',ifile
dum=findfile(ifile)
if dum(0) ne '' then begin
   rd_ukmo_nc3,ifile,ncw,nrw,nthw,alon,alat,th,pvnew,pnew,msfnew,$
               unew,vnew,qnew,qdfnew,marknew,vpnew,sfnew,iflag
   index=where(marknew lt -1.)
   if index(0) ne -1L then marknew(index)=-1.0*marknew(index)/marknew(index)    ; anticyclones= -1
   marknew=smooth(marknew,3,/edge_truncate)
endif
;
; check that point is within MetO latitude range
;
if slat lt min(alat) then stop,'slat lt min MetO lat'   ; slat=min(alat)
if slat gt max(alat) then stop,'slat gt max MetO lat'   ;slat=max(alat)
;
; perform time interpolation
;
pgrd=pold+TSCALE*(pnew-pold)
pvgrd=(pvold+TSCALE*(pvnew-pvold))/100.
msfgrd=msfold+TSCALE*(msfnew-msfold)
markgrd=markold+TSCALE*(marknew-markold)
;
; calculate equivalent latitude using subroutine provided by Doug Allen
;
egrd=0.*pvgrd
for k=0L,nthw-1L do begin
    pvgrd1=transpose(pvgrd(*,*,k))
    elat1=calcelat2d(pvgrd1,alon,alat)
    egrd(*,*,k)=transpose(elat1)
endfor
;
; calculate geopotential height of isentropic surface = (msf - cp*T)/g
; where T = theta* (p/po)^R/cp and divide by 1000 for km
;
tgrd=0.*pvgrd
ggrd=0.*pvgrd
zgrd=0.*pvgrd
for k=0L,nthw-1L do begin
    tgrd(0:nrw-1,0:ncw-1,k)=th(k)*( (pgrd(0:nrw-1,0:ncw-1,k)/1000.)^(.286) )
    ggrd(0:nrw-1,0:ncw-1,k)=(msfgrd(0:nrw-1,0:ncw-1,k)-1004.* $
                             tgrd(0:nrw-1,0:ncw-1,k))/(9.86*1000.)
;
; convert geopotential to geometric height
;
    for j=0L,nrw-1L do begin
        sin2=sin( (alat(j)*dtr)^2.0 )
        numerator=1.0+ks*sin2
        denominator=sqrt( 1.0 - (ecc^2.0)*sin2 )
        gammas=gamma45*(numerator/denominator)
        r=6378.137/(1.006803-(0.006706*sin2))
        zgrd(j,*,k)=(r*ggrd(j,*,k))/ ( (gammas/gamma45)*r - ggrd(j,*,k) )
    endfor
endfor
;
; calculate area of each gridpoint
;
garea=fltarr(ncw,nrw)
dlat=alat(1)-alat(0)
for i=0,ncw-1 do begin
    for j=0,nrw-1 do begin
        phi1=!pi/180.*(alat(j)-dlat/2.)
        phi2=!pi/180.*(alat(j)+dlat/2.)
        garea(i,j) = hem_area*abs(sin(phi1)-sin(phi2))/float(ncw)
    endfor
endfor
y2d=fltarr(ncw,nrw)
x2d=fltarr(ncw,nrw)
for i=0,ncw-1 do y2d(i,*)=alat
for j=0,nrw-1 do x2d(*,j)=alon
;
; sum area in the vortex at each level
;
vtxeql=-99.+0.*fltarr(nthw,3)
for k=0,nthw-1L do begin
for iedge=0,2 do begin
    tmp=transpose(markgrd(*,*,k))
    if iedge eq 0L then rval=0.50
    if iedge eq 1L then rval=0.75
    if iedge eq 2L then rval=0.90
    if slat gt 0. then index=where(y2d gt 0. and tmp ge rval)
    if slat lt 0. then index=where(y2d lt 0. and tmp ge rval)
    if index(0) ne -1 then begin
       vtxarea=total(garea(index))/hem_area
;
; when the vortex is weak, during formation, decay, and warming events it is
; possible for the vortex field to be greater than 0.5 in places but not exceed
; 0.75 and/or 0.9.  In these cases an outer edge is defined but middle and/or
; inner edges are -99.  These times are associated with a small vortex (Elat > 80deg)
; that is relatively mobile.
;
       for j=0,nr-2 do begin
           if vtxarea le hem_frac(j) and $
              vtxarea gt hem_frac(j+1) then begin
              scale=(hem_frac(j)-vtxarea)/(hem_frac(j)-hem_frac(j+1))
              vtxeql(k,iedge)=ihem*(yeq(j)+scale*(yeq(j+1)-yeq(j)))
              goto,tmpjump3
           endif
       endfor
       tmpjump3:
    endif
endfor
endfor
;
; interpolate UKMO to point location
;
if slon lt alon(0) then slon=slon+360.
for i=0L,ncw-1L do begin
    ip1=i+1
    if i eq ncw-1L then ip1=0L
    xlon=alon(i)
    xlonp1=alon(ip1)
    if i eq ncw-1L then xlonp1=360.+alon(ip1)
    if slon ge xlon and slon le xlonp1 then begin
       xscale=(slon-xlon)/(xlonp1-xlon)
       goto,jumpx
    endif
endfor
jumpx:
for j=0L,nrw-2L do begin
    jp1=j+1
    xlat=alat(j)
    xlatp1=alat(jp1)
    if slat ge xlat and slat le xlatp1 then begin
        yscale=(slat-xlat)/(xlatp1-xlat)
        goto,jumpy
    endif
endfor
jumpy:
;
; interpolate gridded data to profile lon/lat
;
pj1=markgrd(j,i,*)+xscale*(markgrd(j,ip1,*)-markgrd(j,i,*))
pjp1=markgrd(jp1,i,*)+xscale*(markgrd(jp1,ip1,*)-markgrd(jp1,i,*))
vortex_marker_profile=reform(pj1+yscale*(pjp1-pj1))

pj1=pgrd(j,i,*)+xscale*(pgrd(j,ip1,*)-pgrd(j,i,*))
pjp1=pgrd(jp1,i,*)+xscale*(pgrd(jp1,ip1,*)-pgrd(jp1,i,*))
pressure_profile=reform(pj1+yscale*(pjp1-pj1))

pj1=tgrd(j,i,*)+xscale*(tgrd(j,ip1,*)-tgrd(j,i,*))
pjp1=tgrd(jp1,i,*)+xscale*(tgrd(jp1,ip1,*)-tgrd(jp1,i,*))
temperature_profile=reform(pj1+yscale*(pjp1-pj1))

pj1=zgrd(j,i,*)+xscale*(zgrd(j,ip1,*)-zgrd(j,i,*))
pjp1=zgrd(jp1,i,*)+xscale*(zgrd(jp1,ip1,*)-zgrd(jp1,i,*))
altitude_profile=reform(pj1+yscale*(pjp1-pj1))
;
; plot for posterity
;
nc=ncw
nr=nrw
thlev=1000.
slev=strcompress(long(thlev))+' K'
index=where(abs(th-thlev) eq min(abs(th-thlev)))
tp1=transpose(tgrd(*,*,index(0)))
mark1=transpose(markgrd(*,*,index(0)))
tp=0.*fltarr(nc+1,nr)
tp(0:nc-1,0:nr-1)=tp1(0:nc-1,0:nr-1)
tp(nc,*)=tp(0,*)
mark=0.*fltarr(nc+1,nr)
mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
mark(nc,*)=mark(0,*)
x=fltarr(nc+1)
x(0:nc-1)=alon
x(nc)=alon(0)+360.
lon=0.*mark
lat=0.*mark
for i=0,nc   do lat(i,*)=alat
for j=0,nr-1 do lon(*,j)=x
if setplot eq 'ps' then begin
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename=pthout+'mark2point_'+sdate+'.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
MAP_SET,ihem*90,0,0,/ortho,/noeras,/grid,/contin,/noborder,title=sdate,charsize=1.5,color=0
nlvls=20
if ihem eq  1L then index=where(lat gt 0.)
if ihem eq -1L then index=where(lat lt 0.)
tmax=max(tp(index))+5.
tmin=min(tp(index))-5.
tmax=300.
tmin=200.
level=tmin+((tmax-tmin)/float(nlvls))*findgen(nlvls+1)
nlvls=nlvls+1
col1=1+indgen(nlvls)*icolmax/float(nlvls)
contour,tp,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
contour,tp,x,alat,/overplot,levels=level,/follow,$
        c_labels=0*level,/noeras,color=0
contour,mark,x,alat,/overplot,levels=[0.1],thick=15,color=0
contour,mark,x,alat,/overplot,levels=[-0.1],thick=15,color=mcolor
MAP_SET,ihem*90,0,0,/ortho,/noeras,/grid,/contin,color=0
loadct,0
oplot,[slon,slon],[slat,slat],psym=8,symsize=2,color=0.6*mcolor
loadct,39
xyouts,xmn+0.01,ymx-0.04,'Vortex (black)',/normal,color=0
xyouts,xmn+0.01,ymx-0.02,'Anticyclone (white)',/normal,color=0

imin=min(level)
imax=max(level)
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,color=0,xtitle=slev+' Temperature'
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/(float(nlvls)-1)
for j=1,nlvls-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+0.3
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,vortex_marker_profile,th,thick=10,xtitle='Vortex Marker',ytitle='Potential Temperature',$
     title='Rothera '+sloc,xrange=[-1.,1.],color=0,yrange=[400.,max(th)]
xyouts,-.98,450.,'Anticyclone',/data,color=0
xyouts,0.25,450.,'Vortex',/data,color=0
plots,0.,400.
plots,0.,max(th),/continue,color=0
;
; save daily DMP profiles above 400 K
;
longitude=slon
latitude=slat
potential_temperature_profile=th
date=long(sdate)
comment=strarr(9)
comment(0)='Profiles based on U.K. Met Office data and valid at 12 GMT'
comment(1)='date in YYYYMMDD'
comment(2)='longitude in degrees east'
comment(3)='latitude in degrees'
comment(4)='potential_temperature = potential temperature profile (K)'
comment(5)='vortex_marker_profile = positive (negative) values in vortex (anticyclones)'
comment(6)='pressure_profile = Pressure profile (hPa)'
comment(7)='temperature_profile = Temperature profile (K)'
comment(8)='altitude_profile = Geometric Altitude profile (km)'
index=where(th ge 400.)
temperature_profile=temperature_profile(index)
altitude_profile=altitude_profile(index)
potential_temperature_profile=potential_temperature_profile(index)
vortex_marker_profile=vortex_marker_profile(index)
pressure_profile=pressure_profile(index)
save,file=pthout+'marker_rothera_'+sdate+'.sav',date,time,longitude,latitude,$
     potential_temperature_profile,vortex_marker_profile,pressure_profile,$
     temperature_profile,altitude_profile,comment
print,'saved DMP '+sdate

if setplot eq 'x' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim '+pthout+'mark2point_'+sdate+'.ps -rotate -90 '+pthout+'mark2point_'+sdate+'.jpg'
   spawn,'/usr/bin/rm '+pthout+'mark2point_'+sdate+'.ps'
endif
goto,jump
end
