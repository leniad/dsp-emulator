unit tape_window;

{$mode delphi}

interface

uses
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Buttons, Grids,lenguaje;

type

  { Ttape_window1 }

  Ttape_window1 = class(TForm)
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
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure fPlayCinta(Sender: TObject);
    procedure fstopcinta(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  tape_window1: Ttape_window1;

implementation
uses principal,tap_tzx,main_engine;

{ Ttape_window1 }

procedure Ttape_window1.fPlayCinta(Sender: TObject);
begin
cinta_tzx.play_tape:=true;
cinta_tzx.estados:=0;
BitBtn1.Enabled:=false;
BitBtn2.Enabled:=true;
sync_all;
end;

procedure Ttape_window1.cerrar_cinta(Sender: TObject);
begin
close;
end;

procedure Ttape_window1.BitBtn4Click(Sender: TObject);
begin
principal1.fLoadCinta(nil);
end;

procedure Ttape_window1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
cinta_tzx.play_tape:=false;
vaciar_cintas;
sync_all;
end;

procedure Ttape_window1.FormShow(Sender: TObject);
begin
tape_window1.Left:=SCREEN_DIF+principal1.Left+principal1.Width;
tape_window1.top:=principal1.top;
//Varios
tape_window1.StringGrid2.cells[0,0]:=leng[main_vars.idioma].varios[0];  //nombre
tape_window1.StringGrid2.cells[1,0]:=leng[main_vars.idioma].varios[1];  //longitud
//tape_window1.StringGrid2.cells[2,0]:='CRC';  //CRC
//mensajes
tape_window1.Caption:=leng[main_vars.idioma].mensajes[2];  //nombre
tape_window1.label1.Caption:=leng[main_vars.idioma].mensajes[9];  //nombre cinta
//Hints
tape_window1.BitBtn1.Hint:=leng[main_vars.idioma].hints[13];
tape_window1.BitBtn2.Hint:=leng[main_vars.idioma].hints[14];
tape_window1.BitBtn3.Hint:=leng[main_vars.idioma].hints[15];
tape_window1.Edit1.Hint:=leng[main_vars.idioma].hints[16];
tape_window1.StringGrid1.Hint:=leng[main_vars.idioma].hints[17];
tape_window1.StringGrid2.Hint:=leng[main_vars.idioma].hints[17];
end;

procedure Ttape_window1.fstopcinta(Sender: TObject);
begin
cinta_tzx.play_tape:=false;
tape_window1.BitBtn1.Enabled:=true;
tape_window1.BitBtn2.Enabled:=false;
main_vars.mensaje_principal:='';
main_screen.rapido:=false;
sync_all;
end;

procedure Ttape_window1.StringGrid1Click(Sender: TObject);
begin
cinta_tzx.grupo:=false;
cinta_tzx.indice_cinta:=cinta_tzx.indice_select[tape_window1.stringgrid1.Selection.Top];
siguiente_bloque_tzx;
sync_all;
end;

procedure Ttape_window1.StringGrid1DblClick(Sender: TObject);
begin
tape_window1.StringGrid1Click(nil);
end;

initialization
  {$I tape_window.lrs}

end.

