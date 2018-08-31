;
; multi-year DJF and JJA YZ of T, U, Mark
; SmidEmax 300 years
; monthly mean of daily averages data 
;
loadct,39
mcolor=byte(!p.color)
icmm1=mcolor-1B
icmm2=mcolor-2B
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.15,0.55,0.15,0.55,0.15,0.55]
yorig=[0.7,0.7,0.4,0.4,0.1,0.1]
xlen=0.325
ylen=0.25
cbaryoff=0.1
cbarydel=0.01
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
smonth=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
nmonth=n_elements(smonth)

nz=61
altitude=30.+findgen(nz)	; interpolate CO grad vortex frequency to constant altitude for difference plots
;
; restore seasonal mean 3D T, U, P, Z, Mark on theta
;
; ALAT            FLOAT     = Array[96]
; ALON            FLOAT     = Array[144]
; DJF_MARK        FLOAT     = Array[96, 144, 22]
; DJF_Z           FLOAT     = Array[96, 144, 22]
; JJA_MARK        FLOAT     = Array[96, 144, 22]
; JJA_Z           FLOAT     = Array[96, 144, 22]
; TH              FLOAT     = Array[22]
;
restore,'smidemax_300-year_TUmark_djf_jja.sav'	; SF marker DJF_MARK, DJF_Z
restore,'smidemax_300-year_COmark_djf_jja.sav'	; CO marker DJF_MARKCO      FLOAT     = Array[144, 96, 22]

djf_markcoyz=mean(djf_markco,dim=1)	; zonal means
jja_markcoyz=mean(jja_markco,dim=1)
;
; plot
;
if setplot eq 'ps' then begin
   lc=0
   !p.font=0
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
           /bold,/color,bits_per_pixel=8,/helvetica,filename='figure_3_comarkbar.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; DJF
;
nlvls=10
tlevel=0.1+0.1*findgen(nlvls)
nlvls=n_elements(tlevel)
col1=(findgen(nlvls)/float(nlvls-1))*mcolor
col1(-1)=col1(-1)-1
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
myz=jja_markcoyz
zyz=mean(JJA_Z,dim=2)
contour,myz,alat,zyz,/noera,/fill,color=0,c_color=col1,levels=tlevel,xrange=[-90,90],yrange=[30,90],ytitle='Altitude (km)',charsize=1.5,charthick=2,title='JJA',xticks=6
contour,myz,alat,zyz,/noera,/foll,color=0,levels=tlevel,/overplot
myz=mean(JJA_MARK,dim=2)
contour,myz,alat,zyz,/noera,/foll,color=mcolor*.9,levels=[0.1,0.5,0.9],/overplot,thick=5

xyouts,xmn-0.1,ymn+0.02,'WACCM',/normal,color=0,charsize=1.5,charthick=2,orientation=90

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
myz=djf_markcoyz
zyz=mean(DJF_Z,dim=2)
contour,myz,alat,zyz,/noera,/fill,color=0,c_color=col1,levels=tlevel,xrange=[-90,90],yrange=[30,90],charsize=1.5,charthick=2,title='DJF',xticks=6
contour,myz,alat,zyz,/noera,/foll,color=0,levels=tlevel,/overplot
myz=mean(DJF_MARK,dim=2)
contour,myz,alat,zyz,/noera,/foll,color=mcolor*.9,levels=[0.1,0.5,0.9],/overplot,thick=5
;
; interpolate WACCM CO grad vortex freq to constant altitude levels
;
jja_markcoyz_waccm_alt=fltarr(nr,nz)
djf_markcoyz_waccm_alt=fltarr(nr,nz)
jja_zyz=mean(JJA_Z,dim=2)
djf_zyz=mean(DJF_Z,dim=2)
for j=0L,nr-1L do begin
    jja_markcoyz_waccm_alt(j,*)=interpol(reform(jja_markcoyz(j,*)),reform(jja_zyz(j,*)),altitude)
    djf_markcoyz_waccm_alt(j,*)=interpol(reform(djf_markcoyz(j,*)),reform(djf_zyz(j,*)),altitude)
endfor

level  = tlevel
nlvls  = n_elements(level)
slab=' '+strarr(n_elements(level))
!type=2^2+2^3+2^5+2^6
plot,[0,0],[0,0],xrange=[0,10],yrange=[0,1],/noeras,yticks=n_elements(level)-1L,$
      position = [.9,.4,.95,max(yorig)+ylen],ytickname=slab,/nodata
xyouts,.98,.45,'Polar Vortex Frequency',/normal,orientation=90,color=0,charsize=1.25,charthick=2
xbox=[0,10,10,0,0]
y2=0
dy= 1./(n_elements(level))
for j=0,n_elements(col1)-1 do begin
    ybox=[y2,y2,y2+dy,y2+dy,y2]
    polyfill,xbox,ybox,color=col1[j]
    y2=y2+dy
endfor
slab=strcompress(string(format='(f4.1)',level),/remove_all)
slabcolor = fltarr(n_elements(level))*0.
slabcolor[0:4] = 255        ; set first few labels to white so they are visible
y1=dy/2 ; center of first color level
for i=0L,n_elements(slab)-1L do begin
    slab0=slab[i]
    xyouts,5,y1-dy/2.,slab0,charsize=1.3,/data,color=slabcolor[i],align = .5 ; This should place the label on the left side of each color level
    y1=y1+dy
endfor
;
; restore DJF/JJA MLS CO-Mark and MERRA2 Mark
; DJF_MARKCO_MLS  FLOAT     = Array[144, 96, 37]
; ZBAR_COLEV_DJF  FLOAT     = Array[96, 37]
;
restore,'mls_COmark_djf_jja.sav'	; nc,nr,nth,alon,alat,th,djf_markco_mls,jja_markco_mls,ZBAR_colev_DJF,ZBAR_colev_JJA
;
; DJF_MARK2AVG    FLOAT     = Array[96, 144, 30]
; DJF_Z2AVG       FLOAT     = Array[96, 144, 30]
;
restore,'MERRA2_djf_jja.sav'		; alon,alat,th,djf_mark2avg,djf_z2avg,jja_mark2avg,jja_z2avg (among other things)
djf_markcoyz=mean(djf_markco_mls,dim=1)	; MLS zonal means
jja_markcoyz=mean(jja_markco_mls,dim=1)
!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
myz=jja_markcoyz
zyz=ZBAR_colev_JJA
contour,myz,alat,zyz,/noera,/cell_fill,color=0,c_color=col1,levels=tlevel,xrange=[-90,90],yrange=[30,90],ytitle='Altitude (km)',charsize=1.5,charthick=2,xticks=6
contour,myz,alat,zyz,/noera,/foll,color=0,levels=tlevel,/overplot
dum=mean(jja_mark2avg,dim=2)
zdum=mean(jja_z2avg,dim=2)
contour,dum,alat,zdum,levels=[0.1,0.5,0.9],color=mcolor*.9,thick=5,/follow,/noeras,/overplot

xyouts,xmn-0.1,ymn+0.02,'MLS/MERRA2',/normal,color=0,charsize=1.5,charthick=2,orientation=90

!type=2^2+2^3
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
myz=djf_markcoyz
zyz=ZBAR_colev_DJF
contour,myz,alat,zyz,/noera,/cell_fill,color=0,c_color=col1,levels=tlevel,xrange=[-90,90],yrange=[30,90],charsize=1.5,charthick=2,xticks=6
contour,myz,alat,zyz,/noera,/foll,color=0,levels=tlevel,/overplot
dum=mean(djf_mark2avg,dim=2)
zdum=mean(djf_z2avg,dim=2)
contour,dum,alat,zdum,levels=[0.1,0.5,0.9],color=mcolor*.9,thick=5,/follow,/noeras,/overplot
;
; interpolate MLS CO grad vortex freq to constant altitude levels
;
bad=where(finite(ZBAR_colev_JJA) eq 0)
if bad(0) ne -1 then ZBAR_colev_JJA(bad)=0.
bad=where(finite(ZBAR_colev_DJF) eq 0)
if bad(0) ne -1 then ZBAR_colev_DJF(bad)=0.

jja_markcoyz_mls_alt=fltarr(nr,nz)
djf_markcoyz_mls_alt=fltarr(nr,nz)
for j=0L,nr-1L do begin
    prof=reform(jja_markcoyz(j,*))
    zprof=reform(ZBAR_colev_JJA(j,*))
    index=where(zprof ne 0.)
    prof=reverse(prof(index))
    zprof=reverse(zprof(index))
    jja_markcoyz_mls_alt(j,*)=interpol(prof,zprof,altitude)

;print,'prof ',reform(prof)
;print,'zprof ',reform(zprof)
;print,'new ',reform(jja_markcoyz_mls_alt(j,*))
;stop

    prof=reform(djf_markcoyz(j,*))
    zprof=reform(ZBAR_colev_DJF(j,*))
    index=where(zprof ne 0.)
    prof=reverse(prof(index))
    zprof=reverse(zprof(index))
    djf_markcoyz_mls_alt(j,*)=interpol(prof,zprof,altitude)
endfor
;contour,djf_markcoyz_mls_alt,alat,altitude,levels=tlevel,/overplot,/follow,color=250
;
; differences
;
restore,'c11_rb.tbl'
tvlct,c1,c2,c3
col2=1+indgen(11)
nlvls=n_elements(col2)
!type=2^2+2^3
xmn=xorig(4)
xmx=xorig(4)+xlen
ymn=yorig(4)
ymx=yorig(4)+ylen
set_viewport,xmn,xmx,ymn,ymx
jja_diff=jja_markcoyz_waccm_alt-jja_markcoyz_mls_alt
index=where(jja_markcoyz_mls_alt eq 0. or finite(jja_markcoyz_mls_alt) eq 0)
if index(0) ne -1L then jja_diff(index)=0./0.
tlevel=-.5+0.1*findgen(nlvls)
index=where(jja_diff lt min(tlevel))
if index(0) ne -1L then jja_diff(index)=min(tlevel)
contour,jja_diff,alat,altitude,levels=tlevel,/cell_fill,c_color=col2,/noeras,xticks=6,color=0,yrange=[30,90],charsize=1.5,charthick=2,ytitle='Altitude (km)',xtitle='Latitude'
index=where(tlevel gt 0.)
contour,jja_diff,alat,altitude,levels=tlevel(index),/foll,c_color=0,/noeras,/overplot,c_labels=0*tlevel
index=where(tlevel lt 0.)
contour,jja_diff,alat,altitude,levels=tlevel(index),/foll,c_color=mcolor,c_linestyle=5,/noeras,/overplot,c_labels=0*tlevel

xmn=xorig(5)
xmx=xorig(5)+xlen
ymn=yorig(5)
ymx=yorig(5)+ylen
set_viewport,xmn,xmx,ymn,ymx
djf_diff=djf_markcoyz_waccm_alt-djf_markcoyz_mls_alt
index=where(djf_markcoyz_mls_alt eq 0. or finite(djf_markcoyz_mls_alt) eq 0)
if index(0) ne -1L then djf_diff(index)=0./0.
contour,djf_diff,alat,altitude,levels=tlevel,/cell_fill,c_color=col2,/noeras,xticks=6,color=0,yrange=[30,90],charsize=1.5,charthick=2,xtitle='Latitude'
index=where(tlevel gt 0.)
contour,djf_diff,alat,altitude,levels=tlevel(index),/foll,c_color=0,/noeras,/overplot,c_labels=0*tlevel
index=where(tlevel lt 0.)
contour,djf_diff,alat,altitude,levels=tlevel(index),/foll,c_color=mcolor,c_linestyle=5,/noeras,/overplot,c_labels=0*tlevel

level  = tlevel
nlvls  = n_elements(level)
slab=' '+strarr(n_elements(level))
!type=2^2+2^3+2^5+2^6
plot,[0,0],[0,0],xrange=[0,10],yrange=[0,1],/noeras,yticks=n_elements(level)-1L,$
      position = [.9,.1,.94,.35],ytickname=slab,/nodata
xyouts,.97,.1,'WACCM-MLS',/normal,orientation=90,color=0,charsize=1.5,charthick=2
xbox=[0,10,10,0,0]
y2=0
dy= 1./(n_elements(level))
for j=0,n_elements(col2)-1 do begin
    ybox=[y2,y2,y2+dy,y2+dy,y2]
    polyfill,xbox,ybox,color=col2[j]
    y2=y2+dy
endfor
loadct,0
slab=strcompress(string(format='(f4.1)',level),/remove_all)
slabcolor = fltarr(n_elements(level))*0.
slabcolor[0:4] = 255        ; set first few labels to white so they are visible
y1=dy/2 ; center of first color level
for i=0L,n_elements(slab)-1L do begin
    slab0=slab[i]
    xyouts,5,y1-dy/2.,slab0,charsize=1.3,/data,color=slabcolor[i],align = .5 ; This should place the label on the left side of each color level
    y1=y1+dy
endfor

;
; Close PostScript file and return control to X-windows
;
if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim figure_3_comarkbar.ps -rotate -90 figure_3_comarkbar.jpg'
;  spawn,'rm -f figure_3_comarkbar.ps'
endif

end
