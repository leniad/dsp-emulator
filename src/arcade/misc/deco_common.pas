unit deco_common;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}gfx_engine,ym_2203,ym_2151,oki6295,hu6280,
     main_engine;

var
 deco_sprite_ram:array[0..$3ff] of word;
 deco16_global_x_size,deco16_sprite_color_add,deco16_sprite_mask:word;
 deco16_sound_latch:byte;
 snd_ram:array[0..$1fff] of byte;

//Sprites
procedure deco16_sprites;
procedure deco16_sprites_pri(pri:byte);
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

//sprites
procedure deco16_sprites;
var
  f,color:byte;
  y,x,nchar:word;
  fx,fy:boolean;
  multi,inc,mult:integer;
begin
for f:=0 to $ff do begin
			nchar:=deco_sprite_ram[(f*4)+1];
			y:=deco_sprite_ram[(f*4)+0];
      if (((y and $1000)<>0) and ((main_vars.frames_sec and 1)<>0)) then continue;
      x:=deco_sprite_ram[(f*4)+2];
      color:=(x shr 9) and $1f;
      fx:=(y and $2000)<>0;
      fy:=(y and $4000)<>0;
      multi:=(1 shl ((y and $0600) shr 9))-1;
      x:=(304-x) and $1ff;
      y:=(240-y) and $1ff;
			nchar:=(nchar and not(multi)) and deco16_sprite_mask;
      if fy then inc:=-1
        else begin
						nchar:=nchar+multi;
						inc:=1;
        end;
      mult:=-16;
      while (multi>=0) do begin
        if nchar<>0 then begin
          put_gfx_sprite(nchar-multi*inc,(color shl 4)+deco16_sprite_color_add,fx,fy,2);
          actualiza_gfx_sprite(x,y+mult*multi,3,2);
        end;
        multi:=multi-1;
      end;
end;
end;

procedure deco16_sprites_pri(pri:byte);
var
  f,color:byte;
  y,x,nchar:word;
  fx,fy:boolean;
  multi,inc,mult:integer;
begin
for f:=0 to $ff do begin
      x:=deco_sprite_ram[(f*4)+2];
      if pri<>((x shr 8) and $c0) then continue;
			nchar:=deco_sprite_ram[(f*4)+1];
			y:=deco_sprite_ram[(f*4)+0];
      if (((y and $1000)<>0) and ((main_vars.frames_sec and 1)<>0)) then continue;
      color:=(x shr 9) and $1f;
      fx:=(y and $2000)<>0;
      fy:=(y and $4000)<>0;
      multi:=(1 shl ((y and $0600) shr 9))-1;	// 1x, 2x, 4x, 8x height
      x:=(deco16_global_x_size-x) and $1ff;
      y:=(240-y) and $1ff;
			nchar:=(nchar and not(multi)) and deco16_sprite_mask;
      if fy then inc:=-1
        else begin
						nchar:=nchar+multi;
						inc:=1;
        end;
      mult:=-16;
      while (multi>=0) do begin
        if nchar<>0 then begin
          put_gfx_sprite(nchar-multi*inc,(color shl 4)+deco16_sprite_color_add,fx,fy,3);
          actualiza_gfx_sprite(x,y+mult*multi,5,3);
        end;
        multi:=multi-1;
      end;
end;
end;

//Sound
procedure deco16_snd_double_init(cpu_clock,sound_clock:dword;sound_bank:cpu_outport_call);
begin
main_h6280:=cpu_h6280.create(cpu_clock,$100);
main_h6280.change_ram_calls(deco16_double_snd_getbyte,deco16_double_snd_putbyte);
main_h6280.init_sound(deco16_double_sound);
ym2203_0:=ym2203_chip.create(sound_clock div 8);
ym2151_0:=ym2151_chip.create(sound_clock div 9);
ym2151_0.change_port_func(sound_bank);
ym2151_0.change_irq_func(deco16_snd_irq);
oki_6295_0:=snd_okim6295.Create(sound_clock div 32,OKIM6295_PIN7_HIGH,2);
oki_6295_1:=snd_okim6295.Create(sound_clock div 16,OKIM6295_PIN7_HIGH,2);
end;

procedure deco16_snd_double_reset;
begin
  main_h6280.reset;
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
if direccion<$10000 then exit;
case direccion of
  $100000:ym2203_0.Control(valor);
  $100001:ym2203_0.Write(valor);
  $110000:ym2151_0.reg(valor);
  $110001:ym2151_0.write(valor);
  $120000..$120001:oki_6295_0.write(valor);
  $130000..$130001:oki_6295_1.write(valor);
  $1f0000..$1f1fff:snd_ram[direccion and $1fff]:=valor;
  $1fec00..$1fec01:main_h6280.timer_w(direccion and $1,valor);
  $1ff400..$1ff403:main_h6280.irq_status_w(direccion and $3,valor);
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
  main_h6280:=cpu_h6280.create(cpu_clock,$100);
  main_h6280.change_ram_calls(deco16_simple_snd_getbyte,deco16_simple_snd_putbyte);
  main_h6280.init_sound(deco16_simple_sound);
  ym2151_0:=ym2151_chip.create(sound_clock div 9);
  ym2151_0.change_port_func(sound_bank);
  ym2151_0.change_irq_func(deco16_snd_irq);
  oki_6295_0:=snd_okim6295.Create(sound_clock div 32,OKIM6295_PIN7_HIGH,2);
end;

procedure deco16_snd_simple_reset;
begin
  main_h6280.reset;
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
if direccion<$10000 then exit;
case direccion of
  $110000:ym2151_0.reg(valor);
  $110001:ym2151_0.write(valor);
  $120000..$120001:oki_6295_0.write(valor);
  $1f0000..$1f1fff:snd_ram[direccion and $1fff]:=valor;
  $1fec00..$1fec01:main_h6280.timer_w(direccion and $1,valor);
  $1ff400..$1ff403:main_h6280.irq_status_w(direccion and $3,valor);
end;
end;

procedure deco16_snd_irq(irqstate:byte);
begin
  if irqstate=1 then main_h6280.set_irq_line(1,ASSERT_LINE)
    else main_h6280.set_irq_line(1,CLEAR_LINE);
end;

procedure deco16_simple_sound;
begin
  ym2151_0.update;
  oki_6295_0.update;
end;

end.
