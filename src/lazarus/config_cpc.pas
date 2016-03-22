unit config_cpc;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls,misc_functions,file_engine,main_engine;

type

  { Tconfigcpc }

  Tconfigcpc = class(TForm)
    Button1: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Edit1: TEdit;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  configcpc: Tconfigcpc;

implementation
uses amstrad_cpc;

{ Tconfigcpc }

procedure put_text_file(number:byte);
var
    file_name:string;
begin
 if OpenRom(StAmstradROM,file_name) then begin
    case number of
      1:configcpc.Edit1.Text:=file_name;
      2:configcpc.Edit2.Text:=file_name;
      3:configcpc.Edit3.Text:=file_name;
      4:configcpc.Edit4.Text:=file_name;
      5:configcpc.Edit5.Text:=file_name;
      6:configcpc.Edit6.Text:=file_name;
    end;
    cpc_rom_slot[number]:=file_name;
  end;
end;

procedure clear_text_file(number:byte);
begin
  case number of
    1:configcpc.Edit1.Text:='';
    2:configcpc.Edit1.Text:='';
    3:configcpc.Edit1.Text:='';
    4:configcpc.Edit1.Text:='';
    5:configcpc.Edit1.Text:='';
    6:configcpc.Edit1.Text:='';
  end;
  cpc_rom_slot[number]:='';
end;

procedure Tconfigcpc.FormShow(Sender: TObject);
begin
 case main_vars.tipo_maquina of
   8:begin //CPC 664
       radiobutton1.Checked:=true;
       radiobutton2.Enabled:=false;
       radiobutton3.Enabled:=false;
       radiobutton4.Enabled:=false;
     end;
   7,9:begin  //CPC 464 y 6128
       radiobutton2.Enabled:=true;
       radiobutton3.Enabled:=true;
       radiobutton4.Enabled:=true;
       case cpc_ga.cpc_model of
         0:radiobutton1.Checked:=true;
         1:radiobutton2.Checked:=true;
         2:radiobutton3.Checked:=true;
         3:radiobutton4.Checked:=true;
       end;
     end;
 end;
 Edit1.Text:=cpc_rom_slot[1];
 Edit2.Text:=cpc_rom_slot[2];
 Edit3.Text:=cpc_rom_slot[3];
 Edit4.Text:=cpc_rom_slot[4];
 Edit5.Text:=cpc_rom_slot[5];
 Edit6.Text:=cpc_rom_slot[6];
end;

procedure Tconfigcpc.Button1Click(Sender: TObject);
begin
  put_text_file(1);
end;

procedure Tconfigcpc.Button2Click(Sender: TObject);
begin
  clear_text_file(1);
end;

procedure Tconfigcpc.Button11Click(Sender: TObject);
begin
  put_text_file(6);
end;

procedure Tconfigcpc.Button12Click(Sender: TObject);
begin
  clear_text_file(6);
end;

procedure Tconfigcpc.Button13Click(Sender: TObject);
var
  f:byte;
  long:integer;
begin
if radiobutton1.Checked then cpc_ga.cpc_model:=0
  else if radiobutton2.Checked then cpc_ga.cpc_model:=1
    else if radiobutton3.Checked then cpc_ga.cpc_model:=2
      else if radiobutton4.Checked then cpc_ga.cpc_model:=3;
cpc_load_roms;
configcpc.Close;
end;

procedure Tconfigcpc.Button14Click(Sender: TObject);
begin
  configcpc.Close;
end;

procedure Tconfigcpc.Button10Click(Sender: TObject);
begin
  clear_text_file(5);
end;

procedure Tconfigcpc.Button3Click(Sender: TObject);
begin
  put_text_file(2);
end;

procedure Tconfigcpc.Button4Click(Sender: TObject);
begin
  clear_text_file(2);
end;

procedure Tconfigcpc.Button5Click(Sender: TObject);
begin
  put_text_file(3);
end;

procedure Tconfigcpc.Button6Click(Sender: TObject);
begin
  clear_text_file(3);
end;

procedure Tconfigcpc.Button7Click(Sender: TObject);
begin
  put_text_file(4);
end;

procedure Tconfigcpc.Button8Click(Sender: TObject);
begin
  clear_text_file(4);
end;

procedure Tconfigcpc.Button9Click(Sender: TObject);
begin
  put_text_file(5);
end;

initialization
  {$I config_cpc.lrs}

end.

