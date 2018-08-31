; temperature and vortex edge
;
@rd_ukmo_nc3
@rd_sage3_o3_soundings

ipan=0
npp=1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
setplot='ps'
read,'setplot=',setplot
nxdim=600
nydim=600
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.03
cbarydel=0.02
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
dirs='/aura3/data/SAGE_III_data/Sound_data/sage3_solar_'
ifile='                             '
close,1
openr,1,'polar_temp+mark+sage3.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    print,ifile
    iflag=0
    sfile=dirs+strmid(ifile,0,7)+'2002_o3.sound'
    rd_sage3_o3_soundings,sfile,norbit,tsage,xsage,ysage,$
       tropp,tropz,tropth,mode,o3sage,psage,thsage,zsage,$
       clsage,qo3sage,nlev
;   if norbit eq 0 then goto,jump

    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump

; Height of isentropic surface = (msf - cp*T)/g
; where T = theta* (p/po)^R/cp and divide by 1000 for km
    t2=0.*p2
    z2=0.*p2
    for k=0,nth-1 do begin
        t2(*,*,k) = th(k)*( (p2(*,*,k)/1000.)^(.286) )
        z2(*,*,k) = (msf2(*,*,k) - 1004.*t2(*,*,k))/(9.86*1000.)
    endfor

if n eq 0 then begin
theta=0.
print,th
read,'Enter theta ',theta
index=where(theta eq th)
if index(0) eq -1 then stop,'Invalid theta level '
thlev=index(0)
endif
        stheta=strcompress(string(fix(theta)),/remove_all)
        qdf1=transpose(qdf2(*,*,thlev))
        sf1=transpose(sf2(*,*,thlev))
        pv1=transpose(pv2(*,*,thlev))
        t1=transpose(t2(*,*,thlev))
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
        t=0.*fltarr(nc+1,nr)
        t(0:nc-1,0:nr-1)=t1(0:nc-1,0:nr-1)
        t(nc,*)=t(0,*)
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

        if ipan eq 0 and setplot eq 'ps' then begin
           lc=0
           set_plot,'ps'
           xsize=nxdim/100.
           ysize=nydim/100.
           !psym=0
           !p.font=0
           device,font_size=9
           device,/landscape,bits=8,$
                   filename='Figures/'+ifile+'_'+stheta+'K_t+mark+sage3.ps'
           device,/color
           device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                  xsize=xsize,ysize=ysize
        endif

; Set plot boundaries
;!p.multi=[npp-ipan,2,2]
erase
        !type=2^2+2^3
        !psym=0
        xmn=xorig(0)
        xmx=xorig(0)+xlen
        ymn=yorig(0)
        ymx=yorig(0)+ylen
        set_viewport,xmn,xmx,ymn,ymx
        MAP_SET,-90,0,-90,/ortho,/noeras,/grid,/contin,/noborder,$
                title='!6SAGE III Ozone + UKMO Temperature '+ifile+$
                '  '+stheta+' K',latdel=10
        !psym=3
        oplot,findgen(361),-0.1+0.*findgen(361)
;       if n eq 0 then begin
        index=where(lat lt 0.)
        sfmin=170.
        nlvls=20
        col1=1+indgen(nlvls)*icolmax/float(nlvls)
        sfint=5.
        sflevel=sfmin+sfint*findgen(nlvls)
;       endif
        contour,t,x,alat,/overplot,levels=sflevel,c_color=col1,thick=1,$
                /cell_fill,/noeras
        contour,t,x,alat,/overplot,levels=sflevel,/follow,color=0,$
                c_labels=0*sflevel
        contour,t,x,alat,/overplot,levels=[180,185,190,195],/follow,thick=5,$
                c_labels=[1,1,1,1],color=0,charsize=3
        MAP_SET,-90,0,-90,/ortho,/noeras,/grid,/contin,/noborder,latdel=10,$
                color=0

        lindex=where(lat lt 0. and marksfl eq 1)
        if lindex(0) ne -1 then begin
           dum=sf          ; SH
           sfmin=min(dum(lindex))
           ymax=max(lat(lindex))
           index=where(lat gt ymax+2.5)
           dum(index)=9999.
           contour,dum,x,alat,levels=sfmin,color=lc,max_value=1.,thick=10,$
                  /overplot
        endif
        index=where(lat lt 0. and marksfh lt 0.)
        if index(0) ne -1 then begin
        for i=0,abs(min(marksfh(index)))-1 do begin
            hindex=where(marksfh eq -1.*(i+1.) and lat lt 0.)
            xmin=min(lon(hindex))
            xmax=max(lon(hindex))
            ymin=min(lat(hindex))
            ymax=max(lat(hindex))
;           if ymin gt -20. then goto,skiphigh
            sedge=max(sf(hindex))
            tmp=sf
            if xmin ne x(0) or xmax ne x(nc) then begin
               index=where(lon lt xmin-3.75 or lon gt xmax+3.75 or $
                           lat lt ymin-2.5 or lat gt ymax+2.5)
               tmp(index)=9999.
            endif
            if xmin eq x(0) and xmax eq x(nc) then begin        ; spans GM
               index=where(lon lt 180. and marksfh eq -1.*(i+1.))
               xmax=max(lon(index))
               index=where(lon lt 180 and lon gt xmax+3.75)
               if index(0) ne -1 then tmp(index)=9999.
               index=where(lon gt 180. and marksfh eq -1.*(i+1.))
               xmin=min(lon(index))
               index=where(lon gt 180 and lon lt xmin-3.75)
               if index(0) ne -1 then tmp(index)=9999.
               index=where(lat lt ymin-2.5 or lat gt ymax+2.5)
               tmp(index)=9999.
            endif
            contour,tmp,x,alat,/overplot,levels=sedge,/noeras,color=0,$
                    max_value=9999.,thick=10
            skiphigh:
        endfor
        endif

        if norbit gt 0 then begin
           index=where(o3sage*1.e6 lt 10. and xsage ne -999. and ysage ne -999.,nobs)
           if index(0) ne -1 then begin
              thsage=thsage(index,*)
              o3sage=o3sage(index,*)*1.e6
              xsage=xsage(index)
              ysage=ysage(index)
              o3max=10.
              for iobs=0,nobs-1 do begin
                  dth=min(abs(thsage(iobs,*)-theta))
                  kindex=where(abs(thsage(iobs,*)-theta) eq dth)
                  a=findgen(8)*(2*!pi/8.)
                  usersym,cos(a),sin(a),/fill
                  oplot,[xsage(iobs),xsage(iobs)],$
                        [ysage(iobs),ysage(iobs)],psym=8,$
                         color=(o3sage(iobs,kindex(0))/o3max)*icolmax,symsize=2
                  a=findgen(10)*(2*!pi/10.)
                  usersym,cos(a),sin(a)
                  oplot,[xsage(iobs),xsage(iobs)],$
                        [ysage(iobs),ysage(iobs)],psym=8,$
                        color=0,symsize=2
              endfor
           endif

; Draw color bar
      imin=0.0
      imax=o3max
      ymnb=yorig(0) -cbaryoff
      ymxb=ymnb  +cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],$
            xtitle='!6(ppmv)'
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(icmm1)
      for j=1,icmm1 do begin
            xbox=[x1,x1,x1+dx,x1+dx,x1]
            polyfill,xbox,ybox,color=j
            x1=x1+dx
      endfor
      endif

;stop
ipan=ipan+1
if ipan ge npp then begin
   ipan=0
   if setplot eq 'ps' then device, /close
endif
    jump:
endfor		; loop over files
end
