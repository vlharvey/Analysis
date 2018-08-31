;-----------------------------------------------------------------------------------------------------------------------------
; Reads in MLS and MERRA data and plots zonal and meridional phase of the Arctic vortex (tilt with altitude) after SSW events
;	 -------------------------------
;       |         Lynn Harvey           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 3/27/2014      |
;	 -------------------------------
;
@stddat			; Determines the number of days since Jan 1, 1956
@kgmt			; This function computes the Julian day number (GMT) from the
@ckday			; This routine changes the Julian day from 365(6 if leap yr)
@kdate			; gives back kmn,kdy information from the Julian day #.
@rd_merra_nc3

;-----------------------------------------------------

SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.1,0.55,0.1,0.55]
yorig=[0.55,0.55,0.1,0.1]
xlen=0.35
ylen=0.35
cbaryoff=0.02
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

RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
;restore, '/Users/harvey/Harvey_etal_2014/Post_process/MLS_ES_daily_max_T_Z.sav'
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
sswdates=[$
'20010206',$    ; for now choose six major SSW w/o ES from the most recent years for comparison to ES events since 2004
'20011229',$
'20020216',$
'20030117',$
'20070223',$
'20080222']
nevents=n_elements(sswdates)
kcount=0L
for iES = 0L, nevents - 1L do begin
    sevent=string(format='(i2.2)',ies+1)
    icount=0L
    kdays=61
;
; save postscript version
;
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/times,filename='../Figures/merra_vortex_phase_ssw_event_'+sevent+'.ps'
       !p.charsize=1.25
       !p.thick=2
       !p.charthick=5
       !p.charthick=5
       !y.thick=2
       !x.thick=2
    endif
    icount=0L

    sswdate0=sswdates(ies)
    iyr=long(strmid(sswdate0,0,4))
    imn=long(strmid(sswdate0,4,2))
    idy=long(strmid(sswdate0,6,2))
    jday = JULDAY(imn,idy,iyr)
;goto,plotit
koff=30
    jday0=jday-koff
    jday1=jday+koff
    CALDAT, jday0, lstmn ,lstdy , lstyr
    CALDAT, jday1, ledmn ,leddy , ledyr

lstday=0L & ledday=0L
if lstyr eq ledyr then yearlab=strcompress(lstyr,/remove_all)
if lstyr ne ledyr then yearlab=strcompress(lstyr,/remove_all)+'-'+strcompress(ledyr,/remove_all)
;goto,quick
;
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=long(ledday-lstday+1L)
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
erase
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
      if ndays gt ledday then goto,colorbar
;
; construct date string
;
      syr=strcompress(iyr,/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
;
; read daily file
;
        dum=findfile(dir+sdate+'.nc3')
        if dum ne '' then ncfile0=dir+sdate+'.nc3'
        rd_merra_nc3,ncfile0,nc,nr,nth,alon,alat,th,pv2,p2,$
           u2,v2,qdf2,mark2,qv2,z2,sf2,q2,iflag
        if iflag ne 0L then goto,jumpday
        tmp2=0.*p2
        for k=0L,nth-1L do tmp2(*,*,k)=th(k)*(p2(*,*,k)/1000.)^0.286
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

	x = where(th ge 500. and th le 10000., nx)
        th2=th(x)
        mark2=mark2(*,*,x)
        z2=z2(*,*,x)
        sf2=sf2(*,*,x)
        xphase=0*th2
        yphase=0*th2
        altarray=0.*th2
;
; max theta below stratopause max
;
        thlevel = reverse(alog(th2) - min(alog(th2),/nan))/(alog(10000.) - min(alog(th2),/nan))  *  254.
;
; plot
;
        if icount le 25 then begin
;          set_viewport,.225,.475,.55,.8
;          map_set,90.,-90.,0,/ortho, /grid,/noeras,/noborder,/contin,color=0
	   for ii = 0L, nx - 1L do begin
               marker=fltarr(nc+1L,nr2)
               marker[0L:nc-1L,*] = transpose(reform(mark2[nr2:nr-1,*,nx-1L-ii]))
               marker[nc,*] = marker(0,*)
               sf=fltarr(nc+1L,nr2)
               sf[0L:nc-1L,*] = transpose(reform(sf2[nr2:nr-1,*,nx-1L-ii]))
               sf[nc,*] = sf(0,*)
               z=fltarr(nc+1L,nr2)
               z[0L:nc-1L,*] = transpose(reform(z2[nr2:nr-1,*,nx-1L-ii]))
               z[nc,*] = z(0,*)
;              contour,marker,lons,alat(nr2:nr-1),levels=[.1],/overplot,color=thlevel[ii],thick=8
;
; superimpose center of vortex
;
               index=where(marker gt 0.)
               if index(0) ne -1L then begin
                  altarray(nx-1-ii)=mean(z(index))
                  index2=where(sf(index) eq min(sf(index)))
                  xphase(nx-1-ii)=x2d(index(index2(0)))
                  yphase(nx-1-ii)=y2d(index(index2(0)))
               endif
            endfor
        endif

        if icount ge 35 then begin
;          set_viewport,.625,.875,.55,.8
;          map_set,90.,-90.,0,/ortho, /grid,/noeras,/noborder,/contin,color=0
           for ii = 0L, nx - 1L do begin
               marker=fltarr(nc+1L,nr2)
               marker[0L:nc-1L,*] = transpose(reform(mark2[nr2:nr-1,*,nx-1L-ii]))
               marker[nc,*] = marker(0,*)
               sf=fltarr(nc+1L,nr2)
               sf[0L:nc-1L,*] = transpose(reform(sf2[nr2:nr-1,*,nx-1L-ii]))
               sf[nc,*] = sf(0,*)
               z=fltarr(nc+1L,nr2)
               z[0L:nc-1L,*] = transpose(reform(z2[nr2:nr-1,*,nx-1L-ii]))
               z[nc,*] = z(0,*)
;              contour,marker,lons,alat(nr2:nr-1),levels=[.1],/overplot,color=thlevel[ii],thick=8
;
; superimpose center of vortex
;
               index=where(marker gt 0.)
               if index(0) ne -1L then begin
                  altarray(nx-1-ii)=mean(z(index))
                  index2=where(sf(index) eq min(sf(index)))
                  xphase(nx-1-ii)=x2d(index(index2(0)))
                  yphase(nx-1-ii)=y2d(index(index2(0)))
               endif
           endfor
        endif
;
; phase plots
;
        theta=th2
        index=where(xphase ne 0.)
        theta=theta(index)
        xphase=xphase(index)
        yphase=yphase(index)
        altarray=altarray(index)
        index=where(theta le 9000.)
        theta=theta(index)
        xphase=xphase(index)
        yphase=yphase(index)
        altarray=altarray(index)
irot=145.
;index1=where(xphase lt 180.)
;if index1(0) ne -1L then irot=max(xphase(index1))
        index=where(xphase ge irot)
        if index(0) ne -1L then xphase(index)=xphase(index)-360.
;
; longitude phase
;
        !type=2^2+2^3
        if icount le 29L then begin
           set_viewport,.6,.9,.6,.9
           plot,xphase,altarray,color=0,xtitle='Longitude',ytitle='Altitude (km)',xrange=[irot-360.,irot],thick=6,yrange=[20.,80.],xticks=3,/noeras,/nodata
           oplot,xphase,altarray,color=(icount/(kdays+1.))*mcolor,psym=8,symsize=0.5
        endif
        if icount ge 31L then begin
           set_viewport,.6,.9,.2,.5
           plot,xphase,altarray,color=0,xtitle='Longitude',ytitle='Altitude (km)',xrange=[irot-360.,irot],thick=6,yrange=[20.,80.],xticks=3,/noeras,/nodata
           oplot,xphase,altarray,color=(icount/(kdays+1.))*mcolor,psym=8,symsize=0.5
        endif
;
; latitude phase
;
        if icount le 29L then begin
           set_viewport,.2,.5,.6,.9
           plot,yphase,altarray,color=0,xtitle='Latitude',ytitle='Altitude (km)',xrange=[40.,90.],yrange=[20.,80.],thick=6,/noeras,/nodata
           oplot,yphase,altarray,color=(icount/(kdays+1.))*mcolor,thick=8
        endif
        if icount ge 31L then begin
           set_viewport,.2,.5,.2,.5
           plot,yphase,altarray,color=0,xtitle='Latitude',ytitle='Altitude (km)',xrange=[40.,90.],yrange=[20.,80.],thick=6,/noeras,/nodata
           oplot,yphase,altarray,color=(icount/(kdays+1.))*mcolor,thick=8
        endif
print,icount,iday-30,' ',sdate

        icount=icount+1L
        jumpday:
goto,jump
colorbar:
;
; color bar
;
       xyouts,.3,0.95,'MERRA SSW Day 0 = '+sswdate0,/normal,charsize=1.5,charthick=2,color=0
       level1 = -30+3*findgen(21)
       nlvls  = kday
       col1 = (1 + indgen(nlvls)) * icolmax / nlvls    ; define colors
       !type=2^2+2^3+2^6                       ; no y title or ticsks
       imin=min(level1)
       imax=max(level1)
       slab=' '+strarr(21)
       set_viewport,.2,.9,.09,.12
       plot,[imin,imax],[0,0],yrange=[0,10],xrange=[0,10],/noeras,xticks=n_elements(level1)-1L,$
             xstyle=1, xtickname=slab,xtitle = 'Days From SSW Onset ('+sswdate0+')',color=0,charsize=1.25
       ybox=[0,10,10,0,0]
       x2=0
       for j=1,n_elements(col1)-1 do begin
           dx= 10./(n_elements(col1)-1L)
           xbox=[x2,x2,x2+dx,x2+dx,x2]
           polyfill,xbox,ybox,color=col1(j-1)
           x2=x2+dx
       endfor
       slabcolor = fltarr(n_elements(slab))*0.
       slabcolor[0:7] = 255
       x1=0.2
       dx=(0.95-0.3)/20.
       sdays=strcompress(long(level1))
       for i=0L,21-1L do begin
          xyouts,x1+dx/2,0.09,sdays(i),charsize=.8,/normal,color=slabcolor[i],charthick=1, orientation= 90.
          x1=x1+dx
       endfor

        if setplot ne 'ps' then stop
        if setplot eq 'ps' then begin
           device, /close
           spawn,'convert -trim ../Figures/merra_vortex_phase_ssw_event_'+sevent+'.ps -rotate -90 /Users/harvey/Harvey_etal_2014/Figures/merra_vortex_phase_ssw_event_'+sevent+'.png'
           spawn,'rm -f ../Figures/merra_vortex_phase_ssw_event_'+sevent+'.ps'
        endif
endfor		; loop over SSW events
end
