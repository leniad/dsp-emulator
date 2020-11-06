unit tape_window;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids,lenguaje;

type
  Ttape_window1 = class(TForm)
    Panel1: TPanel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    Label1: TLabel;
    StringGrid2: TStringGrid;
    StringGrid1: TStringGrid;
    Label2: TLabel;
    Edit1: TEdit;
    BitBtn9: TBitBtn;
    procedure fplaycinta(Sender: TObject);
    procedure cerrar_cinta(Sender: TObject);
    procedure fstopcinta(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn9Click(Sender: TObject);
    procedure StringGrid1Click(Sender: TObject);
    procedure StringGrid1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  tape_window1: Ttape_window1;

implementation
uses principal,tap_tzx,main_engine;

{$R *.dfm}

procedure Ttape_window1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
cinta_tzx.play_tape:=false;
vaciar_cintas;
Windows.SetFocus(child.Handle);
end;

procedure Ttape_window1.FormShow(Sender: TObject);
begin
//Hacer que no se solape con la principal
tape_window1.Left:=SCREEN_DIF+principal1.Left+principal1.Width;
tape_window1.top:=principal1.top;
//Varios
stringgrid1.ColWidths[0]:=stringgrid1.Width-100;
stringgrid1.ColWidths[1]:=100;
stringgrid1.ColCount:=2;
//stringgrid1.ColWidths[2]:=60;
stringgrid2.ColWidths[0]:=stringgrid1.Width-100;
stringgrid2.ColWidths[1]:=100;
stringgrid2.ColCount:=2;
//stringgrid2.ColWidths[2]:=60;
StringGrid2.cells[0,0]:=leng[main_vars.idioma].varios[0];  //nombre
StringGrid2.cells[1,0]:=leng[main_vars.idioma].varios[1];  //longitud
//StringGrid2.cells[2,0]:='CRC';
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

procedure Ttape_window1.fplaycinta(Sender: TObject);   //play
begin
cinta_tzx.play_tape:=true;
cinta_tzx.estados:=0;
BitBtn1.Enabled:=false;
BitBtn2.Enabled:=true;
if addr(cinta_tzx.tape_start)<>nil then cinta_tzx.tape_start;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Ttape_window1.fstopcinta(Sender: TObject); //stop
begin
main_vars.mensaje_principal:='';
cinta_tzx.play_tape:=false;
tape_window1.BitBtn1.Enabled:=true;
tape_window1.BitBtn2.Enabled:=false;
main_screen.rapido:=false;
if addr(cinta_tzx.tape_stop)<>nil then cinta_tzx.tape_stop;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Ttape_window1.StringGrid1Click(Sender: TObject);
begin
cinta_tzx.grupo:=false;
cinta_tzx.indice_cinta:=cinta_tzx.indice_select[tape_window1.stringgrid1.Selection.Top];
siguiente_bloque_tzx;
Windows.SetFocus(child.Handle);
end;

procedure Ttape_window1.StringGrid1DblClick(Sender: TObject);
begin
tape_window1.StringGrid1Click(nil);
end;

procedure Ttape_window1.BitBtn9Click(Sender: TObject);
begin
principal1.fLoadCinta(nil);
end;

procedure Ttape_window1.cerrar_cinta(Sender: TObject);
begin
if addr(cinta_tzx.tape_stop)<>nil then cinta_tzx.tape_stop;
close;
end;

end.
