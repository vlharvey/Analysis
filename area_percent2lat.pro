;
; print the latitude associated with 10, 20, 30% of the hemispheric area
;
PI2=6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
nc=360
nr=91
alon=findgen(nc)
alat=findgen(nr)
x2d=fltarr(nc,nr)
y2d=fltarr(nc,nr)
for i=0,nc-1 do y2d(i,*)=alat
for j=0,nr-1 do x2d(*,j)=alon
area=0.*y2d
deltax=alon(1)-alon(0)
deltay=alat(1)-alat(0)
for j=0,nr-1 do begin
    hy=re*deltay*dtr
    dx=re*cos(alat(j)*dtr)*deltax*dtr
    area(*,j)=dx*hy    ; area of each grid point
endfor
for j=0,nr-1 do begin
    index=where(y2d gt alat(j))
    print,alat(j),100.*total(area(index))/hem_area
endfor
end
