;#############################
;#        Shock Raid         #
;#                           #
;#     by Richard Bayliss    #
;#                           #
;# (C)2021 The New Dimension #
;#     For Reset Magazine    #
;#############################

scorelen = 6
listlen = 5
namelen = 9

;Hi Score detection

CheckForHiScore
          lda #0
          sta $d015
          
          
          ldx #$00
.copyfin  lda Score,x
          sta FinalScore,x
          inx
          cpx #6
          bne .copyfin
        
          sei
          ldx #$48
          ldy #$ff
          stx $fffe
          sty $ffff
          lda #$00
          sta $d019
          sta $d01a
          sta $d011
          lda #$35
          sta $01
          sta FireButton
          lda #$7f
          sta $dc0d
          sta $dd0d
          
          lda #$12
          sta $d018
          ldx #$00
          lda #$00
.silence  sta $d400,x
          inx
          cpx #$18
          bne .silence
          lda #0
          sta $d020
          lda #$08
          sta $d016
          lda #0
          sta NameFinished
          sta JoyDelay
          
          ;Check if the player cheated if so, hi score
          ;is not allowed.
          
          lda cheatlives+1
          cmp #$2c
          beq nohiscoreallowed
          jmp hiscoreallowed
nohiscoreallowed 
          jmp nohiscor
hiscoreallowed          
          ;Check if the player's score has reached 
          ;a position in the high score table
          
          ldx #$00
nextone   lda hslo,x
          sta $c1
          lda hshi,x
          sta $c2 
          
          ldy #$00
scoreget  lda FinalScore,y 
scorecmp  cmp ($c1),y
          bcc posdown
          beq nextdigit 
          bcs posfound
nextdigit iny
          cpy #scorelen
          bne scoreget 
          beq posfound
posdown   inx
          cpx #listlen 
          bne nextone
          beq nohiscor
posfound  stx $02
          cpx #listlen-1
          beq lastscor
          
          ldx #listlen-1
copynext  lda hslo,x
          sta $c1
          lda hshi,x
          sta $c2
          lda nmlo,x
          sta $d1
          lda nmhi,x
          sta $d2
          dex
          lda hslo,x
          sta $c3
          lda hshi,x
          sta $c4
          lda nmlo,x
          sta $d3
          lda nmhi,x
          sta $d4
          
          ldy #scorelen-1
copyscor  lda ($c3),y
          sta ($c1),y
          dey
          bpl copyscor
          
          ldy #namelen+1
copyname  lda ($d3),y
          sta ($d1),y 
          dey 
          bpl copyname 
          cpx $02
          bne copynext
          
lastscor  ldx $02
          lda hslo,x
          sta $c1
          lda hshi,x
          sta $c2
          lda nmlo,x
          sta $d1 
          lda nmhi,x
          sta $d2 
          jmp NameEntry
PlaceNewScore
          ldy #scorelen-1
putscore  lda FinalScore,y
          sta ($c1),y 
          dey
          bpl putscore
          ldy #namelen-1
putname   lda Name,y
          sta ($d1),y
          dey
          bpl putname
          jsr SaveHiScore
nohiscor jmp Title          
          
          
;======================================================

;The player has achieved a position in the high
;score table. So now it is time to do joy control
;name entry.

NameEntry
          ldx #$00 ;Clear the screen
.hiclr          
          lda #$20
          sta screen,x
          sta screen+$100,x
          sta screen+$200,x
          sta screen+$2e8,x 
          inx
          bne .hiclr 
          
          ldx #$00
.putwelldonemessage
          lda pulserow2,x 
          sta screen+(7*40),x
          lda pulserow1,x
          sta screen+(19*40),x
          lda HiScoreMessage,x
          sta screen+(8*40),x
          lda HiScoreMessage+(1*40),x
          sta screen+(11*40),x 
          lda HiScoreMessage+(2*40),x
          sta screen+(13*40),x
          lda HiScoreMessage+(3*40),x
          sta screen+(16*40),x
          lda #$05 
          sta colour+(8*40),x
          lda #$03
          sta colour+(11*40),x
          sta colour+(13*40),x
          lda #$0d
          sta colour+(16*40),x
          lda #1
          sta colour+(7*40),x
          sta colour+(19*40),x
          inx
          cpx #40
          bne .putwelldonemessage
          
          ;Clear name
          
          ldx #$00
.clearname
          lda #$20
          sta Name,x
          inx
          cpx #9
          bne .clearname
          
          ;Set Character A as default character 
          
          lda #1
          sta $04 
          lda $04
          sta Hi_Char
          ;Reset joystick delay 
          
          lda #0
          sta JoyDelay
          
          ;Initialise character position 
          
          lda #<Name
          sta sm+1
          lda #>Name
          sta sm+2
          
          lda #$1b 
          sta $d011 
          lda #0
          jsr MusicInit2
NameEntryLoop
          lda #$f9
          cmp $d012
          bne *-3
          jsr SlowAnimPulse
          jsr HiScorePlayer
          ;Show name on screen 
          
          ldx #$00
showname  lda Name,x
          sta $06e0,x
          lda #1
          sta $dae0,x
          inx
          cpx #9
          bne showname
          
          ;Check that the name entry routine is finished
          
          lda NameFinished
          bne stopnameentry 
          jsr joycheck
          
          jmp NameEntryLoop
          
          ;Name entry has finished, store to the hi score
          ;rank 
          
stopnameentry
          jmp PlaceNewScore
          
          ;Joystick check routine 
joycheck  lda Hi_Char 
sm        sta Name 
          lda JoyDelay 
          cmp #4
          beq joyhiok 
          inc JoyDelay 
          rts
          
joyhiok   lda #0
          sta JoyDelay 
          
          ;Check joystick up 
          
hi_up     lda #1
          bit $dc00
          bne hi_down 
          inc Hi_Char 
          lda Hi_Char 
          cmp #27
          beq delete_char 
          cmp #$21
          beq a_char 
          rts
          
          ;Check joystick down
hi_down   lda #2
          bit $dc00
          bne hi_fire 
          
          ;Move character down one 
          
          dec Hi_Char 
          
          ;Check for special character 
          
          lda Hi_Char
          cmp #$00 
          beq space_char 
          cmp #29
          beq z_char
          rts
          
          ;Make char delete
          
delete_char
          lda #30
          sta Hi_Char
          rts
          
          ;Make char spacebar 
          
space_char
          lda #$20
          sta Hi_Char 
          rts
          
          ;Make char letter A
          
a_char    lda #1
          sta Hi_Char
          rts
          
          ;Make char letter Z
z_char    lda #26
          sta Hi_Char
          rts 
          
          ;Check fire button on joystick 
          
hi_fire   lda $dc00
          !for f = 1 to 5
            lsr
          !end
          bit FireButton
          ror FireButton
          bmi hi_nofire
          bvc hi_nofire
          lda #0
          sta FireButton
          
          ;Fire pressed  
          
          ;Check for DELETE char 
          
          lda Hi_Char
          cmp #30
          bne checkendchar 
          
          ;Delete detected 
          
          lda sm+1
          cmp #<Name
          beq donotgoback 
          dec sm+1
          jsr CleanUpName
donotgoback
          rts
          
          ;Check for END char
          
checkendchar:
          cmp #31
          bne charisok 
          
          ;Make space 
          
          lda #$20
          sta Hi_Char 
          jmp FinishedNow
        
          ;Move to next character
charisok          
          inc sm+1
          ;Check length expired 
          lda sm+1
          cmp #<Name+9
          beq FinishedNow ;Name checked 
          
hi_nofire rts

          ;Trigger name entry finished
          
FinishedNow
          jsr CleanUpName
          
          lda #1
          sta NameFinished

          ;Check for cheat code 
          
          ldx #0
cheatcheck
          lda Name,x
          cmp CheatName,x
          bne skipcheat
          inx 
          cpx #$09
          bne cheatcheck
          
.activatecheat          
          
          lda #$2c
          sta cheatlives+1
skipcheat          
          rts

          ;Clear name from illegal characters to 
          ;prevent messy names
          
CleanUpName 
          ldx #$00
clearchars
          lda Name,x
          cmp #30
          beq cleanup
          cmp #31
          beq cleanup
          jmp skipcleanup
cleanup   lda #$20
          sta Name,x
skipcleanup
          inx
          cpx #namelen
          bne clearchars
          rts
          
HiScorePlayer
          lda system
          cmp #1
          beq .pal2
          inc NTSCTimer
          lda NTSCTimer
          cmp #$06
          beq .loopNTSC
.pal2     jsr MusicPlay2
          rts
.loopNTSC lda #0
          sta NTSCTimer
          rts
          
          
          
          
          
          
          
          
          
          
          
          
          
          
          

FinalScore !byte $30,$30,$30,$30,$30,$30
JoyDelay !byte 0
NameFinished !byte 0
Hi_Char  !byte 0
Name            !text "         "                
NameEnd
CheatName       !text "laserbeam"

hslo !byte <HiScore1,<HiScore2,<HiScore3,<HiScore4,<HiScore5 
hshi !byte >HiScore1,>HiScore2,>HiScore3,>HiScore4,>HiScore5
nmlo !byte <Name1,<Name2,<Name3,<Name4,<Name5 
nmhi !byte >Name1,>Name2,>Name3,>Name4,>Name5

              
HiScoreMessage
                !text "         congratulations pilot          "
                !text "your score has awarded a position in the"
                !text "             hall of fame.              "
                !text "         please enter your name         "

                