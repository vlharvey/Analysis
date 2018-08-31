;
; plot SH lat/p of jet max and height of zero wind line
; MLS version
;
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='ps'
read,'setplot=',setplot
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.2]
xlen=0.7
ylen=0.7
cbaryoff=0.1
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
;
; ALAT            FLOAT     = Array[73]
; P               FLOAT     = Array[19]
; SDATE           STRING    = Array[8045]
; TBAR            FLOAT     = Array[73, 19, 8045]
; UBAR            FLOAT     = Array[72, 19, 8045]
; WLAT            FLOAT     = Array[72]
;
ofile='MLS_YZ_UVT_2004-2017.sav'		;/atmos/harvey/UKMO_data/Datfiles/ukmo_12Z_Ubar_Tbar_3D.sav'
restore,ofile
wlat=lat
p=pressure

restore,'mls_12Z_SH_Ujet_lat_p_zero.sav'	;,sdate,latjet,pjet,zzero
nr=n_elements(wlat)
nl=n_elements(p)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='mls_SHjet_zeroUbar.ps'
   !p.charsize=2
   !p.thick=3
   !p.charthick=5
   !y.thick=3
   !x.thick=3
endif
;
; truncate to Oct-Feb for SH PMC season interpretation
;
index=where(strmid(sdate,4,1) eq '1' or strmid(sdate,4,2) eq '01' or strmid(sdate,4,2) eq '02')
ondzzero=zzero(index)
ondsdate=sdate(index)

erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
lstyr=2007
;lstyr=1992
ledyr=2017
index=where((strmid(ondsdate,4,1) eq '1' and strmid(ondsdate,0,4) eq strcompress(lstyr,/remove_all)) or (strmid(ondsdate,4,2) eq '01' and strmid(ondsdate,0,4) eq strcompress(lstyr+1,/remove_all)) or $
            (strmid(ondsdate,4,2) eq '02' and strmid(ondsdate,0,4) eq strcompress(lstyr+1,/remove_all)),ndays)
ondsdate_temp=ondsdate(index)
ondzzero_temp=ondzzero(index)
;
; 1 October is -80
plot,-80+findgen(ndays),ondzzero_temp,xrange=[-80.,20],yrange=[70.,1],/ylog,title='MLS Height of Ubar=0 at 60S',xtickv=-80+20*findgen(6),xtickname=strcompress(long(-80+20*findgen(6)),/r),$
     ytitle='Pressure (hPa)',charsize=2,charthick=5,xtitle='Days From Solstice',color=0,thick=10,/nodata
nlvls=ledyr-lstyr+1
nint=ylen/float(nlvls)
col1=[0,150,10,50,115,125,180,210,240,150,230]				; 2007-2016
;col1=((findgen(nlvls))/float(nlvls))*mcolor		; all years
;
; from plot_timeseries_mls_temp_multi-year.pro in ~harvey/Harvey_etal_CIPS/ these are when ASC frequencies > 2%
; SH Onset Dates from Cora: 2007=335, 2008=335, 2009=323, 2010=350, 2011=330, 2012=326, 2013=321, 2014=326, 2015=347, 2016=322
;
onset_dates=[-20., -21., -32., -5., -25., -30., -34., -29., -8.,-34,-99]	; 2007-2016 SH onset dates (in 2008, 2012, 2016 subtract from DOY=356)
for iyear=lstyr,ledyr do begin
if iyear ne 2008 then loadct,23
if iyear eq 2008 then loadct,0
if iyear ge 2016 then loadct,2
    index=where((strmid(ondsdate,4,1) eq '1' and strmid(ondsdate,0,4) eq strcompress(iyear,/remove_all)) or $
                (strmid(ondsdate,4,2) eq '01' and strmid(ondsdate,0,4) eq strcompress(iyear+1,/remove_all)) or $
                (strmid(ondsdate,4,2) eq '02' and strmid(ondsdate,0,4) eq strcompress(iyear+1,/remove_all)),ndays)
    ondzzero_temp=ondzzero(index)
    index=where(ondzzero_temp eq -99.)		; no zero wind line within MLS height range
    if index(0) ne -1L then ondzzero_temp(index)=0./0.
    oplot,-80+findgen(ndays),smooth(ondzzero_temp,3,/Nan),thick=15,color=col1(iyear-lstyr)
;   if iyear ge 2016 then oplot,-80+findgen(ndays),smooth(ondzzero_temp,3,/Nan),psym=-4,thick=15,color=col1(iyear-lstyr)
xarray=-80+findgen(ndays)
yarray=smooth(ondzzero_temp,3,/Nan)
if iyear lt 2017L then begin
loadct,0
   xpt=onset_dates(iyear-2007)
   index=where(xarray eq xpt)
   ypt=yarray(index(0))
   oplot,[xpt,xpt],[ypt,ypt],psym=1,color=150,symsize=3,thick=10
;  xyouts,xpt,ypt,strcompress(xpt,/r),color=0,charsize=3,charthick=3
loadct,0
endif
if iyear ne 2008 then loadct,23
if iyear ge 2016 then loadct,2
    xyouts,xorig(0)+xlen-0.12,yorig(0)+ylen-0.03-0.04*(iyear-lstyr),strcompress(iyear,/remove_all),/normal,charsize=2,color=col1(iyear-lstyr),charthick=5	; 2007-2012
;   xyouts,xorig(0)+xlen+0.02,yorig(0)+ylen+0.04-0.04*(iyear-lstyr),strcompress(iyear,/remove_all),/normal,charsize=2,color=col1(iyear-lstyr),charthick=5	; all years
endfor
loadct,23
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim mls_SHjet_zeroUbar.ps -rotate -90 mls_SHjet_zeroUbar.png'
endif
end
