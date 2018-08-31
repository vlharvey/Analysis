;
; reproduce Butchard and Remsberg Figure 4: 850 K PV as a function of Elat (and area % of NH) and time
; MERRA vs. MLS PV
;
@stddat
@kgmt
@ckday
@kdate
@rd_merra_nc3
@rd_mls_nc3

loadct,39
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
device,decompose=0
a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill
re=40000./2./!pi
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0
rtd=double(180./!pi)
dtr=1./rtd
nxdim=1000
nydim=700
xorig=[.15,.15]
yorig=[.6,.2]
xlen=0.7
ylen=0.35
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
nlat=73L
elatbin=-90+2.5*findgen(nlat)
delat=(elatbin(1)-elatbin(0))/2.
!noeras=1
dir='/Volumes/earth/aura6/data/MLS_data/Datfiles_Grid/MLS_grid_theta_'
dir2='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_theta_'
lstmn=11L & lstdy=1L & lstyr=2005L
ledmn=4L & leddy=1L & ledyr=2006L
lstday=0L & ledday=0L
;
; get date range
;
print, ' '
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
if lstyr lt 2000 then lstyr=lstyr+2000
if ledyr lt 2000 then ledyr=ledyr+2000
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=(ledday-lstday+1L)
sdate_all=strarr(kday)
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
      if ndays gt ledday then goto,plotit
;
; construct date string
;
      syr=strcompress(iyr,/remove_all)
      smn=string(FORMAT='(i2.2)',imn)
      sdy=string(FORMAT='(i2.2)',idy)
      sdate=syr+smn+sdy
      print,sdate
      sdate_all(icount)=sdate
;
; read data
;
      rd_merra_nc3,dir2+sdate+'.nc3',nc,nr,nth,alon,alat,th,pv2,p2,$
         u2,v2,qdf2,mark2,qv2,z2,sf2,q2,iflag
      if iflag ne 0L then goto,skipit
      merrath=th
      merrapv2=pv2
      merramark2=mark2
      rd_mls_nc3,dir+sdate+'.nc3',nc,nr,nth,alon,alat,th,pv2,p2,$
         u2,v2,qdf2,mlsmark2,co2,z2,sf2,h2o2,markco2,iflag
      if iflag ne 0L then goto,skipit

      if icount eq 0 then begin
         x2d=fltarr(nc,nr)
         y2d=fltarr(nc,nr)
         for i=0L,nc-1L do y2d(i,*)=alat
         for j=0L,nr-1L do x2d(*,j)=alon
         area=0.*y2d
         deltax=alon(1)-alon(0)
         deltay=alat(1)-alat(0)
         for j=0,nr-1 do begin
             hy=re*deltay*dtr
             dx=re*cos(alat(j)*dtr)*deltax*dtr
             area(*,j)=dx*hy    ; area of each grid point
         endfor
         ytmerrapv=fltarr(kday,nlat)
         ytmlspv=fltarr(kday,nlat)
         ytmerraarea=fltarr(ndays,nlat)
         ytmlsarea=fltarr(ndays,nlat)
      endif
;
; extract theta
;
rth=1000.
;print,th
;read,'Enter theta ',rth
sth=strcompress(long(rth),/remove_all)+'K'
index=where(th eq rth)
mlev=index(0)
mlspv=transpose(pv2(*,*,mlev))
index=where(merrath eq rth)
ilev=index(0)
merrapv=transpose(merrapv2(*,*,ilev))
; 
; check
;
;erase
;xyouts,.45,.95,sdate+' '+sth,/normal,color=0,charsize=1.5
;nlvls=30L
;col1=1+indgen(nlvls)*mcolor/nlvls
;imin=0.
;imax=mean(merrapv)*20.
;iint=(imax-imin)/nlvls
;level=imin+iint*findgen(nlvls)
;print,level
;set_viewport,.1,.45,.3,.7
;map_set,90,0,-90,/ortho,/noeras,/contin,color=0
;contour,merrapv,alon,alat,levels=level,c_color=col1,/cell_fill,title='MERRA PV',/overplot
;contour,merrapv,alon,alat,/overplot,levels=level,color=mcolor,/follow
;
;imin=0.
;imax=mean(mlspv)*20.
;iint=(imax-imin)/nlvls
;;level=imin+iint*findgen(nlvls)
;set_viewport,.55,.9,.3,.7
;map_set,90,0,-90,/ortho,/noeras,/contin,color=0
;contour,mlspv,alon,alat,levels=level,c_color=col1,/cell_fill,title='MLS PV',/overplot
;contour,mlspv,alon,alat,/overplot,levels=level,color=mcolor,/follow
;stop
;
; elat based on PV
;
          merraelatpv=calcelat2d(merrapv,alon,alat)
          mlselatpv=calcelat2d(mlspv,alon,alat)
;
; bin PV in elat
;
          for j=0L,nlat-1L do begin
              e0=elatbin(j)-delat & e1=elatbin(j)+delat
              index=where(merraelatpv ge e0 and merraelatpv lt e1)
              if n_elements(index) ge 2L then begin
                 ytmerraarea(icount,j)=total(area(index))/hem_area
                 ytmerrapv(icount,j)=mean(merrapv(index))
              endif

              index=where(mlselatpv ge e0 and mlselatpv lt e1)
              if n_elements(index) ge 2L then begin
                 ytmlsarea(icount,j)=total(area(index))/hem_area
                 ytmlspv(icount,j)=mean(mlspv(index))
              endif
          endfor
;print,ytmerrapv(icount,*)*1.e4
;stop
skipit:
          icount=icount+1L
goto,jump
plotit:
;
; xlabels
;
syear=strmid(sdate_all,0,4)
smon=strmid(sdate_all,4,2)
sday=strmid(sdate_all,6,2)
xindex=where(sday eq '01' or sday eq '15',nxticks)
xlabs=smon(xindex)+'/'+sday(xindex)
good=where(long(syear) ne 0L)
minyear=long(min(long(syear(good))))
maxyear=long(max(long(syear)))
yearlab=strcompress(maxyear,/remove_all)
if minyear ne maxyear then yearlab=strcompress(minyear,/remove_all)+'-'+strcompress(maxyear,/remove_all)
save,filename='elat_v_time_merra_pv_'+yearlab+'_'+sth+'.sav',ytmerrapv,ytmlspv,kday,elatbin,sdate_all
;
; interpolate small gaps in time
;
for k=0,nlat-1 do begin
    dlev=reform(ytmerrapv(*,k))
    for i=1,kday-1 do begin
        if dlev(i) eq 0. and dlev(i-1) ne 0. then begin
           for ii=i+1,kday-1 do begin
               naway=float(ii-i)
               if naway le 5.0 and dlev(ii) ne 0. then begin
                  dlev(i)=(naway*dlev(i-1)+dlev(ii))/(naway+1.0)
                  goto,jump1
               endif
           endfor
jump1:
        endif
    endfor
    ytmerrapv(*,k)=dlev

    dlev=reform(ytmlspv(*,k))
    for i=1,kday-1 do begin
        if dlev(i) eq 0. and dlev(i-1) ne 0. then begin
           for ii=i+1,kday-1 do begin
               naway=float(ii-i)
               if naway le 5.0 and dlev(ii) ne 0. then begin
                  dlev(i)=(naway*dlev(i-1)+dlev(ii))/(naway+1.0)
                  goto,jump2
               endif
           endfor
jump2:
        endif
    endfor
    ytmlspv(*,k)=dlev
endfor
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
         device,/landscape,bits=8,filename='elat_v_time_merra_pv_'+yearlab+'_'+sth+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.thick=2.0                   ;Plotted lines twice as thick
         !p.charsize=2.0
      endif
;
; mean MERRA PV vs elat
;
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
;ytmerraarea(icount,j)=total(area(index))/hem_area
;ytmerrapv(icount,j)=mean(merrapv(index))
ytmerrapv=ytmerrapv*1.e4
imin=0
imax=max(ytmerrapv)
nlvls=21
iint=(imax-imin)/float(nlvls)
level=imin+iint*findgen(nlvls)
col1=1+indgen(nlvls)*mcolor/nlvls
;ytmerrapv=smooth(ytmerrapv,3)
contour,ytmerrapv,findgen(kday),elatbin,levels=level,color=0,c_color=col1,/noeras,xrange=[0,kday-1],yrange=[30,90],/fill,xticks=nxticks-1,xtickv=xindex,xtickname=xlabs,ytitle='Equivalent Latitude',charsize=2,charthick=2
contour,ytmerrapv,findgen(kday),elatbin,levels=level,color=0,/noeras,/follow,/overplot,min_value=-9999.
xyouts,xmn+0.01,ymn+0.03,'MERRA',color=mcolor,charsize=2,charthick=2,/normal
;
; mean MLS PV vs elat
;
!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+xlen
ymn=yorig(1)
ymx=yorig(1)+ylen
set_viewport,xmn,xmx,ymn,ymx
ytmlspv(*,nlat-1)=-9999.
ytmlspv=ytmlspv*1.e4
contour,ytmlspv,findgen(kday),elatbin,levels=level,color=0,c_color=col1,/noeras,xrange=[0,kday-1],yrange=[30,90],/fill,xticks=nxticks-1,xtickv=xindex,xtickname=xlabs,ytitle='Equivalent Latitude',charsize=2,charthick=2
contour,ytmlspv,findgen(kday),elatbin,levels=level,color=0,/noeras,/follow,/overplot,min_value=-9999.
xyouts,xmn+0.01,ymn+0.03,'MLS',color=mcolor,charsize=2,charthick=2,/normal

omin=min(level)
omax=max(level)
set_viewport,xmn,max(xorig)+xlen,ymn-cbaryoff,ymn-cbaryoff+cbarydel
!type=2^2+2^3+2^6
plot,[omin,omax],[0,0],yrange=[0,10],xrange=[omin,omax],xtitle=yearlab+' '+sth+' Potential Vorticity (PVU)',/noeras,xstyle=1,color=0,charsize=2,charthick=2
ybox=[0,10,10,0,0]
x1=omin
dx=(omax-omin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor

;
if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim elat_v_time_merra_pv_'+yearlab+'_'+sth+'.ps -rotate -90 '+$
         'elat_v_time_merra_pv_'+yearlab+'_'+sth+'.jpg'
endif
end
