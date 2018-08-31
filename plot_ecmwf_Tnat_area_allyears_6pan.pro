;
; plot area within 2004-2005 NH Tnat and save for all levels and years
; Tnat values at theta levels and on dates in Datfiles/Tnat_SC.dat
;
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
device,decompose=0
!noeras=1
nxdim=600
nydim=750
xorig=[.15,.15,.15,.15,.15]
yorig=[.7,.55,.4,.25,.1]
xlen=0.6
ylen=0.1
cbaryoff=0.03
cbarydel=0.02
set_plot,'x'
setplot='x'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   !p.background=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
smon=['J','F','M','A','M','J','J','A','S','O','N','D']
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
nmon=['01','02','03','04','05','06','07','08','09','10','11','12']

restore,'ecmwf_Tnat_area_allyears.sav'	;,area_ave,years,th,sfile
area_all=area_ave
kday=n_elements(SFILE)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='ecmwf_tnat_area_allyears_6pan.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif

rth=[600.,550.,500.,450.,400.]
xyouts,.2,.85,'ECMWF N.H. Area T<Tnat',/normal,charsize=2,color=0
for k=0L,n_elements(rth)-1L do begin
index=where(th eq rth(k))
ith=index(0)
sth=strcompress(long(th(ith)),/remove_all)

xmn=xorig(k)
xmx=xorig(k)+xlen
ymn=yorig(k)
ymx=yorig(k)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3+2^7
plot,[1,kday,kday,1,1],[0.,0.,20.,20.,0.],min_value=0.,color=0,$
      xrange=[1,kday],yrange=[0.,20.],/nodata,charsize=1.5,$
      ytitle='1.e6 km!u2!n',xtickname=[' ',' '],xticks=1,$
      title=sth+' K'
kindex=where(strmid(sfile,3,2) eq '15',nxtick)
xmon=long(strmid(sfile(kindex),0,2))
for i=0,nxtick-1 do begin
    xlab=smon(xmon(i)-1)
    plots,kindex(i)+1,0.
    plots,kindex(i)+1,-1.,/continue,/data,color=0
    xyouts,kindex(i)+1,-5.,xlab,/data,alignment=0.5,charsize=1.5,color=0
endfor

nyear=n_elements(years)
area_all_lev=reform(area_all(*,*,ith))
nlvls=nyear
col1=1+indgen(nlvls)*icolmax/nlvls
yinc=(max(yorig)+ylen-min(yorig))/nlvls
slab=[$
'78-79',$
'79-80',$
'80-81',$
'81-82',$
'82-83',$
'83-84',$
'84-85',$
'85-86',$
'86-87',$
'87-88',$
'88-89',$
'89-90',$
'90-91',$
'91-92',$
'92-93',$
'93-94',$
'94-95',$
'95-96',$
'96-97',$
'97-98',$
'98-99',$
'99-00',$
'00-01',$
'01-02',$
'02-03',$
'03-04',$
'04-05']
for iyear=0L,nyear-1L do begin
    area_ave=reform(area_all_lev(iyear,*))
    index=where(abs(area_ave) lt 1.)
    if index(0) ne -1 then area_ave(index)=-9999.
    oplot,findgen(kday),area_ave,color=col1(iyear),thick=3,min_value=-999.
    xyouts,xmx+0.02,min(yorig)+iyear*yinc,slab(iyear),charsize=2,color=col1(iyear),/normal,charthick=2
endfor
oplot,findgen(kday),area_ave,color=0,thick=5,min_value=-999.
xyouts,xmx+0.02,min(yorig)+(nyear-1L)*yinc,slab(nyear-1),charsize=2,color=0,/normal,charthick=2

endfor	; loop over levels

if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim ecmwf_tnat_area_allyears_6pan.ps -rotate -90 ecmwf_tnat_area_allyears_6pan.jpg'
endif

end
