PRO read_3al, out, label, sfdu, FILE = file, SWAP = swap

;*******************************************************************************
; NAME:
;	READ_3AL
;
; PURPOSE:
;	This is an IDL program that will read UARS level 3AL files which
;	are archived in UNIX format on an SGI (big-endian) platform at NASA's
;	Goddard DAAC.
;
; CALLING SEQUENCE:
; 	READ_3AL, Data [, Label [, Sfdu] ] 
;
; INPUTS:
;	None.
;
; OUTPUTS:
;	Data:	A structure array containing the data record values.
;
; OPTIONAL OUTPUT PARAMETERS:
;	Label:	A structure which contains the label record values.
;	Sfdu:	A structure which contains the SFDU record values.
;
; KEYWORDS Parameters:
;	FILE:	The name of the file (*META or *PROD extension)
;	SWAP:	Performs byte swapping when reading on little-endian machines.
;
; RESTRICTIONS:
;       When reading the DAAC UARS files on a little-endian machine, such as
;       a PC, use the /swap keyword to byte swap the data since the files are
;	written in IEEE big-endian format.
;
; EXAMPLES:
;	Read level 3AL file, return just data records, and supply file name.
;
;		READ_3AL, x, file='MLS_L3AL_SCLO_D0123.V0003_C01_PROD'
;
;	Read level 3AL file, return all records, and prompt for file name.
;
;		READ_3AL, x, h, s	; Program prompts for file name.
;
; MODIFICATION HISTORY:
;	James Johnson, Hughes STX, July 2, 1996.
;
;*******************************************************************************

on_error, 1				; return to main level if error.
if n_params(0) eq 0 then begin		; check if required output was supplied.
  message, "usage: READ_3AL, data [, label [, sfdu ] ]"
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
minlen = 148						; Min. UARS record size
rec = bytarr(minlen)
openr, unit, file, /get_lun
readu, unit, rec

on_ioerror, message2
if (string(rec(20:23)) eq 'CCSD') then begin		; You have a PROD file

;  NOTE: This might be a 3AL or a 3LP file.  Can't be sure which yet.
;  Determine the record length manually from the PROD file.

  i = 0 & j = -1
  while (j eq -1 and i lt 222) do begin
    readu, unit, rec
    ind=where(rec eq 0b, indcnt)
    if (indcnt gt 0) then rec(where(rec eq 0b)) = 1b
    i = i+1
    j = strpos(rec,'UARS')
  endwhile
  reclen = i*minlen + j - 20
  point_lun, unit, 0

endif else begin
  if (string(rec(0:7)) eq "! TYPE :") then begin	; You have a META file

    meta=bytarr(1000)  
    meta(0:147) = rec
    readu, unit, rec
    meta(148:295) = rec
    i = strpos(meta, '! LEVEL :')+10
    if (string(meta(i:i+2)) ne '3AL') then begin
      goto, message3
    endif

;  Might as well get record length from META file.  Also, check
;  for <CR> character (0x13) if downloaded to DOS mode ascii,
;  otherwise check for <LF> character (0x10).

    i = strpos(meta, "! RECORD_SIZE :")+16
    if (strpos(meta(i:i+6), string(13b)) eq -1) then begin
      j = strpos(meta(i:i+6), string(10b))+i-1
    endif else begin
      j = strpos(meta(i:i+6), string(13b))+i-1
    endelse
    reclen = fix(string(meta(i:j)))

;  Assume PROD file is in same directory as META file, and that
;  META and PROD files have not been renamed.  If they have, then
;  you must enter the PROD file as the file.

    i = strlen(file)
    file = strmid(file,0,i-4)+'PROD'

    free_lun, unit
    openr, unit, file, /get_lun

  endif else begin					; Not a valid file type

    goto, message3

  endelse
endelse

rec = bytarr(reclen)

; Read SFDU Label Record

s2 = {sfdu2, record_key:"                    ", control_id_z:"    ", $
      version_id_z:" ", class_id_z:" ", data_desc_id_z:"    ", $
      length_z:"        ", control_id_i:"    ", version_id_i:" ", $
      class_id_i:" ", data_desc_id_i:"    ", length_i:"        "}

readu, unit, rec
s2.record_key = string(rec(0:19))
s2.control_id_z = string(rec(20:23))
s2.version_id_z = string(rec(24))
s2.class_id_z = string(rec(25))
s2.data_desc_id_z = string(rec(28:31))
s2.length_z = string(rec(32:39))
s2.control_id_i = string(rec(40:43))
s2.version_id_i = string(rec(44))
s2.class_id_i = string(rec(45))
s2.data_desc_id_i = string(rec(48:51))
s2.length_i = string(rec(52:59))


; Read File Label Record

l2= {label2, record_key:"                    ", $
    satellite_id:'    ', record_type:'  ', instrument_id:'            ', $
    data_subtype:'            ', $
    format_version:'    ', phys_rec_cnt:'        ', num_cont_recs:'    ', $
    num_phys_recs:'        ', file_creation:'                       ', $
    year_1st_rec:'   ', day_1st_rec:'   ', msec_1st_rec:'        ', $
    year_last_rec:'   ', day_last_rec:'   ', msec_last_rec:'        ', $
    data_level:'   ', uars_day:'    ', num_data_pts:'    ', base_index:'    ', $
    rec_length:'     ', min_latitude:'   ', max_latitude:'   ', $
    ccb_version:'         ', file_cycle_num:'     ', $
    virtual_flag:' ', tot_entry_file:'    ', num_entry_rec:'    '}

point_lun, unit, reclen
readu, unit, l2

if (l2.data_level ne '3AL') then goto, message3 	; Make sure it is 3AL.
sfdu = s2
label = l2

; Read the Data Records

pts = long(label.num_data_pts)
data = {record_key:'                    ', satellite_id:'    ', $
       record_type:'  ', instrument_id:'            ', $
       phys_rec_count:'        ', total_pts:0L, actual_pts:0L, $
       index_1st_pt:0L, time:lonarr(2), lat:0., lon:0., lst:0., sza:0., $
       data:fltarr(pts), quality:fltarr(pts)}

cnt = long(label.num_phys_recs) - 1		; Number of Data Records.
out = replicate(data, cnt)

for i = 0, cnt - 1 do begin

  point_lun, unit, long(reclen)*(i+2)
  readu, unit, rec
  out(i).record_key = string(rec(0:19))
  out(i).satellite_id = string(rec(20:23))
  out(i).record_type = string(rec(24:25))
  out(i).instrument_id = string(rec(26:37))
  out(i).phys_rec_count = string(rec(38:45))
  out(i).total_pts = long(rec(48:51),0)
  out(i).actual_pts = long(rec(52:55),0)
  out(i).index_1st_pt = long(rec(56:59),0)
  out(i).time = long(rec(60:67),0,2)
  out(i).lat = float(rec(68:71),0)
  out(i).lon = float(rec(72:75),0)
  out(i).lst = float(rec(76:79),0)
  out(i).sza = float(rec(80:83),0)
  out(i).data = float(rec(84:84 + 4*pts - 1), 0, pts)
  out(i).quality = float(rec(84 + 4*pts:84 + 4*2*pts - 1), 0, pts)

; If using a little-endian machine, such as a PC, to read the UARS data files.
if KEYWORD_SET(swap) then out(i) = swap_endian(out(i))

; Clear all NaNs (UNIX not a numbers 0x7fffffff) and set them equal to -9999.
; CHECK_MATH(0,1) prevents messages, CHECK_MATH(0,0) turns messages back on.
  check = check_math(0,1)
    dind = where(finite(0.-out(i).data) eq 0, count)
    if (count gt 0) then out(i).data(dind) = -9999.
    qind = where(finite(0.-out(i).quality) eq 0, count)
    if (count gt 0) then out(i).quality(qind) = -9999.
  check = check_math(0,0)

endfor

goto, bye
message1: message, "file could not be opened, or file not found."
goto, bye
message2: message, "problem reading file."
goto, bye
message3: message, "must use a Level 3AL *PROD or *META file."

bye: ;Exit program
free_lun, unit

end
