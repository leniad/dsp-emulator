unit config_general;

interface

uses
  lib_sdl2,Messages,SysUtils,Variants,Classes,Graphics,Controls,Forms,Dialogs,
  StdCtrls,ExtCtrls,lenguaje,main_engine,ComCtrls,Buttons,controls_engine,
  sound_engine,SHLOBJ,rom_export,timer_engine;

type
  TMConfig = class(TForm)
    Button1: TButton;
    Button2: TButton;
    other: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    d1: TEdit;
    Label1: TLabel;
    SpeedButton1: TSpeedButton;
    Label4: TLabel;
    d4: TEdit;
    d5: TEdit;
    Label5: TLabel;
    TabSheet3: TTabSheet;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn1: TBitBtn;
    BitBtn4: TBitBtn;
    GroupBox2: TGroupBox;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    ComboBox2: TComboBox;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    BitBtn7: TBitBtn;
    BitBtn8: TBitBtn;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    BitBtn9: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    Label9: TLabel;
    BitBtn12: TBitBtn;
    Label10: TLabel;
    BitBtn13: TBitBtn;
    Label11: TLabel;
    BitBtn14: TBitBtn;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    ComboBox5: TComboBox;
    ComboBox6: TComboBox;
    ComboBox7: TComboBox;
    ComboBox8: TComboBox;
    SpeedButton5: TSpeedButton;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    BitBtn15: TBitBtn;
    BitBtn16: TBitBtn;
    BitBtn17: TBitBtn;
    ComboBox9: TComboBox;
    ComboBox10: TComboBox;
    ComboBox11: TComboBox;
    BitBtn18: TBitBtn;
    BitBtn19: TBitBtn;
    BitBtn20: TBitBtn;
    ComboBox12: TComboBox;
    ComboBox13: TComboBox;
    ComboBox14: TComboBox;
    Label18: TLabel;
    Label19: TLabel;
    Label20: TLabel;
    GroupBox3: TGroupBox;
    RadioButton6: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    RadioButton11: TRadioButton;
    GroupBox4: TGroupBox;
    RadioButton12: TRadioButton;
    RadioButton13: TRadioButton;
    RadioButton14: TRadioButton;
    RadioButton15: TRadioButton;
    TabSheet4: TTabSheet;
    Label21: TLabel;
    Label22: TLabel;
    Label23: TLabel;
    Label24: TLabel;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
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
    Button8: TButton;
    ROM: TTabSheet;
    BitBtn21: TBitBtn;
    RadioButton24: TRadioButton;
    RadioButton23: TRadioButton;
    GroupBox7: TGroupBox;
    RadioButton22: TRadioButton;
    RadioButton21: TRadioButton;
    Button7: TButton;
    ComboBox1: TComboBox;
    d2: TEdit;
    Label2: TLabel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    d3: TEdit;
    Label3: TLabel;
    SpeedButton6: TSpeedButton;
    SpeedButton7: TSpeedButton;
    Label12: TLabel;
    D6: TEdit;
    SpeedButton8: TSpeedButton;
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
    SpeedButton4: TSpeedButton;
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
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure BitBtn21Click(Sender: TObject);
    procedure RadioButton22Click(Sender: TObject);
    procedure RadioButton21Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure CheckBox16Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  MConfig:TMConfig;
  tecla_leida:word;

implementation
uses principal,redefine, joystick_calibrate;
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

procedure TMConfig.BitBtn10Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
      bitbtn10.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nbut1[0]:=tecla_leida;
  end;
end;

procedure TMConfig.BitBtn11Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    bitbtn11.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nbut2[0]:=tecla_leida;
  end;
end;

PROCEDURE TMConfig.BitBtn12Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    bitbtn12.Caption := nombre_tecla(tecla_leida);
    arcade_input.nbut0[1] := tecla_leida;
  END;
END;

PROCEDURE TMConfig.BitBtn13Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    bitbtn13.Caption := nombre_tecla(tecla_leida);
    arcade_input.nbut1[1] := tecla_leida;
  END;
END;

PROCEDURE TMConfig.BitBtn14Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    bitbtn14.Caption := nombre_tecla(tecla_leida);
    arcade_input.nbut2[1] := tecla_leida;
  END;
END;

procedure TMConfig.BitBtn15Click(Sender: TObject);
begin
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    bitbtn15.Caption := nombre_tecla(tecla_leida);
    arcade_input.nbut4[0] := tecla_leida;
  END;
end;

procedure TMConfig.BitBtn16Click(Sender: TObject);
begin
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    bitbtn16.Caption := nombre_tecla(tecla_leida);
    arcade_input.nbut5[0] := tecla_leida;
  END;
end;

procedure TMConfig.BitBtn17Click(Sender: TObject);
begin
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    bitbtn17.Caption := nombre_tecla(tecla_leida);
    arcade_input.nbut3[0] := tecla_leida;
  END;
end;

procedure TMConfig.BitBtn18Click(Sender: TObject);
begin
redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    bitbtn18.Caption := nombre_tecla(tecla_leida);
    arcade_input.nbut3[1] := tecla_leida;
  END;
end;

procedure TMConfig.BitBtn19Click(Sender: TObject);
begin
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    bitbtn19.Caption:= nombre_tecla(tecla_leida);
    arcade_input.nbut4[1]:=tecla_leida;
  END;
end;

PROCEDURE TMConfig.BitBtn1Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    bitbtn1.Caption:= nombre_tecla(tecla_leida);
    arcade_input.nleft[0]:= tecla_leida;
  end;
end;

procedure TMConfig.FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
begin
  case key of
    13:button1Click(nil);
    27:button2click(nil);
  end;
end;

procedure TMConfig.FormShow(Sender: TObject);
var
  f:integer;
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
  GroupBox3.Caption:=leng[main_vars.idioma].archivo[1];
  button2.Caption:=leng[main_vars.idioma].mensajes[8];
  //idioma
  case main_vars.idioma of
    0:radiobutton5.Checked:=true;
    1:radiobutton6.Checked:=true;
    2:radiobutton7.Checked:=true;
    3:radiobutton8.Checked:=true;
    4:radiobutton9.Checked:=true;
    5:radiobutton10.Checked:=true;
    6:radiobutton11.Checked:=true;
  end;
  //audio
  radiobutton15.Caption := leng[main_vars.idioma].opciones[3];
  case sound_status.calidad_audio of
    0:radiobutton12.Checked:=true;
    1:radiobutton13.Checked:=true;
    2:radiobutton14.Checked:=true;
    3:radiobutton15.Checked:=true;
  end;
  //video
  case main_screen.video_mode of
    0:groupbox5.Enabled:=false;
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
  if event.num_joysticks=0 then begin
    radiobutton1.Checked:=true;
    radiobutton2.Checked:=false;
    radiobutton2.enabled:=false;
    button7.Enabled:=false;
    radiobutton3.Checked:=true;
    radiobutton4.Checked:=false;
    radiobutton4.enabled:=false;
    button8.Enabled:=false;
    combobox1.Enabled:=false;
    combobox1.Items.Add('');
    combobox1.itemindex:=0;
    combobox2.Enabled:=false;
    combobox2.Items.Add('');
    combobox2.itemindex:=0;
    bitbtn9.visible:=true;
    bitbtn10.visible:=true;
    bitbtn11.visible:=true;
    bitbtn15.visible:=true;
    bitbtn16.visible:=true;
    bitbtn17.visible:=true;
    combobox3.Visible:=false;
    combobox4.Visible:=false;
    combobox5.Visible:=false;
    combobox9.Visible:=false;
    combobox10.Visible:=false;
    combobox11.Visible:=false;
    bitbtn12.Visible:=true;
    bitbtn13.visible:=true;
    bitbtn14.visible:=true;
    bitbtn18.Visible:=true;
    bitbtn19.visible:=true;
    bitbtn20.visible:=true;
    combobox6.Visible:=false;
    combobox7.Visible:=false;
    combobox8.Visible:=false;
    combobox12.Visible:=false;
    combobox13.Visible:=false;
    combobox14.Visible:=false;
    radiobutton21.enabled:=false;
    radiobutton22.enabled:=false;
    radiobutton23.enabled:=false;
    radiobutton24.enabled:=false;
  end else begin
    radiobutton2.enabled:=true;
    if arcade_input.use_key[0] then begin
      radiobutton1.Checked:=true;
      radiobutton2.Checked:=false;
      button7.Enabled:=false;
      bitbtn1.Enabled:=true;
      bitbtn2.Enabled:=true;
      bitbtn3.Enabled:=true;
      bitbtn4.Enabled:=true;
      bitbtn9.visible:=true;
      bitbtn10.visible:=true;
      bitbtn11.visible:=true;
      bitbtn15.visible:=true;
      bitbtn16.visible:=true;
      bitbtn17.visible:=true;
      combobox3.Visible:=false;
      combobox4.Visible:=false;
      combobox5.Visible:=false;
      combobox9.Visible:=false;
      combobox10.Visible:=false;
      combobox11.Visible:=false;
      radiobutton21.enabled:=false;
      radiobutton22.enabled:=false;
    end else begin
      radiobutton1.Checked:=false;
      radiobutton2.Checked:=true;
      button7.Enabled:=true;
      bitbtn1.Enabled:=false;
      bitbtn2.Enabled:=false;
      bitbtn3.Enabled:=false;
      bitbtn4.Enabled:=false;
      bitbtn9.visible:=false;
      bitbtn10.visible:=false;
      bitbtn11.visible:=false;
      bitbtn15.visible:=false;
      bitbtn16.visible:=false;
      bitbtn17.visible:=false;
      combobox3.Visible:=true;
      combobox4.Visible:=true;
      combobox5.Visible:=true;
      combobox9.Visible:=true;
      combobox10.Visible:=true;
      combobox11.Visible:=true;
      bitbtn7.enabled:=true;
      if SDL_JoystickNumHats(joystick_def[0])<>0 then begin
        radiobutton21.Enabled:=true;
        radiobutton22.Enabled:=true;
      end else begin
        radiobutton21.Enabled:=false;
        radiobutton22.Enabled:=true;
        radiobutton22.Checked:=true;
      end;
    end;
    radiobutton4.enabled:=true;
    if arcade_input.use_key[1] then begin
      radiobutton3.Checked:=true;
      radiobutton4.Checked:=false;
      button8.Enabled:=false;
      bitbtn5.Enabled:=true;
      bitbtn6.Enabled:=true;
      bitbtn7.Enabled:=true;
      bitbtn8.Enabled:=true;
      bitbtn12.Visible:=true;
      bitbtn13.visible:=true;
      bitbtn14.visible:=true;
      bitbtn18.Visible:=true;
      bitbtn19.visible:=true;
      bitbtn20.visible:=true;
      combobox6.Visible:=false;
      combobox7.Visible:=false;
      combobox8.Visible:=false;
      combobox12.Visible:=false;
      combobox13.Visible:=false;
      combobox14.Visible:=false;
      radiobutton23.enabled:=false;
      radiobutton24.enabled:=false;
    end else begin
      radiobutton3.Checked:=false;
      radiobutton4.Checked:=true;
      button8.Enabled:=true;
      bitbtn5.Enabled:=false;
      bitbtn6.Enabled:=false;
      bitbtn7.Enabled:=false;
      bitbtn8.Enabled:=false;
      bitbtn12.Visible:=false;
      bitbtn13.visible:=false;
      bitbtn14.visible:=false;
      bitbtn12.Visible:=false;
      bitbtn13.visible:=false;
      bitbtn14.visible:=false;
      combobox6.Visible:=true;
      combobox7.Visible:=true;
      combobox8.Visible:=true;
      combobox12.Visible:=true;
      combobox13.Visible:=true;
      combobox14.Visible:=true;
      if SDL_JoystickNumHats(joystick_def[1])<>0 then begin
        radiobutton23.Enabled:=true;
        radiobutton24.Enabled:=true;
      end else begin
        radiobutton23.Enabled:=false;
        radiobutton24.Enabled:=true;
        radiobutton24.Checked:=true;
      end;
    end;
    combobox1.Clear;
    combobox2.Clear;
    for f:=0 to (event.num_joysticks-1) do begin
      combobox1.Items.Add(extract_joy_name(SDL_JoystickName(joystick_def[f])));
      combobox2.Items.Add(extract_joy_name(SDL_JoystickName(joystick_def[f])));
    end;
    combobox1.Enabled:=true;
    combobox1.ItemIndex:=arcade_input.num_joystick[0];
    combobox2.Enabled:=true;
    combobox2.ItemIndex:=arcade_input.num_joystick[1];
    combobox3.Clear;
    combobox4.Clear;
    combobox5.Clear;
    combobox9.Clear;
    combobox10.Clear;
    combobox11.Clear;
    combobox6.Clear;
    combobox7.Clear;
    combobox8.Clear;
    combobox12.Clear;
    combobox13.Clear;
    combobox14.Clear;
    for f:=0 to (sdl_joysticknumbuttons(joystick_def[0])-1) do begin
      combobox3.Items.Add('But '+inttostr(f));
      combobox4.Items.Add('But '+inttostr(f));
      combobox5.Items.Add('But '+inttostr(f));
      combobox9.Items.Add('But '+inttostr(f));
      combobox10.Items.Add('But '+inttostr(f));
      combobox11.Items.Add('But '+inttostr(f));
    end;
    for f:=0 to (sdl_joysticknumbuttons(joystick_def[1])-1) do begin
      combobox6.Items.Add('But ' + inttostr(f));
      combobox7.Items.Add('But ' + inttostr(f));
      combobox8.Items.Add('But ' + inttostr(f));
      combobox12.Items.Add('But ' + inttostr(f));
      combobox13.Items.Add('But ' + inttostr(f));
      combobox14.Items.Add('But ' + inttostr(f));
    end;
    combobox3.ItemIndex:=arcade_input.jbut0[0];
    combobox4.ItemIndex:=arcade_input.jbut1[0];
    combobox5.ItemIndex:=arcade_input.jbut2[0];
    combobox9.ItemIndex:=arcade_input.jbut3[0];
    combobox10.ItemIndex:=arcade_input.jbut4[0];
    combobox11.ItemIndex:=arcade_input.jbut5[0];
    combobox6.ItemIndex:=arcade_input.jbut0[1];
    combobox7.ItemIndex:=arcade_input.jbut1[1];
    combobox8.ItemIndex:=arcade_input.jbut2[1];
    combobox12.ItemIndex:=arcade_input.jbut3[1];
    combobox13.ItemIndex:=arcade_input.jbut4[1];
    combobox14.ItemIndex:=arcade_input.jbut5[1];
  end;
  checkbox4.Checked:=timers.autofire_enabled[0];
  checkbox5.Checked:=timers.autofire_enabled[1];
  checkbox6.Checked:=timers.autofire_enabled[2];
  checkbox7.Checked:=timers.autofire_enabled[3];
  checkbox8.Checked:=timers.autofire_enabled[4];
  checkbox9.Checked:=timers.autofire_enabled[5];
  checkbox10.Checked:=timers.autofire_enabled[6];
  checkbox11.Checked:=timers.autofire_enabled[7];
  checkbox12.Checked:=timers.autofire_enabled[8];
  checkbox13.Checked:=timers.autofire_enabled[9];
  checkbox14.Checked:=timers.autofire_enabled[10];
  checkbox15.Checked:=timers.autofire_enabled[11];
  checkbox16.Checked:=timers.autofire_on;
  CheckBox16Click(self);
  //Player 1
  bitbtn1.Caption:=nombre_tecla(arcade_input.nleft[0]);
  bitbtn2.Caption:=nombre_tecla(arcade_input.nright[0]);
  bitbtn3.Caption:=nombre_tecla(arcade_input.ndown[0]);
  bitbtn4.Caption:=nombre_tecla(arcade_input.nup[0]);
  bitbtn9.Caption:=nombre_tecla(arcade_input.nbut0[0]);
  bitbtn10.Caption:=nombre_tecla(arcade_input.nbut1[0]);
  bitbtn11.Caption:=nombre_tecla(arcade_input.nbut2[0]);
  bitbtn17.Caption:=nombre_tecla(arcade_input.nbut3[0]);
  bitbtn15.Caption:=nombre_tecla(arcade_input.nbut4[0]);
  bitbtn16.Caption:=nombre_tecla(arcade_input.nbut5[0]);
  //Player 2
  bitbtn6.Caption:=nombre_tecla(arcade_input.nleft[1]);
  bitbtn7.Caption:=nombre_tecla(arcade_input.nright[1]);
  bitbtn8.Caption:=nombre_tecla(arcade_input.ndown[1]);
  bitbtn5.Caption:=nombre_tecla(arcade_input.nup[1]);
  bitbtn12.Caption:=nombre_tecla(arcade_input.nbut0[1]);
  bitbtn13.Caption:=nombre_tecla(arcade_input.nbut1[1]);
  bitbtn14.Caption:=nombre_tecla(arcade_input.nbut2[1]);
  bitbtn18.Caption:=nombre_tecla(arcade_input.nbut3[1]);
  bitbtn19.Caption:=nombre_tecla(arcade_input.nbut4[1]);
  bitbtn20.Caption:=nombre_tecla(arcade_input.nbut5[1]);
  //Misc Keys
  button3.Caption:=nombre_tecla(arcade_input.ncoin[0]);
  button4.Caption:=nombre_tecla(arcade_input.ncoin[1]);
  button5.Caption:=nombre_tecla(arcade_input.nstart[0]);
  button6.Caption:=nombre_tecla(arcade_input.nstart[1]);
end;

procedure TMConfig.RadioButton1Click(Sender: TObject);
begin
  bitbtn1.Enabled:=true;
  bitbtn2.Enabled:=true;
  bitbtn3.Enabled:=true;
  bitbtn4.Enabled:=true;
  bitbtn9.visible:=true;
  bitbtn10.visible:=true;
  bitbtn11.visible:=true;
  bitbtn15.visible:=true;
  bitbtn16.visible:=true;
  bitbtn17.visible:=true;
  combobox1.enabled:=false;
  combobox3.Visible:=false;
  combobox4.Visible:=false;
  combobox5.Visible:=false;
  combobox9.Visible:=false;
  combobox10.Visible:=false;
  combobox11.Visible:=false;
  button7.Enabled:=false;
  radiobutton21.Enabled:=false;
  radiobutton22.Enabled:=false;
end;

procedure TMConfig.RadioButton21Click(Sender: TObject);
begin
  bitbtn7.Enabled:=false;
end;

procedure TMConfig.RadioButton22Click(Sender: TObject);
begin
 bitbtn7.Enabled:=true;
end;

procedure TMConfig.RadioButton2Click(Sender: TObject);
begin
  bitbtn1.Enabled:=false;
  bitbtn2.Enabled:=false;
  bitbtn3.Enabled:=false;
  bitbtn4.Enabled:=false;
  bitbtn9.visible:=false;
  bitbtn10.visible:=false;
  bitbtn11.visible:=false;
  bitbtn15.visible:=false;
  bitbtn16.visible:=false;
  bitbtn17.visible:=false;
  combobox1.enabled:=true;
  combobox3.Visible:=true;
  combobox4.Visible:=true;
  combobox5.Visible:=true;
  combobox9.Visible:=true;
  combobox10.Visible:=true;
  combobox11.Visible:=true;
  button7.Enabled:=true;
  if SDL_JoystickNumHats(joystick_def[arcade_input.num_joystick[0]])<>0 then begin
    radiobutton21.Enabled:=true;
    radiobutton22.Enabled:=true;
  end else begin
    radiobutton21.Enabled:=false;
    radiobutton22.Enabled:=true;
    radiobutton22.Checked:=true;
  end;
end;

procedure TMConfig.RadioButton3Click(Sender: TObject);
begin
  bitbtn5.Enabled:=true;
  bitbtn6.Enabled:=true;
  bitbtn7.Enabled:=true;
  bitbtn8.Enabled:=true;
  bitbtn12.visible:=true;
  bitbtn13.visible:=true;
  bitbtn14.visible:=true;
  bitbtn18.visible:=true;
  bitbtn19.visible:=true;
  bitbtn20.visible:=true;
  combobox6.Visible:=false;
  combobox7.Visible:=false;
  combobox8.Visible:=false;
  combobox12.Visible:=false;
  combobox13.Visible:=false;
  combobox14.Visible:=false;
  button8.Enabled:=false;
end;

procedure TMConfig.RadioButton4Click(Sender: TObject);
begin
  bitbtn5.Enabled:=false;
  bitbtn6.Enabled:=false;
  bitbtn7.Enabled:=false;
  bitbtn8.Enabled:=false;
  bitbtn12.visible:=false;
  bitbtn13.visible:=false;
  bitbtn14.visible:=false;
  bitbtn18.visible:=false;
  bitbtn19.visible:=false;
  bitbtn20.visible:=false;
  combobox6.Visible:=true;
  combobox7.Visible:=true;
  combobox8.Visible:=true;
  combobox12.Visible:=true;
  combobox13.Visible:=true;
  combobox14.Visible:=true;
  button8.Enabled:=true;
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
  close;
end;

procedure TMConfig.Button3Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    button3.Caption:=nombre_tecla(tecla_leida);
    arcade_input.ncoin[0]:=tecla_leida;
  end;
end;

procedure TMConfig.Button4Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    button4.Caption:=nombre_tecla(tecla_leida);
    arcade_input.ncoin[1]:=tecla_leida;
  end;
end;

procedure TMConfig.Button5Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    button5.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nstart[0]:=tecla_leida;
  end;
end;

procedure TMConfig.Button6Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    button6.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nstart[1]:=tecla_leida;
  end;
end;

procedure TMConfig.Button7Click(Sender: TObject);
begin
joy_calibration.show;
bucle_joystick(0);
end;

procedure TMConfig.Button8Click(Sender: TObject);
begin
joy_calibration.show;
bucle_joystick(1);
end;

procedure TMConfig.ComboBox1Change(Sender: TObject);
begin
  arcade_input.num_joystick[0]:=combobox1.ItemIndex;
  if SDL_JoystickNumHats(joystick_def[arcade_input.num_joystick[0]])<>0 then begin
    radiobutton21.Enabled:=true;
    radiobutton22.Enabled:=true;
  end else begin
    radiobutton21.Enabled:=false;
    radiobutton22.Enabled:=true;
    radiobutton22.Checked:=true;
  end;
end;

procedure TMConfig.BitBtn20Click(Sender: TObject);
begin
redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    bitbtn20.Caption := nombre_tecla(tecla_leida);
    arcade_input.nbut5[1] := tecla_leida;
  END;
end;

PROCEDURE TMConfig.BitBtn2Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    bitbtn2.Caption := nombre_tecla(tecla_leida);
    arcade_input.nright[0] := tecla_leida;
  END;
END;

PROCEDURE TMConfig.BitBtn3Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    bitbtn3.Caption := nombre_tecla(tecla_leida);
    arcade_input.ndown[0] := tecla_leida;
  END;
END;

PROCEDURE TMConfig.BitBtn4Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    bitbtn4.Caption := nombre_tecla(tecla_leida);
    arcade_input.nup[0] := tecla_leida;
  END;
END;

PROCEDURE TMConfig.BitBtn5Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    bitbtn5.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nup[1]:=tecla_leida;
  END;
END;

PROCEDURE TMConfig.BitBtn6Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    bitbtn6.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nleft[1]:=tecla_leida;
  END;
END;

PROCEDURE TMConfig.BitBtn7Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    bitbtn7.Caption := nombre_tecla(tecla_leida);
    arcade_input.nright[1] := tecla_leida;
  END;
END;

PROCEDURE TMConfig.BitBtn8Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    bitbtn8.Caption:=nombre_tecla(tecla_leida);
    arcade_input.ndown[1]:=tecla_leida;
  END;
END;

PROCEDURE TMConfig.BitBtn9Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    bitbtn9.Caption:=nombre_tecla(tecla_leida);
    arcade_input.nbut0[0]:=tecla_leida;
  END;
END;

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
  if radiobutton5.Checked then tmp_var:=0
    else if radiobutton6.Checked then tmp_var:=1
      else if radiobutton7.Checked then tmp_var:=2
        else if radiobutton8.Checked then tmp_var:=3
          else if radiobutton9.Checked then tmp_var:=4
            else if radiobutton10.Checked then tmp_var:=5
              else if radiobutton11.Checked then tmp_var:=6;
  if tmp_var<> main_vars.idioma then begin
    main_vars.idioma:=tmp_var;
    principal1.IdiomaClick(nil);
  end;
  if radiobutton12.Checked then tmp_var:=0
    else if radiobutton13.Checked then tmp_var:=1
      else if radiobutton14.Checked then tmp_var:=2
        else if radiobutton15.Checked then tmp_var:=3;
  if tmp_var<>sound_status.calidad_audio then begin
    sound_status.calidad_audio:=tmp_var;
    principal1.CambiaAudio(nil);
  end;
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
  arcade_input.num_joystick[1]:=combobox2.ItemIndex;
  arcade_input.jbut0[0]:=combobox3.ItemIndex;
  arcade_input.jbut1[0]:=combobox4.ItemIndex;
  arcade_input.jbut2[0]:=combobox5.ItemIndex;
  arcade_input.jbut3[0]:=combobox9.ItemIndex;
  arcade_input.jbut4[0]:=combobox10.ItemIndex;
  arcade_input.jbut5[0]:=combobox11.ItemIndex;
  arcade_input.jbut0[1]:=combobox6.ItemIndex;
  arcade_input.jbut1[1]:=combobox7.ItemIndex;
  arcade_input.jbut2[1]:=combobox8.ItemIndex;
  arcade_input.jbut3[1]:=combobox12.ItemIndex;
  arcade_input.jbut4[1]:=combobox13.ItemIndex;
  arcade_input.jbut5[1]:=combobox14.ItemIndex;
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

procedure TMConfig.CheckBox16Click(Sender: TObject);
begin
timers.autofire_on:=checkbox16.Checked;
groupbox8.Enabled:=checkbox16.Checked;
groupbox9.Enabled:=checkbox16.Checked;
checkbox4.Enabled:=checkbox16.Checked;
checkbox5.Enabled:=checkbox16.Checked;
checkbox6.Enabled:=checkbox16.Checked;
checkbox7.Enabled:=checkbox16.Checked;
checkbox8.Enabled:=checkbox16.Checked;
checkbox9.Enabled:=checkbox16.Checked;
checkbox10.Enabled:=checkbox16.Checked;
checkbox11.Enabled:=checkbox16.Checked;
checkbox12.Enabled:=checkbox16.Checked;
checkbox13.Enabled:=checkbox16.Checked;
checkbox14.Enabled:=checkbox16.Checked;
checkbox15.Enabled:=checkbox16.Checked;
timers.enabled(timers.autofire_timer,checkbox16.Checked);
end;

procedure TMConfig.BitBtn21Click(Sender: TObject);
begin
export_roms;
end;

end.

