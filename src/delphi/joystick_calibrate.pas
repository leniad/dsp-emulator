unit joystick_calibrate;

interface

uses
  lib_sdl2,Windows,sysutils,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,controls_engine,
  Vcl.Imaging.GIFImg, Vcl.ExtCtrls, System.Classes;

type
  Tjoy_calibration = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Label2: TLabel;
    Image1: TImage;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  joy_calibration: Tjoy_calibration;
  salir:boolean;
  cent_x,cent_y,max_x,max_y:array[0..NUM_PLAYERS] of integer;
  joy_ax0,joy_ax1,joy_ax0_cent,joy_ax1_cent:array[0..NUM_PLAYERS] of integer;

procedure bucle_joystick(numero:byte);

implementation
uses principal;

{$R *.dfm}

procedure bucle_joystick(numero:byte);
var
  sdl_event:libSDL_Event;
  tempi,temp_x,temp_y:integer;
begin
joy_calibration.label1.caption:=inttostr(cent_x[numero]);
joy_calibration.label2.caption:=inttostr(cent_y[numero]);
salir:=false;
while not(salir) do begin
  while SDL_PollEvent(@sdl_event)=0 do begin
    application.ProcessMessages;
    if salir then break;
  end;
  if sdl_event.type_=libSDL_JOYAXISMOTION then begin
    tempi:=SDL_JoystickGetAxis(joystick_def[numero],0);
    if abs(tempi)>abs(max_x[numero]) then max_x[numero]:=tempi;
    cent_x[numero]:=tempi;
    joy_calibration.label1.caption:=inttostr(tempi);
    tempi:=SDL_JoystickGetAxis(joystick_def[numero],1);
    if abs(tempi)>abs(max_y[numero]) then max_y[numero]:=tempi;
    cent_y[numero]:=tempi;
    joy_calibration.label2.caption:=inttostr(tempi);
  end;
end;
temp_x:=(abs(max_x[numero])-abs(cent_x[numero])) div 2;
temp_y:=(abs(max_y[numero])-abs(cent_y[numero])) div 2;
arcade_input.joy_left[numero]:=cent_x[numero]-abs(temp_x);
arcade_input.joy_right[numero]:=cent_x[numero]+abs(temp_x);
arcade_input.joy_up[numero]:=cent_y[numero]-abs(temp_y);
arcade_input.joy_down[numero]:=cent_y[numero]+abs(temp_y);
joy_calibration.close;
Windows.SetFocus(child.Handle);
end;

procedure Tjoy_calibration.Button1Click(Sender: TObject);
begin
salir:=true;
end;

procedure Tjoy_calibration.FormShow(Sender: TObject);
begin
(Image1.Picture.Graphic as TGIFImage).Animate:= True;
end;

end.
