;
; plot timeseries of Ubar at 60N and 10hPa AND min Ubar anywhere poleward of 50N in the stratosphere
;
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
device,decompose=0
!p.background=icolmax
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.15,0.15]
yorig=[0.55,0.1]
xlen=0.65
ylen=0.4
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
    /bold,/color,bits_per_pixel=8,/helvetica,filename='ubar_timeseries_mls_2005-2016.ps'
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
yindex=where(abs(lat-60.) eq min(abs(lat-60.)))
ilat=yindex(0)
pindex=where(pressure eq 10.)
ilev=pindex(0)
ubar10=reform(UBAR_ALL(*,ilat,ilev))
ubar_min=0.*ubar10			; minimum zonal wind speed anywhere in the NH stratosphere
y_min=0.*ubar10			; latitude where winds are minimum
p_min=0.*ubar10			; pressure where winds are minimum
ubar_max=0.*ubar10                      ; maximum zonal wind speed anywhere in the NH stratosphere
y_max=0.*ubar10                 ; latitude where winds are maximum
p_max=0.*ubar10                 ; pressure where winds are maximum

pindex=where(pressure le 50. and pressure ge 1.)
yindex=where(lat ge 50. and lat lt 80.)

nlat=n_elements(lat)
nlv=n_elements(PRESSURE)
x2d=fltarr(nlat,nlv)
y2d=fltarr(nlat,nlv)
for i=0L,nlat-1L do y2d(i,*)=pressure
for j=0L,nlv-1L do x2d(*,j)=lat
;
; loop over days
;
ndays=n_elements(sdate_all)
for iday=0,ndays-1 do begin
;
; zonal mean arrays
;
    uzm=reform(UBAR_ALL(iday,*,*))
    if max(uzm) eq -9999. then goto,skipday
    uvals=reform(uzm(yindex(0):yindex(-1),pindex(0):pindex(-1)))
    yvals=reform(x2d(yindex(0):yindex(-1),pindex(0):pindex(-1)))
    pvals=reform(y2d(yindex(0):yindex(-1),pindex(0):pindex(-1)))
    index=where(uvals eq min(uvals))
    ubar_min(iday)=uvals(index(0))
    y_min(iday)=yvals(index(0))
    p_min(iday)=pvals(index(0))
    index=where(uvals eq max(uvals))
    ubar_max(iday)=uvals(index(0))
    y_max(iday)=yvals(index(0))
    p_max(iday)=pvals(index(0))
;print,sdate_all(iday),ubar_min(iday),y_min(iday),p_min(iday),ubar_max(iday),y_max(iday),p_max(iday)
;erase
;contour,uvals,yvals,pvals,/ylog,levels=5+5*findgen(20),/noeras,color=0,yrange=[max(pvals),min(pvals)],/foll,title=sdate_all(iday)
;contour,uvals,yvals,pvals,/overplot,levels=-100+5*findgen(20),c_linestyle=5,color=0,/foll
;oplot,[y_min(iday),y_min(iday)],[p_min(iday),p_min(iday)],psym=8,color=100,symsize=3
;oplot,[y_max(iday),y_max(iday)],[p_max(iday),p_max(iday)],psym=8,color=250,symsize=3
;wait,0.2

skipday:
endfor  ; loop over days
;
sdate=sdate_all
index=where(ubar10 eq -9999.)
if index(0) ne -1L then ubar10(index)=0.
;
; interpolate small gaps in time
;
    dlev=ubar10
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
    ubar10=dlev
index=where(ubar10 eq 0.)
if index(0) ne -1L then ubar10(index)=0./0.

    dlev=ubar_min
    for i=1,ndays-1 do begin
        if dlev(i) eq 0. and dlev(i-1) ne 0. then begin
           for ii=i+1,ndays-1 do begin
               naway=float(ii-i)
               if naway le 14.0 and dlev(ii) ne 0. then begin
                  dlev(i)=(naway*dlev(i-1)+dlev(ii))/(naway+1.0)
                  goto,jump2
               endif
           endfor
jump2:
        endif
    endfor
    ubar_min=dlev
;
; loop over years
;
nlvls=2016-2005+1L
col1=1+indgen(nlvls)*mcolor/nlvls
yint=(yorig(0)+ylen-yorig(1))/float(nlvls)

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
  tempztnew=ubar10(index)
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
    plot,1+findgen(ndays),tempztnew,/noeras,yrange=[-50.,100.],/nodata,$
      charsize=1.5,color=0,xticks=nxticks-1,xtickname=xlabs,xstyle=1,xrange=[1,ndays],xtickv=xindex,ytitle='MLS Ubar 10 hPa (m/s)',thick=5
    oplot,1+findgen(ndays),0*findgen(ndays),color=0,thick=5
  endif
  oplot,1+findgen(ndays),tempztnew,thick=15,color=col1(iyear-2005)
; xyouts,xmx+0.02,ymx-0.03-(iyear-2005)*yint,strcompress(iyear,/remove_all),color=col1(iyear-2005),/normal,charthick=2,charsize=2
endfor

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
  tempztnew=ubar_min(index)
  xindex=where(sday eq '15',nxticks)
  xlabs=smon(xindex)    ;+'/'+sday(xindex)   ;+'/'+syear(xindex)
  if iyear eq 2006L then tempztnew(45)=0./0.    ; bad data on Feb 15 2006?
  tempztnew=smooth(tempztnew,3,/Nan)

  if iyear eq 2005L then begin
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    plot,1+findgen(ndays),tempztnew,/noeras,yrange=[-70.,20.],/nodata,$
      charsize=1.5,color=0,xticks=nxticks-1,xtickname=xlabs,xstyle=1,xrange=[1,ndays],xtickv=xindex,ytitle='MIN Ubar 50-1 hPa and 50-80N',thick=5
    oplot,1+findgen(ndays),0*findgen(ndays),color=0,thick=5
  endif
  print,iyear
  oplot,1+findgen(ndays),tempztnew,thick=15,color=col1(iyear-2005)
  xyouts,xmx+0.02,yorig(0)+ylen-0.02-(iyear-2005)*yint,strcompress(iyear,/remove_all),color=col1(iyear-2005),/normal,charthick=2,charsize=2
endfor


if setplot eq 'ps' then begin
  device, /close
  spawn,'convert -trim ubar_timeseries_mls_2005-2016.ps -rotate -90 ubar_timeseries_mls_2005-2016.png'
endif


end
