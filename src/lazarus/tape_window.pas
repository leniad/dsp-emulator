unit tape_window;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Grids,lenguaje;

type

  { TForm5 }

  TForm5 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Panel1: TPanel;
    StringGrid1: TStringGrid;
    StringGrid2: TStringGrid;
    procedure BitBtn4Click(Sender: TObject);
    procedure cerrar_cinta(Sender: TObject);
    procedure FormClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure fPlayCinta(Sender: TObject);
    procedure fstopcinta(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  Form5: TForm5;
  tape_bitmap:tbitmap;

implementation
uses principal,tap_tzx,main_engine;

{ TForm5 }

procedure TForm5.fPlayCinta(Sender: TObject);
begin
cinta_tzx.play_tape:=true;
cinta_tzx.estados:=0;
BitBtn1.Enabled:=false;
BitBtn2.Enabled:=true;
end;

procedure TForm5.cerrar_cinta(Sender: TObject);
begin
close;
end;

procedure TForm5.FormClick(Sender: TObject);
begin

end;

procedure TForm5.BitBtn4Click(Sender: TObject);
begin
  form1.fLoadCinta(nil);
end;

procedure TForm5.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
cinta_tzx.play_tape:=false;
vaciar_cintas;
tape_bitmap.Destroy;
end;

procedure TForm5.FormShow(Sender: TObject);
begin
tape_Bitmap:=TBitmap.Create;
//Varios
form5.StringGrid2.cells[0,0]:=leng[main_vars.idioma].varios[0];  //nombre
form5.StringGrid2.cells[1,0]:=leng[main_vars.idioma].varios[1];  //longitud
form5.StringGrid2.cells[2,0]:='CRC';  //CRC
//mensajes
form5.Caption:=leng[main_vars.idioma].mensajes[2];  //nombre
form5.label1.Caption:=leng[main_vars.idioma].mensajes[9];  //nombre cinta
//Hints
form5.BitBtn1.Hint:=leng[main_vars.idioma].hints[13];
form5.BitBtn2.Hint:=leng[main_vars.idioma].hints[14];
form5.BitBtn3.Hint:=leng[main_vars.idioma].hints[15];
form5.Edit1.Hint:=leng[main_vars.idioma].hints[16];
form5.StringGrid1.Hint:=leng[main_vars.idioma].hints[17];
form5.StringGrid2.Hint:=leng[main_vars.idioma].hints[17];
end;

procedure TForm5.fstopcinta(Sender: TObject);
begin
cinta_tzx.play_tape:=false;
form5.BitBtn1.Enabled:=true;
form5.BitBtn2.Enabled:=false;
main_vars.mensaje_general:='';
main_screen.rapido:=false;
end;

procedure TForm5.StringGrid1Click(Sender: TObject);
begin
if cinta_tzx.cargada then begin
  cinta_tzx.grupo:=false;
  cinta_tzx.indice_cinta:=cinta_tzx.indice_select[form5.stringgrid1.Selection.Top];
  siguiente_bloque_tzx;
end;
end;

initialization
  {$I tape_window.lrs}

end.

