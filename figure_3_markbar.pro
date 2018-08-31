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
xorig=[0.15,0.55]
yorig=[0.4,0.4]
xlen=0.325
ylen=0.325
cbaryoff=0.1
cbarydel=0.01
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/atmos/harvey/WACCM_data/Datfiles/Datfiles_Ethan_600yr/CO2x1SmidEmax_yBWCN/3d_CO2x1SmidEmax_yBWCN_'
smonth=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
nmonth=n_elements(smonth)

restore,'smidemax_300-year_TUmark_djf_jja_sosst.sav'
index=where(finite(mark_jja_z) eq 1)
index2=where(mark_jja_z(index) lt -1.)
if index2(0) ne -1L then mark_jja_z(index(index2))=-1.
index=where(finite(mark_djf_z) eq 1)
index2=where(mark_djf_z(index) lt -1.)
if index2(0) ne -1L then mark_djf_z(index(index2))=-1.
;
; calculate zonal means
;
djf_tyz=mean(T_DJF_Z,dim=1)
djf_uyz=mean(U_DJF_Z,dim=1)
djf_markyz=mean(MARK_DJF_Z,dim=1)
jja_tyz=mean(T_JJA_Z,dim=1)
jja_uyz=mean(U_JJA_Z,dim=1)
jja_markyz=mean(MARK_JJA_Z,dim=1)
;
; stratopause and mesopause heights
;
djf_strat=0.*alat
jja_strat=0.*alat
djf_meso=0.*alat
jja_meso=0.*alat
for j=0L,n_elements(alat)-1L do begin
    tprof=reform(jja_tyz(j,*))
    index=where(altitude ge 40 and finite(tprof) eq 1)
    tprof=tprof(index)
    zprof=altitude(index)
    index=where(tprof eq min(tprof))
    jja_meso(j)=zprof(index(0))
    index=where(zprof lt 80.)
    tprof0=tprof(index)
    zprof0=zprof(index)
    index=where(tprof0 eq max(tprof0))
    jja_strat(j)=zprof0(index(0))

    tprof=reform(djf_tyz(j,*))
    index=where(altitude ge 40 and finite(tprof) eq 1)
    tprof=tprof(index)
    zprof=altitude(index)
    index=where(tprof eq min(tprof))
    djf_meso(j)=zprof(index(0))
    index=where(zprof lt 80.)
    tprof0=tprof(index)
    zprof0=zprof(index)
    index=where(tprof0 eq max(tprof0))
    djf_strat(j)=zprof0(index(0))
endfor
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
           /bold,/color,bits_per_pixel=8,/helvetica,filename='figure_3_markbar.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
restore,'c11_rb.tbl'
tvlct,c1,c2,c3
col2=1+indgen(11)
nlvls=n_elements(col2)
;
; DJF
;
x2d=0.*djf_tyz
z2d=0.*djf_tyz
for k=0L,nz-1L do x2d(*,k)=alat
for j=0L,nr-1L do z2d(j,*)=altitude
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
tlevel=-1+0.2*findgen(nlvls)
contour,jja_markyz,alat,altitude,/noera,/cell_fill,color=0,c_color=col2,levels=tlevel,xrange=[-90,90],yrange=[30,125],ytitle='Altitude (km)',charsize=1.5,charthick=2,title='JJA',xticks=6,xtitle='Latitude'
index=where(tlevel gt 0.)
contour,jja_markyz,alat,altitude,/noera,/foll,color=0,levels=tlevel(index),/overplot,c_labels=0*tlevel
index=where(tlevel lt 0.)
contour,jja_markyz,alat,altitude,/noera,/foll,color=mcolor,c_linestyle=5,levels=tlevel(index),/overplot,c_labels=0*tlevel
;loadct,0
oplot,alat,smooth(jja_meso,3,/edge_truncate),thick=15,color=200
oplot,alat,smooth(jja_strat,3,/edge_truncate),thick=15,color=0

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,djf_markyz,alat,altitude,/noera,/cell_fill,color=0,c_color=col2,levels=tlevel,xrange=[-90,90],yrange=[30,125],charsize=1.5,charthick=2,title='DJF',xticks=6,xtitle='Latitude'
index=where(tlevel gt 0.)
contour,djf_markyz,alat,altitude,/noera,/foll,color=0,levels=tlevel(index),/overplot,c_labels=0*tlevel
index=where(tlevel lt 0.)
contour,djf_markyz,alat,altitude,/noera,/foll,color=mcolor,c_linestyle=5,levels=tlevel(index),/overplot,c_labels=0*tlevel
waccm_latitude=alat
oplot,alat,smooth(djf_meso,3,/edge_truncate),thick=15,color=200
oplot,alat,smooth(djf_strat,3,/edge_truncate),thick=15,color=0
;

level  = tlevel
nlvls  = n_elements(level)
slab=' '+strarr(n_elements(level))
!type=2^2+2^3+2^5+2^6
plot,[0,0],[0,0],xrange=[0,10],yrange=[0,1],/noeras,yticks=n_elements(level)-1L,$
      position = [.9,.4,.95,.725],ytickname=slab,/nodata
xyouts,.98,.4,'Anticyclone        Cyclone',/normal,orientation=90,color=0,charsize=1.25,charthick=2
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
   spawn,'convert -trim figure_3_markbar.ps -rotate -90 figure_3_markbar.jpg'
;  spawn,'rm -f figure_3_markbar.ps'
endif

end
