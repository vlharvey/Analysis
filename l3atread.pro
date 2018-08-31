;     *******************************************************************
;     *                            NOTICE                               * 
;     *                            ======                               * 
;     *  THIS PROGRAM WAS WRITTEN BY HUGH C. PUMPHREY AT THE            *
;     *  DEPARTMENT OF METEOROLOGY AT THE UNIVERSITY OF EDINBURGH.      *
;     *  EMAIL ADDRESS H.C.Pumphrey@ed.ac.uk or hcp@met.ed.ac.uk        *
;     *                                                                 *
;     *  YOU MAY USE THIS PROGRAM AT YOUR OWN RISK AND MODIFY IT FOR    *
;     *  YOUR OWN PURPOSES ON THE CONDITION THAT YOU DO NOT REMOVE      *
;     *  THIS NOTICE.                                                   *
;     *******************************************************************

; Read a level 3 at file. This program should read any l3at file ,
; putting all the data into a structure. It can read both sequential
; (jpl) and direct-access (DAAC) versions of a file and does NOT need
; a DAAC-style metadata file to suss out the record length.  It works
; on a VMS version of IDL and on UNIX versions of either IDL or
; PV-WAVE. It also works with files from BADC, where the records have
; been padded out to a standard length.

; use /fast to speed things up if you KNOW that the file contains no
; NaNs 
; use /swap if you are running Digital Unix or any similar system
; which has the opposite endian-ism to Solaris and IRIX
; See the file README.idl for more documentation

pro l3atread,data,filename,fast=fast,swap=swap,append=append,$
                 duplicate=duplicate,verbose=verbose

if n_params() lt 2 then begin
  filename='********'
  print,'Enter file name'
  read,filename
endif
junk=bytarr(4)
junkstr='****'
openr,unitno,filename,/get_lun
if (n_elements(verbose) ne 1) then verbose=0

; Start code to find record length.
if(!Version.os_family eq 'vms') then begin
    ;; This is easy. VMS stores this as part of the filesystem
    file_status=fstat(unitno)
    reclen=file_status.rec_len
    close,unitno
    access='direct'
endif else begin
    ;;This bit works on several unices. Never tested on WinDoze or
    ;;MacOS. Anyone who has IDL on such a machine, Ild be grateful if
    ;;you could either (a) report that this works or (b) fix it so
    ;;that it does!
    ;; Find first occurrance of "UARS" (the first 4 bytes of a record
    ;; are always "UARS", except for the first record) 
    j=0
    while j le 4000 and (not eof(unitno)) and junkstr ne 'UARS' do begin
        readu,unitno,junk
        junkstr=string(junk)
        j=j+1
    endwhile

    if (junkstr ne 'UARS') then begin
        print,'This is not a UARS level 3 file (no occurance of UARS)'
        stop
    endif
    firstindex=j
;    print,'First occurrance of UARS at ',firstindex
; Find Second occurrance of 'UARS'
    junkstr='****'
    while j le 4000 and (not eof(unitno)) and junkstr ne 'UARS' do begin
        readu,unitno,junk
        junkstr=string(junk)
        j=j+1
    endwhile
;    print,'second occurrance of UARS at',j
; This is the record length in long (4 byte) words
    reclen=long(j-firstindex)
;    print,'reclen=',reclen,' words ',reclen*4,' bytes' 
    
    if (reclen eq firstindex-1) then begin
        access='direct'
        if(verbose) then print,'This is a direct access file'
    endif else if reclen eq firstindex-2 then begin
        access='sequential'
        reclen=reclen-long(2)
        if(verbose) then   print,'This is a sequential file'
    endif else begin
        stop,'This is not a UARS level 3 file (Cannot sort out record length)'
    endelse

    if verbose then print,'reclen=',reclen

    close,unitno
    reclen=reclen*long(4)    

endelse
; Now we have determined the record length and the access type we can 
; read in the information record (the second record in the file)

junk=bytarr(reclen)
;if access eq 'sequential' then begin
;  openr,unitno,filename,/f77_unformatted
;endif else begin
  openr,unitno,filename
;endelse


; longdummy is used for the 4-byte integer which is used in UNIX sequential
; unformatted files to show the record lengths. We don't make use of it here
; because l3at files have fixed-lenth records and some are supplied in
; direct-access format (and therefore don't have this number in them)
longdummy=long(0)

if access eq 'sequential' then begin
;  readu,unitno,junk ; sfdu record Not useful, discarded at once
;  readu,unitno,junk ; Information record
  point_lun,unitno,reclen+8
  readu,unitno,longdummy,junk,longdummy ; Information record
endif else begin
  point_lun,unitno,reclen
  readu,unitno,junk ; Information record
endelse
  
infstr=string(junk)

; Extract individual bits of info from info string
satid   =   strmid(infstr,0,4)		;always UARS
rectyp  =   strmid(infstr,4,2)
instid  =   strmid(infstr,6,12)		;Instrument (MLS, CLAES etc)
specst  =   strmid(infstr,18,12)	;Species (H2O, O3_205 etc)
forvno  =   strmid(infstr,30,4)
reccnt  =   strmid(infstr,34,8)
nconrc  =   strmid(infstr,42,4)
nrecs   =   strmid(infstr,46,8)		;Number of Records INCLUDING info
fctime  =   strmid(infstr,54,23)
year1   =   strmid(infstr,77,3)
doy1    =   strmid(infstr,80,3)
time1   =   strmid(infstr,83,8)
year2   =   strmid(infstr,91,3)
doy2    =   strmid(infstr,94,3)
time2   =   strmid(infstr,97,8)
datlev  =   strmid(infstr,105,3)
uarsdayst=  strmid(infstr,108,4)
recpts  =   strmid(infstr,112,4)
fstpt   =   strmid(infstr,116,4)
oldreclen  =   strmid(infstr,120,5)  
ccbvno  =   strmid(infstr,125,9)

specst=strupcase(specst)
if verbose then begin
    print,'SATID==',satid,'=='
    print,'rectyp=',rectyp,'=='
    print,'instid=',instid,'=='
    print,'specst=',specst,'=='
    print,'reccnt=',reccnt,'=='
    print,'nconrc=',nconrc,'=='
    print,'nrecs==',nrecs,'=='
    print,'fctime==',fctime,'=='
    print,'datlev=',datlev,'=='
    print,'uarsd =',uarsdayst,'=='
    print,'recpts=',recpts,'=='
    print,'fstpt =',fstpt,'=='

    print,'oldrec=',oldreclen,'=='

    print,'ccbvno=',ccbvno,'=='
endif

if datlev ne '3AT' then begin
  stop,'This is not a level 3 at file'
endif

if verbose then begin
    print,'Actual record length = ',reclen,' stated record lenth=',oldreclen
    Print,'Base_index is ',fstpt, recpts, ' Points in record '
endif
; Work out what size the data set is.
nrecords=long(nrecs) - 1
nlevels=long(recpts)

;; Check whether we are appending this data set to a previous one. 
if(n_elements(append) gt 0) then begin
    if verbose then print,'appending to given structure'
    if(nlevels eq append(0).totpts and  $
       strmid(specst,0,8) eq string(append(0).reccnt)) then begin
        offset=n_elements(append)        
        data=[append,replicate(append(0),nrecords)]
        prof=data(0)
    endif else begin
        print,'l3atread: you tried to append an incompatible file'
        print,'nlevels (old data)=',nlevels,' new data=',append(0).totpts
        print,'specst=**',strmid(specst,0,8),'**  Old file has **', $
          string(append(0).reccnt),'**'
        return
    endelse
endif else if n_elements(duplicate) gt 0 then begin
    if verbose then print,'duplicating structure'
    if(nlevels eq duplicate(0).totpts and  $
       strmid(specst,0,8) eq string(duplicate(0).reccnt)) then begin
        offset=0        
        data=replicate(duplicate(0),nrecords)
        prof=data(0)
    endif else begin
        print,'l3atread: you tried to duplicate an incompatible file'
        print,'nlevels (old data)=',nlevels,' new data=',append(0).totpts
        print,'specst=**',strmid(specst,0,8),'**  Old file has **', $
          string(append(0).reccnt),'**'
        return
    endelse
endif else begin
    if verbose then print,'Defining new structure'
; Define an UNNAMED structure for one profile. ( The use of an unnamed
; structure prevents trouble if you read in several types of l3at file
; with different record lengths IDL and WAVE have different syntax for
; doing this so you have to do it in a function or subroutine)
    if (!PROMPT eq 'IDL> ') then begin
        prof=getprof_idl(nlevels)
    endif else if (!PROMPT eq 'WAVE> ') then begin
        prof=getprof_wave(nlevels)
    endif else begin
        print,'I dont know if you are running PV-WAVE or IDL, '+ $
          'you have altered !PROMPT'
        stop
    endelse
    data=replicate(prof,nrecords)
    offset=long(0)
endelse
on_ioerror,errlabel
; Read in the data records
record=long(0)
while record lt nrecords and (not eof(unitno)) do begin
;while (not eof(unitno)) do begin

  if access eq 'sequential' then begin
	point_lun,unitno,(record+long(2))*(reclen+8)
	readu,unitno,longdummy,prof,longdummy
  endif else begin	

      point_lun,unitno,(record+long(2))*reclen
      readu,unitno,prof
  endelse


  data(record+offset)=prof
;  print,'Read record no.',record
   record=record+1
endwhile 
on_ioerror,null
errlabel:

; The field satid is the same in all profiles and the field reccnt is
; of no interest. Some other things 
; are stored no-where. We use satid and reccnt to store other things

data(offset:offset+record-1).reccnt=junk(18:18+7) ; species
data(offset:offset+record-1).satid=[junk(108:108+3)] ; UARS day

vstring=strcompress(ccbvno,/remove_all)
vstlen=strlen(vstring)
if vstlen gt 6 then vstlen=6
if vstlen eq 6 then vstring=strmid(vstring,0,6)
instid=strmid(instid,0,12-vstlen-1) + 'V'+vstring
data(offset:offset+record-1).instid=byte(instid)


; spare is 2 spare bytes. We use it for the base index.

; For digital unix (and maybe x86 Linux) it is worth editing this line to
; set swap=1 to be the default. For SPARC Solaris, SGI Irix,  set swap=0
if(n_elements(swap) ne 1) then swap=0

; truncate data set to actual lenth of file, swapping endianism if needed
if(swap eq 1) then begin
  data=swap_endian(data(offset:offset+record-1))
endif else begin
  data=data(offset:offset+record-1)
endelse

data(offset:offset+record-1).spare=fix(fstpt)


free_lun,unitno
bad=fltarr(nlevels) - 99.0
if(n_elements(fast) eq 0) then begin 
    for rec=long(0)+offset,offset+record-1 do begin
;   Replace NaNs with -99.0. This prevents some irritating crashes.
        bad=where ( 1-finite(data(rec).qu))
        if bad(0) ge 0 then data(rec).qu(bad)=-99.0
        bad=where ( 1-finite(data(rec).err))
        if bad(0) ge 0 then data(rec).err(bad)=-99.0
    endfor
endif


end


