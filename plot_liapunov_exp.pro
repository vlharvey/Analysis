;
x0=54
;
nmax=1	; # stream lines
nday=20	; # outputs
;f=['1','2','3','4','5','6','7','8','9','10','11','12','13','14','15']	; # lines
f=['1']
setplot='x'
if setplot eq 'ps' then begin
set_plot,'ps'
xsize=8.00
ysize=8.00
!psym=0
device,/color,/landscape,bits=8,filename='lap.ps'
device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
xsize=xsize,ysize=ysize
endif

lines10=fltarr(nmax,nday)
linefit10=fltarr(nmax,nday)
lineerr10=fltarr(nmax,nday)
lapexp10=fltarr(nmax)
sigma10=fltarr(nmax)

lines30=fltarr(nmax,nday)
linefit30=fltarr(nmax,nday)
lineerr30=fltarr(nmax,nday)
lapexp30=fltarr(nmax)
sigma30=fltarr(nmax)
x=findgen(nday)
;
;  log linear fit
;
openr,1,'ukmo_jan16-feb04_strm1.def.20d_log_fit'
forrd,1,lines10
forrd,1,linefit10
forrd,1,lineerr10
forrd,1,lapexp10
forrd,1,sigma10
close,1
;
;  1st order linear fit
;
openr,1,'ukmo_jan16-feb04_strm1.def.20d_lin_fit'
forrd,1,lines30
forrd,1,linefit30
forrd,1,lineerr30
forrd,1,lapexp30
forrd,1,sigma30
close,1
set_viewport,.1,.9,.1,.9
!mtitle='UKMO January 16 - Febrary 4 2001 1000 K Liapunov exponents'
!xtitle='Material lines'
!ytitle='stretching rate (1/day)'
x=findgen(nmax)
!type=2^2+2^3
!xmin=1
!xmax=nmax
!ymax=1.
!ymin=0.01
!p.thick=2
!psym=4
!linetype=0
plot_io,x,lapexp10
oplot,[65,55],[0.1,0.1]
!linetype=2
!psym=2
oplot,x,lapexp30
oplot,[65,55],[.025,.025]
stop
end
