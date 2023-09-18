# about
this is an NES port of star command, a game that I developed with love2D. I wanted to get back into assembly, and 
for some reason decided the NES. don't ask. it probably wasn't the best choice, but it works.

# dependencies
ca65 (part of the cc65 suite of tools)<br>
ld65 (also part of the cc65 suite of tools)<br>
GNU make<br>
any NES emulator (preferably Mesen2, as there's a make target for running with Mesen.)
<br>
## build instructions
assuming the cc65 toolset is installed and on PATH, and GNU make is installed, just type `make` in the root project
directory. it *should* work.

an NES rom should be outputted in bin/. just load it in your favorite NES emulator. if Mesen2 is installed, and also
on PATH, typing `make run` will load the rom with Mesen2 :3

## Credits
this project wouldn't be possible without these cool people
[sylvie](https://github.com/zlago) - my sweet girlfriend. provided the makefile to use, and helped with general assembly help.<br>
the entire NESdev community. seriously, without them this **definitely** wouldn't be possible, cause the entire community is just so helpful :3
<br><br>
that's all for now~
