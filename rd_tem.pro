;--------------------------------------------------------------------------
pro rd_tem, fname, tem_data
;--------------------------------------------------------------------------

    print, 'opening ' + fname

    ncid = ncdf_open(fname)

; extract waccm fields

    ncdf_varget, ncid, 'P0',      P0
    ncdf_varget, ncid, 'lat',     lat
    ncdf_varget, ncid, 'lev',     lev
    ncdf_varget, ncid, 'ilev',    ilev
    ncdf_varget, ncid, 'time',    time
    ncdf_varget, ncid, 'date',    date
    ncdf_varget, ncid, 'datesec', datesec

    ncdf_varget, ncid, 'V2d',     v2d
    ncdf_varget, ncid, 'W2d',     w2d
    ncdf_varget, ncid, 'TH2d',    th2d
    ncdf_varget, ncid, 'VTH2d',   vth2d

    ncdf_close, ncid

; copy to structure

    nt = n_elements(date)

    tem_data = create_struct( $
      'P0',      P0, $
      'lat',     lat, $
      'lev',     lev, $
      'ilev',    ilev, $
      'time',    time, $
      'date',    date, $
      'datesec', datesec, $
      'V2d',     v2d, $
      'W2d',     w2d, $
      'TH2d',    th2d, $
      'VTH2d',   vth2d $
    )

    print, nt, 'times read'
    
    return

;--------------------------------------------------------------------------
 end
;--------------------------------------------------------------------------

