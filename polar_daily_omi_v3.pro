;****************************************************************************************
; Convert EOS-MLS from he5 to IDL save "SOSST" format.  Interpolate to 0-120 km grid.   *
; Save catalog file each day with date, time, longitude, latitude, fdoy, ltime, lday,   *
; Save "meta" data each day in one file containing all of the original species and      *
; precision data on pressure surfaces as well as status and quality arrays.  Save       *
; interpolated species and temperature, pressure, and atmospheric density in separate   *
; daily files that contain "mix", "error", and "mask" arrays to match SO data format.	*
;											*
; Programed by: V. Lynn Harvey  3/05/07
;
; version 3.3 data 9/21/10
;
; run on MacD88
;
;               CU/LASP									*
;****************************************************************************************
@stddat
@kgmt
@ckday
@kdate
@readl3omi
@aura2date
loadct,39
mcolor=byte(!p.color)
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
device,decompose=0
;
; version
;
sver='v2.2'
sver='v3.3'
;
; restore SOSST altitude grid
;
restore,'/Volumes/atmos/aura6/data/MLS_data/Datfiles_SOSST/o3_mls_v3.3_20040921.sav
;restore,'/aura3/data/SAGE_II_data/Datfiles_SOSST/altitude.sav'
nz=n_elements(altitude)
;
; enter dates to convert MLS pressure data
;
lstmn=9L & lstdy=20L & lstyr=2014L
ledmn=9L & leddy=20L & ledyr=2014L
lstday=0L & ledday=0L 
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
dir='/Volumes/atmos/aura6/data/OMI_data/Datfiles/'
odir='/Volumes/atmos/aura6/data/OMI_data/Datfiles/'
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
;
; look for EOS-OMI data files for today
;
;OMI-Aura_L3-OMDOAO3e_2014m0929_v003-2014m1001t014509.he5
      spawn,'ls '+dir+'OMI-Aura_L3-OMDOAO3e_'+syr+'m'+smn+sdy+'_*.he5',o3files
      result=size(o3files)
;
; this logic will jump day if any one of the above 10 products are missing
;
      if result(0) eq 0L then begin
         print,'OMI data missing on '+sdate
         goto,jump
      endif
      print,'OMI data complete on '+sdate
      print,o3files
;
; read data today.  Original data is in the form of structures
;
      readl3omi,o3files(0),longitude,latitude,o3,o3p
;
; check
;
map_set,0,0,0,/contin,/grid,/noeras
contour,o3,longitude,latitude,c_color=(findgen(20)/21.)*mcolor,nlevels=20,/noeras,/cell_fill,/overplot
;contour,o3p,longitude,latitude,color=mcolor,levels=2.*findgen(20),/overplot,/foll
stop
;
goto,jump
end
