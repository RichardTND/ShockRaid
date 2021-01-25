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
    
    ;Zero all game pointers. So that alien movement, etc is reset 
    
    ldx #$00
.initialisepointers
    lda #0
    sta GamePointersStart,x
    inx
    cpx #GamePointersEnd-GamePointersStart
    bne .initialisepointers
    jsr SetupNewAlienProperties
    
    lda #0
    sta SpriteAnimDelay
    sta SpriteAnimPointer 
  
    
    
    cli
    jmp GameLoop
    
;Construct main IRQ raster interrupts.

    !source "irq.asm"
    
;------------------------------------------------------------------------------------------------    
    
;Main game loop (controls the main body of the game code)

GameLoop    
      jsr SyncTimer
      jsr ExpandSpritePosition
      jsr AnimSprites
      jsr Scroller
      jsr LaserGate
      jsr PlayerProperties
      jsr AlienProperties
      jmp GameLoop


;------------------------------------------------------------------------------------------------      
      
;Synchronise timer (ST) - game and also merged with some other routines

SyncTimer      
      lda #0
      sta ST
      cmp ST
      beq *-3
.skip rts
      

;------------------------------------------------------------------------------------------------

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
      
      
      
      
      

;------------------------------------------------------------------------------------------------      
      
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

;------------------------------------------------------------------------------------------------        
        
        
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
        

;------------------------------------------------------------------------------------------------        
        
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
    

;------------------------------------------------------------------------------------------------    
          
;Test alien properties (Halve speed)

AlienProperties 
         
.doaliensettings
          lda #0
          sta AlienDelayPointer
          jsr TestAlien1Properties
          jsr TestAlien2Properties
          jsr TestAlien3Properties
          jsr TestAlien4Properties
          jsr TestAlien5Properties
          jsr TestAllAliensOffset
          rts
        
;Test alien properties in order to check to 
;see whether or not the alien is active. If it is 
;inactive, zero position the alien until the waiting
;duration has finished.

TestAlien1Properties
          lda Alien1Offset
          cmp #$01
          bne .alien1notoffset
          lda #0
          sta ObjPos+4  ;Inidicates aliens offset
          sta ObjPos+5
          rts
.alien1notoffset
          lda Alien1Enabled ;Is alien 1 enabled, if not hold it
          cmp #$01
          beq .alien1active 
          jsr HoldAlien1
          rts
          
   ;Alien is active. Allow it to move.
          
.alien1active          
A1Type    lda AlienType1
          sta $07fa 
A1Colour  lda Alien1TypeColour
          sta $d029
A1MoveX   lda F01X  
          sta ObjPos+$04
A1MoveY   lda F01Y
          sta ObjPos+$05 
          inc A1MoveX+1
          inc A1MoveY+1
          lda A1MoveX+1
          beq .endalien1movement
          rts
          
          ;Alien movement has finished
          
.endalien1movement          
          lda #$01
          sta Alien1Offset
          rts
          
          ;Alien held back (alien should always be offset)
HoldAlien1 ;when held back
          lda #0
          sta ObjPos+4
          sta ObjPos+5
          lda Alien1Wait
          cmp #1*16 
          beq .launchalien1
          inc Alien1Wait
          rts
          
          ;Alien gets launched 
.launchalien1          
          lda #1
          sta Alien1Enabled 
          rts
          
          ;------------------
          
          
TestAlien2Properties
          lda Alien2Offset
          cmp #$01
          bne .alien2notoffset
          lda #0
          sta ObjPos+6  ;Inidicates aliens offset
          sta ObjPos+7
          rts
.alien2notoffset
          lda Alien2Enabled ;Is alien 1 enabled, if not hold it
          cmp #$01
          beq .alien2active 
          jsr HoldAlien2
          rts
          
   ;Alien is active. Allow it to move.
          
.alien2active          
A2Type    lda AlienType1
          sta $07fb 
A2Colour  lda Alien1TypeColour
          sta $d02a
A2MoveX   lda F01X  
          sta ObjPos+$06
A2MoveY   lda F01Y
          sta ObjPos+$07 
          inc A2MoveX+1
          inc A2MoveY+1
          lda A2MoveX+1
          beq .endalien2movement
          rts
          
          ;Alien movement has finished
          
.endalien2movement          
          lda #$01
          sta Alien2Offset
          rts
          
          ;Alien held back (alien should always be offset)
HoldAlien2 ;when held back
          lda #0
          sta ObjPos+6
          sta ObjPos+7
          lda Alien2Wait
          cmp #2*16 
          beq .launchalien2
          inc Alien2Wait
          rts
          
          ;Alien gets launched 
.launchalien2          
          lda #1
          sta Alien2Enabled 
          rts
          
          ;------------------
          
          
TestAlien3Properties
          lda Alien3Offset
          cmp #$01
          bne .alien3notoffset
          lda #0
          sta ObjPos+8  ;Inidicates aliens offset
          sta ObjPos+9
          rts
.alien3notoffset
          lda Alien3Enabled ;Is alien 1 enabled, if not hold it
          cmp #$01
          beq .alien3active 
          jsr HoldAlien3
          rts
          
   ;Alien is active. Allow it to move.
          
.alien3active          
A3Type    lda AlienType1
          sta $07fc
A3Colour  lda Alien1TypeColour
          sta $d02b
A3MoveX   lda F01X  
          sta ObjPos+$08
A3MoveY   lda F01Y
          sta ObjPos+$09
          inc A3MoveX+1
          inc A3MoveY+1
          lda A3MoveX+1
          beq .endalien3movement
          rts
          
          ;Alien movement has finished
          
.endalien3movement          
          lda #$01
          sta Alien3Offset
          rts
          
          ;Alien held back (alien should always be offset)
HoldAlien3 ;when held back
          lda #0
          sta ObjPos+8
          sta ObjPos+9
          lda Alien3Wait
          cmp #3*16 
          beq .launchalien3
          inc Alien3Wait
          rts
          
          ;Alien gets launched 
.launchalien3          
          lda #1
          sta Alien3Enabled 
          rts
          
          ;------------------
          
          
TestAlien4Properties
          lda Alien4Offset
          cmp #$01
          bne .alien4notoffset
          lda #0
          sta ObjPos+10  ;Inidicates aliens offset
          sta ObjPos+11
          rts
.alien4notoffset
          lda Alien4Enabled ;Is alien 1 enabled, if not hold it
          cmp #$01
          beq .alien4active 
          jsr HoldAlien4
          rts
          
   ;Alien is active. Allow it to move.
          
.alien4active          
A4Type    lda AlienType1
          sta $07fd
A4Colour  lda Alien1TypeColour
          sta $d02c
A4MoveX   lda F01X  
          sta ObjPos+10
A4MoveY   lda F01Y
          sta ObjPos+11
          inc A4MoveX+1
          inc A4MoveY+1
          lda A4MoveX+1
          beq .endalien4movement
          rts
          
          ;Alien movement has finished
          
.endalien4movement          
          lda #$01
          sta Alien4Offset
          rts
          
          ;Alien held back (alien should always be offset)
HoldAlien4 ;when held back
          lda #0
          sta ObjPos+10
          sta ObjPos+11
          lda Alien4Wait
          cmp #4*16 
          beq .launchalien4
          inc Alien4Wait
          rts
          
          ;Alien gets launched 
.launchalien4          
          lda #1
          sta Alien4Enabled 
          rts
          
           ;------------------
          
          
TestAlien5Properties
          lda Alien5Offset
          cmp #$01
          bne .alien5notoffset
          lda #0
          sta ObjPos+12  ;Inidicates aliens offset
          sta ObjPos+13
          rts
.alien5notoffset
          lda Alien5Enabled ;Is alien 1 enabled, if not hold it
          cmp #$01
          beq .alien5active 
          jsr HoldAlien5
          rts
          
   ;Alien is active. Allow it to move.
          
.alien5active          
A5Type    lda AlienType1
          sta $07fe
A5Colour  lda Alien1TypeColour
          sta $d02d
A5MoveX   lda F01X  
          sta ObjPos+12
A5MoveY   lda F01Y
          sta ObjPos+13
          inc A5MoveX+1
          inc A5MoveY+1
          lda A5MoveX+1
          beq .endalien5movement
          rts
          
          ;Alien movement has finished
          
.endalien5movement          
          lda #$01
          sta Alien5Offset
          rts
          
          ;Alien held back (alien should always be offset)
HoldAlien5 ;when held back
          lda #0
          sta ObjPos+12
          sta ObjPos+13
          lda Alien5Wait
          cmp #5*16 
          beq .launchalien5
          inc Alien5Wait
          rts
          
          ;Alien gets launched 
.launchalien5          
          lda #1
          sta Alien5Enabled 
          rts
          
          ;Test all aliens are offset. If the aliens are still on screen
          ;avoid cycling through the sequence table to generate new aliens.
          ;Otherwise read the sequence table and call the next alien value 
          ;accordingly.
          
TestAllAliensOffset
          ldx #$00
.offsetTest
          lda Alien1Offset,x
          cmp #1
          bne .alienstillvisible
          inx
          cpx #5
          bne .offsetTest
          
          ;All aliens are offset, so now read the next table
          
          jsr SetupNewAlienProperties
          
          ;There are aliens visible, so skip process
          
.alienstillvisible
          rts
          
;Read and store new alien patterns according to the value to be read
;from the sequence table. 

SetupNewAlienProperties
          ldx AlienSequencePointer 
          lda AlienSelectSequence,x 
          sta AlienValuePointer 
          inx
          cpx #AlienSelectSequenceEnd-AlienSelectSequence 
          beq .loopaliensequence
          inc AlienSequencePointer
          jsr SelectNextAlien
          rts
.loopaliensequence          
          ldx #0
          stx AlienSequencePointer
          rts

          ;The next alien selection - picks out low+hi byte for alien type
          ;colour and X, Y movement type values.
          
SelectNextAlien
          ldy AlienValuePointer
          lda AlienTypeLo,y
          sta A1Type+1
          sta A2Type+1
          sta A3Type+1
          sta A4Type+1
          sta A5Type+1
          lda AlienTypeHi,y
          sta A1Type+2
          sta A2Type+2
          sta A3Type+2
          sta A4Type+2
          sta A5Type+2
          lda AlienColourLo,y
          sta A1Colour+1
          sta A2Colour+1
          sta A3Colour+1
          sta A4Colour+1
          sta A5Colour+1
          lda AlienColourHi,y
          sta A1Colour+2
          sta A2Colour+2
          sta A3Colour+2
          sta A4Colour+2
          sta A5Colour+2
          lda AlienXPosLo,y
          sta A1MoveX+1
          sta A2MoveX+1
          sta A3MoveX+1
          sta A4MoveX+1
          sta A5MoveX+1
          lda AlienXPosHi,y 
          sta A1MoveX+2
          sta A2MoveX+2
          sta A3MoveX+2
          sta A4MoveX+2
          sta A5MoveX+2
          lda AlienYPosLo,y
          sta A1MoveY+1
          sta A2MoveY+1
          sta A3MoveY+1
          sta A4MoveY+1
          sta A5MoveY+1
          lda AlienYPosHi,y
          sta A1MoveY+2
          sta A2MoveY+2
          sta A3MoveY+2
          sta A4MoveY+2
          sta A5MoveY+2
          ldx #0
.resetaliengroup          
          lda #0
          sta AlienPointersStart,x
          inx 
          cpx #AlienPointersEnd-AlienPointersStart
          bne .resetaliengroup
          rts
         
;------------------------------------------------------------------------------------------------          
          
;Pointers - loads of them
BGColour1 !byte 0 ;Custom pointer for setting background colour ($d023)
BGColour2 !byte 0 ;                                             ($d022)
       
GamePointersStart
ST !byte 0 ;Sync Timer (ST)
ydelay !byte 0 ;Smooth scroll control byte delay
ypos !byte 0  ;Smooth scroll control byte

LaserTriggerOn !byte 0
LaserTriggerTime !byte 0    
LevelPointer !byte 0 ;Game level pointers

;Sprite animation pointers

SpriteAnimDelay !byte 0 ;Control delay of sprite animation
SpriteAnimPointer !byte 0 ;Controls actual pointer for sprite animation
ExplodeAnimDelay !byte 0
ExplodeAnimPointer !byte 0
PlayerBulletColourPointer !byte 0

;Player control pointers

;Alien control pointers 
AlienSequencePointer !byte 0
AlienDelayPointer !byte 0
AlienValuePointer !byte 0

AlienPointersStart 

;Alien offset
Alien1Offset !byte 0
Alien2Offset !byte 0
Alien3Offset !byte 0
Alien4Offset !byte 0
Alien5Offset !byte 0

;Alien waiting control 
Alien1Wait !byte 0
Alien2Wait !byte 0
Alien3Wait !byte 0
Alien4Wait !byte 0
Alien5Wait !byte 0


;Alien released (enabled)
Alien1Enabled !byte 0
Alien2Enabled !byte 0
Alien3Enabled !byte 0
Alien4Enabled !byte 0
Alien5Enabled !byte 0

AlienPointersEnd
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

GamePointersEnd
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
  !byte $98,$99,$9a,$9b
AlienType4Colour
  !byte $04  
;Blue laser square  
AlienType5Frame
  !byte $9c,$9d,$9e,$9f 
AlienType5Colour
  !byte $0e  
;Yellow Cross Droid
AlienType6Frame
  !byte $a0,$a1,$a2,$a3 
AlienType6Colour
  !byte $07  
;Orange Space Gnu
AlienType7Frame 
  !byte $a4,$a5,$a6,$a7
AlienType7Colour
  !byte $08  
;Washing Machine of Doom
AlienType8Frame 
  !byte $a8,$a9,$aa,$ab
AlienType8Colour  
  !byte $06
   
;Background colour properties for each level change

D022Colour !byte $03,$0a,$0c,$05,$0e
D023Colour !byte $0e,$08,$09,$09,$06 

;Player bullet flashing colour scheme (must be super fast)

PlayerBulletColourTable !byte $09,$02,$08,$0a,$07,$01,$0d,$05,$0e,$04,$06
PlayerBulletColourTableEnd
  
;Sequence tables for alien type (Using LO/HI byte values)

AlienTypeLo !byte <AlienType1, <AlienType2, <AlienType3, <AlienType4
            !byte <AlienType5, <AlienType6, <AlienType7, <AlienType8
            !byte <AlienType1, <AlienType2, <AlienType3, <AlienType4
            !byte <AlienType5, <AlienType6, <AlienType7, <AlienType8
            
AlienTypeHi !byte >AlienType1, >AlienType2, >AlienType3, >AlienType4
            !byte >AlienType5, >AlienType6, >AlienType7, >AlienType8
            !byte >AlienType1, >AlienType2, >AlienType3, >AlienType4
            !byte >AlienType5, >AlienType6, >AlienType7, >AlienType8
            
;Sequence tables for alien colour (using LO/HI byte values)

AlienColourLo !byte <Alien1TypeColour, <AlienType2Colour, <AlienType3Colour, <AlienType4Colour
              !byte <AlienType5Colour, <AlienType6Colour, <AlienType7Colour, <AlienType8Colour
              !byte <Alien1TypeColour, <AlienType2Colour, <AlienType3Colour, <AlienType4Colour
              !byte <AlienType5Colour, <AlienType6Colour, <AlienType7Colour, <AlienType8Colour
              
AlienColourHi !byte >Alien1TypeColour, >AlienType2Colour, >AlienType3Colour, >AlienType4Colour
              !byte >AlienType5Colour, >AlienType6Colour, >AlienType7Colour, >AlienType8Colour
              !byte >Alien1TypeColour, >AlienType2Colour, >AlienType3Colour, >AlienType4Colour
              !byte >AlienType5Colour, >AlienType6Colour, >AlienType7Colour, >AlienType8Colour
                            
;Sequence tables for alien movement data X (using LO/HI byte values)

AlienXPosLo   !byte <F01X, <F02X, <F03X, <F04X
              !byte <F05X, <F06X, <F07X, <F08X
              !byte <F09X, <F10X, <F11X, <F12X
              !byte <F13X, <F14X, <F15X, <F16X

AlienXPosHi   !byte >F01X, >F02X, >F03X, >F04X
              !byte >F05X, >F06X, >F07X, >F08X
              !byte >F09X, >F10X, >F11X, >F12X
              !byte >F13X, >F14X, >F15X, >F16X
              
;Sequence tables for alien movement data Y (using LO/HI byte values)              

AlienYPosLo   !byte <F01Y, <F02Y, <F03Y, <F04Y
              !byte <F05Y, <F06Y, <F07Y, <F08Y
              !byte <F09Y, <F10Y, <F11Y, <F12Y
              !byte <F13Y, <F14Y, <F15Y, <F16Y

AlienYPosHi   !byte >F01Y, >F02Y, >F03Y, >F04Y
              !byte >F05Y, >F06Y, >F07Y, >F08Y
              !byte >F09Y, >F10Y, >F11Y, >F12Y
              !byte >F13Y, >F14Y, >F15Y, >F16Y
 
;Sequence selection test data - 12 selections per level                

AlienSelectSequence              
              !byte $01,$02,$01,$03,$02,$01,$03,$04,$02,$03,$01,$03 ;Sequence for level 1
              !byte $02,$06,$03,$04,$05,$08,$03,$07,$05,$03,$05,$07 ;Sequence for level 2
              !byte $09,$0a,$04,$07,$02,$03,$01,$0b,$0c,$05,$0a,$07 ;Sequence for level 3
              !byte $0d,$0b,$0c,$09,$0a,$0e,$0a,$0b,$0e,$09,$0f,$0d ;Sequence for level 4
              !byte $0f,$0a,$0c,$0e,$0b,$0d,$09,$0a,$0d,$0b,$0c,$0f ;(Just incase amount is too short)
              
AlienSelectSequenceEnd
    
    
    