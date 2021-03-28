;PANTALLAS DISPLAY LIST
PRINCIPALDLI
	.BYTE $70,$70,$70,$70,$46
	.WORD TITULOPRINCIPAL
	.BYTE $70,$42
	.WORD TEXTOPRINCIPAL
	.BYTE $02,$02,$02,$02,$02,$02,$02,$02
	.BYTE $02,$02,$02,$02,$02,$02,$02,$02
	.BYTE $02,$02,$02,$02
	.BYTE $41
	.WORD PRINCIPALDLI 
PRINCIPAL
	LDA #<PRINCIPALDLI
	STA $230
	LDA #>PRINCIPALDLI
	STA $231
	RTS
TITULOPRINCIPAL
	.SBYTE +64,"ORGANIZADOR DE DISCO"
TEXTOPRINCIPAL
	;      "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
;COMIENZO EL DIBUJO
	.SBYTE "                ",$A0,$99,$A0,$A0,$19,$A0,"                  "
	.SBYTE "                ",$A0,$99,$A0,$A0,$19,$A0,"                  "
	.SBYTE "                ",$A0,$99,$A0,$A0,$19,$A0,"                  "
	.SBYTE "                ",$A0,$99,$A0,$A0,$19,$A0,"                  "
	.SBYTE "               ",$02,$A0,$99,$A0,$A0,$19,$A0,$16,"                 "
	.SBYTE "               ",$99,$A0,$99,$A0,$A0,$19,$A0,$19,"                 "
	.SBYTE "               ",$96,$82,$99,$A0,$A0,$19,$96,$82,"                 "
	.SBYTE "               ",$A0,$19,$99,$A0,$A0,$19,$99,$A0,"                 "
	.SBYTE "              ",$99,$A0,$16,$99,$A0,$A0,$19,$02,$A0,$19,"                "
	.SBYTE "             ",$09,$A0,$A0,$20,$99,$A0,$A0,$19,$20,$A0,$A0,$0F,"               "
	.SBYTE "            ",$09,$A0,$A0,$19,$20,$99,$A0,$A0,$19,$20,$99,$A0,$A0,$0F,"              "
	.SBYTE "         ",$15,$15,$8D,$A0,$A0,$A0,$16,$20,$99,$A0,$A0,$19,$20,$02,$A0,$A0,$A0,$8D,$15,$15,"           "
	.SBYTE "         ",$A0,$A0,$A0,$A0,$A0,$19,$20,$20,$99,$A0,$A0,$19,$20,$20,$99,$A0,$A0,$A0,$A0,$A0,"           "
	.SBYTE "         ",$A0,$A0,$A0,$95,$0C,$20,$20,$20,$99,$A0,$A0,$19,$20,$20,$20,$0B,$95,$A0,$A0,$A0," (R)       "
	.SBYTE "         ",$0D,$0D,$20,$20,$20,$20,$20,$20,$0B,$95,$95,$0C,$20,$20,$20,$20,$20,$20,$0D,$0D,"           "
	.SBYTE "                                        "
	.SBYTE "                                        "
;MENSAJE START
	.SBYTE "     PRESIONE "
	.SBYTE +128,"START"
	.SBYTE " PARA CONTINUAR.     "
	.SBYTE "                                        "
;PANTALLA MENU PRINCIPAL
MENUPRINCIPALDLI
	.BYTE $70,$70,$70,$46
	.WORD TITULOMENUPRINCIPAL
	.BYTE $70,$42
	.WORD TEXTOMENUPRINCIPAL
	.BYTE $02,$02,$02,$02,$02,$02,$02,$02
	.BYTE $02,$02,$02,$02,$02,$02,$02,$02
	.BYTE $02,$02,$02,$02
	.BYTE $41
	.WORD MENUPRINCIPALDLI
MENUPRINCIPAL
	LDA #<MENUPRINCIPALDLI
	STA $230
	LDA #>MENUPRINCIPALDLI
	STA $231
	RTS
;DATA
TITULOMENUPRINCIPAL
	.SBYTE +64,"ORGANIZADOR DE DISCO"
TEXTOMENUPRINCIPAL
	.SBYTE +128," ORGANIZADOR DE DISCOS PARA ATARI 2018  "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "             "
	.SBYTE +128,"MENU PRINCIPAL"
	.SBYTE "             "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "    ",['N+$80],"uevo archivo                       "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "FIN                                     "
NUEVOARTICULODLI
	.BYTE $70,$70,$70,$46
	.WORD TITULONUEVOARTICULO
	.BYTE $70,$42
	.WORD TEXTONUEVOARTICULO
	.BYTE $02,$02,$02,$02,$02,$02,$02,$02
	.BYTE $02,$02,$02,$02,$02,$02,$02,$02
	.BYTE $02,$02,$02,$02
	.BYTE $41
	.WORD NUEVOARTICULODLI
NUEVOARTICULO
	LDA #<NUEVOARTICULODLI
	STA $230
	LDA #>NUEVOARTICULODLI
	STA $231
	RTS
;DATA
TITULONUEVOARTICULO
	.SBYTE +64,"ORGANIZADOR DE DISCO"
TEXTONUEVOARTICULO
	.SBYTE +128,"            NUEVO  ARTICULO             "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "NUMERO DE REGISTRO 0000                 "	;4
	.SBYTE "                                        "
	.SBYTE "TITULO    : "
NUEVOTITULO
	.SBYTE "..........................."
TEXTONUEVOARTICULO01	
	.SBYTE " "	;27
	.SBYTE "CATEGORIA : "
NUEVOCATEGORIA
	.SBYTE "..........................."
TEXTONUEVOARTICULO02
	.SBYTE " "	;27
	.SBYTE "DISCO     : "
NUEVODISCO	;NUEVODISCO$
	.SBYTE "......"
TEXTONUEVOARTICULO03
	.SBYTE "                      "	;6
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "OBSERVACIONES                           "
	.SBYTE "                                        "
NUEVOOBSERVACIONES
	.SBYTE "....................................... "	;39
	.SBYTE ".......................                 "	;126
TEXTONUEVOARTICULO04
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "                                        "
	.SBYTE "FIN                                     "