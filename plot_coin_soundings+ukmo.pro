;
; plot difference between SAGE III and other 
; physically coincident satellite soundings
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
lstmn=7 & lstdy=15 & lstyr=2 & lstday=0
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
;
; retain coincident soundings
;
      if icount eq 0L then begin
         ncoin=1000L & nlev=300L & dxc=300.
         icoinsage3=-9999.+fltarr(ncoin)
         xcoinsage3=-9999.+fltarr(ncoin)
         ycoinsage3=-9999.+fltarr(ncoin)
         zcoinsage3=-9999.+fltarr(ncoin,nlev)
         pcoinsage3=-9999.+fltarr(ncoin,nlev)
         thcoinsage3=-9999.+fltarr(ncoin,nlev)
         o3coinsage3=-9999.+fltarr(ncoin,nlev)
         xcoinhal=-9999.+fltarr(ncoin)
         ycoinhal=-9999.+fltarr(ncoin)
         zcoinhal=-9999.+fltarr(ncoin,nlev)
         pcoinhal=-9999.+fltarr(ncoin,nlev)
         thcoinhal=-9999.+fltarr(ncoin,nlev)
         o3coinhal=-9999.+fltarr(ncoin,nlev)
         xcoinsage2=-9999.+fltarr(ncoin)
         ycoinsage2=-9999.+fltarr(ncoin)
         zcoinsage2=-9999.+fltarr(ncoin,nlev)
         pcoinsage2=-9999.+fltarr(ncoin,nlev)
         thcoinsage2=-9999.+fltarr(ncoin,nlev)
         o3coinsage2=-9999.+fltarr(ncoin,nlev)
         xcoinpoam3=-9999.+fltarr(ncoin)
         ycoinpoam3=-9999.+fltarr(ncoin)
         zcoinpoam3=-9999.+fltarr(ncoin,nlev)
         pcoinpoam3=-9999.+fltarr(ncoin,nlev)
         thcoinpoam3=-9999.+fltarr(ncoin,nlev)
         o3coinpoam3=-9999.+fltarr(ncoin,nlev)
         scoin3=0L & hcoin=0L & scoin2=0L & pcoin3=0L
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
      if norbits3 eq 0L then goto,jump
      for is3=0,norbits3-1L do begin
          xs3=xsage3(is3)
          ys3=ysage3(is3)
          zs3=reform(zsage3(is3,*))
          ps3=reform(psage3(is3,*))
          ths3=reform(thsage3(is3,*))
          o3s3=reform(o3sage3(is3,*))
;
; SAGE III/HALOE coincidences
;
          if norbith gt 0L then begin
             for ihal=0L,norbith-1L do begin
                 xh=xhal(ihal)
                 yh=yhal(ihal)
                 yave=(yh+ys3)/2.0
                 dxf=re*abs(xh-xs3)*dtr*cos(yave*dtr)
                 dyf=re*abs(yh-ys3)*dtr
                 dist=sqrt(dxf*dxf+dyf*dyf)
                 if dist le dxc then begin
                    xcoinhal(hcoin)=xh
                    ycoinhal(hcoin)=yh
                    zcoinhal(hcoin,0:nlevh-1L)=reform(zhal(ihal,*))
                    pcoinhal(hcoin,0:nlevh-1L)=reform(phal(ihal,*))
                    thcoinhal(hcoin,0:nlevh-1L)=reform(thhal(ihal,*))
                    o3coinhal(hcoin,0:nlevh-1L)=reform(o3hal(ihal,*))
                    hcoin=hcoin+1L
                    if hcoin ge ncoin then stop,'increase ncoin'

                    icoinsage3(scoin3)=1.0
                    xcoinsage3(scoin3)=xs3
                    ycoinsage3(scoin3)=ys3
                    zcoinsage3(scoin3,0:nlevs3-1L)=zs3
                    pcoinsage3(scoin3,0:nlevs3-1L)=ps3
                    thcoinsage3(scoin3,0:nlevs3-1L)=ths3
                    o3coinsage3(scoin3,0:nlevs3-1L)=o3s3
                    scoin3=scoin3+1L
                    if scoin3 ge ncoin then stop,'increase ncoin'
                 endif
             endfor
          endif
;
; SAGE III/SAGE II coincidences
;
          if norbits2 gt 0L then begin
             for is2=0L,norbits2-1L do begin
                 xs2=xsage2(is2)
                 ys2=ysage2(is2)
                 yave=(ys2+ys3)/2.0
                 dxf=re*abs(xs2-xs3)*dtr*cos(yave*dtr)
                 dyf=re*abs(ys2-ys3)*dtr
                 dist=sqrt(dxf*dxf+dyf*dyf)
                 if dist le dxc then begin
                    xcoinsage2(scoin2)=xs2
                    ycoinsage2(scoin2)=ys2
                    zcoinsage2(scoin2,0:nlevs2-1L)=reform(zsage2(is2,*))
                    pcoinsage2(scoin2,0:nlevs2-1L)=reform(psage2(is2,*))
                    thcoinsage2(scoin2,0:nlevs2-1L)=reform(thsage2(is2,*))
                    o3coinsage2(scoin2,0:nlevs2-1L)=reform(o3sage2(is2,*))
                    scoin2=scoin2+1L
                    if scoin2 ge ncoin then stop,'increase ncoin'

                    icoinsage3(scoin3)=2.0
                    xcoinsage3(scoin3)=xs3
                    ycoinsage3(scoin3)=ys3
                    zcoinsage3(scoin3,0:nlevs3-1L)=zs3
                    pcoinsage3(scoin3,0:nlevs3-1L)=ps3
                    thcoinsage3(scoin3,0:nlevs3-1L)=ths3
                    o3coinsage3(scoin3,0:nlevs3-1L)=o3s3
                    scoin3=scoin3+1L
                    if scoin3 ge ncoin then stop,'increase ncoin'
                 endif
             endfor
          endif
;
; SAGE III/POAM III coincidences
;
          if norbitp3 gt 0L then begin
             for ip3=0L,norbitp3-1L do begin
                 xp3=xpoam3(ip3)
                 yp3=ypoam3(ip3)
                 yave=(yp3+ys3)/2.0
                 dxf=re*abs(xp3-xs3)*dtr*cos(yave*dtr)
                 dyf=re*abs(yp3-ys3)*dtr
                 dist=sqrt(dxf*dxf+dyf*dyf)
                 if dist le dxc then begin
                    xcoinpoam3(pcoin3)=xp3
                    ycoinpoam3(pcoin3)=yp3
                    zcoinpoam3(pcoin3,0:nlevp3-1L)=reform(zpoam3(ip3,*))
                    pcoinpoam3(pcoin3,0:nlevp3-1L)=reform(ppoam3(ip3,*))
                    thcoinpoam3(pcoin3,0:nlevp3-1L)=reform(thpoam3(ip3,*))
                    o3coinpoam3(pcoin3,0:nlevp3-1L)=reform(o3poam3(ip3,*))
                    pcoin3=pcoin3+1L
                    if pcoin3 ge ncoin then stop,'increase ncoin'

                    icoinsage3(scoin3)=3.0
                    xcoinsage3(scoin3)=xs3
                    ycoinsage3(scoin3)=ys3
                    zcoinsage3(scoin3,0:nlevs3-1L)=zs3
                    pcoinsage3(scoin3,0:nlevs3-1L)=ps3
                    thcoinsage3(scoin3,0:nlevs3-1L)=ths3
                    o3coinsage3(scoin3,0:nlevs3-1L)=o3s3
                    scoin3=scoin3+1L
                    if scoin3 ge ncoin then stop,'increase ncoin'
                 endif
             endfor
          endif
      endfor
      icount=icount+1L
      goto,jump
           
plotit:
if scoin3 eq 0L then stop,'no coincidences'
;
; truncate data void
;
if hcoin gt 0L then begin
xcoinhal=xcoinhal(0:hcoin-1L)
ycoinhal=ycoinhal(0:hcoin-1L)
zcoinhal=zcoinhal(0:hcoin-1L,*)
pcoinhal=pcoinhal(0:hcoin-1L,*)
thcoinhal=thcoinhal(0:hcoin-1L,*)
o3coinhal=o3coinhal(0:hcoin-1L,*)
endif
if scoin2 gt 0L then begin
xcoinsage2=xcoinsage2(0:scoin2-1L)
ycoinsage2=ycoinsage2(0:scoin2-1L)
zcoinsage2=zcoinsage2(0:scoin2-1L,*)
pcoinsage2=pcoinsage2(0:scoin2-1L,*)
thcoinsage2=thcoinsage2(0:scoin2-1L,*)
o3coinsage2=o3coinsage2(0:scoin2-1L,*)
endif
if pcoin3 gt 0L then begin
xcoinpoam3=xcoinpoam3(0:pcoin3-1L)
ycoinpoam3=ycoinpoam3(0:pcoin3-1L)
zcoinpoam3=zcoinpoam3(0:pcoin3-1L,*)
pcoinpoam3=pcoinpoam3(0:pcoin3-1L,*)
thcoinpoam3=thcoinpoam3(0:pcoin3-1L,*)
o3coinpoam3=o3coinpoam3(0:pcoin3-1L,*)
endif
if scoin3 gt 0L then begin
icoinsage3=icoinsage3(0:scoin3-1L)
xcoinsage3=xcoinsage3(0:scoin3-1L)
ycoinsage3=ycoinsage3(0:scoin3-1L)
zcoinsage3=zcoinsage3(0:scoin3-1L,*)
pcoinsage3=pcoinsage3(0:scoin3-1L,*)
thcoinsage3=thcoinsage3(0:scoin3-1L,*)
o3coinsage3=o3coinsage3(0:scoin3-1L,*)
endif
print,hcoin,scoin2,pcoin3,scoin3
;
; bin HALOE in z
;
nbins=61L
zbins=findgen(nbins)
phalnh=fltarr(nbins)
zhalnh=fltarr(nbins)
thhalnh=fltarr(nbins)
o3halnh=fltarr(nbins)
phalsh=fltarr(nbins)
zhalsh=fltarr(nbins)
thhalsh=fltarr(nbins)
o3halsh=fltarr(nbins)
nhbin=0L*lonarr(nbins)
shbin=0L*lonarr(nbins)
if hcoin gt 0L then begin
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
               phalnh(ibin)=phalnh(ibin)+ph(k)
               zhalnh(ibin)=zhalnh(ibin)+zh(k)
               thhalnh(ibin)=thhalnh(ibin)+thh(k)
               o3halnh(ibin)=o3halnh(ibin)+o3h(k)
               nhbin(ibin)=nhbin(ibin)+1L
               goto,jumpouth
               endif
               if yh lt 0. then begin
               phalsh(ibin)=phalsh(ibin)+ph(k)
               zhalsh(ibin)=zhalsh(ibin)+zh(k)
               thhalsh(ibin)=thhalsh(ibin)+thh(k)
               o3halsh(ibin)=o3halsh(ibin)+o3h(k)
               shbin(ibin)=shbin(ibin)+1L
               goto,jumpouth
               endif
            endif
        endfor
        jumpouth:
    endfor
endfor
index=where(nhbin gt 0L)
if index(0) ne -1 then begin
phalnh(index)=phalnh(index)/float(nhbin(index))
zhalnh(index)=zhalnh(index)/float(nhbin(index))
thhalnh(index)=thhalnh(index)/float(nhbin(index))
o3halnh(index)=1.e6*o3halnh(index)/float(nhbin(index))
endif
index=where(shbin gt 0L)
if index(0) ne -1 then begin
phalsh(index)=phalsh(index)/float(shbin(index))
zhalsh(index)=zhalsh(index)/float(shbin(index))
thhalsh(index)=thhalsh(index)/float(shbin(index))
o3halsh(index)=1.e6*o3halsh(index)/float(shbin(index))
endif
endif
;
; bin SAGE II in Z
;
psage2nh=fltarr(nbins)
zsage2nh=fltarr(nbins)
thsage2nh=fltarr(nbins)
o3sage2nh=fltarr(nbins)
psage2sh=fltarr(nbins)
zsage2sh=fltarr(nbins)
thsage2sh=fltarr(nbins)
o3sage2sh=fltarr(nbins)
nhbin=0L*lonarr(nbins)
shbin=0L*lonarr(nbins)
if scoin2 gt 0L then begin
for i=0,scoin2-1 do begin
    yh=ycoinsage2(i)
    ph=reform(pcoinsage2(i,*))
    zh=reform(zcoinsage2(i,*))
    thh=reform(thcoinsage2(i,*))
    o3h=reform(o3coinsage2(i,*))
    for k=0L,nlev-1L do begin
        for ibin=0L,nbins-2L do begin
            if zbins(ibin) le zh(k) and zbins(ibin+1L) gt zh(k) and $
               o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
               if yh gt 0. then begin
               psage2nh(ibin)=psage2nh(ibin)+ph(k)
               zsage2nh(ibin)=zsage2nh(ibin)+zh(k)
               thsage2nh(ibin)=thsage2nh(ibin)+thh(k)
               o3sage2nh(ibin)=o3sage2nh(ibin)+o3h(k)
               nhbin(ibin)=nhbin(ibin)+1L
               goto,jumpouts2
               endif
               if yh lt 0. then begin
               psage2sh(ibin)=psage2sh(ibin)+ph(k)
               zsage2sh(ibin)=zsage2sh(ibin)+zh(k)
               thsage2sh(ibin)=thsage2sh(ibin)+thh(k)
               o3sage2sh(ibin)=o3sage2sh(ibin)+o3h(k)
               shbin(ibin)=shbin(ibin)+1L
               goto,jumpouts2
               endif
            endif
        endfor
        jumpouts2:
    endfor
endfor
index=where(nhbin gt 0L)
if index(0) ne -1 then begin
psage2nh(index)=psage2nh(index)/float(nhbin(index))
zsage2nh(index)=zsage2nh(index)/float(nhbin(index))
thsage2nh(index)=thsage2nh(index)/float(nhbin(index))
o3sage2nh(index)=1.e6*o3sage2nh(index)/float(nhbin(index))
endif
index=where(shbin gt 0L)
if index(0) ne -1 then begin
psage2sh(index)=psage2sh(index)/float(shbin(index))
zsage2sh(index)=zsage2sh(index)/float(shbin(index))
thsage2sh(index)=thsage2sh(index)/float(shbin(index))
o3sage2sh(index)=1.e6*o3sage2sh(index)/float(shbin(index))
endif
endif
;
; bin POAM III in Z
;
ppoam3nh=fltarr(nbins)
zpoam3nh=fltarr(nbins)
thpoam3nh=fltarr(nbins)
o3poam3nh=fltarr(nbins)
ppoam3sh=fltarr(nbins)
zpoam3sh=fltarr(nbins)
thpoam3sh=fltarr(nbins)
o3poam3sh=fltarr(nbins)
nhbin=0L*lonarr(nbins)
shbin=0L*lonarr(nbins)
if pcoin3 gt 0L then begin
for i=0,pcoin3-1 do begin
    yh=ycoinpoam3(i)
    ph=reform(pcoinpoam3(i,*))
    zh=reform(zcoinpoam3(i,*))
    thh=reform(thcoinpoam3(i,*))
    o3h=reform(o3coinpoam3(i,*))
    for k=0L,nlev-1L do begin
        for ibin=0L,nbins-2L do begin
            if zbins(ibin) le zh(k) and zbins(ibin+1L) gt zh(k) and $
               o3h(k) gt 0. and o3h(k) ne 1.e24 then begin
               if yh gt 0. then begin
               ppoam3nh(ibin)=ppoam3nh(ibin)+ph(k)
               zpoam3nh(ibin)=zpoam3nh(ibin)+zh(k)
               thpoam3nh(ibin)=thpoam3nh(ibin)+thh(k)
               o3poam3nh(ibin)=o3poam3nh(ibin)+o3h(k)
               nhbin(ibin)=nhbin(ibin)+1L
               goto,jumpoutp3
               endif
               if yh lt 0. then begin
               ppoam3sh(ibin)=ppoam3sh(ibin)+ph(k)
               zpoam3sh(ibin)=zpoam3sh(ibin)+zh(k)
               thpoam3sh(ibin)=thpoam3sh(ibin)+thh(k)
               o3poam3sh(ibin)=o3poam3sh(ibin)+o3h(k)
               shbin(ibin)=shbin(ibin)+1L
               goto,jumpoutp3
               endif
            endif
        endfor
        jumpoutp3:
    endfor
endfor
index=where(nhbin gt 0L)
if index(0) ne -1 then begin
ppoam3nh(index)=ppoam3nh(index)/float(nhbin(index))
zpoam3nh(index)=zpoam3nh(index)/float(nhbin(index))
thpoam3nh(index)=thpoam3nh(index)/float(nhbin(index))
o3poam3nh(index)=1.e6*o3poam3nh(index)/float(nhbin(index))
endif
index=where(shbin gt 0L)
if index(0) ne -1 then begin
ppoam3sh(index)=ppoam3sh(index)/float(shbin(index))
zpoam3sh(index)=zpoam3sh(index)/float(shbin(index))
thpoam3sh(index)=thpoam3sh(index)/float(shbin(index))
o3poam3sh(index)=1.e6*o3poam3sh(index)/float(shbin(index))
endif
endif
;
; bin SAGE III in z for coincidences with each instrument type
;
phalsage3nh=fltarr(nbins) & psage2sage3nh=fltarr(nbins) & ppoam3sage3nh=fltarr(nbins)
zhalsage3nh=fltarr(nbins) & zsage2sage3nh=fltarr(nbins) & zpoam3sage3nh=fltarr(nbins)
thhalsage3nh=fltarr(nbins) & thsage2sage3nh=fltarr(nbins) & thpoam3sage3nh=fltarr(nbins)
o3halsage3nh=fltarr(nbins) & o3sage2sage3nh=fltarr(nbins) & o3poam3sage3nh=fltarr(nbins)
phalsage3sh=fltarr(nbins) & psage2sage3sh=fltarr(nbins) & ppoam3sage3sh=fltarr(nbins)
zhalsage3sh=fltarr(nbins) & zsage2sage3sh=fltarr(nbins) & zpoam3sage3sh=fltarr(nbins)
thhalsage3sh=fltarr(nbins) & thsage2sage3sh=fltarr(nbins) & thpoam3sage3sh=fltarr(nbins)
o3halsage3sh=fltarr(nbins) & o3sage2sage3sh=fltarr(nbins) & o3poam3sage3sh=fltarr(nbins)
nhbinhal=0L*lonarr(nbins) & nhbinsage2=fltarr(nbins) & nhbinpoam3=fltarr(nbins)
shbinhal=0L*lonarr(nbins) & shbinsage2=fltarr(nbins) & shbinpoam3=fltarr(nbins)
for i=0,scoin3-1 do begin
    itype=icoinsage3(i)
    ys=ycoinsage3(i)
    ps=reform(pcoinsage3(i,*))
    zs=reform(zcoinsage3(i,*))
    ths=reform(thcoinsage3(i,*))
    o3s=reform(o3coinsage3(i,*))
    for k=0L,nlev-1L do begin
        for ibin=0L,nbins-2L do begin
            if zbins(ibin) le zs(k) and zbins(ibin+1L) gt zs(k) and $
               o3s(k) gt 0. and o3s(k) ne 1.e24 then begin
               if ys gt 0. and itype eq 1.0 then begin
                  phalsage3nh(ibin)=phalsage3nh(ibin)+ps(k)
                  zhalsage3nh(ibin)=zhalsage3nh(ibin)+zs(k)
                  thhalsage3nh(ibin)=thhalsage3nh(ibin)+ths(k)
                  o3halsage3nh(ibin)=o3halsage3nh(ibin)+o3s(k)
                  nhbinhal(ibin)=nhbinhal(ibin)+1L
                  goto,jumpouts3
               endif
               if ys lt 0. and itype eq 1.0 then begin
                  phalsage3sh(ibin)=phalsage3sh(ibin)+ps(k)
                  zhalsage3sh(ibin)=zhalsage3sh(ibin)+zs(k)
                  thhalsage3sh(ibin)=thhalsage3sh(ibin)+ths(k)
                  o3halsage3sh(ibin)=o3halsage3sh(ibin)+o3s(k)
                  shbinhal(ibin)=shbinhal(ibin)+1L
                  goto,jumpouts3
               endif

               if ys gt 0. and itype eq 2.0 then begin
                  psage2sage3nh(ibin)=psage2sage3nh(ibin)+ps(k)
                  zsage2sage3nh(ibin)=zsage2sage3nh(ibin)+zs(k)
                  thsage2sage3nh(ibin)=thsage2sage3nh(ibin)+ths(k)
                  o3sage2sage3nh(ibin)=o3sage2sage3nh(ibin)+o3s(k)
                  nhbinsage2(ibin)=nhbinsage2(ibin)+1L
                  goto,jumpouts3
               endif
               if ys lt 0. and itype eq 2.0 then begin
                  psage2sage3sh(ibin)=psage2sage3sh(ibin)+ps(k)
                  zsage2sage3sh(ibin)=zsage2sage3sh(ibin)+zs(k)
                  thsage2sage3sh(ibin)=thsage2sage3sh(ibin)+ths(k)
                  o3sage2sage3sh(ibin)=o3sage2sage3sh(ibin)+o3s(k)
                  shbinsage2(ibin)=shbinsage2(ibin)+1L
                  goto,jumpouts3
               endif

               if ys gt 0. and itype eq 3.0 then begin
                  ppoam3sage3nh(ibin)=ppoam3sage3nh(ibin)+ps(k)
                  zpoam3sage3nh(ibin)=zpoam3sage3nh(ibin)+zs(k)
                  thpoam3sage3nh(ibin)=thpoam3sage3nh(ibin)+ths(k)
                  o3poam3sage3nh(ibin)=o3poam3sage3nh(ibin)+o3s(k)
                  nhbinpoam3(ibin)=nhbinpoam3(ibin)+1L
                  goto,jumpouts3
               endif
               if ys lt 0. and itype eq 3.0 then begin
                  ppoam3sage3sh(ibin)=ppoam3sage3sh(ibin)+ps(k)
                  zpoam3sage3sh(ibin)=zpoam3sage3sh(ibin)+zs(k)
                  thpoam3sage3sh(ibin)=thpoam3sage3sh(ibin)+ths(k)
                  o3poam3sage3sh(ibin)=o3poam3sage3sh(ibin)+o3s(k)
                  shbinpoam3(ibin)=shbinpoam3(ibin)+1L
                  goto,jumpouts3
               endif
            endif
        endfor
        jumpouts3:
    endfor
endfor
index=where(nhbinhal gt 0L)
if index(0) ne -1 then begin
phalsage3nh(index)=phalsage3nh(index)/float(nhbinhal(index))
zhalsage3nh(index)=zhalsage3nh(index)/float(nhbinhal(index))
thhalsage3nh(index)=thhalsage3nh(index)/float(nhbinhal(index))
o3halsage3nh(index)=1.e6*o3halsage3nh(index)/float(nhbinhal(index))
endif
index=where(shbinhal gt 0L)
if index(0) ne -1 then begin
phalsage3sh(index)=phalsage3sh(index)/float(shbinhal(index))
zhalsage3sh(index)=zhalsage3sh(index)/float(shbinhal(index))
thhalsage3sh(index)=thhalsage3sh(index)/float(shbinhal(index))
o3halsage3sh(index)=1.e6*o3halsage3sh(index)/float(shbinhal(index))
endif

index=where(nhbinsage2 gt 0L)
if index(0) ne -1 then begin
psage2sage3nh(index)=psage2sage3nh(index)/float(nhbinsage2(index))
zsage2sage3nh(index)=zsage2sage3nh(index)/float(nhbinsage2(index))
thsage2sage3nh(index)=thsage2sage3nh(index)/float(nhbinsage2(index))
o3sage2sage3nh(index)=1.e6*o3sage2sage3nh(index)/float(nhbinsage2(index))
endif
index=where(shbinsage2 gt 0L)
if index(0) ne -1 then begin
psage2sage3sh(index)=psage2sage3sh(index)/float(shbinsage2(index))
zsage2sage3sh(index)=zsage2sage3sh(index)/float(shbinsage2(index))
thsage2sage3sh(index)=thsage2sage3sh(index)/float(shbinsage2(index))
o3sage2sage3sh(index)=1.e6*o3sage2sage3sh(index)/float(shbinsage2(index))
endif

index=where(nhbinpoam3 gt 0L)
if index(0) ne -1 then begin
ppoam3sage3nh(index)=ppoam3sage3nh(index)/float(nhbinpoam3(index))
zpoam3sage3nh(index)=zpoam3sage3nh(index)/float(nhbinpoam3(index))
thpoam3sage3nh(index)=thpoam3sage3nh(index)/float(nhbinpoam3(index))
o3poam3sage3nh(index)=1.e6*o3poam3sage3nh(index)/float(nhbinpoam3(index))
endif
index=where(shbinpoam3 gt 0L)
if index(0) ne -1 then begin
ppoam3sage3sh(index)=ppoam3sage3sh(index)/float(shbinpoam3(index))
zpoam3sage3sh(index)=zpoam3sage3sh(index)/float(shbinpoam3(index))
thpoam3sage3sh(index)=thpoam3sage3sh(index)/float(shbinpoam3(index))
o3poam3sage3sh(index)=1.e6*o3poam3sage3sh(index)/float(shbinpoam3(index))
endif
;
; plot average profiles in each hemisphere
;
;xorig=[.0,.35,.7,.0,.35,.7]
;yorig=[.55,.55,.55,.1,.1,.1]
;xlen=0.3
;ylen=0.4
;!type=2^2+2^3
;xmn=xorig(0)
;xmx=xorig(0)+xlen
;ymn=yorig(0)
;ymx=yorig(0)+ylen
;set_viewport,xmn,xmx,ymn,ymx
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[0.,50.],title='NH HAL/S3',/noeras
;if max(o3halnh) gt 0. then begin
;   oplot,o3halnh,zbins,color=mcolor*.9,thick=2
;   oplot,o3halsage3nh,zbins,color=mcolor,thick=2
;endif
;xmn=xorig(1)
;xmx=xorig(1)+xlen
;ymn=yorig(1)
;ymx=yorig(1)+ylen
;set_viewport,xmn,xmx,ymn,ymx
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[0.,50.],title='NH S2/S3',/noeras
;if max(o3sage2nh) gt 0. then begin
;   oplot,o3sage2nh,zbins,color=mcolor*.9,thick=2
;   oplot,o3sage2sage3nh,zbins,color=mcolor,thick=2
;endif
;xmn=xorig(2)
;xmx=xorig(2)+xlen
;ymn=yorig(2)
;ymx=yorig(2)+ylen
;set_viewport,xmn,xmx,ymn,ymx
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[0.,50.],title='NH P3/S3',/noeras
;if max(o3poam3nh) gt 0. then begin
;   oplot,o3poam3nh,zbins,color=mcolor*.9,thick=2
;   oplot,o3poam3sage3nh,zbins,color=mcolor,thick=2
;endif
;xmn=xorig(3)
;xmx=xorig(3)+xlen
;ymn=yorig(3)
;ymx=yorig(3)+ylen
;set_viewport,xmn,xmx,ymn,ymx
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[0.,50.],title='SH HAL/S3',/noeras
;if max(o3halsh) gt 0. then begin
;   oplot,o3halsh,zbins,color=mcolor*.9,thick=2
;   oplot,o3halsage3sh,zbins,color=mcolor,thick=2
;endif
;xmn=xorig(4)
;xmx=xorig(4)+xlen
;ymn=yorig(4)
;ymx=yorig(4)+ylen
;set_viewport,xmn,xmx,ymn,ymx
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[0.,50.],title='SH S2/S3',/noeras
;if max(o3sage2sh) gt 0. then begin
;   oplot,o3sage2sh,zbins,color=mcolor*.9,thick=2
;   oplot,o3sage2sage3sh,zbins,color=mcolor,thick=2
;endif
;xmn=xorig(5)
;xmx=xorig(5)+xlen
;ymn=yorig(5)
;ymx=yorig(5)+ylen
;set_viewport,xmn,xmx,ymn,ymx
;plot,findgen(10),findgen(10),/nodata,xrange=[0.,12.],$
;     yrange=[0.,50.],title='SH P3/S3',/noeras
;if max(o3poam3sh) gt 0. then begin
;   oplot,o3poam3sh,zbins,color=mcolor*.9,thick=2
;   oplot,o3poam3sage3sh,zbins,color=mcolor,thick=2
;endif
;stop
;
; percent differences in ozone
;
index=where(o3halsage3nh gt 0. and o3halnh gt 0.)
if index(0) ne -1 then begin
o3halsage3nh=o3halsage3nh(index)
o3halnh=o3halnh(index)
ho3nhdiff=100.*(o3halsage3nh-o3halnh)/o3halsage3nh
endif
index=where(o3halsage3sh gt 0. and o3halsh gt 0.)
if index(0) ne -1 then begin
o3halsage3sh=o3halsage3sh(index)
o3halsh=o3halsh(index)
ho3shdiff=100.*(o3halsage3sh-o3halsh)/o3halsage3sh
endif

index=where(o3sage2sage3nh gt 0. and o3sage2nh gt 0.)
if index(0) ne -1 then begin
o3sage2sage3nh=o3sage2sage3nh(index)
o3sage2nh=o3sage2nh(index)
so3nhdiff=100.*(o3sage2sage3nh-o3sage2nh)/o3sage2sage3nh
endif
index=where(o3sage2sage3sh gt 0. and o3sage2sh gt 0.)
if index(0) ne -1 then begin
o3sage2sage3sh=o3sage2sage3sh(index)
o3sage2sh=o3sage2sh(index)
so3shdiff=100.*(o3sage2sage3sh-o3sage2sh)/o3sage2sage3sh
endif

index=where(o3poam3sage3nh gt 0. and o3poam3nh gt 0.)
if index(0) ne -1 then begin
o3poam3sage3nh=o3poam3sage3nh(index)
o3poam3nh=o3poam3nh(index)
po3nhdiff=100.*(o3poam3sage3nh-o3poam3nh)/o3poam3sage3nh
endif
index=where(o3poam3sage3sh gt 0. and o3poam3sh gt 0.)
if index(0) ne -1 then begin
o3poam3sage3sh=o3poam3sage3sh(index)
o3poam3sh=o3poam3sh(index)
po3shdiff=100.*(o3poam3sage3sh-o3poam3sh)/o3poam3sage3sh
endif

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
           filename='soundings_coin_'+datelab+'.ps'
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
tmin=min(t)
tmax=max(t)
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
if scoin3 gt 0 then begin
   a=findgen(8)*(2*!pi/8.)
   usersym,cos(a),sin(a),/fill
   oplot,xcoinsage3,ycoinsage3,psym=8,color=mcolor
   a=findgen(9)*(2*!pi/8.)
   usersym,cos(a),sin(a)
   oplot,xcoinsage3,ycoinsage3,psym=8,color=0
endif
if pcoin3 gt 0 then begin
   a=findgen(3)*(2*!pi/3.)
   usersym,cos(a),sin(a),/fill
   oplot,xcoinpoam3,ycoinpoam3,psym=8,color=mcolor
   a=findgen(4)*(2*!pi/3.)
   usersym,cos(a),sin(a)
   oplot,xcoinpoam3,ycoinpoam3,psym=8,color=mcolor*.9
endif
if hcoin gt 0 then begin
   a=findgen(3)*(2*!pi/3.)
   usersym,cos(a),sin(a),/fill
   oplot,xcoinhal,ycoinhal,psym=8,color=mcolor
   a=findgen(4)*(2*!pi/3.)
   usersym,cos(a),sin(a)
   oplot,xcoinhal,ycoinhal,psym=8,color=mcolor*.4
endif
if scoin2 gt 0 then begin
   a=findgen(8)*(2*!pi/8.)
   usersym,cos(a),sin(a),/fill
   oplot,xcoinsage2,ycoinsage2,psym=8,color=mcolor
   a=findgen(9)*(2*!pi/8.)
   usersym,cos(a),sin(a)
   oplot,xcoinsage2,ycoinsage2,psym=8,color=mcolor*.1
endif
;
; horizontal temperature color bar
;
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
; NH ozone percent differences
;
!type=2^2+2^3
xmn=xorig(1)
xmx=xorig(1)+0.3
ymn=yorig(1)
ymx=ymn+0.4
set_viewport,xmn,xmx,ymn,ymx
plot,[-50.,50.],[10,50],yrange=[10,50],/nodata,$
      xrange=[-50.,50.],charsize=1.5,ytitle='!6Altitude (km)',$
      xtitle='!6100*(SAT-SAGE III)/SAGE III',title='!6Northern Hemisphere'
plots,0,10
plots,0,50,/continue,linestyle=5
plots,10,10
plots,10,50,/continue,linestyle=3
plots,-10,10
plots,-10,50,/continue,linestyle=3
index=where(ycoinhal gt 0.,nhal)
if index(0) ne -1 then oplot,ho3nhdiff,zbins,thick=3,color=mcolor*.4
index=where(ycoinsage2 gt 0.,nsage2)
if index(0) ne -1 then oplot,so3nhdiff,zbins,thick=3,color=mcolor*.1
index=where(ycoinpoam3 gt 0.,npoam3)
if index(0) ne -1 then oplot,po3nhdiff,zbins,thick=3,color=mcolor*.9
index=where(ycoinsage3 gt 0.,nsage3)
snhal=strtrim(nhal,2)
snsage3=strtrim(nsage3,2)
snpoam3=strtrim(npoam3,2)
snsage2=strtrim(nsage2,2)
xyouts,-45.,16.,'HALOE ('+snhal+')',/data,charsize=1.2,color=mcolor*.4
xyouts,-45.,14.,'POAM III ('+snpoam3+')',/data,charsize=1.2,color=mcolor*.9
xyouts,-45.,12.,'SAGE II ('+snsage2+')',/data,charsize=1.2,color=mcolor*.1
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
      xtitle='!6100*(SAT-SAGE III)/SAGE III',title='!6Southern Hemisphere'
plots,0,10
plots,0,50,/continue,linestyle=5
plots,10,10
plots,10,50,/continue,linestyle=3
plots,-10,10
plots,-10,50,/continue,linestyle=3
index=where(ycoinhal lt 0.,nhal)
if index(0) ne -1 then oplot,ho3shdiff,zbins,thick=3,color=mcolor*.4
index=where(ycoinsage2 lt 0.,nsage2)
if index(0) ne -1 then oplot,so3shdiff,zbins,thick=3,color=mcolor*.1
index=where(ycoinpoam3 lt 0.,npoam3)
if index(0) ne -1 then oplot,po3shdiff,zbins,thick=3,color=mcolor*.9
index=where(ycoinsage3 lt 0.,nsage3)
snhal=strtrim(nhal,2)
snsage3=strtrim(nsage3,2)
snpoam3=strtrim(npoam3,2)
snsage2=strtrim(nsage2,2)
xyouts,-45.,16.,'HALOE ('+snhal+')',/data,charsize=1.2,color=mcolor*.4
xyouts,-45.,14.,'POAM III ('+snpoam3+')',/data,charsize=1.2,color=mcolor*.9
xyouts,-45.,12.,'SAGE II ('+snsage2+')',/data,charsize=1.2,color=mcolor*.1

if setplot eq 'x' then begin
   save=assoc(3,bytarr(nxdim,nydim))
   img=bytarr(nxdim,nydim)
   img(0,0)=TVRD(0,0,nxdim,nydim)
   write_gif,'soundings_coin_'+datelab+'.gif',img
endif
if setplot eq 'ps' then device, /close
end
