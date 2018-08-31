;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GEOS-5 version 5.2
; Linearly interpolate GEOS "vortex marker" to MLS profile locations
; DO NOT INTERPOLATE THE MARKER IN TIME
;
; Profile OUTPUT:
;       => number of occultations
;       => time, latitude, longitude, tropopause diagnostics
;       => number of levels (121) 121km - 0km
;       => vertical profiles of "marker"
;
; VLH 11/30/2004
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@kgmt
@ckday
@kdate
@calcelat2d
@interp_poam
@tropopause
@rd_geos5_nc3_meto

sver='v1.52'
sver='v2.2'
sver='v3.3'

loadct,38
mcolor=byte(!p.color)
device,decompose=0
a=findgen(8)*(!pi/8.)
usersym,cos(a),sin(a),/fill
!type=2^2+2^3

mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
dir2='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS520.MetO.'
dir1='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
ks=1.931853d-3
ecc=0.081819
gamma45=9.80
;
; get a listing of all "cat" files in ../Datfiles_SOSST
;
pth='/aura6/data/MLS_data/Datfiles/'
pthout='/aura6/data/MLS_data/Datfiles_SOSST/'
altitude=findgen(121)
spawn,'ls '+pthout+'cat_mls_'+sver+'*.sav',ifiles
nfile=n_elements(ifiles)
for kfile=0L,nfile-1L do begin
;
; skip if mark file already exists
;
result=strsplit(ifiles(kfile),'_',/extract)
result2=strsplit(result(5),'.',/extract)
sdate=result2(0)
print,sdate
dum=findfile(pthout+'mark_mls_'+sver+'.geos5.'+sdate+'.sav')
if dum(0) ne '' then goto,jumpday
;
; restore, MLS data
;
icount=0L
icount2=0L
restore,ifiles(kfile)
nfiles=n_elements(time)
nz=n_elements(altitude)
mark_prof=-99.+fltarr(nfiles,nz)

sdate=strcompress(string(date),/remove_all)
iyr=long(strmid(sdate,0,4))
imn=long(strmid(sdate,4,2))
idy=long(strmid(sdate,6,2))
z = kgmt(imn,idy,iyr,jday)          ; calculate Julian day
;
; read GEOS-5 data
;
ifile=dir1+sdate+'_AVG.V01.nc3'
dum=findfile(ifile)
if dum(0) eq '' then ifile=dir2+sdate+'_AVG.V01.nc3'
dum=findfile(ifile)
if dum(0) eq '' then goto,jumpday
ncid=ncdf_open(ifile)
ncdf_diminq,ncid,0,name,nr
ncdf_diminq,ncid,1,name,nc
ncdf_diminq,ncid,2,name,nth
alon=fltarr(nc)
alat=fltarr(nr)
th=fltarr(nth)
ncdf_varget,ncid,0,alon
ncdf_varget,ncid,1,alat
ncdf_varget,ncid,2,th
pgrd=fltarr(nr,nc,nth)
msfgrd=fltarr(nr,nc,nth)
ncdf_varget,ncid,4,pgrd
ncdf_varget,ncid,5,msfgrd
ncdf_close,ncid
mfile=dir1+sdate+'_AVG.V01.nc4'
dum=findfile(mfile)
if dum(0) eq '' then mfile=dir2+sdate+'_AVG.V01.nc4'
ncid=ncdf_open(mfile)
markgrd=fltarr(nr,nc,nth)
ncdf_varget,ncid,3,markgrd
ncdf_close,ncid
print,sdate,' reading '+ifile
;
; normalise marker to be -1s, zeros, and 1s only
;
index=where(markgrd ne 0.)
markgrd(index)=markgrd(index)/abs(markgrd(index))
;
; smooth marker to give "edge" values
;
markgrd=smooth(markgrd,3)
;
; calculate geopotential height of isentropic surface = (msf - cp*T)/g
; where T = theta* (p/po)^R/cp and divide by 1000 for km
tgrd=0.*pgrd
ggrd=0.*pgrd
zgrd=0.*pgrd
for k=0L,nth-1L do begin
    tgrd(0:nr-1,0:nc-1,k)=th(k)*( (pgrd(0:nr-1,0:nc-1,k)/1000.)^(.286) )
    ggrd(0:nr-1,0:nc-1,k)=(msfgrd(0:nr-1,0:nc-1,k)-1004.* $
                          tgrd(0:nr-1,0:nc-1,k))/(9.86*1000.)
;
; convert geopotential to geometric height
;
    for j=0L,nr-1L do begin
        sin2=sin( (alat(j)*dtr)^2.0 )
        numerator=1.0+ks*sin2
        denominator=sqrt( 1.0 - (ecc^2.0)*sin2 )
        gammas=gamma45*(numerator/denominator)
        r=6378.137/(1.006803-(0.006706*sin2))
        zgrd(j,*,k)=(r*ggrd(j,*,k))/ ( (gammas/gamma45)*r - ggrd(j,*,k) )
    endfor
endfor
;
; loop over MLS profiles
;
for n=0L,nfiles-1L do begin
    if latitude(n) lt -90. then goto,jumpprof
    slon=longitude(n) & slat=latitude(n)
;   print,nfiles,n,slon,slat
;
; logic to handle profiles which are out of the GEOS-5 latitude range
;
    if slat lt min(alat) then slat=min(alat)
    if slat gt max(alat) then slat=max(alat)
;
; interpolate GEOS-5 to MLS location
;
    if slon lt alon(0) then slon=slon+360.
    for i=0L,nc-1L do begin
        ip1=i+1
        if i eq nc-1L then ip1=0L
        xlon=alon(i)
        xlonp1=alon(ip1)
        if i eq nc-1L then xlonp1=360.+alon(ip1)
        if slon ge xlon and slon le xlonp1 then begin
           xscale=(slon-xlon)/(xlonp1-xlon)
           goto,jumpx
        endif
    endfor
jumpx:
    for j=0L,nr-2L do begin
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
; loop over MLS altitude levels
;
    for kk=10L,nz-1L do begin
        pz=altitude(kk)         ; use for vertical intepolation wrt altitude
        if pz gt max(zgrd) then goto,jumpprof
        for k=1L,nth-1L do begin
            kp1=k-1             ; GEOS-5 data is "top down"
            uz=zgrd(j,i,k)
            uzp1=zgrd(j,i,kp1)
;
; impose a more rigorous vertical interpolation scale factor based on
; ALL 8 surrounding gridpoints, not just 2: (j,i,k) and (j,i,kp1)
;
;           pj1=zgrd(j,i,k)+xscale*(zgrd(j,ip1,k)-zgrd(j,i,k))
;           pjp1=zgrd(jp1,i,k)+xscale*(zgrd(jp1,ip1,k)-zgrd(jp1,i,k))
;           pj2=zgrd(j,i,kp1)+xscale*(zgrd(j,ip1,kp1)-zgrd(j,i,kp1))
;           pjp2=zgrd(jp1,i,kp1)+xscale*(zgrd(jp1,ip1,kp1)-zgrd(jp1,i,kp1))
;           uz=pj1+yscale*(pjp1-pj1)
;           uzp1=pj2+yscale*(pjp2-pj2)

            if pz ge uz and pz le uzp1 then begin
               zscale=(pz-uz)/(uzp1-uz)
               mark_prof(n,kk)=(markgrd(j,i,k)+markgrd(j,ip1,k)+markgrd(jp1,i,k)+$
                  markgrd(jp1,ip1,k)+markgrd(j,i,kp1)+markgrd(j,ip1,kp1)+$
                  markgrd(jp1,i,kp1)+markgrd(jp1,ip1,kp1))/8.
;              print,pz,mark_prof(n,kk)
               goto,jumpz
            endif
        endfor
jumpz:
    endfor
jumpprof:
endfor
;
; save daily DMP file
;
save,file=pthout+'mark_mls_'+sver+'.geos5.'+sdate+'.sav',id,date,time,longitude,latitude,altitude,mark_prof
print,'saved mark_mls_'+sver+'.geos5.'+sdate+'.sav'
jumpday:
endfor		; loop over days
end
