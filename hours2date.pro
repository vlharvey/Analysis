;
; given number of hours since 01/01/0001 determine month,day,year,hour
;
hour=[17337168.,17337174.,17337180.,17337186.,17337192.,17337198.,17337204.,$ 
      17337210.,17337216.,17337222.,17337228.,17337234.,17337240.,17337246.,$
      17337252.,17337258.,17337264.,17337270.,17337276.,17337282.,17337288.,$
      17337294.,17337300.,17337306.,17337312.,17337318.,17337324.,17337330.,$
      17337336.]
nhour=n_elements(hour)
month=[31,28,31,30,31,30,31,31,30,31,30,31]
ibase=1L
leapdays=0L
for ihour=0,nhour-1 do begin
days=0.
hours=0.
nyear=3000L
for iyear=ibase+1L,nyear-1L do begin
    if (iyear mod 4L) eq 0L then leapdays=leapdays+1L
    days=days+365.
    hours=days*24.+leapdays*24.
    print,iyear,days+leapdays,hours,hours-hour(ihour)
if iyear eq 1989 then stop
;    if abs(hours-hour(ihour)) le 8760.00 then begin
;stop


;       goto,jump
;    endif
endfor
jump:
endfor
end
