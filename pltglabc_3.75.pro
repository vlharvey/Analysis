; read in 2dg lat by 2.5dg lon topography data and interpolate
; to 2.5dg lat by 3.75dg lon grid, plot, and write out.
; NOTE:  latitudes go from North to South and topography grid
;        will match z,t and go from 90 to -90 and 0 to 360
;        96 longitudes

      setplot='x'
      set_plot,setplot
      !type=2^2+2^3
      im = 144
      im2= 96
      jm = 91 
      jm2= 73
      x=-180+2.5*findgen(im)
      x1=0+2.5*findgen(im)
      x2=0+3.75*findgen(im2)
      y=-90+2.*findgen(jm)
      y2=-90+2.5*findgen(jm2)
      y3=90-2.5*findgen(jm2)
;     !xmin=-180
;     !xmax=180
      !xmin=0
      !xmax=360
      !xticks=6
      !xtitle='Longitude'
;     !ymax=90
;     !ymin=-90
      !ymax=-90
      !ymin=90
      !yticks=6
      !ytitle='Latitude'
      month='   '                         
      nam1='    '
      nam2='    '
      nam3='    '
      nam4='    '
      nam5='    '
      topg=fltarr(im,jm)	; topography (in geopotential meters)
      topg1=fltarr(im,jm)	; shift longitudes 180
      temp=fltarr(im,jm2)	; interpolated lats
      topg2=fltarr(im2,jm2)	; interpolated lats & lons
      topv=fltarr(im,jm)	; topography variance
      zlwi=fltarr(im,jm)	; land/water ice identifier
      sst=fltarr(im,jm)		; sea surface temperature
      alb=fltarr(im,jm)		; albedo
      wet=fltarr(im,jm)		; ground wetness
      thk=fltarr(im,jm)		; sea ice thickness
      srf=fltarr(im,jm)		; surface something
      close,10
      openr,10,'gcmbc',/f77
      forrd,10,imjm		; number of rows*columns
      forrd,10,nam1		; titles
      forrd,10,topg
      forrd,10,nam2
      forrd,10,topv
      forrd,10,nam3
      forrd,10,zlwi
      close,10
;goto, skip1

; shift 180 degrees in longitude to match UKMO data
      data=topg
      data(0:im/2-1,*)=data(im/2:im-1,*)
      data(im/2:im-1,*)=topg(0:im/2-1,*)
      topg1=data

; interpolate from 2dg lat to 2.5dg lat (topg1->temp)
      for j2=0,jm2-2 do begin		; 1-73 by 2.5
          for j=0,jm-2 do begin		; 1-91 by 2
              if y(j) eq y2(j2) then begin
                 temp(*,j2)=topg1(*,j)	; multiples of 10dg are same
                 goto,jumplat
              endif
              if y(j) lt y2(j2) and y(j+1) gt y2(j2) then begin
                 scale=(y(j+1)-y2(j2))/(y(j+1)-y(j))
                 temp(*,j2)=topg1(*,j+1)-scale*(topg1(*,j+1)-topg1(*,j))
                 goto,jumplat
              endif
          endfor
          jumplat:
      endfor
      temp(*,jm2-1)=topg1(*,jm-1)

; interpolate from 2.5dg lon to 3.75dg lon (temp->topg2)
      for i2=0,im2-1 do begin		; 1-96 by 3.75
          for i=0,im-2 do begin		; 1-144 by 2.5
              if x1(i) eq x2(i2) then begin
                 topg2(i2,*)=temp(i,*)  ; some are the same
                 goto,jumplon
              endif
              if x1(i) lt x2(i2) and x1(i+1) gt x2(i2) then begin
                 scale=(x1(i+1)-x2(i2))/(x1(i+1)-x1(i))
                 topg2(i2,*)=temp(i+1,*)-scale*(temp(i+1,*)-temp(i,*))
                 goto,jumplon
              endif
          endfor
          jumplon:
      endfor

; topg2 now goes from -90 to 90 by 2.5 and 0 to 360 by 3.75
; now reverse the latitudes to match daily UKMO format
      topg3=fltarr(im2,jm2)
      for j=0,jm2-1 do begin
          jj=jm2-1-j
          topg3(*,j)=topg2(*,jj)
      endfor
   
; write out 2.5dg by 3.75dg topography 90to-90
;     openw,20,'topg3.75',/f77
;     writeu,20,topg3
;     close,20

; plot
      z=topg3
;     z=topg1
      level=min(z)+(max(z)-min(z))*findgen(30)/29.
      ci=string(level(1)-level(0))
      mtitle='GLA 2.5x3.75 bc: '+nam1+' ci='+ci
      !mtitle=mtitle
      label=1+0*level
      contour,z,x2,y2,level=level,c_label=label,c_linestyle=level lt 0
;     contour,z,x1,y,level=level,c_label=label,c_linestyle=level lt 0
      if setplot eq 'x' then stop
      if setplot eq 'ps' then print,mtitle
      z=sqrt(topv)
      level=min(z)+(max(z)-min(z))*findgen(10)/10.
      ci=string(level(1)-level(0))
      mtitle='GLA 2x2.5 bc: '+nam2+' ci='+ci
      !mtitle=mtitle
      label=1+0*level
      contour,z,x,y,level=level,c_label=label,c_linestyle=level lt 0
      if setplot eq 'x' then stop
      if setplot eq 'ps' then print,mtitle
      z=zlwi
      level=[0,1,2,3]
      ci=string(level(1)-level(0))
      mtitle='GLA 2x2.5 bc: '+nam3+' ci='+ci
      !mtitle=mtitle
      label=1+0*level
      contour,z,x,y,level=level,c_label=label,c_linestyle=level lt 0
      if setplot eq 'x' then stop
      if setplot eq 'ps' then print,mtitle
skip1:
; read in things that vary with time (monthly averages)
      for m=1,12 do begin
      
      forrd,10,month,nam1
      forrd,10,sst
      forrd,10,month,nam2
      forrd,10,alb
      forrd,10,month,nam3
      forrd,10,wet
      forrd,10,month,nam4
      forrd,10,thk
      forrd,10,month,nam5
      forrd,10,srf
goto, skip2
      z=sst
      level=min(z)+(max(z)-min(z))*findgen(10)/10.
      ci=string(level(1)-level(0))
      mtitle='GLA 2x2.5 bc: '+month+' '+nam1+' ci='+ci
      !mtitle=mtitle
      label=1+0*level
      contour,z,x,y,level=level,c_label=label,c_linestyle=level lt 0
      if setplot eq 'x' then stop
      if setplot eq 'ps' then print,mtitle
skip2:
      z=alb
      level=.05+.1*findgen(30) 
      ci=string(level(1)-level(0))
      mtitle='GLA 2x2.5 bc: '+month+' '+nam2+' ci='+ci
      !mtitle=mtitle
      label=1+0*level
      contour,z,x,y,level=level,c_label=label,c_linestyle=level lt 0
      print,max(alb),min(alb)
      if setplot eq 'x' then stop
      if setplot eq 'ps' then print,mtitle
goto, skip3
      z=wet
      level=min(z)+(max(z)-min(z))*findgen(10)/10.
      ci=string(level(1)-level(0))
      mtitle='GLA 2x2.5 bc: '+month+' '+nam3+' ci='+ci
      !mtitle=mtitle
      label=1+0*level
      contour,z,x,y,level=level,c_label=label,c_linestyle=level lt 0
      if setplot eq 'x' then stop
      if setplot eq 'ps' then print,mtitle
;skip2:
      z=thk
      level=min(z)+(max(z)-min(z))*findgen(10)/10.
      ci=string(level(1)-level(0))
      mtitle='GLA 2x2.5 bc: '+month+' '+nam4+' ci='+ci
      !mtitle=mtitle
      label=1+0*level
      contour,z,x,y,level=level,c_label=label,c_linestyle=level lt 0
      if setplot eq 'x' then stop
      if setplot eq 'ps' then print,mtitle
goto, skip3
      z=srf
      level=min(z)+(max(z)-min(z))*findgen(10)/10.
      ci=string(level(1)-level(0))
      mtitle='GLA 2x2.5 bc: '+month+' '+nam5+' ci='+ci
      !mtitle=mtitle
      label=1+0*level
      contour,z,x,y,level=level,c_label=label,c_linestyle=level lt 0
      if setplot eq 'x' then stop
      if setplot eq 'ps' then print,mtitle
skip3:
      endfor

      stop
      end

