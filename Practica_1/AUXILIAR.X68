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

            ;Guardam els valors de paràmetre a la pila.
            MOVEM A0/A1/D0-D2/D7,-(A7)

            ;Guardam en D1 el numero d'iteració actual.
            MOVE.W 0,D1

            ;Preparam un DBRA per recorrer l'array de strings (8 vegades).
            MOVE.W 8,D7
            SUBQ.W #1,D7

principi_bucle:

            ;Guardam en D0 la lletra actual.
            MOVE.B (A0)+,D0

            ;A
            CMP.B #65,D0
            BEQ A
            CMP.B #97,D0
            BEQ A
            
            ;B
            CMP.B #66,D0
            BEQ B
            CMP.B #98,D0
            BEQ B

            ;C
            CMP.B #67,D0
            BEQ C
            CMP.B #99,D0
            BEQ C
            
            ;D
            CMP.B #68,D0
            BEQ D
            CMP.B #100,D0
            BEQ D

            ;E
            CMP.B #69,D0
            BEQ E
            CMP.B #101,D0
            BEQ E
            
            ;F
            CMP.B #70,D0
            BEQ F
            CMP.B #102,D0
            BEQ F

            ;G
            CMP.B #71,D0
            BEQ G
            CMP.B #103,D0
            BEQ G

            ;H
            CMP.B #72,D0
            BEQ H
            CMP.B #104,D0
            BEQ H
            ;K
            CMP.B #75,D0
            BEQ H
            CMP.B #107,D0
            BEQ H
            ;X
            CMP.B #88,D0
            BEQ H
            CMP.B #120,D0
            BEQ H

            
            ;I
            CMP.B #73,D0
            BEQ I
            CMP.B #105,D0
            BEQ I

            ;J
            CMP.B #74,D0
            BEQ J
            CMP.B #106,D0
            BEQ J

            ;L
            CMP.B #76,D0
            BEQ L
            CMP.B #108,D0
            BEQ L
            
            ;M
            CMP.B #77,D0
            BEQ M
            CMP.B #109,D0
            BEQ M
            ;N
            CMP.B #78,D0
            BEQ M
            CMP.B #110,D0
            BEQ M
            
            ;O
            CMP.B #79,D0
            BEQ O
            CMP.B #111,D0
            BEQ O
            ;Q
            CMP.B #81,D0
            BEQ O
            CMP.B #113,D0
            BEQ O
            
            ;P
            CMP.B #80,D0
            BEQ P
            CMP.B #112,D0
            BEQ P
            
            ;R
            CMP.B #82,D0
            BEQ R
            CMP.B #114,D0
            BEQ R

            ;S
            CMP.B #83,D0
            BEQ S
            CMP.B #114,D0
            BEQ S

            ;T
            CMP.B #84,D0
            BEQ T
            CMP.B #115,D0
            BEQ T

            ;U
            CMP.B #85,D0
            BEQ U
            CMP.B #116,D0
            BEQ U
            ;V
            CMP.B #86,D0
            BEQ U
            CMP.B #117,D0
            BEQ U
            ;W
            CMP.B #87,D0
            BEQ U
            CMP.B #118,D0
            BEQ U
            
            ;Y
            CMP.B #89,D0
            BEQ Y
            CMP.B #121,D0
            BEQ Y
            
            ;Z
            CMP.B #90,D0
            BEQ Z
            CMP.B #122,D0
            BEQ Z
            
            ;SPACE
            CMP.B #00,D0
            BEQ Z
            
            ;SI NO TROBA RES (CARACTER NO VALID) NO FEIM RES, CONSIDERAM A.

A:          MOVE.W #$77,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

B:          MOVE.W #$7C,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle
            
C:          MOVE.W #$39,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

D:          MOVE.W #$5E,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

E:          MOVE.W #$79,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

F:          MOVE.W #$71,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

G:          MOVE.W #$3D,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

H:          MOVE.W #$76,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

I:          MOVE.W #$30,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

J:          MOVE.W #$1E,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

L:          MOVE.W #$38,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

M:          MOVE.W #$37,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

O:          MOVE.W #$3F,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

P:          MOVE.W #$73,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

R:          MOVE.W #$50,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

S:          MOVE.W #$6D,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

T:          MOVE.W #$78,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

U:          MOVE.W #$3E,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

Y:          MOVE.W #$6E,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

Z:          MOVE.W #$5B,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

SPACE:      MOVE.W #$00,D2
            ADDA.L D1,A1
            MOVE.W D2,(A1)
            
            ADDQ.W #2,D1

            DBRA D7,principi_bucle

            JMP fi_bucle

fi_bucle:
            ;Restablim
            MOVEM (A7)+,A0/A1/D0-D2/D7
            
            RTS

; -----------------------------------------------------------------------------
BITPOS
; GIVEN A BYTE, IT RETURNS THE POSITION (VALUE BETWEEN 0 AND 7) OF THE RIGHT-
; MOST BIT VALUED ONE. IF ALL BITS ARE ZERO, OUTPUTS 8
; INPUT    - D0.B THE BYTE
; OUTPUT   - D0.B THE BIT POSITION
; MODIFIES - NO REGISTER, ASIDE OF D0.B
; -----------------------------------------------------------------------------

            RTS


*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
