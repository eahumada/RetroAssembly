;
; Example of creating a DOS friendly program using CIOV on Atari
;	- How to find an available channel
;	- Open screen and keyboard
;	- Open and read files
;	- Print Strings with and without carriage return
;	- Print character(s)
;
; by Norman Davie
;
; Assembled using WUSDN / MADS
;
; https://cowboy3398.wordpress.com/2020/11/10/cio-assembly-example-for-atari-8-bit/
;

 	ORG  $6000
;
BUFLEN 			= 25
;
EOL   			= $9B 	; ATASCII code for end of line
;	
CMD_OPEN 		= $03 	; Open a device or file
CMD_PUT_REC 		= $09   ; Send until EOL 
CMD_PUT_CHAR   		= $0B   ; Read specified number of characters
CMD_CLOSE 		= $0C 	; Close device or file
CMD_GET_REC 		= $05	; Read until EOL or buffer full
CMD_GET_CHAR		= $07	; Read specified number of characters
;
; OPTIONS FOR OPEN ICAX1
OREAD  	 		= $04 	; Read Only
OWRITE   		= $08  	; Write Only
OUPDATE  		= $0C  	; Read and write
ODIR     		= $02  	; Directory
ORDIR    		= $06  	; Read Directory
OAPPEND  		= $01  	; Append
OWAPPEND 		= $09  	; Write Append
SCLEAR_GT		= $10  	; Clear Graphics and Text
SKEEP_GT 		= $20  	; Keep Graphics and Text
SCLEAR_T 		= $30  	; Clear Text

EOFERR   		= $88   ;(136) END OF FILE

ICHID   		= $0340     ;   Set by OS. Handler Identifier. If not 
        		            ;   in use, the value is 255 ($FF), which 
        		            ;   is also the initialization value.
ICDNO   		= ICHID+1   ;   Set by OS. Device number (eg: D1: D2:).
ICCOM   		= ICHID+2   ;   Set by User. Command
ICSTA   		= ICHID+3   ;   Set by OS. May or may not be the same 
        		            ;   value as CMD_STATUS returned
ICBAL   		= ICHID+4   ;   Set by User. Buffer address (low byte)
ICBAH   		= ICHID+5   ;   Set by User. buffer address (high byte)
ICPTL   		= ICHID+6   ;   Used by BASIC. Address of put byte routine. 
ICPTH   		= ICHID+7   ;   Used by BASIC. Address of put byte routine. 
ICBLL   		= ICHID+8   ;   buffer length (low byte) in put/get operations
ICBLH   		= ICHID+9   ;   buffer length (high byte)
ICAX1   		= ICHID+10  ;   auxiliary information.  Used by Open cmd 
        		            ;   for READ/WRITE/UPDATE
        		            ;   Bit  7   6   5   4   3   2   1   0
        		            ;   Use  ....unused....  W   R   D   A
        		            ;   W equals write, R equals read, 
        		            ;   D equals directory, A equals append.
ICAX2   		= ICHID+11  ;   Auxiliary byte two
ICAX3   		= ICHID+12  ;   Auxiliary bytes three
ICAX4   		= ICHID+13  ;   Auxiliary bytes four
ICAX5   		= ICHID+14  ;   Auxiliary bytes five
ICAX6   		= ICHID+15  ;   Auxiliary bytes six
;
CIOV 			= $E456     ;	CIO VECTOR
;
BUFFER_SIZE		= 80

START:
OPEN_SCREEN

    	JSR GET_CHANNEL		; get an available IOCB channel
	CPX #$80
    	BNE GOT_SCREEN_CHANNEL
    	JMP DIE     		; If X == $80, no CIO available
;
GOT_SCREEN_CHANNEL:
    	STX E_CHANNEL		; keep track of the channel number

; 	LDX E_CHANNEL	 X contains the IOCB channel to use
    	LDA #CMD_OPEN           	; open the device
    	STA ICCOM,X  
;           
    	LDA #<E_DEVICE_NAME	; address of the string of the device (E)
    	STA ICBAL,X
    	LDA #>E_DEVICE_NAME  
    	STA ICBAH,X
;
    	LDA #OUPDATE            ; put chars to screen get chars from keyboard
    	STA ICAX1,X
;
    	LDA #$00 		; not used, but good practice to store zero here
    	STA ICAX2,X
;              	
    	STA ICBLH,X		; Not used
    	STA ICBLL,X
    	JSR CIOV
    	BPL OK1
    	JMP DIE			; Can't even write to screen!
OK1:	
; Ask user for filename
ASK_QUESTION:
    	LDA #<QUESTION
    	LDY #>QUESTION
    	JSR PRINT_STRING
;
READ_ANSWER:
; read the keyboard
	LDX E_CHANNEL
    	LDA #CMD_GET_REC       	; Get input from keyboard
    	STA ICCOM,X
;
    	LDA #<FILENAME      	; Where to store the result
    	STA ICBAL,X
    	LDA #>FILENAME
    	STA ICBAH,X  
;          
    	LDA #<BUFFER_SIZE     ; Max buffer size
    	STA ICBLL,X
    	LDA #>BUFFER_SIZE
    	STA ICBLH,X
;
    	JSR CIOV
    	BPL OPEN_FILE        	; all is well
    	TYA			; Error code is in Y
    	PHA
    	LDA #<ERROR
    	LDX #>ERROR
    	LDY ERROR_SIZE
    	JSR PRINT_STRING_NO_EOL
    	PLA
    	JSR PRINT_HEX
    	JMP CLOSE_ALL      	; oh oh


;
OPEN_FILE:	
    	JSR GET_CHANNEL		; need another channel
	CPX #$80
    	BNE GOT_D_CHANNEL
    	JMP CLOSE_ALL     	; If X == $80, no CIO available
;
GOT_D_CHANNEL:
    	STX D_CHANNEL		; keep track of the channel we want to open

;	LDX D_CHANNEL  X Contains the channel we want to use
    	LDA #CMD_OPEN
    	STA ICCOM,X
;
    	LDA #<FILENAME		; Address containing string of file we want to open
    	STA ICBAL,X		; Must include EOL character
    	LDA #>FILENAME
    	STA ICBAH,X
;   
	LDA #$00			; We don't need to specify length
	STA ICBLL,X
	STA ICBLH,X
	
    	LDA #OREAD		; Open it for read
    	STA ICAX1,X
    	LDA #0			; good practice to zero the second argument
    	STA ICAX2,X
    	
    	JSR CIOV
    	BPL OK2
    	TYA
    	PHA
    	LDA #<ERROR
    	LDX #>ERROR
    	LDY ERROR_SIZE
    	JSR PRINT_STRING_NO_EOL
    	PLA
    	JSR PRINT_HEX
    	JMP CLOSE_ALL
OK2:	
;
READ_NEXT:
	LDX D_CHANNEL		; We're using the D device
    	LDA #CMD_GET_CHAR	; We're going to get characters
    	STA ICCOM,X
;
    	LDA #<BUFFER		; This is where we're storing our characters
    	STA ICBAL,X
    	LDA #>BUFFER
    	STA ICBAH,X
    	
    	LDA #$01		; In this example, we'll only have
    	STA ICBLL,X		; a one character buffer
    	LDA #$00
    	STA ICBLH,X

	JSR CIOV
	BPL OK22
	CPY #EOFERR		; Are we at the end of the file?
	BEQ END_OF_FILE_REACHED
    	TYA			; Some other error occurred
    	PHA
    	LDA #<ERROR
    	LDX #>ERROR
    	LDY ERROR_SIZE
    	JSR PRINT_STRING_NO_EOL
    	PLA
    	JSR PRINT_HEX
	JMP CLOSE_ALL
OK22:
;
PRINT_TO_SCREEN:
    	LDX E_CHANNEL
    	LDA #CMD_PUT_CHAR	; send characters to the screen
    	STA ICCOM,X
    	LDA #<BUFFER		; address of the characters to send
    	STA ICBAL,X
    	LDA #>BUFFER
    	STA ICBAH,X
    	
    	LDA #<$01		; how many characters to send
    	STA ICBLL,X
    	LDA #>$00
    	STA ICBLH,X
    	
    	JSR CIOV
    	BPL READ_NEXT		; read some more
    	TYA			; couldn't write to screen!
    	PHA
    	LDA #<ERROR
    	LDX #>ERROR
    	LDY ERROR_SIZE
    	JSR PRINT_STRING_NO_EOL
    	PLA
    	JSR PRINT_HEX
;
END_OF_FILE_REACHED:
;
CLOSE_ALL:
	JSR WAIT_FOR_RETURN
;
    	LDX E_CHANNEL
    	JSR CLOSE_CHANNEL

    	LDX D_CHANNEL
    	JSR CLOSE_CHANNEL
DIE:
    	RTS 
;
;====================================
; GET_CHANNEL
;  Look for an unused channel
;  Unused channels contain an $FF in the
;  ICHID field
; RETURNS
;   X - Available channel * 16
;   if X == $80, no channel found
; OTHER REGISTERS AFFECTED
;   ALL
;====================================
GET_CHANNEL:
   	LDY #$00
CHECK_CHANNEL:
   	TYA      		; Transfer Y to the Accumulator
   	CLC
   	ROL   			; Multiply it by 16
   	ROL
   	ROL
   	ROL
   	TAX      		; Transfer A to the X register
   	LDA ICHID,X
   	CMP #$FF 		; if the Channel ID is FF it's available
   	BEQ AVAILABLE
   	INY
   	CMP #$07
   	BNE CHECK_CHANNEL
   	LDX #$80		; $80 indicates no channel available
AVAILABLE:
   	RTS

;
;====================================
; PRINT_HEX
;   Displays the A register on screen
;   assumes succefull open of screen
; RETURNS
;   NOTHING
; REGISTERS AFFECTED
;   NONE
;====================================
PRINT_HEX:
   	PHA		; Save A once
   	PHA          	; Save A again
   	LSR 
   	LSR 
   	LSR 
   	LSR     	
   	CLC
   	CMP #$0A
   	BPL A_F1
   	ADC #'0'
   	JMP STORE_TOP_NIBBLE
A_F1:
   	ADC #'A'-$0B
STORE_TOP_NIBBLE:
   	STA HEX_BUFFER
;   
   	PLA		; Get back A
   	AND #$0F
   	CLC
   	CMP #$0A
   	BPL A_F2
   	ADC #'0'
   	JMP STORE_BOT_NIBBLE
A_F2:
   	ADC #'A'-$0B
STORE_BOT_NIBBLE:
   	STA HEX_BUFFER+1 
; $9B is already in HEX_BUFFER+2
   	TXA
   	PHA		; Save X
   	TYA
   	PHA		; Save Y
   	LDA #<HEX_BUFFER
   	LDY #>HEX_BUFFER
   	JSR PRINT_STRING
   	PLA
   	TAY		; Restore Y
   	PLA
   	TAX		; Restore X
   	PLA		; Restore A
   	RTS  
;====================================
; CLOSE_CHANNEL
;   Close channel if open
;   X = channel to close
;     will be $80 if never opened
; RETURNS
;   Nothing
; OTHER REGISTERS AFFECTED
;   ALL
;====================================
CLOSE_CHANNEL:
    	CPX #$7F
    	BPL ALREADY_CLOSED
; Close the channel
    	LDA #CMD_CLOSE
    	STA ICCOM,X
    	JSR CIOV
ALREADY_CLOSED:
    	RTS
;
;====================================
; PRINT_STRING
;   Displays message on screen
;   *** Assumes E_CHANNEL is open
;   A = low byte of address
;   Y = high byte of address
; RETURNS
;   NOTHING
; OTHER REGISTERS AFFECTED
;   ALL
;====================================
PRINT_STRING:
    LDX E_CHANNEL
    STA ICBAL,X
    TYA
    STA ICBAH,X
    LDA #CMD_PUT_REC       ; Prepare to send to screen
    STA ICCOM,X
    LDA #$00
    STA ICBLL,X
    LDA #$FF
    STA ICBLH,X
    JSR CIOV
    RTS
    
;
;====================================
; PRINT_STRING_NO_EOL
;   Displays message on screen
;   *** Assumes E_CHANNEL is open
;   A = low byte of address
;   X = high byte of address
;   Y = number of charactesr
; RETURNS
;   NOTHING
; OTHER REGISTERS AFFECTED
;   ALL
;    	LDA #<ERROR
;    	LDX #>ERROR
;    	LDY ERROR_SIZE
;    	JSR PRINT_STRING_NO_EOL
;====================================    	
PRINT_STRING_NO_EOL:
    STX TEMP
    LDX E_CHANNEL
    STA ICBAL,X
    LDA TEMP
    STA ICBAH,X	
    LDA #CMD_PUT_CHAR       ; Prepare to send to screen
    STA ICCOM,X
    TYA
    STA ICBLL,X
    LDA #$00
    STA ICBLH,X
    JSR CIOV
    RTS
    
;====================================
; WAIT_FOR_RETURN
;   If screen_keyboard_channel is open
;   then waits for enter key
; RETURNS
;   Nothing
; OTHER REGISTERS AFFECTED
;   None
;====================================    	
WAIT_FOR_RETURN:    	
; Wait for enter key from screen *IF* we have the screen and keyboard channel
	PHA
	TXA
	PHA
	TYA
	PHA
    	LDX E_CHANNEL
    	CPX #$7F
    	BPL WFE_DONE
    	LDA #<PRESS_RETURN
    	LDY #>PRESS_RETURN
    	JSR PRINT_STRING
    
; wait for a key
    	LDX E_CHANNEL
    	LDA #CMD_GET_REC       	; Get input from keyboard
    	STA ICCOM,X
    	LDA #<PRESS_RETURN   ; Where to store the result
    	STA ICBAL,X
    	LDA #>PRESS_RETURN
    	STA ICBAH,X            
    	LDA #<ERROR_SIZE     ; Max buffer size
    	STA ICBLL,X
    	LDA #>ERROR_SIZE
    	STA ICBLH,X
    	JSR CIOV
    	PLA
    	TAY
    	PLA
    	TAX
    	PLA
WFE_DONE:
    	RTS  
;====================================
; DATA
;====================================
E_DEVICE_NAME:	.BYTE 'E:',EOL
;
E_CHANNEL: 	.BYTE $FF
D_CHANNEL: 	.BYTE $FF
;
QUESTION:	.BYTE 'File to display:',EOL
ERROR:		.BYTE 'ERROR: ', EOL
ERROR_SIZE	.BYTE 7
TEMP		.BYTE 0
CANT_FIND_FILE: .BYTE 'Can''t open the file',EOL
PRESS_RETURN	.BYTE 'Press RETURN to end', EOL
;
FILENAME:	.DS   BUFFER_SIZE
BUFFER:		.DS   BUFFER_SIZE
HEX_BUFFER: 	.BYTE 0,0,EOL
;
     run START