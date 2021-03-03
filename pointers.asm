
;In game pointers
;****************

;Pal NTSC system 
system !byte 0

;NTSC Timer for music playing 
NTSCTimer !byte 0

;Player control (Fire button) prevent autofire

FireButton !byte 0
   
;Pointers - loads of them
BGColour1 !byte 0 ;Custom pointer for setting background colour ($d023)
BGColour2 !byte 0 ;                                             ($d022)
       
GameOverIsOn !byte 0 

GamePointersStart
ST !byte 0 ;Sync Timer (ST)
ypos !byte 0  ;Smooth scroll control byte

LaserTriggerOn !byte 0
LaserTriggerTime !byte 0    
LevelPointer !byte 0 ;Game level pointers

;Scroller temp pointers

ScrollCharTemp !byte 0
ScrollCharTemp2 !byte 0
ScrollCharTemp3 !byte 0
ScrollCharTemp4 !byte 0

;Sprite animation pointers
BlankSprite !byte $d5
SpriteAnimDelay !byte 0 ;Control delay of sprite animation
SpriteAnimPointer !byte 0 ;Controls actual pointer for sprite animation
ExplodeAnimDelay !byte 0
ExplodeAnimPointer !byte 0
PlayerBulletColourPointer !byte 0
PlayerBulletDestroyed !byte 0
ShieldTime !byte 0
ShieldFlashPointer !byte 0
Lives !byte 0

;Alien bullet properties
AlienBulletWaitTime !byte 0
AlienSelected !byte 0 

;Player control pointers

;Alien control pointers 
AlienSequencePointer !byte 0
AlienDelayPointer !byte 0
AlienValuePointer !byte 0
AlienRandomPointer !byte 0

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

;Alien dead (corresponds to sprite/sprite collision) 

Alien1Dead    !byte 0
Alien2Dead    !byte 0
Alien3Dead    !byte 0
Alien4Dead    !byte 0
Alien5Dead    !byte 0

;Alien death delay pointers 

Alien1DeathDelay !byte 0
Alien1DeathPointer !byte 0
Alien2DeathDelay !byte 0
Alien2DeathPointer !byte 0
Alien3DeathDelay !byte 0
Alien3DeathPointer !byte 0
Alien4DeathDelay !byte 0
Alien4DeathPointer !byte 0
Alien5DeathDelay !byte 0
Alien5DeathPointer !byte 0



AlienPointersEnd
;Custom animation pointers 

SpriteFrameStart
PlayerType !byte 0
AlienType1 !byte 0
AlienType2 !byte 0
AlienType3 !byte 0
AlienType4 !byte 0
AlienType5 !byte 0
AlienType6 !byte 0
AlienType7 !byte 0
AlienType8 !byte 0
AlienType9 !byte 0
AlienType10 !byte 0
AlienType11 !byte 0
AlienType12 !byte 0
AlienType13 !byte 0
AlienType14 !byte 0
AlienType15 !byte 0
AlienType16 !byte 0
CrystalTopLeft !byte 0
CrystalTopRight !byte 0
CrystalBottomLeft !byte 0
CrystalBottomRight !byte 0
GamePointersEnd !byte 0
SpriteFrameEnd
!byte $d5


;Self mod Sprite object position table (filled with blank)
ObjPos !byte $00,$00,$00,$00,$00,$00,$00,$00
       !byte $00,$00,$00,$00,$00,$00,$00,$00
ColliderPlayer !byte $00,$00,$00,$00
ColliderBullet !byte $00,$00,$00,$00
;Sprite Animation frame pointers

;Animation frame for player ship
PlayerShipFrame
  !byte $80,$81,$82,$83
PlayerBulletFrame
  !byte $84,$84,$84,$84

;-------------------------------
;Alien group - LEVEL 1  
  
;Cyan laser burger
AlienType1Frame 
  !byte $90,$91,$92,$93
AlienType1FrameColour 
  !byte $03,$03,$03,$03
Alien1TypeColour
  !byte $03
  
;Cyan laser burger 
AlienType2Frame
  !byte $98,$99,$9a,$9b
AlienType2FrameColour 
  !byte $02,$02,$02,$02  
AlienType2Colour 
  !byte $02
  
;Blue Telephone Box
AlienType3Frame
  !byte $a0,$a1,$a2,$a3
AlienType3FrameColour 
  !byte $06,$06,$06,$06  
AlienType3Colour
  !byte $06
  
;Grey planetoid
AlienType4Frame
  !byte $9c,$9d,$9e,$9f
AlienType4FrameColour 
  !byte $0f,$0f,$0f,$0f
AlienType4Colour
  !byte $0f
;-------------------------  

;Alien group: LEVEL 2

;Gren bug
AlienType5Frame
  !byte $b0,$b1,$b2,$b3
AlienType5FrameColour 
  !byte $05,$05,$03,$03
AlienType5Colour
  !byte $05
  
;Yellow bug
AlienType6Frame
  !byte $b4,$b5,$b6,$b7
AlienType6FrameColour 
  !byte $07,$07,$07,$07
AlienType6Colour
  !byte $07  
  
;Cyan/Yellow bug

AlienType7Frame 
  !byte $bc,$bd,$be,$bf
AlienType7FrameColour 
  !byte $03,$03,$07,$07
AlienType7Colour
  !byte $07
  
;Red Jellyfish bug
AlienType8Frame 
  !byte $c0,$c1,$c2,$c3
AlienType8FrameColour 
  !byte $02,$02,$02,$02 
AlienType8Colour  
  !byte $02
;-------------------------
;Group: LEVEL 3 

;Grey pyramid
AlienType9Frame 
  !byte $a4,$a5,$a6,$a7
AlienType9FrameColour 
  !byte $0f,$0f,$0f,$0f
AlienType9Colour
  !byte $0f 
  
;Grey rocking ship
AlienType10Frame 
  !byte $b8,$b9,$ba,$bb 
AlienType10FrameColour 
  !byte $0f,$0f,$0f,$0f
AlienType10Colour  
  !byte $0f 
  
;Green bug ship
AlienType11Frame 
  !byte $c4,$c5,$c6,$c7 
AlienType11FrameColour 
  !byte $05,$05,$05,$05
AlienType11Colour
  !byte $05
  
;Grey extracting ball
AlienType12Frame
  !byte $c8,$c9,$ca,$cb
AlienType12FrameColour
  !byte $0f,$0f,$0f,$0f
AlienType12Colour
  !byte $0f
  
;------------------------

;Alien group LEVEL 4
  
;Red curved ship
AlienType13Frame 
  !byte $8c,$8c,$8c,$8c 
AlienType13FrameColour 
  !byte $02,$02,$02,$02
AlienType13Colour
  !byte $02 
  
;Red spinning disc
AlienType14Frame 
  !byte $ac,$ad,$ae,$af
AlienType14FrameColour 
  !byte $02,$02,$02,$02
AlienType14Colour  
  !byte $02
  
;Blue droid ship
AlienType15Frame
  !byte $a8,$a9,$aa,$ab
AlienType15FrameColour 
  !byte $0e,$0e,$0e,$0e
AlienType15Colour
  !byte $0e
  
;Orange orb
AlienType16Frame
  !byte $94,$95,$96,$97
AlienType16FrameColour 
  !byte $08,$08,$08,$08

AlienType16Colour 
  !byte $08

;Alien bullet (Just a single frame)
AlienTypeBullet
  !byte $cc 
AlienTypeBulletColour
  !byte $07
  
LetterG !byte $cd
LetterA !byte $ce
LetterM !byte $cf
LetterE !byte $d0 
LetterO !byte $d1
LetterV !byte $d2 
LetterR !byte $d4

PlayerExplosionLeft !byte $d8,$d9
PlayerExplosionRight !byte $da,$db
  
GameOverSprites
        !byte $cd,$ce,$cf,$d0,$d1,$d2,$d3,$d4
  
GameOverPosition
        !byte $40,$60,$50,$60,$60,$60,$70,$60 
        !byte $40,$80,$50,$80,$60,$80,$70,$80 
        
  
ExplosionFrame !byte $85,$86,$87,$88,$89,$8a,$8b,$d5
ExplosionFrameEnd !byte $d5
ExplosionColour
               !byte $08,$0a,$0f,$07,$0f,$0a,$08,$08
   

CrystalTypeFrame
        !byte $dd,$de,$dd,$de 
Crystal !byte 0               
               
;Player shield flash colour (will be fast flashing)

ShieldFlashColour
               !byte $01,$03,$01,$03,$01,$03,$01
ShieldFlashColourEnd
               !byte $03
               
;Background colour properties for each level change

D022Colour !byte $03,$0d,$08,$0f,$0e
D023Colour !byte $0e,$05,$09,$0b,$06 

;Player bullet flashing colour scheme (must be super fast)

PlayerBulletColourTable !byte $09,$02,$08,$0a,$07,$01,$0d,$05,$0e,$04,$06
PlayerBulletColourTableEnd
  


;Sequence tables for alien type (Using LO/HI byte values)
AlienTypeLo !byte <AlienType1, <AlienType2, <AlienType3, <AlienType4
            !byte <AlienType5, <AlienType6, <AlienType7, <AlienType8
            !byte <AlienType9, <AlienType10, <AlienType11, <AlienType12
            !byte <AlienType13, <AlienType14, <AlienType15, <AlienType16
            !byte <AlienType16, <AlienType16
            
AlienTypeHi !byte >AlienType1, >AlienType2, >AlienType3, >AlienType4
            !byte >AlienType5, >AlienType6, >AlienType7, >AlienType8
            !byte >AlienType9, >AlienType10, >AlienType11, >AlienType12
            !byte >AlienType13, >AlienType14, >AlienType15, >AlienType16
            !byte >AlienType16, >AlienType16
;Sequence tables for alien colour (using LO/HI byte values)
AlienColourLo !byte <Alien1TypeColour, <AlienType2Colour, <AlienType3Colour, <AlienType4Colour
              !byte <AlienType5Colour, <AlienType6Colour, <AlienType7Colour, <AlienType8Colour
              !byte <AlienType9Colour, <AlienType10Colour, <AlienType11Colour, <AlienType12Colour
              !byte <AlienType13Colour, <AlienType14Colour, <AlienType15Colour, <AlienType16Colour
              !byte <AlienType16Colour, <AlienType16Colour
              
AlienColourHi !byte >Alien1TypeColour, >AlienType2Colour, >AlienType3Colour, >AlienType4Colour
              !byte >AlienType5Colour, >AlienType6Colour, >AlienType7Colour, >AlienType8Colour
              !byte >AlienType9Colour, >AlienType10Colour, >AlienType11Colour, >AlienType12Colour
              !byte >AlienType13Colour, >AlienType14Colour, >AlienType15Colour, >AlienType16Colour
              !byte >AlienType16Colour, >AlienType16Colour
AlienScoreRangeLo 
              !byte <ScoreRange1, <ScoreRange1, <ScoreRange1, <ScoreRange1 
              !byte <ScoreRange2, <ScoreRange2, <ScoreRange2, <ScoreRange2
              !byte <ScoreRange3, <ScoreRange3, <ScoreRange3, <ScoreRange3
              !byte <ScoreRange4, <ScoreRange4, <ScoreRange4, <ScoreRange4
              !byte <ScoreRange4, <ScoreRange4
              
AlienScoreRangeHi
             
              !byte >ScoreRange1, >ScoreRange1, >ScoreRange1, >ScoreRange1 
              !byte >ScoreRange2, >ScoreRange2, >ScoreRange2, >ScoreRange2
              !byte >ScoreRange3, >ScoreRange3, >ScoreRange3, >ScoreRange3
              !byte >ScoreRange4, >ScoreRange4, >ScoreRange4, >ScoreRange4
              !byte >ScoreRange4, >ScoreRange4
              
                            
;Sequence tables for alien movement data X (using LO/HI byte values)
AlienXPosLo   !byte <F01X, <F02X, <F03X, <F04X
              !byte <F05X, <F06X, <F07X, <F08X
              !byte <F09X, <F10X, <F11X, <F12X
              !byte <F13X, <F14X, <F15X, <F16X, <BlankFormation

AlienXPosHi   !byte >F01X, >F02X, >F03X, >F04X
              !byte >F05X, >F06X, >F07X, >F08X
              !byte >F09X, >F10X, >F11X, >F12X
              !byte >F13X, >F14X, >F15X, >F16X, >BlankFormation
              
;Sequence tables for alien movement data Y (using LO/HI byte values)              
AlienYPosLo   !byte <F01Y, <F02Y, <F03Y, <F04Y
              !byte <F05Y, <F06Y, <F07Y, <F08Y
              !byte <F09Y, <F10Y, <F11Y, <F12Y
              !byte <F13Y, <F14Y, <F15Y, <F16Y, <BlankFormation

AlienYPosHi   !byte >F01Y, >F02Y, >F03Y, >F04Y
              !byte >F05Y, >F06Y, >F07Y, >F08Y
              !byte >F09Y, >F10Y, >F11Y, >F12Y
              !byte >F13Y, >F14Y, >F15Y, >F16Y, >BlankFormation
              
;256 byte random table to select which alien to fire bullet (if present)

              
RandTable     !byte 5,1,3,2,4,1,5,1,2,3,1,4,1,5,3,1,2,5,3,1,3,4,2,1,5,1,3,1,4,2,4,1,2,4
              !byte 1,5,3,2,4,3,5,1,2,4,5,2,4,3,1,5,2,4,3,1,4,3,5,1,2,5,4,3,4,1,2,5,4,1
              !byte 2,1,4,3,4,1,2,4,3,1,3,4,1,2,4,1,4,3,5,1,2,4,5,1,5,3,2,4,5,1,3,2,2,3
              !byte 4,3,1,3,2,5,1,3,2,5,1,4,3,5,1,2,4,3,5,1,3,5,2,1,5,3,4,1,2,4,5,3,1,5
              !byte 4,3,1,3,2,5,1,3,2,5,1,4,3,5,1,2,4,3,5,1,3,5,2,1,5,3,4,1,2,4,5,3,1,5
              
 
;Sequence selection test data - 12 selections per level                

;Alien amount per level: 
              
;LEVEL 1 = 15
;LEVEL 2 = 16
;LEVEL 3 = 14
;LEVEL 4 = 14

AlienSelectSequence              
              ;Sequence 1 - 14 waves - Blank 
              ;$10 = blank formation 
              !byte $10,$00,$03,$01,$02,$03,$02,$01,$00,$01,$03,$01,$02,$00,$10
              ;Sequence 2 - 16 waves
              !byte $04,$06,$05,$07,$04,$07,$05,$06,$04,$07,$06,$04,$05,$06,$07,$10
              ;Sequence 3 - 14 waves 
              !byte $08,$0a,$0b,$09,$08,$0b,$0a,$09,$08,$0b,$0a,$09,$10
              ;Sequence 4 - 14 waves 
              !byte $0d,$0f,$0e,$0c,$0e,$0f,$0e,$0d,$0f,$0e,$0d,$0f,$10,$10 
              
AlienSelectSequenceEnd
    

;Screen pointers (lo-hi byte settings)

screenlo      !byte $00,$28,$50,$78,$a0,$c8,$f0,$18,$40,$68,$90,$b8
              !byte $e0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98 
              !byte $c0
              
screenhi      !byte $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05
              !byte $05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07
              !byte $07
              
!align $100,0
startscreen   !bin "bin\startscreen.bin"