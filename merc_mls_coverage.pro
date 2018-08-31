;
; plot mercator projection of MLS observation locations
;
@stddat
@kgmt
@ckday
@kdate

loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
setplot='ps'
read,'setplot=',setplot
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=750
nydim=750
xorig=[0.20]
yorig=[0.25]
xlen=0.7
ylen=0.5
cbaryoff=0.07
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
mdir='/Volumes/earth/aura6/data/MLS_data/Datfiles_SOSST/'
lstmn=8
lstdy=1
lstyr=2004
ledmn=5
leddy=1
ledyr=2011
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting year ',lstyr
;read,' Enter ending year ',ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal Termination Condition '
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
;
; restore MLS catalogue on this day
;
; ALTITUDE        FLOAT     = Array[121]
; COMMENT         STRING    = Array[4]
; DATE            LONG      =     20070101
; ERR             FLOAT     = Array[3491, 121]
; FDOY            FLOAT     = Array[3491]
; ID              STRING    = Array[3491]
; LATITUDE        FLOAT     = Array[3491]
; LONGITUDE       FLOAT     = Array[3491]
; MASK            FLOAT     = Array[3491, 121]
; MIX             FLOAT     = Array[3491, 121]
; TIME            FLOAT     = Array[3491]
;
      latitude=[-99.]
      longitude=[-99.]
      dum=findfile(mdir+'cat_mls_v3.3_'+sdate+'.sav')
      if dum(0) ne '' then restore,mdir+'cat_mls_v3.3_'+sdate+'.sav'
      if dum(0) eq '' then print,'missing data on '+sdate
;
      if setplot eq 'ps' then begin
         lc=0
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !p.font=0
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                /bold,/color,bits_per_pixel=8,/helvetica,filename='mls_coverage_'+sdate+'.ps'
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !p.charthick=5
         !y.thick=2
         !x.thick=2
      endif
;
; plot MLS coverage
;
      erase
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      !type=2^2+2^3
      map_set,0,0,0,/contin,/grid,title=sdate,color=0
      nprof=n_elements(latitude)
      if min(latitude) gt -90. then begin
         oplot,longitude,latitude,psym=8,color=0
         xyouts,xmx-0.05,ymx+0.02,strcompress(nprof,/remove_all),/normal,color=0,charsize=3,charthick=3
      endif
      if min(latitude) lt -90. then xyouts,xmx-0.05,ymx+0.02,strcompress(0,/remove_all),/normal,color=0,charsize=3,charthick=3
;
;     if setplot ne 'ps' and latitude(0) ne -99. then stop
      if dum(0) ne '' and nprof le 3000 then begin
         wait,1
         print,nprof,' on '+sdate
      endif
      if setplot eq 'ps' then begin
         device, /close
         spawn,'convert -trim mls_coverage_'+sdate+'.ps -rotate -90 mls_coverage_'+sdate+'.jpg'
      endif
goto,jump
end
