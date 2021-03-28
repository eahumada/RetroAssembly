10       .OPT NO LIST
0980     .OPT NO EJECT
0990     .TITLE "A sample device driver for Atari's OS"
1000     .PAGE "--- general remarks ---"
1010 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
1020 ;
1030 ; The "M:" driver --
1040 ;    Using memory as a device
1050 ;
1060 ; Includes installation program
1070 ;
1080 ; Written by Bill Wilkinson
1090 ;   for January, 1982, COMPUTE!
1100 ;
1110 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
1120 ;
1130 ; EQUATES INTO ATARI'S OS, ETC.
1140 ;
1150 ICAUX1 = $034A  ; The AUX1 byte of IOCB
1160 ;
1170 OPOUT = 8       ; Mode 8 is OPEN for OUTPUT
1180 ;
1190 MEMLO = $02E7   ; pointer to bottom of free RAM
1200 MEMTOP = $02E5  ; pointer to top of free RAM
1210 ;
1220 FR1 =   $E0     ; Fltg Pt Register 1, scratch
1230 ;
1240 STATUSOK = 1    ; I/O was good
1250 STATUSEOF = $88 ; reached an end-of-file
1260 ;
1270 HATABS = $031A
1280 ;
1290 HIGH =  $0100   ; divisor for high byte
1300 LOW =   $FF     ; mask for low byte
1310 ;
1320     .PAGE "The installation routine"
1330 ;====== CHANGE NEXT LINE TO SUIT YOUR MEMORY ======
1340     *=  $3000
1350 ; This first routine is simply
1360 ; used to connect the driver
1370 ; to Atari's handler address
1380 ; table.
1390 ;
1400 LOADANDGO
1410     LDX #0      ; We begin at start of table
1420 SEARCHING
1430     LDA HATABS,X ; Check device name
1440     BEQ EMPTYFOUND ; Found last one
1450     CMP #'M     ' ; Already have M: ?
1460     BEQ MINSTALLED ; Yes, don't reinstall
1470     INX 
1480     INX 
1490     INX         ; Point to next entry
1500     BNE SEARCHING ; and keep looking
1510     RTS         ; Huh? Impossible!!!
1520 ;
1530 ; We found the current end of the
1540 ; table...so extend it.
1550 ;
1560 EMPTYFOUND
1570     LDA #'M     ' ; Our device name, "M:"
1580     STA HATABS,X ; is first byte of entry
1590     LDA #MDRIVER&LOW
1600     STA HATABS+1,X ; LSB of driver addr
1610     LDA #MDRIVER/HIGH
1620     STA HATABS+2,X ; and MSB of addr
1630     LDA #0
1640     STA HATABS+3,X ; A new end for the table
1650 ;
1660 ; now change LOMEM so BASIC won't
1670 ; overwrite us.
1680 ;
1690 MINSTALLED
1700     LDA #DRIVERTOP&LOW
1710     STA MEMLO   ; LSB of top addr
1720     LDA #DRIVERTOP/HIGH
1730     STA MEMLO+1 ; and MSB therof
1740 ;
1750 ; and that's all we have to do!
1760 ;
1770     RTS 
1780 ;
1790 ;
1800 ;;;;;;;;;;;;;;;;;;;;;;;;;;;
1810 ;
1820 ; This entry point is provided
1830 ; so that BASIC can reconnect
1840 ; the driver via a USR(RECONNECT)
1850 ;
1860 RECONNECT
1870     PLA 
1880     BEQ LOADANDGO ; No parameters, I hope
1890     TAY 
1900 PULLTHEM
1910     PLA 
1920     PLA         ; get rid of a parameter
1930     DEY 
1940     BNE PULLTHEM ; and pull another
1950     BEQ LOADANDGO ; go reconnect
1960 ;
1970     .PAGE "The driver itself"
1980 ;
1990 ; Recall that all drivers must
2000 ; be connected to OS through
2010 ; a driver routines address table.
2020 ;
2030 MDRIVER
2040     .WORD MOPEN-1 ; The addresses must
2050     .WORD MCLOSE-1 ; ...be given in this
2060     .WORD MGETB-1 ; ...order and must
2070     .WORD MPUTB-1 ; ...be one (1) less
2080     .WORD MSTATUS-1 ; ...than the actual
2090     .WORD MXIO-1 ; ...address
2100     JMP MINIT   ; This is for safety only
2110 ;
2120 ; For many drivers, some of these
2130 ; routines are not needed, and
2140 ; can effectively be null routines
2150 ;
2160 ; A null routine should return
2170 ; a one (1) in the Y-register
2180 ; to indicate success.
2190 ;
2200 MXIO
2210 MINIT
2220     LDY #1      ; success
2230     RTS 
2240 ;
2250 ; If a routine is omitted because
2260 ; it is illegal (reading from a
2270 ; printer, etc.), simply pointing
2280 ; to an RTS is adequate, since
2290 ; Atari OS preloads Y with a
2300 ; 'Function Not Implemented' error
2310 ; return code.
2320 ;
2330     .PAGE "The driver function routines"
2340 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
2350 ;
2360 ; Now we begin the code for the
2370 ; routines that do the actual
2380 ; work
2390 ;
2400 MOPEN
2410     LDA ICAUX1,X ; Check type of open
2420     AND #OPOUT  ; Open for output?
2430     BEQ OPENFORREAD ; No...assume for input
2440     LDA MEMTOP
2450     STA MSTART  ; We start storing
2460     LDY MEMTOP+1 ; ...the bytes
2470     DEY         ; ...one page below
2480     STY MSTART+1 ; the supposed top of mem
2490 ;
2500 ; now we join up with mode 4 open
2510 ;
2520 OPENFORREAD
2530     LDA MSTART  ; simply move the
2540     STA MCURRENT ; ...start pointer
2550     LDA MSTART+1 ; ...to the current
2560     STA MCURRENT+1 ; ...pointer, both bytes
2570 ;
2580     LDY #STATUSOK
2590     RTS         ; we don't acknowledge failure
2600 ;
2610 ;
2620 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
2630 ;
2640 ; the routine for CLOSE of M:
2650 ;
2660 MCLOSE
2670     LDA ICAUX1,X ; check mode of open
2680     AND #OPOUT  ; was for output?
2690     BEQ MCLREAD ; no...close input 'file'
2700 ;
2710     LDA MCURRENT ; we establish our
2720     STA MSTOP   ; ...limit so that
2730     LDA MCURRENT+1 ; ...next use can't
2740     STA MSTOP+1 ; ...go too far
2750 ;
2760 MCLREAD
2770     LDY #STATUSOK
2780     RTS         ; and guaranteed to be ok
2790 ;
2800 ;
2810 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
2820 ;
2830 ; This routine puts one byte
2840 ; to the memory for later
2850 ; retrieval.
2860 ;
2870 MPUTB
2880     PHA         ; save the byte to be PUT
2890     JSR MOVECURRENT ; get ptr to zero page
2900     PLA         ; the byte again
2910     LDY #0
2920     STA (FR1),Y ; put the byte, indirectly
2930     JSR DECCURRENT ; point to nxt byte
2940     RTS         ; that's all
2950 ;
2960 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
2970 ;
2980 ; routine to get a byte put
2990 ; in memory before.
3000 ;
3010 MGETB
3020     JSR MSTATUS ; any more bytes?
3030     BCS MGETRTS ; no...error
3040     LDY #0
3050     LDA (FR1),Y ; yes...get a byte
3060     JSR DECCURRENT ; and point to next byte
3070 MGETRTS
3080     RTS 
3090 ;
3100 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
3110 ;
3120 ; check the status of the driver
3130 ;
3140 ; this routine is only valid
3150 ; when READing the 'file'...
3160 ; "M:" never gets errors when
3170 ; writing.
3180 ;
3190 MSTATUS
3200     JSR MOVECURRENT ; current ptr to zero page
3210     CMP MSTOP   ; any more bytes to get?
3220     BNE MSTOK   ; yes
3230     CPY MSTOP+1 ; double chk
3240     BNE MSTOK   ; yes, again
3250     LDY #STATUSEOF ; oops...
3260     SEC         ; no more bytes
3270     RTS 
3280 ;
3290 MSTOK
3300     LDY #STATUSOK ; all is okay
3310     CLC         ; flag for MGETB
3320     RTS 
3330     .PAGE "Miscellaneous subroutines"
3340 ;
3350 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
3360 ;
3370 ; finally, we have a couple of
3380 ; short and simple routines to
3390 ; manipulate MCURRENT, the ptr
3400 ; to the currently accessed byte
3410 ;
3420 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
3430 ;
3440 ; MOVECURRENT simply moves
3450 ;  MCURRENT to the floating
3460 ;  point register, FR1, in
3470 ;  zero page.  FR1 is always
3480 ;  safe to use except in the
3490 ;  middle of an expression.
3500 ;
3510 MOVECURRENT
3520     LDA MCURRENT
3530     STA FR1     ; notice that we use
3540     LDY MCURRENT+1 ; both the A and
3550     STY FR1+1   ; Y registers...this
3560     RTS         ; is for MSTATUS use
3570 ;
3580 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
3590 ;
3600 ; DECCURRENT simply does a two
3610 ;  byte decrement of the MCURRENT
3620 ;  pointer and returns with the
3630 ;  Y register indicating OK status.
3640 ; NOTE that the A register is
3650 ;  left undisturbed.
3660 ;
3670 DECCURRENT
3680     LDY MCURRENT ; check LSB's value
3690     BNE DECLOW  ; if non-zero, MSB is ok
3700     DEC MCURRENT+1 ; if zero, need to bump MSB
3710 DECLOW
3720     DEC MCURRENT ; now bump the LSB
3730     LDY #STATUSOK ; as promised
3740     RTS 
3750     .PAGE "RAM usage and clean up"
3760 ;
3770 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
3780 ;
3790 ; END OF CODE
3800 ;
3810 ;
3820 ; Now we define our storage
3830 ; locations.
3840 ;
3850 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
3860 ;
3870 ;
3880 ; MCURRENT holds the pointer to
3890 ; the next byte to be PUT or GET
3900 MCURRENT .WORD 0
3910 ;
3920 ; MSTOP is set by CLOSE to point
3930 ; to the last byte PUT, so GET
3940 ; won't try to go past the end
3950 ; of data.
3960 MSTOP .WORD 0
3970 ;
3980 ; MSTART is derived from MEMTOP
3990 ; and points to the first byte
4000 ; stored.  The bytes are stored
4010 ; in descending addresses until
4020 ; MSTOP is set by CLOSE.
4030 MSTART .WORD 0
4040 ;
4050 ; DRIVERTOP becomes the new
4060 ; contents of MEMLO
4070 DRIVERTOP = *+$FF&$FF00
4080 ; (sets to next page boundary)
4090 ;
4100 ;
4110 ; The following is how you make
4120 ; a LOAD-AND-GO file under
4130 ; Atari's DOS 2
4140 ;
4150     *=  $02E0
4160     .WORD LOADANDGO
4170 ;
4180 ;
4190     .END 
