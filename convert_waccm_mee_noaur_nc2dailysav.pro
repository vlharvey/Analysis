;
; mee noaur files obtained from run by Mike Mills	6/88/2008
; /aura7/harvey/WACCM_data/Datfiles/Datfiles_Mills and save in daily
; files in IDL save format
; "h3" files are daily 3-D WACCM output, 20 days per nc file
;
; date (YYYYMMDD) current date
; datesec current seconds of current date
; CH4 (mol/mol)
; CO (mol/mol)
; HNO3 (mol/mol)
; H2O (mol/mol)
; N2O (mol/mol)
; N2O5 (mol/mol)
; NO (mol/mol)
; NO2 (mol/mol)
; NOX (mol/mol)
; NOY (mol/mol)
; NO_MEE (molec/cm3/s) medium energy electron NO production
; O3 (mol/mol)
; PS (Pa) Surface pressure
; QRL_TOT (K/s) Merged LW heating: QRL+QRLNLTE
; QRS_TOT (K/s) Merged SW heating: QRS+QCP+QRS_EUV+QRS_CO2NIR+QRS_AUR+QTHERMAL
; QSUM (s-1) total ion production
; T (K) Temperature
; U (m/s) Zonal wind
; V (m/s) Meridional wind
; Z3 (m) Geopotential Height (above sea level)
;
dir='/aura7/harvey/WACCM_data/Datfiles/Datfiles_Mills/mee00_noaur/'
spawn,'ls '+dir+'mee00_noaur.cam2.h3.*.nc',ncfiles
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
        if result.name eq 'HNO3' then hno3_all=data		; HNO3 (mol/mol)
        if result.name eq 'H2O' then h2o_all=data		; H2O (mol/mol)
        if result.name eq 'N2O' then n2o_all=data		; N2O (mol/mol)
        if result.name eq 'N2O5' then n2o5_all=data		; N2O5 (mol/mol)
        if result.name eq 'NOX' then nox_all=data		; NOX (mol/mol)
        if result.name eq 'NOY' then noy_all=data		; NOY (mol/mol)
        if result.name eq 'NO_MEE' then no_mee_all=data		; (molec/cm3/s) medium energy electron NO production
        if result.name eq 'QRL_TOT' then qrl_tot_all=data	; (K/s) Merged LW heating: QRL+QRLNLTE
        if result.name eq 'QRS_TOT' then qrs_tot_all=data	; (K/s) Merged SW heating: QRS+QCP+QRS_EUV+QRS_CO2NIR+QRS_AUR+QTHERMAL
        if result.name eq 'QSUM' then qsum_all=data		; total ion production (s-1)
        print,'min/max ',result.name,min(data),max(data)
    endfor
    ncdf_close,ncid
;
; create comment for data users
;
    comment=strarr(11)
    comment(0)='time  = days since 2025-01-01 00:00:00'
    comment(1)='psfc  = Surface pressure (hPa)'
    comment(2)='temp  = Temperature (K)'
    comment(3)='uwind = Zonal wind (m/s)'
    comment(4)='vwind = Meridional wind (m/s)'
    comment(5)='ghgt  = Geopotential Height above sea level (m)'
    comment(6)='species are in (mol/mol)'
    comment(7)='QSUM = total ion production (s-1)'
    comment(8)='NO_MEE = medium energy electron NO production (molec/cm3/s)'
    comment(9)='QRL_TOT = Merged LW heating: QRL+QRLNLTE (K/s)'
    comment(10)='QRS_TOT = Merged SW heating: QRS+QCP+QRS_EUV+QRS_CO2NIR+QRS_AUR+QTHERMAL (K/s)'
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
;
; extract 3-D grid from 4-d arrays
;
        temp=reform(temp_all(*,*,*,n))
        uwind=reform(uwind_all(*,*,*,n))
        vwind=reform(vwind_all(*,*,*,n))
        ghgt=reform(ghgt_all(*,*,*,n))
        ch4=reform(ch4_all(*,*,*,n))
        co=reform(co_all(*,*,*,n))
        no=reform(no_all(*,*,*,n))
        no2=reform(no2_all(*,*,*,n))
        o3=reform(o3_all(*,*,*,n))
        hno3=reform(hno3_all(*,*,*,n))
        h2o=reform(h2o_all(*,*,*,n))
        n2o=reform(n2o_all(*,*,*,n))
        n2o5=reform(n2o5_all(*,*,*,n))
        nox=reform(nox_all(*,*,*,n))
        noy=reform(noy_all(*,*,*,n))
        no_mee=reform(no_mee_all(*,*,*,n))
        qrl_tot=reform(qrl_tot_all(*,*,*,n))
        qrs_tot=reform(qrs_tot_all(*,*,*,n))
        qsum=reform(qsum_all(*,*,*,n))
        result=strsplit(ncfile,'/',/extract)
        result2=strsplit(result(6),'.',/extract)
        ofile=dir+result2(0)+'.'+result2(1)+'.'+result2(2)+'.'+sdate_all(n)+'.sav'
        print,ofile
        save,file=ofile,time,date,longitude,latitude,lev,temp,uwind,vwind,$
             ghgt,comment,nlon,nlat,nlev,pgrd,pmsl,psfc,no,no2,ch4,co,o3,h2o,$
             hno3,n2o,n2o5,nox,noy,no_mee,qrl_tot,qrs_tot,qsum
    endfor	; loop over days in file
endfor		; loop over netCDF files
end
