pro rd_ukmo_nwp,ncfile,nc,nr,nc1,nr1,nl,lon,lon1,lat,lat1,press,z3d,t3d,u3d,v3d,iflg
dum1=findfile(ncfile)
if dum1(0) ne '' then begin
   ncid=ncdf_open(ncfile)
   goto,jump
endif
if dum1(0) eq '' then begin
   iflg=1
   return
endif
jump:
result=ncdf_inquire(ncid)
for idim=0,result.ndims-1 do begin
    ncdf_diminq,ncid,idim,name,dim
    if name eq 'longitude' then nc=dim
    if name eq 'latitude' then nr=dim
    if name eq 'longitude_1' then nc1=dim
    if name eq 'latitude_1' then nr1=dim
    if name eq 'p' then nl=dim
;   print,'read ',name,' dimension ',dim
endfor
for ivar=0,result.nvars-1 do begin
    result=ncdf_varinq(ncid,ivar)
    ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
    if result.name eq 'latitude' then lat=data
    if result.name eq 'longitude' then lon=data
    if result.name eq 'latitude_1' then lat1=data
    if result.name eq 'longitude_1' then lon1=data
    if result.name eq 'p' then press=data
    if result.name eq 'temp' then t3d=data
    if result.name eq 'ht' then z3d=data
    if result.name eq 'u' then u3d=data
    if result.name eq 'v' then v3d=data
;   print,'read variable ',result.name
endfor
ncdf_close,ncid
end
