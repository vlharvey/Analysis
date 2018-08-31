;
; plot and save user entire season of daily GEOS and MLS at specified latitude range 
;
@stddat
@kgmt
@ckday
@kdate

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
nxdim=750
nydim=750
yorig=[0.7,0.4,0.1]
xorig=[0.1,0.1,0.1]
xlen=0.75
ylen=0.2
cbaryoff=0.075
cbarydel=0.01
setplot='x'
read,'setplot=',setplot
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=icolmax
endif
mdir='/Volumes/earth/aura6/data/MLS_data/Datfiles_SOSST/'
restore,mdir+'yz_geos5_mls_20101221-20110110.sav
print,alat
rlat=61.25
read,'Enter desired latitude ',rlat
index=where(rlat eq alat)
ilat=index(0)
slat=strcompress(rlat,/remove_all)
dum=findfile(mdir+'*_'+slat+'.sav')
print,dum
!noeras=1
restore,dum(0)
result=strsplit(dum(0),'/',/extract)
result2=strsplit(result(6),'_',/extract)
daterange=result2(3)

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='zt_geos5_'+slat+'_ubar.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
;
; plot temperature
;
erase
xyouts,.3,.95,'Ubar at Latitude= '+slat,charsize=2,charthick=2,/normal,color=0
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
nlvls=21
col1=1+indgen(nlvls)*icolmax/nlvls
level=-100.+10.*findgen(nlvls)
index=where(ubarz eq 0.)
if index(0) ne -1L then ubarz(index)=0./0.
contour,ubarz,dfs,altitude,/noeras,xrange=[-50.,70.],yrange=[0.,100.],charsize=1.5,color=0,$
      ytitle='Altitude (km)',/cell_fill,c_color=col1,levels=level,xtitle='DFS',title=daterange,charthick=2
index=where(level gt 0.)
contour,ubarz,dfs,altitude,levels=level(index),color=0,/follow,/overplot,c_labels=0*level(index)
index=where(level lt 0.)
contour,ubarz,dfs,altitude,levels=level(index),color=mcolor,c_linestyle=5,/follow,/overplot,c_labels=0*level(index)
contour,ubarz,dfs,altitude,levels=[0],color=0,thick=5,/follow,/overplot,c_labels=0*level(index)
      xmnb=xorig(0)+xlen+0.1
      xmxb=xmnb+cbarydel
      set_viewport,xmnb,xmxb,ymn,ymx
      !type=2^2+2^3+2^5
      omin=min(level)
      omax=max(level)
      plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=0,charthick=2,charsize=1.5,title='(m/s)'
      xbox=[0,10,10,0,0]
      y1=omin
      dy=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor
ubarz0=ubarz
daterange0=daterange
restore,dum(1)
result=strsplit(dum(1),'/',/extract)
result2=strsplit(result(6),'_',/extract)
daterange=result2(3)

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
index=where(ubarz eq 0.)
if index(0) ne -1L then ubarz(index)=0./0.
contour,ubarz,dfs,altitude,/noeras,xrange=[-50.,70.],yrange=[0.,100.],charsize=1.5,color=0,$
      ytitle='Altitude (km)',/cell_fill,c_color=col1,levels=level,xtitle='DFS',title=daterange,charthick=2
index=where(level gt 0.)
contour,ubarz,dfs,altitude,levels=level(index),color=0,/follow,/overplot,c_labels=0*level(index)
index=where(level lt 0.)
contour,ubarz,dfs,altitude,levels=level(index),color=mcolor,c_linestyle=5,/follow,/overplot,c_labels=0*level(index)
contour,ubarz,dfs,altitude,levels=[0],color=0,thick=5,/follow,/overplot,c_labels=0*level(index)
      xmnb=xorig(1)+xlen+0.1
      xmxb=xmnb+cbarydel
      set_viewport,xmnb,xmxb,ymn,ymx
      !type=2^2+2^3+2^5
      omin=min(level)
      omax=max(level)
      plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=0,charthick=2,charsize=1.5,title='(m/s)'
      xbox=[0,10,10,0,0]
      y1=omin
      dy=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor

restore,'c11_rb.tbl'
tvlct,c1,c2,c3
col2=1+indgen(11)
pdiff=0.*ubarz
index=where(finite(ubarz0) eq 1 and finite(ubarz) eq 1)
pdiff(index)=ubarz0(index)-ubarz(index)
level=-50.+10.*findgen(11)
!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,pdiff,dfs,altitude,xrange=[-50.,70.],yrange=[0.,100.],$
        xtitle='DFS',charsize=1.5,levels=level,/cell_fill,$
        title=daterange0+' minus '+daterange,c_color=col2,color=0,min_value=-99.,charthick=2
index=where(level gt 0.)
contour,pdiff,dfs,altitude,/overplot,levels=level(index),color=0,/follow,min_value=-99.,c_labels=0*level(index)
index=where(level lt 0.)
contour,pdiff,dfs,altitude,/overplot,levels=level(index),color=mcolor,/follow,min_value=-99.,c_labels=0*level(index)
contour,pdiff,dfs,altitude,/overplot,levels=[0],color=0,thick=3,min_value=-99.
      xmnb=xorig(2)+xlen+0.1
      xmxb=xmnb+cbarydel
      set_viewport,xmnb,xmxb,ymn,ymx
      !type=2^2+2^3+2^5
      omin=min(level)
      omax=max(level)
      plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=0,charthick=2,charsize=1.5,title='(m/s)'
      xbox=[0,10,10,0,0]
      y1=omin
      dy=(omax-omin)/float(11)
      for j=0,11-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col2(j)
          y1=y1+dy
      endfor
loadct,39

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim zt_geos5_'+slat+'_ubar.ps -rotate -90 zt_geos5_'+slat+'_ubar.jpg'
;  spawn,'/usr/bin/rm -f zt_geos5_'+slat+'_ubar.ps'
endif
end
