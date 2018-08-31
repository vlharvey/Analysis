;
; plot ACE zonal mean temperature, averaged over some time period
;
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,0.8*cos(a),0.8*sin(a),/fill
setplot='x'
read,'setplot=',setplot
mcolor=icolmax
icmm1=icolmax-1
icmm2=icolmax-2
nxdim=600 & nydim=600
xorig=[0.1,0.6,0.1,0.6,0.1,0.6,0.1,0.6]
yorig=[0.7,0.7,0.5,0.5,0.3,0.3,0.1,0.1]
npan=n_elements(xorig)
xlen=0.3
ylen=0.15
cbaryoff=0.08
cbarydel=0.02
!NOERAS=-1
!p.font=1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
month='        '+['J','F','M','A','M','J','J','A','S','O','N','D',' ']
dirh='/aura3/data/ACE_data/Datfiles/'
;
; restore monthly mean zonal mean binned in latitude
; vars: latbin,altitude,tempyz,ntempyz,ch4yz,nch4yz,$
;     h2oyz,nh2oyz,hno3yz,nhno3yz,no2yz,nno2yz,o3yz,no3yz
;
restore,file='ACEorig_20060401-20060531.sav'
sdate0='20060401'
sdate1='20060531'

      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         device,font_size=9
         device,/landscape,bits=8,filename='ace_yz_'+sdate0+'-'+sdate1+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
      endif

erase
xyouts,.3,.95,'ACE '+sdate0+'-'+sdate1,/normal,charsize=2.5,color=0
for ii=0L,npan-1L do begin   ; loop over species
    if ii eq 0L then begin
       plotdata=tempyz & plottitle='Temperature'
       level=180.+10.*findgen(11)
    endif
    if ii eq 1L then begin
       plotdata=o3yz & plottitle='Ozone (ppmv)'
index=where(plotdata ne -99.)
plotdata(index)=1.e6*plotdata(index)
       level=findgen(11)
    endif
    if ii eq 2L then begin
       plotdata=h2oyz & plottitle='H2O (ppmv)'
index=where(plotdata ne -99.)
plotdata(index)=1.e6*plotdata(index)
       level=0.7*findgen(11)
    endif
    if ii eq 3L then begin
       plotdata=hno3yz & plottitle='HNO3 (ppbv)'
index=where(plotdata ne -99.)
plotdata(index)=1.e9*plotdata(index)
       level=findgen(11)
    endif
    if ii eq 4L then begin
       plotdata=no2yz & plottitle='NO2 (ppbv)'
index=where(plotdata ne -99.)
plotdata(index)=1.e9*plotdata(index)
       level=findgen(11)
    endif
    if ii eq 5L then begin
       plotdata=ch4yz & plottitle='Methane (ppmv)'
index=where(plotdata ne -99.)
plotdata(index)=1.e6*plotdata(index)
       level=0.2*findgen(11)
    endif
    if ii eq 6L then begin
       plotdata=n2oyz & plottitle='N2O (ppmv)'
index=where(plotdata ne -99.)
plotdata(index)=1.e6*plotdata(index)
       level=0.02*findgen(11)
    endif
    if ii eq 7L then begin
       plotdata=n2o5yz & plottitle='N2O5 (ppbv)'
index=where(plotdata ne -99.)
plotdata(index)=1.e9*plotdata(index)
       level=0.2*findgen(11)
    endif

index=where(plotdata ne -99.)
print,plottitle,' ',min(plotdata(index)),max(plotdata)
;
; fill data void regions
;
    plotsave=plotdata
    plotfilled=plotdata
    for k=0,n_elements(altitude)-1L do begin
        plotlev=reform(plotdata(*,k))
        index1=where(plotlev ne -99.,ngood)
        index2=where(plotlev eq -99.)
        if ngood gt 1 and index1(0) ne -1 and index2(0) ne -1 then begin
           filled=interpol(plotlev(index1),index1,index2)
           plotfilled(index2,k)=filled
        endif
    endfor
    plotdata=plotfilled
;
; plot zonal mean temperature
;
    !type=2^2+2^3
    xmn=xorig(ii)
    xmx=xorig(ii)+xlen
    ymn=yorig(ii)
    ymx=yorig(ii)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*mcolor/nlvls
    if ii lt 6 then xlabs=' '+strarr(7)
    if ii ge 6 then xlabs=['-90','-60','-30','0','30','60','90']
    contour,plotdata,latbin,altitude,xrange=[-90.,90.],yrange=[1.,80.],xticks=6,$
            xtickname=xlabs,charsize=1.5,levels=level,/cell_fill,$
            title=plottitle,c_color=col1,color=0,min_value=-99.
;   contour,plotdata,latbin,altitude,/overplot,levels=level,color=0,/follow,min_value=-99.,$
;           c_labels=0*level
    imin=min(level)
    imax=max(level)
    xmnb=xmx+.07
    xmxb=xmnb+.01
    set_viewport,xmnb,xmxb,ymn,ymx
    !type=2^2+2^3+2^5
    plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],color=0,charsize=1.5
    xbox=[0,10,10,0,0]
    y1=imin
    dy=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
        ybox=[y1,y1,y1+dy,y1+dy,y1]
        polyfill,xbox,ybox,color=col1(j)
        y1=y1+dy
    endfor

endfor

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim ace_yz_'+sdate0+'-'+sdate1+'.ps -rotate -90 ace_yz_'+sdate0+'-'+sdate1+'.jpg'
endif
end
