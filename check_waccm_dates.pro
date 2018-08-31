dir='/aura6/data/WACCM_data/Datfiles/'
;spawn,'ls '+dir+'*nc',ncfiles
;ncfiles=dir+['trends_ref2.cam2.h1.2000-02-20-43200.nc']
ncfiles=dir+['trends_ref2.cam2.h1.1998-01-01-43200.nc']
nfile=n_elements(ncfiles)
for ifile=0L,nfile-1L do begin

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
;   print,'read ',name,' dimension ',dim
endfor
for ivar=0,result0.nvars-1 do begin
    result=ncdf_varinq(ncid,ivar)
    ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
    if result.name eq 'lat' then latitude=data
    if result.name eq 'lon' then longitude=data
    if result.name eq 'lev' then pressure=data
    if result.name eq 'time' then time=data		; days since 1/1/1975
    if result.name eq 'date' then begin
       date=data		; YYYYMMDD
       stop
    endif
    if result.name eq 'co2vmr' then co2vmr1=data	; CO2 volume mixing ratio
    if result.name eq 'mdt' then model_timestep=data	; model timestep
    if result.name eq 'N2D' then n2d1=data		; N(2D)    (mol/mol)  (time, lev, lat, lon)
    if result.name eq 'NO' then no1=data		; NO       (mol/mol)  (time, lev, lat, lon)
    if result.name eq 'O' then o1=data			; O        (mol/mol)  (time, lev, lat, lon)
    if result.name eq 'O2' then o21=data		; O2       (mol/mol)  (time, lev, lat, lon)
    if result.name eq 'QRS_TOT' then sw_heat1=data	; SW heating (K/s)    (time, lev, lat, lon)
    if result.name eq 'T' then temp1=data		; Temp       (K)      (time, lev, lat, lon)
    if result.name eq 'UV2d' then uv2d1=data		; N/S flux U mom (m2/s2) (time, lat, lon)
    if result.name eq 'UW2d' then uw2d1=data		; Ver flux U mom (m2/s2) (time, lat, lon) 
    if result.name eq 'VTH2d' then vth2d1=data		; N/S heat flux  (mK/s)  (time, lat, lon)
    if result.name eq 'WTH2d' then wth2d1=data		; Ver heat flux  (mK/s)  (time, lat, lon)
    if result.name eq 'Z3' then z31=data		; Geop. Height   (m)  (time, lev, lat, lon)
;   print,ivar,result.name,min(data),max(data)
endfor
ncdf_close,ncid
;
; convert time to hours
;
time=(time-fix(time))*24.
;
; create comment for data users
;
comment=strarr(14)
comment(0) ='n2d            = N(2D) (mol/mol)'
comment(1) ='no             = NO (mol/mol)'
comment(2) ='o              = O (mol/mol)'
comment(3) ='o2             = O2 (mol/mol)'
comment(4) ='sw_heat        = Merged SW heating: QRS+QCP+QRS_EUV+QRS_CO2NIR+QRS_AUR+QTHERMAL (K/s)'
comment(5) ='temp           = Temperature (K)'
comment(6) ='uv2d           = Meridional Flux of Zonal Momentum: 2D prj of zon. mean (m2/s2)'
comment(7) ='uw2d           = Vertical Flux of Zonal Momentum; 2D prj of zon. mean (m2/s2)'
comment(8) ='vth2d          = Meridional Heat Flux: 2D prj of zon. mean (mK/s)'
comment(9) ='wth2d          = Vertical Heat Flux: 2D prj of zon. mean (mK/s)'
comment(10)='z3             = Geopotential Height (above sea level) (m)'
comment(11)='co2vmr         = CO2 volume mixing ratio'
comment(12)='model_timestep = model timestep (s)'
comment(13)='Fill value     = 1.e+35'
;
; IDL save file for each output time
;
for n=0L,ntime-1L do begin
    sdate=strcompress(date(n),/remove_all)
    stime=string(format='(i2.2)',fix(time(n)))+'Z'
    ofile='/aura6/data/WACCM_data/Datfiles/'+sdate+'_'+stime+'.sav'
    print,ofile
    co2vmr=co2vmr1(n)
    n2d=reform(n2d1(*,*,*,n))
    no=reform(no1(*,*,*,n))
    o=reform(o1(*,*,*,n))
    o2=reform(o21(*,*,*,n))
    sw_heat=reform(sw_heat1(*,*,*,n))
    temp=reform(temp1(*,*,*,n))
    uv2d=reform(uv2d1(*,*,n))
    uw2d=reform(uw2d1(*,*,n))
    vth2d=reform(vth2d1(*,*,n))
    wth2d=reform(wth2d1(*,*,n))
    z3=reform(z31(*,*,*,n))
    save,file=ofile,longitude,latitude,pressure,n2d,co2vmr,no,o,o2,$
         sw_heat,temp,uv2d,uw2d,vth2d,wth2d,z3,model_timestep,comment
endfor	; loop over output times
endfor	; loop over monthly netCDF files
end
