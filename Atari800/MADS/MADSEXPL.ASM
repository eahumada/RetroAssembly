; WUDSN IDE Atari Rainbow Example - MADS syntax

;	
;		processor	6502

		ORG $4000 ;Start of code

;*		= $4000 ;Start of code

start	LDA #0 ;Disable screen DMA
		STA 559
loop	LDA $d40b ;Load VCOUNT
		CLC
		ADC 20 ;Add counter
		STA $d40a
		STA $d01a ;Change background color
		JMP loop
;.END
