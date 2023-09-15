.segment "HEADER"
	.byte "NES" 			; string required for iNES header
	.byte $1a				; signature of iNES header that the emulator will look for
	.byte $02 				; 2 * 16KB PRG ROM
	.byte $01  				; 1 * 8KB CHR ROM
	.byte %00000000 		; mapper and mirroring. none yet
	.byte $0
	.byte $0
	.byte $0
	.byte $0
	.byte $0, $0, $0, $0 	; unused. 
	.segment "ZEROPAGE"
		
	.segment "STARTUP"
	.segment "CODE"

Reset:
    sei        ; ignore IRQs
    cld        ; disable decimal mode, as the NES doesn't really have it. (techincally not required, but it's good practice to do so)
    ldx #$40
    stx $4017  ; disable APU frame IRQ
    ldx #$ff
    txs        ; Set up stack
    inx        ; now X = 0
    stx $2000  ; disable NMI
    stx $2001  ; disable rendering
    stx $4010  ; disable DMC IRQs

    ; Optional (omitted):
    ; Set up mapper and jmp to further init code here.

    ; The vblank flag is in an unknown state after reset,
    ; so it is cleared here to make sure that @vblankwait1
    ; does not exit immediately.
    bit $2002

    ; First of two waits for vertical blank to make sure that the
    ; PPU has stabilized
@vblankwait1:  
    bit $2002
    bpl @vblankwait1

    ; We now have about 30,000 cycles to burn before the PPU stabilizes.
    ; One thing we can do with this time is put RAM in a known state.
    ; Here we fill it with $00, which matches what (say) a C compiler
    ; expects for BSS.  Conveniently, X is still 0.
    txa
@clrmem:
    sta $000,x
    sta $100,x
    sta $200,x
    sta $300,x
    sta $400,x
    sta $500,x
    sta $600,x
    sta $700,x
    inx
    bne @clrmem

    ; Other things you can do between vblank waits are set up audio
    ; or set up other mapper registers.
   
@vblankwait2:
    bit $2002
    bpl @vblankwait2
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
	sta $0200, x
	inx
	cpx #$30 ;(4 bytes per sprite, 1 sprite *for now*)
	bne LoadSprites
			
	; re-enable interrupts
	lda #%10000000   ; enable NMI, sprites from Pattern Table 0
	sta $2000
		
	lda #%00010000   ; enable sprites
	sta $2001
forever:
	jmp forever
NMI:
	lda #$00
	sta $2003 	; set the low byte (00) of the RAM address
	lda #$02
	sta $4014 	; set the high byte (02) of the RAM address, and start the transfer
	rti 		; return from interrupt
IRQ:
	;NOTE: IRQ code goes here
PaletteData:
	.byte $0e, $27, $10, $30,  $0f, $0f, $0f, $0f,  $0f, $0f, $0f, $0f,  $0f, $0f, $0f, $0f ; background palette data
	.byte $0e, $00, $10, $30,  $0f, $0f, $0f, $0f,  $0f, $0f, $0f, $0f,  $0f, $0f, $0f, $0f ; sprite palette data
SpriteData:
	; y, tile num, attributes, x

	; tile 0
	.byte $80, $07, $00,$80
.segment "VECTORS"
    .word  NMI
    .word  Reset
    .word  0
.segment "CHARS"
	.incbin "tiles.chr"
