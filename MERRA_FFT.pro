restore, '/atmos/harvey/MERRA2_data/Datfiles/MERRA2-on-WACCM_composite-day.sav
np = n_elements(pressure)
diurnal_power = fltarr(nc,nr,np)
semidiurnal_power = fltarr(nc,nr,np)
for ilat = 0, nr - 1l do begin
	for ilon = 0, nc - 1l do begin
		for ilev = 0, np - 1L do begin
			x=fft(reform(qavg[*,ilon,ilat,ilev]))
			diurnal_power[ilon,ilat,ilev] = abs(x[1])
			semidiurnal_power[ilon,ilat,ilev] = abs(x[2])
		endfor
	endfor
endfor

  level1 = findgen(21)
   nlvls  = n_elements(level1)
   col1 = (1 + indgen(nlvls)) * 250. / nlvls ; define colors

	map_set, 0,0,0,/contin,/grid,/noerase
	contour, smooth(semidiurnal_power[*,*,10],5,/edge_truncate),alon,alat,levels = level1,/follow,/cell_fill, c_color = col1,/overplot

	map_set, 0,0,0,/contin,/grid,/noerase



end