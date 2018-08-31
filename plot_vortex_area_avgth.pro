;
; average multiple theta levels
;
; calculate the area enclosed by the vortex at a given theta level
; expressed in equivalent latitude and plot winter time series
; with average and sigma
;
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
device,decompose=0
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.2]
yorig=[0.25]
xlen=0.7
ylen=0.5
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
lstmn=0L & lstdy=0L & lstyr=0L & ledmn=0L
leddy=0L & ledyr=0L & lstday=0L & ledday=0L
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
smon=['Jul','Aug','Sep','Oct','Nov','Dec',$
     'Jan','Feb','Mar','Apr','May','Jun']
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nmon=['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']

restore,file='arctic_vortex_area.sav'
index=where(area_num gt 1.)
if index(0) ne -1 then area_ave(index)=area_ave(index)/area_num(index)
result=size(AREA_ALL)
nyear=result(1)
nday=result(2)
nth=result(3)
area_sig=fltarr(nday,nth)
area_max=fltarr(nday,nth)
area_min=fltarr(nday,nth)
for i=0,nday-1 do begin
    for k=0,nth-1 do begin
        a0=reform(area_all(*,i,k))
        index=where(a0 ne 0.)
        if index(0) ne -1 then begin
           area_min(i,k)=min(a0(index))
           area_max(i,k)=max(a0(index))
           if n_elements(index) gt 1L then begin
           result=moment(a0(index))
           area_sig(i,k)=sqrt(result(1))
           endif
        endif
    endfor
endfor

th=[2000.,1800.,1600.,1400.,1200.,1000.,900.,800.,700.,600.,550.,$
    525.,500.,475.,450.,425.,400.,390.,380.,370.,360.,350.,340.,330.]
rth=1200.
;print,th
;read,'Enter theta surface ',rth
;for k=0,nth-1 do begin
;rth=th(k)
kindex=where(th ge rth and th lt 1600.)
stheta=strcompress(string(long(th(kindex(0)))),/remove_all)+'K'
if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='arctic_vortex_area_avgth+'+stheta+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx

dum=0.*reform(AREA_AVE(*,kindex(0)))
ds=0.*reform(AREA_AVE(*,kindex(0)))
dall=0.*reform(area_all(13,*,kindex(0)))           ; element 13 refers to 2004
dmin=0.*reform(AREA_AVE(*,kindex(0)))
dmax=0.*reform(AREA_AVE(*,kindex(0)))
for k=0L,n_elements(kindex)-1L do begin
    dum(0:184)=dum(0:184)+AREA_AVE(181:365,kindex(k))
    dum(185:365)=dum(185:365)+AREA_AVE(0:180,kindex(k))
    ds(0:184)=ds(0:184)+AREA_SIG(181:365,kindex(k))
    ds(185:365)=ds(185:365)+AREA_SIG(0:180,kindex(k))
    dmin(0:184)=dmin(0:184)+AREA_min(181:365,kindex(k))
    dmin(185:365)=dmin(185:365)+AREA_min(0:180,kindex(k))
    dmax(0:184)=dmax(0:184)+AREA_max(181:365,kindex(k))
    dmax(185:365)=dmax(185:365)+AREA_max(0:180,kindex(k))
    dall(0:184)=dall(0:184)+AREA_all(12,181:365,kindex(k))
    dall(185:365)=dall(185:365)+AREA_all(13,0:180,kindex(k))
endfor
dum=dum/float(n_elements(kindex))
ds=ds/float(n_elements(kindex))
dall=dall/float(n_elements(kindex))
dmin=dmin/float(n_elements(kindex))
dmax=dmax/float(n_elements(kindex))
dum=smooth(dum,5)
ds=smooth(ds,5)
dmin=smooth(dmin,5)
dmax=smooth(dmax,5)
dall=smooth(dall,5)

index=where(dum gt 0.)
plot,dum/hem_area,xrange=[0.,365.],yrange=[0.,.5],psym=8,$
     ytitle='Fraction of the Hemisphere',xtitle='Julian Day',$
     title='1991-2004 Arctic Vortex Area 1300 K',charsize=1.5,$
     xtickv=15+[0,32,60,91,121,152,182,213,244,274,305,335],$
     xticks=11,xtickname=smon,min_value=0.,/nodata
oplot,index,dum(index)/hem_area
oplot,index,(dum(index)/hem_area)+(ds(index)/hem_area)
oplot,index,(dum(index)/hem_area)-(ds(index)/hem_area)
for i=0,364 do begin
    if dum(i) ne 0. and dum(i+1) ne 0. then begin
     plots,i,(dum(i)/hem_area)-(ds(i)/hem_area)
     plots,i,(dum(i)/hem_area)+(ds(i)/hem_area),/continue
     plots,i,dum(i)/hem_area
     plots,i+1,dum(i+1)/hem_area,/continue,thick=8,color=0
    endif
endfor
oplot,index,dmin(index)/hem_area,linestyle=1,min_value=0.
oplot,index,dmax(index)/hem_area,linestyle=1,min_value=0.
index=where(dall ne 0.)
;oplot,index,dall(index)/hem_area,color=icolmax*.3,psym=8,min_value=0.
for i=0,364 do begin
    if dall(i) ne 0. and dall(i+1) ne 0. then begin
     plots,i,dall(i)/hem_area
     plots,i+1,dall(i+1)/hem_area,/continue,thick=8,color=icolmax*.3
    endif
endfor
xyouts,10.,.45,'2003/2004',color=icolmax*.3,/data,charsize=1.5
if setplot eq 'ps' then device, /close
if setplot ne 'ps' then stop
;endfor
end
