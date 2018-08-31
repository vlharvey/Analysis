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
;
; DFS_ALL         FLOAT     = Array[4276]
; LAT             DOUBLE    = Array[96]
; PRESSURE        FLOAT     = Array[55]
; SDATE_ALL       STRING    = Array[4276]
; TBAR_ALL        FLOAT     = Array[4276, 96, 55]
; UBAR_ALL        FLOAT     = Array[4276, 96, 55]
; VBAR_ALL        FLOAT     = Array[4276, 96, 55]
; ZBAR_ALL        FLOAT     = Array[4276, 96, 55]
; O3BAR_ALL        FLOAT     = Array[4276, 96, 55]
;
restore,file='MLS_YZ_UVTO3_2004-2018.sav'		;,sdate_all,dfs_all,vbar_all,ubar_all,tbar_all,zbar_all,lat,pressure
zlev=74
index=where(ZBAR_ALL eq -9999.)
zbar_all(index)=0./0.
zdum=mean(ZBAR_ALL,dim=1,/Nan)
zprof=mean(zdum,dim=1,/Nan)
index=where(finite(zprof) eq 0.)
if index(0) ne -1L then zprof(index)=0.
;print,zprof
;read,'Enter desired pressure level ',zlev
index=where(abs(zprof-zlev) eq min(abs(zprof-zlev)))
ilev=index(0)
slev=strcompress(pressure(ilev),/r)
if setplot eq 'ps' then begin
  lc=0
  set_plot,'ps'
  xsize=nxdim/100.
  ysize=nydim/100.
  !p.font=0
  device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
    /bold,/color,bits_per_pixel=8,/helvetica,filename='u_timeseries_mls_2005-2018_'+slev+'.ps'
  !p.charsize=1.25
  !p.thick=2
  !p.charthick=5
  !y.thick=2
  !x.thick=2
endif

rlat=30.
slat=strcompress(rlat,/r)
nhindex=where(abs(lat-rlat) lt 1)
shindex=where(abs(lat+rlat) lt 1)
ushdata=reform(UBAR_ALL(*,shindex(0),ilev))
unhdata=reform(UBAR_ALL(*,nhindex(0),ilev))

index=where(ushdata eq -9999.)
if index(0) ne -1L then ushdata(index)=0./0.
index=where(unhdata eq -9999.)
if index(0) ne -1L then unhdata(index)=0./0.

print,zprof(ilev)
index=where(finite(unhdata) and (strmid(sdate_all,4,2) eq '01' or strmid(sdate_all,4,2) eq '02' or strmid(sdate_all,4,2) eq '12'))
print,'DJF ',median(unhdata(index)),mean(unhdata(index)),stdev(unhdata(index))
index=where(finite(ushdata) and (strmid(sdate_all,4,2) eq '06' or strmid(sdate_all,4,2) eq '07' or strmid(sdate_all,4,2) eq '08'))
print,'JJA ',median(ushdata(index)),mean(ushdata(index)),stdev(ushdata(index))

nlvls=2018-2005+1L
col1=1+indgen(nlvls)*mcolor/nlvls
yint=ylen/float(nlvls)

for iyear=2005,2018 do begin
;
; set date labels
;
  sday=strmid(sdate_all,6,2)
  smon=strmid(sdate_all,4,2)
  syear=strmid(sdate_all,0,4)
  index=where(syear eq strcompress(iyear,/remove_all),ndays)
  sdatenew=sdate_all(index)
  sday=strmid(sdatenew,6,2)
  smon=strmid(sdatenew,4,2)
  syear=strmid(sdatenew,0,4)
  ushnew=ushdata(index)
  unhnew=unhdata(index)
  xindex=where(sday eq '15',nxticks)
  xlabs=smon(xindex)    ;+'/'+sday(xindex)   ;+'/'+syear(xindex)

  if iyear eq 2005L then begin
    erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    plot,1+findgen(ndays),unhnew,/noeras,title='MLS Ubar at '+slat+' and '+slev+'hPa' ,/nodata,yrange=[min(unhnew),max(unhnew)],$$
      charsize=1.5,color=0,xticks=nxticks-1,xtickname=xlabs,xstyle=1,xrange=[1,ndays],xtickv=xindex,ytitle='(m/s)',thick=5
  endif
  oplot,1+findgen(ndays),smooth(unhnew,7,/Nan),thick=2,psym=-1,color=col1(iyear-2005)
  oplot,1+findgen(ndays),smooth(ushnew,7,/Nan),thick=2,psym=-1,color=0	;color=col1(iyear-2005)
   xyouts,xmx+0.02,ymx-0.03-(iyear-2005)*yint,strcompress(iyear,/remove_all),color=col1(iyear-2005),/normal,charthick=2,charsize=2
jumpyear:
endfor

if setplot eq 'ps' then begin
  device, /close
  spawn,'convert -trim u_timeseries_mls_2005-2018_'+slev+'.ps -rotate -90 u_timeseries_mls_2005-2018_'+slev+'.png'
endif


end
