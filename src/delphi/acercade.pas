unit acercade;

interface

uses Classes,Graphics,Forms,Controls,StdCtrls,Buttons,ExtCtrls,lenguaje,
     main_engine;

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
begin
label1.Caption:='v'+dsp_version;
aboutbox.caption:=leng[main_vars.idioma].archivo[3];
end;

end.

