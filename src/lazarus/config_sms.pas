unit config_sms;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons,main_engine,sound_engine,sn_76496,rom_engine;

type

  { TSMSConfig }

  TSMSConfig = class(TForm)
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  SMSConfig: TSMSConfig;

implementation
uses sega_vdp,sms,nz80;

{ TSMSConfig }

procedure TSMSConfig.FormShow(Sender: TObject);
begin
case sms_0.model of
  0:begin //pal
      radiobutton2.Checked:=true;
      radiobutton1.Checked:=false;
      radiobutton3.Checked:=false;
  end;
  1:begin //ntsc JP
      radiobutton2.Checked:=false;
      radiobutton1.Checked:=true;
      radiobutton3.Checked:=false;
  end;
  2:begin //ntsc US
      radiobutton2.Checked:=false;
      radiobutton1.Checked:=false;
      radiobutton3.Checked:=true;
  end;
end;
end;

procedure TSMSConfig.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
case key of
  13:SpeedButton1Click(nil);
  27:Speedbutton2click(nil);
end;
end;

procedure TSMSConfig.SpeedButton1Click(Sender: TObject);
var
  system:byte;
begin
if radiobutton2.Checked then system:=0; //PAL
if radiobutton1.Checked then system:=1; //NTSC JP
if radiobutton3.Checked then system:=2; //NTSC US
if sms_0.model<>system then begin
    sms_0.model:=system;
    change_sms_model(system);
end;
close;
end;

procedure TSMSConfig.SpeedButton2Click(Sender: TObject);
begin
  close;
end;

initialization
  {$I config_sms.lrs}

end.

