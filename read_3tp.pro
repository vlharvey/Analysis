PRO read_3tp, out, label, sfdu, FILE = file, SWAP = swap

;*******************************************************************************
; NAME:
;	READ_3TP
;
; PURPOSE:
;	This is an IDL program that will read UARS level 3TP files which
;	are archived in UNIX format on an SGI (big-endian) platform at NASA's
;	Goddard DAAC.
;
; CALLING SEQUENCE:
; 	READ_3TP, Data [, Label [, Sfdu] ] 
;
; INPUTS:
;	None.
;
; OUTPUTS:
;	Data:	A structure array containing the data record values.
;
; OPTIONAL OUTPUT PARAMETERS:
;	Label:	A structure which contains the label record values.
;	Sfdu:	A structure  which contains the SFDU record values.
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
;	Read level 3TP file, return just data records, and supply file name.
;
;		READ_3TP, x, file='WINDII_L3TP_SPARAM_D0123.V0009_C01_PROD'
;
;	Read level 3TP file, return all records, and prompt for file name.
;
;		READ_3TP, x, h, s	; Program prompts for file name.
;
; MODIFICATION HISTORY:
;	James Johnson, Hughes STX, July 2, 1996.
;
;*******************************************************************************

on_error, 1				; return to main level if error.
if n_params(0) eq 0 then begin		; check if required output was supplied.
  message, "usage: READ_3TP, data [, label [, sfdu ] ]"
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

;  NOTE: This might be a 3TP or a 3TP file.  Can't be sure which yet.
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
    if (string(meta(i:i+2)) ne '3TP') then begin
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

l4= {label4, satellite_id:'    ', record_type:'  ', $
    instrument_id:'            ', data_subtype:'            ', $
    format_version:'    ', phys_rec_cnt:'        ', num_cont_recs:'    ', $
    num_phys_recs:'        ', file_creation:'                       ', $
    year_1st_rec:'   ', day_1st_rec:'   ', msec_1st_rec:'        ',$
    year_last_rec:'   ', day_last_rec:'   ', msec_last_rec:'        ',$
    data_level:'   ', uars_day:'    ', num_32bit_words:'    ', $
    rec_length:'     ', ccb_version:'         ', file_cycle_num:'     ', $
    virtual_flag:' ', tot_entry_file:'    ', num_entry_rec:'    '}

point_lun, unit, reclen
readu, unit, rec
l4.satellite_id = string(rec(0:3))
l4.record_type = string(rec(4:5))
l4.instrument_id = string(rec(6:17))
l4.data_subtype = string(rec(18:29))
l4.format_version = string(rec(30:33))
l4.phys_rec_cnt = string(rec(34:41))
l4.num_cont_recs = string(rec(42:45))
l4.num_phys_recs = string(rec(46:53))
l4.file_creation = string(rec(54:76))
l4.year_1st_rec = string(rec(77:79))
l4.day_1st_rec = string(rec(80:82))
l4.msec_1st_rec = string(rec(83:90))
l4.year_last_rec = string(rec(91:93))
l4.day_last_rec = string(rec(94:96))
l4.msec_last_rec = string(rec(97:104))
l4.data_level = string(rec(105:107))
l4.uars_day = string(rec(108:111))
l4.num_32bit_words = string(rec(112:115))
l4.rec_length = string(rec(120:124))
l4.ccb_version = string(rec(125:133))
l4.file_cycle_num = string(rec(134:138))
l4.virtual_flag = string(rec(139))
l4.tot_entry_file = string(rec(140:143))
l4.num_entry_rec = string(rec(144:147))

; Make sure it is 3TP.
if (l4.data_level ne '3TP') then goto, message3
sfdu = s1
label = l4

; Read the Data Records

pts = long(label.num_32bit_words)

if (strpos(label.instrument_id,'HALOE') eq 0) then begin	; For HALOE 3TP
  data = {satellite_id:'    ', record_type:'  ', instrument_id:'            ', $
         phys_rec_count:'        ', max_32bit_words:0L, time:lonarr(2), $
         lat:0., lon:0., num_32bit_words:0L, param:fltarr(pts)}

endif else begin

  if (strpos(label.instrument_id,'ISAMS') eq 0) then begin	; For ISAMS 3TP
  p = {isams, sat_dir:0b, LR_view_dir:0b, PMC_pressure:bytarr(8), $
      scan_prog_num:0, scan_version:0b, los_dir:0}
  endif

  if (strpos(label.instrument_id,'MLS') eq 0) then begin	; For MLS 3TP
  p = {mls, col_o3:0., col_o3_sdev:0., col_o3_183:0., col_o3_183_sdev:0.,$
      col_o3_205:0., col_o3_205_sdev:0., pref:0., qual_clo:0., qual_h2o:0., $
      qual_o3:0., qual_o3_183:0., qual_o3_205:0., qual_temp:0., tan_alt_max:0.,$
      tan_alt_min:0., zref_geopot:0., zref_geom:0., maneuver:0L, mmafno:0L, $
      solar_illum:0L, flag_ascend:0b, scan_change:0b, mmaf_stat:' '}
  endif

  if (strpos(label.instrument_id,'PEM') eq 0) then begin	; For PEM 3TP
    if (strpos(label.data_subtype,'MEPS') eq 0) then begin
      p = {meps, time1:lonarr(2), lat1:0., lon1:0., time2:lonarr(2), $
          lat2:0., lon2:0., data:fltarr(32,88), stdev:fltarr(32,88)}
    endif

    if (strpos(label.data_subtype,'HEPS_ELEC_ED') eq 0) then begin
      d1 = {heps_e1, satellite_id:'    ', record_type:'  ', $
            instrument_id:'            ', phys_rec_count:'        ', $
            max_32bit_words:0L, time:lonarr(2), lat:0., lon:0., $
            num_32bit_words:0L, deposit_alt:0., dipole_lat:0., dipole_lon:0., $
            num_alphas:0L, alpha_params:fltarr(20)}

      dn = {heps_en, satellite_id:'    ', record_type:'  ', $
           instrument_id:'            ', phys_rec_count:'        ', $
           max_32bit_words:0L, time:lonarr(2), lat:0., lon:0., $
           num_32bit_words:0L, data:fltarr(88), stdev:fltarr(88), $
           j1_fit:fltarr(6), j2_fit:fltarr(6), $
           g1_fit:fltarr(6), g2_fit:fltarr(6), sigma_fit:fltarr(6), $
           chi2_fit:fltarr(6), i_type_fit:lonarr(6)}

     out = {heps_e, rec1:replicate(d1,1), $
           recn:replicate(dn,long(label.num_phys_recs) - 2)}

     goto, skip
    endif

    if (strpos(label.data_subtype,'HEPS_PROT_ED') eq 0) then begin
      d1 = {heps_p1, satellite_id:'    ', record_type:'  ', $
            instrument_id:'            ', phys_rec_count:'        ', $
            max_32bit_words:0L, time:lonarr(2), lat:0., lon:0., $
            num_32bit_words:0L, deposit_alt:0., dipole_lat:0., dipole_lon:0.}

      dn = {heps_pn, satellite_id:'    ', record_type:'  ', $
           instrument_id:'            ', phys_rec_count:'        ', $
           max_32bit_words:0L, time:lonarr(2), lat:0., lon:0., $
           num_32bit_words:0L, data:fltarr(88), stdev:fltarr(88), $
           j1_fit:fltarr(4), j2_fit:fltarr(4), $
           g1_fit:fltarr(4), g2_fit:fltarr(4), sigma_fit:fltarr(4), $
           chi2_fit:fltarr(4), i_type_fit:lonarr(4)}

     out = {heps_p, rec1:replicate(d1,1), $
           recn:replicate(dn,long(label.num_phys_recs) - 2)}

     goto, skip
    endif

  endif

  if (strpos(label.instrument_id,'WINDII') eq 0) then begin	; For WINDII 3TP
  p = {job_version:'        ', cdb_version:'        ', inv_quantity:0b, $
      temp_source:0b, filter_number:bytarr((4*pts-18)/5), $
      filter_quality:lonarr((4*pts-18)/5)}
  endif

  data = {satellite_id:'    ', record_type:'  ', instrument_id:'            ', $
         phys_rec_count:'        ', max_32bit_words:0L, time:lonarr(2), $
         lat:0., lon:0., num_32bit_words:0L, param:replicate(p,1)}

endelse

out = replicate(data, long(label.num_phys_recs) - 1)

skip: for i = 0, long(label.num_phys_recs) - 2 do begin

  point_lun, unit, long(reclen)*(i+2)
  readu, unit, rec

  if (strpos(label.data_subtype, 'HEPS') ne 0) then begin
    out(i).satellite_id = string(rec(0:3))
    out(i).record_type = string(rec(4:5))
    out(i).instrument_id = string(rec(6:17))
    out(i).phys_rec_count = string(rec(18:25))
    out(i).max_32bit_words = long(rec(28:31),0)
    out(i).time = long(rec(40:47),0,2)
    out(i).lat = float(rec(48:51),0)
    out(i).lon = float(rec(52:55),0)
    out(i).num_32bit_words = long(rec(64:67),0)
  endif

  if (strpos(label.instrument_id,'HALOE') eq 0) then begin	; For HALOE 3TP
   out(i).param(0:out(i).num_32bit_words-1) = $
     float(rec(68:68+4*out(i).num_32bit_words-1),0,out(i).num_32bit_words)

; Clear all NaNs (UNIX not a numbers 0x7fffffff) and set them equal to -9999.
; Check_math(0,1) prevents messages.
; check = check_math(0,1)
   dind = where(finite(0.-out(i).param) eq 0)
   if (total(dind) ge 0) then out(i).param(dind) = -9999.
   check = check_math(0,0)
  endif

  if (strpos(label.instrument_id,'ISAMS') eq 0) then begin	; For ISAMS 3TP
   out(i).param.sat_dir = rec(68)
   out(i).param.LR_view_dir = rec(69)
   out(i).param.PMC_pressure = rec(70:77)
   out(i).param.scan_prog_num = ishft(fix(rec(78:79),0),-5)
   out(i).param.scan_version = ishft(ishft(rec(79),3),-3)
   out(i).param.los_dir = fix(rec(80:81),0)
  endif

  if (strpos(label.instrument_id,'MLS') eq 0) then begin	; For MLS 3TP
   out(i).param.col_o3 = float(rec(68:71),0)
   out(i).param.col_o3_sdev = float(rec(72:75),0)
   out(i).param.col_o3_183 = float(rec(76:79),0)
   out(i).param.col_o3_183_sdev = float(rec(80:83),0)
   out(i).param.col_o3_205 = float(rec(84:87),0)
   out(i).param.col_o3_205_sdev = float(rec(88:91),0)
   out(i).param.pref = float(rec(92:95),0)
   out(i).param.qual_clo = float(rec(96:99),0)
   out(i).param.qual_h2o = float(rec(100:103),0)
   out(i).param.qual_o3 = float(rec(104:107),0)
   out(i).param.qual_o3_183 = float(rec(108:111),0)
   out(i).param.qual_o3_205 = float(rec(112:115),0)
   out(i).param.qual_temp = float(rec(116:119),0)
   out(i).param.tan_alt_max = float(rec(120:123),0)
   out(i).param.tan_alt_min = float(rec(124:127),0)
   out(i).param.zref_geopot = float(rec(128:131),0)
   out(i).param.zref_geom = float(rec(132:135),0)
   out(i).param.maneuver = long(rec(136:139),0)
   out(i).param.mmafno = long(rec(140:143),0)
   out(i).param.solar_illum = long(rec(144:147),0)
   out(i).param.flag_ascend = rec(148)
   out(i).param.scan_change = rec(149)
   out(i).param.mmaf_stat = string(rec(150))
  endif

  if (strpos(label.instrument_id,'PEM') eq 0) then begin     ; For PEM 3TP

    if (strpos(label.data_subtype,'MEPS') eq 0) then begin   ; PEM MEPS

      out(i).param.time1 = long(rec(68:75),0,2)
      out(i).param.lat1 = float(rec(76:79),0)
      out(i).param.lon1 = float(rec(80:83),0)
      out(i).param.time2 = long(rec(84:91),0,2)
      out(i).param.lat2 = float(rec(92:95),0)
      out(i).param.lon2 = float(rec(96:99),0)
      out(i).param.data = float(rec(100:11363),0,32*88)
      out(i).param.stdev = float(rec(11364:22627),0,32*88)

    endif else begin					     ; PEM HEPS

      if (strpos(label.data_subtype,'ELEC') eq 5) then begin ; HEPS electrons
        if (i eq 0) then begin				     ; Record number 1
          out.rec1.satellite_id = string(rec(0:3))
          out.rec1.record_type = string(rec(4:5))
          out.rec1.instrument_id = string(rec(6:17))
          out.rec1.phys_rec_count = string(rec(18:25))
          out.rec1.max_32bit_words = long(rec(28:31),0)
          out.rec1.time = long(rec(40:47),0,2)
          out.rec1.lat = float(rec(48:51),0)
          out.rec1.lon = float(rec(52:55),0)
          out.rec1.num_32bit_words = long(rec(64:67),0)
          out.rec1.deposit_alt = float(rec(68:71),0)
          out.rec1.dipole_lat = float(rec(72:75),0)
          out.rec1.dipole_lon = float(rec(76:79),0)
          out.rec1.num_alphas = long(rec(80:83),0)
          out.rec1.alpha_params = float(rec(84:163),0,20)
        endif else begin				     ; All other records
          out.recn(i-1).satellite_id  = string(rec(0:3))
          out.recn(i-1).record_type = string(rec(4:5))
          out.recn(i-1).instrument_id = string(rec(6:17))
          out.recn(i-1).phys_rec_count = string(rec(18:25))
          out.recn(i-1).max_32bit_words = long(rec(28:31),0)
          out.recn(i-1).time = long(rec(40:47),0,2)
          out.recn(i-1).lat = float(rec(48:51),0)
          out.recn(i-1).lon = float(rec(52:55),0)
          out.recn(i-1).num_32bit_words = long(rec(64:67),0)
          out.recn(i-1).data = float(rec(68:419),0,88)
          out.recn(i-1).stdev = float(rec(420:771),0,88)
          out.recn(i-1).j1_fit = float(rec(772:795),0,6)
          out.recn(i-1).j2_fit = float(rec(796:819),0,6)
          out.recn(i-1).g1_fit = float(rec(820:843),0,6)
          out.recn(i-1).g2_fit = float(rec(844:867),0,6)
          out.recn(i-1).sigma_fit = float(rec(868:891),0,6)
          out.recn(i-1).chi2_fit = float(rec(892:915),0,6)
          out.recn(i-1).i_type_fit = long(rec(916:939),0,6)
        endelse
 
      endif else begin					     ; HEPS protons
        if (i eq 0) then begin				     ; Record number 1
          out.rec1.satellite_id = string(rec(0:3))
          out.rec1.record_type = string(rec(4:5))
          out.rec1.instrument_id = string(rec(6:17))
          out.rec1.phys_rec_count = string(rec(18:25))
          out.rec1.max_32bit_words = long(rec(28:31),0)
          out.rec1.time = long(rec(40:47),0,2)
          out.rec1.lat = float(rec(48:51),0)
          out.rec1.lon = float(rec(52:55),0)
          out.rec1.num_32bit_words = long(rec(64:67),0)
          out.rec1.deposit_alt = float(rec(68:71),0)
          out.rec1.dipole_lat = float(rec(72:75),0)
          out.rec1.dipole_lon = float(rec(76:79),0)
        endif else begin				     ; All other records
          out.recn(i-1).satellite_id  = string(rec(0:3))
          out.recn(i-1).record_type = string(rec(4:5))
          out.recn(i-1).instrument_id = string(rec(6:17))
          out.recn(i-1).phys_rec_count = string(rec(18:25))
          out.recn(i-1).max_32bit_words = long(rec(28:31),0)
          out.recn(i-1).time = long(rec(40:47),0,2)
          out.recn(i-1).lat = float(rec(48:51),0)
          out.recn(i-1).lon = float(rec(52:55),0)
          out.recn(i-1).num_32bit_words = long(rec(64:67),0)
          out.recn(i-1).data = float(rec(68:419),0,88)
          out.recn(i-1).stdev = float(rec(420:771),0,88)
          out.recn(i-1).j1_fit = float(rec(772:787),0,4)
          out.recn(i-1).j2_fit = float(rec(788:803),0,4)
          out.recn(i-1).g1_fit = float(rec(804:819),0,4)
          out.recn(i-1).g2_fit = float(rec(820:835),0,4)
          out.recn(i-1).sigma_fit = float(rec(836:851),0,4)
          out.recn(i-1).chi2_fit = float(rec(852:867),0,4)
          out.recn(i-1).i_type_fit = long(rec(868:883),0,4)
        endelse

      endelse
    endelse
  endif								; End PEM 3TP

  if (strpos(label.instrument_id,'WINDII') eq 0) then begin	; For WINDII 3TP
    out(i).param.job_version = string(rec(68:75))
    out(i).param.cdb_version = string(rec(76:83))
    out(i).param.inv_quantity = rec(84)
    out(i).param.temp_source = rec(85)
    for k=0,(4*out(i).num_32bit_words-18)/5 - 1 do begin
      out(i).param.filter_number(k) = rec(5*k+86)
      out(i).param.filter_quality(k) = long(rec(5*k+87:5*k+90),0)
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
message3: message, "must use a Level 3TP *PROD or *META file."

bye: ;Exit program
free_lun, unit

end
