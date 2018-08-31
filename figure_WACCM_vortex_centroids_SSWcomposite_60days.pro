;---------------------------------------------------------------------------------------------------
; xcentroid and ycentroid from Greer moment diagnostics
; Reads in WACCM data and plots zonal and meridional centroids of the Arctic vortex (tilt with altitude) 
; -30 to +30 days around composite SSW event
;
;	 -------------------------------
;       |         Lynn Harvey           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 11/24/2012      |
;	 -------------------------------
;
@stddat			; Determines the number of days since Jan 1, 1956
@kgmt			; This function computes the Julian day number (GMT) from the
@ckday			; This routine changes the Julian day from 365(6 if leap yr)
@kdate			; gives back kmn,kdy information from the Julian day #.
@vortexshape

;-----------------------------------------------------

SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.2,0.2]	;,0.2]
yorig=[0.6,0.2]	;,0.1]
xlen=0.5
ylen=0.3
cbaryoff=0.12
cbarydel=0.01

a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
loadct,39
mcolor=!p.color
icolmax=255
mcolor=icolmax
icmm1=icolmax-1B
icmm2=icolmax-2B
device,decompose=0
!NOERAS=-1
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
days = 0
months = ['Apr','May','Jun','Jul','Aug','Sep','Oct','Nov']
MONTH = ['04','05','06','07','08','09','10','11']
;
; save postscript version
;
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/times,filename='../Figures/waccm_vortex_centroids_SSW_composite.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
ndays = 61L
dayofES = 1L
niday = 0L
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
restore,'/Users/harvey/Harvey_etal_2014/Post_process/SSW_composite_days_waccm_dm30-dp30.sav' ;,alon,alat,th,nc,nr,nth,pv2_comp,p2_comp,u2_comp,v2_comp,qdf2_comp,q2_comp,gph2_comp,ttgw2_comp,sf2_comp,mark2_comp
;
; wrap around point
;
lons = fltarr(nc+1L)
lons[0:nc-1L] = alon
lons[nc] = alon[0L]
;
; coordinate transformation
;
nr2=nr/2
x2d=fltarr(nc+1,nr/2)
y2d=fltarr(nc+1,nr/2)
for i=0,nc do y2d(i,*)=alat(nr/2:nr-1)
for j=0,nr/2-1 do x2d(*,j)=lons
xcn=fltarr(nc+1,nr2)
ycn=fltarr(nc+1,nr2)
for j=nr2,nr-1 do begin
    ANG = (90. - alat(j)) * RADG * 0.5
    FACTOR = TAN(ANG) * FAC20
    for i=0,nc do begin
        THETA = (lons(i) - 90.) * RADG
        xcn(i,j-nr2) = FACTOR * COS(THETA)
        ycn(i,j-nr2) = FACTOR * SIN(THETA)
    endfor
endfor
;
sdays=string(format='(I3.2)',-30+indgen(ndays))
erase
!type=2^2+2^3
sdays=strarr(ndays)
xphase=fltarr(ndays,nth)
yphase=fltarr(ndays,nth)
nvort_all=fltarr(ndays,nth)
ellip_all=fltarr(ndays,nth)

for iday=0,60L do begin
        iday0=iday-30
        if iday0 lt 0L then sday=string(format='(i3.2)',iday0)
        if iday0 ge 0L then sday=string(format='(i2.2)',iday0)
        sdays(iday)=sday
;
; read daily file
;
        pv2=reform(pv2_comp(*,*,*,iday))
        p2=reform(p2_comp(*,*,*,iday))
        u2=reform(u2_comp(*,*,*,iday))
        v2=reform(v2_comp(*,*,*,iday))
        qdf2=reform(qdf2_comp(*,*,*,iday))
        q2=reform(q2_comp(*,*,*,iday))
        gph2=reform(gph2_comp(*,*,*,iday))
        ttgw2=reform(ttgw2_comp(*,*,*,iday))
        sf2=reform(sf2_comp(*,*,*,iday))
        mark2=reform(mark2_comp(*,*,*,iday))
;
; find vortex centroids, ellipticity
;
        marker_USLM = make_array(nc,nr,nth)
        for k=0,nth-1 do begin
            marker_USLM(*,*,k) = transpose(mark2(*,*,k))
        endfor
        shape = vortexshape(marker_USLM, alat, alon)
        centroid=shape.nhcentroid
        centroidx=reform(centroid(0,*))
        centroidy=reform(centroid(1,*))
        axis=shape.axis
        majoraxis=reform(axis(0,*))
        minoraxis=reform(axis(1,*))
        ellipticity=minoraxis/majoraxis
;print,iday,'ellipticity= ',ellipticity
;print,iday,'xcentroid= ',centroidx
;print,iday,'ycentroid= ',centroidy
;stop

        xphase(iday,*)=centroidx
        yphase(iday,*)=centroidy
;
; loop over altitude
;
       altarray=fltarr(nth)
        nr2=nr/2
 	for ii = 0L, nth - 1L do begin
            waccmdailymark = transpose(reform(mark2[nr2:nr-1,*,nth-1L-ii]))
            marker=fltarr(nc+1L,nr2)
            marker[0L:nc-1L,*] = waccmdailymark
            marker[nc,*] = marker(0,*)
            sf=fltarr(nc+1L,nr2)
            sf[0L:nc-1L,*] = transpose(reform(sf2[nr2:nr-1,*,nth-1L-ii]))
            sf[nc,*] = sf(0,*)
            z=fltarr(nc+1L,nr2)
            z[0L:nc-1L,*] = transpose(reform(gph2[nr2:nr-1,*,nth-1L-ii]))
            z[nc,*] = z(0,*)
            index=where(marker gt 0.)
            if index(0) ne -1L then altarray(ii)=mean(z(index))/1000.
;
; histograms of vortex latitude and longitude
;
!type=2^2+2^3
py1=fltarr(nc)
px1=fltarr(nr)
for i=0L,nc-1L do begin
    index=where(marker(i,*) gt 0.,nn)
    py1(i)=float(nn)
endfor
for j=0L,nr-1L do begin
    index=where(mark2(j,*,nth-1L-ii) gt 0.,nn)
    px1(j)=float(nn)
endfor
;
; are there two cyclonic vortices?
;
n0=findgen(nc)
n1=1.+findgen(nc)
vortlon=0.*alon
index=where(py1 ne 0.)
if index(0) ne -1L then vortlon(index)=1.
index=where(abs(vortlon(n0)-vortlon(n1)) gt 0.,nv)
nextra=1
if nv eq 0L then nv=2                   ; circumpolar has no zeros. set to 2 to get 1 vortex
index=where(vortlon eq 1.)
if min(alon(index)) eq min(alon) and max(alon(index)) ne max(alon) then nextra=0        ; GM edge
if min(alon(index)) ne min(alon) and max(alon(index)) eq max(alon) then nextra=0        ; GM edge
if nv gt 2L then begin
   nextra=0.5*nv                ; each vortex results in 2 edge points - unless it lies exactly along the GM
;  if min(alon(index)) eq min(alon) and max(alon(index)) ne max(alon) then nextra=0        ; GM edge
;  if min(alon(index)) ne min(alon) and max(alon(index)) eq max(alon) then nextra=0        ; GM edge
endif
nv=round(nv-nextra)
nvort_all(iday,nth-1L-ii)=nv
        endfor          ; loop over altitude
;
; set moments to NaN where there are multiple vortices
;
index=where(nvort_all(iday,*) gt 1.)
if index(0) ne -1L then begin
ellipticity(index)=0./0.
xphase(iday,index)=0./0.
yphase(iday,index)=0./0.
endif
ellip_all(iday,*)=ellipticity
print,iday,max(nvort_all(iday,*)),max(ellip_all(iday,*))

     endfor		; loop over days 
;
; save
;
save,filename='waccm_composite_vmoments.sav',sdays,xphase,yphase,nvort_all,ellip_all,th,altarray
;
; longitude phase
;
index=where(xphase gt 180.)
xphase(index)=xphase(index)-360.
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
nlvls=13
col1=1+indgen(nlvls)*icolmax/nlvls
level=-180+30.*findgen(nlvls)
index=where(xphase eq 0.)
if index(0) ne -1L then xphase(index)=0./0.
xphase=smooth(xphase,3,/nan)
contour,xphase,-30.+findgen(ndays),th,c_color=col1,/cell_fill,xtitle='Days From SSW Onset',ytitle='Theta (K)',xrange=[-30.,30.],$
        color=0,yrange=[500.,5000.],title='WACCM Vortex Centroid Longitude',levels=level,charsize=1.5,charthick=2
index=where(level ge 0.)
contour,xphase,-30.+findgen(ndays),th,color=0,/follow,/overplot,levels=level(index)
index=where(level lt 0.)
contour,xphase,-30.+findgen(ndays),th,color=mcolor,/follow,/overplot,levels=level(index),c_linestyle=5
;plots,0,500
;plots,0,5000,/continue,/data,color=mcolor,thick=5
xmax=30.
xyouts,xmax+7.,500.,'Approximate Altitude (km)',color=0,/data,orientation=90.,charsize=1.25,charthick=2
xyouts,xmax+1.,500.,'20',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,800.,'30',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,1400.,'40',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,2000.,'50',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,3000.,'60',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,4000.,'70',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,5000.,'80',color=0,/data,charsize=1.5,charthick=2

imin=min(level)
imax=max(level)
xmnb=xorig(0)+xlen +cbaryoff
xmxb=xmnb  +cbarydel
set_viewport,xmnb,xmxb,ymn,ymx
!type=2^2+2^3+2^5
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,$
      xtitle='Degrees Longitude',charthick=2,charsize=1.5
xbox=[0,10,10,0,0]
y1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
ybox=[y1,y1,y1+dy,y1+dy,y1]
polyfill,xbox,ybox,color=col1(j)
y1=y1+dy
endfor
;
; latitude phase
;
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
nlvls=21
col1=1+indgen(nlvls)*icolmax/nlvls
level=40.+2.5*findgen(nlvls)
index=where(yphase eq 0.)
if index(0) ne -1L then yphase(index)=0./0.
yphase=smooth(yphase,3,/nan)
contour,yphase,-30.+findgen(ndays),th,c_color=col1,/cell_fill,xtitle='Days From SSW Onset',ytitle='Theta (K)',xrange=[-30.,30.],$
        color=0,yrange=[500.,5000.],title='WACCM Vortex Centroid Latitude',levels=level,charsize=1.5,charthick=2
contour,yphase,-30.+findgen(ndays),th,color=0,/follow,/overplot,levels=level	;,C_ANNOTATION=string(long(level))
;plots,0,500
;plots,0,5000,/continue,/data,color=mcolor,thick=5
xmax=30.
xyouts,xmax+7.,500.,'Approximate Altitude (km)',color=0,/data,orientation=90.,charsize=1.25,charthick=2
xyouts,xmax+1.,500.,'20',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,800.,'30',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,1400.,'40',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,2000.,'50',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,3000.,'60',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,4000.,'70',color=0,/data,charsize=1.5,charthick=2
xyouts,xmax+1.,5000.,'80',color=0,/data,charsize=1.5,charthick=2

imin=min(level)
imax=max(level)
xmnb=xorig(0)+xlen +cbaryoff
xmxb=xmnb  +cbarydel
set_viewport,xmnb,xmxb,ymn,ymx
!type=2^2+2^3+2^5
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,$
      xtitle='Degrees Longitude',charthick=2,charsize=1.5
xbox=[0,10,10,0,0]
y1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
ybox=[y1,y1,y1+dy,y1+dy,y1]
polyfill,xbox,ybox,color=col1(j)
y1=y1+dy
endfor
;
; ellipticity
;;
;xmn=xorig(2)
;xmx=xorig(2)+xlen
;ymn=yorig(2)
;ymx=yorig(2)+ylen
;set_viewport,xmn,xmx,ymn,ymx
;!type=2^2+2^3
;nlvls=21
;col1=1+indgen(nlvls)*icolmax/nlvls
;level=0.05*findgen(nlvls)
;index=where(ellip_all eq 0.)
;if index(0) ne -1L then ellip_all(index)=0./0.
;;ellip_all=smooth(ellip_all,3,/nan)
;contour,ellip_all,-30.+findgen(ndays),th,c_color=col1,/cell_fill,xtitle='Days From SSW Onset',ytitle='Theta (K)',xrange=[-30.,30.],$
;        color=0,yrange=[500.,5000.],title='WACCM Vortex Ellipticity',levels=level,charsize=1.5,charthick=2
;contour,ellip_all,-30.+findgen(ndays),th,color=0,/follow,/overplot,levels=level    ;,C_ANNOTATION=string(long(level))
;index=where(nvort_all gt 1.)
;if index(0) ne -1L then begin
;   x2d=fltarr(ndays,nth)
;   y2d=fltarr(ndays,nth)
;   for i=0,ndays-1 do y2d(i,*)=th
;   for j=0,nth-1 do x2d(*,j)=-30+findgen(ndays)
;   oplot,x2d(index),y2d(index),psym=8,color=0,symsize=0.5
;endif
;;plots,0,500
;;plots,0,5000,/continue,/data,color=mcolor,thick=5
;xmax=30.
;xyouts,xmax+7.,500.,'Approximate Altitude (km)',color=0,/data,orientation=90.,charsize=1.25,charthick=2
;xyouts,xmax+1.,500.,'20',color=0,/data,charsize=1.5,charthick=2
;xyouts,xmax+1.,800.,'30',color=0,/data,charsize=1.5,charthick=2
;xyouts,xmax+1.,1400.,'40',color=0,/data,charsize=1.5,charthick=2
;xyouts,xmax+1.,2000.,'50',color=0,/data,charsize=1.5,charthick=2
;xyouts,xmax+1.,3000.,'60',color=0,/data,charsize=1.5,charthick=2
;xyouts,xmax+1.,4000.,'70',color=0,/data,charsize=1.5,charthick=2
;xyouts,xmax+1.,5000.,'80',color=0,/data,charsize=1.5,charthick=2
;
;imin=min(level)
;imax=max(level)
;xmnb=xorig(2)+xlen +cbaryoff
;xmxb=xmnb  +cbarydel
;set_viewport,xmnb,xmxb,ymn,ymx
;!type=2^2+2^3+2^5
;plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,$
;      charthick=2,charsize=1.5
;xbox=[0,10,10,0,0]
;y1=imin
;dy=(imax-imin)/float(nlvls)
;for j=0,nlvls-1 do begin
;ybox=[y1,y1,y1+dy,y1+dy,y1]
;polyfill,xbox,ybox,color=col1(j)
;y1=y1+dy
;endfor
      if setplot ne 'ps' then stop
        if setplot eq 'ps' then begin
           device, /close
           spawn,'convert ../Figures/waccm_vortex_centroids_SSW_composite.ps -rotate -90 /Users/harvey/Harvey_etal_2014/Figures/waccm_vortex_centroids_SSW_composite.png'
;          spawn,'rm -f ../Figures/waccm_vortex_centroids_SSW_composite.ps'
        endif
end
