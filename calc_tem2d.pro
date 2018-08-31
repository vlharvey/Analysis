;--------------------------------------------------------------------------
pro calc_tem2d, lat, ilev, pzero, vbar, wbar, thbar, v1th1, vstar, wstar
;--------------------------------------------------------------------------

; set some constants 

  H  = 7.0e3		; scale height
  ae = 6.37e6		; Earth's radius
  g  = 9.8		; gravity

  ny = n_elements(lat)
  nz = n_elements(ilev)	; TEM quantities are defined on ilev

  latr = lat * !dtor
  coslat = cos(latr)
  sinlat = sin(latr)

  P0 = pzero/100.
  zp = H * alog(P0/ilev)	; TEM quantities are defined on ilev
  rho = P0/(g*H) * exp(-zp/H)

  res = min(abs(zp -   5.e3), k2)
  res = min(abs(zp - 135.e3), k1)

  print, ilev(k2), ilev(k1)

; compute d(thbar)/dz

  thbar_z = fltarr(ny,nz)
  for j = 0, ny-1 do begin
    thbar_z(j,k1:k2) = deriv(zp(k1:k2), thbar(j,k1:k2))
  endfor

; compute TEM velocities

  vstar = fltarr(ny,nz)
  d1z  = fltarr(nz)
  for j = 0, ny-1 do begin
    d1z(k1:k2) = deriv(zp(k1:k2), rho*v1th1(j,k1:k2)/thbar_z(j,k1:k2))
    for k = k1, k2 do begin
       vstar(j,k) = vbar(j,k) - d1z(k)/rho(k) 
    endfor
  endfor

  wstar = fltarr(ny,nz)
  d1y = fltarr(ny)
  d2y = fltarr(ny)
  for k = k1, k2 do begin
     d1y(*) = deriv(latr(*), coslat*v1th1(*,k)/thbar_z(*,k))
     d2y(*) = deriv(latr(*), d1y(*))
     for j = 1, ny-2 do begin
        wstar(j,k) = wbar(j,k) + d1y(j)/(ae*coslat(j)) 
     endfor
     wstar(0,k) = wbar(0,k) - 1./(ae*sinlat(0)) * d2y(0)
     wstar(ny-1,k) = wbar(ny-1,k) - 1./(ae*sinlat(ny-1)) * d2y(ny-1)
  endfor
        
  return
end
