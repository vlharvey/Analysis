
; Plot markers.  cyclones = 1;  anticyclones = -1

@rd_ukmo_nc3
@compvort

nlvls=20
loadct,38
mcolor=!p.color
icolmax=byte(!p.color)
icmm1=icolmax-1B
icmm2=icolmax-2B
col1=1+indgen(nlvls)*icolmax/nlvls
!NOERAS=-1
!P.FONT=0
SETPLOT='ps'
read,'setplot',setplot
nxdim=750
nydim=750
xorig=[0.25,0.25]
yorig=[0.05,0.55]
xlen=0.4
ylen=0.4
cbaryoff=0.0
cbarydel=0.02
device,decompose=0
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
if setplot eq 'ps' then begin
   lc=0
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   wdelete,1
   set_plot,'ps'
   device,/color,/landscape,bits=8,filename='ukmo_nc3.ps'
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
   xsize=xsize,ysize=ysize
endif

nr=0L
nc=0L
nth=0L
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
close,1
openr,1,'ukmo_files.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin

; Read UKMO isentropic data
    iflag=0
    readf,1,ifile
    rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
    savemark=mark2
    mark2sm=0.*mark2
stop
;
; smooth marker field
;
      for i=0,nc-1 do begin
         ip1=i+1
         im1=i-1
         if i eq nc-1 then ip1=0
         if i eq 0 then im1=nc-1
         for j=0,nr-1 do begin
            jp1=j+1
            jm1=j-1
            if j eq nr-1 then jp1=j
            if j eq 0 then jm1=0
            for k=0,nth-1 do begin
               kp1=k+1
               km1=k-1
               if k eq nth-1 then kp1=k
               if k eq 0 then km1=0
               mark2sm(j,i,k)=((1./6.)*(savemark(j,im1,k)+ $
                                  4.0*savemark(j,i,k)+ $
                                      savemark(j,ip1,k))+ $
                             (1./6.)*(savemark(jm1,i,k)+ $
                                  4.0*savemark(j,i,k)+ $
                                      savemark(jp1,i,k))+ $
                             (1./6.)*(savemark(j,i,km1)+ $
                                  4.0*savemark(j,i,k)+ $
                                      savemark(j,i,kp1)))/3.0
            endfor
         endfor
      endfor

    if iflag eq 1 then goto,jump
    x=fltarr(nc+1)
    x(0:nc-1)=alon(0:nc-1)
    x(nc)=alon(0)+360.

; loop over theta from top down
    FOR thlev=0,nth-1 DO BEGIN
; extract theta level
        theta=th(thlev)
        print,'theta level=',theta
        pv1=transpose(pv2(*,*,thlev))
        p1=transpose(p2(*,*,thlev))
        msf1=transpose(msf2(*,*,thlev))
        q1=transpose(q2(*,*,thlev))
        u1=transpose(u2(*,*,thlev))
        v1=transpose(v2(*,*,thlev))
        qdf1=transpose(qdf2(*,*,thlev))
        mark1=transpose(mark2(*,*,thlev))
        mark1sm=transpose(mark2sm(*,*,thlev))
        vp1=transpose(vp2(*,*,thlev))
        sf1=transpose(sf2(*,*,thlev))
        s1=sqrt(u1^2+v1^2)
        t1=theta*(p1/1000.)^.286
        
; introduce relative vorticity
        zeta1=u1*0.0

; compute relative vorticity, zeta
        compvort,u1,v1,zeta1,alon,alat,nc,nr

; add wrap around longitude for plotting
        pv=fltarr(nc+1,nr)
        pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
        pv(nc,*)=pv(0,*)
        p=fltarr(nc+1,nr)
        p(0:nc-1,0:nr-1)=p1(0:nc-1,0:nr-1)
        p(nc,*)=p(0,*)
        s=fltarr(nc+1,nr)
        s(0:nc-1,0:nr-1)=s1(0:nc-1,0:nr-1)
        s(nc,*)=s(0,*)
        msf=fltarr(nc+1,nr)
        msf(0:nc-1,0:nr-1)=msf1(0:nc-1,0:nr-1)
        msf(nc,*)=msf(0,*)
        qdf=fltarr(nc+1,nr)
        qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
        qdf(nc,*)=qdf(0,*)
        mark=fltarr(nc+1,nr)
        mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
        mark(nc,*)=mark(0,*)
        marksm=fltarr(nc+1,nr)
        marksm(0:nc-1,0:nr-1)=mark1sm(0:nc-1,0:nr-1)
        marksm(nc,*)=marksm(0,*)
        vp=fltarr(nc+1,nr)
        vp(0:nc-1,0:nr-1)=vp1(0:nc-1,0:nr-1)
        vp(nc,*)=vp(0,*)
        sf=fltarr(nc+1,nr)
        sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
        sf(nc,*)=sf(0,*)
        zeta=fltarr(nc+1,nr)
        zeta(0:nc-1,0:nr-1)=zeta1(0:nc-1,0:nr-1)
        zeta(nc,*)=zeta(0,*)
        q=fltarr(nc+1,nr)
        q(0:nc-1,0:nr-1)=q1(0:nc-1,0:nr-1)
        q(nc,*)=q(0,*)
        xvortex=0.*s
        yvortex=0.*s
        
; define 2d arrays of longitudes and latitudes
        for i=0,nc do begin
            yvortex(i,*)=alat
        endfor
        for j=0,nr-1 do begin
            xvortex(*,j)=x
        endfor
; PLOT
        !noeras=1
        !type=2^2+2^3
        !p.thick=1
        erase
        ipan=0
        !psym=0
        xmn=xorig(ipan)
        xmx=xorig(ipan)+xlen
        ymn=yorig(ipan)
        ymx=yorig(ipan)+ylen(0)
        set_viewport,xmn,xmx,ymn,ymx
        mtitle=string(theta)+'K PV on '+strmid(ifile,5,6)
        MAP_SET,90,0,0,/stereo,/GRID,/CONTIN,/noeras
        mins=min(pv)
        maxs=max(pv)
        level=mins+((maxs-mins)/nlvls)*findgen(nlvls)
        contour,pv,x,alat,levels=level,/overplot,/cell_fill,c_color=col1
;tmp=smooth(mark,3,/edge_truncate)
tmp=marksm
        contour,tmp,x,alat,/overplot,nlevels=20,color=0	;levels=-1.+.1*findgen(21),/overplot,color=0
index=where(tmp gt -1. and tmp lt 1. and tmp ne 0.)
if index(0) ne -1 then oplot,xvortex(index),yvortex(index),psym=3,color=mcolor
        MAP_SET,90,0,0,/stereo,/GRID,/CONTIN,/noeras,title=mtitle
        imin=min(level)
        imax=max(level)
        ymnb=ymn -cbaryoff
        ymxb=ymnb+cbarydel
        set_viewport,xmn,xmx,ymnb,ymxb
        !type=2^2+2^3+2^6
        plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras
        ybox=[0,10,10,0,0]
        x2=imin
        dx=(imax-imin)/float(icmm1)
        for j=1,icmm1 do begin
            xbox=[x2,x2,x2+dx,x2+dx,x2]
            polyfill,xbox,ybox,color=j
            x2=x2+dx
        endfor
        ipan=1
        xmn=xorig(ipan)
        xmx=xorig(ipan)+xlen
        ymn=yorig(ipan)
        ymx=yorig(ipan)+ylen(0)
        set_viewport,xmn,xmx,ymn,ymx
        mtitle=string(theta)+'K Streamfunction on '+strmid(ifile,5,6)
        MAP_SET,90,0,0,/stereo,/GRID,/CONTIN,/noeras
        index=where(sf lt 1.e12)
        mins=min(sf(index))
        maxs=max(sf(index))
        level=mins+((maxs-mins)/nlvls)*findgen(nlvls)
        contour,sf,x,alat,levels=level,/overplot,/cell_fill,c_color=col1
        contour,mark,x,alat,levels=-1.+.1*findgen(21),/overplot,color=0
;       index=where(mark eq -1.0)
;       if index(0) ne -1 then begin
;          !psym=2
;          for i=0,n_elements(index)-1 do begin
;              oplot,[xvortex(index(i)),xvortex(index(i))],$
;                    [yvortex(index(i)),yvortex(index(i))],color=0b
;          endfor
;       endif
;       index=where(mark eq 1.0)
;       if index(0) ne -1 then begin
;          !psym=2
;          for i=0,n_elements(index)-1 do begin
;              oplot,[xvortex(index(i)),xvortex(index(i))],$
;                    [yvortex(index(i)),yvortex(index(i))],color=mcolor
;          endfor
;       endif
        !psym=0
        MAP_SET,90,0,0,/stereo,/GRID,/CONTIN,/noeras,title=mtitle
        imin=min(level)
        imax=max(level)
        ymnb=ymn -cbaryoff
        ymxb=ymnb+cbarydel
        set_viewport,xmn,xmx,ymnb,ymxb
        !type=2^2+2^3+2^6
        plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras
        ybox=[0,10,10,0,0]
        x2=imin
        dx=(imax-imin)/float(icmm1)
        for j=1,icmm1 do begin
            xbox=[x2,x2,x2+dx,x2+dx,x2]
            polyfill,xbox,ybox,color=j
            x2=x2+dx
        endfor
       stop
    ENDFOR  ; loop over theta
jump:
endfor; loop over days
end
