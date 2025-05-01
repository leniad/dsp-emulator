unit redefine;

{$mode delphi}

interface

uses
  Classes,SysUtils, FileUtil, LResources, Forms, Controls, Graphics, Dialogs,
  StdCtrls, Buttons,lenguaje,controls_engine;

type

  { Tredefine1 }

  Tredefine1 = class(TForm)
    Button1: TButton;
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
    Button2: TButton;
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
    Button3: TButton;
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
    Button4: TButton;
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
    Button5: TButton;
    Button50: TButton;
    Button51: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Button9: TButton;
    SpeedButton1: TSpeedButton;
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
    procedure Button1Click(Sender: TObject);
    procedure Button20Click(Sender: TObject);
    procedure Button21Click(Sender: TObject);
    procedure Button22Click(Sender: TObject);
    procedure Button23Click(Sender: TObject);
    procedure Button24Click(Sender: TObject);
    procedure Button25Click(Sender: TObject);
    procedure Button26Click(Sender: TObject);
    procedure Button27Click(Sender: TObject);
    procedure Button28Click(Sender: TObject);
    procedure Button29Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button30Click(Sender: TObject);
    procedure Button31Click(Sender: TObject);
    procedure Button32Click(Sender: TObject);
    procedure Button33Click(Sender: TObject);
    procedure Button34Click(Sender: TObject);
    procedure Button35Click(Sender: TObject);
    procedure Button36Click(Sender: TObject);
    procedure Button37Click(Sender: TObject);
    procedure Button38Click(Sender: TObject);
    procedure Button39Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button40Click(Sender: TObject);
    procedure Button41Click(Sender: TObject);
    procedure Button42Click(Sender: TObject);
    procedure Button43Click(Sender: TObject);
    procedure Button44Click(Sender: TObject);
    procedure Button45Click(Sender: TObject);
    procedure Button46Click(Sender: TObject);
    procedure Button47Click(Sender: TObject);
    procedure Button48Click(Sender: TObject);
    procedure Button49Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button50Click(Sender: TObject);
    procedure Button51Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormShow(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
  end; 

var
  redefine1: Tredefine1;

implementation
uses principal,config_general;

{ Tredefine1 }

procedure Tredefine1.Button1Click(Sender: TObject);
begin
tecla_leida:=$ffff;
redefine1.close
end;

procedure Tredefine1.Button20Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_O;
redefine1.close;
end;

procedure Tredefine1.Button21Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_P;
redefine1.close;
end;

procedure Tredefine1.Button12Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_Q;
redefine1.close;
end;

procedure Tredefine1.Button13Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_W;
redefine1.close;
end;

procedure Tredefine1.Button14Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_E;
redefine1.close;
end;

procedure Tredefine1.Button15Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_R;
redefine1.close;
end;

procedure Tredefine1.Button16Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_T;
redefine1.close;
end;

procedure Tredefine1.Button17Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_Y;
redefine1.close;
end;

procedure Tredefine1.Button18Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_U;
redefine1.close;
end;

procedure Tredefine1.Button19Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_I;
redefine1.close;
end;

procedure Tredefine1.Button10Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_9;
redefine1.close;
end;

procedure Tredefine1.Button11Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_0;
redefine1.close;
end;

procedure Tredefine1.Button22Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_TAB;
redefine1.close;
end;

procedure Tredefine1.Button23Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_A;
redefine1.close;
end;

procedure Tredefine1.Button24Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_S;
redefine1.close;
end;

procedure Tredefine1.Button25Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_D;
redefine1.close;
end;

procedure Tredefine1.Button26Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_F;
redefine1.close;
end;

procedure Tredefine1.Button27Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_G;
redefine1.close;
end;

procedure Tredefine1.Button28Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_H;
redefine1.close;
end;

procedure Tredefine1.Button29Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_J;
redefine1.close;
end;

procedure Tredefine1.Button2Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_1;
redefine1.close;
end;

procedure Tredefine1.Button30Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_K;
redefine1.close;
end;

procedure Tredefine1.Button31Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_L;
redefine1.close;
end;

procedure Tredefine1.Button32Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_LSHIFT;
redefine1.close;
end;

procedure Tredefine1.Button33Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_Z;
redefine1.close;
end;

procedure Tredefine1.Button34Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_X;
redefine1.close;
end;

procedure Tredefine1.Button35Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_C;
redefine1.close;
end;

procedure Tredefine1.Button36Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_V;
redefine1.close;
end;

procedure Tredefine1.Button37Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_B;
redefine1.close;
end;

procedure Tredefine1.Button38Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_N;
redefine1.close;
end;

procedure Tredefine1.Button39Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_M;
redefine1.close;
end;

procedure Tredefine1.Button3Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_2;
redefine1.close;
end;

procedure Tredefine1.Button40Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_RSHIFT;
redefine1.close;
end;

procedure Tredefine1.Button41Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_LCTRL;
redefine1.close;
end;

procedure Tredefine1.Button42Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_LALT;
redefine1.close;
end;

procedure Tredefine1.Button43Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_SPACE;
redefine1.close;
end;

procedure Tredefine1.Button44Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_RALT;
redefine1.close;
end;

procedure Tredefine1.Button45Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_RCTRL;
redefine1.close;
end;

procedure Tredefine1.Button46Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_DOWN;
redefine1.close;
end;

procedure Tredefine1.Button47Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_UP;
redefine1.close;
end;

procedure Tredefine1.Button48Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_LEFT;
redefine1.close;
end;

procedure Tredefine1.Button49Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_RIGHT;
redefine1.close;
end;

procedure Tredefine1.Button4Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_3;
redefine1.close;
end;

procedure Tredefine1.Button50Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_RETURN;
redefine1.close;
end;

procedure Tredefine1.Button51Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_ESCAPE;
redefine1.close;
end;

procedure Tredefine1.Button5Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_4;
redefine1.close;
end;

procedure Tredefine1.Button6Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_5;
redefine1.close;
end;

procedure Tredefine1.Button7Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_6;
redefine1.close;
end;

procedure Tredefine1.Button8Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_7;
redefine1.close;
end;

procedure Tredefine1.Button9Click(Sender: TObject);
begin
tecla_leida:=KEYBOARD_8;
redefine1.close;
end;

procedure Tredefine1.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case key of
      13,27:speedbutton1Click(nil);
  end;
end;

procedure Tredefine1.FormShow(Sender: TObject);
begin
   redefine1.Button1.Enabled:=false;
   redefine1.SetFocus;
   redefine1.Button1.Enabled:=true;
   redefine1.Button1.Caption:=leng.mensajes[8];
end;

procedure Tredefine1.SpeedButton1Click(Sender: TObject);
begin
  tecla_leida:=KEYBOARD_NONE;
  redefine1.close;
end;

initialization
  {$I redefine.lrs}

end.

