;
; check for missing days in the UKMO database
;
@stddat
@kgmt
@ckday
@kdate
@date2uars

dir='/aura3/data/UKMO_data/Datfiles/'
uday=0L & lstmn=0L & lstdy=0L & lstyr=0L & ledmn=0L & leddy=0L & ledyr=0L & lstday=0L & ledday=0L
month=['jan','feb','mar','apr','may','jun','jul','aug','sep','oct','nov','dec']
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
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
      ifile=dir+'ukmo_'+month(imn-1)+'_'+sdy+'_'+syr+'.nc3'
      dum=findfile(ifile)
      if dum(0) eq '' then begin
         z = date2uars(imn,idy,iyr,uday)
         print,'missing '+ifile,uday
      endif
      ifile=dir+'ppassm_y'+syr+'_m'+smn+'_d'+sdy+'_h12.pp.dat'
      dum=findfile(ifile)
      if dum(0) eq '' then begin
         z = date2uars(imn,idy,iyr,uday)
         print,'missing ',ifile,uday
      endif
      goto, jump
end
