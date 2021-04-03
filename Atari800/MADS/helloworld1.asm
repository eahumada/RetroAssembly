; HELLO.ASM
; ---------
;
; THIS ATARI ASSEMBLY PROGRAM
; WILL PRINT THE "HELLO WORLD"
; MESSAGE TO THE SCREEN
;
; Assembled using WUSDN / MADS
;
     ORG $3400

ICHID   		= $0340     ; DEVICE HANDLER
							;   Set by OS. Handler Identifier. If not 
        		            ;   in use, the value is 255 ($FF), which 
        		            ;   is also the initialization value.

ICDNO   		= ICHID+1   ; DEVICE NUMBER Set by OS. Device number (eg: D1: D2:).
ICCOM   		= ICHID+2   ; I/O COMMAND   Set by User. Command
ICSTA   		= ICHID+3   ; I/O STATUS  Set by OS. May or may not be the same 
        		            ;   value as CMD_STATUS returned
ICBAL   		= ICHID+4   ; LSB BUFFER ADDR  Set by User. Buffer address (low byte)
ICBAH   		= ICHID+5   ; MSB BUFFER ADDR Set by User. buffer address (high byte)
ICPTL   		= ICHID+6   ; LSB PUT ROUTINE  Used by BASIC. Address of put byte routine. 
ICPTH   		= ICHID+7   ; MSB PUT ROUTINE  Used by BASIC. Address of put byte routine. 
ICBLL   		= ICHID+8   ; LSB BUFFER LEN  buffer length (low byte) in put/get operations
ICBLH   		= ICHID+9   ; MSB BUFFER LEN  buffer length (high byte)
ICAX1   		= ICHID+10  ;   auxiliary information.  Used by Open cmd 
        		            ;   for READ/WRITE/UPDATE
        		            ;   Bit  7   6   5   4   3   2   1   0
        		            ;   Use  ....unused....  W   R   D   A
        		            ;   W equals write, R equals read, 
        		            ;   D equals directory, A equals append.
ICAX2   		= ICHID+11  ;   Auxiliary byte two
;
GETREC = 5      ;GET TEXT RECORD
PUTREC = 9      ;PUT TEXT RECORD
;
CIOV =  $E456   ;CIO ENTRY VECTOR
RUNAD = $02E0   ;RUN ADDRESS
EOL   = $9B     ;END OF LINE
;
; SETUP FOR CIO
; -------------

START
	LDX #0    ;IOCB 0
	LDA #PUTREC ;WANT OUTPUT
	STA ICCOM,X ;ISSUE CMD

	LDA #<MSG ;LOW BYTE OF MSG (& FF)
	STA ICBAL,X ; INTO ICBAL

	LDA #>MSG ; HIGH BYTE (/256)
	STA ICBAH,X ; INTO ICBAH

	LDA #0      ;LENGTH OF MSG
	STA ICBLH,X ; HIGH BYTE

	LDA #$FF    ;255 CHAR LENGTH
	STA ICBLL,X ; LOW BYTE
;
; CALL CIO TO PRINT
; -----------------
     JSR CIOV    ;CALL CIO
;0530     RTS         ;EXIT TO DOS
LOOP	JMP LOOP
;
; OUR MESSAGE
; -----------
MSG .BYTE 'HELLO WORLD!',EOL
;
; INIT RUN ADDRESS
; ----------------
     ORG RUNAD
     .WORD START
 
 END