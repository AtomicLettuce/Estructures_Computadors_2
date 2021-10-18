; =============================================================================
; TITLE    : MEMORY MAPPED HARD CODE
; AUTHOR   :
; COMMENTS :
; HISTORY  :
; =============================================================================

; -----------------------------------------------------------------------------
MAPINIT
; SHOWS HARDWARE WINDOW AND GETS MAPPING ADDRESSESG.
; INPUT    - D0.B BIT 0: SHOW HARDWARE WINDOW (1: YES, 0: NO)
;                 BIT 1: GET MAPPING ADDRESSES (1: YES, 0: NO)
;                 BIT 2-7: NOT USED.
;            A0 POINTER TO RAM ADDRESS TO STORE THE MAPPING ADDRESSES IN THIS
;               ORDER: 7-SEGMENT, LEDS, SWITCHES, BUTTONS.
;               IF D0.B BIT 1 IS ZERO, A0 IS NOT USED.
; OUTPUT   - NO OUTPUT THROUGH REGISTERS
;            RAM POINTED BY A0 IS MODIFIED IF D0.B BIT 1 IS 1
; MODIFIES - NONE
; -----------------------------------------------------------------------------

            hola
            BTST.B #0,D0
            BNE salt_1

Comprova_cond_2
            BTST.B #1,D0
            BNE salt_2
retorna
            RTE


salt_1
            JSR Mostrar_pantalla_hardware
            
            BRA Comprova_cond_2

salt_2
            JSR Retorn_de_direccions
            
            BRA retorna



Mostrar_pantalla_hardware
            ;Guardam valors inicials
            MOVE.W D0,-(A7)
            MOVE.W D1,-(A7)
            
            
            
            MOVE.B #33,D0
            MOVE.B #00,D1
            TRAP #15
            
            ;Retornam valors inicials
            MOVE.W (A7)+,D1
            MOVE.W (A7)+,D0
            
            RTS



Retorn_de_direccions
            ;Guardam valors inicials
            MOVE.L A0,-(A7)
            MOVE.W D0,-(A7)
            MOVE.W D1,-(A7)
            
            
            
            
            MOVE.B #33,D0                   ;Sel·leccionam la tasca 33
            
            MOVE.B #01,D1                   ;Obtenim direccions de mapatge dels displays de 7 segments
            TRAP #15
            MOVE.L D1,(A0)+                 ;Guardam la direccio dels 7seg display
            
            MOVE.B #02,D1                   ;Obtenim la direccio de mapatge dels LEDs
            TRAP #15
            MOVE.L D1,(A0)+                 ;Guardam direccio dels LEDs
            
            MOVE.B #03,D1                   ;Obtenim la direccio de mapatge dels interruptors
            TRAP #15
            MOVE.L D1,(A0)+                 ;Guardam direccio dels interruptors
            
            MOVE.B #07,D1                   ;Obtenim la direccio de mapatge dels polsadors
            TRAP #15
            MOVE.L D1,(A0)+                 ;Guardam direccio dels polsadors

            
            ;Retornam valors inicials
            MOVE.W (A7)+,D1
            MOVE.W (A7)+,D0
            MOVE.L (A7)+,A0

            RTS




; -----------------------------------------------------------------------------
MAPPRBIT
; PRINTS 'ZERO','ONE','TWO',...,'SEVEN' INTO THE 7-SEGMENT DISPLAYS DEPENDING
; ON THE BUTTON THAT IS PRESSED (ZERO IS THE RIGHTMOST, SEVEN IS THE LEFTMOST).
; PRINTS 'NONE' IF NO BUTTON IS PRESSED.
; INPUT    - A0 BUTTONS MAPPING ADDRESS
;            A1 7-SEGMENT DISPLAY MAPPING ADDRESS
; OUTPUT   - NONE THROUGH REGISTERS
; MODIFIES - NO REGISTER MODIFIED
; -----------------------------------------------------------------------------
            RTS


*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
