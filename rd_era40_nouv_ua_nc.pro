;         4 - Dimensions
;    initial_time0_hours         120
;    lv_ISBL1          23
;    g0_lat_2          73
;    g0_lon_3         144
;
;         6 - Global Attributes
;creation_date        (CHAR  ) [Length:  29] = Tue Aug 12 09:56:21 MDT 2008
;NCL_Version          (CHAR  ) [Length:   6] = 4.3.1
;system               (CHAR  ) [Length: 131] = Darwin MacD68.local 8.11.1 Darwin Kernel Version 8.11.1: Wed Oct 10 18:23:28 PDT 2007; root:xnu-792.25.20~1/RELEASE_I386 i386 i386
;conventions          (CHAR  ) [Length:   5] = None
;grib_source          (CHAR  ) [Length:  27] = era40_nouv_UA_19570901.grb
;title                (CHAR  ) [Length:  28] = NCL: convert-GRIB-to-netCDF
;
;         9 - Variables
;PV_GDS0_ISBL         (FLOAT ) Dimension Ids = [ 3 2 1 0 ]
;        Attribute forecast_time_units=hours
;        Attribute forecast_time=           0
;        Attribute parameter_number=          60
;        Attribute parameter_table_version=         128
;        Attribute gds_grid_type=           0
;        Attribute level_indicator=         100
;        Attribute _FillValue=     -999.000
;        Attribute units=K m**2 kg**-1 s**-1
;        Attribute long_name=Potential vorticity
;        Attribute center=European Center for Medium-Range Weather Forecasts - Reading
;Z_GDS0_ISBL          (FLOAT ) Dimension Ids = [ 3 2 1 0 ]
;        Attribute forecast_time_units=hours
;        Attribute forecast_time=           0
;        Attribute parameter_number=         129
;        Attribute parameter_table_version=         128
;        Attribute gds_grid_type=           0
;        Attribute level_indicator=         100
;        Attribute _FillValue=     -999.000
;        Attribute units=m**2 s**-2
;        Attribute long_name=Geopotential
;        Attribute center=European Center for Medium-Range Weather Forecasts - Reading
;T_GDS0_ISBL          (FLOAT ) Dimension Ids = [ 3 2 1 0 ]
;        Attribute forecast_time_units=hours
;        Attribute forecast_time=           0
;        Attribute parameter_number=         130
;        Attribute parameter_table_version=         128
;        Attribute gds_grid_type=           0
;        Attribute level_indicator=         100
;        Attribute _FillValue=     -999.000
;        Attribute units=K
;        Attribute long_name=Temperature
;        Attribute center=European Center for Medium-Range Weather Forecasts - Reading
;Q_GDS0_ISBL          (FLOAT ) Dimension Ids = [ 3 2 1 0 ]
;        Attribute forecast_time_units=hours
;        Attribute forecast_time=           0
;        Attribute parameter_number=         133
;        Attribute parameter_table_version=         128
;        Attribute gds_grid_type=           0
;        Attribute level_indicator=         100
;        Attribute _FillValue=     -999.000
;        Attribute units=kg kg**-1
;        Attribute long_name=Specific humidity
;        Attribute center=European Center for Medium-Range Weather Forecasts - Reading
;W_GDS0_ISBL          (FLOAT ) Dimension Ids = [ 3 2 1 0 ]
;        Attribute forecast_time_units=hours
;        Attribute forecast_time=           0
;        Attribute parameter_number=         135
;        Attribute parameter_table_version=         128
;        Attribute gds_grid_type=           0
;        Attribute level_indicator=         100
;        Attribute _FillValue=     -999.000
;        Attribute units=Pa s**-1
;        Attribute long_name=Vertical velocity
;        Attribute center=European Center for Medium-Range Weather Forecasts - Reading
;initial_time0_hours  (DOUBLE) Dimension Ids = [ 0 ]
;        Attribute units=hours since 1800-01-01 00:00
;        Attribute long_name=initial time
;g0_lat_2             (FLOAT ) Dimension Ids = [ 2 ]
;        Attribute La1=      90.0000
;        Attribute Lo1=      0.00000
;        Attribute La2=     -90.0000
;        Attribute Lo2=      357.500
;        Attribute Di=      2.50000
;        Attribute Dj=      2.50000
;        Attribute units=degrees_north
;        Attribute GridType=Cylindrical Equidistant Projection Grid
;        Attribute long_name=latitude
;g0_lon_3             (FLOAT ) Dimension Ids = [ 3 ]
;        Attribute La1=      90.0000
;        Attribute Lo1=      0.00000
;        Attribute La2=     -90.0000
;        Attribute Lo2=      357.500
;        Attribute Di=      2.50000
;        Attribute Dj=      2.50000
;        Attribute units=degrees_east
;        Attribute GridType=Cylindrical Equidistant Projection Grid
;        Attribute long_name=longitude
;lv_ISBL1             (LONG  ) Dimension Ids = [ 1 ]
;        Attribute units=hPa
;        Attribute long_name=isobaric level
PRO rd_era40_nouv_ua_nc, ncfile, latitude, longitude, pressure, temperature, pv, geopot, humidity, wwnd, time
	IF (file_search(ncfile))[0] EQ '' THEN print, 'File Not Found!!'
	ncid=ncdf_open(ncfile)
	NCDF_VARGET, ncid, 'PV_GDS0_ISBL', pv
	NCDF_VARGET, ncid, 'Z_GDS0_ISBL', geopot
	NCDF_VARGET, ncid, 'T_GDS0_ISBL', temperature
	NCDF_VARGET, ncid, 'Q_GDS0_ISBL', humidity
	NCDF_VARGET, ncid, 'W_GDS0_ISBL', wwnd
	NCDF_VARGET, ncid, 'initial_time0_hours', time
	NCDF_VARGET, ncid, 'g0_lat_2', latitude
	NCDF_VARGET, ncid, 'g0_lon_3', longitude
	NCDF_VARGET, ncid, 'lv_ISBL1', pressure
	ncdf_close,ncid
END