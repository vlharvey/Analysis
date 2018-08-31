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
;
l3atread,clo,'/aura6/data/MLS_data/Datfiles/MLS_L3AT_SCLO_D0405.V0005_C02_PROD',append=append,verbose=verbose
print,'read clo'
stop
l3atread,gp,'/aura6/data/MLS_data/Datfiles/MLS_L3AT_SGPH_D0405.V0005_C02_PROD'
print,'read gp'
l3atread,h2o,'/aura6/data/MLS_data/Datfiles/MLS_L3AT_SH2O_D0405.V0006_C03_PROD'
print,'read h2o'
l3atread,hno3,'/aura6/data/MLS_data/Datfiles/MLS_L3AT_SHNO3_D0405.V0006_C01_PROD'
print,'read hno3'
l3atread,tp,'/aura6/data/MLS_data/Datfiles/MLS_L3AT_STEMP_D0405.V0005_C02_PROD'
print,'read tp'
l3atread,o3,'/aura6/data/MLS_data/Datfiles/MLS_L3AT_SO3_205_D0405.V0005_C02_PROD'
print,'read o3'
help,/struct,o3
;
; O3              STRUCT    = -> <Anonymous> Array[1318]
;** Structure <1ef0b8>, 15 tags, length=360, data length=360, refs=1:
;   SATID           BYTE      Array[4]
;   RECTYP          BYTE      Array[2]
;   INSTID          BYTE      Array[12]
;   RECCNT          BYTE      Array[8]
;   SPARE           INT              2			; index of lowest altitude
;   TOTPTS          LONG                37
;   NDATPT          LONG                37
;   FSTIND          LONG                 2
;   RECTIM          LONG      Array[2]
;   LAT             FLOAT           19.1366
;   LONG            FLOAT           242.619
;   SOLTIME         FLOAT           16.1973
;   SOLZEN          FLOAT           58.4308
;   QU              FLOAT     Array[37]
;   ERR             FLOAT     Array[37]
;
mtime=o3.SOLTIME
mlon=o3.LONG
mlat=o3.LAT
;
; The standard pressure level values in millibars are given by:
; P(i) = 1000.0 * (10**(-i/6)), i=0,1,...36
; while the standard altitude level values in kilometers are given by:
; Z(i) = 5 * i, i <= 12
; Z(i) = 60 + (i - 12) * 3, 13 <= i <= 32
; Z(i) = 120 + (i - 32) * 10, 33 <= i <= 50.
;
press=1000.*10.^(-1.*findgen(37)/6.)
p0=press(o3(0).spare)
mpress=p0*10.^(-1.*findgen(37)/6.)		; base of profile is given by o3.spare
mo3=o3.qu
mo3err=o3.err
stop
print,mpress
rpress=0.
read,'Enter pressure level ',rpress
index=where(long(mpress*1000./1000.) eq long(rpress*1000./1000.))
ilev=index(0)
spress=strtrim(string(mpress(ilev)),2)
mo3=reform(mo3(ilev,*))*1.e6
mo3err=reform(mo3err(ilev,*))*1.e6
;mtp=tp.qu
;mtp=reform(mtp(ilev,*))

    erase
    !type=2^2+3^2
    xmn=xorig(0)
    xmx=xorig(0)+xlen
    ymn=yorig(0)
    ymx=yorig(0)+ylen
    set_viewport,xmn,xmx,ymn,ymx
    map_set,0,0,0,/contin,/grid,/noeras,title='MLS Ozone at '+spress
    index=where(mo3 gt 0.,no3)
    if index(0) ne -1 then begin
       o3_mls=mo3(index)
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

    !type=2^2+3^2
    xmn=xorig(1)
    xmx=xorig(1)+xlen
    ymn=yorig(1)
    ymx=yorig(1)+ylen
    set_viewport,xmn,xmx,ymn,ymx
;   map_set,0,0,0,/contin,/grid,/noeras,title='MLS Temperature'
;   index=where(mo3 gt 0.,no3)
;   if index(0) ne -1 then begin
;      o3_mls=mtp(index)
;      x_mls=mlon(index)
;      y_mls=mlat(index)
;      imax=max(o3_mls)
;      imin=min(o3_mls)
;      for i=0,no3-1 do $
;          oplot,[x_mls(i),x_mls(i)],[y_mls(i),y_mls(i)],psym=8,$
;                color=((imax-o3_mls(i))/(imax-imin))*mcolor
;      ymnb=yorig(1)-cbaryoff
;      ymxb=ymnb+cbarydel
;      set_viewport,xmn,xmx,ymnb,ymxb
;      !type=2^2+2^3+2^6
;      plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],$
;            xtitle='(K)',charsize=1.5
;      ybox=[0,10,10,0,0]
;      x1=imin
;      dx=(imax-imin)/float(nlvls)
;      for j=0,nlvls-1 do begin
;          xbox=[x1,x1,x1+dx,x1+dx,x1]
;          polyfill,xbox,ybox,color=col1(j)
;          x1=x1+dx
;      endfor
;   endif

end
