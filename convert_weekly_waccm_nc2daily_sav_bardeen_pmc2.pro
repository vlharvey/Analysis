;
; read WACCM netcdf data from Chuck Bardeen's PMC run
; location: /net/mass/store2/ptmp/bardeen/waccm/carma/run/pmc2
;
; convert weekly (7 daily averages) to individual daily files
;
;from the full list of variables from ncdump -h pmc2.cam2.h0.2028-01-01-00000.nc
;subset here saved
;
;dimensions:
;        lat = 46, lon = 72, lev = 125 
;variables:
;        double lat(lat) ; latitude
;        double lon(lon) ; longitude
;        int date(time) ; current date (YYYYMMDD)
;        float CRICE18(time, lev, lat, lon) ; CRICE18: "ice crystal, 0.4493E-01 um" (kg/kg)
;        float CRICE19(time, lev, lat, lon) ; CRICE19: "ice crystal, 0.6178E-01 um" (kg/kg)
;        float CRICE20(time, lev, lat, lon) ; CRICE20: "ice crystal, 0.8496E-01 um" (kg/kg)
;        float CRICE21(time, lev, lat, lon) ; CRICE21: "ice crystal, 0.1168E+00 um" (kg/kg)
;        float CRICE22(time, lev, lat, lon) ; CRICE22: "ice crystal, 0.1606E+00 um" (kg/kg)
;        float CRICE23(time, lev, lat, lon) ; CRICE23: "ice crystal, 0.2209E+00 um" (kg/kg)
;        float CRICE24(time, lev, lat, lon) ; CRICE24: "ice crystal, 0.3037E+00 um" (kg/kg)
;        float CRICE25(time, lev, lat, lon) ; CRICE25: "ice crystal, 0.4177E+00 um" (kg/kg)
;        float CRICE26(time, lev, lat, lon) ; CRICE26: "ice crystal, 0.5743E+00 um" (kg/kg)
;        float CRICE27(time, lev, lat, lon) ; CRICE27: "ice crystal, 0.7897E+00 um" (kg/kg)
;        float CRICE28(time, lev, lat, lon) ; CRICE28: "ice crystal, 0.1086E+01 um" (kg/kg)
;        float CRICEAD(time, lev, lat, lon) ; CRICEAD: "CRICE surface area density" (um2/cm-3)
;        float CRICEMD(time, lev, lat, lon) ; CRICEMD: "CRICE mass density" (g/cm-3)
;        float CRICEND(time, lev, lat, lon) ; CRICEND: "CRICE number density" (#/cm-3)
;        float CRICERE(time, lev, lat, lon) ; CRICERE: "CRICE effective radius" (um)
;        float Z3(time, lev, lat, lon) ; Z3: "Geopotential Height (above sea level)" (m)
;
idir='/net/mass/store2/ptmp/bardeen/waccm/carma/run/pmc2/'
odir='/aura7/harvey/WACCM_data/Datfiles/PMC/'
spawn,'ls '+idir+'*cam2.h0*nc',ncfiles
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
;       print,'read ',name,' dimension ',dim
    endfor
    for n=0,nt-1L do begin
    for ivar=0,result0.nvars-1 do begin
        result=ncdf_varinq(ncid,ivar)
        varname=result.name
        if varname ne 'P0' and varname ne 'PS' and varname ne 'Z3' and $
           varname ne 'lat' and varname ne 'lon' and varname ne 'lev' and $
           varname ne 'time' and varname ne 'hyai' and varname ne 'hybi' and $
           varname ne 'hyam' and varname ne 'hybm' and varname ne 'date' and $
           strpos(varname,'ICE') eq -1L then goto,jumpvar
;       print,varname

        if varname ne 'PS' and varname ne 'Z3' and strpos(varname,'ICE') eq -1L then $
           ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
        if varname eq 'P0' then p0=data
        if varname eq 'lat' then alat=data
        if varname eq 'lon' then alon=data
        if varname eq 'lev' then lev=data
        if varname eq 'time' then time=data
        if varname eq 'hyai' then hyai=data
        if varname eq 'hybi' then hybi=data
        if varname eq 'hyam' then hyam=data
        if varname eq 'hybm' then hybm=data
        if varname eq 'date' then date=data
;
; Build 3d Pressure from Psfc et al: p(i,j,k) = A(k)*PO + B(k)*PSFC(i,j) in Pascals
;
        if varname eq 'PS' then begin
           count = [nc,nr,1]
           offset = [0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),psfc,count=count,offset=offset
           pgrd=fltarr(nc,nr,nl)
           Pzero=P0
           FOR ilon=0,nc-1 DO $
               FOR ilat=0,nr-1 DO $
                   FOR ialt=0,nl-1 DO $
                       pgrd(ilon,ilat,ialt)=(hyam(ialt)*Pzero + hybm(ialt)*PSFC(ilon,ilat)) / 100.
        endif
;
; geopotential height (m)
;
        if varname eq 'Z3' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),zgrd,count=count,offset=offset
        endif
;
; ice variables
;
        if strpos(varname,'ICE') ne -1L then begin
        if varname eq 'CRICE18' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice18,count=count,offset=offset
        endif
        if varname eq 'CRICE19' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice19,count=count,offset=offset
        endif
        if varname eq 'CRICE20' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice20,count=count,offset=offset
        endif
        if varname eq 'CRICE21' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice21,count=count,offset=offset
        endif
        if varname eq 'CRICE22' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice22,count=count,offset=offset
        endif
        if varname eq 'CRICE23' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice23,count=count,offset=offset
        endif
        if varname eq 'CRICE24' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice24,count=count,offset=offset
        endif
        if varname eq 'CRICE25' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice25,count=count,offset=offset
        endif
        if varname eq 'CRICE26' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice26,count=count,offset=offset
        endif
        if varname eq 'CRICE27' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice27,count=count,offset=offset
        endif
        if varname eq 'CRICE28' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),crice28,count=count,offset=offset
        endif
        if varname eq 'CRICEAD' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),cricead,count=count,offset=offset
        endif
        if varname eq 'CRICEMD' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),cricemd,count=count,offset=offset
        endif
        if varname eq 'CRICEND' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),cricend,count=count,offset=offset
        endif
        if varname eq 'CRICERE' then begin
           count = [nc,nr,nl,1]
           offset = [0,0,0,n]
           ncdf_varget,ncid,ncdf_varid(ncid,varname),cricere,count=count,offset=offset
        endif
    endif
    jumpvar:
    endfor	; loop over variables
;
; convert time to hours
;
    time=(time-fix(time))*24.
;
; build comment array for variable description
;
    comment=strarr(16)
    comment(0)='CRICE18: ice crystals 0.4493E-01 um (kg/kg)'
    comment(1)='CRICE19: ice crystals 0.6178E-01 um (kg/kg)'
    comment(2)='CRICE20: ice crystals 0.8496E-01 um (kg/kg)'
    comment(3)='CRICE21: ice crystals 0.1168E+00 um (kg/kg)'
    comment(4)='CRICE22: ice crystals 0.1606E+00 um (kg/kg)'
    comment(5)='CRICE23: ice crystals 0.2209E+00 um (kg/kg)'
    comment(6)='CRICE24: ice crystals 0.3037E+00 um (kg/kg)'
    comment(7)='CRICE25: ice crystals 0.4177E+00 um (kg/kg)'
    comment(8)='CRICE26: ice crystals 0.5743E+00 um (kg/kg)'
    comment(9)='CRICE27: ice crystals 0.7897E+00 um (kg/kg)'
    comment(10)='CRICE28: ice crystals 0.1086E+01 um (kg/kg)'
    comment(11)='CRICEAD: CRICE surface area density (um2/cm-3)'
    comment(12)='CRICEMD: CRICE mass density (g/cm-3)'
    comment(13)='CRICEND: CRICE number density (#/cm-3)'
    comment(14)='CRICERE: CRICE effective radius (um)'
    comment(15)='ZGRD: Geopotential Height (m)'
;
; IDL save file for each output time
;
    sdate=strcompress(date(n),/remove_all)
    stime=string(format='(i2.2)',fix(time(n)))+'Z'
    ofile=odir+'pmc2.cam2.h0.'+sdate+'_'+stime+'.sav'
    print,ofile
    save,file=ofile,comment,alon,alat,lev,pgrd,zgrd,crice18,crice19,crice20,crice21,crice22,$
         crice23,crice24,crice25,crice26,crice27,crice28,cricead,cricemd,cricend,cricere
endfor	; loop over timesteps
ncdf_close,ncid
endfor	; loop over weekly files
end
