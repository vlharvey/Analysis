;
; NH
; plot satellite data in longitude altitude section
; add polar projection at a user prompted theta
; VLH 1/27/04
;
@stddat
@kgmt
@ckday
@kdate
@rd_sage3_o3_soundings
@rd_haloe_o3_soundings
@rd_poam3_o3_soundings
@rd_sage2_o3_soundings
@rd_ilas_o3_soundings
@rd_ukmo_nc3

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='ps'
read,'setplot=',setplot
nxdim=800 & nydim=800
xorig=[.05,.3,.55,.8]+0.05
yorig=[.7,.45,.15]-0.1
xlen=0.175
ylen=0.175
cbaryoff=0.05
cbarydel=0.01
!NOERAS=-1
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
nmon=['01', '02', '03', '04', '05', '06', '07', '08', '09', '10', '11', '12']
dirs='/aura3/data/SAGE_II_data/Sound_data/sage2_'
dirs3='/aura3/data/SAGE_III_data/Sound_data/sage3_solar_'
diri='/aura3/data/ILAS_data/Sound_data/ilas_'
dirh='/aura3/data/HALOE_data/Sound_data/haloe_'
dirp3='/aura3/data/POAM_data/Sound_data/poam3_'
dirp2='/aura3/data/POAM_data/Sound_data/poam2_'
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
lstmn=4
lstdy=12
lstyr=2001
ledmn=4
leddy=12
ledyr=2001
lstday=0
ledday=0
;
; Ask interactive questions- get starting/ending date and p surface
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

; Compute initial Julian date
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
iday = iday - 1

; --- Loop here --------
jump: iday = iday + 1
print,iday
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then stop,' Normal termination condition '

      if iyr ge 2000 then iyr1=iyr-2000
      if iyr lt 2000 then iyr1=iyr-1900
      uyr=string(FORMAT='(I2.2)',iyr1)
      syr=string(FORMAT='(I4.4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      date=syr+smn+sdy

      if setplot eq 'ps' then begin
         lc=0
         set_plot,'ps'
         xsize=nxdim/100.
         ysize=nydim/100.
         !p.font=0
         device,font_size=9
         device,/landscape,bits=8,$
                filename='polar_xz_o3_profs_'+date+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
      endif
      ifile=mon(imn-1)+sdy+'_'+uyr
      lfile=nmon(imn-1)+'_'+sdy+'_'+uyr
      rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      rtheta=1000.
      index=where(rtheta eq th)
      if index(0) eq -1 then stop
      itheta=index(0)
      stheta=strcompress(string(fix(th(itheta))),/remove_all)
      xz2d=fltarr(nc,nth)
      yz2d=fltarr(nc,nth)
      for k=0,nth-1 do xz2d(*,k)=alon
      for j=0,nc-1 do yz2d(j,*)=th
      x=fltarr(nc+1)
      x(0:nc-1)=alon
      x(nc)=alon(0)+360.
      x2d=fltarr(nc+1,nr)
      y2d=fltarr(nc+1,nr)
      for i=0,nc do y2d(i,*)=alat
      for j=0,nr-1 do x2d(*,j)=x
;
; read satellite ozone soundings
;
      sfile=mon(imn-1)+sdy+'_'+syr
      norbits3=0L & norbits2=0L & norbitp3=0L & norbith=0L & norbiti=0L
;     rd_sage3_o3_soundings,dirs3+sfile+'_o3.sound',norbits3,tsage3,$
;        xsage3,ysage3,tropps3,tropzs3,tropths3,modes3,o3sage3,psage3,$
;        thsage3,zsage3,clsage3,qo3sage3,nlevs3
      rd_sage2_o3_soundings,dirs+sfile+'_o3.sound',norbits2,tsage2,$
         xsage2,ysage2,tropps2,tropzs2,tropths2,modes2,o3sage2,psage2,$
         thsage2,zsage2,clsage2,qo3sage2,nlevs2
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
      rd_haloe_o3_soundings,dirh+sfile+'_o3.sound',norbith,thal,$
         xhal,yhal,tropph,tropzh,tropthh,modeh,o3hal,phal,$
         thhal,zhal,clhal,qo3hal,nlevh
      rd_ilas_o3_soundings,diri+sfile+'_o3.sound',norbiti,tilas,$
         xilas,yilas,troppi,tropzi,tropthi,modei,o3ilas,pilas,$
         thilas,zilas,clilas,qo3ilas,nlevi
;
; remove missing and bad data
;
      yhal0=-999. & yhal1=-999.
      if norbith gt 0L then begin
         index=where(yhal ge -90. and yhal le 90.,norbith)
         if index(0) ne -1 then begin
            yhal=yhal(index)
            xhal=xhal(index)
            o3hal=o3hal(index,*)
            thhal=thhal(index,*)
         endif
         good=0.*fltarr(nlevh)
         for ilev=0,nlevh-1 do $
             if max(thhal(*,ilev)) lt 1.00000e+24 then good(ilev)=1.
         index=where(good eq 1.,nlevh)
         thhal=thhal(*,index)
         o3hal=o3hal(*,index)
         qo3hal=qo3hal(*,index)
         index=where(qo3hal/o3hal gt 0.5)
         if index(0) ne -1 then o3hal(index)=-999.
         index=where(modeh eq 0L)
         if index(0) ne -1 then begin
            yhalsr=yhal(index)
            xhalsr=xhal(index)
            o3halsr=o3hal(index,*)
            thhalsr=thhal(index,*)
            index=where(yhalsr ge -90. and yhalsr le 90.)
            if index(0) eq -1 then goto,jumphalsr
            yhal0=index(0)
            if n_elements(index) gt 1 then begin
               result=moment(yhalsr(index))
               yhal0=result(0)
            endif
         endif
         jumphalsr:
         index=where(modeh eq 1L)
         if index(0) ne -1 then begin
            yhalss=yhal(index)
            xhalss=xhal(index)
            o3halss=o3hal(index,*)
            thhalss=thhal(index,*)
            index=where(yhalss ge -90. and yhalss le 90.)
            if index(0) eq -1 then goto,jumphalss
            yhal1=index(0)
            if n_elements(index) gt 1 then begin
               result=moment(yhalss(index))
               yhal1=result(0)
            endif
         endif
         jumphalss:
      endif
      ysage30=-999. & ysage31=-999.
      if norbits3 gt 0L then begin
         index=where(qo3sage3/o3sage3 gt 0.5)
         if index(0) ne -1 then o3sage3(index)=-999.
         index=where(modes3 eq 0L)
         if index(0) ne -1 then begin
            ysage3sr=ysage3(index)
            xsage3sr=xsage3(index)
            o3sage3sr=o3sage3(index,*)
            thsage3sr=thsage3(index,*)
            index=where(ysage3sr ge -90. and ysage3sr le 90.)
            if index(0) eq -1 then goto,jumpsage3sr
            ysage30=index(0)
            if n_elements(index) gt 1 then begin
               result=moment(ysage3sr(index))
               ysage30=result(0)
            endif
         endif
         jumpsage3sr:
         index=where(modes3 eq 1L)
         if index(0) ne -1 then begin
            ysage3ss=ysage3(index)
            xsage3ss=xsage3(index)
            o3sage3ss=o3sage3(index,*)
            thsage3ss=thsage3(index,*)
            index=where(ysage3ss ge -90. and ysage3ss le 90.)
            if index(0) eq -1 then goto,jumpsage3ss
            ysage31=index(0)
            if n_elements(index) gt 1 then begin
               result=moment(ysage3ss(index))
               ysage31=result(0)
            endif
         endif
         jumpsage3ss:
      endif
      ysage20=-999. & ysage21=-999.
      if norbits2 gt 0L then begin
         index=where(qo3sage2/o3sage2 gt 0.5)
         if index(0) ne -1 then o3sage2(index)=-999.
         index=where(modes2 eq 0L)
         if index(0) ne -1 then begin
            ysage2sr=ysage2(index)
            xsage2sr=xsage2(index)
            o3sage2sr=o3sage2(index,*)
            thsage2sr=thsage2(index,*)
            index=where(ysage2sr ge -90. and ysage2sr le 90.)
            if index(0) eq -1 then goto,jumpsage2sr
            ysage20=index(0)
            if n_elements(index) gt 1 then begin
               result=moment(ysage2sr(index))
               ysage20=result(0)
            endif
         endif
         jumpsage2sr:
         index=where(modes2 eq 1L)
         if index(0) ne -1 then begin
            ysage2ss=ysage2(index)
            xsage2ss=xsage2(index)
            o3sage2ss=o3sage2(index,*)
            thsage2ss=thsage2(index,*)
            index=where(ysage2ss ge -90. and ysage2ss le 90.)
            if index(0) eq -1 then goto,jumpsage2ss
            ysage21=index(0)
            if n_elements(index) gt 1 then begin
               result=moment(ysage2ss(index))
               ysage21=result(0)
            endif
         endif
         jumpsage2ss:
      endif
      ypoam30=-999. & ypoam31=-999.
      if norbitp3 gt 0L then begin
         index=where(qo3poam3/o3poam3 gt 0.5)
         if index(0) ne -1 then o3poam3(index)=-999.
         index=where(modep3 eq 0L)
         if index(0) ne -1 then begin
            ypoam3sr=ypoam3(index)
            xpoam3sr=xpoam3(index)
            o3poam3sr=o3poam3(index,*)
            thpoam3sr=thpoam3(index,*)
            index=where(ypoam3sr ge -90. and ypoam3sr le 90.)
            if index(0) eq -1 then goto,jumppoam3sr
            ypoam30=index(0)
            if n_elements(index) gt 1 then begin
               result=moment(ypoam3sr(index))
               ypoam30=result(0)
            endif
         endif
         jumppoam3sr:
         index=where(modep3 eq 1L)
         if index(0) ne -1 then begin
            ypoam3ss=ypoam3(index)
            xpoam3ss=xpoam3(index)
            o3poam3ss=o3poam3(index,*)
            thpoam3ss=thpoam3(index,*)
            index=where(ypoam3ss ge -90. and ypoam3ss le 90.)
            if index(0) eq -1 then goto,jumppoam3ss
            ypoam31=index(0)
            if n_elements(index) gt 1 then begin
               result=moment(ypoam3ss(index))
               ypoam31=result(0)
            endif
         endif
         jumppoam3ss:
      endif
      yilas0=-999. & yilas1=-999.
      if norbiti gt 0L then begin
         index=where(yilas ge -90. and yilas le 90.,norbith)
         if index(0) ne -1 then begin
            yilas=yilas(index)
            xilas=xilas(index)
            o3ilas=o3ilas(index,*)
            thilas=thilas(index,*)
         endif
         good=0.*fltarr(nlevi)
         for ilev=0,nlevi-1 do $
             if max(thilas(*,ilev)) lt 1.00000e+24 then good(ilev)=1.
         index=where(good eq 1.,nlevi)
         thilas=thilas(*,index)
         o3ilas=o3ilas(*,index)
         qo3ilas=qo3ilas(*,index)
         index=where(qo3ilas/o3ilas gt 0.5)
         if index(0) ne -1 then o3ilas(index)=-999.
         index=where(modei eq 0L)
         if index(0) ne -1 then begin
            yilassr=yilas(index)
            xilassr=xilas(index)
            o3ilassr=o3ilas(index,*)
            thilassr=thilas(index,*)
            index=where(yilassr ge -90. and yilassr le 90.)
            if index(0) eq -1 then goto,jumpilassr
            yilas0=index(0)
            if n_elements(index) gt 1 then begin
               result=moment(yilassr(index))
               yilas0=result(0)
            endif
         endif
         jumpilassr:
         index=where(modei eq 1L)
         if index(0) ne -1 then begin
            yilasss=yilas(index)
            xilasss=xilas(index)
            o3ilasss=o3ilas(index,*)
            thilasss=thilas(index,*)
            index=where(yilasss ge -90. and yilasss le 90.)
            if index(0) eq -1 then goto,jumpilasss
            yilas1=index(0)
            if n_elements(index) gt 1 then begin
               result=moment(yilasss(index))
               yilas1=result(0)
            endif
         endif
         jumpilasss:
      endif
      yorder=[yhal0,yhal1,ypoam30,ypoam31,ysage30,ysage31,$
              ysage20,ysage21,yilas0,yilas1]
      instorder=['HALOESR','HALOESS','POAMSR','POAMSS','SAGE3SR','SAGE3SS',$
                 'SAGE2SR','SAGE2SS','ILASSR','ILASSS']
      erase
      xmn=xorig(0)+.2
      xmx=xmn+xlen+.175
      ymn=yorig(0)
      ymx=ymn+ylen+.175
      set_viewport,xmn,xmx,ymn,ymx
      sf1=transpose(sf2(*,*,itheta))
      mark1=transpose(mark2(*,*,itheta))
      sf=fltarr(nc+1,nr)
      sf(0:nc-1,0:nr-1)=sf1
      sf(nc,*)=sf(0,*)
      mark=fltarr(nc+1,nr)
      mark(0:nc-1,0:nr-1)=mark1(0:nc-1,0:nr-1)
      mark(nc,*)=mark(0,*)
      !type=2^2+2^3
      MAP_SET,90,0,-180,/ortho,/contin,/grid,/noeras,color=lc,/noborder,title=date,charsize=1.5
      oplot,findgen(361),0.1+0.*findgen(361),psym=0
      contour,sf,x,alat,nlevels=20,c_color=lc,/overplot,/follow,c_labels=0,/noeras
      loadct,0
      mcolor=255
      index=where(mark lt 0.)
      if index(0) ne -1 then oplot,x2d(index),y2d(index),psym=8,color=lc,symsize=1.5
      contour,mark,x,alat,levels=[0.1],color=mcolor*0.5,/overplot,/cell_fill,/noeras,min_value=0.1
      contour,mark,x,alat,levels=[0.1],c_color=lc,/overplot,/follow,$
              c_labels=0,/noeras,thick=4
      contour,mark,x,alat,levels=[-0.1],c_color=mcolor*0.5,/overplot,/follow,$
              c_labels=0,/noeras,thick=4
      loadct,38
      mcolor=255
      o3min=4.25
      o3max=8.75
      rlat=20.
      if norbith gt 0L then begin
         xhal2d=0.*thhal
         yhal2d=0.*thhal
         for k=0L,long(nlevh)-1L do begin
             xhal2d(*,k)=xhal
             yhal2d(*,k)=yhal
         endfor
         index=where(abs(thhal-rtheta) le 20. and o3hal gt 0. and yhal2d gt rlat,hcount)
         if hcount gt 0L then begin
            xday=xhal2d(index)
            yday=yhal2d(index)
            thday=thhal(index)
            o3day=o3hal(index)*1.e6
            a=findgen(9)*(2*!pi/8.)
            usersym,2.*cos(a),2.*sin(a),/fill
            for i=0,hcount-1 do $
                oplot,[xday(i),xday(i)],[yday(i),yday(i)],$
                      psym=8,color=mcolor*(o3day(i)-o3min)/(o3max-o3min)
            a=findgen(9)*(2*!pi/8.)
            usersym,2.*cos(a),2.*sin(a)
            oplot,xday,yday,psym=8,color=lc
         endif
      endif
      if norbits2 gt 0L then begin
         xsage2d=0.*thsage2
         ysage2d=0.*thsage2
         for k=0L,long(nlevs2)-1L do begin
             xsage2d(*,k)=xsage2
             ysage2d(*,k)=ysage2
         endfor
         index=where(abs(thsage2-rtheta) le 20. and o3sage2 gt 0. and ysage2d gt rlat,scount)
         if scount gt 0L then begin
            xday=xsage2d(index)
            yday=ysage2d(index)
            thday=thsage2(index)
            o3day=o3sage2(index)*1.e6
            a=findgen(5)*(2*!pi/4.)
            usersym,2.*cos(a),2.*sin(a),/fill
            for i=0,scount-1 do $
                oplot,[xday(i),xday(i)],[yday(i),yday(i)],$
                      psym=8,color=mcolor*(o3day(i)-o3min)/(o3max-o3min)
            a=findgen(5)*(2*!pi/4.)
            usersym,2.*cos(a),2.*sin(a)
            oplot,xday,yday,psym=8,color=lc
         endif
      endif
      if norbitp3 gt 0L then begin
         xpoam2d=0.*thpoam3
         ypoam2d=0.*thpoam3
         for k=0L,long(nlevp3)-1L do begin
             xpoam2d(*,k)=xpoam3
             ypoam2d(*,k)=ypoam3
         endfor
         index=where(abs(thpoam3-rtheta) le 20. and o3poam3 gt 0. and ypoam2d gt rlat,pcount)
         if pcount gt 0L then begin
            xday=xpoam2d(index)
            yday=ypoam2d(index)
            thday=thpoam3(index)
            o3day=o3poam3(index)*1.e6
            a=findgen(4)*(2*!pi/3.)
            usersym,2.*cos(a),2.*sin(a),/fill
            for i=0,pcount-1 do $
                oplot,[xday(i),xday(i)],[yday(i),yday(i)],$
                      psym=8,color=mcolor*(o3day(i)-o3min)/(o3max-o3min)
            a=findgen(4)*(2*!pi/3.)
            usersym,2.*cos(a),2.*sin(a)
            oplot,xday,yday,psym=8,color=lc
         endif
      endif
      if norbiti gt 0L then begin
         xilas2d=0.*thilas
         yilas2d=0.*thilas
         for k=0L,long(nlevi)-1L do begin
             xilas2d(*,k)=xilas
             yilas2d(*,k)=yilas
         endfor
         index=where(abs(thilas-rtheta) le 20. and o3ilas gt 0. and yilas2d gt rlat,icount)
         if icount gt 0L then begin
            xday=xilas2d(index)
            yday=yilas2d(index)
            thday=thilas(index)
            o3day=o3ilas(index)*1.e6
            a=findgen(4)*(2*!pi/3.)
            usersym,2.*cos(a),2.*sin(a),/fill
            for i=0,icount-1 do $
                oplot,[xday(i),xday(i)],[yday(i),yday(i)],$
                      psym=8,color=mcolor*(o3day(i)-o3min)/(o3max-o3min)
            a=findgen(4)*(2*!pi/3.)
            usersym,2.*cos(a),2.*sin(a)
            oplot,xday,yday,psym=8,color=lc
         endif
      endif
;
; remove missing and SH modes
;
      rlat=20.
      index=where(yorder gt rlat,npan)
      if index(0) ne -1 then begin
         yorder=yorder(index)
         instorder=instorder(index)
      endif
      for ipan=0L,npan-1L do begin
;
; plot longitude-altitude sections in correct order S-N
;
          case 1 of
            (instorder(ipan) eq 'HALOESR'): begin
             ydata=yhalsr
             xdata=xhalsr
             o3data=o3halsr
             thdata=thhalsr
            end
            (instorder(ipan) eq 'HALOESS'): begin
             ydata=yhalss
             xdata=xhalss
             o3data=o3halss
             thdata=thhalss
            end
            (instorder(ipan) eq 'POAMSR'): begin
             ydata=ypoam3sr
             xdata=xpoam3sr
             o3data=o3poam3sr
             thdata=thpoam3sr
            end
            (instorder(ipan) eq 'POAMSS'): begin
             ydata=ypoam3ss
             xdata=xpoam3ss
             o3data=o3poam3ss
             thdata=thpoam3ss
            end
            (instorder(ipan) eq 'SAGE3SR'): begin
             ydata=ysage3sr
             xdata=xsage3sr
             o3data=o3sage3sr
             thdata=thsage3sr
            end
            (instorder(ipan) eq 'SAGE3SS'): begin
             ydata=ysage3ss
             xdata=xsage3ss
             o3data=o3sage3ss
             thdata=thsage3ss
            end
            (instorder(ipan) eq 'SAGE2SR'): begin
             ydata=ysage2sr
             xdata=xsage2sr
             o3data=o3sage2sr
             thdata=thsage2sr
            end
            (instorder(ipan) eq 'SAGE2SS'): begin
             ydata=ysage2ss
             xdata=xsage2ss
             o3data=o3sage2ss
             thdata=thsage2ss
            end
            (instorder(ipan) eq 'ILASSR'): begin
             ydata=yilassr
             xdata=xilassr
             o3data=o3ilassr
             thdata=thilassr
            end
            (instorder(ipan) eq 'ILASSS'): begin
             ydata=yilasss
             xdata=xilasss
             o3data=o3ilasss
             thdata=thilasss
            end
            else: begin
            goto,noprof
            end
          endcase
          ydata=reform(ydata)
          xdata=reform(xdata)
          o3data=reform(o3data)
          thdata=reform(thdata)
; 
; remove bad xdata and sort in longitude
;
          index=where(xdata ge 0. and xdata le 360.)
          if index(0) ne -1 then begin
             ydata=reform(ydata(index))
             xdata=reform(xdata(index))
             o3data=reform(o3data(index,*))
             thdata=reform(thdata(index,*))
          endif
          xsave=xdata
          xdata=0.*thdata
          result=size(thdata)
          ndim=result(0)
          if ndim eq 1 then goto,oneprof
          nprof=result(1)
          nl=result(2)
          for i=0,nl-1 do begin
              sindex=sort(xsave)
              xdata(*,i)=xsave(sindex)
              o3data(*,i)=o3data(sindex,i)
              thdata(*,i)=thdata(sindex,i)
          endfor
          xlabels=string(ydata(sindex),format='(f4.1)')+' N'
          !type=2^2+2^3
          xmn=xorig(ipan)
          xmx=xmn+xlen
          ymn=yorig(1)
          ymx=ymn+ylen
          set_viewport,xmn,xmx,ymn,ymx
          ylab='Theta'
          level=4.+0.5*findgen(10)
          nlvls=n_elements(level)
          col1=10+(findgen(nlvls)/nlvls)*mcolor
          contour,o3data*1.e6,xdata,thdata,levels=level,/cell_fill,$
                  title='Slice through '+xlabels(0),c_color=col1,$
                  min_value=-999.,xticks=4,xrange=[0.,360.],yrange=[600.,1600.],$
                  ytitle=ylab,xtitle='Longitude'
          contour,o3data*1.e6,xdata,thdata,levels=level,/follow,/overplot,color=0
;         oplot,xdata,thdata,psym=4,symsize=0.5
;
; closest longitude-altitude slice of UKMO data
;
          result=moment(ydata)
          y0=result(0)
          oneprof:
          if ndim eq 1 then y0=ydata(0)
          index=where(abs(alat-y0) le 7.5,nlat)
          pv1=reform(pv2(index(0),*,*))
          p1=reform(p2(index(0),*,*))
          mark1=reform(mark2(index(0),*,*))
          for j=1,nlat-1 do begin
          llat=index(j)
          pv1=pv1+reform(pv2(llat,*,*))
          p1=p1+reform(p2(llat,*,*))
          mark1=mark1+reform(mark2(llat,*,*))
          endfor
          pv1=pv1/float(nlat)
          p1=p1/float(nlat)
          mark1=mark1/float(nlat)
          t1=0.*mark1
          for k=0,nth-1 do t1(*,k)=th(k)*((p1(*,k)/1000.)^(.286))
          contour,mark1,alon,th,levels=[0.1],/follow,$
                  /overplot,color=0,thick=4,c_labels=[0]
          index=where(mark1 gt 0.)
;         if index(0) ne -1 then oplot,xz2d(index),yz2d(index),psym=3,color=0.
          contour,mark1,alon,th,levels=[-0.1],/follow,$
                  /overplot,color=mcolor,thick=4,c_labels=[0]
          index=where(mark1 lt 0.)
;         if index(0) ne -1 then oplot,xz2d(index),yz2d(index),psym=3,color=mcolor

          plots,0.,rtheta,/data
          plots,360.,rtheta,/data,/continue,color=mcolor
          imin=min(level)
          imax=max(level)
          ymnb=ymn -cbaryoff
          ymxb=ymnb+cbarydel
          set_viewport,xmn,xmx,ymnb,ymxb
          !type=2^2+2^3+2^6
          plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax]
          ybox=[0,10,10,0,0]
          x2=imin
          dx=(imax-imin)/float(nlvls)
          for j=0,nlvls-1 do begin
              xbox=[x2,x2,x2+dx,x2+dx,x2]
              polyfill,xbox,ybox,color=col1(j)
              x2=x2+dx
          endfor
;
; interpolate marker to ozone field
;
          marko3=0.*o3data
          for k=0,nl-1 do begin
              for i=0,nprof-1 do begin
                  slon=xdata(i,k)
                  stheta=thdata(i,k)
                  for kk=1,nth-1 do begin
                      kp1=kk-1
                      xtheta=th(kk)
                      xthetap1=th(kp1)
                      if stheta ge xtheta and slon le xthetap1 then begin
                         zscale=(stheta-xtheta)/(xthetap1-xtheta)
                         for ii=0,nc-1 do begin
                             ip1=ii+1
                             if ii eq nc-1 then ip1=0
                             xlon=alon(ii)
                             xlonp1=alon(ip1)
                             if ii eq nc-1 then xlonp1=xlonp1+360.
                             if slon ge xlon and slon le xlonp1 then begin
                                xscale=(slon-xlon)/(xlonp1-xlon)
                                mj1=mark1(ii,kk)+xscale*(mark1(ip1,kk)-mark1(ii,kk))
                                mjp1=mark1(ii,kp1)+xscale*(mark1(ip1,kp1)-mark1(ii,kp1))
                                marko3(i,k)=mj1+zscale*(mjp1-mj1)
if mark1(ii,kk) lt 0. or mark1(ip1,kk) lt 0. or mark1(ii,kp1) lt 0. or mark1(ip1,kp1) lt 0. then marko3(i,k)=-1.0
                                goto,jumpout
                             endif
                         endfor
                      endif
                  endfor
                  jumpout:
              endfor
          endfor
;
; plot profiles
;
          !type=2^2+2^3
          xmn=xorig(ipan)
          xmx=xmn+xlen
          ymn=yorig(2)
          ymx=ymn+ylen
          set_viewport,xmn,xmx,ymn,ymx
          plot,4.+findgen(6),th,yrange=[600.,1600.],/nodata,title=instorder(ipan)+' Profiles',ytitle=ylab,$
               xtitle='Ozone (ppmv)'
          a=findgen(9)*(2*!pi/8.)
          usersym,cos(a),sin(a),/fill
          for iprof=0L,nprof-1L do begin
              o3_prof=reform(o3data(iprof,*))*1.e6
              th_prof=reform(thdata(iprof,*))
              x_prof=reform(xdata(iprof,*))
              index=where(o3_prof gt 0.)
              if index(0) ne -1 then begin
                 o3_prof=o3_prof(index)
                 th_prof=th_prof(index)
                 oplot,o3_prof,th_prof,psym=0
              endif
              index=where(o3data gt 0. and marko3 lt 0.)
              if index(0) ne -1 then $
                 oplot,o3data(index)*1.e6,thdata(index),color=mcolor*.9,psym=8,symsize=.75
              index=where(o3data gt 0. and marko3 gt 0.1)
              if index(0) ne -1 then $
                 oplot,o3data(index)*1.e6,thdata(index),color=mcolor*.3,psym=8,symsize=.75
          endfor
          noprof:
         endfor
stop
if setplot eq 'ps' then device, /close
goto, jump
end
