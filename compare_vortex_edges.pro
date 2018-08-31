; reads in .mark.nc4 files.  marks polar vortex and anticyclones
; and writes out .nc6 files.

@rd_mark_nc4
@compvort
@marker_lows_sf_v8
@write_mark_nc4

loadct,38
mcolor=!p.color
icolmax=byte(!p.color)
icolmax=fix(icolmax)
a=findgen(8)*(2*!pi/8.)
usersym,2.*cos(a),2.*sin(a),/fill
nr=0L
nc=0L
nth=0L
istart=1+intarr(3)
icount=intarr(3)
dir='/usr72/users/ukmo/Datfiles/ukmo_'
ifile='                             '
close,1
openr,1,'compare_vortex_edges.fil'
nfile=0L
readf,1,nfile
for n=0,nfile-1 do begin

    readf,1,ifile
    print,ifile

; read previously calculated markers
    rd_mark_nc4,dir+ifile+'_mark.nc4',nc,nr,nth,xlon,xlat,th,$
                markpvl2,marksfl2,marksfh2,iflag
    if iflag eq 1 then goto,jump

    file1=dir+ifile+'.nc3'
    dum1=findfile(file1)
    if dum1(0) ne '' then begin
       ncid=ncdf_open(file1)
    endif
    if dum1(0) eq '' then goto,jump

; Read UKMO isentropic data
    pv2=fltarr(nr,nc,nth)
    u2=fltarr(nr,nc,nth)
    v2=fltarr(nr,nc,nth)
    qdf2=fltarr(nr,nc,nth)
    sf2=fltarr(nr,nc,nth)
    ncdf_varget,ncid,3,pv2
    ncdf_varget,ncid,6,u2
    ncdf_varget,ncid,7,v2
    ncdf_varget,ncid,9,qdf2
    ncdf_varget,ncid,13,sf2
    ncdf_close,ncid

    x=fltarr(nc+1)
    x(0:nc-1)=xlon(0:nc-1)
    x(nc)=xlon(0)+360.

    erase
    MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,/noborder

; loop over theta 
;   for thlev=0,nth-1 do begin
    for thlev=0,16 do begin

; extract theta level
    theta=th(thlev)
    print,theta
    u1=transpose(u2(*,*,thlev))
    v1=transpose(v2(*,*,thlev))
    qdf1=transpose(qdf2(*,*,thlev))
    pv1=transpose(pv2(*,*,thlev))
    sf1=transpose(sf2(*,*,thlev))

; introduce relative vorticity
    zeta1=u1*0.0
    compvort,u1,v1,zeta1,xlon,xlat,nc,nr

; northern hemisphere pvmax
      pvmax=max(abs(pv1(0:nc-1,nr/2:nr-2)))
      pvgrad1=pv1*0.0

; normalised PV gradient calculation
for j = 2, nr-3 do begin
    jm1=j-1
    jp1=j+1
    if j eq 0 then jm1=0
    if j eq 0 then dy2=(xlat(1)-xlat(0))*!pi/180.
    if j eq nr-1 then jp1=nr-1
    if j eq nr-1 then dy2=(xlat(nr-1)-xlat(nr-2))*!pi/180.
    if (j gt 0 and j lt nr-1) then dy2=(xlat(jp1)-xlat(jm1))*!pi/180.
    csy=cos(xlat(j)*!pi/180.)
    for i = 0, nc-1 do begin
        ip1 = i+1
        im1 = i-1
        if i eq 0 then im1 = nc-1
        if i eq 0 then dx2 = (xlon(1)-xlon(0))*!pi/180.
        if i eq nc-1 then ip1 = 0
        if i eq nc-1 then dx2 = (xlon(0)-xlon(nc-1))*!pi/180.
        if (i gt 0 and i lt nc-1) then dx2=(xlon(ip1)-xlon(im1))*!pi/180.

        dqdx = (pv1(ip1,j)-pv1(im1,j))/(dx2*csy)
        dqdy = (pv1(i,jp1)-pv1(i,jm1))/dy2
        pvgrad1(i,j) = sqrt(dqdx*dqdx+dqdy*dqdy)*abs(pv1(i,j))/pvmax
        if (dqdy le 0.0) then pvgrad1(i,j) = -sqrt(dqdx*dqdx+dqdy*dqdy)$
                                             *abs(pv1(i,j))/pvmax
    endfor
endfor

; add wrap around longitude for plotting
    u=fltarr(nc+1,nr)
    u(0:nc-1,0:nr-1)=u1(0:nc-1,0:nr-1)
    u(nc,*)=u(0,*)
    v=fltarr(nc+1,nr)
    v(0:nc-1,0:nr-1)=v1(0:nc-1,0:nr-1)
    v(nc,*)=v(0,*)
speed=sqrt(u^2. +v^2.)
    qdf=0.*fltarr(nc+1,nr)
    qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
    qdf(nc,*)=qdf(0,*)
    pv=0.*fltarr(nc+1,nr)
    pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
    pv(nc,*)=pv(0,*)
    sf=0.*fltarr(nc+1,nr)
    sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
    sf(nc,*)=sf(0,*)
    zeta=fltarr(nc+1,nr)
    zeta(0:nc-1,0:nr-1)=zeta1(0:nc-1,0:nr-1)
    zeta(nc,*)=zeta(0,*)
    pvgrad=fltarr(nc+1,nr)
    pvgrad(0:nc-1,0:nr-1)=pvgrad1(0:nc-1,0:nr-1)
    pvgrad(nc,*)=pvgrad(0,*)
pvgrad=pvgrad*speed
for i=0,4 do pvgrad=smooth(pvgrad,5,/edge_truncate)

; streamfunction based polar vortex marker
    marksfl=0.*sf
    marker_lows_sf_v8,sf,marksfl,qdf,zeta,u,v,x,xlat

; potential vorticity based polar vortex marker
    markpvl=0.*pv

;NH SF
;erase
nbins=20
lon=0.*sf
lat=0.*sf
for i=0,n_elements(x)-1 do lat(i,*)=xlat
for j=0,n_elements(xlat)-1 do lon(*,j)=x
y2d=lat
x2d=lon
latmin=0.
latmax=90.
;set_viewport,.1,.9,.1,.9
kk=where(lat gt latmin)
sf=pv
pvmin=min(sf(kk))
pvmax=max(sf(kk))
pvint=(pvmax-pvmin)/(nbins)
pvbin=pvmin+pvint*findgen(nbins)
!psym=0
;contour,sf,x,xlat,/overplot,levels=pvbin,thick=1
for i=0,nc-1 do begin
    index1=where(y2d(i,*) gt 0.)
    index2=where(pvgrad(i,index1) eq max(pvgrad(i,index1)))
    oplot,[x(i),x(i)],[xlat(index1(index2)),xlat(index1(index2))],$
          psym=8,color=mcolor*(thlev+2)/float(18)
;print,x(i),xlat(index1(index2)),max(pvgrad(i,index1))
endfor

;; plot outer sf contour of Arctic vortex
;index=where(y2d gt 0. and marksfl gt 0.)
;if index(0) ne -1 then begin
;   sedge=max(sf(index))
;   index=where(y2d gt 0. and sf le sedge)
;   contour,sf,x,xlat,levels=[sedge],color=mcolor*.9,c_labels=[0],$
;           thick=10,c_linestyle=0,/overplot
;endif           ; if there is a vortex at this level

;; plot outer PV contour of Arctic vortex
;index=where(y2d gt 0. and markpvl gt 0.)
;if index(0) ne -1 then begin
;   sedge=min(pv(index))
;   index=where(y2d gt 0. and pv ge sedge)
;   contour,pv,x,xlat,levels=[sedge],color=mcolor*.5,c_labels=[0],$
;           thick=5,c_linestyle=0,/overplot
;endif          
    ENDFOR	; loop over theta
stop

    jump:
endfor		; loop over files
end
