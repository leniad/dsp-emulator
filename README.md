# DSP Emulator status #
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
    +Added DIPs to all games and 2on player
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
<img src='http://img1.imagilive.com/1017/tetris_atari.png'><img src='http://img1.imagilive.com/1017/ikari.png'><br>
<img src='http://img1.imagilive.com/1017/athena.png'><img src='http://img1.imagilive.com/1017/tnk3.png'><br><br>
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
<img src='http://img1.imagilive.com/0717/rex.png'><img src='http://img1.imagilive.com/0717/buggy.png'><img src='http://img1.imagilive.com/0717/helichopper.png'><br><br>
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
<img src='http://img1.imagilive.com/0617/gnw_dkongjr.png'><img src='http://img1.imagilive.com/0617/gnw_dkong2.png'><br><br>
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
<img src='http://img1.imagilive.com/0517/crazyclimber.png'><img src='http://img1.imagilive.com/0517/returnoftheinvaders.png'><br><br>
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
<img src='http://img1.imagilive.com/0317/simpsons.png'><img src='http://img1.imagilive.com/0317/vendetta.png'><br><br>
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
    +After pressing F4 to record a snapshot, the recording screen no longer shows each time a key is pressed
    +UPD765: Improved processing a track with 0 sectors (Corrects 'Tomahawk' from Spectrum +3)
-Spectrum
    +Added Fuller joystick, and improved descriptions of other types of joystick
    +Fixed Cursor joystick, only works if selected
    +Improved Kempston joystick
-Galaxian HW
    +Moon Cresta
        -Improved sound with samples
        -Fixed a problem with chars/sprites
</pre><br>
<b>31/12/16 - DSP Emulator 0.17b2 WIP. Source and windows 32bits updated</b><br>
After three months entering and leaving the hospital, I have time to update the emulator. I hope I will recover soon and upload more updates<br>
Merry Christmas and happy new year!<br>
<pre>
-General
    +GFX engine: GFX functions optimizations, more speed
    +UPD765
        -Fixed next sector ID load function
        -Fixed a stupid bug when reading a full track (Fixes Spectrum +3 'Platoon' and many others)
    +Disk loading: Fixed some problems selecting compressed files
    +DSK files: Fixed track number asignation
    +Cleaning and optimizations in many drivers (input, video, controls, etc)
    +Namco sound
        -Converted to clases
        -Fixed some bugs
        -Converted to standard audio functions
    +M680X: Added internal RAM
    +Deco 16ic: Converted playfield RAM to word, changed functions and drivers
    +Mouse: Created new functions to standarize the cursor show/hide and creation
    +M68000: Fixed carry flag on opcode roxr.l
    +OKI 6295: Added snapshot functions
    +Samples: Fixed a bug assigning the audio channel
-Amstrad CPC
    +Fixed WAV tape file loading
-Black Tiger
    +Video optimizations
-Asteroids HW
    +Small audio optimizations
    +A video rewrite needed!
    +Asteroids: Small memory optimizations
    +Lunar Lander: added driver, no sound
-Express Raider
    +ROMS updated to 'World V4'
-Gunsmoke HW
    +Added dip switches to all games
    +Added a simulated copy protections
-Higemaru
    +Added dip switches
    +Added P2 controls
-Iron Horse
    +Added dip switches
    +Small video optimizations
-Jackal
    +Added dip switches
-Jr Pacman
    +Added dip switches
    +Fixed screen rotation
    +Added P2 controls
-Shoot Out
    +Optimized sprites
    +Implemented IRQ
-Vulgus
    +Added dip switches
    +Added P2 controls
-Vigilante
    +Updated ROMS to version 'World E'
    +Fixed background scroll
-Space Firebird
    +Fixed dip switches
-Combat School
    +Video optimizations, more speed
    +Added dip switches
-Twin Cobra HW
    +Implemented video on/off
-Double Dragon 3 HW
    +Added snapshot functions
    +Double Dragon 3
        -Fixed scroll ('Egypt' screen)
        -Fixed controls
    +The Combatribes: Added driver with sound
</pre><br>
<img src='http://img1.imagilive.com/1216/ctribes.png'><img src='http://img1.imagilive.com/1216/llander.png'><br>
<b>22/10/16 - DSP Emulator 0.17b1 Final. All binary and source updated. New preview images (thanks to FJ Marti)</b><br><pre>
-All previous WIP enhacements
-General
    +Windows: Fixed image snapshot save bug (Thanks to FJ Marti)
    +Fixed a bug that if DSP is started with the ROMs list and no driver was selected, the emulator hangs (Thanks to FJ Marti)
    +Fixes to the ROMs/Samples file list exportation (Thanks to FJ Marti)
    +N2A03 
        -Converted to CPU
        -Converted to classes
    +Taito Sound
        -Converted to classes
        -Integrated Z80 CPU
    +Konami Sound
        -Converted to classes
        -Integrated Z80 CPU
-ExedExes
    +Added dipswitches
-Express Raider
    +Added dipswitches
-Double Dragon HW
    +Fixed IRQs
    +Double Dragon II: Fixed VBlank, solves the problem of color fading in transitions
</pre><br>
<b>15/10/16 - DSP Emulator 0.17b1. Win32 binary and source updated.</b><br><pre>
-General
    +Namco IO
        -Added 50XX control CPU
        -Added 54XX sound CPU, using samples
    +MB88XX CPU: Added opcodes $0f, $10, $1a, $20, $22, $2f and $48
    +Fixed folders load/save, now the correct last folder used for Spectrum, Amstrad, Coleco, NES, GB, etc is remembered
    +In general configuration menu, you can change preview images, samples, quick snapshot and NV-Ram folders. Removed NES, Coleco and GB folder change (useless now) 
-Spectrum
    +Z80 snapshot
        -V1 - Fixed lenght of the compressed full memory block, I was ignoring the end mark
        -V1 - Fixed buffer overflow, some times the snapshot data has more info that it's needed
        -V2/V3 - Fixed uncompressed memory page inside of the data
        -V2/V3 - Some checks to avoid bad snapshots
        -V2/V3 - Now identify the correct Spectrum model
        -V2/V3 - The preview image, now uses the active screen in 128k models
-Gun.Smoke HW
    +Gun.Smoke: Small video updates
    +1943: Fixed background scroll
-Galaga HW
    +Galaga: added samples
    +Xevious: added driver with sound, small problems with scroll and samples
-WWF Superstars
    +Small video updates
-TMNT HW
    +Sunset Riders: Enhanced copyprotection
</pre><br>
<img src='http://img1.imagilive.com/1016/xevious.png'><br>
<b>26/09/16 - DSP Emulator 0.17b1. Win32 binary and source updated.</b><br><pre>
-General
    +K051960: Implemented IRQ's
    +Changed the way to show the main window caption, including the name of the tape, snapshot, disk, etc.
    +Added MCS48 CPU series: i8035, i8039 and N7751
    +Added i8243, port expander
    +Deleted languages files, they are now integrated
    +K051316: Added basic implementation
    +Added a check when directories are saved to avoid duplicating the folder separator
-Amstrad CPC
    +Added support for the snapshot V3 chuncks (including compressed memory)
-Black Tiger
    +Small video updates
-Popeye
    +Small video updates
-Gyruss
    +Added i8039 CPU and DAC, completed sound
    +Converted audio to stereo
-Juno First
    +Added i8039 CPU and DAC, completed sound
-Sega System 16A
    +Preliminary support of the digital audio with the N7751 CPU
-Hyper Sports
    +Added driver with sound
-Megazone
    +Added driver with sound
-Space Fire Bird
    +Added driver with sound
    +Small problems with the backgroud stars
-Ajax
    +Basic driver
</pre><br>
<img src='http://img1.imagilive.com/0916/hypersports.png'><img src='http://img1.imagilive.com/0916/megazone.png'><br>
<img src='http://img1.imagilive.com/0916/spacefirebird.png'><br>
<b>30/07/16 - DSP Emulator 0.17b1. Win32 binary and source updated.</b><br><pre>
-General
    +Added support for IPF files natively without external libraries. 
        -Many thanks to Jean Louis-Guerin (DrCoolZic) for the documententation 'http://info-coach.fr/atari/documents/_mydoc/IPF-Documentation.pdf'
        -Many thanks also to Bruno Kukulcan and Yoan Courtois (Megachur) for some Amstrad CPC IPF files for testing.
-Updated languaje files with new messages
-Track & Field
    +Added driver with sound
</pre><br>
<img src='http://img1.imagilive.com/0716/track_and_field.png'><br>
<b>07/07/16 - DSP Emulator 0.17 Final. All binary and source updated.</b><br><pre>
-All previous enhacements
-Z80: Implemented WZ/MEMPTR register, now passes all ZEXALL tests
-YM2203: Added functions to change the AY internal clock
-Spectrum
    +When a snapshot without ROM is loaded and previously changed to a different ROM than the original, it's reloaded the original ROM
    +Contended memory changes
-Amstrad CPC
    +Added LensLok protection
    +Enhanced video mode 2, more speed
</pre>