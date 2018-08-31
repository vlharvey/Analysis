pro pvget,date,time,lat,lon,theta,pv,elat
;
; compute PV and Equivalent latitude at given dates, times, lons, lats, and thetas
;
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
;
; define dimensions
;
nday=n_elements(date)
ntheta=n_elements(theta)
pv=fltarr(nday,ntheta)
elat=fltarr(nday,ntheta)
;
; loop over dates
;
for n=0L,nday-1L do begin
;
;***Read UKMO isentropic PV on date(n)
;
    sdate=strtrim(string(date(n)),2)
    print,sdate,lon(n),lat(n)
    syr=strmid(sdate,0,4)
    uyr=strmid(sdate,2,2)
    smn=strmid(sdate,4,2)
    imn=long(smn)
    sdy=strmid(sdate,6,2)
    ifile=mon(imn-1)+sdy+'_'+uyr
    ncid=ncdf_open(diru+ifile+'.nc3')
    if n eq 0L then begin
       nc=0L & nr=0L & nth=0L
       ncdf_diminq,ncid,0,name,nr
       ncdf_diminq,ncid,1,name,nc
       ncdf_diminq,ncid,2,name,nth
       alon=fltarr(nc)
       alat=fltarr(nr)
       th=fltarr(nth)
       pv2=fltarr(nr,nc,nth)
       ncdf_varget,ncid,0,alon
       ncdf_varget,ncid,1,alat
       ncdf_varget,ncid,2,th
    endif
    ncdf_varget,ncid,3,pv2
    ncdf_close,ncid
;
; calculate 3d Equivalent latitude
;
    elat2=0.*pv2
    for ith=0,nth-1 do begin
        pv1=transpose(pv2(*,*,ith))
        elat1=calcelat2d(pv1,alon,alat)
        elat2(*,*,ith)=transpose(elat1)
    endfor
;
; interpolate elat2 to lon(n), lat(n), theta
;
    if lon(n) lt alon(0) then lon(n)=lon(n)+360.
    for i=0L,nc-1L do begin
        ip1=i+1
        if i eq nc-1L then ip1=0L
        xlon=alon(i)
        xlonp1=alon(ip1)
        if i eq nc-1L then xlonp1=360.+alon(ip1)
        if lon(n) ge xlon and lon(n) le xlonp1 then begin
           xscale=(lon(n)-xlon)/(xlonp1-xlon)
           goto,jumpx
        endif
    endfor
jumpx:
    for j=0L,nr-2L do begin
        jp1=j+1
        xlat=alat(j)
        xlatp1=alat(jp1)
        if lat(n) ge xlat and lat(n) le xlatp1 then begin
            yscale=(lat(n)-xlat)/(xlatp1-xlat)
            goto,jumpy
        endif
    endfor
jumpy:
    for k=0L,ntheta-1L do begin 
      for kk=1L,nth-1L do begin
          kp1=kk-1             ; UKMO theta profile is top down
          uth=th(kk)
          uthp1=th(kp1)
          if theta(k) ge uth and theta(k) le uthp1 then begin
             zscale=(theta(k)-uth)/(uthp1-uth)

             pj1=pv2(j,i,kk)+xscale*(pv2(j,ip1,kk)-pv2(j,i,kk))
             pjp1=pv2(jp1,i,kk)+xscale*(pv2(jp1,ip1,kk)-pv2(jp1,i,kk))
             pj2=pv2(j,i,kp1)+xscale*(pv2(j,ip1,kp1)-pv2(j,i,kp1))
             pjp2=pv2(jp1,i,kp1)+xscale*(pv2(jp1,ip1,kp1)-pv2(jp1,i,kp1))
             p1=pj1+yscale*(pjp1-pj1)
             p2=pj2+yscale*(pjp2-pj2)
             pv(n,k)=p1+zscale*(p2-p1)

             pj1=elat2(j,i,kk)+xscale*(elat2(j,ip1,kk)-elat2(j,i,kk))
             pjp1=elat2(jp1,i,kk)+xscale*(elat2(jp1,ip1,kk)-elat2(jp1,i,kk))
             pj2=elat2(j,i,kp1)+xscale*(elat2(j,ip1,kp1)-elat2(j,i,kp1))
             pjp2=elat2(jp1,i,kp1)+xscale*(elat2(jp1,ip1,kp1)-elat2(jp1,i,kp1))
             p1=pj1+yscale*(pjp1-pj1)
             p2=pj2+yscale*(pjp2-pj2)
             elat(n,k)=p1+zscale*(p2-p1)

;            print,theta(k),pv(n,k),elat(n,k)
             goto,jumpz
          endif
      endfor
jumpz:
    endfor
endfor
return
end
