;-----------------------------------------------------------------------------------------------------------------------------
;WACCM AND MLS ELEVATED STRATOPAUSE COMPOSITE FIGURE FOR WACCM STRATOPAUSE CLIMATOLOGY
;	 -------------------------------
;       |         Jeff France           |
;       |         LASP, ATOC            |
;       |    University of Colorado     |
;       |     modified: 08/28/2012      |
;	 -------------------------------
;
;
;
;-----------------------------------------------------------------------------------------------------------------------------
;

@/Volumes/MacD68-1/france/idl_files/stddat			; Determines the number of days since Jan 1, 1956
@/Volumes/MacD68-1/france/idl_files/kgmt			; This function computes the Julian day number (GMT) from the
								;    day, month, and year information.
@/Volumes/MacD68-1/france/idl_files/ckday			; This routine changes the Julian day from 365(6 if leap yr)
								;    to 1 and increases the year, if necessary.
@/Volumes/MacD68-1/france/idl_files/kdate			; gives back kmn,kdy information from the Julian day #.
@/Volumes/MacD68-1/france/idl_files/rd_ukmo_nc3			; reads the data from nc3 files
@/Volumes/MacD68-1/france/idl_files/date2uars			; This code returns the UARS day given (jday,year) information.
@/Volumes/MacD68-1/france/idl_files/plotPosition		; defines positions for n number of plots
@/Volumes/MacD68-1/france/idl_files/rd_GEOS5_nc3
@/Volumes/MacD68-1/france/idl_files/rd_waccm_nc3
@/Volumes/MacD68-1/france/idl_files/frac_index


;--------------------------




px1a = .01
px1b = 0.21
px2a = .23
px2b = .43

py1a = .54
py1b = .94
py2a = .11
py2b = .51


SETPLOT='ps'
read,'setplot',setplot
nxdim=1500
nydim=750
xorig=[0.1,0.6,0.1,0.6,0.1,0.6]
yorig=[0.7,0.7,0.4,0.4,0.1,0.1]

xlen=0.25
ylen=0.25
cbaryoff=0.02
cbarydel=0.01

a=findgen(8)*(2*!pi/8.)
usersym,1.5*cos(a),1.5*sin(a),/fill


if setplot eq 'ps' then begin
  	xsize=nxdim/100.
  	ysize=nydim/100.
  	set_plot,'ps'
  	device,/landscape,/inch,xoff=4.25-ysize/2.,yoff=5.5+xsize/2.,xsize=xsize,ysize=ysize,$
    	/bold,/color,bits_per_pixel=8,/helvetica,filename='idl.ps'
  	!p.charsize=2.    ; test with 1.5
  	!p.thick=3
  	!p.charthick=8
  	!y.thick=3
  	!x.thick=3
endif

loadct,39
mcolor=!p.color
icolmax=255
mcolor=icolmax
icmm1=icolmax-1B
icmm2=icolmax-2B
device,decompose=0
!NOERAS=-1
if setplot ne 'ps' then begin
   	!p.background=mcolor
   	window,4,xsize=nxdim,ysize=nydim,retain=2,colors=162
endif
;

days = 0

months = ['Apr','May','Jun','Jul','Aug','Sep','Oct','Nov']
MONTH = ['04','05','06','07','08','09','10','11']
titles1 = ['-(60-30)','-(30-0)','0-30','30-60','i)','k) Sep','m) Oct','Nov']
titles2 = ['b)','d)','f)','h)','j)','l)','n)','p)','r)']
titles3 = ['a)','c)','e)','g)','i)','k)','m)','o)','q)']




restore, '/Volumes/MacD68-1/france/WACCM_paper/Post_process/Figure_3_pre_process_composit_ES_WACCM.sav'
for imonth = 1, 2L do begin


	vortexmarkcount = fltarr(n_elements(lon), n_elements(lat))
	antimarkcount = fltarr(n_elements(lon), n_elements(lat))
	waccmtmean = fltarr(n_elements(lon), n_elements(lat))
	waccmzmean = fltarr(n_elements(lon), n_elements(lat))

	; SET BAD OR MISSING DATA TO NAN
	z = where(t1to30 le 0.,nz)
	if nz gt 0L then t1to30[z]= !values.f_nan
	z = where(t31to60 le 0.,nz)
	if nz gt 0L then t31to60[z]= !values.f_nan
	z = where(z1to30 le 0.,nz)
	if nz gt 0L then z1to30[z]= !values.f_nan
	z = where(z31to60 le 0.,nz)
	if nz gt 0L then z31to60[z]= !values.f_nan
	z = where(t_1to_30 le 0.,nz)
	if nz gt 0L then t_1to_30[z]= !values.f_nan
	z = where(t_31to_60 le 0.,nz)
	if nz gt 0L then t_31to_60[z]= !values.f_nan
	z = where(z_1to_30 le 0.,nz)
	if nz gt 0L then z_1to_30[z]= !values.f_nan
	z = where(z_31to_60 le 0.,nz)
	if nz gt 0L then z_31to_60[z]= !values.f_nan



	;------------------AVERAGE MONTHLY MEANS AT EACH LAT/LON------------------
	if imonth eq 0L then begin
		for ii = 0, n_elements(lat) - 1L do begin
			for jj = 0, n_elements(lon) - 1L do begin
				x = where(mark_31to_60[*,jj,ii] lt 0. and mark_31to_60[*,jj,ii] gt -99.,nx)
				antimarkcount[jj,ii] = nx
				x = where(mark_31to_60[*,jj,ii] gt 0. and mark_31to_60[*,jj,ii] lt 99.,nx)
				vortexmarkcount[jj,ii] = nx
				waccmtmean[jj,ii] = mean(t_31to_60[*,jj,ii],/nan)
				waccmzmean[jj,ii] = mean(z_31to_60[*,jj,ii],/nan)
			endfor
		endfor
	endif
	if imonth eq 1L then begin
		for ii = 0, n_elements(lat) - 1L do begin
			for jj = 0, n_elements(lon) - 1L do begin
				x = where(mark_1to_30[*,jj,ii] lt 0. and mark_1to_30[*,jj,ii] gt -99.,nx)
				antimarkcount[jj,ii] = nx
				x = where(mark_1to_30[*,jj,ii] gt 0. and mark_1to_30[*,jj,ii] lt 99.,nx)
				vortexmarkcount[jj,ii] = nx
				waccmtmean[jj,ii] = mean(t_1to_30[*,jj,ii],/nan)
				waccmzmean[jj,ii] = mean(z_1to_30[*,jj,ii],/nan)
			endfor
		endfor
	endif
	if imonth eq 2L then begin
		for ii = 0, n_elements(lat) - 1L do begin
			for jj = 0, n_elements(lon) - 1L do begin
				x = where(mark1to30[*,jj,ii] lt 0. and mark1to30[*,jj,ii] gt -99.,nx)
				antimarkcount[jj,ii] = nx
				x = where(mark1to30[*,jj,ii] gt 0. and mark1to30[*,jj,ii] lt 99.,nx)
				vortexmarkcount[jj,ii] = nx
				waccmtmean[jj,ii] = mean(t1to30[*,jj,ii],/nan)
				waccmzmean[jj,ii] = mean(z1to30[*,jj,ii],/nan)
			endfor
		endfor
	endif
	if imonth eq 3L then begin
		for ii = 0, n_elements(lat) - 1L do begin
			for jj = 0, n_elements(lon) - 1L do begin
				x = where(mark31to60[*,jj,ii] lt 0. and mark31to60[*,jj,ii] gt -99.,nx)
				antimarkcount[jj,ii] = nx
				x = where(mark31to60[*,jj,ii] gt 0. and mark31to60[*,jj,ii] lt 99.,nx)
				vortexmarkcount[jj,ii] = nx
				waccmtmean[jj,ii] = mean(t31to60[*,jj,ii],/nan)
				waccmzmean[jj,ii] = mean(z31to60[*,jj,ii],/nan)
			endfor
		endfor
	endif
	;------------------END: AVERAGE MONTHLY MEANS AT EACH LAT/LON------------------
	
	;;;-------------create wrap around for plot------------
    	antimarker = fltarr(n_elements(antimarkcount[*,0L]) + 2L, n_elements(antimarkcount[0L,*]))
    	antimarker[0L:n_elements(antimarkcount[*,0L]) - 1L, *] = antimarkcount[*,*]
   	antimarker[n_elements(antimarkcount[*,0L])-1L:n_elements(antimarkcount[*,0L])+1L,*] = antimarkcount[0L:2L,*]
   	lons = fltarr(n_elements(lon) + 2L)
   	lons[0:n_elements(lon)-1L] = lon
   	lons[n_elements(lon)-1L:n_elements(lon)+1L] = lon[0L:2L]


   	WACCMt = fltarr(n_elements(WACCMtmean[*,0L]) + 2L, n_elements(WACCMtmean[0L,*]))
    	WACCMt[0L:n_elements(WACCMtmean[*,0L]) - 1L, *] = WACCMtmean
   	WACCMt[n_elements(WACCMtmean[*,0L])-1L:n_elements(WACCMtmean[*,0L])+1L,*] = WACCMtmean[0L:2L,*]
     	WACCMZ = fltarr(n_elements(WACCMzmean[*,0L]) + 2L, n_elements(WACCMzmean[0L,*]))
    	WACCMZ[0L:n_elements(WACCMzmean[*,0L]) - 1L, *] = WACCMzmean
   	WACCMZ[n_elements(WACCMzmean[*,0L])-1L:n_elements(WACCMzmean[*,0L])+1L,*] = WACCMzmean[0L:2L,*]


    	vortexmarker = fltarr(n_elements(vortexmarkcount[*,0L]) + 2L, n_elements(vortexmarkcount[0L,*]))
    	vortexmarker[0L:n_elements(vortexmarkcount[*,0L]) - 1L, *] = vortexmarkcount[*,*]
   	vortexmarker[n_elements(vortexmarkcount[*,0L])-1L:n_elements(vortexmarkcount[*,0L])+1L,*] = vortexmarkcount[0L:2L,*]
   	lons = fltarr(n_elements(lon) + 2L)
   	lons[0:n_elements(lon)-1L] = lon
   	lons[n_elements(lon)-1L:n_elements(lon)+1L] = lon[0L:2L]
	;;;

   	WACCMz = smooth(WACCMz,3,/nan)
   	WACCMt = smooth(WACCMt,3,/nan)


	x = where(antimarker lt 0.,nx)
	if nx gt 0L then antimarker[x] = 0.00

	x = where(vortexmarker lt 0.,nx)
	if nx gt 0L then vortexmarker[x] = 0.00


    	;----------------------plot code---------------------      ;x = where(lons eq 0.00)

 
	;Normalize marker
	z = where(lat le 0. and lat ge -99., comp=y)
	antimarker[*,z] = !values.f_nan
	antimarker = antimarker/max(antimarker[*,y],/nan)
	z = where(lat le 0. and lat ge -99., comp=y)
	vortexmarker[*,z] = !values.f_nan
	vortexmarker=vortexmarker/max(vortexmarker[*,y],/nan)






	vortexmarker = smooth(vortexmarker,3,/nan)
	antimarker = smooth(antimarker,3,/nan)



	plot,[0,0],[0,0], position=[.001,.001,.4999,.999], xstyle = 4, ystyle = 4


	xyouts,.9,py1b - .49*(imonth-1L) - .08,titles1[imonth],color =0, orient = -90.
	;xyouts,.1,py1b - .42*(imonth-1L),titles3[imonth],color =0
	;xyouts,.47,py1b - .15*(imonth-1L),titles2[imonth],color =0
	xyouts, .03,.01,'Temperature (K)'
	xyouts, .56,.01,'Height (km)'
	xyouts, .3,.97,'WACCM', charsize = 4., charthick = 10

	; ------------- TEMPERATURE PLOTS -----------------------



    	;----------------------plot code---------------------      ;x = where(lons eq 0.00)
      	;lons[x] = 360.
      	level1 = findgen(13)*3.+240.
      	level1a = findgen(26)*3.+222.
	level3 = findgen(1)+.2
	nlvls  = n_elements(level1)
	col1 = (1 + indgen(nlvls)) * icolmax / nlvls	; define colors
	x = where(lat lt 99.)
	xx = where(lat le 99.)


  	map_set,90.,-90.,0,/ortho, /grid,/noeras,/noborder,/contin,$
    	position = [px1a,py1a - .42*(imonth-1L),px1b,py1b - .42*(imonth-1L)]

	fake = WACCMt
	x = where(WACCMt gt max(level1),nx)
	if nx gt 0 then fake[x] = max(level1)-1.
	x = where(WACCMt lt min(level1),nx)
	if nx gt 0 then fake[x] = min(level1) +1.



    	contour, fake[*,xx], lons, lat[xx], levels=level1, /cell_fill, c_color = col1,/overplot,$
      	min_value = -2., max_value =40000.,xticks = 4, /close, color = 0

    	contour,WACCMt[*,xx], lons, lat[xx], levels=level1a,color=0,charsize=3,$
	min_value = -2., max_value =40000.,/overplot, xticks=5, thick=1

	map_set,90.,-90.,0,/ortho, /grid,/noeras,/noborder,/contin, $
	position = [px1a,py1a - .42*(imonth-1L),px1b,py1b - .42*(imonth-1L)]



	contour,vortexmarker[*,xx], lons, lat[xx], levels = [.3], /overplot, color =0.,thick = 10,$
	position = [px1a,py1a - .42*(imonth-1L),px1b,py1b - .42*(imonth-1L)]

	contour,antimarker[*,xx], lons, lat[xx], levels = [.3,.7], /overplot, color =255.,thick = 10,$
	position = [px1a,py1a - .42*(imonth-1L),px1b,py1b - .42*(imonth-1L)]

	oplot, findgen(361), 0.1+0.*findgen(361), color = 0


	if imonth eq 1L then oplot, maxt_1to_30[*,0],maxt_1to_30[*,1], psym = 8, color = 255, symsize = .6
	if imonth eq 2L then oplot, maxt1to30[*,0],maxt1to30[*,1], psym = 8, color = 255, symsize = .6
	if imonth eq 1L then oplot, maxt_1to_30[*,0],maxt_1to_30[*,1], psym = 8, color = 250, symsize = .3
	if imonth eq 2L then oplot, maxt1to30[*,0],maxt1to30[*,1], psym = 8, color = 250, symsize = .3

	if imonth eq 1L then begin

		;;;;;;;;
    		; -----------------plot the color bar-----------------------

      		;print, max(meanGEOS5strats)
      		;plot the color bar
      		!type=2^2+2^3+2^6			; no y title or ticsks
      		imin=min(level1)
      		imax=max(level1)
      		slab=' '+strarr(n_elements(level1))
	
      		!p.title = ' '
      		plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,xticks=n_elements(level1)-1L,$
      		position = [px1a-.03,0.05, px1b-.01,.1],xstyle=1,xtickname=slab

      		ybox=[0,10,10,0,0]

      		x2=imin
      		for j=1,n_elements(col1)-1 do begin
        		dx= level1[j] - level1[j-1]
        		xbox=[x2,x2,x2+dx,x2+dx,x2]
        		polyfill,xbox,ybox,color=col1(j-1)
        		x2=x2+dx
      		endfor

     		slab=strcompress(string(format='(f7.3)',level1),/remove_all)
		slabcolor = fltarr(n_elements(level1))*0.
		slabcolor[0:2] = 255

		slabcolor = fltarr(n_elements(level1))*0.
		slabcolor[0:2] = 255
		x1=min(level1)+dx/2 + dx

		for i=1L,n_elements(slab)-1L do begin
   			slab0=slab(i)
   			flab0=float(slab(i))
      			slab0=strcompress(string(format='(I5.3)',flab0),/remove_all)
      			xyouts,x1-dx/2,.76,slab0,charsize=1.2,/data,color=slabcolor[i],charthick=4, orientation= 90.
   			x1=x1+dx
		endfor


		;----------------------
	endif


	;-----------------HEIGHT PLOTS---------------------------

    	;----------------------plot code---------------------      ;x = where(lons eq 0.00)
      	;lons[x] = 360.
      	level1 = findgen(14)*2.+42.
      	level1a = findgen(40)*2.+44.
	;level1 = [40,42,44,46,46.5,47,47.5,48,48.5,49,49.5,50,50.5,51,52,53,54,55]

	level3 = findgen(1)+.2
	nlvls  = n_elements(level1)
	col1 = (1 + indgen(nlvls)) * icolmax / nlvls	; define colors
	x = where(lat lt 99.)
	xx = where(lat le 99.)


  	map_set,90.,-90.,0,/ortho,  /grid,/noeras,/noborder,/contin,$
	position = [px2a,py1a - .42*(imonth-1L),px2b,py1b - .42*(imonth-1L)]
 
	fake = WACCMz
	x = where(WACCMz gt max(level1),nx)
	if nx gt 0 then fake[x] = max(level1)-.5
	x = where(WACCMz lt min(level1),nx)
	if nx gt 0 then fake[x] = min(level1) +.5



    	contour, fake[*,xx], lons, lat[xx], levels=level1, /cell_fill, c_color = col1,/overplot,$
      	min_value = -2., max_value =40000.,xticks = 4, /close, color = 0

    	contour,WACCMz[*,xx], lons, lat[xx], levels=level1a,color=0,charsize=3,$
	min_value = -2., max_value =40000.,/overplot, xticks=5, thick=1

    	map_set,90.,-90.,0,/ortho,  /grid,/noeras,/noborder,/contin, $
    	position = [px2a,py1a - .42*(imonth-1L),px2b,py1b - .42*(imonth-1L)]

	contour,vortexmarker[*,xx], lons, lat[xx], levels = [.3], /overplot, color =0.,thick = 10,$
	position = [px2a,py1a - .42*(imonth-1L),px2b,py1b - .42*(imonth-1L)]

	contour,antimarker[*,xx], lons, lat[xx], levels = [.3,.7], /overplot, color =255.,thick = 10,$
	position = [px2a,py1a - .42*(imonth-1L),px2b,py1b - .42*(imonth-1L)]

	
	oplot, findgen(361), 0.1+0.*findgen(361), color = 0

	if imonth eq 1L then oplot, maxz_1to_30[*,0],maxz_1to_30[*,1], psym = 8, color = 255, symsize = .6
	if imonth eq 2L then oplot, maxz1to30[*,0],maxz1to30[*,1], psym = 8, color = 255, symsize = .6
	if imonth eq 1L then oplot, maxz_1to_30[*,0],maxz_1to_30[*,1], psym = 8, color = 250, symsize = .3
	if imonth eq 2L then oplot, maxz1to30[*,0],maxz1to30[*,1], psym = 8, color = 250, symsize = .3

	if imonth eq 1L then begin
    		; -----------------plot the color bar-----------------------

      		;print, max(meanGEOS5strats)
      		;plot the color bar
      		!type=2^2+2^3+2^6			; no y title or ticsks
      		imin=min(level1)
      		imax=max(level1)
      		slab=' '+strarr(n_elements(level1))

      		!p.title = ' '
      		plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,xticks=n_elements(level1)-1L,$
      		position = [px2a+.01,.05,px2b,.1],xstyle=1,xtickname=slab


      		ybox=[0,10,10,0,0]

      		x2=imin
      		for j=1,n_elements(col1)-1 do begin
        		dx= level1[j] - level1[j-1]
        		xbox=[x2,x2,x2+dx,x2+dx,x2]
        		polyfill,xbox,ybox,color=col1(j-1)
        		x2=x2+dx
      		endfor

		;;;;;;;;      
     		slab=strcompress(string(format='(f7.3)',level1),/remove_all)
		slabcolor = fltarr(n_elements(level1))*0.
		slabcolor[0:2] = 255

		slabcolor = fltarr(n_elements(level1))*0.
		slabcolor[0:3] = 255

    		x1=min(level1)+dx/2 + dx

		for i=1L,n_elements(slab)-1L do begin
   			slab0=slab(i)
   			flab0=float(slab(i))
      			slab0=strcompress(string(format='(I5.2)',flab0),/remove_all)
      			xyouts,x1-dx/2,.76,slab0,charsize=1.2,/data,color=slabcolor[i],charthick=4, orientation= 90.
   			x1=x1+dx
		endfor
	endif; imonth=1
ENDFOR; imonth






;-----------------------------------------------------MLS----------------------------------------------------------


px1a = .51
px1b = 0.71
px2a = .73
px2b = .93

restore, '/Volumes/MacD68-1/france/WACCM_paper/Post_process/Figure_3_pre_process_composit_ES_MLS.sav'


for imonth = 1, 2L do begin


	vortexmarkcount = fltarr(n_elements(lon), n_elements(lat))
	antimarkcount = fltarr(n_elements(lon), n_elements(lat))
	waccmtmean = fltarr(n_elements(lon), n_elements(lat))
	waccmzmean = fltarr(n_elements(lon), n_elements(lat))


	; SET BAD OR MISSING DATA TO NAN
	z = where(t1to30 le 0.,nz)
	if nz gt 0L then t1to30[z]= !values.f_nan
	z = where(t31to60 le 0.,nz)
	if nz gt 0L then t31to60[z]= !values.f_nan
	z = where(z1to30 le 0.,nz)
	if nz gt 0L then z1to30[z]= !values.f_nan
	z = where(z31to60 le 0.,nz)
	if nz gt 0L then z31to60[z]= !values.f_nan
	z = where(t_1to_30 le 0.,nz)
	if nz gt 0L then t_1to_30[z]= !values.f_nan
	z = where(t_31to_60 le 0.,nz)
	if nz gt 0L then t_31to_60[z]= !values.f_nan
	z = where(z_1to_30 le 0.,nz)
	if nz gt 0L then z_1to_30[z]= !values.f_nan
	z = where(z_31to_60 le 0.,nz)
	if nz gt 0L then z_31to_60[z]= !values.f_nan


	;------------------AVERAGE MONTHLY MEANS AT EACH LAT/LON------------------
	if imonth eq 0L then begin
		for ii = 0, n_elements(lat) - 1L do begin
			for jj = 0, n_elements(lon) - 1L do begin
				x = where(mark_31to_60[*,jj,ii] lt 0. and mark_31to_60[*,jj,ii] gt -99.,nx)
				antimarkcount[jj,ii] = nx
				x = where(mark_31to_60[*,jj,ii] gt 0. and mark_31to_60[*,jj,ii] lt 99.,nx)
				vortexmarkcount[jj,ii] = nx
				waccmtmean[jj,ii] = meant_31to_60[2,jj,ii]
				waccmzmean[jj,ii] = meanz_31to_60[2,jj,ii]
			endfor
		endfor
	endif
	if imonth eq 1L then begin
		for ii = 0, n_elements(lat) - 1L do begin
			for jj = 0, n_elements(lon) - 1L do begin
				x = where(mark_1to_30[2,jj,ii] lt 0. and mark_1to_30[2,jj,ii] gt -99.,nx)
				antimarkcount[jj,ii] = nx
				x = where(mark_1to_30[2,jj,ii] gt 0. and mark_1to_30[2,jj,ii] lt 99.,nx)
				vortexmarkcount[jj,ii] = nx
				waccmtmean[jj,ii] = meant_1to_30[2,jj,ii]
				waccmzmean[jj,ii] = meanz_1to_30[2,jj,ii]
			endfor
		endfor
	endif
	if imonth eq 2L then begin
		for ii = 0, n_elements(lat) - 1L do begin
			for jj = 0, n_elements(lon) - 1L do begin
				x = where(mark1to30[2,jj,ii] lt 0. and mark1to30[2,jj,ii] gt -99.,nx)
				antimarkcount[jj,ii] = nx
				x = where(mark1to30[2,jj,ii] gt 0. and mark1to30[2,jj,ii] lt 99.,nx)
				vortexmarkcount[jj,ii] = nx
				waccmtmean[jj,ii] = meant1to30[2,jj,ii]
				waccmzmean[jj,ii] = meanz1to30[2,jj,ii]
			endfor
		endfor

	x = where(lat gt 50.)
	antimarkcount[*,x] = 0.
	endif
	if imonth eq 3L then begin
		for ii = 0, n_elements(lat) - 1L do begin
			for jj = 0, n_elements(lon) - 1L do begin
				x = where(mark31to60[2,jj,ii] lt 0. and mark31to60[2,jj,ii] gt -99.,nx)
				antimarkcount[jj,ii] = nx
				x = where(mark31to60[2,jj,ii] gt 0. and mark31to60[2,jj,ii] lt 99.,nx)
				vortexmarkcount[jj,ii] = nx
				waccmtmean[jj,ii] = meant31to60[2,jj,ii]
				waccmzmean[jj,ii] = meanz31to60[2,jj,ii]
			endfor
		endfor
	endif
	;------------------END: AVERAGE MONTHLY MEANS AT EACH LAT/LON------------------
	
	;;;-------------create wrap around for plot------------
    	antimarker = fltarr(n_elements(antimarkcount[*,0L]) + 2L, n_elements(antimarkcount[0L,*]))
    	antimarker[0L:n_elements(antimarkcount[*,0L]) - 1L, *] = antimarkcount[*,*]
   	antimarker[n_elements(antimarkcount[*,0L])-1L:n_elements(antimarkcount[*,0L])+1L,*] = antimarkcount[0L:2L,*]
   	lons = fltarr(n_elements(lon) + 2L)
   	lons[0:n_elements(lon)-1L] = lon
   	lons[n_elements(lon)-1L:n_elements(lon)+1L] = lon[0L:2L]

   	WACCMt = fltarr(n_elements(WACCMtmean[*,0L]) + 2L, n_elements(WACCMtmean[0L,*]))
    	WACCMt[0L:n_elements(WACCMtmean[*,0L]) - 1L, *] = WACCMtmean
   	WACCMt[n_elements(WACCMtmean[*,0L])-1L:n_elements(WACCMtmean[*,0L])+1L,*] = WACCMtmean[0L:2L,*]
     	WACCMZ = fltarr(n_elements(WACCMzmean[*,0L]) + 2L, n_elements(WACCMzmean[0L,*]))
    	WACCMZ[0L:n_elements(WACCMzmean[*,0L]) - 1L, *] = WACCMzmean
   	WACCMZ[n_elements(WACCMzmean[*,0L])-1L:n_elements(WACCMzmean[*,0L])+1L,*] = WACCMzmean[0L:2L,*]

    	vortexmarker = fltarr(n_elements(vortexmarkcount[*,0L]) + 2L, n_elements(vortexmarkcount[0L,*]))
    	vortexmarker[0L:n_elements(vortexmarkcount[*,0L]) - 1L, *] = vortexmarkcount[*,*]
   	vortexmarker[n_elements(vortexmarkcount[*,0L])-1L:n_elements(vortexmarkcount[*,0L])+1L,*] = vortexmarkcount[0L:2L,*]
   	lons = fltarr(n_elements(lon) + 2L)
   	lons[0:n_elements(lon)-1L] = lon
   	lons[n_elements(lon)-1L:n_elements(lon)+1L] = lon[0L:2L]
	;;;


   	WACCMz = smooth(WACCMz,3,/nan)
   	WACCMt = smooth(WACCMt,3,/nan)


	x = where(antimarker lt 0.,nx)
	if nx gt 0L then antimarker[x] = 0.00

	x = where(vortexmarker lt 0.,nx)
	if nx gt 0L then vortexmarker[x] = 0.00
 
	;;;Normalize marker
	z = where(lat le 0. and lat ge -99., comp=y)
	antimarker[*,z] = !values.f_nan
	antimarker = antimarker/max(antimarker[*,y],/nan)
	z = where(lat le 0. and lat ge -99., comp=y)
	vortexmarker[*,z] = !values.f_nan
	z = where(lat ge 82., comp=y)
	vortexmarker[*,z] = !values.f_nan
	vortexmarker=vortexmarker/max(vortexmarker[*,y],/nan)
	;;;

	vortexmarker = smooth(vortexmarker,3,/nan)
	antimarker = smooth(antimarker,3,/nan)
	
	if imonth eq 2L then begin
		x = where(lat gt 45.)
		vortexmarker[*,x] = 1.
	endif

	plot,[0,0],[0,0], position=[.5,.001,.999,.999], xstyle = 4, ystyle = 4, /noerase


	xyouts,.9,py1b - .49*(imonth-1L) - .08,titles1[imonth],color =0, orient = -90.
	;xyouts,.1,py1b - .42*(imonth-1L),titles3[imonth],color =0
	;xyouts,.47,py1b - .15*(imonth-1L),titles2[imonth],color =0
	xyouts, .03,.01,'Temperature (K)'
	xyouts, .56,.01,'Height (km)'
	xyouts, .3,.97,'MLS 2012', charsize = 4., charthick = 10

	; -------------PLOT TEMPERATURE CONTOUR PLOTS -----------------------
     	;lons[x] = 360.
        	level1 = findgen(13)*3.+240.
    	level1a = findgen(26)*3.+222.
	level3 = findgen(1)+.2
      	nlvls  = n_elements(level1)
	col1 = (1 + indgen(nlvls)) * icolmax / nlvls	; define colors
	x = where(lat lt 99.)
	xx = where(lat le 99.)


	map_set,90.,-90.,0,/ortho, /grid,/noeras,/noborder,/contin,$
	position = [px1a,py1a - .42*(imonth-1L),px1b,py1b - .42*(imonth-1L)]

	fake = WACCMt
	x = where(WACCMt gt max(level1),nx)
	if nx gt 0 then fake[x] = max(level1)-1.
	x = where(WACCMt lt min(level1),nx)
	if nx gt 0 then fake[x] = min(level1) +1.



	contour, fake[*,xx], lons, lat[xx], levels=level1, /cell_fill, c_color = col1,/overplot,$
	min_value = -2., max_value =40000.,xticks = 4, /close, color = 0

	contour,WACCMt[*,xx], lons, lat[xx], levels=level1a,color=0,charsize=3,$
	min_value = -2., max_value =40000.,/overplot, xticks=5, thick=1

	map_set,90.,-90.,0,/ortho, /grid,/noeras,/noborder,/contin, $
	position = [px1a,py1a - .42*(imonth-1L),px1b,py1b - .42*(imonth-1L)]


	contour,vortexmarker[*,xx], lons, lat[xx], levels = [.3], /overplot, color =0.,thick = 10,$
	position = [px1a,py1a - .42*(imonth-1L),px1b,py1b - .42*(imonth-1L)]

	contour,antimarker[*,xx], lons, lat[xx], levels = [.3,.7], /overplot, color =255.,thick = 10,$
	position = [px1a,py1a - .42*(imonth-1L),px1b,py1b - .42*(imonth-1L)]

	oplot, findgen(361), 0.1+0.*findgen(361), color = 0




	; -------------END: PLOT TEMPERATURE CONTOUR PLOTS -----------------------

	; -----------------plot the color bar-----------------------
	if imonth eq 1L then begin

		;;;;;;;;

		;print, max(meanGEOS5strats)
      		;plot the color bar
      		!type=2^2+2^3+2^6			; no y title or ticsks
      		imin=min(level1)
      		imax=max(level1)
      		slab=' '+strarr(n_elements(level1))

      		!p.title = ' '
      		plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,xticks=n_elements(level1)-1L,$
      		position = [px1a-.03,0.05, px1b-.01,.1],xstyle=1,xtickname=slab

      		ybox=[0,10,10,0,0]

      		x2=imin
      		for j=1,n_elements(col1)-1 do begin
        		dx= level1[j] - level1[j-1]
        		xbox=[x2,x2,x2+dx,x2+dx,x2]
        		polyfill,xbox,ybox,color=col1(j-1)
        		x2=x2+dx
      		endfor
	
     		slab=strcompress(string(format='(f7.3)',level1),/remove_all)
		slabcolor = fltarr(n_elements(level1))*0.
		slabcolor[0:2] = 255

		slabcolor = fltarr(n_elements(level1))*0.
		slabcolor[0:2] = 255
		x1=min(level1)+dx/2 + dx

		for i=1L,n_elements(slab)-1L do begin
   			slab0=slab(i)
   			flab0=float(slab(i))
   			slab0=strcompress(string(format='(I5.3)',flab0),/remove_all)
      			xyouts,x1-dx/2,.76,slab0,charsize=1.2,/data,color=slabcolor[i],charthick=4, orientation= 90.
   			x1=x1+dx
		endfor
	endif
	; -----------------END: plot the color bar-----------------------


	;-----------------PLOT HEIGHT CONTOUR PLOTS---------------------------

      	;lons[x] = 360.
     	level1 = findgen(14)*2.+42.
	level1a = findgen(40)*2.+44.
	;level1 = [40,42,44,46,46.5,47,47.5,48,48.5,49,49.5,50,50.5,51,52,53,54,55]

	level3 = findgen(1)+.2	nlvls  = n_elements(level1)
	col1 = (1 + indgen(nlvls)) * icolmax / nlvls	; define colors
	x = where(lat lt 99.)
	xx = where(lat le 99.)


	map_set,90.,-90.,0,/ortho,  /grid,/noeras,/noborder,/contin,$
	position = [px2a,py1a - .42*(imonth-1L),px2b,py1b - .42*(imonth-1L)]
 
	fake = WACCMz
	x = where(WACCMz gt max(level1),nx)
	if nx gt 0 then fake[x] = max(level1)-.5
	x = where(WACCMz lt min(level1),nx)
	if nx gt 0 then fake[x] = min(level1) +.5



	contour, fake[*,xx], lons, lat[xx], levels=level1, /cell_fill, c_color = col1,/overplot,$
	min_value = -2., max_value =40000.,xticks = 4, /close, color = 0

	contour,WACCMz[*,xx], lons, lat[xx], levels=level1a,color=0,charsize=3,$
	min_value = -2., max_value =40000.,/overplot, xticks=5, thick=1

	map_set,90.,-90.,0,/ortho,  /grid,/noeras,/noborder,/contin, $
	position = [px2a,py1a - .42*(imonth-1L),px2b,py1b - .42*(imonth-1L)]


	contour,vortexmarker[*,xx], lons, lat[xx], levels = [.3], /overplot, color =0.,thick = 10,$
	position = [px2a,py1a - .42*(imonth-1L),px2b,py1b - .42*(imonth-1L)]

	contour,antimarker[*,xx], lons, lat[xx], levels = [.3,.7], /overplot, color =255.,thick = 10,$
	position = [px2a,py1a - .42*(imonth-1L),px2b,py1b - .42*(imonth-1L)]

	oplot, findgen(361), 0.1+0.*findgen(361), color = 0
	
	;-----------------END: PLOT HEIGHT CONTOUR PLOTS---------------------------

	; -----------------plot the color bar-----------------------
	if imonth eq 1L then begin

		;print, max(meanGEOS5strats)
		;plot the color bar
		!type=2^2+2^3+2^6			; no y title or ticsks
		imin=min(level1)
		imax=max(level1)
		slab=' '+strarr(n_elements(level1))

		!p.title = ' '
		plot,[imin,imax],[0,0],yrange=[0,10],xrange=[imin,imax],/noeras,xticks=n_elements(level1)-1L,$
		position = [px2a+.01,.05,px2b,.1],xstyle=1,xtickname=slab


		ybox=[0,10,10,0,0]

		x2=imin
		for j=1,n_elements(col1)-1 do begin
			dx= level1[j] - level1[j-1]
			xbox=[x2,x2,x2+dx,x2+dx,x2]
			polyfill,xbox,ybox,color=col1(j-1)
			x2=x2+dx
		endfor

		;;;;;;;;      
		slab=strcompress(string(format='(f7.3)',level1),/remove_all)
		slabcolor = fltarr(n_elements(level1))*0.
		slabcolor[0:2] = 255

		slabcolor = fltarr(n_elements(level1))*0.
		slabcolor[0:3] = 255

		x1=min(level1)+dx/2 + dx

		for i=1L,n_elements(slab)-1L do begin
			slab0=slab(i)
			flab0=float(slab(i))
			slab0=strcompress(string(format='(I5.2)',flab0),/remove_all)
			xyouts,x1-dx/2,.76,slab0,charsize=1.2,/data,color=slabcolor[i],charthick=4, orientation= 90.
			x1=x1+dx
		endfor
	endif; imonth=1
	; -----------------END: plot the color bar-----------------------
ENDFOR; imonth





;--------------------------------  CONVERT .PS TO .PNG  ---------------------------------------


if setplot eq 'ps' then begin
	device, /close
	spawn,'pstopnm -dpi=300 -landscape idl.ps'	spawn,'pnmtopng idl001.ppm > /Volumes/MacD68-1/france/WACCM_paper/Figures/Figure_4_WACCM_MLS.png'
	spawn,'rm idl001.ppm idl.ps'
endif
;-------------------------------- END: CONVERT .PS TO .PNG  ---------------------------------------

end
