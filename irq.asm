;Main Interrupts for the soft scrolling test SEU.
;We use stack control in order to stabilize the interrupts


          ;Game scrolling background IRQ

irq1
          sta stacka1+1 
          stx stackx1+1 
          sty stacky1+1 
          lda $dc0d     
          sta $dd0d     
          lda #$00
          sta $d01b
          lda ypos      
       
          sta $d011     
         
          lda #$00
          sta $d01b
          lda #$03      
          sta $dd00
          lda #$1e    
          sta $d018     
        
       
          lda BGColour2
          sta $d023
          lda BGColour1
          sta $d022
          lda #$ff
          sta $d015
          sta $d01c
         
          ;Main scroll controll routine (this controls the smoothness
          ;of the scroll connected to the interrupt (irq1)
          
          jsr SmartBackgroundScroll
       
          ldx #<irq2    
          ldy #>irq2    
          lda #$d1 
          stx $fffe     
          sty $ffff     
          sta $d012     
          asl $d019     
stacka1
          lda #$00      
stackx1
          ldx #$00      
stacky1
          ldy #$00      
          rti

          ;Status Panel IRQ. Before that however a $D011 register 
          ;is triggered to hide the last row before the score panel
          ;in order to stabilise the score panel.
          
irq2      sta stacka2+1
         
        
          lda #$00     
          sta $d015
        
          lda $d011     
          cmp #$15      
          beq flip      
          
          lda #$7b      
          sta $d011     
    
          pha
          pla
          pha
          pla
          nop
          nop
          nop
          nop
          
          ;The main score panel IRQ. The panel is set to blue
          ;and remains that call through all causes.
flip
          stx stackx2+1 
          
            lda #$0e
          sta $d022     
          lda #$06
          sta $d023     
          lda #$77      
          sta $d011     
          sty stacky2+1 
          ldx #$5a  
          dex
          bne *-1       
          lda #$17      
          sta $d011     
           
          lda #$03
          sta $dd00
          lda #$12  
          sta $d018     
            
          lda #0
          sta $d015
          sta $d01c
          
          jsr SoundPlayer             
         
          
          ldx #<irq1   
          ldy #>irq1    
          lda #$fa      
          stx $fffe     
          sty $ffff     
          sta $d012     
          asl $d019     
stacka2
          lda #$00      
stackx2
          ldx #$00      
stacky2
          ldy #$00      
          rti


nmi         rti

          ;PAL & NTSC timed music player

SoundPlayer
          lda #1
          sta ST
          lda SoundOption 
          beq .irqmusic
          jsr SFXPlay
          rts
.irqmusic          
          jsr PalNTSCPlayer
.irqloop
          rts
          
          

          