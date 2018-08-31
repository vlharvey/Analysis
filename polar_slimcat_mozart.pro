;
; read SLIMCAT and MOZART model fields for comparison
;
@rd_sage3_o3_soundings
@rd_haloe_o3_soundings
@rd_poam3_o3_soundings
@rd_sage2_o3_soundings
@rd_ukmo_nc3
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
;read,'setplot=',setplot
mcolor=icolmax
nlvls=20
col1=1+indgen(nlvls)*mcolor/nlvls
icmm1=icolmax-1
icmm2=icolmax-2
setplot='x'
read,'setplot=',setplot
nxdim=600 & nydim=600
xorig=[0.10,0.6]
yorig=[0.25,0.25]
xlen=0.35
ylen=0.35
cbaryoff=0.02
cbarydel=0.02
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
dirmz='/aura2/shaw/MOZART/MZ_CH4FULL/CH4_'
dirsl='/aura2/shaw/SC_CH4FULL/'
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
dirh='/aura3/data/HALOE_data/Sound_data/haloe_'
dirs='/aura3/data/SAGE_II_data/Sound_data/sage2_'
dirs3='/aura3/data/SAGE_III_data/Sound_data/sage3_solar_'
dirp2='/aura3/data/POAM_data/Sound_data/poam2_'
dirp3='/aura3/data/POAM_data/Sound_data/poam3_'
ifile='                             '
lstmn=12 & lstdy=2 & lstyr=2 & lstday=0
ledmn=3 & leddy=30 & ledyr=3 & ledday=0
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
restore,'/aura2/shaw/MOZART/MZ_CH4FULL/cat.dat'
nc=n_elements(lon)
nr=n_elements(lat)
nth=n_elements(zo)
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
; read SLIMCAT data
;
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      uyr=strmid(syr,2,2)
      ifile=syr+smn+sdy
      restore,dirmz+ifile+'_theta.dat'
      restore,dirsl+ifile+'CH4_SLIMCAT.dat'
;
; read satellite ozone soundings
;
      sfile=mon(imn-1)+sdy+'_'+syr
;     rd_sage3_o3_soundings,dirs3+sfile+'_o3.sound',norbits3,tsage3,$
;        xsage3,ysage3,tropps3,tropzs3,tropths3,modes3,o3sage3,psage3,$
;        thsage3,zsage3,clsage3,qo3sage3,nlevs3
;     rd_sage2_o3_soundings,dirs+sfile+'_o3.sound',norbits2,tsage2,$
;        xsage2,ysage2,tropps2,tropzs2,tropths2,modes2,o3sage2,psage2,$
;        thsage2,zsage2,clsage2,qo3sage2,nlevs2
      if iyr lt 1998 then begin
      rd_poam3_o3_soundings,dirp2+sfile+'_o3.sound',norbitp3,tpoam3,$
         xpoam3,ypoam3,troppp3,tropzp3,tropthp3,modep3,o3poam3,ppoam3,$
         thpoam3,zpoam3,clpoam3,qo3poam3,nlevp3
      endif
      if iyr ge 1998 then begin
      rd_poam3_o3_soundings,dirp3+sfile+'_o3.sound',norbitp3,tpoam3,$
         xpoam3,ypoam3,troppp3,tropzp3,tropthp3,modep3,o3poam3,ppoam3,$
         thpoam3,zpoam3,clpoam3,qo3poam3,nlevp3
      endif
;     rd_haloe_o3_soundings,dirh+sfile+'_o3.sound',norbith,thal,$
;        xhal,yhal,tropph,tropzh,tropthh,modeh,o3hal,phal,$
;        thhal,zhal,clhal,qo3hal,nlevh
;
; uncomment for only one theta surface per day
;
      if icount eq 0L then begin
         theta0=2000.
         print,zo
         read,'Enter theta ',theta0
         index=where(theta0 eq zo)
         if index(0) eq -1 then stop,'Invalid theta level '
         thlev=index(0)
         stheta=strcompress(string(fix(theta0)),/remove_all)
         x=fltarr(nc+1)
         x(0:nc-1)=lon
         x(nc)=lon(0)+360.
         x2d=fltarr(nc+1,nr)
         y2d=fltarr(nc+1,nr)
         for i=0,nc   do y2d(i,*)=lat
         for j=0,nr-1 do x2d(*,j)=x
;
; choose closest SLIMCAT level to chosen MOZART level
;
         index=where(abs(theta-theta0) eq min(abs(theta-theta0)))
         thlev2=index(0)
         stheta2=strcompress(string(fix(theta(thlev2))),/remove_all)
print,'choose SLIMCAT ',theta(thlev2),theta0
      endif
;
; comment out for only one theta surface per day
;
;     for thlev=0,nth-1 do begin
          if setplot eq 'ps' then begin
             lc=0
             set_plot,'ps'
             xsize=nxdim/100.
             ysize=nydim/100.
             !p.font=0
             device,font_size=9
             device,/landscape,bits=8,filename=ifile+'_'+stheta+'K_slimcat_mozart.ps'
             device,/color
             device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                     xsize=xsize,ysize=ysize
          endif
;
; extract desired theta surface from MZ data
;
          data1=data(*,*,thlev)*1.e6
          data2=0.*fltarr(nc+1,nr)
          data2(0:nc-1,0:nr-1)=data1(0:nc-1,0:nr-1)
          data2(nc,*)=data2(0,*)
;
; extract desired theta surface from SL data
;
          sdata1=sc(*,*,thlev2)*1.e6
          ncs=n_elements(LON_SC)
          nrs=n_elements(LAT_SC)
          xs=fltarr(ncs+1)
          xs(0:ncs-1)=lon_sc
          xs(ncs)=lon_sc(0)+360.
          sdata2=0.*fltarr(ncs+1,nrs)
          sdata2(0:ncs-1,0:nrs-1)=sdata1(0:ncs-1,0:nrs-1)
          sdata2(ncs,*)=sdata2(0,*)

          erase
          !type=2^2+2^3
          xmn=xorig(0)
          xmx=xorig(0)+xlen
          ymn=yorig(0)
          ymx=yorig(0)+ylen
          set_viewport,xmn,xmx,ymn,ymx
          date=strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
                           month(imn-1),' ',idy,', ',iyr))
          xyouts,0.25,0.75,date+' Methane',/normal,charsize=3
          MAP_SET,90,0,0,/ortho,/noeras,/grid,/contin,/noborder,$
                  title='MOZART '+stheta+' K',charsize=2.0
          oplot,findgen(361),0.1+0.*findgen(361)
          if icount eq 0 then begin
             omin=0.0
             omax=2.0
             nlvls=20
             oint=0.1
             level=omin+oint*findgen(nlvls)
             col1=1+indgen(nlvls)*icolmax/float(nlvls)
          endif
print,'MZ ',min(data2),max(data2)
          contour,data2,x,lat,/overplot,levels=level,c_color=col1,$
                 /cell_fill,/noeras
          contour,data2,x,lat,/overplot,levels=level,/follow,$
                  c_labels=0*level,/noeras,color=0
          MAP_SET,90,0,0,/ortho,/noeras,/grid,/contin,/noborder,$
                 charsize=2.0,latdel=10,color=0
;
; occultation points colored by ozone
;
          omin=0.
          omax=12.
          if norbitp3 gt 0 then begin
             norbit=norbitp3
             for i=0,norbit-1 do begin
                 o3prof=reform(o3poam3(i,*))
;                index=where(o3prof gt 0.)
;                if index(0) eq -1 then goto,jumpp
;                o3prof=o3prof(index)*1.e6
;                thprof=reform(thpoam3(i,index))
                 xx=xpoam3(i)
                 yy=ypoam3(i)
;                dth=min(abs(thprof-theta0))
;                kindex=where(abs(thprof-theta0) eq dth)
                 a=findgen(4)*(2*!pi/4.)
;                usersym,cos(a),sin(a),/fill
;                oplot,[xx,xx],[yy,yy],psym=8,symsize=2,$
;                       color=(o3prof(kindex(0))/omax)*icolmax
;                a=findgen(5)*(2*!pi/4.)
;                usersym,cos(a),sin(a)
                 oplot,[xx,xx],[yy,yy],psym=8,color=0,symsize=1.5
                 jumpp:
             endfor
          endif

; horizontal methane color bar
          ymnb=yorig(0)-cbaryoff
          ymxb=ymnb+cbarydel
          set_viewport,xmn,xmx,ymnb,ymxb
          !type=2^2+2^3+2^6
          plot,[min(level),max(level)],[0,0],yrange=[0,10],$
               xrange=[min(level),max(level)],charsize=1.5,$
               xtitle='(ppmv)'
          ybox=[0,10,10,0,0]
          x1=min(level)
          dx=(max(level)-min(level))/float(nlvls)
          for j=0,nlvls-1 do begin
              xbox=[x1,x1,x1+dx,x1+dx,x1]
              polyfill,xbox,ybox,color=col1(j)
              x1=x1+dx
          endfor

          !type=2^2+2^3
          xmn=xorig(1)
          xmx=xorig(1)+xlen
          ymn=yorig(1)
          ymx=yorig(1)+ylen
          set_viewport,xmn,xmx,ymn,ymx
print,'SC ',min(sdata2),max(sdata2)
          MAP_SET,90,0,0,/ortho,/noeras,/grid,/contin,/noborder,$
                  title='SLIMCAT '+stheta2+' K',charsize=2.0
          oplot,findgen(361),0.1+0.*findgen(361)
          contour,sdata2,xs,lat_sc,/overplot,levels=level,c_color=col1,$
                 /cell_fill,/noeras
          contour,sdata2,xs,lat_sc,/overplot,levels=level,/follow,$
                  c_labels=0*level,/noeras,color=0
          MAP_SET,90,0,0,/ortho,/noeras,/grid,/contin,/noborder,$
                 charsize=2.0,latdel=10,color=0

          omin=0.
          omax=12.
          if norbitp3 gt 0 then begin
             norbit=norbitp3
             for i=0,norbit-1 do begin
                 o3prof=reform(o3poam3(i,*))
;                index=where(o3prof gt 0.)
;                if index(0) eq -1 then goto,jumpp2
;                o3prof=o3prof(index)*1.e6
;                thprof=reform(thpoam3(i,index))
                 xx=xpoam3(i)
                 yy=ypoam3(i)
;                dth=min(abs(thprof-theta0))
;                kindex=where(abs(thprof-theta0) eq dth)
                 a=findgen(4)*(2*!pi/4.)
;                usersym,cos(a),sin(a),/fill
;                oplot,[xx,xx],[yy,yy],psym=8,symsize=2,$
;                       color=(o3prof(kindex(0))/omax)*icolmax
;                a=findgen(5)*(2*!pi/4.)
;                usersym,cos(a),sin(a)
                 oplot,[xx,xx],[yy,yy],psym=8,color=0,symsize=1.5
                 jumpp2:
             endfor
          endif

; horizontal color bar
          ymnb=yorig(0)-cbaryoff
          ymxb=ymnb+cbarydel
          set_viewport,xmn,xmx,ymnb,ymxb
          !type=2^2+2^3+2^6
          plot,[min(level),max(level)],[0,0],yrange=[0,10],$
               xrange=[min(level),max(level)],charsize=1.5,$
               xtitle='(ppmv)'
          ybox=[0,10,10,0,0]
          x1=min(level)
          dx=(max(level)-min(level))/float(nlvls)
          for j=0,nlvls-1 do begin
              xbox=[x1,x1,x1+dx,x1+dx,x1]
              polyfill,xbox,ybox,color=col1(j)
              x1=x1+dx
          endfor
      if setplot eq 'ps' then device,/close
      if setplot ne 'ps' then stop
      icount=icount+1L
      goto,jump
end
