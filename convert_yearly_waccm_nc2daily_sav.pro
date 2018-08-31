;
; read WACCM yearly O3, H2O, and T netcdf data and convert to daily IDL save files
;
dir='/aura6/data/WACCM_data/Datfiles/'
ncfiles=[$
'H2O_MZ3.1_ECMWF_Op_2000_paper.nc',$
'H2O_MZ3.1_ERA1_2000_paper.nc',$
'H2O_MZ3.1_WA1b_1999_paper.nc',$
'O3_MZ3.1_ECMWF_Op_2000_paper.nc',$
'O3_MZ3.1_ERA1_2000_paper.nc',$
'O3_MZ3.1_WA1b_1999_paper.nc',$
'T_MZ3.1_ECMWF_Op_2000_paper.nc',$
'T_MZ3.1_ERA1_2000_paper.nc',$
'T_MZ3.1_WA1b_1999_paper.nc']
ofiles=[$
'H2O_MZ3.1_ECMWF_Op_',$
'H2O_MZ3.1_ERA1_',$
'H2O_MZ3.1_WA1b_',$
'O3_MZ3.1_ECMWF_Op_',$
'O3_MZ3.1_ERA1_',$
'O3_MZ3.1_WA1b_',$
'T_MZ3.1_ECMWF_Op_',$
'T_MZ3.1_ERA1_',$
'T_MZ3.1_WA1b_']
nfile=n_elements(ncfiles)
for ifile=0L,nfile-1L do begin
    ncfile=dir+ncfiles(ifile)
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
        help,result.name
        if result.name ne 'PS' and result.name ne 'T' and $
           result.name ne 'H2O_VMR_inst' and result.name ne 'O3_VMR_inst' then $
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
        if result.name eq 'date' then begin
           date=data
           sdate=strcompress(date,/remove_all)
        endif
        if result.name eq 'PS' then begin
           ncdf_varget,ncid,ncdf_varid(ncid,result.name),psfc
help,psfc
;
; Calculate 4d Pressure: p(i,j,k,l) = A(k)*PO + B(k)*PSFC(i,j) in Pascals
;
           pgrd=fltarr(nc,nr,nl,nt)
           Pzero=P0
           FOR ilon=0,nc-1 DO $
               FOR ilat=0,nr-1 DO $
                   FOR ialt=0,nl-1 DO $
                       pgrd(ilon,ilat,ialt,*)=(hyam(ialt)*Pzero + hybm(ialt)*PSFC(ilon,ilat,*)) / 100.
        endif

        if result.name eq 'H2O_VMR_inst' then begin
           count = [nc,nr,nl,1]
           for n=0L,nt-1L do begin
               offset = [0,0,0,n]
               ncdf_varget,ncid,ncdf_varid(ncid,result.name),h2o,count=count,offset=offset
               pressure=reform(pgrd(*,*,*,n))
help,h2o,pressure
               ofile=dir+ofiles(ifile)+sdate(n)+'.sav'
               save,file=ofile,alon,alat,pressure,h2o
               print,'saving '+ofile
           endfor
;
; wipe out variables to save memory
;
;          delvar,h2o,pgrd
        endif

        if result.name eq 'O3_VMR_inst' then begin
           count = [nc,nr,nl,1]
           for n=0L,nt-1L do begin
               offset = [0,0,0,n]
               ncdf_varget,ncid,ncdf_varid(ncid,result.name),o3,count=count,offset=offset
               pressure=reform(pgrd(*,*,*,n))
help,o3,pressure
               ofile=dir+ofiles(ifile)+sdate(n)+'.sav'
               save,file=ofile,alon,alat,pressure,o3
               print,'saving '+ofile
           endfor
;          delvar,o3,pgrd
        endif

        if result.name eq 'T' then begin
           count = [nc,nr,nl,1]
           for n=0L,nt-1L do begin
               offset = [0,0,0,n]
               ncdf_varget,ncid,ncdf_varid(ncid,result.name),temp,count=count,offset=offset
               pressure=reform(pgrd(*,*,*,n))
help,temp,pressure
               ofile=dir+ofiles(ifile)+sdate(n)+'.sav'
               save,file=ofile,alon,alat,pressure,temp
               print,'saving '+ofile
           endfor
;          delvar,temp,pgrd
        endif

    endfor
    ncdf_close,ncid
endfor	; loop over netCDF files
end
