;
; plot x and y centroids
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
; ES day zeros
;
dir='/Volumes/earth/harvey/WACCM_data/Datfiles/Datfiles_WACCM4/mee00fpl_FW2.cam2.h3.dyns.'
esdates=[20041218,20060130,20151221,20231223,20261210,20320204,20331220,20390226,20420104]
kcount=0L
nevents=n_elements(esdates)
for iES = 0L, nevents - 1L do begin
    sevent=string(format='(i2.2)',ies+1)
    sevent=strtrim(strcompress(string(format='(I3.2)',ies+1)),2)
    restore,'/Users/harvey/Harvey_etal_2014/Post_process/waccm_zt_vmoment_ES_event_'+sevent+'.sav'	;,nvort_all,ellip_all,xcentroid_all,ycentroid_all,th2r,sdate_all,altarray
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
              /bold,/color,bits_per_pixel=8,/times,filename='../Figures/waccm_zt_centroids_ES_event_'+sevent+'.ps'
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
set_viewport,0.2,0.8,0.55,0.9
nlvls=13
col1=1+indgen(nlvls)*icolmax/nlvls
level=-180.+30*findgen(nlvls)
contour,smooth(xcentroid_all,3,/edge_truncate,/nan),-30+findgen(ndays),altarray,xrange=[-30,30],yrange=[10.,70.],c_color=col1,/cell_fill,levels=level,$
        ytitle='Approximate Altitude (km)',/noeras,color=0,charsize=1.5,charthick=2
index=where(nvort_all gt 1)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=0,symsize=0.5
!type=2^2+2^3+2^5
cbaryoff=0.1
cbarydel=0.01
imin=min(level)
imax=max(level)
xmnb=0.8 +cbaryoff
xmxb=xmnb  +cbarydel
set_viewport,xmnb,xmxb,0.55,0.9
!type=2^2+2^3+2^5
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,$
      ytitle='Degrees Longitude',charthick=2,charsize=1.5
xbox=[0,10,10,0,0]
y1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
ybox=[y1,y1,y1+dy,y1+dy,y1]
polyfill,xbox,ybox,color=col1(j)
y1=y1+dy
endfor

!type=2^2+2^3
set_viewport,0.2,0.8,0.15,0.5
nlvls=21
col1=1+indgen(nlvls)*icolmax/nlvls
level=40.+2.5*findgen(nlvls)
contour,smooth(ycentroid_all,3,/edge_truncate,/nan),-30+findgen(ndays),altarray,xrange=[-30,30],yrange=[10.,70.],c_color=col1,/cell_fill,levels=level,$
        xtitle='Days since ES onset (MY'+strmid(sdate_all(30),2,2)+')',ytitle='Approximate Altitude (km)',/noeras,color=0,charsize=1.5,charthick=2
index=where(nvort_all gt 1)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=0,symsize=0.5
!type=2^2+2^3+2^5
imin=min(level)
imax=max(level)
xmnb=0.8 +cbaryoff
xmxb=xmnb  +cbarydel
set_viewport,xmnb,xmxb,0.15,0.5
!type=2^2+2^3+2^5
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,$
      ytitle='Degrees Latitude',charthick=2,charsize=1.5
xbox=[0,10,10,0,0]
y1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
ybox=[y1,y1,y1+dy,y1+dy,y1]
polyfill,xbox,ybox,color=col1(j)
y1=y1+dy
endfor


    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim ../Figures/waccm_zt_centroids_ES_event_'+sevent+'.ps -rotate -90 ../Figures/waccm_zt_centroids_ES_event_'+sevent+'.png'
       spawn,'rm -f ../Figures/waccm_zt_centroids_ES_event_'+sevent+'.ps'
    endif
endfor		; loop over ES events
end
