;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Convert geopotential height to geometric height
;
; GGRD is 3D grid of geopotential height with dimensions (nr,nc,nz) 
;      where nr=number of latitudes, nc=number of longitudes, nz=number of levels
; ZGRD is corresponding 3D grid of geometric height
; ALAT is 1D array of latitudes
;
; VLH 06/28/2010
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; define constants
;
rtd=double(180./!pi)
dtr=1./rtd
ks=1.931853d-3
ecc=0.081819
gamma45=9.80
;
; convert geopotential to geometric height
;
for k=0L,nz-1L do begin
    for j=0L,nr-1L do begin
        sin2=sin( (alat(j)*dtr)^2.0 )
        numerator=1.0+ks*sin2
        denominator=sqrt( 1.0 - (ecc^2.0)*sin2 )
        gammas=gamma45*(numerator/denominator)
        r=6378.137/(1.006803-(0.006706*sin2))
        zgrd(j,*,k)=(r*ggrd(j,*,k))/ ( (gammas/gamma45)*r - ggrd(j,*,k) )
    endfor	; loop over latitudes
endfor		; loop over altitudes
end
