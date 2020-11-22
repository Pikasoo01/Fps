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
    inc rotation_speed
+   
pt_noRight:


    lda Keyborad_left
    beq pt_noLeft
    lda rotation_speed
    cmp #$fa
    bmi +
    dec rotation_speed      ;decrease speed
    dec rotation_speed
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
+	jmp dos_doY

dos_negx:
	clc
	adc playerPosX+1		;sub to float
	sta playerPosX+1
	bcs +
	dec playerPosX
+
dos_doY:

	lda c_dir_y
	asl
	bcs dos_negy
	adc playerPosY+1		;add to float
	sta playerPosY+1
	bcc +
	inc playerPosY
+	rts
dos_negy:
	clc
	adc playerPosY+1		;add to float
	sta playerPosY+1
	bcs +
	dec playerPosY
+   rts