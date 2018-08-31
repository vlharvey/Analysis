;
; for each year, plot the daily maximum PNJ wind speed in the Arctic
;
@stddat
@kgmt
@ckday
@kdate
@date2uars
@rd_ukmo_nc3
@drawvectors

; set color table
loadct,38
device,decompose=0
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
icmm1=icolmax-1
icmm2=icolmax-2
lc=mcolor
!noeras=1

diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
setplot='x'
read,'setplot',setplot
nlg=0l
nlat=0l
nlv=0l
lstmn=1
lstdy=1
lstyr=2004
ledmn=5
leddy=1
ledyr=2004
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date
;
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
nday=ledday-lstday+1L
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.30]
xlen=0.7
ylen=0.35
cbaryoff=0.08
cbarydel=0.01

if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162

if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='max_wind_timeseries.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
   !p.thick=2.0                   ;Plotted lines twice as thick
   !p.charsize=1.0
endif

; Compute initial Julian date
iyr0=1992L
iyr1=2006L
nlvls=iyr1-iyr0+1L
col1=10+indgen(nlvls)*icolmax/nlvls
for iyr=iyr0,iyr1 do begin
icount=0
sp_time=-99.+fltarr(nday+1)
z = stddat(lstmn,lstdy,iyr,lstday)
z = stddat(ledmn,leddy,iyr,ledday)

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
      if ndays gt ledday then goto,plotit
;
; read UKMO data
;
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr
      rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
      s2=sqrt(u2^2.0 + v2^2.0)

; Declare plotting arrays
      y3d=0.*u2
      th3d=0.*u2
      for i=0,nc-1 do begin
          for k=0,nth-1 do y3d(*,i,k)=alat
          for j=0,nr-1 do th3d(j,i,*)=th
      endfor

index=where(y3d gt 0. and th3d ge 1000. and mark2 gt 0.)
if index(0) ne -1 then begin
ytmp=y3d(index)
thtmp=th3d(index)
stmp=s2(index)
sp_time(icount)=max(s2(index))
index=where(stmp eq max(stmp))
print,ifile,sp_time(icount),ytmp(index(0)),thtmp(index(0))
endif

icount=icount+1L
goto, jump

plotit:

; Autoscale if scale values for parameter/level are not defined
if iyr eq iyr0 then begin
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
plot,findgen(nday),sp_time,title='Polar Night Jet Speed',xtitle='Julian day',$
     ytitle='m/s',yrange=[0.,200.],charsize=2,/nodata,min_value=-99.
endif
sp_time=smooth(sp_time,3)
oplot,findgen(nday),sp_time,color=col1(iyr-iyr0),thick=4,min_value=-99.
if iyr eq iyr1 then oplot,findgen(nday),sp_time,color=lc,thick=10
yinc=(ymx-ymn)/nlvls
xyouts,xmx+0.02,ymn+(iyr-iyr0)*yinc,syr,charsize=2,color=col1(iyr-iyr0),/normal
if iyr eq iyr1 then xyouts,xmx+0.02,ymn+(iyr-iyr0)*yinc,syr,charsize=2,color=lc,/normal
endfor
if setplot eq 'ps' then device, /close
end
