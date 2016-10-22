unit LoadRom;

{$mode delphi}

interface

uses
  {$IFDEF WINDOWS}windows,{$ENDIF}
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls, Grids, Buttons,lenguaje,main_engine;

type

  { TFLoadRom }

  TFLoadRom = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn3: TBitBtn;
    gpxrominfo: TGroupBox;
    GroupBox1: TGroupBox;
    ImgPreview: TImage;
    Label1: TLabel;
    Label10: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label9: TLabel;
    RomList: TStringGrid;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure RomListClick(Sender: TObject);
    procedure RomListDblClick(Sender: TObject);
  private
    procedure init_game_desc;
    { private declarations }
  public
    { public declarations }
  end; 

var
  FLoadRom: TFLoadRom;

implementation
uses init_games, principal;

{ TFLoadRom }

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

procedure TFLoadRom.init_game_desc;
var
  f,h,pos:word;
  pos_grid:integer;
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
      Floadrom.RomList.Row:=f;
      pos_grid:=f-14;
      if pos_grid<=0 then pos_grid:=1;
      if pos_grid>(games_cont-28) then pos_grid:=games_cont-28;
      Floadrom.RomList.TopRow:=pos_grid;
    end;
    Cells[0,f]:=games_desc[orden_games[f]].name;
    if games_desc[orden_games[f]].zip='' then cells[1,f]:='N/A'
      else if fileexists(Directory.Arcade_roms+games_desc[orden_games[f]].zip+'.zip') then cells[1,f]:='YES'
        else cells[1,f]:='NO';
  end;
end;
end;

procedure TFLoadRom.RomListClick(Sender: TObject);
begin
show_picture;
end;

procedure TFLoadRom.BitBtn3Click(Sender: TObject);
begin
FLoadRom.RomListDblClick(nil);
end;

procedure TFLoadRom.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState
  );
begin
case key of
  13:begin
    Close;
    FLoadRom.RomListDblClick(nil);
  end;
  38,40:show_picture;
end;
end;

procedure TFLoadRom.FormShow(Sender: TObject);
var
    png:TPortableNetworkGraphic;
begin
BitBtn1.Caption:=leng[main_vars.idioma].mensajes[8];
init_game_desc;
if not FileExists(Directory.Preview+'preview.png') then begin
   png := TPortableNetworkGraphic.Create;
   ImgPreview.canvas.Brush.Color:=clWhite;
   ImgPreview.canvas.Brush.Style:=bsSolid;
   ImgPreview.canvas.Rectangle(0,0,ImgPreview.Width,ImgPreview.Height);
   ImgPreview.Canvas.Brush.Color:=clBlue;
   ImgPreview.Canvas.Font.Color:=clBlue;
   ImgPreview.Canvas.Font.Size:=12;
   ImgPreview.Canvas.TextOut(70, 80, 'Image not Loaded!');
   png.Assign(imgpreview.Picture.Bitmap);
   png.SaveToFile(Directory.Preview+'preview.png');
   png.free;
end;
show_picture;
end;

procedure TFLoadRom.BitBtn1Click(Sender: TObject);
begin
floadrom.close;
if main_vars.tipo_maquina=65535 then exit;
//setfocus
EmuStatus:=EmuStatusTemp;
principal1.timer1.Enabled:=true;
end;

procedure TFLoadRom.RomListDblClick(Sender: TObject);
begin
//Si es la misma maquina debe continuar, sino que ejecute la nueva
if main_vars.tipo_maquina<>games_desc[orden_games[Floadrom.RomList.Selection.Top]].grid then load_game(games_desc[orden_games[RomList.Selection.Top]].grid);
floadrom.close;
end;

initialization
  {$I loadrom.lrs}

end.

