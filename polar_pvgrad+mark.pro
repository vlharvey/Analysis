;
; reads in .nc3 and .nc4 marker field and plots polar orthographic
;
@rd_ukmo_nc3

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
device,decompose=0
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.5,0.0]
yorig=[0.25,0.25]
xlen=0.5
ylen=0.5
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
close,1
openr,1,'polar_pvgrad+mark.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    print,ifile
    iflag=0
    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
;
; meridional PV gradient calculation
;
pvgrad2=0*pv2
pvgrad4=0*pv2
dy2=2.*(alat(1)-alat(0))*!pi/180.
dy4=12.*(alat(1)-alat(0))*!pi/180.
for k=0,nth-1 do begin
for j=2,nr-3 do begin
    jm1=j-1
    jp1=j+1
    jm2=j-2
    jp2=j+2
    for i=0,nc-1 do begin
        pvgrad2(j,i,k) = (pv2(jp1,i,k)-pv2(jm1,i,k))/dy2	; 2nd order
        pvgrad4(j,i,k) = (-1.*pv2(jp2,i,k)+8.*pv2(jp1,i,k) $
                          -8.*pv2(jm1,i,k)+1.*pv2(jm2,i,k))/dy4	; 4th order
    endfor
endfor
pvgrad2(0,*,k)=pvgrad2(2,*,k)
pvgrad2(1,*,k)=pvgrad2(2,*,k)
pvgrad4(nr-2,*,k)=pvgrad2(nr-3,*,k)
pvgrad4(nr-1,*,k)=pvgrad2(nr-3,*,k)
endfor

if n eq 0 then begin
theta=0.
;print,th
;read,'Enter theta ',theta
theta=1600.
index=where(theta eq th)
if index(0) eq -1 then stop,'Invalid theta level '
thlev=index(0)
endif
        stheta=strcompress(string(fix(theta)),/remove_all)
        qdf1=transpose(qdf2(*,*,thlev))
        sf1=transpose(sf2(*,*,thlev))
        pv1=transpose(pv2(*,*,thlev))
        pvgrad1=transpose(pvgrad4(*,*,thlev))
        marksfl1=transpose(marksf2(*,*,thlev))
        marksfh1=transpose(marksf2(*,*,thlev))
        qdf=0.*fltarr(nc+1,nr)
        qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
        qdf(nc,*)=qdf(0,*)
        sf=0.*fltarr(nc+1,nr)
        sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
        sf(nc,*)=sf(0,*)
        pv=0.*fltarr(nc+1,nr)
        pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
        pv(nc,*)=pv(0,*)
        pvgrad=0.*fltarr(nc+1,nr)
        pvgrad(0:nc-1,0:nr-1)=pvgrad1(0:nc-1,0:nr-1)
        pvgrad(nc,*)=pvgrad(0,*)
        marksfl=0.*fltarr(nc+1,nr)
        marksfl(0:nc-1,0:nr-1)=marksfl1(0:nc-1,0:nr-1)
        marksfl(nc,*)=marksfl(0,*)
        marksfh=0.*fltarr(nc+1,nr)
        marksfh(0:nc-1,0:nr-1)=marksfh1(0:nc-1,0:nr-1)
        marksfh(nc,*)=marksfh(0,*)
        x=fltarr(nc+1)
        x(0:nc-1)=alon
        x(nc)=alon(0)+360.
        lon=0.*sf
        lat=0.*sf
        for i=0,nc   do lat(i,*)=alat
        for j=0,nr-1 do lon(*,j)=x

        if setplot eq 'ps' then begin
           set_plot,'ps'
           xsize=nxdim/100.
           ysize=nydim/100.
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                /bold,/color,bits_per_pixel=8,/helvetica,filename=ifile+'_'+stheta+'K_pvgrad+mark.ps'
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !p.charthick=5
         !y.thick=2
         !x.thick=2
        endif

; Set plot boundaries
        erase
        xmn=xorig(0)
        xmx=xorig(0)+xlen
        ymn=yorig(0)
        ymx=yorig(0)+ylen
        set_viewport,xmn,xmx,ymn,ymx
        xyouts,.3,.8,ifile+'  '+stheta+' K',/normal,charsize=3,color=0
        MAP_SET,90,0,-90,/ortho,/noeras,/contin,/noborder,charsize=2.0,color=0
        index=where(lat gt 0.)
        sfmin=min(pvgrad(index))
        sfmax=max(pvgrad(index))
sfmax=0.05
sfmin=-0.05
        nlvls=20
        sfint=(sfmax-sfmin)/nlvls
        sflevel=sfmin+sfint*findgen(nlvls)
        col1=1+indgen(nlvls)*mcolor/nlvls
        !psym=0
        contour,pvgrad,x,alat,/overplot,levels=sflevel,c_color=col1,/cell_fill,/noeras
index=where(sflevel gt 0.)
        contour,pvgrad,x,alat,/overplot,levels=sflevel(index),color=0
index=where(sflevel lt 0.)
        contour,pvgrad,x,alat,/overplot,levels=sflevel(index),color=mcolor,c_linestyle=5

;       index=where(pvgrad lt 0. and lat gt 0.)
;       if index(0) ne -1 then oplot,lon(index),lat(index),psym=2,color=0
      contour,marksfl,x,alat,/overplot,levels=[0.1],thick=10,color=0
      contour,marksfl,x,alat,/overplot,levels=[-0.1],thick=10,color=mcolor
        MAP_SET,90,0,-90,/ortho,/noeras,/contin,charsize=2.0

      imin=min(sflevel)
      imax=max(sflevel)
      ymnb=yorig(0)-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xorig(0)+0.1,xorig(0)+xlen-0.1,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,$
           xtitle='MetO '+stheta+' K PV Gradient'
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor


;       lindex=where(lat gt 0. and marksfl eq 1)
;       if lindex(0) ne -1 then begin
;          dum=sf          ; NH
;          sfmax=max(dum(lindex))
;          ymin=min(lat(lindex))
;          index=where(lat lt ymin-2.5)
;          dum(index)=9999.
;          contour,dum,x,alat,levels=sfmin,color=0,max_value=1.,thick=10,$
;                 /overplot
;       endif

      xmn=xorig(1)
      xmx=xorig(1)+xlen
      ymn=yorig(1)
      ymx=yorig(1)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,90,0,-90,/ortho,/noeras,/contin,title='PV',charsize=2.0,color=0
        index=where(lat gt 0.)
        sfmin=min(pv(index))
        sfmax=max(pv(index))
        nlvls=20
        sfint=(sfmax-sfmin)/nlvls
        sflevel=sfmin+sfint*findgen(nlvls)
        col1=1+indgen(nlvls)*mcolor/nlvls
        !psym=0
        contour,pv,x,alat,/overplot,levels=sflevel,c_color=col1,/cell_fill,/noeras
        contour,pv,x,alat,/overplot,levels=sflevel,color=0,c_linestyle=sflevel lt 0
        contour,pv,x,alat,/overplot,levels=[0],color=0,thick=5
      contour,marksfl,x,alat,/overplot,levels=[0.1],thick=10,color=0
      contour,marksfl,x,alat,/overplot,levels=[-0.1],thick=10,color=mcolor
        MAP_SET,90,0,-90,/ortho,/noeras,/contin,charsize=2.0

      imin=min(sflevel)
      imax=max(sflevel)
      ymnb=yorig(1)-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xorig(1)+0.1,xorig(1)+xlen-0.1,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,$
           xtitle='MetO '+stheta+' K PV'
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor


;       lindex=where(lat gt 0. and marksfl eq 1)
;       if lindex(0) ne -1 then begin
;          dum=sf          ; NH
;          sfmax=max(dum(lindex))
;          ymin=min(lat(lindex))
;          index=where(lat lt ymin-2.5)
;          dum(index)=9999.
;          contour,dum,x,alat,levels=sfmin,color=0,max_value=1.,thick=10,$
;                 /overplot
;       endif

      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device, /close
         spawn,'convert -trim '+ifile+'_'+stheta+'K_pvgrad+mark.ps -rotate -90 '+ifile+'_'+stheta+'K_pvgrad+mark.jpg'
      endif

    jump:
endfor		; loop over files
end
