unit redefine;

interface

uses
  sdl2,Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, ExtCtrls,lenguaje,main_engine;

type
  TForm4 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    Button10: TButton;
    Button11: TButton;
    Button12: TButton;
    Button13: TButton;
    Button14: TButton;
    Button15: TButton;
    Button16: TButton;
    Button17: TButton;
    Button18: TButton;
    Button19: TButton;
    Button20: TButton;
    Button21: TButton;
    Button22: TButton;
    Button23: TButton;
    Button24: TButton;
    Button25: TButton;
    Button26: TButton;
    Button27: TButton;
    Button28: TButton;
    Button29: TButton;
    Button30: TButton;
    Button31: TButton;
    Button32: TButton;
    Button33: TButton;
    Button34: TButton;
    Button35: TButton;
    Button36: TButton;
    Button37: TButton;
    Button38: TButton;
    Button39: TButton;
    Button40: TButton;
    Button41: TButton;
    Button42: TButton;
    Button43: TButton;
    Button44: TButton;
    Button45: TButton;
    Button46: TButton;
    Button47: TButton;
    Button48: TButton;
    Button49: TButton;
    Button50: TButton;
    Button51: TButton;
    SpeedButton1: TSpeedButton;
    procedure Button1Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure Button40Click(Sender: TObject);
    procedure Button42Click(Sender: TObject);
    procedure Button44Click(Sender: TObject);
    procedure Button41Click(Sender: TObject);
    procedure Button45Click(Sender: TObject);
    procedure Button47Click(Sender: TObject);
    procedure Button46Click(Sender: TObject);
    procedure Button48Click(Sender: TObject);
    procedure Button49Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button43Click(Sender: TObject);
    procedure Button50Click(Sender: TObject);
    procedure Button51Click(Sender: TObject);
    procedure Button23Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure Button11Click(Sender: TObject);
    procedure Button12Click(Sender: TObject);
    procedure Button13Click(Sender: TObject);
    procedure Button14Click(Sender: TObject);
    procedure Button15Click(Sender: TObject);
    procedure Button16Click(Sender: TObject);
    procedure Button17Click(Sender: TObject);
    procedure Button18Click(Sender: TObject);
    procedure Button19Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure Button26Click(Sender: TObject);
    procedure Button27Click(Sender: TObject);
    procedure Button28Click(Sender: TObject);
    procedure Button29Click(Sender: TObject);
    procedure Button30Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button33Click(Sender: TObject);
    procedure Button34Click(Sender: TObject);
    procedure Button35Click(Sender: TObject);
    procedure Button36Click(Sender: TObject);
    procedure Button37Click(Sender: TObject);
    procedure Button38Click(Sender: TObject);
    procedure Button39Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;

implementation
uses config_general;
{$R *.dfm}

procedure TForm4.Button10Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_9;
form4.close;
end;

procedure TForm4.Button11Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_0;
form4.close;
end;

procedure TForm4.Button12Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_Q;
form4.close;
end;

procedure TForm4.Button13Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_W;
form4.close;
end;

procedure TForm4.Button14Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_E;
form4.close;
end;

procedure TForm4.Button15Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_R;
form4.close;
end;

procedure TForm4.Button16Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_T;
form4.close;
end;

procedure TForm4.Button17Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_Y;
form4.close;
end;

procedure TForm4.Button18Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_U;
form4.close;
end;

procedure TForm4.Button19Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_I;
form4.close;
end;

procedure TForm4.Button1Click(Sender: TObject);
begin
tecla_leida:=$ffff;
form4.close;
end;

procedure TForm4.Button20Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_O;
form4.close;
end;

procedure TForm4.Button21Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_P;
form4.close;
end;

procedure TForm4.Button22Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_TAB;
form4.close;
end;

procedure TForm4.Button23Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_A;
form4.close;
end;

procedure TForm4.Button24Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_S;
form4.close;
end;

procedure TForm4.Button25Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_D;
form4.close;
end;

procedure TForm4.Button26Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_F;
form4.close;
end;

procedure TForm4.Button27Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_G;
form4.close;
end;

procedure TForm4.Button28Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_H;
form4.close;
end;

procedure TForm4.Button29Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_J;
form4.close;
end;

procedure TForm4.Button2Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_1;
form4.close;
end;

procedure TForm4.Button30Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_K;
form4.close;
end;

procedure TForm4.Button31Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_L;
form4.close;
end;

procedure TForm4.Button32Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_LSHIFT;
form4.close;
end;

procedure TForm4.Button33Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_Z;
form4.close;
end;

procedure TForm4.Button34Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_X;
form4.close;
end;

procedure TForm4.Button35Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_C;
form4.close;
end;

procedure TForm4.Button36Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_V;
form4.close;
end;

procedure TForm4.Button37Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_B;
form4.close;
end;

procedure TForm4.Button38Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_N;
form4.close;
end;

procedure TForm4.Button39Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_M;
form4.close;
end;

procedure TForm4.Button3Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_2;
form4.close;
end;

procedure TForm4.Button40Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_RSHIFT;
form4.close;
end;

procedure TForm4.Button41Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_LCTRL;
form4.close;
end;

procedure TForm4.Button42Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_LALT;
form4.Close;
end;

procedure TForm4.Button43Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_SPACE;
form4.close;
end;

procedure TForm4.Button44Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_RALT;
form4.close;
end;

procedure TForm4.Button45Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_RCTRL;
form4.close;
end;

procedure TForm4.Button46Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_DOWN;
form4.close;
end;

procedure TForm4.Button47Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_UP;
form4.close;
end;

procedure TForm4.Button48Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_LEFT;
form4.close;
end;

procedure TForm4.Button49Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_RIGHT;
form4.Close;
end;

procedure TForm4.Button4Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_3;
form4.close;
end;

procedure TForm4.Button50Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_RETURN;
form4.close;
end;

procedure TForm4.Button51Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_ESCAPE;
form4.close;
end;

procedure TForm4.Button5Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_4;
form4.close;
end;

procedure TForm4.Button6Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_5;
form4.close;
end;

procedure TForm4.Button7Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_6;
form4.close;
end;

procedure TForm4.Button8Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_7;
form4.close;
end;

procedure TForm4.Button9Click(Sender: TObject);
begin
tecla_leida:=SDL_SCANCODE_8;
form4.close;
end;

procedure TForm4.FormShow(Sender: TObject);
begin
form4.Button1.Enabled:=false;
form4.SetFocus;
form4.Button1.Enabled:=true;
form4.Button1.Caption:=leng[main_vars.idioma].mensajes[8];
end;

procedure TForm4.SpeedButton1Click(Sender: TObject);
begin
tecla_leida:=$fffe;
form4.close;
end;

end.
