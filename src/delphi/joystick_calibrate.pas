unit joystick_calibrate;

interface

uses
  sdl2,Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,controls_engine,
  Vcl.Imaging.GIFImg, Vcl.ExtCtrls;

type
  TForm8 = class(TForm)
    Label1: TLabel;
    Button1: TButton;
    Label2: TLabel;
    Image1: TImage;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form8: TForm8;
  salir:boolean;

procedure bucle_joystick(numero:byte);

implementation

{$R *.dfm}

procedure bucle_joystick(numero:byte);
var
  sdl_event:TSDL_Event;
begin
form8.label1.caption:=inttostr(arcade_input.joy_ax0_cent[numero]);
form8.label2.caption:=inttostr(arcade_input.joy_ax1_cent[numero]);
salir:=false;
while not(salir) do begin
  while SDL_PollEvent(@sdl_event)=0 do begin
    application.ProcessMessages;
    if salir then break;
  end;
  SDL_JoystickUpdate;
  if sdl_event.type_=SDL_JOYAXISMOTION then begin
    arcade_input.joy_ax0_cent[numero]:=SDL_JoystickGetAxis(joystick_def[numero],0);
    form8.label1.caption:=inttostr(arcade_input.joy_ax0_cent[numero]);
    arcade_input.joy_ax1_cent[numero]:=SDL_JoystickGetAxis(joystick_def[numero],1);
    form8.label2.caption:=inttostr(arcade_input.joy_ax1_cent[numero]);
  end;
end;
form8.close;
end;

procedure TForm8.Button1Click(Sender: TObject);
begin
salir:=true;
end;

procedure TForm8.FormShow(Sender: TObject);
begin
(Image1.Picture.Graphic as TGIFImage).Animate:= True;
end;

end.
