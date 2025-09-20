unit arcade_config;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

const
  MAX_DIP=3-1;
  MAX_COMP=16;

type
  Tconfig_arcade = class(TForm)
    GroupBox1: TGroupBox;
    Button1: TButton;
    Button2: TButton;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    procedure Button2Click(Sender:TObject);
    procedure Button1Click(Sender:TObject);
    procedure FormClose(Sender:TObject;var Action:TCloseAction);
    procedure FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  procedure activate_arcade_config;

var
  config_arcade: Tconfig_arcade;
  ComboBox_dip:array[0..MAX_DIP,1..MAX_COMP] of TComboBox;
  Label_dip:array[0..MAX_DIP,1..MAX_COMP] of TLabel;

implementation
uses controls_engine,main_engine;

{$R *.dfm}

procedure activate_arcade_config;
var
  dip_tmp:pdef_dip;
  dip_pos,h:byte;
begin
  //Si no hay Dip Switch me salgo ya
  if marcade.dswa_val=nil then exit;
  config_arcade.GroupBox2.Visible:=false;
  config_arcade.GroupBox3.Visible:=false;
  config_arcade.Width:=279;
  config_arcade.Button1.Left:=9;
  config_arcade.Button2.Left:=141;
  //Poner los valores de los dip
  dip_tmp:=marcade.dswa_val;
  dip_pos:=1;
  while dip_tmp.name<>'' do begin
    Combobox_dip[0,dip_pos]:=TComboBox.create(config_arcade);
    Combobox_dip[0,dip_pos].Parent:=config_arcade.GroupBox1;
    Combobox_dip[0,dip_pos].Left:=100;
    Combobox_dip[0,dip_pos].Top:=25*dip_pos;
    Combobox_dip[0,dip_pos].TabStop:=false;
    Combobox_dip[0,dip_pos].Width:=150;
    Label_dip[0,dip_pos]:=TLabel.Create(config_arcade);
    Label_dip[0,dip_pos].Parent:=config_arcade.GroupBox1;
    Label_dip[0,dip_pos].Left:=5;
    Label_dip[0,dip_pos].Top:=25*dip_pos;
    Label_dip[0,dip_pos].AutoSize:=true;
    if (dip_tmp.number-1)>MAX_DIP_VALUES then MessageDlg('Warning: More Values in DIP A than available!',mtError,[mbOk],0);
    for h:=0 to dip_tmp.number-1 do begin
      Combobox_dip[0,dip_pos].Items.Add(dip_tmp.dip[h].dip_name);
      if dip_tmp.dip[h].dip_val=(marcade.dswa and dip_tmp.mask) then combobox_dip[0,dip_pos].ItemIndex:=h;
    end;
    Label_dip[0,dip_pos].Caption:=dip_tmp.name;
    dip_pos:=dip_pos+1;
    if dip_pos>MAX_COMP then MessageDlg('Warning: More Values in DIP A than available!',mtError,[mbOk],0);
    inc(dip_tmp);
  end;
if marcade.dswb_val<>nil then begin
  dip_tmp:=marcade.dswb_val;
  dip_pos:=1;
  config_arcade.Width:=550;
  config_arcade.Button1.Left:=64;
  config_arcade.Button2.Left:=340;
  config_arcade.GroupBox2.Visible:=true;
  while dip_tmp.name<>'' do begin
    Combobox_dip[1,dip_pos]:=TComboBox.create(config_arcade);
    Combobox_dip[1,dip_pos].Parent:=config_arcade.GroupBox2;
    Combobox_dip[1,dip_pos].Left:=100;
    Combobox_dip[1,dip_pos].Top:=25*dip_pos;
    Combobox_dip[1,dip_pos].TabStop:=false;
    Combobox_dip[1,dip_pos].Width:=150;
    Label_dip[1,dip_pos]:=TLabel.Create(config_arcade);
    Label_dip[1,dip_pos].Parent:=config_arcade.GroupBox2;
    Label_dip[1,dip_pos].Left:=5;
    Label_dip[1,dip_pos].Top:=25*dip_pos;
    Label_dip[1,dip_pos].AutoSize:=true;
    if (dip_tmp.number-1)>MAX_DIP_VALUES then MessageDlg('Warning: More Values in DIP B than available!',mtError,[mbOk],0);
    for h:=0 to dip_tmp.number-1 do begin
      Combobox_dip[1,dip_pos].Items.Add(dip_tmp.dip[h].dip_name);
      if dip_tmp.dip[h].dip_val=(marcade.dswb and dip_tmp.mask) then combobox_dip[1,dip_pos].ItemIndex:=h;
    end;
    Label_dip[1,dip_pos].Caption:=dip_tmp.name;
    dip_pos:=dip_pos+1;
    if dip_pos>MAX_COMP then MessageDlg('Warning: More Values in DIP B than available!',mtError,[mbOk],0);
    inc(dip_tmp);
  end;
end;
if marcade.dswc_val<>nil then begin
  dip_tmp:=marcade.dswc_val;
  dip_pos:=1;
  config_arcade.Width:=823;
  config_arcade.Button1.Left:=208;
  config_arcade.Button2.Left:=496;
  config_arcade.GroupBox3.Visible:=true;
  while dip_tmp.name<>'' do begin
    Combobox_dip[2,dip_pos]:=TComboBox.create(config_arcade);
    Combobox_dip[2,dip_pos].Parent:=config_arcade.GroupBox3;
    Combobox_dip[2,dip_pos].Left:=100;
    Combobox_dip[2,dip_pos].Top:=25*dip_pos;
    Combobox_dip[2,dip_pos].TabStop:=false;
    Combobox_dip[2,dip_pos].Width:=150;
    Label_dip[2,dip_pos]:=TLabel.Create(config_arcade);
    Label_dip[2,dip_pos].Parent:=config_arcade.GroupBox3;
    Label_dip[2,dip_pos].Left:=5;
    Label_dip[2,dip_pos].Top:=25*dip_pos;
    Label_dip[2,dip_pos].AutoSize:=true;
    if (dip_tmp.number-1)>MAX_DIP_VALUES then MessageDlg('Warning: More Values in DIP C than available!',mtError,[mbOk],0);
    for h:=0 to dip_tmp.number-1 do begin
      Combobox_dip[2,dip_pos].Items.Add(dip_tmp.dip[h].dip_name);
      if dip_tmp.dip[h].dip_val=(marcade.dswc and dip_tmp.mask) then combobox_dip[2,dip_pos].ItemIndex:=h;
    end;
    Label_dip[2,dip_pos].Caption:=dip_tmp.name;
    dip_pos:=dip_pos+1;
    if dip_pos>MAX_COMP then MessageDlg('Warning: More Values in DIP C than available!',mtError,[mbOk],0);
    inc(dip_tmp);
  end;
end;
  //Mostrar ventana
  config_arcade.Show;
  config_arcade.SetFocus;
  while config_arcade.Showing do application.ProcessMessages;
end;

procedure Tconfig_arcade.Button1Click(Sender: TObject);
var
  dip_tmp:pdef_dip;
  dip_pos:byte;
  valor:word;
begin
//Poner los valores de los dip A
  dip_tmp:=marcade.dswa_val;
  dip_pos:=1;
  while dip_tmp.name<>'' do begin
    valor:=dip_tmp.dip[combobox_dip[0,dip_pos].ItemIndex].dip_val;
    marcade.dswa:=(marcade.dswa and not(dip_tmp.mask)) or valor;
    dip_pos:=dip_pos+1;
    inc(dip_tmp);
  end;
  if marcade.dswb_val<>nil then begin
    dip_tmp:=marcade.dswb_val;
    dip_pos:=1;
    while dip_tmp.name<>'' do begin
      valor:=dip_tmp.dip[combobox_dip[1,dip_pos].ItemIndex].dip_val;
      marcade.dswb:=(marcade.dswb and not(dip_tmp.mask)) or valor;
      dip_pos:=dip_pos+1;
      inc(dip_tmp);
    end;
  end;
  if marcade.dswc_val<>nil then begin
    dip_tmp:=marcade.dswc_val;
    dip_pos:=1;
    while dip_tmp.name<>'' do begin
      valor:=dip_tmp.dip[combobox_dip[2,dip_pos].ItemIndex].dip_val;
      marcade.dswc:=(marcade.dswc and not(dip_tmp.mask)) or valor;
      dip_pos:=dip_pos+1;
      inc(dip_tmp);
    end;
  end;
  close;
end;

procedure Tconfig_arcade.Button2Click(Sender: TObject);
begin
  config_arcade.close;
end;

procedure Tconfig_arcade.FormClose(Sender: TObject; var Action: TCloseAction);
var
  f,h:byte;
begin
  for f:=0 to MAX_DIP do begin
    for h:=1 to MAX_COMP do begin
      if Combobox_dip[f,h]<>nil then begin
        Combobox_dip[f,h].Destroy;
        Combobox_dip[f,h]:=nil;
        Label_dip[f,h].Destroy;
        Label_dip[f,h]:=nil;
      end;
    end;
  end;
end;

procedure Tconfig_arcade.FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
begin
case key of
    13:button1Click(nil);
    27:button2click(nil);
  end;
end;

end.
