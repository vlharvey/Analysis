;
; check q values in nc3 files
;
@stddat
@kgmt
@ckday
@kdate

dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
uday=0L & lstday=0L & ledday=0L
lstmn=10L & lstdy=17L & lstyr=1991L 
ledmn=3L & leddy=13L & ledyr=2006L
mon=['jan_','feb_','mar_','apr_','may_','jun_','jul_','aug_','sep_','oct_','nov_','dec_']
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
;
; this logic will work through 2090
;
if lstyr ge 91 and lstyr le 99 then lstyr=lstyr+1900
if ledyr ge 91 and ledyr le 99 then ledyr=ledyr+1900
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      if iyr lt 2000 then iyr1=iyr-1900
      if iyr ge 2000 then iyr1=iyr-2000
      syr=string(FORMAT='(I2.2)',iyr1)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      ifile=mon(imn-1)+sdy+'_'+syr
      dum1=findfile(dir+ifile+'.nc3')
      if dum1(0) ne '' then ncid=ncdf_open(dir+ifile+'.nc3')
      if dum1(0) eq '' then goto,jump
      nr=0L & nc=0L & nth=0L
      ncdf_diminq,ncid,0,name,nr
      ncdf_diminq,ncid,1,name,nc
      ncdf_diminq,ncid,2,name,nth
      alon=fltarr(nc)
      alat=fltarr(nr)
      thlev=fltarr(nth)
      q=fltarr(nr,nc,nth)
      ncdf_varget,ncid,0,alon
      ncdf_varget,ncid,1,alat
      ncdf_varget,ncid,2,thlev
      ncdf_varget,ncid,8,q
      ncdf_close,ncid
      if min(q) eq 0. and max(q) eq 0. then print,syr+smn+sdy,min(q),max(q)
goto,jump
end
