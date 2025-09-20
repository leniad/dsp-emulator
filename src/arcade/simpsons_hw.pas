unit simpsons_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,konami,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,ym_2151,k052109,k053260,eepromser,timer_engine,
     k053251,k053246_k053247_k055673;

function iniciar_simpsons:boolean;

implementation
const
        simpsons_rom:array[0..3] of tipo_roms=(
        (n:'072-g02.16c';l:$20000;p:0;crc:$580ce1d6),(n:'072-p01.17c';l:$20000;p:$20000;crc:$07ceeaea),
        (n:'072-013.13c';l:$20000;p:$40000;crc:$8781105a),(n:'072-012.15c';l:$20000;p:$60000;crc:$244f9289));
        simpsons_sound:tipo_roms=(n:'072-g03.6g';l:$20000;p:0;crc:$76c1850c);
        simpsons_tiles:array[0..1] of tipo_roms=(
        (n:'072-b07.18h';l:$80000;p:0;crc:$ba1ec910),(n:'072-b06.16h';l:$80000;p:2;crc:$cf2bbcab));
        simpsons_sprites:array[0..3] of tipo_roms=(
        (n:'072-b08.3n';l:$100000;p:0;crc:$7de500ad),(n:'072-b09.8n';l:$100000;p:2;crc:$aa085093),
        (n:'072-b10.12n';l:$100000;p:4;crc:$577dbd53),(n:'072-b11.16l';l:$100000;p:6;crc:$55fab05d));
        simpsons_k053260:array[0..1] of tipo_roms=(
        (n:'072-d05.1f';l:$100000;p:0;crc:$1397a73b),(n:'072-d04.1d';l:$40000;p:$100000;crc:$78778013));
        simpsons_eeprom:tipo_roms=(n:'simpsons2p.12c.nv';l:$80;p:0;crc:$fbac4e30);

var
 tiles_rom,sprite_rom,k053260_rom:pbyte;
 sprite_colorbase,bank0_bank,bank2000_bank,rom_bank1,sound_bank,snd_timer,sprite_timer_dmaon,sprite_timer_dmaoff:byte;
 layer_colorbase,layerpri:array[0..2] of byte;
 rom_bank:array[0..$3f,0..$1fff] of byte;
 sound_rom_bank:array[0..7,0..$3fff] of byte;
 firq_enabled:boolean;
 sprite_ram:array[0..$7ff] of word;

procedure simpsons_sprite_cb(var code:dword;var color:word;var priority_mask:word);
var
  pri:integer;
begin
	pri:=(color and $f80) shr 6;   // ???????
	if (pri<=layerpri[2]) then priority_mask:=0
	  else if ((pri>layerpri[2]) and (pri<=layerpri[1])) then priority_mask:=1
	    else if ((pri>layerpri[1]) and (pri<=layerpri[0])) then priority_mask:=2
	      else priority_mask:=3;
	color:=sprite_colorbase+(color and $1f);
end;

procedure simpsons_cb(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
begin
code:=code or (((color and $3f) shl 8) or (bank shl 14));
color:=layer_colorbase[layer]+((color and $c0) shr 6);
end;

procedure simpsons_sprites_dmaon;
begin
timers.enabled(sprite_timer_dmaon,false);
timers.enabled(sprite_timer_dmaoff,true);
if firq_enabled then konami_0.change_firq(ASSERT_LINE);
end;

procedure simpsons_sprites_dmaoff;
begin
timers.enabled(sprite_timer_dmaoff,false);
konami_0.change_firq(CLEAR_LINE);
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
sorted_layer[0]:=0;
layerpri[0]:=k053251_0.get_priority(K053251_CI2);
sorted_layer[1]:=1;
layerpri[1]:=k053251_0.get_priority(K053251_CI3);
sorted_layer[2]:=2;
layerpri[2]:=k053251_0.get_priority(K053251_CI4);
konami_sortlayers3(@sorted_layer,@layerpri);
if k053251_0.dirty_tmap[K053251_CI2] then begin
  k052109_0.clean_video_buffer_layer(0);
  k053251_0.dirty_tmap[K053251_CI2]:=false;
end;
if k053251_0.dirty_tmap[K053251_CI3] then begin
  k052109_0.clean_video_buffer_layer(1);
  k053251_0.dirty_tmap[K053251_CI3]:=false;
end;
if k053251_0.dirty_tmap[K053251_CI4] then begin
  k052109_0.clean_video_buffer_layer(2);
  k053251_0.dirty_tmap[K053251_CI4]:=false;
end;
fill_full_screen(4,bg_colorbase*16);
k052109_0.draw_tiles;
k053246_0.k053247_update_sprites;
k053246_0.k053247_draw_sprites(3);
k052109_0.draw_layer(sorted_layer[0],4);
k053246_0.k053247_draw_sprites(2);
k052109_0.draw_layer(sorted_layer[1],4);
k053246_0.k053247_draw_sprites(1);
k052109_0.draw_layer(sorted_layer[2],4);
k053246_0.k053247_draw_sprites(0);
actualiza_trozo_final(112,16,288,224,4);
end;

procedure eventos_simpsons;
begin
if event.arcade then begin
  //P1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //System
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
end;
end;

procedure simpsons_objdma;
var
	dst,src:pword;
  inac,count:word;
begin
	dst:=k053246_0.k053247_get_ram;
  src:=@sprite_ram[0];
  inac:=256;
  count:=256;
	repeat
		if (((src^ and $8000)<>0) and ((src^ and $ff)<>0)) then begin
			copymemory(dst,src,$10);
			inc(dst,8);
			inac:=inac-1;
		end;
		inc(src,8);
    count:=count-1;
	until (count=0);
	if (inac<>0) then repeat
      dst^:=0;
      inc(dst,8);
      inac:=inac-1;
  until (inac=0);
end;

procedure simpsons_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
      eventos_simpsons;
      if f=224 then begin
        if k052109_0.is_irq_enabled then konami_0.change_irq(HOLD_LINE);
        if k053246_0.is_irq_enabled then begin
          simpsons_objdma;
          timers.enabled(sprite_timer_dmaon,true);
        end;
        update_video_simpsons;
      end;
      //main
      konami_0.run(frame_main);
      frame_main:=frame_main+konami_0.tframes-konami_0.contador;
      //sound
      z80_0.run(frame_snd);
      frame_snd:=frame_snd+z80_0.tframes-z80_0.contador;
  end;
  video_sync;
end;
end;

//Main CPU
function simpsons_getbyte(direccion:word):byte;
var
  tempw:word;
begin
case direccion of
    0..$fff:if bank0_bank=1 then simpsons_getbyte:=buffer_paleta[direccion]
                else simpsons_getbyte:=k052109_0.read(direccion);
    $1000..$1fff:case direccion of
                   $1f80:simpsons_getbyte:=marcade.in2;
                   $1f81:simpsons_getbyte:=$cf+(eepromser_0.do_read shl 4)+(eepromser_0.ready_read shl 5);
                   $1f90:simpsons_getbyte:=marcade.in0;
                   $1f91:simpsons_getbyte:=marcade.in1;
                   $1f92:simpsons_getbyte:=$ff;
                   $1f93:simpsons_getbyte:=$ff;
                   $1fc4:begin
                            simpsons_getbyte:=0;
                            z80_0.change_irq(HOLD_LINE);
                         end;
                   $1fc6..$1fc7:simpsons_getbyte:=k053260_0.main_read(direccion and 1);
                   $1fc8..$1fc9:simpsons_getbyte:=k053246_0.read(direccion and 1);
                   $1fca:; //Watchdog
                      else simpsons_getbyte:=k052109_0.read(direccion)
              end;
    $2000..$3fff:if bank2000_bank=0 then simpsons_getbyte:=k052109_0.read(direccion)
                    else if (direccion>$2fff) then simpsons_getbyte:=memoria[direccion]
                         else begin //k053247
                                  tempw:=(direccion and $fff) shr 1;
                                  //simpsons_getbyte:=(sprite_ram[tempw] shr ((not(direccion) and 1)*8)) and $ff;
                                  if (direccion and 1)<>0 then simpsons_getbyte:=sprite_ram[tempw] and $ff
                                     else simpsons_getbyte:=sprite_ram[tempw] shr 8;
                              end;
    $4000..$5fff,$8000..$ffff:simpsons_getbyte:=memoria[direccion];
    $6000..$7fff:simpsons_getbyte:=rom_bank[rom_bank1,direccion and $1fff];
    end;
end;

procedure simpsons_putbyte(direccion:word;valor:byte);
var
   tempw:word;
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
    0..$fff:if bank0_bank=1 then begin
                if buffer_paleta[direccion]<>valor then begin
                  buffer_paleta[direccion]:=valor;
                  cambiar_color(direccion shr 1);
                end;
            end else k052109_0.write(direccion,valor);
    $1000..$1fff:case direccion of
                  $1fa0..$1fa7:k053246_0.write(direccion and 7,valor);
                  $1fb0..$1fbf:k053251_0.write(direccion and $f,valor);
                  $1fc0:begin
                             if (valor and 8)<>0 then k052109_0.set_rmrd_line(ASSERT_LINE)
                                else k052109_0.set_rmrd_line(CLEAR_LINE);
                             if (valor and $20)=0 then k053246_0.set_objcha_line(ASSERT_LINE)
                                else k053246_0.set_objcha_line(CLEAR_LINE);
                        end;
                  $1fc2:if (valor<>$ff) then begin
                           eepromser_0.di_write((valor shr 7) and 1);
                           eepromser_0.cs_write((valor shr 3) and 1);
                           eepromser_0.clk_write((valor shr 4) and 1);
                           bank0_bank:=valor and 1;
                           bank2000_bank:=(valor shr 1) and 1;
                           firq_enabled:=(valor and 4)<>0;
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
    $6000..$ffff:; //ROM
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
timers.enabled(snd_timer,false);
z80_0.change_nmi(CLEAR_LINE);
end;

procedure simpsons_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:; //ROM
  $f000..$f7ff:mem_snd[direccion]:=valor;
  $f800:ym2151_0.reg(valor);
  $f801:ym2151_0.write(valor);
  $fa00:begin
             z80_0.change_nmi(ASSERT_LINE);
             timers.enabled(snd_timer,true);
        end;
  $fc00..$fc2f:k053260_0.write(direccion and $3f,valor);
  $fe00:sound_bank:=valor and 7;
end;
end;

procedure simpsons_sound_update;
begin
  ym2151_0.update;
  k053260_0.update;
end;

//Main
procedure reset_simpsons;
begin
 konami_0.reset;
 z80_0.reset;
 frame_main:=konami_0.tframes;
 frame_snd:=z80_0.tframes;
 eepromser_0.reset;
 k052109_0.reset;
 k053251_0.reset;
 k053246_0.reset;
 k053260_0.reset;
 ym2151_0.reset;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 bank0_bank:=0;
 bank2000_bank:=0;
 rom_bank1:=0;
 sound_bank:=0;
 firq_enabled:=false;
end;

procedure cerrar_simpsons;
begin
if sprite_rom<>nil then freemem(sprite_rom);
if tiles_rom<>nil then freemem(tiles_rom);
if k053260_rom<>nil then freemem(k053260_rom);
sprite_rom:=nil;
tiles_rom:=nil;
k053260_rom:=nil;
eepromser_0.write_data('simpsons.nv')
end;

function iniciar_simpsons:boolean;
var
   memoria_temp:array[0..$7ffff] of byte;
   f:byte;
begin
llamadas_maquina.close:=cerrar_simpsons;
llamadas_maquina.reset:=reset_simpsons;
llamadas_maquina.bucle_general:=simpsons_principal;
llamadas_maquina.fps_max:=59.185606;
llamadas_maquina.scanlines:=264;
iniciar_simpsons:=false;
//Pantallas para el K052109
screen_init(1,512,256,true);
screen_init(2,512,256,true);
screen_init(3,512,256,true);
screen_init(4,1024,1024,false,true);
iniciar_video(288,224,true);
iniciar_audio(true);
//cargar roms y ponerlas en su sitio...
if not(roms_load(@memoria_temp,simpsons_rom)) then exit;
copymemory(@memoria[$8000],@memoria_temp[$78000],$8000);
for f:=0 to $3f do copymemory(@rom_bank[f,0],@memoria_temp[f*$2000],$2000);
//cargar sonido
if not(roms_load(@memoria_temp,simpsons_sound)) then exit;
copymemory(@mem_snd,@memoria_temp,$8000);
for f:=0 to 7 do copymemory(@sound_rom_bank[f,0],@memoria_temp[f*$4000],$4000);
//Main CPU
konami_0:=cpu_konami.create(12000000);
konami_0.change_ram_calls(simpsons_getbyte,simpsons_putbyte);
konami_0.change_set_lines(simpsons_bank);
//Sound CPU
z80_0:=cpu_z80.create(3579545);
z80_0.change_ram_calls(simpsons_snd_getbyte,simpsons_snd_putbyte);
z80_0.init_sound(simpsons_sound_update);
snd_timer:=timers.init(z80_0.numero_cpu,90,simpsons_nmi,nil,false);
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
getmem(k053260_rom,$140000);
if not(roms_load(k053260_rom,simpsons_k053260)) then exit;
k053260_0:=tk053260_chip.create(3579545,k053260_rom,$140000,0.70);
//eeprom
eepromser_0:=eepromser_chip.create(ER5911,8);
if not(eepromser_0.load_data('simpsons.nv')) then begin
  if not(roms_load(@memoria_temp,simpsons_eeprom)) then exit;
  copymemory(eepromser_0.get_data,@memoria_temp,$80);
end;
//Prioridades
k053251_0:=k053251_chip.create;
//Iniciar video
getmem(tiles_rom,$100000);
if not(roms_load32b(tiles_rom,simpsons_tiles)) then exit;
k052109_0:=k052109_chip.create(1,2,3,0,simpsons_cb,tiles_rom,$100000);
getmem(sprite_rom,$400000);
if not(roms_load64b(sprite_rom,simpsons_sprites)) then exit;
k053246_0:=k053246_chip.create(4,simpsons_sprite_cb,sprite_rom,$400000);
sprite_timer_dmaon:=timers.init(konami_0.numero_cpu,256,simpsons_sprites_dmaon,nil,false);
sprite_timer_dmaoff:=timers.init(konami_0.numero_cpu,2048,simpsons_sprites_dmaoff,nil,false);
k053246_0.k053247_start(0,16);
//final
iniciar_simpsons:=true;
end;

end.
