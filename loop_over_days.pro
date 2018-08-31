;
@ckday
@kdate

;
; data directory
;
dir='/Volumes/Data/MERRA_data/Datfiles/MERRA-on-WACCM_press_'
iyr=1980
nday=365
if (iyr mod 4) eq 0 then nday=366
for iday=1,nday do begin
    kdate,float(iday),iyr,imn,idy
    ckday,iday,iyr
    syr=strcompress(iyr,/remove_all)
    smn=string(FORMAT='(i2.2)',imn)
    sdy=string(FORMAT='(i2.2)',idy)
    sdate=syr+smn+sdy
    print,iday,imn,idy
;
; get all Jan 1sts, etc.
spawn,'ls '+dir+'????'+smn+sdy+'.sav',ifiles
;help,ifiles
;
; loop over ifiles and average
;
nyear=n_elements(ifiles)
for iyear=0L,nyear-1L do begin
;
; read ifiles(iyear)
; 
    if iyear eq 0L then zavg=0.*z
    zavg=zavg+z
endfor
zavg=zavg/float(nyear)
;
; save out Jan 1st AVG file, etc.
;
save,file=dir+smn+sdy+'_AVG.sav',zavg,lon,lat,lev

endfor
end
