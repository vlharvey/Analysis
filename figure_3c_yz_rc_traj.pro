;
; YZ plots of JJA and DJF 300-year average vstar and wstar 
;
loadct,39
mcolor=byte(!p.color)
icmm1=mcolor-1B
icmm2=mcolor-2B
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.15,0.55]
yorig=[0.4,0.4]
xlen=0.325
ylen=0.325
cbaryoff=0.1
cbarydel=0.01
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/atmos/harvey/WACCM_data/Datfiles/Datfiles_Ethan_600yr/CO2x1SmidEmax_yBWCN/3d_CO2x1SmidEmax_yBWCN_'
dir2='/atmos/harvey/WACCM_data/Datfiles/Datfiles_Ethan_600yr/CO2x1SmidEmax_yBWCN/ZM_CO2x1SmidEmax_yBWCN_'
smonth=['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec']
nmonth=n_elements(smonth)

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
;
; build MMDD dates
;
spawn,'ls '+dir+'????.sav',ifiles
ndays=n_elements(ifiles)

goto,quick
;
; loop over days of the year
;
mmdd=strarr(ndays)
for iday=0,ndays-1 do begin
;
; restore daily mean of all years
;
    ofile=ifiles(iday)
    result=strsplit(ofile,'_',/extract)
    result2=strsplit(result(-1),'.',/extract)
    mmdd(iday)=result2(0)
    print,'reading '+ofile
    restore,ofile	;,nc,nr,nth,alon,alat,th,ipvavg,pavg,uavg,vavg,qdfavg,coavg,zavg,sfavg,mavg,$
	                   ;	ipvsig,psig,usig,vsig,qdfsig,cosig,zsig,sfsig,msig
    restore,dir2+mmdd(iday)+'.sav'	; zm omega, qjoule, qrs_aur, qrs_euv, ttgw, t, utgw, v*, w*, z
    print,'reading '+dir2+mmdd(iday)+'.sav'

    if iday eq 0L then begin
       nz=n_elements(lev)
       tdjf=fltarr(nr,nth)
       udjf=fltarr(nr,nth)
       mdjf=fltarr(nr,nth)
       zdjf=fltarr(nr,nth)
       codjf=fltarr(nr,nth)
       wstardjf=fltarr(nr,nz)
       vstardjf=fltarr(nr,nz)
       zstardjf=fltarr(nr,nz)
       ndjf=fltarr(nr,nz)

       tjja=fltarr(nr,nth)
       ujja=fltarr(nr,nth)
       mjja=fltarr(nr,nth)
       zjja=fltarr(nr,nth)
       cojja=fltarr(nr,nth)
       wstarjja=fltarr(nr,nz)
       vstarjja=fltarr(nr,nz)
       zstarjja=fltarr(nr,nz)
       njja=fltarr(nr,nz)
    endif
vstar=reform(VSTAR_DAILY_MEAN(*,0:-2))  ; remove 1000 hPa  
wstar=reform(WSTAR_DAILY_MEAN(*,0:-2))  ; remove 1000 hPa  
;
; calculate temp
;
    tavg=0*pavg
    for k=0,nth-1 do tavg(*,*,k) = th(k)*( (pavg(*,*,k)/1000.)^(.286) )
;
; calculate zonal means
;
    uyz=mean(uavg,dim=2)
    coyz=mean(coavg,dim=2)
    zyz=mean(zavg,dim=2)
    myz=mean(mavg,dim=2)
    tyz=mean(tavg,dim=2)
;
; sum daily means in DJF and JJA
;
    if strmid(mmdd(iday),0,2) eq '01' or strmid(mmdd(iday),0,2) eq '02' or strmid(mmdd(iday),0,2) eq '12' then begin
       tdjf=tdjf+tyz
       udjf=udjf+uyz
       mdjf=mdjf+myz
       zdjf=zdjf+zyz
       codjf=codjf+coyz
       vstardjf=vstardjf+vstar
       wstardjf=wstardjf+wstar
       zstardjf=zstardjf+Z3_DAILY_MEAN/1000.
       ndjf=ndjf+1.
    endif

    if strmid(mmdd(iday),0,2) eq '06' or strmid(mmdd(iday),0,2) eq '07' or strmid(mmdd(iday),0,2) eq '08' then begin
       tjja=tjja+tyz
       ujja=ujja+uyz
       mjja=mjja+myz
       zjja=zjja+zyz
       cojja=cojja+coyz
       vstarjja=vstarjja+vstar
       wstarjja=wstarjja+wstar
       zstarjja=zstarjja+Z3_DAILY_MEAN/1000.
       njja=njja+1.
    endif
endfor
;
; average
;
tdjf=tdjf/njja
udjf=udjf/njja
mdjf=mdjf/njja
zdjf=zdjf/njja
codjf=codjf/njja
vstardjf=vstardjf/njja
wstardjf=wstardjf/njja
zstardjf=zstardjf/njja

tjja=tjja/njja
ujja=ujja/njja
mjja=mjja/njja
zjja=zjja/njja
cojja=cojja/njja
vstarjja=vstarjja/njja
wstarjja=wstarjja/njja
zstarjja=zstarjja/njja
;
; save file
;
save,file='yz_WMark_smidemax_DJF_JJA.sav',nr,nth,nz,alat,tdjf,udjf,mdjf,zdjf,codjf,vstardjf,wstardjf,zstardjf,tjja,ujja,mjja,zjja,cojja,vstarjja,wstarjja,zstarjja
quick:
restore,'yz_WMark_smidemax_DJF_JJA.sav'

vstardjfsave=vstardjf
wstardjfsave=wstardjf
zstardjfsave=zstardjf
vstarjjasave=vstarjja
wstarjjasave=wstarjja
zstarjjasave=zstarjja
;
; stratopause and mesopause heights
;
djf_strat=0.*alat
jja_strat=0.*alat
djf_meso=0.*alat
jja_meso=0.*alat
for j=0L,n_elements(alat)-1L do begin
    altitude=mean(zjja,dim=1)
    tprof=reform(tjja(j,*))
    index=where(altitude ge 40 and finite(tprof) eq 1)
    tprof=tprof(index)
    zprof=altitude(index)
    index=where(tprof eq min(tprof))
    jja_meso(j)=zprof(index(0))
    index=where(zprof lt 80.)
    tprof0=tprof(index)
    zprof0=zprof(index)
    index=where(tprof0 eq max(tprof0))
    jja_strat(j)=zprof0(index(0))

    altitude=mean(zdjf,dim=1)
    tprof=reform(tdjf(j,*))
    index=where(altitude ge 40 and finite(tprof) eq 1)
    tprof=tprof(index)
    zprof=altitude(index)
    index=where(tprof eq min(tprof))
    djf_meso(j)=zprof(index(0))
    index=where(zprof lt 80.)
    tprof0=tprof(index)
    zprof0=zprof(index)
    index=where(tprof0 eq max(tprof0))
    djf_strat(j)=zprof0(index(0))
endfor
;
; postscript file
;
if setplot eq 'ps' then begin
   lc=0
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   set_plot,'ps'
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='figure_3c_yz_rc_traj.ps'
   !p.charsize=1
   !p.thick=2
   !p.charthick=2
   !y.thick=2
   !x.thick=2
endif
;
; plot
;
restore,'c11_rb.tbl'
tvlct,c1,c2,c3
col2=1+indgen(11)
nlvls=n_elements(col2)

erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
tlevel=-1+0.2*findgen(nlvls)
contour,mjja,alat,zjja,/noera,/fill,color=0,c_color=col2,levels=tlevel,xrange=[-90,90],yrange=[30,125],xtitle='Latitude',ytitle='Altitude (km)',charsize=1,charthick=2,xticks=6,title='JJA'
index=where(tlevel gt 0.)
contour,mjja,alat,zjja,/noera,/foll,color=0,levels=tlevel(index),/overplot,c_labels=0*tlevel
index=where(tlevel lt 0.)
contour,mjja,alat,zjja,/noera,/foll,color=mcolor,c_linestyle=5,levels=tlevel(index),/overplot,c_labels=0*tlevel

wstarjja=wstarjja*100.
for i=0L,nr-1L do begin
    if i mod 5 ne 0 then vstarjja(i,*)=999.
    if i mod 5 ne 0 then wstarjja(i,*)=999.
endfor
index=where(zstarjja lt 30. or zstarjja gt 122.)
vstarjja(index)=999.
wstarjja(index)=999.
velovect,vstarjja,wstarjja,alat,mean(zstarjja,dim=1),/overplot,length=20,thick=3,missing=990.,color=0
;oplot,alat,jja_meso,thick=15,color=200
;oplot,alat,jja_strat,thick=15,color=0
;
; interpolate marker to RC altitudes (mjja on zjja to zstarjja) for trajectory initialization?
; (for now just get a back trajectory running from one point using seasonal average steady flow)
;
loadct,39
x0=-90.+2.*findgen(16)
y0=75.+0.*findgen(16)
ntraj=n_elements(x0)
oplot,[x0,x0],[y0,y0],psym=8,symsize=3,color=0
dsec=-86400.			; negative for back trajectories
for itraj=0L,ntraj-1L do begin
xold=x0(itraj) & yold=y0(itraj)
ymin=min(abs(x0))
ymax=max(abs(x0))
for iday=0L,50-1L do begin	; run for 2-months
;
; daily "wind" at parcel location
;
    xindex=where(abs(xold-alat) eq min(abs(xold-alat)))
    zprof=reform(zstarjjasave(xindex(0),*))
    yindex=where(abs(yold-zprof) eq min(abs(yold-zprof)))
    vv=vstarjjasave(xindex(0),yindex(0))
    ww=wstarjjasave(xindex(0),yindex(0))
    dkm=vv*dsec/1000.			; km distance in latitude
    dlat=dkm/ (!pi*re/180.)		; divide by km/deg to get dlat in degrees
    xnew=xold+dlat
    if xnew gt 90. then xnew=90.- (xnew-90.)
    if xnew lt -90. then xnew=-90.- (xnew+90.)
    dkm=ww*dsec/1000.
    ynew=yold+dkm

    oplot,[xold,xnew],[yold,ynew],psym=8,color=((abs(x0(itraj))-ymin)/(ymax-ymin))*mcolor,symsize=0.75
    xold=xnew
    yold=ynew
endfor	; loop over timesteps
endfor	; loop over trajectories

restore,'c11_rb.tbl'
tvlct,c1,c2,c3
col2=1+indgen(11)
nlvls=n_elements(col2)

!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
contour,mdjf,alat,zdjf,/noera,/fill,color=0,c_color=col2,levels=tlevel,xrange=[-90,90],yrange=[30,125],xtitle='Latitude',charsize=1,charthick=2,xticks=6,title='DJF'
index=where(tlevel gt 0.)
contour,mdjf,alat,zdjf,/noera,/foll,color=0,levels=tlevel(index),/overplot,c_labels=0*tlevel
index=where(tlevel lt 0.)
contour,mdjf,alat,zdjf,/noera,/foll,color=mcolor,c_linestyle=5,levels=tlevel(index),/overplot,c_labels=0*tlevel

wstardjf=wstardjf*100.
for i=0L,nr-1L do begin
    if i mod 5 ne 0 then vstardjf(i,*)=999.
    if i mod 5 ne 0 then wstardjf(i,*)=999.
endfor
index=where(zstardjf lt 30. or zstardjf gt 122.)
vstardjf(index)=999.
wstardjf(index)=999.
velovect,vstardjf,wstardjf,alat,mean(zstardjf,dim=1),/overplot,length=20,thick=3,missing=990.,color=0
;oplot,alat,djf_meso,thick=15,color=200
;oplot,alat,djf_strat,thick=15,color=0

loadct,39
x0=90.-2.*findgen(16)
y0=75.+0.*findgen(16)
ntraj=n_elements(x0)
oplot,[x0,x0],[y0,y0],psym=8,symsize=3,color=0
dsec=-86400.                    ; negative for back trajectories
for itraj=0L,ntraj-1L do begin
xold=x0(itraj) & yold=y0(itraj)
ymin=min(abs(x0))
ymax=max(abs(x0))
for iday=0L,50-1L do begin      ; run for 2-months
;
; daily "wind" at parcel location
;
    xindex=where(abs(xold-alat) eq min(abs(xold-alat)))
    zprof=reform(zstardjfsave(xindex(0),*))
    yindex=where(abs(yold-zprof) eq min(abs(yold-zprof)))
    vv=vstardjfsave(xindex(0),yindex(0))
    ww=wstardjfsave(xindex(0),yindex(0))
    dkm=vv*dsec/1000.                   ; km distance in latitude
    dlat=dkm/ (!pi*re/180.)             ; divide by km/deg to get dlat in degrees
    xnew=xold+dlat
    if xnew gt 90. then xnew=90.- (xnew-90.)
    if xnew lt -90. then xnew=-90.- (xnew+90.)
    dkm=ww*dsec/1000.
    ynew=yold+dkm

    oplot,[xold,xnew],[yold,ynew],psym=8,color=((abs(x0(itraj))-ymin)/(ymax-ymin))*mcolor,symsize=0.75
    xold=xnew
    yold=ynew
endfor  ; loop over timesteps
endfor  ; loop over trajectories

restore,'c11_rb.tbl'
tvlct,c1,c2,c3
col2=1+indgen(11)
nlvls=n_elements(col2)

level  = tlevel
nlvls  = n_elements(level)
slab=' '+strarr(n_elements(level))
!type=2^2+2^3+2^5+2^6
plot,[0,0],[0,0],xrange=[0,10],yrange=[0,1],/noeras,yticks=n_elements(level)-1L,$
      position = [.9,.4,.95,.725],ytickname=slab,/nodata
xyouts,.98,.4,'Anticyclone        Cyclone',/normal,orientation=90,color=0,charsize=1.25,charthick=2
xbox=[0,10,10,0,0]
y2=0
dy= 1./(n_elements(level))
for j=0,n_elements(col2)-1 do begin
    ybox=[y2,y2,y2+dy,y2+dy,y2]
    polyfill,xbox,ybox,color=col2[j]
    y2=y2+dy
endfor
loadct,0
slab=strcompress(string(format='(f4.1)',level),/remove_all)
slabcolor = fltarr(n_elements(level))*0.
slabcolor[0:4] = 255        ; set first few labels to white so they are visible
y1=dy/2 ; center of first color level
for i=0L,n_elements(slab)-1L do begin
    slab0=slab[i]
    xyouts,5,y1-dy/2.,slab0,charsize=1.3,/data,color=slabcolor[i],align = .5 ; This should place the label on the left side of each color level
    y1=y1+dy
endfor

;
; Close PostScript file and return control to X-windows
;
    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim figure_3c_yz_rc_traj.ps -rotate -90 figure_3c_yz_rc_traj.jpg'
;      spawn,'rm -f figure_3c_yz_rc_traj.ps'
    endif

end
