;-----------------------------------------------------------------------------------------------------------------------------
;Saves daily polar cap average stratopause
;   	 -------------------------------
;       |         Jeff France           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 01/25/2014      |
;   	 -------------------------------
;
;
;
;-----------------------------------------------------------------------------------------------------------------------------
;

restore,'/Users/franceja/France_et_al_2014/Post_process/MLS_dailymean_lat_weight_profile_70-90N.sav'

;,dates, MEANDAILYPROFILE, altitude
x = where(MEANDAILYPROFILE eq 0.)
MEANDAILYPROFILE[x] = !values.f_nan


MLSstratopause = fltarr(n_elements(dates), n_elements(lon))
for jjj = 0L, n_elements(lon) - 1L do begin

MEANDAILYPROFILE1 = reform(MEANDAILYPROFILE[*,jjj,*])



	

	MLSt = reform(MEANDAILYPROFILE1[ii,*])
	x = where(altitude gt 20. and altitude le 100.)	
	xx = where(MLSt[x] eq max(MLSt[x], /nan), nxx)
	if nxx ge 1L then begin
		if MLSt[x[xx[0]]] gt 0. and MLSt[x[xx[0]]]lt 1000. then MLSstratopause[ii] = altitude[x[xx[0]]]
	endif
endfor
endfor
meanstrat = MLSstratopause
save, dates,meanstrat,filename = '/Users/franceja/France_et_al_2014/Post_process/MLS_area_weighted_strat_daily_mean_70-90N.sav'


END	