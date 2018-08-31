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
dir='/atmos/harvey/WACCM_data/Datfiles/Datfiles_Ethan_600yr/CO2x1SmidEmax_yBWCN/3d_CO2x1SmidEmax_yBWCN_'
smonth=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
nmonth=n_elements(smonth)

restore,'smidemax_300-year_TUmark_djf_jja_sosst.sav'
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
; plot
;
if setplot eq 'ps' then begin
   lc=0
   !p.font=0
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
           /bold,/color,bits_per_pixel=8,/helvetica,filename='figure_1_tbar.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
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
nlvls=27
tlevel=[130+5*findgen(nlvls),280,300,320,350,400,450,500]
nlvls=n_elements(tlevel)
col1=(findgen(nlvls)/float(nlvls))*mcolor
contour,jja_tyz,alat,altitude,/noera,/cell_fill,color=0,c_color=col1,levels=tlevel,xrange=[-90,90],yrange=[30,105],ytitle='Altitude (km)',charsize=1.5,charthick=2,title='JJA',xticks=6
contour,jja_tyz,alat,altitude,/noera,/foll,color=0,levels=tlevel,/overplot,c_labels=0*tlevel

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,djf_tyz,alat,altitude,/noera,/cell_fill,color=0,c_color=col1,levels=tlevel,xrange=[-90,90],yrange=[30,105],charsize=1.5,charthick=2,title='DJF',xticks=6
contour,djf_tyz,alat,altitude,/noera,/foll,color=0,levels=tlevel,/overplot,c_labels=0*tlevel
waccm_latitude=alat
;
; SABER T
;
restore,'saber_14-year_TUmark_djf_jja_sosst.sav
;
; Nan 85-pole
;
O3B_DJF_Z(*,-2,*)=0./0.
O3B_JJA_Z(*,-2,*)=0./0.
O3_DJF_Z(*,-2,*)=0./0.
O3_JJA_Z(*,-2,*)=0./0.
P_DJF_Z(*,-2,*)=0./0.
P_JJA_Z(*,-2,*)=0./0.
T_DJF_Z(*,-2,*)=0./0.
T_JJA_Z(*,-2,*)=0./0.
U_DJF_Z(*,-2,*)=0./0.
U_JJA_Z(*,-2,*)=0./0.
V_DJF_Z(*,-2,*)=0./0.
V_JJA_Z(*,-2,*)=0./0.
;
; zonal mean
;
jjat=mean(t_jja_z,dim=1)
djft=mean(t_djf_z,dim=1)
;
; why isn't SABER binned in WACCM latitude grid?
;
saber_djf_t=fltarr(n_elements(waccm_latitude),nz)
saber_jja_t=fltarr(n_elements(waccm_latitude),nz)
for k=0L,nz-1L do begin
    tlev=reform(djft(*,k))
;   index=where(finite(tlev) eq 0)
;   if index(0) ne -1L then tlev(index)=0.
    saber_djf_t(*,k)=interpol(tlev,alat,waccm_latitude)
    tlev=reform(jjat(*,k))
;   index=where(finite(tlev) eq 0)
;   if index(0) ne -1L then tlev(index)=0.
    saber_jja_t(*,k)=interpol(tlev,alat,waccm_latitude)
endfor

lon=alon
lat=alat
nlon=n_elements(lon)
nlat=n_elements(lat)

!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,saber_jja_t,waccm_latitude,altitude,levels=tlevel,/cell_fill,c_color=col1,/noeras,xticks=6,ytitle='Altitude (km)',color=0,yrange=[30,105],charsize=1.5,charthick=2
contour,saber_jja_t,waccm_latitude,altitude,levels=tlevel,/foll,c_color=0,/noeras,/overplot,c_labels=0*tlevel

!type=2^2+2^3
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,saber_djf_t,waccm_latitude,altitude,levels=tlevel,/cell_fill,c_color=col1,/noeras,xticks=6,color=0,yrange=[30,105],charsize=1.5,charthick=2
contour,saber_djf_t,waccm_latitude,altitude,levels=tlevel,/foll,c_color=0,/noeras,/overplot,c_labels=0*tlevel

level  = tlevel
nlvls  = n_elements(level)
col1 = (1 + indgen(nlvls)) * 255. / nlvls    ; define colors
slab=' '+strarr(n_elements(level))
!type=2^2+2^3+2^5+2^6
plot,[0,0],[0,0],xrange=[0,10],yrange=[0,1],/noeras,yticks=n_elements(level)-1L,$
      position = [.9,.4,.94,.95],ytickname=slab,/nodata
xyouts,.97,.5,'Temperature (K)',/normal,orientation=90,color=0,charsize=1.5,charthick=2
xbox=[0,10,10,0,0]
y2=0
dy= 1./(n_elements(level)-1.)
for j=0,n_elements(col1)-2 do begin
    ybox=[y2,y2,y2+dy,y2+dy,y2]
    polyfill,xbox,ybox,color=col1[j]
    y2=y2+dy
endfor
loadct,0
slab=strcompress(string(format='(i3)',level),/remove_all)
slabcolor = fltarr(n_elements(level))*0.
slabcolor[0:8] = 255        ; set first few labels to white so they are visible
y1=dy/2 ; center of first color level
for i=0L,n_elements(slab)-2L do begin
    slab0=slab[i]
    if i mod 2 eq 0 then xyouts,5,y1-dy/2.,slab0,charsize=1.3,/data,color=slabcolor[i],align = .5 ; This should place the label on the left side of each color level
    y1=y1+dy
endfor
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

jja_diff=jja_tyz-saber_jja_t
index=where(saber_jja_t eq 0.)
if index(0) ne -1L then jja_diff(index)=0./0.
tlevel=-50+10*findgen(nlvls)
contour,jja_diff,waccm_latitude,altitude,levels=tlevel,/cell_fill,c_color=col2,/noeras,xticks=6,color=0,yrange=[30,105],charsize=1.5,charthick=2,ytitle='Altitude (km)',xtitle='Latitude'
index=where(tlevel gt 0.)
contour,jja_diff,waccm_latitude,altitude,levels=tlevel(index),/foll,c_color=0,/noeras,/overplot,c_labels=0*tlevel
index=where(tlevel lt 0.)
contour,jja_diff,waccm_latitude,altitude,levels=tlevel(index),/foll,c_color=mcolor,c_linestyle=5,/noeras,/overplot,c_labels=0*tlevel

xmn=xorig(5)
xmx=xorig(5)+xlen
ymn=yorig(5)
ymx=yorig(5)+ylen
set_viewport,xmn,xmx,ymn,ymx

djf_diff=djf_tyz-saber_djf_t
index=where(saber_djf_t eq 0.)
if index(0) ne -1L then djf_diff(index)=0./0.
tlevel=-50+10*findgen(nlvls)
contour,djf_diff,waccm_latitude,altitude,levels=tlevel,/cell_fill,c_color=col2,/noeras,xticks=6,color=0,yrange=[30,105],charsize=1.5,charthick=2,xtitle='Latitude'
index=where(tlevel gt 0.)
contour,djf_diff,waccm_latitude,altitude,levels=tlevel(index),/foll,c_color=0,/noeras,/overplot,c_labels=0*tlevel
index=where(tlevel lt 0.)
contour,djf_diff,waccm_latitude,altitude,levels=tlevel(index),/foll,c_color=mcolor,c_linestyle=5,/noeras,/overplot,c_labels=0*tlevel

level  = tlevel
nlvls  = n_elements(level)
slab=' '+strarr(n_elements(level))
!type=2^2+2^3+2^5+2^6
plot,[0,0],[0,0],xrange=[0,10],yrange=[0,1],/noeras,yticks=n_elements(level)-1L,$
      position = [.9,.1,.94,.35],ytickname=slab,/nodata
xyouts,.97,.1,'WACCM-SABER',/normal,orientation=90,color=0,charsize=1.5,charthick=2
xbox=[0,10,10,0,0]
y2=0
dy= 1./(n_elements(level))
for j=0,n_elements(col2)-1 do begin
    ybox=[y2,y2,y2+dy,y2+dy,y2]
    polyfill,xbox,ybox,color=col2[j]
    y2=y2+dy
endfor
loadct,0
slab=strcompress(string(format='(i3)',level),/remove_all)
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
   spawn,'convert -trim figure_1_tbar.ps -rotate -90 figure_1_tbar.jpg'
;  spawn,'rm -f figure_1_tbar.ps'
endif

end
