;
; Figure 3 for PV elat paper
; NH + SH version (SF and PV are reversed in vortex)
;
; 4-year monthly means
; plot an altitude profile of the mean latitude difference
; between min (max) SF (PV) contours and max latitude in
; any of the bins
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
xorig=[0.125,0.525]
yorig=[0.2,0.2]
xlen=0.36
ylen=0.6
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
month=['Apr','May','Jun','Jul','Aug','Sep']
stimes=['04','05','06','07','08','09']
ntimes=n_elements(stimes)
xinc=xlen/float(ntimes)
col1=31+(indgen(ntimes)/float(ntimes))*mcolor
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
          /bold,/color,bits_per_pixel=8,/helvetica,filename='figure_3_new.ps'
endif
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
;restore,'geos5_sh_sf_pv_difflat_save_daily.sav
restore,'geos5_sh_sf_pv_diffwlat_save_daily.sav

for itime=0L,ntimes-1L do begin
    syr=strmid(sdates,0,4)
    smn=strmid(sdates,4,2)
    sdy=strmid(sdates,6,2)
    index=where(smn eq stimes(itime),nday)
    sfdiff=reform(SFDIFF_ALL(index,*))
    pvdiff=reform(PVDIFF_ALL(index,*))
    sfdiffmean=0.*th
    pvdiffmean=0.*th
;
; PVDIFF_ALL      FLOAT     = Array[1583, 26]
; SFDIFF_ALL      FLOAT     = Array[1583, 26]
;
    for k=0L,n_elements(th)-1L do begin
        index=where(sfdiff(*,k) ne -99.,npts)
        if index(0) ne -1L then $
           sfdiffmean(k)=sfdiffmean(k)+total(sfdiff(index,k))/float(npts)
        index=where(pvdiff(*,k) ne -99.,npts)
        if index(0) ne -1L then $
           pvdiffmean(k)=pvdiffmean(k)+total(pvdiff(index,k))/float(npts) 
    endfor
    if itime eq 0L then begin
       ytickval=[500,1000,2000,3000,4000,4600]
       ytickn=['500','1000','2000','3000','4000','4600']
       plot,sfdiffmean,th,xrange=[0.,30.],yrange=[500.,max(th)],color=0,$
            xtitle='!4D !XLatitude',ytitle='Theta (K)',/nodata,yticks=n_elements(ytickval)-1,$
            ytickv=ytickval,ytickname=ytickn
    endif
    oplot,sfdiffmean,th,thick=10,color=col1(itime)
    oplot,pvdiffmean,th,thick=10,color=col1(itime),linestyle=5
    xyouts,0.01+xorig(0)+xinc*float(itime),.82,month(itime),color=col1(itime),/normal,alignment=0
endfor	; loop over months
xyouts,25.,700.,'SH',color=0,/data,charsize=2
;
; NH
;
month=['Oct','Nov','Dec','Jan','Feb','Mar']
stimes=['10','11','12','01','02','03']
ntimes=n_elements(stimes)
xinc=xlen/float(ntimes)

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
;restore,'geos5_nh_sf_pv_difflat_save_daily.sav
restore,'geos5_nh_sf_pv_diffwlat_save_daily.sav

for itime=0L,ntimes-1L do begin
    syr=strmid(sdates,0,4)
    smn=strmid(sdates,4,2)
    sdy=strmid(sdates,6,2)
    index=where(smn eq stimes(itime),nday)
    sfdiff=reform(SFDIFF_ALL(index,*))
    pvdiff=reform(PVDIFF_ALL(index,*))
    sfdiffmean=0.*th
    pvdiffmean=0.*th
;
; PVDIFF_ALL      FLOAT     = Array[1583, 26]
; SFDIFF_ALL      FLOAT     = Array[1583, 26]
;
    for k=0L,n_elements(th)-1L do begin
        index=where(sfdiff(*,k) ne -99.,npts)
        if index(0) ne -1L then $
           sfdiffmean(k)=sfdiffmean(k)+total(sfdiff(index,k))/float(npts)
        index=where(pvdiff(*,k) ne -99.,npts)
        if index(0) ne -1L then $
           pvdiffmean(k)=pvdiffmean(k)+total(pvdiff(index,k))/float(npts)
    endfor
    if itime eq 0L then begin
       plot,sfdiffmean,th,xrange=[0.,30.],yrange=[500.,max(th)],color=0,$
            xtitle='!4D !XLatitude',/nodata,ytitle=' ',$
            ytickname=[' ',' ',' ',' ',' ']
    endif
    oplot,sfdiffmean,th,thick=10,color=col1(itime)
    oplot,pvdiffmean,th,thick=10,color=col1(itime),linestyle=5
    xyouts,0.01+xorig(1)+xinc*float(itime),.82,month(itime),color=col1(itime),/normal,alignment=0
endfor  ; loop over months
xyouts,25.,700.,'NH',color=0,/data,charsize=2
xyouts,xmx+0.075,ymn+0.13,'Approximate Altitude (km)',color=0,/normal,orientation=90.
xyouts,xmx+0.01,ymn+0.00,'20',color=0,/normal
xyouts,xmx+0.01,ymn+0.07,'30',color=0,/normal
xyouts,xmx+0.01,ymn+0.21,'50',color=0,/normal
xyouts,xmx+0.01,ymn+0.36,'60',color=0,/normal
xyouts,xmx+0.01,ymx-0.09,'70',color=0,/normal

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim figure_3_new.ps -rotate -90 figure_3_new.jpg'
;  spawn,'/usr/bin/rm figure_3_new.ps'
endif
end
