pro rd_dc8_diag,ifile,nx,ny,nz,tdc8,xdc8,ydc8,zdc8,pdc8,thdc8,$
    pvdc8,udc8,vdc8,qdc8,msfdc8,qdfdc8,mrkdc8,vpdc8,sfdc8
close,2
openr,2,ifile
idate=0L
readf,2,idate
print,'idate =',idate
nx=0L & ny=0L & nz=0L
readf,2,nx
tdc8=fltarr(nx)
readf,2,tdc8
readf,2,nx,ny,nz
xdc8=fltarr(nx,ny,nz)
ydc8=fltarr(nx,ny,nz)
zdc8=fltarr(nx,ny,nz)
pdc8=fltarr(nx,ny,nz)
thdc8=fltarr(nx,ny,nz)
pvdc8=fltarr(nx,ny,nz)
udc8=fltarr(nx,ny,nz)
vdc8=fltarr(nx,ny,nz)
qdc8=fltarr(nx,ny,nz)
msfdc8=fltarr(nx,ny,nz)
qdfdc8=fltarr(nx,ny,nz)
mrkdc8=fltarr(nx,ny,nz)
vpdc8=fltarr(nx,ny,nz)
sfdc8=fltarr(nx,ny,nz)
readf,2,xdc8,ydc8,zdc8,pdc8,thdc8,pvdc8,udc8,vdc8,$
        qdc8,msfdc8,qdfdc8,mrkdc8,vpdc8,sfdc8
close,2
return
end
