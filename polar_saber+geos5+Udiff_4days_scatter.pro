;
; Plot polar projections of U, V, and isotachs from GEOS-5 and SABER and their differences
;
@kgmt
@rd_ukmo_nc3
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
xorig=[0.1825,0.4,0.7,0.1825,0.4,0.7,0.1825,0.4,0.7,0.1825,0.4,0.7]
yorig=[0.73,0.73,0.73,0.52,0.52,0.52,0.31,0.31,0.31,0.1,0.1,0.1]
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
nz=121
altitude=findgen(nz)
ralt=40.
;print,altitude
;read,'Enter desired altitude ',ralt
index=where(altitude eq ralt)
if index(0) eq -1L then stop,'Invalid latitude'
ialt=index(0)
salt=strcompress(long(altitude(ialt)),/remove_all)
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
   device,/landscape,bits=8,filename='polar_saber+geos5+Udiff_4day_'+salt+'_scatter.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
endif
spawn,'ls '+sdir+'*.sav',ncfiles
icount=0L
gcount=0L
nfile=n_elements(ncfiles)
for ifile=18L,nfile-1L do begin
;
; extract date
;
    result=strsplit(ncfiles(ifile),'/',/extract)
    result2=strsplit(result(4),'.',/extract)
    sdate=result2(1)
    if sdate ne '20080124' and sdate ne '20080206' and sdate ne '20080215' and sdate ne '20080223' then goto,jump
syr=strmid(sdate,0,4)
smn=strmid(sdate,4,2)
sdy=strmid(sdate,6,2)
imn=long(smn)
idy=long(sdy)
;
; read GEOS4 marker
;
    rd_geos5_nc3_meto,dir+sdate+'_AVG.V01.nc3',nc,nr,nth,glon,glat,th,$
                 pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
    if iflag eq 1 then goto,jump
    index=where(mark2 lt -1.)
    if index(0) ne -1L then mark2(index)=-1.0*(mark2(index)/mark2(index))
    t2=0.*pv2
    for k=0,nth-1 do t2(*,*,k)=th(k)*((p2(*,*,k)/1000.)^(.286))
    z2=(msf2-1004.*t2)/(9.86*1000.)
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
;
; compute zonal mean T, U, Z
;
    nlat=n_elements(alat)
    nlg=n_elements(alon)
    nlv=n_elements(press)
    p=press
;
; interpolate GEOS T, U to height surfaces user entered altitude
;
    tz_geos5=fltarr(nc,nr)
    uz_geos5=fltarr(nc,nr)
    markz_geos5=fltarr(nc,nr)
    tz_saber=fltarr(nlg,nlat)
    uz_saber=fltarr(nlg,nlat)
    zz=ralt
    for i=0L,nc-1L do begin
    for j=0L,nr-1L do begin
        zprof=reform(z2(j,i,*))
        for k=1L,nth-1L do begin
            zup=zprof(k-1) & zlw=zprof(k)	; profiles are top down
            if zup ge zz and zlw le zz then begin
               zscale=(zup-zz)/(zup-zlw)
               tz_geos5(i,j)=t2(j,i,k-1)+zscale*(t2(j,i,k)-t2(j,i,k-1))
               uz_geos5(i,j)=u2(j,i,k-1)+zscale*(u2(j,i,k)-u2(j,i,k-1))
               markz_geos5(i,j)=mark2(j,i,k-1)+zscale*(mark2(j,i,k)-mark2(j,i,k-1))
            endif
        endfor
    endfor
    endfor
    for ii=0L,nlg-1L do begin
    for jj=0L,nlat-1L do begin
        zprof=reform(zdata(ii,jj,*))
        for k=1L,nlv-1L do begin
            zup=zprof(k) & zlw=zprof(k-1)	; profiles are bottom up
            if zup ge zz and zlw le zz then begin
               zscale=(zup-zz)/(zup-zlw)
               tz_saber(ii,jj)=tdata(ii,jj,k-1)+zscale*(tdata(ii,jj,k)-tdata(ii,jj,k-1))
               uz_saber(ii,jj)=udata(ii,jj,k-1)+zscale*(udata(ii,jj,k)-udata(ii,jj,k-1))
            endif
        endfor
    endfor
    endfor
;
; interpolate GEOS-5 to SABER horizontal grid for differencing
;
    tz_geos5s=fltarr(nlg,nlat)
    uz_geos5s=fltarr(nlg,nlat)
    for ii=0L,nlg-1L do begin
        xpt=alon(ii)
        for jj=0L,nlat-1L do begin
            ypt=alat(jj)
            for j=0L,nr-2L do begin
                jp1=j+1
                if glat(j) lt ypt and glat(jp1) ge ypt then begin
                   yscale=(glat(jp1)-ypt)/(glat(jp1)-glat(j))

                   for i=0L,nc-2L do begin
                       ip1=i+1
                       if glon(i) lt xpt and glon(ip1) ge xpt then begin
                          xscale=(glon(ip1)-xpt)/(glon(ip1)-glon(i))

                          uj1=uz_geos5(i,j)+xscale*(uz_geos5(ip1,j)-uz_geos5(i,j))
                          ujp1=uz_geos5(i,jp1)+xscale*(uz_geos5(ip1,jp1)-uz_geos5(i,jp1))
                          uz_geos5s(ii,jj)=uj1+yscale*(ujp1-uj1)

;print,glon(i),xpt,glon(ip1),xscale
;print,glat(j),ypt,glat(jp1),yscale
;print,uz_geos5(i,j),uz_geos5s(ii,jj),uz_geos5(i,j)
;stop
                       endif
                   endfor
if xpt lt glon(0) then begin
   ip1=0 & i=nc-1
   xscale=(glon(ip1)-xpt)/(glon(ip1)-glon(i))
   uj1=uz_geos5(i,j)+xscale*(uz_geos5(ip1,j)-uz_geos5(i,j))
   ujp1=uz_geos5(i,jp1)+xscale*(uz_geos5(ip1,jp1)-uz_geos5(i,jp1))
   uz_geos5s(ii,jj)=uj1+yscale*(ujp1-uj1)
endif

                endif

             endfor
        endfor
    endfor
;
; add wrap-around point in longitude for plotting
;
    tgeos5=fltarr(nc+1,nr)
    ugeos5=fltarr(nc+1,nr)
    markgeos5=fltarr(nc+1,nr)
    tsaber=fltarr(nlg+1,nlat)
    usaber=fltarr(nlg+1,nlat)
    ugeos5s=fltarr(nlg+1,nlat)
    tgeos5(0:nc-1,0:nr-1)=tz_geos5
    markgeos5(0:nc-1,0:nr-1)=markz_geos5
    ugeos5(0:nc-1,0:nr-1)=uz_geos5
    tsaber(0:nlg-1,0:nlat-1)=tz_saber
    usaber(0:nlg-1,0:nlat-1)=uz_saber
    ugeos5s(0:nlg-1,0:nlat-1)=uz_geos5s
    tgeos5(nc,*)=tgeos5(0,*)
    markgeos5(nc,*)=markgeos5(0,*)
    ugeos5(nc,*)=ugeos5(0,*)
    tsaber(nlg,*)=tsaber(0,*)
    usaber(nlg,*)=usaber(0,*)
    ugeos5s(nlg,*)=ugeos5s(0,*)
    alon2=fltarr(nlg+1)
    alon2(0:nlg-1)=alon
    alon2(nlg)=alon2(0)
    glon2=fltarr(nc+1)
    glon2(0:nc-1)=glon
    glon2(nc)=glon2(0)
;
;index=where(ubarz_yt_saber eq 0.)
;if index(0) ne -1L then ubarz_yt_saber(index)=-999.
;
; day 1
;
if imn eq 1 and idy eq 24 then begin
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
    xyouts,xorig(0)-0.02,ymn+0.05,sdate,charsize=1.5,charthick=2,/normal,orientation=90,color=0
    contour,ugeos5s,alon2,alat,/noeras,levels=level,c_color=col1,/cell_fill,min_value=-999,/overplot
    contour,ugeos5s,alon2,alat,/noeras,/overplot,levels=level,color=0,min_value=-999
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[0.1],color=0,min_value=-999,thick=5
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[-0.1],color=mcolor,min_value=-999,thick=5
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/ortho,/noerase,color=0,title='SABER',charsize=1.5
    contour,usaber,alon2,alat,/noeras,levels=level,c_color=col1,/cell_fill,min_value=-999,/overplot
    contour,usaber,alon2,alat,charsize=1.5,/noeras,/overplot,levels=level,color=0,min_value=-999
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[0.1],color=0,min_value=-999,thick=5
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[-0.1],color=mcolor,min_value=-999,thick=5
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    xmn=xorig(2)
    xmx=xorig(2)+xlen
    ymn=yorig(2)
    ymx=yorig(2)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    index=where(ugeos5s ne 0. and usaber ne 0.)
    plot,usaber(index),ugeos5s(index),color=0,psym=4,ytitle='GEOS-5',$
         xrange=[min(level),max(level)],yrange=[min(level),max(level)],xtickname=[' ',' ',' ',' ',' ']
    oplot,level,level,psym=0,color=0
endif
;
; day 2
;
if imn eq 2 and idy eq 6 then begin
    level=-100.+10.*findgen(21)
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*mcolor/nlvls
    !type=2^2+2^3
    xmn=xorig(3)
    xmx=xorig(3)+xlen
    ymn=yorig(3)
    ymx=yorig(3)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/ortho,/noerase,color=0
    xyouts,xorig(0)-0.02,ymn+0.05,sdate,charsize=1.5,charthick=2,/normal,orientation=90,color=0
    contour,ugeos5s,alon2,alat,/noeras,levels=level,c_color=col1,/cell_fill,min_value=-999,/overplot
    contour,ugeos5s,alon2,alat,/noeras,/overplot,levels=level,color=0,min_value=-999
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[0.1],color=0,min_value=-999,thick=5
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[-0.1],color=mcolor,min_value=-999,thick=5
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    xmn=xorig(4)
    xmx=xorig(4)+xlen
    ymn=yorig(4)
    ymx=yorig(4)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/ortho,/noerase,color=0
    contour,usaber,alon2,alat,/noeras,levels=level,c_color=col1,/cell_fill,min_value=-999,/overplot
    contour,usaber,alon2,alat,charsize=1.5,/noeras,/overplot,levels=level,color=0,min_value=-999
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[0.1],color=0,min_value=-999,thick=5
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[-0.1],color=mcolor,min_value=-999,thick=5
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    xmn=xorig(5)
    xmx=xorig(5)+xlen
    ymn=yorig(5)
    ymx=yorig(5)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    index=where(ugeos5s ne 0. and usaber ne 0.)
    plot,usaber(index),ugeos5s(index),color=0,psym=4,ytitle='GEOS-5',$
         xrange=[min(level),max(level)],yrange=[min(level),max(level)],xtickname=[' ',' ',' ',' ',' ']
    oplot,level,level,psym=0,color=0
endif
;
; day 3
;
if imn eq 2 and idy eq 15 then begin
    level=-100.+10.*findgen(21)
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*mcolor/nlvls
    !type=2^2+2^3
    xmn=xorig(6)
    xmx=xorig(6)+xlen
    ymn=yorig(6)
    ymx=yorig(6)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    xyouts,xorig(0)-0.02,ymn+0.05,sdate,charsize=1.5,charthick=2,/normal,orientation=90,color=0
    map_set,90,0,-90,/ortho,/noerase,color=0
    contour,ugeos5s,alon2,alat,/noeras,levels=level,c_color=col1,/cell_fill,min_value=-999,/overplot
    contour,ugeos5s,alon2,alat,/noeras,/overplot,levels=level,color=0,min_value=-999
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[0.1],color=0,min_value=-999,thick=5
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[-0.1],color=mcolor,min_value=-999,thick=5
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    xmn=xorig(7)
    xmx=xorig(7)+xlen
    ymn=yorig(7)
    ymx=yorig(7)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/ortho,/noerase,color=0
    contour,usaber,alon2,alat,/noeras,levels=level,c_color=col1,/cell_fill,min_value=-999,/overplot
    contour,usaber,alon2,alat,charsize=1.5,/noeras,/overplot,levels=level,color=0,min_value=-999
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[0.1],color=0,min_value=-999,thick=5
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[-0.1],color=mcolor,min_value=-999,thick=5
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    xmn=xorig(8)
    xmx=xorig(8)+xlen
    ymn=yorig(8)
    ymx=yorig(8)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    index=where(ugeos5s ne 0. and usaber ne 0.)
    plot,usaber(index),ugeos5s(index),color=0,psym=4,ytitle='GEOS-5',$
         xrange=[min(level),max(level)],yrange=[min(level),max(level)],xtickname=[' ',' ',' ',' ',' ']
    oplot,level,level,psym=0,color=0
endif
;
; day 4
;
if imn eq 2 and idy eq 23 then begin
    level=-100.+10.*findgen(21)
    nlvls=n_elements(level)
    col1=1+indgen(nlvls)*mcolor/nlvls
    !type=2^2+2^3
    xmn=xorig(9)
    xmx=xorig(9)+xlen
    ymn=yorig(9)
    ymx=yorig(9)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/ortho,/noerase,color=0
    xyouts,xorig(0)-0.02,ymn+0.05,sdate,charsize=1.5,charthick=2,/normal,orientation=90,color=0
    contour,ugeos5s,alon2,alat,/noeras,levels=level,c_color=col1,/cell_fill,min_value=-999,/overplot
    contour,ugeos5s,alon2,alat,/noeras,/overplot,levels=level,color=0,min_value=-999
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[0.1],color=0,min_value=-999,thick=5
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[-0.1],color=mcolor,min_value=-999,thick=5
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    imin=min(level)
    imax=max(level)
    ymnb=ymn -cbaryoff
    ymxb=ymnb  +cbarydel
    set_viewport,xmn,xmx,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle=salt+' km Ubar (m/s)',color=0
    ybox=[0,10,10,0,0]
    x1=imin
    dxx=(imax-imin)/float(nlvls)
    for jj=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dxx,x1+dxx,x1]
        polyfill,xbox,ybox,color=col1(jj)
        x1=x1+dxx
    endfor
    xmn=xorig(10)
    xmx=xorig(10)+xlen
    ymn=yorig(10)
    ymx=yorig(10)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,-90,/ortho,/noerase,color=0
    contour,usaber,alon2,alat,/noeras,levels=level,c_color=col1,/cell_fill,min_value=-999,/overplot
    contour,usaber,alon2,alat,charsize=1.5,/noeras,/overplot,levels=level,color=0,min_value=-999
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[0.1],color=0,min_value=-999,thick=5
    contour,markgeos5,glon2,glat,/noeras,/overplot,levels=[-0.1],color=mcolor,min_value=-999,thick=5
    map_set,90,0,-90,/ortho,/noerase,/contin,/grid,color=0
    imin=min(level)
    imax=max(level)
    ymnb=ymn -cbaryoff
    ymxb=ymnb  +cbarydel
    set_viewport,xmn,xmx,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle=salt+' km Ubar (m/s)',color=0
    ybox=[0,10,10,0,0]
    x1=imin
    dxx=(imax-imin)/float(nlvls)
    for jj=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dxx,x1+dxx,x1]
        polyfill,xbox,ybox,color=col1(jj)
        x1=x1+dxx
    endfor
    xmn=xorig(11)
    xmx=xorig(11)+xlen
    ymn=yorig(11)
    ymx=yorig(11)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !type=2^2+2^3
    index=where(ugeos5s ne 0. and usaber ne 0.)
    plot,usaber(index),ugeos5s(index),color=0,psym=4,xtitle='SABER',ytitle='GEOS-5',$
         xrange=[min(level),max(level)],yrange=[min(level),max(level)]
    oplot,level,level,psym=0,color=0
endif
    jump:
endfor          ; loop over time steps
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim polar_saber+geos5+Udiff_4day_'+salt+'_scatter.ps '+$
         ' -rotate -90 polar_saber+geos5+Udiff_4day_'+salt+'_scatter.jpg'
endif
end
