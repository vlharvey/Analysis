;
; plot GEOS-5 SF vs PV
; superimpose all theta levels
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto

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
yorig=[.65,.65,.4,.4,.1,.1]
xlen=0.25
ylen=0.25
cbaryoff=0.06
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
stimes=[$
'_AVG.V01.']
slabs=['AVG']
ntimes=n_elements(stimes)
!noeras=1
dirm='/aura6/data/MLS_data/Datfiles_SOSST/'
dir='/aura7/harvey/GEOS5_data/Datfiles/DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'
lstmn=7L & lstdy=8L & lstyr=2006L
ledmn=7L & leddy=8L & ledyr=2006L
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
;
; read new vortex
;
      ncid=ncdf_open(dir+sdate+stimes(0)+'nc5')
      marknew2=fltarr(nr,nc,nth)
      ncdf_varget,ncid,3,marknew2
      ncdf_close,ncid

      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.
      y2d=fltarr(nc,nr)
      for i=0,nc-1 do y2d(i,*)=alat
      index=where(th eq 2200.)
      ilev=index(0)
      rlev=th(ilev)
      slev=strcompress(long(th(ilev)),/remove_all)+'K'
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
         device,/landscape,bits=8,filename='geos5_sh_sf_vs_pv_'+sdate+'_'+slabs(0)+'_alllev_'+slev+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.thick=2
      endif
;
; loop over theta surfaces
;
      speed2=sqrt(u2^2.+v2^2.)
      col2=reverse(1+indgen(nth-7)*mcolor/float(nth-7))
      mark1=transpose(mark2(*,*,ilev))
      msf1=transpose(msf2(*,*,ilev))
      marknew1=transpose(marknew2(*,*,ilev))
      sf1=transpose(sf2(*,*,ilev))
      pv1=-1.*transpose(pv2(*,*,ilev))
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
; Isotachs + vortex edge
;
      erase
      !type=2^2+2^3
      xyouts,.35,.95,sdate+' '+slabs(0)+' '+slev,/normal,color=0,charsize=2,charthick=2
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      map_set,-90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='GEOS-5 Wind Speed'
      slevel=5.*findgen(30)
      nlvls=n_elements(slevel)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,speed,x,alat,/overplot,levels=slevel,c_color=col1,/fill,/noeras
      contour,sf,x,alat,/overplot,nlevels=20,color=0,/noeras,/follow,c_labels=0
      loadct,0
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=5,/noeras,/follow
      contour,marknew,x,alat,/overplot,levels=[0.1],color=200,thick=4,/noeras,/follow
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
      map_set,-90,0,-90,/ortho,/contin,/grid,color=0,/noeras,title='GEOS-5 PV'
      omin=0.
      index=where(y2d lt 0.)
      omax=max(pv(index))
      slevel=omin+((omax-omin)/float(nlvls))*findgen(nlvls)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,pv,x,alat,/overplot,levels=slevel,c_color=col1,/fill,/noeras
;     contour,pv,x,alat,/overplot,levels=slevel,color=0,/noeras,/follow,c_labels=0
      loadct,0
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=5,/noeras,/follow
      contour,marknew,x,alat,/overplot,levels=[0.1],color=200,thick=4,/noeras,/follow
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
; individual SF vs PV points
;
      !type=2^2+2^3
      xmn=0.15
      xmx=xmn+0.3
      ymn=0.1
      ymx=ymn+0.5
      set_viewport,xmn,xmx,ymn,ymx
      sfmax=1.25e-5
      sfmin=-1.25e-5
      pvmin=1.e-4
      pvmax=3.
      plot,findgen(10),findgen(10),/nodata,xrange=[sfmin,sfmax],yrange=[pvmin,pvmax],$
           /ylog,color=0,xtitle='Streamfunction',ytitle='Potential Vorticity'
      index=where(y2d lt 0.)
      for ilev=0L,nth-8L do begin
          sf=transpose(sf2(*,*,ilev))
          pv=-1.*transpose(pv2(*,*,ilev))
          oplot,sf(index),pv(index),psym=8,color=col2(ilev),symsize=0.2
      endfor
;
; mean PV per SF bin
;
      !type=2^2+2^3
      xmn=0.55
      xmx=xmn+0.3
      ymn=0.1
      ymx=ymn+0.5
      set_viewport,xmn,xmx,ymn,ymx
      plot,findgen(10),findgen(10),/nodata,xrange=[sfmin,sfmax],yrange=[pvmin,pvmax],$
           /ylog,color=0,xtitle='Streamfunction'
      sfbins=sfmin+((sfmax-sfmin)/20.)*findgen(21)
      dsf=sfbins(1)-sfbins(0)
      for ilev=0L,nth-8L do begin
          sf=transpose(sf2(*,*,ilev))
          pv=-1.*transpose(pv2(*,*,ilev))
          mark=transpose(mark2(*,*,ilev))
          marknew=transpose(marknew2(*,*,ilev))
          meanpv=fltarr(n_elements(sfbins))
          sigmapv=fltarr(n_elements(sfbins))

          for ii=0L,n_elements(sfbins)-1L do begin
              index=where(y2d lt 0. and sf ge sfbins(ii)-dsf and sf lt sfbins(ii)+dsf)
              if n_elements(index) ge 2L then begin
              result=moment(pv(index))
              meanpv(ii)=result(0)
              sigmapv(ii)=sqrt(result(1))
;pvmin2=meanpv(ii)-sigmapv(ii)
;if pvmin2 lt pvmin then pvmin2=pvmin
;plots,sfbins(ii)+(0.05*float(ilev))*dsf,pvmin2
;plots,sfbins(ii)+(0.05*float(ilev))*dsf,meanpv(ii)+sigmapv(ii),color=col2(ilev),/continue
;print,sfbins(ii)+(0.05*float(ilev))*dsf,min(pv(index)),max(pv(index))
              endif
          endfor
          oplot,sfbins,meanpv,psym=0,thick=5,color=col2(ilev)
;
; superimpose SF at vortex edges and compute correlation coefficient for data
; inside the vortex (for each nc3 and nc5 definion)
;
      loadct,0
      smax1=-99. & smax2=-99.
      index=where(y2d lt 0. and mark gt 0.)
      if index(0) ne -1L then begin
         smax1=min(sf(index))
index=where(abs(sfbins-smax1) eq min(abs(sfbins-smax1)))
oplot,sfbins(index),meanpv(index),psym=8,color=0
;        result=correlate(sf(index),pv(index))
;        xyouts,xmx+0.02,ymx-0.02,'r='+string(format='(f5.2)',result),/normal,color=0,charsize=2
      endif
      index=where(y2d lt 0. and marknew gt 0.)
      if index(0) ne -1L then begin
         smax2=min(sf(index))
index=where(abs(sfbins-smax2) eq min(abs(sfbins-smax2)))
oplot,sfbins(index),meanpv(index),psym=8,color=200
;        result=correlate(sf(index),pv(index))
;        xyouts,xmx+0.02,ymx-0.05,'r='+string(format='(f5.2)',result),/normal,color=200,charsize=2
      endif
      loadct,38
;stop
      endfor

      set_viewport,xmx+cbaryoff,xmx+cbaryoff+cbarydel,ymn,ymx
      !type=2^2+2^3+2^5
      plot,[0,0],[min(th),max(th)],xrange=[0,10],yrange=[700.,max(th)],title='(K)',color=0,$
           yticks=nth-8,ytickv=th(0:nth-8),ytickname=string(format='(i4)',long(th(0:nth-9)))
      xbox=[0,10,10,0,0]
      y1=700.
      dy=(max(th)-y1)/float(nth-8)
      col2=reverse(col2)
      for j=0,nth-9 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col2(j)
          y1=y1+dy
      endfor
 
      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device,/close
         spawn,'convert -trim geos5_sh_sf_vs_pv_'+sdate+'_'+slabs(0)+'_alllev_'+slev+'.ps -rotate -90 '+$
               'geos5_sh_sf_vs_pv_'+sdate+'_'+slabs(0)+'_alllev_'+slev+'.jpg'
;        spawn,'/usr/bin/rm geos5_sh_sf_vs_pv_'+sdate+'_'+slabs(0)+'_alllev_'+slev+'.ps'
      endif

goto,jump
end
