;
; plot daily zonal mean U, V, T on p from gridded data
;
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.30]
xlen=0.65
ylen=0.5
cbaryoff=0.08
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
  lc=icolmax
  window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif

if setplot eq 'ps' then begin
  lc=0
  set_plot,'ps'
  xsize=nxdim/100.
  ysize=nydim/100.
  !p.font=0
  device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
    /bold,/color,bits_per_pixel=8,/helvetica,filename='temp_timeseries_mls_2005-2016.ps'
  !p.charsize=1.25
  !p.thick=2
  !p.charthick=5
  !y.thick=2
  !x.thick=2
endif

;
; DFS_ALL         FLOAT     = Array[4276]
; LAT             DOUBLE    = Array[96]
; PRESSURE        FLOAT     = Array[55]
; SDATE_ALL       STRING    = Array[4276]
; TBAR_ALL        FLOAT     = Array[4276, 96, 55]
; UBAR_ALL        FLOAT     = Array[4276, 96, 55]
; VBAR_ALL        FLOAT     = Array[4276, 96, 55]
; ZBAR_ALL        FLOAT     = Array[4276, 96, 55]
;
restore,file='MLS_YZ_UVT_2004-2016.sav'		;,sdate_all,dfs_all,vbar_all,ubar_all,tbar_all,zbar_all,lat,pressure
zlev=40.
ndays=n_elements(sdate_all)
for iday=0,ndays-1 do begin
;
; zonal mean arrays
;
    alat=LAT
    nlat=n_elements(alat)
    nlv=n_elements(PRESSURE)
    zzm=reform(ZBAR_ALL(iday,*,*))
    tzm=reform(TBAR_ALL(iday,*,*))
    uzm=reform(UBAR_ALL(iday,*,*))
    vzm=reform(VBAR_ALL(iday,*,*))
;
; temp poleward of 70N (note, temps are Nan and heights are -9999 where undefined- this doesn't affect 40 km)
;
    yindex=where(alat ge 70.)
    tprof=mean(tzm(yindex,*),dim=1)
    zprof=mean(zzm(yindex,*),dim=1)
    if iday eq 0 then tempzt=fltarr(ndays)
;
; interpolate temperature to zlev=40km using zprof
;
    for kk=0,nlv-2L do begin    ; loop over model levels looking for levels bounding 40 km
        if zprof(kk) lt zlev and zprof(kk+1) ge zlev then begin
               zscale=(zprof(kk)-zlev)/(zprof(kk)-zprof(kk+1))
               tempzt(iday)=tprof(kk)-zscale*(tprof(kk)-tprof(kk+1))  ; interpolate to 40 km
;print,zprof(kk+1),zlev,zprof(kk),zscale
;print,tprof(kk+1),tempzt(iday),tprof(kk)
;stop
        endif
    endfor
;
endfor  ; loop over days
;
; order chronologically
;
sdate=sdate_all
;ldate=long(sdate)
;index=sort(ldate)
;sdate=sdate(index)
;tempzt=tempzt(index)
;
; interpolate small gaps in time
;
    dlev=tempzt
    for i=1,ndays-1 do begin
        if dlev(i) eq 0. and dlev(i-1) ne 0. then begin
           for ii=i+1,ndays-1 do begin
               naway=float(ii-i)
               if naway le 14.0 and dlev(ii) ne 0. then begin
                  dlev(i)=(naway*dlev(i-1)+dlev(ii))/(naway+1.0)
                  goto,jump1
               endif
           endfor
jump1:
        endif
    endfor
    tempzt=dlev
index=where(tempzt eq 0.)
if index(0) ne -1L then tempzt(index)=0./0.
;
; loop over years
;
nlvls=2016-2005+1L
col1=1+indgen(nlvls)*mcolor/nlvls
yint=ylen/float(nlvls)

for iyear=2005,2016 do begin
;
; set date labels
;
  sday=strmid(sdate,6,2)
  smon=strmid(sdate,4,2)
  syear=strmid(sdate,0,4)
  index=where(syear eq strcompress(iyear,/remove_all),ndays)
index=index(0:91)
ndays=n_elements(index)
  sdatenew=sdate(index)
  sday=strmid(sdatenew,6,2)
  smon=strmid(sdatenew,4,2)
  syear=strmid(sdatenew,0,4)
  tempztnew=tempzt(index)
  xindex=where(sday eq '15',nxticks)
  xlabs=smon(xindex)    ;+'/'+sday(xindex)   ;+'/'+syear(xindex)
  if iyear eq 2006L then tempztnew(45)=0./0.	; bad data on Feb 15 2006?
  tempztnew=smooth(tempztnew,3,/Nan)

  if iyear eq 2005L then begin
    erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    plot,1+findgen(ndays),tempztnew,/noeras,yrange=[190.,280.],title='MLS Average Temp > 70N at 40 km',/nodata,$
      charsize=1.5,color=0,xticks=nxticks-1,xtickname=xlabs,xstyle=1,xrange=[1,ndays],xtickv=xindex,ytitle='Temperature (K)',thick=5
  endif
  print,iyear
  oplot,1+findgen(ndays),tempztnew,thick=15,color=col1(iyear-2005)
  xyouts,xmx+0.02,ymx-0.03-(iyear-2005)*yint,strcompress(iyear,/remove_all),color=col1(iyear-2005),/normal,charthick=2,charsize=2
jumpyear:
endfor

if setplot eq 'ps' then begin
  device, /close
  spawn,'convert -trim temp_timeseries_mls_2005-2016.ps -rotate -90 temp_timeseries_mls_2005-2016.png'
endif


end
