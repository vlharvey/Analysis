;****************************************************************************************
; check for multiple files per day (c01, c02, ...)
;
;****************************************************************************************
@stddat
@kgmt
@ckday
@kdate
@readl2gp_std
@aura2date
loadct,38
mcolor=byte(!p.color)
;
; version
;
sver='v2.2'
;
; enter dates to convert MLS pressure data
;
lstmn=9L & lstdy=30L & lstyr=8L
ledmn=11L & leddy=30L & ledyr=8L
lstday=0L & ledday=0L 
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 or lstyr gt 2011 then stop,'Year out of range '
if ledyr lt 1991 or ledyr gt 2011 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
dir='/aura6/data/MLS_data/Datfiles/'
odir='/aura6/data/MLS_data/Datfiles_SOSST/'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
;
; loop over dates
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays gt ledday then stop,' Normal termination condition '
      syr=string(FORMAT='(I4.4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
print,sdate
;
; look for EOS-MLS data files for today
;
      spawn,'ls '+dir+'MLS-Aura_L2GP-CO_v02-2*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',files
      result1=size(files)
;
; how many files today?  print only if more than 1
;
      if files(0) ne '' and result1(1) gt 1L then begin
         print,result1(1),' files on '+sdate
         print,files
         goto,jump
      endif
goto,jump
end
