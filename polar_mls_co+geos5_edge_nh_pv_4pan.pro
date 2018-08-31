;
; enter altitude and plot MLS CO and GEOS-5 Arctic vortex
; plot PV and isotachs.  4 panel
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

sver='v2.2'

loadct,38
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[.1,.55,.1,.55]
yorig=[.55,.55,.1,.1]
xlen=0.35
ylen=0.35
cbaryoff=0.02
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
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
lstmn=11L & lstdy=1L & lstyr=2007L
ledmn=11L & leddy=20L & ledyr=2007L
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
      rd_geos5_nc3_meto,dir+sdate+'_1200.V01.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
      if iflag eq 1 then goto,jump
;
; read new vortex
;
      ncid=ncdf_open(dir+sdate+'_1200.V01.nc5')
      marknew2=fltarr(nr,nc,nth)
      ncdf_varget,ncid,3,marknew2
      ncdf_close,ncid

      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.
;
; select theta level to plot
;
      if icount eq 0 then begin
         rlev=4000.
         print,th
;        read,' Enter desired theta surface ',rlev
         zindex=where(th eq rlev)
         ilev=zindex(0)
         slev=strcompress(th(ilev),/remove_all)+'K'
      endif
      speed2=sqrt(u2^2.+v2^2.)
      mark1=transpose(mark2(*,*,ilev))
      marknew1=transpose(marknew2(*,*,ilev))
      sf1=transpose(sf2(*,*,ilev))
      pv1=transpose(pv2(*,*,ilev))*1.e6
      p1=transpose(p2(*,*,ilev))
      u1=transpose(u2(*,*,ilev))
      speed1=transpose(speed2(*,*,ilev))
      mark=fltarr(nc+1,nr)
      mark(0:nc-1,0:nr-1)=mark1
      mark(nc,*)=mark(0,*)
      marknew=fltarr(nc+1,nr)
      marknew(0:nc-1,0:nr-1)=marknew1
      marknew(nc,*)=marknew(0,*)
      sf=fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1
      sf(nc,*)=sf(0,*)
      pv=fltarr(nc+1,nr)
      pv(0:nc-1,0:nr-1)=pv1
      pv(nc,*)=pv(0,*)
      p=fltarr(nc+1,nr)
      p(0:nc-1,0:nr-1)=p1
      p(nc,*)=p(0,*)
      u=fltarr(nc+1,nr)
      u(0:nc-1,0:nr-1)=u1
      u(nc,*)=u(0,*)
      speed=fltarr(nc+1,nr)
      speed(0:nc-1,0:nr-1)=speed1
      speed(nc,*)=speed(0,*)
      temp=th(ilev)*((p/1000.)^(.286))
;
; read MLS data
;
      dum=findfile(dirm+'cat_mls_'+sver+'_'+sdate+'.sav')
      if dum(0) eq '' then goto,jump
      restore,dirm+'cat_mls_'+sver+'_'+sdate+'.sav'             ; altitude
      restore,dirm+'tpd_mls_'+sver+'_'+sdate+'.sav'             ; temperature, pressure
      restore,dirm+'co_mls_'+sver+'_'+sdate+'.sav'              ; mix
      nz=n_elements(altitude)
      nthlev=n_elements(thlev)
      mprof=n_elements(longitude)
      mlev=n_elements(altitude)
      muttime=time
      mlat=latitude
      mlon=longitude
      bad=where(mask eq -99.)
      if bad(0) ne -1L then mix(bad)=-99.
      good=where(mix ne -99.)
      if good(0) eq -1L then goto,jump
      mco=mix
      mtemp=temperature
      mpress=pressure
;
; eliminate bad uttimes and SH
;
      index=where(muttime gt 0. and mlat gt 0.)
      if index(0) eq -1L then goto,jump
      muttime=reform(muttime(index))
      mlat=reform(mlat(index))
      mlon=reform(mlon(index))
      mtemp=reform(mtemp(index,*))
      mpress=reform(mpress(index,*))
      mco=reform(mco(index,*))
      mtheta=mtemp*(1000./mpress)^0.286
      index=where(mtemp lt 0.)
      if index(0) ne -1L then mtheta(index)=-99.
;
; construct 2d MLS arrays to match CO
;
      mpress2=mpress
      mtime2=0.*mco
      mlat2=0.*mco
      mlon2=0.*mco
      for i=0L,mlev-1L do begin
          mtime2(*,i)=muttime
          mlat2(*,i)=mlat
          mlon2(*,i)=mlon
      endfor
;
; extract MLS CO near rlev
;
      kindex=where(abs(mtheta-rlev) le 50. and mco ne -99.,mprof)
      if kindex(0) eq -1L then goto,jump
      codata=mco(kindex)*1.e6
      xdata=mlon2(kindex)
      ydata=mlat2(kindex)
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
         device,/landscape,bits=8,filename='polar_mls_co+geos5_edge_nh_pv_'+sdate+'_'+slev+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.thick=2.0                   ;Plotted lines twice as thick
         !p.charsize=2.0
      endif
;
; polar plot
;
      erase
      !type=2^2+2^3
      xyouts,.1,.975,'MLS CO + GEOS-5 Arctic Vortex '+sdate+' '+slev,/normal,color=0,charsize=2,charthick=2
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='MLS Carbon Monoxide'
      omin=-0.5 & omax=2.	; 2000 K
      omin=-0.5 & omax=4.	; 2600 K
      omin=-0.5 & omax=5.	; 2800 K
      omin=-0.5 & omax=6.	; 3600 K
;omin=min(codata) & omax=max(codata)
;print,omin,omax
      for i=0L,mprof-1L do begin
          if codata(i) ge omin and codata(i) le omax then $
          oplot,[xdata(i),xdata(i)],[ydata(i),ydata(i)],psym=8,$
                 color=((codata(i)-omin)/(omax-omin))*mcolor
          if codata(i) gt omax then $
          oplot,[xdata(i),xdata(i)],[ydata(i),ydata(i)],psym=8,$
                 color=.95*mcolor
      endfor
loadct,0
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=10,/noeras,/follow
      contour,marknew,x,alat,/overplot,levels=[0.1],color=150,thick=8,/noeras,/follow
loadct,38
      contour,mark,x,alat,/overplot,levels=[-0.1],color=.5*mcolor,thick=10,/noeras,/follow
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras
;     contour,sf,x,alat,/overplot,nlevels=20,color=0,thick=3,/noeras,/follow,c_labels=0
;     contour,speed,x,alat,/overplot,levels=50.+10.*findgen(10),color=0,thick=3,/noeras,/follow,c_labels=0
;     level=[-150.,-125.,-100.,-75.,-50.,50.,75.,100.,125.,150.]
;     contour,u,x,alat,/overplot,levels=level,c_linestyle=level lt 0.,color=0,thick=3,/noeras,/follow,c_labels=0
      oplot,findgen(361),0.2+0.*findgen(361),psym=0,color=0
      nlvls=11
      level=omin+((omax-omin)/float(nlvls))*findgen(nlvls+1)
      nlvls=n_elements(level)
      col1=1+indgen(nlvls)*mcolor/nlvls
      set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
      !type=2^2+2^3+2^6
      plot,[omin,omax],[0,0],yrange=[0,10],$
            xrange=[omin,omax],xtitle='(ppmv)',/noeras,xstyle=1,color=0
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
      endfor
;
; Isotachs
;
      !type=2^2+2^3
      xmn=xorig(1)
      xmx=xorig(1)+xlen
      ymn=yorig(1)
      ymx=yorig(1)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='Wind Speed'
      slevel=10.*findgen(20)
      slevel=7.5*findgen(20)	; 2800 K
      nlvls=n_elements(slevel)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,speed,x,alat,/overplot,levels=slevel,c_color=col1,/fill,/noeras
      contour,speed,x,alat,/overplot,levels=slevel,color=0,/noeras,/follow,c_labels=0
loadct,0
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=10,/noeras,/follow
      contour,marknew,x,alat,/overplot,levels=[0.1],color=150,thick=8,/noeras,/follow
loadct,38
      contour,mark,x,alat,/overplot,levels=[-0.1],color=0.5*mcolor,thick=10,/noeras,/follow
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      oplot,findgen(361),0.2+0.*findgen(361),psym=0,color=0
      set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
      !type=2^2+2^3+2^6
      omin=min(slevel)
      omax=max(slevel)
      plot,[omin,omax],[0,0],yrange=[0,10],$
            xrange=[omin,omax],xtitle='(m/s)',/noeras,xstyle=1,color=0
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
      endfor
;
; Temperature
;
      !type=2^2+2^3
      xmn=xorig(2)
      xmx=xorig(2)+xlen
      ymn=yorig(2)
      ymx=yorig(2)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras,charsize=1.5,title='Temperature'
;     nlvls=20
;     col1=1+indgen(nlvls)*mcolor/nlvls
      slevel=0.4+0.025*findgen(20)	; 2000 K
      slevel=0.2+0.025*findgen(20)	; 2200
      slevel=220.+2.5*findgen(20)
      slevel=200.+5.*findgen(20)	; 3400 K
      nlvls=n_elements(slevel)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,temp,x,alat,/overplot,levels=slevel,c_color=col1,/fill,/noeras
      contour,temp,x,alat,/overplot,levels=slevel,color=0,/noeras,/follow,c_labels=0
loadct,0
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=10,/noeras,/follow
      contour,marknew,x,alat,/overplot,levels=[0.1],color=150,thick=8,/noeras,/follow
loadct,38
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      contour,mark,x,alat,/overplot,levels=[-0.1],color=.5*mcolor,thick=10,/noeras,/follow
      oplot,findgen(361),0.2+0.*findgen(361),psym=0,color=0
      set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
      !type=2^2+2^3+2^6
      omin=min(slevel)
      omax=max(slevel)
      plot,[omin,omax],[0,0],yrange=[0,10],$
            xrange=[omin,omax],xtitle='(K)',/noeras,xstyle=1,color=0
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
      endfor
;
; PV
;
      !type=2^2+2^3
      xmn=xorig(3)
      xmx=xorig(3)+xlen
      ymn=yorig(3)
      ymx=yorig(3)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='PV'
      slevel=3000.*findgen(20)	; 2000
      slevel=5000.*findgen(20)	; 2400
      slevel=7500.*findgen(20)	; 2600
      slevel=10000.*findgen(20)	; 2800
      slevel=12500.*findgen(20)	; 3000
      slevel=15000.*findgen(20)	; 3200
      slevel=17500.*findgen(20)	; 3400
      slevel=20000.*findgen(20)	; 3800
      slevel=25000.*findgen(20)	; 4000
      nlvls=n_elements(slevel)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,pv,x,alat,/overplot,levels=slevel,c_color=col1,/fill,/noeras
      contour,pv,x,alat,/overplot,levels=slevel,color=0,/noeras,/follow,c_labels=0
loadct,0
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=10,/noeras,/follow
      contour,marknew,x,alat,/overplot,levels=[0.1],color=150,thick=8,/noeras,/follow
loadct,38
      contour,mark,x,alat,/overplot,levels=[-0.1],color=.5*mcolor,thick=10,/noeras,/follow
      map_set,90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      oplot,findgen(361),0.2+0.*findgen(361),psym=0,color=0
      set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
      !type=2^2+2^3+2^6
      omin=min(slevel)
      omax=max(slevel)
      plot,[omin,omax],[0,0],yrange=[0,10],$
            xrange=[omin,omax],xtitle='(PVU)',/noeras,xstyle=1,color=0
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
         spawn,'convert -trim polar_mls_co+geos5_edge_nh_pv_'+sdate+'_'+slev+'.ps -rotate -90 '+$
               'polar_mls_co+geos5_edge_nh_pv_'+sdate+'_'+slev+'.jpg'
      endif
      icount=icount+1L
goto,jump
end
