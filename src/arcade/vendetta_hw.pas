unit vendetta_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,konami,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,ym_2151,k052109,k053260,k053246_k053247_k055673,
     k054000,k053251,timer_engine,eepromser;

function iniciar_vendetta:boolean;

implementation
const
        //vendetta
        vendetta_rom:tipo_roms=(n:'081u01.17c';l:$40000;p:0;crc:$b4d9ade5);
        vendetta_sound:tipo_roms=(n:'081b02';l:$10000;p:0;crc:$4c604d9b);
        vendetta_tiles:array[0..1] of tipo_roms=(
        (n:'081a09';l:$80000;p:0;crc:$b4c777a9),(n:'081a08';l:$80000;p:2;crc:$272ac8d9));
        vendetta_sprites:array[0..3] of tipo_roms=(
        (n:'081a04';l:$100000;p:0;crc:$464b9aa4),(n:'081a05';l:$100000;p:2;crc:$4e173759),
        (n:'081a06';l:$100000;p:4;crc:$e9fe6d80),(n:'081a07';l:$100000;p:6;crc:$8a22b29a));
        vendetta_k053260:tipo_roms=(n:'081a03';l:$100000;p:0;crc:$14b6baea);
        vendetta_eeprom:tipo_roms=(n:'vendetta.nv';l:$80;p:0;crc:$fbac4e30);
        //DIP
        vendetta_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$02;dip_name:'4C 1C'),(dip_val:$05;dip_name:'3C 1C'),(dip_val:$08;dip_name:'2C 1C'),(dip_val:$04;dip_name:'3C 2C'),(dip_val:$01;dip_name:'4C 3C'),(dip_val:$0f;dip_name:'1C 1C'),(dip_val:$03;dip_name:'3C 4C'),(dip_val:$07;dip_name:'2C 3C'),(dip_val:$0e;dip_name:'1C 2C'),(dip_val:$06;dip_name:'2C 5C'),(dip_val:$0d;dip_name:'1C 3C'),(dip_val:$0c;dip_name:'1C 4C'),(dip_val:$0b;dip_name:'1C 5C'),(dip_val:$0a;dip_name:'1C 6C'),(dip_val:$09;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$20;dip_name:'4C 1C'),(dip_val:$50;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$40;dip_name:'3C 2C'),(dip_val:$10;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'3C 4C'),(dip_val:$70;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$60;dip_name:'2C 5C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$90;dip_name:'1C 7C'),(dip_val:$0;dip_name:'No Coin'))),());
        vendetta_dip_b:array [0..3] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'1'),(dip_val:$2;dip_name:'2'),(dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        vendetta_dip_c:array [0..1] of def_dip=(
        (mask:$1;name:'Flip Screen';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 tiles_rom,sprite_rom,k053260_rom:pbyte;
 sound_latch,sprite_colorbase,rom_bank1,video_bank,timer_n:byte;
 irq_enabled:boolean;
 layer_colorbase,layerpri:array[0..2] of byte;
 rom_bank:array[0..27,0..$1fff] of byte;

procedure vendetta_cb(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
begin
code:=code or (((color and $03) shl 8) or ((color and $30) shl 6) or ((color and $0c) shl 10) or (bank shl 14));
color:=layer_colorbase[layer]+((color and $c0) shr 6);
end;

procedure vendetta_sprite_cb(var code:dword;var color:word;var priority_mask:word);
var
  pri:integer;
begin
	pri:=(color and $03e0) shr 4;   // ???????
	if (pri<=layerpri[2]) then priority_mask:=0
	  else if ((pri>layerpri[2]) and (pri<=layerpri[1])) then priority_mask:=1
	    else if ((pri>layerpri[1]) and (pri<=layerpri[0])) then priority_mask:=2
	      else priority_mask:=3;
	color:=sprite_colorbase+(color and $001f);
end;

procedure update_video_vendetta;
var
  bg_colorbase:byte;
  sorted_layer:array[0..2] of byte;
begin
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
bg_colorbase:=k053251_0.get_palette_index(K053251_CI0);
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
k052109_0.draw_tiles;
k053246_0.k053247_update_sprites;
fill_full_screen(4,bg_colorbase*16);
k053246_0.k053247_draw_sprites(3);
k052109_0.draw_layer(sorted_layer[0],4);
k053246_0.k053247_draw_sprites(2);
k052109_0.draw_layer(sorted_layer[1],4);
k053246_0.k053247_draw_sprites(1);
k052109_0.draw_layer(sorted_layer[2],4);
k053246_0.k053247_draw_sprites(0);
actualiza_trozo_final(112,16,288,224,4);
end;

procedure eventos_vendetta;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $Fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $F7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //Service
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
end;
end;

procedure vendetta_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=konami_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
    for f:=0 to $ff do begin
      //main
      konami_0.run(frame_m);
      frame_m:=frame_m+konami_0.tframes-konami_0.contador;
      //sound
      z80_0.run(frame_s);
      frame_s:=frame_s+z80_0.tframes-z80_0.contador;
      if f=239 then begin
        if irq_enabled then konami_0.change_irq(HOLD_LINE);
        update_video_vendetta;
      end;
    end;
    eventos_vendetta;
    video_sync;
end;
end;

function vendetta_getbyte(direccion:word):byte;
begin
case direccion of
    0..$1fff:vendetta_getbyte:=rom_bank[rom_bank1,direccion];
    $2000..$3fff,$8000..$ffff:vendetta_getbyte:=memoria[direccion];
    $4000..$4fff:if video_bank=0 then vendetta_getbyte:=k052109_0.read(direccion and $fff)
                    else vendetta_getbyte:=k053246_0.k053247_r(direccion and $fff);
    $5f80..$5f9f:vendetta_getbyte:=k054000_0.read(direccion and $1f);
    $5fc0:vendetta_getbyte:=marcade.in0; //p1
    $5fc1:vendetta_getbyte:=marcade.in1; //p2
    $5fc2:vendetta_getbyte:=$ff; //p3
    $5fc3:vendetta_getbyte:=$ff; //p3
    $5fd0:vendetta_getbyte:=er5911_do_read+(er5911_ready_read shl 1)+$f4;
    $5fd1:vendetta_getbyte:=marcade.in2; //service
    $5fe4:begin
            z80_0.change_irq(HOLD_LINE);
            vendetta_getbyte:=0;
          end;
    $5fe6..$5fe7:vendetta_getbyte:=k053260_0.main_read(direccion and 1);
    $5fe8..$5fe9:vendetta_getbyte:=k053246_0.read(direccion and 1);
    $5fea:vendetta_getbyte:=0;
    $6000..$6fff:if video_bank=0 then vendetta_getbyte:=k052109_0.read($2000+(direccion and $fff))
                  else vendetta_getbyte:=buffer_paleta[direccion and $fff];
    else vendetta_getbyte:=k052109_0.read(direccion and $3fff);
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

procedure vendetta_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$1fff,$8000..$ffff:; //ROM
    $2000..$3fff:memoria[direccion]:=valor;
    $4000..$4fff:if video_bank=0 then k052109_0.write(direccion and $fff,valor)
                    else k053246_0.k053247_w(direccion and $fff,valor);
    $5f80..$5f9f:k054000_0.write(direccion and $1f,valor);
    $5fa0..$5faf:k053251_0.write(direccion and $f,valor);
    $5fb0..$5fb7:k053246_0.write(direccion and $7,valor);
    $5fe0:begin
            if (valor and $8)<>0 then k052109_0.set_rmrd_line(ASSERT_LINE)
              else k052109_0.set_rmrd_line(CLEAR_LINE);
            if (valor and $20)<>0 then k053246_0.set_objcha_line(ASSERT_LINE)
              else k053246_0.set_objcha_line(CLEAR_LINE);
          end;
    $5fe2:begin
            if valor=$ff then exit;
            irq_enabled:=((valor shr 6) and 1)<>0;
            video_bank:=valor and 1;
            er5911_di_write((valor shr 5) and 1);
            er5911_cs_write((valor shr 3) and 1);
            er5911_clk_write((valor shr 4) and 1);
          end;
    $5fe4:z80_0.change_irq(HOLD_LINE);
    $5fe6..$5fe7:k053260_0.main_write(direccion and 1,valor);
    $6000..$6fff:if video_bank=0 then begin
                  direccion:=direccion and $fff;
                  if ((direccion=$1d80) or (direccion=$1e00) or (direccion=$1f00)) then k052109_0.write(direccion,valor);
	                k052109_0.write(direccion+$2000,valor);
                 end else if buffer_paleta[direccion and $fff]<>valor then begin
                          buffer_paleta[direccion and $fff]:=valor;
                          cambiar_color((direccion and $fff) shr 1);
                       end;
    else k052109_0.write(direccion and $3fff,valor);
end;
end;

procedure vendetta_bank(valor:byte);
begin
  rom_bank1:=valor and $1f;
end;

function vendetta_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$f7ff:vendetta_snd_getbyte:=mem_snd[direccion];
  $f801:vendetta_snd_getbyte:=ym2151_0.status;
  $fc00..$fc2f:vendetta_snd_getbyte:=k053260_0.read(direccion and $3f);
end;
end;

procedure vendetta_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$efff:; //ROM
  $f000..$f7ff:mem_snd[direccion]:=valor;
  $f800:ym2151_0.reg(valor);
  $f801:ym2151_0.write(valor);
  $fa00:begin
          z80_0.change_nmi(ASSERT_LINE);
          timers.enabled(timer_n,true);
        end;
  $fc00..$fc2f:k053260_0.write(direccion and $3f,valor);
end;
end;

procedure vendetta_clear_nmi;
begin
  timers.enabled(timer_n,false);
  z80_0.change_nmi(CLEAR_LINE);
end;

procedure vendetta_sound_update;
begin
  ym2151_0.update;
  k053260_0.update;
end;

//Main
procedure reset_vendetta;
begin
 konami_0.reset;
 z80_0.reset;
 k052109_0.reset;
 k053260_0.reset;
 k053251_0.reset;
 k054000_0.reset;
 k053246_0.reset;
 ym2151_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 sound_latch:=0;
 rom_bank1:=0;
 irq_enabled:=false;
 video_bank:=0;
end;

procedure cerrar_vendetta;
begin
if k053260_rom<>nil then freemem(k053260_rom);
if sprite_rom<>nil then freemem(sprite_rom);
if tiles_rom<>nil then freemem(tiles_rom);
k053260_rom:=nil;
sprite_rom:=nil;
tiles_rom:=nil;
end;

function iniciar_vendetta:boolean;
var
   temp_mem:array[0..$3ffff] of byte;
   f:byte;
begin
llamadas_maquina.close:=cerrar_vendetta;
llamadas_maquina.reset:=reset_vendetta;
llamadas_maquina.bucle_general:=vendetta_principal;
llamadas_maquina.fps_max:=59.17;
iniciar_vendetta:=false;
//Pantallas para el K052109
screen_init(1,512,256,true);
screen_init(2,512,256,true);
screen_mod_scroll(2,512,512,511,256,256,255);
screen_init(3,512,256,true);
screen_mod_scroll(3,512,512,511,256,256,255);
screen_init(4,1024,1024,false,true);
iniciar_video(288,224,true);
iniciar_audio(true);
//cargar roms y ponerlas en su sitio...
if not(roms_load(@temp_mem,vendetta_rom)) then exit;
copymemory(@memoria[$8000],@temp_mem[$38000],$8000);
for f:=0 to 27 do copymemory(@rom_bank[f,0],@temp_mem[f*$2000],$2000);
//cargar sonido
if not(roms_load(@mem_snd,vendetta_sound)) then exit;
//Main CPU
konami_0:=cpu_konami.create(3000000,256);
konami_0.change_ram_calls(vendetta_getbyte,vendetta_putbyte);
konami_0.change_set_lines(vendetta_bank);
//Sound CPU
z80_0:=cpu_z80.create(3579545,256);
z80_0.change_ram_calls(vendetta_snd_getbyte,vendetta_snd_putbyte);
z80_0.init_sound(vendetta_sound_update);
timer_n:=timers.init(z80_0.numero_cpu,90,vendetta_clear_nmi,nil,false);
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
getmem(k053260_rom,$100000);
if not(roms_load(k053260_rom,vendetta_k053260)) then exit;
k053260_0:=tk053260_chip.create(3579545,k053260_rom,$100000,0.70);
//Iniciar video
layer_colorbase[0]:=0;
layer_colorbase[1]:=0;
layer_colorbase[2]:=0;
layerpri[0]:=0;
layerpri[1]:=0;
layerpri[2]:=0;
sprite_colorbase:=0;
//Prioridad
k053251_0:=k053251_chip.create;
//tiles
getmem(tiles_rom,$100000);
if not(roms_load32b(tiles_rom,vendetta_tiles)) then exit;
k052109_0:=k052109_chip.create(1,2,3,0,vendetta_cb,tiles_rom,$100000);
//sprites
getmem(sprite_rom,$400000);
if not(roms_load64b(sprite_rom,vendetta_sprites)) then exit;
k053246_0:=k053246_chip.create(4,vendetta_sprite_cb,sprite_rom,$400000);
k053246_0.k053247_start;
//eeprom
eepromser_init(ER5911,8);
if not(roms_load(@temp_mem,vendetta_eeprom)) then exit;
eepromser_load_data(@temp_mem,$80);
//protection
k054000_0:=k054000_chip.create;
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@vendetta_dip_a;
marcade.dswb:=$5e;
marcade.dswb_val:=@vendetta_dip_b;
marcade.dswc:=$ff;
marcade.dswc_val:=@vendetta_dip_c;
//final
reset_vendetta;
iniciar_vendetta:=true;
end;

end.
