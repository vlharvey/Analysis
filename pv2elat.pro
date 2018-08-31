function pv2elat, pv, lon, lat, lonstep=lonstep, latstep=latstep
  ;This function computes elat from pv for waccm following Bodekers "How to calculate equivalent latitude", http://www.pa.op.dlr.de/CCMVal/HowToCalculateEqlat.pdf
  
  ;INPUT
  ;pv is potential vorticity in the dimensions pv[lon,lat]
  ;lon is the longitude (values aren't actually used, just its length)
  ;lat is the latitude including the poles
  ;lonstep is the zonal grid width (for WACCM it's 2.5deg)
  ;latstep is the meridional grid width (for WACCM it's 1.89474deg)
  
  ;RETURN
  ;elat[lon,lat] are the equivalent latitudes for pv[lon,lat]
  
  ;auto detect lonstep and latstep if omitted in call of pv2elat
  if keyword_set(lonstep) eq 0 then lonstep=(abs(lon[0:n_elements(lon)-2]-lon[1:n_elements(lon)-1]))[fix(n_elements(lon)/2)]
  if keyword_set(latstep) eq 0 then latstep=(abs(lat[0:n_elements(lat)-2]-lat[1:n_elements(lat)-1]))[fix(n_elements(lat)/2)]
  
  for ihem=0,1 do begin ; 0 is NH, 1 is SH
    case ihem of
      0:hem='NH'
      1:hem='SH'
    endcase
  
    ;restrict latitudes, find min and max of PV in the hemisphere
    if hem ne 'NH' and hem ne 'SH' then stop
    case hem of
      'SH': latindex=where(lat lt 0,nlatindex)            
      'NH': latindex=where(lat ge 0,nlatindex)
    endcase
    if nlatindex lt 2 then continue
    maxpv=max(pv[*,latindex],min=minpv)
        
    ;setup latitude bins    
    pvstep=(maxpv-minpv)/999.
    pv_values=indgen(1000)/999.*(maxpv-minpv)+minpv
    areatotal=dblarr(1000) ;total area of each PV contour
    totalarea=0d ;total area from all PV contours
    ;lonstep=2.5 & latstep=1.89474 ;those are the lonstep and latstep for 2x SD-WACCM output
    for ilon=0,n_elements(lon)-1 do begin
      for ilat=0,n_elements(latindex)-1 do begin
    
        ;determine contour the PV value is in, add area to that contour index
        case hem of
          'NH': arrayindex=fix((pv[ilon,latindex[ilat]]-minpv)/pvstep)+1
          'SH': arrayindex=fix((maxpv-pv[ilon,latindex[ilat]])/pvstep)+1
        endcase
        area=1d*!dtor*lonstep*abs(sin(!dtor*(lat[latindex[ilat]]-.5*latstep))-sin(!dtor*(lat[latindex[ilat]]+.5*latstep)))
    
        ;sum the area
        if arrayindex eq 1000 then area=0d
        totalarea+=area
        areatotal[indgen(arrayindex)]+=area
      endfor
    endfor
    
    ;normalize area to 2pi
    ;if abs(totalarea-2*!pi) gt 1e-4 then areatotal*=(2*!pi/totalarea)
    areatotal=areatotal < (2*!pi)
    areatotal*=(2d*!pi/totalarea)
    
    ;transform areas to equivalent latitudes
    case hem of
      'NH': aindex=indgen(1000)
      'SH': aindex=999-indgen(1000)
    endcase
    eqlat=57.29577951*asin(1-(areatotal[aindex]/6.283185307)) ;2*!pi=6.283185307 , 1/!dtor=57.29577951
  
    ;generate output for both hemispheres
    case hem of
      'NH':begin
            pv_elat_nh=fltarr(2,1000)
            pv_elat_nh[0,*]=eqlat
            pv_elat_nh[1,*]=pv_values
            nh_latindex=latindex
           end
      'SH':begin
            pv_elat_sh=fltarr(2,1000)
            pv_elat_sh[0,*]=eqlat
            pv_elat_sh[1,*]=pv_values
            sh_latindex=latindex
           end
    endcase
  
  endfor ;endfor of ihem loop
  
  ;interpolate to elat to pv input
  elat=fltarr(n_elements(lon),n_elements(lat))*!values.f_nan
  if keyword_set(pv_elat_nh) then begin
    for ilat=0,n_elements(nh_latindex)-1 do elat[*,nh_latindex[ilat]]=interpol(reform(pv_elat_nh[0,*]),reform(pv_elat_nh[1,*]),reform(pv[*,nh_latindex[ilat]]))
  end
  if keyword_set(pv_elat_sh) then begin
    for ilat=0,n_elements(sh_latindex)-1 do elat[*,sh_latindex[ilat]]=interpol(reform(pv_elat_sh[0,*]),reform(pv_elat_sh[1,*]),reform(pv[*,sh_latindex[ilat]]))
  end
  
  return,elat
end