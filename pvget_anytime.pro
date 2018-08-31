;
; compute PV and Equivalent latitude at a given longitude and latitude and theta
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc3
@calcelat2d
mon=['jan_','feb_','mar_','apr_','may_','jun_','jul_','aug_','sep_','oct_','nov_','dec_']
lstmn=0L & lstdy=0L & lstyr=0L & ledmn=0L & leddy=0L & ledyr=0L & lstday=0L & ledday=0L
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
;
; --- Loop here --------
;
jump: iday = iday + 1
      print,iday,iyr
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
;
;***Read UKMO isentropic PV
;
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr
      ncid=ncdf_open(diru+ifile+'.nc3')
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
; interpolate elat2 to xpt, ypt, thpt
;
      xpt=[0.,0.] & ypt=[45.,80.] & thpt=[1000.,1000.]
      npt=n_elements(xpt)
      pvpt=fltarr(npt)
      elatpt=fltarr(npt)
      FOR IPT=0l,NPT-1l DO BEGIN

      if xpt(ipt) lt alon(0) then xpt(ipt)=xpt(ipt)+360.
      for i=0L,nc-1L do begin
          ip1=i+1
          if i eq nc-1L then ip1=0L
          xlon=alon(i)
          xlonp1=alon(ip1)
          if i eq nc-1L then xlonp1=360.+alon(ip1)
          if xpt(ipt) ge xlon and xpt(ipt) le xlonp1 then begin
             xscale=(xpt(ipt)-xlon)/(xlonp1-xlon)
             goto,jumpx
          endif
      endfor
jumpx:
      for j=0L,nr-2L do begin
          jp1=j+1
          xlat=alat(j)
          xlatp1=alat(jp1)
          if ypt(ipt) ge xlat and ypt(ipt) le xlatp1 then begin
              yscale=(ypt(ipt)-xlat)/(xlatp1-xlat)
              goto,jumpy
          endif
      endfor
jumpy:
      for kk=1L,nth-1L do begin
          kp1=kk-1             ; UKMO theta profile is top down
          uth=th(kk)
          uthp1=th(kp1)
          if thpt(ipt) ge uth and thpt(ipt) le uthp1 then begin
             zscale=(thpt(ipt)-uth)/(uthp1-uth)

             pj1=pv2(j,i,kk)+xscale*(pv2(j,ip1,kk)-pv2(j,i,kk))
             pjp1=pv2(jp1,i,kk)+xscale*(pv2(jp1,ip1,kk)-pv2(jp1,i,kk))
             pj2=pv2(j,i,kp1)+xscale*(pv2(j,ip1,kp1)-pv2(j,i,kp1))
             pjp2=pv2(jp1,i,kp1)+xscale*(pv2(jp1,ip1,kp1)-pv2(jp1,i,kp1))
             p1=pj1+yscale*(pjp1-pj1)
             p2=pj2+yscale*(pjp2-pj2)
             pvpt(ipt)=p1+zscale*(p2-p1)

             pj1=elat2(j,i,kk)+xscale*(elat2(j,ip1,kk)-elat2(j,i,kk))
             pjp1=elat2(jp1,i,kk)+xscale*(elat2(jp1,ip1,kk)-elat2(jp1,i,kk))
             pj2=elat2(j,i,kp1)+xscale*(elat2(j,ip1,kp1)-elat2(j,i,kp1))
             pjp2=elat2(jp1,i,kp1)+xscale*(elat2(jp1,ip1,kp1)-elat2(jp1,i,kp1))
             p1=pj1+yscale*(pjp1-pj1)
             p2=pj2+yscale*(pjp2-pj2)
             elatpt(ipt)=p1+zscale*(p2-p1)

             print,xscale,yscale,zscale,pvpt(ipt),elatpt(ipt)
             goto,jumpz
          endif
      endfor
jumpz:
      ENDFOR
      stop
goto, jump
end
