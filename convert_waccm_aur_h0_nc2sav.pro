;
; "aurora" run
; save a subset (T, Z, Psfc, NO, NO2, N2O, O3, HNO3, CH4, CO) of WACCM monthly mean netcdf data for Cora's group
;
; dimensions:
;       lat = 46 ;
;       lon = 72 ;
;       lev = 66 ;
;       time = UNLIMITED ; // (1 currently)
;
; variables:
;       double P0 ;
;               P0:long_name = "reference pressure" ;
;               P0:units = "Pa" ;
;       double lat(lat) ;
;               lat:long_name = "latitude" ;
;               lat:units = "degrees_north" ;
;       double lon(lon) ;
;               lon:long_name = "longitude" ;
;               lon:units = "degrees_east" ;
;       double lev(lev) ;
;               lev:long_name = "hybrid level at midpoints (1000*(A+B))" ;
;               lev:units = "level" ;
;               lev:positive = "down" ;
;               lev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate" ;
;               lev:formula_terms = "a: hyam b: hybm p0: P0 ps: PS" ;
;       double time(time) ;
;               time:long_name = "time" ;
;               time:units = "days since 1975-01-01 00:00:00" ;
;               time:calendar = "noleap" ;
;               time:bounds = "time_bnds" ;
;       float CH4(time, lev, lat, lon) ;
;               CH4:units = "mol/mol" ;
;               CH4:long_name = "CH4" ;
;               CH4:cell_method = "time: mean" ;
;       float CO(time, lev, lat, lon) ;
;               CO:units = "mol/mol" ;
;               CO:long_name = "CO" ;
;               CO:cell_method = "time: mean" ;
;       float HNO3(time, lev, lat, lon) ;
;               HNO3:units = "mol/mol" ;
;               HNO3:long_name = "HNO3" ;
;               HNO3:cell_method = "time: mean" ;
;       float NO(time, lev, lat, lon) ;
;               NO:units = "mol/mol" ;
;               NO:long_name = "NO" ;
;               NO:cell_method = "time: mean" ;
;       float N2O(time, lev, lat, lon) ;
;               N2O:units = "mol/mol" ;
;               N2O:long_name = "N2O" ;
;               N2O:cell_method = "time: mean" ;
;       float NO2(time, lev, lat, lon) ;
;               NO2:units = "mol/mol" ;
;               NO2:long_name = "NO2" ;
;               NO2:cell_method = "time: mean" ;
;       float O3(time, lev, lat, lon) ;
;               O3:units = "mol/mol" ;
;               O3:long_name = "O3" ;
;               O3:cell_method = "time: mean" ;
;       float PS(time, lat, lon) ;
;               PS:units = "Pa" ;
;               PS:long_name = "Surface pressure" ;
;               PS:cell_method = "time: mean" ;
;       float T(time, lev, lat, lon) ;
;               T:units = "K" ;
;               T:long_name = "Temperature" ;
;               T:cell_method = "time: mean" ;
;       float Z3(time, lev, lat, lon) ;
;               Z3:units = "m" ;
;               Z3:long_name = "Geopotential Height (above sea level)" ;
;               Z3:cell_method = "time: mean" ;
;
dir='/aura7/harvey/WACCM_data/Datfiles/Aurora/'
spawn,'ls '+dir+'waccm319_8_smax*.h0.*nc',ncfiles
nfile=n_elements(ncfiles)
for ifile=0L,nfile-1L do begin
    snum=string(format='(i2.2)',ifile+1)
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
;       print,'read ',name,' dimension ',dim
    endfor
    for ivar=0,result0.nvars-1 do begin
        result=ncdf_varinq(ncid,ivar)
        ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
        if result.name eq 'lat' then latitude=data
        if result.name eq 'lon' then longitude=data
        if result.name eq 'lev' then pressure=data
        if result.name eq 'date' then date=data			; YYYYMMDD
        if result.name eq 'PS' then psfc_mean=data/100.		; surface pressure
        if result.name eq 'NO' then no_mean=data		; NO       (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'NO2' then no2_mean=data		; NO2       (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'N2O' then n2o_mean=data		; N2O       (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'CO' then co_mean=data		; CO       (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'CH4' then ch4_mean=data		; CH4      (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'HNO3' then hno3_mean=data		; HNO3      (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'O3' then o3_mean=data		; O3      (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'T' then temp_mean=data		; Temp       (K)      (time, lev, lat, lon)
        if result.name eq 'Z3' then ghgt_mean=data		; Geop. Height   (m)  (time, lev, lat, lon)
;       print,ivar,result.name,min(data),max(data)
    endfor
    ncdf_close,ncid
;
; create comment for data users
;
    comment=strarr(9)
    comment(0)='no_mean   = NO (mol/mol)'
    comment(1)='no2_mean  = NO2 (mol/mol)'
    comment(2)='n2o_mean  = N2O (mol/mol)'
    comment(3)='co_mean   = CO (mol/mol)'
    comment(4)='ch4_mean  = CH4 (mol/mol)'
    comment(5)='hno3_mean = HNO3 (mol/mol)'
    comment(6)='o3_mean   = O3 (mol/mol)'
    comment(7)='temp_mean = Temperature (K)'
    comment(8)='ghgt_mean = Geopotential Height (above sea level) (m)'
    result=strsplit(ncfile,'/',/extract)
    result2=strsplit(result(5),'.',/extract)
    ofile=dir+result2(0)+'.'+result2(1)+'.'+result2(2)+'.'+result2(3)+'.sav'
    print,ofile
    save,file=ofile,longitude,latitude,pressure,psfc_mean,no_mean,no2_mean,n2o_mean,co_mean,ch4_mean,$
         hno3_mean,o3_mean,temp_mean,ghgt_mean,comment

endfor	; loop over monthly netCDF files
end
