	*=$2000
;***************************************
; INICIO MACROS
;***************************************

.MACRO NEGRO
	LDA #0
	STA 710
.ENDM
	

.MACRO MORADO
	LDA #80
	STA 710
.ENDM

.MACRO AZUL
	LDA #96
	STA 710
.ENDM
	
INICIO
	AZUL
	
LOOP
	JMP LOOP
	*=$2E0
	.WORD INICIO