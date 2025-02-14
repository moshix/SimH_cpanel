// JOB DEMOCOBD SAMPLE COBOL PROGRAM
// OPTION LINK,SYM,LISTX
// EXEC COBOL
 CBL DMAP=21A0,PMAP=21A0
       IDENTIFICATION DIVISION.
       PROGRAM-ID. 'SAMPLE'.
       AUTHOR. A PROGRAMMER.
       REMARKS. THIS IS A SAMPLE COBOL (D LEVEL) PROGRAM FOR A TYPICAL
           BUSINESS REPORT.  IT ALSO DEMONSTRATES A CONTROL BREAK,
           A BINARY SEARCH FOR A TABLE, CALLING A SUBROUTINE,
           AND USES BOTH A LINE COUNTER AND THE COBOL USE OF CH.12
           ON THE PRINTER CARRIAGE TAPE.

           THIS PROGRAM IS INTENDED TO SHOW AN EARLY 1968 PROGRAM
           AND THEREFORE BEFORE PROFESSOR DIJKSTRA'S LETTER ON 'GOTO'
           STATEMENTS WAS PUBLISHED BY THE ACM, I.E. BEFORE THE DAYS
           OF STRUCTURED PROGRAMMING.  'GO TO' VERBS ARE USED
           IN THE PROGRAM AS NECESSARY AND CORRECTLY AS IN
           THE METHODS OF 'MODULAR PROGRAMMING'.

           THE ONLY WAY OF INCLUDING COMMENTS IN THIS VERSION OF COBOL
           IS THIS 'REMARKS' PARAGRAPH AND A 'NOTE' VERB AS USED IN THE
           PROCEDURE DIVISION.   EVERYTHING FROM 'NOTE' TO THE END OF
           THE SENTENCE (PERIOD) IS A COMMENT.  IF THE 'NOTE' IS THE 
           FIRST VERB IN A PARAGRAPH THE WHOLE PARAGRAPH IS A COMMENT.
           AN ASTERISK IN COL. 7 IS IGNORED AND DOES NOT MEAN A COMMENT.

           THE 'DMAP' AND 'PMAP' OPTIONS ON THE 'CBL' OPTION CARD ONLY
           AFFECT THE SOURCE CODE LISTING.  IF YOU KNOW THE ACTUAL
           LINKEDIT ADDRESS THEY CAN BE USED AS AN OFFSET TO SHOW
           ACTUAL CORE LOCATIONS ON THE SOURCE CODE LISTING FOR
           THE DATA MAP (SYM) AND PROCEDURE MAP (LISTX) TO AID
           IN DEBUGGING.

           THIS PROGRAM SHOWS THE PRINTING METHOD OF SETTING UP
           ALL LINES IN WORKING STORAGE AND THEN USING THE 'FROM'
           OPTION ON THE 'WRITE' TO SEND EACH ONE TO THE PRINTER.

       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. IBM-360.
       OBJECT-COMPUTER. IBM-360.
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
           SELECT PAY-FILE   ASSIGN TO 'SYS007' UNIT-RECORD 2501.
           SELECT PRINT-FILE ASSIGN TO 'SYS009' UNIT-RECORD 1403.
       I-O-CONTROL.
           APPLY EOP TO FORM-OVERFLOW ON PRINT-FILE.
      
       DATA DIVISION.
       FILE SECTION.
       FD  PAY-FILE
           LABEL RECORDS ARE OMITTED
           RECORDING MODE IS F
           RECORD CONTAINS 75 CHARACTERS
           DATA RECORD IS EMPLOYEE-RECORD.
       01  EMPLOYEE-RECORD.
           05  EM-DEPARTMENT       PICTURE XX.
           05  FILLER              PICTURE XXX.
           05  EM-NAME             PICTURE X(20).
           05  FILLER              PICTURE X(8).
           05  EM-OTH-DED-X.
               10  EM-OTH-DED      PICTURE S9(5)V99.
           05  FILLER              PICTURE X(16).
           05  EM-SSN13            PICTURE XXX.
           05  EM-SSN45            PICTURE XX.
           05  EM-SSN69            PICTURE XXXX.
           05  EM-SALARY-X.
               10  EM-SALARY       PICTURE S9(5)V99.
           05  FILLER              PICTURE X(3).
       FD  PRINT-FILE
           LABEL RECORDS ARE OMITTED
           RECORDING MODE IS F
           DATA RECORD IS PRINT-LINE.
       01  PRINT-LINE              PICTURE X(133).
       WORKING-STORAGE SECTION.
       01  FILLER.
           02  FILLER   COMPUTATIONAL.
               05  IDX             PICTURE S9(4).
               05  UPPER-LIMIT     PICTURE S9(4).
               05  LOWER-LIMIT     PICTURE S9(4).
           02  FILLER   COMPUTATIONAL-3.
               05  WS-PAGE         PICTURE S999        VALUE ZERO.
               05  LINE-CNTR       PICTURE S999.
               05  WS-FIT-WITH     PICTURE S9(5)V99.
               05  WS-SIT-WITH     PICTURE S9(5)V99.
               05  WS-NET-PAY      PICTURE S9(5)V99.
               05  WS-DT-SALARY    PICTURE S9(5)V99    VALUE ZERO.
               05  WS-DT-FIT-WITH  PICTURE S9(5)V99    VALUE ZERO.
               05  WS-DT-SIT-WITH  PICTURE S9(5)V99    VALUE ZERO.
               05  WS-DT-OTH-DED   PICTURE S9(5)V99    VALUE ZERO.
               05  WS-DT-NET-PAY   PICTURE S9(5)V99    VALUE ZERO.
               05  WS-FT-SALARY    PICTURE S9(7)V99    VALUE ZERO.
               05  WS-FT-FIT-WITH  PICTURE S9(7)V99    VALUE ZERO.
               05  WS-FT-SIT-WITH  PICTURE S9(7)V99    VALUE ZERO.
               05  WS-FT-OTH-DED   PICTURE S9(7)V99    VALUE ZERO.
               05  WS-FT-NET-PAY   PICTURE S9(7)V99    VALUE ZERO.
           02  FILLER.
               05  ASA             PICTURE X           VALUE SPACE.
               05  WS-DEPARTMENT   PICTURE XX.
               05  DEPTS-TABLE.
                   10  FILLER      PICTURE X(12) VALUE '10     SALES'.
                   10  FILLER      PICTURE X(12) VALUE '20      MFG.'.
                   10  FILLER      PICTURE X(12) VALUE '30  BUSINESS'.
                   10  FILLER      PICTURE X(12) VALUE '40    TRANS.'.
                   10  FILLER      PICTURE X(12) VALUE '50 ENGINEER.'.
               05  DEPT-TABLE REDEFINES DEPTS-TABLE OCCURS 5 TIMES.
                   10  DEPT-CODE   PICTURE XX.
                   10  DEPT-DESC   PICTURE X(10).
           02  BLANK-LINE          PICTURE X           VALUE SPACE.
           02  HEADING1.
               05  FILLER          PICTURE X.
               05  H1-TODAY        PICTURE X(8).
               05  FILLER          PICTURE X(40)       VALUE SPACES.
               05  FILLER PICTURE X(70) VALUE 'COBOL-D SAMPLE PROGRAM'.
               05  FILLER          PICTURE X(5)        VALUE 'PAGE '.
               05  H1-PAGE         PICTURE ZZ9.
           02  HEADING2.
               05  FILLER          PICTURE X(14) VALUE ' DEPT.    NAME'.
               05  FILLER          PICTURE X(15)       VALUE SPACES.
               05  FILLER          PICTURE X(100)      VALUE
                      'SOC.SEC.NO.        SALARY         F.I.T.
      -               'S.I.T.          OTHER           NET'.
           02  UNDER-LINE.
               05  FILLER          PICTURE X(14) VALUE ' _____    ____'.
               05  FILLER          PICTURE X(15)       VALUE SPACES.
               05  FILLER          PICTURE X(100)      VALUE
                      '___________        ______         ______
      -               '______          _____           ___'.
           02  DETAIL-LINE.
               05  FILLER          PICTURE X           VALUE SPACE.
               05  DL-DEPARTMENT   PICTURE XX.
               05  FILLER          PICTURE X(4)        VALUE SPACES.
               05  DL-NAME         PICTURE X(20).
               05  FILLER          PICTURE XX          VALUE SPACES.
               05  DL-SSN13        PICTURE XXX.
               05  DL-SSN-HYP1     PICTURE X.
               05  DL-SSN45        PICTURE XX.
               05  DL-SSN-HYP2     PICTURE X.
               05  DL-SSN69        PICTURE XXXX.
               05  FILLER          PICTURE X(5)        VALUE SPACES.
               05  DL-SALARY       PICTURE ZZ,ZZZ.99-.
               05  FILLER          PICTURE X(5)        VALUE SPACES.
               05  DL-FIT-WITH     PICTURE ZZ,ZZZ.99-.
               05  FILLER          PICTURE X(5)        VALUE SPACES.
               05  DL-SIT-WITH     PICTURE ZZ,ZZZ.99-.
               05  FILLER          PICTURE X(5)        VALUE SPACES.
               05  DL-OTH-DED      PICTURE ZZ,ZZZ.99-.
               05  FILLER          PICTURE X(5)        VALUE SPACES.
               05  DL-NET-PAY      PICTURE ZZ,ZZZ.99-.
           02  ERROR-LINE.
               05  FILLER          PICTURE X           VALUE SPACE.
               05  EL-DEPARTMENT   PICTURE XX.
               05  FILLER          PICTURE X(4)        VALUE SPACES.
               05  EL-NAME         PICTURE X(20).
               05  FILLER          PICTURE XX          VALUE SPACES.
               05  EL-SSN13        PICTURE XXX.
               05  EL-SSN-HYP1     PICTURE X.
               05  EL-SSN45        PICTURE XX.
               05  EL-SSN-HYP2     PICTURE X.
               05  EL-SSN69        PICTURE XXXX.
               05  FILLER          PICTURE X(5)        VALUE SPACES.
               05  FILLER          PICTURE X(13) VALUE 'ERROR IN DATA'.
           02  DEPARTMENT-LINE.
               05  FILLER          PICTURE X(12)       VALUE SPACES.
               05  DT-DEPT-DESC    PICTURE X(10)       VALUE SPACES.
               05  FILLER          PICTURE X(12) VALUE ' DEPARTMENT'.
               05  DT-DEPARTMENT   PICTURE X(2).
               05  FILLER          PICTURE X(9)     VALUE ' TOTALS'.
               05  DT-SALARY       PICTURE ZZ,ZZZ.99-.
               05  FILLER          PICTURE X(5)        VALUE SPACES.
               05  DT-FIT-WITH     PICTURE ZZ,ZZZ.99-.
               05  FILLER          PICTURE X(5)        VALUE SPACES.
               05  DT-SIT-WITH     PICTURE ZZ,ZZZ.99-.
               05  FILLER          PICTURE X(5)        VALUE SPACES.
               05  DT-OTH-DED      PICTURE ZZ,ZZZ.99-.
               05  FILLER          PICTURE X(5)        VALUE SPACES.
               05  DT-NET-PAY      PICTURE ZZ,ZZZ.99-.
               05  FILLER          PICTURE X           VALUE '*'.
           02  FINAL-TOTAL-LINE.
               05  FILLER          PICTURE X(28)       VALUE SPACES.
               05  FILLER          PICTURE X(15)  VALUE 'FINAL TOTALS'.
               05  FT-SALARY       PICTURE ZZZZ,ZZZ.99-.
               05  FILLER          PICTURE X(3)        VALUE SPACES.
               05  FT-FIT-WITH     PICTURE ZZZZ,ZZZ.99-.
               05  FILLER          PICTURE X(3)        VALUE SPACES.
               05  FT-SIT-WITH     PICTURE ZZZZ,ZZZ.99-.
               05  FILLER          PICTURE X(3)        VALUE SPACES.
               05  FT-OTH-DED      PICTURE ZZZZ,ZZZ.99-.
               05  FILLER          PICTURE X(3)        VALUE SPACES.
               05  FT-NET-PAY      PICTURE ZZZZ,ZZZ.99-.
               05  FILLER          PICTURE XX          VALUE '**'.

       PROCEDURE DIVISION.
           NOTE THE REQUIREMENT OF THE 'ENTER' VERBS WHEN CALLING
               A SUBROUTINE.  NOTE WE ARE USING A CONTROL BREAK
               SO WE READ THE FIRST RECORD IN HOUSEKEEPING.
           OPEN INPUT PAY-FILE, OUTPUT PRINT-FILE.
           ENTER LINKAGE.
           CALL 'GETDATE' USING H1-TODAY.
           ENTER COBOL.
           PERFORM HEADING-ROUTINE THRU HEADING-ROUTINE-EXIT.
           READ PAY-FILE AT END GO TO END-OF-JOB.
           MOVE EM-DEPARTMENT TO WS-DEPARTMENT.
       MAIN-LOOP.
           IF EOP OR LINE-CNTR > 56
               PERFORM HEADING-ROUTINE THRU HEADING-ROUTINE-EXIT.
           EXAMINE EM-SALARY-X  REPLACING LEADING SPACES BY ZEROS.
           EXAMINE EM-OTH-DED-X REPLACING LEADING SPACES BY ZEROS.
           IF EM-SALARY IS NUMERIC AND EM-OTH-DED IS NUMERIC
                    PERFORM DATA-IS-GOOD THRU DATA-IS-GOOD-EXIT
               ELSE PERFORM DATA-IS-BAD  THRU DATA-IS-BAD-EXIT.
           READ PAY-FILE AT END GO TO END-OF-JOB.
           IF EM-DEPARTMENT NOT = WS-DEPARTMENT
               PERFORM DEPARTMENT-TOTAL THRU DEPARTMENT-TOTAL-EXIT.
           GO TO MAIN-LOOP.
       END-OF-JOB.
           PERFORM FINAL-TOTALS THRU FINAL-TOTALS-EXIT.
           CLOSE PAY-FILE, PRINT-FILE.
           STOP RUN.

       HEADING-ROUTINE.
           ADD 1 TO WS-PAGE
           MOVE WS-PAGE TO H1-PAGE
           NOTE THAT 'AFTER ADVANCING 0' MEANS SKIP TO A NEW PAGE,
               AND 'AFTER ADVANCING name' WOULD NEED TO BE A VALID
               ASA CHARACTER.
           WRITE PRINT-LINE FROM HEADING1 AFTER ADVANCING 0
           WRITE PRINT-LINE FROM HEADING2 AFTER ADVANCING 2
           MOVE '+' TO ASA
           WRITE PRINT-LINE FROM UNDER-LINE AFTER ADVANCING ASA
           WRITE PRINT-LINE FROM BLANK-LINE AFTER ADVANCING 1
           MOVE 4 TO LINE-CNTR.
       HEADING-ROUTINE-EXIT.
           EXIT.

       DATA-IS-GOOD.
           MULTIPLY EM-SALARY BY .14  GIVING WS-FIT-WITH ROUNDED
           MULTIPLY EM-SALARY BY .025 GIVING WS-SIT-WITH ROUNDED
           COMPUTE WS-NET-PAY = EM-SALARY - WS-FIT-WITH - WS-SIT-WITH -
               EM-OTH-DED
           ADD EM-SALARY      TO WS-DT-SALARY
           ADD WS-FIT-WITH    TO WS-DT-FIT-WITH
           ADD WS-SIT-WITH    TO WS-DT-SIT-WITH
           ADD EM-OTH-DED     TO WS-DT-OTH-DED
           ADD WS-NET-PAY     TO WS-DT-NET-PAY
           MOVE EM-DEPARTMENT TO DL-DEPARTMENT
           MOVE EM-NAME       TO DL-NAME
           MOVE EM-SSN13      TO DL-SSN13
           MOVE EM-SSN45      TO DL-SSN45
           MOVE EM-SSN69      TO DL-SSN69
           MOVE '-'           TO DL-SSN-HYP1, DL-SSN-HYP2
           MOVE EM-SALARY     TO DL-SALARY
           MOVE WS-FIT-WITH   TO DL-FIT-WITH
           MOVE WS-SIT-WITH   TO DL-SIT-WITH
           MOVE EM-OTH-DED    TO DL-OTH-DED
           MOVE WS-NET-PAY    TO DL-NET-PAY
           WRITE PRINT-LINE FROM DETAIL-LINE AFTER ADVANCING 1
           ADD 1 TO LINE-CNTR.
       DATA-IS-GOOD-EXIT.
           EXIT.
       DATA-IS-BAD.
           MOVE EM-DEPARTMENT TO EL-DEPARTMENT
           MOVE EM-NAME       TO EL-NAME
           MOVE EM-SSN13      TO EL-SSN13
           MOVE EM-SSN45      TO EL-SSN45
           MOVE EM-SSN69      TO EL-SSN69
           MOVE '-'           TO EL-SSN-HYP1, EL-SSN-HYP2
           WRITE PRINT-LINE FROM ERROR-LINE AFTER ADVANCING 1
           ADD 1 TO LINE-CNTR.
       DATA-IS-BAD-EXIT.
           EXIT.

           NOTE THE CONTROL BREAK ROUTINE WILL CREATE AND PRINT
               THE DEPARTMENT TOTAL LINE, ROLL THE DEPARTMENT TOTALS
               TO FINAL TOTALS AND THEN CLEAR DEPARTMENT TOTALS.
       DEPARTMENT-TOTAL.
           MOVE WS-DEPARTMENT TO DT-DEPARTMENT
           NOTE WE USE A BINARY SEARCH TO GET A DEPARTMENT NAME.
           MOVE 6 TO UPPER-LIMIT.
           MOVE ZERO TO LOWER-LIMIT.
       DEPT-SEARCH.
           COMPUTE IDX = (UPPER-LIMIT + LOWER-LIMIT) / 2
           IF IDX = LOWER-LIMIT
              GO TO DEPT-BAD.
           IF DEPT-CODE (IDX) LESS THAN WS-DEPARTMENT
              MOVE IDX TO LOWER-LIMIT
              GO TO DEPT-SEARCH.
           IF DEPT-CODE (IDX) GREATER THAN WS-DEPARTMENT
              MOVE IDX TO UPPER-LIMIT
              GO TO DEPT-SEARCH.
           MOVE DEPT-DESC (IDX) TO DT-DEPT-DESC
           GO TO DEPT-END-SEARCH.
       DEPT-BAD.
           MOVE 'UNKNOWN' TO DT-DEPT-DESC.
       DEPT-END-SEARCH.
           MOVE WS-DT-SALARY   TO DT-SALARY
           MOVE WS-DT-FIT-WITH TO DT-FIT-WITH
           MOVE WS-DT-SIT-WITH TO DT-SIT-WITH
           MOVE WS-DT-OTH-DED  TO DT-OTH-DED
           MOVE WS-DT-NET-PAY  TO DT-NET-PAY
           WRITE PRINT-LINE FROM DEPARTMENT-LINE AFTER ADVANCING 1
           WRITE PRINT-LINE FROM BLANK-LINE AFTER ADVANCING 1
           ADD 2 TO LINE-CNTR
           ADD WS-DT-SALARY   TO WS-FT-SALARY
           ADD WS-DT-FIT-WITH TO WS-FT-FIT-WITH
           ADD WS-DT-SIT-WITH TO WS-FT-SIT-WITH
           ADD WS-DT-OTH-DED  TO WS-FT-OTH-DED
           ADD WS-DT-NET-PAY  TO WS-FT-NET-PAY
           MOVE ZEROS TO WS-DT-SALARY, WS-DT-FIT-WITH, WS-DT-SIT-WITH,
               WS-DT-OTH-DED, WS-DT-NET-PAY
           MOVE EM-DEPARTMENT TO WS-DEPARTMENT.
       DEPARTMENT-TOTAL-EXIT.
           EXIT.

       FINAL-TOTALS.
           PERFORM DEPARTMENT-TOTAL THRU DEPARTMENT-TOTAL-EXIT
           MOVE WS-FT-SALARY   TO FT-SALARY
           MOVE WS-FT-FIT-WITH TO FT-FIT-WITH
           MOVE WS-FT-SIT-WITH TO FT-SIT-WITH
           MOVE WS-FT-OTH-DED  TO FT-OTH-DED
           MOVE WS-FT-NET-PAY  TO FT-NET-PAY
           WRITE PRINT-LINE FROM FINAL-TOTAL-LINE AFTER ADVANCING 1.
       FINAL-TOTALS-EXIT.
           EXIT.
/*
// EXEC ASSEMBLY
         TITLE 'GET CURRENT-DATE FOR COBOL'
* SINCE THIS COBOL DOES NOT HAVE 'CURRENT-DATE' USE THIS ROUTINE
* TO PASS BACK THE COMRG DATE.  USES STANDARD LINKAGE CONVENTIONS.
GETDATE  CSECT
R1       EQU   1
R2       EQU   2
R15      EQU   15
         USING *,R15
         SAVE  (14,12)          SAVE COBOL'S REGISTERS
         L     R2,0(R1)         GET ADDRESS OF COBOL'S PASSED FIELD
         COMRG
         MVC   0(8,R2),0(R1)    MOVE THE COMRG DATE TO COBOL
         RETURN (14,12)         RESTORE COBOL'S REGISTERS AND RETURN
         END
/*
// EXEC LNKEDT
// ASSGN SYS007,X'00C'
// ASSGN SYS009,X'00E'
// EXEC
10004ACHER, WILLIAM C.          00675241004            3679874321120000034
10185DONNEMAN, THOMAS M.        00900191003            1043781234130000040
10300FELDMAN, MIKE R.           00300000004            2156278643115000026
10325HATFIELD, MARK I.          00205390002            2225723628090000030
10730REEDE, OWEN W.             01051440001            2115897234105000021
10960WINGLAND, KEITH E.         00350000003            4215679672085000026
20111CARTOLER, VIOLET B.        00750060004            3455667381140000032
20304FROMM, STEVE V.            01200005002            2300267832122500037
20590NEIL, CLARENCE N.          00950230001            4016787112135000040
20801SCHEIBER, HARRY T.         00325080002            6198842236112500046
20956WANGLEY, THEO. A.          00150000003            1723456124120000050
30030ALLOREN, RUTH W.           00000000002            7647982367130000055
30181DELBERT, EDWARD D.         01305541015            6419182773110000051
30318HANEY, CAROL S.            01450005008            5533266791100000058
30487KING, MILDRED J.           01804290010            8711322487090500033
30834TRAWLEY, HARRIS T.         00550000009            7623561471100250032
40171COSTA, NAN S.              00560000005            1241963182122000046
40027ALHOUER, ELAINE E.         00220660006            6381469783079500022
40317HANBEE, ALETTA O.          00395000008            1136719674139000050
40721RASSMUSEN, JOHN J.         01000000004            2064397865129600040
50040ATKINSON, CHARLES          00675241004            3679874321120000034
50060BASEL, DEBORAH L           00900191003            1043781234130000040
50105BETTINARDI, RONALD J       01500500003            1125666601110000022
/*
/&
