unit lenslock;
interface

uses
  lib_sdl2,Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls,
  Forms, Dialogs, ExtCtrls, StdCtrls, Buttons,main_engine,spectrum_128k,
  spectrum_3,tape_window,vars_hide;

const
  decode_lenslok:array[0..8,0..15] of shortint=(
	( 0, -81, -31,  13, -62, -41,  22, 0,  0, -22,  39, 58, -12, 29, 70, 0 ),	// ACE
	( 0, -41, -30, -68, -52, -11, -20, 0,  0,  32,  60, 11,  22, 49, 71, 0 ),	// Art Studio
	( 0, -41, -57, -77,  10, -28, -19, 0,  0,  43, -10, 22,  32, 77, 58, 0 ),	// Elite
	( 0, -40, -57, -71,  14, -27, -21, 0,  0,  42, -12, 22,  27, 67, 53, 0 ),	// Jewels of Darkness
	( 0, -27, -39, -71, -6,  -17, -48, 0,  0,  51,  64,  7,  40, 17, 79, 0 ),	// Price of Magik
	( 0, -82, -31, -58, -20, -42,  10, 0,  0, -10,  32, 65,  20, 44, 80, 0 ),	// Tomahawk
	( 0, -20, -41, -69, -53,   6, -29, 0,  0,  -9,  64, 20,  46, 33, 81, 0 ),	// TT Racer
  ( 0, -77, -28,  -4, -19, -59, -39, 0,  0,  20,  51, 10,  10, 66, 28, 0 ),	// Graphic Adventure Creator
  ( 0, -79, -31,  -7, -22, -61, -44, 0,  0,  18,  50,  7,  67, 39, 27, 0 ));	// Mooncresta


type
  Tlenslock1 = class(TForm)
    BitBtn1: TBitBtn;
    GroupBox2: TGroupBox;
    Image1: TImage;
    BitBtn18: TBitBtn;
    ComboBox1: TComboBox;
    procedure close_button(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
  def_lens=record
    activo:boolean;
    indice:byte;
  end;

var
  lenslock1: Tlenslock1;
  lenslok:def_lens;

implementation
uses spectrum_misc,principal;
var
  imagen1:tbitmap;

{$R *.dfm}
procedure cargar_bmp;
var
  nombre2:ansistring;
  rect2:libsdl_rect;
  temp_s:libsdlP_Surface;
begin
rect2.x:=0;
rect2.y:=0;
rect2.w:=p_final[0].x;
rect2.h:=p_final[0].y;
temp_s:=SDL_CreateRGBSurface(0,rect2.w,rect2.h,16,0,0,0,0);
SDL_UpperBlit(pantalla[1],@rect2,temp_s,@rect2);
nombre2:=directory.Base+'temp.bmp';
SDL_SaveBMP_RW(temp_s,SDL_RWFromFile(pointer(nombre2),'wb'),1);
SDL_FreeSurface(temp_s);
imagen1.LoadFromFile(nombre2);
deletefile(nombre2);
end;

procedure sens_lock(image_to_show:TImage);
var
  i:byte;
  noffset:integer;
  x,y:word;
begin
imagen1:=tbitmap.Create;
x:=127;
y:=54;
case main_vars.tipo_maquina of
  0,5:spec_a_pantalla(@memoria[$4000],imagen1);
  1,4:spec_a_pantalla(@memoria_128k[pantalla_128k,0],imagen1);
  2,3:spec_a_pantalla(@memoria_3[pantalla_128k,0],imagen1);
  7,8,9:begin
          cargar_bmp;
          x:=200;
          case lenslok.indice of
            1:y:=135;
            5:y:=110;
            7:y:=120;
          end;
        end;
end;
for i:=0 to 15 do begin
  if decode_lenslok[lenslok.indice,i]<>0 then noffset:=round((57*decode_lenslok[lenslok.indice,i])/100)
    else noffset:=round((57*101) div 100);
  StretchBlt(imagen1.canvas.handle, i, 0,1, 32,imagen1.Canvas.Handle,x+noffset,y+1, 1, 21-2, SRCCOPY);
end;
StretchBlt(image_to_show.canvas.handle,0,0,127,57,imagen1.Canvas.Handle,0,0, 16, 32, SRCCOPY);
image_to_show.Visible:=false;
image_to_show.Visible:=true;
imagen1.free;
end;

procedure Tlenslock1.close_button(Sender: TObject);
begin
close;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tlenslock1.ComboBox1Change(Sender: TObject);
begin
lenslok.indice:=combobox1.ItemIndex;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tlenslock1.BitBtn1Click(Sender: TObject);
begin
sens_lock(lenslock1.Image1);
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tlenslock1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
tape_window1.label2.caption:='';
lenslok.activo:=false;
if not(main_screen.pantalla_completa) then Windows.SetFocus(child.Handle);
end;

procedure Tlenslock1.FormShow(Sender: TObject);
begin
lenslock1.Left:=SCREEN_DIF+principal1.Left+principal1.Width;
lenslock1.Top:=SCREEN_DIF+tape_window1.top+tape_window1.Height;
combobox1.Items.Clear;
combobox1.Items.Add('ACE');
combobox1.Items.Add('Art Studio');
combobox1.Items.Add('Elite');
combobox1.Items.Add('Jewels of Darkness');
combobox1.Items.Add('Price of Magik');
combobox1.Items.Add('Tomahawk');
combobox1.Items.Add('TT Racer');
combobox1.Items.Add('Graphic Adventure Creator');
combobox1.Items.Add('Mooncresta');
combobox1.ItemIndex:=lenslok.indice;
end;

end.
