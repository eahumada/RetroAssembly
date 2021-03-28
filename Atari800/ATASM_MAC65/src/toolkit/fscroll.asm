0100     .TITLE "Fine scrolling demonstration"
0101 ;
0102 ; file:  FSCROLL.DEM
0103 ;
0104 ; Fine scrolling demonstration for
0105 ;   the MAC/65 Toolkit diskette.
0106 ;
0107 ; This program uses the scrolling macros
0108 ; and routines contained in the file
0109 ; SCROLL.M65 to perform fine scrolling
0110 ; under joystick control over an array
0111 ; of character data.  Graphics mode 0
0112 ; is used to avoid designing a custom
0113 ; character set.
0114 ;
0115 ; The program proceeds as follows:
0116 ;   1) The array of characters over
0117 ;      which to scroll is set up with
0118 ;      sequentially increasing character
0119 ;      values (just to fill the array
0120 ;      with a somewhat meaningful
0121 ;      pattern.  The size of the array
0122 ;      is 64x64, but these dimensions
0123 ;      may be changed by modifying the
0124 ;      global constants XSIZE and YSIZE.
0125 ;   2) Fine scrolling is initiated by
0126 ;      using the macro SCRDIM.  This
0127 ;      macro expects as parameters the
0128 ;      character array dimensions, the
0129 ;      addresses of the character array
0130 ;      as well as free memory to put
0131 ;      a display list, and the desired
0132 ;      ANTIC mode in which to display the
0133 ;      array.  The SCRDIM macro automatically
0134 ;      sets the lower right limit of
0135 ;      scrolling.  At the same time, the
0136 ;      POKE macro is used to specify the
0137 ;      speed at which to scroll.
0138 ;   3) The main program loop is enterred
0139 ;      which just sets the direction
0140 ;      value of joystick zero to be the
0141 ;      direction of scroll.  At the same
0142 ;      time, the START key is polled.
0143 ;      If the START key is pressed, the
0144 ;      program exits by returning the
0145 ;      screen to graphics mode zero,
0146 ;      and then performing an RTS.
0147 ;
0148     .PAGE "equates and constants"
0149 ;
0150 ; constants:
0151 ;
0152 XSIZE = 128     ; horizontal size of character array
0153 YSIZE = 64      ;  vertical   "   "      "       "
0154 ;
0155 ;
0156 ; hardware locations:
0157 ;
0158 CONSOLE = $D01F
0159 STARTKEY = 1    ; START key is low order bit.
0160 STICK0 = $0278  ; Location for joystick 0
0161 ;
0162 ;
0163 ; zero page memory:
0164 ;
0165 CHPTR = $D4     ; pointer used for indirect access to array
0166 ;
0167 ;
0168 ; and, finally, our own macro!
0169 ;
0170     .MACRO BOUNDARY 
0171     *=  [*+%1-1]&[0-%1]
0172     .ENDM 
0173 ;
0174     .PAGE "setup of character array"
0175 ;
0176     *=  $5000
0177 ;
0178 ; Start of code-- First, fill character array
0179 ;   with sequential characters starting with
0180 ;   the value zero.  Since the character array
0181 ;   is used as screen memory, we are filling
0182 ;   it with the actual screen codes.
0183 ;
0184 MAIN
			JMP FILLARRAY
0185 ;
0186 ; includes of macro and subroutine libraries:
0187 ;
0188     .OPT NO LIST
0189       .IF .NOT .DEF @PASS
0190       .INCLUDE kernmac.asm
0191 PASS  .=  2     ; PASS 1 DONE
0192       .ENDIF 
0193     .INCLUDE kerncode.asm
0194     .INCLUDE scroll.asm
0195     .OPT LIST ; ,NO MLIST,NO CLIST
0196 ;
0197 ;
0198 FILLARRAY  POKE  CURCHAR,0 ; Start with screen value of zero
0199      VPOKE  CHPTR,SCREEN ; Point at start of screen array
0200 ;
0201 ; Loop to fill screen array with data:
0202 ;
0203      DOI  1,XSIZE
0204      DOJ  1,YSIZE
0205 ;
0206     LDY #0      ; Store current character value in array.
0207     LDA CURCHAR
0208     STA (CHPTR),Y
0209 ;
0210      DINC  CHPTR ; Move to next array position.
0211     INC CURCHAR ; And bump screen code.
0212 ;
0213      LOOPJ  
0214      LOOPI  
0215 ;
0216     .PAGE "Initiate fine scrolling"
0217 ;
0218 ; Begin fine scrolling by calling the
0219 ;   SCRDIM macro.
0220 ;
0221 ; ANTIC mode 2, xsize by ysize screen array,
0222 ; DLIST is address to put display list,
0223 ; SCREEN is address of character array.
0224      SCRDIM  2,XSIZE,YSIZE,DLIST,SCREEN
0225 ;
0226 ; Print instructions (pretty simple!):
0227 ;
0228      CR         ; Clear text window
0229      CR
		WAIT 60
		WAIT 60
0230      PRINTSTR "Use joystick to scroll screen."
0231      PRINTSTR "Push START key to stop program."
0232 ;
0233 ;
0234 ; Main loop:  Copy joystick 0 value into
0235 ;   scrolling direction until START key
0236 ;   is pressed.
0237 ;
0238 LOOP  POKE  SCROLL,STICK0 ; Use joystick value as scroll direction.
0239     LDA CONSOLE ; Check START key
0240     AND #STARTKEY
0241     BNE LOOP
0242 ;
0243 ;
0244 ; Start key was pressed-- return to
0245 ;   graphics mode 0 and return to DOS.
0246 ;
0247      STOPSCROLL  
0248      GR  0
0249     RTS 
0250 ;
0251     .PAGE "Variables and array storage"
0252 ;
0253 CURCHAR *= *+1  ; Char counter used to fill screen array
0254 ;
0255 ; Display list memory-- must not cross 1K
0256 ;   boundary, so start it at 1K boundary.
0257      BOUNDARY  1024
0258 DLIST *= *+$0100 ; Reserve 1 page for safety.
0259 ;
0260 ; Screen array-- individual lines may not cross 4K
0261 ;   boundary, so start screen on 4K boundary (overkill).
0262 ;
0263      BOUNDARY  4096
0264 SCREEN *= *+[XSIZE*YSIZE]
0265 ;
0266 ;
0267	*=$02E0
0268	.WORD MAIN
0267 ; End of program.
