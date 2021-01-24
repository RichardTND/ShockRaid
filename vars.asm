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

;Background object characters for lasers

LaserGateChars = $3800+64*8
LaserGateCharsBackup = $3808 ;Where old text chars lie

;Player variables

UpStopPos = $5a
DownStopPos = $ba
LeftStopPos = $0e
RightStopPos = $a0

;Music variables

MusicInit = $1000
MusicPlay = $1003
