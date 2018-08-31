;
; generate a .fil file of mon_dd_yy
;
@stddat
@kgmt
@ckday
@kdate
lstmn=0L & lstdy=0L & lstyr=0L & ledmn=0L & leddy=0L & ledyr=0L
lstday=0L & ledday=0L
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
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
close,2
openw,2,'tmp.fil'
nday=long(ledday-lstday)+1L
printf,2,nday
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays gt ledday then begin
         close,2
         stop
      endif
      if iyr ge 2000 then iyr1=iyr-2000
      if iyr le 1999 then iyr1=iyr-1900
      date=strcompress(string(FORMAT='(A4,I2.2,A1,I2.2)',mon(imn-1L),idy,'_',iyr1))
      printf,2,date
goto, jump
end
