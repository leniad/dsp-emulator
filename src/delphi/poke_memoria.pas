unit poke_memoria;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,spectrum_48k,spectrum_128k,spectrum_3,lenguaje,main_engine;

type
  Tpoke_spec = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Label1: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    procedure FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
    procedure FormShow(Sender:TObject);
    procedure Button2Click(Sender:TObject);
    procedure Button1Click(Sender:TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  poke_spec: Tpoke_spec;
  cadena:string='';
  direccion:word;
  valor:byte;
  posicion:byte=0;

implementation

{$R *.dfm}

procedure Tpoke_spec.FormKeyUp(Sender:TObject;var Key:word;Shift:TShiftState);
var
  f:word;
  p:string;
begin
case key of
  8:if length(cadena)<>0 then begin
      p:='';
      for f:=1 to length(cadena)-1 do p:=p+cadena[f];
      cadena:=p;
    end;
  9:if posicion=0 then begin
      label3.Caption:=cadena;
      posicion:=1;
      if cadena<>'' then direccion:=strtoint(cadena);
      cadena:=label5.Caption;
     end else begin
      label5.Caption:=cadena;
      posicion:=0;
      if cadena<>'' then valor:=strtoint(cadena);
      cadena:=label3.Caption;
    end;
  13:button1click(nil);
  27:button2click(nil);//cancelar
  48..57:if posicion=0 then begin
          if length(cadena)<>5 then cadena:=cadena+chr(key);
         end else if length(cadena)<>3 then cadena:=cadena+chr(key);
end;
if posicion=0 then label3.Caption:=cadena+'<'
  else label5.caption:=cadena+'<';
end;

procedure Tpoke_spec.FormShow(Sender: TObject);
begin
poke_spec.Button2.Caption:=leng[main_vars.idioma].mensajes[8];
poke_spec.ActiveControl:=nil;
cadena:='';
posicion:=0;
direccion:=0;
valor:=0;
label5.Caption:='';
label3.Caption:='<';
end;

procedure Tpoke_spec.Button2Click(Sender: TObject);
begin
poke_spec.close;
end;

procedure Tpoke_spec.Button1Click(Sender: TObject);
begin
if posicion=0 then begin
  poke_spec.ActiveControl:=nil;
  exit;
end;
if cadena<>'' then valor:=strtoint(cadena);
case main_vars.tipo_maquina of
  0:spec48_putbyte(direccion,valor);
  1:spec128_putbyte(direccion,valor);
  2:spec3_putbyte(direccion,valor);
end;
poke_spec.close;
end;

end.
