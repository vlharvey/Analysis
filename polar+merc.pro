;
; read UKMO netCDF data and plot polar stereographic and mercator
;
@rd_ukmo_nc3
@drawvectors

loadct,38
mcolor=byte(!p.color)
if mcolor eq 0 then mcolor=255
setplot='ps'
print,'Enter ps to print a postscript file '
read,'Enter x to print to X-window ',setplot
nxdim=750
nydim=750
xorig=[0.3,0.2]
yorig=[0.05,0.6]
xlen=0.4
ylen=0.4
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
;diru='/goliath/marek/UKMO/Datfiles/ukmo_'
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
close,1
openr,1,'polar+merc.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    print,ifile
    iflag=0
    rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
;
; ask for desired theta surfaces
;
    if n eq 0 then begin
       theta1=0. & theta2=0.
;      print,th
;      read,'Enter 2 theta values (high then low) ',theta1,theta2
theta1=900
theta2=360
       index=where(theta1 eq th)
       if index(0) eq -1 then stop,'Invalid theta level '
       thlev1=index(0)
       index=where(theta2 eq th)
       if index(0) eq -1 then stop,'Invalid theta level '
       thlev2=index(0)
       stheta1=strcompress(string(fix(theta1)),/remove_all)
       stheta2=strcompress(string(fix(theta2)),/remove_all)
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
       device,/landscape,bits=8,$
               filename=ifile+'_'+stheta1+'_'+stheta2+'K.ps'
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
    MAP_SET,-90,0,0,/stereo,/noeras,title='!6'+stheta1+' K',charsize=2
    sf1=transpose(sf2(*,*,thlev1))
    sf=0.*fltarr(nc+1,nr)
    sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
    sf(nc,*)=sf(0,*)
    sfmin=min(sf)
    sfmax=max(sf)
    nlvls=20
    sfint=(sfmax-sfmin)/nlvls
    sflevel=sfmin+sfint*findgen(nlvls)
    col1=reverse(1+indgen(nlvls)*mcolor/nlvls)
    x=fltarr(nc+1)
    x(0:nc-1)=alon
    x(nc)=alon(0)+360.
    contour,sf,x,alat,/overplot,levels=sflevel,c_color=col1,/cell_fill,/noeras
    contour,sf,x,alat,/overplot,levels=sflevel,color=0
    MAP_SET,-90,0,0,/stereo,/contin,/grid,/noeras,color=0
    u1=transpose(u2(*,*,thlev1))
    v1=transpose(v2(*,*,thlev1))
    u=fltarr(nc+1,nr)
    u(0:nc-1,0:nr-1)=u1(0:nc-1,0:nr-1)
    u(nc,*)=u(0,*)
    v=fltarr(nc+1,nr)
    v(0:nc-1,0:nr-1)=v1(0:nc-1,0:nr-1)
    v(nc,*)=v(0,*)
    drawvectors,nc+1,nr,x,alat,u,v,5,0
    MAP_SET,-90,0,0,/stereo,/noeras,lonlab=-5,label=1,$
            latdel=180,charsize=2,title='!6'+stheta1+' K'

    !type=2^2+2^3
    xmn=xorig(1)
    xmx=xorig(1)+0.6
    ymn=yorig(1)
    ymx=yorig(1)+0.3
    set_viewport,xmn,xmx,ymn,ymx
; 
; swap longitudes so the mercator plot doesn't get confused
;
    sf1=transpose(sf2(*,*,thlev2))
    sf=0.*fltarr(nc+1,nr)
    sf(0:nc/2-1,0:nr-1)=sf1(nc/2:nc-1,0:nr-1)
    sf(nc/2:nc,0:nr-1)=sf1(0:nc/2,0:nr-1)
    sfmin=min(sf)
    sfmax=max(sf)
    sfint=(sfmax-sfmin)/nlvls
    sflevel=sfmin+sfint*findgen(nlvls)
    col1=1+indgen(nlvls)*mcolor/nlvls
    x=fltarr(nc+1)
    x(0:nc/2-1)=alon(nc/2:nc-1)-360.
    x(nc/2:nc)=alon(0:nc/2)
    contour,sf,x,alat,levels=sflevel,c_color=col1,/cell_fill,/noeras,$
            xrange=[-180.,180.],yrange=[-90.,90],xticks=6,yticks=6,charsize=2
    contour,sf,x,alat,/overplot,levels=sflevel,color=0
    MAP_SET,0,0,0,/noeras,/contin,/grid,color=0
    MAP_SET,0,0,0,/noeras,title='!6'+ifile+'  '+stheta2+' K',charsize=2
    u1=transpose(u2(*,*,thlev2))
    v1=transpose(v2(*,*,thlev2))
    u=fltarr(nc+1,nr)
    u(0:nc/2-1,0:nr-1)=u1(nc/2:nc-1,0:nr-1)
    u(nc/2:nc,0:nr-1)=u1(0:nc/2,0:nr-1)
    v=fltarr(nc+1,nr)
    v(0:nc/2-1,0:nr-1)=v1(nc/2:nc-1,0:nr-1)
    v(nc/2:nc,0:nr-1)=v1(0:nc/2,0:nr-1)
    drawvectors,nc+1,nr,x,alat,u,v,3,0
    stop
    if setplot eq 'ps' then device, /close
    jump:
endfor		; loop over files
end
