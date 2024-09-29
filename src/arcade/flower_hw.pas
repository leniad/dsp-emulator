unit flower_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,timer_engine,flower_audio;

function iniciar_flower:boolean;

implementation
const
        flower_rom:tipo_roms=(n:'1.5j';l:$8000;p:0;crc:$a4c3af78);
        flower_rom2:tipo_roms=(n:'2.5f';l:$8000;p:0;crc:$7c7ee2d8);
        flower_rom_snd:tipo_roms=(n:'3.d9';l:$4000;p:0;crc:$8866c2b0);
        flower_char:tipo_roms=(n:'10.13e';l:$2000;p:0;crc:$62f9b28c);
        flower_tiles:array[0..3] of tipo_roms=(
        (n:'8.10e';l:$2000;p:0;crc:$f85eb20f),(n:'6.7e';l:$2000;p:$2000;crc:$3e97843f),
        (n:'9.12e';l:$2000;p:$4000;crc:$f1d9915e),(n:'15.9e';l:$2000;p:$6000;crc:$1cad9f72));
        flower_sprites:array[0..3] of tipo_roms=(
        (n:'14.19e';l:$2000;p:0;crc:$11b491c5),(n:'13.17e';l:$2000;p:$2000;crc:$ea743986),
        (n:'12.16e';l:$2000;p:$4000;crc:$e3779f7f),(n:'11.14e';l:$2000;p:$6000;crc:$8801b34f));
        flower_samples:tipo_roms=(n:'4.12a';l:$8000;p:0;crc:$851ed9fd);
        flower_vol:tipo_roms=(n:'5.16a';l:$4000;p:0;crc:$42fa2853);
        flower_prom:array[0..2] of tipo_roms=(
        (n:'82s129.k3';l:$100;p:0;crc:$5aab7b41),(n:'82s129.k2';l:$100;p:$100;crc:$ababb072),
        (n:'82s129.k1';l:$100;p:$200;crc:$d311ed0d));
        //DIP
        flower_dipa:array [0..5] of def_dip2=(
        (mask:8;name:'Energy Decrease';number:2;val2:(8,0);name2:('Slow','Fast')),
        (mask:$10;name:'Invulnerability';number:2;val2:($10,0);name2:('Off','On')),
        (mask:$20;name:'Keep Weapons When Destroyed';number:2;val2:($20,0);name2:('No','Yes')),
        (mask:$40;name:'Difficulty';number:2;val2:($40,0);name2:('Normal','Hard')),
        (mask:$80;name:'Shot Range';number:2;val2:($80,0);name2:('Short','Long')),());
        flower_dipb:array [0..5] of def_dip2=(
        (mask:7;name:'Lives';number:8;val8:(7,6,5,4,3,6,1,0);name8:('1','2','3','4','5','2','7','Infinite')),
        (mask:$18;name:'Coinage';number:4;val4:(0,8,$18,$10);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
        (mask:$20;name:'Cabinet';number:2;val2:(0,$20);name2:('Upright','Cocktail')),
        (mask:$40;name:'Demo Sounds';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Bonus Life';number:2;val2:($80,0);name2:('30K 50K+','50K 80K+')),());
        CPU_SYNC=4;
        CPU_DIV=5;

var
 sound_latch,scrollfg,scrollbg:byte;
 nmi_audio:boolean;

procedure update_video_flower;
var
  yoffs,xoffs,tile_offs,yi,xi,x_div,y_div,x_size,y_size,atrib,atrib2,atrib3,nchar,color,sx,sy:byte;
  ypixels,xpixels,f,offs,x,y:word;
  flipx,flipy:boolean;
  x_zoom,y_zoom:single;
begin
for x:=0 to 35 do begin
  for y:=0 to 27 do begin
     sx:=29-y;
     sy:=x-2;
     if (sy and $20)<>0 then offs:=sx+((sy and $1f) shl 5)
        else offs:=sy+(sx shl 5);
     if gfx[0].buffer[offs] then begin
        nchar:=memoria[$e000+offs];
        color:=memoria[$e400+offs] and $fc;
        put_gfx_trans(x*8,(27-y)*8,nchar,color,1,0);
        gfx[0].buffer[offs]:=false;
     end;
  end;
end;
for f:=0 to $ff do begin
  x:=f mod 16;
  y:=f div 16;
  if gfx[1].buffer[f] then begin
    nchar:=memoria[$f800+f];
    color:=memoria[$f900+f] and $f0;
    put_gfx(((x*16)+16) and $ff,y*16,nchar,color,2,1);
    gfx[1].buffer[f]:=false;
  end;
  if gfx[1].buffer[f+$100] then begin
    nchar:=memoria[$f000+f];
    color:=memoria[$f100+f] and $f0;
    put_gfx_trans(((x*16)+16) and $ff,y*16,nchar,color,3,1);
    gfx[1].buffer[f+$100]:=false;
  end;
end;
fill_full_screen(4,$400);
scroll__y(2,4,scrollbg+16);
scroll__y(3,4,scrollfg+16);
//Sprites
for f:=$3f downto 0 do begin
    atrib:=memoria[$de08+(f*8)+2];
    atrib2:=memoria[$de08+(f*8)+1];
    atrib3:=memoria[$de08+(f*8)+3];
    nchar:=(atrib2 and $3f) or ((atrib and 1) shl 6) or ((atrib and 8) shl 4);
		color:=memoria[$de08+(f*8)+6];
		x:=(memoria[$de08+(f*8)+4] or (memoria[$de08+(f*8)+5] shl 8))-39;
		y:=225-memoria[$de08+(f*8)+0];
		flipy:=(atrib2 and $80)<>0;
		flipx:=(atrib2 and $40)<>0;
		y_size:=((atrib3 and $80) shr 7)+1;
		x_size:=((atrib3 and 8) shr 3)+1;
		if y_size=2 then y_div:=1
      else y_div:=2;
		if x_size=2 then x_div:=1
      else x_div:=2;
		y_zoom:=0.125*(((atrib3 and $70) shr 4)+1);
		x_zoom:=0.125*(((atrib3 and 7) shr 0)+1);
    ypixels:=trunc(y_zoom*16);
		xpixels:=trunc(x_zoom*16);
    if (y_size=2) then y:=y-16;
    for yi:=0 to (y_size-1) do begin
			yoffs:=(16-ypixels) div y_div;
			for xi:=0 to (x_size-1) do begin
				xoffs:=(16-xpixels) div x_div;
				if flipx then tile_offs:=(x_size-xi-1)*8
          else tile_offs:=xi*8;
				if flipy then tile_offs:=tile_offs+(y_size-yi-1)
          else tile_offs:=tile_offs+yi;
        put_gfx_sprite_zoom(nchar+tile_offs,color,flipx,flipy,2,x_zoom,y_zoom);
        actualiza_gfx_sprite_zoom(x+xi*xpixels+xoffs,y+yi*ypixels+yoffs,4,2,x_zoom,y_zoom);
			end;
		end;
end;
actualiza_trozo(0,0,288,224,1,0,0,288,224,4);
actualiza_trozo_final(0,0,288,224,4);
end;

procedure eventos_flower;
begin
if event.arcade then begin
  //p1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //p2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //System
  if arcade_input.coin[0] then begin
    z80_0.change_nmi(PULSE_LINE);
    marcade.in2:=(marcade.in2 and $fe);
  end else begin
    marcade.in2:=(marcade.in2 or 1);
  end;
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or 4);
end;
end;

procedure flower_principal;
var
  f:word;
  h:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
   if f=240 then begin
      z80_0.change_irq(ASSERT_LINE);
      z80_1.change_irq(ASSERT_LINE);
      update_video_flower;
   end;
   for h:=1 to CPU_SYNC do begin
    //Main CPU
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //Sub CPU
    z80_1.run(frame_sub);
    frame_sub:=frame_sub+z80_1.tframes-z80_1.contador;
    //Sound CPU
    z80_2.run(frame_snd);
    frame_snd:=frame_snd+z80_2.tframes-z80_2.contador;
   end;
  end;
  eventos_flower;
  video_sync;
end;
end;

function flower_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$dfff,$e000..$f1ff,$f800..$f9ff:flower_getbyte:=memoria[direccion];
  $a100:flower_getbyte:=marcade.in0;
  $a101:flower_getbyte:=marcade.in1;
  $a102:flower_getbyte:=marcade.in2 or marcade.dswa;
  $a103:flower_getbyte:=marcade.dswb;
  $f200:flower_getbyte:=scrollfg;
  $fa00:flower_getbyte:=scrollbg;
end;
end;

procedure flower_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$7fff:; //ROM
   $c000..$dfff,$e800..$efff:memoria[direccion]:=valor;
   $a000..$a007:case (direccion and 7) of
                  0,5..7:;
                  1:main_screen.flip_main_screen:=(valor and 1)<>0;
                  2:if (valor and 1)=0 then z80_0.change_irq(CLEAR_LINE);
                  3:if (valor and 1)=0 then z80_1.change_irq(CLEAR_LINE);
                  4:; //Coin Counter
                end;
   $a400:begin
            sound_latch:=valor;
            if nmi_audio then z80_2.change_nmi(PULSE_LINE);
         end;
   $e000..$e7ff:if memoria[direccion]<>valor then begin
                  memoria[direccion]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
                end;
   $f000..$f1ff:if memoria[direccion]<>valor then begin
                  memoria[direccion]:=valor;
                  gfx[1].buffer[(direccion and $ff)+$100]:=true;
                end;
   $f200:scrollfg:=valor;
   $f800..$f9ff:if memoria[direccion]<>valor then begin
                  memoria[direccion]:=valor;
                  gfx[1].buffer[direccion and $ff]:=true;
                end;
   $fa00:scrollbg:=valor;
end;
end;

function flower_getbyte_sub(direccion:word):byte;
begin
case direccion of
  0..$7fff:flower_getbyte_sub:=mem_misc[direccion];
    else flower_getbyte_sub:=flower_getbyte(direccion);
end;
end;

function snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$3fff,$c000..$c7ff:snd_getbyte:=mem_snd[direccion];
  $6000:snd_getbyte:=sound_latch;
end;
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:; //ROM
  $4001:nmi_audio:=(valor and 1)<>0;
  $8000..$803f:flower_0.write(direccion,valor);
  $a000..$a03f:flower_0.write(direccion or $40,valor);
  $c000..$c7ff:mem_snd[direccion]:=valor;
end;
end;

procedure flower_snd_irq;
begin
  z80_2.change_irq(HOLD_LINE);
end;

procedure flower_update_sound;
begin
  flower_0.update;
end;

//Main
procedure flower_reset;
begin
z80_0.reset;
z80_1.reset;
z80_2.reset;
frame_main:=z80_0.tframes;
frame_sub:=z80_1.tframes;
frame_snd:=z80_1.tframes;
flower_0.reset;
reset_audio;
nmi_audio:=false;
sound_latch:=0;
scrollfg:=0;
scrollbg:=0;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=7;
end;

function iniciar_flower:boolean;
const
      pc_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
          8*8*2+0,8*8*2+1,8*8*2+2, 8*8*2+3,8*8*2+8,8*8*2+9,8*8*2+10,8*8*2+11);
      pc_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
          8*8*4+16*0, 8*8*4+16*1, 8*8*4+2*16, 8*8*4+3*16, 8*8*4+4*16, 8*8*4+5*16, 8*8*4+6*16, 8*8*4+7*16);
var
  memoria_temp:array[0..$7fff] of byte;
  colores:tpaleta;
  f:word;
begin
llamadas_maquina.bucle_general:=flower_principal;
llamadas_maquina.reset:=flower_reset;
llamadas_maquina.fps_max:=60.6060606060606;
iniciar_flower:=false;
iniciar_audio(false);
screen_init(1,288,224,true);
screen_init(2,256,256);
screen_mod_scroll(2,256,256,255,256,256,255);
screen_init(3,256,256,true);
screen_mod_scroll(3,256,256,255,256,256,255);
screen_init(4,512,256,false,true);
iniciar_video(288,224);
//Main CPU
//Si pongo 3Mhz, a veces en la demo la nave muere, pero no se da cuenta y entra en un bucle sin fin y ya no responde a nada
z80_0:=cpu_z80.create(18432000 div CPU_DIV,264*CPU_SYNC);
z80_0.change_ram_calls(flower_getbyte,flower_putbyte);
if not(roms_load(@memoria,flower_rom)) then exit;
//Sub CPU
z80_1:=cpu_z80.create(18432000 div CPU_DIV,264*CPU_SYNC);
z80_1.change_ram_calls(flower_getbyte_sub,flower_putbyte);
if not(roms_load(@mem_misc,flower_rom2)) then exit;
//Sound CPU
z80_2:=cpu_z80.create(18432000 div CPU_DIV,264*CPU_SYNC);
z80_2.change_ram_calls(snd_getbyte,snd_putbyte);
z80_2.init_sound(flower_update_sound);
timers.init(z80_2.numero_cpu,18432000/CPU_DIV/90,flower_snd_irq,nil,true);
if not(roms_load(@mem_snd,flower_rom_snd)) then exit;
//Sound chip
flower_0:=flower_chip.create(96000);
if not(roms_load(@flower_0.sample_rom,flower_samples)) then exit;
if not(roms_load(@flower_0.sample_vol,flower_vol)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,flower_char)) then exit;
for f:=0 to $1fff do memoria_temp[f]:=not(memoria_temp[f]);
init_gfx(0,8,8,$200);
gfx[0].trans[3]:=true;
gfx_set_desc_data(2,0,8*8*2,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//convertir tiles
if not(roms_load(@memoria_temp,flower_tiles)) then exit;
for f:=0 to $7fff do memoria_temp[f]:=not(memoria_temp[f]);
init_gfx(1,16,16,$100);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,16*16*2,0,4,16*16*2*$100,16*16*2*$100+4);
convert_gfx(1,0,@memoria_temp,@pc_x,@pc_y,false,false);
//sprites
if not(roms_load(@memoria_temp,flower_sprites)) then exit;
for f:=0 to $7fff do memoria_temp[f]:=not(memoria_temp[f]);
init_gfx(2,16,16,$100);
gfx[2].trans[15]:=true;
convert_gfx(2,0,@memoria_temp,@pc_x,@pc_y,false,false);
//pal
if not(roms_load(@memoria_temp,flower_prom)) then exit;
for f:=0 to $ff do begin
		colores[f].r:=pal4bit(memoria_temp[f]);
    colores[f].g:=pal4bit(memoria_temp[f+$100]);
    colores[f].b:=pal4bit(memoria_temp[f+$200]);
end;
set_pal(colores,$100);
//DIP
marcade.dswa:=$f8;
marcade.dswa_val2:=@flower_dipa;
marcade.dswb:=$9d;
marcade.dswb_val2:=@flower_dipb;
//final
flower_reset;
iniciar_flower:=true;
end;

end.
