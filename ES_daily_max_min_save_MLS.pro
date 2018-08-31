;-----------------------------------------------------------------------------------------------------------------------------
;FIGURE 5 FOR STRATOPAUSE CLIMATOLOGY
;		 -------------------------------
;       |         Jeff France           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 11/18/2011      |
;		 -------------------------------
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
@/Volumes/MacD68-1/france/idl_files/frac_index


;--------------------------




restore, '/Volumes/MacD68-1/france/France_et_al_2012/Post_process/MLS_stratopause_temp_height_theta_mark_ES.sav'
restore, '/Volumes/MacD68-1/france/WACCM_paper/Post_process/MLS_elevated_strat.sav'



dailymeantemp = fltarr(n_elements(dayzeros), 61L)
dailymeanheight = fltarr(n_elements(dayzeros), 61L)
dailymeantheta = fltarr(n_elements(dayzeros), 61L)
dailymaxtemplat = fltarr(n_elements(dayzeros), 61L)
maxheightTheta = fltarr(n_elements(dayzeros), 61L)
dailymaxtemplon = fltarr(n_elements(dayzeros), 61L)
dailymaxheightlat = fltarr(n_elements(dayzeros), 61L)
dailymaxheightlon = fltarr(n_elements(dayzeros), 61L)
dailymaxthetalat = fltarr(n_elements(dayzeros), 61L)
dailymaxthetalon = fltarr(n_elements(dayzeros), 61L)
ESdate = strarr(n_elements(dayzeros)*61L)
inday = 0L
for iES = 0, n_elements(dayzeros) - 1L do begin
    sdate = dates[dayzeros(iES)]


;
; determine date of day -30 
;
    imn=long(strmid(sdate,4,2))
    idy=long(strmid(sdate,6,2))
    iyr=long(strmid(sdate,0,4))
    jday0 = JULDAY(imn, idy, iyr)
    jdaym30=jday0-30L
    CALDAT, jdaym30, imnm30 , idym30 , iyrm30

    for iday=0,60L do begin
    sdateindex = 61L*ies + iday
 ;   date = dates[sdateindex] 

	;ifile = date
	
		print, dates[sdateindex], sdateindex
		MLSt = reform(MLStemps[sdateindex,*,*])
		MLSz = reform(MLSheights[sdateindex,*,*])
		MLSth = reform(MLSthetas[sdateindex,*,*])
		marker = reform(MLSmarks[sdateindex,*,*])
            
        ;
   
	lats1 = fltarr(n_elements(lon),n_elements(lat)) 
	for ii = 0, n_elements(lat) - 1L do lats1[*,ii] = lat[ii]
	lons1 = fltarr(n_elements(lon),n_elements(lat)) 
	for ii = 0, n_elements(lon) - 1L do lons1[ii,*] = lon[ii]

   x = where(MLSz le 0.,nx)
   if nx gt 0L then MLSz[x] = !values.f_nan
   x = where(MLSt le 0.,nx)
   if nx gt 0L then MLSt[x] = !values.f_nan
   MLSz = smooth(MLSz,11,/edge,/nan)
   MLSt = smooth(MLSt,11,/edge,/nan)



  
x = where(marker lt 0. and marker gt -99.,nx)
if nx gt 0L then marker[x] = -1.

x = where(marker gt 0.,nx)
if nx gt 0L then marker[x] = 1.

x = where(marker le -99.,nx)
marker[x] = 0.

marker = smooth(marker,11,/nan)




	maxtemp = 0.*lat                                                              
	for i = 0L, n_elements(lat) - 1L do maxtemp[i]= max(MLSt[*,i],/nan) 
	; FIND ALL LOCAL TEMPERATURE MAXIMA (2 ADJACENT POINTS ARE LESS THAN CENTER POINT)
	localtmax = 0. * lat
	for j = 1L, n_elements(lat) - 2 do if maxtemp[j-1L] lt maxtemp[j] and maxtemp[j+1L] lt maxtemp[j] then localtmax[j] = maxtemp[j]
	index = where(localtmax ne 0, nindex)
	if nindex gt 0L then  begin
		ir = where(lat eq max(lat[index]))
		ir = ir[0]
		t = reform(MLSt[*,ir:*])
		lonsReform = reform(lons1[*,ir:*])
		latReform = reform(lats1[*,ir:*])
		y = where(t eq max(t,/nan),ny)
		dailymaxtemplon[iES, iday] = lonsReform[y[0]]
		dailymaxtemplat[iES, iday] = latReform[y[0]]
		ESdate[inday] = dates[dayzeros[ies]-30L+iday]
	endif



	index = where(lat gt 20.)                                                                          
	z = reform(MLSth[*,index[0]:*])
	theta_temp = reform(MLSth[*,index[0]:*])
	lonsReform = reform(lons1[*,index[0]:*])
	latReform = reform(lats1[*,index[0]:*])
	y = where(z eq max(z,/nan),ny)
	maxheightTheta[iES, iday] = theta_temp[y[0]]

	if theta_temp[y[0]] eq 0.0 and ny gt 1L then maxheightTheta[iES, iday] = max(theta_temp[y])
;	;if max(theta_temp[y]) = 0. then stop
	dailymaxheightlon[iES, iday] = lonsReform[y[0]]
	dailymaxheightlat[iES, iday] = latReform[y[0]]



	
	lat70 = where(lat ge 70L)
	latweight = SQRT(COS(2*3.141592*abs(lat70)/360.))
	temp = reform(MLSt[*,lat70])
	z = reform(MLSz[*,lat70])
	th = reform(MLSth[*,lat70])
	latweights = temp*0.
	for i = 0L, n_elements(lat70) - 1L do latweights[i,*] = latweight[i]
	x = where(temp gt 100. and temp lt 600.,nx)
	if nx gt 0L then dailymeantemp[ies,iday] = TOTAL(latweights[x]*temp[x],/nan)/total(latweights[x],/nan)
	x = where(z gt 10. and z lt 90.,nx)
	if nx gt 0L then dailymeanheight[ies,iday] = TOTAL(latweights[x]*z[x],/nan)/total(latweights[x],/nan)
	x = where(th gt 100. and th lt 100000.,nx)
	if nx gt 0L then dailymeantheta[ies,iday] = TOTAL(latweights[x]*th[x],/nan)/total(latweights[x],/nan)
	


inday = inday+1L
endfor

endfor

save, filename = '/Volumes/MacD68-1/france/ES_paper/Post_process/MLS_ES_daily_max_T_Z.sav', $
		dailymaxheightlon, dailymaxheightlat,dailymaxtemplon, dailymaxtemplat, esdate, maxheightTheta, dailymeantheta, dailymeanheight, dailymeantemp
end
