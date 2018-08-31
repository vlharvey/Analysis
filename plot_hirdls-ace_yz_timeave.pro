;
; plot HIRDLS and ACE zonal means and their differences
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
; restore zonal mean HIRDLS
;
restore,file='/aura3/data/HIRDLS_data/Analysis/HIRPROF_20060504-20060531.sav'
hdate0='20060504'
hdate1='20060531'
hirdls_altitude=altitude
;
; reverse HIRDLS altitudes to match ACE SOSST
;
x=reverse(hirdls_altitude)
hirdls_altitude=reform(hirdls_altitude(x))
hirdls_CH4YZ=reform(ch4yz(*,x))
hirdls_CLONO2YZ=reform(CLONO2YZ(*,x))
hirdls_H2OYZ=reform(H2OYZ(*,x))
hirdls_HNO3YZ=reform(HNO3YZ(*,x))
hirdls_N2O5YZ=reform(N2O5YZ(*,x))
hirdls_N2OYZ=reform(N2OYZ(*,x))
hirdls_NCH4YZ=reform(NCH4YZ(*,x))
hirdls_NCLONO2YZ=reform(NCLONO2YZ(*,x))
hirdls_NH2OYZ=reform(NH2OYZ(*,x))
hirdls_NHNO3YZ=reform(NHNO3YZ(*,x))
hirdls_NN2O5YZ=reform(NN2O5YZ(*,x))
hirdls_NN2OYZ=reform(NN2OYZ(*,x))
hirdls_NNO2YZ=reform(NNO2YZ(*,x))
hirdls_NO2YZ=reform(NO2YZ(*,x))
hirdls_NO3YZ=reform(NO3YZ(*,x))
hirdls_NTEMPYZ=reform(NTEMPYZ(*,x))
hirdls_O3YZ=reform(O3YZ(*,x))
hirdls_TEMPYZ=reform(TEMPYZ(*,x))
;
; restore monthly mean zonal mean binned in latitude
; vars: latbin,altitude,tempyz,ntempyz,ch4yz,nch4yz,$
;     h2oyz,nh2oyz,hno3yz,nhno3yz,no2yz,nno2yz,o3yz,no3yz
;
restore,file='ACEorig_20060401-20060531.sav'
adate0='20060401'
adate1='20060531'
ace_CH4YZ=ch4yz
ace_CLONO2YZ=CLONO2YZ
ace_H2OYZ=H2OYZ
ace_HNO3YZ=HNO3YZ
ace_N2O5YZ=N2O5YZ
ace_N2OYZ=N2OYZ
ace_NCH4YZ=NCH4YZ
ace_NCLONO2YZ=NCLONO2YZ
ace_NH2OYZ=NH2OYZ
ace_NHNO3YZ=NHNO3YZ
ace_NN2O5YZ=NN2O5YZ
ace_NN2OYZ=NN2OYZ
ace_NNO2YZ=NNO2YZ
ace_NO2YZ=NO2YZ
ace_NO3YZ=NO3YZ
ace_NTEMPYZ=NTEMPYZ
ace_O3YZ=O3YZ
ace_TEMPYZ=TEMPYZ
;
; difference arrays
;
diff_CH4YZ=0.*ch4yz
x=where(HIRDLS_CH4YZ ne -99. and ACE_CH4YZ ne -99.)
if x(0) ne -1L then diff_CH4YZ(x)=100.*(HIRDLS_CH4YZ(x)-ace_CH4YZ(x))/ace_CH4YZ(x)
diff_CLONO2YZ=0.*CLONO2YZ
x=where(HIRDLS_clono2YZ ne -99. and ACE_clono2YZ ne -99.)
if x(0) ne -1L then diff_clono2YZ(x)=100.*(HIRDLS_clono2YZ(x)-ace_clono2YZ(x))/ace_clono2YZ(x)
diff_H2OYZ=0.*H2OYZ
x=where(HIRDLS_h2oYZ ne -99. and ACE_h2oYZ ne -99.)
if x(0) ne -1L then diff_h2oYZ(x)=100.*(HIRDLS_h2oYZ(x)-ace_h2oYZ(x))/ace_h2oYZ(x)
diff_HNO3YZ=0.*HNO3YZ
x=where(HIRDLS_hno3YZ ne -99. and ACE_hno3YZ ne -99.)
if x(0) ne -1L then diff_hno3YZ(x)=100.*(HIRDLS_hno3YZ(x)-ace_hno3YZ(x))/ace_hno3YZ(x)
diff_N2O5YZ=0.*N2O5YZ
x=where(HIRDLS_n2o5YZ ne -99. and ACE_n2o5YZ ne -99.)
if x(0) ne -1L then diff_n2o5YZ(x)=100.*(HIRDLS_n2o5YZ(x)-ace_n2o5YZ(x))/ace_n2o5YZ(x)
diff_N2OYZ=0.*N2OYZ
x=where(HIRDLS_n2oYZ ne -99. and ACE_n2oYZ ne -99.)
if x(0) ne -1L then diff_n2oYZ(x)=100.*(HIRDLS_n2oYZ(x)-ace_n2oYZ(x))/ace_n2oYZ(x)
diff_NO2YZ=0.*NO2YZ
x=where(HIRDLS_no2YZ ne -99. and ACE_no2YZ ne -99.)
if x(0) ne -1L then diff_no2YZ(x)=100.*(HIRDLS_no2YZ(x)-ace_no2YZ(x))/ace_no2YZ(x)
diff_O3YZ=0.*O3YZ
x=where(HIRDLS_o3YZ ne -99. and ACE_o3YZ ne -99.)
if x(0) ne -1L then diff_o3YZ(x)=100.*(HIRDLS_o3YZ(x)-ace_o3YZ(x))/ace_o3YZ(x)
diff_TEMPYZ=0.*TEMPYZ
x=where(HIRDLS_tempYZ ne -99. and ACE_tempYZ ne -99.)
if x(0) ne -1L then diff_tempYZ(x)=100.*(HIRDLS_tempYZ(x)-ace_tempYZ(x))/ace_tempYZ(x)

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,font_size=9
   device,/landscape,bits=8,filename='hirdls-ace_yz_'+adate0+'-'+adate1+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
endif

erase
xyouts,.3,.95,'HIRDLS-ACE '+adate0+'-'+adate1,/normal,charsize=2.5,color=0
for ii=0L,npan-1L do begin   ; loop over species
    if ii eq 0L then begin
       plotdata=diff_tempyz & plottitle='Temperature'
    endif
    if ii eq 1L then begin
       plotdata=diff_o3yz & plottitle='Ozone (ppmv)'
    endif
    if ii eq 2L then begin
       plotdata=diff_h2oyz & plottitle='H2O (ppmv)'
    endif
    if ii eq 3L then begin
       plotdata=diff_hno3yz & plottitle='HNO3 (ppbv)'
    endif
    if ii eq 4L then begin
       plotdata=diff_no2yz & plottitle='NO2 (ppbv)'
    endif
    if ii eq 5L then begin
       plotdata=diff_ch4yz & plottitle='Methane (ppmv)'
    endif
    if ii eq 6L then begin
       plotdata=diff_n2oyz & plottitle='N2O (ppmv)'
    endif
    if ii eq 7L then begin
       plotdata=diff_n2o5yz & plottitle='N2O5 (ppbv)'
    endif
index=where(plotdata eq 0.)
if index(0) ne -1L then plotdata(index)=-99999.
level=-10.+findgen(21)
if ii gt 0L then level=-100.+10.*findgen(21)

index=where(plotdata ne -99999.)
print,plottitle,' ',min(plotdata(index)),max(plotdata)
;
; fill data void regions
;
    plotsave=plotdata
    plotfilled=plotdata
    for k=0,n_elements(altitude)-1L do begin
        plotlev=reform(plotdata(*,k))
        index1=where(plotlev ne -99999.,ngood)
        index2=where(plotlev eq -99999.)
        if ngood gt 1 and index1(0) ne -1 and index2(0) ne -1 then begin
           filled=interpol(plotlev(index1),index1,index2)
           plotfilled(index2,k)=filled
        endif
    endfor
;   plotdata=plotfilled
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
            title=plottitle,c_color=col1,color=0,min_value=-99999.
;   contour,plotdata,latbin,altitude,/overplot,levels=[5.,200.],color=0,/follow,min_value=-99999.,$
;           c_labels=[0,0]
;   contour,plotdata,latbin,altitude,/overplot,levels=[-200.,-5.],color=mcolor,/follow,min_value=-99999.,$
;           c_labels=[0,0]
    contour,plotdata,latbin,altitude,/overplot,levels=[0],color=0,/follow,min_value=-99999.,thick=2

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
   spawn,'convert -trim hirdls-ace_yz_'+adate0+'-'+adate1+'.ps -rotate -90 hirdls-ace_yz_'+adate0+'-'+adate1+'.jpg'
endif
end
