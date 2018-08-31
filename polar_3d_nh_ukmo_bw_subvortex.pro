;
; SOLVE II theta range 240-800 K
; plot subvortex
; all levels
; 1 panel

@rd_ukmo_nc3
@rd_ukmo_subvortex

loadct,38
mcolor=!p.color
icolmax=byte(!p.color)
icolmax=fix(icolmax)
a=findgen(8)*(2*!pi/8.)
usersym,2*cos(a),2*sin(a),/fill
nxdim=700
nydim=700
cbaryoff=0.04
cbarydel=0.02
set_plot,'x'
setplot='x'
;read,'setplot= ',setplot
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
!noeras=1
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifiles=[$
'ukmo_nh_files_91-92.fil',$
'ukmo_nh_files_92-93.fil',$
'ukmo_nh_files_93-94.fil',$
'ukmo_nh_files_94-95.fil',$
'ukmo_nh_files_95-96.fil',$
'ukmo_nh_files_96-97.fil',$
'ukmo_nh_files_97-98.fil',$
'ukmo_nh_files_98-99.fil',$
'ukmo_nh_files_99-00.fil',$
'ukmo_nh_files_00-01.fil',$
'ukmo_nh_files_01-02.fil',$
'ukmo_nh_files_02-03.fil',$
'ukmo_nh_files_03-04.fil']
odirs=[$
'1991-1992/',$
'1992-1993/',$
'1993-1994/',$
'1994-1995/',$
'1995-1996/',$
'1996-1997/',$
'1997-1998/',$
'1998-1999/',$
'1999-2000/',$
'2000-2001/',$
'2001-2002/',$
'2002-2003/',$
'2003-2004/']
nyear=n_elements(odirs)
!noeras=1
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
for iyear=0,nyear-1 do begin
close,1
openr,1,ifiles(iyear)
nfile=0L
nn=0L
readf,1,nfile
for l=0,nfile-1 do begin
    readf,1,ifile
    mindex=where(strmid(ifile,0,3) eq mon)
;
; this logic will work through 2090
;
    if strmid(ifile,7,1) eq '9' then $
       date=strmid(ifile,4,2)+' '+month(mindex(0))+' 19'+strmid(ifile,7,2)
    if strmid(ifile,7,1) ne '9' then $
       date=strmid(ifile,4,2)+' '+month(mindex(0))+' 20'+strmid(ifile,7,2)
    rd_ukmo_nc3,dir+ifile+'_solve2.nc3',nc,nr,nth,alon,alat,th,$
                pv2,p2,msf2,u2,v2,q2,qdf2,marksf2,vp2,sf2,iflag
    rd_ukmo_subvortex,'Datfiles/'+ifile+'_solve2.nc3.subvortex',nc,nr,nth,$
                alon,alat,th,subvortex2
;
; Height of isentropic surface = (msf - cp*T)/g
; where T = theta* (p/po)^R/cp and divide by 1000 for km
;
    speed2=sqrt(u2^2+v2^2)
    temp2=0.*pv2
    zth2=0.*pv2
    for k=0,nth-1 do begin
        temp2(0:nr-1,0:nc-1,k)=th(k)*( (p2(0:nr-1,0:nc-1,k)/1000.)^(.286) )
        zth2(0:nr-1,0:nc-1,k)=(msf2(0:nr-1,0:nc-1,k)-1004.* $
                              temp2(0:nr-1,0:nc-1,k))/(9.86*1000.)
    endfor
    x=fltarr(nc+1)
    x(0:nc-1)=alon(0:nc-1)
    x(nc)=alon(0)+360.

; select theta levels to plot
    if l eq 0 then begin
       thindex=where(th ge 280,nth2)
       th2=th(thindex)
       thlw=th2(nth2-1)
       thup=th2(0)
       thlab=strcompress(string(fix(th2)),/remove_all)
       thlab='!6'+reverse(thlab)
       nr2=nr/2
       x2d=fltarr(nc+1,nr2)
       y2d=fltarr(nc+1,nr2)
       for i=0,nc do y2d(i,*)=alat(nr2:nr-1)
       for j=0,nr2-1 do x2d(*,j)=x
       dy=alat(1)-alat(0)
       dx=alon(1)-alon(0)
       xcn=fltarr(nc+1,nr2)
       ycn=fltarr(nc+1,nr2)
       for j=nr2,nr-1 do begin
           ANG = (90. - alat(j)) * RADG * 0.5
           FACTOR = TAN(ANG) * FAC20
           for i=0,nc do begin
               THETA = (x(i) - 90.) * RADG
               xcn(i,j-nr2) = FACTOR * COS(THETA)
               ycn(i,j-nr2) = FACTOR * SIN(THETA)
           endfor
       endfor
    endif
;
; truncate arrays based on levels chosen to plot
;
    subvortex2=reform(subvortex2(*,*,thindex),nr,nc,nth2)
    marksf2=reform(marksf2(*,*,thindex),nr,nc,nth2)
    sf2=reform(sf2(*,*,thindex),nr,nc,nth2)
    speed2=reform(speed2(*,*,thindex),nr,nc,nth2)
    temp2=reform(temp2(*,*,thindex),nr,nc,nth2)
    zth2=reform(zth2(*,*,thindex),nr,nc,nth2)

; save postscript version
    if setplot eq 'ps' then begin
       lc=0
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='Postscript/'+ifile+'_subvortex.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
;
; contour 3-D subvortex
;
    erase
    xrot=30
    zrot=0
    set_viewport,0.,1.,0.,1.
    !type=2^6+2^5     ; suppress x and y axes
    dum=fltarr(nc+1,nr2)
    surface,dum,xcn,ycn,xrange=[-1.0,1.0],yrange=[-1.0,1.0],/noeras,$
            zrange=[0.,1.],/save,/nodata,zstyle=4,charsize=3,$
            ax=xrot,az=zrot
    nz=fltarr(nth2)
    nz3=fltarr(nth2)
    for kk=0,nth2-1 do begin
        nz(kk)=kk*(1./(nth2-1.))
        nz3(kk)=(kk+4.)*(1./(nth2+8.))
    endfor
    for kk=0,nth2-1 do begin
        lev=nth2-1-kk
        sflmark1=transpose(subvortex2(*,*,lev))
        sfhmark1=transpose(marksf2(*,*,lev))
        sf1=transpose(sf2(*,*,lev))
        zth1=transpose(zth2(*,*,lev))
        speed1=transpose(speed2(*,*,lev))
        temp1=transpose(temp2(*,*,lev))

        sflmark=fltarr(nc+1,nr2)
        sflmark(0:nc-1,0:nr2-1)=sflmark1(0:nc-1,nr2:nr-1)
        sflmark(nc,*)=sflmark(0,*)
        sfhmark=fltarr(nc+1,nr2)
        sfhmark(0:nc-1,0:nr2-1)=sfhmark1(0:nc-1,nr2:nr-1)
        sfhmark(nc,*)=sfhmark(0,*)
        sf=fltarr(nc+1,nr2)
        sf(0:nc-1,0:nr2-1)=sf1(0:nc-1,nr2:nr-1)
        sf(nc,*)=sf(0,*)
        speed=fltarr(nc+1,nr2)
        speed(0:nc-1,0:nr2-1)=speed1(0:nc-1,nr2:nr-1)
        speed(nc,*)=speed(0,*)
        zth=fltarr(nc,nr2)
        zth(0:nc-1,0:nr2-1)=zth1(0:nc-1,nr2:nr-1)
        result=moment(zth)
        avgz=result(0)
        savgz=strcompress(string(FORMAT='(f4.1)',avgz),/remove_all)

; draw latitude circles at top and bottom
        if kk eq 0 or kk eq nth2-1 then begin
        lon=findgen(361)
        lonp=0.*lon
        latp=0.*lon
        for k=0,2 do begin
            if k eq 0 then lat=0.+0.*fltarr(361)
            if k eq 1 then lat=30.+0.*fltarr(361)
            if k eq 2 then lat=60.+0.*fltarr(361)
            for j=0,360 do begin
                ANG = (90. - lat(j)) * RADG * 0.5
                FACTOR = TAN(ANG) * FAC20
                THETA = (lon(j) - 90.) * RADG
                lonp(j) = FACTOR * COS(THETA)
                latp(j) = FACTOR * SIN(THETA)
            endfor
!p.linestyle=0
if k eq 0 then !p.linestyle=1
            oplot,lonp,latp,/T3D,zvalue=nz(kk),color=lc
!p.linestyle=0
if k eq 1 then begin
index=where(lon eq 90.)
xyouts,lonp(index(0)),latp(index(0)),z=nz(kk),'!690E',color=lc,$
       /data,charsize=3,alignment=0.5,/t3d
plots,lonp(index(0)),latp(index(0)),z=nz(kk),/t3d

index=where(lon eq 270.)
xyouts,lonp(index(0)),latp(index(0)),z=nz(kk),'!6270E',color=lc,$
       /data,charsize=3,alignment=0.5,/t3d
plots,lonp(index(0)),latp(index(0)),z=nz(kk),/t3d,/continue

index=where(lon eq 180.)
xyouts,lonp(index(0)),latp(index(0)),z=nz(kk),'!6180',color=lc,$
       /data,charsize=3,alignment=0.5,/t3d
plots,lonp(index(0)),latp(index(0)),z=nz(kk),/t3d

index=where(lon eq 360.)
xyouts,lonp(index(0)),latp(index(0)),z=nz(kk),'!6GM',color=lc,$
       /data,charsize=3,alignment=0.5,/t3d
plots,lonp(index(0)),latp(index(0)),z=nz(kk),/t3d,/continue
endif
        endfor
        endif
        lindex=where(sflmark eq 1.)
        if lindex(0) ne -1 then begin
           oplot,xcn(lindex),ycn(lindex),/T3D,zvalue=nz(kk),color=lc,psym=8,symsize=1.5
           contour,sflmark,xcn,ycn,levels=[0.1],color=mcolor*.15,/T3D,$
                   zvalue=nz(kk),thick=3
        endif
;
; mark anticyclones
;
;       hindex=where(sfhmark lt 0.)
;       if hindex(0) ne -1 then begin
;          oplot,xcn(hindex),ycn(hindex),/T3D,zvalue=nz(kk),color=lc,symsize=2,psym=8
;          contour,sfhmark,xcn,ycn,levels=[-0.1],color=mcolor*.05,/T3D,$
;                  zvalue=nz(kk),thick=5
;       endif                   ; if anticyclones
;
; draw isotachs
;
;       index=where(y2d gt 0.)
;       start=max(speed(index))
;       slevel=start-15.+5.*findgen(4)
;       index=where(speed eq start)
;       yjet=y2d(index(0))
;       if yjet lt 40. then $
;       contour,speed,xcn,ycn,levels=slevel,color=lc*.9,$
;               c_labels=0+0L*slevel,/T3D,zvalue=nz(kk),thick=2
;       if yjet ge 40. then $
;       contour,speed,xcn,ycn,levels=slevel,color=lc*.55,$
;               c_labels=0+0L*slevel,/T3D,zvalue=nz(kk)
;       contour,sflmark,xcn,ycn,levels=[0.1],color=mcolor*.15,/T3D,$
;               zvalue=nz(kk),thick=3


        xyouts,.06,nz3(kk),thlab(kk),color=lc,/normal,charsize=1.5
        xyouts,.89,nz3(kk),savgz,color=lc,/normal,charsize=1.5
    endfor	; loop over stacked polar plots
    xyouts,.04,.88,'!6Theta (K)',charsize=2,/normal
    xyouts,.76,.88,'!6Altitude (km)',charsize=2,/normal
    xyouts,.25,0.95,'!6'+date,/normal,charsize=3
    if setplot eq 'ps' then device,/close
    if setplot eq 'x' then begin
       save=assoc(3,bytarr(nxdim,nydim))
       img=bytarr(nxdim,nydim)
       img(0,0)=TVRD(0,0,nxdim,nydim)
       write_gif,odirs(iyear)+ifile+'_subvortex.gif',img
    endif
;   stop
    jump:
endfor	; loop over days
endfor
end
