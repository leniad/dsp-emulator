unit simpsons_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,konami,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,ym_2151,k052109,k053260,eepromser,timer_engine,
     k053251,k053246_k053247_k055673;

procedure cargar_simpsons;

implementation
const
        simpsons_rom:array[0..4] of tipo_roms=(
        (n:'072-g02.16c';l:$20000;p:0;crc:$580ce1d6),(n:'072-g01.17c';l:$20000;p:$20000;crc:$9f843def),
        (n:'072-j13.13c';l:$20000;p:$40000;crc:$aade2abd),(n:'072-j12.15c';l:$20000;p:$60000;crc:$479e12f2),());
        simpsons_sound:tipo_roms=(n:'072-e03.6g';l:$20000;p:0;crc:$866b7a35);
        simpsons_tiles:array[0..2] of tipo_roms=(
        (n:'072-b07.18h';l:$80000;p:0;crc:$ba1ec910),(n:'072-b06.16h';l:$80000;p:2;crc:$cf2bbcab),());
        simpsons_sprites:array[0..4] of tipo_roms=(
        (n:'072-b08.3n';l:$100000;p:0;crc:$7de500ad),(n:'072-b09.8n';l:$100000;p:2;crc:$aa085093),
        (n:'072-b10.12n';l:$100000;p:4;crc:$577dbd53),(n:'072-b11.16l';l:$100000;p:6;crc:$55fab05d),());
        simpsons_k053260:array[0..2] of tipo_roms=(
        (n:'072-d05.1f';l:$100000;p:0;crc:$1397a73b),(n:'072-d04.1d';l:$40000;p:2;crc:$78778013),());
        simpsons_eeprom:tipo_roms=(n:'simpsons.12c.nv';l:$80;p:0;crc:$ec3f0449);
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
 tiles_rom,sprite_rom,k053260_rom:pbyte;
 sprite_colorbase,bank0_bank,bank2000_bank,rom_bank1,sound_bank,snd_timer,sprite_timer:byte;
 layer_colorbase,layerpri:array[0..2] of byte;
 rom_bank:array[0..$3f,0..$1fff] of byte;
 sound_rom_bank:array[0..7,0..$3fff] of byte;
 firq_enabled:boolean;
 sprite_ram:array[0..$7ff] of word;

procedure reset_simpsons;
begin
 main_konami.reset;
 snd_z80.reset;
 k052109_0.reset;
 k053251_0.reset;
 ym2151_0.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 bank0_bank:=0;
 bank2000_bank:=0;
 rom_bank1:=0;
 sound_bank:=0;
 firq_enabled:=false;
end;

procedure simpsons_cb(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
begin
code:=code or (((color and $3f) shl 8) or (bank shl 14));
color:=layer_colorbase[layer]+((color and $c0) shr 6);
end;

procedure simpsons_sprites_firq;
begin
timer[sprite_timer].enabled:=false;
if firq_enabled then main_konami.change_firq(HOLD_LINE);
end;

procedure update_video_simpsons;
var
  bg_colorbase:byte;
  sorted_layer:array[0..2] of byte;
begin
bg_colorbase:=k053251_0.get_palette_index(K053251_CI0);
sprite_colorbase:=k053251_0.get_palette_index(K053251_CI1);
layer_colorbase[0]:=k053251_0.get_palette_index(K053251_CI2);
layer_colorbase[1]:=k053251_0.get_palette_index(K053251_CI3);
layer_colorbase[2]:=k053251_0.get_palette_index(K053251_CI4);
k052109_0.draw_tiles;
sorted_layer[0]:=0;
layerpri[0]:=k053251_0.get_priority(K053251_CI2);
sorted_layer[1]:=1;
layerpri[1]:=k053251_0.get_priority(K053251_CI3);
sorted_layer[2]:=2;
layerpri[2]:=k053251_0.get_priority(K053251_CI4);
konami_sortlayers3(@sorted_layer,@layerpri);
fill_full_screen(4,bg_colorbase*16);
k052109_0.draw_layer(sorted_layer[0],4);
k052109_0.draw_layer(sorted_layer[1],4);
k052109_0.draw_layer(sorted_layer[2],4);
actualiza_trozo_final(112,16,288,224,4);
end;

procedure eventos_simpsons;
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

procedure simpsons_principal;
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
                    update_video_simpsons;
                    if k052109_0.is_irq_enabled then main_konami.change_irq(HOLD_LINE);
                    if k053246_0.is_irq_enabled then begin
                       //simpsons_objdma();
                       timer[sprite_timer].enabled:=true;
                    end;
                  end;
    end;
    eventos_simpsons;
    video_sync;
end;
end;

//Main CPU
function simpsons_getbyte(direccion:word):byte;
var
  tempw:word;
begin
case direccion of
    0..$fff:if bank0_bank=0 then simpsons_getbyte:=k052109_0.read(direccion)
                              else simpsons_getbyte:=buffer_paleta[direccion];
    $1000..$1fff:case direccion of
                   $1f80:simpsons_getbyte:=$ff; //coin
                   $1f81:simpsons_getbyte:=$cf+(er5911_do_read shl 4)+(er5911_ready_read shl 5); //eeprom+service
                   $1f90:simpsons_getbyte:=$ff; //p1
                   $1f91:simpsons_getbyte:=$ff; //p2
                   $1f92:simpsons_getbyte:=$ff; //p3
                   $1f93:simpsons_getbyte:=$ff; //p4
                   $1fc4:begin
                            simpsons_getbyte:=0;
                            snd_z80.change_irq(HOLD_LINE);
                         end;
                   $1fc6..$1fc7:simpsons_getbyte:=k053260_0.main_read(direccion and $1);
                   $1fc8..$1fc9:simpsons_getbyte:=k053246_0.read(direccion and 1);
                   $1fca:; //Watchdog
                   else simpsons_getbyte:=k052109_0.read(direccion)
              end;
    $2000..$3fff:if bank2000_bank=0 then simpsons_getbyte:=k052109_0.read(direccion)
                    else if (direccion>$2fff) then simpsons_getbyte:=memoria[direccion]
                         else begin //k053247
                                  tempw:=(direccion and $fff) shr 1;
                                  if (direccion and 1)<>0 then simpsons_getbyte:=sprite_ram[tempw] and $ff
                                     else simpsons_getbyte:=sprite_ram[tempw] shr 8;
                              end;
    $4000..$5fff,$8000..$ffff:simpsons_getbyte:=memoria[direccion];
    $6000..$7fff:simpsons_getbyte:=rom_bank[rom_bank1,direccion and $1fff];
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

procedure simpsons_putbyte(direccion:word;valor:byte);
var
   tempw:word;
begin
if direccion>$5fff then exit;
case direccion of
    0..$fff:if bank0_bank=1 then begin
                             if buffer_paleta[direccion]<>valor then begin
                                buffer_paleta[direccion]:=valor;
                                cambiar_color(direccion shr 1);
                             end;
                          end else k052109_0.write(direccion,valor);
    $1000..$1fff:case direccion of
                  $1fa0..$1fa7:k053246_0.write(direccion and $7,valor);
                  $1fb0..$1fbf:k053251_0.write(direccion and $f,valor);
                  $1fc0:begin
                             if (valor and 8)<>0 then k052109_0.set_rmrd_line(ASSERT_LINE)
                                else k052109_0.set_rmrd_line(CLEAR_LINE);
                             if (valor and $20)=0 then k053246_0.set_objcha_line(ASSERT_LINE)
                                else k053246_0.set_objcha_line(CLEAR_LINE);
                        end;
                  $1fc2:if (valor<>$ff) then begin
                           er5911_di_write((valor shr 7) and 1);
                           er5911_cs_write((valor shr 3) and 1);
                           er5911_clk_write((valor shr 4) and 1);
                           bank0_bank:=valor and 1;
                           bank2000_bank:=(valor shr 1) and 1;
                           firq_enabled:=(valor and $4)<>0;
                        end;
                  $1fc6..$1fc7:k053260_0.main_write(direccion and 1,valor);
                  else k052109_0.write(direccion,valor);
             end;
    $2000..$3fff:if bank2000_bank=0 then k052109_0.write(direccion,valor)
                    else if (direccion>$2fff) then memoria[direccion]:=valor
                         else begin //k053247
                                tempw:=(direccion and $fff) shr 1;
                                if (direccion and 1)<>0 then sprite_ram[tempw]:=(sprite_ram[tempw] and $ff00) or valor
                                   else sprite_ram[tempw]:=(sprite_ram[tempw] and $ff) or (valor shl 8);
                              end;
    $4000..$5fff:memoria[direccion]:=valor;
end;
end;

procedure simpsons_bank(valor:byte);
begin
     rom_bank1:=valor and $3f;
end;

//Audio CPU
function simpsons_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$f000..$f7ff:simpsons_snd_getbyte:=mem_snd[direccion];
  $8000..$bfff:simpsons_snd_getbyte:=sound_rom_bank[sound_bank,direccion and $3fff];
  $f801:simpsons_snd_getbyte:=ym2151_0.status;
  $fc00..$fc2f:simpsons_snd_getbyte:=k053260_0.read(direccion and $3f);
end;
end;

procedure simpsons_nmi;
begin
timer[snd_timer].enabled:=false;
snd_z80.change_nmi(ASSERT_LINE);
end;

procedure simpsons_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$c000 then exit;
case direccion of
  $f000..$f7ff:mem_snd[direccion]:=valor;
  $f800:ym2151_0.reg(valor);
  $f801:ym2151_0.write(valor);
  $fa00:begin
             snd_z80.change_nmi(CLEAR_LINE);
             timer[snd_timer].enabled:=true;
        end;
  $fc00..$fc2f:k053260_0.write(direccion and $3f,valor);
  $fe00:sound_bank:=valor and $7;
end;
end;

procedure simpsons_sound_update;
begin
  ym2151_0.update;
  k053260_0.update;
end;

//Main
procedure cerrar_simpsons;
begin
if sprite_rom<>nil then freemem(sprite_rom);
if tiles_rom<>nil then freemem(tiles_rom);
if k053260_rom<>nil then freemem(k053260_rom);
sprite_rom:=nil;
tiles_rom:=nil;
k053260_rom:=nil;
end;

function iniciar_simpsons:boolean;
var
   temp_mem:array[0..$7ffff] of byte;
   f:byte;
begin
iniciar_simpsons:=false;
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
if not(cargar_roms(@temp_mem[0],@simpsons_rom[0],'simpsons.zip',0)) then exit;
copymemory(@memoria[$8000],@temp_mem[$78000],$8000);
for f:=0 to $3f do copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
//cargar sonido
if not(cargar_roms(@temp_mem[0],@simpsons_sound,'simpsons.zip',1)) then exit;
copymemory(@mem_snd[0],@temp_mem[0],$8000);
copymemory(@sound_rom_bank[0,0],@temp_mem[$8000],$4000); //?????
copymemory(@sound_rom_bank[1,0],@temp_mem[$8000],$4000);
copymemory(@sound_rom_bank[2,0],@temp_mem[$8000],$4000);
for f:=3 to 7 do copymemory(@sound_rom_bank[f,0],@temp_mem[$c000+((f-3)*$4000)],$4000);
//Main CPU
main_konami:=cpu_konami.create(3000000,256);
main_konami.change_ram_calls(simpsons_getbyte,simpsons_putbyte);
main_konami.change_set_lines(simpsons_bank);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,256);
snd_z80.change_ram_calls(simpsons_snd_getbyte,simpsons_snd_putbyte);
snd_z80.init_sound(simpsons_sound_update);
snd_timer:=init_timer(main_konami.numero_cpu,25,simpsons_nmi,false);
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
getmem(k053260_rom,$140000);
if not(cargar_roms(k053260_rom,@simpsons_k053260,'simpsons.zip',0)) then exit;
k053260_0:=tk053260_chip.create(3579545,k053260_rom,$140000,0.70);
//eeprom
eepromser_init(ER5911,8);
if not(cargar_roms(@temp_mem[0],@simpsons_eeprom,'simpsons.zip',1)) then exit;
eepromser_load_data(@temp_mem[0],$80);
//Prioridades
k053251_0:=k053251_chip.create;
//Iniciar video
getmem(tiles_rom,$100000);
if not(cargar_roms32b(tiles_rom,@simpsons_tiles,'simpsons.zip',0)) then exit;
k052109_0:=k052109_chip.create(1,2,3,simpsons_cb,tiles_rom,$100000);
getmem(sprite_rom,$400000);
if not(cargar_roms32b(sprite_rom,@simpsons_sprites,'simpsons.zip',0)) then exit;
k053246_0:=k053246_chip.create(4,nil,sprite_rom,$400000);
sprite_timer:=init_timer(main_konami.numero_cpu,30,simpsons_sprites_firq,false);
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@aliens_dip_a;
marcade.dswb:=$5e;
marcade.dswb_val:=@aliens_dip_b;
marcade.dswc:=$ff;
marcade.dswc_val:=@aliens_dip_c;
//final
reset_simpsons;
iniciar_simpsons:=true;
end;

procedure Cargar_simpsons;
begin
llamadas_maquina.iniciar:=iniciar_simpsons;
llamadas_maquina.cerrar:=cerrar_simpsons;
llamadas_maquina.reset:=reset_simpsons;
llamadas_maquina.bucle_general:=simpsons_principal;
llamadas_maquina.fps_max:=59.185606;
end;

end.
