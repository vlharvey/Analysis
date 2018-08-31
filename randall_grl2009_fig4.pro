;
; plot average N pole temperatures and zonal mean zonal wind betwen 60 and 80 N
; 2 panel
;
re=40000./2./!pi
earth_tavg_90N=4.*!pi*re*re
hem_tavg_90N=earth_tavg_90N/2.0
rtd=double(180./!pi)
dtr=1./rtd
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
device,decompose=0
!noeras=1
nxdim=750
nydim=750
xorig=[0.15,0.15]
yorig=[0.55,0.15]
xlen=0.7
ylen=0.35
cbaryoff=0.08
cbarydel=0.02
set_plot,'x'
setplot='x'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   !p.background=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
smon=['J','F','M','A','M','J','J','A','S','O','N','D']
smon=[' ',' ',' ',' ']
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nmon=['01','02','03','04','05','06','07','08','09','10','11','12']

restore,'ukmo_Tavg90N_allyears.sav'	;,TAVG_90N_ALL,th,yyyymmdd,doy
result=size(yyyymmdd)
nyear=result(1)
kday=result(2)
rth=2000.
;print,th
;read,'Enter desired theta surface ',rth
index=where(rth eq th)
ith=index(0)
sth=strcompress(long(th(ith)),/remove_all)
;
; extract desired level
;
tavg_90N_all_lev=reform(tavg_90N_all(*,*,ith))

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
;  !p.font=0
;  device,font_size=9
;  device,/landscape,bits=8,filename='ukmo_tavg_90N_Ubar60-80N_allyears_spring_'+sth+'K.ps'
   device,/helvetica
   !p.charthick=5
   device,/portrait,/encapsulated,bits=8,filename='randall_grl2009_fig4.eps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
endif
;
; range of tavg_90Ns prior to 2004
;
tavg_90N_min_lev=fltarr(kday)
tavg_90N_max_lev=fltarr(kday)
tavg_90N_1sig_lev=fltarr(kday)
tavg_90N_avg_lev=fltarr(kday)
for i=0L,kday-1 do begin
    tavg_90Nday=reform(tavg_90N_ALL_LEV(0L:nyear-7L,i))
    index=where(tavg_90Nday ne 0.,nn)
    if index(0) ne -1L then begin
       tavg_90N_min_lev(i)=min(tavg_90Nday(index))
       tavg_90N_max_lev(i)=max(tavg_90Nday(index))
       result=moment(tavg_90Nday(index))
       tavg_90N_avg_lev(i)=result(0)
       tavg_90N_1sig_lev(i)=sqrt(result(1))
    endif
endfor
tavg_90N_min_lev(0)=tavg_90N_min_lev(1)
tavg_90N_max_lev(0)=tavg_90N_max_lev(1)
tavg_90N_avg_lev(0)=tavg_90N_avg_lev(1)
tavg_90N_1sig_lev(0)=tavg_90N_1sig_lev(1)
tavg_90N_min_lev=smooth(tavg_90N_min_lev,3)
tavg_90N_max_lev=smooth(tavg_90N_max_lev,3)
tavg_90N_avg_lev=smooth(tavg_90N_avg_lev,3)
tavg_90N_1sig_lev=smooth(tavg_90N_1sig_lev,3)
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3+2^7
amin=190.
amax=290.
kday=91L
plot,[1,kday,kday,1,1],[amin,amin,amax,amax,amin],min_value=0.,color=0,$
      xrange=[1,kday],yrange=[amin,amax],/nodata,charsize=1.5,$
      ytitle=sth+' K Temperature (K)',xtickname=smon,xticks=n_elements(smon)-1,xthick=5,ythick=5
xyouts,15.,amin-9.,'Jan',/data,color=0,charsize=2,alignment=0.5
xyouts,46.,amin-9.,'Feb',/data,color=0,charsize=2,alignment=0.5
xyouts,74.,amin-9.,'Mar',/data,color=0,charsize=2,alignment=0.5

loadct,0
for i=2L,kday-1L do begin
    if tavg_90N_min_lev(i-1) ne 0. then begin
       plots,i,tavg_90N_min_lev(i-1)
       plots,i,tavg_90N_max_lev(i-1),/continue,thick=20,color=200
    endif
    if tavg_90N_avg_lev(i-1) ne 0. then begin
       plots,i,tavg_90N_avg_lev(i-1)-tavg_90N_1sig_lev(i-1)
       plots,i,tavg_90N_avg_lev(i-1)+tavg_90N_1sig_lev(i-1),/continue,thick=20,color=150
       plots,i,tavg_90N_avg_lev(i-1)-1.0
       plots,i,tavg_90N_avg_lev(i-1)+1.0,/continue,thick=20,color=20
    endif
endfor
loadct,39

slab=['1992','1993','1994','1995','1996','1997','1998','1999',$
      '2000','2001','2002','2003','2004','2005','2006']
slab=['2004','2005','2006','2007','2008','2009']
nlvls=n_elements(slab)
col1=51+indgen(nlvls)*icolmax/nlvls
yinc=3.
restore,'c11.tbl
tvlct,c1,c2,c3
for iyear=nyear-6L,nyear-1L do begin
    tavg_90N_ave=reform(tavg_90N_all_lev(iyear,*))
    index=where(abs(tavg_90N_ave) lt 0.01)
    if index(0) ne -1 then tavg_90N_ave(index)=-9999.
    index1=where(tavg_90N_ave ne -9999.,ngood)
    index2=where(tavg_90N_ave eq -9999.)
    if ngood gt 1 and index1(0) ne -1 and index2(0) ne -1 then begin
       filled=interpol(tavg_90N_ave(index1),index1,index2)
       tavg_90N_ave(index2)=filled
    endif
    tavg_90N_ave=smooth(tavg_90N_ave,3)
    if iyear eq nyear-6L then begin
       oplot,findgen(kday),tavg_90N_ave,color=3,thick=10,min_value=-9999.
       oplot,findgen(118),tavg_90N_ave(0:117),color=3,thick=10,min_value=-9999.
    endif
    if iyear eq nyear-5L then begin
       oplot,findgen(kday),tavg_90N_ave,color=4,thick=10,min_value=-9999.
       oplot,findgen(118),tavg_90N_ave(0:117),color=4,thick=10,min_value=-9999.
    endif
    if iyear eq nyear-4L then begin
       oplot,findgen(kday),tavg_90N_ave,color=5,thick=10,min_value=-9999.
       oplot,findgen(118),tavg_90N_ave(0:117),color=5,thick=10,min_value=-9999.
    endif
    if iyear eq nyear-3L then begin
       oplot,findgen(kday),tavg_90N_ave,color=6,thick=10,min_value=-9999.
       oplot,findgen(118),tavg_90N_ave(0:117),color=6,thick=10,min_value=-9999.
    endif
    if iyear eq nyear-2L then begin
       oplot,findgen(kday),tavg_90N_ave,color=7,thick=10,min_value=-9999.
       oplot,findgen(118),tavg_90N_ave(0:117),color=7,thick=10,min_value=-9999.
    endif
    if iyear eq nyear-1L then begin
       oplot,findgen(kday),tavg_90N_ave,color=11,thick=10,min_value=-9999.
       oplot,findgen(118),tavg_90N_ave(0:117),color=11,thick=10,min_value=-9999.
    endif
endfor
loadct,39
;
; panel 2
;
restore,'ukmo_Ubar60to80N_allyears.sav'	;,UBAR_60TO80N_ALL,th,yyyymmdd,doy
result=size(yyyymmdd)
nyear=result(1)
kday=result(2)
;
; extract desired level
;
UBAR_60TO80N_all_lev=reform(UBAR_60TO80N_all(*,*,ith))
;
; range of Ubars prior to 2004
;
smax_min_lev=fltarr(kday)
smax_max_lev=fltarr(kday)
smax_1sig_lev=fltarr(kday)
smax_avg_lev=fltarr(kday)
for i=0L,kday-1 do begin
    smaxday=reform(UBAR_60TO80N_ALL_LEV(0L:nyear-7L,i))
    index=where(smaxday ne 0.,nn)
    if index(0) ne -1L then begin
       smax_min_lev(i)=min(smaxday(index))
       smax_max_lev(i)=max(smaxday(index))
       result=moment(smaxday(index))
       smax_avg_lev(i)=result(0)
       smax_1sig_lev(i)=sqrt(result(1))
    endif
endfor
smax_min_lev(0)=smax_min_lev(1)
smax_max_lev(0)=smax_max_lev(1)
smax_avg_lev(0)=smax_avg_lev(1)
smax_1sig_lev(0)=smax_1sig_lev(1)
smax_min_lev=smooth(smax_min_lev,3)
smax_max_lev=smooth(smax_max_lev,3)
smax_avg_lev=smooth(smax_avg_lev,3)
smax_1sig_lev=smooth(smax_1sig_lev,3)
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3+2^7
amin=50.
amax=190.
amin=min(smax_avg_lev)-50.
amax=max(smax_avg_lev)+50.
kday=91L
plot,[1,kday,kday,1,1],[amin,amin,amax,amax,amin],min_value=0.,color=0,$
      xrange=[1,kday],yrange=[amin,amax],/nodata,charsize=1.5,$
      ytitle=sth+' K Wind Speed (ms!u-1!n)',xtickname=smon,xticks=n_elements(smon)-1L,xthick=5,ythick=5
xyouts,15.,amin-17.,'Jan',/data,color=0,charsize=2,alignment=0.5
xyouts,46.,amin-17.,'Feb',/data,color=0,charsize=2,alignment=0.5
xyouts,74.,amin-17.,'Mar',/data,color=0,charsize=2,alignment=0.5

loadct,0
for i=2L,kday-1L do begin
    if smax_min_lev(i-1) ne 0. then begin
       plots,i,smax_min_lev(i-1)
       plots,i,smax_max_lev(i-1),/continue,thick=20,color=200
    endif
    if smax_avg_lev(i-1) ne 0. then begin
       plots,i,smax_avg_lev(i-1)-smax_1sig_lev(i-1)
       plots,i,smax_avg_lev(i-1)+smax_1sig_lev(i-1),/continue,thick=20,color=150
       plots,i,smax_avg_lev(i-1)-2.0
       plots,i,smax_avg_lev(i-1)+2.0,/continue,thick=20,color=20
    endif
endfor

slab=['1992','1993','1994','1995','1996','1997','1998','1999',$
      '2000','2001','2002','2003','2004','2005','2006']
slab=['2004','2005','2006','2007','2008','2009']
nlvls=n_elements(slab)
col1=51+indgen(nlvls)*icolmax/nlvls
ymin=min(yorig)+0.07
ymax=max(yorig)+ylen
yinc=(ymax-ymin)/float(nlvls)
xmax=max(xorig)+xlen+0.02
;
; use Cora's color table
;
restore,'c11.tbl
tvlct,c1,c2,c3
for iyear=nyear-6L,nyear-1L do begin
    smax_ave=reform(UBAR_60TO80N_all_lev(iyear,*))
    index=where(abs(smax_ave) lt 0.01)
    if index(0) ne -1 then smax_ave(index)=-9999.
    index1=where(smax_ave ne -9999.,ngood)
    index2=where(smax_ave eq -9999.)
    if ngood gt 1 and index1(0) ne -1 and index2(0) ne -1 then begin
       filled=interpol(smax_ave(index1),index1,index2)
       smax_ave(index2)=filled
    endif
    smax_ave=smooth(smax_ave,3)
    if iyear eq nyear-6L then begin
       oplot,findgen(kday),smax_ave,color=3,thick=10,min_value=-9999.
       oplot,findgen(118),smax_ave(0:117),color=3,thick=10,min_value=-9999.
       xyouts,xmax,ymin+yinc*(iyear-(nyear-6L)),slab(iyear-(nyear-6L)),charsize=2,color=3,/normal,charthick=2
    endif
    if iyear eq nyear-5L then begin
       oplot,findgen(kday),smax_ave,color=4,thick=10,min_value=-9999.
       oplot,findgen(118),smax_ave(0:117),color=4,thick=10,min_value=-9999.
       xyouts,xmax,ymin+yinc*(iyear-(nyear-6L)),slab(iyear-(nyear-6L)),charsize=2,color=4,/normal,charthick=2
    endif
    if iyear eq nyear-4L then begin
       oplot,findgen(kday),smax_ave,color=5,thick=10,min_value=-9999.
       oplot,findgen(118),smax_ave(0:117),color=5,thick=10,min_value=-9999.
       xyouts,xmax,ymin+yinc*(iyear-(nyear-6L)),slab(iyear-(nyear-6L)),charsize=2,color=5,/normal,charthick=2
    endif
    if iyear eq nyear-3L then begin
       oplot,findgen(kday),smax_ave,color=6,thick=10,min_value=-9999.
       oplot,findgen(118),smax_ave(0:117),color=6,thick=10,min_value=-9999.
       xyouts,xmax,ymin+yinc*(iyear-(nyear-6L)),slab(iyear-(nyear-6L)),charsize=2,color=6,/normal,charthick=2
    endif
    if iyear eq nyear-2L then begin
       oplot,findgen(kday),smax_ave,color=7,thick=10,min_value=-9999.
       oplot,findgen(118),smax_ave(0:117),color=7,thick=10,min_value=-9999.
       xyouts,xmax,ymin+yinc*(iyear-(nyear-6L)),slab(iyear-(nyear-6L)),charsize=2,color=7,/normal,charthick=2
    endif
    if iyear eq nyear-1L then begin
       oplot,findgen(kday),smax_ave,color=11,thick=10,min_value=-9999.
       oplot,findgen(118),smax_ave(0:117),color=11,thick=10,min_value=-9999.
       xyouts,xmax,ymin+yinc*(iyear-(nyear-6L)),slab(iyear-(nyear-6L)),charsize=2,color=11,/normal,charthick=2
    endif
endfor

if setplot eq 'ps' then device, /close
end
