;
; plot annual cycles of zonal mean zonal wind at 60 N for all years 1991-2010
;
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
mon=['Jan','Feb','Mar','Apr','May','Jun',$
     'Jul','Aug','Sep','Oct','Nov','Dec']
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.175,0.175]
yorig=[0.6,0.15]
xlen=0.7
ylen=0.35
cbaryoff=0.08
cbarydel=0.02
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
;
; restore save file
;
restore,file='MetO_dTdy_Ubar_SSW_Climo.sav'	;,yyyymmdd,th,nh_dtdy,sh_dtdy,nh_ubar60,sh_ubar60,comment
syyyymmdd=strcompress(yyyymmdd,/remove_all)
syear=strmid(syyyymmdd,0,4)
smon=strmid(syyyymmdd,4,2)
sday=strmid(syyyymmdd,6,2)
rlev=1000.
print,th
read,'Enter desired altitude ',rlev
index=where(th eq rlev)
ilev=index(0)
slev=strcompress(long(rlev),/remove_all)
NH_UBAR60_lev=reform(NH_UBAR60(*,ilev))
NH_dtdy_lev=reform(NH_dtdy(*,ilev))
index=where(NH_UBAR60_lev eq 0.)
if index(0) ne -1L then NH_UBAR60_lev(index)=0./0.
index=where(NH_dtdy_lev eq 0.)
if index(0) ne -1L then NH_dtdy_lev(index)=0./0.
;
; postscript file and plot
;
if setplot eq 'ps' then begin
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   !p.font=0
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='plot_dtdy_ubar_ssw_meto_'+slev+'K.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
erase
!type=2^2+2^3
iyear0=min(long(syear))
iyear0=2004
iyear1=max(long(syear))
nlvls=iyear1-iyear0+1L
col1=indgen(nlvls)*mcolor/(nlvls-1)
umin=-50. & umax=100.	; 2000 K
;umin=-20. & umax=80.	; 700 K
;umin=-10. & umax=50.	; 500 K
;umin=-10. & umax=10.	; 280 K
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,findgen(10),/nodata,yrange=[umin,umax],xrange=[1.,365.],/noeras,title=slev+' K',color=0,$
     xticks=11,xtickname=mon,ytitle='Zonal Mean Zonal Wind at 60!uo!n N'
ymn=yorig(0)
ymx=yorig(0)+ylen
yinc=(ymx-ymn)/nlvls
for iyear=iyear0,iyear1 do begin
    index=where(long(syear) eq iyear,ndays)
    NH_UBAR60_lev_year=smooth(NH_UBAR60_lev(index),3,/nan)
;   NH_UBAR60_lev_year=NH_UBAR60_lev(index)
    ithick=3
    if iyear eq 2004 or iyear eq 2006 or iyear eq 2009 or iyear eq 2010 then ithick=6
    oplot,findgen(ndays),NH_UBAR60_lev_year,psym=0,color=col1(iyear-iyear0),thick=ithick
    xyouts,xmx+0.02,ymn+0.01+yinc*(iyear-iyear0),syear(index(0)),color=col1(iyear-iyear0),/normal,charsize=1
    if iyear eq 2010 then begin
       loadct,0
       oplot,findgen(ndays),NH_UBAR60_lev_year,psym=0,color=150,thick=ithick
       xyouts,xmx+0.02,ymn+0.01+yinc*(iyear-iyear0),syear(index(0)),color=150,/normal,charsize=1
       loadct,39
    endif
endfor		; loop over years
plots,1,0
plots,365,0,/continue,color=0

umin=-50. & umax=50.
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,findgen(10),/nodata,yrange=[umin,umax],xrange=[1.,365.],/noeras,color=0,$
     xticks=11,xtickname=mon,ytitle='T at Pole minus T at 60!uo!n N'
ymn=yorig(1)
ymx=yorig(1)+ylen
yinc=(ymx-ymn)/nlvls
for iyear=iyear0,iyear1 do begin
    index=where(long(syear) eq iyear,ndays)
    NH_dtdy_lev_year=smooth(NH_dtdy_lev(index),3,/nan)
;   NH_dtdy_lev_year=NH_dtdy_lev(index)
    ithick=3
    if iyear eq 2004 or iyear eq 2006 or iyear eq 2009 or iyear eq 2010 then ithick=6
    oplot,findgen(ndays),NH_dtdy_lev_year,psym=0,color=col1(iyear-iyear0),thick=ithick
    xyouts,xmx+0.02,ymn+0.01+yinc*(iyear-iyear0),syear(index(0)),color=col1(iyear-iyear0),/normal,charsize=1
    if iyear eq 2010 then begin
       loadct,0
       oplot,findgen(ndays),NH_dtdy_lev_year,psym=0,color=150,thick=ithick
       xyouts,xmx+0.02,ymn+0.01+yinc*(iyear-iyear0),syear(index(0)),color=150,/normal,charsize=1
       loadct,39
    endif
endfor          ; loop over years
plots,1,0
plots,365,0,/continue,color=0

;
; Close PostScript file and return control to X-windows

     if setplot ne 'ps' then stop
     if setplot eq 'ps' then begin
        device, /close
        spawn,'convert -trim plot_dtdy_ubar_ssw_meto_'+slev+'K.ps -rotate -90 '+$
                            'plot_dtdy_ubar_ssw_meto_'+slev+'K.jpg'
;       spawn,'/usr/bin/rm plot_dtdy_ubar_ssw_meto_'+slev+'K.ps'
     endif
end
