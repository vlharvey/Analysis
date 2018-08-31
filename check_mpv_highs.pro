;
; what are characteristic MPV values inside anticyclones?
;
@rd_ukmo_nc3
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
    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
    x=fltarr(nc+1)
    x(0:nc-1)=alon(0:nc-1)
    x(nc)=alon(0)+360.
    s2=sqrt(u2^2+v2^2)
    xlon=alon
    xlat=alat
    y3d=fltarr(nr,nc,nth)
    for k=0,nth-1 do $
        for j=0,nr-1 do $
            for i=0,nc-1 do y3d(*,i,k)=alat
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
    index=where(marksf2 lt 0.)
    if index(0) ne -1 then plot,mpv2(index),y3d(index),psym=3
    stop
    jump:
endfor		; loop over days
end
