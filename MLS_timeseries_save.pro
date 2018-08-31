@/home/franceja/IDL_files/stddat			; Determines the number of days since Jan 1, 1956
@/home/franceja/IDL_files/kgmt			; This function computes the Julian day number (GMT) from the
								;    day, month, and year information.
@/home/franceja/IDL_files/ckday			; This routine changes the Julian day from 365(6 if leap yr)
								;    to 1 and increases the year, if necessary.
@/home/franceja/IDL_files/kdate			; gives back kmn,kdy information from the Julian day #.
@/home/franceja/IDL_files/rd_ukmo_nc3			; reads the data from nc3 files
@/home/franceja/IDL_files/date2uars			; This code returns the UARS day given (jday,year) information.
@/home/franceja/IDL_files/plotPosition		; defines positions for n number of plots
@/home/franceja/IDL_files/pv2elat
@/home/franceja/IDL_files/sf2elat




;-----------Determine the range of days and set up the counter for the date----------------------

lstdy = 8L
lstmn = 8L
lstyr = 4L
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
days = 3600L
;read,' Enter number of days  ', days
;  set endday equal to startday so for each plot, only one day is plotted, for each elements of 'days'
ledmn = lstmn
leddy = lstdy
ledyr = lstyr

doy = fltarr(days)
idoy = 1L


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
dates = strarr(days)

dirMLS='/Users/franceja/MLS_data/Datfiles_grid/'

djfdate = 0L

FOR iii = 0L, days - 1L DO BEGIN


sys1 = SYSTIME( /JULIAN)


if iii gt 0L then begin

  startday = startday + 1L
  endday = endday + 1L
  caldat, startday, lstmn, lstdy, lstyr
  lstyr = lstyr - 2000L
  ledmn = lstmn
  leddy = lstdy
  ledyr = lstyr
  print, lstyr, ledmn, leddy
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
  doy = string(Format='(I03)',iday)
  ifile = string(syr+smn+sdy)
  ;----------------------------------------------
dates[iii] = ifile

ifiles=file_search(dirMLS+'MLS_T_grid5_v3.3_'+ifile+'.sav',count=nfile)
if ifiles[0] eq '' then begin
	print, 'NO DATA -- ',ifile
	continue
endif
restore, ifiles
;
; read daily file
;

n_lat = n_elements(lat)
n_lon = n_elements(lon)
n_levels    = n_elements(altitude)





if iii eq 0L then begin
	meandailyProfile = fltarr(days,n_lon,n_elements(altitude))
	strdates = strarr(120L)
	dateSeries = findgen(120L) + 1L
	tempSeries = fltarr(n_elements(dateSeries),n_elements(lon), n_elements(altitude))
	tday = 0L
	mode = 0L
endif

if imn eq 11L and idy eq 1L then begin

	smoothtemp = tempseries*!values.f_nan
	x = where(tempseries le 0. or tempseries gt 1000.,nx)
	if nx gt 0L then tempseries[x] = !values.f_nan

	save, filename = '/Users/franceja/France_et_al_2014/Post_process/MLS_timeseries_SH_'+syr+'.sav', lon,tempseries, dateseries, altitude, strdates, smoothtemp
	strdates = strarr(181L)
	dateSeries = findgen(181L) + 1L
	if iyr mod 4 eq 3L then begin
		strdates = strarr(182L)
		dateSeries = findgen(182L) + 1L		
	endif
	tempSeries = fltarr(n_elements(dateSeries),n_elements(lon), n_elements(altitude))
	tday = 0L
	mode = 0L
endif
if imn eq 5L and idy eq 1L then begin


	save, filename = '/Users/franceja/France_et_al_2014/Post_process/MLS_timeseries_NH_'+syr+'.sav', lon,tempseries, dateseries, altitude, strdates, smoothtemp
	strdates = strarr(184L)
	dateSeries = findgen(184L) + 1L
	tempSeries = fltarr(n_elements(dateSeries),n_elements(lon), n_elements(altitude))
	tday = 0L
	mode = 1L
endif

x = where(t_grid le 100. and t_grid gt 600.,nx)
if nx gt 0L then t_grid[x] = !values.f_nan
if mode eq 0L then lat75 = where(lat ge 70. and lat le 88.75)
if mode eq 1L then lat75 = where(lat le -70. and lat ge -88.75)
latweight = SQRT(COS(!DtoR*abs(lat[lat75])))
for kk = 0L, n_elements(altitude) - 1L do begin
	for jj = 0L, n_elements(lon) - 1L do begin
			temp = reform(t_grid[jj,lat75,kk])
			latweights = temp*0.	
			for i = 0L, n_elements(lat75) - 1L do latweights[i,*] = latweight[i]
			x = where(temp gt 100. and temp lt 600.,nx)
			if nx gt 0L then tempSeries[tday,jj,kk] = TOTAL(latweights[x]*temp[x],/nan)/total(latweights[x],/nan)
	endfor
endfor
strdates[tday] = '20' + ifile
meandailyProfile[iii,*,*] = reform(tempseries[tday,*,*])
print, max(meandailyprofile[iii,*,*],/nan)
tday = tday + 1L
print, iii
endfor

save, filename = '/Users/franceja/France_et_al_2014/Post_process/MLS_Dailymean_lat_weight_profile_70-90N.sav',dates, meandailyprofile, altitude,lon

end