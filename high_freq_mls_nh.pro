;
; plot anticyclone frequency over some time period
;
@rd_ukmo_nc3
@stddat
@kgmt
@ckday
@kdate
@range_ring

re=40000./2./!pi
rad=double(180./!pi)
dtr=double(!pi/180.)
earth_area=4.*!pi*re*re
hem_area=earth_area/2.0

a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
mcolor=icolmax
device,decompose=0
setplot='x'
read,'setplot=',setplot
nxdim=750 & nydim=750
xorig=[0.10]
yorig=[0.10]
cbaryoff=0.015
cbarydel=0.01
!NOERAS=-1
!p.charthick=2
if setplot ne 'ps' then begin
   lc=0
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=icolmax
endif
month=['Jan','Feb','Mar','Apr','May','Jun',$
       'Jul','Aug','Sep','Oct','Nov','Dec']
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
mno=[31,28,31,30,31,30,31,31,30,31,30,31]
nmon=['01','02','03','04','05','06','07','08','09','10','11','12']
diru='/aura3/data/UKMO_data/Datfiles/ukmo_'
ifile='                             '
lstmn=12 & lstdy=1 & lstyr=2005 & lstday=0
ledmn=1 & leddy=20 & ledyr=2006 & ledday=0
;read,' Enter starting year ',lstyr
;read,' Enter ending year ',ledyr
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
nday=ledday-lstday+1L
;
; --- Loop here --------
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr
;
; read UKMO data
;
      syr=strtrim(string(iyr),2)
      sdy=string(FORMAT='(i2.2)',idy)
      smn=string(FORMAT='(i2.2)',imn)
      uyr=strmid(syr,2,2)
      ifile=mon(imn-1)+sdy+'_'+uyr
      lfile=nmon(imn-1)+'_'+sdy+'_'+uyr
;
; test for end condition and close windows.
;
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,plotit

      rd_ukmo_nc3,diru+ifile+'.nc3',nc,nr,nth,alon,alat,th,$
                  pv2,p2,msf2,u2,v2,q2,qdf2,mark2,vp2,sf2,iflag
      if iflag eq 1 then goto,jump
      if icount eq 0L then begin
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
         hfreq=0.*mark2
         dates=strarr(nday)
      endif
      dates(icount)=lfile
;
; save anticyclone frequency
;
index=where(mark2 ne 0.)
mark2sm=0.*mark2
mark2sm(index)=mark2(index)/abs(mark2(index))
index=where(mark2sm lt 0.)
hfreq(index)=hfreq(index)+mark2sm(index)
print,ifile,max(nfreq)

icount=icount+1L
goto,jump

plotit:
for k=0L,11L do begin
    stheta=strcompress(long(th(k)),/remove_all)
;
; postscript file
;
    if setplot eq 'ps' then begin
       lc=0
       set_plot,'ps'
       xsize=nxdim/100.
       ysize=nydim/100.
       !p.font=0
       device,font_size=9
       device,/landscape,bits=8,filename='high_freq_mls_nh_'+stheta+'.ps'
       device,/color
       device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
              xsize=xsize,ysize=ysize
    endif
;
; extract MetO anticyclone info
;
    hf1=transpose(hfreq(*,*,k))
    nf1=transpose(nfreq(*,*,k))
    index=where(nf1 gt 0.)
    hf1(index)=abs(hf1(index)/float(icount))
    hf=fltarr(nc+1,nr)
    hf(0:nc-1,0:nr-1)=hf1
    hf(nc,*)=hf(0,*)

    erase
    map_set,90,-90,0,/stereo,color=0,/contin,/grid,/noeras,title=stheta,charsize=2
    contour,hf,x,alat,/follow,levels=0.1+0.1*findgen(10),color=0,thick=3,/overplot

oplot,findgen(366),30.+0.*findgen(366),psym=0,thick=4,color=0
oplot,90.+0.*findgen(91),findgen(91),psym=0,thick=4,color=0
oplot,270.+0.*findgen(91),findgen(91),psym=0,thick=4,color=0

    if setplot ne 'ps' then stop
    if setplot eq 'ps' then begin
       device, /close
       spawn,'convert -trim high_freq_mls_nh_'+stheta+'.ps -rotate -90 high_freq_mls_nh_'+stheta+'.jpg'
    endif
endfor
end
