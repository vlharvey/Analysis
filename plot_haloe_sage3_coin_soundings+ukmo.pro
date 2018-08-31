;
; plot difference between physically coincident 
; HALOE and SAGE III satellite soundings
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

re=40000./2./!pi
rad=double(180./!pi)
dtr=double(!pi/180.)
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
read,'setplot=',setplot
nxdim=750 & nydim=750
xorig=[0.15,0.15,0.55]
yorig=[0.70,0.10,0.10]
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
lstmn=9 & lstdy=9 & lstyr=2 & lstday=0
ledmn=9 & leddy=16 & ledyr=2 & ledday=0
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
      if ndays gt ledday then goto,plotit
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
         theta=800.
;        print,th
;        read,'Enter theta ',theta
         index=where(theta eq th)
         if index(0) eq -1 then stop,'Invalid theta level '
         thlev=index(0)
         stheta=strcompress(string(fix(theta)),/remove_all)
      endif
      pv1=transpose(pv2(*,*,thlev))
      p1=transpose(p2(*,*,thlev))
      mark1=transpose(mark2(*,*,thlev))
      t1=theta*((p1/1000.)^(.286))
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
;
; retain coincident soundings
;
      if icount eq 0L then begin
         ncoin=500L & nlev=300L & dxc=500.
         xcoinhal=-9999.+fltarr(ncoin)
         ycoinhal=-9999.+fltarr(ncoin)
         zcoinhal=-9999.+fltarr(ncoin,nlev)
         pcoinhal=-9999.+fltarr(ncoin,nlev)
         thcoinhal=-9999.+fltarr(ncoin,nlev)
         o3coinhal=-9999.+fltarr(ncoin,nlev)
         xcoinsage3=-9999.+fltarr(ncoin)
         ycoinsage3=-9999.+fltarr(ncoin)
         zcoinsage3=-9999.+fltarr(ncoin,nlev)
         pcoinsage3=-9999.+fltarr(ncoin,nlev)
         thcoinsage3=-9999.+fltarr(ncoin,nlev)
         o3coinsage3=-9999.+fltarr(ncoin,nlev)
         hcoin=0L & scoin=0L
         pvave1=pv1
         pave1=p1
         markave1=mark1
         tave1=t1
      endif
      if icount gt 0L then begin
         pvave1=pvave1+pv1
         pave1=pave1+p1
         markave1=markave1+mark1
         tave1=tave1+t1
      endif
;
; find HALOE and SAGE III soundings that are within dxc km apart
;
      if norbits3 gt 0L and norbith gt 0L then begin
         for i=0,norbith-1L do begin
             xh=xhal(i) & yh=yhal(i)
             dxf=re*abs(xh-xsage3)*dtr*cos(yh*dtr)
             dyf=re*abs(yh-ysage3)*dtr
             dist=sqrt(dxf*dxf+dyf*dyf)
             hindex=where(dist le dxc,ncoin0)
             if hindex(0) ne -1 then begin
                for icoin=0L,ncoin0-1L do begin
                    ii=hindex(icoin)
                    xcoinsage3(scoin)=xsage3(ii)
                    ycoinsage3(scoin)=ysage3(ii)
                    zcoinsage3(scoin,0:nlevs3-1L)=zsage3(ii,*)
                    pcoinsage3(scoin,0:nlevs3-1L)=psage3(ii,*)
                    thcoinsage3(scoin,0:nlevs3-1L)=thsage3(ii,*)
                    o3coinsage3(scoin,0:nlevs3-1L)=o3sage3(ii,*)
                    scoin=scoin+1L
                    if scoin ge ncoin then stop,'increase ncoin'
                endfor
             endif
         endfor
         for i=0,norbits3-1L do begin
             xs=xsage3(i) & ys=ysage3(i)
             dxf=re*abs(xs-xhal)*dtr*cos(ys*dtr)
             dyf=re*abs(ys-yhal)*dtr
             dist=sqrt(dxf*dxf+dyf*dyf)
             sindex=where(dist le dxc,ncoin0)
             if sindex(0) ne -1 then begin
                for icoin=0L,ncoin0-1L do begin
                    ii=sindex(icoin)
                    xcoinhal(hcoin)=xhal(ii)
                    ycoinhal(hcoin)=yhal(ii)
                    zcoinhal(hcoin,0:nlevh-1L)=zhal(ii,*)
                    pcoinhal(hcoin,0:nlevh-1L)=phal(ii,*)
                    thcoinhal(hcoin,0:nlevh-1L)=thhal(ii,*)
                    o3coinhal(hcoin,0:nlevh-1L)=o3hal(ii,*)
                    hcoin=hcoin+1L
                    if hcoin ge ncoin then stop,'increase ncoin'
                endfor
             endif
         endfor
      endif
icount=icount+1L
goto,jump
           
plotit:
;
; bin in theta then average
;
nbins=61L
zbins=findgen(nbins)
xcoinhal=xcoinhal(0:hcoin-1L)
ycoinhal=ycoinhal(0:hcoin-1L)
zcoinhal=zcoinhal(0:hcoin-1L,*)
pcoinhal=pcoinhal(0:hcoin-1L,*)
thcoinhal=thcoinhal(0:hcoin-1L,*)
o3coinhal=o3coinhal(0:hcoin-1L,*)
xcoinsage3=xcoinsage3(0:scoin-1L)
ycoinsage3=ycoinsage3(0:scoin-1L)
zcoinsage3=zcoinsage3(0:scoin-1L,*)
pcoinsage3=pcoinsage3(0:scoin-1L,*)
thcoinsage3=thcoinsage3(0:scoin-1L,*)
o3coinsage3=o3coinsage3(0:scoin-1L,*)
;
; check individual profiles
;
print,hcoin,scoin
;set_viewport,.1,.45,.1,.9
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[270.,2000.],title='NH',/noeras
;for i=0L,hcoin-1L do begin
;    if ycoinhal(i) gt 0. then begin
;    index=where(o3coinhal(i,*) gt 0. and o3coinhal(i,*) lt 1.)
;    o3prof=reform(o3coinhal(i,index))*1.e6
;    thprof=reform(thcoinhal(i,index))
;    oplot,o3prof,thprof,color=mcolor*.9
;    endif
;endfor
;for i=0L,scoin-1L do begin
;    if ycoinsage3(i) gt 0. then begin
;    index=where(o3coinsage3(i,*) gt 0. and o3coinsage3(i,*) lt 1.)
;    o3prof=reform(o3coinsage3(i,index))*1.e6
;    thprof=reform(thcoinsage3(i,index))
;    oplot,o3prof,thprof
;    endif
;endfor
;set_viewport,.55,.9,.1,.9
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[270.,2000.],title='SH',/noeras
;for i=0L,hcoin-1L do begin
;    if ycoinhal(i) lt 0. then begin
;    index=where(o3coinhal(i,*) gt 0. and o3coinhal(i,*) lt 1.)
;    o3prof=reform(o3coinhal(i,index))*1.e6
;    thprof=reform(thcoinhal(i,index))
;    oplot,o3prof,thprof,color=mcolor*.9
;    endif
;endfor
;for i=0L,scoin-1L do begin
;    if ycoinsage3(i) lt 0. then begin
;    index=where(o3coinsage3(i,*) gt 0. and o3coinsage3(i,*) lt 1.)
;    o3prof=reform(o3coinsage3(i,index))*1.e6
;    thprof=reform(thcoinsage3(i,index))
;    oplot,o3prof,thprof
;    endif
;endfor
;stop

pavehalnh=fltarr(nbins)
zavehalnh=fltarr(nbins)
thavehalnh=fltarr(nbins)
o3avehalnh=fltarr(nbins)
pavehalsh=fltarr(nbins)
zavehalsh=fltarr(nbins)
thavehalsh=fltarr(nbins)
o3avehalsh=fltarr(nbins)
nhbin=0L*lonarr(nbins)
shbin=0L*lonarr(nbins)
for i=0,hcoin-1 do begin
    yh=ycoinhal(i)
    ph=reform(pcoinhal(i,*))
    zh=reform(zcoinhal(i,*))
    thh=reform(thcoinhal(i,*))
    o3h=reform(o3coinhal(i,*))
    for k=0L,nlev-1L do begin
        for ibin=0L,nbins-2L do begin
            if zbins(ibin) le zh(k) and zbins(ibin+1L) gt zh(k) and $
               o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
               if yh gt 0. then begin
               pavehalnh(ibin)=pavehalnh(ibin)+ph(k)
               zavehalnh(ibin)=zavehalnh(ibin)+zh(k)
               thavehalnh(ibin)=thavehalnh(ibin)+thh(k)
               o3avehalnh(ibin)=o3avehalnh(ibin)+o3h(k)
               nhbin(ibin)=nhbin(ibin)+1L
               goto,jumpouth
               endif
               if yh lt 0. then begin
               pavehalsh(ibin)=pavehalsh(ibin)+ph(k)
               zavehalsh(ibin)=zavehalsh(ibin)+zh(k)
               thavehalsh(ibin)=thavehalsh(ibin)+thh(k)
               o3avehalsh(ibin)=o3avehalsh(ibin)+o3h(k)
               shbin(ibin)=shbin(ibin)+1L
               goto,jumpouth
               endif
            endif
        endfor
        jumpouth:
    endfor
endfor
index=where(nhbin gt 0L)
pavehalnh(index)=pavehalnh(index)/float(nhbin(index))
zavehalnh(index)=zavehalnh(index)/float(nhbin(index))
thavehalnh(index)=thavehalnh(index)/float(nhbin(index))
o3avehalnh(index)=o3avehalnh(index)/float(nhbin(index))
index=where(shbin gt 0L)
pavehalsh(index)=pavehalsh(index)/float(shbin(index))
zavehalsh(index)=zavehalsh(index)/float(shbin(index))
thavehalsh(index)=thavehalsh(index)/float(shbin(index))
o3avehalsh(index)=o3avehalsh(index)/float(shbin(index))

zcoinsage3nh=fltarr(nbins)
pavesage3nh=fltarr(nbins)
zavesage3nh=fltarr(nbins)
thavesage3nh=fltarr(nbins)
o3avesage3nh=fltarr(nbins)
zcoinsage3sh=fltarr(nbins)
pavesage3sh=fltarr(nbins)
zavesage3sh=fltarr(nbins)
thavesage3sh=fltarr(nbins)
o3avesage3sh=fltarr(nbins)
nhbin=0L*lonarr(nbins)
shbin=0L*lonarr(nbins)
for i=0,scoin-1 do begin
    ys=ycoinsage3(i)
    ps=reform(pcoinsage3(i,*))
    zs=reform(zcoinsage3(i,*))
    ths=reform(thcoinsage3(i,*))
    o3s=reform(o3coinsage3(i,*))
    for k=0L,nlev-1L do begin
        for ibin=0L,nbins-2L do begin
            if zbins(ibin) le zs(k) and zbins(ibin+1L) gt zs(k) and $
               o3s(k) gt 0. and o3s(k) ne 1.e24 then begin
               if ys gt 0. then begin
               pavesage3nh(ibin)=pavesage3nh(ibin)+ps(k)
               zavesage3nh(ibin)=zavesage3nh(ibin)+zs(k)
               thavesage3nh(ibin)=thavesage3nh(ibin)+ths(k)
               o3avesage3nh(ibin)=o3avesage3nh(ibin)+o3s(k)
               nhbin(ibin)=nhbin(ibin)+1L
               goto,jumpouts
               endif
               if ys lt 0. then begin
               pavesage3sh(ibin)=pavesage3sh(ibin)+ps(k)
               zavesage3sh(ibin)=zavesage3sh(ibin)+zs(k)
               thavesage3sh(ibin)=thavesage3sh(ibin)+ths(k)
               o3avesage3sh(ibin)=o3avesage3sh(ibin)+o3s(k)
               shbin(ibin)=shbin(ibin)+1L
               goto,jumpouts
               endif
            endif
        endfor
        jumpouts:
    endfor
endfor
index=where(nhbin gt 0L)
pavesage3nh(index)=pavesage3nh(index)/float(nhbin(index))
zavesage3nh(index)=zavesage3nh(index)/float(nhbin(index))
thavesage3nh(index)=thavesage3nh(index)/float(nhbin(index))
o3avesage3nh(index)=o3avesage3nh(index)/float(nhbin(index))
index=where(shbin gt 0L)
pavesage3sh(index)=pavesage3sh(index)/float(shbin(index))
zavesage3sh(index)=zavesage3sh(index)/float(shbin(index))
thavesage3sh(index)=thavesage3sh(index)/float(shbin(index))
o3avesage3sh(index)=o3avesage3sh(index)/float(shbin(index))
;
; plot average profiles in each hemisphere
;
;set_viewport,.1,.45,.1,.9
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[0.,50.],title='NH',/noeras
;oplot,o3avehalnh*1.e6,zbins,color=mcolor*.9,thick=2
;oplot,o3avesage3nh*1.e6,zbins,color=mcolor,thick=2
;set_viewport,.55,.9,.1,.9
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[0.,50.],title='SH',/noeras
;oplot,o3avehalsh*1.e6,zbins,color=mcolor*.9,thick=2
;oplot,o3avesage3sh*1.e6,zbins,color=mcolor,thick=2
;stop
;
; percent differences in ozone
;
index=where(o3avesage3nh gt 0. and o3avehalnh gt 0.)
pavesage3nh=pavesage3nh(index)
zavesage3nh=zavesage3nh(index)
thavesage3nh=thavesage3nh(index)
o3avesage3nh=o3avesage3nh(index)
o3avehalnh=o3avehalnh(index)
nho3diff=100.*(o3avehalnh-o3avesage3nh)/o3avesage3nh
index=where(o3avesage3sh gt 0. and o3avehalsh gt 0.)
pavesage3sh=pavesage3sh(index)
zavesage3sh=zavesage3sh(index)
thavesage3sh=thavesage3sh(index)
o3avehalsh=o3avehalsh(index)
o3avesage3sh=o3avesage3sh(index)
sho3diff=100.*(o3avehalsh-o3avesage3sh)/o3avesage3sh

pvave1=pvave1/float(icount)
pave1=pave1/float(icount)
markave1=markave1/float(icount)
tave1=tave1/float(icount)
pv=0.*fltarr(nc+1,nr)
pv(0:nc-1,0:nr-1)=pvave1(0:nc-1,0:nr-1)
pv(nc,*)=pv(0,*)
t=0.*fltarr(nc+1,nr)
t(0:nc-1,0:nr-1)=tave1(0:nc-1,0:nr-1)
t(nc,*)=t(0,*)
mark=0.*fltarr(nc+1,nr)
mark(0:nc-1,0:nr-1)=markave1(0:nc-1,0:nr-1)
mark(nc,*)=mark(0,*)
x=fltarr(nc+1)
x(0:nc-1)=alon
x(nc)=alon(0)+360.
lon=0.*t
lat=0.*t
for i=0,nc   do lat(i,*)=alat
for j=0,nr-1 do lon(*,j)=x
daterange=strcompress(string(FORMAT='(A3,A1,I2,A2,I4,A3,A3,A1,I2,A2,I4,A3)',$
 month(lstmn-1),' ',lstdy,', ',lstyr,' - ',month(ledmn-1),' ',leddy,', ',ledyr))
datelab=strcompress(string(FORMAT='(I4,I2.2,I2.2,A1,I4,I2.2,I2.2)',$
 lstyr,lstmn,lstdy,'-',ledyr,ledmn,leddy))

if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,$
           filename='haloe_sage_coin_'+datelab+'.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
           xsize=xsize,ysize=ysize
endif

; Set plot boundaries
erase
!type=2^2+2^3
xmn=xorig(0)
xmx=xorig(0)+0.7
ymn=yorig(0)
ymx=yorig(0)+0.25
set_viewport,xmn,xmx,ymn,ymx
tmin=min(t)-10.
tmax=max(t)+10.
tint=(tmax-tmin)/(nlvls-1)
tlevel=tmin+tint*findgen(nlvls)
contour,t,x,alat,levels=tlevel,c_color=col1,/cell_fill,/noeras,$
       title='!6'+stheta+' K Temperature '+daterange,charsize=1.5,$
       xticks=6,xtitle='!6Longitude',yticks=6,ytitle='!6Latitude',$
       xtickname='!6'+['0','60','120','180','240','300','360'],$
       ytickname='!6'+['90S','60S','30S','EQ','30N','60N','90N']
contour,t,x,alat,/overplot,levels=tlevel,c_color=0,$
       c_labels=0*tlevel,/follow,/noeras
contour,t,x,alat,/overplot,levels=180.+5.*findgen(5),/follow,$
       c_color=icolmax,thick=2,/noeras,c_labels=1+0*findgen(11)
MAP_SET,0,180,0,/merc,/noeras,/contin,charsize=2
;contour,mark,x,alat,levels=[0.1],color=0,thick=5,/overplot
omin=2.0
omax=12.
if scoin gt 0 then begin
   a=findgen(8)*(2*!pi/8.)
   usersym,cos(a),sin(a),/fill
   oplot,xcoinsage3,ycoinsage3,psym=8,color=mcolor
   a=findgen(9)*(2*!pi/8.)
   usersym,cos(a),sin(a)
   oplot,xcoinsage3,ycoinsage3,psym=8,color=mcolor*.9
endif
if hcoin gt 0 then begin
   a=findgen(3)*(2*!pi/3.)
   usersym,cos(a),sin(a),/fill
   oplot,xcoinhal,ycoinhal,psym=8,color=mcolor
   a=findgen(4)*(2*!pi/3.)
   usersym,cos(a),sin(a)
   oplot,xcoinhal,ycoinhal,psym=8,color=mcolor*.2
endif

; horizontal temperature color bar
ymnb=yorig(0)-cbaryoff
ymxb=ymnb+cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[min(tlevel),max(tlevel)],[0,0],yrange=[0,10],$
      xrange=[min(tlevel),max(tlevel)],charsize=1.5
ybox=[0,10,10,0,0]
x1=min(tlevel)
dx=(max(tlevel)-min(tlevel))/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor
;
; NH HALOE and SAGE III ozone percent difference
;
!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+0.3
ymn=yorig(1)
ymx=ymn+0.4
set_viewport,xmn,xmx,ymn,ymx
plot,[-50.,50.],[10,50],yrange=[10,50],/nodata,$
      xrange=[-50.,50.],charsize=1.5,ytitle='!6Altitude (km)',$
      xtitle='!6Ozone Percent Difference',title='!6Northern Hemisphere'
plots,0,10
plots,0,50,/continue,linestyle=5
plots,10,10
plots,10,50,/continue,linestyle=3
plots,-10,10
plots,-10,50,/continue,linestyle=3
oplot,nho3diff,zbins,thick=3
index=where(ycoinhal gt 0.,nhal)
snhal=strtrim(nhal,2)
index=where(ycoinsage3 gt 0.,nsage3)
snsage3=strtrim(nsage3,2)
xyouts,10.,48.,'SAGE III ('+snsage3+')',/data,charsize=1.2
xyouts,10.,46.,'HALOE ('+snhal+')',/data,charsize=1.2
;
; SH HALOE and SAGE III ozone percent difference
;
!type=2^2+2^3
xmn=xorig(2)
xmx=xorig(2)+0.3
ymn=yorig(2)
ymx=ymn+0.4
set_viewport,xmn,xmx,ymn,ymx
plot,[-50.,50.],[10,50],yrange=[10,50],/nodata,$
      xrange=[-50.,50.],charsize=1.5,ytitle='!6Altitude (km)',$
      xtitle='!6Ozone Percent Difference',title='!6Southern Hemisphere'
plots,0,10
plots,0,50,/continue,linestyle=5
plots,10,10
plots,10,50,/continue,linestyle=3
plots,-10,10
plots,-10,50,/continue,linestyle=3
oplot,sho3diff,zbins,thick=3
index=where(ycoinhal lt 0.,nhal)
snhal=strtrim(nhal,2)
index=where(ycoinsage3 lt 0.,nsage3)
snsage3=strtrim(nsage3,2)
xyouts,10.,48.,'SAGE III ('+snsage3+')',/data,charsize=1.2
xyouts,10.,46.,'HALOE ('+snhal+')',/data,charsize=1.2

if setplot eq 'x' then begin
   save=assoc(3,bytarr(nxdim,nydim))
   img=bytarr(nxdim,nydim)
   img(0,0)=TVRD(0,0,nxdim,nydim)
   write_gif,'haloe_sage_coin_'+datelab+'.gif',img
endif
if setplot eq 'ps' then device, /close
end
