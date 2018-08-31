;-----------------------------------------------------------------------------------------------------------------------------
; Reads in MERRA data and plots vortex phase on each day
;
@stddat
@kgmt
@ckday
@kdate
@rd_merra_nc3
@vortexshape

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
nzdim=750
nydim=750
xorig=[0.1,0.6,0.1,0.6,0.1,0.6]
yorig=[0.7,0.7,0.4,0.4,0.1,0.1]
xlen=0.25
ylen=0.25
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
    icount=0L
    ndays=61
    for iday =0L, ndays-1L do begin
        if iday lt 30L then sday=string(format='(I3.2)',iday-30)
        if iday ge 30L then sday=string(format='(I2.2)',iday-30)
        sdate=esdate(iday+60*ies)
        if sdate eq '' then goto,jumpday        ; missing day
print,iday-30,' ',sdate
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
; save postscript version
;
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nzdim/100.
         ysize=nydim/100.
;        !p.font=0
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                /bold,/color,bits_per_pixel=8,/times,filename='../Figures/merra_vortex_phase_ES_event_'+sevent+'_ES_Day_'+sday+'.ps'
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !y.thick=2
         !x.thick=2
      endif
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
;
; theta below stratopause max height
;
;       if maxheighttheta[ies,iday] le 0. or maxheighttheta[ies,iday] gt 10000. then maxheighttheta[ies,iday]= maxheighttheta[ies,iday-1]
;       xtheta = th - maxheighttheta[ies,iday]
        x = where(th ge 500. and th le 10000., nz)
        if x(0) eq -1L then goto,jumpday
        th2=th(x)
        mark2=mark2(*,*,x)
        sf2=sf2(*,*,x)
        z2=z2(*,*,x)
        xphase=0*th2
        yphase=0*th2
;
; find vortex centroids, ellipticity
;
        marker_USLM = make_array(nc,nr,nz)
        for k=0,nz-1 do begin
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
        thlevel = reverse(alog(th2) - min(alog(th2),/nan))/(alog(6000.) - min(alog(th2),/nan))  *  254.
;       maxthetalevel = (alog(maxheighttheta[ies,iday])/(alog(5000.)))*254.
;       if maxheighttheta[ies,iday] gt 5000. then begin
;          thlevel = reverse(alog(th2) - min(alog(th2),/nan))/(alog(maxheighttheta[ies,iday]) - min(alog(th2),/nan))*254.
;          maxthetalevel = (alog(maxheighttheta[ies,iday])/(alog(maxheighttheta[ies,iday])))*254.
;       endif
;
; plot
;
        erase
	map_set,90.,-90.,0,/ortho, /grid,/noeras,/noborder,/contin,position = [0.25,0.45,0.75,0.95],color=0,$
                title='MERRA '+sdate+' (Day '+ sday+')'
          
        altarray=fltarr(nz)
	for ii = 0L, nz - 1L do begin
        nz4=(ii+8.)*(1./(nz+16.))
            marker=fltarr(nc+1L,nr2)
            marker[0L:nc-1L,*] = transpose(reform(mark2[nr2:nr-1,*,nz-1L-ii]))
            marker[nc,*] = marker(0,*)
            sf=fltarr(nc+1L,nr2)
            sf[0L:nc-1L,*] = transpose(reform(sf2[nr2:nr-1,*,nz-1L-ii]))
            sf[nc,*] = sf(0,*)
            z=fltarr(nc+1L,nr2)
            z[0L:nc-1L,*] = transpose(reform(z2[nr2:nr-1,*,nz-1L-ii]))
            z[nc,*] = z(0,*)

            contour,marker,lons,alat(nr2:nr-1),levels=[.1],/overplot,color=thlevel[ii],thick=8
            smin=min(sf)
            smax=max(sf)
            slevel=smin+((smax-smin)/39.)*findgen(40)
;           contour,sf,lons,alat(nr2:nr-1),levels=slevel,/overplot,color=0
;
; superimpose center of vortex
;
            index=where(marker gt 0.)
            altarray(nz-1-ii)=mean(z(nr-1,*))
            if index(0) ne -1L then begin
;              index2=where(sf(index) eq min(sf(index)))
;              xavg=mean(xcn(index))
;              yavg=mean(ycn(index))
;              xindex=where(abs(xcn-xavg) eq min(abs(xcn-xavg)))
;              yindex=where(abs(ycn-yavg) eq min(abs(ycn-yavg)))
;              oplot,x2d(index(index2)),y2d(index(index2)),color=thlevel(ii),psym=8,symsize=2
;              xphase(nz-1-ii)=x2d(index(index2(0)))
;              yphase(nz-1-ii)=y2d(index(index2(0)))
;              print,x2d(index(index2)),y2d(index(index2)),th2(nz-1-ii)
               skm=strcompress(long(mean(z(index))),/remove_all)+' km'
               if ii mod 2 eq 0 then xyouts,px1a-0.05,py1a+ii*((py1b-py1a)/nz),skm,color=thlevel(ii),/normal,charsize=1.25,charthick=3
               oplot,[xphase(nz-1-ii),xphase(nz-1-ii)],[yphase(nz-1-ii),yphase(nz-1-ii)],color=thlevel(ii),psym=8,symsize=2
               altarray(nz-1-ii)=mean(z(index))
            endif
	endfor
;oplot, [dailymaxheightlon[iES,iday],dailymaxheightlon[iES,iday]],$
;              [dailymaxheightlat[iES,iday],dailymaxheightlat[iES,iday]], psym = 8, color = 0.95*mcolor, symsize = 2
;       a=findgen(9)*(2*!pi/8.)
;       usersym,1.5*cos(a),1.5*sin(a)
;       oplot, [dailymaxheightlon[iES,iday],dailymaxheightlon[iES,iday]],$
;              [dailymaxheightlat[iES,iday],dailymaxheightlat[iES,iday]], psym = 8, color = 0, symsize = 2
        a=findgen(8)*(2*!pi/8.)
        usersym,1.5*cos(a),1.5*sin(a),/fill

;
theta=th2
index=where(xphase ne 0.,nz)
theta=theta(index)
altarray=altarray(index)
xphase=xphase(index)
yphase=yphase(index)
index1=where(xphase lt 180.)
print,xphase
index=where(xphase gt max(xphase(index1)))
if index(0) ne -1L then xphase(index)=xphase(index)-360.
!type=2^2+2^3
;
; longitude
;
set_viewport,.525,.7,.1,.4
if dailymaxheightlon[iES,iday] gt 90. then dailymaxheightlon[iES,iday]=dailymaxheightlon[iES,iday]-360.
plot,xphase,altarray,color=0,xtitle='Longitude',xrange=[-180.,180.],thick=5,yrange=[20.,80.],xticks=5,/noeras,charsize=1.25
for ii=0L,nz-1L do oplot,[xphase(ii),xphase(ii)],[altarray(ii),altarray(ii)],color=thlevel(nz-1-ii),psym=8
;oplot,xphase,altarray,color=(iday/31.)*mcolor,thick=5
;oplot,[dailymaxheightlon[iES,iday],dailymaxheightlon[iES,iday]],$
;      [78.,78.],psym=8,color=0.95*mcolor,symsize=2
;      [maxheighttheta[iES,iday],maxheighttheta[iES,iday]],psym=8,color=0.95*mcolor,symsize=1.5
;        a=findgen(9)*(2*!pi/8.)
;        usersym,1.5*cos(a),1.5*sin(a)
;        oplot, [dailymaxheightlon[iES,iday],dailymaxheightlon[iES,iday]],$
;               [78.,78.], psym = 8, color = 0, symsize = 2
        a=findgen(8)*(2*!pi/8.)
        usersym,1.5*cos(a),1.5*sin(a),/fill
;
; latitude
;
set_viewport,.3,.475,.1,.4
plot,yphase,altarray,color=0,xtitle='Latitude',xrange=[40.,90.],yrange=[20.,80.],thick=5,/noeras,charsize=1.25,ytitle='Altitude (km)'
for ii=0L,nz-1L do oplot,[yphase(ii),yphase(ii)],[altarray(ii),altarray(ii)],color=thlevel(nz-1-ii),psym=8
;oplot,yphase,altarray,color=(iday/31.)*mcolor,thick=5
;oplot,[dailymaxheightlat[iES,iday],dailymaxheightlat[iES,iday]],$
;      [78.,78.],psym=8,color=0.95*mcolor,symsize=2
;        a=findgen(9)*(2*!pi/8.)
;        usersym,1.5*cos(a),1.5*sin(a)
;        oplot, [dailymaxheightlat[iES,iday],dailymaxheightlat[iES,iday]],$
;               [78.,78.], psym = 8, color = 0, symsize = 2
        a=findgen(8)*(2*!pi/8.)
        usersym,1.5*cos(a),1.5*sin(a),/fill

;     [maxheighttheta[iES,iday],maxheighttheta[iES,iday]],psym=8,color=0.95*mcolor,symsize=1.5
;print,maxheighttheta[iES,iday]

        if setplot ne 'ps' then stop
        if setplot eq 'ps' then begin
           device, /close
           spawn,'convert -trim ../Figures/merra_vortex_phase_ES_event_'+sevent+'_ES_Day_'+sday+'.ps -rotate -90 ../Figures/merra_vortex_phase_ES_event_'+sevent+'_ES_Day_'+sday+'.png'
           spawn,'rm -f ../Figures/merra_vortex_phase_ES_event_'+sevent+'_ES_Day_'+sday+'.ps'
        endif
    
        jumpday:
        icount=icount+1L

endfor		; loop over days 0 to +30
endfor		; loop over ES events
end
