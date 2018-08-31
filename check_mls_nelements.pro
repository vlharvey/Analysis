;
; check that number of elements is the same each day
;
@stddat
@kgmt
@ckday
@kdate

mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
mdir='/aura6/data/MLS_data/Datfiles_SOSST/'
lstmn=1
lstdy=10
lstyr=2005
ledmn=1
leddy=31
ledyr=2005
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting year ',lstyr
;read,' Enter ending year ',ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
minyear=lstyr
maxyear=ledyr
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
;goto,quick

z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
kcount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal Termination Condition '
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      dum=findfile(mdir+'oh_mls_v2.2_'+sdate+'.sav')
      if dum(0) eq '' then goto,skipmls
print,sdate

;bro_mls_v2.2_20050101.sav
;cat_mls_v2.2_20050101.sav
;clo_mls_v2.2_20050101.sav
;co_mls_v2.2_20050101.sav
;dmps_mls_v2.2.meto.20050101.sav
;dmps_mls_v2.2.waccm.20050101.sav
;h2o_mls_v2.2_20050101.sav
;hcl_mls_v2.2_20050101.sav
;hno3_mls_v2.2_20050101.sav
;mark_mls_v2.2.meto.20050101.sav
;n2o_mls_v2.2_20050101.sav
;o3_mls_v2.2_20050101.sav
;raw_isobaric_mls_v2.2_20050101.sav
;raw_mls_v2.2_20050101.sav
;tpd_mls_v2.2_20050101.sav

      restore,mdir+'cat_mls_v2.2_'+sdate+'.sav'
      restore,mdir+'tpd_mls_v2.2_'+sdate+'.sav'
mprof=n_elements(FDOY)
result=size(TEMPERATURE)
if result(1) ne mprof then print,'Temp ',sdate
      restore,mdir+'oh_mls_v2.2_'+sdate+'.sav'
result=size(mix)
if result(1) ne mprof then print,'OH ',sdate
      restore,mdir+'ho2_mls_v2.2_'+sdate+'.sav'
result=size(mix)
if result(1) ne mprof then print,'HO2 ',sdate

skipmls:
      icount=icount+1L
goto,jump
end
