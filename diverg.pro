      SUBROUTINE DIVERG (MERIDS,LATS,U,V,DIV,DUD)
C
      DIMENSION  U(MERIDS,LATS),V(MERIDS,LATS),DIV(MERIDS,LATS)
C
      DATA PI /3.14159/ ,RAD /6 371 000/
C
      RLAT (J) = PI*(.5 + (.5-J)/LATS)
C
C----------------------------------------------------------------------C
C          CALCULATE DIVERGENCE ( TIMES 1 000 000 )
C------------------------------------------ AUTHOR: M FISHER 1985 -----C
C
      DPHI = PI/LATS
      RDPHI= 1./DPHI
      DPHIB2=DPHI*.5
      RDLAM=.5*MERIDS/PI
C
      COSMM = SIN (DPHIB2)
      COSM  = 0.
      COS0  = -COSMM
C
      DO 10 JN=1,LATS/2
C
      JS   = LATS+1-JN
      JNM  = JN+1
      JNMM = JN+2
      JSP  = JS-1
      JSPP = JS-2
C
      IF (JN .LE. 2) THEN
            JNPP = 3-JN
            JNP  = 1
      ELSE
            JNPP = JN-2
            JNP  = JN-1
      END IF
C
      JSMM = LATS+1 - JNPP
      JSM  = LATS+1 - JNP
C
C-----------------------------------------------------------------------
C IN THE ABOVE N/S =>HEMISPHERE, P/M => +/-DPHI, PP/MM => +/- 2*DPHI
C-----------------------------------------------------------------------
C
      PHI = RLAT (JN)
C
      COSPP = COS0
      COSP  = COSM
      COS0  = COSMM
      COSM  = COS (PHI-DPHIB2)
      COSMM = COS (PHI-DPHI)
C
      C  = 1 000 000./(12.*RAD*COS0)
      B  = C*RDPHI
      B8 = 8.*B
C
      A1 = C*RDLAM
      A2 = 8.*A1
      A3 = B8*COSP
      A4 =-B8*COSM
      A5 =-B *COSPP
      A6 = B *COSMM
      A7 = A3+A4+A5+A6
C
      DO 10 IWW=1,MERIDS
C
      IW  = 1 + MOD (IWW,MERIDS)
      I   = 1 + MOD (IW ,MERIDS)
      IE  = 1 + MOD (I  ,MERIDS)
      IEE = 1 + MOD (IE ,MERIDS)
C
      IF (JN .LE. 2) THEN
            IPP = 1 + MOD (I-1+MERIDS/2,MERIDS)
            IF (JN .EQ. 1) THEN
                  IP = IPP
            ELSE
                  IP = I
            END IF
      ELSE
            IPP = I
            IP  = I
      END IF
C
      DIV (I,JN) =   A2*(U(IE ,JN) - U(IW ,JN))
     *              +A1*(U(IWW,JN) - U(IEE,JN))
     *              +A3* V(IP ,JNP )
     *              +A4* V(I  ,JNM )
     *              +A5* V(IPP,JNPP)
     *              +A6* V(I  ,JNMM)
     *              +A7* V(I  ,JN  )
C
      DIV (I,JS) =   A2*(U(IE ,JS) - U(IW ,JS))
     *              +A1*(U(IWW,JS) - U(IEE,JS))
     *              -A3* V(IP ,JSM )
     *              -A4* V(I  ,JSP )
     *              -A5* V(IPP,JSMM)
     *              -A6* V(I  ,JSPP)
     *              -A7* V(I  ,JS  )
C
   10 CONTINUE
C
C-----------------------------------------------------------------------
C
C   PROPAGATE MISSING DATA INDICATORS
C
C-----------------------------------------------------------------------
C
      DO 50 IWW = 1,MERIDS
C
      IW = 1+MOD (IWW,MERIDS)
      I  = 1+MOD (IW ,MERIDS)
C
      DO 50 J   = 1,LATS
C
      IF (U(I,J) .EQ. DUD) THEN
            IE  = 1+MOD (I ,MERIDS)
            IEE = 1+MOD (IE,MERIDS)
C
            DIV(IWW,J) = DUD
            DIV(IW ,J) = DUD
            DIV(IE ,J) = DUD
            DIV(IEE,J) = DUD
      END IF
C
      IF (V(I,J) .EQ. DUD) THEN
            IN  = I
            INN = I
            IS  = I
            ISS = I
            JN  = J-1
            JNN = J-2
            JS  = J+1
            JSS = J+2
C
            IF      (J .EQ. 1)      THEN
                  INN = 1+MOD (I-1 +MERIDS/2,MERIDS)
                  IN  = INN
                  JNN = 2
                  JN  = 1
            ELSE IF (J .EQ. 2)      THEN
                  INN = 1+MOD (I-1 +MERIDS/2,MERIDS)
                  JNN = 1
            ELSE IF (J .EQ. LATS-1) THEN
                  ISS = 1+MOD (I-1 +MERIDS/2,MERIDS)
                  JSS = LATS
            ELSE IF (J .EQ. LATS)   THEN
                  ISS = 1+MOD (I-1 +MERIDS/2,MERIDS)
                  IS  = ISS
                  JSS = LATS-1
                  JS  = LATS
            END IF
C
            DIV(I   ,J ) = DUD
            DIV(IN ,JN ) = DUD
            DIV(INN,JNN) = DUD
            DIV(IS ,JS ) = DUD
            DIV(ISS,JSS) = DUD
      END IF
C
   50 CONTINUE
C
      RETURN
      END
