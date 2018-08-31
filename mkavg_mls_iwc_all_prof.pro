;mkavg_jan_ice_column_mls.pro -- Make avg Jan ice mass column using Mark's 0D formula.
;
; Read MLS profiles and bin instead of using gridded data
;
;Note that Mark's formula gives the ice mass density (e.g., mass/volume). I want
;  the column, so I must integrate in height. 
;The gridded MLS data are on pressure levels, so I need to calculate dz.
;To do this I can convert the geopotential height to geometric height, and do the
;   integration at each point explicitly (i.e., calculate delta-z for each point, since
;   I'll have the geometric height for each point).
;   z =  h * (R_earth) / ((R_earth) - h), z=geometric ht, h=geopotential ht.
;The earth's radius is given by (http://en.wikipedia.org/wiki/Earth_radius):
; R(lat)=sqrt(num/den) where:
;        num = [a^2 cos(lat)]^2 + [b^2 sin(lat)]^2
;	    den = [a cos(lat)]^2 + (b sin(lat))^2
;	    a = 6,378.1370 km    b = 6,356.7523 km 
;
nr=37L
latbin=-90.+5.*findgen(nr)
nc=12L
lonbin=15.+30.*findgen(nc)

mdir='/atmos/aura6/data/MLS_data/Datfiles_SOSST/'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nmon=['01','02','03','04','05','06','07','08','09','10','11','12']
FOR YEAR=2013,2013 DO BEGIN
   yyyy=strcompress(year,/remove_all)
   if year mod 4 eq 0L then mday(1)=29
   if year mod 4 ne 0L then mday(1)=28
   FOR IMON=6,N_elements(mon)-1L DO BEGIN
   smn=nmon(imon)
   icount=0
   FOR IDAY=0,MDAY(IMON)-1 DO BEGIN
      sdate=yyyy+smn+string(format='(i2.2)',iday+1)
;
; read MLS
;
      dum=findfile(mdir+'cat_mls_v3.3_'+sdate+'.sav')
      if dum(0) eq '' then goto,skipmls
      restore,mdir+'cat_mls_v3.3_'+sdate+'.sav'
      restore,mdir+'h2o_mls_v3.3_'+sdate+'.sav'
      restore,mdir+'tpd_mls_v3.3_'+sdate+'.sav'
print,'cat_mls_v3.3_'+sdate+'.sav'
;
; apply mask
;
      index=where(mask eq -99.)
      if index(0) ne -1L then mix(index)=-99.
      mlsh2omix=mix
      index=where(temperature_mask eq -99.)
      if index(0) ne -1L then temperature(index)=-99.
      mlsh2omix=mix
      nlv=n_elements(altitude)
;
; adhere to previous file naming conventions
;
      alt=altitude
      lev=pressure
      nlev=n_elements(altitude)
      mprof=n_elements(fdoy)

      IF ICOUNT EQ 0 THEN BEGIN
         ICE=FLTARR(nc,nr,mday(imon))-99	;WILL HOLD FINAL INTEGRATED ICE COLUMN MASS
         ICEAVG=FLTARR(nc,nr)-99
         icount=1
      ENDIF

      ;CALCULATE M_ICE AT EACH PRESSURE LEVEL USING MARK'S FORMULA
      ;M_ICE = ice mass density = [(P_H2O - P_SAT)*100 / (T * 8.314)] * 18*1.e6
      ; P_H2O IS PARTIAL PRESSURE OF H2O (MIXING RATIO * TOTAL PRESSURE), hPa
      ; P_SAT IS SATURATION VAPOR PRESSURE (SEE BELOW; POSSIBLY FROM RAPP & THOMAS, 2006)
      ; 100 IS TO CONVERT FROM hPa TO Pa (1 hPa = 100 Pa)
      ; T IS TEMPERATURE IN K 
      ; 8.314 IS THE GAS CONSTANT (m^3 Pa K^-1 mol^-1) 
      ;    or equivalently (J K^-1 mol^-1) since 1 Pa m^3 = 1 J.
      ;    Note that 1 Pa = 1 kg m^-1 s^-2 and 1J = 1 km m^2 s^-2
      ;    So 1 Pa m^3 = 1 kg m^2 s^-2 = 1J
      ; 18 is molecular weight of water (g/mol)
      ; 1.E6 IS conversion for g to microg
      ; So units of M_ice = ug/m^3
      ; CIPS gives IWC in ug/m^2, so we have to integrate z in terms of meters.
   
      ;P_SAT is given by Rapp and Thomas, 2006 as:
      ;  0.01*exp(9.550426-(5723.265/T)+3.53068*ln(T)-0.00728332*T)
      ;  The 0.01 converts from Pa to hPa.
      
      T=temperature		;MLS_T_GRID
      H2O=mlsh2omix		;MLS_H2O_GRID
      
      ;SATURATION VAPOR PRESSURE:
      PSAT=0.01*EXP(9.550426-(5723.265/T)+3.53068*ALOG(T)-0.00728332*T)
      ;H2O PARTIAL PRESSURE:
      PP=FLTARR(mprof,NLEV)
      FOR I=0,NLEV-1 DO BEGIN
        h2olev=reform(h2o(*,i))
        good=where(h2olev ne -99.)
        if good(0) ne -1L then PP(good,I)=H2O(good,I)*LEV(good,I)
      ENDFOR
      
      MICE=1.E6*18.*100*(PP-PSAT)/(T*8.314)
for k=0L,n_elements(altitude)-1L do print,lev(1001,k),t(1001,k),h2o(1001,k),pp(1001,k),psat(1001,k),mice(1001,k)
stop
      ;ONLY INTEGRATE OVER A SMALL RANGE SINCE SOME LOW ALTITUDES ALSO HAVE
      ;  POSITIVE ICE AND MLS DATA ONLY VALID BELOW 90 KM OR SO.
      ;MUST MULTIPLY BY EACH DZ LAYER SEPARATELY.
      BAD=WHERE(MICE LT 0 OR FINITE(MICE) EQ 0)
      MICE(BAD)=0

for k=0L,n_elements(altitude)-1L do print,lev(1001,k),t(1001,k),h2o(1001,k),pp(1001,k),psat(1001,k),mice(1001,k)

stop
      FOR J=0L,NR-1L DO BEGIN
          alatm1=latbin(j)-((latbin(1)-latbin(0))/2.)
          alatp1=latbin(j)+((latbin(1)-latbin(0))/2.)
          good=where(latitude ge alatm1 and latitude lt alatp1)
          if good(0) ne -1L then begin
             lons=longitude(good)
             mice0=mice(good,*)
             FOR I=0L,NC-1L DO BEGIN
                 alonm1=lonbin(i)-((lonbin(1)-lonbin(0))/2.)
                 alonp1=lonbin(i)+((lonbin(1)-lonbin(0))/2.)
                 good0=where(lons ge alonm1 and lons lt alonp1,nn)
                 if good0(0) ne -1L then begin
                    mice1=mice0(good0,*)
                    FOR IPROF=0L,NN-1L DO BEGIN
                        SUM=0
                        FOR K=0,NLEV-2 DO BEGIN
                           IF ALT(K) GT 70 AND ALT(K) LT 90 THEN BEGIN
                              ALTHI=ALT(K)+(ALT(K+1)-ALT(K))/2.0
                              ALTLO=ALT(K)-(ALT(K+1)-ALT(K))/2.0
                              DZ=(ALTHI-ALTLO)*1000.	;INTEGRATE IN METERS, NOT KM
                              SUM=SUM+MICE1(iprof,K)*DZ
                           ENDIF
                        ENDFOR
                        ICE(I,J,IDAY)=SUM
;if sum gt 0. then stop
                    ENDFOR
                 endif
             ENDFOR
          endif
      ENDFOR
;
;   if iday eq 10 then stop	;check to make sure the sum is correct
;
skipmls:
   ENDFOR	; end loop over days
   
   ;AVERAGE THE ARRAY
   FOR I=0,NC-1 DO BEGIN
      FOR J=0,NR-1 DO BEGIN
         GOOD=WHERE(ICE(I,J,*) GT 0,NGOOD)
         IF NGOOD GT 2 THEN ICEAVG(I,J)=MEDIAN(ICE(I,J,GOOD))
      ENDFOR
   ENDFOR
   FILE='avg_mls_iwc_'+mon(imon)+yyyy+'.sav'
   comment='ICE IS IWC IN MICROGRAMS PER SQUARE METER''
   save,lonbin,latbin,ice,iceavg,comment,file=file
ENDFOR	; loop over months
ENDFOR	; loop over years
end
