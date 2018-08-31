pro gcm_color_table,setplot,colbw,icolmax,icmm1,icmm2

;------------------------------------------------------------------------
;
; procedure to customize and load color table for gcm plotting codes
;
; input parameters:
;
;   setplot       character          flag, 'ps' to create postscript file
;                                    or 'x' to plot to screen
;   colbw         character          flag, 'col' for color plots, 'gs' for
;                                    grayscale plots, 'bw' for black &
;                                    white plots (no shading or colors)
;
; returned parameters:
;
;   icolmax       byte               array index of final entry in color
;                                    table: (number of colors) - 1
;                                    ie, for 256 colors, icolmax=255 and
;                                    colors are indexed (0:255)
;   icmm1         byte               icolmax-1
;   icmm2         byte               icolmax-2
;
;------------------------------------------------------------------------

loadct,38
icolmax=byte(!p.color)
icolmax=fix(icolmax)
if icolmax eq 0 then icolmax=255
icmm1=icolmax-1
icmm2=icolmax-2

common colors,r_orig,g_orig,b_orig,r_curr,g_curr,b_curr
r_curr=r_orig & g_curr=g_orig & b_curr=b_orig

;
;C Adjust color table #38 for either x-windows or postscript plots

;C set up indices for color table arrays
if colbw eq 'tr' then ncol=10 else if colbw eq 'gs' then ncol=8 else ncol=16
i1 = 1+icolmax*indgen(ncol)/ncol
i2 = reverse(icolmax-i1)

;C define color table values for either grayscale or color plots
;
if colbw eq 'gs' then begin
;
  red = [  81B, 104B, 127B, 150B, 173B, 196B, 219B, 242B  ]
  red = reverse(red)
  grn = red
  blu = red
;
endif else if colbw eq 'tr' then begin
;
  red = [ 204B, 102B,   0B,   0B,   0B, 102B, 255B, 255B, 255B,  51B ]
;
  grn = [   0B,   0B,  51B, 153B, 255B, 102B, 255B, 153B,   0B,   0B ]
;
  blu = [ 204B, 204B, 255B, 204B,   0B,   0B,   0B,  51B,  51B,   0B ]

endif else begin
;
  red = [ 150B, 200B, 100B, 100B, 100B,   0B, 150B, 200B, $
          150B, 200B, 255B, 255B, 255B, 255B, 200B, 175B  ]
;
  grn = [   0B,   0B, 100B, 100B, 100B, 140B, 170B, 200B, $
          200B, 255B, 255B, 200B, 160B, 125B,  50B,  50B  ]
;
  blu = [ 150B, 200B, 150B, 200B, 255B,   0B,   0B,   0B, $
            0B, 120B,   0B,   0B,   0B,   0B, 100B,  75B  ]
endelse

;C fill color table arrays
;
r_curr(  0)=  0B      &  g_curr(  0)=  0B      &  b_curr(  0)=  0B
r_curr(icolmax)=255B  &  g_curr(icolmax)=255B  &  b_curr(icolmax)=255B
;
for m=0,ncol-1 do begin
  r_curr(i1(m):i2(m))=red(m)
  g_curr(i1(m):i2(m))=grn(m)
  b_curr(i1(m):i2(m))=blu(m)
endfor

tvlct,r_curr,g_curr,b_curr

end
