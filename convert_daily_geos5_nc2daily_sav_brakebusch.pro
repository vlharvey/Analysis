;
; read GEOS-5 netcdf data from Matthias Brakebusch with the following variables from ncdump -h
; convert monthly to daily files
;
; aura% pwd
; /aura7/harvey/GEOS5_data/Datfiles_Brakebusch
; aura% ncdump -h GEOS5.1_2004_19x2_72lev_20041231.nc
; netcdf GEOS5.1_2004_19x2_72lev_20041231 {
; dimensions:
;         lon = 144 ;
;         lat = 96 ;
;         lev = 72 ;
;         time = 4 ;
;         ilev = 73 ;
;         scalar = UNLIMITED ; // (1 currently)
; variables:
;         float lon(lon) ;
;                 lon:long_name = "longitude" ;
;                 lon:units = "degrees_east" ;
;         float lat(lat) ;
;                 lat:long_name = "latitude" ;
;                 lat:units = "degrees_north" ;
;         float lev(lev) ;
;                 lev:long_name = "hybrid level at midpoint (1000*(A+B))" ;
;                 lev:units = "level" ;
;                 lev:positive = "down" ;
;                 lev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate\"" ;
;         float time(time) ;
;                 time:long_name = "time" ;
;                 time:units = "days since 2004-01-01 00:00:00" ;
;                 time:calendar = "gregorian" ;
;                 time:bounds = "time_bnds" ;
;         float ilev(ilev) ;
;                 ilev:long_name = "hybrid level at interface (1000*(A+B))" ;
;                 ilev:units = "level" ;
;                 ilev:positive = "down" ;
;                 ilev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate\"" ;
;         float hyam(lev) ;
;                 hyam:long_name = "hybrid A Coefficient at layer midpoints" ;
;         float hyai(ilev) ;
;                 hyai:long_name = "hybrid A Coefficient at layer interfaces" ;
;         float hybm(lev) ;
;                 hybm:long_name = "hybrid B Coefficient at layer midpoints" ;
;         float hybi(ilev) ;
;                 hybi:long_name = "hybrid B Coefficient at layer interfaces" ;
;         int date(time) ;
;                 date:long_name = "current date (YYYYMMDD)" ;
;         int datesec(time) ;
;                 datesec:long_name = "current seconds of current date" ;
;         float P0(scalar) ;
;                 P0:long_name = "reference pressure" ;
;                 P0:units = "Pa" ;
;         float PS(time, lat, lon) ;
;                 PS:long_name = "Surface pressure" ;
;                 PS:units = "Pa" ;
;         float T(time, lev, lat, lon) ;
;                 T:long_name = "Temperature" ;
;                 T:units = "K" ;
;         float U(time, lev, lat, lon) ;
;                 U:long_name = "Meridional wind" ;
;                 U:units = "m/s" ;
;         float V(time, lev, lat, lon) ;
;                 V:long_name = "Zonal wind" ;
;                 V:units = "m/s" ;
;
dir='/aura7/harvey/GEOS5_data/Datfiles_Brakebusch/'
spawn,'ls '+dir+'GEOS5.1_2004_19x2_72lev_*nc',ncfiles
nfile=n_elements(ncfiles)
for ifile=0L,nfile-1L do begin

ncfile=ncfiles(ifile)
print,'opening '+ncfile
ncid=ncdf_open(ncfile)
result0=ncdf_inquire(ncid)
for idim=0,result0.ndims-1 do begin
    ncdf_diminq,ncid,idim,name,dim
    if name eq 'lon' then nc=dim
    if name eq 'lat' then nr=dim
    if name eq 'lev' then nl=dim
    if name eq 'time' then nt=dim
    print,'read ',name,' dimension ',dim
endfor
for ivar=0,result0.nvars-1 do begin
    result=ncdf_varinq(ncid,ivar)
    print,result.name
    ncdf_varget,ncid,ncdf_varid(ncid,result.name),data

    if result.name eq 'P0' then p0=data
    if result.name eq 'PS' then ps=data
    if result.name eq 'lat' then alat=data
    if result.name eq 'lon' then alon=data
    if result.name eq 'lev' then lev=data
    if result.name eq 'ilev' then ilev=data
    if result.name eq 'time' then time=data
    if result.name eq 'hyai' then hyai=data
    if result.name eq 'hybi' then hybi=data
    if result.name eq 'hyam' then hyam=data
    if result.name eq 'hybm' then hybm=data
    if result.name eq 'date' then begin
       date=data
       sdate=strcompress(date,/remove_all)
    endif
    if result.name eq 'T' then t4d=data
    if result.name eq 'U' then u4d=data
    if result.name eq 'V' then v4d=data
endfor	; loop over variables
ncdf_close,ncid
;
; loop over time steps
;
time=(time-fix(time))*24.
stime=string(format='(i2.2)',long(time))
for itime=0L,nt-1L do begin
;
; Calculate 3d Pressure: p(i,j,k) = A(k)*PO + B(k)*PS(i,j) in Pascals
;
    pgrd=fltarr(nc,nr,nl)
    Pzero=P0
    FOR ilon=0,nc-1 DO $
        FOR ilat=0,nr-1 DO $
            FOR ialt=0,nl-1 DO $
                pgrd(ilon,ilat,ialt)=(hyam(ialt)*Pzero + hybm(ialt)*PS(ilon,ilat,itime)) / 100.
;
; IDL save file for each output time
;
    tgrd=reform(t4d(*,*,*,itime))
    ugrd=reform(u4d(*,*,*,itime))
    vgrd=reform(v4d(*,*,*,itime))
    ofile=dir+'GEOS5.1_2004_19x2_72lev_'+sdate(itime)+'_'+stime(itime)+'Z.sav'
    print,ofile
    save,file=ofile,alon,alat,pgrd,tgrd,ugrd,vgrd
endfor	; loop over time step
endfor	; loop over files
end
