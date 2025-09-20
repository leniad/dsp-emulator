unit acercade;

{$mode delphi}

interface

uses
  Classes,SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  ExtCtrls, StdCtrls,lenguaje,main_engine;

type

  { TAboutbox }

  TAboutbox = class(TForm)
    Copyright: TLabel;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    OKButton: TButton;
    Panel1: TPanel;
    ProductName: TLabel;
    ProgramIcon: TImage;
    procedure FormShow(Sender: TObject);
    procedure OKButtonClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Aboutbox: TAboutbox;

implementation
uses principal;

{ TAboutbox }

procedure TAboutbox.FormShow(Sender: TObject);
var
  f:integer;
begin
f:=(principal1.left+(principal1.width div 2))-(AboutBox.Width div 2);
if f<0 then AboutBox.Left:=0
  else AboutBox.Left:=f;
f:=(principal1.top+(principal1.Height div 2))-(AboutBox.Height div 2);
if f<0 then AboutBox.Top:=0
  else AboutBox.Top:=f;
label1.Caption:='v'+dsp_version;
aboutbox.caption:=leng.archivo[1];
end;

procedure TAboutbox.OKButtonClick(Sender: TObject);
begin
  aboutbox.close;
end;

initialization
  {$I acercade.lrs}

end.

