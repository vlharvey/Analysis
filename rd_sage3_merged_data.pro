;
; Read SAGE III merged theta data.
;
pro rd_sage3_merged_data,yymmdd,icount,thal,xhal,yhal,thhal,$
    dsat,phal,zhal,ptrhal,ztrhal,thtrhal,clhal,mhal,h2ohal,$
    o3hal,no2hal,extahal,sadhal,eh2ohal,eo3hal,eno2hal,eextahal,esadhal
t=0.
x=0.
y=0.
th=0.
d=0.
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
exta=0.
sad=0.
eh2o=0.
eo3=0.
eno2=0.
eexta=0.
esad=0.
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
extahal=fltarr(icount)
sadhal=fltarr(icount)
h2ohal=fltarr(icount)
o3hal=fltarr(icount)
no2hal=fltarr(icount)
eextahal=fltarr(icount)
esadhal=fltarr(icount)
eh2ohal=fltarr(icount)
eo3hal=fltarr(icount)
eno2hal=fltarr(icount)

for i=0L,icount-1L do begin
;
; printf,50,t,y,x,th,d,p,z,p_trop,z_trop,th_trop,cl,m
    readf,4,t,y,x,th,d,pth,zth,ptr,ztr,thtr,cl,m
;
; printf,50,extadat,saddat,no2dat,o3dat,h2odat
    readf,4,exta,sad,no2,o3,h2o
;
; printf,50,extaerrdat,saderrdat,no2errdat,o3errdat,h2oerrdat
    readf,4,eexta,esad,eno2,eo3,eh2o

    thal(i)=t
    xhal(i)=x
    yhal(i)=y
    thhal(i)=th
    dsat(i)=d
    phal(i)=pth
    zhal(i)=zth
    ptrhal(i)=ptr
    ztrhal(i)=ztr
    thtrhal(i)=thtr
    clhal(i)=cl
    mhal(i)=m
    sadhal(i)=sad
    extahal(i)=exta
    h2ohal(i)=h2o
    o3hal(i)=o3
    no2hal(i)=no2
    esadhal(i)=esad
    eh2ohal(i)=eh2o
    eo3hal(i)=eo3
    eno2hal(i)=eno2
    eextahal(i)=eexta
return
endfor
return
end
