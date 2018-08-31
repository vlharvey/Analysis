pro rd_era40_nc,ncfile,nc,nr,nl,alon,alat,press,tp,uu,vv,gp,iflg
iflg=0
;
; ncfile should be a string of the form:
; '/aura7/harvey/ERA40_data/Datfiles/era40_ua_12Z_YYYYMMDD.nc'
; file contents:
; aura% ncdump -h era40_ua_12Z_19621022.nc
; dimensions:
;         x_levels = 144 ;
;         y_levels = 73 ;
;         z_levels = 23 ;
; variables:
;         float x_levels(x_levels) ;
;         float y_levels(y_levels) ;
;         float z_levels(z_levels) ;
;         float temperature(z_levels, y_levels, x_levels) ;
;         float uwnd(z_levels, y_levels, x_levels) ;
;         float vwnd(z_levels, y_levels, x_levels) ;
;         float geopot(z_levels, y_levels, x_levels) ;
; 
; // global attributes:
;                 :DATASET = "ERA40_Upper_Air_12Z" ;
;                 :DATE = 19621022 ;
;
dum1=findfile(ncfile)
if dum1(0) ne '' then begin
   ncid=ncdf_open(ncfile)
   print,'opened ',ncfile
   goto,jump
endif
if dum1(0) eq '' then begin
   iflg=1
   return
endif
stop
jump:
result=ncdf_inquire(ncid)
;nc=0L & nr=0L & nl=0L & nt=0L
for idim=0,result.ndims-1 do begin
    ncdf_diminq,ncid,idim,name,dim
    if name eq 'x_levels' then nc=dim
    if name eq 'y_levels' then nr=dim
    if name eq 'z_levels' then nl=dim
;   print,'read ',name,' dimension ',dim
endfor
;alon=0. & alat=0. & press=0. & time=0. & data=0.
for ivar=0,result.nvars-1 do begin
    result=ncdf_varinq(ncid,ivar)
    ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
    if result.name eq 'x_levels' then alon=data
    if result.name eq 'y_levels' then alat=data
    if result.name eq 'z_levels' then press=data
    if result.name eq 'temperature' then tp=data
    if result.name eq 'uwnd' then uu=data
    if result.name eq 'vwnd' then vv=data
    if result.name eq 'geopot' then gp=data
;   print,'read ',result.name,' variable'
endfor
ncdf_close,ncid
end
