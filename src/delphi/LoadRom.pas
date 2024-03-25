unit LoadRom;
interface
uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons,pngimage,lenguaje,main_engine;

type
  TFLoadRom = class(TForm)
    gpxrominfo: TGroupBox;
    RomList: TStringGrid;
    BitBtn3: TBitBtn;
    BitBtn1: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    Panel1: TPanel;
    ImgPreview: TImage;
    GroupBox1: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    GroupBox2: TGroupBox;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    procedure RomListDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure RomListClick(Sender: TObject);
    procedure FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
    procedure BitBtn3Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
  private
    procedure init_game_desc(sort:word);
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FLoadRom: TFLoadRom;

implementation
uses init_games, principal;
{$R *.dfm}

procedure show_picture;
var
  dir:string;
  numero:integer;
begin
numero:=StrToInt(fLoadRom.RomList.Cells[2,fLoadRom.RomList.Selection.Top]);
FLoadRom.label4.caption:=GAMES_DESC[numero].year;
FLoadRom.label5.caption:=sound_tipo[GAMES_DESC[numero].snd];
FLoadRom.label9.caption:=GAMES_DESC[numero].company;
if GAMES_DESC[numero].hi then FLoadRom.label6.caption:='YES'
      else FLoadRom.label6.caption:='NO';
//En el caso de las consolas es especial prefiero poner una imagen fija
case GAMES_DESC[numero].grid of
  3:dir:='plus2a.png';
  1000:dir:='nes.png';
  1001:dir:='coleco.png';
  1002:if GAMES_DESC[numero].zip='gbcolor' then dir:='gbc.png'
        else dir:='gb.png';
  1003:dir:='chip8.png';
  1004:dir:='sms.png';
  1005:dir:='sg1000.png';
  1006:dir:='gg.png';
  1007:dir:='scv.png';
  1008:dir:='genesis.png';
  1009:dir:='pv1000.png';
  1010:dir:='pv2000.png';
  else dir:=GAMES_DESC[numero].zip+'.png';
end;
if FileExists(Directory.Preview+dir) then Floadrom.ImgPreview.Picture.LoadFromFile(Directory.Preview+dir)
      else Floadrom.ImgPreview.Picture.LoadFromFile(Directory.Preview+'preview.png');
end;

procedure TFLoadRom.FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
begin
case key of
  13:begin
      fLoadRom.RomListDblClick(nil);
      Close;
     end;
  38,40:show_picture;
  27:floadrom.BitBtn1Click(nil);
end;
end;

procedure test_sort_arcade;
begin
  main_vars.sort:=0;
  if floadrom.checkbox1.Checked then main_vars.sort:=main_vars.sort or $10;
  if floadrom.checkbox2.Checked then main_vars.sort:=main_vars.sort or $20;
  if floadrom.checkbox3.Checked then main_vars.sort:=main_vars.sort or $40;
  if floadrom.checkbox4.Checked then main_vars.sort:=main_vars.sort or $80;
  if floadrom.checkbox5.Checked then main_vars.sort:=main_vars.sort or $100;
  if floadrom.checkbox6.Checked then main_vars.sort:=main_vars.sort or $200;
  if main_vars.sort=0 then main_vars.sort:=1;
end;

procedure TFLoadRom.FormShow(Sender: TObject);
var
  f,h,pos:word;
  png:TPngImage;
begin
BitBtn1.Caption:=leng[main_vars.idioma].mensajes[8];
romlist.ColWidths[0]:=romlist.Width-65;
romlist.ColWidths[1]:=40;
romlist.ColWidths[2]:=-1;
romlist.Visible:=true;
romlist.Cells[0,0]:='Driver Name';
romlist.Cells[1,0]:='ROM';
//Creo la imagen si no existe
if not(FileExists(Directory.Preview+'preview.png')) then begin
   ImgPreview.canvas.Brush.Color:=clWhite;
   ImgPreview.canvas.Brush.Style:=bsSolid;
   ImgPreview.canvas.Rectangle(0,0,ImgPreview.Width,ImgPreview.Height);
   ImgPreview.Canvas.Font.Color:=clblue;
   ImgPreview.Canvas.Font.Size:=12;
   ImgPreview.Canvas.TextOut(70,80,'Image not available!');
   PNG:=TPngImage.Create;
   PNG.Assign(imgpreview.Picture.Bitmap);
   PNG.SaveToFile(Directory.Preview+'preview.png');
   PNG.free;
end;
//Los ordeno...
for f:=1 to GAMES_CONT do orden_games[f]:=f;
  for f:=1 to GAMES_CONT-1 do begin
    for h:=1 to GAMES_CONT-1 do begin
      if GAMES_DESC[orden_games[h]].name>GAMES_DESC[orden_games[h+1]].name then begin
        pos:=orden_games[h];
        orden_games[h]:=orden_games[h+1];
        orden_games[h+1]:=pos;
    end;
  end;
end;
//Añado las entradas a la lista
case main_vars.sort of
  0:RadioButton1.Checked:=true;
  2:RadioButton2.Checked:=true;
  4:RadioButton4.Checked:=true;
  8:RadioButton3.Checked:=true;
  1,$10..$ffff:begin
      CheckBox1.Checked:=(main_vars.sort and $10)<>0;
      CheckBox2.Checked:=(main_vars.sort and $20)<>0;
      CheckBox3.Checked:=(main_vars.sort and $40)<>0;
      CheckBox4.Checked:=(main_vars.sort and $80)<>0;
      CheckBox5.Checked:=(main_vars.sort and $100)<>0;
      CheckBox6.Checked:=(main_vars.sort and $200)<>0;
      //El orden es importante!!
      radiobutton5.checked:=true;
    end;
end;
show_picture;
end;

procedure TFLoadRom.init_game_desc(sort:word);
var
  f:word;
  sitio,cantidad:integer;
  myRect:TGridRect;
procedure poner;
var
  test:string;
  numero:integer;
begin
romlist.RowCount:=cantidad+1; //Hay que cotar las de arriba!!!
numero:=orden_games[f];
RomList.cells[2,cantidad]:=inttostr(numero);
if ((GAMES_DESC[numero].grid>1999) and (GAMES_DESC[numero].grid<3000)) then RomList.Cells[0,cantidad]:=GAMES_DESC[numero].name+' - Game & Watch'
  else RomList.Cells[0,cantidad]:=GAMES_DESC[numero].name;
if GAMES_DESC[numero].zip='' then RomList.cells[1,cantidad]:='N/A'
  else begin
        test:=directory.arcade_list_roms[find_rom_multiple_dirs(GAMES_DESC[numero].zip+'.zip')];
        if fileexists(test+GAMES_DESC[numero].zip+'.zip') then RomList.cells[1,cantidad]:='YES'
          else RomList.cells[1,cantidad]:='NO';
  end;
cantidad:=cantidad+1;
end;
begin
for f:=1 to romlist.RowCount-1 do romlist.Rows[f].Clear;
cantidad:=1;
myRect.Left:=0;
myRect.Top:=1;
myRect.Right:=1;
myRect.Bottom:=1;
Floadrom.RomList.Selection:=myRect;
with RomList do begin
  for f:=1 to GAMES_CONT do begin
    if sort=0 then poner
      else if (GAMES_DESC[orden_games[f]].tipo and sort)<>0 then poner;
  end;
end;
for f:=1 to cantidad-1 do begin
    if main_vars.tipo_maquina=GAMES_DESC[strtoint(RomList.cells[2,f])].grid then begin
      myRect.Left:=0;
      myRect.Top:=f;
      myRect.Right:=1;
      myRect.Bottom:=f;
      Floadrom.RomList.Selection:=myRect;
      if (f-14)<1 then sitio:=1
        else sitio:=f-14;
      if cantidad>27 then Floadrom.RomList.TopRow:=sitio;
    end;
end;
end;

procedure TFLoadRom.BitBtn1Click(Sender: TObject);
begin
floadrom.close;
if not(main_vars.driver_ok) then begin
    principal1.BitBtn2.Enabled:=false;
    principal1.BitBtn3.Enabled:=false;
    principal1.BitBtn5.Enabled:=false;
    principal1.BitBtn6.Enabled:=false;
    principal1.BitBtn19.Enabled:=false;
    principal1.BitBtn8.Enabled:=false;
    principal1.enabled:=true;
    if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;
end;

procedure TFLoadRom.BitBtn3Click(Sender: TObject);
begin
FLoadRom.RomListDblClick(nil);
end;

procedure TFLoadRom.RomListDblClick(Sender: TObject);
var
  numero:integer;
begin
numero:=GAMES_DESC[StrToInt(RomList.Cells[2,RomList.Selection.Top])].grid;
//Si es la misma maquina debe continuar, sino que ejecute la nueva
if main_vars.tipo_maquina<>numero then load_game(numero);
floadrom.close;
end;

procedure TFLoadRom.RadioButton1Click(Sender: TObject);
begin
  init_game_desc(0);
  main_vars.sort:=0;
  groupbox2.Enabled:=false;
  groupbox2.visible:=false;
  show_picture;
end;

procedure TFLoadRom.RadioButton2Click(Sender: TObject);
begin
  init_game_desc(2);
  main_vars.sort:=2;
  groupbox2.Enabled:=false;
  groupbox2.visible:=false;
  show_picture;
end;

procedure TFLoadRom.RadioButton5Click(Sender: TObject);
begin
  groupbox2.Enabled:=true;
  groupbox2.visible:=true;
  test_sort_arcade;
  init_game_desc(main_vars.sort);
  show_picture;
end;

procedure TFLoadRom.CheckBox1Click(Sender: TObject);
begin
  test_sort_arcade;
  init_game_desc(main_vars.sort);
  show_picture;
end;

procedure TFLoadRom.RomListClick(Sender: TObject);
begin
show_picture;
end;

procedure TFLoadRom.RadioButton3Click(Sender: TObject);
begin
  init_game_desc(8);
  main_vars.sort:=8;
  groupbox2.Enabled:=false;
  groupbox2.visible:=false;
  show_picture;
end;

procedure TFLoadRom.RadioButton4Click(Sender: TObject);
begin
  init_game_desc(4);
  main_vars.sort:=4;
  groupbox2.Enabled:=false;
  groupbox2.visible:=false;
  show_picture;
end;

end.
