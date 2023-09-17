.include "inc/global.inc"

.segment "INESHDR"
	.byte "NES" 		; string required for iNES header
	.byte $1a				; signature of iNES header that the emulator will look for
	.byte $01 				; 16KB PRG ROM
	.byte $01  				; 8KB CHR ROM
	.byte %00000000 		; mapper and mirroring. none yet
	.byte $0
	.byte $0
	.byte $0
	.byte $0
	.byte $0, $0, $0, $0 	; unused. 
.segment "ZEROPAGE"
.segment "STACK"
.segment "SHADOWOAM"
	shadowoam:
		.res 64 * 4
.segment "BSS"
	playerX: .res 1 	; player's X position (will be updated)
	playerY: .res 1 	; player's Y position (will *not* be updated)
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
	mainLoop:
		jmp main
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
		; load values into x and y variables
		lda #$80
		sta playerX
		sta playerY

		; load 0 into the A register to reset it
		lda #$0
		
		; y, tile num, attributes, x
		; tile 0
		.byte playerY, $00, $00, playerX
	.segment "VECTORS"
	    .word  NMI
	    .word  Reset
	    .word  0
	.segment "CHR"
		.incbin "tiles.chr"
