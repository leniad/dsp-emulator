unit config_general;

interface
uses
  lib_sdl2,Variants,Classes,Controls,Forms,Dialogs,
  StdCtrls,ExtCtrls,lenguaje,main_engine,ComCtrls,Buttons,controls_engine,
  SHLOBJ,redefine_main;

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
    GroupBox15: TGroupBox;
    RadioButton28: TRadioButton;
    RadioButton29: TRadioButton;
    Label6: TLabel;
    Label7: TLabel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    ComboBox3: TComboBox;
    Label8: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Label9: TLabel;
    ComboBox4: TComboBox;
    procedure FormShow(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure BitBtn21Click(Sender: TObject);
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
    procedure Button7Click(Sender: TObject);
    procedure BitBtn22Click(Sender: TObject);
    procedure RadioButton12Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MConfig:TMConfig;
  idioma_antes:byte;

implementation
uses principal,configgeneral_misc,rom_engine;
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

procedure TMConfig.Button3Click(Sender: TObject);
begin
  indice_redefinir:=0;
  mredefine.showmodal;
end;

procedure TMConfig.Button4Click(Sender: TObject);
begin
  indice_redefinir:=1;
  mredefine.showmodal;
end;

procedure TMConfig.Button5Click(Sender: TObject);
begin
  indice_redefinir:=2;
  mredefine.showmodal;
end;

procedure TMConfig.Button6Click(Sender: TObject);
begin
  indice_redefinir:=3;
  mredefine.showmodal;
end;

procedure TMConfig.Button7Click(Sender: TObject);
begin
  indice_redefinir:=4;
  mredefine.showmodal;
end;

procedure TMConfig.Button8Click(Sender: TObject);
begin
  indice_redefinir:=5;
  mredefine.showmodal;
end;

procedure TMConfig.Button9Click(Sender: TObject);
begin
  indice_redefinir:=6;
  mredefine.showmodal;
end;

procedure TMConfig.Button10Click(Sender: TObject);
begin
  indice_redefinir:=7;
  mredefine.showmodal;
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
