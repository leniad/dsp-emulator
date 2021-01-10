﻿# DSP Emulator status #
<b>10/01/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Gameboy/Gameboy Color review
    +Fixed mapper MBC1
    +Added MBC1 collection version (fixes 'Bomberman Collection', 'Mortal Combat I&II', '4 in 1 Vol II', etc)
    +Fixed mapper MBC2
    +Added mapper MBC3
    +Added partial MBC7
    +Fixed cartridge load (fixes cartridges bigger than 4Mb)
    +Fixed cartridge default start values (fixes 'Dragon's Lair - The Legend' and many others)
    +Fixed OAM DMA, dont add aditional CPU cycles and dont draw sprites if its running
    +Fixed CGB DMA, change the counter values when running (fixes 'Turok - Rage Wars', 'Aliens - Thanatos Encounter' and many others)
    +Fixed CBG DMA start/stop info and cancel option (fixes 'Championship Motocross 2001' and others)
    +Fixed CGB sprite/BG priority (fixes graphis in '007 - The World is Not Enough' intro)
    +Fixed CBG sprite tranparency
    +Added sprite draw order (fixes 'Boy and His Blob, A - Rescue of Princess Blobette')
    +Added a basic serial IRQ (makes 'Mortal Kombat' run)
    +Added STAT IRQ blocking (makes 'Altered Space', 'Pinball Fantasies', 'Pinball Dreams' and many others run)
    +Fixed controls (fixes 'Konami GB Collection Volume 1')
    +Fixed BIOS disable... Ouch! Never gets enabled again after boot!
</pre>
<img src='https://i.ibb.co/fSXQ5HJ/007.jpg'> <img src='https://i.ibb.co/S02H0G8/alien.jpg'> <img src='https://i.ibb.co/FgqHLQf/tarta.jpg'><br>
<img src='https://i.ibb.co/HNBLtnN/altered.jpg'> <img src='https://i.ibb.co/QpS6Hcs/DL.jpg'><br>
<img src='https://i.ibb.co/SQNzFt8/nascar.jpg'> <img src='https://i.ibb.co/f9XBSvR/Perfect-Dark.jpg'><br>
<img src='https://i.ibb.co/2tgpJnp/turok.jpg'> <img src='https://i.ibb.co/NtFTbKK/xmen.jpg'><br><br>
<b>02/01/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Blood Bros HW
    +Blood Bros.: Added driver with sound
    +Sky Smasher: Added driver with sound
</pre>
<img src='https://i.ibb.co/qYtR8zM/Blood-Bros.jpg'><img src='https://i.ibb.co/QcjZ5vR/Sky-Smasher.jpg'><br><br>
<b>30/12/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
    +CPU
        -M68000: Fixed sign in opcode pea.w
    +Video: Added a function to change video resolution on execution time
-3x3 Puzzle HW
    +3x3 Puzzle: Added driver with sound
    +Casanova: Added driver with sound
-1945k III HW
    +1945k III: Added driver with sound
    +96 Flag Rally: Added driver with sound
</pre>
<img src='https://i.ibb.co/RTvMTWp/3x3-Puzzle.jpg'><img src='https://i.ibb.co/tXhw2Fw/Casanova.jpg'><br>
<img src='https://i.ibb.co/9ZHffKf/1945k-III.jpg'><img src='https://i.ibb.co/Zg1p5m2/96-Flag-Rally.jpg'><br><br>
<b>27/12/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Lazarus
    +More cosmetical changes
    +Fixed 'no sound' option
-General
    +CPU
        -Z80: Fixed a stupid bug on IRQ
-SNK
    +Fixed rotation buttons
    +ASO - Armored Scrum Object: Added driver with sound
-Fire Trap
    +Added driver with sound
</pre>
<img src='https://i.ibb.co/tbPFC5s/ASO.jpg'><img src='https://i.ibb.co/7k0tR07/FireTrap.jpg'><br>
Merry Christmas and happy new year!!
<img src='https://i.ibb.co/ZMswJ6h/santa.gif'><br><br>
<b>14/12/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Lazarus
    +Cosmetical changes (icons, objects size...)
    +Fixed change screen size from options menu
-Game & Watch
    +Finaly find a solution to compile under Lazarus
-Amstrad CPC
    +You can load disks again... Opps!
</pre><br><br>
<b>08/12/20 - DSP Emulator 0.18b3 WIP. Win32, macOS64 and source update.<br><pre>
-Added macOS 64bits WIP compilation, tested on v10.15 and v11.0
-NES
    +Changes on mapper 5, fixes PRG mapping
-Tecmo HW
    +Fixed small bug on ADPCM
    +Fixed FPS
    +Silkworm:
        -Fixed sound chip, it's a YM3812
        -Fixed Z80 clock
</pre><br><br>
<b>01/12/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Sega VDP
    +Fixed IRQ generation
-Sega GameGear
    +Added driver with sound
    +Added Codemasters mapper
-Sega Master System
    +Added cart enable/disable
    +Driver stop and warning if no BIOS present
-Armed F HW
    +Added driver for Crazy Climber 2
    +Added driver for Legion
</pre>
<img src='https://i.ibb.co/0cy0d0J/cclimber2.jpg'>
<img src='https://i.ibb.co/v3rFCPQ/legion.jpg'><br>
<img src='https://i.ibb.co/j3J1Q23/sonic.jpg'>
<img src='https://i.ibb.co/X8XvmNn/street-rage.jpg'>
<img src='https://i.ibb.co/L6cGmQg/jedi.jpg'><br><br>
<b>25/11/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-SG-1000
    +Added two mappers. Almost 100% compatibility now
-Armed F HW
    +Added Terra Force driver with sound
</pre>
<img src='https://i.ibb.co/bsBmfcc/Terra-Force.jpg'>
<img src='https://i.ibb.co/DQr1WRB/kings.jpg'>
<img src='https://i.ibb.co/Dtnt3dP/yakf2.jpg'><br><br>
<b>23/11/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Armed F HW
    +Added Armed F driver with sound
</pre>
<img src='https://i.ibb.co/wwKDKzy/Armed-F.jpg'><br><br>
<b>13/11/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
    +TMS99XX: Fixed video mode 2
-Coleco
    +Added Mega Cart support: ROM pagination
    +Added Super Game Module support: More RAM and AY8912
    +Added support for Boxxle and Black Onix (missing EEPROM)
</pre>
<img src='https://i.ibb.co/Kbdy6Dh/dragon.jpg'>
<img src='https://i.ibb.co/g6BcNn3/jetpac.jpg'>
<img src='https://i.ibb.co/b6C6hCc/mario.jpg'>
<img src='https://i.ibb.co/myvKXbb/pacman.jpg'><br><br>
<b>06/11/20 - DSP Emulator 0.18b2 Final. Almost three years have passed since the last update! Updated Win32 binary and source code.
The executables for Linux and Mac this time are not compiled, if someone needs them let me know..</b><br>
Many, many changes. The most important are:<br><pre>
-General
    +YM2203/YM2151/YM3812: Fixed (finally!) the FM sound, improves a lot Shinobi, Rastan, Ghost'n Goblins, Snow Bros...
    +CPU's: Added some CPU's, many fixes and new opcodes
-8bit computer
    +Spectrum: 100% emulated 'floating bus', added 'Turbo sound'..
    +Commodore 64: Added a initial driver
-Consoles
    +NES: Fixed many video issues, added many mappers...
    +Sega Master System: Improved driver, almost 100% working games
-Arcade
    +Added some MCUs to emulate protections, added 24 new games, added dipswitches...
</pre>
All changes in 'Whatsnew.txt'. Some snapshots later<br><br>
<b>31/12/17 - DSP Emulator 0.18 Final. Source and all binaries updated.</b><br>
All previous changes and...<br><pre>
-General
    +Lazarus: Changed then way SDL library initializes the audio, using the newer functions
    +Better Open/Save dialogs. Now work the last directory used for each system
    +Changed where and when the SDL library is initializated
-NES
    +Fixed mappers 1, 4, 12, 67 and 68
    +Added mappers mmc6, 11 and 147
-Contra
    +Added DIPs switches
-Knuckle Joe
    +Added DIPs switches and 2nd player
-Super Basketball
    +Added DIPs switches and 2nd player
-Iron Horse
    +Updated to version K
</pre>
Please read the 'Whats New' for a full list of changes<br>
Merry Christmas and happy new year!<br><br>
<b>05/12/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br>
New WIP update! Gauntlet HW completed!<br><pre>
-General
    +CPU engine: Fixed reset state when is asserted (not pulsed)
    +M6502 CPU: Set BRK flag disabled on reset
    +M68000: Added M68010, and changed some opcodes
    +Slapstic: Enhanced some functions, added more revisions
    +Atari MO: Added Atari sprite system
    +Palette engine: added a function for 4bits+intensity palette generator
-Iron Horse
    +Updated to version K
-Gauntlet HW
    +Gauntlet: Completed driver, added video, sprites, audio and controls
    +Gauntlet II: Added driver with sound
-Atari System I
    +Peter Pakrat: Basic driver
</pre><br>
<img src='http://img1.imagilive.com/1217/gauntlet.png'><img src='http://img1.imagilive.com/1217/gauntlet_play.png'><img src='http://img1.imagilive.com/1217/gauntlet2.png'><img src='http://img1.imagilive.com/1217/gauntlet2_play.png'><br>
<b>21/10/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br>
After some health problems (visit to the hospital included), I publish a new WIP update<br><pre>
-General
    +Slapstic: Added Atari Protection device
    +Pokey: Added the function to define ALL_POT call
    +Improved column scroll function
    +Added a specific function for shadow sprites
-Gameboy / Gameboy Color
    +Improved video timmings
    +Corrected colors in GBC
    +Fixed some control bits (Serial, IRQ, Joystick, etc.)
    +Corrected the function that compares line Y
    +Fixed HDMA functions in GBC
    +Improved HU-C1 and MMMM01 mappers
-Food Fight
    +Added default NVRAM load
    +Correct the size and data type of the NVRAM
-Sega System 1/2
    +Fixed Z80 timmigs
    +Added DIPs to all games and 2nd player
    +Improved sound IRQs
-Mappy HW
    +Super Pacman: Fixed sprites
-Tetris (Atari)
    +Added driver with sound
-SNK HW
    +Ikari Warriors: Added driver with sound
    +Athena: Added driver with sound
    +T.N.K III: Added driver with sound
</pre><br>
<img src='http://img1.imagilive.com/1017/tetris_atari.png'><img src='http://img1.imagilive.com/1017/ikari.png'><img src='http://img1.imagilive.com/1017/athena.png'><img src='http://img1.imagilive.com/1017/tnk3.png'><br>
<b>13/07/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br>
Enhanced Amstrad CPC emulation<br><pre>
-Game and Watch
    +Added 'Mario Bros.', missing graphics
    +Better sound emulation
-Amstrad CPC
    +Better CPC Z80 timings
    +Added configuration for tape motor, you can select if it is used in the emulation of the virtual tape or not
    +Improved video (registers, vsync, hsync, etc.)
    +Improved memory management, 512Kb expansion it's working properly
    +Improved interruptions
-Super Darwin
    +Added MCU, simulated protection removed
    +Corrected palette and VBLANK
    +Added 2nd player controls, dip switches and screen flip
</pre><br>
<img src='http://img1.imagilive.com/0717/rex.png'><img src='http://img1.imagilive.com/0717/buggy.png'><img src='http://img1.imagilive.com/0717/helichopper.png'><br>
<b>11/06/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br>
At last I have emulated (not simulated) two Game and Watch games!. Thanks to MAME for the ROMs and the info.<br><pre>
-General
    +SM510: Added new CPU
-Spectrum
    +Simplified and standardized speaker functions
-Game and Watch
    +Donkey Kong Jr: Added game with sound
    +Donkey Kong II: Added game with sound
</pre><br>
<img src='http://img1.imagilive.com/0617/gnw_dkongjr.png'><img src='http://img1.imagilive.com/0617/gnw_dkong2.png'><br>
<b>10/05/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br><pre>
-General
    +GFX: Added functions to rotate X axis and/or Y axis of a surface
-Psychic 5
    +Fixed intro
-Crazy Climber
    +Added driver with sound
-Return of the Invaders
    +Added driver with sound
</pre><br>
<img src='http://img1.imagilive.com/0517/crazyclimber.png'><img src='http://img1.imagilive.com/0517/returnoftheinvaders.png'><br>
<b>28/04/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br><pre>
-General
    +Lazarus
        -Fixed stereo sound
        -Improved audio synchronization
    +GFX
        -Added final screen independent flip X or flip Y
        -Improved scrolling by independent rows and/or columns
        -Improved zoom sprites (no more graps)
    +Deco BAC06
        -Converted to classes
        -Fixed bugs and more speed
    +Deco 16IC: Converted to classes
    +K051960, K05324x: Optimized sprites rendering
    +K007232
        -Support of two simultaneous audio chips
        -Fixed stereo support
    +K053260: Fixed stereo support
    +MCS51
        -Corrected registers, mapped in memory
        -Added more opcodes
-Deco 0 HW
    +Driver optimizations
    +Added dipswitches
    +Baddudes: Added i8751, protection patches removed
-Caveman Ninja HW
    +Fixed raster interrupts
    +Robocop 2: Fixed video
-Toki
    +Fixed sprites
-ActFancer
    +Optimized driver
    +Added dipswitches
-Gradius III
    +Changed sound to stereo
-Simpsons
    +Changed sound to stereo
-Vendetta
    +Changed sound to stereo
-Ajax
    +Fixed audio (converted to stereo)
    +Fixed video (missing k051316 zoom/rotate)
    +Added controls
    +Added dipswitches
-Gauntlet HW
    +Basic driver
-Sauro
    +Added driver with sound, only missing ADPCM
</pre><br>
<img src='http://img1.imagilive.com/0417/sauro.png'><br><br>
<b>11/03/17 - DSP Emulator 0.17b2 Final. All binary and source updated.</b><br><pre>
-All WIP previous enhacements
-General
    +Fixed a bug when entering the options menu without starting a driver (Thanks to FJ Marti)
    +If a driver is not initialized when exiting the list, no buttons are displayed
    +Added multiple directories for arcade ROMS separated by ';' (requested by Davide)
    +Fixed enter full screen when changing from video menu
    +K054000: Added protection chip
    +K053246-K053247-K055673: Implemented functions to show sprites
-GameBoy/GameBoy Color
    +Rewritted the video functions
    +Corrected read/write of MBC5 mapper extra memory
    +Corrected the sound 'mode 3'
    +Corrected reading of the joystick/buttons when ussing the IRQ
    +Improved way to compare the current line that generates an IRQ
    +Improved timings of the current line
    +GameBoy Color
        -Corrected the size of the palette records. Fixed when the palette pointer is automatically advanced
        -Improved way to change speed
    +Improved loading a cartridge with an extra header before the data
    +Added mappers HuC-1 (to be confirmed) and MBC2
-Pacman HW
    +Added the rest of dipswitch
    +Added screen rotation
    +Crush Roller: Added driver with sound
-Galaxian HW
    +Fixed Scrambre sound, caused errors when closing the driver
-TNZS HW
    +Corrected audio initialization
-TMNT HW
    +TMNT: Changed the ROMS to 2 players version
-The Simpsons
    +Fixed video and audio
    +Graphics problems (possible bug in the CPU)
    +Changed the ROMS to the 2 Players version (requested by Davide)
-Vendetta (requested by Davide)
    +Added driver with sound
</pre><br>
Please read the 'Whats New' for details<br>
<img src='http://img1.imagilive.com/0317/simpsons.png'><img src='http://img1.imagilive.com/0317/vendetta.png'><br>
<b>22/01/17 - DSP Emulator 0.17b2 WIP. Updated source and windows 32bits binary</b><br>
<pre>
-General
    +Autofire
        -General options -> Autofire -> Enable/disable
        -Independent for each button
    +CPU: Unified functions in/out with read/write
    +Tape Engine
        -Improved handling of 1-byte blocks in TAP tapes
        -Added control to avoid blocks of 0 length in TAP tapes
        -Corrected the length of the message block of the TZX tapes
    +After pressing F4 to record a snapshot, the file select screen no longer is shown each time a key is pressed
    +UPD765: Improved processing a track with 0 sectors (Corrects 'Tomahawk' from Spectrum +3)
-Spectrum
    +Added Fuller joystick, and improved descriptions of other types of joystick
    +Fixed Cursor joystick, only works if selected
    +Improved Kempston joystick
-Galaxian HW
    +Moon Cresta
        -Improved sound with samples
        -Fixed a problem with chars/sprites
</pre>