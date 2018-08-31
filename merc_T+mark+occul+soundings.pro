;
; plot satellite soundings and ukmo data
; VLH 8/20/2003
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
mcolor=icolmax
nlvls=20
col1=1+indgen(nlvls)*mcolor/nlvls
icmm1=icolmax-1
icmm2=icolmax-2
setplot='x'
;read,'setplot=',setplot
nxdim=750 & nydim=750
xorig=[0.10,0.70,0.10,0.40,0.70]
yorig=[0.70,0.70,0.10,0.10,0.10]
cbaryoff=0.10
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
dirs='/aura3/data/SAGE_II_data/Sound_data/sage2_'
dirs3='/aura3/data/SAGE_III_data/Sound_data/sage3_solar_'
diri='/aura3/data/ILAS_data/Sound_data/ilas_'
dirh='/aura3/data/HALOE_data/Sound_data/haloe_'
dirp3='/aura3/data/POAM_data/Sound_data/poam3_'
dirp2='/aura3/data/POAM_data/Sound_data/poam2_'
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
lstmn=1 & lstdy=1 & lstyr=3 & lstday=0
ledmn=1 & leddy=1 & ledyr=3 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
print, ' '
print, '      UKMO Version '
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
      if icount eq 0L then begin
         theta=700.
         print,th
         read,'Enter theta ',theta
         index=where(theta eq th)
         if index(0) eq -1 then stop,'Invalid theta level '
         thlev=index(0)
         stheta=strcompress(string(fix(theta)),/remove_all)
      endif
      qdf1=transpose(qdf2(*,*,thlev))
      sf1=transpose(sf2(*,*,thlev))
      msf1=transpose(msf2(*,*,thlev))
      pv1=transpose(pv2(*,*,thlev))
      p1=transpose(p2(*,*,thlev))
      mark1=transpose(mark2(*,*,thlev))
      t1=theta*((p1/1000.)^(.286))
      z1=(msf1-1004.*t1)/(9.86*1000.)
;
; read satellite ozone soundings
;
      sfile=mon(imn-1)+sdy+'_'+syr
      rd_sage3_o3_soundings,dirs3+sfile+'_o3.sound',norbits3,tsage3,$
         xsage3,ysage3,tropps3,tropzs3,tropths3,modes3,o3sage3,psage3,$
         thsage3,zsage3,clsage3,qo3sage3,nlevs3
      print,norbits3,' SAGE III'
      rd_sage2_o3_soundings,dirs+sfile+'_o3.sound',norbits2,tsage2,$
         xsage2,ysage2,tropps2,tropzs2,tropths2,modes2,o3sage2,psage2,$
         thsage2,zsage2,clsage2,qo3sage2,nlevs2
      print,norbits2,' SAGE II'
      if iyr lt 1998 then begin
      rd_poam3_o3_soundings,dirp2+sfile+'_o3.sound',norbitp3,tpoam3,$
         xpoam3,ypoam3,troppp3,tropzp3,tropthp3,modep3,o3poam3,ppoam3,$
         thpoam3,zpoam3,clpoam3,qo3poam3,nlevp3
      print,norbitp2,' POAM II'
      endif
      if iyr ge 1998 then begin
      rd_poam3_o3_soundings,dirp3+sfile+'_o3.sound',norbitp3,tpoam3,$
         xpoam3,ypoam3,troppp3,tropzp3,tropthp3,modep3,o3poam3,ppoam3,$
         thpoam3,zpoam3,clpoam3,qo3poam3,nlevp3
      print,norbitp3,' POAM III'
      endif
      rd_haloe_o3_soundings,dirh+sfile+'_o3.sound',norbith,thal,$
         xhal,yhal,tropph,tropzh,tropthh,modeh,o3hal,phal,$
         thhal,zhal,clhal,qo3hal,nlevh
      print,norbith,' HALOE'

      qdf=0.*fltarr(nc+1,nr)
      qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
      qdf(nc,*)=qdf(0,*)
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

      if setplot eq 'ps' then begin
         lc=0
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,$
                 filename='merc_T+mark+occul+soundings_'+stheta+'K_.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
      endif

; Set plot boundaries
      erase
      !type=2^2+2^3
      xmn=xorig(0)
      xmx=xorig(0)+0.4
      ymn=yorig(0)
      ymx=yorig(0)+0.2
      set_viewport,xmn,xmx,ymn,ymx
      date=strcompress(string(FORMAT='(A3,A1,I2,A2,I4)',$
                       month(imn-1),' ',idy,', ',iyr))
      if icount eq 0L then begin
         tmin=min(t)-10.
         tmax=max(t)+10.
         tint=(tmax-tmin)/(nlvls-1)
         tlevel=tmin+tint*findgen(nlvls)
      endif
      contour,t,x,alat,levels=tlevel,c_color=col1,/cell_fill,/noeras,$
              title='!6UKMO '+date+' '+stheta+' K',charsize=1.5,$
              xticks=6,xtitle='!6Longitude',yticks=6,ytitle='!6Latitude',$
              xtickname='!6'+['0','60','120','180','240','300','360'],$
              ytickname='!6'+['90S','60S','30S','EQ','30N','60N','90N']
      contour,t,x,alat,/overplot,levels=tlevel,c_color=0,$
              c_labels=0*tlevel,/follow,/noeras
      contour,t,x,alat,/overplot,levels=180.+5.*findgen(5),/follow,$
              c_color=icolmax,thick=2,/noeras,c_labels=1+0*findgen(11)
      MAP_SET,0,180,0,/merc,/noeras,/contin,charsize=2
      contour,mark,x,alat,levels=[0.1],color=0,thick=5,/overplot
      omin=2.0
      omax=7.
      if norbits3 gt 0 then begin
         norbit=norbits3
         for i=0,norbit-1 do begin
             o3prof=reform(o3sage3(i,*))
             index=where(o3prof gt 0.)
             o3prof=o3prof(index)*1.e6
             thprof=reform(thsage3(i,index))
             xx=xsage3(i)
             yy=ysage3(i)
             dth=min(abs(thprof-theta))
             kindex=where(abs(thprof-theta) eq dth)
             a=findgen(8)*(2*!pi/8.)
             usersym,cos(a),sin(a),/fill
             oplot,[xx,xx],[yy,yy],psym=8,symsize=2,$
                    color=(o3prof(kindex(0))/omax)*icolmax
             a=findgen(9)*(2*!pi/8.)
             usersym,cos(a),sin(a)
             oplot,[xx,xx],[yy,yy],psym=8,symsize=2,color=0
         endfor
      endif
      if norbits2 gt 0 then begin
         norbit=norbits2
         for i=0,norbit-1 do begin
             o3prof=reform(o3sage2(i,*))
             index=where(o3prof gt 0.)
             o3prof=o3prof(index)*1.e6
             thprof=reform(thsage2(i,index))
             xx=xsage2(i)
             yy=ysage2(i)
             dth=min(abs(thprof-theta))
             kindex=where(abs(thprof-theta) eq dth)
             a=findgen(8)*(2*!pi/8.)
             usersym,cos(a),sin(a),/fill
             oplot,[xx,xx],[yy,yy],psym=8,symsize=2,$
                    color=(o3prof(kindex(0))/omax)*icolmax
             a=findgen(9)*(2*!pi/8.)
             usersym,cos(a),sin(a)
             oplot,[xx,xx],[yy,yy],psym=8,symsize=2,color=icolmax*.9
         endfor
      endif
      if norbitp3 gt 0 then begin
         norbit=norbitp3
         for i=0,norbit-1 do begin
             o3prof=reform(o3poam3(i,*))
             index=where(o3prof gt 0.)
             o3prof=o3prof(index)*1.e6
             thprof=reform(thpoam3(i,index))
             xx=xpoam3(i)
             yy=ypoam3(i)
             dth=min(abs(thprof-theta))
             kindex=where(abs(thprof-theta) eq dth)
             a=findgen(4)*(2*!pi/4.)
             usersym,cos(a),sin(a),/fill
             oplot,[xx,xx],[yy,yy],psym=8,symsize=2,$
                    color=(o3prof(kindex(0))/omax)*icolmax
             a=findgen(5)*(2*!pi/4.)
             usersym,cos(a),sin(a)
             oplot,[xx,xx],[yy,yy],psym=8,symsize=2,color=0
         endfor
      endif
      if norbith gt 0 then begin
         norbit=norbith
         for i=0,norbit-1 do begin
             o3prof=reform(o3hal(i,*))
             index=where(o3prof gt 0.)
             o3prof=o3prof(index)*1.e6
             thprof=reform(thhal(i,index))
             xx=xhal(i)
             yy=yhal(i)
             dth=min(abs(thprof-theta))
             kindex=where(abs(thprof-theta) eq dth)
             a=findgen(3)*(2*!pi/3.)
             usersym,cos(a),sin(a),/fill
             oplot,[xx,xx],[yy,yy],psym=8,symsize=2,$
                    color=(o3prof(kindex(0))/omax)*icolmax
             a=findgen(4)*(2*!pi/3.)
             usersym,cos(a),sin(a)
             oplot,[xx,xx],[yy,yy],psym=8,symsize=2,color=0
         endfor
      endif

; horizontal temperature color bar
      ymnb=yorig(0)-cbaryoff
      ymxb=ymnb+cbarydel
      set_viewport,xmn,xmx,ymnb,ymxb
      !type=2^2+2^3+2^6
      plot,[min(tlevel),max(tlevel)],[0,0],yrange=[0,10],$
           xrange=[min(tlevel),max(tlevel)],charsize=1.5,$
           xtitle='!6Temperature (K)'
      ybox=[0,10,10,0,0]
      x1=min(tlevel)
      dx=(max(tlevel)-min(tlevel))/float(nlvls)
      for j=0,nlvls-1 do begin
          xbox=[x1,x1,x1+dx,x1+dx,x1]
          polyfill,xbox,ybox,color=col1(j)
          x1=x1+dx
      endfor

; vertical ozone color bar
      xmnb=xorig(0)+0.4+0.01
      xmxb=xmnb+cbarydel
      set_viewport,xmnb,xmxb,ymn,ymx
      !type=2^2+2^3+2^5+2^6
      plot,[0,0],[omin,omax],xrange=[0,10],yrange=[omin,omax]
      xbox=[0,10,10,0,0]
      y1=omin
      dy=(omax-omin)/float(nlvls)
      for j=0,nlvls-1 do begin
          ybox=[y1,y1,y1+dy,y1+dy,y1]
          polyfill,xbox,ybox,color=col1(j)
          y1=y1+dy
      endfor
      !type=2^2+2^3+2^5
      axis,10,omin,0,YAX=1,/DATA,charsize=1.5,/ynozero
      xyouts,xmxb+0.05,ymn+(ymx-ymn)/5.0,'!6Ozone (ppmv)',/normal,charsize=1.5,orientation=90.
;
; SAGE III ozone soundings
;
      !type=2^2+2^3
      xmn=xorig(1)
      xmx=xorig(1)+0.25
      ymn=yorig(1)-0.10
      ymx=ymn+0.35
      set_viewport,xmn,xmx,ymn,ymx
      plot,[0,12],[250,2000],yrange=[250,2000],/nodata,$
           xrange=[0,12],charsize=1.5,ytitle='!6Theta (K)',$
           xtitle='!6Ozone (ppmv)',title='!6SAGE III'
      if norbits3 eq 0L then $
      xyouts,2.,1200.,'!6No SAGE III data',/data,charsize=1.5
      if norbits3 gt 0L then begin
         for i=0,norbits3-1 do begin
             yy=ysage3(i)
             o3prof=reform(o3sage3(i,*))
             index=where(o3prof gt 0.)
             o3prof=o3prof(index)*1.e6
             thprof=reform(thsage3(i,index))
             if yy gt 0. then oplot,o3prof,thprof,color=mcolor
             if yy lt 0. then oplot,o3prof,thprof,color=mcolor*.25
         endfor
      endif
;
; SAGE II
;
      xmn=xorig(2)
      xmx=xorig(2)+0.25
      ymn=yorig(2)
      ymx=ymn+0.35
      set_viewport,xmn,xmx,ymn,ymx
      plot,[0,12],[250,2000],yrange=[250,2000],/nodata,$
           xrange=[0,12],charsize=1.5,ytitle='!6Theta (K)',$
           xtitle='!6Ozone (ppmv)',title='!6SAGE II'
      if norbits2 eq 0L then $
      xyouts,2.,1200.,'!6No SAGE II data',/data,charsize=1.5
      if norbits2 gt 0L then begin
         for i=0,norbits2-1 do begin
             yy=ysage2(i)
             o3prof=reform(o3sage2(i,*))
             index=where(o3prof gt 0.)
             o3prof=o3prof(index)*1.e6
             thprof=reform(thsage2(i,index))
             if yy gt 0. then oplot,o3prof,thprof,color=mcolor
             if yy lt 0. then oplot,o3prof,thprof,color=mcolor*.25
         endfor
      endif
;
; HALOE
;
      xmn=xorig(3)
      xmx=xorig(3)+0.25
      ymn=yorig(3)
      ymx=ymn+0.35
      set_viewport,xmn,xmx,ymn,ymx
      plot,[0,12],[250,2000],yrange=[250,2000],/nodata,$
           xrange=[0,12],charsize=1.5,ytickname=[' ',' ',' ',' '],$
           xtitle='!6Ozone (ppmv)',title='!6HALOE'
      if norbith eq 0L then $
      xyouts,2.,1200.,'!6No HALOE data',/data,charsize=1.5
      if norbith gt 0L then begin
         for i=0,norbith-1 do begin
             yy=yhal(i)
             o3prof=reform(o3hal(i,*))
             index=where(o3prof gt 0. and o3prof ne 1.00000e+24)
             o3prof=o3prof(index)*1.e6
             thprof=reform(thhal(i,index))
             if yy gt 0. then oplot,o3prof,thprof,color=mcolor
             if yy lt 0. then oplot,o3prof,thprof,color=mcolor*.25
         endfor
      endif
;
; POAM III
;
      xmn=xorig(4)
      xmx=xorig(4)+0.25
      ymn=yorig(4)
      ymx=ymn+0.35
      set_viewport,xmn,xmx,ymn,ymx
      plot,[0,12],[250,2000],yrange=[250,2000],/nodata,$
           xrange=[0,12],charsize=1.5,ytickname=[' ',' ',' ',' '],$
           xtitle='!6Ozone (ppmv)',title='!6POAM III'
      if norbitp3 eq 0L then $
      xyouts,2.,1200.,'!6No POAM III data',/data,charsize=1.5
      if norbitp3 gt 0L then begin
         for i=0,norbitp3-1 do begin
             yy=ypoam3(i)
             o3prof=reform(o3poam3(i,*))
             index=where(o3prof gt 0.)
             o3prof=o3prof(index)*1.e6
             thprof=reform(thpoam3(i,index))
             if yy gt 0. then oplot,o3prof,thprof,color=mcolor
             if yy lt 0. then oplot,o3prof,thprof,color=mcolor*.25
         endfor
      endif

      if setplot eq 'x' then begin
         save=assoc(3,bytarr(nxdim,nydim))
         img=bytarr(nxdim,nydim)
         img(0,0)=TVRD(0,0,nxdim,nydim)
         write_gif,'merc_T+mark+occul+soundings_'+stheta+'K.gif',img
      endif
      if setplot eq 'ps' then device, /close
      icount=icount+1L
      stop
      goto,jump
end
