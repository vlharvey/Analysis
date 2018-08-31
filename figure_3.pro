;
; PV elat breakdown figure 3. 4-year average annual cycles
; of latitude difference between max/min PV and SF and poleward
; most PV and SF.  NH and SH. 4 panel.
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
xorig=[0.125,0.125,0.525,0.525]
yorig=[0.6,0.15,0.6,0.15]
xlen=0.375
ylen=0.35
cbaryoff=0.05
cbarydel=0.01
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
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
          /bold,/color,bits_per_pixel=8,/helvetica,filename='figure_3.ps'
endif
;
; PVDIFF_ALL      FLOAT     = Array[1583, 26]
; SFDIFF_ALL      FLOAT     = Array[1583, 26]
;
restore,'geos5_sh_sf_pv_difflat_save_daily.sav
syr=strmid(sdates,0,4)
smn=strmid(sdates,4,2)
sdy=strmid(sdates,6,2)
iyr0=min(long(syr))
iyr1=max(long(syr))
erase
for ii=iyr0,iyr1-1 do begin
;
; extract winter season
;
syr=strmid(sdates,0,4)
smn=strmid(sdates,4,2)
sdy=strmid(sdates,6,2)
index=where( (syr eq strcompress(ii,/remove_all) and smn eq '04') or $
             (syr eq strcompress(ii,/remove_all) and smn eq '05') or $
             (syr eq strcompress(ii,/remove_all) and smn eq '06') or $
             (syr eq strcompress(ii,/remove_all) and smn eq '07') or $
             (syr eq strcompress(ii,/remove_all) and smn eq '08') or $
             (syr eq strcompress(ii,/remove_all) and smn eq '09') )
sdate=sdates(index)
kday=n_elements(sdate)
syr=strmid(sdate,0,4)
smn=strmid(sdate,4,2)
sdy=strmid(sdate,6,2)
pvdiff=reform(pvdiff_all(index,*))
sfdiff=reform(sfdiff_all(index,*))
if ii eq 2004L then begin
   pvdiff_avg=0.*pvdiff
   npvdiff_avg=0L*pvdiff
   sfdiff_avg=0.*sfdiff
   nsfdiff_avg=0L*sfdiff
endif
index=where(pvdiff ne -99.)
pvdiff_avg(index)=pvdiff_avg(index)+pvdiff(index)
npvdiff_avg(index)=npvdiff_avg(index)+1L
index=where(sfdiff ne -99.)
sfdiff_avg(index)=sfdiff_avg(index)+sfdiff(index)
nsfdiff_avg(index)=nsfdiff_avg(index)+1L

endfor	; loop over years
index=where(npvdiff_avg gt 0L)
if index(0) ne -1L then pvdiff_avg(index)=pvdiff_avg(index)/npvdiff_avg(index)
index=where(nsfdiff_avg gt 0L)
if index(0) ne -1L then sfdiff_avg(index)=sfdiff_avg(index)/nsfdiff_avg(index)

xindex=where(sdy eq '15',nxticks)
syr0=strcompress(min(long(syr)),/remove_all)
syr1=strcompress(max(long(syr)),/remove_all)

!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=[1.,2.,3.,4.,5.,10.,15.,20.,25.,30.]
nlvls2=n_elements(level)
col2=1+(indgen(nlvls2)/float(nlvls2))*mcolor
index=where(sfdiff_avg eq 0.)
if index(0) ne -1L then sfdiff_avg(index)=0./0.
sfdiff_avg=smooth(sfdiff_avg,3,/NaN,/edge_truncate)
sfdiff_avg(index)=0.
contour,sfdiff_avg,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),max(th)],c_color=col2,$
        ytitle='Theta (K)',/cell_fill,/noeras,levels=level,min_value=-99.,color=0,$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),title='SH (!4W!1  based)'
contour,sfdiff_avg,findgen(kday),th,/follow,levels=[10.],color=0,thick=5,/overplot,c_labels=[0]
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
index=where(pvdiff_avg eq 0.)
if index(0) ne -1L then pvdiff_avg(index)=0./0.
pvdiff_avg=smooth(pvdiff_avg,3,/NaN,/edge_truncate)
pvdiff_avg(index)=0.
contour,pvdiff_avg,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),max(th)],c_color=col2,$
        ytitle='Theta (K)',/cell_fill,/noeras,levels=level,min_value=-99.,color=0,$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),title='SH (PV based)'
contour,pvdiff_avg,findgen(kday),th,/follow,levels=[10.],color=0,thick=5,/overplot,c_labels=[0]
;
; NH
;
restore,'geos5_nh_sf_pv_difflat_save_daily.sav
syr=strmid(sdates,0,4)
smn=strmid(sdates,4,2)
sdy=strmid(sdates,6,2)
iyr0=min(long(syr))
iyr1=max(long(syr))
for ii=iyr0+1,iyr1 do begin
iyrm1=ii-1L
;
; extract NH winter season
;
syr=strmid(sdates,0,4)
smn=strmid(sdates,4,2)
sdy=strmid(sdates,6,2)
index=where( (syr eq strcompress(ii-1L,/remove_all) and strmid(smn,0,1) eq '1') or $
             (syr eq strcompress(ii,/remove_all) and smn eq '01') or $
             (syr eq strcompress(ii,/remove_all) and smn eq '02' and sdy ne '29') or $
             (syr eq strcompress(ii,/remove_all) and smn eq '03') )
sdate=sdates(index)
kday=n_elements(sdate)
syr=strmid(sdate,0,4)
smn=strmid(sdate,4,2)
sdy=strmid(sdate,6,2)
pvdiff=reform(pvdiff_all(index,*))
sfdiff=reform(sfdiff_all(index,*))
if ii eq 2005L then begin
   pvdiff_avg=0.*pvdiff
   npvdiff_avg=0L*pvdiff
   sfdiff_avg=0.*sfdiff
   nsfdiff_avg=0L*sfdiff
endif
index=where(pvdiff ne -99.)
pvdiff_avg(index)=pvdiff_avg(index)+pvdiff(index)
npvdiff_avg(index)=npvdiff_avg(index)+1L
index=where(sfdiff ne -99.)
sfdiff_avg(index)=sfdiff_avg(index)+sfdiff(index)
nsfdiff_avg(index)=nsfdiff_avg(index)+1L

endfor  ; loop over years
index=where(npvdiff_avg gt 0L)
if index(0) ne -1L then pvdiff_avg(index)=pvdiff_avg(index)/npvdiff_avg(index)
index=where(nsfdiff_avg gt 0L)
if index(0) ne -1L then sfdiff_avg(index)=sfdiff_avg(index)/nsfdiff_avg(index)

xindex=where(sdy eq '15',nxticks)
syr0=strcompress(min(long(syr)),/remove_all)
syr1=strcompress(max(long(syr)),/remove_all)

!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=[1.,2.,3.,4.,5.,10.,15.,20.,25.,30.]
nlvls2=n_elements(level)
col2=1+(indgen(nlvls2)/float(nlvls2))*mcolor
index=where(sfdiff_avg eq 0.)
if index(0) ne -1L then sfdiff_avg(index)=0./0.
sfdiff_avg=smooth(sfdiff_avg,3,/NaN,/edge_truncate)
sfdiff_avg(index)=0.
contour,sfdiff_avg,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),max(th)],c_color=col2,$
        /cell_fill,/noeras,levels=level,min_value=-99.,color=0,ytickname=[' ',' ',' ',' '],$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),title='NH (!4W!1  based)'
contour,sfdiff_avg,findgen(kday),th,/follow,levels=[10.],color=0,thick=5,/overplot,c_labels=[0]
ylabels=strcompress(string(format='(i2)',15.+5.*findgen(13)),/remove_all)
xyouts,xmx+0.075,ymn,'Approximate Altitude (km)',color=0,/normal,orientation=90.
xyouts,xmx+0.01,ymn,'20',color=0,/normal
xyouts,xmx+0.01,ymn+0.03,'30',color=0,/normal
xyouts,xmx+0.01,ymn+0.07,'40',color=0,/normal
xyouts,xmx+0.01,ymn+0.125,'50',color=0,/normal
xyouts,xmx+0.01,ymn+0.21,'60',color=0,/normal
xyouts,xmx+0.01,ymx-0.04,'70',color=0,/normal
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
index=where(pvdiff_avg eq 0.)
if index(0) ne -1L then pvdiff_avg(index)=0./0.
pvdiff_avg=smooth(pvdiff_avg,3,/NaN,/edge_truncate)
pvdiff_avg(index)=0.
contour,pvdiff_avg,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),max(th)],c_color=col2,$
        /cell_fill,/noeras,levels=level,min_value=-99.,color=0,ytickname=[' ',' ',' ',' '],$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),title='NH (PV based)'
contour,pvdiff_avg,findgen(kday),th,/follow,levels=[10.],color=0,thick=5,/overplot,c_labels=[0]
xyouts,xmx+0.075,ymn,'Approximate Altitude (km)',color=0,/normal,orientation=90.
xyouts,xmx+0.01,ymn,'20',color=0,/normal
xyouts,xmx+0.01,ymn+0.03,'30',color=0,/normal
xyouts,xmx+0.01,ymn+0.07,'40',color=0,/normal
xyouts,xmx+0.01,ymn+0.125,'50',color=0,/normal
xyouts,xmx+0.01,ymn+0.21,'60',color=0,/normal
xyouts,xmx+0.01,ymx-0.04,'70',color=0,/normal

omin=min(level)
omax=max(level)
xmnb=min(xorig)
xmxb=max(xorig)+xlen
ymx=min(yorig)-cbaryoff
ymn=ymx-cbarydel
set_viewport,xmnb,xmxb,ymn,ymx
!type=2^2+2^3+2^6
plot,[omin,omax],[0,0],yrange=[0,10],xrange=[omin,omax],color=0,xtitle='!4D !XLatitude',$
     xticks=nlvls2-1,xtickname=strcompress(long(level))
ybox=[0,10,10,0,0]
x1=omin
dx=(omax-omin)/float(nlvls2)
for j=0,nlvls2-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col2(j)
    x1=x1+dx
endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim figure_3.ps -rotate -90 figure_3.jpg'
;  spawn,'/usr/bin/rm figure_3.ps'
endif
end
