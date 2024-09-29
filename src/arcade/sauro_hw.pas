unit sauro_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,timer_engine,ym_3812;

function iniciar_sauro:boolean;

implementation
const
        sauro_rom:array[0..1] of tipo_roms=(
        (n:'sauro-2.bin';l:$8000;p:0;crc:$19f8de25),(n:'sauro-1.bin';l:$8000;p:$8000;crc:$0f8b876f));
        sauro_snd_rom:tipo_roms=(n:'sauro-3.bin';l:$8000;p:0;crc:$0d501e1b);
        sauro_pal:array[0..2] of tipo_roms=(
        (n:'82s137-3.bin';l:$400;p:0;crc:$d52c4cd0),(n:'82s137-2.bin';l:$400;p:$400;crc:$c3e96d5d),
        (n:'82s137-1.bin';l:$400;p:$800;crc:$bdfcf00c));
        sauro_char_bg:array[0..1] of tipo_roms=(
        (n:'sauro-6.bin';l:$8000;p:0;crc:$4b77cb0f),(n:'sauro-7.bin';l:$8000;p:$8000;crc:$187da060));
        sauro_char_fg:array[0..1] of tipo_roms=(
        (n:'sauro-4.bin';l:$8000;p:0;crc:$9b617cda),(n:'sauro-5.bin';l:$8000;p:$8000;crc:$a6e2640d));
        sauro_sprites:array[0..3] of tipo_roms=(
        (n:'sauro-8.bin';l:$8000;p:0;crc:$e08b5d5e),(n:'sauro-9.bin';l:$8000;p:$8000;crc:$7c707195),
        (n:'sauro-10.bin';l:$8000;p:$10000;crc:$c93380d1),(n:'sauro-11.bin';l:$8000;p:$18000;crc:$f47982a8));
        //DIP
        sauro_dip_a:array [0..6] of def_dip2=(
        (mask:2;name:'Demo Sounds';number:2;val2:(0,2);name2:('Off','On')),
        (mask:4;name:'Cabinet';number:2;val2:(4,0);name2:('Upright','Cocktail')),
        (mask:8;name:'Free Play';number:2;val2:(0,8);name2:('Off','On')),
        (mask:$30;name:'Difficult';number:4;val4:($30,$20,$10,0);name4:('Very Easy','Easy','Hard','Very Hard')),
        (mask:$40;name:'Allow Continue';number:2;val2:(0,$40);name2:('No','Yes')),
        (mask:$80;name:'Freeze';number:2;val2:(0,$80);name2:('Off','On')),());
        sauro_dip_b:array [0..3] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(0,1,2,3);name4:('4C 1C','3C 1C','2C 1C','1C 1C')),
        (mask:$c;name:'Coin B';number:4;val4:($c,8,4,0);name4:('1C 2C','1C 3C','1C 4C','1C 5C')),
        (mask:$30;name:'Lives';number:4;val4:($30,$20,$10,0);name4:('2','3','4','5')),());

var
 scroll_bg,scroll_fg,sound_latch,pal_bank:byte;

procedure update_video_sauro;
var
  f,color,nchar,x,y:word;
  attr:byte;
begin
for f:=0 to $3ff do begin
  //bg
  if gfx[0].buffer[f] then begin
      x:=f div 32;
      y:=f mod 32;
      attr:=memoria[$f400+f];
      nchar:=memoria[$f000+f]+((attr and 7) shl 8);
      color:=((attr shr 4) and $f) or pal_bank;
      put_gfx_flip(x*8,y*8,nchar,color shl 4,1,0,(attr and 8)<>0,false);
      gfx[0].buffer[f]:=false;
  end;
  //fg
  if gfx[1].buffer[f] then begin
    x:=f div 32;
    y:=f mod 32;
    attr:=memoria[f+$fc00];
    color:=((attr shr 4) and $f) or pal_bank;
    nchar:=memoria[f+$f800]+((attr and 7) shl 8);
    put_gfx_trans_flip(x*8,y*8,nchar,color shl 4,2,1,(attr and 8)<>0,false);
    gfx[1].buffer[f]:=false;
  end;
end;
scroll__x(1,3,scroll_bg);
scroll__x(2,3,scroll_fg);
//sprites
for f:=0 to $fe do begin
    y:=memoria[$e803+(f*4)];
    if y=$f8 then continue;
    attr:=memoria[$e803+(f*4)+3];
    nchar:=memoria[$e803+(f*4)+1]+((attr and 3) shl 8);
		x:=memoria[$e803+(f*4)+2];
		y:=236-y;
		color:=((attr shr 4) and $f) or pal_bank;
		// I'm not really sure how this bit works
		if (attr and 8)<>0 then begin
			if (x>$c0) then x:=x+256;
		end else if (x<$40) then continue;
		put_gfx_sprite(nchar,color shl 4,(attr and 4)<>0,false,2);
    actualiza_gfx_sprite(x,y,3,2);
end;
actualiza_trozo_final(8,16,240,224,3);
end;

procedure eventos_sauro;
begin
if event.arcade then begin
  //P1
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or $40) else marcade.in0:=(marcade.in0 and $bf);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or $80) else marcade.in0:=(marcade.in0 and $7f);
  //P2
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or $40) else marcade.in1:=(marcade.in1 and $bf);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or $80) else marcade.in1:=(marcade.in1 and $7f);
end;
end;

procedure sauro_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    if f=240 then begin
      z80_0.change_irq(HOLD_LINE);
      update_video_sauro;
    end;
    //main
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //snd
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
  end;
  eventos_sauro;
  video_sync;
end;
end;

function sauro_getbyte(direccion:word):byte;
begin
sauro_getbyte:=memoria[direccion];
end;

procedure sauro_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$dfff:; //ROM
   $e000..$ebff:memoria[direccion]:=valor; //NVRAM + Sprite ram
   $f000..$f7ff:if memoria[direccion]<>valor then begin
                     memoria[direccion]:=valor;
                     gfx[0].buffer[direccion and $3ff]:=true;
                end;
   $f800..$ffff:if memoria[direccion]<>valor then begin
                     memoria[direccion]:=valor;
                     gfx[1].buffer[direccion and $3ff]:=true;
                end;
end;
end;

function sauro_inbyte(port:word):byte;
begin
case (port and $ff) of
    0:sauro_inbyte:=marcade.dswa;
    $20:sauro_inbyte:=marcade.dswb;
    $40:sauro_inbyte:=marcade.in0;
    $60:sauro_inbyte:=marcade.in1;
end;
end;

procedure sauro_outbyte(port:word;valor:byte);
const
  scroll_map:array[0..7] of byte=(2,1,4,3,6,5,0,7);
  scroll_map_flip:array[0..7] of byte=(0,7,2,1,4,3,6,5);
begin
case (port and $ff) of
     $80:sound_latch:=$80 or valor;
     $a0:scroll_bg:=valor;
     $a1:if main_screen.flip_main_screen then scroll_fg:=(valor and $f8) or scroll_map_flip[valor and 7]
            else scroll_fg:=(valor and $f8) or scroll_map[valor and 7] ;
     $c0:main_screen.flip_main_screen:=(valor<>0);
     $ca..$cb:if pal_bank<>((valor and 3) shl 4) then begin
                pal_bank:=(valor and 3) shl 4;
                fillchar(gfx[0].buffer,$400,1);
                fillchar(gfx[1].buffer,$400,1);
              end;
end;
end;

function sauro_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:sauro_snd_getbyte:=mem_snd[direccion];
  $e000:begin
             sauro_snd_getbyte:=sound_latch;
             sound_latch:=0;
        end;
end;
end;

procedure sauro_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$87ff:mem_snd[direccion]:=valor;
  $a000:; //adpcm
  $c000:ym3812_0.control(valor);
  $c001:ym3812_0.write(valor);
end;
end;

procedure sauro_sound_update;
begin
 ym3812_0.update;
end;

procedure sauro_snd_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

//Main
procedure reset_sauro;
begin
 z80_0.reset;
 z80_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 ym3812_0.reset;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 scroll_bg:=0;
 scroll_fg:=0;
 sound_latch:=0;
 pal_bank:=0;
end;

function iniciar_sauro:boolean;
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$1ffff] of byte;
const
    pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
    pc_y:array[0..7] of dword=(0*4*8, 1*4*8, 2*4*8, 3*4*8, 4*4*8, 5*4*8, 6*4*8, 7*4*8);
    ps_x:array[0..15] of dword=(1*4, 0*4, 3*4, 2*4, 5*4, 4*4, 7*4, 6*4, 9*4, 8*4, 11*4, 10*4, 13*4, 12*4, 15*4, 14*4);
    ps_y:array[0..15] of dword=($18000*8+0*4*16,$10000*8+0*4*16,$8000*8+0*4*16,0+0*4*16,
                                $18000*8+1*4*16,$10000*8+1*4*16,$8000*8+1*4*16,0+1*4*16,
			                          $18000*8+2*4*16,$10000*8+2*4*16,$8000*8+2*4*16,0+2*4*16,
                                $18000*8+3*4*16,$10000*8+3*4*16,$8000*8+3*4*16,0+3*4*16);
begin
llamadas_maquina.bucle_general:=sauro_principal;
llamadas_maquina.reset:=reset_sauro;
llamadas_maquina.fps_max:=55.72;
iniciar_sauro:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256,true);
screen_mod_scroll(2,256,256,255,256,256,255);
screen_init(3,512,256,false,true);
iniciar_video(240,224);
//Main CPU
z80_0:=cpu_z80.create(5000000,256);
z80_0.change_ram_calls(sauro_getbyte,sauro_putbyte);
z80_0.change_io_calls(sauro_inbyte,sauro_outbyte);
if not(roms_load(@memoria,sauro_rom)) then exit;
//Sound CPU
z80_1:=cpu_z80.create(4000000,256);
z80_1.change_ram_calls(sauro_snd_getbyte,sauro_snd_putbyte);
z80_1.init_sound(sauro_sound_update);
if not(roms_load(@mem_snd,sauro_snd_rom)) then exit;
//IRQ Sound CPU
timers.init(z80_1.numero_cpu,4000000/(8*60),sauro_snd_irq,nil,true);
//Sound Chips
ym3812_0:=ym3812_chip.create(YM3812_FM,2500000);
//convertir chars
if not(roms_load(@memoria_temp,sauro_char_bg)) then exit;
init_gfx(0,8,8,2048);
gfx_set_desc_data(4,0,8*8*4,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
if not(roms_load(@memoria_temp,sauro_char_fg)) then exit;
init_gfx(1,8,8,2048);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,8*8*4,0,1,2,3);
convert_gfx(1,0,@memoria_temp,@pc_x,@pc_y,false,false);
//convertir sprites
if not(roms_load(@memoria_temp,sauro_sprites)) then exit;
init_gfx(2,16,16,1024);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,16*16,0,1,2,3);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
//poner la paleta
if not(roms_load(@memoria_temp,sauro_pal)) then exit;
for f:=0 to $3ff do begin
  colores[f].r:=pal4bit(memoria_temp[f]);
  colores[f].g:=pal4bit(memoria_temp[f+$400]);
  colores[f].b:=pal4bit(memoria_temp[f+$800]);
end;
set_pal(colores,$400);
//DIP
marcade.dswa:=$66;
marcade.dswb:=$2f;
marcade.dswa_val2:=@sauro_dip_a;
marcade.dswb_val2:=@sauro_dip_b;
//final
reset_sauro;
iniciar_sauro:=true;
end;

end.
