;
; use subroutines provided by DAAC to read UARS MLS data
;
setplot='x'
read,'setplot?',setplot
loadct,38
mcolor=byte(!p.color)
mcolor=fix(mcolor)
device,decompose=0
if mcolor eq 0 then mcolor=255
nlvls=20
col1=1+mcolor*findgen(20)/nlvls
icmm1=mcolor-1
icmm2=mcolor-2
!noeras=1
a=findgen(6)*(2*!pi/6.)
usersym,cos(a),sin(a),/fill
nxdim=700
nydim=700
xorig=[0.15,0.15]
yorig=[0.60,0.15]
xlen=0.7
ylen=0.3
cbaryoff=0.02
cbarydel=0.02
if setplot ne 'ps' then begin
   lc=mcolor
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
;
; version 4 from BADC
;
;l3atread,tp,'/aura6/data/MLS_data/Datfiles/MLS_L3AT_STEMP_D2103.V0004_C01_PROD'
;l3atread,o3,'/aura6/data/MLS_data/Datfiles/MLS_L3AT_SO3_205_D2103.V0004_C01_PROD'
;
; version 5 from Goddard DAAC
; The UARS pressure array is defined as:
; P = 1000 * 10^(-i/6) where i=0,1,2,... (indices of vertical dimension)
;
infile='/aura6/data/MLS_data/Datfiles/MLS_L3AT_SCLO_D2710.V0005_C02_PROD'
read_3at, x, h, s, FILE = infile, SWAP = swap
s = size(x[0].data) ; s[1] = size of vertical dimension for data
pclo = 10.0^(3-findgen(s[1])/6)
clodata=x.data
cloqual=x.quality

infile='/aura6/data/MLS_data/Datfiles/MLS_L3AT_SGPH_D2710.V0005_C02_PROD'
read_3at, x, h, s, FILE = infile, SWAP = swap
s = size(x[0].data)
pgp = 10.0^(3-findgen(s[1])/6)
gpdata=x.data
gpqual=x.quality

infile='/aura6/data/MLS_data/Datfiles/MLS_L3AT_SHNO3_D2710.V0006_C05_PROD'
read_3at, x, h, s, FILE = infile, SWAP = swap
s = size(x[0].data)
phno3 = 10.0^(3-findgen(s[1])/6)
hno3data=x.data
hno3qual=x.quality

infile='/aura6/data/MLS_data/Datfiles/MLS_L3AT_STEMP_D2710.V0005_C02_PROD'
read_3at, x, h, s, FILE = infile, SWAP = swap
s = size(x[0].data)
ptemp = 10.0^(3-findgen(s[1])/6)
tempdata=x.data
tempqual=x.quality

infile='/aura6/data/MLS_data/Datfiles/MLS_L3AT_SO3_205_D2710.V0005_C02_PROD'
read_3at, x, h, s, FILE = infile, SWAP = swap
mtime=24.*x.time(1)/86400000.
mlat=x.lat
mlon=x.lon
s = size(x[0].data)
Po3 = 10.0^(3-findgen(s[1])/6)
o3data = x.data
o3qual = x.quality

infile='/aura6/data/MLS_data/Datfiles/MLS_L3TP_SPARAM_L3TP_D2710.V0005_C02_PROD'
read_3tp, x, h, s, FILE = infile, SWAP = swap
help,names='*data'
help,names='*qual'
help,names='p*'

print,po3
rpress=0.
read,'Enter pressure level ',rpress
index=where(long(po3*1000./1000.) eq long(rpress*1000./1000.))
ilev=index(0)
spress=strtrim(string(po3(ilev)),2)
mo3data=reform(o3data(ilev,*))*1.e6
mo3qual=reform(o3qual(ilev,*))*1.e6

    erase
    !type=2^2+3^2
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,0,0,0,/contin,/grid,/noeras,title='UARS MLS Ozone at '+spress+' hPa'
    index=where(mo3data gt 0.,no3)
    if index(0) ne -1 then begin
       o3_mls=mo3data(index)
       x_mls=mlon(index)
       y_mls=mlat(index)
       imax=max(o3_mls)
       imin=min(o3_mls)
       for i=0,no3-1 do $
           oplot,[x_mls(i),x_mls(i)],[y_mls(i),y_mls(i)],psym=8,$
                 color=((imax-o3_mls(i))/(imax-imin))*mcolor
       ymnb=yorig(0)-cbaryoff
       ymxb=ymnb+cbarydel
       set_viewport,xmn,xmx,ymnb,ymxb
       !type=2^2+2^3+2^6
       plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],$
             xtitle='(ppmv)',charsize=1.5
       ybox=[0,10,10,0,0]
       x1=imin
       dx=(imax-imin)/float(nlvls)
       for j=0,nlvls-1 do begin
           xbox=[x1,x1,x1+dx,x1+dx,x1]
           polyfill,xbox,ybox,color=col1(j)
           x1=x1+dx
       endfor
    endif

index=where(long(ptemp*1000./1000.) eq long(rpress*1000./1000.))
ilev=index(0)
spress=strtrim(string(ptemp(ilev)),2)
mtempdata=reform(tempdata(ilev,*))
mtempqual=reform(tempqual(ilev,*))

    !type=2^2+3^2
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,0,0,0,/contin,/grid,/noeras,title='UARS MLS Temperature '+spress+' hPa'
    index=where(mo3data gt 0.,no3)
    if index(0) ne -1 then begin
       o3_mls=mtempdata(index)
       x_mls=mlon(index)
       y_mls=mlat(index)
       imax=max(o3_mls)
       imin=min(o3_mls)
       for i=0,no3-1 do $
           oplot,[x_mls(i),x_mls(i)],[y_mls(i),y_mls(i)],psym=8,$
                 color=((imax-o3_mls(i))/(imax-imin))*mcolor
       ymnb=yorig(1)-cbaryoff
       ymxb=ymnb+cbarydel
       set_viewport,xmn,xmx,ymnb,ymxb
       !type=2^2+2^3+2^6
       plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],$
             xtitle='(K)',charsize=1.5
       ybox=[0,10,10,0,0]
       x1=imin
       dx=(imax-imin)/float(nlvls)
       for j=0,nlvls-1 do begin
           xbox=[x1,x1,x1+dx,x1+dx,x1]
           polyfill,xbox,ybox,color=col1(j)
           x1=x1+dx
       endfor
    endif

end
