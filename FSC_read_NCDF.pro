;+; NAME:; FSC_Read_NCDF;; PURPOSE:; Use this function to read the contents of a NETCDF format file.  This function; is simply a wrapper around David Fanning's NCDF_DATA::ReadFile() method.;; REQUIREMENTS:; NCDF_DATA__DEFINE from http://www.dfanning.com/;; CALLING SEQUENCE:; result = FSC_READ_NCDF(file, [SUCCESS = variable], [EXTRA KEYWORDS]);; RETURNED VALUE:; Returns an data structure of the file contents or -1 if an error occurs.;; ARGUMENTS:; FILE  The fully qualified file name to read. If the file doesn't exist the;   routine will return as a failure.; ; KEYWORDS:; SUCCESS Set this equal to a named variable to retrieve a flag indicating a;   successful read.  This flag is non-zero for a successful read.; EXTRA KEYWORDS may be passed through to the NCDF_DATA::INIT() method. ;; MODIFICATION HISTORY:; 2008-03-11 BT written for IDL6.3;-
  FUNCTION FSC_Read_NCDF, File, $	SUCCESS = success, _EXTRA = extra  ncdf_obj = 0    CATCH, error  IF error NE 0 THEN BEGIN    IF OBJ_VALID(ncdf_obj) THEN OBJ_DESTROY, ncdf_obj    SUCCESS = 0    RETURN, -1  ENDIF    IF (FILE_TEST(file[0]) EQ 0) THEN BEGIN    MESSAGE, "File not found: " + file[0], /CONTINUE    SUCCESS = 0    RETURN, -1  ENDIF      ncdf_obj = OBJ_NEW("NCDF_DATA", file, _EXTRA = extra)  d = ncdf_obj->ReadFile(SUCCESS = success)  OBJ_DESTROY, ncdf_obj    RETURN, dEND; FSC_Read_NCDF