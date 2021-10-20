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




            BTST.L #0,D0            
            BNE salt_1

Comprova_cond_2
            BTST.L #1,D0
            BNE salt_2
retorna
            RTS


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
            
            
            
            MOVE.B #32,D0
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
            
            
            
            
            MOVE.B #32,D0                   ;Sel·leccionam la tasca 33
            
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

            MOVEM.L A0-A1/D0,-(A7)
            
            MOVE.B (A0),D0                  ;Etrtreim la informació dels botons
            NOT.B   D0                      ;Feim aquesta not perque la logica
            ;dels polsador es inversa, es a dir, si esta pitjat sortira un 0
            ;i si no hi esta sort un 1. D'aquesta manera ens estalviam fer
            ;altre tipus de comprovacions
            
            JSR BITPOS                      ;Comprovam quin boto esta pitjat
            
            
            ;Depenent del boto pitjat escriurem una cosa o una altre
            CMP.B #1,D0
            BEQ     zero
            
            CMP.B #2,D0
            BEQ     uno
            
            CMP.B #3,D0
            BEQ     dos
            
            CMP.B #4,D0
            BEQ     tres
            
            CMP.B #5,D0
            BEQ     quatre
            
            CMP.B #6,D0
            BEQ     cinc
            
            CMP.B #7,D0
            BEQ     sis
            
            CMP.B #8,D0
            BEQ     set
            
            ;Si no hi ha cap boto esscriurem none
            BRA none
            
            
            ;Escrivim el text corresponent als displays fent servir la subrutin
            ;STR2SEG 
zero
            LEA TEXT,A0
            MOVE.B #'Z',(A0)+
            MOVE.B #'E',(A0)+
            MOVE.B #'R',(A0)+
            MOVE.B #'O',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            
            LEA TEXT,A0
            JSR STR2SEG
            JMP final_maprbit
            

uno
            LEA TEXT,A0
            MOVE.B #'O',(A0)+
            MOVE.B #'N',(A0)+
            MOVE.B #'E',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            
            LEA TEXT,A0
            JSR STR2SEG
            JMP final_maprbit
dos
            LEA TEXT,A0
            MOVE.B #'T',(A0)+
            MOVE.B #'W',(A0)+
            MOVE.B #'O',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            
            LEA TEXT,A0
            JSR STR2SEG
            JMP final_maprbit
tres
            LEA TEXT,A0
            MOVE.B #'T',(A0)+
            MOVE.B #'H',(A0)+
            MOVE.B #'R',(A0)+
            MOVE.B #'E',(A0)+
            MOVE.B #'E',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            
            LEA TEXT,A0
            JSR STR2SEG
            JMP final_maprbit
quatre
            LEA TEXT,A0
            MOVE.B #'F',(A0)+
            MOVE.B #'O',(A0)+
            MOVE.B #'U',(A0)+
            MOVE.B #'R',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            
            LEA TEXT,A0
            JSR STR2SEG
            JMP final_maprbit
cinc
            LEA TEXT,A0
            MOVE.B #'F',(A0)+
            MOVE.B #'I',(A0)+
            MOVE.B #'V',(A0)+
            MOVE.B #'E',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            
            LEA TEXT,A0
            JSR STR2SEG
            JMP final_maprbit

            
sis
            LEA TEXT,A0
            MOVE.B #'S',(A0)+
            MOVE.B #'I',(A0)+
            MOVE.B #'X',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            
            LEA TEXT,A0
            JSR STR2SEG
            JMP final_maprbit
set
            LEA TEXT,A0
            MOVE.B #'S',(A0)+
            MOVE.B #'E',(A0)+
            MOVE.B #'V',(A0)+
            MOVE.B #'E',(A0)+
            MOVE.B #'N',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            
            LEA TEXT,A0
            JSR STR2SEG
            JMP final_maprbit
none
            LEA TEXT,A0
            MOVE.B #'N',(A0)+
            MOVE.B #'O',(A0)+
            MOVE.B #'N',(A0)+
            MOVE.B #'E',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            MOVE.B #' ',(A0)+
            
            LEA TEXT,A0
            JSR STR2SEG
            JMP final_maprbit

;Punt de tornada d'aquesta subrutina (MAPRBIT)
final_maprbit
            MOVEM.L (A7)+,A0-A1/D0
            RTS







*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
