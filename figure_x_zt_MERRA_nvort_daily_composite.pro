;-----------------------------------------------------------------------------------------------------------------------------
; Reads in MERRA data and plots number of cyclonic lobes in the NH on each level each day
;
@stddat
@kgmt
@ckday
@kdate
@rd_merra_nc3
@range_ring

re=40000./2./!pi
rad=double(180./!pi)
dtr=double(!pi/180.)
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0

px1a = .22
px1b = .73
px2a = .52
px2b = .95
py1a = .50
py1b = .95
py2a = .45
py2b = .66
py3a = .15
py3b = .35

SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.1,0.6,0.1,0.6,0.1,0.6]
yorig=[0.7,0.7,0.4,0.4,0.1,0.1]
xlen=0.25
ylen=0.25
cbaryoff=0.1
cbarydel=0.01

a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
loadct,39
mcolor=!p.color
icolmax=255
mcolor=icolmax
icmm1=icolmax-1B
icmm2=icolmax-2B
device,decompose=0
!NOERAS=-1
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nzdim,ysize=nydim,retain=2,colors=162
endif
days = 0
months = ['Apr','May','Jun','Jul','Aug','Sep','Oct','Nov']
MONTH = ['04','05','06','07','08','09','10','11']
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
;
; Read ES day zeros
;
restore, '/Users/harvey/Harvey_etal_2014/Post_process/MLS_ES_daily_max_T_Z.sav'
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
kcount=0L
result=size(MAXHEIGHTTHETA)
nevents=result(1)
for iES = 0L, nevents - 1L do begin
    sevent=string(format='(i2.2)',ies+1)
    sevent=strtrim(strcompress(string(format='(I3.2)',ies+1)),2)

restore,filename='merra_zt_nvort_ES_event_'+sevent+'.sav'	;,nvort,th2r,sdate_all
ndays=n_elements(sdate_all)
nz=n_elements(th2r)
if ies eq 0L then nvort_all=0.*nvort
for i=0L,ndays-1L do begin
for k=0L,nz-1L do begin
    if nvort(i,k) gt nvort_all(i,k) then nvort_all(i,k)=nvort(i,k)
endfor
endfor

endfor
;
; save postscript version
;
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/times,filename='../Figures/merra_zt_nvort_ES_event_composite.ps'
       !p.charsize=1.25
       !p.thick=2
       !p.charthick=5
       !p.charthick=5
       !y.thick=2
       !x.thick=2
    endif

plotit:

        x2d=fltarr(ndays,nz)
        y2d=fltarr(ndays,nz)
        for i=0,ndays-1 do y2d(i,*)=th2r
        for j=0,nz-1 do x2d(*,j)=-30+findgen(ndays)

print,max(nvort)
;erase
!type=2^2+2^3
set_viewport,0.2,0.9,0.3,0.7
contour,nvort_all,-30+findgen(ndays),th2r,/nodata,xrange=[-30,30],yrange=[min(th2r),max(th2r)],$
        xtitle='Days since ES onset (4 Events)',ytitle='Theta (K)',/noeras,color=0,charsize=1.5,charthick=2
index=where(nvort_all eq 1)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=0,symsize=0.5
index=where(nvort_all eq 2)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=250,symsize=1
index=where(nvort_all eq 3)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=200,symsize=1.5
index=where(nvort_all eq 4)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=170,symsize=1.5
index=where(nvort_all eq 5)
if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=50,symsize=1.5

imin=1.
imax=5.
ymnb=0.3 -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,0.2,0.9,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,$
      xtitle='MERRA # Cyclonic Vortices',charthick=2,charsize=1.25
ybox=[0,10,10,0,0]
x1=imin
col1=[0,250,200,170,50]
nlvls=n_elements(col1)
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor

        if setplot ne 'ps' then stop
        if setplot eq 'ps' then begin
           device, /close
           spawn,'convert -trim ../Figures/merra_zt_nvort_ES_event_composite.ps -rotate -90 ../Figures/merra_zt_nvort_ES_event_composite.png'
           spawn,'rm -f ../Figures/merra_zt_nvort_ES_event_composite.ps'
        endif
end
