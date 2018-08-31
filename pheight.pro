;
; latitude-altitude sections of UKMO pressure data
;
@stddat
@kgmt
@ckday
@kdate
@date2uars
@rd_ukmo
@drawvectors

nlg=0l
nlat=0l
nlv=0l
lstmn=0
lstdy=0
lstyr=0
ledmn=0
leddy=0
ledyr=0
lstday=0
ledday=0
uday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
print, ' '
print, '      UKMO Version '
print, ' '
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
      if ndays gt ledday then stop,' Normal termination condition '

;***Read UKMO data
      file='/aura3/data/UKMO_data/Datfiles/ppassm_y'+$
            string(FORMAT='(i2.2,a2,i2.2,a2,i2.2,a11)',$
            iyr+'_m'+imn+'_d'+idy+'_h12.pp.dat')
      print,file
      rd_ukmo,file,iflg,nlg,nlat,nlv,alon,alat,wlon,wlat,p,$
              zp,tp,up,vp
      if iflg ne 0 then goto, jump

      zavg=fltarr(nlv)
      thavg=fltarr(nlv)
      for k=nlv-1,0,-1 do begin
          zresult=moment(zp(*,*,k)/1000.)
          thresult=moment(tp(*,k)*(1000./p(k))^.286)
          zavg(k)=zresult(0)
          thavg(k)=thresult(0)
          if k eq nlv-1 then print,p(k),zresult(0),thresult(0)
          if k lt nlv-1 then print,p(k),zresult(0),thresult(0),$
                                   zavg(k+1)-zavg(k),thavg(k+1)-thavg(k)
      endfor

goto, jump

end
