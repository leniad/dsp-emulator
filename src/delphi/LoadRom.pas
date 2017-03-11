unit LoadRom;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, StdCtrls, Grids, Buttons,pngimage,lenguaje,main_engine;

type
  TFLoadRom = class(TForm)
    GroupBox1: TGroupBox;
    ImgPreview: TImage;
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
    Label7: TLabel;
    Label9: TLabel;
    Label10: TLabel;
    procedure RomListDblClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure RomListClick(Sender: TObject);
    procedure FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
    procedure BitBtn3Click(Sender: TObject);
  private
    procedure init_game_desc;
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
begin
FLoadRom.label4.caption:=games_desc[orden_games[Floadrom.RomList.Selection.Top]].year;
FLoadRom.label5.caption:=sound_tipo[games_desc[orden_games[Floadrom.RomList.Selection.Top]].snd];
FLoadRom.label9.caption:=games_desc[orden_games[Floadrom.RomList.Selection.Top]].company;
if games_desc[orden_games[Floadrom.RomList.Selection.Top]].hi then FLoadRom.label6.caption:='YES'
      else FLoadRom.label6.caption:='NO';
//En el caso de las consolas es especial prefiero poner una imagen fija
case games_desc[orden_games[Floadrom.RomList.Selection.Top]].grid of
  1000:dir:='nes.png';
  1001:dir:='coleco.png';
  1002:dir:='gb.png';
  1003:dir:='chip8.png';
  1004:dir:='sms.png';
  else dir:=games_desc[orden_games[Floadrom.RomList.Selection.Top]].zip+'.png';
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
end;
end;

procedure TFLoadRom.FormShow(Sender: TObject);
var
  png:TPngImage;
begin
BitBtn1.Caption:=leng[main_vars.idioma].mensajes[8];
init_game_desc;
if not FileExists(Directory.Preview+'preview.png') then begin
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
show_picture;
end;

procedure TFLoadRom.init_game_desc;
var
  f,h,pos:word;
  pos_grid:integer;
  myRect:TGridRect;
  test:string;
begin
with RomList do begin
  RowCount:=games_cont+1;
  Visible:=true;
  Cells[0,0]:='Driver Name';
  Cells[1,0]:='ROM Found';
  //Los ordeno...
  for f:=1 to games_cont do orden_games[f]:=f;
  for f:=1 to games_cont-1 do begin
    for h:=1 to games_cont-1 do begin
      if games_desc[orden_games[h]].name>games_desc[orden_games[h+1]].name then begin
        pos:=orden_games[h];
        orden_games[h]:=orden_games[h+1];
        orden_games[h+1]:=pos;
      end;
    end;
  end;
  for f:=1 to games_cont do begin
    if main_vars.tipo_maquina=games_desc[orden_games[f]].grid then begin
      myRect.Left:=0;
      myRect.Top:=f;
      myRect.Right:=1;
      myRect.Bottom:=f;
      Floadrom.RomList.Selection:=myRect;
      pos_grid:=f-14;
      if pos_grid<=0 then pos_grid:=1;
      if pos_grid>(games_cont-28) then pos_grid:=games_cont-28;
      Floadrom.RomList.TopRow:=pos_grid;
    end;
    Cells[0,f]:=games_desc[orden_games[f]].name;
    if games_desc[orden_games[f]].zip='' then cells[1,f]:='N/A'
      else begin
        test:=directory.arcade_list_roms[find_rom_multiple_dirs(games_desc[orden_games[f]].zip+'.zip')];
        if fileexists(test+games_desc[orden_games[f]].zip+'.zip') then cells[1,f]:='YES'
          else cells[1,f]:='NO';
      end;
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
    exit;
end;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
EmuStatus:=EmuStatusTemp;
principal1.timer1.Enabled:=true;
end;

procedure TFLoadRom.BitBtn3Click(Sender: TObject);
begin
FLoadRom.RomListDblClick(nil);
end;

procedure TFLoadRom.RomListDblClick(Sender: TObject);
begin
//Si es la misma maquina debe continuar, sino que ejecute la nueva
if main_vars.tipo_maquina<>games_desc[orden_games[Floadrom.RomList.Selection.Top]].grid then load_game(games_desc[orden_games[RomList.Selection.Top]].grid);
floadrom.close;
end;

procedure TFLoadRom.RomListClick(Sender: TObject);
begin
show_picture;
end;

end.
