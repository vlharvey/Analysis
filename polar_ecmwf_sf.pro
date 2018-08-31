;
; plot ECMWF streamfunction in mercator projection
;
@stddat
@kgmt
@ckday
@kdate
@rd_poam_merged_data
@rd_ecmwf_nc2

loadct,38
mcolor=byte(!p.color)
device,decompose=0
icmm1=mcolor-1B
icmm2=mcolor-2B
!noeras=1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
nxdim=750
nydim=750
xorig=[0.15]
yorig=[0.15]
xlen=0.8
ylen=0.8
cbaryoff=0.03
cbarydel=0.02
!NOERAS=-1
SETPLOT='ps'
read,'setplot',setplot
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif

mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
dirh='/aura3/data/ECMWF_data/Datfiles/ecmwf_'
dirp='/aura3/data/POAM_data/Merged_data/poam3_'
ifile='                             '
;lstmn=12 & lstdy=2 & lstyr=2 & lstday=0
;ledmn=12 & leddy=2 & ledyr=2 & ledday=0
;
; Ask interactive questions- get starting/ending date
;
;read,' Enter starting date (month, day, year) ',lstmn,lstdy,lstyr
;read,' Enter ending date   (month, day, year) ',ledmn,leddy,ledyr
;if lstyr lt 91 then lstyr=lstyr+2000
;if ledyr lt 91 then ledyr=ledyr+2000
;if lstyr lt 1900 then lstyr=lstyr+1900
;if ledyr lt 1900 then ledyr=ledyr+1900
;if lstyr lt 1991 then stop,'Year out of range '
;if ledyr lt 1991 then stop,'Year out of range '
;z = stddat(lstmn,lstdy,lstyr,lstday)
;z = stddat(ledmn,leddy,ledyr,ledday)
;if ledday lt lstday then stop,' Wrong dates! '
;iyr = lstyr
;idy = lstdy
;imn = lstmn
;z = kgmt(imn,idy,iyr,iday)
;iday = iday - 1
;
; --- Loop here --------
;
;jump: iday = iday + 1
;      kdate,float(iday),iyr,imn,idy
;      ckday,iday,iyr
;
; test for end condition and close windows.
;
;      z = stddat(imn,idy,iyr,ndays)
;      if ndays lt lstday then stop,' starting day outside range '
;      if ndays gt ledday then stop
;
; get filenames (a file is expected every 5 days)
;
spawn,'ls -1 '+dirh+'*_12Z.nc2',ifiles
nday=n_elements(ifiles)
for n=0L,nday-1L do begin    
;
; read ECMWF
;
    result=strsplit(ifiles(n),'_',/extract)
    smon=result(2)
    sday=result(3)
    syear=result(4)
    rd_ecmwf_nc2,ifiles(n),nc,nr,nth,alon,alat,thlev,ipv,prs,msf,u,v,q,qdf,vp,sf,sh,o3,iflg

    filename=dirp+mon(long(smon)-1L)+sday+'_'+syear+'.merged'
    sdum=findfile(filename)
    pcount=0L
    if sdum(0) eq '' then goto,jumppoam
    close,4
    if sdum(0) ne '' then openr,4,filename
    rd_poam_merged_data,yymmdd,ncount,tpoam,xpoam,ypoam,thpoam,$
        xsatpoam,ysatpoam,ppoam,zpoam,ptrpoam,ztrpoam,thtrpoam,$
        clpoam,mpoam,h2opoam,pvpoam,o3poam,no2poam,aerpoam,eh2opoam,$
        eo3poam,eno2poam,eaerpoam
    close,4
    jumppoam:

    if n eq 0L then begin
       rpress=0.
       print,thlev
       read,'Enter theta level ',rpress
       index=where(long(rpress) eq long(thlev))
       klevs=index(0)
       spress=strcompress(string(rpress),/remove_all)+' K'
    endif

u1=fltarr(nc+1,nr)
v1=fltarr(nc+1,nr)
pv1=fltarr(nc+1,nr)
qdf1=fltarr(nc+1,nr)
sf1=fltarr(nc+1,nr)
alon1=fltarr(nc+1)
alon1(0:nc-1)=alon
alon1(nc)=alon(0)+360.
u1(0:nc-1,0:nr-1)=transpose(u(*,*,klevs))
v1(0:nc-1,0:nr-1)=transpose(v(*,*,klevs))
pv1(0:nc-1,0:nr-1)=transpose(ipv(*,*,klevs))
qdf1(0:nc-1,0:nr-1)=transpose(qdf(*,*,klevs))
sf1(0:nc-1,0:nr-1)=transpose(sf(*,*,klevs))
u1(nc,*)=u1(0,*)
v1(nc,*)=v1(0,*)
pv1(nc,*)=pv1(0,*)
qdf1(nc,*)=qdf1(0,*)
sf1(nc,*)=sf1(0,*)
s1=sqrt(u1^2.+v1^2.)
level=5.*findgen(25)
nlvls=26
index=where(abs(qdf1) lt 1000.)
pvmin=min(qdf1(index))
pvmax=max(qdf1(index))
pvint=(pvmax-pvmin)/nlvls
col1=1+indgen(nlvls)*mcolor/nlvls
level=pvmin+pvint*findgen(nlvls)
    !noeras=1
    erase
    !type=2^2+2^3
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,90,0,0,/stereo,/contin,/grid,title=syear+smon+sday+' ECMWF Isotachs '+spress,$
            charsize=2,/noeras
    contour,qdf1,alon1,alat,/overplot,levels=level,/fill,/cell_fill,c_color=col1,/noeras
    contour,qdf1,alon1,alat,levels=level,/follow,c_color=0,/overplot,/noeras
contour,sf1,alon1,alat,nlevels=30,/follow,/overplot,/noeras,thick=2
    map_set,90,0,0,/stereo,/contin,/grid,/noeras
index=where(thpoam eq 1000.)
if index(0) ne -1 then oplot,xpoam(index),ypoam(index),psym=8,symsize=2
    imin=min(level)
    imax=max(level)
    ymnb=ymn -cbaryoff
    ymxb=ymnb+cbarydel
    set_viewport,xmn,xmx,ymnb,ymxb
    !type=2^2+2^3+2^6
    plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras
    ybox=[0,10,10,0,0]
    x2=imin
    dx=(imax-imin)/(float(nlvls)-1)
    for j=1,nlvls-1 do begin
        xbox=[x2,x2,x2+dx,x2+dx,x2]
        polyfill,xbox,ybox,color=col1(j)
        x2=x2+dx
    endfor

stop
endfor
end
