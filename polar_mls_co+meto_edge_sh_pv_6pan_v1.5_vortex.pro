;
; plot different symbols for points in the vortex
; enter altitude and plot MLS CO and MetO Arctic vortex
; plot PV and isotachs.  4 panel
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc3

sver='v1.52'

loadct,38
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[0.15,0.55,0.15,0.55,0.15,0.55]+0.025
yorig=[.7,.7,.4,.4,.1,.1]-0.03
xlen=0.25
ylen=0.25
cbaryoff=0.04
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
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
ntimes=n_elements(stimes)
!noeras=1
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
lstmn=8L & lstdy=10L & lstyr=2004L
ledmn=3L & leddy=13L & ledyr=2008L
lstday=0L & ledday=0L
;
; get date range
;
print, ' '
print, '      MetO Version '
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
      uyr=string(FORMAT='(i2.2)',iyr-2000L)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
      ifile=mon(imn-1)+sdy+'_'+uyr
;
; read MLS data
;
      dum=findfile(dirm+'cat_mls_'+sver+'_'+sdate+'.sav')
      if dum(0) eq '' then goto,jump
      restore,dirm+'cat_mls_'+sver+'_'+sdate+'.sav'             ; altitude
      restore,dirm+'tpd_mls_'+sver+'_'+sdate+'.sav'             ; temperature, pressure
      restore,dirm+'mark_mls_'+sver+'.meto.'+sdate+'.sav'      ; marker field
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
      restore,dirm+'h2o_mls_'+sver+'_'+sdate+'.sav'              ; water vapor mix
      bad=where(mask eq -99.)
      if bad(0) ne -1L then mix(bad)=-99.
      good=where(mix ne -99.)
      if good(0) eq -1L then goto,jump
      mh2o=mix
      mtemp=temperature
      mpress=pressure
;
; eliminate bad uttimes and SH
;
      index=where(muttime gt 0. and mlat lt -20.)
      if index(0) eq -1L then goto,jump
      muttime=reform(muttime(index))
      mlat=reform(mlat(index))
      mlon=reform(mlon(index))
      mtemp=reform(mtemp(index,*))
      mpress=reform(mpress(index,*))
      mmark=reform(mark_prof(index,*))
      mco=reform(mco(index,*))
      mh2o=reform(mh2o(index,*))
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
      rlev=1800.
      kindex=where(abs(mtheta-rlev) le 50. and mco ne -99. and mh2o ne -99.,mprof)
      if kindex(0) eq -1L then goto,jump
      codata=mco(kindex)*1.e6
      h2odata=mh2o(kindex)*1.e6
      markdata=mmark(kindex)
      xdata=mlon2(kindex)
      ydata=mlat2(kindex)
;
; read MetO data
;
      rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
      if iflag eq 1 then goto,jump
print,sdate
;
; read new vortex
;
;     ncid=ncdf_open(dir+sdate+stimes(itime)+'nc5')
;     marknew2=fltarr(nr,nc,nth)
;     ncdf_varget,ncid,3,marknew2
;     ncdf_close,ncid

      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.
;
; select theta level to plot
;
      if icount eq 0 then begin
         print,th
;        read,' Enter desired theta surface ',rlev
         zindex=where(th eq rlev)
         ilev=zindex(0)
         slev=strcompress(long(th(ilev)),/remove_all)+'K'
      endif
      speed2=sqrt(u2^2.+v2^2.)
      mark1=transpose(mark2(*,*,ilev))
      msf1=transpose(msf2(*,*,ilev))
;     marknew1=transpose(marknew2(*,*,ilev))
      sf1=transpose(sf2(*,*,ilev))
      pv1=transpose(pv2(*,*,ilev))
      p1=transpose(p2(*,*,ilev))
      q1=transpose(q2(*,*,ilev))
      u1=transpose(u2(*,*,ilev))
      speed1=transpose(speed2(*,*,ilev))
      mark=fltarr(nc+1,nr)
      mark(0:nc-1,0:nr-1)=mark1
      mark(nc,*)=mark(0,*)
      msf=fltarr(nc+1,nr)
      msf(0:nc-1,0:nr-1)=msf1
      msf(nc,*)=msf(0,*)
;     marknew=fltarr(nc+1,nr)
;     marknew(0:nc-1,0:nr-1)=marknew1
;     marknew(nc,*)=marknew(0,*)
      sf=fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1
      sf(nc,*)=sf(0,*)
      pv=fltarr(nc+1,nr)
      pv(0:nc-1,0:nr-1)=pv1
      pv(nc,*)=pv(0,*)
      p=fltarr(nc+1,nr)
      p(0:nc-1,0:nr-1)=p1
      p(nc,*)=p(0,*)
      q=fltarr(nc+1,nr)
      q(0:nc-1,0:nr-1)=q1
      q(nc,*)=q(0,*)
      u=fltarr(nc+1,nr)
      u(0:nc-1,0:nr-1)=u1
      u(nc,*)=u(0,*)
      speed=fltarr(nc+1,nr)
      speed(0:nc-1,0:nr-1)=speed1
      speed(nc,*)=speed(0,*)
      temp=th(ilev)*((p/1000.)^(.286))
      height=(msf - 1004.*temp)/(9.86*1000.)
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
         device,/landscape,bits=8,filename='polar_mls_co+meto_edge_sh_pv_'+sdate+'_'+slev+'_v1.5_vortex.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.thick=2
      endif
;
; Isotachs + vortex edge
;
      erase
      !type=2^2+2^3
      xyouts,.35,.95,sdate+' '+slev,/normal,color=0,charsize=2,charthick=2
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,-90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='MetO Wind Speed'
      slevel=10.*findgen(20)
      slevel=7.5*findgen(20)    ; 2800 K
      nlvls=n_elements(slevel)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,speed,x,alat,/overplot,levels=slevel,c_color=col1,/fill,/noeras
;     contour,speed,x,alat,/overplot,levels=slevel,color=0,/noeras,/follow,c_labels=0
      loadct,0
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=5,/noeras,/follow
;     contour,marknew,x,alat,/overplot,levels=[0.1],color=100,thick=4,/noeras,/follow
      loadct,38
;     contour,mark,x,alat,/overplot,levels=[-0.1],color=0.5*mcolor,thick=3,/noeras,/follow
      map_set,-90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      oplot,findgen(361),0.2+0.*findgen(361),psym=0,color=0
      set_viewport,xmx+cbaryoff,xmx+cbaryoff+cbarydel,ymn,ymx
      !type=2^2+2^3+2^5
      omin=min(slevel)
      omax=max(slevel)
      plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],title='(m/s)',color=0
      xbox=[0,10,10,0,0]
      y1=omin
      dy=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor
;
; PV + vortex edge
;
      !type=2^2+2^3
      xmn=xorig(1)
      xmx=xorig(1)+xlen
      ymn=yorig(1)
      ymx=yorig(1)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,-90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='MetO PV'
      slevel=reverse(-1*1000.*findgen(20))/1.e6
;     slevel=reverse(-1*5000.*findgen(20))/1.e6
;     slevel=reverse(-1*6000.*findgen(20))/1.e6
;     slevel=reverse(-1*7500.*findgen(20))/1.e6
;     slevel=reverse(-1*10000.*findgen(20))/1.e6
;     slevel=reverse(-1*12500.*findgen(20))/1.e6
;     slevel=reverse(-1*15000.*findgen(20))/1.e6
;     slevel=reverse(-1*17500.*findgen(20))/1.e6
;     slevel=reverse(-1*20000.*findgen(20))/1.e6
;     slevel=reverse(-1*25000.*findgen(20))/1.e6
;     slevel=reverse(-1*60000.*findgen(20))/1.e6
      nlvls=n_elements(slevel)
      col1=reverse(1+indgen(nlvls)*mcolor/nlvls)
      contour,pv,x,alat,/overplot,levels=slevel,c_color=col1,/fill,/noeras
      contour,pv,x,alat,/overplot,levels=slevel,color=0,/noeras,/follow,c_labels=0
      loadct,0
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=5,/noeras,/follow
;     contour,marknew,x,alat,/overplot,levels=[0.1],color=100,thick=4,/noeras,/follow
      loadct,38
;     contour,mark,x,alat,/overplot,levels=[-0.1],color=0.5*mcolor,thick=3,/noeras,/follow
      map_set,-90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      oplot,findgen(361),0.2+0.*findgen(361),psym=8,color=0,symsize=0.1
      set_viewport,xmx+cbaryoff,xmx+cbaryoff+cbarydel,ymn,ymx
      !type=2^2+2^3+2^5
      omin=min(slevel)
      omax=max(slevel)
      plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],title='(PVU)',color=0
      xbox=[0,10,10,0,0]
      y1=omin
      dy=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor
;
; MLS CO
;
      xmn=xorig(2)
      xmx=xorig(2)+xlen
      ymn=yorig(2)
      ymx=yorig(2)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,-90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='MLS Carbon Monoxide'
      omin=-0.5 & omax=3.	; 2000 K
;     omin=-0.5 & omax=4.	; 2600 K
;     omin=-0.5 & omax=5.	; 2800 K
;     omin=-0.5 & omax=6.	; 3600 K
      for i=0L,mprof-1L do begin
          if codata(i) ge omin and codata(i) le omax then $
          oplot,[xdata(i),xdata(i)],[ydata(i),ydata(i)],psym=8,$
                 color=((codata(i)-omin)/(omax-omin))*mcolor
          if codata(i) gt omax then $
          oplot,[xdata(i),xdata(i)],[ydata(i),ydata(i)],psym=8,$
                 color=.95*mcolor
      endfor
      loadct,0
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=5,/noeras,/follow
;     index=where(abs(markdata) lt 1 and markdata gt 0.)
;     if index(0) ne -1L then oplot,xdata(index),ydata(index),psym=8,color=150
;     contour,marknew,x,alat,/overplot,levels=[0.1],color=100,thick=4,/noeras,/follow
      loadct,38
;     contour,mark,x,alat,/overplot,levels=[-0.1],color=0.5*mcolor,thick=3,/noeras,/follow
      map_set,-90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      contour,sf,x,alat,/overplot,nlevels=20,color=0,thick=1,/noeras,/follow,c_labels=0
      oplot,findgen(361),0.2+0.*findgen(361),psym=0,color=0
      set_viewport,xmx+cbaryoff,xmx+cbaryoff+cbarydel,ymn,ymx
      !type=2^2+2^3+2^5
      nlvls=11
      level=omin+((omax-omin)/float(nlvls))*findgen(nlvls+1)
      nlvls=n_elements(level)
      col1=1+indgen(nlvls)*mcolor/nlvls
      plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],title='(ppmv)',color=0
      xbox=[0,10,10,0,0]
      y1=omin
      dy=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor
;
; MLS water vapor
;
      !type=2^2+2^3
      xmn=xorig(3)
      xmx=xorig(3)+xlen
      ymn=yorig(3)
      ymx=yorig(3)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,-90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='MLS Water Vapor'
      omin=4. & omax=8.       ; 2000 K
      for i=0L,mprof-1L do begin
          if h2odata(i) ge omin and h2odata(i) le omax then $
          oplot,[xdata(i),xdata(i)],[ydata(i),ydata(i)],psym=8,$
                 color=((h2odata(i)-omin)/(omax-omin))*mcolor
          if h2odata(i) gt omax then $
          oplot,[xdata(i),xdata(i)],[ydata(i),ydata(i)],psym=8,$
                 color=.95*mcolor
      endfor
loadct,0
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=5,/noeras,/follow
;     index=where(abs(markdata) lt 1 and markdata gt 0.)
;     if index(0) ne -1L then oplot,xdata(index),ydata(index),psym=8,color=150
;     contour,marknew,x,alat,/overplot,levels=[0.1],color=100,thick=4,/noeras,/follow
      loadct,38
;     contour,mark,x,alat,/overplot,levels=[-0.1],color=0.5*mcolor,thick=3,/noeras,/follow
      contour,sf,x,alat,/overplot,nlevels=20,color=0,thick=1,/noeras,/follow,c_labels=0
      map_set,-90,0,-90,/ortho,/contin,/grid,color=0,/noeras
      oplot,findgen(361),0.2+0.*findgen(361),psym=0,color=0
      set_viewport,xmx+cbaryoff,xmx+cbaryoff+cbarydel,ymn,ymx
      !type=2^2+2^3+2^5
      nlvls=11
      level=omin+((omax-omin)/float(nlvls))*findgen(nlvls+1)
      nlvls=n_elements(level)
      col1=1+indgen(nlvls)*mcolor/nlvls
      plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],title='(ppmv)',color=0
      xbox=[0,10,10,0,0]
      y1=omin
      dy=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor
;
; CO vs H2O scatter plot
;
      !type=2^2+2^3
      xmn=xorig(4)
      xmx=xorig(4)+xlen
      ymn=yorig(4)
      ymx=yorig(4)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      plot,codata,h2odata,psym=8,color=0,xrange=[-1,3],yrange=[4,8],symsize=0.25,$
           xtitle='CO',ytitle='H!l2!nO',/nodata,title='Scatter Plot'
      nbins=37
      ybins=-1.+.25*findgen(nbins)
      xbins=-1.+.25*findgen(nbins)
      dbin=xbins(1)-xbins(0)
      nfreq=fltarr(nbins,nbins)

      for ii=0L,n_elements(codata)-1 do begin
          for i=0L,nbins-1 do begin
          for j=0L,nbins-1 do begin
              if codata(ii) ge xbins(i)-dbin/2. and codata(ii) lt xbins(i)+dbin/2. and $
                 h2odata(ii) ge ybins(j)-dbin/2. and h2odata(ii) lt ybins(j)+dbin/2. then $
                 nfreq(i,j)=nfreq(i,j)+1.
          endfor
          endfor
      endfor
      index=where(markdata gt 0.)
      vavg_co=-99.
      vavg_h2o=-99.
loadct,0
      if index(0) ne -1L then begin
         oplot,codata(index),h2odata(index),psym=8,symsize=0.5,color=mcolor*.6
         result=moment(codata(index))
         vavg_co=result(0)
         vsig_co=sqrt(result(1))
         result=moment(h2odata(index))
         vavg_h2o=result(0)
         vsig_h2o=sqrt(result(1))
      endif
loadct,38
      aavg_co=-99.
      aavg_h2o=-99.
      index=where(markdata eq 0.)
      if index(0) ne -1L then begin
         oplot,codata(index),h2odata(index),psym=8,symsize=0.5,color=0
         result=moment(codata(index))
         aavg_co=result(0)
         asig_co=sqrt(result(1))
         result=moment(h2odata(index))
         aavg_h2o=result(0)
         asig_h2o=sqrt(result(1))
      endif
;     index=where(abs(markdata) lt 1 and markdata gt 0.)
;     if index(0) ne -1L then oplot,codata(index),h2odata(index),psym=8,symsize=0.5,color=mcolor*.9

      contour,nfreq,xbins,ybins,levels=[5.],color=0.1*mcolor,/follow,/overplot,thick=2
      contour,nfreq,xbins,ybins,levels=[10.],color=0.2*mcolor,/follow,/overplot,thick=2
      contour,nfreq,xbins,ybins,levels=[20.],color=0.3*mcolor,/follow,/overplot,thick=2
      contour,nfreq,xbins,ybins,levels=[30.],color=0.4*mcolor,/follow,/overplot,thick=2
      contour,nfreq,xbins,ybins,levels=[40.],color=0.5*mcolor,/follow,/overplot,thick=1
      contour,nfreq,xbins,ybins,levels=[50.],color=0.6*mcolor,/follow,/overplot,thick=1
      contour,nfreq,xbins,ybins,levels=[75.],color=0.7*mcolor,/follow,/overplot,thick=1
      contour,nfreq,xbins,ybins,levels=[100.],color=0.8*mcolor,/follow,/overplot,thick=1
      contour,nfreq,xbins,ybins,levels=[200.],color=0.9*mcolor,/follow,/overplot,thick=1
      contour,nfreq,xbins,ybins,levels=[300.],color=0.95*mcolor,/follow,/overplot,thick=1
print,max(nfreq)
;
; CO and H2O PDFs
;
      !type=2^2+2^3
      xmn=xorig(5)
      xmx=xorig(5)+xlen
      ymn=yorig(5)
      ymx=yorig(5)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      y1=histogram(h2odata,min=-1,max=8.,binsize=.25)/float(n_elements(h2odata))
      y2=histogram(codata,min=-1,max=8.,binsize=.25)/float(n_elements(codata))
      ymax=max(y1,y2)+0.2*max(y1,y2)
      !linetype=0
      x=-1.+.25*findgen(37)
      plot,x,y1,xtitle='(ppmv)',ytitle='Frequency',charsize=1.2,$
           title='PDFs',xrange=[-1.,8.],yrange=[0.,ymax],color=0
      oplot,x,y1,color=.3*mcolor,thick=3
      y2=histogram(codata,min=-1,max=8.,binsize=.25)/float(n_elements(codata))
      oplot,x,y2,color=.9*mcolor,thick=3

      if aavg_co ne -99. then begin
         plots,aavg_co,0.
         plots,aavg_co,ymax,color=0,/continue,thick=3
         plots,aavg_h2o,0.
         plots,aavg_h2o,ymax,color=0,/continue,thick=3
;        plots,aavg_co-asig_co,0.
;        plots,aavg_co-asig_co,ymax,color=0,/continue,linestyle=5
;        plots,aavg_co+asig_co,0.
;        plots,aavg_co+asig_co,ymax,color=0,/continue,linestyle=5
      endif
      if vavg_co ne -99. then begin
         plots,vavg_co,0.
         plots,vavg_co,ymax,color=mcolor*.9,/continue,thick=3
         plots,vavg_h2o,0.
         plots,vavg_h2o,ymax,color=mcolor*.3,/continue,thick=3
;        plots,vavg_co-vsig_co,0.
;        plots,vavg_co-vsig_co,ymax,color=mcolor*.9,/continue,linestyle=5,thick=2
;        plots,vavg_co+vsig_co,0.
;        plots,vavg_co+vsig_co,ymax,color=mcolor*.9,/continue,linestyle=5,thick=2
      endif
      xyouts,3,.9*ymax,'CO',/data,charsize=1.2,color=.9*mcolor,charthick=2
      xyouts,3,.8*ymax,'H!l2!nO',/data,charsize=1.2,color=.3*mcolor,charthick=2

      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device,/close
         spawn,'convert -trim polar_mls_co+meto_edge_sh_pv_'+sdate+'_'+slev+'_v1.5_vortex.ps -rotate -90 '+$
               'polar_mls_co+meto_edge_sh_pv_'+sdate+'_'+slev+'_v1.5_vortex.jpg'
         spawn,'/usr/bin/rm polar_mls_co+meto_edge_sh_pv_'+sdate+'_'+slev+'_v1.5_vortex.ps'
      endif
      icount=icount+1L
goto,jump
end
