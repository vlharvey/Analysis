;
; median
; plot GEOS-5 SF vs PV
; superimpose all theta levels
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_nc3_meto
@calcelat2d

loadct,39
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.01
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
lstmn=1L & lstdy=19L & lstyr=2007L
ledmn=1L & leddy=19L & ledyr=2007L
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
      x2d=fltarr(nc,nr)
      for i=0,nc-1 do y2d(i,*)=alat
      for i=0,nr-1 do x2d(*,i)=alon
;
; save postscript version
;
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !p.charthick=5
         !y.thick=2
         !x.thick=2
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
          /bold,/color,bits_per_pixel=8,/helvetica,filename='figure_4_'+sdate+'_new_median.ps'
      endif
;
; loop over theta surfaces
;
      zindex=where(th ge 500.,nth)
      th=th(zindex)
      speed2=sqrt(u2^2.+v2^2.)
      col2=reverse(1+indgen(nth)*mcolor/float(nth))
      pv2=reform(pv2(*,*,zindex))
      p2=reform(p2(*,*,zindex))
      msf2=reform(msf2(*,*,zindex))
      u2=reform(u2(*,*,zindex))
      v2=reform(v2(*,*,zindex))
      q2=reform(q2(*,*,zindex))
      qdf2=reform(qdf2(*,*,zindex))
      mark2=reform(mark2(*,*,zindex))
      marknew2=reform(marknew2(*,*,zindex))
      sf2=reform(sf2(*,*,zindex))
      vp2=reform(vp2(*,*,zindex))
thlev=3600.
thlev1=1000.
;      index=where(th eq thlev)
;      ilev=index(0)
;      rlev=th(ilev)
;      slev=strcompress(long(th(ilev)),/remove_all)+' K'
;      mark1=transpose(mark2(*,*,ilev))
;      msf1=transpose(msf2(*,*,ilev))
;      marknew1=transpose(marknew2(*,*,ilev))
;      sf1=transpose(sf2(*,*,ilev))
;      pv1=transpose(pv2(*,*,ilev))
;      elat1=calcelat2d(pv1,alon,alat)
;      p1=transpose(p2(*,*,ilev))
;      q1=transpose(q2(*,*,ilev))
;      u1=transpose(u2(*,*,ilev))
;      speed1=transpose(speed2(*,*,ilev))
;;
;; compute Nash vortex edge
;; integrate wind speed and PV in Elat bins
;;
;      nbins=37
;      dy=2.5
;      latmin=0.
;      latmax=90.
;      elatbin=latmin+dy*findgen(nbins)
;      speedbin=-999.+0.*fltarr(nbins)                               ; average windspeed per elat bin
;      pvbin=0.*elatbin
;      for n=0,nbins-2 do begin
;          t=where(pv1 lt 1000. and y2d ge latmin and elat1 ge elatbin(n) and elat1 lt elatbin(n+1),it)
;          if it gt 2 then begin
;             result=moment(pv1(t))
;             pvbin(n)=result(0)
;             if min(y2d(t))-latmin le dy then begin ; make sure bins are resolved (do not intersect latmin)
;                speedbin(n)=-999.
;                goto,jumpnhbin
;             endif
;             speedbin(n)=total(speed1(t))/float(it)
;          endif
;          jumpnhbin:
;      endfor                                                        ; loop over Elat bins
;      s=where(y2d ge latmin and elat1 ge elatbin(nbins-1),is)
;      if is gt 2 then begin
;         result=moment(pv1(s))
;         pvbin(n)=result(0)
;         if min(y2d(s))-latmin gt dy then speedbin(nbins-1)=total(speed1(s))/float(is)
;      endif
;;
;; compute PV gradient wrt Equivalent latitude
;;
;      dpvbin=0.*pvbin
;      for i=0,nbins-2L do dpvbin(i)=pvbin(i+1)-pvbin(i)
;      dpvbin(nbins-1)=pvbin(nbins-1)-pvbin(nbins-2)
;;
;; impose Nash filter poleward of 80deg (and add new one Equatorward of lat0)
;;
;      lat0=70.
;      index=where(elatbin ge lat0)                                  ; filter down poleward of 80deg
;      speedbin(index)=speedbin(index)*(90.-elatbin(index))/30.
;      dpvbin(index)=dpvbin(index)*(90.-elatbin(index))/30.
;      lat0=25.
;      if th(ilev) lt 600. then lat0=45.
;      index=where(elatbin le lat0)                                  ; filter down equatorward of lat0
;      speedbin(index)=speedbin(index)*(elatbin(index))/(2.*lat0)
;      dpvbin(index)=dpvbin(index)*(elatbin(index))/(2.*lat0)
;      dpvbin=dpvbin/max(dpvbin)       
;;
;; vortex edge is where dPV/dElat multiplied by the wind speed integrated in Elat bins is maximum
;; and integrated wind speed must be greater than 15.2 m/s
;;
;      prod=dpvbin*speedbin
;      index=where(prod eq max(prod))
;      if index(0) ne -1L then edgepv=pvbin(index)
;
;      mark=fltarr(nc+1,nr)
;      mark(0:nc-1,0:nr-1)=mark1
;      mark(nc,*)=mark(0,*)
;      msf=fltarr(nc+1,nr)
;      msf(0:nc-1,0:nr-1)=msf1
;      msf(nc,*)=msf(0,*)
;      marknew=fltarr(nc+1,nr)
;      marknew(0:nc-1,0:nr-1)=marknew1
;      marknew(nc,*)=marknew(0,*)
;      sf=fltarr(nc+1,nr)
;      sf(0:nc-1,0:nr-1)=sf1
;      sf(nc,*)=sf(0,*)
;      pv=fltarr(nc+1,nr)
;      pv(0:nc-1,0:nr-1)=pv1
;      pv(nc,*)=pv(0,*)
;      p=fltarr(nc+1,nr)
;      p(0:nc-1,0:nr-1)=p1
;      p(nc,*)=p(0,*)
;      u=fltarr(nc+1,nr)
;      u(0:nc-1,0:nr-1)=u1
;      u(nc,*)=u(0,*)
;      speed=fltarr(nc+1,nr)
;      speed(0:nc-1,0:nr-1)=speed1
;      speed(nc,*)=speed(0,*)
;      temp=th(ilev)*((p/1000.)^(.286))
;      height=(msf - 1004.*temp)/(9.86*1000.)
;
; mean and median PV per SF bin
;
      erase
      !type=2^2+2^3
;     xyouts,.41,.92,sdate,/normal,color=0,charsize=1.5
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      sfmax=1e-5
      sfmin=-1.e-5
      pvmin=1.e-4
      pvmax=1.
      plot,findgen(10),findgen(10),/nodata,xrange=[sfmin,sfmax],yrange=[pvmin,pvmax],$
           /ylog,color=0,xtitle='!4W!1  (s!u-1!n)',ytitle='Mean PV (Km!u-2!nkg!u-1!ns!u-1!n)',xticks=4,charsize=1,$
ytickname=['10!u-4!n','10!u-3!n','10!u-2!n','10!u-1!n','1'],ytickv=[1.e-4,1.e-3,1.e-2,1.e-1,1]
      sfbins=sfmin+((sfmax-sfmin)/20.)*findgen(21)
      dsf=sfbins(1)-sfbins(0)
      for ilev=0L,nth-1L do begin
          sf=transpose(sf2(*,*,ilev))
          pv=transpose(pv2(*,*,ilev))
          mark=transpose(mark2(*,*,ilev))
          marknew=transpose(marknew2(*,*,ilev))
          meanpv=fltarr(n_elements(sfbins))
          medianpv=fltarr(n_elements(sfbins))
          sigmapv=fltarr(n_elements(sfbins))
          for ii=0L,n_elements(sfbins)-1L do begin
              index=where(y2d gt 40. and sf ge sfbins(ii)-dsf and sf lt sfbins(ii)+dsf)
              if n_elements(index) ge 2L then begin
              result=moment(pv(index))
              meanpv(ii)=result(0)
              medianpv(ii)=median(pv(index))
              sigmapv(ii)=sqrt(result(1))
              endif
          endfor
          index=where(meanpv gt 0.)
          if index(0) ne -1L then begin
             meanpv(index)=smooth(meanpv(index),3)
;            oplot,sfbins(index),meanpv(index),psym=0,color=col2(ilev),thick=6
;for ii=0L,n_elements(index)-1 do begin
;    plots,sfbins(index(ii)),meanpv(index(ii))-sigmapv(index(ii))
;    plots,sfbins(index(ii)),meanpv(index(ii))+sigmapv(index(ii)),/continue,color=col2(ilev)
;endfor
             oplot,sfbins(index),medianpv(index),psym=0,color=col2(ilev),thick=6
             if th(ilev) eq thlev or th(ilev) eq thlev1 then $
                oplot,sfbins(index),meanpv(index),color=0,psym=0,linestyle=2,thick=10
          endif
;if min(meanpv) lt 0. then stop
;print,th(ilev),min(meanpv),max(meanpv)
;print,meanpv
;print,meanlat
;stop
      endfor
;
      imin=min(th)
      imax=max(th)
      ymnb=yorig(0)-0.08
      ymxb=ymnb+cbarydel
      set_viewport,xorig(0),xorig(0)+xlen,ymnb,ymxb
      !type=2^2+2^3+2^6
      xpos=[500.,1000.,1500.,2000.,2500.,3000.,3500.,4000.,4500.]
      nxticks=n_elements(xpos)
      spos=strcompress(long(xpos),/remove_all)
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='Theta (K)',$
           xticks=n_elements(xpos)-1,xtickv=xpos,xtickname=spos
      ybox=[0,10,10,0,0]
      x1=imin
nlvls=20
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
      dx=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
      xbox=[x1,x1,x1+dx,x1+dx,x1]
      polyfill,xbox,ybox,color=col1(j)
      x1=x1+dx
      endfor

      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device,/close
         spawn,'convert -trim figure_4_'+sdate+'_new_median.ps -rotate -90 figure_4_'+sdate+'_new_median.jpg'
;        spawn,'/usr/bin/rm figure_4_'+sdate+'_new_median.ps'
      endif

goto,jump
end
