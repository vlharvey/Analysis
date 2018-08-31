;
; read WACCM netcdf data from Chuck Bardeen with select variables from ncdump -h
; convert individual files to IDL save format
;
;aura% ncdump -h ../Datfiles/h0.hervig_2x.nc
;netcdf h0.hervig_2x {
;dimensions:
;        lat = 46 ;
;        lon = 72 ;
;        lev = 125 ;
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
;        double lev(lev) ;
;                lev:long_name = "hybrid level at midpoints (1000*(A+B))" ;
;                lev:units = "level" ;
;                lev:positive = "down" ;
;                lev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate" ;
;                lev:formula_terms = "a: hyam b: hybm p0: P0 ps: PS" ;
;        int date(time) ;
;                date:long_name = "current date (YYYYMMDD)" ;
;        float PS(time, lat, lon) ;
;                PS:units = "Pa" ;
;                PS:long_name = "Surface pressure" ;
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
dir='/aura3/data/WACCM_data/Datfiles/'
spawn,'ls '+dir+'h0.hervig*nc',ncfiles
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
for n=0,nt-1L do begin
for ivar=0,result0.nvars-1 do begin
    result=ncdf_varinq(ncid,ivar)
    print,result.name
    if result.name eq 'P0' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),p0
    if result.name eq 'lat' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),alat
    if result.name eq 'lon' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),alon
    if result.name eq 'lev' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),lev
    if result.name eq 'ilev' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),ilev
    if result.name eq 'hyai' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),hyai
    if result.name eq 'hybi' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),hybi
    if result.name eq 'hyam' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),hyam
    if result.name eq 'hybm' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),hybm
    if result.name eq 'date' then begin
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),date
       sdate=strcompress(date,/remove_all)
    endif

    if result.name eq 'PS' then begin
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),psfc
;
; Calculate 4d Pressure: p(i,j,k,l) = A(k)*PO + B(k)*PSFC(i,j) in Pascals
;
       pgrd=fltarr(nc,nr,nl)
       FOR ilon=0,nc-1 DO $
           FOR ilat=0,nr-1 DO $
               FOR ialt=0,nl-1 DO $
                   pgrd(ilon,ilat,ialt)=(hyam(ialt)*P0 + hybm(ialt)*PSFC(ilon,ilat)) / 100.
    endif
    if result.name eq 'T' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),tgrd
    if result.name eq 'U' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),ugrd
    if result.name eq 'V' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),vgrd
    if result.name eq 'Z3' then ncdf_varget,ncid,ncdf_varid(ncid,result.name),zgrd
endfor	; loop over variables
;
; IDL save file 
;
    result=strsplit(ncfile,'.',/extract)
    ofile=result(0)+'.'+result(1)+'.sav'
    print,ofile
    save,file=ofile,alon,alat,pgrd,tgrd,ugrd,vgrd,zgrd
endfor	; loop over output times
ncdf_close,ncid
endfor	; loop over monthly files
end
