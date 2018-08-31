;
; contour zonal mean latitude as a function of equivalent latitude and time
; Equivalent latitude is computed from PV and CO, 2 panel.
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
nxdim=1000
nydim=700
xorig=[.1,0.1,0.55,0.55]
yorig=[.55,.1,.55,.1]
xlen=0.35
ylen=0.3
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
mon=['jan','feb','mar','apr','may','jun',$
     'jul','aug','sep','oct','nov','dec']
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
nlat=35L
elatbin=-85+5.*findgen(nlat)
delat=(elatbin(1)-elatbin(0))/2.
stimes=[$
'_0000.V01.',$
'_0600.V01.',$
'_1200.V01.',$
'_1800.V01.']
slabs=['00Z','06Z','12Z','18Z']
ntimes=n_elements(stimes)
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
kday=(ledday-lstday+1L)*4L
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
      if ndays gt ledday then goto,plotit
;
; construct date string
;
      syr=strcompress(iyr,/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
print,sdate
;
; read MLS data
;
      dum=findfile(dirm+'cat_mls_'+sver+'_'+sdate+'.sav')
      if dum(0) eq '' then goto,skipit
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
      if good(0) eq -1L then goto,skipit
      mco=mix
      restore,dirm+'h2o_mls_'+sver+'_'+sdate+'.sav'              ; water vapor mix
      bad=where(mask eq -99.)
      if bad(0) ne -1L then mix(bad)=-99.
      good=where(mix ne -99.)
      if good(0) eq -1L then goto,skipit
      mh2o=mix
      mtemp=temperature
      mpress=pressure
;
; eliminate bad uttimes and SH
;
      index=where(muttime gt 0.)
      if index(0) eq -1L then goto,skipit
      muttime=reform(muttime(index))
      mlat=reform(mlat(index))
      mlon=reform(mlon(index))
      mtemp=reform(mtemp(index,*))
      mpress=reform(mpress(index,*))
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
; loop over daily output times
;
      for itime=0L,ntimes-1L do begin
;
; read GEOS-5 data
;
      rd_geos5_nc3_meto,dir+sdate+stimes(itime)+'nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,sf2,vp2,iflag
      if iflag eq 1 then goto,skipit
;
; read new vortex
;
      ncid=ncdf_open(dir+sdate+stimes(itime)+'nc5')
      marknew2=fltarr(nr,nc,nth)
      ncdf_varget,ncid,3,marknew2
      ncdf_close,ncid
      if icount eq 0 then begin
         x2d=fltarr(nc,nr)
         y2d=fltarr(nc,nr)
         for i=0L,nc-1L do y2d(i,*)=alat
         for j=0L,nr-1L do x2d(*,j)=alon
         ytlatpv=-9999.+fltarr(kday,nlat)
         ytlatpvsig=-9999.+fltarr(kday,nlat)
         ytmarkpv=-9999.+fltarr(kday,nlat)
         ytlatco=-9999.+fltarr(kday,nlat)
         ytlatcosig=-9999.+fltarr(kday,nlat)
         ytmarkco=-9999.+fltarr(kday,nlat)
      endif
;
; loop over theta
;
index=where(th eq 3600.)
ilev=index(0)
      yzlatpv=fltarr(nlat,nth)
      yzlatco=fltarr(nlat,nth)
      yzlatpvsig=fltarr(nlat,nth)
      yzlatcosig=fltarr(nlat,nth)
      yzmarkpv=fltarr(nlat,nth)
      yzmarkco=fltarr(nlat,nth)
      for kk=ilev,ilev do begin
          rlev=th(kk)
          slev=strcompress(long(rlev),/remove_all)+'K'
          kindex=where(abs(mtheta-rlev) le 50. and mco ne -99. and mh2o ne -99.,mprof)
          if kindex(0) eq -1L then goto,skipit
          codata=mco(kindex)*1.e6
          h2odata=mh2o(kindex)*1.e6
          xdata=mlon2(kindex)
          ydata=mlat2(kindex)
          cogrid=griddata(xdata,ydata,codata,/degrees)
          for l=0L,4 do cogrid=smooth(cogrid,3)
dims=size(cogrid)
ncc=dims(1)
nrr=dims(2)
alongrid=(360./(float(ncc)-1.))*findgen(ncc)
alatgrid=-90.+(180./(float(nrr)-1.))*findgen(nrr)
index=where(alatgrid lt 0.)
if index(0) ne -1L then cogrid(index)=-1.*cogrid(index)
      if icount eq 0 then begin
         x2dgrid=fltarr(ncc,nrr)
         y2dgrid=fltarr(ncc,nrr)
         for i=0L,ncc-1L do y2dgrid(i,*)=alatgrid
         for j=0L,nrr-1L do x2dgrid(*,j)=alongrid
      endif

          pv1=transpose(pv2(*,*,kk))
          mark1=transpose(mark2(*,*,kk))
          elatpv1=calcelat2d(pv1,alon,alat)
          elatco1=calcelat2d(cogrid,alongrid,alatgrid)
;
; interpolate GEOS-5 marker to co grid
;
    markgrid=0.*cogrid
    for ii=0L,ncc-1L do begin
        slon=alongrid(ii)
        if slon lt alon(0) then slon=slon+360.
        for jj=0L,nrr-1L do begin
            slat=alatgrid(jj)
            for i=0L,nc-1L do begin
                ip1=i+1
                if i eq nc-1L then ip1=0L
                xlon=alon(i)
                xlonp1=alon(ip1)
                if i eq nc-1L then xlonp1=360.+alon(ip1)
                if slon ge xlon and slon le xlonp1 then begin
                   xscale=(slon-xlon)/(xlonp1-xlon)
                   goto,jumpx
                endif
            endfor
jumpx:
            for j=0L,nr-2L do begin
                jp1=j+1
                xlat=alat(j)
                xlatp1=alat(jp1)
                if slat ge xlat and slat le xlatp1 then begin
                    yscale=(slat-xlat)/(xlatp1-xlat)
                    goto,jumpy
                endif
            endfor
jumpy:
                   p1=mark1(i,j)
                   pp2=mark1(i,jp1)
                   p3=mark1(ip1,j)
                   p4=mark1(ip1,jp1)
                   if p1 eq 1. or pp2 eq 1. or p3 eq 1. or p4 eq 1. then $
                      markgrid(ii,jj)=1.0
                   if p1 lt 0. or pp2 lt 0. or p3 lt 0. or p4 lt 0. then $
                      markgrid(ii,jj)=min([p1,pp2,p3,p4])
jumpz1:
        endfor
    endfor

;erase
;xyouts,.45,.95,strcompress(th(kk)),/normal,color=0,charsize=1.5
;nlvls=nlat
;col1=1+indgen(nlvls)*mcolor/nlvls
;imin=min(pv1)
;imax=max(pv1)
;iint=(imax-imin)/nlvls
;level=imin+iint*findgen(nlvls)
;print,'PV ',level
;set_viewport,.1,.5,.6,.9
;contour,pv1,alon,alat,levels=level,c_color=col1,/fill,title='PV',xrange=[0.,360.],$
;        yrange=[-90.,90.],xtitle='Longitude',ytitle='Latitude',color=0
;contour,pv1,alon,alat,/overplot,levels=level,color=0,/follow
;contour,mark1,alon,alat,/overplot,levels=[0.1],color=mcolor,/follow,thick=5
;imin=min(cogrid)
;imax=max(cogrid)
;iint=(imax-imin)/nlvls
;level=imin+iint*findgen(nlvls)
;print,'SF ',level
;set_viewport,.5,.9,.6,.9
;contour,cogrid,alongrid,alatgrid,levels=level,c_color=col1,/fill,title='SF',xrange=[0.,360.],$
;        yrange=[-90.,90.],xtitle='Longitude',ytitle='Latitude',color=0
;contour,cogrid,alongrid,alatgrid,/overplot,levels=level,color=0,/follow
;contour,mark1,alon,alat,/overplot,levels=[0.1],color=mcolor,/follow,thick=5
;level=elatbin
;set_viewport,.1,.5,.2,.5
;contour,elatpv1,alon,alat,levels=level,c_color=col1,/fill,title='Elat PV',xrange=[0.,360.],$
;        yrange=[-90.,90.],xtitle='Longitude',ytitle='Latitude',color=0
;contour,elatpv1,alon,alat,/overplot,levels=level,color=0,/follow
;contour,mark1,alon,alat,/overplot,levels=[0.1],color=mcolor,/follow,thick=5
;set_viewport,.5,.9,.2,.5
;contour,elatco1,alongrid,alatgrid,levels=level,c_color=col1,/fill,title='Elat SF',xrange=[0.,360.],$
;        yrange=[-90.,90.],xtitle='Longitude',ytitle='Latitude',color=0
;contour,elatco1,alongrid,alatgrid,/overplot,levels=level,color=0,/follow
;contour,mark1,alon,alat,/overplot,levels=[0.1],color=mcolor,/follow,thick=5
;stop
;
; bin max marker and CO in elat
;
          for j=0L,nlat-1L do begin
              e0=elatbin(j)-delat & e1=elatbin(j)+delat
              index=where(elatpv1 ge e0 and elatpv1 lt e1)
              if n_elements(index) ge 2L then begin
                 result=moment(y2d(index))
                 yzlatpv(j,kk)=result(0)
                 yzlatpvsig(j,kk)=sqrt(result(1))
                 yzmarkpv(j,kk)=mean(mark1(index))
                 ytlatpv(icount,*)=yzlatpv(*,kk)
                 ytlatpvsig(icount,*)=yzlatpvsig(*,kk)
                 ytmarkpv(icount,*)=yzmarkpv(*,kk)
              endif
              index=where(elatco1 ge e0 and elatco1 lt e1)
              if n_elements(index) ge 2L then begin
                 result=moment(y2dgrid(index))
                 yzlatco(j,kk)=result(0)
                 yzlatcosig(j,kk)=sqrt(result(1))
                 yzmarkco(j,kk)=mean(markgrid(index))
                 ytlatco(icount,*)=yzlatco(*,kk)
                 ytlatcosig(icount,*)=yzlatcosig(*,kk)
                 ytmarkco(icount,*)=yzmarkco(*,kk)
              endif
          endfor
      endfor
;!type=2^2+2^3
;erase
;set_viewport,.1,.45,.55,.95
;level=elatbin
;nlvls=nlat
;col1=1+indgen(nlvls)*mcolor/nlvls
;
;contour,yzlatpv,elatbin,th,levels=level,c_color=col1,/fill,title='Mean Latitude',$
;        xtitle='PV based Equivalent Latitude',color=0
;contour,yzlatpv,elatbin,th,levels=level,color=0,/follow,/overplot
;contour,yzmarkpv,elatbin,th,levels=[0.1,0.5,0.9],color=0,thick=5,/follow,/overplot
;set_viewport,.55,.9,.55,.95
;contour,yzlatco,elatbin,th,levels=level,c_color=col1,/fill,title='Mean Latitude',$
;        xtitle='CO based Equivalent Latitude',color=0
;contour,yzlatco,elatbin,th,levels=level,color=0,/follow
;contour,yzmarkco,elatbin,th,levels=[0.1,0.5,0.9],color=0,thick=5,/follow,/overplot
;
;level=findgen(nlvls)
;set_viewport,.1,.45,.05,.45
;contour,yzlatpvsig,elatbin,th,levels=level,c_color=col1,/fill,title='Sigma Latitude',$
;        xtitle='PV based Equivalent Latitude',color=0
;contour,yzlatpvsig,elatbin,th,levels=level,color=0,/follow,/overplot
;contour,yzmarkpv,elatbin,th,levels=[0.1,0.5,0.9],color=0,thick=5,/follow,/overplot
;set_viewport,.55,.9,.05,.45
;contour,yzlatcosig,elatbin,th,levels=level,c_color=col1,/fill,title='Sigma Latitude',$
;        xtitle='CO based Equivalent Latitude',color=0
;contour,yzlatcosig,elatbin,th,levels=level,color=0,/follow
;contour,yzmarkco,elatbin,th,levels=[0.1,0.5,0.9],color=0,thick=5,/follow,/overplot
;stop
;
skipit:
            icount=icount+1L
      endfor    ; loop over 4 daily times

goto,jump
plotit:
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
         device,/landscape,bits=8,filename='elat_v_time_geos5_lat+mark_'+sdate+'_'+slev+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.thick=2.0                   ;Plotted lines twice as thick
         !p.charsize=2.0
      endif

erase
!type=2^2+2^3
xyouts,.45,.9,slev,/normal,color=0,charsize=2,charthick=2
;
; PV based Elat. contour mean lat and mark per elat bin
;
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=elatbin
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,ytlatpv,1.+findgen(kday),elatbin,levels=elatbin,color=0,c_color=col1,/noeras,$
        xrange=[1,kday],yrange=[-90,90],/fill,title='Mean Latitude',min_value=-9999.,yticks=6,$
        ytitle='PV based Elat'
contour,ytlatpv,1.+findgen(kday),elatbin,levels=elatbin,color=0,/noeras,/follow,/overplot,min_value=-9999.
contour,ytmarkpv,1.+findgen(kday),elatbin,/overplot,levels=[0.1,0.5,0.9],color=0,thick=8,/noeras,/follow,min_value=-9999.
;
; CO based Elat. contour mean lat and mark per elat bin
;
!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=elatbin
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
ytlatco=smooth(ytlatco,3)
ytmarkco=smooth(ytmarkco,3)
contour,ytlatco,1.+findgen(kday),elatbin,levels=elatbin,color=0,c_color=col1,/noeras,$
        xrange=[1,kday],yrange=[-90,90],/fill,title='Mean Latitude',min_value=-9999.,yticks=6,$
        ytitle='CO based Elat'
contour,ytlatco,1.+findgen(kday),elatbin,levels=elatbin,color=0,/noeras,/follow,/overplot,min_value=-9999.
contour,ytmarkco,1.+findgen(kday),elatbin,/overplot,levels=[0.1,0.5,0.9],color=0,thick=8,/noeras,/follow,min_value=-9999.
omin=min(level)
omax=max(level)
set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
!type=2^2+2^3+2^6
plot,[omin,omax],[0,0],yrange=[0,10],$
      xrange=[omin,omax],xtitle='Latitude',/noeras,xstyle=1,color=0
ybox=[0,10,10,0,0]
x1=omin
dx=(omax-omin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor
;
; plot sigmas
;
!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+xlen
ymn=yorig(2)
ymx=yorig(2)+ylen
set_viewport,xmn,xmx,ymn,ymx
level=findgen(nlvls)
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
contour,ytlatpvsig,1.+findgen(kday),elatbin,levels=level,color=0,c_color=col1,/noeras,$
        xrange=[1,kday],yrange=[-90,90],/fill,title='Sigma Latitude',min_value=-9999.,yticks=6,$
        ytitle='PV based Elat'
contour,ytlatpvsig,1.+findgen(kday),elatbin,levels=level,color=0,/noeras,/follow,/overplot,min_value=-9999.
contour,ytmarkpv,1.+findgen(kday),elatbin,/overplot,levels=[0.1,0.5,0.9],color=0,thick=8,/noeras,/follow,min_value=-9999.
;
; CO based Elat. contour sigma lat and mark per elat bin
;
!type=2^2+2^3
xmn=xorig(3)
xmx=xorig(3)+xlen
ymn=yorig(3)
ymx=yorig(3)+ylen
set_viewport,xmn,xmx,ymn,ymx
nlvls=n_elements(level)
col1=1+indgen(nlvls)*mcolor/nlvls
ytlatcosig=smooth(ytlatcosig,3)
contour,ytlatcosig,1.+findgen(kday),elatbin,levels=level,color=0,c_color=col1,/noeras,$
        xrange=[1,kday],yrange=[-90,90],/fill,title='Sigma Latitude',min_value=-9999.,yticks=6,$
        ytitle='CO based Elat'
contour,ytlatcosig,1.+findgen(kday),elatbin,levels=level,color=0,/noeras,/follow,/overplot,min_value=-9999.
contour,ytmarkco,1.+findgen(kday),elatbin,/overplot,levels=[0.1,0.5,0.9],color=0,thick=8,/noeras,/follow,min_value=-9999.
omin=min(level)
omax=max(level)
set_viewport,xmn,xmx,ymn-cbaryoff,ymn-cbaryoff+cbarydel
!type=2^2+2^3+2^6
plot,[omin,omax],[0,0],yrange=[0,10],$
      xrange=[omin,omax],xtitle='Latitude',/noeras,xstyle=1,color=0
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
         spawn,'convert -trim polar_mls_co+geos5_edge_nh_pv_'+sdate+'_'+slabs(itime)+'_'+slev+'.ps -rotate -90 '+$
               'polar_mls_co+geos5_edge_nh_pv_'+sdate+'_'+slabs(itime)+'_'+slev+'.jpg'
      endif
end
