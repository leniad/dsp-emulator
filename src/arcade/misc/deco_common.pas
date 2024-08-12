unit deco_common;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}gfx_engine,ym_2203,ym_2151,oki6295,hu6280,
     cpu_misc,main_engine;

type
  tdeco16_sprite=class
    constructor create(gfx,pant:byte;global_x_size,color_add,mask:word);
    destructor free;
    public
      ram:array[0..$3ff] of word;
      procedure draw_sprites(pri:byte=0);
      procedure reset;
    private
      global_x_size,color_add,mask:word;
      gfx,pant:byte;
  end;

var
 deco16_sound_latch:byte;
 snd_ram:array[0..$1fff] of byte;
 oki_rom:array[0..1,0..$3ffff] of byte;
 deco_sprites_0:tdeco16_sprite;

//Sound
procedure deco16_snd_simple_init(cpu_clock,sound_clock:dword;sound_bank:cpu_outport_call);
procedure deco16_snd_simple_reset;
function deco16_simple_snd_getbyte(direccion:dword):byte;
procedure deco16_simple_snd_putbyte(direccion:dword;valor:byte);
procedure deco16_simple_sound;
procedure deco16_snd_double_init(cpu_clock,sound_clock:dword;sound_bank:cpu_outport_call);
procedure deco16_snd_double_reset;
function deco16_double_snd_getbyte(direccion:dword):byte;
procedure deco16_double_snd_putbyte(direccion:dword;valor:byte);
procedure deco16_double_sound;
procedure deco16_snd_irq(irqstate:byte);

implementation

constructor tdeco16_sprite.create(gfx,pant:byte;global_x_size,color_add,mask:word);
begin
  self.global_x_size:=global_x_size;
  self.color_add:=color_add;
  self.mask:=mask;
  self.gfx:=gfx;
  self.pant:=pant;
end;

destructor tdeco16_sprite.free;
begin
end;

procedure tdeco16_sprite.reset;
begin
  fillchar(self.ram,$400*2,0);
end;

procedure tdeco16_sprite.draw_sprites(pri:byte=0);
var
  f,color:byte;
  y,x,nchar:word;
  fx,fy:boolean;
  multi,inc,mult:integer;
begin
for f:=0 to $ff do begin
      x:=self.ram[(f*4)+2];
      if pri<>((x shr 8) and $c0) then continue;
			y:=self.ram[(f*4)+0];
      if (((y and $1000)<>0) and ((main_vars.frames_sec and 1)<>0)) then continue;
      color:=(x shr 9) and $1f;
      fx:=(y and $2000)<>0;
      fy:=(y and $4000)<>0;
      multi:=(1 shl ((y and $0600) shr 9))-1;	// 1x, 2x, 4x, 8x height
      x:=(self.global_x_size-x) and $1ff;
      y:=(240-y) and $1ff;
			nchar:=(self.ram[(f*4)+1] and not(multi)) and self.mask;
      if fy then inc:=-1
        else begin
						nchar:=nchar+multi;
						inc:=1;
        end;
      mult:=-16;
      while (multi>=0) do begin
        if nchar<>0 then begin
          put_gfx_sprite(nchar-multi*inc,(color shl 4)+self.color_add,fx,fy,self.gfx);
          actualiza_gfx_sprite(x,y+mult*multi,self.pant,self.gfx);
        end;
        multi:=multi-1;
      end;
end;
end;

//Sound
procedure deco16_snd_double_init(cpu_clock,sound_clock:dword;sound_bank:cpu_outport_call);
begin
h6280_0:=cpu_h6280.create(cpu_clock,$100);
h6280_0.change_ram_calls(deco16_double_snd_getbyte,deco16_double_snd_putbyte);
h6280_0.init_sound(deco16_double_sound);
ym2203_0:=ym2203_chip.create(sound_clock div 8);
ym2151_0:=ym2151_chip.create(sound_clock div 9);
ym2151_0.change_port_func(sound_bank);
ym2151_0.change_irq_func(deco16_snd_irq);
oki_6295_0:=snd_okim6295.Create(sound_clock div 32,OKIM6295_PIN7_HIGH,2);
oki_6295_1:=snd_okim6295.Create(sound_clock div 16,OKIM6295_PIN7_HIGH,2);
end;

procedure deco16_snd_double_reset;
begin
  h6280_0.reset;
  ym2203_0.reset;
  ym2151_0.reset;
  oki_6295_0.reset;
  oki_6295_1.reset;
  deco16_sound_latch:=0;
end;

function deco16_double_snd_getbyte(direccion:dword):byte;
begin
case direccion of
  0..$ffff:deco16_double_snd_getbyte:=mem_snd[direccion];
  $100000:deco16_double_snd_getbyte:=ym2203_0.status;
  $100001:deco16_double_snd_getbyte:=ym2203_0.Read;
  $110001:deco16_double_snd_getbyte:=ym2151_0.status;
  $120000..$120001:deco16_double_snd_getbyte:=oki_6295_0.read;
  $130000..$130001:deco16_double_snd_getbyte:=oki_6295_1.read;
  $140000..$140001:deco16_double_snd_getbyte:=deco16_sound_latch;
  $1f0000..$1f1fff:deco16_double_snd_getbyte:=snd_ram[direccion and $1fff];
end;
end;

procedure deco16_double_snd_putbyte(direccion:dword;valor:byte);
begin
case direccion of
  0..$ffff:; //ROM
  $100000:ym2203_0.control(valor);
  $100001:ym2203_0.write(valor);
  $110000:ym2151_0.reg(valor);
  $110001:ym2151_0.write(valor);
  $120000..$120001:oki_6295_0.write(valor);
  $130000..$130001:oki_6295_1.write(valor);
  $1f0000..$1f1fff:snd_ram[direccion and $1fff]:=valor;
  $1fec00..$1fec01:h6280_0.timer_w(direccion and $1,valor);
  $1ff400..$1ff403:h6280_0.irq_status_w(direccion and $3,valor);
end;
end;

procedure deco16_double_sound;
begin
  ym2151_0.update;
  ym2203_0.Update;
  oki_6295_0.update;
  oki_6295_1.update;
end;

procedure deco16_snd_simple_init(cpu_clock,sound_clock:dword;sound_bank:cpu_outport_call);
begin
  h6280_0:=cpu_h6280.create(cpu_clock,$100);
  h6280_0.change_ram_calls(deco16_simple_snd_getbyte,deco16_simple_snd_putbyte);
  h6280_0.init_sound(deco16_simple_sound);
  ym2151_0:=ym2151_chip.create(sound_clock div 9);
  ym2151_0.change_port_func(sound_bank);
  ym2151_0.change_irq_func(deco16_snd_irq);
  oki_6295_0:=snd_okim6295.Create(sound_clock div 32,OKIM6295_PIN7_HIGH,1);
end;

procedure deco16_snd_simple_reset;
begin
  h6280_0.reset;
  ym2151_0.reset;
  oki_6295_0.reset;
  deco16_sound_latch:=0;
end;

function deco16_simple_snd_getbyte(direccion:dword):byte;
begin
case direccion of
  0..$ffff:deco16_simple_snd_getbyte:=mem_snd[direccion];
  $110001:deco16_simple_snd_getbyte:=ym2151_0.status;
  $120000..$120001:deco16_simple_snd_getbyte:=oki_6295_0.read;
  $140000..$140001:deco16_simple_snd_getbyte:=deco16_sound_latch;
  $1f0000..$1f1fff:deco16_simple_snd_getbyte:=snd_ram[direccion and $1fff];
end;
end;

procedure deco16_simple_snd_putbyte(direccion:dword;valor:byte);
begin
case direccion of
  0..$ffff:; //ROM
  $110000:ym2151_0.reg(valor);
  $110001:ym2151_0.write(valor);
  $120000..$120001:oki_6295_0.write(valor);
  $1f0000..$1f1fff:snd_ram[direccion and $1fff]:=valor;
  $1fec00..$1fec01:h6280_0.timer_w(direccion and $1,valor);
  $1ff400..$1ff403:h6280_0.irq_status_w(direccion and $3,valor);
end;
end;

procedure deco16_snd_irq(irqstate:byte);
begin
  h6280_0.set_irq_line(1,irqstate);
end;

procedure deco16_simple_sound;
begin
  ym2151_0.update;
  oki_6295_0.update;
end;

end.
