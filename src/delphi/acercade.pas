unit acercade;

interface

uses Forms,StdCtrls,ExtCtrls,lenguaje,main_engine, Vcl.Imaging.GIFImg,
  Vcl.Graphics, Vcl.Controls, System.Classes;

type
  TAboutBox = class(TForm)
    Panel1: TPanel;
    ProgramIcon: TImage;
    ProductName: TLabel;
    Copyright: TLabel;
    OKButton: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Image1: TImage;
    procedure OKButtonClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  AboutBox: TAboutBox;

implementation
uses principal;
{$R *.dfm}

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
aboutbox.close;
end;

procedure TAboutBox.FormShow(Sender: TObject);
var
  f:integer;
begin
f:=(principal1.left+(principal1.width div 2))-(AboutBox.Width div 2);
if f<0 then AboutBox.Left:=0
  else AboutBox.Left:=f;
f:=(principal1.top+(principal1.Height div 2))-(AboutBox.Height div 2);
if f<0 then AboutBox.Top:=0
  else AboutBox.Top:=f;
label1.Caption:='v'+DSP_VERSION;
aboutbox.caption:=leng.archivo[3];
(Image1.Picture.Graphic as TGIFImage).Animate:= True;
end;

end.

