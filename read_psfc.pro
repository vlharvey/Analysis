;
; read psfc files
;
filename='/aura3/data/UKMO_data/Datfiles/ppassm_y08_m04_d16_h12.pp.dat.psfc'
close,10
openr,10,filename,/f77
nlg=0L & nlat=0L
readu,10,nlg,nlat
alon=fltarr(nlg) & alat=fltarr(nlat)
readu,10,alon,alat
mslp=fltarr(nlg,nlat) & sfcp=fltarr(nlg,nlat)
readu,10,mslp,sfcp
close,10
end
