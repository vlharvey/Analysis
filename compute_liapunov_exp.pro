nmax=5   ; max # of contours 
nday=20   ; number of days output 

ifile=[$
'ukmo_jan16-feb04_strm1.def',$
'ukmo_jan16-feb04_strm2.def',$
'ukmo_jan16-feb04_strm3.def',$
'ukmo_jan16-feb04_strm4.def',$
'ukmo_jan16-feb04_strm5.def'$
]

line=fltarr(nday)
dum1=line
dum2=line
dum3=line

lines=fltarr(nmax,nday)
linefit=fltarr(nmax,nday)
lineerr=fltarr(nmax,nday)

sigma=fltarr(nmax)
lapexp=fltarr(nmax)

for n=0,nmax-1 do begin
   openr,1,ifile(n)
   readu,1,line
   close,1
   lines(n,*)=line/line(0)
   plot,line
   wait,.1
endfor
;
;  log linear fit
;
num=strcompress(string(n),/remove_all)
openw,1,'ukmo_jan16-feb04_strm'+num+'.def.20d_log_fit'

for n = 0, nmax-1 do begin
   x=findgen(nday)
   line=lines(n,*)
   coef=poly_fit(x,alog(line),1,yfit,ybin,sig)
   lapexp(n)=coef(1)
   linefit(n,*)=exp(yfit)
   lineerr(n,*)=line-exp(yfit)
   sigma(n)=exp(sig)
endfor
writeu,1,lines
writeu,1,linefit
writeu,1,lineerr
writeu,1,lapexp
writeu,1,sigma
close,1
;
;  1st order linear fit
;
for n = 0, nmax-1 do begin
   line=lines(n,*)
   coef=poly_fit(x,line,1,yfit,ybin,sig)
   lapexp(n)=coef(1)
   linefit(n,*)=yfit
   lineerr(n,*)=line-yfit
   sigma(n)=sig
endfor

openw,1,'ukmo_jan16-feb04_strm'+num+'.def.20d_lin_fit'

writeu,1,lines
writeu,1,linefit
writeu,1,lineerr
writeu,1,lapexp
writeu,1,sigma
close,1
end
