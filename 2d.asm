;******************************************
; All 2d graphic goes here
; OSD and Status board
;



;******************************************
;   Print the value in A at the position Y
; A = Value to print
; Y = col to print it
;
PrintValue:
    ldx #10     ;empty display
    cmp #100    ;are we over 100
    bcc +
    ldx #0      ;reset to value of 0
-   inx         ;increase value
    sec
    sbc #100    ;sub 100 from A
    cmp #100
    bcs -       ;do again if we are still over 100
+   jsr DrawDigit
    cpx #10
    beq +
    ldx #0
+
    cmp #10    ;are we over 10
    bcc +
    ldx #0      ;reset to value of 0
-   inx         ;increase value
    sec
    sbc #10    ;sub 10 from A
    cmp #10
    bcs -       ;do again if we are still over 10
+   jsr DrawDigit
    tax         ;process last digit
    jsr DrawDigit
    rts


;*******************************************
; Display a single digit at the Y position
; Increase Y by 2 after
; X = digit to display

DrawDigit:
    pha     ;save A
    stx dd_savex
    txa
    asl
    asl
    asl
    tax
    lda NumberData,X
    sta $748+40,y
    lda NumberData+1,X
    sta $749+40,y
    lda NumberData+2,X
    sta $748+80,y
    lda NumberData+3,X
    sta $749+80,y
    lda NumberData+4,X
    sta $748+120,y
    lda NumberData+5,X
    sta $749+120,y
    iny
    iny
    ldx #$ff
dd_savex = *-1
    pla     ;restore A
    rts
