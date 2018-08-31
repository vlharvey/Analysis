n_levels = 121L
n_lon = **
n_lat = **  
dlon = 360./(n_lon - 1L)
dlat = 180./(n_lat - 1L)
mlsTempGrid = fltarr(n_lat, n_lon, n_levels)

; loop over the latitude, longitude, and altitude grid
for ii = 0L, n_lon-1L do begin
  for jj = 0L, n_lat-1L do begin
    for kk = 0L, n_levels-1L do begin
     bad = where(temperature_mask[*,kk] eq -99., nb)
     if nb gt 0. then begin
       temperature[bad,kk] = -99.
       pressure[bad,kk] = -99.
     endif
   ; bin data into 2 degree lat bins

        x = where(temperature[*,kk] gt -99. and latitude gt (-90. + dlat* (jj-0.5)) and latitude lt (-90. + dlat * (jj+0.5)),nx)
nxx = 0
if nx gt 0L then begin
       if (dlon*(ii+0.5)) le 360. and dlon*(ii-.5) ge 0. then   xx = where(longitude[x] gt dlon*(ii-0.5) and longitude[x] lt dlon*(ii+.05),nxx)
       if (dlon*(ii+0.5)) gt 360. then                          xx = where(longitude[x] gt dlon*(ii-0.5) or longitude[x] lt (dlon*(ii+0.5) - 360.),nxx)
       if dlon*(ii-0.5) lt 0. then                              xx = where(longitude[x] gt ( dlon*(ii-0.5) + 360. ) or longitude[x] lt dlon*(ii+0.5),nxx)
endif
if nxx gt 0L then begin
      mlsTempGrid[ii,jj,kk] = mean(temperature[x[xx],kk])
      mlsPressureGrid[ii,jj,kk] = mean(pressure[x[xx],kk])
endif
end
