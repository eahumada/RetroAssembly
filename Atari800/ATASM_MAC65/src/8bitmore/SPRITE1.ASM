10 ; LIST #D:SPRITE1.ASM
20 ;
30 ;
40       .OPT OBJ
50       *=  $5000
60 ;
70 ICHID =   $0340
80 ICDNO =   $0341
90 ICCOM =   $0342
0100 ICSTA = $0343
0110 ICBAL = $0344
0120 ICBAH = $0345
0130 ICPTL = $0346
0140 ICPTH = $0347
0150 ICBLL = $0348
0160 ICBLH = $0349
0170 ICAUX1 = $034A
0180 ICAUX2 = $034B
0190 CLOSE = $0C
0200 OPEN =  $03
0210 CIOV =  $E456
0220 ;
0230 YLOC =  $CC     ;Ind Address for Y
0240 XLOC =  $CE     ;X Position
0250 PMBASE = $D0    ;pmbase address
0260 STOTOP = $0100  ;keep for now
0270 STICK0 = $D300  ;joystick 0 pos
0280 HPOSP0 = $D000  ;Horz POS Player 0
0290 SNAME .BYTE "S:",$9B ;screen device
0300 PLAYER .BYTE 24,60,126,102,126,255,66,66 ;player 0 bitmap data
0310 ;
0320 ;
0330 ;
0340 ;
0350 ;
0360     LDA 106     ;Get top of RAM
0370     STA STOTOP
0380     SEC         ;Setup for subtraction
0390     SBC #4      ;Save 4 pages for pmg double line resolution
0400     STA 106     ;Set new ramtop
0410     STA 54279   ;PMBASE
0420     STA PMBASE+1 ;high byte
0430     LDA #0
0440     STA PMBASE  ;low byte
0450 ;
0460 ;
0470 ;
0480     LDA #5+16   ;gr.5 no window
0490     PHA 
0500     LDX #$60    ;IOCB6 for screen
0510     LDA #CLOSE
0520     STA ICCOM,X ;Close device first
0530     JSR CIOV
0540     LDX #$60
0550     LDA #OPEN   ;Open screen
0560     STA ICCOM,X
0570     LDA #SNAME&255 ;"S:" for screen
0580     STA ICBAL,X
0590     LDA #SNAME/256
0600     STA ICBAH,X
0610     PLA 
0620     STA ICAUX2,X
0630     AND #$F0    ;Get high 4 bits
0640     EOR #$10    ;Flip high bit
0650     ORA #$0C    ;Read or Write
0660     STA ICAUX1,X ;n+16, n+32 etc.
0670     JSR CIOV
0680 ;
0690 ;
0700 ;
0710     LDA #46     ;double line resolution
0720     STA 559     ;
0730 ;
0740 ;
0750 ;
0760     LDY #0
0770     LDX #4
0780     LDA #0      ;zero means blank
0790 CLEARPM
0800     DEY         ;255 to 0(1page)
0810     STA (PMBASE),Y ;clear byte
0820     BNE CLEARPM ;loop
0830     INC PMBASE+1 ;next page
0840     LDY #255    ;reset loop
0850     DEX         ;page done,count down to next
0860     CPX #0      ;are we done?
0870     BNE CLEARPM
0880     LDA 106
0881     STA PMBASE+1 ;reset PMBASE
0890 ;
0900 ;
0910 ;
0920 CREATEPLAYER
0930     LDA PMBASE+1
0940     CLC 
0950     ADC #2      ;pmbase+512(2 pages)
0960     STA YLOC+1  ;high byte of YLOC
0970     LDA #90     ;initial y coordinate
0980     STA YLOC    ;low byte
0990     LDY #0      ;a counter
1000 INSERTPLAYER
1010     LDA PLAYER,Y ;get byte of player
1020     STA (YLOC),Y ;store byte
1030     INY 
1040     CPY #8      ;8bytes yet?
1050     BNE INSERTPLAYER
1060     LDA #120    ;get initial x
1070     STA HPOSP0  ;move to x
1080     STA XLOC    ;store it
1090     LDA #68     ;red player
1100     STA 704     ;
1110     LDA #3      ;enable player
1120     STA 53277
1130 ;
1140 ;
1150 ;
1160 MAIN
1170     JSR RDSTK   ;
1180     LDX #5      ; DELAY
1190     LDY #0
1195 ;
1196 ;
1197 ;
1200 DELAY
1210     DEY 
1220     BNE DELAY
1230     DEX 
1240     BNE DELAY
1250     JMP MAIN
1260 RDSTK
1270     LDA STICK0  ;READ STICK(0)
1280     AND #1
1290     BEQ UP
1300     LDA STICK0
1310     AND #2
1320     BEQ DOWN
1321 ;
1322 ;
1330 SIDE
1340     LDA STICK0
1350     AND #4
1360     BEQ LEFT
1370     LDA STICK0
1380     AND #8
1390     BEQ RIGHT
1400     RTS 
1410 ;
1420 ;
1440 UP
1450     LDY #1      ;MOVE 1BYTE
1460     DEC YLOC
1470 UP1
1480     LDA (YLOC),Y
1490     DEY 
1500     STA (YLOC),Y
1510     INY 
1520     INY 
1530     CPY #10
1540     BCC UP1
1550     BCS SIDE
1560 ;
1580 ;
1590 DOWN
1600     LDY #7      ;MOVE TOP BYTE FIRST
1610 DOWN1
1620     LDA (YLOC),Y
1630     INY 
1640     STA (YLOC),Y
1650     DEY 
1660     DEY 
1670     BPL DOWN1
1680     INY 
1690     LDA #0
1700     STA (YLOC),Y
1710     INC YLOC
1720     CLC 
1730     BCC SIDE
1740 ;
1760 ;
1770 LEFT
1780     LDA XLOC    ;MOVE LEFT
1790     CMP #39
1794     BEQ SKIPL
1795     DEC XLOC
1800     STA HPOSP0
1810 SKIPL RTS 
1820 ;
1840 ;
1850 RIGHT
1855     LDA XLOC
1856     CMP #208
1857     BEQ SKIPR
1860     INC XLOC    ;MOVE RIGHT
1870     LDA XLOC
1880     STA HPOSP0
1890 SKIPR RTS 
1900 WAITKEY LDX #$FF
1910     STX $02FC
1920 WAITKEYLOOP LDX $02FC
1930     CPX #$FF
1940     BNE QUIT
1950     JMP WAITKEYLOOP
1960 QUIT BRK 
