;
; noaur4 files obtained from run by Mike Mills	6/18/2008
;
; "h3" files are daily 3-D WACCM output, 20 days per nc file
;
; read CO, CH4, O3, NO2, NO, T, U, V, Z, surface pressure, 
; and mean sea level pressure
;
; /aura7/harvey/WACCM_data/Datfiles/Noaur and save in daily
; files in IDL save format
;
;netcdf noaur4.cam2.h3.2054-12-22-00000 {
;dimensions:
;        lat = 46 ;
;        lon = 72 ;
;        slat = 45 ;
;        slon = 72 ;
;        lev = 66 ;
;        ilev = 67 ;
;        isccp_prs = 7 ;
;        isccp_tau = 7 ;
;        isccp_prstau = 49 ;
;        time = UNLIMITED ; // (15 currently)
;        tbnd = 2 ;
;        chars = 8 ;
;variables:
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
;                time:units = "days since 2025-01-01 00:00:00" ;
;                time:calendar = "noleap" ;
;                time:bounds = "time_bnds" ;
;        double time_bnds(time, tbnd) ;
;                time_bnds:long_name = "time interval endpoints" ;
;        char date_written(time, chars) ;
;        char time_written(time, chars) ;
;        int ntrm ;
;                ntrm:long_name = "spectral truncation parameter M" ;
;        int ntrn ;
;                ntrn:long_name = "spectral truncation parameter N" ;
;        int ntrk ;
;                ntrk:long_name = "spectral truncation parameter K" ;
;        int ndbase ;
;                ndbase:long_name = "base day" ;
;        int nsbase ;
;                nsbase:long_name = "seconds of base day" ;
;        int nbdate ;
;                nbdate:long_name = "base date (YYYYMMDD)" ;
;        int nbsec ;
;                nbsec:long_name = "seconds of base date" ;
;        int mdt ;
;                mdt:long_name = "timestep" ;
;                mdt:units = "s" ;
;        int nlon(lat) ;
;                nlon:long_name = "number of longitudes" ;
;        int wnummax(lat) ;
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
;        int ndcur(time) ;
;                ndcur:long_name = "current day (from base day)" ;
;        int nscur(time) ;
;                nscur:long_name = "current seconds of current day" ;
;        int date(time) ;
;                date:long_name = "current date (YYYYMMDD)" ;
;        double co2vmr(time) ;
;                co2vmr:long_name = "co2 volume mixing ratio" ;
;        int datesec(time) ;
;                datesec:long_name = "current seconds of current date" ;
;        int nsteph(time) ;
;                nsteph:long_name = "current timestep" ;
;        float CH4(time, lev, lat, lon) ;
;                CH4:units = "mol/mol" ;
;                CH4:long_name = "CH4" ;
;                CH4:cell_method = "time: mean" ;
;        float CO(time, lev, lat, lon) ;
;                CO:units = "mol/mol" ;
;                CO:long_name = "CO" ;
;                CO:cell_method = "time: mean" ;
;        float MSKtem(time, lat, lon) ;
;                MSKtem:units = "unitless" ;
;                MSKtem:long_name = "TEM mask" ;
;                MSKtem:cell_method = "time: mean" ;
;        float NO(time, lev, lat, lon) ;
;                NO:units = "mol/mol" ;
;                NO:long_name = "NO" ;
;                NO:cell_method = "time: mean" ;
;        float NO2(time, lev, lat, lon) ;
;                NO2:units = "mol/mol" ;
;                NO2:long_name = "NO2" ;
;                NO2:cell_method = "time: mean" ;
;        float O3(time, lev, lat, lon) ;
;                O3:units = "mol/mol" ;
;                O3:long_name = "O3" ;
;                O3:cell_method = "time: mean" ;
;        float PS(time, lat, lon) ;
;                PS:units = "Pa" ;
;                PS:long_name = "Surface pressure" ;
;                PS:cell_method = "time: mean" ;
;        float PSL(time, lat, lon) ;
;                PSL:units = "Pa" ;
;                PSL:long_name = "Sea level pressure" ;
;                PSL:cell_method = "time: mean" ;
;        float T(time, lev, lat, lon) ;
;                T:units = "K" ;
;                T:long_name = "Temperature" ;
;                T:cell_method = "time: mean" ;
;        float U(time, lev, lat, lon) ;
;                U:units = "m/s" ;
;                U:long_name = "Zonal wind" ;
;                U:cell_method = "time: mean" ;
;        float V(time, lev, lat, lon) ;
;                V:units = "m/s" ;
;                V:long_name = "Meridional wind" ;
;                V:cell_method = "time: mean" ;
;        float Z3(time, lev, lat, lon) ;
;                Z3:units = "m" ;
;                Z3:long_name = "Geopotential Height (above sea level)" ;
;                Z3:cell_method = "time: mean" ;
;
dir='/aura7/harvey/WACCM_data/Datfiles/Noaur/'
spawn,'ls '+dir+'noaur4.cam2.h3.*.nc',ncfiles
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
        if result.name eq 'P0' then p0=data
        if result.name eq 'hyai' then hyai=data
        if result.name eq 'hybi' then hybi=data
        if result.name eq 'hyam' then hyam=data
        if result.name eq 'hybm' then hybm=data
        if result.name eq 'lat' then latitude=data
        if result.name eq 'lon' then longitude=data
        if result.name eq 'lev' then lev=data
        if result.name eq 'datesec' then time_all=float(data)/86400.	; current seconds of current date
        if result.name eq 'date' then date_all=data		; YYYYMMDD
        if result.name eq 'PS' then psfc_all=data/100.		; Surface pressure (Pa) (time, lat, lon)
        if result.name eq 'PSL' then pmsl_all=data/100.		; Sea level pressure (Pa) (time, lat, lon)
        if result.name eq 'T' then temp_all=data		; Temperature (K) (time, lev, lat, lon)
        if result.name eq 'U' then uwind_all=data		; Zonal wind (m/s) (time, lev, lat, lon)
        if result.name eq 'V' then vwind_all=data		; Meridional wind (m/s) (time, lev, lat, lon)
        if result.name eq 'Z3' then ghgt_all=data		; Geopotential Height (above sea level) (m) (time, lev, lat, lon)
        if result.name eq 'CH4' then ch4_all=data		; Methane (mol/mol) 
        if result.name eq 'CO' then co_all=data			; Carbon Monoxide (mol/mol)
        if result.name eq 'NO' then no_all=data			; NO (mol/mol)
        if result.name eq 'NO2' then no2_all=data		; NO2 (mol/mol)
        if result.name eq 'O3' then o3_all=data			; Ozone (mol/mol)
        print,'min/max ',result.name,min(data),max(data)
    endfor
    ncdf_close,ncid
;
; create comment for data users
;
    comment=strarr(7)
    comment(0)='time  = days since 2025-01-01 00:00:00'
    comment(1)='psfc  = Surface pressure (hPa)'
    comment(2)='temp  = Temperature (K)'
    comment(3)='uwind = Zonal wind (m/s)'
    comment(4)='vwind = Meridional wind (m/s)'
    comment(5)='ghgt  = Geopotential Height above sea level (m)'
    comment(6)='species are in (mol/mol)
;
; daily IDL save files
;
    sdate_all=strcompress(date_all,/remove_all)
    print,ncfile
    for n=0L,ntime-1L do begin
        time=time_all(n)
        date=date_all(n)
        psfc=reform(psfc_all(*,*,n))
        pmsl=reform(pmsl_all(*,*,n))
;
; Calculate 3d Pressure: p(i,j,k) = A(k)*PO + B(k)*PSFC(i,j) in Pascals
;
        pgrd=fltarr(nlon,nlat,nlev)
        FOR i=0,nlon-1 DO $
            FOR j=0,nlat-1 DO $
                FOR k=0,nlev-1 DO $
                    pgrd(i,j,k)=(hyam(k)*P0 + hybm(k)*PSFC(i,j)) / 100.
        temp=reform(temp_all(*,*,*,n))
        uwind=reform(uwind_all(*,*,*,n))
        vwind=reform(vwind_all(*,*,*,n))
        ghgt=reform(ghgt_all(*,*,*,n))
        result=strsplit(ncfile,'/',/extract)
        result2=strsplit(result(5),'.',/extract)
        ofile=dir+result2(0)+'.'+result2(1)+'.'+result2(2)+'.'+sdate_all(n)+'.sav'
        print,ofile
        save,file=ofile,time,date,longitude,latitude,lev,temp,uwind,vwind,$
             ghgt,comment,nlon,nlat,nlev,pgrd,pmsl,psfc
    endfor	; loop over days in file
endfor		; loop over netCDF files
end
