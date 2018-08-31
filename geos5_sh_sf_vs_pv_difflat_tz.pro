;
; 5-years of GEOS-5 data: daily time altitude plots of
; the mean latitude difference between min (max) SF (PV) 
; contours and max latitude in any of the bins
;
@stddat
@kgmt
@ckday
@kdate

loadct,39
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[0.15,0.15]
yorig=[0.60,0.20]
xlen=0.7
ylen=0.35
cbaryoff=0.06
cbarydel=0.01
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
nlvls=21
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
!noeras=1
if setplot eq 'ps' then begin
   set_plot,'ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
   xsize=nxdim/100.
   ysize=nydim/100.
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='geos5_sh_sf_vs_pv_difflat_tz.ps'
endif
;
; PVDIFF_ALL      FLOAT     = Array[1583, 26]
; SFDIFF_ALL      FLOAT     = Array[1583, 26]
;
restore,'geos5_sh_sf_pv_difflat_save_daily.sav
syr=strmid(sdates,0,4)
smn=strmid(sdates,4,2)
sdy=strmid(sdates,6,2)
xindex=where(smn eq '07' and sdy eq '01',nxticks)
kday=n_elements(sdates)

erase
xyouts,xorig(0)-0.06,yorig(0)+ylen+0.01,'SH',/normal,color=0,charsize=2
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=2.*findgen(nlvls)
contour,sfdiff_all,findgen(kday),th,xrange=[0.,kday],yrange=[300.,max(th)],c_color=col1,$
        title='Mean Lat in Vortex - Min Lat anywhere',ytitle='Theta (K)',/cell_fill,/noeras,$
        levels=level,min_value=-99.,color=0,xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex)+'/'+syr(xindex)
;contour,sfdiff_all,findgen(kday),th,/overplot,levels=level

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,pvdiff_all,findgen(kday),th,xrange=[0.,kday],yrange=[300.,max(th)],c_color=col1,$
        ytitle='Theta (K)',/cell_fill,/noeras,levels=level,min_value=-99.,color=0,$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex)+'/'+syr(xindex)
;contour,pvdiff_all,findgen(kday),th,/overplot,levels=level

imin=min(level)
imax=max(level)
ymnb=yorig(1)-cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='Latitude Difference (degrees)',charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim geos5_sh_sf_vs_pv_difflat_tz.ps -rotate -90 '+$
         'geos5_sh_sf_vs_pv_difflat_tz.jpg'
;  spawn,'/usr/bin/rm geos5_sh_sf_vs_pv_difflat_tz.ps'
endif
end
