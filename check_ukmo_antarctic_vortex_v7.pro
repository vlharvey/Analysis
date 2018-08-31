;
; Arctic vortex colored by Temperature
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc3
@range_ring

device,decompose=0
loadct,38
mcolor=!p.color
icolmax=byte(!p.color)
icolmax=fix(icolmax)
a=findgen(8)*(2*!pi/8.)
usersym,2*cos(a),2*sin(a),/fill
nxdim=800
nydim=800
cbaryoff=0.05
cbarydel=0.02
!noeras=1
set_plot,'x'
setplot='x'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
lstmn=3 & lstdy=1 & lstyr=92 & lstday=0
ledmn=12 & leddy=31 & ledyr=5 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
;print, ' '
;print, '      UKMO Version '
;print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
;
; --- Loop here --------
;
icount=0
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; test for end condition and close windows.
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' normal termination condition'
;
; read UKMO data
;
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr
      date=sdy+' '+month(imn-1)+' '+syr
      print,ifile
    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
    x=fltarr(nc+1)
    x(0:nc-1)=alon(0:nc-1)
    x(nc)=alon(0)+360.

; select 3 theta levels to plot
    if icount eq 0 then begin
       index=where(th ge 240. and th le 2000.,nth2)
       thlevs=reverse(strcompress(string(fix(th(index))))+' K')
       thlw=th(nth2-1)
       thup=th(0)
       x2d=fltarr(nc+1,nr/2)
       y2d=fltarr(nc+1,nr/2)
       for i=0,nc do y2d(i,*)=alat(0:nr/2-1)
       for j=0,nr/2-1 do x2d(*,j)=x
       dy=alat(1)-alat(0)
       icount=1
    endif

; save postscript version
if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename=ifile+'.ps'
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
    imin=180.
    imax=300.
    nlev=long((imax-imin)/10.)+1L
    plots,.48,.226,/normal
    plots,.48,.78,/continue,/normal,thick=3
    set_viewport,.1,.9,.1,.9
    !type=2^6+2^5     ; suppress x and y axes
    dum=fltarr(nc+1,nr2)
    irot=-15.
    surface,dum,xcs,ycs,xrange=[-1.0,1.0],yrange=[-1.0,1.0],/noeras,$
            zrange=[thlw,thup],/save,/nodata,zstyle=4,charsize=3.0,az=irot
    for kk=0,nth2-1 do begin
        lev=nth2-1-kk
        nz=kk*(1./(nth2-1.))
        nz2=(kk+1.)*(1./(nth2+1.))
        nz3=(kk+4.)*(1./(nth2+8.))
        nz4=(kk+8.)*(1./(nth2+16.))
        mark1=transpose(mark2(*,*,lev))
        sf1=transpose(sf2(*,*,lev))
        pv1=transpose(pv2(*,*,lev))
        p1=transpose(p2(*,*,lev))
        msf=transpose(msf2(*,*,lev))
        mpv1=pv1*((th(lev)/300.))^(-9./2.)

; temperature
        temp1=th(lev)*(p1/1000.)^.286
        temp=fltarr(nc+1,nr2)
        temp(0:nc-1,0:nr2-1)=temp1(0:nc-1,0:nr2-1)    ; NH
        temp(nc,*)=temp(0,*)
        index=where(y2d gt -30. or temp eq 0.)
        temp(index)=1.e15

; height of theta surface
        zth=(msf-1004.*temp1)/(9.86*1000.)
	result=moment(zth(*,0:nr2-1))
	avgz=result(0)
        savgz=strcompress(string(fix(avgz)),/remove_all)

; superimpose stream function
        dum(0:nc-1,0:nr2-1)=sf1(0:nc-1,0:nr2-1)    ; NH
        dum(nc,*)=dum(0,*)
        if kk eq 0 then begin
           !psym=0
           smin=min(dum)
           smax=max(dum)
           sint=(smax-smin)/15.
           sflevel=smin+sint*findgen(15)
           contour,dum,xcs,ycs,levels=sflevel,color=lc,c_labels=0+0.*sflevel,$
                   /T3D,zvalue=nz
        endif

; draw latitude circles
        if kk eq 0 then begin
        !psym=0
        lon=findgen(361)
        lonp=0.*lon
        latp=0.*lon
        for k=0,2 do begin
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
            oplot,lonp,latp,/T3D,zvalue=nz,color=lc
        endfor
        MAP_SET,-90,0,-1.*irot,/stereo,/contin,/grid,/noborder,/noeras,londel=90.,$
            label=1,lonlab=1,charsize=2,latdel=180.,/t3d,zvalue=nz
        endif

        dum=fltarr(nc+1,nr2)
        dum(0:nc-1,0:nr2-1)=mark1(0:nc-1,0:nr2-1)    ; NH
        dum(nc,*)=dum(0,*)
;
; sub-vortex modification
;
;       if th(lev) le 500. then begin
;          mpv=fltarr(nc+1,nr2)
;          mpv(0:nc-1,0:nr2-1)=mpv1(0:nc-1,0:nr2-1)
;          mpv(nc,*)=mpv(0,*)
;          lindex=where(dum gt 0.0,nl)
;          if lindex(0) eq -1 then begin
;             index=where(mpv le -0.0004 and y2d le -45.)
;             if index(0) ne -1 then dum(index)=1.
;          endif
;          if lindex(0) ne -1 then begin
;             if max(y2d(lindex)) ge -55. then begin
;                index=where(mpv le -0.0004 and y2d le -45.)
;                if index(0) ne -1 then dum(index)=1.
;                index=where(mpv gt -0.0004)
;                if index(0) ne -1 then dum(index)=0.
;             endif
;          endif
;       endif

        lindex=where(dum gt 0.0,nl)
        if lindex(0) ne -1 then begin
           for ii=0,nl-1 do begin
               if temp(lindex(ii)) ne 1.e15 then $
               oplot,[xcs(lindex(ii)),xcs(lindex(ii))],$
                     [ycs(lindex(ii)),ycs(lindex(ii))],$
                     /T3D,zvalue=nz,psym=8,symsize=2,$
                     color=1.+((temp(lindex(ii))-imin)/(imax-imin))*icolmax
              if temp(lindex(ii)) eq 1.e15 then $
               oplot,[xcs(lindex(ii)),xcs(lindex(ii))],$
                     [ycs(lindex(ii)),ycs(lindex(ii))],$
                     /T3D,zvalue=nz,psym=8,symsize=0.5,color=0
           endfor
           contour,temp,xcs,ycs,levels=[180.,185.,190.,195.],color=mcolor,$
                   /T3D,zvalue=nz,thick=1,max_value=1.e15
           contour,dum,xcs,ycs,levels=[0.1],color=0,$
                   c_labels=0,/T3D,zvalue=nz,thick=3,max_value=1.e15
        endif
        jumplev:
        xyouts,.83,nz4,savgz+' km',color=lc,/normal,charsize=2
        xyouts,.08,nz4,thlevs(kk),color=lc,/normal,charsize=2
    endfor	; loop over stacked polar plots
    !psym=0
    xyouts,0.33,0.88,date,/normal,charsize=3.0
    xyouts,.08,.83,'Theta (K)',charsize=2,/normal
    xyouts,.76,.83,'Altitude (km)',charsize=2,/normal
    set_viewport,.2,.78,.14-cbaryoff,.14-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    col1=1.+(findgen(nlev)/nlev)*icolmax
    level=imin+10.*findgen(nlev)
    plot,[imin,imax],[0,0],yrange=[0,nlev],$
          xrange=[imin,imax],xtitle='Temperature',/noeras,$
          xtickname=strcompress(string(fix(level)),/remove_all),$
          xstyle=1,xticks=nlev-1,charsize=1.5
    ybox=[0,nlev,nlev,0,0]
    x1=imin
    dx=(imax-imin)/float(nlev)
    for j=0,nlev-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
    endfor
    !p.charthick=1.
;   if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert '+ifile+'.ps -rotate -90 '+ifile+'.jpg'
    endif
;stop
goto, jump
end
