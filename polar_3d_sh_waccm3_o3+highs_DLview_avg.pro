
; Antarctic vortex colored by Ozone
; Anticyclones in black poleward of 13.75S

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
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
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
mon=['jul']
month=['July']
!noeras=1
dir='/aura7/harvey/WACCM_data/Datfiles/Datfiles_TNV3/wa3_tnv3_'
nmonth=n_elements(month)
for imonth=0,nmonth-1 do begin
    spawn,'ls '+dir+mon(imonth)+'*avg.sav',ifile
    restore,ifile
    pv2=pv_mean
    p2=p_mean
    ch4=ch4_mean
    u2=u_mean
    v2=v_mean
    no2=no2_mean
    mark2=mark_mean
    sf2=sf_mean
    h2o=h2o_mean
    o3=o3_mean

tmp2=0.*p2
for k=0L,nth-1L do tmp2(*,*,k)=th(k)*(p2(*,*,k)/1000.)^0.286
      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.

; select theta levels to plot
    if imonth eq 0L then begin
       zindex=where(th ge 300. and th le 4000.,nth2)
       thlevs=reverse(strcompress(string(fix(th(zindex))))+' K')
       thlw=min(th(zindex))
       thup=max(th(zindex))
       th2=reverse(th(zindex))
       nr2=nr/2
       x2d=fltarr(nc+1,nr2)
       y2d=fltarr(nc+1,nr2)
       for i=0,nc do y2d(i,*)=alat(0:nr2-1)
       for j=0,nr2-1 do x2d(*,j)=x
       dy=alat(1)-alat(0)
    endif

; save postscript version
    if setplot eq 'ps' then begin
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='3d_sh_'+mon(imonth)+'_wa3.ps'
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
    irot=-115.
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
        o31=transpose(o3(*,*,lev))*1.e6
        p1=transpose(p2(*,*,lev))
        mpv1=pv1*((th(lev)/300.))^(-9./2.)

; temperature
        temp1=th(lev)*(p1/1000.)^.286
print,th(lev),min(temp1),max(temp1)
        temp=fltarr(nc+1,nr2)
        temp(0:nc-1,0:nr2-1)=temp1(0:nc-1,0:nr2-1)    ; SH
; substitute ozone mixing ratio
;       temp(0:nc-1,0:nr2-1)=o31(0:nc-1,0:nr2-1)    ; SH
        temp(nc,*)=temp(0,*)
;       index=where(y2d lt 30. or temp eq 0.)
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

        lindex=where(dum gt 0.1,nl)
        imin=180.
        imax=270.
	if lindex(0) ne -1 then begin
           for ii=0,nl-1 do begin
               if temp(lindex(ii)) ne 1.e15 then $
               oplot,[xcs(lindex(ii)),xcs(lindex(ii))],$
                     [ycs(lindex(ii)),ycs(lindex(ii))],$
                     /T3D,zvalue=nz,psym=8,symsize=2,$
                     color=((temp(lindex(ii))-imin)/(imax-imin))*icolmax
;              if temp(lindex(ii)) eq 1.e15 then $
;              oplot,[xcs(lindex(ii)),xcs(lindex(ii))],$
;                    [ycs(lindex(ii)),ycs(lindex(ii))],$
;                    /T3D,zvalue=nz,psym=8,symsize=0.5,color=0
           endfor
;          contour,temp,xcs,ycs,levels=[180.],color=10,$
;                  /T3D,zvalue=nz,thick=3,max_value=1.e15
           contour,dum,xcs,ycs,levels=[0.1],color=0,$
                   c_labels=0,/T3D,zvalue=nz,thick=3,max_value=1.e15
        endif
;
; anticyclones
;
;dum=dum/(xcs^2+ycs^2)
        index=where(dum lt -0.25,nl)

        if index(0) ne -1 then begin
           oplot,xcs(index),ycs(index),/T3D,zvalue=nz,psym=8,symsize=2,color=0
loadct,0
           contour,dum,xcs,ycs,levels=[-0.25],color=mcolor*.7,$
                   c_labels=0,/T3D,zvalue=nz,thick=3
;           nhigh=abs(min(dum(lindex)))
;sdum=0.*dum
;        sdum(0:nc-1,0:nr2-1)=sf1(0:nc-1,nr/2:nr-1)    ; SH
;        sdum(nc,*)=sdum(0,*)
;dx=x2d(1,0)-x2d(0,0)
;           for ihigh=0,nhigh-1 do begin
;               index=where(dum eq -1.0*(ihigh+1))
;               if index(0) eq -1 then goto,jump1
;              if max(y2d(index)) ge -13.7500 then goto,jump1
;              if max(y2d(index)) ge -2.5 then goto,jump1
;               sedge=max(sdum(index))     ; value of SF to contour
;               tmp=sdum
;               xmax=max(x2d(index))+1.0*dx      ; isolate region
;               xmin=min(x2d(index))-1.0*dx
;               ymax=max(y2d(index))+2.0*dy
;               ymin=min(y2d(index))-2.0*dy
;               if xmin lt x(0) and xmax gt x(nc) then begin     ; GM
;                  index=where(x2d gt 180. and dum eq -1.0*(ihigh+1))
;                  xmax2=min(x2d(index))-2.0*dx
;                  index=where(x2d lt 180. and dum eq -1.0*(ihigh+1))
;                  xmin2=max(x2d(index))+2.0*dx
;                  index=where((x2d lt xmax2 and x2d gt xmin2) or (y2d lt ymin or y2d gt ymax))
;               endif
;               if xmin gt x(0) or xmax lt x(nc) then $
;                 index=where(x2d lt xmin or x2d gt xmax or y2d lt ymin or y2d gt ymax)
;              if index(0) ne -1 then tmp(index)=-9999.
;              index=where(tmp ne -9999. and y2d gt 13.7500 and dum eq -1.0*(ihigh+1))
;               index=where(tmp ne -9999. and y2d gt 0. and dum eq -1.0*(ihigh+1))
;               oplot,xcs(index),ycs(index),psym=8,color=0,/T3D,zvalue=nz,symsize=1.8
;               contour,tmp,xcs,ycs,levels=[sedge],color=icolmax*.7,$
;                 /T3D,zvalue=nz,c_linestyle=0,/overplot,min_value=-9999.,thick=3
;               jump1:
;           endfor               ; loop over anticyclones

loadct,38
        endif
jumplev:
        xyouts,.83,nz4,savgz,color=0,/normal,charsize=2,charthick=2
        xyouts,.08,nz4,thlevs(kk),color=0,/normal,charsize=2,charthick=2
    endfor	; loop over stacked polar plots
    !psym=0
    xyouts,0.33,0.88,month(imonth)+' WACCM3',/normal,charsize=3.0,color=0,charthick=2
    xyouts,.08,.8,'Theta (K)',charsize=2,/normal,color=0,charthick=2
    xyouts,.78,.8,'Pressure (hPa)',charsize=2,/normal,color=0,charthick=2
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
       spawn,'convert -trim 3d_sh_'+mon(imonth)+'_wa3.ps -rotate -90 3d_sh_'+mon(imonth)+'_wa3.jpg'
;      spawn,'/usr/bin/rm 3d_sh_'+mon(imonth)+'_wa3.ps'
    endif

endfor

end
