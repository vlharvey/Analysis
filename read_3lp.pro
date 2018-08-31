PRO read_3lp, out, label, sfdu, FILE = file, SWAP = swap

;*******************************************************************************
; NAME:
;	READ_3LP
;
; PURPOSE:
;	This is an IDL program that will read UARS level 3LP files which
;	are archived in UNIX format on an SGI (big-endian) platform at NASA's
;	Goddard DAAC.
;
; CALLING SEQUENCE:
; 	READ_3LP, Data [, Label [, Sfdu] ] 
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
;	Read level 3LP file, return just data records, and supply file name.
;
;		READ_3LP, x, file='MLS_L3LP_SPARAM_L3LP_D0123.V0003_C01_PROD'
;
;	Read level 3LP file, return all records, and prompt for file name.
;
;		READ_3LP, x, h, s	; Program prompts for file name.
;
; MODIFICATION HISTORY:
;	James Johnson, Hughes STX, July 2, 1996.
;
;*******************************************************************************

on_error, 1				; return to main level if error.
if n_params(0) eq 0 then begin		; check if required output was supplied.
  message, "usage: READ_3LP, data [, label [, sfdu ] ]"
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

;  NOTE: This might be a 3LP or a 3LP file.  Can't be sure which yet.
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
    if (string(meta(i:i+2)) ne '3LP') then begin
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

l5= {label5, record_key:"                    ", $
    satellite_id:'    ', record_type:'  ', instrument_id:'            ', $
    data_subtype:'            ', $
    format_version:'    ', phys_rec_cnt:'        ', num_cont_recs:'    ', $
    num_phys_recs:'        ', file_creation:'                       ', $
    year_1st_rec:'   ', day_1st_rec:'   ', msec_1st_rec:'        ',$
    year_last_rec:'   ', day_last_rec:'   ', msec_last_rec:'        ',$
    data_level:'   ', uars_day:'    ', num_32bit_words:'    ', $
    rec_length:'     ', min_latitude:'   ', max_latitude:'   ', $
    ccb_version:'         ', file_cycle_num:'     ', $
    virtual_flag:' ', tot_entry_file:'    ', num_entry_rec:'    '}

point_lun, unit, reclen
readu, unit, rec
l5.record_key = string(rec(0:19))
l5.satellite_id = string(rec(20:23))
l5.record_type = string(rec(24:25))
l5.instrument_id = string(rec(26:37))
l5.data_subtype = string(rec(38:49))
l5.format_version = string(rec(50:53))
l5.phys_rec_cnt = string(rec(54:61))
l5.num_cont_recs = string(rec(62:65))
l5.num_phys_recs = string(rec(66:73))
l5.file_creation = string(rec(74:96))
l5.year_1st_rec = string(rec(97:99))
l5.day_1st_rec = string(rec(100:102))
l5.msec_1st_rec = string(rec(103:110))
l5.year_last_rec = string(rec(111:113))
l5.day_last_rec = string(rec(114:116))
l5.msec_last_rec = string(rec(117:124))
l5.data_level = string(rec(125:127))
l5.uars_day = string(rec(128:131))
l5.num_32bit_words = string(rec(132:135))
l5.rec_length = string(rec(140:144))
l5.min_latitude = string(rec(145:147))
l5.max_latitude = string(rec(148:150))
l5.ccb_version = string(rec(151:159))
l5.file_cycle_num = string(rec(160:164))
l5.virtual_flag = string(rec(165))
l5.tot_entry_file = string(rec(166:169))
l5.num_entry_rec = string(rec(170:173))

; Make sure it is 3LP.
if (l5.data_level ne '3LP') then goto, message3
sfdu = s2
label = l5


; Read the Data Records

pts = long(label.num_32bit_words)

if (strpos(label.instrument_id,'ISAMS') eq 0) then begin	; For ISAMS 3LP
  p = {isams, sat_dir:0b, LR_view_dir:0b, PMC_pressure:bytarr(8), $
      scan_prog_num:0, scan_version:0b, los_dir:0}
endif

if (strpos(label.instrument_id,'MLS') eq 0) then begin	; For MLS 3LP
  p = {mls, col_o3:0., col_o3_sdev:0., col_o3_183:0., col_o3_183_sdev:0.,$
      col_o3_205:0., col_o3_205_sdev:0., pref:0., qual_clo:0., qual_h2o:0., $
      qual_o3:0., qual_o3_183:0., qual_o3_205:0., qual_temp:0., tan_alt_max:0.,$
      tan_alt_min:0., zref_geopot:0., zref_geom:0., maneuver:0L, mmafno:0L, $
      solar_illum:0L, flag_ascend:0b, scan_change:0b, mmaf_stat:' '}
endif

if (strpos(label.instrument_id,'WINDII') eq 0) then begin	; For WINDII 3LP
  p = {job_version:'        ', cdb_version:'        ', inv_quantity:0b, $
      temp_source:0b, filter_number:bytarr((4*pts-18)/5), $
      filter_quality:lonarr((4*pts-18)/5)}
endif

data = {record_key:'                    ', satellite_id:'    ', $
       record_type:'  ', instrument_id:'            ', $
       phys_rec_count:'        ', max_32bit_words:0L, time:lonarr(2), $
       lat:0., lon:0., num_32bit_words:0L, param:replicate(p,1)}

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
  out(i).max_32bit_words = long(rec(48:51),0)
  out(i).time = long(rec(60:67),0,2)
  out(i).lat = float(rec(68:71),0)
  out(i).lon = float(rec(72:75),0)
  out(i).num_32bit_words = long(rec(84:87),0)

  if (strpos(label.instrument_id,'ISAMS') eq 0) then begin	; For ISAMS 3LP
    out(i).param.sat_dir = rec(88)
    out(i).param.LR_view_dir = rec(89)
    out(i).param.PMC_pressure = rec(90:97)
    out(i).param.scan_prog_num = ishft(fix(rec(98:99),0),-5)
    out(i).param.scan_version = ishft(ishft(rec(99),3),-3)
    out(i).param.los_dir = fix(rec(100:101),0)
  endif

  if (strpos(label.instrument_id,'MLS') eq 0) then begin	; For MLS 3LP
    out(i).param.col_o3 = float(rec(88:91),0)
    out(i).param.col_o3_sdev = float(rec(92:95),0)
    out(i).param.col_o3_183 = float(rec(96:99),0)
    out(i).param.col_o3_183_sdev = float(rec(100:103),0)
    out(i).param.col_o3_205 = float(rec(104:107),0)
    out(i).param.col_o3_205_sdev = float(rec(108:111),0)
    out(i).param.pref = float(rec(112:115),0)
    out(i).param.qual_clo = float(rec(116:119),0)
    out(i).param.qual_h2o = float(rec(120:123),0)
    out(i).param.qual_o3 = float(rec(124:127),0)
    out(i).param.qual_o3_183 = float(rec(128:131),0)
    out(i).param.qual_o3_205 = float(rec(132:135),0)
    out(i).param.qual_temp = float(rec(136:139),0)
    out(i).param.tan_alt_max = float(rec(140:143),0)
    out(i).param.tan_alt_min = float(rec(144:147),0)
    out(i).param.zref_geopot = float(rec(148:151),0)
    out(i).param.zref_geom = float(rec(152:155),0)
    out(i).param.maneuver = long(rec(156:159),0)
    out(i).param.mmafno = long(rec(160:163),0)
    out(i).param.solar_illum = long(rec(164:167),0)
    out(i).param.flag_ascend = rec(168)
    out(i).param.scan_change = rec(169)
    out(i).param.mmaf_stat = string(rec(170))
  endif

  if (strpos(label.instrument_id,'WINDII') eq 0) then begin	; For WINDII 3LP
    out(i).param.job_version = string(rec(88:95))
    out(i).param.cdb_version = string(rec(96:103))
    out(i).param.inv_quantity = rec(104)
    out(i).param.temp_source = rec(105)
    for k=0,(4*out(i).num_32bit_words-18)/5 - 1 do begin
      out(i).param.filter_number(k) = rec(5*k+106)
      out(i).param.filter_quality(k) = long(rec(5*k+107:5*k+110),0)
    endfor
  endif

; If using a little-endian machine, such as a PC, to read the UARS data files.
if KEYWORD_SET(swap) then out(i) = swap_endian(out(i))

endfor

goto, bye
message1: message, "file could not be opened, or file not found."
goto, bye
message2: message, "problem reading file."
goto, bye
message3: message, "must use a Level 3LP *PROD or *META file."

bye: ;Exit program
free_lun, unit

end
