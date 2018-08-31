;
; plot ACE zonal mean no2
;
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,0.8*cos(a),0.8*sin(a),/fill
setplot='x'
read,'setplot=',setplot
mcolor=icolmax
icmm1=icolmax-1
icmm2=icolmax-2
nxdim=600 & nydim=600
xorig=[0.15]
yorig=[0.45]
xlen=0.7
ylen=0.45
cbaryoff=0.08
cbarydel=0.02
!NOERAS=-1
!p.font=1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
month='        '+['J','F','M','A','M','J','J','A','S','O','N','D',' ']
dira='/aura3/data/ACE_data/Datfiles_SOSST/v2.2/'
syear=['2004','2005','2006']
lyear=long(syear)
print,'2004   2005   2006'
kyear=2006L
;read,'Enter desired year ',kyear
x=where(kyear eq lyear)
if x(0) eq -1L then stop,'Invalid year'
syear0=syear(x)
;
; restore ACE SOSST data
;
restore,dira+'cat_ace_v2.2.'+syear0
restore,dira+'no2_ace_v2.2.'+syear0

plotlat0:
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,fdoy,latitude,psym=8,color=0,yrange=[-90.,90.],xrange=[1.,366.],xticks=12,$
     xtickname=month,charsize=2,ytitle='Latitude',yticks=6,title=syear0
iday0=90L
;read,'Enter desired start day (1-365) ',iday0
plots,iday0,-90
plots,iday0,90.,/continue,thick=3,color=0
iday0logic='y'
;read,'Is start day correct? ',iday0logic
if iday0logic eq 'n' then goto,plotlat0

plotlat1:
erase
plot,fdoy,latitude,psym=8,color=0,yrange=[-90.,90.],xrange=[1.,366.],xticks=12,$
     xtickname=month,charsize=2,ytitle='Latitude',yticks=6,title=syear0
plots,iday0,-90
plots,iday0,90.,/continue,thick=3,color=0
iday1=152L
;read,'Enter desired end day (1-365) ',iday1
plots,iday1,-90
plots,iday1,90.,/continue,thick=3,color=0
iday1logic='y'
;read,'Is end day correct? ',iday1logic
if iday1logic eq 'n' then goto,plotlat1
;
; construct zonal mean between iday0 and iday1
;
x=where(fdoy ge iday0 and fdoy le iday1,nprof)
acedate=date
sdate0=strcompress(min(acedate(x)),/remove_all)
sdate1=strcompress(max(acedate(x)),/remove_all)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,bits=8,filename='ace_yz_no2_'+sdate0+'-'+sdate1+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
endif
;
; bin ACE data in latitude bins
;
o3data=reform(mix(x,*))
ydata=reform(latitude(x))
nr=36L
nz=n_elements(altitude)
deltay=5.0
latbin=-87.5+deltay*findgen(nr)
lat2d=fltarr(nr,nz)
alt2d=fltarr(nr,nz)
for i=0L,nr-1L do alt2d(i,*)=altitude
for k=0L,nz-1L do lat2d(*,k)=latbin
o3array=fltarr(nr,nz)
no3array=lonarr(nr,nz)
for i=0L,nprof-1L do begin
    y0=ydata(i)
    o3prof=reform(o3data(i,*))
    for j=0L,nr-1L do begin
        if latbin(j)-deltay/2. le y0 and latbin(j)+deltay/2. gt y0 then begin
           index=where(o3prof ne -99.)
           if index(0) ne -1L then begin
              o3array(j,index)=o3array(j,index)+o3prof(index)
              no3array(j,index)=no3array(j,index)+1L
           endif
        endif
    endfor
endfor
;
; average contents of each bin
;
index=where(no3array gt 0L)
if index(0) ne -1L then $
   o3array(index)=1.e9*o3array(index)/float(no3array(index))
index=where(no3array eq 0L)
if index(0) ne -1L then o3array(index)=-99.
index=where(o3array ne -99.)
if index(0) eq -1L then stop
print,min(o3array(index)),max(o3array(index))
;
; fill data void regions
;
o3save=o3array
o3filled=o3array
for k=0,n_elements(altitude)-1L do begin
    o3lev=reform(o3array(*,k))
    index1=where(o3lev ne -99.,ngood)
    index2=where(o3lev eq -99.)
    if ngood gt 1 and index1(0) ne -1 and index2(0) ne -1 then begin
       filled=interpol(o3lev(index1),index1,index2)
       o3filled(index2,k)=filled
    endif
endfor
o3array=o3filled
;
; plot zonal mean ozone
;
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=[0.,0.0001,0.0002,0.0005,0.001,0.002,0.005,0.01,0.02,0.05,0.1,0.2,0.5,1.,2.,5.,10.]
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,o3array,latbin,altitude,xrange=[-90.,90.],yrange=[1.,120.],xticks=6,$
        charsize=2,xtitle='Latitude',ytitle='Altitude (km)',levels=level,/cell_fill,$
        title='Zonal Mean ACE NO!l2!n',c_color=col1,color=0,min_value=-99.
contour,o3array,latbin,altitude,/overplot,levels=level,color=0,/follow,min_value=-99.,$
        c_labels=0*level
index=where(o3save eq -99.)
;if index(0) ne -1L then oplot,lat2d(index),alt2d(index),psym=8,color=mcolor
xyouts,-30.,110.,sdate0+' - '+sdate1,charsize=2,/data,color=mcolor
imin=min(level)
imax=max(level)
xmnb=xmx+.05
xmxb=xmnb+.01
set_viewport,xmnb,xmxb,ymn,ymx
!type=2^2+2^3+2^5
plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,charsize=2
xbox=[0,10,10,0,0]
y1=imin
dy=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor

ymnb=ymn-.35
ymxb=ymnb+.25
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3
plot,fdoy,latitude,psym=8,color=0,yrange=[-90.,90.],xrange=[1.,366.],xticks=12,$
     xtickname=month,charsize=2,ytitle='Latitude',yticks=6
loadct,0
plots,iday0,-90
plots,iday0,90.,/continue,thick=8,color=200
plots,iday1,-90
plots,iday1,90.,/continue,thick=8,color=200
plots,iday0,90.
plots,iday1,90.,/continue,thick=8,color=200
plots,iday0,-90.
plots,iday1,-90.,/continue,thick=8,color=200

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim ace_yz_no2_'+sdate0+'-'+sdate1+'.ps -rotate -90 ace_yz_no2_'+sdate0+'-'+sdate1+'.jpg'
endif
end
