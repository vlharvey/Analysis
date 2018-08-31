;
; read T, Z data from "h3" netcdf files in 
; /aura7/harvey/WACCM_data/Datfiles/Datfiles_Mills/mee01fco and save in IDL save format
;
; dimensions:
;        time = UNLIMITED ; // (360 currently)
;        lev = 66 ;
;        ilev = 67 ;
;        lat = 46 ;
;        lon = 72 ;
;variables:
;        double lev(lev) ;
;                lev:long_name = "hybrid level at midpoints (1000*(A+B))" ;
;                lev:units = "level" ;
;                lev:positive = "down" ;
;                lev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate" ;
;                lev:formula_terms = "a: hyam b: hybm p0: P0 ps: PS" ;
;        double lat(lat) ;
;                lat:long_name = "latitude" ;
;                lat:units = "degrees_north" ;
;        double lon(lon) ;
;                lon:long_name = "longitude" ;
;                lon:units = "degrees_east" ;
;        double time(time) ;
;                time:bounds = "time_bnds" ;
;                time:calendar = "noleap" ;
;                time:units = "days since 2025-01-01 00:00:00" ;
;                time:long_name = "time" ;
;        int date(time) ;
;                date:long_name = "current date (YYYYMMDD)" ;
;        float T(time, lev, lat, lon) ;
;                T:cell_method = "time: mean" ;
;                T:long_name = "Temperature" ;
;                T:units = "K" ;
;        float Z3(time, lev, lat, lon) ;
;                Z3:cell_method = "time: mean" ;
;                Z3:long_name = "Geopotential Height (above sea level)" ;
;                Z3:units = "m" ;
;
dir='/aura7/harvey/WACCM_data/Datfiles/Datfiles_Mills/mee01fco/'
spawn,'ls '+dir+'mee01fco.vars.h3.20*.nc',ncfiles
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
        print,'read ',name,' dimension ',dim
    endfor
    for ivar=0,result0.nvars-1 do begin
        result=ncdf_varinq(ncid,ivar)
        if result.name ne 'PS' and result.name ne 'PSL' and $
           result.name ne 'NOX' and result.name ne 'QSUM' $
                  then ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
        if result.name eq 'lat' then latitude=data
        if result.name eq 'lon' then longitude=data
        if result.name eq 'lev' then pressure=data
        if result.name eq 'time' then time_all=data		; days since 2025-01-01
        if result.name eq 'date' then date_all=data		; YYYYMMDD
        if result.name eq 'T' then temp_all=data		; Temperature (K) (time, lev, lat, lon)
        if result.name eq 'Z3' then ghgt_all=data		; Geopotential Height (above sea level) (m)
        if result.name eq 'O3' then o3_all=data			; Ozone (mol/mol)
        print,'min/max ',result.name,min(data),max(data)
    endfor
    ncdf_close,ncid
;
; create comment for data users
;
    comment=strarr(4)
    comment(0)='time  = days since 2025-01-01 00:00:00'
    comment(1)='temp  = Temperature (K)'
    comment(2)='ghgt  = Geopotential Height above sea level (m)'
    comment(3)='ozone = Ozone (mol/mol)'
;
; daily IDL save files
;
    sdate_all=strcompress(date_all,/remove_all)
    print,ncfile
    for n=0L,ntime-1L do begin
        time=time_all(n)
        date=date_all(n)
        temp=reform(temp_all(*,*,*,n))
        ghgt=reform(ghgt_all(*,*,*,n))
        o3=reform(o3_all(*,*,*,n))
        result=strsplit(ncfile,'/',/extract)
        result2=strsplit(result(6),'.',/extract)
        ofile=dir+result2(0)+'.'+result2(1)+'.'+result2(2)+'.'+sdate_all(n)+'.sav'
        print,ofile
        save,file=ofile,time,date,longitude,latitude,pressure,temp,ghgt,o3,comment
    endfor	; loop over days in file
endfor		; loop over netCDF files
end
