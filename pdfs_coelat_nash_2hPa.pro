;
; PDFs of Elat edge values based on CO and PV
;
loadct,39
mcolor=byte(!p.color)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.25]
yorig=[0.25]
cbaryoff=0.02
cbarydel=0.01
xlen=0.6
ylen=0.6
PI2=6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
!NOERAS=-1
syear=['2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014']
nyear=n_elements(syear)
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
;
; get file listing
;
spawn,'ls elat_time_co_edges_????-????.sav',ifiles
restore,ifiles(0)
lowlat_elatedge_time_all=LOWLAT_ELATEDGE_TIME
nashedge_time_all=nashedge_time
sdate_time_all=sdate_time

for ifile=1L,n_elements(ifiles)-1L do begin
    restore,ifiles(ifile)
    LOWLAT_ELATEDGE_TIME_all=[LOWLAT_ELATEDGE_TIME_all,LOWLAT_ELATEDGE_TIME]
    nashedge_time_all=[nashedge_time_all,nashedge_time]
    sdate_time_all=[sdate_time_all,sdate_time]
endfor

; postscript file
;
if setplot eq 'ps' then begin
   lc=0
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='pdfs_coelat_nash_'+spress+'.ps'
   !p.charsize=1.2
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
;
; DJF
;
syear=strmid(sdate_time_all,0,4)
smon=strmid(sdate_time_all,4,2)
sday=strmid(sdate_time_all,6,2)
index=where(smon ne '11' and smon ne '03')
LOWLAT_ELATEDGE_TIME_all=LOWLAT_ELATEDGE_TIME_all(index)
NASHEDGE_TIME_all=NASHEDGE_TIME_all(index)
sdate_time_all=sdate_time_all(index)
syear=strmid(sdate_time_all,0,4)
smon=strmid(sdate_time_all,4,2)
sday=strmid(sdate_time_all,6,2)

erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
diff=LOWLAT_ELATEDGE_TIME_ALL-nashedge_time_all
;
; monthly PDFs
;
index=where(smon eq '12')
imin=-20.
imax=60.
iinc=4.
y2=histogram(diff(index),min=imin,max=imax,binsize=iinc)	;/float(n_elements(index))
nlvls=long((imax-imin)/iinc + 1)
level=imin+iinc*findgen(nlvls)
plot,level,smooth(y2,3),color=0,xtitle='!7D!3Elat',ytitle='Total Counts',thick=15,yrange=[0.,100.],charsize=1.5,charthick=4
decdiff=diff(index)
index2=where(decdiff le 10.)
spercent=string(format='(f4.1)',100.*float(n_elements(index2))/float(n_elements(index)))
xyouts,xmx-0.35,ymx-0.03,'Median !7D!3Elat  (%<10)',color=0,/normal,charsize=1.5,charthick=4
xyouts,xmx-0.3,ymx-0.07,'DEC '+string(format='(f4.1)',median(diff(index)))+' ('+spercent+')',color=0,/normal,charsize=1.5,charthick=4

index=where(smon eq '01')
y2=histogram(diff(index),min=imin,max=imax,binsize=iinc)	;/float(n_elements(index))
oplot,level,smooth(y2,3),color=mcolor*.9,thick=15
jandiff=diff(index)
index2=where(jandiff le 10.)
spercent=string(format='(f4.1)',100.*float(n_elements(index2))/float(n_elements(index)))
xyouts,xmx-0.3,ymx-0.11,'JAN '+string(format='(f4.1)',median(diff(index)))+' ('+spercent+')',color=mcolor*.9,/normal,charsize=1.5,charthick=4

index=where(smon eq '02')
y2=histogram(diff(index),min=imin,max=imax,binsize=iinc)	;/float(n_elements(index))
oplot,level,smooth(y2,3),color=mcolor*.3,thick=15
febdiff=diff(index)
index2=where(febdiff le 10.)
spercent=string(format='(f4.1)',100.*float(n_elements(index2))/float(n_elements(index)))
xyouts,xmx-0.3,ymx-0.15,'FEB '+string(format='(f4.1)',median(diff(index)))+' ('+spercent+')',color=mcolor*.3,/normal,charsize=1.5,charthick=4

; Close PostScript file and return control to X-windows
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim pdfs_coelat_nash_'+spress+'.ps -rotate -90 '+$
                       'pdfs_coelat_nash_'+spress+'.jpg'
;  spawn,'rm -f pdfs_coelat_nash_'+spress+'.ps'
endif
end
