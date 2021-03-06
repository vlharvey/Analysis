pro drawvectors_np,mg,jg2,along,alat2,udata,vdata,maxmag,nh

;C print scale legend
; if nh eq 0 then begin
;   sina = 10./maxmag
;   cosa = 0.
;   x0=150.
;   y0=-85
;   dx = sina
;   dy = cosa
;   size = sqrt(dx*dx+dy*dy)
;   arr = .25
;   st = arr*.38268
;   ct = arr*.92387
;   x1 = x0 + dx
;   y1 = y0 + dy
;   oplot,[90,90,180],[-90,-80,-80]
;   oplot,[x0,x1],[y0,y1]
;   Oplot,[x1,x1-(ct*dx-st*dy)],[y1,y1-(ct*dy+st*dx)]
;   Oplot,[x1,x1-(ct*dx+st*dy)],[y1,y1-(ct*dy-st*dx)]
;   xyouts,95.,-87.5,'10 m/s'
; endif

;C draw vectors
;   loninc=intarr(jg2)
;   loninc(*)=2
;   if nh ne 0 then begin
;     jg=jg2/2
;     for j=0,jg-1 do begin
;       loninc(j)=mg/(2*(j+1))
;       loninc(jg2-1-j)=mg/(2*(j+1))
;     endfor
;   endif

speed=sqrt(udata^2. + vdata^2.)

    sina = udata/maxmag
    cosa = vdata/maxmag
    for j=2,jg2-3,3 do begin
      for i=0,mg-1,4 do begin
color0=(speed(i,j)/max(speed(*,jg2/2:-1)))*255.
        x0=along(i)
        y0=alat2(j)
        dx = sina(i,j)
        dy = cosa(i,j)
        if dx ge 999. then goto, clipdata
        size = sqrt(dx*dx+dy*dy)
        arr = .25
        st = arr*.38268
        ct = arr*.92387
        x1 = x0 + dx
        y1 = y0 + dy
        if y1 gt 90. then begin
           y1=90.-(y1-90.)
           x1=x1+180.
        endif
        if y1 lt -90. then begin
           y1=-90.-(y1+90.)
           x1=x1+180.
        endif
        if x1 gt 360. then x1=x1-360.
        if y0 ge 90. or y0 lt -90. then goto, jumplab
        oplot,[x0,x1],[y0,y1],color=color0,thick=11
        oplot,[x1,x1-(ct*dx-st*dy)],[y1,y1-(ct*dy+st*dx)],color=color0,thick=11
        oplot,[x1,x1-(ct*dx+st*dy)],[y1,y1-(ct*dy-st*dx)],color=color0,thick=11
jumplab:
clipdata:
      endfor
    endfor

end
