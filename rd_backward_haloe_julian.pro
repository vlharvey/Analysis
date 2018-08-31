pro rd_backward_haloe_julian,nday,norbit,ifile1,dir,xhalb,yhalb,xsatb,ysatb,thalb,$
ch4halb,hfhalb,h2ohalb,o3halb,hclhalb,noxhalb,aerhalb,no2halb 
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
mday=[31,28,31,30,31,30,31,31,30,31,30,31]
icount=0L
for n=0,nday-1 do begin
close,4
openr,4,dir+ifile1(n)
readf,4,iorbit
if iorbit eq 0L then goto,jumpday
print,'theta input file is '+ifile1(n),iorbit
;
; extract day, month, year from ifile1
;
idy=fix(strmid(ifile1(n),20,2))
index=where(strmid(ifile1(n),16,4) eq mon)
imn=index(0)+1
iyr=fix(strmid(ifile1(n),23,2))
leapyr=iyr mod 4
if leapyr eq 0 then leapdy=1
if leapyr ne 0 then leapdy=0
if imn le 2 then leapdy=0
mdays=0
for i=0,imn-2 do mdays=mdays+mday(i)
jday=mdays+idy+leapdy
for i=0,iorbit-1 do begin
t=0.
x=0.
y=0.
xs=0.
ys=0.
pth=0.
zth=0.
ptr=0.
ztr=0.
thtr=0.
cl=0.
m=0
ch4=0.
hf=0.
h2o=0.
o3=0.
hcl=0.
no2=0.
no=0.
aer=0.
e1=0.
e2=0.
e3=0.
e4=0.
comp1=0.
dens1=0.
medr1=0.
disw1=0.
conc1=0.
surf1=0.
volu1=0.
effr1=0.
readf,4,t,y,x,xs,ys,pth,zth,ptr,ztr,thtr,cl,m
;
; convert time to Julian hour
;
thalb(icount)=24.*jday+t
xhalb(icount)=x
yhalb(icount)=y
xsatb(icount)=xs
ysatb(icount)=ys
readf,4,ch4,hf,h2o,o3,hcl,no2,no,aer,e1,e2,e3,e4,$
        comp1,dens1,medr1,disw1,conc1,surf1,volu1,effr1
ch4halb(icount)=ch4
hfhalb(icount)=hf
h2ohalb(icount)=h2o
o3halb(icount)=o3
hclhalb(icount)=hcl
noxhalb(icount)=no2+no
no2halb(icount)=no2
aerhalb(icount)=aer
readf,4,ch4,hf,h2o,o3,hcl,no2,no,aer 
icount=icount+1L
endfor
jumpday:
close,4
endfor
index=where(thalb ne 9999.) 
if index(0) ne -1 then begin
thalb=thalb(index)
xhalb=xhalb(index) 
yhalb=yhalb(index) 
xsatb=xsatb(index) 
ysatb=ysatb(index) 
ch4halb=ch4halb(index) 
hfhalb=hfhalb(index) 
h2ohalb=h2ohalb(index) 
o3halb=o3halb(index) 
hclhalb=hclhalb(index) 
noxhalb=noxhalb(index) 
no2halb=no2halb(index) 
aerhalb=aerhalb(index) 
;
; sort backward haloe data
;
index=reverse(sort(thalb))
thalb=thalb(index)
xhalb=xhalb(index) 
yhalb=yhalb(index) 
xsatb=xsatb(index) 
ysatb=ysatb(index) 
ch4halb=ch4halb(index) 
hfhalb=hfhalb(index) 
h2ohalb=h2ohalb(index) 
o3halb=o3halb(index) 
hclhalb=hclhalb(index) 
noxhalb=noxhalb(index) 
no2halb=no2halb(index) 
aerhalb=aerhalb(index) 
endif
return
end
