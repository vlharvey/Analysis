;
; plot Lyman alpha time series. Oct/Nov average for 2007 through 2012.
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
close,2
openr,2,'composite_lyman_alpha.csv'
dum=' '
readf,2,dum
date=19000101L
lya=0.
type=1L
count=0L
while not eof(2) do begin
      readf,2,date,lya,type
      if count eq 0L then begin
         date_all=date
         lya_all=lya
      endif
      if count gt 0L then begin
         date_all=[date_all,date]
         lya_all=[lya_all,lya]
      endif
      count=count+1L
endwhile
plot,findgen(count),lya_all,psym=1,color=0
stop 
ofile='ukmo_12Z_Ubar_Tbar_3D.sav'
restore,ofile
restore,'ukmo_12Z_SH_Ujet_lat_p_zero.sav'	;,sdate,latjet,pjet,zzero
nr=n_elements(wlat)
nl=n_elements(p)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/times,filename='lya_octnov_avg.ps'
   !p.charsize=2
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; loop over years
;
index=where(strmid(sdate,4,1) eq '1' or strmid(sdate,4,2) eq '01')
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
ledyr=2012
index=where((strmid(ondsdate,4,1) eq '1' and strmid(ondsdate,0,4) eq strcompress(lstyr,/remove_all)) or (strmid(ondsdate,4,2) eq '01' and strmid(ondsdate,0,4) eq strcompress(lstyr+1,/remove_all)),ndays)
plot,1+findgen(ndays),ondzzero(index),xrange=[1.,ndays],yrange=[100.,1.],/ylog,title='Height of Ubar=0 at 60S',xticks=3,$
     ytitle='Pressure (hPa)',charsize=2,charthick=2,xtickv=[15.,15.+31.,15.+31.+30.,15.+31.+30.+31.],xtickname=['Oct','Nov','Dec','Jan'],/nodata,color=0
nlvls=ledyr-lstyr
nint=ylen/float(nlvls)
for iyear=lstyr,ledyr do begin
    index=where((strmid(ondsdate,4,1) eq '1' and strmid(ondsdate,0,4) eq strcompress(iyear,/remove_all)) or (strmid(ondsdate,4,2) eq '01' and strmid(ondsdate,0,4) eq strcompress(iyear+1,/remove_all)),ndays)
    oplot,1+findgen(ndays),ondzzero(index),thick=8,color=((iyear-float(lstyr))/(float(ledyr-lstyr)+1.))*mcolor
    xyouts,xorig(0)+xlen+0.02,yorig(0)+ylen+(float(lstyr)-iyear)*nint,strcompress(iyear,/remove_all),/normal,charsize=2,color=((iyear-float(lstyr))/(float(ledyr-lstyr)+1.))*mcolor
print,ndays
endfor
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim lya_octnov_avg.ps -rotate -90 lya_octnov_avg.png'
endif
end
