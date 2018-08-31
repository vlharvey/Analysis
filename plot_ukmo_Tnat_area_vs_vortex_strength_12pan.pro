;
; yearly files have been saved out for Tnat that varies daily
;
; scatter plot of area within 1994-2005 NH Tnat and vortex strength
;
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
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
   device,/landscape,bits=8,filename='ukmo_tnat_area_vs_vortex_strength_12pan.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
nlvls=13
col1=1+indgen(nlvls)*icolmax/nlvls
slab=[$
'9495','9596','9697','9798','9899','9900',$
'0001','0102','0203','0304','0405']
y1=['1994','1995','1996','1997','1998','1999','2000','2001','2002','2003','2004']
y2=['1995','1996','1997','1998','1999','2000','2001','2002','2003','2004','2005']
odir='/aura2/harvey/Vortex_Index/Datfiles/'
erase
nyear=n_elements(slab)
for iyear=0L,nyear-1L do begin
;
; restore vortex strength index
;
    restore,odir+'vortex_strength_'+y1(iyear)+'_'+y2(iyear)+'_utls.sav'
    sfile_strength=sfile
    nstrength=n_elements(sfile_strength)
;
; restore Tnat area
;
    restore,'ukmo_Tnat_area_'+slab(iyear)+'.sav'	;,area_ave,th,sfile,sdate
ntnat=n_elements(sfile)
if nstrength ne ntnat then begin
; 
; need to eliminate some strength days
;
if nstrength gt ntnat then begin
   flag=fltarr(nstrength)
   for ii=0L,nstrength-1L do begin
       sfile0=sfile_strength(ii)
       index=where(sfile eq sfile0)
       if index(0) eq -1L then flag(ii)=-99.
   endfor
   index=where(flag eq 0.,nstrength)
   prod_zt=reform(prod_zt(index,*))
   sfile_strength=reform(sfile_strength(index))
endif
if nstrength ne ntnat then stop
endif

    ldate=long(sdate)
    nday=n_elements(sdate)
    print,slab(iyear),' ',min(ldate),max(ldate),min(area_ave),max(area_ave),min(prod_zt),max(prod_zt)
;
; scatter area_ave and prod_zt
;
    xmn=xorig(iyear)
    xmx=xorig(iyear)+xlen
    ymn=yorig(iyear)
    ymx=yorig(iyear)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    level=findgen(nlvls)
    level(0)=0.01
    ylab=' ' & xlab=' '
    if iyear eq 0L or iyear eq 4L or iyear eq 8L then ylab='Strength Index'
    if iyear eq 8L or iyear eq 9L or iyear eq 10L then xlab='Tnat Area'
    plot,findgen(10),findgen(10),/nodata,xrange=[0.,13.],yrange=[10.,70.],$
            charsize=1.5,ytitle=ylab,xtitle=xlab,color=0,title=slab(iyear),charthick=2
theta_2d=0.*area_ave
day_2d=0.*area_ave
for k=0L,n_elements(th)-1L do theta_2d(*,k)=th(k)
for k=0L,NSTRENGTH-1L do day_2d(k,*)=k+1.0
    index=where(area_ave ne 0. and prod_zt ne 0. and theta_2d le 500.,npts)
;   oplot,area_ave(index),prod_zt(index),psym=8,color=0
thmin=min(theta_2d(index))-2.
thmax=max(theta_2d(index))+2.
    for ii=0L,npts-1L do $
        oplot,[area_ave(index(ii)),area_ave(index(ii))],[prod_zt(index(ii)),prod_zt(index(ii))],$
              psym=8,color=((theta_2d(index(ii))-thmin)/(thmax-thmin))*icolmax,symsize=1.25
;
; color by day of winter
;
;thmin=min(day_2d(index))-1.
;thmax=max(day_2d(index))+1.
;    for ii=0L,npts-1L do $
;        oplot,[area_ave(index(ii)),area_ave(index(ii))],[prod_zt(index(ii)),prod_zt(index(ii))],$
;              psym=8,color=((thmax-day_2d(index(ii)))/(thmax-thmin))*icolmax,symsize=1.25

endfor	; loop over years
;
; color bar
;
xmnb=xorig(nyear)+0.05+cbaryoff
xmxb=xmnb+cbarydel
ymn=yorig(nyear)
ymx=yorig(nyear)+ylen
set_viewport,xmnb,xmxb,ymn,ymx
imin=thmin
imax=thmax
!type=2^2+2^3+2^5
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],$
     ytitle='Theta',charsize=1.5,color=0,charthick=2
xbox=[0,10,10,0,0]
yy1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[yy1,yy1,yy1+dy,yy1+dy,yy1]
    polyfill,xbox,ybox,color=col1(j)
    yy1=yy1+dy
endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim ukmo_tnat_area_vs_vortex_strength_12pan.ps -rotate -90 ukmo_tnat_area_vs_vortex_strength_12pan.jpg'
endif

end
