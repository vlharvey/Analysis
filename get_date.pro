;
; build UKMO filename for import into script to ftp daily data
; VLH Tue Sep 17 11:11:55 EDT 2002
;
spawn,'date +%D',date
mm=strmid(date,0,2) & dd=strmid(date,3,2) & yy=strmid(date,6,2)
ifile='ppassm_operh_y'+yy+'_m'+mm+'_d'+dd+'_h12.pp'
end
