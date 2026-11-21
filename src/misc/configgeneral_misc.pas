unit configgeneral_misc;

interface
uses sysutils,forms;

procedure configgeneral_formshow;
procedure configgeneral_formclose;
procedure configeneral_autofire;
procedure actualiza_teclas;
procedure enable_joystick_def;

implementation
uses controls_engine,lib_sdl2,config_general,redefine,principal,main_engine,
     lenguaje,sound_engine,timer_engine;

procedure enable_joystick_def;
begin
mconfig.button7.Enabled:=false;
mconfig.button8.Enabled:=false;
mconfig.button9.Enabled:=false;
mconfig.button10.Enabled:=false;
case joystick.num of
  1:mconfig.button7.Enabled:=true;
  2:begin
      mconfig.button7.Enabled:=true;
      mconfig.button8.Enabled:=true;
    end;
  3:begin
      mconfig.button7.Enabled:=true;
      mconfig.button8.Enabled:=true;
      mconfig.button9.Enabled:=true;
    end;
  4..100:begin
      mconfig.button7.Enabled:=true;
      mconfig.button8.Enabled:=true;
      mconfig.button9.Enabled:=true;
      mconfig.button10.Enabled:=true;
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
  //auto type
  if main_vars.auto_type then mconfig.radiobutton28.Checked:=true
    else mconfig.radiobutton29.Checked:=true;
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
  mconfig.combobox1.Clear;
  mconfig.combobox2.Clear;
  mconfig.combobox3.Clear;
  mconfig.combobox4.Clear;
  for f:=1 to 4 do begin
    mconfig.combobox1.Items.Add('Keyboard '+inttostr(f));
    mconfig.combobox2.Items.Add('Keyboard '+inttostr(f));
    mconfig.combobox3.Items.Add('Keyboard '+inttostr(f));
    mconfig.combobox4.Items.Add('Keyboard '+inttostr(f));
  end;
  for f:=0 to (joystick.num-1) do begin
      mconfig.combobox1.Items.Add('Joystick '+inttostr(f+1)+' - '+joystick.nombre[f]);
      mconfig.combobox2.Items.Add('Joystick '+inttostr(f+1)+' - '+joystick.nombre[f]);
      mconfig.combobox3.Items.Add('Joystick '+inttostr(f+1)+' - '+joystick.nombre[f]);
      mconfig.combobox4.Items.Add('Joystick '+inttostr(f+1)+' - '+joystick.nombre[f]);
  end;
  enable_joystick_def;
  mconfig.combobox1.ItemIndex:=arcade_input.ndef[0];
  mconfig.combobox2.ItemIndex:=arcade_input.ndef[1];
  mconfig.combobox3.ItemIndex:=arcade_input.ndef[2];
  //mconfig.combobox4.ItemIndex:=arcade_input.ndef[3];
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

procedure actualiza_teclas;
var
  f:byte;
procedure set_keys(player,index_key:byte);
begin
  arcade_input.ncoin[player]:=defkeys[index_key].coin;
  arcade_input.nstart[player]:=defkeys[index_key].start;
  arcade_input.nup[player]:=defkeys[index_key].up;
  arcade_input.ndown[player]:=defkeys[index_key].down;
  arcade_input.nleft[player]:=defkeys[index_key].left;
  arcade_input.nright[player]:=defkeys[index_key].right;
  arcade_input.nbut0[player]:=defkeys[index_key].but0;
  arcade_input.nbut1[player]:=defkeys[index_key].but1;
  arcade_input.nbut2[player]:=defkeys[index_key].but2;
  arcade_input.nbut3[player]:=defkeys[index_key].but3;
  arcade_input.nbut4[player]:=defkeys[index_key].but4;
  arcade_input.nbut5[player]:=defkeys[index_key].but5;
end;
begin
for f:=0 to NUM_PLAYERS do begin
  arcade_input.use_key[f]:=arcade_input.ndef[f]<4;
  set_keys(f,arcade_input.ndef[f]);
  if not(arcade_input.use_key[f]) then
    if joystick_def[arcade_input.num_joystick[f]]=nil then arcade_input.ndef[f]:=f;
end;
end;

procedure configgeneral_formclose;
var
  f,tmp_var:byte;
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
  main_vars.auto_type:=mconfig.radiobutton28.Checked;
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
  //Arreglar entradas arcade
  arcade_input.ndef[0]:=mconfig.combobox1.ItemIndex;
  arcade_input.ndef[1]:=mconfig.combobox2.ItemIndex;
  arcade_input.ndef[2]:=mconfig.combobox3.ItemIndex;
  //arcade_input.ndef[3]:=mconfig.combobox4.ItemIndex;
  actualiza_teclas;
  for f:=0 to NUM_PLAYERS do begin
    if not(arcade_input.use_key[f]) then begin
      arcade_input.num_joystick[f]:=arcade_input.ndef[f]-4;
      SDL_JoystickUpdate;
      arcade_input.joy_x[f]:=SDL_JoystickGetAxis(joystick_def[arcade_input.num_joystick[f]],0);
      arcade_input.joy_y[f]:=SDL_JoystickGetAxis(joystick_def[arcade_input.num_joystick[f]],1);
    end;
  end;
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
