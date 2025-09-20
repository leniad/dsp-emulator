unit konami_snd;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}ay_8910,sound_engine,nz80,misc_functions;

type
    konamisnd_chip=class(snd_chip_class)
        constructor create(amp,ntipo:byte;clock:integer;frame_div:word);
        destructor free;
    public
          sound_latch,pedir_irq:byte;
          z80:cpu_z80;
          memoria:array[0..$83ff] of byte;
          procedure reset;
          procedure run(frame:word);
    private
          tipo,frame:byte;
          frame_s:single;
          last_cycles,clock:integer;
          function portb_read:byte;
          function timer(frame:word):byte;
    end;

var
  konamisnd_0:konamisnd_chip;

const
  TIPO_TIMEPLT=0;
  TIPO_JUNGLER=1;
  TIPO_SCRAMBLE=2;
  TIPO_FROGGER=3;

implementation

function konamisnd_timeplt_getbyte(direccion:word):byte;
begin
case direccion of
  0..$2fff:konamisnd_timeplt_getbyte:=konamisnd_0.memoria[direccion];
  $3000..$3fff:konamisnd_timeplt_getbyte:=konamisnd_0.memoria[$3000+(direccion and $3ff)];
  $4000..$4fff:konamisnd_timeplt_getbyte:=ay8910_0.Read;
  $6000..$6fff:konamisnd_timeplt_getbyte:=ay8910_1.Read;
end;
end;

procedure konamisnd_timeplt_putbyte(direccion:word;valor:byte);
begin
if direccion<$3000 then exit;
case direccion of
     $3000..$3fff:konamisnd_0.memoria[$3000+(direccion and $3ff)]:=valor;
     $4000..$4fff:ay8910_0.Write(valor);
     $5000..$5fff:ay8910_0.Control(valor);
     $6000..$6fff:ay8910_1.Write(valor);
     $7000..$7fff:ay8910_1.Control(valor);
     $8000..$ffff:; //filtros
end;
end;

function konamisnd_jungler_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:konamisnd_jungler_getbyte:=konamisnd_0.memoria[direccion];
  $2000..$2fff:konamisnd_jungler_getbyte:=konamisnd_0.memoria[$2000+(direccion and $3ff)];
  $4000..$4fff:konamisnd_jungler_getbyte:=ay8910_0.Read;
  $6000..$6fff:konamisnd_jungler_getbyte:=ay8910_1.Read;
end;
end;

procedure konamisnd_jungler_putbyte(direccion:word;valor:byte);
begin
if direccion<$2000 then exit;
case direccion of
     $2000..$2fff:konamisnd_0.memoria[$2000+(direccion and $3ff)]:=valor;
     $3000..$3fff:; //filtros
     $4000..$4fff:ay8910_0.Write(valor);
     $5000..$5fff:ay8910_0.Control(valor);
     $6000..$6fff:ay8910_1.Write(valor);
     $7000..$7fff:ay8910_1.Control(valor);
end;
end;

function konamisnd_scramble_getbyte(direccion:word):byte;
begin
case direccion of
  0..$2fff:konamisnd_scramble_getbyte:=konamisnd_0.memoria[direccion];
  $8000..$ffff:if (direccion and $1000)=0 then konamisnd_scramble_getbyte:=konamisnd_0.memoria[$8000+(direccion and $3ff)];
end;
end;

procedure konamisnd_scramble_putbyte(direccion:word;valor:byte);
begin
if direccion<$3000 then exit;
if (direccion and $1000)=0 then konamisnd_0.memoria[$8000+(direccion and $3ff)]:=valor
                  else ; //Filtros
end;

function konamisnd_scramble_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$ff;
if (puerto and $20)<>0 then res:=res and ay8910_1.Read;
if (puerto and $80)<>0 then res:=res and ay8910_0.Read;
konamisnd_scramble_inbyte:=res;
end;

procedure konamisnd_scramble_outbyte(puerto:word;valor:byte);
begin
if (puerto and $10)<>0 then ay8910_1.Control(valor)
   else if (puerto and $20)<>0 then ay8910_1.Write(valor);
if (puerto and $40)<>0 then ay8910_0.Control(valor)
   else if (puerto and $80)<>0 then ay8910_0.Write(valor);
end;

function konamisnd_frogger_getbyte(direccion:word):byte;
begin
case (direccion and $7fff) of
  0..$1fff:konamisnd_frogger_getbyte:=konamisnd_0.memoria[direccion];
  $4000..$5fff:konamisnd_frogger_getbyte:=konamisnd_0.memoria[$4000+(direccion and $3ff)];
end;
end;

procedure konamisnd_frogger_putbyte(direccion:word;valor:byte);
begin
if direccion<$2000 then exit;
case (direccion and $7fff) of
  $4000..$5fff:konamisnd_0.memoria[$4000+(direccion and $3ff)]:=valor;
  $6000..$7fff:; //filtros
end;
end;

function konamisnd_frogger_inbyte(puerto:word):byte;
begin
if (puerto and $ff)=$40 then konamisnd_frogger_inbyte:=($ff and ay8910_0.Read);
end;

procedure konamisnd_frogger_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
    $40:ay8910_0.Write(valor);
    $80:ay8910_0.Control(valor);
end;
end;

function konamisnd0_porta:byte;
begin
  konamisnd0_porta:=konamisnd_0.sound_latch;
end;

function konamisnd0_portb:byte;
begin
  konamisnd0_portb:=konamisnd_0.portb_read;
end;

procedure konamisnd_update;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

constructor konamisnd_chip.create(amp,ntipo:byte;clock:integer;frame_div:word);
begin
self.tipo:=ntipo;
self.z80:=cpu_z80.create(clock,frame_div);
self.z80.init_sound(konamisnd_update);
ay8910_0:=ay8910_chip.create(clock,AY8910,amp);
ay8910_0.change_io_calls(konamisnd0_porta,konamisnd0_portb,nil,nil);
ay8910_1:=ay8910_chip.create(clock,AY8910,amp);
self.frame_s:=self.z80.tframes;
case ntipo of
  TIPO_TIMEPLT:self.z80.change_ram_calls(konamisnd_timeplt_getbyte,konamisnd_timeplt_putbyte);
  TIPO_JUNGLER:self.z80.change_ram_calls(konamisnd_jungler_getbyte,konamisnd_jungler_putbyte);
  TIPO_SCRAMBLE:begin
                     self.z80.change_ram_calls(konamisnd_scramble_getbyte,konamisnd_scramble_putbyte);
                     self.z80.change_io_calls(konamisnd_scramble_inbyte,konamisnd_scramble_outbyte);
                end;
  TIPO_FROGGER:begin
                     self.z80.change_ram_calls(konamisnd_frogger_getbyte,konamisnd_frogger_putbyte);
                     self.z80.change_io_calls(konamisnd_frogger_inbyte,konamisnd_frogger_outbyte);
                end;
end;
end;

destructor konamisnd_chip.free;
begin
  self.z80.free;
end;

procedure konamisnd_chip.reset;
begin
self.z80.reset;
ay8910_0.reset;
ay8910_1.reset;
self.sound_latch:=0;
self.frame:=0;
self.clock:=0;
self.last_cycles:=0;
end;

procedure konamisnd_chip.run(frame:word);
begin
self.frame:=frame;
self.z80.change_irq(self.pedir_irq);
self.z80.run(frame_s);
self.frame_s:=self.frame_s+self.z80.tframes-self.z80.contador;
self.pedir_irq:=self.z80.get_irq;
end;

function konamisnd_chip.portb_read:byte;
begin
if self.tipo=TIPO_FROGGER then portb_read:=BITSWAP8(self.timer(self.frame),7,6,3,4,5,2,1,0)
   else portb_read:=self.timer(self.frame);
end;

function konamisnd_chip.timer(frame:word):byte;
var
   cycles:dword;
   hibit:byte;
begin
cycles:=((self.z80.contador+round(frame*self.z80.tframes))*8) mod (16*16*2*8*5*2);
hibit:=0;
// separate the high bit from the others */
if (cycles >= (16*16*2*8*5)) then begin
   hibit:=1;
   cycles:=cycles-16*16*2*8*5;
end;
// the top bits of the counter index map to various bits here */
timer:=(hibit shl 7) or           // B7 is the output of the final divide-by-2 counter */
		(BIT_n(cycles,14) shl 6) or // B6 is the high bit of the divide-by-5 counter */
		(BIT_n(cycles,13) shl 5) or // B5 is the 2nd highest bit of the divide-by-5 counter */
		(BIT_n(cycles,11) shl 4) or // B4 is the high bit of the divide-by-8 counter */
		$0e;                        // assume remaining bits are high, except B0 which is grounded */
end;

end.
