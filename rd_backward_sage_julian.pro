pro rd_backward_sage_julian,nday,norbit,ifile1,dir,xsageb,ysageb,xsatsageb,$
    ysatsageb,tsageb,extsageb,sadsageb,h2osageb,o3sageb,no2sageb
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
ext=0.
sad=0.
h2o=0.
o3=0.
no2=0.
readf,4,t,y,x,xs,ys,pth,zth,ptr,ztr,thtr,cl,m
tsageb(icount)=24.*jday+t
xsageb(icount)=x
ysageb(icount)=y
xsatsageb(icount)=xs
ysatsageb(icount)=ys
readf,4,ext,sad,no2,o3,h2o
extsageb(icount)=ext
sadsageb(icount)=sad
no2sageb(icount)=no2
o3sageb(icount)=o3
h2osageb(icount)=h2o
readf,4,ext,sad,no2,o3,h2o
icount=icount+1L
endfor
jumpday:
close,4
endfor
index=where(tsageb ne 9999.) 
if index(0) ne -1 then begin
tsageb=tsageb(index)
xsageb=xsageb(index) 
ysageb=ysageb(index) 
xsatsageb=xsatsageb(index) 
ysatsageb=ysatsageb(index) 
extsageb=extsageb(index)
sadsageb=sadsageb(index)
h2osageb=h2osageb(index)
o3sageb=o3sageb(index)
no2sageb=no2sageb(index)
;
; sort backward sage data
;
index=reverse(sort(tsageb))
tsageb=tsageb(index)
xsageb=xsageb(index) 
ysageb=ysageb(index) 
xsatsageb=xsatsageb(index) 
ysatsageb=ysatsageb(index) 
extsageb=extsageb(index)
sadsageb=sadsageb(index)
h2osageb=h2osageb(index)
o3sageb=o3sageb(index)
no2sageb=no2sageb(index)
endif
return
end
