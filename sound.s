;**************************************
; init sound
;
; Sound_Init
;

Sound_Init:
	;prevent interupt
	sei
	lda #<sound_irq
	sta $fffa
	lda #>sound_irq
	sta $fffb
	
	;set timer
	lda #$6
	sta $DD06
	lda #$0
	sta $DD07	;set timer count to 25x/s
	lda #$51
	sta $DD0F	;set timer option
	
	lda #$f0
	sta $DD04
	lda #$ff
	sta $DD05	;set timer count to 25x/s
	lda #$11
	sta $DD0E	;set timer option
	lda #$d4
	sta musicVoicePtr+1
	lda #$7f
	sta $DD0D	;clear irq of cia1
	lda #$82
	sta $DD0D	;set irq for timer a
	
	lda #0
	ldx #0
sini_jmp1
	sta $d400,x
	inx
	cpx #$18
	bne sini_jmp1
	
	
	lda #32		;set default instrument
	sta voiceWf
	sta voiceWf+1
	sta voiceWf+2
	
	lda #9		;A=O,D=9
	sta $D405 
	sta $D40C 
	sta $D413
	lda #0		;S=O,R=O
	sta $D406
	sta $D40D 
	sta $D414 
	
	lda #15
	sta $D418	;set volume to max
	
	jsr Music_Stop
	lda $DD0D
	cli
	rts


;**************************************
; stop playing
;
; Music_Stop
;

Music_Stop:
	lda #0
	sta canPlayMusic
	rts


;**************************************
; play music
;
; Music_Start
;

Music_Start:
	lda musicStart
	sta musicOff
	lda musicStart+1
	sta musicOff+1
	lda #1
	sta canPlayMusic
	rts



;**************************************
; IRQ handler
;

sound_irq:
	sta sirqA
	stx sirqX
	sty sirqY
	lda $DD0D
	and #2
	bne sirGo
	lda canPlayMusic
	bne sirGo
	jmp sirDone
sirGo:
	
	ldy #0
	lda (musicOff),y ;number of action
	iny
	cmp #0
	beq sirDone2
	tax
sirLoop1:
	lda (musicOff),y
	cmp #$80 ;restart (loop point)
	bne sirVoice
		lda musicStart
		sta musicOff
		lda musicStart+1
		sta musicOff+1
	jmp sirJmp1
sirVoice
	cmp #3
	bpl sirInstrument	;no other fnc for now
		;load all data
		sta musicVoiceid
		iny
		lda (musicOff),y
		iny
		sta musicNote

		sty sirBy
		ldy musicVoiceid
		lda sound_ioptr,y
		sta musicVoicePtr
		lda musicNote
		beq sirMute
		asl
		tay
		lda sound_note,y
		sta music_freqLow
		iny
		lda sound_note,y
		ldy #1
		sta (musicVoicePtr),y
		dey
		lda music_freqLow
		sta (musicVoicePtr),y	
		ldy musicVoiceid
		lda voiceWf,y
		ldy #4
		sta (musicVoicePtr),y
		ora #1
		sta (musicVoicePtr),y

		ldy #$FF
sirBy = *-1
		jmp sirJmp1
sirMute:
		sty sirBy2
		lda #0
		ldy #4
		sta (musicVoicePtr),y
		ldy #$FF
sirBy2 = *-1
		jmp sirJmp1
sirInstrument:
	cmp #$13
	bpl sirJmp1
	jsr soundSetInstrument
sirJmp1:
	dex	;are we done?
	bne sirLoop1

sirDone2:
	tya
	clc
	adc musicOff
	sta musicOff
	bcc sirDone
	inc musicOff+1
sirDone:
	
	ldx #$ff
sirqX = *-1
	ldy #$ff
sirqY = *-1
;lda #$19
;	sta $DD0E	;set timer option
	lda #$ff
sirqA = *-1
	rti
	
	
	
	
	
soundSetInstrument:
	and #$3
	sta musicVoiceid
	iny
	lda (musicOff),y
	iny
	sta musicNote

	sty sirBy3
	ldy musicVoiceid
	lda sound_ioptr,y
	sta musicVoicePtr
	lda musicNote
	asl
	asl
	tay
	lda snd_instrument,y
	sta musicInst
	iny
	lda snd_instrument,y
	sta musicInst+1
	iny
	lda snd_instrument,y
	sta musicInst+2
	
	ldy #5
	lda musicInst
	sta (musicVoicePtr),y	
	iny
	lda musicInst+1
	sta (musicVoicePtr),y	
	ldy musicVoiceid
	lda musicInst+2
	sta voiceWf,y

	ldy #$FF
sirBy3 = *-1

	rts
	
sound_ioptr
!by 00,07,$e

sound_note
!by 0,0
    ;G      G#     A       A#      B       C       C#      D       D#      E       F       F#	
!by 36,6,   130,6, 228,6,  77,7,   189,7,  50,8,   175,8,  51,9,   191,9,  84,10,  241,10, 152,11
!by 73,12,  4,13,  201,13, 156,14, 122,15, 101,16, 96,17,  104,18, 128,19, 169,20, 227,21, 49,23
!by 146,24, 8,26,  148,27, 57,29,  245,30, 204,32, 192,34, 208,36, 1,39,   83,41,  200,43, 99,46



snd_test:
!by 1,0,17 ,0 ,1,0,15 ,1,0,10 ,0 ,1,0,13 ,0
!by 1,0,17 ,0 ,1,0,15 ,1,0,10 ,0 ,1,0,8 ,1,$10,1
!by 1,0,17 ,0 ,1,0,15 ,1,0,10 ,0 ,1,0,13 ,0
!by 1,0,17 ,0 ,1,0,15 ,1,0,10 ,0 ,1,0,8 ,2,$10,0
!by $80 ;repete


snd_instrument:
!by 9,0,32,0	;piano
!by 9,0,16,0	;xylophone

