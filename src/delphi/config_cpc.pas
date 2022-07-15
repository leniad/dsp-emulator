unit config_cpc;
interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls,misc_functions,file_engine,main_engine,pal_engine, Vcl.ComCtrls;

type
  TConfigCPC = class(TForm)
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
    Edit2: TEdit;
    Button3: TButton;
    Button4: TButton;
    Label3: TLabel;
    Edit3: TEdit;
    Button5: TButton;
    Button6: TButton;
    Label4: TLabel;
    Edit4: TEdit;
    Button7: TButton;
    Button8: TButton;
    Label5: TLabel;
    Edit5: TEdit;
    Button9: TButton;
    Button10: TButton;
    Label6: TLabel;
    Edit6: TEdit;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    GroupBox7: TGroupBox;
    RadioButton12: TRadioButton;
    RadioButton13: TRadioButton;
    GroupBox3: TGroupBox;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    Edit7: TEdit;
    Button15: TButton;
    GroupBox4: TGroupBox;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    GroupBox5: TGroupBox;
    TrackBar1: TTrackBar;
    procedure Button15Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Button1Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);
    procedure RadioButton10Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  ConfigCPC: TConfigCPC;

implementation
uses amstrad_cpc,lenslock;
{$R *.dfm}

procedure TConfigCPC.Button13Click(Sender: TObject);
var
  f:byte;
  colores:tpaleta;
  temps:single;
begin
if radiobutton1.Checked then cpc_ga.cpc_model:=0
  else if radiobutton2.Checked then cpc_ga.cpc_model:=1
    else if radiobutton3.Checked then cpc_ga.cpc_model:=2
      else if radiobutton4.Checked then cpc_ga.cpc_model:=3
        else if radiobutton8.Checked then cpc_ga.cpc_model:=4;
cpc_load_roms;
lenslok.activo:=radiobutton12.Checked;
cpc_crt.color_monitor:=radiobutton9.Checked;
if radiobutton5.Checked then cpc_ga.ram_exp:=0
  else if radiobutton6.Checked then cpc_ga.ram_exp:=1
    else if radiobutton7.Checked then cpc_ga.ram_exp:=2;
if lenslok.activo then lenslock1.Show;
if cpc_crt.color_monitor then begin
  for f:=0 to 31 do begin
    colores[f].r:=cpc_paleta[f] shr 16;
    colores[f].g:=(cpc_paleta[f] shr 8) and $ff;
    colores[f].b:=cpc_paleta[f] and $ff;
  end;
end else begin
  cpc_crt.bright:=trackbar1.position;
  for f:=0 to 31 do begin
    colores[f].r:=0;
    temps:=0.01*0*green_classic[f]*255;
    if temps>255 then temps:=255;
    colores[f].b:=trunc(temps);
    temps:=green_classic[f]*255*(1+(cpc_crt.bright/4));
    if temps>255 then temps:=255;
    colores[f].g:=trunc(temps);
  end;
end;
set_pal(colores,32);
configcpc.Close;
end;

procedure TConfigCPC.Button14Click(Sender: TObject);
begin
configcpc.Close;
end;

procedure put_text_file(number:byte);
var
  file_name:string;
begin
if OpenRom(StAmstradROM,file_name) then begin
  case number of
    0:configcpc.Edit7.Text:=file_name;
    1:configcpc.Edit1.Text:=file_name;
    2:configcpc.Edit2.Text:=file_name;
    3:configcpc.Edit3.Text:=file_name;
    4:configcpc.Edit4.Text:=file_name;
    5:configcpc.Edit5.Text:=file_name;
    6:configcpc.Edit6.Text:=file_name;
  end;
  cpc_rom[number].name:=file_name;
end;
end;

procedure clear_text_file(number:byte);
begin
case number of
  0:configcpc.Edit7.Text:='';
  1:configcpc.Edit1.Text:='';
  2:configcpc.Edit2.Text:='';
  3:configcpc.Edit3.Text:='';
  4:configcpc.Edit4.Text:='';
  5:configcpc.Edit5.Text:='';
  6:configcpc.Edit6.Text:='';
end;
cpc_rom[number].name:='';
end;

procedure TConfigCPC.Button15Click(Sender: TObject);
begin
put_text_file(0);
end;

procedure TConfigCPC.Button1Click(Sender: TObject);
begin
put_text_file(1);
end;

procedure TConfigCPC.Button3Click(Sender: TObject);
begin
put_text_file(2);
end;

procedure TConfigCPC.Button4Click(Sender: TObject);
begin
clear_text_file(2);
end;

procedure TConfigCPC.Button5Click(Sender: TObject);
begin
put_text_file(3);
end;

procedure TConfigCPC.Button6Click(Sender: TObject);
begin
clear_text_file(3);
end;

procedure TConfigCPC.Button7Click(Sender: TObject);
begin
put_text_file(4);
end;

procedure TConfigCPC.Button8Click(Sender: TObject);
begin
clear_text_file(4);
end;

procedure TConfigCPC.Button9Click(Sender: TObject);
begin
put_text_file(5);
end;

procedure TConfigCPC.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
case key of
    13:button13Click(nil);
    27:button14click(nil);
  end;
end;

procedure TConfigCPC.FormShow(Sender: TObject);
begin
case main_vars.tipo_maquina of
  8:begin //CPC 664
      radiobutton2.Enabled:=false;
      radiobutton3.Enabled:=false;
      radiobutton4.Enabled:=false;
      case cpc_ga.cpc_model of
        4:radiobutton8.Checked:=true;
          else radiobutton1.Checked:=true;
      end;
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
        4:radiobutton8.Checked:=true;
      end;
    end;
end;
Edit7.Text:=cpc_rom[0].name;
Edit1.Text:=cpc_rom[1].name;
Edit2.Text:=cpc_rom[2].name;
Edit3.Text:=cpc_rom[3].name;
Edit4.Text:=cpc_rom[4].name;
Edit5.Text:=cpc_rom[5].name;
Edit6.Text:=cpc_rom[6].name;
//Lenslock
if lenslok.activo then radiobutton12.Checked:=true
  else radiobutton13.Checked:=true;
case cpc_ga.ram_exp of
  0:radiobutton5.Checked:=true;
  1:radiobutton6.Checked:=true;
  2:radiobutton7.Checked:=true;
end;
trackbar1.Position:=cpc_crt.bright;
if cpc_crt.color_monitor then begin
  radiobutton9.Checked:=true;
  groupbox5.Enabled:=false;
  trackbar1.Enabled:=false;
end else begin
  radiobutton10.Checked:=true;
  groupbox5.Enabled:=true;
  trackbar1.Enabled:=true;
end;
end;

procedure TConfigCPC.RadioButton10Click(Sender: TObject);
begin
  trackbar1.Enabled:=true;
  groupbox5.Enabled:=true;
end;

procedure TConfigCPC.RadioButton9Click(Sender: TObject);
begin
  trackbar1.Enabled:=false;
  groupbox5.Enabled:=false;
end;

procedure TConfigCPC.Button10Click(Sender: TObject);
begin
clear_text_file(5);
end;

procedure TConfigCPC.Button11Click(Sender: TObject);
begin
put_text_file(6);
end;

procedure TConfigCPC.Button12Click(Sender: TObject);
begin
clear_text_file(6);
end;

procedure TConfigCPC.Button2Click(Sender: TObject);
begin
clear_text_file(1);
end;

end.
