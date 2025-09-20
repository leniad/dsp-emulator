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
{$R *.dfm}

procedure TAboutBox.OKButtonClick(Sender: TObject);
begin
aboutbox.close;
end;

procedure TAboutBox.FormShow(Sender: TObject);
begin
label1.Caption:='v'+DSP_VERSION;
aboutbox.caption:=leng[main_vars.idioma].archivo[3];
(Image1.Picture.Graphic as TGIFImage).Animate:= True;
end;

end.

