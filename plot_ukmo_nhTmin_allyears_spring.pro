;
; plot min NH temperatures
;
re=40000./2./!pi
earth_tmin=4.*!pi*re*re
hem_tmin=earth_tmin/2.0
rtd=double(180./!pi)
dtr=1./rtd
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
device,decompose=0
!noeras=1
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.35]
xlen=0.7
ylen=0.4
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

restore,'ukmo_nhTmin_allyears.sav'	;,NH_TMIN_ALL,th,yyyymmdd,doy
result=size(yyyymmdd)
nyear=result(1)
kday=result(2)
rth=2000.
print,th
read,'Enter desired theta surface ',rth
index=where(rth eq th)
ith=index(0)
sth=strcompress(long(th(ith)),/remove_all)
;
; extract desired level
;
tmin_all=nh_tmin_all
tmin_all_lev=reform(tmin_all(*,*,ith))
;
; shift in time so plot ranges from 1 July through 30 June
;
;yyyymmdd_sftd=0L*yyyymmdd
;tmin_all_lev_sftd=0.*tmin_all_lev
;for iyear=0L,nyear-2L do begin
;    yyyymmdd_sftd(iyear,0:182)=yyyymmdd(iyear,183:365)
;    yyyymmdd_sftd(iyear,183:365)=yyyymmdd(iyear+1,0:182)
;    tmin_all_lev_sftd(iyear,0:182)=tmin_all_lev(iyear,183:365)
;    tmin_all_lev_sftd(iyear,183:365)=tmin_all_lev(iyear+1,0:182)
;endfor
;yyyymmdd=yyyymmdd_sftd
;tmin_all_lev=tmin_all_lev_sftd

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='ukmo_nhtmin_allyears_spring_'+sth+'K.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
;
; range of tmins prior to 2004
;
tmin_min_lev=fltarr(kday)
tmin_max_lev=fltarr(kday)
tmin_1sig_lev=fltarr(kday)
tmin_avg_lev=fltarr(kday)
for i=0L,kday-1 do begin
    tminday=reform(TMIN_ALL_LEV(0L:nyear-4L,i))
    index=where(tminday ne 0.,nn)
    if index(0) ne -1L then begin
       tmin_min_lev(i)=min(tminday(index))
       tmin_max_lev(i)=max(tminday(index))
       result=moment(tminday(index))
       tmin_avg_lev(i)=result(0)
       tmin_1sig_lev(i)=sqrt(result(1))
    endif
endfor
tmin_min_lev(0)=tmin_min_lev(1)
tmin_max_lev(0)=tmin_max_lev(1)
tmin_avg_lev(0)=tmin_avg_lev(1)
tmin_1sig_lev(0)=tmin_1sig_lev(1)
tmin_min_lev=smooth(tmin_min_lev,3)
tmin_max_lev=smooth(tmin_max_lev,3)
tmin_avg_lev=smooth(tmin_avg_lev,3)
tmin_1sig_lev=smooth(tmin_1sig_lev,3)
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3+2^7
amin=200.
amax=265.
amin=min(tmin_avg_lev)-30.
if amin lt 0. then amin=0.
amax=max(tmin_avg_lev)+10.
kday=91L
plot,[1,kday,kday,1,1],[amin,amin,amax,amax,amin],min_value=0.,color=0,$
      xrange=[1,kday],yrange=[amin,amax],/nodata,charsize=2,$
      ytitle='Minimum Temperature',xtickname=smon,xticks=n_elements(smon)-1L,$
      title=sth+' K'
xyouts,15.,amin-5.,'Jan',/data,color=0,charsize=2,alignment=0.5
xyouts,46.,amin-5.,'Feb',/data,color=0,charsize=2,alignment=0.5
xyouts,74.,amin-5.,'Mar',/data,color=0,charsize=2,alignment=0.5
;date0=reform(yyyymmdd(1,*))
;kindex=where(strmid(strcompress(date0,/remove_all),6,2) eq '15',nxtick)
;xmon=long(strmid(strcompress(date0(kindex),/remove_all),4,2))
;for i=0,nxtick-1 do begin
;    xlab=smon(xmon(i)-1)
;    plots,kindex(i)+1,0.
;    plots,kindex(i)+1,-5.,/continue,/data,color=0
;    xyouts,kindex(i)+1,-20.,xlab,/data,alignment=0.5,charsize=3,color=0
;endfor
loadct,0
for i=1L,kday do begin
    if tmin_min_lev(i-1) ne 0. then begin
       plots,i,tmin_min_lev(i-1)
       plots,i,tmin_max_lev(i-1),/continue,thick=20,color=200
    endif
    if tmin_avg_lev(i-1) ne 0. then begin
       plots,i,tmin_avg_lev(i-1)-tmin_1sig_lev(i-1)
       plots,i,tmin_avg_lev(i-1)+tmin_1sig_lev(i-1),/continue,thick=20,color=150
       plots,i,tmin_avg_lev(i-1)-1.0
       plots,i,tmin_avg_lev(i-1)+1.0,/continue,thick=20,color=20
    endif

endfor
loadct,38

slab=['1992','1993','1994','1995','1996','1997','1998','1999',$
      '2000','2001','2002','2003','2004','2005','2006']
slab=['2004','2005','2006']
nlvls=n_elements(slab)
col1=51+indgen(nlvls)*icolmax/nlvls
yinc=(ymx-ymn)/nlvls
yinc=5.
for iyear=nyear-3L,nyear-1L do begin
    tmin_ave=reform(tmin_all_lev(iyear,*))
    index=where(abs(tmin_ave) lt 0.01)
    if index(0) ne -1 then tmin_ave(index)=-9999.
    index1=where(tmin_ave ne -9999.,ngood)
    index2=where(tmin_ave eq -9999.)
    if ngood gt 1 and index1(0) ne -1 and index2(0) ne -1 then begin
       filled=interpol(tmin_ave(index1),index1,index2)
       tmin_ave(index2)=filled
    endif
    tmin_ave=smooth(tmin_ave,3)
    if iyear lt nyear-1L then oplot,findgen(kday),tmin_ave,color=col1(iyear-(nyear-3L)),thick=10,min_value=-9999.
    if iyear eq nyear-1L then oplot,findgen(118),tmin_ave(0:117),color=col1(iyear-(nyear-3L)),thick=10,min_value=-9999.
    xyouts,kday-10.,amin+12.-(iyear-(nyear-3L))*yinc,slab(iyear-(nyear-3L)),charsize=2,color=col1(iyear-(nyear-3L)),/data,charthick=2
endfor

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim ukmo_nhtmin_allyears_spring_'+sth+'K.ps -rotate -90 ukmo_nhtmin_allyears_spring_'+sth+'K.jpg'
endif
end
