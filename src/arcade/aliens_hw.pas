unit aliens_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,konami,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,ym_2151,k052109,k051960,k007232,misc_functions;

procedure Cargar_aliens;
function iniciar_aliens:boolean;
procedure reset_aliens;
procedure cerrar_aliens;
//Main
procedure aliens_principal;
function aliens_getbyte(direccion:word):byte;
procedure aliens_putbyte(direccion:word;valor:byte);
procedure aliens_bank(valor:byte);
//Sound
function aliens_snd_getbyte(direccion:word):byte;
procedure aliens_snd_putbyte(direccion:word;valor:byte);
procedure aliens_sound_update;
procedure aliens_snd_bankswitch(valor:byte);
//Video
procedure aliens_cb(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
procedure aliens_sprite_cb(var code:word;var color:word;var pri:word;var shadow:word);
procedure aliens_k007232_cb(valor:byte);

implementation
const
        //aliens
        aliens_rom:array[0..2] of tipo_roms=(
        (n:'875_j01.c24';l:$20000;p:0;crc:$6a529cd6),(n:'875_j02.e24';l:$10000;p:$20000;crc:$56c20971),());
        aliens_sound:tipo_roms=(n:'875_b03.g04';l:$8000;p:0;crc:$1ac4d283);
        aliens_tiles:array[0..4] of tipo_roms=(
        (n:'875b11.k13';l:$80000;p:0;crc:$89c5c885),(n:'875b12.k19';l:$80000;p:2;crc:$ea6bdc17),
        (n:'875b07.j13';l:$40000;p:$100000;crc:$e9c56d66),(n:'875b08.j19';l:$40000;p:$100002;crc:$f9387966),());
        aliens_sprites:array[0..4] of tipo_roms=(
        (n:'875b10.k08';l:$80000;p:0;crc:$0b1035b1),(n:'875b09.k02';l:$80000;p:2;crc:$e76b3c19),
        (n:'875b06.j08';l:$40000;p:$100000;crc:$081a0566),(n:'875b05.j02';l:$40000;p:$100002;crc:$19a261f2),());
        aliens_k007232:tipo_roms=(n:'875b04.e05';l:$40000;p:0;crc:$4e209ac8);
        //DIP
        aliens_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$02;dip_name:'4C 1C'),(dip_val:$05;dip_name:'3C 1C'),(dip_val:$08;dip_name:'2C 1C'),(dip_val:$04;dip_name:'3C 2C'),(dip_val:$01;dip_name:'4C 3C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$03;dip_name:'3C 4C'),(dip_val:$07;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$06;dip_name:'2C 5C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(dip_val:$0a;dip_name:'1C 6C'),(dip_val:$09;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$20;dip_name:'4C 1C'),(dip_val:$50;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$40;dip_name:'3C 2C'),(dip_val:$10;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'3C 4C'),(dip_val:$70;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$60;dip_name:'2C 5C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$90;dip_name:'1C 7C'),(dip_val:$0;dip_name:'No Coin'))),());
        aliens_dip_b:array [0..3] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'1'),(dip_val:$2;dip_name:'2'),(dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        aliens_dip_c:array [0..1] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 tiles_rom,sprite_rom,k007232_rom:pbyte;
 sound_latch,sprite_colorbase,bank0_bank,rom_bank1:byte;
 layer_colorbase:array[0..2] of byte;
 rom_bank:array[0..19,0..$1fff] of byte;
 ram_bank:array[0..1,0..$3ff] of byte;

procedure Cargar_aliens;
begin
llamadas_maquina.iniciar:=iniciar_aliens;
llamadas_maquina.cerrar:=cerrar_aliens;
llamadas_maquina.reset:=reset_aliens;
llamadas_maquina.bucle_general:=aliens_principal;
llamadas_maquina.fps_max:=59.185606;
end;

function iniciar_aliens:boolean;
var
   temp_mem:array[0..$2ffff] of byte;
   f:byte;
begin
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
if not(cargar_roms(@temp_mem[0],@aliens_rom[0],'aliens.zip',0)) then exit;
copymemory(@memoria[$8000],@temp_mem[$28000],$8000);
for f:=0 to 19 do copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
//cargar sonido
if not(cargar_roms(@mem_snd[0],@aliens_sound,'aliens.zip',1)) then exit;
//Main CPU
main_konami:=cpu_konami.create(3000000,256);
main_konami.change_ram_calls(aliens_getbyte,aliens_putbyte);
main_konami.change_set_lines(aliens_bank);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,256);
snd_z80.change_ram_calls(aliens_snd_getbyte,aliens_snd_putbyte);
snd_z80.init_sound(aliens_sound_update);
//Sound Chips
YM2151_Init(0,3579545,aliens_snd_bankswitch,nil);
getmem(k007232_rom,$40000);
if not(cargar_roms(k007232_rom,@aliens_k007232,'aliens.zip',1)) then exit;
k007232_0:=k007232_chip.create(3579545,k007232_rom,$40000,0.20,aliens_k007232_cb);
//Iniciar video
getmem(tiles_rom,$200000);
if not(cargar_roms32b(tiles_rom,@aliens_tiles,'aliens.zip',0)) then exit;
k052109_0:=k052109_chip.create(1,2,3,aliens_cb,tiles_rom,$200000);
getmem(sprite_rom,$200000);
if not(cargar_roms32b(sprite_rom,@aliens_sprites,'aliens.zip',0)) then exit;
k051960_0:=k051960_chip.create(4,sprite_rom,$200000,aliens_sprite_cb,2);
layer_colorbase[0]:=0;
layer_colorbase[1]:=4;
layer_colorbase[2]:=8;
sprite_colorbase:=16;
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@aliens_dip_a;
marcade.dswb:=$5e;
marcade.dswb_val:=@aliens_dip_b;
marcade.dswc:=$ff;
marcade.dswc_val:=@aliens_dip_c;
//final
reset_aliens;
iniciar_aliens:=true;
end;

procedure cerrar_aliens;
begin
main_konami.free;
snd_z80.free;
YM2151_close(0);
k052109_0.Free;
k051960_0.free;
k007232_0.free;
freemem(k007232_rom);
freemem(sprite_rom);
freemem(tiles_rom);
close_audio;
close_video;
end;

procedure reset_aliens;
begin
 main_konami.reset;
 snd_z80.reset;
 k052109_0.reset;
 YM2151_reset(0);
 k051960_0.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 sound_latch:=0;
 bank0_bank:=0;
 rom_bank1:=0;
end;

procedure aliens_cb(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
begin
code:=code or (((color and $3f) shl 8) or (bank shl 14));
color:=layer_colorbase[layer]+((color and $c0) shr 6);
end;

procedure aliens_sprite_cb(var code:word;var color:word;var pri:word;var shadow:word);
begin
// The PROM allows for mixed priorities, where sprites would have */
// priority over text but not on one or both of the other two planes. */
case (color and $70) of
     $10:pri:=0 ;      // over ABF */
     $0:pri:=4;       //over AB, not F */
     $40:pri:=6;      // over A, not BF */
     $20,$60:pri:=7;  // over -, not ABF */
     $50:pri:=2;      // over AF, not B */
     $30,$70:pri:=3;  // over F, not AB */
end;
code:=code or ((color and $80) shl 6);
color:=sprite_colorbase+(color and $f);
shadow:=0;  // shadows are not used by this game
end;

procedure aliens_k007232_cb(valor:byte);
begin
  k007232_0.set_volume(0,(valor and $f)*$11,0);
  k007232_0.set_volume(1,0,(valor shr 4)*$11);
end;

procedure draw_layer(layer:byte);inline;
var
  f:word;
begin
case layer of
  0:actualiza_trozo(0,0,512,256,1,0,0,512,256,4); //Esta es fija
  1:begin
      case k052109_0.scroll_tipo[1] of
        0,1:for f:=0 to $ff do scroll__x_part(2,4,k052109_0.scroll_x[1,f],k052109_0.scroll_y[1,0],f,1);
        2:for f:=0 to $1ff do scroll__y_part(2,4,k052109_0.scroll_y[1,f],k052109_0.scroll_x[1,0],f,1);
        3:scroll_x_y(2,4,k052109_0.scroll_x[1,0],k052109_0.scroll_y[1,0]);
      end;
    end;
  2:begin
      case k052109_0.scroll_tipo[2] of
        0,1:for f:=0 to $ff do scroll__x_part(3,4,k052109_0.scroll_x[2,f],k052109_0.scroll_y[2,0],f,1);
        2:for f:=0 to $1ff do scroll__y_part(3,4,k052109_0.scroll_y[2,f],k052109_0.scroll_x[2,0],f,1);
        3:scroll_x_y(3,4,k052109_0.scroll_x[2,0],k052109_0.scroll_y[2,0]);
      end;
    end;
end;
end;

procedure update_video_aliens;
begin
k052109_0.draw_tiles;
fill_full_screen(4,layer_colorbase[1]*16);
k051960_0.draw_sprites(7,-1);
draw_layer(1); //A
k051960_0.draw_sprites(6,-1);
k051960_0.draw_sprites(2,-1);
draw_layer(2); //B
k051960_0.draw_sprites(4,-1);
k051960_0.draw_sprites(3,-1);
draw_layer(0); //F
k051960_0.draw_sprites(0,-1);
actualiza_trozo_final(112,16,288,224,4);
end;

procedure eventos_aliens;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
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
frame_m:=main_konami.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
    for f:=0 to $ff do begin
    //main
    main_konami.run(frame_m);
    frame_m:=frame_m+main_konami.tframes-main_konami.contador;
    //sound
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=239 then begin
                    update_video_aliens;
                    if k051960_0.is_irq_enabled then main_konami.change_irq(HOLD_LINE);
                  end;
    end;
    eventos_aliens;
    video_sync;
end;
end;

//Main CPU
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
                           else begin
                                direccion:=direccion and $3fff;
                                if k052109_0.get_rmrd_line=CLEAR_LINE then begin
                                   if ((direccion>=$3800) and (direccion<$3808)) then aliens_getbyte:=k051960_0.k051937_read(direccion-$3800)
                                      else if (direccion<$3c00) then aliens_getbyte:=k052109_0.read(direccion)
                                           else aliens_getbyte:=k051960_0.read(direccion-$3c00);
                                end else aliens_getbyte:=k052109_0.read(direccion and $3fff);
                           end;
                 end;
    end;
end;

procedure cambiar_color(pos:word);inline;
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

procedure aliens_putbyte(direccion:word;valor:byte);
begin
if direccion>$7fff then exit;
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
                                    snd_z80.pedir_irq:=HOLD_LINE;
                               end;
                         else begin
                              direccion:=direccion and $3fff;
                              if ((direccion>=$3800) and (direccion<$3808)) then k051960_0.k051937_write(direccion-$3800,valor)
                                 else if (direccion<$3c00) then k052109_0.write(direccion,valor)
                                      else k051960_0.write(direccion-$3c00,valor);
                         end;
                 end;
end;
end;

procedure aliens_bank(valor:byte);
begin
     rom_bank1:=valor and $1f;
end;

//Audio CPU
function aliens_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:aliens_snd_getbyte:=mem_snd[direccion];
  $a001:aliens_snd_getbyte:=YM2151_status_port_read(0);
  $c000:aliens_snd_getbyte:=sound_latch;
  $e000..$e00d:aliens_snd_getbyte:=k007232_0.read(direccion and $f);
end;
end;

procedure aliens_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $8000..$87ff:mem_snd[direccion]:=valor;
  $a000:YM2151_register_port_write(0,valor);
  $a001:YM2151_data_port_write(0,valor);
  $e000..$e00d:k007232_0.write(direccion and $f,valor);
end;
end;

procedure aliens_snd_bankswitch(valor:byte);
begin
// b1: bank for chanel A */
// b0: bank for chanel B */
k007232_0.set_bank(BIT_n(valor,1),BIT_n(valor,0));
end;

procedure aliens_sound_update;
begin
  ym2151_Update(0);
  k007232_0.update;
end;

end.
