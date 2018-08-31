;
; plot mercator projection of SF and wind vectors and
; then a time series of v within some area SW of Tibet
;
@rd_ukmo_nc3
@drawvectors

loadct,38
mcolor=byte(!p.color)
if mcolor eq 0 then mcolor=255
setplot='ps'
print,'Enter ps to print a postscript file '
read,'Enter x to print to X-window ',setplot
nxdim=700
nydim=700
xorig=[0.15,0.15]
yorig=[0.57,0.1]
xlen=0.7
ylen=0.35
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
openr,1,'merc+xz.fil'
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
       theta=0.
       print,th
       read,'Enter theta surface ',theta
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
       device,/landscape,bits=8,$
               filename=ifile+'_'+stheta+'K.ps'
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
    sf=transpose(msf2(*,*,thlev))
    if n eq 0. then begin
    sfmin=min(sf)-.02*min(sf)
    sfmax=max(sf)+.02*max(sf)
    nlvls=20L
    sfint=(sfmax-sfmin)/nlvls
    sflevel=sfmin+sfint*findgen(nlvls)
    col1=1+indgen(nlvls)*mcolor/nlvls
    endif
    !type=2^2+2^3
    contour,sf,alon,alat,levels=sflevel,c_color=col1,/cell_fill,/noeras,$
            xrange=[0.,360.],yrange=[-90.,90],xticks=6,yticks=6,$
            xstyle=1,ystyle=1,charsize=2
    contour,sf,alon,alat,/overplot,levels=sflevel,color=0
    MAP_SET,0,180,0,/noeras,/contin,/grid,color=0
    MAP_SET,0,180,0,/noeras,title='!6'+ifile+'  '+stheta+' K',charsize=2
    u=transpose(u2(*,*,thlev))
    v=transpose(v2(*,*,thlev))
    drawvectors,nc,nr,alon,alat,u,v,2,0
    oplot,60.+findgen(61),-10.+0.*findgen(61),psym=0,thick=2
    oplot,60.+findgen(61),5.+0.*findgen(61),psym=0,thick=2
    oplot,60.+0.*findgen(61),-10.+findgen(16),psym=0,thick=2
    oplot,120.+0.*findgen(61),-10.+findgen(16),psym=0,thick=2

    oplot,findgen(361),0.*findgen(361),psym=0

    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
v2=smooth(v2,3)
    index=where(alat le 5. and alat ge -10.,nlat)
    vxz=fltarr(nc,nth)
    for i=0,nc-1 do $
        for k=0,nth-1 do $
            vxz(i,k)=total(v2(index,i,k))/float(nlat)
    sfmin=-20.
    sfmax=20.
    nlvls=41L
    sfint=1.0
    level=sfmin+sfint*findgen(nlvls)
    col2=1+indgen(nlvls)*mcolor/nlvls
    !type=2^2+2^3
    index=where(th le 400.,nyticks)
    ylabels=reverse(strcompress(string(fix(th(index))),/remove_all))
    contour,vxz,alon,th,levels=level,c_color=col2,/cell_fill,/noeras,$
            xrange=[0.,360.],yrange=[min(th(index)),max(th(index))],$
            xticks=6,yticks=nyticks-1,ytickname=ylabels,$
            charsize=2,title='!6Meridional wind component'
    contour,vxz,alon,th,levels=level,c_color=0,/follow,/noeras,$
            c_linestyle=level lt 0.,/overplot
    contour,vxz,alon,th,/overplot,levels=0,color=0,thick=2
    oplot,findgen(361),theta+0.*findgen(361),psym=0
    oplot,60.+findgen(61),340.+0.*findgen(61),psym=0,thick=2
    oplot,60.+findgen(61),380.+0.*findgen(61),psym=0,thick=2
    oplot,60.+0.*findgen(61),340.+findgen(41),psym=0,thick=2
    oplot,120.+0.*findgen(61),340.+findgen(41),psym=0,thick=2
;   stop
    if setplot eq 'ps' then device, /close

    if setplot eq 'x' then begin
       save=assoc(3,bytarr(nxdim,nydim))
       img=bytarr(nxdim,nydim)
       img(0,0)=TVRD(0,0,nxdim,nydim)
       write_gif,'Tibet_gifs/'+ifile+'_'+stheta+'K_merc.gif',img
    endif

    jump:
endfor		; loop over files
end
