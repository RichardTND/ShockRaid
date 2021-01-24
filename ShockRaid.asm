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
      *=$7000
      !source "onetime.asm"
      !source "gamecode.asm"
      
      ;Import game tile data
      *=$b000
TILEMEMORY
      !bin "bin\gametiles.bin"

      ;Insert the HUD graphics data
      *=$e000
hud   !bin "bin\hud.bin"
      !align $100,0
hudattribs
      !bin "bin\hudattribs.bin"
      