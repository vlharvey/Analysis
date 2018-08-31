PRO read_3at, out, label, sfdu, FILE = file, SWAP = swap

;*******************************************************************************
; NAME:
;	READ_3AT
;
; PURPOSE:
;	This is an IDL program that will read UARS level 3AT files which
;	are archived in UNIX format on an SGI (big-endian) platform at NASA's
;	Goddard DAAC.
;
; CALLING SEQUENCE:
; 	READ_3AT, Data [, Label [, Sfdu] ] 
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
;       SWAP:   Performs byte swapping when reading on little-endian machines.
;
; RESTRICTIONS:
;       When reading the DAAC UARS files on a little-endian machine, such as
;       a PC, use the /swap keyword to byte swap the data since the files are
;       written in IEEE big-endian format.
;
; EXAMPLES:
;	Read level 3AT file, return just data records, and supply file name.
;
;		READ_3AT, x, file='MLS_L3AT_SCLO_D0123.V0003_C01_PROD'
;
;	Read level 3AT file, return all records, and prompt for file name.
;
;		READ_3AT, x, h, s	; Program prompts for file name.
;
; MODIFICATION HISTORY:
;	James Johnson, Hughes STX, July 2, 1996.
;
;*******************************************************************************

on_error, 1				; return to main level if error.
if n_params(0) eq 0 then begin		; check if required output was supplied.
  message, "usage: READ_3AT, data [, label [, sfdu ] ]"
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
if (string(rec(0:3)) eq 'CCSD') then begin		; You have a PROD file

;  NOTE: This might be a 3AT or a 3TP file.  Can't be sure which yet.
;  Determine the record length manually from the PROD file.

  i = 0 & j = -1
  while (j eq -1 and i lt 222) do begin
    readu, unit, rec
    ind=where(rec eq 0b, indcnt)
    if (indcnt gt 0) then rec(where(rec eq 0b)) = 1b
    i = i+1
    j = strpos(rec,'UARS')
  endwhile
  reclen = i*minlen + j
  point_lun, unit, 0

endif else begin
  if (string(rec(0:7)) eq "! TYPE :") then begin	; You have a META file

    meta=bytarr(1000)  
    meta(0:147) = rec
    readu, unit, rec
    meta(148:295) = rec
    i = strpos(meta, '! LEVEL :')+10
    if (string(meta(i:i+2)) ne '3AT') then begin
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

s1 = {sfdu1, control_id_z:"    ", $
     version_id_z:" ", class_id_z:" ", data_desc_id_z:"    ", $
     length_z:"        ", control_id_i:"    ", version_id_i:" ", $
     class_id_i:" ", data_desc_id_i:"    ", length_i:"        "}

readu, unit, rec
s1.control_id_z = string(rec(0:3))
s1.version_id_z = string(rec(4))
s1.class_id_z = string(rec(5))
s1.data_desc_id_z = string(rec(8:11))
s1.length_z = string(rec(12:19))
s1.control_id_i = string(rec(20:23))
s1.version_id_i = string(rec(24))
s1.class_id_i = string(rec(25))
s1.data_desc_id_i = string(rec(28:31))
s1.length_i = string(rec(32:39))


; Read File Label Record

l1= {label1, satellite_id:'    ', record_type:'  ', $
    instrument_id:'            ', data_subtype:'            ', $
    format_version:'    ', phys_rec_cnt:'        ', num_cont_recs:'    ', $
    num_phys_recs:'        ', file_creation:'                       ', $
    year_1st_rec:'   ', day_1st_rec:'   ', msec_1st_rec:'        ',$
    year_last_rec:'   ', day_last_rec:'   ', msec_last_rec:'        ',$
    data_level:'   ', uars_day:'    ', num_data_pts:'    ', base_index:'    ', $
    rec_length:'     ', ccb_version:'         ', file_cycle_num:'     ', $
    virtual_flag:' ', tot_entry_file:'    ', num_entry_rec:'    '}

point_lun, unit, reclen
readu, unit, l1

if (l1.data_level ne '3AT') then goto, message3		; Make sure it is 3AT.
sfdu = s1
label = l1

; Read the Data Records

pts = long(label.num_data_pts)
data = {satellite_id:'    ', record_type:'  ', instrument_id:'            ', $
       phys_rec_count:'        ', spare:0, total_pts:0L, actual_pts:0L, $
       index_1st_pt:0L, time:lonarr(2), lat:0., lon:0., lst:0., sza:0., $
       data:fltarr(pts), quality:fltarr(pts)}

nrec = long(label.num_phys_recs) - 1		; Number of Data Records.
out = replicate(data, nrec)

i=0L
while i lt nrec and (not eof(unit)) do begin
 
  point_lun, unit, long(reclen)*(i+2)
  readu, unit, data
  out(i) = data
; readu, unit, rec
; out(i).satellite_id = string(rec(0:3))
; out(i).record_type = string(rec(4:5))
; out(i).instrument_id = string(rec(6:17))
; out(i).phys_rec_count = string(rec(18:25))
; out(i).total_pts = long(rec(28:31),0)
; out(i).actual_pts = long(rec(32:35),0)
; out(i).index_1st_pt = long(rec(36:39),0)
; out(i).time = long(rec(40:47),0,2)
; out(i).lat = float(rec(48:51),0)
; out(i).lon = float(rec(52:55),0)
; out(i).lst = float(rec(56:59),0)
; out(i).sza = float(rec(60:63),0)
; out(i).data = float(rec(64:64 + 4*pts - 1), 0, pts)
; out(i).quality = float(rec(64 + 4*pts:64 + 4*2*pts - 1), 0, pts)

; If using a little-endian machine, such as a PC, to read the UARS data files.
if KEYWORD_SET(swap) then out(i) = swap_endian(out(i))

; Clear all NaNs (UNIX not a numbers 0x7fffffff) and set them equal to -9999.
; Check_math(0,1) prevents messages.
  check = check_math(0,1)
    dind = where(finite(0.-out(i).data) eq 0)
    if (total(dind) ge 0) then out(i).data(dind) = -9999.
    qind = where(finite(0.-out(i).quality) eq 0)
    if (total(qind) ge 0) then out(i).quality(qind) = -9999.
  check = check_math(0,0)

  i=i+1
endwhile

goto, bye
message1: message, "file could not be opened, or file not found."
goto, bye
message2: message, "problem reading file."
goto, bye
message3: message, "must use a Level 3AT *PROD or *META file."

bye: ;Exit program
free_lun, unit

end
