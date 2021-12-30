; =============================================================================
; TITLE    : SYSTEM MANAGEMENT (SYSTEM CODE)
; AUTHOR   : ANTONI BURGUERA
; HISTORY  : 05-JULY-2021 - CREATION
; COMMENTS : IT IS DIVIDED IN THREE BLOCKS:
;            - SYS : GENERIC.
;            - SCR : SCREEN MANAGEMENT.
;            - MOU : MOUSE MANAGEMENT
;            THE FORMAT OF MOUVAL AND MOUEDGE IS DESCRIBED IN SYSCONST.
; =============================================================================

; -----------------------------------------------------------------------------
SYSINIT
; INITIALIZES THE SYSTEM AS FOLLOWS:
; * DISABLES INTERRUPTS
; * CALLS SCRINIT
; * CALLS MOUINIT
; * ENABLES SIMULATOR EXCEPTION PROCESSING
; * SWITCHES TO USER
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; NOTE     - NOTE THAT INTERRUPTS REMAIN DISABLED AFTER THIS SUBROUTINE
; -----------------------------------------------------------------------------
         
;GUARDAM ELS REGISTRES A RESTAURAR.
            MOVE.L D1,-(A7)

;DESHABILITAM INTERRUPCIONS.
            OR.W    #$0700,SR
;CRIDAM A LA SUBRUTINA SCRINIT.
            JSR SCRINIT
;CRIDAM A LA SUBRUTINA MOUINIT.
            JSR MOUINIT
;HABILITAM EXECUCIONS SIMULADES.            
            MOVE.B #5,D1
            TRAP #15   
;RESTAURAM ELS REGISTRES.
            MOVE.L (A7)+,D1
;FEIM UNA COPIA DE LA DIRECCIO RTS.
            MOVE.L (A7)+,D0            
;CANVIAM A MODE USUARI.
            AND.W   #$DFFF,SR
           
;RESTAURAM LA DIRECCIO DE RETORN.
            MOVE.L D0,-(A7)

            RTS

; =============================================================================
; MOUSE MANAGEMENT (SYSTEM CODE)
; =============================================================================

; -----------------------------------------------------------------------------
MOUINIT
; INITIALIZES MOUSE AS FOLLOWS:
; * STORES CURRENT MOUSE POSITION AND BUTTON STATUS INTO MOUY, MOUX AND MOUVAL
; * CLEARS MOUEDGE
; * INSTALLS MOUREAD INTO TRAP #MOUTRAP
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - ALL REGISTERS CAN BE MODIFIED
; -----------------------------------------------------------------------------

;GUARDAM ELS REGISTRES A RESTAURAR.
            MOVEM.L D0-D1,-(A7)
            
;OBTENIM LA POSICIO I L'ESTAT DEL RATOLI.
            MOVE.B  #0,D1
            MOVE.B  #61,D0
            TRAP #15
;NETETJAM MOUSEDGE
            MOVE.B #0,MOUEDGE
        
;MOVEM LA POSICIO X I Y A LES VARIABLES.
            MOVE.W D1,MOUX    
;MOVEM 16 BITS A LA DRETA PER OBTENIR LA Y.
            LSR.W #8, D1      
            LSR.L #8, D1
            MOVE.W D1,MOUY
            
;FEIM UNA MASCARA DE L'ESTAT I LA GUARDAM.
            AND.B   #%00000111,D0
            MOVE.B D0, MOUVAL            
                        
;DESHABILITAM LES INTERRUPCIONS TEMPORALMENT.          
            ORI.W    #$0700,SR            
;INSTAL LAM LA ISR MOUREAD AL VECTOR 1. 
            MOVE.L #MOUREAD,($80+MOUTRAP*4)
;ACTIVAM LES INTERRUPCIONS VECTORITZADES.
            MOVE.B #5,D1
            MOVE.B #32,D0
            TRAP #15
;TORNAM A ACTIVAR LES INTERRUPCIONS.
            AND.W   #$F8FF,SR
            
;RESTAURAM ELS REGISTRES EMPRATS.
            MOVEM.L (A7)+,D0-D1            
            RTS

; -----------------------------------------------------------------------------
MOUREAD
; MOUSE READING TRAP SERVICE ROUTINE. IT DOES THE FOLLOWING:
; * STORES CURRENT MOUSE POSITION INTO MOUY AND MOUX.
; * STORES CURRENT BUTTON STATUS INTO MOUVAL
; * COMPUTES AND STORES MOUEDGE
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------

;GUARDAM ELS REGISTRES A RESTAURAR.
            MOVEM.L D0-D1,-(A7)
            
;OBTENIM LA POSICIO I L'ESTAT DEL RATOLI.
            MOVE.B  #0,D1
            MOVE.B  #61,D0
            TRAP #15
        
;MOVEM LA POSICIO X I Y A LES VARIABLES.
            MOVE.W D1,MOUX    
;MOVEM 16 BITS A LA DRETA PER OBTENIR LA Y.
            LSR.L #8, D1      
            LSR.L #8, D1
            MOVE.W D1,MOUY
            
;FEIM UNA MASCARA DE L'ESTAT I LA GUARDAM.
            AND.B   #%00000111,D0
            MOVE.B D0, MOUVAL    
              
;MIRAM SI MOUVAL (D0) ES DIFERENT A 0.
            CMP.W #0,D0
            BEQ .ACTEDGE   

;SI HO ES SIGNIFICA QUE HI HA UN BOTO PITJAT.
            MOVE.B #1,MOUEDGE       
;RESTAURAM ELS REGISTRES EMPRATS.
            MOVEM.L (A7)+,D0-D1            
            RTE
            
.ACTEDGE    ;SI NO HI HA CAP BOTO PITJAT POSAM 0.
            MOVE.B #0,MOUEDGE
            ;RESTAURAM ELS REGISTRES EMPRATS.
            MOVEM.L (A7)+,D0-D1
            RTE

; =============================================================================
; SCREEN MANAGEMENT (SYSTEM CODE)
; =============================================================================

; -----------------------------------------------------------------------------
SCRINIT
; INITIALIZES THE SCREEN, SCREEN-RELATED INTERRUPT AND VARS AS FOLLOWS:
; * INSTALLS SCRUPD INTO TRAP #SCRTRAP
; * SETS OUTPUT RESOLUTION TO SCRWIDTH*SCRHEIGH
; * SETS OUTPUT TO WINDOWED MODE
; * ENABLES DOUBLE BUFFER AND CLEARS BOTH SCREEN BUFFERS
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - ALL REGISTERS CAN BE MODIFIED
; -----------------------------------------------------------------------------
            MOVE.L  #SCRUPD,($80+SCRTRAP*4) ; INSTALL TRAP
            MOVE.L  #SCRWIDTH<<16|SCRHEIGH,D1 ; SET RESOLUTION
            MOVE.B  #33,D0
            TRAP    #15
            MOVE.L  #1,D1                   ; SET WINDOWED MODE
            TRAP    #15
            MOVE.W  #$FF00,D1               ; CLEAR VISIBLE BUFFER
            MOVE.B  #11,D0
            TRAP    #15
            MOVE.B  #17,D1                  ; ENABLE DOUBLE BUFFER
            MOVE.B  #92,D0
            TRAP    #15
            MOVE.W  #$FF00,D1               ; CLEAR HIDDEN BUFFER
            MOVE.B  #11,D0
            TRAP    #15
            RTS

; -----------------------------------------------------------------------------
SCRUPD
; TRAP SERVICE ROUTINE IN CHARGE OF VISUALIZING CURRENT FRAME AND CLEARING
; BUFFER FOR THE NEXT ONE. PERFORMS TWO TASKS:
; * CLEARS ACTIVE (HIDDEN) GRAPHICS BUFFER
; * SWITCHES ACTIVE AND VISIBLE GRAPHICS BUFFER
; INPUT    - NONE
; OUTPUT   - NONE
; MODIFIES - NONE
; -----------------------------------------------------------------------------
            MOVEM.W D0-D1,-(A7)
            MOVE.B  #94,D0                  ; UPDATE DOUBLE BUFFER
            TRAP    #15
            MOVE.W  #$FF00,D1               ; CLEAR HIDDEN BUFFER
            MOVE.B  #11,D0
            TRAP    #15
            MOVEM.W (A7)+,D0-D1
            RTE

*~Font name~Courier New~
*~Font size~16~
*~Tab type~0~
*~Tab size~4~
