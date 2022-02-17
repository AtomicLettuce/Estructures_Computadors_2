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

    ;Copiam el punter SDB a VDB    
    MOVE.L A1,(A0)
    
    ; Netejam el byte d'estat
    ADDA #4,A0  ; Moure punter
    CLR.B (A0)
    SUBA #4,A0  ; Deixar el punter com estava

    RTS

; -----------------------------------------------------------------------------
BTNUPD
; UPDATES THE BUTTON VDB AND EXECUTES THE CALLBACK IF REQUIRED
; INPUT    : A0 - POINTER TO THE VARIABLE DATABLOCK
; OUTPUT   : NONE
; MODIFIES : NONE
; -----------------------------------------------------------------------------

    MOVEM D0-D5/A0-A2,-(A7)

    MOVE.L (A0),A1
    MOVE.L (A0),A2
    ;APUNTAM AL BYTE DE STATUS.
    ADDA #4,A0
    MOVE.W (A1)+,D0 ;Y TOP
    MOVE.W (A1)+,D1 ;X TOP
    
    MOVE.W D0,D2
    MOVE.W D1,D3
    
    ADD.W (A1)+,D2 ;X BOT
    ADD.W (A1)+,D3 ;Y BOT
    
    MOVE.W MOUX,D4 ;X ACTUAL
    MOVE.W MOUY,D5 ;Y ACTUAL
    
    CMP D4,D1 ;COMP X ESQ SUP
    BGE .FORA 

    CMP D5,D0 ;COMP Y ESQ SUP
    BGE .FORA
    
    CMP D4,D3 ;COMP X ESQ INF
    BLE .FORA
    
    CMP D5,D2 ;COMP Y ESQ INF
    BLE .FORA

;MIRAM L'ESTAT DE MOUEDGE PER SI S'HA FET CLICK  
    CMP.B #0,(MOUEDGE)
    BNE .CLICK
;SINO S'HA FET CLICK MIRAM SI ESTA PITJAT (MANTINGUT)
    CMP.B #0,(MOUVAL)
    BNE .PRESS
;SI ESTAVA DEDINS PERO NO PITJAT MOVEM #1 A NES BIT D'STATUS    
    MOVE.B #%0001,(A0)
;RESTAURAM REGISTRES        
.FI MOVEM (A7)+,D0-D5/A0-A2
    RTS 
;MOVEM #3 A A NES BIT D'STATUS I SORTIM
.PRESS
    MOVE.B #%0011,(A0)
    BRA .FI

.CLICK
;MOVEM #5 A NES BIT D'ESSTATUS 
    MOVE.B #%0101,(A0)
;OBTENIM LA DIRECCIO DEL CALLBACK I L'EXECUTAM
    MOVEA.L (A1),A2
    JSR (A2)
;SORTIM RESTAURANT REGISTRES.
    BRA .FI
    
.FORA    
;SI ESTA FORA DEL BOTO BIT D'STATUS A 0.
    MOVE.B #0,(A0)    
    BRA .FI

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

;Guardam registres
    MOVEM.L D0-D7/A0-A2,-(A7)

; Definim les caracteristiques del llapis que pinta
    
; PEN WIDTH
    MOVE.B #BTNPENWD,D1
    MOVE.W #93,D0
    TRAP #15
    
;CONTOUR COLOUR
    MOVE.L #BTNPENCL,D1
    MOVE #80,D0
    TRAP #15

;FILL COLOUR SWITCH
    ADDA #4,A0
    CMP.B #0,(A0)
    BEQ .MOUTSIDE
    
    BTST.B #1,(A0)
    BNE .MOUPRESSED
    
; FILL COLOUR si dins pero no pitjat    
    MOVE.L #BTNSELCL,D1
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
    MOVE.L #BTNPRSCL,D1
    MOVE.W #81,D0
    TRAP #15
    BRA .SORTIDA
    
.SORTIDA
    ; A0 torna a apuntar a l'inici de VDB i A1 a l'inici de SDB
    SUBA #4,A0
    MOVE.L (A0),A1    
    
    ; Neteja de registres per evitar problemes
    CLR.L D1
    CLR.L D2
    CLR.L D3
    CLR.L D4
    ; Obtencio coordenades
    MOVE.W (A1)+,D2 ; UPPER Y
    MOVE.W (A1)+,D1 ; LEFT X
    MOVE.W D1,D3    
    MOVE.W D2,D4
    
    MOVE.W (A1)+,D5 ; HEIGHT
    MOVE.W (A1)+,D6 ; WIDTH
    
    ADD.W D5,D4 ; LOWER Y
    ADD.W D6,D3 ; RIGHT X

    ; Dibuixam el rectangle com amb les especificacions de llapis definides
    MOVE.W #87,D0
    TRAP #15
    
    ; Escrivim el text
    ADDA #4,A1
    DIVU.W #2,D5
    ADD D5,D2   ; Y COORD

    MOVEA.L A1,A2 

;HEM D'OBTENIR EL NUMERO DE CARACTERS PER CENTRAR EL TEXT.
.SIZESTR   
;EMPRAM D7 PER DUR EL COMPTE
    ADDQ.W  #1,D7
;A2 APUNTA A LA CADENA DE CARACTERS I COMPROVAM AMB NULL.   
    CMP.B   #0,(A2)+
;SI NO ES NULL NO HEM ACABAT    
    BNE .SIZESTR    
;QUAN SORTIGUEM TENDREM UN EXTRA.
    SUBQ.W #1,D7
    
;UN CARACTER = 8BITS
    LSL.W #3,D7
    
;PER CENTRAR LA X EMPRAM : RECT_LEFT + (WIDTH - TEXT)/2
    SUB.W D7,D6
    LSR.W #1,D6
    ADD.W D6,D1    

    SUB.W #8,D2 ; RESTAUM UN ACRACTER PER TAL QUE LA Y QUEDI CENTRADA.
    MOVE.W #95,D0
    TRAP #15

;RESTAURAM ELS  REGISTRES
    MOVEM.L (A7)+,D0-D7/A0-A2

    RTS
*~Font name~Courier New~
*~Font size~16~
*~Tab type~1~
*~Tab size~4~
