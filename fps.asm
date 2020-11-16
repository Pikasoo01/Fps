	!to"build/fps.prg",cbm

	!src "const.asm"
	!src "zeropage.asm"
	
	* = $0801
	!by $0d,$08,$0a,$00,$9e,$32,$30,$38,$30
    	
	* = $0820
setup
	;prevent interupt
	sei
	
	;setup memory layout
	LDA #$35
	STA 1
	
	;setup stack
	LDX #$FF
	TXS
	
	lda #<interupt_handler
	sta $fffe
	sta $fffc
	sta $fffa
	lda #>interupt_handler
	sta $ffff
	sta $fffd
	sta $fffb
	
	;disable all interupt
	lda #0
	sta $D01A ;vic irq
	
	
	lda #$00
	sta $d020 ;black border
	lda #0
	sta $d021	;block background
	
	
	lda #$80
	sta playerPosX+1
	sta playerPosY+1
	lda #0		;45deg view for test
	sta playerDir	
	lda #$10
	sta playerPosX
	sta playerPosY 	;set the player for test
	
	;set char color
	lda #5
	ldy #0
-	sta $d800,y
	sta $d900,y
	sta $da00,y
	sta $db00,y
	iny
	bne -


	ldy #0			;set flip buffer value
	lda #0
-	
	sta $7c00,y
	sta $7d00,y
	sta $7e00,y
	iny
	bne -

	ldy #0
-	lda flipData,y	;copy char map into fast mem
	sta $f0,y
	iny
	cpy #16
	bne -
        
	jsr CopyFakeMap
        
main_loop1:
	;get key for motion
	inc $770
	inc playerDir
	;inc playerDir
	;inc playerDir

	;move player
	
	;do action
	
	;cpu AI
	
	;draw
	jsr Draw3dScreen
	jsr processSprite

	jsr FlipScreen
	
	jmp main_loop1
	
	
interupt_handler
	;jmp *
	rti
	
;memory map
; 0000 - 01ff used by cpu + zeromem
; 0200 - 02FF	free
; 0300 - 03FF	Map section
;
; 7C00 - 7FFF   Video flip buffer

CopyFakeMap:
	ldy #0
-	lda fmdata,y
	sta $300,y
	iny
	bne -
	rts

	
!src "3dhelper.asm"
!src "3d.asm"
!src "sprite.asm"

;fake map data
fmdata:
!by 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
!by 1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1
!by 1,0,0,0,16,1,0,1,1,1,0,0,0,0,0,1
!by 1,0,0,0,0,0,0,1,0,1,0,0,0,0,0,1
!by 1,1,1,1,1,0,0,1,0,1,1,1,1,1,1,1
!by 1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1
!by 1,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1
!by 1,0,0,0,0,1,1,1,0,0,0,0,0,0,0,1
!by 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
!by 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
!by 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
!by 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
!by 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
!by 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
!by 1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1
!by 1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1

object_x !by (4*8)+4
object_y !by (2*8)+4