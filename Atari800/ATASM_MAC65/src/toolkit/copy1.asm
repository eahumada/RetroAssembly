0100     .TITLE "COPY1 -- A SINGLE FILE COPY PROGRAM"
0101 ;
0102 ; before the first page, we give some printer options
0103 ;
;0104     .OPT NO CLIST
;0105     .OPT NO MLIST
;0106     .SET 2,120  ; line length is 120 characters
;0107     .SET 1,4    ; indent all except error lines!
0108 ; NOTE: you may need to put the character sequence for
0109 ;   "condensed print" into the .TITLE line if your
0110 ;   printer cannot print 120 characters per line
0111 ;   in default mode.
0112 ;
0113     .PAGE ".      SOME GENERAL REMARKS"
0114 ;
0115 ; This program is a "quick and dirty" program which will
0116 ;   copy one file only.  It is intended as a demonstration
0117 ;   of the capabilities of CPARSE and the MAC/65 ToolKit.
0118 ;
0119 ; This program is intended to be used from the command
0120 ;   line of OS/A+ or DOS XL (i.e., when the "D1:" prompt
0121 ;   is present).
0122 ;
0123 ; The calling format is:
0124 ;
0125 ; [Dn:]COPY1 fromfile tofile
0126 ;
0127 ;   where 'fromfile' and 'tofile' are any legitimate
0128 ;   Atari file or device names.
0129 ;
0130 ; Note that if you do NOT give a device specifier followed
0131 ;   by a colon (e.g., P: or D2:), the OSS CP (as called
0132 ;   by CPARSE in this program) will automatically prepend
0133 ;   "Dn:", where "n" is the same as the current prompt.
0134 ;   (See your OS/A+ or DOS XL manual for more on this topic.)
0135 ;
0136 ;
0137 ; This program makes use of much of the information published
0138 ;   in the OS/A+ and DOS XL manuals, in particular as regards
0139 ;   IOCB's and values returned from DOS calls.
0140 ;
0141 ; The program:
0142 ;
0143 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
0144 ;
0145     .PAGE ".      System Equates (not printed) and COPY1 fixed RAM usage"
0156 ;
0157 ; But then we turn off the KERNEL macros' saving
0158 ;   of X and Y registers (because we don't
0159 ;   count on them not changing), especially
0160 ;   in I/O macros.
0161 ;
0162 @@PUSHREGS .= 0 ; thus
0163 ;
0146 ;
0147       .IF .NOT .DEF CPALOC
0148 ;
0149 ; this code is only assembled on Pass 1, thanks to
0150 ;   the above .IF usage.
0151 ;
0152       .INCLUDE sysequ.asm
0153       .INCLUDE kernmac.asm
0154 ;
0155       .ENDIF 
0164 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
0165 ;
0166 ; First, we jump around CPARSE and the kernel routines
0167 ;   so that we can make this a .COM file for use
0168 ;   by the CP of OS/A+ and DOS XL.
0169 ;
0170 ; ======= change this to match your system's LOMEM =======
0171 ;
0172     *=  $2800
0173 ;
0174 ;
0175 COPY1
0176     JMP ACTUAL.START
0177 ;
0178 ;
0179 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
0180 ;
0181 ;
0182     .PAGE ".      CPARSE is INCLUDEd from disk"
0183     .INCLUDE cparse.asm
0184 ;
0185     .PAGE ".      KERNEL routines are INCLUDEd from disk"
0186 ;
0187 ; but we don't want them LISTed
0188 ;
0189     .OPT NO LIST
0190     .INCLUDE kerncode.asm
0191     .OPT LIST
0192 ;
0193     .PAGE ".      Equates, etc., unique to COPY1"
0194 ;
0195 ; The actual start of the COPY1 code!
0196 ;
0197 ;
0198 ; EQUATES and MACROS unique to this program!
0199 ;
0200 ; first:  equates
0201 ;
0202 ; File numbers
0203 ;
0204 INFILE = 2
0205 OUTFILE = 3
0206 ;
0207 ; only legal error
0208 ;
0209 EOF =   136     ; END OF FILE ERROR
0210 ;
0211 ; just a zero page temporary:
0212 ;
0213 PTR =   $D6     ; used by MOVENAME
0214 ;
0215 ;
0216 ; Elements of ARGV "array" used by this program
0217 ;
0218 ; ARGV(0) = ARGV = name this program was called via
0219 ;
0220 ARG.INFILE = ARGV+2 ; same as ARGV(1)
0221 ARG.OUTFILE = ARGV+4 ; same as ARGV(2)
0222 ;
0223 ; RAM used exclusively by COPY1
0224 ;
0225 BUFFER.BEGIN .WORD BUFFER.START ; a little redundant
0226     ;           (this is necessary to avoid a phase
0227     ;           error when the MINUS macro calculates
0228     ;           how big the buffer is)
0229 ;
0230 ;
0231 BUFFER.LENGTH .WORD 0 ; just temporary storage
0232 SAFETY .WORD $0200 ; leave 1 KB of memory free
0233 ;
0234 ; a place to keep the entry stack pointer
0235 ;
0236 SAVESTACK *= *+1
0237 ;
0238 ; buffers which can be used with OPEN macro
0239 ;
0240 NAME.INFILE *= *+20 ; input file
0241 NAME.OUTFILE *= *+20 ; output file
0242 ;
0243 ;
0244 ; then, some macros of our own!
0245 ;
0246     .MACRO FATAL 
0247      PUSHY      ; save error code
0248      PRINTSTR 0,%$1 ; print the message
0249      PULLY      ; recover error code
0250     JMP QQERR   ; let ToolKit print error number
0251     .ENDM 
0252 ;
0253     .MACRO MOVENAME 
0254      DPOKE  PTR,%1
0255     LDY #19
0256 @LP
0257     LDA (PTR),Y
0258     STA %2,Y
0259     DEY 
0260     BPL @LP
0261     .ENDM 
0262 ;
0263 ; the EXIT macro assumes that you have saved
0264 ;   the entry stack pointer in SAVESTACK
0265 ;
0266     .MACRO EXIT 
0267     LDX SAVESTACK
0268     TXS 
0269     RTS 
0270     .ENDM 
0271 ;
0272 ;
0273 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
0274 ;
0275     .PAGE ".      Beginning of actual code"
0276 ACTUAL.START
0277     TSX 
0278     STX SAVESTACK ; so we can return to DOS any time
0279     JSR CPARSE  ; decipher command line
0280     LDA ARGC    ; and we insist on
0281     CMP #3      ; ...exactly 3 "arguments"
0282     BNE ARGC.BAD ; oops...
0283     JMP ARGC.OK ; all ok
0284 ;
0285 ARGC.BAD
0286 ; oops...not 3 arguments
;0287      PRINTSTR "Invalid use of command!"
;0288      PRINTSTR "Proper format is:"
0289      PRINTSTR "   COPY1 fromfile tofile"
0290      EXIT       ; back to DOS XL or OS/A+
0291 ;
0292 ; if we get here, there were three arguments
0293 ;
0294 ; we ignore the first one (it is "D1:COPY1")
0295 ;
0296 ; second one is fromfile (input)
0297 ;  third one is tofile (output)
0298 ;
0299 ARGC.OK
0300 ; first, move names into buffers accessible by OPEN
0301      MOVENAME  ARG.INFILE,NAME.INFILE
0302      MOVENAME  ARG.OUTFILE,NAME.OUTFILE
0303 ; now, open both files...with caution
0304      TRAP  ERR.OPENIN
0305      OPEN  INFILE,OPIN,0,NAME.INFILE
0306      TRAP  ERR.OPENOUT
0307      OPEN  OUTFILE,OPOUT,0,NAME.OUTFILE
0308 ;
0309 ; if here, both files open ok
0310 ;
0311 ; figure out how big our copy buffer is
0312 ;
0313      CALC  MEMTOP ; free space is
0314      MINUS  BUFFER.BEGIN ; between
0315      MINUS  SAFETY ; buffer and himem
0316      STORE  BUFFER.LENGTH ; (with a bit of a safety factor)
0317 ;
0318 ; now start the actual data copy
0319 ;
0320 GETPUT.LOOP
0321      TRAP  ERR.BGET
0322      BGET  INFILE,BUFFER.START,BUFFER.LENGTH
0323 ; simply read in a buffer load of data...
0324      TRAP  ERR.BPUT
0325      BPUT  OUTFILE,BUFFER.START,BUFFER.LENGTH
0326 ; ...and write it back out.
0327     JMP GETPUT.LOOP ; and do it again
0328 ; (note that we do this until we get an error)
0329     .PAGE ".      Error handlers (including end of file)"
0330 ;
0331 ; ERR.BGET --
0332 ;    we expect to get an error from BGET eventually.
0333 ;    We presume that we will get an end of file
0334 ;    error (136, $88).
0335 ;
0336 ERR.BGET
0337     CPY #EOF    ; end of file?
0338     BNE ERR.BGET.REAL ; no!
0339 ;
0340 ; got an end of file on BGET...write
0341 ;   what we got and quit
0342 ;
0343      TRAP  ERR.BPUT
0344      BPUT  OUTFILE,BUFFER.START,ICBLEN+INFILE*16
0345 ; (the length is obtained from value returned by BGET)
0346 ;
0347 ; and we are done!
0348 ;
0349      CLOSE  INFILE ; that is, after we close
0350      CLOSE  OUTFILE ; both files
0351      EXIT  
0352 ;
0353 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
0354 ;
0355 ; these are the fatal errors!
0356 ;
0357 ERR.BGET.REAL
0358      FATAL  "Error while reading file"
0359 ;
0360 ERR.BPUT
0361      FATAL  "Error while writing file"
0362 ;
0363 ERR.OPENIN
0364      FATAL  "Could not open <fromfile>"
0365 ;
0366 ERR.OPENOUT
0367      FATAL  "Could not open <tofile>"
0368 ;
0369 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
0370 ;
0371     .PAGE ".      The actual copy buffer"
0372 ;
0373 ; We use all of memory from the end of the program to
0374 ;   (MEMTOP) as a buffer.
0375 ;
0376 BUFFER.START = *
0377 ;
0378     .END 
