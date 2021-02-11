
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
       
GamePointersStart
ST !byte 0 ;Sync Timer (ST)
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
PlayerBulletDestroyed !byte 0
ShieldTime !byte 0
ShieldFlashPointer !byte 0

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
BlankSprite !byte $ff
SpriteFrameEnd
!byte 0
GamePointersEnd
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

;Red electro ship
AlienType1Frame 
  !byte $8c,$8d,$8e,$8f 
Alien1TypeColour
  !byte $02
  
;Cyan laser burger 
AlienType2Frame
  !byte $90,$91,$92,$93
AlienType2Colour 
  !byte $03
  
;Orange / bronze cylinder droid
AlienType3Frame
  !byte $94,$95,$96,$97
  
AlienType3Colour
  !byte $08
  
;Red metalic cylinder
AlienType4Frame
  !byte $98,$99,$9a,$9b
AlienType4Colour
  !byte $02
  
;Grey planetoid
AlienType5Frame
  !byte $9c,$9d,$9e,$9f 
AlienType5Colour
  !byte $0f
  
;Blue tardis booth
AlienType6Frame
  !byte $a0,$a1,$a2,$a3 
AlienType6Colour
  !byte $06  
  
;Silver pulsating ship

AlienType7Frame 
  !byte $a4,$a5,$a6,$a7
AlienType7Colour
  !byte $0f
  
;Light blue alien space ship
AlienType8Frame 
  !byte $a8,$a9,$aa,$ab
AlienType8Colour  
  !byte $0e
  
;Red spinning disc
AlienType9Frame 
  !byte $ac,$ad,$ae,$af
AlienType9Colour
  !byte $02
  
;Green bug
AlienType10Frame 
  !byte $b0,$b1,$b2,$b3 
AlienType10Colour  
  !byte $05 ;!TO DO, special routine to detect this alien so it can change colour in animation
  
;Yellow firefly
AlienType11Frame 
  !byte $b4,$b5,$b6,$b7 
AlienType11Colour
  !byte $07
  
;Grey rocker
AlienType12Frame
  !byte $b8,$b9,$ba,$bb 
AlienType12Colour
  !byte $0f
  
;Cyan bug
AlienType13Frame 
  !byte $bc,$bd,$be,$bf 
AlienType13Colour
  !byte $03 
  
;Red jelly fish
AlienType14Frame 
  !byte $c0,$c1,$c2,$c3
AlienType14Colour  
  !byte $02
  
;Green bug invader
AlienType15Frame
  !byte $c4,$c5,$c6,$c7 
AlienType15Colour
  !byte $05
  
;Silver exploding football
AlienType16Frame
  !byte $c8,$c9,$ca,$cb 
AlienType16Colour 
  !byte $0f

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
        
CrystalTopLeftFrame
        !byte $dd,$de,$dd,$de 
CrystalTopRightFrame
        !byte $df,$e0,$df,$e0 
CrystalBottomLeftFrame
        !byte $e1,$e2,$e1,$e2
CrystalBottomRightFrame
        !byte $e3,$e4,$e3,$e4
       
  
ExplosionFrame !byte $85,$86,$87,$88,$89,$8a,$8b,$ff 
ExplosionFrameEnd !byte $ff
ExplosionColour
               !byte $08,$0a,$0f,$07,$0f,$0a,$08,$ff
   
;Player shield flash colour (will be fast flashing)

ShieldFlashColour
               !byte $01,$03,$01,$03,$01,$03,$01
ShieldFlashColourEnd
               !byte $03
               
;Background colour properties for each level change

D022Colour !byte $03,$0a,$0c,$05,$0e
D023Colour !byte $0e,$08,$09,$09,$06 

;Player bullet flashing colour scheme (must be super fast)

PlayerBulletColourTable !byte $09,$02,$08,$0a,$07,$01,$0d,$05,$0e,$04,$06
PlayerBulletColourTableEnd
  
;Sequence tables for alien type (Using LO/HI byte values)
AlienTypeLo !byte <AlienType1, <AlienType2, <AlienType3, <AlienType4
            !byte <AlienType5, <AlienType6, <AlienType7, <AlienType8
            !byte <AlienType9, <AlienType10, <AlienType11, <AlienType12
            !byte <AlienType13, <AlienType14, <AlienType15, <AlienType16
            !byte <AlienType16
            
AlienTypeHi !byte >AlienType1, >AlienType2, >AlienType3, >AlienType4
            !byte >AlienType5, >AlienType6, >AlienType7, >AlienType8
            !byte >AlienType9, >AlienType10, >AlienType11, >AlienType12
            !byte >AlienType13, >AlienType14, >AlienType15, >AlienType16
            !byte >AlienType16
;Sequence tables for alien colour (using LO/HI byte values)
AlienColourLo !byte <Alien1TypeColour, <AlienType2Colour, <AlienType3Colour, <AlienType4Colour
              !byte <AlienType5Colour, <AlienType6Colour, <AlienType7Colour, <AlienType8Colour
              !byte <AlienType9Colour, <AlienType10Colour, <AlienType11Colour, <AlienType12Colour
              !byte <AlienType13Colour, <AlienType14Colour, <AlienType15Colour, <AlienType16Colour
              !byte <AlienType16Colour
              
AlienColourHi !byte >Alien1TypeColour, >AlienType2Colour, >AlienType3Colour, >AlienType4Colour
              !byte >AlienType5Colour, >AlienType6Colour, >AlienType7Colour, >AlienType8Colour
              !byte >AlienType9Colour, >AlienType10Colour, >AlienType11Colour, >AlienType12Colour
              !byte >AlienType13Colour, >AlienType14Colour, >AlienType15Colour, >AlienType16Colour
              !byte >AlienType16Colour
AlienScoreRangeLo 
              !byte <ScoreRange1, <ScoreRange1, <ScoreRange1, <ScoreRange1 
              !byte <ScoreRange2, <ScoreRange2, <ScoreRange2, <ScoreRange2
              !byte <ScoreRange3, <ScoreRange3, <ScoreRange3, <ScoreRange3
              !byte <ScoreRange4, <ScoreRange4, <ScoreRange4, <ScoreRange4
              !byte <ScoreRange4
              
AlienScoreRangeHi
             
              !byte >ScoreRange1, >ScoreRange1, >ScoreRange1, >ScoreRange1 
              !byte >ScoreRange2, >ScoreRange2, >ScoreRange2, >ScoreRange2
              !byte >ScoreRange3, >ScoreRange3, >ScoreRange3, >ScoreRange3
              !byte >ScoreRange4, >ScoreRange4, >ScoreRange4, >ScoreRange4
              !byte >ScoreRange4
              
                            
;Sequence tables for alien movement data X (using LO/HI byte values)
AlienXPosLo   !byte <F01X, <F02X, <F03X, <F04X
              !byte <F05X, <F06X, <F07X, <F08X
              !byte <F09X, <F10X, <F11X, <F12X
              !byte <F13X, <F14X, <F15X, <F16X, <F16X

AlienXPosHi   !byte >F01X, >F02X, >F03X, >F04X
              !byte >F05X, >F06X, >F07X, >F08X
              !byte >F09X, >F10X, >F11X, >F12X
              !byte >F13X, >F14X, >F15X, >F16X, >F16X
              
;Sequence tables for alien movement data Y (using LO/HI byte values)              
AlienYPosLo   !byte <F01Y, <F02Y, <F03Y, <F04Y
              !byte <F05Y, <F06Y, <F07Y, <F08Y
              !byte <F09Y, <F10Y, <F11Y, <F12Y
              !byte <F13Y, <F14Y, <F15Y, <F16Y, <F16Y

AlienYPosHi   !byte >F01Y, >F02Y, >F03Y, >F04Y
              !byte >F05Y, >F06Y, >F07Y, >F08Y
              !byte >F09Y, >F10Y, >F11Y, >F12Y
              !byte >F13Y, >F14Y, >F15Y, >F16Y, >F16Y
              
;256 byte random table to select which alien to fire bullet (if present)

RandTable     !byte 5,1,3,2,4,1,5,1,2,3,1,4,1,5,3,1,2,5,3,1,3,4,2,1,5,1,3,1,4,2,4,1,2,4
              !byte 1,5,3,2,4,3,5,1,2,4,5,2,4,3,1,5,2,4,3,1,4,3,5,1,2,5,4,3,4,1,2,5,4,1
              !byte 2,1,4,3,4,1,2,4,3,1,3,4,1,2,4,1,4,3,5,1,2,4,5,1,5,3,2,4,5,1,3,2,2,3
              !byte 4,3,1,3,2,5,1,3,2,5,1,4,3,5,1,2,4,3,5,1,3,5,2,1,5,3,4,1,2,4,5,3,1,5
              !byte 4,3,1,3,2,5,1,3,2,5,1,4,3,5,1,2,4,3,5,1,3,5,2,1,5,3,4,1,2,4,5,3,1,5
              
 
;Sequence selection test data - 12 selections per level                
AlienSelectSequence              
              !byte $01,$02,$00,$03,$02,$01,$03,$04,$00,$03,$01,$03 ;Sequence for level 1
              !byte $02,$06,$03,$00,$05,$08,$03,$07,$05,$03,$05,$07 ;Sequence for level 2
              !byte $09,$0a,$04,$07,$02,$03,$01,$0b,$0c,$05,$0a,$07 ;Sequence for level 3
              !byte $0d,$0b,$0c,$09,$0a,$0e,$0a,$0b,$0e,$09,$0f,$0d ;Sequence for level 4
              !byte $0f,$0a,$0c,$0e,$0b,$0d,$09,$0a,$0d,$0b,$0c,$0f ;(Just incase amount is too short)
              
AlienSelectSequenceEnd
    

;Screen pointers (lo-hi byte settings)

screenlo      !byte $00,$28,$50,$78,$a0,$c8,$f0,$18,$40,$68,$90,$b8
              !byte $e0,$08,$30,$58,$80,$a8,$d0,$f8,$20,$48,$70,$98 
              !byte $c0
              
screenhi      !byte $04,$04,$04,$04,$04,$04,$04,$05,$05,$05,$05,$05
              !byte $05,$06,$06,$06,$06,$06,$06,$06,$07,$07,$07,$07
              !byte $07
              
!align $100,0
 
;Import game start screen
startscreen
  !bin "bin\startscreen.bin"              
  