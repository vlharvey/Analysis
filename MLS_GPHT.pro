;put SABER onto HIRDLS pressure grid and convert to GPHT

restore, '/Volumes/MacD68-1/france/HIRDLS_data/Datfiles/HIRDLS2ALL_v06-00.2006d001.sav'

@/Volumes/MacD68-1/france/idl_files/readl2gp_std
mls_path='/Volumes/MacD68-1/france/MLS_data/Datfiles/'
output_path='/Volumes/MacD68-1/france/MLS_data/Datfiles/'
idl_path='/Volumes/MacD68-1/france/idl_files/'

;;; time range

start_date='20060101'

end_date='20060301'

ndays=julday(strmid(end_date,4,2),strmid(end_date,6,2),strmid(end_date,0,4)) - $ 
julday(strmid(start_date,4,2),strmid(start_date,6,2),strmid(start_date,0,4)) +1
current_date = start_date
start_julday = julday(strmid(start_date,4,2),strmid(start_date,6,2),strmid(start_date,0,4))
;;; day loop
for iday=0,ndays-1 do begin
;
s0=systime(1)
 ;prepare date variables
current_julday = start_julday + iday
caldat, current_julday, month, day, year
current_doy = current_julday-julday(1,1,year)+1
str_year = strcompress(string(year),/r)
str_date_code = str_year+'d'+strcompress(string(current_doy,format='(i3.3)'),/r)
 print, 'Starting '+str_date_code+' !!!'
 ;read MLS T
 file=mls_path+'MLS-Aura_L2GP-Temperature_v03-30-c01_'+str_date_code+'-c01.he5'
    spawn, 'ls ' + file, nfiles
 if nfiles eq '' then begin
   print, '   NO DATA ON '+str_date_code
 continue
 endif
 data=readl2gp_std(file)
 value=data.l2gpvalue
 status=transpose(rebin(data.status,data.ntimes,data.nlevels))
 quality=transpose(rebin(data.quality,data.ntimes,data.nlevels))
 convergence=transpose(rebin(data.convergence,data.ntimes,data.nlevels))
 pressure=rebin(data.pressure,data.nlevels,data.ntimes)
 GPH = data.ml2gph
 
 err=100.*abs(data.l2gpprecision)/abs(data.l2gpvalue)
 
 print, '   MLS data read.'

 
 
 
 ;screen T
 
 index=where(data.l2gpprecision le 0 or (status and 1) or quality le .6 or convergence gt 1.2 ,nindex) ;only for temperature !!!
 
 if nindex ne 0 then value[index]=!values.f_nan
 
 index=where(pressure gt 316 or pressure lt .001,nindex) ;only for temperature !!!
 
 if nindex ne 0 then value[index]=!values.f_nan
 
 index=where(err gt 100,nindex)
 
 if nindex ne 0 then value[index]=!values.f_nan

 
 
 
 ;store T
 
 mls_t=value
 
 ntimes=data.ntimes
 
 mls_lon=data.longitude
 
 mls_lon[where(mls_lon lt 0)]=360.+mls_lon[where(mls_lon lt 0)]
 
 index=where(mls_lon lt 0 or mls_lon gt 360,nindex)
 
 if nindex ne 0 then mls_lon[index]=!values.f_nan
 
 mls_lat=data.latitude
 
 index=where(mls_lat lt -90 or mls_lat gt 90,nindex)
stop 
 if nindex ne 0 then mls_lat[index]=!values.f_nan
;Read GPHT
 file=mls_path+'MLS-Aura_L2GP-GPH_v03-30-c01_'+str_date_code+'-c01.he5'
    spawn, 'ls ' + file, nfiles
 if nfiles eq '' then begin
   print, '   NO DATA ON '+str_date_code
 continue
  endif
  data=readl2gp_std(file)
  value=data.l2gpvalue
stop
  endfor
  
  end