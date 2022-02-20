# DSP Emulator status #
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
    +Updated SDL library to 2.0.20
    +Analog control: Addded selection of X or Y axis inverted
-Genesis/Megadrive
    +Started a new driver
-Mr Do!
    +Fixed colors
    +Added dipswitch
-Crystal Castles: Added driver with sound
-Flower: Added driver with sound
-Mr Do Castle Hardware
    +Mr Do Castle: Added driver with sound
    +Do! Run Run: Added driver with sound
    +Mr Do Wild Ride: Added driver with sound
    +Jumping Jack: Added driver with sound
    +Kick Rider: Added driver with sound
    +Indoor Soccer: Added driver with sound
</pre><br>
<img src="https://i.ibb.co/YRpBMZn/ccastles.png"> <img src="https://i.ibb.co/QK4H7bL/Flower.png"><br>
<img src="https://i.ibb.co/bL1nPyV/docastle.png"> <img src="https://i.ibb.co/5vCDj3Q/dorunrun.png"><br>
<img src="https://i.ibb.co/PCfncpm/dowild.png"> <img src="https://i.ibb.co/cx19TTm/jjack.png"><br>
<img src="https://i.ibb.co/SN4wrdn/kickrider.png"> <img src="https://i.ibb.co/G9hgj0n/insoccer.png"><br><br>
<b>22/11/21 - DSP Emulator 0.20WIP5. Win32 and source update.<br><pre>
-General
    +CPU
        -MCS48
            +Added I8042 CPU type
            +Fixed IRQs
            +Added opcodes $02,$08,$22,$35,$40,$41,$60,$61,$65,$86,$89,$8a,$90,$c7 and $d6
            +Fixed opcodes $10,$11 and $57
-Sega GameGear
    +Added Master System video compatibility
    +Added CodeMasters Mapper extra RAM
-NinjaKid II HW
    +Added dipswitches
    +NinjaKid II: Added PCM sound
    +Atomic RoboKid: Added driver with sound
-StarForce
    +Updated ROMs names
-Sega System 16a
    +Added PCM sound
-The New Zealand Story HW
    +Extermination: Added driver with sound
</pre><br>
<img src="https://i.ibb.co/sVXs8Cj/Extermination.png"> <img src="https://i.ibb.co/ysdpg20/Atomic-Robo-kid.png"><br>
<img src="https://i.ibb.co/Qj0Y1Y3/castle.png"> <img src="https://i.ibb.co/nnjPJ4r/outrun-europa.png"><br><br>
<b>31/10/21 - DSP Emulator 0.20WIP4. Win32 and source update.<br><pre>
-General
    +Seta Sprites: Added new device
    +CPU
        -M6502
            +Added M65CE02 CPU type. Added many specific opcodes
    +Lens Lock
        -Fixed Amstrad decode mode
    +Seta X1-010
        -Added new sound device
-Spectrum
    +Spectrum 16K/48K fixed screen timings
-Dec8 HW
    +Super Real Darwin: Inverted coin input
-Karate Champ
    +Added driver with sound
-Pacman HW
    +Enhance IRQs
    +Ms Pac Man Twin
        -Added driver with sound
-Renegade
    +Fixed dipswitches
-Seta HW
    +Thundercade
        -Added driver with sound
    +Twin Eagle
        -Added driver with sound
    +Thunder & Lightning
        -Added driver with sound
-StarForce
    +Fixed X scroll in background
-The New Zealand Story HW
    +Rewrited video system, now uses Seta Sprite device
</pre><br>
<img src="https://i.ibb.co/1v0t051/Karate-Champ.png"> <img src="https://i.ibb.co/LCjkcSF/Ms-Pac-Man-Twin.png"><br>
<img src="https://i.ibb.co/THTbTq6/Thunder-Lightning.png" > <img src="https://i.ibb.co/3WdcDhH/Thundercade.png" ><br>
<img src="https://i.ibb.co/2d2z7vQ/Twin-Eagle.png"><br><br>
<b>27/08/21 - After some exhausting and time-consuming real life, here comes a new little update. DSP Emulator 0.20WIP3. Win32 and source update.<br><pre>
-General
    +Joystick: Some changes to enhance configuration
-Commodore 64
    +Snapshots: Initial support for VSF (Vice Snapshot File)
-Burguer Time HW
    +Code cleaning
    +Burguer Time: Update decryption, more speed
    +Lock'N'Chase: Added driver with sound
    +Minky Monkey: Added driver with sound
-Mario Bros.
    +Added quick snapshots
-Sega System 1/System 2
    +Fixed slowdowns and clean code
    +Added quick snapshots
    +Enhanced video buffer, more speed
</pre><br>
<img src='https://i.ibb.co/2dhK7yY/lnc.png'> <img src='https://i.ibb.co/BNhzcvg/mmonkey.png'><br><br>
<b>31/05/21 - DSP Emulator 0.20WIP2. Win32 and source update.<br><pre>
-General
    +CPU
        -UPD78XX
            +Added sub CPU 7801
            +Added many opcodes, and fix others
-Sega Master System
    +Fixed IRQ in SMS video mode (Fixes 'Nemesis', 'The Simpsons - Bart vs. the Space Mutants', etc)
    +Fixed memory initialization with value $f0 (Fixes 'Alibaba and 40 Thieves', 'Micro Xevious', etc)
    +Change palette of TMS video mode
-Super Cassette Vision
    +Added preliminary console driver (to fix CPU 78XX and enhance Taito CChip!)
-Toaplan 1
    +Added preliminary driver for the system
        -Hellfire: Basic driver 
</pre><br><br>
<b>22/04/21 - DSP Emulator 0.20WIP1. Win32 and source update.<br><pre>
-General
    +CPU
        -LR35902
            +Add 4T when take an IRQ and comes from HALT
-Gameboy/Gameboy Color
    +Fixed background/window/sprites prorities. Finally understood how it works and renders the screen and objects
    +Fixed window line draw (Fixes 'Star Trek', 'Marblemadness', 'International Karate' and many others)
    +Fixed stupid bug in Gamboy Color video RAM
    +Fixed Gameboy Color background color (Fixes 'Yoda Stories')
    +Fixed sprite/sprite priority
    +Fixed when LCD is disabled, LCD-stat is 0
    +DMA - Fixed data origin 
</pre>
<img src='https://i.ibb.co/p2X10Tc/karate.jpg'> <img src='https://i.ibb.co/k2mwrPG/startrek.jpg'><br>
<img src='https://i.ibb.co/JtgQtNG/Yoda.jpg'><br><br>
<b>10/04/21 - DSP Emulator 0.19 released<br>
Windows 32bits and 64bits, Linux 64bits, MacOS X 64bits and source updated. Updated Wiki.<br><pre>
All changes on previous 0.18b3 release and
-General
    +Preview picture
        -Cosmetical changes: bigger with black background and scaled picture
        -Added picture to Spectrum Plus 2A, SG-1000 and GameGear. Split GameBoy and GameBoy color pictures
-Gameboy/Gameboy Color
    +Better drawing priorities, still not perfect
    +Window: fixed priorities with sprites (Look at 'Prehistorik Man')
    +Fixed controls order reading (Fixes new version of 'Robocop' - Thanks to Neville)
    +Small fix to serial (Fixes 'Lunar Lander', 'Hyper Dunk' and many others)
-Suna 8 HW
    +Hard Head 2
        -Fixed palette
</pre>
<b>28/03/21 - Last update before stable version. DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
    +Samples: simplified samples loading functions
-Suna 8 HW
    +Added DIP switches
    +Fixed sound clock
        -Hard Head
            +Fixed DAC samples
            +Fixed FPS
        -Hard Head 2
            +Fixed ROM decode
            +Fixed video (only remains palette color problem)
            +Added DAC samples
-Tiger Road HW
    +Added DIP switches
-Outrun
    +Fixed gear button
</pre>
<img src='https://i.ibb.co/3vsqcdv/hh2-1.jpg'> <img src='https://i.ibb.co/233KTxs/hh2-2.jpg'><br><br>
<b>13/03/21 - Second update today! DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-GameBoy/Gameboy Color HW
    +Now you can choose between original GB green palette and GB pocket BW (Thanks to Neville)
-Amstrad CPC
    +Fixed screen flickering (Thanks to Neville)
</pre>
<b>13/03/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
    +Sound
        -Sega PCM: Added sound chip
-Spectrum
    +Fixed low border size, was 8 pixels too long (Thanks to Neville)
    +Fixed fast speed and no border draw, now don't draw any border
-Amstrad CPC
    +Resize screen size, it was too big, now it's 384x272 pixels (Thanks to Neville)
-Sega Master System
    +Fixed zip ROM load (Thanks to Neville)
-Sega GameGear
    +Fixed zip ROM load (Thanks to Neville)
-Outrun HW
    +Added road
    +Added Sega PCM
    +Added controls
    +Added DIP switches
</pre>
<img src='https://i.ibb.co/RcKQtpX/Outrun-1.jpg'> <img src='https://i.ibb.co/GJmTSdT/Outrun-2.jpg'><br><br>
<b>05/03/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
    +CPU
        -M68000: Added reset line procedure
    +Added Sega 315-5195 as a device
-Outrun HW
    +Enhanced driver only missing: partial road, digital sound and controls
</pre>
<img src='https://i.ibb.co/4VZGbtv/Outrun-1.jpg'> <img src='https://i.ibb.co/fvp9PQL/Outrun-2.jpg'><br><br>
<b>26/02/21 - DSP Emulator 0.18b3 WIP. Win32 and source update.<br><pre>
-General
    +CPU
        -MCS51:
            +clean the code
            +Fixed carry in opcodes $B8 to $BF
            +Fixed IRQs
    +ROMS export: Fixed many ROMs sets and added samples, again
-Ajax: Fixed ROM names
-Slap Fight: Fixed ROM names
-Sega System 16B HW
    +Small fix to memory mapper
    +When using i8751, the M68000 don't have access to 315-5195
    +Removed i8751/M68000 hack
    +Added dipswitches
        -Golden Axe: Fixed remaining issues with i8751
        -Passing Shot: Added driver with sound, due the lack of FD1094 emulation using predecoded version
        -Aurail: Added driver with sound
</pre>
<img src='https://i.ibb.co/d4KG1Mr/passingshot.jpg'> <img src='https://i.ibb.co/b3mqHPb/Aurail.jpg'><br><br>