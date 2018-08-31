;
; plot CAO center of mass for 1995-1996
; VLH May 18 2010
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3

loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
!p.background=icolmax
setplot='ps'
read,'setplot=',setplot
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

restore,'/Users/harvey/Desktop/Wheeler_etal_2010/com_daily_temporal_data.sav'
;COM_DAILY_AREA  DOUBLE    = Array[346]
;COM_DAILY_CAO_ONSET LONG      = Array[346]
;COM_DAILY_CAO_PTS FLOAT     = Array[346]
;COM_DAILY_DATE  LONG      = Array[346]
;COM_DAILY_DELTAT DOUBLE    = Array[346]
;COM_DAILY_DURATION FLOAT     = Array[346]
;COM_DAILY_LATITUDE FLOAT     = Array[346]
;COM_DAILY_LONGITUDE FLOAT     = Array[346]
;COM_DAILY_MARKER FLOAT     = Array[346]
;COM_DAILY_STR   DOUBLE    = Array[346]
;COM_DAILY_TEMP  FLOAT     = Array[346]
;
com_daily_longitude=com_daily_longitude+360.
com_daily_tempf=(9./5.)*(com_daily_temp-273.)+32.

good=where(com_daily_duration ge 3. and com_daily_longitude lt 300. and com_daily_latitude lt 65. and com_daily_latitude gt 25. and com_daily_tempf lt 50.)
com_date=com_daily_date(good)
com_latitude=com_daily_latitude(good)
com_longitude=com_daily_longitude(good)
com_daily_temp=com_daily_temp(good)
com_daily_tempf=com_daily_tempf(good)
com_sdate=strcompress(com_date,/remove_all)

lstmn=10
lstdy=1
lstyr=1995
ledmn=4
leddy=30
ledyr=1996

;lstmn=1
;lstdy=20
;lstyr=1996
;ledmn=3
;leddy=1
;ledyr=1996

lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting date ',lstmn,lstdy,lstyr
;read,' Enter ending date ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
minyear=lstyr
maxyear=ledyr
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
;
if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='merc_cao_com_'+yearlab+'.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
map_set,0,0,0,/contin,/grid,/noeras,color=0,limit=[20.,210.,70.,310.]

z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
sdate_all=strarr(kday)
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
kcount=0L
gcount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
print,sdate
      sdate_all(icount)=sdate
today=where(com_sdate eq sdate,npts)
if today(0) eq -1L then goto,skipday
tmin=230.
tmax=300.
tint=5.
nlvls=long(1.+(tmax-tmin)/tint)
col1=1+indgen(nlvls)*mcolor/nlvls
tlevel=tmin+5.*findgen(nlvls)
sday=strcompress(iday,/remove_all)
for i=0L,npts-1L do begin
    oplot,[com_longitude(today(i)),com_longitude(today(i))],$
          [com_latitude(today(i)),com_latitude(today(i))],psym=8,color=((com_daily_temp(today(i))-tmin)/(tmax-tmin))*mcolor
    xyouts,com_longitude(today(i)),com_latitude(today(i)),sday,/data,color=0,charsize=1.5
print,com_daily_tempf(today(i))
endfor
wait,.5
;
skipday:
      icount=icount+1L
goto,jump

plotit:
xyouts,xmn+0.02,ymx-0.05,yearlab,/normal,color=mcolor,charsize=3,charthick=3
imin=tmin
imax=tmax
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='Temperature (K)'
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for jj=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(jj)
x1=x1+dx
endfor

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim merc_cao_com_'+yearlab+'.ps -rotate -90 merc_cao_com_'+yearlab+'.jpg'
    endif
end
