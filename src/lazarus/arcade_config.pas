unit arcade_config;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls;

const
  MAX_DIP=3-1;
  MAX_COMP=32;

type

  { Tconfig_arcade }

  Tconfig_arcade = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  config_arcade: Tconfig_arcade;

implementation
uses controls_engine,main_engine;

var
  ComboBox_dip:array[0..MAX_DIP,1..MAX_COMP] of TComboBox;
  Label_dip:array[0..MAX_DIP,1..MAX_COMP] of TLabel;

{ Tconfig_arcade }

procedure Tconfig_arcade.Button1Click(Sender: TObject);
var
  dip_tmp:pdef_dip;
  dip_tmp2:pdef_dip2;
  dip_pos:byte;
  valor:word;
function leer_valor_dip2(pos:byte):word;
begin
case dip_tmp2.number of
  2:leer_valor_dip2:=dip_tmp2.val2[combobox_dip[pos,dip_pos].ItemIndex];
  4:leer_valor_dip2:=dip_tmp2.val4[combobox_dip[pos,dip_pos].ItemIndex];
  8:leer_valor_dip2:=dip_tmp2.val8[combobox_dip[pos,dip_pos].ItemIndex];
  16:leer_valor_dip2:=dip_tmp2.val16[combobox_dip[pos,dip_pos].ItemIndex];
  32:leer_valor_dip2:=dip_tmp2.val32[combobox_dip[pos,dip_pos].ItemIndex];
end;
end;
begin
  if marcade.dswa_val2<>nil then begin
    dip_tmp2:=marcade.dswa_val2;
    dip_pos:=1;
    while dip_tmp2.name<>'' do begin
      valor:=leer_valor_dip2(0);
      marcade.dswa:=(marcade.dswa and not(dip_tmp2.mask)) or valor;
      dip_pos:=dip_pos+1;
      inc(dip_tmp2);
    end;
    if marcade.dswb_val2<>nil then begin
      dip_tmp2:=marcade.dswb_val2;
      dip_pos:=1;
      while dip_tmp2.name<>'' do begin
        valor:=leer_valor_dip2(1);
        marcade.dswb:=(marcade.dswb and not(dip_tmp2.mask)) or valor;
        dip_pos:=dip_pos+1;
        inc(dip_tmp2);
      end;
    end;
    if marcade.dswc_val2<>nil then begin
      dip_tmp2:=marcade.dswc_val2;
      dip_pos:=1;
      while dip_tmp2.name<>'' do begin
        valor:=leer_valor_dip2(2);
        marcade.dswc:=(marcade.dswc and not(dip_tmp2.mask)) or valor;
        dip_pos:=dip_pos+1;
        inc(dip_tmp2);
      end;
    end;
  end else begin
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
  end;
config_arcade.close;
end;

procedure Tconfig_arcade.Button2Click(Sender: TObject);
begin
config_arcade.close;
end;

procedure Tconfig_arcade.FormClose(Sender: TObject; var CloseAction: TCloseAction);
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

procedure Tconfig_arcade.FormKeyUp(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
  case key of
      13:button1Click(nil);
      27:button2click(nil);
    end;
end;

procedure Tconfig_arcade.FormShow(Sender: TObject);
procedure montar_paneles(pos,dip_pos:byte);
begin
  Combobox_dip[pos,dip_pos]:=TComboBox.create(config_arcade);
  case pos of
    0:Combobox_dip[pos,dip_pos].Parent:=config_arcade.GroupBox1;
    1:Combobox_dip[pos,dip_pos].Parent:=config_arcade.GroupBox2;
    2:Combobox_dip[pos,dip_pos].Parent:=config_arcade.GroupBox3;
  end;
  Combobox_dip[pos,dip_pos].Left:=100;
  Combobox_dip[pos,dip_pos].Top:=25*dip_pos;
  Combobox_dip[pos,dip_pos].TabStop:=false;
  Combobox_dip[pos,dip_pos].Width:=150;
  Label_dip[pos,dip_pos]:=TLabel.Create(config_arcade);
  case pos of
    0:Label_dip[pos,dip_pos].Parent:=config_arcade.GroupBox1;
    1:Label_dip[pos,dip_pos].Parent:=config_arcade.GroupBox2;
    2:Label_dip[pos,dip_pos].Parent:=config_arcade.GroupBox3;
  end;
  Label_dip[pos,dip_pos].Left:=5;
  Label_dip[pos,dip_pos].Top:=25*dip_pos;
  Label_dip[pos,dip_pos].AutoSize:=true;
end;
procedure put_dip(pos:byte;dip:pdef_dip;valor:word);
var
  dip_pos,h:byte;
  dip_tmp:pdef_dip;
begin
dip_tmp:=dip;
dip_pos:=1;
while dip_tmp.name<>'' do begin
  montar_paneles(pos,dip_pos);
  if (dip_tmp.number-1)>MAX_DIP_VALUES then MessageDlg('Warning: More Values in DIP_old than available!',mtError,[mbOk],0);
  for h:=0 to dip_tmp.number-1 do begin
    Combobox_dip[pos,dip_pos].Items.Add(dip_tmp.dip[h].dip_name);
    if dip_tmp.dip[h].dip_val=(valor and dip_tmp.mask) then combobox_dip[pos,dip_pos].ItemIndex:=h;
  end;
  Label_dip[pos,dip_pos].Caption:=dip_tmp.name;
  dip_pos:=dip_pos+1;
  if dip_pos>MAX_COMP then MessageDlg('Warning: More Values in DIP_old than available!',mtError,[mbOk],0);
  inc(dip_tmp);
end;
end;
procedure put_dip2(pos:byte;dip:pdef_dip2;valor:word);
var
  dip_pos,h:byte;
  dip_tmp2:pdef_dip2;
begin
dip_pos:=1;
dip_tmp2:=dip;
while dip_tmp2.name<>'' do begin
  montar_paneles(pos,dip_pos);
  for h:=0 to dip_tmp2.number-1 do begin
    case dip_tmp2.number of
        2:begin
            Combobox_dip[pos,dip_pos].Items.Add(dip_tmp2.name2[h]);
            if dip_tmp2.val2[h]=(valor and dip_tmp2.mask) then combobox_dip[pos,dip_pos].ItemIndex:=h;
          end;
        4:begin
            Combobox_dip[pos,dip_pos].Items.Add(dip_tmp2.name4[h]);
            if dip_tmp2.val4[h]=(valor and dip_tmp2.mask) then combobox_dip[pos,dip_pos].ItemIndex:=h;
          end;
        8:begin
            Combobox_dip[pos,dip_pos].Items.Add(dip_tmp2.name8[h]);
            if dip_tmp2.val8[h]=(valor and dip_tmp2.mask) then combobox_dip[pos,dip_pos].ItemIndex:=h;
          end;
        16:begin
            Combobox_dip[pos,dip_pos].Items.Add(dip_tmp2.name16[h]);
            if dip_tmp2.val16[h]=(valor and dip_tmp2.mask) then combobox_dip[pos,dip_pos].ItemIndex:=h;
           end;
        32:begin
            Combobox_dip[pos,dip_pos].Items.Add(dip_tmp2.name32[h]);
            if dip_tmp2.val32[h]=(valor and dip_tmp2.mask) then combobox_dip[pos,dip_pos].ItemIndex:=h;
          end;

    end;
  end;
  Label_dip[pos,dip_pos].Caption:=dip_tmp2.name;
  dip_pos:=dip_pos+1;
  if dip_pos>MAX_COMP then MessageDlg('Warning: More Values in DIP than available!',mtError,[mbOk],0);
  inc(dip_tmp2);
end;
end;
begin
  config_arcade.GroupBox2.Visible:=false;
  config_arcade.GroupBox3.Visible:=false;
  config_arcade.Width:=279;
  config_arcade.Button1.Left:=9;
  config_arcade.Button2.Left:=141;
  if marcade.dswa_val2<>nil then put_dip2(0,marcade.dswa_val2,marcade.dswa)
    else put_dip(0,marcade.dswa_val,marcade.dswa);
  if ((marcade.dswb_val<>nil) or (marcade.dswb_val2<>nil)) then begin
    config_arcade.Width:=550;
    config_arcade.Button1.Left:=64;
    config_arcade.Button2.Left:=340;
    config_arcade.GroupBox2.Visible:=true;
    if marcade.dswb_val2<>nil then put_dip2(1,marcade.dswb_val2,marcade.dswb)
      else put_dip(1,marcade.dswb_val,marcade.dswb);
  end;
  if ((marcade.dswc_val<>nil) or (marcade.dswc_val2<>nil)) then begin
    config_arcade.Width:=823;
    config_arcade.Button1.Left:=208;
    config_arcade.Button2.Left:=496;
    config_arcade.GroupBox3.Visible:=true;
    if marcade.dswc_val2<>nil then put_dip2(2,marcade.dswc_val2,marcade.dswc)
      else put_dip(2,marcade.dswc_val,marcade.dswc);
  end;
end;

initialization
  {$I arcade_config.lrs}

end.

