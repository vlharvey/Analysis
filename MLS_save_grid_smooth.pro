@/Volumes/MacD68-1/france/idl_files/stddat			; Determines the number of days since Jan 1, 1956
@/Volumes/MacD68-1/france/idl_files/kgmt			; This function computes the Julian day number (GMT) from the
								;    day, month, and year information.
@/Volumes/MacD68-1/france/idl_files/ckday			; This routine changes the Julian day from 365(6 if leap yr)
								;    to 1 and increases the year, if necessary.
@/Volumes/MacD68-1/france/idl_files/kdate			; gives back kmn,kdy information from the Julian day #.
@/Volumes/MacD68-1/france/idl_files/rd_ukmo_nc3			; reads the data from nc3 files
@/Volumes/MacD68-1/france/idl_files/date2uars			; This code returns the UARS day given (jday,year) information.
@/Volumes/MacD68-1/france/idl_files/plotPosition		; defines positions for n number of plots
@/Volumes/MacD68-1/france/idl_files/rd_GEOS5_nc3


;-----------------------------------------------------
;The following determines the date range

lstdy = 0L
lstmn = 0L
lstyr = 0L

read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
days = 0L
read,' Enter number of days  ', days
; set endday equal to startday so for each plot, only one day is plotted, for each elements of 'days'
ledmn = lstmn
leddy = lstdy
ledyr = lstyr
n_dayAvg = 1L    ; 1 day running average



mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
;if ledyr lt 1991 then stop,'Year out of range '
stddat,lstmn,lstdy,lstyr,lstday
stddat,ledmn,leddy,ledyr,ledday
if ledday lt lstday then stop,' Wrong dates! '
iyr = lstyr
idy = lstdy
imn = lstmn
mn1 = ledmn
dy1 = leddy
yr1 = ledyr

kgmt,imn,idy,iyr,iday
startday = julday(lstmn, lstdy, lstyr)
endday = julday(ledmn, leddy, ledyr)

; -----------------------------
; loop over each day
nth_day = 10
for day = 0L, days - 1L do begin

if day gt 0L then begin
iday = nday

  startday = startday + 1L
  endday = endday + 1L
  caldat, startday, lstmn, lstdy, lstyr
  lstyr = lstyr - 2000L
  ledmn = lstmn
  leddy = lstdy
  ledyr = lstyr
  print, lstyr, ledmn, leddy
  nday  = nday + 1L
  mon=['jan_','feb_','mar_','apr_','may_','jun_',$
       'jul_','aug_','sep_','oct_','nov_','dec_']
  if lstyr lt 91 then lstyr=lstyr+2000
  if ledyr lt 91 then ledyr=ledyr+2000
  if lstyr lt 1900 then lstyr=lstyr+1900
  if ledyr lt 1900 then ledyr=ledyr+1900
  if lstyr lt 1991 then stop,'Year out of range '
  ;if ledyr lt 1991 then stop,'Year out of range '
  stddat,lstmn,lstdy,lstyr,lstday
  stddat,ledmn,leddy,ledyr,ledday
  if ledday lt lstday then stop,' Wrong dates! '
  iyr = lstyr
  idy = lstdy
  imn = lstmn
  kgmt,imn,idy,iyr,iday
endif

nday = iday
;-------------------------------------------------------------------------

dir='/Volumes/MacD68-1/france/MLS_data/Datfiles/'


; define variables
startday      = julday(lstmn,lstdy,2000 + lstyr)
endday        = julday(ledmn,leddy,2000 + ledyr)



  ;----------------------------------------------
  ; determine the date
  ckday,iday,iyr
  kdate,float(iday),iyr,imn,idy
  stddat, imn,idy,iyr,ndays
  if iyr lt 2000 then iyr1=iyr-1900
  if iyr ge 2000 then iyr1=iyr-2000
  syr   = string(FORMAT='(I2.2)',iyr1)
  smn   = string(FORMAT='(I2.2)',imn)
  sdy   = string(FORMAT='(I2.2)',idy)
  doy = string(Format='(I03)',iday)
  ifile = string(syr+smn+sdy)
  ;----------------------------------------------


nc = 0L
rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,pv3,p3,msf3,u3,v3,q3,mark3,vp3,sf3,iflag
if nc eq 0L then continue




  WACCMtemp=!values.f_nan*p3
  gp2=!values.f_nan*p3
    WACCMGpHt2 = WACCMtemp*!values.f_nan
ggrd=fltarr(nc,nr,nth)   ; 3-d geopotential height
zgrd=0.*ggrd

k = 8.314
g=9.81
M = .02896
rtd=double(180./!pi)
dtr=1./rtd
ks=1.931853d-3
ecc=0.081819
gamma45=9.80




for jj=0L,nTH-1L do begin
 	; determine temperature using Poisson's relation
	WACCMtemp[*,*,jj] = reform(th[jj])*( (p3[*,*,jj]/1000.D)^(.286) )
endfor




        ; if file exists, then determine daily mean T and P
      MLStempave = temperature
      MLSpressave = p_grid

mlslat = lat
mlslon = lon

      
n_lat = n_elements(lat)
n_lon = n_elements(lon)

n_levels    = n_elements(altitude)
n_theta     = n_elements(MLSpotentialT)
dlon        = 360./(n_lon - 1L)
dlat        = 180./(n_lat - 1L)
tempave     = fltarr(n_dayAvg, n_lon, n_lat, n_levels) - 99.
pressAve    = fltarr(n_dayAvg, n_lon, n_lat, n_levels) - 99.

MLSgphtave = fltarr(n_lon, n_lat, n_levels) * !values.f_nan
MLStemp     = fltarr(n_lon, n_lat, n_theta) * !values.f_nan	; averaged temperatures over n_dayAvg and longitude, fit to lat grid
MLSpress    = fltarr(n_lon, n_lat, n_theta) * !values.f_nan
MLSalt      = fltarr(n_lon, n_lat, n_theta)			; interpolated altitude to potential temperature grid
N2          = fltarr(n_lon, n_lat, n_levels)* !values.f_nan	; Static stability parameter
MLStheta       = fltarr(n_lon, n_lat, n_levels) *!values.f_nan
MLSGPHT     = fltarr(n_lon, n_lat, n_levels)*!values.f_nan
MLSstratGPheight = fltarr(10L, n_lon, n_lat)*!values.f_nan
MLSstratTheta = fltarr(10L, n_lon, n_lat)*!values.f_nan
MLSstratpress = fltarr(10L, n_lon, n_lat)*!values.f_nan
tempstrat   = fltarr(10L, n_lon, n_lat)*!values.f_nan
MLSzstrat   = fltarr(10L, n_lon, n_lat)*!values.f_nan
MLSn2   = fltarr(10L, n_lon, n_lat)*!values.f_nan
GeometricAltitude = fltarr(n_lon,n_lat,n_levels)*!values.f_nan
MLSzstratconvert= fltarr(10L, n_lon, n_lat)*!values.f_nan
MLStropGPheight = fltarr(10L, n_lon, n_lat)*!values.f_nan
MLStroptheta = fltarr(10L, n_lon, n_lat)*!values.f_nan
MLStroppress = fltarr(10L, n_lon, n_lat)*!values.f_nan
temptrop   = fltarr(10L, n_lon, n_lat)*!values.f_nan
MLSztrop   = fltarr(10L, n_lon, n_lat)*!values.f_nan
polystratheight = fltarr(n_lon, n_lat)*!values.f_nan
polystrattemp = fltarr(n_lon, n_lat)*!values.f_nan


MLSmesoGPheight = fltarr(10L, n_lon, n_lat)*!values.f_nan
MLSmesotheta = fltarr(10L, n_lon, n_lat)*!values.f_nan
MLSmesopress = fltarr(10L, n_lon, n_lat)*!values.f_nan
tempmeso   = fltarr(10L, n_lon, n_lat)*!values.f_nan
MLSzmeso   = fltarr(10L, n_lon, n_lat)*!values.f_nan
Alt         = fltarr(10L, n_lon, n_lat)*!values.f_nan








 
 
;----------------------------------------------


    for jj = 0L, n_lat - 1L do begin
    for kk = 0L, n_lon - 1L do begin
	mlstempave[kk,jj,*] = smooth(mlstempave[kk,jj,*],1L,/nan)
      x = where(MLStempAve[kk,jj,*] gt -99. and MLSpressave[kk,jj,*] gt -99., nx)
      if nx gt 0L then begin
        MLStheta[kk,jj,*]  = MLStempAve[kk,jj,*] * ((1000. / MLSpressave[kk,jj,*])^(.286))
      endif
    endfor
    endfor



N2     = fltarr(n_lon,n_lat, n_elements(altitude))*!values.f_nan
dN2     = fltarr(n_lon,n_lat, n_elements(altitude))*!values.f_nan
N22     = fltarr(n_lon,n_lat, n_elements(altitude))*!values.f_nan
dN22     = fltarr(n_lon,n_lat, n_elements(altitude))*!values.f_nan

    for ii = 1L, n_elements(altitude) - 2L do begin
    	index = reform(N2[*,*,ii])
    	numerator = 9.81*(reform((MLStheta[*,*,ii+1L])) - reform((MLStheta[*,*,ii-1L])))*240. / MLStheta[*,*,ii]
    	 denominator = (altitude[ii+1L] - altitude[ii-1L])*1000. * MLStempave[*,*,ii] ; change in theta with altitude
		index = numerator / denominator
    	     	N2[*,*,ii] = index
    	index = reform(N22[*,*,ii])
    	numerator = (reform((MLStheta[*,*,ii+1L])) - reform((MLStheta[*,*,ii-1L])))
    	 denominator = (altitude[ii+1L] - altitude[ii-1L]) ; change in theta with altitude
		index = numerator / denominator
    	     	N22[*,*,ii] = index
	endfor
    for ii = 1L, n_elements(altitude) - 2L do begin
    	index = reform(dN2[*,*,ii])
    	index = (reform(n2[*,*,ii+1L]) - reform(n2[*,*,ii-1L])) / (altitude[ii+1L] - altitude[ii-1L]) ; change in theta with altitude
    	dN2[*,*,ii] = index
    	index = reform(dN22[*,*,ii])
    	index = (reform(n22[*,*,ii+1L]) - reform(n22[*,*,ii-1L])) / (altitude[ii+1L] - altitude[ii-1L]) ; change in theta with altitude
    	dN22[*,*,ii] = index
	endfor
	
 
	; ---------------------------------------------------------------------
;Stratopause defined using local maxima, allowing for a separated stratopause
for ii = 0L, n_lon - 1L do begin

for jj = 0L, n_lat - 1L do begin
  nstrat = 0L
  ntrop = 0L
  nmeso = 0L



x = where (MLStempave[ii,jj,*] le 0., nx)
if nx gt 0L then MLStempave[ii,jj,x] = !values.f_nan

    MLSsmoothT = reform(MLStempave[ii,jj,*])
  if max(MLStempave[ii, jj, *], /nan) gt 0. then begin

nsmooth = 0L
ismooth = 0L
tsmooth1 = 0.

      for kk = 10L, n_levels - 10L do begin
        ;Stratopause definition using the static stability
;	if n2[ii,jj,kk] gt 50. then begin;
;		n2[ii,jj,*] = 100.
        ; Determines if ii,jj,kk location is a local max temperature

	tsmooth = smooth(mlssmootht,15,/nan)
      if (altitude[kk] gt 10. and altitude[kk] lt 85. and tsmooth[kk] gt -99. and $
              (tsmooth[kk] gt tsmooth[kk+1L]) and (tsmooth[kk] gt tsmooth[kk-1L]) and $
              (tsmooth[kk] gt tsmooth[kk+3L]) and (tsmooth[kk] gt tsmooth[kk-3L]) and $
              (tsmooth[kk] gt tsmooth[kk+4L]) and (tsmooth[kk] gt tsmooth[kk-4L]) and $
              (tsmooth[kk] gt tsmooth[kk+5L]) and (tsmooth[kk] gt tsmooth[kk-5L]) and $
              (tsmooth[  kk] gt tsmooth[ kk+2L]) and (tsmooth[ kk] gt tsmooth[kk-2L])) then begin
            	nsmooth = nsmooth + 1L
				if tsmooth[kk] gt tsmooth1 then begin
				 stratsmooth = altitude[kk]
				tsmooth1 = tsmooth[kk]
				endif
				endif
              endfor
for kk = 10L, n_levels - 10L do begin	
	IF NSTRAT lt 10L then begin

   if (altitude[kk] gt (stratsmooth - 15.) and altitude[kk] lt (stratsmooth + 15.) and MLSsmoothT[kk] gt -99. and $
              (MLSsmoothT[kk] gt MLSsmoothT[kk+1L]) and (MLSsmoothT[kk] gt MLSsmoothT[kk-1L]) and $
              (MLSsmoothT[kk+1] gt MLSsmoothT[kk+2L]) and (MLSsmoothT[kk+2] gt MLSsmoothT[kk+3L]) and $
              (MLSsmoothT[kk+3] gt MLSsmoothT[kk+4L]) and (MLSsmoothT[kk+4] gt MLSsmoothT[kk+5L]) and $
              (MLSsmoothT[kk-1] gt MLSsmoothT[kk-2L]) and (MLSsmoothT[kk-2] gt MLSsmoothT[kk-3L]) and $
              (MLSsmoothT[kk-3] gt MLSsmoothT[kk-4L]) and (MLSsmoothT[kk-4] gt MLSsmoothT[kk-5L]) and $
              (MLSsmoothT[kk] gt MLSsmoothT[kk+3L]) and (MLSsmoothT[kk] gt MLSsmoothT[kk-3L]) and $
              (MLSsmoothT[kk] gt MLSsmoothT[kk+4L]) and (MLSsmoothT[kk] gt MLSsmoothT[kk-4L]) and $
              (MLSsmoothT[kk] gt MLSsmoothT[kk+5L]) and (MLSsmoothT[kk] gt MLSsmoothT[kk-5L]) and $
              (MLSsmootht[  kk] gt MLSsmootht[ kk+2L]) and (MLSsmootht[ kk] gt MLSsmoothT[kk-2L])) and nstrat lt 10L then begin



               MLSstrattheta[nstrat,ii, jj] = MLStheta[ii,jj,kk]
                Tempstrat[nstrat,ii,jj] = MLStempave[ii,jj,kk]
                MLSstratpress[nstrat,ii,jj] = MLSpressave[ii,jj,kk]
                MLSstratGPheight[nstrat,ii,jj] = MLSgpht[kk]
                MLSzstrat[nstrat,ii,jj] = altitude[kk]
		       MLSn2 [nstrat,ii,jj] = n2[ii,jj,kk]
                                nstrat = nstrat + 1L
	endif
	endif

	


	if ntrop lt 10L then begin
      if (altitude[kk] gt 0. and altitude[kk] lt 20. and MLSsmoothT[kk] gt -99. and $
              (MLSsmoothT[kk] lt MLSsmoothT[kk+1L]) and (MLSsmoothT[kk] lt MLSsmoothT[kk-1L]) and $
              (MLSsmootht[  kk] lt MLSsmootht[ kk+2L]) and (MLSsmootht[ kk] lt MLSsmoothT[kk-2L])) then begin


                MLSTroptheta[nstrat,ii, jj] = MLStheta[ii,jj,kk]
                MLSTropGPheight[nstrat,ii, jj] = MLSgpht[kk]
                TempTrop[nstrat,ii,jj] = MLStempave[ii,jj,kk]
               MLSTropPress[nstrat,ii,jj] = MLSpressave[ii,jj,kk]
                 MLSztrop[nstrat,ii,jj] = altitude[kk]
                ntrop = ntrop + 1L
	endif
      endif

	if nmeso lt 10L then begin
      if (altitude[kk] gt 50. and altitude[kk] lt 300. and MLSsmoothT[kk] gt -99. and $
              (MLSsmoothT[kk] lt MLSsmoothT[kk+1L]) and (MLSsmoothT[kk] lt MLSsmoothT[kk-1L]) and $
              (MLSsmootht[  kk] lt MLSsmootht[ kk+2L]) and (MLSsmootht[ kk] lt MLSsmoothT[kk-2L])) then begin


                MLSmesotheta[nmeso,ii, jj] = MLStheta[ii,jj,kk]
                MLSmesoGPheight[nmeso,ii, jj] = MLSgpht[kk]
                Tempmeso[nmeso,ii,jj] = MLStempave[ii,jj,kk]
               MLSmesoPress[nmeso,ii,jj] = MLSpressave[ii,jj,kk]
                 MLSzmeso[nmeso,ii,jj] = altitude[kk]
                nmeso = nmeso + 1L

      endif
	endif
    endfor
    
;------------NEW STRATOPAUSE DEFINITION---------- FROM DAY ET AL., 2011-----------
;  FIT THE TEMPERATURE PROFILE TO A 4TH ORDER POLYNOMIAL BETWEEN 20-85 KM
	st = reform(mlstempave[ii,jj,10:100])
	z = reform(altitude[10:100])
	x = where(st lt 0. or finite(st) eq 0.,nx, comp = y)
	if nx gt 0L then st[x] = !values.f_nan
	if max(y) ge 0 then begin
	x = poly_fit(z[y],st[y],4)
 	polytemp = x[0,4]*z^4 + x[0,3]*z^3+x[0,2]*z^2+x[0,1]*z+x[0,0]

	x = where(polytemp eq max(polytemp[10:75],/nan),nx); MAX TEMPERATURE BETWEEN 20-85 KM
	if nx gt 0L then polystratheight[ii,jj] = z[x[0]]
	if nx gt 0L then polystrattemp[ii,jj] = max(mlstempave[ii,jj,polystratheight[ii,jj]-2l:polystratheight[ii,jj]+2l],/nan)
	endif

;	x = where(tempstrat[*,ii,jj] eq max(tempstrat[*,ii,jj], /nan), nx);
;	if nx EQ 1 then begin
;		if MLSzstrat[x,ii,jj] gt 70. and MLSzstrat[x,ii,jj] lt 100. then begin
;		print, 'High Stratopause'
;		print, 'latitude:  ', MLSlat[jj]
;		print, 'longitude: ', MLSlon[ii]
;		print, 'height:  ' , MLSzstrat[x,ii,jj]
;		if MLSlat[jj] lt 50. and MLSlat[jj] gt -50. then plot, MLStempave[ii,jj,*], altitude
;	endif
    
    
;endif
endif

ENDFOR
ENDFOR

if max(MLSzstrat,/nan) gt 0. then begin
print, 'file saved'
PotentialTemp = MLSpotentialT
      GeopotentialHeight = MLSGpHt
       
      
      x = where (lat gt 82. or lat lt -82.)
      MLSstrattheta[*,*,x] = !values.f_nan   ;  MLS coverage is from -82 to 82N
      MLSstratGPheight[*,*,x] = !values.f_nan   ;  MLS coverage is from -82 to 82N
      MLSstratpress[*,*,x] = !values.f_nan
      MLSzstrat[*,*,x] = !values.f_nan
	  MLSzstratconvert[*,*,x]= !values.f_nan
      MLStroptheta[*,*,x] = !values.f_nan   ;  MLS coverage is from -82 to 82N
      MLStropGPheight[*,*,x] = !values.f_nan   ;  MLS coverage is from -82 to 82N
      MLStroppress[*,*,x] = !values.f_nan
      MLSztrop[*,*,x] = !values.f_nan
      MLSmesotheta[*,*,x] = !values.f_nan   ;  MLS coverage is from -82 to 82N
      MLSmesoGPheight[*,*,x] = !values.f_nan   ;  MLS coverage is from -82 to 82N
      MLSmesopress[*,*,x] = !values.f_nan
      MLSzmeso[*,*,x] = !values.f_nan
      Tempstrat[*,*,x] = !values.f_nan
      Temptrop[*,*,x] = !values.f_nan
      Tempmeso[*,*,x] = !values.f_nan
      P = MLSstratpress
      date = date[0]
      comment = strarr(1)




      comment[0] = 'The stratopause height must meet the following criteria: it must be a local temperature maximum which has been defined'$
+' to be a measurement that is greater than the two points both higher and lower than itself on the temperature profile.'
          SAVE, Tempstrat,MLSzstrat,MLSStrattheta,MLSStratGPheight,$
          P,lat,lon,date,comment,n2,dn2,n22,dn22,MLSstratpress,polystratheight,polystrattemp, $
            FILENAME = '/Volumes/MacD68-2/france/data/MLS_data/MLS_pause_height_grid_smooth_for_20' + ifile +'.sav'
endif
endif
; ---------------------------------------------------------------------
; ---------------------------------------------------------------------



endfor


end
