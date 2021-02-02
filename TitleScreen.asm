;#############################
;#        Shock Raid         #
;#                           #
;#     by Richard Bayliss    #
;#                           #
;# (C)2021 The New Dimension #
;#     For Reset Magazine    #
;#############################

;Title screen code

Title          sei
               lda #$35
               sta $01
               ldx #$48
               ldy #$ff
               stx $fffe
               sty $ffff
               lda #$00
               sta $d01a
               sta $d019
               sta $d020
               sta $d021
               sta XPos
               lda #$81
               sta $dc0d
               sta $dd0d
               lda #$00
               sta $d011
               sta PageNo
               lda MusicSprite
               sta $07f8
               lda SFXSprite
               sta $07f9
               lda #$ff
               sta $d015 
               sta $d01c
               lda #$01
               sta $d025
               lda #$09
               sta $d026
               lda #$0c
               sta ObjPos
               lda #$a0
               sta ObjPos+2
               lda #$c8
               sta ObjPos+1
               sta ObjPos+3
               ldx #0
.clrrest       lda #$00
               sta ObjPos+4,x
               inx
               cpx #$0c
               bne .clrrest 
               sta $e1
               sta FireButton
               lda #<ScrollText 
               sta MessRead+1
               lda #>ScrollText 
               sta MessRead+2
               ldx #$00
.paintlogo     lda colram,x
               sta colour,x
               lda colram+$100,x
               sta colour+$100,x
               lda colram+$200,x
               sta colour+$200,x
               lda colram+$2e8,x
               sta colour+$2e8,x
               lda #$20
               sta $0400,x
               sta $0500,x
               sta $0600,x
               sta $06e8,x
               inx
               bne .paintlogo
               jsr DisplayCredits
               ldx #<tirq1
               ldy #>tirq1
               stx $fffe
               sty $ffff
               ldx #<nmi
               ldy #>nmi
               stx $fffa
               sty $fffb
               lda #$00
               sta $d012
               lda #$7f
               sta $dc0d
               sta $dd0d
               lda #$1b 
               sta $d011
               lda #$01
               sta $d019
               sta $d01a
               lda #$00
               jsr MusicInit 
               cli
               
               jmp TitleLoop ;(placed after IRQS)
               
;Title screen irq routine (Split into 3 interrupts one for logo, one for static credits / hiscore screen and one for scroll text)

               ;Title screen scroll text routine 
               
tirq1          sta tstacka1+1
               stx tstackx1+1
               sty tstacky1+1
               lda $dc0d 
               sta $dd0d 
               asl $d019 
               lda #$32
               sta $d012
               lda #$03
               sta $dd00
               lda #$1b 
               sta $d011
               lda XPos
               sta $d016
               lda #$12
               sta $d018 
              
               ldx #<tirq2
               ldy #>tirq2
               stx $fffe
               sty $ffff
tstacka1       lda #$00
tstackx1       ldx #$00
tstacky1       ldy #$00
               rti 
               
               ;Bitmap logo routine 
               
tirq2          sta tstacka2+1
               stx tstackx2+1
               sty tstacky2+1
               asl $d019
               lda #$7a
               sta $d012
            
               lda #$00
               sta $dd00
               lda #$3b 
               sta $d011
               lda #$18
               sta $d016
               lda #$18
               sta $d018 
              
               ldx #<tirq3 
               ldy #>tirq3
               stx $fffe
               sty $ffff
tstacka2       lda #$00
tstackx2       ldx #$00
tstacky2       ldy #$00
               rti 
               
               ;Static title screen text 
               
tirq3          sta tstacka3+1
               stx tstackx3+1
               sty tstacky3+1
               asl $d019 
               lda #$f0
               sta $d012
               !for i= 1to 9
                 nop
               !end
               
               lda #$03
               sta $dd00
               lda #$1b 
               sta $d011
               lda #$08
               sta $d016 
               lda #$12
               sta $d018 
             
               lda #1
               sta ST
               jsr MusicPlay
               
               ldx #<tirq1
               ldy #>tirq1
               stx $fffe
               sty $ffff
tstacka3       lda #$00
tstackx3       ldx #$00
tstacky3       ldy #$00
               rti
               
               
TitleLoop
                jsr ExpandSpritePosition
                jsr SyncTimer
                jsr XScroller
                jsr PageFlipper
                jsr FlashRoutine
                jsr CheckSoundOption
.titleleft      lda #4
                bit $dc00 
                bne .titleright
                lda #0
                sta SoundOption
                jmp FireButtonWait
.titleright     lda #8
                bit $dc00
                bne FireButtonWait
                lda #1
                sta SoundOption
FireButtonWait                
                lda $dc00
                !for f = 1 to 5
                  lsr
                !end 
                bit FireButton
                ror FireButton
                bmi TitleLoop
                bvc TitleLoop
                jmp Game
                
;Scrolling text message 

XScroller       lda XPos 
                sec
                sbc #1
                and #7
                sta XPos 
                bcs .exittextscroll
                ldx #$00
.shift          lda $07c1,x
                sta $07c0,x
                inx
                cpx #$28
                bne .shift 
MessRead        lda ScrollText 
                bne .storechar
                lda #<ScrollText 
                sta MessRead+1
                lda #>ScrollText 
                sta MessRead+2
                jmp MessRead 
.storechar      sta $07e7
                inc MessRead+1
                bne .exittextscroll
                inc MessRead+2
.exittextscroll rts                
                
                ;Display the hi score table 
                
DisplayHiScores
                jsr ClearNecessaryRows
                ldx #$00
.puthis         lda pulserow1,x 
                sta screen+10*40,x
                lda #1 
                sta colour+10*40,x 
                lda HallOfFameText,x
                sta screen+12*40,x 
                lda HallOfFameText+40,x
                sta screen+14*40,x
                lda HallOfFameText+80,x
                sta screen+15*40,x
                lda HallOfFameText+120,x
                sta screen+16*40,x
                lda HallOfFameText+160,x
                sta screen+17*40,x
                lda HallOfFameText+200,x
                sta screen+18*40,x 
                lda HallOfFameText+240,x
                sta screen+20*40,x
                lda pulserow2,x
                sta screen+22*40,x
                lda #1
                sta colour+22*40,x
                inx
                cpx #$28
                bne .puthis
                rts
                

                ;Display the game credits on screen (all text in shades of green)
                
DisplayCredits
                jsr ClearNecessaryRows
                ldx #$00
.putmessage     lda pulserow1,x
                sta screen+10*40,x
                lda #$01
                sta colour+10*40,x
                lda TitleScreenText,x
                sta screen+12*40,x
                lda TitleScreenText+40,x
                sta screen+14*40,x
                lda TitleScreenText+80,x
                sta screen+15*40,x
                lda TitleScreenText+120,x
                sta screen+16*40,x
                lda TitleScreenText+160,x
                sta screen+17*40,x
                lda TitleScreenText+200,x
                sta screen+19*40,x
                lda TitleScreenText+240,x
                sta screen+20*40,x
                lda pulserow2,x 
                sta screen+22*40,x
                lda #$01
                sta colour+22*40,x
               
                inx
                cpx #40
                bne .putmessage
                rts
                
ClearNecessaryRows
                ldx #$00
.clrloop        lda #$20
                sta screen+10*40,x
                sta screen+10*40+$100,x
                sta screen+$200,x
                sta screen+$2e8-40,x
                lda #13
                sta colour+10*40,x
                sta colour+10*40+$100,x
                sta colour+$200,x
                sta colour+$2e8-40,x
                inx
                bne .clrloop 
                rts
                
;Page flip routine - reads between title screen credits and hi score table 

PageFlipper     lda PageTimer
                cmp #$fa
                beq .next 
                inc PageTimer
                rts
.next           lda #0
                sta PageTimer 
                inc PageTimer+1
                lda PageTimer+1
                cmp #$02
                beq .pageread
                rts 
.pageread       lda #0
                sta PageTimer+1
                lda PageNo
                cmp #1
                beq .hof
                jsr DisplayCredits
                lda #1
                sta PageNo
                rts
.hof            jsr DisplayHiScores
                lda #0
                sta PageNo
                rts
                
FlashRoutine    lda FlashDelay
                cmp #2
                beq FlashMain
                inc FlashDelay 
                rts
FlashMain       lda #$00
                sta FlashDelay
                ldx FlashPointer
                lda FlashColourTable,x 
                sta FlashStore 
                inx
                cpx #FlashColourEnd-FlashColourTable 
                beq FlashReset 
                inc FlashPointer
                rts
FlashReset      ldx #0
                stx FlashPointer 
                rts
                
CheckSoundOption
                lda SoundOption
                beq InGameMusicMode
                lda #$0b 
                sta $d027 
                lda FlashStore
                sta $d028
                rts
InGameMusicMode lda #$0b
                sta $d028
                lda FlashStore
                sta $d027
                rts
                
MusicSprite !byte $d6
SFXSprite !byte $d7
                
                
SoundOption !byte 0                
PageTimer !byte 0,0
PageNo    !byte 0
FlashDelay !byte 0
FlashPointer !byte 0
FlashStore !byte 0
FlashColourTable
           !byte $09,$05,$0d,$01,$0d,$05,$09
FlashColourEnd !byte 0
                
XPos      !byte 0
pulserow1       !byte 99,100,99,100,99,100,99,100,99,100
                !byte 99,100,99,100,99,100,99,100,99,100
                !byte 99,100,99,100,99,100,99,100,99,100
                !byte 99,100,99,100,99,100,99,100,99,100
                
pulserow2       !byte 101,102,101,102,101,102,101,102,101,102
                !byte 101,102,101,102,101,102,101,102,101,102
                !byte 101,102,101,102,101,102,101,102,101,102
                !byte 101,102,101,102,101,102,101,102,101,102
               
               !ct scr
TitleScreenText
                
                !text "   (c) 2021 the new dimension + reset   "
                !text " programming          richard bayliss   "
                !text " graphics             richard bayliss   "
                !text "                      hugues poisseroux "
                !text " sfx+music            richard bayliss   "
                !text "        use a joystick in port 2        "
                !text "         - press fire to play -         "
                
HallOfFameText  !text "             the hall of fame           "
                !text "           1. richard b 000000          "
                !text "           2. hugues    000000          "
                !text "           3. martin    000000          "
                !text "           4. reset     000000          "
                !text "           5. mmxxi     000000          "
                !text "         - press fire to play -         "
                
ScrollText      
                !byte 99,100,99,100 
                !text " shock raid "
                !byte 101,102,101,102
                !text " ...   programming, game graphics and music/sfx by richard bayliss ...   logo and "
                !text "bitmap graphics by hugues (ax!s) poisseroux ...   copyright (c) 2021 the new dimension "
                !text "...   developed specially for reset issue 14's mix-i-disk ...   use left/right to select in game sound "
                !text "options ...   dateline: earth: 2192 ...   "
                !text "operation shock raid has commenced ...   an alien planet is moving fast and is "
                !text "currently on course for a head-on collision with planet earth ...   the source that is "
                !text "controlling it is a crystal of light ...   your mission is to enter four different zones "
                !text "of the planet's underground in search for the crystal and destroy it ...   however you will not be alone ...   "
                !text "aliens will attempt to stop you ...   try to avoid crashing into the aliens, boundaries or laser gates, otherwise "
                !text "a shield will be taken away from you ...   as soon as all of your shields run out, your ship will be destroyed "
                !text "with you inside it ...   can you get through all 4 zones, find and destroy crystal and teleport back to "
                !text "give earth the good news, or will you be too late? ...   good luck pilot, you will need it ...   "
                !text "this game was programmed and developed during winter 2021 ...   we do hope you have fun playing this game ...   "
                !text "- press fire to play - ...                              "
                
                !byte 0
                
                