;
; plot UKMO vertical profiles of global averaged theta, height, pressure
;
@rd_ukmo_nc3
loadct,38
mcolor=!p.color
nxdim=750
nydim=750
xorig=[0.35]
yorig=[0.25]
xlen=0.3
ylen=0.5
setplot='x'
read,'SETPLOT ',setplot
if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
;  !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='th_p_z.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
           xsize=xsize,ysize=ysize
   !p.charsize=1.5
endif
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                                       '
close,1
openr,1,'plot_th_p_z.fil'
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    print,ifile
    rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
;
; Calculate geopotential height of an isentropic surface = (msf - cp*T)/g
;
    z2=0.*qdf2
    t2=0.*qdf2
    if n eq 0 then begin
       zavg=fltarr(nfile,nth)
       pavg=fltarr(nfile,nth)
       zsig=fltarr(nfile,nth)
       psig=fltarr(nfile,nth)
       zmin=fltarr(nfile,nth)
       pmin=fltarr(nfile,nth)
       zmax=fltarr(nfile,nth)
       pmax=fltarr(nfile,nth)
    endif
    for k=0,nth-1 do begin
        kk=nth-1-k
        t2(*,*,k) = th(k)*( (p2(*,*,k)/1000.)^(.286) )
        z2(*,*,k) = (msf2(*,*,k) - 1004.*t2(*,*,k))/(9.86*1000.)
        res1=moment(z2(*,*,k))
        res2=moment(p2(*,*,k))
        zavg(n,kk)=res1(0)
        pavg(n,kk)=res2(0)
        zsig(n,kk)=sqrt(res1(1))
        psig(n,kk)=sqrt(res2(1))
        zmin(n,kk)=min(z2(*,*,k))
        pmin(n,kk)=min(p2(*,*,k))
        zmax(n,kk)=max(z2(*,*,k))
        pmax(n,kk)=max(p2(*,*,k))
    endfor
    jump:
endfor
;
; average all months and take yearly max and min
;
zavgf=fltarr(nth)
pavgf=fltarr(nth)
zsigf=fltarr(nth)
psigf=fltarr(nth)
zminf=fltarr(nth)
pminf=fltarr(nth)
zmaxf=fltarr(nth)
pmaxf=fltarr(nth)
for k=0,nth-1 do begin
    res1=moment(zavg(*,k))
    res2=moment(pavg(*,k))
    zavgf(k)=res1(0)
    pavgf(k)=res2(0)
    zsigf(k)=sqrt(res1(1))
    psigf(k)=sqrt(res2(1))
    zminf(k)=min(zmin(*,k))
    pminf(k)=min(pmin(*,k))
    zmaxf(k)=max(zmax(*,k))
    pmaxf(k)=max(pmax(*,k))
endfor
;
; plot
;
erase
!type=2^2+2^3
!p.linestyle=0
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
stheta=reverse(strcompress(string(fix(th)),/remove_all))
plot,zavgf,findgen(nth),/noeras,xstyle=9,thick=2,$
     xtitle='!6Geopotential Altitude (km)',xrange=[0.0,50.],$
     ytitle='!6Potential Temperature (K)',yticks=nth-1,$
     ytickv=findgen(nth),ytickname=stheta
!p.linestyle=5
;   oplot,zavgf+zsigf,findgen(nth)
;   oplot,zavgf-zsigf,findgen(nth)
oplot,zminf,findgen(nth)
oplot,zmaxf,findgen(nth)
!p.linestyle=0
axis,xrange=[0.1,1000.],/xlog,/save,xaxis=1,/data,$
     xtitle='!6Pressure (hPa)'
oplot,pavgf,findgen(nth),thick=2
oplot,pavgf,findgen(nth),psym=4
!p.linestyle=5
;   oplot,pavgf+psigf,findgen(nth)
;   oplot,pavgf-psigf,findgen(nth)
oplot,pminf,findgen(nth)
oplot,pmaxf,findgen(nth)
if setplot eq 'ps' then device, /close
end
