;***********************************
; Draw Sprite
;
; there is 16 sprite possible by section
; if distance > 0 then draw it
; Items have 1 sprite
; monster has 2 sprite x 4 direction + 1 attack 1 hit and 2 dieing      

processSprite:
    lda obj_dist+1
    beq prs_done
    ;get the steps
    sta spr_dist
    lda obj_col_hit+1
    asl
    sta spr_col

    ;finc angle from table
    lda object_x
    sec
    sbc obj_pos_hitx+1
    clc
    adc #8
    sta temp8

    lda object_y
    sec
    sbc obj_pos_hity+1
    clc
    adc #8
    asl
    asl
    asl
    asl
    ora temp8
    tay
    lda PixelsAngle,y
    sta temp8
    jsr loadMatrix

    lda playerDir
    sec
    sbc #38
    clc
    adc spr_col
    sta temp16

    lda temp8	;find the starting ray direction
	sec
	sbc temp16
    jsr loadMatrix2


    ;step up until we cross X or Y of the object
    lda #0
    sta spr_dist+1
    sta spr_deca
    sta spr_deca+1
    sta matrixPointX+1      ;clear low part of cfloat
    sta matrixPointY+1
    lda obj_pos_hitx+1
    sta matrixPointX        ;set position x and y
    lda obj_pos_hity+1
    sta matrixPointY

prs_loop1:
    lda matrixPointX
    cmp object_x
    bne +

    lda matrixPointY
    cmp object_y
    beq prs_onit
+
    ;increase distance
    jsr sprite_do_step
    jsr sprite_do_step2

    jmp prs_loop1
    ;we cross x, edit col by objX-rayX
prs_onit:
    lda spr_dist
    asl spr_dist+1
    rol
    asl spr_dist+1
    rol
    sta spr_dist
    
    jsr spriteDarw
prs_done:
    rts




sprite_do_step:
	lda c_dir_x
	asl
	bcs sds_negx
	adc matrixPointX+1		;add to float
	sta matrixPointX+1
	bcc +
	inc matrixPointX
+	jmp sds_doY

sds_negx:
	clc
	adc matrixPointX+1		;sub to float
	sta matrixPointX+1
	bcs +
	dec matrixPointX
+
sds_doY:

	lda c_dir_y
	asl
	bcs sds_negy
	adc matrixPointY+1		;add to float
	sta matrixPointY+1
	bcc +
	inc matrixPointY
+	rts
sds_negy:
	clc
	adc matrixPointY+1		;add to float
	sta matrixPointY+1
	bcs +
	dec matrixPointY
+   rts


sprite_do_step2:
	lda c_dir_y2
	asl
	bcs sds2_negx
	adc spr_deca+1		;add to float
	sta spr_deca+1
	bcc +
	inc spr_deca
+	jmp sds2_doY

sds2_negx:
	clc
	adc spr_deca+1		;sub to float
	sta spr_deca+1
	bcs +
	dec spr_deca
+
sds2_doY:

	lda c_dir_x2
	asl
	bcs sds2_negy
	adc spr_dist+1		;add to float
	sta spr_dist+1
	bcc +
	inc spr_dist
+	rts
sds2_negy:
	clc
	adc spr_dist+1		;add to float
	sta spr_dist+1
	bcs +
	dec spr_dist
+   rts




;**************************************
; Sprite Draw
;


spriteDarw:
    ;prepare the steps
    ldy spr_dist
    lda #0
    sta temp8
    sta temp16
    sta tex_step1
	lda Text_step,Y			;load step
	asl 			;swipe left by 2
	rol tex_step1
	asl 		
	rol tex_step1
	sta tex_step1+1

    asl spr_deca+1
    rol spr_deca
    ;go 4 left
    lda #4
    sec
    sbc spr_deca
    sta spr_deca

-   cmp #0      ;if lower than 0 shift col by 2
    bpl +
    inc spr_col
    inc spr_col
    clc
    adc #2
    sta spr_deca
    jmp -

+
-   lda tex_step1+1
    clc
    adc temp8+1
    sta temp8+1
    lda tex_step1
    adc temp8
    sta temp8
    dec spr_col    
    cmp spr_deca
    bcc -

    lda spr_col
    and #1
    bne -           ;only on x2 col

    sec
    lda spr_deca+1
    sbc temp8+1
    sta temp8+1
    lda spr_deca
    sbc temp8
    sta temp8

               ;start drawing it
    lda spr_col
    lsr
    tax             ; X = colon

spr_loop1:
    lda tex_step1+1
    clc
    adc temp8+1         ;increase pixel + step
    sta temp8+1
 
    lda tex_step1
    adc temp8
    sta temp8
    sta spr_pixp1       ;save for pixel 1 pos

    lda tex_step1+1
    clc
    adc temp8+1         ;increase pixel + step
    sta temp8+1
 
    lda tex_step1
    adc temp8
    sta temp8
    sta spr_pixp2       ;save for pixel 1 pos
    tay             ;get the mask2

    cpx #38
    bcs +           ;skip, outside of screen
    lda z_depth,x
    cmp spr_dist       ;zdepth
    bmi +

    
    lda textureMask,y
    sta spr_pix_mask2

    ldy spr_pixp1       ;get the mask 1
    lda textureMask,y
    sta spr_pix_mask1

    jsr spriteDrawLine

+
    inx

    lda temp8
    cmp #8
    bcc spr_loop1

    rts

spriteDrawLine:
    lda #0                  ;reset sprite pos to 0
    sta spr_linePos
    sta spr_linePos+1

    ;set the begin height
    ldy spr_dist
    lda Text_Start,y        ;get starting pos
    bpl +
    and #$f
    sta spr_linePos
    lda #0
+
    lsr                     ;divide by 2
    sta current_line
    lda #0
    bcc +
    lda #1
+
    sta spr_cline
sdl_loop1:
    ;pixel 1

    jsr GetPixs             ;get current pixel

    ldy spr_linePos
    lda spr_cline
    bne sdl_doLower         ;if we must skip the high part

    lda spr_pixp1
    cmp #8
    bcs +           ;skip over if outsite of pixmap
    lda spriteTestMask,y    ;load transparency
    and spr_pix_mask1
    beq +                   ;if visible or not
    lda current_pixs        ;clear bit
    and #$e
    sta current_pixs
    lda spriteTest,y
    and spr_pix_mask1       ;pixel color
    beq +
    inc current_pixs        ;set the bit
+
    lda spr_pixp2
    cmp #8
    bcs +           ;skip over if outsite of pixmap
    lda spriteTestMask,y    ;load transparency
    and spr_pix_mask2
    beq +                   ;if visible or not
    lda current_pixs        ;clear bit
    and #$D
    sta current_pixs
    lda spriteTest,y
    and spr_pix_mask2       ;pixel color
    beq +
    lda current_pixs        ;set the bit
    ora #2
    sta current_pixs
+
sdl_doLower:

    lda tex_step1+1
    clc
    adc spr_linePos+1         ;increase pixel + step
    sta spr_linePos+1
    lda tex_step1               ;increase high part
    adc spr_linePos
    sta spr_linePos

    cmp #16
    bcc sdl_jmp2
    jsr PutPixs         ;store result
    rts

sdl_jmp2:
    ldy spr_linePos
    lda spr_pixp1
    cmp #8
    bcs +           ;skip over if outsite of pixmap
    lda spriteTestMask,y    ;load transparency
    and spr_pix_mask1
    beq +                   ;if visible or not
    lda current_pixs        ;clear bit
    and #$b
    sta current_pixs
    lda spriteTest,y
    and spr_pix_mask1       ;pixel color
    beq +
    lda current_pixs        ;set the bit
    ora #4
    sta current_pixs
+
    lda spr_pixp2
    cmp #8
    bcs +           ;skip over if outsite of pixmap
    lda spriteTestMask,y    ;load transparency
    and spr_pix_mask2
    beq +                   ;if visible or not
    lda current_pixs        ;clear bit
    and #$7
    sta current_pixs
    lda spriteTest,y
    and spr_pix_mask2       ;pixel color
    beq +
    lda current_pixs        ;set the bit
    ora #8
    sta current_pixs
+

    jsr PutPixs         ;store result
    lda #0
    sta spr_cline

    inc current_line    ;goes next line
    lda current_line
    cmp #19             ;over line 38 its over
    bcs +
    lda tex_step1+1
    clc
    adc spr_linePos+1         ;increase pixel + step
    sta spr_linePos+1
    lda tex_step1               ;increase high part
    adc spr_linePos
    sta spr_linePos
    cmp #16
    bcs +

    jmp sdl_loop1
+
    rts


spriteTestMask:
!by %00011000
!by %00111100
!by %01111110
!by %01111110
!by %00111100
!by %11111111
!by %11111111
!by %11111111
!by %11111111
!by %00111100
!by %00111100
!by %01111110
!by %11111111
!by %11111111
!by %11100111
!by %11100111

spriteTest:
!by %00000000
!by %00011000
!by %00111100
!by %00111100
!by %00011000
!by %00000000
!by %11111111
!by %11111111
!by %00011000
!by %00011000
!by %00011000
!by %00111100
!by %01100110
!by %01100110
!by %11000011
!by %11000011