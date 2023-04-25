# DSP Emulator status #
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
            +Removed fake adpcm, using standar MSM5205
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