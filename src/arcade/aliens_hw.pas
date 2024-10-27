unit aliens_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,konami,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,ym_2151,k052109,k051960,k007232;

function iniciar_aliens:boolean;

implementation
const
        //aliens
        aliens_rom:array[0..1] of tipo_roms=(
        (n:'875_j01.c24';l:$20000;p:0;crc:$6a529cd6),(n:'875_j02.e24';l:$10000;p:$20000;crc:$56c20971));
        aliens_sound:tipo_roms=(n:'875_b03.g04';l:$8000;p:0;crc:$1ac4d283);
        aliens_tiles:array[0..3] of tipo_roms=(
        (n:'875b11.k13';l:$80000;p:0;crc:$89c5c885),(n:'875b12.k19';l:$80000;p:2;crc:$ea6bdc17),
        (n:'875b07.j13';l:$40000;p:$100000;crc:$e9c56d66),(n:'875b08.j19';l:$40000;p:$100002;crc:$f9387966));
        aliens_sprites:array[0..3] of tipo_roms=(
        (n:'875b10.k08';l:$80000;p:0;crc:$0b1035b1),(n:'875b09.k02';l:$80000;p:2;crc:$e76b3c19),
        (n:'875b06.j08';l:$40000;p:$100000;crc:$081a0566),(n:'875b05.j02';l:$40000;p:$100002;crc:$19a261f2));
        aliens_k007232:tipo_roms=(n:'875b04.e05';l:$40000;p:0;crc:$4e209ac8);
        //DIP
        aliens_dip_a:array [0..2] of def_dip2=(
        (mask:$0f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),
        (mask:$f0;name:'Coin B';number:16;val16:($20,$50,$80,$40,$10,$f0,$30,$70,$e0,$60,$d0,$c0,$b0,$a0,$90,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','No Coin')),());
        aliens_dip_b:array [0..3] of def_dip2=(
        (mask:$3;name:'Lives';number:4;val4:(3,2,1,0);name4:('1','2','3','5')),
        (mask:$60;name:'Difficulty';number:4;val4:($60,$40,$20,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')),());
        aliens_dip_c:array [0..1] of def_dip2=(
        (mask:$1;name:'Flip Screen';number:2;val2:(1,0);name2:('Off','On')),());
        layer_colorbase:array[0..2] of byte=(0,4,8);

var
 tiles_rom,sprite_rom,k007232_rom:pbyte;
 sound_latch,bank0_bank,rom_bank1:byte;
 rom_bank:array[0..19,0..$1fff] of byte;
 ram_bank:array[0..1,0..$3ff] of byte;

procedure aliens_cb(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
begin
code:=code or (((color and $3f) shl 8) or (bank shl 14));
color:=layer_colorbase[layer]+((color and $c0) shr 6);
end;

procedure aliens_sprite_cb(var code:word;var color:word;var pri:word;var shadow:word);
begin
// The PROM allows for mixed priorities, where sprites would have
// priority over text but not on one or both of the other two planes.
case (color and $70) of
     $20,$60:pri:=7;  // over -, not ABF
     $0:pri:=4;       //over AB, not F
     $40:pri:=6;      // over A, not BF
     $10:pri:=0 ;      // over ABF
     //No posibles debido a como pinta la pantalla el driver!!
     $50:pri:=2;      // over AF, not B
     $30,$70:pri:=3;  // over F, not AB
end;
code:=code or ((color and $80) shl 6);
color:=16+(color and $f);
shadow:=0;  // shadows are not used by this game
end;

procedure aliens_k007232_cb(valor:byte);
begin
  k007232_0.set_volume(0,(valor and $f)*$11,0);
  k007232_0.set_volume(1,0,(valor shr 4)*$11);
end;

procedure aliens_k051960_cb(state:byte);
begin
  konami_0.change_irq(state);
end;

procedure update_video_aliens;
begin
k052109_0.draw_tiles;
k051960_0.update_sprites;
fill_full_screen(4,layer_colorbase[1]*16);
k051960_0.draw_sprites(7,-1);
k052109_0.draw_layer(1,4); //A
k051960_0.draw_sprites(6,-1);
k052109_0.draw_layer(2,4); //B
k051960_0.draw_sprites(4,-1);
k052109_0.draw_layer(0,4); //F
k051960_0.draw_sprites(0,-1);
actualiza_trozo_final(112,16,288,224,4);
end;

procedure eventos_aliens;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
end;
end;

procedure aliens_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=konami_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRunning do begin
    for f:=0 to $ff do begin
      //main
      konami_0.run(frame_m);
      frame_m:=frame_m+konami_0.tframes-konami_0.contador;
      //sound
      z80_0.run(frame_s);
      frame_s:=frame_s+z80_0.tframes-z80_0.contador;
      if f=239 then update_video_aliens;
      k051960_0.update_line(f);
    end;
    eventos_aliens;
    video_sync;
end;
end;

function aliens_getbyte(direccion:word):byte;
begin
case direccion of
    0..$3ff:aliens_getbyte:=ram_bank[bank0_bank,direccion];
    $400..$1fff,$8000..$ffff:aliens_getbyte:=memoria[direccion];
    $2000..$3fff:aliens_getbyte:=rom_bank[rom_bank1,direccion and $1fff];
    $4000..$7fff:case direccion of
                    $5f80:aliens_getbyte:=marcade.dswc; //DSW3
                    $5f81:aliens_getbyte:=marcade.in0; //p1
                    $5f82:aliens_getbyte:=marcade.in1; //p2
                    $5f83:aliens_getbyte:=marcade.dswb; //dsw2
                    $5f84:aliens_getbyte:=marcade.dswa; //dsw1
                    else if k052109_0.get_rmrd_line=CLEAR_LINE then begin
                            direccion:=direccion and $3fff;
                            case direccion of
                              0..$37ff,$3808..$3bff:aliens_getbyte:=k052109_0.read(direccion);
                              $3800..$3807:aliens_getbyte:=k051960_0.k051937_read(direccion-$3800);
                              $3c00..$3fff:aliens_getbyte:=k051960_0.read(direccion-$3c00);
                            end;
                         end else aliens_getbyte:=k052109_0.read(direccion and $3fff);
                 end;
    end;
end;

procedure aliens_putbyte(direccion:word;valor:byte);

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
end;

begin
case direccion of
    0..$3ff:begin
                 ram_bank[bank0_bank,direccion]:=valor;
                 if bank0_bank=1 then begin
                    if buffer_paleta[direccion]<>valor then begin
                       buffer_paleta[direccion]:=valor;
                       cambiar_color(direccion shr 1);
                    end;
                 end;
            end;
    $400..$1fff:memoria[direccion]:=valor;
    $2000..$3fff:;
    $4000..$7fff:case direccion of
                         $5f88:begin
                                    bank0_bank:=(valor and $20) shr 5;
                                    if (valor and $40)<>0 then k052109_0.set_rmrd_line(ASSERT_LINE)
                                        else k052109_0.set_rmrd_line(CLEAR_LINE);
                               end;
                         $5f8c:begin
                                    sound_latch:=valor;
                                    z80_0.change_irq(HOLD_LINE);
                               end;
                         else begin
                              direccion:=direccion and $3fff;
                              case direccion of
                                0..$37ff,$3808..$3bff:k052109_0.write(direccion,valor);
                                $3800..$3807:k051960_0.k051937_write(direccion-$3800,valor);
                                $3c00..$3fff:k051960_0.write(direccion-$3c00,valor);
                              end;
                         end;
                 end;
    $8000..$ffff:; //ROM
end;
end;

procedure aliens_bank(valor:byte);
begin
     rom_bank1:=valor and $1f;
end;

function aliens_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:aliens_snd_getbyte:=mem_snd[direccion];
  $a001:aliens_snd_getbyte:=ym2151_0.status;
  $c000:aliens_snd_getbyte:=sound_latch;
  $e000..$e00d:aliens_snd_getbyte:=k007232_0.read(direccion and $f);
end;
end;

procedure aliens_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$87ff:mem_snd[direccion]:=valor;
  $a000:ym2151_0.reg(valor);
  $a001:ym2151_0.write(valor);
  $e000..$e00d:k007232_0.write(direccion and $f,valor);
end;
end;

procedure aliens_snd_bankswitch(valor:byte);
begin
// b1: bank for chanel A */
// b0: bank for chanel B */
k007232_0.set_bank((valor shr 1) and 1,valor and 1);
end;

procedure aliens_sound_update;
begin
  ym2151_0.update;
  k007232_0.update;
end;

//Main
procedure reset_aliens;
begin
 konami_0.reset;
 z80_0.reset;
 k052109_0.reset;
 ym2151_0.reset;
 k051960_0.reset;
 reset_video;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 sound_latch:=0;
 bank0_bank:=0;
 rom_bank1:=0;
end;

procedure cerrar_aliens;
begin
if k007232_rom<>nil then freemem(k007232_rom);
if sprite_rom<>nil then freemem(sprite_rom);
if tiles_rom<>nil then freemem(tiles_rom);
k007232_rom:=nil;
sprite_rom:=nil;
tiles_rom:=nil;
end;

function iniciar_aliens:boolean;
var
   temp_mem:array[0..$2ffff] of byte;
   f:byte;
begin
llamadas_maquina.close:=cerrar_aliens;
llamadas_maquina.reset:=reset_aliens;
llamadas_maquina.bucle_general:=aliens_principal;
llamadas_maquina.fps_max:=59.185606;
iniciar_aliens:=false;
//Pantallas para el K052109
screen_init(1,512,256,true);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,512,511,256,256,255);
screen_init(3,512,256,true);
screen_mod_scroll(3,512,512,511,256,256,255);
screen_init(4,1024,1024,false,true);
iniciar_video(288,224,true);
iniciar_audio(false);
//cargar roms y ponerlas en su sitio...
if not(roms_load(@temp_mem,aliens_rom)) then exit;
copymemory(@memoria[$8000],@temp_mem[$28000],$8000);
for f:=0 to 19 do copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
//cargar sonido
if not(roms_load(@mem_snd,aliens_sound)) then exit;
//Main CPU
konami_0:=cpu_konami.create(12000000,256);
konami_0.change_ram_calls(aliens_getbyte,aliens_putbyte);
konami_0.change_set_lines(aliens_bank);
//Sound CPU
z80_0:=cpu_z80.create(3579545,256);
z80_0.change_ram_calls(aliens_snd_getbyte,aliens_snd_putbyte);
z80_0.init_sound(aliens_sound_update);
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
ym2151_0.change_port_func(aliens_snd_bankswitch);
getmem(k007232_rom,$40000);
if not(roms_load(k007232_rom,aliens_k007232)) then exit;
k007232_0:=k007232_chip.create(3579545,k007232_rom,$40000,0.20,aliens_k007232_cb);
//Iniciar video
getmem(tiles_rom,$200000);
if not(roms_load32b(tiles_rom,aliens_tiles)) then exit;
k052109_0:=k052109_chip.create(1,2,3,0,aliens_cb,tiles_rom,$200000);
getmem(sprite_rom,$200000);
if not(roms_load32b(sprite_rom,aliens_sprites)) then exit;
k051960_0:=k051960_chip.create(4,1,sprite_rom,$200000,aliens_sprite_cb,2);
k051960_0.change_irqs(aliens_k051960_cb,nil,nil);
//DIP
marcade.dswa:=$ff;
marcade.dswa_val2:=@aliens_dip_a;
marcade.dswb:=$5e;
marcade.dswb_val2:=@aliens_dip_b;
marcade.dswc:=$ff;
marcade.dswc_val2:=@aliens_dip_c;
//final
reset_aliens;
iniciar_aliens:=true;
end;

end.
