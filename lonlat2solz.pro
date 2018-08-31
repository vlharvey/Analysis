; http://oceancolor.gsfc.nasa.gov/DOCS/idl/navigation/lonlat2solz.pro
;+NAME/ONE LINE DESCRIPTION OF ROUTINE:
;    LONLAT2SOLZ calculates the solar and sensor view angles from geodetic
;    longitude and latitude and observation time.
;
; -----------------------------------------------------------------
; pro lonlat2solz
;
; Calculates solar and sensor view angles from geodetic longitude 
; and latitude, and observation time.
;
; Inputs:
;     lon	- longitude of pixel in degrees
;     lat	- longitude of pixel in degrees
;     year      - observation year
;     day       - observation day of year
;     msec      - observation millisecs of day
;
; Outputs:
;     solz	- solar zenith angle of pixel in degrees
;     sola	- solar azimuth angle of pixel in degrees
;
; Notes:
;     Inputs can be scalar or vector, but vectors must be of
;     equal length.
;
; Written By:
;     Bryan Franz, SAIC GSC, NASA/SIMBIOS Project, April 1998.
;     (with much help from geonav.pro by Fred Patt)
;
; -----------------------------------------------------------------

pro lonlat2solz,lon,lat,year,day,msec,solz,sola

    Re = 6378.137        ; Earth radius in km
    f  = 1/298.257       ; Earth flattening factor

    l_sun,year,day,msec/1000.D0,usun

    n    = n_elements(lon)
    solz = fltarr(n)
    sola = fltarr(n)
    rmat = fltarr(3,3) ; Rotation matrix

    for i=0L,n-1 do begin

      rlon   = lon(i)*!pi/180.
      rlat   = lat(i)*!pi/180.

      ;
      ; First, we must define the axes (in ECR space) of a
      ; pixel-local coordinate system, with the z-axis along
      ; the geodetic pixel normal, x-axis pointing east, and
      ; y-axis pointing north.
      ;
      up    = [cos(rlat)*cos(rlon),cos(rlat)*sin(rlon),sin(rlat)]
      upxy  = sqrt(up(0)*up(0)+up(1)*up(1))
      ea    = [-up(1)/upxy,up(0)/upxy,0.0]
      no    = crossp(up,ea)

      ;
      ; Compute geocentric pixel location vector.
      ;
      phi   = atan(tan(rlat)*(1-f)^2)                ; geocentric latitude
      R     = Re*(1-f)/sqrt(1-(2-f)*f*(cos(phi)^2))  ; dist to Earth surface
      gvec  = R*[cos(phi)*cos(rlon),cos(phi)*sin(rlon),sin(phi)]

      ;
      ; Now we can transform Sun vectors into the local frame.
      ;
      rmat(0,*) = ea
      rmat(1,*) = no
      rmat(2,*) = up
      sunl      = rmat # usun(*,i)

      ;
      ; Compute the solar zenith and azimuth
      ;
      solz(i) = atan(sqrt(sunl(0)*sunl(0)+sunl(1)*sunl(1)),sunl(2)) * !radeg
      if (solz(i) gt 0.05) then begin
          sola(i) = atan(sunl(0),sunl(1)) * !radeg
      endif else begin
          sola(i) = 0.0
      endelse
      if (sola(i) lt 0.0) then $
          sola(i) = sola(i) + 360.0d0

    endfor

    if (n eq 1) then begin
        solz = solz(0)
        sola = sola(0)
    endif

    return
end
