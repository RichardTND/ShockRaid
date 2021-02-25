;#############################
;#        Shock Raid         #
;#                           #
;#     by Richard Bayliss    #
;#                           #
;# (C)2021 The New Dimension #
;#     For Reset Magazine    #
;#############################

;Game variables



;Map and tile memory data

tilemem = $b0 ;Load address of all tiles
tileY = $02   ;rows
map = $03     ;Map address storebyte
tiledata = $fc ;16bit address for tile memory
maptmp = $fe   ;temp byte for map
screen = $0400  ;screen RAM 
colour = $d800  ;colour RAM
mapload = MAPDATA ;Memory of the game map
rowtemp = $0f00  ;Temporary self-modifying byte for map
tileload = $b000

;Row variables 
row0 = screen
row1 = screen+1*40
row2 = screen+2*40
row3 = screen+3*40
row4 = screen+4*40
row5 = screen+5*40
row6 = screen+6*40
row7 = screen+7*40
row8 = screen+8*40
row9 = screen+9*40
row10 = screen+10*40
row11 = screen+11*40
row12 = screen+12*40
row13 = screen+13*40
row14 = screen+14*40
row15 = screen+15*40
row16 = screen+16*40
row17 = screen+17*40
row18 = screen+18*40
row19 = screen+19*40
row20 = screen+20*40



;Player variables

UpStopPos = $5a
DownStopPos = $ba
LeftStopPos = $0e
RightStopPos = $a0

KillerCharsRangeStartGroup1 = 44
KillerCharsRangeEndGroup2 = 240


LaserGateChar1 = 241
LaserGateChar2 = 242
LaserGateChar3 = 243
LaserGateChar4 = 244
LaserGateChar5 = 245
LaserGateChar6 = 246
LaserGateChar7 = 247
LaserGateChar8 = 248
;Background object characters for lasers

LaserGateChars = $3800+(241*8) ;Starting character set for the laser gate objects

LaserGateCharsBackup = CharsBackupMemory ;Where old text chars lie ;BACKUP

LevelExitChar = 27 ;The char ID for the top of the flag pole

playerlo = $70 ;Zero pages set for the player 
playerhi = $71

ScrollChar = $3800+(29*8) ;The the scrolling void
ScrollChar2 = $3800+(30*8)
ScrollChar3 = $3800+(35*8)
ScrollChar4 = $3800+(193*8)

EndLaserLeftChar1 = $3800+(245*8)
EndLaserRightChar1 = $3800+(246*8)
EndLaserLeftChar2 = $3800+(247*8)
EndLaserRightChar2 = $3800+(248*8)
EndLaserDownChar1 = $3800+(249*8)
EndLaserDownChar2 = $3800+(250*8)

;Alien movement variables (The formation data is based on
;Richard's Alien Formation Maker program). X = first 256 bytes, Y = last 256 bytes
;(As recorded from the program). Variable names will be named as F01X, F01Y - F16X, F16Y 
;for short

F01X = FormationData01 
F01Y = FormationData01 + $100
F02X = FormationData02
F02Y = FormationData02 + $100
F03X = FormationData03
F03Y = FormationData03 + $100
F04X = FormationData04
F04Y = FormationData04 + $100
F05X = FormationData05 
F05Y = FormationData05 + $100
F06X = FormationData06
F06Y = FormationData06 + $100
F07X = FormationData07
F07Y = FormationData07 + $100
F08X = FormationData08
F08Y = FormationData08 + $100
F09X = FormationData09
F09Y = FormationData09 + $100
F10X = FormationData10
F10Y = FormationData10 + $100
F11X = FormationData11
F11Y = FormationData11 + $100
F12X = FormationData12
F12Y = FormationData12 + $100
F13X = FormationData13
F13Y = FormationData13 + $100
F14X = FormationData14
F14Y = FormationData14 + $100
F15X = FormationData15
F15Y = FormationData15 + $100
F16X = FormationData16
F16Y = FormationData16 + $100

;VIC2 BANK 3 - Screen character position where each feature
;lies.

Score = $0777   ;Position of the 5-digit score panel 
Shield = $0787  ;Position of the 1 digit shield counter
LevelIndicator = $0796 ;Position of the player level indicator

pulsecharleft1 = $0800+99*8
pulsecharleft2 = $0800+100*8 
pulsecharright1 = $0800+101*8
pulsecharright2 = $0800+102*8

fillchar = 170

;Invincibility timer

InvulnerabilityTimer = 200


;Music variables

TitleMusic = 0
GameMusic = 1
GameOverJingle = 2
EndMusic = 3

MusicInit = $1000
MusicPlay = $1003

MusicInit2 = $f400
MusicPlay2 = $f403

;SFX Variables 


;Game Start / Level Up 

GameOverSFX = 0
PlayerShootSFX = 1
ShieldHitSFX = 2
PlayerDeathSFX = 3
AlienDeathSFX = 4
AlienShootSFX = 5 
LevelUpSFX = 6


;Hi Score variables 


scorelen = 5
listlen = 5
namelen = 9
storbyt = $07
;Hi Score detection

SFXInit = $f000
SFXPlay = $f003
