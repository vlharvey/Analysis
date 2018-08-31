FUNCTION loadauradata, file, VarNames, sorig

;; reads datasets from the VarNames from Aura HDF-EOS5 file 
;; returns a structure containing the datasets
;; some structure tag names are shortened
;; sorig is an optional structure to be extended with new data

;shortname : dataset name
;.T        : Temperaure
;.P        : Pressure
;.lat      : Latitude
;.lon      : Longitude
;.sza      : SolarZenithAngleolar 
;.lst      : LocalSolarTime
;all other structure items have the same tagnames as dataset names

IF N_ELEMENTS(sorig) EQ 0 THEN extend=0 ELSE extend=1
IF extend THEN s = sorig

;; read a dataset given in the VarNames from Aura HDF-EOS5 file 

;; list of variable names that need shortening
VNLIST= ['Temperature', 'Pressure', 'Latitude', 'Longitude', 'SolarZenithAngle', 'LocalSolarTime']

;; list of short variable names
SVNLIST = ['T', 'P', 'lat', 'lon', 'sza', 'lst']


;; loop over variable names, read variable, append to structure
FOR iv = 0,N_ELEMENTS(VarNames)-1 DO $
  BEGIN

    VarName = VarNames(iv)

;; read the VarName into x
    status = GET_AURA(file, VarName, x)
    IF status NE 0 THEN MESSAGE,'DataSet..' + VarName

;; make the short name for the structure variable
    ShortVarName = VarName

    q = WHERE(VarName EQ VNLIST)
    IF q(0) NE -1 THEN ShortVarName = SVNLIST(q(0))

;; replace a start digit with "_"digit and "." with "_"
    IF STRMATCH(STRMID(ShortVarName, 0, 1), '[0-9]') THEN ShortVarName = '_' + ShortVarName
    IF STRMATCH(ShortVarName, '*.*') THEN ShortVarName = STRJOIN(STRSPLIT(ShortVarName,'.',/EXTRACT),'_')

;; create structure with x or append x to structure
    IF iv EQ 0 AND NOT(extend) THEN s = CREATE_STRUCT(ShortVarName, x) ELSE s = CREATE_STRUCT(s, ShortVarName, x)

ENDFOR

RETURN, s
END
