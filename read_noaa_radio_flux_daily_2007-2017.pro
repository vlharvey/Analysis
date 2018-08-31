;
; read noaa radio flux
;
close,10
openr,10,'noaa_radio_flux_daily_2007-2017.ascii
header1=' '
header2=' '
readf,10,header1
print,header1
readf,10,header2
print,header2
dataline=' '
icount=0L
while not eof(10) do begin
      readf,10,dataline
      result=strsplit(dataline,' ',/extract)
      if icount eq 0L then begin
         year=result(0)
         mon=result(1)
         day=result(2)
         f107=result(3)
      endif
      if icount gt 0L then begin
         year=[year,result(0)]
         mon=[mon,result(1)]
         day=[day,result(2)]
         f107=[f107,result(3)]
      endif
      icount=icount+1
endwhile
close,10
f107=float(f107)
bad=where(f107 lt 0.)
if index(0) ne -1L then f107(bad)=0./0.
;
; fyr for plotting
;
doy=julday(long(mon),long(day),long(year))-julday(1,1,long(year))
nday=float(365.+0.*long(year))
index=where(long(year) mod 4 eq 0L)
if index(0) ne -1L then nday(index)=366.
fry=1.*year+(float(doy)/nday)

window
loadct,39
!p.background=255
device,decompose=0
!type=2^2+2^3
plot,fry,f107,color=0,psym=1,xrange=[2007,2018],yrange=[50,250],ytitle='F10.7 (10e-22 W/m^2/Hz)',charsize=2,charthick=2
;
; print yearly averages
;
for ii=2007,2017 do begin
    index=where(year eq ii)
    print,year(index(0)),mean(f107(index),/Nan)
endfor
end
