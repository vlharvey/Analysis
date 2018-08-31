pro rd_forward_haloe_julian,nday,norbit,ifile1,dir,xhalf,yhalf,xsatf,ysatf,thalf,$
ch4half,hfhalf,h2ohalf,o3half,hclhalf,noxhalf,aerhalf,no2half 
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
thalf(icount)=24.*jday+t
xhalf(icount)=x
yhalf(icount)=y
xsatf(icount)=xs
ysatf(icount)=ys
readf,4,ch4,hf,h2o,o3,hcl,no2,no,aer,e1,e2,e3,e4,$
        comp1,dens1,medr1,disw1,conc1,surf1,volu1,effr1
ch4half(icount)=ch4
hfhalf(icount)=hf
h2ohalf(icount)=h2o
o3half(icount)=o3
hclhalf(icount)=hcl
noxhalf(icount)=no+no2
no2half(icount)=no2
aerhalf(icount)=aer
readf,4,ch4,hf,h2o,o3,hcl,no2,no,aer 
icount=icount+1L
endfor
jumpday:
close,4
endfor
index=where(thalf ne 9999.) 
if index(0) ne -1 then begin
thalf=thalf(index)
xhalf=xhalf(index) 
yhalf=yhalf(index) 
xsatf=xsatf(index) 
ysatf=ysatf(index) 
ch4half=ch4half(index) 
hfhalf=hfhalf(index) 
h2ohalf=h2ohalf(index) 
o3half=o3half(index) 
hclhalf=hclhalf(index) 
noxhalf=noxhalf(index) 
no2half=no2half(index) 
aerhalf=aerhalf(index) 
endif
return
end
