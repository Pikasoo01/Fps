;****************************************
; Tick player
;

PlayerTick:
    lda Keyboard_right
    beq pt_noRight
    lda rotation_speed
    cmp #6                 ;not over max
    bpl +
    inc rotation_speed      ;increase speed
+   
pt_noRight:


    lda Keyborad_left
    beq pt_noLeft
    lda rotation_speed
    cmp #$fa
    bmi +
    dec rotation_speed      ;decrease speed
+   
pt_noLeft:


    lda Keyboard_right      ;if no action
    bne pt_jmp1
    lda Keyborad_left
    bne pt_jmp1
    clc
    lda rotation_speed      ;we slow down
    bpl +
    sec                     ;set high bit
+
    ror                     ;divide speed by 2
    cmp #$ff
    bne +
    lda #0                  ;if at -1 we set 0
+
    sta rotation_speed
pt_jmp1:
    lda rotation_speed
    clc
    adc playerDir           ;make player rotate
    sta playerDir


            ;walk forward / backward
    lda Keyboard_up
    beq pt_noForward
    lda playerDir
    jsr doOneStep
pt_noForward:

    lda Keyboard_down
    beq pt_noBackward
    lda playerDir
    eor #128    ;180 degree flip
    jsr doOneStep
pt_noBackward:


    rts


doOneStep:
    jsr loadMatrix
    lda c_dir_x
	asl
	bcs dos_negx
	adc playerPosX+1		;add to float
	sta playerPosX+1
	bcc +
	inc playerPosX
    lda playerPosX          ;test if we hit pixel 4
    and #$7
    cmp #7
    bne +
    lda playerPosX          ;we are on pix 4
    clc
    adc #8                  ;look for wall in that direction
    sta matrixPointX
    lda playerPosY
    sta matrixPointY
    jsr getWall
    and #15                 ;do we have one?
    beq +
    lda playerPosX          ;yes, stay in previous pixel
    and #$f8
    ora #6
    sta playerPosX
+	jmp dos_doY

dos_negx:
	clc
	adc playerPosX+1		;sub to float
	sta playerPosX+1
	bcs +
	dec playerPosX
    lda playerPosX          ;test if we hit pixel 4
    and #$7
    cmp #1
    bne +
    lda playerPosX          ;we are on pix 4
    sec
    sbc #8                  ;look for wall in that direction
    sta matrixPointX
    lda playerPosY
    sta matrixPointY
    jsr getWall
    and #15                 ;do we have one?
    beq +
    lda playerPosX          ;yes, stay in previous pixel
    and #$f8
    ora #2
    sta playerPosX
+
dos_doY:

	lda c_dir_y
	asl
	bcs dos_negy
	adc playerPosY+1		;add to float
	sta playerPosY+1
	bcc +
	inc playerPosY
    lda playerPosY          ;test if we hit pixel 4
    and #$7
    cmp #7
    bne +
    lda playerPosY          ;we are on pix 4
    clc
    adc #8                  ;look for wall in that direction
    sta matrixPointY
    lda playerPosX
    sta matrixPointX
    jsr getWall
    and #15                 ;do we have one?
    bne dos_j41
    lda matrixPointX
    and #7
    cmp #2
    bcs dos_j21
    dec matrixPointX
    dec matrixPointX
    jmp dos_j31
dos_j21:
    cmp #6
    bcc +
        ;add 8
    inc matrixPointX
    inc matrixPointX
dos_j31:
    jsr getWall
    and #15                 ;do we have one?
    beq +
dos_j41:
    lda playerPosY          ;yes, stay in previous pixel
    and #$f8
    ora #6
    sta playerPosY
+	rts
dos_negy:
	clc
	adc playerPosY+1		;add to float
	sta playerPosY+1
	bcs +
	dec playerPosY
    lda playerPosY          ;test if we hit pixel 4
    and #$7
    cmp #1
    bne +
    lda playerPosY          ;we are on pix 4
    sec
    sbc #8                  ;look for wall in that direction
    sta matrixPointY
    lda playerPosX
    sta matrixPointX
    jsr getWall
    and #15                 ;do we have one?
    bne dos_j4
    lda matrixPointX
    and #7
    cmp #2
    bcs dos_j2
    dec matrixPointX
    dec matrixPointX
    jmp dos_j3
dos_j2:
    cmp #6
    bcc +
        ;add 8
    inc matrixPointX
    inc matrixPointX
dos_j3:
    jsr getWall
    and #15                 ;do we have one?
    beq +
dos_j4:
    lda playerPosY          ;yes, stay in previous pixel
    and #$f8
    ora #2
    sta playerPosY
+   rts
