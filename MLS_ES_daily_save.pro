;-----------------------------------------------------------------------------------------------------------------------------
;save ES max/min temp height locations for each day
;	 -------------------------------
;       |         Jeff France           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 01/25/2014      |
;	 -------------------------------
;
;
;
;-----------------------------------------------------------------------------------------------------------------------------
;

@/home/franceja/IDL_files/stddat			; Determines the number of days since Jan 1, 1956
@/home/franceja/IDL_files/kgmt			; This function computes the Julian day number (GMT) from the
								;    day, month, and year information.
@/home/franceja/IDL_files/ckday			; This routine changes the Julian day from 365(6 if leap yr)
								;    to 1 and increases the year, if necessary.
@/home/franceja/IDL_files/kdate			; gives back kmn,kdy information from the Julian day #.
@/home/franceja/IDL_files/rd_ukmo_nc3			; reads the data from nc3 files
@/home/franceja/IDL_files/date2uars			; This code returns the UARS day given (jday,year) information.
@/home/franceja/IDL_files/plotPosition		; defines positions for n number of plots
@/home/franceja/IDL_files/rd_waccm_nc3
@/home/franceja/IDL_files/frac_index


;--------------------------


days = 0
restore, '/Users/franceja/France_et_al_2014/Post_process/MLS_strat_Z_T_MERRA_mark_2004-2014.sav'
restore, '/Users/franceja/France_et_al_2014/Post_process/MLS_elevated_strat_70-90N.sav'



dailymaxtemplat = fltarr(n_elements(dayzeros), 61L)
dailymaxtemplon = fltarr(n_elements(dayzeros), 61L)
dailymaxheightlat = fltarr(n_elements(dayzeros), 61L)
dailymaxheightlon = fltarr(n_elements(dayzeros), 61L)
dailymeanheight = fltarr(n_elements(dayzeros), 61L)
dailymeantemp = fltarr(n_elements(dayzeros), 61L)
ESdate = strarr(n_elements(dayzeros)*61L)
inday = 0L

	
	
	for nnday = 0, n_elements(dayzeros) - 1L do begin
    sdate = dates[dayzeros(nnday)]
    print,sdate
    
    
    
;
; determine date of day -30 
;
    imn=long(strmid(sdate,4,2))
    idy=long(strmid(sdate,6,2))
    iyr=long(strmid(sdate,0,4))
    jday0 = JULDAY(imn, idy, iyr)
    jdaym30=jday0-30L
    CALDAT, jdaym30, imnm30 , idym30 , iyrm30

    for ndays=0, 60L do begin
        jday=jdaym30+ndays
        CALDAT, jday, imn , idy , iyr
        print,ndays-30L,imn,idy,iyr
print, inday

    sdateindex = dayzeros[nnday] + ndays - 30L

    mlsdailytemp = reform(mlstemps[sdateindex,*,*])
    mlsdailyheight = reform(mlsheights[sdateindex,*,*])
    mlsdailymark = reform(mlsmarks[sdateindex,*,*])
            
        ;
; plot and save plot with ES#nnday(1-15) and days=ndays-30 in the filename
;



	lats1 = fltarr(n_elements(lon),n_elements(lat)) 
	for ii = 0, n_elements(lat) - 1L do lats1[*,ii] = lat[ii]
	lons1 = fltarr(n_elements(lon),n_elements(lat)) 
	for ii = 0, n_elements(lon) - 1L do lons1[ii,*] = lon[ii]


	x = where(mlsdailytemp le 0.,nx)
	if nx gt 0L then mlsdailytemp[x] = !values.f_nan
	x = where(mlsdailyheight le 0.,nx)
	if nx gt 0L then mlsdailyheight[x] = !values.f_nan
	temps = smooth(mlsdailytemp,7,/nan)
	xlat = where(lat ge 70.)
	dailymeanheight[nnday,ndays] = mean(mlsdailyheight[*,xlat],/nan)
	dailymeantemp[nnday,ndays] = mean(mlsdailytemp[*,xlat],/nan)
	maxtemp = 0.*lat
	for i = 0L, n_elements(lat) - 1L do maxtemp[i]= max(temps[*,i],/nan) 
	; FIND ALL LOCAL TEMPERATURE MAXIMA (2 ADJACENT POINTS ARE LESS THAN CENTER POINT)
	localtmax = 0. * lat
	for j = 1L, n_elements(lat) - 2 do if maxtemp[j-1L] lt maxtemp[j] and maxtemp[j+1L] lt maxtemp[j] then localtmax[j] = maxtemp[j]
	index = where(localtmax ne 0, nindex)
	if nindex gt 0L then  begin
		ir = where(lat eq max(lat[index]))
		ir = ir[0]
		t = reform(temps[*,ir:*])
		lonsReform = reform(lons1[*,ir:*])
		latReform = reform(lats1[*,ir:*])
		y = where(t eq max(t,/nan),ny)
		dailymaxtemplon[nnday, ndays] = lonsReform[y[0]]
		dailymaxtemplat[nnday, ndays] = latReform[y[0]]
		ESdate[inday] = dates[sdateindex]
	endif

	 
	x = where(mlsdailyheight le 0.,nx)
	if nx gt 0L then mlsdailyheight[x] = !values.f_nan
	heights = smooth(mlsdailyheight,7,/nan)

	index = where(lat gt 20.)                                                                          
	t = reform(heights[*,index[0]:*])
	lonsReform = reform(lons1[*,index[0]:*])
	latReform = reform(lats1[*,index[0]:*])
	y = where(t eq max(t,/nan),ny)
	dailymaxheightlon[nnday, ndays] = lonsReform[y[0]]
	dailymaxheightlat[nnday, ndays] = latReform[y[0]]


;-----------------------------------------------------------------------
	inday = inday + 1L

	endfor

endfor

save, filename = '/Users/franceja/France_et_al_2014/Post_process/MLS_ES_daily_max_T_Z.sav', $
		dailymaxheightlon, dailymaxheightlat,dailymaxtemplon, dailymaxtemplat, esdate,dailymeantemp,dailymeanheight
end
