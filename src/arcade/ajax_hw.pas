unit ajax_hw;

interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,konami,hd6309,main_engine,controls_engine,rom_engine,pal_engine,
     sound_engine,ym_2151,k052109,k051960,k007232,k051316,dialogs;

function iniciar_ajax:boolean;

implementation

const
        //ajax
        ajax_rom:array[0..1] of tipo_roms=(
        (n:'770_m01.n11';l:$10000;p:0;crc:$4a64e53a),(n:'770_l02.n12';l:$10000;p:$10000;crc:$ad7d592b));
        ajax_sub:array[0..1] of tipo_roms=(
        (n:'770_l05.i16';l:$8000;p:0;crc:$ed64fbb2),(n:'770_f04.g16';l:$10000;p:$8000;crc:$e0e4ec9c));
        ajax_sound:tipo_roms=(n:'770_h03.f16';l:$8000;p:0;crc:$2ffd2afc);
        ajax_tiles:array[0..7] of tipo_roms=(
        (n:'770c13-a.f3';l:$10000;p:0;crc:$4ef6fff2),(n:'770c13-c.f4';l:$10000;p:1;crc:$97ffbab6),
        (n:'770c12-a.f5';l:$10000;p:2;crc:$6c0ade68),(n:'770c12-c.f6';l:$10000;p:3;crc:$61fc39cc),
        (n:'770c13-b.e3';l:$10000;p:$40000;crc:$86fdd706),(n:'770c13-d.e4';l:$10000;p:$40001;crc:$7d7acb2d),
        (n:'770c12-b.e5';l:$10000;p:$40002;crc:$5f221cc6),(n:'770c12-d.e6';l:$10000;p:$40003;crc:$f1edb2f4));
        ajax_sprites:array[0..15] of tipo_roms=(
        (n:'770c09-a.f8';l:$10000;p:0;crc:$76690fb8),(n:'770c09-e.f9';l:$10000;p:1;crc:$17b482c9),
        (n:'770c08-a.f10';l:$10000;p:2;crc:$efd29a56),(n:'770c08-e.f11';l:$10000;p:3;crc:$6d43afde),
        (n:'770c09-b.e8';l:$10000;p:$40000;crc:$cd1709d1),(n:'770c09-f.e9';l:$10000;p:$40001;crc:$cba4b47e),
        (n:'770c08-b.e10';l:$10000;p:$40002;crc:$f3374014),(n:'770c08-f.e11';l:$10000;p:$40003;crc:$f5ba59aa),
        (n:'770c09-c.d8';l:$10000;p:$80000;crc:$bfd080b8),(n:'770c09-g.d9';l:$10000;p:$80001;crc:$77d58ea0),
        (n:'770c08-c.d10';l:$10000;p:$80002;crc:$28e7088f),(n:'770c08-g.d11';l:$10000;p:$80003;crc:$17da8f6d),
        (n:'770c09-d.c8';l:$10000;p:$c0000;crc:$6f955600),(n:'770c09-h.c9';l:$10000;p:$c0001;crc:$494a9090),
        (n:'770c08-d.c10';l:$10000;p:$c0002;crc:$91591777),(n:'770c08-h.c11';l:$10000;p:$c0003;crc:$d97d4b15));
        ajax_zoom:array[0..1] of tipo_roms=(
        (n:'770c06.f4';l:$40000;p:0;crc:$d0c592ee),(n:'770c07.h4';l:$40000;p:$40000;crc:$0b399fb1));
        ajax_k007232_1:array[0..3] of tipo_roms=(
        (n:'770c10-a.a7';l:$10000;p:0;crc:$e45ec094),(n:'770c10-b.a6';l:$10000;p:$10000;crc:$349db7d3),
        (n:'770c10-c.a5';l:$10000;p:$20000;crc:$71cb1f05),(n:'770c10-d.a4';l:$10000;p:$30000;crc:$e8ab1844));
        ajax_k007232_2:array[0..7] of tipo_roms=(
        (n:'770c11-a.c6';l:$10000;p:0;crc:$8cccd9e0),(n:'770c11-b.c5';l:$10000;p:$10000;crc:$0af2fedd),
        (n:'770c11-c.c4';l:$10000;p:$20000;crc:$7471f24a),(n:'770c11-d.c3';l:$10000;p:$30000;crc:$a58be323),
        (n:'770c11-e.b7';l:$10000;p:$40000;crc:$dd553541),(n:'770c11-f.b6';l:$10000;p:$50000;crc:$3f78bd0f),
        (n:'770c11-g.b5';l:$10000;p:$60000;crc:$078c51b2),(n:'770c11-h.b4';l:$10000;p:$70000;crc:$7300c2e1));
        //DIP
        ajax_dip_a:array [0..1] of def_dip2=(
        (mask:$0f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),
        (mask:$f0;name:'Coin B';number:16;val16:($20,$50,$80,$40,$10,$f0,$30,$70,$e0,$60,$d0,$c0,$b0,$a0,$90,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','No Coin')));
        ajax_dip_b:array [0..4] of def_dip2=(
        (mask:$3;name:'Lives';number:4;val4:(3,2,1,0);name4:('2','3','5','7')),
        (mask:$4;name:'Cabinet';number:2;val2:(0,4);name2:('Upright','Cocktail')),
        (mask:$18;name:'Bonus Life';number:4;val4:($18,$10,8,0);name4:('30K 150K','10K 200K','30K','50K')),
        (mask:$60;name:'Difficulty';number:4;val4:($60,$40,$20,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')));
        ajax_dip_c:array [0..1] of def_dip2=(
        (mask:$1;name:'Flip Screen';number:2;val2:(1,0);name2:('Off','On')),
        (mask:$8;name:'Control in 3D Stages';number:2;val2:(8,0);name2:('Normal','Inverted')));

var
 tiles_rom,sprite_rom,k007232_1_rom,k007232_2_rom,zoom_rom:pbyte;
 sound_latch,rom_bank1,rom_bank2:byte;
 sub_firq_enable,prioridad:boolean;
 rom_bank:array[0..11,0..$1fff] of byte;
 rom_sub_bank:array[0..8,0..$1fff] of byte;

procedure ajax_cb(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
const
  layer_colorbase:array[0..2] of byte=(1024 div 16,0 div 16,512 div 16);
begin
	code:=code or (((color and $0f) shl 8) or (bank shl 12));
	color:=layer_colorbase[layer]+((color and $f0) shr 4);
end;

procedure ajax_sprite_cb(var code:word;var color:word;var pri:word;var shadow:word);
begin
{ priority bits:
	   4 over zoom (0 = have priority)
	   5 over B    (0 = have priority)
	   6 over A    (1 = have priority)
	   never over F}
if (color and $20)<>0 then pri:=1 // Por debajo de B
  else pri:=0; //Por encima de B
if (color and $10)<>0 then pri:=3 // Z = 4
  else pri:=2;
if (color and $40)=0 then pri:=5  // A = 2
  else pri:=4;
color:=16+(color and $f);
end;

procedure ajax_k051316_cb(var code:word;var color:word;var priority_mask:word);
begin
  code:=code or ((color and $07) shl 8);
	color:=6+((color and $08) shr 3);
end;

procedure ajax_k007232_cb_0(valor:byte);
begin
  k007232_0.set_volume(0,(valor shr 4)*$11,0);
  k007232_0.set_volume(1,0,(valor and $f)*$11);
end;

procedure ajax_k007232_cb_1(valor:byte);
begin
  k007232_1.set_volume(1,(valor and $0f)*($11 shr 1),(valor shr 4)*($11 shr 1));
end;

procedure ajax_k051960_cb(state:byte);
begin
  konami_0.change_irq(state);
end;

procedure update_video_ajax;
begin
k052109_0.draw_tiles;
k051960_0.update_sprites;
k051960_0.draw_sprites(1,-1);
k052109_0.draw_layer(2,5); //B
k051960_0.draw_sprites(0,-1);
if prioridad then begin
  k051960_0.draw_sprites(3,-1);
  k051316_0.draw(5);
  k051960_0.draw_sprites(2,-1);
  k051960_0.draw_sprites(5,-1);
  k052109_0.draw_layer(1,5); //A
  k051960_0.draw_sprites(4,-1);
end else begin
  k051960_0.draw_sprites(5,-1);
  k052109_0.draw_layer(1,5); //A
  k051316_0.draw(5);
  k051960_0.draw_sprites(4,-1);
  k051960_0.draw_sprites(3,-1);
  k051960_0.draw_sprites(2,-1);
end;
k052109_0.draw_layer(0,5); //F
actualiza_trozo_final(112,16,304,224,5);
end;

procedure eventos_ajax;
begin
if main_vars.service1 then marcade.dswc:=(marcade.dswc and $fb) else marcade.dswc:=(marcade.dswc or $4);
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  //P2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //System
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or 8);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure ajax_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
    for f:=0 to $ff do begin
      if f=240 then update_video_ajax;
      //main
      konami_0.run(frame_main);
      frame_main:=frame_main+konami_0.tframes-konami_0.contador;
      //sub
      hd6309_0.run(frame_sub);
      frame_sub:=frame_sub+hd6309_0.tframes-hd6309_0.contador;
      //sound
      z80_0.run(frame_snd);
      frame_snd:=frame_snd+z80_0.tframes-z80_0.contador;
      k051960_0.update_line(f);
    end;
    eventos_ajax;
    video_sync;
end;
end;

function ajax_getbyte(direccion:word):byte;
begin
case direccion of
    0..$1c0:case ((direccion and $1c0) shr 6) of
              0:ajax_getbyte:=random(256);
              4:ajax_getbyte:=marcade.in1;
              6:case (direccion and 3) of
                  0:ajax_getbyte:=marcade.in2; //system
                  1:ajax_getbyte:=marcade.in0; //p1
                  2:ajax_getbyte:=marcade.dswa; //dsw1
                  3:ajax_getbyte:=marcade.dswb; //dsw2
                end;
              7:ajax_getbyte:=marcade.dswc;  //DSW3
                  else ajax_getbyte:=$ff;
            end;
    $800..$807:ajax_getbyte:=k051960_0.k051937_read(direccion and $7);
    $c00..$fff:ajax_getbyte:=k051960_0.read(direccion-$c00);
    $1000..$1fff:ajax_getbyte:=buffer_paleta[direccion and $fff];
    $2000..$5fff,$8000..$ffff:ajax_getbyte:=memoria[direccion];
    $6000..$7fff:ajax_getbyte:=rom_bank[rom_bank1,direccion and $1fff];
end;
end;

procedure ajax_putbyte(direccion:word;valor:byte);

procedure cambiar_color(pos:word);
var
  color:tcolor;
  valor:word;
begin
  valor:=(buffer_paleta[pos*2] shl 8)+buffer_paleta[(pos*2)+1];
  color.b:=pal5bit(valor shr 10);
  color.g:=pal5bit(valor shr 5);
  color.r:=pal5bit(valor);
  set_pal_color_alpha(color,pos);
  k052109_0.clean_video_buffer;
  k051316_0.clean_video_buffer;
end;

begin
case direccion of
   0..$1c0:case ((direccion and $1c0) shr 6) of
              0:if (direccion=0) then if (sub_firq_enable) then hd6309_0.change_firq(HOLD_LINE);
              1:z80_0.change_irq(HOLD_LINE);
              2:sound_latch:=valor;
              3:begin
                  rom_bank1:=((not(valor) and $80) shr 5)+(valor and 7);
                  prioridad:=(valor and 8)<>0;
                end;
              5:;
            end;
   $800..$807:k051960_0.k051937_write(direccion and $7,valor);
   $c00..$fff:k051960_0.write(direccion-$c00,valor);
   $1000..$1fff:if buffer_paleta[direccion and $fff]<>valor then begin
                       buffer_paleta[direccion and $fff]:=valor;
                       cambiar_color((direccion and $fff) shr 1);
                    end;
   $2000..$5fff:memoria[direccion]:=valor;
   $6000..$ffff:; //ROM
end;
end;

//Sub CPU
function ajax_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7ff:ajax_sub_getbyte:=k051316_0.read(direccion);
  $1000..$17ff:ajax_sub_getbyte:=k051316_0.rom_read(direccion and $7ff);
  $2000..$3fff:ajax_sub_getbyte:=memoria[direccion];
  $4000..$7fff:ajax_sub_getbyte:=k052109_0.read(direccion and $3fff);
  $8000..$9fff:ajax_sub_getbyte:=rom_sub_bank[rom_bank2,direccion and $1fff];
  $a000..$ffff:ajax_sub_getbyte:=mem_misc[direccion];
end;
end;

procedure ajax_sub_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7ff:k051316_0.write(direccion,valor);
  $800..$80f:k051316_0.control_w(direccion and $f,valor);
  $1800:begin
            // enable char ROM reading through the video RAM
            if (valor and $40)<>0 then k052109_0.set_rmrd_line(ASSERT_LINE)
              else k052109_0.set_rmrd_line(CLEAR_LINE);
	          // bit 5 enables 051316 wraparound
	          //m_k051316->wraparound_enable(data & 0x20);
	          // FIRQ control
	          sub_firq_enable:=(valor and $10)<>0;
	          // bank # (ROMS G16 and I16)
	          rom_bank2:=valor and $0f;
        end;
  $2000..$3fff:memoria[direccion]:=valor;
  $4000..$7fff:k052109_0.write(direccion and $3fff,valor);
  $8000..$ffff:; //ROM
end;
end;

//Sound
function ajax_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:ajax_snd_getbyte:=mem_snd[direccion];
  $a000..$a00d:ajax_snd_getbyte:=k007232_0.read(direccion and $f);
  $b000..$b00d:ajax_snd_getbyte:=k007232_1.read(direccion and $f);
  $c001:ajax_snd_getbyte:=ym2151_0.status;
  $e000:ajax_snd_getbyte:=sound_latch;
end;
end;

procedure ajax_snd_bankswitch(valor:byte);
begin
k007232_0.set_bank((valor shr 1) and 1,valor and 1);
k007232_1.set_bank((valor shr 4) and 3,(valor shr 2) and 3);
end;

procedure ajax_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$87ff:mem_snd[direccion]:=valor;
  $9000:ajax_snd_bankswitch(valor);
  $a000..$a00d:k007232_0.write(direccion and $f,valor);
  $b000..$b00d:k007232_1.write(direccion and $f,valor);
  $b80c:k007232_1.set_volume(0,(valor and $0f)*($11 shr 1),(valor and $f)*($11 shr 1));
  $c000:ym2151_0.reg(valor);
  $c001:ym2151_0.write(valor);
end;
end;

procedure ajax_sound_update;
begin
  ym2151_0.update;
  k007232_0.update;
  k007232_1.update;
end;

//Main
procedure reset_ajax;
begin
 konami_0.reset;
 hd6309_0.reset;
 z80_0.reset;
 k052109_0.reset;
 ym2151_0.reset;
 k051960_0.reset;
 k051316_0.reset;
 frame_main:=konami_0.tframes;
 frame_sub:=hd6309_0.tframes;
 frame_snd:=z80_0.tframes;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 sound_latch:=0;
 rom_bank1:=0;
 rom_bank2:=0;
 sub_firq_enable:=false;
end;

procedure cerrar_ajax;
begin
if k007232_1_rom<>nil then freemem(k007232_1_rom);
if k007232_2_rom<>nil then freemem(k007232_2_rom);
if sprite_rom<>nil then freemem(sprite_rom);
if tiles_rom<>nil then freemem(tiles_rom);
if zoom_rom<>nil then freemem(zoom_rom);
k007232_1_rom:=nil;
k007232_2_rom:=nil;
sprite_rom:=nil;
tiles_rom:=nil;
zoom_rom:=nil;
end;

function iniciar_ajax:boolean;
var
   temp_mem:array[0..$1ffff] of byte;
   f:byte;
begin
llamadas_maquina.close:=cerrar_ajax;
llamadas_maquina.reset:=reset_ajax;
llamadas_maquina.bucle_general:=ajax_principal;
llamadas_maquina.fps_max:=59.185606;
llamadas_maquina.scanlines:=256;
iniciar_ajax:=false;
main_screen.rot90_screen:=true;
//Pantallas para el K052109
screen_init(1,512,256,true);
screen_init(2,512,256,true);
screen_init(3,512,256,false);
screen_init(4,512,512,true); //Para el K051316
screen_init(5,1024,1024,false,true);
iniciar_video(304,224,true);
iniciar_audio(true);
//Main CPU
konami_0:=cpu_konami.create(12000000);
konami_0.change_ram_calls(ajax_getbyte,ajax_putbyte);
if not(roms_load(@temp_mem,ajax_rom)) then exit;
copymemory(@memoria[$8000],@temp_mem[$8000],$8000);
for f:=0 to 3 do copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
for f:=0 to 7 do copymemory(@rom_bank[4+f,0],@temp_mem[$10000+(f*$2000)],$2000);
//Sub CPU
hd6309_0:=cpu_hd6309.create(3000000,TCPU_HD6309E);
hd6309_0.change_ram_calls(ajax_sub_getbyte,ajax_sub_putbyte);
if not(roms_load(@temp_mem,ajax_sub)) then exit;
copymemory(@mem_misc[$a000],@temp_mem[$2000],$6000);
copymemory(@rom_sub_bank[8,0],@temp_mem[0],$2000);
for f:=0 to 7 do copymemory(@rom_sub_bank[f,0],@temp_mem[$8000+(f*$2000)],$2000);
//Sound CPU
z80_0:=cpu_z80.create(3579545);
z80_0.change_ram_calls(ajax_snd_getbyte,ajax_snd_putbyte);
z80_0.init_sound(ajax_sound_update);
if not(roms_load(@mem_snd,ajax_sound)) then exit;
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
getmem(k007232_1_rom,$40000);
if not(roms_load(k007232_1_rom,ajax_k007232_1)) then exit;
k007232_0:=k007232_chip.create(3579545,k007232_1_rom,$40000,0.20,ajax_k007232_cb_0);
getmem(k007232_2_rom,$80000);
if not(roms_load(k007232_2_rom,ajax_k007232_2)) then exit;
k007232_1:=k007232_chip.create(3579545,k007232_2_rom,$80000,0.50,ajax_k007232_cb_1,true);
//Iniciar video
getmem(tiles_rom,$80000);
if not(roms_load32b_b(tiles_rom,ajax_tiles)) then exit;
k052109_0:=k052109_chip.create(1,2,3,0,ajax_cb,tiles_rom,$80000);
getmem(sprite_rom,$100000);
if not(roms_load32b_b(sprite_rom,ajax_sprites)) then exit;
k051960_0:=k051960_chip.create(5,1,sprite_rom,$100000,ajax_sprite_cb,2);
k051960_0.change_irqs(ajax_k051960_cb,nil,nil);
getmem(zoom_rom,$80000);
if not(roms_load(zoom_rom,ajax_zoom)) then exit;
k051316_0:=k051316_chip.create(4,2,ajax_k051316_cb,zoom_rom,$80000,BPP7);
//DIP
init_dips(1,ajax_dip_a,$ff);
init_dips(2,ajax_dip_b,$5a);
init_dips(3,ajax_dip_c,$ff);
//final
iniciar_ajax:=true;
end;

end.
