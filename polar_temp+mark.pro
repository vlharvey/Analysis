; temperature and vortex edge
;
@rd_ukmo_nc3

ipan=0
npp=1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
setplot='ps'
read,'setplot=',setplot
nxdim=600
nydim=600
xorig=[0.1]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
close,1
openr,1,'polar_temp+mark.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    print,ifile
    iflag=0
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
        marksf1=transpose(marksf2(*,*,thlev))
        marksf1=transpose(marksf2(*,*,thlev))
        marksf=0.*fltarr(nc+1,nr)
        marksf(0:nc-1,0:nr-1)=marksf1(0:nc-1,0:nr-1)
        marksf(nc,*)=marksf(0,*)
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
                   filename='Figures/'+ifile+'_'+stheta+'K_t+mark.ps'
           device,/color
           device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                  xsize=xsize,ysize=ysize
        endif

; Set plot boundaries
;!p.multi=[npp-ipan,2,2]
erase
        !psym=0
        MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,/noborder,$
                title='!6UKMO Temperature '+ifile+'  '+stheta+' K',charsize=2.0,latdel=10
        !psym=3
        oplot,findgen(361),-0.1+0.*findgen(361)
;       if n eq 0 then begin
        index=where(lat lt 0.)
        sfmin=170.
        nlvls=35
        col1=1+indgen(nlvls)*icolmax/float(nlvls)
        sfint=2.
        sflevel=sfmin+sfint*findgen(nlvls)
;       endif
        contour,t,x,alat,/overplot,levels=sflevel,c_color=col1,thick=1,$
                /cell_fill,/noeras
        contour,t,x,alat,/overplot,levels=sflevel,/follow,color=0,$
                c_labels=0*sflevel
        contour,t,x,alat,/overplot,levels=[180,185,190,195],/follow,thick=5,$
                c_labels=[1,1,1,1],color=0,charsize=3
        MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,/noborder,latdel=10,$
                charsize=2,color=0

        lindex=where(lat lt 0. and marksf eq 1)
        if lindex(0) ne -1 then begin
           dum=sf          ; SH
           sfmin=min(dum(lindex))
           ymax=max(lat(lindex))
           index=where(lat gt ymax+2.5)
           dum(index)=9999.
           contour,dum,x,alat,levels=sfmin,color=lc,max_value=1.,thick=10,$
                  /overplot
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
