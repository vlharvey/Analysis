;
; plot mercator and longitude-altitude plots
;
@rd_ukmo_nc3
@drawvectors

loadct,38
device,decompose=0
mcolor=byte(!p.color)
if mcolor eq 0 then mcolor=255
icolmax=mcolor
setplot='ps'
print,'Enter ps to print a postscript file '
read,'Enter x to print to X-window ',setplot
nxdim=700
nydim=700
xorig=[0.15,0.15]
yorig=[0.6,0.15]
xlen=0.7
ylen=0.35
cbaryoff=0.07
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
close,1
openr,1,'merc+xz.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    print,ifile
    iflag=0
    rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
    index=where(mark2 lt -1.0)
    if index(0) ne -1L then mark2(index)=mark2(index)/abs(mark2(index))
;
; compute temperature
;
      t2=0.*u2
      for k=0,nth-1 do t2(*,*,k)=th(k)*((p2(*,*,k)/1000.)^(.286))
;
; ask for desired theta surfaces
;
    if n eq 0 then begin
       theta=1600.
;      print,th
;      read,'Enter theta surface ',theta
       index=where(theta eq th)
       if index(0) eq -1 then stop,'Invalid theta level '
       thlev=index(0)
       stheta=strcompress(string(fix(theta)),/remove_all)
    endif
;
; save as postscript file
;
    if setplot eq 'ps' then begin
       lc=0
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='merc_xt_'+ifile+'_'+stheta+'K_tp_meto.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
               xsize=xsize,ysize=ysize
    endif
;
; plot 
;
    erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    !psym=0
    temp=transpose(t2(*,*,thlev))
    mark=transpose(mark2(*,*,thlev))
nlvls=19
col1=1+indgen(nlvls)*icolmax/nlvls
level=190.+5.*findgen(nlvls)
    !type=2^2+2^3
    contour,temp,alon,alat,levels=level,c_color=col1,/cell_fill,/noeras,$
            xrange=[0.,360.],yrange=[-90.,90],xticks=6,yticks=6,$
            xstyle=1,ystyle=1,charsize=2
    contour,temp,alon,alat,/overplot,levels=level,color=0
    contour,mark,alon,alat,/overplot,levels=[0.1],color=0,thick=5
    contour,mark,alon,alat,/overplot,levels=[-0.1],color=mcolor,thick=5
    MAP_SET,0,180,0,/noeras,/contin,/grid,color=0
    MAP_SET,0,180,0,/noeras,title=ifile+'  '+stheta+' K',charsize=2
    u=transpose(u2(*,*,thlev))
    v=transpose(v2(*,*,thlev))
;   drawvectors,nc,nr,alon,alat,u,v,2,0

    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    index=where(alat eq 58.7500,nlat)
    slat=strcompress(alat(index(0)),/remove_all)
    vxz=fltarr(nc,nth)
    mxz=fltarr(nc,nth)
    for i=0,nc-1 do begin
        for k=0,nth-1 do begin
            vxz(i,k)=(t2(index(0)-1,i,k)+2.*t2(index(0),i,k)+t2(index(0)+1,i,k))/4.
            mxz(i,k)=(mark2(index(0)-1,i,k)+2.*mark2(index(0),i,k)+mark2(index(0)+1,i,k))/4.
        endfor
    endfor
    !type=2^2+2^3
    index=where(th ge 700.,nyticks)
    ylabels=reverse(strcompress(string(fix(th(index))),/remove_all))
    contour,vxz,alon,th,levels=level,c_color=col1,/cell_fill,/noeras,$
            xrange=[0.,360.],yrange=[min(th(index)),max(th(index))],$
            xticks=6,yticks=nyticks-1,ytickname=ylabels,ytickv=reverse(th(index)),$
            charsize=2,title='Temperature at 60 N'
    contour,vxz,alon,th,levels=level,c_color=0,/follow,/noeras,$
            c_linestyle=level lt 0.,/overplot
    contour,mxz,alon,th,/overplot,levels=[0.1],color=0,thick=5
    contour,mxz,alon,th,/overplot,levels=[-0.1],color=mcolor,thick=5

imin=min(level)
imax=max(level)
ymnb=yorig(1) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='(K)'
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for jj=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(jj)
x1=x1+dx
endfor

    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim merc_xt_'+ifile+'_'+stheta+'K_tp_meto.ps -rotate -90 merc_xt_'+ifile+'_'+stheta+'K_tp_meto.jpg'
    endif
    if setplot eq 'x' then stop
    jump:
endfor		; loop over files
end
