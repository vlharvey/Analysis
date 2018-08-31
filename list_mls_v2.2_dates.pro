;********************************
; List dates of MLS v2.2 files
;********************************
@ckday
@kdate

mno=[31,28,31,30,31,30,31,31,30,31,30,31]
dir='/aura6/data/MLS_data/Datfiles/'
spawn,'ls '+dir+'MLS-Aura_L2GP-Temperature_v02*5',ifiles
nfile=n_elements(ifiles)
ldate=lonarr(nfile)
for i=0L,nfile-1L do begin
    result=strsplit(ifiles(i),'.',/extract)
    result2=strsplit(result(0),'_',/extract)
    result3=strsplit(result2(4),'d',/extract)
    iyr=long(result3(0))
    iday=long(result3(1))
    kdate,float(iday),iyr,imn,idy
    ckday,iday,iyr
    syr=string(FORMAT='(I4.4)',iyr)
    smn=string(FORMAT='(I2.2)',imn)
    sdy=string(FORMAT='(I2.2)',idy)
    ldate(i)=long(syr+smn+sdy)
endfor
;
; sort in time
;
x=sort(ldate)
for i=0L,nfile-1L do print,ifiles(x(i)),' ',ldate(x(i))
end
