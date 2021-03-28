		*=$2000
;***************************
; MACROS
;***************************
	.MACRO OPCION
		.IF %1 < 2
			LDA #0
			STA 710
		.ELSE
			LDA #80
			STA 710
		.ENDIF
	.ENDM
;***************************
INICIO
	OPCION 2
LOOP
	JMP LOOP
	*=$2E0
	.WORD INICIO
