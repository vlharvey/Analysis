pro colbar,caption,scl,xloc1,chsize=chsize,levels=levels2,$
   normal=normal,prlabels=prlabels2,colors=colors,nobox=nobox,$
   ticklen=ticklen,nticks=nticks,capsize=capsize,rhs=rhs,bottom=bottom,$
   format=format,lhs=lhs,top=top,caploc=caploc,zero=zero
;+
; NAME: 
;    colbar
; PURPOSE:
;    generates  a color bar with labels and caption
;
;    This routine is different from tgcolbar, but uses nearly the same
;    call sequence thus the user can simply delete the "tg" in front of tgcolbar
;    to use this routine. 
;
;    The main difference between this routine and tgcolbar
;    is that by specifying the levels
;    the colorbar will show the individual colors for those levels which can
;    be labeled. This makes the routine compatible with contour,/fill,levels=levels
;    calls. This routine also has no internal tg calls.
;    There are also a number of new or simplifying features:
;      (1) uses device independent normalized coordiantes
;      (2) use of /rhs, lhs, /top, /bottom keywords for default positioning
;      (3) control of contour level colors
;      (4) more control of labeling of color bar
;      (5) allows for irregularly spaced contour levels
;      (6) works correctly with !p.multi
;  
;    ** example
;    put a color scale on the rhs of a contour plot where the contour levels are = levels
;
;    set_viewport,.2,.8,.2,.8 ; make some room on rhs
;    contour,my_data,levels=levels,/fill
;    colbar,'my data',levels=levels,/rhs
;
;    note that the levels command will override scl
;
; CATEGORY:  
;  graphics color
; CALLING SEQUENCE:
;   colbar,caption,scl,xloc1
; INPUTS:
;   - all inputs are optional but either the levels array or scl must be
;     specifed
; OPTIONAL INPUTS:
;      caption = label string for the color bar (optional)
;      scl = min and max data values to be labeled (optional)
;      xloc1 = location vector: xloc1(0) = x-origin (optional)
;                               xloc1(1) = y-origin
;                               xloc1(2) = x-width
;                               xloc1(3) = y-width
;      for compatibility with tgcolbar x-range is 0-639, yrange 0-479
;
;      Use the /normal keyword for x-range 0-1, yrange 0-1
;      ** note if the max(scl) <=1, colbar assumes you want to use normalized coords
;         but forgot to use /normal
; KEYWORD PARTAMETERS:
;   (alphabetically)
;   bottom = default position of the colorbar on the bottom 
;       (overrides xloc /normal set, uses !p.position, may cover a subtitle)  
;   capsize = caption size, default is chsize or 1.0
;   caploc = normalized distance the caption is from the colorbar
;           if caploc is negative this distance is on the other side of
;           the colorbar. Default is caption is on rhs of vertical bar
;           caption is below horizontal bar.
;   chsize = size of the numeric characters - default is 1.0
;   colors = [min color index, max color index]. default is [0,maxcolor]
;   format = the string used to format numeric labels on the color bar, normally 
;     the idl routine str is used
;   levels = array values for colors ; specifying levels overrides scl
;   lhs= position of the colorbar centered on the left hand side (overrides xloc
;        uses !x.window and !y.window). You may have to move the rhs of the plot to see the
;   nticks = number of ticks to put along the long side of the bar
;   nobox = don't draw boxes around color fields when levels is specified
;   normal = coordinates are normalized
;   prlabels = either a keyword or and array
;       if set as a keyword, prlabels will print all the contour level labels
;        ** note if scl is used and levels is not used, prlabels will print
;           the same number of labels as the number of colors in the colortable
;       if set as an array
;       prlabels must be the same length as levels with values = 0 or nonzero
;         to indicate whether a label is 
;         going to be printed next to the color cell, 0 means no print
;         default (not specified) is to print the first and last label
;   rhs= position of the colorbar centered on the right hand side. You may have to move the rhs of the plot to see the
;        colorbar since idl puts the right axis close to the edge.
;   ticklen = the length of the tick marks along the long side of the colorbar
;     if normal is set then ticklen is fraction of the width of the bar
;     if not normal then ticklen is in pixel units
;   top = position of the colorbar on the top as wide as the graph
;       (overrides xloc /normal set, uses !p.position)
;   zero =  add a label at the zero point, /zero  
; OUTPUTS:
;   none
; COMMON BLOCKS:
;   none
; SIDE EFFECTS:
; REQUIRED ROUTINES:
;   str, if format is not used
;  mrs 9/13/97
;- 
; add an extra level at the origin
if n_elements(levels2) gt 0 then begin 
   nl=n_elements(levels2)
   levels=[2.*levels2(0)-levels2(1),levels2]
   endif
if n_elements(prlabels2) gt 1 then prlabels=[0,prlabels2]
if n_elements(prlabefls2) eq 1  then prlabels=prlabels2
; set some defaults
size_df=1.

; somebody probably forgot to use /normal keyword but meant to use it

if n_elements(xloc1) gt 0 then if max(xloc1) le 1. then normal=1 

; set color range

maxcol=!d.n_colors

cmax=210
if maxcol gt cmax then maxcol=cmax
if n_elements(colors) eq 0 then colors=[0,maxcol-1]

ncolors=colors(1)-colors(0)+1

; first decide if this is a continuous system or quantized colors

if n_elements(levels) eq 0 then begin ; continuous system so define levels
    levels=findgen(ncolors)*(scl(1)-scl(0))/(ncolors-1) +scl(0)
    nobox=1
    endif

if n_elements(scl) eq 0 then scl=[min(levels),max(levels)]

    nc = n_elements(levels)

; locate the colorbar position

if n_elements(xloc1) gt 0 then begin  ; color bar specified by itself
   xloc=float(xloc1)
   endif else begin ; color bar location is relative to a plot

   xwin=!x.window  ; find out where the plot is
   ywin=!y.window
   posit=[xwin(0),ywin(0),xwin(1),ywin(1)]
   if posit(2)-posit(0) lt .4 then size_df=.6 
   if posit(2)-posit(0) lt .2 then size_df=.4 
   normal=1

; identify places for colorbar

        if keyword_set(lhs) then begin
   	  xloc=fltarr(4)  
   	  xloc(0)=posit(0)-0.12
  	  xloc(1)=posit(1)
  	  xloc(2)=0.02
   	  xloc(3)=posit(3)-posit(1)
   	endif

	if keyword_set(rhs) then begin
	   xloc=fltarr(4)  
 	  xloc(0)=posit(2)+.01
 	  xloc(1)=posit(1)
 	  xloc(2)=0.02
	  xloc(3)=posit(3)-posit(1)
	  endif

	if keyword_set(bottom) then begin
  	  xloc=fltarr(4)  
 	  xloc(1)=posit(1)-0.14
 	  xloc(0)=posit(0)
 	  xloc(3)=0.02
	   xloc(2)=posit(2)-posit(0)
	   endif

	if keyword_set(top) then begin
	   xloc=fltarr(4)  
	   xloc(1)=posit(3)+0.15
	   xloc(0)=posit(0)
	   xloc(3)=0.02
	   xloc(2)=posit(2)-posit(0)
	   caploc=-0.02
	   endif
	   
	   endelse

  if not keyword_set(normal) then begin  ; normalize coordinates
     xloc(0)=xloc(0)/640.
     xloc(2)=xloc(2)/640.
     xloc(1)=xloc(1)/480.
     xloc(3)=xloc(3)/480.
      endif

if n_elements(chsize) eq 0 then size=size_df else size=chsize

; prlabels is a tag that determines whether a label is printed
    
if n_elements(prlabels) eq 1 then prlabels=levels*0+1   

if n_elements(prlabels) eq 0 then begin
   prlabels=intarr(nc)
   prlabels(1)=1
   prlabels(nc-1)=1
   endif

if keyword_set(zero) then begin
   n=where(levels eq 0)
   if n(0) ge 0 then prlabels(n(0))=1
   
   endif

xorigin=xloc(0)
yorigin=xloc(1)
xwidth =xloc(2)
ywidth =xloc(3)

; generate boxes nc+1 boxes that we fill with color

if xwidth gt ywidth then begin 
; horizontal color bar
  xs=xwidth/(nc)
  ys=ywidth
  xd=xs
  yd=0
  orient=270.
  endif else begin
; vertical color bar
  ys=ywidth/(nc)
  xs=xwidth
  xd=0
  yd=ys
  orient=0.
  endelse

xbox=[0,0,xs,xs,0]
ybox=[0,ys,ys,0,0]
xtriv=[0,xs*.5,xs,0]
ytriv=[0,ys,0,0]
xtriv2=[0,xs*.5,xs,0]
ytriv2=[ys,0,ys,ys]
xtrih=[0,0,xs,0]
ytrih=[0,ys,ys*.5,0]
xtrih2=[0,xs,xs,0]
ytrih2=[0.5*ys,0,ys,0.5*ys]
offset=0

; set up the color table

colorarr=intarr(nc)
colorarr(0)=colors(0)
dl=float(colors(1)-colors(0))/float(nc-3)
colorarr(nc-1)= min([255,colors(1)+dl])
for j=1,nc-2 do begin
        colorarr(j)=dl*(j-1)+colors(0)
        endfor
	
; now draw the colorbar

for j=0,nc-1 do begin

; draw boxes

	xbox1=(xbox+xd*j+xorigin)
	ybox1=(ybox+yd*j+yorigin)
   if nc le 30 then begin
; draw triangle at the top
       if j eq nc-1 then begin
       if xwidth gt ywidth then begin 
         xbox1=xtrih+xd*j+xorigin
         ybox1=ytrih+yd*j+yorigin
         endif else begin  
         xbox1=xtriv+xd*j+xorigin
         ybox1=ytriv+yd*j+yorigin
         endelse
        endif
       if j eq 0 then begin
; draw triangle at the bottom
       if xwidth gt ywidth then begin 
         xbox1=xtrih2+xorigin
         ybox1=ytrih2+yorigin
         endif else begin  
         xbox1=xtriv2+xorigin
         ybox1=ytriv2+yorigin
         endelse
        endif
      endif

        polyfill,xbox1,ybox1,color=colorarr(j),/normal
	if not keyword_set(nobox) then plots,xbox1,ybox1,/normal

;  add numeric labels
  
   if prlabels(j) gt 0 then begin
;   if j eq 0 then goto,skipthis
    if n_elements(format) eq 0 then strng=str(levels(j)) else $
                strng=string(format=format,levels(j))
    if xwidth gt ywidth then begin ; get the width of a character
       xyouts,0,0,' ',/normal,orien=orient,charsize=-size,width=scw 
       scw=abs(scw)
       xyouts,xbox1(0),ybox1(0)-scw,strng,/normal,orien=orient,charsize=size,width=width
       offset=max([offset,width])
       endif else begin
       xyouts,0,0,' ',/normal,orien=orient,charsize=-size,width=scw
       scw=abs(scw)
       xyouts,xbox1(2)+scw,ybox1(0),strng,/normal,orien=orient,charsize=size,width=width
       offset=max([offset,width])
       endelse
      endif
   skipthis: 
	endfor

; draw a box around the entire bar

   if nc gt 30 then begin

   plots,[xorigin,xorigin,xorigin+xwidth,xorigin+xwidth,xorigin], $
            [yorigin,yorigin+ywidth,yorigin+ywidth,yorigin,yorigin],/normal
endif else begin

       if xwidth gt ywidth then begin 
      xdb=[xorigin+xs,xorigin,xorigin+xs,xorigin+xwidth-xs,xorigin+xwidth,xorigin+xwidth-xs,xorigin+xs]
      ydb=[yorigin,yorigin+ys*0.5,yorigin+ywidth,yorigin+ywidth,yorigin+ywidth*.5,yorigin,yorigin]
      plots,xdb,ydb,/normal

       endif else begin
      xdb=[xorigin,xorigin,xorigin+xwidth*.5,xorigin+xwidth,xorigin+xwidth,xorigin+xwidth*0.5,xorigin]
      ydb=[yorigin+ys,yorigin+ywidth-ys,yorigin+ywidth,yorigin+ywidth-ys,yorigin+ys,yorigin,yorigin+ys]
      plots,xdb,ydb,/normal

       endelse
endelse   

; draw tick marks
    if n_elements(nticks) gt 0 then begin  
    if xwidth gt ywidth then begin
      ; horizontal bar
      if n_elements(ticklen) eq 0 then ticklen1=ywidth*.2 else ticklen1=ticklen*ywidth
      if not keyword_set(normal) and n_elements(ticklen) gt 0 then ticklen1=ticklen/480.
      ytickloc0=fltarr(nticks)+yorigin 
      ytickloc1=fltarr(nticks)+yorigin+ticklen1
      xtickloc0=(findgen(nticks)+1)*xwidth/nticks+xorigin
      xtickloc1=xtickloc0
      for j=0,nticks-1 do plots,[xtickloc0(j),xtickloc1(j)],[ytickloc0(j),ytickloc1(j)],/normal
     endif else begin
      ; vertical bar
      if n_elements(ticklen) eq 0 then ticklen1=xwidth*.2  else ticklen1=ticklen*xwidth
      if not keyword_set(normal) and n_elements(ticklen) gt 0 then ticklen1=ticklen/640.
      xtickloc0=fltarr(nticks)+xorigin+xwidth 
      xtickloc1=fltarr(nticks)+xorigin+xwidth-ticklen1
      ytickloc0=(findgen(nticks)+1)*ywidth/nticks+yorigin
      ytickloc1=ytickloc0
      for j=0,nticks-1 do plots,[xtickloc0(j),xtickloc1(j)],[ytickloc0(j),ytickloc1(j)],/normal
     endelse

     endif ; end of tick stuff

; draw zero tick mark

    if keyword_set(zero) then begin 
       nzticks=n_elements(levels)
       n=where(levels eq 0) 
       if n(0) lt 0 then begin
          print,'From colbar - no zero level value'
          goto,xx
          endif
       j=n(0)
    if xwidth gt ywidth then begin
      ; horizontal bar
      if n_elements(ticklen) eq 0 then ticklen1=ywidth*.2 else ticklen1=ticklen*ywidth
      if not keyword_set(normal) and n_elements(ticklen) gt 0 then ticklen1=ticklen/480.
      ytickloc0=fltarr(nzticks)+yorigin 
      ytickloc1=fltarr(nzticks)+yorigin+ticklen1
      xtickloc0=(findgen(nzticks)+1)*xwidth/nzticks+xorigin
      xtickloc1=xtickloc0
      plots,[xtickloc0(j),xtickloc1(j)],[ytickloc0(j),ytickloc1(j)],/normal
     endif else begin
      ; vertical bar
      if n_elements(ticklen) eq 0 then ticklen1=xwidth*.2  else ticklen1=ticklen*xwidth
      if not keyword_set(normal) and n_elements(ticklen) gt 0 then ticklen1=ticklen/640.
      xtickloc0=fltarr(nzticks)+xorigin+xwidth 
      xtickloc1=fltarr(nzticks)+xorigin+xwidth-ticklen1
      ytickloc0=(findgen(nzticks)+1)*ywidth/nzticks+yorigin
      ytickloc1=ytickloc0
      plots,[xtickloc0(j),xtickloc1(j)],[ytickloc0(j),ytickloc1(j)],/normal
     endelse

     endif ; end of zero tick stuff
     xx:
    
; draw the caption
  n=where(prlabels ne 0)
 if n_elements(n) lt 3 then offset=0 ; if there are only end labels tighten up the caption
 if n_elements(caption) gt 0 then begin
 if n_elements(capsize) eq 0 then capsize=size
  if xwidth gt ywidth then begin
        if n_elements(caploc) eq 0 then caploc=offset+4.5*scw
        if caploc lt 0 then caploc=caploc-ywidth
        xyouts,xorigin+xwidth/2.,yorigin-caploc,align=0.5,caption,/normal,orien=0,size=capsize
        endif else begin
        if n_elements(caploc) eq 0 then caploc=xs+offset+3*scw        
        xyouts,xorigin+caploc,yorigin+ywidth/2.,caption,/normal,orien=90,size=capsize,align=0.5
        endelse
 endif  
return
end
  
