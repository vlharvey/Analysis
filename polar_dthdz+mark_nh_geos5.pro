;
; polar plot of NH vortex edge over static stability
; show that highest dthdz values are not inside the vortex > 4000 K ?
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

sver='v2.2'
;sver='v1.52'

loadct,38
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[.15,.55]
yorig=[.4,.4]
xlen=0.3
ylen=0.3
cbaryoff=0.03
cbarydel=0.01
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
RADG = !PI / 180.
FAC20 = 1.0 / TAN(45.*RADG)
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']

!noeras=1
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS520.MetO.'
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'

lstmn=12 & lstdy=20 & lstyr=2006
ledmn=12 & leddy=25 & ledyr=2006
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
;
;print, ' '
;print, '      GEOS Version '
;print, ' '
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
;
; Compute initial Julian date
;
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
      if ndays gt ledday then stop,' normal termination condition '
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy

      rd_geos5_nc3_meto,dir+sdate+'_AVG.V01.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,markold2,sf2,vp2,iflag
      sp2=sqrt(u2^2.+v2^2.)
;
; compute temperature
;
      t2=0.*u2
      for k=0,nth-1 do t2(*,*,k)=th(k)*((p2(*,*,k)/1000.)^(.286))
      z2=(msf2-1004.*t2)/(9.86*1000.)
;
; dtheta/dz = (th1-th0) / (z1-z0)
;
      dthdz2=0.*t2
      for k=0,nth-1 do begin
          lp1=k-1
          lm1=k+1
          IF K EQ 0 then LP1=0
          IF K EQ NTH-1 then LM1=NTH-1
          for i=0,nc-1 do begin
          for j=0,nr-1 do begin
              DTHDz2(j,i,K)=(TH(LP1)-TH(LM1))/(z2(j,i,LP1)-z2(j,i,LM1))
          endfor
          endfor
      endfor
;
; on first day
;
      if icount eq 0L then begin
         x=fltarr(nc+1)
         x(0:nc-1)=alon(0:nc-1)
         x(nc)=alon(0)+360.
         y2d=fltarr(nc+1,nr)
         x2d=fltarr(nc+1,nr)
         for ii=0L,nc do y2d(ii,*)=alat
         for jj=0L,nr-1L do x2d(*,jj)=x
;        rtheta=0.
;        read,'Enter desired theta surface ',rtheta
;        index=where(th eq rtheta)
;        itheta=index(0)
;        stheta=strcompress(fix(th(itheta)),/remove_all)
         icount=1
      endif
;
; loop over theta
;
kcount=0L
      for itheta=0L,nth-1L do begin
         stheta=strcompress(fix(th(itheta)),/remove_all)
         rtheta=th(itheta)
;
; save postscript version
;
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !psym=0
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,filename='polar_dthdz+mark_nh_'+sdate+'_'+stheta+'K_geos5.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
      endif

      markold1=transpose(markold2(*,*,itheta))
      pv1=transpose(pv2(*,*,itheta))
      sp1=transpose(sp2(*,*,itheta))
      dthdz1=transpose(dthdz2(*,*,itheta))
      dthdz=fltarr(nc+1,nr)
      sp=fltarr(nc+1,nr)
      pv=fltarr(nc+1,nr)
      markold=fltarr(nc+1,nr)
      dthdz(0:nc-1,0:nr-1)=dthdz1(0:nc-1,0:nr-1)
      dthdz(nc,*)=dthdz(0,*)
      sp(0:nc-1,0:nr-1)=sp1(0:nc-1,0:nr-1)
      sp(nc,*)=sp(0,*)
      pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
      pv(nc,*)=pv(0,*)
      markold(0:nc-1,0:nr-1)=markold1(0:nc-1,0:nr-1)
      markold(nc,*)=markold(0,*)
index=where(finite(dthdz) ne 1)
if index(0) ne -1L then goto,jumplev
;
; polar plot
;
      erase
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      nlvls=21
      imin=min(dthdz)
      imax=max(dthdz)
      int=(imax-imin)/float(nlvls)
      dthdzbin=imin+int*findgen(nlvls)
      if kcount eq 0L then begin
      level=dthdzbin
      kcount=1
      endif
      col1=1+indgen(nlvls)*icolmax/nlvls
      !p.charthick=2
      xyouts,.35,.75,'GEOS-5 '+sdate+' '+stheta+' K',charsize=2,color=0,/normal
      MAP_SET,90,0,-90,/stereo,/noeras,color=0
      oplot,findgen(361),.1+0.*findgen(361),psym=0,color=0
      contour,dthdz,x,alat,color=0,/noeras,/cell_fill,c_color=col1,levels=dthdzbin,/overplot
      contour,dthdz,x,alat,c_color=0,/noeras,/follow,levels=dthdzbin,/overplot
      index=where(dthdz ge 80.)
;     oplot,x2d(index),y2d(index),psym=8,color=0
;     contour,sp,x,alat,c_color=100,/noeras,/follow,levels=[40.],thick=4,/overplot
;     contour,sp,x,alat,c_color=150,/noeras,/follow,levels=[60.],thick=4,/overplot
;     contour,sp,x,alat,c_color=200,/noeras,/follow,levels=[80.],thick=4,/overplot
;     contour,sp,x,alat,c_color=240,/noeras,/follow,levels=[100.],thick=4,/overplot
      contour,markold,x,alat,c_color=0,/noeras,/follow,levels=[0.5],thick=4,/overplot
      MAP_SET,90,0,-90,/stereo,/noeras,title=mtitle,color=0,/contin,/grid
      set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
      !type=2^2+2^3+2^6
      omin=min(level)
      omax=max(level)
      plot,[omin,omax],[0,0],yrange=[0,10],$
            xrange=[omin,omax],xtitle='d(theta)/dz',/noeras,$
            xstyle=1,charsize=1.5,color=0,charthick=2
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor

      !type=2^2+2^3
      xmn=xorig(1)
      xmx=xorig(1)+xlen
      ymn=yorig(1)
      ymx=yorig(1)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      nlvls=21
      imin=0.
      imax=max(pv)
      int=(imax-imin)/float(nlvls)
      pvbin=imin+int*findgen(nlvls)
      level=dthdzbin
      col1=1+indgen(nlvls)*icolmax/nlvls
      !p.charthick=2
      MAP_SET,90,0,-90,/stereo,/noeras,color=0
      oplot,findgen(361),.1+0.*findgen(361),psym=0,color=0
      contour,pv,x,alat,color=0,/noeras,/cell_fill,c_color=col1,levels=pvbin,/overplot
      contour,pv,x,alat,c_color=0,/noeras,/follow,levels=pvbin,/overplot
      contour,markold,x,alat,c_color=0,/noeras,/follow,levels=[0.5],thick=4,/overplot
      MAP_SET,90,0,-90,/stereo,/noeras,title=mtitle,color=0,/contin,/grid
      set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
      !type=2^2+2^3+2^6
      omin=min(level)
      omax=max(level)
      plot,[omin,omax],[0,0],yrange=[0,10],$
            xrange=[omin,omax],xtitle='PV',/noeras,$
            xstyle=1,charsize=1.5,color=0,charthick=2
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor


    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device,/close
       spawn,'convert -trim polar_dthdz+mark_nh_'+sdate+'_'+stheta+'K_geos5.ps -rotate -90 '+$
                           'polar_dthdz+mark_nh_'+sdate+'_'+stheta+'K_geos5.jpg'
    endif
jumplev: 
    endfor	; loop over theta

goto,jump
end
