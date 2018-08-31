;--------------------------------------------------------------------------
pro calc_tem, fname, lat, ilev, vstar, wstar, date
;--------------------------------------------------------------------------

  rd_tem, fname, tem_data

  nz = n_elements(tem_data.ilev)
  ny = n_elements(tem_data.lat)
  nt = n_elements(tem_data.date)

  vstar = fltarr(ny,nz,nt)
  wstar = fltarr(ny,nz,nt)

  lat = tem_data.lat
  ilev = tem_data.ilev
  date = tem_data.date

  p0 = tem_data.p0

  ; tem_data.v2d

  for imon = 0, nt -1 do begin

    vbar = transpose(tem_data.v2d(*,*,imon)) 
    wbar = transpose(tem_data.w2d(*,*,imon)) 
    thbar = transpose(tem_data.th2d(*,*,imon)) 
    v1th1 = transpose(tem_data.vth2d(*,*,imon)) 

    print, tem_data.date(imon)

    calc_tem2d, lat, ilev, p0, vbar, wbar, thbar, v1th1, vstar1, wstar1

    vstar(*,*,imon) = vstar1
    wstar(*,*,imon) = wstar1

  endfor

  return

end
