#DSP Emulator status<br>
<b>26/05/16 - DSP Emulator 0.16b3 WIP. Source and Windows 32 WIP binary updated.</b><br><pre>
-General
    +GFX: Fixed and enhanced the final screen rotation
    +Improved how is closed the drivers, CPU, video, etc. Fixed bugs and removed some problems when the driver is not initialized and changed an other
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
    + Mapped some missing special keys</pre>
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
    +upd765 chip
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
<b>31/03/15</b> - Migrated from Google. Published WIP source.
