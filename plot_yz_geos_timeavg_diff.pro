;
; plot user specified time average zonal mean GEOS Ubar and differences
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

sver='v2.2'
sver='v3.3'

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
xorig=[0.1,0.4,0.7]
yorig=[0.4,0.4,0.4]
xlen=0.25
ylen=0.25
cbaryoff=0.075
cbarydel=0.01
setplot='x'
read,'setplot=',setplot
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=icolmax
endif
mdir='/Volumes/earth/aura6/data/MLS_data/Datfiles_SOSST/'
!noeras=1
lstmn=1L & lstdy=1L & lstyr=2010L
ledmn=2L & leddy=20L & ledyr=2010L
lstday=0L & ledday=0L
;
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
firstdate=string(FORMAT='(i2.2)',lstmn)+string(FORMAT='(i2.2)',lstdy)
lastdate=string(FORMAT='(i2.2)',ledmn)+string(FORMAT='(i2.2)',leddy)
daterange=firstdate+'-'+lastdate
dum=findfile(mdir+'yz_geos5_mls_*'+firstdate+'*'+lastdate+'.sav')
print,dum
restore,dum(0)
tbar0=ubarz
restore,dum(1)
tbar1=ubarz

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='yz_geos_timeavg_diff_'+daterange+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
;
; plot Ubar
;
erase
xyouts,.3,.7,'Avg Ubar '+daterange,charsize=2,charthick=2,/normal,color=0
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
nlvls=21
col1=1+indgen(nlvls)*icolmax/nlvls
level=-100.+10.*findgen(nlvls)
index=where(tbar0 eq 0.)
if index(0) ne -1L then tbar0(index)=0./0.
contour,tbar0,alat,altitude,/noeras,xrange=[-90.,90.],yrange=[0.,100.],charsize=1.5,color=0,$
      ytitle='Altitude (km)',xticks=6,/cell_fill,c_color=col1,levels=level,xtitle='Latitude',title='2009',charthick=2
index=where(level gt 0.)
contour,tbar0,alat,altitude,levels=level(index),color=0,/follow,/overplot,c_labels=0*level(index)
index=where(level lt 0.)
contour,tbar0,alat,altitude,levels=level(index),color=mcolor,c_linestyle=5,/follow,/overplot,c_labels=0*level(index)
contour,tbar0,alat,altitude,levels=[0],color=0,thick=5,/follow,/overplot,c_labels=0*level(index)
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='(m/s)',charsize=1.5,charthick=2
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
index=where(tbar1 eq 0.)
if index(0) ne -1L then tbar1(index)=0./0.
contour,tbar1,alat,altitude,/noeras,xrange=[-90.,90.],yrange=[0.,100.],charsize=1.5,color=0,$
      xticks=6,/cell_fill,c_color=col1,levels=level,xtitle='Latitude',title='2010',charthick=2
index=where(level gt 0.)
contour,tbar1,alat,altitude,levels=level(index),color=0,/follow,/overplot,c_labels=0*level(index)
index=where(level lt 0.)
contour,tbar1,alat,altitude,levels=level(index),color=mcolor,c_linestyle=5,/follow,/overplot,c_labels=0*level(index)
contour,tbar1,alat,altitude,levels=[0],color=0,/follow,/overplot,thick=5,c_labels=0*level(index)
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='(m/s)',charsize=1.5,charthick=2
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor

restore,'c11_rb.tbl'
tvlct,c1,c2,c3
col2=1+indgen(11)
pdiff=-99.+0.*tbar0
index=where(finite(tbar0) eq 1 and finite(tbar1) eq 1)
if index(0) eq -1L then stop
pdiff(index)=tbar0(index)-tbar1(index)
index=where(pdiff eq -99.)
if index(0) ne -1L then pdiff(index)=0./0.
level=-20.+4.*findgen(11)
!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,pdiff,alat,altitude,xrange=[-90.,90.],yrange=[0.,100.],$
        xticks=6,xtitle='Latitude',charsize=1.5,levels=level,/cell_fill,$
        title='dU',c_color=col2,color=0,charthick=2
index=where(level gt 0.)
contour,pdiff,alat,altitude,/overplot,levels=level(index),color=0,/follow,c_labels=0*level(index)
index=where(level lt 0.)
contour,pdiff,alat,altitude,/overplot,levels=level(index),color=mcolor,/follow,c_labels=0*level(index)
contour,pdiff,alat,altitude,/overplot,levels=[0],color=0,thick=3
imin=min(level)
imax=max(level)
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,$
      xtitle='(m/s)',color=0,xticks=n_elements(level)/2,charsize=1.5,charthick=2
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/(float(n_elements(col2)))
for jj=0L,n_elements(col2)-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col2(jj)
    x2=x2+dx
endfor
loadct,39

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim yz_geos_timeavg_diff_'+daterange+'.ps -rotate -90 yz_geos_timeavg_diff_'+daterange+'.jpg'
;  spawn,'/usr/bin/rm -f yz_geos_timeavg_diff_'+daterange+'.ps'
endif
end
