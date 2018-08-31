;
; plot only winter seasons in individual panels
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
xorig=[0.1,0.3,0.5,0.7]
yorig=[0.6,0.6,0.6,0.6]
xlen=0.175
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
          /bold,/color,bits_per_pixel=8,/helvetica,filename='geos5_sh_sf_vs_pv_difflat_tz_yearly.ps'
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
for ii=iyr0,iyr1-1L do begin
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
pvdiff=smooth(reform(pvdiff_all(index,*)),3)
sfdiff=smooth(reform(sfdiff_all(index,*)),3)
xindex=where(sdy eq '15',nxticks)
syr0=strcompress(min(long(syr)),/remove_all)

!type=2^2+2^3
xmn=xorig(ii-2004)
xmx=xorig(ii-2004)+xlen
ymn=yorig(ii-2004)
ymx=yorig(ii-2004)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=2.*findgen(nlvls)
level2=[1.,2.,3.,4.,5.,10.,20.,30.]
nlvls2=n_elements(level2)
col2=1+(indgen(nlvls2)/float(nlvls2))*mcolor
if ii eq 2004L then begin
   xyouts,xorig(ii-2004)-0.06,yorig(1)+ylen-0.015,'SH',/normal,color=0,charsize=2
   contour,sfdiff,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),max(th)],c_color=col2,$
        ytitle='Theta (K)',/cell_fill,/noeras,levels=level2,min_value=-99.,color=0,$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),title=syr0,charsize=0.8
;contour,sfdiff,findgen(kday),th,/overplot,levels=level
endif
if ii gt 2004 then begin
   contour,sfdiff,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),max(th)],c_color=col2,$
        /cell_fill,/noeras,levels=level2,min_value=-99.,color=0,yticks=1,ytickname=[' ',' '],$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),title=syr0,charsize=0.8
endif

!type=2^2+2^3
xmn=xorig(ii-2004)
xmx=xorig(ii-2004)+xlen
ymn=0.2
ymx=0.2+ylen
set_viewport,xmn,xmx,ymn,ymx
if ii eq 2004L then begin
   contour,pvdiff,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),max(th)],c_color=col2,$
        ytitle='Theta (K)',/cell_fill,/noeras,levels=level2,min_value=-99.,color=0,$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),charsize=0.8
;contour,pvdiff,findgen(kday),th,/overplot,levels=level
endif
if ii gt 2004 then begin
   contour,pvdiff,findgen(kday),th,xrange=[0.,kday],yrange=[min(th),max(th)],c_color=col2,$
        /cell_fill,/noeras,levels=level2,min_value=-99.,color=0,yticks=1,ytickname=[' ',' '],$
        xticks=nxticks-1,xtickv=xindex,xtickname=smn(xindex),charsize=0.8
endif

endfor

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
   spawn,'convert -trim geos5_sh_sf_vs_pv_difflat_tz_yearly.ps -rotate -90 '+$
         'geos5_sh_sf_vs_pv_difflat_tz_yearly.jpg'
;  spawn,'/usr/bin/rm geos5_sh_sf_vs_pv_difflat_tz_yearly.ps'
endif
end
