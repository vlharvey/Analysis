;
; reads in .nc3 and plots polar orthographic
; plus occultation locations.  automated date.
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
xorig=[0.10]
yorig=[0.15]
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
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
dirh='/aura3/data/HALOE_data/Sound_data/haloe_'
dirs='/aura3/data/SAGE_II_data/Sound_data/sage2_'
dirs3='/aura3/data/SAGE_III_data/Sound_data/sage3_solar_'
dirp2='/aura3/data/POAM_data/Sound_data/poam2_'
dirp3='/aura3/data/POAM_data/Sound_data/poam3v4_'
ifile='                             '
lstmn=12 & lstdy=11 & lstyr=2 & lstday=0
ledmn=3 & leddy=1 & ledyr=3 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
;print, ' '
;print, '      UKMO Version '
;print, ' '
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
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr
      rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
; Height of isentropic surface = (msf - cp*T)/g
; where T = theta* (p/po)^R/cp and divide by 1000 for km
    t2=0.*p2
    z2=0.*p2
    for k=0,nth-1 do begin
        t2(*,*,k) = th(k)*( (p2(*,*,k)/1000.)^(.286) )
        z2(*,*,k) = (msf2(*,*,k) - 1004.*t2(*,*,k))/(9.86*1000.)
    endfor
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
             device,/landscape,bits=8,filename=ifile+'_'+stheta+'K_pv+mark+occul.ps'
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
          MAP_SET,90,0,0,/stereo,/noeras,/grid,/contin,/noborder,$
                  title=date+'  '+stheta+' K',charsize=2.0
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
          contour,mark,x,alat,/overplot,levels=[0.1],thick=7,color=0
          contour,mark,x,alat,/overplot,levels=[-0.1],thick=7,color=mcolor
;         contour,z,x,alat,/overplot,levels=35+0.5*findgen(30),thick=2,color=mcolor,$
;                 c_labels=1+0*findgen(30),c_charsize=2.0
          MAP_SET,90,0,0,/stereo,/noeras,/grid,/contin,/noborder,$
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
;                dth=min(abs(thprof-theta))
;                kindex=where(abs(thprof-theta) eq dth)
                 a=findgen(4)*(2*!pi/4.)
;                usersym,cos(a),sin(a),/fill
;                oplot,[xx,xx],[yy,yy],psym=8,symsize=2,$
;                       color=(o3prof(kindex(0))/omax)*icolmax
;                a=findgen(5)*(2*!pi/4.)
;                usersym,cos(a),sin(a)
                 oplot,[xx,xx],[yy,yy],psym=8,symsize=2,color=0
                 jumpp:
             endfor
          endif

; horizontal PV color bar
          ymnb=yorig(0)-cbaryoff
          ymxb=ymnb+cbarydel
          set_viewport,xmn,xmx,ymnb,ymxb
          !type=2^2+2^3+2^6
          plot,[min(pvlevel),max(pvlevel)],[0,0],yrange=[0,10],$
               xrange=[min(pvlevel),max(pvlevel)],charsize=1.5,$
               xtitle='Potential Vorticity (PVU)'
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
          spawn,'convert -trim '+ifile+'_'+stheta+'K_pv+mark+occul.ps '+$
          ' -rotate -90 '+ifile+'_'+stheta+'K_pv+mark+occul.jpg'
      endif
      if setplot ne 'ps' then stop
      icount=icount+1L
      goto,jump
end
