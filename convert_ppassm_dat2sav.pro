@stddat
@kgmt
@ckday
@kdate
@date2uars
@rd_ukmo

month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
setplot='x'
colbw='col'
lstmn=11
lstdy=11
lstyr=7
ledmn=11
leddy=11
ledyr=7
lstday=0
ledday=0
uday=0

; Ask interactive questions- get starting/ending date and p surface
;print, ' '
;print, '      UKMO Version '
;print, ' '
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr

if lstyr ge 91 and lstyr le 99 then lstyr=lstyr+1900
if ledyr ge 91 and ledyr le 99 then ledyr=ledyr+1900
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1991 or lstyr gt 2007 then stop,'Year out of range '
if ledyr lt 1991 or ledyr gt 2007 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

; define viewport location 
nxdim=750
nydim=750
xorig=[0.1,0.5]
yorig=[0.15,0.15]
xlen=0.3
ylen=0.3
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal Termination Condition'

; --- Calculate UARS day from (imn,idy,iyr) information.
      z = date2uars(imn,idy,iyr,uday)
      print,imn,idy,iyr,' = UARS day ',fix(uday)

;***Read UKMO data
      if iyr ge 2000 then iyr1=iyr-2000
      if iyr le 1999 then iyr1=iyr-1900
      file='/aura7/harvey/UKMO_data/Datfiles/ppassm_y'+$
            string(FORMAT='(i2.2,a2,i2.2,a2,i2.2,a11)',$
            iyr1,'_m',imn,'_d',idy,'_h12.pp.dat')
      rd_ukmo,file,iflg,nlg,nlat,nlv,alon,alat,wlon,wlat,p,z3d,t3d,u3d,v3d
      if iflg ne 0 then goto, jump
; 
; write in IDL save format
;
      ofile='/aura7/harvey/UKMO_data/Datfiles/ppassm_y'+$
            string(FORMAT='(i2.2,a2,i2.2,a2,i2.2,a11)',$
            iyr1,'_m',imn,'_d',idy,'_h12.pp.sav')
      save,file=ofile,alon,alat,wlon,wlat,p,z3d,t3d,u3d,v3d

goto,jump
end
