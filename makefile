all:
	ca65 *.asm -o main.o 
	ld65 *.o -o star-command.nes -t nes
	Mesen star-command.nes
clean:
	rm *.nes *.o
