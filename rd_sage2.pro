pro rd_sage2,imn,idy,iyr1,kth,nsage,xsage,ysage,xsatsage,ysatsage,$
             sageext,sagesad,sagexno2,sageo3

if iyr1 lt 84 or iyr1 gt 99 then goto,jump

dir='/pluto/'
mon=strarr(12)*4
mon=['jan_','feb_','mar_','apr_','may_','jun_',$
     'jul_','aug_','sep_','oct_','nov_','dec_']
thlab=strarr(30)
thlab=['1400k','1200k','1000k','900k','800k','700k','600k',$
        '550k', '525k', '500k','475k','450k','425k','400k',$
        '390k', '380k', '370k','360k','350k','340k','330k',$
        '320k', '310k', '300k','290k','280k','270k','260k',$
        '250k', '240k']
hdr='_data/sage2_'
filename=' '
filename=dir+thlab(kth)+hdr+mon(imn-1)+(string(FORMAT='(I2.2,A1,I2,A1)',$
         idy,'_',iyr1,'.'))+thlab(kth)+'.cc'
print, 'opening '+filename
close,10
openr,10,filename

a1=0.
a2=0.
a3=0.
a4=0.
a5=0.
a6=0.
a7=0.
b1=0.
b2=0.
b3=0.
b4=0.
b5=0.
b6=0.
b7=0.
b8=0.
b9=0.
b10=0.
b11=0.
b12=0.
b13=0.
b14=0.
b15=0.
ncount=0
readf,10,ncount
if ncount eq 0 then goto,jump

; Read SAGE II daily theta data 
for n=0,ncount-1 do begin
    readf,10,a1,a2,a3,a4,a5,a6,a7
    ysage(n)=a2
    xsage(n)=a3
    xsatsage(n)=a4
    ysatsage(n)=a5

; b1=1 um ext, b2= 0.525 um ext, b3= 0.453 um ext, b4= 0.385 um ext,
; b5=SAD,      b6=NO2,           b7=O3,            b8=H2O
    readf,10,b1,b2,b3,b4,b5,b6,b7,b8
    sageext(n)=b1
    sagesad(n)=b5
    sagexno2(n)=b6
    sageo3(n)=b7

; b9 = 1 um error, b10= .525 err,  b11= .453 err,
; b12= .385 err,   b13= NO2 error, b14= O3 error, b15=H2O error
    readf,10,b9,b10,b11,b12,b13,b14,b15

endfor
close,10
jump:
end

