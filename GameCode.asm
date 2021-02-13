;#############################
;#        Shock Raid         #
;#                           #
;#     by Richard Bayliss    #
;#                           #
;# (C)2021 The New Dimension #
;#     For Reset Magazine    #
;#############################

;Main game code
Game 
NewLevelStart
    
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
    ldx #<nmi 
    ldy #>nmi
    stx $fffa
    sty $fffb
    ldx #$00
.sidout
    lda #0
    sta $d400,x
    inx
    cpx #$18
    bne .sidout
    
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
    sta FireButton
    sta $e1 ;Init slow anim zeropage
    
    
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
    lda startscreen,x
    sta screen,x
    lda startscreen+$100,x
    sta screen+$100,x
    lda startscreen+$200,x
    sta screen+$200,x
    lda startscreen+$2e8,x
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
    cpx #240-40 
    bne .drawhud
    
    ldx #$00
.colourhud    
    ldy hud,x
    lda hudattribs,y 
    sta colour+$2f8+40,x
    inx
    cpx #240-40
    bne .colourhud
   
    ;Zero points
    
    ldx #$00
.zeroscore
    lda #$30
    sta Score,x 
    inx
    cpx #$05
    bne .zeroscore
    
    lda #$39 ;Nine shields
    sta Shield
    
    ;Setup the game sprites
    
    lda #$ff
    sta $d015
    sta $d01c
    lda #$0c
    sta $d025
    lda #$0b
    sta $d026
    lda #$03
    sta $d027
    lda #$80
    sta $07f8 ;Sprite 0 HW frame
    lda #$56
    sta ObjPos
    lda #$b8
    sta ObjPos+1
    
    lda #$10
    sta ypos
    lda #0
    sta $d017
    sta $d01d
    sta $d01b
    ldx #$fb
    txs
   
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
    
    lda SoundOption 
    beq .MusicOptionSet
    lda #LevelUpSFX
    jsr SFXInit
.MusicOptionSet    
    lda #GameMusic
    jsr MusicInit
    
    
    ;Zero all game pointers. So that alien movement, etc is reset 
.Continue    
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
    
    ldx #$00
    
    ;Clear all sprite animation frame with blank frames 
    
    ldx #$00
.blankspriteframes
    lda #$ff
    sta SpriteFrameStart,x
    inx
    cpx #SpriteFrameEnd-SpriteFrameStart 
    bne .blankspriteframes
    
  
    ;Reset shield time (100 secs)
    
    lda #100
    sta ShieldTime
    
    cli
    jmp GameLoop
    

    
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
      jsr SpriteToBackground
      jsr SpriteToSprite
      jsr TestShield
      jsr TestEnemyBullet
      jsr SmartBackgroundScroll
      
      ;Check game pause/quit function ... CONTROL = PAUSE, <- = QUIT BACK TO FRONT END (While paused)
      
      lda #4
      bit $dc01
      bne NotPaused
      
      ;Press fire to unpause game
      lda #0
      sta FireButton
.pauseloop      
      lda $dc00
      lsr
      lsr
      lsr
      lsr
      lsr
      bit FireButton
      ror FireButton 
      bmi .pauseloop2 
      bvc .pauseloop2
      lda #0
      sta FireButton 
      jmp .resume 
.pauseloop2      
      lda #2
      bit $dc01
      bne .pauseloop 
      jmp Title
      
.resume      
      
      
NotPaused      
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
      lda AlienType9Frame,x
      sta AlienType9
      lda AlienType10Frame,x
      sta AlienType10 
      lda AlienType11Frame,x
      sta AlienType11
      lda AlienType12Frame,x
      sta AlienType12
      lda AlienType13Frame,x
      sta AlienType13
      lda AlienType14Frame,x
      sta AlienType14
      lda AlienType15Frame,x
      sta AlienType15 
      lda AlienType16Frame,x
      sta AlienType16
      lda CrystalTypeFrame,x 
      sta Crystal
      ;Now do the same for the colour table as some 
      ;sprites use more than one sprite colour 
      ;to give them a cool effect 
      lda AlienType1FrameColour,x
      sta Alien1TypeColour
      lda AlienType2FrameColour,x
      sta AlienType2Colour
      lda AlienType3FrameColour,x
      sta AlienType3Colour
      lda AlienType4FrameColour,x
      sta AlienType4Colour
      lda AlienType5FrameColour,x
      sta AlienType5Colour
      lda AlienType6FrameColour,x
      sta AlienType6Colour
      lda AlienType7FrameColour,x
      sta AlienType7Colour
      lda AlienType8FrameColour,x
      sta AlienType8Colour 
      lda AlienType9FrameColour,x
      sta AlienType9Colour 
      lda AlienType10FrameColour,x
      sta AlienType10Colour
      lda AlienType11FrameColour,x
      sta AlienType11Colour 
      lda AlienType12FrameColour,x
      sta AlienType12Colour 
      lda AlienType13FrameColour,x
      sta AlienType13Colour 
      lda AlienType14FrameColour,x
      sta AlienType14Colour
      lda AlienType15FrameColour,x
      sta AlienType15Colour 
      lda AlienType16FrameColour,x
      sta AlienType16Colour
      
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

ScrollMain      

      ;Main scroll controll routine (this controls the smoothness
      ;of the scroll connected to the interrupt (irq1)
      
      inc ypos
      lda ypos
      cmp #$18
      bpl DoHardScroll
      rts

DoHardScroll
      lda #$10
      sta ypos
      
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
      ldy #$0a
      dey
      bne *-1
      jsr FitRow1
      jsr FitRow2 
      jsr flagcheck
      rts
FitRow1      
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
       rts
FitRow2       
       ldx #$27
ShiftRows2
        lda #fillchar
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
        rts
        
;Finally a simple subroutine that the end of the flag 
flagcheck 

        ldx #$00
.checkflag
        lda row19,x
        cmp #LevelExitChar ;char detection 
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
        sta LevelIndicator
        
        ;Add an extra life to the player 
        
        lda Shield
        cmp #$39
        beq .nobonusshield 
        inc Shield
.nobonusshield    
        jsr Score1000Bonus
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
        lda SoundOption 
        beq .skiplevelupsfx
        lda #LevelUpSFX
        jsr SFXInit
.skiplevelupsfx        
        rts 

;The player has completed the game
        
GameComplete        
        jmp EndScreen
;------------------------------------------------------------------------------------------------        
        
        
;Control the laser gates settings (on/off)

LaserGate
        jsr ScrollLasers
        lda LaserTriggerTime 
        cmp #40
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
        lda LaserGateChars,x
        asl 
        rol LaserGateChars+8,x
        rol LaserGateChars,x
        asl
        rol LaserGateChars+8,x
        rol LaserGateChars,x
        inx
        cpx #$08
        bne .scrolllaserchars
        
        ldx #$00
.scrollmorelaserchars
        lda LaserGateChars+16,x
        asl
        rol LaserGateChars+24,x
        rol LaserGateChars+16,x
        asl
        rol LaserGateChars+24,x
        rol LaserGateChars+16,x
        inx
        cpx #$08
        bne .scrollmorelaserchars
        
SlowAnimPulse
      lda $e1 
      cmp #1
      beq .okscroll
      inc $e1
      rts
.okscroll
      lda #0
      sta $e1 
      ldx #$00
.scrollpulse1
      lda pulsecharleft1,x
      asl 
      rol pulsecharleft2,x
      rol pulsecharleft1,x 
      inx
      cpx #8
      bne .scrollpulse1
      ldx #$00
.scrollpulse2
      lda pulsecharright1,x
      lsr
      ror pulsecharright2,x
      ror pulsecharright1,x
      inx
      cpx #8
      bne .scrollpulse2
      rts
      
        rts
        

;------------------------------------------------------------------------------------------------        
        
;Player control (Joystick read) 

PlayerProperties        

        jsr PlayerBulletProperties ;Also control the player's bullet 
                            
        ;Player is alive, so it is allowed to be controlled.
        
        lda PlayerType
        sta $07f8 
       
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

        ;Read firebutton, but the button is not allowed 
        ;to be held down
        
        lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit FireButton  
        ror FireButton 
        bmi .notfire
        bvc .notfire
        lda #0
        sta FireButton
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
          lda SoundOption 
          beq .skipplayershootsfx
          lda #PlayerShootSFX
          jsr SFXInit
.skipplayershootsfx          
          rts 
          
          
;---------------------------------------------------------          

;Player Bullet Control 
          
PlayerBulletProperties
          
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
          sbc #$0b ;Bullet speed
          cmp #$22 ;Destroy bullet position 
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
          jsr TestAlienBulletToPlayer
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

Alien1Exploder
          lda Alien1DeathDelay
          cmp #1
          beq .explodemain1
          inc Alien1DeathDelay
          rts
.explodemain1
          lda #0
          sta Alien1DeathDelay 
          ldx Alien1DeathPointer 
          lda ExplosionFrame,x
          sta $07fa
          lda #$07
          sta $d029
          inx
          cpx #ExplosionFrameEnd-ExplosionFrame
          beq .stopexplode1
          inc Alien1DeathPointer
          rts
.stopexplode1
          ldx #ExplosionFrameEnd-ExplosionFrame-1
          stx Alien1DeathPointer
          lda #<BlankSprite 
          sta A1Type+1
          lda #>BlankSprite
          sta A1Type+2
          lda #0
          sta Alien1Dead
          rts
          
          
   ;Alien is active. Allow it to move.

.alien1active          
          lda Alien1Dead
          cmp #1
          beq Alien1Exploder
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
          
.alien2explosion
            
Alien2Exploder
          lda Alien2DeathDelay
          cmp #1
          beq .explodemain2
          inc Alien2DeathDelay
          rts
.explodemain2
          lda #0
          sta Alien2DeathDelay 
          ldx Alien2DeathPointer 
          lda ExplosionFrame,x
          sta $07fb
          lda #$07
          sta $d02a
          inx
          cpx #ExplosionFrameEnd-ExplosionFrame
          beq .stopexplode2
          inc Alien2DeathPointer
          rts
.stopexplode2
          ldx #ExplosionFrameEnd-ExplosionFrame-1
          stx Alien2DeathPointer
          lda #<BlankSprite 
          sta A2Type+1
          lda #>BlankSprite
          sta A2Type+2
          lda #0
          sta Alien2Dead
          rts
          
   ;Alien is active. Allow it to move.
          
.alien2active          
          lda Alien2Dead
          cmp #$01
          beq .alien2explosion
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
          
.alienexplosion3
          lda Alien3DeathDelay
          cmp #1
          beq .alien3deathmain
          inc Alien3DeathDelay
          rts
.alien3deathmain
          lda #0
          sta Alien3DeathDelay 
          ldx Alien3DeathPointer
          lda ExplosionFrame,x
          sta $07fc
          lda #$07 
          sta $d02b
           
          inx
          cpx #ExplosionFrameEnd-ExplosionFrame 
          beq .stopexplode3
          inc Alien3DeathPointer
          rts
.stopexplode3
          ldx #ExplosionFrameEnd-ExplosionFrame-1
          stx Alien3DeathPointer
          lda #<BlankSprite 
          sta A3Type+1
          lda #>BlankSprite
          sta A3Type+2
          lda #0
          sta Alien3Dead
          rts
          
          
   ;Alien is active. Allow it to move.
          
.alien3active          
          lda Alien3Dead
          cmp #1
          beq .alienexplosion3
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
          
.explosion04
          lda Alien4DeathDelay
          cmp #1
          beq .explode4main
          inc Alien4DeathDelay 
          rts
.explode4main
          lda #$00
          sta Alien4DeathDelay
          ldx Alien4DeathPointer
          lda ExplosionFrame,x
          sta $07fd
          lda #$07
          sta $d02c
           
          inx
          cpx #ExplosionFrameEnd-ExplosionFrame
          beq .stopexploder4
          inc Alien4DeathPointer
          rts
.stopexploder4
          ldx #ExplosionFrameEnd-ExplosionFrame-1
          stx Alien4DeathPointer
          lda #<BlankSprite 
          sta A4Type+1
          lda #>BlankSprite
          sta A4Type+2
          lda #0
          sta Alien4Dead
          rts
          
          
   ;Alien is active. Allow it to move.
          
.alien4active          
          lda Alien4Dead
          cmp #1
          beq .explosion04
          
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
          
.explosion5
          lda Alien5DeathDelay
          cmp #1
          beq .explode5main
          inc Alien5DeathDelay 
          rts
.explode5main
          lda #$00
          sta Alien5DeathDelay 
          ldx Alien5DeathPointer
          lda ExplosionFrame,x
          sta $07fe
          lda #$07
          sta $d02d
          inx
          cpx #ExplosionFrameEnd-ExplosionFrame
          beq .stopexplode5
          inc Alien5DeathPointer
          rts 
.stopexplode5 
          lda #ExplosionFrameEnd-ExplosionFrame-1
          sta Alien5DeathPointer
          lda #<BlankSprite 
          sta A5Type+1
          lda #>BlankSprite
          sta A5Type+2
          lda #0
          sta Alien5Dead
          rts
          
   ;Alien is active. Allow it to move.
          
.alien5active          
          lda Alien5Dead
          cmp #1
          beq .explosion5
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
          lda AlienScoreRangeLo,y
          sta AwardPoints+1
          lda AlienScoreRangeHi,y
          sta AwardPoints+2
          lda #0
          sta Alien1Dead
          sta Alien2Dead
          sta Alien3Dead
          sta Alien4Dead
          sta Alien5Dead
          ldx #0
.resetaliengroup          
          lda #0
          sta AlienPointersStart,x
          inx 
          cpx #AlienPointersEnd-AlienPointersStart
          bne .resetaliengroup
          
          rts
 
;------------------------------------------------------------------------------------------------

;Sprite to background char collision for the player (if the player hits any 
;deadly background, one shield should be depleted. After all shields are 
;gone. The player is dead

SpriteToBackground 
          
          lda ObjPos+1
          sec
          sbc #$32
          lsr
          lsr
          lsr
          tay
          lda screenlo,y
          sta playerlo
          lda screenhi,y 
          sta playerhi 
          lda ObjPos 
          sec
          sbc #$08
          lsr
          lsr
          tay
          ldx #3
          sty selfmod+1
.bgcloop  jmp CheckCharType
selfmod   ldy #$00
          lda playerlo 
          clc
          adc #40
          sta playerlo 
          bcc skipmod 
          inc playerhi
skipmod   dex
          bne .bgcloop
          rts
          
          ;Check char type ... 
          
CheckCharType
         
          ;Check for laser gate chars 
          lda (playerlo),y
          
          cmp #LaserGateChar1
          beq LaserGateCollisionTest 
          cmp #LaserGateChar2
          beq LaserGateCollisionTest 
          cmp #LaserGateChar3
          beq LaserGateCollisionTest 
          cmp #LaserGateChar4
          beq LaserGateCollisionTest
          

          ;Check for killer chars (except for gate, as that was checked beforehand)
         
          cmp #KillerCharsRangeStartGroup1 
          bcc .playersafe1
          cmp #KillerCharsRangeEndGroup2
          bcs .playersafe1
.playersafe1
          cmp #37
          beq .playersafe
          cmp #0
          beq .playersafe
          cmp #120
          beq .playersafe
          cmp #121
          beq .playersafe
          cmp #122
          beq .playersafe
          cmp #123
          beq .playersafe
          cmp #124
          beq .playersafe
          cmp #125
          beq .playersafe
         
          jmp PlayerIsHit 
.playersafe
          jmp selfmod
          
          
;Check if the player hits the laser gate 

LaserGateCollisionTest 

          lda LaserTriggerOn
          beq PlayerIsHit
          rts
          
;The player is hit by a killer char or an alien
;check if the player's shield has timed out.
;If it has, delete 1 shield and trigger it 
;to flash. Otherwise destroy the player.

PlayerIsHit
          lda ShieldTime
          cmp #0
          beq .deductshield
          rts
.deductshield
          lda #100
          sta ShieldTime
cheatlives
          dec Shield
          lda Shield
          cmp #$30
          beq GameOver
          lda SoundOption 
          beq .skipgameoversfx
          lda #ShieldHitSFX
          jsr SFXInit
.skipgameoversfx          
          rts
          
;----------------------------------------------------------------------------------------------

;The player is dead, so clear all of the enemies and do a spectactular explosion           
          
GameOver    
          ldx #$00
.clearallenemiesforgameover
          lda BlankSprite
          sta $07f8,x
          lda #$07
          sta $d027,x
          inx
          cpx #$08
          bne .clearallenemiesforgameover
          
          ;Now place all sprites for explosion on to the player ship
          
          ldx #$00
.maskexp  lda ObjPos+1
          sta ObjPos+3,x
          lda ObjPos 
          sta ObjPos+2,x
          inx
          inx
          cpx #$0e 
          bne .maskexp 
          
          ;New Sync Loop for the explosion routine 
          lda #0
          sta ExplodeAnimDelay
          sta ExplodeAnimPointer
          lda SoundOption 
          beq MassExplosionLoop
          lda #PlayerDeathSFX
          jsr SFXInit
          
MassExplosionLoop          
          jsr SyncTimer
          jsr ExpandSpritePosition
          jsr ExplodeAllSprites 
          jsr MoveExploder
          jsr LaserGate
          jmp MassExplosionLoop
          
          ;Explode all sprites animation 
          
ExplodeAllSprites
          lda ExplodeAnimDelay
          cmp #$03
          beq .playerexplodenow
          inc ExplodeAnimDelay 
          rts
.playerexplodenow
          lda #0
          sta ExplodeAnimDelay 
          ldx ExplodeAnimPointer
          lda PlayerExplosionLeft,x
          sta $07f8
          lda PlayerExplosionRight,x
          sta $07f9
          inx
          cpx #2
          beq .finishedExploder
          inc ExplodeAnimPointer 
          rts
.finishedExploder

          ldx #0
          stx ExplodeAnimPointer
          rts 
          
          ;Move out the explosion effect
          
MoveExploder          
          lda ObjPos
          sec
          sbc #2
          cmp #$02
          bcs .onset1
          lda #0
          sta ObjPos+1
.onset1   sta ObjPos
          
          lda ObjPos+2 
          clc
          adc #2
          cmp #$ba
          bcc .onset2 
          lda #0
          sta ObjPos+3
.onset2          
          sta ObjPos+2
          
          ;Check if explosion sprites are offset . If so 
          ;make gameover automatically 
          
          lda ObjPos+1
          beq .obj2out
          rts
.obj2out  lda ObjPos+3
          beq .isgameover
          rts
          
.isgameover          
          ;Display the GAME OVER text sprites 
          
          
          lda #$00
          sta $d015
          ldx #0
zeropos   lda #0
          sta $d000,x
          sta ObjPos,x 
        
          inx
          cpx #$10
          bne zeropos
          ldx #$00
SetGOPosition
          lda GameOverPosition,x
          sta ObjPos,x
          inx
          cpx #$10
          bne SetGOPosition
          
          ldx #$00
.putgameover
          lda GameOverSprites,x
          sta $07f8,x
          lda #$08
          sta $d027,x
          inx
          cpx #$08
          bne .putgameover
          lda SoundOption 
          beq .skipgameoversound
          lda #GameOverSFX 
          jsr SFXInit
.skipgameoversound          
          lda #0
          sta FireButton
          lda #$ff
          sta $d015 
          lda #GameOverJingle
          jsr MusicInit
          lda #$0c
          sta BGColour1
          lda #$0b
          sta BGColour2
          
GameOverLoop        
          jsr SyncTimer
           
          jsr ExpandSpritePosition
          jsr LaserGate
          lda $dc00 
          lsr
          lsr
          lsr
          lsr
          lsr
          bit FireButton 
          ror FireButton 
          bmi GameOverLoop
          bvc GameOverLoop
          lda #0
          sta FireButton 
          jmp CheckForHiScore
          
;-----------------------------------------------------------------------------------------------

;Sprite to sprite collision - for player and bullet 
;then test collision with enemy objects

SpriteToSprite

           ;register player sprite to sprite 
           lda ObjPos
           sec
           sbc #$06 
           sta ColliderPlayer
           clc
           adc #$0c
           sta ColliderPlayer+1
           lda ObjPos+1
           sec
           sbc #$0c
           sta ColliderPlayer+2
           clc
           adc #$18
           sta ColliderPlayer+3
           
           ;Now store for the player bullet collider
           
           lda ObjPos+2
           sec
           sbc #$06
           sta ColliderBullet 
           clc
           adc #$0c 
           sta ColliderBullet+1
           lda ObjPos+3 
           sec
           sbc #$0c
           sta ColliderBullet+2
           clc
           adc #$18
           sta ColliderBullet+3
           
           
           ;Test player to alien 
           
           jsr TestPlayerToAlienCollision
           
           ;Test bullet to alien 
           
           jsr TestBulletToAlien 
           
;Test collision (player to alien)

TestPlayerToAlienCollision

          jsr TestA2P1
          jsr TestA2P2
          jsr TestA2P3
          jsr TestA2P4
          jsr TestA2P5
         
          rts
          
;Generate macro code response, in order to check for 
;the alien's status before calling collision checks
;with the player ship.         

          
!macro alientoplayertest aliendead, aliendeathdelay, aliendeathpointer, alienx, alieny, alienframelo {
  
          lda aliendead
          cmp #1
          beq .nothit

          lda alienx 
          cmp ColliderPlayer
          bcc .nothit
          cmp ColliderPlayer+1
          bcs .nothit 
          lda alieny 
          cmp ColliderPlayer+2 
          bcc .nothit 
          cmp ColliderPlayer+3
          bcs .nothit 
          lda ShieldTime 
          cmp #0
          bne .nothit
          lda alienframelo+1
          cmp #<BlankSprite
          beq .nothit
          lda #0
          sta aliendeathdelay
          sta aliendeathpointer
          lda #1
          sta aliendead
          jsr PlayerIsHit
.nothit          
          rts
}          
          
TestA2P1  +alientoplayertest Alien1Dead, Alien1DeathDelay, Alien1DeathPointer, ObjPos+4, ObjPos+5, A1Type
TestA2P2  +alientoplayertest Alien2Dead, Alien2DeathDelay, Alien2DeathPointer, ObjPos+6, ObjPos+7, A2Type
TestA2P3  +alientoplayertest Alien3Dead, Alien3DeathDelay, Alien3DeathPointer, ObjPos+8, ObjPos+9, A3Type
TestA2P4  +alientoplayertest Alien4Dead, Alien4DeathDelay, Alien4DeathPointer, ObjPos+10, ObjPos+11, A4Type
TestA2P5  +alientoplayertest Alien5Dead, Alien5DeathDelay, Alien5DeathPointer, ObjPos+12, ObjPos+13, A5Type


          ;Test alien to player bullet collision 
          
TestBulletToAlien 

          jsr TestA2B1
          jsr TestA2B2
          jsr TestA2B3
          jsr TestA2B4
          jsr TestA2B5
          rts
          
;Generate macro response that tests alien status before
;testing alien sprite to bullet collision.

!macro alienbullettest aliendead, aliendeathdelay, aliendeathpointer, alienx, alieny, alienframe {
        
        lda aliendead
        cmp #1
        beq .notshot
        
        lda alienx
        cmp ColliderBullet
        bcc .notshot
        cmp ColliderBullet+1
        bcs .notshot 
        lda alieny 
        cmp ColliderBullet+2
        bcc .notshot
        cmp ColliderBullet+3
        bcs .notshot 
        
        ;Aliens should not be destroyed if the bullet is outside the screen
        
        lda ObjPos+2
        cmp #0
        beq .notshot
        lda ObjPos+3
        cmp #$32
        bcc .notshot
        
         ;Aliens should not be destroyed if shot is exploding
        
        lda PlayerBulletDestroyed 
        cmp #1
        beq .notshot
        
        lda alienframe+1
        cmp #<BlankSprite 
        beq .notshot
        lda #<BlankSprite 
        sta alienframe+1
        lda #>BlankSprite 
        sta alienframe+2
        
        lda SoundOption 
        beq .justaddpoints
        
       
        
        lda #AlienDeathSFX 
        jsr SFXInit
.justaddpoints        
         lda #0
        sta aliendeathpointer
        sta aliendeathdelay
        lda #1
        sta aliendead
        jsr AwardPoints
        
        
        ;Home the player's bullet position so that the player can
        ;fire again.
        
        
        lda #0
        sta ObjPos+2
        
.notshot        
        rts
       
        }
      
TestA2B1  +alienbullettest Alien1Dead, Alien1DeathDelay, Alien1DeathPointer, ObjPos+4, ObjPos+5, A1Type 
TestA2B2  +alienbullettest Alien2Dead, Alien2DeathDelay, Alien2DeathPointer, ObjPos+6, ObjPos+7, A2Type 
TestA2B3  +alienbullettest Alien3Dead, Alien3DeathDelay, Alien3DeathPointer, ObjPos+8, ObjPos+9, A3Type 
TestA2B4  +alienbullettest Alien4Dead, Alien4DeathDelay, Alien4DeathPointer, ObjPos+10, ObjPos+11, A4Type 
TestA2B5  +alienbullettest Alien5Dead, Alien5DeathDelay, Alien5DeathPointer, ObjPos+12, ObjPos+13, A5Type 

                 ;Just like with the alien to player collision, assign alien 
                 ;bullet to player collision the same way 
                 
TestAlienBulletToPlayer

                lda ObjPos+14
                cmp ColliderPlayer
                bcc .nobulltoplayer
                cmp ColliderPlayer+1
                bcs .nobulltoplayer 
                lda ObjPos+15
                cmp ColliderPlayer+2
                bcc .nobulltoplayer 
                cmp ColliderPlayer+3 
                bcs .nobulltoplayer
                lda #0
                sta ObjPos+14
                jsr PlayerIsHit
.nobulltoplayer rts
;-----------------------------------------------------------------------------------------------

                  ;Test player's shield. When active during play, the player is left 
                  ;invulnerable for a short period of time. 
TestShield 
                  lda ShieldTime 
                  beq .shieldout
                  dec ShieldTime 
                  ldx ShieldFlashPointer
                  lda ShieldFlashColour,x
                  sta $d027 
                  inx
                  cpx #ShieldFlashColourEnd-ShieldFlashColour
                  beq .shieldloop
                  inc ShieldFlashPointer
                  rts 
.shieldloop       ldx #0
                  stx ShieldFlashPointer
                  rts
.shieldout        lda #0
                  sta ShieldTime
                  lda #$0f
                  sta $d027
                  rts
          
;------------------------------------------------------------------------------------------------
;Scoring routine 

AwardPoints       jmp ScoreRange1
                  
Score1000Bonus    jsr ScorePoints
                  jsr ScorePoints
                  jsr ScorePoints
                  jsr ScorePoints
                  jsr ScorePoints
ScoreRange4       jsr ScorePoints
                  jsr ScorePoints
ScoreRange3       jsr ScorePoints
ScoreRange2       jsr ScorePoints
ScoreRange1       jsr ScorePoints
                  rts
                  
ScorePoints       inc Score+2 ;Units of 100 points
                  ldx #2
.doscore          lda Score,x 
                  cmp #$3a
                  bne .scoreok 
                  lda #$30
                  sta Score,x 
                  inc Score-1,x
.scoreok          dex
                  bne .doscore
                  rts
;------------------------------------------------------------------------------------------------

;Test enemy bullet to fire. After the enemy bullet is offset. Give some time before 
;picking a random. Bullets only go down

TestEnemyBullet 
                  lda AlienTypeBullet
                  sta $07ff
                  lda AlienTypeBulletColour
                  sta $d02e
                  lda ObjPos+14
                  beq .timedspawnbullet
                  lda ObjPos+15
                  clc
                  adc #4
                  sta ObjPos+15
                  cmp #$ca
                  bcc .notoffsetbullet
                  lda #$00
                  sta ObjPos+14
                  sta AlienBulletWaitTime
                  rts 
.notoffsetbullet  sta ObjPos+15          
                  rts
                  
                  ;Wait for bullet wait counter to expire before spawning 
                  ;a new alien bullet
                  
.timedspawnbullet lda AlienBulletWaitTime
                  cmp #30 ;Interval
                  beq .launchnewbullet 
                  inc AlienBulletWaitTime
                  
                  
                  rts
                
                  ;Now reset the wait timer and select the enemy to 
                  ;position the bullet with  
.launchnewbullet                  
                  lda #0
                  sta AlienBulletWaitTime
                  ldx AlienRandomPointer
                  lda RandTable,x
                  sta AlienSelected
                  lda AlienSelected 
                  cmp #1
                  beq .alien1bulletspawncheck1
                  cmp #2
                  beq .alien2bulletspawncheck1
                  cmp #3
                  beq .alien3bulletspawncheck1
                  cmp #4
                  beq .alien4bulletspawncheck1
                  cmp #5
                  beq .alien5bulletspawncheck1 
                  rts 
.alien1bulletspawncheck1 jmp .alien1bulletspawncheck
.alien2bulletspawncheck1 jmp .alien2bulletspawncheck
.alien3bulletspawncheck1 jmp .alien3bulletspawncheck
.alien4bulletspawncheck1 jmp .alien4bulletspawncheck 
.alien5bulletspawncheck1 jmp .alien5bulletspawncheck

                  ;Macro code for checking alien status before 
                  ;spawning a deadly bullet to it.
                  
  !macro spawnbullet aliendead, alienframe, alienposx, alienposy {
    
                  lda aliendead
                  cmp #1
                  beq .cannotspawnyet
                  lda alienframe+1    ;If alien is blank, it is dead
                  cmp #<BlankSprite   ;therefore it should not spawn
                  beq .cannotspawnyet
                  lda alienposx 
                  cmp #$a8 
                  bcs .cannotspawnyet
                  lda alienposy ;Ensure alien is on screen
                  cmp #$3a
                  bcc .cannotspawnyet
                  
                  ;Checks have passed, so spawn alien bullet  
                  ;on to the aliens.
                  
                  lda alienposx
                  sta ObjPos+14
                  lda alienposy 
                  clc
                  adc #8
                  sta ObjPos+15
                  lda SoundOption 
                  beq .cannotspawnyet
                  lda #AlienShootSFX 
                  jsr SFXInit
.cannotspawnyet   rts
   }

.alien1bulletspawncheck
                  +spawnbullet Alien1Dead, A1Type, ObjPos+4, ObjPos+5
.alien2bulletspawncheck                  
                  +spawnbullet Alien2Dead, A2Type, ObjPos+6, ObjPos+7 
.alien3bulletspawncheck
                  +spawnbullet Alien3Dead, A3Type, ObjPos+8, ObjPos+9
.alien4bulletspawncheck
                  +spawnbullet Alien4Dead, A4Type, ObjPos+10, ObjPos+11
.alien5bulletspawncheck
                  +spawnbullet Alien5Dead, A5Type, ObjPos+12, ObjPos+13
                  
                  
;-----------------------------------------------------------------------------------------------                  
                  
  
SmartBackgroundScroll  
                    lda ScrollChar
                    sta $f6
                    ldx #0
.scrollcharloop     lda ScrollChar+1,x
                    sta ScrollChar,x
                    inx
                    cpx #$08
                    bne .scrollcharloop
                    lda $f6
                    sta ScrollChar+7 
                    rts
  
;------------------------------------------------------------------------------------------------          

;Pal / NTSC player

PalNTSCPlayer
                    lda system
                    cmp #1
                    beq .pal
                    inc NTSCTimer
                    lda NTSCTimer
                    cmp #6
                    beq .playerloop
.pal                 jsr MusicPlay
                    rts
.playerloop         lda #0
                    sta NTSCTimer
                    rts
                    
       
;-------------------------------------------------------------------------------------

;Construct main IRQ raster interrupts.

    !source "irq.asm"

;Additional assembly source pointers 

  !source "pointers.asm"
  