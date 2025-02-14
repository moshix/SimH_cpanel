;*	NAM FLITA
	ORG $6000
;*THE FOLLOWING PROGRAM WAS WRITTEN BY WAYNE PARSOSN IN
;*CONJUNCTION WITH THE INDISTRIAL ENGENEERING DEPARTMENT
;*AND DR. DAUER AS A PARTIAL REQUIREMENT FOR COMPLETITION
;*OF A MS DEGREE AT THE UNIVERSITY OF CENTRAL FLORIDA IN THE
;*FALL SEMESTER OF 1981.
;*
;**********************************************************
;*
;*THE FOLLOWING SECTION OF THE PROGRAM IS THE SYSTEM MACRO
;*OT OS DESIGNED TO SEQUENTIALLY CALL THE PROPER ROUTINES IN
;*ORDER TO EFFICIENTLY EXECUTE THE PROBLEM ALGORITH
MACRO   STS STKSAV
	CLRA
	CLRB
	JSR CLRMEM	;CLEAR MEMORY LOCATIONS
	JSR PIAINT	;INITIALIZE PIA AND CLEAR SCREEN
	JSR PROMPT	;PRINT USER PROMPT MESSAGES
	JSR INITLOD	;LOAD INITIAL AIRCRAFT POSITIONAL PARAMETERS
TMPLOD	DEC ZV		;USE THIS STATEMENT FOR DEBUG PURPOSES ONLY!!
	BRA TIMONE	;GO TRANSFORM INITIAL VIEW 1ST TIME THRU
GOAGN	JSR UPDATE	;GET UPDATED A/D VOLTS
	BRA GONORM
ADSIM	JSR STAPAR 	;LOAD STATIONARY PARAMETERS TO SIMULATE A/D
GONORM	JSR RELPOS	;DETERMINE IF RELATIVE POSITION HAS CHANGED
	JSR CNVRT	;A/D VOLTS => PARAMETERS
TIMONE	JSR GO3D2D	;GO TRANSFORM 3D TO 2D COORDINATES 
	JSR CLSCRN	;CLEAR SCREEN FOR NEW DRAW
	JSR DBDRAW	;DRAW TRANSFORMED DATA BASE
;	BRA TMPLOD	;USE IN DEBUG MODE ONLY
;	BRA ADSIM	;USE IN DEBUG MODE ONLY
	BRA GOAGN	;NORMAL RETURN, SYSTEM OPERATION
;*SUBROUTINE "CLRMEM" ATTEMPTS TO CLEAR MEMORY STORAGE LOCATIONS
;*AND DATA ARRAYS RESERVED BUT NOT YET CONTAINING ANY MEANINGFUL
;*DATA
CLRMEM	CLRB
	STAB CNT
	STAB COUNT
GETNXT	LDAB CNT	
	BNE MOREOB
	LDAB CNT
	INCB
	STAB COUNT
	CMPB #1
	BEQ CLRRML
	CMPB #2
	BEQ CLROB
	CMPB #3
	BEQ SUBDUN
CLEAR1	LDAB #$FF	;TOTAL NUMBER OF LOCATIONS TO CLEAR
CLEAR2	CLRA
CLRMOR	STAA $00,X
	DECB
	BEQ GETNXT	
	INX
	BRA CLRMOR
CLRRML	LDX #$7000	;CLEAR RESERVE MEMORY LOCATIONS
	LDAB #$FF	
	BRA CLEAR2
CLROB	LDAB #1		;CLEAR OUTPUT BUFFER
	STA CNT
	LDX #$1800	;OUTPUT BUFFER STARTING ADDRESS = 1800
	BRA CLEAR1
MOREOB	DECB
	STAB CNT
	LDX #$1900
	BRA CLEAR1	
SUBDUN	RTS		;ALL DONE ; GO BACK TO MACRO	
;*SUBROUTINE "PIAINT" AND "CLSRCN" USE THE MEMORY LOCATION
;* "GDOPT" TO CHOOSE THE GRAPHICS DISPLAY OPTION DESIRED BY
;*THE ROUTINE "SCREEN" AND THEN CALLS IT
PIAINT	LDAA #1
	STAA GDOPT	;GRAPHICS DISPLAY OPTION = PIA INITIALIZATION
	JSR SCREEN
CLSCRN	LDAA #3
	JSR SCREEN
	RTS
;*SUBROUTINE "PROMPT" WILL LOAD THE INDEX REGISTER WITH THE		
;*ADDRESS OF THE NEXT USER PROMPT TO BE DISPLAYED AND THEN 
;*WILL PRINT THE MESSAGE ON THE USER'S TERMINAL. IT WILL
;*THEN WAIT UNTIL THE USER HAS READ AND UNDERSTOOD THE
;*PROMPT BEFORE PRINTING THE NEXT MESSAGE.
PROMPT	LDX #WELCOM
	JSR DSPCHR
	LDX #MSGA
	JSR DSPCHR
	LDX #MSGB
	JSR DSPCHR
	LDX #MSGC
	JSR DSPCHR
	RTS		;RETURN TO MACRO
DSPCHR	LDAA $0,X
	CMPA #04	
	BNE PRTCHR
NOTGOT	CLRA		;PREPARE ACCM FOR RESPONSE
	JSR $E1AC	;ANY RESPONSE ?
	CMPA #$31
	BEQ LOADIR
	CMPA #$32
	BEQ LOADIR
	CMPA #$A0	;ASCII SPACEBAR = A0
	BEQ NOTGOT
	RTS		;RETURN FROM JSR DSPCHR CALL
PRTCHR	JSR $E1D1	;PUT CHARACTER OUT TO TERMINAL
	INX
	BRA DSPCHR	
LOADIR	CMPA #$31
	BEQ LOAD1
	LDX #$1100	;RESPONSE TO MSGB PROMPT = 2
	STX IBP
	RTS		;RETURN FROM JSR DSPCHR CALL
LOAD1	LDX #$1300	;RESPONSE TO MSGB PROMPT = 1
	STX IBP
	RTS		;RETURN FROM JSR DSPCHR CALL
;*SUBROUTINE "INITLOD" LOADS THE SIX POSITIONAL PARAMETERS
;*OF THE SIMULATOR'S INITIAL POSITION WHICH WAS PREVIOUSLY
;*PROMPTED TO THE USER.
INITLOD	LDX #$D500	;-11,190 FEET FROM DISPLAY ORIGIN
	STX XV		;POS = WEST (0000-7FFF) NEG = EAST (FFFF-8000)
	LDX #$FC18	;ALT = 1000 FT => 3D VALUE FOR VIEWRT
	STX YV		;      SO REQUIRE NEGATIVE 3D VALUE (FFFF-8000)
	LDX #$F000	;-4096 FEET FROM DISPLAY ORIGIN
	STX ZV		;POS=SOUTH (0000-7FFF) NEG=NORTH (FFFF-8000)
	LDX #$0000	;PITCH = BANK = HEADING = 0.0 DEGREES
	STX PV
	STX BV
	STX HV
	LDX #$1800
	STX OBP
	LDAA #$40
	STAA SCRN
	RTS
;*SUBROUTINE "GO3D2D" CALLS THE PROGRAM WRITTEN BY SUBLOGIC'S
;*BRUCE ARTWICK WHICH WILL PERFORM THE NECESSARYMATHEMATICAL
;*ALGORITHMS TO SUCCESSFULLY TRANSFORM THE DATA BASE GIVE
;*THE POSITIONAL PARAMETERS STORED IN XV,YU,ZV,PV,BV AND HV,
;*UPON COMPLETITION THE OUTPUT ARRAY IS STORES IN MEMORY IN
;*THE OUTPUT BUFFER.
GO3D2D	JSR $0900	;3D TO 2D CONVERTER ROUTINE
	RTS
;*SUBROUTINE "DBDRAW" WILL LOAD THE NEXT (X1,Y1) AND (X2,Y2)
;*FROM THE OUTPUT BUFFER IF THE CONTROL BYTE IS HEX 55,
;*OTHERWISE IT WILL RETURN TO THE MACRO
DBDRAW	LDX OBP
FEED	LDAA 0,X
	CMPA #$55
	BEQ NXTLIN
	RTS
NXTLIN	INX
	LDAA 0,X
	STAA X1
	INX	
	LDAA 0,X
	STAA Y1
	INX	
	LDAA 0,X
	STAA X2
	INX	
	LDAA 0,X
	STAA X2
	INX	
	STX IDXREG
	LDAA #5
	STA GDOPT	;GRAPHIC'S DISPLAY OPTION = DRAW (SHOW2)
	JSR SCREEN
	LDX IDXREG
	BRA FEED
;*SUBROUTINE "UPDATE" ENABLES THE M6800/ATC-610J INTERFACE
;*AD-68A CARD THEREBY RETRIEVING THE SELECTED UPDATED
;*PARAMETER AND PLACES IT IN MEMORY AT LOCATION "NEWDAT"
UPDATE	CLRA
	STAA NEWDAT
	LDAA #16	;BIT 4 = 1, X3 ENABLED (+X WEST/-X EAST)
	STA ENABLE
	JSR GETNEW
	LDAA NEWDAT
	STAA X3		;X3 = A/D VOLTS
	CLRA
	STAA NEWDAT
	LDAA #32	;BIT 5 = 1, Z3 ENABLED (+Z SOUTH/-Z NORTH)
	STA ENABLE
	JSR GETNEW
	LDAA NEWDAT
	STAA Z3		;Z3 = A/D VOLTS
	CLRA
	STAA NEWDAT
	LDAA #2		;BIT 1 = 1, Y3 ENABLED (ALTITUDE)
	STA ENABLE
	JSR GETNEW
	LDAA NEWDAT
	STAA Y3		;Z3 = A/D VOLTS
	CLRA
	STAA NEWDAT
	LDAA #1		;BIT 0 = 1, P ENABLED 
	STA ENABLE
	JSR GETNEW
	LDAA NEWDAT
	STAA PITCH	;PITCH = A/D VOLTS
	CLRA
	STAA NEWDAT
	LDAA #8		;BIT 3 = 1, B ENABLED 
	STA ENABLE
	JSR GETNEW
	LDAA NEWDAT
	STAA BANK	;BANK = A/D VOLTS
	CLRA
	STAA NEWDAT
	LDAA #4		;BIT 2 = 1, H ENABLED 
	STA ENABLE
	JSR GETNEW
	LDAA NEWDAT
	STAA HEAD	;HEAD = A/D VOLTS
	RTS
;*SUBROUTINE "GETNEW" IS CALLED FROM AND RETURNS TO "UPDATE".
;*IT GETS INSTRUCTIONS ON WHICH AD-68A CHANNEL TO ENABLE FROM
;*MEMORY LOCATION "ENABLE" AND THEN RETRIEVES THE INPUT AND
;*LEAVES IT IN MEMORY LOCATION "NEWDAT".
GETNEW	CLRB
	LDAA #$80
	STAA $800C
ENTER 	LDAA $800C
	CMPB #$FA
	BHI EXIT
	BITA ENABLE
	BNE EXIT
	INCB
	BRA ENTER
EXIT	STAB NEWDAT
	LDAA #$40
	STAA $800C
	RTS	
STKSAV	EQU $78F1
CNVRT	EQU $626B
RELPOS	EQU $6200
CNT	EQU $78F3		
COUNT	EQU $78F0
GDOPT	EQU $7817
SCREEN	EQU $7000
WELCOM	EQU $7200
MSGA	EQU $7900
MSGB	EQU $7A00
MSGC	EQU $7400
XV	EQU $0100
YV	EQU $0102
ZV	EQU $0104
PV 	EQU $0106
BV 	EQU $0108
HV 	EQU $010A
IBP 	EQU $010F
OBP 	EQU $0111
SCRN	EQU $010E
X1	EQU $0050
Y1	EQU $0051
X2	EQU $0052
Y2	EQU $0053
IDXREG 	EQU $781A
NEWDAT 	EQU $7818
ENABLE 	EQU $7819
X3	EQU $7800
Y3	EQU $7802
Z3	EQU $7804
PITCH	EQU $7806
BANK	EQU $7808
HEAD	EQU $780A
STAPAR	EQU $6312
	END

