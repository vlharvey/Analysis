;
; plot a mercator projection of QDF
; VLH 8/13/2003
;
@rd_ukmo_nc3			; subroutine to read UKMO data
;
; load rainbow color table
;
loadct,38
mcolor=fix(byte(!p.color))
if mcolor eq 0 then mcolor=255
nlvls=20
col1=1+indgen(nlvls)*mcolor/nlvls
;
; user defined symbol (psym=8) as a filled circle
;
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
;
; choose to plot to the screen ('x') or to a postscript file ('ps')
;
setplot='x'
read,'setplot=',setplot
;
; set dimensions of plot window
;
nxdim=750 & nydim=750
xorig=[0.15]
yorig=[0.35]
xlen=0.75 & ylen=0.55
cbaryoff=0.15
cbarydel=0.02
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=mcolor
   lc2=0
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
;
; open input file containing filenames
;
close,1
openr,1,'merc_temp.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
;
; read UKMO isentropic data
;
    iflag=0
    rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
       pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
;
; if data file doesn't exist
;
    if iflag eq 1 then goto,jump
;
; on the first day choose level to plot
;
    if n eq 0 then begin
       theta=0.
       print,th
       read,'Enter theta ',theta
       index=where(theta eq th)
       if index(0) eq -1 then stop,'Invalid theta level '
       thlev=index(0)
       stheta=strcompress(string(fix(theta)),/remove_all)
    endif
;
; extract desired level from 3-D arrays
;
    p1=transpose(p2(*,*,thlev))
; 
; calculate temperature: T=theta*(p/po)^(R/cp) where po=1000 hPa
;
    temp1=th(thlev)*( (p1/1000.)^(.286) )
;
; add wrap-around point in longitude for plotting
;
    temp=0.*fltarr(nc+1,nr)
    temp(0:nc-1,0:nr-1)=temp1(0:nc-1,0:nr-1)
    temp(nc,*)=temp(0,*)
    x=fltarr(nc+1)
    x(0:nc-1)=alon
    x(nc)=alon(0)+360.
;
; print daily min/max temperature
;
    tstats=strcompress(string(FORMAT='(F5.1,A1,F5.1)',$
           min(temp),'-',max(temp)))
    print,th(thlev),'   ',tstats
;
; if postscript file
;
    if setplot eq 'ps' then begin
       lc=0
       lc2=mcolor
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !psym=0
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename=ifile+'_'+stheta+'K_temp.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
;
; set plot boundaries
;
    erase
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
;
; on the first day, set levels to plot
;
    if n eq 0 then begin
       tmin=min(temp)-10.
       tmax=max(temp)+10.
       tint=(tmax-tmin)/(nlvls-1)
       tlevel=tmin+tint*findgen(nlvls)
    endif
    !type=2^2+2^3
    contour,temp,x,alat,levels=tlevel,c_color=col1,/cell_fill,/noeras,$
            title='!6UKMO Temperature at '+stheta+' K on '+ifile,charsize=2,$
            xticks=6,xtitle='!6Longitude',yticks=6,ytitle='!6Latitude',$
            xtickname='!6'+['0','60','120','180','240','300','360'],$
            ytickname='!6'+['90S','60S','30S','EQ','30N','60N','90N']
    contour,temp,x,alat,/overplot,levels=tlevel,c_color=lc,$
            c_labels=1+0*tlevel,/follow,/noeras
    contour,temp,x,alat,/overplot,levels=180.+2.*findgen(11),/follow,$
            c_color=lc2,thick=2,/noeras,c_labels=1+0*findgen(11)
;
; superimpose mercator map
;
    MAP_SET,0,180,0,/merc,/noeras,/grid,/contin,latdel=10,charsize=2
;
; draw color bar
;
    ymnb=yorig(0)-cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn,xmx,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[min(tlevel),max(tlevel)],[0,0],yrange=[0,10],$
         xrange=[min(tlevel),max(tlevel)],charsize=2,$
         xtitle='!6degrees Kelvin'
    ybox=[0,10,10,0,0]
    x1=min(tlevel)
    dx=(max(tlevel)-min(tlevel))/float(nlvls)
    for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
    endfor
;
; close postscript file
;
    if setplot eq 'ps' then device, /close
;
; if plotted to the screen, save as a .gif image
;
    if setplot eq 'x' then begin
       save=assoc(3,bytarr(nxdim,nydim))
       img=bytarr(nxdim,nydim)
       img(0,0)=TVRD(0,0,nxdim,nydim)
       write_gif,ifile+'_'+stheta+'K_temp.gif',img
       stop
    endif

    jump:
endfor		; loop over files
end
