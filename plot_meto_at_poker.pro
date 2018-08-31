;
; plot "meto_at_poker" data
; Poker Flat (65N,147W) 213E
;
@stddat
@kgmt
@ckday
@kdate

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='ps'
read,'setplot=',setplot
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.2]
xlen=0.7
ylen=0.7
cbaryoff=0.1
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
dir='/Volumes/earth/aura3/data/UKMO_data/Marker_profiles/'	; directory where data files reside
lstmn=1L & lstdy=1L & lstyr=2010L
ledmn=3L & leddy=31L & ledyr=2010L
lstday=0L & ledday=0L
;
; Ask interactive questions- get starting/ending date and p surface
;
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
slat=65. & slon=215.			; Poker Flat
;read,' Enter longitude, latitude, theta ',slon,slat
sloc='('+string(FORMAT='(i3)',slon)+'E ,'+string(FORMAT='(i2)',slat)+'N)'
;
; --- Loop over days --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit
      sdate=string(FORMAT='(i4,i2.2,i2.2)',iyr,imn,idy)
;
; restore daily profiles
;
; comment(0)='Profiles based on U.K. Met Office data and valid at 12 GMT'
; comment(1)='date in YYYYMMDD'
; comment(2)='longitude in degrees east'
; comment(3)='latitude in degrees'
; comment(4)='potential_temperature_profile = potential temperature profile (K)'
; comment(5)='vortex_marker_profile = positive (negative) values in vortex (anticyclones)'
; comment(6)='pressure_profile = Pressure profile (hPa)'
; comment(7)='temperature_profile = Temperature profile (K)'
; comment(8)='altitude_profile = Geometric Altitude profile (km)'
; comment(9)='zonal_wind_profile = Zonal Wind profile (km)'
; comment(10)='meridional_wind_profile = Meridional Wind profile (km)'
;
      restore,dir+'meto_at_poker_'+sdate+'.sav'
      print,sdate
;
; declare 2-d arrays on first day
;
      if icount eq 0L then begin
         nth=n_elements(potential_temperature_profile)
         sdate_all=strarr(kday)
         theta2d=fltarr(kday,nth)
         marker2d=fltarr(kday,nth)
         press2d=fltarr(kday,nth)
         temp2d=fltarr(kday,nth)
         alt2d=fltarr(kday,nth)
         u2d=fltarr(kday,nth)
         v2d=fltarr(kday,nth)
      endif
      sdate_all(icount)=sdate
      theta2d(icount,*)=potential_temperature_profile
      marker2d(icount,*)=vortex_marker_profile
      press2d(icount,*)=pressure_profile
      temp2d(icount,*)=temperature_profile
      alt2d(icount,*)=altitude_profile
      u2d(icount,*)=zonal_wind_profile
      v2d(icount,*)=meridional_wind_profile

icount=icount+1L
goto,jump
;
; plot
;
plotit:
if setplot eq 'ps' then begin
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='meto_at_poker_'+sdate+'.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
imax=100.
imin=-100.
nlvls=20
level=imin+((imax-imin)/float(nlvls))*findgen(nlvls+1)
nlvls=nlvls+1
col1=1+indgen(nlvls)*icolmax/float(nlvls)
contour,u2d,1+findgen(kday),potential_temperature_profile,xtitle='Days in '+string(FORMAT='(i4)',iyr),ytitle='Potential Temperature',/fill,c_color=col1,levels=level,$
     title='Zonal Wind + Vortex Marker at Poker Flat '+sloc,xrange=[1.,kday],color=0,yrange=[min(potential_temperature_profile),max(potential_temperature_profile)]
index=where(level lt 0.)
contour,u2d,1+findgen(kday),potential_temperature_profile,/overplot,/follow,levels=level(index),c_linestyle=5,color=mcolor
index=where(level gt 0.)
contour,u2d,1+findgen(kday),potential_temperature_profile,/overplot,/follow,levels=level(index),c_linestyle=0,color=0
contour,marker2d,1+findgen(kday),potential_temperature_profile,/overplot,/follow,levels=[0.1],c_linestyle=0,color=0,thick=20		; vortex
contour,marker2d,1+findgen(kday),potential_temperature_profile,/overplot,/follow,levels=[-0.1],c_linestyle=5,color=mcolor,thick=20	; anticyclones

imin=min(level)
imax=max(level)
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,color=0,xtitle='Zonal Wind (m/s)'
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/(float(nlvls)-1)
for j=1,nlvls-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor

if setplot eq 'x' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim meto_at_poker_'+sdate+'.ps -rotate -90 meto_at_poker_'+sdate+'.jpg'
   spawn,'rm -f meto_at_poker_'+sdate+'.ps'
endif
end
