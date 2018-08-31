;
; read WACCM netcdf data with the following variables from ncdump -h
;
; dimensions:
;        lat = 46 ;
;        lon = 72 ;
;        slat = 45 ;
;        slon = 72 ;
;        lev = 66 ;
;        ilev = 67 ;
;        isccp_prs = 7 ;
;        isccp_tau = 7 ;
;        isccp_prstau = 49 ;
;        time = UNLIMITED ; // (60 currently)
;        tbnd = 2 ;
;        chars = 8 ;
;
; variables:
;        double P0 ;
;                P0:long_name = "reference pressure" ;
;                P0:units = "Pa" ;
;        double lat(lat) ;
;                lat:long_name = "latitude" ;
;                lat:units = "degrees_north" ;
;        double lon(lon) ;
;                lon:long_name = "longitude" ;
;                lon:units = "degrees_east" ;
;        double slat(slat) ;
;                slat:long_name = "staggered latitude" ;
;                slat:units = "degrees_north" ;
;        double slon(slon) ;
;                slon:long_name = "staggered longitude" ;
;                slon:units = "degrees_east" ;
;        double w_stag(slat) ;
;                w_stag:long_name = "staggered latitude weights" ;
;        double lev(lev) ;
;                lev:long_name = "hybrid level at midpoints (1000*(A+B))" ;
;                lev:units = "level" ;
;                lev:positive = "down" ;
;                lev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate" ;
;                lev:formula_terms = "a: hyam b: hybm p0: P0 ps: PS" ;
;        double ilev(ilev) ;
;                ilev:long_name = "hybrid level at interfaces (1000*(A+B))" ;
;                ilev:units = "level" ;
;                ilev:positive = "down" ;
;                ilev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate" ;
;                ilev:formula_terms = "a: hyai b: hybi p0: P0 ps: PS" ;
;        double isccp_prs(isccp_prs) ;
;                isccp_prs:long_name = "Mean ISCCP pressure" ;
;                isccp_prs:units = "mb" ;
;                isccp_prs:isccp_prs_bnds = 0., 180., 310., 440., 560., 680., 800., 1000. ;
;        double isccp_tau(isccp_tau) ;
;                isccp_tau:long_name = "Mean ISCCP optical depth" ;
;                isccp_tau:units = "unitless" ;
;                isccp_tau:isccp_tau_bnds = 0., 0.3, 1.3, 3.6, 9.4, 23., 60., 379. ;
;        double isccp_prstau(isccp_prstau) ;
;                isccp_prstau:long_name = "Mean pressure (mb).mean optical depth (unitless)/1000" ;
;                isccp_prstau:units = "mixed" ;
;        double time(time) ;
;                time:long_name = "time" ;
;                time:units = "days since 1975-01-01 00:00:00" ;
;                time:calendar = "noleap" ;
;                time:bounds = "time_bnds" ;
;        double time_bnds(time, tbnd) ;
;                time_bnds:long_name = "time interval endpoints" ;
;        char date_written(time, chars) ;
;        char time_written(time, chars) ;
;        long ntrm ;
;                ntrm:long_name = "spectral truncation parameter M" ;
;        long ntrn ;
;                ntrn:long_name = "spectral truncation parameter N" ;
;        long ntrk ;
;                ntrk:long_name = "spectral truncation parameter K" ;
;        long ndbase ;
;                ndbase:long_name = "base day" ;
;        long nsbase ;
;                nsbase:long_name = "seconds of base day" ;
;        long nbdate ;
;                nbdate:long_name = "base date (YYYYMMDD)" ;
;        long nbsec ;
;                nbsec:long_name = "seconds of base date" ;
;        long mdt ;
;                mdt:long_name = "timestep" ;
;                mdt:units = "s" ;
;        long nlon(lat) ;
;                nlon:long_name = "number of longitudes" ;
;        long wnummax(lat) ;
;                wnummax:long_name = "cutoff Fourier wavenumber" ;
;        double hyai(ilev) ;
;                hyai:long_name = "hybrid A coefficient at layer interfaces" ;
;        double hybi(ilev) ;
;                hybi:long_name = "hybrid B coefficient at layer interfaces" ;
;        double hyam(lev) ;
;                hyam:long_name = "hybrid A coefficient at layer midpoints" ;
;        double hybm(lev) ;
;                hybm:long_name = "hybrid B coefficient at layer midpoints" ;
;        double gw(lat) ;
;                gw:long_name = "gauss weights" ;
;        long ndcur(time) ;
;                ndcur:long_name = "current day (from base day)" ;
;        long nscur(time) ;
;                nscur:long_name = "current seconds of current day" ;
;        long date(time) ;
;                date:long_name = "current date (YYYYMMDD)" ;
;        double co2vmr(time) ;
;                co2vmr:long_name = "co2 volume mixing ratio" ;
;        long datesec(time) ;
;                datesec:long_name = "current seconds of current date" ;
;        long nsteph(time) ;
;                nsteph:long_name = "current timestep" ;
;        float MSKtem(time, lat, lon) ;
;                MSKtem:units = "unitless" ;
;                MSKtem:long_name = "TEM mask" ;
;        float N2D(time, lev, lat, lon) ;
;                N2D:units = "mol/mol" ;
;                N2D:long_name = "N(2D)" ;
;        float NO(time, lev, lat, lon) ;
;                NO:units = "mol/mol" ;
;                NO:long_name = "NO" ;
;        float O(time, lev, lat, lon) ;
;                O:units = "mol/mol" ;
;                O:long_name = "O" ;
;        float O2(time, lev, lat, lon) ;
;                O2:units = "mol/mol" ;
;                O2:long_name = "O2" ;
;        float PS(time, lat, lon) ;
;                PS:units = "Pa" ;
;                PS:long_name = "Surface pressure" ;
;        float QRS_TOT(time, lev, lat, lon) ;
;                QRS_TOT:units = "K/s" ;
;                QRS_TOT:long_name = "Merged SW heating: QRS+QCP+QRS_EUV+QRS_CO2NIR+QRS_AUR+QTHERMAL" ;
;        float T(time, lev, lat, lon) ;
;                T:units = "K" ;
;                T:long_name = "Temperature" ;
;        float TH(time, ilev, lat, lon) ;
;                TH:units = "K" ;
;                TH:long_name = "Potential Temperature" ;
;        float UV2d(time, lat, lon) ;
;                UV2d:units = "M2/S2" ;
;                UV2d:long_name = "Meridional Flux of Zonal Momentum: 2D prj of zon. mean" ;
;        float UW2d(time, lat, lon) ;
;                UW2d:units = "M2/S2" ;
;                UW2d:long_name = "Vertical Flux of Zonal Momentum; 2D prj of zon. mean" ;
;        float VTH2d(time, lat, lon) ;
;                VTH2d:units = "MK/S" ;
;                VTH2d:long_name = "Meridional Heat Flux: 2D prj of zon. mean" ;
;        float WTH2d(time, lat, lon) ;
;                WTH2d:units = "MK/S" ;
;                WTH2d:long_name = "Vertical Heat Flux: 2D prj of zon. mean" ;
;        float Z3(time, lev, lat, lon) ;
;                Z3:units = "m" ;
;                Z3:long_name = "Geopotential Height (above sea level)" ;
;
dir='/aura6/data/WACCM_data/Datfiles/'
spawn,'ls '+dir+'*nc',ncfiles
nfile=n_elements(ncfiles)
for ifile=0L,nfile-1L do begin

ncfile=ncfiles(ifile)
print,'opening '+ncfile
ncid=ncdf_open(ncfile)
result0=ncdf_inquire(ncid)
for idim=0,result0.ndims-1 do begin
    ncdf_diminq,ncid,idim,name,dim
    if name eq 'lon' then nlon=dim
    if name eq 'lat' then nlat=dim
    if name eq 'lev' then nlev=dim
    if name eq 'time' then ntime=dim
;   print,'read ',name,' dimension ',dim
endfor
for ivar=0,result0.nvars-1 do begin
    result=ncdf_varinq(ncid,ivar)
    ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
    if result.name eq 'lat' then latitude=data
    if result.name eq 'lon' then longitude=data
    if result.name eq 'lev' then pressure=data
    if result.name eq 'time' then time=data		; days since 1/1/1975
    if result.name eq 'date' then date=data		; YYYYMMDD
    if result.name eq 'co2vmr' then co2vmr1=data	; CO2 volume mixing ratio
    if result.name eq 'mdt' then model_timestep=data	; model timestep
    if result.name eq 'N2D' then n2d1=data		; N(2D)    (mol/mol)  (time, lev, lat, lon)
    if result.name eq 'NO' then no1=data		; NO       (mol/mol)  (time, lev, lat, lon)
    if result.name eq 'O' then o1=data			; O        (mol/mol)  (time, lev, lat, lon)
    if result.name eq 'O2' then o21=data		; O2       (mol/mol)  (time, lev, lat, lon)
    if result.name eq 'QRS_TOT' then sw_heat1=data	; SW heating (K/s)    (time, lev, lat, lon)
    if result.name eq 'T' then temp1=data		; Temp       (K)      (time, lev, lat, lon)
    if result.name eq 'UV2d' then uv2d1=data		; N/S flux U mom (m2/s2) (time, lat, lon)
    if result.name eq 'UW2d' then uw2d1=data		; Ver flux U mom (m2/s2) (time, lat, lon) 
    if result.name eq 'VTH2d' then vth2d1=data		; N/S heat flux  (mK/s)  (time, lat, lon)
    if result.name eq 'WTH2d' then wth2d1=data		; Ver heat flux  (mK/s)  (time, lat, lon)
    if result.name eq 'Z3' then z31=data		; Geop. Height   (m)  (time, lev, lat, lon)
;   print,ivar,result.name,min(data),max(data)
endfor
ncdf_close,ncid
;
; convert time to hours
;
time=(time-fix(time))*24.
;
; create comment for data users
;
comment=strarr(14)
comment(0) ='n2d            = N(2D) (mol/mol)'
comment(1) ='no             = NO (mol/mol)'
comment(2) ='o              = O (mol/mol)'
comment(3) ='o2             = O2 (mol/mol)'
comment(4) ='sw_heat        = Merged SW heating: QRS+QCP+QRS_EUV+QRS_CO2NIR+QRS_AUR+QTHERMAL (K/s)'
comment(5) ='temp           = Temperature (K)'
comment(6) ='uv2d           = Meridional Flux of Zonal Momentum: 2D prj of zon. mean (m2/s2)'
comment(7) ='uw2d           = Vertical Flux of Zonal Momentum; 2D prj of zon. mean (m2/s2)'
comment(8) ='vth2d          = Meridional Heat Flux: 2D prj of zon. mean (mK/s)'
comment(9) ='wth2d          = Vertical Heat Flux: 2D prj of zon. mean (mK/s)'
comment(10)='z3             = Geopotential Height (above sea level) (m)'
comment(11)='co2vmr         = CO2 volume mixing ratio'
comment(12)='model_timestep = model timestep (s)'
comment(13)='Fill value     = 1.e+35'
;
; IDL save file for each output time
;
for n=0L,ntime-1L do begin
    sdate=strcompress(date(n),/remove_all)
    stime=string(format='(i2.2)',fix(time(n)))+'Z'
    ofile='/aura6/data/WACCM_data/Datfiles/'+sdate+'_'+stime+'.sav'
    print,ofile
    co2vmr=co2vmr1(n)
    n2d=reform(n2d1(*,*,*,n))
    no=reform(no1(*,*,*,n))
    o=reform(o1(*,*,*,n))
    o2=reform(o21(*,*,*,n))
    sw_heat=reform(sw_heat1(*,*,*,n))
    temp=reform(temp1(*,*,*,n))
    uv2d=reform(uv2d1(*,*,n))
    uw2d=reform(uw2d1(*,*,n))
    vth2d=reform(vth2d1(*,*,n))
    wth2d=reform(wth2d1(*,*,n))
    z3=reform(z31(*,*,*,n))
    save,file=ofile,longitude,latitude,pressure,n2d,co2vmr,no,o,o2,$
         sw_heat,temp,uv2d,uw2d,vth2d,wth2d,z3,model_timestep,comment
endfor	; loop over output times
endfor	; loop over monthly netCDF files
end
