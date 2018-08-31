;
; add Chicago
; Lower Stratosphere (LS)
; reads in .nc3 and plots polar projection of PV and the vortex edge at 800 K
; plus isotachs at 340 K in the upper troposphere
;
@stddat
@kgmt
@ckday
@kdate
@rd_merra_nc3

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
nxdim=800
nydim=800
xorig=[0.1,0.4,0.7]
yorig=[0.4,0.4,0.4]
xlen=0.3
ylen=0.3
cbaryoff=0.02
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
lstmn=1L & lstdy=21L & lstyr=14L
ledmn=1L & leddy=27L & ledyr=14L
lstday=0L & ledday=0L
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1979 then stop,'Year out of range '
if ledyr lt 1979 then stop,'Year out of range '
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
kcount=0L

; --- Loop here --------
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' normal termination condition '

      if iyr ge 2000 then iyr1=iyr-2000
      if iyr lt 2000 then iyr1=iyr-1900
      uyr=string(FORMAT='(I2.2)',iyr1)
      syr=string(FORMAT='(I4.4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      print,sdate
      if sdate ne '20140121' and sdate ne '20140124' and sdate ne '20140127' then goto,jump
      ifile=mon(imn-1)+sdy+'_'+uyr
;
; read MERRA data
;
    dum=findfile(dir+sdate+'.nc3')
    if dum ne '' then ncfile0=dir+sdate+'.nc3'
    rd_merra_nc3,ncfile0,nc,nr,nth,alon,alat,th,pv2,p2,$
       u2,v2,qdf2,mark2,qv2,z2,sf2,q2,iflag

;     rd_ukmo_nc3,dir+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
;             pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
      if icount eq 0 then begin
         theta=800.
;        print,th
;        read,'Enter theta ',theta
         index=where(theta eq th)
         if index(0) eq -1 then stop,'Invalid theta level '
         thlev=index(0)
         icount=1
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
;        !p.font=0
         device,font_size=9
         device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
                /bold,/color,bits_per_pixel=8,/times,filename='merra_PV_LS+chicago.ps'
         !p.charsize=1.25
         !p.thick=2
         !p.charthick=5
         !y.thick=2
         !x.thick=2
      endif
      erase
      endif
      theta=th(thlev)
      stheta=strcompress(string(fix(theta)),/remove_all)
      qdf1=transpose(qdf2(*,*,thlev))
      sf1=transpose(sf2(*,*,thlev))
      pv1=transpose(pv2(*,*,thlev))
      u1=transpose(u2(*,*,-1))
      v1=transpose(v2(*,*,-1))	; wind speed at 340 K
      p1=transpose(p2(*,*,-1))	; wind speed at 340 K
temp=th(-1)*(p1/1000.)^.286
height=transpose(z2(*,*,-1))
;stop
      sp1=sqrt(u1^2.+v1^2.)
      mark1=transpose(mark2(*,*,thlev))
      qdf=0.*fltarr(nc+1,nr)
      qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
      qdf(nc,*)=qdf(0,*)
      sf=0.*fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
      sf(nc,*)=sf(0,*)
      sp=0.*fltarr(nc+1,nr)
      sp(0:nc-1,0:nr-1)=sp1(0:nc-1,0:nr-1)
      sp(nc,*)=sp(0,*)
      pv=0.*fltarr(nc+1,nr)
      pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
      pv(nc,*)=pv(0,*)
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

      !psym=0
      !type=2^2+2^3
      !p.charthick=2
      xmn=xorig(kcount)
      xmx=xorig(kcount)+xlen
      ymn=yorig(kcount)
      ymx=yorig(kcount)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,/noborder,$
              title=sdate,charsize=2.0,latdel=10,color=0,limit=[0.,0.,90.,360.]
      oplot,findgen(361),0.1+0.*findgen(361),color=0
      index=where(lat gt 0.)
      imin=0.
;     imax=max(pv(index))
      imax=0.0008
      nlvls=20
      pvint=(imax-imin)/float(nlvls)
      level=imin+pvint*findgen(nlvls)
;print,level
loadct,39
      col1=1+indgen(nlvls)*icolmax/float(nlvls)
      contour,pv,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
      contour,pv,x,alat,/overplot,levels=level,/follow,$
              c_labels=0*level,/noeras,color=0
;
loadct,8
      contour,sp,x,alat,/overplot,levels=[35.],thick=10,color=.65*mcolor
      contour,sp,x,alat,/overplot,levels=[45.],thick=10,color=.75*mcolor
      contour,sp,x,alat,/overplot,levels=[55.],thick=10,color=0
      MAP_SET,90,0,-90,/ortho,/noeras,/grid,/contin,/noborder,$
             charsize=2.0,latdel=10,color=0,limit=[0.,0.,90.,360.]
;
; superimpose Chicago (41.9N, 272.4E)
;
loadct,0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
      yy=41.9 & xx=272.4
      oplot,[xx,xx],[yy,yy],psym=8,color=mcolor*.8,symsize=3
loadct,39
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a)
      oplot,[xx,xx],[yy,yy],psym=8,color=0,symsize=3
;
      if kcount eq 1 then begin
      ymnb=ymn -cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      imax=imax*1.e6
      plot,[imin,imax],[0,0],yrange=[0,10],$
            xrange=[imin,imax],xtitle=stheta+' K (30 km, 10 hPa) PV (PVU)',/noeras,$
            charsize=1.5,color=0,charthick=2
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(nlvls)
      for j=0,nlvls-1 do begin
        xbox=[x1,x1,x1+dx,x1+dx,x1]
        polyfill,xbox,ybox,color=col1(j)
        x1=x1+dx
      endfor
      endif

kcount=kcount+1
goto,jump
      if setplot eq 'ps' then begin
         device, /close
         spawn,'convert -trim merra_PV_LS+chicago.ps -rotate -90 merra_PV_LS+chicago.png'
      endif
end
