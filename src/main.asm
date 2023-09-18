.include "inc/global.inc"

	.segment "CODE"
main:
; simple code for testing audio, since the NES can't easily print text. this is basically the 2A03
; equivalent to a C "Hello, World" program :3 
	lda #$01	; square 1
	sta $4015
	lda #$08	; period low
	sta $4002
	lda #$02	; period high
	sta $4003
	lda #$bf	; volume
	sta $4000

	lda $2002    ; read PPU status to reset the high/low latch to high
	lda #$3F
	sta $2006    ; write the high byte of $3F10 address
	lda #$10
	sta $2006    ; write the low byte of $3F10 address
	
	ldx #$00
	LoadPalettes:
		lda PaletteData, x      	                          
		sta $2007               
		inx                     
		cpx #$20               
		bne LoadPalettes 
		     
		ldx #$00
	LoadSprites:
		lda SpriteData, x		
		sta shadowoam, x
		inx
		cpx #$30 ;(4 bytes per sprite, 1 sprite *for now*)
		bne LoadSprites

	lda #$90
	sta playerX 	; store value into playerX variable

	ldx playerX 
	sta $0203 		; store playerX into bit 4 of sprite 0
			
	; re-enable interrupts
	lda #%10000000   ; enable NMI, sprites from Pattern Table 0
	sta $2000
		
	lda #%00010000   ; enable sprites
	sta $2001
forever:
	jmp forever
