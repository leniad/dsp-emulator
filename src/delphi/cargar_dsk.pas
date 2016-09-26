unit cargar_dsk;

interface

uses
  Windows, SysUtils, Variants, Classes,Forms,Vcl.Controls,Dialogs, Grids,
  StdCtrls, FileCtrl,upd765,main_engine,lenguaje,misc_functions,
  file_engine,disk_file_format,ipf_disk;

type
  Tload_dsk = class(TForm)
    Button1: TButton;
    GroupBox1: TGroupBox;
    Button2: TButton;
    FileListBox1: TFileListBox;
    DirectoryListBox1: TDirectoryListBox;
    DriveComboBox1: TDriveComboBox;
    StringGrid1: TStringGrid;
    procedure Button2Click(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure FileListBox1KeyUp(Sender:TObject;var Key:word;Shift: TShiftState);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  load_dsk: Tload_dsk;
  file_name,file_extension,end_file_name:string;
  datos_dsk:pbyte;
  file_size,ultima_posicion:integer;

implementation
uses principal;

{$R *.dfm}

procedure Tload_dsk.Button1Click(Sender: TObject);
begin
if datos_dsk<>nil then freemem(datos_dsk);
datos_dsk:=nil;
case main_vars.tipo_maquina of
  2:Directory.spectrum_disk:=FileListBox1.Directory+main_vars.cadena_dir;
  8,9:Directory.amstrad_disk:=FileListBox1.Directory+main_vars.cadena_dir;
end;
ultima_posicion:=filelistbox1.ItemIndex;
load_dsk.close;
end;

procedure Tload_dsk.Button2Click(Sender: TObject);
begin
FileListBox1DblClick(self);
end;

procedure Tload_dsk.FileListBox1Click(Sender: TObject);
var
  f:word;
  longitud,crc:integer;
  nothing1,nothing2:boolean;
  file_inside_zip:string;
begin
file_name:=filelistbox1.FileName;
file_extension:=extension_fichero(filelistbox1.FileName);
if datos_dsk<>nil then begin
  freemem(datos_dsk);
  datos_dsk:=nil;
end;
for f:=1 to (stringgrid1.RowCount-1) do begin
    stringgrid1.Cells[0,f]:='';
    stringgrid1.Cells[1,f]:='';
end;
stringgrid1.RowCount:=2;
f:=1;
if file_extension='ZIP' then begin
  //Primero busco los DSK
  if search_file_from_zip(file_name,'*.dsk',file_inside_zip,longitud,crc,false) then begin
    repeat
       stringgrid1.Cells[0,f]:=file_inside_zip;
       stringgrid1.Cells[1,f]:=inttostr(longitud);
       inc(f);
       stringgrid1.RowCount:=stringgrid1.RowCount+1;
    until not(find_next_file_zip(file_inside_zip,longitud,crc));
    nothing1:=false;
  end else nothing1:=true;
  //Ahora busco los IPF
  if search_file_from_zip(file_name,'*.ipf',file_inside_zip,longitud,crc,false) then begin
    repeat
       stringgrid1.Cells[0,f]:=file_inside_zip;
       stringgrid1.Cells[1,f]:=inttostr(longitud);
       inc(f);
       stringgrid1.RowCount:=stringgrid1.RowCount+1;
    until not(find_next_file_zip(file_inside_zip,longitud,crc));
    nothing2:=false;
  end else nothing1:=true;
  if (nothing1 and nothing2) then exit;
  stringgrid1.RowCount:=stringgrid1.RowCount-1;
end;
if ((file_extension='DSK') or (file_extension='IPF')) then begin
  if not(read_file_size(file_name,file_size)) then exit;
  getmem(datos_dsk,file_size);
  if not(read_file(file_name,datos_dsk,file_size)) then exit;
  end_file_name:=extractfilename(file_name);
end;
end;

procedure Tload_dsk.FileListBox1DblClick(Sender: TObject);
var
  correcto:boolean;
begin
correcto:=false;
if file_extension='' then exit;
if file_extension='DSK' then correcto:=dsk_format(0,file_size,datos_dsk);
if file_extension='IPF' then correcto:=ipf_format(0,file_size,datos_dsk);
if correcto then begin
    llamadas_maquina.open_file:=file_extension+':'+end_file_name;
    ResetFDC;
    dsk[0].ImageName:=end_file_name;
    load_dsk.Button1Click(self);
end else begin
  MessageDlg('Error abriendo el disco: "'+end_file_name+'".', mtError,[mbOk], 0);
  llamadas_maquina.open_file:='';
end;
change_caption;
freemem(datos_dsk);
datos_dsk:=nil;
end;

procedure Tload_dsk.FileListBox1KeyUp(Sender:TObject;var Key:word;Shift: TShiftState);
begin
case key of
  13:FileListBox1DblClick(self);
  27:Button1Click(self);
end;
end;

procedure Tload_dsk.FormShow(Sender: TObject);
begin
stringgrid1.ColWidths[0]:=stringgrid1.Width-60;
stringgrid1.ColWidths[1]:=60;
stringgrid1.Cells[0,0]:=leng[main_vars.idioma].varios[0];
stringgrid1.Cells[1,0]:=leng[main_vars.idioma].varios[1];
Button2.Caption:=leng[main_vars.idioma].mensajes[7];
Button1.Caption:=leng[main_vars.idioma].mensajes[8];
case main_vars.tipo_maquina of
  2:DirectoryListBox1.Directory:=Directory.spectrum_disk;
  8,9:DirectoryListBox1.Directory:=Directory.amstrad_disk;
end;
if ((filelistbox1.Count=0) or (ultima_posicion<=0))  then begin
  ultima_posicion:=0;
  exit;
end else begin
  if ultima_posicion<filelistbox1.Count then begin
    filelistbox1.Selected[ultima_posicion]:=true;
  end;
end;
filelistbox1.setfocus;
FileListBox1Click(nil);
end;

procedure Tload_dsk.StringGrid1DblClick(Sender: TObject);
var
  crc:integer;
  file_inside_zip:string;
begin
if stringgrid1.RowCount=1 then exit;
if datos_dsk<>nil then begin
  freemem(datos_dsk);
  datos_dsk:=nil;
end;
if not(search_file_from_zip(file_name,stringgrid1.Cells[0,stringgrid1.Selection.top],file_inside_zip,file_size,crc,true)) then exit;
getmem(datos_dsk,file_size);
if not(load_file_from_zip(file_name,file_inside_zip,datos_dsk,file_size,crc,true)) then exit;
file_extension:=extension_fichero(file_inside_zip);
end_file_name:=file_inside_zip;
FileListBox1DblClick(self);
end;

end.
