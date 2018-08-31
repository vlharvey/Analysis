;
; create MLS yearly files. monthly means
;
dirh='/Volumes/earth/aura6/data/MLS_data/Datfiles_SOSST/raw_mls_v3.3_'
spawn,'ls '+dirh+'*daily_zm.sav',ifiles
smon=['01','02','03','04','05','06','07','08','09','10','11','12']
model_years=[2004,2005,2006,2007,2008,2009,2010,2011,2012,2013,2014]
model_years=string(FORMAT='(i4)',long(model_years))
nyears=n_elements(model_years)
;
; loop over model years
;
for iyear=0L,nyears-1L do begin

      dum=findfile(dirh+model_years(iyear)+'_daily_zm.sav')
      restore,dum(0)
;
; monthly averages
;
      nr=n_elements(latbin)
      nl=n_elements(pmls)
      kday=12L
      BROMLS_MONAVG=fltarr(nr,nl,kday)
      CLOMLS_MONAVG=fltarr(nr,nl,kday)
      COMLS_MONAVG=fltarr(nr,nl,kday)
      GPMLS_MONAVG=fltarr(nr,nl,kday)
      H2OMLS_MONAVG=fltarr(nr,nl,kday)
      HCLMLS_MONAVG=fltarr(nr,nl,kday)
      HNO3MLS_MONAVG=fltarr(nr,nl,kday)
      N2OMLS_MONAVG=fltarr(nr,nl,kday)
      O3MLS_MONAVG=fltarr(nr,nl,kday)
      TPMLS_MONAVG=fltarr(nr,nl,kday)
      for n=0L,kday-1L do begin
          monindex=where(strmid(SDATE_ALL,0,2) eq string(FORMAT='(I2.2)',n+1))
          if monindex(0) ne -1L then begin
             BROMLS_MON=reform(BROMLS_AVG(*,*,monindex))
             CLOMLS_MON=reform(CLOMLS_AVG(*,*,monindex))
             COMLS_MON=reform(COMLS_AVG(*,*,monindex))
             GPMLS_MON=reform(GPMLS_AVG(*,*,monindex))
             H2OMLS_MON=reform(H2OMLS_AVG(*,*,monindex))
             HCLMLS_MON=reform(HCLMLS_AVG(*,*,monindex))
             HNO3MLS_MON=reform(HNO3MLS_AVG(*,*,monindex))
             N2OMLS_MON=reform(N2OMLS_AVG(*,*,monindex))
             O3MLS_MON=reform(O3MLS_AVG(*,*,monindex))
             TPMLS_MON=reform(TPMLS_AVG(*,*,monindex))
             for j=0L,nr-1L do begin
             for k=0L,nl-1L do begin
                 index=where(BROMLS_MON(j,k,*) ne 0.)
                 if index(0) ne -1L then BROMLS_MONAVG(j,k,n)=mean(BROMLS_MON(j,k,index))
                 index=where(CLOMLS_MON(j,k,*) ne 0.)
                 if index(0) ne -1L then CLOMLS_MONAVG(j,k,n)=mean(CLOMLS_MON(j,k,index))
                 index=where(COMLS_MON(j,k,*) ne 0.)
                 if index(0) ne -1L then COMLS_MONAVG(j,k,n)=mean(COMLS_MON(j,k,index))
                 index=where(GPMLS_MON(j,k,*) ne 0.)
                 if index(0) ne -1L then GPMLS_MONAVG(j,k,n)=mean(GPMLS_MON(j,k,index))
                 index=where(H2OMLS_MON(j,k,*) ne 0.)
                 if index(0) ne -1L then H2OMLS_MONAVG(j,k,n)=mean(H2OMLS_MON(j,k,index))
                 index=where(HCLMLS_MON(j,k,*) ne 0.)
                 if index(0) ne -1L then HCLMLS_MONAVG(j,k,n)=mean(HCLMLS_MON(j,k,index))
                 index=where(HNO3MLS_MON(j,k,*) ne 0.)
                 if index(0) ne -1L then HNO3MLS_MONAVG(j,k,n)=mean(HNO3MLS_MON(j,k,index))
                 index=where(N2OMLS_MON(j,k,*) ne 0.)
                 if index(0) ne -1L then N2OMLS_MONAVG(j,k,n)=mean(N2OMLS_MON(j,k,index))
                 index=where(O3MLS_MON(j,k,*) ne 0.)
                 if index(0) ne -1L then O3MLS_MONAVG(j,k,n)=mean(O3MLS_MON(j,k,index))
                 index=where(TPMLS_MON(j,k,*) ne 0.)
                 if index(0) ne -1L then TPMLS_MONAVG(j,k,n)=mean(TPMLS_MON(j,k,index))
             endfor
             endfor
         endif
      endfor
      print,max(TPMLS_MONAVG),max(O3MLS_MONAVG),max(N2OMLS_MONAVG),max(HNO3MLS_MONAVG),max(HCLMLS_MONAVG),max(H2OMLS_MONAVG),max(GPMLS_MONAVG),max(COMLS_MONAVG),max(CLOMLS_MONAVG),max(BROMLS_MONAVG)
;
; check
;
erase
!type=2^2+2^3
loadct,39
mcolor=byte(!p.color)
mcolor=fix(mcolor)
device,decompose=0
if mcolor eq 0 then mcolor=255
nlvls=20
col1=1+mcolor*findgen(20)/nlvls
ilat=where(min(abs(latbin-0.94736842)) eq abs(latbin-0.94736842))
plotarray=transpose(reform(TPMLS_MONAVG(ilat,*,*)))
omin=min(plotarray)
omax=max(plotarray)
level=omin+((omax-omin)/nlvls)*findgen(nlvls+1)
contour,plotarray,1+findgen(kday),pmls,levels=level,c_color=col1,/cell_fill,/noeras,yrange=[max(pmls),min(pmls)],/ylog,$
        xrange=[1.,kday],xticks=11,ytitle='Pressure',xtitle='Month',charsize=1.5,min_value=-99.,title='MLS Temp '+model_years(iyear)
contour,plotarray,1+findgen(kday),pmls,levels=level,c_color=0,/follow,/noeras,/overplot
;
; save yearly file
;
ofile=dirh+model_years(iyear)+'_monthly_zm.sav'
save,file=ofile,latbin,pmls,BROMLS_MONAVG,CLOMLS_MONAVG,COMLS_MONAVG,GPMLS_MONAVG,H2OMLS_MONAVG,HCLMLS_MONAVG,HNO3MLS_MONAVG,N2OMLS_MONAVG,O3MLS_MONAVG,TPMLS_MONAVG
endfor	; loop over years
end
