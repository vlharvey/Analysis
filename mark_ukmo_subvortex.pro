;
; use MPV to mark the subvortex  VLH 8/6/2003
;
@rd_ukmo_nc3
@write_ukmo_subvortex
loadct,38
mcolor=!p.color
icolmax=byte(!p.color)
icmm1=icolmax-1B
icmm2=icolmax-2B
nlvls=31
col1=1+indgen(nlvls)*icolmax/nlvls
!NOERAS=-1
!P.FONT=0
SETPLOT='x'
;read,'setplot',setplot
; define viewport location
nxdim=750
nydim=750
xorig=[0.30,0.10,0.55]
yorig=[0.55,0.13,0.13]
xlen=0.4
ylen=0.4
cbaryoff=0.06
cbarydel=0.01
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/usr72/users/ukmo/Datfiles/ukmo_'
ifile='                             '
close,1
openr,1,'mark_ukmo_subvortex.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    if n eq 0 then ifile0=ifile
    iflag=0
    rd_ukmo_nc3,dir+ifile+'_solve2.nc3',nc,nr,nth,alon,alat,th,$
;   rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
    x=fltarr(nc+1)
    x(0:nc-1)=alon(0:nc-1)
    x(nc)=alon(0)+360.
    s2=sqrt(u2^2+v2^2)
    xlon=alon
    xlat=alat
;
; Height of isentropic surface = (msf - cp*T)/g
; where T = theta* (p/po)^R/cp and divide by 1000 for km
;
    t2=0.*p2
    z2=0.*p2
    for k=0,nth-1 do begin
        t2(*,*,k) = th(k)*( (p2(*,*,k)/1000.)^(.286) )
        z2(*,*,k) = (msf2(*,*,k) - 1004.*t2(*,*,k))/(9.86*1000.)
    endfor
;
; modified PV
;
    pv2=smooth(pv2,3,/edge_truncate)
    mpv2=0.*pv2
    th0=300.
    for k=0,nth-1 do mpv2(*,*,k)=pv2(*,*,k)*( (th(k)/th0) )^(-9./2.)
;
; choose mpv co-located with maximum pv gradients at each level 
; not zonal mean Dpv/Dy but loop around longitudes to find max
;
    pvgrad2=0.*pv2
    kindex=where(th le 600. and th ge 300.,nth2)
    th2=fltarr(nth)
    mpv0=fltarr(nth)
    pvgradmax=fltarr(nth)
    for k=kindex(0),kindex(nth2-1) do begin
        pv1=transpose(pv2(*,*,k))
        s1=transpose(s2(*,*,k))
        mpv1=transpose(mpv2(*,*,k))
        pvmax=max(abs(pv1))
        pvgrad1=pv1*0.0
        for j = 0, nr-1 do begin
            jm1=j-1
            jp1=j+1
            if j eq 0 then jm1=0
            if j eq 0 then dy2=(xlat(1)-xlat(0))*!pi/180.
            if j eq nr-1 then jp1=nr-1
            if j eq nr-1 then dy2=(xlat(nr-1)-xlat(nr-2))*!pi/180.
            if (j gt 0 and j lt nr-1) then dy2=(xlat(jp1)-xlat(jm1))*!pi/180.
            csy=cos(xlat(j)*!pi/180.)
            for i = 0, nc-1 do begin
                ip1 = i+1
                im1 = i-1
                if i eq 0 then im1 = nc-1
                if i eq 0 then dx2 = (xlon(1)-xlon(0))*!pi/180.
                if i eq nc-1 then ip1 = 0
                if i eq nc-1 then dx2 = (xlon(0)-xlon(nc-1))*!pi/180.
                if (i gt 0 and i lt nc-1) then dx2=(xlon(ip1)-xlon(im1))*!pi/180.

                dqdx = (pv1(ip1,j)-pv1(im1,j))/(dx2*csy)
                dqdy = (pv1(i,jp1)-pv1(i,jm1))/dy2
                pvgrad1(i,j) = sqrt(dqdx*dqdx+dqdy*dqdy)
                if (dqdy le 0.0) then pvgrad1(i,j) = -1.0*pvgrad1(i,j)
            endfor
        endfor
        pvgrad2(*,*,k)=transpose(pvgrad1)
;
; investigate method
;
;       erase
;       sth=strcompress(string(fix(th(k))),/remove_all)
;       set_viewport,.1,.9,.1,.9
;       mtitle='!6'+sth+' K UKMO PV on '+ifile
;       !psym=0
;       !type=2^2+2^3
;       MAP_SET,90,0,-90,/stereo,/noeras,title=mtitle,color=lc,/contin,/grid
;       oplot,findgen(361),.1+0.*findgen(361),psym=3
        pvgrad=0.*fltarr(nc+1,nr)
        pvgrad(0:nc-1,0:nr-1)=pvgrad1(0:nc-1,0:nr-1)
        pvgrad(nc,*)=pvgrad(0,*)
        pv=0.*fltarr(nc+1,nr)
        pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
        pv(nc,*)=pv(0,*)
        mpv=0.*fltarr(nc+1,nr)
        mpv(0:nc-1,0:nr-1)=mpv1(0:nc-1,0:nr-1)
        mpv(nc,*)=mpv(0,*)
;       s=0.*fltarr(nc+1,nr)
;       s(0:nc-1,0:nr-1)=s1(0:nc-1,0:nr-1)
;       s(nc,*)=s(0,*)
;       pvmin=0.
;       pvmax=max(pv(*,nr/2:nr-1))
;       pvint=(pvmax-pvmin)/(nlvls-1)
;       pvlevel=pvmin+pvint*findgen(nlvls)
;       contour,pv,x,alat,levels=pvlevel,/noeras,/overplot,$
;               c_color=col1,/cell_fill
;       contour,pv,x,alat,levels=pvlevel,/noeras,/overplot,$
;               color=0,/follow,c_labels=0+intarr(nlvls)
;       contour,s,x,alat,levels=15.+5.*findgen(10),$
;               color=mcolor,/overplot,/noeras,/follow,c_labels=0+intarr(10)
;       MAP_SET,90,0,-90,/stereo,/noeras,title=mtitle,color=lc,/contin,/grid
        pvavg=0. & mpvavg=0. & pvmed=0. & mpvmed=0.
        pvsave=fltarr(nc) & mpvsave=fltarr(nc)
        for i=0,nc-1 do begin
;
; look poleward of 40 N and 2 gridpoints away from the pole
;
            index=where(alat gt 40.)
            nr2=index(0)
            pvgradtmp=reform(pvgrad1(i,nr2:nr-3))
            pvtmp=reform(pv1(i,nr2:nr-3))
            mpvtmp=reform(mpv1(i,nr2:nr-3))
            lattmp=alat(nr2:nr-3)
            lontmp=alon(i)+0.*fltarr(n_elements(lattmp))
            index=where(pvgradtmp eq max(pvgradtmp))
            ;print,'Lon:PV/MPV/LAT ',alon(i),pvtmp(index(0)),mpvtmp(index(0)),lattmp(index(0))
;           oplot,[lontmp(index(0)),lontmp(index(0))],$
;                 [lattmp(index(0)),lattmp(index(0))],psym=4,color=0
            pvavg=pvavg+pvtmp(index(0))
            mpvavg=mpvavg+mpvtmp(index(0))
            pvsave(i)=pvtmp(index(0))
            mpvsave(i)=mpvtmp(index(0))
        endfor
        pvavg=pvavg/float(nc)
        mpvavg=mpvavg/float(nc)
        pvmed=median(pvsave)
        mpvmed=median(mpvsave)
        mpv0(k)=mpvmed
        th2(k)=th(k)
;       contour,pv,x,alat,levels=pvavg,thick=4,c_labels=[0],$
;               color=mcolor,/overplot,/noeras,/follow
        ;contour,mpv,x,alat,levels=mpvavg,thick=4,c_labels=[0],$
        ;        color=mcolor*.3,/overplot,/noeras,/follow
;       contour,pv,x,alat,levels=pvmed,thick=4,c_labels=[0],$
;               color=0,/overplot,/noeras,/follow
        ;contour,mpv,x,alat,levels=mpvmed,thick=4,c_labels=[0],$
        ;        color=0,/overplot,/noeras,/follow
;       print,th(k),' % diff=',100.*(pvavg-pvmed)/pvavg,' MPV=',mpvmed
    endfor
    index=where(mpv0 ne 0.)
    if index(0) ne -1 then begin
       mpv0=mpv0(index)
       th2=th2(index)
       index=sort(mpv0)
       mpv0=mpv0(index)
       th2=th2(index)
    endif
    if index(0) eq -1 then mpv0=[0.00039,0.0004,0,00041]
;
; introduce subvortex array
;
    subvortex=0.*mpv2
    mpv0med=median(mpv0)
    markindex=where(mpv2 gt mpv0med)
    if markindex(0) ne -1 then subvortex(markindex)=1.0
    write_ukmo_subvortex,dir+ifile+'_solve2.nc3.subvortex',$
          nc,nr,nth,alon,alat,th,subvortex
;
; plotting information
;
    theta=380.
    thlev=where(th eq theta)
    if thlev(0) eq -1 then stop,'Bad Theta'
    thlev=thlev(0)
    sth=strcompress(string(fix(theta)),/remove_all)
    ;print,alon
    ;read,' Enter longitude ',rlon1
    rlon1=283.125
    index1=where(alon eq rlon1)
    if index1(0) eq -1 then stop,'Bad Longitude'
    ilon1=index1(0)
    rlon2=rlon1+180.
    if rlon2 gt max(alon) then rlon2=rlon2-360.
    index2=where(alon eq rlon2)
    ilon2=index2(0)
    slon1=strcompress(string(rlon1),/remove_all)+'E'
    slon2=strcompress(string(rlon2),/remove_all)+'E'
    xyz=fltarr(nr,nth)
    yyz=fltarr(nr,nth)
    for i=0,nr-1 do yyz(i,*)=th
    for j=0,nth-1 do xyz(0:nr/2-1,j)=alat(nr/2:nr-1) 
    for j=0,nth-1 do xyz(nr/2:nr-1,j)=reverse(alat(nr/2:nr-1)) 
    p1=transpose(p2(*,*,thlev))
    pv1=transpose(pv2(*,*,thlev))
    mpv1=transpose(mpv2(*,*,thlev))
    qdf1=transpose(qdf2(*,*,thlev))
    msf1=transpose(msf2(*,*,thlev))
    mark1=transpose(marksf2(*,*,thlev))
    sf1=transpose(sf2(*,*,thlev))
    u1=transpose(u2(*,*,thlev))
    t1=transpose(t2(*,*,thlev))
    z1=transpose(z2(*,*,thlev))
    u=fltarr(nc+1,nr)
    u(0:nc-1,0:nr-1)=u1(0:nc-1,0:nr-1)
    u(nc,*)=u(0,*)
    t=fltarr(nc+1,nr)
    t(0:nc-1,0:nr-1)=t1(0:nc-1,0:nr-1)
    t(nc,*)=t(0,*)
    z=fltarr(nc+1,nr)
    z(0:nc-1,0:nr-1)=z1(0:nc-1,0:nr-1)
    z(nc,*)=z(0,*)
    p=0.*fltarr(nc+1,nr)
    p(0:nc-1,0:nr-1)=p1(0:nc-1,0:nr-1)
    p(nc,*)=p(0,*)
    pv=0.*fltarr(nc+1,nr)
    pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)*1.e4
    pv(nc,*)=pv(0,*)
    mpv=0.*fltarr(nc+1,nr)
    mpv(0:nc-1,0:nr-1)=mpv1(0:nc-1,0:nr-1)
    mpv(nc,*)=mpv(0,*)
    qdf=fltarr(nc+1,nr)
    qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
    qdf(nc,*)=qdf(0,*)
    msf=fltarr(nc+1,nr)
    msf(0:nc-1,0:nr-1)=msf1(0:nc-1,0:nr-1)
    msf(nc,*)=msf(0,*)
    mark=0.*fltarr(nc+1,nr)
    mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
    mark(nc,*)=mark(0,*)
    sf=0.*fltarr(nc+1,nr)
    sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
    sf(nc,*)=sf(0,*)
    temp=theta*((p/1000.)^(.286))
    zth=(msf-1004.*temp)/(9.86*1000.)
    syz=fltarr(nr,nth)
    uyz=fltarr(nr,nth)
    tyz=fltarr(nr,nth)
    zyz=fltarr(nr,nth)
    markyz=fltarr(nr,nth)
    mpvyz=fltarr(nr,nth)
    pvyz=fltarr(nr,nth)
    for k=0,nth-1 do begin
        uyz(0:nr/2-1,k)=u2(nr/2:nr-1,ilon1,k)
        uyz(nr/2:nr-1,k)=reverse(u2(nr/2:nr-1,ilon2,k))
        syz(0:nr/2-1,k)=s2(nr/2:nr-1,ilon1,k)
        syz(nr/2:nr-1,k)=reverse(s2(nr/2:nr-1,ilon2,k))
        tyz(0:nr/2-1,k)=t2(nr/2:nr-1,ilon1,k)
        tyz(nr/2:nr-1,k)=reverse(t2(nr/2:nr-1,ilon2,k))
        zyz(0:nr/2-1,k)=z2(nr/2:nr-1,ilon1,k)
        zyz(nr/2:nr-1,k)=reverse(z2(nr/2:nr-1,ilon2,k))
        markyz(0:nr/2-1,k)=marksf2(nr/2:nr-1,ilon1,k)
        markyz(nr/2:nr-1,k)=reverse(marksf2(nr/2:nr-1,ilon2,k))
        mpvyz(0:nr/2-1,k)=mpv2(nr/2:nr-1,ilon1,k)
        mpvyz(nr/2:nr-1,k)=reverse(mpv2(nr/2:nr-1,ilon2,k))
        pvyz(0:nr/2-1,k)=pv2(nr/2:nr-1,ilon1,k)*1.e4
        pvyz(nr/2:nr-1,k)=reverse(pv2(nr/2:nr-1,ilon2,k))*1.e4
    endfor

    if setplot eq 'ps' then begin
       lc=0
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       wdelete,1
       set_plot,'ps'
       device,/color,/landscape,bits=8,filename='Postscript/ukmo_'+ifile+'_'+sth+'_'+slon1+'.ps'
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif

; plot
    !noeras=1
    !type=2^2+2^3
    !p.thick=1
    erase
    !psym=0
    ipan=0
    xmn=xorig(ipan)
    xmx=xorig(ipan)+xlen
    ymn=yorig(ipan)
    ymx=yorig(ipan)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    mtitle='!6'+sth+' K UKMO PV on '+ifile
    !psym=0
    !type=2^2+2^3
    MAP_SET,90,0,-90,/ortho,/noeras,title=mtitle,color=lc
    pvmin=0.
    pvmax=max(pv(*,nr/2:nr-1))
    pvint=(pvmax-pvmin)/(nlvls-1)
    pvlevel=pvmin+pvint*findgen(nlvls)
    contour,pv,x,alat,levels=pvlevel,/noeras,/overplot,$
            c_color=col1,/cell_fill
    contour,pv,x,alat,levels=pvlevel,/noeras,/overplot,$
            color=0,/follow,c_labels=0+intarr(nlvls)
index=where(th2 eq theta)
if index(0) ne -1 then $
;   contour,mpv,x,alat,levels=mpv0(index(0)),color=mcolor,thick=3,/overplot
    result=moment(mpv0)
    print,ifile,mpv0med,result(0)
    contour,mpv,x,alat,levels=result(0),color=mcolor,thick=3,/overplot
    contour,mpv,x,alat,levels=mpv0med,color=0,thick=3,/overplot
;   contour,pv,x,alat,levels=[2.5],color=mcolor*.65,thick=3,/overplot
    contour,mark,x,alat,levels=[0.1],/noeras,/overplot,$
            color=mcolor*.2,/follow,thick=3,c_labels=[0]
    MAP_SET,90,0,-90,/ortho,/grid,/contin,/noeras,/noborder,color=0
    oplot,rlon1+0.*alat,alat,color=icolmax,linestyle=2
    oplot,rlon2+0.*alat,alat,color=icolmax,linestyle=2
    ipan=1
    xmn=xorig(ipan)
    xmx=xorig(ipan)+xlen
    ymn=yorig(ipan)
    ymx=yorig(ipan)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    level=2.5*findgen(nlvls)
    contour,syz,alat,th,levels=level,/fill,/cell_fill,c_color=col1,$
            xtitle='!6'+slon1+'       Latitude      '+slon2,ytitle='!6Theta',$
            xtickname=['Eq','30','60','NP','60','30','Eq'],xticks=6,$
            yrange=[260.,600.]
    contour,syz,alat,th,levels=level,/noeras,/overplot,$
            color=0,/follow,c_labels=0+intarr(nlvls)
    contour,pvyz,alat,th,levels=[2.5],color=mcolor*.65,thick=3,/overplot
    contour,markyz,alat,th,levels=[0.1],/noeras,/overplot,$
            color=mcolor,/follow,thick=3,c_labels=[0]
    tlevel=[185.,190.,195.,200.]
    contour,tyz,alat,th,levels=tlevel,/follow,c_color=0,/overplot,$
            c_labels=1+0*tlevel,c_linestyle=tlevel lt 0,thick=2
    oplot,alat,theta+0.*alat,color=icolmax,linestyle=2
    imin=min(level)
    imax=max(level)
    ymnb=ymn -cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn,xmx,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras
    ybox=[0,10,10,0,0]
    x2=imin
    dx=(imax-imin)/(float(nlvls)-1)
    for j=1,nlvls-1 do begin
        xbox=[x2,x2,x2+dx,x2+dx,x2]
        polyfill,xbox,ybox,color=col1(j)
        x2=x2+dx
    endfor

    ipan=2
    xmn=xorig(ipan)
    xmx=xorig(ipan)+xlen
    ymn=yorig(ipan)
    ymx=yorig(ipan)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    imin=min(mpvyz)
    imin=0.
    imax=max(mpvyz)
    mpvlevel=imin+((imax-imin)/nlvls)*findgen(nlvls)
    contour,mpvyz,alat,th,levels=mpvlevel,/fill,/cell_fill,c_color=col1,$
            xtitle='!6'+slon1+'       Latitude      '+slon2,ytitle='!6Theta',$
            xtickname=['Eq','30','60','NP','60','30','Eq'],xticks=6,$
            yrange=[260.,600.]
    contour,mpvyz,alat,th,levels=mpvlevel,/noeras,/overplot,$
            color=0,/follow,c_labels=0+intarr(nlvls)
    contour,mpvyz,alat,th,levels=mpv0,color=mcolor,/overplot
    contour,mpvyz,alat,th,levels=result(0),color=mcolor,/overplot,thick=4
    contour,mpvyz,alat,th,levels=mpv0med,color=0,/overplot,thick=4
    contour,pvyz,alat,th,levels=[2.5],color=mcolor*.65,thick=3,/overplot
    tlevel=[185.,190.,195.,200.]
    contour,tyz,alat,th,levels=tlevel,/follow,c_color=0,/overplot,$
            c_labels=1+0*tlevel,c_linestyle=tlevel lt 0,thick=2
;   contour,markyz,alat,th,levels=[0.1],/noeras,/overplot,$
;           color=mcolor,/follow,thick=3,c_labels=[0]
    oplot,alat,theta+0.*alat,color=icolmax,linestyle=2
    imin=min(mpvlevel)
    imax=max(mpvlevel)
    ymnb=ymn -cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn,xmx,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras
    ybox=[0,10,10,0,0]
    x2=imin
    dx=(imax-imin)/(float(nlvls)-1)
    for j=1,nlvls-1 do begin
        xbox=[x2,x2,x2+dx,x2+dx,x2]
        polyfill,xbox,ybox,color=col1(j)
        x2=x2+dx
    endfor

; Close PostScript file and return control to X-windows
    if setplot eq 'ps' then device, /close
    if setplot eq 'x' then begin
       save=assoc(3,bytarr(nxdim,nydim))
       img=bytarr(nxdim,nydim)
       img(0,0)=TVRD(0,0,nxdim,nydim)
       write_gif,'Gif_images/ukmo_subvortex_'+ifile+'_'+sth+'.gif',img
    endif
;   stop
    jump:
endfor		; loop over days
end
