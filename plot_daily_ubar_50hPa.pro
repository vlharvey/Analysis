;
; IDL code to plot the daily zonal mean zonal winds as a function of latitude
;
!type=2^2+2^3
month=['January','February','March','April','May','June',$
       'July','August','September','October','November','December']
restore,'/Volumes/earth/harvey/UKMO_data/Datfiles/ukmo_12Z_Ubar_50hPa.sav
index=where(ubar eq -99. or ubar eq -10000.)
if index(0) ne -1L then ubar(index)=0./0.
nday=n_elements(sdate)
for icount=0L,nday-1L do begin
    smn=strmid(sdate(icount),4,2)
    imn=long(smn)
    plot,alat,ubar(*,icount),xrange=[-90.,90.],yrange=[-40.,80.],title=sdate(icount),xtitle='Latitude',ytitle='Ubar',charsize=2,charthick=2,thick=3
    xyouts,-10.,70.,month(imn-1),/data,charsize=3,charthick=2
    plots,-90.,10.
    plots,90.,10.,/continue,linestyle=5
    plots,-90.,-10.
    plots,90.,-10.,/continue,linestyle=5
    wait,.1
endfor
end
