;
; Antarctic vortex colored by Temperature
;
@stddat
@kgmt
@ckday
@kdate
@rd_waccm3_nc3_bardeen_dust

loadct,38
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
lstmn=1
lstdy=1
lstyr=2034
ledmn=12
leddy=31
ledyr=2034
lstday=0
ledday=0
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
;
; Ask interactive questions- get starting/ending date and p surface
;
print, ' '
print, '      WACCM Version '
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '

if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
!noeras=1
dir='/aura3/data/WACCM_data/Datfiles/h0.lynn+dust.'

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      if iyr ge 2000L then iyr1=iyr-2000L
      if iyr lt 2000L then iyr1=iyr-1900L
      sday=string(FORMAT='(I3.3)',iday-1)
      ifile=dir+sday+'_00Z.nc3'
      rd_waccm3_nc3_bardeen_dust,ifile,nc,nr,nth,alon,alat,th,pv2,p2,$
         u2,v2,qdf2,mark2,vp,sf2,q2,dust_ad,dust_md,dust_mmr,dust_nd,dust_re,iflag
      if iflag ne 0L then goto,jump
tmp2=0.*p2
for k=0L,nth-1L do tmp2(*,*,k)=th(k)*(p2(*,*,k)/1000.)^0.286
      if iflag eq 1 then goto,jump
      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.

; select theta levels to plot
    if icount eq 0L then begin
       zindex=where(th ge 300. and th le 5000.,nth2)
       thlevs=reverse(strcompress(string(fix(th(zindex))))+' K')
       thlw=min(th(zindex))
       thup=max(th(zindex))
       th2=reverse(th(zindex))
       nr2=nr/2
       x2d=fltarr(nc+1,nr2)
       y2d=fltarr(nc+1,nr2)
       for i=0,nc do y2d(i,*)=alat(0:nr/2-1)
       for j=0,nr2-1 do x2d(*,j)=x
       dy=alat(1)-alat(0)
       icount=1L
    endif

; save postscript version
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='Figures/'+sday+'_sh_cb+dust.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
       !p.thick=2.0                   ;Plotted lines twice as thick
       !p.charsize=2.0
    endif

; coordinate transformation
    xcs=fltarr(nc+1,nr2)
    ycs=fltarr(nc+1,nr2)
    for j=0,nr/2-1 do begin
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
    irot=-15.
;   irot=0.
    surface,dum,xcs,ycs,xrange=[-1.0,1.0],yrange=[-1.0,1.0],/noeras,$
            zrange=[thlw,thup],/save,/nodata,zstyle=4,charsize=3.0,az=irot
    col1=fltarr(nth2)
    for kk=0,nth2-1 do begin
        index=where(th eq th2(kk))
        lev=index(0)
        nz=kk*(1./(nth2-1.))
        nz2=(kk+1.)*(1./(nth2+1.))
        nz3=(kk+4.)*(1./(nth2+8.))
        nz4=(kk+8.)*(1./(nth2+16.))
        mark1=transpose(mark2(*,*,lev))
        sf1=transpose(sf2(*,*,lev))
        pv1=transpose(pv2(*,*,lev))
        p1=transpose(p2(*,*,lev))
        mpv1=pv1*((th(lev)/300.))^(-9./2.)

; temperature
        temp1=th(lev)*(p1/1000.)^.286
print,th(lev),min(temp1),max(temp1)
        temp=fltarr(nc+1,nr2)
        temp(0:nc-1,0:nr2-1)=temp1(0:nc-1,0:nr2-1)    ; SH
        temp(nc,*)=temp(0,*)
;       index=where(y2d gt -30. or temp eq 0.)
        index=where(temp eq 0.)
        if index(0) ne -1 then temp(index)=1.e15

; pressure of theta surface
        index=where(p1 ne 0.)
        if n_elements(index) eq 1L then goto,jumplev
	result=moment(p1(index))
	avgz=result(0)
        savgz=strcompress(string(FORMAT='(F7.3)',avgz))

; draw latitude circles
        if kk eq 0 then begin
        !psym=0
        lon=findgen(361)
        lonp=0.*lon
        latp=0.*lon
        for k=0,0 do begin
            if k eq 0 then lat=0.*fltarr(361)
            if k eq 1 then lat=-30.+0.*fltarr(361)
            if k eq 2 then lat=-60.+0.*fltarr(361)
            for j=0,360 do begin
                ANG = (90. - lat(j)) * RADG * 0.5
                FACTOR = TAN(ANG) * FAC20
                THETA = (lon(j) - 90.) * RADG
                lonp(j) = FACTOR * COS(THETA)
                latp(j) = -1.0*FACTOR * SIN(THETA)
            endfor
            oplot,lonp,latp,/T3D,zvalue=nz,color=0,thick=2
        endfor
        MAP_SET,-90,0,-1.*irot,/stereo,/contin,/grid,/noborder,/noeras,londel=90.,$
            label=1,lonlab=1,charsize=2,latdel=180.,/t3d,zvalue=nz,color=0
;
; fill continents grey
;
        loadct,0
        map_continents,mlinethick=2,/t3d,zvalue=nz,color=mcolor*.4,/fill_continents
;
; superimpose stream function
;
        dum(0:nc-1,0:nr2-1)=sf1(0:nc-1,0:nr2-1)    ; SH
        dum(nc,*)=dum(0,*)
        smin=min(dum)
        smax=max(dum)
        sint=(smax-smin)/15.
        sflevel=smin+sint*findgen(15)
        contour,dum,xcs,ycs,levels=sflevel,color=0,c_labels=0+0.*sflevel,$
                /T3D,zvalue=nz,thick=1
        loadct,38
        endif
 
        nz2=(kk+1.)*(1./(nth2+1.))
        col1(kk)=nz2*icolmax
        dum=fltarr(nc+1,nr2)
        dum(0:nc-1,0:nr2-1)=mark1(0:nc-1,0:nr2-1)    ; SH
        dum(nc,*)=dum(0,*)
;
; sub-vortex modification
;
        if th(lev) le 300. then begin
           lindex=where(dum gt 0.0,nl)
           mpv=fltarr(nc+1,nr2)
           mpv(0:nc-1,0:nr2-1)=mpv1(0:nc-1,0:nr2-1)
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
        imin=170.
        imax=310.
	if lindex(0) ne -1 then begin
           for ii=0,nl-1 do begin
               if temp(lindex(ii)) ne 1.e15 then $
               oplot,[xcs(lindex(ii)),xcs(lindex(ii))],$
                     [ycs(lindex(ii)),ycs(lindex(ii))],$
                     /T3D,zvalue=nz,psym=8,symsize=2,$
                     color=((temp(lindex(ii))-imin)/(imax-imin))*icolmax
           endfor
;          contour,temp,xcs,ycs,levels=[180.],color=10,$
;                  /T3D,zvalue=nz,thick=3,max_value=1.e15
           contour,dum,xcs,ycs,levels=[0.1],color=0,$
                   c_labels=0,/T3D,zvalue=nz,thick=3,max_value=1.e15
        endif

jumplev:
        xyouts,.83,nz4,savgz,color=0,/normal,charsize=2,charthick=2
        xyouts,.08,nz4,thlevs(kk),color=0,/normal,charsize=2,charthick=2
    endfor	; loop over stacked polar plots
    !psym=0
    xyouts,0.375,0.88,'Day '+sday,/normal,charsize=3.0,color=0,charthick=2
    xyouts,.08,.85,'Theta (K)',charsize=2,/normal,color=0,charthick=2
    xyouts,.78,.85,'Pressure (hPa)',charsize=2,/normal,color=0,charthick=2
    set_viewport,.2,.78,.14-cbaryoff,.14-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    iint=(imax-imin)/12.
    level=imin+iint*findgen(13)
    plot,[imin,imax],[0,0],yrange=[0,10],$
          xrange=[imin,imax],xtitle='Temperature',/noeras,$
          xtickname=strcompress(string(fix(level)),/remove_all),$
          xstyle=1,xticks=12,charsize=1.5,color=0,charthick=2
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
       spawn,'convert -trim Figures/'+sday+'_sh_cb+dust.ps -rotate -90 Figures/'+sday+'_sh_cb+dust.jpg'
;      spawn,'/usr/bin/rm Figures/'+sday+'_sh_cb+dust.ps'
    endif

goto, jump

end
