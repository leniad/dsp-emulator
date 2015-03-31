unit konami_snd;

interface
uses ay_8910,sound_engine,main_engine,nz80;

type
  tkonami_call=function(valor:byte):byte;
  tksound=record
    sound_latch,frame,tipo:byte;
    last_cycles,clock:integer;
    call:tkonami_call;
  end;
const
  ONE_AY8910=0;
  TWO_AY8910=1;

var
  konami_sound:tksound;

function konamisnd_porta:byte;
function konamisnd_portb:byte;
function konamisnd_getbyte(direccion:word):byte;
procedure konamisnd_putbyte(direccion:word;valor:byte);
procedure konamisnd_2ay;
procedure konamisnd_1ay;
procedure konamisnd_init(amp,cpu,ntipo:byte;clock:integer;call:tkonami_call);
procedure konamisnd_reset;
procedure konamisnd_close;

implementation

function konamisnd_porta:byte;
begin
  konamisnd_porta:=konami_sound.sound_latch;
end;

function konamisnd_portb:byte;
const reloj:array[0..9] of byte=(0,$10,$20,$30,$40,$90,$a0,$b0,$a0,$d0);
var
  current_totalcycles:integer;
  res:byte;
begin
current_totalcycles:=snd_z80.contador+round(konami_sound.frame*snd_z80.tframes);
konami_sound.clock:=(konami_sound.clock+(current_totalcycles-konami_sound.last_cycles));
konami_sound.last_cycles:=current_totalcycles;
res:=reloj[(konami_sound.clock div 512) mod 10];
if @konami_sound.call<>nil then res:=konami_sound.call(res);
konamisnd_portb:=res;
end;

function konamisnd_getbyte(direccion:word):byte;
begin
case direccion of
  $4000:konamisnd_getbyte:=ay8910_0.Read;
  $6000:konamisnd_getbyte:=ay8910_1.Read;
    else konamisnd_getbyte:=mem_snd[direccion];
end;
end;

procedure konamisnd_putbyte(direccion:word;valor:byte);
begin
if direccion<$2000 then exit;
case direccion of
        $4000:ay8910_0.Write(valor);
        $5000:ay8910_0.Control(valor);
        $6000:ay8910_1.Write(valor);
        $7000:ay8910_1.Control(valor);
end;
mem_snd[direccion]:=valor;
end;

procedure konamisnd_2ay;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

procedure konamisnd_1ay;
begin
  ay8910_0.update;
end;

procedure konamisnd_init(amp,cpu,ntipo:byte;clock:integer;call:tkonami_call);
begin
konami_sound.call:=call;
konami_sound.tipo:=ntipo;
case konami_sound.tipo of
  ONE_AY8910:begin
      sound_engine_init(cpu,clock,konamisnd_1ay);
      ay8910_0:=ay8910_chip.create(1789772,amp);
      ay8910_0.change_io_calls(konamisnd_porta,konamisnd_portb,nil,nil);
    end;
  TWO_AY8910:begin
      sound_engine_init(cpu,clock,konamisnd_2ay);
      ay8910_0:=ay8910_chip.create(1789772,amp);
      ay8910_0.change_io_calls(konamisnd_porta,konamisnd_portb,nil,nil);
      ay8910_1:=ay8910_chip.create(1789772,amp);
    end;
end;
end;

procedure konamisnd_reset;
begin
ay8910_0.reset;
if konami_sound.tipo=TWO_AY8910 then ay8910_1.reset;
konami_sound.sound_latch:=0;
konami_sound.frame:=0;
konami_sound.clock:=0;
konami_sound.last_cycles:=0;
end;

procedure konamisnd_close;
begin
ay8910_0.Free;
if konami_sound.tipo=TWO_AY8910 then ay8910_1.Free;
end;

end.
