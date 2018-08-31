;---------------------------------------------------------------------------------------------------
; Reads in MERRA data and plots zonal and meridional phase of the Arctic vortex (tilt with altitude) 
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

;-----------------------------------------------------

SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.2,0.2]
yorig=[0.685,0.185]
xlen=0.6
ylen=0.25
cbaryoff=0.1
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
          /bold,/color,bits_per_pixel=8,/times,filename='../Figures/merra_vortex_phase_ssw_composite.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; DAILYMAXHEIGHTLAT FLOAT     = Array[3, 61]
; DAILYMAXHEIGHTLON FLOAT     = Array[3, 61]
; DAILYMAXTEMPLAT FLOAT     = Array[3, 61]
; DAILYMAXTEMPLON FLOAT     = Array[3, 61]
; DAILYMEANHEIGHT FLOAT     = Array[3, 61]
; DAILYMEANTEMP   FLOAT     = Array[3, 61]
; DAILYMEANTHETA  FLOAT     = Array[3, 61]
; ESDATE          STRING    = Array[183]
; MAXHEIGHTTHETA  FLOAT     = Array[3, 61]
;
restore, '/Users/harvey/Harvey_etal_2014/Post_process/MLS_ES_daily_max_T_Z.sav'
ndays = 61L
dayofES = 1L
niday = 0L
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
restore,'/Users/harvey/Harvey_etal_2014/Post_process/SSW_composite_days_merra_dm30-dp30.sav' ;,alon,alat,th,nc,nr,nth,pv2_comp,p2_comp,u2_comp,v2_comp,qdf2_comp,q2_comp,gph2_comp,ttgw2_comp,sf2_comp,mark2_comp
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
;       gph2=reform(gph2_comp(*,*,*,iday))
;       ttgw2=reform(ttgw2_comp(*,*,*,iday))
        sf2=reform(sf2_comp(*,*,*,iday))
        mark2=reform(mark2_comp(*,*,*,iday))
;
	for ii = 0L, nth - 1L do begin
            waccmdailymark = transpose(reform(mark2[nr2:nr-1,*,nth-1L-ii]))
            marker=fltarr(nc+1L,nr2)
            marker[0L:nc-1L,*] = waccmdailymark
            marker[nc,*] = marker(0,*)
            waccmdailysf = transpose(reform(sf2[nr2:nr-1,*,nth-1L-ii]))
            sf=fltarr(nc+1L,nr2)
            sf[0L:nc-1L,*] = waccmdailysf
            sf[nc,*] = sf(0,*)
;
; superimpose center of vortex
;
            index=where(marker gt 0. and y2d gt 0.)
            if index(0) ne -1L then begin
               index2=where(sf(index) eq min(sf(index)))
               xphase(iday,nth-1-ii)=x2d(index(index2(0)))
               yphase(iday,nth-1-ii)=y2d(index(index2(0)))
            endif
        endfor
endfor
;
; longitude phase
;
index=where(xphase ne 0. and xphase gt 180.)
xphase(index)=xphase(index)-360.
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
nlvls=21
col1=1+indgen(nlvls)*icolmax/nlvls
level=-150+15.*findgen(nlvls)
index=where(xphase eq 0.)
if index(0) ne -1L then xphase(index)=0./0.
xphase=smooth(xphase,3,/nan)
contour,xphase,-30.+findgen(ndays),th,c_color=col1,/cell_fill,xtitle='Days From SSW Onset',ytitle='Theta (K)',xrange=[-30.,30.],$
        color=0,yrange=[500.,5000.],title='MERRA Vortex Longitude Phase',levels=level,charsize=1.5,charthick=2
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

;avgdailymeantheta=fltarr(ndays)
;bad=where(DAILYMEANTHETA eq -999.)
;DAILYMEANTHETA(bad)=0./0.
;for iday=0,ndays-1L do avgdailymeantheta(iday)=mean(DAILYMEANTHETA(*,iday),/nan)
;for i=0L,2 do oplot,-30.+findgen(ndays),DAILYMEANTHETA(i,*),psym=8
;oplot,-30.+findgen(ndays),avgDAILYMEANTHETA,psym=8
;index=where(avgDAILYMEANTHETA gt 4600.)
;if index(0) ne -1L then oplot,index-30.,avgDAILYMEANTHETA(index),psym=8,color=0
;for i=0L,2 do oplot,-30.+findgen(ndays),MAXHEIGHTTHETA(i,*),psym=8,color=mcolor*.9
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,$
      xtitle='Degrees Longitude',charthick=2,charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
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
nlvls=19
col1=1+indgen(nlvls)*icolmax/nlvls
level=40.+2.5*findgen(nlvls)
index=where(yphase eq 0.)
if index(0) ne -1L then yphase(index)=0./0.
yphase=smooth(yphase,3,/nan)
contour,yphase,-30.+findgen(ndays),th,c_color=col1,/cell_fill,xtitle='Days From SSW Onset',ytitle='Theta (K)',xrange=[-30.,30.],$
        color=0,yrange=[500.,5000.],title='MERRA Vortex Latitude Phase',levels=level,charsize=1.5,charthick=2
contour,yphase,-30.+findgen(ndays),th,color=0,/follow,/overplot,levels=level,c_labels=0*level
;plots,0,500
;plots,0,5000,/continue,/data,color=mcolor,thick=5
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
ymnb=yorig(1) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,$
      xtitle='Degrees Latitude',charthick=2,charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor

        if setplot ne 'ps' then stop
        if setplot eq 'ps' then begin
           device, /close
           spawn,'convert ../Figures/merra_vortex_phase_ssw_composite.ps -rotate -90 /Users/harvey/Harvey_etal_2014/Figures/merra_vortex_phase_ssw_composite.png'
;          spawn,'rm -f ../Figures/merra_vortex_phase_ssw_composite.ps'
        endif
end
