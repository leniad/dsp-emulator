unit config_general;

{$mode delphi}

interface
uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ComCtrls, ExtCtrls, StdCtrls, Buttons, EditBtn, lib_sdl2, controls_engine,
  main_engine, lenguaje, sound_engine,rom_export,timer_engine;

type

  { TMConfig }

  TMConfig = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn15: TBitBtn;
    BitBtn16: TBitBtn;
    BitBtn17: TBitBtn;
    BitBtn18: TBitBtn;
    BitBtn19: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn20: TBitBtn;
    BitBtn21: TBitBtn;
    BitBtn22: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    Button1: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button2: TButton;
    Button7: TButton;
    Button8: TButton;
    CheckBox1: TCheckBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    CheckBox17: TCheckBox;
    CheckBox9: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    D1: TDirectoryEdit;
    D2: TDirectoryEdit;
    D6: TDirectoryEdit;
    D5: TDirectoryEdit;
    D3: TDirectoryEdit;
    D4: TEdit;
    GroupBox1: TGroupBox;
    GroupBox10: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label2: TLabel;
    Label20: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    other: TPageControl;
    RadioButton1: TRadioButton;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    RadioButton12: TRadioButton;
    RadioButton14: TRadioButton;
    RadioButton15: TRadioButton;
    RadioButton16: TRadioButton;
    RadioButton17: TRadioButton;
    RadioButton18: TRadioButton;
    RadioButton19: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton20: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    GroupBox5: TRadioGroup;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    TabSheet5: TTabSheet;
    TabSheet6: TTabSheet;
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn13Click(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure BitBtn15Click(Sender: TObject);
    procedure BitBtn16Click(Sender: TObject);
    procedure BitBtn17Click(Sender: TObject);
    procedure BitBtn18Click(Sender: TObject);
    procedure BitBtn19Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn20Click(Sender: TObject);
    procedure BitBtn21Click(Sender: TObject);
    procedure BitBtn22Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure CheckBox16Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
    procedure RadioButton11Click(Sender: TObject);
    procedure RadioButton12Change(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton21Change(Sender: TObject);
    procedure RadioButton22Change(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Change(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton6Click(Sender: TObject);
    procedure RadioButton7Click(Sender: TObject);
    procedure RadioButton8Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  MConfig:TMConfig;
  tecla_leida:word;
  idioma_antes:byte;

implementation
uses principal, redefine;

{ TMConfig }
function nombre_tecla(num: word):string;
begin
  case num of
    KEYBOARD_ESCAPE: nombre_tecla := 'ESC';
    KEYBOARD_CAPSLOCK: nombre_tecla := 'CAPSLOCK';
    KEYBOARD_TAB: nombre_tecla := 'TAB';
    //KEYBOARD_SCANCODE_SLASH: nombre_tecla := 'SLASH';
    //KEYBOARD_SCANCODE_QUOTE: nombre_tecla := 'QUOTE';
    //KEYBOARD_SCANCODE_SEMICOLON: nombre_tecla := 'SEMICOLON';
    //KEYBOARD_SCANCODE_BACKSLASH: nombre_tecla := 'DELETE';
    //KEYBOARD_SCANCODE_LESS: nombre_tecla := 'LESS';
    KEYBOARD_HOME: nombre_tecla := 'HOME';
    KEYBOARD_RIGHT: nombre_tecla := 'RIGHT';
    KEYBOARD_LEFT: nombre_tecla := 'LEFT';
    KEYBOARD_DOWN: nombre_tecla := 'DOWN';
    KEYBOARD_UP: nombre_tecla := 'UP';
    KEYBOARD_RALT: nombre_tecla := 'R ALT';
    KEYBOARD_LALT:nombre_tecla:='L ALT';
    KEYBOARD_RSHIFT: nombre_tecla := 'R SHIFT';
    KEYBOARD_LSHIFT: nombre_tecla := 'L SHIFT';
    KEYBOARD_RCTRL: nombre_tecla := 'R CTRL';
    KEYBOARD_LCTRL: nombre_tecla := 'L CTRL';
    KEYBOARD_RETURN: nombre_tecla := 'ENTER';
    KEYBOARD_SPACE: nombre_tecla := 'SPACE';
    KEYBOARD_A: nombre_tecla := 'A';
    KEYBOARD_B: nombre_tecla := 'B';
    KEYBOARD_C: nombre_tecla := 'C';
    KEYBOARD_D: nombre_tecla := 'D';
    KEYBOARD_E: nombre_tecla := 'E';
    KEYBOARD_F: nombre_tecla := 'F';
    KEYBOARD_G: nombre_tecla := 'G';
    KEYBOARD_H: nombre_tecla := 'H';
    KEYBOARD_I: nombre_tecla := 'I';
    KEYBOARD_J: nombre_tecla := 'J';
    KEYBOARD_K: nombre_tecla := 'K';
    KEYBOARD_L: nombre_tecla := 'L';
    KEYBOARD_M: nombre_tecla := 'M';
    KEYBOARD_N: nombre_tecla := 'N';
    KEYBOARD_O: nombre_tecla := 'O';
    KEYBOARD_P: nombre_tecla := 'P';
    KEYBOARD_Q: nombre_tecla := 'Q';
    KEYBOARD_R: nombre_tecla := 'R';
    KEYBOARD_S: nombre_tecla := 'S';
    KEYBOARD_T: nombre_tecla := 'T';
    KEYBOARD_U: nombre_tecla := 'U';
    KEYBOARD_V: nombre_tecla := 'V';
    KEYBOARD_W: nombre_tecla := 'W';
    KEYBOARD_X: nombre_tecla := 'X';
    KEYBOARD_Y: nombre_tecla := 'Y';
    KEYBOARD_Z: nombre_tecla := 'Z';
    KEYBOARD_1: nombre_tecla := '1';
    KEYBOARD_2: nombre_tecla := '2';
    KEYBOARD_3: nombre_tecla := '3';
    KEYBOARD_4: nombre_tecla := '4';
    KEYBOARD_5: nombre_tecla := '5';
    KEYBOARD_6: nombre_tecla := '6';
    KEYBOARD_7: nombre_tecla := '7';
    KEYBOARD_8: nombre_tecla := '8';
    KEYBOARD_9: nombre_tecla := '9';
    KEYBOARD_0: nombre_tecla := '0';
    KEYBOARD_NONE:nombre_tecla:='N/D';
    else nombre_tecla := 'N/D';
  end;
end;

function get_button(player:byte):byte;
var
  f,res:byte;
  salir,tempb:boolean;
begin
salir:=false;
while not(salir) do begin
  SDL_JoystickUpdate;
  application.ProcessMessages;
  if salir then break;
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

procedure TMConfig.BitBtn10Click(Sender: TObject);
begin
  if arcade_input.use_key[0] then begin
      redefine1.showmodal;
      if tecla_leida<>$FFFF then begin
        bitbtn10.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nbut1[0]:=tecla_leida;
      end;
  end else begin
      bitbtn10.Caption:='Press but';
      arcade_input.jbut1[0]:=get_button(arcade_input.num_joystick[0]);
      bitbtn10.Caption:=inttostr(arcade_input.jbut1[0]);
  end;
end;

procedure TMConfig.BitBtn11Click(Sender: TObject);
begin
  if arcade_input.use_key[0] then begin
    redefine1.showmodal;
    if tecla_leida<>$FFFF then begin
      bitbtn11.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nbut2[0]:=tecla_leida;
    end;
  end else begin
    bitbtn11.Caption:='Press but';
    arcade_input.jbut2[0]:=get_button(arcade_input.num_joystick[0]);
    bitbtn11.Caption:=inttostr(arcade_input.jbut2[0]);
  end;
end;

procedure TMConfig.BitBtn12Click(Sender: TObject);
begin
  if arcade_input.use_key[1] then begin
    redefine1.showmodal;
    if tecla_leida<>$FFFF then begin
      bitbtn12.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nbut0[1]:=tecla_leida;
    end;
  end else begin
    bitbtn12.Caption:='Press but';
    arcade_input.jbut0[1]:=get_button(arcade_input.num_joystick[1]);
    bitbtn12.Caption:=inttostr(arcade_input.jbut0[1]);
  end;
end;

procedure TMConfig.BitBtn13Click(Sender: TObject);
begin
  if arcade_input.use_key[1] then begin
    redefine1.showmodal;
    if tecla_leida<>$FFFF then begin
      bitbtn13.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nbut1[1]:=tecla_leida;
    end;
  end else begin
    bitbtn13.Caption:='Press but';
    arcade_input.jbut1[1]:=get_button(arcade_input.num_joystick[1]);
    bitbtn13.Caption:=inttostr(arcade_input.jbut1[1]);
  end;
end;

procedure TMConfig.BitBtn14Click(Sender: TObject);
begin
  if arcade_input.use_key[1] then begin
    redefine1.showmodal;
    if tecla_leida<>$FFFF then begin
      bitbtn14.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nbut2[1]:=tecla_leida;
    end;
  end else begin
    bitbtn14.Caption:='Press but';
    arcade_input.jbut2[1]:=get_button(arcade_input.num_joystick[1]);
    bitbtn14.Caption:=inttostr(arcade_input.jbut2[1]);
  end;
end;

procedure TMConfig.BitBtn15Click(Sender: TObject);
begin
  if arcade_input.use_key[0] then begin
      redefine1.showmodal;
      if tecla_leida<>$FFFF then begin
        bitbtn15.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nbut4[0]:=tecla_leida;
      end;
    end else begin
      bitbtn15.Caption:='Press but';
      arcade_input.jbut4[0]:=get_button(arcade_input.num_joystick[0]);
      bitbtn15.Caption:=inttostr(arcade_input.jbut4[0]);
    end;
end;

procedure TMConfig.BitBtn16Click(Sender: TObject);
begin
  if arcade_input.use_key[0] then begin
      redefine1.showmodal;
      if tecla_leida<>$FFFF then begin
        bitbtn16.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nbut5[0]:=tecla_leida;
      end;
    end else begin
      bitbtn16.Caption:='Press but';
      arcade_input.jbut5[0]:=get_button(arcade_input.num_joystick[0]);
      bitbtn16.Caption:=inttostr(arcade_input.jbut5[0]);
    end;
end;

procedure TMConfig.BitBtn17Click(Sender: TObject);
begin
  if arcade_input.use_key[0] then begin
      redefine1.showmodal;
      if tecla_leida<>$FFFF then begin
        bitbtn17.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nbut3[0]:=tecla_leida;
      end;
    end else begin
      bitbtn17.Caption:='Press but';
      arcade_input.jbut3[0]:=get_button(arcade_input.num_joystick[0]);
      bitbtn17.Caption:=inttostr(arcade_input.jbut3[0]);
    end;
end;

procedure TMConfig.BitBtn18Click(Sender: TObject);
begin
  if arcade_input.use_key[1] then begin
      redefine1.showmodal;
      if tecla_leida<>$FFFF then begin
        bitbtn18.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nbut3[1]:=tecla_leida;
      end;
    end else begin
      bitbtn18.Caption:='Press but';
      arcade_input.jbut3[1]:=get_button(arcade_input.num_joystick[1]);
      bitbtn18.Caption:=inttostr(arcade_input.jbut3[1]);
    end;
end;

procedure TMConfig.BitBtn19Click(Sender: TObject);
begin
  if arcade_input.use_key[1] then begin
      redefine1.showmodal;
      if tecla_leida<>$FFFF then begin
        bitbtn19.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nbut4[1]:=tecla_leida;
      end;
    end else begin
      bitbtn19.Caption:='Press but';
      arcade_input.jbut4[1]:=get_button(arcade_input.num_joystick[1]);
      bitbtn19.Caption:=inttostr(arcade_input.jbut4[1]);
    end;
end;

procedure TMConfig.BitBtn1Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    bitbtn1.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nleft[0]:= tecla_leida;
  end;
end;

procedure TMConfig.BitBtn20Click(Sender: TObject);
begin
  if arcade_input.use_key[1] then begin
      redefine1.showmodal;
      if tecla_leida<>$FFFF then begin
        bitbtn20.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nbut5[1]:=tecla_leida;
      end;
    end else begin
      bitbtn20.Caption:='Press but';
      arcade_input.jbut5[1]:=get_button(arcade_input.num_joystick[1]);
      bitbtn20.Caption:=inttostr(arcade_input.jbut5[1]);
    end;
end;

procedure TMConfig.BitBtn21Click(Sender: TObject);
begin
  export_roms;
end;

procedure TMConfig.BitBtn22Click(Sender: TObject);
begin
  export_samples;
end;

procedure TMConfig.BitBtn2Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    bitbtn2.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nright[0]:=tecla_leida;
  end;
end;

procedure TMConfig.BitBtn3Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    bitbtn3.Caption:=nombre_tecla(tecla_leida);
    arcade_input.ndown[0]:=tecla_leida;
  end;
end;

procedure TMConfig.BitBtn4Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    bitbtn4.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nup[0]:=tecla_leida;
  end;
end;

procedure TMConfig.BitBtn5Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    bitbtn5.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nup[1]:=tecla_leida;
  end;
end;

procedure TMConfig.BitBtn6Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    bitbtn6.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nleft[1]:=tecla_leida;
  end;
end;

procedure TMConfig.BitBtn7Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    bitbtn7.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nright[1]:=tecla_leida;
  end;
end;

procedure TMConfig.BitBtn8Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    bitbtn8.Caption:=nombre_tecla(tecla_leida);
    arcade_input.ndown[1]:=tecla_leida;
  end;
end;

procedure TMConfig.BitBtn9Click(Sender: TObject);
begin
  if arcade_input.use_key[0] then begin
    redefine1.showmodal;
    if tecla_leida<>$FFFF then begin
      bitbtn9.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nbut0[0]:=tecla_leida;
    end;
  end else begin
    bitbtn9.Caption:='Press but';
    arcade_input.jbut0[0]:=get_button(arcade_input.num_joystick[0]);
    bitbtn9.Caption:=inttostr(arcade_input.jbut0[0]);
  end;
end;

procedure TMConfig.Button9Click(Sender: TObject);
begin
  if arcade_input.use_key[0] then begin
      redefine1.showmodal;
      if tecla_leida<>$FFFF then begin
        Button9.Caption:=nombre_tecla(tecla_leida);
        arcade_input.ncoin[0]:=tecla_leida;
      end;
    end else begin
      Button9.Caption:='Press but';
      arcade_input.jcoin[0]:=get_button(arcade_input.num_joystick[0]);
      Button9.Caption:=inttostr(arcade_input.jcoin[0]);
    end;
end;

procedure TMConfig.Button10Click(Sender: TObject);
begin
  if arcade_input.use_key[0] then begin
      redefine1.showmodal;
      if tecla_leida<>$FFFF then begin
        Button10.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nstart[0]:=tecla_leida;
      end;
    end else begin
      Button10.Caption:='Press but';
      arcade_input.jstart[0]:=get_button(arcade_input.num_joystick[0]);
      Button10.Caption:=inttostr(arcade_input.jstart[0]);
    end;
end;

procedure TMConfig.Button11Click(Sender: TObject);
begin
  if arcade_input.use_key[1] then begin
     redefine1.showmodal;
     if tecla_leida<>$FFFF then begin
        Button11.Caption:=nombre_tecla(tecla_leida);
        arcade_input.ncoin[1]:=tecla_leida;
     end;
  end else begin
      Button11.Caption:='Press but';
      arcade_input.jcoin[1]:=get_button(arcade_input.num_joystick[1]);
      Button11.Caption:=inttostr(arcade_input.jcoin[1]);
  end;
end;

procedure TMConfig.Button12Click(Sender: TObject);
begin
  if arcade_input.use_key[1] then begin
     redefine1.showmodal;
     if tecla_leida<>$FFFF then begin
        Button12.Caption:=nombre_tecla(tecla_leida);
        arcade_input.nstart[1]:=tecla_leida;
     end;
  end else begin
      Button12.Caption:='Press but';
      arcade_input.jstart[1]:=get_button(arcade_input.num_joystick[1]);
      Button12.Caption:=inttostr(arcade_input.jstart[1]);
  end;
end;

procedure TMConfig.Button1Click(Sender: TObject);
var
  tmp_var:byte;
begin
  Directory.Preview:=D1.Text;
  if d1.Text[length(d1.Text)]<>main_vars.cadena_dir then Directory.Preview:=Directory.Preview+main_vars.cadena_dir;
  Directory.Arcade_samples:=D2.Text;
  if d2.Text[length(d2.Text)]<>main_vars.cadena_dir then Directory.Arcade_samples:=Directory.Arcade_samples+main_vars.cadena_dir;
  Directory.Arcade_nvram:=D3.Text;
  if d3.Text[length(d3.Text)]<>main_vars.cadena_dir then Directory.Arcade_nvram:=Directory.Arcade_nvram+main_vars.cadena_dir;
  split_dirs(D4.Text);
  Directory.Arcade_hi:=D5.Text;
  if d5.Text[length(d5.Text)]<>main_vars.cadena_dir then Directory.Arcade_hi:=Directory.Arcade_hi+main_vars.cadena_dir;
  Directory.qsnapshot:=D6.Text;
  if d6.Text[length(d6.Text)]<>main_vars.cadena_dir then Directory.qsnapshot:=Directory.qsnapshot+main_vars.cadena_dir;
  if radiobutton5.Checked then main_vars.idioma:=0
    else if radiobutton6.Checked then main_vars.idioma:=1
      else if radiobutton7.Checked then main_vars.idioma:=2
        else if radiobutton8.Checked then main_vars.idioma:=3
          else if radiobutton9.Checked then main_vars.idioma:=4
            else if radiobutton10.Checked then main_vars.idioma:=5
              else if radiobutton11.Checked then main_vars.idioma:=6
                else if radiobutton12.Checked then main_vars.idioma:=200;
  sound_status.sonido_activo:=radiobutton14.Checked;
  principal1.SinSonido1.Checked:=not(radiobutton14.Checked);
  principal1.ConSonido1.Checked:=radiobutton14.Checked;
  if groupbox5.Enabled then begin
    if radiobutton16.Checked then tmp_var:=1
      else if radiobutton17.Checked then tmp_var:=2
        else if radiobutton18.Checked then tmp_var:=3
          else if radiobutton19.Checked then tmp_var:=4
            else if radiobutton20.Checked then tmp_var:=5;
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
  main_vars.auto_exec:=checkbox2.Checked;
  main_vars.show_crc_error:=checkbox1.Checked;
  main_vars.center_screen:=checkbox3.Checked;
//Arreglar entradas arcade
  arcade_input.use_key[0]:=radiobutton1.Checked;
  arcade_input.use_key[1]:=radiobutton3.Checked;
  arcade_input.num_joystick[0]:=combobox1.ItemIndex;
  arcade_input.num_joystick[1]:=combobox2.ItemIndex;
  timers.autofire_on:=checkbox16.Checked;
  if timers.autofire_on then begin
    timers.autofire_enabled[0]:=checkbox4.Checked;
    timers.autofire_enabled[1]:=checkbox5.Checked;
    timers.autofire_enabled[2]:=checkbox6.Checked;
    timers.autofire_enabled[3]:=checkbox7.Checked;
    timers.autofire_enabled[4]:=checkbox8.Checked;
    timers.autofire_enabled[5]:=checkbox9.Checked;
    timers.autofire_enabled[6]:=checkbox10.Checked;
    timers.autofire_enabled[7]:=checkbox11.Checked;
    timers.autofire_enabled[8]:=checkbox12.Checked;
    timers.autofire_enabled[9]:=checkbox13.Checked;
    timers.autofire_enabled[10]:=checkbox14.Checked;
    timers.autofire_enabled[11]:=checkbox15.Checked;
  end else for tmp_var:=0 to 11 do timers.autofire_enabled[tmp_var]:=false;
  close;
end;

procedure TMConfig.Button2Click(Sender: TObject);
begin
if main_vars.idioma<>idioma_antes then begin
   main_vars.idioma:=idioma_antes;
   cambiar_idioma(idioma_antes);
end;
close;
end;

procedure TMConfig.Button3Click(Sender: TObject);
begin

end;

procedure TMConfig.Button7Click(Sender: TObject);
begin
SDL_JoystickUpdate;
arcade_input.joy_x[0]:=SDL_JoystickGetAxis(joystick_def[0],0);
arcade_input.joy_y[0]:=SDL_JoystickGetAxis(joystick_def[0],1);
//SDL_JoystickGetAxisInitialState(joystick_def[0],0,@arcade_input.joy_x[0]);
//SDL_JoystickGetAxisInitialState(joystick_def[0],1,@arcade_input.joy_y[0]);
end;

procedure TMConfig.Button8Click(Sender: TObject);
begin
SDL_JoystickUpdate;
arcade_input.joy_x[1]:=SDL_JoystickGetAxis(joystick_def[1],0);
arcade_input.joy_y[1]:=SDL_JoystickGetAxis(joystick_def[1],1);
//SDL_JoystickGetAxisInitialState(joystick_def[1],0,@arcade_input.joy_x[1]);
//SDL_JoystickGetAxisInitialState(joystick_def[1],1,@arcade_input.joy_y[1]);
end;

procedure TMConfig.CheckBox16Click(Sender: TObject);
begin
  timers.autofire_on:=checkbox16.Checked;
  groupbox8.Enabled:=checkbox16.Checked;
  groupbox9.Enabled:=checkbox16.Checked;
  checkbox4.Enabled:=checkbox16.Checked;
  CheckBox4.Enabled:=checkbox16.Checked;
  CheckBox5.Enabled:=checkbox16.Checked;
  CheckBox6.Enabled:=checkbox16.Checked;
  CheckBox7.Enabled:=checkbox16.Checked;
  CheckBox8.Enabled:=checkbox16.Checked;
  checkbox10.Enabled:=checkbox16.Checked;
  checkbox11.Enabled:=checkbox16.Checked;
  checkbox12.Enabled:=checkbox16.Checked;
  checkbox13.Enabled:=checkbox16.Checked;
  checkbox14.Enabled:=checkbox16.Checked;
  checkbox15.Enabled:=checkbox16.Checked;
  timers.enabled(timers.autofire_timer,checkbox16.Checked);
end;

procedure TMConfig.ComboBox1Change(Sender: TObject);
begin
  arcade_input.num_joystick[0]:=combobox1.ItemIndex;
end;

procedure TMConfig.ComboBox2Change(Sender: TObject);
begin
  arcade_input.num_joystick[1]:=combobox2.ItemIndex;
end;

procedure TMConfig.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case key of
    13:Button1Click(nil);
    27:button2click(nil);
  end;
end;

procedure cambiar_texto_idioma(idioma:byte);
begin
cambiar_idioma(idioma);
MConfig.GroupBox3.Caption:=leng.archivo[1];
MConfig.button2.Caption:=leng.mensajes[8];
MConfig.checkbox2.Caption:=leng.varios[2];
MConfig.checkbox1.Caption:=leng.varios[3];
MConfig.checkbox3.Caption:=leng.varios[4];
MConfig.checkbox17.Caption:=leng.varios[5];
MConfig.radiobutton15.Caption:=leng.opciones[3];
MConfig.radiobutton14.Caption:=leng.opciones[5];
MConfig.groupbox4.Caption:=leng.opciones[1];
Mconfig.TabSheet2.Caption:=leng.opciones[6];
end;

procedure TMConfig.FormShow(Sender: TObject);
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
  cambiar_texto_idioma(main_vars.idioma);
  //idioma
  case main_vars.idioma of
    0:radiobutton5.Checked:=true;
    1:radiobutton6.Checked:=true;
    2:radiobutton7.Checked:=true;
    3:radiobutton8.Checked:=true;
    4:radiobutton9.Checked:=true;
    5:radiobutton10.Checked:=true;
    6:radiobutton11.Checked:=true;
    200:radiobutton12.Checked:=true;
  end;
  //audio
  if sound_status.sonido_activo then radiobutton14.Checked:=true
    else radiobutton15.Checked:=true;
  //video
  case main_screen.video_mode of
    1:radiobutton16.Checked:=true;
    2:radiobutton17.Checked:=true;
    3:radiobutton18.Checked:=true;
    4:radiobutton19.Checked:=true;
    5:radiobutton20.Checked:=true;
  end;
  //Autoload
  checkbox2.Checked:=main_vars.auto_exec;
  //Mostar errores CRC
  checkbox1.Checked:=main_vars.show_crc_error;
  //Centrar Pantalla
  checkbox3.Checked:=main_vars.center_screen;
  //Diretorios
  D1.Text:=Directory.Preview;
  D2.Text:=Directory.Arcade_samples;
  D3.Text:=Directory.Arcade_nvram;
  D4.Text:=get_all_dirs;
  D5.Text:=Directory.Arcade_hi;
  D6.Text:=Directory.qsnapshot;
  //Componer todas las entradas
  if joystick.num=0 then begin
    radiobutton1.Checked:=true;
    radiobutton2.Checked:=false;
    radiobutton2.enabled:=false;
    button7.Enabled:=false;
    radiobutton3.Checked:=true;
    radiobutton4.Checked:=false;
    radiobutton4.enabled:=false;
    button8.Enabled:=false;
    combobox1.Enabled:=false;
    combobox1.Clear;
    combobox2.Enabled:=false;
    combobox2.Clear;
  end else begin
    combobox1.clear;
    combobox2.clear;
    for f:=0 to (joystick.num-1) do begin
      combobox1.Items.Add(joystick.nombre[f]);
      combobox2.Items.Add(joystick.nombre[f]);
    end;
    radiobutton2.enabled:=true;
    radiobutton4.enabled:=true;
    combobox1.ItemIndex:=arcade_input.num_joystick[0];
    combobox2.ItemIndex:=arcade_input.num_joystick[1];
  end;
  if arcade_input.use_key[0] then begin
     radiobutton1.Checked:=true;
     radiobutton2.Checked:=false;
     combobox1.Enabled:=false;
     button7.Enabled:=false;
     bitbtn1.Enabled:=true;
     bitbtn2.Enabled:=true;
     bitbtn3.Enabled:=true;
     bitbtn4.Enabled:=true;
     bitbtn9.Caption:=nombre_tecla(arcade_input.nbut0[0]);
     bitbtn10.Caption:=nombre_tecla(arcade_input.nbut1[0]);
     bitbtn11.Caption:=nombre_tecla(arcade_input.nbut2[0]);
     bitbtn17.Caption:=nombre_tecla(arcade_input.nbut3[0]);
     bitbtn15.Caption:=nombre_tecla(arcade_input.nbut4[0]);
     bitbtn16.Caption:=nombre_tecla(arcade_input.nbut5[0]);
     //Player 1
     bitbtn1.Caption:=nombre_tecla(arcade_input.nleft[0]);
     bitbtn2.Caption:=nombre_tecla(arcade_input.nright[0]);
     bitbtn3.Caption:=nombre_tecla(arcade_input.ndown[0]);
     bitbtn4.Caption:=nombre_tecla(arcade_input.nup[0]);
     //Misc Keys
     button9.Caption:=nombre_tecla(arcade_input.ncoin[0]);
     Button10.Caption:=nombre_tecla(arcade_input.nstart[0]);
  end else begin
     radiobutton1.Checked:=false;
     radiobutton2.Checked:=true;
     button7.Enabled:=true;
     bitbtn1.Enabled:=false;
     bitbtn2.Enabled:=false;
     bitbtn3.Enabled:=false;
     bitbtn4.Enabled:=false;
     bitbtn7.enabled:=true;
     bitbtn9.Caption:=inttostr(arcade_input.jbut0[0]);
     bitbtn10.Caption:=inttostr(arcade_input.jbut1[0]);
     bitbtn11.Caption:=inttostr(arcade_input.jbut2[0]);
     bitbtn17.Caption:=inttostr(arcade_input.jbut3[0]);
     bitbtn15.Caption:=inttostr(arcade_input.jbut4[0]);
     bitbtn16.Caption:=inttostr(arcade_input.jbut5[0]);
     //Misc Keys
     button9.Caption:=inttostr(arcade_input.jcoin[0]);
     Button10.Caption:=inttostr(arcade_input.jstart[0]);
  end;
  if arcade_input.use_key[1] then begin
     radiobutton3.Checked:=true;
     radiobutton4.Checked:=false;
     combobox2.Enabled:=false;
     button8.Enabled:=false;
     bitbtn5.Enabled:=true;
     bitbtn6.Enabled:=true;
     bitbtn7.Enabled:=true;
     bitbtn8.Enabled:=true;
     bitbtn12.Caption:=nombre_tecla(arcade_input.nbut0[1]);
     bitbtn13.Caption:=nombre_tecla(arcade_input.nbut1[1]);
     bitbtn14.Caption:=nombre_tecla(arcade_input.nbut2[1]);
     bitbtn18.Caption:=nombre_tecla(arcade_input.nbut3[1]);
     bitbtn19.Caption:=nombre_tecla(arcade_input.nbut4[1]);
     bitbtn20.Caption:=nombre_tecla(arcade_input.nbut5[1]);
     //Player 2
     bitbtn6.Caption:=nombre_tecla(arcade_input.nleft[1]);
     bitbtn7.Caption:=nombre_tecla(arcade_input.nright[1]);
     bitbtn8.Caption:=nombre_tecla(arcade_input.ndown[1]);
     bitbtn5.Caption:=nombre_tecla(arcade_input.nup[1]);
     //Misc keys
     Button11.Caption:=nombre_tecla(arcade_input.ncoin[1]);
     Button12.Caption:=nombre_tecla(arcade_input.nstart[1]);
   end else begin
     radiobutton3.Checked:=false;
     radiobutton4.Checked:=true;
     combobox2.Enabled:=true;
     button8.Enabled:=true;
     bitbtn5.Enabled:=false;
     bitbtn6.Enabled:=false;
     bitbtn7.Enabled:=false;
     bitbtn8.Enabled:=false;
     bitbtn12.Caption:=inttostr(arcade_input.jbut0[1]);
     bitbtn13.Caption:=inttostr(arcade_input.jbut1[1]);
     bitbtn14.Caption:=inttostr(arcade_input.jbut2[1]);
     bitbtn18.Caption:=inttostr(arcade_input.jbut3[1]);
     bitbtn19.Caption:=inttostr(arcade_input.jbut4[1]);
     bitbtn20.Caption:=inttostr(arcade_input.jbut5[1]);
     //Misc keys
     Button11.Caption:=inttostr(arcade_input.jcoin[1]);
     Button12.Caption:=inttostr(arcade_input.jstart[1]);
  end;
  checkbox4.Checked:=timers.autofire_enabled[0];
  CheckBox5.Checked:=timers.autofire_enabled[1];
  CheckBox6.Checked:=timers.autofire_enabled[2];
  CheckBox7.Checked:=timers.autofire_enabled[3];
  CheckBox8.Checked:=timers.autofire_enabled[4];
  CheckBox9.Checked:=timers.autofire_enabled[5];
  checkbox10.Checked:=timers.autofire_enabled[6];
  checkbox11.Checked:=timers.autofire_enabled[7];
  checkbox12.Checked:=timers.autofire_enabled[8];
  checkbox13.Checked:=timers.autofire_enabled[9];
  checkbox14.Checked:=timers.autofire_enabled[10];
  checkbox15.Checked:=timers.autofire_enabled[11];
  checkbox16.Checked:=timers.autofire_on;
  CheckBox16Click(self);
end;

procedure TMConfig.GroupBox1Click(Sender: TObject);
begin

end;

procedure TMConfig.RadioButton10Click(Sender: TObject);
begin
  main_vars.idioma:=5;
  cambiar_texto_idioma(5);
end;

procedure TMConfig.RadioButton11Click(Sender: TObject);
begin
  main_vars.idioma:=6;
  cambiar_texto_idioma(6);
end;

procedure TMConfig.RadioButton12Change(Sender: TObject);
begin
  main_vars.idioma:=200;
  cambiar_texto_idioma(200);
end;

procedure TMConfig.RadioButton1Click(Sender: TObject);
begin
  bitbtn1.Enabled:=true;
  bitbtn2.Enabled:=true;
  bitbtn3.Enabled:=true;
  bitbtn4.Enabled:=true;
  combobox1.enabled:=false;
  button7.Enabled:=false;
  bitbtn9.Caption:=nombre_tecla(arcade_input.nbut0[0]);
  bitbtn10.Caption:=nombre_tecla(arcade_input.nbut1[0]);
  bitbtn11.Caption:=nombre_tecla(arcade_input.nbut2[0]);
  bitbtn17.Caption:=nombre_tecla(arcade_input.nbut3[0]);
  bitbtn15.Caption:=nombre_tecla(arcade_input.nbut4[0]);
  bitbtn16.Caption:=nombre_tecla(arcade_input.nbut5[0]);
  //Player 1
  bitbtn1.Caption:=nombre_tecla(arcade_input.nleft[0]);
  bitbtn2.Caption:=nombre_tecla(arcade_input.nright[0]);
  bitbtn3.Caption:=nombre_tecla(arcade_input.ndown[0]);
  bitbtn4.Caption:=nombre_tecla(arcade_input.nup[0]);
  //Misc Keys
  button9.Caption:=nombre_tecla(arcade_input.ncoin[0]);
  Button9.Caption:=nombre_tecla(arcade_input.nstart[0]);
  arcade_input.use_key[0]:=true;
end;

procedure TMConfig.RadioButton21Change(Sender: TObject);
begin
  bitbtn7.Enabled:=false;
end;

procedure TMConfig.RadioButton22Change(Sender: TObject);
begin
  bitbtn7.Enabled:=true;
end;

procedure TMConfig.RadioButton2Click(Sender: TObject);
begin
  if joystick.num=0 then exit;
  arcade_input.use_key[0]:=false;
  bitbtn1.Enabled:=false;
  bitbtn2.Enabled:=false;
  bitbtn3.Enabled:=false;
  bitbtn4.Enabled:=false;
  combobox1.enabled:=true;
  button7.Enabled:=true;
  bitbtn9.Caption:=inttostr(arcade_input.jbut0[0]);
  bitbtn10.Caption:=inttostr(arcade_input.jbut1[0]);
  bitbtn11.Caption:=inttostr(arcade_input.jbut2[0]);
  bitbtn17.Caption:=inttostr(arcade_input.jbut3[0]);
  bitbtn15.Caption:=inttostr(arcade_input.jbut4[0]);
  bitbtn16.Caption:=inttostr(arcade_input.jbut5[0]);
  //Misc Keys
  button9.Caption:=inttostr(arcade_input.jcoin[0]);
  Button9.Caption:=inttostr(arcade_input.jstart[0]);
end;

procedure TMConfig.RadioButton3Click(Sender: TObject);
begin
  bitbtn5.Enabled:=true;
  bitbtn6.Enabled:=true;
  bitbtn7.Enabled:=true;
  bitbtn8.Enabled:=true;
  combobox2.Enabled:=false;
  button8.Enabled:=false;
  bitbtn12.Caption:=nombre_tecla(arcade_input.nbut0[1]);
  bitbtn13.Caption:=nombre_tecla(arcade_input.nbut1[1]);
  bitbtn14.Caption:=nombre_tecla(arcade_input.nbut2[1]);
  bitbtn18.Caption:=nombre_tecla(arcade_input.nbut3[1]);
  bitbtn19.Caption:=nombre_tecla(arcade_input.nbut4[1]);
  bitbtn20.Caption:=nombre_tecla(arcade_input.nbut5[1]);
  //Player 2
  bitbtn6.Caption:=nombre_tecla(arcade_input.nleft[1]);
  bitbtn7.Caption:=nombre_tecla(arcade_input.nright[1]);
  bitbtn8.Caption:=nombre_tecla(arcade_input.ndown[1]);
  bitbtn5.Caption:=nombre_tecla(arcade_input.nup[1]);
  //Misc keys
  Button10.Caption:=nombre_tecla(arcade_input.ncoin[1]);
  Button11.Caption:=nombre_tecla(arcade_input.nstart[1]);
  arcade_input.use_key[1]:=true;
end;

procedure TMConfig.RadioButton4Click(Sender: TObject);
begin
  if joystick.num=0 then exit;
  arcade_input.use_key[1]:=false;
  bitbtn5.Enabled:=false;
  bitbtn6.Enabled:=false;
  bitbtn7.Enabled:=false;
  bitbtn8.Enabled:=false;
  combobox2.Enabled:=true;
  button8.Enabled:=true;
  bitbtn12.Caption:=inttostr(arcade_input.jbut0[1]);
  bitbtn13.Caption:=inttostr(arcade_input.jbut1[1]);
  bitbtn14.Caption:=inttostr(arcade_input.jbut2[1]);
  bitbtn18.Caption:=inttostr(arcade_input.jbut3[1]);
  bitbtn19.Caption:=inttostr(arcade_input.jbut4[1]);
  bitbtn20.Caption:=inttostr(arcade_input.jbut5[1]);
  //Misc keys
  Button10.Caption:=inttostr(arcade_input.jcoin[1]);
  Button11.Caption:=inttostr(arcade_input.jstart[1]);
end;

procedure TMConfig.RadioButton5Change(Sender: TObject);
begin

end;

procedure TMConfig.RadioButton5Click(Sender: TObject);
begin
  main_vars.idioma:=0;
  cambiar_texto_idioma(0);
end;

procedure TMConfig.RadioButton6Click(Sender: TObject);
begin
  main_vars.idioma:=1;
  cambiar_texto_idioma(1);
end;

procedure TMConfig.RadioButton7Click(Sender: TObject);
begin
  main_vars.idioma:=2;
  cambiar_texto_idioma(2);
end;

procedure TMConfig.RadioButton8Click(Sender: TObject);
begin
  main_vars.idioma:=3;
  cambiar_texto_idioma(3);
end;

procedure TMConfig.RadioButton9Click(Sender: TObject);
begin
  main_vars.idioma:=4;
  cambiar_texto_idioma(4);
end;

initialization
  {$I config_general.lrs}

end.

