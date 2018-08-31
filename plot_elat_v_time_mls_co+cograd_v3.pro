;
; plot daily mean CO and CO gradient vs Elat
; CO horizontal gradient - dCO/dx + dCO/dy
;
@calcelat2d

re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
nrr=91L
yeq=findgen(nrr)
latcircle=fltarr(nrr)
hem_frac=fltarr(nrr)
for j=0,nrr-2 do begin
    hy=re*dtr
    dx=re*cos(yeq(j)*dtr)*360.*dtr
    latcircle(j)=dx*hy
endfor
for j=0,nrr-1 do begin
    if yeq(j) ge 0. then index=where(yeq ge yeq(j))
    if index(0) ne -1 then hem_frac(j)=100.*total(latcircle(index))/hem_area
    if yeq(j) eq 0. then hem_frac(j)=100.
endfor

loadct,39
mcolor=byte(!p.color)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
yorig=[0.25]
xorig=[0.15]
cbaryoff=0.02
cbarydel=0.01
xlen=0.8
ylen=0.6
PI2=6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
!NOERAS=-1
syear=['2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014']
nyear=n_elements(syear)
smon=['01','02','03','04','05','06','07','08','09','10','11','12']
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
; get file listing
;
dir='/Volumes/atmos/aura6/data/MLS_data/Datfiles_Grid/MLS_grid5_ALL_v3.3_'

for iyear=0L,nyear-1L do begin
;
   rpress=1.
   spress=strcompress(rpress,/remove_all)+'hPa'
;
restore,'elat_v_time_mls_co+cograd_'+syear(iyear)+'_'+spress+'.sav'	;,ytco,ytdco,ytprod,ytcograd,ytcoedge,ytelatedge,yeq,sdate_all
print,'restored elat_v_time_mls_co+cograd_'+syear(iyear)+'_'+spress+'.sav'
;
; postscript file
;
    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       set_plot,'ps'
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/helvetica,filename='elat_v_time_mls_co+cograd_'+syear(iyear)+'_'+spress+'.ps'
       !p.charsize=1.25
       !p.thick=2
       !p.charthick=5
       !y.thick=2
       !x.thick=2
    endif
; 
; plot
;
if iyear eq 0 then begin
ytco_big=ytco
ytdco_big=ytdco
ytprod_big=ytprod
ytcograd_big=ytcograd
ytcoedge_big=ytcoedge
ytelatedge_big=ytelatedge
sdate_big=sdate_all
endif

if iyear gt 0 then begin
index=where(strmid(sdate_all,4,2) eq '01' or strmid(sdate_all,4,2) eq '02' or strmid(sdate_all,4,2) eq '03' or strmid(sdate_all,4,2) eq '04')
ytco_big=[ytco_old,ytco(index,*)]
ytdco_big=[ytdco_old,ytdco(index,*)]
ytprod_big=[ytprod_old,ytprod(index,*)]
ytcograd_big=[ytcograd_old,ytcograd(index,*)]
ytcoedge_big=[ytcoedge_old,ytcoedge(index)]
ytelatedge_big=[ytelatedge_old,ytelatedge(index)]
sdate_big=[sdate_old,sdate_all(index)]
endif
nfile=n_elements(sdate_big)
;
; smooth by 1 week
;
ytco_big=smooth(ytco_big,7,/edge_truncate,/Nan)
ytdco_big=smooth(ytdco_big,7,/edge_truncate,/Nan)
;
; x-axis labels
;
syr=strmid(sdate_big,0,4)
smn=strmid(sdate_big,4,2)
sdy=strmid(sdate_big,6,2)
xindex=where(sdy eq '15',nxticks)
xlabs=smn(xindex)

index=where(ytelatedge_big eq 0.)
if index(0) ne -1L then ytelatedge_big(index)=0./0.
;
; CO tendency (derivative in time)
;
dcodt=0.*ytco_big
nr=n_elements(yeq)
for j=0L,nr-1L do begin
    covals=reform(ytco_big(*,j))
    dcodt(*,j)=deriv(covals)
endfor
;
; compute edge here
;
elatedge=fltarr(nfile)
coedge=fltarr(nfile)
for i=0L,nfile-1L do begin
; 
; 2 ways to minimize intra-vortex gradient maxima: divide by CO value or multiply by cos(elat). Neither work
    dcoday=reform(ytdco_big(i,*))	;/reform(ytco_big(i,*))	;*cos(yeq*!pi/180.)
    coday=reform(ytco_big(i,*))
    index=where(dcoday eq max(dcoday))	; maximum in elat gradient
    elatedge(i)=yeq(index(0))
    coedge(i)=coday(index(0))
endfor
index=where(elatedge le 30.)
if index(0) ne -1L then elatedge(index)=0./0.

erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
!type=2^2+2^3
set_viewport,xmn,xmx,ymn,ymx
nlvls=26L
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
index=where(ytco_big lt 100.)
imin=min(ytco_big)
imax=max(ytco_big(index))
colevel=imin+((imax-imin)/float(nlvls-1))*findgen(nlvls)
contour,ytco_big,findgen(nfile),yeq,levels=colevel,xrange=[0,nfile],yrange=[20,90],/noeras,color=0,c_color=col1,title='Mean CO',ytitle='Equivalent Latitude',xticks=nxticks-1,xtickname=xlabs,xtickv=xindex,charsize=1.5,charthick=2
;oplot,findgen(nfile),elatedge,color=0,thick=3
oplot,findgen(nfile),smooth(elatedge,3,/edge_truncate,/Nan),color=0,thick=3
if iyear eq 0 then xyouts,1,30,syear(iyear),/data,charsize=2,charthick=2,color=0
if iyear gt 0 then xyouts,1,30,syear(iyear-1)+'-'+syear(iyear),/data,charsize=2,charthick=2,color=0
xyouts,0.4,0.9,spress,/normal,charsize=2,charthick=2,color=0
;
;xmn=xorig(1)
;xmx=xorig(1)+xlen
;ymn=yorig(1)
;ymx=yorig(1)+ylen
;!type=2^2+2^3
;set_viewport,xmn,xmx,ymn,ymx
;nlvls=26L
;col1=1+(indgen(nlvls)/float(nlvls))*mcolor
;index=where(ytdco_big ne 0. and finite(ytdco_big) eq 1 and ytdco_big lt 1)
;imin=min(ytdco_big(index))
;imax=max(ytdco_big(index))
;colevel=imin+((imax-imin)/float(nlvls-1))*findgen(nlvls)
;contour,ytdco_big,findgen(nfile),yeq,levels=colevel,xrange=[0,nfile],yrange=[20,90],/noeras,color=0,c_color=col1,title='dCO/dElat',ytitle='Equivalent Latitude',xticks=nxticks-1,xtickname=xlabs,xtickv=xindex,charsize=1.5,charthick=2
;oplot,findgen(nfile),smooth(elatedge,7,/edge_truncate,/Nan),thick=3,color=0
;
;xmn=xorig(2)
;xmx=xorig(2)+xlen
;ymn=yorig(2)
;ymx=yorig(2)+ylen
;!type=2^2+2^3
;set_viewport,xmn,xmx,ymn,ymx
;nlvls=26L
;col1=1+(indgen(nlvls)/float(nlvls))*mcolor
;index=where(ytcograd_big ne 0. and finite(ytcograd_big) eq 1)
;imin=min(ytcograd_big(index))
;imax=max(ytcograd_big(index))
;colevel=imin+((imax-imin)/float(nlvls-1))*findgen(nlvls)
;contour,ytcograd_big,findgen(nfile),yeq,levels=colevel,xrange=[0,nfile],yrange=[20,90],/noeras,color=0,c_color=col1,title='Elat Edge',ytitle='Equivalent Latitude',xticks=nxticks-1,xtickname=xlabs,xtickv=xindex,charsize=1.5,charthick=2,/nodata
;;oplot,findgen(nfile),ytelatedge_big,color=0,psym=8
;oplot,findgen(nfile),smooth(ytelatedge_big,7,/edge_truncate,/Nan),color=0.3*mcolor,thick=2
;oplot,findgen(nfile),smooth(elatedge,7,/edge_truncate,/Nan),thick=2,color=0
;
;xmn=xorig(3)
;xmx=xorig(3)+xlen
;ymn=yorig(3)
;ymx=yorig(3)+ylen
;!type=2^2+2^3
;set_viewport,xmn,xmx,ymn,ymx
;nlvls=26L
;col1=1+(indgen(nlvls)/float(nlvls))*mcolor
;index=where(ytprod_big ne 0. and finite(ytprod_big) eq 1 and ytprod_big lt 1.e8)
;imin=min(ytco_big(index))
;imax=max(ytco_big(index))
;colevel=imin+((imax-imin)/float(nlvls-1))*findgen(nlvls)
;plot,findgen(nfile),colevel,xrange=[0,nfile],yrange=[imin,imax],/noeras,color=0,title='CO Edge',ytitle='CO Concentration',xticks=nxticks-1,xtickname=xlabs,xtickv=xindex,charsize=1.5,charthick=2,/nodata
;ytcoedge_big=smooth(ytcoedge_big,7,/edge_truncate,/Nan)
;coedge=smooth(coedge,7,/edge_truncate,/Nan)
;oplot,findgen(nfile),ytcoedge_big,color=mcolor*.3,psym=8,symsize=0.5
;oplot,findgen(nfile),ytcoedge_big,color=mcolor*.3,thick=2
;oplot,findgen(nfile),coedge,color=0,psym=1
;oplot,findgen(nfile),coedge,color=0,thick=1
;
; retain November and December
;
smn=strmid(sdate_all,4,2)
index=where(smn eq '10' or smn eq '11' or smn eq '12')
ytco_old=ytco(index,*)
ytdco_old=ytdco(index,*)
ytprod_old=ytprod(index,*)
ytcograd_old=ytcograd(index,*)
ytcoedge_old=ytcoedge(index)
ytelatedge_old=ytelatedge(index)
sdate_old=sdate_all(index)
;
; Close PostScript file and return control to X-windows
;
     if iyear gt 0 and setplot ne 'ps' then stop
     if setplot eq 'ps' then begin
        device, /close
        spawn,'convert -trim elat_v_time_mls_co+cograd_'+syear(iyear)+'_'+spress+'.ps -rotate -90 '+$
                            'elat_v_time_mls_co+cograd_'+syear(iyear)+'_'+spress+'.jpg'
;       spawn,'rm -f elat_v_time_mls_co+cograd_'+syear(iyear)+'_'+spress+'.ps'
     endif
;
skipmon:
endfor	; loop over years
end
