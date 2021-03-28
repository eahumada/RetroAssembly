1000     .PAGE "OSS SYSTEM EQUATES FOR ATARI"
1010 ;
1020 ;  FILE = #DN:SYSEQU.M65
1030 ;
1040 ;
1050 ; I/O CONTROL BLOCK EQUATES
1060 ;
1065 SAVEPC = *      ; SAVE CURRENT ORG
1067 ;
1070     *=  $0340   ; START OF SYSTEM IOCBS
1075 IOCB
1080 ;
1090 ICHID *= *+1    ; DEVICE HANDLER IS (SET BY OS)
1100 ICDNO *= *+1    ; DEVICE NUMBER (SET BY OS)
1110 ICCOM *= *+1    ; I/O COMMAND
1120 ICSTA *= *+1    ; I/O STATUS
1130 ICBADR *= *+2   ; BUFFER ADDRESS
1140 ICPUT *= *+2    ; DH PUT ROUTINE (ADR-1)
1150 ICBLEN *= *+2   ; BUFFER LENGTH
1160 ICAUX1 *= *+1   ; AUX 1
1170 ICAUX2 *= *+1   ; AUX 2
1180 ICAUX3 *= *+1   ; AUX 3
1190 ICAUX4 *= *+1   ; AUX 4
1200 ICAUX5 *= *+1   ; AUX 5
1210 ICAUX6 *= *+1   ; AUX 6
1220 ;
1230 IOCBLEN = *-IOCB ; LENGTH OF ONE IOCB
1240 ;
1250 ; IOCB COMMAND VALUE EQUATES
1260 ;
1270 COPN =  3       ; OPEN
1280 CGBINR = 7      ; GET BINARY RECORD
1290 CGTXTR = 5      ; GET TEXT RECORD
1300 CPBINR = 11     ; PUT BINARY RECORD
1310 CPTXTR = 9      ; PUT TEXT RECORD
1320 CCLOSE = 12     ; CLOSE 
1330 CSTAT = 13      ; GET STATUS
1340 ; 
1350 ; DEVICE DEPENDENT COMMAND EQUATES FOR FILE MANAGER
1360 ;
1370 CREN =  32      ; RENAME
1380 CERA =  33      ; ERASE
1390 CPRO =  35      ; PROTECT
1400 CUNP =  36      ; UNPROTECT
1410 CPOINT = 37     ; POINT
1420 CNOTE = 38      ; NOTE
1430 ;
1440 ; AUX1 VALUES REQUIRED FOR OPEN
1450 ;
1460 OPIN =  4       ; OPEN INPUT
1470 OPOUT = 8       ; OPEN OUTPUT
1480 OPUPD = 12      ; OPEN UPDATE
1490 OPAPND = 9      ; OPEN APPEND
1500 OPDIR = 6       ; OPEN DIRECTORY
1510 ;
1520     .PAGE 
1530 ;
1540 ;    EXECUTE FLAG DEFINES
1550 ;
1560 EXCYES = $80    ; EXECUTE IN PROGRESS
1570 EXCSCR = $40    ; ECHO EXCUTE INPUT TO SCREEN
1580 EXCNEW = $10    ; EXECUTE START UP MODE
1590 EXCSUP = $20    ; COLD START EXEC FLAG
1600 ;
1610 ; MISC ADDRESS EQUATES
1620 ;
1630 CPALOC = $0A    ; POINTER TO CP
1640 WARMST = $08    ; WARMSTART (0=COLD)
1650 MEMLO = $02E7   ; AVAILABLE MEM (LOW) PTR
1660 MEMTOP = $02E5  ; AVAILABLE MEM (HIGH) PTR
1670 APPMHI = $0E    ; UPPER LIMIT OF APPLICATION MEMORY
1680 INITADR = $02E2 ; ATARI LOAD/INIT ADR
1690 GOADR = $02E0   ; ATARI LOAD/GO ADR
1700 CARTLOC = $BFFA ; CARTRIDGE RUN LOCATION
1710 CIO =   $E456   ; CIO ENTRY ADR
1720 EOL =   $9B     ; END OF LINE CHAR
1730 ;
1740 ;  CP FUNCTION AND VALUE DISPLACEMENTS
1750 ;     (INDIRECT THROUGH CPALOC)
1760 ;           IE. (CPALOC),Y
1770 ;
1780 CPGNFN = 3      ; GET NEXT FILE NAME
1790 CPDFDV = $07    ; DEFAULT DRIVE (3 BYTES)
1800 CPBUFP = $0A    ; CMD BUFF NEXT CHAR POINTR (1 BYTE)
1810 CPEXFL = $0B    ; EXECUTE FLAG
1820 CPEXFN = $0C    ; EXECUTE FILE NAME (16 BYTES)
1830 CPEXNP = $1C    ; EXECUTE NOTE/POINT VALUES
1840 CPFNAM = $21    ; FILENAME BUFFER
1850 RUNLOC = $3D    ; CP LOAD/RUN ADR
1860 CPCMDB = $3F    ; COMMAND BUFFER (60 BYTES)
1870 CPCMDGO = $F3
1880 ;
1890     *=  SAVEPC  ; RESTORE PC
1900 ;