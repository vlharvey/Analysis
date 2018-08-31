lon=findgen(361)
lat=-90+findgen(181)
nlon=n_elements(lon)         ; regularly-gridded latitude (degrees)
nlat=n_elements(lat)         ; regularly-gridded longitude (degrees)
area=FltArr(nlon,nlat)
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd

y2d=fltarr(nlon,nlat)
for i=0,nlon-1 do y2d(i,*)=lat

deltax=lon(1)-lon(0)
deltay=lat(1)-lat(0)
for j=0,nlat-1 do begin
    hy=re*deltay*dtr
    dx=re*cos(lat(j)*dtr)*deltax*dtr
    area(*,j)=dx*hy    ; area of each grid point
endfor

end
