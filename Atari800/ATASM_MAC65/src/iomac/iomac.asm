1000     .TITLE "IOMAC.LIB -- FTe system I/O macros"
1010     .PAGE "   Support Macros"
1020       .IF .NOT .DEF IOCB
1030       .ERROR "You must include SYSEQU.M65 ahead of this!!"
1040       .ENDIF 
1050 ;
1060 ; These macros are called by the actual I/O macros
1070 ; to perform the rudimentary register load functions.
1080 ;
1090 ;
1100 ; MACRO:  @CH
1110 ;
1120 ; Loads IOCB number (parameter 1) into X register.
1130 ;
1140 ; If parameter value is 0 to 7, immediate channel number
1150 ;   is assumed.
1160 ;
1170 ; If parameter value is > 7 then a memory location
1180 ;   is assumed to contain the channel number.
1190 ;
1200     .MACRO @CH 
1210       .IF %1>7
1220       LDA %1
1230       ASL A
1240       ASL A
1250       ASL A
1260       ASL A
1270       TAX 
1280       .ELSE 
1290       LDX #%1*16
1300       .ENDIF 
1310     .ENDM 
1320 ;
1330 ;
1340 ; MACRO:  @CV
1350 ;
1360 ; Loads Constant or Value into accumultor (A-register)
1370 ;
1380 ; If value of parameter 1 is 0-255, @CV
1390 ; assumes it's an (immediate) constant.
1400 ;
1410 ; Otherwise the value is assumed to
1420 ; be a memory location (non-zero page).
1430 ;
1440 ;
1450 ;
1460     .MACRO @CV 
1470       .IF %1<256
1480       LDA #%1
1490       .ELSE 
1500       LDA %1
1510       .ENDIF 
1520     .ENDM 
1530 ;
1540 ;
1550 ;
1560 ;
1570 ; MACRO:  @FL
1580 ;
1590 ; @FL is used to establish a filespec (file name)
1600 ;
1610 ; If a literal string is passed, @FL will
1620 ; generate the string in line, jump
1630 ; around it, and place its address
1640 ; in the IOCB pointed to by the X-register.
1650 ;
1660 ; If a non-zero page label is passed
1670 ; the MACRO assumes it to be the label
1680 ; of a valid filespec and uses it instead.
1690 ;
1700 ;
1710 ;
1720     .MACRO @FL 
1730       .IF %1<256
1740       JMP *+%1+4
1750 @F    .BYTE %$1,0
1760       LDA # <@F
1770       STA ICBADR,X
1780       LDA # >@F
1790       STA ICBADR+1,X
1800       .ELSE 
1810       LDA # <%1
1820       STA ICBADR,X
1830       LDA # >%1
1840       STA ICBADR+1,X
1850       .ENDIF 
1860     .ENDM 
1870     .PAGE "   XIO macro"
1880 ;
1890 ; MACRO:  XIO
1900 ;
1910 ;  FORM:  XIO cmd,ch[,aux1,aux2][,filespec]
1920 ;
1930 ; ch is given as in the @CH macro
1940 ; cmd, aux1, aux2 are given as in the @CV macro
1950 ; filespec is given as in the @FL macro
1960 ;
1970 ; performs familiar XIO operations with/for OS/A+
1980 ;
1990 ; If aux1 is given, aux2 must also be given
2000 ; If aux1 and aux2 are omitted, they are set to zero
2010 ; If the filespec is omitted, "S:" is assumed
2020 ;
2030     .MACRO XIO 
2040       .IF %0<2 .OR %0>5
2050       .ERROR "XIO: wrong number of arguments"
2060       .ELSE 
2070        @CH  %2
2080        @CV  %1
2090       STA ICCOM,X ; COMMAND
2100         .IF %0>=4
2110          @CV  %3
2120         STA ICAUX1,X
2130          @CV  %4
2140         STA ICAUX2,X
2150         .ELSE 
2160         LDA #0
2170         STA ICAUX1,X
2180         STA ICAUX2,X
2190         .ENDIF 
2200         .IF %0=2 .OR %0=4
2210          @FL  "S:"
2220         .ELSE 
2230 @@IO    .=  %0
2240          @FL  %$(@@IO)
2250         .ENDIF 
2260       JSR CIO
2270       .ENDIF 
2280     .ENDM 
2290     .PAGE "   OPEN macro"
2300 ;
2310 ; MACRO:  OPEN
2320 ;
2330 ;  FORM:  OPEN ch,aux1,aux2,filespec
2340 ;
2350 ; ch is given as in the @CH macro
2360 ; aux1 and aux2 are given as in the @CV macro
2370 ; filespec is given as in the @FL macro
2380 ;
2390 ; will attempt to open the given file name on
2400 ; the given channel, using the open "modes"
2410 ; specified by aux1 and aux2
2420 ;
2430     .MACRO OPEN 
2440       .IF %0<>4
2450       .ERROR "OPEN: wrong number of arguments"
2460       .ELSE 
2470         .IF %4<256
2480          XIO  COPN,%1,%2,%3,%$4
2490         .ELSE 
2500          XIO  COPN,%1,%2,%3,%4
2510         .ENDIF 
2520       .ENDIF 
2530     .ENDM 
2540     .PAGE "   BGET and BPUT macros"
2550 ;
2560 ; MACROS: BGET and BPUT
2570 ;
2580 ;   FORM: BGET ch,buf,len
2590 ;         BPUT ch,buf,len
2600 ;
2610 ; ch is given as in the @CH macro
2620 ; len is ALWAYS assumed to be an immediate
2630 ;   and actual value...never a memory address
2640 ; buf must be the address of an appropriate
2650 ;   buffer in memory
2660 ;
2670 ; puts or gets length bytes to/from the
2680 ;   specified buffer, uses binary read/write
2690 ;
2700 ;
2710 ; first: a common macro
2720 ;
2730     .MACRO @GP 
2740      @CH  %1
2750     LDA #%4
2760     STA ICCOM,X
2770     LDA # <%2
2780     STA ICBADR,X
2790     LDA # >%2
2800     STA ICBADR+1,X
2810     LDA # <%3
2820     STA ICBLEN,X
2830     LDA # >%3
2840     STA ICBLEN+1,X
2850     JSR CIO
2860     .ENDM 
2870 ;
2880     .MACRO BGET 
2890       .IF %0<>3
2900       .ERROR "BGET: wrong number of parameters"
2910       .ELSE 
2920        @GP  %1,%2,%3,CGBINR
2930       .ENDIF 
2940     .ENDM 
2950 ;
2960     .MACRO BPUT 
2970       .IF %0<>3
2980       .ERROR "BPUT: wrong number of parameters"
2990       .ELSE 
3000        @GP  %1,%2,%3,CPBINR
3010       .ENDIF 
3020     .ENDM 
3030 ;
3040     .PAGE "   PRINT macro"
3050 ;
3060 ; MACRO:  PRINT
3070 ;
3080 ;  FORM:  PRINT ch[,buffer[,length]]
3090 ;
3100 ; ch is as given in @CH macro
3110 ; if no buffer, prints just a RETURN
3120 ; if no length given, 255 assumed
3130 ;
3140 ; used to print text.  To print text without RETURN,
3150 ; length must be given.  See OS/A+ manual
3160 ;
3170 ; EXCEPTION: second parameter may be a literal
3180 ;  string (e.g., PRINT 0,"test"), in which
3190 ;  case the length (if given) is ignored.
3200 ;
3210     .MACRO PRINT 
3220       .IF %0<1 .OR %0>3
3230       .ERROR "PRINT: wrong number of parameters"
3240       .ELSE 
3250         .IF %0>1
3260           .IF %2<128
3270           JMP *+4+%2
3280 @IO       .BYTE %$2,$9B
3290            @GP  %1,@IO,%2+1,CPTXTR
3300           .ELSE 
3310             .IF %0=2
3320              @GP  %1,%2,255,CPTXTR
3330             .ELSE 
3340              @GP  %1,%2,%3,CPTXTR
3350             .ENDIF 
3360           .ENDIF 
3370         .ELSE 
3380         JMP *+4
3390 @IO     .BYTE $9B
3400          @GP  %1,@IO,1,CPTXTR
3410         .ENDIF 
3420       .ENDIF 
3430     .ENDM 
3440 ;
3450     .PAGE "   INPUT macro"
3460 ;
3470 ; MACRO:  INPUT
3480 ;
3490 ;  FORM:  INPUT ch,buf,len
3500 ;
3510 ; ch is given as in the @CH macro
3520 ; buf MUST be a proper buffer address
3530 ; len may be omitted, in which case 255 is assumed
3540 ;
3550 ; gets a line of text input to the given
3560 ;   buffer, maximum of length bytes
3570 ;
3580     .MACRO INPUT 
3590       .IF %0<2 .OR %0>3
3600       .ERROR "INPUT: wrong number of parameters"
3610       .ELSE 
3620         .IF %0=2
3630          @GP  %1,%2,255,CGTXTR
3640         .ELSE 
3650          @GP  %1,%2,%3,CGTXTR
3660         .ENDIF 
3670       .ENDIF 
3680     .ENDM 
3690     .PAGE "   CLOSE macro"
3700 ;
3710 ; MACRO:  CLOSE
3720 ;
3730 ;  FORM:  CLOSE ch
3740 ;
3750 ; ch is given as in the @CH macro
3760 ;
3770 ; closes channel ch
3780 ;
3790     .MACRO CLOSE 
3800       .IF %0<>1
3810       .ERROR "CLOSE: wrong number of parameters"
3820       .ELSE 
3830        @CH  %1
3840       LDA #CCLOSE
3850       STA ICCOM,X
3860       JSR CIO
3870       .ENDIF 
3880     .ENDM 
3890 ;
3900 ;;;;;;;;;;; END OF IOMAC.LIB ;;;;;;;;;;;;
3910 ;
