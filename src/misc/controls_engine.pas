unit controls_engine;

interface

uses {$ifdef windows}controls,windows,{$endif}lib_sdl2,main_engine,sysutils,graphics;

const
  NUM_PLAYERS=3-1;
  NUM_JOYSTICKS=10-1;
  NUM_CONTROLS=8-1;
  KEYBOARD_A=4;
  KEYBOARD_B=5;
  KEYBOARD_C=6;
  KEYBOARD_D=7;
  KEYBOARD_E=8;
  KEYBOARD_F=9;
  KEYBOARD_G=10;
  KEYBOARD_H=11;
  KEYBOARD_I=12;
  KEYBOARD_J=13;
  KEYBOARD_K=14;
  KEYBOARD_L=15;
  KEYBOARD_M=16;
  KEYBOARD_N=17;
  KEYBOARD_O=18;
  KEYBOARD_P=19;
  KEYBOARD_Q=20;
  KEYBOARD_R=21;
  KEYBOARD_S=22;
  KEYBOARD_T=23;
  KEYBOARD_U=24;
  KEYBOARD_V=25;
  KEYBOARD_W=26;
  KEYBOARD_X=27;
  KEYBOARD_Y=28;
  KEYBOARD_Z=29;
  KEYBOARD_1=30;
  KEYBOARD_2=31;
  KEYBOARD_3=32;
  KEYBOARD_4=33;
  KEYBOARD_5=34;
  KEYBOARD_6=35;
  KEYBOARD_7=36;
  KEYBOARD_8=37;
  KEYBOARD_9=38;
  KEYBOARD_0=39;
  //
  KEYBOARD_RETURN=40;
  KEYBOARD_ESCAPE=41;
  KEYBOARD_BACKSPACE=42;
  KEYBOARD_TAB=43;
  KEYBOARD_SPACE=44;
  KEYBOARD_HOME=74;
  KEYBOARD_END=77;
  KEYBOARD_CAPSLOCK=57;
  KEYBOARD_AVPAG=78;
  //Modificadores
  KEYBOARD_LCTRL=224;
  KEYBOARD_LSHIFT=225;
  KEYBOARD_LALT=226;
  KEYBOARD_LWIN=227;
  KEYBOARD_RCTRL=228;
  KEYBOARD_RSHIFT=229;
  KEYBOARD_RALT=230;
  KEYBOARD_RWIN=231;
  //Cursor
  KEYBOARD_RIGHT=79;
  KEYBOARD_LEFT=80;
  KEYBOARD_DOWN=81;
  KEYBOARD_UP=82;
  //Resto de teclas
  KEYBOARD_FILA0_T0=53;
  KEYBOARD_FILA0_T1=45;
  KEYBOARD_FILA0_T2=46;
  KEYBOARD_FILA1_T1=47;
  KEYBOARD_FILA1_T2=48;
  KEYBOARD_FILA2_T1=51;
  KEYBOARD_FILA2_T2=52;
  KEYBOARD_FILA2_T3=49;
  KEYBOARD_FILA3_T0=100;
  KEYBOARD_FILA3_T1=54;
  KEYBOARD_FILA3_T2=55;
  KEYBOARD_FILA3_T3=56;
  //Funcion
  KEYBOARD_F1=58;
  KEYBOARD_F2=59;
  KEYBOARD_F3=60;
  KEYBOARD_F4=61;
  KEYBOARD_F5=62;
  KEYBOARD_F6=63;
  KEYBOARD_F7=64;
  KEYBOARD_F8=65;
  KEYBOARD_F9=66;
  KEYBOARD_F10=67;
  KEYBOARD_F11=68;
  KEYBOARD_F12=69;
  //Teclado Numerico
  KEYBOARD_NRETURN=88;
  KEYBOARD_N1=89;
  KEYBOARD_N2=90;
  KEYBOARD_N3=91;
  KEYBOARD_N4=92;
  KEYBOARD_N5=93;
  KEYBOARD_N6=94;
  KEYBOARD_N7=95;
  KEYBOARD_N8=96;
  KEYBOARD_N9=97;
  KEYBOARD_N0=98;
  KEYBOARD_NDOT=99;
  //Reservada la ultima para indicar que no hay tecla
  KEYBOARD_NONE=255;

type
    def_mouse = record
        x,y:word;
        button1,button2:boolean;
    end;
    def_event = record
        mouse,arcade:boolean;
        emouse:boolean;
    end;
    def_arcade = record
        coin,start,up,down,left,right,but0,but1,but2,but3,but4,but5,use_key:array[0..NUM_PLAYERS] of boolean;
        ncoin,nstart,nup,ndown,nleft,nright,nbut0,nbut1,nbut2,nbut3,nbut4,nbut5,num_joystick,ndef:array[0..NUM_PLAYERS] of byte;
        joy_y,joy_x:array[0..NUM_PLAYERS] of integer;
    end;
    def_marcade=record
        in0,in1,in2,in3,in4,in5:word;
        dswa,dswb,dswc:word;
        dswa_val,dswb_val,dswc_val:pdef_dip;
        dipsw_a,dipsw_b,dipsw_c:array of def_dip2;
    end;
    def_analog_control=record
        x,y:array[0..NUM_PLAYERS] of integer;
        val:array[0..NUM_PLAYERS] of integer;
        delta,mid_val,max_val,min_val:integer;
        return_center:boolean;
        circle:boolean;
        inverted_x,inverted_y:boolean;
    end;
    def_analog=record
        c:array[0..4] of def_analog_control;
        cpu:byte;
        clock:dword;
    end;
    def_joysticks=record
        num:byte;
        nombre:array[0..NUM_JOYSTICKS] of string;
        buttons:array[0..NUM_JOYSTICKS] of integer;
    end;
    defkeys_def=record
        coin,start,up,down,left,right,but0,but1,but2,but3,but4,but5:byte;
    end;

const
  crDiana=TCursor(1);

var
    keyboard:array [0..255] of boolean;
    marcade:def_marcade;
    event:def_event;
    arcade_input:def_arcade;
    analog:def_analog;
    raton:def_mouse;
    joystick:def_joysticks;
    joystick_def:array[0..NUM_JOYSTICKS] of libsdlp_joystick;
    defkeys:array[0..NUM_CONTROLS] of defkeys_def;

procedure controls_start;
procedure evalue_controls;
procedure init_mouse(evalue_mouse:boolean);
procedure reset_controls;
//Cursor
function CrearCursorDiana:HCURSOR;
//Joystick
procedure close_joystick;
procedure load_joysticks;
//Analog
procedure init_analog(cpu:byte;cpu_clock:integer);
procedure analog_0(sensitivity,port_delta,mid_val,max_val,min_val:integer;return_center:boolean;circle:boolean=false;inverted_x:boolean=false;inverted_y:boolean=false);
procedure analog_1(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
procedure analog_2(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
procedure analog_3(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
procedure analog_4(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
//DIPs
procedure init_dips(pos:byte;dip_sw:array of def_dip2;val:word);

implementation
uses principal,file_engine,timer_engine{$ifdef fpc},sound_engine{$endif};

var
  keystate:pbyte=nil;

type
  joystick_axis_state=record
    valid:boolean;
    raw:integer;
    normalized:double;
  end;
var
  axis_state:array[0..NUM_PLAYERS,0..1] of joystick_axis_state;

procedure close_joystick;
var
  f,axis:byte;
begin
for f:=0 to NUM_PLAYERS do
  for axis:=0 to 1 do begin
    axis_state[f,axis].valid:=false;
    axis_state[f,axis].normalized:=0;
  end;
for f:=0 to NUM_JOYSTICKS do begin
  if joystick_def[f]<>nil then begin
    SDL_JoystickClose(joystick_def[f]);
    joystick_def[f]:=nil;
  end;
end;
end;

function CrearCursorDiana:HCURSOR;
var
  AndMask:array[0..$7f] of byte;
  XorMask:array[0..$7f] of byte;
  X,Y,Dx,Dy,Dist2,Index:integer;
  BitMask:Byte;
procedure PintarPixel(PX,PY:Integer;Blanco:Boolean);
begin
    Index:=PY*4+(PX shr 3);
    BitMask:=$80 shr (PX and 7);
    // AND=0 hace opaco el píxel. XOR=0 negro; XOR=1 blanco
    AndMask[Index]:=AndMask[Index] and not BitMask;
    if Blanco then XorMask[Index]:=XorMask[Index] or BitMask
      else XorMask[Index]:=XorMask[Index] and not(BitMask);
end;
begin
  // Fondo transparente en una máscara monocroma
  FillChar(AndMask,SizeOf(AndMask),$FF);
  FillChar(XorMask,SizeOf(XorMask),0);
  // Brazos de la cruz, dejando libre la zona central
  for Y:=0 to 31 do
    if ((Y<=3) or (Y>=27)) then begin
      PintarPixel(15,Y,false);
      PintarPixel(14,Y,true);
    end;
  for X:=0 to 31 do
    if ((X<=3) or (X>=27)) then begin
      PintarPixel(X,15,false);
      PintarPixel(X,14,true);
    end;
  // Dos anillos concéntricos
  for Y:=0 to 31 do
    for X:=0 to 31 do begin
      Dx:=X-15;
      Dy:=Y-15;
      Dist2:=Dx*Dx+Dy*Dy;
      if ((Dist2>=100) and (Dist2<=121)) then PintarPixel(X,Y,false)
        else if ((Dist2>=81) and (Dist2<100)) then PintarPixel(X,Y,true)
              else if ((Dist2>=25) and (Dist2<=36)) then PintarPixel(X,Y,false)
                    else if ((Dist2>=16) and (Dist2<25)) then PintarPixel(X,Y,true);
    end;
  // Punto central
  PintarPixel(15,15,false);
  Result:=CreateCursor(HInstance,15,15,32,32,@AndMask[0],@XorMask[0]);
end;

procedure load_joysticks;
var
  f:byte;
function extract_joy_name(nombre:pansichar):string;
var
  ptemp:pbyte;
  cadena:string;
begin
  if nombre=nil then begin
    extract_joy_name:='None';
    exit;
  end;
  ptemp:=pbyte(nombre);
  cadena:='';
  while ptemp^<>0 do begin
    cadena:=cadena+chr(ptemp^);
    inc(ptemp);
  end;
  extract_joy_name:=cadena;
end;
begin
close_joystick;
joystick.num:=SDL_NumJoysticks;
if joystick.num<>0 then begin
  for f:=0 to (joystick.num-1) do begin
    joystick_def[f]:=SDL_JoystickOpen(f);
    joystick.nombre[f]:=extract_joy_name(SDL_JoystickName(joystick_def[f]));
    joystick.buttons[f]:=sdl_joysticknumbuttons(joystick_def[f]);
  end;
  SDL_JoystickEventState(libSDL_DISABLE);
end;
for f:=0 to NUM_PLAYERS do if joystick_def[arcade_input.num_joystick[f]]=nil then arcade_input.use_key[f]:=true;
end;

procedure controls_start;
begin
if keystate=nil then keystate:=pbyte(SDL_GetKeyboardState(nil));
load_joysticks;
end;

procedure init_mouse(evalue_mouse:boolean);
begin
if evalue_mouse then begin
  {$ifndef fpc}child.Cursor:=crDiana;{$endif}
  event.emouse:=true;
end else begin
  event.emouse:=false;
  {$ifndef fpc}child.Cursor:=crDefault;{$endif}
end;
end;

procedure evaluar_arcade_keyb_extra(player:byte);
begin
//System
if (arcade_input.coin[player]<>(keyboard[arcade_input.ncoin[player]])) then begin
  arcade_input.coin[player]:=keyboard[arcade_input.ncoin[player]];
  event.arcade:=true;
end;
if (arcade_input.start[player]<>(keyboard[arcade_input.nstart[player]])) then begin
  arcade_input.start[player]:=keyboard[arcade_input.nstart[player]];
  event.arcade:=true;
end;
end;

procedure evaluar_arcade_keyb(player:byte);
begin
//Joystick
if (arcade_input.up[player]<>(keyboard[arcade_input.nup[player]])) then begin
    arcade_input.up[player]:=keyboard[arcade_input.nup[player]];
    arcade_input.down[player]:=false;
    event.arcade:=true;
end;
if (arcade_input.down[player]<>(keyboard[arcade_input.ndown[player]])) then begin
    arcade_input.down[player]:=keyboard[arcade_input.ndown[player]];
    arcade_input.up[player]:=false;
    event.arcade:=true;
end;
if (arcade_input.left[player]<>(keyboard[arcade_input.nleft[player]])) then begin
    arcade_input.left[player]:=keyboard[arcade_input.nleft[player]];
    arcade_input.right[player]:=false;
    event.arcade:=true;
end;
if (arcade_input.right[player]<>(keyboard[arcade_input.nright[player]])) then begin
    arcade_input.right[player]:=keyboard[arcade_input.nright[player]];
    arcade_input.left[player]:=false;
    event.arcade:=true;
end;
//Botones
if timers.autofire_enabled[0+(player*6)] then begin
  timers.autofire_status[0+(player*6)]:=keyboard[arcade_input.nbut0[player]];
end else begin
  if (arcade_input.but0[player]<>(keyboard[arcade_input.nbut0[player]])) then begin
      arcade_input.but0[player]:=keyboard[arcade_input.nbut0[player]];
      event.arcade:=true;
  end;
end;
if timers.autofire_enabled[1+(player*6)] then begin
  timers.autofire_status[1+(player*6)]:=keyboard[arcade_input.nbut1[player]];
end else begin
  if (arcade_input.but1[player]<>(keyboard[arcade_input.nbut1[player]])) then begin
      arcade_input.but1[player]:=keyboard[arcade_input.nbut1[player]];
      event.arcade:=true;
  end;
end;
if timers.autofire_enabled[2+(player*6)] then begin
  timers.autofire_status[2+(player*6)]:=keyboard[arcade_input.nbut2[player]];
end else begin
  if (arcade_input.but2[player]<>(keyboard[arcade_input.nbut2[player]])) then begin
      arcade_input.but2[player]:=keyboard[arcade_input.nbut2[player]];
      event.arcade:=true;
  end;
end;
if timers.autofire_enabled[3+(player*6)] then begin
  timers.autofire_status[3+(player*6)]:=keyboard[arcade_input.nbut3[player]];
end else begin
  if (arcade_input.but3[player]<>(keyboard[arcade_input.nbut3[player]])) then begin
      arcade_input.but3[player]:=keyboard[arcade_input.nbut3[player]];
      event.arcade:=true;
  end;
end;
if timers.autofire_enabled[4+(player*6)] then begin
  timers.autofire_status[4+(player*6)]:=keyboard[arcade_input.nbut4[player]];
end else begin
  if (arcade_input.but4[player]<>(keyboard[arcade_input.nbut4[player]])) then begin
      arcade_input.but4[player]:=keyboard[arcade_input.nbut4[player]];
      event.arcade:=true;
  end;
end;
if timers.autofire_enabled[5+(player*6)] then begin
  timers.autofire_status[5+(player*6)]:=keyboard[arcade_input.nbut5[player]];
end else begin
  if (arcade_input.but5[player]<>(keyboard[arcade_input.nbut5[player]])) then begin
      arcade_input.but5[player]:=keyboard[arcade_input.nbut5[player]];
      event.arcade:=true;
  end;
end;
end;

procedure evaluar_arcade_joy_extra(player:byte);
var
  tempb:boolean;
  player_joy:byte;
begin
SDL_JoystickUpdate;
player_joy:=arcade_input.num_joystick[player];
if player_joy>NUM_JOYSTICKS then exit;
if joystick_def[player_joy]=nil then exit;
      //System
      tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.ncoin[player])<>0;
      if (arcade_input.coin[player]<>tempb) then begin
        arcade_input.coin[player]:=tempb;
        event.arcade:=true;
      end;
      tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nstart[player])<>0;
      if (arcade_input.start[player]<>tempb) then begin
        arcade_input.start[player]:=tempb;
        event.arcade:=true;
      end;
end;

procedure evaluar_arcade_joy(player:byte);
function normalized_axis(raw,minimum,center,maximum,deadzone:integer):double;
var
  lower_edge,upper_edge:Int64;
begin
  result:=0;
  lower_edge:=Int64(center)-deadzone;
  upper_edge:=Int64(center)+deadzone;
  if (deadzone<0) or (lower_edge<=minimum) or (upper_edge>=maximum) then exit;
  if raw<lower_edge then result:=(raw-lower_edge)/lower_edge-minimum
    else if raw>upper_edge then Result:=(raw-upper_edge)/maximum-upper_edge;
  if result<-1 then result:=-1
    else if result>1 then result:=1;
end;

procedure read_joystick_axes(player:byte);
var
  axis,physical_axis,player_joy,axis_count,center,raw:integer;
  valid:boolean;
  position:double;
begin
  player_joy:=arcade_input.num_joystick[player];
  axis_count:=0;
  if player_joy<=NUM_JOYSTICKS then
    if joystick_def[player_joy]<>nil then
      axis_count:=SDL_JoystickNumAxes(joystick_def[player_joy]);
  for axis:=0 to 1 do begin
    physical_axis:=axis;
    valid:=(physical_axis>=0) and (physical_axis<axis_count);
    raw:=0;
    position:=0;
    if valid then begin
      raw:=SDL_JoystickGetAxis(joystick_def[player_joy],physical_axis);
      // Preserve the legacy per-player center, adding a neutral band.
      if axis=0 then center:=arcade_input.joy_x[player]
      else center:=arcade_input.joy_y[player];
      position:=normalized_axis(raw,-32768,center,32767,4096);
    end;
    if (axis_state[player,axis].valid<>valid) or
       (axis_state[player,axis].normalized<>position) then event.arcade:=true;
    axis_state[player,axis].valid:=valid;
    axis_state[player,axis].raw:=raw;
    axis_state[player,axis].normalized:=position;
  end;
end;
var
  tempb:boolean;
  player_joy:byte;
begin
SDL_JoystickUpdate;
player_joy:=arcade_input.num_joystick[player];
read_joystick_axes(player);
// Keep digital directions for digital games and keyboard-style analog modes.
tempb:=axis_state[player,0].normalized<0;
if tempb<>arcade_input.left[player] then event.arcade:=true;
arcade_input.left[player]:=tempb;
tempb:=axis_state[player,0].normalized>0;
if tempb<>arcade_input.right[player] then event.arcade:=true;
arcade_input.right[player]:=tempb;
tempb:=axis_state[player,1].normalized<0;
if tempb<>arcade_input.up[player] then event.arcade:=true;
arcade_input.up[player]:=tempb;
tempb:=axis_state[player,1].normalized>0;
if tempb<>arcade_input.down[player] then event.arcade:=true;
arcade_input.down[player]:=tempb;
if player_joy>NUM_JOYSTICKS then exit;
if joystick_def[player_joy]=nil then exit;
      //Buttons
      if timers.autofire_enabled[0+(player*6)] then begin
        timers.autofire_status[0+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut0[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut0[player])<>0;
        if arcade_input.but0[player]<>tempb then begin
          arcade_input.but0[player]:=tempb;
          event.arcade:=true;
        end;
      end;
      if timers.autofire_enabled[1+(player*6)] then begin
        timers.autofire_status[1+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut1[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut1[player])<>0;
        if arcade_input.but1[player]<>tempb then begin
          arcade_input.but1[player]:=tempb;
          event.arcade:=true;
        end;
      end;
      if timers.autofire_enabled[2+(player*6)] then begin
        timers.autofire_status[2+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut2[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut2[player])<>0;
        if arcade_input.but2[player]<>tempb then begin
          arcade_input.but2[player]:=tempb;
          event.arcade:=true;
        end;
      end;
      if timers.autofire_enabled[3+(player*6)] then begin
        timers.autofire_status[3+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut3[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut3[player])<>0;
        if arcade_input.but3[player]<>tempb then begin
          arcade_input.but3[player]:=tempb;
          event.arcade:=true;
        end;
      end;
      if timers.autofire_enabled[4+(player*6)] then begin
        timers.autofire_status[4+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut4[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut4[player])<>0;
        if arcade_input.but4[player]<>tempb then begin
          arcade_input.but4[player]:=tempb;
          event.arcade:=true;
        end;
      end;
      if timers.autofire_enabled[5+(player*6)] then begin
        timers.autofire_status[5+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut5[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.nbut5[player])<>0;
        if arcade_input.but5[player]<>tempb then begin
          arcade_input.but5[player]:=tempb;
          event.arcade:=true;
        end;
      end;
end;

procedure evalue_controls;
var
  f:byte;
  sdl_event:libSDL_Event;
begin
  event.arcade:=false;
  event.mouse:=false;

  {principal1.statusbar1.Panels[2].Text:=
  'X='+IntToStr(analog.c[0].x[0])+
  ' Centro='+IntToStr(analog.c[0].mid_val)+
  ' Izq='+IntToStr(Ord(arcade_input.left[0]))+
  ' Der='+IntToStr(Ord(arcade_input.right[0]))+
  ' Retorno='+IntToStr(Ord(analog.c[0].return_center));}
  // Procesar todos los eventos pendientes.
  while SDL_PollEvent(@sdl_event)<>0 do begin
    {$ifdef fpc}
    if sdl_event.type_=libSDL_WINDOWEVENT then
      if ((sdl_event.window.event<>libSDL_WINDOWEVENT_ENTER) and (sdl_event.window.event<>libSDL_WINDOWEVENT_LEAVE)) then
        SDL_ClearQueuedAudio(sound_device);
    {$endif}
    // El raton se procesa por evento, dentro del bucle, puede haber muchos eventos!
    if event.emouse then begin
      case sdl_event.type_ of
        libSDL_MOUSEMOTION:begin
          raton.x:=trunc(sdl_event.motion.x/main_screen.mouse_x);
          raton.y:=trunc(sdl_event.motion.y/main_screen.mouse_y);
          event.mouse:=true;
        end;
        libSDL_MOUSEBUTTONUP:begin
          event.mouse:=true;
          case sdl_event.button.button of
            libSDL_BUTTON_LEFT:raton.button1:=false;
            libSDL_BUTTON_RIGHT:raton.button2:=false;
          end;
        end;
        libSDL_MOUSEBUTTONDOWN:begin
          event.mouse:=true;
          case sdl_event.button.button of
            libSDL_BUTTON_LEFT:raton.button1:=true;
            libSDL_BUTTON_RIGHT:raton.button2:=true;
          end;
        end;
      end;
    end;
  end;
  // Leer los mandos una sola vez, despues de procesar los eventos.
  for f:=0 to NUM_PLAYERS do begin
    if not arcade_input.use_key[f] then begin
      evaluar_arcade_joy(f);
      evaluar_arcade_joy_extra(f);
    end;
  end;
  // Actualizar el teclado aunque no hubiera eventos pendientes.
  for f:=0 to $ff do begin
    if keyboard[f]<>(keystate[f]<>0) then begin
      event.arcade:=true;
      copymemory(@keyboard[0],keystate,$100);
      break;
    end;
  end;
  // Evaluar los controles de teclado una sola vez.
  for f:=0 to NUM_PLAYERS do begin
    if arcade_input.use_key[f] and event.arcade then begin
      evaluar_arcade_keyb(f);
      evaluar_arcade_keyb_extra(f);
    end;
  end;
  if event.arcade then begin
     if keyboard[KEYBOARD_F1] then main_vars.service1:=not(main_vars.service1);
     if keyboard[KEYBOARD_F2] then principal1.fFast(nil);
     if keyboard[KEYBOARD_F3] then principal1.Reset1Click(nil);
     if (keyboard[KEYBOARD_F4] and not(main_screen.pantalla_completa)) then
        if @llamadas_maquina.grabar_snapshot<>nil then llamadas_maquina.grabar_snapshot;
     if keyboard[KEYBOARD_F6] then pasar_pantalla_completa;
     if keyboard[KEYBOARD_F7] then
        if @llamadas_maquina.save_qsnap<>nil then llamadas_maquina.save_qsnap('-01');
     if keyboard[KEYBOARD_F8] then
        if @llamadas_maquina.save_qsnap<>nil then llamadas_maquina.save_qsnap('-02');
     if keyboard[KEYBOARD_F9] then
        if @llamadas_maquina.load_qsnap<>nil then llamadas_maquina.load_qsnap('-01');
     if keyboard[KEYBOARD_F10] then
        if @llamadas_maquina.load_qsnap<>nil then llamadas_maquina.load_qsnap('-02');
     if keyboard[KEYBOARD_F11] then principal1.fSlow(nil);
  end;
end;

procedure analog_read_0;
function absolute_axis(player,axis:byte;inverted:boolean):integer;
var
  position:double;
  value:Int64;
begin
  position:=0;
  if axis_state[player,axis].valid then
    position:=axis_state[player,axis].normalized;
  // Existing polarity: left/up increase when inverted=false.
  if not inverted then position:=-position;
  if position<0 then
    value:=Int64(analog.c[0].mid_val)+Round(position*(analog.c[0].mid_val-analog.c[0].min_val))
  else value:=Int64(analog.c[0].mid_val)+Round(position*(analog.c[0].max_val-analog.c[0].mid_val));
  if value<analog.c[0].min_val then value:=analog.c[0].min_val;
  if value>analog.c[0].max_val then value:=analog.c[0].max_val;
  Result:=integer(value);
end;
procedure update_axis(var value:integer;positive_pressed,negative_pressed:boolean);
var
  next_value,range_size,offset:Int64;
begin
  next_value:=value;
  if positive_pressed<>negative_pressed then begin
    if positive_pressed then next_value:=next_value+analog.c[0].delta
    else next_value:=next_value-analog.c[0].delta;
  end else if (not positive_pressed) and analog.c[0].return_center then begin
    if next_value>analog.c[0].mid_val then begin
      next_value:=next_value-analog.c[0].delta;
      if next_value<analog.c[0].mid_val then next_value:=analog.c[0].mid_val;
    end else if next_value<analog.c[0].mid_val then begin
      next_value:=next_value+analog.c[0].delta;
      if next_value>analog.c[0].mid_val then next_value:=analog.c[0].mid_val;
    end;
  end;
  if analog.c[0].circle then begin
    range_size:=Int64(analog.c[0].max_val)-analog.c[0].min_val+1;
    if range_size<=0 then exit;
    offset:=(next_value-analog.c[0].min_val) mod range_size;
    if offset<0 then offset:=offset+range_size;
    next_value:=Int64(analog.c[0].min_val)+offset;
  end else begin
    if next_value>analog.c[0].max_val then next_value:=analog.c[0].max_val;
    if next_value<analog.c[0].min_val then next_value:=analog.c[0].min_val;
  end;
  value:=integer(next_value);
end;
var
  f:byte;
begin
  for f:=0 to NUM_PLAYERS do begin
    if (not arcade_input.use_key[f]) and (not analog.c[0].circle) then
      analog.c[0].y[f]:=absolute_axis(f,1,analog.c[0].inverted_y)
    else if analog.c[0].inverted_y then
      update_axis(analog.c[0].y[f],arcade_input.down[f],arcade_input.up[f])
    else update_axis(analog.c[0].y[f],arcade_input.up[f],arcade_input.down[f]);
    if (not arcade_input.use_key[f]) and (not analog.c[0].circle) then
      analog.c[0].x[f]:=absolute_axis(f,0,analog.c[0].inverted_x)
    else if analog.c[0].inverted_x then
      update_axis(analog.c[0].x[f],arcade_input.right[f],arcade_input.left[f])
    else update_axis(analog.c[0].x[f],arcade_input.left[f],arcade_input.right[f]);
  end;
end;

procedure analog_read_1;
var
  f:byte;
begin
for f:=0 to NUM_PLAYERS do begin
  if arcade_input.but0[f] then begin
    analog.c[1].val[f]:=analog.c[1].val[f]+analog.c[1].delta;
    if analog.c[1].val[f]>analog.c[1].max_val then analog.c[1].val[f]:=analog.c[1].max_val;
  end;
  if analog.c[1].return_center then begin
    if not(arcade_input.but0[f]) then begin
      if analog.c[1].val[f]>analog.c[1].min_val then begin
          analog.c[1].val[f]:=analog.c[1].val[f]-analog.c[1].delta;
          if analog.c[1].val[f]<analog.c[1].min_val then analog.c[1].val[f]:=analog.c[1].min_val;
      end;
    end;
  end;
end;
end;

procedure analog_read_2;
var
  f:byte;
begin
for f:=0 to NUM_PLAYERS do begin
  if arcade_input.but1[f] then begin
    analog.c[2].val[f]:=analog.c[2].val[f]+analog.c[2].delta;
    if analog.c[2].val[f]>analog.c[2].max_val then analog.c[2].val[f]:=analog.c[2].max_val;
  end;
  if analog.c[2].return_center then begin
    if not(arcade_input.but1[f]) then begin
      if analog.c[2].val[f]>analog.c[2].min_val then begin
          analog.c[2].val[f]:=analog.c[2].val[f]-analog.c[2].delta;
          if analog.c[2].val[f]<analog.c[2].min_val then analog.c[2].val[f]:=analog.c[2].min_val;
      end;
    end;
  end;
end;
end;

procedure analog_read_3;
var
  f:byte;
begin
for f:=0 to NUM_PLAYERS do begin
  if arcade_input.but2[f] then begin
    analog.c[3].val[f]:=analog.c[3].val[f]+analog.c[3].delta;
    if analog.c[3].val[f]>analog.c[3].max_val then analog.c[3].val[f]:=analog.c[3].max_val;
  end;
  if analog.c[3].return_center then begin
    if not(arcade_input.but2[f]) then begin
      if analog.c[3].val[f]>analog.c[3].min_val then begin
          analog.c[3].val[f]:=analog.c[3].val[f]-analog.c[3].delta;
          if analog.c[3].val[f]<analog.c[3].min_val then analog.c[3].val[f]:=analog.c[3].min_val;
      end;
    end;
  end;
end;
end;

procedure analog_read_4;
var
  f:byte;
begin
for f:=0 to NUM_PLAYERS do begin
  if arcade_input.but3[f] then begin
    analog.c[4].val[f]:=analog.c[4].val[f]+analog.c[4].delta;
    if analog.c[4].val[f]>analog.c[4].max_val then analog.c[4].val[f]:=analog.c[4].max_val;
  end;
  if analog.c[4].return_center then begin
    if not(arcade_input.but3[f]) then begin
      if analog.c[4].val[f]>analog.c[4].min_val then begin
          analog.c[4].val[f]:=analog.c[4].val[f]-analog.c[4].delta;
          if analog.c[4].val[f]<analog.c[4].min_val then analog.c[4].val[f]:=analog.c[4].min_val;
      end;
    end;
  end;
end;
end;

procedure init_analog(cpu:byte;cpu_clock:integer);
var
  player,axis:integer;
begin
  analog.cpu:=cpu;
  analog.clock:=cpu_clock;
  for player:=0 to NUM_PLAYERS do
    for axis:=0 to 1 do begin
      axis_state[player,axis].valid:=false;
      axis_state[player,axis].normalized:=0;
    end;
end;

procedure analog_0(sensitivity,port_delta,mid_val,max_val,min_val:integer;return_center:boolean;circle:boolean=false;inverted_x:boolean=false;inverted_y:boolean=false);
var
   f:byte;
begin
timers.init(analog.cpu,analog.clock/((4250000/analog.clock)*sensitivity),analog_read_0,nil,true);
analog.c[0].inverted_x:=inverted_x;
analog.c[0].inverted_y:=inverted_y;
analog.c[0].delta:=port_delta;
analog.c[0].mid_val:=mid_val;
analog.c[0].max_val:=max_val;
analog.c[0].min_val:=min_val;
analog.c[0].circle:=circle;
for f:=0 to NUM_PLAYERS do begin
    analog.c[0].x[f]:=mid_val;
    analog.c[0].y[f]:=mid_val;
end;
analog.c[0].return_center:=return_center;
end;

procedure analog_1(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
var
   f:byte;
begin
timers.init(analog.cpu,analog.clock/((4250000/analog.clock)*sensitivity),analog_read_1,nil,true);
analog.c[1].delta:=port_delta;
analog.c[1].max_val:=max_val;
analog.c[1].min_val:=min_val;
for f:=0 to NUM_PLAYERS do analog.c[1].val[f]:=min_val;
analog.c[1].return_center:=return_center;
end;

procedure analog_2(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
var
   f:byte;
begin
timers.init(analog.cpu,analog.clock/((4250000/analog.clock)*sensitivity),analog_read_2,nil,true);
analog.c[2].delta:=port_delta;
analog.c[2].max_val:=max_val;
analog.c[2].min_val:=min_val;
for f:=0 to NUM_PLAYERS do analog.c[2].val[f]:=min_val;
analog.c[2].return_center:=return_center;
end;

procedure analog_3(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
var
   f:byte;
begin
timers.init(analog.cpu,analog.clock/((4250000/analog.clock)*sensitivity),analog_read_3,nil,true);
analog.c[3].delta:=port_delta;
analog.c[3].max_val:=max_val;
analog.c[3].min_val:=min_val;
for f:=0 to NUM_PLAYERS do analog.c[3].val[f]:=min_val;
analog.c[3].return_center:=return_center;
end;

procedure analog_4(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
var
   f:byte;
begin
timers.init(analog.cpu,analog.clock/((4250000/analog.clock)*sensitivity),analog_read_4,nil,true);
analog.c[4].delta:=port_delta;
analog.c[4].max_val:=max_val;
analog.c[4].min_val:=min_val;
for f:=0 to NUM_PLAYERS do analog.c[4].val[f]:=min_val;
analog.c[4].return_center:=return_center;
end;

procedure init_dips(pos:byte;dip_sw:array of def_dip2;val:word);
var
  f,val_dw:word;
begin
  case pos of
    1:begin
        setlength(marcade.dipsw_a,length(dip_sw));
        for f:=0 to (length(dip_sw))-1 do marcade.dipsw_a[f]:=dip_sw[f];
        val_dw:=1;
        if file_ini_load_dip(val_dw) then marcade.dswa:=val_dw
          else marcade.dswa:=val;
    end;
    2:begin
        setlength(marcade.dipsw_b,length(dip_sw));
        for f:=0 to (length(dip_sw))-1 do marcade.dipsw_b[f]:=dip_sw[f];
        val_dw:=2;
        if file_ini_load_dip(val_dw) then marcade.dswb:=val_dw
          else marcade.dswb:=val;
    end;
    3:begin
        setlength(marcade.dipsw_c,length(dip_sw));
        for f:=0 to (length(dip_sw))-1 do marcade.dipsw_c[f]:=dip_sw[f];
        val_dw:=3;
        if file_ini_load_dip(val_dw) then marcade.dswc:=val_dw
          else marcade.dswc:=val;
    end;
  end;
end;

procedure reset_controls;
var
  f,axis:byte;
begin
for f:=0 to NUM_PLAYERS do begin
  arcade_input.up[f]:=false;
  arcade_input.down[f]:=false;
  arcade_input.left[f]:=false;
  arcade_input.right[f]:=false;
  arcade_input.but0[f]:=false;
  arcade_input.but1[f]:=false;
  arcade_input.but2[f]:=false;
  arcade_input.but3[f]:=false;
  arcade_input.but4[f]:=false;
  arcade_input.but5[f]:=false;
  arcade_input.coin[f]:=false;
  arcade_input.start[f]:=false;
end;
raton.button1:=false;
raton.button2:=false;
raton.x:=0;
raton.y:=0;
event.mouse:=false;
event.arcade:=false;
fillchar(keyboard[0],256,0);
for f:=0 to NUM_PLAYERS do begin
    for axis:=0 to 1 do begin
      axis_state[f,axis].valid:=false;
      axis_state[f,axis].normalized:=0;
    end;
    analog.c[0].x[f]:=analog.c[0].mid_val;
    analog.c[0].y[f]:=analog.c[0].mid_val;
    analog.c[1].val[f]:=analog.c[1].min_val;
    analog.c[2].val[f]:=analog.c[2].min_val;
    analog.c[3].val[f]:=analog.c[3].min_val;
    analog.c[4].val[f]:=analog.c[4].min_val;
end;
end;

end.
