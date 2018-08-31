;
; MERRA SSW length with ES and w/o ES
;
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[.15]
yorig=[.25]
xlen=0.7
ylen=0.5
cbaryoff=0.075
cbarydel=0.01
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
!noeras=1
;
; save postscript version
;
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='merra_ssw_pdfs.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
   !p.thick=2.
   !p.charthick=2.
   !p.charsize=1.5
endif

!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
restore,'../Post_process/merra_sswlen_ult0.sav
index=where(sswdd/10000L eq 2004L or sswdd/10000L eq 2006L or $
            sswdd/1000L eq 20090L or sswdd/1000L eq 20120L or sswdd/10000L eq 2013L)
index2=where(sswdd/10000L eq 1985L or sswdd/1000L eq 19870L)
esflag=0*sswdd
esflag(index)=1
esflag(index2)=2
years=1979+indgen(35)
index=where(esflag eq 0)
nmajornoes=sswlen(index)
index=where(esflag eq 1)
nmajorwes=sswlen(index)
esdates=sswdd(index)
x=5*findgen(17)
x=findgen(41)
y1=histogram(nmajornoes,min=0,max=40,binsize=1)
y2=histogram(nmajorwes,min=0,max=40,binsize=1)
plot,x,y1,color=0,thick=15,ytitle='Number of Major SSWs',xtitle='Major SSW duration (days)',charsize=2,charthick=2,yrange=[0,3],xrange=[0,40],/nodata,yticks=3
index=where(y1 ne 0)
;oplot,x(index),y1(index),color=0,psym=8,symsize=2
for i=0L,n_elements(index)-1L do begin
    plots,x(index(i)),0
    plots,x(index(i)),y1(index(i)),/continue,color=0,thick=10
endfor
index=where(y2 ne 0)
;oplot,x(index),y2(index),color=250,psym=8,symsize=1.5	;thick=15
for i=0L,n_elements(index)-1L do begin
    plots,x(index(i)),0
    plots,x(index(i)),y2(index(i)),/continue,color=250,thick=10
;   xyouts,x(index(i)),y2(index(i)),strmid(strcompress(SSWDD,/remove_all),0,4),/data,charsize=2,charthick=2,color=250
endfor
xyouts,10,2.75,'MERRA 1979-2013',/data,charsize=2,charthick=2,color=0

;restore,'merra_sswlen_ult5.sav
;index=where(sswdd/10000L eq 1985L or sswdd/1000L eq 19870L or sswdd/10000L eq 2004L or sswdd/10000L eq 2006L or $
;            sswdd/1000L eq 20090L or sswdd/10000L eq 2010L or sswdd/1000L eq 20120L or sswdd/10000L eq 2013L)
;esflag=0*sswdd
;esflag(index)=1
;years=1979+indgen(35)
;index=where(esflag eq 0)
;nmajornoes=sswlen(index)
;index=where(esflag eq 1)
;nmajorwes=sswlen(index)
;x=5*findgen(17)
;y1=histogram(nmajornoes,min=0,max=80,binsize=5)
;y2=histogram(nmajorwes,min=0,max=80,binsize=5)
;loadct,0
;oplot,x,y1,color=100,thick=14
;loadct,39
;oplot,x,y2,color=200,thick=14
;
;restore,'merra_sswlen_ult10.sav
;index=where(sswdd/10000L eq 1985L or sswdd/1000L eq 19870L or sswdd/10000L eq 2004L or sswdd/10000L eq 2006L or $
;            sswdd/1000L eq 20090L or sswdd/10000L eq 2010L or sswdd/1000L eq 20120L or sswdd/10000L eq 2013L)
;esflag=0*sswdd
;esflag(index)=1
;index=where(esflag eq 0)
;nmajornoes=sswlen(index)
;index=where(esflag eq 1)
;nmajorwes=sswlen(index)
;y1=histogram(nmajornoes,min=0,max=80,binsize=5)
;y2=histogram(nmajorwes,min=0,max=80,binsize=5)
;;loadct,0
;;oplot,x,y1,color=150,thick=8
;;loadct,39
;;oplot,x,y2,color=150,thick=8

;restore,'merra_sswlen_ult15.sav
;index=where(sswdd/10000L eq 1985L or sswdd/1000L eq 19870L or sswdd/10000L eq 2004L or sswdd/10000L eq 2006L or $
;            sswdd/1000L eq 20090L or sswdd/10000L eq 2010L or sswdd/1000L eq 20120L or sswdd/10000L eq 2013L)
;esflag=0*sswdd
;esflag(index)=1
;index=where(esflag eq 0)
;nmajornoes=sswlen(index)
;index=where(esflag eq 1)
;nmajorwes=sswlen(index)
;y1=histogram(nmajornoes,min=0,max=80,binsize=5)
;y2=histogram(nmajorwes,min=0,max=80,binsize=5)
;loadct,0
;oplot,x,y1,color=200,thick=13
xyouts,32,2.8,'NO ES',color=0,/data,charsize=2,charthick=2
;xyouts,20,11,'NO ES Ubar<5',color=100,/data,charsize=2,charthick=2
;xyouts,20,10,'NO ES Ubar<15',color=200,/data,charsize=2,charthick=2
loadct,39
;oplot,x,y2,color=100,thick=13
xyouts,32,2.6,'ES',color=250,/data,charsize=2,charthick=2
;xyouts,50,11,'ES Ubar<5',color=200,/data,charsize=2,charthick=2
;xyouts,50,10,'ES Ubar<15',color=100,/data,charsize=2,charthick=2

if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim merra_ssw_pdfs.ps -rotate -90 merra_ssw_pdfs.jpg'
endif

end
