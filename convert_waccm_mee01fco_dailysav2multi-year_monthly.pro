;
; compute multi-year monthly means and save
;
dir='/aura7/harvey/WACCM_data/Datfiles/Datfiles_Mills/mee01fco/'
month=['J','F','M','A','M','J','J','A','S','O','N','D',' ']
for imonth=0L,n_elements(month)-2L do begin
    imn=imonth+1L
    smn=string(format='(i2.2)',imn)
    ofile=dir+'mee01fco.vars.h3.'+smn+'_AVG.sav'
    print,ofile
    spawn,'ls '+dir+'mee01fco.vars.h3.20??'+smn+'??.sav',sfiles
    nfile=n_elements(sfiles)
;
; loop over all days in this month in all years
;
    for ifile=0L,nfile-1L do begin
        sfile=sfiles(ifile)
        print,'opening '+sfile
        restore,sfile
;
; declare average arrays
;
        if ifile eq 0L then begin
           o3_avg=0.*o3
           temp_avg=0.*temp
           ghgt_avg=0.*ghgt
        endif
;
; summate
;
        o3_avg=o3_avg+o3
        temp_avg=temp_avg+temp
        ghgt_avg=ghgt_avg+ghgt
    endfor	; loop over all days
;
; average
;
    o3_avg=o3_avg/float(nfile)
    temp_avg=temp_avg/float(nfile)
    ghgt_avg=ghgt_avg/float(nfile)
;
; multi-year monthly mean save files
;
    save,file=ofile,o3_avg,temp_avg,ghgt_avg,latitude,longitude,pressure
endfor		; loop over months
end
