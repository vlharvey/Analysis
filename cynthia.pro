month=['January','February','March','April','May','June','July',$
       'August','September','October','November','December']
nmonth=n_elements(month)
model_dates=[$
'1 December 1999 12UT',$
'1 January 2000 12UT']
nday=n_elements(model_dates)
for n=0L,nday-1L do begin
    result=strsplit(model_dates(n),/extract)
    idy=string(FORMAT='(I2.2)',result(0))
    iyr=string(FORMAT='(I4)',result(2))
    for i=0L,nmonth-1L do begin
        index=where(result(1) eq month(i))
        if index(0) ne -1 then imn=string(FORMAT='(I2.2)',i+1L)
    endfor
    print,model_dates(n),' ',iyr+imn+idy
endfor
end
