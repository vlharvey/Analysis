;
; GEOS-5 version
; plot polar PV
;
@stddat
@kgmt
@ckday
@kdate
@rd_geos5_dat_origp

loadct,39
device,decompose=0
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
!noeras=1
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.15]
xlen=0.7
ylen=0.7
cbaryoff=0.01
cbarydel=0.01
setplot='x'
read,'setplot=',setplot
if setplot ne 'ps' then begin
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=icolmax
endif
dir='/aura7/harvey/GEOS5_data/Datfiles/'
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
lstmn=1
lstdy=15
lstyr=2008
ledmn=3
leddy=15
ledyr=2008
lstday=0
ledday=0
;goto,plotit
;
; Ask interactive questions- get starting/ending date and p surface
;
;print, ' '
;print, '      GEOS-5 Version '
;print, ' '
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
;
; Compute initial Julian date
;
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
      if ndays gt ledday then stop
      if iyr ge 2000L then iyr1=iyr-2000L
      if iyr lt 2000L then iyr1=iyr-1900L
;
;***Read GEOS-5 data
;
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      ifile='DAS.ops.asm.tavg3d_dyn_v.GEOS510.MetO.'+sdate+'_1200.V01.dat'
      rd_geos5_dat_origp,dir+ifile,iflg,nc,nr,nlv,alon,alat,height,p3d,g3d,t3d,u3d,v3d,q3d,pv3d
      if iflg ne 0 then goto, jump
      zp=g3d/1000.
      altitude=height
      x=fltarr(nc+1)
      x(0:nc-1)=alon
      x(nc)=x(0)
      y2d=fltarr(nc+1,nr)
      for i=0,nc do y2d(i,*)=alat
;
; loop over altitude
;
      for j=0L,nlv-1L do begin
          salt=strcompress(string(format='(f5.1)',height(j)),/remove_all)

          if setplot eq 'ps' then begin
             set_plot,'ps'
             xsize=nxdim/100.
             ysize=nydim/100.
             !psym=0
             !p.font=0
             device,font_size=9
             device,/landscape,bits=8,filename='polar_pv_press_geos5_'+salt+'.ps'
             device,/color
             device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                    xsize=xsize,ysize=ysize
             !p.thick=2.0                   ;Plotted lines twice as thick
             !p.charsize=1.0
          endif
;
; plot PV
;
          pv1=reform(pv3d(*,*,j))
          pv=0.*fltarr(nc+1,nr)
          pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
          pv(nc,*)=pv(0,*)
          u1=reform(u3d(*,*,j))
          u=0.*fltarr(nc+1,nr)
          u(0:nc-1,0:nr-1)=u1(0:nc-1,0:nr-1)
          u(nc,*)=u(0,*)
          erase
          xmn=xorig(0)
          xmx=xorig(0)+xlen
          ymn=yorig(0)
          ymx=yorig(0)+ylen
          set_viewport,xmn,xmx,ymn,ymx
          !type=2^2+2^3
          MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,title='PV '+sdate+' '+salt+' km',color=0
          index=where(y2d gt 0.)
          imin=min(pv(index))
          imax=max(pv(index))
          nlvls=20
          iint=(imax-imin)/float(nlvls)
          level=imin+iint*findgen(nlvls)
          nlvls=n_elements(level)
          col1=indgen(nlvls)*icolmax/(nlvls-1)
          contour,pv,x,alat,/overplot,levels=level,c_color=col1,/cell_fill,/noeras
          contour,pv,x,alat,/overplot,levels=[0.],c_color=0,thick=2,/follow,/noeras
          contour,u,x,alat,/overplot,levels=-100.+20.*findgen(5),color=0,c_linestyle=5,thick=3
          contour,u,x,alat,/overplot,levels=20.+20.*findgen(9),color=mcolor,thick=3
          MAP_SET,90,0,-90,/stereo,/noeras,/grid,/contin,color=0
          ymnb=yorig(0) -cbaryoff
          ymxb=ymnb  +cbarydel
          set_viewport,xmn,xmx,ymnb,ymxb
          !type=2^2+2^3+2^6
          plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0
          ybox=[0,10,10,0,0]
          x1=imin
          dx=(imax-imin)/float(nlvls)
          for jj=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(jj)
          x1=x1+dx
          endfor

          if setplot ne 'ps' then stop
          if setplot eq 'ps' then begin
             device, /close
             spawn,'convert -trim polar_pv_press_geos5_'+salt+'.ps -rotate -90 polar_pv_press_geos5_'+salt+'.jpg'
          endif
      endfor	; loop over altitude
goto,jump
end
