9000       .IF .NOT .DEF CPALOC
9001 ;
9002 ; Note that these equates will not be assembled
9003 ;   if CPALOC has been previously defined
9004 ;   (e.g., if you have .INCLUDEd SYSEQU)
9005 ;
9006 ; Also note that they will not be assembled
9007 ;   on the second pass of the assembly
9008 ;   (because CPALOC will have been defined in this block
9009 ;   in the first pass!)
9010 ;
9011 ; This is a good trick to use in your own programs.
9012 ;
9013 ;
9014 ; MISC ADDRESS EQUATES
9015 ;
9016 CPALOC =  $0A   ; pointer to beginning of Console Processor
9017 MEMLO =   $02E7 ; AVAIL MEM (LOW) PTR
9018 MEMTOP =  $02E5 ; AVAIL MEM (HIGH) PTR
9019 ;
9020 ;  CP internal function, pointer, address, etc. displacements
9021 ;
9022 ;  These locations must be accessed indirectly through CPALOC
9023 ;        i.e.:  LDA (CPALOC),Y
9024 ;
9025 CPGNFN =  3     ; GET NEXT FILE NAME
9026 CPDFDV =  $07   ; DEFAULT DRIVE (3 BYTES)
9027 CPBUFP =  $0A   ; CMD BUFF NEXT CHAR POINTR (1 BYTE)
9028 CPEXFL =  $0B   ; EXECUTE FLAG
9029 CPEXFN =  $0C   ; EXECUTE FILE NAME (16 BYTES)
9030 CPEXNP =  $1C   ; EXECUTE NOTE/POINT VALUES
9031 CPFNAM =  $21   ; FILENAME BUFFER
9032 RUNLOC =  $3D   ; CP LOAD/RUN ADR
9033 CPCMDB =  $3F   ; COMMAND BUFFER (60 BYTES)
9034 CPGOCMD = $AF   ; ENTRY POINT FOR DO AND MENU
9035 ;
9036       .ENDIF    ; [ .not .def CPALOC ]
9037 ;
9038     .PAGE "CPARSE -- OS/A+ command line parser"
9039 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9040 ;
9041 ; CPARSE -- command line parser for '.COM' command files
9042 ;
9043 ;
9044 ; CAUTION:
9045 ;   If CPARSE is INCLUDEd at beginning of user program,
9046 ;   the program should begin with a JMP around CPARSE
9047 ;   or should specify a run address, else CP will
9048 ;   try to execute CPARSE and will loop forever.
9049 ;
9050 ; ENTRY:
9051 ;  should be called immediately after entry to
9052 ;  the .COM program from OS/A+ or DOS XL
9053 ;
9054 ; EXIT:
9055 ; [1]'ARGC' is a byte location containing the count of the number of
9056 ;    file names found on the command line (includes the name of the
9057 ;    .COM program itself, so is always greater than zero)
9058 ; [2]'ARGV' is an array of .WORD pointers (8 max), each pointing to the
9059 ;    processed filename in the corresponding position on the command
9060 ;    line.  ARGV[0], for example, is always the name of the .COM
9061 ;    program itself.  The processed names themselves are placed in
9062 ;    an internal buffer (ARGBUF) capable of holding at most 256 bytes
9063 ;    total.  'Processed' implies that the default disk/directory
9064 ;    specifier has been prepended to the command line file name, if
9065 ;    one was not supplied in the command line.
9066 ;
9067 ; [3]'ARGFLAGS' is an array of 36 one-byte flags which are built from
9068 ;    user-requested flags in the command line.  A command flag consists
9069 ;    of a character '+' or '-' followed by one or more alphanumeric
9070 ;    characters.  Each one-byte flag is built as follows:
9071 ;     a. ALPHA characters following one of the flags ('-' or '+')
9072 ;        change the state of one of first 26 flags in ARGFLAGS,
9073 ;        corresponding in position to their position in the alphabet.
9074 ;     b. NUMERIC characters following a flag change the state of one
9075 ;        of the last 10 flags, corresponding to their numeric value.
9076 ;     c. The state of each byte in ARGFLAGS shall be:
9077 ;        0  -- if the corresponding character was not used as a flag.
9078 ;        n  -- where 'n' is the position of the flag in the command
9079 ;              line and corresponds to the index (in ARGV) of the file
9080 ;              name which the flag PRECEDED.
9081 ;        n+$80 -- where 'n' is as above and the $80 bit indicates that
9082 ;              the flag character used was '-' instead of '+'.
9083 ; [4] Note that, in addition to the name 'ARGLAGS' given to the entire
9084 ;    array of flags, each flag has a label associated with it of the
9085 ;    form 'FLAG.x', where 'x' is the character corresponding to the
9086 ;    particular flag.
9087 ; [5]'FLAG.IN' and 'FLAG.OUT' are each one byte flags which, like the
9088 ;    character flags, tell the position in the command line of the
9089 ;    symbols '<' (.IN) and '>' (.OUT).  These flags are presumed to
9090 ;    be used in future products associated with 'Redirected I/O'.
9091 ;
9092     .PAGE 
9093 ;
9094 ; EXAMPLE:
9095 ;  given the command line below (with the prompt 'D2:'):
9096 ; [D2:]PROG -O D1:FILE1.OUT FILEA FILEB
9097 ;
9098 ;  the following would occur on a call to CPARSE:
9099 ;  1. ARGC would contain 4
9100 ;  2. the first 4 entries of ARGV would point, respectively, to:
9101 ;      D2:PROG
9102 ;      D1:FILE1.OUT
9103 ;      D2:FILEA
9104 ;      D2:FILEB
9105 ;  3. FLAG.O would contain $81, indicating the '-' flag used with 'O'
9106 ;     in front of the first filename after the command.
9107 ;
9108 ;
9109 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9110     .PAGE "CPARSE data area"
9111 ;
9112 ; The data areas:
9113 ;
9114 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9115 ;
9116 BEGIN.DATA
9117 ;
9118 ; The argument count and vectors
9119 ;
9120 ARGC .BYTE 0
9121 ARGV .WORD 0,0,0,0,0,0,0,0
9122 ;
9123 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9124 ;
9125 ; miscellaneous counters
9126 ;
9127 CP.SAVBUFP *= *+1 ; save (CPALOC),CPBUFP here
9128 CP.BUFCNT *= *+1 ; count of chars used in ARG.BUF
9129 ;
9130 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9131 ;
9132 ; The redirection flags
9133 ;
9134 FLAG.INOUT
9135 FLAG.IN *= *+1
9136 FLAG.OUT *= *+1
9137 ;
9138 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9139 ;
9140 ; The command line flags
9141 ;
9142 ARGFLAGS
9143 ; The alphabetic flags
9144 FLAG.A *= *+1
9145 FLAG.B *= *+1
9146 FLAG.C *= *+1
9147 FLAG.D *= *+1
9148 FLAG.E *= *+1
9149 FLAG.F *= *+1
9150 FLAG.G *= *+1
9151 FLAG.H *= *+1
9152 FLAG.I *= *+1
9153 FLAG.J *= *+1
9154 FLAG.K *= *+1
9155 FLAG.L *= *+1
9156 FLAG.M *= *+1
9157 FLAG.N *= *+1
9158 FLAG.O *= *+1
9159 FLAG.P *= *+1
9160 FLAG.Q *= *+1
9161 FLAG.R *= *+1
9162 FLAG.S *= *+1
9163 FLAG.T *= *+1
9164 FLAG.U *= *+1
9165 FLAG.V *= *+1
9166 FLAG.W *= *+1
9167 FLAG.X *= *+1
9168 FLAG.Y *= *+1
9169 FLAG.Z *= *+1
9170 ; The numerical flags
9171 FLAG.0 *= *+1
9172 FLAG.1 *= *+1
9173 FLAG.2 *= *+1
9174 FLAG.3 *= *+1
9175 FLAG.4 *= *+1
9176 FLAG.5 *= *+1
9177 FLAG.6 *= *+1
9178 FLAG.7 *= *+1
9179 FLAG.8 *= *+1
9180 FLAG.9 *= *+1
9181 ;
9182 END.DATA
9183 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9184 ;
9185 ; ARG.BUF -- where we move the command line filenames to
9186 ;
9187 ARG.BUF *= *+128 ; allow room for 128 bytes...in some versions of
9188     *=  *+1     ; OS/A+ this might need to be 256 bytes.
9189 ;
9190 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9191 ;
9192 ; since 6502 doesn't have JSR (ADDR),
9193 ;   we have to simulate it thus:
9194 ;
9195 CP.GETFN JMP CP.GETFN ; changed by initialization
9196 ;
9197     .PAGE "CPARSE entry and initialization"
9198 ;
9199 ; CPARSE -- the mainline routine
9200 ;
9201 CPARSE
9202     LDY #END.DATA-BEGIN.DATA-1 ; first,
9203     LDA #0      ; we need to clear all our flags, etc.
9204 CP.CLRLOOP
9205     STA BEGIN.DATA,Y ; by zeroing all bytes
9206     DEY         ; of the data area
9207     BPL CP.CLRLOOP ; (data area is < 128 bytes)
9208 ;
9209 ; now begins the real work
9210 ;
9211     CLC 
9212     LDA CPALOC
9213     ADC #CPGNFN ; we are building the address
9214     STA CP.GETFN+1
9215     LDA CPALOC+1
9216     ADC #0
9217     STA CP.GETFN+2 ; of the "get file name" routine
9218 ;
9219 ; now we reset the filename getting process back to start of cmd line
9220 ;
9221     LDY #CPBUFP ; offset to buffer ptr
9222     LDA #0
9223     STA (CPALOC),Y ; now reset
9224 ;
9225 ;
9226 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9227 ;
9228 ; The major loop of CPARSE --
9229 ;    performed until there are no more file names or flags to get
9230 ;
9231 ;
9232 CP.LOOP
9233     LDY #CPBUFP ; the current buffer ptr pointer
9234     LDA (CPALOC),Y ; buffer offset to A
9235     STA CP.SAVBUFP ; then save it for a nonce
9236     JSR CP.GETFN ; the address we built up
9237 ;
9238     LDY #CPBUFP ; the pointer pointer again
9239     LDA CP.SAVBUFP ; recover the former buffer ptr value
9240     CMP (CPALOC),Y ; did we get more from the CMD line?
9241     BEQ CP.NOMORE ; no...quit now
9242 ;
9243 ; to here: we got either a filename or a set of flags
9244 ;
9245     LDY #CPFNAM ; the pointer to the name buffer
9246 ; we scan for the colon
9247 CP.COLON
9248     LDA (CPALOC),Y
9249     CMP #':     ; is this the colon?
9250     BEQ CP.CFND ; yes
9251     INY         ; to next char
9252     BNE CP.COLON
9253     SEC         ; oops...bad command line?
9254     RTS         ; carry set says 'OOPS'
9255 ;
9256 ; we got the colon...check for flags
9257 ;
9258 CP.CFND
9259     INY 
9260     LDA (CPALOC),Y ; the possible flag
9261     CMP #'>     ; redirected output?
9262     BEQ CP.OUT
9263     CMP #'<     ; redirected input?
9264     BEQ CP.IN
9265     CMP #'-     ; flags follow?
9266     BEQ CP.MINUS ; yes
9267     CMP #'+     ; flags follow?
9268     BEQ CP.PLUS ; yes
9269     CMP #'0
9270     BCC CP.GOFNAM ; not a digig
9271     CMP #1+'9
9272     BCS CP.GOFNAM ; not a digit
9273     LDA ARGC    ; is this first arg?
9274     BEQ CP.LOOP ; yes...ignore line number
9275 ;
9276 CP.GOFNAM
9277     JMP CP.FNAM ; if none of those, must be filename
9278 ;
9279 ; CP.NOMORE -- no more to process
9280 ;
9281 CP.NOMORE CLC   ; simply go back to caller
9282     RTS         ; ...with carry clear meaning 'OK'
9283     .PAGE "CPARSE -- process < and > flags"
9284 ;
9285 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9286 ;
9287 ; CP.IN and CP.OUT -- process the < and > flags
9288 ;
9289 CP.IN
9290     LDX #FLAG.IN-FLAG.INOUT
9291     JMP CP.INOUT
9292 CP.OUT
9293     LDX #FLAG.OUT-FLAG.INOUT
9294 ;
9295 CP.INOUT
9296     LDA ARGC    ; we get the current file name number
9297     STA FLAG.INOUT,X ; and set the redirection flag as needed
9298 ;
9299 ; now fix up cmd buffer ptr in case user did '>file' with no space
9300 ;
9301     INY         ; to next char following
9302     LDA (CPALOC),Y ; get that char
9303     CMP #'A     ; is it alpha?
9304     BCC CP.IOQUIT ; no
9305     CMP #'Z+1   ; alpha?
9306     BCS CP.IOQUIT ; no
9307 ; next char is alpha, presume it is filename...user forgot the space
9308     LDY #CPBUFP ; again, the buffer ptr
9309     LDA (CPALOC),Y ; get the current buffer offset
9310     CLC 
9311     ADC #CPCMDB ; include offset to buffer
9312     TAY         ; make a buffer ptr out of Y reg
9313     DEY         ; back up one char
9314 ;
9315 CP.IOLP
9316     LDA (CPALOC),Y ; get a char from cmd buf
9317     CMP #'<     ; redirector?
9318     BEQ CP.ADJUST ; yes
9319     CMP #'>     ; other kind?
9320     BEQ CP.ADJUST
9321     DEY 
9322     BNE CP.IOLP ; keep looking
9323 ;
9324 CP.ADJUST
9325     INY         ; back to first alpha char
9326     TYA 
9327     SEC 
9328     SBC #CPCMDB ; change from buf ptr to offset
9329     BMI CP.IOQUIT ; shouldn't happen
9330     LDY #CPBUFP ; ptr to offset again
9331     STA (CPALOC),Y ; and we have backed up...we hope
9332 ;
9333 ;
9334 CP.IOQUIT
9335     JMP CP.LOOP ; get next parameter
9336     .PAGE "CPARSE -- process the + and - flags"
9337 ;
9338 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9339 ;
9340 ; CP.MINUS and CP.PLUS -- process '-' and '+' flags
9341 ;
9342 CP.MINUS
9343     LDA #$80    ; the 'minus' flag
9344     BNE CP.PM
9345 CP.PLUS
9346     LDA #0      ; the plus flag
9347 ;
9348 CP.PM
9349     ORA ARGC    ; include the filename count
9350 ;
9351 ; now process all legit characters following the flag
9352 ;
9353 CP.PMLP
9354     INY         ; to next char
9355     PHA         ; save the flag value
9356     LDA (CPALOC),Y ; get the possible flag character
9357     TAX         ; transfer the character to use it as index
9358     PLA         ; and recover the flag value to use
9359     CPX #'A     ; is it alpha?
9360     BCC CP.PMNUM ; no...check for numeric
9361     CPX #'Z+1   ; is it alpha
9362     BCS CP.PMQUIT ; no...and can't be numeric...so quit
9363 ; if to here, is alpha
9364     STA FLAG.A-'A,X ; so set up the proper flag
9365     BCC CP.PMLP ; do another character
9366 ;
9367 ; if here, possible numeric flag
9368 ;
9369 CP.PMNUM
9370     CPX #'0     ; numeric?
9371     BCC CP.PMQUIT ; no
9372     CPX #'9+1   ; numeric?
9373     BCS CP.PMQUIT ; no
9374     STA FLAG.0-'0,X ; yes...so setup the flag
9375     BCC CP.PMLP
9376 ;
9377 ; end of flag characters
9378 ;
9379 CP.PMQUIT
9380     JMP CP.LOOP ; another flag or name to do...maybe
9381     .PAGE "CPARSE -- process a filename"
9382 ;
9383 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
9384 ;
9385 ; CP.FNAM -- we have a valid filename to process
9386 ;
9387 CP.FNAM
9388     LDA ARGC    ; get cnt of filenames so far
9389     ASL A       ; double, to use as ptr
9390     TAX         ; ...actually as index
9391     LDA CP.BUFCNT
9392     CLC 
9393     ADC #ARG.BUF&255 ; develop address where
9394     STA ARGV,X  ; ...this argument will be
9395     LDA #0
9396     ADC #ARG.BUF/256
9397     STA ARGV+1,X ; both bytes, of course
9398 ;
9399     LDY #CPFNAM ; start of the filename in buffer
9400     LDX CP.BUFCNT ; count of characters in ARG.BUF
9401 ; we move characters from CP's internal buffer to our master buffer
9402 ;
9403 CP.FNLP
9404     LDA (CPALOC),Y ; get a character
9405     BMI CP.FNDONE ; presumably, a RETURN ($9B) character
9406     CMP #$21    ; is it a space or less?
9407     BCC CP.FNDONE ; yes
9408     STA ARG.BUF,X ; good character...save it
9409     INX         ; bump counter
9410     INY         ; and pointer
9411     CPY #CPFNAM+15 ; max number of chars we transfer
9412     BNE CP.FNLP ; more to do
9413 ;
9414 ; if to here, either got a non filename char or moved 15 chars
9415 ;
9416 CP.FNDONE
9417     LDA #0
9418     STA ARG.BUF,X ; ensure good terminator
9419     INX         ; to start of next position in ARG.BUF
9420     STX CP.BUFCNT ; for next file name
9421 ;
9422     INC ARGC    ; and say we have gotten another file!
9423 ;
9424     JMP CP.LOOP ; next cmd line name or flag
9425 ;
