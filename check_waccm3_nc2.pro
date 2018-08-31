;
; reads in .nc2 files.  marks polar vortex and anticyclones
;
@stddat
@kgmt
@ckday
@kdate

loadct,38
mcolor=byte(!p.color)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.25]
xlen=0.7
ylen=0.5
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
dirh='/aura3/data/WACCM_data/Datfiles/mee00fco.vars.h3.'
lstmn=1 & lstdy=6 & lstyr=2060 & lstday=0
ledmn=1 & leddy=6 & ledyr=2060 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
print, ' '
print, '      WACCM Version '
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; test for end condition and close windows.
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
      sday=string(FORMAT='(i3.3)',iday-1)
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      sdate=syr+smn+sdy
;
;***Read WACCM data
      dum=findfile(dirh+sdate+'.nc2')
      if dum(0) ne '' then begin
         ifile=dirh+sdate+'.nc2'
      endif
      ncid=ncdf_open(ifile)
      ncdf_diminq,ncid,0,name,nr
      ncdf_diminq,ncid,1,name,nc
      ncdf_diminq,ncid,2,name,nth
      xlon=fltarr(nc)
      xlat=fltarr(nr)
      th=fltarr(nth)
      pv2=fltarr(nr,nc,nth)
      p2=fltarr(nr,nc,nth)
      msf2=fltarr(nr,nc,nth)
      u2=fltarr(nr,nc,nth)
      v2=fltarr(nr,nc,nth)
      qdf2=fltarr(nr,nc,nth)
      vp2=fltarr(nr,nc,nth)
      sf2=fltarr(nr,nc,nth)
      ncdf_varget,ncid,0,xlon
      ncdf_varget,ncid,1,xlat
      ncdf_varget,ncid,2,th
      ncdf_varget,ncid,3,pv2
      ncdf_varget,ncid,4,p2
      ncdf_varget,ncid,5,u2
      ncdf_varget,ncid,6,v2
      ncdf_varget,ncid,7,qdf2
      ncdf_varget,ncid,8,vp2
      ncdf_varget,ncid,9,sf2
      ncdf_close,ncid
      print,'read ',ifile
      x=fltarr(nc+1)
      x(0:nc-1)=xlon(0:nc-1)
      x(nc)=xlon(0)+360.
      mark2=0.*qdf2
;
; compute 3d relative vorticity (this version of compvort requires dimensions lon,lat,lev
;
      zz=fltarr(nc,nr,nth)
      uu=fltarr(nc,nr,nth)
      vv=fltarr(nc,nr,nth)
      for k=0,nth-1 do begin
          uu(*,*,k)=transpose(u2(*,*,k))
          vv(*,*,k)=transpose(v2(*,*,k))
      endfor
      relvort,uu,vv,zz,xlon,xlat,nc,nr
      zeta2=0.*qdf2
      for k=0,nth-1 do zeta2(*,*,k)=transpose(zz(*,*,k))

; loop over theta
      for thlev=0,nth-1 do begin
          theta=th(thlev)
          u1=transpose(u2(*,*,thlev))
          v1=transpose(v2(*,*,thlev))
          qdf1=transpose(qdf2(*,*,thlev))
          sf1=transpose(sf2(*,*,thlev))
          zeta1=transpose(zeta2(*,*,thlev))
          zeta=fltarr(nc+1,nr)
          zeta(0:nc-1,0:nr-1)=zeta1(0:nc-1,0:nr-1)
          zeta(nc,*)=zeta(0,*)
          u=fltarr(nc+1,nr)
          u(0:nc-1,0:nr-1)=u1(0:nc-1,0:nr-1)
          u(nc,*)=u(0,*)
          v=fltarr(nc+1,nr)
          v(0:nc-1,0:nr-1)=v1(0:nc-1,0:nr-1)
          v(nc,*)=v(0,*)
          qdf=fltarr(nc+1,nr)
          qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
          qdf(nc,*)=qdf(0,*)
          sf=0.*fltarr(nc+1,nr)
          sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
          sf(nc,*)=sf(0,*)
          x2d=0.*sf
          y2d=0.*sf
          for i=0,nc do y2d(i,*)=xlat
          for j=0,nr-1 do x2d(*,j)=x
erase
!type=2^2+2^3
imin=min(zeta) & imax=max(zeta)
nlvls=30
level=imin+((imax-imin)/nlvls)*findgen(nlvls)
map_set,0,0,0,/contin,/grid,/noeras
contour,zeta,x,xlat,levels=level,/overplot,/noeras,title=string(th(thlev)),c_linestyle=(level lt 0.)
contour,sf,x,xlat,nlevels=20,/noeras,/overplot,thick=3
index=where(qdf lt 0.)
if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=2,color=mcolor*.3,symsize=0.5
index=where(qdf gt 0.)
if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=2,color=mcolor*.9,symsize=0.5
stop
      ENDFOR	; loop over theta

      goto,jump
end
