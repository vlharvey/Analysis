;-----------------------------------------------------------------------------------------------------------------------------
;Using the database of merra, SABER, MLS, this creates a save file of stratopause height and T on merra grid and original strat savefile grid
;	 -------------------------------
;       |         Jeff France           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 01/28/2011      |
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
@/home/franceja/IDL_files/date2uars			; This code returns the UARS day given (jday,year) information.
@/home/franceja/IDL_files/plotPosition		; defines positions for n number of plots
@/home/franceja/IDL_files/frac_index
@/home/franceja/IDL_files/rd_merra_nc3			; reads the data from nc3 files


SABERheights = 0
merraheights = 0
WACCMheights = 0
MLSheights = 0
marker = 0.

;-----------Determine the range of days and set up the counter for the date----------------------

lstdy = 8L
lstmn = 8L
lstyr = 4L
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
days = 3500L
;read,' Enter number of days  ', days
;  set endday equal to startday so for each plot, only one day is plotted, for each elements of 'days'
ledmn = lstmn
leddy = lstdy
ledyr = lstyr

doy = fltarr(days)
idoy = 221L

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
startday = julday(lstmn, lstdy, lstyr)
endday = julday(ledmn, leddy, ledyr)

;  ----------- define variables and set plot window------------------
; loop over each day
nth_day = 10
nday = iday
ifile1 = 0L
ifile2 = 0L
ifile3 = 0L
height1 = 0L
height2 = 0L
height3 = 0L
temp1 = 0L
temp2 = 0L
temp3 = 0L
alon = findgen(96)
alat = findgen(72)
nth=0L
saberyaw = 0L
FOR iii = 0L, days-1 DO BEGIN          	; n_days is set in plot code and it determines how many days will be averaged together in each plot.
  	nsave = 0L

  	;----------------------------------------------
  	; determine the date
  	ckday,iday,iyr
  	kdate,float(iday),iyr,imn,idy
  	stddat, imn,idy,iyr,ndays
  	if iyr lt 2000 then iyr1=iyr-1900
  	if iyr ge 2000 then iyr1=iyr-2000
  	syr   = string(FORMAT='(I4.2)',iyr)
  	smn   = string(FORMAT='(I2.2)',imn)
  	sdy   = string(FORMAT='(I2.2)',idy)
  	ifile = string(syr+smn+sdy)

  	ifile3 = ifile2
  	ifile2 = ifile1
  	ifile1 = ifile

	if iii eq 0L then dates = strarr(days)
	dates[iii] = ifile


if imn eq 1l and idy eq 1l then idoy = 0l
idoy = idoy + 1L
doy[iii] = idoy

print, doy[iii]






	;--------RESTORE DATA-------------------------


marker = marker*0.
		;------------restore merra data from IDL save files----------------------------------
		merrafile = 0L
		mark = 0
  		print ,ifile
 		; restore merra sav files
		@/home/franceja/MERRA_data/Pre_process/read_merra  ; read in merra data

		if max(mark,/nan) gt 0L then begin
  		       		alat = alat
       		alon = alon
       		alat = alat
       		merramark = intmerramark
		latgrid = alat
		longrid = alon

endif

x = where(mark le -10.,nx)
if nx gt 0L then mark[x] = 0.
x = where(mark gt 0. or mark lt 0.,nx)
if nx gt 0L then mark[x] = mark[x]/abs(mark[x])
		

    	;------------restore MLS data from IDL save files----------------------------------
  	print ,ifile
  	directory='/Users/franceja/MLS_data/Stratopause/'
mlsfile = 0
 	; restore MLS sav files
  	file =  directory + 'MLS_stratopause_' + ifile + '.sav'
  	spawn, 'ls ' + file, nfile
  	if nfile ne '' then begin
    		restore, file
    		MLSlat = lat
    		MLSlon = lon
    		MLST = mlsTstrat
		mlsfile = 1L
	endif

	
	
;-------------------------------------DEFINE VARIABLES--------------------------------------------------------------


		if iii eq 0L then day1 = date
		if iii eq days - 1L then day2 = date
	    	
		if n_elements(merraheights) eq 1L then begin
    			merraheights = fltarr(days, n_elements(lon), n_elements(lat))*0. - 999.
    			merratemps = fltarr(days,n_elements(lon), n_elements(lat))*0. - 999.
    			merramarkers = fltarr(days, n_elements(lon), n_elements(lat))*0. - 999.
  				merradouble = fltarr(days, n_elements(lon), n_elements(lat))*0.
		endif

	if iii eq 0L then day1 = date
	if iii eq days - 1L then day2 = date
    	



	


		if iii eq days - 1L then endday = date
	    	

		if n_elements(MLSheights) eq 1L then begin
    			mlsheights = fltarr(days, n_elements(mlslon), n_elements(mlslat))*0. - 999.
    			mlstemps = fltarr(days,n_elements(mlslon), n_elements(mlslat))*0. - 999.
    			mlsmarks = fltarr(days,n_elements(mlslon), n_elements(mlslat))*0.
    			mlsdouble = fltarr(days, n_elements(mlslon), n_elements(mlslat))*0.
		endif
		
icount = 0

;x = where(alat gt .,nx)
;if nx gt 0L then mark[x,*,*] = 0.

;-------------------------------LOOP OVER LAT/LON TO DETERMINE STRATOPAUSE Z/T---------------------------------------------------
	for ii = 0L, n_elements(lon)-1L do begin
		for jj = 0L, n_elements(lat)-1L do begin
 
      			if mlsfile eq 1L then begin 

      			iilat=where(abs(alat - lat[jj]) eq min(abs(alat - lat[jj])))
      			jjlon=where(abs(alon - lon[ii]) eq min(abs(alon - lon[ii])))

				y = where(mlszstrat[*,ii,jj] gt 20. and mlszstrat[*,ii,jj] lt 100.,ny)
				if ny gt 0L then begin
					x = where(mlst[y,ii,jj] eq max(mlst[y,ii,jj],/nan),nx)
					if nx eq 1 then begin
 						mlsheights[iii,ii,jj] = mlszstrat[y[x],ii,jj]
						mlstemps[iii,ii,jj] = mlst[y[x],ii,jj]
						x = where(abs(mlsheights[iii,ii,jj] - gpht[ii,jj,*]) eq min(abs(mlsheights[iii,ii,jj] - gpht[ii,jj,*]),/nan),nx)

						if nx eq 2L then begin
							if mlsheights[iii,ii,jj] lt 100. and mark[iilat,jjlon,x[0]] eq mark[iilat,jjlon,x[1]]$
							 then mlsmarks[iii,ii,jj] = mark[iilat,jjlon,x[0]]
						endif							
						if x[0] eq 0L and nx eq 1L then mlsmarks[iii,ii,jj] = mark[iilat,jjlon,x]
						
						if x[0] gt 0L and x[0] lt n_elements(gpht[0,0,*]) and nx eq 1L then begin
						if (mlsheights[iii,ii,jj] - gpht[ii,jj,x-1]) lt (mlsheights[iii,ii,jj] - gpht[ii,jj,x+1]) then begin
							if mlsheights[iii,ii,jj] lt 100. and mark[iilat,jjlon,x] eq mark[iilat,jjlon,x-1]$
						 	then mlsmarks[iii,ii,jj] = mark[iilat,jjlon,x]
						endif
 						if (mlsheights[iii,ii,jj] - gpht[ii,jj,x-1]) gt (mlsheights[iii,ii,jj] - gpht[ii,jj,x+1]) then begin
							if mlsheights[iii,ii,jj] lt 100. and mark[iilat,jjlon,x] eq mark[iilat,jjlon,x+1]$
							 then mlsmarks[iii,ii,jj] = mark[iilat,jjlon,x]
						endif
						endif
					endif
				endif

				if ii gt 0L and jj gt 0L then begin
					diff = abs(mlsheights[iii,ii,jj] - mlsheights[iii,ii,jj-1L])
					diff2 = abs(mlsheights[iii,ii,jj] - mlsheights[iii,ii-1L,jj])
					diff3 = abs(mlsheights[iii,ii,jj] - mlsheights[iii,ii-1L,jj-1L])
					if diff ge 10. and diff le 100. or diff2 ge 10. and diff2 le 100. $
					and diff3 ge 10. and diff3 le 100. then mlsdouble[iii,ii,jj] = 1L
				endif
			ENDIF; MLSFILE=1

		    	
		    	
			if n_elements(merraheights) eq 1L then begin
    				merraheights = fltarr(days, n_elements(lon), n_elements(lat))*0. - 999.
    				merratemps = fltarr(days,n_elements(lon), n_elements(lat))*0. - 999.
    				merramarkers = fltarr(days,n_elements(lon), n_elements(lat))*0. - 999.
			endif
		

		    	
		    	

		    	
					; STATIC STABILITY AS IN MANNEY
		    	

			endfor
		endfor

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
endfor


save, filename = '/Users/franceja/France_et_al_2014/Post_process/MLS_strat_Z_T_MERRA_mark_2004-2014.sav',$
	mlstemps,mlsheights,mlsmarks, dates, lat, lon, doy


end
