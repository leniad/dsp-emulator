unit cargar_spec;

{$mode delphi}

interface

uses
  LCLType,Classes,LResources,Forms,Controls,FileCtrl,StdCtrls,ExtCtrls,EditBtn;

type

  { TForm2 }

  TForm2 = class(TForm)
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
  Form2: TForm2;

implementation
uses main_engine,spectrum_load;

{ TForm2 }

procedure TForm2.Button1Click(Sender: TObject);
begin
spectrum_load_close;
form2.close;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
FileListBox1DblClick(self);
end;

procedure TForm2.DirectoryEdit1Change(Sender: TObject);
var
   cadena:string;
   f:integer;
begin
  cadena:=form2.DirectoryEdit1.Directory;
  if cadena='' then exit;
  form2.FileListBox1.Directory:='';
  if cadena[length(cadena)]=main_vars.cadena_dir then
  for f:=1 to (length(cadena)-1) do form2.FileListBox1.Directory:=form2.FileListBox1.Directory+cadena[f]
     else form2.FileListBox1.Directory:=cadena;
end;

procedure TForm2.FileListBox1Click(Sender: TObject);
begin
spectrum_load_click;
end;

procedure TForm2.FileListBox1DblClick(Sender: TObject);
begin
spectrum_load_exit;
end;

procedure TForm2.FileListBox1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
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

initialization
  {$I cargar_spec.lrs}

end.

