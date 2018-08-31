;
; mercator MLS gridded H2O plus MERRA for interpretation
;
@stddat
@kgmt
@ckday
@kdate
@rd_merra_nc3

sver='v3.3'

loadct,39
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
nxdim=700
nydim=700
xorig=[0.1]
yorig=[0.2]
xlen=0.8
ylen=0.6
cbaryoff=0.1
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
!noeras=1
dirm='/atmos/aura6/data/MLS_data/Datfiles_SOSST/'
dirm='/atmos/aura6/data/MLS_data/Datfiles_Grid/MLS_grid5_ALL_v3.3_'
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
lstmn=6L & lstdy=1L & lstyr=2009L
ledmn=8L & leddy=30L & ledyr=2009L
lstday=0L & ledday=0L
;
; get date range
;
print, ' '
print, '      MERRA Version '
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
print,sdate
;
; read MLS data
;
      dum=findfile(dirm+sdate+'.sav')
      if dum(0) eq '' then begin
         mprof=0L
         goto,jumpmerra
      endif
      restore,dirm+sdate+'.sav'

      plev=0.00464159        ; 81 km
      slev=string(FORMAT='(f5.3)',plev)
      index=where(abs(pmls2-plev) eq min(abs(pmls2-plev)))
      ilev=index(0)
nc=n_elements(lon)
nr=n_elements(lat)
      xlon=fltarr(nc+1)
      xlon(0:nc-1)=lon(0:nc-1)
      xlon(nc)=xlon(0)+360.

      h2o1=reform(h2o_grid(*,*,ilev))*1.e6
      h2o=fltarr(nc+1,nr)
      h2o(0:nc-1,*)=h2o1(0:nc-1,*)
      h2o(nc,*)=h2o(0,*)
      z1=reform(GP_GRID(*,*,ilev))/1000.
      mtemp=reform(TP_GRID(*,*,ilev))
      mtheta=mtemp*(1000./plev)^0.286
      thmean=mean(mtheta)
;
; read MERRA data
;
jumpmerra:
    ncfile0=dir+sdate+'.nc3'
    rd_merra_nc3,ncfile0,nc,nr,nth,alon,alat,th,pv2,p2,$
       u2,v2,qdf2,mark2,qv2,z2,sf2,q2,iflag
      if iflag eq 1 then goto,jump
    ncid=ncdf_open(dir+sdate+'.nc4')
    marknew2=fltarr(nr,nc,nth)
    ncdf_varget,ncid,3,marknew2
    ncdf_close,ncid

      x=fltarr(nc+1)
      x(0:nc-1)=alon(0:nc-1)
      x(nc)=alon(0)+360.
      x2d=fltarr(nc+1,nr)
      y2d=fltarr(nc+1,nr)
      for k=0,nr-1 do x2d(*,k)=x
      for j=0,nc do y2d(j,*)=alat
;
; select theta level to plot
;
      if icount eq 0 then begin
         zindex=where(abs(th-thmean) eq min(abs(th-thmean)))
         ilev2=zindex(0)+1L	; 5000 is discontinuous
print,th(ilev2),' K'
      endif
      speed2=sqrt(u2^2.+v2^2.)
      mark1=transpose(mark2(*,*,ilev2))
      marknew1=transpose(marknew2(*,*,ilev2))
      sf1=transpose(sf2(*,*,ilev2))
      pv1=transpose(pv2(*,*,ilev2))
      p1=transpose(p2(*,*,ilev2))
      q1=transpose(q2(*,*,ilev2))
      u1=transpose(u2(*,*,ilev2))
      speed1=transpose(speed2(*,*,ilev2))
      mark=fltarr(nc+1,nr)
      mark(0:nc-1,0:nr-1)=mark1
      mark(nc,*)=mark(0,*)
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
      temp=th(ilev2)*((p/1000.)^(.286))
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
         device,/landscape,bits=8,filename='merc_mls_h2o+merra_'+sdate+'_'+slev+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.thick=2.0                   ;Plotted lines twice as thick
      endif
;
; Isotachs + vortex edge
;
      erase
      !type=2^2+2^3
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      level=0.25*findgen(20)
      nlvls=n_elements(level)
      col1=1+indgen(nlvls)*mcolor/nlvls
      contour,h2o,xlon,lat,levels=level,c_color=col1,/cell_fill,/noeras,color=0,title=sdate+' MERRA Streamfunction',charsize=1.5,yticks=6,$
              xticks=6,ytitle='Latitude',xtitle='Longitude',ytickname=['-90','-60','-30','0','30','60','90']	;ytickformat='(i3)'
      sflevel=min(sf)+((max(sf)-min(sf))/float(nlvls))*findgen(nlvls)
      contour,sf,x,alat,/overplot,levels=sflevel,color=0,/foll,/noeras,thick=2,c_labels=0*sflevel
      contour,mark,x,alat,/overplot,levels=[0.1],color=0,thick=10,/noeras,/follow
loadct,0
      contour,marknew,x,alat,/overplot,levels=[-0.1],color=150,thick=10,/noeras,/follow
loadct,39
      map_set,0,180,0,/contin,/grid,color=0,/noeras

imin=min(level)
imax=max(level)
ymnb=yorig(0) -cbaryoff
ymxb=ymnb  +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],color=0,xtitle='MLS '+slev+' H!l2!nO (ppmv)',/noeras,charthick=2,charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlvls)
for j=0,nlvls-1 do begin
xbox=[x1,x1,x1+dx,x1+dx,x1]
polyfill,xbox,ybox,color=col1(j)
x1=x1+dx
endfor
;
      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device,/close
         spawn,'convert -trim merc_mls_h2o+merra_'+sdate+'_'+slev+'.ps -rotate -90 '+$
               'merc_mls_h2o+merra_'+sdate+'_'+slev+'.jpg'
      endif
      icount=icount+1L
goto,jump
end
