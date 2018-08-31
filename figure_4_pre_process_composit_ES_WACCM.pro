;-----------------------------------------------------------------------------------------------------------------------------
;SAVES CODE FOR FIGURES 3 OF FRANCE ET AL 2012. MEAN AND STANDARD DEVIATION STRAT HEIGHT AND TEMPERATURE ARE SAVED MONTHLY.
;	 -------------------------------
;       |         Jeff France           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 02/19/2012      |
;	 -------------------------------
;
;
;
;-----------------------------------------------------------------------------------------------------------------------------
;

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
@/Volumes/MacD68-1/france/idl_files/rd_WACCM_nc3
@/Volumes/MacD68-1/france/idl_files/frac_index


;------------RESTORE SAVE FILE WITH DAYS, LON, LAT FOR WACCM AND GEOS----------

restore, '/Volumes/MacD68-1/france/WACCM_paper/Post_process/Post_process_1_height_temps_mark.sav'
restore, '/Volumes/MacD68-1/france/WACCM_paper/Post_process/elevated_strat.sav'

y = ESindex



t1to30 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
t31to60 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
t_1to_30 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
t_31to_60 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
z1to30 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
z31to60 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
z_1to_30 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
z_31to_60 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
mark1to30 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
mark31to60 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
mark_1to_30 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
mark_31to_60 = fltarr(n_elements(dayzeros)*30L,n_elements(lon),n_elements(lat)) 
dates1to30 = strarr(n_elements(dayzeros)*30L)
dates31to60 = strarr(n_elements(dayzeros)*30L)
dates_1to_30 = strarr(n_elements(dayzeros)*30L) 
dates_31to_60 = strarr(n_elements(dayzeros)*30L)
for iii = 0L, n_elements(dayzeros) - 1L do begin
	if dayzeros[iii] ge 60L then begin
		dates1to30[iii*30L:(iii*30L) + 29L] = dates[dayzeros[iii]:dayzeros[iii]+29L]
		t1to30[iii*30L:(iii*30L) + 29L,*,*] = WACCMtemps[dayzeros[iii]:dayzeros[iii]+29L,*,*]
		t31to60[iii*30L:(iii*30L) + 29L,*,*] = WACCMtemps[dayzeros[iii]+30L:dayzeros[iii]+59L,*,*]
		t_1to_30[iii*30L:(iii*30L) + 29L,*,*] = WACCMtemps[dayzeros[iii]-30L:dayzeros[iii]-1L,*,*]
		t_31to_60[iii*30L:(iii*30L) + 29L,*,*] = WACCMtemps[dayzeros[iii]-60L:dayzeros[iii]-31L,*,*]
		z1to30[iii*30L:(iii*30L) + 29L,*,*] = WACCMheight[dayzeros[iii]:dayzeros[iii]+29L,*,*]
		z31to60[iii*30L:(iii*30L) + 29L,*,*] = WACCMheight[dayzeros[iii]+30L:dayzeros[iii]+59L,*,*]
		z_1to_30[iii*30L:(iii*30L) + 29L,*,*] = WACCMheight[dayzeros[iii]-30L:dayzeros[iii]-1L,*,*]
		z_31to_60[iii*30L:(iii*30L) + 29L,*,*] = WACCMheight[dayzeros[iii]-60L:dayzeros[iii]-31L,*,*]
		mark1to30[iii*30L:(iii*30L) + 29L,*,*] = WACCMmark[dayzeros[iii]:dayzeros[iii]+29L,*,*]
		mark31to60[iii*30L:(iii*30L) + 29L,*,*] = WACCMmark[dayzeros[iii]+30L:dayzeros[iii]+59L,*,*]
		mark_1to_30[iii*30L:(iii*30L) + 29L,*,*] = WACCMmark[dayzeros[iii]-30L:dayzeros[iii]-1L,*,*]
		mark_31to_60[iii*30L:(iii*30L) + 29L,*,*] = WACCMmark[dayzeros[iii]-60L:dayzeros[iii]-31L,*,*]
		dates1to30[iii*30L:(iii*30L) + 29L] = dates[dayzeros[iii]:dayzeros[iii]+29L]
		dates31to60[iii*30L:(iii*30L) + 29L] = dates[dayzeros[iii]+30L:dayzeros[iii]+59L]
		dates_1to_30[iii*30L:(iii*30L) + 29L] = dates[dayzeros[iii]-30L:dayzeros[iii]-1L]
		dates_31to_60[iii*30L:(iii*30L) + 29L] = dates[dayzeros[iii]-60L:dayzeros[iii]-31L]
	endif
	if dayzeros[iii] lt 60L and dayzeros[iii] gt 30L then begin
		t1to30[iii*30L:(iii*30L) + 29L,*,*] = WACCMtemps[dayzeros[iii]:dayzeros[iii]+29L,*,*]
		t31to60[iii*30L:(iii*30L) + 29L,*,*] = WACCMtemps[dayzeros[iii]+30L:dayzeros[iii]+59L,*,*]
		t_1to_30[iii*30L:(iii*30L) + 29L,*,*] = WACCMtemps[dayzeros[iii]-30L:dayzeros[iii]-1L,*,*]
		t_31to_60[0:dayzeros[iii]-31L,*,*] = WACCMtemps[0:dayzeros[iii]-31L,*,*]
		z1to30[iii*30L:(iii*30L) + 29L,*,*] = WACCMheight[dayzeros[iii]:dayzeros[iii]+29L,*,*]
		z31to60[iii*30L:(iii*30L) + 29L,*,*] = WACCMheight[dayzeros[iii]+30L:dayzeros[iii]+59L,*,*]
		z_1to_30[iii*30L:(iii*30L) + 29L,*,*] = WACCMheight[dayzeros[iii]-30L:dayzeros[iii]-1L,*,*]
		z_31to_60[0:dayzeros[iii]-31L,*,*] = WACCMheight[0:dayzeros[iii]-31L,*,*]
		mark1to30[iii*30L:(iii*30L) + 29L,*,*] = WACCMmark[dayzeros[iii]:dayzeros[iii]+29L,*,*]
		mark31to60[iii*30L:(iii*30L) + 29L,*,*] = WACCMmark[dayzeros[iii]+30L:dayzeros[iii]+59L,*,*]
		mark_1to_30[iii*30L:(iii*30L) + 29L,*,*] = WACCMmark[dayzeros[iii]-30L:dayzeros[iii]-1L,*,*]
		mark_31to_60[0:dayzeros[iii]-31L,*,*] = WACCMmark[0:dayzeros[iii]-31L,*,*]
		dates1to30[iii*30L:(iii*30L) + 29L] = dates[dayzeros[iii]:dayzeros[iii]+29L]
		dates31to60[iii*30L:(iii*30L) + 29L] = dates[dayzeros[iii]+30L:dayzeros[iii]+59L]
		dates_1to_30[iii*30L:(iii*30L) + 29L] = dates[dayzeros[iii]-30L:dayzeros[iii]-1L]
		dates_31to_60[0:dayzeros[iii]-31L] = dates[0L:dayzeros[iii]-31L]
	endif


z = where(t1to30 le 0.,nz)
if nz gt 0L then t1to30[z]= !values.f_nan
z = where(t31to60 le 0.,nz)
if nz gt 0L then t31to60[z]= !values.f_nan
z = where(z1to30 le 0.,nz)
if nz gt 0L then z1to30[z]= !values.f_nan
z = where(z31to60 le 0.,nz)
if nz gt 0L then z31to60[z]= !values.f_nan
z = where(t_1to_30 le 0.,nz)
if nz gt 0L then t_1to_30[z]= !values.f_nan
z = where(t_31to_60 le 0.,nz)
if nz gt 0L then t_31to_60[z]= !values.f_nan
z = where(z_1to_30 le 0.,nz)
if nz gt 0L then z_1to_30[z]= !values.f_nan
z = where(z_31to_60 le 0.,nz)
if nz gt 0L then z_31to_60[z]= !values.f_nan


	if iii eq 0L then begin
		meanZ1to30 = fltarr(n_elements(dayzeros),n_elements(lon),n_elements(lat)) * !values.f_nan
		meanT1to30 = fltarr(n_elements(dayzeros),n_elements(lon),n_elements(lat)) * !values.f_nan 
		meanZ31to60 = fltarr(n_elements(dayzeros),n_elements(lon),n_elements(lat))  * !values.f_nan
		meanT31to60 = fltarr(n_elements(dayzeros),n_elements(lon),n_elements(lat))  * !values.f_nan
		meanZ_1to_30 = fltarr(n_elements(dayzeros),n_elements(lon),n_elements(lat))  * !values.f_nan
		meanT_1to_30 = fltarr(n_elements(dayzeros),n_elements(lon),n_elements(lat))  * !values.f_nan
		meanZ_31to_60 = fltarr(n_elements(dayzeros),n_elements(lon),n_elements(lat))  * !values.f_nan
		meanT_31to_60 = fltarr(n_elements(dayzeros),n_elements(lon),n_elements(lat))  * !values.f_nan
	endif
	for ii = 52L, n_elements(lat) - 1L do begin
		for jj = 0L, n_elements(lon) - 1L do begin
			meanZ1to30[iii,jj,ii] = mean(z1to30[iii*30L:(iii*30L) + 29L,jj,ii],/nan)
			meanT1to30[iii,jj,ii] = mean(t1to30[iii*30L:(iii*30L) + 29L,jj,ii],/nan)
			meanZ31to60[iii,jj,ii] = mean(z31to60[iii*30L:(iii*30L) + 29L,jj,ii],/nan)
			meanT31to60[iii,jj,ii] = mean(t31to60[iii*30L:(iii*30L) + 29L,jj,ii],/nan)
			meanZ_1to_30[iii,jj,ii] = mean(z_1to_30[iii*30L:(iii*30L) + 29L,jj,ii],/nan)
			meanT_1to_30[iii,jj,ii] = mean(t_1to_30[iii*30L:(iii*30L) + 29L,jj,ii],/nan)
			meanZ_31to_60[iii,jj,ii] = mean(z_31to_60[iii*30L:(iii*30L) + 29L,jj,ii],/nan)
			meanT_31to_60[iii,jj,ii] = mean(t_31to_60[iii*30L:(iii*30L) + 29L,jj,ii],/nan)
		endfor
	endfor



	if iii eq 0L then begin
		maxZ1to30 = fltarr(n_elements(dayzeros),2L) * !values.f_nan
		maxZ31to60 = fltarr(n_elements(dayzeros),2L) * !values.f_nan
		maxZ_1to_30 = fltarr(n_elements(dayzeros),2L) * !values.f_nan
		maxZ_31to_60 = fltarr(n_elements(dayzeros),2L) * !values.f_nan
		maxT1to30 = fltarr(n_elements(dayzeros),2L) * !values.f_nan
		maxT31to60 = fltarr(n_elements(dayzeros),2L) * !values.f_nan
		maxT_1to_30 = fltarr(n_elements(dayzeros),2L) * !values.f_nan
		maxT_31to_60 = fltarr(n_elements(dayzeros),2L) * !values.f_nan
	endif

	waccmt=fltarr(n_elements(lon),n_elements(lat))

	lat2d = fltarr(n_elements(lon), n_elements(lat))
	lon2d = fltarr(n_elements(lon), n_elements(lat))
	for i = 0L, n_elements(lon) - 1L do lat2d[i,*] = lat
	for j = 0L, n_elements(lat) - 1L do lon2d[*,j] = lon

	waccmt = reform(meanZ1to30[iii,*,*])

	index = where(lat gt 20.)                                                                          
	t = reform(waccmt[*,index[0]:*])
	lonsReform = reform(lon2d[*,index[0]:*])
	latReform = reform(lat2d[*,index[0]:*])
	y = where(t eq max(t,/nan),ny)
	maxZ1to30[iii,0] = lonsReform[y[0]]
	maxZ1to30[iii,1] = latReform[y[0]]
	if ny gt 1L then print, lat2d[y], lon2d[y]

	waccmt = reform(meanZ31to60[iii,*,*])

	index = where(lat gt 20.)                                                                          
	t = reform(waccmt[*,index[0]:*])
	lonsReform = reform(lon2d[*,index[0]:*])
	latReform = reform(lat2d[*,index[0]:*])
	y = where(t eq max(t,/nan),ny)
	maxZ31to60[iii,0] = lonsReform[y[0]]
	maxZ31to60[iii,1] = latReform[y[0]]
	if ny gt 1L then print, lat2d[y], lon2d[y]

	waccmt = reform(meanZ_1to_30[iii,*,*])

	index = where(lat gt 20.)                                                                          
	t = reform(waccmt[*,index[0]:*])
	lonsReform = reform(lon2d[*,index[0]:*])
	latReform = reform(lat2d[*,index[0]:*])
	y = where(t eq max(t,/nan),ny)
	maxZ_1to_30[iii,0] = lonsReform[y[0]]
	maxZ_1to_30[iii,1] = latReform[y[0]]
	if ny gt 1L then print, lat2d[y], lon2d[y]

	waccmt = reform(meanZ_31to_60[iii,*,*])

	index = where(lat gt 20.)
	t = reform(waccmt[*,index[0]:*])
	lonsReform = reform(lon2d[*,index[0]:*])
	latReform = reform(lat2d[*,index[0]:*])
	y = where(t eq max(t,/nan),ny)
	maxZ_31to_60[iii,0] = lonsReform[y[0]]
	maxZ_31to_60[iii,1] = latReform[y[0]]
	if ny gt 1L then print, lat2d[y], lon2d[y]

	waccmt = reform(meanT1to30[iii,*,*])

	index = where(lat2d gt 20. and lat2d lt 90.)                                                                          
	maxtemp = 0.*lat                                                              
	for i = 0L, n_elements(lat) - 1L do maxtemp[i]= max(waccmt[*,i],/nan) 
	; FIND ALL LOCAL TEMPERATURE MAXIMA (2 ADJACENT POINTS ARE LESS THAN CENTER POINT)
	localtmax = 0. * lat
	for j = 1L, n_elements(lat) - 2 do if maxtemp[j-1L] lt maxtemp[j] and maxtemp[j+1L] lt maxtemp[j] then localtmax[j] = maxtemp[j]
	;oplot, lat, localTmax, psym = 2, symsize = 2, color = 150.
	index = where(localtmax ne 0, nindex)
	if nindex gt 0L then  begin
		ir = where(lat eq max(lat[index]))
		ir = ir[0]-1L
		t = reform(waccmt[*,ir:*])
		lonsReform = reform(lon2d[*,ir:*])
		latReform = reform(lat2d[*,ir:*])
		y = where(t eq max(t,/nan),ny)
		maxT1to30[iii,0] = lonsReform[y[0]]
		maxT1to30[iii,1] = latReform[y[0]]
		if ny gt 1L then print, lat2d[y], lon2d[y]
	endif
	waccmt = reform(meanT31to60[iii,*,*])

	maxtemp = 0.*lat                                                              
	for i = 0L, n_elements(lat) - 1L do maxtemp[i]= max(waccmt[*,i],/nan) 
	; FIND ALL LOCAL TEMPERATURE MAXIMA (2 ADJACENT POINTS ARE LESS THAN CENTER POINT)
	localtmax = 0. * lat
	for j = 1L, n_elements(lat) - 2 do if maxtemp[j-1L] lt maxtemp[j] and maxtemp[j+1L] lt maxtemp[j] then localtmax[j] = maxtemp[j]
	;oplot, lat, localTmax, psym = 2, symsize = 2, color = 150.
	index = where(localtmax ne 0, nindex)
	if nindex gt 0L then  begin
		ir = where(lat eq max(lat[index]))
		ir = ir[0]-1L
		t = reform(waccmt[*,ir:*])
		lonsReform = reform(lon2d[*,ir:*])
		latReform = reform(lat2d[*,ir:*])
		y = where(t eq max(t,/nan),ny)
		maxT31to60[iii,0] = lonsReform[y[0]]
		maxT31to60[iii,1] = latReform[y[0]]
		if ny gt 1L then print, lat2d[y], lon2d[y]
	endif

	waccmt = reform(meanT_1to_30[iii,*,*])

	maxtemp = 0.*lat                                                              
	for i = 0L, n_elements(lat) - 1L do maxtemp[i]= max(waccmt[*,i],/nan) 
	; FIND ALL LOCAL TEMPERATURE MAXIMA (2 ADJACENT POINTS ARE LESS THAN CENTER POINT)
	localtmax = 0. * lat
	for j = 1L, n_elements(lat) - 2 do if maxtemp[j-1L] lt maxtemp[j] and maxtemp[j+1L] lt maxtemp[j] then localtmax[j] = maxtemp[j]
	;oplot, lat, localTmax, psym = 2, symsize = 2, color = 150.
	index = where(localtmax ne 0, nindex)
	if nindex gt 0L then  begin
		ir = where(lat eq max(lat[index]))
		ir = ir[0]-1L
		t = reform(waccmt[*,ir:*])
		lonsReform = reform(lon2d[*,ir:*])
		latReform = reform(lat2d[*,ir:*])
		y = where(t eq max(t,/nan),ny)
		maxT_1to_30[iii,0] = lonsReform[y[0]]
		maxT_1to_30[iii,1] = latReform[y[0]]
		if ny gt 1L then print, lat2d[y], lon2d[y]
	endif

	waccmt = reform(meanT_31to_60[iii,*,*])

	maxtemp = 0.*lat                                                              
	for i = 0L, n_elements(lat) - 1L do maxtemp[i]= max(waccmt[*,i],/nan) 
	; FIND ALL LOCAL TEMPERATURE MAXIMA (2 ADJACENT POINTS ARE LESS THAN CENTER POINT)
	localtmax = 0. * lat
	for j = 1L, n_elements(lat) - 2 do if maxtemp[j-1L] lt maxtemp[j] and maxtemp[j+1L] lt maxtemp[j] then localtmax[j] = maxtemp[j]
	;oplot, lat, localTmax, psym = 2, symsize = 2, color = 150.
	index = where(localtmax ne 0, nindex)
	if nindex gt 0L then  begin
		ir = where(lat eq max(lat[index]))
		ir = ir[0]-1L


		t = reform(waccmt[*,ir:*])
		lonsReform = reform(lon2d[*,ir:*])
		latReform = reform(lat2d[*,ir:*])
		y = where(t eq max(t,/nan),ny)
		maxT_31to_60[iii,0] = lonsReform[y[0]]
		maxT_31to_60[iii,1] = latReform[y[0]]
		if ny gt 1L then print, lat2d[y], lon2d[y]
	endif




endfor


save, filename = '/Volumes/MacD68-1/france/WACCM_paper/Post_process/Figure_4_pre_process_composit_ES_WACCM.sav', 	t1to30,t31to60,t_1to_30, $
t_31to_60, z1to30, z31to60, z_1to_30, z_31to_60,mark1to30, mark31to60,mark_1to_30, mark_31to_60, lat, lon, $
meanZ1to30,meanZ31to60,meanZ_1to_30,meanZ_31to_60,meanT1to30,meanT31to60,meanT_1to_30,meanT_31to_60,$
maxZ1to30,maxZ31to60,maxZ_1to_30,maxZ_31to_60,maxT1to30,maxT31to60,maxT_1to_30,maxT_31to_60, dates1to30


END	