unit redefine_main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,redefine;

type
  TMredefine = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn10: TBitBtn;
    BitBtn11: TBitBtn;
    BitBtn15: TBitBtn;
    BitBtn16: TBitBtn;
    BitBtn17: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn23: TBitBtn;
    BitBtn24: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn9: TBitBtn;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    procedure FormShow(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn23Click(Sender: TObject);
    procedure BitBtn24Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn9Click(Sender: TObject);
    procedure BitBtn10Click(Sender: TObject);
    procedure BitBtn11Click(Sender: TObject);
    procedure BitBtn17Click(Sender: TObject);
    procedure BitBtn15Click(Sender: TObject);
    procedure BitBtn16Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Mredefine: TMredefine;
  tecla_leida:word;
  config_button:boolean;
  indice_redefinir:byte;

implementation
uses controls_engine,lib_sdl2,principal;

{$R *.dfm}

function nombre_tecla(num:word):string;
begin
  case num of
    KEYBOARD_ESCAPE:nombre_tecla:='ESC';
    KEYBOARD_CAPSLOCK:nombre_tecla:='CAPSLOCK';
    KEYBOARD_TAB:nombre_tecla:='TAB';
    //KEYBOARD_SLASH:nombre_tecla:='SLASH';
    //KEYBOARD_QUOTE:nombre_tecla:='QUOTE';
    //KEYBOARD_SEMICOLON:nombre_tecla:='SEMICOLON';
    //KEYBOARD_BACKSLASH:nombre_tecla:='DELETE';
    //KEYBOARD_LESS:nombre_tecla:='LESS';
    KEYBOARD_HOME:nombre_tecla:='HOME';
    KEYBOARD_RIGHT:nombre_tecla:='RIGHT';
    KEYBOARD_LEFT:nombre_tecla:='LEFT';
    KEYBOARD_DOWN:nombre_tecla:='DOWN';
    KEYBOARD_UP:nombre_tecla:='UP';
    KEYBOARD_RALT:nombre_tecla:='RALT';
    KEYBOARD_LALT:nombre_tecla:='LALT';
    KEYBOARD_RSHIFT:nombre_tecla:='RSHIFT';
    KEYBOARD_LSHIFT:nombre_tecla:='LSHIFT';
    KEYBOARD_RCTRL:nombre_tecla:='RCONTROL';
    KEYBOARD_LCTRL:nombre_tecla:='LCONTROL';
    KEYBOARD_RETURN:nombre_tecla:='ENTER';
    KEYBOARD_SPACE:nombre_tecla:='SPACE';
    KEYBOARD_A:nombre_tecla:='A';
    KEYBOARD_B:nombre_tecla:='B';
    KEYBOARD_C:nombre_tecla:='C';
    KEYBOARD_D:nombre_tecla:='D';
    KEYBOARD_E:nombre_tecla:='E';
    KEYBOARD_F:nombre_tecla:='F';
    KEYBOARD_G:nombre_tecla:='G';
    KEYBOARD_H:nombre_tecla:='H';
    KEYBOARD_I:nombre_tecla:='I';
    KEYBOARD_J:nombre_tecla:='J';
    KEYBOARD_K:nombre_tecla:='K';
    KEYBOARD_L:nombre_tecla:='L';
    KEYBOARD_M:nombre_tecla:='M';
    KEYBOARD_N:nombre_tecla:='N';
    KEYBOARD_O:nombre_tecla:='O';
    KEYBOARD_P:nombre_tecla:='P';
    KEYBOARD_Q:nombre_tecla:='Q';
    KEYBOARD_R:nombre_tecla:='R';
    KEYBOARD_S:nombre_tecla:='S';
    KEYBOARD_T:nombre_tecla:='T';
    KEYBOARD_U:nombre_tecla:='U';
    KEYBOARD_V:nombre_tecla:='V';
    KEYBOARD_W:nombre_tecla:='W';
    KEYBOARD_X:nombre_tecla:='X';
    KEYBOARD_Y:nombre_tecla:='Y';
    KEYBOARD_Z:nombre_tecla:='Z';
    KEYBOARD_1:nombre_tecla:='1';
    KEYBOARD_2:nombre_tecla:='2';
    KEYBOARD_3:nombre_tecla:='3';
    KEYBOARD_4:nombre_tecla:='4';
    KEYBOARD_5:nombre_tecla:='5';
    KEYBOARD_6:nombre_tecla:='6';
    KEYBOARD_7:nombre_tecla:='7';
    KEYBOARD_8:nombre_tecla:='8';
    KEYBOARD_9:nombre_tecla:='9';
    KEYBOARD_0:nombre_tecla:='0';
    KEYBOARD_NONE:nombre_tecla:='N/D';
    else nombre_tecla:='N/D';
  end;
end;

function nombre_boton(boton:byte):string;
begin
  if boton=255 then nombre_boton:='None'
    else nombre_boton:=inttostr(boton);
end;

function get_button(boton:byte):byte;
var
  f,res:byte;
  tempb,salir:boolean;
  time1,time2:cardinal;
  tempstr:string;
begin
salir:=false;
time1:=sdl_getticks;
while not(salir) do begin
  SDL_JoystickUpdate;
  application.ProcessMessages;
  if salir then break;
  time2:=sdl_getticks;
  if ((time2-time1)>5000) then begin
    get_button:=$ff;
    exit;
  end;
  tempstr:='Press Btn ('+inttostr(5-((time2-time1) div 1000))+')';
  case boton of
    9:mredefine.BitBtn9.Caption:=tempstr;
    10:mredefine.BitBtn10.Caption:=tempstr;
    11:mredefine.BitBtn11.Caption:=tempstr;
    15:mredefine.BitBtn15.Caption:=tempstr;
    16:mredefine.BitBtn16.Caption:=tempstr;
    17:mredefine.BitBtn17.Caption:=tempstr;
    23:mredefine.BitBtn23.Caption:=tempstr;
    24:mredefine.BitBtn24.Caption:=tempstr;
  end;
  for f:=0 to joystick.buttons[indice_redefinir-4]-1 do begin
    tempb:=(SDL_JoystickGetButton(joystick_def[indice_redefinir-4],f)=1);
    if tempb then begin
      res:=f;
      salir:=true;
    end;
  end;
end;
get_button:=res;
end;

procedure TMredefine.BitBtn10Click(Sender: TObject);
begin
if indice_redefinir<4 then begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn10.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].but1:=tecla_leida;
  end;
end else begin
    if config_button then exit;
    config_button:=true;
    defkeys[indice_redefinir].but1:=get_button(10);
    config_button:=false;
    bitbtn10.Caption:=nombre_boton(defkeys[indice_redefinir].but1);
  end;
end;

procedure TMredefine.BitBtn11Click(Sender: TObject);
begin
if indice_redefinir<4 then begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn11.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].but2:=tecla_leida;
  end;
end else begin
    if config_button then exit;
    config_button:=true;
    defkeys[indice_redefinir].but2:=get_button(11);
    config_button:=false;
    bitbtn11.Caption:=nombre_boton(defkeys[indice_redefinir].but2);
  end;
end;

procedure TMredefine.BitBtn15Click(Sender: TObject);
begin
if indice_redefinir<4 then begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn15.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].but4:=tecla_leida;
  end;
end else begin
    if config_button then exit;
    config_button:=true;
    defkeys[indice_redefinir].but4:=get_button(15);
    config_button:=false;
    bitbtn15.Caption:=nombre_boton(defkeys[indice_redefinir].but4);
  end;
end;

procedure TMredefine.BitBtn16Click(Sender: TObject);
begin
if indice_redefinir<4 then begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn16.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].but5:=tecla_leida;
  end;
end else begin
    if config_button then exit;
    config_button:=true;
    defkeys[indice_redefinir].but5:=get_button(16);
    config_button:=false;
    bitbtn16.Caption:=nombre_boton(defkeys[indice_redefinir].but5);
  end;
end;

procedure TMredefine.BitBtn17Click(Sender: TObject);
begin
if indice_redefinir<4 then begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn17.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].but3:=tecla_leida;
  end;
end else begin
    if config_button then exit;
    config_button:=true;
    defkeys[indice_redefinir].but3:=get_button(17);
    config_button:=false;
    bitbtn17.Caption:=nombre_boton(defkeys[indice_redefinir].but3);
  end;
end;

procedure TMredefine.BitBtn1Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn1.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].left:=tecla_leida;
  end;
end;

procedure TMredefine.BitBtn23Click(Sender: TObject);
begin
if indice_redefinir<4 then begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn23.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].coin:=tecla_leida;
  end;
end else begin
    if config_button then exit;
    config_button:=true;
    defkeys[indice_redefinir].coin:=get_button(23);
    config_button:=false;
    bitbtn23.Caption:=nombre_boton(defkeys[indice_redefinir].coin);
  end;
end;

procedure TMredefine.BitBtn24Click(Sender: TObject);
begin
if indice_redefinir<4 then begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn24.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].start:=tecla_leida;
  end;
end else begin
    if config_button then exit;
    config_button:=true;
    defkeys[indice_redefinir].start:=get_button(24);
    config_button:=false;
    bitbtn24.Caption:=nombre_boton(defkeys[indice_redefinir].start);
  end;
end;

procedure TMredefine.BitBtn2Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn2.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].right:=tecla_leida;
  end;
end;

procedure TMredefine.BitBtn3Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn3.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].down:=tecla_leida;
  end;
end;

procedure TMredefine.BitBtn4Click(Sender: TObject);
begin
  redefine1.showmodal;
  if tecla_leida<>$ffff then begin
    bitbtn4.Caption:=nombre_tecla(tecla_leida);
    defkeys[indice_redefinir].up:=tecla_leida;
  end;
end;

procedure TMredefine.BitBtn9Click(Sender: TObject);
begin
  if indice_redefinir<4 then begin
    redefine1.showmodal;
    if tecla_leida<>$ffff then begin
      bitbtn9.Caption:=nombre_tecla(tecla_leida);
      defkeys[indice_redefinir].but0:=tecla_leida;
    end;
  end else begin
    if config_button then exit;
    config_button:=true;
    defkeys[indice_redefinir].but0:=get_button(9);
    config_button:=false;
    bitbtn9.Caption:=nombre_boton(defkeys[indice_redefinir].but0);
  end;
end;

procedure TMredefine.FormShow(Sender: TObject);
var
  f:integer;
begin
  f:=(principal1.left+(principal1.width div 2))-(Mredefine.Width div 2);
  if f<0 then Mredefine.Left:=0
    else Mredefine.Left:=f;
  f:=(principal1.top+(principal1.Height div 2))-(Mredefine.Height div 2);
  if f<0 then Mredefine.Top:=0
    else Mredefine.Top:=f;
  if indice_redefinir<4 then begin
    bitbtn1.Enabled:=true;
    bitbtn2.Enabled:=true;
    bitbtn3.Enabled:=true;
    bitbtn4.Enabled:=true;
    bitbtn1.Caption:=nombre_tecla(defkeys[indice_redefinir].left);
    bitbtn2.Caption:=nombre_tecla(defkeys[indice_redefinir].right);
    bitbtn3.Caption:=nombre_tecla(defkeys[indice_redefinir].down);
    bitbtn4.Caption:=nombre_tecla(defkeys[indice_redefinir].up);
    bitbtn23.Caption:=nombre_tecla(defkeys[indice_redefinir].coin);
    bitbtn10.Caption:=nombre_tecla(defkeys[indice_redefinir].but1);
    bitbtn24.Caption:=nombre_tecla(defkeys[indice_redefinir].start);
    bitbtn9.Caption:=nombre_tecla(defkeys[indice_redefinir].but0);
    bitbtn11.Caption:=nombre_tecla(defkeys[indice_redefinir].but2);
    bitbtn17.Caption:=nombre_tecla(defkeys[indice_redefinir].but3);
    bitbtn15.Caption:=nombre_tecla(defkeys[indice_redefinir].but4);
    bitbtn16.Caption:=nombre_tecla(defkeys[indice_redefinir].but5);
  end else begin
    bitbtn1.Enabled:=false;
    bitbtn2.Enabled:=false;
    bitbtn3.Enabled:=false;
    bitbtn4.Enabled:=false;
    bitbtn1.Caption:='LEFT';
    bitbtn2.Caption:='RIGHT';
    bitbtn3.Caption:='DOWN';
    bitbtn4.Caption:='UP';
    bitbtn23.Caption:=nombre_boton(defkeys[indice_redefinir].coin);
    bitbtn10.Caption:=nombre_boton(defkeys[indice_redefinir].but1);
    bitbtn24.Caption:=nombre_boton(defkeys[indice_redefinir].start);
    bitbtn9.Caption:=nombre_boton(defkeys[indice_redefinir].but0);
    bitbtn11.Caption:=nombre_boton(defkeys[indice_redefinir].but2);
    bitbtn17.Caption:=nombre_boton(defkeys[indice_redefinir].but3);
    bitbtn15.Caption:=nombre_boton(defkeys[indice_redefinir].but4);
    bitbtn16.Caption:=nombre_boton(defkeys[indice_redefinir].but5);
  end;
end;

end.
