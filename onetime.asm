;#############################
;#        Shock Raid         #
;#                           #
;#     by Richard Bayliss    #
;#                           #
;# (C)2021 The New Dimension #
;#     For Reset Magazine    #
;#############################

;Some one time code which will initialise the game settings
;for example backup the laser beam character set, etc.
      
    ;Backup the laser character set
      sei
      lda #$35
      sta $01
      ldx #$00
backuplaser
      lda LaserGateChars,x
      sta LaserGateCharsBackup,x
      inx
      cpx #32
      bne backuplaser
      lda $02a6
      sta system
      lda #0
      sta $d020
      sta $d021
    
      
      jmp LoadHiScores