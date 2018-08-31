@stddat
@kgmt
@ckday
@kdate
@date2uars
lstmn=0
lstdy=0
lstyr=0
ledmn=0
leddy=0
ledyr=0
lstday=0
ledday=0
uday=0
dir='/usr34/users/harvey/tmp/couk'

print, ' '
print, '      UKMO Version '
print, ' '
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr

if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 or lstyr gt 1998 then stop,'Year out of range '
if ledyr lt 1991 or ledyr gt 1998 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      print,'kdate ',float(iday),iyr,imn,idy
      ckday,iday,iyr
      print,'ckday ',float(iday),iyr,imn,idy

; --- Calculate UARS day from (imn,idy,iyr) information.
      z = date2uars(imn,idy,iyr,uday)
      print,imn,idy,iyr,' = UARS day ',fix(uday)

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays gt ledday then stop,' Normal termination condition '

      goto, jump
end
