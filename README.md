# DSP Emulator status #
<b>29/09/24 - DSP Emulator 0.23WIP4. Updated Windows binary and source<br>
<pre>
-General
    +Controls Engine
        -Added analog control reset
    +Sound
        -Konami: added mute, added to all drivers
        -MSM5232: added sound chip, but sounds too fast (testing)
        -YM2203: fixed sound amplification
        -OKI6295: fixed sound amplification
        -YM2413: bypass delphi shl function error
    +Misc
        -Added Taito 68705 protection device, unified from all drivers
        -Split Galaxian stars from driver, converted into a device
        -General cleaning and still working on new DIP switches data conversion
        -Added new preview images
-NES
    +Fixed screen flicker in mapper 4 (Fixes Kings Quest V)
-Arkanoid
    +Removed MCU, used general Taito 68705
-Armed Formation HW
    +Added DIPs
    +Removed sprite masks
-China Gate
    +Removed scan lines conversion
    +Fixed FIRQs
-City Connection
    +Enhanced video parameters
-Double Dragon HW
    +Removed scan lines conversion
    +Removed video masks
    +Fixed FIQRs
    +Double Dragon: change ROMs to world version
-Food Fight
    +Some video optimizations, removed fake scroll
    +Fixed IRQ
-Galaxian
    +Removed stars generation
    +Better background color handling
-Legend of Kage
    +Removed MCU, used general Taito 68705
-Legendary Wings HW
    +Added sound CPU reset
    +Fire Ball: added driver with sound
-Mysterious Stones
    +Removed scan lines conversion
    +Fixed IRQs
-Pacman HW
    +Enhanced Z80 map
    +Removed video hack, converted to rotated screen
    +Ponpoko: added driver with sound
    +Wood Pecker: added driver with sound
    +Eyes: added driver with sound
    +Ali Baba and 40 Thieves: added driver with sound
    +Piranha added driver with sound
-Prehistoric Isle in 1930
    +Enhanced video parameters
    +Fixed IRQ
-Rally X
    +Optimized video functions
    +Fixed video buffer
    +Fixed screen rotation
-Renegade
    +Removed MCU, used general Taito 68705
    +Enhanced video parameters
    +Fixed screen size
    +Fixed IRQs
    +Fixed sound IRQs
-Return of Invaders
    +Removed MCU, used general Taito 68705
-Slap Fight
    +Removed MCU, used general Taito 68705
    +Removed chars and tiles masks
-Senjyo HW
    +Baluba: Added DIP switches
-Super Dodge Ball
    +Enhanced video scroll
-Tecmo 16
    +Final Star Force: Added driver with sound
-Time Pilot
    +Changed screen render to line by line, fixed sprite render
    +Fixed screen orientation
-Tutankhan
    +Added background stars
-Wyvern F-0
    +Added driver with sound

          Before                     Now
<img src="https://i.ibb.co/Xp8cTyq/Time-Pilot-before.png"> <img src="https://i.ibb.co/kXwJ1h2/Time-Pilot-now.png">

New Games
<img src="https://i.ibb.co/8YpxJRW/Ali-Baba-and-40-Thieves.png"> <img src="https://i.ibb.co/0Zgscth/Eyes.png">
<img src="https://i.ibb.co/7b25vVP/Final-Star-Force.png"> <img src="https://i.ibb.co/dcKTjp4/Piranha.png">
<img src="https://i.ibb.co/zNZ8hBq/Ponpoko.png"> <img src="https://i.ibb.co/Q89cn8X/Woodpecker.png">
<img src="https://i.ibb.co/308LXR6/Wyvern-F-0.png"> <img src="https://i.ibb.co/1rpsr0Y/Fire-Ball.png">
</pre><br>
<b>01/09/24 - DSP Emulator 0.23WIP3. Updated Windows binary and source<br>
<pre>
-General
    +Config
        -Split ROMs and samples DAT info in two export buttons
    +Misc
        -Deco 104/146: converted to classes
        -Fixed 'Gardia' ROMs export (Thanks to Neville)
        -Fixed 'Kick'n Run' ROMs export size (Thanks to Neville)
    +DIPs switches engine
        -Rewrited engine
        -New data structure, easy to maintain and easy to add
        -Start migrate all DIPs to new structure
    +Graphics engine
        -Added mask to all functions, no need to mask the graphic number before call any function, removed graphic number mask from all drivers
        -DECO BAC06
            +Removed chars/tiles masks
            +Added general color mask
            +Added read/write 8bits functions
    +Sound engine
        -YM2413: added new sound chip
        -SN76496: fixed snapshot
        -VLM5030: changed to new tables values, rewrited some code
    +CPUs
        -M6809
            +Added opcode $28
        -HD6309
            +Added opcodes $1,$28,$29 and $1X2e
        -MCS51
            +Added forced input function
        -UPD781X
            +UPD7801: Fixed CALT opcode
            +Added opcode $a9 (makes SCV - 'Elevator Fight' playable)
    +Timer engine
        -One shot timers: added a new kind of timers, when called it's executed once, and then stops

-Sega Master System
    +Fixed sound chip order creation (Thanks to Neville)
    +Removed big borders video in PAL version, NTSC and PAL have the same video size
    +Added YM2413 sound
-Super Cassette Vision
    +Fixed vsync length (Fixes 'Mappy' sound speed)
-Boogie Wings
    +Still WIP driver, but enhanced the driver, still wrong colors and screen draw
    +Fixed read/write maps
    +Added screen parameters
    +Added screen tiles and tiles bank calls
    +Fixed ROMs loading
-Deco 8 HW
    +Super Real Darwin
        -Fixed screen parameters and rotation
        -Fixed sprites
    +Last Mission: added driver with sound
    +Shackled: added driver with sound
    +Gondomania: added driver with sound
    +Garyo Retsuden: added driver with sound
    +Captain Silver: added driver with sound
    +Cobra Command: added driver with sound
    +The Real Ghostbusters: added driver with sound
    +Psycho-Nics Oscar: added driver with sound
-Hyper Sports HW
    +Fixed screen rotation
    +Hyper Sports: Fixed speech sounds
    +Road Fighter: added driver with sound
-Lasso HW
    +Lasso: added driver with sound
    +Chameleon: added driver with sound
-Legendary Wings HW
    +Avengers
        -Updated ROMs to version D
        -Added DIPs switches
-Pang HW
    +Added YM2413 sound
-Track and Field
    +Fixed speech sounds
-Tehkan World Cup
    +Added missing DIPs
-Toki
    +Added missing DIPs

<img src="https://imgbb.host/images/NEG31.png"> <img src="https://imgbb.host/images/NEY07.png">
<img src="https://imgbb.host/images/NE7JM.png"> <img src="https://imgbb.host/images/NEpX4.png">
<img src="https://imgbb.host/images/NEgTb.png"> <img src="https://imgbb.host/images/NEapr.png">
<img src="https://imgbb.host/images/NYXT7.png"> <img src="https://imgbb.host/images/NYFXl.png">
<img src="https://imgbb.host/images/NYdFB.png"> <img src="https://imgbb.host/images/NYEB4.png">
<img src="https://imgbb.host/images/NYxFc.png"> <img src="https://imgbb.host/images/NYOVL.png">
</pre><br><br>
<b>12/08/24 - DSP Emulator 0.23WIP2. Updated Windows binary and source<br>
<pre>
-General
    +Misc
        -Updated SDL2 library for windows 2.30.6
        -ROMs export: Fixed '88 Gamed' ROM info (thanks to okurka)
        -Updated Preview images
    +Video
        -Rewrited full screen mode
            +Screen now it's scaled
            +Hide mouse, except if needed (Spectrum mouse, Operation Wolf and Zero Point)
            +Fixed mouse position click
    +Sound engine
        -Added close functions to clean variables
        -Added some functions to ensure a sound chip have a CPU associated before it's created
    +Controls Engine
        -Joystick
            +Removed calibrate functions, just press button to calibrate
            +Rewrited all functions, now responds faster
    +Timer Engine
        -Add timer lapse, before call timer function
    +CPU
        -M6502
            +Fixed 'brk' opcode (fixes Oric's 'SkoolDaze' and many others)
        -M680X
            +Added opcodes $2c, $2f and $85
            +Rewrited get/put byte functions
            +Make RAM and ROM internal
        -MB88XX
            +Rewrited internal flags functions
        -Z80
            +Added IRQ mode 2 external vector calls
            +Daisy chain: clean all functions
            +Z80 CTC: Clean daisy chain functions
            +Z80 PIO: Converted to classes
    +Devices
        -VIA6522: Implemented VIA timers with the timer engine
        -TAP/TZX Engine
            +Fixed blocks $10,$11 and $14, misses one pulse
            +Remove last block pause, and change pause functions
            +Added T64 files
-Spectrum
    +Removed minimum border draw when fast speed, now draws full border lines (thanks to Neville)
-Amstrad CPC
    +Fixed lenslock protection, added 'Moon Cresta' protection
    +Fixed tape/wav opening error
-Casio PV1000
    +Fixed IRQ generation
    +Fixed screen size and border
-Commodore 64
    +Enhanced PRG loading
    +Changed T64 to tape system, still not working
-Oric HW
    +Changed screen draw to line by line
    +Fixed tape/wav opening error
    +Changed sound chip to AY8912
-Aliens
    +Fixed CPU clock
-Baraduke HW
    +Changed to new M680X CPU engine
-BombJack HW
    +Merged with Calorie Kun
    +Fixed background layer
    +Changed memory map to a generalized one
    +Added rotation screen
    +Changed screen parameters
    +Enhanced NMI
-Breakthru HW
    +Changed memory map to a generalized one
    +Fixed DIPs
-Bubblebobble
    +Changed to new M680X CPU engine
    +Added IRQ mode 2 external vector function
    +Remove manual GFX invert
-Centipede
    +Enhanced IRQ generation
-Double Dragon HW
    +Double Dragon: Changed to new M680X CPU engine
-Firetrap
    +Added MSM5205 reset
-Gaplus
    +Fixed corrupted sprites
-KiKi KaiKai HW
    +KiKi KaiKai: Added driver with sound
    +Kick and Run: Added driver with sound
-Knuckle Joe
    +Changed to new M680X CPU engine
-Irem M62
    +Changed to new M680X CPU engine
+Pacland
    +Changed to new M680X CPU engine
+Pooyan
    +Enhance palette conversion
+Shaolins Road
    +Fixed Sprites
+Skykid
    +Changed to new M680X CPU engine
+Senjyo HW
    +Fixed slow inputs
    +Changed to new Z80 PIO engine
+Super DodgeBall
    +Changed to new M680X CPU engine
+Sega System 1/2
    +Changed to new Z80 PIO engine
+System Namco86
    +Changed to new M680X CPU engine
+Williams HW
    +Changed to new M680X CPU engine
    
    
        Before                                               0.23WIP2
Full Screen
<img src="https://i.ibb.co/kxByHxd/gng-before.jpg"> <img src="https://i.ibb.co/rxkbkpB/gng-023wip2.jpg">

Casio PV1000 <img src="https://i.ibb.co/zZtZk1W/digdug-before.jpg">                 <img src="https://i.ibb.co/WyMSKWp/digdug-after.jpg">
     
     
        New Games
<img src="https://i.ibb.co/vBPfM25/Ki-Ki-Kai-Kai.jpg"> <img src="https://i.ibb.co/vYVcWMB/Kickand-Run.jpg">
</pre><br>
<b>25/03/24 - DSP Emulator 0.23WIP1. Updated Windows binary and source.<br>
<pre>
-General
    +Misc
        -Fixed preview screen generation
        -Fixed CRC show when a ROM file is not found
    +Snapshot
        -Simplified snapshot system functions 
    +Video
        -AVG/DVG: Added new vector draw system. WIP.
        -GFX: Added invert option when convert GFX
    +Sound
        -MSM5205
            +Rewrited all sound playing functions
            +Make all variables, adpcm ROMS, and timing internal, removed all variables from drivers
            +Make standard adpcm play functions by default, removed all repeated functions from drivers
    +CPU
        -M68000
            +Fixed some timings
            +Fixed 'divs' opcode (Now 'Space Harrier' works fine!)
            +Fixed privilege exception in 'stop', 'move to sr' and 'move from sr' opcodes
        -MCS51
            +Added 8X52 and CMOS CPU types
            +Enhanced internal RAM read/write
            +Fixed IRQ generation
            +Fixed parity calculation
            +Fixed push/pop
            +Fixed timer0 and timer1
            +Fixed many opcodes
            +Added opcodes $84
        -Z80
            +Added some more WZ
    +Misc
        -Sega deCript: Added another SEGA ROMs decript
-Spectrum
    +Added quick save/load (F7-F8/F9-F10)
    +Spectrum 128/+3 some code cleaning
-Amstrad CPC
    +Added quick save/load (F7-F8/F9-F10)
-Commodore 64
    +Some memory functions clean
    +Some tape control changes
    +Added quick save/load (F7-F8/F9-F10)
-Sega Master System
    +Fixed pause (Fixes 'Bart Simpsons and the Space Mutants')
    +Fixed BIOS loading
-88 Games
    +Added driver, screen draw problems... Maybe CPU bugs?
-Ajax
    +Fixed CPU clock
-Aliens
    +CPU map cleaning
-Appoooh HW
    +Appohhh: Added driver with sound
    +Robo Wres 2001: Added driver with sound
-Asteroids HW
    +Added new vector system
    +Lunar lander: added AVG-DVG prom
-Bank Panic HW
    +Bank Panic: added driver with sound
    +Combat Hawk: added driver with sound
-Bionic Commando
    +Fixed background wrong colors
-Blue Print HW
    +Blue Print: added driver with sound
    +Saturn: added driver with sound
    +Grasspin: added driver with sound
-Calorie Kun vs Moguranian
    +Added driver with sound
-Dooyong HW
    +Blue Hawk: added driver with sound
    +The Last Day: added driver with sound
    +Gulf Storm: added driver with sound
    +Pollux: added driver with sound
    +Flying Tiger: added driver with sound
-Galaxian HW
    +Fixed background
    +Fixed NMI clear
    +Fixed sprite calculation procedures
    +Fixed bullet draw
    +Fixed scramble protection
    +Ant Eater: added driver with sound
    +Armored Car: added driver with sound
    +The End: added driver with sound
    +Battle of Atlantis: added driver with sound
    +Calipso: added driver with sound
    +Cavelon: added driver with sound
-Gaplus
    +Fixed sprites
-Pirate Hihemaru
    +Added screen priorities
-Karnov HW
    +Added IRQ assert/clean
-Legendary Wings HW
    +Legendary Wings: Update ROMs names
    +Trojan: Fixed palette
    +Avengers: added driver with sound, some sync problems...
-Popeye HW
    +Fixed DMA
    +Popeye: Fixed screen draw
    +Sky Skipper: adder driver with sound
-The Simpsons
    +Fixed CPU clock
-Snowbros HW
    +Come Back Toto: added driver with sound
    +Hyper Pacman: added driver with sound
-Steel Force HW
    +Mortal Race: added driver with sound
-Sega System 1/2 HW
    +Removed Z80 special timings, added adjust cycle function, remove all CPU clock hacks
    +Fixed palette
    +Wonder Boy: removed decript procedures, now using new SEGA deCript
    +Gardia: added driver with sound
-ThunderX
	+Better collisions functions
	+Some CPU map cleaning
	+Fixed CPU clock
-Unico HW
    +BurglarX: added driver with sound
    +ZeroPoint: added driver with sound

New Games
<img src="https://i.ibb.co/Gd0fzzt/88-Games.png"> <img src="https://i.ibb.co/fCC9Ky4/Ant-Eater.png">
<img src="https://i.ibb.co/cbXntKx/Appoooh.png"> <img src="https://i.ibb.co/BC3GsSW/Armored-Car.png">
<img src="https://i.ibb.co/8Nd5wLZ/Avengers.png"> <img src="https://i.ibb.co/c2F2PDM/Bank-Panic.png">
<img src="https://i.ibb.co/4V7TQv1/Battle-of-Atlantis.png"> <img src="https://i.ibb.co/7gjqpc1/Blue-Hawk.png">
<img src="https://i.ibb.co/mTCjxxm/Blue-Print.png"> <img src="https://i.ibb.co/YDmRccd/BurglarX.png">
<img src="https://i.ibb.co/1b2GPCz/Calipso.png"> <img src="https://i.ibb.co/Fq6wsf3/Calorie-Kun-vs-Moguranian.png">
<img src="https://i.ibb.co/h8rpQbf/Cavelon.png"> <img src="https://i.ibb.co/1nx7pZ3/Combat-Hawk.png">
<img src="https://i.ibb.co/z6fCfKs/Come-Back-Toto.png"> <img src="https://i.ibb.co/j56Wwry/Flying-Tiger.png">
<img src="https://i.ibb.co/0VL7KWV/Gardia.png"> <img src="https://i.ibb.co/qg9q1Qf/Grasspin.png">
<img src="https://i.ibb.co/M6RDCg1/Gulf-Storm.png"> <img src="https://i.ibb.co/Z8gjwws/Hyper-Pacman.png">
<img src="https://i.ibb.co/CQ00JH3/Mortal-Race.png"> <img src="https://i.ibb.co/SccXJ38/Pollux.png">
<img src="https://i.ibb.co/N1VK9cx/Robo-Wres-2001.png"> <img src="https://i.ibb.co/MDYzgVP/Saturn.png">
<img src="https://i.ibb.co/WWgfTdr/Sky-Skipper.png"> <img src="https://i.ibb.co/1d8j9SQ/The-End.png">
<img src="https://i.ibb.co/bv9ThLB/The-Last-Day.png"> <img src="https://i.ibb.co/w6Q3pN5/Zero-Point.png">
</pre><br>
<b>15/11/23 - DSP Emulator 0.22Final. Updated Windows binary and source. Please read 'Whats New 0.22' file for full details.<br>
<pre>
-General
    +Updated preview images
    +Uploaded samples for Bosconian and Gaplus
    +Devices
        -Eeprom: 
            +Mix two source files
            +Converted to classes
            +Fixed 16bits writes
            +Added functions to load/save content
            +Added E93CXX devices
    +Sound
        -OKI6295: fixed playing voices
-Spectrum
    +Changed 'fast load' button
        -Disabled if no tape is loaded
        -Set 'on' by default when 'TAP' file is loaded
        -Set 'off' by default when 'TXZ' and 'PZX' files are loaded
-Sega SG-1000
    +Safari Hunting: fixed cartridge mirroring, now works
-Diverboy
    +Added driver with sound
-Mug Smashers
    +Added driver with sound
-Steel Force HW
    +Steel Force: added driver with sound
    +Twin Brats: added driver with sound

<img src="https://i.ibb.co/3k72TKq/diverboy.png"> <img src="https://i.ibb.co/MkRDhV9/mugsmash.png">
<img src="https://i.ibb.co/5BnT7Yq/stlforce.png"> <img src="https://i.ibb.co/Gd5mZSQ/twinbrat.png">
</pre><br>
<b>02/11/23 - DSP Emulator 0.22WIP6. Updated Windows binary and source.<br>
<pre>
-General
    +CPU
        -lr35902
            +Added snapshots
            +Change ime flag to 'disabled' on reset (Fixes Hook)
        -MCS48
            +Added external IO, and fixed internal IO
            +Fixed conditional jumps
            +Fixed ROM reads with and without PC increment
            +Fixed CPU clock init
            +Fixed IRQs
            +Added opcodes $25, $45, $70, $71 and $90
            +Fixed opcodes $80, $81, $a3, $b3 and $e3
        -na2a03
            +Added snapshots
            +Rewrited sound part
            +Fixed audio buffer
            +Fixed dpcm sound... But clicks a lot
-Gameboy/Gameboy Color
    +Added snapshots
    +Modernized mappers, better mapper reset
    +Changed a bit screen timings
    +Added 'Wisdom Tree' mapper
    +Added partial mapper MBC6
-NES
    +Added snapshots
    +Modernized mappers
    +Added black&white palette
    +Changed a bit screen timings
-Pacman HW
    +Birdiy: added driver with sound
-Irem M63 HW
    +Wily Tower: added driver with sound
    +Fighting Basketball: added driver with sound

<img src="https://i.ibb.co/F0v4vkF/birdiy.png"> <img src="https://i.ibb.co/SdNWnDY/wilytowr.png">
<img src="https://i.ibb.co/yPQFCSn/fghtbskt.png"> <img src="https://i.ibb.co/YbQ9SYB/noas-ark.png" alt="NES black&white pal">
<img src="https://i.ibb.co/XYtx8P5/hook.png" alt="GB Hook">
</pre><br>

<b>22/08/23 - DSP Emulator 0.22WIP5. Updated Windows binary and source.<br>
<pre>
-General
    +New main Snapshot system
        -New unified ROM/game/snapshot/tape load/save system
        -New unified snapshot data extractor system
    +Video
        -Sega VDP (SMS/GG): Added snapshots
    +CPU
        -UPD7810: Added snapshots
    +Sound
        -UPD1771: Added snapshots 
    +Misc
        +I2Cmem: Added snapshots
-Amstrad CPC
    +Added the new ROM/tape/snapshot load system
-Commodore 64
    +Added the new ROM/tape/snapshot load system
-Oric HW
    +Added the new ROM/tape/snapshot load system
-Chip 8
    +Added the new ROM load game system
    +Added snapshots
-Coleco
    +Moved to new snapshot system
    +Added eeprom to snapshot (if present)
-GameBoy/GameBoy Color
    +Added the new ROM load game system
    +Added snapshots (still not working)
    +Fixed ROM loading
-NES
    +Added the new ROM load game system
    +Added snapshots (still not working)
-Sega SG-1000
    +Added the new ROM load game system
    +Added snapshots
    +Added a new game file format '.MV'
-Sega GameGear
    +Added the new ROM load game system
    +Fixed CPU and sound creation order (emulator can crash)
    +Added snapshots
-Sega Master System
    +Added the new ROM load game system
    +Added snapshots
    +Fixed BIOS+Game loading, now supports all extra BIOS+Game for all systems
    +Fixed international detection, now detects the system via $3F port
    +Fixed ROM loading
    +Fixed model change NTSC/PAL
    +Fixed CPU and sound creation order (emulator can crash)
-SuperCassete Vision
    +Added the new ROM load game system
    +Added snapshots
    +Fixed ROM loading, all available games now works
-Casio PV-1000
    +Added new console, supports sound, controls
    +Added snapshots
    +All available games working
-Casio PV-2000
    +Added new console, supports sound, controls, keyboard...
    +Added snapshots
    +All available games working

<img src="https://i.ibb.co/K5630F6/sonic-bios.png"> <img src="https://i.ibb.co/jgSjLx7/pv1k-pooyan.png">
<img src="https://i.ibb.co/khPw33g/pv1k-digdug.png"> <img src="https://i.ibb.co/tZjHjhz/pv2k-galaga.png">
<img src="https://i.ibb.co/WzLYzmF/pv2k-super.png">
</pre><br>

<b>09/08/23 - DSP Emulator 0.22WIP4.1. Fast fix... Updated Windows binary, OSX and source.<br>
<pre>
-General
    +Updated SDL2 library for windows
    +Updated the documentation, 'DSP small guide' and 'DSP how to compile'
    +Lazarus
        -Fixed compile i2cmem module
    +Fixed press 'ESC' for close pop-up windows
    +Fixed some spellings
    +Some cosmetic changes
    +ROMs export
    	-Fixed 'future spy' ROM info (thanks to Neville)
    	-Added 'gaplus' sample info, was missing
    +Fixed controls, when pressing left+right or up+down at the same time
-Spectrum
    +Fixed screen refresh when changed screen resolution
-Donkey Kong HW
    +Fixed screen flip
</pre><br>

<b>08/08/23 - Updated docs.<br>
<pre>
-Updated 'How to compile'
-Added a new section 'DSP small guide', a guide for using the emulator
</pre><br>
<b>29/07/23 - DSP Emulator 0.22WIP4. Updated Windows binary and source.<br>
<pre>
-General
    +Added a new section 'How to compile DSP Emulator'
    +Started to implement parent drivers (ROMs loading and ROMs export), for example Xevious and Super Xevious, they share ROMs, but they are not the same arcade.
    +Namco IO 56XX-58XX-59XX
        -Changed to classes
        -Added IO 59XX
        -Implemented timers to internal
-Galaga HW
    +Added DIPs to all drivers
    +Added all remain controls to all drivers
    +DigDug: Simplified background render 
    +Super Xevious: Added driver with sound
-Galaxian HW
    +Added DIPs to all drivers
    +Added all remain controls to all drivers
    +Amidar
        -Updated ROMs
        -Added background color
-Gaplus
    +Added driver with sound
-Gun.Smoke HW
    +Added sound CPU reset line
-Mappy HW
    +Added DIPs to all drivers
    +Added all remain controls to all drivers
    +Changed to new Namco 5X IO driver
    +Grobda: added driver with sound
    +Pac & Pal: Added driver with sound
-Pacland
    +Added DIPs switches
    +Fixed a stupid bug with palette change
    +Change screen parameters
</pre><br>
<img src="https://i.ibb.co/MMrK2QL/gaplus.png"> <img src="https://i.ibb.co/yyhYKkF/Grobda.png"><br>
<img src="https://i.ibb.co/dWBHZGV/pacnpal.png"> <img src="https://i.ibb.co/4pCWsMm/sxevious.png"><br><br>
<b>08/07/23 - DSP Emulator 0.22WIP3. Updated Windows binary and source.<br>
<pre>
-General
    +Updated Preview Images
    +CPU
        -Added a new counter to count all timings of the CPU, used in Asteroids, Circus Charlie, Gyruss, Hypersports, and many others...
        -LR35902: fixed HALT opcode, fixes many Gameboy Color Konami games
    +Sound
        -Konami Sound: video line not needed any more
        -Samples: added volume
    +Video
        -Changed rol90 name to rot270
        -Added rot180 to rotate screen 180 degrees
        -Fixed main screen flip x and flip y, now can be used both
    +Disk: added DSK format for Oric disks
    +GFX: fixed gfx rotate when graphics are not square
-Oric HW
    +Added preliminary disc support, not working
-Centipede HW
    +Centipede
        -Fixed dip
        -Fixed video
        -Fixed controls
        -Fixed colors, now using indirect palette
    +Millipede: added driver with sound
-Circus Charlie
    +Fixed sprites
-Flower
    +Enhanced IRQs
-Legendary Wings HW
    +Section Z: fixed audio
-Mega Sys 1 HW
    +64th Street: fixed sprites
-Missile Command
    +Missile Command: added driver with sound
    +Super Missile Attack: added driver with sound
-Taito SJ HW
    +Added DIPs
    +Updated to use gfx buffers
    +Fixed controls, added buttons
    +Optimized maps
    +Fixed sound NMI
    +Fixed DAC
    +Elevator Action: updated ROMs
-Time Pilot
    +Added DIPs
    +Added video enable
-Wardner
    +Fixed DIPs
-Zaxxon HW
    +Fixed sound
    +Fixed DIPs
    +Fixed video
    +Added samples volume
    +Super Zaxxon: added driver with sound
    +Future Spy: added driver with sound
</pre><br>
<img src="https://i.ibb.co/QXPBHVk/Millipede.png"> <img src="https://i.ibb.co/2cPdYjJ/fspy.png"><br>
<img src="https://i.ibb.co/sj1W1T4/missile.png"> <img src="https://i.ibb.co/T8cnjdk/smissile.png"><br>
<img src="https://i.ibb.co/gjQKZgt/szaxxon.png"><br><br>
<b>22/05/23 - DSP Emulator 0.22WIP2. Updated Windows binary and source.<br>
<pre>
-General
    +CPU
        -M6502
            +Fixed timings before internal timer call
            +Added some opcodes for 2xNOP and 3xNOP
        -Z80
            +Fixed timings before internal timer call
            +Some updates to internal procedures
    +Tape System
        -Added procedures to call before tape play and after play
        -Fixed WAV format tapes loading
        -Added Oric TAP file format support
        -Fixed main speed changes when a tape is playing
    +Devices
        -VIA6522: Added device
-Amstrad CPC
    +Enabled Z80 timings (fixes Saboteur II and many others)
    +Rewrited video to update screen pixel by pixel
    +Fixed tape loading with new Z80 timings
-Coleco
    +Black Onix: Added 24C08 eeprom
    +Boxxled: Added 24C256 eeprom
-Commodore 64
    +Swapped joystick 0 and joystick 1
    +Added F1 to start/stop tape loading
-NES
    +Fixed mapper 9
    +Added partial mapper 10 (thanks to Neville)
-Oric HW
    +Added support for tape loading, AY-8910 sound and keyboard
        -Oric 1: added driver with sound
        -Oric Atmos: added driver with sound
-Sega System 1/2 HW
    +Changed Z80 timings, fixes Pitfall II intro

     Before                                     After
<img src="https://i.ibb.co/fY4p5Vy/zaptballs-before.png"> <img src="https://i.ibb.co/PgY8J2h/zaptballs.png">
<img src="https://i.ibb.co/nbwR7g8/zaptballs2-before.png"> <img src="https://i.ibb.co/7n3xkzP/zaptballs2.png">
                                   <img src="https://i.ibb.co/R6j4ztG/Pitfall2.png">

     New Systems
<img src="https://i.ibb.co/C1qr3dN/oric1.png"> <img src="https://i.ibb.co/Gt8DT3r/orica.png">
<img src="https://i.ibb.co/QHKwX27/oric-atmos.png">
</pre><br>

<b>25/04/23 - DSP Emulator 0.22WIP1. Updated Windows binary and source.<br>
<pre>
-General
    +Updated wiki
    +Updated preview images (thanks to Nevile)
    +Update SDL2 library to 2.26.5
    +CPU
        -NEC V20/V30/V33
            +Implemented sound timers
            +Added NMI
            +Added many EA types
            +Fixed PUSH/POP CPU flags
            +Added opcodes $0f18, $0f19, $0f1a, $0f1b, $0f1c, $0f1d, $31, $34, $68, $6a, $6b, $82, $8308, $8320, $8330, $8d, $91, $92, $93, $94, $95, $97, $c008, $c020, $c028, $c120, $c128, $c8, $c9, $d110, $d200, $d220, $d228, $d3, $e3, $e4, $ec, $ee, $ef, $f2a4, $f2a5, $f2af, $f618, $f620, $f630, $f720, $f728, $f730 and $f738
        -Z80
            +Added (again) functions to change CPU timmings
            +Fixed some timmings and timming calculation
    +Sound
        -Seibu sound
            +Rewrited and converted to class
            +Added internal Z80, ADPCM, sound chip and controls
            +Changed CPU mappers to internal
            +Removed fake adpcm, using standard MSM5205
        -MSM5205
            +Converted to class
    +Devices
        -Added i2c eeproms
    +File engine
        -Changed CRC variable to unsigned 32bits
-Amstrad CPC
    +Fixed keyboard matrix reads (Fixes 'Night Shade')
    +Added specific Z80 timmings, but breaks tape loading, so they are disabled
-Bloodbros HW
    +Added new seibu sound system
-Cabal
    +Added new seibu sound system
-Raiden
    +Added new driver, but have some CPU bugs, sounds fails and controls are not working
-Shadow Warriors HW
    +Shadow Warriors: added driver with sound
    +Wild Fang/Tecmo knight: added driver with sound
-Toki
    +Added new seibu sound system
-Twins HW
    +Twins: added driver with sound
    +Twins (Electronic Devices): added driver with sound
    +Hot Block - Tetrix II: added driver with sound
</pre><br>
<img src="https://i.ibb.co/kybsYYx/hotblock.png"> <img src="https://i.ibb.co/f0BJtWB/Raiden.png"><br>
<img src="https://i.ibb.co/TbKr4n6/shadoww.png"> <img src="https://i.ibb.co/wgxVq4S/Twins.png"><br>
<img src="https://i.ibb.co/2Y4NJ9z/Twinsed1.png"> <img src="https://i.ibb.co/Z8tYVmD/wildfang.png"><br><br>
<b>12/03/23 - DSP Emulator 0.21Final. Updated Windows binary, linux 64 binary and source.<br>
<pre>
-General
    +Added some SDL2 functions to autoselect the best video format when switch to full screen
    +Fixed some export ROM data (thanks to Neville)
    +Fixed a stupid bug creating pixel buffer
    +CPU
        -M68000
            +Fixed opcodes divu and sbcd (thanks to Neville)
-SG-1000
    +Added HOLD button
-Sega Master System
    +Fixed 'Pause' button, now works
-Mega System 1 HW
    +Fixed RAM byte write (fixes '64th Street - A detective story' protection)
</pre><br>
Please read 'Whats New 0.21' file for full details<br><br>
<b>12/02/23 - DSP Emulator 0.21WIP6. Updated Windows binary and source.<br>
<pre>
-General 
    +Updated SDL library to 2.26.3
    +Updated preview images
    +Remove arcade keys when not using arcade drivers
    +CPU
        -M68000
            +Split read/write byte flags
            +Enhanced timings
            +Fixed opcodes addi.l, addq.l, sbcd.rr, abcd.rr, roxr.w, roxl.w, rol.w, asr.b, lsr.b, roxr.b, ror.b, asr.w, lsr.w, ror.w, asr.l, lsr.l, roxr.l, ror.l asl.b, lsl.b, roxl.b, rol.b, asl.w, lsl.w, asl.l, lsl.l, roxl.l, rol.l
            +Added movem.w $38 efective address
        -MCS51
            +Added opcodes $38..$3f, $62, $63, $64 and $b1
            +Fixed external get/put byte with no function
        -fd1089: Updated decode functions
    +Sound
        -SEGA PCM: Added stereo
        -SN76496: Added stereo
        -VLM5030: Added stereo
        -YM2203: Added stereo
    +Updated key redefine names
        -'COIN' --> 'COIN/SELECT'
        -'START' --> 'P1/START' or 'P2/START'
-Gauntlet
    +Gauntlet: Renamed ROM zip to 'gauntlet'
    +Gauntlet II: Updated ROMs to v2
-Hang-On HW
    +Hang-On: added driver with sound
    +Enduro racer: added driver with sound
    +Space Harrier: added driver with sound, some sprite problems (M68000 bug?)
-Mega System 1 HW
    +Fixed all video issues
        -Fixed graphics layers
        -Fixed scroll
        -Fixed sprites
    +Fixed graphics decode
    +Rod Land
        -Updated ROMs
        -Added graphics decrypt
    +64th Street - A detective story: added driver with sound
-Outrun
    +Fixed tile buffer size and activation
    +Fixed missing sprites
    +Fixed tiles transparency
    +Fixed tiles priority
-Sega System 16A HW
    +Fixed graphics decode
    +Fixed sprite ROMs and decode to 16bits
    +Fixed tiles transparency
    +Fixed tiles priority (very obious in WB3 end zone)
    +Alien Syndrome: Updated fd1089 ROM decode key
    +Wonder Boy III: Updated fd1089 ROM decode key
-Sega System 16B HW
    +Fixed disabled screen
    +Fixed tiles transparency
    +Fixed tiles priority
    +Fixed tile buffer activation
</pre><br>
<img src="https://i.ibb.co/1TJHpV3/64street.png"> <img src="https://i.ibb.co/ky5TD1S/enduror.png"><br>
<img src="https://i.ibb.co/NZ45xpK/hangon.png"> <img src="https://i.ibb.co/8jFd81t/sharrier.png"><br><br>
<b>10/01/23 - DSP Emulator 0.21WIP5.1. Updated Windows binary and source.<br>
<pre>
-General
    +Change between drivers is faster now
    +Fixed joystick SDL 2 support! Changed hint function before SDL init, and works with all SDL 2 versions (removed SDL 2.0.16)
    +Added start and coin/select in player redefinition page
    +Start and coin/select keys can be mapped to joystick buttons
-Sega Master System
    +Remapped 'Pause' button to coin/select button
-Sega Game Gear
    +Removed 'Pause' button (doesn't have it)
</pre><br><br>
<b>08/01/23 - DSP Emulator 0.21WIP5. Updated Windows binary and source.<br>
<pre>
-General
    +Find a bug on new releases of SDL 2 library, joystick stop working when main window loses focus. Changed to SDL 2.0.16, works fine with this version
        -Added SDL 2.0.16 for download
    +Enhanced joystick support
        -New redefine buttons system, select and press the button to use it
        -Rewrited joystick internal functions
    +Windows: Removed mouse cursor, slows down everything when enabled
    +Lazarus: Added 'follow me' window style. The main emulation window follows select window when it moves.
-CPS1 HW
    +Added 3 extra players buttons, 'Street Fighter II' now works with all buttons
    +Better row scroll, still not working
-Super Duck
    +Added driver with sound
-Tiger Road
    +Added sprite buffer
</pre><br>
<img src="https://i.ibb.co/3WVdjYP/supduck.png"><br><br>
<b>06/12/22 - DSP Emulator 0.21WIP4.2. Another fix! Updated Windows binary and source update.<br>
<pre>
-General
    +Fixed - Emulator losses focus and keyboard stop working (Thanks to Neville)
    +Updated SDL library to 2.26.1
-Coleco
    +Fire button 1 and 2 switched
    +Fixed error message loading a cartridge
</pre><br><br>
<b>05/11/22 - DSP Emulator 0.21WIP4.1. Quick fix! Updated Windows binary and source update.<br>
<pre>
-Lazarus
    +Fixed image preview error
    +Fixed linux sort games
    +Added check for SDL2 Mixer present, needed for linux and MacOS
-General
    +Fixed - Emulator stops with no reason (Thanks to Neville)
    +Better console game files loading, better error handling
    +Better tape files loading, better error handling
    +Fixed remembering last open dir for all systems
    +Better fullscreen mode (Press F6)
</pre><br><br>
<b>25/10/22 - DSP Emulator 0.21WIP4. Updated Windows binary and source update.<br>
<pre>
-General
    +Update preview images, added images for new drivers
    +Konami K051316
        -Begin implementation, still WIP
    +CPU
        -HD6309: Fixed opcodes $2c, $2d and $2f
        -Konami CPU
              +Fixed opcodes $66, $67, $6e, $6f, $76, $77, $7e, $7f, $b4 and $b5
              +Added opcodes $74, $bc, $be, $c6, $cc, $cd and $ce (Fixes 'The Simpsons', it's playable to the end)
        -M6809: Fixed opcodes $2c, $2d, $2e and $2f
    +Konami 053246
        -Fixed shadows
    +Sound
        -AY8910
              +Added gain per channel
              +Fixed AY8912 PORTB channel
-Ajax
    +Added K051316 video chip
-Ambush
    +Added driver with sound
-Kyugo HW
    +S.R.D. Mission: Added driver with sound
    +AirWolf: Added driver with sound
-Mag Max
    +Added driver with sound
-Nemesis HW
    +Rewrited screen flip, fixes TwinBee
-The Simpsons
    +Fixed video settings
    +Added sprites dma interrupt enable/disable
-Thunder Cross HW
    +Fixed sprites priority
</pre><br>
<img src="https://i.ibb.co/TgzTxTV/Airwolf.png"> <img src="https://i.ibb.co/PFmVY4f/Ambush.png"><br>
<img src="https://i.ibb.co/TwdZJMY/magmax.png"> <img src="https://i.ibb.co/yX12fWz/srdmission.png"><br>
<img src="https://i.ibb.co/pdpvh16/twinbee.png"> <img src="https://i.ibb.co/S332FHp/vendetta.png"><br><br>