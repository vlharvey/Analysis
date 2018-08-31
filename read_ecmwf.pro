pro read_ecmwf,ncfile,nc,nr,nl,nt,alon,alat,press,date,z2,t2,u2,v2,q2,w2,o32,varname,varunit
ncid=ncdf_open(ncfile)
result=ncdf_inquire(ncid)
ndims=result.ndims
nvars=result.nvars
varname=strarr(nvars)
varunit=strarr(nvars)
print,ndims,' dimensions'
print,nvars,' variables'
nc=0L & nr=0L & nl=0L & nt=0L
for idim=0,ndims-1 do begin
    ncdf_diminq,ncid,idim,name,dim
    print,'dimension ',idim,' ',name,dim
    if name eq 'longitude' then nc=dim
    if name eq 'latitude' then nr=dim
    if name eq 'levelist' then nl=dim
    if name eq 'date' then nt=dim
endfor
print,' '
for ivar=0,nvars-1 do begin
    result=ncdf_varinq(ncid,ivar)
    ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
    varname(ivar)=result.name
    print,'variable  ',ivar,' ',result.name

    for iatt=0,result.natts-1 do begin
        att_result=ncdf_attinq(ncid,ivar,ncdf_attname(ncid,ivar,iatt))
        attribute=att_result.datatype
        ncdf_attget,ncid,ivar,ncdf_attname(ncid,ivar,iatt),attribute
        if ncdf_attname(ncid,ivar,iatt) eq 'units' then varunit(ivar)=string(attribute)
        if ncdf_attname(ncid,ivar,iatt) eq 'long_name' then varname(ivar)=string(attribute)
        print,'attribute ',iatt,' ',ncdf_attname(ncid,ivar,iatt),'=',string(attribute)
    endfor
;
; extract variables
;
    if result.name eq 'longitude' then alon=data
    if result.name eq 'latitude' then alat=data
    if result.name eq 'levelist' then press=data
    if result.name eq 'date' then date=data
    if result.name eq 'z' then begin
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'scale_factor',scale
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'add_offset',offset
       z2=(offset+scale*data)/9.806	; convert geopotential to geopotential height
    endif
    if result.name eq 't' then begin
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'scale_factor',scale
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'add_offset',offset
       t2=offset+scale*data
    endif
    if result.name eq 'u' then begin
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'scale_factor',scale
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'add_offset',offset
       u2=offset+scale*data
    endif
    if result.name eq 'v' then begin
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'scale_factor',scale
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'add_offset',offset
       v2=offset+scale*data
    endif
    if result.name eq 'q' then begin
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'scale_factor',scale
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'add_offset',offset
       q2=offset+scale*data
    endif
    if result.name eq 'w' then begin
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'scale_factor',scale
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'add_offset',offset
       w2=offset+scale*data
    endif
    if result.name eq 'o3' then begin
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'scale_factor',scale
       ncdf_attget,ncid,ncdf_varid(ncid,result.name),'add_offset',offset
       o32=offset+scale*data
    endif
endfor
ncdf_close,ncid
return
end
