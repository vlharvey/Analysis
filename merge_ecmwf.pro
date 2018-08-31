;
; merge winds with PV,T,Z,RH,W,O3
;
loadct,38
mcolor=byte(!p.color)
device,decompose=0
nlvls=30L
col1=1+indgen(nlvls)*mcolor/nlvls

spawn,'ls ../Datfiles/*12Z.dat',ifiles
spawn,'ls ../Datfiles/*12Z_uv.dat',wfiles
nfile=n_elements(ifiles)
for n=0,nfile-1 do begin
    ifile=ifiles(n)
    wfile=wfiles(n)
    nc=0L & nr=0L & nl=0L
    close,1
    openr,1,ifile,/f77,ERROR=err
    print,'Opening ',ifile
    readu,1,nc,nr,nl
    alon=fltarr(nc)
    alat=fltarr(nr)
    press=fltarr(nl)
    pv=fltarr(nc,nr,nl)
    gp=fltarr(nc,nr,nl)
    tp=fltarr(nc,nr,nl)
    uu=fltarr(nc,nr,nl)
    vv=fltarr(nc,nr,nl)
    ww=fltarr(nc,nr,nl)
    sh=fltarr(nc,nr,nl)
    oz=fltarr(nc,nr,nl)
    readu,1,alon,alat,press
    readu,1,pv,gp,tp,uu,vv,ww,sh,oz
;
; read U and V
;
    close,1
    openr,1,wfile,/f77,ERROR=err
    readu,1,nc,nr,nl
    readu,1,alon,alat,press
    readu,1,uu,vv
    close,1
;
; write merged file
;
    result=strsplit(ifile,'.',/extract)
    ofile='..'+result(0)+'.sav'
    save,file=ofile,nc,nr,nl,alon,alat,press,pv,gp,tp,uu,vv,ww,sh,oz

idate=strsplit(result(0),'_',/extract)
date=idate(3)+idate(1)+idate(2)
erase
map_set,0,180,0,/contin,/grid,/noeras,title=date
dum=reform(oz(*,*,18))
zdum=reform(gp(*,*,18))
contour,dum,alon,alat,nlevels=30,/cell_fill,c_color=col1,/overplot,/noeras
contour,dum,alon,alat,nlevels=15,/follow,c_color=0,c_labels=0,/overplot,/noeras
contour,zdum,alon,alat,nlevels=30,/follow,c_color=mcolor,c_labels=0,thick=2,/overplot,/noeras
map_set,0,180,0,/contin,/grid,/noeras

endfor
end
