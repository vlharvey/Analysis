PRO read_nmc, out, label, FILE = file, SWAP = swap

;*******************************************************************************
; NAME:
;       READ_NMC
;
; PURPOSE:
;       This is an IDL program that will read UARS correlative NMC files which
;       are archived in UNIX format on an SGI (big-endian) platform at NASA's
;       Goddard DAAC.
;
; CALLING SEQUENCE:
;       READ_NMC, Data [, Label ]
;
; INPUTS:
;       None.
;
; OUTPUTS:
;       Data:   A structure array containing the data record values.
;
; OPTIONAL OUTPUT PARAMETERS:
;       Label:  A structure which contains the label record values.
;
; KEYWORDS Parameters:
;       FILE:   The name of the file (*META or *PROD extension)
;       SWAP:   Performs byte swapping when reading on little-endian machines.
;
; RESTRICTIONS:
;       When reading the DAAC UARS files on a little-endian machine, such as
;       a PC, use the /swap keyword to byte swap the data since the files are
;       written in IEEE big-endian format.
;
; EXAMPLES:
;       Read NMC file, return just data records, and supply file name.
;
;               READ_NMC, x, file='CORR_ZNMC_STEMP_D0123.V0001_C01_PROD'
;
;       Read NMC file, return all records, and prompt for file name.
;
;               READ_NMC, x, h         ; Program prompts for file name.
;
; MODIFICATION HISTORY:
;       James Johnson, Hughes STX, July 2, 1996.
;
;*******************************************************************************

on_error, 1                             ; return to main level if error.
if n_params(0) eq 0 then begin          ; check if required output was supplied.
  message, "usage: READ_NMC, data [, label ]"
  goto, bye
endif

if not KEYWORD_SET(file) then begin

  file = ''
  print, format='("Please enter file name", $)
  read, file
  file = strtrim(file)

endif

on_ioerror, message1

file = strtrim(file,2)

minlen = 148                                            ; Min. UARS record size
rec = bytarr(minlen)
openr, unit, file, /get_lun
readu, unit, rec

on_ioerror, message2

if (string(rec(0:3)) eq 'CCSD' and $
    strupcase(string(rec(132:134))) eq 'NMC') then begin

  point_lun, unit, 0

endif else begin

  if (string(rec(0:19)) eq "! TYPE : CORRELATIVE") then begin
 							; You have a META file
    meta=bytarr(1000)
    meta(0:147) = rec
    readu, unit, rec
    meta(148:295) = rec
    readu, unit, rec
    meta(296:443) = rec
    readu, unit, rec
    meta(444:591) = rec
    readu, unit, rec
    meta(592:739) = rec
    j = strpos(meta, '! SOURCE :')+11
    if (string(meta(j:j+2)) ne 'NMC') then begin
      goto, message3
    endif

;  Assume PROD file is in same directory as META file, and that
;  META and PROD files have not been renamed.  If they have, then
;  you must enter the PROD file as the file.

    i = strlen(file)
    file = strmid(file,0,i-4)+'PROD'

    free_lun, unit					; Close the *META file
    openr, unit, file, /get_lun				; Open the *PROD file

  endif else begin                                      ; Not a valid file type
    goto, message3

  endelse

endelse


reclen = 16964				 ; All NMC file records are this length

label = {hnmc, tz_field:"            ", lz_field:"        ", $
     ti_field:"            ", li_field:"        ", $
     vi_field:"                                                ", $
     project_name:"    ", uars_pi:"                    ", $
     uars_cmi:"                    ", corr_data_class:"        ", $
     instrument_type:"            ", obs_station_id:"            ", $
     corr_file_id:"            ", $
     start_time:"                       ", $
     stop_time:"                       ", $
     max_lat:"       ", min_lat:"       ", $
     max_lon:"       ", min_lon:"       ", $
     max_alt_km:"        ", min_alt_km:"        ", $
     max_alt_mb:"        ", min_alt_mb:"        ", $
     record_size:"      ", num_rec_in_file:"      ", $
     data_quality1:"   ", data_quality2:"   ", $
     user_comments:"                                                                                ", $
     corr_dat_param1:"            ", corr_dat_param2:"            ", $
     corr_dat_param3:"            ", corr_dat_param4:"            "}

readu, unit, label

dat = {nmc, data_type:0L, surf_type1:0L, surf_value1:0., surf_type2:0L, $
      surf_value2:0., year_data:0L, month_data:0L, day_data:0L, $
      hour_data:0L, hemisphere:0L, time_indicator:"                       ", $
      extra_byte:" ", data:fltarr(65,65)}

out = replicate(dat, long(label.num_rec_in_file) - 1)

point_lun, unit, reclen
readu, unit, out

; If using a little-endian machine, such as a PC, to read the UARS data files.
if KEYWORD_SET(swap) then out = swap_endian(out)

goto, bye
message1: message, "file could not be opened, or file not found."
goto, bye
message2: message, "problem reading file."
goto, bye
message3: message, "must use a correlative NMC *PROD or *META file."

bye: ;Exit program
free_lun, unit

end

