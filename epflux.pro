pro epflux,up,vp,wp,tp,zp,rbar,lat,dudy,dudz,stab,nx,ny,nz,$
    epy1,epy2,epz1,epz2,eptndy,eptndz,eptnd
  ;; This a modified version of EPflux and forcing calculator, without the
  ;; normalization for the EPflux vectors.
  ;; Hanli Liu, 7/99
  ;; Revised: Katelynn Greer July 2011
    
  ;Notes: Everything is calculated on pressure surfaces, a la "Middle Atm Dynamics" by Andrews, Holton & Leovy
    
    
  ar = 6370000.                   ;radius of the Earth
  d2r = !pi/180.   ; degree to radian
  d2y = 1./360.*2.*!pi*6370000.  ; latitude degee to meridional distance
  fcor = 2.*2.*!pi/86400.*sin(lat*d2r)  ;Coriolis force
  fcor1 = fltarr(ny,nz)
  for l = 0,nz-1 do begin
    fcor1(*,l)=fcor
  endfor
  
  epy = fltarr(ny,nz)         ;y component of EP-flux
  epy1 = epy                  ;term 1 of y component of EP-flux
  epy2 = epy                  ;term 2 of y component of EP-flux
  epz = epy                   ;z component of EP-flux
  epz1 = epy                  ;term 1 of z component of EP-flux
  epz2 = epy                  ;term 2 of z component of EP-flux
  epfy = epy
  epfz = epy
  epf = epy
  vt = epy                    ;meriodional heat flux
  
  ;; epy1 = (-u'v'), epz1=(-u'w'), vt = (v'T')
  for j = 0,ny-1 do begin
    for l = 0,nz-1 do begin
      epy1(j,l) = -total(up(*,j,l*vp(*,j,l)))/nx $
        *rbar(j,l)*ar*cos(lat(j)*d2r) $
        *2.*!Pi*ar*cos(lat(j)*d2r)   ; longitude integration
        
      epz1(j,l) = -total(up(*,j,l)*wp(*,j,l))/nx $
        *rbar(j,l)*ar*cos(lat(j)*d2r) $
        *2.*!Pi*ar*cos(lat(j)*d2r)
        
      vt(j,l) = total(vp(*,j,l)*tp(*,j,l))/nx
    endfor
  endfor
  
  for j = 0,ny-1 do begin
    for l = 0,nz-1 do begin
      epy2(j,l) = vt(j,l)/stab(j,l)*dudz(j,l) $
        *rbar(j,l)*ar*cos(lat(j)*d2r) $
        *2.*!Pi*ar*cos(lat(j)*d2r)

      epz2(j,l) = -(dudy(j,l)-fcor(j))*vt(j,l)/stab(j,l) $
        *rbar(j,l)*ar*cos(lat(j)*d2r) $
        *2.*!Pi*ar*cos(lat(j)*d2r)
    endfor
  endfor
  
  epy = epy1+epy2
  epz = epz1+epz2
  
  for l = 1,nz-2 do begin
    epfz(*,l) = (epz(*,l+1)-epz(*,l-1)) $
      /(zp(*,l+1)-zp(*,l-1))
  ;                /(rbar(*,l,itime)*ar*cos(lat*d2r))
  endfor
  epfz(*,0) = 2.*epfz(*,1)-epfz(*,2)
  epfz(*,nz-1) = 2.*epfz(*,nz-2)-epfz(*,nz-3)
  
  ;for j = 1,ny-2 do begin
  ;  for ic = 0,ncomp-1 do begin
  ;    epfy(j,*,ic) = (epy(j+1,*,ic)*cos(lat(j+1)*d2r)- $
  ;                 epy(j-1,*,ic)*cos(lat(j-1)*d2r)) $
  ;                /((lat(j+1)-lat(j-1))*d2y)/(cos(lat(j)*d2r))
  ;;                /(rbar(j,*)*ar)
  ;  endfor
  ;endfor
  for j = 1,ny-2 do begin
    epfy(j,*) = (epy(j+1,*)-epy(j-1,*)) $
      /((lat(j+1)-lat(j-1))*d2y)
      
  endfor
  
  epfy(0,*) = 1.5*epfy(1,*)-.5*epfy(2,*)
  epfy(ny-1,*) = 1.5*epfy(ny-2,*)-0.5*epfy(ny-3,*)
  
  epf = epfy+epfz
  eptndy = epfy       ;meridional EP-flux tendency, divergence
  eptndz = epfz       ;vertical EP-flux tendency, divergence
  for j = 0,ny-1 do begin
    for l = 0,nz-1 do begin
      eptndy(j,l) = epfy(j,l)/rbar(j,l)/(ar*cos(lat(j)*d2r))^2 $
        /2./!pi*86400.
      eptndz(j,l) = epfz(j,l)/rbar(j,l)/(ar*cos(lat(j)*d2r))^2 $
        /2./!pi*86400.
    endfor
  endfor
  eptnd = eptndy+eptndz     ;total EP-flux tendency, divergence
  
  return
end
