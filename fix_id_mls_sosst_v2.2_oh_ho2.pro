;****************************************************************************************
;
; Fix ID value
;  6/30/2010
;               CU/LASP									*
;****************************************************************************************
@stddat
@kgmt
@ckday
@kdate
loadct,38
mcolor=byte(!p.color)
;
; version
;
sver='v2.2'
;
; enter dates 
;
lstmn=9L & lstdy=1L & lstyr=2004L
ledmn=9L & leddy=12L & ledyr=2009L
lstday=0L & ledday=0L 
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
dir='/aura6/data/MLS_data/Datfiles_SOSST/'
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
      syyyymmdd=sdate
;
; check for save file
;
      dum=findfile(dir+'oh_mls_'+sver+'_'+sdate+'.sav')
      if dum(0) eq '' then goto,jump1
      restore,dir+'oh_mls_'+sver+'_'+sdate+'.sav'
      result=size(mix)
      mprof=result(1)
      sprof=string(format='(i4.4)',1.+findgen(mprof))
      id=syyyymmdd+'.'+sprof
      save,file=dir+'oh_mls_'+sver+'_'+sdate+'.sav',altitude,id,mix,err,mask,comment

jump1:
      dum=findfile(dir+'ho2_mls_'+sver+'_'+sdate+'.sav')
      if dum(0) eq '' then goto,jump
      restore,dir+'ho2_mls_'+sver+'_'+sdate+'.sav'
      result=size(mix)
      mprof=result(1)
      sprof=string(format='(i4.4)',1.+findgen(mprof))
      id=syyyymmdd+'.'+sprof
      save,file=dir+'ho2_mls_'+sver+'_'+sdate+'.sav',altitude,id,mix,err,mask,comment
print,sdate
goto,jump
end
