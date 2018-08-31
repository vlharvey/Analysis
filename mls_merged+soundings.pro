;****************************************************************************************
;  Program: mls_merged+soundings.pro							*
;                                                                                       *
;  Input data:          MLS data structures              				*
;  Input files:         MLS-Aura_L2GP_YYYYMMDD.sav
;  Output data:         MLS merged isentropic data and soundings			*
;											*
; Merged Isentropic data OUTPUT:                                                        *
;       => number of occultations                                                       *
;       => time, latitude, longitude, theta, sat longitude, sat latitude,               *
;               pressure on theta, height of theta (km),                                *
;               pressure of tropopause, height of tropopause (km),                      *
;               potential temperature of tropopause, cloud flag, mode                   *
;       => HNO3, NO2, O3, H2O								*
;       => HNO3 error, NO2 error, O3 error, H2O error					*
;                                                                                       *
; Sounding OUTPUT:                                                                      *
;       => number of occultations                                                       *
;       => time, latitude, longitude, sat longitude, sat latitude,                      *
;               pressure of tropopause, height of tropopause (km),                      *
;               potential temperature of tropopause, sunrise/sunset mode                *
;       => number of levels                                                             *
;       => vertical profiles of either ozone or extinction, then pressure,              *
;       => potential temperature, altitude, cloud flag, and error                       *
;                                                                                       *
;  Programed by: V. Lynn Harvey  12/2005						*
;											*
; MLS structures
;
; CO              STRUCT    = -> <Anonymous> Array[1]
;    SWATHNAME       STRING    'CO'
;    NTIMES          LONG              3493
;    NLEVELS         LONG                37
;    NFREQS          LONG                 0
;    PRESSURE        FLOAT     Array[37]
;    FREQUENCY       DOUBLE    Array[1]
;    LATITUDE        FLOAT     Array[3493]
;    LONGITUDE       FLOAT     Array[3493]
;    TIME            DOUBLE    Array[3493]
;    LOCALSOLARTIME  FLOAT     Array[3493]
;    SOLARZENITHANGLE FLOAT    Array[3493]
;    LINEOFSIGHTANGLE FLOAT    Array[3493]
;    ORBITGEODETICANGLE FLOAT  Array[3493]
;    CHUNKNUMBER     LONG      Array[3493]
;    L2GPVALUE       FLOAT     Array[37, 3493]
;    L2GPPRECISION   FLOAT     Array[37, 3493]
;    STATUS          LONG      Array[3493]
;    QUALITY         FLOAT     Array[3493]          
; GP              STRUCT    = -> <Anonymous> Array[1]
; H2O             STRUCT    = -> <Anonymous> Array[1]
; HCL             STRUCT    = -> <Anonymous> Array[1]
; HNO3            STRUCT    = -> <Anonymous> Array[1]
; O3              STRUCT    = -> <Anonymous> Array[1]
; TP              STRUCT    = -> <Anonymous> Array[1]
; YYYYMMDD        LONG      =     20050529
;                                                                                       *
;****************************************************************************************
@stddat
@kgmt
@ckday
@kdate
@interp_mls
@tropopause

;thlev=[330.,340.,350.,360.,370.,380.,390.,400.,425.,450.,475.,500.,525.,$
;       550.,600.,700.,800.,900.,1000.,1200.,1400.,1600.,1800.,2000.]
thlev=[400.,450.,500.,550.,600.,700.,800.,900.,1000.]

ntheta=n_elements(thlev)
month=['jan_','feb_','mar_','apr_','may_','jun_',$
       'jul_','aug_','sep_','oct_','nov_','dec_']
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
odir='/aura6/data/MLS_data/Merged_data/'
sdir='/aura6/data/MLS_data/Sound_data/'
ddir='/aura6/data/MLS_data/Datfiles/'
lstmn=10 & lstdy=19 & lstyr=4 & lstday=0
ledmn=10 & leddy=19 & ledyr=4 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
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
;
; test for end condition
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' normal termination condition '
;
; read MLS data today
;
      norbit=0L & morbit=0L
      ifile=ddir+'MLS-Aura_L2GP_'+syear+smon+sday+'.sav'
      dum=findfile(ifile)
      if dum(0) eq '' then goto,no_data
      restore,ifile
      press=o3.PRESSURE				; PRESSURE        FLOAT     Array[37]
      mlev=n_elements(press)
      mtime=o3.TIME				; TIME            DOUBLE    [3494]
      mlat=o3.LATITUDE
      mlon=o3.LONGITUDE
      norbit=n_elements(mlat)
      temp_sound=transpose(tp.L2GPVALUE)	; TEMPERATURE     FLOAT     Array[37, 3494]
      o3_sound=transpose(o3.L2GPVALUE)		; O3              FLOAT     Array[37, 3494]
      o3precision=transpose(o3.L2GPPRECISION)
      o3status=transpose(o3.STATUS)
      o3quality=transpose(o3.QUALITY)
      eo3_sound=o3precision
;
; use precision, status, and quality arrays to zero out bad ozone data
;
      o3bad=where(o3precision lt 0.)
      if o3bad(0) ne -1L then o3_sound(o3bad)=-99.
      o3bad=where(o3status mod 2 ne 0L)         ; o3status=0 is good, all odd values are bad
      if o3bad(0) ne -1L then o3_sound(*,o3bad)=-99.
      o3bad=where(o3quality lt 0.1)         ; do not use if quality < 0.1
      if o3bad(0) ne -1L then o3_sound(*,o3bad)=-99.
;
; time is elapsed seconds since midnight 1 Jan 1993 to hours today
;
      tmls=fltarr(ntheta,norbit)
      istime=1993010100L
      ehr=mtime/60./60.       ; convert mtime from seconds to hours
      hh2=0.d*mtime
      for n=0L,norbit-1L do begin
          yy1=istime/1000000
          if yy1 mod 4 eq 0 then mno(1)=29L
          if yy1 mod 4 ne 0 then mno(1)=28L
          mm1=istime/10000L-yy1*100L
          dd1=istime/100L-yy1*10000L-mm1*100L
          dd2=dd1+long(ehr(n))/24L
          hh1=istime-yy1*1000000L-mm1*10000L-dd1*100L
          yy2=yy1 & mm2=mm1
          while dd2 gt mno(mm2-1) do begin
                dd2=dd2-mno(mm2-1)
                mm2=mm2+1L
                if mm2 gt 12L then begin
                   mm2=mm2-12L
                   yy2=yy2+1L
                   if yy2 mod 4 eq 0 then mno(1)=29
                   if yy2 mod 4 ne 0 then mno(1)=28
                endif
          endwhile
          hh2(n)=ehr(n) mod 24
          if hh2(n) ge 24. then begin
             hh2(n)=hh2(n)-24.
             dd2=dd2+1L
             if dd2 gt mno(mm2-1L) then begin
                dd2=dd2-mno(mm2-1L)
                mm2=mm2+1L
                if mm2 gt 12L then begin
                   mm2=mm2-12L
                   yy2=yy2+1L
                endif
             endif
          endif
;         print,mtime(n),hh2(n)
      endfor
;
; merged isentropic arrays
;
      tmls=fltarr(ntheta,norbit)
      for k=0L,ntheta-1L do tmls(k,*)=hh2
      xmls=-999.+fltarr(ntheta,norbit)
      for k=0L,ntheta-1L do xmls(k,*)=mlon
      ymls=-999.+fltarr(ntheta,norbit)
      for k=0L,ntheta-1L do ymls(k,*)=mlat
      xsatmls=-999.+fltarr(ntheta,norbit)
      ysatmls=-999.+fltarr(ntheta,norbit)
      mmls=-999L+lonarr(ntheta,norbit)
      pmls=-999.+fltarr(ntheta,norbit)
      zmls=-999.+fltarr(ntheta,norbit)
      thmls=-999.+fltarr(ntheta,norbit)
      for i=0,norbit-1 do thmls(*,i)=thlev
      ptrmls=-999.+fltarr(ntheta,norbit)
      ztrmls=-999.+fltarr(ntheta,norbit)
      thtrmls=-999.+fltarr(ntheta,norbit)
      clmls=-999.+fltarr(ntheta,norbit)
      o3mls=-999.+fltarr(ntheta,norbit)
      eo3mls=-999.+fltarr(ntheta,norbit)
;
; todays soundings
;
      t_sound=-999.+fltarr(norbit,mlev)
      for k=0L,mlev-1L do t_sound(*,k)=hh2
      z_sound=-999.+fltarr(norbit,mlev)
      press_sound=-999.+fltarr(norbit,mlev)
      for i=0L,norbit-1L do press_sound(i,*)=press
      theta_sound=temp_sound
      index=where(temp_sound gt 0. and press_sound gt 0.)
      if index(0) ne -1 then $
         theta_sound(index)=temp_sound(index)*((1000./press_sound(index))^.286)
      cloud_sound=-999.+fltarr(norbit,mlev)

      for iorbit=0,norbit-1 do begin                  ; loop over daily profiles
          for nth=0,ntheta-1 do begin                 ; loop over theta levels
;
; tropopause routine expects profiles top down
;
              t_prof=reform(temp_sound(iorbit,*))
              p_prof=reform(press_sound(iorbit,*))
              z_prof=reform(z_sound(iorbit,*))
              th_prof=reform(theta_sound(iorbit,*))
              index=sort(p_prof)
              t_prof=t_prof(index)
              p_prof=p_prof(index)
              z_prof=z_prof(index)
              th_prof=th_prof(index)
;             tropopause,t_prof,p_prof,z_prof,th_prof,mlev,p_trop,z_trop,th_trop
;             ztrmls(nth,iorbit)=z_trop
;             ptrmls(nth,iorbit)=p_trop
;             thtrmls(nth,iorbit)=th_trop
;
; interpolate to theta surfaces
;
              p_prof=reform(press_sound(iorbit,*))
              th_prof=reform(theta_sound(iorbit,*))
; PRESSURE
              interp_mls,1,mlev,p_prof,th_prof,aer_theta,thlev(nth)
              pmls(nth,iorbit)=aer_theta
; O3
              interp_mls,1,mlev,reform(o3_sound(iorbit,*)),th_prof,aer_theta,thlev(nth)
              o3mls(nth,iorbit)=aer_theta
              interp_mls,1,mlev,reform(eo3_sound(iorbit,*)),th_prof,aer_theta,thlev(nth)
              eo3mls(nth,iorbit)=aer_theta
          endfor
      endfor
      tsave=reform(tmls(0,*))
      xsave=reform(xmls(0,*))
      ysave=reform(ymls(0,*))
      xsatsave=reform(xsatmls(0,*))
      ysatsave=reform(ysatmls(0,*))
      msave=reform(mmls(0,*))
      ptrsave=reform(ptrmls(0,*))
      ztrsave=reform(ztrmls(0,*))
      thtrsave=reform(thtrmls(0,*))
;
; eliminate bad data
;
      index=where(tmls ge 0. and tmls le 24.,morbit)
      if index(0) ne -1 then begin
         tmls=tmls(index)
         xmls=xmls(index)
         ymls=ymls(index)
         thmls=thmls(index)
         xsatmls=xsatmls(index)
         ysatmls=ysatmls(index)
         pmls=pmls(index)
         zmls=zmls(index)
         ptrmls=ptrmls(index)
         ztrmls=ztrmls(index)
         thtrmls=thtrmls(index)
         clmls=clmls(index)
         mmls=mmls(index)
         o3mls=o3mls(index)
         eo3mls=eo3mls(index)
      endif
;
; sort into chronological order
;
      index=sort(tmls)
      tmls=tmls(index)
      xmls=xmls(index)
      ymls=ymls(index)
      pmls=pmls(index)
      zmls=zmls(index)
      thmls=thmls(index)
      xsatmls=xsatmls(index)
      ysatmls=ysatmls(index)
      ptrmls=ptrmls(index)
      ztrmls=ztrmls(index)
      thtrmls=thtrmls(index)
      clmls=clmls(index)
      mmls=mmls(index)
      o3mls=o3mls(index)
      eo3mls=eo3mls(index)
      close,4
      openw,4,odir+'mls_'+month(imn-1)+sday+'_'+syear+'.merged'
      printf,4,yymmdd
      printf,4,morbit
      for i=0L,morbit-1L do begin
          t=tmls(i)
          x=xmls(i)
          y=ymls(i)
          th=thmls(i)
          xs=xsatmls(i)
          ys=ysatmls(i)
          pth=pmls(i)
          zth=zmls(i)
          ptr=ptrmls(i)
          ztr=ztrmls(i)
          thtr=thtrmls(i)
          cl=clmls(i)
          m=mmls(i)
          o3=o3mls(i)
          eo3=eo3mls(i)
          printf,4,t,y,x,th,o3,eo3	;xs,ys,pth,zth,ptr,ztr,thtr,cl,m
      endfor
      close,4
;
; sort into reverse chronological order
;
      index=reverse(sort(tmls))
      tmls=tmls(index)
      xmls=xmls(index)
      ymls=ymls(index)
      pmls=pmls(index)
      zmls=zmls(index)
      thmls=thmls(index)
      xsatmls=xsatmls(index)
      ysatmls=ysatmls(index)
      ptrmls=ptrmls(index)
      ztrmls=ztrmls(index)
      thtrmls=thtrmls(index)
      clmls=clmls(index)
      mmls=mmls(index)
      o3mls=o3mls(index)
      eo3mls=eo3mls(index)
      close,4
      openw,4,odir+'mls_'+month(imn-1)+sday+'_'+syear+'.merged.back'
      printf,4,yymmdd
      printf,4,morbit
      for i=0L,morbit-1L do begin
          t=tmls(i)
          x=xmls(i)
          y=ymls(i)
          th=thmls(i)
          xs=xsatmls(i)
          ys=ysatmls(i)
          pth=pmls(i)
          zth=zmls(i)
          ptr=ptrmls(i)
          ztr=ztrmls(i)
          thtr=thtrmls(i)
          cl=clmls(i)
          m=mmls(i)
          o3=o3mls(i)
          eo3=eo3mls(i)
          printf,4,t,y,x,th,o3,eo3      ;xs,ys,pth,zth,ptr,ztr,thtr,cl,m
      endfor
      close,4
;
; write ozone soundings
;
;     o3file='mls_'+month(imn-1)+sday+'_'+syear+'_o3.sound'
;     close,21
;     openw,21,sdir+o3file
;     printf,21,norbit
;     for i=0,norbit-1 do begin
;         t=tsave(i)
;         x=xsave(i)
;         y=ysave(i)
;         ys=ysatsave(i)
;         xs=xsatsave(i)
;         p_trop=ptrsave(i)
;         z_trop=ztrsave(i)
;         th_trop=thtrsave(i)
;         m=msave(i)
;         printf,21,t,y,x,xs,ys,p_trop,z_trop,th_trop,m
;         printf,21,mlev
;         dum=reform(o3_sound(i,*))
;         printf,21,dum
;         p_sound_o3=reform(press_sound(i,*))
;         th_sound_o3=reform(theta_sound(i,*))
;         cl_sound_o3=-999.+0.*reform(press_sound(i,*))
;         z_sound_o3=reform(z_sound(i,*))
;         printf,21,p_sound_o3
;         printf,21,th_sound_o3
;         printf,21,z_sound_o3
;         printf,21,cl_sound_o3
;         dum=reform(eo3_sound(i,*))
;         printf,21,dum
;     endfor		; end of orbit loop
;     close,21
      goto,end_day_data
;
; if no data
;
     no_data:
     close,19,20,21
     ofile1='mls_'+month(imn-1)+sday+'_'+syear+'.merged'
     openw,19,odir+ofile1
     printf,19,yymmdd
     printf,19,morbit
     ofile2='mls_'+month(imn-1)+sday+'_'+syear+'.merged.back'
     openw,20,odir+ofile2
     printf,20,yymmdd
     printf,20,morbit
     close,19,20

;    o3file='mls_'+month(imn-1)+sday+'_'+syear+'_o3.sound'
;    openw,21,sdir+o3file
;    printf,21,norbit
;    close,21
     end_day_data:
     print,syear+smon+sday+' ',norbit,morbit

goto,jump
END
