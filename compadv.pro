   pro compadv,ul,vl,rhj,adv,lon,lat,nc,nr
;
; compute jacobian advection from u, v and rhj data
;
   adv=fltarr(nc,nr)
;  INITIALIZE CONSTANTS
;
      pi2 = 6.2831853071796
      dtr=pi2/360.
      radea=6.37E6
      omega=7.292E-5
;
    for j = 0, nr-1 do begin
      jp1=j+1
      jm1=j-1
      jp2=j+2
      jm2=j-2
      if (j eq 0) then begin
        jm1=0
        jm2=0
      endif
      if (j eq nr-1) then begin
        jp1=nr-1
        jp2=nr-1
      endif
      if (j eq nr-2) then jp2=nr-1
      if (j eq 1) then jm2=0
      dy1=radea*(lat(jp1)-lat(jm1))*dtr
      dy2=radea*(lat(jp2)-lat(jm2))*dtr
      dx1=radea*cos(lat(j)*dtr)*pi2/(.5*nc)
      dx2=radea*cos(lat(j)*dtr)*pi2/(.25*nc)
;
      for i = 0, nc-1 do begin
         ip1=i+1
         im1=i-1
         ip2=i+2
         im2=i-2
         if (i eq 0) then begin
           im1=nc-1
           im2=nc-1
         endif
         if (i eq nc-1) then begin
           ip1=1
           ip2=2
         endif
         if (i eq 1) then im2=nc-1
         if (i eq nc-2) then ip2=0
;
         drhjdx = (4./3.) * (rhj(ip1,j) - rhj(im1,j)) / dx1 $
              - (1./3.) * (rhj(ip2,j) - rhj(im2,j)) / dx2
         if (j le 1 or j ge nr-2) then begin
           drhjdy = (rhj(i,jp1)*cos(lat(jp1)*dtr) $
                -  rhj(i,jm1)*cos(lat(jm1)*dtr)) / dy1
         endif
         if (j gt 1 and j lt nr-2) then begin
           drhjdy = (4./3.)*(rhj(i,jp1)*cos(lat(jp1)*dtr) $
                - rhj(i,jm1)*cos(lat(jm1)*dtr)) / dy1 $
                - (1./3.)*(rhj(i,jp2)*cos(lat(jp2)*dtr) $
                - rhj(i,jm2)*cos(lat(jm2)*dtr)) / dy2
         endif
         adv(i,j) = ul(i,j)*drhjdx+vl(i,j)*drhjdy
      endfor
   endfor
   return
   end
