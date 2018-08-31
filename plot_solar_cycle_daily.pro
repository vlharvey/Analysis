;
; plot time series of daily f10.7 cm solar radio flux
;
; VLH 9/23/09
;
@stddat
@kgmt
@ckday
@kdate
@rd_era40_nc

loadct,39
device,decompose=0
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
icmm1=icolmax-1
icmm2=icolmax-2
a=findgen(8)*(2*!pi/8.)
usersym,0.5*cos(a),0.5*sin(a),/fill
!noeras=1
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.3]
xlen=0.7
ylen=0.4
cbaryoff=0.08
cbarydel=0.02
setplot='ps'
read,'setplot=',setplot
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='solar_cycle_daily.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
mon=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
smon=['01','02','03','04','05','06','07','08','09','10','11','12']
nmonth=n_elements(mon)
;
; read f10.7 daily data
;
close,1
openr,1,'f10.7cm_solar_flux_daily_data.txt'
dum=' '
readf,1,dum
ndays=24000L
sdate=lonarr(ndays)
f10_timeseries=fltarr(ndays)
iday=0L
while not eof(1) do begin
      readf,1,dum
      vals=strsplit(dum,' ',/extract)
      sdate(iday)=long(vals(0))
      if n_elements(vals) gt 1L then f10_timeseries(iday)=float(vals(1))
      iday=iday+1L
endwhile
close,1
;
syyyymmdd_all=strcompress(sdate,/remove_all)
syear=strmid(syyyymmdd_all,0,4)
smon=strmid(syyyymmdd_all,4,2)
sday=strmid(syyyymmdd_all,6,2)
good=where(long(syear) ne 0L)
minyear=long(min(long(syear(good))))
maxyear=long(max(long(syear)))
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
xindex=where(smon eq '07' and sday eq '15' and long(syear) mod 2 eq 1,nxticks)
xlabs=strmid(syear(xindex),2,2)
;
; plot
;
erase
!type=2^2+2^3+2^7
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx

index=where(f10_timeseries gt 0.,nn)
plot,index,f10_timeseries(index),ytitle='Daily Solar Flux 10.7 cm',xtitle=' ',color=0,xtickv=xindex,xtickname=xlabs,xticks=nxticks-1,yrange=[50.,350.],charsize=0.75,psym=3
;oplot,index,f10_timeseries(index),psym=8,color=0
;
; save jpg
;
if setplot eq 'ps' then begin
device,/close
spawn,'convert -trim solar_cycle_daily.ps -rotate -90 solar_cycle_daily.jpg'
endif
end
