;-----------------------------------------------------------------------------------------------------------------------------
; Reads in MLS and MERRA data and plots zonal and meridional phase of the Arctic vortex (tilt with altitude) after ES events
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
@vortexshape

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
restore, '/Users/harvey/Harvey_etal_2014/Post_process/MLS_ES_daily_max_T_Z.sav'
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
kcount=0L
result=size(MAXHEIGHTTHETA)
nevents=result(1)
for iES = 0L, nevents - 1L do begin
    sevent=string(format='(i2.2)',ies+1)
    icount=0L
    ndays=61
;
; save postscript version
;
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
              /bold,/color,bits_per_pixel=8,/times,filename='../Figures/merra_vortex_phase_ES_event_'+sevent+'.ps'
       !p.charsize=1.25
       !p.thick=2
       !p.charthick=5
       !p.charthick=5
       !y.thick=2
       !x.thick=2
    endif
    icount=0L
    ndays=61
;
; timeseries of max stratopause height
;
    sdays=string(format='(I3.2)',-30+indgen(ndays))
    erase
    !type=2^2+2^3
;   set_viewport,.2,.9,.85,.95
;   plot,findgen(ndays),dailymeantheta[iES,*],color=0,xtitle='Days From ES Onset',thick=6,yrange=[500.,10000.],/noeras,ytitle='Theta (K)',$
;        xticks=ndays/10,xtickname=sdays(0:ndays-1:10),title='MLS ES event '+sevent+' ('+esdate(30+ndays*(ies))+')',/nodata
;   plots,30,500
;   plots,30,10000.,/continue,color=0,thick=3
;   oplot,findgen(ndays),dailymeantheta[iES,*],color=0,thick=6
;   for iday=0,ndays-1L do begin
;       oplot,[iday,iday],[dailymeantheta[iES,iday],dailymeantheta[iES,iday]],psym=8,color=(iday/(ndays+1.))*mcolor,symsize=1.5
;       a=findgen(9)*(2*!pi/8.)
;       usersym,1.5*cos(a),1.5*sin(a)
;       oplot,[iday,iday],[dailymeantheta[iES,iday],dailymeantheta[iES,iday]],psym=8,color=0,symsize=1.5
;       a=findgen(8)*(2*!pi/8.)
;       usersym,1.5*cos(a),1.5*sin(a),/fill
;   endfor

datetitle=esdate(30+ies*60)
    for iday =0L, ndays-1L do begin
        if iday lt 30L then sday=string(format='(I3.2)',iday-30)
        if iday ge 30L then sday=string(format='(I2.2)',iday-30)
        sdate=esdate(iday+60*ies)

        sdays(iday)=string(format='(I3.2)',iday-30)

        if sdate eq '' then goto,jumpday        ; missing day
;print,iday-30,' ',sdate
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

        if dailymeantheta[ies,iday] le 0. or dailymeantheta[ies,iday] gt 10000. then dailymeantheta[ies,iday]= dailymeantheta[ies,iday-1]
	xtheta = th - dailymeantheta[ies,iday]
	x = where(th ge 500. and th le 10000., nx)
        th2=th(x)
        mark2=mark2(*,*,x)
        z2=z2(*,*,x)
        sf2=sf2(*,*,x)
        xphase=0*th2
        yphase=0*th2
        altarray=0.*th2
;
; find vortex centroids, ellipticity
;
        marker_USLM = make_array(nc,nr,nx)
        for k=0,nx-1 do begin
            marker_USLM(*,*,k) = transpose(mark2(*,*,k))
        endfor
        shape = vortexshape(marker_USLM, alat, alon)
        centroid=shape.nhcentroid
        centroidx=reform(centroid(0,*))
        centroidy=reform(centroid(1,*))
        axis=shape.axis
        majoraxis=reform(axis(0,*))
        minoraxis=reform(axis(1,*))
        ellipticity=minoraxis/majoraxis
;print,iday,'ellipticity= ',ellipticity
;print,iday,'xcentroid= ',centroidx
;print,iday,'ycentroid= ',centroidy
;stop

        xphase=centroidx
        yphase=centroidy
;
; max theta below stratopause max
;
        thlevel = reverse(alog(th2) - min(alog(th2),/nan))/(alog(10000.) - min(alog(th2),/nan))  *  254.
        maxthetalevel = (alog(dailymeantheta[ies,iday])/(alog(10000.)))*254.
        if dailymeantheta[ies,iday] gt 10000. then begin
           thlevel = reverse(alog(th2) - min(alog(th2),/nan))/(alog(dailymeantheta[ies,iday]) - min(alog(th2),/nan))*254.
           maxthetalevel = (alog(dailymeantheta[ies,iday])/(alog(dailymeantheta[ies,iday])))*254.
        endif
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
;                 index2=where(sf(index) eq min(sf(index)))
;                 oplot,x2d(index(index2)),y2d(index(index2)),color=(iday/(ndays+1.))*mcolor,psym=8
;                 a=findgen(9)*(2*!pi/8.)
;                 usersym,1.5*cos(a),1.5*sin(a)
;                 oplot,x2d(index(index2)),y2d(index(index2)),color=mcolor,psym=8
;                 a=findgen(9)*(2*!pi/8.)
;                 usersym,1.5*cos(a),1.5*sin(a),/fill
;                 xphase(nx-1-ii)=x2d(index(index2(0)))
;                 yphase(nx-1-ii)=y2d(index(index2(0)))
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
;                 oplot,x2d(index(index2)),y2d(index(index2)),color=(iday/(ndays+1.))*mcolor,psym=8
;                 a=findgen(9)*(2*!pi/8.)
;                 usersym,1.5*cos(a),1.5*sin(a)
;                 oplot,x2d(index(index2)),y2d(index(index2)),color=mcolor,psym=8
;                 a=findgen(9)*(2*!pi/8.)
;                 usersym,1.5*cos(a),1.5*sin(a),/fill
;                 xphase(nx-1-ii)=x2d(index(index2(0)))
;                 yphase(nx-1-ii)=y2d(index(index2(0)))
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
print,xphase
        if index(0) ne -1L then xphase(index)=xphase(index)-360.
        if dailymaxheightlon[iES,iday] gt 180. then dailymaxheightlon[iES,iday]=dailymaxheightlon[iES,iday]-360.
;
; longitude phase
;
        if icount le 23L then begin
           set_viewport,.6,.9,.6,.9
           plot,xphase,altarray,color=0,xtitle='Longitude',ytitle='Altitude (km)',xrange=[irot-360.,irot],thick=6,yrange=[20.,80.],xticks=3,/noeras,/nodata
           oplot,xphase,altarray,color=(iday/(ndays+1.))*mcolor,psym=8	;,symsize=0.5
;          oplot,[dailymaxheightlon[iES,iday],dailymaxheightlon[iES,iday]],$
;                [dailymeantheta[iES,iday],dailymeantheta[iES,iday]],psym=8,color=(iday/(ndays+1.))*mcolor,symsize=1.5
;          a=findgen(9)*(2*!pi/8.)
;          usersym,1.5*cos(a),1.5*sin(a)
;          oplot, [dailymaxheightlon[iES,iday],dailymaxheightlon[iES,iday]],$
;                 [dailymeantheta[iES,iday],dailymeantheta[iES,iday]], psym = 8, color = mcolor*.9, symsize = 1.5
;          a=findgen(8)*(2*!pi/8.)
;          usersym,1.5*cos(a),1.5*sin(a),/fill
;          xyouts,0.,4500.,'-30 to -10',color=0,/data
        endif
        if icount ge 31L then begin
           set_viewport,.6,.9,.2,.5
           plot,xphase,altarray,color=0,xtitle='Longitude',ytitle='Altitude (km)',xrange=[irot-360.,irot],thick=6,yrange=[20.,80.],xticks=3,/noeras,/nodata
           oplot,xphase,altarray,color=(iday/(ndays+1.))*mcolor,psym=8	;,symsize=0.5
;          oplot,[dailymaxheightlon[iES,iday],dailymaxheightlon[iES,iday]],$
;                [dailymeantheta[iES,iday],dailymeantheta[iES,iday]],psym=8,color=(iday/(ndays+1.))*mcolor,symsize=1.5
;          a=findgen(9)*(2*!pi/8.)
;          usersym,1.5*cos(a),1.5*sin(a)
;          oplot, [dailymaxheightlon[iES,iday],dailymaxheightlon[iES,iday]],$
;                 [dailymeantheta[iES,iday],dailymeantheta[iES,iday]], psym = 8, color = 0, symsize = 1.5
;          a=findgen(8)*(2*!pi/8.)
;          usersym,1.5*cos(a),1.5*sin(a),/fill
;          xyouts,0.,4500.,'10 to 30',color=0,/data
        endif
;
; latitude phase
;
        if icount le 23L then begin
           set_viewport,.2,.5,.6,.9
           plot,yphase,altarray,color=0,xtitle='Latitude',ytitle='Altitude (km)',xrange=[40.,90.],yrange=[20.,80.],thick=6,/noeras,/nodata
           oplot,yphase,altarray,color=(iday/(ndays+1.))*mcolor,thick=8
;          oplot,[dailymaxheightlat[iES,iday],dailymaxheightlat[iES,iday]],$
;                [dailymeantheta[iES,iday],dailymeantheta[iES,iday]],psym=8,color=(iday/(ndays+1.))*mcolor,symsize=1.5
;          a=findgen(9)*(2*!pi/8.)
;          usersym,1.5*cos(a),1.5*sin(a)
;          oplot, [dailymaxheightlat[iES,iday],dailymaxheightlat[iES,iday]],$
;                 [dailymeantheta[iES,iday],dailymeantheta[iES,iday]], psym = 8, color = mcolor*.9, symsize = 1.5
;          a=findgen(8)*(2*!pi/8.)
;          usersym,1.5*cos(a),1.5*sin(a),/fill
;          xyouts,50.,4500.,'-30 to -10',color=0,/data
        endif
        if icount ge 31L then begin
           set_viewport,.2,.5,.2,.5
           plot,yphase,altarray,color=0,xtitle='Latitude',ytitle='Altitude (km)',xrange=[40.,90.],yrange=[20.,80.],thick=6,/noeras,/nodata
           oplot,yphase,altarray,color=(iday/(ndays+1.))*mcolor,thick=8
;          oplot,[dailymaxheightlat[iES,iday],dailymaxheightlat[iES,iday]],$
;                [dailymeantheta[iES,iday],dailymeantheta[iES,iday]],psym=8,color=(iday/(ndays+1.))*mcolor,symsize=1.5
;          a=findgen(9)*(2*!pi/8.)
;          usersym,1.5*cos(a),1.5*sin(a)
;          oplot, [dailymaxheightlat[iES,iday],dailymaxheightlat[iES,iday]],$
;                 [dailymeantheta[iES,iday],dailymeantheta[iES,iday]], psym = 8, color = 0, symsize = 1.5
;          a=findgen(8)*(2*!pi/8.)
;          usersym,1.5*cos(a),1.5*sin(a),/fill
;          xyouts,50.,4500.,'10 to 30',color=0,/data
        endif
print,icount,iday-30,' ',sdate

        icount=icount+1L
        jumpday:
endfor		; loop over days 
;
; color bar
;
       level1 = findgen(20)
       nlvls  = n_elements(sdays)
       col1 = (1 + indgen(nlvls)) * icolmax / nlvls    ; define colors
       !type=2^2+2^3+2^6                       ; no y title or ticsks
       imin=min(level1)
       imax=max(level1)
       slab=' '+strarr(20)
       set_viewport,.2,.9,.09,.12
       plot,[imin,imax],[0,0],yrange=[0,10],xrange=[0,10],/noeras,xticks=n_elements(level1)-1L,$
             xstyle=1,xtickname=slab, xtitle = 'Days From ES Onset ('+esdate(30+ies*60)+')',color=0,charsize=1.25
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
       x1=min(level1)+dx/2 + dx
       for i=0L,20-1L do begin
          xyouts,x1-dx/2,.76,sdays(i*3),charsize=.8,/data,color=slabcolor[i],charthick=1, orientation= 90.
          x1=x1+dx*3
       endfor

        if setplot ne 'ps' then stop
        if setplot eq 'ps' then begin
           device, /close
           spawn,'convert -trim ../Figures/merra_vortex_phase_ES_event_'+sevent+'.ps -rotate -90 /Users/harvey/Harvey_etal_2014/Figures/merra_vortex_phase_ES_event_'+sevent+'.png'
           spawn,'rm -f ../Figures/merra_vortex_phase_ES_event_'+sevent+'.ps'
        endif
endfor		; loop over ES events
end
