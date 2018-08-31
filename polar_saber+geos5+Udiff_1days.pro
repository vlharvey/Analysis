;
; first interpolate GEOS to SABER locations and then to SABER grid
; Plot polar projections of U, V, and isotachs from GEOS-5 and SABER and their differences
;
@rd_geos5_nc3_meto

loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
!p.background=icolmax
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.15,0.4,0.65]
yorig=[0.4,.4,.4]
xlen=.2
ylen=.2
cbaryoff=0.02
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
smonth=['J','F','M','A','M','J','J','A','S','O','N','D']
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
sdir='/aura6/data/SABER_data/Datfiles_winds/GRID_PHI_WINDS.2008'
sddir='/aura6/data/SABER_data/Datfiles_SOSST/'
nz=121
altitude=findgen(nz)
ralt=40.
;print,altitude
;read,'Enter desired altitude ',ralt
index=where(altitude eq ralt)
if index(0) eq -1L then stop,'Invalid latitude'
ialt=index(0)
salt=strcompress(long(altitude(ialt)),/remove_all)
spawn,'ls '+sdir+'*.sav',ncfiles
nfile=n_elements(ncfiles)
for ifile=18L,nfile-1L do begin
;
; extract date
;
    result=strsplit(ncfiles(ifile),'/',/extract)
    result2=strsplit(result(4),'.',/extract)
    sdate=result2(1)
;
; postscript file
;
if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='polar_saber+geos5+Udiff_'+sdate+'_'+salt+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
;
; read GEOS data for matker field
;
;
; read GEOS-5 data
;
    rd_geos5_nc3_meto,dir+sdate+'_AVG.V01.nc3',nc,nr,nthg,glon,glat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
    if iflag eq 1 then goto,jump
    xgeos=fltarr(nc+1)
    xgeos(0:nc-1)=glon(0:nc-1)
    xgeos(nc)=glon(0)+360.
    t2=0.*pv2
    for k=0,nthg-1 do t2(*,*,k)=th(k)*((p2(*,*,k)/1000.)^(.286))
    z2=(msf2-1004.*t2)/(9.86*1000.)
;
; interpolate GEOS marker to altitude surfaces
;
    mark2z=fltarr(nr,nc)
    zz=ralt
    if max(z2) lt zz then goto,jumplev
    for j=0L,nr-1L do begin
    for i=0L,nc-1L do begin
        for k=1L,nthg-1L do begin
            zup=z2(j,i,k-1) & zlw=z2(j,i,k)
            if zup ne 0. and zlw ne 0. then begin
            if zup ge zz and zlw le zz then begin
               zscale=(zup-zz)/(zup-zlw)
               mark2z(j,i)=mark2(j,i,k-1)+zscale*(mark2(j,i,k)-mark2(j,i,k-1))
            endif
            endif
        endfor
    endfor
    endfor
    jumplev:

    syr=strmid(sdate,0,4)
    smn=strmid(sdate,4,2)
    sdy=strmid(sdate,6,2)
    imn=long(smn)
    idy=long(sdy)
;
; restore DMP file
;
; DATE            STRING    = '20080331'
; DYNTROP         FLOAT     = Array[1172]
; ELAT_PROF       FLOAT     = Array[1172, 42]
; ID              STRING    = Array[1398]
; LATITUDE        FLOAT     = Array[1172]
; LONGITUDE       FLOAT     = Array[1172]
; PTHERMTROP      FLOAT     = Array[1172]
; PV_PROF         FLOAT     = Array[1172, 42]
; P_PROF          FLOAT     = Array[1172, 42]
; THLEV           INT       = Array[42]
; THTHERMTROP     FLOAT     = Array[1172]
; TIME            FLOAT     = Array[1172]
; TP_PROF         FLOAT     = Array[1172, 42]
; U_PROF          FLOAT     = Array[1172, 42]
; VELAT_PROF      FLOAT     = Array[1172, 42, 3]
; V_PROF          FLOAT     = Array[1172, 42]
; ZTHERMTROP      FLOAT     = Array[1172]
; Z_PROF          FLOAT     = Array[1172, 42]
;
    dum=findfile(sddir+'dmps_saber_v1.07.geos5.'+sdate+'.sav')
    if dum(0) eq '' then goto,jump
    restore,sddir+'dmps_saber_v1.07.geos5.'+sdate+'.sav'
    nth=n_elements(thlev)
    nprof=n_elements(time)
;
; restore gridded SABER T, U, V, Z, data
;
; ALAT            FLOAT     = Array[35]
; ALON            FLOAT     = Array[12]
; PRESS           FLOAT     = Array[120]
; T3D             FLOAT     = Array[12, 35, 120]
; U3D             FLOAT     = Array[12, 35, 120]
; V3D             FLOAT     = Array[12, 35, 120]
; Z3D             FLOAT     = Array[12, 35, 120]
;
    restore,ncfiles(ifile)
    print,ncfiles(ifile)
    tdata=t3d   ; avoid T3D intrinsic function
    udata=u3d 
;   if max(tdata) eq 0. then goto,jump
    zdata=z3d/1000.
    dlon=(alon(1)-alon(0))/2.
    dlat=(alat(1)-alat(0))/2.
;
; compute zonal mean T, U, Z
;
    nlat=n_elements(alat)
    nlg=n_elements(alon)
    nlv=n_elements(press)
    p=press
;
; interpolate GEOS (from theta) and SABER (from pressure) T, U to user entered altitude level
;
    polart_geos5=fltarr(nlg,nlat)
    polaru_geos5=fltarr(nlg,nlat)
    polarn_geos5=lonarr(nlg,nlat)
    polart_saber=fltarr(nlg,nlat)
    polaru_saber=fltarr(nlg,nlat)
    for iprof=0L,nprof-1L do begin
        zprof=reform(z_prof(iprof,*))
        tprof=reform(tp_prof(iprof,*))
        uprof=reform(u_prof(iprof,*))
        xp=longitude(iprof)
        if xp gt alon(nlg-1)+dlon then xp=xp-360.
        yp=latitude(iprof)
        for i=0L,nlg-1L do begin
            if alon(i)-dlon lt xp and alon(i)+dlon ge xp then begin
            for j=0L,nlat-1L do begin
            if alat(j)-dlat lt yp and alat(j)+dlat ge yp then begin
               for k=1L,nth-1L do begin
                   zup=zprof(k-1) & zlw=zprof(k)	; profiles are top down
                   if zup ge zz and zlw le zz then begin
                      zscale=(zup-zz)/(zup-zlw)
                      polart_geos5(i,j)=polart_geos5(i,j)+(tprof(k-1)+zscale*(tprof(k)-tprof(k-1)))
                      polaru_geos5(i,j)=polaru_geos5(i,j)+(uprof(k-1)+zscale*(uprof(k)-uprof(k-1)))
                      polarn_geos5(i,j)=polarn_geos5(i,j)+1L
;print,alon(i)-dlon,xp,alon(i)+dlon
;print,alat(j)-dlat,yp,alat(j)+dlat
;print,polarn_geos5(i,j),iprof
;stop
                   endif
               endfor
            endif
            endfor
            endif
        endfor
    endfor
    index=where(polarn_geos5 gt 0L)
    if index(0) ne -1L then polart_geos5(index)=polart_geos5(index)/float(polarn_geos5(index))
    if index(0) ne -1L then polaru_geos5(index)=polaru_geos5(index)/float(polarn_geos5(index))

    for ii=0L,nlg-1L do begin
    for jj=0L,nlat-1L do begin
        zprof=reform(zdata(ii,jj,*))
        for k=1L,nlv-1L do begin
            zup=zprof(k) & zlw=zprof(k-1)	; profiles are bottom up
            if zup ge zz and zlw le zz then begin
               zscale=(zup-zz)/(zup-zlw)
               polart_saber(ii,jj)=tdata(ii,jj,k-1)+zscale*(tdata(ii,jj,k)-tdata(ii,jj,k-1))
               polaru_saber(ii,jj)=udata(ii,jj,k-1)+zscale*(udata(ii,jj,k)-udata(ii,jj,k-1))
            endif
        endfor
    endfor
    endfor
;
; add wrap-around point in longitude for plotting
;
    mark1=transpose(mark2z(*,*))
    mark=fltarr(nc+1,nr)
    mark(0:nc-1,0:nr-1)=mark1
    mark(nc,*)=mark(0,*)
    tgeos5=fltarr(nlg+1,nlat)
    ugeos5=fltarr(nlg+1,nlat)
    tsaber=fltarr(nlg+1,nlat)
    usaber=fltarr(nlg+1,nlat)
    tgeos5(0:nlg-1,0:nlat-1)=polart_geos5
    ugeos5(0:nlg-1,0:nlat-1)=polaru_geos5
    tsaber(0:nlg-1,0:nlat-1)=polart_saber
    usaber(0:nlg-1,0:nlat-1)=polaru_saber
    tgeos5(nlg,*)=tgeos5(0,*)
    ugeos5(nlg,*)=ugeos5(0,*)
    tsaber(nlg,*)=tsaber(0,*)
    usaber(nlg,*)=usaber(0,*)
    alon2=fltarr(nlg+1)
    alon2(0:nlg-1)=alon
    alon2(nlg)=alon2(0)
    erase
    level=-100.+10.*findgen(21)
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*mcolor/nlvls
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/ortho,/noerase,color=0,title='GEOS-5',charsize=1.5
    xyouts,0.45,yorig(0)+ylen+0.05,sdate,charsize=2,charthick=2,/normal,color=0
    contour,ugeos5,alon2,alat,/noeras,levels=level,c_color=col1,/cell_fill,min_value=-999,/overplot
    contour,ugeos5,alon2,alat,/noeras,/overplot,levels=level,color=0,min_value=-999
    contour,mark,xgeos,glat,/overplot,levels=[0.1],/follow,color=0,c_labels=0*level,thick=10
    loadct,0
    contour,mark,xgeos,glat,/overplot,levels=[-0.1],/follow,color=125,c_labels=0*level,thick=10
    loadct,39
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    imin=min(level)
    imax=max(level)
    ymnb=ymn -cbaryoff
    ymxb=ymnb  +cbarydel
    set_viewport,xmn,xmx,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle=salt+' km U (m/s)',color=0,charthick=2
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for jj=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(jj)
        x1=x1+dx
    endfor
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/ortho,/noerase,color=0,title='SABER',charsize=1.5
    contour,usaber,alon2,alat,/noeras,levels=level,c_color=col1,/cell_fill,min_value=-999,/overplot
    contour,usaber,alon2,alat,charsize=1.5,/noeras,/overplot,levels=level,color=0,min_value=-999
    contour,mark,xgeos,glat,/overplot,levels=[0.1],/follow,color=0,c_labels=0*level,thick=10
    loadct,0
    contour,mark,xgeos,glat,/overplot,levels=[-0.1],/follow,color=125,c_labels=0*level,thick=10
    loadct,39
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    imin=min(level)
    imax=max(level)
    ymnb=ymn -cbaryoff
    ymxb=ymnb  +cbarydel
    set_viewport,xmn,xmx,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle=salt+' km U (m/s)',color=0,charthick=2
    ybox=[0,10,10,0,0]
    x1=imin
    dx=(imax-imin)/float(nlvls)
    for jj=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(jj)
        x1=x1+dx
    endfor
    restore,'c11_rb.tbl'
    tvlct,c1,c2,c3
    col2=1+indgen(11)
    pdiff=-99.+0.*ugeos5
    index=where(usaber ne 0. and ugeos5 ne 0.)
    if index(0) eq -1L then goto,jump
    pdiff(index)=ugeos5(index)-usaber(index)
    pdiff=smooth(pdiff,3)
    level=-25.+5.*findgen(11)
    !type=2^2+2^3
    xmn=xorig(2)
    xmx=xorig(2)+xlen
    ymn=yorig(2)
    ymx=yorig(2)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/ortho,/noerase,color=0,title='GEOS-5 - SABER',charsize=1.5
    contour,pdiff,alon2,alat,levels=level,/cell_fill,c_color=col2,color=0,min_value=-99.,/overplot
    contour,pdiff,alon2,alat,/overplot,levels=level,color=0,/follow,min_value=-99.,c_labels=0*level
    contour,pdiff,alon2,alat,/overplot,levels=[0],color=0,thick=1,min_value=-99.
    contour,mark,xgeos,glat,/overplot,levels=[0.1],/follow,color=0,c_labels=0*level,thick=10
    loadct,0
    contour,mark,xgeos,glat,/overplot,levels=[-0.1],/follow,color=125,c_labels=0*level,thick=10
    loadct,39
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    imin=min(level)
    imax=max(level)
    ymnb=ymn -cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn,xmx,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,$
          xtitle=salt+' km Differences (m/s)',xticks=n_elements(level)/2,color=0,charthick=2
    ybox=[0,10,10,0,0]
    x2=imin
    restore,'c11_rb.tbl'
    tvlct,c1,c2,c3
    col2=1+indgen(11)
    dx=(imax-imin)/(float(n_elements(col2)))
    for jj=0L,n_elements(col2)-1 do begin
        xbox=[x2,x2,x2+dx,x2+dx,x2]
        polyfill,xbox,ybox,color=col2(jj)
        x2=x2+dx
    endfor
    loadct,39
    jump:
    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim polar_saber+geos5+Udiff_'+sdate+'_'+salt+'.ps '+$
             ' -rotate -90 polar_saber+geos5+Udiff_'+sdate+'_'+salt+'.jpg'
    endif
endfor          ; loop over time steps
end
