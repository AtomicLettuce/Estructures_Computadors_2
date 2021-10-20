; =============================================================================
; TITLE    : VARIABLES
; AUTHOR   :
; COMMENTS :
; HISTORY  :
; =============================================================================

;Espai reservat per les direccions de mapatge de memòria
MAPADDR
MAPSEGAD    DS.L    1                       ;direccio displays de 7segments
MAPLEDAD    DS.L    1                       ;direccio dels LEDs
MAPSWIAD    DS.L    1                       ;direccio dels switches
MAPBUTAD    DS.L    1                       ;direccio dels botons


;Espai reservat on s'escriu el text que ha d'anar als displays
TEXT        DS.B    8
            DS.W    0


            

*~Font name~Courier New~
*~Font size~10~
*~Tab type~0~
*~Tab size~4~
