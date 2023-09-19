.include "inc/global.inc"

.segment "CODE"
main:
	
; main code here
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
forever:
	jmp forever
