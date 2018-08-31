;
; plot average temperature differences from 15 Jan to 28 Feb
; wrt MLS for HIRDLS, SABER, and GEOS-5
; (construct from data interpolated to satellite locations)
;
@stddat
@kgmt
@ckday
@kdate

loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
setplot='ps'
read,'setplot=',setplot
nxdim=600
nydim=600
xorig=[0.25]
yorig=[0.15]
xlen=0.5
ylen=0.7
cbaryoff=0.08
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
restore,'zt_mls_tbar.sav'
TBAR_ZT_MLS=TBAR_ZT
SDATE_ALL_MLS=SDATE_ALL
ALTITUDE_MLS=ALTITUDE
restore,'zt_geos5_at_mls_tbar.sav'
TBAR_ZT_GEOS=TBAR_ZT
SDATE_ALL_GEOS=SDATE_ALL
restore,'zt_saber_tbar.sav'
TBAR_ZT_SABER=TBAR_ZT
SDATE_ALL_SABER=SDATE_ALL
zindex=where(altitude le max(altitude_mls))
TBAR_ZT_SABER=reform(TBAR_ZT_SABER(*,zindex,*))
restore,'zt_hirdls_tbar.sav'
TBAR_ZT_HIRDLS=TBAR_ZT
SDATE_ALL_HIRDLS=SDATE_ALL
nz=n_elements(altitude)
nlat=n_elements(latbin)
;
; user entered date range
;
print,SDATE_ALL_MLS
idate0=20080115L
idate1=20080315L
;read,' Enter starting date (YYYYMMDD) ',idate0
;read,' Enter ending date   (YYYYMMDD) ',idate1
index0=where(long(sdate_all_mls) eq idate0)
index1=where(long(sdate_all_mls) eq idate1)
sdate0=sdate_all_mls(index0(0))
sdate1=sdate_all_mls(index1(0))
;
; loop over latitude
;
for j=nlat-10L,nlat-1L do begin
    slat=strcompress(long(latbin(j)),/remove_all)+'N'
;
; extract latitude from tbar_zt
; TBAR_ZT         FLOAT     = Array[35, 121, 61]
;
    t2d_mls=reform(tbar_zt_mls(j,*,index0(0):index1(0)))
    t2d_geos=reform(tbar_zt_geos(j,*,index0(0):index1(0)))
    t2d_saber=reform(tbar_zt_saber(j,*,index0(0):index1(0)))
    t2d_hirdls=reform(tbar_zt_hirdls(j,*,index0(0):index1(0)))
;
; construct time-averaged temperature profiles for MLS, HIRDLS, SABER, 
; and GEOS for this latitude over date range.  remove days where there is no data. 
;
    tavg_mls=fltarr(nz)
    tavg_geos=fltarr(nz)
    tavg_saber=fltarr(nz)
    tavg_hirdls=fltarr(nz)
    for k=0,nz-1L do begin
        good=where(T2D_MLS(k,*) ne 0.,ngood)
        if good(0) ne -1 then tavg=total(T2D_MLS(k,good))/float(ngood)
        if good(0) ne -1 then tavg_mls(k)=tavg
        good=where(T2D_GEOS(k,*) ne 0.,ngood)
        if good(0) ne -1 then tavg=total(T2D_GEOS(k,good))/float(ngood)
        if good(0) ne -1 then tavg_geos(k)=tavg
        good=where(T2D_SABER(k,*) ne 0.,ngood)
        if good(0) ne -1 then tavg=total(T2D_SABER(k,good))/float(ngood)
        if good(0) ne -1 then tavg_saber(k)=tavg
        good=where(T2D_HIRDLS(k,*) ne 0.,ngood)
        if good(0) ne -1 then tavg=total(T2D_HIRDLS(k,good))/float(ngood)
        if good(0) ne -1 then tavg_hirdls(k)=tavg
;if tavg_mls(k) ne 0. then print,tavg_mls(k),tavg_geos(k),tavg_saber(k),tavg_hirdls(k)
    endfor

    if setplot eq 'ps' then begin
       lc=0
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='profile_mls-geos5_saber_hirdls_tdiff_'+slat+'_'+sdate0+'-'+sdate1+'.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
;
; plot zonal mean temperature and z'
;
    erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    tdiff=0.*tavg_mls
    index=where(tavg_mls ne 0. and tavg_geos ne 0.)
    if index(0) eq -1L then goto,jumplat
    tdiff(index)=tavg_geos(index)-tavg_mls(index)
    plot,tdiff,altitude,/noeras,xrange=[-10.,10.],yrange=[20.,60.],charthick=2,$
          charsize=1.5,color=0,ytitle='Altitude (km)',title=sdate0+'-'+sdate1+'  '+slat,$
          xtitle='Temperature difference',thick=3
    index=where(tavg_mls ne 0. and tavg_saber ne 0.)
    if index(0) eq -1L then goto,jumplat
    tdiff(index)=tavg_saber(index)-tavg_mls(index)
    oplot,tdiff,altitude,color=250,thick=3
    index=where(tavg_mls ne 0. and tavg_hirdls ne 0.)
    if index(0) eq -1L then goto,jumplat
    tdiff(index)=tavg_hirdls(index)-tavg_mls(index)
    oplot,tdiff,altitude,color=100,thick=3
    plots,0.,20.
    plots,0.,60.,/continue,color=0
    xyouts,-9.,25.,'MLS - GEOS5',charthick=2,color=0,/data,charsize=1.5
    xyouts,-9.,23.,'MLS - SABER',charthick=2,color=250,/data,charsize=1.5
    xyouts,-9.,21.,'MLS - HIRDLS',charthick=2,color=100,/data,charsize=1.5

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim profile_mls-geos5_saber_hirdls_tdiff_'+slat+'_'+sdate0+'-'+sdate1+'.ps '+$
             '-rotate -90 profile_mls-geos5_saber_hirdls_tdiff_'+slat+'_'+sdate0+'-'+sdate1+'.jpg'
    endif
    jumplat:
endfor	; loop over latitude
end
