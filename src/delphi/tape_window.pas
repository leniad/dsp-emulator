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
    procedure FormCreate(Sender: TObject);
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

procedure Ttape_window1.FormCreate(Sender: TObject);
begin
  tape_window_idioma;
end;

procedure Ttape_window1.FormShow(Sender: TObject);
begin
//Hacer que no se solape con la principal
tape_window1.Left:=principal1.Left+principal1.Width;
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
end;

procedure Ttape_window1.fplaycinta(Sender: TObject);   //play
begin
cinta_tzx.play_tape:=true;
cinta_tzx.estados:=0;
BitBtn1.Enabled:=false;
BitBtn2.Enabled:=true;
if addr(cinta_tzx.tape_start)<>nil then cinta_tzx.tape_start
  else main_screen.rapido:=true;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Ttape_window1.fstopcinta(Sender: TObject); //stop
begin
main_vars.mensaje_principal:='';
cinta_tzx.play_tape:=false;
tape_window1.BitBtn1.Enabled:=true;
tape_window1.BitBtn2.Enabled:=false;
main_screen.rapido:=false;
if addr(cinta_tzx.tape_stop)<>nil then cinta_tzx.tape_stop
  else main_screen.rapido:=false;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Ttape_window1.StringGrid1Click(Sender: TObject);
begin
cinta_tzx.grupo:=false;
cinta_tzx.indice_cinta:=cinta_tzx.indice_select[tape_window1.stringgrid1.Selection.Top];
siguiente_bloque_tzx;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
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
