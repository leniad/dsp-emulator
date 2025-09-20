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
    BitBtn23: TBitBtn;
    BitBtn24: TBitBtn;
    BitBtn25: TBitBtn;
    BitBtn26: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn9: TBitBtn;
    Button1: TButton;
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
    procedure BitBtn23Click(Sender: TObject);
    procedure BitBtn24Click(Sender: TObject);
    procedure BitBtn25Click(Sender: TObject);
    procedure BitBtn26Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure CheckBox16Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
    procedure RadioButton11Click(Sender: TObject);
    procedure RadioButton12Change(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton21Change(Sender: TObject);
    procedure RadioButton22Change(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
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
  config_button:boolean;

implementation
uses principal, redefine,configgeneral_misc;

{ TMConfig }

procedure TMConfig.BitBtn9Click(Sender: TObject);
begin
  read_button(9,0);
end;

procedure TMConfig.BitBtn10Click(Sender: TObject);
begin
  read_button(10,0);
end;

procedure TMConfig.BitBtn11Click(Sender: TObject);
begin
  read_button(11,0);
end;

procedure TMConfig.BitBtn12Click(Sender: TObject);
begin
  read_button(12,1);
end;

procedure TMConfig.BitBtn13Click(Sender: TObject);
begin
  read_button(13,1);
end;

procedure TMConfig.BitBtn14Click(Sender: TObject);
begin
  read_button(14,1);
end;

procedure TMConfig.BitBtn15Click(Sender: TObject);
begin
  read_button(15,0);
end;

procedure TMConfig.BitBtn16Click(Sender: TObject);
begin
  read_button(16,0);
end;

procedure TMConfig.BitBtn17Click(Sender: TObject);
begin
  read_button(17,0);
end;

procedure TMConfig.BitBtn18Click(Sender: TObject);
begin
  read_button(18,1);
end;

procedure TMConfig.BitBtn19Click(Sender: TObject);
begin
 read_button(19,1);
end;

procedure TMConfig.BitBtn20Click(Sender: TObject);
begin
  read_button(20,1);
end;

procedure TMConfig.BitBtn23Click(Sender: TObject);
begin
  read_button(23,0);
end;

procedure TMConfig.BitBtn24Click(Sender: TObject);
begin
  read_button(24,0);
end;

procedure TMConfig.BitBtn25Click(Sender: TObject);
begin
  read_button(25,1);
end;

procedure TMConfig.BitBtn26Click(Sender: TObject);
begin
  read_button(26,1);
end;

procedure TMConfig.BitBtn1Click(Sender: TObject);
begin
  read_dir(1);
end;

procedure TMConfig.BitBtn2Click(Sender: TObject);
begin
  read_dir(2);
end;

procedure TMConfig.BitBtn3Click(Sender: TObject);
begin
  read_dir(3);
end;

procedure TMConfig.BitBtn4Click(Sender: TObject);
begin
  read_dir(4);
end;

procedure TMConfig.BitBtn5Click(Sender: TObject);
begin
  read_dir(5);
end;

procedure TMConfig.BitBtn6Click(Sender: TObject);
begin
  read_dir(6);
end;

procedure TMConfig.BitBtn7Click(Sender: TObject);
begin
  read_dir(7);
end;

procedure TMConfig.BitBtn8Click(Sender: TObject);
begin
  read_dir(8);
end;

procedure TMConfig.BitBtn21Click(Sender: TObject);
begin
  export_roms;
end;

procedure TMConfig.BitBtn22Click(Sender: TObject);
begin
  export_samples;
end;

procedure TMConfig.Button1Click(Sender: TObject);

begin
configgeneral_formclose;
close;
end;

procedure TMConfig.Button2Click(Sender: TObject);
begin
if main_vars.idioma<>idioma_antes then begin
   main_vars.idioma:=idioma_antes;
   cambiar_idioma;
end;
close;
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
configeneral_autofire;
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

procedure TMConfig.FormShow(Sender: TObject);
begin
configgeneral_formshow;
end;

procedure TMConfig.RadioButton10Click(Sender: TObject);
begin
  main_vars.idioma:=5;
  cambiar_idioma;
  cambiar_idioma_ventanas;
end;

procedure TMConfig.RadioButton11Click(Sender: TObject);
begin
  main_vars.idioma:=6;
  cambiar_idioma;
  cambiar_idioma_ventanas;
end;

procedure TMConfig.RadioButton12Change(Sender: TObject);
begin
  main_vars.idioma:=200;
  cambiar_idioma;
  cambiar_idioma_ventanas;
end;

procedure TMConfig.RadioButton1Click(Sender: TObject);
begin
  select_keyboard_p1;
end;

procedure TMConfig.RadioButton2Click(Sender: TObject);
begin
  select_joystick_p1;
end;

procedure TMConfig.RadioButton3Click(Sender: TObject);
begin
  select_keyboard_p2;
end;

procedure TMConfig.RadioButton4Click(Sender: TObject);
begin
  select_joystick_p2;
end;

procedure TMConfig.RadioButton21Change(Sender: TObject);
begin
  bitbtn7.Enabled:=false;
end;

procedure TMConfig.RadioButton22Change(Sender: TObject);
begin
  bitbtn7.Enabled:=true;
end;

procedure TMConfig.RadioButton5Click(Sender: TObject);
begin
  main_vars.idioma:=0;
  cambiar_idioma;
  cambiar_idioma_ventanas;
end;

procedure TMConfig.RadioButton6Click(Sender: TObject);
begin
  main_vars.idioma:=1;
  cambiar_idioma;
  cambiar_idioma_ventanas;
end;

procedure TMConfig.RadioButton7Click(Sender: TObject);
begin
  main_vars.idioma:=2;
  cambiar_idioma;
  cambiar_idioma_ventanas;
end;

procedure TMConfig.RadioButton8Click(Sender: TObject);
begin
  main_vars.idioma:=3;
  cambiar_idioma;
  cambiar_idioma_ventanas;
end;

procedure TMConfig.RadioButton9Click(Sender: TObject);
begin
  main_vars.idioma:=4;
  cambiar_idioma;
  cambiar_idioma_ventanas;
end;

initialization
  {$I config_general.lrs}

end.

