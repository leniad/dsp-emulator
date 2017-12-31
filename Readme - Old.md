# dsp-emulator #
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
-General
    +Z80: Implemented WZ/MEMPTR register, now passes all ZEXALL tests
    +YM2203: Added functions to change the AY internal clock
-Spectrum
    +When a snapshot without ROM is loaded and previously changed to a different ROM than the original, it's reloaded the original ROM
    +Contended memory changes
-Amstrad CPC
    +Added LensLok protection
    +Enhanced video mode 2, more speed
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
