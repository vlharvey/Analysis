;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Linearly interpolate UKMO analysis in space and time to MLS profiles
; to generate "Derived Meteorological Products" for the SOSST team
;
; Profile OUTPUT:
;       => number of occultations
;       => time, latitude, longitude, tropopause diagnostics
;	=> number of levels
;       => vertical profiles of pressure, temperature, PV, Eqlat, vortex edge
;
; "fast" version does not perform time interpolation
;
; VLH 11/30/2004
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@kgmt
@ckday
@kdate
@calcelat2d
@interp_poam
@tropopause

sver1='v1.52'
sver2='v2.2'

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
; get a listing of all MLS-Aura_L2GP files in ../Datfiles
;
pth='/aura6/data/MLS_data/Datfiles/'
pthout='/aura6/data/MLS_data/Datfiles_SOSST/'
spawn,'ls '+pthout+'cat_mls_'+sver2+'*20071222.sav',ifiles
nfile=n_elements(ifiles)
for kfile=0L,nfile-1L do begin
;
; skip if DMP already exists
;
result=strsplit(ifiles(kfile),'_',/extract)
result2=strsplit(result(5),'.',/extract)
sdate=result2(0)
print,sdate
dum=findfile(pthout+'dmps_mls_'+sver2+'.meto.'+sdate+'.sav')
;if dum(0) ne '' then goto,jumpday
;
; restore, MLS data
;
icount=0L
icount2=0L
restore,ifiles(kfile)
hh2=time
time=hh2/24.0

restore,'/aura6/data/HIRDLS_data/Datfiles/theta.dat'
thlev=zo
sdate=strcompress(string(date),/remove_all)
nfiles=n_elements(time)
nth=n_elements(thlev)
p_prof=-99.+fltarr(nfiles,nth)
z_prof=-99.+fltarr(nfiles,nth)
tp_prof=-99.+fltarr(nfiles,nth)
pv_prof=-99.+fltarr(nfiles,nth)
elat_prof=-99.+fltarr(nfiles,nth)
velat_prof=-99.+fltarr(nfiles,nth,3)
dyntrop=-99.+fltarr(nfiles)
zthermtrop=-99.+fltarr(nfiles)
pthermtrop=-99.+fltarr(nfiles)
ththermtrop=-99.+fltarr(nfiles)

for n=0L,nfiles-1L do begin
    if latitude(n) lt -90. then goto,jumpprof
    iyr=long(strmid(sdate,0,4))
    imn=long(strmid(sdate,4,2))
    idy=long(strmid(sdate,6,2))
    z = kgmt(imn,idy,iyr,jday)		; calculate Julian day
    slon=longitude(n) & slat=latitude(n)
    if slat lt 0. then ihem=-1
    if slat gt 0. then ihem=1
;   print,id(n),date,time(n),slon,slat
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
       markold=smooth(markold,3,/edge_truncate)
    endif
    if dum(0) ne '' and icount gt 0L then begin
    if ifile ne file1 then begin
       rd_ukmo_nc3,ifile,ncw,nrw,nthw,alon,alat,th,pvold,pold,msfold,$
                   uold,vold,qold,qdfold,markold,vpold,sfold,iflag
       print,'reading '+ifile
       newday=1L
       markold=smooth(markold,3,/edge_truncate)
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
       marknew=smooth(marknew,3,/edge_truncate)
    endif
    if dum(0) ne '' and icount2 gt 0L then begin
    if ifile ne file2 then begin
       rd_ukmo_nc3,ifile,ncw,nrw,nthw,alon,alat,th,pvnew,pnew,msfnew,$
                   unew,vnew,qnew,qdfnew,marknew,vpnew,sfnew,iflag
       print,'reading '+ifile
       newday=1L
       marknew=smooth(marknew,3,/edge_truncate)
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
    pvgrd=pvold+TSCALE*(pvnew-pvold)
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
    endif
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
;if iedge eq 2 then begin
;nlev=20
;col1=mcolor*findgen(nlev)/(float(nlev))
;erase
;map_set,ihem*90,0,0,/ortho,/contin,/grid,/noeras,title=string(th(k))
;egrd1=transpose(egrd(*,*,k))
;pvgrd1=transpose(pvgrd(*,*,k))
;contour,egrd1,alon,alat,/overplot,nlevels=20,/cell_fill,c_color=col1
;contour,egrd1,alon,alat,/overplot,nlevels=20,/follow,color=0
;contour,tmp,alon,alat,/overplot,level=[0.01,0.25,0.5,0.75,1.0],thick=3
;level=[vtxeql(k,2),vtxeql(k,1),vtxeql(k,0)]
;index=sort(level)
;level=level(index)
;contour,egrd1,alon,alat,/overplot,levels=level,thick=2,color=0
;oplot,[slon,slon],[slat,slat],psym=4,symsize=4,color=0
;endif
                  goto,tmpjump3
               endif
           endfor
           tmpjump3:
        endif
    endfor
    endfor
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
; loop over MLS pressure levels
;
    for kk=0L,nth-1L do begin
        th1=thlev(kk)		; vertical intepolation wrt theta

        for k=1L,nthw-1L do begin
            kp1=k-1             ; UKMO data is "top down"
            uz=th(k)
            uzp1=th(kp1)
            zscale=(th1-uz)/(uzp1-uz)

            if th1 ge uz and th1 le uzp1 then begin
               pj1=zgrd(j,i,k)+xscale*(zgrd(j,ip1,k)-zgrd(j,i,k))
               pjp1=zgrd(jp1,i,k)+xscale*(zgrd(jp1,ip1,k)-zgrd(jp1,i,k))
               pj2=zgrd(j,i,kp1)+xscale*(zgrd(j,ip1,kp1)-zgrd(j,i,kp1))
               pjp2=zgrd(jp1,i,kp1)+xscale*(zgrd(jp1,ip1,kp1)-zgrd(jp1,i,kp1))
               p1=pj1+yscale*(pjp1-pj1)
               p2=pj2+yscale*(pjp2-pj2)
               z_prof(n,kk)=p1+zscale*(p2-p1)

               pj1=pgrd(j,i,k)+xscale*(pgrd(j,ip1,k)-pgrd(j,i,k))
               pjp1=pgrd(jp1,i,k)+xscale*(pgrd(jp1,ip1,k)-pgrd(jp1,i,k))
               pj2=pgrd(j,i,kp1)+xscale*(pgrd(j,ip1,kp1)-pgrd(j,i,kp1))
               pjp2=pgrd(jp1,i,kp1)+xscale*(pgrd(jp1,ip1,kp1)-pgrd(jp1,i,kp1))
               p1=pj1+yscale*(pjp1-pj1)
               p2=pj2+yscale*(pjp2-pj2)
               p_prof(n,kk)=alog(p1)+zscale*alog(p2/p1)
               p_prof(n,kk)=exp(p_prof(n,kk))

               pj1=tgrd(j,i,k)+xscale*(tgrd(j,ip1,k)-tgrd(j,i,k))
               pjp1=tgrd(jp1,i,k)+xscale*(tgrd(jp1,ip1,k)-tgrd(jp1,i,k))
               pj2=tgrd(j,i,kp1)+xscale*(tgrd(j,ip1,kp1)-tgrd(j,i,kp1))
               pjp2=tgrd(jp1,i,kp1)+xscale*(tgrd(jp1,ip1,kp1)-tgrd(jp1,i,kp1))
               p1=pj1+yscale*(pjp1-pj1)
               p2=pj2+yscale*(pjp2-pj2)
               tp_prof(n,kk)=p1+zscale*(p2-p1)

               pj1=pvgrd(j,i,k)+xscale*(pvgrd(j,ip1,k)-pvgrd(j,i,k))
               pjp1=pvgrd(jp1,i,k)+xscale*(pvgrd(jp1,ip1,k)-pvgrd(jp1,i,k))
               pj2=pvgrd(j,i,kp1)+xscale*(pvgrd(j,ip1,kp1)-pvgrd(j,i,kp1))
               pjp2=pvgrd(jp1,i,kp1)+xscale*(pvgrd(jp1,ip1,kp1)-pvgrd(jp1,i,kp1))
               p1=pj1+yscale*(pjp1-pj1)
               p2=pj2+yscale*(pjp2-pj2)
               pv_prof(n,kk)=p1+zscale*(p2-p1)
;              pv_prof(n,kk)=alog(abs(p1))+pscale*alog(p2/p1)
;              pv_prof(n,kk)=(p1/abs(p1))*exp(pv_prof(n,kk))

               pj1=egrd(j,i,k)+xscale*(egrd(j,ip1,k)-egrd(j,i,k))
               pjp1=egrd(jp1,i,k)+xscale*(egrd(jp1,ip1,k)-egrd(jp1,i,k))
               pj2=egrd(j,i,kp1)+xscale*(egrd(j,ip1,kp1)-egrd(j,i,kp1))
               pjp2=egrd(jp1,i,kp1)+xscale*(egrd(jp1,ip1,kp1)-egrd(jp1,i,kp1))
               p1=pj1+yscale*(pjp1-pj1)
               p2=pj2+yscale*(pjp2-pj2)
               elat_prof(n,kk)=p1+zscale*(p2-p1)
               for iedge=0L,2L do begin
               v1=vtxeql(k,iedge)
               v2=vtxeql(kp1,iedge)
               if v1 ne -99. and v2 ne -99. then velat_prof(n,kk,iedge)=v1+zscale*(v2-v1)
               endfor
               if velat_prof(n,kk,0) ne -99. and abs(velat_prof(n,kk,0)) lt 20. then $
                  print,'EDGE ',velat_prof(n,kk,0)
;              print,th1,p_prof(n,kk),tp_prof(n,kk),pv_prof(n,kk),elat_prof(n,kk),velat_prof(n,kk,0)
               goto,jumpz
            endif
        endfor
jumpz:
    endfor
;
; TROPOPAUSE CALCULATION
; interpolate to the height (km) of the dynamical tropopause (PV=2.5 PVU)
; calculate the height (km), pressure (hPa), and potential temperature (K) of the thermal tropopause
;
    z0=reform(z_prof(n,*))
    p0=reform(p_prof(n,*))
    tp0=reform(tp_prof(n,*))
    th0=tp0+(1000./p0)^0.286
    pv0=reform(pv_prof(n,*))
    pvval=2.5e-6
    interp_poam,1,nth,reverse(z0),reverse(abs(pv0)),aer_theta,pvval
    dyntrop(n)=aer_theta
;   print,'dyntrop= ',aer_theta
    tropopause,tp0,p0,z0,th0,nth,p_trop,z_trop,th_trop
;   print,'thermtrop ',z_trop,p_trop,th_trop
    zthermtrop(n)=z_trop
    pthermtrop(n)=p_trop
    ththermtrop(n)=th_trop
jumpprof:
endfor
erase
set_viewport,.1,.45,.3,.6
plot,velat_prof(*,15,0),psym=4,yrange=[0.,90.],symsize=0.5,title='Vortex Elat 45 km',/noeras
oplot,elat_prof(*,15),psym=3,color=mcolor*.9
set_viewport,.55,.9,.3,.6
plot,pv_prof(*,15),psym=4,yrange=[min(pv_prof(*,15)),max(pv_prof(*,15))],$
     symsize=0.5,title='PV 45 km',/noeras
;
; save daily DMP file
;
time=hh2
save,file=pthout+'dmps_mls_'+sver2+'.meto.'+sdate+'.sav',id,date,time,longitude,latitude,thlev,$
     p_prof,tp_prof,pv_prof,elat_prof,velat_prof,dyntrop,zthermtrop,pthermtrop,ththermtrop
print,'saved DMP '+sdate
jumpday:
endfor		; loop over days
end
