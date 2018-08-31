;
; read WACCM U, V, T monthly netCDF file. calculate PV, QDF and 
; interpolate to isentropic surfaces.  Output daily theta .nc files.
;
; interpolate to 72 latitudes as MetO -88.75 to 88.75 by 2.5
; and 144 longitudes 0 to 357.5 by 2.5
; for calculation of stream function
;
@compvort

loadct,38
device,decompose=0
mcolor=byte(!p.color)
nlvls=30L
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
PI2=6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
!noeras=-1
nxdim=750
nydim=750
xorig=[0.1,0.1]
yorig=[0.6,0.15]
xlen=0.8
ylen=0.35
cbaryoff=0.05
cbarydel=0.01
setplot='x'
read,'setplot= ',setplot
if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
ncfile='/aura3/randall/waccm/U_V_T_S1.nc'
ncid=ncdf_open(ncfile)
result0=ncdf_inquire(ncid)
for idim=0,result0.ndims-1 do begin
    ncdf_diminq,ncid,idim,name,dim
    if name eq 'lon' then nc=dim
    if name eq 'lat' then nr=dim
    if name eq 'lev' then nl=dim
    if name eq 'time' then nt=dim
;   print,'read ',name,' dimension ',dim
endfor
ncfile2='/aura3/randall/waccm/O3_CH4_NOY_S1.nc'
ncid2=ncdf_open(ncfile2)
result2=ncdf_inquire(ncid2)
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
    if result.name eq 'PS' then psfc=data/100.
    if result.name eq 'T' or result.name eq 'U' or result.name eq 'V' then $
       ncdf_varget,ncid,ncdf_varid(ncid,result.name),data, OFFSET=[0,0,0,itime], COUNT=[nc,nr,nl,1]
    if result.name eq 'T' then tl=data
    if result.name eq 'U' then ul=data
    if result.name eq 'V' then vl=data
;   print,ivar,result.name,min(data),max(data)
endfor
for ivar=0,result2.nvars-1 do begin
    result=ncdf_varinq(ncid2,ivar)
    if result.name ne 'CH4' and result.name ne 'NOY' and result.name ne 'O3' then $
       ncdf_varget,ncid2,ncdf_varid(ncid2,result.name),data
    if result.name eq 'CH4' or result.name eq 'NOY' or result.name eq 'O3' then $
       ncdf_varget,ncid2,ncdf_varid(ncid2,result.name),data, OFFSET=[0,0,0,itime], COUNT=[nc,nr,nl,1]
    if result.name eq 'CH4' then ch4=data
    if result.name eq 'NOY' then noy=data
    if result.name eq 'O3' then  o3=data
;   print,ivar,result.name,min(data),max(data)
endfor
;
; windspeed
;
sl=sqrt(ul^2.0+vl^2.0)
;
; calculate Pressure prl(i,j,k) = A(k)*PO + B(k)*PS(i,j)
;
prl=fltarr(nc,nr,nl)
Pzero=P0/100.
FOR ilon=0,nc-1 DO $
    FOR ilat=0,nr-1 DO $
        FOR ialt=0,nl-1 DO $
            prl(ilon,ilat,ialt)=hyam(ialt)*Pzero + hybm(ialt)*PSFC(ilon,ilat,itime)
;
; calculate theta, absolute vorticity
;
thl=0.*tl
for L=0L,NL-1L do $
    THL(*,*,L)=TL(*,*,L)*(1000./PRL(*,*,L))^.286
eta=0.*tl
compvort,ul,vl,eta,alon,alat,nc,nr
;
; LOOP OVER LATITUDES
;
pv=0.*tl
qdf=0.*tl
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
; COMPUTE QDF, ISENTROPIC POTENTIAL VORTICITY ON PRESSURE SURFACE
;
        for K=0,NL-1L do begin
            LM1=K-1
            LP1=K+1
            IF K EQ 0 then LM1=0
            IF K EQ NL-1L then LP1=NL-1L
            DTHDP=(THL(I,LAT,LP1)-THL(I,LAT,LM1))/(PRL(I,LAT,LP1)-PRL(I,LAT,LM1))
            DUDP=(ul(I,LAT,LP1)-ul(I,LAT,LM1))/(PRL(I,LAT,LP1)-PRL(I,LAT,LM1))
            DVDP=(vl(I,LAT,LP1)-vl(I,LAT,LM1))/(PRL(I,LAT,LP1)-PRL(I,LAT,LM1))
            DTHDX=(4./3.)*(THL(IP1,LAT,K)-THL(IM1,LAT,K))/DX1 - $
                  (1./3.)*(THL(IP2,LAT,K)-THL(IM2,LAT,K))/DX2
            IF LAT LE 1 OR LAT GE NR-2 THEN begin
               DTHDY=(THL(I,JP1,K)-THL(I,JM1,K))/DY1
            endif
            IF LAT gt 1 and LAT lt NR-2 THEN begin
               DTHDY=(4./3.)*(THL(I,JP1,K)-THL(I,JM1,K))/DY1 - $
                     (1./3.)*(THL(I,JP2,K)-THL(I,JM2,K))/DY2
            ENDIF
            IF DTHDP GE 0. THEN begin
               PV(I,LAT,K)=1.E12
            endif
            IF DTHDP lt 0. THEN begin
               PV(I,LAT,K)=eta(I,LAT,K)-(DUDP*DTHDY-DVDP*DTHDX)/DTHDP
               PV(I,LAT,K)=-9.8*DTHDP*PV(I,LAT,K)/100.
            ENDIF

; normalized by RADEA. The signed sqrt of Q is taken.
            arg1 = (ul(IP1,LAT,K)-ul(IM1,LAT,K))/DX1 $
                  - vl(I,LAT,K)*TAN(ALAT(LAT)*DTR)/RADEA
            arg2 = (vl(IP1,LAT,K)-vl(IM1,LAT,K))/DX1 $
                  + ul(I,LAT,K)*TAN(ALAT(LAT)*DTR)/RADEA
            DVDY = (vl(I,JP1,K)-vl(I,JM1,K))/DY1
            DUDY = (ul(I,JP1,K)-ul(I,JM1,K))/DY1
            if abs(arg1) gt 1.e12 or abs(arg2) gt 1.e12 then QDF(I,LAT,K) = 1.e12
            if abs(arg1) lt 1.e12 and abs(arg2) lt 1.e12 then begin
               qtemp=(0.5*(arg1*arg1+DVDY*DVDY)+arg2*DUDY)*RADEA*RADEA
               if qtemp ge 0.0 then QDF(I,LAT,K) = sqrt(qtemp)
               if qtemp lt 0.0 then QDF(I,LAT,K) = -sqrt(-qtemp)
            endif
        endfor
    endfor
endfor
;
; check
; 
slyz=fltarr(nr,nl)
ulyz=fltarr(nr,nl)
tlyz=fltarr(nr,nl)
for j=0,nr-1L do begin
for k=0,nl-1L do begin
    slyz(j,k)=total(sl(*,j,k))/float(nc)
    ulyz(j,k)=total(ul(*,j,k))/float(nc)
    tlyz(j,k)=total(tl(*,j,k))/float(nc)
endfor
endfor
sdate=strcompress(string(date(itime)),/remove_all)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='waccm_'+sdate+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=min(ulyz)+((max(ulyz)-min(ulyz))/float(nlvls))*findgen(nlvls)
!type=2^2+2^3
contour,ulyz,alat,lev,levels=level,/cell_fill,c_color=col1,/noeras,yrange=[1000.,0.0001],$
        xrange=[-90.,90.],title=sdate,/ylog
contour,ulyz,alat,lev,levels=level,/follow,c_color=0,/noeras,/overplot
contour,ulyz,alat,lev,levels=[0.],/follow,c_color=0,thick=3,/noeras,/overplot
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],$
      xtitle='WACCM Zonal Mean Windspeed',charsize=2,/noeras
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
tmin=100.
tmax=300.
level=tmin+((tmax-tmin)/float(nlvls))*findgen(nlvls)
!type=2^2+2^3
contour,tlyz,alat,lev,levels=level,/cell_fill,c_color=col1,/noeras,yrange=[1000.,0.0001],$
        xrange=[-90.,90.],/ylog
contour,tlyz,alat,lev,levels=level,/follow,c_color=0,/noeras,/overplot
contour,tlyz,alat,lev,levels=[0.],/follow,c_color=0,thick=3,/noeras,/overplot
imin=min(level)
imax=max(level)
ymnb=yorig(1) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],$
      xtitle='WACCM Zonal Mean Temperature',charsize=2,/noeras
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor


if setplot eq 'ps' then device, /close
if setplot ne 'ps' then wait,1.

ENDFOR		; LOOP OVER TIMESTEPS
ncdf_close,ncid
ncdf_close,ncid2
end
