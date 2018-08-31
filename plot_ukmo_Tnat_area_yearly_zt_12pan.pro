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
nxdim=1000
nydim=800
xorig=[.1,.3,.5,.7,.1,.3,.5,.7,.1,.3,.5,.7]
yorig=[.68,.68,.68,.68,.4,.4,.4,.4,.12,.12,.12,.12]
xlen=0.15
ylen=0.2
cbaryoff=0.02
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
   device,/landscape,bits=8,filename='ukmo_tnat_area_yearly_zt_12pan.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
nlvls=13
col1=1+indgen(nlvls)*icolmax/nlvls
slab=[$
'9495','9596','9697','9798','9899','9900',$
'0001','0102','0203','0304','0405']
erase
nyear=n_elements(slab)
for iyear=0L,nyear-1L do begin
    restore,'ukmo_Tnat_area_'+slab(iyear)+'.sav'	;,area_ave,th,sfile,sdate
    ldate=long(sdate)
    nday=n_elements(sdate)
    print,slab(iyear),' ',min(ldate),max(ldate),n_elements(sdate)
    
    xmn=xorig(iyear)
    xmx=xorig(iyear)+xlen
    ymn=yorig(iyear)
    ymx=yorig(iyear)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    level=findgen(nlvls)
    level(0)=0.01
    ylab=' '
    if iyear eq 0L or iyear eq 4L or iyear eq 8L then ylab='Theta'
    contour,area_ave,findgen(nday),th,min_value=0.,c_color=col1,levels=level,yrange=[350.,700.],$
            charsize=1.5,ytitle=ylab,xticks=4,xtickname=' '+strarr(5),/fill,color=0,$
            title=slab(iyear),charthick=2
    plots,0.,400.
    plots,nday-1L,400.,color=0,thick=3,/data,/continue
    kindex=where(strmid(sfile,3,2) eq '01',nxtick)
    xmon=long(strmid(sfile(kindex),0,2))
    for i=0,nxtick-1 do begin
        plots,kindex(i)+1,350.
        plots,kindex(i)+1,325.,/continue,/data,color=0
    endfor
    kindex=where(strmid(sfile,3,2) eq '15',nxtick)
    xmon=long(strmid(sfile(kindex),0,2))
    for i=0,nxtick-1 do begin
        xlab=smon(xmon(i)-1)
        xyouts,kindex(i)+1,300.,xlab,/data,alignment=0.5,charsize=2,charthick=2,color=0
    endfor
endfor	; loop over years
;
; color bar
;
xmnb=xorig(nyear)+0.05+cbaryoff
xmxb=xmnb+cbarydel
ymn=yorig(nyear)
ymx=yorig(nyear)+ylen
set_viewport,xmnb,xmxb,ymn,ymx
imin=min(level)
imax=max(level)
!type=2^2+2^3+2^5
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],$
     ytitle='N.H. T<Tnat Area (1.e6 km!u2!n)',charsize=1.5,color=0,charthick=2
xbox=[0,10,10,0,0]
y1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim ukmo_tnat_area_yearly_zt_12pan.ps -rotate -90 ukmo_tnat_area_yearly_zt_12pan.jpg'
endif

end
