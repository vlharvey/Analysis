;
; Arctic vortex colored by Temperature
; superimpose occultation locations
;
@rd_ukmo_nc3
@rd_haloe_o3_soundings_julian
@rd_sage2_o3_soundings_julian
@rd_sage3_o3_soundings_julian
@rd_poam3_o3_soundings_julian
@rd_dc8_merge
@interp_sound
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
set_plot,'x'
setplot='x'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
ifiles=[$
;'ukmo_nh_files_91-92.fil',$
;'ukmo_nh_files_92-93.fil',$
;'ukmo_nh_files_93-94.fil',$
;'ukmo_nh_files_94-95.fil',$
;'ukmo_nh_files_95-96.fil',$
;'ukmo_nh_files_96-97.fil',$
;'ukmo_nh_files_97-98.fil',$
;'ukmo_nh_files_98-99.fil',$
;'ukmo_nh_files_99-00.fil',$
;'ukmo_nh_files_00-01.fil',$
;'ukmo_nh_files_01-02.fil',$
;'ukmo_nh_files_02-03.fil',$
;'ukmo_nh_files_03-04.fil',$
'ukmo_nh_files_04-05.fil']
odirs=[$
;'1991-1992/',$
;'1992-1993/',$
;'1993-1994/',$
;'1994-1995/',$
;'1995-1996/',$
;'1996-1997/',$
;'1997-1998/',$
;'1998-1999/',$
;'1999-2000/',$
;'2000-2001/',$
;'2001-2002/',$
;'2002-2003/',$
;'2003-2004/',$
'2004-2005/']
nyear=n_elements(odirs)
!noeras=1
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
dirh='/aura3/data/HALOE_data/Sound_data/haloe_'
dirs='/aura3/data/SAGE_II_data/Sound_data/sage2_'
dirs3='/aura3/data/SAGE_III_data/Sound_data/sage3_solar_'
dirp='/aura3/data/POAM_data/Sound_data/poam3v4_'
ifile='                             '
for iyear=0,nyear-1 do begin
close,1
openr,1,ifiles(iyear)
nfile=0L
readf,1,nfile
for l=0,nfile-1 do begin
    readf,1,ifile
    print,ifile
;
; this logic works for years 1990-2089
; note: ifile1 is an array
;
    mindex=where(strmid(ifile,0,3) eq mon)
    if strmid(ifile,7,1) eq '9' then begin
       date=strmid(ifile,4,2)+' '+month(mindex(0))+' 19'+strmid(ifile,7,2)
       ifile1=[strmid(ifile,0,7)+'19'+strmid(ifile,7,2)+'_o3.sound']
    endif
    if strmid(ifile,7,1) ne '9' then begin
       date=strmid(ifile,4,2)+' '+month(mindex(0))+' 20'+strmid(ifile,7,2)
       ifile1=[strmid(ifile,0,7)+'20'+strmid(ifile,7,2)+'_o3.sound']
    endif
    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
    x=fltarr(nc+1)
    x(0:nc-1)=alon(0:nc-1)
    x(nc)=alon(0)+360.
;
; read HALOE
;
    numh=0L & nums=0L & nums3=0L & nump=0L
    nday=1L
    norbit=30L
    nl=300L
    xhal=9999+fltarr(nday*norbit,nl)
    yhal=9999+fltarr(nday*norbit,nl)
    thal=9999+fltarr(nday*norbit,nl)
    thhal=9999+fltarr(nday*norbit,nl)
    o3hal=9999+fltarr(nday*norbit,nl)
    rd_haloe_o3_soundings_julian,nday,iorbit,$
       ifile1,dirh,thal,xhal,yhal,thhal,o3hal
    if iorbit gt 0 then begin
;      index=where(thhal le 2000. and o3hal le 1. and o3hal gt 0.)
       hindex=where(thal(*,0) ne 9999. and yhal(*,0) gt 45.,numh)
       if numh gt 0L then begin
       thal=reform(thal(hindex,0))
       xhal=reform(xhal(hindex,0))
       yhal=reform(yhal(hindex,0))
       thhal=reform(thhal(hindex,*))
       o3hal=reform(o3hal(hindex,*))
       endif
    endif
;
; read SAGE II
;
    xsage=9999+fltarr(nday*norbit,nl)
    ysage=9999+fltarr(nday*norbit,nl)
    tsage=9999+fltarr(nday*norbit,nl)
    thsage=9999+fltarr(nday*norbit,nl)
    o3sage=9999+fltarr(nday*norbit,nl)
    rd_sage2_o3_soundings_julian,nday,iorbit,$
       ifile1,dirs,tsage,xsage,ysage,thsage,o3sage
    if iorbit gt 0L then begin
;      index=where(thsage gt 2000. or o3sage gt 2000. or o3sage lt 0.)
       sindex=where(tsage(*,0) ne 9999. and ysage(*,0) gt 45.,nums)
       if nums gt 0L then begin
       tsage=reform(tsage(sindex,0))
       xsage=reform(xsage(sindex,0))
       ysage=reform(ysage(sindex,0))
       thsage=reform(thsage(sindex,*))
       o3sage=reform(o3sage(sindex,*))
       endif
    endif
;
; read SAGE III
;
    xsage3=9999+fltarr(nday*norbit,nl)
    ysage3=9999+fltarr(nday*norbit,nl)
    tsage3=9999+fltarr(nday*norbit,nl)
    thsage3=9999+fltarr(nday*norbit,nl)
    o3sage3=9999+fltarr(nday*norbit,nl)
    rd_sage3_o3_soundings_julian,nday,iorbit,$
       ifile1,dirs3,tsage3,xsage3,ysage3,thsage3,o3sage3
    if iorbit gt 0L then begin
;      index=where(thsage3 gt 2000. or o3sage3 gt 2000. or o3sage3 lt 0.)
       sindex3=where(tsage3(*,0) ne 9999. and ysage3(*,0) gt 0.,nums3)
       if nums3 gt 0L then begin
       tsage3=reform(tsage3(sindex3,0))
       xsage3=reform(xsage3(sindex3,0))
       ysage3=reform(ysage3(sindex3,0))
       thsage3=reform(thsage3(sindex3,*))
       o3sage3=reform(o3sage3(sindex3,*))
       endif
    endif
;
; read POAM III
;
    xpoam=9999+fltarr(nday*norbit,nl)
    ypoam=9999+fltarr(nday*norbit,nl)
    tpoam=9999+fltarr(nday*norbit,nl)
    thpoam=9999+fltarr(nday*norbit,nl)
    o3poam=9999+fltarr(nday*norbit,nl)
    rd_poam3_o3_soundings_julian,nday,iorbit,$
       ifile1,dirp,tpoam,xpoam,ypoam,thpoam,o3poam
    if iorbit gt 0L then begin
;      index=where(thpoam gt 2000. or o3poam gt 2000. or o3poam lt 0.)
       pindex=where(tpoam(*,0) ne 9999. and ypoam(*,0) gt 0.,nump)
       if nump gt 0L then begin
       tpoam=reform(tpoam(pindex,0))
       xpoam=reform(xpoam(pindex,0))
       ypoam=reform(ypoam(pindex,0))
       thpoam=reform(thpoam(pindex,*))
       o3poam=reform(o3poam(pindex,*))
       endif
    endif
print,numh,nums,nums3,nump

; theta levels to plot
    if l eq 0 then begin
       index=where(th ge 350. and th le 2000.,nth2)
       thlevs=reverse(strcompress(string(fix(th(index)))))
       thlw=th(nth2-1)
       thup=th(0)
       x2d=fltarr(nc+1,nr/2)
       y2d=fltarr(nc+1,nr/2)
       for i=0,nc do y2d(i,*)=alat(nr/2:nr-1)
       for j=0,nr/2-1 do x2d(*,j)=x
       dy=alat(1)-alat(0)
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
       device,/landscape,bits=8,filename='Postscript/'+ifile+'+occul.ps'
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
    erase
    !psym=0
    set_viewport,.195,.765,.1,.35
    MAP_SET,90,0,135,/stereo,/contin,/grid,/noborder,/noeras,londel=90.,$
            label=1,lonlab=1,charsize=2,latdel=180.
    plots,.48,.226,/normal
    plots,.48,.78,/continue,/normal,thick=3
    set_viewport,.12,.92,.09,.92
    !type=2^6+2^5     ; suppress x and y axes
    dum=fltarr(nc+1,nr2)
    surface,dum,xcn,ycn,xrange=[-1.0,1.0],yrange=[-1.0,1.0],/noeras,$
            zrange=[thlw,thup],/save,/nodata,zstyle=4,charsize=3.0,az=-135
    nz=fltarr(nth2)
    for kk=0,nth2-1 do nz(kk)=(th(nth2-1-kk)-thlw)/(thup-thlw)
    for kk=0,nth2-1 do begin
        km1=kk-1 & kp1=kk+1
        if kk eq 0 then km1=0
        if kk eq nth2-1 then kp1=nth2-1
        lev=nth2-1-kk
;       nz=kk*(1./(nth2-1.))		; equally spaced in the vertical stretches subvortex
        nz2=(kk+1.)*(1./(nth2+1.))
        nz3=(kk+4.)*(1./(nth2+8.))
        sflmark1=transpose(marksf2(*,*,lev))
        sfhmark1=transpose(marksf2(*,*,lev))
        sf1=transpose(sf2(*,*,lev))
        pv1=transpose(pv2(*,*,lev))
        prs1=transpose(p2(*,*,lev))
        msf1=transpose(msf2(*,*,lev))
        mpv1=pv1*((th(lev)/300.))^(-9./2.)
        mpv=fltarr(nc+1,nr2)
        mpv(0:nc-1,0:nr2-1)=mpv1(0:nc-1,nr2:nr-1)    ; NH
        mpv(nc,*)=mpv(0,*)

; temperature
        temp1=th(lev)*(prs1/1000.)^.286
        temp=fltarr(nc+1,nr2)
        temp(0:nc-1,0:nr2-1)=temp1(0:nc-1,nr2:nr-1)    ; NH
        temp(nc,*)=temp(0,*)
        index=where(y2d lt 30. or temp eq 0.)
        temp(index)=1.e15

; height of theta surface
        zth1=(msf1-1004.*temp1)/(9.86*1000.)
	result=moment(zth1(*,nr2:nr-1))
	avgz=result(0)
        savgz=strcompress(string(fix(avgz)),/remove_all)
        ymin=.2+(.775-.2)*nz(kk)
        if kk ne 1 and kk ne 2 and kk ne 3 and kk ne 4 and kk ne 6 and $
           kk ne 8 and kk ne 10 then begin
           xyouts,.1,ymin,thlevs(kk),charsize=2,/normal
           xyouts,.8,ymin,savgz,charsize=2,/normal
        endif
        xyouts,.18,ymin,'-',charsize=2,/normal
        xyouts,.77,ymin,'-',charsize=2,/normal

; superimpose stream function
        dum(0:nc-1,0:nr2-1)=sf1(0:nc-1,nr2:nr-1)    ; NH
        dum(nc,*)=dum(0,*)
        if kk eq 0 then begin
           !psym=0
           smin=min(dum)
           smax=max(dum)
           sint=(smax-smin)/15.
           sflevel=smin+sint*findgen(15)
           contour,dum,xcn,ycn,levels=sflevel,color=lc,c_labels=0+0.*sflevel,$
                   /T3D,zvalue=nz(kk),thick=1
        !psym=0
        lon=findgen(361)
        lonp=0.*lon
        latp=0.*lon
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
            oplot,lonp,latp,/T3D,zvalue=nz(kk),color=lc
        endfor
        endif
 
        nz2=(kk+1.)*(1./(nth2+1.))
        dum=fltarr(nc+1,nr2)
        dum(0:nc-1,0:nr2-1)=sflmark1(0:nc-1,nr2:nr-1)    ; NH
        dum(nc,*)=dum(0,*)
;
; sub-vortex modification
;
        if th(lev) le 500. then begin
        lindex=where(dum gt 0.0,nl)
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
           a=findgen(8)*(2*!pi/8.)
           usersym,2*cos(a),2*sin(a),/fill
           for ii=0,nl-1 do begin
               if temp(lindex(ii)) ne 1.e15 then $
               oplot,[xcn(lindex(ii)),xcn(lindex(ii))],$
                     [ycn(lindex(ii)),ycn(lindex(ii))],$
                     /T3D,zvalue=nz(kk),psym=8,symsize=2,$
                     color=((temp(lindex(ii))-imin)/(imax-imin))*icolmax
               if temp(lindex(ii)) eq 1.e15 then $
               oplot,[xcn(lindex(ii)),xcn(lindex(ii))],$
                     [ycn(lindex(ii)),ycn(lindex(ii))],$
                     /T3D,zvalue=nz(kk),psym=8,symsize=0.5,color=0
           endfor
           contour,temp,xcn,ycn,levels=[180.,185.,190.,195.],color=0,$
                   zvalue=nz(kk),thick=2,max_value=1.e15,/t3d
           contour,dum,xcn,ycn,levels=[0.1],color=0,/t3d,$
                   c_labels=0,zvalue=nz(kk),thick=3,max_value=1.e15
        endif

        if numh gt 0L then begin
           xn=0.*xhal
           yn=0.*yhal
           for i=0L,numh-1L do begin
               ANG = (90. - yhal(i)) * RADG * 0.5
               FACTOR = TAN(ANG) * FAC20
               THETA = (xhal(i) - 90.) * RADG
               xn = FACTOR * COS(THETA)
               yn = FACTOR * SIN(THETA)
               a=findgen(8)*(2*!pi/8.)
               usersym,2*cos(a),2*sin(a),/fill
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=lc
               a=findgen(10)*(2*!pi/10.)
               usersym,2*cos(a),2*sin(a)
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=lc
               dist=nz(kp1)-nz(kk)
               if dist gt 0. then begin
               for m=0,10 do $
                   oplot,[xn,xn],[yn,yn],zvalue=nz(kk)+float(m)*dist/11.,/T3D,psym=3,color=lc
               endif
           endfor
        endif
        if nums gt 0L then begin
           xn=0.*xsage
           yn=0.*ysage
           for i=0L,nums-1L do begin
               ANG = (90. - ysage(i)) * RADG * 0.5
               FACTOR = TAN(ANG) * FAC20
               THETA = (xsage(i) - 90.) * RADG
               xn = FACTOR * COS(THETA)
               yn = FACTOR * SIN(THETA)
               a=findgen(8)*(2*!pi/8.)
               usersym,2*cos(a),2*sin(a),/fill
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=mcolor*.65
               a=findgen(10)*(2*!pi/10.)
               usersym,2*cos(a),2*sin(a)
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=lc
               dist=nz(kp1)-nz(kk)
               if dist gt 0. then begin
               for m=0,10 do $
                   oplot,[xn,xn],[yn,yn],zvalue=nz(kk)+float(m)*dist/11.,/T3D,psym=3,color=lc
               endif
           endfor
        endif
        if nums3 gt 0L then begin
           xn=0.*xsage3
           yn=0.*ysage3
           for i=0L,nums3-1L do begin
               ANG = (90. - ysage3(i)) * RADG * 0.5
               FACTOR = TAN(ANG) * FAC20
               THETA = (xsage3(i) - 90.) * RADG
               xn = FACTOR * COS(THETA)
               yn = FACTOR * SIN(THETA)
               a=findgen(8)*(2*!pi/8.)
               usersym,2*cos(a),2*sin(a),/fill
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=mcolor*.9
               a=findgen(10)*(2*!pi/10.)
               usersym,2*cos(a),2*sin(a)
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=lc
               dist=nz(kp1)-nz(kk)
               if dist gt 0. then begin
               for m=0,10 do $
                   oplot,[xn,xn],[yn,yn],zvalue=nz(kk)+float(m)*dist/11.,/T3D,psym=3,color=lc
              endif
           endfor
        endif
        if nump gt 0L then begin
           xn=0.*xpoam
           yn=0.*ypoam
           for i=0L,nump-1L do begin
               ANG = (90. - ypoam(i)) * RADG * 0.5
               FACTOR = TAN(ANG) * FAC20
               THETA = (xpoam(i) - 90.) * RADG
               xn = FACTOR * COS(THETA)
               yn = FACTOR * SIN(THETA)
               a=findgen(8)*(2*!pi/8.)
               usersym,2*cos(a),2*sin(a),/fill
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=mcolor*.35
               a=findgen(10)*(2*!pi/10.)
               usersym,2*cos(a),2*sin(a)
               oplot,[xn,xn],[yn,yn],zvalue=nz(kk),/T3D,psym=8,color=lc
               dist=nz(kp1)-nz(kk)
               if dist gt 0. then begin
               for m=0,10 do $
                   oplot,[xn,xn],[yn,yn],zvalue=nz(kk)+float(m)*dist/11.,/T3D,psym=3,color=lc
               endif
           endfor
        endif
    endfor	; loop over stacked polar plots
    !psym=0
    xyouts,0.32,0.89,date,/normal,charsize=3.0
    xyouts,.10,.82,'Theta (K)',charsize=2,/normal
    xyouts,.77,.82,'Altitude (km)',charsize=2,/normal
    set_viewport,.2,.78,.14-cbaryoff,.14-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    iint=(imax-imin)/10.
    level=imin+iint*findgen(10)
    plot,[imin,imax],[0,0],yrange=[0,10],$
          xrange=[imin,imax],xtitle='Temperature',/noeras,$
          xtickname=strcompress(string(fix(level)),/remove_all),$
          xstyle=1,xticks=9,charsize=1.5
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(mcolor)
    for j=0,mcolor-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=j
      x1=x1+dx
    endfor
    !p.charthick=1.
    if setplot eq 'ps' then device,/close
    if setplot eq 'x' then begin
       save=assoc(3,bytarr(nxdim,nydim))
       img=bytarr(nxdim,nydim)
       img(0,0)=TVRD(0,0,nxdim,nydim)
       write_gif,odirs(iyear)+ifile+'+occul.gif',img
       stop
    endif
    jump:
endfor	; loop over days
endfor
end
