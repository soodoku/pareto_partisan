* Encoding: UTF-8.
* Encoding: .
/*Editing the CCES UCM 2018 Data*/

/* Recoding the pid7 variable so that it is centered at zero

COMPUTE pid7zero = $SYSMIS.
IF (pid7 = 1) pid7zero = -3.
IF (pid7 = 2) pid7zero = -2.
IF (pid7 = 3) pid7zero = -1.
IF (pid7 = 4) pid7zero = 0.
IF (pid7 = 5) pid7zero = 1.
IF (pid7 = 6) pid7zero = 2.
IF (pid7 = 7) pid7zero = 3.
EXECUTE.

VALUE LABELS
pid7zero
-3 'Strong Democrat'
-2 'Not So Strong Democrat'
-1 'Lean Democrat'
0 'Independent'
1 'Lean Republican'
2 'Not So Strong Republican'
3 'Strong Republican'.
EXECUTE.



/*Creating a pid3 variable centered on zero and with leaners coded as partisans

COMPUTE pid3lean = $SYSMIS.
IF (pid7 = 1) pid3lean = -1.
IF (pid7 = 2) pid3lean = -1.
IF (pid7 = 3) pid3lean = -1.
IF (pid7 = 4) pid3lean = 0.
IF (pid7 = 5) pid3lean = 1.
IF (pid7 = 6) pid3lean = 1.
IF (pid7 = 7) pid3lean = 1.
EXECUTE.

VALUE LABELS
pid3lean
-1 'Democrat'
0 'Independent'
1 'Republican'.
EXECUTE.


COMPUTE AffectivePolarizationPost=UCMRepThermPost - UCMDemThermPost. 
EXECUTE.

COMPUTE AffectivePolarization=UCMRepTherm - UCMDemTherm. 
EXECUTE.


