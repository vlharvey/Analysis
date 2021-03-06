pro marker_lows_pv_v9,sf,mark,qdf,zeta,u,v,x,y,theta,sfval
;
; version 9
; mark contour associated with maximum horizontal gradient in that distribution (PV or CO)
; sf=co
; qdf=gradient
;
; version 8 
; take out most unnecessary logic
; set equatorward bound to be 15 degrees and call it a day
; of nodes in Q that do not touch 15 degrees and have cyclonic zeta
; choose max integrated wind speed
;
; version 7
; do not have poleward bound of 65 N
; use wind speed and not U to capture when the polar vortex is so displaced
; from the pole so as the polar night does not encircle the pole. (and U is
; negative during a long part of the line integral.
;
; version 6
; If integrated QDF about a SF isopleth is negative it is a candidate
; to represent the edge of cyclones.  Of these candidate isopleths the
; one with the largest integrated wind speed is chosen.  Only the entire
; hemisphere is examined and "sub-vortices" are allowed.
; small tropical sf values requires a minimum latitude criteria when "filling"

nbins=20
nr=n_elements(y)
nc=n_elements(x)
dx=x(1)-x(0)
dy=y(1)-y(0)
lon=0.*sf
lat=0.*sf
for i=0,n_elements(x)-1 do lat(i,*)=y
for j=0,n_elements(y)-1 do lon(*,j)=x
speed=sqrt(u^2+v^2)
avgq_vs_sf=-999.+0.*fltarr(nbins)               ; average QDF per bin
avgz_vs_sf=-999.+0.*fltarr(nbins)		; average relative vorticity
avgs_vs_sf=-999.+0.*fltarr(nbins)               ; average windspeed per bin
num_vs_sf=0.*fltarr(nbins)               ; number of points in each bin (lowest number is where gradient is largest)
sfbin=0.0*fltarr(nbins)

; set NH latmin, latmax
latmin=15.
latmax=90.
if theta le 500. then latmin=40.
if theta le 400. then latmin=50.
kk=where(lat gt latmin)
sfmin=min(sf(kk))
sfmax=max(sf(kk))
sfint=(sfmax-sfmin)/(nbins)
sfbin=sfmin+sfint*findgen(nbins)

; in NH lows are positive PV values.  loop pvbin from high down so mark
; polar vortex first
sfbin=sfmax-sfint*findgen(nbins)

; loop over SF bins in NH
for n=0,nbins-2 do begin
    t=where(lat ge latmin and sf lt sfbin(n) and sf ge sfbin(n+1),it)
; check latmin.  make sure bins are resolved (do not intersect latmin)
    if (it gt 2) then begin
        if min(lat(t))-latmin le dy then begin
           avgq_vs_sf(n)=999.
           goto,jumpnhbin
        endif
        avgq_vs_sf(n)=total(qdf(t))/float(it)
        avgz_vs_sf(n)=total(zeta(t))/float(it)
        avgs_vs_sf(n)=total(speed(t))/float(it)
        num_vs_sf(n)=float(it)
    endif
    jumpnhbin:
endfor	; loop over bins
s=where(lat ge latmin and sf lt sfbin(nbins-1),is)
if is gt 2 then begin
if min(lat(s))-latmin gt dy then begin
   avgq_vs_sf(nbins-1)=total(qdf(s))/float(is)
   avgz_vs_sf(nbins-1)=total(zeta(s))/float(is)
   avgs_vs_sf(nbins-1)=total(speed(s))/float(is)
   num_vs_sf(nbins-1)=float(is)
endif
endif
index=where(avgq_vs_sf ne -999. and num_vs_sf gt 0.,nbins)
if index(0) ne -1 then begin
   avgq_vs_sf=avgq_vs_sf(index)
   avgz_vs_sf=avgz_vs_sf(index)
   avgs_vs_sf=avgs_vs_sf(index)
   num_vs_sf=num_vs_sf(index)
   sfbin=sfbin(index)
endif
if index(0) eq -1 then goto,dosh
;avgq_vs_sf=smooth(avgq_vs_sf,3,/edge_truncate)
;erase
;plot,sfbin,avgq_vs_sf,thick=3,color=0
;axis,yax=1,/data,yrange=[min(avgs_vs_sf),max(avgs_vs_sf)],/save
;oplot,sfbin,avgs_vs_sf,thick=2,color=100
;
; largest CO gradient
;
index=where(avgq_vs_sf eq max(avgq_vs_sf))
if min(num_vs_sf) ne 0. then begin
print,'MAX GRAD ',avgq_vs_sf(index),sfbin(index)
   sfval=sfbin(index(0)) 
   s=where(lat ge latmin and sf ge sfval,is)
   if is gt 2 then begin	;and min(lat(s))-latmin gt dy then begin
       mark(s)=1.0
       print,'Arctic vortex CO ',theta,min(num_vs_sf),sfval
    endif
endif
;stop

; Southern Hemisphere
dosh:
return

nbins=20
avgq_vs_sf=-999.+0.*fltarr(nbins)               ; average QDF per bin
avgs_vs_sf=-999.+0.*fltarr(nbins)               ; average windspeed per bin
avgz_vs_sf=-999.+0.*fltarr(nbins)               ; average relative vorticity per bin
sfbin=0.0*fltarr(nbins)

latmin=-90.
latmax=-15.
if theta le 500. then latmin=-40.
if theta le 400. then latmin=-50.
kk=where(lat lt latmax)
sfmin=min(sf(kk))
sfmax=max(sf(kk))
sfint=(sfmax-sfmin)/(nbins)
; in SH lows are low PV values.  
sfbin=sfmin+sfint*findgen(nbins)

; loop over SF bins in SH
for n=0,nbins-2 do begin
    t=where(lat le latmax and sf gt sfbin(n) and sf le sfbin(n+1),it)
; check latmax.  make sure bins are resolved (do not intersect latmax)
; and make sure bins are not divided by latmax
    if (it gt 2) then begin
        if abs(abs(max(lat(t)))-abs(latmax)) le dy then begin
           avgq_vs_sf(n)=999.
           goto,jumpshbin
        endif
        avgq_vs_sf(n)=total(qdf(t))/float(it)
        avgz_vs_sf(n)=total(zeta(t))/float(it)
        avgs_vs_sf(n)=total(speed(t))/float(it)
    endif
    jumpshbin:
endfor
s=where(lat le latmax and sf gt sfbin(nbins-1),is)
if is gt 2 then begin
if abs(abs(max(lat(s)))-abs(latmax)) gt dy then begin
   avgq_vs_sf(nbins-1)=total(qdf(s))/float(is)
   avgz_vs_sf(nbins-1)=total(zeta(s))/float(is)
   avgs_vs_sf(nbins-1)=total(speed(s))/float(is)
endif
endif
index=where(avgq_vs_sf ne -999.,nbins)
if index(0) ne -1 then begin
   avgq_vs_sf=avgq_vs_sf(index)
   avgz_vs_sf=avgz_vs_sf(index)
   avgs_vs_sf=avgs_vs_sf(index)
   sfbin=sfbin(index)
endif
if index(0) eq -1 then return

; interpolate SF values to where integrated QDF=0.0 y=mx+b; where y=0 x=-b/m
sfnode=0.*fltarr(nbins)
wnode=0.*fltarr(nbins)
znode=0.*fltarr(nbins)
s0=sfbin(0)
q0=avgq_vs_sf(0)
w0=avgs_vs_sf(0)
z0=avgz_vs_sf(0)
for n=1,nbins-1 do begin
    s1=sfbin(n)
    q1=avgq_vs_sf(n)
    w1=avgs_vs_sf(n)
    z1=avgz_vs_sf(n)
    if q0*q1 le 0. then begin
       if q0 ne 999. and q1 ne 999. then begin
       slope=(q0-q1)/(s0-s1)
       ycept=q0-slope*s0
       sfnode(n)=-ycept/slope           ; streamfunction at QDF node
       ss=sfnode(n)
       scale=(s0-ss)/(s0-s1)
       wnode(n)=w0+scale*(w1-w0)        ; wind speed at QDF node
       znode(n)=z0+scale*(z1-z0)        ; relative vorticity at QDF node
       endif
       if q0 eq 999. then begin
       sfnode(n)=s1
       wnode(n)=w1
       znode(n)=z1
       endif
       if q1 eq 999. then begin
       sfnode(n)=s0
       wnode(n)=w0
       znode(n)=z0
       endif
    endif
    s0=s1
    q0=q1
    w0=w1
    z0=z1
endfor

; eliminate sfnodes that get close to latmax
index=where(sfnode ne 0.,nnodes)
if index(0) ne -1 then begin
for l=0,nnodes-1 do begin
    s=where(lat le latmax and sf le sfnode(index(l)))
    if s(0) ne -1 then $
       if abs(abs(max(lat(s)))-abs(latmax)) lt dy then $
          sfnode(index(l))=0.
endfor
endif

; all cyclonic znodes
iindex=where(znode lt 0. and sfnode ne 0.)
if iindex(0) ne -1 then begin
; choose the "candidate" with largest wind speed
   jindex=where(wnode(iindex) eq max(wnode(iindex)))

   index=where(sfnode eq sfnode(iindex(jindex(0))))
   s=where(lat le latmax and sf le sfnode(index(0)),is)
   if is gt 2 and abs(abs(max(lat(s)))-abs(latmax)) gt dy then begin
      mark(s)=1.0
   endif
endif   ; cyclonic relative vorticity
return
end
