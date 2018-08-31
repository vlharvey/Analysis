pro gcm_panels,npp,delta,nxdim,nydim,xorig,yorig,xlen,ylen,cbaryoff,cbarydel
;------------------------------------------------------------------------
; procedure to set positions for multi-panel plots in gcm plot codes
;
; input parameters:
;
;   npp           integer            number of panels per page
;   delta         string             flag, =y to generate delta plot
;
; returned parameters:
;
;   nxdim         integer            window x-dimension in pixels
;   nydim         integer            window y-dimension in pixels
;   xorig         fltarr(npp)        x coordinates of plot origins
;   yorig         fltarr(npp)        y coordinates of plot origins
;   xlen          real               length of x axis
;   ylen          real               length of y axis
;   cbaryoff      real               y distance between plot origin
;                                     and colorbar origin
;   cbarydel      real               thickness of colorbar
;-----------------------------------------------------------------------
;
;define viewport location for each panel
;
case 1 of
  (npp eq 1): begin
    nxdim=750
    nydim=750
    xorig=[0.12]
    yorig=[0.2]
    xlen=0.8
    ylen=0.7
    cbaryoff=0.1
    cbarydel=0.01
  end
  (npp eq 2): begin
    nxdim=1000
    nydim=750
    xorig=[.05,.56]
    yorig=[.2,.2]
    xlen=0.43
    ylen=0.70
    cbaryoff=0.1
    cbarydel=0.01
  end
  (npp eq 3 and delta eq 'y'): begin
    nxdim=1000
    nydim=750
    xorig=[.045,.385,.725]
    yorig=[.20,.20,.20]
    xlen=0.27
    ylen=0.70
    cbaryoff=0.1
    cbarydel=0.01
  end
  (npp eq 3 or npp eq 4): begin
    nxdim=800
    nydim=800
    xorig=[0.05,0.56,0.05,0.56]
    yorig=[0.61,0.61,0.10,0.10]
    xlen=0.36
    ylen=0.36
    cbaryoff=0.035
    cbarydel=0.01
  end
  (npp eq 6): begin
    nxdim=750
    nydim=600
    xorig=[.0,.35,.7,.0,.35,.7]
    yorig=[.55,.55,.55,.15,.15,.15]
    xlen=0.3
    ylen=0.3
    cbaryoff=0.03
    cbarydel=0.02
  end
endcase
end
;
; main program to drive gcm_panels
;
@gcm_panels
setplot='x'
read,'setplot=',setplot
npp=2
delta='n'
!NOERAS=1
gcm_panels,npp,delta,nxdim,nydim,xorig,yorig,xlen,ylen,cbaryoff,cbarydel
if setplot ne 'ps' then window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
if setplot eq 'ps' then begin
   set_plot,'ps'
   !p.font=0
   device,/color
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,bits=8,filename='idl.ps'
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
endif
;
; plot
;
erase
for ipan=0,npp-1 do begin
    xmn=xorig(ipan)
    xmx=xorig(ipan)+xlen
    ymn=yorig(ipan)
    ymx=yorig(ipan)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !psym=0
    MAP_SET,90,0,-90,/stereo,/noeras,/contin,/noborder
    contour,dum,x,alat,/overplot,/noeras,nlevels=20
endfor
if setplot eq 'ps' then device, /close
end
