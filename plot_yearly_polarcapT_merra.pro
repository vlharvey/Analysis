;
; plot yearly polar cap average Temp
;
@stddat
@kgmt
@ckday
@kdate

loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[.15]
yorig=[.25]
xlen=0.7
ylen=0.6
cbaryoff=0.075
cbarydel=0.01
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
!noeras=1
;goto,plotit
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_press_'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
lstmn=11
;lstmn=1
lstdy=1
lstyr=1979
ledmn=5
leddy=1
ledyr=1979
;
; loop over years
;
;for lstyr=1979,2013 do begin
for lstyr=2013,2013 do begin
   ledyr=lstyr+1

if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif

z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
nfile=kday
yyyymmdd=lonarr(nfile)
syyyymmdd=strarr(nfile)
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop here over days --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; Test for end condition and close windows.
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto, plotit
      syr=string(FORMAT='(I4.4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      print,sdate
      yyyymmdd(icount)=long(syr+smn+sdy)
      syyyymmdd(icount)=sdate
;
; read data
;
      dum=findfile(dir+sdate+'.sav')
      if dum(0) eq '' then goto,skip
      restore,dir+sdate+'.sav'		
      alat=LATITUDE_WACCM
      nth=n_elements(pressure)
      nr=n_elements(LATITUDE_WACCM)
      nc=n_elements(LONGITUDE_WACCM)
;
      if icount eq 0L then begin
         nh_t=-9999.+0.*fltarr(nfile,nth)
      endif
;
; calculate zonal mean temperature and zonal wind
;
      tzm=fltarr(nr,nth)
      yindex=where(alat ge 70.)
      for k=0,nth-1 do begin
          for j=0,nr-1 do begin
              tzm(j,k)=total(tgrd(*,j,k))/float(nc)
          endfor
          nh_t(icount,k)=mean(tzm(yindex,k))
      endfor
;stop
      skip:
      icount=icount+1L
goto,jump
;
; plot
;
plotit:
;
; save postscript version
;
syr=strmid(syyyymmdd,0,4)
smn=strmid(syyyymmdd,4,2)
sdy=strmid(syyyymmdd,6,2)
xindex=where(sdy eq '15',nxticks)
xlabs=smn(xindex)
minyear=long(min(long(syr)))
maxyear=long(max(long(syr)))
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='merra_polarcapT_'+yearlab+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
   !p.thick=2.
   !p.charthick=2.
   !p.charsize=1.5
endif

erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=180.+5.*findgen(21)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
!type=2^2+2^3
contour,nh_t,findgen(icount),pressure,yrange=[max(pressure),min(pressure)],/ylog,/noeras,levels=level,$
        c_color=col1,/cell_fill,color=0,ytitle='Pressure (hPa)',title=yearlab+' MERRA Temperature >70N',$
        xticks=nxticks-1,xtickname=xlabs,xtickv=xindex
index=where(level gt 0.)
contour,nh_t,findgen(icount),pressure,/noeras,levels=level(index),/follow,color=mcolor,/overplot
set_viewport,xmx+cbaryoff,xmx+cbaryoff+cbarydel,ymn,ymx
!type=2^2+2^3+2^5
omin=min(level)
omax=max(level)
plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],title='(K)',color=0,charsize=1.5
xbox=[0,10,10,0,0]
y1=omin
dy=(omax-omin)/float(nlvls)
for j=0,nlvls-1 do begin
    ybox=[y1,y1,y1+dy,y1+dy,y1]
    polyfill,xbox,ybox,color=col1(j)
    y1=y1+dy
endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim merra_polarcapT_'+yearlab+'.ps -rotate -90 '+$
         'merra_polarcapT_'+yearlab+'.jpg'
endif

endfor
end
