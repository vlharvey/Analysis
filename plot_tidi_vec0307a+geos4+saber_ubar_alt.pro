;
; bin TIDI zonal wind in latitude and plot zonal mean zonal wind
; compare to MetO and GEOS-4
; interpolate MetO and GEOS-4 to altitude
;
@read_tidi_vec0307a
@kdate
@rd_ukmo_nc3

nlatbin=18L
latbin=-85.+10.*findgen(nlatbin)
naltbin=30L
altbin=2.5+2.5*findgen(naltbin)
naltbin2=50L
altbin2=2.5+2.5*findgen(naltbin2)
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
device,decompose=0
!p.background=icolmax
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.1,0.1]
yorig=[0.52,0.2]
xlen=0.4
ylen=0.35
cbaryoff=0.10
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
gdir='/aura7/harvey/GEOS4_data/Datfiles/'
spawn,'ls /aura3/data/TIDI_data/Datfiles/vec0307a/TIDI_VEC_20041*ncdf',ncfiles	; with G4 data
;spawn,'ls /aura3/data/TIDI_data/Datfiles/vec0307a/TIDI_VEC_200302*ncdf',ncfiles		; with SABER data
nfile=n_elements(ncfiles)
for ifile=0L,nfile-1L do begin
    ncfile=ncfiles(ifile)
    read_tidi_vec0307a,ncfile,nvec,nalts,date_len,two_telescopes,ut_date,lat,lon,sza,alt_retrieved,time,$
         ms_time,ut_time,rec_index,data_ok,lst,lza,mlat,mlon,track,table_id,measure_track,flight_dir,ascending,$
         in_saa,u_p9,var_u_p9,v_p9,var_v_p9,u_p15,var_u_p15,v_p15,var_v_p15,u_bb,var_u_bb,v_bb,var_v_bb,ver_p9,$
         var_ver_p9,t_doppler_p9,var_t_doppler_p9,ver_p15,var_ver_p15,t_doppler_p15,var_t_doppler_p15,ver_bb,$
         var_ver_bb,t_doppler_bb,var_t_doppler_bb
    print,'read '+ncfile

    ut_seconds=ut_time/1000.
    ut_hours=ut_seconds/60./60.
    sut_date=string(ut_date)
    sdate=sut_date(0)

    sdata_ok=strarr(nvec)
    for i=0L,nvec-1L do sdata_ok(i)=string(DATA_OK(i))
    warm_or_cold=strarr(nvec)
    for i=0L,nvec-1L do warm_or_cold(i)=string(measure_track(i))
;
; read GEOS-4 data on sdate
;
    submeto=0L
    syr=strmid(sdate,0,4)
    iyr=long(syr)
    iday=strmid(sdate,4,3)
    kdate,float(iday),iyr,imn,idy
    smn=string(FORMAT='(I2.2)',imn)
    sdy=string(FORMAT='(I2.2)',idy)
    sdatelabel=syr+smn+sdy
    gfile='DAS.flk.asm.tavg3d_mis_e.GEOS403.MetO.'+syr+smn+sdy+'_1200.V01.dat'
    dum=findfile(gdir+gfile)
    if dum(0) eq '' then submeto=1L
    if submeto eq 0L then begin
    rd_geos5_dat,gdir+gfile,iflg,nlg,nlat,nlv,glon,glat,gwlon,gwlat,p,zp,tp,up,vp,qp
    print,'read '+gfile
    zp=zp/1000.
    ubar=fltarr(nlat-1L,nlv)
    zbar=fltarr(nlat,nlv)
    for k=0L,nlv-1L do begin
    for j=0L,nlat-2L do begin
        ubar(j,k)=total(up(*,j,k))/float(nlg)
        zbar(j,k)=total(zp(*,j,k))/float(nlg)
    endfor
    zbar(nlat-1,k)=total(zp(*,nlat-1,k))/float(nlg)
    endfor
;
; intepolate Ubar to altitude
;
    ubarz=fltarr(nlat-1L,naltbin)
    for j=0L,nlat-2L do begin
        for k=0L,naltbin-1L do begin
            zlev=altbin(k)
            for kk=0L,nlv-2 do begin
                z0=(zbar(j,kk)+zbar(j+1,kk))/2.
                z1=(zbar(j,kk+1)+zbar(j+1,kk+1))/2.
                if z0 le zlev and z1 gt zlev then begin
                   zscale=(z1-zlev)/(z1-z0)
                   ubarz(j,k)=ubar(j,kk+1)+zscale*(ubar(j,kk)-ubar(j,kk+1))
                endif
            endfor
        endfor
    endfor
    plat=gwlat
    endif
;
; read MetO on sdate
;
    if submeto eq 1L then begin
       syr=strmid(sdate,2,2)
       iyr=long(syr)
       iday=strmid(sdate,4,3)
       kdate,float(iday),iyr,imn,idy
       smn=string(format='(i2.2)',imn)
       sdy=string(format='(i2.2)',idy)
       ufile='/aura3/data/UKMO_data/Datfiles/ukmo_'+mon(imn-1)+sdy+'_'+syr+'.nc3'
       rd_ukmo_nc3,ufile,nc,nr,nth,ulon,ulat,th,pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
       print,'read '+ufile
;
; compute geopotential height
;
       z2=0.*qdf2
       t2=0.*qdf2
       for k=0,nth-1 do begin
           t2(*,*,k) = th(k)*( (p2(*,*,k)/1000.)^(.286) )
           z2(*,*,k) = (msf2(*,*,k) - 1004.*t2(*,*,k))/(9.86*1000.)
       endfor
;
; compute Ubar
;
       ubar=fltarr(nr,nth)
       zbar=fltarr(nr,nth)
       for k=0L,nth-1L do begin
       for j=0L,nr-1L do begin
           ubar(j,k)=total(u2(j,*,k))/float(nc)
           zbar(j,k)=total(z2(j,*,k))/float(nc)
       endfor
       endfor
;
; intepolate Ubar to altitude
;
       ubarz=-999.+0.*fltarr(nr,naltbin)
       for j=0L,nr-1L do begin
           for k=0L,naltbin-1L do begin
               zlev=altbin(k)
               for kk=1L,nth-1 do begin
                   z0=zbar(j,kk)
                   z1=zbar(j,kk-1)
                   if z0 le zlev and z1 gt zlev then begin
                      zscale=(z1-zlev)/(z1-z0)
                      ubarz(j,k)=ubar(j,kk-1)+zscale*(ubar(j,kk)-ubar(j,kk-1))
                   endif
               endfor
           endfor
       endfor
       plat=ulat
    endif
;
; construct zonal mean zonal wind from TIDI
;
    tidi_ubar=fltarr(nlatbin,nalts)
    tidi_nubar=lonarr(nlatbin,nalts)
    dy=(latbin(1)-latbin(0))/2.
    for ii=0L,nvec-1 do begin
        if warm_or_cold(ii) eq 'C' and sdata_ok(ii) eq 'T' then begin
        uprof=reform(u_p9(*,ii))
        zindex=where(uprof ne -999. and uprof ne 0.)
        if zindex(0) eq -1L then goto,jumpvec
        for jj=0L,nlatbin-1L do begin
            if latbin(jj)-dy le lat(ii) and latbin(jj)+dy gt lat(ii) then begin
               tidi_ubar(jj,zindex)=tidi_ubar(jj,zindex)+uprof(zindex) 
               tidi_nubar(jj,zindex)=tidi_nubar(jj,zindex)+1L
               goto,jumpvec
            endif
        endfor
        endif
        jumpvec:
    endfor
    index=where(tidi_nubar gt 0L)
    if index(0) eq -1L then goto,jump
    tidi_ubar(index)=tidi_ubar(index)/tidi_nubar(index)
    index=where(tidi_nubar eq 0L)
    if index(0) ne -1L then tidi_ubar(index)=-999.
;
; read SABER winds
;
    sfile='GRID_PHI_WINDS.'+sdatelabel+'.sav'
    sdum=findfile('/aura6/data/SABER_data/Datfiles_winds/'+sfile)
    if sdum(0) ne '' then begin
    restore,'/aura6/data/SABER_data/Datfiles_winds/'+sfile
;
; compute Ubar
;
    snlat=n_elements(alat)
    snlg=n_elements(alon)
    snlv=n_elements(press)
    ubar_saber=fltarr(snlat,snlv)
    zbar_saber=fltarr(snlat,snlv)
    for k=0L,snlv-1L do begin
    for j=0L,snlat-1L do begin
        index=where(u3d(*,j,k) ne 0.,ngood)
        if index(0) ne -1L then begin
           ubar_saber(j,k)=total(u3d(index,j,k))/float(ngood)
;          zbar_saber(j,k)=total(z3d(index,j,k))/float(ngood)
        endif
    endfor
    endfor
    endif
;
; intepolate SABER Ubar to high altitude grid
;
;   ubarz_saber=-999.+0.*fltarr(snlat,naltbin2)
;   for j=0L,snlat-1L do begin
;       for k=0L,naltbin2-1L do begin
;           zlev=altbin2(k)
;           for kk=0L,snlv-2 do begin
;               z0=zbar_saber(j,kk)
;               z1=zbar_saber(j,kk+1)
;               if z0 le zlev and z1 gt zlev then begin
;                  zscale=(z1-zlev)/(z1-z0)
;                  ubarz_saber(j,k)=ubar_saber(j,kk+1)+zscale*(ubar_saber(j,kk)-ubar_saber(j,kk+1))
;               endif
;           endfor
;       endfor
;   endfor

    if setplot eq 'ps' then begin
       lc=0
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='tidi_vec0307a+geos4+saber_'+sdate+'_ubar.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
    erase
    xyouts,.45,.95,sdatelabel+' Ubar',/normal,charsize=2,color=0,charthick=3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    nlvls=25
    level=-120.+10.*findgen(nlvls)
    col1=1+indgen(nlvls)*icolmax/nlvls
    !type=2^2+2^3
    contour,tidi_ubar,latbin,alt_retrieved,charsize=1.5,/noeras,ytitle='Altitude',xticks=1,$
            xtickname=[' ',' '],levels=level,c_color=col1,/cell_fill,color=0,min_value=-999.,yrange=[70.,120.]
    index=where(level gt 0.)
    contour,tidi_ubar,latbin,alt_retrieved,levels=level(index),color=0,/follow,/noeras,/overplot
    index=where(level lt 0.)
    contour,tidi_ubar,latbin,alt_retrieved,levels=level(index),color=icolmax,/follow,/noeras,/overplot,$
            c_linestyle=5
    xyouts,0.,121.,'TIDI',/data,charsize=2,color=0,charthick=3,alignment=0.5

    if submeto eq 0L then begin
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    contour,ubarz,plat,altbin,charsize=1.5,/noeras,xtitle='Latitude',yrange=[min(altbin),max(altbin)],$
            levels=level,c_color=col1,/cell_fill,color=0,min_value=-999.,$
            ytickv=[10.,20.,30.,40.,50.,60.,70.],yticks=6
    index=where(level gt 0.)
    contour,ubarz,plat,altbin,levels=level(index),color=0,/follow,/noeras,/overplot
    index=where(level lt 0.)
    contour,ubarz,plat,altbin,levels=level(index),color=icolmax,/follow,/noeras,/overplot,c_linestyle=5
    xyouts,0.,5.,'GEOS-4',/data,charsize=2,color=0,charthick=3,alignment=0.5
    endif
    if submeto eq 1L then begin
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen-0.07
    set_viewport,xmn,xmx,ymn,ymx
    contour,ubarz,plat,altbin,charsize=1.5,/noeras,xtitle='Latitude',yrange=[min(altbin),60.],$
            levels=level,c_color=col1,/cell_fill,color=0,min_value=-999.,$
            ytickv=[10.,20.,30.,40.,50.,60.],yticks=5
    index=where(level gt 0.)
    contour,ubarz,plat,altbin,levels=level(index),color=0,/follow,/noeras,/overplot
    index=where(level lt 0.)
    contour,ubarz,plat,altbin,levels=level(index),color=icolmax,/follow,/noeras,/overplot,c_linestyle=5
    xyouts,0.,50.,'MetO',/data,charsize=2,color=0,charthick=3,alignment=0.5
    endif

    if sdum(0) ne '' then begin
    set_viewport,0.55,0.95,0.25,0.85
    contour,ubar_saber,alat,press,charsize=1.5,/noeras,xtitle='Latitude',yrange=[max(press),min(press)],/ylog,$
            levels=level,c_color=col1,/cell_fill,color=0,min_value=-999.
    index=where(level gt 0. and level lt 100.)
    contour,ubar_saber,alat,press,levels=level(index),color=0,/follow,/noeras,/overplot
    index=where(level lt 0. and level gt -100.)
    contour,ubar_saber,alat,press,levels=level(index),color=icolmax,/follow,/noeras,/overplot,c_linestyle=5
    xyouts,0.,min(press),'SABER',/data,charsize=2,color=0,charthick=3,alignment=0.5
    endif

    imin=min(level)
    imax=max(level)
    ymnb=yorig(1) -cbaryoff
    ymxb=ymnb  +cbarydel
    set_viewport,0.2,0.8,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,charsize=2,xtitle='(m/s)'
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
    endfor
    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim tidi_vec0307a+geos4+saber_'+sdate+'_ubar.ps -rotate -90 '+$
             ' tidi_vec0307a+geos4+saber_'+sdate+'_ubar.jpg'
    endif
    jump:
endfor		; loop over time steps
end
