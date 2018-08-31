;
; This code returns the UARS day given (jday,year) information.
; --- UARS day 1 = September 12, 1991 (jday=255)

function date2uars,imn,iday,iyr,uday

month=[31,28,31,30,31,30,31,31,30,31,30,31]
ibase=1991
leapdays=0

; --- Compute number of days since 1 January 1991
idays=float(iyr-ibase)*365.

; --- add the leap days for the period from 1991
if (iyr mod 4) eq 0 then begin
   month(1) = 29
   leapdays=fix(float(iyr-1992)/4.)
endif else begin
   month(1) = 28
   leapdays=fix(float(iyr-1988)/4.)
endelse

if imn le 1 then goto, jump

for j = 0, imn-2 do begin
    idays = idays + month(j)
endfor

jump: uday = iday + idays + leapdays - 254
;print,'in date2 ',iday,idays,leapdays,uday

end


