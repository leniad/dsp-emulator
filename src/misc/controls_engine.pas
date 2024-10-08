unit controls_engine;

interface

uses {$ifdef windows}windows,controls,{$endif}lib_sdl2,main_engine,
     {$ifdef fpc}sound_engine,{$else}uchild,{$endif}timer_engine,sysutils;

const
  NUM_PLAYERS=2-1;
  NUM_JOYSTICKS=10-1;
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
        mouse,keyboard,arcade:boolean;
        emouse,ejoystick,ekeyboard,earcade:boolean;
    end;
    def_arcade = record
        coin,start,up,down,left,right,but0,but1,but2,but3,but4,but5,use_key:array[0..NUM_PLAYERS] of boolean;
        ncoin,nstart,nup,ndown,nleft,nright,nbut0,nbut1,nbut2,nbut3,nbut4,nbut5,jcoin,jstart,jbut0,jbut1,jbut2,jbut3,jbut4,jbut5,num_joystick:array[0..NUM_PLAYERS] of byte;
        joy_y,joy_x:array[0..NUM_PLAYERS] of smallint;
    end;
    def_marcade=record
        in0,in1,in2,in3,in4:word;
        dswa,dswb,dswc:word;
        dswa_val,dswb_val,dswc_val:pdef_dip;
        dswa_val2,dswb_val2,dswc_val2:pdef_dip2;
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

var
    keyboard:array [0..255] of boolean;
    marcade:def_marcade;
    event:def_event;
    arcade_input:def_arcade;
    analog:def_analog;
    raton:def_mouse;
    joystick:def_joysticks;
    joystick_def:array[0..NUM_JOYSTICKS] of libsdlp_joystick;

procedure controls_start;
procedure evalue_controls;
procedure init_controls(evalue_mouse,evalue_keyboard,evalue_joystick,evalue_arcade:boolean);
//Joystick
procedure close_joystick;
//Mouse cursor
procedure show_mouse_cursor;
procedure hide_mouse_cursor;
//Analog
procedure init_analog(cpu:byte;cpu_clock:integer);
procedure reset_analog;
procedure analog_0(sensitivity,port_delta,mid_val,max_val,min_val:integer;return_center:boolean;circle:boolean=false;inverted_x:boolean=false;inverted_y:boolean=false);
procedure analog_1(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
procedure analog_2(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
procedure analog_3(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);
procedure analog_4(sensitivity,port_delta,max_val,min_val:integer;return_center:boolean);

implementation
uses principal;

var
  keystate:pbyte=nil;

procedure show_mouse_cursor;
{$ifdef fpc}
var
  new_cursor:libSDLP_Cursor;
begin
new_cursor:=SDL_CreateSystemcursor(3);
SDL_SetCursor(new_cursor);
SDL_ShowCursor(1);
{$else}
begin
//No funciona en delphi (se vuelve muuuuuuuuuy lento)
//child.Cursor:=crCross;
{$endif}
end;

procedure hide_mouse_cursor;
{$ifdef fpc}
var
  new_cursor:libSDLP_Cursor;
begin
new_cursor:=SDL_CreateSystemcursor(1);
SDL_SetCursor(new_cursor);
SDL_ShowCursor(1);
{$else}
begin
child.Cursor:=crDefault;
{$endif}
end;

procedure close_joystick;
var
  f:byte;
begin
for f:=0 to NUM_JOYSTICKS do begin
  if joystick_def[f]<>nil then begin
    SDL_JoystickClose(joystick_def[f]);
    joystick_def[f]:=nil;
  end;
end;
end;

procedure controls_start;
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
if keystate=nil then keystate:=pbyte(SDL_GetKeyboardState(nil));
//Abro los joysticks
close_joystick;
joystick.num:=SDL_NumJoysticks;
if joystick.num<>0 then begin
  for f:=0 to (joystick.num-1) do begin
    joystick_def[f]:=SDL_JoystickOpen(f);
    joystick.nombre[f]:=extract_joy_name(SDL_JoystickName(joystick_def[f]))+'-'+inttohex(f,1);
    joystick.buttons[f]:=sdl_joysticknumbuttons(joystick_def[f]);
  end;
  SDL_JoystickEventState(libSDL_DISABLE);
end;
for f:=0 to NUM_PLAYERS do if joystick_def[arcade_input.num_joystick[f]]=nil then arcade_input.use_key[f]:=true;
end;

procedure init_controls(evalue_mouse,evalue_keyboard,evalue_joystick,evalue_arcade:boolean);
var
  f:byte;
begin
event.emouse:=evalue_mouse;
event.ekeyboard:=evalue_keyboard;
event.ejoystick:=evalue_joystick;
event.earcade:=evalue_arcade;
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
event.keyboard:=false;
fillchar(keyboard[0],256,0);
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
      //System
      tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jcoin[player])<>0;
      if (arcade_input.coin[player]<>tempb) then begin
        arcade_input.coin[player]:=tempb;
        event.arcade:=true;
      end;
      tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jstart[player])<>0;
      if (arcade_input.start[player]<>tempb) then begin
        arcade_input.start[player]:=tempb;
        event.arcade:=true;
      end;
end;

procedure evaluar_arcade_joy(player:byte);
var
  valor:integer;
  tempb:boolean;
  player_joy:byte;
begin
SDL_JoystickUpdate;
player_joy:=arcade_input.num_joystick[player];
      //Buttons
      if timers.autofire_enabled[0+(player*6)] then begin
        timers.autofire_status[0+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut0[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut0[player])<>0;
        if arcade_input.but0[player]<>tempb then begin
          arcade_input.but0[player]:=tempb;
          event.arcade:=true;
        end;
      end;
      if timers.autofire_enabled[1+(player*6)] then begin
        timers.autofire_status[1+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut1[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut1[player])<>0;
        if arcade_input.but1[player]<>tempb then begin
          arcade_input.but1[player]:=tempb;
          event.arcade:=true;
        end;
      end;
      if timers.autofire_enabled[2+(player*6)] then begin
        timers.autofire_status[2+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut2[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut2[player])<>0;
        if arcade_input.but2[player]<>tempb then begin
          arcade_input.but2[player]:=tempb;
          event.arcade:=true;
        end;
      end;
      if timers.autofire_enabled[3+(player*6)] then begin
        timers.autofire_status[3+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut3[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut3[player])<>0;
        if arcade_input.but3[player]<>tempb then begin
          arcade_input.but3[player]:=tempb;
          event.arcade:=true;
        end;
      end;
      if timers.autofire_enabled[4+(player*6)] then begin
        timers.autofire_status[4+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut4[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut4[player])<>0;
        if arcade_input.but4[player]<>tempb then begin
          arcade_input.but4[player]:=tempb;
          event.arcade:=true;
        end;
      end;
      if timers.autofire_enabled[5+(player*6)] then begin
        timers.autofire_status[5+(player*6)]:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut5[player])<>0;
      end else begin
        tempb:=SDL_JoystickGetButton(joystick_def[player_joy],arcade_input.jbut5[player])<>0;
        if arcade_input.but5[player]<>tempb then begin
          arcade_input.but5[player]:=tempb;
          event.arcade:=true;
        end;
      end;
  //end;
//  libSDL_JOYAXISMOTION:begin
    valor:=SDL_JoystickGetAxis(joystick_def[player_joy],0);
    tempb:=valor<arcade_input.joy_x[player];
    if tempb<>arcade_input.left[player] then begin
      event.arcade:=true;
      arcade_input.left[player]:=tempb;
      arcade_input.right[player]:=false;
    end;
    tempb:=valor>arcade_input.joy_x[player];
    if tempb<>arcade_input.right[player] then begin
      event.arcade:=true;
      arcade_input.right[player]:=tempb;
      arcade_input.left[player]:=false;
    end;
    valor:=SDL_JoystickGetAxis(joystick_def[player_joy],1);
    tempb:=valor<arcade_input.joy_y[player];
    if tempb<>arcade_input.up[player] then begin
      event.arcade:=true;
      arcade_input.up[player]:=tempb;
      arcade_input.down[player]:=false;
    end;
    tempb:=valor>arcade_input.joy_y[player];
    if tempb<>arcade_input.down[player] then begin
      event.arcade:=true;
      arcade_input.down[player]:=tempb;
      arcade_input.up[player]:=false;
    end;
end;

procedure evalue_controls;
var
   f:byte;
   sdl_event:libSDL_Event;
begin
  event.arcade:=false;
  event.keyboard:=false;
  event.mouse:=false;
  //Joystick
  if (event.ejoystick or event.earcade) then begin
    for f:=0 to NUM_PLAYERS do begin
      if not(arcade_input.use_key[f]) then begin
        evaluar_arcade_joy(f);
        if event.earcade then evaluar_arcade_joy_extra(f);
      end;
    end;
  end;
  if SDL_PollEvent(@sdl_event)=0 then exit;
  {$ifdef fpc}
  if sdl_event.type_=libSDL_WINDOWEVENT then
    if ((sdl_event.window.event<>libSDL_WINDOWEVENT_ENTER) and (sdl_event.window.event<>libSDL_WINDOWEVENT_LEAVE)) then SDL_ClearQueuedAudio(sound_device);
  {$endif}
  //Rellenar el teclado interno
  //principal1.statusbar1.panels[2].text:=inttostr(analog.c[0].x[0]);
  for f:=0 to $ff do
      if keyboard[f]<>(keystate[f]<>0) then begin
        event.keyboard:=true;
        copymemory(@keyboard[0],keystate,$100);
        break;
      end;
  //Las teclas independientes de los drivers
  if event.keyboard then begin
     if keyboard[KEYBOARD_F1] then main_vars.service1:=not(main_vars.service1);
     if keyboard[KEYBOARD_F2] then principal1.fFast(nil);
     if keyboard[KEYBOARD_F3] then principal1.Reset1Click(nil);
     if (keyboard[KEYBOARD_F4] and not(main_screen.pantalla_completa)) then begin
        if @llamadas_maquina.grabar_snapshot<>nil then llamadas_maquina.grabar_snapshot;
        keystate[KEYBOARD_F4]:=0; //Cuando tiene que poner a 0 la tecla esta en el menu... Tengo que ponerla a 0 yo o cree que esta todo el rato pulsada!
     end;
     if keyboard[KEYBOARD_F6] then pasar_pantalla_completa;
     if keyboard[KEYBOARD_F7] then begin
        if @llamadas_maquina.save_qsnap<>nil then llamadas_maquina.save_qsnap('-01');
        keystate[KEYBOARD_F7]:=0;
     end;
     if keyboard[KEYBOARD_F8] then begin
        if @llamadas_maquina.save_qsnap<>nil then llamadas_maquina.save_qsnap('-02');
        keystate[KEYBOARD_F8]:=0;
     end;
     if keyboard[KEYBOARD_F9] then begin
        if @llamadas_maquina.load_qsnap<>nil then llamadas_maquina.load_qsnap('-01');
        keystate[KEYBOARD_F9]:=0;
     end;
     if keyboard[KEYBOARD_F10] then begin
        if @llamadas_maquina.load_qsnap<>nil then llamadas_maquina.load_qsnap('-02');
        keystate[KEYBOARD_F10]:=0;
     end;
     if keyboard[KEYBOARD_F11] then principal1.fSlow(nil);
  end;
  if (event.ejoystick or event.earcade) then begin
    for f:=0 to NUM_PLAYERS do begin
      if arcade_input.use_key[f] then begin
        if event.keyboard then begin
          evaluar_arcade_keyb(f);
          if event.earcade then evaluar_arcade_keyb_extra(f);
        end;
      end;
    end;
  end;
  //Raton
  if event.emouse then begin
    case sdl_event.type_ of
      libSDL_MOUSEMOTION:begin  //Movimiento
                            raton.x:=trunc(sdl_event.motion.x/main_screen.mouse_x);
                            raton.y:=trunc(sdl_event.motion.y/main_screen.mouse_y);
                            event.mouse:=true;
                         end;
      libSDL_MOUSEBUTTONUP:begin  //Levantar boton
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

procedure analog_read_0;
var
  f:byte;
begin
for f:=0 to NUM_PLAYERS do begin
    //EJE Y
  if analog.c[0].inverted_y then begin
     if arcade_input.down[f] then begin
        analog.c[0].y[f]:=analog.c[0].y[f]+analog.c[0].delta;
        if analog.c[0].circle then begin
          if analog.c[0].y[f]>analog.c[0].max_val then analog.c[0].y[f]:=analog.c[0].y[f]-analog.c[0].max_val;
        end else begin
          if analog.c[0].y[f]>analog.c[0].max_val then analog.c[0].y[f]:=analog.c[0].max_val;
        end;
     end;
    if arcade_input.up[f] then begin
        analog.c[0].y[f]:=analog.c[0].y[f]-analog.c[0].delta;
        if analog.c[0].circle then begin
          if analog.c[0].y[f]<analog.c[0].min_val then analog.c[0].y[f]:=analog.c[0].y[f]+analog.c[0].max_val;
        end else begin
          if analog.c[0].y[f]<analog.c[0].min_val then analog.c[0].y[f]:=analog.c[0].min_val;
        end;
    end;
    if analog.c[0].return_center then begin
      if not(arcade_input.down[f]) then begin
        if analog.c[0].y[f]>analog.c[0].mid_val then begin
          analog.c[0].y[f]:=analog.c[0].y[f]-analog.c[0].delta;
          if analog.c[0].y[f]<analog.c[0].mid_val then analog.c[0].y[f]:=analog.c[0].mid_val;
        end;
      end;
      if not(arcade_input.up[f]) then begin
        if analog.c[0].y[f]<analog.c[0].mid_val then begin
          analog.c[0].y[f]:=analog.c[0].y[f]+analog.c[0].delta;
          if analog.c[0].y[f]>analog.c[0].mid_val then analog.c[0].y[f]:=analog.c[0].mid_val;
        end;
      end;
    end;
  end else begin
    if arcade_input.up[f] then begin
      analog.c[0].y[f]:=analog.c[0].y[f]+analog.c[0].delta;
      if analog.c[0].circle then begin
        if analog.c[0].y[f]>analog.c[0].max_val then analog.c[0].y[f]:=analog.c[0].y[f]-analog.c[0].max_val;
      end else begin
        if analog.c[0].y[f]>analog.c[0].max_val then analog.c[0].y[f]:=analog.c[0].max_val;
      end;
    end;
    if arcade_input.down[f] then begin
      analog.c[0].y[f]:=analog.c[0].y[f]-analog.c[0].delta;
      if analog.c[0].circle then begin
        if analog.c[0].y[f]<analog.c[0].min_val then analog.c[0].y[f]:=analog.c[0].y[f]+analog.c[0].max_val;
      end else begin
        if analog.c[0].y[f]<analog.c[0].min_val then analog.c[0].y[f]:=analog.c[0].min_val;
      end;
    end;
    if analog.c[0].return_center then begin
      if not(arcade_input.up[f]) then begin
        if analog.c[0].y[f]>analog.c[0].mid_val then begin
          analog.c[0].y[f]:=analog.c[0].y[f]-analog.c[0].delta;
          if analog.c[0].y[f]<analog.c[0].mid_val then analog.c[0].y[f]:=analog.c[0].mid_val;
        end;
      end;
      if not(arcade_input.down[f]) then begin
        if analog.c[0].y[f]<analog.c[0].mid_val then begin
          analog.c[0].y[f]:=analog.c[0].y[f]+analog.c[0].delta;
          if analog.c[0].y[f]>analog.c[0].mid_val then analog.c[0].y[f]:=analog.c[0].mid_val;
        end;
      end;
    end;
  end;
  //EJE X
  if analog.c[0].inverted_x then begin
    if arcade_input.right[f] then begin
      analog.c[0].x[f]:=analog.c[0].x[f]+analog.c[0].delta;
      if analog.c[0].circle then begin
        if analog.c[0].x[f]>analog.c[0].max_val then analog.c[0].x[f]:=analog.c[0].x[f]-analog.c[0].max_val;
      end else begin
        if analog.c[0].x[f]>analog.c[0].max_val then analog.c[0].x[f]:=analog.c[0].max_val;
      end;
    end;
    if arcade_input.left[f] then begin
      analog.c[0].x[f]:=analog.c[0].x[f]-analog.c[0].delta;
      if analog.c[0].circle then begin
        if analog.c[0].x[f]<analog.c[0].min_val then analog.c[0].x[f]:=analog.c[0].x[f]+analog.c[0].max_val;
      end else begin
        if analog.c[0].x[f]<analog.c[0].min_val then analog.c[0].x[f]:=analog.c[0].min_val;
      end;
    end;
    if analog.c[0].return_center then begin
      if not(arcade_input.right[f]) then
        if analog.c[0].x[f]>analog.c[0].mid_val then begin
          analog.c[0].x[f]:=analog.c[0].x[f]-analog.c[0].delta;
          if analog.c[0].x[f]<analog.c[0].mid_val then analog.c[0].x[f]:=analog.c[0].mid_val;
        end;
      if not(arcade_input.left[f]) then
        if analog.c[0].x[f]<analog.c[0].mid_val then begin
          analog.c[0].x[f]:=analog.c[0].x[f]+analog.c[0].delta;
          if analog.c[0].x[f]>analog.c[0].mid_val then analog.c[0].x[f]:=analog.c[0].mid_val;
        end;
    end;
  end else begin
    if arcade_input.left[f] then begin
      analog.c[0].x[f]:=analog.c[0].x[f]+analog.c[0].delta;
      if analog.c[0].circle then begin
        if analog.c[0].x[f]>analog.c[0].max_val then analog.c[0].x[f]:=analog.c[0].x[f]-analog.c[0].max_val;
      end else begin
        if analog.c[0].x[f]>analog.c[0].max_val then analog.c[0].x[f]:=analog.c[0].max_val;
      end;
    end;
    if arcade_input.right[f] then begin
      analog.c[0].x[f]:=analog.c[0].x[f]-analog.c[0].delta;
      if analog.c[0].circle then begin
        if analog.c[0].x[f]>analog.c[0].max_val then analog.c[0].x[f]:=analog.c[0].x[f]+analog.c[0].max_val;
      end else begin
        if analog.c[0].x[f]<analog.c[0].min_val then analog.c[0].x[f]:=analog.c[0].min_val;
      end;
    end;
    if analog.c[0].return_center then begin
      if not(arcade_input.left[f]) then
        if analog.c[0].x[f]>analog.c[0].mid_val then begin
          analog.c[0].x[f]:=analog.c[0].x[f]-analog.c[0].delta;
          if analog.c[0].x[f]<analog.c[0].mid_val then analog.c[0].x[f]:=analog.c[0].mid_val;
        end;
      if not(arcade_input.right[f]) then
        if analog.c[0].x[f]<analog.c[0].mid_val then begin
          analog.c[0].x[f]:=analog.c[0].x[f]+analog.c[0].delta;
          if analog.c[0].x[f]>analog.c[0].mid_val then analog.c[0].x[f]:=analog.c[0].mid_val;
        end;
    end;
  end;
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
begin
analog.cpu:=cpu;
analog.clock:=cpu_clock;
end;

procedure reset_analog;
var
  f:byte;
begin
for f:=0 to NUM_PLAYERS do begin
    analog.c[0].x[f]:=analog.c[0].mid_val;
    analog.c[0].y[f]:=analog.c[0].mid_val;
    analog.c[1].val[f]:=analog.c[1].min_val;
    analog.c[2].val[f]:=analog.c[2].min_val;
    analog.c[3].val[f]:=analog.c[3].min_val;
    analog.c[4].val[f]:=analog.c[4].min_val;
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

end.
