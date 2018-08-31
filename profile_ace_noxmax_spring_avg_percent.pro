;
; spring time period only
; plot vertical profile of maximum average NOx (regardless of timing) for each year 2004, 2005, 2006
;
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
setplot='x'
read,'setplot=',setplot
mcolor=icolmax
icmm1=icolmax-1
icmm2=icolmax-2
nxdim=600 & nydim=600
xorig=[0.30]
yorig=[0.20]
xlen=0.4
ylen=0.6
cbaryoff=0.08
cbarydel=0.02
!NOERAS=-1
!p.font=1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
dira='/aura3/data/ACE_data/Datfiles_SOSST/v2.2/'
syear=['2004','2005','2006']
nyear=n_elements(syear)
nlvls=21L
col1=1L+indgen(nlvls)*mcolor/float(nlvls)
;
; postscript file
;
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,bits=8,filename='profile_ace_noxmax_spring_avg_percent.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
endif
;
; restore NOx files
;
restore,'vortex_nox_2004.sav
nday4=nday
FDOY4=FDOY
LATITUDE4=LATITUDE
ONOX4=ONOX
onox4(0:35,*)=0.
restore,'vortex_nox_2005.sav
nday5=nday
FDOY5=FDOY
LATITUDE5=LATITUDE
ONOX5=ONOX
restore,'vortex_nox_2006.sav
nday6=nday
FDOY6=FDOY
LATITUDE6=LATITUDE
ONOX6=ONOX
nz=n_elements(ALTITUDE)
;
; NOx maximum profiles
;
noxmax4=fltarr(nz)
noxmax5=fltarr(nz)
noxmax6=fltarr(nz)
;
; loop over altitudes
;
kday=91L
for kk=0L,nz-1L do begin
;
; extract vortex NOx at this altitude
;
    noxmax4(kk)=max(ONOX4(0L:kday-1L,kk))
    noxmax5(kk)=max(ONOX5(0L:kday-1L,kk))
    noxmax6(kk)=max(ONOX6(0L:kday-1L,kk))
    jumplev:
endfor  ; loop over years
;
; percent that 2006 is of 2004
;
noxpercent=0.*noxmax4
index=where(noxmax4 ne 0. and noxmax6 ne 0.)
noxpercent(index)=100.*noxmax6(index)/noxmax4(index)
;noxmax6=smooth(noxmax6,3)
;
; plot profiles of maxima
;
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
nmin=0.
nmax=max(noxpercent)
plot,noxpercent,altitude,psym=0,/noeras,yrange=[30.,80.],thick=2,$
         charsize=1.75,xtitle='NOx (ppbv)',color=0,xrange=[nmin,100.],$
         title='ACE NOx 50 N 2006/2004',ytitle='Altitude (km)'
oplot,noxpercent,altitude,psym=8,color=0
oplot,noxpercent,altitude,psym=0,color=0,thick=2
if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim profile_ace_noxmax_spring_avg_percent.ps -rotate -90 '+$
         'profile_ace_noxmax_spring_avg_percent.jpg'
   spawn,'/usr/bin/rm profile_ace_noxmax_spring_avg_percent.ps'
endif
end
