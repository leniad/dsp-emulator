unit joystick_calibration;

{$mode delphi}

interface

uses
  lib_sdl2,Classes, SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ExtCtrls,controls_engine;

type

  { Tjoy_calibration }

  Tjoy_calibration = class(TForm)
    Button1: TButton;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  joy_calibration: Tjoy_calibration;
  salir:boolean;
  cent_x,cent_y,max_x,max_y:integer;

procedure bucle_joystick(numero:byte);

implementation

procedure bucle_joystick(numero:byte);
var
  sdl_event:libSDL_Event;
  tempi,temp_x,temp_y:integer;
begin
joy_calibration.label1.caption:=inttostr(cent_x);
joy_calibration.label2.caption:=inttostr(cent_y);
salir:=false;
while not(salir) do begin
  while SDL_PollEvent(@sdl_event)=0 do begin
    application.ProcessMessages;
    if salir then break;
  end;
  if sdl_event.type_=libSDL_JOYAXISMOTION then begin
    //tempi:=SDL_JoystickGetAxis(joystick_def[numero],0);
    if abs(tempi)>abs(max_x) then max_x:=tempi;
    cent_x:=tempi;
    joy_calibration.label1.caption:=inttostr(tempi);
    //tempi:=SDL_JoystickGetAxis(joystick_def[numero],1);
    if abs(tempi)>abs(max_y) then max_y:=tempi;
    cent_y:=tempi;
    joy_calibration.label2.caption:=inttostr(tempi);
  end;
end;
temp_x:=(abs(max_x)-abs(cent_x)) div 2;
temp_y:=(abs(max_y)-abs(cent_y)) div 2;
arcade_input.joy_left[numero]:=cent_x-abs(temp_x);
arcade_input.joy_right[numero]:=cent_x+abs(temp_x);
arcade_input.joy_up[numero]:=cent_y-abs(temp_y);
arcade_input.joy_down[numero]:=cent_y+abs(temp_y);
joy_calibration.close;
end;

{ Tjoy_calibration }

procedure Tjoy_calibration.Button1Click(Sender: TObject);
begin
salir:=true;
end;

procedure Tjoy_calibration.FormShow(Sender: TObject);
begin
//(Image1.Picture.Graphic as TGIFImage).Animate:= True;
end;

initialization
{$I joystick_calibration.lrs}

end.

