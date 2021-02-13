C&&& A21
C  TEST ALG. 21 VARIABLE METRIC FUNCTION MINIMISATION
C  J.C. NASH   JULY 1978, APRIL 1989
      INTEGER N,ND,NDC,I,J,LIMIT,NIN,NOUT,LIMIT2
      REAL B(4),STEP,VL,BH(4,4),X(4),C(4),G(4),T(4)
      LOGICAL NOCOM
      EXTERNAL WFUN,WDER
C  I/O CHANNELS
      NIN=5
      NOUT=6
      N=4
      ND=5
      NDC=6
   1  READ(NIN,901)STEP,LIMIT,LIMIT2
 901  FORMAT(F10.5,2I5)
      IF(STEP.EQ.0.0)STOP
      IF(LIMIT.LE.0)STOP
      WRITE(NOUT,951)STEP,LIMIT,LIMIT2
 951  FORMAT(' PROBLEM=WOOD4 STEPSIZE=',F15.10,'  LIMITS',2I5)
      READ(NIN,902)B
 902  FORMAT(4F10.5)
      WRITE(NOUT,953)
 953  FORMAT(' INITIAL POINT')
      WRITE(NOUT,952)B
 952  FORMAT(1H ,4F15.10)
C  REPLACE 0 WITH NOUT IF YOU WANT INTERMEDIATE OUTPUT
      CALL A21VM(N,B,BH,4,X,C,G,T,LIMIT,LIMIT2,NOCOM,0,VL,WFUN,WDER)
      WRITE(NOUT,954)VL,LIMIT
 954  FORMAT(' CONV. TO',1PE16.8,' IN',I5)
      WRITE(NOUT,952)B
      WRITE(NOUT,910)
 910  FORMAT(' ')
      GOTO 1
      END
      SUBROUTINE A21VM(N,B,BH,NBH,X,C,G,T,IFN,IG,NOCOM,IPR,P0,FUN,DER)
C  ALGORITHM 21 VARIABLE METRIC FUNCTION MINIMIZATION
C  J.C. NASH   JULY 1978, FEBRUARY 1980, APRIL 1989
C  N = NO. OF PARAMETERS TO BE ADJUSTED
C  B = INITIAL SET OF PARAMETERS (INPUT)
C    = MINIMUM  (OUTPUT)
C  BH= WORKING ARRAY
C  NBH= FIRST DIMENSION OF BH
C  X,C,G,T = WORKING VECTORS OF LENGTH AT LEAST N
C  ON OUTPUT G CONTAINS LAST GRADIENT EVALUATED
C  IFN= COUNT OF FUNCTION EVALUATIONS USED
C     = LIMIT ON THESE (INPUT)
C  IG = COUNT OF GRADIENT EVALUATIONS USED
C  NOCOM = LOGICAL FLAG SET .TRUE. IF INITIAL POINT INFEASIBLE
C  IPR = PRINTER CHANNEL.  PRINTING ONLY IF IPR.GT.0
C  P0 = MINIMAL FUNCTION VALUE
C  FUN = NAME OF FUNCTION SUBROUTINE
C  DER = NAME OF DERIVATIVE SUBROUTINE
C     CALLING SEQUENCE   P=FUN(N,B,NOCOM) -- OTHER INFO. PASSED
C     CALLING SEQUENCE   CALL DER(N,B,G)  --  THROUGH COMMON
C  STEP 0
      LOGICAL NOCOM
      INTEGER N,NBH,IFN,IG,IPR,ILAST,I,J,COUNT
      REAL B(N),BH(NBH,N),X(N),C(N),G(N),T(N),P0,W,TOL,K,S,D1,D2,P
      IG=0
      LIFN=IFN
      IFN=0
      W=0.2
      TOL=0.0001
C  STEP 1
      NOCOM=.FALSE.
      P0=FUN(N,B,NOCOM)
      IFN=IFN+1
      IF(NOCOM)RETURN
C  STEP 2  - ASSUME DERIVATIVES CAN BE COMPUTED IF FUNCTION CAN
      CALL DER(N,B,G)
      IG=IG+1
C  STEP 3
  30  DO 35 I=1,N
        DO 32 J=1,N
          BH(I,J)=0.0
  32    CONTINUE
        BH(I,I)=1.0
  35  CONTINUE
      ILAST=IG
C  STEP 4
  40  IF(IPR.GT.0)WRITE(IPR,950)IG,IFN,P0
 950  FORMAT( 6H AFTER,I4,8H GRAD. &,I4,22H FN EVALUATIONS, FMIN=,
     *1PE16.8)
      DO 45 I=1,N
        X(I)=B(I)
        C(I)=G(I)
  45  CONTINUE
C  STEP 5
      D1=0.0
      DO 55 I=1,N
        S=0.0
        DO 53 J=1,N
          S=S-BH(I,J)*G(J)
  53    CONTINUE
        T(I)=S
        D1=D1-S*G(I)
  55  CONTINUE
C  STEP 6
      IF(D1.GT.0.0)GOTO 70
      IF(ILAST.EQ.IG)GOTO 180
      GOTO 30
  70  K=1.0
C  STEP 7
C  STEP 8
  80  COUNT=0
      DO 85 I=1,N
        B(I)=X(I)+K*T(I)
        IF(B(I).EQ.X(I))COUNT=COUNT+1
  85  CONTINUE
C  STEP 9
      IF(COUNT.LT.N)GOTO 100
      IF(ILAST.EQ.IG)GOTO 180
      GOTO 30
C  STEP 10
 100  IFN=IFN+1
      IF(IFN.GT.LIFN)GOTO 175
      P=FUN(N,B,NOCOM)
      IF(.NOT.NOCOM)GOTO 110
      K=W*K
      GOTO 80
C  STEP 11
 110  IF(P.LT.P0-D1*K*TOL)GOTO 120
      K=W*K
      GOTO 80
 120  P0=P
      IG=IG+1
      CALL DER(N,B,G)
C  STEP 13
      D1=0.0
      DO 135 I=1,N
        T(I)=K*T(I)
        C(I)=G(I)-C(I)
        D1=D1+T(I)*C(I)
 135  CONTINUE
C  STEP 14
      IF(D1.LE.0.0)GOTO 30
C  STEP 15
      D2=0.0
      DO 156 I=1,N
        S=0.0
        DO 154 J=1,N
          S=S+BH(I,J)*C(J)
 154    CONTINUE
        X(I)=S
        D2=D2+S*C(I)
 156  CONTINUE
C  STEP 16
      D2=1.0+D2/D1
      DO 165 I=1,N
        DO 164 J=1,N
          BH(I,J)=BH(I,J)-(T(I)*X(J)+X(I)*T(J)-D2*T(I)*T(J))/D1
 164    CONTINUE
 165  CONTINUE
C  STEP 17
      GOTO 40
C  RESET B IN CASE FN EVALN LIMIT REACHED
 175  DO 177 I=1,N
        B(I)=X(I)
 177  CONTINUE
 180  IF(IPR.LE.0)RETURN
      WRITE(IPR,951)
 951  FORMAT(10H0CONVERGED)
      WRITE(IPR,950)IG,IFN,P0
      RETURN
      END
      FUNCTION WFUN(N,B,NOCOM)
C  J.C. NASH   JULY 1978, APRIL 1989
      LOGICAL NOCOM
      INTEGER N
      REAL B(N),FV,D(4)
      IF(N.NE.4)STOP
      NOCOM=.FALSE.
      CALL WOOD4(FV,D,B,0,.FALSE.)
      WFUN=FV
      RETURN
      END
      SUBROUTINE WDER(N,B,G)
C  J.C. NASH   JULY 1978, APRIL 1989
      INTEGER N
      REAL B(N),G(4),FV
      IF(N.NE.4)STOP
      CALL WOOD4(FV,G,B,0,.TRUE.)
      RETURN
      END
      SUBROUTINE WOOD4(FVAL,D,X,I,MODE)
C  J.C. NASH   JULY 1978, APRIL 1989
C  WOOD'S 4 PARAMETER FUNCTION
C  FVAL  =  FUNCTION VALUE OR RESIDUAL VALUE AT POINT I
C   D    =  DERIVATIVES OF RESIDUAL I
C   X    =  POINT
C   I    =  OBSERVATION NO.  IF 0  THEN  COMPUTE SUM OF SQUARES OR GRAD
C  MODE  =  F  FN OR  RES, T  DERIVS. OR GRADIENT
      LOGICAL MODE
      INTEGER I
      REAL X(4),D(4)
C  HILLSTROM EXPRESSIONS
      IF(MODE) GOTO 500
      IF(I.GT.0)GOTO 250
C   SUM OF SQUARES TOTAL FN
      FVAL=100.0*(X(2)-X(1)**2)**2 + (1.0-X(1))**2
      FVAL=FVAL + 90.0*(X(4)-X(3)**2)**2
      FVAL=FVAL + (1.0-X(3))**2
      FVAL=FVAL + 10.1*((X(2)-1.0)**2 + (X(4)-1.0)**2)
      FVAL=FVAL + 19.8*(X(2)-1.0)*(X(4)-1.0)
      RETURN
C   RESIDUALS
 250  GOTO (310,320,330,340,350,360,370),I
 310  FVAL=10.0*(X(2)-X(1)**2)
      RETURN
 320  FVAL=1.0-X(1)
      RETURN
 330  FVAL=SQRT(90.0)*(X(4)-X(3)**2)
      RETURN
 340  FVAL=1.0-X(3)
      RETURN
 350  FVAL=SQRT(0.2)*(X(2)-1.0)
      RETURN
 360  FVAL=SQRT(0.2)*(X(4)-1.0)
      RETURN
 370  FVAL=SQRT(9.9)*(X(2)+X(4)-2.0)
      RETURN
C    DERIVATIVES
 500  IF(I.GT.0)GOTO 750
C   GRADIENT OF FN
      D(1)=-400.0*(X(2)-X(1)**2)*X(1) - 2.0*(1.0-X(1))
      D(2)= 200.0*(X(2)-X(1)**2) + 20.2*(X(2)-1.0) + 19.8*(X(4)-1.0)
      D(3)=-360.0*X(3)*(X(4)-X(3)**2) - 2.0*(1.0-X(3))
      D(4)= 180.0*(X(4)-X(3)**2) + 20.2*(X(4)-1.0) + 19.8*(X(2)-1.0)
      RETURN
C   RESIDUAL DERIVS AT OBSN I
 750  GOTO (810,820,830,840,850,860,870), I
 810  D(1)= -20.0*X(1)
      D(2)= 10.0
      D(3)=  0.0
      D(4)=  0.0
      RETURN
 820  D(1)= -1.0
      D(2)=  0.0
      D(3)=  0.0
      D(4)=  0.0
      RETURN
 830  D(1)=  0.0
      D(2)=  0.0
      D(3)= -2.0*SQRT(90.0)*X(3)
      D(4)=  SQRT(90.0)
      RETURN
 840  D(1)= 0.0
      D(2)=  0.0
      D(3)= -1.0
      D(4)=  0.0
      RETURN
 850  D(1)=  0.0
      D(2)= SQRT(0.2)
      D(3)=  0.0
      D(4)=  0.0
      RETURN
 860  D(1)=  0.0
      D(2)=  0.0
      D(3)=  0.0
      D(4)= SQRT(0.2)
      RETURN
 870  D(1)=  0.0
      D(2)= SQRT(9.9)
      D(3)=  0.0
      D(4)= SQRT(9.9)
      RETURN
      END
C&&&   0.1         5    5
C&&&   -3.0      -1.0      -3.0      -1.0
C&&&   0.1      1000  100
C&&&   0.9       0.9       0.9       0.9
C&&&   0.1      1000  100
C&&&  -3.0      -1.0      -3.0      -1.0
C&&&   0.1       100   10
C&&&  -3.0      -1.0      -3.0      -1.0
C&&&   0.0         0    0
