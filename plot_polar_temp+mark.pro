;
; plot NH polar projection of Met Office temperature on a theta surface.
; also plot the position of the Arctic vortex and NH anticyclones 
;
; VLH 7/27/2006: CU/LASP
;
@rd_ukmo_nc3
@stddat
@kgmt
@ckday
@kdate
;
; define user symbol
;
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
;
; load color table
;
loadct,38
icolmax=byte(!p.color)		; icolmax=white
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
;
; comment this out if not necessary.  I need this 
; on my Sun workstation to get the colors right
;
device,decompose=0
;
; choose screen or postscript plotting
;
setplot='x'
read,'Enter x to plot to the screen, ps for postscript file ',setplot
;
; set viewport size and frame dimensions
;
nxdim=700 & nydim=700
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.03
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   !p.background=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
;
; directory from which to read the Met Office data
; note: you need to edit this for your purposes
;
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
;
; date variables
;
lstmn=1 & lstdy=1 & lstyr=3 & lstday=0
ledmn=1 & leddy=31 & ledyr=3 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
print, ' '
print, '      Met Office Version '
print, ' '
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
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
; test for end condition 
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '
;
; build date and data filename
;
      syr=strtrim(string(iyr),2)	; 4-digit year
      uyr=strmid(syr,2,2)		; 2-digit year
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
      ifile=mon(imn-1)+sdy+'_'+uyr
;
; read Met Office data
;
      rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
;
; select theta surface
;
      if icount eq 0L then begin
         theta=700.
         print,th
         read,'Enter theta ',theta
         index=where(theta eq th)
         if index(0) eq -1 then stop,'Invalid theta level '
         thlev=index(0)
         stheta=strcompress(string(fix(theta)),/remove_all)
      endif
      sf1=transpose(sf2(*,*,thlev))
      msf1=transpose(msf2(*,*,thlev))
      pv1=transpose(pv2(*,*,thlev))
      p1=transpose(p2(*,*,thlev))
      mark1=transpose(mark2(*,*,thlev))
      t1=theta*((p1/1000.)^(.286))
      z1=(msf1-1004.*t1)/(9.86*1000.)
;
; add "wrap-around" longitude point for plotting
;
      sf=0.*fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
      sf(nc,*)=sf(0,*)
      pv=0.*fltarr(nc+1,nr)
      pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
      pv(nc,*)=pv(0,*)
      t=0.*fltarr(nc+1,nr)
      t(0:nc-1,0:nr-1)=t1(0:nc-1,0:nr-1)
      t(nc,*)=t(0,*)
      mark=0.*fltarr(nc+1,nr)
      mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
      mark(nc,*)=mark(0,*)
      x=fltarr(nc+1)
      x(0:nc-1)=alon
      x(nc)=alon(0)+360.
      lon=0.*sf
      lat=0.*sf
      for i=0,nc   do lat(i,*)=alat
      for j=0,nr-1 do lon(*,j)=x
;
; for postscript file
;
      if setplot eq 'ps' then begin
         lc=0
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,filename='polar_temp+mark_'+sdate+'_'+stheta+'K.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
      endif
;
; Set plot boundaries
;
      erase
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
;
; retain same contour levels throughout plotting.  set on first day only.
;
      if icount eq 0L then begin
         nlvls=20
         col1=1+indgen(nlvls)*icolmax/nlvls
         index=where(lat gt 0.)
         tmin=min(t(index))-10.
         tmax=max(t(index))+10.
         tint=(tmax-tmin)/(nlvls-1)
         tlevel=tmin+tint*findgen(nlvls)
      endif
      MAP_SET,90,0,0,/stereo,/grid,/contin,/noborder,/noeras,charsize=1.5,$
              title='Met Office Temperature on '+sdate+' at '+stheta+' K',color=0
      oplot,findgen(361),0.1+0.*findgen(361),psym=0,thick=2,color=0
      contour,t,x,alat,levels=tlevel,c_color=col1,/cell_fill,/overplot,/noeras
      contour,t,x,alat,/overplot,levels=tlevel,c_color=0,c_labels=0*tlevel,/follow,/noeras
      contour,t,x,alat,/overplot,levels=180.+5.*findgen(5),/follow,$
              c_color=icolmax,thick=2,/noeras,c_labels=1+0*findgen(11)
      MAP_SET,90,0,0,/stereo,/noeras,/contin,/noborder,color=0
      contour,mark,x,alat,levels=[0.1],color=0,thick=5,/overplot
      index=where(lat gt 0. and mark gt 0.)
      if index(0) ne -1 then oplot,lon(index),lat(index),psym=1,color=0,symsize=0.8
      contour,mark,x,alat,levels=[-0.1],color=icolmax,thick=5,/overplot
      index=where(lat gt 0. and mark lt 0.)
      if index(0) ne -1 then oplot,lon(index),lat(index),psym=1,color=icolmax,symsize=0.8
;
; horizontal temperature color bar
;
      ymnb=yorig(0)-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[min(tlevel),max(tlevel)],[0,0],yrange=[0,10],color=0,$
           xrange=[min(tlevel),max(tlevel)],charsize=1.5,xtitle='(K)'
      ybox=[0,10,10,0,0]
      x1=min(tlevel)
      dx=(max(tlevel)-min(tlevel))/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor
;
; stop if plotting to the screen
;
      if setplot eq 'x' then stop
;
; create jpg image from postscript file
;
      if setplot eq 'ps' then begin
         device, /close
         spawn,'convert -trim -rotate -90 polar_temp+mark_'+sdate+'_'+stheta+'K.ps '+$
               'polar_temp+mark_'+sdate+'_'+stheta+'K.jpg'
      endif
      icount=icount+1L
goto,jump
end
