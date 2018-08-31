;
; plot mean latitude vs SF and PV at all levels
; plot mean latitude difference profiles along side
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
xorig=[0.10,0.55]
yorig=[0.4,0.4]
xlen=0.25
ylen=0.25
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
rtd=double(180./!pi)
dtr=1./rtd
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
          /bold,/color,bits_per_pixel=8,/helvetica,filename='figure_2_'+sdate+'_new.ps'
      endif
      thlev1=3600.
      thlev=1000.
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
;     xyouts,.4,.7,sdate,/normal,color=0,charsize=2
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      sfmax=6e-6
      sfmin=-6e-6
      plot,findgen(10),findgen(10),/nodata,xrange=[sfmax,sfmin],yrange=[40.,80.],$
           color=0,xtitle='!4W!1  (s!u-1!n)',ytitle='Mean Latitude',xticks=2,charsize=1
      nbins=20L
      meanlat_sf=fltarr(nbins,nth)
      meanlat_pv=fltarr(nbins,nth)
      sigmalat_sf=fltarr(nbins,nth)
      sigmalat_pv=fltarr(nbins,nth)
;
; loop over theta surfaces
;
      for ilev=nth-1L,0L,-1L do begin
          pv=transpose(pv2(*,*,ilev))
          sf=transpose(sf2(*,*,ilev))
          index=where(y2d gt 40.)
          pvmax=max(pv(index))*.9
          pvmin=min(pv(index))*.9
          pvbin=pvmax-((pvmax-pvmin)/float(nbins))*findgen(nbins)
          sfmax=max(sf(index))*.9
          sfmin=min(sf(index))*.9
          sfbin=sfmax-((sfmax-sfmin)/float(nbins))*findgen(nbins)
          n=0L
          t=where(y2d gt 40. and pv gt pvbin(n))
          if n_elements(t) ge 2L then begin
             result=moment(y2d(t))
             wlat=total( y2d(t)*cos(y2d(t)*dtr) )/total( cos(y2d(t)*dtr) )
             meanlat_pv(n,ilev)=wlat
             sigmalat_pv(n,ilev)=sqrt(result(1))
          endif
          t=where(y2d gt 40. and sf gt sfbin(n))
          if n_elements(t) ge 2L then begin
             result=moment(y2d(t))
             wlat=total( y2d(t)*cos(y2d(t)*dtr) )/total( cos(y2d(t)*dtr) )
             meanlat_sf(n,ilev)=wlat
             sigmalat_sf(n,ilev)=sqrt(result(1))
          endif
          for n=1,nbins-2L do begin
              t=where(y2d gt 40. and pv le pvbin(n) and pv gt pvbin(n+1))
              if n_elements(t) ge 2L then begin
                 result=moment(y2d(t))
                 wlat=total( y2d(t)*cos(y2d(t)*dtr) )/total( cos(y2d(t)*dtr) )
                 meanlat_pv(n,ilev)=wlat
                 sigmalat_pv(n,ilev)=sqrt(result(1))
              endif
              t=where(y2d gt 40. and sf le sfbin(n) and sf gt sfbin(n+1))
              if n_elements(t) ge 2L then begin
                 result=moment(y2d(t))
                 wlat=total( y2d(t)*cos(y2d(t)*dtr) )/total( cos(y2d(t)*dtr) )
                 meanlat_sf(n,ilev)=wlat
                 sigmalat_sf(n,ilev)=sqrt(result(1))
              endif
          endfor
          n=nbins-1
          t=where(y2d gt 40. and pv le pvbin(n))
          if n_elements(t) ge 2L then begin
             result=moment(y2d(t))
             wlat=total( y2d(t)*cos(y2d(t)*dtr) )/total( cos(y2d(t)*dtr) )
             meanlat_pv(n,ilev)=wlat
             sigmalat_pv(n,ilev)=sqrt(result(1))
          endif
          t=where(y2d gt 40. and sf le sfbin(n))
          if n_elements(t) ge 2L then begin
             result=moment(y2d(t))
             wlat=total( y2d(t)*cos(y2d(t)*dtr) )/total( cos(y2d(t)*dtr) )
             meanlat_sf(n,ilev)=wlat
             sigmalat_sf(n,ilev)=sqrt(result(1))
          endif
          meanlat_sf_lev=reform(meanlat_sf(*,ilev))
          index=where(meanlat_sf_lev ne 0.)
          meanlat_sfsm=meanlat_sf_lev(index)
          if ilev mod 2 eq 0 or th(ilev) le 2000. then oplot,sfbin(index),meanlat_sfsm,color=col2(ilev),psym=0,thick=5
          if th(ilev) eq thlev or th(ilev) eq thlev1 then oplot,sfbin(index),meanlat_sfsm,color=0,psym=0,linestyle=2,thick=10
      endfor  ; loop over altitude
;
; delta latitude for SF profile
;
      sfdiff=fltarr(nth)
      for ilev=nth-1L,0L,-1L do begin
          sf=transpose(sf2(*,*,ilev))
          index=where(y2d gt 40.)
          sfmax=max(sf(index))*0.9 & sfmin=min(sf(index))*0.9
          sfbin=sfmin+((sfmax-sfmin)/float(nbins))*findgen(nbins)
          index=where(meanlat_sf(*,ilev) ne 0.)
          sfdiff(ilev)=abs(meanlat_sf(nbins-1,ilev)-max(meanlat_sf(index,ilev)))
      endfor    ; loop over altitude
      set_viewport,xmx+0.0775,xmx+0.125,ymn,ymx
      yindex=where(th eq 500. or th eq 1000. or $
                   th eq 2000. or th eq 3000. or th eq 4000. or th eq 4600.,nxticks)
      ypos=[500.,1000.,1500.,2000.,2500.,3000.,3500.,4000.,4500.]
      nyticks=n_elements(ypos)
      spos=strcompress(long(ypos),/remove_all)
      !type=2^2+2^3
      plot,sfdiff,th,color=0,thick=5,/noeras,xtitle='Lat Diff',title='!4W!1',$
           ytitle='Theta (K)',xrange=[0.,40.],yrange=[500.,4600.],xticks=2,$
           yticks=nyticks-1,ytickname=spos,ytickv=ypos,charsize=0.8

      !type=2^2+2^3
      xmn=xorig(1)
      xmx=xorig(1)+xlen
      ymn=yorig(1)
      ymx=yorig(1)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      pvmin=1.e-4
      pvmax=5.
      plot,findgen(10),findgen(10),/nodata,xrange=[pvmin,pvmax],yrange=[40.,80.],$
           color=0,xtitle='PV (Km!u2!nkg!u-1!ns!u-1!n)',ytitle='Mean Latitude',charsize=1,/xlog,$
           xtickname=['10!u-4!n','10!u-3!n','10!u-2!n','10!u-1!n','1'],xtickv=[1.e-4,1.e-3,1.e-2,1.e-1,1]
      for ilev=nth-1L,0,-1L do begin
          pv=transpose(pv2(*,*,ilev))
          index=where(y2d gt 40.)
          pvmax=max(pv(index))*.9 & pvmin=min(pv(index))*.9
          pvbin=pvmax-((pvmax-pvmin)/float(nbins))*findgen(nbins)
          index=where(meanlat_pv(*,ilev) ne 0.)
          if ilev mod 2 eq 0 or th(ilev) le 2000. then $
             oplot,pvbin(index),meanlat_pv(index,ilev),color=col2(ilev),psym=0,thick=5
          if th(ilev) eq thlev or th(ilev) eq thlev1 then $
             oplot,pvbin(index),meanlat_pv(index,ilev),color=0,psym=0,linestyle=2,thick=5
      endfor  ; loop over altitude
;
; delta latitude for PV profile
;
      pvdiff=fltarr(nth)
      for ilev=nth-1L,0L,-1L do begin
          pv=transpose(pv2(*,*,ilev))
          index=where(y2d gt 40.)
          pvmax=max(pv(index))*0.9 & pvmin=min(pv(index))*0.9
          pvbin=pvmin+((pvmax-pvmin)/float(nbins))*findgen(nbins)
          index=where(meanlat_pv(*,ilev) ne 0.)
          pvdiff(ilev)=abs(meanlat_pv(0,ilev)-max(meanlat_pv(index,ilev)))
      endfor    ; loop over altitude
      set_viewport,xmx+0.0775,xmx+0.125,ymn,ymx
      plot,pvdiff,th,color=0,thick=5,/noeras,xtitle='Lat Diff',title='PV',$
           ytitle='Theta (K)',xrange=[0.,40.],yrange=[500.,4600.],xticks=2,$
           yticks=nyticks-1,ytickname=spos,ytickv=ypos,charsize=0.8

      imin=min(th)
      imax=max(th)
      ymnb=yorig(1)-0.08
      ymxb=ymnb+cbarydel
      set_viewport,xorig(0),xmx+0.125,ymnb,ymxb
      !type=2^2+2^3+2^6
      xindex=where(th eq 500. or th eq 1000. or $
             th eq 2000. or th eq 3000. or th eq 4000. or th eq 4600.,nxticks)
      xpos=[500.,1000.,1500.,2000.,2500.,3000.,3500.,4000.,4500.]
      nxticks=n_elements(xpos)
      spos=strcompress(long(xpos),/remove_all)
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='Theta (K)',xticks=nxticks-1,$
           xtickname=spos,xtickv=xpos
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
         spawn,'convert -trim figure_2_'+sdate+'_new.ps -rotate -90 figure_2_'+sdate+'_new.jpg'
;        spawn,'/usr/bin/rm figure_2_'+sdate+'_new.ps'
      endif

goto,jump
end
