;
; read WACCM U, V, T and calculate PV
;
@compvort
@calcelat2d

PI2=6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
ncfile='/aura3/randall/waccm/U_V_T_S1.nc'
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
;
; loop over timesteps
;
FOR ITIME=0l,NT-1l DO BEGIN
;
; loop over variables
;
for ivar=0,result0.nvars-1 do begin
    result=ncdf_varinq(ncid,ivar)
    if result.name ne 'T' and result.name ne 'U' and result.name ne 'V' then $
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
    if result.name eq 'date' then date=data
    if result.name eq 'PS' then psfc=data
    if result.name eq 'T' or result.name eq 'U' or result.name eq 'V' then $
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),data, OFFSET=[0,0,0,itime], COUNT=[nc,nr,nl,1]
    if result.name eq 'T' then tgrd=data
    if result.name eq 'U' then ugrd=data
    if result.name eq 'V' then vgrd=data
    print,ivar,result.name,min(data),max(data)
endfor
p=lev
;
;============================================================
; Calculate Pressure
;============================================================
;pgrd        = fltarr(nc,nr,nl)
;Pzero       = P0
;pgrd(i,j,k) = A(k)*PO + B(k)*PS(i,j) in Pascals
;FOR ilon = 0, nc-1 DO $
;    FOR ilat = 0, nr-1 DO $
;        FOR ialt = 0, nl-1 DO $
;            pgrd(ilon,ilat,ialt) = (hyam(ialt)*Pzero + hybm(ialt)*PSFC(ilon,ilat,*)) / 100.
;
; calculate theta, absolute vorticity
;
pv=0.*tgrd
eta=0.*tgrd
thgrd=0.*tgrd
for L=0L,NL-1L do $
    THGRD(*,*,L)=TGRD(*,*,L)*(1000./LEV(L))^.286

compvort,ugrd,vgrd,eta,alon,alat,nc,nr
;
; LOOP OVER LATITUDES
;
for LAT=0L,NR-1L do begin
    JP1=LAT-1
    JM1=LAT+1
    JP2=LAT-2
    JM2=LAT+2
    IF LAT EQ 0 THEN begin
       JP1=0
       JP2=0
    ENDIF
    IF LAT EQ NR-1L THEN begin
       JM1=NR-1L
       JM2=NR-1L
    ENDIF
    IF LAT EQ NR-2 then JM2=NR-1
    IF LAT EQ 1 then JP2=0
    DY1=RADEA*(ALAT(JP1)-ALAT(JM1))*DTR
    DY2=RADEA*(ALAT(JP2)-ALAT(JM2))*DTR
    DX1=RADEA*COS(ALAT(LAT)*DTR)*PI2/(.5*NC)
    DX2=RADEA*COS(ALAT(LAT)*DTR)*PI2/(.25*NC)
;
; LOOP OVER LONGITUDES
;
    for I=0,NC-1L do begin
        IP1=I+1
        IM1=I-1
        IP2=I+2
        IM2=I-2
        IF I EQ 0 THEN begin
           IM1=NC-1
           IM2=NC-2
        ENDIF
        IF I EQ NC-1 THEN begin
           IP1=0
           IP2=1
        ENDIF
        IF I EQ 1 then IM2=NC-1
        IF I EQ NC-2 then IP2=0
;
; COMPUTE ISENTROPIC POTENTIAL VORTICITY ON PRESSURE SURFACE
;
        for K=0,NL-1L do begin
            LM1=K-1
            LP1=K+1
            IF K EQ 0 then LM1=0
            IF K EQ NL-1L then LP1=NL-1L
            DTHDP=(THGRD(I,LAT,LP1)-THGRD(I,LAT,LM1))/(P(LP1)-P(LM1))
            DUDP=(ugrd(I,LAT,LP1)-ugrd(I,LAT,LM1))/(P(LP1)-P(LM1))
            DVDP=(vgrd(I,LAT,LP1)-vgrd(I,LAT,LM1))/(P(LP1)-P(LM1))
            DTHDX=(4./3.)*(THGRD(IP1,LAT,K)-THGRD(IM1,LAT,K))/DX1 - $
                  (1./3.)*(THGRD(IP2,LAT,K)-THGRD(IM2,LAT,K))/DX2
            IF LAT LE 1 OR LAT GE NR-2 THEN begin
               DTHDY=(THGRD(I,JP1,K)-THGRD(I,JM1,K))/DY1
            endif
            IF LAT gt 1 and LAT lt NR-2 THEN begin
               DTHDY=(4./3.)*(THGRD(I,JP1,K)-THGRD(I,JM1,K))/DY1 - $
                     (1./3.)*(THGRD(I,JP2,K)-THGRD(I,JM2,K))/DY2
            ENDIF
            IF DTHDP GE 0. THEN begin
               PV(I,LAT,K)=1.E12
            endif
            IF DTHDP lt 0. THEN begin
               PV(I,LAT,K)=eta(I,LAT,K)-(DUDP*DTHDY-DVDP*DTHDX)/DTHDP
               PV(I,LAT,K)=-9.8*DTHDP*PV(I,LAT,K)/100.
            ENDIF
        endfor
    endfor
endfor
;
; calculate Equivalent latitude
;
elat=0.*pv
for k=0L,nl-1L do begin
pv1=reform(pv(*,*,k))
elat1=calcelat2d(pv1,alon,alat)
elat(*,*,k)=elat1
endfor
;
; save daily PV and ELAT
;
sdate=strcompress(string(date(itime)),/remove_all)
save,file='/aura3/data/WACCM_data/Datfiles/PV_ELAT_S1_'+sdate+'.sav',pv,elat,alon,alat,lev
print,sdate

ENDFOR		; LOOP OVER TIMESTEPS
ncdf_close,ncid
end
