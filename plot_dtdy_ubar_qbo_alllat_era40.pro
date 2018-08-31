;
; ERA40 zonal mean temperature and zonal wind at all latitudes
;
; VLH 9/11/09
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
xorig=[0.2,0.2,0.2]
yorig=[0.675,0.375,0.075]
xlen=0.55
ylen=0.2
cbaryoff=0.08
cbarydel=0.02
setplot='ps'
read,'setplot=',setplot
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
mon=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
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
restore,file='ERA40_tbar_ubar_alllat_era40_1957-2002.sav'
restore,'ERA40_dTdy_Ubar_QBO_1957-2002.sav'
syyyymmdd_all=strcompress(yyyymmdd_all,/remove_all)
syear=strmid(syyyymmdd_all,2,2)
smon=strmid(syyyymmdd_all,4,2)
sday=strmid(syyyymmdd_all,6,2)
good=where(long(syear) ne 0L)
minyear=long(min(long(syear(good))))
maxyear=long(max(long(syear)))
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
xindex=where(smon eq '07' and sday eq '15' and long(syear) mod 2 eq 0,nxticks)
xlabs=smon(xindex)+'/'+sday(xindex)
xlabs=syear(xindex)
good=where(long(syear) ne 0L)
minyear=long(min(long(syear(good))))
maxyear=long(max(long(syear)))
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
for k=10L,nl-1L do begin
erase
!type=2^2+2^3+2^7
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
spress=strcompress(long(press(k)),/remove_all)
sh_dtdy_lev=reform(sh_dtdy_all(*,k))
sh_dtdy_lev_smoothed=smooth(sh_dtdy_lev,7,/edge_truncate)
sh_dtdy_lev=sh_dtdy_lev_smoothed
ymin=-40.
ymax=40.
plot,findgen(nday),sh_dtdy_lev,thick=3,yrange=[ymin,ymax],/noeras,title='T 85S - T 60S',$
     xtickv=xindex,xtickname=' '+strarr(nxticks+1),xticks=nxticks,color=0,/nodata,$
     charthick=1.25,charsize=1.5,yminor=2
xyouts,xmn+0.02,ymx-0.02,spress+' hPa',/normal,color=0,charthick=1.5,charsize=1.5
nmonth=12
col1=1+indgen(nmonth)*mcolor/nmonth
for i=0L,nxticks-1L do xyouts,xindex(i),ymin-10.,xlabs(i),/data,orientation=90,color=0,alignment=0.5
yint=(ymx-ymn)/float(nmonth)
yval=ymn
for i=0L,nmonth-1L do begin
    xyouts,xmx+0.02,yval,mon(i),/normal,color=col1(i)
    yval=yval+yint
    smon0=string(format='(i2.2)',i+1)
    sday0=15
    index=where(smon eq smon0 and sday eq sday0)
    oplot,index,sh_dtdy_lev(index),color=col1(i),thick=3
endfor
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
spress=strcompress(long(press(k)),/remove_all)
sh_dtdy_lev=reform(SH_UBAR65_ALL(*,k))
sh_dtdy_lev_smoothed=smooth(sh_dtdy_lev,7,/edge_truncate)
sh_dtdy_lev=sh_dtdy_lev_smoothed
ymin=-50.
ymax=150.
plot,findgen(nday),sh_dtdy_lev,thick=3,yrange=[ymin,ymax],/noeras,title='Ubar 65S',$
     xtickv=xindex,xtickname=' '+strarr(nxticks+1),xticks=nxticks,color=0,/nodata,$
     charthick=1.25,charsize=1.5,yminor=2
xyouts,xmn+0.02,ymx-0.02,spress+' hPa',/normal,color=0,charthick=1.5,charsize=1.5
nmonth=12
col1=1+indgen(nmonth)*mcolor/nmonth
for i=0L,nxticks-1L do xyouts,xindex(i),ymin-10.,xlabs(i),/data,orientation=90,color=0,alignment=0.5
yint=(ymx-ymn)/float(nmonth)
yval=ymn
for i=0L,nmonth-1L do begin
    xyouts,xmx+0.02,yval,mon(i),/normal,color=col1(i)
    yval=yval+yint
    smon0=string(format='(i2.2)',i+1)
    sday0=15
    index=where(smon eq smon0 and sday eq sday0)
    oplot,index,sh_dtdy_lev(index),color=col1(i),thick=3
endfor
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
spress=strcompress(long(press(k)),/remove_all)
sh_dtdy_lev=reform(UBAR_EQ_ALL(*,k))
sh_dtdy_lev_smoothed=smooth(sh_dtdy_lev,7,/edge_truncate)
sh_dtdy_lev=sh_dtdy_lev_smoothed
ymin=-60.
ymax=40.
plot,findgen(nday),sh_dtdy_lev,thick=3,yrange=[ymin,ymax],/noeras,title='Ubar at the Equator',$
     xtickv=xindex,xtickname=' '+strarr(nxticks+1),xticks=nxticks,color=0,/nodata,$
     charthick=1.25,charsize=1.5,yminor=2
xyouts,xmn+0.02,ymx-0.02,spress+' hPa',/normal,color=0,charthick=1.5,charsize=1.5
nmonth=12
col1=1+indgen(nmonth)*mcolor/nmonth
for i=0L,nxticks-1L do xyouts,xindex(i),ymin-10.,xlabs(i),/data,orientation=90,color=0,alignment=0.5
yint=(ymx-ymn)/float(nmonth)
yval=ymn
for i=0L,nmonth-1L do begin
    xyouts,xmx+0.02,yval,mon(i),/normal,color=col1(i)
    yval=yval+yint
    smon0=string(format='(i2.2)',i+1)
    sday0=15
    index=where(smon eq smon0 and sday eq sday0)
    oplot,index,sh_dtdy_lev(index),color=col1(i),thick=3
endfor

stop
endfor
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='ERA40_dTdy_Ubar_QBO_'+yearlab+'.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; save jpg
;
if setplot eq 'ps' then begin
device,/close
spawn,'convert -trim ERA40_dTdy_Ubar_QBO_'+yearlab+'.ps -rotate -90 ERA40_dTdy_Ubar_QBO_'+yearlab+'.jpg'
endif
end
