;
; calculate WACCM geopotential height using Temperature and 
; the hypsometric equation: Z2 = (Rd*Tv/g) * ln(p1/p2) + Z1
;
; WACCM hybrid vertical coordinate gives surface pressure at
; the lowest model altitude.  calculate mean sea level pressure
;
; VLH 11/17/5
;
@stddat
@kgmt
@ckday
@kdate

Rd=287.053  ; J/(kg K)
grav=9.806

dir='/aura3/data/WACCM_data/Datfiles/'
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
lstmn=1 & lstdy=1 & lstyr=90
ledmn=1 & leddy=1 & ledyr=4
lstday=0 & ledday=0
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 57 then lstyr=lstyr+2000
if ledyr lt 57 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1957 then stop,'Year out of range '
if ledyr lt 1957 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      print,imn,idy,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '

      if iyr ge 2000 then iyr1=iyr-2000
      if iyr lt 2000 then iyr1=iyr-1900
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
;
;***Read ECMWF data
      ifile=dir+'wa3_tnv3_'+syr+smn+sdy+'.sav'
      dum=findfile(ifile)
      if dum(0) eq '' then goto,jump
      restore,ifile
;
; variables restored are:
; ALAT            DOUBLE    = Array[46]
; ALON            DOUBLE    = Array[72]
; LEV             DOUBLE    = Array[66]
; CH4GRD          FLOAT     = Array[72, 46, 66]
; H2OGRD          FLOAT     = Array[72, 46, 66]
; NO2GRD          FLOAT     = Array[72, 46, 66]
; NOGRD           FLOAT     = Array[72, 46, 66]
; O3GRD           FLOAT     = Array[72, 46, 66]
; PGRD            FLOAT     = Array[72, 46, 66]
; TGRD            FLOAT     = Array[72, 46, 66]
; UGRD            FLOAT     = Array[72, 46, 66]
; VGRD            FLOAT     = Array[72, 46, 66]
;
      if icount eq 0L then begin 
         icount=1L
         lsfc=n_elements(lev)-1L
         longitude_wa3=alon
         latitude_wa3=alat
         ncw=n_elements(longitude_wa3)
         nrw=n_elements(latitude_wa3)
         nlw=n_elements(lev)
      endif
;
; integrate temperature to get geopotential height
; arrays are top down (sfc=nlw-1)
;
psfc=reform(pgrd(*,*,nlw-1L))
      zgrd=0.*tgrd
      for k=nlw-2L,0,-1L do begin
          for j=0L,nrw-1L do begin
          for i=0L,ncw-1L do begin
              zgrd(i,j,k)=(Rd*tgrd(i,j,k)/grav)*alog(pgrd(i,j,k+1L)/pgrd(i,j,k))+zgrd(i,j,k+1L)
;print,pgrd(i,j,k+1L),pgrd(i,j,k),zgrd(i,j,k)
          endfor
          endfor
print,lev(k),min(zgrd(*,*,k)),max(zgrd(*,*,k))
map_set,0,0,0,/contin,/grid
contour,zgrd(*,*,k),alon,alat,/overplot,nlevels=30
stop
      endfor

;     tsfc_wa3=reform(tgrd(*,*,lsfc))
;     ofile=dir+'tsfc_wa3_'+syr+smn+sdy+'.ASCII'
;     print,'writing '+ofile
;     openw,1,ofile
;     printf,1,nrw
;     printf,1,ncw
;     printf,1,ncw,nrw
;     printf,1,longitude_wa3
;     printf,1,latitude_wa3
;     printf,1,tsfc_wa3
;     close,1
stop
goto, jump
end
