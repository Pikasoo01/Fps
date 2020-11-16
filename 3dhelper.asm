
;************************************
; add value to float from matrix direction
;
; matrixPtr = ptr to matrix line x,y
;
; cost : 89 per loop
;

float_add_matrix:
	lda #0					;clear the cross flag
	sta scan_text_xy
-
	lda c_dir_x
	asl
	bcs fam_negx
	adc matrixPointX+1		;add to float
	sta matrixPointX+1
	bcc +
	inc matrixPointX
	lda matrixPointX
	and #$7
	bne +
	inc scan_text_xy
+	jmp fam_doY

fam_negx:
	clc
	adc matrixPointX+1		;sub to float
	sta matrixPointX+1
	bcs +
	dec matrixPointX
	lda matrixPointX
	and #$7
	cmp #$7
	bne +
	inc scan_text_xy
+
fam_doY:

	lda c_dir_y
	asl
	bcs fam_negy
	adc matrixPointY+1		;add to float
	sta matrixPointY+1
	bcc +
	inc matrixPointY
	lda matrixPointY
	and #$7
	bne +
	inc scan_text_xy
	inc scan_text_xy
+	jmp fam_test
fam_negy:
	clc
	adc matrixPointY+1		;add to float
	sta matrixPointY+1
	bcs +
	dec matrixPointY
	lda matrixPointY
	and #$7
	cmp #$7
	bne +
	inc scan_text_xy
	inc scan_text_xy
+
fam_test:
	lda focal_inc
	clc
	adc matrixDist+1			;inc distance
	sta matrixDist+1
	bcc +
	inc matrixDist
+
	lda scan_text_xy
	beq -					;if no wall crossed dont test
	jsr getWall
	pha						;save A
	lsr
	lsr						;test for object 
	lsr
	lsr
	cmp #0
	beq +
		;we have an object
	tay				;move to Y
	lda obj_dist,Y
	beq fam_goin
	cmp matrixDist
	bcc +					;do we need to stor first encounter
fam_goin:
	stx obj_col_hit,Y
	lda matrixDist
	sta obj_dist,y			;store dist
	lda matrixPointY
	sta obj_pos_hity,Y		;store Y pos
	
	lda matrixPointX		;if we crossed Y we store X instead
	sta obj_pos_hitx,Y
+
	pla
	and #$f
	cmp #0
	bne +
	jmp float_add_matrix	;if is 0 then keep going
+
	sta tex_id1				;save the texture id
	dec tex_id1
	asl matrixDist+1
	lda matrixDist
	rol
	asl
	sta z_depth,X
	;sta matrixDist
	rts
	
;********************************************
;
; get wall data base on the X,Y of the matrix
;
; return A = wall data
;
; cost 29

getWall:
	lda matrixPointY
	asl
	and #$F0			;keep high value
	sta gw_ptr
	lda matrixPointX	;use high part in low 4 bits
	lsr
	lsr
	lsr
	ora gw_ptr
	sta gw_ptr
	lda $02FF			;load value
gw_ptr = *-2
	rts
	
	
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
;
; loadMatrix
;
; load matrix for the direction loaded in A
;
; cost : 51
;

loadMatrix:
	asl				;put high bit in carry
	tay				;remaining in Y
	bcc +			;low or high part
	lda Matrix+256,Y	;load x,y
	sta c_dir_x
	lda Matrix+257,Y
	sta c_dir_y
	rts

+	lda Matrix,Y	;load x,y
	sta c_dir_x
	lda Matrix+1,Y
	sta c_dir_y
	rts
	

loadMatrix2:
	asl				;put high bit in carry
	tay				;remaining in Y
	bcc +			;low or high part
	lda Matrix+256,Y	;load x,y
	sta c_dir_x2
	lda Matrix+257,Y
	sta c_dir_y2
	rts

+	lda Matrix,Y	;load x,y
	sta c_dir_x2
	lda Matrix+1,Y
	sta c_dir_y2
	rts
	
	
	


