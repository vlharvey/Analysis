pro rd_ilas_merged_data,yymmdd,icount,thal,xhal,yhal,thhal,$
    dsat,phal,zhal,ptrhal,ztrhal,thtrhal,clhal,mhal,h2ohal,$
    o3hal,no2hal,eh2ohal,eo3hal,eno2hal
t=0.
x=0.
y=0.
th=0.
xs=0.
pth=0.
zth=0.
ptr=0.
ztr=0.
thtr=0.
cl=0.
m=0L
h2o=0.
o3=0.
no2=0.
eh2o=0.
eo3=0.
eno2=0.
yymmdd=0L
icount=0L
readf,4,yymmdd
readf,4,icount
if icount eq 0L then return
thal=fltarr(icount)
xhal=fltarr(icount)
yhal=fltarr(icount)
thhal=fltarr(icount)
dsat=fltarr(icount)
phal=fltarr(icount)
zhal=fltarr(icount)
ptrhal=fltarr(icount)
ztrhal=fltarr(icount)
thtrhal=fltarr(icount)
clhal=fltarr(icount)
mhal=lonarr(icount)
h2ohal=fltarr(icount)
o3hal=fltarr(icount)
no2hal=fltarr(icount)
eh2ohal=fltarr(icount)
eo3hal=fltarr(icount)
eno2hal=fltarr(icount)
for i=0L,icount-1L do begin
    readf,4,t,y,x,th,xs,pth,zth,ptr,ztr,thtr,cl,m
    readf,4,no2,o3,h2o
    readf,4,eno2,eo3,eh2o
    thal(i)=t
    xhal(i)=x
    yhal(i)=y
    thhal(i)=th
    dsat(i)=xs
    phal(i)=pth
    zhal(i)=zth
    ptrhal(i)=ptr
    ztrhal(i)=ztr
    thtrhal(i)=thtr
    clhal(i)=cl
    mhal(i)=m
    h2ohal(i)=h2o
    o3hal(i)=o3
    no2hal(i)=no2
    eh2ohal(i)=eh2o
    eo3hal(i)=eo3
    eno2hal(i)=eno2
endfor
return
end