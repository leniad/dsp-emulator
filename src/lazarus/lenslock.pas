unit lenslock;

{$mode delphi}

interface

uses
  {$IFDEF WINDOWS}windows,{$else}LCLType,LCLIntf,{$endif}
  Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  Buttons, StdCtrls, ExtCtrls,main_engine,spectrum_128k,spectrum_3,tape_window;

const
          decode_lenslok:array[0..6,0..15] of shortint=(
	( 0, -81, -31,	13, -62, -41,  22, 0,  0, -22,	39, 58, -12, 29, 70, 0 ),	// ACE
	( 0, -41, -30, -68, -52, -11, -20, 0,  0,  32,	60, 11,  22, 49, 71, 0 ),	// Art Studio
	( 0, -41, -57, -77,  10, -28, -19, 0,  0,  43, -10, 22,  32, 77, 58, 0 ),	// Elite
	( 0, -40, -57, -71,  14, -27, -21, 0,  0,  42, -12, 22,  27, 67, 53, 0 ),	// Jewels of Darkness
	( 0, -27, -39, -71, -6,  -17, -48, 0,  0,  51,	64,  7,  40, 17, 79, 0 ),	// Price of Magik
	( 0, -82, -31, -58, -20, -42,  10, 0,  0, -10,	32, 65,  20, 44, 80, 0 ),	// Tomahawk
	( 0, -20, -41, -69, -53,   6, -29, 0,  0,  -9,	64, 20,  46, 33, 81, 0 ));	// TT Racer

type
  { Tlenslock1 }

  Tlenslock1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn18: TBitBtn;
    GroupBox2: TGroupBox;
    Image1: TImage;
    procedure close_button(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;
  def_lens=record
    activo:boolean;
    indice:byte;
  end;

var
  lenslock1: Tlenslock1;
  lenslok:def_lens;

implementation
uses principal,spectrum_misc;

{ Tlenslock1 }

procedure sens_lock(image_to_show:TImage);
var
  i:byte;
  noffset:integer;
  imagen1:tbitmap;
begin
imagen1:=tbitmap.Create;
case main_vars.tipo_maquina of
  0,5:spec_a_pantalla(@memoria[$4000],imagen1);
  1,4:spec_a_pantalla(@memoria_128k[pantalla_128k,0],imagen1);
  2,3:spec_a_pantalla(@memoria_3[pantalla_128k,0],imagen1);
end;
for i:=0 to 15 do begin
  if decode_lenslok[lenslok.indice,i]<>0 then noffset:=round((57*decode_lenslok[lenslok.indice,i])/100)
    else noffset:=round((57*101) div 100);
  StretchBlt(imagen1.canvas.handle, i, 0,1, 32,imagen1.Canvas.Handle,127+noffset, 54+1, 1, 21-2, SRCCOPY);
end;
StretchBlt(image_to_show.canvas.handle, 0, 0,129, 57,imagen1.Canvas.Handle,0, 0, 16, 32, SRCCOPY);
image_to_show.Visible:=false;
image_to_show.Visible:=true;
imagen1.free;
end;

procedure Tlenslock1.BitBtn1Click(Sender: TObject);
begin
sens_lock(lenslock1.Image1);
end;

procedure Tlenslock1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
tape_window1.label2.caption:='';
lenslok.activo:=false;
end;

procedure Tlenslock1.FormShow(Sender: TObject);
begin
lenslock1.Left:=SCREEN_DIF+principal1.Left+principal1.Width;
lenslock1.Top:=SCREEN_DIF+tape_window1.top+tape_window1.Height;
end;

procedure Tlenslock1.close_button(Sender: TObject);
begin
close;
end;

initialization
  {$I lenslock.lrs}

end.

