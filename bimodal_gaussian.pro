PRO Bimodal, X, A, F, pder

	F = A[0] * exp(-((x-A[1])^2.)/(2.*(A[2]^2.)))+ A[3] * exp(-((x-A[4])^2.)/(2.*(A[5]^2.)))
	
	IF N_PARAMS() GE 4 THEN begin ; If the procedure is called with four parameters, calculate the partial derivatives.
		pder = FLTARR(N_ELEMENTS(X), 6)
		; Compute the partial derivatives with respect to A
		pder[*, 0] = exp(-((x-A[1])^2)/(2*A[2]^2.))
		pder[*, 3] = exp(-((x-A[4])^2)/(2*A[5]^2.))
		
		pder[*, 1] = A[0]*(x-A[1])*exp(-(x-A[1])^2./(2*A[2]^2.))/A[2]^2.
		pder[*, 4] = A[3]*(x-A[4])*exp(-(x-A[4])^2./(2*A[5]^2.))/A[5]^2.
		
		pder[*, 2] = A[0]*(A[1]-x)^2.*exp(-(A[1]-x)^2./(2.*A[2]^2.))/(2.*A[2]^3)
		pder[*, 5] = A[3]*(A[4]-x)^2.*exp(-(A[4]-x)^2./(2.*A[5]^2.))/(2.*A[5]^3)
	endif
end
	
 		restore, '/Users/franceja/Downloads/pdf4jeff.sav'
	  		X = level
			Y = COPDF
			weights = Y*0. + 1. ; Define a vector of weights.
			Aguess = fltarr(6)
			m1 = where(y eq max(y))
			Aguess[0] = y[m1]*1.
			Aguess[1] = x[m1]*1.
			Aguess[2] = .3
			
			m2 = 0L
			smoothcopdf = smooth(copdf,3)
			for i = m1[0]+2L, n_elements(Y) - 2L do begin
				if smoothcopdf[i] gt smoothcopdf[i-1L] and $
				   smoothcopdf[i] gt smoothcopdf[i+1L] then m2 = i ;selects next local maximum as initial guess for 2nd gaussian
			endfor

			Aguess[3] = y[m2]*1.
			Aguess[4] = x[m2]*1.
			Aguess[5] = .3
			A = aguess
			
			; Provide an initial guess of the function's parameters.
			yfit = CURVEFIT(X, Y, weights, A, SIGMA, FUNCTION_NAME='bimodal')

loadct, 39

plot, level,A[0] * exp((-((x-A[1])^2)/(2*A[2]^2))), color = 80.,xtitle = 'Concentration (ppmv)',ytitle = 'Occurrence (%)'
oplot, level,A[3] * exp((-((x-A[4])^2)/(2*A[5]^2))),color = 250.
loadct,0
oplot, level,copdf, color = 255.
end

