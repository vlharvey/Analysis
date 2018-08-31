;
; plot entire 14 years in 1 longitude-time section
;
loadct,38
device,decompose=0
mcolor=byte(!p.color)
icolmax=byte(!p.color)
icolmax=fix(icolmax)
a=findgen(8)*(2*!pi/8.)
usersym,2*cos(a),2*sin(a),/fill
nxdim=800
nydim=800
xorig=[0.2]
yorig=[0.2]
xlen=0.7
ylen=0.7
cbaryoff=0.12
cbarydel=0.02
set_plot,'x'
setplot='x'
read,'setplot=',setplot
if setplot ne 'ps' then begin
   lc=icolmax
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
pi2 = 6.2831853071796
dtr=pi2/360.
re=6.37E3
dir='/aura2/harvey/Hovmoller/Datfiles/'
ifiles=[$
'ukmo_jan_01_92-dec_31_92_nc3_xt.sav',$
'ukmo_jan_01_93-dec_31_93_nc3_xt.sav',$
'ukmo_jan_01_94-dec_31_94_nc3_xt.sav',$
'ukmo_jan_01_95-dec_31_95_nc3_xt.sav',$
'ukmo_jan_01_96-dec_31_96_nc3_xt.sav',$
'ukmo_jan_01_97-dec_31_97_nc3_xt.sav',$
'ukmo_jan_01_98-dec_31_98_nc3_xt.sav',$
'ukmo_jan_01_99-dec_31_99_nc3_xt.sav',$
'ukmo_jan_01_00-dec_31_00_nc3_xt.sav',$
'ukmo_jan_01_01-dec_31_01_nc3_xt.sav',$
'ukmo_jan_01_02-dec_31_02_nc3_xt.sav',$
'ukmo_jan_01_03-dec_31_03_nc3_xt.sav',$
'ukmo_jan_01_04-dec_31_04_nc3_xt.sav']
nyear=n_elements(ifiles)
nday=365L
for n=0,nyear-1L do begin 
    restore,dir+ifiles(n)
    print,'restored ',ifiles(n)
    nth=n_elements(th2)
    nr=n_elements(YMIDS)
    nc=n_elements(alon)
    if n eq 0L then begin
       uxtall=fltarr(nc,nday,nyear)
       tmpxtall=fltarr(nc,nday,nyear)
       msfxtall=fltarr(nc,nday,nyear)
       markxtall=fltarr(nc,nday,nyear)
       uxtmean=fltarr(nc,nday)
       tmpxtmean=fltarr(nc,nday)
       msfxtmean=fltarr(nc,nday)
       markxtmean=fltarr(nc,nday)
       sfileall=strarr(nday*nyear)
       rlat=0.
       print,ymids
       read,'Enter desired latitude ',rlat
       index=where(ymids eq rlat)
       ilat=index(0)
       ralt=0.
       print,th2
       read,'Enter desired altitude ',ralt
       index=where(th2 eq ralt)
       ialt=index(0)
    endif
    index=where(strmid(sfile,0,6) ne 'feb_29',nfile)
    uxtall(*,*,n)=uxt(*,index,ilat,ialt)
    tmpxtall(*,*,n)=tmpxt(*,index,ilat,ialt)
    msfxtall(*,*,n)=msfxt(*,index,ilat,ialt)
    markxtall(*,*,n)=markxt(*,index,ilat,ialt)
    uxtmean=uxtmean+uxt(*,index,ilat,ialt)
    tmpxtmean=tmpxtmean+tmpxt(*,index,ilat,ialt)
    msfxtmean=msfxtmean+msfxt(*,index,ilat,ialt)
    markxtmean=markxtmean+markxt(*,index,ilat,ialt)
    sfileall(n*nday:((n+1L)*nday)-1L)=sfile(index)
endfor
;
; deviation from time mean in Temperature and MSF
;
tmpxtmean=tmpxtmean/float(nyear)
msfxtmean=msfxtmean/float(nyear)
tprxt=-9999.+0.*tmpxtall
msfprxt=-9999.+0.*msfxtall
for n=0,nyear-1L do begin
for j=0,nday-1L do begin
for i=0,nc-1L do begin
    if tmpxtall(i,j,n) ne 0. then begin
       tprxt(i,j,n)=tmpxtall(i,j,n)-tmpxtmean(i,j)
       msfprxt(i,j,n)=msfxtall(i,j,n)-msfxtmean(i,j)
    endif
endfor
endfor
endfor
;
; reform tprxt to be a 2-D array over entire time period
;
tprxtall=fltarr(nc,nday*nyear)
msfprxtall=fltarr(nc,nday*nyear)
for n=0L,nyear-1L do tprxtall(*,n*nday:((n+1L)*nday)-1L)=tprxt(*,*,n)
for n=0L,nyear-1L do msfprxtall(*,n*nday:((n+1L)*nday)-1L)=msfprxt(*,*,n)
;
; plot Hov at ilat and ialt
;
sth=strcompress(string(fix(th2(ialt))),/remove_all)
if ymids(ilat) eq 0. then slat='Eq'
if ymids(ilat) gt 0. then slat=strcompress(string(ymids(ilat)),/remove_all)+'N'
if ymids(ilat) lt 0. then slat=strcompress(string(ymids(ilat)),/remove_all)+'S'
if setplot eq 'ps' then begin
   lc=0
   set_plot,'ps'
   xsize=nxdim/100.
   ysize=nydim/100.
   !p.font=0
   device,font_size=9
   device,/landscape,bits=8,filename='hov_Mprmark_'+sth+'K_'+slat+'_uars.ps'
   device,/color
   device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize
endif
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
!type=2^2+2^3
set_viewport,xmn,xmx,ymn,ymx
mtitle='MetO MSF-MSFavg '+sth+' K '+slat
plt=reform(msfprxtall,nc,nfile*nyear)
index=where(plt eq 0.)
if index(0) ne -1L then plt(index)=-9999./0.
plt=smooth(plt,10,/NaN,/edge_truncate)
imin=-5000.
imax=5000.
print,sth,'  ',slat,'  ',imin,imax
if abs(imin) eq 0. and abs(imax) eq 0. then goto,jump2
nlev=11
col1=1.0+(findgen(nlev)/nlev)*mcolor
cint=(imax-imin)/(nlev-1.)
level=imin+cint*findgen(nlev)
index=where(strmid(sfileall,0,6) eq 'jan_01',nytick)
contour,plt,alon,findgen(nfile*nyear),xrange=[0.,360.],/fill,$
        /cell_fill,yrange=[0,nfile*nyear-1L],xstyle=1,ystyle=1,xticks=6,$
        yticks=nytick-1,ytickv=index,ytickname=sfileall(index),$
        xtitle='!6Longitude',ytitle='!6Time',c_color=col1,$
        title=mtitle,/noeras,levels=level,charsize=2,min_value=-9999.
;contour,plt,alon,findgen(nfile),/overplot,/follow,levels=level,$
;                   c_color=0,c_labels=0*level,/noeras
;contour,plt1,alon,findgen(nfile),/overplot,/follow,levels=[-0.01],$
;                   c_color=0,c_labels=0,thick=2,/noeras
;contour,plt1,alon,findgen(nfile),/overplot,/follow,levels=[0.01],$
;                   c_color=mcolor,c_labels=0,thick=2,/noeras
;index=where(plt1 lt 0.)
;if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=0,symsize=0.1
;index=where(plt1 gt 0.)
;if index(0) ne -1L then oplot,x2d(index),y2d(index),psym=8,color=mcolor,symsize=0.1
;
; start parcel at the GM and loop over days
;
;xold=0.
;oplot,[xold,xold],[0,0],psym=8,symsize=0.75
;for nn=0L,nfile-1L do begin
;
; daily zonal wind at parcel location
;
;    xindex=where(abs(xold-alon) eq min(abs(xold-alon)))
;    uu=uplt(xindex(0),nn)
;    dkm=uu*86400./1000.
;    dx=re*cos(ymids(ilat)*dtr)*360.*dtr               ; km around latitude circle
;    xnew=xold+ (dkm/dx)*360.
;    if xnew gt 360. then xnew=xnew-360.
;    if xnew lt 0. then xnew=xnew+360.
;    if uu gt 0. then oplot,[xnew,xnew],[nn,nn],psym=8,color=mcolor,symsize=0.75
;    if uu lt 0. then oplot,[xnew,xnew],[nn,nn],psym=8,color=0,symsize=0.75
;    xold=xnew
;endfor
;xyouts,xmn,ymn-0.08,'Anticyclone (black)',charsize=2,/normal,color=lc
;xyouts,xmn+0.45,ymn-0.08,'Polar Vortex (white)',charsize=2,/normal,color=lc
ymnb=yorig-cbaryoff
ymxb=ymnb +cbarydel
set_viewport,xmn,xmx,ymnb,ymxb
!type=2^2+2^3+2^6
plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,charsize=1.5
ybox=[0,10,10,0,0]
x1=imin
dx=(imax-imin)/float(nlev)
for jj=0,nlev-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(jj)
    x1=x1+dx
endfor
if setplot eq 'ps' then begin
   device, /close
   spawn,'convert -trim hov_Mprmark_'+sth+'K_'+slat+'_uars.ps '+$
         '-rotate -90 hov_Mprmark_'+sth+'K_'+slat+'_uars.jpg'
endif
jump2:
end
