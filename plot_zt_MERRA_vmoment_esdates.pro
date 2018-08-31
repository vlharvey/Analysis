;
; plot number of cyclonic lobes in the NH on each level each day and ellipticity
;
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
loadct,39
mcolor=!p.color
icolmax=255
mcolor=icolmax
device,decompose=0
!NOERAS=-1
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nzdim,ysize=nydim,retain=2,colors=162
endif
;
; Read ES day zeros
;
restore, '/Users/harvey/Harvey_etal_2014/Post_process/MLS_ES_daily_max_T_Z.sav'
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
kcount=0L
result=size(MAXHEIGHTTHETA)
nevents=result(1)
for iES = 0L, nevents - 1L do begin
    sevent=string(format='(i2.2)',ies+1)
    sevent=strtrim(strcompress(string(format='(I3.2)',ies+1)),2)
    restore,'/Users/harvey/Harvey_etal_2014/Post_process/merra_zt_vmoment_ES_event_'+sevent+'.sav'	;,nvort_all,ellip_all,xcentroid_all,ycentroid_all,th2r,sdate_all,altarray
    nz=n_elements(altarray)
    ndays=n_elements(sdate_all)
    set_viewport,0.3,0.7,0.1,0.4
    x2d=fltarr(ndays,nz)
    y2d=fltarr(ndays,nz)
    for i=0,ndays-1 do y2d(i,*)=altarray
    for j=0,nz-1 do x2d(*,j)=-30+findgen(ndays)
;
; save postscript version
;
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/times,filename='../Figures/merra_zt_nvort_ES_event_'+sevent+'.ps'
       !p.charsize=1.25
       !p.thick=2
       !p.charthick=5
       !p.charthick=5
       !y.thick=2
       !x.thick=2
    endif

index=where(ellip_all eq 0.)
if index(0) ne -1L then ellip_all(index)=0./0.
erase
!type=2^2+2^3
set_viewport,0.2,0.9,0.3,0.7
contour,nvort_all,-30+findgen(ndays),altarray,/nodata,xrange=[-30,30],yrange=[10.,70.],$
        xtitle='Days since ES onset ('+strmid(sdate_all(30),0,4)+')',ytitle='Approximate Altitude (km)',/noeras,color=0,charsize=1.5,charthick=2
contour,smooth(ellip_all,5,/edge_truncate),-30+findgen(ndays),altarray,/overplot,level=0.2*findgen(6),/follow,thick=5,color=0,/nodata
contour,smooth(ellip_all,5,/edge_truncate,/Nan),-30+findgen(ndays),altarray,/overplot,level=0.1,/follow,thick=25,color=10           
contour,smooth(ellip_all,5,/edge_truncate,/Nan),-30+findgen(ndays),altarray,/overplot,level=0.2,/follow,thick=25,color=50           
contour,smooth(ellip_all,5,/edge_truncate,/Nan),-30+findgen(ndays),altarray,/overplot,level=0.4,/follow,thick=25,color=100
contour,smooth(ellip_all,5,/edge_truncate,/Nan),-30+findgen(ndays),altarray,/overplot,level=0.6,/follow,thick=25,color=150
contour,smooth(ellip_all,5,/edge_truncate,/Nan),-30+findgen(ndays),altarray,/overplot,level=0.8,/follow,thick=25,color=200
contour,smooth(ellip_all,5,/edge_truncate,/Nan),-30+findgen(ndays),altarray,/overplot,level=0.9,/follow,thick=25,color=250
index=where(nvort_all gt 1)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=0,symsize=0.5

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim ../Figures/merra_zt_nvort_ES_event_'+sevent+'.ps -rotate -90 ../Figures/merra_zt_nvort_ES_event_'+sevent+'.png'
       spawn,'rm -f ../Figures/merra_zt_nvort_ES_event_'+sevent+'.ps'
    endif
endfor		; loop over ES events
end
