;
; restore SOSST ozone data for 2005
;
@stddat
@kgmt
@ckday
@kdate

loadct,38
mcolor=fix(byte(!p.color))
mcolor=fix(mcolor)
if mcolor eq 0 then mcolor=255
device,decompose=0
setplot='x'
read,'setplot=',setplot
nxdim=750 & nydim=750
xorig=[0.15]
yorig=[0.10]
cbaryoff=0.015
cbarydel=0.01
!NOERAS=-1
a=findgen(8)*(2*!pi/8.)
usersym,cos(a),sin(a),/fill
if setplot ne 'ps' then begin
   lc=0
   window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
   !p.background=mcolor
endif
dir='c:\Datfiles_SOSST\'
syear=['2005']
nyear=n_elements(syear)
;
; loop over years (currently 1)
;
for iyear=0L,nyear-1L do begin
    syr=syear(iyear)
;
; restore full year of SOSST ozone from each instrument
;
; SAGE II
;
    restore,dir+'cat_sage2_v6.2.'+syr
    restore,dir+'o3_sage2_v6.2.'+syr
    datesage2_all=date
    ysage2_all=latitude
    xsage2_all=longitude
    modes2_all=sctype
    o3sage2_all=mix
;
; SAGE III
;
    restore,dir+'cat_sage3_v3.00.'+syr
    restore,dir+'o3mlr_sage3_v3.00.'+syr
    datesage3_all=date
    ysage3_all=latitude
    xsage3_all=longitude
    modes3_all=sctype
    o3sage3_all=mix
;
; HALOE
;
    restore,dir+'cat_haloe_v19.'+syr
    restore,dir+'o3_haloe_v19.'+syr
    datehal_all=date
    yhal_all=latitude
    xhal_all=longitude
    modeh_all=sctype
    o3hal_all=mix
;
; POAM
;
    restore,dir+'cat_poam3_v4.0.'+syr
    restore,dir+'o3_poam3_v4.0.'+syr
    datepoam_all=date
    ypoam_all=latitude
    xpoam_all=longitude
    modep_all=sctype
    o3poam_all=mix
;
; ACE
;
    restore,dir+'cat_ace_v2.2.'+syr
    restore,dir+'o3_ace_v2.2.'+syr
    dateace_all=date
    yace_all=latitude
    xace_all=longitude
    modea_all=sctype
    o3ace_all=mix
;
; MAESTRO
;
    restore,dir+'cat_maestro_v1.2.'+syr
    restore,dir+'vo3_maestro_v1.2.'+syr
    datemaestro_all=date
    ymaestro_all=latitude
    xmaestro_all=longitude
    modem_all=sctype
    o3maestro_all=mix
;
; loop over days in the year
;
    lstmn=1 & lstdy=1 & lstyr=long(syear(iyear)) & lstday=0
    ledmn=12 & leddy=31 & ledyr=long(syear(iyear)) & ledday=0
    z = stddat(lstmn,lstdy,lstyr,lstday)
    z = stddat(ledmn,leddy,ledyr,ledday)
    iyr = lstyr
    idy = lstdy
    imn = lstmn
    z = kgmt(imn,idy,iyr,iday)
    iday = iday - 1
;
; --- Loop over days here --------
;
    jump: iday = iday + 1
          kdate,float(iday),iyr,imn,idy
          ckday,iday,iyr
          z = stddat(imn,idy,iyr,ndays)
          if ndays lt lstday then stop,' starting day outside range '
          if ndays gt ledday then goto,jumpyear
          syr=strtrim(string(iyr),2)
          sdy=string(FORMAT='(i2.2)',idy)
          smn=string(FORMAT='(i2.2)',imn)
          sdate=syr+smn+sdy
          ldate=long(sdate)
;
; extract daily SOSST data
;
          norbits3=0L & norbits2=0L & norbitp=0L & norbith=0L & norbita=0L & norbitm=0L
          sage2day=where(datesage2_all eq ldate,norbits2)
          if norbits2 le 1L then goto,jumpsage2
          o3sage2=reform(o3sage2_all(sage2day,*))*1.e6
          ysage2=reform(ysage2_all(sage2day))
          xsage2=reform(xsage2_all(sage2day))
          jumpsage2:
          sage3day=where(datesage3_all eq ldate,norbits3)
          if norbits3 le 1L then goto,jumpsage3
          o3sage3=reform(o3sage3_all(sage3day,*))*1.e6
          ysage3=reform(ysage3_all(sage3day))
          xsage3=reform(xsage3_all(sage3day))
          jumpsage3:
          halday=where(datehal_all eq ldate,norbith)
          if norbith le 1L then goto,jumphal
          o3hal=reform(o3hal_all(halday,*))*1.e6
          yhal=reform(yhal_all(halday))
          xhal=reform(xhal_all(halday))
          jumphal:
          poamday=where(datepoam_all eq ldate,norbitp)
          if norbitp le 1L then goto,jumppoam
          o3poam=reform(o3poam_all(poamday,*))*1.e6
          ypoam=reform(ypoam_all(poamday))
          xpoam=reform(xpoam_all(poamday))
          jumppoam:
          aceday=where(dateace_all eq ldate,norbita)
          if norbita le 1L then goto,jumpace
          o3ace=reform(o3ace_all(aceday,*))*1.e6
          yace=reform(yace_all(aceday))
          xace=reform(xace_all(aceday))
          jumpace:
          maestroday=where(datemaestro_all eq ldate,norbitm)
          if norbitm le 1L then goto,jumpmaestro
          o3maestro=reform(o3maestro_all(maestroday,*))*1.e6
bad=where(o3maestro gt 20.)
if bad(0) ne -1L then o3maestro(bad)=-99.e6
          ymaestro=reform(ymaestro_all(maestroday))
          xmaestro=reform(xmaestro_all(maestroday))
          jumpmaestro:
          print,iyr,imn,idy
          print,norbits3,norbits2,norbitp,norbith,norbita,norbitm
;
; postscript file
;
         if setplot eq 'ps' then begin
            lc=0
            set_plot,'ps'
            xsize=nxdim/100.
            ysize=nydim/100.
            !p.font=0
            device,font_size=9
            device,/landscape,bits=8,filename='sosst_o3_'+sdate+'.ps'
            device,/color
            device,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,$
                   xsize=xsize,ysize=ysize
         endif
;
; plot geographical distribution of ozone profiles
;
         erase
         !type=2^2+2^3
         set_viewport,xorig(0),xorig(0)+0.7,yorig(0)+0.61,yorig(0)+0.61+0.225
         map_set,0,0,0,/contin,/grid,color=0,/noeras,title=sdate,charsize=2
         if norbits2 gt 0L then oplot,xsage2,ysage2,psym=8,color=mcolor*.1,symsize=2
         if norbits3 gt 0L then oplot,xsage3,ysage3,psym=8,color=mcolor*.2,symsize=2
         if norbitp gt 0L then oplot,xpoam,ypoam,psym=8,color=mcolor*.35,symsize=2
         if norbith gt 0L then oplot,xhal,yhal,psym=8,color=mcolor*.6,symsize=2
         if norbita gt 0L then oplot,xace,yace,psym=8,color=mcolor*.8,symsize=3
         if norbitm gt 0L then oplot,xmaestro,ymaestro,psym=8,color=mcolor*.9,symsize=2
;
; plot ozone profiles
;
         xmn=xorig(0)
         xmx=xorig(0)+0.7
         ymn=yorig(0)
         ymx=yorig(0)+0.6
         set_viewport,xmn,xmx,ymn,ymx
         plot,findgen(13),altitude,/nodata,/noeras,color=0,charsize=2,charthick=2,$
              xrange=[0.,12.],yrange=[1.,80.],xtitle='Ozone (ppmv)',ytitle='Altitude (km)'
         if norbits2 gt 0L then begin
            for iprof=0L,norbits2-1L do begin
                oplot,reform(o3sage2(iprof,*)),altitude,color=mcolor*.1,min_value=-99.,thick=5
            endfor
            xyouts,9.,22.,'SAGE II',charthick=2,/data,charsize=2,color=mcolor*.1
         endif
         if norbits3 gt 0L then begin
            for iprof=0L,norbits3-1L do begin
                oplot,reform(o3sage3(iprof,*)),altitude,color=mcolor*.2,min_value=-99.,thick=5
            endfor
            xyouts,9.,18.,'SAGE III',charthick=2,/data,charsize=2,color=mcolor*.2
         endif
         if norbitp gt 0L then begin
            for iprof=0L,norbitp-1L do begin
                oplot,reform(o3poam(iprof,*)),altitude,color=mcolor*.35,min_value=-99.,thick=5
            endfor
            xyouts,9.,14.,'POAM III',charthick=2,/data,charsize=2,color=mcolor*.35
         endif
         if norbith gt 0L then begin
            for iprof=0L,norbith-1L do begin
                oplot,reform(o3hal(iprof,*)),altitude,color=mcolor*.6,min_value=-99.,thick=5
            endfor
            xyouts,9.,10.,'HALOE',charthick=2,/data,charsize=2,color=mcolor*.6
         endif
         if norbita gt 0L then begin
            for iprof=0L,norbita-1L do begin
                oplot,reform(o3ace(iprof,*)),altitude,color=mcolor*.8,min_value=-99.,thick=5
            endfor
            xyouts,9.,6.,'ACE',charthick=2,/data,charsize=2,color=mcolor*.8
         endif
         if norbitm gt 0L then begin
            for iprof=0L,norbitm-1L do begin
                oplot,reform(o3maestro(iprof,*)),altitude,color=mcolor*.9,min_value=-99.,thick=5
            endfor
            xyouts,9.,2.,'MAESTRO',charthick=2,/data,charsize=2,color=mcolor*.9
         endif
;
; stop or save postscript file
;
         if setplot ne 'ps' then stop
         if setplot eq 'ps' then begin
            device, /close
            spawn,'convert -trim sosst_o3_'+sdate+'.ps -rotate -90 sosst_o3_'+sdate+'.jpg'
         endif
         goto,jump
     jumpyear:
endfor		; loop over years (currently 1)
end
