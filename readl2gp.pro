;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;+
; This funtion returns a structure containing the information in an
; mls l2gp swath in the file given by filename.
; <p>
; The first (often only) swath in the file is returned unless the user
; supplies a value for swathName. In either case, the name of the
; swath read is returned into swathName.
; <p>
; Error checking has been omitted in favor of clarity.
; <p>
; Make sure to check file exists
;
; @param filename        {type=String}
;                        The name of the HDF file to read.
; @keyword swathName     {type=String}
;                        The name of the HDF-EOS swath.
; @keyword variableName  {type=String}
;                        The name of the regular HDF variable entry.
; @keyword precisionName {type=String}
;                        The name of the regular HDF precision entry.
;
; @author Nathaniel Livesey
; @version $Revision: 1.12 $ $Date: 2004/11/09 15:21:22 $
;-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
function readl2gp, filename, swathName=swathName, $
                   variableName=variableName, $
                   precisionName=precisionName

Compile_Opt idl2

OpenR, unit, filename, /GET_LUN, error=err
IF err NE 0 THEN Return, 0 ELSE Free_LUN, unit

; Setup the defaults
IF N_Elements(variableName) EQ 0 THEN BEGIN
  variableName = 'L2gpValue'
  precisionName = 'L2gpPrecision'
ENDIF ELSE BEGIN
  IF N_Elements(precisionName) EQ 0 THEN $
    precisionName = variableName + 'Precision'
ENDELSE

; IF this is an hdf 5 file open it that way
atts = ''
IF h5f_is_hdf5(filename) THEN BEGIN
  ;; This is an hdf5 file
  fileID = H5F_Open(filename)

  ;; Query the swaths group
  groupName = 'HDFEOS/SWATHS'
  noSwaths = H5G_Get_NMembers(fileID, groupName)

  IF noSwaths LE 0 THEN BEGIN
    H5F_Close, fileID
    MyMessage, /ERROR, 'No swaths in file'
  ENDIF

  ;; Identify the swath we want
  swathIndex = 0
  IF N_Elements(swathName) NE 0 THEN BEGIN
    REPEAT BEGIN
      thisName = H5G_Get_Member_Name(fileID, groupName, swathIndex)
      swathIndex = swathIndex + 1
    ENDREP UNTIL swathIndex EQ noSwaths OR thisName EQ swathName
    IF thisName NE swathName THEN BEGIN
      H5F_Close, fileID
      MyMessage, /ERROR, 'No such swath in file'
    ENDIF
  ENDIF ELSE swathName = H5G_Get_Member_Name(fileID, groupName, 0)

  ;; Now attach to this group
  swathID = H5G_Open(fileID, groupName+'/'+swathName)

  ;; Get the geolocation fields
  ;; First open the group and get all of its members
  gField = 'Geolocation Fields'
  geoLocID = H5G_Open(swathID, gField)
  nMembers = H5G_Get_NMembers(swathID, gField)
  IF nMembers GT 0 THEN BEGIN
    members = StrArr(nMembers)
    FOR i = 0, nMembers - 1 DO BEGIN
      members[i] = H5G_Get_Member_Name(swathID, gField, i)
    ENDFOR
  ENDIF ELSE members = ''

  ;; These ones have to be present
  datasets = ['Time', 'Latitude', 'Longitude']
  FOR i = 0, N_Elements(datasets) - 1 DO BEGIN
    dsID = H5D_Open(geoLocID, datasets[i])
    temp = H5D_Read(dsID)
    H5D_Close, dsID
    CASE datasets[i] OF
      'Time'      : time = temp
      'Latitude'  : latitude = temp
      'Longitude' : longitude = temp
    ENDCASE
  ENDFOR

  ;; Sort out the dimensions of time
  nTimes = N_Elements(time)

  ;; The rest might be omitted for some files so tread carefully
  datasets = ['ChunkNumber', 'LineOfSightAngle', 'LocalSolarTime', $
              'OrbitGeodeticAngle', 'SolarZenithAngle']
  type =     ['l',           'f',                'f', $
              'f',                  'f']
  FOR i = 0, N_Elements(datasets) - 1 DO BEGIN
    IF (Where(members EQ datasets[i]))[0] NE -1 THEN BEGIN
      dsID = H5D_Open(geoLocID, datasets[i])
      temp = H5D_Read(dsID)
      H5D_Close, dsID
    ENDIF ELSE BEGIN
      temp = type[i] EQ 'f' ? FltArr(nTimes) : LonArr(nTimes)
    ENDELSE
    
    CASE datasets[i] OF
      'ChunkNumber'        : chunkNumber = temp
      'LineOfSightAngle'   : lineOfSightAngle = temp
      'LocalSolarTime'     : localSolarTime = temp
      'OrbitGeodeticAngle' : orbitGeodeticAngle = temp
      'SolarZenithAngle'   : solarZenithAngle = temp
    ENDCASE
  ENDFOR

  ;; Sort out dimensions of fields that don't already exist
  datasets = ['Pressure', 'Frequency']
  FOR i = 0, N_Elements(datasets) - 1 DO BEGIN
    IF (Where(members EQ datasets[i]))[0] NE -1 THEN BEGIN
      dsID = H5D_Open(geoLocID, datasets[i])
      temp = H5D_Read(dsID)
      H5D_Close, dsID
      cnt = N_Elements(temp)
    ENDIF ELSE cnt = 0
    IF cnt EQ 0 THEN temp = [0.0]

    CASE datasets[i] OF
      'Pressure'  : BEGIN
        pressure = temp
        nLevels = cnt
      END
      'Frequency' : BEGIN
        frequency = Double(temp)
        nFreqs = cnt
      END
    ENDCASE
  ENDFOR

  H5G_Close, geoLocID

  ;; Get the data fields
  ;; First open the group and get all of its members will come in
  ;; handy when looking for status/quality
  gField = 'Data Fields'
  dataID = H5G_Open(swathID, gField)
  nMembers = H5G_Get_NMembers(swathID, gField)
  IF nMembers GT 0 THEN BEGIN
    members = StrArr(nMembers)
    FOR i = 0, nMembers - 1 DO BEGIN
      members[i] = H5G_Get_Member_Name(swathID, gField, i)
    ENDFOR
  ENDIF ELSE members = ''

  ;; These two are always members.  We also want the attributes for
  ;; the variableName
  dsID = H5d_Open(dataID, variableName)
  l2gpValue = H5D_Read(dsId)
  FOR i = 0, H5A_Get_Num_Attrs(dsId) - 1 DO BEGIN
    attId = H5A_Open_Idx(dsId, i)
    atts = i EQ 0 ? Create_Struct(H5A_Get_Name(attId), H5A_Read(attId)) : $
                    Create_Struct(atts, H5A_Get_Name(attId), H5A_Read(attId))
    H5A_Close, attId
  ENDFOR
  H5D_Close, dsId
  dsID = H5d_Open(dataID, precisionName)
  l2gpPrecision = H5D_Read(dsId)
  H5D_Close, dsId  

  ;; Get status and quality if presents
  datasets = ['Status', 'Quality']
  type     = ['l',      'f']
  FOR i = 0, N_Elements(datasets) - 1 DO BEGIN
    IF (Where(members EQ datasets[i]))[0] NE -1 THEN BEGIN
      dsID = H5D_Open(dataID, datasets[i])
      temp = H5D_Read(dsID)
      H5D_Close, dsID
    ENDIF ELSE BEGIN
      temp = type EQ 'l' ? LonArr(nTimes) : FltArr(nTimes)
    ENDELSE

    CASE datasets[i] OF 
      'Status' : status = temp
      'Quality' : quality = temp
    ENDCASE
  ENDFOR

  H5G_Close, dataID

  ;; Close group, file
  H5G_Close, swathID
  H5F_Close, fileID

ENDIF ELSE BEGIN
  ;; This is an hdf4 file
  ;; First open the file.
  fileID = EOS_SW_Open(filename)

  ;; IF the user didn't ask for a specific swath name, get the first one.
  IF NOT Keyword_Set(swathName) THEN BEGIN
    noSwaths = EOS_SW_InqSwath(filename, swathNames)
    swathNames = StrSplit(swathNames, ',', /EXTRACT)
    swathName = swathNames[0]
  ENDIF

  ;; Attach to this swath
  swathID = EOS_SW_Attach(fileID, swathName)
  IF swathID LE 0 THEN BEGIN
    dummy = EOS_SW_Close(fileID)
    Return, 0
  ENDIF

  ;; Here we should do a full survey of the swath to make sure it is a
  ;; genuine l2gp swath.  As this is example code, we'll simply press on
  ;; assuming that it is.

  ;; Get the dimensions, a value of -1 indicates no variation in given
  ;; direction.
  nTimes = EOS_SW_DimInfo(swathID, 'nTimes')
  nLevels = EOS_SW_DimInfo(swathID, 'nLevels')
  nFreqs = EOS_SW_DimInfo(swathID, 'nFreqs')

  ;; Now get the horizontal coordinate information
  dummy = EOS_SW_ReadField(swathID, 'Latitude', latitude)
  dummy = EOS_SW_ReadField(swathID, 'Longitude', longitude)
  dummy = EOS_SW_ReadField(swathID, 'Time', time)
  dummy = EOS_SW_ReadField(swathID, 'LocalSolarTime', LocalSolarTime)
  dummy = EOS_SW_ReadField(swathID, 'SolarZenithAngle', solarZenithAngle)
  dummy = EOS_SW_ReadField(swathID, 'LineOfSightAngle', lineOfSightAngle)
  dummy = EOS_SW_ReadField(swathID, 'OrbitGeodeticAngle', orbitGeodeticAngle)
  dummy = EOS_SW_ReadField(swathID, 'ChunkNumber', chunkNumber)

  ;; Now get the vertical coordinate information if any to get
  IF nLevels GT 0 THEN BEGIN
    dummy = EOS_SW_ReadField(swathID, 'Pressure', pressure)
  ENDIF ELSE pressure = [0.0]

  ;; Now get the frequency coordinate if any
  IF nFreqs GT 0 THEN BEGIN
    dummy = EOS_SW_ReadField(swathID, 'Frequency', frequency) 
  ENDIF ELSE frequency = [0.0d0]

  ;; Now read the data fields
  dummy = EOS_SW_ReadField(swathID, variableName, l2gpValue)
  dummy = EOS_SW_InqAttrs(fileID, attrList, length=len)

;   FOR i = 0, len - 1 DO BEGIN
;     dummy = EOS_SW_readattr(swathID, attrList[i], temp)
;     atts = i EQ 0 ? Create_Struct(attrList[i], temp) :  Create_Struct(atts, attrList[i], temp)
;   ENDFOR
;  dummy = EOS_SW_getfillvalue(swathID, variableName, fillValue)
  dummy = EOS_SW_ReadField(swathID, precisionName, l2gpPrecision)
  dummy = EOS_SW_ReadField(swathID, 'Status', status)
  dummy = EOS_SW_ReadField(swathID, 'Quality', quality)

  IF N_Elements(status) EQ 0 THEN status = lonarr(nTimes)
  IF N_Elements(quality) EQ 0 THEN quality = FltArr(nTimes)

  ;; Now detach from the swath and close the file
  dummy = EOS_SW_Detach(swathID)
  dummy = EOS_SW_Close(fileID)

ENDELSE

;; Clear status if all values are 71 (a remnant of an old attempt)
temp = status[Uniq(status, Sort(status))]
IF N_Elements(temp) EQ 1 AND temp[0] EQ 71 THEN status[*] = 0


;; Now construct the result
result = {swathName:swathName, $
          nTimes:nTimes, $
          nLevels:nLevels, $
          nFreqs:nFreqs, $
          $
          pressure:pressure, $
          frequency:frequency, $
          $
          latitude:latitude, $      
          longitude:longitude, $       
          time:time, $              
          localSolarTime:localSolarTime, $    
          solarZenithAngle:solarZenithAngle, $
          lineOfSightAngle:lineOfSightAngle, $      
          orbitGeodeticAngle:orbitGeodeticAngle, $    
          chunkNumber:chunkNumber, $
          $
          l2gpValue:l2gpValue, $
          l2gpPrecision:l2gpPrecision, $
          status:status, $
          quality:quality, $
          attributes:atts }
;; That's it
close,unit
Return, result
END

;; $Log: readl2gp.pro,v $
;; Revision 1.12  2004/11/09 15:21:22  livesey
;; Bug fix, added call to H5A_Close
;;
;; Revision 1.11  2004/09/29 20:12:38  fullerr
;; Made so it is a stand-alone procedure
;;
;; Revision 1.10  2004/03/30 21:19:49  fullerr
;; Changed made all quantities with status flags being 71 set to 0
;;
;; Revision 1.9  2004/03/18 19:10:45  livesey
;; Minor HDF4 change to new status type.
;;
;; Revision 1.8  2004/03/18 18:41:26  fullerr
;; Fixed a bug obtaining Quality from hdf5 and did some reformatting
;;
;; Revision 1.7  2004/02/23 18:18:50  fullerr
;; Reomved latest change for he4 files (left he5)
;;
;; Revision 1.6  2004/02/21 01:24:46  fullerr
;; Added a way to get values of attributes for dataset (valueable for MissingValue attr)
;;
;; Revision 1.5  2003/11/03 18:46:13  livesey
;; Modified to read HIRDLS files more easily.
;;
;; Revision 1.4  2003/09/19 21:54:42  fullerr
;; Reformatted/cleaned up code, and added documentation
;;
