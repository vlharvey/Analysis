;
; test that save file exists with MLS and marker interpolation done
; ***MLS only***
; test LOP definition.  v2 defn: look at anticyclone mean/sigma and ambient mean/sigma
; within X km from anticyclone center of mass.
; VLH 9/7/2006
;
; plot zt ozone inside anticyclones
;
@aura2date
@rd_ukmo_nc3
@stddat
@kgmt
@ckday
@kdate
@range_ring
@fillit

re=40000./2./!pi
rad=double(180./!pi)
dtr=double(!pi/180.)
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0

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
cbaryoff=0.02
cbarydel=0.02
!NOERAS=-1
!p.charthick=2
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
dirs2='/aura3/data/SAGE_II_data/Datfiles_SOSST/'
dirs3='/aura3/data/SAGE_III_data/Datfiles_SOSST/'
dirh='/aura3/data/HALOE_data/Datfiles_SOSST/'
dirp='/aura3/data/POAM_data/Datfiles_SOSST/'
dira='/aura3/data/ACE_data/Datfiles_SOSST/v2.2/'
dirma='/aura3/data/MAESTRO_data/Datfiles_SOSST/v1.2/'
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
dirm='/aura6/data/MLS_data/Datfiles/'
ifile='                             '
lstmn=1 & lstdy=12 & lstyr=2006 & lstday=0
ledmn=1 & leddy=12 & ledyr=2006 & ledday=0
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
nday=ledday-lstday+1L
;
;goto,plotit
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; read UKMO data
;
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr
      lfile=nmon(imn-1)+'_'+sdy+'_'+uyr
      if setplot eq 'ps' then begin
         lc=0
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,filename='polar_high_cmass_nhDL_'+syr+smn+sdy+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
      endif
;
; test for end condition and close windows.
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' normal termination condition'

      dum=findfile('/aura2/harvey/Analysis/Datfiles_MLS/mls+mark_'+syr+smn+sdy+'.sav')
      if dum(0) ne '' then begin
;        print,'save file exists ',iyr,imn,idy
         if icount gt 0L then goto,jump2save
      endif
      rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jumpday
;     mark2=smooth(mark2,3,/edge_truncate)
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
;
; zt arrays
;
         lop_zt=fltarr(nday,nth)-99.
         ho3mean_zt=fltarr(nday,nth)-99.
         ao3mean_zt=fltarr(nday,nth)-99.
         ho3sigma_zt=fltarr(nday,nth)-99.
         ao3sigma_zt=fltarr(nday,nth)-99.
         date_zt=strarr(nday)
      endif
;
; read MLS data
;
      dum=findfile(dirm+'MLS-Aura_L2GP_'+syr+smn+sdy+'.sav')
      if dum(0) eq '' then goto,jumpday
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
      if index(0) eq -1L then goto,jumpday
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
      mtheta2=0.*mtemp
      for i=0L,mlev-1L do mtheta2(i,*)=mtemp(i,*)*(1000./mpress(i))^0.286
      index=where(mtemp lt 0.)
      if index(0) ne -1L then mtheta2(index)=-999.
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
; interpolate MetO marker to MLS data (mo3, mo3mask, mpress2, mtheta2, mlon2, mlat2, mtime2
; but retain field of integers
;
      mmark2=0.*mo3
      for ii=0L,mprof-1L do begin
          for kk=0L,mlev-1L do begin
              slon=mlon2(kk,ii)
              slat=mlat2(kk,ii)
              slev=mtheta2(kk,ii)
              if slev lt 500. then goto,jumpz
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
                     p1=mark2(j,i,k)
                     p2=mark2(jp1,i,k)
                     p3=mark2(j,ip1,k)
                     p4=mark2(jp1,ip1,k)
                     p5=mark2(j,i,kp1)
                     p6=mark2(jp1,i,kp1)
                     p7=mark2(j,ip1,kp1)
                     p8=mark2(jp1,ip1,kp1)
                     if p1 eq 1. or p2 eq 1. or p3 eq 1. or p4 eq 1. or $
                        p5 eq 1. or p6 eq 1. or p7 eq 1. or p8 eq 1. then $
                        mmark2(kk,ii)=1.0
                     if p1 lt 0. or p2 lt 0. or p3 lt 0. or p4 lt 0. or $
                        p5 lt 0. or p6 lt 0. or p7 lt 0. or p8 lt 0. then $
                        mmark2(kk,ii)=min([p1,p2,p3,p4,p5,p6,p7,p8])
                     goto,jumpz
                  endif
              endfor
jumpz:
          endfor
      endfor
;
; restore save file with MLS and MetO marker
;
jump2save:
restore,'/aura2/harvey/Analysis/Datfiles_MLS/mls+mark_'+syr+smn+sdy+'.sav'
date_zt(icount)=lfile
;
; determine number of NH swaths 
;
      mprof=n_elements(mlat)
      index=where(mlat ge 81.7,npt)
      tswath=muttime(index)
      flag=0.*tswath
      nswath=50L
      tsave=fltarr(nswath)
      mcount=0L
      for i=0L,npt-1L do begin
          index=where(abs(tswath(i)-tswath) lt 1. and flag eq 0.)
          if index(0) ne -1L then begin
             flag(index)=1.0
             kindex=where(abs(muttime-tswath(index(0))) le 0.5 and mlat gt 0.)
             stime=string(FORMAT='(I2.2)',long(tswath(index(0))))
             tsave(mcount)=tswath(index(0))
             mcount=mcount+1L
             xtmp=mlon(kindex)
             ytmp=mlat(kindex)
             index=where(ytmp eq min(ytmp))
          endif
      endfor
      tsave=tsave(0:mcount-1L)
;
; interpolate MLS data to MetO theta surfaces (use mtheta2(mlev,mprof) and th(nth) to make mtheta_th(nth,mprof))
;
    mtheta_th=fltarr(nth,mprof)
    mo3_th=fltarr(nth,mprof)
    mo3mask_th=fltarr(nth,mprof)
    mmark_th=fltarr(nth,mprof)
    mtemp_th=fltarr(nth,mprof)
    mpress2_th=fltarr(nth,mprof)
    mtime2_th=fltarr(nth,mprof)
    mlat2_th=fltarr(nth,mprof)
    mlon2_th=fltarr(nth,mprof)
    for k=0L,nth-1L do begin    ; no need to interpolate time,lat,lon
        mtime2_th(k,*)=muttime
        mlat2_th(k,*)=mlat
        mlon2_th(k,*)=mlon
    endfor
    for ii=0L,mprof-1L do begin
        for k=0L,nth-1L do begin
            ulev=th(k)
            for kk=0L,mlev-2L do begin
                kp1=kk+1
                mlev0=mtheta2(kk,ii)     ; MLS profiles start at the bottom
                mlev1=mtheta2(kp1,ii)
                if mlev0 le ulev and mlev1 gt ulev then begin
                   zscale=(ulev-mlev0)/(mlev1-mlev0)
                   mtheta_th(k,ii)=mlev0+zscale*(mlev1-mlev0)
                   mpress2_th(k,ii)=exp(alog(mpress2(kk,ii))+zscale*(alog(mpress2(kp1,ii))-alog(mpress2(kk,ii))))
                   mtemp_th(k,ii)=mtemp(kk,ii)+zscale*(mtemp(kp1,ii)-mtemp(kk,ii))
                   mo3_th(k,ii)=mo3(kk,ii)+zscale*(mo3(kp1,ii)-mo3(kk,ii))
;
; if either mask above or below is set then set here
;
                   if mo3mask(kk,ii) eq -99 or mo3mask(kp1,ii) eq -99. then mo3mask_th(k,ii)=-99.
;
; retain integer values for marker
;
                   if mmark2(kk,ii) ne 0. then mmark_th(k,ii)=mmark2(kk,ii)
                   if mmark2(kp1,ii) ne 0. then mmark_th(k,ii)=mmark2(kp1,ii)

                   goto,jumpzz
                endif
            endfor
jumpzz:
        endfor
    endfor
;
; loop over theta levels ranging from 2000-500K
; save anticyclone points and nearby ambient points (t,x,y,th,o3)
;
erase
set_viewport,.1,.9,.1,.9
map_set,90,-90,0,/stereo,/contin,/grid,color=0,title=syr+smn+sdy,charsize=2
index=where(mark2 ne 0.)
mark2sm=0.*mark2
if index(0) ne -1L then mark2sm(index)=mark2(index)/abs(mark2(index))
mark2sm=smooth(mark2sm,3,/edge_truncate)
      ho3mean_save=fltarr(nth)
      ao3mean_save=fltarr(nth)
      ho3sigma_save=fltarr(nth)
      ao3sigma_save=fltarr(nth)
      ho3_save=-99.
      ao3_save=-99.
      hth_save=-99.
      ath_save=-99.
      hx_save=-99.
      ax_save=-99.
      hy_save=-99.
      ay_save=-99.
      ht_save=-99.
      at_save=-99.
      nlvls=12L
      col1=1+indgen(nlvls)*mcolor/(float(nlvls))
      for k=11L,0L,-1L do begin
;
; extract MetO anticyclone info
;
          mark1=transpose(mark2sm(*,*,k))
          mark=fltarr(nc+1,nr)
          mark(0:nc-1,0:nr-1)=mark1
          mark(nc,*)=mark(0,*)
;
; zero out non-pacific anticyclones
;
index=where(x2d lt 90. or x2d gt 270. and mark lt 0.)
if index(0) ne -1 then mark(index)=0.
index=where(y2d lt 30.)
if index(0) ne -1 then mark(index)=0.
          contour,mark,x,alat,levels=[-.1],c_color=0,/overplot,/follow,c_labels=0,/noeras,thick=10
loadct,0
contour,mark,x,alat,levels=[.1],c_color=mcolor*.7,/overplot,/follow,c_labels=0,/noeras,thick=5
loadct,38

          rtheta2=th(k)
          index=where(rtheta2 eq th)
          itheta=index(0)
;
; look in NH for anticyclones
;
          index=where(mtheta_th eq rtheta2 and mlat2_th gt 0.,npt)
          if index(0) eq -1L then goto,jumplev
          xdata=mlon2_th(index) & ydata=mlat2_th(index) & tdata=mtime2_th(index)
          o3data=mo3_th(index)
          o3mask=mo3mask_th(index)
          o3mark=mmark_th(index)
          o3theta=mtheta_th(index)
          index=where(xdata lt 0.)
          if index(0) ne -1 then xdata(index)=xdata(index)+360.
;
; if there are no anticyclones on this level then jumplev
;
          if min(o3mark) eq 0. then goto,jumplev
;
; loop over all anticyclones on a given level
;
;         for ihigh=1,abs(min(o3mark)) do begin
;             mmin=-1.0*ihigh
;
; based on marked MLS data
;
;             hindex=where(xdata ge 90. and xdata le 270. and ydata ge 30. and o3mark lt 0.,nhigh)	;eq mmin,nhigh)
;
; based on MetO highs
;
              hindex=where(x2d ge 90. and x2d le 270. and y2d ge 30. and mark lt 0.,nhigh)	;eq mmin,nhigh)
              if nhigh lt 2L then goto,jumphigh	; no MLS data in this anticyclone 
;
; normalise by area of each gridpoint.  without this logic, the center of mass is shifted poleward
;
;             adata=1.+0.*xdata
              adata=1.+0.*x2d
;             deltax=alon(1)-alon(0)
;             deltay=alat(1)-alat(0)
;             for jj=0L,npt-1L do begin
;                 hy=re*deltay*dtr
;                 dx=re*cos(ydata(jj)*dtr)*deltax*dtr
;                 adata(jj)=1.0     ;dx*hy    ; area of each grid point
;             endfor
;             adata=adata/max(adata)

;             resultx=moment(xdata(hindex))
              resultx=moment(x2d(hindex))
              x0=resultx(0)
;
; for anticyclone that spans the GM
;
;             if min(xdata(hindex)) lt 45. and max(xdata(hindex)) gt 315. then begin
;                xdata_save=xdata(hindex) 
;                index=where(xdata_save gt 180.)
;                xdata_save(index)=xdata_save(index)-360.
;                xdata(hindex)=xdata_save
;                resultx=moment(xdata(hindex))
;                x0=resultx(0)
;                if x0 lt 0. then x0=x0+360.
;             endif
;             resulty=moment(ydata(hindex)*adata(hindex))	; normalise by area
              resulty=moment(y2d(hindex)*adata(hindex))	; normalise by area
              y0=resulty(0)
;             if y0 le 30. then goto,jumplev		; ignore tropical anticyclones
;
; draw range ring 100 km beyond anticyclone edge
;
;             dxf=re*abs(x0-xdata(hindex))*dtr*cos(y0*dtr)
;             dyf=re*abs(y0-ydata(hindex))*dtr
              dxf=re*abs(x0-x2d(hindex))*dtr*cos(y0*dtr)
              dyf=re*abs(y0-y2d(hindex))*dtr

              dist=sqrt(dxf*dxf+dyf*dyf)
              dist0=max(dist)+500.
              if dist0 gt 4000. then dist0=4000.
              range_ring,y0,x0,dist0,360,bear,lats,lons
print,rtheta2,x0,y0,dist0,min(o3mark),min(mark)
oplot,[x0,x0],[y0,y0],psym=8,symsize=3,color=col1(11-k)
oplot,lons,lats,color=col1(11-k),thick=7
;
; extract ambient MLS ozone within dist0 of anticyclone and plot
;
              dxf=re*abs(x0-xdata)*dtr*cos(y0*dtr)
              dyf=re*abs(y0-ydata)*dtr
              dist=sqrt(dxf*dxf+dyf*dyf)
              agood=where(o3mark eq 0. and dist le dist0 and ydata ge 20.)
              hgood=where(o3mark lt 0. and dist le dist0 and ydata ge 30.)
;
; save ambient and anticyclone ozone and theta
;
              if hgood(0) ne -1L then begin
                 ho3_save=[ho3_save,o3data(hgood)]
                 hth_save=[hth_save,o3theta(hgood)]
                 hx_save=[hx_save,xdata(hgood)]
                 hy_save=[hy_save,ydata(hgood)]
                 ht_save=[ht_save,tdata(hgood)]
                 if n_elements(hgood) ge 3L then begin
;oplot,xdata(hgood),ydata(hgood),psym=8,color=0,symsize=1.5
                    result=moment(o3data(hgood))
                    ho3mean_save(k)=result(0)
                    ho3sigma_save(k)=sqrt(result(1))
                 endif
              endif
              if agood(0) ne -1L then begin
                 ao3_save=[ao3_save,o3data(agood)]
                 ath_save=[ath_save,o3theta(agood)]
                 ax_save=[ax_save,xdata(agood)]
                 ay_save=[ay_save,ydata(agood)]
                 at_save=[at_save,tdata(agood)]
                 if n_elements(agood) ge 3L then begin
;oplot,xdata(agood),ydata(agood),psym=4,color=0,symsize=1.5
                    result=moment(o3data(agood))
                    ao3mean_save(k)=result(0)
                    ao3sigma_save(k)=sqrt(result(1))
                 endif
              endif
          jumphigh:
;         endfor	; loop over highs
          jumplev:
      endfor	; end loop over theta
;
; save mean ozone profiles on this day
;
      ho3mean_zt(icount,*)=ho3mean_save
      ao3mean_zt(icount,*)=ao3mean_save
      ho3sigma_zt(icount,*)=ho3sigma_save
      ao3sigma_zt(icount,*)=ao3sigma_save
;index=where(ho3mean_save gt 0.)
;plot,ho3mean_save(index),th(index),color=mcolor*.9,thick=5,psym=0
;index=where(ao3mean_save gt 0.)
;oplot,ao3mean_save(index),th(index),color=0,thick=5,psym=0
;
; loop over theta again
; mark anticyclone points with ozone less than ambient-1.5 sigma and 1 ppmv lower than ambient mean
;
;
; lop arrays
;
         tlop_save=[-99.]
         xlop_save=[-99.]
         ylop_save=[-99.]
         o3lop_save=[-99.]
         thlop_save=[-99.]
nlvls=12
col1=reverse(1+indgen(nlvls)*mcolor/(float(nlvls)))
      for k=0L,11L do begin
          index=where(ath_save eq th(k))
          if index(0) eq -1L then goto,jumplev2
;
; 1 sigma threshold
;
          ao3thresh=ao3mean_save(k)-1.*ao3sigma_save(k)
          index=where(hth_save eq th(k) and ho3_save lt ao3thresh,npt)	; and $
;
; 1 ppmv less than ambient mean
;
;                     ao3thresh-ho3_save ge 1.0,npt)
          if index(0) eq -1L then goto,jumplev2
;
; save LOP location and ozone
;
          tlop_save=[tlop_save,float(iyr)*1000.+float(iday)+ht_save(index)/24.]
          xlop_save=[xlop_save,hx_save(index)]
          ylop_save=[ylop_save,hy_save(index)]
          thlop_save=[thlop_save,th(k)+fltarr(npt)]
          o3lop_save=[o3lop_save,ho3_save(index)]
;oplot,hx_save(index),hy_save(index),symsize=2,psym=4,color=col1(k)
;
; retain LOP altitude
;
          lop_zt(icount,k)=1.
      jumplev2:
      endfor
col1=1+indgen(nlvls)*mcolor/(float(nlvls))
      xmnb=0.9-0.02
      xmxb=xmnb+cbarydel
      set_viewport,xmnb,xmxb,.1,.9
      !type=2^2+2^3+2^5
      omin=th(11)
      omax=th(0)
      plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax],color=0,title='Theta   ',charsize=1.5
      xbox=[0,10,10,0,0]
      y1=omin
      dy=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor
;
; remove first point
;
      index=where(xlop_save ne -99.,nlop)
      if index(0) ne -1L then begin
         tlop_save=tlop_save(index)
         xlop_save=xlop_save(index)
         ylop_save=ylop_save(index)
         thlop_save=thlop_save(index)
         o3lop_save=o3lop_save(index)
      endif
;     xyouts,0.12,0.12,strcompress(nlop,/remove_all)+' LOP Points',color=0,/normal,charsize=2

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim polar_high_cmass_nhDL_'+syr+smn+sdy+'.ps -rotate -90 polar_high_cmass_nhDL_'+syr+smn+sdy+'.jpg'
endif
jumpday:
      icount=icount+1L
goto,jump

end
