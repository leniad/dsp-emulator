unit lib_sdl2;

interface

uses
  Classes,SysUtils,sdl2,dialogs{$IFDEF WINDOWS},windows{$else},dynlibs{$endif};

procedure Init_sdl_lib;
procedure close_sdl_lib;

type
    TSDL_Init=function(flags:UInt32):SInt32; cdecl;
    TSDL_WasInit=function(flags:UInt32):UInt32; cdecl;
    TSDL_Quit=procedure;cdecl;
    TSDL_LoadBMP_RW=function(src:PSDL_RWops;freesrc:SInt32):PSDL_Surface;cdecl;
    TSDL_CreateRGBSurface=function(flags:UInt32;width:SInt32;height:SInt32;depth:SInt32;Rmask:UInt32;Gmask:UInt32;Bmask:UInt32;Amask:UInt32):PSDL_Surface;cdecl;
    TSDL_UpperBlit=function(src:PSDL_Surface;const srcrect:PSDL_Rect;dst:PSDL_Surface;dstrect:PSDL_Rect):SInt32;cdecl;
    TSDL_FreeSurface=procedure(surface:PSDL_Surface);cdecl;
    TSDL_SaveBMP_RW=function(surface:PSDL_Surface;dst:PSDL_RWops;freedst:SInt32):SInt32;cdecl;
    TSDL_SetColorKey=function(surface:PSDL_Surface;flag:SInt32;key:UInt32):SInt32;cdecl;
    TSDL_JoystickUpdate=procedure;cdecl;
    TSDL_JoystickGetAxis=function(joystick:PSDL_Joystick;axis:SInt32):SInt16;cdecl;
    TSDL_NumJoysticks=function:SInt32;cdecl;
    TSDL_JoystickName=function(joystick:PSDL_Joystick):PAnsiChar;cdecl;
    TSDL_JoystickNumButtons=function(joystick:PSDL_Joystick):SInt32;cdecl;
    TSDL_JoystickOpen=function(device_index:SInt32):PSDL_Joystick;cdecl;
    TSDL_JoystickClose=procedure(joystick:PSDL_Joystick);cdecl;
    TSDL_JoystickGetButton=function(joystick:PSDL_Joystick;button:SInt32):UInt8;cdecl;
    TSDL_EventState=function(type_:UInt32;state:SInt32):UInt8;cdecl;
    TSDL_PollEvent=function(event:PSDL_Event):SInt32;cdecl;
    TSDL_GetCursor=function:PSDL_Cursor;cdecl;
    TSDL_CreateCursor=function(const data:PUInt8;const mask:PUInt8;w:SInt32;h:SInt32;hot_x:SInt32;hot_y:SInt32):PSDL_Cursor;cdecl;
    TSDL_SetCursor=procedure(cursor:PSDL_Cursor);cdecl;
    TSDL_ShowCursor=function(toggle:SInt32):SInt32;cdecl;
    TSDL_DestroyWindow=procedure(window:PSDL_Window);cdecl;
    TSDL_VideoQuit=procedure;cdecl;
    TSDL_SetWindowSize=procedure(window:PSDL_Window;w:SInt32;h:SInt32);cdecl;
    TSDL_GetWindowSurface=function(window:PSDL_Window):PSDL_Surface;cdecl;
    TSDL_CreateWindowFrom=function(const data:Pointer):PSDL_Window;cdecl;
    TSDL_CreateWindow=function(const title:PAnsiChar;x:SInt32;y:SInt32;w:SInt32;h:SInt32;flags:UInt32):PSDL_Window;cdecl;
    TSDL_UpdateWindowSurface=function(window:PSDL_Window):SInt32;cdecl;
    TSDL_RWFromFile=function(const _file:PAnsiChar;const mode:PAnsiChar):PSDL_RWops;cdecl;
    TSDL_GetRGB=procedure(pixel:UInt32;const format:PSDL_PixelFormat;r:PUInt8;g:PUInt8;b:PUInt8);cdecl;
    TSDL_MapRGB=function(const format:PSDL_PixelFormat;r:UInt8;g:UInt8;b:UInt8):UInt32;cdecl;
    TSDL_MapRGBA=function(const format:PSDL_PixelFormat;r:UInt8;g:UInt8;b:UInt8;a:Uint8):UInt32;cdecl;
    TSDL_GetKeyboardState=function(numkeys:PInt):PUInt8;cdecl;
    TSDL_SetHintWithPriority=function (const name:PChar;const value:PChar;priority:SDL_HintPriority):boolean;cdecl;
    TSDL_SetHint=function (const name:PChar;const value:PChar):boolean; cdecl;
    TSDL_SetSurfaceBlendMode=function (surface: PSDL_Surface; blendMode: TSDL_BlendMode):SInt32;cdecl;
    {$ifndef windows}
    TSDL_SetError=function(const fmt:PAnsiChar):SInt32;cdecl;
    TSDL_GetError=function:PAnsiChar;cdecl;
    TSDL_GetTicks=function:UInt32;cdecl;
    TSDL_SetWindowTitle=procedure(window:PSDL_Window;const title:PAnsiChar);cdecl;
    {$endif}

    libsdl_rect=Tsdl_rect;
    libsdlp_Surface=psdl_surface;
    libsdlp_joystick=psdl_joystick;
    libsdlP_cursor=PSDL_cursor;
    libSDL_Event=TSDL_Event;
    libsdlP_Window =PSDL_Window;

const
  libAUDIO_S16= $8010;
  libSDL_JOYBUTTONDOWN=SDL_JOYBUTTONDOWN;
  libSDL_JOYBUTTONUP=SDL_JOYBUTTONUP;
  libSDL_JOYAXISMOTION=SDL_JOYAXISMOTION;
  libSDL_MOUSEMOTION=SDL_MOUSEMOTION;
  libSDL_MOUSEBUTTONDOWN=SDL_MOUSEBUTTONDOWN;
  libSDL_MOUSEBUTTONUP=SDL_MOUSEBUTTONUP;
  libSDL_BUTTON_LEFT=SDL_BUTTON_LEFT;
  libSDL_BUTTON_RIGHT=SDL_BUTTON_RIGHT;
  libSDL_SCANCODE_F1=SDL_SCANCODE_F1;
  libSDL_SCANCODE_F2=SDL_SCANCODE_F2;
  libSDL_SCANCODE_F3=SDL_SCANCODE_F3;
  libSDL_SCANCODE_F4=SDL_SCANCODE_F4;
  libSDL_SCANCODE_F5=SDL_SCANCODE_F5;
  libSDL_SCANCODE_F6=SDL_SCANCODE_F6;
  libSDL_SCANCODE_F7=SDL_SCANCODE_F7;
  libSDL_SCANCODE_F8=SDL_SCANCODE_F8;
  libSDL_SCANCODE_F9=SDL_SCANCODE_F9;
  libSDL_SCANCODE_F10=SDL_SCANCODE_F10;
  libSDL_SCANCODE_F11=SDL_SCANCODE_F11;
  libSDL_SCANCODE_F12=SDL_SCANCODE_F12;
  libSDL_SCANCODE_RSHIFT=SDL_SCANCODE_RSHIFT;
  libSDL_SCANCODE_RALT=SDL_SCANCODE_RALT;
  libSDL_SCANCODE_RCTRL=SDL_SCANCODE_RCTRL;
  libSDL_SCANCODE_HOME=SDL_SCANCODE_HOME;
  libSDL_SCANCODE_RIGHT=SDL_SCANCODE_RIGHT;
  libSDL_SCANCODE_LEFT=SDL_SCANCODE_LEFT;
  libSDL_SCANCODE_DOWN=SDL_SCANCODE_DOWN;
  libSDL_SCANCODE_UP=SDL_SCANCODE_UP;
  libSDL_SCANCODE_INSERT=SDL_SCANCODE_INSERT;
  libSDL_SCANCODE_DELETE=SDL_SCANCODE_DELETE;
  libSDL_SCANCODE_RETURN=SDL_SCANCODE_RETURN;
  libSDL_SCANCODE_EQUALS=SDL_SCANCODE_EQUALS;
  libSDL_SCANCODE_SLASH=SDL_SCANCODE_SLASH;
  libSDL_SCANCODE_NONUSBACKSLASH=SDL_SCANCODE_NONUSBACKSLASH;
  libSDL_SCANCODE_APOSTROPHE=SDL_SCANCODE_APOSTROPHE;
  libSDL_SCANCODE_BACKSLASH=SDL_SCANCODE_BACKSLASH;
  libSDL_SCANCODE_MINUS=SDL_SCANCODE_MINUS;
  libSDL_SCANCODE_PERIOD=SDL_SCANCODE_PERIOD;
  libSDL_SCANCODE_comma=SDL_SCANCODE_COMMA;
  libSDL_SCANCODE_space=SDL_SCANCODE_space;
  libSDL_SCANCODE_escape=SDL_SCANCODE_escape;
  libSDL_SCANCODE_tab=SDL_SCANCODE_tab;
  libSDL_SCANCODE_CAPSLOCK=SDL_SCANCODE_CAPSLOCK;
  libSDL_SCANCODE_BACKSPACE=SDL_SCANCODE_BACKSPACE;
  libSDL_SCANCODE_SEMICOLON=SDL_SCANCODE_SEMICOLON;
  libSDL_SCANCODE_LCTRL = 224;
  libSDL_SCANCODE_LSHIFT = 225;
  libSDL_SCANCODE_LALT = 226;
  libSDL_SCANCODE_A = 4;
  libSDL_SCANCODE_B = 5;
  libSDL_SCANCODE_C = 6;
  libSDL_SCANCODE_D = 7;
  libSDL_SCANCODE_E = 8;
  libSDL_SCANCODE_F = 9;
  libSDL_SCANCODE_G = 10;
  libSDL_SCANCODE_H = 11;
  libSDL_SCANCODE_I = 12;
  libSDL_SCANCODE_J = 13;
  libSDL_SCANCODE_K = 14;
  libSDL_SCANCODE_L = 15;
  libSDL_SCANCODE_M = 16;
  libSDL_SCANCODE_N = 17;
  libSDL_SCANCODE_O = 18;
  libSDL_SCANCODE_P = 19;
  libSDL_SCANCODE_Q = 20;
  libSDL_SCANCODE_R = 21;
  libSDL_SCANCODE_S = 22;
  libSDL_SCANCODE_T = 23;
  libSDL_SCANCODE_U = 24;
  libSDL_SCANCODE_V = 25;
  libSDL_SCANCODE_W = 26;
  libSDL_SCANCODE_X = 27;
  libSDL_SCANCODE_Y = 28;
  libSDL_SCANCODE_Z = 29;
  libSDL_SCANCODE_1 = 30;
  libSDL_SCANCODE_2 = 31;
  libSDL_SCANCODE_3 = 32;
  libSDL_SCANCODE_4 = 33;
  libSDL_SCANCODE_5 = 34;
  libSDL_SCANCODE_6 = 35;
  libSDL_SCANCODE_7 = 36;
  libSDL_SCANCODE_8 = 37;
  libSDL_SCANCODE_9 = 38;
  libSDL_SCANCODE_0 = 39;

  libSDL_INIT_VIDEO=SDL_INIT_VIDEO;
  libSDL_INIT_JOYSTICK=SDL_INIT_JOYSTICK;
  libSDL_INIT_NOPARACHUTE=SDL_INIT_NOPARACHUTE;
  libSDL_HINT_GRAB_KEYBOARD=SDL_HINT_GRAB_KEYBOARD;
  libSDL_HINT_OVERRIDE=SDL_HINT_OVERRIDE;
  libSDL_INIT_AUDIO=SDL_INIT_AUDIO;
  libSDL_WINDOWPOS_UNDEFINED=SDL_WINDOWPOS_UNDEFINED;
  libSDL_WINDOW_FULLSCREEN=SDL_WINDOW_FULLSCREEN;

  libSDL_BLENDMODE_BLEND=SDL_BLENDMODE_BLEND;

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
  SDL_MapRGBA:TSDL_MapRGBA;
  SDL_GetKeyboardState:TSDL_GetKeyboardState;
  SDL_SetHintWithPriority:TSDL_SetHintWithPriority;
  SDL_SetHint:TSDL_SetHint;
  SDL_SetSurfaceBlendMode:TSDL_SetSurfaceBlendMode;
  {$ifndef windows}
  SDL_SetError:TSDL_SetError;
  SDL_GetError:TSDL_GetError;
  SDL_GetTicks:TSDL_GetTicks;
  SDL_SetWindowTitle:TSDL_SetWindowTitle;
  {$endif}

implementation

procedure Init_sdl_lib;
begin
{$ifdef darwin}
sdl_dll_Handle:=LoadLibrary('libSDL2.dylib');
{$endif}
{$ifdef linux}
sdl_dll_Handle:=LoadLibrary('libSDL2.so');
if sdl_dll_Handle=0 then sdl_dll_Handle:=LoadLibrary('libSDL2.so.0');
if sdl_dll_Handle=0 then sdl_dll_Handle:=LoadLibrary('libSDL2-2.0.so.0');
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
@SDL_SetSurfaceBlendMode:=GetProcAddress(sdl_dll_Handle,'SDL_SetSurfaceBlendMode');
//rwops
@SDL_RWFromFile:=GetProcAddress(sdl_dll_Handle,'SDL_RWFromFile');
//pixels
@SDL_GetRGB:=GetProcAddress(sdl_dll_Handle,'SDL_GetRGB');
@SDL_MapRGB:=GetProcAddress(sdl_dll_Handle,'SDL_MapRGB');
@SDL_MapRGBA:=GetProcAddress(sdl_dll_Handle,'SDL_MapRGBA');
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

end.

