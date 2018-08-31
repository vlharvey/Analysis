
;main.pro

;Katelynn Greer
;4 March 2013

;Purpose:

nc_file_USLM = 'ukmo_feb_13_02.nc3'
filepathget = 'C:\Users\Kately\Dropbox\ARSENL\AnalysisCodes\VortexDiagnostics\CaseStudies\';
filenameget_USLM = filepathget + nc_file_USLM

;==================Retrieve .netcdf data================================================

;~~~Retrieve date
monthname = strmid(nc_file_USLM,5,3)
if monthname eq 'jan' then month=1.0
if monthname eq 'feb' then month=2.0
if monthname eq 'mar' then month=3.0
if monthname eq 'apr' then month=4.0
if monthname eq 'may' then month=5.0
if monthname eq 'jun' then month=6.0
if monthname eq 'jul' then month=7.0
if monthname eq 'aug' then month=8.0
if monthname eq 'sep' then month=9.0
if monthname eq 'oct' then month=10.0
if monthname eq 'nov' then month=11.0
if monthname eq 'dec' then month=12.0
day = float(strmid(nc_file_USLM,9,2))
yr = float(strmid(nc_file_USLM,12,2))
if yr gt 50 then year = yr+1900.0
if yr le 50 then year = yr+2000.0
Julian_date=julday(month,day,year)
caldat,Julian_date,null,null,year
doy = floor(Julian_date-julday(12,31,year-1,0,0,0))
frac_date=year+doy/365.0

cdfid = ncdf_open(filenameget_USLM)

;~~~Retrieve lat
varid = ncdf_varid(cdfid, 'latitudes')
ncdf_varget,cdfid,varid,lat
ny = n_elements(lat)

;~~~Retrieve lon
varid = ncdf_varid(cdfid, 'longitudes')
ncdf_varget,cdfid,varid,lon
nx = n_elements(lon)

;~~~Retrieve Theta levels [hPa]
varid = ncdf_varid(cdfid, 'th_levels')
ncdf_varget,cdfid,varid,theta
nz = n_elements(theta)

;~~~Retrieve Vortex Markers
varid = ncdf_varid(cdfid, 'mark')
ncdf_varget,cdfid,varid,marker_USLM0
marker_USLM = make_array(nx,ny,nz)
for k=0,nz-1 do begin
  marker_USLM(*,*,k) = transpose(marker_USLM0(*,*,k))
endfor

;~~~Retrieve Isentropic Potential Vorticity
varid = ncdf_varid(cdfid, 'ipv')
ncdf_varget,cdfid,varid,ipv_USLM0
ipv_USLM = make_array(nx,ny,nz)
for k=0,nz-1 do begin
  ipv_USLM(*,*,k) = transpose(ipv_USLM0(*,*,k))
endfor

;~~~Mass Stream Function
varid = ncdf_varid(cdfid, 'msf')
ncdf_varget,cdfid,varid,msf_USLM0
msf_USLM = make_array(nx,ny,nz)
for k=0,nz-1 do begin
  msf_USLM(*,*,k) = transpose(msf_USLM0(*,*,k))
endfor

;~~~Retrieve Pressure
varid = ncdf_varid(cdfid, 'press')
ncdf_varget,cdfid,varid,p_USLM0
p_USLM = make_array(nx,ny,nz)
for k=0,nz-1 do begin
  p_USLM(*,*,k) = transpose(p_USLM0(*,*,k))
endfor

;~~~
ncdf_close, cdfid
;=======================================================================================================

shape = vortexshape(marker_USLM, lat, lon)

;=================PLOTTING==============================================================================
cgPS_open, filename = 'C:\Users\Kately\Dropbox\ARSENL\AnalysisCodes\VortexDiagnostics\ps\VortexShape_ukmo_feb_13_02.ps',nomatch=1
loadct, 39
!p.multi = [0,2,1,0,0]

for k=0,18 do begin
theta_level = k
mark_pos_id = where(marker_USLM(*,*,theta_level) gt 0)
marker_levels = [0.0,0.999,1.000,1.001]

;IPV Levels
ipv_temp = ipv_USLM(*,*,theta_level)
max_ipv_levels = max(ipv_temp(mark_pos_id))
min_ipv_levels = min(ipv_temp(mark_pos_id))
delta_ipv_levels = (max_ipv_levels-min_ipv_levels)/31.
ipv_levels = indgen(31)*delta_ipv_levels + min_ipv_levels

lon_plot = [lon,lon(0)]
marker_USLM_plot = [[marker_USLM(*,*,theta_level),marker_USLM(0,*,theta_level)]]
ipv_USLM_plot = [[ipv_USLM(*,*,theta_level),ipv_USLM(0,*,theta_level)]]

map_set,90,0,/stereographic,/isotropic,/noborder,$
  limit=[20,-180,90,180],/advance,/noerase,title = STRING(theta(k), FORMAT='(I7.0)')
;contour,ipv_USLM_plot,lon_plot,lat,$
;  levels=ipv_levels,/cell_fill,/overplot
contour,marker_USLM_plot,lon_plot,lat,$
  levels=marker_levels,/cell_fill,c_color=[255,50,50,255],/overplot
map_grid, label=1
oplot,[shape.NHcentroid(0,theta_level)],[shape.NHcentroid(1,theta_level)],psym=1,symsize=2.0,thick=10.0,color=255
oplot,[shape.NHmajoraxisloc(0,k),shape.NHcentroid(0,k)],[shape.NHmajoraxisloc(1,k),shape.NHcentroid(1,k)],thick=10.0,color=255
oplot,[shape.NHminoraxisloc(0,k),shape.NHcentroid(0,k)],[shape.NHminoraxisloc(1,k),shape.NHcentroid(1,k)],thick=10.0,color=255

endfor

map_set,90,0,/stereographic,/isotropic,/noborder,$
  limit=[20,-180,90,180],/advance,/noerase,title = 'Centroid Loc w/ Height'
map_grid, label=1
oplot,[Shape.NHcentroid(0,0:18)],[shape.NHcentroid(1,0:18)],psym=4
oplot,[Shape.NHcentroid(0,0:18)],[shape.NHcentroid(1,0:18)]

cgPS_close

!p.multi=0


END