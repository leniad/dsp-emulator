unit cargar_spec;

interface

uses ExtCtrls, Controls, StdCtrls, FileCtrl, Classes, Forms, Vcl.ComCtrls;

type
  TForm2 = class(TForm)
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    FileListBox1: TFileListBox;
    Button1: TButton;
    Button2: TButton;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    GroupBox2: TGroupBox;
    Image1: TImage;
    TreeView1: TTreeView;
    procedure FormShow(Sender:TObject);
    procedure Button1Click(Sender:TObject);
    procedure Button2Click(Sender:TObject);
    procedure FileListBox1DblClick(Sender:TObject);
    procedure FileListBox1KeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
    procedure FileListBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

{$R *.dfm}

implementation
uses spectrum_load;

procedure TForm2.Button1Click(Sender: TObject);
begin
spectrum_load_close;
form2.close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
FileListBox1DblClick(self);
end;

procedure TForm2.FileListBox1Click(Sender: TObject);
begin
spectrum_load_click;
end;

procedure TForm2.FileListBox1DblClick(Sender: TObject);
begin
spectrum_load_exit;
end;

procedure TForm2.FileListBox1KeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
begin
case key of
  13:Button2Click(sender);
  27:button1click(sender);
end;
end;

procedure TForm2.FormShow(Sender: TObject);
begin
spectrum_load_init;
filelistbox1.setfocus;
FileListBox1Click(nil);
end;

end.
