;Decrunch text linker 

  !to "shockraidpiclinker.prg",cbm
  *=$0801
  !bin "shockraidpiclinker.exo",,2
  lda #$00
  sta $d020
  sta $d021
  lda #$14
  sta $d018
  ldx #$00
clrscr
  lda #$20
  sta $0400,x
  sta $0500,x
  sta $0600,x
  sta $06e8,x
  inx
  bne clrscr
  
  ldx #$00
getdata
  lda decrunchtext,x
  sta $0400,x
  lda #$0f
  sta $d800,x
  inx
  cpx #decrunchtextend-decrunchtext
  bne getdata
  rts
  
  !ct scr
decrunchtext
  !text "please wait ............... de-crunching"
decrunchtextend  
  