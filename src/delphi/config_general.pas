unit config_general;

interface
uses
  lib_sdl2,Variants,Classes,Controls,Forms,Dialogs,
  StdCtrls,ExtCtrls,lenguaje,main_engine,ComCtrls,Buttons,controls_engine,
  SHLOBJ,rom_export;

type
  TMConfig = class(TForm)
    Button1: TButton;
    Button2: TButton;
    other: TPageControl;
    TabSheet1: TTabSheet;
    GroupBox3: TGroupBox;
    RadioButton6: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    GroupBox4: TGroupBox;
    RadioButton14: TRadioButton;
    RadioButton15: TRadioButton;
    GroupBox5: TGroupBox;
    RadioButton16: TRadioButton;
    RadioButton17: TRadioButton;
    RadioButton18: TRadioButton;
    RadioButton19: TRadioButton;
    RadioButton20: TRadioButton;
    GroupBox6: TGroupBox;
    CheckBox2: TCheckBox;
    CheckBox1: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox17: TCheckBox;
    TabSheet2: TTabSheet;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    Label4: TLabel;
    Label5: TLabel;
    SpeedButton5: TSpeedButton;
    Label2: TLabel;
    SpeedButton2: TSpeedButton;
    Label3: TLabel;
    SpeedButton6: TSpeedButton;
    Label12: TLabel;
    SpeedButton8: TSpeedButton;
    SpeedButton4: TSpeedButton;
    d1: TEdit;
    d4: TEdit;
    d5: TEdit;
    d2: TEdit;
    d3: TEdit;
    D6: TEdit;
    TabSheet3: TTabSheet;
    GroupBox1: TGroupBox;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn9: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn15: TBitBtn;
    BitBtn16: TBitBtn;
    BitBtn17: TBitBtn;
    GroupBox7: TGroupBox;
    Button7: TButton;
    ComboBox1: TComboBox;
    GroupBox2: TGroupBox;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    Label25: TLabel;
    Label26: TLabel;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    BitBtn12: TBitBtn;
    BitBtn13: TBitBtn;
    BitBtn14: TBitBtn;
    BitBtn18: TBitBtn;
    BitBtn19: TBitBtn;
    BitBtn20: TBitBtn;
    GroupBox10: TGroupBox;
    ComboBox2: TComboBox;
    Button8: TButton;
    ROM: TTabSheet;
    BitBtn21: TBitBtn;
    Autofire: TTabSheet;
    GroupBox8: TGroupBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    CheckBox7: TCheckBox;
    CheckBox8: TCheckBox;
    CheckBox9: TCheckBox;
    GroupBox9: TGroupBox;
    CheckBox10: TCheckBox;
    CheckBox11: TCheckBox;
    CheckBox12: TCheckBox;
    CheckBox13: TCheckBox;
    CheckBox14: TCheckBox;
    CheckBox15: TCheckBox;
    CheckBox16: TCheckBox;
    BitBtn22: TBitBtn;
    RadioButton12: TRadioButton;
    BitBtn23: TBitBtn;
    BitBtn24: TBitBtn;
    BitBtn25: TBitBtn;
    BitBtn26: TBitBtn;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure BitBtn8Click(Sender: TObject);
    procedure BitBtn7Click(Sender: TObject);
    procedure BitBtn12Click(Sender: TObject);
    procedure BitBtn13Click(Sender: TObject);
    procedure BitBtn14Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure BitBtn17Click(Sender: TObject);
    procedure BitBtn15Click(Sender: TObject);
    procedure BitBtn16Click(Sender: TObject);
    procedure BitBtn19Click(Sender: TObject);
    procedure BitBtn18Click(Sender: TObject);
    procedure BitBtn20Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure BitBtn21Click(Sender: TObject);
    procedure RadioButton22Click(Sender: TObject);
    procedure RadioButton21Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure CheckBox16Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton11Click(Sender: TObject);
    procedure RadioButton6Click(Sender: TObject);
    procedure RadioButton7Click(Sender: TObject);
    procedure RadioButton8Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure BitBtn22Click(Sender: TObject);
    procedure RadioButton12Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure BitBtn23Click(Sender: TObject);
    procedure BitBtn24Click(Sender: TObject);
    procedure BitBtn25Click(Sender: TObject);
    procedure BitBtn26Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MConfig:TMConfig;
  tecla_leida:word;
  idioma_antes:byte;
  config_button:boolean;

implementation
uses principal,redefine,configgeneral_misc;
{$R *.dfm}

function BrowseForFolder(init_dir,title:string):string;
var
  browseInfo:tbrowseInfo;
  itemidList:pitemIDList;
  displayname:array[0..259] of char;
function remove_last_char(tempch:string):string;
var
  f:integer;
  resch:string;
begin
if tempch[length(tempch)]=main_vars.cadena_dir then begin
  resch:='';
  for f:=1 to (length(tempch)-1) do resch:=resch+tempch[f];
end else resch:=tempch;
remove_last_char:=resch;
end;
begin
  FillChar(BrowseInfo,SizeOf(BrowseInfo),0);
  BrowseInfo.hwndOwner:=Application.Handle;
  BrowseInfo.pszDisplayName:=@DisplayName[0];
  BrowseInfo.lpszTitle:=PChar(Title);
  BrowseInfo.ulFlags:=BIF_RETURNONLYFSDIRS;
  ItemIDList:=SHBrowseForFolder(BrowseInfo);
  if Assigned(ItemIDList) then begin
    if SHGetPathFromIDList(ItemIDList,DisplayName) then BrowseForFolder:=DisplayName;
  end else BrowseForFolder:=remove_last_char(init_dir);
end;

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


procedure TMConfig.FormCreate(Sender: TObject);
begin
  config_general_idioma;
end;

procedure TMConfig.FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
begin
case key of
    13:button1Click(nil);
    27:button2click(nil);
end;
end;

procedure TMConfig.FormShow(Sender: TObject);
begin
  configgeneral_formshow;
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

procedure TMConfig.RadioButton21Click(Sender: TObject);
begin
  button7.Enabled:=false;
end;

procedure TMConfig.RadioButton22Click(Sender: TObject);
begin
 button7.Enabled:=true;
end;

procedure TMConfig.SpeedButton1Click(Sender: TObject);
begin
  d1.Text:=BrowseForFolder(d1.text,label1.Caption);
end;

procedure TMConfig.SpeedButton2Click(Sender: TObject);
begin
  d2.Text:=BrowseForFolder(d2.text,label2.Caption);
end;

procedure TMConfig.SpeedButton4Click(Sender: TObject);
begin
  d4.Text:=d4.Text+BrowseForFolder(d4.text,label4.Caption);
end;

procedure TMConfig.SpeedButton5Click(Sender: TObject);
begin
  d5.Text:=BrowseForFolder(d5.text,label5.Caption);
end;

procedure TMConfig.SpeedButton6Click(Sender: TObject);
begin
  d3.Text:=BrowseForFolder(d3.text,label3.Caption);
end;

procedure TMConfig.SpeedButton8Click(Sender: TObject);
begin
  d6.Text:=BrowseForFolder(d6.text,label12.Caption);
end;

procedure TMConfig.Button2Click(Sender: TObject);
begin
  if main_vars.idioma<>idioma_antes then begin
    main_vars.idioma:=idioma_antes;
    cambiar_idioma;
    cambiar_idioma_ventanas;
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

procedure TMConfig.ComboBox1Change(Sender: TObject);
begin
  arcade_input.num_joystick[0]:=combobox1.ItemIndex;
end;

procedure TMConfig.ComboBox2Change(Sender: TObject);
begin
  arcade_input.num_joystick[1]:=combobox2.ItemIndex;
end;

procedure TMConfig.Button1Click(Sender: TObject);
begin
configgeneral_formclose;
close;
end;

procedure TMConfig.CheckBox16Click(Sender: TObject);
begin
configeneral_autofire;
end;

procedure TMConfig.BitBtn21Click(Sender: TObject);
begin
export_roms;
end;

procedure TMConfig.BitBtn22Click(Sender: TObject);
begin
export_samples;
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

procedure TMConfig.RadioButton12Click(Sender: TObject);
begin
main_vars.idioma:=200;
cambiar_idioma;
cambiar_idioma_ventanas;
end;

end.
