unit cargar_dsk;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Grids, FileCtrl, EditBtn,upd765,main_engine,misc_functions,
  file_engine,lenguaje,disk_file_format;

type

  { Tload_dsk }

  Tload_dsk = class(TForm)
    Button1: TButton;
    Button2: TButton;
    DirectoryEdit1: TDirectoryEdit;
    FileListBox1: TFileListBox;
    GroupBox1: TGroupBox;
    StringGrid1: TStringGrid;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure DirectoryEdit1Change(Sender: TObject);
    procedure FileListBox1Click(Sender: TObject);
    procedure FileListBox1DblClick(Sender: TObject);
    procedure FileListBox1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  load_dsk:Tload_dsk;
  nombre_dsk,extension_dsk:string;
  extension_zip,nombre_zip:string;
  datos_dsk:pbyte;
  file_size,ultima_posicion:integer;

implementation
uses principal;

{ Tload_dsk }

procedure Tload_dsk.Button2Click(Sender: TObject);
begin
  FileListBox1DblClick(self);
end;

procedure Tload_dsk.DirectoryEdit1Change(Sender: TObject);
begin
load_dsk.FileListBox1.Directory:=load_dsk.DirectoryEdit1.Directory;
end;

procedure Tload_dsk.FileListBox1Click(Sender: TObject);
var
  f:word;
  nombre_def:string;
  longitud,crc:integer;
begin
nombre_dsk:=filelistbox1.FileName;
extension_dsk:=extension_fichero(filelistbox1.FileName);
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
if extension_dsk='ZIP' then begin
  if not(find_first_file_zip(nombre_dsk,'*.dsk',nombre_zip,longitud,crc,false)) then
    if not(find_first_file_zip(nombre_dsk,'*.ipf',nombre_zip,longitud,crc,false)) then exit;
  repeat
    extension_zip:=extension_fichero(nombre_zip);
    if ((extension_zip='DSK') or (extension_zip='IPF')) then begin
       stringgrid1.Cells[0,f]:=nombre_zip;
       stringgrid1.Cells[1,f]:=inttostr(longitud);
       if f=1 then begin
        nombre_def:=nombre_zip;
        file_size:=longitud;
        getmem(datos_dsk,longitud);
        if not(load_file_from_zip(nombre_dsk,nombre_zip,datos_dsk,longitud,crc,true)) then exit;
       end;
       inc(f);
       stringgrid1.RowCount:=stringgrid1.RowCount+1;
    end;
  until not(find_next_file_zip(nombre_zip,longitud,crc));
  nombre_zip:=nombre_def;
  stringgrid1.RowCount:=stringgrid1.RowCount-1;
end;
if extension_dsk='DSK' then begin
  if not(read_file_size(nombre_dsk,file_size)) then exit;
  getmem(datos_dsk,file_size);
  if not(read_file(nombre_dsk,datos_dsk,file_size)) then exit;
end;
if extension_dsk='IPF' then begin
  if not(read_file_size(nombre_dsk,file_size)) then exit;
  getmem(datos_dsk,file_size);
  if not(read_file(nombre_dsk,datos_dsk,file_size)) then exit;
end;
end;

procedure Tload_dsk.FileListBox1DblClick(Sender: TObject);
var
  cadena:string;
  correcto:boolean;
begin
if extension_dsk='ZIP' then cadena:=extractfilename(nombre_zip)
  else cadena:=extractfilename(nombre_dsk);
if cadena='' then exit;
extension_dsk:=extension_fichero(cadena);
if extension_dsk='DSK' then correcto:=dsk_format(0,file_size,datos_dsk);
if extension_dsk='IPF' then correcto:=ipf_format(0,file_size,datos_dsk);
if correcto then begin
    change_caption(llamadas_maquina.caption+' - '+extension_dsk+': '+cadena);
    ResetFDC;
    dsk[0].ImageName:=cadena;
    load_dsk.Button1Click(self);
end else begin
  MessageDlg('Error abriendo el disco: "'+cadena+'".', mtError,[mbOk], 0);
end;
freemem(datos_dsk);
datos_dsk:=nil;
end;

procedure Tload_dsk.FileListBox1KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
case key of
  13:FileListBox1DblClick(self);
  27:Button1Click(self);
end;
end;

procedure Tload_dsk.FormShow(Sender: TObject);
begin
stringgrid1.Cells[0,0]:=leng[main_vars.idioma].varios[0];
stringgrid1.Cells[1,0]:=leng[main_vars.idioma].varios[1];
Button2.Caption:=leng[main_vars.idioma].mensajes[7];
Button1.Caption:=leng[main_vars.idioma].mensajes[8];
case main_vars.tipo_maquina of
  2:begin
         FileListBox1.Directory:=Directory.spectrum_disk;
         DirectoryEdit1.Directory:=Directory.spectrum_disk;
    end;
  8,9:begin
         FileListBox1.Directory:=Directory.amstrad_disk;
         DirectoryEdit1.Directory:=Directory.amstrad_disk;
      end;
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

procedure Tload_dsk.StringGrid1Click(Sender: TObject);
var
  crc:integer;
begin
if stringgrid1.RowCount=1 then exit;
if datos_dsk<>nil then begin
  freemem(datos_dsk);
  datos_dsk:=nil;
end;
if not(search_file_from_zip(nombre_dsk,stringgrid1.Cells[0,stringgrid1.Selection.top],nombre_zip,file_size,crc,true)) then exit;
getmem(datos_dsk,file_size);
if not(load_file_from_zip(nombre_dsk,nombre_zip,datos_dsk,file_size,crc,true)) then exit;
extension_zip:=extension_fichero(nombre_zip);
end;

procedure Tload_dsk.StringGrid1DblClick(Sender: TObject);
begin
StringGrid1Click(self);
FileListBox1DblClick(self);
end;

procedure Tload_dsk.Button1Click(Sender: TObject);
var
   cadena:string;
begin
if datos_dsk<>nil then freemem(datos_dsk);
datos_dsk:=nil;
cadena:=FileListBox1.Directory;
if cadena[length(cadena)]<>main_vars.cadena_dir then cadena:=cadena+main_vars.cadena_dir;
case main_vars.tipo_maquina of
    2:Directory.spectrum_disk:=cadena;
    8,9:Directory.amstrad_disk:=cadena;
end;
ultima_posicion:=filelistbox1.ItemIndex;
load_dsk.close;
end;

initialization
  {$I cargar_dsk.lrs}

end.

