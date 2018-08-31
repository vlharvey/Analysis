
; Arctic vortex colored by Temperature

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
'ukmo_nh_files_91-92.fil',$
'ukmo_nh_files_92-93.fil',$
'ukmo_nh_files_93-94.fil',$
'ukmo_nh_files_94-95.fil',$
'ukmo_nh_files_95-96.fil',$
'ukmo_nh_files_96-97.fil',$
'ukmo_nh_files_97-98.fil',$
'ukmo_nh_files_98-99.fil',$
'ukmo_nh_files_99-00.fil',$
'ukmo_nh_files_00-01.fil',$
'ukmo_nh_files_01-02.fil',$
'ukmo_nh_files_02-03.fil',$
'ukmo_nh_files_03-04.fil']
odirs=[$
'1991-1992/',$
'1992-1993/',$
'1993-1994/',$
'1994-1995/',$
'1995-1996/',$
'1996-1997/',$
'1997-1998/',$
'1998-1999/',$
'1999-2000/',$
'2000-2001/',$
'2001-2002/',$
'2002-2003/',$
'2003-2004/']
nyear=n_elements(odirs)
!noeras=1
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
for iyear=0,nyear-1 do begin
close,1
openr,1,ifiles(iyear)
nfile=0L
readf,1,nfile
for l=0,nfile-1 do begin
    readf,1,ifile
    print,ifile
    mindex=where(strmid(ifile,0,3) eq mon)
;
; this logic will work through 2090
;
    if strmid(ifile,7,1) eq '9' then $
       date=strmid(ifile,4,2)+' '+month(mindex(0))+' 19'+strmid(ifile,7,2)
    if strmid(ifile,7,1) ne '9' then $
       date=strmid(ifile,4,2)+' '+month(mindex(0))+' 20'+strmid(ifile,7,2)
    rd_ukmo_nc3,dir+ifile+'_solve2.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
    x=fltarr(nc+1)
    x(0:nc-1)=alon(0:nc-1)
    x(nc)=alon(0)+360.

; select theta levels to plot
    if l eq 0 then begin
       index=where(th ge 300. and th le 2000.,nth2)
       thlevs=reverse(strcompress(string(fix(th(index))))+' K')
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
   device,/landscape,bits=8,filename='Postscript/'+ifile+'.ps'
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
    col1=fltarr(nth2)
    for kk=0,nth2-1 do begin
        lev=nth2-1-kk
        nz=kk*(1./(nth2-1.))
        nz2=(kk+1.)*(1./(nth2+1.))
        nz3=(kk+4.)*(1./(nth2+8.))
        sflmark=transpose(marksf2(*,*,lev))
        sfhmark=transpose(marksf2(*,*,lev))
        sf=transpose(sf2(*,*,lev))
        pv=transpose(pv2(*,*,lev))
        prs=transpose(p2(*,*,lev))
        msf=transpose(msf2(*,*,lev))
        mpv1=pv*((th(lev)/300.))^(-9./2.)

; temperature
        temp1=th(lev)*(prs/1000.)^.286
        temp=fltarr(nc+1,nr2)
        temp(0:nc-1,0:nr2-1)=temp1(0:nc-1,nr2:nr-1)    ; NH
        temp(nc,*)=temp(0,*)
        index=where(y2d lt 30. or temp eq 0.)
        temp(index)=1.e15

; height of theta surface
        zth=(msf-1004.*temp1)/(9.86*1000.)
	result=moment(zth(*,nr2:nr-1))
	avgz=result(0)
        savgz=strcompress(string(fix(avgz)),/remove_all)

; superimpose stream function
        dum(0:nc-1,0:nr2-1)=sf(0:nc-1,nr2:nr-1)    ; NH
        dum(nc,*)=dum(0,*)
        if kk eq 0 then begin
           !psym=0
           smin=min(dum)
           smax=max(dum)
           sint=(smax-smin)/15.
           sflevel=smin+sint*findgen(15)
           contour,dum,xcn,ycn,levels=sflevel,color=lc,c_labels=0+0.*sflevel,$
                   /T3D,zvalue=nz,thick=1
        endif

; draw latitude circles
        if kk eq 0 then begin
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
            oplot,lonp,latp,/T3D,zvalue=nz,color=lc
        endfor
        endif
 
        nz2=(kk+1.)*(1./(nth2+1.))
        col1(kk)=nz2*icolmax
        dum=fltarr(nc+1,nr2)
        dum(0:nc-1,0:nr2-1)=sflmark(0:nc-1,nr2:nr-1)    ; NH
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
           mpv=fltarr(nc+1,nr2)
           mpv(0:nc-1,0:nr2-1)=mpv1(0:nc-1,nr2:nr-1)
           mpv(nc,*)=mpv(0,*)
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
                     /T3D,zvalue=nz,psym=8,symsize=2,$
                     color=((temp(lindex(ii))-imin)/(imax-imin))*icolmax
               if temp(lindex(ii)) eq 1.e15 then $
               oplot,[xcn(lindex(ii)),xcn(lindex(ii))],$
                     [ycn(lindex(ii)),ycn(lindex(ii))],$
                     /T3D,zvalue=nz,psym=8,symsize=0.5,color=0
           endfor
           contour,temp,xcn,ycn,levels=[180.,185.,190.,195.],color=0,$
                   /T3D,zvalue=nz,thick=2,max_value=1.e15
           contour,dum,xcn,ycn,levels=[0.1],color=0,$
                   c_labels=0,/T3D,zvalue=nz,thick=3,max_value=1.e15
        endif
        xyouts,.83,nz3,savgz+' km',color=lc,/normal,charsize=2
        xyouts,.08,nz3,thlevs(kk),color=lc,/normal,charsize=2
    endfor	; loop over stacked polar plots
    !psym=0
    xyouts,0.33,0.9,date,/normal,charsize=3.0
    xyouts,.08,.9,'Theta (K)',charsize=2,/normal
    xyouts,.76,.9,'Altitude (km)',charsize=2,/normal
;   !type=2^6+2^5     ; suppress x and y axes
;   set_viewport,.195,.765,.65,.9
;   MAP_SET,90,0,135,/stereo,/contin,/grid,/noborder,/noeras

; draw color bar
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
    dx=(imax-imin)/float(nth2)
    for j=0,nth2-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
    endfor
    !p.charthick=1.
;stop
    if setplot eq 'ps' then device,/close
    if setplot eq 'x' then begin
       save=assoc(3,bytarr(nxdim,nydim))
       img=bytarr(nxdim,nydim)
       img(0,0)=TVRD(0,0,nxdim,nydim)
       write_gif,odirs(iyear)+ifile+'.gif',img
    endif
    jump:
endfor	; loop over days
endfor
end
