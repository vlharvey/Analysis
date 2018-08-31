;--------------------------------------------------
;PlotPositions procedure
;
;defines the positions of n plots on a landscape or portrait
;
;nplots = 1,2,3,4
;--------------------------------------------------



PRO plotPosition, nplots, lndscp, posL, posP


; Create position structure
position = { posStruct, x1 : [0., 0., 0., 0., 0., 0.], y1 : [0., 0., 0., 0., 0., 0.],$   ; bottom left and top right indicies
                        x2 : [0., 0., 0., 0., 0., 0.], y2 : [0., 0., 0., 0., 0., 0.] }		
posL = REPLICATE( position, 1)
posP = REPLICATE( position, 1)
;Define the position for each plot with 1, 2, 3, or 4 plots on a page

; Landscape positions
if nplots eq 1 then begin
if lndscp eq 1 then begin
  posL.x1[0] = .1			; 1 plot
  posL.y1[0] = .1 
  posL.x2[0] = .9
  posL.y2[0] = .9
endif
endif

if lndscp eq 1 then begin
  if nplots eq 2 then begin
    posL.x1 = [ .2,  .2, 0., 0., 0., 0.]		; 2 plots
    posL.y1 = [.55, .05, 0., 0., 0., 0.]
    posL.x2 = [ .8,  .8, 0., 0., 0., 0.]
    posL.y2 = [.95, .45, 0., 0., 0., 0.]
  endif

  if nplots eq 3 then begin
    posL.x1 = [ .1,  .1,  .6, 0., 0., 0.]	; 3 plots
    posL.y1 = [.55, .05, .55, 0., 0., 0.]
    posL.x2 = [.45, .45, .95, 0., 0., 0.]
    posL.y2 = [.95, .45, .95, 0., 0., 0.]
  endif

  if nplots eq 4 then begin
    posL.x1 = [ .1,  .1,  .6,  .6, 0., 0.]	; 4 plots
    posL.y1 = [.55, .05, .55, .05, 0., 0.]
    posL.x2 = [.45, .45, .95, .95, 0., 0.]
    posL.y2 = [.95, .45, .95, .45, 0., 0.]
  endif


  if nplots eq 5 then begin
    posL.x1 = [ .1,  .1,  .1,  .6,  .6, 0.]	; 4 plots
    posL.y1 = [.75,  .4, .05, .75,  .4, 0.]
    posL.x2 = [.45, .45, .45, .95, .95, 0.]
    posL.y2 = [.95,  .6, .25, .95,  .6, 0.]
  endif

  if nplots eq 6 then begin
    posL.x1 = [ .1,  .1,  .1,  .6,  .6,  .6]	; 4 plots
    posL.y1 = [.75,  .4, .05, .75,  .4, .05]
    posL.x2 = [.45, .45, .45, .95, .95, .95]
    posL.y2 = [.95,  .6, .25, .95,  .6, .25]
  endif
endif


; Portrait postions
if lndscp eq 0 then begin
  if nplots eq 1 then begin
    posP.x1[0] = .55			; 1 plot
    posP.y1[0] = .05
    posP.x2[0] = .95
    posP.y2[0] = .95
  endif

  if nplots eq 2 then begin
    posP.x1 = [.05, .05, 0., 0., 0., 0.]		; 2 plots
    posP.y1 = [.55, .05, 0., 0., 0., 0.]
    posP.x2 = [.95, .95, 0., 0., 0., 0.]
    posP.y2 = [.95, .45, 0., 0., 0., 0.]
  endif

  if nplots eq 3 then begin
    posP.x1 = [.05, .55, .05, 0., 0., 0.]		; 3 plots
    posP.y1 = [.55, .55, .05, 0., 0., 0.]
    posP.x2 = [.45, .95, .45, 0., 0., 0.]
    posP.y2 = [.95, .95, .45, 0., 0., 0.]
  endif

  if nplots eq 4 then begin
    posP.x1 = [.05, .55, .05, .55, 0., 0.]		; 4 plots
    posP.y1 = [.55, .55, .05, .05, 0., 0.]
    posP.x2 = [.45, .95, .45, .95, 0., 0.]
    posP.y2 = [.95, .95, .45, .45, 0., 0.]
  endif

  if nplots eq 5 then begin
    posL.x1 = [.05, .55, .05, .55, .05, 0.]	; 4 plots
    posL.y1 = [.75, .75,  .4,  .4, .05, 0.]
    posL.x2 = [.45, .45, .45, .95, .95, 0.]
    posL.y2 = [.95, .95,  .6,  .6, .25, 0.]
  endif

  if nplots eq 6 then begin
    posL.x1 = [.05, .05, .05, .55, .55, .55]	; 4 plots
    posL.y1 = [.75,  .4, .05, .75,  .4, .05]
    posL.x2 = [.45, .45, .45, .95, .95, .95]
    posL.y2 = [.95,  .6, .25, .95,  .6, .25]
  endif
endif



end
