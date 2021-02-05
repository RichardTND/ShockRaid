;#############################
;#        Shock Raid         #
;#                           #
;#     by Richard Bayliss    #
;#                           #
;# (C)2021 The New Dimension #
;#     For Reset Magazine    #
;#############################


      ;Variables 
      !source "vars.asm"
      
      ;Generate main program
      !to "shockraid.prg",cbm
      
      *=$0800
      ;Import text character set to screen memory
      !bin "bin\textcharset.bin"
       ;Insert the HUD graphics data
      *=$0c00
hud   !bin "bin\hud.bin"
      !align $100,0
hudattribs
      !bin "bin\hudattribs.bin"
      
      
      *=$1000
      ;Import music data
      !bin "bin\music.prg",,2
      
      ;Import game sprites
      *=$2000
      !bin "bin\gamesprites.bin"
      
      ;Import game graphics character set
      *=$3800
      !bin "bin\gamecharset.bin"
      
   ;Import map data
      *=$4800
mapstart
MAPDATA 
      !bin "bin\gamemap.bin"
mapend
      *=*+10
      
      ;Main game code
      *=$6200
      !source "onetime.asm"
      !source "titlescreen.asm"
      !source "gamecode.asm"
      !source "hiscore.asm"
      ;There should be enough room here (hopefully for alien formation data)
      ;but the code data should be aligned to the nearest $x00 position 
      !align $ff,0
FormationData01
      !bin "bin\Formation01.prg",,2
FormationData02
      !bin "bin\Formation02.prg",,2
FormationData03
      !bin "bin\Formation03.prg",,2
FormationData04
      !bin "bin\Formation04.prg",,2
FormationData05
      !bin "bin\Formation05.prg",,2
FormationData06
      !bin "bin\Formation06.prg",,2
FormationData07
      !bin "bin\Formation07.prg",,2
FormationData08
      !bin "bin\Formation08.prg",,2
FormationData09
      !bin "bin\Formation09.prg",,2
FormationData10
      !bin "bin\Formation10.prg",,2
FormationData11
      !bin "bin\Formation11.prg",,2
FormationData12
      !bin "bin\Formation12.prg",,2
FormationData13
      !bin "bin\Formation13.prg",,2
FormationData14
      !bin "bin\Formation14.prg",,2
FormationData15
      !bin "bin\Formation15.prg",,2
FormationData16
      !bin "bin\Formation16.prg",,2
      
      
      ;Import game tile data
      *=$b000
TILEMEMORY
      !bin "bin\gametiles.bin"
      
      ;Import end music data 
      *=$b800
      !bin "bin\music2.prg",,2
      
      
      ;Import logo bitmap video RAM data
      *=$c800
      ;Import logo colour RAM data 
colram
      !bin "bin\logocolram.prg",,2
      *=$cc00
vidram      
      !bin "bin\logovidram.prg",,2 
      
      *=$e000
      ;Import logo bitmap data 
      !bin "bin\logobitmap.prg",,2
      
      *=$f000
      ;Import game sound effects
      !bin "bin\shockraidsfx.prg",,2
      

     