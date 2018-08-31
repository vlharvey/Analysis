;
; reads in .nc3 and .nc4 marker field and plots polar stereographic
;
@rd_ukmo_nc3

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
xorig=[0.30,0.15,0.55]
yorig=[0.55,0.15,0.15]
xlen=0.3
ylen=0.3
cbaryoff=0.02
cbarydel=0.015
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dir='/usr72/users/ukmo/Datfiles/ukmo_'
ifile='                             '
close,1
openr,1,'check_q.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    print,ifile
    iflag=0
    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,qswa2,qdf2,mark2,vp2,sf2,iflag
    rd_ukmo_nc3,dir+ifile+'_noadj.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,qnoa2,qdf2,mark2,vp2,sf2,iflag
    rd_ukmo_nc3,dir+ifile+'_adjold.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,qslwa2,qdf2,mark2,vp2,sf2,iflag

    if iflag eq 1 then goto,jump

if n eq 0 then begin
theta=0.
;print,th
;read,'Enter theta ',theta
theta=550.
index=where(theta eq th)
if index(0) eq -1 then stop,'Invalid theta level '
thlev=index(0)
endif
        stheta=strcompress(string(fix(theta)),/remove_all)
        qnoa1=transpose(qnoa2(*,*,thlev))
        qswa1=transpose(qswa2(*,*,thlev))
        qslwa1=transpose(qslwa2(*,*,thlev))

        qnoa=0.*fltarr(nc+1,nr)
        qnoa(0:nc-1,0:nr-1)=qnoa1(0:nc-1,0:nr-1)
        qnoa(nc,*)=qnoa(0,*)

        qswa=0.*fltarr(nc+1,nr)
        qswa(0:nc-1,0:nr-1)=qswa1(0:nc-1,0:nr-1)
        qswa(nc,*)=qswa(0,*)

        qslwa=0.*fltarr(nc+1,nr)
        qslwa(0:nc-1,0:nr-1)=qslwa1(0:nc-1,0:nr-1)
        qslwa(nc,*)=qslwa(0,*)


        x=fltarr(nc+1)
        x(0:nc-1)=alon
        x(nc)=alon(0)+360.

        if setplot eq 'ps' then begin
           lc=0
           set_plot,'ps'
           xsize=nxdim/100.
           ysize=nydim/100.
           !psym=0
           !p.font=0
           device,font_size=9
           device,/landscape,bits=8,$
                   filename='check_q_'+ifile+'_'+stheta+'K.ps'
           device,/color
           device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                  xsize=xsize,ysize=ysize
        endif

      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='!6NO Mass Adjustment'
      xyouts,.25,.9,'!6Q on '+ifile+' at '+stheta+' K',/normal,charsize=2
      nlvls=30
      level=-3.+0.2*findgen(nlvls)
      col1=1+indgen(nlvls)*icolmax/nlvls
      contour,qnoa,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
      contour,qnoa,x,alat,levels=level,/overplot,/follow,$
              c_labels=1+0*level,c_linestyle=level lt 0
      contour,qnoa,x,alat,levels=[0],/overplot,/follow,thick=3,color=0
      imin=min(level)
      imax=max(level)
      ymnb=yorig(0)-cbaryoff
      ymxb=ymnb  +cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax]
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
            xbox=[x1,x1,x1+dx,x1+dx,x1]
            polyfill,xbox,ybox,color=col1(j)
            x1=x1+dx
      endfor

      xmn=xorig(1)
      xmx=xorig(1)+xlen
      ymn=yorig(1)
      ymx=yorig(1)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='!6SW Adjustment'
      contour,qswa,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
      contour,qswa,x,alat,levels=level,/overplot,/follow,$
              c_labels=1+0*level,c_linestyle=level lt 0
      contour,qswa,x,alat,levels=[0],/overplot,/follow,thick=3,color=0
      imin=min(level)
      imax=max(level)
      ymnb=yorig(1) -cbaryoff
      ymxb=ymnb  +cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax]
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
            xbox=[x1,x1,x1+dx,x1+dx,x1]
            polyfill,xbox,ybox,color=col1(j)
            x1=x1+dx
      endfor

      xmn=xorig(2)
      xmx=xorig(2)+xlen
      ymn=yorig(2)
      ymx=yorig(2)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,title='!6SW+LW Adjustment'
      contour,qslwa,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
      contour,qslwa,x,alat,levels=level,/overplot,/follow,$
              c_labels=1+0*level,c_linestyle=level lt 0
      contour,qslwa,x,alat,levels=[0],/overplot,/follow,thick=3,color=0
      imin=min(level)
      imax=max(level)
      ymnb=yorig(2) -cbaryoff
      ymxb=ymnb  +cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax]
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
            xbox=[x1,x1,x1+dx,x1+dx,x1]
            polyfill,xbox,ybox,color=col1(j)
            x1=x1+dx
      endfor

    if setplot eq 'ps' then device, /close
stop
    jump:
endfor		; loop over files
end
