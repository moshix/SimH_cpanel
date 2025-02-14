; NAM PPGTST-1
; test joystick

PARADR EQU $800C

 ORG $0020
 LDX #CLRSCN
 JSR PDATA1
START LDAA #$3D 
 LDX #PARADR 
 LDAB #$00 
 STAB 2,X
 STAA 3,X
LOOP1 LDAA 3,X	read joy 800f	
 ANDA #$80 	wait bit7=1
 BEQ LOOP1
 LDAA 2,X  	read joy 800e
 TAB		mandatory bit7=0
 ANDA #$80 
 BNE LOOP1 
 ANDB #$7F 
 STAB LOPOS	store lopos
LOOP2 LDAA 3,X 	read joy 800f	
 ANDA #$80 	wait bit7=1
 BEQ LOOP2
 LDAA 2,X 	read joy 800e
 TAB		mandatory bit7=1
 ANDA #$80
 BNE SKIP1
 LDX #ERRSTR
 JSR PDATA1
 BRA LOOP1
SKIP1 ANDB #$7F
 STAB HIPOS	store hipos
 LDAA LOPOS 
SKIP2 JSR OUTHL
 LDAA LOPOS 
 JSR OUTHR
SKIP3 JSR OUTS 
 LDAA HIPOS
SKIP4 JSR OUTHL 
 LDAA HIPOS 
 JSR OUTHR
SKIP5 LDX #CRLF 
 JSR PDATA1 
 LDX #PARADR 
 BRA LOOP1
LOPOS FCB $00
HIPOS FCB $00

CLRSCN FCB $0D,$0A,$10,$16,$00,$04

CRLF FCB $0D,$0A,$00,$00,$00,$04
ERRSTR FCC 'SEQUENCE ERROR'

 FCB $04
 ORG $A048
 FDB $20
 ORG $A002
 FDB $801C
PDATA1 EQU $E07E
OUTHL EQU $E067
OUTHR EQU $E06B
OUTS EQU $E0CC 
END

