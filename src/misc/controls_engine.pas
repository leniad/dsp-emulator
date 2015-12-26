unit controls_engine;

interface
uses lib_sdl2,main_engine,timer_engine{$ifdef windows},windows{$endif};

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
        coin,start,up,down,left,right,but0,but1,but2,but3,but4,but5:array[0..1] of boolean;
        ncoin,nstart,nup,ndown,nleft,nright,nbut0,nbut1,nbut2,nbut3,nbut4,nbut5,jbut0,jbut1,jbut2,jbut3,jbut4,jbut5:array[0..1] of word;
        use_key:array[0..1] of boolean;
        num_joystick:array[0..1] of byte;
        joy_ax0,joy_ax1:array[0..1] of integer;
        joy_ax0_cent,joy_ax1_cent:array[0..1] of integer;
    end;
    def_marcade=record
        in0,in1,in2,in3,in4,in5,in6,in7:word;
        dswa,dswb,dswc:word;
        dswa_val,dswb_val,dswc_val:pdef_dip;
    end;
    def_analog=record
        x,y:array[0..1] of integer;
        delta,mid_val,max_val,min_val:integer;
        return_center:boolean;
    end;

const
    cdata:array[0..63] of byte=(
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0);
    cmask:array[0..63] of byte=(
        3,192,15,240,28,56,56,28,
        113,142,225,135,193,131,206,115,
        206,115,193,131,225,135,113,142,
        56,28,28,56,15,240,3,192,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0);

var
    joystick_def:array[0..1] of libsdlp_joystick;
    raton:def_mouse;
    arcade_input:def_arcade;
    event:def_event;
    keyboard:array [0..255] of boolean;
    keystate:pbyte;
    marcade:def_marcade;
    old_cursor:libsdlP_cursor;
    analog:def_analog;

procedure evalue_controls;
procedure init_controls(evalue_mouse,evalue_keyboard,evalue_joystick,evalue_arcade:boolean);
procedure open_joystick(player:byte);
procedure close_joystick(num:byte);
//Analog
procedure init_analog(cpu:byte;cpu_clock:integer;sensitivity,port_delta,mid_val,max_val,min_val:integer;return_center:boolean);
procedure analog_read;

implementation
uses principal;

procedure open_joystick(player:byte);
begin
  joystick_def[player]:=SDL_JoystickOpen(arcade_input.num_joystick[player]);
end;

procedure close_joystick(num:byte);
begin
  SDL_JoystickClose(joystick_def[num]);
  joystick_def[num]:=nil;
end;

procedure init_controls(evalue_mouse,evalue_keyboard,evalue_joystick,evalue_arcade:boolean);
var
  f:byte;
begin
for f:=0 to 1 do begin
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
event.emouse:=evalue_mouse;
event.ekeyboard:=evalue_keyboard;
event.ejoystick:=evalue_joystick;
event.earcade:=evalue_arcade;
fillchar(keyboard[0],255,0);
if joystick_def[0]<>nil then close_joystick(arcade_input.num_joystick[0]);
if joystick_def[1]<>nil then close_joystick(arcade_input.num_joystick[1]);
open_joystick(0);
open_joystick(1);
if joystick_def[0]=nil then arcade_input.use_key[0]:=true;
if joystick_def[1]=nil then arcade_input.use_key[1]:=true;
end;

procedure evaluar_arcade_basic;
begin
if (arcade_input.coin[0]<>(keystate[arcade_input.ncoin[0] and $ff]<>0)) then begin
  arcade_input.coin[0]:=keystate[arcade_input.ncoin[0] and $ff]<>0;
  event.arcade:=true;
end;
if (arcade_input.coin[1]<>(keystate[arcade_input.ncoin[1] and $ff]<>0)) then begin
  arcade_input.coin[1]:=keystate[arcade_input.ncoin[1] and $ff]<>0;
  event.arcade:=true;
end;
if (arcade_input.start[0]<>(keystate[arcade_input.nstart[0] and $ff]<>0)) then begin
  arcade_input.start[0]:=keystate[arcade_input.nstart[0] and $ff]<>0;
  event.arcade:=true;
end;
if (arcade_input.start[1]<>(keystate[arcade_input.nstart[1] and $ff]<>0)) then begin
  arcade_input.start[1]:=keystate[arcade_input.nstart[1] and $ff]<>0;
  event.arcade:=true;
end;
end;

procedure evaluar_arcade_keyb(player:byte);
begin
if (arcade_input.up[player]<>(keystate[arcade_input.nup[player] and $ff]<>0)) then begin
    arcade_input.up[player]:=keystate[arcade_input.nup[player] and $ff]<>0;
    event.arcade:=true;
end;
if (arcade_input.down[player]<>(keystate[arcade_input.ndown[player] and $ff]<>0)) then begin
    arcade_input.down[player]:=keystate[arcade_input.ndown[player] and $ff]<>0;
    event.arcade:=true;
end;
if (arcade_input.up[player] and arcade_input.down[player]) then arcade_input.down[player]:=false;
if (arcade_input.left[player]<>(keystate[arcade_input.nleft[player] and $ff]<>0)) then begin
    arcade_input.left[player]:=keystate[arcade_input.nleft[player] and $ff]<>0;
    event.arcade:=true;
end;
if (arcade_input.right[player]<>(keystate[arcade_input.nright[player] and $ff]<>0)) then begin
    arcade_input.right[player]:=keystate[arcade_input.nright[player] and $ff]<>0;
    event.arcade:=true;
end;
if (arcade_input.left[player] and arcade_input.right[player]) then arcade_input.right[player]:=false;
if (arcade_input.but0[player]<>(keystate[arcade_input.nbut0[player] and $ff]<>0)) then begin
  arcade_input.but0[player]:=keystate[arcade_input.nbut0[player] and $ff]<>0;
  event.arcade:=true;
end;
if (arcade_input.but1[player]<>(keystate[arcade_input.nbut1[player] and $ff]<>0)) then begin
  arcade_input.but1[player]:=keystate[arcade_input.nbut1[player] and $ff]<>0;
  event.arcade:=true;
end;
if (arcade_input.but2[player]<>(keystate[arcade_input.nbut2[player] and $ff]<>0)) then begin
  arcade_input.but2[player]:=keystate[arcade_input.nbut2[player] and $ff]<>0;
  event.arcade:=true;
end;
if (arcade_input.but3[player]<>(keystate[arcade_input.nbut3[player] and $ff]<>0)) then begin
  arcade_input.but3[player]:=keystate[arcade_input.nbut3[player] and $ff]<>0;
  event.arcade:=true;
end;
if (arcade_input.but4[player]<>(keystate[arcade_input.nbut4[player] and $ff]<>0)) then begin
  arcade_input.but4[player]:=keystate[arcade_input.nbut4[player] and $ff]<>0;
  event.arcade:=true;
end;
if (arcade_input.but5[player]<>(keystate[arcade_input.nbut5[player] and $ff]<>0)) then begin
  arcade_input.but5[player]:=keystate[arcade_input.nbut5[player] and $ff]<>0;
  event.arcade:=true;
end;
end;

procedure evaluar_arcade_joy(tevent:integer;player:byte);
var
  valor:integer;
begin
if SDL_NumJoysticks=0 then exit;
SDL_JoystickUpdate();
case tevent of
  libSDL_JOYBUTTONDOWN,libSDL_JOYBUTTONUP:begin
    arcade_input.but0[player]:=SDL_JoystickGetButton(joystick_def[player],arcade_input.jbut0[player])<>0;
    arcade_input.but1[player]:=SDL_JoystickGetButton(joystick_def[player],arcade_input.jbut1[player])<>0;
    arcade_input.but2[player]:=SDL_JoystickGetButton(joystick_def[player],arcade_input.jbut2[player])<>0;
    arcade_input.but3[player]:=SDL_JoystickGetButton(joystick_def[player],arcade_input.jbut3[player])<>0;
    arcade_input.but4[player]:=SDL_JoystickGetButton(joystick_def[player],arcade_input.jbut4[player])<>0;
    arcade_input.but5[player]:=SDL_JoystickGetButton(joystick_def[player],arcade_input.jbut5[player])<>0;
    event.arcade:=true;
  end;
  libSDL_JOYAXISMOTION:begin
    valor:=SDL_JoystickGetAxis(joystick_def[player],0)-arcade_input.joy_ax0_cent[player];
    if valor<>arcade_input.joy_ax0[player] then begin
      event.arcade:=true;
      arcade_input.left[player]:=(valor<-3200);
      arcade_input.right[player]:=(valor>3200);
      arcade_input.joy_ax0[player]:=valor;
    end;
    valor:=SDL_JoystickGetAxis(joystick_def[player],1)-arcade_input.joy_ax1_cent[player];
    if valor<>arcade_input.joy_ax1[player] then begin
      event.arcade:=true;
      arcade_input.up[player]:=(valor<-3200);
      arcade_input.down[player]:=(valor>3200);
      arcade_input.joy_ax1[player]:=valor;
    end;
  end;
end;
end;

procedure evaluar_raton(tevent:libSDL_Event);
var
  sc_mul:byte;
function video_mult:byte;
begin
  case main_screen.video_mode of
    2,4:video_mult:=2;
    5:video_mult:=3;
    else video_mult:=1;
  end;
end;
begin
event.mouse:=false;
case tevent.type_ of
  libSDL_MOUSEMOTION:begin  //Movimiento
    sc_mul:=video_mult;
    raton.x:=tevent.motion.x div sc_mul;
    raton.y:=tevent.motion.y div sc_mul;
    event.mouse:=true;
  end;
  libSDL_MOUSEBUTTONUP:begin  //Levantar boton
    event.mouse:=true;
    case tevent.button.button of
        libSDL_BUTTON_LEFT:raton.button1:=false;
        libSDL_BUTTON_RIGHT:raton.button2:=false;
    end;
  end;
  libSDL_MOUSEBUTTONDOWN:begin
    event.mouse:=true;
    case tevent.button.button of
        libSDL_BUTTON_LEFT:raton.button1:=true;
        libSDL_BUTTON_RIGHT:raton.button2:=true;
    end;
  end;
end;
end;

procedure evalue_controls;
var
  sdl_event:libSDL_Event;
  f:word;
procedure evalue_joy;
begin
if arcade_input.use_key[0] then evaluar_arcade_keyb(0)
      else evaluar_arcade_joy(sdl_event.type_,0);
if arcade_input.use_key[1] then evaluar_arcade_keyb(1)
      else evaluar_arcade_joy(sdl_event.type_,1);
end;
begin
  if SDL_PollEvent(@sdl_event)=0 then exit;
  event.arcade:=false;
  event.keyboard:=false;
  event.mouse:=false;
  //Primero las teclas independientes de los drivers
  if ((keystate[libSDL_SCANCODE_F1]<>0) and not(keystate[libSDL_SCANCODE_RSHIFT]<>0)) then main_vars.service1:=not(main_vars.service1);
  if ((keystate[libSDL_SCANCODE_F2]<>0) and not(keystate[libSDL_SCANCODE_RSHIFT]<>0)) then principal1.fFast(nil);
  if ((keystate[libSDL_SCANCODE_F3]<>0) and not(keystate[libSDL_SCANCODE_RSHIFT]<>0)) then principal1.Reset1Click(nil);
  if ((keystate[libSDL_SCANCODE_F4]<>0) and not(main_screen.pantalla_completa) and not(keystate[libSDL_SCANCODE_RSHIFT]<>0)) then begin
      if @llamadas_maquina.grabar_snapshot<>nil then llamadas_maquina.grabar_snapshot;
  end;
  if ((keystate[libSDL_SCANCODE_F6]<>0) and not(keystate[libSDL_SCANCODE_RSHIFT]<>0)) then pasar_pantalla_completa;
  if ((keystate[libSDL_SCANCODE_F7]<>0) and not(keystate[libSDL_SCANCODE_RSHIFT]<>0)) then begin
    if @llamadas_maquina.save_qsnap<>nil then llamadas_maquina.save_qsnap('-01');
  end;
  if ((keystate[libSDL_SCANCODE_F8]<>0) and not(keystate[libSDL_SCANCODE_RSHIFT]<>0)) then begin
    if @llamadas_maquina.save_qsnap<>nil then llamadas_maquina.save_qsnap('-02');
  end;
  if ((keystate[libSDL_SCANCODE_F9]<>0) and not(keystate[libSDL_SCANCODE_RSHIFT]<>0)) then begin
    if @llamadas_maquina.load_qsnap<>nil then llamadas_maquina.load_qsnap('-01');
  end;
  if ((keystate[libSDL_SCANCODE_F10]<>0) and not(keystate[libSDL_SCANCODE_RSHIFT]<>0)) then begin
    if @llamadas_maquina.load_qsnap<>nil then llamadas_maquina.load_qsnap('-02');
  end;
  if (keystate[libSDL_SCANCODE_F11]<>0) then principal1.fSlow(nil);
  //Arcade
  if event.earcade then begin
    evaluar_arcade_basic;
    evalue_joy;
  end;
  //Raton
  if event.emouse then evaluar_raton(sdl_event);
  //Joy Stick
  if event.ejoystick then evalue_joy;
  //Teclado
  if event.ekeyboard then begin
    for f:=0 to $ff do
      if keyboard[f]<>(keystate[f]<>0) then begin
        event.keyboard:=true;
        copymemory(@keyboard[0],keystate,$100);
        break;
      end;
  end;
end;

procedure init_analog(cpu:byte;cpu_clock:integer;sensitivity,port_delta,mid_val,max_val,min_val:integer;return_center:boolean);
begin
init_timer(cpu,cpu_clock/sensitivity,analog_read,true);
analog.delta:=port_delta;
analog.mid_val:=mid_val;
analog.max_val:=max_val;
analog.min_val:=min_val;
analog.x[0]:=mid_val;
analog.y[0]:=mid_val;
analog.x[1]:=mid_val;
analog.y[1]:=mid_val;
analog.return_center:=return_center;
end;

procedure analog_read;
var
  f:byte;
begin
for f:=0 to 1 do begin
  if arcade_input.up[f] then analog.y[f]:=analog.y[f]+analog.delta;
  if arcade_input.down[f] then analog.y[f]:=analog.y[f]-analog.delta;
  if analog.y[f]>analog.max_val then analog.y[f]:=analog.max_val;
  if analog.y[f]<analog.min_val then analog.y[f]:=analog.min_val;
  if analog.return_center then begin
    if not(arcade_input.up[f]) then begin
      if analog.y[f]>analog.mid_val then begin
          analog.y[f]:=analog.y[f]-analog.delta;
          if analog.y[f]<analog.mid_val then analog.y[f]:=analog.mid_val;
      end;
    end;
    if not(arcade_input.down[f]) then begin
      if analog.y[f]<analog.mid_val then begin
          analog.y[f]:=analog.y[f]+analog.delta;
          if analog.y[f]>analog.mid_val then analog.y[f]:=analog.mid_val;
      end;
    end;
  end;
  if arcade_input.left[f] then analog.x[f]:=analog.x[f]+analog.delta;
  if arcade_input.right[f] then analog.x[f]:=analog.x[f]-analog.delta;
  if analog.x[f]>analog.max_val then analog.x[f]:=analog.max_val;
  if analog.x[f]<analog.min_val then analog.x[f]:=analog.min_val;
  if analog.return_center then begin
    if not(arcade_input.left[f]) then begin
      if analog.x[f]>analog.mid_val then begin
          analog.x[f]:=analog.x[f]-analog.delta;
          if analog.x[f]<analog.mid_val then analog.x[f]:=analog.mid_val;
      end;
    end;
    if not(arcade_input.right[f]) then begin
      if analog.x[f]<analog.mid_val then begin
          analog.x[f]:=analog.x[f]+analog.delta;
          if analog.x[f]>analog.mid_val then analog.x[f]:=analog.mid_val;
      end;
    end;
  end;
end;
end;

end.
