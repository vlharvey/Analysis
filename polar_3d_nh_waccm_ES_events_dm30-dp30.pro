;
; Day -30 to day +30 for each ES event
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
cbaryoff=0.055
cbarydel=0.01
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
!NOERAS=-1
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
!noeras=1
;
; Read ES day zeros
;
restore,'/Users/harvey/Harvey_etal_2014/Post_process/elevated_strat.sav'
restore,'/Users/harvey/Harvey_etal_2014/Post_process/WACCM_ES_daily_max_T_Z.sav'
ndates = 30.*n_elements(DAYZERODATES)
dir='/Volumes/earth/harvey/WACCM_data/Datfiles/Datfiles_WACCM4/mee00fpl_FW2.cam2.h3.dyns.'
ESday = fltarr(n_elements(DAYZERODATES)*30L)
Date = fltarr(n_elements(DAYZERODATES)*30L)
nday = 0L
dayofES = 1L
niday = 0L
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)

for iES = 0L, n_elements(DAYZERODATES) - 1L do begin
    sevent=string(format='(i2.2)',ies+1)
    ydate = dayzerodates[iES]
    print,'Day Zero = ',ydate
    iyr=long(strmid(ydate,0,4))
    imn=long(strmid(ydate,4,2))
    idy=long(strmid(ydate,6,2))
    z = kgmt(imn,idy,iyr,kday)
    kday=kday-30
    if kday lt 0L then begin
       kday=kday+365
       iyr=iyr-1
    endif
    for iday=kday,kday+59L do begin
        iday0=iday
        if iday0 gt 366L then iday0=iday0-365L
        kdate,float(iday0),iyr,imn,idy
        ckday,iday0,iyr
        sdy=string(FORMAT='(i2.2)',idy)
        smn=string(FORMAT='(i2.2)',imn)
        syr=strtrim(string(iyr),2)

        if iday0-kday-30L lt 0L then sday=string(format='(i3.2)',iday0-kday-30L)
        if iday0-kday-30L ge 0L then sday=string(format='(i2.2)',iday0-kday-30L)
        if iday0 lt 60L and kday gt 300L then begin
           lday=iday0+365L
           if lday-kday-30L lt 0L then sday=string(format='(i3.2)',lday-kday-30L)
           if lday-kday-30L ge 0L then sday=string(format='(i2.2)',lday-kday-30L)
        endif
        ifile = syr+smn+sdy
        ifiles=file_search(dir+ifile+'_3D_dyn.nc3',count=nfile)
        if ifiles[0] eq '' then continue
        result=strsplit(ifiles(0),'.',/extract)
        result2=strsplit(result(4),'_',/extract)
        sdate=result2(0)
;
; read daily file
;
        ncfile0=ifiles(0)
        ncid=ncdf_open(ncfile0)
        result0=ncdf_inquire(ncid)
        for idim=0,result0.ndims-1 do begin
            ncdf_diminq,ncid,idim,name,dim
            if name eq 'number_of_latitudes' then nr=dim
            if name eq 'number_of_longitudes' then nc=dim
            if name eq 'number_of_levels' then nth=dim
        endfor
        for ivar=0,result0.nvars-1 do begin
            result=ncdf_varinq(ncid,ivar)
            ncdf_varget,ncid,ncdf_varid(ncid,result.name),data
            if result.name eq 'latitude' then alat=data
            if result.name eq 'longitude' then alon=data
            if result.name eq 'theta' then th=data
            if result.name eq 'IPV' then pv2=data
            if result.name eq 'P' then p2=data
            if result.name eq 'U' then u2=data
            if result.name eq 'V' then v2=data
            if result.name eq 'QDF' then qdf2=data
            if result.name eq 'Q' then q2=data
            if result.name eq 'GPH' then gph2=data
            if result.name eq 'TTGW' then ttgw2=data
            if result.name eq 'SF' then sf2=data
            if result.name eq 'MARK' then mark2=data
            print,ivar,result.name,min(data),max(data)
        endfor
        ncdf_close,ncid

      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.

; select theta levels to plot
      zindex=where(th ge 500. and th le 5000.,nth2)
      thlevs=reverse(strcompress(string(fix(th(zindex))))+' K')
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
;        !p.font=0
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                /bold,/color,bits_per_pixel=8,/times,filename='../Figures/ES_event_'+sevent+'_Day_'+sday+'_'+sdate+'_3D_waccm.ps'
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !p.charthick=5
         !y.thick=2
         !x.thick=2
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
    irot=210.
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
        lev=zindex(nth2-1-kk)
        slev=strcompress(long(mean(gph2(nr2:nr-1,*,lev))/1000.),/remove_all)
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
        temp=fltarr(nc+1,nr2)
        temp(0:nc-1,0:nr2-1)=temp1(0:nc-1,nr2:nr-1)    ; NH
        temp(nc,*)=temp(0,*)
        index=where(y2d lt 25. or temp eq 0.)
        temp(index)=1.e15

; draw latitude circles
        if kk eq 0 then begin
        !psym=0
        lon=findgen(361)
        lonp=0.*lon
        latp=0.*lon
;oplot,xcn,ycn,psym=8,symsize=2.25,color=mcolor*.3,/T3D,zvalue=nz(kk)	; blue ocean is too much color
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
            oplot,lonp,latp,/T3D,zvalue=nz(kk),color=0,thick=2
        endfor
;       MAP_SET,90,0,250.-1.*irot,/stereo,/contin,/grid,/noborder,/noeras,londel=90.,$
        MAP_SET,90,0,0,/stereo,/contin,/grid,/noborder,/noeras,londel=90.,$
            label=1,lonlab=1,charsize=3,latdel=180.,/t3d,zvalue=nz(kk),color=0
;
; fill continents grey
;
        loadct,0
        map_continents,mlinethick=2,/t3d,zvalue=nz(kk),color=mcolor*.5,/fill_continents,/coasts,/countries
        map_continents,/t3d,zvalue=nz(kk),color=0,/countries,/usa,/coasts
        MAP_SET,90,0,0,/stereo,/contin,/grid,/noborder,/noeras,londel=90.,$
            label=1,lonlab=1,charsize=3,latdel=180.,/t3d,zvalue=nz(kk),color=0
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
        loadct,39
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
        imax=300.
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
            if th(lev) gt 700. then begin
;           contour,temp,xcn,ycn,levels=[180.],color=.8*mcolor,/T3D,zvalue=nz(kk),thick=3,max_value=1.e15
;           contour,temp,xcn,ycn,levels=[185.],color=.85*mcolor,/T3D,zvalue=nz(kk),thick=3,max_value=1.e15
;           contour,temp,xcn,ycn,levels=[190.],color=.9*mcolor,/T3D,zvalue=nz(kk),thick=3,max_value=1.e15
            endif
            contour,dum,xcn,ycn,levels=[0.1],color=0,c_labels=0,/T3D,zvalue=nz(kk),thick=10,max_value=1.e15
         endif
;;
;; anticyclones
;;
;        lindex=where(dum lt 0.0,nl)
;        if lindex(0) ne -1 then begin
;;          oplot,xcn(lindex),ycn(lindex),/T3D,zvalue=nz(kk),psym=8,symsize=2,color=0
;loadct,0
;;          contour,dum,xcn,ycn,levels=[-0.1],color=mcolor*.3,$
;;                  c_labels=0,/T3D,zvalue=nz(kk),thick=3
;           nhigh=abs(min(dum(lindex)))
;sdum=0.*dum
;        sdum(0:nc-1,0:nr2-1)=sf1(0:nc-1,nr2:nr-1)    ; NH
;        sdum(nc,*)=sdum(0,*)
;dx=x2d(1,0)-x2d(0,0)
;           for ihigh=0,nhigh-1 do begin
;               index=where(dum eq -1.0*(ihigh+1))
;               if min(y2d(index)) le 13.7500 then goto,jump1
;               sedge=min(sdum(index))     ; value of SF to contour
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
;                  index=where(x2d lt xmin or x2d gt xmax or y2d lt ymin or y2d gt ymax)
;               if index(0) ne -1 then tmp(index)=-9999.
;               index=where(tmp ne -9999. and y2d gt 13.7500 and dum eq -1.0*(ihigh+1))
;               if index(0) ne -1L then oplot,xcn(index),ycn(index),psym=8,color=0,/T3D,zvalue=nz(kk),symsize=2
;               contour,tmp,xcn,ycn,levels=[sedge],color=icolmax*.7,$
;                 /T3D,zvalue=nz(kk),c_linestyle=0,/overplot,min_value=-9999.,thick=10
;               jump1:
;           endfor               ; loop over anticyclones
;
;loadct,39
;        endif
;
        if kk mod 2 eq 0 then begin
        xyouts,.05,nz4,slev+' km',color=0,/normal,charsize=2,charthick=5
        endif
    endfor	; loop over stacked polar plots
    !psym=0
    xyouts,0.2,0.9,'ES event '+sevent+' Day '+sday+' '+sdate,/normal,charsize=2,color=0,charthick=5
    xyouts,.05,.85,'Altitude',charsize=2,/normal,color=0,charthick=5
;
    set_viewport,.25,.73,.12-cbaryoff,.12-cbaryoff+cbarydel
    !type=2^2+2^3+2^6
    iint=(imax-imin)/10.
    level=imin+iint*findgen(10)
    plot,[imin,imax],[0,0],yrange=[0,10],$
          xrange=[imin,imax],xtitle='WACCM4 Temperature',/noeras,$
          xtickname=strcompress(string(fix(level)),/remove_all),$
          xstyle=1,xticks=9,charsize=1.25,color=0,charthick=5
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nth2)
    for j=0,nth2-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
    endfor

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim ../Figures/ES_event_'+sevent+'_Day_'+sday+'_'+sdate+'_3D_waccm.ps -rotate -90 ../Figures/ES_event_'+sevent+'_Day_'+sday+'_'+sdate+'_3D_waccm.png'
       spawn,'rm -f ../Figures/ES_event_'+sevent+'_Day_'+sday+'_'+sdate+'_3D_waccm.ps'
    endif

endfor          ; loop over days 0 to +30
endfor          ; loop over ES events
end