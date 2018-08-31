;
; plot Lyman alpha time series. Apr/May average for 2007 through 2012.
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
; NH PMC onset dates in DFS
;
NHyear=[2007,2008,2009,2010,2011,2012,2013,2014]
NHonset=[-27.,-20.,-24.,-24.,-26.,-27.,-34.,-22.]
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
;plot,findgen(count),lya_all,psym=1,color=0
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/times,filename='lya_aprmay_avg.ps'
   !p.charsize=2
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; loop over years
;
ondsdate=strcompress(date_all,/remove_all)

erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
lstyr=2007
ledyr=2014
nyear=ledyr-lstyr+1
result=strsplit(dum,',',/extract)

index=where(((strmid(ondsdate,4,2) eq '04' or strmid(ondsdate,4,2) eq '05') and strmid(ondsdate,0,4) eq strcompress(lstyr,/remove_all)),ndays)
plot,lstyr+findgen(nyear),findgen(nyear),xrange=[lstyr,ledyr],yrange=[3.4,4.4],xticks=nyear-1,$
     ytitle=result(1),charsize=2,charthick=2,/nodata,color=0,title='April-May Mean'
lya_aprmay=fltarr(nyear)
for iyear=lstyr,ledyr do begin
    index=where((strmid(ondsdate,4,2) eq '04' or strmid(ondsdate,4,2) eq '05') and strmid(ondsdate,0,4) eq strcompress(iyear,/remove_all)) 
    oplot,[iyear,iyear],[mean(lya_all(index)),mean(lya_all(index))],psym=8,color=0,symsize=2
    if iyear ge 2007 then begin
;      oplot,[iyear,iyear],[mean(lya_all(index)),mean(lya_all(index))],psym=8,color=mcolor*.9,symsize=2
       xyouts,iyear,mean(lya_all(index))-0.05,string(format='(f4.2)',strcompress(mean(lya_all(index)),/remove_all)),color=0,/data,charsize=1.5,charthick=2
    endif
    lya_aprmay(iyear-lstyr)=mean(lya_all(index))
endfor
oplot,lstyr+findgen(nyear),lya_aprmay,color=0,thick=8
axis,yaxis=1,yrange=[-35.,-20.],/save,color=mcolor*.9,ytitle='NH PMC Onset Date (DFS)',charsize=2,charthick=2
oplot,nhyear,nhonset,color=mcolor*.9,thick=8
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim lya_aprmay_avg.ps -rotate -90 lya_aprmay_avg.png'
endif
end
