all:
	asm6 main.asm star-command.nes
	fceux star-command.nes
clean:
	rm *.nes
