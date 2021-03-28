; quick and dirty specnotes - january 2011 - pps

hposp0    = $D000
hposp1    = $D001
hposp2    = $D002
hposp3    = $D003
hposm0    = $D004
hposm1    = $D005
hposm2    = $D006
hposm3    = $D007
sizep0    = $D008
sizep1    = $D009
sizep2    = $D00A
sizep3    = $D00B
sizem    = $D00C
colpm0    = $D012
colpm1    = $D013
colpm2    = $D014
colpm3    = $D015
color0    = $D016
color1    = $D017
color2    = $D018
color3    = $D019
colbak    = $D01A
gtictl    = $D01B
pmcntl    = $D01D
hitclr    = $D01E
skctl    = $D20F
portb    = $D301
dmactl    = $D400
dlptr    = $D402
vscrol    = $D405
pmbase    = $D407
chbase    = $D409
wsync    = $D40A
vcount    = $D40B
nmien    = $D40E
nmist    = $D40F

;* ---    MAIN PROGRAM

	org $a000

ant    dta $70,$70,$70,$70,$70,$f0,$42,a(scr),$70
    dta $02,$0,$02,$40,$02,$0,$02,$0,$02,$0,$02,$0,$02,$0,$02,$0,$02,$0,$02
    dta $40,$02
    dta $41,a(ant)

mainload


    mwa #ant 560        ;DL an
    mwa #dli 512        ;dann neuen eintragen

    lda #7            ;VBI
    ldx >vbi        ;wird
    ldy <vbi        ;jetzt
    jsr $e45c        ;angeschaltet

    mva #$c0 $d40e        ;und an

    mva #$ff skctl
l    lda skctl
    cmp #$ff
    beq l

    jmp $e477


c1    dta 0    ;aim $06
c2    dta 0    ;aim $0e

;----------------------------------------------------

dli    pha
    tya
    pha
    txa
    pha

    lda #$E0
    sta chbase
    lda #$00
    sta colbak
    lda c1
    sta color1
    lda c2
    sta color2
    sta wsync


    pla
    tax
    pla
    tay
    pla
    rti

;-----

dli2    pha
    tya
    pha
    txa
    pha

    lda #$E0
    sta chbase
    lda #$00
    sta colbak
    lda #$0e
    sta color2
    lda #$06
    sta color1
    ldx #0
l1    sta wsync
    inx
    cpx zaehl
    bne l1
    ldx #$06
    stx color1
    stx wsync
    inx
    stx color1
    stx wsync
    inx
    stx color1
    stx wsync
    inx
    stx color1
    stx wsync
    inx
    stx color1
    stx wsync
    inx
    stx color1
    stx wsync
    inx
    stx color1
    stx wsync
    inx
    stx color1
    stx wsync
    inx
    stx color1
    stx wsync

    pla
    tax
    pla
    tay
    pla
    rti

;-----

dli3    pha
    tya
    pha
    txa
    pha

    lda #$E0
    sta chbase
    lda #$00
    sta colbak
    lda #$06
    sta color1
    lda #$0e
    sta color2


    pla
    tax
    pla
    tay
    pla
    rti



zaehl    dta 0
;-------------------------------

vbi    lda zaehl
    cmp #$5
    bmi vbiout

    mva #0 zaehl
    lda c2
    cmp #$0e
    beq set_c1
    inc c2
    inc c1
    jmp vbiend
set_c1    mva #0 zaehl
    lda #7            ;VBI
    ldx >vbi2        ;wird
    ldy <vbi2        ;jetzt
    jsr $e45c        ;angeschaltet
    jmp $e462        ;VBI zuende und weiter mit System


vbiout    inc zaehl
vbiend    mwa #dli 512
    jmp $e462        ;VBI zuende und weiter mit System

;-----------

vbi2    mwa #dli2 512
    lda zaehl
    cmp #120
    bpl set_v3
    inc zaehl
    jmp $e462        ;VBI zuende und weiter mit System

set_v3    lda #7            ;VBI
    ldx >vbi3        ;wird
    ldy <vbi3        ;jetzt
    jsr $e45c        ;angeschaltet
    jmp $e462        ;VBI zuende und weiter mit System

;------------

vbi3    mwa #dli3 512
    jmp $e462        ;VBI zuende und weiter mit System

;-------------------------------

    org $a800
scr
    dta d'Some notes Rybags gave about Spectipede:'
    dta d'-'*
    dta d' The game should be able to run on a   '
    dta d'  32K machine so I',b(7),d'm targetting at that.'
    dta d'-'*
    dta d' It should be noted it',b(7),d's a conversion  '
    dta d'  of a budget 2.99 game from Master-    '
    dta d'  tronic for the Commodore Plus/4. It',b(7),d's '
    dta d'  got a bit of a bug in the game where  '
    dta d'  sometimes you can run into an enemy   '
    dta d'  without harm. Other times you get     '
    dta d'  killed. Maybe it',b(7),d's the reason it was  '
    dta d'  made into a budget title.             '
    dta d'-'*
    dta d' Be aware about a future VBXE version! '


    run mainload
