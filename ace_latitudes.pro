;
; plot ACE latitudes
;
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
setplot='x'
read,'setplot=',setplot
mcolor=icolmax
icmm1=icolmax-1
icmm2=icolmax-2
nxdim=600 & nydim=600
xorig=[0.15]
yorig=[0.25]
xlen=0.7
ylen=0.5
cbaryoff=0.08
cbarydel=0.02
!NOERAS=-1
!p.font=1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
month='        '+['J','F','M','A','M','J','J','A','S','O','N','D',' ']
dira='/aura3/data/ACE_data/Datfiles_SOSST/v2.2/'
syear=['2004','2005','2006']
nyear=n_elements(syear)
nlvls=n_elements(syear)
col1=51+indgen(nlvls)*icolmax/nlvls
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,bits=8,filename='ace_latitudes.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
endif
;
; loop over years
;
for iyear=0L,nyear-1L do begin
;
; restore ACE SOSST data
;
    ex=findfile(dira+'cat_ace_v2.2.'+syear(iyear))
    if ex(0) eq '' then goto,jumpyear
    restore,dira+'cat_ace_v2.2.'+syear(iyear)

    if iyear eq 0L then begin
       erase
       !type=2^2+2^3
       xmn=xorig(0)
       xmx=xorig(0)+xlen
       ymn=yorig(0)
       ymx=yorig(0)+ylen
       set_viewport,xmn,xmx,ymn,ymx
       plot,fdoy,latitude,psym=8,color=0,yrange=[-90.,90.],xrange=[1.,366.],xticks=12,$
            xtickname=month,charsize=2,ytitle='Latitude',yticks=6
    endif
    oplot,fdoy,latitude,psym=8,color=col1(iyear-(nyear-3L)),symsize=0.8
    xyouts,120.,95.,'2004',/data,color=col1(0),charsize=2
    xyouts,170.,95.,'2005',/data,color=col1(1),charsize=2
    xyouts,220.,95.,'2006',/data,color=col1(2),charsize=2

    jumpyear:
endfor  ; loop over years
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim ace_latitudes.ps -rotate -90 ace_latitudes.jpg'
endif
end
