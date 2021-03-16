;#############################
;#        Shock Raid         #
;#                           #
;#     by Richard Bayliss    #
;#                           #
;# (C)2021 The New Dimension #
;#     For Reset Magazine    #
;#############################

;Title screen code
Title
TitleScreen    sei
               lda #$34
               sta $01
               lda #<ScrollText ;Initialise scroll text
               sta MessRead+1
               lda #>ScrollText 
               sta MessRead+2
               
               ;Clear the entire screen
               
               ldx #$00
.clearfullscreen
               lda #$00
               sta $0400,x
               sta $0500,x
               sta $0600,x
               sta $06e8,x 
               inx
               bne .clearfullscreen
               
               ;Kill all IRQs and set to $0001,$35 mode.
               
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
               sta $d017
               sta $d01d
               sta $d01b
               sta TitleFlashColourPointer
               sta TitleFlashColourDelay
               
               sta XPos
               lda #$81
               sta $dc0d
               sta $dd0d
               lda #$00
               sta $d011
               lda #0
               sta PageNo
               sta PageTimer
               sta PageTimer+1
               lda MusicSprite
               sta $07f8
               lda SFXSprite
               sta $07f9
               
               ;Setup blue star sprites for title screen
               
               ldx #$00
.makestars               
               lda StarSprite 
               sta $07fa,x
               lda #14
               sta $d029,x
               inx
               cpx #6
               bne .makestars
        
               lda #$ff
               sta $d015 
               sta $d01c
               sta $d01b
               lda #$0c
               sta $d025
               lda #$0b
               sta $d026
               
               lda #$0c
               sta ObjPos
               lda #$a0
               sta ObjPos+2
               lda #$c8
               sta ObjPos+1
               sta ObjPos+3
               ldx #0
.clrrest       lda StarPosTable,x
               sta ObjPos+4,x
               inx
               cpx #$0c
               bne .clrrest 
               sta $e1
               sta FireButton
              
               ;Copy the logo video and colour data then place into 
               ;the logo's video and colour RAM at BANK $01
               
               ldx #$00
.paintlogo     lda colram,x
               sta colour,x
               lda colram+$100,x
               sta colour+$100,x
               lda colram+$200,x
               sta colour+$200,x
               lda colram+$2e8,x
               sta colour+$2e8,x
               lda #$00
               sta $0400,x
               sta $0500,x
               sta $0600,x
               sta $06e8,x
               inx
               bne .paintlogo
               
               ;Fill out the text rows as black 
               
               ldx #$00
.blackout      lda #$00
               sta colour+(9*40),x
               sta $0400+(9*40),x
               sta colour+(12*40),x 
               sta colour+(13*40),x
               sta colour+(14*40),x
               sta colour+(15*40),x
               sta colour+(16*40),x
               sta colour+(17*40),x
               sta colour+(18*40),x
               sta colour+(19*40),x
               sta colour+(20*40),x
               lda laserscrollcharcolour,x
               sta colour+(10*40),x
               sta colour+(22*40),x
               inx
               cpx #$28
               bne .blackout
               
               ;Display hi scores by default 
               
               jsr DisplayHiScores
               
               ;Setup IRQ interrupts for the title screen
               
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
               lda #TitleMusic
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
               lda #1
               sta ST
               jsr PalNTSCPlayer
           
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
               lda #$38
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
               nop
               nop
               nop
               nop
               nop
               nop
               nop
               nop
               nop
               nop
               
               lda #$03
               sta $dd00
               lda #$1b 
               sta $d011
               lda #$08
               sta $d016 
               lda #$12
               sta $d018 
             
               
               ldx #<tirq1
               ldy #>tirq1
               stx $fffe
               sty $ffff
tstacka3       lda #$00
tstackx3       ldx #$00
tstacky3       ldy #$00
               rti
               
               ;Main loop for our title screen
               
TitleLoop       jsr SyncTimer             ;Synchronize timer with IRQ
                jsr ExpandSpritePosition  ;Expand the sprite position to use full screen
                jsr StarField             ;Move the stars
                jsr XScroller             ;Scroll text routine
                jsr PageFlipper           ;Credits / Hall of fame swap routine
                jsr FlashRoutine          ;Colour flashing and washing
                jsr LaserGate             ;Charset animation for the scrolling lasers
                jsr CheckSoundOption      ;Sound option detection
                jsr WashColourText        ;Main colour washing text
                
                ;Read joystick to select game sound options
                
.titleleft      lda #4            ;Left selects in game music
                bit $dc00 
                bne .titleright
                lda #0
                sta SoundOption
                jmp FireButtonWait
                
.titleright     lda #8            ;Right selects sound effects
                bit $dc00
                bne FireButtonWait
                lda #1
                sta SoundOption
FireButtonWait                
                                  ;Check fire button and that it has been
                lda $dc00         ;released. Then start game.
                lsr
                lsr
                lsr
                lsr
                lsr
                bit FireButton
                ror FireButton
                bmi TitleLoop
                bvc TitleLoop
                jmp Game
                
;Scrolling text message 

XScroller       lda XPos 
                sec
                sbc #2
                and #7
                sta XPos 
                bcs .exittextscroll
                ldx #$00
.shift          lda $07c1,x
                sta $07c0,x
                lda scrollcharcolour,x
                sta colour+(24*40),x
                inx
                cpx #$28
                bne .shift 
                lda #$34
                sta $01
MessRead        
                lda ScrollText 
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

.exittextscroll 
                lda #$35
                sta $01            
                rts
                
                ;Display the hi score table 
                
DisplayHiScores
                jsr ClearNecessaryRows
                ldx #$00
.puthis         lda pulserow2,x 
                sta screen+10*40,x
               
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
                lda pulserow1,x
                sta screen+22*40,x
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
                inx
                cpx #40
                bne .putmessage
                rts
                
                ;Clean up a few bits
                
ClearNecessaryRows
                ldx #$00
.clrloop        lda #$20
                sta screen+10*40,x
                sta screen+10*40+$100,x
                sta screen+$200,x
                sta screen+$2e8-40,x
               
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
                
                ;The main flash routine in action
                
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
                
StarField       ldx #$00
.scrollaway     lda ObjPos+4,x
                clc
                adc StarSpeed,x
                bcs .placestar 
                lda #$c0 
.placestar                
                sta ObjPos+4,x
                inx
                inx
                cpx #$0c
                bne .scrollaway
                rts
                

;Colour flash routine (washing) for title screen text 
;scroll text remains as it is.

WashColourText  
                lda TitleFlashColourDelay
                cmp #2
                beq .flashtitlemain
                inc TitleFlashColourDelay
                rts
.flashtitlemain lda #0
                sta TitleFlashColourDelay
                ldx TitleFlashColourPointer
                lda TitleFlashColourTable,x
                sta colour+(12*40)+39
                sta colour+(13*40)
                sta colour+(14*40)+39
                sta colour+(15*40)
                sta colour+(16*40)+39
                sta colour+(17*40)
                sta colour+(18*40)+39
                sta colour+(19*40)
              
                sta colour+(20*40)+39
                inx
                cpx #TitleFlashColourEnd-TitleFlashColourTable 
                beq .looptitleflash
                inc TitleFlashColourPointer
                jsr StoreColourToText
                rts                
.looptitleflash
                ldx #$00
                stx TitleFlashColourPointer
                 
                
                ;Main colour washing to each text row left
StoreColourToText
                jsr WashColourTextLeft
                jsr WashColourTextRight 
                rts
                
WashColourTextLeft 
                
                ldx #$00
.washleft       lda colour+(12*40)+1,x
                sta colour+(12*40),x
                lda colour+(14*40)+1,x
                sta colour+(14*40),x
                lda colour+(16*40)+1,x
                sta colour+(16*40),x 
                lda colour+(18*40)+1,x
                sta colour+(18*40),x
                lda colour+(20*40)+1,x
                sta colour+(20*40),x
                inx
                cpx #$28
                bne .washleft
                rts

WashColourTextRight 

                ldx #$27
.washright      lda colour+(13*40)-1,x
                sta colour+(13*40),x
                lda colour+(15*40)-1,x
                sta colour+(15*40),x
                lda colour+(17*40)-1,x
                sta colour+(17*40),x
                lda colour+(19*40)-1,x
                sta colour+(19*40),x
                dex
                bpl .washright
                rts       
       
                ;Title screen pointers
                
MusicSprite !byte $d6
SFXSprite !byte $d7
StarSprite !byte $dc

StarPosTable    !byte $00,$90
                !byte $00,$a0
                !byte $00,$b0
                !byte $00,$c0
                !byte $00,$d0
                
StarSpeed       !byte $fe,$00
                !byte $fc,$00
                !byte $fd,$00
                !byte $fc,$00
                !byte $fd,$00
                !byte $fe,$00

                
                
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
               
scrollcharcolour !byte $09,$0b,$0c,$0f,$07
                 !byte $01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$07
                 !byte $0f,$0c,$0b,$09,$09
                 
laserscrollcharcolour
                 !byte $09,$0b,$0c,$0f,$07
                 !byte $01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01
                 !byte $01,$01,$01,$01,$01
                 !byte $07,$0f,$0c,$0b,$09
                 
                 
TitleScreenText
                
                !text "       (c) 2021 the new dimension       "
                !text " programming ........ richard bayliss   "
                !text " charset ............ richard bayliss   "
                !text " graphics+sprites ... hugues poisseroux "
                !text " sfx+music .......... richard bayliss   "
                !text "        use a joystick in port 2        "
                !text "         - press fire to play -         "
                
HallOfFameText  !text "            the hall of fame            "
                
                !text "           1. "
HiScoreTableStart                
Name1           !text "richard   "
HiScore1        !text "09000           "
                !text "           2. "
Name2           !text "hugues    "
HiScore2        !text "07500           "
                !text "           3. "
Name3           !text "kevin     "
HiScore3        !text "05000           "
                !text "           4. "
Name4           !text "reset     "
HiScore4        !text "02500           "
                !text "           5. "
Name5           !text "tnd       "
HiScore5        !text "00500           "
HiScoreTableEnd
HiScoreTableEnd
                !text "         - press fire to play -         "    
  
TitleFlashColourDelay !byte 0
TitleFlashColourPointer !byte 0

TitleFlashColourTable
                !byte $09,$0b,$0c,$0f,$07,$01,$07,$0f,$0c
TitleFlashColourEnd !byte $0b

