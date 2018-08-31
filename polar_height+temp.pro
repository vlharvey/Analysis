;
; reads in .nc3 and .nc4 marker field and plots polar 
;
@rd_ukmo_nc3

ipan=1
npp=1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
device,decompose=0
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
nxdim=500
nydim=500
xorig=[0.1]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
!p.background=icolmax
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
close,1
openr,1,'polar_height+temp.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin
    readf,1,ifile
    iflag=0
    rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    if iflag eq 1 then goto,jump

if n eq 0 then begin
theta=0.
;print,th
;read,'Enter theta ',theta
theta=800.
index=where(theta eq th)
if index(0) eq -1 then stop,'Invalid theta level '
thlev=index(0)
endif

; Height of isentropic surface = (msf - cp*T)/g
; where T = theta* (p/po)^R/cp and divide by 1000 for km
    speed2=sqrt(u2^2+v2^2)
    temp2=0.*pv2
    zth2=0.*pv2
    for k=0,nth-1 do begin
        temp2(0:nr-1,0:nc-1,k)=th(k)*( (p2(0:nr-1,0:nc-1,k)/1000.)^(.286) )
        zth2(0:nr-1,0:nc-1,k)=(msf2(0:nr-1,0:nc-1,k)-1004.* $
                              temp2(0:nr-1,0:nc-1,k))/(9.86*1000.)
    endfor

        stheta=strcompress(string(fix(theta)),/remove_all)
        qdf1=transpose(qdf2(*,*,thlev))
        sf1=transpose(sf2(*,*,thlev))
        pv1=transpose(pv2(*,*,thlev))
        temp1=transpose(temp2(*,*,thlev))
        zth1=transpose(zth2(*,*,thlev))
        marksf1=transpose(marksf2(*,*,thlev))
        qdf=0.*fltarr(nc+1,nr)
        qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
        qdf(nc,*)=qdf(0,*)
        sf=0.*fltarr(nc+1,nr)
        sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
        sf(nc,*)=sf(0,*)
        pv=0.*fltarr(nc+1,nr)
        pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
        pv(nc,*)=pv(0,*)
        marksf=0.*fltarr(nc+1,nr)
        marksf(0:nc-1,0:nr-1)=marksf1(0:nc-1,0:nr-1)
        marksf(nc,*)=marksf(0,*)
        temp=0.*fltarr(nc+1,nr)
        temp(0:nc-1,0:nr-1)=temp1(0:nc-1,0:nr-1)
        temp(nc,*)=temp(0,*)
        zth=0.*fltarr(nc+1,nr)
        zth(0:nc-1,0:nr-1)=zth1(0:nc-1,0:nr-1)
        zth(nc,*)=zth(0,*)
print,ifile,min(zth(*,nr/2:nr-1)),max(temp(*,nr/2:nr-1))

        x=fltarr(nc+1)
        x(0:nc-1)=alon
        x(nc)=alon(0)+360.
        lon=0.*sf
        lat=0.*sf
        for i=0,nc   do lat(i,*)=alat
        for j=0,nr-1 do lon(*,j)=x

if setplot eq 'ps' then begin
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !psym=0
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='Figures/'+ifile+'_'+stheta+'K_zth+temp.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
          xsize=xsize,ysize=ysize
   !p.thick=2.0                   ;Plotted lines twice as thick
   !p.charsize=2.0
endif

; Set plot boundaries
        erase
        !psym=0
        MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,$
                title=ifile+'  '+stheta+' K',charsize=2.0,latdel=10,color=0
        index=where(lat gt 0.)
        pvmin=min(sf(index))
        pvmax=max(sf(index))
pvmin=pvmin+0.3*pvmin
pvmax=pvmax+0.3*pvmax
        nlvls=21
        pvint=(pvmax-pvmin)/nlvls
        if n eq 0 then pvlevel=pvmin+pvint*findgen(nlvls)
        col1=1+indgen(nlvls)*icolmax/nlvls
        contour,sf,x,alat,/overplot,levels=pvlevel,c_color=col1,/cell_fill,/noeras
        contour,sf,x,alat,/overplot,levels=pvlevel,color=0,/follow,/noeras,c_labels=0*indgen(nlvls)
        MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,color=0
        marksf=smooth(marksf,3)
        contour,marksf,x,alat,levels=[0.1],color=0,thick=20,/overplot
        contour,marksf,x,alat,levels=[-0.1],color=icolmax,thick=20,/overplot

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim Figures/'+ifile+'_'+stheta+'K_zth+temp.ps -rotate -90 Figures/'+ifile+'_'+stheta+'K_zth+temp.jpg'
       spawn,'/usr/bin/rm -f Figures/'+ifile+'_'+stheta+'K_zth+temp.ps'
    endif
    jump:
endfor		; loop over files
end
