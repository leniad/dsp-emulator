type
    {$IFNDEF WIN64}
    size_t=cardinal;
    {$ELSE}
    size_t=int64;
    {$ENDIF}
    libsdl_Bool=(SDL_FALSE,SDL_TRUE);
    libsdl_AudioDeviceID=cardinal;
    libsdl_Stdio=record
                  autoclose:libsdl_Bool;
	          fp:file;
               end;
    libsdl_Mem=record
                  base:pbyte;
	          here:pbyte;
	          stop:pbyte;
               end;
    libsdl_Unknown=record
                  data1:Pointer;
               end;
    libsdl_AndroidIO=record
                  fileNameRef:Pointer;
                  inputStreamRef:Pointer;
                  readableByteChannelRef:Pointer;
                  readMethod:Pointer;
                  assetFileDescriptorRef:Pointer;
                  position:LongInt;
                  size_:LongInt;
                  offset:LongInt;
                  fd:longint;
               end;
    libsdl_WindowsIOBuffer = record
                  data:Pointer;
	          size_:size_t;
	          left:size_t;
               end;
    libsdl_WindowsIO=record
                  append:libsdl_Bool;
                  h:Pointer;
                  buffer:libsdl_WindowsIOBuffer;
               end;
    libsdlp_RWops=^libsdl_RWops;
    libsdl_RWops=packed record
                  size_:size_t;
                  seek:function(context:libsdlp_RWops;offset:int64;whence:longint):int64;cdecl;
                  read:function(context:libsdlp_RWops;ptr:Pointer;size_:size_t;maxnum:size_t):size_t;cdecl;
                  write:function(context:libsdlp_RWops;const ptr:Pointer;size_:size_t;num:size_t):size_t;cdecl;
                  close:function(context:libsdlp_RWops):longint;cdecl;
                  _type:cardinal;
	          case Integer of
	               0:(stdio:libsdl_Stdio);
	               1:(mem:libsdl_Mem);
	               2:(unknown:libsdl_Unknown);
	               {$IFDEF ANDROID}
	               3:(androidio:libsdl_AndroidIO);
	               {$ENDIF}
	               {$IFDEF WINDOWS}
	               3:(windowsio:libsdl_WindowsIO);
	               {$ENDIF}
               end;
    libsdlWindowShapeMode=(ShapeModeDefault,ShapeModeBinarizeAlpha,ShapeModeReverseBinarizeAlpha,ShapeModeColorKey);
    libsdl_rect=record //TSDL_Rect
                  x,y:LongInt;
                  w,h:LongInt;
                end;
    libsdlp_rect=^libsdl_rect; //PSDL_Rect
    libsdlp_Color=^libsdl_Color; //PSDL_Color
    libsdl_Color=record
                  r:byte;
                  g:byte;
                  b:byte;
                  unused:byte;
                end;
    libsdlp_Palette=^libSDL_Palette; //PSDL_Palette
    libSDL_Palette=record  //TSDL_Palette
                  ncolors:LongInt;
                  colors:libsdlp_Color;
                  version:Cardinal;
                  refcount:LongInt;
                end;
    libsdlp_PixelFormat=^libSDL_PixelFormat; //PSDL_PixelFormat
    libSDL_PixelFormat=record //TSDL_PixelFormat
                  format:Cardinal;
                  palette:libsdlp_Palette;
                  BitsPerPixel:byte;
                  BytesPerPixel:byte;
                  padding:array[0..1] of byte;
                  Rmask:Cardinal;
                  Gmask:Cardinal;
                  Bmask:Cardinal;
                  Amask:Cardinal;
                  Rloss:byte;
                  Gloss:byte;
                  Bloss:byte;
                  Aloss:byte;
                  Rshift:byte;
                  Gshift:byte;
                  Bshift:byte;
                  Ashift:byte;
                  refcount:LongInt;
                  next:libsdlp_PixelFormat;
                end;
    libSDL_Surface=record //TSDL_Surface
                  flags:Cardinal;
                  format:libsdlp_PixelFormat;
                  w,h:LongInt;
                  pitch:LongInt;
                  pixels:Pointer;
                  userdata:Pointer;
                  locked:LongInt;
                  lock_data:Pointer;
                  clip_rect:libsdlp_rect;
                  map:Pointer;
                  refcount:LongInt;
                end;
    libsdlp_Surface=^libSDL_Surface; //PSDL_Surface
    libsdlp_joystick=pointer; //PSDL_Joystick;
    libsdlP_cursor=pointer; //PSDL_cursor;
    libsdl_DisplayMode = record //TSDL_DisplayMode
                  format:Cardinal;
                  w:LongInt;
                  h:LongInt;
                  refresh_rate:LongInt;
                  driverdata:Pointer;
                end;
    libsdlp_WindowShaper=^libsdl_WindowShaper; //PSDL_WindowShaper
    libsdlp_Window=^libsdl_Window; //PSDL_Window
    libsdl_WindowShapeParams=record
                  case Integer of
                       0:(binarizationCutoff:byte;);
                       1:(colorKey:libsdl_Color;);
                   end;
    libsdl_WindowShapeMode=record
                  mode:libsdlWindowShapeMode;
                  parameters:libsdl_WindowShapeParams;
                end;
    libsdl_WindowShaper=record
                  window:libsdlp_Window;
                  userx,usery:cardinal;
                  mode:libsdl_WindowShapeMode;
                  hasshape:libsdl_Bool;
                  driverdata:Pointer;
                end;
    libsdlp_WindowUserData=^libsdl_WindowUserData;
    libsdl_WindowUserData=record
                  name:PAnsiChar;
                  data:Pointer;
                  next:libsdlp_WindowUserData;
               end;
    libsdl_Window=record //TSDL_Window
                  magic:Pointer;
                  id:Cardinal;
                  title:PAnsiChar;
                  icon:libsdlp_Surface;
                  x,y:LongInt;
                  w,h:LongInt;
                  min_w,min_h:LongInt;
                  max_w,max_h:LongInt;
                  flags:Cardinal;
                  windowed:libsdl_Rect;
                  fullscreen_mode:libsdl_DisplayMode;
                  brightness:Single;
                  gamma:pword;
                  saved_gamma:pword;
                  surface:libsdlp_Surface;
                  surface_valid:libsdl_Bool;
                  shaper:libsdlp_WindowShaper;
                  data:libsdlp_WindowUserData;
                  driverdata:Pointer;
                  prev:libsdlp_Window;
                  next:libsdlp_Window;
                end;
    libsdlp_AudioSpec=^libsdl_AudioSpec;
    libsdl_AudioSpec=record //TSDL_AudioSpec
                  freq:Integer;
                  format:word; //TSDL_AudioFormat;
                  channels:byte;
                  silence:byte;
                  samples:word;
                  padding:word;
                  size_:cardinal;
                  callback:pointer;
                  userdata:Pointer;
                end;
    libSDLp_Event=^libSDL_Event;
    libsdl_TCommonEvent=record
                  type_:cardinal;
                  timestamp:cardinal;
                end;
    libsdl_TWindowEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   windowID:cardinal;
                   event:byte;
                   padding1:byte;
                   padding2:byte;
                   padding3:byte;
                   data1:LongInt;
                   data2:LongInt;
                end;
    libsdl_Keysym=record
                   scancode:dword; //TSDL_ScanCode;
                   sym:LongInt; //TSDL_KeyCode;
                   _mod:word;
                   unicode:cardinal;
                end;
    libsdl_KeyboardEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   windowID:cardinal;
                   state:byte;
                   _repeat:byte;
                   padding2:byte;
                   padding3:byte;
                   keysym:libsdl_KeySym;
                end;
    libsdl_TextEditingEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   windowID:cardinal;
                   text:array[0..32] of Char;
                   start:LongInt;
                   length:LongInt;
                end;
    libsdl_TextInputEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   windowID:cardinal;
                   text:array[0..32] of Char;
                end;
    libsdl_MouseMotionEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   windowID:cardinal;
                   which:cardinal;
                   state:byte;
                   padding1:byte;
                   padding2:byte;
                   padding3:byte;
                   x:LongInt;
                   y:longint;
                   xrel:longint;
                   yrel:longint;
                end;
    libsdl_MouseButtonEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   windowID:cardinal;
                   which:cardinal;
                   button:byte;
                   state:byte;
                   padding1:byte;
                   padding2:byte;
                   x:longint;
                   y:longint;
                end;
    libsdl_MouseWheelEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   windowID:cardinal;
                   which:cardinal;
                   x:longint;
                   y:longint;
                end;
    libsdl_JoyAxisEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   which:LongInt;//TSDL_JoystickID;
                   axis:byte;
                   padding1:byte;
                   padding2:byte;
                   padding3:byte;
                   value:smallint;
                   padding4:word;
                end;
    libsdl_JoyBallEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   which:longint;// TSDL_JoystickID;
                   ball:byte;
                   padding1:byte;
                   padding2:byte;
                   padding3:byte;
                   xrel:smallint;
                   yrel:smallint;
                end;
    libsdl_JoyHatEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   which:longint; // TSDL_JoystickID;
                   hat:byte;
                   value:byte;
                   padding1:byte;
                   padding2:byte;
                end;
    libsdl_JoyButtonEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   which:longint; //TSDL_JoystickID;
                   button:byte;
                   state:byte;
                   padding1:byte;
                   padding2:byte;
                end;
    libsdl_JoyDeviceEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   which:longint; //TSDL_JoystickID;
                end;
    libsdl_ControllerAxisEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   which:longint; //TSDL_JoystickID;
                   axis:byte;
                   padding1:byte;
                   padding2:byte;
                   padding3:byte;
                   value:smallint;
                   padding4:word;
                end;
    libsdl_ControllerButtonEvent = record
                   type_:cardinal;
                   timestamp:cardinal;
                   which:longint; //TSDL_JoystickID;
                   button:byte;
                   state:byte;
                   padding1:byte;
                   padding2:byte;
                end;
    libsdl_ControllerDeviceEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   which:longint;
                end;
    libsdl_TouchFingerEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   touchId:Int64; //TSDL_TouchID;
                   fingerId:Int64; //TSDL_FingerID;
                   x:Single;
                   y:Single;
                   dx:Single;
                   dy:Single;
                   pressure:Single;
                end;
    libsdl_QuitEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                end;
    libsdl_UserEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   windowID:cardinal;
                   code:longint;
                   data1:Pointer;
                   data2:Pointer;
                end;
    libsdl_Version=record
                   major,minor,patch:byte;
                end;
    libsdlp_SysWMmsg=^libsdl_SysWMmsg;
    {$IFDEF Windows}
    libsdl_SysWMmsg=record
                   version:libsdl_Version;
                   h_wnd:HWND;
                   msg:cardinal;
                   w_Param:WPARAM;
                   lParam:LPARAM;
                end;
    {$ELSE}
    {$IFDEF Unix}
    libsdl_SysWm=(SDL_SYSWM_X11);
    libsdl_SysWMmsg=record
                   version:libsdl_Version;
                   subsystem:libsdl_SysWm;
                   {$IFDEF FPC}
                     {$IFNDEF DARWIN}
                   event:TXEvent;
                     {$ENDIF}
                   {$ELSE}
                   event:XEvent;
                   {$ENDIF}
                end;
    {$ELSE}
    libsdl_SysWMmsg=record
                   version:libsdl_Version;
                   data:Integer;
                end;
    {$ENDIF}
    {$ENDIF}
    libsdl_SysWMEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   msg:libsdlp_SysWMmsg;
                end;
    libsdl_MultiGestureEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   touchId:Int64; //TSDL_TouchID;
                   dTheta:Single;
                   dDist:Single;
                   x:Single;
                   y:Single;
                   numFingers:word;
                   padding:word;
                end;
    libsdl_DollarGestureEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   touchId:int64; //TSDL_TouchID;
                   gestureId:int64; //TSDL_GestureID;
                   numFingers:cardinal;
                   error:Single;
                   x:Single;
                   y:Single;
                end;
    libsdl_DropEvent=record
                   type_:cardinal;
                   timestamp:cardinal;
                   _file:PAnsiChar;
                   end;
    libSDL_Event=record
                  case Integer of
                       0:(type_:cardinal);
                       libSDL_COMMONEVENT:(common:libsdl_TCommonEvent);
                       libSDL_WINDOWEVENT:(window:libsdl_TWindowEvent);
                       libSDL_KEYUP,libSDL_KEYDOWN:(key:libsdl_KeyboardEvent);
                       libSDL_TEXTEDITING:(edit:libsdl_TextEditingEvent);
                       libSDL_TEXTINPUT:(text:libsdl_TextInputEvent);
                       libSDL_MOUSEMOTION:(motion:libsdl_MouseMotionEvent);
                       libSDL_MOUSEBUTTONUP,libSDL_MOUSEBUTTONDOWN:(button:libsdl_MouseButtonEvent);
                       libSDL_MOUSEWHEEL:(wheel:libsdl_MouseWheelEvent);
                       libSDL_JOYAXISMOTION:(jaxis:libsdl_JoyAxisEvent);
                       libSDL_JOYBALLMOTION:(jball:libsdl_JoyBallEvent);
                       libSDL_JOYHATMOTION:(jhat:libsdl_JoyHatEvent);
                       libSDL_JOYBUTTONDOWN,libSDL_JOYBUTTONUP:(jbutton:libsdl_JoyButtonEvent);
                       libSDL_JOYDEVICEADDED,libSDL_JOYDEVICEREMOVED:(jdevice:libsdl_JoyDeviceEvent);
                       libSDL_CONTROLLERAXISMOTION:(caxis:libsdl_ControllerAxisEvent);
                       libSDL_CONTROLLERBUTTONUP,libSDL_CONTROLLERBUTTONDOWN:(cbutton:libsdl_ControllerButtonEvent);
                       libSDL_CONTROLLERDEVICEADDED,libSDL_CONTROLLERDEVICEREMOVED,libSDL_CONTROLLERDEVICEREMAPPED:(cdevice:libsdl_ControllerDeviceEvent);
                       libSDL_QUITEV:(quit:libsdl_QuitEvent);
                       libSDL_TUSEREVENT:(user:libsdl_UserEvent);
                       libSDL_TSYSWMEVENT:(syswm:libsdl_SysWMEvent);
                       libSDL_FINGERDOWN,libSDL_FINGERUP,libSDL_FINGERMOTION:(tfinger:libsdl_TouchFingerEvent);
                       libSDL_MULTIGESTURE:(mgesture:libsdl_MultiGestureEvent);
                       libSDL_DOLLARGESTURE,libSDL_DOLLARRECORD:(dgesture:libsdl_DollarGestureEvent);
                       libSDL_DROPFILE:(drop:libsdl_DropEvent);
                end;
