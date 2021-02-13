;Shock Raid picture linker

vid = $3f40
col = $4328

                    !to "shockraidpiclinker.prg",cbm
                    *=$0801
                    !basic 2061
                    *=$080d
                    sei
                    lda $02a6
                    sta system
                    lda #$00
                    sta $d020
                    sta $d021
                    ldx #$00
drawpic             lda vid,x
                    sta $0400,x
                    lda vid+$100,x
                    sta $0500,x
                    lda vid+$200,x
                    sta $0600,x
                    lda vid+$2e8,x 
                    sta $06e8,x
                    lda col,x
                    sta $d800,x
                    lda col+$100,x
                    sta $d900,x
                    lda col+$200,x
                    sta $da00,x
                    lda col+$2e8,x
                    sta $dae8,x
                    inx
                    bne drawpic
                    lda #$3b
                    sta $d011
                    lda #$18
                    sta $d018
                    sta $d016
                    lda #$03
                    sta $dd00
                    ldx #<irq
                    ldy #>irq
                    lda #$32
                    stx $0314 
                    sty $0315
                    sta $d012
                    lda #$7f
                    sta $dc0d
                    sta $dd0d
                    lda #$3b
                    sta $d011
                    lda #$01
                    sta $d019
                    sta $d01a
                    lda #$00
                    jsr $1000
                    cli
DisplayLoop                    
                    lda $dc01
                    cmp #$ef
                    bne DisplayLoop2
                    jmp Exit
DisplayLoop2                    
                    lda #16
                    bit $dc00
                    bne DisplayLoop
                    
                    
                    
Exit                sei
                    ldx #$31
                    ldy #$ea
                    lda #$81
                    stx $0314
                    sty $0315
                    sta $dc0d
                    sta $dd0d
                    lda #$00
                    sta $d019
                    sta $d01a
                    ldx #$00
clearsound          lda #$00
                    sta $d400,x
                    inx
                    cpx #$18
                    bne clearsound
                    jsr $ff81
                    lda #$00
                    sta $d020
                    sta $d021
                    ldx #$00
maketransfer        lda transfer,x
                    sta $0600,x
                    lda #0
                    sta $d800,x
                    sta $d900,x
                    sta $da00,x
                    sta $dae8,x
                    inx
                    bne maketransfer
                    ldx #$00
copydecrunchtext    lda decrunchtext,x
                    sta $0400,x
                    lda #$0c
                    sta $d800,x
                    inx
                    cpx #$28
                    bne copydecrunchtext
                    lda #$00
                    sta $0800
                    cli
                    jmp $0600
transfer            sei
                    lda #$34
                    sta $01
copyloop1           ldx #0                    
copyloop            lda $4800,x
                    sta $0801,x
                    inx
                    bne copyloop
                    inc $0609
                    inc $060c
                    lda $0609
                    bne copyloop1
                    lda #$37
                    sta $01
                    cli
                    jsr $a659
                    jmp $a7ae
                    
irq                 inc $d019
                    lda $dc0d
                    sta $dd0d
                    lda #$f8
                    sta $d012
                    jsr musicplayer
                    jmp $ea7e
                    
musicplayer         lda system
                    cmp #1
                    beq pal
                    inc ntsctimer
                    lda ntsctimer
                    cmp #6
                    beq resetntsc
pal                 jsr $1003
                    rts
resetntsc           lda #0
                    sta ntsctimer
                    rts
                    
system              !byte 0                    
ntsctimer           !byte 0
                    !ct scr
decrunchtext        
                    !text "-decrunching game, please wait a moment-"
                    
                    *=$1000
                    !bin "bin\loadertune.prg",,2
                    
                    *=$2000
                    !bin "bin\shockraidload.prg",,2
                    
                    *=$4800
                    !bin "shockraid.prg",,2
                    