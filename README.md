# dsp-emulator
Dsp emulator
Delphi & Lazarus+Free Pascal free emulator.
Arcade, Spectrum, Amstrad CPC, NES, Coleco Vision...

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
+ Z80: Fixed LDD and LDDR (Was fixed on Spectrum Z80 engine, but I forget to update!)<br>
+ Loading dynamically the necessary libraries. No more errors if the SDL2 library is not present, warns and finishes execution. If Zlib or IPF libraries are not available, do not perform the function but continues execution.<br>
+ Pokey: Started writing chip emulation<br>
+ Lazarus (Linux and OSX)<br>
- Fixed search function within a ZIP, it was doubling the results<br>
- Optional libraries: Zlib and IPF (CAPS Image)<br>
- Needed libraries: SDL2 and SDL2 Mixer<br>
+ Delphi (Windows)<br>
- Optional library: IPF (CAPS Image), the Zlib library is included on Delphi and don't need a external library<br>
- Needed library: SDL2<br>
+ UPD765:<br>
- Fixed length when full track read is selected<br>
- Fixed length when a sector read is selected<br>
- Fixed function that searches for the next id sector ('Tintin on the Moon' loads again on Spectrum +3)<br>
- Fixed when trying to read beyond the end of a track ('Short Circuit', 'Head Over Heels', etc. loads on Amstrad)<br>
- Fixed sector selection when it's deleted and SK is selected<br>
+ IPF: Started writing an interface to the IPF disk format<br>
Amstrad<br>
+ Implemented snapshots. Now load and save in 'SNA' format.<br>
+ Fixed selection of high ROM. If an unmapped ROM is selected by default basic ROM is slected (Fixes 'avant JC 20000', '2112AD', etc.)<br>
+ Some enhancement on Z80 timings, but still are wrong ('Prohibition' loads)</pre>

<strike>Windows 0.15b2WIP 32Bits binary</strike><br>
<strike>Linux 0.15b2WIP 32Bits binary</strike><br>
<strike>Linux 0.15b2WIP 64Bits binary</strike><br>
<strike>MAC OSX 0.15b2WIP 32bits binary</strike><br><br>

<b>06/11/14</b> - DSP 0.15b2WIP. Windows 32bits, Linux 32bits and 64 bits and MAC OSX 32  bits binary.<br>
<pre>-General<br>
+ Small cosmetical details fixes (icons, screen sizes, etc.)<br>
+ Lazarus: Modified the use of the Zlib library, now it links the external library, so compiled objects are no longer needed. Zlib libray must be installed on Linux and OSX (Linux 64bit fails).<br>
+ Simplified the creation of audio emulated device, the audio CPU information is saved internally (number and CPU clock), so it is no longer necessary to add it when initializing a sound chip<br>
+ Simplified keyboard system. It is not based on events to see if the key is pressed or not.<br>
+ M68000: Fixed and added the timings of all opcodes<br>
-Spectrum<br>
+ If a snapshot is loaded and that the maximum speed is set, it's reduced to normal speed<br>
-Amstrad<br>
+ Fixed mode 2 display. I can not change the physical resolution of the screen, because there are games that combine several resolutions in the same frame. It is now the color is estimated from the sum of then two real pixels. (Thanks to cpcbegin)<br>
+ Fixed removal of the IRQ when values are modified in the GA. It fixes audio speed and video timings in some games.<br>
+ M6845 video: The address value is calculated with a table. 32k screen display effect and hardware scrolling now work<br>
-Taito SJ HW<br>
+ Fixed audio<br>
-Zaxxon HW<br>
+ Congo: Fixed audio<br>
-Contra<br>
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

<b>11/03</b> - Siete años<br>
Hoy hace siete años del atentado de Madrid/Atocha...<br>
<img src='http://img1.imagilive.com/0311/in_memoria.png' alt='En memoria de las víctimas del 11-M' title='En memoria de las víctimas del 11-M'><br>

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
As we sing here: 'Yo soy Español, Español, Español!!!'<br>
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
