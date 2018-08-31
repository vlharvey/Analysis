;-----------------------------------------------------------------------------------------------------------------------------
;SAVES CODE FOR ELEVATED STRATOPAUSE DAYS FOR WACCM.
;   	 -------------------------------
;       |         Jeff France           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 04/11/2012      |
;   	 -------------------------------
;
;
;
;-----------------------------------------------------------------------------------------------------------------------------
;
@/home/franceja/IDL_files/bsort

;------------RESTORE SAVE FILE WITH DAYS, LON, LAT FOR WACCM AND GEOS----------


restore, '/Users/franceja/France_et_al_2014/Post_process/MLS_area_weighted_strat_daily_mean_70-90N.sav'
restore,'/Users/franceja/France_et_al_2014/Post_process/MLS_Dailymean_lat_weight_profile_70-90N.sav'

strat = fltarr(n_elements(dates))
xx = where(meanstrat le 10.)
meanstrat[xx] = !values.f_nan
for i = 0, n_elements(dates) - 1L do strat[i] = mean(meanstrat[i,*],/nan)

climostratmean = fltarr(n_elements(dates))
climostratstddev = fltarr(n_elements(dates))


for iday = 0L, n_elements(dates) - 1L do begin
	if strmid(dates[iday],4,4) eq '0229' then begin
		climostratmean[iday] = climostratmean[iday-1L]
		climostratstddev[iday] = climostratstddev[iday-1L]
		continue
	endif
	xdays = reform(where(strmid(dates,4,4) eq strmid(dates[iday],4,4)))
	
	climostratmean[iday] = mean(strat[xdays],/nan)
	climostratstddev[iday] = stddev(strat[xdays],/nan)
endfor


climostratmean = smooth(climostratmean,31,/nan)
climostratstddev = smooth(climostratstddev,31,/nan)


;for jjj = 0, 7 do begin



;		lonmins = 45.*jjj - 22.5
;		lonmaxs = 45.*jjj + 22.5
;		xlon = where(lon ge lonmins and lon le lonmaxs)
;		if jjj eq 0L then xlon = where(lon ge (360.-22.5) or lon lt 22.5)
minjump = 25.

fo jjj = 0, n_elements(lon) - 1L do begin
;elevatedstrat,dates,strat
dum = indgen(n_elements(dates))

xx = where(strat le 10.)
strat[xx] = !values.f_nan

for i = 0, n_elements(dates) - 1L do strat[i] = mean(strat[i,*])

y = smooth(strat,9,/nan)

dayzeroindex = fltarr(n_elements(dates))
ESindex = fltarr(n_elements(dates))

totdays = n_elements(dates)
dayzeros = fltarr(200)
stratjump = fltarr(200)
tempstddev = fltarr(200)
nd = 0L
for ii = 7L, n_elements(y) - 8L do begin

	heightmin = climostratmean[ii] + 1.*climostratstddev[ii] ; 1stddev above decadal height avg
	jump = mean(strat[ii+3L:ii+7L]) - mean(strat[ii-7L:ii-3L])
	if jump gt 10. and strat[ii] gt heightmin and mean(strat[ii:ii+4L]) gt heightmin then begin ; require 
		dayzeros[nd] = ii
		stratjump[nd] = max(strat[ii+3L:ii+7L]) - min(strat[ii-7L:ii-3L])
		
		tempstddev[nd] = stddev(meandailyprofile[x + ii - 7L, where((altitude - min(strat[ii-7L:ii-3L])) eq min((altitude - min(strat[ii-7L:ii-3L]))))$
		:where((altitude - max(altitude - strat[ii+3L:ii+7L])) eq min((altitude - max(strat[ii+3L:ii+7L]))))],/nan)
		
		if stratjump[nd] ge minjump then dayzeroindex[ii] = 1L
		
		nd = nd + 1L
		ii = ii+20L
	endif
endfor


x = where(stratjump ge minjump,nx)

dayzeros = reform(dayzeros[x])

x = where(dayzeroindex eq 1L,nx)

for ii = 0L, nx - 1L do ESindex[x[ii]:x[ii] + 5L] = 1L


; Determine ES period following each day zero-- ES lasts until stratopause descends to within one standard deviation above the daily mean

x = where(dayzeroindex eq 1L,nx)
for ii = 0L, nx - 1L do begin
	xdate = where(strmatch(strmid(dates,4,4), strmid(dates[x[ii]],4,4)) eq 1L) + 6L ; Add 6 because the first 5 days are assumed to be elevated

	for jj = 0L, 90L do begin ; loop over days following ES day zero to determine how long it's elevated
		xdate2 = xdate + jj
		esday = x[ii] + 6L + jj 			; Add 6 because the first 5 days are assumed to be elevated
		y = where(strat[xdate2] gt 20. and strat[xdate2] lt 100.,ny)
		dailymean = mean(strat[xdate2[y]],/nan)
		dailystddev = stddev(strat[xdate2[y]],/nan)
		if strat[esday] gt (dailymean + dailystddev) then begin
			ESindex[esday] = 1L
		endif else break
	endfor
endfor

x = where(esindex eq 1L, comp = y)
esindex = x
noesindex = y

save,tempstddev,dayzeros, dayzeroindex, ESindex, noESindex, stratjump,dates, filename='/Users/franceja/France_et_al_2014/Post_process/MLS_elevated_strat_70-90N.sav' ;'+strtrim(strcompress(string(jjj*45L)),2)+'
END	