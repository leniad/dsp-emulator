unit tape_window;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls, Grids,lenguaje;

type
  TForm5 = class(TForm)
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
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form5: TForm5;
  tape_bitmap:tbitmap;

implementation
uses principal,tap_tzx,main_engine;

{$R *.dfm}

procedure TForm5.FormClose(Sender: TObject; var Action: TCloseAction);
begin
cinta_tzx.play_tape:=false;
vaciar_cintas;
Tape_bitmap.Destroy;
end;

procedure TForm5.FormShow(Sender: TObject);
begin
//Hacer que no se solape con la principal
form5.Left:=form1.Left+form1.Width;
Tape_Bitmap:=TBitmap.Create;
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

procedure TForm5.fplaycinta(Sender: TObject);   //play
begin
cinta_tzx.play_tape:=true;
cinta_tzx.estados:=0;
BitBtn1.Enabled:=false;
BitBtn2.Enabled:=true;
//if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure TForm5.fstopcinta(Sender: TObject); //stop
begin
cinta_tzx.play_tape:=false;
form5.BitBtn1.Enabled:=true;
form5.BitBtn2.Enabled:=false;
main_vars.mensaje_general:='';
main_screen.rapido:=false;
//if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure TForm5.StringGrid1Click(Sender: TObject);
begin
if cinta_tzx.cargada then begin
  cinta_tzx.grupo:=false;
  cinta_tzx.indice_cinta:=cinta_tzx.indice_select[form5.stringgrid1.Selection.Top];
  siguiente_bloque_tzx;
end;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure TForm5.BitBtn9Click(Sender: TObject);
begin
form1.fLoadCinta(nil);
end;

procedure TForm5.cerrar_cinta(Sender: TObject); //clean
begin
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
close;
end;

end.
