;
; "h3" files are daily 3-D WACCM output
;
; read T, U, V, Z, Psfc, Pslv data from "h3" netcdf files in 
; /aura7/harvey/WACCM_data/Datfiles/Aurora and save in IDL save format
;
; dimensions:
;        lat = 46 ;
;        lon = 72 ;
;        lev = 66 ;
;        time = UNLIMITED ; // (20 currently)
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
;        double lev(lev) ;
;                lev:long_name = "hybrid level at midpoints (1000*(A+B))" ;
;                lev:units = "level" ;
;                lev:positive = "down" ;
;                lev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate" ;
;                lev:formula_terms = "a: hyam b: hybm p0: P0 ps: PS" ;
;        double time(time) ;
;                time:long_name = "time" ;
;                time:units = "days since 2025-01-01 00:00:00" ;
;                time:calendar = "noleap" ;
;                time:bounds = "time_bnds" ;
;       int date(time) ;
;               date:long_name = "current date (YYYYMMDD)" ;
;       float PS(time, lat, lon) ;
;               PS:units = "Pa" ;
;               PS:long_name = "Surface pressure" ;
;               PS:cell_method = "time: mean" ;
;       float PSL(time, lat, lon) ;
;               PSL:units = "Pa" ;
;               PSL:long_name = "Sea level pressure" ;
;               PSL:cell_method = "time: mean" ;
;       float T(time, lev, lat, lon) ;
;               T:units = "K" ;
;               T:long_name = "Temperature" ;
;               T:cell_method = "time: mean" ;
;       float U(time, lev, lat, lon) ;
;               U:units = "m/s" ;
;               U:long_name = "Zonal wind" ;
;               U:cell_method = "time: mean" ;
;       float V(time, lev, lat, lon) ;
;               V:units = "m/s" ;
;               V:long_name = "Meridional wind" ;
;               V:cell_method = "time: mean" ;
;       float Z3(time, lev, lat, lon) ;
;               Z3:units = "m" ;
;               Z3:long_name = "Geopotential Height (above sea level)" ;
;               Z3:cell_method = "time: mean" ;
;
dir='/aura7/harvey/WACCM_data/Datfiles/Aurora/'
spawn,'ls '+dir+'waccm319_8_smax*.h3.*.nc',ncfiles
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
        if result.name eq 'time' then time_all=data		; days since 2025-01-01
        if result.name eq 'date' then date_all=data		; YYYYMMDD
        if result.name eq 'PS' then psfc_all=data/100.		; Surface pressure (Pa) (time, lat, lon)
        if result.name eq 'T' then temp_all=data		; Temperature (K) (time, lev, lat, lon)
        if result.name eq 'U' then uwind_all=data		; Zonal wind (m/s) (time, lev, lat, lon)
        if result.name eq 'V' then vwind_all=data		; Meridional wind (m/s) (time, lev, lat, lon)
        if result.name eq 'Z3' then ghgt_all=data		; Geopotential Height (above sea level) (m) (time, lev, lat, lon)
;       print,'min/max ',result.name,min(data),max(data)
    endfor
    ncdf_close,ncid
;
; create comment for data users
;
    comment=strarr(6)
    comment(0)='time  = days since 1995-01-01 00:00:00'
    comment(1)='psfc  = Surface pressure (hPa)'
    comment(2)='temp  = Temperature (K)'
    comment(3)='uwind = Zonal wind (m/s)'
    comment(4)='vwind = Meridional wind (m/s)'
    comment(5)='ghgt  = Geopotential Height above sea level (m)'
;
; daily IDL save files
;
    sdate_all=strcompress(date_all,/remove_all)
    print,ncfile
    for n=0L,ntime-1L do begin
        date=date_all(n)
        time=time_all(n)
        psfc=reform(psfc_all(*,*,n))
        temp=reform(temp_all(*,*,*,n))
        uwind=reform(uwind_all(*,*,*,n))
        vwind=reform(vwind_all(*,*,*,n))
        ghgt=reform(ghgt_all(*,*,*,n))
        result=strsplit(ncfile,'/',/extract)
        result2=strsplit(result(5),'.',/extract)
        ofile=dir+result2(0)+'.'+result2(1)+'.'+result2(2)+'.'+sdate_all(n)+'.sav'
        print,ofile
        save,file=ofile,time,date,longitude,latitude,pressure,psfc,temp,uwind,vwind,ghgt,comment
    endfor	; loop over days in file
endfor		; loop over netCDF files
end
