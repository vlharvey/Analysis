;
; replicate Figure 7 from Labitzke and Kunze 2009
; February monthly average solar flux vs geopotential height at the NP and 30 hPa
; separated by QBO phase. East or West at the Equator and 30 hPa
; fill dots when Major stratospheric warmings occur
;
; VLH 9/14/09
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
usersym,cos(a),sin(a),/fill
!noeras=1
nxdim=700
nydim=700
xorig=[0.15,0.55]
yorig=[0.3,0.3]
xlen=0.3
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
          /bold,/color,bits_per_pixel=8,/helvetica,filename='Labitzke_and_Kunze_2009_Fig.7.ps'
   !p.charsize=1.25
   !p.thick=2
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
nyear=63
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
; restore ERA40 files
;
; ALAT            FLOAT     = Array[73]
; COMMENT         STRING    = 'dT/dy=Tbar85-Tbar60 and Ubar65 is zonal mean zonal wind at 65N/S'
; NDAY            LONG      =        16436
; NH_DTDY_ALL     FLOAT     = Array[16436, 23]
; NH_UBAR65_ALL   FLOAT     = Array[16436, 23]
; NL              LONG      =           23
; NR              LONG      =           73
; PRESS           FLOAT     = Array[23]
; SH_DTDY_ALL     FLOAT     = Array[16436, 23]
; SH_UBAR65_ALL   FLOAT     = Array[16436, 23]
; TBAR_ALL        FLOAT     = Array[16436, 73, 23]
; UBAR_ALL        FLOAT     = Array[16436, 73, 23]
; UBAR_EQ_ALL     FLOAT     = Array[16436, 23]
; YYYYMMDD_ALL    LONG      = Array[16436]
;
restore,'ERA40_dTdy_Ubar_QBO_1957-2002.sav'
restore,file='ERA40_tbar_ubar_alllat_era40_1957-2002.sav'	; no alat?
nr=73
alat=-90.+2.5*findgen(nr)
syyyymmdd_all=strcompress(yyyymmdd_all,/remove_all)
syear=strmid(syyyymmdd_all,0,4)
smon=strmid(syyyymmdd_all,4,2)
sday=strmid(syyyymmdd_all,6,2)
good=where(long(syear) ne 0L)
minyear=long(min(long(syear(good))))
maxyear=long(max(long(syear)))
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
;
; compute february monthly averages at 30 hPa
;
;     years(iyear)=long(vals(0))
;     f10_feb(iyear)=vals(2)/10.
; TBAR_ALL        FLOAT     = Array[16436, 73, 23]
; GBAR_ALL        FLOAT     = Array[16436, 73, 23]
; UBAR_EQ_ALL     FLOAT     = Array[16436, 23]
; YYYYMMDD_ALL    LONG      = Array[16436]

ilev50=where(press eq 50.)
ilev50=ilev50(0)
ilev30=where(press eq 30.)
ilev30=ilev30(0)
ilev10=where(press eq 10.)
ilev10=ilev10(0)
ilev1=where(press eq 1.)
ilev1=ilev1(0)
gplev30=reform(GBAR_ALL(*,nr-1,ilev30))	; daily GPH at NP and 30 hPa
tplev30=reform(TBAR_ALL(*,nr-1,ilev30))	; daily temp at NP and 30 hPa
ilat=where(alat eq 65.)
ilat=ilat(0)
ulev60N10=reform(UBAR_ALL(*,ilat,ilev10))	; daily Ubar at 60N and 10 hPa
ulev60N1=reform(UBAR_ALL(*,ilat,ilev1))	; daily Ubar at 60N and 1 hPa
ulev30=reform(UBAR_EQ_ALL(*,ilev30))	; daily Ubar at Equator and 30 hPa
ulev50=reform(UBAR_EQ_ALL(*,ilev50))	; daily Ubar at Equator and 50 hPa
gpavg30=-99.+0.*fltarr(nyear)			; Feb monthly average GPH at the NP and 30 hPa 
tpavg30=-99.+0.*fltarr(nyear)			; Feb monthly average temp at the NP and 30 hPa 
uavgeq30=-99.+0.*fltarr(nyear)			; Feb monthly average zonal wind at the equator
uavgeq50=-99.+0.*fltarr(nyear)			; Feb monthly average zonal wind at the equator
usigeq50=-99.+0.*fltarr(nyear)			; Feb monthly standard deviation of zonal wind at the equator
uchgeq50=-99.+0.*fltarr(nyear)			; Feb monthly standard deviation of zonal wind at the equator
uavg60N10=-99.+0.*fltarr(nyear)			; Feb monthly average zonal wind at 60 N
uavg60N1=-99.+0.*fltarr(nyear)			; Feb monthly average zonal wind at 60 N
for i=0,nyear-1L do begin
    index=where(syear eq strcompress(years(i),/remove_all) and smon eq '02',nn)
    if index(0) ne -1 then begin	; there are years ini f10.7 record before and after ERA40
       tpavg30(i)=total(tplev30(index))/float(nn)
       gpavg30(i)=total(gplev30(index))/float(nn)
       uavgeq30(i)=total(ulev30(index))/float(nn)
       uavgeq50(i)=total(ulev50(index))/float(nn)
       usigeq50(i)=stdev(ulev50(index))
       if min(ulev50(index)) lt 0. and max(ulev50(index)) gt 0. then uchgeq50(i)=1
       uavg60N1(i)=min(ulev60N1(index))
       uavg60N10(i)=min(ulev60N10(index))
uvals=reform(ulev60N10(index))
mmwindex=where(uvals lt 0.,nmmw)
print,years(i),tpavg30(i),uavgeq50(i),usigeq50(i),uchgeq50(i),uavg60N10(i),nmmw
    endif
endfor
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
;tmin=190.
;tmax=230.
tmin=21.2
tmax=23.2
tpavg30=gpavg30/10000.
index=where(tpavg30 ne -99. and uavgeq50 lt 0. and uchgeq50 ne 1.,nn)
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a)
plot,f10_feb(index),tpavg30(index),xtitle='Solar Flux 10.7 cm',ytitle='NP GPH',psym=8,color=0,$
     xrange=[60.,260.],yrange=[tmin,tmax],title='QBO East Phase'
for i=0L,nn-1L do xyouts,f10_feb(index(i)),tpavg30(index(i)),strmid(strcompress(years(index(i)),/remove_all),2,2),$
    charsize=1,/data,color=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
index=where(tpavg30 ne -99. and uavgeq50 lt 0. and uchgeq50 ne 1. and uavg60N10 lt 0.,nn)
oplot,f10_feb(index),tpavg30(index),psym=8,color=0
for i=0L,nn-1L do xyouts,f10_feb(index(i)),tpavg30(index(i)),strmid(strcompress(years(index(i)),/remove_all),2,2),$
    charsize=1,/data,color=0
;index=where(tpavg30 ne -99. and uavgeq50 lt 0. and uavg60N1 lt 0.,nn)
;oplot,f10_feb(index),tpavg30(index),psym=8,color=.4*mcolor

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
index=where(tpavg30 ne -99. and uavgeq50 gt 0. and uchgeq50 ne 1.,nn)
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a)
plot,f10_feb(index),tpavg30(index),xtitle='Solar Flux 10.7 cm',psym=8,color=0,$
     xrange=[60.,260.],yrange=[tmin,tmax],title='QBO West Phase'
for i=0L,nn-1L do xyouts,f10_feb(index(i)),tpavg30(index(i)),strmid(strcompress(years(index(i)),/remove_all),2,2),$
    charsize=1,/data,color=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
index=where(tpavg30 ne -99. and uavgeq50 gt 0. and uchgeq50 ne 1. and uavg60N10 lt 0.,nn)
oplot,f10_feb(index),tpavg30(index),psym=8,color=0
for i=0L,nn-1L do xyouts,f10_feb(index(i)),tpavg30(index(i)),strmid(strcompress(years(index(i)),/remove_all),2,2),$
    charsize=1,/data,color=0
;index=where(tpavg30 ne -99. and uavgeq50 gt 0. and uavg60N1 lt 0.,nn)
;oplot,f10_feb(index),tpavg30(index),psym=8,color=.4*mcolor
;
; save jpg
;
if setplot eq 'ps' then begin
device,/close
spawn,'convert -trim Labitzke_and_Kunze_2009_Fig.7.ps -rotate -90 Labitzke_and_Kunze_2009_Fig.7.jpg'
endif
end
