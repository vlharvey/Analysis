;****************************************************************************************
;  v2.2 save merged files and soundings based on "SOSST style" input files
;  Program: mls_merged+soundings.pro							*
;                                                                                       *
;  Input data:          MLS data structures              				*
;  Input files:         MLS-Aura_L2GP_YYYYMMDD.sav
;  Output data:         MLS merged isentropic data and soundings			*
;											*
; Merged Isentropic data OUTPUT:                                                        *
;       => number of profiles
;       => time, latitude, longitude, theta
;       => CO, N2O, O3, H2O								*
;       => CO, N2O, O3, H2O errors
;                                                                                       *
;  Programed by: V. Lynn Harvey  06/2008						*
;											*
;****************************************************************************************
@stddat
@kgmt
@ckday
@kdate
@interp_mls

sver='v2.2'

thlev=[600.,700.,800.,900.,1000.,1200.,1400.,1600.,1800.,2000.,$
       2200.,2400.,2600.,2800.,3000.,3200.,3400.,3600.,3800.,4000.]
ntheta=n_elements(thlev)
month=['jan_','feb_','mar_','apr_','may_','jun_',$
       'jul_','aug_','sep_','oct_','nov_','dec_']
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
odir='/aura6/data/MLS_data/Merged_data/'
sdir='/aura6/data/MLS_data/Sound_data/'
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
lstmn=10 & lstdy=1 & lstyr=4 & lstday=0
ledmn=4 & leddy=1 & ledyr=8 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      sday=string(FORMAT='(I2.2)',idy)
      smon=string(FORMAT='(I2.2)',imn)
      syear=string(FORMAT='(I4)',iyr)
      sjday=string(FORMAT='(I3.3)',iday)
      yymmdd=long(syear+smon+sday)
      sdate=syear+smon+sday
;
; test for end condition
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' normal termination condition '
;
; read MLS data today
;
      mprof=0L & morbit=0L
;
; read MLS data
;
      dum=findfile(dirm+'cat_mls_'+sver+'_'+sdate+'.sav')
      if dum(0) eq '' then goto,no_data
      restore,dirm+'cat_mls_'+sver+'_'+sdate+'.sav'             ; altitude
      restore,dirm+'tpd_mls_'+sver+'_'+sdate+'.sav'             ; temperature, pressure
      restore,dirm+'co_mls_'+sver+'_'+sdate+'.sav'              ; mix
      nz=n_elements(altitude)
      nthlev=n_elements(thlev)
      mprof=n_elements(longitude)
      mlev=n_elements(altitude)
      muttime=time
      mlat=latitude
      mlon=longitude
      bad=where(mask eq -99.)
      if bad(0) ne -1L then mix(bad)=-99.
      good=where(mix ne -99.)
      if good(0) eq -1L then goto,no_data
      mco=mix
      mcoe=err
      mtemp=temperature
      mpress=pressure
;
; eliminate bad uttimes 
;
      index=where(muttime gt 0.,mprof)
      if index(0) eq -1L then goto,jump
      muttime=reform(muttime(index))
      mlat=reform(mlat(index))
      mlon=reform(mlon(index))
      mtemp=reform(mtemp(index,*))
      mpress=reform(mpress(index,*))
      mco=reform(mco(index,*))
      mcoe=reform(mcoe(index,*))
      mtheta=mtemp*(1000./mpress)^0.286
      index=where(mtemp lt 0.)
      if index(0) ne -1L then mtheta(index)=-99.
;
; merged isentropic arrays
;
      tmls=fltarr(ntheta,mprof)
      for k=0L,ntheta-1L do tmls(k,*)=muttime
      xmls=-999.+fltarr(ntheta,mprof)
      for k=0L,ntheta-1L do xmls(k,*)=mlon
      ymls=-999.+fltarr(ntheta,mprof)
      for k=0L,ntheta-1L do ymls(k,*)=mlat
      thmls=-999.+fltarr(ntheta,mprof)
      for i=0,mprof-1 do thmls(*,i)=thlev
      comls=-999.+fltarr(ntheta,mprof)
      ecomls=-999.+fltarr(ntheta,mprof)
;
; interpolate CO to theta surfaces
;
      for iorbit=0,mprof-1 do begin                  ; loop over daily profiles
          for nth=0,ntheta-1 do begin                 ; loop over theta levels
              th_prof=reform(mtheta(iorbit,*))
              interp_mls,1,mlev,reform(mco(iorbit,*)),th_prof,aer_theta,thlev(nth)
              comls(nth,iorbit)=aer_theta
              interp_mls,1,mlev,reform(mcoe(iorbit,*)),th_prof,aer_theta,thlev(nth)
              ecomls(nth,iorbit)=aer_theta
          endfor
      endfor
;
; eliminate bad data
;
      index=where(tmls ge 0. and tmls le 24.,morbit)
      if index(0) ne -1 then begin
         tmls=tmls(index)
         xmls=xmls(index)
         ymls=ymls(index)
         thmls=thmls(index)
         comls=comls(index)
         ecomls=ecomls(index)
      endif
;
; sort into chronological order
;
      index=sort(tmls)
      tmls=tmls(index)
      xmls=xmls(index)
      ymls=ymls(index)
      thmls=thmls(index)
      comls=comls(index)
      ecomls=ecomls(index)
      close,4
      openw,4,odir+'mls_'+month(imn-1)+sday+'_'+syear+'_'+sver+'.merged'
      printf,4,yymmdd
      printf,4,morbit
      for i=0L,morbit-1L do begin
          t=tmls(i)
          x=xmls(i)
          y=ymls(i)
          th=thmls(i)
          co=comls(i)
          eco=ecomls(i)
          printf,4,t,y,x,th,co,eco	;xs,ys,pth,zth,ptr,ztr,thtr,cl,m
      endfor
      close,4
;
; sort into reverse chronological order
;
      index=reverse(sort(tmls))
      tmls=tmls(index)
      xmls=xmls(index)
      ymls=ymls(index)
      thmls=thmls(index)
      comls=comls(index)
      ecomls=ecomls(index)
      close,4
      openw,4,odir+'mls_'+month(imn-1)+sday+'_'+syear+'_'+sver+'.merged.back'
      printf,4,yymmdd
      printf,4,morbit
      for i=0L,morbit-1L do begin
          t=tmls(i)
          x=xmls(i)
          y=ymls(i)
          th=thmls(i)
          co=comls(i)
          eco=ecomls(i)
          printf,4,t,y,x,th,co,eco      ;xs,ys,pth,zth,ptr,ztr,thtr,cl,m
      endfor
      close,4
      goto,end_day_data
;
; if no data
;
     no_data:
     close,19,20,21
     ofile1='mls_'+month(imn-1)+sday+'_'+syear+'_'+sver+'.merged'
     openw,19,odir+ofile1
     printf,19,yymmdd
     printf,19,morbit
     ofile2='mls_'+month(imn-1)+sday+'_'+syear+'_'+sver+'.merged.back'
     openw,20,odir+ofile2
     printf,20,yymmdd
     printf,20,morbit
     close,19,20

     end_day_data:
     print,syear+smon+sday+' ',mprof,morbit
goto,jump
END
