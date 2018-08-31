;
; 10-year average
; save monthly vortex shape diagnostics
; MLS CO version
;
loadct,39
mcolor=byte(!p.color)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[.15,.55,.15,.55]
yorig=[.6,.6,.15,.15]
xlen=0.3
ylen=0.25
cbaryoff=0.05
cbarydel=0.01
device,decompose=0
mcolor=byte(!p.color)
nlvls=20L
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
PI2=6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
dum=2004+indgen(11)
syear=strcompress(dum,/remove_all)
nyear=n_elements(syear)
smon=['10','11','12','01','02','03']
nmon=n_elements(smon)
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
;
for iyear=0L,nyear-2L do begin
for imon=0L,nmon-1L do begin
    if smon(imon) gt 4 then begin
       restore,'vortex_shape_mlsco_'+syear(iyear)+smon(imon)+'.sav
       print,syear(iyear),smon(imon),nfile
    endif
    if smon(imon) lt 5 then begin
       restore,'vortex_shape_mlsco_'+syear(iyear+1)+smon(imon)+'.sav
       print,syear(iyear+1),smon(imon),nfile
    endif

; pmls
; AREA1           FLOAT     = Array[31, 30]
; CENTROID_LATITUDE1 FLOAT     = Array[31, 30]
; CENTROID_LONGITUDE1 FLOAT     = Array[31, 30]
; ELLIPTICITY1    FLOAT     = Array[31, 30]
; NFILE           LONG      =           31
; NTH             LONG      =           30
; NUMBER_VORTEX_LOBES1 FLOAT     = Array[31, 30]
; SDATE_ALL       STRING    = Array[31]
; TH              FLOAT     = Array[30]

if imon eq 0L then begin
;  ALTITUDE_tot=ALTITUDE
   AREA1_tot=AREA1	
   clat_tot=CENTROID_LATITUDE1
   clon_tot=CENTROID_LONGITUDE1
   ellip_tot=ELLIPTICITY1
   nvort_tot=NUMBER_VORTEX_LOBES1
   sdate_tot=SDATE_ALL
endif
if imon gt 0L then begin
;  ALTITUDE_tot=[ALTITUDE_tot,ALTITUDE]
   AREA1_tot=[AREA1_tot,AREA1]
   clat_tot=[clat_tot,CENTROID_LATITUDE1]
   clon_tot=[clon_tot,CENTROID_LONGITUDE1]
   ellip_tot=[ellip_tot,ELLIPTICITY1]
   nvort_tot=[nvort_tot,NUMBER_VORTEX_LOBES1]
   sdate_tot=[sdate_tot,SDATE_ALL]
endif
;help,imon,sdate_tot

skipmon:
endfor	; loop over months
if iyear eq 0L then begin
   nl=n_elements(pmls)
   nday=182L
   area_10yr=fltarr(nday,nl)
   narea_10yr=fltarr(nday,nl)
   clat_10yr=fltarr(nday,nl)
   nclat_10yr=fltarr(nday,nl)
   clon_10yr=fltarr(nday,nl)
   nclon_10yr=fltarr(nday,nl)
   ellip_10yr=fltarr(nday,nl)
   nellip_10yr=fltarr(nday,nl)
   nvort_10yr=fltarr(nday,nl)
   numvort_10yr=fltarr(nday,nl)
endif
;
; arrays are different sizes each season due to missing days. Set to 181 days then "fill" in based on missing days.
; should be doy 274 to doy 91
;
nday=n_elements(sdate_tot)
doy=fltarr(nday)
for i=0L,nday-1L do begin
    idy=long(strmid(sdate_tot(i),6,2))
    imn=long(strmid(sdate_tot(i),4,2))
    iyr=long(strmid(sdate_tot(i),0,4))
    z = kgmt(imn,idy,iyr,iday)
    doy(i)=iday
endfor

leapday=0L
if long(strmid(sdate_tot(0),0,4)) mod 4 eq 0L then leapday=1L
tmp=doy-doy(0)
index=where(tmp lt 0.)
tmp(index)=index+1.	; tmp is array of indices

for i=0L,nday-1L do begin

prof=reform(AREA1_tot(i,*))
index=where(prof ne -99 and prof ne 0.)
if index(0) ne -1L then area_10yr(tmp(i),index)=area_10yr(tmp(i),index)+prof(index)
if index(0) ne -1L then narea_10yr(tmp(i),index)=narea_10yr(tmp(i),index)+1.

prof=reform(clat_tot(i,*))
index=where(prof ne -99. and prof ne 0.)
if index(0) ne -1L then clat_10yr(tmp(i),index)=clat_10yr(tmp(i),index)+prof(index)
if index(0) ne -1L then nclat_10yr(tmp(i),index)=nclat_10yr(tmp(i),index)+1.

prof=reform(clon_tot(i,*))
index=where(prof ne -99. and prof ne 0.)
if index(0) ne -1L then clon_10yr(tmp(i),index)=clon_10yr(tmp(i),index)+prof(index)
if index(0) ne -1L then nclon_10yr(tmp(i),index)=nclon_10yr(tmp(i),index)+1.

prof=reform(ellip_tot(i,*))
index=where(prof ne -99. and prof ne 0.)
if index(0) ne -1L then ellip_10yr(tmp(i),index)=ellip_10yr(tmp(i),index)+prof(index)
if index(0) ne -1L then nellip_10yr(tmp(i),index)=nellip_10yr(tmp(i),index)+1.

prof=reform(nvort_tot(i,*))
index=where(prof ne -99. and prof ne 0.)
if index(0) ne -1L then nvort_10yr(tmp(i),index)=nvort_10yr(tmp(i),index)+prof(index)
if index(0) ne -1L then numvort_10yr(tmp(i),index)=numvort_10yr(tmp(i),index)+1.

endfor

help,area1_10yr,area1_tot,tmp
print,tmp
;stop
;
; plot year of area, y0, x0, ellip, nvort
;
syr=strmid(sdate_tot,0,4)
smonth=strmid(sdate_tot,4,2)
sday=strmid(sdate_tot,6,2)
yearlab=syr(0)+'-'+syr(-1)
xindex=where(sday eq '15',nxticks)
xticklab=smonth(xindex)
nfile=n_elements(sdate_tot)
;nxticks=nxticks

endfor	; loop over years
;
; plot 10yr average
;
index=where(narea_10yr gt 0.)
if index(0) ne -1L then area_10yr(index)=area_10yr(index)/narea_10yr(index)

index=where(nclat_10yr gt 0.)
if index(0) ne -1L then clat_10yr(index)=clat_10yr(index)/nclat_10yr(index)

index=where(nclon_10yr gt 0.)
if index(0) ne -1L then clon_10yr(index)=clon_10yr(index)/nclon_10yr(index)

index=where(nellip_10yr gt 0.)
if index(0) ne -1L then ellip_10yr(index)=ellip_10yr(index)/nellip_10yr(index)

index=where(numvort_10yr gt 0.)
if index(0) ne -1L then nvort_10yr(index)=nvort_10yr(index)/numvort_10yr(index)

if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='zt_vortex_shape_mlsco_10yr.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif

nfile=182L
erase
xyouts,.325,.875,'MLS 2004-2014',/normal,charsize=2,charthick=2,color=0
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=2.+2.*findgen(15)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,area_10yr,findgen(nfile),pmls,levels=level,/noeras,c_color=col1,/cell_fill,color=0,xticks=nxticks-1,xtickv=xindex,xtickname=xticklab,ytitle='Pressure (hPa)',yrange=[10,0.01],/ylog,charsize=1.5,charthick=2
contour,smooth(area_10yr,3,/edge_truncate,/Nan),findgen(nfile),pmls,levels=[15],/noeras,color=0,/foll,/overplot,thick=3,c_labels=[0]
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='Vortex Area (%)',/noeras,charsize=1.5,charthick=2
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for jj=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(jj)
x1=x1+dx
endfor

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=40+2.5*findgen(21)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,clat_10yr,findgen(nfile),pmls,levels=level,/noeras,c_color=col1,/cell_fill,color=0,xticks=nxticks-1,xtickv=xindex,xtickname=xticklab,yrange=[10,0.01],/ylog,charsize=1.5,charthick=2
contour,smooth(clat_10yr,3,/edge_truncate,/Nan),findgen(nfile),pmls,levels=[80],/noeras,color=0,/foll,/overplot,thick=3,c_labels=[0]
imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='Centroid Latitude',/noeras,charsize=1.5,charthick=2
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for jj=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(jj)
x1=x1+dx
endfor

!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=0.05*findgen(16)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,ellip_10yr,findgen(nfile),pmls,levels=level,/noeras,c_color=col1,/cell_fill,color=0,xticks=nxticks-1,xtickv=xindex,xtickname=xticklab,yrange=[10,0.01],ytitle='Pressure (hPa)',/ylog,charsize=1.5,charthick=2
contour,smooth(ellip_10yr,3,/edge_truncate,/Nan),findgen(nfile),pmls,levels=[0.55],/noeras,color=0,/foll,/overplot,thick=3	;,c_labels=[0]
imin=min(level)
imax=max(level)
ymnb=yorig(2) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='Vortex Ellipticity',/noeras,charsize=1.5,charthick=2
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for jj=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(jj)
x1=x1+dx
endfor

!type=2^2+2^3
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=1.+0.2*findgen(11)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,nvort_10yr,findgen(nfile),pmls,levels=level,/noeras,c_color=col1,/cell_fill,color=0,xticks=nxticks-1,xtickv=xindex,xtickname=xticklab,yrange=[10,0.01],/nodata,/ylog,charsize=1.5,charthick=2
nth=n_elements(pmls)
x2d=fltarr(nfile,nth)
y2d=fltarr(nfile,nth)
for k=0L,nth-1L do x2d(*,k)=findgen(nfile)
for i=0L,nfile-1L do y2d(i,*)=pmls
index=where(nvort_tot eq 1.)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=0,symsize=2
index=where(nvort_tot eq 2.)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=mcolor*.4
index=where(nvort_tot gt 2.)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=mcolor*.9

;contour,nvort_tot,findgen(nfile),pmls,levels=level,/noeras,color=0,/foll
imin=min(level)
imax=max(level)
ymnb=yorig(3) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='# Vortex Lobes',/noeras,charsize=1.5,charthick=2
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for jj=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(jj)
x1=x1+dx
endfor

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim zt_vortex_shape_mlsco_10yr.ps -rotate -90 zt_vortex_shape_mlsco_10yr.jpg'
    endif


end
