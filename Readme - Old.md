# DSP Emulator old news #
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
    +Rewrite screen flip, fixes TwinBee
-The Simpsons
    +Fixed video settings
    +Added sprites dma interrupt enable/disable
-Thunder Cross HW
    +Fixed sprites priority
</pre><br>
<img src="https://i.ibb.co/TgzTxTV/Airwolf.png"> <img src="https://i.ibb.co/PFmVY4f/Ambush.png"><br>
<img src="https://i.ibb.co/TwdZJMY/magmax.png"> <img src="https://i.ibb.co/yX12fWz/srdmission.png"><br>
<img src="https://i.ibb.co/pdpvh16/twinbee.png"> <img src="https://i.ibb.co/S332FHp/vendetta.png"><br><br>
<b>09/10/22 - DSP Emulator 0.21WIP3. Updated Windows 32 and source update.<br>
<pre>
-General
    +Update preview images, added images for new drivers
    +Update SDL library to 2.24.1
    +Added sort options in game list menu. You can sort computers, Game & Watch, consoles and arcade (and arcade subtypes sport, run & gun, shot, maze, fight and drive)
    +CPU
        -Konami CPU: Fixed opcodes $6f, $76 and $7e. Fixes 'The Simpsons', which it's fully playable now.
    +Konami 052109
        -Fixed scroll, now 'Ajax' works fine.
-China Gate
    +Added driver with sound
-Side Arms
    +Added driver with sound
-Speed Rumbler
    +Added driver with sound
</pre><br>
<img src="https://i.ibb.co/nQLhzkR/sidearms.png"> <img src="https://i.ibb.co/ZL4qdMG/chinagate.png"><br>
<img src="https://i.ibb.co/HKM5b3X/speedrumbler.png"><br>
<img src="https://i.ibb.co/DDZvm9x/ajax.png"> <img src="https://i.ibb.co/4J0nfrT/simpsons.png"><br>
<img src="https://i.ibb.co/smYLSk8/sort-list.png"><br><br>
<b>04/09/22 - DSP Emulator 0.21WIP2. Updated Windows 32 and source update. This release tries to improve general stability.<br>
<pre>
-DSP 0.20Final has been repacked with preview images
-General
    +Update preview images
    +New option for consoles, now you can choose if you want start the driver with the window for loading games open or not
    +Sound options simplified, now you can choose 'enabled' or 'disabled'
    +Fixed label 'load disk' in console cartridge 'open' icon, now shows 'load game'
    +If no game is loaded, shows a image, not just an empty window
    +Fixed window priority, if a option window is active, the window behind is disabled
    +Added some languaje translations in main config menu
    +Changed 'Show game list', 'Configure DSP' and 'Save screen' icons
    +Changed 'Show game list' and 'Configure DSP' position in main window
    +Sound: removed 11025Hz and 22050Hz sample quality, they are useless!
    +CPU
        -M6805: Added opcodes $21, $56, $6a, $7a, $7f and $c1
-Amstrad CPC
    +If a CDT tape is loaded and there is no pause block at the beginning, a 2000ms pause is added to the virtual tape
-Arkanoid
    +Added driver with sound (Not correct sound chip)
-Renegade
    +Fixed input
    +Fixed sprites
</pre><br>
<img src="https://i.ibb.co/y6x0knj/arkanoid.png"><br><br>
<b>01/08/22 - DSP Emulator 0.21WIP1. Updated Windows 32 and source update.<br>
<pre>
-General
    +Z80 CTC: converted to classes
    +Added close function to many devices
    +Sound: Make internal sound buffer bigger
    +CPU
        -M6809: Added opcodes $01, $29 and $1X2e
        -M680X: 
             + Added opcodes $47,$c2,$c9,$d9,$f0 and $fb
             + Opcode $f3 is not for M6808
-Senjyo HW
    +Update driver to new CTC
    +Senjyo: Fixed ROMs export size (thanks to okurka)
-MCR HW
    +Tapper: added driver with sound
-Williams HW
    +Fixed sound
    +Joust: added driver with sound
    +Robotron: added driver with sound
    +Stargate: added driver with sound
</pre><br>
<img src="https://i.ibb.co/7ygV8q2/joust.png"> <img src="https://i.ibb.co/QMLz9Cq/Robotron.png"><br>
<img src="https://i.ibb.co/gzB2Ld8/Stargate.png"> <img src="https://i.ibb.co/WkrhCBH/Tapper.png"><br><br>
<b>15/07/22 - DSP Emulator 0.20Final. Updated Windows (32 & 64), Linux (64), OSX (64) and source update.<br>
<pre>
-General
    +Changed transparent color (fixes 'Thunder & Lightning' sprites)
    +CPU
        -UPD78XX
            +UPD7801
                -Fixed IRQs
                -Fixed timers
-Amstrad CPC
    +Fixed green monitor palette
    +Added green monitor brightness
-Coleco
    +Fixed snapshot loading
-Super Cassete Vision
    +Fixed remain issues
    +Fixed BASIC Nyuumon RAM 
-Ninja Kid II HW
    +Fixed sound init
-Seta HW
    +Thunder & Lightning: added protection
</pre><br><br>
<b>29/06/22 - DSP Emulator 0.20WIP9. Win32 and source update.<br>
<pre>
-General
    +Updated SDL library to 2.0.22
    +CPU
        -UPD78XX
            +Added many, many opcodes and fixed many others
            +Added UPD7801 opcode timing tables
            +Fixed IRQs
            +Fixed outports
-Amstrad CPC
    +Rewrited CRT video emulation
    +Added green monitor option
    +Fixed hardware scroll
-Super Cassete Vision
    +Added video emulation
    +Added Sound
    +Added input
    +Added ROM banking
    +Everything moves slow... And I dont know why...
</pre><br>
<img src="https://i.ibb.co/4mPpzSG/007-after.png"> <img src="https://i.ibb.co/KKL0dMs/007-before.png"><br>
<img src="https://i.ibb.co/twRdZ1T/actionf-after.png"> <img src="https://i.ibb.co/G9GP1GS/actionf-before.png"><br>
<img src="https://i.ibb.co/gZQztF4/indy-after.png"> <img src="https://i.ibb.co/ypP0KgM/indy-before.png"><br>
<img src="https://i.ibb.co/k1zBkFr/prof2-after.png"> <img src="https://i.ibb.co/7CYr8QC/prof2-before.png"><br>
<img src="https://i.ibb.co/ZL3mxSw/rastan-after.png"> <img src="https://i.ibb.co/gjFBf4g/rastan-before.png"><br>
<img src="https://i.ibb.co/9qwKFxd/rick2-after.png"> <img src="https://i.ibb.co/tX7LPNF/rick2-before.png"><br>
<img src="https://i.ibb.co/RpYZDH5/scauldron-after.png"> <img src="https://i.ibb.co/2nGSkfs/scauldron-before.png"><br>
<img src="https://i.ibb.co/h87xtth/xyp-after.png"> <img src="https://i.ibb.co/ZKPdGxV/xyp-before.png"><br>
<img src="https://i.ibb.co/PcmnGKC/scv-db.png"> <img src="https://i.ibb.co/r0fkxgj/scv-dragons.png"><br>
<img src="https://i.ibb.co/ZTwdqg2/scv-kungfu.png"> <img src="https://i.ibb.co/g967ZMt/scv-mappy.png"><br>
<img src="https://i.ibb.co/NsvDYxP/scv-monster.png"> <img src="https://i.ibb.co/16r4ysL/scv-polepos2.png"><br>
<img src="https://i.ibb.co/t3fXqTV/scv-prowr.png"><br><br>
<b>01/05/22 - DSP Emulator 0.20WIP8. Win32 and source update.<br>
<pre>
-General
    +ROMs export
        -Fixed Sly Spy ROMs info (Thanks to Neville)
    +CPU
        -Z80
            +Added M1 raise signal (read opcode)
        -M6800
            +Added HD63701Y0 CPU
            +Fixed internal read/write registers
            +Fixed opcodes BHI and BLS (ouch!)
            +Added opcode RORA
-Amstrad CPC
    +Speed up video
    +Dandanator added initial support
-Black Tiger
    +Fixed MCU CPU clock
    +Added video HW specs
-Commando
    +Fixed main CPU clock
    +Added video HW specs
-Ghost'n Goblins
    +Added video HW specs
-Gun.Smoke HW
    +Added video HW specs
-The Legend of Kage
    +Rewrited video driver
        -Fixed proirity BG/FG/Sprites
        -Fixed disable screen
-Outrun (Thanks to Neville)
    +Fixed palette
    +Fixed shadows
-Senjyo HW (called StarForce before)
    +Fixed video buffer
    +Added BG stripe and radar
    +Added char flip
    +Added Senjyo driver with sound
    +Added Baluba-louk no Densetsu driver with sound
-Super Dodgeball
    +Added driver with sound
-Sega System 16A HW (Thanks to Neville)
    +Fixed palette
    +Fixed shadows
-Sega System 16B HW (Thanks to Neville)
    +Fixed palette
    +Fixed shadows
</pre><br>
<img src="https://i.ibb.co/pbCwPBB/alien-new.png"> <img src="https://i.ibb.co/yykkKdT/alien-old.png"><br>
<img src="https://i.ibb.co/0F2cVnD/ddux-new.png"> <img src="https://i.ibb.co/RSjvvYx/ddux-old.png"><br>
<img src="https://i.ibb.co/R7QD992/outrun-new.png"> <img src="https://i.ibb.co/pwW4hDV/outrun-old.png"><br>
<img src="https://i.ibb.co/yNWN6Dq/baluba.png"> <img src="https://i.ibb.co/w6F4Wjc/dandanator.png"><br>
<img src="https://i.ibb.co/7tc3krp/legend.png"> <img src="https://i.ibb.co/yd1TJv8/Senjyo.png"><br>
<img src="https://i.ibb.co/N6bCFj9/superdb.png"><br><br>
<b>27/03/22 - DSP Emulator 0.20WIP7. Win32 and source update.<br>
<pre>
-General
����+Simplified drivers initialization
����+Deco BAC06
��������-Added video buffer
��������-Fixed sprite RAM size
��������-Fixed row & col scroll
����+Samples
��������-Now you can specify the source file (fixes sample load from 'New Rally X')
����+CPU
��������-M68000
������������+Added opcode 'ror.w' (fixes E-Swat)
��������-M6800
������������+Fixed opcodes LSR, ROR, LSRD, ASLD, DAA, BHI and BLS
������������+Fixed flags from RTI (Fixes 'Knockle Joe')
-Act Fancer
����+Updated ROMs
-Contra
����+Fixed Sound CPU clock
-Deco 0 HW
����+Fixed many graphics issues
����+Changed FPS, adjusted lines
��������-Sly Spy: Added driver with sound
��������-Bouder Dash I/II: Added driver with sound
-Epos HW
����+The Glob: Added dip switches
����+Superglob: Added dip switches
-Megazone
����+Fixed CPU clock
����+Fixed scroll
����+Updated ROMs names
-Pengo
����+Added dip switches
-Popeye
����+Fixed CPU NMI
-Route 16 HW
����+Fixed DAC reset
-Slapfigth HW
����+Removed sprites buffer
����+Added dip switches and P2 controls
����+Fixed video lines
����+Fixed IRQ generation
����+Fixed CPU memory map
����+Added sound CPU reset
-TNZS HW
����+Fixed YM2203 init
-Twin Cobra HW
����+Added dip switches
</pre><br>
<img src="https://i.ibb.co/syqg8Vf/SlySpy.png"> <img src="https://i.ibb.co/zn24jhn/Boulder-Dash-I-II.png"><br><br>
<b>20/02/22 - DSP Emulator 0.20WIP6. Win32 and source update.<br>
Happy 20th aniversary!<br>
More than 200.000 code lines<br>
More than 300 arcade games<br>
10 8bits computers<br>
8 home consoles<br>
19 CPUs emulated<br>
29 sound chips<br>
And more to come!<br>
<pre>
-General
����+Updated SDL library to 2.0.20
����+Analog control: Addded selection of X or Y axis inverted
-Genesis/Megadrive
����+Started a new driver
-Mr Do!
����+Fixed colors
����+Added dipswitch
-Crystal Castles: Added driver with sound
-Flower: Added driver with sound
-Mr Do Castle Hardware
����+Mr Do Castle: Added driver with sound
����+Do! Run Run: Added driver with sound
����+Mr Do Wild Ride: Added driver with sound
����+Jumping Jack: Added driver with sound
����+Kick Rider: Added driver with sound
����+Indoor Soccer: Added driver with sound
</pre><br>
<img src="https://i.ibb.co/YRpBMZn/ccastles.png"> <img src="https://i.ibb.co/QK4H7bL/Flower.png"><br>
<img src="https://i.ibb.co/bL1nPyV/docastle.png"> <img src="https://i.ibb.co/5vCDj3Q/dorunrun.png"><br>
<img src="https://i.ibb.co/PCfncpm/dowild.png"> <img src="https://i.ibb.co/cx19TTm/jjack.png"><br>
<img src="https://i.ibb.co/SN4wrdn/kickrider.png"> <img src="https://i.ibb.co/G9hgj0n/insoccer.png"><br><br>
<b>22/11/21 - DSP Emulator 0.20WIP5. Win32 and source update.<br><pre>
-General
����+CPU
��������-MCS48
������������+Added I8042 CPU type
������������+Fixed IRQs
������������+Added opcodes $02,$08,$22,$35,$40,$41,$60,$61,$65,$86,$89,$8a,$90,$c7 and $d6
������������+Fixed opcodes $10,$11 and $57
-Sega GameGear
����+Added Master System video compatibility
����+Added CodeMasters Mapper extra RAM
-NinjaKid II HW
����+Added dipswitches
����+NinjaKid II: Added PCM sound
����+Atomic RoboKid: Added driver with sound
-StarForce
����+Updated ROMs names
-Sega System 16a
����+Added PCM sound
-The New Zealand Story HW
����+Extermination: Added driver with sound
</pre><br>
<img src="https://i.ibb.co/sVXs8Cj/Extermination.png"> <img src="https://i.ibb.co/ysdpg20/Atomic-Robo-kid.png"><br>
<img src="https://i.ibb.co/Qj0Y1Y3/castle.png"> <img src="https://i.ibb.co/nnjPJ4r/outrun-europa.png"><br><br>
<b>31/10/21 - DSP Emulator 0.20WIP4. Win32 and source update.<br><pre>
-General
����+Seta Sprites: Added new device
����+CPU
��������-M6502
������������+Added M65CE02 CPU type. Added many specific opcodes
����+Lens Lock
��������-Fixed Amstrad decode mode
����+Seta X1-010
��������-Added new sound device
-Spectrum
����+Spectrum 16K/48K fixed screen timings
-Dec8 HW
����+Super Real Darwin: Inverted coin input
-Karate Champ
����+Added driver with sound
-Pacman HW
����+Enhance IRQs
����+Ms Pac Man Twin
��������-Added driver with sound
-Renegade
����+Fixed dipswitches
-Seta HW
����+Thundercade
��������-Added driver with sound
����+Twin Eagle
��������-Added driver with sound
����+Thunder & Lightning
��������-Added driver with sound
-StarForce
����+Fixed X scroll in background
-The New Zealand Story HW
����+Rewrited video system, now uses Seta Sprite device
</pre><br>
<img src="https://i.ibb.co/1v0t051/Karate-Champ.png"> <img src="https://i.ibb.co/LCjkcSF/Ms-Pac-Man-Twin.png"><br>
<img src="https://i.ibb.co/THTbTq6/Thunder-Lightning.png" > <img src="https://i.ibb.co/3WdcDhH/Thundercade.png" ><br>
<img src="https://i.ibb.co/2d2z7vQ/Twin-Eagle.png"><br><br>
<b>27/08/21 - After some exhausting and time-consuming real life, here comes a new little update. DSP Emulator 0.20WIP3. Win32 and source update.<br><pre>
-General
����+Joystick: Some changes to enhance configuration
-Commodore 64
����+Snapshots: Initial support for VSF (Vice Snapshot File)
-Burguer Time HW
����+Code cleaning
����+Burguer Time: Update decryption, more speed
����+Lock'N'Chase: Added driver with sound
����+Minky Monkey: Added driver with sound
-Mario Bros.
����+Added quick snapshots
-Sega System 1/System 2
����+Fixed slowdowns and clean code
����+Added quick snapshots
����+Enhanced video buffer, more speed
</pre><br>
<img src='https://i.ibb.co/2dhK7yY/lnc.png'> <img src='https://i.ibb.co/BNhzcvg/mmonkey.png'><br><br>
<b>31/05/21 - DSP Emulator 0.20WIP2. Win32 and source update.<br><pre>
-General
����+CPU
��������-UPD78XX
������������+Added sub CPU 7801
������������+Added many opcodes, and fix others
-Sega Master System
����+Fixed IRQ in SMS video mode (Fixes 'Nemesis', 'The Simpsons - Bart vs. the Space Mutants', etc)
����+Fixed memory initialization with value $f0 (Fixes 'Alibaba and 40 Thieves', 'Micro Xevious', etc)
����+Change palette of TMS video mode
-Super Cassette Vision
����+Added preliminary console driver (to fix CPU 78XX and enhance Taito CChip!)
-Toaplan 1
����+Added preliminary driver for the system
��������-Hellfire: Basic driver 
</pre><br><br>
<b>22/04/21 - DSP Emulator 0.20WIP1. Win32 and source update.<br><pre>
-General
����+CPU
��������-LR35902
������������+Add 4T when take an IRQ and comes from HALT
-Gameboy/Gameboy Color
����+Fixed background/window/sprites prorities. Finally understood how it works and renders the screen and objects
����+Fixed window line draw (Fixes 'Star Trek', 'Marblemadness', 'International Karate' and many others)
����+Fixed stupid bug in Gamboy Color video RAM
����+Fixed Gameboy Color background color (Fixes 'Yoda Stories')
����+Fixed sprite/sprite priority
����+Fixed when LCD is disabled, LCD-stat is 0
����+DMA - Fixed data origin 
</pre>
<img src='https://i.ibb.co/p2X10Tc/karate.jpg'> <img src='https://i.ibb.co/k2mwrPG/startrek.jpg'><br>
<img src='https://i.ibb.co/JtgQtNG/Yoda.jpg'><br><br>
<b>10/04/21 - DSP Emulator 0.19 released<br>
Windows 32bits and 64bits, Linux 64bits, MacOS X 64bits and source updated. Updated Wiki.<br><pre>
All changes on previous 0.18b3 release and
-General
����+Preview picture
��������-Cosmetical changes: bigger with black background and scaled picture
��������-Added picture to Spectrum Plus 2A, SG-1000 and GameGear. Split GameBoy and GameBoy color pictures
-Gameboy/Gameboy Color
����+Better drawing priorities, still not perfect
����+Window: fixed priorities with sprites (Look at 'Prehistorik Man')
����+Fixed controls order reading (Fixes new version of 'Robocop' - Thanks to Neville)
����+Small fix to serial (Fixes 'Lunar Lander', 'Hyper Dunk' and many others)
-Suna 8 HW
����+Hard Head 2
��������-Fixed palette
</pre>
<b>28/03/21 - Last update before stable version. DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
����+Samples: simplified samples loading functions
-Suna 8 HW
����+Added DIP switches
����+Fixed sound clock
��������-Hard Head
������������+Fixed DAC samples
������������+Fixed FPS
��������-Hard Head 2
������������+Fixed ROM decode
������������+Fixed video (only remains palette color problem)
������������+Added DAC samples
-Tiger Road HW
����+Added DIP switches
-Outrun
����+Fixed gear button
</pre>
<img src='https://i.ibb.co/3vsqcdv/hh2-1.jpg'> <img src='https://i.ibb.co/233KTxs/hh2-2.jpg'><br><br>
<b>13/03/21 - Second update today! DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-GameBoy/Gameboy Color HW
����+Now you can choose between original GB green palette and GB pocket BW (Thanks to Neville)
-Amstrad CPC
����+Fixed screen flickering (Thanks to Neville)
</pre>
<b>13/03/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
����+Sound
��������-Sega PCM: Added sound chip
-Spectrum
����+Fixed low border size, was 8 pixels too long (Thanks to Neville)
����+Fixed fast speed and no border draw, now don't draw any border
-Amstrad CPC
����+Resize screen size, it was too big, now it's 384x272 pixels (Thanks to Neville)
-Sega Master System
����+Fixed zip ROM load (Thanks to Neville)
-Sega GameGear
����+Fixed zip ROM load (Thanks to Neville)
-Outrun HW
����+Added road
����+Added Sega PCM
����+Added controls
����+Added DIP switches
</pre>
<img src='https://i.ibb.co/RcKQtpX/Outrun-1.jpg'> <img src='https://i.ibb.co/GJmTSdT/Outrun-2.jpg'><br><br>
<b>05/03/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
����+CPU
��������-M68000: Added reset line procedure
����+Added Sega 315-5195 as a device
-Outrun HW
����+Enhanced driver only missing: partial road, digital sound and controls
</pre>
<img src='https://i.ibb.co/4VZGbtv/Outrun-1.jpg'> <img src='https://i.ibb.co/fvp9PQL/Outrun-2.jpg'><br><br>
<b>26/02/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
����+CPU
��������-MCS51:
������������+clean the code
������������+Fixed carry in opcodes $B8 to $BF
������������+Fixed IRQs
����+ROMS export: Fixed many ROMs sets and added samples, again
-Ajax: Fixed ROM names
-Slap Fight: Fixed ROM names
-Sega System 16B HW
����+Small fix to memory mapper
����+When using i8751, the M68000 don't have access to 315-5195
����+Removed i8751/M68000 hack
����+Added dipswitches
��������-Golden Axe: Fixed remaining issues with i8751
��������-Passing Shot: Added driver with sound, due the lack of FD1094 emulation using predecoded version
��������-Aurail: Added driver with sound
</pre>
<img src='https://i.ibb.co/d4KG1Mr/passingshot.jpg'> <img src='https://i.ibb.co/b3mqHPb/Aurail.jpg'><br><br>
<b>23/02/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Renewed preview images (Thanks to Neville)
-General
����+CPU
��������-MCS51: Added halt line
����+ROMS export: Fixed many ROMs sets (Thanks to Neville)
-Commodore 64
����+Added PRG and T64 file support (added by chuso gar)
-Sega System 16B HW
����+Fixed dipswitches
����+Fixed video cache
����+Fixed sprite colors
����+Added memory overlap
����+Added 315-5248 and 315-5250
����+Added more operations to 315-5195
��������-Dynamite Dux: Added driver with sound
��������-Golden Axe: Driver working, due problems with i8751/M68000 using predecoded version
��������-ESwat - Cyber Police: Added driver with sound, due the lack of FD1094 emulation using predecoded version
</pre>
<img src='https://i.ibb.co/sV7p4Gg/ddux.jpg'> <img src='https://i.ibb.co/SmTHK9B/Golden-Axe.jpg'><br>
<img src='https://i.ibb.co/685rNxJ/eswat.jpg'><br><br>
<b>19/02/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
����+CPU
��������-MCS51: Added opcodes $45,$e2,$e3,$f2 and $f3
����+uPD7759: Added slave chip type
-Sega System 16B HW
����+Added MCU, sound, sprites and controls
����+Fixed chars and tiles
��������-Altered Beast: Driver with sound
��������-Golden Axe: Initial driver
</pre>
<img src='https://i.ibb.co/BqJ7h6z/Altered-Beast-1.jpg'> <img src='https://i.ibb.co/cJZ8tGN/Altered-Beast-2.jpg'><br><br>
<b>14/02/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
����+CPU
��������-M68000: Fixed TAS opcode
-Sega System 16B HW
����+Altered Beast: Initial driver
</pre>
<img src='https://i.ibb.co/1R3GTt2/Altered-Beast-1.jpg'> <img src='https://i.ibb.co/prjZ7j4/Altered-Beast-2.jpg'><br><br>
<b>26/01/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
����+CPU
��������-M6800: Added opcodes $56 and $fa
-Gameboy/Gameboy Color
����+Better Y scroll
����+Better sprites/backgorund priorities
-Baraduke HW
����+Baraduke: Added driver with sound
����+Moto-Cross: Added driver with sound
-Namco System 86 HW
����+Rewrite sprite system
����+Removed video hacks
����+Added dipswitches
����+The Return of Ishtar: Added driver with sound
����+Genpei ToumaDen: Added driver with sound
����+Wonder Momo: Added driver with sound
</pre>
<img src='https://i.ibb.co/VDY2nwC/Baraduke.jpg'> <img src='https://i.ibb.co/j4SqBnf/Metro.jpg'><br>
<img src='https://i.ibb.co/MGW3zJL/return.jpg'> <img src='https://i.ibb.co/G0PmKfx/Genpei.jpg'><br>
<img src='https://i.ibb.co/sVsFRWv/Wonder.jpg'><br><br>
<b>10/01/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Gameboy/Gameboy Color review
����+Fixed mapper MBC1
����+Added MBC1 collection version (fixes 'Bomberman Collection', 'Mortal Combat I&II', '4 in 1 Vol II', etc)
����+Fixed mapper MBC2
����+Added mapper MBC3
����+Added partial MBC7
����+Fixed cartridge load (fixes cartridges bigger than 4Mb)
����+Fixed cartridge default start values (fixes 'Dragon's Lair - The Legend' and many others)
����+Fixed OAM DMA, dont add aditional CPU cycles and dont draw sprites if its running
����+Fixed CGB DMA, change the counter values when running (fixes 'Turok - Rage Wars', 'Aliens - Thanatos Encounter' and many others)
����+Fixed CBG DMA start/stop info and cancel option (fixes 'Championship Motocross 2001' and others)
����+Fixed CGB sprite/BG priority (fixes graphis in '007 - The World is Not Enough' intro)
����+Fixed CBG sprite tranparency
����+Added sprite draw order (fixes 'Boy and His Blob, A - Rescue of Princess Blobette')
����+Added a basic serial IRQ (makes 'Mortal Kombat' run)
����+Added STAT IRQ blocking (makes 'Altered Space', 'Pinball Fantasies', 'Pinball Dreams' and many others run)
����+Fixed controls (fixes 'Konami GB Collection Volume 1')
����+Fixed BIOS disable... Ouch! Never gets enabled again after boot!
</pre>
<img src='https://i.ibb.co/fSXQ5HJ/007.jpg'> <img src='https://i.ibb.co/S02H0G8/alien.jpg'> <img src='https://i.ibb.co/FgqHLQf/tarta.jpg'><br>
<img src='https://i.ibb.co/HNBLtnN/altered.jpg'> <img src='https://i.ibb.co/QpS6Hcs/DL.jpg'><br>
<img src='https://i.ibb.co/SQNzFt8/nascar.jpg'> <img src='https://i.ibb.co/f9XBSvR/Perfect-Dark.jpg'><br>
<img src='https://i.ibb.co/2tgpJnp/turok.jpg'> <img src='https://i.ibb.co/NtFTbKK/xmen.jpg'><br><br>
<b>02/01/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Blood Bros HW
����+Blood Bros.: Added driver with sound
����+Sky Smasher: Added driver with sound
</pre>
<img src='https://i.ibb.co/qYtR8zM/Blood-Bros.jpg'><img src='https://i.ibb.co/QcjZ5vR/Sky-Smasher.jpg'><br><br>
<b>30/12/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
����+CPU
��������-M68000: Fixed sign in opcode pea.w
����+Video: Added a function to change video resolution on execution time
-3x3 Puzzle HW
����+3x3 Puzzle: Added driver with sound
����+Casanova: Added driver with sound
-1945k III HW
����+1945k III: Added driver with sound
����+96 Flag Rally: Added driver with sound
</pre>
<img src='https://i.ibb.co/RTvMTWp/3x3-Puzzle.jpg'><img src='https://i.ibb.co/tXhw2Fw/Casanova.jpg'><br>
<img src='https://i.ibb.co/9ZHffKf/1945k-III.jpg'><img src='https://i.ibb.co/Zg1p5m2/96-Flag-Rally.jpg'><br><br>
<b>27/12/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Lazarus
����+More cosmetical changes
����+Fixed 'no sound' option
-General
����+CPU
��������-Z80: Fixed a stupid bug on IRQ
-SNK
����+Fixed rotation buttons
����+ASO - Armored Scrum Object: Added driver with sound
-Fire Trap
����+Added driver with sound
</pre>
<img src='https://i.ibb.co/tbPFC5s/ASO.jpg'><img src='https://i.ibb.co/7k0tR07/FireTrap.jpg'><br>
Merry Christmas and happy new year!!
<img src='https://i.ibb.co/ZMswJ6h/santa.gif'><br><br>
<b>14/12/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Lazarus
����+Cosmetical changes (icons, objects size...)
����+Fixed change screen size from options menu
-Game & Watch
����+Finaly find a solution to compile under Lazarus
-Amstrad CPC
����+You can load disks again... Opps!
</pre><br><br>
<b>08/12/20 - DSP Emulator 0.18b3 WIP. Win32, macOS64 and source update.<br><pre>
-Added macOS 64bits WIP compilation, tested on v10.15 and v11.0
-NES
����+Changes on mapper 5, fixes PRG mapping
-Tecmo HW
����+Fixed small bug on ADPCM
����+Fixed FPS
����+Silkworm:
��������-Fixed sound chip, it's a YM3812
��������-Fixed Z80 clock
</pre><br><br>
<b>01/12/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Sega VDP
����+Fixed IRQ generation
-Sega GameGear
����+Added driver with sound
����+Added Codemasters mapper
-Sega Master System
����+Added cart enable/disable
����+Driver stop and warning if no BIOS present
-Armed F HW
����+Added driver for Crazy Climber 2
����+Added driver for Legion
</pre>
<img src='https://i.ibb.co/0cy0d0J/cclimber2.jpg'>
<img src='https://i.ibb.co/v3rFCPQ/legion.jpg'><br>
<img src='https://i.ibb.co/j3J1Q23/sonic.jpg'>
<img src='https://i.ibb.co/X8XvmNn/street-rage.jpg'>
<img src='https://i.ibb.co/L6cGmQg/jedi.jpg'><br><br>
<b>25/11/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-SG-1000
����+Added two mappers. Almost 100% compatibility now
-Armed F HW
����+Added Terra Force driver with sound
</pre>
<img src='https://i.ibb.co/bsBmfcc/Terra-Force.jpg'>
<img src='https://i.ibb.co/DQr1WRB/kings.jpg'>
<img src='https://i.ibb.co/Dtnt3dP/yakf2.jpg'><br><br>
<b>23/11/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-Armed F HW
����+Added Armed F driver with sound
</pre>
<img src='https://i.ibb.co/wwKDKzy/Armed-F.jpg'><br><br>
<b>13/11/20 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
����+TMS99XX: Fixed video mode 2
-Coleco
����+Added Mega Cart support: ROM pagination
����+Added Super Game Module support: More RAM and AY8912
����+Added support for Boxxle and Black Onix (missing EEPROM)
</pre>
<img src='https://i.ibb.co/Kbdy6Dh/dragon.jpg'>
<img src='https://i.ibb.co/g6BcNn3/jetpac.jpg'>
<img src='https://i.ibb.co/b6C6hCc/mario.jpg'>
<img src='https://i.ibb.co/myvKXbb/pacman.jpg'><br><br>
<b>06/11/20 - DSP Emulator 0.18b2 Final. Almost three years have passed since the last update! Updated Win32 binary and source code.
The executables for Linux and Mac this time are not compiled, if someone needs them let me know..</b><br>
Many, many changes. The most important are:<br><pre>
-General
����+YM2203/YM2151/YM3812: Fixed (finally!) the FM sound, improves a lot Shinobi, Rastan, Ghost'n Goblins, Snow Bros...
����+CPU's: Added some CPU's, many fixes and new opcodes
-8bit computer
����+Spectrum: 100% emulated 'floating bus', added 'Turbo sound'..
����+Commodore 64: Added a initial driver
-Consoles
����+NES: Fixed many video issues, added many mappers...
����+Sega Master System: Improved driver, almost 100% working games
-Arcade
����+Added some MCUs to emulate protections, added 24 new games, added dipswitches...
</pre>
All changes in 'Whatsnew.txt'. Some snapshots later<br><br>
<b>31/12/17 - DSP Emulator 0.18 Final. Source and all binaries updated.</b><br>
All previous changes and...<br><pre>
-General
����+Lazarus: Changed then way SDL library initializes the audio, using the newer functions
����+Better Open/Save dialogs. Now work the last directory used for each system
����+Changed where and when the SDL library is initializated
-NES
����+Fixed mappers 1, 4, 12, 67 and 68
����+Added mappers mmc6, 11 and 147
-Contra
����+Added DIPs switches
-Knuckle Joe
����+Added DIPs switches and 2nd player
-Super Basketball
����+Added DIPs switches and 2nd player
-Iron Horse
����+Updated to version K
</pre>
Please read the 'Whats New' for a full list of changes<br>
Merry Christmas and happy new year!<br><br>
<b>05/12/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br>
New WIP update! Gauntlet HW completed!<br><pre>
-General
����+CPU engine: Fixed reset state when is asserted (not pulsed)
����+M6502 CPU: Set BRK flag disabled on reset
����+M68000: Added M68010, and changed some opcodes
����+Slapstic: Enhanced some functions, added more revisions
����+Atari MO: Added Atari sprite system
����+Palette engine: added a function for 4bits+intensity palette generator
-Iron Horse
����+Updated to version K
-Gauntlet HW
����+Gauntlet: Completed driver, added video, sprites, audio and controls
����+Gauntlet II: Added driver with sound
-Atari System I
����+Peter Pakrat: Basic driver
</pre><br>
<img src='http://img1.imagilive.com/1217/gauntlet.png'><img src='http://img1.imagilive.com/1217/gauntlet_play.png'><img src='http://img1.imagilive.com/1217/gauntlet2.png'><img src='http://img1.imagilive.com/1217/gauntlet2_play.png'><br>
<b>21/10/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br>
After some health problems (visit to the hospital included), I publish a new WIP update<br><pre>
-General
����+Slapstic: Added Atari Protection device
����+Pokey: Added the function to define ALL_POT call
����+Improved column scroll function
����+Added a specific function for shadow sprites
-Gameboy / Gameboy Color
����+Improved video timmings
����+Corrected colors in GBC
����+Fixed some control bits (Serial, IRQ, Joystick, etc.)
����+Corrected the function that compares line Y
����+Fixed HDMA functions in GBC
����+Improved HU-C1 and MMMM01 mappers
-Food Fight
����+Added default NVRAM load
����+Correct the size and data type of the NVRAM
-Sega System 1/2
����+Fixed Z80 timmigs
����+Added DIPs to all games and 2nd player
����+Improved sound IRQs
-Mappy HW
����+Super Pacman: Fixed sprites
-Tetris (Atari)
����+Added driver with sound
-SNK HW
����+Ikari Warriors: Added driver with sound
����+Athena: Added driver with sound
����+T.N.K III: Added driver with sound
</pre><br>
<img src='http://img1.imagilive.com/1017/tetris_atari.png'><img src='http://img1.imagilive.com/1017/ikari.png'><img src='http://img1.imagilive.com/1017/athena.png'><img src='http://img1.imagilive.com/1017/tnk3.png'><br>
<b>13/07/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br>
Enhanced Amstrad CPC emulation<br><pre>
-Game and Watch
����+Added 'Mario Bros.', missing graphics
����+Better sound emulation
-Amstrad CPC
����+Better CPC Z80 timings
����+Added configuration for tape motor, you can select if it is used in the emulation of the virtual tape or not
����+Improved video (registers, vsync, hsync, etc.)
����+Improved memory management, 512Kb expansion it's working properly
����+Improved interruptions
-Super Darwin
����+Added MCU, simulated protection removed
����+Corrected palette and VBLANK
����+Added 2nd player controls, dip switches and screen flip
</pre><br>
<img src='http://img1.imagilive.com/0717/rex.png'><img src='http://img1.imagilive.com/0717/buggy.png'><img src='http://img1.imagilive.com/0717/helichopper.png'><br>
<b>11/06/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br>
At last I have emulated (not simulated) two Game and Watch games!. Thanks to MAME for the ROMs and the info.<br><pre>
-General
����+SM510: Added new CPU
-Spectrum
����+Simplified and standardized speaker functions
-Game and Watch
����+Donkey Kong Jr: Added game with sound
����+Donkey Kong II: Added game with sound
</pre><br>
<img src='http://img1.imagilive.com/0617/gnw_dkongjr.png'><img src='http://img1.imagilive.com/0617/gnw_dkong2.png'><br>
<b>10/05/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br><pre>
-General
����+GFX: Added functions to rotate X axis and/or Y axis of a surface
-Psychic 5
����+Fixed intro
-Crazy Climber
����+Added driver with sound
-Return of the Invaders
����+Added driver with sound
</pre><br>
<img src='http://img1.imagilive.com/0517/crazyclimber.png'><img src='http://img1.imagilive.com/0517/returnoftheinvaders.png'><br>
<b>28/04/17 - DSP Emulator 0.18WIP. Win32 binary and source updated.</b><br><pre>
-General
����+Lazarus
��������-Fixed stereo sound
��������-Improved audio synchronization
����+GFX
��������-Added final screen independent flip X or flip Y
��������-Improved scrolling by independent rows and/or columns
        -Improved zoom sprites (no more graps)
����+Deco BAC06
��������-Converted to classes
��������-Fixed bugs and more speed
����+Deco 16IC: Converted to classes
����+K051960, K05324x: Optimized sprites rendering
����+K007232
��������-Support of two simultaneous audio chips
��������-Fixed stereo support
����+K053260: Fixed stereo support
����+MCS51
��������-Corrected registers, mapped in memory
��������-Added more opcodes
-Deco 0 HW
����+Driver optimizations
����+Added dipswitches
����+Baddudes: Added i8751, protection patches removed
-Caveman Ninja HW
����+Fixed raster interrupts
����+Robocop 2: Fixed video
-Toki
����+Fixed sprites
-ActFancer
����+Optimized driver
����+Added dipswitches
-Gradius III
����+Changed sound to stereo
-Simpsons
����+Changed sound to stereo
-Vendetta
����+Changed sound to stereo
-Ajax
����+Fixed audio (converted to stereo)
����+Fixed video (missing k051316 zoom/rotate)
����+Added controls
����+Added dipswitches
-Gauntlet HW
����+Basic driver
-Sauro
����+Added driver with sound, only missing ADPCM
</pre><br>
<img src='http://img1.imagilive.com/0417/sauro.png'><br><br>
<b>11/03/17 - DSP Emulator 0.17b2 Final. All binary and source updated.</b><br><pre>
-All WIP previous enhacements
-General
����+Fixed a bug when entering the options menu without starting a driver (Thanks to FJ Marti)
����+If a driver is not initialized when exiting the list, no buttons are displayed
����+Added multiple directories for arcade ROMS separated by ';' (requested by Davide)
����+Fixed enter full screen when changing from video menu
����+K054000: Added protection chip
����+K053246-K053247-K055673: Implemented functions to show sprites
-GameBoy/GameBoy Color
����+Rewritted the video functions
����+Corrected read/write of MBC5 mapper extra memory
����+Corrected the sound 'mode 3'
����+Corrected reading of the joystick/buttons when ussing the IRQ
����+Improved way to compare the current line that generates an IRQ
����+Improved timings of the current line
����+GameBoy Color
��������-Corrected the size of the palette records. Fixed when the palette pointer is automatically advanced
��������-Improved way to change speed
����+Improved loading a cartridge with an extra header before the data
����+Added mappers HuC-1 (to be confirmed) and MBC2
-Pacman HW
����+Added the rest of dipswitch
����+Added screen rotation
����+Crush Roller: Added driver with sound
-Galaxian HW
����+Fixed Scrambre sound, caused errors when closing the driver
-TNZS HW
����+Corrected audio initialization
-TMNT HW
����+TMNT: Changed the ROMS to 2 players version
-The Simpsons
����+Fixed video and audio
����+Graphics problems (possible bug in the CPU)
����+Changed the ROMS to the 2 Players version (requested by Davide)
-Vendetta (requested by Davide)
����+Added driver with sound
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
����+Tape Engine
��������-Improved handling of 1-byte blocks in TAP tapes
��������-Added control to avoid blocks of 0 length in TAP tapes
��������-Corrected the length of the message block of the TZX tapes
����+After pressing F4 to record a snapshot, the file select screen no longer is shown each time a key is pressed
����+UPD765: Improved processing a track with 0 sectors (Corrects 'Tomahawk' from Spectrum +3)
-Spectrum
����+Added Fuller joystick, and improved descriptions of other types of joystick
����+Fixed Cursor joystick, only works if selected
����+Improved Kempston joystick
-Galaxian HW
����+Moon Cresta
��������-Improved sound with samples
��������-Fixed a problem with chars/sprites
</pre>
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
����+Windows: Fixed image snapshot save bug (Thanks to FJ Marti)
����+Fixed a bug that if DSP is started with the ROMs list and no driver was selected, the emulator hangs (Thanks to FJ Marti)
����+Fixes to the ROMs/Samples file list exportation (Thanks to FJ Marti)
����+N2A03 
��������-Converted to CPU
��������-Converted to classes
����+Taito Sound
��������-Converted to classes
��������-Integrated Z80 CPU
����+Konami Sound
��������-Converted to classes
��������-Integrated Z80 CPU
-ExedExes
����+Added dipswitches
-Express Raider
����+Added dipswitches
-Double Dragon HW
����+Fixed IRQs
����+Double Dragon II: Fixed VBlank, solves the problem of color fading in transitions
</pre><br>
<b>15/10/16 - DSP Emulator 0.17b1. Win32 binary and source updated.</b><br><pre>
-General
����+Namco IO
��������-Added 50XX control CPU
��������-Added 54XX sound CPU, using samples
����+MB88XX CPU: Added opcodes $0f, $10, $1a, $20, $22, $2f and $48
����+Fixed folders load/save, now the correct last folder used for Spectrum, Amstrad, Coleco, NES, GB, etc is remembered
����+In general configuration menu, you can change preview images, samples, quick snapshot and NV-Ram folders. Removed NES, Coleco and GB folder change (useless now) 
-Spectrum
����+Z80 snapshot
��������-V1 - Fixed lenght of the compressed full memory block, I was ignoring the end mark
��������-V1 - Fixed buffer overflow, some times the snapshot data has more info that it's needed
��������-V2/V3 - Fixed uncompressed memory page inside of the data
��������-V2/V3 - Some checks to avoid bad snapshots
��������-V2/V3 - Now identify the correct Spectrum model
��������-V2/V3 - The preview image, now uses the active screen in 128k models
-Gun.Smoke HW
����+Gun.Smoke: Small video updates
����+1943: Fixed background scroll
-Galaga HW
����+Galaga: added samples
����+Xevious: added driver with sound, small problems with scroll and samples
-WWF Superstars
����+Small video updates
-TMNT HW
����+Sunset Riders: Enhanced copyprotection
</pre><br>
<img src='http://img1.imagilive.com/1016/xevious.png'><br>
<b>26/09/16 - DSP Emulator 0.17b1. Win32 binary and source updated.</b><br><pre>
-General
����+K051960: Implemented IRQ's
����+Changed the way to show the main window caption, including the name of the tape, snapshot, disk, etc.
����+Added MCS48 CPU series: i8035, i8039 and N7751
����+Added i8243, port expander
����+Deleted languages files, they are now integrated
����+K051316: Added basic implementation
����+Added a check when directories are saved to avoid duplicating the folder separator
-Amstrad CPC
����+Added support for the snapshot V3 chuncks (including compressed memory)
-Black Tiger
����+Small video updates
-Popeye
����+Small video updates
-Gyruss
����+Added i8039 CPU and DAC, completed sound
����+Converted audio to stereo
-Juno First
����+Added i8039 CPU and DAC, completed sound
-Sega System 16A
����+Preliminary support of the digital audio with the N7751 CPU
-Hyper Sports
����+Added driver with sound
-Megazone
����+Added driver with sound
-Space Fire Bird
����+Added driver with sound
����+Small problems with the backgroud stars
-Ajax
����+Basic driver
</pre><br>
<img src='http://img1.imagilive.com/0916/hypersports.png'><img src='http://img1.imagilive.com/0916/megazone.png'><br>
<img src='http://img1.imagilive.com/0916/spacefirebird.png'><br>
<b>30/07/16 - DSP Emulator 0.17b1. Win32 binary and source updated.</b><br><pre>
-General
����+Added support for IPF files natively without external libraries. 
��������-Many thanks to Jean Louis-Guerin (DrCoolZic) for the documententation 'http://info-coach.fr/atari/documents/_mydoc/IPF-Documentation.pdf'
��������-Many thanks also to Bruno Kukulcan and Yoan Courtois (Megachur) for some Amstrad CPC IPF files for testing.
��������-Updated languaje files with new messages
-Track & Field
����+Added driver with sound
</pre><br>
<img src='http://img1.imagilive.com/0716/track_and_field.png'><br>
<b>07/07/16 - DSP Emulator 0.17 Final. All binary and source updated.</b><br><pre>
-All previous enhacements
-General
����+Z80: Implemented WZ/MEMPTR register, now passes all ZEXALL tests
����+YM2203: Added functions to change the AY internal clock
-Spectrum
����+When a snapshot without ROM is loaded and previously changed to a different ROM than the original, it's reloaded the original ROM
����+Contended memory changes
-Amstrad CPC
����+Added LensLok protection
����+Enhanced video mode 2, more speed
</pre>
<b>18/06/16 - DSP Emulator 0.16b3 WIP. Source and Windows 32 WIP binary updated.</b><br><pre>
-Lazarus: Fixed zlib stuff. Removed external library dependency, now you can use fast snapshots, load spectrum SZX, DSP, CSW files, load Coleco snapshots, etc.
-Finished IRQ, NMI, reset and halt signals rewrite
-Simplified and reorganized all drivers procedures and functions
-Enhanced ZIP file load:
    +Delphi: the internal classes are used
    +Lazarus: More simple object implementation
-CPU M680X: Unified all opcodes
</pre><br>
<b>02/06/16 - DSP Emulator 0.16b3 WIP. Source and Windows 32 WIP binary updated.</b><br><pre>
-General
    +Begin a general driver cleaning
    +Z80: Added opcode function calls in class
    +YM2151: Converted the driver to class
-Rally X HW
    +Cleaned and corrected the driver (memory, video, etc. )
    +Jungler: Simplified the video, removed manual rotation
-Arabian
    +Fixed video
-Blockout
    +Fixed video
-The Simpsons
    +Added driver with sound, no sprites and many graphics problems
</pre><br>
<b>26/05/16 - DSP Emulator 0.16b3 WIP. Source and Windows 32 WIP binary updated.</b><br><pre>
-General
    +GFX: Fixed and enhanced the final screen rotation
    +Improved how drivers are closed, CPU, video, etc. Fixed bugs and removed some problems when the driver is not initialized and changed an other
    +K007232: Fixed sound
-Thunder Cross HW
    +Super Contra: Added driver with sound
    +Gang Busters: Added driver with sound
    +Thunder Cross: Added driver with sound
</pre><br>
<img src='http://img1.imagilive.com/0516/super_contra.png'><img src='http://img1.imagilive.com/0516/gang_busters.png'><br>
<img src='http://img1.imagilive.com/0516/thunder_cross.png'><br>
<b>24/05/16 - DSP Emulator 0.16b3 WIP. Source and Windows 32 WIP binary.</b><br><pre>
-General
    +KONAMI CPU
        -Almost finished
-Aliens
    -Added driver with sound
    -Small problem with sprite priorities
</pre><br>
<img src='http://img1.imagilive.com/0516/aliens1.png'><img src='http://img1.imagilive.com/0516/aliens2.png'><br>
<b>22/05/16 - DSP Emulator 0.16b3 WIP. Source and Windows 32 WIP binary.</b><br><pre>
-General
    +Unified into a single button Play/Pause functions
    +M6809
        -Cleaning and unified opcodes
        -Enhanced timings
        -Fixed 'sync' opcode
        -Added $102d opcode (Fix video in 'Combat School' and 'Contra')
        -Modified and simplified IRQs calls
    +HD6309
        -Total CPU cleaning
        -Added an internal M6809 for compatibility mode
    +KONAMI CPU
        -Writing started
-Mappy HW
    +Fixed sprites: added a mask for the sprites size
-Juno First
    +Fixed driver initialisation
</pre><br>
<b>15/05/16 - DSP Emulator 0.16b3 WIP. Source and Windows 32 WIP binary.</b><br><pre>
-General
    +YM3812: Added chip YM3526
    +PIA 8255
        -Converted to classes
        -Device driver clean
-Karnov HW
    +Karnov: Added driver with sound
    +Chelnov: Added driver with sound
</pre><br>
<img src='http://img1.imagilive.com/0516/karnov.png'><img src='http://img1.imagilive.com/0516/chelnov.png'><br>
<b>08/05/16 - DSP Emulator 0.16b3 WIP. Source and Windows 32 WIP binary.</b><br><pre>
-General
    +Fixed snapshots loading in some drivers
    +Fixed value and type of the amplifier in some sound chips
    +Cleaning some CPUs
    +Completely eliminated references to the 'SDL2.pas' unit and improved the 'lib_sdl2.pas' to be independent
    +GFX: fixed left rotate of the nonsquare graphics
    +Z80
        -Removed the special case of HALT opcode
        -Fixed possible loose of timings after the execution of an opcode
    +YM3812: Converted to classes
    +Konami Sound
        -Converted to classes
        -Integrated Z80 sound CPU
        -Integrated Frogger and Scramble sound driver
        -Improved and corrected some drivers
        -Separated into four types 'Time Pilot', 'Jungler', 'Frogger' and 'scamble'
    +Updated 'Galaxians' samples and added 'Space Invaders' samples
-Sega System 1
    +Added custom Z80 timings
-Popeye
    +Added 2nd player controls
    +Driver cleaning
-Galaxian HW
    +Galaxian: Added several sounds (samples)
    +Fixed stars background
-Space Invaders
    +Added driver with sound (samples)
-Centipede
    +Added driver with sound
</pre><br>
<img src='http://img1.imagilive.com/0516/spaceinvaders.png'><img src='http://img1.imagilive.com/0516/centipede.png'><br>
<b>10/04/16 - DSP Emulator 0.16b2 FINAL released. Source, Win32/64 and Linux 32/64 available.</b><br>
So much updates and enhancements, and at last a ROM/Samples information export. Please read the documentation or the wiki (Spectrum and Amstrad CPC have keyboard changes).<br>
Many thanks to greatxerox and Davide.<br><br>
<b>29/03/16 - DSP Emulator 0.16b2 WIP source and Win32 updated.</b><pre>
-Added to download SDL library 2.0.4 for Windows 32/64 bits. You can also download from http://www.libsdl.org
-DSK file engine
    +Added patches to fix the some Titus protections in Amstrad CPC
-Tape file engine
    +General cleaning
    +CSW format: File opening rewrited, improves stability.
    +TAP format: Standardized opening files through data structures
    +TZX format: Standardized opening files through data structures
    +PZX format
        -Standardized opening files through data structures
        -Corrected data block
        -Properly implemented very large pulses
-Spectrum
    +Mapped some missing special keys</pre>
<b>22/03/16 - DSP Emulator 0.16b2 WIP source and Win32 updated.</b><pre>
-Added to download some preview images
-General
    +Added a new button to configure dip switches the arcade drivers
    +Added a new button to configure computers and consoles
    +Controls engine
        -Rewrited engine, both the keyboard and joystick
        -Rewrited joystick calibration system
    +DSK file engine
        -Rewrited file openning, improves stability
        -Fixed double-sided images loading
        -Fixed emulation of weak sectors
        -Fixed calculating the length of a track
        -Fixed the order of the tracks
    +UPD765 chip
        -Fixed reading a sector ID (Corrects 'Tintin on the moon' Spectrum +3)
        -Fixed handling weak sectors (Corrects SpeedLock +3 protection)
        -Fixed attempt to read beyond the length of a sector (Corrects SpeedLock Amstrad CPC protection)
-Amstrad CPC
    +New menu to change options
        -Choose ROM versions: English, French, Spanish or Danish
        -Map ROMs in spaces 1 to 6 of CPC
    +Keys mapped all the CPC in a position similar to the original
    +Modified the timings Z80
-Asteroids
    +Fixed sound samples
    +Small fixes and cleaning</pre>
<b>29/02/16 - DSP Emulator 0.16b2 WIP source and Win32 updated.</b><pre>
-ROM Engine: ROM and samples file info export finished. Now you can use your favorite ROM manager.
-Small ROMs definition fixes in some drivers
-Uploaded Languaje files and sound samples used by DSP, I forgot to do it when I do de google project migration.</pre>
<b>28/02/16 - DSP Emulator 0.16b2 WIP source and Win32 updated.</b><pre>
-Lazarus: New sound engine, better sound. Some problems with stereo sounds (Using SDL2 v2.0.4)
-Samples: Fixes resample of no standar frequencies.
-ROM Engine: New export data system, now you can export ROM data in ClearMame Pro format to manage ROMs used. Finished about 50%. (Configure DSP --> ROM --> Export ROM Data)</pre>
<b>10/01/16 - DSP Emulator 0.16b1 Final version. Updated source, Windows 32/64 and Linux 32/64 binaries.</b><br>
<img src='http://s10.postimg.org/dqoip41vd/gradius3.png'></img><br><br>
<b>26/12/15 - DSP Emulator 0.16b1 source and Win32 snapshot updated again.</b><br><pre>
-GFX Engine: Implemented alpha color sprites and palette
-K0052109: Implemented video buffers, more speed
-K051960 and K05324X: Implemented shadow sprites (alpha color)
-Added Service functions pressing F1 (impremented in TMNT and Ghost'n Goblins drivers so far)</pre>
<b>22/12/15 - DSP Emulator 0.16b1 source and Win32 snapshot both WIP updated.</b><br><pre>
-Added Konami ADPCM K053260 and K007232 chips
-Sunset Riders: Fixed protection, added controls, finished audio and video
-Implemented zoomed sprites, added to Teenage Mutant Ninja Turtles, Sunset Riders and Nemesis</pre>
<b>17/12/15 - DSP Emulator 0.16b1 source WIP update. Win32 WIP snapshot updated too.</b><br>
<img src='http://img1.imagilive.com/1215/ssriders1.png'></img><img src='http://img1.imagilive.com/1215/ssriders2.png'></img><br><br>
<b>10/12/15 - DSP Emulator 0.16b1 source WIP update and Win32 WIP snapshot.</b><br>
<img src='http://img1.imagilive.com/1215/tmnt1.png'></img><img src='http://img1.imagilive.com/1215/tmnt2.png'></img><br><br>
<b>01/11/15 - DSP Emulator 0.16b1 source WIP update and Win32 WIP snapshot.</b><br><br>
<b>29/10/15 - Released DSP Emulator 0.16 Final.</b> Added Win 32, Win 64, Linux 32 and Linux 64 binary. Added source. Read 'Whats New.txt' or visit wiki for more detailed info.<br><br>
<b>25/10/15 - DSP Emulator 0.16 WIP.</b> Added Renegade driver with sound.<br>
<img src='http://img1.imagilive.com/1015/renegade.png'></img><br><br>
<b>26/09/15 - DSP Emulator 0.16 WIP.</b> Sega Master System console added. About 99% of compatibility.<br>
<img src='http://img1.imagilive.com/0915/sonic2.png'></img><img src='http://img1.imagilive.com/0915/zool.png'></img><br><br>
<b>30/08/15 - DSP Emulator 0.16 WIP.</b> Important changes in snapshot system! Fixed Spectrum and Amstrad CPC snapshot load/save snapshots, more compatible.<br><br>
<b>10/08/15 - DSP Emulator 0.15b3 Final.</b> Please read the docs for more info. Many fixes and enhances.<br><br>
<b>31/05/15</b> - Added Free Kick driver..<br>
<img src='http://img1.imagilive.com/0515/freekick.png'></img><br><br>
<b>12/04/15</b> - Added Gyruss driver..<br>
<img src='http://img1.imagilive.com/0415/gyruss.png'></img><br><br>
<b>31/03/15</b> - Migrated from Google. Published WIP source.<br>
<b>06/02/15</b> - DSP 0.15b2 Final. Windows 32bits and 64bits, Linux 32bits and 64 bits and MAC OSX 32 bits binary.<br>
Many changes, focused on drivers completion (screen rotation, controls, etc.) and stability. Please read the documentation for more information.<br>
Three new drivers: Pleiads (no sound), Snap Jack and Cosmic Avenger.<br>
<br>
<a href='https://drive.google.com/file/d/0B75BlF7Jx3PgVDZTaHdQNDkxS1k/view?usp=sharing'>Windows 0.15b2 Source</a><br><br>
<a href='https://drive.google.com/file/d/0B75BlF7Jx3PgTExlNEJZb0ZNNTg/view?usp=sharing'>Windows 0.15b2 32Bits binary</a><br>
<a href='https://drive.google.com/file/d/0B75BlF7Jx3PgZTZQTkQzWTZXck0/view?usp=sharing'>Windows 0.15b2 64Bits binary</a><br><br>
<a href='https://drive.google.com/file/d/0B75BlF7Jx3PgSFRvaTJja1hlZXc/view?usp=sharing'>Linux 0.15b2 32Bits binary</a><br>
<a href='https://drive.google.com/file/d/0B75BlF7Jx3PgYTgxOEQ4Zkw3SWM/view?usp=sharing'>Linux 0.15b2 64Bits binary</a><br><br>
<a href='https://drive.google.com/file/d/0B75BlF7Jx3PgUmRrdnoyNkRzUlE/view?usp=sharing'>MAC OSX 0.15b2 32bits binary</a><br>

<img src='http://img1.imagilive.com/0215/pleiads.png'><img src='http://img1.imagilive.com/0215/snapjack.png'><br>
<img src='http://img1.imagilive.com/0215/cosmic_avenger.png'><br>

<b>04/12/14</b> - DSP 0.15b2WIP. Windows 32bits, Linux 32bits and 64 bits and MAC OSX 32  bits binary.<br>
<pre>-General<br>
+ Z80: Fixed LDD and LDDR (Was fixed on Spectrum Z80 engine, but I forget to update!)
+ Loading dynamically the necessary libraries. No more errors if the SDL2 library is not present, warns and finishes execution. If Zlib or IPF libraries are not available, do not perform the function but continues execution.
+ Pokey: Started writing chip emulation
+ Lazarus (Linux and OSX)
- Fixed search function within a ZIP, it was doubling the results
- Optional libraries: Zlib and IPF (CAPS Image)
- Needed libraries: SDL2 and SDL2 Mixer
+ Delphi (Windows)
- Optional library: IPF (CAPS Image), the Zlib library is included on Delphi and don't need a external library
- Needed library: SDL2
+ UPD765:
- Fixed length when full track read is selected
- Fixed length when a sector read is selected
- Fixed function that searches for the next id sector ('Tintin on the Moon' loads again on Spectrum +3)
- Fixed when trying to read beyond the end of a track ('Short Circuit', 'Head Over Heels', etc. loads on Amstrad)
- Fixed sector selection when it's deleted and SK is selected
+ IPF: Started writing an interface to the IPF disk format
Amstrad
+ Implemented snapshots. Now load and save in 'SNA' format.
+ Fixed selection of high ROM. If an unmapped ROM is selected by default basic ROM is slected (Fixes 'avant JC 20000', '2112AD', etc.)
+ Some enhancement on Z80 timings, but still are wrong ('Prohibition' loads)</pre>

<strike>Windows 0.15b2WIP 32Bits binary</strike><br>
<strike>Linux 0.15b2WIP 32Bits binary</strike><br>
<strike>Linux 0.15b2WIP 64Bits binary</strike><br>
<strike>MAC OSX 0.15b2WIP 32bits binary</strike><br><br>

<b>06/11/14</b> - DSP 0.15b2WIP. Windows 32bits, Linux 32bits and 64 bits and MAC OSX 32  bits binary.<br>
<pre>-General
+ Small cosmetical details fixes (icons, screen sizes, etc.)
+ Lazarus: Modified the use of the Zlib library, now it links the external library, so compiled objects are no longer needed. Zlib libray must be installed on Linux and OSX (Linux 64bit fails).
+ Simplified the creation of audio emulated device, the audio CPU information is saved internally (number and CPU clock), so it is no longer necessary to add it when initializing a sound chip
+ Simplified keyboard system. It is not based on events to see if the key is pressed or not.
+ M68000: Fixed and added the timings of all opcodes
-Spectrum
+ If a snapshot is loaded and that the maximum speed is set, it's reduced to normal speed
-Amstrad
+ Fixed mode 2 display. I can not change the physical resolution of the screen, because there are games that combine several resolutions in the same frame. It is now the color is estimated from the sum of then two real pixels. (Thanks to cpcbegin)
+ Fixed removal of the IRQ when values are modified in the GA. It fixes audio speed and video timings in some games.
+ M6845 video: The address value is calculated with a table. 32k screen display effect and hardware scrolling now work
-Taito SJ HW
+ Fixed audio
-Zaxxon HW
+ Congo: Fixed audio
-Contra
+ Fixed video</pre>

<strike>Windows 0.15b2WIP 32Bits binary</strike><br>
<strike>Linux 0.15b2WIP 32Bits binary</strike><br>
<strike>Linux 0.15b2WIP 64Bits binary</strike><br>
<strike>MAC OSX 0.15b2WIP 32bits binary</strike><br><br>
<img src='http://img1.imagilive.com/1114/mode2.png'><img src='http://img1.imagilive.com/1114/babyjo.png'><br>
<img src='http://img1.imagilive.com/1114/last_mission.png'><img src='http://img1.imagilive.com/1114/prehistorik2.png'><br>
<img src='http://img1.imagilive.com/1114/satan.png'><br>

<b>16/10/14</b> - Released DSP 0.15b1. Windows and Linux (32bits and 64 bits) binary and source. Added 32bits MAC OSX binary.<br>
Update main systems to SDL v2, more speed. Many fixes and updates (read documentation for more details)<br><br>
<a href='https://drive.google.com/file/d/0B75BlF7Jx3PgNDJuZmthWXBuZW8/view?usp=sharing'>DSP Source 0.15b1</a><br>
<a href='http://www.libsdl.org/'>Windows SDL v2 library Download</a><br>
<strike>Windows 0.15b1 32Bits binary</strike><br>
<strike>Windows 0.15b1 64Bits binary</strike><br>
<strike>Linux 0.15b1 32Bits binary</strike><br>
<strike>Linux 0.15b1 64Bits binary</strike><br>
<strike>Linux 0.15b1 OSX 32Bits binary</strike><br><br>
<img src='http://img1.imagilive.com/1014/foodfight.png'><br>

<b>27/07/14</b> - Released DSP 0.15. Windows and Linux (32bits and 64 bits) binary and source...<br>
Many changes, added 15 new games... For more info, please read the documents.<br>
Due the changes in google projects, now I'm ussing google drive for downloads.<br><br>
<a href='https://drive.google.com/file/d/0B75BlF7Jx3PgeTBGR3Jya1JDMFk/edit?usp=sharing'>DSP 0.15 Source</a><br>
<strike>Windows 0.15 32Bits binary</strike><br>
<strike>Windows 0.15 64Bits binary</strike><br>
<strike>Linux 0.15 32Bits binary</strike><br>
<strike>Linux 0.15 64Bits binary</strike><br><br>
<img src='http://img1.imagilive.com/0714/alien.png'>
<img src='http://img1.imagilive.com/0714/blockuot.png'><br>
<img src='http://img1.imagilive.com/0714/congo.png'>
<img src='http://img1.imagilive.com/0714/ddragon3.png'><br>
<img src='http://img1.imagilive.com/0714/dragonb.png'>
<img src='http://img1.imagilive.com/0714/elevator.png'><br>
<img src='http://img1.imagilive.com/0714/hharry.png'>
<img src='http://img1.imagilive.com/0714/jungle.png'><br>
<img src='http://img1.imagilive.com/0714/motos.png'>
<img src='http://img1.imagilive.com/0714/rtype2.png'><br>
<img src='http://img1.imagilive.com/0714/spang.png'>
<img src='http://img1.imagilive.com/0714/tower.png'><br>
<img src='http://img1.imagilive.com/0714/vulgus.png'>
<img src='http://img1.imagilive.com/0714/wb3.png'><br>
<img src='http://img1.imagilive.com/0714/zaxxon.png'><br>

<b>11/04/13</b> - Released 0.14b3 WIP Binary for Windows 32bits and Mac OS X 32bits. Tired that I can't find a program to calibrate the Joystick in OS X, I make my own calibration system in configuration menu for all versions. Also change SDL video system in OS X to X11 and speed gets dramatically enhanced.<br>

<b>08/04/13</b> - Released 0.14b2 Binary for Mac OS-X 32bits alpha. Please send feedback!!<br>

<b>07/04/13</b> - Released 0.14b2 Source Fix. Fixed Lazarus Windows 32bits compilation<br>

<b>04/04/13</b> - Released 0.14b2. Windows and Linux (32bits and 64 bits) binary and source... Taito madness!<br>
New quick snapshot system you can save two snapshots pressing F7 and F8 and recover them with F9 and F10. Read text files for implemented drivers so far.<br>
Fixed 'Kangaroo' sound and graphics. Added Taito drivers 'Rainbow Islands', 'Rainbow Islands Extra', ' Volfied' and 'Operation Wolf' (using mouse as gun).<br>
Small fixes here and there... Read text files for more info<br>
<img src='http://img1.imagilive.com/0413/rainbow.png'>
<img src='http://img1.imagilive.com/0413/rainbow_extra.png'><br>
<img src='http://img1.imagilive.com/0413/volfied.png'>
<img src='http://img1.imagilive.com/0413/opwolf.png'><br>

<b>26/02/13</b> - Released 0.14b1. Windows and Linux (32bits and 64 bits) binary and source.<br>
At last compiled a Windows 64bits full functional binary.<br>
Started the conversion to classes, all CPU's and some sound chips already done.<br>
Improved NEC CPU, 'R-Type' now works (no sound, but playable), fixed many bugs related to the palette and scroll, fixed sprites priorities in Gaelco HW (not implemented in MAME), added 'Kangaroo', 'Bionic Commando' and 'WWF Super Stars'.<br>
<img src='http://img1.imagilive.com/0213/wwf_super_stars.png'>
<img src='http://img1.imagilive.com/0213/bionic_commando.png'><br>
<img src='http://img1.imagilive.com/0213/kangaroo.png'><br>

<b>29/09</b> - Released 0.14. Windows binary and source.<br>
This release is focussed in stability. Thanks to FastMM4 library all memory leaks are removed. Also fixed samples, improved TAP/TZX library (added 8 bits symbols support), fixed many sound problems when closing drivers, and fixed sprites in some drivers.<br>
Also improved Spectrum border full emulation (thanks to azesmbog[@]mail.ru) and render speed.<br>
Finally added a preliminary 'Congo' driver<br>
Updated Wiki to 0.14 version<br>
<img src='http://img1.imagilive.com/0912/dsp_014.png'><br>

<b>09/09</b> - Parachute Simulator and mariobros emulator for iPhone/iPad.<br>
These last days of holidays, I've done some testing with Delphi XE2 and FireMonkey, which means programs for the iPhone/iPad.<br>
I tried to compile the simulator 'Parachute' (derived from my Lazarus proyect + MADrigal simulator) and the emulator 'mariobros' (derived from my source of DSP emulator).<br>
With the simulator 'Parachute' I haven't had many problems to run, and works quite well with sound.<br>
I can't say the same of the 'mariobros' emulator, in this case if I had some problems, especially with speed. I can't get more than 30fps on the iPhone, but if 60 fps on the iPad. So far, this first version has no sound, and the controls are not too good implemented, but to be a first test is not bad at all...<br>
You can download them in 'Downloads' section, but you need a jailbreak iPhone/iPad.<br>
<img src='http://img1.imagilive.com/0912/parachute.PNG'><br>
<img src='http://img1.imagilive.com/0912/mariobros.PNG'><br>

<b>12/07</b> - Released 0.12b5 final. Linux, Windows binary and source.<br>
Fixed some arcade drivers issues and full rewrited NES and GameBoy/Gameboy Color.<br>
<img src='http://img1.imagilive.com/0712/gb_hunck.png'>
<img src='http://img1.imagilive.com/0712/gb_wario3.png'><br>
<img src='http://img1.imagilive.com/0712/gbc_1942.png'>
<img src='http://img1.imagilive.com/0712/gbc_dalm.png'><br>
<img src='http://img1.imagilive.com/0712/nes_castle2.png'>
<img src='http://img1.imagilive.com/0712/nes_gauntlet2.png'><br>
<img src='http://img1.imagilive.com/0712/nes_kirby.png'><br>

<b>28/04</b> - Released 0.12b4 final. Windows binary and source.<br>
Added Gaelco's 'Squash' and 'Boimechanical Toy', 'Bagman', 'Super Bagman' and Chip8/Super Chip8 simulator.<br>
Added dipswitch configuration window for arcade drivers, and a big change on digital sound emulators, sound quality is very improved. Take a look to 'readme.txt'.<br>
<img src='http://img1.imagilive.com/0412/dipsw.png'><br>
<img src='http://img1.imagilive.com/0412/squash.png'>
<img src='http://img1.imagilive.com/0412/biomtoy.png'><br>
<img src='http://img1.imagilive.com/0412/bagman.png'>
<img src='http://img1.imagilive.com/0412/sbagman.png'><br>
<img src='http://img1.imagilive.com/0412/chip8.png'><br>

<b>08/03</b> - Now thanks to Luca Antignano and it's simulators, I've ported 'Parachute Simulator' to Lazarus/FPC and SDL sound. You can download source, Windows 32/64 bits binary and Linux 32/64 bits binary.<br>
<img src='http://img1.imagilive.com/0312/parachute.jpg'>

<b>07/03</b> - Released 0.12b3 final. Windows binary, Linux 32/64bits binary and source code available.<br>
Added 'Arabian', 'DigDug', 'Donkey Kong Junior', 'Donkey Kong 3' and 'Pirate Ship Higemaru'.<br>
Added NES driver to Lazarus, so all system are both in Delphi and Lazarus.<br>
Added sound to NES, many fixes and changes in many drivers.<br>
<img src='http://img1.imagilive.com/0312/arabian.png'>
<img src='http://img1.imagilive.com/0312/digdug.png'><br>
<img src='http://img1.imagilive.com/0312/dkong3.png'>
<img src='http://img1.imagilive.com/0312/dkongjr.png'><br>
<img src='http://img1.imagilive.com/0312/higemaru.png'><br>

<b>22/12</b> - Released 0.12b2 final. Windows binary and source available.<br>
Added 'Diet Go Go' and 'Act-Fancer Cybernetic Hyper Weapon'.<br>
Fixed 'P47 The Phantom Fighter', 'Rod-Land' and 'Saint Dragon'. Fixed some bugs in Deco0 hardware and Caveman Ninja Hardware video.<br>
<img src='http://img1.imagilive.com/1211/robocop2.png'>
<img src='http://img1.imagilive.com/1211/dietgogo.png'><br>
<img src='http://img1.imagilive.com/1211/act_fancer.png'>
<img src='http://img1.imagilive.com/1211/rodland.png'><br>
<img src='http://img1.imagilive.com/1211/saint_dragon.png'><br>

<b>27/11</b> - Another WIP version released. Windows binary and source available.<br>
More opcodes for Hu6280 CPU and internal timer.<br>
Added 'Tumble Pop', 'Funky Jet', Super Burger Time' and 'Caveman Ninja'.<br>
<img src='http://img1.imagilive.com/1111/cavemanninja.png'>
<img src='http://img1.imagilive.com/1111/funkyjet.png'><br>
<img src='http://img1.imagilive.com/1111/tumblepop.png'>
<img src='http://img1.imagilive.com/1111/superbtime.png'><br>

<b>20/11</b> - New WIP version released!!! Windows binary and source available.<br>
Added Hu6280 CPU, fixed some video issues in 'Mysterious Stone' and 'Jr. Pacman' and added Deco0 Hardware, wich include 'Robocop', 'Baddudes' and 'Hippodrome'.<br>
<img src='http://img1.imagilive.com/1111/hippodrome.PNG'>
<img src='http://img1.imagilive.com/1111/robocop.png'><br>
<img src='http://img1.imagilive.com/1111/baddudes.png'><br>

<b>06/11</b> - DSP Emulator 0.12b1 Released<br>
Windows binary and source available.<br>
Rewrited Z80-PIO and Z80-CTC devices.<br>
Support for AMX Mouse with emulated Z80-PIO (not simulated) and support for Kempston Mouse in Spectrum driver<br>
Added sound to Starforce and fixed small video issues<br>
Added sound to Sega System 16A<br>
Rewrited Sega System 1/2 driver, fixed all video, sprites and sound issues. Added driver for Choplifter, Mister Viking, Sega Ninja, Up'n Down and Flicky<br>
Implemented sprites effects in Ninja Kid II<br>
<img src='http://img1.imagilive.com/1111/choplifter.png'>
<img src='http://img1.imagilive.com/1111/mrviking.png'><br>
<img src='http://img1.imagilive.com/1111/seganinja.png'>
<img src='http://img1.imagilive.com/1111/updown.png'><br>
<img src='http://img1.imagilive.com/1111/flicky.png'><br>

<b>24/10</b> - Released DSP Emulator Linux Binary 0.12<br>

<b>13/10</b> - DSP Emulator 0.12 Released<br>
Windows binary and source available.<br>
At last ported to Lazarus Spectrum and Amstrad drivers (only remains NES), big changes on source code, ported many functions to Lazarus (ZIP, ZLIB, files, INI, etc).<br>
Fixed CPU bugs, sound bugs, rewrited PPI 8255...<br>
Almost rewrited the Amstrad CPC driver, improved video (still not perfect), sound, stability, and disc copy protections.<br>
Added drivers for 'Ikari III - The rescue', 'Search and Rescue', 'Twin Cobra', 'Flying Shark' and 'Jr. Pacman'.<br>
<img src='http://img1.imagilive.com/1011/ikari3.PNG'>
<img src='http://img1.imagilive.com/1011/search_rescue.PNG'><br>
<img src='http://img1.imagilive.com/1011/twincobra.PNG'>
<img src='http://img1.imagilive.com/1011/fshark343.PNG'><br>
<img src='http://img1.imagilive.com/1011/jrpacman.PNG'><br>


<b>08/08</b> - Updated DSP Emulator Linux Binary to 0.11b4!<br>

<b>04/08</b> - DSP Emulator 0.11b4 Released<br>
Windows binary and source available, last update before 0.12.<br>
Big source changes, code cleaning on all arcade drivers.<br>
At last 'Galaga' works and updated Galaxian driver fixing many bugs.<br>Added drivers for 'Scramble , 'Super Cobra', 'Amidar' and 'Pengo'.<br>Small updates in Coleco, NES and Amstrad drivers.<br>Big update on Spectrum side, many bug fixes and a new snapshot/tape load window.<br>
<img src='http://img1.imagilive.com/0811/pengo.PNG'>
<img src='http://img1.imagilive.com/0811/galaga.PNG'><br>
<img src='http://img1.imagilive.com/0811/amidar.PNG'>
<img src='http://img1.imagilive.com/0811/scobra.PNG'><br>
<img src='http://img1.imagilive.com/0811/scramble.PNG'>
<img src='http://img1.imagilive.com/0811/sp_tape_load.PNG'><br>

<b>24/06</b> - Updated Wiki to DSP 0.11b3<br>

<b>08/06</b> - DSP Emulator 0.11b3 Released<br>
Released DSP 0.11b3. Windows binary and source available (no WIP this time!).<br>
This has been one of the most interesting versions. Many updates, more speed on all drivers, a system to cache the graphics drivers that change dynamically the palette, better directory system...<br>
'Black Tiger' colors are corrected and added some priorities (the bridge of the screen 3) that MAME does not emulate yet!<br>
<img src='http://img1.imagilive.com/0611/blktiger015.PNG'><br>
Improvements in many drivers, priorities, stability, graphical glitches, but the most significant advances have been the drivers 'Sega System 16A' and 'Irem M72'.<br>
'Shinobi' work at real speed, fixed many graphical glitches.<br>
'R-Type' begins to work better, added controls, raster IRQ and fixed sprites.<br>
And added the driver 'Time Pilot' with sound.<br>
<img src='http://img1.imagilive.com/0611/rtype.PNG'>
<img src='http://img1.imagilive.com/0611/timepilot.PNG'><br>

<b>10/05</b> - DSP Emulator 0.11b2<br>
Released DSP 0.11b2 stable version. Binary and source available.<br>
Many big changes in sound system and graphics system, fixed some CPU's issues, optimizations here and there, fixed some graphics in CPS1, fixed Bubble Bobble screen... and other fixes in some drivers.<br>
Added 'SNK 68k' hardware, drivers for 'P.O.W. - Prisoners of War' and 'Street Smart' with sound.<br>
Added 'Jaleco MegaSystem 1' hardware, drivers for 'P47 - Phantom Fighter', 'Rodland' and 'Saint Dragon'.<br>
<img src='http://img1.imagilive.com/0511/pow.png'>
<img src='http://img1.imagilive.com/0511/streetsmart.png'><br>
<img src='http://img1.imagilive.com/0511/p47.png'><br>

<b>18/04</b> - DSP Emulator 0.11b2 WIP 17/04<br>
Long time since last WIP! Now released DSP 0.11b2 WIP 17/04, binary and source.<br>
Big changes on timer engine, cpu engine (added states for the interrupts of all CPUs) and new sound engine (more speed for all drivers), fixed main window resize mess.<br>
New ADPCM chip 'UPD7759', fixed OKI6295 sound quality.<br>
Fixed 'Prehistoric Isle in 1930' driver and now works fine with sound, added ADPCM to 'Combat School', fixed M68705 in 'Xain'd Sleena', fixed sound in '1942' and NMK16 driver ('Saboten Bombers' and 'Bombjack Twin') and small fixes here and there in all drivers...<br>
<img src='http://img1.imagilive.com/0411/prehisle.png'><br>

<b>27/03</b> - DSP Emulator 0.11b2 WIP 27/03<br>
DSP 0.11b2 WIP released, binary and source.<br>
Added 'Combat School' and 'Heavy Unit'. Many changes in Intel MCS51, added 'Pandora' chip and Konami K007121<br>
<img src='http://img1.imagilive.com/0311/combatsc.png'>
<img src='http://img1.imagilive.com/0311/hvyunit.png'><br>

<b>11/03</b> - Siete a�os<br>
Hoy hace siete a�os del atentado de Madrid/Atocha...<br>
<img src='http://img1.imagilive.com/0311/in_memoria.png' alt='En memoria de las v�ctimas del 11-M' title='En memoria de las v�ctimas del 11-M'><br>

<b>10/03</b> - DSP Emulator 0.11b1<br>
DSP 0.11b1 stable release. Released both binary and source.<br>
Added 'Mario Bros.' with partial sound emulation and 'Solomon Key' driver with sound.<br>
<img src='http://img1.imagilive.com/0311/mariobros.png'>
<img src='http://img1.imagilive.com/0311/solomon.png'><br>

<b>07/03</b> - DSP Emulator 0.11b1 WIP 07/03<br>
New release DSP 0.11b1 WIP binary and source.<br>
Fixed sprite priorities in CPS1, fixed some scroll bugs and added 'Pacland' driver with sound.<br>
<img src='http://img1.imagilive.com/0311/pacland.PNG'><br>

<b>01/03</b> - DSP Emulator 0.11b1 WIP 01/03<br>
After a short holidays, another release of DSP 0.11b1 WIP binary and source.<br>
Fixed mouse use in 'Spectrum', improved joystick control, fixed graphics in 'Legend of Kage', fixed sprites in 'Rolling Thunder' and fixed scroll in 'Repulse'.<br>
Added 'The NewZealand Story' and 'Insector X' drivers with sound.<br>
<img src='http://img1.imagilive.com/0311/tnzs.png'>
<img src='http://img1.imagilive.com/0311/insectorx.png'><br>

<b>21/02</b> - DSP Emulator 0.11b1 WIP 20/02<br>
Another release of DSP 0.11b1 WIP binary and source.<br>
Added new CPU MCS51 serires.<br>
Added MCU i8751 to Black Tiger (removed protection patches).<br>
Added 'Repulse' driver with sound.<br>
<img src='http://img1.imagilive.com/0211/repulse.png'><br>

<b>18/02</b> - DSP Emulator 0.11b1 WIP 17/02<br>
Another release of DSP 0.11b1 WIP binary and source.<br>
Namco System 86 cleans, optimized HD6309 CPU and fixed M6809 DAA opcode. Added 'Roc'n Rope' driver with sound.<br>
<img src='http://img1.imagilive.com/0211/rocnrope.png'><br>

<b>15/02</b> - DSP Emulator 0.11b1 WIP 15/02<br>
Another DSP 0.11b1 WIP binary and source.<br>
More HD63701 fixes and opcodes. Added Namco System 86, 'Rolling Thunder', 'Hopping Mappy' and 'Sky Kid Deluxe'.<br>
<img src='http://img1.imagilive.com/0211/rthunder.png'>
<img src='http://img1.imagilive.com/0211/hopmappy.png'>
<img src='http://img1.imagilive.com/0211/skykiddx.png'><br>

<b>07/02</b> - DSP Emulator 0.11b1 WIP 06/02<br>
Released DSP 0.11b1 WIP binary and source, fixed Breakthru hardware, added Sky Kid. Many changes on HD63701, added OCI timer, added many opcodes and some bug fixes.<br>
<img src='http://img1.imagilive.com/0211/Sky_Kid.png'><br>

<b>31/01</b> - Preview Images for DSP 0.11<br>
Thanks to Davide 'Turrican' Michelini, now we have all preview images for DSP 0.11 in download section. Thanks for your good job!<br>
<img src='http://img1.imagilive.com/0111/preview.jpg'><br>

<b>14/01</b> - DSP Emulator 0.11<br>
Relased the estable version of the emulator. Released source and Windows Binary, and updated documentation. This weekend linux release.<br>
Added 'UPL' driver for 'Ninja Kid II', 'Ark Area' and 'Mutant Night'.<br>
<img src='http://img1.imagilive.com/0111/ninjakid2.PNG'>
<img src='http://img1.imagilive.com/0111/arkarea.PNG'>
<img src='http://img1.imagilive.com/0111/mutantnight.PNG'><br>

<b>08/01</b> - DSP Emulator 0.10b4 WIP 08/01<br>
First update of the year and last beta stage. Updated Windows binary and source.<br>
Added M6805 CPU so 'Legend of Kage', 'Tiger Heli', 'Slap Fight' and 'Xain'd Sleena' uses original ROMs with no patches.<br>
Added a new driver 'Pang' with partial sound, only OKI 6295 missing YM2413<br>
<img src='http://img1.imagilive.com/0111/pang.PNG'><br>

<b>31/12</b> - DSP Emulator 0.10b4 WIP 31/12<br>
Oppps! One more update... Fixed sprites and sound speed in 'Time Pilot '84', and added one more driver 'Tutankham'.<br>
<img src='http://img1.imagilive.com/1210/tutankham.PNG'><br>

<b>30/12</b> - DSP Emulator 0.10b4 WIP 30/12<br>
Last update this year, and maybe this week. Some bugs fixed on M6809, and added 'Time Pilot '84' with sound.<br>
<img src='http://img1.imagilive.com/1210/tp84.PNG'><br>

<b>27/12</b> - DSP Emulator 0.10b4 WIP 27/12<br>
Great improvements on System16A driver. Fixed colors, sprites, tiles, chars, priorities and controls, but no sound (yet). Added 'Alex Kidd' and 'Fantasy Zone'<br>
<img src='http://img1.imagilive.com/1210/shinobi.PNG'>
<img src='http://img1.imagilive.com/1210/alexkid.PNG'><br>
<img src='http://img1.imagilive.com/1210/fantzone.PNG'><br>

<b>24/12</b> - Merry Christmas and a happy New Year!!<br><br>
<img src='http://img1.imagilive.com/1210/santa3c4.gif'><br>

<b>19/12</b> - DSP Emulator 0.10b4 WIP 19/12<br>
New WIP source and binary.<br>
More Lazarus proyect updates added 'Main Configuration' and 'Drivers List' windows.<br>
Many 'sanity checks' for Spectrum snapshot and ROM loads to avoid hangs, added snapshot load and save of the new models added.<br>
More Sega System16a improves, 'Shinobi' now shows sprites.<br>

<b>12/12</b> - DSP Emulator 0.10b4 WIP 12/12<br>
New WIP source/binary release (more changes on source code!).<br>
Updated Lazarus proyect with all new drivers, some bugfixes and many changes on source code (Added 'About' window).<br>
Released a Linux and Windows WIP binary.<br>
Some Spectrum regresion fixes ('Cobra' works again and the 'Ultracargas' loads again), fixed hangs when samples are not present and a skeleton driver for Sega System16a with Shinobi showing text layer.<br>

<b>07/12</b> - DSP Emulator 0.10b4 WIP 07/12<br>
New WIP source only release (big changes on source code).<br>
Working on a better description of the main functions, changed and created code units more descriptives.<br>
There is no binary release because the changes are on source only (there is no new drivers or new features).<br>

<b>02/12</b> - DSP Emulator 0.10b4 WIP 02/12<br>
New WIP release. Many thanks to NesBr!<br>
"Just" a code clean, and some bug fixes (Now DSP compiles in Delphi 2010 but SDL window don't work).<br>
Added some Spectrum versions and fixed some drivers. Changed Spectrum ROMs added the files from this page <a href='http://www.shadowmagic.org.uk/spectrum/roms.html'><a href='http://www.shadowmagic.org.uk/spectrum/roms.html'>http://www.shadowmagic.org.uk/spectrum/roms.html</a></a>. Thanks to Philip Kendall.<br>

<b>23/11</b> - DSP Emulator 0.10b3<br>
Added source and Windows binary of final beta release.<br>
Included all changes of WIP versions, finally a GameBoy/GameBoy Color emulation and many other small changes.<br>
One of those changes is a better driver list. Now is sorted alphabetically, and shows the information better than before.<br><br>
<img src='http://img1.imagilive.com/1110/gb2.PNG'>
<img src='http://img1.imagilive.com/1110/gb1.PNG'><br>

<b>26/09</b> - DSP Emulator 0.10b3 WIP 26/09<br>
Added new translation: Italian (thanks to Davide Michelini!)<br>
CPS1: Added QSound chip<br>
Added 'Cadillacs and Dinosaurs' and 'The Punisher'<br>
Some screen shots...<br>
<img src='http://img1.imagilive.com/0910/dino.PNG'>
<img src='http://img1.imagilive.com/0910/punisher.PNG'><br>

<b>21/09</b> - DSP Emulator 0.10b3 WIP 20/09<br>
Fixed Spectrum driver initialization, added some opcodes to M68000<br>
CPS1: Added priorities between sprites and planes, fixed sprites, fixed transparent tiles and added Strider, Three Wonders, Captain Commando, Knights of the Round and SF2' Champion Edition.<br>
Some more screen shots...<br>
<img src='http://img1.imagilive.com/0910/captcomm.PNG'>
<img src='http://img1.imagilive.com/0910/3wonders.PNG'><br>
<img src='http://img1.imagilive.com/0910/strider.PNG'>
<img src='http://img1.imagilive.com/0910/sf2ce.PNG'><br>
<img src='http://img1.imagilive.com/0910/knights.PNG'><br>

<b>14/09</b> - DSP Emulator 0.10b2 Released!<br>
After two months of hard real life work, there is another release of DSP emulator (there is no WIP this time).<br>
This release is amazing because there is a new CPS1 driver working! Many thanks to Tom Walker who sent me his driver to understand this arcade.<br>
There are other remarcable stuff, I fixed many M68000 bugs, making almost all games playable, fixed Big Karnak video added Thunder Hoop to this Gaelco Hardware and added Cabal.<br>
And now some screen shots...<br>
<img src='http://img1.imagilive.com/0910/ghouls.PNG'>
<img src='http://img1.imagilive.com/0910/ffight.PNG'><br>
<img src='http://img1.imagilive.com/0910/sf2.PNG'>
<img src='http://img1.imagilive.com/0910/kod.PNG'><br>
<img src='http://img1.imagilive.com/0910/bkarnak.PNG'>
<img src='http://img1.imagilive.com/0910/thoop.PNG'><br>
<img src='http://img1.imagilive.com/0910/cabal.PNG'><br>
You can download binary and source.<br><br><br>

<b>14/07</b> - DSP Emulator 0.10b1 FINAL<br>
No new drivers added, but many changes in many drivers.<br>
Added sound in Donkey Kong, Galaxian (partial) with drivers, several changes in sample system.<br>
Added functions to avoid sprite cuts (many drivers to mention)<br>
Added general scroll in all remain drivers, addeded functions to support partial screen scroll<br>
You can download binary and source.<br><br><br>

<b>12/07</b> - New World Champion<br>
<b>Finally, after many years, Spain won the World Football Champion South Africa 2010!</b><br>
<img src='http://img1.imagilive.com/0710/Bandera_Espana.png'><br>
As we sing here: 'Yo soy Espa�ol, Espa�ol, Espa�ol!!!'<br>
The joy has overflowed, people have gone mad, and for a while we forget about the damn CRISIS<br>

<b>30/06</b> - DSP Emulator 0.10b1 WIP 29/06<br>
General:<br>
UPD765 - Added some of the specifications EDSK v5: added emulation of the 'weak' sectors (multiple copies of the same sector) and corrected the specification of the 32K sectors ('Corsarios', 'MOT', 'Robocop', 'Buggy Boy', etc.).<br>
Spectrum+3:<br>
Understood in detail SpeedLock+3 copy protection. If the disk image does not include copies of the 'weak' sectors, the emulator simulate them. Understood also the 32Kb sector Opera disk protection. Modified image of 'MOT' for testing and is working properly.<br>
Pacman:<br>
Cleaned and simplified the video system. Fixed a stupid bug, not counted time spent by each frame (hangs after pause and freezes after playing for a while).<br>

<b>28/06</b> - DSP Emulator 0.10b1 WIP 27/06<br>
Added 'The Legend of Kage' using bootleg version (missing M68705 CPU).<br>
Revised all CPUs, now use smallint and shortint to evaluate the sign, removing an 'if' sentence.<br>
'Bubble Bobble' : Fixed a bug in the color palette and rewrited video renderer, now uses the video PROM, this fixes some bugs and graphical effects (like background color).<br>

<img src='http://img1.imagilive.com/0610/lkage.PNG'><br>

<b>23/06</b> - DSP Emulator 0.10b1 WIP 22/06<br>
Added Slap Fight and Tiger Heli (same hardware) both using bootleg version (missing M68705 CPU). Added M6801 CPU to Bubble Bobble, now MCU is emulated not simulated.<br>

<img src='http://img1.imagilive.com/0610/slapfight.PNG'>
<img src='http://img1.imagilive.com/0610/tigerheli.PNG'><br>

<b>16/06</b> - DSP Emulator 0.10b1 WIP 15/06<br>
Many changes today!.<br>
Added ADPCM chip OKI 6295, so Double Dragon II has ADPCM sound. Revised all drivers for add reset and shutdown for all devices that driver initiates (improved stability).<br>
-Black Tiger: Reimplemented the driver to display the background. Now, does not slow down when changes intensively the palette.<br>
-Tecmo Hardware: Changed the name of the driver from Rygar to Tecmo Hardware, fixed sprites of 32x32 (rewrited sprite system), added second player controls, amplified ADPCM sound. Added Silk Worm driver with sound.<br>
-Popeye: Fixed background activation<br>
-Psychic 5: fixed sprite position by 1 pixel<br>
-Rally X Hardware: Fixed video priorities, the sprites are cleared correctly<br>
-Toki: Added ADPCM sound, does not work quite right<br>
-NMK 16: Added ADPCM sound, does not work quite right too...<br>
-1942: Fixed bug on background buffer<br>
<img src='http://img1.imagilive.com/0610/silkworm.png'><br>

<b>08/06</b> - DSP Emulator 0.10b1 WIP 08/06<br>
Speed up 'Mr. Do!' video render, added 'The Glob', 'Super Glob' and 'Double Dragon II - The Revenge' drivers.<br>
<img src='http://img1.imagilive.com/0610/ddragon2.PNG'>
<img src='http://img1.imagilive.com/0610/glob.PNG'>
<img src='http://img1.imagilive.com/0610/superglob.PNG'>

<b>06/06</b> - DSP Emulator 0.10b1 WIP 06/06<br>
Fixed small bug on background in Double Dragon driver, added Mr. Do! driver with sound.<br>
<img src='http://img1.imagilive.com/0610/mrdo.PNG'>

<b>05/06</b> - DSP Emulator 0.10b1 WIP 05/06<br>
One of my most wanted drivers at last is emulated.<br>
Added Double Dragon with ADPCM and sound, added HD6309 and HD63701 CPUs, optimized M6809 CPU and fixed FIRQ and IRQ bug.<br>
<img src='http://img1.imagilive.com/0610/ddragon.PNG'>

<b>01/06</b> - DSP Emulator 0.10b1 WIP 01/06<br>
Added Super Real Darwin, and implemented generic scroll in Popeye.<br>
<img src='http://img1.imagilive.com/0610/srdarwin.PNG'>

<b>30/05</b> - DSP Emulator 0.10b1 WIP 30/05<br>
Added Break Thru and Darwin 4078 both with sound.<br>
<img src='http://img1.imagilive.com/0510/break_thru.PNG'>
<img src='http://img1.imagilive.com/0510/darwin.PNG'><br>

<b>28/05</b> - DSP Emulator 0.10 final release.<br>
Released binary and source of the new version.<br>
Added preliminary NEC v20/v30/v33 CPU, Pac-man enhance memory map, added Ms. Pac-Man driver, fixed JumpBug, fixed Lady Bug and New Rally X, added preliminary ADPCM sound for Trojan, added driver for R-Type (without sound and controls), and of course all the changes from 0.9b5.<br>
<img src='http://img1.imagilive.com/0510/mspacman.png'><br>

<b>28/04</b> - Emulator progress.<br>
I'm sorry about the lack of updates, but real life leaves you sometimes exaust (and even more if you get sick). Here is a picture of my next target:<br>
<img src='http://img1.imagilive.com/0410/rtype.PNG'>


<b>12/04</b> - DSP Emulator 0.9b5 WIP 12/04 released.<br>
<b>At last BubbleBobble has sound!</b><br>
Many bugs fixed on YM2203 and YM3812 timers (finally undestood how they work!). Many drivers work with correct speed with no CPU clock hack. Most obiuos is 'Toki', now shoot sound, jump sound, etc sound at correct speed. Removed hacks from 'Toki', 'Wardner', 'ShootOut', 'SnowBros', 'Express Raider' and many others.<br>
Added driver for 'Circus Charlie' and 'Iron Horse', both with sound.<br>
<img src='http://img1.imagilive.com/0410/circuscharlie.PNG'>
<img src='http://img1.imagilive.com/0410/ironhorse.PNG'><br>

<b>05/04</b> - DSP Emulator 0.9b5 WIP 05/04 released.<br>
Finished input system, you can choose between connected joysticks, reconfigure buttons, redefine keyboard, select keyboard or joystick, etc. Go to 'Options -> Configuration -> Input'.<br>
Added driver for 'Jail Break' with sound.<br>
Almost finished WIP stage, 'just' try to port everything to Linux.<br>
<img src='http://img1.imagilive.com/0410/jailbreak.PNG'><br>

<b>03/04</b> - DSP Emulator 0.9b5 WIP 03/04 released.<br>
Almost finished input system, you can select any joystick for both players, only missing reconfigure buttons.<br>
Fixed 'Shoot Out' and 'Express Raider' coins<br>
Added driver for '1942' and inside Gun.Smoke driver added '1943: Battle of Midway' and '1943 Kai: Midway kaisen'.<br>
<img src='http://img1.imagilive.com/0410/1942.PNG'> <img src='http://img1.imagilive.com/0410/1943.PNG'> <img src='http://img1.imagilive.com/0410/1943kai.PNG'><br>

<b>31/03</b> - DSP Emulator 0.9b5 WIP 30/03 released.<br>
Continue improving input system, added joystick, by now you can select only the first joystick (even you have more, and it's listed in the configuration menu).<br>
Reviewed all drivers and added all entries (second coin, start and player).<br>
Added controls in Tehkan Worldcup, and now it's playable.<br>

<b>26/03</b> - DSP Emulator 0.9b5 WIP 26/03 released.<br>
Improved keyboard system, one of the most wanted changes. Now the keys can be redefined (general configuration menu) and added second player controls, and two players can play together (BubbleBobble, ExedExes, etc). The joystick is disabled for now due to internal changes. Reviewing all drivers to add all entries (second coin, start and player).<br>
Also added Gun.Smoke and added many opcodes to TMS-32010 CPU, you can finish Wardner now.<br>
<img src='http://img1.imagilive.com/0310/gunsmoke.PNG'><br>

<b>16/03</b> - DSP Emulator 0.9b5 WIP 15/03 released.<br>
Added Exed Exes, preliminary driver for Big Karnak and small fixes for TMS-32010 CPU.<br>
<img src='http://img1.imagilive.com/0310/exedexes.PNG'><br>

<b>15/03</b> - I'm sorry, but DSP WIP will be delayed some days.<a href='http://www.fallasfromvalencia.com'> Here in Valencia we are celebrating Fallas 2010</a>, up to 20/03, at last some holidays!! Maybe I release a new version before weekend... but I don't know.<br>

<b>09/03</b> - DSP Emulator 0.9b5 WIP released.<br>
<b>Finally I found the huge memory reservation bug!.</b> It was the TAPE module, that reserves 12288 (tape blocks) X 131070 (size of block)=1,6Gb of RAM! Now DSP uses pointers, and reserve memory as it's needed (I think it was when added PZX support). Thanks to Davide Michelini (and some forums) to point me to this bug.<br>
I also fixed the sprites in Wardner.<br>
<img src='http://img1.imagilive.com/0310/wardnerd78.PNG'><br>

09/03 - DSP Emulator 0.9b4 for Linux released. Remember this is a WIP version.<br>
<br>
07/03 - DSP Emulator 0.9b4 Released. This final release added TMS-32010 CPU, and one of my favorites arcades Wardner.<br>
<br>
01/03 - Added more M680X opcodes, added drivers for: Spelunker, Spelunker II, Lode Runner, Lode Runner II and Knuckle Joe. Fixed some small bugs.<br>
<br>
This is the last week of WIP, this weekend the final relase of beta 4.<br>
<br>
And now some coding tips: Some days ago reading some forums, I read that DSP consumes so much virtual memory, and testing much deeper I get a surprise... DSP reserves 1,5Gb of virtual RAM! (but doesn't uses it). I compiled DSP with Delphi 2010 and... the same problem! I tested a 'hello world' program and... the same occurs! It's incledible! Delphi reserves a huge virtual memory space without use! This is a Delphi bug, because compiling DSP with Lazarus everything it's OK. I will do more testing, but any help about this is wellcome.<br>
<br>
23/02 - Fixed some bugs on M6800 CPU, added ADPCM to KungFu Master (sound it's more clean now)<br>
<br>
22/02 - Added M6800 CPU series, so KungFu Master have sound (only missing ADPCM)<br>
<br>
15/02 - Saboten Bombers: working 100% only missing sound. Added Bomb Jack Twin, added New Rally X. Added sound and controls to Snow Bros. Fixed sprites and background in Toki. Started the rewrite of M68000 core.<br>
<br>
09/02 - Saboten Bombers: Fixed bugs, decrypted graphics. Only missing sprites, IO and sound.<br>
<br>
08/02 - Fixed some bugs on Spectrum and Amstrad tape/disc loading and main screen resize, a small bug on Spectrum+3 and Spectrum 128, and now remembers the last tape/disc opened.<br>
Fixed Rygar sprites and Psychic 5 initial screen. Fixed and added some opcodes on Motorola 68000. Added Hard Head 2 and Saboten Bombers drivers.<br>
<br>
04/02 - Added DAC to HardHead and fixed bugs in Windows and Linux<br>
<br>
03/02 - Download added: Linux binary (tested on Fedora 11 and Ubuntu 9.04)<br>
<br>
02/02 - Hard Head driver finished, only remains DAC<br>
<br>
01/02 - Xain'd Sleena driver finished, works 99% only remains a very small sprites glitch. Suna driver started, Hard Head begin to work, but missing sound and correct video emulation.<br>
<br>
29/01 - Added basic driver for Xain'd Sleena with sound. Sprites, backgrounds and colors are missing<br>
<br>
28/01 - These days I'm having some troubles with the IO's of Galaga (reaches the main screen, but goes crazy with coin insertion), so I shall change the driver to see if I clear my mind a little, and then return to it.<br>
I'll start with the driver of Suna 8 bits (Hard Head and Hard Head 2) and the Xain'd Sleena driver.<br>
And between all this I will review the drivers posted by Francenm some months ago, Sauro, System1 and Warp-Warp.
