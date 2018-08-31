;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; profiles of WACCM NO from mee00fco run
; VLH 1/11/2011
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
loadct,39
mcolor=byte(!p.color)
!NOERAS=-1
device,decompose=0
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.20]
xlen=0.8
ylen=0.6
cbaryoff=0.075
cbarydel=0.01
!NOERAS=-1
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif

a=findgen(8)*(!pi/8.)
usersym,cos(a),sin(a),/fill
dir='/Volumes/External_Ethan/WACCM3/mee00fco/mee00fco.vars.h3.'
rtd=double(180./!pi)
dtr=1./rtd
ks=1.931853d-3
ecc=0.081819
gamma45=9.80
;
iyears=2030+indgen(50)
iyears=2060
syears=strcompress(long(iyears),/remove_all)
nyears=n_elements(syears)
for iyear=0L,nyears-1L do begin
;
; read WACCM data
;
    ncfile0=dir+syears(iyear)+'.nc'
    print,ncfile0
    ncid=ncdf_open(ncfile0)
    result0=ncdf_inquire(ncid)
    for idim=0,result0.ndims-1 do begin
        ncdf_diminq,ncid,idim,name,dim
        if name eq 'lon' then nc=dim
        if name eq 'lat' then nr=dim
        if name eq 'lev' then nl=dim
        if name eq 'time' then nt=dim
;       print,'read ',name,' dimension ',dim
    endfor
    for ivar=0,result0.nvars-1 do begin
        result=ncdf_varinq(ncid,ivar)
        if result.name eq 'V' or result.name eq 'U' or result.name eq 'OMEGA' or result.name eq 'NOX' or result.name eq 'NOY' or $
           result.name eq 'O3' or result.name eq 'QSUM' then goto,jumpvar1
        ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
        if result.name eq 'P0' then p0=data
        if result.name eq 'hyai' then hyai=data
        if result.name eq 'hybi' then hybi=data
        if result.name eq 'hyam' then hyam=data
        if result.name eq 'hybm' then hybm=data
        if result.name eq 'PS' then psfc=data     ;/100.
        if result.name eq 'lat' then lat=data
        if result.name eq 'lon' then lon=data
        if result.name eq 'lev' then lev=data
        if result.name eq 'time' then time=data
        if result.name eq 'date' then date=data
        if result.name eq 'T' then tgrd=data
        if result.name eq 'U' then ugrd=data
        if result.name eq 'V' then vgrd=data
        if result.name eq 'OMEGA' then omegagrd=data
        if result.name eq 'NOX' then noxgrd=data
        if result.name eq 'NOY' then noygrd=data
        if result.name eq 'O3' then o3grd=data
        if result.name eq 'Z3' then ggrd=data/1000.
        if result.name eq 'QSUM' then qgrd=data
        print,ivar,result.name,min(data),max(data)
jumpvar1:
    endfor
    ncdf_close,ncid
    sdate=strcompress(date,/remove_all)
;
;============================================================
; Calculate Pressure : pgrd(i,j,k) = A(k)*PO + B(k)*PS(i,j)
;============================================================
    pgrd        = fltarr(nc,nr,nl,nt)
    Pzero       = P0      ;/100.
    FOR ilon = 0, nc-1 DO $
        FOR ilat = 0, nr-1 DO $
            FOR ialt = 0, nl-1 DO $
                pgrd(ilon,ilat,ialt,*) = hyam(ialt)*Pzero + hybm(ialt)*PSFC(ilon,ilat)
;
; read NO and NO2 and CO
;
    ncfile0=dir+syears(iyear)+'.chems.nc'
    print,ncfile0
    ncid=ncdf_open(ncfile0)
    result0=ncdf_inquire(ncid)
    for ivar=0,result0.nvars-1 do begin
        result=ncdf_varinq(ncid,ivar)
        if result.name eq 'CLONO2' or result.name eq 'CH4' or result.name eq 'NO2' then goto,jumpvar2
        ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
        if result.name eq 'NO' then nogrd=data
        if result.name eq 'CO' then cogrd=data
        print,ivar,result.name,min(data),max(data)
jumpvar2:
    endfor
    ncdf_close,ncid
;
; compute atmospheric density
; p=rho R T -> rho=P/RT where R=287 J/K kg. Pressure in Pascals.
;
    rhogrd=pgrd/(tgrd*287.)
;
; define profile arrays
;
       p_prof=-99.+fltarr(nr,nl)
       z_prof=-99.+fltarr(nr,nl)
       gp_prof=-99.+fltarr(nr,nl)
       tp_prof=-99.+fltarr(nr,nl)
       co_prof=-99.+fltarr(nr,nl)
       o3_prof=-99.+fltarr(nr,nl)
       o2_prof=-99.+fltarr(nr,nl)
       no_prof=-99.+fltarr(nr,nl)
       no2_prof=-99.+fltarr(nr,nl)
       u_prof=-99.+fltarr(nr,nl)
       v_prof=-99.+fltarr(nr,nl)
       omega_prof=-99.+fltarr(nr,nl)
       rho_prof=-99.+fltarr(nr,nl)
;
; convert to molecules/cm3
;
    nogrd=nogrd * (1./29.) * (1000./1.) * rhogrd * 6.022e23 / 1.e6 ; divide by 1.e6 for m-3 to cm-3
;   no2grd=no2grd * (1./29.) * (1000./1.) * rhogrd * 6.022e23 / 1.e6
;   o3grd=o3grd * (1./29.) * (1000./1.) * rhogrd * 6.022e23 / 1.e6
;   cogrd=cogrd * (1./29.) * (1000./1.) * rhogrd * 6.022e23 / 1.e6
;   o2grd=o2grd * (1./29.) * (1000./1.) * rhogrd * 6.022e23 / 1.e6
;
; convert geopotential to geometric height
;
    zgrd=0.*ggrd
    for j=0L,nr-1L do begin
        sin2=sin( (lat(j)*dtr)^2.0 )
        numerator=1.0+ks*sin2
        denominator=sqrt( 1.0 - (ecc^2.0)*sin2 )
        gammas=gamma45*(numerator/denominator)
        r=6378.137/(1.006803-(0.006706*sin2))
        zgrd(*,j,*,*)=(r*ggrd(*,j,*,*))/ ( (gammas/gamma45)*r - ggrd(*,j,*,*) )
    endfor
;
; daily zonal averages
;
nhindex=where(lat ge 60.)
    for n=0L,90	do begin	;nt-1L do begin
        for k=0,nl-1L do begin
        for j=0,nr-1L do begin
            no_prof(j,k)=mean(nogrd(*,j,k,n))
            co_prof(j,k)=mean(cogrd(*,j,k,n))
        endfor
        endfor
nogrd3d=reform(nogrd(*,*,*,n))
zgrd3d=reform(zgrd(*,*,*,n))
;
; plot
;
; save postscript version
    if setplot eq 'ps' then begin
       set_plot,'ps'
       !p.charsize=2
       !p.thick=2
       !p.charthick=5
       !p.charthick=5
       !y.thick=2
       !x.thick=2
       xsize=nxdim/100.
       ysize=nydim/100.
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/helvetica,filename='profs_no_mee00fco_'+sdate(n)+'.ps'
    endif

    erase
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    nlvls=31
imin=1.e6
imax=1.e9
    level=imin+((imax-imin)/float(nlvls))*findgen(nlvls)
    col1=1+indgen(nlvls)*mcolor/nlvls
plot,nogrd3d(0,nhindex(0),*),zgrd3d(0,nhindex(0),*),yrange=[50.,130.],xrange=[imin,imax],/xlog,color=0,ytitle='Altitude (km)',xtitle='NO (molec/cm3) > 60 N',title=sdate(n)
for i=0L,nc-1 do for j=0,n_elements(nhindex)-1 do oplot,nogrd3d(i,nhindex(j),*),zgrd3d(i,nhindex(j),*),color=0

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim profs_no_mee00fco_'+sdate(n)+'.ps -rotate -90 profs_no_mee00fco_'+sdate(n)+'.jpg'
       spawn,'rm -f profs_no_mee00fco_'+sdate(n)+'.ps'
    endif
endfor		; loop over days
endfor		; loop over years
end
