;
; reads in .nc3 and plots mercator projection
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc3

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,39
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='ps'
read,'setplot=',setplot
nxdim=500
nydim=500
xorig=[0.15]
yorig=[0.4]
xlen=0.7
ylen=0.5
cbaryoff=0.155
cbarydel=0.02
!NOERAS=-1
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
nmon=['01','02','03','04','05','06','07','08','09','10','11','12']
lstmn=1L & lstdy=1L & lstyr=9L
ledmn=2L & leddy=20L & ledyr=9L
lstday=0L & ledday=0L
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 then stop,'Year out of range '
if ledyr lt 1991 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
icount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal Termination Condition '

      if iyr ge 2000 then iyr1=iyr-2000
      if iyr lt 2000 then iyr1=iyr-1900
      uyr=string(FORMAT='(I2.2)',iyr1)
      syr=string(FORMAT='(I4.4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      date=syr+smn+sdy
      print,date
      ifile=mon(imn-1)+sdy+'_'+uyr
;
; read MetO data
;
      rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
              pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
      if icount eq 0 then begin
         theta=600.
;        print,th
;        read,'Enter theta ',theta
         index=where(theta eq th)
         if index(0) eq -1 then stop,'Invalid theta level '
         thlev=index(0)
         icount=1
      endif

      theta=th(thlev)
      stheta=strcompress(string(fix(theta)),/remove_all)
      qdf1=transpose(qdf2(*,*,thlev))
      sf1=transpose(sf2(*,*,thlev))
      pv1=transpose(pv2(*,*,thlev))*1.e2	; correct units
      mark1=transpose(mark2(*,*,thlev))
      qdf=0.*fltarr(nc+1,nr)
      qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
      qdf(nc,*)=qdf(0,*)
      sf=0.*fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
      sf(nc,*)=sf(0,*)
      pv=0.*fltarr(nc+1,nr)
      pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
      pv(nc,*)=pv(0,*)
pv(*,nr-1)=0./0.
;pv(*,nr-2)=0./0.
;pv(*,nr-3)=0./0.
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

      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         set_plot,'ps'
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                /bold,/color,bits_per_pixel=8,/helvetica,filename='merc_pv+mark_'+date+'_'+stheta+'K.ps'
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !p.charthick=5
         !y.thick=2
         !x.thick=2
      endif
      erase
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
;     MAP_SET,0,0,0,/noeras,/grid,/contin,title=date,color=0,limit=[40.,-180.,max(alat),180.],$
;             label=1,lonlab=40.,latlab=-180,latdel=10.
;     oplot,findgen(361),0.1+0.*findgen(361)
      index=where(lat gt 0.)
      pvmin=min(pv(index))
      pvmax=max(pv(index))
      nlvls=20
      pvint=(pvmax-pvmin)/nlvls
      pvlevel=pvmin+pvint*findgen(nlvls)
      col1=1+indgen(nlvls)*icolmax/float(nlvls)
      contour,pv,x,alat,levels=pvlevel,c_color=col1,/cell_fill,/noeras,title=date,$
              xtitle='Longitude',ytitle='Latitude',color=0,$
              yticks=4,xticks=6,yrange=[0.,90.],xrange=[-180.,180.]
      contour,pv,x-360.,alat,levels=pvlevel,c_color=col1,/cell_fill,/noeras,/overplot
      contour,pv,x,alat,/overplot,levels=pvlevel,/follow,c_labels=0*pvlevel,/noeras,color=0
      contour,pv,x-360.,alat,/overplot,levels=pvlevel,/follow,c_labels=0*pvlevel,/noeras,color=0
      contour,mark,x,alat,/overplot,levels=[0.1],thick=10,color=0
      contour,mark,x-360.,alat,/overplot,levels=[0.1],/follow,c_labels=[1],/noeras,color=0,thick=10
      contour,mark,x,alat,/overplot,levels=[-0.1],thick=10,color=mcolor
      contour,mark,x-360.,alat,/overplot,levels=[-0.1],/follow,c_labels=[1],/noeras,color=mcolor,thick=10
      contour,pv,x,alat,/overplot,levels=[0],/follow,c_labels=[1],/noeras,color=mcolor*.9,thick=3
      contour,pv,x-360.,alat,/overplot,levels=[0],/follow,c_labels=[1],/noeras,color=mcolor*.9,thick=3
;     MAP_SET,0,0,0,/noeras,/grid,/contin,color=0,limit=[0.,-180.,max(alat),180.],$
;             label=1,lonlab=40.,latlab=-180,latdel=10.
      imin=min(pvlevel)
      imax=max(pvlevel)
      ymnb=yorig(0)-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xorig(0),xorig(0)+xlen,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,$
           xtitle='MetO '+stheta+' K Potential Vorticity (Km!u2!nkg!u-1!ns!u-1!n)'
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
         spawn,'convert -trim merc_pv+mark_'+date+'_'+stheta+'K.ps -rotate -90 merc_pv+mark_'+date+'_'+stheta+'K.jpg'
      endif
goto,jump
end
