;
; ES composite with MLS CO
; contour CO and the vortex edge as a function of latitude and time
; +/- 30 days around all ES events
;
@stddat
@kgmt
@ckday
@kdate
@rd_merra_nc3

sver='v3.3'

loadct,39
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=1000
nydim=700
xorig=[.1,0.1,0.55,0.55]
yorig=[.25,.1,.55,.1]
xlen=0.8
ylen=0.6
cbaryoff=0.1
cbarydel=0.01
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
stimes=[$
'_AVG.V01.']
slabs=['AVG']
ntimes=n_elements(stimes)
!noeras=1
idir='/Users/harvey/Harvey_etal_2014/Post_process/'
dirm='/Volumes/earth/aura6/data/MLS_data/Datfiles_SOSST/'
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
mlsesdates=['20060130','20090205','20120130','20130123']
;sabesdates=['20060128','20090205','20120128','20130123']

nevent=n_elements(mlsesdates)
for ievent=0,nevent-1L do begin
    esdate0=mlsesdates(ievent)
    iyr=long(strmid(esdate0,0,4))
    imn=long(strmid(esdate0,4,2))
    idy=long(strmid(esdate0,6,2))
    jday = JULDAY(imn,idy,iyr)
    jday0=jday-30
    jday1=jday+30
    CALDAT, jday0, lstmn ,lstdy , lstyr
    CALDAT, jday1, ledmn ,leddy , ledyr

    lstday=0L & ledday=0L
    if lstyr eq ledyr then yearlab=strcompress(lstyr,/remove_all)
    if lstyr ne ledyr then yearlab=strcompress(lstyr,/remove_all)+'-'+strcompress(ledyr,/remove_all)
    restore,idir+'pdfs_merra_co+mark_'+yearlab+'.sav'
;
; average all events to create composite
;
    if ievent eq 0L then begin
       ytco_all=0.*CO2D_PDF
       nytco_all=0.*CO2D_PDF
       yth2o_all=0.*CO2D_PDF
       nyth2o_all=0.*CO2D_PDF
       ytmark_all=0.*CO2D_PDF
       nytmark_all=0.*CO2D_PDF
       ytspeed_all=0.*CO2D_PDF
       nytspeed_all=0.*CO2D_PDF
    endif

    index=where(CO2D_PDF ne -9999.)
    if index(0) ne -1L then ytco_all(index)=ytco_all(index)+CO2D_PDF(index)
    if index(0) ne -1L then nytco_all(index)=nytco_all(index)+1.0
;   index=where(yth2o ne -9999.)
;   if index(0) ne -1L then yth2o_all(index)=yth2o_all(index)+yth2o(index)
;   if index(0) ne -1L then nyth2o_all(index)=nyth2o_all(index)+1.0
;   index=where(ytmark ne -9999.)
;   if index(0) ne -1L then ytmark_all(index)=ytmark_all(index)+ytmark(index)
;   if index(0) ne -1L then nytmark_all(index)=nytmark_all(index)+1.0
;   index=where(ytspeed ne -9999.)
;   if index(0) ne -1L then ytspeed_all(index)=ytspeed_all(index)+ytspeed(index)
;   if index(0) ne -1L then nytspeed_all(index)=nytspeed_all(index)+1.0
endfor
index=where(nytco_all gt 0.)
if index(0) ne -1L then ytco_all(index)=ytco_all(index)/float(nytco_all(index))
;index=where(nyth2o_all gt 0.)
;if index(0) ne -1L then yth2o_all(index)=yth2o_all(index)/float(nyth2o_all(index))
;index=where(nytmark_all gt 0.)
;if index(0) ne -1L then ytmark_all(index)=ytmark_all(index)/float(nytmark_all(index))
;index=where(nytspeed_all gt 0.)
;if index(0) ne -1L then ytspeed_all(index)=ytspeed_all(index)/float(nytspeed_all(index))
;
; rename for convenience
;
ytco=ytco_all
yth2o=yth2o_all
ytmark=ytmark_all
ytspeed=ytspeed_all
;
; loop over theta
;
          rlev=4000.
          slev=strcompress(long(rlev),/remove_all)+'K'
;
; save postscript version
;
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !psym=0
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,filename='pdfs_merra_co+mark_'+slev+'_composite.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.thick=2.0                   ;Plotted lines twice as thick
         !p.charsize=2.0
      endif

erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
nlvls=21
col1=1+indgen(nlvls)*mcolor/nlvls
plotarray=ytco
cbartitle=slev+' Frequency'
index=where(plotarray eq -9999.)
if index(0) ne -1L then plotarray(index)=0./0.
      cbartitle=slev+' MLS CO PDF'
      nlvls=20
      col1=1+indgen(nlvls)*mcolor/nlvls
      x=-1+findgen(14)
      level=.05+0.05*findgen(20)
      contour,plotarray,-30.+findgen(kday),x,levels=.05+0.05*findgen(20),/fill,c_color=col1,xtitle='Days From ES Onset',ytitle='CO (ppmv)',color=0,/noeras,charsize=2,charthick=2
      contour,plotarray,-30.+findgen(kday),x,levels=.05+0.05*findgen(20),/foll,color=0,/overplot,charsize=2,charthick=2
;     contour,h2o2d_pdf,-30.+findgen(kday),x,levels=.05+0.05*findgen(20),/follow,/overplot,color=0
;plots,0,30
;plots,0,80,/continue,thick=5,color=150
loadct,39
omin=min(level)
omax=max(level)
set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
!type=2^2+2^3+2^6
plot,[omin,omax],[0,0],yrange=[0,10],charsize=2,charthick=2,$
      xrange=[omin,omax],xtitle=cbartitle,/noeras,xstyle=1,color=0
ybox=[0,10,10,0,0]
x1=omin
dx=(omax-omin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor
;
if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim pdfs_merra_co+mark_'+slev+'_composite.ps -rotate -90 '+$
         'pdfs_merra_co+mark_'+slev+'_composite.jpg'
endif
end
