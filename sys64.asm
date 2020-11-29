!src "keyboard64.asm"

;*********************************************
; Timming function
; based on 10 fps using the TOD
; return the amount of frame to play beafor redraw

GetFrameSkip:
    lda $DC08           ;get 1/10 of secondes
    sta newFrame
    ldx #0              ;set count to 0
    ldy LatessFrame     ;load last frame
-   cpy newFrame        ;are we = if yes done
    beq +
    iny                 ;increase y and x
    inx
    cpy #10             ;did we loop around?
    bne -
    ldy #0              ;yes reset to 0
    jmp -
+   sty LatessFrame
    rts




InitFrameCounter:
    lda #0
    sta	$dc0e		;Set TOD Clock Frequency to 60Hz
	sta	$dc0f		;Enable Set-TOD-Clock
	sta	$dc0b		;Set TOD-Clock to 0 (hours)
	sta	$dc0a		;- (minutes)
	sta	$dc09		;- (seconds)
	sta	$dc08		;- (deciseconds)
    rts