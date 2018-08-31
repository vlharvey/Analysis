;
; reads in .nc3 data and plots grey scale QDF, streamfunction
; isopleths, and anticyclone/polar vortex boundaries
;
@rd_ukmo_nc3

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
nlev=20
col1=1+(findgen(nlev)/nlev)*icolmax
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
openr,1,'polar_qdf+sf.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    snum=strcompress(string(n),/remove_all)
    readf,1,ifile
    print,ifile
    iflag=0
    rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump
    dum1=findfile(dir+ifile+'.nc3')
    if dum1(0) ne '' then ncid=ncdf_open(dir+ifile+'.nc3')
    if dum1(0) eq '' then goto,jump
    if n eq 0 then begin
       x=fltarr(nc+1)
       x(0:nc-1)=alon(0:nc-1)
       x(nc)=alon(0)+360.
       dx=x(1)-x(0)
       x2d=fltarr(nc+1,nr)
       y2d=fltarr(nc+1,nr)
       for i=0,nc do y2d(i,*)=alat
       for j=0,nr-1 do x2d(*,j)=x
       qdf2=fltarr(nr,nc,nth)
       sf2=fltarr(nr,nc,nth)
    endif
    ncdf_varget,ncid,9,qdf2
    ncdf_varget,ncid,13,sf2
    ncdf_close,ncid

; loop over theta 
;   FOR THLEV=0,NTH-1 DO BEGIN
    index=where(th eq 500.)
    ilev=index(0)
    FOR THLEV=ilev,ilev DO BEGIN
        theta=th(thlev)
        stheta=strcompress(string(fix(theta)),/remove_all)
        print,theta
        qdf1=transpose(qdf2(*,*,thlev))
        sf1=transpose(sf2(*,*,thlev))
        marksfl1=transpose(marksf2(*,*,thlev))
        marksfh1=transpose(marksf2(*,*,thlev))
        qdf=0.*fltarr(nc+1,nr)
        qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
        qdf(nc,*)=qdf(0,*)
        sf=0.*fltarr(nc+1,nr)
        sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
        sf(nc,*)=sf(0,*)
        marksfl=0.*fltarr(nc+1,nr)
        marksfl(0:nc-1,0:nr-1)=marksfl1(0:nc-1,0:nr-1)
        marksfl(nc,*)=marksfl(0,*)
        marksfh=0.*fltarr(nc+1,nr)
        marksfh(0:nc-1,0:nr-1)=marksfh1(0:nc-1,0:nr-1)
        marksfh(nc,*)=marksfh(0,*)
        lon=0.*sf
        lat=0.*sf
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
                   filename='Figures/'+ifile+'_'+stheta+'K_qdf+sf.ps'
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
        MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,/noborder,$
                title='!6Q and streamfunction isopleths on '+ifile+' at '+stheta+' K'

        level=-200.+20.*findgen(nlev)
        contour,qdf,x,alat,/overplot,levels=level,$
                c_color=col1,/cell_fill,/noeras
        MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,/noborder,color=0
        sfmin=min(sf)
        sfmax=max(sf)
        sfint=(sfmax-sfmin)/15.
        sfbin=sfmin+sfint*findgen(15)
        contour,sf,x,alat,/overplot,levels=sfbin,thick=2,/noeras,color=icolmax,$
                c_labels=0+0*sfbin,charsize=3,max_value=9999.

        lindex=where(marksfl eq 1. and lat gt 0.)
        if lindex(0) ne -1 then ledge=max(sf(lindex))
        tmp=sf
        lelim=where(marksfl ne 1. and lat gt 0.)
        if lelim(0) ne -1 then tmp(lelim)=0.
;       contour,sf,x,alat,/overplot,levels=ledge,/noeras,color=icolmax,thick=10
;       index=where(lat gt 0. and marksfh lt 0.)
;       for i=0,abs(min(marksfh(index)))-1 do begin
;           hindex=where(marksfh eq -1.*(i+1.) and lat gt 0.)
;           if hindex(0) ne -1 then hedge=min(sf(hindex))
;           tmp=sf
;           helim=where(marksfh ne -1.*(i+1.) and lat gt 0.)
;           if helim(0) ne -1 then tmp(helim)=0.
;           contour,sf,x,alat,/overplot,levels=hedge,/noeras,color=icolmax,thick=10
;       endfor

        if setplot eq 'x' then begin
           save=assoc(3,bytarr(750,750))
           img=bytarr(750,750)
           img(0,0)=TVRD(0,0,750,750)
           write_gif,'q+sf_'+ifile+'_'+stheta+'K.gif',img
        endif

; Close PostScript file and return control to X-windows
        if setplot eq 'ps' then device, /close
;stop
    ENDFOR	; loop over theta
    jump:
endfor		; loop over files
end
