;-----------------------------------------------------------------------------------------------------------------------------
;Using the database of GEOS5, MLS, MLS, this creates a save file of stratopause height and T on geos5 grid and original strat savefile grid
;	 -------------------------------
;       |         Jeff France           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 05/11/2010      |
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



;;----------------DEFINE THE ELEVATED STRATOPAUSE--------------------------------------;;
nnx = 0L
;remove elevated stratopause days
restore, '/Volumes/MacD68-1/france/WACCM_paper/Post_process/MLS_elevated_strat.sav'
xdayzeros = dayzeros



;-----------Determine the range of days and set up the counter for the date----------------------


  	directory='/Volumes/MacD68-2/france/data/MLS_data/'



iii = 0L
xes = 0L
iesday = -30.


days = 61L*n_elements(dayzeros)
esdates = strarr(days)
FOR iii = 0L, days-1 DO BEGIN
	if iesday eq 31. then begin
		xes = xes+1L
		iesday = -30.
	endif

	if iii eq 0L then ESbefore0after1 = fltarr(n_elements(dayzeros)*61.)
	if iesday lt 0L then ESbefore0after1[iii] = 0L	
	if iesday ge 0L then ESbefore0after1[iii] = 1L	


	sys1 = SYSTIME( /JULIAN)


	nc = 0L
	ifile = dates[xdayzeros[xes]+iesday]
	print, ifile, xes, iesday,xdayzeros[xes]
	iesday = iesday+1L

 	; restore MLS sav files
 	file =  directory + 'MLS_T_GPH_pressure_' + ifile + '.sav'
  	spawn, 'ls ' + file, nfile
  	if nfile ne '' then begin
    		restore, file
			MLStemp = temperature
			MLSGPH = GPH
			mlslat = MLS_lat
			mlslon = MLS_lon
			x = where(MLSgph le 0.,nx)
			if nx gt 0L then MLSGPH[x] = !values.f_nan
			pressure = pressure_grid
	endif
	n_levels = n_elements(pressure)

 	if iii eq 0L then begin
 		mlstemps = fltarr(days, n_levels)-999.
		mlstemps70 = fltarr(days, n_levels)-999.
		mlstemps60 = fltarr(days, n_levels)-999.
		mlstemps50 = fltarr(days, n_levels)-999.
		mlsheight70 = fltarr(days, n_levels)-999.
		mlsheight60 = fltarr(days, n_levels)-999.
		mlsheight50 = fltarr(days, n_levels)-999.
	meanMLStemp50 = fltarr(n_levels)
	meanMLStemp60 = fltarr(n_levels)
	meanMLStemp70 = fltarr(n_levels)
	meanMLStemppole = fltarr(n_levels)
	MLSstratopause50 = fltarr(days)
	MLSstratopause60 = fltarr(days)
	MLSstratopause70 = fltarr(days)
	MLSstratopausepole = fltarr(days)
	endif
	 ; if file exists, then determine daily mean T and P
		
    for kk = 0L, n_levels-1L do begin

        level  = MLStemp[*,kk]
      ; bin data into 2 degree lat bins

      x = where(level gt 150. and level lt 400. and MLSlat gt 75., nx)
      if nx gt 10L then MLStemps[iii,kk]  = mean(level(x), /nan)

      x = where(level gt 150. and level lt 400. and MLSlat gt 68. and MLSlat lt 72., nx)
      if nx gt 10L then begin
      	xlat = where(smooth(level[x],11,/nan) eq max(smooth(level[x],11,/nan),/nan))
      	ylat = where(abs(MLSlon[x] - MLSlon[x[xlat[0]]]) gt 100.,nylat)
      	if nylat ge 11L then MLStemps70(iii,kk)  = max(smooth(level[x],11,/nan),/nan) - min(smooth(level[x[ylat]],11,/nan),/nan)
	  endif
      x = where(level gt 150. and level lt 400. and MLSlat gt 58. and MLSlat lt 62., nx)
      if nx gt 10L then begin
      	xlat = where(smooth(level[x],11,/nan) eq max(smooth(level[x],11,/nan),/nan))
      	ylat = where(abs(MLSlon[x] - MLSlon[x[xlat[0]]]) gt 100.,nylat)
      	if nylat ge 11L then MLStemps60(iii,kk)  = max(smooth(level[x],11,/nan),/nan) - min(smooth(level[x[ylat]],11,/nan),/nan)
	  endif
      x = where(level gt 150. and level lt 400. and MLSlat gt 48. and MLSlat lt 52., nx)
      if nx gt 10L then begin
      	xlat = where(smooth(level[x],11,/nan) eq max(smooth(level[x],11,/nan),/nan))
      	ylat = where(abs(MLSlon[x] - MLSlon[x[xlat[0]]]) gt 100.,nylat)
      	if nylat ge 11L then MLStemps50(iii,kk)  = max(smooth(level[x],11,/nan),/nan) - min(smooth(level[x[ylat]],11,/nan),/nan)
	  endif

      level  = reform(MLSGPH[*,kk])
      ; bin data into 2 degree lat bins

      x = where(level gt 0. and level lt 100000. and MLSlat gt 68. and MLSlat lt 72., nx)
      if nx gt 10L then begin
      	xlat = where(smooth(level[x],11,/nan) eq max(smooth(level[x],11,/nan),/nan))
      	ylat = where(abs(MLSlon[x] - MLSlon[x[xlat[0]]]) gt 100.,nylat)
      	if nylat ge 11L then MLSheight70(iii,kk)  = max(smooth(level[x],11,/nan),/nan) - min(smooth(level[x[ylat]],11,/nan),/nan)
	  endif

      x = where(level gt 0. and level lt 100000. and MLSlat gt 58. and MLSlat lt 62., nx)
      if nx gt 10L then begin
      	xlat = where(smooth(level[x],11,/nan) eq max(smooth(level[x],11,/nan),/nan))
      	ylat = where(abs(MLSlon[x] - MLSlon[x[xlat[0]]]) gt 100.,nylat)
      	if nylat ge 11L then MLSheight60(iii,kk)  = max(smooth(level[x],11,/nan),/nan) - min(smooth(level[x[ylat]],11,/nan),/nan)
	  endif

	  
      x = where(level gt 0. and level lt 100000. and MLSlat gt 48. and MLSlat lt 52., nx)
      if nx gt 10L then begin
      	xlat = where(smooth(level[x],11,/nan) eq max(smooth(level[x],11,/nan),/nan))
      	ylat = where(abs(MLSlon[x] - MLSlon[x[xlat[0]]]) gt 100.,nylat)
      	if nylat ge 11L then MLSheight50(iii,kk)  = max(smooth(level[x],11,/nan),/nan) - min(smooth(level[x[ylat]],11,/nan),/nan)
	  endif
      
    

		level  = reform(MLSheight50[*,kk])
		x = where(level le 0.,nx)
		if nx gt 0L then level[x] = !values.f_nan
      	; bin data into 2 degree lat bins

      	z = where(level gt 0. and level lt 90000., nz)
      	if nz gt 10. then begin
	  		X = MLSlon[z] 
			Y = level[z]
			weights = Y*0. + 1. ; Define a vector of weights.
			levelmean = mean(Y,/nan)
			A2guess = where(abs(Y - levelmean) eq min(abs(Y - levelmean),/nan))
			A2guess = X[A2guess[0]]
			A = [1000.0,A2guess, levelmean] ; Provide an initial guess of the function's parameters.
			yfit = CURVEFIT(X, Y, weights, A, SIGMA, FUNCTION_NAME='wave1')
;			PRINT, 'Function parameters: ', A ; Print the parameters returned in A. 
			MLSheight50[iii,kk] = abs(A[0])
		endif

		level  = reform(MLSheight60[*,kk])
      	z = where(level gt 0. and level lt 90000., nz)
   		if nz gt 10. then begin
			X = MLSlon[z] 
			Y = level[z]
			weights = Y*0. + 1. ; Define a vector of weights.
			levelmean = mean(Y,/nan)
			A2guess = where(abs(Y - levelmean) eq min(abs(Y - levelmean),/nan))
			A2guess = X[A2guess[0]]
			A = [1000.0,A2guess, levelmean] ; Provide an initial guess of the function's parameters.
			yfit = CURVEFIT(X, Y, weights, A, SIGMA, FUNCTION_NAME='wave1') ; fit data to sine function : y = a[0]*sin(a[1]*x+a[2]) + a[3]
;			PRINT, 'Function parameters: ', A ; Print the parameters returned in A. 
			MLSheight60[iii,kk] = abs(A[0])
		endif
		      
		level  = reform(MLSheight70[*,kk])
      	z = where(level gt 0. and level lt 90000., nz)
   		if nz gt 10. then begin
			X = MLSlon[z] 
			Y = level[z]
			weights = Y*0. + 1. ; Define a vector of weights.
			levelmean = mean(Y,/nan)
			A2guess = where(abs(Y - levelmean) eq min(abs(Y - levelmean),/nan))
			A2guess = X[A2guess[0]]
			A = [1000.0,A2guess, levelmean] ; Provide an initial guess of the function's parameters.
			yfit = CURVEFIT(X, Y, weights, A, SIGMA, FUNCTION_NAME='wave1') ; fit data to sine function : y = a[0]*sin(a[1]*x+a[2]) + a[3]
;			PRINT, 'Function parameters: ', A ; Print the parameters returned in A. 
			MLSheight70[iii,kk] = abs(A[0])
     stop
		endif
      
      
 	  


	
		x = where(mlslat gt 47. and mlslat lt 53.)
		meanMLStemp50[kk] = mean(MLStemp[x,kk],/nan)
		x = where(mlslat gt 57. and mlslat lt 63.)
		meanMLStemp60[kk] = mean(MLStemp[x,kk],/nan)
		x = where(mlslat gt 67. and mlslat lt 73.)
		meanMLStemp70[kk] = mean(MLStemp[x,kk],/nan)
		x = where(mlslat ge 70.)
		meanMLStemppole[kk] = mean(MLStemp[x,kk],/nan)
	
   endfor ; kk

x = where(pressure lt 50. and pressure gt .001 and max(meanMLStemp50 gt 100.), nx)
if nx gt 0L then begin
	y = where(max(meanMLStemp50[x]) eq meanMLStemp50[x],ny)
	if ny gt 0L then MLSstratopause50[iii] = pressure[x[y[0]]]
endif

x = where(pressure lt 50. and pressure gt .001 and max(meanMLStemp60 gt 100.), nx)
if nx gt 0L then begin
	y = where(max(meanMLStemp60[x]) eq meanMLStemp60[x],ny)
	if ny gt 0L then MLSstratopause60[iii] = pressure[x[y[0]]]
endif

x = where(pressure lt 50. and pressure gt .001 and max(meanMLStemp70 gt 100.), nx)
if nx gt 0L then begin
	y = where(max(meanMLStemp70[x]) eq meanMLStemp70[x],ny)
	if ny gt 0L then MLSstratopause70[iii] = pressure[x[y[0]]]
endif
x = where(pressure lt 50. and pressure gt .001 and max(meanMLStemppole gt 100.), nx)
if nx gt 0L then begin
	y = where(max(meanMLStemppole[x]) eq meanMLStemppole[x],ny)
	if ny gt 0L then MLSstratopausepole[iii] = pressure[x[y[0]]]
endif
print, MLSstratopause50[iii]

esdates[iii] = ifile
endfor

save, filename = '/Volumes/MacD68-1/france/ES_paper/Post_process/Platentary_Wave_1_amplitudes_MLS.sav',$
	esdates,MLSheight50,MLSheight60,MLSheight70,pressure,MLSstratopause50,MLSstratopause60,MLSstratopause70,MLSstratopausepole



end
