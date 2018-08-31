;
; plot 12 yearly hovmollers in a 12 panel plot at a given latitude and altitude
;
loadct,38
device,decompose=0
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
a=findgen(8)*(2*!pi/8.)
usersym,2*cos(a),2*sin(a),/fill
npp=12
delta='n'
gcm_panels,npp,delta,nxdim,nydim,xorig,yorig,xlen,ylen,cbaryoff,cbarydel
set_plot,'x'
setplot='x'
read,'setplot=',setplot
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
pi2 = 6.2831853071796
dtr=pi2/360.
re=6.37E3
dir='/aura2/harvey/Hovmoller/Datfiles/'
ifiles=[$
;'ukmo_jan_01_92-dec_31_92_nc3_xt.sav',$
'ukmo_jan_01_93-dec_31_93_nc3_xt.sav',$
'ukmo_jan_01_94-dec_31_94_nc3_xt.sav',$
'ukmo_jan_01_95-dec_31_95_nc3_xt.sav',$
'ukmo_jan_01_96-dec_31_96_nc3_xt.sav',$
'ukmo_jan_01_97-dec_31_97_nc3_xt.sav',$
'ukmo_jan_01_98-dec_31_98_nc3_xt.sav',$
'ukmo_jan_01_99-dec_31_99_nc3_xt.sav',$
'ukmo_jan_01_00-dec_31_00_nc3_xt.sav',$
'ukmo_jan_01_01-dec_31_01_nc3_xt.sav',$
'ukmo_jan_01_02-dec_31_02_nc3_xt.sav',$
'ukmo_jan_01_03-dec_31_03_nc3_xt.sav',$
'ukmo_jan_01_04-dec_31_04_nc3_xt.sav']
nyear=n_elements(ifiles)
syear=[$
'1993',$
'1994',$
'1995',$
'1996',$
'1997',$
'1998',$
'1999',$
'2000',$
'2001',$
'2002',$
'2003',$
'2004']
nday=365L
for n=0,nyear-1L do begin 
    restore,dir+ifiles(n)
    print,'restored ',ifiles(n)
    nc=n_elements(alon)
    nfile=n_elements(sfile)
    x2d=fltarr(nc,nfile)
    y2d=fltarr(nc,nfile)
    for i=0,nc-1 do y2d(i,*)=findgen(nfile)
    for j=0,nfile-1 do x2d(*,j)=alon
;
; first year only
;
    if n eq 0L then begin
       nth=n_elements(th2)
       nr=n_elements(YMIDS)
       rlat=0.
       print,ymids
       read,'Enter desired latitude ',rlat
       index=where(ymids eq rlat)
       ilat=index(0)
       ralt=0.
       print,th2
       read,'Enter desired altitude ',ralt
       index=where(th2 eq ralt)
       ialt=index(0)
       sth=strcompress(string(fix(th2(ialt))),/remove_all)
       if ymids(ilat) eq 0. then slat='Eq'
       if ymids(ilat) gt 0. then slat=strcompress(string(ymids(ilat)),/remove_all)+'N'
       if ymids(ilat) lt 0. then slat=strcompress(string(ymids(ilat)),/remove_all)+'S'
       if setplot eq 'ps' then begin
          lc=0
          set_plot,'ps'
          xsize=nxdim/100.
          ysize=nydim/100.
          !p.font=0
          device,font_size=9
          device,/landscape,bits=8,filename='hov_Tprmark_'+sth+'K_'+slat+'_12pan.ps'
          device,/color
          device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
       endif
       erase
       xyouts,.25,.95,'MetO Temperature '+sth+' K '+slat,/normal,charsize=3
    endif
;
; extract desired latitude-altitude
;
    plt=reform(tmpxt(*,*,ilat,ialt),nc,nfile)
    plt1=reform(markxt(*,*,ilat,ialt),nc,nfile)
    uplt=reform(uxt(*,*,ilat,ialt),nc,nfile)
    plt1=smooth(plt1,5)
;
; plot yearly Hovs at ilat and ialt
;
    xmn=xorig(n)
    xmx=xorig(n)+xlen
    ymn=yorig(n)
    ymx=yorig(n)+ylen
    !type=2^2+2^3
    set_viewport,xmn,xmx,ymn,ymx
print,max(plt),min(plt)
    imin=230.
    imax=270.
    nlev=10
loadct,38
    col1=1.0+(findgen(nlev)/nlev)*mcolor
    cint=(imax-imin)/(nlev-1.)
    level=imin+cint*findgen(nlev)
    index=where(strmid(sfile,4,2) eq '01',nytick)
    contour,plt,alon,findgen(nfile),xrange=[0.,360.],/fill,$
            /cell_fill,yrange=[0,nfile-1L],xstyle=1,ystyle=1,xticks=6,$
            yticks=nytick-1,ytickv=index,ytickname=strmid(sfile(index),0,3),c_color=col1,$
            title=syear(n),/noeras,levels=level,charsize=1.5,min_value=-9999.
;contour,plt,alon,findgen(nfile),/overplot,/follow,levels=level,$
;           c_color=0,c_labels=0*level,/noeras
    contour,plt1,alon,findgen(nfile),/overplot,/follow,levels=[-0.01],$
            c_color=0,c_labels=0,thick=2,/noeras
    contour,plt1,alon,findgen(nfile),/overplot,/follow,levels=[0.01],$
            c_color=mcolor,c_labels=0,thick=2,/noeras
    index=where(plt1 lt 0.)
    if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=0,symsize=0.025
    index=where(plt1 gt 0.)
    if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=mcolor,symsize=0.025
;
; start parcel at the GM and loop over days
;
loadct,0
    xold=0.
    oplot,[xold,xold],[0,0],psym=8,symsize=0.75
    for nn=0L,nfile-1L do begin
;
; daily zonal wind at parcel location
;
        xindex=where(abs(xold-alon) eq min(abs(xold-alon)))
        uu=uplt(xindex(0),nn)
        dkm=uu*86400./1000.
        dx=re*cos(ymids(ilat)*dtr)*360.*dtr               ; km around latitude circle
        xnew=xold+ (dkm/dx)*360.
        if xnew gt 360. then xnew=xnew-360.
        if xnew lt 0. then xnew=xnew+360.
        if uu gt 0. then oplot,[xnew,xnew],[nn,nn],psym=8,color=mcolor*.45,symsize=0.325
        if uu lt 0. then oplot,[xnew,xnew],[nn,nn],psym=8,color=mcolor*.55,symsize=0.325
        xold=xnew
    endfor
;   xyouts,xmn,ymn-0.08,'Anticyclone (black)',charsize=2,/normal,color=lc
;   xyouts,xmn+0.45,ymn-0.08,'Polar Vortex (white)',charsize=2,/normal,color=lc
    if n eq nyear-1L then begin
loadct,38
        xmnb=xorig(n)+xlen+cbaryoff+0.02
        xmxb=xmnb+cbarydel
        set_viewport,xmnb,xmxb,ymn,ymx
        !type=2^2+2^3+2^5
        plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],/noeras,charsize=1.5
        xbox=[0,10,10,0,0]
        y1=imin
        dy=(imax-imin)/float(nlev)
        for jj=0,nlev-1 do begin
            ybox=[y1,y1,y1+dy,y1+dy,y1]
            polyfill,xbox,ybox,color=col1(jj)
            y1=y1+dy
        endfor
    endif
endfor
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim hov_Tprmark_'+sth+'K_'+slat+'_12pan.ps '+$
         '-rotate -90 hov_Tprmark_'+sth+'K_'+slat+'_12pan.jpg'
endif
end
