;
; print all fonts
;
loadct,39
device,decompose=0
icolmax=byte(!p.color)
icolmax=fix(icolmax)
mcolor=icolmax
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
!noeras=1
nxdim=750
nydim=750
xorig=[0.1]
yorig=[0.1]
xlen=0.8
ylen=0.8
setplot='x'
read,'setplot=',setplot
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=icolmax
endif
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,filename='char_font.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; print characters
;
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
xinc=(xmx-xmn)/20
yinc=(ymx-ymn)/20
for ichar=1,20 do begin
    schar=strcompress(ichar,/remove_all)
    xyouts,xmn,ymx+0.05,'!n'+schar,color=0,/normal,charsize=2,alignment=0.5
    xyouts,xmn,ymx,'!'+schar+'a',color=0,/normal,charsize=2
    xyouts,xmn,ymx-yinc,'!'+schar+'b',color=0,/normal,charsize=2
    xyouts,xmn,ymx-2.*yinc,'!'+schar+'c',color=0,/normal,charsize=2
    xyouts,xmn,ymx-3.*yinc,'!'+schar+'d',color=0,/normal,charsize=2
    xyouts,xmn,ymx-4.*yinc,'!'+schar+'e',color=0,/normal,charsize=2
    xyouts,xmn,ymx-5.*yinc,'!'+schar+'f',color=0,/normal,charsize=2
    xyouts,xmn,ymx-6.*yinc,'!'+schar+'g',color=0,/normal,charsize=2
    xyouts,xmn,ymx-7.*yinc,'!'+schar+'h',color=0,/normal,charsize=2
    xyouts,xmn,ymx-8.*yinc,'!'+schar+'i',color=0,/normal,charsize=2
    xyouts,xmn,ymx-9.*yinc,'!'+schar+'j',color=0,/normal,charsize=2
    xyouts,xmn,ymx-10.*yinc,'!'+schar+'k',color=0,/normal,charsize=2
    xyouts,xmn,ymx-11.*yinc,'!'+schar+'l',color=0,/normal,charsize=2
    xyouts,xmn,ymx-12.*yinc,'!'+schar+'m',color=0,/normal,charsize=2
    xyouts,xmn,ymx-13.*yinc,'!'+schar+'n',color=0,/normal,charsize=2
    xyouts,xmn,ymx-14.*yinc,'!'+schar+'o',color=0,/normal,charsize=2
    xyouts,xmn,ymx-15.*yinc,'!'+schar+'p',color=0,/normal,charsize=2
    xyouts,xmn,ymx-16.*yinc,'!'+schar+'q',color=0,/normal,charsize=2
    xyouts,xmn,ymx-17.*yinc,'!'+schar+'r',color=0,/normal,charsize=2
    xyouts,xmn,ymx-18.*yinc,'!'+schar+'s',color=0,/normal,charsize=2
    xyouts,xmn,ymx-19.*yinc,'!'+schar+'t',color=0,/normal,charsize=2
    xyouts,xmn,ymx-20.*yinc,'!'+schar+'u',color=0,/normal,charsize=2

    xmn=xmn+xinc
endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim char_font.ps -rotate -90 char_font.jpg'
stop
endif
end
