
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
	lda $03FF			;load value
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
	
	
	


;3d step mapping
!align 255, 0
Matrix:
!by $7F, $00    ;x: 127   y: 0
!by $7F, $03    ;x: 127   y: 3
!by $7F, $06    ;x: 127   y: 6
!by $7F, $09    ;x: 127   y: 9
!by $7E, $0C    ;x: 126   y: 12
!by $7E, $10    ;x: 126   y: 16
!by $7E, $13    ;x: 126   y: 19
!by $7D, $16    ;x: 125   y: 22
!by $7D, $19    ;x: 125   y: 25
!by $7C, $1C    ;x: 124   y: 28
!by $7B, $1F    ;x: 123   y: 31
!by $7A, $22    ;x: 122   y: 34
!by $7A, $25    ;x: 122   y: 37
!by $79, $28    ;x: 121   y: 40
!by $78, $2B    ;x: 120   y: 43
!by $76, $2E    ;x: 118   y: 46
!by $75, $31    ;x: 117   y: 49
!by $74, $33    ;x: 116   y: 51
!by $73, $36    ;x: 115   y: 54
!by $71, $39    ;x: 113   y: 57
!by $70, $3C    ;x: 112   y: 60
!by $6F, $3F    ;x: 111   y: 63
!by $6D, $41    ;x: 109   y: 65
!by $6B, $44    ;x: 107   y: 68
!by $6A, $47    ;x: 106   y: 71
!by $68, $49    ;x: 104   y: 73
!by $66, $4C    ;x: 102   y: 76
!by $64, $4E    ;x: 100   y: 78
!by $62, $51    ;x: 98   y: 81
!by $60, $53    ;x: 96   y: 83
!by $5E, $55    ;x: 94   y: 85
!by $5C, $58    ;x: 92   y: 88
!by $5A, $5A    ;x: 90   y: 90
!by $58, $5C    ;x: 88   y: 92
!by $55, $5E    ;x: 85   y: 94
!by $53, $60    ;x: 83   y: 96
!by $51, $62    ;x: 81   y: 98
!by $4E, $64    ;x: 78   y: 100
!by $4C, $66    ;x: 76   y: 102
!by $49, $68    ;x: 73   y: 104
!by $47, $6A    ;x: 71   y: 106
!by $44, $6B    ;x: 68   y: 107
!by $41, $6D    ;x: 65   y: 109
!by $3F, $6F    ;x: 63   y: 111
!by $3C, $70    ;x: 60   y: 112
!by $39, $71    ;x: 57   y: 113
!by $36, $73    ;x: 54   y: 115
!by $33, $74    ;x: 51   y: 116
!by $31, $75    ;x: 49   y: 117
!by $2E, $76    ;x: 46   y: 118
!by $2B, $78    ;x: 43   y: 120
!by $28, $79    ;x: 40   y: 121
!by $25, $7A    ;x: 37   y: 122
!by $22, $7A    ;x: 34   y: 122
!by $1F, $7B    ;x: 31   y: 123
!by $1C, $7C    ;x: 28   y: 124
!by $19, $7D    ;x: 25   y: 125
!by $16, $7D    ;x: 22   y: 125
!by $13, $7E    ;x: 19   y: 126
!by $10, $7E    ;x: 16   y: 126
!by $0C, $7E    ;x: 12   y: 126
!by $09, $7F    ;x: 9   y: 127
!by $06, $7F    ;x: 6   y: 127
!by $03, $7F    ;x: 3   y: 127
!by $00, $7F    ;x: 0   y: 127
!by $FD, $7F    ;x: 65533   y: 127
!by $FA, $7F    ;x: 65530   y: 127
!by $F7, $7F    ;x: 65527   y: 127
!by $F4, $7E    ;x: 65524   y: 126
!by $F0, $7E    ;x: 65520   y: 126
!by $ED, $7E    ;x: 65517   y: 126
!by $EA, $7D    ;x: 65514   y: 125
!by $E7, $7D    ;x: 65511   y: 125
!by $E4, $7C    ;x: 65508   y: 124
!by $E1, $7B    ;x: 65505   y: 123
!by $DE, $7A    ;x: 65502   y: 122
!by $DB, $7A    ;x: 65499   y: 122
!by $D8, $79    ;x: 65496   y: 121
!by $D5, $78    ;x: 65493   y: 120
!by $D2, $76    ;x: 65490   y: 118
!by $CF, $75    ;x: 65487   y: 117
!by $CD, $74    ;x: 65485   y: 116
!by $CA, $73    ;x: 65482   y: 115
!by $C7, $71    ;x: 65479   y: 113
!by $C4, $70    ;x: 65476   y: 112
!by $C1, $6F    ;x: 65473   y: 111
!by $BF, $6D    ;x: 65471   y: 109
!by $BC, $6B    ;x: 65468   y: 107
!by $B9, $6A    ;x: 65465   y: 106
!by $B7, $68    ;x: 65463   y: 104
!by $B4, $66    ;x: 65460   y: 102
!by $B2, $64    ;x: 65458   y: 100
!by $AF, $62    ;x: 65455   y: 98
!by $AD, $60    ;x: 65453   y: 96
!by $AB, $5E    ;x: 65451   y: 94
!by $A8, $5C    ;x: 65448   y: 92
!by $A6, $5A    ;x: 65446   y: 90
!by $A4, $58    ;x: 65444   y: 88
!by $A2, $55    ;x: 65442   y: 85
!by $A0, $53    ;x: 65440   y: 83
!by $9E, $51    ;x: 65438   y: 81
!by $9C, $4E    ;x: 65436   y: 78
!by $9A, $4C    ;x: 65434   y: 76
!by $98, $49    ;x: 65432   y: 73
!by $96, $47    ;x: 65430   y: 71
!by $95, $44    ;x: 65429   y: 68
!by $93, $41    ;x: 65427   y: 65
!by $91, $3F    ;x: 65425   y: 63
!by $90, $3C    ;x: 65424   y: 60
!by $8F, $39    ;x: 65423   y: 57
!by $8D, $36    ;x: 65421   y: 54
!by $8C, $33    ;x: 65420   y: 51
!by $8B, $31    ;x: 65419   y: 49
!by $8A, $2E    ;x: 65418   y: 46
!by $88, $2B    ;x: 65416   y: 43
!by $87, $28    ;x: 65415   y: 40
!by $86, $25    ;x: 65414   y: 37
!by $86, $22    ;x: 65414   y: 34
!by $85, $1F    ;x: 65413   y: 31
!by $84, $1C    ;x: 65412   y: 28
!by $83, $19    ;x: 65411   y: 25
!by $83, $16    ;x: 65411   y: 22
!by $82, $13    ;x: 65410   y: 19
!by $82, $10    ;x: 65410   y: 16
!by $82, $0C    ;x: 65410   y: 12
!by $81, $09    ;x: 65409   y: 9
!by $81, $06    ;x: 65409   y: 6
!by $81, $03    ;x: 65409   y: 3
!by $81, $00    ;x: 65409   y: 0
!by $81, $FD    ;x: 65409   y: 65533
!by $81, $FA    ;x: 65409   y: 65530
!by $81, $F7    ;x: 65409   y: 65527
!by $82, $F4    ;x: 65410   y: 65524
!by $82, $F0    ;x: 65410   y: 65520
!by $82, $ED    ;x: 65410   y: 65517
!by $83, $EA    ;x: 65411   y: 65514
!by $83, $E7    ;x: 65411   y: 65511
!by $84, $E4    ;x: 65412   y: 65508
!by $85, $E1    ;x: 65413   y: 65505
!by $86, $DE    ;x: 65414   y: 65502
!by $86, $DB    ;x: 65414   y: 65499
!by $87, $D8    ;x: 65415   y: 65496
!by $88, $D5    ;x: 65416   y: 65493
!by $8A, $D2    ;x: 65418   y: 65490
!by $8B, $CF    ;x: 65419   y: 65487
!by $8C, $CD    ;x: 65420   y: 65485
!by $8D, $CA    ;x: 65421   y: 65482
!by $8F, $C7    ;x: 65423   y: 65479
!by $90, $C4    ;x: 65424   y: 65476
!by $91, $C1    ;x: 65425   y: 65473
!by $93, $BF    ;x: 65427   y: 65471
!by $95, $BC    ;x: 65429   y: 65468
!by $96, $B9    ;x: 65430   y: 65465
!by $98, $B7    ;x: 65432   y: 65463
!by $9A, $B4    ;x: 65434   y: 65460
!by $9C, $B2    ;x: 65436   y: 65458
!by $9E, $AF    ;x: 65438   y: 65455
!by $A0, $AD    ;x: 65440   y: 65453
!by $A2, $AB    ;x: 65442   y: 65451
!by $A4, $A8    ;x: 65444   y: 65448
!by $A6, $A6    ;x: 65446   y: 65446
!by $A8, $A4    ;x: 65448   y: 65444
!by $AB, $A2    ;x: 65451   y: 65442
!by $AD, $A0    ;x: 65453   y: 65440
!by $AF, $9E    ;x: 65455   y: 65438
!by $B2, $9C    ;x: 65458   y: 65436
!by $B4, $9A    ;x: 65460   y: 65434
!by $B7, $98    ;x: 65463   y: 65432
!by $B9, $96    ;x: 65465   y: 65430
!by $BC, $95    ;x: 65468   y: 65429
!by $BF, $93    ;x: 65471   y: 65427
!by $C1, $91    ;x: 65473   y: 65425
!by $C4, $90    ;x: 65476   y: 65424
!by $C7, $8F    ;x: 65479   y: 65423
!by $CA, $8D    ;x: 65482   y: 65421
!by $CD, $8C    ;x: 65485   y: 65420
!by $CF, $8B    ;x: 65487   y: 65419
!by $D2, $8A    ;x: 65490   y: 65418
!by $D5, $88    ;x: 65493   y: 65416
!by $D8, $87    ;x: 65496   y: 65415
!by $DB, $86    ;x: 65499   y: 65414
!by $DE, $86    ;x: 65502   y: 65414
!by $E1, $85    ;x: 65505   y: 65413
!by $E4, $84    ;x: 65508   y: 65412
!by $E7, $83    ;x: 65511   y: 65411
!by $EA, $83    ;x: 65514   y: 65411
!by $ED, $82    ;x: 65517   y: 65410
!by $F0, $82    ;x: 65520   y: 65410
!by $F4, $82    ;x: 65524   y: 65410
!by $F7, $81    ;x: 65527   y: 65409
!by $FA, $81    ;x: 65530   y: 65409
!by $FD, $81    ;x: 65533   y: 65409
!by $00, $81    ;x: 0   y: 65409
!by $03, $81    ;x: 3   y: 65409
!by $06, $81    ;x: 6   y: 65409
!by $09, $81    ;x: 9   y: 65409
!by $0C, $82    ;x: 12   y: 65410
!by $10, $82    ;x: 16   y: 65410
!by $13, $82    ;x: 19   y: 65410
!by $16, $83    ;x: 22   y: 65411
!by $19, $83    ;x: 25   y: 65411
!by $1C, $84    ;x: 28   y: 65412
!by $1F, $85    ;x: 31   y: 65413
!by $22, $86    ;x: 34   y: 65414
!by $25, $86    ;x: 37   y: 65414
!by $28, $87    ;x: 40   y: 65415
!by $2B, $88    ;x: 43   y: 65416
!by $2E, $8A    ;x: 46   y: 65418
!by $31, $8B    ;x: 49   y: 65419
!by $33, $8C    ;x: 51   y: 65420
!by $36, $8D    ;x: 54   y: 65421
!by $39, $8F    ;x: 57   y: 65423
!by $3C, $90    ;x: 60   y: 65424
!by $3F, $91    ;x: 63   y: 65425
!by $41, $93    ;x: 65   y: 65427
!by $44, $95    ;x: 68   y: 65429
!by $47, $96    ;x: 71   y: 65430
!by $49, $98    ;x: 73   y: 65432
!by $4C, $9A    ;x: 76   y: 65434
!by $4E, $9C    ;x: 78   y: 65436
!by $51, $9E    ;x: 81   y: 65438
!by $53, $A0    ;x: 83   y: 65440
!by $55, $A2    ;x: 85   y: 65442
!by $58, $A4    ;x: 88   y: 65444
!by $5A, $A6    ;x: 90   y: 65446
!by $5C, $A8    ;x: 92   y: 65448
!by $5E, $AB    ;x: 94   y: 65451
!by $60, $AD    ;x: 96   y: 65453
!by $62, $AF    ;x: 98   y: 65455
!by $64, $B2    ;x: 100   y: 65458
!by $66, $B4    ;x: 102   y: 65460
!by $68, $B7    ;x: 104   y: 65463
!by $6A, $B9    ;x: 106   y: 65465
!by $6B, $BC    ;x: 107   y: 65468
!by $6D, $BF    ;x: 109   y: 65471
!by $6F, $C1    ;x: 111   y: 65473
!by $70, $C4    ;x: 112   y: 65476
!by $71, $C7    ;x: 113   y: 65479
!by $73, $CA    ;x: 115   y: 65482
!by $74, $CD    ;x: 116   y: 65485
!by $75, $CF    ;x: 117   y: 65487
!by $76, $D2    ;x: 118   y: 65490
!by $78, $D5    ;x: 120   y: 65493
!by $79, $D8    ;x: 121   y: 65496
!by $7A, $DB    ;x: 122   y: 65499
!by $7A, $DE    ;x: 122   y: 65502
!by $7B, $E1    ;x: 123   y: 65505
!by $7C, $E4    ;x: 124   y: 65508
!by $7D, $E7    ;x: 125   y: 65511
!by $7D, $EA    ;x: 125   y: 65514
!by $7E, $ED    ;x: 126   y: 65517
!by $7E, $F0    ;x: 126   y: 65520
!by $7E, $F4    ;x: 126   y: 65524
!by $7F, $F7    ;x: 127   y: 65527
!by $7F, $FA    ;x: 127   y: 65530
!by $7F, $FD    ;x: 127   y: 65533


;step in the /32 pixel
Text_step
!by 10, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
!by 16, 17, 18, 19, 20, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32
!by 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48
!by 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 65
!by 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81
!by 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97
!by 98, 99, 100, 101, 102, 103, 104, 105, 106, 108, 109, 110, 111, 112, 113, 114
!by 115, 116, 117, 118, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130
!by 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146
!by 147, 148, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163
!by 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179
!by 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 193, 194, 195, 196
!by 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212
!by 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 224, 225, 226, 227, 228
!by 229, 230, 231, 232, 233, 234, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245

;amnt of pixel beafor wall, bit 7 set = pixel start in texture
Text_Start:
!by 10, 138, 138, 137, 137, 137, 136, 136, 135, 135, 135, 134, 134, 133, 133, 133
!by 132, 132, 131, 131, 131, 130, 130, 129, 129, 128, 0, 1, 1, 2, 3, 4
!by 4, 5, 6, 6, 7, 7, 8, 8, 8, 9, 9, 10, 10, 10, 11, 11
!by 11, 12, 12, 12, 12, 13, 13, 13, 13, 13, 14, 14, 14, 14, 14, 15
!by 15, 15, 15, 15, 15, 15, 16, 16, 16, 16, 16, 16, 16, 16, 17, 17
!by 17, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18
!by 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19
!by 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20
!by 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20
!by 20, 20, 20, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21
!by 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21
!by 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22
!by 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22
!by 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22
!by 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22

PixelsAngle:
!by $A0,$A3,$A6,$AA,$AE,$B2,$B7,$BD,$C2,$C8,$CC,$D1,$D6,$D9,$DD,$E0
!by $9D,$A0,$A3,$A7,$AC,$B1,$B6,$BC,$C3,$C9,$CF,$D4,$D8,$DC,$E0,$E3
!by $99,$9C,$A0,$A4,$A8,$AE,$B5,$BC,$C3,$CB,$D1,$D7,$DC,$DF,$E3,$E6
!by $96,$98,$9C,$A0,$A5,$AB,$B2,$BB,$C4,$CD,$D5,$DB,$E0,$E4,$E7,$EA
!by $91,$94,$97,$9B,$A0,$A7,$AF,$BA,$C5,$D0,$D8,$E0,$E5,$E8,$EC,$EE
!by $8D,$8F,$91,$95,$98,$A0,$AA,$B7,$C8,$D5,$E0,$E7,$EB,$EE,$F1,$F2
!by $88,$89,$8B,$8D,$90,$95,$A0,$B1,$CE,$DF,$EA,$EF,$F2,$F5,$F6,$F7
!by $83,$83,$84,$85,$86,$88,$8F,$A0,$DF,$F1,$F7,$FA,$FB,$FC,$FC,$FD
!by $7D,$7D,$7C,$7B,$7A,$78,$71,$60,$7F,$0E,$08,$05,$04,$03,$03,$02
!by $78,$76,$75,$72,$70,$6A,$60,$4F,$31,$20,$15,$10,$0D,$0B,$09,$08
!by $73,$71,$6F,$6B,$67,$60,$55,$48,$38,$2A,$20,$18,$15,$11,$0F,$0C
!by $6E,$6C,$68,$65,$60,$58,$50,$46,$3A,$30,$27,$20,$1B,$17,$14,$11
!by $6A,$68,$64,$60,$5B,$55,$4D,$45,$3B,$32,$2B,$25,$20,$1C,$18,$16
!by $66,$63,$60,$5C,$57,$51,$4B,$44,$3C,$35,$2F,$28,$24,$20,$1C,$19
!by $63,$60,$5C,$58,$54,$4F,$49,$43,$3D,$36,$31,$2C,$27,$23,$20,$1D
!by $60,$5D,$59,$56,$52,$4D,$48,$43,$3D,$37,$33,$2E,$2A,$26,$23,$20

screen_offset_l: 
!for pos, 0, 19 {	!byte <(pos*40) }
screen_offset_h: 
!for pos, 0, 19 {	!byte >($7c00+(pos*40)) }

focalFix:
!by 148
!by 158
!by 167
!by 176
!by 185
!by 193
!by 200
!by 208
!by 215
!by 221
!by 227
!by 232
!by 237
!by 241
!by 245
!by 248
!by 250
!by 252
!by 254
!by 255
!by 255
!by 255
!by 254
!by 252
!by 250
!by 248
!by 245
!by 241
!by 237
!by 232
!by 227
!by 221
!by 215
!by 208
!by 200
!by 193
!by 185
!by 176
!by 167
!by 158

textureMask:
!by 1,2,4,8,16,32,64,128

;***************************************************
; texture
!align 15, 0		;align to 256 block so its faster
textureTest:
!by %11111111
!by %10000001
!by %10000001
!by %10000001
!by %10000001
!by %10000001
!by %10000001
!by %10000001
!by %10000001
!by %10000001
!by %11111111
!by %10010001
!by %10010001
!by %10010001
!by %10010001
!by %11111111