;
; adapted from /aura6/data/GEOS4_data/Pre_process_MetO/mark_ukmo_global_vortices_v7_beta.pro
;
; marks circumpolar anticyclones!
;
; reads in .nc2 files.  marks polar vortex and anticyclones
; and writes out .nc4 files.
; v7 polar vortices
;
; this version adds the "subvortex modification" below 500 K
;
@stddat
@kgmt
@ckday
@kdate
@rd_ukmo_nc2
@compvort
@calcelat2d
@marker_lows_v7
@marker_highs_v6
@marker_circhighs_v7
@write_ukmo_nc4

loadct,38
mcolor=byte(!p.color)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.15]
yorig=[0.25]
xlen=0.7
ylen=0.5
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
dir='/aura3/data/UKMO_data/Datfiles/ukmo_'
lstmn=1 & lstdy=1 & lstyr=6 & lstday=0
ledmn=1 & leddy=1 & ledyr=6 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
;print, ' '
;print, '      UKMO Version '
;print, ' '
read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 2000 then lstyr=lstyr+2000
if ledyr lt 2000 then ledyr=ledyr+2000
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
      if ndays gt ledday then stop,' normal termination condition'
;
; read UKMO data
;
      syr=strtrim(string(iyr),2)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      date=syr+smn+sdy
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr
      print,ifile
      rd_ukmo_nc2,dir+ifile+'.nc2',nc,nr,nth,xlon,xlat,th,$
                 pv2,p2,msf2,u2,v2,q2,qdf2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
      x=fltarr(nc+1)
      x(0:nc-1)=xlon(0:nc-1)
      x(nc)=xlon(0)+360.
      mark2=0.*qdf2

; loop over theta
      mpvnh=999. & mpvsh=-999.
      for thlev=0,nth-1 do begin
          theta=th(thlev)
          pv1=transpose(pv2(*,*,thlev))
;         elat1=calcelat2d(pv1,xlon,xlat)
          p1=transpose(p2(*,*,thlev))
          mpv1=pv1*((th(thlev)/300.))^(-9./2.)
          u1=transpose(u2(*,*,thlev))
          v1=transpose(v2(*,*,thlev))
          qdf1=transpose(qdf2(*,*,thlev))
          sf1=transpose(sf2(*,*,thlev))
          zeta1=u1*0.0
          compvort,u1,v1,zeta1,xlon,xlat,nc,nr
          mpv=fltarr(nc+1,nr)
          mpv(0:nc-1,0:nr-1)=mpv1(0:nc-1,0:nr-1)
          mpv(nc,*)=mpv(0,*)
          pv=fltarr(nc+1,nr)
          pv(0:nc-1,0:nr-1)=pv1(0:nc-1,0:nr-1)
          pv(nc,*)=mpv(0,*)
;         elat=fltarr(nc+1,nr)
;         elat(0:nc-1,0:nr-1)=elat1(0:nc-1,0:nr-1)
;         elat(nc,*)=elat(0,*)
          p=fltarr(nc+1,nr)
          p(0:nc-1,0:nr-1)=p1(0:nc-1,0:nr-1)
          p(nc,*)=p(0,*)
          tp=theta*(p/1000.)^0.286
          zeta=fltarr(nc+1,nr)
          zeta(0:nc-1,0:nr-1)=zeta1(0:nc-1,0:nr-1)
          zeta(nc,*)=zeta(0,*)
          u=fltarr(nc+1,nr)
          u(0:nc-1,0:nr-1)=u1(0:nc-1,0:nr-1)
          u(nc,*)=u(0,*)
          v=fltarr(nc+1,nr)
          v(0:nc-1,0:nr-1)=v1(0:nc-1,0:nr-1)
          v(nc,*)=v(0,*)
          qdf=fltarr(nc+1,nr)
          qdf(0:nc-1,0:nr-1)=qdf1(0:nc-1,0:nr-1)
          qdf(nc,*)=qdf(0,*)
          sf=0.*fltarr(nc+1,nr)
          sf(0:nc-1,0:nr-1)=sf1(0:nc-1,0:nr-1)
          sf(nc,*)=sf(0,*)
          x2d=0.*sf
          y2d=0.*sf
          for i=0,nc do y2d(i,*)=xlat
          for j=0,nr-1 do x2d(*,j)=x
  
; streamfunction based polar vortex marker
          markl=0.*qdf
          marker_lows_v7,sf,markl,qdf,zeta,u,v,x,xlat,theta
;
; sub-vortex modification
;
        if theta eq 500. then begin
           nhindex=where(markl gt 0. and y2d gt 0.)
           shindex=where(markl gt 0. and y2d lt 0.)
           if nhindex(0) ne -1 then begin
              mpvnh=total(mpv(nhindex))/n_elements(nhindex)
;             elatnh=min(elat(nhindex))
           endif
           if shindex(0) ne -1 then begin
              mpvsh=total(mpv(shindex))/n_elements(shindex)
;             elatsh=max(elat(shindex))
           endif
           print,'AVG MPV ',mpvnh,mpvsh
;          print,'ELAT EDGE ',elatnh,elatsh
        endif
        if theta lt 500. then begin
           index=where(y2d gt 20. and mpv gt mpvnh and tp lt 230.)
;          if index(0) ne -1 then markl(index)=1.
index=where(y2d gt 20. and tp gt 240.)
if index(0) ne -1 then markl(index)=0.
;index=where(y2d gt 20. and mpv lt mpvnh)
;if index(0) ne -1 then markl(index)=0.

           index=where(y2d lt -20. and mpv lt mpvsh and tp lt 230.)
;          if index(0) ne -1 then markl(index)=1.
index=where(y2d lt -20. and tp gt 240.)
if index(0) ne -1 then markl(index)=0.
;index=where(y2d lt -20. and mpv gt mpvsh)
;if index(0) ne -1 then markl(index)=0.
        endif
;  
; streamfunction based anticyclone marker
;
          markh=0.*qdf
;
; don't look for anticyclones if theta surface is discontinuous
;
          if max(pv) lt 1.00000e+12 then begin
             marker_highs_v6,sf,markh,qdf,zeta,u,v,x,xlat,pv
  
; like polar vortex marker routine modified to find circumpolar highs
          markh2=0.*qdf
          marker_circhighs_v7,sf,markh2,qdf,zeta,u,v,x,xlat,theta
;
; check for overlap between circumpolar high and non circumpolar highs
;
          lindex=where(markh2 lt 0. and markh lt 0.)
          if lindex(0) ne -1 then begin
;print,'highs overlapping'
;erase
;!type=2^2+2^3
;contour,sf,x,xlat,nlevels=20,/noeras,title=string(th(thlev))
;index=where(markh lt 0.)
;if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=8,color=mcolor
;index=where(markh2 lt 0.)
;if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=4,color=mcolor*.3,symsize=0.5
;stop
             if min(y2d(lindex)) gt 0. then begin
                kindex=where(markh lt 0. and y2d gt 0.,kpt)
                jindex=where(markh2 lt 0. and y2d gt 0.,jpt)
                if max(y2d(jindex)) eq max(y2d) then markh(lindex)=0.           ; keep circumpolar
                if max(y2d(jindex)) lt max(y2d) then markh2(lindex)=0.
;               if kpt gt jpt then markh2(lindex)=0.            ; keep bigger
;               if kpt lt jpt then markh(lindex)=0.
             endif
             if max(y2d(lindex)) lt 0. then begin
                kindex=where(markh lt 0. and y2d lt 0.,kpt)
                jindex=where(markh2 lt 0. and y2d lt 0.,jpt)
                if min(y2d(jindex)) eq min(y2d) then markh(lindex)=0.           ; keep circumpolar
                if min(y2d(jindex)) gt min(y2d) then markh2(lindex)=0.
;               if kpt gt jpt then markh2(lindex)=0.            ; keep bigger
;               if kpt lt jpt then markh(lindex)=0.
             endif
;print,'are the highs still overlapping ?'
;erase
;!type=2^2+2^3
;contour,sf,x,xlat,nlevels=20,/noeras,title=string(th(thlev))
;index=where(markh lt 0.)
;if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=8,color=mcolor
;index=where(markh2 lt 0.)
;if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=4,color=mcolor*.3,symsize=0.5
;stop
          endif
;
; merge 2 anticyclone marker fields
;
         index=where(markh2 lt 0.)
         if index(0) ne -1L then markh(index)=min(markh)-1.0

          endif
;
; check for vortex and anticyclone overlap
;
          lindex=where(markl gt 0. and markh lt 0.)
          if lindex(0) ne -1 then begin
;            if min(y2d(lindex)) lt 0. and max(y2d(lindex)) gt 0. then stop
;
; NH
; 
             if min(y2d(lindex)) gt 0. then begin
                s0=min(sf(lindex))
                kindex=where(markl gt 0. and y2d gt 0.)
                s1=min(sf(kindex))
                index=where(sf ge (s0+s1)/2.0 and y2d gt 0.)
                markl(index)=0.
             endif
;
; SH
; 
             if max(y2d(lindex)) lt 0. then begin
                s0=max(sf(lindex))
                kindex=where(markl gt 0. and y2d lt 0.)
                s1=max(sf(kindex))
                index=where(sf le (s0+s1)/2.0 and y2d lt 0.)
                markl(index)=0.
             endif
          endif
;erase
;xmn=xorig(0)
;xmx=xorig(0)+xlen
;ymn=yorig(0)
;ymx=yorig(0)+ylen
;set_viewport,xmn,xmx,ymn,ymx
;!type=2^2+2^3
;contour,sf,x,xlat,nlevels=20,/noeras,xrange=[0.,360.],yrange=[-90.,90],$
;        title=date+'  '+string(theta)+' K',charsize=2
;map_set,0,180,0,/contin,/grid,/noeras
;index=where(markl gt 0.)
;if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=2,color=.2*mcolor
;index=where(markh lt 0.)
;if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=4,color=.9*mcolor
;contour,mpv,x,xlat,/overplot,levels=[mpvsh,mpvnh],thick=2,c_linestyle=1
;wait,1
          markl1=0.*qdf1
          markl1(0:nc-1,0:nr-1)=markl(0:nc-1,0:nr-1)
          mark2(*,*,thlev)=transpose(markl1)
          markh1=0.*qdf1
          markh1(0:nc-1,0:nr-1)=markh(0:nc-1,0:nr-1)
          mark2(*,*,thlev)=mark2(*,*,thlev)+transpose(markh1)
jumplev:

      ENDFOR	; loop over theta

; Write UKMO isentropic data in netCDF format
      write_ukmo_nc4,dir+ifile+'.nc4',nc,nr,nth,xlon,xlat,th,mark2
      goto,jump
end
