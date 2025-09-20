unit cargar_spec;

{$mode delphi}

interface

uses
  LCLType,Classes,LResources,Forms,Controls,FileCtrl,StdCtrls,ExtCtrls,EditBtn;

type

  { Tload_spec }

  Tload_spec = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DirectoryEdit1: TDirectoryEdit;
    FileListBox1: TFileListBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DirectoryEdit1Change(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
    procedure FileListBox1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  load_spec: Tload_spec;

implementation
uses main_engine,spectrum_load;

{ Tload_spec }

procedure Tload_spec.Button1Click(Sender: TObject);
begin
spectrum_load_close;
load_spec.close;
end;

procedure Tload_spec.Button2Click(Sender: TObject);
begin
FileListBox1DblClick(self);
end;

procedure Tload_spec.DirectoryEdit1Change(Sender: TObject);
var
   cadena:string;
   f:integer;
begin
  cadena:=load_spec.DirectoryEdit1.Directory;
  if cadena='' then exit;
  load_spec.FileListBox1.Directory:='';
  if cadena[length(cadena)]=main_vars.cadena_dir then
  for f:=1 to (length(cadena)-1) do load_spec.FileListBox1.Directory:=load_spec.FileListBox1.Directory+cadena[f]
     else load_spec.FileListBox1.Directory:=cadena;
end;

procedure Tload_spec.FileListBox1Click(Sender: TObject);
begin
spectrum_load_click;
end;

procedure Tload_spec.FileListBox1DblClick(Sender: TObject);
begin
spectrum_load_exit;
end;

procedure Tload_spec.FileListBox1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
case key of
  13:Button2Click(sender);
  27:button1click(sender);
end;
end;

procedure Tload_spec.FormShow(Sender: TObject);
begin
spectrum_load_init;
filelistbox1.setfocus;
FileListBox1Click(nil);
end;

initialization
  {$I cargar_spec.lrs}

end.

