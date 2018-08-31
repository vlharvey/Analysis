;
; plot GEOS-5 SF vs PV at 2 levels, one where PV is vortex centered (1000 K) and one where it is not (3600 K)
; superimpose all theta levels
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

loadct,39
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.05,0.515,0.05,0.515]
yorig=[0.55,0.55,0.15,0.15]
xlen=0.325
ylen=0.325
cbaryoff=0.1
cbarydel=0.02
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
stimes=[$
'_AVG.V01.']
slabs=['AVG']
ntimes=n_elements(stimes)
!noeras=1
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS520.MetO.'
lstmn=11L & lstdy=16L & lstyr=2008L
ledmn=11L & leddy=16L & ledyr=2008L
lstday=0L & ledday=0L
;
; get date range
;
print, ' '
print, '      GEOS-5 Version '
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 2000 then lstyr=lstyr+2000
if ledyr lt 2000 then ledyr=ledyr+2000
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
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; --- Test for end condition
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
;
; construct date string
;
      syr=strcompress(iyr,/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
;
; read GEOS-5 data
;
      rd_geos5_nc3_meto,dir+sdate+stimes(0)+'nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
      if iflag eq 1 then goto,jump
      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.
      y2d=fltarr(nc,nr)
      x2d=fltarr(nc,nr)
      for i=0,nc-1 do y2d(i,*)=alat
      for i=0,nr-1 do x2d(*,i)=alon
;
; reduce theta surfaces
;
      zindex=where(th ge 500.,nth)
      th=th(zindex)
      speed2=sqrt(u2^2.+v2^2.)
      col2=reverse(1+indgen(nth)*mcolor/float(nth))
      pv2=reform(pv2(*,*,zindex))
      u2=reform(u2(*,*,zindex))
      v2=reform(v2(*,*,zindex))
      sf2=reform(sf2(*,*,zindex))
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !p.thick=2
         !p.charthick=5
         !p.charthick=5
         !y.thick=2
         !x.thick=2
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='figure_1_'+sdate+'_new.ps'
      endif
      thlev1=3600.
      index=where(th eq thlev1)
      ilev=index(0)
      rlev=th(ilev)
      slev=strcompress(long(th(ilev)),/remove_all)
      sf1=transpose(sf2(*,*,ilev))
      pv1=transpose(pv2(*,*,ilev))
      v1=transpose(v2(*,*,ilev))
      u1=transpose(u2(*,*,ilev))
      speed1=transpose(speed2(*,*,ilev))
      sf=fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1
      sf(nc,*)=sf(0,*)
      pv=fltarr(nc+1,nr)
      pv(0:nc-1,0:nr-1)=pv1
      pv(nc,*)=pv(0,*)
      speed=fltarr(nc+1,nr)
      speed(0:nc-1,0:nr-1)=speed1
      speed(nc,*)=speed(0,*)
;
; SF and 75 m/s isotach
;
      erase
      !type=2^2+2^3
      xyouts,.35,.51,sdate,/normal,color=0,charsize=2
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='!4W!1'
;     level=-1.e-5+1.e-6*findgen(21)
      index=where(y2d gt 0.)
      imax=max(sf(index))
      imin=min(sf(index))
      level=imin+((imax-imin)/float(10))*findgen(10)
      nlvls=n_elements(level)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,sf,x,alat,/overplot,levels=level,c_color=col1,/noeras,/cell_fill
      contour,sf,x,alat,/overplot,levels=level,color=0,/noeras,/follow,c_labels=0,thick=2
      contour,speed,x,alat,/overplot,levels=[75.],color=mcolor,thick=5,/noeras,/follow,c_charsize=1,c_charthick=3
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      oplot,findgen(361),0.2+0.*findgen(361),psym=0,color=0
      xyouts,xmn+0.005,ymx-0.02,slev+' K',/normal,color=0
      imin=min(level)
      imax=max(level)
      xmnb=xorig(0)+xlen+cbaryoff
      xmxb=xmnb+cbarydel
      set_viewport,xmnb,xmxb,yorig(0)+cbarydel,yorig(0)+ylen-cbarydel
      !type=2^2+2^3+2^5+2^7
      plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],title='s!u-1!n',color=0,xticks=4
      xbox=[0,10,10,0,0]
      y1=imin
      dy=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor
;
; PV and 75 m/s isotach
;
      !type=2^2+2^3
      xmn=xorig(1)
      xmx=xorig(1)+xlen
      ymn=yorig(1)
      ymx=yorig(1)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='PV'
      index=where(y2d gt 0.)
      pvmax=max(pv(index))-0.25*(max(pv(index)))
      pvmin=min(pv(index))
;pvmax=.1
pvmin=0.
      pvbin=pvmin+((pvmax-pvmin)/float(10))*findgen(10)
      nlvls=n_elements(pvbin)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,pv,x,alat,/overplot,levels=pvbin,c_color=col1,/cell_fill,/noeras
      contour,pv,x,alat,/overplot,levels=pvbin,color=0,thick=2,/noeras,/follow,c_labels=0
      contour,speed,x,alat,/overplot,levels=[75.],color=mcolor,thick=5,/noeras,/follow,c_charsize=1,c_charthick=3
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      oplot,findgen(361),0.2+0.*findgen(361),psym=8,color=0,symsize=0.1
      xyouts,xmn+0.005,ymx-0.02,slev+' K',/normal,color=0
      imin=pvmin
      imax=pvmax
      xmnb=xorig(1)+xlen+cbaryoff
      xmxb=xmnb+cbarydel
      set_viewport,xmnb,xmxb,yorig(1)+cbarydel,yorig(1)+ylen-cbarydel
      !type=2^2+2^3+2^5+2^7
      plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],title='Km!u2!nkg!u-1!ns!u-1!n    ',$
           color=0,xticks=nlvls/2,xtickformat='(f4.2)'
      xbox=[0,10,10,0,0]
      y1=imin
      dy=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor
;
; 1000 K
;
      thlev=1000.
      index=where(th eq thlev)
      ilev=index(0)
      rlev=th(ilev)
      slev=strcompress(long(th(ilev)),/remove_all)
      sf1=transpose(sf2(*,*,ilev))
      pv1=transpose(pv2(*,*,ilev))
      v1=transpose(v2(*,*,ilev))
      u1=transpose(u2(*,*,ilev))
      speed1=transpose(speed2(*,*,ilev))
      sf=fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1
      sf(nc,*)=sf(0,*)
      pv=fltarr(nc+1,nr)
      pv(0:nc-1,0:nr-1)=pv1
      pv(nc,*)=pv(0,*)
      speed=fltarr(nc+1,nr)
      speed(0:nc-1,0:nr-1)=speed1
      speed(nc,*)=speed(0,*)
      !type=2^2+2^3
      xmn=xorig(2)
      xmx=xorig(2)+xlen
      ymn=yorig(2)
      ymx=yorig(2)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='!4W!1'
;     level=-1.e-5+1.e-6*findgen(21)
      index=where(y2d gt 0.)
      imax=max(sf(index))
      imin=min(sf(index))
      level=imin+((imax-imin)/float(10))*findgen(10)
      nlvls=n_elements(level)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,sf,x,alat,/overplot,levels=level,c_color=col1,/noeras,/cell_fill
      contour,sf,x,alat,/overplot,levels=level,color=0,/noeras,/follow,c_labels=0,thick=2
      contour,speed,x,alat,/overplot,levels=[75.],color=mcolor,thick=5,/noeras,/follow,c_charsize=1,c_charthick=3
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      oplot,findgen(361),0.2+0.*findgen(361),psym=0,color=0
      xyouts,xmn+0.005,ymx-0.02,slev+' K',/normal,color=0
      imin=min(level)
      imax=max(level)
      xmnb=xorig(2)+xlen+cbaryoff
      xmxb=xmnb+cbarydel
      set_viewport,xmnb,xmxb,yorig(2)+cbarydel,yorig(2)+ylen-cbarydel
      !type=2^2+2^3+2^5+2^7
      plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],title='s!u-1!n',color=0,xticks=4
      xbox=[0,10,10,0,0]
      y1=imin
      dy=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor
;
      !type=2^2+2^3
      xmn=xorig(3)
      xmx=xorig(3)+xlen
      ymn=yorig(3)
      ymx=yorig(3)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='PV'
      index=where(y2d gt 0.)
      pvmax=max(pv(index))-0.1*(max(pv(index)))
      pvmin=min(pv(index))
;pvmax=.001
pvmin=0.
      pvbin=pvmin+((pvmax-pvmin)/float(10))*findgen(11)
      nlvls=n_elements(pvbin)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,pv,x,alat,/overplot,levels=pvbin,c_color=col1,/cell_fill,/noeras
      contour,pv,x,alat,/overplot,levels=pvbin,color=0,thick=2,/noeras,/follow,c_labels=0
      contour,speed,x,alat,/overplot,levels=[75.],color=mcolor,thick=5,/noeras,/follow,c_charsize=1,c_charthick=3
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      oplot,findgen(361),0.2+0.*findgen(361),psym=8,color=0,symsize=0.1
      xyouts,xmn+0.005,ymx-0.02,slev+' K',/normal,color=0
      imin=pvmin
      imax=pvmax
      xmnb=xorig(3)+xlen+cbaryoff
      xmxb=xmnb+cbarydel
      set_viewport,xmnb,xmxb,yorig(3)+cbarydel,yorig(3)+ylen-cbarydel
      !type=2^2+2^3+2^5+2^7
      plot,[0,0],[imin,imax],xrange=[0,10],yrange=[imin,imax],title='Km!u2!nkg!u-1!ns!u-1!n    ',$
           color=0,xticks=nlvls/2,xtickformat='(f4.2)'
      xbox=[0,10,10,0,0]
      y1=imin
      dy=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor

      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device,/close
         spawn,'convert -trim figure_1_'+sdate+'_new.ps -rotate -90 figure_1_'+sdate+'_new.jpg'
;        spawn,'/usr/bin/rm figure_1_'+sdate+'_new.ps'
      endif

goto,jump
end
