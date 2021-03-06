pro gcm_panels,npp,delta,nxdim,nydim,xorig,yorig,xlen,ylen,cbaryoff,cbarydel

;------------------------------------------------------------------------
;
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
;
;------------------------------------------------------------------------

;C  define viewport location for each panel
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
    cbaryoff=0.055
    cbarydel=0.005
  end
  (npp eq 6): begin
    nxdim=750
    nydim=600
    xorig=[.01,.34,.67,.01,.34,.67]
    yorig=[.55,.55,.55,.10,.10,.10]
    xlen=0.3
    ylen=0.4
    cbaryoff=0.03
    cbarydel=0.02
  end
  (npp eq 9): begin
    nxdim=800
    nydim=800
    xorig=[.0725,.3725,.6725,.0725,.3725,.6725,.0725,.3725,.6725]
    yorig=[.7,.7,.7,.4,.4,.4,.1,.1,.1]
    xlen=0.25
    ylen=0.25
    cbaryoff=0.03
    cbarydel=0.02
  end
  (npp eq 12): begin
    nxdim=1000
    nydim=800
    xorig=[.1,.3,.5,.7,.1,.3,.5,.7,.1,.3,.5,.7]
    yorig=[.68,.68,.68,.68,.4,.4,.4,.4,.12,.12,.12,.12]
    xlen=0.2
    ylen=0.2
    cbaryoff=0.02
    cbarydel=0.02
  end
  (npp eq 16): begin
    nxdim=1000
    nydim=800
    xorig=[.1,.3,.5,.7,.1,.3,.5,.7,.1,.3,.5,.7,.1,.3,.5,.7]
    yorig=[.7,.7,.7,.7,.5,.5,.5,.5,.3,.3,.3,.3,.1,.1,.1,.1]
    xlen=0.2
    ylen=0.12
    cbaryoff=0.02
    cbarydel=0.02
  end

endcase

end
