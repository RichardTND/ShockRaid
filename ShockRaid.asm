;#############################
;#        Shock Raid         #
;#                           #
;#     by Richard Bayliss    #
;#                           #
;# (C)2021 The New Dimension #
;#     For Reset Magazine    #
;#############################

DiskVersion = 1

;Insert variables source file

      !source "vars.asm"
      
;Generate main program

      !to "shockraid.prg",cbm
      
      
;Insert the title screen text charset

      *=$0800
      !bin "bin\textcharset.bin"
      

      
;Insert music data 1 (Title, In game music and Game Over jingle)
      
      *=$1000
      !bin "bin\music.prg",,2
      
;Insert main game sprites
      
      *=$2000
      !bin "bin\gamesprites.bin"
      
;Insert main game graphics character set
      
      *=$3800
      !bin "bin\gamecharset.bin"
      
;There's a bit of space for DISK access for hi score 
;saving and loading. 
      
      *=$4000
      !source "diskaccess.asm"
      
;Insert end screen sequence code
      
      *=$4100
      !source "endscreen.asm"
      
CharsBackupMemory
      !align $ff,0 
;Insert the game's map (Built from Charpad)
      
      *=$4800
mapstart
MAPDATA 
      !bin "bin\gamemap.bin"
      
      ;Mark the start of the map (mapend = starting position)
mapend
      *=*+10
       
      
      
      *=$6200
;Insert the onetime assembly source code - This is where to jump to after
;packing/crunching this production.
      
      !source "onetime.asm"
      
;Insert title screen code assembly source code
      
      !source "titlescreen.asm"
      
;Insert the main game code
      
      !source "gamecode.asm"
      
;Insert the hi-score check routine code 
      
      !source "hiscore.asm"
    
      ;There should be enough room here (hopefully for alien formation data)
      ;but the code data should be aligned to the nearest $x00 position 
      !align $ff,0
      
;The following files are the X, and Y tables for each alien movement
;pattern.
      
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

      ;Insert title screen end (game completion) text
      *=$a800
endtext      
      !bin "bin\endtext.bin"
      *=$ac00
endscreen2
      !bin "bin\endscreen2.bin"
      
      ;Insert the game tile data. 
      
      *=$b000
TILEMEMORY
      !bin "bin\gametiles.bin"
      
      ;Insert end screen
      
      *=$c400
endscreenmemory
      !bin "bin\endscreen.bin"
      
      ;Insert logo bitmap video RAM data
      
      *=$c800
colram
      !bin "bin\logocolram.prg",,2
      
      ;Insert logo bitmap colour RAM data
      
      *=$cc00
vidram      
      !bin "bin\logovidram.prg",,2 
      
      ;Insert title screen scroll text
      
      *=$d000
      !source "scrolltext.asm"
      
      
      ;Insert title screen bitmap graphics data
      
      *=$e000
      !bin "bin\logobitmap.prg",,2
      
      ;Insert in game sound effects player data
      
      *=$f000
      !bin "bin\shockraidsfx.prg",,2
      
      ;Insert end screen / hi score music data
      
      *=$f400
      !bin "bin\music2.prg",,2
      ;Insert the HUD graphics data then 
;the attributes
       
      
hud   !bin "bin\hud.bin"
    
hudattribs
      !bin "bin\hudattribs.bin"
     