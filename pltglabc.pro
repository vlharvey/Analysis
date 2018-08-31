      setplot='x'
      set_plot,setplot
      !type=2^2+2^3
      im = 144
      jm = 91 
      x=-180+360.*findgen(144)/144.
      y=-90+180.*findgen(91)/90.
      !xmin=-180
      !xmax=180
      !xticks=6
      !xtitle='Longitude'
      !ymax=90
      !ymin=-90
      !yticks=6
      !ytitle='Latitude'
      month='   '                         
      nam1='    '
      nam2='    '
      nam3='    '
      nam4='    '
      nam5='    '
; topography (Z or z?)
      topg=fltarr(im,jm)
; topography variance
      topv=fltarr(im,jm)
; land/water ice identifier
      zlwi=fltarr(im,jm)
; sst
      sst=fltarr(im,jm)
; albedo
      alb=fltarr(im,jm)
; ground wetness
      wet=fltarr(im,jm)
; sea ice thickness
      thk=fltarr(im,jm)
; surface something
      srf=fltarr(im,jm)

      close,10
      openr,10,'gcmbc',/f77
; number rows*columns
      forrd,10,imjm
; names of arrays
      forrd,10,nam1
      forrd,10,topg
      forrd,10,nam2
      forrd,10,topv
      forrd,10,nam3
      forrd,10,zlwi
;goto, skip1
      z=topg
      level=min(z)+(max(z)-min(z))*findgen(30)/29.
      ci=string(level(1)-level(0))
      mtitle='GLA 2x2.5 bc: '+nam1+' ci='+ci
      !mtitle=mtitle
      label=1+0*level
      contour,z,x,y,level=level,c_label=label,c_linestyle=level lt 0
      if setplot eq 'x' then stop
      if setplot eq 'ps' then print,mtitle
      z=sqrt(topv)
      level=min(z)+(max(z)-min(z))*findgen(10)/10.
      ci=string(level(1)-level(0))
      mtitle='GLA 2x2.5 bc: '+nam2+' ci='+ci
      !mtitle=mtitle
      label=1+0*level
; contour topography
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

