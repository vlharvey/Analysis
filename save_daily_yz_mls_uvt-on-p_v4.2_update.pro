;
; save daily zonal mean U, V, T on p from gridded data
;
@stddat
@kgmt
@ckday
@kdate

loadct,39
mcolor=byte(!p.color)
device,decompose=0
nlvls=18
col1=(findgen(nlvls)/float(nlvls))*mcolor
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
smonth=['J','F','M','A','M','J','J','A','S','O','N','D']
mdir='/atmos/aura6/data/MLS_data/Datfiles_Grid/'
;start_year=[2007,2008,2009,2010,2011,2012,2013,2014,2015]
;start_date=[-27, -21, -24, -24, -26, -27, -34, -28,-42]
;end_date=[66, 65, 61, 61, 64, 61, 64, 80]
;nyear=n_elements(start_year)

restore,'MLS_YZ_UVT_2004-2017.sav.old
dfs_old=DFS_ALL		; FLOAT     = Array[4276]
sdate_old=SDATE_ALL	; STRING    = Array[4276]
tbar_old=TBAR_ALL	; FLOAT     = Array[4276, 96, 55]
ubar_old=UBAR_ALL	; FLOAT     = Array[4276, 96, 55]
vbar_old=VBAR_ALL	; FLOAT     = Array[4276, 96, 55]
zbar_old=ZBAR_ALL	; FLOAT     = Array[4276, 96, 55]
kdayold=n_elements(sdate_old)
maxdate=max(sdate_old)
lstmn=strmid(maxdate,4,2)
lstdy=strmid(maxdate,6,2)
lstyr=strmid(maxdate,0,4)
print,'Last Day ',lstyr,lstmn,lstdy

ledmn=8
leddy=12
ledyr=2018
lstday=0
ledday=0
;
z = stddat(lstmn,lstdy,lstyr,lstday)
z = stddat(ledmn,leddy,ledyr,ledday)
if ledday lt lstday then stop,' Wrong dates! '
kday=ledday-lstday+1L
;
; Compute initial Julian date
;
iyr = lstyr
idy = lstdy
imn = lstmn
z = kgmt(imn,idy,iyr,iday)
;iday = iday - 1	; start tomorrow
icount=0L
;
; longitude grid
;
dx=15.
nc=long(360./dx)+1
longrid=dx*findgen(nc)
nr=91L
latgrid=-90.+2.*findgen(nr)
dy=latgrid(1)-latgrid(0)
;
; loop over days (start with the day after maxdate)
;
jump: iday = iday + 1
      kdate,float(iday),iyr,imn,idy
      ckday,iday,iyr

; --- Test for end condition and close windows.
      z = stddat(imn,idy,iyr,ndays)
      if ndays lt lstday then stop,' starting day outside range '
      if ndays gt ledday then goto,saveit
      syr=string(FORMAT='(I4)',iyr)
      smn=string(FORMAT='(I2.2)',imn)
      sdy=string(FORMAT='(I2.2)',idy)
      sdate=syr+smn+sdy
      if icount eq 0 then begin
         sdate_all=strarr(kday)
         dfs_all=fltarr(kday)
      endif
      sdate_all(icount)=sdate

      if iday ge 60 and iday le 258 then dfs=julday(long(smn),long(sdy),long(syr))-julday(6,21,long(syr))
      if iday lt 60 then dfs=julday(long(smn),long(sdy),long(syr))-julday(12,21,long(syr)-1L)
      if iday gt 258 then dfs=julday(long(smn),long(sdy),long(syr))-julday(12,21,long(syr))
      print,sdate,' ',dfs
      dfs_all(icount)=dfs
;
; restore MLS on this day
;
      dum=findfile(mdir+'MLS_grid5_ALL_U_V_v4.2_'+sdate+'.sav')
      if dum(0) eq '' then goto,skipmls
      restore,mdir+'MLS_grid5_ALL_U_V_v4.2_'+sdate+'.sav'
;
; declare arrays on first day
;
      nlv=n_elements(pmls2)
      nr=n_elements(lat)
      if icount eq 0 then begin
         ubar_all=fltarr(kday,nr,nlv)-9999.
         vbar_all=fltarr(kday,nr,nlv)-9999.
         tbar_all=fltarr(kday,nr,nlv)-9999.
         zbar_all=fltarr(kday,nr,nlv)-9999.
         pressure=pmls2
      endif
      umean=mean(u,dim=4)         ; mean over both nodes
      vmean=mean(v,dim=4)         ; mean over both nodes
      tmean=mean(t,dim=4)         ; mean over both nodes
      zmean=mean(gph,dim=4)
;
; compute zonal means
;
      ubar=mean(umean,dim=1,/nan)
      vbar=mean(vmean,dim=1,/nan)
      tbar=mean(tmean,dim=1,/nan)
      gpbar=mean(zmean,dim=1,/nan)/1000.
;
; convert geopotential height to geometric height
;
    ks=1.931853d-3
    ecc=0.081819
    gamma45=9.80
    rtd=double(180./!pi)
    dtr=1./rtd
    zbar=0.*gpbar
    for j=0L,nr-1L do begin
        sin2=sin( (lat(j)*dtr)^2.0 )
        numerator=1.0+ks*sin2
        denominator=sqrt( 1.0 - (ecc^2.0)*sin2 )
        gammas=gamma45*(numerator/denominator)
        r=6378.137/(1.006803-(0.006706*sin2))
        zbar(j,*)= (r*gpbar(j,*))/ ( (gammas/gamma45)*r - gpbar(j,*) )
    endfor
    index=where(finite(gpbar) ne 1)
    if index(0) ne -1L then zbar(index)=-9999.
;
erase
!type=2^2+2^3
contour,tbar,lat,zbar,levels=160+10*findgen(nlvls),/noerase,c_color=col1,yrange=[10,90],xrange=[-90,90],/cell_fill,title=sdate
contour,ubar,lat,zbar,levels=10+10*findgen(nlvls),/noerase,color=mcolor,/overplot
contour,ubar,lat,zbar,levels=-200+10*findgen(nlvls),/overplot,c_linestyle=5
;
; retain all daily zonal means
;
    ubar_all(icount,*,*)=ubar
    vbar_all(icount,*,*)=vbar
    tbar_all(icount,*,*)=tbar
    zbar_all(icount,*,*)=zbar

skipmls:
icount=icount+1L
goto,jump

saveit:
sdate_new=[sdate_old,sdate_all(0:icount-1L)]
dfs_new=[dfs_old,dfs_all(0:icount-1L)]
ubar_new=fltarr(icount+kdayold,nr,nlv)
tbar_new=fltarr(icount+kdayold,nr,nlv)
vbar_new=fltarr(icount+kdayold,nr,nlv)
zbar_new=fltarr(icount+kdayold,nr,nlv)
for i=0L,kdayold-1L do begin
    ubar_new(i,*,*)=ubar_old(i,*,*)
    tbar_new(i,*,*)=tbar_old(i,*,*)
    vbar_new(i,*,*)=vbar_old(i,*,*)
    zbar_new(i,*,*)=zbar_old(i,*,*)
endfor
for i=0,icount-1L do begin
    ubar_new(kdayold+i,*,*)=ubar_all(i,*,*)
    tbar_new(kdayold+i,*,*)=tbar_all(i,*,*)
    vbar_new(kdayold+i,*,*)=vbar_all(i,*,*)
    zbar_new(kdayold+i,*,*)=zbar_all(i,*,*)
    print,'adding '+sdate_all(i),max(ubar_all(i,*,*)),i
endfor
;
; rename
;
sdate_all=sdate_new
dfs_all=dfs_new
ubar_all=ubar_new
tbar_all=tbar_new
vbar_all=vbar_new
zbar_all=zbar_new

save,file='MLS_YZ_UVT_2004-2017.sav',sdate_all,dfs_all,vbar_all,ubar_all,tbar_all,zbar_all,lat,pressure

end
