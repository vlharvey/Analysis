;
; 2007 SH season of NOGAPS-ALPHA data: daily time altitude section
; of the mean latitude difference between max (min) SF (PV) contours 
; and min latitude in any of the bins
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
xorig=[0.15]
yorig=[0.6]
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
          /bold,/color,bits_per_pixel=8,/helvetica,filename='nogaps_sh_sf_vs_pv_difflat_tz_yearly.ps'
endif
;
; PVDIFF_ALL      FLOAT     = Array[1583, 26]
; SFDIFF_ALL      FLOAT     = Array[1583, 26]
;
restore,'nogaps_sh_sf_pv_difflat_save_daily.sav
syr=strmid(sdates,0,4)
smn=strmid(sdates,4,2)
sdy=strmid(sdates,6,2)
iyr0=min(long(syr))
erase
;
; extract winter season
;
syr=strmid(sdates,0,4)
smn=strmid(sdates,4,2)
sdy=strmid(sdates,6,2)
sdate=sdates
kday=n_elements(sdate)
syr=strmid(sdate,0,4)
smn=strmid(sdate,4,2)
sdy=strmid(sdate,6,2)
pvdiff=pvdiff_all
sfdiff=sfdiff_all
xindex=where(sdy eq '15',nxticks)
syr0=strcompress(min(long(syr)),/remove_all)

!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=2.*findgen(nlvls)
level2=[1.,2.,3.,4.,5.,10.,20.,30.]
nlvls2=n_elements(level2)
col2=1+(indgen(nlvls2)/float(nlvls2))*mcolor
xyouts,xorig(0)-0.06,yorig(0)+ylen-0.015,'SH',/normal,color=0,charsize=2
contour,sfdiff,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),4600.],c_color=col2,$
        ytitle='Theta (K)',/cell_fill,/noeras,levels=level2,min_value=-99.,color=0,$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),title=syr0,charsize=0.8
;contour,sfdiff,findgen(kday),th,/overplot,levels=level
contour,sfdiff,findgen(kday),th,/follow,levels=[10.],color=0,thick=5,/overplot,c_labels=[0]

!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=0.2
ymx=0.2+ylen
set_viewport,xmn,xmx,ymn,ymx
pvdiff=smooth(pvdiff,3)
contour,pvdiff,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),4600.],c_color=col2,$
        ytitle='Theta (K)',/cell_fill,/noeras,levels=level2,min_value=-99.,color=0,$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),charsize=0.8
;contour,pvdiff,findgen(kday),th,/overplot,levels=level
contour,pvdiff,findgen(kday),th,/follow,levels=[10.],color=0,thick=5,/overplot,c_labels=[0]

; vertical color bars
omin=min(level2)
omax=max(level2)
xmnb=max(xorig)+xlen+0.05
xmxb=xmnb+cbarydel
set_viewport,xmnb,xmxb,yorig(0),yorig(0)+ylen
!type=2^2+2^3+2^5+2^6
plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=mcolor
xbox=[0,10,10,0,0]
y1=omin
dy=(omax-omin)/float(nlvls2)
for j=0,nlvls2-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col2(j)
    y1=y1+dy
endfor
!type=2^2+2^3+2^5
xyouts,xmxb+0.035,yorig(0)+ylen/4.0,'SF !4D !XLatitude',/normal,charsize=1.5,orientation=90.,color=0
plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=0,yticks=nlvls2-1,ytickname=strcompress(long(level2))

omin=min(level)
omax=max(level)
xmnb=max(xorig)+xlen+0.05
xmxb=xmnb+cbarydel
set_viewport,xmnb,xmxb,ymn,ymx
!type=2^2+2^3+2^5+2^6
plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=mcolor
xbox=[0,10,10,0,0]
y1=omin
dy=(omax-omin)/float(nlvls2)
for j=0,nlvls2-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col2(j)
    y1=y1+dy
endfor
!type=2^2+2^3+2^5
xyouts,xmxb+0.035,ymn+ylen/4.0,'PV !4D !XLatitude',/normal,charsize=1.5,orientation=90.,color=0
plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=0,yticks=nlvls2-1,ytickname=strcompress(long(level2))

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim nogaps_sh_sf_vs_pv_difflat_tz_yearly.ps -rotate -90 '+$
         'nogaps_sh_sf_vs_pv_difflat_tz_yearly.jpg'
;  spawn,'/usr/bin/rm nogaps_sh_sf_vs_pv_difflat_tz_yearly.ps'
endif
end
