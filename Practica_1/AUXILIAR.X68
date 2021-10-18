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

; -----------------------------------------------------------------------------
BITPOS
; GIVEN A BYTE, IT RETURNS THE POSITION (VALUE BETWEEN 0 AND 7) OF THE RIGHT-
; MOST BIT VALUED ONE. IF ALL BITS ARE ZERO, OUTPUTS 8
; INPUT    - D0.B THE BYTE
; OUTPUT   - D0.B THE BIT POSITION
; MODIFIES - NO REGISTER, ASIDE OF D0.B
; -----------------------------------------------------------------------------
