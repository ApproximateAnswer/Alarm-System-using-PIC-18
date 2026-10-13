; TODO INSERT CONFIG CODE HERE USING CONFIG BITS GENERATOR

;CODE BY GROUP ALAA TOMBOKTI & LOBNA MOUSA

     LIST P = 18F4520
      INCLUDE P18F4520.inc
 	 
PORTA   EQU 0xF80 
PORTB   EQU 0xF81
PORTC   EQU 0xF82
PORTD   EQU 0xF83
PORTE   EQU 0xF84
TRISA   EQU 0xF92
TRISB   EQU 0xF93
TRISC   EQU 0xF94
TRISD   EQU 0xF95
TRISE   EQU 0xF96
T0CON   EQU 0xFD5
T1CON   EQU 0xFCD
T2CON   EQU 0xFCA
T3CON   EQU 0xFB1
TMR0L   EQU 0xFD6
TMR0H   EQU 0xFD7
TMR1L   EQU 0xFCE
TMR1H   EQU 0xFCF
TMR2    EQU 0xFCC
PR2     EQU 0xFCB
INTCON  EQU 0xFF2
CCP1CON EQU 0xFBD
CCP2CON EQU 0xFBA
CCPR1L  EQU 0xFBE 
CCPR1H  EQU 0xFBF
CCPR2L  EQU 0xFBB
CCPR2H  EQU 0xFBC
ADCON0  EQU 0xFC2
ADCON1  EQU 0xFC1
ADCON2  EQU 0xFC0
ADRESL  EQU 0xFC3
ADRESH  EQU 0xFC4
	 
   ORG 0x00
   GOTO START
   
DELAY 
	    MOVLW 0x03              ;PRESCALAR 1:16
	    MOVWF T0CON
AGAIN       MOVLW 0x0B              ;Delay 
	    MOVWF TMR0H
	    MOVLW 0xDC
	    MOVWF TMR0L 
	    BCF INTCON, TMR0IF
	    BSF T0CON, TMR0ON 
WAIT1	    BTFSS INTCON, TMR0IF
	    BRA WAIT1 
	    BCF T1CON, TMR0ON
	    RETURN 
   
TIMER2_ON
 
	    MOVLW   D'249'  ;prescaler 4
	    MOVWF   PR2	    ;PR2 = (Fosc/(4*PWMfreq*prescale)) - 1
            MOVLW   B'0000101'  ;TMR2ON on 
            MOVWF   T2CON
            RETURN
    
TIMER2_OFF
            MOVLW   B'0000001' ;TMR2ON off 
            MOVWF   T2CON
            RETURN
    
BUZZER_OFF
    
	    movlw B'00001100'  ; CCP2CON 0% = 0C
            movwf CCP2CON 
            movlw H'00'   ;CCPR1L 0%
            movwf CCPR2L
            RETURN
   
START
	    
        MOVLW  0x00 ;led and buzzer to portb bit 3 and 2 is output
        MOVWF TRISB  
         MOVLW  0x80;PORTD Bit7 IS INPUT FOR PIR
         MOVWF TRISD
         MOVLW 0x00 ;PORTC IS OUTPUT FOR LCD
         MOVWF TRISC
  
;LCD CODE	    
	    
	    BCF   PORTD, RD0		 ;SEND INSTRUCTIONS TO LCD WHEN RS = 0 
	    MOVLW 0x038			     
	    CALL  SEND_TO_LCD		 ;WRITE TO LCD FOR 8-bit MODE / 2 LINES DISPLAY
	    MOVLW 0x038			 
	    CALL  SEND_TO_LCD
	    MOVLW 0x038           
	    CALL  SEND_TO_LCD
	    MOVLW 0x010           
	    CALL  SEND_TO_LCD              ;TURN OFF DISPLAY
	    MOVLW 0x001           
	    CALL  SEND_TO_LCD              ;CLEAR DISPLAY
	    MOVLW 0x006
	    CALL  SEND_TO_LCD              ;SET CURSOR MOVE DIRECTION
	    MOVLW 0x00
	    CALL  SEND_TO_LCD              ;ENABLE/DISPLAY CURSOR
	   
  

SEND_TO_LCD
	    MOVWF  PORTC 
	    BSF    PORTD, RD2 ;E = 1
	    NOP 
	    BCF    PORTD, RD2     ;TOGGLE E TO SEND DATA TO LCD 
	    CALL   DELAY
	    RETURN   
 
MAIN
   BTFSS PORTD, RD7 ;SENOSR 1 OR 0
   GOTO MAIN
  ; GOTO NoMotion
   GOTO MOTION
MOTION   
   BCF PORTD, RD0 ;RS=0 
   MOVLW 0x001 
   CALL SEND_TO_LCD
   BCF PORTD, RD0   ;RS = 0 if no display
   MOVLW 0x080
    CALL SEND_TO_LCD
    BSF PORTD, RD0    ; RS=1 to display
    MOVLW 'M'
    CALL SEND_TO_LCD
    MOVLW 'O'
    CALL SEND_TO_LCD
     MOVLW 'T'
     CALL SEND_TO_LCD
     MOVLW 'I'
     CALL SEND_TO_LCD
     MOVLW 'O'
     CALL SEND_TO_LCD
     MOVLW 'N'
     CALL SEND_TO_LCD
     BCF PORTC,RC0    ;RS=1 again to display
     MOVLW 0x0C0
     CALL SEND_TO_LCD
     
     BSF PORTC,RC0
     MOVLW 'A'
     CALL SEND_TO_LCD
     MOVLW 'L'
     CALL SEND_TO_LCD
     MOVLW 'E'
     CALL SEND_TO_LCD
     MOVLW 'R'
     CALL SEND_TO_LCD
     MOVLW 'T'
     CALL SEND_TO_LCD
     CALL DELAY

LOOP
     CALL BUZZER
     CALL LED
 GOTO MAIN

BUZZER
	    call TIMER2_ON
            movlw B'00011100'  ; Pulse Width Modulation
            movwf CCP2CON 
	    movlw D'125'   ;CCPR1L 80%
            movwf CCPR2L
            call DELAY
            call BUZZER_OFF
            call DELAY
            call DELAY
	    RETURN 
LED   
    BSF PORTB, D'3' ; LED ON
    call DELAY
    BTFSS PORTD, RD7 ;SENOSR 1 OR 0
    BCF PORTB, D'3' ; LED OFF
    GOTO LED
    call DELAY
    RETURN
                          
 
    BRA   START 
 END
