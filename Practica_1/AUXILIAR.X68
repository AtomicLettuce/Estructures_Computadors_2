; =============================================================================
; TITLE    : AUXILIARY CODE
; AUTHOR   :
; COMMENTS :
; HISTORY  :
; =============================================================================

; -----------------------------------------------------------------------------
STR2SEG
; CONVERTS A STRING OF 8 CHARS INTO THE 7-SEGMENT DISPLAYS WORDS SEQUENCE,
; READY TO BE SENT TO THE DISPLAYS.
; ACCEPTS CHARACTERS FROM A TO Z AND FROM a TO z AND SPACE. CAPITAL AND NON
; CAPITAL ARE DISPLAYED WITH THE SAME GRAPHIC.
; INPUT    - A0 POINTER TO THE STRING (8 CHAR)
;            A1 POINTER TO THE ADDRESS WHERE TO PUT THE WORDS SEQUENCE
; OUTPUT   - MEMORY FROM (A1) TO (A0+15) MODIFIED.
; MODIFIES - NO REGISTERS MODIFIED
; NOTE     - BEHAVIOR IN FRONT OF CHARS OUTSIDE RANGES A-Z AND a-z AND SPACE
;            IS UNDEFINED
; -----------------------------------------------------------------------------

            ;Guardam els valors de par�metre a la pila.
            MOVEM.L A0/A1/D0-D2/D7,-(A7)

            ;Feim aquesta resta perque quan just abans d'escriure al display
            ;Sumam 2 a A1. D'aquesta manera, a la primera iteraci� es com si
            ; no haguessim fet res ja que restam 2 i sumam 2
            SUBQ.W #2,A1

            ;Preparam un DBRA per recorrer l'array de strings (8 vegades).
            MOVE.W #8,D7
            SUBQ.W #1,D7

principi_bucle:

            ;Guardam en D0 la lletra actual.
            MOVE.B (A0)+,D0

            ;Identificam de quina lletra es tracta
            
            ;A
            CMP.B #'A',D0
            BEQ A
            CMP.B #'a',D0
            BEQ A
            
            ;B
            CMP.B #'B',D0
            BEQ B
            CMP.B #'b',D0
            BEQ B

            ;C
            CMP.B #'C',D0
            BEQ C
            CMP.B #'c',D0
            BEQ C
            
            ;D
            CMP.B #'D',D0
            BEQ D
            CMP.B #'d',D0
            BEQ D

            ;E
            CMP.B #'E',D0
            BEQ E
            CMP.B #'e',D0
            BEQ E
            
            ;F
            CMP.B #'F',D0
            BEQ F
            CMP.B #'f',D0
            BEQ F

            ;G
            CMP.B #'G',D0
            BEQ G
            CMP.B #'g',D0
            BEQ G

            ;H
            CMP.B #'H',D0
            BEQ H
            CMP.B #'h',D0
            BEQ H
            ;K
            CMP.B #'K',D0
            BEQ H
            CMP.B #'k',D0
            BEQ H
            ;X
            CMP.B #'X',D0
            BEQ H
            CMP.B #'x',D0
            BEQ H

            
            ;I
            CMP.B #'I',D0
            BEQ I
            CMP.B #'i',D0
            BEQ I

            ;J
            CMP.B #'J',D0
            BEQ J
            CMP.B #'j',D0
            BEQ J

            ;L
            CMP.B #'L',D0
            BEQ L
            CMP.B #'l',D0
            BEQ L
            
            ;M
            CMP.B #'M',D0
            BEQ M
            CMP.B #'m',D0
            BEQ M
            ;N
            CMP.B #'N',D0
            BEQ M
            CMP.B #'n',D0
            BEQ M
            
            ;O
            CMP.B #'O',D0
            BEQ O
            CMP.B #'o',D0
            BEQ O
            ;Q
            CMP.B #'Q',D0
            BEQ O
            CMP.B #'q',D0
            BEQ O
            
            ;P
            CMP.B #'P',D0
            BEQ P
            CMP.B #'p',D0
            BEQ P
            
            ;R
            CMP.B #'R',D0
            BEQ R
            CMP.B #'r',D0
            BEQ R

            ;S
            CMP.B #'S',D0
            BEQ S
            CMP.B #'s',D0
            BEQ S

            ;T
            CMP.B #'T',D0
            BEQ T
            CMP.B #'t',D0
            BEQ T

            ;U
            CMP.B #'U',D0
            BEQ U
            CMP.B #'u',D0
            BEQ U
            ;V
            CMP.B #'V',D0
            BEQ U
            CMP.B #'v',D0
            BEQ U
            ;W
            CMP.B #'W',D0
            BEQ U
            CMP.B #'w',D0
            BEQ U
            
            ;Y
            CMP.B #'Y',D0
            BEQ Y
            CMP.B #'y',D0
            BEQ Y
            
            ;Z
            CMP.B #'Z',D0
            BEQ Z
            CMP.B #'z',D0
            BEQ Z
            
            ;SPACE SI NO HA ESTAT CAP DELS ANTERIORS TAMB� CONSIDERAR� SPACE
            BRA SPACE
            

            ;Escrivim dins del segment que toca la lletra que toca

A:          MOVE.W #SEG_A,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

B:          MOVE.W #SEG_B,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle
            
C:          MOVE.W #SEG_C,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

D:          MOVE.W #SEG_D,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

E:          MOVE.W #SEG_E,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

F:          MOVE.W #SEG_F,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

G:          MOVE.W #SEG_E,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

H:          MOVE.W #SEG_H,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

I:          MOVE.W #SEG_I,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

J:          MOVE.W #SEG_J,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

L:          MOVE.W #SEG_L,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

M:          MOVE.W #SEG_M,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

O:          MOVE.W #SEG_O,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

P:          MOVE.W #SEG_P,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

R:          MOVE.W #SEG_R,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

S:          MOVE.W #SEG_S,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

T:          MOVE.W #SEG_T,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

U:          MOVE.W #SEG_U,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

Y:          MOVE.W #SEG_Y,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

Z:          MOVE.W #SEG_Z,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

SPACE:      MOVE.W #$0000,D2
            ADDA.L #2,A1
            MOVE.W D2,(A1)
            
            

            DBRA D7,principi_bucle

            JMP fi_bucle

fi_bucle:
            ;Restablim
            MOVEM.L (A7)+,A0/A1/D0-D2/D7
            
            RTS

; -----------------------------------------------------------------------------
BITPOS
; GIVEN A BYTE, IT RETURNS THE POSITION (VALUE BETWEEN 0 AND 7) OF THE RIGHT-
; MOST BIT VALUED ONE. IF ALL BITS ARE ZERO, OUTPUTS 8
; INPUT    - D0.B THE BYTE
; OUTPUT   - D0.B THE BIT POSITION
; MODIFIES - NO REGISTER, ASIDE OF D0.B
; -----------------------------------------------------------------------------

            ;Anam comprovant de menys pes a m�s pes amb la instrucci� BTST.
            
            ;Comprovam el bit 0.           
            BTST.L #0,D0
            ;Si hi ha un 1 posa a D1 un 0. 
            BNE BIT_ZERO
            
            ;Es fa exactament igual per els altres bits (0-7).
            
            BTST.L #1,D0
            BNE BIT_UN

            BTST.L #2,D0
            BNE BIT_DOS
            
            BTST.L #3,D0
            BNE BIT_TRES
            
            BTST.L #4,D0
            BNE BIT_QUATRE
            
            BTST.L #5,D0
            BNE BIT_CINC
            
            BTST.L #6,D0
            BNE BIT_SIS
            
            BTST.L #7,D0
            BNE BIT_SET
            
            ;Si no hi ha camp 1 posam un 8 a D0.
            MOVE.B #8,D0
            
            ;Sortim de la rutina.
            RTS

;Etiquetes per posar el valor correcte depenent de la instrucci� BTST.
BIT_ZERO:
            MOVE.B #0,D0
            RTS
BIT_UN:
            MOVE.B #1,D0
            RTS
BIT_DOS:
            MOVE.B #2,D0
            RTS
BIT_TRES:
            MOVE.B #3,D0
            RTS
BIT_QUATRE:
            MOVE.B #4,D0
            RTS
BIT_CINC:
            MOVE.B #5,D0
            RTS
BIT_SIS:
            MOVE.B #6,D0
            RTS
BIT_SET:
            MOVE.B #7,D0
            RTS








*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
