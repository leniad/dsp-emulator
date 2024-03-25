unit heavyunit_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,mcs51,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     kaneco_pandora,ym_2203,sound_engine,misc_functions;

function iniciar_hvyunit:boolean;

implementation
const
        hvyunit_cpu1:tipo_roms=(n:'b73_10.5c';l:$20000;p:0;crc:$ca52210f);
        hvyunit_cpu2:tipo_roms=(n:'b73_11.5p';l:$10000;p:0;crc:$cb451695);
        hvyunit_sound:tipo_roms=(n:'b73_12.7e';l:$10000;p:0;crc:$d1d24fab);
        hvyunit_mermaid:tipo_roms=(n:'mermaid.bin';l:$e00;p:0;crc:$88c5dd27);
        hvyunit_gfx0:array[0..7] of tipo_roms=(
        (n:'b73_08.2f';l:$80000;p:0;crc:$f83dd808),(n:'b73_07.2c';l:$10000;p:$100000;crc:$5cffa42c),
        (n:'b73_06.2b';l:$10000;p:$120000;crc:$a98e4aea),(n:'b73_01.1b';l:$10000;p:$140000;crc:$3a8a4489),
        (n:'b73_02.1c';l:$10000;p:$160000;crc:$025c536c),(n:'b73_03.1d';l:$10000;p:$180000;crc:$ec6020cf),
        (n:'b73_04.1f';l:$10000;p:$1a0000;crc:$f7badbb2),(n:'b73_05.1h';l:$10000;p:$1c0000;crc:$b8e829d2));
        hvyunit_gfx1:tipo_roms=(n:'b73_09.2p';l:$80000;p:0;crc:$537c647f);
        //Dip
        hvyunit_dip_a:array [0..6] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Flip_Screen';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Service Mode';number:2;dip:((dip_val:$0;dip_name:'On'),(dip_val:$4;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Coin Mode';number:2;dip:((dip_val:$8;dip_name:'Mode 1'),(dip_val:$0;dip_name:'Mode 2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'1C 6C(Mode 1)/1C 4C(Mode 2)'),(dip_val:$10;dip_name:'1C 2C(Mode 1)/1C 3C(Mode 2)'),(dip_val:$20;dip_name:'2C 1C'),(dip_val:$30;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Coin B';number:4;dip:((dip_val:$40;dip_name:'1C 2(Mode 1)/1C 3C(Mode 2)'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$c0;dip_name:'1C 1C'),(dip_val:$0;dip_name:'1C 6C(Mode 1)/1C 4C(Mode 2)'),(),(),(),(),(),(),(),(),(),(),(),())),());
        hvyunit_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Difficulty';number:4;dip:((dip_val:$2;dip_name:'Easy'),(dip_val:$3;dip_name:'Normal'),(dip_val:$1;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$4;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Bonus';number:2;dip:((dip_val:$8;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'7'),(dip_val:$10;dip_name:'5'),(dip_val:$20;dip_name:'4'),(dip_val:$30;dip_name:'3'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$40;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 sound_latch,nrom_cpu1,nrom_cpu2,nrom_cpu3,scroll_port,scroll_x,scroll_y:byte;
 rom_cpu1:array[0..7,0..$3fff] of byte;
 rom_cpu2,rom_cpu3:array[0..3,0..$3fff] of byte;
 //mermaid
 mermaidlatch,slavelatch:byte;
 slavelatch_data,mermaidlatch_data:boolean;
 mermaid_p:array[0..3] of byte;

procedure update_video_hvyunit;
var
  f,nchar:word;
  color,x,y,atrib:byte;
begin
//background
for f:=0 to $3ff do begin
  atrib:=mem_misc[$c400+f];
  color:=atrib shr 4;
  if (gfx[1].buffer[f] or buffer_color[color]) then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=mem_misc[$c000+f]+((atrib and $f) shl 8);
      put_gfx(x*16,y*16,nchar,color shl 4,1,1);
      gfx[1].buffer[f]:=false;
  end;
end;
scroll_x_y(1,2,scroll_x+((scroll_port and $40) shl 2)+96,scroll_y+((scroll_port and $80) shl 1));
pandora_0.update_video(2,0);
//Prioridad de los chars
actualiza_trozo_final(0,16,256,224,2);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_hvyunit;
begin
if event.arcade then begin
  //marcade.in0
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  //marcade.in1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //marcade.in2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
end;
end;

procedure hvyunit_principal;
var
  frame_m,frame_s,frame_m2,frame_mcu:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_m2:=z80_1.tframes;
frame_s:=z80_2.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
  //CPU 1
  z80_0.run(frame_m);
  frame_m:=frame_m+z80_0.tframes-z80_0.contador;
  //CPU 2
  z80_1.run(frame_m2);
  frame_m2:=frame_m2+z80_1.tframes-z80_1.contador;
  //CPU Sound
  z80_2.run(frame_s);
  frame_s:=frame_s+z80_2.tframes-z80_2.contador;
  //MCU
  mcs51_0.run(frame_mcu);
  frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
  case f of
    63:begin
         z80_0.im2_lo:=$ff;
         z80_0.change_irq(HOLD_LINE);
       end;
    239:begin
         z80_0.im2_lo:=$fd;
         z80_0.change_irq(HOLD_LINE);
         z80_1.change_irq(HOLD_LINE);
         update_video_hvyunit;
        end;
  end;
 end;
 eventos_hvyunit;
 video_sync;
end;
end;

function hvyunit_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff:hvyunit_getbyte:=rom_cpu1[0,direccion];
  $4000..$7fff:hvyunit_getbyte:=rom_cpu1[1,direccion and $3fff];
  $8000..$bfff:hvyunit_getbyte:=rom_cpu1[nrom_cpu1,direccion and $3fff];
  $c000..$cfff:hvyunit_getbyte:=pandora_0.spriteram_r8(direccion and $fff);
  $d000..$ffff:hvyunit_getbyte:=memoria[direccion];
end;
end;

procedure hvyunit_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:;
  $c000..$cfff:pandora_0.spriteram_w8((direccion and $fff),valor);
  $d000..$ffff:memoria[direccion]:=valor;
end;
end;

procedure hvyunit_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0,1:nrom_cpu1:=valor and $7;
  2:z80_1.change_nmi(PULSE_LINE);
end;
end;

function hvyunit_misc_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff:hvyunit_misc_getbyte:=rom_cpu2[0,direccion];
  $4000..$7fff:hvyunit_misc_getbyte:=rom_cpu2[1,direccion and $3fff];
  $8000..$bfff:hvyunit_misc_getbyte:=rom_cpu2[nrom_cpu2,direccion and $3fff];
  $c000..$cfff:hvyunit_misc_getbyte:=mem_misc[direccion];
  $d000..$d1ff:hvyunit_misc_getbyte:=buffer_paleta[direccion and $1ff];
  $d200..$d7ff,$da00..$dfff:hvyunit_misc_getbyte:=mem_misc[direccion];
  $d800..$d9ff:hvyunit_misc_getbyte:=buffer_paleta[(direccion and $1ff)+$200];
  $e000..$ffff:hvyunit_misc_getbyte:=memoria[direccion];
end;
end;

procedure hvyunit_misc_putbyte(direccion:word;valor:byte);

procedure cambiar_color(dir:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir+$200];
  color.g:=pal4bit(tmp_color shr 4);
  color.b:=pal4bit(tmp_color);
  set_pal_color(color,dir);
  if dir<$100 then buffer_color[dir shr 4]:=true;
end;

begin
case direccion of
  0..$bfff:;
  $c000..$c7ff:if mem_misc[direccion]<>valor then begin
                  gfx[1].buffer[direccion and $3ff]:=true;
                  mem_misc[direccion]:=valor;
               end;
  $d000..$d1ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                  buffer_paleta[direccion and $1ff]:=valor;
                  cambiar_color(direccion and $1ff);
               end;
  $d200..$d7ff,$da00..$dfff:mem_misc[direccion]:=valor;
  $d800..$d9ff:if buffer_paleta[(direccion and $1ff)+$200]<>valor then begin
                  buffer_paleta[(direccion and $1ff)+$200]:=valor;
                  cambiar_color(direccion and $1ff);
               end;
  $e000..$ffff:memoria[direccion]:=valor;
end;
end;

function hvyunit_misc_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $4:begin
        slavelatch_data:=false;
        hvyunit_misc_inbyte:=slavelatch;
     end;
  $c:hvyunit_misc_inbyte:=(byte(not(slavelatch_data)) shl 2) or (byte(mermaidlatch_data) shl 3);
end;
end;

procedure hvyunit_misc_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $0:begin
      nrom_cpu2:=valor and $3;
      scroll_port:=valor;
     end;
  $2:begin
      z80_2.change_nmi(PULSE_LINE);
      sound_latch:=valor;
     end;
  $4:begin
      mermaidlatch:=valor;
      mermaidlatch_data:=true;
      mcs51_0.change_irq0(ASSERT_LINE);
     end;
  $6:scroll_y:=valor;
  $8:scroll_x:=valor;
end;
end;

function snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$3fff:snd_getbyte:=rom_cpu3[0,direccion];
  $4000..$7fff:snd_getbyte:=rom_cpu3[1,direccion and $3fff];
  $8000..$bfff:snd_getbyte:=rom_cpu3[nrom_cpu3,direccion and $3fff];
  $c000..$c7ff:snd_getbyte:=mem_snd[direccion];
end;
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$bfff then mem_snd[direccion]:=valor;
end;

function snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $2:snd_inbyte:=ym2203_0.status;
  $3:snd_inbyte:=ym2203_0.Read;
  $4:snd_inbyte:=sound_latch;
end;
end;

procedure snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
    $0:nrom_cpu3:=valor and $3;
    $2:ym2203_0.Control(valor);
    $3:ym2203_0.Write(valor);
end;
end;

function mcu_in_port0:byte;
begin
  mcu_in_port0:=0;
end;

procedure mcu_out_port0(valor:byte);
begin
  if (((mermaid_p[0] and 2)=0) and ((valor and 2)<>0)) then begin
    slavelatch:=mermaid_p[1];
    slavelatch_data:=true;
  end;
	if (valor and 1)=0 then begin
    mermaid_p[1]:=mermaidlatch;
    mcs51_0.change_irq0(CLEAR_LINE);
    mermaidlatch_data:=false;
  end;
	mermaid_p[0]:=valor;
end;

function mcu_in_port1:byte;
begin
  mcu_in_port1:=mermaid_p[1];
end;

procedure mcu_out_port1(valor:byte);
begin
	mermaid_p[1]:=valor;
end;

function mcu_in_port2:byte;
begin
  case ((mermaid_p[0] shr 2) and 3) of
		0:mcu_in_port2:=marcade.in1;
		1:mcu_in_port2:=marcade.in2;
		2:mcu_in_port2:=marcade.in0;
    3:mcu_in_port2:=$ff;
  end;
end;

procedure mcu_out_port2(valor:byte);
begin
  mermaid_p[2]:=valor;
end;

function mcu_in_port3:byte;
var
  dsw:byte;
begin
	case ((mermaid_p[0] shr 5) and 3) of
		0:dsw:=(BIT_n(marcade.dswb,4) shl 3) or (BIT_n(marcade.dswb,0) shl 2) or (BIT_n(marcade.dswa,4) shl 1) or BIT_n(marcade.dswa,0);
		1:dsw:=(BIT_n(marcade.dswb,5) shl 3) or (BIT_n(marcade.dswb,1) shl 2) or (BIT_n(marcade.dswa,5) shl 1) or BIT_n(marcade.dswa,1);
		2:dsw:=(BIT_n(marcade.dswb,6) shl 3) or (BIT_n(marcade.dswb,2) shl 2) or (BIT_n(marcade.dswa,6) shl 1) or BIT_n(marcade.dswa,2);
		3:dsw:=(BIT_n(marcade.dswb,7) shl 3) or (BIT_n(marcade.dswb,3) shl 2) or (BIT_n(marcade.dswa,7) shl 1) or BIT_n(marcade.dswa,3);
	end;
	mcu_in_port3:=(dsw shl 4) or (byte(slavelatch_data) shl 3) or (byte(not(mermaidlatch_data)) shl 2);
end;

procedure mcu_out_port3(valor:byte);
begin
  mermaid_p[3]:=valor;
  if (valor and $2)<>0 then z80_1.change_reset(CLEAR_LINE)
    else z80_1.change_reset(ASSERT_LINE);
end;

procedure hvyunit_sound_irq(state:byte);
begin
  z80_2.change_irq(state);
end;

procedure hvyunit_sound_update;
begin
  ym2203_0.Update;
end;

//Main
procedure reset_hvyunit;
begin
 z80_0.reset;
 z80_0.im2_lo:=$ff;
 z80_1.reset;
 z80_2.reset;
 mcs51_0.reset;
 pandora_0.reset;
 ym2203_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 sound_latch:=0;
 nrom_cpu1:=0;
 nrom_cpu2:=0;
 nrom_cpu3:=0;
 scroll_port:=0;
 scroll_x:=0;
 scroll_y:=0;
 //mermaid
 mermaidlatch_data:=false;
 slavelatch:=0;
 mermaidlatch:=0;
 slavelatch_data:=false;
end;

function iniciar_hvyunit:boolean;
const
  pg_x:array[0..15] of dword=(0*4,1*4,2*4,3*4,4*4,5*4,6*4,7*4,
		8*32+0*4,8*32+1*4,8*32+2*4,8*32+3*4,8*32+4*4,8*32+5*4,8*32+6*4,8*32+7*4);
  pg_y:array[0..15] of dword=(0*32,1*32,2*32,3*32,4*32,5*32,6*32,7*32,
   16*32+0*32,16*32+1*32,16*32+2*32,16*32+3*32,16*32+4*32,16*32+5*32,16*32+6*32,16*32+7*32);
var
  memoria_temp:array[0..$1ffff] of byte;
  ptemp:pbyte;
  f:word;
begin
llamadas_maquina.bucle_general:=hvyunit_principal;
llamadas_maquina.reset:=reset_hvyunit;
llamadas_maquina.fps_max:=58;
iniciar_hvyunit:=false;
iniciar_audio(false);
screen_init(1,512,512);
screen_mod_scroll(1,512,256,511,512,256,511);
screen_init(2,512,512,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(6000000,$100);
z80_0.change_ram_calls(hvyunit_getbyte,hvyunit_putbyte);
z80_0.change_io_calls(nil,hvyunit_outbyte);
//Misc CPU
z80_1:=cpu_z80.create(6000000,$100);
z80_1.change_ram_calls(hvyunit_misc_getbyte,hvyunit_misc_putbyte);
z80_1.change_io_calls(hvyunit_misc_inbyte,hvyunit_misc_outbyte);
//Sound CPU
z80_2:=cpu_z80.create(6000000,$100);
z80_2.change_ram_calls(snd_getbyte,snd_putbyte);
z80_2.change_io_calls(snd_inbyte,snd_outbyte);
z80_2.init_sound(hvyunit_sound_update);
//mcu cpu
mcs51_0:=cpu_mcs51.create(I8X51,6000000,$100);
mcs51_0.change_io_calls(mcu_in_port0,mcu_in_port1,mcu_in_port2,mcu_in_port3,mcu_out_port0,mcu_out_port1,mcu_out_port2,mcu_out_port3);
//pandora
pandora_0:=pandora_gfx.create($3fff,$100,false);
//Sound Chip
ym2203_0:=ym2203_chip.create(3000000,0.8,0.8);
ym2203_0.change_irq_calls(hvyunit_sound_irq);
//cargar roms
if not(roms_load(@memoria_temp,hvyunit_cpu1)) then exit;
for f:=0 to 7 do copymemory(@rom_cpu1[f,0],@memoria_temp[f*$4000],$4000);
//cargar cpu 2
if not(roms_load(@memoria_temp,hvyunit_cpu2)) then exit;
for f:=0 to 3 do copymemory(@rom_cpu2[f,0],@memoria_temp[f*$4000],$4000);
//cargar sonido
if not(roms_load(@memoria_temp,hvyunit_sound)) then exit;
for f:=0 to 3 do copymemory(@rom_cpu3[f,0],@memoria_temp[f*$4000],$4000);
//cargar mermaid
if not(roms_load(mcs51_0.get_rom_addr,hvyunit_mermaid)) then exit;
//convertir chars
getmem(ptemp,$200000);
if not(roms_load(ptemp,hvyunit_gfx0)) then exit;
init_gfx(0,16,16,$4000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,4*8*32,0,1,2,3);
convert_gfx(0,0,ptemp,@pg_x,@pg_y,false,false);
//convertir sprites
if not(roms_load(ptemp,hvyunit_gfx1)) then exit;
init_gfx(1,16,16,$1000);
gfx[1].trans[0]:=true;
convert_gfx(1,0,ptemp,@pg_x,@pg_y,false,false);
freemem(ptemp);
//dip
marcade.dswa:=$fe;
marcade.dswb:=$f7;
marcade.dswa_val:=@hvyunit_dip_a;
marcade.dswb_val:=@hvyunit_dip_b;
//reset
reset_hvyunit;
iniciar_hvyunit:=true;
end;

end.
