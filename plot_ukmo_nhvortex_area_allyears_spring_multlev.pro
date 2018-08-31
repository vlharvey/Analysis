;
; integrate a range of altitudes
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
;smon=['J','A','S','O','N','D','J','F','M','A','M','J'] ; 1 July = day 182
smon=['J','F','M','A','M','J','J','A','S','O','N','D']
smon=['J','F','M','A','M']
smon=[' ',' ',' ',' ']                                  ; Jan, Feb, Mar case
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nmon=['01','02','03','04','05','06','07','08','09','10','11','12']

restore,'ukmo_nhvortex_area_allyears.sav'	;,area_ave,th,yyyymmdd
result=size(yyyymmdd)
nyear=result(1)
kday=result(2)
rth0=1000.
rth1=2000.
print,th
read,'Enter desired lower theta surface ',rth0
read,'Enter desired upper theta surface ',rth1
zindex=where(th ge rth0 and th le rth1,kth)
sth0=strcompress(long(min(th(zindex))),/remove_all)
sth1=strcompress(long(max(th(zindex))),/remove_all)
;
; extract desired level
;
area_all=area_ave
area_all_lev=0.*reform(area_all(*,*,0))
for iyear=0L,nyear-1L do begin
for iday=0L,kday-1L do begin
    area_all_lev(iyear,iday)=total(area_all(iyear,iday,zindex))/float(kth)
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
   device,/landscape,bits=8,filename='ukmo_nhvortex_area_allyears_'+sth0+'-'+sth1+'K_spring.ps'
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
kday0=91
amax=120.
amin=0.
plot,[1,kday0,kday0,1,1],[amin,amin,amax,amax,amin],min_value=0.,color=0,$
      xrange=[1,kday0],yrange=[amin,amax],/nodata,charsize=2,$
      ytitle='Millions of km!u2!n',xtickname=smon,xticks=n_elements(smon)-1L,$
      title='Average Arctic Vortex Area '+sth0+'-'+sth1+'K'
xyouts,15.,amin-7.,'Jan',/data,color=0,charsize=2,alignment=0.5
xyouts,46.,amin-7.,'Feb',/data,color=0,charsize=2,alignment=0.5
xyouts,74.,amin-7.,'Mar',/data,color=0,charsize=2,alignment=0.5

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
for i=0L,kday-1 do begin
    areaday=reform(AREA_ALL_LEV(0L:nyear-3L,i))
    index=where(areaday ne 0.)
    if index(0) ne -1L then area_min_lev(i)=min(areaday(index))
    if index(0) ne -1L then area_max_lev(i)=max(areaday(index))
endfor
area_min_lev=smooth(area_min_lev,3)
area_max_lev=smooth(area_max_lev,3)
loadct,0
for i=2L,kday0-1 do begin
    if area_min_lev(i-1) ne 0. then begin
       plots,i,area_min_lev(i-1)
       plots,i,area_max_lev(i-1),/continue,thick=20,color=200
    endif
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
    plots,4,114.-(iyear-(nyear-3L))*yinc
    plots,14,114.-(iyear-(nyear-3L))*yinc,color=col1(iyear-(nyear-3L)),/data,thick=8,/continue
    xyouts,15.,112.-(iyear-(nyear-3L))*yinc,slab(iyear-(nyear-3L)),charsize=2,color=col1(iyear-(nyear-3L)),/data,charthick=2
endfor

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim ukmo_nhvortex_area_allyears_'+sth0+'-'+sth1+'K_spring.ps -rotate -90 '+$
                       'ukmo_nhvortex_area_allyears_'+sth0+'-'+sth1+'K_spring.jpg'
endif
end
