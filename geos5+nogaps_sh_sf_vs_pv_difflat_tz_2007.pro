;
; 2007 SH NOGAPS vs GEOS-5 PV latitude differences
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
yorig=[0.6,0.15]
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
nlvls=20
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
          /bold,/color,bits_per_pixel=8,/helvetica,filename='geos5+nogaps_sh_sf_vs_pv_difflat_tz_2007.ps'
endif
;
; PVDIFF_ALL      FLOAT     = Array[1583, 26]
; SFDIFF_ALL      FLOAT     = Array[1583, 26]
;
restore,'geos5_sh_sf_pv_difflat_save_daily.sav
;
; extract winter season
;
syr=strmid(sdates,0,4)
smn=strmid(sdates,4,2)
sdy=strmid(sdates,6,2)
index=where( (syr eq '2007' and smn eq '05' and long(sdy) ge 15L) or (syr eq '2007' and smn eq '06') or $
             (syr eq '2007' and smn eq '07') or (syr eq '2007' and smn eq '08') )
sdate=sdates(index)
kday=n_elements(sdate)
syr=strmid(sdate,0,4)
smn=strmid(sdate,4,2)
sdy=strmid(sdate,6,2)
pvdiff=reform(pvdiff_all(index,*))
sfdiff=reform(sfdiff_all(index,*))
xindex=where(sdy eq '15',nxticks)

erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level2=2.+2.*findgen(nlvls)
;level2=[1.,2.,3.,4.,5.,10.,20.,30.,40.,50.]
nlvls2=n_elements(level2)
col2=1+(indgen(nlvls2)/float(nlvls2))*mcolor
;pvdiff=smooth(pvdiff,3)
contour,pvdiff,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),max(th)],c_color=col2,$
        ytitle='Theta (K)',/cell_fill,/noeras,levels=level2,min_value=-99.,color=0,$
        charsize=1.5,xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex)
contour,pvdiff,findgen(kday),th,/follow,levels=[10.],color=0,thick=5,/overplot,c_labels=[0]
xyouts,xorig(0)+0.05,yorig(0)+ylen+0.015,'GEOS-5',/normal,color=0,charsize=1.5
xyouts,xorig(0)+xlen-0.15,yorig(0)+ylen+0.015,'SH 2007',/normal,color=0,charsize=1.5
index=where(pvdiff ne 0.)
print,'GEOS ',min(pvdiff(index)),max(pvdiff)
;
; NOGAPS
;
restore,'nogaps_sh_sf_pv_difflat_save_daily.sav
syr=strmid(sdates,0,4)
smn=strmid(sdates,4,2)
sdy=strmid(sdates,6,2)
pvdiff=pvdiff_all
sfdiff=sfdiff_all
xindex=where(sdy eq '15',nxticks)
kday=n_elements(sdates)

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
set_viewport,xmn,xmx,ymn,ymx
index=where(pvdiff ne 0.)
;pvdiff=smooth(pvdiff,3)
contour,pvdiff,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),max(th)],c_color=col2,$
        ytitle='Theta (K)',/cell_fill,/noeras,levels=level2,min_value=-99.,color=0,$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),charsize=1.5
contour,pvdiff,findgen(kday),th,/follow,levels=[10.],color=0,thick=5,/overplot,c_labels=[0]
xyouts,xorig(0)+0.05,yorig(1)+ylen+0.015,'NOGAPS-ALPHA',/normal,color=0,charsize=1.5
xyouts,xorig(0)+xlen-0.15,yorig(1)+ylen+0.015,'SH 2007',/normal,color=0,charsize=1.5

omin=min(level2)
omax=max(level2)
xmnb=xorig(0)
xmxb=xorig(0)+xlen
set_viewport,xmnb,xmxb,yorig(1)-cbaryoff,yorig(1)-cbaryoff+cbarydel
!type=2^2+2^3+2^6
plot,[omin,omax],[0,0],yrange=[0,10],xrange=[omin,omax],color=0,$
      xtitle='!4D !XLatitude'	;,xticks=nlvls2-1,xtickname=strcompress(long(level2))
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
   spawn,'convert -trim geos5+nogaps_sh_sf_vs_pv_difflat_tz_2007.ps -rotate -90 '+$
         'geos5+nogaps_sh_sf_vs_pv_difflat_tz_2007.jpg'
;  spawn,'/usr/bin/rm geos5+nogaps_sh_sf_vs_pv_difflat_tz_2007.ps'
endif
end
