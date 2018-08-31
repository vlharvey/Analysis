;-----------------------------------------------------------------------------------------------------------------------------
; Reads in WACCM data and returns stratopause height and temperature
;	 -------------------------------
;       |         Jeff France           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 05/24/2010      |
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


;-----------------------------------------------------
;The following determines the date range

lstdy = 8L
lstmn = 8L
lstyr = 4L

;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
days = 2922L
;read,' Enter number of days  ', days
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

sys1 = SYSTIME( /JULIAN)

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


if day eq 0L then begin
	dates = strarr(days)
	doy = fltarr(days)
endif
;-------------------------------------------------------------------------



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
  ;doy = string(Format='(I03)',iday)
  ifile = string(syr+smn+sdy)
  
if day eq 0L then idoy = 221L  
if imn eq 1l and idy eq 1l then idoy = 0l
idoy = idoy + 1L


doy[day] = idoy
dates[day] = '20'+ifile

  ;----------------------------------------------
   	file ='/Volumes/MacD68-2/france/data/MLS_data/MLS_pause_height_grid_smooth_for_20' + ifile +'.sav'
  	spawn, 'ls ' + file, nfile
  	if nfile eq '' then continue
  	restore, file
    date = '20'+ifile
print, dates[day]
    

if day eq 0L then begin
	n_lat = n_elements(lat)
	n_lon = n_elements(lon)
	MLStemps = fltarr(days,n_lon,n_lat)
endif
	
MLStemps[day,*,*] = 			stratMLStemps[*,*]
MLSheight[day,*,*] = 			stratMLSheight[*,*]



endfor


save, MLSTemps, mlsheight,lat,lon,dates,doy,$
FILENAME = '/Volumes/MacD68-1/france/WACCM_paper/Post_process/MLS_Post_process_1_height_temps.sav'




end