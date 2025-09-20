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
  ComboBox_dip:array[0..MAX_DIP,1..MAX_COMP] of TComboBox;
  Label_dip:array[0..MAX_DIP,1..MAX_COMP] of TLabel;

implementation
uses controls_engine,main_engine,principal,arcadeconfig_misc;

{ Tconfig_arcade }

procedure Tconfig_arcade.Button1Click(Sender: TObject);
begin
  configarcade_boton1;
  close;
end;

procedure Tconfig_arcade.Button2Click(Sender: TObject);
begin
config_arcade.close;
end;

procedure Tconfig_arcade.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  arcadeconfig_close;
end;

procedure Tconfig_arcade.FormKeyUp(Sender: TObject; var Key: Word;Shift: TShiftState);
begin
  case key of
      13:button1Click(nil);
      27:button2click(nil);
    end;
end;

procedure Tconfig_arcade.FormShow(Sender: TObject);
begin
  arcadeconfig_formshow;
end;

initialization
  {$I arcade_config.lrs}

end.

