	*=$3000
;*****************************
; MACROS
;*****************************
;
	.MACRO POKE
		LDA #%2
		STA %1
	.ENDM
	
	.MACRO POSITION
		LDA #%2
		STA 84
		LDA #%1
		STA	85
	.ENDM
;*****************************
PANTALLA
	.BYTE "HOLA MUNDO",$9B

START
	POKE 710,80
	POSITION 10,6
	LDX #<PANTALLA
	LDY #>PANTALLA
	JSR $C642

LOOP
	JMP LOOP

	*=$2E0
	.WORD START