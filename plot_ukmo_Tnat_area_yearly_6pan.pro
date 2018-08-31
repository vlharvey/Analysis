;
; yearly files have been saved out for Tnat that varies daily
;
; plot area within 1994-2005 NH Tnat and save for all levels and years
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
nxdim=600
nydim=750
xorig=[.15,.15,.15,.15,.15]
yorig=[.7,.55,.4,.25,.1]
xlen=0.6
ylen=0.1
cbaryoff=0.03
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
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nmon=['01','02','03','04','05','06','07','08','09','10','11','12']
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='ukmo_tnat_area_yearly_5pan.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
slab=[$
'9495',$
'9596',$
'9697',$
'9798',$
'9899',$
'9900',$
'0001',$
'0102',$
'0203',$
'0304',$
'0405']
rth=[600.,550.,500.,450.,400.]
;xyouts,.2,.85,'MetO N.H. Area T<Tnat',/normal,charsize=2,color=0
nyear=n_elements(slab)
for iyear=0L,nyear-1L do begin
    restore,'ukmo_Tnat_area_'+slab(iyear)+'.sav'	;,area_ave,th,sfile,sdate
    ldate=long(sdate)
    if iyear eq 0L then begin
       area_all=fltarr(nyear,122L,n_elements(th))	; accommodate leap years
       ldate_all=lonarr(nyear,122L)
    endif
    nday=n_elements(sdate)
    area_all(iyear,0L:nday-1L,*)=area_ave
;print,reform(area_ave(*,11))
    ldate_all(iyear,0L:nday-1L)=ldate
    print,slab(iyear),' ',min(ldate),max(ldate),n_elements(sdate)
endfor
    
for k=0L,n_elements(rth)-1L do begin
index=where(th eq rth(k))
ith=index(0)
sth=strcompress(long(th(ith)),/remove_all)

xmn=xorig(k)
xmx=xorig(k)+xlen
ymn=yorig(k)
ymx=yorig(k)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3+2^7
plot,[1,122L,122L,1,1],[0.,0.,20.,20.,0.],min_value=0.,color=0,$
      xrange=[1,122L],yrange=[0.,20.],/nodata,charsize=1.5,$
      ytitle='1.e6 km!u2!n',xticks=4,xtickname=' '+strarr(5),title=sth+' K'
kindex=where(strmid(sfile,3,2) eq '01',nxtick)
xmon=long(strmid(sfile(kindex),0,2))
for i=0,nxtick-1 do begin
    plots,kindex(i)+1,0.
    plots,kindex(i)+1,-1.,/continue,/data,color=0
endfor
kindex=where(strmid(sfile,3,2) eq '15',nxtick)
xmon=long(strmid(sfile(kindex),0,2))
for i=0,nxtick-1 do begin
    xlab=smon(xmon(i)-1)
    xyouts,kindex(i)+1,-5.,xlab,/data,alignment=0.5,charsize=2,charthick=2,color=0
endfor

area_all_lev=reform(area_all(*,*,ith))
nlvls=nyear
col1=1+indgen(nlvls)*icolmax/nlvls
yinc=(max(yorig)+ylen-min(yorig))/nlvls
for iyear=0L,nyear-1L do begin
    area_ave=reform(area_all_lev(iyear,*))
ldate_year=ldate_all(iyear,*)
index=where(ldate_year ne 0L,kday)
;print,slab(iyear),' ',kday
    index=where(abs(area_ave) lt 1.)
    if index(0) ne -1 then area_ave(index)=-9999.
    oplot,findgen(kday),area_ave,color=col1(iyear),thick=8,min_value=-999.
    xyouts,xmx+0.02,ylen/4.+min(yorig)+iyear*yinc,slab(iyear),charsize=2,color=col1(iyear),/normal,charthick=2
endfor
;oplot,findgen(kday),area_ave,color=0,thick=5,min_value=-999.
;xyouts,xmx+0.02,ylen/4.+min(yorig)+(nyear-1L)*yinc,slab(nyear-1),charsize=2,color=0,/normal,charthick=2

endfor	; loop over levels

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim ukmo_tnat_area_yearly_5pan.ps -rotate -90 ukmo_tnat_area_yearly_5pan.jpg'
endif

end
