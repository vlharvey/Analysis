;
; read WACCM netcdf data from Chuck Bardeen with the following variables from ncdump -h
; convert monthly to daily files
;
;aura% ncdump -h ../Datfiles/h0.lynn.2034.07.nc
;netcdf h0.lynn.2034.07 {
;dimensions:
;        lat = 46 ;
;        lon = 72 ;
;        lev = 66 ;
;        ilev = 67 ;
;        time = UNLIMITED ; // (31 currently)
;variables:
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
;       double ilev(ilev) ;
;               ilev:long_name = "hybrid level at interfaces (1000*(A+B))" ;
;               ilev:units = "level" ;
;               ilev:positive = "down" ;
;               ilev:standard_name = "atmosphere_hybrid_sigma_pressure_coordinate" ;
;               ilev:formula_terms = "a: hyai b: hybi p0: P0 ps: PS" ;
;       double time(time) ;
;               time:long_name = "time" ;
;               time:units = "days since 2025-01-01 00:00:00" ;
;               time:calendar = "noleap" ;
;               time:bounds = "time_bnds" ;
;       double hyai(ilev) ;
;               hyai:long_name = "hybrid A coefficient at layer interfaces" ;
;       double hybi(ilev) ;
;               hybi:long_name = "hybrid B coefficient at layer interfaces" ;
;       double hyam(lev) ;
;               hyam:long_name = "hybrid A coefficient at layer midpoints" ;
;       double hybm(lev) ;
;               hybm:long_name = "hybrid B coefficient at layer midpoints" ;
;       double gw(lat) ;
;               gw:long_name = "gauss weights" ;
;       int date(time) ;
;               date:long_name = "current date (YYYYMMDD)" ;
;       float PS(time, lat, lon) ;
;               PS:units = "Pa" ;
;               PS:long_name = "Surface pressure" ;
;               PS:cell_method = "time: mean" ;
;       float Q(time, lev, lat, lon) ;
;               Q:units = "kg/kg" ;
;               Q:long_name = "Specific humidity" ;
;               Q:cell_method = "time: mean" ;
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
;
dir='/aura3/data/WACCM_data/Datfiles/'
spawn,'ls '+dir+'h0*nc',ncfiles
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
    if result.name ne 'PS' and result.name ne 'T' and $
       result.name ne 'Q' and result.name ne 'U' and result.name ne 'V' and $
       result.name ne 'DUSTND' and result.name ne 'DUSTAD' and result.name ne 'DUSTMD' and $
       result.name ne 'DUSTRE' and result.name ne 'DUSTMMR' then $
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),data

    if result.name eq 'P0' then p0=data
    if result.name eq 'lat' then alat=data
    if result.name eq 'lon' then alon=data
    if result.name eq 'lev' then lev=data
    if result.name eq 'ilev' then ilev=data
    if result.name eq 'time' then time=data
    if result.name eq 'hyai' then hyai=data
    if result.name eq 'hybi' then hybi=data
    if result.name eq 'hyam' then hyam=data
    if result.name eq 'hybm' then hybm=data
;   if result.name eq 'date' then begin
;      date=data
;      sdate=strcompress(date,/remove_all)
;   endif
    if result.name eq 'PS' then begin
       count = [nc,nr,1]
       offset = [0,0,n]
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),psfc,count=count,offset=offset
;
; Calculate 4d Pressure: p(i,j,k,l) = A(k)*PO + B(k)*PSFC(i,j) in Pascals
;
       pgrd=fltarr(nc,nr,nl)
       Pzero=P0
       FOR ilon=0,nc-1 DO $
           FOR ilat=0,nr-1 DO $
               FOR ialt=0,nl-1 DO $
                   pgrd(ilon,ilat,ialt)=(hyam(ialt)*Pzero + hybm(ialt)*PSFC(ilon,ilat)) / 100.
    endif
    if result.name eq 'T' then begin
       count = [nc,nr,nl,1]
       offset = [0,0,0,n]
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),tgrd,count=count,offset=offset
    endif
    if result.name eq 'U' then begin
       count = [nc,nr,nl,1]
       offset = [0,0,0,n]
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),ugrd,count=count,offset=offset
    endif
    if result.name eq 'V' then begin
       count = [nc,nr,nl,1]
       offset = [0,0,0,n]
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),vgrd,count=count,offset=offset
    endif
    if result.name eq 'Q' then begin		; specific humidity
       count = [nc,nr,nl,1]
       offset = [0,0,0,n]
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),qgrd,count=count,offset=offset
    endif
    if result.name eq 'DUSTND' then begin	; number density
       count = [nc,nr,nl,1]
       offset = [0,0,0,n]
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),dustndgrd,count=count,offset=offset
    endif
    if result.name eq 'DUSTAD' then begin	; surface area density
       count = [nc,nr,nl,1]
       offset = [0,0,0,n]
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),dustadgrd,count=count,offset=offset
    endif
    if result.name eq 'DUSTMD' then begin	; mass density
       count = [nc,nr,nl,1]
       offset = [0,0,0,n]
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),dustmdgrd,count=count,offset=offset
    endif
    if result.name eq 'DUSTRE' then begin	; effective radius
       count = [nc,nr,nl,1]
       offset = [0,0,0,n]
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),dustregrd,count=count,offset=offset
    endif
    if result.name eq 'DUSTMMR' then begin	; total mass mixing ratio
       count = [nc,nr,nl,1]
       offset = [0,0,0,n]
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),dustmmrgrd,count=count,offset=offset
    endif
endfor	; loop over variables
;
; convert time to hours
;
time=(time-fix(time))*24.
;
; IDL save file for each output time
;
;   sdate=strcompress(date(n),/remove_all)
    sdate=string(format='(i3.3)',n)
    stime=string(format='(i2.2)',fix(time(n)))+'Z'
    ofile=dir+'h0.lynn+dust.'+sdate+'_'+stime+'.sav'
    print,ofile
    save,file=ofile,alon,alat,pgrd,tgrd,ugrd,vgrd,qgrd,dustndgrd,dustadgrd,dustmdgrd,dustregrd,dustmmrgrd
endfor	; loop over output times
ncdf_close,ncid
endfor	; loop over monthly files
end
