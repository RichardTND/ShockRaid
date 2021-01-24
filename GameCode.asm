;#############################
;#        Shock Raid         #
;#                           #
;#     by Richard Bayliss    #
;#                           #
;# (C)2021 The New Dimension #
;#     For Reset Magazine    #
;#############################

;Main game code

NewLevelStart
    ldx #$fb
    txs
    
    sei
    lda #$35
    sta $01
    lda #$00
    sta $d01a
    sta $d019
    lda #$81
    sta $dc0d
    sta $dd0d
    ldx #$48 
    ldy #$ff
    stx $fffe
    sty $ffff
    
    lda #$18
    sta $d016
    lda #$1e  ;Game screen map
    sta $d018
    lda #$00
    sta $d020
    sta $d021
    lda #0
    sta LevelPointer
    sta PlayerBulletColourPointer
    
    ;Initialise all sprite positions 
    
    ldx #$00
.initspritepos
    lda #$00
    sta $d000,x
    sta ObjPos,x
    inx
    inx
    cpx #$10
    bne .initspritepos
    
    ;Initialise map scroll
    lda #<mapend  ;'mapload' is the start address which is the last
    sta map       ;row to appear on screen when scrolling downwards!
    lda #>mapend  ;so find a way to calculate 'mapend' (see above)
    sta map+1     
    
    jsr SetupLevelScheme
    
    ldx #$00
ZeroFillGameScreen
    lda #$00
    sta screen,x
    sta screen+$100,x
    sta screen+$200,x
    sta screen+$2e8,x
    lda #$09 ;Fill multicolour WHITE
    sta colour,x
    sta colour+$100,x
    sta colour+$200,x
    sta colour+$2e8,x
    inx
    bne ZeroFillGameScreen
    
    ;Draw the panel (The size from charpad is 6 by 40
    
    ldx #$00
.drawhud
    lda hud,x
    sta screen+$2f8+40,x
    inx
    cpx #240 
    bne .drawhud
    
    ldx #$00
.colourhud    
    ldy hud,x
    lda hudattribs,y 
    sta colour+$2f8+40,x
    inx
    cpx #240
    bne .colourhud
   
    ;Setup the game sprites
    
    lda #$ff
    sta $d015
    sta $d01c
    lda #$01
    sta $d025
    lda #$09
    sta $d026
    lda #$03
    sta $d027
    lda #$80
    sta $07f8 ;Sprite 0 HW frame
    lda #$56
    sta ObjPos
    lda #$b8
    sta ObjPos+1
    
    ldx #<irq1
    ldy #>irq1
    stx $fffe
    sty $ffff
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda #$32
    sta $d012
    lda #$1b
    sta $d011
    lda #$01
    sta $d01a
    sta $d019
    lda #0
    jsr MusicInit
    
    ;Zero multi-sprite animation routine 
    
    lda #0
    sta SpriteAnimDelay
    sta SpriteAnimPointer 
    
    
    cli
    jmp GameLoop
    
;Construct main IRQ raster interrupts.

    !source "irq.asm"
    
;Main game loop (controls the main body of the game code)

GameLoop    
      jsr SyncTimer
      jsr ExpandSpritePosition
      jsr AnimSprites
      jsr Scroller
      jsr LaserGate
      jsr PlayerProperties
      jmp GameLoop
      
      
;Synchronise timer (ST) - game and also merged with some other routines

SyncTimer      
      lda #0
      sta ST
      cmp ST
      beq *-3
.skip rts
      
;Double the size of the X sprite position so that the sprites can
;use the whole screen area.

ExpandSpritePosition
      ldx #$00
.expandposloop
      lda ObjPos+1,x
      sta $d001,x
      lda ObjPos,x
      asl
      ror $d010
      sta $d000,x
      inx
      inx
      cpx #$10
      bne .expandposloop
      rts
      
;Animate those sprites 

AnimSprites
      lda SpriteAnimDelay
      cmp #4
      beq .dospriteanim
      inc SpriteAnimDelay
      rts
      
.dospriteanim
      lda #0
      sta SpriteAnimDelay
      
      ;Main sprite animation, read animation table and 
      ;store to self-modifying pointers for sprite animation 
      
      ldx SpriteAnimPointer
      lda PlayerShipFrame,x
      sta PlayerType
      lda AlienType1Frame,x
      sta AlienType1
      lda AlienType2Frame,x
      sta AlienType2 
      lda AlienType3Frame,x 
      sta AlienType3
      lda AlienType4Frame,x 
      sta AlienType4
      lda AlienType5Frame,x
      sta AlienType5 
      lda AlienType6Frame,x 
      sta AlienType6 
      lda AlienType7Frame,x 
      sta AlienType7 
      lda AlienType8Frame,x
      sta AlienType8 
      inx
      cpx #4
      beq .loopanimation
      inc SpriteAnimPointer 
      rts 
.loopanimation
      ldx #$00
      stx SpriteAnimPointer
      rts
      
      
      
      
      
      
      
;Scroll main game background data

Scroller
;      lda ydelay
;      cmp #1
;      beq ScrollMain
;      inc ydelay
;      jmp .skip ;If not reached delay, jump to nearest RTS command
      
      ;Scroll fast enough, reset delay timer and continue to the 
      ;main scroller routine 
      
ScrollMain      
 ;     lda #0
 ;     sta ydelay
      
      ;Main scroll controll routine (this controls the smoothness
      ;of the scroll connected to the interrupt (irq1)
      
      lda ypos
      and #$07
      clc
      adc #$01
      tax
      and #$07
      sta ypos
      txa
      adc #$f8
      bcs DoHardScroll
      rts

DoHardScroll
      jsr FitRows ;Jump subroutine to draw each row to the screen
      
DoMap lda tileY
      bne SameMapRow
      
      lda map
      sec
      sbc #10   ;Size of map = 10 columns
      sta map
      lda map+1
      sbc #$00
      sta map+1
      lda #$10
SameMapRow      
      sec
      sbc #$04
      sta tileY
      
      lda map
      sta maptmp 
      lda map+1
      sta maptmp+1
      
      lda #$00
      ldx #>screen
      jsr ExtractRow
      
      rts
      
      ;Extract row from map data
      
ExtractRow
      sta PlotRow+1 ;Store to lobyte PlotRow
      clc 
      adc #$28
      sta Check+1
      stx PlotRow+2 ;Store to hibyte PlotRow
      
Extract
      ldy #$00
      lda (maptmp),y
      and #$0f
      asl
      asl
      asl
      asl
      sta tiledata ;Low byte of title data address
      lda (maptmp),y
      and #$f0
      lsr
      lsr
      lsr
      lsr
      clc
      adc #tilemem
      sta tiledata+1
      
      ldy tileY
      ldx #$03
ReadTile
      lda (tiledata),y
PlotRow      
      sta $ffff
      inc PlotRow+1
      bne Loop01
      inc PlotRow+2
Loop01  
      lda PlotRow+1
Check cmp #$28
      beq ExitTileLogic
      iny
      dex
      bpl ReadTile
      inc maptmp
      bne Loop02
      inc maptmp+1
      
Loop02
      clv
      bvc  Extract 
ExitTileLogic
      rts
      
      ;Fit each row and perform main scroll 
FitRows      
      ldx #$27
ShiftRows1
       lda row10,x
       sta rowtemp,x
       lda row9,x
       sta row10,x
       lda row8,x
       sta row9,x
       lda row7,x
       sta row8,x
       lda row6,x
       sta row7,x
       lda row5,x
       sta row6,x
       lda row4,x
       sta row5,x
       lda row3,x
       sta row4,x
       lda row2,x
       sta row3,x
       lda row1,x
       sta row2,x
       lda row0,x
       sta row1,x
       dex
       bpl ShiftRows1
       
       ldx #$27
ShiftRows2
        lda #$00
        sta row20,x
        lda row18,x
        sta row19,x
        lda row17,x
        sta row18,x
        lda row16,x
        sta row17,x
        lda row15,x
        sta row16,x
        lda row14,x
        sta row15,x
        lda row13,x
        sta row14,x
        lda row12,x
        sta row13,x
        lda row11,x
        sta row12,x
        lda rowtemp,x
        sta row11,x
     
        dex
        bpl ShiftRows2
        
;Finally a simple subroutine that the end of the flag 

        ldx #$00
.checkflag
        lda row19,x
        cmp #104 ;char detection 
        beq .setupnextlevel
        inx
        cpx #$28
        bne .checkflag 
        rts
        
;Setup next level
.setupnextlevel
        inc LevelPointer
        lda LevelPointer
        clc
        adc #$31
        sta $0796
        jmp SetupLevelScheme
        
        
;Main level counter checker 

SetupLevelScheme
        ldx LevelPointer
        lda D022Colour,x
        sta BGColour1
        lda D023Colour,x
        sta BGColour2
        inx
        cpx #5 
        beq GameComplete
        rts 

;The player has completed the game
        
GameComplete        
        inc $d020 
        jmp *-3
        
;Control the laser gates settings (on/off)

LaserGate
        jsr ScrollLasers
        lda LaserTriggerTime 
        cmp #64
        beq TriggerLaserMode
        inc LaserTriggerTime
        rts
        
TriggerLaserMode        
        lda #0
        sta LaserTriggerTime
        lda LaserTriggerOn
        cmp #1
        beq ActivateLaserGate
        
        ;Laser gate not active - remove laser chars 
        
        ldx #$00
.remove
        lda #$00
        sta LaserGateChars,x
        inx
        cpx #32
        bne .remove
        lda #1
        sta LaserTriggerOn
        rts
        
        ;Laser gate has been activated, copy backup characters
        ;and place on to the laser gate
ActivateLaserGate
        
        ldx #$00
.backupchars
        lda LaserGateCharsBackup,x
        sta LaserGateChars,x
        inx
        cpx #32
        bne .backupchars
        lda #0
        sta LaserTriggerOn
        rts
        
        ;Scroll the lasers across 
ScrollLasers
        
        ldx #$00
.scrolllaserchars
        lda LaserGateChars+8,x
        asl 
        rol LaserGateChars+8,x
        asl
        rol LaserGateChars+8,x
        lda LaserGateChars,x
        asl
        rol LaserGateChars,x
        asl
        rol LaserGateChars,x
        inx
        cpx #$08
        bne .scrolllaserchars
        
        ldx #$00
.scrollmorelaserchars
        lda LaserGateChars+24,x
        asl
        rol LaserGateChars+24,x
        asl
        rol LaserGateChars+24,x
        lda LaserGateChars+16,x
        asl
        rol LaserGateChars+16,x
        asl 
        rol LaserGateChars+16,x
        inx
        cpx #$08
        bne .scrollmorelaserchars
        rts
        
;Player control (Joystick read) 

PlayerProperties        

        jsr PlayerBulletProperties ;Also control the player's bullet 
                            
        ;lda PlayerDead
        ;cmp #$01
        ;beq .destroyplayer
        
        ;Player is alive, so it is allowed to be controlled.
        
        lda PlayerType
        sta $07f8 
        lda #$03
        sta $d027
        
        ;Read joystick port 2 controls, and then move ship accordingly
        
        lda #1    ;read up control
        bit $dc00 
        bne .notup
        jsr MovePlayerUp
        
.notup  lda #2    ;read down control
        bit $dc00
        bne .notdown
        jsr MovePlayerDown 
        
.notdown
        lda #4    ;read left control
        bit $dc00 
        bne .notleft
        jsr MovePlayerLeft 
        
.notleft
        lda #8    ;read right control
        bit $dc00
        bne .notright
        jsr MovePlayerRight
        
.notright
        lda #16   ;Check for fire
        bit $dc00
        bne .notfire
        jmp FireBullet 
.notfire 
        rts
        
        ;Move player up until it has reached its stop zone
        
MovePlayerUp
        lda ObjPos+1 
        sec
        sbc #2 ;Speed 2 * 1
        cmp #UpStopPos
        bcs .storeup
        lda #UpStopPos 
.storeup
        sta ObjPos+1 
        rts 
        
        ;Move player down until it has reached its stop zone
MovePlayerDown
        lda ObjPos+1 
        clc
        adc #2 ;Speed 2 * 1
        cmp #DownStopPos
        bcc .storedown 
        lda #DownStopPos
.storedown
        sta ObjPos+1
        rts 
        
        ;Move player left until it has reached its stop zone 
        
MovePlayerLeft
         lda ObjPos 
         sec
         sbc #1 ;Sprite expanded, so speed has doubled
         cmp #LeftStopPos
         bcs .storeleft
         lda #LeftStopPos
.storeleft         
         sta ObjPos
         rts
         
         ;Move player right until it has reached its stop zone
         
MovePlayerRight
         lda ObjPos
         clc
         adc #1 ;1*1 speed
         cmp #RightStopPos
         bcc .storeright 
         lda #RightStopPos 
.storeright
         sta ObjPos
         rts
         
         ;Player fires bullet - check if the bullet X position is 
         ;at its home position. If so, then allow now bullet firing
         ;unless of course, bullet is dead. 
         
FireBullet
          ;lda PlayerBulletDestroyed 
          ;cmp #1
          ;beq .destroyplayerbullet
         
          lda ObjPos+2  ;If at zero position (by default)
          cmp #$00
          bne .skipshot
          jmp .doplayerfirebullet
.skipshot rts
          
          ;Position bullet where player is 
.doplayerfirebullet
          lda ObjPos
          sta ObjPos+2 ;Player Bullet X to Player X
          lda ObjPos+1
          sec
          sbc #$08
          sta ObjPos+3 ;Player Bullet Y to Player Y
          rts 
          
          ;Player Bullet Control 
          
PlayerBulletProperties
          
          ;lda PlayerBulletDead
          ;cmp #1
          ;beq .donotmovebullet
          
          
          ;Set bullet type 
          jsr FlashPlayerBullet
          lda PlayerBulletFrame
          sta $07f9 
BColSM    ;Player bullet self-mod
          lda #$0d
          sta $d028
          
          ;Fire bullet at lightning speed until it reaches
          ;the outer rim of the game screen
          
          lda ObjPos+3
          sec
          sbc #$09 ;Bullet speed
          cmp #$32 ;Destroy bullet position 
          bcs .storenewbulletposition
          lda #$00
          sta ObjPos+2
         
.storenewbulletposition
          sta ObjPos+3
          rts
          
          ;Flash player bullet colour by reading bullet colour table 
          
FlashPlayerBullet          
          ldx PlayerBulletColourPointer
          lda PlayerBulletColourTable,x
          sta BColSM+1
          inx
          cpx #PlayerBulletColourTableEnd-PlayerBulletColourTable
          beq .loopflash
          inc PlayerBulletColourPointer
          rts
          ;Restart bullet colour colour cycle
.loopflash          
          ldx #0
          stx PlayerBulletColourPointer
          rts
          
        
;Pointers - loads of them
        
ST !byte 0 ;Sync Timer (ST)
ydelay !byte 0 ;Smooth scroll control byte delay
ypos !byte 0  ;Smooth scroll control byte
BGColour1 !byte 0 ;Custom pointer for setting background colour ($d023)
BGColour2 !byte 0 ;                                             ($d022)
LaserTriggerOn !byte 0
LaserTriggerTime !byte 0    
LevelPointer !byte 0 ;Game level pointers

;Sprite animation pointers

SpriteAnimDelay !byte 0 ;Control delay of sprite animation
SpriteAnimPointer !byte 0 ;Controls actual pointer for sprite animation
ExplodeAnimDelay !byte 0
ExplodeAnimPointer !byte 0
PlayerBulletColourPointer !byte 0
;Custom animation pointers 

PlayerType !byte 0
AlienType1 !byte 0
AlienType2 !byte 0
AlienType3 !byte 0
AlienType4 !byte 0
AlienType5 !byte 0
AlienType6 !byte 0
AlienType7 !byte 0
AlienType8 !byte 0

;Self mod Sprite object position table (filled with blank)
ObjPos !fill $11,0

;Sprite Animation frame pointers

;Animation frame for player ship
PlayerShipFrame
  !byte $80,$81,$82,$83
PlayerBulletFrame
  !byte $84,$84,$84,$84
ExplosionFrame 
  !byte $85,$86,$87,$88,$89,$8a,$8b
;Pink rotary robot  
AlienType1Frame 
  !byte $8c,$8d,$8e,$8f 
Alien1TypeColour
  !byte $0a
;Green laser bot  
AlienType2Frame
  !byte $90,$91,$92,$93
AlienType2Colour 
  !byte $05
;Cyan hoverbot  
AlienType3Frame
  !byte $94,$95,$96,$97
AlienType3Colour
  !byte $03  
;Purple disc  
AlienType4Frame
  !byte $98,$99,$98,$99
AlienType4Colour
  !byte $04  
;Blue laser square  
AlienType5Frame
  !byte $9a,$9b,$9c,$9d 
AlienType5Colour
  !byte $0e  
;Yellow Cross Droid
AlienType6Frame
  !byte $9e,$9f,$a0,$a1 
AlienType6Colour
  !byte $07  
;Orange Space Gnu
AlienType7Frame 
  !byte $a2,$a3,$a4,$a5
AlienType7Colour
  !byte $08  
;Washing Machine of Doom
AlienType8Frame 
  !byte $a6,$a7,$a8,$a9
AlienType8Colour  
  !byte $06
   
;Background colour properties for each level change

D022Colour !byte $03,$0a,$0c,$05,$0e
D023Colour !byte $0e,$08,$09,$09,$06 

;Player bullet flashing colour scheme (must be super fast)

PlayerBulletColourTable !byte $09,$02,$08,$0a,$07,$01,$0d,$05,$0e,$04,$06
PlayerBulletColourTableEnd
  
  
    

    
    
    