;
; Upper Stratosphere (US) version
; reads in .nc3 and plots polar projection of PV and the vortex edge at 2000 K
; plus isotachs at 340 K in the upper troposphere
;
@stddat
@kgmt
@ckday
@kdate
@rd_merra2_nc3
@drawvectors

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='ps'
read,'setplot=',setplot
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.03
cbarydel=0.02
!NOERAS=-1
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
dir='/atmos/harvey/MERRA2_data/Datfiles/MERRA2-on-WACCM_theta_'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
lstmn=3L & lstdy=1L & lstyr=2011
ledmn=3L & leddy=31L & ledyr=2011
lstday=0L & ledday=0L
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then spawn,'date'
      if ndays gt ledday then stop,' normal termination condition '

      if iyr ge 2000 then iyr1=iyr-2000
      if iyr lt 2000 then iyr1=iyr-1900
      syr=string(FORMAT='(I4.4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      print,sdate
;
; read data
;
      dum=findfile(dir+sdate+'00.nc3')
      if dum ne '' then ncfile0=dir+sdate+'00.nc3'
      rd_merra2_nc3,ncfile0,nc,nr,nth,alon,alat,th,pv2,p2,$
         u2,v2,qdf2,mark2,qv2,z2,sf2,q2,o32,iflag
      if iflag ne 0L then goto,jump
      tmp2=0.*p2
      for k=0L,nth-1L do tmp2(*,*,k)=th(k)*(p2(*,*,k)/1000.)^0.286
;
; normalize marker
;
      index=where(mark2 lt 0.)
      if index(0) ne -1L then mark2(index)=-1.

      if icount eq 0 then begin
         theta=4000.
;        print,th
;        read,'Enter theta ',theta
         index=where(theta eq th)
         if index(0) eq -1 then stop,'Invalid theta level '
         thlev=index(0)
      endif
      theta=th(thlev)
      stheta=strcompress(string(fix(theta)),/remove_all)
      qdf1=transpose(qdf2(*,*,thlev))
      sf1=transpose(sf2(*,*,thlev))
      pv1=transpose(pv2(*,*,thlev))
      u1=transpose(u2(*,*,thlev))
      v1=transpose(v2(*,*,thlev))
      z1=transpose(z2(*,*,thlev))
      sp1=sqrt(u1^2.+v1^2.)
      mark1=transpose(mark2(*,*,thlev))
      qdf=0.*fltarr(nc+1,nr)
      qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
      qdf(nc,*)=qdf(0,*)
      z=0.*fltarr(nc+1,nr)
      z(0:nc-1,0:nr-1)=z1(0:nc-1,0:nr-1)
      z(nc,*)=z(0,*)
      sf=0.*fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
      sf(nc,*)=sf(0,*)
      sp=0.*fltarr(nc+1,nr)
      sp(0:nc-1,0:nr-1)=sp1(0:nc-1,0:nr-1)
      sp(nc,*)=sp(0,*)
      pv=0.*fltarr(nc+1,nr)
      pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
      pv(nc,*)=pv(0,*)
      mark=0.*fltarr(nc+1,nr)
      mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
      mark(nc,*)=mark(0,*)
      x=fltarr(nc+1)
      x(0:nc-1)=alon
      x(nc)=alon(0)+360.
      lon=0.*sf
      lat=0.*sf
      for i=0,nc   do lat(i,*)=alat
      for j=0,nr-1 do lon(*,j)=x
;
; read COgrad marker
;
      restore,'/Users/harvey/Harvey_etal_2018_COgrad/Code/Save_files/daily_mls_coelatedge+merra2_sfelatedge_'+syr+smn+'_2d_nh.sav'
today=where(SDATE_TIME eq sdate)
if today(0) ne -1L then MARKMLS3D=reform(MARKMLS4D(*,*,*,today(0)))
if theta eq 4000. then markmls2d=reform(markmls3d(*,*,26))
 
loadct,39
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
;        !p.font=0
         device,font_size=9
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                /bold,/color,bits_per_pixel=8,/times,filename='polar_pv_merra2_'+sdate+'_'+stheta+'K.ps'
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !p.charthick=5
         !y.thick=2
         !x.thick=2
      endif
      erase
      !psym=0
      !type=2^2+2^3
      !p.charthick=2
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,/noborder,$
              title=sdate,charsize=2.0,latdel=10,color=0,limit=[15,0,90,360]
      oplot,findgen(361),0.1+0.*findgen(361),color=0
      index=where(lat gt 0.)
      if icount eq 0L then begin
      imin=0	;min(pv)
      imax=max(pv)
      endif
      nlvls=20
      pvint=(imax-imin)/float(nlvls)
      level=imin+pvint*findgen(nlvls)
;print,level
loadct,23
      col1=1+indgen(nlvls)*icolmax/float(nlvls)
      contour,pv,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
      contour,pv,x,alat,/overplot,levels=level,/follow,$
              c_labels=0*level,/noeras,color=0
drawvectors,nc,nr,alon,alat,u1,v1,5,1
;
; vortex edge at all levels
;
;      contour,mark,x,alat,/overplot,levels=[-0.1],thick=10,color=0
      contour,mark,x,alat,/overplot,levels=[0.1],thick=15,color=0
      contour,markmls2d,alon,alat,/overplot,levels=[0.1],thick=15,color=250

;     for k=nth-1,0,-1 do begin
;           theta=th(k)
;           stheta=strcompress(string(fix(theta)),/remove_all)
;           mark1=transpose(mark2(*,*,k))
;           mark=0.*fltarr(nc+1,nr)
;           mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
;           mark(nc,*)=mark(0,*)
;           contour,mark,x,alat,/overplot,levels=[0.1],thick=10,color=(float(k)/float(nth))*mcolor,c_label=stheta,c_charsize=1.5,c_charthick=2
;     endfor
;index=where(lat gt 0. and pv lt 0.)
;if index(0) ne -1L then oplot,lon(index),lat(index),psym=8,color=0
loadct,39
     contour,z,x,alat,/overplot,nlevels=20,thick=2,color=mcolor
loadct,23
     contour,sp,x,alat,/overplot,levels=[40.],thick=5,color=.75*mcolor
     contour,sp,x,alat,/overplot,levels=[50.],thick=5,color=.85*mcolor
     contour,sp,x,alat,/overplot,levels=[70.],thick=5,color=.95*mcolor
;    contour,sp,x,alat,/overplot,levels=[90.],thick=5,color=.95*mcolor
      MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,/noborder,charsize=2.0,latdel=10,color=0,limit=[15,0,90,360]
      ymnb=ymn -cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],$
            xrange=[imin,imax],xtitle='MERRA-2 '+stheta+' K Potential Vorticity',/noeras,$
            charsize=1.5,color=0,charthick=2
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
      endfor

      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device, /close
         spawn,'convert -trim polar_pv_merra2_'+sdate+'_'+stheta+'K.ps -rotate -90 polar_pv_merra2_'+sdate+'_'+stheta+'K.png'
;        spawn,'rm -f polar_pv_merra2_'+sdate+'_'+stheta+'K.ps'
      endif
      icount=icount+1L
goto,jump
end
