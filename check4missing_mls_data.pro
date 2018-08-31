;****************************************************************************************
; Convert EOS-MLS from he5 to IDL save "SOSST" format.  Interpolate to 0-120 km grid.   *
; Save catalog file each day with date, time, longitude, latitude, fdoy, ltime, lday,   *
; Save "meta" data each day in one file containing all of the original species and      *
; precision data on pressure surfaces as well as status and quality arrays.  Save       *
; interpolated species and temperature, pressure, and atmospheric density in separate   *
; daily files that contain "mix", "error", and "mask" arrays to match SO data format.	*
;											*
; Programed by: V. Lynn Harvey  6/01/06							*
;               CU/LASP									*
;****************************************************************************************
@stddat
@kgmt
@ckday
@kdate
;
; enter dates to convert MLS pressure data
;
lstmn=4L & lstdy=3L & lstyr=2005L
ledmn=12L & leddy=12L & ledyr=2009L	; last day of OH data
lstday=0L & ledday=0L 
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
dir='/aura6/data/MLS_data/Datfiles/'
close,1
openw,1,'check4missing_mls_data.txt'
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
;     spawn,'ls '+dir+'MLS-Aura_L2GP-BrO_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',brofiles
;     spawn,'ls '+dir+'MLS-Aura_L2GP-CO_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',cofiles
;     spawn,'ls '+dir+'MLS-Aura_L2GP-ClO_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',clofiles
      spawn,'ls '+dir+'MLS-Aura_L2GP-GPH_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',gpfiles
;     spawn,'ls '+dir+'MLS-Aura_L2GP-H2O_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',h2ofiles
;     spawn,'ls '+dir+'MLS-Aura_L2GP-HCl_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',hclfiles
;     spawn,'ls '+dir+'MLS-Aura_L2GP-HNO3_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',hno3files
;     spawn,'ls '+dir+'MLS-Aura_L2GP-N2O_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',n2ofiles
;     spawn,'ls '+dir+'MLS-Aura_L2GP-O3_*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',o3files
      spawn,'ls '+dir+'MLS-Aura_L2GP-Temperature*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',tpfiles
      spawn,'ls '+dir+'MLS-Aura_L2GP-OH*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',ohfiles
      spawn,'ls '+dir+'MLS-Aura_L2GP-HO2*'+string(FORMAT='(i4.4,a1,i3.3)',iyr,'d',iday)+'.he5',ho2files
;     result1=size(brofiles)
;     result2=size(cofiles)
;     result3=size(clofiles)
      result4=size(gpfiles)
;     result5=size(h2ofiles)
;     result6=size(hclfiles)
;     result7=size(hno3files)
;     result8=size(n2ofiles)
;     result9=size(o3files)
      result10=size(tpfiles)
      result11=size(ohfiles)
      result12=size(ho2files)
;
; if all 4 are missing then jump
;
      if result4(0) eq 0L and result10(0) eq 0L and result11(0) eq 0L and result12(0) eq 0L then goto,jump
;
; print missing data
;
;     if result1(0) eq 0L then printf,1,'missing BrO on '+sdate,iday
;     if result2(0) eq 0L then printf,1,'missing CO on '+sdate,iday
;     if result3(0) eq 0L then printf,1,'missing ClO on '+sdate,iday
      if result4(0) eq 0L then printf,1,'missing GPH on '+sdate,iday
;     if result5(0) eq 0L then printf,1,'missing H2O on '+sdate,iday
;     if result6(0) eq 0L then printf,1,'missing HCl on '+sdate,iday
;     if result7(0) eq 0L then printf,1,'missing HNO3 on '+sdate,iday
;     if result8(0) eq 0L then printf,1,'missing N2O on '+sdate,iday
;     if result9(0) eq 0L then printf,1,'missing O3 on '+sdate,iday
      if result10(0) eq 0L then printf,1,'missing Tp on '+sdate,iday
      if result11(0) eq 0L then printf,1,'missing OH on '+sdate,iday
      if result12(0) eq 0L then printf,1,'missing HO2 on '+sdate,iday

goto,jump
end
