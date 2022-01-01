; =============================================================================
; TITLE    : BUTTON MANAGEMENT
; AUTHOR   : ANTONI BURGUERA
; HISTORY  : 05-JULY-2021 - CREATION
; COMMENTS : * A BUTTON IS DEFINED BY A STATIC DATA BLOCK (SDB), WHICH DOES NOT
;              CHANGE OVER TIME, AND A VARIABLE DATA BLOCK (VDB), THAT CAN
;              CHANGE OVER TIME. CHANGES IN THE VDB ARE PRODUCED WHEN CALLING
;              SUBROUTINE BTNUPD.
;
;            * THE BUTTON SDB (CAN BE IN ROM) HAS THE FOLLOWING FIELDS. THE
;              NUMBER DENOTES THE OFFSET WITH RESPECT TO THE SDB START:
;
;                +0  - WORD - YTOP COORDINATE (PIXELS)
;                +2  - WORD - XLEFT COORDINATE (PIXELS)
;                +4  - WORD - HEIGHT (PIXELS)
;                +6  - WORD - WIDTH (PIXELS)
;                +8  - LONG - CALLBACK POINTER
;                +12 - BYTE STRING - ZERO TERMINATED STRING. TEXT TO SHOW.
;
;            * THE BUTTON VDB (MUST BE IN RAM) IS:
;
;                +0 - LONG - POINTER TO THE STATIC DATABLOCK
;                +4 - BYTE - STATUS WITH FORMAT XXXXXCPI WHERE:
;                            - I (BIT 0) - 1=MOUSE INSIDE, 0=MOUSE OUTSIDE
;                            - P (BIT 1) - 1=MOUSE PRESSED INSIDE
;                                          0=MOUSE NOT PRESSED INSIDE
;                            - C (BIT 2) - 1=MOUSE CLICKED INSIDE
;                                          0=MOUSE NOT CLICKED INSIDE
;                            NOTE THAT IF I=0 THEN P=C=0, IF I=1 AND P=0
;                            THEN C=0.
; =============================================================================

; -----------------------------------------------------------------------------
BTNINIT
; INITIALIZES THE BUTTON BY:
;  * COPYING THE SDB POINTER INTO THE VDB.
;  * CLEARING THE STATUS BYTE.
; INPUT    : A0 - POINTER TO THE VARIABLE DATABLOCK
;            A1 - POINTER TO THE STATIC DATABLOCK
; OUTPUT   : NONE
; MODIFIES : NONE
; -----------------------------------------------------------------------------

; TODO : PLACE YOUR CODE HERE



    ;Copiam el punter SDB a VDB
    
    MOVE.L (A1),(A0)
    
    ; Netejam el byte d'estat
    ADDA #4,A1  ; Moure punter
    CLR.B (A1)
    SUBA #4,A1  ; Deixar el punter com estava

    RTS



; -----------------------------------------------------------------------------
BTNUPD
; UPDATES THE BUTTON VDB AND EXECUTES THE CALLBACK IF REQUIRED
; INPUT    : A0 - POINTER TO THE VARIABLE DATABLOCK
; OUTPUT   : NONE
; MODIFIES : NONE
; -----------------------------------------------------------------------------

; TODO : PLACE YOUR CODE HERE






    RTS




; -----------------------------------------------------------------------------
BTNPLOT
; PLOTS THE BUTTON. A RECTANGLE IS DRAWN WITH THICKNESS BTNPENWD. THE CONTOUR
; COLOR IS BTNPENCL. THE FILL COLOR IS BLACK IF THE MOUSE IS NOT INSIDE,
; BTNSELCL IF THE MOUSE IS INSIDE BUT THE MOUSE BUTTON IS NOT PRESSED AND
; BTNPRSCL IF THE MOUSE BUTTON IS PRESSED INSIDE.
; INPUT    : A0 - POINTER TO THE VARIABLE DATABLOCK
; OUTPUT   : NONE
; MODIFIES : NONE
; -----------------------------------------------------------------------------

; TODO : PLACE YOUR CODE HERE

;Guardam registres
    MOVEM.L D0-D4/A0-A1,-(A7)

; Definim les caracteristiques del llapis que pinta
    
; PEN WIDTH
    MOVE.B BTNPENWD,D1
    MOVE.W #93,D0
    TRAP #15
    
;CONTOUR COLOUR
    MOVE.L  BTNPENCL,D1
    MOVE #80,D0
    TRAP #15

;FILL COLOUR SWITCH
    ADDA #4,A0
    CMP.B #0,(A0)
    BEQ .MOUTSIDE
    
    BTST.B #1,(A0)
    BNE .MOUPRESSED
    

; FILL COLOUR si dins pero no pitjat    
    MOVE.L BTNSELCL,D1
    MOVE.W #81,D0
    TRAP #15
    BRA .SORTIDA
     
    
; FILL COLOUR si no hi ha el ratoli damunt
.MOUTSIDE
    MOVE.L #0,D1
    MOVE.W #81,D0
    TRAP #15
    BRA .SORTIDA

;FILL COLOUR si dins i pitjat
.MOUPRESSED
    MOVE.L BTNPRSCL,D1
    MOVE.W #81,D0
    TRAP #15
    BRA .SORTIDA
    


.SORTIDA
    ; A0 torna a apuntar a l'inici de VDB
    SUBA #4,A0
    MOVE.L (A0),A1
    
    ; Obtencio coordenades
    MOVE.W (A1)+,D2 ; UPPER Y
    MOVE.W (A1)+,D1 ; LEFT X
    MOVE.W D1,D3    
    MOVE.W D2,D4
    
    ADD.W (A1)+,D4 ; LOWER Y
    ADD.W (A1)+,D3 ; RIGHT X
    
    
    ; Dibuixam el rectangle com amb les especificacions de llapis definides
    MOVE.W #87,D0
    TRAP #15
    
    ; Ara a1 torna a apuntar a l'inici de SDB
    MOVE.L (A0),A1
    





;Ressetejam registres
    MOVEM.L (A7)+,D0-D4/A0-A1

    RTS


*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
