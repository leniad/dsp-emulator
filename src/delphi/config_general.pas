unit config_general;

interface

uses
  sdl2,Messages,SysUtils,Variants,Classes,Graphics,Controls,Forms,Dialogs,
  StdCtrls,ExtCtrls,lenguaje,main_engine,ComCtrls,Buttons,controls_engine,
  sound_engine,SHLOBJ;

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
    SpeedButton2: TSpeedButton;
    d2: TEdit;
    Label2: TLabel;
    SpeedButton3: TSpeedButton;
    d3: TEdit;
    Label3: TLabel;
    Label4: TLabel;
    d4: TEdit;
    SpeedButton4: TSpeedButton;
    d5: TEdit;
    Label5: TLabel;
    TabSheet3: TTabSheet;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    ComboBox1: TComboBox;
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
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
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
    Button7: TButton;
    Button8: TButton;
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
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
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
    SDL_SCANCODE_ESCAPE:nombre_tecla:='ESC';
    SDL_SCANCODE_CAPSLOCK:nombre_tecla:='CAPSLOCK';
    SDL_SCANCODE_TAB:nombre_tecla:='TAB';
    SDL_SCANCODE_SLASH:nombre_tecla:='SLASH';
    //SDL_SCANCODE_QUOTE:nombre_tecla:='QUOTE';
    SDL_SCANCODE_SEMICOLON:nombre_tecla:='SEMICOLON';
    SDL_SCANCODE_BACKSLASH:nombre_tecla:='DELETE';
    //SDL_SCANCODE_LESS:nombre_tecla:='LESS';
    SDL_SCANCODE_HOME:nombre_tecla:='HOME';
    SDL_SCANCODE_RIGHT:nombre_tecla:='RIGHT';
    SDL_SCANCODE_LEFT:nombre_tecla:='LEFT';
    SDL_SCANCODE_DOWN:nombre_tecla:='DOWN';
    SDL_SCANCODE_UP:nombre_tecla:='UP';
    SDL_SCANCODE_RALT:nombre_tecla:='RIGHT'+chr(10)+chr(13)+'ALT';
    SDL_SCANCODE_LALT:nombre_tecla:='LEFT'+chr(10)+chr(13)+'ALT';
    SDL_SCANCODE_RSHIFT:nombre_tecla:='RIGHT'+chr(10)+chr(13)+'SHIFT';
    SDL_SCANCODE_LSHIFT:nombre_tecla:='LEFT'+chr(10)+chr(13)+'SHIFT';
    SDL_SCANCODE_RCTRL:nombre_tecla:='RIGHT'+chr(10)+chr(13)+'CONTROL';
    SDL_SCANCODE_LCTRL:nombre_tecla:='LEFT'+chr(10)+chr(13)+'CONTROL';
    SDL_SCANCODE_RETURN:nombre_tecla:='ENTER';
    SDL_SCANCODE_SPACE:nombre_tecla:='SPACE';
    SDL_SCANCODE_A:nombre_tecla:='A';
    SDL_SCANCODE_B:nombre_tecla:='B';
    SDL_SCANCODE_C:nombre_tecla:='C';
    SDL_SCANCODE_D:nombre_tecla:='D';
    SDL_SCANCODE_E:nombre_tecla:='E';
    SDL_SCANCODE_F:nombre_tecla:='F';
    SDL_SCANCODE_G:nombre_tecla:='G';
    SDL_SCANCODE_H:nombre_tecla:='H';
    SDL_SCANCODE_I:nombre_tecla:='I';
    SDL_SCANCODE_J:nombre_tecla:='J';
    SDL_SCANCODE_K:nombre_tecla:='K';
    SDL_SCANCODE_L:nombre_tecla:='L';
    SDL_SCANCODE_M:nombre_tecla:='M';
    SDL_SCANCODE_N:nombre_tecla:='N';
    SDL_SCANCODE_O:nombre_tecla:='O';
    SDL_SCANCODE_P:nombre_tecla:='P';
    SDL_SCANCODE_Q:nombre_tecla:='Q';
    SDL_SCANCODE_R:nombre_tecla:='R';
    SDL_SCANCODE_S:nombre_tecla:='S';
    SDL_SCANCODE_T:nombre_tecla:='T';
    SDL_SCANCODE_U:nombre_tecla:='U';
    SDL_SCANCODE_V:nombre_tecla:='V';
    SDL_SCANCODE_W:nombre_tecla:='W';
    SDL_SCANCODE_X:nombre_tecla:='X';
    SDL_SCANCODE_Y:nombre_tecla:='Y';
    SDL_SCANCODE_Z:nombre_tecla:='Z';
    SDL_SCANCODE_1:nombre_tecla:='1';
    SDL_SCANCODE_2:nombre_tecla:='2';
    SDL_SCANCODE_3:nombre_tecla:='3';
    SDL_SCANCODE_4:nombre_tecla:='4';
    SDL_SCANCODE_5:nombre_tecla:='5';
    SDL_SCANCODE_6:nombre_tecla:='6';
    SDL_SCANCODE_7:nombre_tecla:='7';
    SDL_SCANCODE_8:nombre_tecla:='8';
    SDL_SCANCODE_9:nombre_tecla:='9';
    SDL_SCANCODE_0:nombre_tecla:='0';
    else nombre_tecla:='N/D';
  end;
end;

procedure TMConfig.BitBtn10Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    if tecla_leida=$FFFE then begin
      bitbtn10.Caption:='N/D';
      arcade_input.nbut1[0]:=$ffff;
    end else begin
      bitbtn10.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nbut1[0]:=tecla_leida;
    end;
  end;
end;

procedure TMConfig.BitBtn11Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    if tecla_leida=$FFFE then begin
      bitbtn11.Caption:='N/D';
      arcade_input.nbut2[0]:=$ffff;
    end else begin
      bitbtn11.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nbut2[0]:=tecla_leida;
    end;
  end;
end;

PROCEDURE TMConfig.BitBtn12Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn12.Caption:='N/D';
      arcade_input.nbut0[1]:=$ffff;
    end else begin
      bitbtn12.Caption := nombre_tecla(tecla_leida);
      arcade_input.nbut0[1] := tecla_leida;
    end;
  END;
END;

PROCEDURE TMConfig.BitBtn13Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn13.Caption:='N/D';
      arcade_input.nbut1[1]:=$ffff;
    end else begin
      bitbtn13.Caption := nombre_tecla(tecla_leida);
      arcade_input.nbut1[1] := tecla_leida;
    end;
  END;
END;

PROCEDURE TMConfig.BitBtn14Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn14.Caption:='N/D';
      arcade_input.nbut2[1]:=$ffff;
    end else begin
      bitbtn14.Caption := nombre_tecla(tecla_leida);
      arcade_input.nbut2[1] := tecla_leida;
    end;
  END;
END;

procedure TMConfig.BitBtn15Click(Sender: TObject);
begin
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn16.Caption:='N/D';
      arcade_input.nbut4[0]:=$ffff;
    end else begin
      bitbtn16.Caption := nombre_tecla(tecla_leida);
      arcade_input.nbut4[0] := tecla_leida;
    end;
  END;
end;

procedure TMConfig.BitBtn16Click(Sender: TObject);
begin
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn15.Caption:='N/D';
      arcade_input.nbut5[0]:=$ffff;
    end else begin
      bitbtn15.Caption := nombre_tecla(tecla_leida);
      arcade_input.nbut5[0] := tecla_leida;
    end;
  END;
end;

procedure TMConfig.BitBtn17Click(Sender: TObject);
begin
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn17.Caption:='N/D';
      arcade_input.nbut3[0]:=$ffff;
    end else begin
      bitbtn17.Caption := nombre_tecla(tecla_leida);
      arcade_input.nbut3[0] := tecla_leida;
    end;
  END;
end;

procedure TMConfig.BitBtn18Click(Sender: TObject);
begin
redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn18.Caption:='N/D';
      arcade_input.nbut3[1]:=$ffff;
    end else begin
      bitbtn18.Caption := nombre_tecla(tecla_leida);
      arcade_input.nbut3[1] := tecla_leida;
    end;
  END;
end;

procedure TMConfig.BitBtn19Click(Sender: TObject);
begin
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn19.Caption:='N/D';
      arcade_input.nbut4[1]:=$ffff;
    end else begin
      bitbtn19.Caption:= nombre_tecla(tecla_leida);
      arcade_input.nbut4[1]:=tecla_leida;
    end;
  END;
end;

PROCEDURE TMConfig.BitBtn1Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn1.Caption:='N/D';
      arcade_input.nleft[0]:=$ffff;
    end else begin
      bitbtn1.Caption:= nombre_tecla(tecla_leida);
      arcade_input.nleft[0]:= tecla_leida;
    end;
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
  if not(main_vars.lenguaje_ok) then begin
    groupbox3.Enabled:=false;
    radiobutton5.Enabled:=false;
    radiobutton6.Enabled:=false;
    radiobutton7.Enabled:=false;
    radiobutton8.Enabled:=false;
    radiobutton9.Enabled:=false;
    radiobutton10.Enabled:=false;
    radiobutton11.Enabled:=false;
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
  D1.Text:=Directory.Nes;
  D2.Text:=Directory.GameBoy;
  D3.Text:=Directory.ColecoVision;
  D4.Text:=Directory.Arcade_roms;
  D5.Text:=Directory.Arcade_hi;
  //Componer todas las entradas
  if SDL_NumJoysticks=0 then begin
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
    end;
    combobox1.Clear;
    combobox2.Clear;
    for f:=0 to (SDL_NumJoysticks()-1) do begin
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
  combobox3.Visible:=false;
  combobox4.Visible:=false;
  combobox5.Visible:=false;
  combobox9.Visible:=false;
  combobox10.Visible:=false;
  combobox11.Visible:=false;
  button7.Enabled:=false;
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
  combobox3.Visible:=true;
  combobox4.Visible:=true;
  combobox5.Visible:=true;
  combobox9.Visible:=true;
  combobox10.Visible:=true;
  combobox11.Visible:=true;
  button7.Enabled:=true;
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
  d1.Text:=BrowseForFolder(d1.text,label1.Caption)+main_vars.cadena_dir;
end;

procedure TMConfig.SpeedButton2Click(Sender: TObject);
begin
  d2.Text:=BrowseForFolder(d2.text,label2.Caption)+main_vars.cadena_dir;
end;

procedure TMConfig.SpeedButton3Click(Sender: TObject);
begin
  d3.Text:=BrowseForFolder(d3.text,label3.Caption)+main_vars.cadena_dir;
end;

procedure TMConfig.SpeedButton4Click(Sender: TObject);
begin
  d4.Text:=BrowseForFolder(d4.text,label4.Caption)+main_vars.cadena_dir;
end;

procedure TMConfig.SpeedButton5Click(Sender: TObject);
begin
  d5.Text:=BrowseForFolder(d5.text,label5.Caption)+main_vars.cadena_dir;
end;

procedure TMConfig.Button2Click(Sender: TObject);
begin
  close;
end;

procedure TMConfig.Button3Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    if tecla_leida=$FFFE then begin
      bitbtn3.Caption:='N/D';
      arcade_input.ncoin[0]:=$ffff;
    end else begin
      button3.Caption:=nombre_tecla(tecla_leida);
      arcade_input.ncoin[0]:=tecla_leida;
    end;
  end;
end;

procedure TMConfig.Button4Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    if tecla_leida=$FFFE then begin
      bitbtn4.Caption:='N/D';
      arcade_input.ncoin[1]:=$ffff;
    end else begin
      button4.Caption:=nombre_tecla(tecla_leida);
      arcade_input.ncoin[1]:=tecla_leida;
    end;
  end;
end;

procedure TMConfig.Button5Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    if tecla_leida=$FFFE then begin
      bitbtn5.Caption:='N/D';
      arcade_input.nstart[0]:=$ffff;
    end else begin
      button5.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nstart[0]:=tecla_leida;
    end;
  end;
end;

procedure TMConfig.Button6Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$FFFF then begin
    if tecla_leida=$FFFE then begin
      bitbtn6.Caption:='N/D';
      arcade_input.nstart[1]:=$ffff;
    end else begin
      button6.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nstart[1]:=tecla_leida;
    end;
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

procedure TMConfig.BitBtn20Click(Sender: TObject);
begin
redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn20.Caption:='N/D';
      arcade_input.nbut5[1]:=$ffff;
    end else begin
      bitbtn20.Caption := nombre_tecla(tecla_leida);
      arcade_input.nbut5[1] := tecla_leida;
    end;
  END;
end;

PROCEDURE TMConfig.BitBtn2Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn2.Caption:='N/D';
      arcade_input.nright[0]:=$ffff;
    end else begin
      bitbtn2.Caption := nombre_tecla(tecla_leida);
      arcade_input.nright[0] := tecla_leida;
    end;
  END;
END;

PROCEDURE TMConfig.BitBtn3Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn3.Caption:='N/D';
      arcade_input.ndown[0]:=$ffff;
    end else begin
      bitbtn3.Caption := nombre_tecla(tecla_leida);
      arcade_input.ndown[0] := tecla_leida;
    end;
  END;
END;

PROCEDURE TMConfig.BitBtn4Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn4.Caption:='N/D';
      arcade_input.nup[0]:=$ffff;
    end else begin
      bitbtn4.Caption := nombre_tecla(tecla_leida);
      arcade_input.nup[0] := tecla_leida;
    end;
  END;
END;

PROCEDURE TMConfig.BitBtn5Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn5.Caption:='N/D';
      arcade_input.nup[1]:=$ffff;
    end else begin
      bitbtn5.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nup[1]:=tecla_leida;
    end;
  END;
END;

PROCEDURE TMConfig.BitBtn6Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn6.Caption:='N/D';
      arcade_input.nleft[1]:=$ffff;
    end else begin
      bitbtn6.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nleft[1]:=tecla_leida;
    end;
  END;
END;

PROCEDURE TMConfig.BitBtn7Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida <> $FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn7.Caption:='N/D';
      arcade_input.nright[1]:=$ffff;
    end else begin
      bitbtn7.Caption := nombre_tecla(tecla_leida);
      arcade_input.nright[1] := tecla_leida;
    end;
  END;
END;

PROCEDURE TMConfig.BitBtn8Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn8.Caption:='N/D';
      arcade_input.ndown[1]:=$ffff;
    end else begin
      bitbtn8.Caption:=nombre_tecla(tecla_leida);
      arcade_input.ndown[1]:=tecla_leida;
    end;
  END;
END;

PROCEDURE TMConfig.BitBtn9Click(Sender: TObject);
BEGIN
  redefine1.showmodal;
  IF tecla_leida<>$FFFF THEN BEGIN
    if tecla_leida=$FFFE then begin
      bitbtn9.Caption:='N/D';
      arcade_input.nbut0[0]:=$ffff;
    end else begin
      bitbtn9.Caption:=nombre_tecla(tecla_leida);
      arcade_input.nbut0[0]:=tecla_leida;
    end;
  END;
END;

procedure TMConfig.Button1Click(Sender: TObject);
var
  tmp_var:byte;
begin
  Directory.Nes:=D1.Text;
  Directory.GameBoy:=D2.Text;
  Directory.ColecoVision:=D3.Text;
  Directory.Arcade_roms:=D4.Text;
  Directory.Arcade_hi:=D5.Text;
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
  if radiobutton16.Checked then tmp_var:=1
    else if radiobutton17.Checked then tmp_var:=2
      else if radiobutton18.Checked then tmp_var:=3
        else if radiobutton19.Checked then tmp_var:=4
          else if radiobutton20.Checked then tmp_var:=5;
  if tmp_var<>main_screen.video_mode then begin
    main_screen.video_mode:=tmp_var;
    principal1.CambiarVideo(nil);
  end;
  main_vars.auto_exec:=checkbox2.Checked;
  main_vars.show_crc_error:=checkbox1.Checked;
  main_vars.center_screen:=checkbox3.Checked;
//Arreglar entradas arcade
  arcade_input.use_key[0]:=radiobutton1.Checked;
  arcade_input.use_key[1]:=radiobutton3.Checked;
  arcade_input.num_joystick[0]:=combobox1.ItemIndex;
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
  close;
end;

end.

