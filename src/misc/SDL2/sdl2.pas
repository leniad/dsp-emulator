unit SDL2;

{
  Simple DirectMedia Layer
  Copyright (C) 1997-2013 Sam Lantinga <slouken@libsdl.org>

  Pascal-Header-Conversion
  Copyright (C) 2012/13 Tim Blume aka End/EV1313

  SDL.pas is based on the files:
  "sdl.h",
  "sdl_audio.h",
  "sdl_blendmode.h",
  "sdl_events.h",
  "sdl_error.h",
  "sdl_gamecontroller.h",
  "sdl_gesture.h",
  "sdl_haptic.h",
  "sdl_hints.h",
  "sdl_joystick.h",
  "sdl_keyboard.h",
  "sdl_keycode.h",
  "sdl_loadso.h"
  "sdl_pixels.h",
  "sdl_power.h",
  "sdl_main.h",
  "sdl_messagebox.h",
  "sdl_mouse.h",
  "sdl_mutex.h",
  "sdl_rect.h",
  "sdl_render.h",
  "sdl_rwops.h",
  "sdl_scancode.h",
  "sdl_shape.h",
  "sdl_stdinc.h",
  "sdl_surface.h",
  "sdl_thread.h",
  "sdl_timer.h",
  "sdl_touch.h",
  "sdl_version.h",
  "sdl_video.h",
  "sdltype_s.h"

  I will not translate:
  "sdl_opengl.h",
  "sdl_opengles.h"
  "sdl_opengles2.h"

  cause there's a much better OpenGL-Header avaible at delphigl.com:

  the dglopengl.pas

  Parts of the SDL.pas are from the SDL-1.2-Headerconversion from the JEDI-Team,
  written by Domenique Louis and others.

  I've changed the names of the dll for 32 & 64-Bit, so theres no conflict
  between 32 & 64 bit Libraries.

  This software is provided 'as-is', without any express or implied
  warranty.  In no case will the authors be held liable for any damages
  arising from the use of this software.

  Permission is granted to anyone to use this software for any purpose,
  including commercial applications, and to alter it and redistribute it
  freely, subject to the following restrictions:

  1. The origin of this software must not be misrepresented; you must not
     claim that you wrote the original software. If you use this software
     in a product, an acknowledgment in the product documentation would be
     appreciated but is not required.
  2. Altered source versions must be plainly marked as such, and must not be
     misrepresented as being the original software.
  3. This notice may not be removed or altered from any source distribution.

  Special Thanks to:

   - DelphiGL.com - Community
   - Domenique Louis and everyone else from the JEDI-Team
   - Sam Latinga and everyone else from the SDL-Team
}

{
  Changelog:
  ----------
  v.1.74-stable; 10.11.2013: added sdl_gamecontroller.h
  v.1.73-stable; 08.11.2013: added sdl_hints.h and some keystate helpers
                             thx to Cybermonkey!
  v.1.72-stable; 23.09.2013: fixed bug with procedures without parameters
                             (they must have brakets)
  v.1.70-stable; 17.09.2013: added "sdl_messagebox.h" and "sdl_haptic.h"
  v.1.63-stable; 16.09.2013: added libs sdl2_image and sdl2_ttf and added sdl_audio.h
  v.1.62-stable; 03.09.2013: fixed.
  v.1.61-stable; 02.09.2013: now it should REALLY work with Mac...
  v.1.60-stable; 01.09.2013: now it should work with Delphi XE4 for Windows and
                            MacOS and of course Lazarus. thx to kotai :D
  v.1.55-Alpha; 24.08.2013: fixed bug with SDL_GetEventState thx to d.l.i.w.
  v.1.54-Alpha; 24.08.2013: added sdl_loadso.h
  v.1.53-Alpha; 24.08.2013: renamed *really* and fixed linux comp.
  v.1.52-Alpha; 24.08.2013: renamed sdl.pas to sdl2.pas
  v.1.51-Alpha; 24.08.2013: added sdl_platform.h
  v.1.50-Alpha; 24.08.2013: the header is now modular. thx for the hint from d.l.i.w.
  v.1.40-Alpha; 13.08.2013: Added MacOS compatibility (thx to stoney-fd)
  v.1.34-Alpha; 05.08.2013: Added missing functions from sdl_thread.h
  v.1.33-Alpha; 31.07.2013: Added missing units for Linux. thx to Cybermonkey
  v.1.32-Alpha; 31.07.2013: Fixed three bugs, thx to grieferatwork
  v.1.31-Alpha; 30.07.2013: Added "sdl_power.h"
  v.1.30-Alpha; 26.07.2013: Added "sdl_thread.h" and "sdl_mutex.h"
  v.1.25-Alpha; 29.07.2013: Added Makros for SDL_RWops
  v.1.24-Alpha; 28.07.2013: Fixed bug with RWops and size_t
  v.1.23-Alpha; 27.07.2013: Fixed two bugs, thx to GrieferAtWork
  v.1.22-Alpha; 24.07.2013: Added "sdl_shape.h" and TSDL_Window
                            (and ordered the translated header list ^^)
  v.1.21-Alpha; 23.07.2013: Added TSDL_Error
  v.1.20-Alpha; 19.07.2013: Added "sdl_timer.h"
  v.1.10-Alpha; 09.07.2013: Added "sdl_render.h"
  v.1.00-Alpha; 05.07.2013: Initial Alpha-Release.
}

{$DEFINE SDL}

{$I jedi.inc}

interface
uses dialogs{$IFDEF WINDOWS},windows{$endif}{$ifdef linux},X,XLib{$endif}{$ifndef windows},dynlibs{$endif};

{$I sdltype.inc}
{$I sdlversion.inc}
{$I sdlerror.inc}
{$I sdlplatform.inc}
{$I sdlpower.inc}
{$I sdlthread.inc}
{$I sdlmutex.inc}
{$I sdltimer.inc}
{$I sdlpixels.inc}
{$I sdlrect.inc}
{$I sdlrwops.inc}
{$I sdlaudio.inc}
{$I sdlblendmode.inc}
{$I sdlsurface.inc}
{$I sdlshape.inc}
{$I sdlvideo.inc}
{$I sdlhints.inc}
{$I sdlmessagebox.inc}
{$I sdlrenderer.inc}
{$I sdlscancode.inc}
{$I sdlkeyboard.inc}
{$I sdlmouse.inc}
{$I sdljoystick.inc}
{$I sdlgamecontroller.inc}
{$I sdlhaptic.inc}
{$I sdltouch.inc}
{$I sdlgesture.inc}
{$I sdlevents.inc}
{$I sdl.inc}

var
  sdl_dll_handle:int64;
  SDL_Init:TSDL_Init;
  SDL_WasInit:TSDL_WasInit;
  SDL_Quit:TSDL_Quit;
  SDL_LoadBMP_RW:TSDL_LoadBMP_RW;
  SDL_CreateRGBSurface:TSDL_CreateRGBSurface;
  SDL_UpperBlit:TSDL_UpperBlit;
  SDL_FreeSurface:TSDL_FreeSurface;
  SDL_SaveBMP_RW:TSDL_SaveBMP_RW;
  SDL_SetColorKey:TSDL_SetColorKey;
  SDL_JoystickUpdate:TSDL_JoystickUpdate;
  SDL_JoystickGetAxis:TSDL_JoystickGetAxis;
  SDL_NumJoysticks:TSDL_NumJoysticks;
  SDL_JoystickName:TSDL_JoystickName;
  SDL_JoystickNumButtons:TSDL_JoystickNumButtons;
  SDL_JoystickOpen:TSDL_JoystickOpen;
  SDL_JoystickClose:TSDL_JoystickClose;
  SDL_JoystickGetButton:TSDL_JoystickGetButton;
  SDL_EventState:TSDL_EventState;
  SDL_PollEvent:TSDL_PollEvent;
  SDL_GetCursor:TSDL_GetCursor;
  SDL_CreateCursor:TSDL_CreateCursor;
  SDL_SetCursor:TSDL_SetCursor;
  SDL_ShowCursor:TSDL_ShowCursor;
  SDL_DestroyWindow:TSDL_DestroyWindow;
  SDL_VideoQuit:TSDL_VideoQuit;
  SDL_SetWindowSize:TSDL_SetWindowSize;
  SDL_GetWindowSurface:TSDL_GetWindowSurface;
  SDL_CreateWindowFrom:TSDL_CreateWindowFrom;
  SDL_CreateWindow:TSDL_CreateWindow;
  SDL_UpdateWindowSurface:TSDL_UpdateWindowSurface;
  SDL_RWFromFile:TSDL_RWFromFile;
  SDL_GetRGB:TSDL_GetRGB;
  SDL_MapRGB:TSDL_MapRGB;
  SDL_GetKeyboardState:TSDL_GetKeyboardState;
  SDL_SetHintWithPriority:TSDL_SetHintWithPriority;
  SDL_SetHint:TSDL_SetHint;
  {$ifndef windows}
  SDL_SetError:TSDL_SetError;
  SDL_GetError:TSDL_GetError;
  SDL_GetTicks:TSDL_GetTicks;
  SDL_SetWindowTitle:TSDL_SetWindowTitle;
  {$endif}

procedure Init_sdl_lib;
procedure close_sdl_lib;

implementation

procedure Init_sdl_lib;
begin
{$ifdef darwin}
sdl_dll_Handle:=LoadLibrary('libSDL2.dylib');
{$endif}
{$ifdef linux}
sdl_dll_Handle:=LoadLibrary('libSDL2.so');
if sdl_dll_Handle=0 then sdl_dll_Handle:=LoadLibrary('libSDL2.so.0');
{$endif}
{$ifdef windows}
sdl_dll_Handle:=LoadLibrary('sdl2.dll');
{$endif}
if sdl_dll_Handle=0 then begin
  MessageDlg('SDL2 library not found.'+chr(10)+chr(13)+'Please read the documentation!', mtError,[mbOk], 0);
  halt(0);
end;
//sdl
@SDL_Init:=GetProcAddress(sdl_dll_Handle,'SDL_Init');
@SDL_WasInit:=GetProcAddress(sdl_dll_Handle,'SDL_WasInit');
@SDL_Quit:=GetProcAddress(sdl_dll_Handle,'SDL_Quit');
//surface
@SDL_LoadBMP_RW:=GetProcAddress(sdl_dll_Handle,'SDL_LoadBMP_RW');
@SDL_CreateRGBSurface:=GetProcAddress(sdl_dll_Handle,'SDL_CreateRGBSurface');
@SDL_UpperBlit:=GetProcAddress(sdl_dll_Handle,'SDL_UpperBlit');
@SDL_FreeSurface:=GetProcAddress(sdl_dll_Handle,'SDL_FreeSurface');
@SDL_SaveBMP_RW:=GetProcAddress(sdl_dll_Handle,'SDL_SaveBMP_RW');
@SDL_SetColorKey:=GetProcAddress(sdl_dll_Handle,'SDL_SetColorKey');
//joystick
@SDL_JoystickUpdate:=GetProcAddress(sdl_dll_Handle,'SDL_JoystickUpdate');
@SDL_JoystickGetAxis:=GetProcAddress(sdl_dll_Handle,'SDL_JoystickGetAxis');
@SDL_NumJoysticks:=GetProcAddress(sdl_dll_Handle,'SDL_NumJoysticks');
@SDL_JoystickName:=GetProcAddress(sdl_dll_Handle,'SDL_JoystickName');
@SDL_JoystickNumButtons:=GetProcAddress(sdl_dll_Handle,'SDL_JoystickNumButtons');
@SDL_JoystickOpen:=GetProcAddress(sdl_dll_Handle,'SDL_JoystickOpen');
@SDL_JoystickClose:=GetProcAddress(sdl_dll_Handle,'SDL_JoystickClose');
@SDL_JoystickGetButton:=GetProcAddress(sdl_dll_Handle,'SDL_JoystickGetButton');
//events
@SDL_EventState:=GetProcAddress(sdl_dll_Handle,'SDL_EventState');
@SDL_PollEvent:=GetProcAddress(sdl_dll_Handle,'SDL_PollEvent');
//mouse
@SDL_GetCursor:=GetProcAddress(sdl_dll_Handle,'SDL_GetCursor');
@SDL_CreateCursor:=GetProcAddress(sdl_dll_Handle,'SDL_CreateCursor');
@SDL_SetCursor:=GetProcAddress(sdl_dll_Handle,'SDL_SetCursor');
@SDL_ShowCursor:=GetProcAddress(sdl_dll_Handle,'SDL_ShowCursor');
//video
@SDL_DestroyWindow:=GetProcAddress(sdl_dll_Handle,'SDL_DestroyWindow');
@SDL_VideoQuit:=GetProcAddress(sdl_dll_Handle,'SDL_VideoQuit');
@SDL_SetWindowSize:=GetProcAddress(sdl_dll_Handle,'SDL_SetWindowSize');
@SDL_GetWindowSurface:=GetProcAddress(sdl_dll_Handle,'SDL_GetWindowSurface');
@SDL_CreateWindowFrom:=GetProcAddress(sdl_dll_Handle,'SDL_CreateWindowFrom');
@SDL_CreateWindow:=GetProcAddress(sdl_dll_Handle,'SDL_CreateWindow');
@SDL_UpdateWindowSurface:=GetProcAddress(sdl_dll_Handle,'SDL_UpdateWindowSurface');
//rwops
@SDL_RWFromFile:=GetProcAddress(sdl_dll_Handle,'SDL_RWFromFile');
//pixels
@SDL_GetRGB:=GetProcAddress(sdl_dll_Handle,'SDL_GetRGB');
@SDL_MapRGB:=GetProcAddress(sdl_dll_Handle,'SDL_MapRGB');
//keyboard
@SDL_GetKeyboardState:=GetProcAddress(sdl_dll_Handle,'SDL_GetKeyboardState');
//hint
@SDL_SetHintWithPriority:=GetProcAddress(sdl_dll_Handle,'SDL_SetHintWithPriority');
@SDL_SetHint:=GetProcAddress(sdl_dll_Handle,'SDL_SetHint');
{$ifndef windows}
//error
@SDL_SetError:=GetProcAddress(sdl_dll_Handle,'SDL_SetError');
@SDL_GetError:=GetProcAddress(sdl_dll_Handle,'SDL_GetError');
//timer
@SDL_GetTicks:=GetProcAddress(sdl_dll_Handle,'SDL_GetTicks');
//video
@SDL_SetWindowTitle:=GetProcAddress(sdl_dll_Handle,'SDL_SetWindowTitle');
{$endif}
end;

procedure close_sdl_lib;
begin
if sdl_dll_handle<>0 then begin
   FreeLibrary(sdl_dll_Handle);
   sdl_dll_handle:=0;
end;
end;

//from "sdl_version.h"
procedure SDL_VERSION(x: PSDL_Version);
begin
  x.major := SDL_MAJOR_VERSION;
  x.minor := SDL_MINOR_VERSION;
  x.patch := SDL_PATCHLEVEL;
end;

function SDL_VERSIONNUM(X,Y,Z: UInt32): Cardinal;
begin
  Result := X*1000 + Y*100 + Z;
end;

function SDL_COMPILEDVERSION: Cardinal;
begin
  Result := SDL_VERSIONNUM(SDL_MAJOR_VERSION,
                           SDL_MINOR_VERSION,
                           SDL_PATCHLEVEL);
end;

function SDL_VERSION_ATLEAST(X,Y,Z: Cardinal): Boolean;
begin
  Result := SDL_COMPILEDVERSION >= SDL_VERSIONNUM(X,Y,Z);
end;

{$IFDEF WINDOWS}
//from "sdl_thread.h"

{function SDL_CreateThread(fn: TSDL_ThreadFunction; name: PAnsiChar; data: Pointer): PSDL_Thread; overload;
begin
  Result := SDL_CreateThread(fn,name,data,nil,nil);
end;}

{$ENDIF}

//from "sdl_rect.h"
function SDL_RectEmpty(X: TSDL_Rect): Boolean;
begin
  Result := (X.w <= 0) or (X.h <= 0);
end;

function SDL_RectEquals(A: TSDL_Rect; B: TSDL_Rect): Boolean;
begin
  Result := (A.x = B.x) and (A.y = B.y) and (A.w = B.w) and (A.h = B.h);
end;

//from "sdl_rwops.h"

function SDL_RWsize(ctx: PSDL_RWops): SInt64;
begin
  Result := ctx^.size(ctx);
end;

function SDL_RWseek(ctx: PSDL_RWops; offset: SInt64; whence: SInt32): SInt64;
begin
  Result := ctx^.seek(ctx,offset,whence);
end;

function SDL_RWtell(ctx: PSDL_RWops): SInt64;
begin
  Result := ctx^.seek(ctx, 0, RW_SEEK_CUR);
end;

function SDL_RWread(ctx: PSDL_RWops; ptr: Pointer; size: size_t; n: size_t): size_t;
begin
  Result := ctx^.read(ctx, ptr, size, n);
end;

function SDL_RWwrite(ctx: PSDL_RWops; ptr: Pointer; size: size_t; n: size_t): size_t;
begin
  Result := ctx^.write(ctx, ptr, size, n);
end;

function SDL_RWclose(ctx: PSDL_RWops): SInt32;
begin
  Result := ctx^.close(ctx);
end;

//from "sdl_audio.h"

{function SDL_LoadWAV(_file: PAnsiChar; spec: PSDL_AudioSpec; audio_buf: PPUInt8; audio_len: PUInt32): PSDL_AudioSpec;
begin
  Result := SDL_LoadWAV_RW(SDL_RWFromFile(_file, 'rb'), 1, spec, audio_buf, audio_len);
end;}
  
function SDL_AUDIO_BITSIZE(x: Cardinal): Cardinal;
begin
  Result := x and SDL_AUDIO_MASK_BITSIZE;
end;

function SDL_AUDIO_ISFLOAT(x: Cardinal): Cardinal;
begin
  Result := x and SDL_AUDIO_MASK_DATATYPE;
end;

function SDL_AUDIO_ISBIGENDIAN(x: Cardinal): Cardinal;
begin
  Result := x and SDL_AUDIO_MASK_ENDIAN;
end;

function SDL_AUDIO_ISSIGNED(x: Cardinal): Cardinal;
begin
  Result := x and SDL_AUDIO_MASK_SIGNED;
end;

function SDL_AUDIO_ISINT(x: Cardinal): Cardinal;
begin
  Result := not SDL_AUDIO_ISFLOAT(x);
end;

function SDL_AUDIO_ISLITTLEENDIAN(x: Cardinal): Cardinal;
begin
  Result := not SDL_AUDIO_ISLITTLEENDIAN(x);
end;

function SDL_AUDIO_ISUNSIGNED(x: Cardinal): Cardinal;
begin
  Result := not SDL_AUDIO_ISSIGNED(x);
end;

//from "sdl_pixels.h"

function SDL_PIXELFLAG(X: Cardinal): Boolean;
begin
  Result := (X shr 28) = $0F;
end;

function SDL_PIXELTYPE(X: Cardinal): Boolean;
begin
  Result := (X shr 24) = $0F;
end;

function SDL_PIXELORDER(X: Cardinal): Boolean;
begin
  Result := (X shr 20) = $0F;
end;

function SDL_PIXELLAYOUT(X: Cardinal): Boolean;
begin
  Result := (X shr 16) = $0F;
end;

function SDL_BITSPERPIXEL(X: Cardinal): Boolean;
begin
  Result := (X shr 8) = $FF;
end;

function SDL_IsPixelFormat_FOURCC(format: Variant): Boolean;
begin
  {* The flag is set to 1 because 0x1? is not in the printable ASCII range *}
  Result := format and SDL_PIXELFLAG(format) <> 1;
end;

//from "sdl_surface.h"
{function SDL_LoadBMP(_file: PAnsiChar): PSDL_Surface;
begin
  Result:=SDL_LoadBMP_RW(SDL_RWFromFile(_file, 'rb'), 1);
end;}

//from "sdl_video.h"
function SDL_WindowPos_IsUndefined(X: Variant): Variant;
begin
  Result := (X and $FFFF0000) = SDL_WINDOWPOS_UNDEFINED_MASK;
end;

function SDL_WindowPos_IsCentered(X: Variant): Variant;
begin
  Result := (X and $FFFF0000) = SDL_WINDOWPOS_CENTERED_MASK;
end;

//from "sdl_events.h"

function SDL_GetEventState(type_: UInt32): UInt8;
begin
  Result := SDL_EventState(type_, SDL_QUERY);
end;

end.
