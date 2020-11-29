;********************************************
;
; whaitForKey
;
; just whait for a key pressed
;

whaitForKey:
	lda #0
	sta $DC00
	lda $DC01
	cmp #$ff
	beq whaitForKey
wfk_loop
	lda #0
	sta $DC00
	lda $DC01
	cmp #$ff
	bne wfk_loop
	rts


;*********************************************
; Scan Keys
;
; Update the keys status
;

ScanKeys:
    ldy #0
	lda #0
-
	sta Keyboard_f1,y		;clear buffer
	iny
	cpy #13
	bne -
	
	ldy #1
	lda #$fe	;row 1 for f key
	sta $DC00
	lda $DC01
	sta K_tempVar
	and #2		;test return
	bne +
	sty Keyboard_action
+	
	lda K_tempVar
	and #8		;test f7
	bne +
	sty Keyboard_f7
+
	lda K_tempVar
	and #16		;test f1
	bne +
	sty Keyboard_f1
+
	lda K_tempVar
	and #32		;test f3
	bne +
	sty Keyboard_f3
+
	lda K_tempVar
	and #64		;test f5
	bne +
	sty Keyboard_f5
+
	lda #$fD	;row 2 for asw34 key
	sta $DC00
	lda $DC01
	sta K_tempVar
	and #1		;test 3
	bne +
	sty Keyboard_3
+
	lda K_tempVar
	and #2		;test w
	bne +
	sty Keyboard_up
+
	lda K_tempVar
	and #4		;test a
	bne +
	sty Keyborad_left
+
	lda K_tempVar
	and #8		;test 4
	bne +
	sty Keyboard_4
+
	lda K_tempVar
	and #32		;test s
	bne +
	sty Keyboard_down
+
	lda #$fb	;row 3 for d key
	sta $DC00
	lda $DC01
	and #4		;test d
	bne +
	sty Keyboard_right
+

	lda #$7f	;row 8 for 12 key
	sta $DC00
	lda $DC01
	sta K_tempVar
	and #1		;test 1
	bne +
	sty Keyboard_1
+
	lda K_tempVar
	and #8		;test 2
	bne +
	sty Keyboard_2
+


	;do joy
	lda $DC00
	ror
	bcs +
	sty Keyboard_up
+
	ror
	bcs +
	sty Keyboard_down
+
	ror
	bcs +
	sty Keyborad_left
+
	ror
	bcs +
	sty Keyboard_right
+
	ror
	bcs +
	sty Keyboard_action
+	
	rts