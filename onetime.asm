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
      ldx #$00
backuplaser
      lda LaserGateChars,x
      sta LaserGateCharsBackup,x
      inx
      cpx #32
      bne backuplaser
      
   