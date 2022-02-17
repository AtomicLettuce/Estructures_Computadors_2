; =============================================================================
; TITLE    : GRID MANAGEMENT
; AUTHOR   : ANTONI BURGUERA
; HISTORY  : 05-JULY-2021 - CREATION
; COMMENTS : * THERE ARE TWO MATRICES (GRDMATR0 AND GRDMATR1) AND TWO POINTERS
;              TO THESE MATRICES (GRDSRC AND GRDDST).
;
;            * THE MATRIX TO BE PLOTTED IS ALWAYS THE ONE POINTED BY GRDDST.
;
;            * THE MATRIX TO BE UPDATED BY THE MOUSE (GRDMUPD) IS ALWAYS THE
;              ONE POINTED BY GRDDST.
;
;            * THE RULES-UPDATE (GRDRUPD) SWITCHES THE POINTERS AND THEN READS
;              THE NEW SOURCE MATRIX (GRDSRC) TO DETERMINE THE NUMBER OF
;              NEIGHBORS. THE RESULTING CELL VALUE IS WRITTEN TO THE DESTINA-
;              TION MATRIX, POINTED BY GRDDST.
; =============================================================================

; -----------------------------------------------------------------------------
GRDINIT
; INITIALIZE THE GRID AS FOLLOWS:
; * POINTS THE SOURCE GRID POINTER TO GRDMATR0.
; * POINTS THE DESTINATION GRID POINTER TO GRDMATR1.
; * RESETS THE COUNTERS (GRDNPLR1, GRDNPLR2, GRDNGEN).
; * FILLS THE TWO MATRICES (GRDMATR0 AND GRDMATR1) WITH ZEROS.
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; -----------------------------------------------------------------------------
            MOVEM.L A0/D0,-(A7)
            MOVE.L  #GRDMATR0,(GRDSRC)
            MOVE.L  #GRDMATR1,(GRDDST)
            CLR.W   (GRDNPLR1)
            CLR.W   (GRDNPLR2)
            CLR.W   (GRDNGEN)
            LEA     GRDMATR0,A0
            MOVE.W  #GRDWIDTH*GRDHEIGH*2-1,D0
.LOOP       CLR.B   (A0)+
            DBRA.W  D0,.LOOP
            MOVEM.L (A7)+,A0/D0
            RTS

; -----------------------------------------------------------------------------
GRDMUPD
; GRID UPDATE USING MOUSE. THE INTERFACE IS AS FOLLOWS:
; * IF MOUSE IS NOT PRESSED OR IS OUTSIDE THE PLOTTED GRID, DOES NOTHING.
; * IF LEFT MOUSE BUTTON IS PRESSED INSIDE THE GRID:
;   - A PLAYER 1 (VALUE=1) CELL IS CREATED AT THE MOUSE POSITION IF THE MOUSE
;     IS ON THE LEFT HALF OF THE GRID.
;   - A PLAYER 2 (VALUE=2) CELL IS CREATED AT THE MOUSE POSITION IF THE MOUSE
;     IS ON THE RIGHT HALF OF THE GRID.
; * IF RIGHT MOUSE BUTTON IS PRESSED INSIDE THE GRID, THE CELL WHERE THE MOUSE
;   IS IS CLEARED (VALUE=0).
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; -----------------------------------------------------------------------------

            MOVEM.L D0-D5/A0,-(A7)
            
;NOMES VOLEM CANVIAR LA CASELLA QUAN HI HA UN BOTO PITJAT.
            CMP.B   #0,MOUVAL
            BEQ     .FORA
;A0 HA D'APUNTAR A LA MATRIU DST.
            MOVE.L  GRDDST,A0
;OBTENIM X I Y ACTUALS.
            MOVE.W  MOUX,D0
            MOVE.W  MOUY,D1
;OBTENIM LES COORDENADES QUE DELIMITEN.
            MOVE.W  #GRDXOFF,D2
            MOVE.W  #GRDYOFF,D3
            
            MOVE.W  #GRDXOFF,D4
            MOVE.W  #GRDYOFF,D5

            ADD.W   #GRDPXWID,D4
            ADD.W   #GRDPXHEI,D5
            
            CMP D0,D2 ;COMP X ESQ SUP
            BGE .FORA 

            CMP D1,D3 ;COMP Y ESQ SUP
            BGE .FORA
    
            CMP D0,D4 ;COMP X ESQ INF
            BLE .FORA
    
            CMP D1,D5 ;COMP Y ESQ INF
            BLE .FORA
            
;PODEM REUTILITZAR D4 I D5
;OBTENIM LA DIFERENCIA.
            SUB.W D2,D0
            SUB.W D3,D1
;OBTENIM LA POSICIO RELATIVA AL CANTO SUPERIOR ESQUERRA
            DIVU.W #GRDPXWID/GRDWIDTH,D0    ;COL          
            DIVU.W #GRDPXWID/GRDWIDTH,D1    ;FIL
;FEIM UNA AND PER ELIMINAR EL RESIDU        
            AND.L #$00FF,D0                 
            AND.L #$00FF,D1
;GUARDAM LA COLUMNA EN UN ALTRE REGISTRE
            MOVE.W D0,D6
;OBTENIM L'OFFSET FINAL : OFF = FIL * N.COL + COL
            MULU.W #GRDWIDTH,D1              
            ADD.W  D1,D0
;APUNTAM AL BIT CALCULAT.                     
            ADDA.W D0,A0                    
            
;MIRAM SI S'HA PITJAT EL BOTO DRET.
            CMP.B #MOUMSKRT,MOUVAL          
            BEQ .CELRESET
 
            CMP.B #MOUMSKMD,MOUVAL
            BEQ .FORA
            
            
;SI ES INFERIOR A LA MITAT (CASELLES) ES TRACTA DEL P1            
            CMP.W #(GRDMSWID/2),D6    
            BLE .CELP1                      
;SI NO HEM BOTAT ES TRACTA DE P2.
            MOVE.B #2,(A0)                              
.FORA       ;RESTAURAM REGISTRES I SORTIM
            MOVEM.L (A7)+,D0-D5/A0
            RTS

.CELRESET   ;PER NETEJTJAR UNA CASELLA MOVEM UN 0.  
            MOVE.B #0,(A0)                 
            BRA .FORA
            
.CELP1      ;PER DESIGNAR P1 MOVEM UN 1.  
            MOVE.B #1,(A0)
            BRA .FORA
            
; -----------------------------------------------------------------------------
GRDRUPD
; UPDATES THE GRID ACCORDING TO 2-PLAYER GAME OF LIFE RULES AS FOLLOWS:
; * ADDS 1 TO THE NUMBER OF GENERATIONS (GRDNGEN)
; * SWITCHES THE MATRIX POINTERS (GRDDST AND GRDSRC).
; * CHECKS THE NEIGHBORS USING THE NEW SOURCE MATRIX (POINTER BY GRDSRC)
; * THE RESULTS OF APPLYING THE RULES ARE WRITTEN INTO THE NEW DESTINATION
;   MATRIX (POINTED BY GRDDST).
; * THE RULES ARE THE FOLLOWING, WHERE P1 AND P2 ARE 1 AND 2 RESPECTIVELY,
;   DEAD CELLS ARE REPRESENTED BY 0 AND NP1 AND NP2 DENOTE THE NUMBER OF
;   PLAYER 1 AND PLAYER 2 NEIGHBORS RESPECTIVELY:
;   + SURVIVAL RULES
;     - IF CELL IS P1 AND NP1-NP2 IS 2 OR 3 -> NEW VALUE IS P1
;     - IF CELL IS P1 AND NP1-NP2 IS 1 AND NP1>=2 -> NEW VALUE IS P1
;     - OTHERWISE -> NEW VALUE IS 0
;     - IF CELL IS P2 AND NP2-NP1 IS 2 OR 3 -> NEW VALUE IS P2
;     - IF CELL IS P2 AND NP2-NP1 IS 1 AND NP2>=2 -> NEW VALUE IS P2
;     - OTHERWISE -> NEW VALUE IS 0
;   + BIRTH RULES
;     - THE CELL HAS EXACTLY THREE P1 NEIGHBOURS AND THE NUMBER
;       OF P2 NEIGHBOURS IS DIFFERENT FROM THREE. IN THIS CASE A
;       P1 TOKEN IS BORN IN THE CELL.
;     - THE CELL HAS EXACTLY THREE P2 NEIGHBOURS AND THE NUMBER
;       OF P1 NEIGHBOURS IS DIFFERENT FROM THREE. IN THIS CASE A
;       P2 TOKEN IS BORN IN THE CELL.
;     - THE CELL HAS EXACTLY THREE WHITE AND THREE BLACK NEIGHBOURS.
;       IN THIS CASE AN UNBIASED COIN DETERMINES WHETHER A WHITE OR
;       BLACK TOKEN IS BORN IN THE CELL.
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; -----------------------------------------------------------------------------

            MOVEM.L D0-D7/A0-A6,-(A7)
;SUMAM UNA GENERACIO.
            ADDQ.W #1, GRDNGEN              
;INTERCANVIAM ELS PUNTERS DE LES GRAELLES
            MOVE.L GRDDST,D0
            MOVE.L GRDSRC,GRDDST
            MOVE.L D0,GRDSRC          
            CLR.L D0
;OBTENIM EL PUNTER DE LA CEL·LDA
            MOVE.L GRDSRC,A0       
;COORD X I Y DINS LA MATRIU            
            MOVE.W #0,D1                    ; Coord X dins matriu
            MOVE.W #0,D2                    ; Coord Y dins matriu
          
;INDEX D'ITERACIO BULCE 1
            MOVE.W #(GRDHEIGH-1),D7         
.BUCLE1
;INDEX D'ITERACIO BULCE 2
            MOVE.W #(GRDWIDTH-1),D6        
            BRA .BUCLE2

.FINBUCLE2
;RESETETJAM CORD X I ACTUALITZAM CORD Y
            MOVE.W #0,D1                    
            ADDQ.W #1,D2             
       
            DBRA D7, .BUCLE1  
            BRA .FINBUCLE1          
            
.BUCLE2     
;EVALUAM SI LA CELDA VIU O MOR.
            CMP.B #0,(A0)                   
            BEQ .MORTA   
.VIVA            
            JSR SURVIVE
.FIN_CELLA
;ACTUALITZAM CORD X I EL PUNTER A LA CELDA.
            ADDQ.W #1,D1                    
            ADDQ.L #1,A0                
            DBRA D6, .BUCLE2
            BRA .FINBUCLE2

.MORTA      ;COMPROVAM SI POT NEIXER.
            JSR BIRTH                       
            BRA .FIN_CELLA
            
.FINBUCLE1  ;RESTAUARAM REGISTRES
            MOVEM.L (A7)+,D0-D7/A0-A6
            RTS
; -----------------------------------------------------------------------------
BIRTH
; COMPROVA I ACTUALITZA SI ES NECESARI SI UNA CEL.LA NEIX O NO
; INPUT     : A0 - PUNTER A LA CEL.LA CORRESPONENT
;             0D1 - COORDENADA X DE LA CEL.LA
;             1D2 - COORDENADA Y DE LA CEL.LA
; OUTPUT   : NONE
; MODIFIES : (A0) SI RESULTA QUE HA DE NEIXER
; -----------------------------------------------------------------------------
            MOVEM.L D0-D5/D7/A0-A2,-(A7)
;MOVEM EL PUNTER DE GRDDST A A2
            MOVE.L GRDDST,A2
;FEIM UNA COPIA DE LA COORDENADA Y            
            MOVE.W D2,D3
;DIVIDIM AMB DESPLAÇAMENTS            
            LSL.L #GRDSHWID,D3            
            ADD.W D1,D3
;OBTENIM EL PUNTER DE LA MATEIXA CASELLA PERO A GRDDST.            
            ADDA D3,A2             
            CLR.L D3
;OBTENIM LA CORD X DE LA CEL·LA VEINA                       
            MOVE.W D1,D0                    
            SUBQ.W #1,D0
            AND.W #GRDMSWID,D0
;OBTENIM LA CORD Y DE LA CEL·LA VEINA            
            MOVE.W D2,D7                    
            SUBQ.W #1,D7
            AND.W #GRDMSHEI,D7
            
;NETETJAM ELS COMPTADORS
            CLR.W .COMPTP1                       
            CLR.W .COMPTP2                       
            
;COMPROVAM LES CEL·LDES VEINES.
            MOVE.W #3,D3                    ;INDEX LOOP 1 
            DBRA D3,.LOOP1
.LOOP1
            MOVE.W #2,D4                    ;INDEX LOOP 2
            BRA .LOOP2
.FINLOOP2   
;ACTUALITZAM CORD Y CEL·LA VEINA
            ADDQ #1,D7                      
            AND.W #GRDMSHEI,D7

;RESETETJAM CORD X            
            MOVE.W D1,D0                    
            SUBQ.W #1,D0
            AND.W #GRDMSWID,D0 
     
            DBRA D3,.LOOP1
            BRA .FINLOOP1            
            
.LOOP2      ;APUNTAM A INICI DE LA MATRIU
            MOVE.L GRDSRC, A1   
            MOVE.W D7, D5      
;COM WIDTH ES POTENCIA DE 2 PODEM MULTIPLICAR AMB DESPLAÇAMENTS.             
            LSL.W #GRDSHWID,D5               
;APUNTAM A LA CEL·LA VEINA
            ADD.W D0,D5
            ADDA D5,A1                      

;COMPROVAM ELS DIFERENTS CASOS
            CMP.B #0,(A1) ;CAS BUID                 
            BEQ .FINCAS
            
            CMP.B #1,(A1) ;CAS P1
            BEQ .CASP1
            
            ;CAS P2
            ADDQ.W #1,.COMPTP2
            BRA .FINCAS
            
.CASP1      ;INCREMENTAM EL COMPTADOR DEL P1
            ADDQ.W #1,.COMPTP1                                 
.FINCAS     ;ACTUALITZAM CORD X VEINA
            ADDQ  #1,D0                      
            AND.W #GRDMSWID,D0            

            DBRA D4,.LOOP2
            BRA .FINLOOP2             
            
.FINLOOP1

; DETERMINAR QUE PASSA

; Com amb el bucle hem considerat que la propia cel.la a avaluar es una cel.la
; veina, hem de restar 1 al comptador de p1 o p2 depenent de si la cel.la era
; originalment una cel.la p1 o p2 (continuam era una cal.la buida)

            CMP.B #1,(A0)
            BEQ .REST_P1
            
            CMP.B #2,(A0)
            BEQ .REST_P2
            
            BRA .CONTINUAR

.REST_P1
            SUBQ.W #1, .COMPTP1
            BRA .CONTINUAR
.REST_P2
            SUBQ.W #1,.COMPTP2

.CONTINUAR
;COMPROVAM SI HI HA EXACTAMENT 3 CEL·LES P1
            CMP.W #3,.COMPTP1           
            BEQ .P1_3
            
            CMP.W #3, .COMPTP2
            BEQ .P2_3
;CAS MORT
            MOVE.B #0,(A2)
            BRA .FIN                    
.P1_3       ;COMPROVAM SI HI HA EMPAT
            CMP.W #3,.COMPTP2        
            BEQ .P1_P2_3
                        
            MOVE.B #1,(A2) ;CAS P1 
            BRA .FIN
           
.P1_P2_3    ;CAS EMPAT 
            JSR UTLRAND
            MOVE.B D1,(A2)
            BRA .FIN    
        
.P2_3       ;CAS P2
            MOVE.B #2,(A2)
.FIN        ;RESTAURAM REGISTRES EMPRATS   
            MOVEM.L (A7)+,D0-D5/D7/A0-A2
            RTS
            
.COMPTP1     DC.W    0
.COMPTP2     DC.W    0
            
; -----------------------------------------------------------------------------
SURVIVE
; COMPROVA (I ACTUALITZA SI ES NECESARI) SI UNA SEGUEIX VIVA O NO
; INPUT     : A0 - PUNTER A LA CEL.LA CORRESPONENT
;             D1 - COORDENADA X DE LA CEL.LA
;             D2 - COORDENADA Y DE LA CEL.LA
; OUTPUT   : NONE
; MODIFIES : (A0) SI RESULTA QUE HA DE MORIR
; -----------------------------------------------------------------------------

            MOVEM.L D0-D7/A0-A2,-(A7)
            
;MOVEM EL PUNTER DE GRDDST A A2
            MOVE.L GRDDST,A2
;FEIM UNA COPIA DE LA COORDENADA Y            
            MOVE.W D2,D3
;DIVIDIM AMB DESPLAÇAMENTS            
            LSL.L #GRDSHWID,D3            
            ADD.W D1,D3
;OBTENIM EL PUNTER DE LA MATEIXA CASELLA PERO A GRDDST.            
            ADDA D3,A2             

;OBTENIM LA CORD X DE LA CEL·LA VEINA                       
            MOVE.W D1,D0                    
            SUBQ.W #1,D0
            AND.W #GRDMSWID,D0
;OBTENIM LA CORD Y DE LA CEL·LA VEINA            
            MOVE.W D2,D7                    
            SUBQ.W #1,D7
            AND.W #GRDMSHEI,D7
            
;NETETJAM ELS COMPTADORS
            CLR.W .COMPTP1                       
            CLR.W .COMPTP2        
            
;COMPROVAM LES CELDES VEINES
            MOVE.W #3,D3
            DBRA D3,.LOOP1 ;INDEX LOOP1               
.LOOP1
            MOVE.W #2,D4 ;INDEX LOOP2
            BRA .LOOP2
.FINLOOP2   
;ACTUALITZAM CORD Y CEL·LA VEINA
            ADDQ #1,D7                      
            AND.W #GRDMSHEI,D7

;RESETETJAM CORD X            
            MOVE.W D1,D0                    
            SUBQ.W #1,D0
            AND.W #GRDMSWID,D0 
     
            DBRA D3,.LOOP1
            BRA .FINLOOP1            
            
.LOOP2      ;APUNTAM A INICI DE LA MATRIU
            MOVE.L GRDSRC, A1   
            MOVE.W D7, D5      
;COM WIDTH ES POTENCIA DE 2 PODEM MULTIPLICAR AMB DESPLAÇAMENTS.             
            LSL.W #GRDSHWID,D5               
;APUNTAM A LA CEL·LA VEINA
            ADD.W D0,D5
            ADDA D5,A1                      

;COMPROVAM ELS DIFERENTS CASOS
            CMP.B #0,(A1) ;CAS BUID                 
            BEQ .FINCAS
            
            CMP.B #1,(A1) ;CAS P1
            BEQ .CASP1
            
            ;CAS P2
            ADDQ.W #1,.COMPTP2
            BRA .FINCAS
            
.CASP1      ;INCREMENTAM EL COMPTADOR DEL P1
            ADDQ.W #1,.COMPTP1                                 
.FINCAS     ;ACTUALITZAM CORD X VEINA
            ADDQ  #1,D0                      
            AND.W #GRDMSWID,D0            

            DBRA D4,.LOOP2
            BRA .FINLOOP2             
            
.FINLOOP1
; DETERMINAR QUE PASSA

; Com amb el bucle hem considerat que la propia cel.la a avaluar es una cel.la
; veina, hem de restar 1 al comptador de p1 o p2 depenent de si la cel.la era
; originalment una cel.la p1 o p2 (continuam era una cal.la buida)

            CMP.B #1,(A0)
            BEQ .REST_P1
            
            CMP.B #2, (A0)
            BEQ .REST_P2
            
            BRA .CONTINUAR

.REST_P1
            SUBQ.W #1, .COMPTP1
            BRA .CONTINUAR
.REST_P2

            SUBQ.W #1, .COMPTP2

.CONTINUAR

;COMPROVAR SI LA CEL·LA ES DE P1 O P2
            CMP.B #2,(A0)                   
;CAS P2
            BEQ .CAS_P2
            
;CAS P1
            MOVE.W .COMPTP1,D0
            SUB.W .COMPTP2,D0
;IF CELL IS P1 AND NP1-NP2 IS 2 OR 3 -> NEW VALUE IS P1
            CMP.W #2,D0
            BEQ .P1_VIU
            
            CMP.W #3,D0
            BEQ .P1_VIU
;IF CELL IS P1 AND NP1-NP2 IS 1 AND NP1>=2 -> NEW VALUE IS P1
            CMP.W #1,D0
            BEQ .P1_2COND            
            BRA .MORT
            
.P1_2COND
            CMP.W #2,.COMPTP1
            BGE .P1_VIU
            BRA .MORT            
            
.P1_VIU
            MOVE.B #1,(A2)
            BRA .FIN          
            
.CAS_P2
            MOVE.W .COMPTP2,D0
            SUB.W .COMPTP1,D0
;IF CELL IS P1 AND NP1-NP2 IS 2 OR 3 -> NEW VALUE IS P1
            CMP.W #2,D0
            BEQ .P2_VIU
            
            CMP.W #3,D0
            BEQ .P2_VIU
;IF CELL IS P1 AND NP1-NP2 IS 1 AND NP1>=2 -> NEW VALUE IS P1
            CMP.W #1,D0
            BEQ .P2_2COND            
            BRA .MORT
.P2_2COND
            CMP.W #2,.COMPTP2
            BGE .P2_VIU
            BRA .MORT            
            
.P2_VIU
            MOVE.B #2,(A2)
            BRA .FIN          
        
.MORT
            MOVE.B #0,(A2)
            BRA .FIN            
.FIN            
            MOVEM.L (A7)+,D0-D7/A0-A2
            RTS
            
.COMPTP1     DC.W    0
.COMPTP2     DC.W    0

; -----------------------------------------------------------------------------
GRDSAVE
; SAVES THE GRID INTO A FILE IN CSV FORMAT
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; NOTE     : THE LOCAL BUFFER SIZE MUST BE MAX(512,2*GRDWIDTH+1). PLEASE CHANGE
;            IT ACCORDINGLY IF GRDWIDTH*2+1 IS LARGER THAN 512.
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7/A0-A6,-(A7)       ; TO BE OPTIMIZED
            MOVE.B  #50,D0                  ; CLOSE ALL FILES (RECOMMENDED)
            TRAP    #15
            SUB.L   #512,A7                 ; ROW BUFFER IN LOCAL MEMORY
            MOVE.B  #58,D0                  ; SHOW FILE DIALOG TASK
            MOVE.L  #1,D1                   ; DISPLAY SAVE DIALOG
            LEA     .MSG,A1                 ; STANDARD MESSAGE
            LEA     .FILTER,A2              ; NO FILTER
            MOVE.L  A7,A3                   ; FILE NAME BUFFER
            CLR.W   (A3)                    ; ENSURE THERE IS NO STRING
            TRAP    #15
            TST.B   D1
            BEQ     .END                    ; IF CANCELLED, DO NOTHING
            MOVE.L  A3,A1                   ; PLACE THE FILENAME INTO A1
            MOVE.B  #52,D0                  ; CREATE NEW FILE
            TRAP    #15
            TST.W   D0                      ; CHECK CREATION ERROR
            BNE     .END                    ; DO NOTHING MORE IF ERROR
            MOVE.L  A7,A6                   ; PUT A6 INTO START OF BUFFER
            MOVE.L  A7,A1                   ; PUT A1 INTO START OF BUFFER
            MOVE.L  (GRDDST), A0            ; A0: POINTER TO THE DATA TO WRITE
            MOVE.W  #GRDHEIGH-1,D3          ; D3: NUMBER OF ROWS - 1
.LOOPY      MOVE.W  #GRDWIDTH-1,D2          ; D2: NUMBER OF COLUMNS - 1
.LOOP       MOVE.B  #'0',D0                 ; ADD CHAR '0' AND THE CELL VALUE
            ADD.B   (A0)+,D0
            MOVE.B  D0, (A6)+               ; STORE IT IN THE BUFFER
            MOVE.B  #',',(A6)+              ; NOW PUT THE COMMA
            DBRA.W  D2,.LOOP
            MOVE.B  #$0D,-1(A6)             ; STORE CARRIAGE RETURN (REMOVE ',')
            MOVE.B  #$0A,(A6)               ; STORE LINE FEED
            MOVE.B  #54,D0                  ; WRITE TO FILE TASK NUMBER
            MOVE.L  #GRDWIDTH*2+1,D2        ; NUMBER OF BYTES TO WRITE
            TRAP    #15                     ; WRITE (A1 IS ALREADY THERE)
            MOVE.L  A1,A6                   ; GO BACK TO THE BUFFER START
            DBRA.W  D3,.LOOPY
            MOVE.B  #56,D0                  ; CLOSE FILE
            TRAP    #15
.END        ADD.L   #512,A7                 ; RESTORE STACK
            MOVEM.L (A7)+,D0-D7/A0-A6       ; TO BE OPTIMIZED
            RTS
.MSG        DC.B    'SELECT A CSV FILE TO SAVE',0
.FILTER     DC.B    '*.CSV',0
            DS.W    0

; -----------------------------------------------------------------------------
GRDLOAD
; LOADS THE GRID FROM A CSV FORMATTED FILE
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; NOTE     : THE LOCAL BUFFER SIZE MUST BE MAX(512,2*GRDWIDTH+1). PLEASE CHANGE
;            IT ACCORDINGLY IF GRDWIDTH*2+1 IS LARGER THAN 512.
; -----------------------------------------------------------------------------
            MOVEM.L D0-D7/A0-A6,-(A7)       ; TO BE OPTIMIZED
            MOVE.B  #50,D0                  ; CLOSE ALL FILES (RECOMMENDED)
            TRAP    #15
            SUB.L   #512,A7                 ; ROW BUFFER IN LOCAL MEMORY
            MOVE.B  #58,D0                  ; SHOW FILE DIALOG TASK
            CLR.L   D1                      ; DISPLAY LOAD DIALOG
            LEA     .MSG,A1                 ; STANDARD MESSAGE
            LEA     .FILTER,A2              ; NO FILTER
            MOVE.L  A7,A3                   ; FILE NAME BUFFER
            CLR.W   (A3)                    ; ENSURE THERE IS NO STRING
            TRAP    #15
            TST.B   D1
            BEQ     .END                    ; IF CANCELLED, DO NOTHING
            MOVE.L  A3,A1                   ; PLACE THE FILENAME INTO A1
            MOVE.B  #51,D0                  ; OPEN EXISTING FILE
            TRAP    #15
            TST.W   D0                      ; CHECK ERRORS
            BNE     .END                    ; IF ERRORS, DO NOTHING MORE
            MOVE.L  A7,A6                   ; PUT A6 INTO START OF BUFFER
            MOVE.L  A7,A1                   ; PUT A1 INTO START OF BUFFER
            MOVE.L  (GRDDST), A0            ; POINTER TO STORE PROCESS. DATA
            MOVE.W  #GRDHEIGH-1,D3
.LOOP       MOVE.L  A6,A1
            MOVE.B  #53,D0                  ; READ DATA TASK NUMBER
            MOVE.L  #GRDWIDTH*2+1,D2        ; NUMBER OF BYTES TO READ
            TRAP    #15                     ; READ THE DATA
            MOVE.W  #GRDWIDTH-1,D2
.COPY       MOVE.B  (A1)+,D0                ; PICK ONE LOADED CHARACTER
            SUB.B   #'0',D0                 ; CONVERT FROM ASCII TO NUMBER
            MOVE.B  D0,(A0)+                ; STORE DATA
            ADDQ.L  #1,A1                   ; SKIP THE COMMA
            DBRA.W  D2,.COPY
            DBRA.W  D3,.LOOP
            MOVE.B  #56,D0                  ; CLOSE FILE
            TRAP    #15
.END        ADD.L   #512,A7                 ; RESTORE STACK
            MOVEM.L (A7)+,D0-D7/A0-A6       ; TO BE OPTIMIZED
            RTS
.MSG        DC.B    'SELECT A CSV FILE TO LOAD',0
.FILTER     DC.B    '*.CSV',0
            DS.W    0

; -----------------------------------------------------------------------------
GRDLLEFT
; LOADS THE LEFT PART OF THE GRID FROM A CSV FORMATTED FILE
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; NOTE     : THE LOCAL BUFFER SIZE MUST BE MAX(512,2*GRDWIDTH+1). PLEASE CHANGE
;            IT ACCORDINGLY IF GRDWIDTH*2+1 IS LARGER THAN 512.
; NOTE     : ALL THE ACTIVE CELLS ARE STORED AS PLAYER 1 INDEPENDLY OF THEIR
;            ACTUAL VALUE.
; -----------------------------------------------------------------------------

; TODO : PLACE YOUR CODE HERE
            MOVEM.L D0-D7/A0-A6,-(A7)       ; TO BE OPTIMIZED
            
            MOVE.B  #50,D0                  ; CLOSE ALL FILES (RECOMMENDED)
            TRAP    #15
            SUB.L   #512,A7                 ; ROW BUFFER IN LOCAL MEMORY
            
            MOVE.B  #58,D0                  ; SHOW FILE DIALOG TASK
            CLR.L   D1                      ; DISPLAY LOAD DIALOG
            LEA     .MSG,A1                 ; STANDARD MESSAGE
            LEA     .FILTER,A2              ; NO FILTER
            MOVE.L  A7,A3                   ; FILE NAME BUFFER
            CLR.W   (A3)                    ; ENSURE THERE IS NO STRING
            TRAP    #15
            
            TST.B   D1
            BEQ     .END                    ; IF CANCELLED, DO NOTHING
            MOVE.L  A3,A1                   ; PLACE THE FILENAME INTO A1
            MOVE.B  #51,D0                  ; OPEN EXISTING FILE
            TRAP    #15
            
            TST.W   D0                      ; CHECK ERRORS
            BNE     .END                    ; IF ERRORS, DO NOTHING MORE
            
            MOVE.L  A7,A6                   ; PUT A6 INTO START OF BUFFER
            MOVE.L  A7,A1                   ; PUT A1 INTO START OF BUFFER
            MOVE.L  (GRDDST), A0             ; POINTER TO STORE PROCESS. DATA
            
            SUBA    #GRDWIDTH/2,A0          ; Per compensar la primera de LOOP
            MOVE.W  #GRDHEIGH-1,D3
            
            
.LOOP      
            ADDA    #GRDWIDTH/2,A0          ; Perque nomes volem modificar LEFT
            MOVE.L  A6,A1
            MOVE.B  #53,D0                  ; READ DATA TASK NUMBER
            MOVE.L  #GRDWIDTH*2+1,D2        ; NUMBER OF BYTES TO READ
            TRAP    #15                     ; READ THE DATA
            
            MOVE.W  #((GRDWIDTH/2)-1),D2    ; perque nomes volem modificar LEFT
            
.COPY       MOVE.B  (A1)+,D0                ; PICK ONE LOADED CHARACTER
            SUB.B   #'0',D0                 ; CONVERT FROM ASCII TO NUMBER
            MOVE.B  D0,(A0)+                ; STORE DATA
            
            ADDQ.L  #1,A1                   ; SKIP THE COMMA
            
            DBRA.W  D2,.COPY
            DBRA.W  D3,.LOOP
            
            
            MOVE.B  #56,D0                  ; CLOSE FILE
            TRAP    #15
            
.END        ADD.L   #512,A7                 ; RESTORE STACK
            MOVEM.L (A7)+,D0-D7/A0-A6       ; TO BE OPTIMIZED

            RTS

.MSG        DC.B    'SELECT A CSV FILE TO LOAD',0
.FILTER     DC.B    '*.CSV',0
            DS.W    0
; -----------------------------------------------------------------------------
GRDLRGT
; LOADS THE RIGHT PART OF THE GRID FROM A CSV FORMATTED FILE
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; NOTE     : THE LOCAL BUFFER SIZE MUST BE MAX(512,2*GRDWIDTH+1). PLEASE CHANGE
;            IT ACCORDINGLY IF GRDWIDTH*2+1 IS LARGER THAN 512.
; NOTE     : ALL THE ACTIVE CELLS ARE STORED AS PLAYER 2 INDEPENDLY OF THEIR
;            ACTUAL VALUE.
; -----------------------------------------------------------------------------

            MOVEM.L D0-D7/A0-A6,-(A7)       ; TO BE OPTIMIZED
            
            MOVE.B  #50,D0                  ; CLOSE ALL FILES (RECOMMENDED)
            TRAP    #15
            SUB.L   #512,A7                 ; ROW BUFFER IN LOCAL MEMORY
            
            MOVE.B  #58,D0                  ; SHOW FILE DIALOG TASK
            CLR.L   D1                      ; DISPLAY LOAD DIALOG
            LEA     .MSG,A1                 ; STANDARD MESSAGE
            LEA     .FILTER,A2              ; NO FILTER
            MOVE.L  A7,A3                   ; FILE NAME BUFFER
            CLR.W   (A3)                    ; ENSURE THERE IS NO STRING
            TRAP    #15
            
            TST.B   D1
            BEQ     .END                    ; IF CANCELLED, DO NOTHING
            MOVE.L  A3,A1                   ; PLACE THE FILENAME INTO A1
            MOVE.B  #51,D0                  ; OPEN EXISTING FILE
            TRAP    #15
            
            TST.W   D0                      ; CHECK ERRORS
            BNE     .END                    ; IF ERRORS, DO NOTHING MORE
            
            MOVE.L  A7,A6                   ; PUT A6 INTO START OF BUFFER
            MOVE.L  A7,A1                   ; PUT A1 INTO START OF BUFFER
            MOVE.L  (GRDDST), A0             ; POINTER TO STORE PROCESS. DATA
            
            MOVE.W  #GRDHEIGH-1,D3
            
            
.LOOP      
            ADDA    #GRDWIDTH/2,A0          ; Perque nomes volem modificar RIGH
            MOVE.L  A6,A1
            MOVE.B  #53,D0                  ; READ DATA TASK NUMBER
            MOVE.L  #GRDWIDTH*2+1,D2        ; NUMBER OF BYTES TO READ
            TRAP    #15                     ; READ THE DATA
            
            MOVE.W  #((GRDWIDTH/2)-1),D2    ; perque nomes volem modificar RIGHT
            
.COPY       MOVE.B  (A1)+,D0                ; PICK ONE LOADED CHARACTER
            SUB.B   #'0',D0                 ; CONVERT FROM ASCII TO NUMBER
            MOVE.B  D0,(A0)+                ; STORE DATA
            
            ADDQ.L  #1,A1                   ; SKIP THE COMMA
            
            DBRA.W  D2,.COPY
            DBRA.W  D3,.LOOP
            
            
            MOVE.B  #56,D0                  ; CLOSE FILE
            TRAP    #15
            
.END        ADD.L   #512,A7                 ; RESTORE STACK
            MOVEM.L (A7)+,D0-D7/A0-A6       ; TO BE OPTIMIZED

            RTS

.MSG        DC.B    'SELECT A CSV FILE TO LOAD',0
.FILTER     DC.B    '*.CSV',0
            DS.W    0

; -----------------------------------------------------------------------------
GRDPLOT
; PLOTS THE GRID
; INPUT    : NONE
; OUTPUT   : NONE
; MODIFIES : NONE
; -----------------------------------------------------------------------------

            MOVEM.L D0-D7/A0,-(A7)
            CLR.W GRDNPLR1                  ; POSAM A 0 ELS COMPTADORS (ELS
            CLR.W GRDNPLR2                  ; ACTUALITZAREM CONFORME DIBUIXEM)
            
            MOVE.L GRDDST,A0
            MOVE.W #GRDWIDTH*GRDHEIGH-1,D0
                
;DEFINIM PEN WIDTH.        
            MOVE.B #1,D1 
            MOVE.W #93,D0
            TRAP #15
;DEFINIM CONTOUR COLOR            
            MOVE.L #CLRDKGRN, D1
            MOVE.W #80,D0
            TRAP #15 

            MOVE.W #(GRDHEIGH-1),D7
            MOVE.W #GRDXOFF,.CORDX
            MOVE.W #GRDYOFF,.CORDY
.LOOP1
            MOVE.W #(GRDWIDTH-1),D6
            BRA .LOOP2
            
.FINLOOP2   ;RESETETJAM CORDX I ACTUALITZAM CORDY
            MOVE.W #GRDXOFF,.CORDX           
            ADD.W #GRDPXHEI/GRDHEIGH, .CORDY          
            DBRA D7,.LOOP1  
            BRA .FINLOOP1          
            
.LOOP2
;DEFINIM EL FILL COLOUR (dDEPEN DEL CONTINGUT DE LA MATRIU)
            MOVE.B (A0)+,D0
            CMP.B #0,D0
;CAS CASELLA BUIDA NO LA PINTAM PERÒ ACTTUALITZAM CORDX
            BEQ .PINTADA 
            CMP #1,D0
            BEQ .FILLP1 

.FILLP2     ; CAS CASELLA DEL P2
            ADDQ.W #1, GRDNPLR2               ; ACTUALITZAM PUNTUACIO
            MOVE.L #GRDCOLP2,D1
            MOVE.W #81,D0
            TRAP #15
            BRA .FINCOLORS 

.FILLP1     ; CAS CASELLA DEL P1
            ADDQ.W #1,GRDNPLR1              ; ACTUALITZAM PUNTUACIO
            MOVE.L #GRDCOLP1,D1
            MOVE.W #81,D0
            TRAP #15
            
.FINCOLORS
            ;SITUAM COORDENADES
            MOVE.W  .CORDX,D1                ;LEFT X
            MOVE.W .CORDY,D2                 ;UPPER Y
            MOVE.W D1,D3
            ADD.W #GRDPXWID/GRDWIDTH,D3      ;RIGHT X 
            MOVE.W D2,D4
            ADD.W #GRDPXHEI/GRDHEIGH,D4      ;LOWER Y
            
            MOVE.W #87,D0
            TRAP #15
.PINTADA    ;ACTUALITZAM VARIABLE CORDX
            ADD.W #GRDPXWID/GRDWIDTH,.CORDX           
            DBRA D6, .LOOP2
            BRA .FINLOOP2
            
.FINLOOP1   ;DIBUIXAM LES LINIES DE LES GRAELLES 
            MOVE.W #GRDHEIGH,D6
            
            MOVE.W #GRDXOFF,D1              ;X1
            MOVE.W #(GRDXOFF+GRDPXWID),D3   ;X2
            
            MOVE.W #GRDYOFF,D2              ;Y1
            MOVE.W #GRDYOFF,D4              ;Y2
.LOOP_FILES
            MOVE.W #84,D0
            TRAP #15
            
            ADD.W #GRDPXHEI/GRDHEIGH,D2     ;ACTUALITZAR Y1
            ADD.W #GRDPXHEI/GRDHEIGH,D4     ;ACTUALITZAR Y2

            DBRA D6,.LOOP_FILES       
            
            MOVE.W #GRDWIDTH,D6
            
            MOVE.W #GRDYOFF,D2              ;Y1
            MOVE.W #GRDYOFF+GRDPXHEI,D4     ;Y2
            
            MOVE.W #GRDXOFF,D1              ;X1
            MOVE.W #GRDXOFF,D3              ;X2
            
.LOOP_COLUMNES
            MOVE.W #84,D0
            TRAP #15
            
            ADD.W #GRDPXWID/GRDWIDTH,D1     ;ACTUALITZAR X1
            ADD.W #GRDPXWID/GRDWIDTH,D3     ;ACTUALITZAR X2

            DBRA D6,.LOOP_COLUMNES
            
;DIBUIXA, ELS MARCADORS, COMENÇAM PER JUGADOR 1            
            MOVE.W #4,D2            
;DEFINIM FILL COLOUR
            MOVE.L #GRDCOLP1,D1
            MOVE.W #81,D0
            TRAP #15

;POSICIONAM EL CURSOR.
            MOVE.W #GRDSCP1X<<8|GRDSCP1Y,D1
            MOVE.W #11,D0
            TRAP #15
            
;DEFINIM LA PUNTUACIO
            CLR.L D1
            MOVE.W GRDNPLR1,D1
            MOVE.W #20,D0
            TRAP #15

;MARCADOR JUGADOR 2            
;DEFINIM FILL COLOUR
            MOVE.L #GRDCOLP2,D1
            MOVE.W #81,D0
            TRAP #15
            
;POSICIONAM EL CURSOR.
            MOVE.W #GRDSCP2X<<8|GRDSCP2Y,D1
            MOVE.W #11,D0
            TRAP #15
            
;DEFINIM LA PUNTUACIO
            CLR.L D1
            MOVE.W GRDNPLR2,D1
            MOVE.W #20,D0
            TRAP #15

;DIBUIXAM EL MARCADOR DE LES GENERACIONS.
;DEFINIM FILL COLOUR
            MOVE.L #CLRMDGRN,D1
            MOVE.W #81,D0
            TRAP #15
            
;POSICIONAM EL CURSOR.
            MOVE.W #GRDSCNGX<<8|GRDSCNGY,D1
            MOVE.W #11,D0
            TRAP #15
            
;DEFINIM LA PUNTUACIO
            CLR.L D1
            MOVE.W GRDNGEN,D1
            MOVE.W #20,D0
            TRAP #15

;COMPROVAR QUIN JUGADOR TE MAJOR PUNTUACIO PER POSASR L'ASTERISC            
            MOVE.W GRDNPLR1,D1
            MOVE.W GRDNPLR2,D2
            
            CMP.W D1,D2
            
            BLO .ASP1
            BHI .ASP2
;SI TENEN IGUAL PUNTUACIO ES POSA UN ASTERISC A CADA UN
            JSR .ASTP1
            JSR .ASTP2
            
            BRA .FIN
            
.ASP1
            JSR .ASTP1
            BRA .FIN            
            
.ASP2
            JSR .ASTP2
            BRA .FIN             
            
.FIN            
            MOVEM.L (A7)+,D0-D7/A0
            RTS
            
.CORDX            DC.W GRDXOFF
.CORDY            DC.W GRDYOFF
            
.ASTP1
            ;Fill colour
            MOVE.L #GRDCOLP1,D1
            MOVE.W #81,D0
            TRAP #15
            
            ; Posicionament cursor
            MOVE.W #GRDSCP1X<<8|(GRDSCP1Y-1),D1
            MOVE.W #11,D0
            TRAP #15
            
            ; Puntuacio
            CLR.L D1
            MOVE.W #42,D1                   ; Numero ASCII del *
            MOVE.W #6,D0
            TRAP #15
            
            RTS
   
.ASTP2
            ;Fill colour
            MOVE.L #GRDCOLP2,D1
            MOVE.W #81,D0
            TRAP #15
            
            ; Posicionament cursor
            MOVE.W #GRDSCP2X<<8|(GRDSCP2Y-1),D1
            MOVE.W #11,D0
            TRAP #15
            
            ; Puntuacio
            CLR.L D1            
            MOVE.W #42,D1                   ; Numero ASCII del *
            MOVE.W #6,D0
            TRAP #15
          
            RTS










*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
