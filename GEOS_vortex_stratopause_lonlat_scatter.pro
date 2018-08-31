;---------------------------------------------------------------------------------------------------
; Reads in GEOS data and plots zonal and meridional phase of the Arctic vortex (tilt with altitude) 
; -30 to +30 days around composite ES event
;
;	 -------------------------------
;       |         Lynn Harvey           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 11/24/2012      |
;	 -------------------------------
;
@stddat			; Determines the number of days since Jan 1, 1956
@kgmt			; This function computes the Julian day number (GMT) from the
@ckday			; This routine changes the Julian day from 365(6 if leap yr)
@kdate			; gives back kmn,kdy information from the Julian day #.
@rd_geos5_nc3_meto

;-----------------------------------------------------

SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.2,0.2]
yorig=[0.685,0.185]
xlen=0.6
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
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
days = 0
months = ['Apr','May','Jun','Jul','Aug','Sep','Oct','Nov']
MONTH = ['04','05','06','07','08','09','10','11']
;
; save postscript version
;
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/times,filename='../Figures/geos5_vortex_latlon_scatter.ps'
   !p.charsize=1.25
   !p.thick=2
   !p.charthick=5
   !p.charthick=5
   !y.thick=2
   !x.thick=2
endif
dir='/Volumes/earth/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS520.MetO.'
dir1='/Volumes/earth/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
;
; DAILYMAXHEIGHTLAT FLOAT     = Array[3, 61]
; DAILYMAXHEIGHTLON FLOAT     = Array[3, 61]
; DAILYMAXTEMPLAT FLOAT     = Array[3, 61]
; DAILYMAXTEMPLON FLOAT     = Array[3, 61]
; DAILYMEANHEIGHT FLOAT     = Array[3, 61]
; DAILYMEANTEMP   FLOAT     = Array[3, 61]
; DAILYMEANTHETA  FLOAT     = Array[3, 61]
; ESDATE          STRING    = Array[183]
; MAXHEIGHTTHETA  FLOAT     = Array[3, 61]
;
restore, '/Users/harvey/Harvey_etal_2014/Post_process/MLS_ES_daily_max_T_Z.sav'
ndays = 61L
dayofES = 1L
niday = 0L
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
vfiles=[$
'vortex_area_ES_20060130_geos5.sav',$
'vortex_area_ES_20090205_geos5.sav',$
'vortex_area_ES_20120130_geos5.sav']
for nn=0,n_elements(vfiles)-1L do begin
    restore,'/Users/harvey/Harvey_etal_2014/Post_process/'+vfiles(nn)
    for iday=0L,n_elements(sfile)-1L do begin
        file=dir1+sfile(iday)+'_AVG.V01.nc3'
        result=findfile(dir1+sfile(iday)+'_AVG.V01.nc3')
        if result(0) eq '' then file=dir+sfile(iday)+'_AVG.V01.nc3'
        rd_geos5_nc3_meto,file,nc,nr,nth,alon,alat,th,$
           pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
;
; declare vortex phase arrays
;
        if iday eq 0L and nn eq 0L then begin
;
; wrap around point
;
        lons = fltarr(nc+1L)
        lons[0:nc-1L] = alon
        lons[nc] = alon[0L]
;
; coordinate transformation
;
        nr2=nr/2
        x2d=fltarr(nc+1,nr/2)
        y2d=fltarr(nc+1,nr/2)
        for i=0,nc do y2d(i,*)=alat(nr/2:nr-1)
        for j=0,nr/2-1 do x2d(*,j)=lons
        xcn=fltarr(nc+1,nr2)
        ycn=fltarr(nc+1,nr2)
        for j=nr2,nr-1 do begin
            ANG = (90. - alat(j)) * RADG * 0.5
            FACTOR = TAN(ANG) * FAC20
            for i=0,nc do begin
                THETA = (lons(i) - 90.) * RADG
                xcn(i,j-nr2) = FACTOR * COS(THETA)
                ycn(i,j-nr2) = FACTOR * SIN(THETA)
            endfor
        endfor

        ndays=n_elements(sfile)
        xphase=fltarr(n_elements(vfiles),ndays,nth)
        yphase=fltarr(n_elements(vfiles),ndays,nth)
        endif

	for ii = 0L, nth - 1L do begin
            geos5dailymark = transpose(reform(mark2[nr2:nr-1,*,nth-1L-ii]))
            marker=fltarr(nc+1L,nr2)
            marker[0L:nc-1L,*] = geos5dailymark
            marker[nc,*] = marker(0,*)
            geos5dailysf = transpose(reform(sf2[nr2:nr-1,*,nth-1L-ii]))
            sf=fltarr(nc+1L,nr2)
            sf[0L:nc-1L,*] = geos5dailysf
            sf[nc,*] = sf(0,*)
;
; superimpose center of vortex
;
            index=where(marker gt 0. and y2d gt 0.)
            if index(0) ne -1L then begin
               index2=where(sf(index) eq min(sf(index)))
               xphase(nn,iday,nth-1L-ii)=x2d(index(index2(0)))
               yphase(nn,iday,nth-1L-ii)=y2d(index(index2(0)))
            endif
        endfor		; loop over level
     endfor		; loop over day
endfor			; loop over event
;
; longitude phase
;
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
zindex=where(th ge 500. and th le 2000.,nth2)
nlvls=nth2
col1=1+indgen(nlvls)*icolmax/nlvls
for k=0L,nth-1L do begin
    if th(k) ge 500. and th(k) le 2000. then begin
    xphaselev=reform(xphase(*,*,k))
    good=where(xphaselev ne 0. and DAILYMAXTEMPLON ne 0.)
    if k eq 13L then plot,xphaselev(good),DAILYMAXTEMPLON(good),color=(float(k-13)/float(nth2))*mcolor,ytitle='Stratopause Longitude',xrange=[0.,360.],$
       yrange=[0.,360.],xtitle='Vortex Longitude',charsize=1.5,charthick=2,psym=8
    oplot,xphaselev(good),DAILYMAXTEMPLON(good),color=(float(k)/float(nth))*mcolor,psym=8
    endif
endfor
imin=500.
imax=2000.
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,$
      xtitle='Theta (K)',charthick=2,charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor
;
; latitude phase
;
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
for k=0L,nth-1L do begin
    if th(k) ge 500. and th(k) le 2000. then begin
    yphaselev=reform(yphase(*,*,k))
    good=where(yphaselev ne 0. and DAILYMAXTEMPLAT ne 0.)
    if k eq 13L then plot,yphaselev(good),DAILYMAXTEMPLAT(good),color=(float(k-13)/float(nth2))*mcolor,ytitle='Stratopause Latitude',xrange=[20.,90.],$
       yrange=[20.,90.],xtitle='Vortex Latitude',charsize=1.5,charthick=2,psym=8
    oplot,yphaselev(good),DAILYMAXTEMPLAT(good),color=(float(k)/float(nth))*mcolor,psym=8
    endif
endfor
ymnb=yorig(1) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,$
      xtitle='Degrees Latitude',charthick=2,charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor

        if setplot ne 'ps' then stop
        if setplot eq 'ps' then begin
           device, /close
           spawn,'convert ../Figures/geos5_vortex_latlon_scatter.ps -rotate -90 /Users/harvey/Desktop/Harvey_etal_2014/Figures/geos5_vortex_latlon_scatter.png'
;          spawn,'rm -f ../Figures/geos5_vortex_latlon_scatter.ps'
        endif
end
