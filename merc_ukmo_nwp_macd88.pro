;
; read new Met Office "nwp" netCDF pressure files
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nwp
;
; choose rainbow color table
;
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2
nlvls=31L
col1=1+indgen(nlvls)*icmm1/nlvls
!noeras=1
device,decompose=0
;
; define viewport location 
;
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.25]
xlen=0.7
ylen=0.5
cbaryoff=0.03
cbarydel=0.02
!NOERAS=-1
;
; enter "x" to plot to a window or "ps" to a postscript file for printing
;
setplot='x'
read,'setplot ',setplot
if setplot ne 'ps' then $
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
;
; Ask interactive questions- get starting/ending dates
;
lstmn=6 & lstdy=13 & lstyr=2011
ledmn=6 & leddy=13 & ledyr=2011
lstday=0 & ledday=0
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr ge 91 and lstyr le 99 then lstyr=lstyr+1900
if ledyr ge 91 and ledyr le 99 then ledyr=ledyr+1900
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
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
;
; loop over days
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      syr=strtrim(iyr,2)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      date=syr+smn+sdy
;
; build Met Office filename and read netCDF data
;
      file='/Volumes/earth/harvey/UKMO_data/Datfiles/ukmo-nwp-strat_gbl-std_'+$
            string(FORMAT='(i4,i2.2,i2.2,a22)',iyr,imn,idy,'12_u-v-gph-t-w_uars.nc')
      rd_ukmo_nwp,file,nc,nr,nc1,nr1,nlv,wlon,alon,wlat,alat,p,z3d,t3d,u3d,v3d,iflg
      print,'read Met Office data on '+date
      print,' '
;
; extract pressure level for plotting
;
      plev=0.
      print,p
      read,'Enter desired pressure level ',plev
      index=where(p eq plev)
      ilev=index(0)
      slev=string(FORMAT='(f6.1)',p(ilev))
      tl=reform(t3d(*,*,ilev))
;
; set postscript file if necessary
;
      if setplot eq 'ps' then begin
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !psym=0
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,filename='merc_ukmo_nwp_'+date+'_'+strcompress(slev,/remove_all)+'hPa.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
      endif
;
; add wrap-around point in longitude for contouring
;
      tl1=fltarr(nc+1L,nr1)
      tl1(0L:nc-1L,0L:nr1-1L)=tl
      for j=0L,nr1-1L do tl1(nc,j)=tl1(0,j)
      alon1=fltarr(nc+1L)
      alon1(0L:nc-1L)=alon
      alon1(nc)=alon1(0)
;
; plot mercator projection of temperature
; 
      erase
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      MAP_SET,0,0,0,/GRID,/CONTIN,/noeras,title=date+' MetO Temperature at'+slev+' hPa',charsize=1.5
      level=180.+4.*findgen(nlvls)
      contour,tl1,alon1,alat,levels=level,/overplot,/cell_fill,c_color=col1
      contour,tl1,alon1,alat,levels=level,/overplot,/follow,c_color=0
      MAP_SET,0,0,0,/GRID,/CONTIN,/noeras,color=icolmax
;
; add color bar
;
      imin=min(level)
      imax=max(level)
      ymnb=yorig(0) -cbaryoff
      ymxb=ymnb  +cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax]
      ybox=[0,10,10,0,0]
      x1=imin
      dx=(imax-imin)/float(nlvls)
      for j=0L,nlvls-1L do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor
      if setplot ne 'ps' then stop
      if setplot eq 'ps' then begin
         device,/close
         spawn,'convert -trim merc_ukmo_nwp_'+date+'_'+strcompress(slev,/remove_all)+'hPa.ps '+$
               '-rotate -90 merc_ukmo_nwp_'+date+'_'+strcompress(slev,/remove_all)+'hPa.jpg'
      endif
goto,jump
end
