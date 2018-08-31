;
; check for discontinuity in Sep 2008
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
xorig=[.15,.15]
yorig=[.55,.15]
xlen=0.7
ylen=0.35
cbaryoff=0.075
cbarydel=0.01
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
!noeras=1
;goto,plotit
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_press_'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
lstmn=1L & lstdy=1L & lstyr=1979L
lstmn=1L & lstdy=1L & lstyr=2000L
ledmn=1L & leddy=31L & ledyr=2014L
;
; Ask interactive questions- get starting/ending date and p surface
;
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
;read,' Enter starting year ',lstyr
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
      if ndays gt ledday then goto, saveit
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
      restore,dir+sdate+'.sav'		
;
      if icount eq 0L then begin
         alat=LATITUDE_WACCM
         nth=n_elements(pressure)
         nr=n_elements(LATITUDE_WACCM)
         nc=n_elements(LONGITUDE_WACCM)
         globalt=-9999.+0.*fltarr(nfile,nth)
      endif
;
; calculate global mean temperature at each altitude
;
      globalt(icount,*)=mean(mean(tgrd,dimension=1),dimension=1)
      skip:
      icount=icount+1L
goto,jump
;
; save file
;
saveit:
icount=n_elements(yyyymmdd)
save,file='Save_files/MERRA_globalt.sav',yyyymmdd,syyyymmdd,pressure,globalt,icount
;
; plot
;
plotit:
restore,'Save_files/MERRA_globalt.sav'
;
; save postscript version
;
sdate0=syyyymmdd(0)
sdate1=syyyymmdd(icount-1)
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='merra_globaltemp_'+sdate0+'-'+sdate1+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
   !p.thick=2.
   !p.charthick=2.
   !p.charsize=1.5
endif
syr=strmid(syyyymmdd,2,2)
smn=strmid(syyyymmdd,4,2)
sdy=strmid(syyyymmdd,6,2)
xindex=where(sdy eq '01' and smn eq '01',nxticks)
xlabs=syr(xindex)

erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=150.+5.*findgen(21)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
!type=2^2+2^3
contour,globalt,findgen(icount),pressure,yrange=[max(pressure),min(pressure)],/ylog,/noeras,levels=level,$
        c_color=col1,/cell_fill,color=0,ytitle='Theta (K)',title='MERRA Global Temperature',$
        xticks=nxticks-1,xtickname=xlabs,xtickv=xindex
contour,globalt,findgen(icount),pressure,/noeras,levels=level,/follow,color=mcolor,/overplot
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

if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim merra_globaltemp_'+sdate0+'-'+sdate1+'.ps -rotate -90 '+$
         'merra_globaltemp_'+sdate0+'-'+sdate1+'.jpg'
endif

end
