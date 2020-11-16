
;*******************************************
; Draw3dScreen
; this function will compute all V-line using the projection method
; 
;


Draw3dScreen:
	lda #0
	ldx #0
-	sta obj_dist,X	;reset object
	inx
	cpx #16
	bne -

	lda playerDir	;find the starting ray direction
	sec
	sbc #38			;player dir - 40
	sta scan_dir
	ldx #1
d3d_loop1:
	lda #0
	sta matrixDist		;reset distance
	sta matrixDist+1		;reset distance
	lda focalFix,x
	sta focal_inc

	lda playerPosX		;copy player pos x
	sta matrixPointX
	lda playerPosX+1		
	sta matrixPointX+1
	lda playerPosY		;copy player pos y
	sta matrixPointY
	lda playerPosY+1		
	sta matrixPointY+1

	lda scan_dir		;prepare matrix
	jsr loadMatrix

	jsr float_add_matrix		;trace to wall
	sta tex_dist1
	lda scan_text_xy		;compute the texture pos
	cmp #2
	bcs d3d_t1y
	lda matrixPointY		;from X
	jmp +
d3d_t1y:
	lda matrixPointX		;from Y
+	and #$7
	tay
	lda textureMask,y
	sta tex_hpos1

	inc scan_dir

	jsr DrawLines


	inc scan_dir
	inx
	cpx #39
	bne d3d_loop1
	rts
	





DrawLines:
	;X = current line
	ldy tex_dist1			;convert distance to wall height
	lda #0					;set 0 for low and for top count
	sta tex_pix1+1
	sta tex_pix1
	sta dl_val				;set low ptr
	sta tex_step1
	lda Text_step,Y			;load step
	asl 			;swipe left by 2
	rol tex_step1
	asl 		
	rol tex_step1
	sta tex_step1+1

	lda #$7c
	sta dl_val+1

	lda Text_Start,Y
	bpl +					;load start offset
	and #$f					;if bit 7 is set we are in texture
	sta tex_pix1			;set current pixel
	lda #0
+
	sta tex_top1
	lda #19
	sta current_line
dl_loop1:
	lda #0
	ldy tex_top1
	cpy #2
	bcc +
	dec tex_top1
	dec tex_top1
	jmp dl_nopix
+
	sta current_pixs
	;pixel1
	jsr GetPixel1			;get pixel color
	and tex_hpos1
	beq +
	lda #$3
	sta current_pixs
+

	;pixel 3
	jsr GetPixel1			;get pixel color
	and tex_hpos1
	beq +
	lda #12
	ora current_pixs
	sta current_pixs
+

	;store pixel in buffer
	;jsr PutPixs
	lda current_pixs
dl_nopix:
	sta $ffff,X
dl_val = * - 2
	lda dl_val
	clc
	adc #40
	sta dl_val
	bcc +
	inc dl_val+1
+

	dec current_line
	lda current_line
	bne dl_loop1
	rts
	



GetPixel1:
	lda tex_top1		;if in top
	bne +
	lda tex_pix1		;if out of textur
	cmp #16
	bcs +
	ora tex_id1			;scale by texture id
	tay

	lda tex_step1+1		;point to next pixel
	clc
	adc tex_pix1+1		;incrementing by pix step
	sta tex_pix1+1
	lda tex_step1
	adc tex_pix1
	sta tex_pix1

	lda textureTest,y
	rts
+	dec tex_top1
	lda #0
	rts


PutPixs:
	ldy current_line
	lda screen_offset_l,y
	sta pp_val
	lda screen_offset_h,y
	sta pp_val+1
	lda current_pixs
	sta $ffff,X
pp_val = * - 2
	rts

GetPixs:
	ldy current_line
	lda screen_offset_l,y
	sta gp_val
	lda screen_offset_h,y
	sta gp_val+1

	lda $ffff,X
gp_val = * - 2
	sta current_pixs
	rts

;**********************************************
; FlipScreen
; 	Draw to the video memory the calculated frame
;

FlipScreen:
	ldx #0
-	ldy $7c00,x
	lda $f0,y
	sta $400,x
	ldy $7d00,x
	lda $f0,y
	sta $500,x
	ldy $7e00,x
	lda $f0,y
	sta $600,x
	inx
	bne -
	rts
	
flipData: !by $20,$7e,$7c,$E2,$7B,$61,$FF,$EC,$6C,$7F,$e1,$FB,$62,$Fc,$FE,$A0