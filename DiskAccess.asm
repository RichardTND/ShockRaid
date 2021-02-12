;*********************************
;*                               *
;*        LET'S INVADE 2         *
;*             by                *
;*       RICHARD BAYLISS         *
;*                               *
;*  (C) 2019 THE NEW DIMENSION   *
;*                               *
;*********************************

;Hi score loader / saver routine 
!ifdef DiskVersion {
!ct scr
dname !pet "s:"
fname !pet "sr.hi"
fnamelen = *-fname
dnamelen = *-dname


SaveHiScore
      lda cheatlives+1
      cmp #$2c
      beq SkipHiScoreSaver
      jsr DisableInts
      jsr savefile
      lda #$35
      sta $01
SkipHiScoreSaver
      rts 
      
      
LoadHiScores

    ; lda CheatMode
    ; cmp #1
  ;   beq SkipHiScoreLoader
      jsr DisableInts
      
      jsr loadfile
SkipHiScoreLoader
      rts 


DisableInts
      sei
      lda #$48
      sta $FFFE
      lda #$FF
      sta $FFFF
      lda #$00
      sta $d019
      sta $d01a
      sta $d015
      lda #$81
      sta $dc0d
      sta $dd0d
      ldx #$00
clrsidD
      lda #$00 
      sta $d400,x
      inx
      cpx #$18
      bne clrsidD
      lda #$0b
      sta $d011
      lda #$36
      sta $01
      cli
      rts
savefile
      
          ldx $ba             ; get current devicenumber
          cpx #$08
          bcc skipsave    ; skip saving below device #8
                                   ; begin delete file
        
          lda #$0f
          tay
          jsr $ffba            ; set addressses
          jsr resetdevice
          lda #dnamelen
          ldx #<dname
          ldy #>dname
          jsr $ffbd             ; set deletename+length
          jsr $ffc0             ; "open" sends dname as disk command
          lda #$0f         
          jsr $ffc3             ; "close"
          jsr $ffcc             ; clear channel
                                   ; end delete file
 
                                   ; begin save file
          lda #$0f
          ldx $ba
          tay
          jsr $ffba            ; set addressses
          jsr resetdevice
          lda #fnamelen
          ldx #<fname
          ldy #>fname
          jsr $ffbd           ; set filename+length
          lda #$fb          ; zeropage
          ldx #<HiScoreTableStart
          ldy #>HiScoreTableStart
          stx $fb            ; zeropage low
          sty $fc            ; zeropage high
          ldx #<HiScoreTableEnd
          ldy #>HiScoreTableEnd
          jsr $ffd8          ; save file
skipsave
skipsave
      rts
      
;--------------------------------------------------
loadfile
;Loading hi-score tables
    
      ldx $ba
      cpx #$08
      bcc skipload
      
      lda #$0f
      tay
      jsr $ffba
      jsr resetdevice
      lda #fnamelen
      ldx #<fname
      ldy #>fname
      jsr $ffbd
      lda #$00
      jsr $ffd5
      bcc loaded
      
      jsr savefile
loaded
skipload
      rts
      
;Reset device,
resetdevice

      lda #$01
      ldx #<INITDRIVE
      ldy #>INITDRIVE
      jsr $FFBD
      jsr $FFC0
      lda #$0F
      JSR $FFC3
      JSR $FFCC
      rts
      
INITDRIVE
      !pet "i:"
}

