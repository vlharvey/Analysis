pro bimodal, X, A, F, pder

F = A[0] * exp(-((x-A[1])^2.)/(2.*(A[2]^2.)))+ A[3] * exp(-((x-A[4])^2.)/(2.*(A[5]^2.)))

IF N_PARAMS() GE 4 THEN begin ; If the procedure is called with four parameters, calculate the partial derivatives.
   pder = FLTARR(N_ELEMENTS(X), 6)
;
; Compute the partial derivatives with respect to A
;
   pder[*, 0] = exp(-((x-A[1])^2)/(2*A[2]^2.))
   pder[*, 3] = exp(-((x-A[4])^2)/(2*A[5]^2.))

   pder[*, 1] = A[0]*(x-A[1])*exp(-(x-A[1])^2./(2*A[2]^2.))/A[2]^2.
   pder[*, 4] = A[3]*(x-A[4])*exp(-(x-A[4])^2./(2*A[5]^2.))/A[5]^2.

   pder[*, 2] = A[0]*(A[1]-x)^2.*exp(-(A[1]-x)^2./(2.*A[2]^2.))/(2.*A[2]^3)
   pder[*, 5] = A[3]*(A[4]-x)^2.*exp(-(A[4]-x)^2./(2.*A[5]^2.))/(2.*A[5]^3)

endif
end
