;
; input x,y,th,date,time and output elat and velat
;
@calcelat2d
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc3

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='ps'
read,'setplot=',setplot
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
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
imn=1 & idy=1 & iyr=2005
read,' Enter date (month, day, year) ',imn,idy,iyr
if iyr lt 91 then iyr=iyr+2000
if iyr lt 1900 then iyr=iyr+1900
if iyr lt 1991 then stop,'Year out of range '
time=20.
read,' Enter UT time (0-24 hours) ',time
stime=strcompress(string(time))
time=time/24.	; convert to fractional day
slon=30. & slat=50. & sth=1000.
read,' Enter longitude, latitude, theta ',slon,slat,sth
sloc='x= '+strcompress(string(slon))+$
     ' :y= '+strcompress(string(slat))+$
     ' :th= '+strcompress(string(sth))
if slat lt 0. then ihem=-1
if slat gt 0. then ihem=1
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
dum=findfile(ifile)
if dum(0) ne '' then begin
   rd_ukmo_nc3,ifile,ncw,nrw,nthw,alon,alat,th,pvold,pold,msfold,$
               uold,vold,qold,qdfold,markold,vpold,sfold,iflag
   markold=smooth(markold,3,/edge_truncate)
endif
;
; read UKMO data on day 1
;
ifile=diru+string(FORMAT='(a4,i2.2,a1,i2.2,a4)',mon(imn1-1L),idy1,'_',iyr1,'.nc3')
dum=findfile(ifile)
if dum(0) ne '' then begin
   rd_ukmo_nc3,ifile,ncw,nrw,nthw,alon,alat,th,pvnew,pnew,msfnew,$
               unew,vnew,qnew,qdfnew,marknew,vpnew,sfnew,iflag
   marknew=smooth(marknew,3,/edge_truncate)
endif
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
for k=1L,nthw-1L do begin
    kp1=k-1
    thlev=th(k)
    thlevp1=th(kp1)
    if sth ge thlev and sth le thlevp1 then begin
        zscale=(sth-thlev)/(thlevp1-thlev)
        goto,jumpz
    endif
endfor
jumpz:

pj1=egrd(j,i,k)+xscale*(egrd(j,ip1,k)-egrd(j,i,k))
pjp1=egrd(jp1,i,k)+xscale*(egrd(jp1,ip1,k)-egrd(jp1,i,k))
pj2=egrd(j,i,kp1)+xscale*(egrd(j,ip1,kp1)-egrd(j,i,kp1))
pjp2=egrd(jp1,i,kp1)+xscale*(egrd(jp1,ip1,kp1)-egrd(jp1,i,kp1))
p1=pj1+yscale*(pjp1-pj1)
p2=pj2+yscale*(pjp2-pj2)
elat0=p1+zscale*(p2-p1)
print,'elat = ',elat0
for iedge=0L,2L do begin
    v1=vtxeql(k,iedge)
    v2=vtxeql(kp1,iedge)
    if v1 ne -99. and v2 ne -99. then velat0=v1+zscale*(v2-v1)
    if iedge eq 0L then print,'outer edge = ',velat0
    if iedge eq 1L then print,'middle edge = ',velat0
    if iedge eq 2L then print,'inner edge = ',velat0
endfor
;
; plot for posterity
;
nc=ncw
nr=nrw
index=where(abs(th-thlev) eq min(abs(th-thlev)))
elat1=transpose(egrd(*,*,index(0)))
mark1=transpose(markgrd(*,*,index(0)))
elat=0.*fltarr(nc+1,nr)
elat(0:nc-1,0:nr-1)=elat1(0:nc-1,0:nr-1)
elat(nc,*)=elat(0,*)
mark=0.*fltarr(nc+1,nr)
mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
mark(nc,*)=mark(0,*)
x=fltarr(nc+1)
x(0:nc-1)=alon
x(nc)=alon(0)+360.
lon=0.*elat
lat=0.*elat
for i=0,nc   do lat(i,*)=alat
for j=0,nr-1 do lon(*,j)=x
if setplot eq 'ps' then begin
   lc=0
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/color,/landscape,bits=8,filename='elat2point_'+sdate+'.ps'
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
xyouts,.2,.92,sloc,/normal,charsize=2
MAP_SET,90,0,0,/stereo,/noeras,/grid,/contin,/noborder,title=sdate+' t ='+stime,charsize=2.0
oplot,findgen(361),0.1+0.*findgen(361)
index=where(lat gt 0.)
nlvls=31
level=3.*findgen(nlvls)
col1=1+indgen(nlvls)*icolmax/float(nlvls)
contour,elat,x,alat,/overplot,levels=level,c_color=col1,$
       /cell_fill,/noeras
contour,elat,x,alat,/overplot,levels=level,/follow,$
        c_labels=0*level,/noeras,color=0
contour,mark,x,alat,/overplot,levels=[0.1],thick=10,color=mcolor
MAP_SET,90,0,0,/stereo,/noeras,/grid,/contin,/noborder,charsize=2.0
oplot,[slon,slon],[slat,slat],psym=8,symsize=2,color=0
imin=min(level)
imax=max(level)
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/(float(nlvls)-1)
for j=1,nlvls-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor
if setplot ne 'ps' then stop
if setplot eq 'ps' then device, /close
end
