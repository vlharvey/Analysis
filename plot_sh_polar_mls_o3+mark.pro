;
; plot SH polar plot of MLS ozone and Met Office marker
;
@aura2date
@rd_ukmo_nc3
@stddat
@kgmt
@ckday
@kdate

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='x'
read,'setplot=',setplot
nxdim=750 & nydim=750
xorig=[0.10]
yorig=[0.10]
cbaryoff=0.075
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=0
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=icolmax
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
nmon=['01','02','03','04','05','06','07','08','09','10','11','12']
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
dirm='/aura6/data/MLS_data/Datfiles/'
ifile='                             '
;lstmn=9 & lstdy=8 & lstyr=2004 & lstday=0
lstmn=2 & lstdy=6 & lstyr=2005 & lstday=0
ledmn=6 & leddy=1 & ledyr=2006 & ledday=0
;read,' Enter starting year ',lstyr
;read,' Enter ending year ',ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
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
;
; read UKMO data
;
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      idate=long(smn+sdy)
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr
      lfile=nmon(imn-1)+'_'+sdy+'_'+uyr
      rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
      mark2=smooth(mark2,3,/edge_truncate)
      if icount eq 0L then begin
         rtheta=1000.
;        print,th
;        read,' Enter theta level ',rtheta
         index=where(rtheta eq th)
         if index(0) eq -1 then stop
         itheta=index(0)
         stheta=strcompress(string(fix(th(itheta))),/remove_all)
         xz2d=fltarr(nc,nth)
         yz2d=fltarr(nc,nth)
         for k=0,nth-1 do xz2d(*,k)=alon
         for j=0,nc-1 do yz2d(j,*)=th
         x=fltarr(nc+1)
         x(0:nc-1)=alon
         x(nc)=alon(0)+360.
         x2d=fltarr(nc+1,nr)
         y2d=fltarr(nc+1,nr)
         for i=0,nc do y2d(i,*)=alat
         for j=0,nr-1 do x2d(*,j)=x
      endif
;
; read MLS data
;
      dum=findfile(dirm+'MLS-Aura_L2GP_'+syr+smn+sdy+'.sav')
      if dum(0) eq '' then goto,jump
      restore,dirm+'MLS-Aura_L2GP_'+syr+smn+sdy+'.sav'
      mpress=o3.pressure
      mlev=n_elements(mpress)
      mprof=o3.ntimes
      mtime=o3.TIME
      mlat=o3.latitude
      mlon=o3.longitude
      index=where(mlon lt 0.)
      mlon(index)=mlon(index)+360.
      mtemp=tp.L2GPVALUE
      mo3=o3.L2GPVALUE*1.e6
      mo3prec=o3.L2GPPRECISION
      mo3stat=o3.STATUS
      mo3qual=o3.QUALITY
      mo3mask=0.*mo3
;
; eliminate bad uttimes
;
      index=where(mtime gt 0.,mprof)
      if index(0) eq -1L then goto,jump
      mtime=reform(mtime(index))
      mlat=reform(mlat(index))
      mlon=reform(mlon(index))
      mtemp=reform(mtemp(*,index))
      mo3=reform(mo3(*,index))
      mo3prec=reform(mo3prec(index))
      mo3stat=reform(mo3stat(index))
      mo3qual=reform(mo3qual(index))
      mo3mask=reform(mo3mask(*,index))
;
; use quality, status, and precision flags to remove suspect data
;
      o3bad=where(mo3prec lt 0.)
      if o3bad(0) ne -1L then mo3mask(o3bad)=-99.
      o3bad=where(mo3stat mod 2 ne 0L)                ; o3status=0 is good, all odd values are bad
      if o3bad(0) ne -1L then mo3mask(*,o3bad)=-99.
      o3bad=where(mo3qual lt 0.1)                     ; do not use if quality < 0.1
      if o3bad(0) ne -1L then mo3mask(*,o3bad)=-99.
;
; convert elapsed seconds to dates (yyyymmddhh)
;
      aura2date,mdate,mtime
;
; time is elapsed seconds since midnight 1 Jan 1993 to hours today
; convert to daily UT time (0-24 hours)
;
      muttime=mtime
      istime=1993010100L
      ehr=muttime/60./60.       ; convert time from seconds to hours
      hh2=0.d*muttime
      for n=0L,mprof-1L do begin
          yy1=istime/1000000
          if yy1 mod 4 eq 0 then mno(1)=29L
          if yy1 mod 4 ne 0 then mno(1)=28L
          mm1=istime/10000L-yy1*100L
          dd1=istime/100L-yy1*10000L-mm1*100L
          dd2=dd1+long(ehr(n))/24L
          hh1=istime-yy1*1000000L-mm1*10000L-dd1*100L
          yy2=yy1 & mm2=mm1
          while dd2 gt mno(mm2-1) do begin
                dd2=dd2-mno(mm2-1)
                mm2=mm2+1L
                if mm2 gt 12L then begin
                   mm2=mm2-12L
                   yy2=yy2+1L
                   if yy2 mod 4 eq 0 then mno(1)=29
                   if yy2 mod 4 ne 0 then mno(1)=28
                endif
          endwhile
          hh2(n)=ehr(n) mod 24
          if hh2(n) ge 24. then begin
             hh2(n)=hh2(n)-24.
             dd2=dd2+1L
             if dd2 gt mno(mm2-1L) then begin
                dd2=dd2-mno(mm2-1L)
                mm2=mm2+1L
                if mm2 gt 12L then begin
                   mm2=mm2-12L
                   yy2=yy2+1L
                endif
             endif
          endif
      endfor
      muttime=hh2
;
; calculate potential temperature
;
      mtheta=0.*mtemp
      for i=0L,mlev-1L do mtheta(i,*)=mtemp(i,*)*(1000./mpress(i))^0.286
      index=where(mtemp lt 0.)
      if index(0) ne -1L then mtheta(index)=-999.
      mpress2=0.*mo3
      mtime2=0.*mo3
      mlat2=0.*mo3
      mlon2=0.*mo3
      for i=0L,mprof-1L do mpress2(*,i)=mpress
      for i=0L,mlev-1L do begin
          mtime2(i,*)=muttime
          mlat2(i,*)=mlat
          mlon2(i,*)=mlon
      endfor
      print,iyr,imn,idy
;
; postscript file
;
      if setplot eq 'ps' then begin
         lc=0
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,$
                 filename='sh_polar_mls_o3+mark_'+lfile+'_'+stheta+'K.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
      endif
;
; polar projection
;
      pv1=transpose(pv2(*,*,itheta))
      sf1=transpose(sf2(*,*,itheta))
      mark1=transpose(mark2(*,*,itheta))
      pv=fltarr(nc+1,nr)
      pv(0:nc-1,0:nr-1)=pv1
      pv(nc,*)=pv(0,*)
      sf=fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1
      sf(nc,*)=sf(0,*)
      mark=fltarr(nc+1,nr)
      mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
      mark(nc,*)=mark(0,*)
      erase
      !type=2^2+2^3
      xyouts,.4,.95,syr+smn+sdy+'  '+stheta+' K',/normal,color=0,charsize=2
      set_viewport,.075,.325,.65,.9
      MAP_SET,-90,0,-180,/ortho,/contin,/grid,/noeras,color=lc,/noborder,charsize=1.5,title='Ozone'
      oplot,findgen(361),0.1+0.*findgen(361),psym=0,color=0
      contour,sf,x,alat,nlevels=30,c_color=lc,/overplot,/follow,c_labels=0,/noeras
      index=where(mark gt 0. and y2d lt 0.)
      if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=2,color=lc
      index=where(mark lt 0. and y2d lt 0.)
      if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=4,color=lc
      contour,mark,x,alat,levels=[.1],c_color=mcolor*.1,/overplot,/follow,c_labels=0,/noeras,thick=3
      contour,mark,x,alat,levels=[-.1],c_color=0,/overplot,/follow,c_labels=0,/noeras,thick=3
      a=findgen(8)*(2*!pi/8.)
      usersym,cos(a),sin(a),/fill
      index=where(mtheta gt rtheta-80. and mtheta le rtheta+80. and mlat2 lt 0.,npt)
      th0=string(FORMAT='(I4)',itheta)
      if index(0) eq -1L then goto,jump
      xdata=mlon2(index) & ydata=mlat2(index)
      o3data=mo3(index)
      o3mask=mo3mask(index)
      index=where(xdata lt 0.)
      if index(0) ne -1 then xdata(index)=xdata(index)+360.
      omin=2.0
      omax=10.
      for i=0L,n_elements(o3data)-1L do begin
          if o3mask(i) ne -99. then $
             oplot,[xdata(i),xdata(i)],[ydata(i),ydata(i)],psym=8,$
                   color=((o3data(i)-omin)/(omax-omin))*mcolor,symsize=1.5
      endfor
      MAP_SET,-90,0,-180,/ortho,/contin,/grid,/noeras,color=0,/noborder,charsize=1.5
;
; deviation of ozone from hemispheric mean
;
      set_viewport,.375,.625,.65,.9
      MAP_SET,-90,0,-180,/ortho,/contin,/grid,/noeras,color=lc,/noborder,charsize=1.5,title='O3-HemMean'
      oplot,findgen(361),0.1+0.*findgen(361),psym=0,color=0
      contour,sf,x,alat,nlevels=30,c_color=lc,/overplot,/follow,c_labels=0,/noeras
      index=where(mark gt 0. and y2d lt 0.)
      if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=2,color=lc
      index=where(mark lt 0. and y2d lt 0.)
      if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=4,color=lc
      contour,mark,x,alat,levels=[.1],c_color=mcolor*.1,/overplot,/follow,c_labels=0,/noeras,thick=3
      contour,mark,x,alat,levels=[-.1],c_color=0,/overplot,/follow,c_labels=0,/noeras,thick=3
      a=findgen(8)*(2*!pi/8.)
      usersym,cos(a),sin(a),/fill
      index=where(mtheta gt rtheta-80. and mtheta le rtheta+80. and mlat2 lt 0.,npt)
      if index(0) eq -1L then goto,jump
      th0=string(FORMAT='(I4)',itheta)
      xdata=mlon2(index) & ydata=mlat2(index)
      o3data=mo3(index)
      o3mask=mo3mask(index)
      index=where(xdata lt 0.)
      if index(0) ne -1 then xdata(index)=xdata(index)+360.
      omin=-3.0
      omax=3.
      o3mean=total(o3data)/n_elements(o3data)
print,'mean SH avg ',o3mean
      o3pr=o3data-o3mean
      for i=0L,n_elements(o3data)-1L do begin
          if o3mask(i) ne -99. then $
             oplot,[xdata(i),xdata(i)],[ydata(i),ydata(i)],psym=8,$
                   color=((o3pr(i)-omin)/(omax-omin))*mcolor,symsize=1.5
      endfor
      MAP_SET,-90,0,-180,/ortho,/contin,/grid,/noeras,color=0,/noborder,charsize=1.5
;
; determine number of SH swaths
;
      index=where(mlat le -81.7,npt)
      tswath=muttime(index)
      flag=0.*tswath
      nswath=50L
      tsave=fltarr(nswath)
      mcount=0L
      for i=0L,npt-1L do begin
          index=where(abs(tswath(i)-tswath) lt 1. and flag eq 0.)
          if index(0) ne -1L then begin
             flag(index)=1.0
             kindex=where(abs(muttime-tswath(index(0))) le 0.5 and mlat lt 0.)
;            oplot,mlon(kindex),mlat(kindex),psym=8,symsize=1.25,color=(float(i+1)/float(npt))*mcolor
             stime=string(FORMAT='(I2.2)',long(tswath(index(0))))
             tsave(mcount)=tswath(index(0))
             mcount=mcount+1L
             xtmp=mlon(kindex)
             ytmp=mlat(kindex)
             index=where(ytmp eq min(ytmp))
             xyouts,xtmp(index(0)),30.,stime,/data,charsize=1.5,alignment=0.5,color=0,charthick=3
          endif
      endfor
      tsave=tsave(0:mcount-1L)
;
; set viewport to plot all swaths
;
      xorig=[0.05,0.2,0.35,0.5,0.65,0.8,0.05,0.2,0.35,0.5,0.65,0.8,0.05,0.2,0.35,0.5,0.65,0.8]
      yorig=[0.5,0.5,0.5,0.5,0.5,0.5,0.3,0.3,0.3,0.3,0.3,0.3,0.1,0.1,0.1,0.1,0.1,0.1]-0.05
      xlen=0.1 & ylen=0.15
;
; loop over MLS swaths and calculate mean ozone at all levels in all ambient regions in the hemisphere
;
;     for iswath=0L,mcount-1L do begin
;         tplot=tsave(iswath)
;         kindex=where(abs(muttime-tplot) le 0.5 and mlat lt 0.,mprof)
          kindex=where(mlat lt 0.,mprof)
          o3swath=transpose(smooth(mo3(*,kindex),3,/edge_truncate))
          o3mask=transpose(mo3mask(*,kindex))
          index=where(o3swath lt 0.)
          if index(0) ne -1L then o3swath(index)=0.1
;         if iswath eq 0L then begin
             o3amb=fltarr(mlev)	; mean ozone profile in SH ambient regions
             thamb=fltarr(mlev)	; mean th profile in SH ambient regions
;         endif

          thswath=transpose(mtheta(*,kindex))
          lonswath=transpose(mlon2(*,kindex))
          latswath=transpose(mlat2(*,kindex))
          markswath=0.*latswath
          xswath=0.*thswath
          ylabels=string(format='(f4.1)',mlat(kindex))
          xlabels=string(format='(f5.1)',mlon(kindex))
          for i=0L,mlev-1L do xswath(*,i)=findgen(mprof)
;
; interpolate MetO marker to MLS swath
;
          for ii=0L,mprof-1L do begin
              for kk=0L,mlev-1L do begin
                  slon=lonswath(ii,kk)
                  slat=latswath(ii,kk)
                  slev=thswath(ii,kk)

                  if slon lt alon(0) then slon=slon+360.
                  for i=0L,nc-1L do begin
                      ip1=i+1
                      if i eq nc-1L then ip1=0L
                      xlon=alon(i)
                      xlonp1=alon(ip1)
                      if i eq nc-1L then xlonp1=360.+alon(ip1)
                      if slon ge xlon and slon le xlonp1 then begin
                         xscale=(slon-xlon)/(xlonp1-xlon)
                         goto,jumpx0
                      endif
                  endfor
jumpx0:
                  for j=0L,nr-2L do begin
                      jp1=j+1
                      xlat=alat(j)
                      xlatp1=alat(jp1)
                      if slat ge xlat and slat le xlatp1 then begin
                          yscale=(slat-xlat)/(xlatp1-xlat)
                          goto,jumpy0
                      endif
                  endfor
jumpy0:
                  for k=1L,nth-1L do begin
                      kp1=k-1             ; UKMO data is "top down"
                      uz=th(k)
                      uzp1=th(kp1)
                      if slev ge uz and slev le uzp1 then begin
                         zscale=(slev-uz)/(uzp1-uz)
                         pj1=mark2(j,i,k)+xscale*(mark2(j,ip1,k)-mark2(j,i,k))
                         pjp1=mark2(jp1,i,k)+xscale*(mark2(jp1,ip1,k)-mark2(jp1,i,k))
                         pj2=mark2(j,i,kp1)+xscale*(mark2(j,ip1,kp1)-mark2(j,i,kp1))
                         pjp2=mark2(jp1,i,kp1)+xscale*(mark2(jp1,ip1,kp1)-mark2(jp1,i,kp1))
                         p1=pj1+yscale*(pjp1-pj1)
                         p2=pj2+yscale*(pjp2-pj2)
                         markswath(ii,kk)=p1+zscale*(p2-p1)
                         goto,jumpz0
                      endif
                  endfor
jumpz0:
              endfor
          endfor

;
; calculate hemispheric mean in AMBIENT regions OUTSIDE the tropical region
;
           result=size(o3swath)
           nz=result(2)
           for k=0L,nz-1L do begin
               o3lev=reform(o3swath(*,k))
               marklev=reform(markswath(*,k))
               ylev=reform(latswath(*,k))
               thlev=reform(thswath(*,k))
               xx=where(o3lev ne 0. and abs(marklev) le 0.05 and abs(ylev) gt 25.,nn)
               if xx(0) ne -1L then o3amb(k)=total(o3lev(xx))/float(nn)
               if xx(0) ne -1L then thamb(k)=total(thlev(xx))/float(nn)
           endfor
;     endfor		; loop over swaths
;
; deviation of ozone from ambient mean
;
      set_viewport,.675,.925,.65,.9
      MAP_SET,-90,0,-180,/ortho,/contin,/grid,/noeras,color=lc,/noborder,charsize=1.5,title='O3-AmbMean'
      oplot,findgen(361),0.1+0.*findgen(361),psym=0,color=0
      contour,sf,x,alat,nlevels=30,c_color=lc,/overplot,/follow,c_labels=0,/noeras
      index=where(mark gt 0. and y2d lt 0.)
      if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=2,color=lc
      index=where(mark lt 0. and y2d lt 0.)
      if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=4,color=lc
      contour,mark,x,alat,levels=[.1],c_color=mcolor*.1,/overplot,/follow,c_labels=0,/noeras,thick=3
      contour,mark,x,alat,levels=[-.1],c_color=0,/overplot,/follow,c_labels=0,/noeras,thick=3
      a=findgen(8)*(2*!pi/8.)
      usersym,cos(a),sin(a),/fill
      index=where(thswath gt rtheta-80. and thswath le rtheta+80. and latswath lt 0.,npt)
      if index(0) eq -1L then goto,jump
      th0=string(FORMAT='(I4)',itheta)
      xdata=lonswath(index) & ydata=latswath(index)
      o3data=o3swath(index)
      o3mask=o3mask(index)
      o3mark=markswath(index)
      index=where(xdata lt 0.)
      if index(0) ne -1 then xdata(index)=xdata(index)+360.
      omin=-3.0
      omax=3.
      index=where(abs(o3mark) le 0.05 and ydata lt -25.,nn)
      o3mean=total(o3data(index))/float(nn)
print,'mean SH ambient ',o3mean
      o3pr=o3data-o3mean
      for i=0L,n_elements(o3data)-1L do begin
          if o3mask(i) ne -99. then $
             oplot,[xdata(i),xdata(i)],[ydata(i),ydata(i)],psym=8,$
                   color=((o3pr(i)-omin)/(omax-omin))*mcolor,symsize=1.5
      endfor
      for i=0L,nn-1L do begin
          if o3mask(index(i)) ne -99. then $
             oplot,[xdata(index(i)),xdata(index(i))],[ydata(index(i)),ydata(index(i))],psym=8,$
                   color=mcolor,symsize=1.5
      endfor
      MAP_SET,-90,0,-180,/ortho,/contin,/grid,/noeras,color=0,/noborder,charsize=1.5
;
; loop over all MLS swaths again, now looking for LOPs
;
      nlop=0L
      nhigh=0L
      for iswath=0L,mcount-1L do begin

          tplot=tsave(iswath)
;         print,tsave
;         read,'Central Swath times ',tplot
          kindex=where(abs(muttime-tplot) le 0.5 and mlat lt 0.,mprof)
          stime=string(FORMAT='(F4.1)',tplot)
;print,iswath,' swath at ',stime
;         for kk=0,mprof-1L,4L do $
;             oplot,[mlon(kindex(kk)),mlon(kindex(kk))],[mlat(kindex(kk)),mlat(kindex(kk))],$
;                    psym=2,symsize=1.75,color=lc
;
; extract MLS swath
;
          o3swath=transpose(smooth(mo3(*,kindex),3,/edge_truncate))
          o3mask=transpose(mo3mask(*,kindex))
          index=where(o3swath lt 0.)
          if index(0) ne -1L then o3swath(index)=0.1
          thswath=transpose(mtheta(*,kindex))
          if max(thswath) lt 0. then goto,jumpmlsswath
          lonswath=transpose(mlon2(*,kindex))
          latswath=transpose(mlat2(*,kindex))
          markswath=0.*latswath
          xswath=0.*thswath
          ylabels=string(format='(f4.1)',mlat(kindex))
          xlabels=string(format='(f5.1)',mlon(kindex))
          for i=0L,mlev-1L do xswath(*,i)=findgen(mprof)
;
; interpolate MetO marker to MLS swath
;
          for ii=0L,mprof-1L do begin
              for kk=0L,mlev-1L do begin
                  slon=lonswath(ii,kk)
                  slat=latswath(ii,kk)
                  slev=thswath(ii,kk)
    
                  if slon lt alon(0) then slon=slon+360.
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
                  for k=1L,nth-1L do begin
                      kp1=k-1             ; UKMO data is "top down"
                      uz=th(k)
                      uzp1=th(kp1)
                      if slev ge uz and slev le uzp1 then begin
                         zscale=(slev-uz)/(uzp1-uz)
                         pj1=mark2(j,i,k)+xscale*(mark2(j,ip1,k)-mark2(j,i,k))
                         pjp1=mark2(jp1,i,k)+xscale*(mark2(jp1,ip1,k)-mark2(jp1,i,k))
                         pj2=mark2(j,i,kp1)+xscale*(mark2(j,ip1,kp1)-mark2(j,i,kp1))
                         pjp2=mark2(jp1,i,kp1)+xscale*(mark2(jp1,ip1,kp1)-mark2(jp1,i,kp1))
                         p1=pj1+yscale*(pjp1-pj1)
                         p2=pj2+yscale*(pjp2-pj2)
                         markswath(ii,kk)=p1+zscale*(p2-p1)
                         goto,jumpz
                      endif
                  endfor
jumpz:
              endfor
          endfor
;
; hemispheric mean in all regions to fill with SOME data
;
          o3swath=transpose(smooth(mo3(*,kindex),3,/edge_truncate))
          o3mask=transpose(mo3mask(*,kindex))
          index=where(o3swath lt 0.)
          if index(0) ne -1L then o3swath(index)=0.1
          o3pr=0.*o3swath
          o3prpcnt=0.*o3swath
          index=where(abs(o3swath) gt 100. or o3mask eq -99.)
          if index(0) ne -1L then o3swath(index)=0.
          result=size(o3swath)
          nz=result(2)
          for k=0L,nz-1L do begin
              o3lev=reform(o3swath(*,k))
              xx=where(o3lev ne 0.,nn)
              if xx(0) ne -1L then begin
                 o3pr(xx,k)=o3lev(xx)-total(o3lev(xx))/float(nn)
;                o3prpcnt(xx,k)=100.*(o3lev(xx)-total(o3lev(xx))/float(nn) )/ ( total(o3lev(xx))/float(nn) )
                 o3prpcnt(xx,k)=100.*(o3lev(xx)-o3amb(k))/o3amb(k)
;                print,'o3mean in SH ',total(THSWATH(xx,k))/nn,total(o3lev(xx))/float(nn)
;if iswath eq 0L then print,'o3mean in midlat ambient ',total(THSWATH(xx,k))/nn,o3amb(k),total(o3lev(xx))/float(nn)
;o3levtest=reform(o3lev(xx))
;o3test=reform(o3prpcnt(xx,k))
;index=where(o3test lt -50.)
;if index(0) ne -1L then begin
;   print,'o3vals= ',o3levtest(index)
;   print,'thambmean= ',thamb(k)
;   print,'o3ambmean= ',o3amb(k)
;   stop
;endif
              endif
          endfor
;
; plot swaths of eddy ozone (%)
;
;         !type=2^2+2^3
;         set_viewport,xorig(iswath),xorig(iswath)+xlen,yorig(iswath),yorig(iswath)+ylen
;         omin=-50.
;         omax=50.
;         nlvls=11
;         level=omin+((omax-omin)/(nlvls-1))*findgen(nlvls)
;         col1=1+indgen(nlvls)*mcolor/nlvls
;         contour,o3prpcnt,xswath,thswath,levels=level,/cell_fill,title=stime+' UT',$
;                 c_color=col1,min_value=-999.,xticks=1,xrange=[0.,mprof-1L],xtickname=[' ',' '],$
;                 yrange=[500.,1800.],charsize=1.25,color=0
;         index=where(level gt 0.)
;         contour,o3prpcnt,xswath,thswath,levels=level(index),/follow,color=0,min_value=-999.,/overplot,c_labels=0*level
;         index=where(level lt 0.)
;         if index(0) ne -1L then $
;            contour,o3prpcnt,xswath,thswath,levels=level(index),/follow,color=mcolor,min_value=-999.,/overplot,c_labels=0*level
;         contour,o3prpcnt,xswath,thswath,levels=[0.0],/follow,color=0,thick=3,min_value=-999.,/overplot,c_labels=0*level
;         contour,markswath,xswath,thswath,levels=[-0.05],/follow,color=0,thick=5,min_value=-999.,/overplot,c_labels=0*level
;         contour,markswath,xswath,thswath,levels=[0.1],/follow,color=mcolor,thick=5,min_value=-999.,/overplot,c_labels=0*level

index=where(thswath gt 500. and thswath le 2000.)
print,'min o3 % ',min(o3prpcnt(index)),min(o3swath(index))

          index=where(thswath ge 600. and thswath le 1600. and $                ; altitude criteria
                      latswath lt -20. and $                                     ; latitude criteria
                      markswath lt -0.05)       ; in anticyclone criteria
          if index(0) ne -1L then begin
;            oplot,xswath(index),thswath(index),psym=2,color=mcolor
;
; save anticyclone coordinates
;
             if nhigh eq 0L then begin
                xhigh=lonswath(index)
                yhigh=latswath(index)
                thhigh=thswath(index)
                nhigh=nhigh+1L
             endif
             if nhigh gt 0L then begin
                xhigh=[xhigh,lonswath(index)]
                yhigh=[yhigh,latswath(index)]
                thhigh=[thhigh,thswath(index)]
                nhigh=nhigh+1L
             endif
          endif

          index=where(thswath ge 600. and thswath le 1600. and $		; altitude criteria
                      latswath lt -20. and $					; latitude criteria
                      markswath lt -0.05 and o3prpcnt le -10. and o3swath gt 2.0)	; in anticyclone and amplitude criteria
          if index(0) ne -1L then begin
;            oplot,xswath(index),thswath(index),psym=2,color=mcolor
;
; save LOP coordinates. save o3 value!
;
             if nlop eq 0L then begin
                xlop=lonswath(index)
                ylop=latswath(index)
                thlop=thswath(index)
                nlop=nlop+1L
             endif
             if nlop gt 0L then begin
                xlop=[xlop,lonswath(index)]
                ylop=[ylop,latswath(index)]
                thlop=[thlop,thswath(index)]
                nlop=nlop+1L
             endif
;            print,'LOP x range ',min(lonswath(index)),max(lonswath(index))
;            print,'LOP y range ',min(latswath(index)),max(latswath(index))
;            print,'LOP th range ',min(thswath(index)),max(thswath(index))
;            if min(latswath(index)) lt 30. then print,'LOP y range ',min(latswath(index)),max(latswath(index))
          endif

;         for i=0L,mprof-1L,50 do begin
;             plots,i,500
;             plots,i,450,/data,/continue,color=0
;             xyouts,i,400.,xlabels(i),/data,charsize=1.25,alignment=0.5,color=0
;             xyouts,i,350.,ylabels(i),/data,charsize=1.25,alignment=0.5,color=0
;         endfor
;         plots,mprof-1,500
;         plots,mprof-1,450,/data,/continue,color=0
;         xyouts,mprof-1,400.,xlabels(mprof-1),/data,charsize=1.25,alignment=0.5,color=0
;         xyouts,mprof-1,350.,ylabels(mprof-1),/data,charsize=1.25,alignment=0.5,color=0
jumpmlsswath:

      endfor	; loop over MLS swaths
;
; plot LOPs today in x-y colored by theta
;
      nlvls=11L
      col1=1+indgen(nlvls)*mcolor/nlvls
      if nlop gt 0L then begin
      !type=2^2+2^3
      set_viewport,.1,.45,.175,.575
      omin=600.
      omax=1800.
      plot,xlop,ylop,/nodata,color=0,xrange=[0.,360.],yrange=[-90.,-20.],xtitle='Longitude',$
           ytitle='Latitude',charsize=1.5,title='Plan View'
      for i=0L,n_elements(xhigh)-1L do $
          oplot,[xhigh(i),xhigh(i)],[yhigh(i),yhigh(i)],psym=8,color=0,symsize=2
      for i=0L,n_elements(xlop)-1L do begin
          oplot,[xlop(i),xlop(i)],[ylop(i),ylop(i)],psym=8,$
                   color=((thlop(i)-omin)/(omax-omin))*mcolor,symsize=1.5
      endfor
;
; horizontal theta color bar
;
      ymnb=.175-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,.1,.45,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[omin,omax],[0,0],yrange=[0,10],color=0,$
           xrange=[omin,omax],charsize=1.5,xtitle='LOP Theta (K)'
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor
;
; plot LOPs today in y-th colored by x
;
      !type=2^2+2^3
      set_viewport,.6,.95,.175,.575
      omin=0.
      omax=360.
      plot,ylop,thlop,/nodata,color=0,xrange=[-90.,-20.],yrange=[500.,1800.],xtitle='Latitude',$
           ytitle='Theta',charsize=1.5,title='East to West View'
      for i=0L,n_elements(xhigh)-1L do $
          oplot,[yhigh(i),yhigh(i)],[thhigh(i),thhigh(i)],psym=8,color=0,symsize=2
      for i=0L,n_elements(xlop)-1L do begin
          oplot,[ylop(i),ylop(i)],[thlop(i),thlop(i)],psym=8,$
                   color=((xlop(i)-omin)/(omax-omin))*mcolor,symsize=1.5
      endfor
;
; horizontal longitude color bar
;
      ymnb=.175-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,.6,.95,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[omin,omax],[0,0],yrange=[0,10],color=0,$
           xrange=[omin,omax],charsize=1.5,xtitle='LOP Longitude'
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor

      endif

      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device, /close
         spawn,'convert -trim sh_polar_mls_o3+mark_'+lfile+'_'+stheta+'K.ps -rotate -90 '+$
               ' sh_polar_mls_o3+mark_'+lfile+'_'+stheta+'K.jpg'
         spawn,'/usr/bin/rm sh_polar_mls_o3+mark_'+lfile+'_'+stheta+'K.ps'
      endif
      icount=icount+1L
goto,jump
end
