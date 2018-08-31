pro readl3omi,file_name,lon,lat,o3,o3p

; open file
; file_name = 'OMI-Aura_L3-OMTO3e_2005m1214_v002-2006m0929t143855.he5'
  file_id = H5F_OPEN(file_name)

  datafield_name = '/HDFEOS/GRIDS/ColumnAmountO3/Data Fields/ColumnAmountO3'
  data_id = H5D_OPEN(file_id,datafield_name)

  dataspace_id = H5D_GET_SPACE(data_id)
  Dims = H5S_GET_SIMPLE_EXTENT_DIMS(dataspace_id)
  Dims = float(Dims)

; Convert data type for division operator
  lon_dims = Dims(0)
  lat_dims = Dims(1)

  o3 = H5D_READ(data_id)

; Get units
  units_id = H5A_OPEN_NAME(data_id, 'Units')
  units = H5A_READ(units_id)

; Get missing value
  missingvalue_id = H5A_OPEN_NAME(data_id,'MissingValue')
  missingvalue = H5A_READ(missingvalue_id)

; Convert data type
  o3 = float(o3)
  missingvaluef = float(missingvalue(0))

  H5A_Close, missingvalue_id
  H5D_Close, data_id

; Process missing value, convert dataf that are equal to missingvaluef to NaN
  idx = where(o3 eq missingvaluef(0), cnt)
  if cnt gt 0 then o3[idx] = !Values.F_NAN

; Calculate the latitude and longitude range based on vector points and lat/lon step
  lat = (FINDGEN(long(lat_dims))*(180.0/lat_dims))-90
  lon = FINDGEN(long(lon_dims))*(360.0/lon_dims)-180
;
; column ozone precision
;
  datafield_name = '/HDFEOS/GRIDS/ColumnAmountO3/Data Fields/ColumnAmountO3Precision'
  data_id = H5D_OPEN(file_id,datafield_name)

  o3p = H5D_READ(data_id)

; Get units
  units_id = H5A_OPEN_NAME(data_id, 'Units')
  units = H5A_READ(units_id)

; Get missing value
  missingvalue_id = H5A_OPEN_NAME(data_id,'MissingValue')
  missingvalue = H5A_READ(missingvalue_id)

; Convert data type
  o3p = float(o3p)
  missingvaluef = float(missingvalue(0))

  H5A_Close, missingvalue_id
  H5D_Close, data_id

; Process missing value, convert o3p that are equal to missingvaluef to NaN
  idx = where(o3p eq missingvaluef(0), cnt)
  if cnt gt 0 then o3p[idx] = !Values.F_NAN

  return
end
