;
; plot yearly timeseries of MLS Tbar and H2Obar at a given latitude and altitude
; data is plotted wrt SH DFS -40 to DFS +80
;
@stddat
@kgmt
@ckday
@kdate

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
restore,'c11.tbl'
tvlct,c1,c2,c3
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='ps'
read,'setplot=',setplot
nxdim=700
nydim=700
xorig=[0.2,0.2,0.2]
yorig=[0.75,0.45,0.15]
xlen=0.6
ylen=0.2
cbaryoff=0.1
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
ofile='/atmos/aura6/data/MLS_data/Datfiles_Grid/mls_Ubar_Tbar_H2Obar_3D.sav'
restore,ofile
kday=n_elements(sdate)
nr=n_elements(wlat)
nl=n_elements(p)
;
; truncate to only plot AIM time (2007 onward)
;
index=where(sdate gt 20070501L)
sdate=sdate(index)
tbar=reform(tbar(*,*,index))
ubar=reform(ubar(*,*,index))
h2obar=reform(h2obar(*,*,index))
;
; remove negatives from water
;
bad=where(finite(h2obar) eq 0L or h2obar lt 0.)
if bad(0) ne -1L then h2obar(bad)=0./0.
;
; compute DFS relative to SH for all dates
;
nn=n_elements(sdate)
fdoy=fltarr(nn)
dfs=fltarr(nn)
for i=0L,nn-1L do begin
    iyr=long(strmid(sdate(i),0,4))
    imn=long(strmid(sdate(i),4,2))
    idy=long(strmid(sdate(i),6,2))
    z = kgmt(imn,idy,iyr,iday)
    fdoy(i)=1.0*iday
    dfs(i)=fdoy(i)-355.
endfor
;
; approx altitude
;
altitude=7.*alog(1000./p)
;
; choose latitude and altitude and extract from TBAR and UBAR
;
nlat=17
rlats=-80+10.*findgen(nlat)
;print,alat
;;read,'Enter latitude ',rlat
;index=where(abs(rlat-alat) eq min(abs(rlat-alat)))
;ilat=index(0)
;index=where(abs(rlat-wlat) eq min(abs(rlat-wlat)))
;iwlat=index(0)
;slat=strcompress(rlat,/remove_all)
;
zindex=where(p le 10. and p ge 0.00100000,nlev)
;ralt=0.001
;print,p
;;read,'Enter pressure ',ralt
;index=where(abs(ralt-p) eq min(abs(ralt-p)))
;ilev=index(0)
;slev=strcompress(ralt,/remove_all)
;
; loop over latitudes and altitudes
;
for ilat=0L,nlat-1L do begin
yindex=where(abs(rlats(ilat)-alat) eq min(abs(rlats(ilat)-alat)))
ilat0=yindex(0)
rlat=rlats(ilat)
slat=strcompress(rlat,/remove_all)

for ilev=0L,nlev-1L do begin
ilev0=zindex(ilev)
ralt=p(ilev0)
slev=strcompress(string(format='(f7.3)',ralt),/remove_all)
salt=string(format='(f4.1)',altitude(ilev0))

print,alat(ilat0),p(ilev0),altitude(ilev0)

tdata=reform(tbar(ilat0,ilev0,*))
udata=reform(ubar(ilat0,ilev0,*))
h2odata=reform(h2obar(ilat0,ilev0,*))*1.e6
;
; Nan bad data
;
index=where(tdata le 0.0)
if index(0) ne -1L then tdata(index)=0./0.
if index(0) ne -1L then udata(index)=0./0.

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/times,filename='mls_tbar_h2obar_yearly_timeseries_SHPMC_'+slat+'_'+slev+'_cips.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif

dfsindex=where(dfs eq -40.,nseason)
nlvls=nseason
col1=[0,150,1,3,5,6,9,11]

erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,-40.+findgen(121),findgen(121),/nodata,xrange=[-40.,80.],yrange=[0.,100.],/noeras,charsize=2,charthick=2,color=0,ytitle='PMC Frequency',title='80S'
for iseason=0L,nseason-1L do begin
    restore,'/Volumes/Data/CIPS_data/Pre_process/Line_plots/F_V4.20_80Lat_2G_SH'+strmid(sdate(dfsindex(iseason)),2,2)+'.sav'    ;,ddd,freq
    freq30=smooth(freq,31,/edge_truncate)
    dum=freq    ;-freq30
    oplot,ddd,dum,color=col1(iseason),thick=5
endfor

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
tmax=150.
tmin=300.
for iseason=0L,nseason-1L do begin
    if dfsindex(iseason)+121L lt n_elements(sdate) then tdatayear=reform(tdata(dfsindex(iseason):dfsindex(iseason)+121L))
    if dfsindex(iseason)+121L ge n_elements(sdate) then tdatayear=reform(tdata(dfsindex(iseason):n_elements(sdate)-1L))
    index=where(finite(tdatayear) eq 1L)
    if max(tdatayear(index)) gt tmax then tmax=max(tdatayear(index))
    if min(tdatayear(index)) lt tmin then tmin=min(tdatayear(index))
print,min(tdatayear)
endfor
print,'Tmin ',tmin,tmax

plot,-40.+findgen(121),findgen(121),/nodata,xrange=[-40.,80.],yrange=[tmin,tmax],/noeras,charsize=2,charthick=2,color=0,ytitle='MLS T (K)',title=slat+' '+slev+' hPa ('+salt+' km)',xtitle='DFS (21 Dec)'
dfsindex=where(dfs eq -40.,nseason)
yearmin=long(strmid(sdate(dfsindex(0)),0,4))
yearmax=long(strmid(sdate(dfsindex(nseason-1)),0,4))
for iseason=0L,nseason-1L do begin
    if dfsindex(iseason)+121L lt n_elements(sdate) then dfsyear=reform(dfs(dfsindex(iseason):dfsindex(iseason)+121L))
    if dfsindex(iseason)+121L lt n_elements(sdate) then tdatayear=reform(tdata(dfsindex(iseason):dfsindex(iseason)+121L))
    if dfsindex(iseason)+121L ge n_elements(sdate) then dfsyear=reform(dfs(dfsindex(iseason):n_elements(sdate)-1L))
    if dfsindex(iseason)+121L ge n_elements(sdate) then tdatayear=reform(tdata(dfsindex(iseason):n_elements(sdate)-1L))
    dum=dfsyear
    maxday=max(dum)
    index=where(dum lt dum(0))
    dum(index)=maxday+1+findgen(n_elements(index))
    dfsyear=dum
    index=where(finite(tdatayear) eq 1L)
    oplot,dfsyear(index),smooth(tdatayear(index),7,/edge_truncate),color=col1(iseason),thick=5
endfor
;
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
umax=0.
umin=100.
for iseason=0L,nseason-1L do begin
    if dfsindex(iseason)+121L lt n_elements(sdate) then h2odatayear=reform(h2odata(dfsindex(iseason):dfsindex(iseason)+121L))
    if dfsindex(iseason)+121L ge n_elements(sdate) then h2odatayear=reform(h2odata(dfsindex(iseason):n_elements(sdate)-1L))
    index=where(finite(h2odatayear) eq 1L)
    if max(h2odatayear(index)) gt umax then umax=max(h2odatayear(index))
    if min(h2odatayear(index)) lt umin then umin=min(h2odatayear(index))
endfor
print,'H2omin ',umin,umax

plot,-40.+findgen(121),findgen(121),/nodata,xrange=[-40.,80.],yrange=[umin,umax],/noeras,charsize=2,charthick=2,color=0,ytitle='MLS H2O (ppmv)'
for iseason=0L,nseason-1L do begin
    if dfsindex(iseason)+121L lt n_elements(sdate) then dfsyear=reform(dfs(dfsindex(iseason):dfsindex(iseason)+121L))
    if dfsindex(iseason)+121L lt n_elements(sdate) then h2odatayear=reform(h2odata(dfsindex(iseason):dfsindex(iseason)+121L))
    if dfsindex(iseason)+121L ge n_elements(sdate) then dfsyear=reform(dfs(dfsindex(iseason):n_elements(sdate)-1L))
    if dfsindex(iseason)+121L ge n_elements(sdate) then h2odatayear=reform(h2odata(dfsindex(iseason):n_elements(sdate)-1L))
    dum=dfsyear
    maxday=max(dum) 
    index=where(dum lt dum(0))
    dum(index)=maxday+1+findgen(n_elements(index))
    dfsyear=dum
    index=where(finite(h2odatayear) eq 1L)
    if index(0) ne -1 then oplot,dfsyear(index),smooth(h2odatayear(index),7,/edge_truncate),color=col1(iseason),thick=5
endfor
;
nlvls=nseason
col1=[0,150,1,3,5,6,9,11]
imin=yearmin
imax=yearmax
ymnb=yorig(2) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,charsize=1.5,charthick=2
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nseason)
for j=0,nseason-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim mls_tbar_h2obar_yearly_timeseries_SHPMC_'+slat+'_'+slev+'_cips.ps -rotate -90 mls_tbar_h2obar_yearly_timeseries_SHPMC_'+slat+'_'+slev+'_cips.jpg'
endif

endfor	; loop over levels
endfor	; loop over latitudes

end
