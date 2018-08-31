;
; reads in .nc3 and plots polar orthographic
; plus occultation locations.  automated date.
;
@rd_ecmwf_nc3_manney
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
device,decompose=0
setplot='x'
read,'setplot=',setplot
mcolor=icolmax
nlvls=20
col1=1+indgen(nlvls)*mcolor/nlvls
icmm1=icolmax-1
icmm2=icolmax-2
nxdim=600 & nydim=600
xorig=[0.10]
yorig=[0.15]
cbaryoff=0.02
cbarydel=0.02
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
dir='/aura6/data/ECMWF_data/Datfiles/ecmwf_'
dirp='/aura3/data/POAM_data/Datfiles_SOSST/'
dirs='/aura3/data/SAGE_III_data/Datfiles_SOSST/'
lstmn=1 & lstdy=24 & lstyr=5 & lstday=0
ledmn=1 & leddy=24 & ledyr=5 & ledday=0
;restore,dirs+'cat_sage3_v3.00.1999'
;sage3date=date
;sage3lat=latitude
;sage3lon=longitude
;restore,dirs+'cat_sage3_v3.00.2000'
;sage3date=[sage3date,date]
;sage3lat=[sage3lat,latitude]
;sage3lon=[sage3lon,longitude]
restore,dirp+'cat_poam3_v4.0.1999'
poamdate=date
poamlat=latitude
poamlon=longitude
restore,dirp+'cat_poam3_v4.0.2000'
poamdate=[poamdate,date]
poamlat=[poamlat,latitude]
poamlon=[poamlon,longitude]
;
; Ask interactive questions- get starting/ending date
;
;print, ' '
;print, '      UKMO Version '
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
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      uyr=strmid(syr,2,2)
      ifile=string(FORMAT='(i4,i2.2,i2.2,a8)',iyr,imn,idy,'_12Z.nc3')
      rd_ecmwf_nc3_manney,dir+ifile,nc,nr,nth,alon,alat,th,pv2,p2,$
         msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
;
; Calculate the height of the isentropic surface = (msf - cp*T)/g
; where T = theta* (p/po)^R/cp and divide by 1000 for km
;
      t2=0.*p2
      z2=0.*p2
      for k=0,nth-1 do begin
          t2(*,*,k) = th(k)*( (p2(*,*,k)/1000.)^(.286) )
          z2(*,*,k) = (msf2(*,*,k) - 1004.*t2(*,*,k))/(9.86*1000.)
      endfor
;
; extract SAGE III and POAM III latitudes on this day
;
      slat=[-99.] & plat=[-99.]
      yyyymmdd=long(syr+smn+sdy)
;     index=where(sage3date eq yyyymmdd)
;     if index(0) ne -1L then begin
;        slat=sage3lat(index)
;        slon=sage3lon(index)
;     endif
      index=where(poamdate eq yyyymmdd)
      if index(0) ne -1L then begin
         plat=poamlat(index)
         plon=poamlon(index)
      endif
;
; uncomment for only one theta surface per day
;
      if icount eq 0L then begin
         theta=500.
;        print,th
;        read,'Enter theta ',theta
         index=where(theta eq th)
         if index(0) eq -1 then stop,'Invalid theta level '
         thlev=index(0)
         stheta=strcompress(string(fix(theta)),/remove_all)
         x=fltarr(nc+1)
         x(0:nc-1)=alon
         x(nc)=alon(0)+360.
         lon=fltarr(nc+1,nr)
         lat=fltarr(nc+1,nr)
         for i=0,nc   do lat(i,*)=alat
         for j=0,nr-1 do lon(*,j)=x
      endif
;
; comment out for only one theta surface per day
;
;     for thlev=0,nth-1 do begin
;         theta=th(thlev)
;         stheta=strcompress(string(fix(theta)),/remove_all)
          if setplot eq 'ps' then begin
             lc=0
             set_plot,'ps'
             xsize=nxdim/100.
             ysize=nydim/100.
             !p.font=0
             device,font_size=9
             device,/landscape,bits=8,filename=ifile+'_'+stheta+'K_pv+mark+sosst_ecmwfop.ps'
             device,/color
             device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                     xsize=xsize,ysize=ysize
          endif
;
; extract desired theta surface
;
          qdf1=transpose(qdf2(*,*,thlev))
          sf1=transpose(sf2(*,*,thlev))
          pv1=transpose(pv2(*,*,thlev))
          mark1=transpose(mark2(*,*,thlev))
          z1=transpose(z2(*,*,thlev))
          qdf=0.*fltarr(nc+1,nr)
          qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
          qdf(nc,*)=qdf(0,*)
          sf=0.*fltarr(nc+1,nr)
          sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
          sf(nc,*)=sf(0,*)
          pv=0.*fltarr(nc+1,nr)
          pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
          pv(nc,*)=pv(0,*)
          mark=0.*fltarr(nc+1,nr)
          mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
          mark(nc,*)=mark(0,*)
          z=0.*fltarr(nc+1,nr)
          z(0:nc-1,0:nr-1)=z1(0:nc-1,0:nr-1)
          z(nc,*)=z(0,*)
;
; polar orthographic of PV, vortex/anticyclone boundaries, and occultations
;
          erase
          !type=2^2+2^3
          xmn=xorig(0)
          xmx=xorig(0)+0.8
          ymn=yorig(0)
          ymx=yorig(0)+0.8
          set_viewport,xmn,xmx,ymn,ymx
          date=strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
                           month(imn-1),' ',idy,', ',iyr))
          MAP_SET,90,0,0,/ortho,/noeras,/grid,/contin,/noborder,$
                  title=date+'  '+stheta+' K',charsize=2.0,color=0
          oplot,findgen(361),0.1+0.*findgen(361)
          if icount eq 0 then begin
             index=where(lat gt 0.)
             pvmin=min(pv(index))-0.1*min(pv(index))
             pvmax=max(pv(index))+0.1*min(pv(index))
             nlvls=20
             pvint=(pvmax-pvmin)/nlvls
             pvlevel=pvmin+pvint*findgen(nlvls)
             col1=1+indgen(nlvls)*icolmax/float(nlvls)
          endif
          contour,pv,x,alat,/overplot,levels=pvlevel,c_color=col1,$
                 /cell_fill,/noeras
          contour,pv,x,alat,/overplot,levels=pvlevel,/follow,$
                  c_labels=0*pvlevel,/noeras,color=0
mark=smooth(mark,3,/edge_truncate)
          contour,mark,x,alat,/overplot,levels=[0.1,0.5,0.9],thick=5,color=0
;         contour,mark,x,alat,/overplot,levels=[-0.1],thick=7,color=mcolor
;         contour,z,x,alat,/overplot,levels=35+0.5*findgen(30),thick=2,color=mcolor,$
;                 c_labels=1+0*findgen(30),c_charsize=2.0
          MAP_SET,90,0,0,/ortho,/noeras,/grid,/contin,/noborder,$
                 charsize=2.0,latdel=10,color=0
;
; superimpose occultation locations
;
          a=findgen(8)*(2*!pi/7.)
          usersym,cos(a),sin(a),/fill
          if plat(0) ne -99. then oplot,plon,plat,psym=8,symsize=2,color=0
          a=findgen(5)*(2*!pi/4.)
          usersym,cos(a),sin(a),/fill
          if slat(0) ne -99. then oplot,slon,slat,psym=8,symsize=2,color=0
;
; key
;
          xyouts,xmx-0.15,ymn+0.045,'POAM III (circles)',/normal,color=0
          xyouts,xmx-0.15,ymn+0.020,'SAGE III (diamonds)',/normal,color=0
;
; horizontal PV color bar
;
          ymnb=yorig(0)-cbaryoff
          ymxb=ymnb+cbarydel
          set_viewport,xmn,xmx,ymnb,ymxb
          !type=2^2+2^3+2^6
          plot,[min(pvlevel),max(pvlevel)],[0,0],yrange=[0,10],$
               xrange=[min(pvlevel),max(pvlevel)],charsize=1.5,$
               xtitle='Potential Vorticity (PVU)',color=0
          ybox=[0,10,10,0,0]
          x1=min(pvlevel)
          dx=(max(pvlevel)-min(pvlevel))/float(nlvls)
          for j=0,nlvls-1 do begin
              xbox=[x1,x1,x1+dx,x1+dx,x1]
              polyfill,xbox,ybox,color=col1(j)
              x1=x1+dx
          endfor
      if setplot eq 'ps' then begin
         device, /close
          spawn,'convert -trim '+ifile+'_'+stheta+'K_pv+mark+sosst_ecmwfop.ps '+$
          ' -rotate -90 '+ifile+'_'+stheta+'K_pv+mark+sosst_ecmwfop.jpg'
      endif
      if setplot ne 'ps' then stop
      icount=icount+1L
      goto,jump
end
