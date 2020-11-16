;***********************************
; Draw Sprite
;
; there is 15 sprite possible by section
; if distance > 0 then draw it
; Items have 1 sprite
; monster has 2 sprite x 4 direction + 1 attack 1 hit and 2 dieing      
processSprites:
    lda #1
    sta spr_loop
-   ldy spr_loop
    cpy #16
    beq pss_done
    lda obj_dist,y  ;copy all data into slot 0
    beq +
    sta spr_dist
    lda obj_pos_hitx,y 
    sta matrixPointX
    lda obj_pos_hity,y 
    sta matrixPointY
    lda obj_col_hit,y  
    asl
    sta spr_col
        ;do the object only ptr and data
    lda objectDataZone,Y
    tay
    lda $300,Y          ;object X
    sta object_x
    lda $301,Y          ;object Y
    sta object_y
    lda $302,Y          ;object sprite ptr
    sta sprite_ptr_mask
    ora #16             ;image data is 16 bytes later
    sta sprite_ptr
    lda $303,Y         
    sta sprite_ptr_mask+1
    sta sprite_ptr+1

    jsr processSprite
+   inc spr_loop
    jmp -
pss_done:
    rts

processSprite:
    ;finc angle from table
    lda object_x
    sec
    sbc matrixPointX
    clc
    adc #8
    sta temp8

    lda object_y
    sec
    sbc matrixPointY
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

    ldx spr_col ;get the current col in X

-   cmp #0      ;if lower than 0 shift col by 2
    bpl +
    inx         ;increase col
    lda spr_deca+1
    clc
    adc tex_step1+1     ;add text step to it per col increased
    sta spr_deca+1
    lda spr_deca
    adc tex_step1
    sta spr_deca
    jmp -

+
-   lda tex_step1+1
    clc
    adc temp8+1         ;go left a bit to start the pixel at right col
    sta temp8+1
    lda tex_step1
    adc temp8
    sta temp8
    dex                 ;decrease col    
    cmp spr_deca
    bcc -

    txa             ;test for whole col
    and #1
    bne -           ;only on x2 col

    sec
    lda spr_deca+1  ;find the perfect pixel to draw
    sbc temp8+1
    sta temp8+1
    lda spr_deca
    sbc temp8
    sta temp8

               ;start drawing it
    txa
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
    lda spr_dist 
    cmp z_depth,x      ;zdepth
    bpl +
    sta z_depth,x       ;store new z value
    
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
    and #$f                 ;keep pixel value
    sta spr_linePos         ;store in line pos
    lda #0                  ;we start at line 0
+
    lsr                     ;divide by 2
    sta current_line
    lda #0
    rol                     ;bring last bit in A
    sta spr_cline           ;save it for later
sdl_loop1:
    ;pixel 1

    jsr GetPixs             ;get current pixels

    ldy spr_linePos
    lda spr_cline
    bne sdl_doLower         ;if we must skip the high part

    lda spr_pixp1
    cmp #8
    bcs +                   ;skip over if outsite of pixmap
    lda (sprite_ptr_mask),y    ;load transparency
    and spr_pix_mask1
    beq +                   ;if visible or not
    lda current_pixs        ;clear bit
    and #$e
    sta current_pixs
    lda (sprite_ptr),y
    and spr_pix_mask1       ;pixel color
    beq +
    inc current_pixs        ;set the bit
+
    lda spr_pixp2
    cmp #8
    bcs +           ;skip over if outsite of pixmap
    lda (sprite_ptr_mask),y    ;load transparency
    and spr_pix_mask2
    beq +                   ;if visible or not
    lda current_pixs        ;clear bit
    and #$D
    sta current_pixs
    lda (sprite_ptr),y
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
    lda (sprite_ptr_mask),y    ;load transparency
    and spr_pix_mask1
    beq +                   ;if visible or not
    lda current_pixs        ;clear bit
    and #$b
    sta current_pixs
    lda (sprite_ptr),y
    and spr_pix_mask1       ;pixel color
    beq +
    lda current_pixs        ;set the bit
    ora #4
    sta current_pixs
+
    lda spr_pixp2
    cmp #8
    bcs +           ;skip over if outsite of pixmap
    lda (sprite_ptr_mask),y    ;load transparency
    and spr_pix_mask2
    beq +                   ;if visible or not
    lda current_pixs        ;clear bit
    and #$7
    sta current_pixs
    lda (sprite_ptr),y
    and spr_pix_mask2       ;pixel color
    beq +
    lda current_pixs        ;set the bit
    ora #8
    sta current_pixs
+

    jsr PutPixs         ;store result

    lsr spr_cline       ;clear it

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


