;
; reads in .nc3 data and plots grey scale QDF, streamfunction
; isopleths, and anticyclone/polar vortex boundaries
;
@rd_ukmo_nc3

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
device,decompose=0
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
setplot='ps'
read,'setplot=',setplot
nxdim=750
nydim=750
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
openr,1,'polar_qdf+sf_sh.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    snum=strcompress(string(n),/remove_all)
    readf,1,ifile
    print,ifile
    iflag=0
    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump

; loop over theta 
    FOR THLEV=0,NTH-1 DO BEGIN
;   FOR THLEV=5,5 DO BEGIN
        theta=th(thlev)
        stheta=strcompress(string(fix(theta)),/remove_all)
        qdf1=transpose(qdf2(*,*,thlev))
        sf1=transpose(sf2(*,*,thlev))
        mark1=transpose(mark2(*,*,thlev))
        qdf=0.*fltarr(nc+1,nr)
        qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
        qdf(nc,*)=qdf(0,*)
        sf=0.*fltarr(nc+1,nr)
        sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
        sf(nc,*)=sf(0,*)
        mark=0.*fltarr(nc+1,nr)
        mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
        mark(nc,*)=mark(0,*)
        lon=0.*sf
        lat=0.*sf
        x=fltarr(nc+1)
        x(0:nc-1)=alon
        x(nc)=x(0)
        for i=0,nc   do lat(i,*)=alat
        for j=0,nr-1 do lon(*,j)=x

        if setplot eq 'ps' then begin
           lc=0
           set_plot,'ps'
           xsize=nxdim/100.
           ysize=nydim/100.
           !psym=0
           !p.font=0
           device,font_size=9
           device,/landscape,bits=8,$
                   filename=snum+'_'+stheta+'K_qdf+sf+edges.ps'
           device,/color
           device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                  xsize=xsize,ysize=ysize
        endif

; Set plot boundaries
        erase
        xmn=xorig(0)
        xmx=xorig(0)+xlen
        ymn=yorig(0)
        ymx=yorig(0)+ylen
        set_viewport,xmn,xmx,ymn,ymx
        !psym=0
        MAP_SET,-90,0,90,/ortho,/noeras,/grid,/contin,$
                title='!6Q on '+ifile+' at '+stheta+' K',charsize=1.5
        nlvls=25
        col1=1+indgen(nlvls)*icolmax/nlvls
        level=-300.+25.*findgen(nlvls)
        contour,qdf,x,alat,/overplot,levels=level,$
                c_color=col1,/cell_fill,/noeras
        contour,qdf,x,alat,/overplot,levels=[0.],$
                c_color=icolmax,/follow,/noeras
        MAP_SET,-90,0,90,/ortho,/noeras,/grid,/contin,/noborder,color=0
        sfmin=min(sf)
        sfmax=max(sf)
        sfint=(sfmax-sfmin)/20.
        sfbin=sfmin+sfint*findgen(20)
        contour,sf,x,alat,/overplot,levels=sfbin,thick=2,/noeras,color=0,$
                c_labels=0+0*sfbin,charsize=3,max_value=9999.
        contour,mark,x,alat,/overplot,levels=[-.1],/noeras,color=icolmax,thick=5
        contour,mark,x,alat,/overplot,levels=[.1],/noeras,color=0,thick=5

if setplot eq 'x' then stop
;filename=snum+'_'+stheta+'K_qdf+sf+edges.ps'
if setplot eq 'ps' then begin
   device, /close
   spawn,snum+'_'+stheta+'K_qdf+sf+edges.ps rotate -90 '+$
         snum+'_'+stheta+'K_qdf+sf+edges.jpg'
endif
    ENDFOR	; loop over theta
    jump:
endfor		; loop over files
end
