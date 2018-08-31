;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Linearly interpolate UKMO "vortex marker" to MLS profile locations
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

sver='v1.52'
sver='v2.2'

loadct,38
mcolor=byte(!p.color)
device,decompose=0
a=findgen(8)*(!pi/8.)
usersym,cos(a),sin(a),/fill
!type=2^2+2^3

mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
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
;
; get a listing of all "cat" files in ../Datfiles_SOSST
;
pth='/aura6/data/MLS_data/Datfiles/'
pthout='/aura6/data/MLS_data/Datfiles_SOSST/'
;restore,pthout+'cat_mls_v1.52_20060112.sav'		; get altitude array
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
dum=findfile(pthout+'mark_mls_'+sver+'.meto.'+sdate+'.sav')
if dum(0) ne '' then goto,jumpday
;
; restore, MLS data
;
icount=0L
icount2=0L
restore,ifiles(kfile)
hh2=time
time=hh2/24.0
nfiles=n_elements(time)
sdate=strcompress(string(date),/remove_all)
nz=n_elements(altitude)
mark_prof=-99.+fltarr(nfiles,nz)

for n=0L,nfiles-1L do begin
    if latitude(n) lt -90. then goto,jumpprof
    iyr=long(strmid(sdate,0,4))
    imn=long(strmid(sdate,4,2))
    idy=long(strmid(sdate,6,2))
    z = kgmt(imn,idy,iyr,jday)		; calculate Julian day
    slon=longitude(n) & slat=latitude(n)
    if slat lt 0. then ihem=-1
    if slat gt 0. then ihem=1
;   print,nfiles,n,iyr,imn,idy,time(n),slon,slat
;
; determine 2 bounding dates in (month, day, year) format
; based on fractional year and day and analyses valid at 12Z
;
    if time(n) lt 0.5 then begin
        jday0=jday-1.0
        jday1=jday
        tscale=time(n)+0.5
    endif
    if time(n) ge 0.5 then begin
        jday0=jday
        jday1=jday+1.0
        tscale=time(n)-0.5
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
    ifile=diru+string(FORMAT='(a4,i2.2,a1,i2.2,a4)',mon(imn0-1L),idy0,'_',iyr0,'.nc3')
    dum=findfile(ifile)
    if dum(0) eq '' then goto,jumpprof
    if dum(0) ne '' and icount eq 0L then begin
       rd_ukmo_nc3,ifile,ncw,nrw,nthw,alon,alat,th,pvold,pold,msfold,$
                   uold,vold,qold,qdfold,markold,vpold,sfold,iflag
       icount=1L
       newday=1L
       print,'reading '+ifile
       file1=ifile
    endif
    if dum(0) ne '' and icount gt 0L then begin
    if ifile ne file1 then begin
       rd_ukmo_nc3,ifile,ncw,nrw,nthw,alon,alat,th,pvold,pold,msfold,$
                   uold,vold,qold,qdfold,markold,vpold,sfold,iflag
       print,'reading '+ifile
       newday=1L
    endif
    endif
    file1=ifile
;
; read UKMO data on day 1
;
    ifile=diru+string(FORMAT='(a4,i2.2,a1,i2.2,a4)',mon(imn1-1L),idy1,'_',iyr1,'.nc3')
    dum=findfile(ifile)
    if dum(0) ne '' and icount2 eq 0L then begin
       rd_ukmo_nc3,ifile,ncw,nrw,nthw,alon,alat,th,pvnew,pnew,msfnew,$
                   unew,vnew,qnew,qdfnew,marknew,vpnew,sfnew,iflag
       print,n,nfiles,ifile
       icount2=1L
       newday=1L
       print,'reading '+ifile
       file2=ifile
    endif
    if dum(0) ne '' and icount2 gt 0L then begin
    if ifile ne file2 then begin
       rd_ukmo_nc3,ifile,ncw,nrw,nthw,alon,alat,th,pvnew,pnew,msfnew,$
                   unew,vnew,qnew,qdfnew,marknew,vpnew,sfnew,iflag
       print,'reading '+ifile
       newday=1L
    endif
    endif
    file2=ifile
;
; check for a bad day of MetO data
;
    if min(pvold) eq 1.00000e+12 or min(pvnew) eq 1.00000e+12 then goto,jumpprof
;
; perform time interpolation only if new daY
;
    if newday eq 1L then begin
       pgrd=pold+TSCALE*(pnew-pold)
       msfgrd=msfold+TSCALE*(msfnew-msfold)
       if time(n) lt 0.5 then markgrd=markold
       if time(n) ge 0.5 then markgrd=marknew
;
; normalise marker to be -1s, zeros, and 1s only
;
       index=where(markgrd ne 0.)
       markgrd(index)=markgrd(index)/abs(markgrd(index))
;
; calculate geopotential height of isentropic surface = (msf - cp*T)/g
; where T = theta* (p/po)^R/cp and divide by 1000 for km
       tgrd=0.*pgrd
       ggrd=0.*pgrd
       zgrd=0.*pgrd
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
    endif
;
; logic to handle profiles which are out of the MetO latitude range
;
    if slat lt min(alat) then slat=min(alat)
    if slat gt max(alat) then slat=max(alat)
;
; interpolate UKMO to MLS location
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
; loop over MLS altitude levels
;
    for kk=0L,nz-1L do begin
        pz=altitude(kk)         ; use for vertical intepolation wrt altitude
        if pz gt max(zgrd) then goto,jumpprof
        for k=1L,nthw-1L do begin
            kp1=k-1             ; UKMO data is "top down"
;           uz=zgrd(j,i,k)
;           uzp1=zgrd(j,i,kp1)
;
; impose a more rigorous vertical interpolation scale factor based on
; ALL 8 surrounding gridpoints, not just 2: (j,i,k) and (j,i,kp1)
;
            pj1=zgrd(j,i,k)+xscale*(zgrd(j,ip1,k)-zgrd(j,i,k))
            pjp1=zgrd(jp1,i,k)+xscale*(zgrd(jp1,ip1,k)-zgrd(jp1,i,k))
            pj2=zgrd(j,i,kp1)+xscale*(zgrd(j,ip1,kp1)-zgrd(j,i,kp1))
            pjp2=zgrd(jp1,i,kp1)+xscale*(zgrd(jp1,ip1,kp1)-zgrd(jp1,i,kp1))
            uz=pj1+yscale*(pjp1-pj1)
            uzp1=pj2+yscale*(pjp2-pj2)
            zscale=(pz-uz)/(uzp1-uz)

            if pz ge uz and pz le uzp1 then begin
;
; retain binary marker field.  Require at least 2 surrounding gridpoints to be
; anticyclone or vortex for mark_prof to be anticyclone or vortex.  else, ambient.
;
               if markgrd(j,i,k)+markgrd(j,ip1,k)+markgrd(jp1,i,k)+$
                  markgrd(jp1,ip1,k)+markgrd(j,i,kp1)+markgrd(j,ip1,kp1)+$
                  markgrd(jp1,i,kp1)+markgrd(jp1,ip1,kp1) le -2.0 then mark_prof(n,kk)=-1.0
               if markgrd(j,i,k)+markgrd(j,ip1,k)+markgrd(jp1,i,k)+$
                  markgrd(jp1,ip1,k)+markgrd(j,i,kp1)+markgrd(j,ip1,kp1)+$
                  markgrd(jp1,i,kp1)+markgrd(jp1,ip1,kp1) ge 2.0 then mark_prof(n,kk)=1.0
               if abs(markgrd(j,i,k)+markgrd(j,ip1,k)+markgrd(jp1,i,k)+$
                  markgrd(jp1,ip1,k)+markgrd(j,i,kp1)+markgrd(j,ip1,kp1)+$
                  markgrd(jp1,i,kp1)+markgrd(jp1,ip1,kp1)) lt 2.0 then mark_prof(n,kk)=0.0
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
time=hh2
save,file=pthout+'mark_mls_'+sver+'.meto.'+sdate+'.sav',id,date,time,longitude,latitude,altitude,mark_prof
jumpday:
endfor		; loop over days
end
