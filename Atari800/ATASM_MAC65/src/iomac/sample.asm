1000     .TITLE "A SAMPLE PROGRAM USING IOMAC.LIB"
1010     .OPT NO LIST
1020     .INCLUDE sysequ.asm
1030     .INCLUDE iomac.asm
1040     .OPT LIST
1050     .PAGE "   [end of equates and libraries...begin code]"
;1060     .OPT NO MLIST
1070     *=  $7000   ; an arbitrary location
1080 ;
1090 SAMPLE
1100     JMP AROUND  ; skip buffers, etc.
1110 ;
1120 BUFFER *= *+256
1130 ;
1140 MESSAGE1 .BYTE +$80," This is a test of the sample program    Type your name here -> "
1150     .BYTE " "
1160 M1LENGTH = *-MESSAGE1
1170 MESSAGE2 .BYTE "Hi there, "
1180 M2LENGTH = *-MESSAGE2
1190 ;
1200 ; BEGIN ACTUAL CODE
1210 ;
1220 AROUND
1230      OPEN  3,8,0,"P:"
1240      BPUT  0,MESSAGE1,M1LENGTH
1250      INPUT  0,BUFFER
1260      PRINT  0
1270      BPUT  0,MESSAGE2,M2LENGTH
1280      PRINT  0,BUFFER
1290      PRINT  3,"Also, we send it to the printer..."
1300      BPUT  3,MESSAGE2,M2LENGTH
1310      PRINT  3,BUFFER
1320      PRINT  0,"That's all folks"
1250      INPUT  0,BUFFER
1330      CLOSE  3
1340     RTS 
1350     .OPT NO LIST
1360     .END 
