;
; include ECMWF
; plot area within NH vortex
;
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
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
smon=['J','F','M','A','M']
;smon=['J','A','S','O','N','D','J','F','M','A','M','J']	; 1 July = day 182
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nmon=['01','02','03','04','05','06','07','08','09','10','11','12']

restore,'ecmwf_nhvortex_area_allyears.sav'       ;,area_ave,th,yyyymmdd
earea_ave=area_ave
eth=th
eyyyymmdd=yyyymmdd
result=size(eyyyymmdd)
enyear=result(1)
ekday=result(2)

restore,'ukmo_nhvortex_area_allyears.sav'	;,area_ave,th,yyyymmdd
result=size(yyyymmdd)
nyear=result(1)
kday=result(2)
rth=2000.
print,th
read,'Enter desired theta surface ',rth
index=where(rth ge th)
ith=index(0)
sth=strcompress(long(th(ith)),/remove_all)
;
; extract desired level
;
area_all=area_ave
area_all_lev=0.*reform(area_all(*,*,ith))
zindex=where(th ge rth,kth)
for iyear=0L,nyear-1L do begin
for iday=0L,kday-1L do begin
    area_all_lev(iyear,iday)=total(area_all(iyear,iday,zindex))/float(kth)
endfor
endfor
;
; ECMWF
earea_all=earea_ave
earea_all_lev=0.*reform(earea_all(*,*,ith))
zindex=where(eth eq rth,kth)
for iyear=0L,enyear-1L do begin
for iday=0L,ekday-1L do begin
    earea_all_lev(iyear,iday)=total(earea_all(iyear,iday,zindex))/float(kth)
endfor
endfor
;
; shift in time so plot ranges from 1 July through 30 June
;
;yyyymmdd_sftd=0L*yyyymmdd
;area_all_lev_sftd=0.*area_all_lev
;for iyear=0L,nyear-2L do begin
;    yyyymmdd_sftd(iyear,0:182)=yyyymmdd(iyear,183:365)
;    yyyymmdd_sftd(iyear,183:365)=yyyymmdd(iyear+1,0:182)
;    area_all_lev_sftd(iyear,0:182)=area_all_lev(iyear,183:365)
;    area_all_lev_sftd(iyear,183:365)=area_all_lev(iyear+1,0:182)
;endfor
;yyyymmdd=yyyymmdd_sftd
;area_all_lev=area_all_lev_sftd

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='ukmo+ecmwf_nhvortex_area_allyears_'+sth+'K_spring.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3+2^7
amin=0.
amax=120.
kday0=121
plot,[1,kday0,kday0,1,1],[0.,0.,amax,amax,0.],min_value=0.,color=0,$
      xrange=[1,kday0],yrange=[0.,amax],/nodata,charsize=2,$
      ytitle='Millions of km!u2!n',xtickname=smon,xticks=n_elements(smon)-1L,$
      title='Average Arctic Vortex Area '+sth+'-2000 K'

;date0=reform(yyyymmdd(1,*))
;kindex=where(strmid(strcompress(date0,/remove_all),6,2) eq '15',nxtick)
;xmon=long(strmid(strcompress(date0(kindex),/remove_all),4,2))
;for i=0,nxtick-1 do begin
;    xlab=smon(xmon(i)-1)
;    plots,kindex(i)+1,0.
;    plots,kindex(i)+1,-5.,/continue,/data,color=0
;    xyouts,kindex(i)+1,-20.,xlab,/data,alignment=0.5,charsize=3,color=0
;endfor
;
; range of areas prior to 2004
;
area_min_lev=fltarr(kday)
area_max_lev=fltarr(kday)
area_avg_lev=fltarr(kday)
for i=0L,kday-1 do begin
    areaday=reform(AREA_ALL_LEV(0L:nyear-3L,i))
    index=where(areaday ne 0.,nn)
    if nn gt 1L then begin
       area_min_lev(i)=min(areaday(index))
       area_max_lev(i)=max(areaday(index))
       area_avg_lev(i)=total(areaday(index))/float(nn)
    endif
endfor
area_min_lev=smooth(area_min_lev,3)
area_max_lev=smooth(area_max_lev,3)
area_avg_lev=smooth(area_avg_lev,3)
;
; ECMWF ranges
;
earea_min_lev=fltarr(ekday)
earea_max_lev=fltarr(ekday)
earea_avg_lev=fltarr(ekday)
for i=0L,ekday-1 do begin
    eareaday=reform(eAREA_ALL_LEV(0L:nyear-3L,i))
    index=where(eareaday ne 0.,nn)
    if nn gt 1L then begin
       earea_min_lev(i)=min(eareaday(index))
       earea_max_lev(i)=max(eareaday(index))
       earea_avg_lev(i)=total(eareaday(index))/float(nn)
    endif
endfor
earea_min_lev=smooth(earea_min_lev,3)
earea_max_lev=smooth(earea_max_lev,3)
earea_avg_lev=smooth(earea_avg_lev,3)

loadct,0
for i=1L,kday0 do begin
    if area_min_lev(i-1) ne 0. then begin
       plots,i,area_min_lev(i-1)
       plots,i,area_max_lev(i-1),/continue,thick=20,color=200
    endif
    if earea_min_lev(i-1) ne 0. then begin
       plots,i,earea_min_lev(i-1)
       plots,i,earea_max_lev(i-1),/continue,thick=20,color=200
    endif
    if area_avg_lev(i-1) ne 0. then begin
       plots,i,area_avg_lev(i-1)-1.0
       plots,i,area_avg_lev(i-1)+1.0,/continue,thick=20,color=50
    endif
;   if earea_avg_lev(i-1) ne 0. then begin
;      plots,i,earea_avg_lev(i-1)-1.0
;      plots,i,earea_avg_lev(i-1)+1.0,/continue,thick=20,color=50
;   endif
endfor
loadct,38

slab=['1992','1993','1994','1995','1996','1997','1998','1999',$
      '2000','2001','2002','2003','2004','2005','2006']
slab=['2004','2005','2006']
nlvls=n_elements(slab)
col1=51+indgen(nlvls)*icolmax/nlvls
yinc=(ymx-ymn)/nlvls
yinc=7.
for iyear=nyear-3L,nyear-1L do begin
    area_ave=reform(area_all_lev(iyear,*))
;print,reform(yyyymmdd(iyear,*))
    index=where(abs(area_ave) lt 0.01)
    if index(0) ne -1 then area_ave(index)=-9999.
    index1=where(area_ave ne -9999.,ngood)
    index2=where(area_ave eq -9999.)
    if ngood gt 1 and index1(0) ne -1 and index2(0) ne -1 then begin
       filled=interpol(area_ave(index1),index1,index2)
       area_ave(index2)=filled
    endif
    area_ave=smooth(area_ave,3,/edge_truncate)
    oplot,findgen(kday),area_ave,color=col1(iyear-(nyear-3L)),thick=8,min_value=-9999.
    xyouts,105.,103.-(iyear-(nyear-3L))*yinc,slab(iyear-(nyear-3L)),charsize=2,color=col1(iyear-(nyear-3L)),/data,charthick=2
endfor
;
; ECMWF 1979
;
slab=['1978','1979','1980','1981','1982','1983','1984','1985','1986','1987','1988','1989',$
      '1990','1991','1992','1993','1994','1995','1996','1997','1998','1999','2000','2001','2002']
for iyear=1L,1L do begin
    area_ave=reform(earea_all_lev(iyear,*))
;print,reform(eyyyymmdd(iyear,*))
    index=where(abs(area_ave) lt 0.01)
    if index(0) ne -1 then area_ave(index)=-9999.
    index1=where(area_ave ne -9999.,ngood)
    index2=where(area_ave eq -9999.)
    if ngood gt 1 and index1(0) ne -1 and index2(0) ne -1 then begin
       filled=interpol(area_ave(index1),index1,index2)
       area_ave(index2)=filled
    endif
    area_ave=smooth(area_ave,3,/edge_truncate)
    oplot,findgen(kday),area_ave,color=mcolor*(iyear+1.)/(enyear+2.),thick=3,min_value=-9999.
    xyouts,105.,110.,slab(iyear),charsize=2,$
           color=mcolor*(iyear+1.)/(enyear+2.),/data,charthick=2
endfor
if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim ukmo+ecmwf_nhvortex_area_allyears_'+sth+'K_spring.ps -rotate -90 ukmo+ecmwf_nhvortex_area_allyears_'+sth+'K_spring.jpg'
endif
end
