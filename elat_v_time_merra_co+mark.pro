;
; CO-based Equivalent latitude vs. time plot of MLS CO, the CO "vortex edge" (lowlat), and the Nash edge
;
@stddat
@kgmt
@ckday
@kdate
@rd_merra_nc3
@rd_sdwaccm4_nc3
@calcelat2d

re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
nrr=91L
yeq=findgen(nrr)
;index=where(yeq mod 2 eq 0,nrr)
;yeq=yeq(index)				; 2 degree bins

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
xorig=[.15,0.1,0.55,0.55]
yorig=[.25,.1,.55,.1]
xlen=0.8
ylen=0.6
cbaryoff=0.1
cbarydel=0.01
PI2=6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
!NOERAS=-1
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
dirm='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
dir='/Volumes/atmos/aura6/data/MLS_data/Datfiles_Grid/MLS_grid5_ALL_v3.3_'

for iyear=2004,2013 do begin

lstmn=12L & lstdy=10L & lstyr=iyear
ledmn=1L & leddy=20L & ledyr=lstyr+1L	;2010L
lstday=0L & ledday=0L
minyear=lstyr
maxyear=ledyr
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
goto,getit
;
; get date range
;
print, ' '
print, '      MERRA Version '
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 2000 then lstyr=lstyr+2000
if ledyr lt 2000 then ledyr=ledyr+2000
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=(ledday-lstday+1L)
leapday=0L
if ledyr mod 4 eq 0 then leapday=1
kday=kday+leapday
elatedge_time=fltarr(kday)
coedge_time=fltarr(kday)
lowlat_elatedge_time=-9999.+fltarr(kday)
lowlat_coedge_time=-9999.+fltarr(kday)
sfelatedge_time=-9999.+fltarr(kday)
markcoelatedge_time=-9999.+fltarr(kday)
marksfelatedge_time=-9999.+fltarr(kday)
pvelatedge_time=-9999.+fltarr(kday)
nashedge_time=-9999.+fltarr(kday)
sdate_time=strarr(kday)
ytco=-9999.+fltarr(kday,nrr)
ytspeed=-9999.+fltarr(kday,nrr)
ytmark=-9999.+fltarr(kday,nrr)
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; --- Test for end condition
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit
;
; construct date string
;
      syr=strcompress(iyr,/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
      print,sdate
      sdate_time(icount)=sdate
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
        dum=findfile(ifile)
        if dum(0) eq '' then goto,jumpstep
        restore,ifile
        print,'restored '+ifile
;
; MERRA
;
        ifile=dirm+sdate+'.nc3'
        rd_merra_nc3,ifile,nc,nr,nth,alon,alat,th,pv2,p2,$
            u2,v2,qdf2,mark2,qv2,z2,sf2,q2,iflag
        print,iflag,ifile
        sp2=sqrt(u2^2.+v2^2.)
;
; choose theta surface
;
        rth=1400.
;       print,th
;       read,'Enter desired theta ',rth
        index=where(abs(rth-th) eq min(abs(rth-th)))
        ith=index(0)
        sth=strcompress(long(th(ith)),/remove_all)+'K'
        pv1=transpose(reform(pv2(0:nr-1,*,ith)))
        sp1=transpose(reform(sp2(0:nr-1,*,ith)))
;
; choose pressure
;
        rpress=2.0
;       print,pmls
;       read,'Enter desired pressure ',rpress
        index=where(abs(rpress-pmls) eq min(abs(rpress-pmls)))
        ilev=index(0)
        spress=strcompress(long(pmls(ilev)),/remove_all)+'hPa'
        nc=n_elements(lon)
        nr=n_elements(lat)
        nl=n_elements(pmls)
;       alat=lat
;       alon=lon
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
;
; horizontal CO gradient
;
        co1=reform(co_grid(*,*,ilev))*1.e6
;       co1=smooth(co1,3,/edge_truncate)
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
                cograd1(i,j) = sqrt(dqdx*dqdx+dqdy*dqdy)	;/abs(co1(i,j))	;/comax
;
; allowing negative on vortex interior is useful to isolate edge but if vortex is offset from the pole dCO/dy<0 should be >0
;
;               if (dqdy le 0.0) then cograd1(i,j) = -sqrt(dqdx*dqdx+dqdy*dqdy)$
;                                                    *abs(co1(i,j))/comax
;
; without normalization
;
;               cograd1(i,j) = sqrt(dqdx*dqdx+dqdy*dqdy)       ;/abs(co1(i,j))
;               if (dqdy le 0.0) then cograd1(i,j) = -1.0*cograd1(i,j)

            endfor
        endfor
;
; poles are bad and neighbooring lats
;
        cograd1(*,0)=0./0.
        cograd1(*,1)=0./0.
        cograd1(*,nr-1)=0./0.
        cograd1(*,nr-2)=0./0.
;
; horizontal PV gradient
;
        pvgrad1=pv1*0.0
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
        
                dqdx = (pv1(ip1,j)-pv1(im1,j))/(dx2*csy)
                dqdy = (pv1(i,jp1)-pv1(i,jm1))/dy2
                pvgrad1(i,j) = sqrt(dqdx*dqdx+dqdy*dqdy)	;/abs(pv1(i,j))  ;/pvmax
;
; allowing negative on vortex interior is useful to isolate edge but if vortex is offset from the pole dCO/dy<0 should be >0
;
;               if (dqdy le 0.0) then pvgrad1(i,j) = -sqrt(dqdx*dqdx+dqdy*dqdy)$
;                                                    *abs(pv1(i,j))/pvmax
;
; without normalization
;
;               pvgrad1(i,j) = sqrt(dqdx*dqdx+dqdy*dqdy)       ;/abs(pv1(i,j))
;               if (dqdy le 0.0) then pvgrad1(i,j) = -1.0*pvgrad1(i,j)

            endfor
        endfor
;
; poles are bad and neighbooring lats
;
        pvgrad1(*,0)=0./0.
        pvgrad1(*,1)=0./0.
        pvgrad1(*,nr-1)=0./0.
        pvgrad1(*,nr-2)=0./0.
;
; CO Elat - set SH values to -1
;
        index=where(lat lt 0.)
        cosave=co1
        cosave(index)=-1.*cosave(index)
        elat=calcelat2d(cosave,alon,alat)
;
; PV elat
;
        pvelat=calcelat2d(pv1,alon,alat)
;
; mean CO and CO gradient within 1 degree spaced elat bins
; mean CO gradient
;
       cobin=fltarr(nrr)
       cogradbin=fltarr(nrr)
       for i=0L,nrr-1L do begin
           ip1=i+1
           if i eq nrr-1 then ip1=nrr-1
           im1=i-1
           if i eq 0L then im1=0
           index=where(y2d gt 0. and elat ge yeq(im1) and elat lt yeq(ip1))
           if index(0) ne -1L then cobin(i)=mean(co1(index))
           if index(0) ne -1L then cogradbin(i)=mean(cograd1(index))
       endfor
       ytco(icount,*)=cobin
;
; derivative of Elat wrt CO
;
       delatlevs=smooth(deriv(yeq,cobin),7,/edge_truncate)
;
; mean PV within 1 degree spaced elat
; mean PV gradient
;
       pvbin=fltarr(nrr)
       pvgradbin=fltarr(nrr)
       spbin=fltarr(nrr)
       for i=0L,nrr-1L do begin
           ip1=i+1
           if i eq nrr-1 then ip1=nrr-1
           im1=i-1
           if i eq 0L then im1=0
           index=where(y2d gt 0. and pvelat ge yeq(im1) and pvelat lt yeq(ip1))
           if index(0) ne -1L then pvbin(i)=mean(pv1(index))
           if index(0) ne -1L then pvgradbin(i)=mean(pvgrad1(index))
           if index(0) ne -1L then spbin(i)=mean(sp1(index))
       endfor
       ytspeed(icount,*)=spbin
;
; yikes, why is PV vs Elat so noisy?
;
;      pvbin=smooth(pvbin,3,/edge_truncate)
;
; derivative of PV Elat wrt PV
;
       dpvelatlevs=smooth(deriv(yeq,pvbin),7,/edge_truncate)
;
; apply "sloping filter" equal to 1 at 80 and 0 at 90 (1.125-yeq/80.)/0.125
;
       index=where(yeq ge 80.)
       delatlevs(index)=delatlevs(index)*((1.125-yeq(index)/80.)/0.125)
       dpvelatlevs(index)=dpvelatlevs(index)*((1.125-yeq(index)/80.)/0.125)
       spbin(index)=spbin(index)*((1.125-yeq(index)/80.)/0.125)
;
; Nash product of wind and dpv/elat
;
       prod=dpvelatlevs*spbin
;
; absolute maximum in the first derivative - as Nash
;
       index=where(delatlevs eq max(delatlevs))
       elatedge=yeq(index(0))		; Elat value of the edge
       coedge=cobin(index(0))		; CO value of the edge
       index=where(dpvelatlevs eq max(dpvelatlevs))
       pvelatedge=yeq(index(0))		; PV Elat value of the edge
       pvedge=pvbin(index(0))		; PV value of the edge
       index=where(prod eq max(prod))
       nashedge=yeq(index(0))           ; Elat value of the "Nash" edge
;
; most equatorward local maximum in the CO-Elat first derivative
; require positive slope over 2 points prior to max and negative slope following max
;
flag=0.*delatlevs
ilim=2
for i=ilim,n_elements(delatlevs)-ilim-1L do begin
    if delatlevs(i) gt delatlevs(i-1) and delatlevs(i) gt delatlevs(i+1) then begin
       if delatlevs(i) gt delatlevs(i-ilim) and delatlevs(i) gt delatlevs(i+ilim) then flag(i)=1.
    endif
endfor
;
; and of the CO contours co-located with maximum CO gradients, require those gradients to be some fraction of the strength of the maximum gradient
;
index=where(flag eq 1 and delatlevs ge max(delatlevs)*0.5)      ;yeq gt 30.)
edgecandidates=[-99.]
coedgecandidates=[-99.]
if index(0) ne -1L then edgecandidates=yeq(index)
if index(0) ne -1L then coedgecandidates=cobin(index)
;print,'Candidates ',edgecandidates
;
; broadcast edges
;
;print,'CO Elat Edge ',elatedge
;print,'CO Elat Edge lowlat ',min(edgecandidates)
;print,'PV Elat Edge ',pvelatedge
;print,'Nash Edge ',nashedge
;
; save edges
;
       elatedge_time(icount)=elatedge
       coedge_time(icount)=coedge
       index=where(edgecandidates eq min(edgecandidates))
       lowlat_elatedge_time(icount)=edgecandidates(index)
       lowlat_coedge_time(icount)=coedgecandidates(index)
;print,'CO Value for Elat edge: ',coedge
;print,'CO Value for low lat Elat edge: ',coedgecandidates(index)
       pvelatedge_time(icount)=pvelatedge
       nashedge_time(icount)=nashedge
print,'CO Elat Edge ',lowlat_elatedge_time(icount)
print,'Nash Elat Edge ',nashedge

jumpstep:
icount=icount+1L
goto,jump

plotit:
getit:
restore,'elat_time_co_edges_'+yearlab+'.sav'

syear=strmid(sdate_time,0,4)
smon=strmid(sdate_time,4,2)
sday=strmid(sdate_time,6,2)
xindex=where(sday eq '15',nxticks)
xlabs=smon(xindex)	;+'/'+sday(xindex)
good=where(long(syear) ne 0L)
minyear=long(min(long(syear(good))))
maxyear=long(max(long(syear)))
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
;
; interpolate small gaps in time
;
for k=0,nrr-1 do begin
    dlev=reform(ytco(*,k))
    for i=1,kday-1 do begin
        if dlev(i) eq -9999. and dlev(i-1) ne -9999. then begin
           for ii=i+1,kday-1 do begin
               naway=float(ii-i)
               if naway le 25.0 and dlev(ii) ne 0. then begin
                  dlev(i)=(naway*dlev(i-1)+dlev(ii))/(naway+1.0)
                  goto,jump11
               endif
           endfor
jump11:
        endif
    endfor
    ytco(*,k)=dlev
    dlev=reform(ytspeed(*,k))
    for i=1,kday-1 do begin
        if dlev(i) eq -9999. and dlev(i-1) ne -9999. then begin
           for ii=i+1,kday-1 do begin
               naway=float(ii-i)
               if naway le 25.0 and dlev(ii) ne 0. then begin
                  dlev(i)=(naway*dlev(i-1)+dlev(ii))/(naway+1.0)
                  goto,jump12
               endif
           endfor
jump12:
        endif
    endfor
    ytspeed(*,k)=dlev
endfor
;
; save file
;
;save,file='elat_time_co_edges_'+yearlab+'.sav',kday,yeq,elatedge_time,coedge_time,lowlat_elatedge_time,lowlat_coedge_time,sfelatedge_time,markcoelatedge_time,marksfelatedge_time,pvelatedge_time,nashedge_time,sdate_time,ytco,ytspeed,ytmark,spress
;
; postscript file
;
if setplot eq 'ps' then begin
   lc=0
   xsize=nxdim/100.
   ysize=nydim/100.
   set_plot,'ps'
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='elat_v_time_merra_co+mark_'+yearlab+'_'+spress+'.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif

index=where(strmid(sdate_time,4,4) ge '1210' or strmid(sdate_time,4,4) le '0120')
sdate_time=sdate_time(index)
kday=n_elements(sdate_time)
YTCO=YTCO(index,*)
YTMARK=YTMARK(index,*)
YTSPEED=YTSPEED(index,*)
COEDGE_TIME=COEDGE_TIME(index)
ELATEDGE_TIME=ELATEDGE_TIME(index)
LOWLAT_COEDGE_TIME=LOWLAT_COEDGE_TIME(index)
LOWLAT_ELATEDGE_TIME=LOWLAT_ELATEDGE_TIME(index)
MARKCOELATEDGE_TIME=MARKCOELATEDGE_TIME(index)
MARKSFELATEDGE_TIME=MARKSFELATEDGE_TIME(index)
NASHEDGE_TIME=NASHEDGE_TIME(index)
PVELATEDGE_TIME=PVELATEDGE_TIME(index)
SFELATEDGE_TIME=SFELATEDGE_TIME(index)
;
; reset ticks
;
syear=strmid(sdate_time,0,4)
smon=strmid(sdate_time,4,2)
sday=strmid(sdate_time,6,2)
xindex=where(sday eq '01' or sday eq '15',nxticks)
xlabs=smon(xindex)+'/'+sday(xindex)
good=where(long(syear) ne 0L)
minyear=long(min(long(syear(good))))
maxyear=long(max(long(syear)))
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
; 
; save postscript version
;
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3+2^7
index=where(ytco gt 0.)
imin=0	;min(ytco(index))
imax=1.	;max(ytco)
nlvls=26L
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
level=imin+((imax-imin)/float(nlvls-1))*findgen(nlvls)
print,level
contour,ytco,1.+findgen(kday),yeq,levels=level,color=0,c_color=col1,/noeras,charsize=2,charthick=2,xrange=[1,kday],yrange=[30,90],/cell_fill,min_value=-9999.,yticks=6,$
        ytitle='Equivalent Latitude',xticks=nxticks-1,xtickname=xlabs,xtickv=xindex
index=where(lowlat_elatedge_time le 20.)
if index(0) ne -1L then lowlat_elatedge_time(index)=0./0.
;loadct,0
oplot,1.+findgen(kday),smooth(lowlat_elatedge_time,3,/edge_truncate,/Nan),color=mcolor,thick=10
index=where(nashedge_time le 0.)
if index(0) ne -1L then nashedge_time(index)=0./0.
oplot,1.+findgen(kday),smooth(nashedge_time,3,/edge_truncate,/Nan),color=mcolor*.9,thick=10,linestyle=5
index=where(pvelatedge_time le 0.)
if index(0) ne -1L then pvelatedge_time(index)=0./0.
;oplot,1.+findgen(kday),smooth(pvelatedge_time,3,/edge_truncate,/Nan),color=150,thick=10,linestyle=5
loadct,39
contour,ytspeed,1.+findgen(kday),yeq,levels=60+10*findgen(5),/noeras,charsize=2,thick=2,c_color=[150,180,210,230],/foll,/overplot,c_labels=[1,1,1,1,1,1,1,1]                     ; all contours
xyouts,xmx-0.25,ymn+0.03,yearlab,charsize=2,color=250,/normal,charthick=5
ymnb=ymn -cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xmn+0.01,xmx-0.01,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='MLS '+spress+' CO',/noeras,color=0,charsize=1,charthick=2
ybox=[0,10,10,0,0]
x2=imin
dx=(imax-imin)/(float(nlvls)-1)
for j=1,nlvls-1 do begin
    xbox=[x2,x2,x2+dx,x2+dx,x2]
    polyfill,xbox,ybox,color=col1(j)
    x2=x2+dx
endfor

; Close PostScript file and return control to X-windows
if setplot ne 'ps' then stop	;wait,1
if setplot eq 'ps' then begin
device, /close
spawn,'convert -trim elat_v_time_merra_co+mark_'+yearlab+'_'+spress+'.ps -rotate -90 elat_v_time_merra_co+mark_'+yearlab+'_'+spress+'.jpg'
endif

endfor
end
