unit cargar_spec;

interface

uses ExtCtrls, Controls, StdCtrls, FileCtrl, Classes, Forms, Vcl.ComCtrls;

type
  Tload_spec = class(TForm)
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
    procedure FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
    procedure FileListBox1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  load_spec: Tload_spec;

{$R *.dfm}

implementation
uses spectrum_load;

procedure Tload_spec.Button1Click(Sender: TObject);
begin
spectrum_load_close;
load_spec.close;
end;

procedure Tload_spec.Button2Click(Sender: TObject);
begin
FileListBox1DblClick(self);
end;

procedure Tload_spec.FileListBox1Click(Sender: TObject);
begin
spectrum_load_click;
end;

procedure Tload_spec.FileListBox1DblClick(Sender: TObject);
begin
spectrum_load_exit;
end;

procedure Tload_spec.FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
begin
case key of
  13:if filelistbox1.FileName<>'' then Button2Click(sender);
  27:button1click(sender);
end;
end;

procedure Tload_spec.FormShow(Sender: TObject);
begin
spectrum_load_init;
filelistbox1.setfocus;
FileListBox1Click(nil);
end;

end.
