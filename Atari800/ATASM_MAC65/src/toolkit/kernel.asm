1000     .PAGE ".       Some pertinent remarks"
1001 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
1002 ;
1003 ; KERNEL.M65
1004 ;
1005 ; System support macros and subroutines
1006 ;
1007 ; This file MUST be .INCLUDEd before
1008 ;   any of the other libraries are use
1009 ;   in your program.
1010 ;
1011 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
1012 ;
1013 ; Notice how we include the macros ONLY on pass 1
1014 ;   of the assembly...thus saving
1015 ;   time during the second pass.
1016 ;
1017 ; For even greater savings, you may .INCLUDE
1018 ;   the separated forms of this file (KERNEL.MAC
1019 ;   and KERNCODE.M65) in your own code
1020 ;   following the example of COPY1.M65
1021 ;
1022       .IF .NOT .DEF @@PASS
1023 @@PASS =  1     ; this is only equated (defined)
1024       ;         on pass 1, so all the following
1025       ;         macros are only read on pass 1
1026 ;
1027       .PAGE ".       KERNEL support macros"
1028 ;
1029 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
1030 ;
1031 ; First: a set of support macros used
1032 ;   internally by other macros and/or
1033 ;   system support subroutines.
1034 ;
1035 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
1036 ;
1037 ; PULLY, PULLX, PUSHX, PUSHY, PHR, PLR --
1038 ;   simply save and restore registers
1039 ;
1040 ; Note that PHR and PLR are controlled by the
1041 ;   switch @@PUSHREGS!
1042 ;
1043 @@PUSHREGS .= 1 ; by default, save regs
1044 ;
1045 ;
1046       .MACRO PULLY 
1047       PLA 
1048       TAY 
1049       .ENDM 
1050       .MACRO PULLX 
1051       PLA 
1052       TAX 
1053       .ENDM 
1054       .MACRO PUSHX 
1055       TXA 
1056       PHA 
1057       .ENDM 
1058       .MACRO PUSHY 
1059       TYA 
1060       PHA 
1061       .ENDM 
1062       .MACRO PLR 
1063         .IF @@PUSHREGS
1064          PULLY  
1065          PULLX  
1066         .ENDIF 
1067       .ENDM 
1068       .MACRO PHR 
1069         .IF @@PUSHREGS
1070          PUSHX  
1071          PUSHY  
1072         .ENDIF 
1073       .ENDM 
1074 ;
1075 ; BLT and BGT -- only work on certain ranges of args
1076 ;
;1077       .MACRO BLT 
;1078       BCC %1
;1079       .ENDM 
1080       .MACRO BGT 
1081       BCC @GT
1082       BNE %1
1083 @GT
1084       .ENDM 
1085 ;
1086 ; PLDA -- load an argument which is either
1087 ;    immediate (if < 256) or an address
1088 ;
1089       .MACRO PLDA 
1090         .IF [%1]>256
1091         LDA %1
1092         .ELSE 
1093         LDA #%1
1094         .ENDIF 
1095       .ENDM 
1096 ;
1097 ; DCMP, DEQCMP -- used by IF macros
1098 ;
1099       .MACRO DCMP 
1100        DPOKE  QQCMP,%1
1101        DPOKE  QQCMP+2,%2
1102       SEC 
1103       LDA QQCMP
1104       SBC QQCMP+2
1105       LDA QQCMP+1
1106       SBC QQCMP+3
1107       .ENDM 
1108       .MACRO DEQCMP 
1109        DPOKE  QQCMP,%1
1110        DPOKE  QQCMP+2,%2
1111       LDA QQCMP
1112       CMP QQCMP+2
1113       PHP 
1114       LDA QQCMP+1
1115       CMP QQCMP+3
1116       PHP 
1117       PLA 
1118       STA QQCFLG
1119       PLA 
1120       AND QQCFLG
1121       PHA 
1122       PLP 
1123       .ENDM 
1124 ;
1125 ; SGET -- get a string argument which is either
1126 ;         literal (in quotes) or an address
1127 ;
1128       .MACRO SGET
1129         .IF %1<256
1130         JMP *+%1+4
1131 @STR    ; 
			.BYTE %$1
			.BYTE 0
1132         LDA #<@STR
1133         STA $0344,X
1134         LDA #>@STR
1135         STA $0345,X
1136         LDA #0
1137         STA $0349,X
1138         LDA #%1
1139         STA $0348,X
1140         .ELSE
1141         LDA #<%1
1142         STA $0344,X
1143         LDA #>%1
1144         STA $0345,X
1145           .IF %0>1
1146            DPOKE  QQCMP,%2
1147           LDA QQCMP
1148           STA $0348,X
1149           LDA QQCMP+1
1150           STA $0349,X
1151           .ELSE
1152           LDA #0
1153           STA $0349,X
1154           LDA #255
1155           STA $0348,X
1156           .ENDIF
1157         .ENDIF
1158       .ENDM
1159 ;
1160 ; T16 -- simply multiply A-reg by 16
1161 ;
1162       .MACRO T16 
1163       ASL A
1164       ASL A
1165       ASL A
1166       ASL A
1167       .ENDM 
1168 ;
1169 ; ERRCHK -- used by all I/O to implement TRAP
1170 ;
1171       .MACRO ERRCHK 
1172       CPY #0
1173       BPL ERRK
1174       JMP (QQTRAP)
1175 ERRK
1176       .ENDM 
1177 ;
1178 ; CHAN -- get a channel number
1179 ;
1180       .MACRO CHAN 
1181         .IF %1>255
1182         LDA %1
1183          T16  
1184         TAX 
1185         .ELSE 
1186         LDX #%1*16
1187         .ENDIF 
1188       .ENDM 
1189 ;
1190 ; BPGET -- support for BPUT and BGET
1191 ;
1192       .MACRO BPGET 
1193        CHAN  %1
1194       LDA # >%2
1195       STA $0345,X
1196       LDA # <%2
1197       STA $0344,X
1198       LDA %3+1
1199       STA $0349,X
1200       LDA %3
1201       STA $0348,X
1202       LDA #%4
1203       STA $0342,X
1204       JSR $E456
1205        ERRCHK  
1206       .ENDM 
2000       .PAGE ".       GRAPHICS macros"
2001 ;
2002 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
2003 ;
2004 ; GRAPHICS support macros from KERNEL.M65
2005 ;
2006 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
2007 ;
2008 ;
2009 ; GR -- same as BASIC GRAPHICS command
2010 ;
2011       .MACRO GR 
2012        PHR  
2013        PLDA  %1
2014       JSR QQGR
2015        PLR  
2016       .ENDM 
2017 ;
2018 ; POS -- set X/Y position
2019 ;
2020       .MACRO POS 
2021        DPOKE  85,%1
2022        POKE  84,%2
2023       .ENDM 
2024 ;
2025 ; COLOR -- choose a COLOR for a later PLOT, etc.
2026 ;
2027       .MACRO COLOR 
2028        POKE  QQCOLR,%1
2029       .ENDM 
2030 ;
2031 ; PLOT -- plot a point
2032 ;
2033       .MACRO PLOT 
2034        POS  %1,%2
2035        PUT  6,QQCOLR
2036       .ENDM 
2037 ;
2038 ; SETCOLOR -- same as BASIC
2039 ;
2040       .MACRO SETCOLOR 
2041        PUSHX  
2042        PLDA  %1
2043       TAX 
2044        PLDA  %2
2045        T16  
2046       STA 212
2047        PLDA  %3
2048       CLC 
2049       ADC 212
2050       STA 708,X
2051        PULLX  
2052       .ENDM 
2053 ;
2054 ; LOCATE -- what color is a given pixel
2055 ;
2056       .MACRO LOCATE 
2057        POS  %1,%2
2058        GET  6,%3
2059       .ENDM 
2060 ;
2061 ; TXTPOS -- position cursor in text window
2062 ;
2063       .MACRO TXTPOS 
2064        DPOKE  $0291,%1
2065        POKE  $0290,%2
2066       .ENDM 
2067 ;
2068 ; DRAWTO -- draw a line
2069 ;
2070       .MACRO DRAWTO 
2071        POKE  $02FB,QQCOLR
2076        POS  %1,%2
2077        PHR  
2078       JSR QQDRAW
2079        PLR  
2080       .ENDM 
2081 ;
2082 ; FILL -- fill an area (uses OS)
2083 ;
2084       .MACRO FILL 
2085        PHR  
2086        PLDA  %1
2087       JSR QQFILL
2088        PLR  
2089       .ENDM 
3000       .PAGE ".       Integer MATH Macros"
3001 ;
3002 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
3003 ;
3004 ; The math macros which are part of KERNEL.M65
3005 ;
3006 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
3007 ;
3008 ;
3009 ; CALC -- begin a CALCulation by loading
3010 ;         first number into pseudo-register
3011 ;
3012       .MACRO CALC 
3013        DPOKE  212,%1
3014       .ENDM 
3015 ;
3016 ; STORE -- store results of a math calculation
3017 ;
3018       .MACRO STORE 
3019       LDA 212
3020       STA %1
3021       LDA 212+1
3022       STA %1+1
3023       .ENDM 
3024 ;
3025 ; PLUS -- add a value from memory to register
3026 ;
3027       .MACRO PLUS 
3028         .IF [%1]<256
3029         CLC 
3030         LDA #%1
3031         ADC 212
3032         STA 212
3033         BCC @K
3034         INC 212+1
3035 @K
3036         .ELSE 
3037         CLC 
3038         LDA %1
3039         ADC 212
3040         STA 212
3041         LDA %1+1
3042         ADC 212+1
3043         STA 212+1
3044         .ENDIF 
3045       .ENDM 
3046 ;
3047 ; MINUS -- subtract a value from pseudo-register
3048 ;
3049       .MACRO MINUS 
3050         .IF [%1]<256
3051         SEC 
3052         LDA 212
3053         SBC #%1
3054         STA 212
3055         LDA 212+1
3056         SBC #0
3057         STA 212+1
3058         .ELSE 
3059         SEC 
3060         LDA 212
3061         SBC %1
3062         STA 212
3063         LDA 212+1
3064         SBC %1+1
3065         STA 212+1
3066         .ENDIF 
3067       .ENDM 
3068 ;
3069 ; MUL -- multiply pseudo register by a value
3070 ;
3071       .MACRO MUL 
3072        PUSHY  
3073        PLDA  %1
3074       STA 212+1
3075       JSR QQRMUL
3076        PULLY  
3077       .ENDM 
3078 ;
3079 ; DIV -- divide pseudo register by a value
3080 ;
3081       .MACRO DIV 
3082        PUSHY  
3083        PLDA  %1
3084       STA 224+1
3085       JSR QQRDIV
3086        PULLY  
3087       .ENDM 
3088 ;
3089 ; RND -- choose a random number
3090 ;
3091       .MACRO RND 
3092        POKE  QQCMP,%1
3093 @K
3094       LDA $D20A
3095       CMP QQCMP
3096        BGT  @K
3097       BEQ @K
3098       .ENDM 
4000       .PAGE ".       I/O Macros"
4001 ;
4002 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
4003 ;
4004 ; the I/O macros of KERNEL.M65
4005 ;
4006 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
4007 ;
4008 ; OPEN -- open a file to a channel
4009 ;
4010       .MACRO OPEN 
4011        PHR  
4012        CHAN  %1
4013        PLDA  %2
4014       STA $034A,X
4015        PLDA  %3
4016       STA $034B,X
4017       LDA #3
4018       STA $0342,X
4019        SGET  %4
4020       JSR $E456
4021        ERRCHK  
4022        PLR  
4023       .ENDM 
4024 ;
4025 ; CLOSE -- close a channel (no error check!)
4026 ;
4027       .MACRO CLOSE 
4028        PHR  
4029        CHAN  %1
4030       LDA #12
4031       STA $0342,X
4032       JSR $E456
4033        PLR  
4034       .ENDM 
4035 ;
4036 ; GET -- get a single byte from a channel
4037 ;
4038       .MACRO GET 
4039        PHR  
4040        PLDA  %1
4041       JSR QQGET
4042       STA %2
4043        PLR  
4044       .ENDM 
4045 ;
4046 ; PUT -- put a character to a channel
4047 ;
4048       .MACRO PUT 
4049        POKE  QQPASS+2,%2
4050        PHR  
4051        PLDA  %1
4052       JSR QQPUT
4053        PLR  
4054       .ENDM 
4055 ;
4056 ; BGET -- get a block from a channel
4057 ;
4058       .MACRO BGET 
4059        PHR  
4060        BPGET  %1,%2,%3,7
4061        PLR  
4062       .ENDM 
4063 ;
4064 ; BPUT -- put a block to a channel
4065 ;
4066       .MACRO BPUT 
4067        PHR  
4068        BPGET  %1,%2,%3,11
4069        PLR  
4070       .ENDM 
4071 ;
4072 ; PRINT -- print a string
4073 ;
4074 ; first, the macro which does the work
4075 ;
4076       .MACRO @@PRINT 
4077        PHR  
4078        CHAN  %1
4079         .IF %0>2
4080          SGET  %2,%3
4081         .ELSE 
4082          SGET  %2
4083         .ENDIF 
4084       JSR QQPREC
4085        PLR  
4086       .ENDM 
4087 ;
4088 ; now, the macro the user sees
4089 ;
4090       .MACRO PRINT 
4091         .IF %0=1
4092          @@PRINT  0,%1
4093         .ELSE 
4094           .IF %0=2
4095            @@PRINT  %1,%2
4096           .ELSE 
4097            @@PRINT  %1,%2,%3
4098           .ENDIF
4099         .ENDIF
4100       .ENDM
4101 ;
4102 ;
4072 ; PRINTSTR -- print a string LITERAL (in quotes)
4073 ;
4074 ; first, the macro which does the work
4075 ;
4076     .MACRO @@PRINTSTR 
4077      PHR  
4078      CHAN %1
4079       .IF %0>2
4080        SGET %$2,%3
4081       .ELSE
4082        SGET %$2
4083       .ENDIF
4084     JSR QQPREC
4085      PLR
4086     .ENDM
4087 ;
4088 ; now, the macro the user sees
4089 ;
4090     .MACRO PRINTSTR 
4091       .IF %0=1
4092        @@PRINTSTR 0,%$1
4093       .ELSE 
4094         .IF %0=2
4095          @@PRINTSTR %1,%$2
4096         .ELSE 
4097          @@PRINTSTR %1,%$2,%3
4098         .ENDIF 
4099       .ENDIF 
4100     .ENDM 
4101 ;
4102 ;
4103 ; CR -- output a CR to a channel
4104 ;       If no channel given, output to channel 0
4105 ;
4106       .MACRO CR 
4107         .IF %0>0
4108          PUT  %1,155
4109         .ELSE 
4110          PUT  0,155
4111         .ENDIF 
4112       .ENDM 
4113 ;
4114 ; CLS -- simply output a clear screen
4115 ;        character to channel 0
4116 ;
4117       .MACRO CLS 
4118        PUT  0,125
4119       .ENDM 
4120 ;
4121 ; PRINUM -- print an integer number to a channel
4122 ;           within a specified width field
4123 ;
4124       .MACRO PRINUM 
4125        PHR  
4126        CALC  %2
4127        PLDA  %1
4128       STA QQPASS
4129        PLDA  %3
4130       STA QQPASS+1
4131       JSR QQPIN
4132        PLR  
4133       .ENDM 
4134 ;
4135 ; INPUT -- input a string from a channel
4136 ;
4137       .MACRO INPUT 
4138        PHR  
4139        CHAN  %1
4140       LDA # <%2
4141       STA $0344,X
4142       LDA # >%2
4143       STA $0345,X
4144         .IF %0>2
4145          DPOKE  QQCMP,%3
4146         LDA QQCMP
4147         STA $0348,X
4148         LDA QQCMP+1
4149         STA $0349,X
4150         .ELSE 
4151         LDA #0
4152         STA $0349,X
4153         LDA #255
4154         STA $0348,X
4155         .ENDIF 
4156       JSR QQIN
4157        PLR  
4158       .ENDM 
4159 ;
4160 ; ININUM -- input an integer number
4161 ;
4162       .MACRO ININUM 
4163        PHR  
4164        PLDA  %1
4165       JSR QQININ
4166       LDA 212
4167       STA %2
4168       LDA 212+1
4169       STA %2+1
4170        PLR  
4171       .ENDM 
4172 ;
4173 ; BLOAD -- load a binary file to memory
4174 ;
4175       .MACRO BLOAD 
4176        PHR  
4177        CLOSE  5
4178        OPEN  5,4,0,%1
4179       JSR QQLOAD
4180        PLR  
4181       .ENDM 
5000       .PAGE ".       CONTROL macros"
5001 ;
5002 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
5003 ;
5004 ; The control macros of KERNEL.M65
5005 ;
5006 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
5007 ;
5008 ;
5009 ; GOSUB -- same as JSR except saves X&Y regs
5010 ;
5011       .MACRO GOSUB 
5012        PUSHX  
5013        PUSHY  
5014       JSR %1
5015        PULLY  
5016        PULLX  
5017       .ENDM 
5018 ;
5019 ; IFEQ, IFNE, IFGT, IFLT --
5020 ;     compare two integer values and branch
5021 ;     if condition is met
5022 ;
5023       .MACRO IFEQ 
5024        DEQCMP  %1,%2
5025       BNE @THEN
5026       JMP %3
5027 @THEN
5028       .ENDM 
5029       .MACRO IFNE 
5030        DEQCMP  %1,%2
5031       BEQ @THEN
5032       JMP %3
5033 @THEN
5034       .ENDM 
5035       .MACRO IFLT 
5036        DCMP  %1,%2
5037       BPL @THEN
5038       JMP %3
5039 @THEN
5040       .ENDM 
5041       .MACRO IFGT 
5042        DCMP  %2,%1
5043       BPL @THEN
5044       JMP %3
5045 @THEN
5046       .ENDM 
5047 ;
5048 ; DOI, LOOPI -- loop control using the 'I' variable
5049 ;
5050       .MACRO DOI 
5051        DPOKE  QQLOOP,%1
5052        DPOKE  QQLOOP+6,%2
5053       LDA # <[?K-1]
5054       STA QQLOOP+12
5055       LDA # >[?K-1]
5056       STA QQLOOP+13
5057 @K
5058       .ENDM 
5059       .MACRO LOOPI 
5060        DINC  QQLOOP
5061        IFGT  QQLOOP,QQLOOP+6,@LI
5062       LDA QQLOOP+13
5063       PHA 
5064       LDA QQLOOP+12
5065       PHA 
5066       RTS 
5067 @LI
5068       .ENDM 
5069 ;
5070 ; DOJ, LOOPJ -- loop control using the 'J' variable
5071 ;
5072       .MACRO DOJ 
5073        DPOKE  QQLOOP+2,%1
5074        DPOKE  QQLOOP+8,%2
5075       LDA # <[?K-1]
5076       STA QQLOOP+14
5077       LDA # >[?K-1]
5078       STA QQLOOP+15
5079 @K
5080       .ENDM 
5081       .MACRO LOOPJ 
5082        DINC  QQLOOP+2
5083        IFGT  QQLOOP+2,QQLOOP+8,@LJ
5084       LDA QQLOOP+15
5085       PHA 
5086       LDA QQLOOP+14
5087       PHA 
5088       RTS 
5089 @LJ
5090       .ENDM 
5091 ;
5092 ; DOK, LOOPK -- loop control using the 'K' variable
5093 ;
5094       .MACRO DOK 
5095        DPOKE  QQLOOP+4,%1
5096        DPOKE  QQLOOP+10,%2
5097       LDA # <[?K-1]
5098       STA QQLOOP+16
5099       LDA # >[?K-1]
5100       STA QQLOOP+17
5101 @K
5102       .ENDM 
5103       .MACRO LOOPK 
5104        DINC  QQLOOP+4
5105        IFGT  QQLOOP+4,QQLOOP+10,@LK
5106       LDA QQLOOP+17
5107       PHA 
5108       LDA QQLOOP+16
5109       PHA 
5110       RTS 
5111 @LK
5112       .ENDM 
5113       .MACRO TRAP 
5114        VPOKE  QQTRAP,%1
5115       .ENDM 
6000       .PAGE ".       MISCellaneous macros"
6001 ;
6002 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
6003 ;
6004 ; Miscellaneous macros from KERNEL.M65
6005 ;
6006 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
6007 ;
6008 ; DINC -- increment a word (2 bytes)
6009 ;
6010       .MACRO DINC 
6011       INC %1
6012       BNE @K
6013       INC %1+1
6014 @K
6015       .ENDM 
6016 ;
6017 ; VPOKE -- poke an immediate value into a word
6018 ;
6019       .MACRO VPOKE 
6020       LDA # <%2
6021       STA %1
6022       LDA # >%2
6023       STA %1+1
6024       .ENDM 
6025 ;
6026 ; DPOKE -- could be better called DMOVE
6027 ;
6028       .MACRO DPOKE 
6029         .IF [%2]>256
6030         LDA %2
6031         STA %1
6032         LDA %2+1
6033         STA %1+1
6034         .ELSE 
6035         LDA #%2
6036         STA %1
6037         LDA #0
6038         STA %1+1
6039         .ENDIF 
6040       .ENDM 
6041 ;
6042 ; POKE -- a single byte poke
6043 ;
6044       .MACRO POKE 
6045        PLDA  %2
6046       STA %1
6047       .ENDM 
6048 ;
6049 ; WAIT -- wait a certain number of jiffies
6050 ;
6051       .MACRO WAIT 
6052        POKE  544,%1
6053 @K
6054       LDA 544
6055       BNE @K
6056       .ENDM 
6057 ;
6058 ; STOP -- stop until START is pushed
6059 ;
6060       .MACRO STOP 
6061       JSR QQSTOP
6062       .ENDM 
6063 ;
6064 ; SOUND -- just like BASIC's sound
6065 ;
6066       .MACRO SOUND 
6067        POKE  $D208,0
6068       LDA #3
6069       STA $D20F
6070       STA $0232
6071         .IF %1<4
6072         LDX #%1+%1
6073         .ELSE 
6074          PLDA  %1
6075         ASL A
6076         TAX 
6077         .ENDIF 
6078         .IF %3<16 .AND %4<16
6079         LDA #%3*16+%4
6080         .ELSE 
6081          PLDA  %3
6082          T16  
6083         STA 212
6084          PLDA  %4
6085         AND #$0F
6086         ORA 212
6087         .ENDIF 
6088       STA $D201,X
6089        PLDA  %2
6090       STA $D200,X
6091       .ENDM 
6092 ;
6093 ; BMOVE -- move a block of memory
6094 ;
6095       .MACRO BMOVE 
6096        VPOKE  QQPASS+2,%3
6097        VPOKE  203,%1
6098        VPOKE  214,%2
6099       JSR QQBMOV
6100       .ENDM 
6101 ;
6102 ; PGMOVE -- special move of a single page (256 bytes)
6103 ;
6104       .MACRO PGMOVE 
6105        POKE  204,%1
6106        PLDA  %2
6107       JSR QQPGMV
6108       .ENDM 
6109 ;
6110 ; BCLR -- clear (set to zero) a block of memory
6111 ;
6112       .MACRO BCLR 
6113        VPOKE  203,%1
6114        VPOKE  QQPASS+2,%2
6115       JSR QQBCLR
6116       .ENDM 
6117 ;
6118 ; PGCLR -- fast clear of a page of memory
6119 ;
6120 ;
6121       .MACRO PGCLR 
6122        PUSHY  
6123        POKE  204,%1
6124        POKE  203,0
6125       TAY 
6126 ?L1
6127       STA (203),Y
6128       INY 
6129       BNE ?L1
6130        PULLY  
6131       .ENDM 
7000 ;
7010 ; End of all macros -- so end of the .IF from
7020 ;   line 1022 at the beginning of this listing
7030 ;
7040       .ENDIF 
8000     .PAGE ".       KERNEL SUBROUTINES"
8001 ;
8002 ;************************************
8003 ;
8004 ; KERNEL CODE -- RAM and coded subroutines
8005 ;                to support kernel macros
8006 ;
8007 ;************************************
8008 ;
8009 ; first, RAM usage
8010 ;
8011 ; note that only QQTRAP needs to assume an initial value
8012 ;   and even that is not necessary if the user always
8013 ;   codes a TRAP macro.
8014 ;
8015 QQLEN .BYTE 0
8016 QQCOLR .BYTE 0
8017 QQENUM .WORD 0
8018 QQCFLG .WORD 0
8019 QQTRAP .WORD QQERR
8020 QQPASS .WORD 0,0
8021 QQCMP .WORD 0,0
8022 QQPUTB .BYTE 0
8023 QQLOOP *= *+18
8024 I   =   QQLOOP
8025 J   =   QQLOOP+2
8026 K   =   QQLOOP+4
8027 ;
8028 ;************************************
8029 ; Actual ToolKit Subroutines
8030 ;************************************
8031 ;
8032 ; Multiply subroutine
8033 ;
8034 QQRMUL
8035     LDA #0
8036     STA 224
8037     STA 224+1
8038     LDY #8
8039 ?L1
8040     ASL A
8041     ROL 224+1
8042     ASL 212+1
8043     BCC ?L2
8044     CLC 
8045     ADC 212
8046     BCC ?L2
8047     INC 224+1
8048 ?L2
8049     DEY 
8050     BNE ?L1
8051     STA 212
8052     LDA 224+1
8053     STA 212+1
8054     RTS 
8055 ;
8056 ; Divide subroutine
8057 ;
8058 QQRDIV
8059     LDY #8
8060     LDA 212
8061     STA 224+2
8062     LDA 212+1
8063 ?LA1
8064     ASL 224+2
8065     ROL A
8066     CMP 224+1
8067     BCC ?LA2
8068     SBC 224+1
8069     INC 224+2
8070 ?LA2
8071     DEY 
8072     BNE ?LA1
8073     STA 224
8074     LDA #0
8075     STA 212+1
8076     LDA 224+2
8077     STA 212
8078     RTS 
8079 ;
8080 ; Get a single byte
8081 ;
8082 QQGET
8083      T16  
8084     TAX 
8085     LDA #7
8086     STA $0342,X
8087     LDA #0
8088     STA $0348,X
8089     STA $0349,X
8090     JSR $E456
8091      ERRCHK  
8092     RTS 
8093 ;
8094 ; Put a single byte
8095 ;
8096 QQPUT
8097      T16  
8098     TAX 
8099     LDA #11
8100     STA $0342,X
8101     LDA #0
8102     STA $0348,X
8103     STA $0349,X
8104     LDA QQPASS+2
8105     JSR $E456
8106      ERRCHK  
8107     RTS 
8108 ; calculate the length of a string
8109 ;
8110 ; print subroutine
8111 ;
8112 QQPREC
8113     LDA #9
8114     STA $0342,X
8115     JSR $E456
8116      ERRCHK  
8117     RTS 
8118 ;
8119 ; print an integer number (PRINUM macro)
8120 ;
8121 QQPIN
8122     JSR $D9AA   ;I>FP
8123     JSR $D8E6   ; FP>ASCII
8124     LDA 243
8125     STA 203
8126     LDA 243+1
8127     STA 204
8128     JSR QQSLEN
8129     CPY QQPASS+1
8130     BEQ ?NOERR
8131     BCC ?NOERR
8132     LDY #175
8133     JMP (QQTRAP)
8134 ?NOERR
8135     SEC 
8136     LDA QQPASS+1
8137     SBC QQLEN
8138     STA QQPASS+1
8139     BEQ ?LD3
8140 ?LD1
8141     LDA #32
8142     STA QQPUTB
8143      PUT  QQPASS,QQPUTB
8144     DEC QQPASS+1
8145     BNE ?LD1
8146 ?LD3
8147     LDY #0
8148 ?LD2
8149     LDA (203),Y
8150     AND #127
8151     STA QQPUTB
8152      PUSHY  
8153      PUT  QQPASS,QQPUTB
8154      PULLY  
8155     INY 
8156     CPY QQLEN
8157     BNE ?LD2
8158     RTS 
8159 ;
8160 ; input subroutine
8161 ;
8162 QQIN
8163     LDA #5
8164     STA $0342,X
8165     JSR $E456
8166      ERRCHK  
8167     RTS 
8168 ;
8169 ; ININUM suppor
8170 ;
8171 QQININ
8172     STA QQPASS+2
8173      INPUT  QQPASS+2,$0580
8174      VPOKE  243,$0580
8175      POKE  242,0
8176     JSR $D800
8177     BCC ?NO2ERR
8178     JMP (QQTRAP)
8179 ?NO2ERR
8180     JSR $D9D2
8181     BCC ?NERR2
8182     JMP (QQTRAP)
8183 ?NERR2
8184     RTS 
8185 ;
8186 ; LOAD a file (LOAD macro)
8187 ;
8188 QQLOAD
8189      GET  5,QQPASS+2
8190      GET  5,QQPASS+2+1
8191     LDA QQPASS+2+1
8192     AND QQPASS+2
8193     CMP #255
8194     BEQ ?LE7
8195     LDY #176
8196     JMP (QQTRAP)
8197 ?LE7
8198      GET  5,QQPASS+2
8199      GET  5,QQPASS+3
8200      GET  5,QQPASS
8201      GET  5,QQPASS+1
8202      CALC  QQPASS
8203      MINUS  QQPASS+2
8204      PLUS  1
8205     LDX #$50
8206     LDA 212
8207     STA $0348,X
8208     LDA 212+1
8209     STA $0349,X
8210     LDA QQPASS+2
8211     STA $0344,X
8212     LDA QQPASS+3
8213     STA $0345,X
8214     LDA #7
8215     STA $0342,X
8216     JSR $E456
8217      ERRCHK  
8218     CPY #3      ; no error...about to get EOF?
8219     BEQ ?LE8    ; yes
8220     JMP ?LE7    ; no...get another segment
8221 ?LE8  CLOSE  5
8222     RTS 
8223 ;
8224 ; execute GR subroutine
8225 ;
8226 QQGR
8227     STA QQPASS+2
8228      CLOSE  6
8229     LDA QQPASS+2
8230     AND #$F0
8231     EOR #$10
8232     ORA #$0C
8233     STA QQPASS+2+1
8234      OPEN  6,QQPASS+2+1,QQPASS+2,"S:"
8235     RTS 
8236 ;
8237 ; execute DRAWTO subroutine
8238 ;
8239 QQDRAW
8240     LDX #$60
8241     LDA #$11
8242     STA $0342,X
8243     JSR $E456
8244      ERRCHK  
8245     RTS 
8246 ;
8247 ; execute FILL subroutine
8248 ;
8249 QQFILL
8250     STA $02FD
8251     LDX #$60
8252     LDA #$12
8253     STA $0342,X
8254     JSR $E456
8255      ERRCHK  
8256     RTS 
8257 ;
8258 ; Support for TRAP and error messages
8259 ;
8260 QQERMSG .BYTE "Fatal Error #"
8261 QQERMLEN .WORD *-QQERMSG
8262 QQERR
8263     STY QQENUM
8264      POKE  QQENUM+1,0
8265      CR  
8266      CR  
8267      BPUT  0,QQERMSG,QQERMLEN
8268      PRINUM  0,QQENUM,3
8269      CR  
8270      CR  
8271      PRINTSTR "Push START key to return to DOS"
8272      STOP  
8273     JMP ($0A)
8274 ;
8275 ; support for STOP macro
8276 ;
8277 QQSTOP
8278     PHP 
8279     PHA 
8280      PUSHX  
8281      PUSHY  
8282      SOUND  0,32,10,14
8283      WAIT  60
8284      SOUND  0,0,0,0
8285 ?LF6
8286     LDA $D01F
8287     CMP #6
8288     BNE ?LF6
8289      PULLY  
8290      PULLX  
8291     PLA 
8292     PLP 
8293     RTS 
8294 ;
8295 ; support for BMOVE macro
8296 ;
8297 QQBMOV
8298     LDY #0
8299     STY QQPASS
8300     STY QQPASS+1
8301 ?LG1
8302     LDA (203),Y
8303     STA (214),Y
8304      DINC  203
8305      DINC  214
8306      DINC  QQPASS
8307      DEQCMP  QQPASS,QQPASS+2
8308     BNE ?LG1
8309     RTS 
8310 ;
8311 ; support for PGMOVE macro
8312 ;
8313 QQPGMV
8314     STA 215
8315     TYA 
8316     PHA 
8317     LDY #0
8318     STY 203
8319     STY 214
8320 ?LH1
8321     LDA (203),Y
8322     STA (214),Y
8323     INY 
8324     BNE ?LH1
8325     PLA 
8326     TAY 
8327     RTS 
8328 ;
8329 ; support for BCLR   macro
8330 ;
8331 QQBCLR
8332     TYA 
8333     PHA 
8334     LDY #0
8335     STY QQPASS
8336     STY QQPASS+1
8337 ?LI1
8338     LDA #0
8339     STA (203),Y
8340      DINC  203
8341      DINC  QQPASS
8342      DEQCMP  QQPASS,QQPASS+2
8343     BNE ?LI1
8344     PLA 
8345     TAY 
8346     RTS 
8347 ;
8348 ; QQSLEN -- find length of a string
8349 ;   which is terminated by a char with
8350 ;   MSBit on.
8351 ;
8352 QQSLEN
8353     LDY #255
8354 ?LB1 INY 
8355     LDA (203),Y
8356     BPL ?LB1
8357     INY 
8358     STY QQLEN
8359     RTS 
