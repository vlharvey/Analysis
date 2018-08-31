;
; CO elat
; CO horizontal gradient - dCO/dx + dCO/dy
;
@calcelat2d

re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
nrr=91L
yeq=findgen(nrr)
latcircle=fltarr(nrr)
hem_frac=fltarr(nrr)
for j=0,nrr-2 do begin
    hy=re*dtr
    dx=re*cos(yeq(j)*dtr)*360.*dtr
    latcircle(j)=dx*hy
endfor
for j=0,nrr-1 do begin
    if yeq(j) ge 0. then index=where(yeq ge yeq(j))
    if index(0) ne -1 then hem_frac(j)=100.*total(latcircle(index))/hem_area
    if yeq(j) eq 0. then hem_frac(j)=100.
endfor

loadct,39
mcolor=byte(!p.color)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.1,0.55]
yorig=[0.05,0.05]
cbaryoff=0.02
cbarydel=0.01
xlen=0.4
ylen=0.4
PI2=6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
!NOERAS=-1
syear=['2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014']
syear=['2013']
nyear=n_elements(syear)
smon=['01','02','03','04','05','06','07','08','09','10','11','12']
nmon=n_elements(smon)
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
dir='/Volumes/atmos/aura6/data/MLS_data/Datfiles_Grid/MLS_grid5_ALL_v3.3_'

for iyear=0L,nyear-1L do begin
for imon=0L,nmon-1L do begin
;if imon gt 3 and imon lt 8 then goto,skipmon
;if imon lt 11 then goto,skipmon
ifiles=file_search(dir+syear(iyear)+smon(imon)+'??.sav',count=nfile)
if nfile eq 0L then goto,skipmon
;
; loop over files
;
icount=0L
kcount=0L
FOR n=0l,nfile-1l DO BEGIN
    result=strsplit(ifiles(n),'.',/extract)
    result2=result(1)
    result3=strsplit(result2,'_',/extract)
    sdate=result3(-1)
    print,sdate,icount
;
; read gridded MLS data on pressure
; CO_GRID         FLOAT     = Array[144, 96, 37]
; GP_GRID         FLOAT     = Array[144, 96, 55]
; H2O_GRID        FLOAT     = Array[144, 96, 55]
; LAT             DOUBLE    = Array[96]
; LON             DOUBLE    = Array[144]
; N2O_GRID        FLOAT     = Array[144, 96, 37]
; O3_GRID         FLOAT     = Array[144, 96, 55]
; PMLS            FLOAT     = Array[37]
; PMLS2           FLOAT     = Array[55]
; TP_GRID         FLOAT     = Array[144, 96, 55]
;
    ifile=dir+sdate+'.sav'
    restore,ifile
;
; first day
;
;if kcount eq 0L then begin
   rpress=1.
;  print,pmls
;  read,'Enter desired pressure ',rpress
   index=where(abs(rpress-pmls) eq min(abs(rpress-pmls)))
   ilev=index(0)
   spress=strcompress(pmls(ilev),/remove_all)+'hPa'
   nc=n_elements(lon)
   nr=n_elements(lat)
   nl=n_elements(pmls)
   alat=lat
   alon=lon
   dum=co_grid(*,*,0)
   lon=0.*dum
   lat=0.*dum
   for i=0,nc-1 do lat(i,*)=alat
   for j=0,nr-1 do lon(*,j)=alon
   area=0.*lat
   deltax=alon(1)-alon(0)
   deltay=alat(1)-alat(0)
   for j=0,nr-1 do begin
       hy=re*deltay*dtr
       dx=re*cos(alat(j)*dtr)*deltax*dtr
       area(*,j)=dx*hy    ; area of each grid point
   endfor

   x2d=fltarr(nc,nr)
   y2d=fltarr(nc,nr)
   for i=0,nc-1 do y2d(i,*)=alat
   for j=0,nr-1 do x2d(*,j)=alon
   kcount=1
;endif
;
; postscript file
;
    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       set_plot,'ps'
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/helvetica,filename='polar_daily_coelat+cograd_press_'+sdate+'_'+spress+'.ps'
       !p.charsize=1.25
       !p.thick=2
       !p.charthick=5
       !y.thick=2
       !x.thick=2
    endif
;
; normalized CO gradient
;
cograd2=0.*co_grid
for k=0,nl-1 do begin
co1=co_grid(*,*,k)
comax=max(abs(co1(*,nr/2:-1)))
cograd1=co1*0.0
for j = 0, nr-1 do begin
    jm1=j-1
    jp1=j+1
    if j eq 0 then jm1=0
    if j eq 0 then dy2=(alat(1)-alat(0))*!pi/180.
    if j eq nr-1 then jp1=nr-1
    if j eq nr-1 then dy2=(alat(nr-1)-alat(nr-2))*!pi/180.
    if (j gt 0 and j lt nr-1) then dy2=(alat(jp1)-alat(jm1))*!pi/180.
    csy=cos(alat(j)*!pi/180.)
    for i = 0, nc-1 do begin
        ip1 = i+1
        im1 = i-1
        if i eq 0 then im1 = nc-1
        if i eq 0 then dx2 = (alon(1)-alon(0))*!pi/180.
        if i eq nc-1 then ip1 = 0
        if i eq nc-1 then dx2 = (alon(0)-alon(nc-1))*!pi/180.
        if (i gt 0 and i lt nc-1) then dx2=(alon(ip1)-alon(im1))*!pi/180.

        dqdx = (co1(ip1,j)-co1(im1,j))/(dx2*csy)
        dqdy = (co1(i,jp1)-co1(i,jm1))/dy2
        cograd1(i,j) = sqrt(dqdx*dqdx+dqdy*dqdy)/abs(co1(i,j))	;/comax
;
; allowing negative on vortex interior is useful to isolate edge but if vortex is offset from the pole dCO/dy<0 should be >0
;
;       if (dqdy le 0.0) then cograd1(i,j) = -sqrt(dqdx*dqdx+dqdy*dqdy)$
;                                            *abs(co1(i,j))/comax
;
; without normalization
;
;       cograd1(i,j) = sqrt(dqdx*dqdx+dqdy*dqdy)       ;/abs(co1(i,j))
;       if (dqdy le 0.0) then cograd1(i,j) = -1.0*cograd1(i,j)

    endfor
endfor
cograd2(*,*,k)=smooth(cograd1*1.e6,3,/edge_truncate)
;print,pmls(k),max(cograd1)
endfor
;
; loop over levels
;
;for ith=20L,20L do begin	;0,nl-1L do begin
;
; extract level
;
    n2o=n2o_grid(*,*,ilev)*1.e9
    co=co_grid(*,*,ilev)*1.e6
;
; area of CO "Nash" vortex
;
    index=where(lat lt 0.)
    cosave=co
    cosave(index)=-1.*cosave(index)
    elat=calcelat2d(cosave,alon,alat)
;
    cograd=cograd2(*,*,ilev)
index=where(elat le 10.)	; zero tropical gradients that got enhanced by divide by co
cograd(index)=0.
cograd=smooth(cograd,5,/edge_truncate)
    index=where(abs(pmls2-pmls(ilev)) eq min(abs(pmls2-pmls(ilev))))
    gp=gp_grid(*,*,index(0))/1000.
;   print,'MLS P grids ',pmls(ilev),pmls2(index(0))
;
; set CO levels for hemisphere
;
nlvls=26L
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
nhindex=where(y2d gt 0.,nn)
imin=min(co(nhindex))
imax=max(co(nhindex))
colevel=imin+((imax-imin)/float(nlvls-1))*findgen(nlvls)
if max(colevel) eq 0. then goto,jumplev			; bad data
if finite(max(colevel)) eq 0 then goto,jumplev
;
; elat as a function of CO
;
elatlevs=0.*colevel
for i=1L,nlvls-1L do begin
    index=where(y2d gt 0. and co gt colevel(i-1) and co le colevel(i))
    if index(0) ne -1L then elatlevs(i)=mean(elat(index))
endfor
;
; mean CO within 1 degree spaced elat
; mean CO gradient
;
cobins=fltarr(nrr)
cogradbins=fltarr(nrr)
for i=0L,nrr-1L do begin
    ip1=i+1
    if i eq nrr-1 then ip1=nrr-1
    im1=i-1
    if i eq 0L then im1=0
    index=where(y2d gt 0. and elat ge yeq(im1) and elat lt yeq(ip1))
    if index(0) ne -1L then cobins(i)=mean(co(index))
    if index(0) ne -1L then cogradbins(i)=mean(cograd(index))
endfor
;
erase
set_viewport,0.15,0.45,0.6,0.9
!type=2^2+2^3
plot,elatlevs,colevel,color=0,/noeras,charsize=2,ytitle='CO Concentration (ppmv)',xtitle='Mean Elat',xrange=[0,90],psym=8
oplot,yeq,cobins,psym=1,color=0
delatlevs=smooth(deriv(yeq,cobins),7,/edge_truncate)
d2elatlevs=deriv(delatlevs)	;,cobins)
axis,/yax,yrange=[min(delatlevs),max(delatlevs)],/save,ytitle='dElat/dCO',charsize=2,color=mcolor*.9
;
; product of 1) mean COgrad as a function of elat and 2) dCO/delat
;
prod=delatlevs*cogradbins
;
; extract node from d2Elat/dCO2
;
elatsave=yeq
d2elatsave=d2elatlevs
oplot,yeq,delatlevs,color=mcolor*.9,psym=8
oplot,yeq,delatlevs,color=mcolor*.9,thick=2
oplot,yeq,0.*delatlevs,color=mcolor*.9

axis,/yax,yrange=[min(d2elatsave),max(d2elatsave)],/save,ytitle='d2Elat/dCO2',charsize=2,color=mcolor*.3
oplot,yeq,d2elatsave,color=mcolor*.3,psym=8
oplot,yeq,d2elatsave,color=mcolor*.3,thick=2
oplot,yeq,0.*d2elatsave,color=mcolor*.3
;
; absolute maximum in the first derivative - as Nash
;
;colevsave=colevel(1:-1)
colevsave=cobins
index=where(delatlevs eq max(delatlevs))
elatedge=elatsave(index(0))
coedge=colevsave(index(0))
; 
; absolute maximum in the product
;
index=where(prod eq max(prod))
elatedge2=elatsave(index(0))
coedge2=colevsave(index(0))
;
; most equatorward local maximum in the first derivative
;
flag=0.*delatlevs
for i=1L,n_elements(delatlevs)-2L do begin
    if delatlevs(i) gt delatlevs(i-1) and delatlevs(i) gt delatlevs(i+1) then flag(i)=1.
endfor
nhindex=where(y2d gt 0.,nn)
cohemmean=mean(co(nhindex))
cohemsig=stdev(co(nhindex))
index=where(flag eq 1 and cobins gt cohemmean-0.5*cohemsig)
print,'HEM MEAN/SIG ',cohemmean,cohemsig
print,cobins(index)
print,yeq(index)
elatedge=yeq(index(0))
coedge=colevsave(index(0))
;
; save postscript version
;
xyouts,.3,.95,sdate+' '+spress,color=0,charsize=2,charthick=2,/normal
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
nhindex=where(y2d gt 0.,nn)
zmin=min(gp(nhindex))
zmax=max(gp(nhindex))
zlevel=zmin+((zmax-zmin)/float(10))*findgen(10)

co=smooth(co,3,/edge_truncate)
lat(-1)=90.
alat(-1)=90.
map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,charsize=1.5,title='CO'	;,limit=[40.,0.,90.,360.]
contour,co,alon,alat,levels=colevel,/noeras,charsize=2,c_color=col1,/cell_fill,/overplot
map_set,90,0,-90,/ortho,/contin,/noerase,color=mcolor
;contour,gp,alon,alat,levels=zlevel,/noeras,charsize=2,color=mcolor*.8,/foll,/overplot,thick=3
;if d gt 0. then contour,co,alon,alat,/noeras,levels=comean,color=mcolor*.9,thick=7,/overplot,/foll			; McDonald and Smith
;for j=0L,n_elements(comeanpdf)-1L do contour,co,alon,alat,/noeras,levels=comeanpdf(j),color=0,/overplot,/foll,thick=5	; my candidates
;contour,co,alon,alat,levels=colevel(0:nlvls-1:2),/noeras,charsize=2,color=mcolor,/foll,/overplot,c_labels=0*colevel			; all contours
contour,elat,alon,alat,levels=10+10*findgen(8),/noeras,charsize=2,color=mcolor,/foll,/overplot,c_labels=[1,1,1,1,1,1,1,1]			; all contours
;contour,elat,alon,alat,levels=elatedge,/noeras,charsize=2,color=mcolor,/foll,/overplot,c_labels=[1],thick=8
contour,co,alon,alat,levels=coedge2,/noeras,charsize=2,color=mcolor*.9,/foll,/overplot,c_labels=[0],thick=8			; candidate with the most votes
print,'Elat Edge ',elatedge
print,'CO Edge ',coedge

print,'Elat Edge2 ',elatedge2
print,'CO Edge2 ',coedge2


    imin=min(colevel)
    imax=max(colevel)
    ymnb=ymn -cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn+0.01,xmx-0.01,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,color=0,charsize=1
    ybox=[0,10,10,0,0]
    x2=imin
    dx=(imax-imin)/(float(nlvls)-1)
    for j=1,nlvls-1 do begin
        xbox=[x2,x2,x2+dx,x2+dx,x2]
        polyfill,xbox,ybox,color=col1(j)
        x2=x2+dx
    endfor

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
nhindex=where(y2d gt 0.,nn)
imin=min(cograd(nhindex))
imax=max(cograd(nhindex))
level=imin+((imax-imin)/float(nlvls))*findgen(nlvls)
map_set,90,0,-90,/ortho,/contin,/grid,/noerase,color=0,charsize=1.5,title='CO Gradient'      ;,limit=[40.,0.,90.,360.]
contour,cograd,alon,alat,levels=level,/noeras,charsize=2,c_color=col1,/cell_fill,/overplot
map_set,90,0,-90,/ortho,/contin,/noerase,color=mcolor
;contour,zth,alon,alat,levels=zlevel,/noeras,charsize=2,color=.8*mcolor,/foll,/overplot,thick=3
;if d gt 0. then contour,cograd,alon,alat,/noeras,level=comean,color=mcolor*.9,thick=7,/overplot,/foll
;for j=0L,n_elements(comeanpdf)-1L do contour,cograd,alon,alat,/noeras,level=comeanpdf(j),color=0,/overplot,/foll,thick=5
contour,cograd,alon,alat,levels=level(0:nlvls-1:2),/noeras,charsize=2,color=mcolor,/foll,/overplot,c_labels=0*level
contour,co,alon,alat,levels=coedge2,/noeras,charsize=2,color=mcolor*.9,/foll,/overplot,c_labels=[0],thick=8                     ; candidate with the most votes
;
; mean gradient within CO bins
;
cogradbin=0.*colevel
for i=1L,nlvls-1L do begin
    index=where(co gt colevel(i-1) and co le colevel(i),nn)
    if index(0) ne -1L then cogradbin(i)=mean(cograd(index))
endfor
cogradbin=smooth(cogradbin,3,/edge_truncate)	; want edge influence to reduce highest-most CO bins
;
; treat gradient as CO as a function of elat
;
set_viewport,0.6,0.9,0.6,0.9
;plot,colevel,cogradbin,color=0,/noeras,charsize=2,xtitle='CO Concentration (ppmv)',ytitle='Mean CO Gradient',thick=5,yrange=[0.,max(cogradbin)+0.1*max(cogradbin)]
;index=where(cogradbin eq max(cogradbin))
;cogradlev=colevel(index(0))	; CO value where CO gradient is max

plot,yeq,cogradbins,color=0,/noeras,charsize=2,ytitle='Mean CO Gradient (ppmv/elat)',xtitle='Mean Elat',xrange=[0,90],thick=5
delatgradlevs=smooth(deriv(yeq,cogradbins),7,/edge_truncate)
d2elatgradlevs=deriv(delatgradlevs)     ;,cobins)
;axis,/yax,yrange=[min(delatgradlevs),max(delatgradlevs)],/save,ytitle='dElat/dCOgrad',charsize=2,color=mcolor*.9
axis,/yax,yrange=[min(prod),max(prod)],/save,ytitle='COgrad/elat * dCO/elat',charsize=2,color=mcolor*.9
;
; extract node from d2Elat/dCO2
;
elatsave=yeq
d2elatgradsave=d2elatgradlevs
;oplot,yeq,delatgradlevs,color=mcolor*.9,psym=8
;oplot,yeq,delatgradlevs,color=mcolor*.9,thick=2
;oplot,yeq,0.*delatgradlevs,color=mcolor*.9
oplot,yeq,prod,color=mcolor*.9,psym=8
oplot,yeq,prod,color=mcolor*.9,thick=2
oplot,yeq,0.*prod,color=mcolor*.9

;axis,/yax,yrange=[min(d2elatgradsave),max(d2elatgradsave)],/save,ytitle='d2Elat/dCOgrad2',charsize=2,color=mcolor*.3
;oplot,yeq,d2elatgradsave,color=mcolor*.3,psym=8
;oplot,yeq,d2elatgradsave,color=mcolor*.3,thick=2
;oplot,yeq,0.*d2elatgradsave,color=mcolor*.3

xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
map_set,90,0,-90,/ortho,/noerase
;contour,co,alon,alat,levels=cogradlev,/noeras,charsize=2,color=mcolor*.9,/foll,/overplot,c_labels=[0],thick=8
;
; superimpose all local maxima - bimodal distributions usually want lower CO value
;
cogradnodes=0./0.
for i=1L,nlvls-2L do begin
    if cogradbin(i-1) lt cogradbin(i) and cogradbin(i+1) lt cogradbin(i) then begin
       cogradnodes=[cogradnodes,colevel(i)]
    endif
endfor
index=where(finite(cogradnodes) eq 1.)
cogradnodes=cogradnodes(index)
;contour,co,alon,alat,levels=cogradnodes(sort(cogradnodes)),/noeras,charsize=2,color=mcolor*.9,/foll,/overplot,c_labels=[0],thick=8
;print,'CO Gradient Local Maxima ',cogradnodes

    imin=min(level)
    imax=max(level)
    ymnb=ymn -cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn+0.01,xmx-0.01,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,color=0,charsize=1
    ybox=[0,10,10,0,0]
    x2=imin
    dx=(imax-imin)/(float(nlvls)-1)
    for j=1,nlvls-1 do begin
        xbox=[x2,x2,x2+dx,x2+dx,x2]
        polyfill,xbox,ybox,color=col1(j)
        x2=x2+dx
    endfor

; Close PostScript file and return control to X-windows
     if setplot ne 'ps' then stop
     if setplot eq 'ps' then begin
        device, /close
        spawn,'convert -trim polar_daily_coelat+cograd_press_'+sdate+'_'+spress+'.ps -rotate -90 '+$
                            'polar_daily_coelat+cograd_press_'+sdate+'_'+spress+'.jpg'
        spawn,'rm -f polar_daily_coelat+cograd_press_'+sdate+'_'+spress+'.ps'
     endif
jumplev:
;endfor
icount=icount+1L
jumpstep:
endfor	; loop over files
;
skipmon:
endfor	; loop over months
endfor	; loop over years
end
