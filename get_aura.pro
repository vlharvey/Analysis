FUNCTION HandleAttribute, FileId, dataname, attrname, data

geo_group = "Geolocation Fields"
dat_group = "Data Fields"

;; get the swathname
swathname = h5g_get_member_name(FileId, '/HDFEOS/SWATHS/', 0)

;; set counter for number of attempted reads
NPASS = 1

;; if attrname is not a string type (i.e./attrname) then get attribute data
IF SIZE(/TYPE, attrname) NE SIZE(/TYPE,"") THEN $
  BEGIN
    attrname = dataname
    NPASS = 1 ;; group attribute
END ELSE BEGIN
    NPASS = 6 ;; dataset attribute 
END


;; on error jumps back to this line
CATCH, error_statusa

IF  error_statusa NE 0 THEN $
  BEGIN
    MESSAGE,/informational, "Trying new name..."
    CATCH, error_statusa, /cancel
    NPASS = NPASS + 1 
ENDIF 

;; create HDF path to variable
IF NPASS EQ 1 THEN GrpName = '/HDFEOS/ADDITIONAL/FILE_ATTRIBUTES/'
IF NPASS EQ 2 THEN GrpName = '/HDFEOS/SWATHS/' + swathname + '/'
IF NPASS EQ 3 THEN GrpName = '/HDFEOS/SWATHS/'
IF NPASS EQ 4 THEN GrpName = '/HDFEOS/'
IF NPASS EQ 5 THEN GrpName = '/HDFEOS/ADDITIONAL/FILE_ATTRIBUTES/'
IF NPASS EQ 6 THEN DsName  = '/HDFEOS/SWATHS/' + swathname + '/' + geo_group + '/' + dataname +'/'
IF NPASS EQ 7 THEN DsName  = '/HDFEOS/SWATHS/' + swathname + '/' + dat_group + '/' + dataname +'/'   

IF NPASS GT 7 THEN $
  BEGIN 
    print, attrname + ' not found.. Sorry!' 
    CATCH,/cancel
    RETURN, -1
END

CASE 1 OF
    NPASS LE 4: BEGIN ;; Group
        print, "Attempting to read..", GrpName + attrname 
        GrpId = h5g_open(FileId, GrpName)
        AtId  = h5a_open_name(GrpId, attrname)
        data  = h5a_read(AtId)
        h5a_close, AtId
        h5g_close, GrpId
    END
    ELSE :BEGIN ;; Dataset
        print, "Attempting to read..", DsName + attrname
        DsId  = h5d_open(fileid, DsName)
        AtId  = h5a_open_name(DsId, attrname)
        data  = h5a_read(AtId)
        h5a_close, AtId
        h5d_close, DsId
    END
ENDCASE

RETURN, 0
END

Function HandleDataField, FileId, dataname, data
;; get named data field

geo_group = "Geolocation Fields"
dat_group = "Data Fields"

;; get the swath name
swathname = h5g_get_member_name(FileId, '/HDFEOS/SWATHS/', 0)

;; set counter for number of attempted reads
NPASS = 1

;; on error jumps back to this line
CATCH, error_statusd

IF  error_statusd NE 0 THEN $
  BEGIN
    MESSAGE,/informational, "Trying new name..."
    CATCH, error_statusd, /cancel
    NPASS = NPASS + 1
ENDIF 

;; create HDF path to variable
IF NPASS EQ 1 THEN DsName ='/HDFEOS/SWATHS/' + swathname + '/' + geo_group + '/' + dataname
IF NPASS EQ 2 THEN DsName ='/HDFEOS/SWATHS/' + swathname + '/' + dat_group + '/' + dataname

IF NPASS GT 2 THEN $
  BEGIN 
    print, dataname + ' not found.. Sorry!' 
    CATCH,/cancel 
    RETURN, -1
END

print, "Attempting to read..", DsName 
DsId = h5d_open(fileid, DsName)

DspId = h5d_get_space(DsId)
Dims  = h5s_get_simple_extent_dims(DspId)
h5s_close, DspId

dspidm = h5s_create_simple(dims)
data = h5d_read(dsid, FILE_SPACE=dspidm)
h5s_close, DspIdM
h5d_close, DsId

data = reform(data)

RETURN, 0
END

FUNCTION get_aura, file, varname, data, attrname=attrname
;+
; NAME:
;	GET_AURA
;
; PURPOSE:
;       extract data from Aura style HDF5-EOS file
;
; CATEGORY:
;	HDF5-EOS file reader
;
; CALLING SEQUENCE:
;       status = GET_AURA(file, varname, data)
;
; INPUTS:
;       file is the file name
;       varname is the HDF5-EOS object
;       
; KEYWORD PARAMETERS:
;       swathname is the HDF5-EOS swath (defaults to 'HIRDLS')
;       attribute must be set if varname is an attribute object (GET_AURA,/attribute, ...)
; OUTPUTS:
;	data is the returned IDL data variable name
;       returns 0 for success and -1 for failure
;
; EXAMPLES:
;
; 1) extract datsets
;
; extract the HIRDLS 'Temperature' dataset and put into variable t
; status = get_aura('HIRDLS.he5','Temperature',t)
; 
; extract the MLS 'Latitude' dataset and put into variable lats 
; status = get_aura('MLS.he5','Latitude',lats)
;
; 2) extract attributes associated with a particular dataset
;
; extract the 'Units' attribute from the 'Temperature' dataset and put into variable x
; status = get_aura('HIRDLS.he5','Temperature', x, attr='Units')
;
; 3) extract attributes associated with groups 
;
; extract the 'InstrumentName' attribute and put into variable x 
; status = get_aura('HIRDLS.he5','InstrumentName', x, /attr)
;
; extract the 'GranuleMonth' attribute and put into variable x
; status = get_aura('HIRDLS.he5','GranuleMonth', x, /attr);
;
;
; MODIFICATION HISTORY:
;       AL 1-NOV-2003 revised version of get_sw_data5.pro
;       AL 4-NOV-2003 added swath name recognition
;-


FileId = h5f_open(file)
IF FileId EQ -1 THEN MESSAGE, "File does not exist."

CASE N_ELEMENTS(attrname) OF
    0:    status = HandleDataField(FileId, varname, data)
    ELSE: status = HandleAttribute(FileId, varname, attrname, data)
ENDCASE

h5f_close,FileId

RETURN, status
END
