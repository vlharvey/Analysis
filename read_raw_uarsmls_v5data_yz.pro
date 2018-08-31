;
; use subroutines provided by DAAC to read UARS MLS data v5 and v6 for HNO3
; plot zonal means to check data
;
@stddat
@kgmt
@ckday
@kdate
@aura2date

setplot='x'
read,'setplot?',setplot
loadct,38
mcolor=byte(!p.color)
mcolor=fix(mcolor)
device,decompose=0
if mcolor eq 0 then mcolor=255
nlvls=20
col1=1+mcolor*findgen(20)/nlvls
icmm1=mcolor-1
icmm2=mcolor-2
!noeras=1
a=findgen(6)*(2*!pi/6.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.15,0.55,0.15,0.55]
yorig=[0.6,0.6,0.15,0.15]
xlen=0.3
ylen=0.3
cbaryoff=0.08
cbarydel=0.01
if setplot ne 'ps' then begin
   lc=0
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
dy=2.5
mnr=long((180./dy) +1.0)
latbin=-90.+dy*findgen(mnr)
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
dirm='/aura6/data/MLS_data/Datfiles/'
;
; user enters date
;
lstmn=1L & lstdy=1L & lstyr=94L
ledmn=1L & leddy=1L & ledyr=94L
lstday=0L & ledday=0L
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 91 then lstyr=lstyr+2000
if ledyr lt 91 then ledyr=ledyr+2000
if lstyr lt 1900 then lstyr=lstyr+1900
if ledyr lt 1900 then ledyr=ledyr+1900
if lstyr lt 1991 or lstyr gt 2011 then stop,'Year out of range '
if ledyr lt 1991 or ledyr gt 2011 then stop,'Year out of range '
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
      z = stddat(imn,idy,iyr,ndays)
      if ndays gt ledday then stop,' Normal termination condition '
      syr=string(FORMAT='(I4.4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
;
; --- Calculate UARS day from (imn,idy,iyr) information.
;
      z = date2uars(imn,idy,iyr,uday)
      print,iyr,imn,idy,uday
      suday=string(FORMAT='(I4.4)',uday)
;
; look for 6 MLS data files on this day and jump day if any are missing
;
      dum=findfile(dirm+'MLS_L3*'+suday+'*PROD')
      result=size(dum)
      if result(1) lt 6L then goto,jump
;
; read version 5 UARS MLS data from Goddard DAAC
; The UARS pressure array is defined as:
; P = 1000 * 10^(-i/6) where i=0,1,2,... (indices of vertical dimension)
;
      pressall=10.0^(3-findgen(43)/6)	; all pressure levels
      dum=findfile(dirm+'MLS_L3AT_SCLO_D'+suday+'*PROD')
      infile=dum(0)
      read_3at, x, h, s, FILE = infile, SWAP = swap
      s = size(x[0].data) ; s[1] = size of vertical dimension for data
      pclo = pressall(x(0).INDEX_1ST_PT:x(0).INDEX_1ST_PT+s[1]-1L)
      clodata=x.data*1.e9
      cloprec=x.quality*1.e9
      nlevclo=s(1)

      dum='/aura6/data/MLS_data/Datfiles/MLS_L3AT_SGPH_D'+suday+'*PROD'
      infile=dum(0)
      read_3at, x, h, s, FILE = infile, SWAP = swap
      s = size(x[0].data)
      pgp = pressall(x(0).INDEX_1ST_PT:x(0).INDEX_1ST_PT+s[1]-1L)
      gpdata=x.data
      gpprec=x.quality
      nlevgp=s(1)

      dum='/aura6/data/MLS_data/Datfiles/MLS_L3AT_SHNO3_D'+suday+'*PROD'
      infile=dum(0)
      read_3at, x, h, s, FILE = infile, SWAP = swap
      s = size(x[0].data)
      phno3 = pressall(x(0).INDEX_1ST_PT:x(0).INDEX_1ST_PT+s[1]-1L)
      hno3data=x.data*1.e9
      hno3prec=x.quality*1.e9
      nlevhno3=s(1)

      dum='/aura6/data/MLS_data/Datfiles/MLS_L3AT_STEMP_D'+suday+'*PROD'
      infile=dum(0)
      read_3at, x, h, s, FILE = infile, SWAP = swap
      s = size(x[0].data)
      ptemp = pressall(x(0).INDEX_1ST_PT:x(0).INDEX_1ST_PT+s[1]-1L)
      tempdata=x.data
      tempprec=x.quality
      nlevtemp=s(1)

      dum='/aura6/data/MLS_data/Datfiles/MLS_L3AT_SO3_205_D'+suday+'*PROD'
      infile=dum(0)
      read_3at, x, h, s, FILE = infile, SWAP = swap
      mtime=24.*x.time(1)/86400000.
      mlat=x.lat
      mlon=x.lon
      s = size(x[0].data)
      Po3205 = pressall(x(0).INDEX_1ST_PT:x(0).INDEX_1ST_PT+s[1]-1L)
      o3205data = x.data*1.e6
      o3205prec = x.quality*1.e6
      nlevo3205=s(1)

;     dum='/aura6/data/MLS_data/Datfiles/MLS_L3AT_SO3_183_D'+suday+'*PROD'
;     infile=dum(0)
;     read_3at, x, h, s, FILE = infile, SWAP = swap
;     s = size(x[0].data)
;     Po3183 = 10.0^(3-findgen(s[1])/6)
;     o3183data = x.data*1.e6
;     o3183prec = x.quality*1.e6
;     nlevo3183=s(1)
;
; read quality and status flags
;
      dum='/aura6/data/MLS_data/Datfiles/MLS_L3TP_SPARAM_L3TP_D'+suday+'*PROD'
      infile=dum(0)
      read_3tp, x, h, s, FILE = infile, SWAP = swap
      cloqual=x.param.QUAL_CLO
      o3205qual=x.param.QUAL_O3_205
      hno3qual=x.param.QUAL_O3_205
      tempqual=x.param.QUAL_TEMP
      gpqual=x.param.QUAL_TEMP
      mmafstat=x.param.MMAF_STAT
;
; bin MLS data in latitude and calculate zonal means
;
      zmclo=fltarr(mnr,nlevclo)
      zmhno3=fltarr(mnr,nlevhno3)
      zmtemp=fltarr(mnr,nlevtemp)
      zmgp=fltarr(mnr,nlevgp)
      zmo3205=fltarr(mnr,nlevo3205)
      for j=0L,mnr-1L do begin
          for k=0L,nlevclo-1L do begin
              levdata=reform(clodata(k,*))
              levprec=reform(cloprec(k,*))
              index=where( (mmafstat eq 'G' or mmafstat eq 'T' or mmafstat eq 't') $
                            and cloqual eq 4. and levprec gt 0. and $
                            mlat ge latbin(j)-dy/2.0 and mlat lt latbin(j)+dy/2.0,npts)
              if index(0) ne -1L then zmclo(j,k)=total(levdata(index))/float(npts)
          endfor
          for k=0L,nlevhno3-1L do begin
              levdata=reform(hno3data(k,*))
              levprec=reform(hno3prec(k,*))
              index=where(  (mmafstat eq 'G' or mmafstat eq 'T' or mmafstat eq 't') $
                             and hno3qual eq 4. and levprec gt 0. and $
                             mlat ge latbin(j)-dy/2.0 and mlat lt latbin(j)+dy/2.0,npts)
              if index(0) ne -1L then zmhno3(j,k)=total(levdata(index))/float(npts)
          endfor
          for k=0L,nlevtemp-1L do begin
              levdata=reform(tempdata(k,*))
              levprec=reform(tempprec(k,*))
              index=where(  (mmafstat eq 'G' or mmafstat eq 'T' or mmafstat eq 't') $
                             and tempqual eq 4. and $	;levprec gt 0. and $
                             mlat ge latbin(j)-dy/2.0 and mlat lt latbin(j)+dy/2.0,npts)
              if index(0) ne -1L then zmtemp(j,k)=total(levdata(index))/float(npts)
          endfor
          for k=0L,nlevgp-1L do begin
              levdata=reform(gpdata(k,*))
              levprec=reform(gpprec(k,*))
              index=where(  (mmafstat eq 'G' or mmafstat eq 'T' or mmafstat eq 't') $
                             and gpqual eq 4. and levprec gt 0. and $
                             mlat ge latbin(j)-dy/2.0 and mlat lt latbin(j)+dy/2.0,npts)
              if index(0) ne -1L then zmgp(j,k)=total(levdata(index))/float(npts)
          endfor
          for k=0L,nlevo3205-1L do begin
              levdata=reform(o3205data(k,*))
              levprec=reform(o3205prec(k,*))
              index=where(  (mmafstat eq 'G' or mmafstat eq 'T' or mmafstat eq 't') $
                             and o3205qual eq 4. and levprec gt 0. and $
                             mlat ge latbin(j)-dy/2.0 and mlat lt latbin(j)+dy/2.0,npts)
              if index(0) ne -1L then zmo3205(j,k)=total(levdata(index))/float(npts)
          endfor
      endfor

      index=where(zmclo eq 0.)
      if index(0) ne -1L then zmclo(index)=-99.
      index=where(zmhno3 eq 0.)
      if index(0) ne -1L then zmhno3(index)=-99.
      index=where(zmo3205 eq 0.)
      if index(0) ne -1L then zmo3205(index)=-99.
      index=where(zmtemp eq 0.)
      if index(0) ne -1L then zmtemp(index)=-99.
      index=where(zmgp eq 0.)
      if index(0) ne -1L then zmgp(index)=-99.
;
; save postscript file?
;
      if setplot eq 'ps' then begin
         lc=0
         xsize=nxdim/100.
         ysize=nydim/100.
         set_plot,'ps'
         device,/color,/landscape,bits=8,filename='yz_uarsmls_'+sdate+'.ps'
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
      endif

      erase
      xyouts,.3,.95,'UARS MLS '+sdate,charsize=2,/normal,color=0
      !type=2^2+3^2
      xmn=xorig(0)
      xmx=xorig(0)+xlen
      ymn=yorig(0)
      ymx=yorig(0)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      omin=0.0
      omax=11.
      nlvls=20
      level=omin+((omax-omin)/nlvls)*findgen(nlvls+1)
      col1=1+indgen(nlvls+1)*mcolor/nlvls
      contour,zmo3205,latbin,po3205,levels=level,c_color=col1,/cell_fill,/noeras,yrange=[100.,0.01],/ylog,$
              xrange=[-90.,90.],xticks=6,ytitle='Pressure',xtitle='Latitude',charsize=1.5,min_value=-99.,$
              title='O3 (205-GHz)',color=0
      contour,zmo3205,latbin,po3205,levels=level,c_color=0,/follow,/noeras,/overplot
      ymnb=yorig(0)-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[omin,omax],[0,0],yrange=[0,10],xrange=[omin,omax],$
            charsize=1.5,color=0,xticks=5
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor

      !type=2^2+3^2
      xmn=xorig(1)
      xmx=xorig(1)+xlen
      ymn=yorig(1)
      ymx=yorig(1)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      omin=180.
      omax=300.
      nlvls=20
      level=omin+((omax-omin)/nlvls)*findgen(nlvls+1)
      col1=1+indgen(nlvls+1)*mcolor/nlvls
      contour,zmtemp,latbin,ptemp,levels=level,c_color=col1,/cell_fill,/noeras,yrange=[100.,0.01],/ylog,$
              xrange=[-90.,90.],xticks=6,xtitle='Latitude',charsize=1.5,min_value=-99.,$
              title='Temperature',color=0
      contour,zmtemp,latbin,ptemp,levels=level,c_color=0,/follow,/noeras,/overplot
      ymnb=yorig(1)-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[omin,omax],[0,0],yrange=[0,10],xrange=[omin,omax],$
            charsize=1.5,color=0,xticks=5
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor

      !type=2^2+3^2
      xmn=xorig(2)
      xmx=xorig(2)+xlen
      ymn=yorig(2)
      ymx=yorig(2)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      omin=0.0
      omax=15.
      nlvls=20
      level=omin+((omax-omin)/nlvls)*findgen(nlvls+1)
      col1=1+indgen(nlvls+1)*mcolor/nlvls
      contour,zmhno3,latbin,phno3,levels=level,c_color=col1,/cell_fill,/noeras,yrange=[100.,1.],/ylog,$
              xrange=[-90.,90.],xticks=6,ytitle='Pressure',xtitle='Latitude',charsize=1.5,min_value=-99.,$
              title='HNO3',color=0
      contour,zmhno3,latbin,phno3,levels=level,c_color=0,/follow,/noeras,/overplot
      ymnb=yorig(2)-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[omin,omax],[0,0],yrange=[0,10],xrange=[omin,omax],$
            xtitle='(ppbv)',charsize=1.5,color=0,xticks=5
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor

      !type=2^2+3^2
      xmn=xorig(3)
      xmx=xorig(3)+xlen
      ymn=yorig(3)
      ymx=yorig(3)+ylen
      set_viewport,xmn,xmx,ymn,ymx
      omin=0.0
      omax=100.
      nlvls=20
      level=omin+((omax-omin)/nlvls)*findgen(nlvls+1)
      col1=1+indgen(nlvls+1)*mcolor/nlvls
      contour,zmgp,latbin,pgp,levels=level,c_color=col1,/cell_fill,/noeras,yrange=[100.,0.01],/ylog,$
              xrange=[-90.,90.],xticks=6,xtitle='Latitude',charsize=1.5,min_value=-99.,$
              title='Geopotential Height',color=0,c_labels=1+0*level
      contour,zmgp,latbin,pgp,levels=level,c_color=0,/follow,/noeras,/overplot
      ymnb=yorig(3)-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[omin,omax],[0,0],yrange=[0,10],xrange=[omin,omax],$
            xtitle='(km)',charsize=1.5,color=0,xticks=5
      ybox=[0,10,10,0,0]
      x1=omin
      dx=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor

      if setplot eq 'x' then stop
      if setplot eq 'ps' then begin
         device, /close
         spawn,'convert -trim yz_uarsmls_'+sdate+'.ps -rotate -90 yz_uarsmls_'+sdate+'.jpg'
      endif
goto,jump
end
