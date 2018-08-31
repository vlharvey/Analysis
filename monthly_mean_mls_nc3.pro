;
; store monthly mean
;
@rd_mls_nc3
@write_mls_nc3

loadct,39
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
device,decompose=0
mcolor=byte(!p.color)
nlvls=20L
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
PI2=6.2831853071796
DTR=PI2/360.
RADEA=6.37E6
syear=['2004','2005','2006','2007','2008','2009','2010','2011','2012','2013','2014']
nyear=n_elements(syear)
smon=['01','02','03','04','05','06','07','08','09','10','11','12']
nmon=n_elements(smon)
set_plot,'ps'
setplot='ps'
read,'setplot= ',setplot
if setplot ne 'ps' then begin
   set_plot,'x'
   !p.background=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=255
endif
;
; get file listing
;
dir='/Volumes/earth/aura6/data/MLS_data/Datfiles_Grid/MLS_grid_theta_'

for iyear=0L,nyear-1L do begin
for imon=0L,nmon-1L do begin
ifiles=file_search(dir+syear(iyear)+smon(imon)+'??.nc3',count=nfile)
print,syear(iyear),smon(imon),nfile
if nfile eq 0L then goto,jumpmon
;
; loop over files
;
icount=0L
FOR n=0l,nfile-1l DO BEGIN
    result=strsplit(ifiles(n),'.',/extract)
    result2=result(0)
    result3=strsplit(result2,'_',/extract)
    sdate=result3(-1)
    print,sdate
    ifile=dir+sdate+'.nc3'
    rd_mls_nc3,ifile,nc,nr,nth,alon,alat,th,pv2,p2,$
       u2,v2,qdf2,mark2,co2,z2,sf2,h2o2,markco2,iflag
    if iflag ne 0L then goto,jumpstep
    tmp2=0.*p2
    for k=0L,nth-1L do tmp2(*,*,k)=th(k)*(p2(*,*,k)/1000.)^0.286
;
; monthly means
;
if icount eq 0L then begin
   pv2mean=pv2
   p2mean=p2
   g2mean=z2
   u2mean=u2
   v2mean=v2
   markco2mean=markco2
   qdf2mean=qdf2
   mark2mean=mark2
   sf2mean=sf2
   h2o2mean=h2o2
   co2mean=co2
   num=0.*pv2
   index=where(co2 ne 0. and z2 ne 0.)
   num(index)=num(index)+1.
endif
if icount gt 0L then begin
   index=where(co2 ne 0. and z2 ne 0.)
   pv2mean(index)=pv2mean(index)+pv2(index)
   p2mean(index)=p2mean(index)+p2(index)
   g2mean(index)=g2mean(index)+z2(index)
   u2mean(index)=u2mean(index)+u2(index)
   v2mean(index)=v2mean(index)+v2(index)
   markco2mean(index)=markco2mean(index)+markco2(index)
   qdf2mean(index)=qdf2mean(index)+qdf2(index)
   mark2mean(index)=mark2mean(index)+mark2(index)
   sf2mean(index)=sf2mean(index)+sf2(index)
   h2o2mean(index)=h2o2mean(index)+h2o2(index)
   co2mean(index)=co2mean(index)+co2(index)
   num(index)=num(index)+1.
endif

index=where(co2 eq 0. or z2 eq 0.)
if index(0) ne -1L then begin
   pv2(index)=0./0.
   p2(index)=0./0.
   z2(index)=0./0.
   u2(index)=0./0.
   v2(index)=0./0.
   markco2(index)=0./0.
   qdf2(index)=0./0.
   mark2(index)=0./0.
   sf2(index)=0./0.
   h2o2(index)=0./0.
   co2(index)=0./0.
endif

markzm=mean(mark2,dim=2,/Nan)
uzm=mean(u2,dim=2,/Nan)
gzm=mean(z2,dim=2,/Nan)/1000.
pzm=mean(p2,dim=2,/Nan)
markcozm=mean(markco2,dim=2,/Nan)
h2ozm=mean(h2o2,dim=2,/Nan)*1.e6
cozm=mean(co2,dim=2,/Nan)*1.e6
tzm=0.*pzm
for k=0L,nth-1L do tzm(*,k)=th(k)*(pzm(*,k)/1000.)^.286
thzm=tzm*(1000./pzm)^0.286
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
nlvls=31L
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
contour,uzm,alat,gzm,levels=-150.+10.*findgen(31),/noeras,xrange=[-90.,90],yrange=[10.,90.],charsize=2,c_color=col1,/cell_fill,title=sdate,xtitle='Latitude',ytitle='Geopotential Height (km)',xticks=6,color=0
contour,uzm,alat,gzm,levels=-150.+10.*findgen(15),/noeras,/overplot,/follow,color=mcolor,c_linestyle=5
;contour,qzm,alat,gzm,levels=-15.+findgen(15),/noeras,/overplot,/follow,color=mcolor*.9,c_linestyle=5
contour,uzm,alat,gzm,levels=10.+10.*findgen(15),/noeras,/overplot,/follow,color=0
contour,markzm,alat,gzm,levels=[0.1,0.5,0.9],/noeras,/overplot,/follow,color=0,thick=15
loadct,0
contour,markcozm,alat,gzm,levels=[0.1,0.5,0.9],/noeras,/overplot,/follow,color=150,thick=10
loadct,39
;contour,h2ozm,alat,gzm,levels=1.+0.5*findgen(10),/noeras,/overplot,/follow,color=250
;contour,cozm,alat,gzm,levels=0.1+0.5*findgen(10),/noeras,/overplot,/follow,color=250
contour,thzm,alat,gzm,levels=reverse(th(0:nth-1:2)),/follow,thick=3,/overplot,c_annotation=strcompress(long(reverse(th(0:nth-1:2))),/remove_all)
contour,tzm,alat,gzm,levels=[150.],/follow,thick=3,/overplot,color=0.1*mcolor
contour,tzm,alat,gzm,levels=[160.],/follow,thick=3,/overplot,color=0.15*mcolor
contour,tzm,alat,gzm,levels=[170.],/follow,thick=3,/overplot,color=0.2*mcolor
contour,tzm,alat,gzm,levels=[180.],/follow,thick=3,/overplot,color=0.3*mcolor
contour,tzm,alat,gzm,levels=[190.],/follow,thick=3,/overplot,color=0.35*mcolor
contour,tzm,alat,gzm,levels=[200.],/follow,thick=3,/overplot,color=0.4*mcolor
contour,tzm,alat,gzm,levels=[210.],/follow,thick=3,/overplot,color=0.5*mcolor
contour,tzm,alat,gzm,levels=[220.],/follow,thick=3,/overplot,color=0.6*mcolor
contour,tzm,alat,gzm,levels=[230.],/follow,thick=3,/overplot,color=0.65*mcolor
contour,tzm,alat,gzm,levels=[240.],/follow,thick=3,/overplot,color=0.7*mcolor
contour,tzm,alat,gzm,levels=[250.],/follow,thick=3,/overplot,color=0.75*mcolor
contour,tzm,alat,gzm,levels=[260.],/follow,thick=3,/overplot,color=0.8*mcolor
contour,tzm,alat,gzm,levels=[270.],/follow,thick=3,/overplot,color=0.9*mcolor
contour,tzm,alat,gzm,levels=[280.],/follow,thick=3,/overplot,color=0.95*mcolor
contour,tzm,alat,gzm,levels=[290.],/follow,thick=3,/overplot,color=mcolor
wait,.5

icount=icount+1L
jumpstep:
endfor	; loop over files
;
; average
;
index=where(num gt 0.)
pv2mean(index)=pv2mean/num(index)
p2mean(index)=p2mean(index)/num(index)
g2mean(index)=g2mean(index)/num(index)
u2mean(index)=u2mean(index)/num(index)
v2mean(index)=v2mean(index)/num(index)
markco2mean(index)=markco2mean(index)/num(index)
qdf2mean(index)=qdf2mean(index)/num(index)
mark2mean(index)=mark2mean(index)/num(index)
sf2mean(index)=sf2mean(index)/num(index)
h2o2mean(index)=h2o2mean(index)/num(index)
co2mean(index)=co2mean(index)/num(index)
index=where(num eq 0.)
if index(0) ne -1L then begin
   pv2mean(index)=0./0.
   p2mean(index)=0./0.
   g2mean(index)=0./0.
   u2mean(index)=0./0.
   v2mean(index)=0./0.
   markco2mean(index)=0./0.
   qdf2mean(index)=0./0.
   mark2mean(index)=0./0.
   sf2mean(index)=0./0.
   h2o2mean(index)=0./0.
   co2mean(index)=0./0.
endif

pv2zmean=mean(pv2mean,dim=2,/Nan)
p2zmean=mean(p2mean,dim=2,/Nan)
g2zmean=mean(g2mean,dim=2,/Nan)/1000.
u2zmean=mean(u2mean,dim=2,/Nan)
v2zmean=mean(v2mean,dim=2,/Nan)
markco2zmean=mean(markco2mean,dim=2,/Nan)
qdf2zmean=mean(qdf2mean,dim=2,/Nan)
mark2zmean=mean(mark2mean,dim=2,/Nan)
sf2zmean=mean(sf2mean,dim=2,/Nan)
h2o2zmean=mean(h2o2mean,dim=2,/Nan)
co2zmean=mean(co2mean,dim=2,/Nan)

yyyymm=strmid(sdate,0,6)
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
         device,/landscape,bits=8,filename='monthly_mean_mls_yz_'+yyyymm+'.ps'
         device,/color
         device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                xsize=xsize,ysize=ysize
         !p.thick=2.0                   ;Plotted lines twice as thick
         !p.charsize=2.0
      endif
erase
xmn=xorig(0)
xmx=xorig(0)+xlen
ymn=yorig(0)
ymx=yorig(0)+ylen
set_viewport,xmn,xmx,ymn,ymx
!type=2^2+2^3
nlvls=21L
col1=1+(indgen(nlvls)/float(nlvls))*mcolor
contour,u2zmean,alat,g2zmean,levels=-100.+10.*findgen(21),/noeras,xrange=[-90.,90],yrange=[10.,100.],title=yyyymm,charsize=2,c_color=col1,/cell_fill,xtitle='Latitude',xticks=6,ytitle='Geopotential Height (km)',color=0
contour,u2zmean,alat,g2zmean,levels=-100.+10.*findgen(10),/noeras,/overplot,/follow,color=mcolor,c_linestyle=5
contour,u2zmean,alat,g2zmean,levels=10.+10.*findgen(10),/noeras,/overplot,/follow,color=0
contour,mark2zmean,alat,g2zmean,levels=[0.1,0.5,0.9],/noeras,/overplot,/follow,color=0,thick=15
loadct,0
contour,markco2zmean,alat,g2zmean,levels=[0.1,0.5,0.9],/noeras,/overplot,/follow,color=150,thick=10
loadct,39
tzm=0.*p2zmean
for k=0L,nth-1L do tzm(*,k)=th(k)*(p2zmean(*,k)/1000.)^.286
thzm=tzm*(1000./p2zmean)^0.286
contour,tzm,alat,g2zmean,levels=[150.],/follow,thick=3,/overplot,color=0.1*mcolor
contour,tzm,alat,g2zmean,levels=[160.],/follow,thick=3,/overplot,color=0.15*mcolor
contour,tzm,alat,g2zmean,levels=[170.],/follow,thick=3,/overplot,color=0.2*mcolor
contour,tzm,alat,g2zmean,levels=[180.],/follow,thick=3,/overplot,color=0.3*mcolor
contour,tzm,alat,g2zmean,levels=[190.],/follow,thick=3,/overplot,color=0.35*mcolor
contour,tzm,alat,g2zmean,levels=[200.],/follow,thick=3,/overplot,color=0.4*mcolor
contour,tzm,alat,g2zmean,levels=[210.],/follow,thick=3,/overplot,color=0.5*mcolor
contour,tzm,alat,g2zmean,levels=[220.],/follow,thick=3,/overplot,color=0.6*mcolor
contour,tzm,alat,g2zmean,levels=[230.],/follow,thick=3,/overplot,color=0.65*mcolor
contour,tzm,alat,g2zmean,levels=[240.],/follow,thick=3,/overplot,color=0.7*mcolor
contour,tzm,alat,g2zmean,levels=[250.],/follow,thick=3,/overplot,color=0.75*mcolor
contour,tzm,alat,g2zmean,levels=[260.],/follow,thick=3,/overplot,color=0.8*mcolor
contour,tzm,alat,g2zmean,levels=[270.],/follow,thick=3,/overplot,color=0.9*mcolor
contour,tzm,alat,g2zmean,levels=[280.],/follow,thick=3,/overplot,color=0.95*mcolor
contour,tzm,alat,g2zmean,levels=[290.],/follow,thick=3,/overplot,color=mcolor
contour,thzm,alat,gzm,levels=[1000.,2000.,3000.,4000.,5000.,6000.],/follow,thick=3,/overplot,c_annotation=strcompress([1000,2000,3000,4000,5000,6000],/remove_all)

omin=-100.
omax=100.
set_viewport,xmn,max(xorig)+xlen,ymn-0.12,ymn-0.12+0.01
!type=2^2+2^3+2^6
plot,[omin,omax],[0,0],yrange=[0,10],xrange=[omin,omax],xtitle='MLS Zonal Mean Wind (m/s)',/noeras,xstyle=1,color=0,charsize=2,charthick=2
ybox=[0,10,10,0,0]
x1=omin
dx=(omax-omin)/float(nlvls)
for j=0,nlvls-1 do begin
    xbox=[x1,x1,x1+dx,x1+dx,x1]
    polyfill,xbox,ybox,color=col1(j)
    x1=x1+dx
endfor

ofile=dir+yyyymm+'.nc3'
write_mls_nc3,ofile,nc,nr,nth,alon,alat,th,pv2mean,p2mean,u2mean,v2mean,qdf2mean,mark2mean,co2mean,g2mean,sf2mean,h2o2mean,markco2mean

if setplot ne 'ps' then stop
if setplot eq 'ps' then begin
   device,/close
   spawn,'convert -trim monthly_mean_mls_yz_'+yyyymm+'.ps -rotate -90 monthly_mean_mls_yz_'+yyyymm+'.jpg'
endif

jumpmon:
endfor	; loop over months
endfor	; loop over years
end
