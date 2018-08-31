;
; ERA40 zonal mean temperature and zonal wind
; store 2-D arrays (day vs. altitude) of dT/dy and Ubar for SSWs
; for both hemispheres and Ubar at the Equator for QBO.
; save yearly sav files
;
; VLH 9/9/09
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
;
; restore climo of SSW and QBO proxy arrays
;
; COMMENT         STRING    = 'dT/dy=Tbar85-Tbar60 and Ubar65 is zonal mean zonal wind at 65N/S'
; NDAY            LONG      =        16436
; NH_DTDY_ALL     FLOAT     = Array[16436, 23]
; NH_UBAR65_ALL   FLOAT     = Array[16436, 23]
; NL              LONG      =           23
; PRESS           FLOAT     = Array[23]
; SH_DTDY_ALL     FLOAT     = Array[16436, 23]
; SH_UBAR65_ALL   FLOAT     = Array[16436, 23]
; UBAR_EQ_ALL     FLOAT     = Array[16436, 23]
; YYYYMMDD_ALL    LONG      = Array[16436]
;
restore,file='ERA40_dTdy_Ubar_QBO_1957-2002.sav'
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
erase
level=-40.+5.*findgen(13) ; -40 to +20
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
!type=2^2+2^3+2^7
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
nh_dtdy=nh_dtdy_all
contour,nh_dtdy,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=level,$
        c_color=col1,/cell_fill,color=0,ytitle='Pressure (hPa)',title='Tbar 85N - 60N',$
        xrange=[0.,nday-1],xticks=nxticks-1,xtickname=' '+strarr(nxticks+1),charsize=1.25,$
        charthick=2,xticklen=-0.05,min_value=-9999.
;index=where(level lt 0.)
;contour,nh_dtdy,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=level(index),$
;        c_labels=0*index,/follow,color=0,/overplot,min_value=-9999.
;index=where(level gt 0.)
;contour,nh_dtdy,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=level(index),$
;        /follow,color=mcolor,/overplot,c_linestyle=5,c_labels=0*index,min_value=-9999.
;contour,nh_dtdy,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=[0],$
;        /follow,color=0,/overplot,thick=3,min_value=-9999.
for ii=0L,nxticks-1L do xyouts,xindex(ii),3000.,xlabs(ii),/data,color=0,charsize=1.25,$
                               charthick=2,alignment=0.5
imin=min(level)
imax=max(level)
xmnb=xorig(0)+xlen+cbaryoff
xmxb=xmnb+cbarydel
set_viewport,xmnb,xmxb,yorig(0)+cbarydel,yorig(0)+ylen-cbarydel
!type=2^2+2^3+2^5+2^7
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],title='K',color=0,/noeras,charsize=1.25,charthick=2
xbox=[0,10,10,0,0]
y1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor
ulevel=-50.+10.*findgen(13)
nlvls=n_elements(ulevel)
col1=1+indgen(nlvls)*mcolor/nlvls
!type=2^2+2^3+2^7
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
nh_ubar65=nh_ubar65_all
contour,nh_ubar65,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=ulevel,$
        c_color=col1,/cell_fill,color=0,ytitle='Pressure (hPa)',title='Ubar at 65N',$
        xrange=[0.,nday-1],xticks=nxticks-1,xtickname=' '+strarr(nxticks+1),charsize=1.25,$
        charthick=2,xticklen=-0.05,min_value=-9999.
;index=where(ulevel gt 0.)
;contour,nh_ubar65,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=ulevel(index),$
;        c_labels=0*index,/follow,color=0,/overplot,min_value=-9999.
;index=where(ulevel lt 0.)
;contour,nh_ubar65,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=ulevel(index),$
;        /follow,color=mcolor,/overplot,c_linestyle=5,c_labels=0*index,min_value=-9999.
;contour,nh_ubar65,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=[0.],$
;        /follow,color=0,/overplot,thick=3,min_value=-9999.
for ii=0L,nxticks-1L do xyouts,xindex(ii),3000.,xlabs(ii),/data,color=0,charsize=1.25,$
                               charthick=2,alignment=0.5
imin=min(ulevel)
imax=max(ulevel)
xmnb=xorig(1)+xlen+cbaryoff
xmxb=xmnb+cbarydel
set_viewport,xmnb,xmxb,yorig(1)+cbarydel,yorig(1)+ylen-cbarydel
!type=2^2+2^3+2^5+2^7
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],title='m/s',$
     color=0,/noeras,charsize=1.25,charthick=2
xbox=[0,10,10,0,0]
y1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor
ulevel=-50.+10.*findgen(9)
nlvls=n_elements(ulevel)
col1=1+indgen(nlvls)*mcolor/nlvls
!type=2^2+2^3+2^7
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
ubar_eq=ubar_eq_all
contour,ubar_eq,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=ulevel,$
        c_color=col1,/cell_fill,color=0,ytitle='Pressure (hPa)',title='Ubar at the Equator',$
        xrange=[0.,nday-1],xticks=nxticks-1,xtickname=' '+strarr(nxticks+1),charsize=1.25,$
        charthick=2,xticklen=-0.05,min_value=-9999.
;index=where(ulevel gt 0.)
;contour,ubar_eq,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=ulevel(index),$
;        c_labels=0*index,/follow,color=0,/overplot,min_value=-9999.
;contour,ubar_eq,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=[5,15],$
;        c_labels=[0,0],/follow,color=0,/overplot,min_value=-9999.
;index=where(ulevel lt 0.)
;contour,ubar_eq,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=ulevel(index),$
;        /follow,color=mcolor,/overplot,c_linestyle=5,c_labels=0*index,min_value=-9999.
;contour,ubar_eq,findgen(nday),press,/ylog,yrange=[1000.,1.],/noeras,levels=[0.],$
;        /follow,color=mcolor,/overplot,thick=3,min_value=-9999.,c_labels=[0]
for ii=0L,nxticks-1L do xyouts,xindex(ii),3000.,xlabs(ii),/data,color=0,charsize=1.25,$
                               charthick=2,alignment=0.5
imin=min(ulevel)
imax=max(ulevel)
xmnb=xorig(2)+xlen+cbaryoff
xmxb=xmnb+cbarydel
set_viewport,xmnb,xmxb,yorig(2)+cbarydel,yorig(2)+ylen-cbarydel
!type=2^2+2^3+2^5+2^7
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],title='m/s',$
     color=0,/noeras,charsize=1.25,charthick=2
xbox=[0,10,10,0,0]
y1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor
;
; save jpg
;
if setplot eq 'ps' then begin
device,/close
spawn,'convert -trim ERA40_dTdy_Ubar_QBO_'+yearlab+'.ps -rotate -90 ERA40_dTdy_Ubar_QBO_'+yearlab+'.jpg'
endif
end
