pro rd_dc8_merge,ifile,nobs,tdc8,o3dc8,co2dc8,codc8,ch4dc8,tpdc8,$
    thdc8,zdc8,ydc8,xdc8,sdc8,ddc8,pdc8
;
; Read DC8 MergesYYYYMMDD.dat ASCII files		VLH 7/23/2003
; File format: 1st number is the number of data points
; 
;	 Column		Data		Units
; ----------------------------------------------------
;	 0		Time		(seconds)
;	 1		Ozone		(ppb)
;	 2		CO2		(ppm)
;	 3		CO		(ppb)
;	 4		CH4		(ppm)
;	 5		Temperature	(K)
;	 6		Theta		(K)
;	 7		Altitude	(m)
;	 8		Latitude	(deg)
;	 9		Longitude	(deg)
;	 10		wind speed	(m/s)
;	 11		wind direction	(degrees)
;	 12		Press		(hPa)
; ----------------------------------------------------
close,2
openr,2,ifile
nobs=0L
readf,2,nobs
tdc8=-9999.+fltarr(nobs)
o3dc8=-9999.+fltarr(nobs)
co2dc8=-9999.+fltarr(nobs)
codc8=-9999.+fltarr(nobs)
ch4dc8=-9999.+fltarr(nobs)
tpdc8=-9999.+fltarr(nobs)
thdc8=-9999.+fltarr(nobs)
zdc8=-9999.+fltarr(nobs)
ydc8=-9999.+fltarr(nobs)
xdc8=-9999.+fltarr(nobs)
sdc8=-9999.+fltarr(nobs)
ddc8=-9999.+fltarr(nobs)
pdc8=-9999.+fltarr(nobs)
t=0. & o3=0. & co2=0. & co=0. & ch4=0. & tp=0.
th=0. & z=0. & y=0. & x=0. & s=0. & d=0. & p=0.
for i=0L,nobs-1L do begin
    readf,2,t,o3,co2,co,ch4,tp,th,z,y,x,s,d,p
;   print,t,o3,co2,co,ch4,tp,th,z,y,x,s,d,p
    tdc8(i)=t/60./60.				; hours
    if o3 ne 9999. then o3dc8(i)=o3/1000.	; ppm
    co2dc8(i)=co2
    codc8(i)=co
    ch4dc8(i)=ch4
    tpdc8(i)=tp
    thdc8(i)=th
    zdc8(i)=z
    ydc8(i)=y
    xdc8(i)=x
    sdc8(i)=s
    ddc8(i)=d
    pdc8(i)=p
endfor
index=where(o3dc8 gt 0.,nobs)
tdc8=tdc8(index)
o3dc8=o3dc8(index)
co2dc8=co2dc8(index)
codc8=codc8(index)
ch4dc8=ch4dc8(index)
tpdc8=tpdc8(index)
thdc8=thdc8(index)
zdc8=zdc8(index)
ydc8=ydc8(index)
xdc8=xdc8(index)
sdc8=sdc8(index)
ddc8=ddc8(index)
pdc8=pdc8(index)
index=where(xdc8 lt 0.0)
if index(0) ne -1 then xdc8(index)=xdc8(index)+360.
return
end
