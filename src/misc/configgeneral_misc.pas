unit configgeneral_misc;

interface
uses controls_engine,sysutils,lib_sdl2,config_general,forms,redefine,principal,
     main_engine,lenguaje,sound_engine,timer_engine;

procedure read_button(boton,player:byte);
procedure read_dir(boton:byte);
procedure configgeneral_formshow;
procedure configgeneral_formclose;
procedure configeneral_autofire;
procedure select_keyboard_p1;
procedure select_keyboard_p2;
procedure select_joystick_p1;
procedure select_joystick_p2;

implementation

function nombre_tecla(num:word):string;
begin
  case num of
    KEYBOARD_ESCAPE:nombre_tecla:='ESC';
    KEYBOARD_CAPSLOCK:nombre_tecla:='CAPSLOCK';
    KEYBOARD_TAB:nombre_tecla:='TAB';
    //KEYBOARD_SLASH:nombre_tecla:='SLASH';
    //KEYBOARD_QUOTE:nombre_tecla:='QUOTE';
    //KEYBOARD_SEMICOLON:nombre_tecla:='SEMICOLON';
    //KEYBOARD_BACKSLASH:nombre_tecla:='DELETE';
    //KEYBOARD_LESS:nombre_tecla:='LESS';
    KEYBOARD_HOME:nombre_tecla:='HOME';
    KEYBOARD_RIGHT:nombre_tecla:='RIGHT';
    KEYBOARD_LEFT:nombre_tecla:='LEFT';
    KEYBOARD_DOWN:nombre_tecla:='DOWN';
    KEYBOARD_UP:nombre_tecla:='UP';
    KEYBOARD_RALT:nombre_tecla:='RIGHT'+chr(10)+chr(13)+'ALT';
    KEYBOARD_LALT:nombre_tecla:='LEFT'+chr(10)+chr(13)+'ALT';
    KEYBOARD_RSHIFT:nombre_tecla:='RIGHT'+chr(10)+chr(13)+'SHIFT';
    KEYBOARD_LSHIFT:nombre_tecla:='LEFT'+chr(10)+chr(13)+'SHIFT';
    KEYBOARD_RCTRL:nombre_tecla:='RIGHT'+chr(10)+chr(13)+'CONTROL';
    KEYBOARD_LCTRL:nombre_tecla:='LEFT'+chr(10)+chr(13)+'CONTROL';
    KEYBOARD_RETURN:nombre_tecla:='ENTER';
    KEYBOARD_SPACE:nombre_tecla:='SPACE';
    KEYBOARD_A:nombre_tecla:='A';
    KEYBOARD_B:nombre_tecla:='B';
    KEYBOARD_C:nombre_tecla:='C';
    KEYBOARD_D:nombre_tecla:='D';
    KEYBOARD_E:nombre_tecla:='E';
    KEYBOARD_F:nombre_tecla:='F';
    KEYBOARD_G:nombre_tecla:='G';
    KEYBOARD_H:nombre_tecla:='H';
    KEYBOARD_I:nombre_tecla:='I';
    KEYBOARD_J:nombre_tecla:='J';
    KEYBOARD_K:nombre_tecla:='K';
    KEYBOARD_L:nombre_tecla:='L';
    KEYBOARD_M:nombre_tecla:='M';
    KEYBOARD_N:nombre_tecla:='N';
    KEYBOARD_O:nombre_tecla:='O';
    KEYBOARD_P:nombre_tecla:='P';
    KEYBOARD_Q:nombre_tecla:='Q';
    KEYBOARD_R:nombre_tecla:='R';
    KEYBOARD_S:nombre_tecla:='S';
    KEYBOARD_T:nombre_tecla:='T';
    KEYBOARD_U:nombre_tecla:='U';
    KEYBOARD_V:nombre_tecla:='V';
    KEYBOARD_W:nombre_tecla:='W';
    KEYBOARD_X:nombre_tecla:='X';
    KEYBOARD_Y:nombre_tecla:='Y';
    KEYBOARD_Z:nombre_tecla:='Z';
    KEYBOARD_1:nombre_tecla:='1';
    KEYBOARD_2:nombre_tecla:='2';
    KEYBOARD_3:nombre_tecla:='3';
    KEYBOARD_4:nombre_tecla:='4';
    KEYBOARD_5:nombre_tecla:='5';
    KEYBOARD_6:nombre_tecla:='6';
    KEYBOARD_7:nombre_tecla:='7';
    KEYBOARD_8:nombre_tecla:='8';
    KEYBOARD_9:nombre_tecla:='9';
    KEYBOARD_0:nombre_tecla:='0';
    KEYBOARD_NONE:nombre_tecla:='N/D';
    else nombre_tecla:='N/D';
  end;
end;

function nombre_boton(boton:byte):string;
begin
  if boton=255 then nombre_boton:='None'
    else nombre_boton:=inttostr(boton);
end;

function get_button(player,button:byte):byte;
var
  f,res:byte;
  tempb,salir:boolean;
  time1,time2:cardinal;
  tempstr:string;
begin
salir:=false;
time1:=sdl_getticks;
while not(salir) do begin
  SDL_JoystickUpdate;
  application.ProcessMessages;
  if salir then break;
  time2:=sdl_getticks;
  if ((time2-time1)>5000) then begin
    get_button:=$ff;
    exit;
  end;
  tempstr:='Press Btn ('+inttostr(5-((time2-time1) div 1000))+')';
  case button of
    9:mconfig.BitBtn9.Caption:=tempstr;
    10:mconfig.BitBtn10.Caption:=tempstr;
    11:mconfig.BitBtn11.Caption:=tempstr;
    12:mconfig.BitBtn12.Caption:=tempstr;
    13:mconfig.BitBtn13.Caption:=tempstr;
    14:mconfig.BitBtn14.Caption:=tempstr;
    15:mconfig.BitBtn15.Caption:=tempstr;
    16:mconfig.BitBtn16.Caption:=tempstr;
    17:mconfig.BitBtn17.Caption:=tempstr;
    18:mconfig.BitBtn18.Caption:=tempstr;
    19:mconfig.BitBtn19.Caption:=tempstr;
    20:mconfig.BitBtn20.Caption:=tempstr;
    23:mconfig.BitBtn23.Caption:=tempstr;
    24:mconfig.BitBtn24.Caption:=tempstr;
    25:mconfig.BitBtn25.Caption:=tempstr;
    26:mconfig.BitBtn26.Caption:=tempstr;
  end;
  for f:=0 to joystick.buttons[player]-1 do begin
    tempb:=SDL_JoystickGetButton(joystick_def[player],f)=1;
    if tempb then begin
      res:=f;
      salir:=true;
    end;
  end;
end;
get_button:=res;
end;

procedure read_button(boton,player:byte);
begin
if config_button then exit;
config_button:=true;
if arcade_input.use_key[player] then begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    case boton of
      9:begin
          mconfig.bitbtn9.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut0[0]:=tecla_leida;
      end;
      10:begin
          mconfig.bitbtn10.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut1[0]:=tecla_leida;
        end;
      11:begin
          mconfig.bitbtn11.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut2[0]:=tecla_leida;
      end;
      12:begin
          mconfig.bitbtn12.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut0[1]:=tecla_leida;
      end;
      13:begin
          mconfig.bitbtn13.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut1[1]:=tecla_leida;
      end;
      14:begin
          mconfig.bitbtn14.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut2[1]:=tecla_leida;
      end;
      15:begin
          mconfig.bitbtn15.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut4[0]:=tecla_leida;
      end;
      16:begin
          mconfig.bitbtn16.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut5[0]:=tecla_leida;
      end;
      17:begin
          mconfig.bitbtn17.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut3[0]:=tecla_leida;
      end;
      18:begin
          mconfig.bitbtn18.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut3[1]:=tecla_leida;
      end;
      19:begin
          mconfig.bitbtn19.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut4[1]:=tecla_leida;
      end;
      20:begin
          mconfig.bitbtn20.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nbut5[1]:=tecla_leida;
      end;
      23:begin
          mconfig.bitbtn23.Caption:=nombre_tecla(tecla_leida);
          arcade_input.ncoin[0]:=tecla_leida;
      end;
      24:begin
          mconfig.BitBtn24.Caption:=nombre_tecla(tecla_leida);
          arcade_input.nstart[0]:=tecla_leida;
      end;
    25:begin
        mconfig.BitBtn25.Caption:=nombre_tecla(tecla_leida);
        arcade_input.ncoin[1]:=tecla_leida;
      end;
    26:begin
        mconfig.BitBtn26.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nstart[1]:=tecla_leida;
    end;
    end;
  end;
end else begin
  case boton of
    9:begin
        arcade_input.jbut0[0]:=get_button(arcade_input.num_joystick[0],9);
        mconfig.bitbtn9.Caption:=nombre_boton(arcade_input.jbut0[0]);
    end;
    10:begin
        arcade_input.jbut1[0]:=get_button(arcade_input.num_joystick[0],10);
        mconfig.bitbtn10.Caption:=nombre_boton(arcade_input.jbut1[0]);
       end;
    11:begin
        arcade_input.jbut2[0]:=get_button(arcade_input.num_joystick[0],11);
        mconfig.bitbtn11.Caption:=nombre_boton(arcade_input.jbut2[0]);
    end;
    12:begin
        arcade_input.jbut0[1]:=get_button(arcade_input.num_joystick[1],12);
        mconfig.bitbtn12.Caption:=nombre_boton(arcade_input.jbut0[1]);
    end;
    13:begin
        arcade_input.jbut1[1]:=get_button(arcade_input.num_joystick[1],13);
        mconfig.bitbtn13.Caption:=nombre_boton(arcade_input.jbut1[1]);
    end;
    14:begin
        arcade_input.jbut2[1]:=get_button(arcade_input.num_joystick[1],14);
        mconfig.bitbtn14.Caption:=nombre_boton(arcade_input.jbut2[1]);
    end;
    15:begin
        arcade_input.jbut4[0]:=get_button(arcade_input.num_joystick[0],15);
        mconfig.bitbtn15.Caption:=nombre_boton(arcade_input.jbut4[0]);
    end;
    16:begin
        arcade_input.jbut5[0]:=get_button(arcade_input.num_joystick[0],16);
        mconfig.bitbtn16.Caption:=nombre_boton(arcade_input.jbut5[0]);
    end;
    17:begin
        arcade_input.jbut3[0]:=get_button(arcade_input.num_joystick[0],17);
        mconfig.bitbtn17.Caption:=nombre_boton(arcade_input.jbut3[0]);
    end;
    18:begin
        arcade_input.jbut3[1]:=get_button(arcade_input.num_joystick[1],18);
        mconfig.bitbtn18.Caption:=nombre_boton(arcade_input.jbut3[1]);
    end;
    19:begin
        arcade_input.jbut4[1]:=get_button(arcade_input.num_joystick[1],19);
        mconfig.bitbtn19.Caption:=nombre_boton(arcade_input.jbut4[1]);
    end;
    20:begin
        arcade_input.jbut5[1]:=get_button(arcade_input.num_joystick[1],20);
        mconfig.bitbtn20.Caption:=nombre_boton(arcade_input.jbut5[1]);
    end;
    23:begin
        arcade_input.jcoin[0]:=get_button(arcade_input.num_joystick[0],23);
        mconfig.bitbtn23.Caption:=nombre_boton(arcade_input.jcoin[0]);
    end;
    24:begin
        arcade_input.jstart[0]:=get_button(arcade_input.num_joystick[0],24);
        mconfig.BitBtn24.Caption:=nombre_boton(arcade_input.jstart[0]);
    end;
    25:begin
        arcade_input.jcoin[1]:=get_button(arcade_input.num_joystick[1],25);
        mconfig.BitBtn25.Caption:=nombre_boton(arcade_input.jcoin[1]);
    end;
    26:begin
        arcade_input.jstart[1]:=get_button(arcade_input.num_joystick[1],26);
        mconfig.BitBtn26.Caption:=nombre_boton(arcade_input.jstart[1]);
    end;
  end;
end;
config_button:=false
end;

procedure read_dir(boton:byte);
begin
redefine1.showmodal;
if tecla_leida<>$ffff then begin
  case boton of
    1:begin
        mconfig.bitbtn1.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nleft[0]:=tecla_leida;
    end;
    2:begin
        mconfig.bitbtn2.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nright[0]:=tecla_leida;
    end;
    3:begin
        mconfig.bitbtn3.Caption:=nombre_tecla(tecla_leida);
        arcade_input.ndown[0]:=tecla_leida;
    end;
    4:begin
        mconfig.bitbtn4.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nup[0]:=tecla_leida;
    end;
    5:begin
        mconfig.bitbtn5.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nup[1]:=tecla_leida;
    end;
    6:begin
        mconfig.bitbtn6.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nleft[1]:=tecla_leida;
    end;
    7:begin
        mconfig.bitbtn7.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nright[1]:=tecla_leida;
    end;
    8:begin
        mconfig.bitbtn8.Caption:=nombre_tecla(tecla_leida);
        arcade_input.ndown[1]:=tecla_leida;
    end;
  end;
end;
end;

procedure configgeneral_formshow;
var
  f:integer;
begin
  f:=(principal1.left+(principal1.width div 2))-(MConfig.Width div 2);
  if f<0 then MConfig.Left:=0
    else MConfig.Left:=f;
  f:=(principal1.top+(principal1.Height div 2))-(MConfig.Height div 2);
  if f<0 then MConfig.Top:=0
    else MConfig.Top:=f;
  idioma_antes:=main_vars.idioma;
  config_button:=false;
  //idioma
  case main_vars.idioma of
    0:mconfig.radiobutton5.Checked:=true;
    1:mconfig.radiobutton6.Checked:=true;
    2:mconfig.radiobutton7.Checked:=true;
    3:mconfig.radiobutton8.Checked:=true;
    4:mconfig.radiobutton9.Checked:=true;
    5:mconfig.radiobutton10.Checked:=true;
    6:mconfig.radiobutton11.Checked:=true;
    200:mconfig.radiobutton12.Checked:=true;
  end;
  {$ifndef fpc}
  mconfig.Speedbutton1.Caption:=leng.archivo[2];
  mconfig.Speedbutton2.Caption:=leng.archivo[2];
  mconfig.Speedbutton4.Caption:=leng.archivo[2];
  mconfig.Speedbutton5.Caption:=leng.archivo[2];
  mconfig.Speedbutton6.Caption:=leng.archivo[2];
  mconfig.Speedbutton8.Caption:=leng.archivo[2];
  {$endif}
  //audio
  if sound_status.sonido_activo then mconfig.radiobutton14.Checked:=true
    else mconfig.radiobutton15.Checked:=true;
  //video
  case main_screen.video_mode of
    0:mconfig.groupbox5.Enabled:=false;
    1:mconfig.radiobutton16.Checked:=true;
    2:mconfig.radiobutton17.Checked:=true;
    3:mconfig.radiobutton18.Checked:=true;
    4:mconfig.radiobutton19.Checked:=true;
    5:mconfig.radiobutton20.Checked:=true;
  end;
  //Autoload
  mconfig.checkbox2.Checked:=main_vars.auto_exec;
  //Mostar errores CRC
  mconfig.checkbox1.Checked:=main_vars.show_crc_error;
  //Centrar Pantalla
  mconfig.checkbox3.Checked:=main_vars.center_screen;
  //Consolas init
  mconfig.checkbox17.Checked:=main_vars.console_init;
  //Diretorios
  mconfig.D1.Text:=Directory.Preview;
  mconfig.D2.Text:=Directory.Arcade_samples;
  mconfig.D3.Text:=Directory.Arcade_nvram;
  mconfig.D4.Text:=get_all_dirs;
  mconfig.D5.Text:=Directory.Arcade_hi;
  mconfig.D6.Text:=Directory.qsnapshot;
  //Componer todas las entradas
  if joystick.num=0 then begin
    mconfig.radiobutton1.Checked:=true;
    mconfig.radiobutton2.Checked:=false;
    mconfig.radiobutton2.enabled:=false;
    mconfig.button7.Enabled:=false;
    mconfig.radiobutton3.Checked:=true;
    mconfig.radiobutton4.Checked:=false;
    mconfig.radiobutton4.enabled:=false;
    mconfig.button8.Enabled:=false;
    mconfig.combobox1.Enabled:=false;
    mconfig.combobox1.Clear;
    mconfig.combobox2.Enabled:=false;
    mconfig.combobox2.Clear;
  end else begin
    mconfig.combobox1.Clear;
    mconfig.combobox2.Clear;
    for f:=0 to (joystick.num-1) do begin
      mconfig.combobox1.Items.Add(joystick.nombre[f]);
      mconfig.combobox2.Items.Add(joystick.nombre[f]);
    end;
    mconfig.radiobutton2.enabled:=true;
    mconfig.radiobutton4.enabled:=true;
    mconfig.combobox1.ItemIndex:=arcade_input.num_joystick[0];
    mconfig.combobox2.ItemIndex:=arcade_input.num_joystick[1];
  end;
  if arcade_input.use_key[0] then begin
    mconfig.radiobutton1.Checked:=true;
    mconfig.radiobutton2.Checked:=false;
    mconfig.combobox1.Enabled:=false;
    mconfig.button7.Enabled:=false;
    mconfig.bitbtn1.Enabled:=true;
    mconfig.bitbtn2.Enabled:=true;
    mconfig.bitbtn3.Enabled:=true;
    mconfig.bitbtn4.Enabled:=true;
    mconfig.bitbtn9.Caption:=nombre_tecla(arcade_input.nbut0[0]);
    mconfig.bitbtn10.Caption:=nombre_tecla(arcade_input.nbut1[0]);
    mconfig.bitbtn11.Caption:=nombre_tecla(arcade_input.nbut2[0]);
    mconfig.bitbtn17.Caption:=nombre_tecla(arcade_input.nbut3[0]);
    mconfig.bitbtn15.Caption:=nombre_tecla(arcade_input.nbut4[0]);
    mconfig.bitbtn16.Caption:=nombre_tecla(arcade_input.nbut5[0]);
    mconfig.bitbtn1.Caption:=nombre_tecla(arcade_input.nleft[0]);
    mconfig.bitbtn2.Caption:=nombre_tecla(arcade_input.nright[0]);
    mconfig.bitbtn3.Caption:=nombre_tecla(arcade_input.ndown[0]);
    mconfig.bitbtn4.Caption:=nombre_tecla(arcade_input.nup[0]);
    //Misc Keys
    mconfig.BitBtn23.Caption:=nombre_tecla(arcade_input.ncoin[0]);
    mconfig.BitBtn24.Caption:=nombre_tecla(arcade_input.nstart[0]);
  end else begin
    mconfig.radiobutton1.Checked:=false;
    mconfig.radiobutton2.Checked:=true;
    mconfig.button7.Enabled:=true;
    mconfig.bitbtn1.Enabled:=false;
    mconfig.bitbtn2.Enabled:=false;
    mconfig.bitbtn3.Enabled:=false;
    mconfig.bitbtn4.Enabled:=false;
    mconfig.bitbtn7.enabled:=true;
    mconfig.bitbtn1.Caption:='LEFT';
    mconfig.bitbtn2.Caption:='RIGHT';
    mconfig.bitbtn3.Caption:='DOWN';
    mconfig.bitbtn4.Caption:='UP';
    mconfig.bitbtn9.Caption:=nombre_boton(arcade_input.jbut0[0]);
    mconfig.bitbtn10.Caption:=nombre_boton(arcade_input.jbut1[0]);
    mconfig.bitbtn11.Caption:=nombre_boton(arcade_input.jbut2[0]);
    mconfig.bitbtn17.Caption:=nombre_boton(arcade_input.jbut3[0]);
    mconfig.bitbtn15.Caption:=nombre_boton(arcade_input.jbut4[0]);
    mconfig.bitbtn16.Caption:=nombre_boton(arcade_input.jbut5[0]);
    //Misc Keys
    mconfig.BitBtn23.Caption:=nombre_boton(arcade_input.jcoin[0]);
    mconfig.BitBtn24.Caption:=nombre_boton(arcade_input.jstart[0]);
  end;
  if arcade_input.use_key[1] then begin
    mconfig.radiobutton3.Checked:=true;
    mconfig.radiobutton4.Checked:=false;
    mconfig.combobox2.Enabled:=false;
    mconfig.button8.Enabled:=false;
    mconfig.bitbtn5.Enabled:=true;
    mconfig.bitbtn6.Enabled:=true;
    mconfig.bitbtn7.Enabled:=true;
    mconfig.bitbtn8.Enabled:=true;
    mconfig.bitbtn12.Caption:=nombre_tecla(arcade_input.nbut0[1]);
    mconfig.bitbtn13.Caption:=nombre_tecla(arcade_input.nbut1[1]);
    mconfig.bitbtn14.Caption:=nombre_tecla(arcade_input.nbut2[1]);
    mconfig.bitbtn18.Caption:=nombre_tecla(arcade_input.nbut3[1]);
    mconfig.bitbtn19.Caption:=nombre_tecla(arcade_input.nbut4[1]);
    mconfig.bitbtn20.Caption:=nombre_tecla(arcade_input.nbut5[1]);
    mconfig.bitbtn6.Caption:=nombre_tecla(arcade_input.nleft[1]);
    mconfig.bitbtn7.Caption:=nombre_tecla(arcade_input.nright[1]);
    mconfig.bitbtn8.Caption:=nombre_tecla(arcade_input.ndown[1]);
    mconfig.bitbtn5.Caption:=nombre_tecla(arcade_input.nup[1]);
    //Misc keys
    mconfig.BitBtn25.Caption:=nombre_tecla(arcade_input.ncoin[1]);
    mconfig.BitBtn26.Caption:=nombre_tecla(arcade_input.nstart[1]);
  end else begin
    mconfig.radiobutton3.Checked:=false;
    mconfig.radiobutton4.Checked:=true;
    mconfig.combobox2.Enabled:=true;
    mconfig.button8.Enabled:=true;
    mconfig.bitbtn5.Enabled:=false;
    mconfig.bitbtn6.Enabled:=false;
    mconfig.bitbtn7.Enabled:=false;
    mconfig.bitbtn8.Enabled:=false;
    mconfig.bitbtn6.Caption:='LEFT';
    mconfig.bitbtn7.Caption:='RIGHT';
    mconfig.bitbtn8.Caption:='DOWN';
    mconfig.bitbtn5.Caption:='UP';
    mconfig.bitbtn12.Caption:=nombre_boton(arcade_input.jbut0[1]);
    mconfig.bitbtn13.Caption:=nombre_boton(arcade_input.jbut1[1]);
    mconfig.bitbtn14.Caption:=nombre_boton(arcade_input.jbut2[1]);
    mconfig.bitbtn18.Caption:=nombre_boton(arcade_input.jbut3[1]);
    mconfig.bitbtn19.Caption:=nombre_boton(arcade_input.jbut4[1]);
    mconfig.bitbtn20.Caption:=nombre_boton(arcade_input.jbut5[1]);
    //Misc keys
    mconfig.BitBtn25.Caption:=nombre_boton(arcade_input.jcoin[1]);
    mconfig.BitBtn26.Caption:=nombre_boton(arcade_input.jstart[1]);
  end;
  mconfig.checkbox4.Checked:=timers.autofire_enabled[0];
  mconfig.checkbox5.Checked:=timers.autofire_enabled[1];
  mconfig.checkbox6.Checked:=timers.autofire_enabled[2];
  mconfig.checkbox7.Checked:=timers.autofire_enabled[3];
  mconfig.checkbox8.Checked:=timers.autofire_enabled[4];
  mconfig.checkbox9.Checked:=timers.autofire_enabled[5];
  mconfig.checkbox10.Checked:=timers.autofire_enabled[6];
  mconfig.checkbox11.Checked:=timers.autofire_enabled[7];
  mconfig.checkbox12.Checked:=timers.autofire_enabled[8];
  mconfig.checkbox13.Checked:=timers.autofire_enabled[9];
  mconfig.checkbox14.Checked:=timers.autofire_enabled[10];
  mconfig.checkbox15.Checked:=timers.autofire_enabled[11];
  mconfig.checkbox16.Checked:=timers.autofire_on;
  mconfig.CheckBox16Click(nil);
end;

procedure configgeneral_formclose;
var
  tmp_var:byte;
begin
  Directory.Preview:=mconfig.D1.Text;
  if mconfig.d1.Text[length(mconfig.d1.Text)]<>main_vars.cadena_dir then Directory.Preview:=Directory.Preview+main_vars.cadena_dir;
  Directory.Arcade_samples:=mconfig.D2.Text;
  if mconfig.d2.Text[length(mconfig.d2.Text)]<>main_vars.cadena_dir then Directory.Arcade_samples:=Directory.Arcade_samples+main_vars.cadena_dir;
  Directory.Arcade_nvram:=mconfig.D3.Text;
  if mconfig.d3.Text[length(mconfig.d3.Text)]<>main_vars.cadena_dir then Directory.Arcade_nvram:=Directory.Arcade_nvram+main_vars.cadena_dir;
  split_dirs(mconfig.D4.Text);
  Directory.Arcade_hi:=mconfig.D5.Text;
  if mconfig.d5.Text[length(mconfig.d5.Text)]<>main_vars.cadena_dir then Directory.Arcade_hi:=Directory.Arcade_hi+main_vars.cadena_dir;
  Directory.qsnapshot:=mconfig.D6.Text;
  if mconfig.d6.Text[length(mconfig.d6.Text)]<>main_vars.cadena_dir then Directory.qsnapshot:=Directory.qsnapshot+main_vars.cadena_dir;
  if mconfig.radiobutton5.Checked then main_vars.idioma:=0
    else if mconfig.radiobutton6.Checked then main_vars.idioma:=1
      else if mconfig.radiobutton7.Checked then main_vars.idioma:=2
        else if mconfig.radiobutton8.Checked then main_vars.idioma:=3
          else if mconfig.radiobutton9.Checked then main_vars.idioma:=4
            else if mconfig.radiobutton10.Checked then main_vars.idioma:=5
              else if mconfig.radiobutton11.Checked then main_vars.idioma:=6
                else if mconfig.radiobutton12.Checked then main_vars.idioma:=200;
  sound_status.sonido_activo:=mconfig.radiobutton14.Checked;
  principal1.SinSonido1.Checked:=not(mconfig.radiobutton14.Checked);
  principal1.ConSonido1.Checked:=mconfig.radiobutton14.Checked;
  if mconfig.groupbox5.Enabled then begin
    if mconfig.radiobutton16.Checked then tmp_var:=1
      else if mconfig.radiobutton17.Checked then tmp_var:=2
        else if mconfig.radiobutton18.Checked then tmp_var:=3
          else if mconfig.radiobutton19.Checked then tmp_var:=4
            else if mconfig.radiobutton20.Checked then tmp_var:=5;
    if tmp_var<>main_screen.video_mode then begin
      if main_vars.driver_ok then begin
        if tmp_var=6 then pasar_pantalla_completa
          else begin
            main_screen.old_video_mode:=main_screen.video_mode;
            main_screen.video_mode:=tmp_var;
            cambiar_video;
          end;
      end;
    end;
  end;
  main_vars.auto_exec:=mconfig.checkbox2.Checked;
  main_vars.show_crc_error:=mconfig.checkbox1.Checked;
  main_vars.center_screen:=mconfig.checkbox3.Checked;
  main_vars.console_init:=mconfig.checkbox17.Checked;
//Arreglar entradas arcade
  arcade_input.use_key[0]:=mconfig.radiobutton1.Checked;
  arcade_input.use_key[1]:=mconfig.radiobutton3.Checked;
  arcade_input.num_joystick[0]:=mconfig.combobox1.ItemIndex;
  arcade_input.num_joystick[1]:=mconfig.combobox2.ItemIndex;
  timers.autofire_on:=mconfig.checkbox16.Checked;
  if timers.autofire_on then begin
    timers.autofire_enabled[0]:=mconfig.checkbox4.Checked;
    timers.autofire_enabled[1]:=mconfig.checkbox5.Checked;
    timers.autofire_enabled[2]:=mconfig.checkbox6.Checked;
    timers.autofire_enabled[3]:=mconfig.checkbox7.Checked;
    timers.autofire_enabled[4]:=mconfig.checkbox8.Checked;
    timers.autofire_enabled[5]:=mconfig.checkbox9.Checked;
    timers.autofire_enabled[6]:=mconfig.checkbox10.Checked;
    timers.autofire_enabled[7]:=mconfig.checkbox11.Checked;
    timers.autofire_enabled[8]:=mconfig.checkbox12.Checked;
    timers.autofire_enabled[9]:=mconfig.checkbox13.Checked;
    timers.autofire_enabled[10]:=mconfig.checkbox14.Checked;
    timers.autofire_enabled[11]:=mconfig.checkbox15.Checked;
  end else for tmp_var:=0 to 11 do timers.autofire_enabled[tmp_var]:=false;
end;

procedure select_keyboard_p1;
begin
  mconfig.bitbtn1.Enabled:=true;
  mconfig.bitbtn2.Enabled:=true;
  mconfig.bitbtn3.Enabled:=true;
  mconfig.bitbtn4.Enabled:=true;
  mconfig.combobox1.enabled:=false;
  mconfig.button7.Enabled:=false;
  mconfig.bitbtn9.Caption:=nombre_tecla(arcade_input.nbut0[0]);
  mconfig.bitbtn10.Caption:=nombre_tecla(arcade_input.nbut1[0]);
  mconfig.bitbtn11.Caption:=nombre_tecla(arcade_input.nbut2[0]);
  mconfig.bitbtn17.Caption:=nombre_tecla(arcade_input.nbut3[0]);
  mconfig.bitbtn15.Caption:=nombre_tecla(arcade_input.nbut4[0]);
  mconfig.bitbtn16.Caption:=nombre_tecla(arcade_input.nbut5[0]);
  //Player 1
  mconfig.bitbtn1.Caption:=nombre_tecla(arcade_input.nleft[0]);
  mconfig.bitbtn2.Caption:=nombre_tecla(arcade_input.nright[0]);
  mconfig.bitbtn3.Caption:=nombre_tecla(arcade_input.ndown[0]);
  mconfig.bitbtn4.Caption:=nombre_tecla(arcade_input.nup[0]);
  //Misc Keys
  mconfig.BitBtn23.Caption:=nombre_tecla(arcade_input.ncoin[0]);
  mconfig.BitBtn24.Caption:=nombre_tecla(arcade_input.nstart[0]);
  arcade_input.use_key[0]:=true;
end;

procedure select_keyboard_p2;
begin
  mconfig.bitbtn5.Enabled:=true;
  mconfig.bitbtn6.Enabled:=true;
  mconfig.bitbtn7.Enabled:=true;
  mconfig.bitbtn8.Enabled:=true;
  mconfig.combobox2.Enabled:=false;
  mconfig.button8.Enabled:=false;
  mconfig.bitbtn12.Caption:=nombre_tecla(arcade_input.nbut0[1]);
  mconfig.bitbtn13.Caption:=nombre_tecla(arcade_input.nbut1[1]);
  mconfig.bitbtn14.Caption:=nombre_tecla(arcade_input.nbut2[1]);
  mconfig.bitbtn18.Caption:=nombre_tecla(arcade_input.nbut3[1]);
  mconfig.bitbtn19.Caption:=nombre_tecla(arcade_input.nbut4[1]);
  mconfig.bitbtn20.Caption:=nombre_tecla(arcade_input.nbut5[1]);
  //Player 2
  mconfig.bitbtn6.Caption:=nombre_tecla(arcade_input.nleft[1]);
  mconfig.bitbtn7.Caption:=nombre_tecla(arcade_input.nright[1]);
  mconfig.bitbtn8.Caption:=nombre_tecla(arcade_input.ndown[1]);
  mconfig.bitbtn5.Caption:=nombre_tecla(arcade_input.nup[1]);
  //Misc keys
  mconfig.BitBtn25.Caption:=nombre_tecla(arcade_input.ncoin[1]);
  mconfig.BitBtn26.Caption:=nombre_tecla(arcade_input.nstart[1]);
  arcade_input.use_key[1]:=true;
end;

procedure select_joystick_p1;
begin
  if joystick.num=0 then exit;
  arcade_input.use_key[0]:=false;
  mconfig.bitbtn1.Enabled:=false;
  mconfig.bitbtn2.Enabled:=false;
  mconfig.bitbtn3.Enabled:=false;
  mconfig.bitbtn4.Enabled:=false;
  mconfig.combobox1.enabled:=true;
  mconfig.button7.Enabled:=true;
  mconfig.bitbtn1.Caption:='LEFT';
  mconfig.bitbtn2.Caption:='RIGHT';
  mconfig.bitbtn3.Caption:='DOWN';
  mconfig.bitbtn4.Caption:='UP';
  mconfig.bitbtn9.Caption:=nombre_boton(arcade_input.jbut0[0]);
  mconfig.bitbtn10.Caption:=nombre_boton(arcade_input.jbut1[0]);
  mconfig.bitbtn11.Caption:=nombre_boton(arcade_input.jbut2[0]);
  mconfig.bitbtn17.Caption:=nombre_boton(arcade_input.jbut3[0]);
  mconfig.bitbtn15.Caption:=nombre_boton(arcade_input.jbut4[0]);
  mconfig.bitbtn16.Caption:=nombre_boton(arcade_input.jbut5[0]);
  //Misc Keys
  mconfig.BitBtn23.Caption:=nombre_boton(arcade_input.jcoin[0]);
  mconfig.BitBtn24.Caption:=nombre_boton(arcade_input.jstart[0]);
end;

procedure select_joystick_p2;
begin
  if joystick.num=0 then exit;
  arcade_input.use_key[1]:=false;
  mconfig.bitbtn5.Enabled:=false;
  mconfig.bitbtn6.Enabled:=false;
  mconfig.bitbtn7.Enabled:=false;
  mconfig.bitbtn8.Enabled:=false;
  mconfig.combobox2.Enabled:=true;
  mconfig.button8.Enabled:=true;
  mconfig.bitbtn6.Caption:='LEFT';
  mconfig.bitbtn7.Caption:='RIGHT';
  mconfig.bitbtn8.Caption:='DOWN';
  mconfig.bitbtn5.Caption:='UP';
  mconfig.bitbtn12.Caption:=nombre_boton(arcade_input.jbut0[1]);
  mconfig.bitbtn13.Caption:=nombre_boton(arcade_input.jbut1[1]);
  mconfig.bitbtn14.Caption:=nombre_boton(arcade_input.jbut2[1]);
  mconfig.bitbtn18.Caption:=nombre_boton(arcade_input.jbut3[1]);
  mconfig.bitbtn19.Caption:=nombre_boton(arcade_input.jbut4[1]);
  mconfig.bitbtn20.Caption:=nombre_boton(arcade_input.jbut5[1]);
  //Misc keys
  mconfig.BitBtn25.Caption:=nombre_boton(arcade_input.jcoin[1]);
  mconfig.BitBtn26.Caption:=nombre_boton(arcade_input.jstart[1]);
end;

procedure configeneral_autofire;
begin
timers.autofire_on:=mconfig.checkbox16.Checked;
mconfig.groupbox8.Enabled:=mconfig.checkbox16.Checked;
mconfig.groupbox9.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox4.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox5.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox6.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox7.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox8.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox9.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox10.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox11.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox12.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox13.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox14.Enabled:=mconfig.checkbox16.Checked;
mconfig.checkbox15.Enabled:=mconfig.checkbox16.Checked;
timers.enabled(timers.autofire_timer,mconfig.checkbox16.Checked);
end;

end.
