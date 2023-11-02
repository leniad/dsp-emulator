unit config_gb;

{$mode delphi}

interface

uses
  Classes, SysUtils, LResources, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { Tconfiggb }

  Tconfiggb = class(TForm)
    Button1: TButton;
    Button2: TButton;
    GroupBox7: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  configgb: Tconfiggb;

implementation
uses gb;

{ Tconfiggb }

procedure Tconfiggb.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
case key of
    13:button1Click(nil);
    27:button2click(nil);
end;
end;

procedure Tconfiggb.FormShow(Sender: TObject);
begin
if gb_0.is_gbc then begin
    groupbox7.Enabled:=false;
    radiobutton1.Enabled:=false;
    radiobutton2.Enabled:=false;
end else begin
    groupbox7.Enabled:=true;
    radiobutton1.Enabled:=true;
    radiobutton2.Enabled:=true;
end;
case gb_0.palette of
    0:radiobutton1.Checked:=true;
    1:radiobutton2.Checked:=true;
end;
end;

procedure Tconfiggb.Button1Click(Sender: TObject);
begin
if radiobutton1.Checked then gb_0.palette:=0
  else if radiobutton2.Checked then gb_0.palette:=1;
configgb.Close;
end;

procedure Tconfiggb.Button2Click(Sender: TObject);
begin
configgb.Close;
end;

initialization

end.

