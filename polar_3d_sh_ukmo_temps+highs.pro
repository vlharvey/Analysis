
; Antarctic vortex colored by temperature
; Anticyclones in black

@rd_ukmo_nc3
@range_ring

loadct,38
mcolor=!p.color
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,2*cos(a),2*sin(a),/fill
nxdim=800
nydim=800
cbaryoff=0.05
cbarydel=0.02
set_plot,'ps'
setplot='ps'
;read,'setplot= ',setplot
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
nr=0L
nc=0L
nth=0L
ifiles=[$
;'ukmo_sh_files_92.fil',$
;'ukmo_sh_files_93.fil',$
;'ukmo_sh_files_94.fil',$
;'ukmo_sh_files_95.fil',$
;'ukmo_sh_files_96.fil',$
;'ukmo_sh_files_97.fil',$
;'ukmo_sh_files_98.fil',$
;'ukmo_sh_files_99.fil',$
;'ukmo_sh_files_00.fil',$
;'ukmo_sh_files_01.fil',$
;'ukmo_sh_files_02.fil',$
'ukmo_sh_files_03.fil']
odirs=[$
;'1992/',$
;'1993/',$
;'1994/',$
;'1995/',$
;'1996/',$
;'1997/',$
;'1998/',$
;'1999/',$
;'2000/',$
;'2001/',$
;'2002/',$
'2003/']
nyear=n_elements(odirs)
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
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
    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
    x=fltarr(nc+1)
    x(0:nc-1)=alon(0:nc-1)
    x(nc)=alon(0)+360.

; select 3 theta levels to plot
    if l eq 0 then begin
       index=where(th ge 350. and th le 2000.,nth2)
       thlevs=reverse(strcompress(string(fix(th(index))))+' K')
       thlw=th(nth2-1)
       thup=th(0)
       x2d=fltarr(nc+1,nr/2)
       y2d=fltarr(nc+1,nr/2)
       for i=0,nc do y2d(i,*)=alat(0:nr/2-1)
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
   device,/landscape,bits=8,filename=odirs(iyear)+ifile+'.ps'
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
    set_viewport,.195,.765,.1,.35
    MAP_SET,-90,0,135,/stereo,/contin,/noborder,/noeras,londel=90.,$
            label=1,lonlab=-1,charsize=2,latdel=180.
    plots,.48,.226,/normal
    plots,.48,.78,/continue,/normal,thick=3
    set_viewport,.12,.92,.09,.92
    !type=2^6+2^5     ; suppress x and y axes
    dum=fltarr(nc+1,nr2)
    surface,dum,xcs,ycs,xrange=[-1.0,1.0],yrange=[-1.0,1.0],/noeras,$
            zrange=[thlw,thup],/save,/nodata,zstyle=4,charsize=3.0,az=-135
    for kk=0,nth2-1 do begin
        lev=nth2-1-kk
        nz=kk*(1./(nth2-1.))
        nz2=(kk+1.)*(1./(nth2+1.))
        nz3=(kk+4.)*(1./(nth2+8.))
        mark1=transpose(mark2(*,*,lev))
        sf1=transpose(sf2(*,*,lev))
        pv1=transpose(pv2(*,*,lev))
        p1=transpose(p2(*,*,lev))
        msf1=transpose(msf2(*,*,lev))
        mpv1=pv1*((th(lev)/300.))^(-9./2.)

; temperature
        temp1=th(lev)*(p1/1000.)^.286
        temp=fltarr(nc+1,nr2)
        temp(0:nc-1,0:nr2-1)=temp1(0:nc-1,0:nr2-1)    ; NH
        temp(nc,*)=temp(0,*)
        index=where(y2d gt -30. or temp eq 0.)
        temp(index)=1.e15

; height of theta surface
        zth=(msf1-1004.*temp1)/(9.86*1000.)
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
        endif

        nz2=(kk+1.)*(1./(nth2+1.))
        dum=fltarr(nc+1,nr2)
        dum(0:nc-1,0:nr2-1)=mark1(0:nc-1,0:nr2-1)    ; NH
        dum(nc,*)=dum(0,*)
;
; sub-vortex modification
;
        if th(lev) le 500. then begin
           lindex=where(dum gt 0.0,nl)
           mpv=fltarr(nc+1,nr2)
           mpv(0:nc-1,0:nr2-1)=mpv1(0:nc-1,0:nr2-1)
           mpv(nc,*)=mpv(0,*)
           if lindex(0) eq -1 then begin
              index=where(mpv le -0.0004 and y2d le -45.)
              if index(0) ne -1 then dum(index)=1.
           endif
           if lindex(0) ne -1 then begin
              if max(y2d(lindex)) ge -55. then begin
                 index=where(mpv le -0.0004 and y2d le -45.)
                 if index(0) ne -1 then dum(index)=1.
                 index=where(mpv gt -0.0004)
                 if index(0) ne -1 then dum(index)=0.
              endif
           endif
        endif

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
           contour,temp,xcs,ycs,levels=[180.,185.,190.,195.],color=0,$
                   /T3D,zvalue=nz,thick=2,max_value=1.e15
           contour,dum,xcs,ycs,levels=[0.1],color=0,$
                   c_labels=0,/T3D,zvalue=nz,thick=3,max_value=1.e15
        endif
;
; anticyclones
;
        lindex=where(dum lt 0.0,nl)
        if lindex(0) ne -1 then begin
           oplot,xcs(lindex),ycs(lindex),/T3D,zvalue=nz,psym=8,symsize=2,color=lc
           contour,dum,xcs,ycs,levels=[-0.1],color=mcolor*.05,$
                   c_labels=0,/T3D,zvalue=nz,thick=3
        endif

        jumplev:
        xyouts,.83,nz3,savgz+' km',color=lc,/normal,charsize=2
        xyouts,.08,nz3,thlevs(kk),color=lc,/normal,charsize=2
    endfor	; loop over stacked polar plots
    !psym=0
    xyouts,0.33,0.88,date,/normal,charsize=3.0
    xyouts,.08,.88,'Theta (K)',charsize=2,/normal
    xyouts,.76,.88,'Altitude (km)',charsize=2,/normal
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
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert '+odirs(iyear)+ifile+'.ps -rotate -90 '+odirs(iyear)+ifile+'.jpg'
       spawn,'/usr/bin/rm -f '+odirs(iyear)+ifile+'.ps'
    endif
;stop
    jump:
endfor	; loop over days
endfor
end
