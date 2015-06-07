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

{ TAboutbox }

procedure TAboutbox.FormShow(Sender: TObject);
begin
  label1.Caption:='v'+dsp_version;
  aboutbox.caption:=leng[main_vars.idioma].archivo[3];
end;

procedure TAboutbox.OKButtonClick(Sender: TObject);
begin
  aboutbox.close;
end;

initialization
  {$I acercade.lrs}

end.

