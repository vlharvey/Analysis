;
; plot MLS ozone and SOSST ozone on a NH polar plot
;
@aura2date
@rd_ukmo_nc3
@stddat
@kgmt
@ckday
@kdate
@range_ring

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
cbaryoff=0.015
cbarydel=0.01
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
lstmn=1 & lstdy=7 & lstyr=2005 & lstday=0
ledmn=4 & leddy=1 & ledyr=2006 & ledday=0
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
      dum=findfile('/aura2/harvey/Analysis/Datfiles_MLS/mls+mark_'+syr+smn+sdy+'.sav')
      if dum(0) ne '' then begin
         print,'save file exists ',iyr,imn,idy
         goto,jump2save
      endif
      rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
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
restore,'/aura2/harvey/MLS_LOP_defn/Datfiles_MLS/mls+mark_'+syr+smn+sdy+'.sav'
;
; read year of SOSST data
;
      if icount eq 0L or iday eq 1L then begin
         restore,dirs2+'cat_sage2_v6.2.'+syr
         restore,dirs2+'o3_sage2_v6.2.'+syr
         datesage2_all=date
         ysage2_all=latitude
         xsage2_all=longitude
         o3sage2_all=mix
         restore,dirs3+'cat_sage3_v3.00.'+syr
         restore,dirs3+'o3mlr_sage3_v3.00.'+syr
         datesage3_all=date
         ysage3_all=latitude
         xsage3_all=longitude
         o3sage3_all=mix
         restore,dirh+'cat_haloe_v19.'+syr
         restore,dirh+'o3_haloe_v19.'+syr
         datehal_all=date
         yhal_all=latitude
         xhal_all=longitude
         o3hal_all=mix
         restore,dirp+'cat_poam3_v4.0.'+syr
         restore,dirp+'o3_poam3_v4.0.'+syr
         datepoam_all=date
         ypoam_all=latitude
         xpoam_all=longitude
         o3poam_all=mix
         restore,dira+'cat_ace_v2.2.'+syr
         restore,dira+'o3_ace_v2.2.'+syr
         dateace_all=date
         yace_all=latitude
         xace_all=longitude
         o3ace_all=mix
         restore,dirma+'cat_maestro_v1.2.'+syr
         restore,dirma+'vo3_maestro_v1.2.'+syr
         datemaestro_all=date
         ymaestro_all=latitude
         xmaestro_all=longitude
         o3maestro_all=mix
      endif
;
; extract today from SOSST data
;
      index=where(datesage2_all eq long(syr+smn+sdy) and ysage2_all gt 10.,norbits2)
      if index(0) ne -1L then begin
         ysage2=ysage2_all(index)
         xsage2=xsage2_all(index)
         o3sage2=o3sage2_all(index,*)
      endif
      index=where(datesage3_all eq long(syr+smn+sdy) and ysage3_all gt 10.,norbits3)
      if index(0) ne -1L then begin
         ysage3=ysage3_all(index)
         xsage3=xsage3_all(index)
         o3sage3=o3sage3_all(index,*)
      endif
      index=where(datehal_all eq long(syr+smn+sdy) and yhal_all gt 10.,norbith)
      if index(0) ne -1L then begin
         yhal=yhal_all(index)
         xhal=xhal_all(index)
         o3hal=o3hal_all(index,*)
      endif
      index=where(datepoam_all eq long(syr+smn+sdy) and ypoam_all gt 10.,norbitp)
      if index(0) ne -1L then begin
         ypoam=ypoam_all(index)
         xpoam=xpoam_all(index)
         o3poam=o3poam_all(index,*)
      endif
      index=where(dateace_all eq long(syr+smn+sdy) and yace_all gt 10.,norbita)
      if index(0) ne -1L then begin
         yace=yace_all(index)
         xace=xace_all(index)
         o3ace=o3ace_all(index,*)
      endif
      index=where(datemaestro_all eq long(syr+smn+sdy) and ymaestro_all gt 10.,norbitma)
      if index(0) ne -1L then begin
         ymaestro=ymaestro_all(index)
         xmaestro=xmaestro_all(index)
         o3maestro=o3maestro_all(index,*)
      endif
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
                 filename='polar_o3_mls+sosst_nh_'+lfile+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
      endif
;
; polar projection of MetO data at 1000 K
;
      rtheta=1000.
      index=where(rtheta eq th)
      itheta=index(0)
      stheta=strcompress(string(fix(th(itheta))),/remove_all)
      sf1=transpose(sf2(*,*,itheta))
      mark1=transpose(mark2(*,*,itheta))
      sf=fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1
      sf(nc,*)=sf(0,*)
      mark=fltarr(nc+1,nr)
      mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
      mark(nc,*)=mark(0,*)
;
; zero out non-pacific anticyclones
;
index=where(x2d lt 45. or x2d gt 270. and mark lt 0.)
if index(0) ne -1 then mark(index)=0.
;
; polar plot of ozone
;
      erase
      !type=2^2+2^3
      set_viewport,.15,.85,.15,.85
      MAP_SET,90,0,-180,/stereo,/contin,/grid,/noeras,color=lc,charsize=1.5,title=syr+smn+sdy
      oplot,findgen(361),0.1+0.*findgen(361),psym=0,color=0
      contour,sf,x,alat,nlevels=30,c_color=lc,/overplot,/follow,c_labels=0,/noeras
      index=where(mark gt 0.05 and y2d gt 0.)
      if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=2,color=lc
      index=where(mark lt -0.05 and y2d gt 0.)
      if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=4,color=lc
      a=findgen(8)*(2*!pi/8.)
      usersym,cos(a),sin(a),/fill
      index=where(mtheta2 gt rtheta-80. and mtheta2 le rtheta+80. and mlat2 gt 0.,npt)
      if index(0) eq -1L then goto,jump
      xdata=mlon2(index) & ydata=mlat2(index)
      o3data=mo3(index)
      o3mask=mo3mask(index)
      o3mark=mmark2(index)
      index=where(xdata lt 0.)
      if index(0) ne -1 then xdata(index)=xdata(index)+360.
      omin=2.0
      omax=10.
      for i=0L,n_elements(o3data)-1L do begin
          if o3mask(i) ne -99. then $
             oplot,[xdata(i),xdata(i)],[ydata(i),ydata(i)],psym=8,$
                   color=((o3data(i)-omin)/(omax-omin))*mcolor,symsize=2
      endfor
      loadct,0
      contour,mark,x,alat,levels=[.05],c_color=mcolor*.7,/overplot,/follow,c_labels=0,/noeras,thick=10
      loadct,38
      contour,mark,x,alat,levels=[-.05],c_color=0,/overplot,/follow,c_labels=0,/noeras,thick=10
;
; superimpose SOSST observations
;
      zindex=where(altitude eq 40.)
      if norbits2 gt 0L then begin
         for i=0L,norbits2-1L do $
             oplot,[xsage2(i),xsage2(i)],[ysage2(i),ysage2(i)],psym=8,symsize=3,$
                   color=0	;((o3sage2(i,zindex(0))-omin)/(omax-omin))*mcolor
      endif
      if norbits3 gt 0L then begin
         for i=0L,norbits3-1L do $
             oplot,[xsage3(i),xsage3(i)],[ysage3(i),ysage3(i)],psym=8,symsize=3,$
                   color=0	;((o3sage3(i,zindex(0))-omin)/(omax-omin))*mcolor
      endif
      if norbith gt 0L then begin
         for i=0L,norbith-1L do $
             oplot,[xhal(i),xhal(i)],[yhal(i),yhal(i)],psym=8,symsize=3,$
                   color=0	;((o3hal(i,zindex(0))-omin)/(omax-omin))*mcolor
      endif
      if norbitp gt 0L then begin
         for i=0L,norbitp-1L do $
             oplot,[xpoam(i),xpoam(i)],[ypoam(i),ypoam(i)],psym=8,symsize=3,$
                   color=0	;((o3poam(i,zindex(0))-omin)/(omax-omin))*mcolor
      endif
      if norbita gt 0L then begin
         for i=0L,norbita-1L do $
             oplot,[xace(i),xace(i)],[yace(i),yace(i)],psym=8,symsize=3,$
                   color=0	;((o3ace(i,zindex(0))-omin)/(omax-omin))*mcolor
      endif
;     if norbitma gt 0L then begin
;        for i=0L,norbitma-1L do $
;            oplot,[xmaestro(i),xmaestro(i)],[ymaestro(i),ymaestro(i)],psym=8,symsize=3,$
;                  color=0	;((o3maestro(i,zindex(0))-omin)/(omax-omin))*mcolor
;     endif
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a)
      if norbits2 gt 0L then oplot,xsage2,ysage2,psym=8,symsize=2,color=0
      if norbits3 gt 0L then oplot,xsage3,ysage3,psym=8,symsize=2,color=0
      if norbith gt 0L then oplot,xhal,yhal,psym=8,symsize=2,color=0
      if norbitp gt 0L then oplot,xpoam,ypoam,psym=8,symsize=2,color=0
      if norbita gt 0L then oplot,xace,yace,psym=8,symsize=2,color=0
      if norbitma gt 0L then oplot,xmaestro,ymaestro,psym=8,symsize=2,color=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
;
; determine number of NH swaths and print time of swaths on polar plot
;
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
;            oplot,mlon(kindex),mlat(kindex),psym=8,symsize=1.25,color=(float(i+1)/float(npt))*mcolor
             stime=string(FORMAT='(I2.2)',long(tswath(index(0))))
             tsave(mcount)=tswath(index(0))
             mcount=mcount+1L
             xtmp=mlon(kindex)
             ytmp=mlat(kindex)
             index=where(ytmp eq min(ytmp))
;            xyouts,xtmp(index(0)),30.,stime,/data,charsize=1.5,alignment=0.5,color=0,charthick=3
          endif
      endfor
      tsave=tsave(0:mcount-1L)
      MAP_SET,90,0,-180,/stereo,/contin,/grid,/noeras,color=0,charsize=1.5
      imin=omin
      imax=omax
      ymnb=0.15-cbaryoff
      ymxb=ymnb  +cbarydel
      set_viewport,.15,.85,ymnb,ymxb
      nlvls=20L
      col1=1+indgen(nlvls)*mcolor/(float(nlvls))
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],xtitle='Ozone (ppmv)',color=0
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
            xbox=[x1,x1,x1+dx,x1+dx,x1]
            polyfill,xbox,ybox,color=col1(j)
            x1=x1+dx
      endfor
      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device, /close
         spawn,'convert -trim polar_o3_mls+sosst_nh_'+lfile+'.ps -rotate -90 '+$
               ' polar_o3_mls+sosst_nh_'+lfile+'.jpg'
      endif
      icount=icount+1L
goto,jump
end
