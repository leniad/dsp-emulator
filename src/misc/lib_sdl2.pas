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
    //Audio
    TSDL_OpenAudio=function(desired:PSDL_AudioSpec;obtained:PSDL_AudioSpec):Integer;cdecl;
    TSDL_CloseAudio=procedure;cdecl;
    TSDL_QueueAudio=function (dev:TSDL_AudioDeviceID;const data:pointer;len:Uint32):Integer;cdecl;
    TSDL_PauseAudio=procedure (pause_on: Integer);cdecl;
    TSDL_MixAudio=procedure (dst:PUInt8;src:PUInt8;len:UInt32;volume:Integer);cdecl;
    TSDL_ClearQueuedAudio=procedure (dev:TSDL_AudioDeviceID);cdecl;
    TSDL_GetQueuedAudioSize=function (dev:TSDL_AudioDeviceID):UInt32;cdecl;

    libsdl_rect=Tsdl_rect;
    libsdlp_Surface=psdl_surface;
    libsdlp_joystick=psdl_joystick;
    libsdlP_cursor=PSDL_cursor;
    libSDL_Event=TSDL_Event;
    libsdlP_Window =PSDL_Window;
    libsdlP_AudioSpec=PSDL_AudioSpec;
    libsdl_AudioSpec=TSDL_AudioSpec;
    libSDL_AudioCallback=TSDL_AudioCallback;
    libSDL_puint8=PUint8;

const
  libAUDIO_S16=$8010;
  libSDL_JOYBUTTONDOWN=SDL_JOYBUTTONDOWN;
  libSDL_JOYBUTTONUP=SDL_JOYBUTTONUP;
  libSDL_JOYAXISMOTION=SDL_JOYAXISMOTION;
  libSDL_MOUSEMOTION=SDL_MOUSEMOTION;
  libSDL_MOUSEBUTTONDOWN=SDL_MOUSEBUTTONDOWN;
  libSDL_MOUSEBUTTONUP=SDL_MOUSEBUTTONUP;
  libSDL_BUTTON_LEFT=SDL_BUTTON_LEFT;
  libSDL_BUTTON_RIGHT=SDL_BUTTON_RIGHT;
  libSDL_KEYUP=SDL_KEYUP;
  libSDL_KEYDOWN=SDL_KEYDOWN;

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
  //Audio
  SDL_OpenAudio:TSDL_OpenAudio;
  SDL_CloseAudio:TSDL_CloseAudio;
  SDL_QueueAudio:TSDL_QueueAudio;
  SDL_PauseAudio:TSDL_PauseAudio;
  SDL_MixAudio:TSDL_MixAudio;
  SDL_ClearQueuedAudio:TSDL_ClearQueuedAudio;
  SDL_GetQueuedAudioSize:TSDL_GetQueuedAudioSize;

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
//Audio
@SDL_OpenAudio:=GetProcAddress(sdl_dll_Handle,'SDL_OpenAudio');
@SDL_CloseAudio:=GetProcAddress(sdl_dll_Handle,'SDL_CloseAudio');
@SDL_QueueAudio:=GetProcAddress(sdl_dll_Handle,'SDL_QueueAudio');
@SDL_PauseAudio:=GetProcAddress(sdl_dll_Handle,'SDL_PauseAudio');
@SDL_MixAudio:=GetProcAddress(sdl_dll_Handle,'SDL_MixAudio');
@SDL_ClearQueuedAudio:=GetProcAddress(sdl_dll_Handle,'SDL_ClearQueuedAudio');
@SDL_GetQueuedAudioSize:=GetProcAddress(sdl_dll_Handle,'SDL_GetQueuedAudioSize');
end;

procedure close_sdl_lib;
begin
if sdl_dll_handle<>0 then begin
   FreeLibrary(sdl_dll_Handle);
   sdl_dll_handle:=0;
end;
end;

end.

