;
; 5-year monthly means
; plot an altitude profile of the frequency of the time that
; minimum PV is not in the lower half of SF bins
;
@stddat
@kgmt
@ckday
@kdate

loadct,39
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[0.3]
yorig=[0.2]
xlen=0.4
ylen=0.6
cbaryoff=0.06
cbarydel=0.01
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
month=['Apr','May','Jun','Jul','Aug','Sep']
stimes=['04','05','06','07','08','09']
ntimes=n_elements(stimes)
xinc=xlen/float(ntimes)
col1=31+(indgen(ntimes)/float(ntimes))*mcolor
!noeras=1
if setplot eq 'ps' then begin
   set_plot,'ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
   xsize=nxdim/100.
   ysize=nydim/100.
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='geos5_sh_pv_minout_monthly.ps'
endif
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx

for itime=0L,ntimes-1L do begin
;
; restore monthly mean profiles of PV freq 
;
    spawn,'ls geos5_pv_freq_minout_sh_*'+stimes(itime)+'.sav',gfiles
    nyear=n_elements(gfiles)
    for iyear=0L,nyear-1L do begin
        restore,gfiles(iyear)
        pvfreq=smooth(pvfreq,3)
        if iyear eq 0L then begin
           th=[4600.,4400.,4200.,4000.,3800.,3600.,3400.,3200.,3000.,2800.,2600.,$
               2400.,2200.,2000.,1800.,1600.,1400.,1200.,1000.,900.,800.,700.,600.,$
               550.,500.,450.,400.,350.,300.]
           nth=n_elements(th)
           PVfreqmean=0.*pvfreq
           PVfreqall=fltarr(nyear,nth)
        endif
        pvfreqmean=pvfreqmean+pvfreq
        pvfreqall(iyear,*)=pvfreq
    endfor
    pvfreqmean=pvfreqmean/float(nyear)
;
    if itime eq 0L then begin
       plot,pvfreqmean,th,xrange=[0.,100.],yrange=[500.,max(th)],color=0,/nodata,$
            xtitle='Percent of the time min PV in low SF bins',ytitle='Theta (K)'
    endif
    oplot,pvfreqmean,th,psym=0,color=col1(itime),thick=10
    xyouts,0.01+xorig(0)+xinc*float(itime),.82,month(itime),color=col1(itime),/normal,alignment=0
endfor	; loop over months

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim geos5_sh_pv_minout_monthly.ps -rotate -90 '+$
         'geos5_sh_pv_minout_monthly.jpg'
   spawn,'/usr/bin/rm geos5_sh_pv_minout_monthly.ps'
endif
end
