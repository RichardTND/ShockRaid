;Shockraid end screen 

;Kill all interrupts and draw end screen.

EndScreen
          sei
          lda #$35
          sta $01
          ldx #$48
          ldy #$ff
          stx $fffe
          sty $ffff
          lda #$81
          sta $dc0d
          sta $dd0d
          lda #$00
          sta $d019
          sta $d01a
          sta $d011
          sta cp 
          sta cp2
          sta cp2b
          sta enddelay   
          ldx #$00
.backupscore
          lda Score,x
          sta scorebackup,x
          inx 
          cpx #$05
          bne .backupscore
          
          ;Grab all of the lasers 
          
          ldx #$00
RestoreLasersForEnd
          lda LaserGateCharsBackup,x
          sta LaserGateChars,x
          inx
          cpx #64
          bne RestoreLasersForEnd
          
          ;Draw the end scene map
          
          ldx #$00
.drawendscene
          lda endscreenmemory,x
          sta screen,x
          lda endscreenmemory+$100,x
          sta screen+$100,x
          lda endscreenmemory+$200,x
          sta screen+$200,x
          lda endscreenmemory+$2e8,x
          sta screen+$2e8,x
          lda #$09
          sta $d800,x
          sta $d900,x
          sta $da00,x
          sta $dae8,x
          inx
          bne .drawendscene
          
          ;Remove all sprites 
          
          ldx #$00
.zeroposend
          lda #$00
          sta $d000,x
          sta $d001,x
          sta ObjPos,x 
          inx
          cpx #$10
          bne .zeroposend
          
          ;Now fill animation with blank sprites
          
          ldx #$00
.zerofillframesend
          lda #$ff
          sta $07f8,x
          inx
          cpx #$08
          bne .zerofillframesend
          
          ;Now setup the screen perameters.
          
          lda #$0f
          sta $d022
          lda #$0b
          sta $d023
          lda #$18
          sta $d016
          lda #$1e
          sta $d018 
          lda #$1b
          sta $d011
          lda #0
          sta $d020
          sta $d021
          lda #$ff
          sta $d015
          sta $d01c
          lda #$0b
          sta $d025
          lda #$0c
          sta $d026
          lda #$0f
          sta $d027
          lda #$07
          sta $d028
          lda #$0d
          sta $d029
          sta $d02b 
          lda #$03
          sta $d02a
          sta $d02c 
          
         
          lda #$03
          sta $d029
          sta $d02a
          lda #$03
          sta $d02b
          sta $d02c
          lda #%00000100
          sta $d017
          sta $d01d
          lda Crystal
          sta $07fa
          lda #$51
          sta ObjPos+4
          lda #$92
          sta ObjPos+5
         
          
          
          
          ;Setup the end screen IRQ
          
          ldx #<endirq
          ldy #>endirq
          stx $fffe
          sty $ffff
          lda #$7f
          sta $dc0d
          sta $dd0d
          lda #$32
          sta $d012
          lda #$01
          sta $d019
          sta $d01a
          lda #1
          jsr MusicInit2
          cli
          jmp EndLoop1
          
endirq    sta estacka+1
          stx estackx+1
          sty estacky+1
          lda $dc0d
          sta $dd0d
          asl $d019
          lda #$fa
          sta $d012
          lda #1
          sta ST
          jsr HiScorePlayer
estacka   lda #$00
estackx   ldx #$00
estacky   ldy #$00
          rti
          
          
;End loop 1 - In this scene we just animate the laser beams
;and the crystal. Wait a few seconds before sending in the player
;ship. 

EndLoop1  jsr SyncTimer
          jsr ExpandSpritePosition
          jsr AnimEndBG
          jsr AnimSprites
          jsr FlashCrystal
          lda Crystal
          sta $07fa
          inc enddelay
          lda enddelay
          beq nextscene
          jmp EndLoop1
          
          
;End loop 2 - In this scene, the player ship enters the room 
          
nextscene
          lda #0
          sta enddelay
          
          lda #$56
          sta ObjPos+0
          lda #$fe
          sta ObjPos+1
          
          

EndLoop2  jsr SyncTimer
          jsr ExpandSpritePosition 
          jsr AnimEndBG
          jsr AnimSprites
          jsr FlashCrystal
          lda Crystal
          sta $07fa
          lda PlayerType
          sta $07f8 
          lda #$0f
          sta $d027
          lda ObjPos+1
          sec
          sbc #1
          cmp #$dc
          bcs .stopship
          lda #$dc 
.stopship
          sta ObjPos+1 
          inc enddelay
          lda enddelay
          beq nextscene3
          jmp EndLoop2 
      
;Next, the player shoots the crystal a few times, before it gets destroyed.
nextscene3
          lda #0
          sta enddelay 
          
EndLoop3  jsr SyncTimer
          jsr ExpandSpritePosition 
          jsr AnimEndBG
          jsr AnimSprites 
          jsr FlashCrystal
          jsr FlashPlayerBullet
          lda Crystal
          sta $07fa
          lda PlayerType
          sta $07f8 
          lda #$0f 
          sta $d027 
          lda PlayerBulletFrame
          sta $07f9 
          lda BColSM+1
          sta $d028
          jsr FireBullets
          inc enddelay 
          lda enddelay
          beq nextscene4
          jmp EndLoop3
          
;Scene 4 ...   the crystal and the room is destroyed, and the player moves out of the screen 

nextscene4 lda #0
           sta enddelay 
           
           ldx #$00
makeendscreen2           
           lda endscreen2,x
           sta $0400,x
           lda endscreen2+$100,x
           sta $0500,x
           lda endscreen2+$200,x
           sta $0600,x 
           lda endscreen2+$2e8,x
           sta $06e8,x
           inx
           bne makeendscreen2
           
           jmp EndLoop4
checktodelete
           cmp #1
           beq .mkblank 
           cmp #2
           beq .mkblank 
           cmp #3
           beq .mkblank 
           cmp #4
           beq .mkblank 
           rts
.mkblank   lda #0
           rts
           
           
EndLoop4
           jsr SyncTimer
           jsr ExpandSpritePosition
           jsr AnimEndBG
          
           jsr DestroyEverything 
           lda PlayerType
           sta $07f8 
           lda #$ff
           sta PlayerBulletFrame
           jmp EndLoop4
           
DestroyEverything 
         
           lda cp2b
           cmp #2
           beq .doit
           inc cp2b
           rts
.doit      lda #0
           sta cp2b
           ldx cp2
           lda bgexplodetable,x
           sta $d020
           sta $d021
           lda spriteexploder,x
           sta $07fa
           lda #$07
           sta $d029
           inx
           cpx #bgexplodetableend-bgexplodetable 
           beq .finishedExp 
           inc cp2
           rts
.finishedExp 
           ldx #0
           stx cp2
           lda #0
           sta ObjPos+2
           sta ObjPos+3
           sta ObjPos+4
           sta ObjPos+5
           
;The crystal has been destroyed. Allow the player to fly out of the scene  
;Also show the background shorting out while moving out
           
endscene5           
EndLoop5
           jsr SyncTimer
           
           jsr ExpandSpritePosition
           jsr AnimSprites
           jsr Surge
           jsr MoveOutScene
           jmp EndLoop5
MoveOutScene

           lda ObjPos+1
           beq Out
           sec 
           sbc #1
           
           sta ObjPos+1           
           rts
Out        jmp DisplayEndText
           
Surge      ldx cp2 
           lda surgetable1,x
           sta $d022
           lda surgetable2,x
           sta $d023 
           inx
           cpx #12
           beq .loopsurge
           inc cp2
           rts
.loopsurge  ldx #0
           stx cp2
           rts
           
           
           
           
           
          
          
;Player fires bullets 
FireBullets
          lda ObjPos+3
          sec 
          sbc #9
          cmp #$98
          bcs .under 
          jmp BlastOut
.under    sta ObjPos+3          
          rts 
BlastOut  lda ObjPos+0
          sta ObjPos+2
          lda ObjPos+1
          sta ObjPos+3
         
          rts
          
          
         
          
         
;Animate the laser beams 
          
AnimEndBG          
         ;Down lasers 
         
         lda EndLaserDownChar1+7
         sta $e2
         lda EndLaserDownChar2+7
         sta $e3
         ldx #$07
.sdown   lda EndLaserDownChar1-1,x
         sta EndLaserDownChar1,x 
         lda EndLaserDownChar2-1,x
         sta EndLaserDownChar2,x
         dex
         bpl .sdown
         
         ;Restore last char byte 
         lda $e2
         sta EndLaserDownChar1
         lda $e3
         sta EndLaserDownChar2
         
         ;Left lasers 
         
         ldx #0
.sleft         
         lda EndLaserLeftChar1,x
         asl
         rol EndLaserRightChar1,x
         rol EndLaserLeftChar1,x 
         asl
         rol EndLaserRightChar1,x
         rol EndLaserLeftChar1,x
         inx
         cpx #8
         bne .sleft 
         
         ldx #0
.sleft2  lda EndLaserLeftChar2,x
         asl
         rol EndLaserRightChar2,x
         rol EndLaserLeftChar2,x 
         asl
         rol EndLaserRightChar2,x
         rol EndLaserLeftChar2,x
         inx
         cpx #8
         bne .sleft2
         rts
         
;Flash the crystal 
FlashCrystal
        ldx cp  
        lda crystaltable,x
        sta $d029
        inx
        cpx #crystaltableend-crystaltable 
        beq resetfl
        inc cp
        rts
resetfl ldx #0
        stx cp 
        rts
        
;The final part of the end scene 
DisplayEndText
        lda #0
        sta FireButton
        
        lda #$0b
        sta $d011 
        lda #$00
        sta $d017
        sta $d01d
        sta $d015
        lda #$0e
        sta $d022
        lda #$06
        sta $d023
;Setup the end text and attribs 
       
        ldx #$00
.setendtext      
        lda endtext,x
        sta screen,x
        lda endtext+$100,x
        sta screen+$100,x
        lda endtext+$200,x
        sta screen+$200,x
        lda endtext+$2e8,x
        sta screen+$2e8,x
        ldy screen,x 
        lda hudattribs,y 
        sta colour,x
        ldy screen+$100,x
        lda hudattribs,y
        sta colour+$100,x
        ldy screen+$200,x 
        lda hudattribs,y 
        sta colour+$200,x 
        ldy screen+$2e8,x
        lda hudattribs,y 
        sta colour+$2e8,x 
        inx
        bne .setendtext 
        ldx #$00
.restorelaserbeams
        lda LaserGateCharsBackup,x
        sta LaserGateChars,x
        inx
        cpx #64
        bne .restorelaserbeams
        
        lda #$12
        sta $d018
        lda #$1b
        sta $d011
        
EndLoopFinal
        jsr SyncTimer
        jsr LaserGate
        lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit FireButton
        ror FireButton
        bmi EndLoopFinal 
        bvc EndLoopFinal 
        lda #0
        sta FireButton
        
        ldx #$00
.restorescore
        lda scorebackup,x
        sta Score,x
        inx
        cpx #5
        bne .restorescore
        
        
        jmp HiScoreRoutine
        
        
BulletSpawnCount !byte 0
        
cp !byte 0        
crystaltable 
        !byte $06,$06,$05,$05,$0e,$0e,$03,$03,$01,$01,$03,$03,$0e,$0e,$05,$05
crystaltableend !byte 6        
         
enddelay !byte 0

cp2 !byte 0
cp2b !byte 0
bgexplodetable
         !byte $00,$09,$02,$08,$0a,$07,$01,$07,$0a,$08,$02,$09,$00,$00
bgexplodetableend !byte 0         
spriteexploder
         !byte $85,$85,$86,$86,$87,$87,$88,$88,$89,$89,$8a,$8a,$8b,$8b,$8b         
          
         
surgetable1
         !byte $0b,$0c,$0f,$07,$01,$07,$0f,$0c,$0b,$0b,$0b,$0b                  
surgetable2
         !byte $0c,$0c,$0f,$07,$01,$07,$0f,$0c,$0c,$0c,$0c,$0c
         
scorebackup !fill 6,0         
