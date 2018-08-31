;
; this code determines the orientation of points wrt due north
;
PI2 = 6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
OMEGA=7.292E-5

lat0=48.99000
lon0=246.4400
lat1=48.79000
lon1=246.3330

; determine distance between two points

DY=RADEA*(lat0-lat1)*DTR
latm=(lat0+lat1)/2.
DX=RADEA*COS(latm*DTR)*(lon0-lon1)*dtr
stlat=lat0
stlon=lon0
range=sqrt(dx*dx+dy*dy)/1000.	; get into KM
print,range
npts=360L
start_bear=0.
lons=abs(float(stlon))
ccw = 1.0
bearing=ccw * double(360.*findgen(npts)/npts) + start_bear

latp=fltarr(npts)
lonp=fltarr(npts)

; ** radius of the earth, radians

re=40000./2./!pi
rad=double(180./!pi)

; ** c is great circle angle between st and our points

case stlat of
     90: begin
         sina=1.0e-10
         cosa=sqrt(1.-sina^2)
     end
     -90: begin
          sina=1.0e-10
          cosa=-1.0*sqrt(1.-sina^2)
     end
else: begin
      a=(90.-stlat)/rad
      sina=sin(a)
      cosa=cos(a)
      end
endcase

BB=bearing/rad
c=range/re
sinc=sin(c)
cosc=cos(c)
cosBB=cos(BB)
sinBB=sin(BB)
cosb=cosa*cosc+sina*sinc*cosBB
b=acos(cosb)
sinb=sin(b)
latp=90.-b*rad
sinAA = sina * sinBB /sinb
cosAA = (cosa-cosc*cosb) /sinc /sinb
sinCC = sinc * sinBB /sinb
cosCC = - cosAA * cosBB + sinAA * sinBB * cosc
lonp= atan(sinCC,cosCC) * rad + lons

plot,lonp,latp,psym=3,xrange=[min(lonp),max(lonp)],$
     yrange=[min(latp),max(latp)]
oplot,[lon0,lon0],[lat0,lat0],psym=2
oplot,[lon1,lon1],[lat1,lat1],psym=2
xdiff=abs(lonp-lon1)
ydiff=abs(latp-lat1)
index=where(xdiff+ydiff eq min(xdiff+ydiff))
print,bearing(index)

end
