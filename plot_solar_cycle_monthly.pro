;
; plot time series of monthly f10.7 cm solar radio flux
;
; VLH 9/23/09
;
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
          /bold,/color,bits_per_pixel=8,/helvetica,filename='solar_cycle.ps'
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
; read f10.7 monthly mean data
;
close,1
openr,1,'f10.7cm_solar_flux_monthly_data.txt'
dum=' '
for i=0,5 do readf,1,dum
iyear=0
nyear=64
years=lonarr(nyear)
f10_jan=fltarr(nyear)
f10_feb=fltarr(nyear)
f10_mar=fltarr(nyear)
f10_apr=fltarr(nyear)
f10_may=fltarr(nyear)
f10_jun=fltarr(nyear)
f10_jul=fltarr(nyear)
f10_aug=fltarr(nyear)
f10_sep=fltarr(nyear)
f10_oct=fltarr(nyear)
f10_nov=fltarr(nyear)
f10_dec=fltarr(nyear)
while not eof(1) do begin
      readf,1,dum
      vals=strsplit(dum,' ',/extract)
;
; save years and monthly average f10.7 each year
;
      years(iyear)=long(vals(0))
      f10_jan(iyear)=vals(1)/10.
      f10_feb(iyear)=vals(2)/10.
      f10_mar(iyear)=vals(3)/10.
      f10_apr(iyear)=vals(4)/10.
      f10_may(iyear)=vals(5)/10.
      f10_jun(iyear)=vals(6)/10.
      f10_jul(iyear)=vals(7)/10.
      f10_aug(iyear)=vals(8)/10.
      f10_sep(iyear)=vals(9)/10.
      f10_oct(iyear)=vals(10)/10.
      f10_nov(iyear)=vals(11)/10.
      f10_dec(iyear)=vals(12)/10.
      iyear=iyear+1L
endwhile
close,1
;
; save timeseries of f10.7 and yyyymm
;
npts=nmonth*nyear
f10_timeseries=fltarr(npts)
yyyymm_timeseries=lonarr(npts)
ipnt=0L
for n=0L,nyear-1L do begin
    f10_timeseries(ipnt)=f10_jan(n)
    f10_timeseries(ipnt+1)=f10_feb(n)
    f10_timeseries(ipnt+2)=f10_mar(n)
    f10_timeseries(ipnt+3)=f10_apr(n)
    f10_timeseries(ipnt+4)=f10_may(n)
    f10_timeseries(ipnt+5)=f10_jun(n)
    f10_timeseries(ipnt+6)=f10_jul(n)
    f10_timeseries(ipnt+7)=f10_aug(n)
    f10_timeseries(ipnt+8)=f10_sep(n)
    f10_timeseries(ipnt+9)=f10_oct(n)
    f10_timeseries(ipnt+10)=f10_nov(n)
    f10_timeseries(ipnt+11)=f10_dec(n)
    yyyymm_timeseries(ipnt:ipnt+nmonth-1L)=long(strcompress(years(n),/remove_all)+string(format='(i2.2)',1+indgen(nmonth)))
    ipnt=ipnt+nmonth
endfor
;
syyyymmdd_all=strcompress(yyyymm_timeseries,/remove_all)
syear=strmid(syyyymmdd_all,0,4)
smon=strmid(syyyymmdd_all,4,2)
good=where(long(syear) ne 0L)
minyear=long(min(long(syear(good))))
maxyear=long(max(long(syear)))
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
xindex=where(smon eq '07' and long(syear) mod 2 eq 1,nxticks)
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
plot,index,f10_timeseries(index),ytitle='Solar Flux 10.7 cm',xtitle=' ',color=0,xtickv=xindex,xtickname=xlabs,xticks=nxticks-1,yrange=[50.,300.],charsize=0.75
oplot,index,f10_timeseries(index),psym=8,color=0
;
; save jpg
;
if setplot eq 'ps' then begin
device,/close
spawn,'convert -trim solar_cycle.ps -rotate -90 solar_cycle.jpg'
endif
end
