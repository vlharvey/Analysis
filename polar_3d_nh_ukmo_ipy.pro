;
; IPY version has 4 lidar sites superimposed
;
; Arctic vortex colored by Temperature
; Anticyclones in black poleward of 13.75N
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc3

loadct,39
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,2*cos(a),2*sin(a),/fill
nxdim=800
nydim=800
cbaryoff=0.065
cbarydel=0.02
set_plot,'ps'
setplot='ps'
;read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
lstmn=1
lstdy=25
lstyr=2009
ledmn=1
leddy=25
ledyr=2009
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
!noeras=1
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      syr=strtrim(string(iyr),2)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr

      rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
      if strmid(ifile,7,1) eq '9' then $
         date=strmid(ifile,4,2)+' '+month(imn-1)+' 19'+strmid(ifile,7,2)
      if strmid(ifile,7,1) ne '9' then $
         date=strmid(ifile,4,2)+' '+month(imn-1)+' 20'+strmid(ifile,7,2)

      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.

; select theta levels to plot
      index=where(th ge 300. and th le 2000.,nth2)
      thlevs=reverse(strcompress(string(fix(th(index))))+' K')
      thlw=th(nth2-1)
      thup=th(0)
      x2d=fltarr(nc+1,nr/2)
      y2d=fltarr(nc+1,nr/2)
      for i=0,nc do y2d(i,*)=alat(nr/2:nr-1)
      for j=0,nr/2-1 do x2d(*,j)=x
      dy=alat(1)-alat(0)

; save postscript version
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !psym=0
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,filename='IPY/'+sdate+'_3D.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.thick=2.0                   ;Plotted lines twice as thick
         !p.charsize=2.0
      endif

; coordinate transformation
    nr2=nr/2
    xcn=fltarr(nc+1,nr2)
    ycn=fltarr(nc+1,nr2)
    for j=nr2,nr-1 do begin
        ANG = (90. - alat(j)) * RADG * 0.5
        FACTOR = TAN(ANG) * FAC20
        for i=0,nc do begin
            THETA = (x(i) - 90.) * RADG
            xcn(i,j-nr2) = FACTOR * COS(THETA)
            ycn(i,j-nr2) = FACTOR * SIN(THETA)
        endfor
    endfor
    xcs=fltarr(nc+1,nr2)
    ycs=fltarr(nc+1,nr2)
    for j=0,nr2-1 do begin
        ANG = (90. + alat(j)) * RADG * 0.5
        FACTOR = TAN(ANG) * FAC20
        for i=0,nc do begin
            THETA = (x(i) - 90.) * RADG
            xcs(i,j) = FACTOR * COS(THETA)
            ycs(i,j) = -1.0 * FACTOR * SIN(THETA)
        endfor
    endfor

    erase
    !psym=0
    plots,.48,.226,/normal
    plots,.48,.78,/continue,/normal,thick=3
    set_viewport,.1,.9,.1,.9
    !type=2^6+2^5     ; suppress x and y axes
    dum=fltarr(nc+1,nr2)
    irot=-110.
    surface,dum,xcn,ycn,xrange=[-1.0,1.0],yrange=[-1.0,1.0],/noeras,$
            zrange=[thlw,thup],/save,/nodata,zstyle=4,charsize=3.0,az=irot
    col1=fltarr(nth2)
    nz=fltarr(nth2)
;   for kk=0,nth2-1 do nz(kk)=(th(nth2-1-kk)-thlw)/(thup-thlw)
    for kk=0,nth2-1 do nz(kk)=kk*(1./(nth2-1.)) ; equally spaced in the vertical stretches subvortex
    for kk=0,nth2-1 do begin
        km1=kk-1 & kp1=kk+1
        if kk eq 0 then km1=0
        if kk eq nth2-1 then kp1=nth2-1
        lev=nth2-1-kk
        nz2=(kk+1.)*(1./(nth2+1.))
        nz3=(kk+4.)*(1./(nth2+8.))
        nz4=(kk+8.)*(1./(nth2+16.))
        mark1=transpose(mark2(*,*,lev))
        sf1=transpose(sf2(*,*,lev))
        pv1=transpose(pv2(*,*,lev))
        p1=transpose(p2(*,*,lev))
        msf1=transpose(msf2(*,*,lev))
        mpv1=pv1*((th(lev)/300.))^(-9./2.)

; temperature
        temp1=th(lev)*(p1/1000.)^.286
        temp=fltarr(nc+1,nr2)
        temp(0:nc-1,0:nr2-1)=temp1(0:nc-1,nr2:nr-1)    ; NH
        temp(nc,*)=temp(0,*)
        index=where(y2d lt 25. or temp eq 0.)
        temp(index)=1.e15

; height of theta surface
        zth=(msf1-1004.*temp1)/(9.86*1000.)
	result=moment(zth(*,nr2:nr-1))
	avgz=result(0)
        savgz=strcompress(string(fix(avgz)),/remove_all)

; draw latitude circles
        if kk eq 0 then begin
        !psym=0
        lon=findgen(361)
        lonp=0.*lon
        latp=0.*lon
;oplot,xcn,ycn,psym=8,symsize=2.25,color=mcolor*.3,/T3D,zvalue=nz(kk)	; blue ocean is too much color
        for k=0,0 do begin
            if k eq 0 then lat=0.*fltarr(361)
            if k eq 1 then lat=30.+0.*fltarr(361)
            if k eq 2 then lat=60.+0.*fltarr(361)
            for j=0,360 do begin
                ANG = (90. - lat(j)) * RADG * 0.5
                FACTOR = TAN(ANG) * FAC20
                THETA = (lon(j) - 90.) * RADG
                lonp(j) = FACTOR * COS(THETA)
                latp(j) = FACTOR * SIN(THETA)
            endfor
            oplot,lonp,latp,/T3D,zvalue=nz(kk),color=0,thick=2
        endfor
        MAP_SET,90,0,250.-1.*irot,/stereo,/contin,/grid,/noborder,/noeras,londel=90.,$
            label=1,lonlab=1,charsize=3,latdel=180.,/t3d,zvalue=nz(kk),color=0
;
; fill continents grey
;
        loadct,0
        map_continents,mlinethick=2,/t3d,zvalue=nz(kk),color=mcolor*.5,/fill_continents,/coasts,/countries
        map_continents,/t3d,zvalue=nz(kk),color=0,/countries,/usa,/coasts
;
; superimpose stream function
;
        dum(0:nc-1,0:nr2-1)=sf1(0:nc-1,nr2:nr-1)    ; NH
        dum(nc,*)=dum(0,*)
        smin=min(dum)
        smax=max(dum)
        sint=(smax-smin)/10.
        sflevel=smin+sint*findgen(10)
        contour,dum,xcn,ycn,levels=sflevel,color=0,c_labels=0+0.*sflevel,$
                /T3D,zvalue=nz(kk),thick=2
        loadct,39
        endif
 
        nz2=(kk+1.)*(1./(nth2+1.))
        col1(kk)=nz2*icolmax
        dum=fltarr(nc+1,nr2)
        dum(0:nc-1,0:nr2-1)=mark1(0:nc-1,nr2:nr-1)    ; NH
        dum(nc,*)=dum(0,*)
;
; sub-vortex modification
;
        if th(lev) le 0. then begin
           lindex=where(dum gt 0.0,nl)
           mpv=fltarr(nc+1,nr2)
           mpv(0:nc-1,0:nr2-1)=mpv1(0:nc-1,nr2:nr-1)
           mpv(nc,*)=mpv(0,*)
           if lindex(0) eq -1 then begin
              index=where(mpv ge 0.0004 and y2d ge 55.)
              if index(0) ne -1 then dum(index)=1.
           endif
           if lindex(0) ne -1 then begin
              if min(y2d(lindex)) le 55. then begin
                 index=where(mpv ge 0.0004 and y2d ge 55.)
                 if index(0) ne -1 then dum(index)=1.
                 index=where(mpv lt 0.0004)
                 if index(0) ne -1 then dum(index)=0.
              endif
           endif
        endif

        lindex=where(dum gt 0.0,nl)
        imin=180.
        imax=280.
	if lindex(0) ne -1 then begin
           for ii=0,nl-1 do begin
               if temp(lindex(ii)) ne 1.e15 then $
               oplot,[xcn(lindex(ii)),xcn(lindex(ii))],$
                     [ycn(lindex(ii)),ycn(lindex(ii))],$
                     /T3D,zvalue=nz(kk),psym=8,symsize=2,$
                     color=((temp(lindex(ii))-imin)/(imax-imin))*icolmax
               if temp(lindex(ii)) gt imax then $
               oplot,[xcn(lindex(ii)),xcn(lindex(ii))],$
                     [ycn(lindex(ii)),ycn(lindex(ii))],$
                     /T3D,zvalue=nz(kk),psym=8,symsize=0.5,color=mcolor*.95
           endfor
           contour,temp,xcn,ycn,levels=[180.,185.,190.,195.],color=mcolor,$
                   /T3D,zvalue=nz(kk),thick=1,max_value=1.e15
           contour,dum,xcn,ycn,levels=[0.1],color=0,$
                   c_labels=0,/T3D,zvalue=nz(kk),thick=3,max_value=1.e15
        endif
;
; anticyclones
;
        lindex=where(dum lt 0.0,nl)
        if lindex(0) ne -1 then begin
;          oplot,xcn(lindex),ycn(lindex),/T3D,zvalue=nz(kk),psym=8,symsize=2,color=0
loadct,0
;          contour,dum,xcn,ycn,levels=[-0.1],color=mcolor*.3,$
;                  c_labels=0,/T3D,zvalue=nz(kk),thick=3
           nhigh=abs(min(dum(lindex)))
sdum=0.*dum
        sdum(0:nc-1,0:nr2-1)=sf1(0:nc-1,nr2:nr-1)    ; NH
        sdum(nc,*)=sdum(0,*)
dx=x2d(1,0)-x2d(0,0)
           for ihigh=0,nhigh-1 do begin
               index=where(dum eq -1.0*(ihigh+1))
               if min(y2d(index)) le 13.7500 then goto,jump1
               sedge=min(sdum(index))     ; value of SF to contour
               tmp=sdum
               xmax=max(x2d(index))+1.0*dx      ; isolate region
               xmin=min(x2d(index))-1.0*dx
               ymax=max(y2d(index))+2.0*dy
               ymin=min(y2d(index))-2.0*dy
               if xmin lt x(0) and xmax gt x(nc) then begin     ; GM
                  index=where(x2d gt 180. and dum eq -1.0*(ihigh+1))
                  xmax2=min(x2d(index))-2.0*dx
                  index=where(x2d lt 180. and dum eq -1.0*(ihigh+1))
                  xmin2=max(x2d(index))+2.0*dx
                  index=where((x2d lt xmax2 and x2d gt xmin2) or (y2d lt ymin or y2d gt ymax))
               endif
               if xmin gt x(0) or xmax lt x(nc) then $
                  index=where(x2d lt xmin or x2d gt xmax or y2d lt ymin or y2d gt ymax)
               if index(0) ne -1 then tmp(index)=-9999.
               index=where(tmp ne -9999. and y2d gt 13.7500 and dum eq -1.0*(ihigh+1))
               oplot,xcn(index),ycn(index),psym=8,color=0,/T3D,zvalue=nz(kk),symsize=2
               contour,tmp,xcn,ycn,levels=[sedge],color=icolmax*.7,$
                 /T3D,zvalue=nz(kk),c_linestyle=0,/overplot,min_value=-9999.,thick=3
               jump1:
           endfor               ; loop over anticyclones

loadct,39
        endif
loadct,0
;
; superimpose profile at ALOMAR lidar site (69N, 16E)
;
yy=69.3 & xx=16.
               ANG = (90. - yy) * RADG * 0.5
               FACTOR = TAN(ANG) * FAC20
               THETA0 = (xx - 90.) * RADG
               xn = FACTOR * COS(THETA0)
               yn = FACTOR * SIN(THETA0)
               a=findgen(8)*(2*!pi/8.)
               usersym,2*cos(a),2*sin(a),/fill
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=120
               dist=nz(kp1)-nz(kk)
               if dist gt 0. then begin
               for m=0,10 do $
                   oplot,[xn,xn],[yn,yn],zvalue=nz(kk)+float(m)*dist/11.,/T3D,psym=8,color=120
               endif
;
; superimpose profile at EUREKA lidar site (80N, 86W)
;
loadct,39
yy=80. & xx=274.
               ANG = (90. - yy) * RADG * 0.5
               FACTOR = TAN(ANG) * FAC20
               THETA0 = (xx - 90.) * RADG
               xn = FACTOR * COS(THETA0)
               yn = FACTOR * SIN(THETA0)
               a=findgen(8)*(2*!pi/8.)
               usersym,2*cos(a),2*sin(a),/fill
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=mcolor*.3
               dist=nz(kp1)-nz(kk)
               if dist gt 0. then begin
               for m=0,10 do $
                   oplot,[xn,xn],[yn,yn],zvalue=nz(kk)+float(m)*dist/11.,/T3D,psym=8,color=mcolor*.3
               endif
;
; superimpose profile at SONDRESTORM lidar site (67N, 52W)
;
yy=67. & xx=308.
               ANG = (90. - yy) * RADG * 0.5
               FACTOR = TAN(ANG) * FAC20
               THETA0 = (xx - 90.) * RADG
               xn = FACTOR * COS(THETA0)
               yn = FACTOR * SIN(THETA0)
               a=findgen(8)*(2*!pi/8.)
               usersym,2*cos(a),2*sin(a),/fill
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=mcolor*.1
               dist=nz(kp1)-nz(kk)
               if dist gt 0. then begin
               for m=0,10 do $
                   oplot,[xn,xn],[yn,yn],zvalue=nz(kk)+float(m)*dist/11.,/T3D,psym=8,color=mcolor*.1
               endif
;
; superimpose profile at POKER FLAT lidar site (65N, 147W)
;
yy=65. & xx=213.
               ANG = (90. - yy) * RADG * 0.5
               FACTOR = TAN(ANG) * FAC20
               THETA0 = (xx - 90.) * RADG
               xn = FACTOR * COS(THETA0)
               yn = FACTOR * SIN(THETA0)
               a=findgen(8)*(2*!pi/8.)
               usersym,2*cos(a),2*sin(a),/fill
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=mcolor*.95
               dist=nz(kp1)-nz(kk)
               if dist gt 0. then begin
               for m=0,10 do $
                   oplot,[xn,xn],[yn,yn],zvalue=nz(kk)+float(m)*dist/11.,/T3D,psym=8,color=mcolor*.95
               endif
;
; superimpose profile at IAP lidar site (54N, 12E)
;
yy=54.1 & xx=11.8
               ANG = (90. - yy) * RADG * 0.5
               FACTOR = TAN(ANG) * FAC20
               THETA0 = (xx - 90.) * RADG
               xn = FACTOR * COS(THETA0)
               yn = FACTOR * SIN(THETA0)
               a=findgen(8)*(2*!pi/8.)
               usersym,2*cos(a),2*sin(a),/fill
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=mcolor*.95
               dist=nz(kp1)-nz(kk)
               if dist gt 0. then begin
               for m=0,10 do $
                   oplot,[xn,xn],[yn,yn],zvalue=nz(kk)+float(m)*dist/11.,/T3D,psym=8,color=mcolor*.35
               endif


        xyouts,.83,nz4,savgz+' km',color=0,/normal,charsize=2,charthick=2
        xyouts,.08,nz4,thlevs(kk),color=0,/normal,charsize=2,charthick=2
    endfor	; loop over stacked polar plots
    !psym=0
    xyouts,0.33,0.85,date,/normal,charsize=3.0,color=0,charthick=2
    xyouts,.08,.78,'Theta (K)',charsize=2,/normal,color=0,charthick=2
    xyouts,.76,.78,'Altitude (km)',charsize=2,/normal,color=0,charthick=2
loadct,0
    xyouts,.8,.13,'Alomar (69N,16E)',charsize=1.5,/normal,color=120,charthick=2
loadct,39
    xyouts,.8,.11,'Eureka (80N,86W)',charsize=1.5,/normal,color=mcolor*.3,charthick=2
    xyouts,.74,.09,'Sondrestrom (67N,51W)',charsize=1.5,/normal,color=mcolor*.1,charthick=2
    xyouts,.75,.07,'Poker Flat (65N,147W)',charsize=1.5,/normal,color=mcolor*.95,charthick=2
    xyouts,.83,.05,'IAP (54N,12E)',charsize=1.5,/normal,color=mcolor*.35,charthick=2
    set_viewport,.25,.73,.12-cbaryoff,.12-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    iint=(imax-imin)/10.
    level=imin+iint*findgen(10)
    plot,[imin,imax],[0,0],yrange=[0,10],$
          xrange=[imin,imax],xtitle='Temperature',/noeras,$
          xtickname=strcompress(string(fix(level)),/remove_all),$
          xstyle=1,xticks=9,charsize=1.25,color=0,charthick=2
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nth2)
    for j=0,nth2-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
    endfor
    !p.charthick=1.
    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim IPY/'+sdate+'_3D.ps -rotate -90 IPY/'+sdate+'_3D.png'
       spawn,'/usr/bin/rm -f IPY/'+sdate+'_3D.ps'
    endif
goto, jump
end
