;
; CFC-11
; HIRDLS2ALL data is pressure data that must be interpolated to ACE altitudes
; plot HIRDLS and ACE zonal means and their differences
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
nxdim=800 & nydim=800
xorig=[0.2,0.2,0.2]
yorig=[0.7,0.4,0.1]
npan=n_elements(xorig)
xlen=0.6
ylen=0.225
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
dirh='/aura3/data/ACE_data/Datfiles/'
;
; restore zonal mean HIRDLS
;
;restore,file='/aura3/data/HIRDLS_data/Analysis/HIRDLS2ALL_h2o_20060501-20060531.sav'
restore,file='/aura3/data/HIRDLS_data/Analysis/HIRDLS2ALL_v2.02.06.20060507-20060531.sav'
hdate0='20060501'
hdate1='20060531'
hirdls_pressure=pressure
;
hirdls_altyp=altyz
index=where(hirdls_altyp ne -99.)
if index(0) ne -1L then hirdls_altyp(index)=hirdls_altyp(index)/1000.	; km
hirdls_H2OYp=CFC11YZ
;
; restore monthly mean zonal mean binned in latitude
; vars: latbin,altitude,tempyz,ntempyz,ch4yz,nch4yz,$
;     h2oyz,nh2oyz,h2oyz,nh2oyz,h2oyz,nh2oyz,o3yz,no3yz
;
restore,file='ACEorig_20060401-20060531.sav'
adate0='20060401'
adate1='20060531'
ace_H2OYZ=CFC11YZ
;
; interpolate HIRDLS to 120 km altitude grid
; this "old" ACE data is top-down
;
hirdls_h2oyz=0.*ACE_h2oYZ
for j=0,n_elements(latbin)-1L do begin
for k=0,n_elements(altitude)-1L do begin
    zp=altitude(k)
    for kk=0L,n_elements(hirdls_pressure)-2L do begin
        hz0=hirdls_altyp(j,kk) & hz1=hirdls_altyp(j,kk+1L)
        if hirdls_H2OYp(j,kk) ne -99. and hirdls_H2OYp(j,kk+1L) ne -99. then begin
        if hz0 lt zp and hz1 ge zp then begin
           zscale=(hz1-zp)/(hz1-hz0)
           hirdls_h2oyz(j,k)=hirdls_H2OYp(j,kk+1)-zscale*(hirdls_H2OYp(j,kk+1L)-hirdls_H2OYp(j,kk))
;print,hz0,zp,hz1,zscale
;print,hirdls_H2OYp(j,kk),hirdls_h2oyz(j,k),hirdls_H2OYp(j,kk+1L)
;stop
        endif
        endif
    endfor
endfor
endfor
;
; difference arrays
;
diff_H2OYZ=0.*H2OYZ
x=where(HIRDLS_h2oYZ ne -99. and ACE_h2oYZ ne -99.)
if x(0) ne -1L then diff_h2oYZ(x)=100.*(HIRDLS_h2oYZ(x)-ace_h2oYZ(x))/ace_h2oYZ(x)

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,bits=8,filename='hirdls2allv2.02.06-ace_yz_'+adate0+'-'+adate1+'_cfc11.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
endif

erase
hdata=HIRDLS_h2oYZ*1.e9
adata=ace_h2oYZ*1.e9
ddata=diff_h2oYZ
index=where(hdata eq 0.)
if index(0) ne -1L then hdata(index)=-99999.
index=where(adata eq 0.)
if index(0) ne -1L then adata(index)=-99999.
index=where(hdata le 0. or adata le 0. or ddata eq 0.)
if index(0) ne -1L then ddata(index)=-99999.
level=0.02*findgen(21)
dlevel=-100+10.*findgen(21)
;
; fill data void regions
;
;   plotsave=plotdata
;   plotfilled=plotdata
;   for k=0,n_elements(altitude)-1L do begin
;       plotlev=reform(plotdata(*,k))
;       index1=where(plotlev ne -99999.,ngood)
;       index2=where(plotlev eq -99999.)
;       if ngood gt 1 and index1(0) ne -1 and index2(0) ne -1 then begin
;          filled=interpol(plotlev(index1),index1,index2)
;          plotfilled(index2,k)=filled
;       endif
;   endfor
;   plotdata=plotfilled
;
; plot zonal mean h2o
;
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*mcolor/nlvls
    xlabs=' '+strarr(7)
    contour,hdata,latbin,altitude,xrange=[-90.,90.],yrange=[10.,50.],xticks=6,ytitle='Altitude (km)',$
            xtickname=xlabs,charsize=2.5,levels=level,/cell_fill,$
            title='HIRDLS v2.02.06 CFC-11 '+hdate0+'-'+hdate1,c_color=col1,color=0,min_value=-99999.
    contour,hdata,latbin,altitude,/overplot,levels=level,color=0,/follow,min_value=-99999.,$
            c_labels=0*level
;   contour,ddata,latbin,altitude,/overplot,levels=[0],color=mcolor,/follow,min_value=-99999.,thick=3
    imin=min(level)
    imax=max(level)
    xmnb=xmx+.07
    xmxb=xmnb+.01
    set_viewport,xmnb,xmxb,ymn,ymx
    !type=2^2+2^3+2^5
    plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,charsize=2.5
    xbox=[0,10,10,0,0]
    y1=imin
    dy=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
        ybox=[y1,y1,y1+dy,y1+dy,y1]
        polyfill,xbox,ybox,color=col1(j)
        y1=y1+dy
    endfor
    xyouts,xmnb-0.04,ymx+0.01,'(ppbv)',/normal,charsize=2,color=0

    !type=2^2+2^3
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*mcolor/nlvls
    contour,adata,latbin,altitude,xrange=[-90.,90.],yrange=[10.,50.],xticks=6,ytitle='Altitude (km)',$
            xtickname=xlabs,charsize=2.5,levels=level,/cell_fill,$
            title='ACE CFC-11 '+adate0+'-'+adate1,c_color=col1,color=0,min_value=-99999.
    contour,adata,latbin,altitude,/overplot,levels=level,color=0,/follow,min_value=-99999.,$
            c_labels=0*level
;   contour,ddata,latbin,altitude,/overplot,levels=[0],color=mcolor,/follow,min_value=-99999.,thick=3
    imin=min(level)
    imax=max(level)
    xmnb=xmx+.07
    xmxb=xmnb+.01
    set_viewport,xmnb,xmxb,ymn,ymx
    !type=2^2+2^3+2^5
    plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,charsize=2.5
    xbox=[0,10,10,0,0]
    y1=imin
    dy=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
        ybox=[y1,y1,y1+dy,y1+dy,y1]
        polyfill,xbox,ybox,color=col1(j)
        y1=y1+dy
    endfor
    xyouts,xmnb-0.04,ymx+0.01,'(ppbv)',/normal,charsize=2,color=0

nr=n_elements(latbin)
nz=n_elements(altitude)
lat2d=fltarr(nr,nz)
alt2d=fltarr(nr,nz)
for i=0L,nr-1L do alt2d(i,*)=altitude
for k=0L,nz-1L do lat2d(*,k)=latbin
x=where(lat2d le -50. and ddata ne -99999.)
if x(0) ne -1L then ddata(x)=-99999.
    !type=2^2+2^3
    xmn=xorig(2)
    xmx=xorig(2)+xlen
    ymn=yorig(2)
    ymx=yorig(2)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    nlvls=n_elements(dlevel)
    col1=1+indgen(nlvls)*mcolor/nlvls
    xlabs=['-90','-60','-30','0','30','60','90']
    contour,ddata,latbin,altitude,xrange=[-90.,90.],yrange=[10.,50.],xticks=6,$
            xtickname=xlabs,charsize=2.5,levels=dlevel,/cell_fill,ytitle='Altitude (km)',$
            title='HIRDLS-ACE CFC-11 Difference (%)',c_color=col1,color=0,min_value=-99999.,xtitle='Latitude'
    index=where(dlevel lt 0.)
    contour,ddata,latbin,altitude,/overplot,levels=dlevel(index),color=0,/follow,min_value=-99999.,$
            c_labels=0*index,c_charsize=2
    index=where(dlevel gt 0.)
    contour,ddata,latbin,altitude,/overplot,levels=dlevel(index),color=mcolor,/follow,min_value=-99999.,$
            c_labels=0*index,c_charsize=2
    contour,ddata,latbin,altitude,/overplot,levels=[0],color=0,/follow,min_value=-99999.,thick=6,c_labels=[0]

    imin=min(dlevel)
    imax=max(dlevel)
    xmnb=xmx+.07
    xmxb=xmnb+.01
    set_viewport,xmnb,xmxb,ymn,ymx
    !type=2^2+2^3+2^5
    plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,charsize=2.5
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
   spawn,'convert -trim hirdls2allv2.02.06-ace_yz_'+adate0+'-'+adate1+'_cfc11.ps -rotate -90 hirdls2allv2.02.06-ace_yz_'+adate0+'-'+adate1+'_cfc11.jpg'
endif
end
