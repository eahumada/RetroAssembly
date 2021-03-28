; "Hello world" in 6502 assembly language for 8-bit Atari.

; Assembler: http://xasm.atari.org/ or http://mads.atari8.info/


	org $3000                                                  ; Start address of your code, should be between $2000 and $a000 to be sure it loads from most DOS
main lda #$21                                              ; main is a label
	sta $22f                                                   ; write #$21 into $22f -> DMA on
	lda #<dl                                                   ; load low part of the address of label dl into accumulator
	sta $230                                                   ; write it into the low part of DL vector
	lda #>dl                                                   ; now go for the high part of dl
	sta $231                                                   ; write it into the high part of DL vector
	jmp *                                                      ; endless jump to itselves


text dta d' HELLO, ',d'WORLD!  '*                          ; text is label; dta d writes things between ' ' into memory the star at the end is for adding 128 to each char,
                                                           ; so WORLD! becomes another colour. Try: dta d' HeLlO, ',d'WoRlD!  '*
; Display List
dl dta b($70),b($70),b($70),b($47),a(text),b($41),a(dl)    ; dl is label used in the upper code, $70 := 8 blank lines (or a full char line),
                                                           ; $47 := load memory address and set to charmode like BASIC GR. 2,
                                                           ; a(text) := store the address of text here,
                                                           ; b($41),a(dl) := ANTIC needs to know that the dl is over and where the start is for next run
	org $2e0                                                   ; following code will be compiled to $2e0 (RUN address of a compiled programme)
	dta a(main)                                                ; at least we have to set it to main

end