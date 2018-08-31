;
; read NO, NO2, N2O, HNO3, CO, CH4, O3, T, Z data from "h1" netcdf files in 
; /aura7/harvey/WACCM_data/Datfiles/NoAur and save in IDL save format
;
; dimensions:
;        lat = 46 ;
;        lon = 72 ;
;        lev = 66 ;
;        time = UNLIMITED ; // (10 currently)
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
;
dir='/aura7/harvey/WACCM_data/Datfiles/Noaur/'
spawn,'ls '+dir+'wa319_9_smax_noaur.cam2.h1.*.nc',ncfiles
nfile=n_elements(ncfiles)
for ifile=0L,nfile-1L do begin
    snum=string(format='(i2.2)',ifile+1)
    ncfile=ncfiles(ifile)
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
        if result.name eq 'PS' then psfc_all=data/100.      ; surface pressure
        if result.name eq 'NO' then no_all=data             ; NO       (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'NO2' then no2_all=data           ; NO2       (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'N2O' then n2o_all=data           ; N2O       (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'CO' then co_all=data             ; CO       (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'CH4' then ch4_all=data           ; CH4      (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'HNO3' then hno3_all=data         ; HNO3      (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'O3' then o3_all=data             ; O3      (mol/mol)  (time, lev, lat, lon)
        if result.name eq 'T' then temp_all=data            ; Temp       (K)      (time, lev, lat, lon)
        if result.name eq 'Z3' then ghgt_all=data             ; Geop. Height   (m)  (time, lev, lat, lon)
;       print,'min/max ',result.name,min(data),max(data)
    endfor
    ncdf_close,ncid
;
; create comment for data users
;
    comment=strarr(10)
    comment(0)='time = days since 2025-01-01'
    comment(1)='no   = NO (mol/mol)'
    comment(2)='no2  = NO2 (mol/mol)'
    comment(3)='n2o  = N2O (mol/mol)'
    comment(4)='co   = CO (mol/mol)'
    comment(5)='ch4  = CH4 (mol/mol)'
    comment(6)='hno3 = HNO3 (mol/mol)'
    comment(7)='o3   = O3 (mol/mol)'
    comment(8)='temp = Temperature (K)'
    comment(9)='ghgt = Geopotential Height (above sea level) (m)'
;
; daily IDL save files
;
    sdate_all=strcompress(date_all,/remove_all)
    print,ncfile
    for n=0L,ntime-1L do begin
        sdate=sdate_all(n)
        time=time_all(n)
        psfc=reform(psfc_all(*,*,n))
        no=reform(no_all(*,*,*,n))
        no2=reform(no2_all(*,*,*,n))
        n2o=reform(n2o_all(*,*,*,n))
        co=reform(co_all(*,*,*,n))
        ch4=reform(ch4_all(*,*,*,n))
        hno3=reform(hno3_all(*,*,*,n))
        o3=reform(o3_all(*,*,*,n))
        temp=reform(temp_all(*,*,*,n))
        ghgt=reform(ghgt_all(*,*,*,n))
        result=strsplit(ncfile,'/',/extract)
        result2=strsplit(result(5),'.',/extract)
        ofile=dir+result2(0)+'.'+result2(1)+'.'+result2(2)+'.'+sdate+'.sav'
        print,ofile
        save,file=ofile,longitude,latitude,pressure,psfc,time,no,no2,n2o,co,ch4,hno3,o3,temp,ghgt,comment
    endfor      ; loop over days in file
endfor	; loop over netCDF files
end
