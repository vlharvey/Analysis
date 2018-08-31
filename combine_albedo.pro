;combine_frequency.pro -- Combine daily files of frequency into a single file.

;THE IDLSAVE FILES IN THIS DIRECTORY WERE COPIED OVER FROM E:\DATA\AIM\cips\l4_nc\idlsave.

print,'MAKE SURE YOU HAVE COPIED THE MOST RECENT DAILY FILES FROM E: TO C: !!!!

;pth='e:\data\aim\cips\l4_nc\idlsave\'

fname=' '
close,1
;openr,1,PTH+'dir.txt'
openr,1,'dir.txt'

;FIND OUT HOW MANY DAYS THERE ARE
NDAYS=0
WHILE NOT EOF(1) DO BEGIN
   READF,1,FNAME
   NDAYS=NDAYS+1
ENDWHILE
CLOSE,1

;OPENR,1,PTH+'DIR.TXT'
OPENR,1,'DIR.TXT'

FOR I = 0,NDAYS-1 DO BEGIN
;FOR I = 0,1 DO BEGIN
   READF,1,FNAME
   ;RESTORE,PTH+FNAME
   RESTORE,FNAME

   IF I EQ 0 THEN BEGIN
      NLAT=N_ELEMENTS(LATGRID)
      NLON=N_ELEMENTS(LONGRID)

      ALB=FLTARR(NDAYS,NLON,NLAT)-99
      ALBE=FLTARR(NDAYS,NLON,NLAT)-99
      RAD=FLTARR(NDAYS,NLON,NLAT)-99
      RADE=FLTARR(NDAYS,NLON,NLAT)-99
      NCLDS=FLTARR(NDAYS,NLON,NLAT)-99
      NPTS=FLTARR(NDAYS,NLON,NLAT)-99
      ALBLAT=FLTARR(NDAYS,NLAT)-99
      ALBELAT=FLTARR(NDAYS,NLAT)-99
      RADLAT=FLTARR(NDAYS,NLAT)-99
      RADELAT=FLTARR(NDAYS,NLAT)-99
      NCLAT=FLTARR(NDAYS,NLAT)-99
      NPLAT=FLTARR(NDAYS,NLAT)-99
      DATE=LONARR(NDAYS)
   ENDIF

   DATE(I)=DT

   ;FULL LON/LAT GRID
   ALB(I,*,*)=ALBEDO
   ALBE(I,*,*)=ALBEDO_ERR
   RAD(I,*,*)=RADIUS
   RADE(I,*,*)=RADIUS_ERR
   NCLDS(I,*,*)=NCLOUDS
   NPTS(I,*,*)=NPOINTS

   ;TEST
   X=WHERE(NPOINTS EQ 0 AND NCLOUDS GT 0,NX)
   IF NX GT 0 THEN STOP

   ;LATITUDE AVERAGES
   FOR LL = 0,NLAT-1 DO BEGIN
      TESTC=NCLOUDS(*,LL)
      X=WHERE(TESTC GT 0,NX)
      IF NX GT 2 THEN BEGIN
         ALBLAT(I,LL)=MEAN(ALBEDO(x,LL))
         ALBELAT(I,LL)=MEAN(ALBEDO_ERR(x,LL))
         RADLAT(I,LL)=MEAN(RADIUS(x,LL))
         RADELAT(I,LL)=MEAN(RADIUS_ERR(x,LL))
         NCLAT(I,LL)=TOTAL(TESTC(X))
      ENDIF
      TESTP=NPOINTS(*,LL)
      X=WHERE(TESTP GE 0,NX)
      IF NX GT 0 THEN NPLAT(I,LL)=TOTAL(TESTP(X))
   ENDFOR
ENDFOR
CLOSE,1

DOY=YYYYMMDD_TO_JDAY(DATE)-JULDAY(12,31,2006)
ALBEDO=ALB
ALBEDO_ERR=ALBE
ALBEDO_LAT=ALBLAT
ALBEDO_ERR_LAT=ALBELAT
RADIUS=RAD
RADIUS_ERR=RADE
RADIUS_LAT=RADLAT
RADIUS_ERR_LAT=RADELAT
NCLOUDS=NCLDS
NPOINTS=NPTS
NCLOUDS_LAT=NCLAT
NPOINTS_LAT=NPLAT

SAVE,DATE,DOY,LATGRID,LONGRID,ALBEDO,ALBEDO_ERR,ALBEDO_LAT,ALBEDO_ERR_LAT, $
NCLOUDS,NPOINTS,NCLOUDS_LAT,NPOINTS_LAT,RADIUS,RADIUS_ERR,RADIUS_LAT,RADIUS_ERR_LAT, $
FILE='albedo_nh08.dat'

end