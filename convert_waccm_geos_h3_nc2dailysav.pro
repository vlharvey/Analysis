;
; netcdf wcm_geos_50-60km_daily_2x_0.1rlx.cam2.h3.2004-01-02-00000 {
; dimensions:
;        lat = 96 ;
;        lon = 144 ;
;        lev = 88 ;
;        time = UNLIMITED ; // (30 currently)
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
;        int date(time) ;
;                date:long_name = "current date (YYYYMMDD)" ;
;        float OMEGA(time, lev, lat, lon) ;
;                OMEGA:units = "Pa/s" ;
;                OMEGA:long_name = "Vertical velocity (pressure)" ;
;        float PS(time, lat, lon) ;
;                PS:units = "Pa" ;
;                PS:long_name = "Surface pressure" ;
;        float PSL(time, lat, lon) ;
;                PSL:units = "Pa" ;
;                PSL:long_name = "Sea level pressure" ;
;        float T(time, lev, lat, lon) ;
;                T:units = "K" ;
;                T:long_name = "Temperature" ;
;        float U(time, lev, lat, lon) ;
;                U:units = "m/s" ;
;                U:long_name = "Zonal wind" ;
;        float V(time, lev, lat, lon) ;
;                V:units = "m/s" ;
;                V:long_name = "Meridional wind" ;
;        float Z3(time, lev, lat, lon) ;
;                Z3:units = "m" ;
;                Z3:long_name = "Geopotential Height (above sea level)" ;
;
dir='/aura7/harvey/WACCM_data/Datfiles/Datfiles_GEOS/'
spawn,'ls '+dir+'*.nc',ncfiles
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
        if result.name eq 'U' then u_all=data			; Zonal Wind
        if result.name eq 'V' then v_all=data			; Meridional Wind
        if result.name eq 'OMEGA' then w_all=data		; Vertical Wind
        print,'min/max ',result.name,min(data),max(data)
    endfor
    ncdf_close,ncid
;
; create comment for data users
;
    comment=strarr(6)
    comment(0)='date  = YYYYMMDD'
    comment(1)='temp  = Temperature (K)'
    comment(2)='ghgt  = Geopotential Height above sea level (m)'
    comment(3)='u = Zonal Wind (m/s)'
    comment(4)='v = Meridional Wind (m/s)'
    comment(5)='w = Vertical Wind (Pa/s)'
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
        u=reform(u_all(*,*,*,n))
        v=reform(v_all(*,*,*,n))
        w=reform(w_all(*,*,*,n))
        result=strsplit(ncfile,'/',/extract)
        result2=strsplit(result(5),'.',/extract)
        ofile=dir+result2(0)+'.'+result2(1)+'.'+result2(2)+'.'+sdate_all(n)+'.sav'
        print,ofile
        save,file=ofile,time,date,longitude,latitude,pressure,temp,ghgt,u,v,w,comment
    endfor	; loop over days in file
endfor		; loop over netCDF files
end
