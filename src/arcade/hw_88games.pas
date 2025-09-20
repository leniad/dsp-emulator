unit hw_88games;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,konami,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,ym_2151,k052109,k051960,k051316,upd7759;

function iniciar_hw88games:boolean;

implementation
const
        hw88games_rom:array[0..1] of tipo_roms=(
        (n:'861m01.k18';l:$8000;p:0;crc:$4a4e2959),(n:'861m02.k16';l:$10000;p:$8000;crc:$e19f15f6));
        hw88games_sound:tipo_roms=(n:'861d01.d9';l:$8000;p:0;crc:$0ff1dec0);
        hw88games_tiles:array[0..7] of tipo_roms=(
        (n:'861a08.a';l:$10000;p:0;crc:$77a00dd6),(n:'861a08.c';l:$10000;p:1;crc:$b422edfc),
        (n:'861a09.a';l:$10000;p:2;crc:$df8917b6),(n:'861a09.c';l:$10000;p:3;crc:$f577b88f),
        (n:'861a08.b';l:$10000;p:$40000;crc:$28a8304f),(n:'861a08.d';l:$10000;p:$40001;crc:$e01a3802),
        (n:'861a09.b';l:$10000;p:$40002;crc:$4917158d),(n:'861a09.d';l:$10000;p:$40003;crc:$2bb3282c));
        hw88games_sprites:array[0..15] of tipo_roms=(
        (n:'861a05.a';l:$10000;p:0;crc:$cedc19d0),(n:'861a05.e';l:$10000;p:1;crc:$725af3fc),
        (n:'861a06.a';l:$10000;p:2;crc:$85e2e30e),(n:'861a06.e';l:$10000;p:3;crc:$6f96651c),
        (n:'861a05.b';l:$10000;p:$40000;crc:$db2a8808),(n:'861a05.f';l:$10000;p:$40001;crc:$32d830ca),
        (n:'861a06.b';l:$10000;p:$40002;crc:$ce17eaf0),(n:'861a06.f';l:$10000;p:$40003;crc:$88310bf3),
        (n:'861a05.c';l:$10000;p:$80000;crc:$cf03c449),(n:'861a05.g';l:$10000;p:$80001;crc:$fd51c4ea),
        (n:'861a06.c';l:$10000;p:$80002;crc:$a568b34e),(n:'861a06.g';l:$10000;p:$80003;crc:$4a55beb3),
        (n:'861a05.d';l:$10000;p:$c0000;crc:$97d78c77),(n:'861a05.h';l:$10000;p:$c0001;crc:$60d0c8a5),
        (n:'861a06.d';l:$10000;p:$c0002;crc:$bc70ab39),(n:'861a06.h';l:$10000;p:$c0003;crc:$d906b79b));
        hw88games_zoom:array[0..3] of tipo_roms=(
        (n:'861a04.a';l:$10000;p:0;crc:$092a8b15),(n:'861a04.b';l:$10000;p:$10000;crc:$75744b56),
        (n:'861a04.c';l:$10000;p:$20000;crc:$a00021c5),(n:'861a04.d';l:$10000;p:$30000;crc:$d208304c));
        hw88games_upd7759_0:array[0..1] of tipo_roms=(
        (n:'861a07.a';l:$10000;p:0;crc:$5d035d69),(n:'861a07.b';l:$10000;p:$10000;crc:$6337dd91));
        hw88games_upd7759_1:array[0..1] of tipo_roms=(
        (n:'861a07.c';l:$10000;p:0;crc:$5067a38b),(n:'861a07.d';l:$10000;p:$10000;crc:$86731451));
        hw88games_dip_a:array [0..1] of def_dip2=(
        (mask:$10;name:'Flip Screen';number:2;val2:($10,0);name2:('Off','On')),
        (mask:$20;name:'World Records';number:2;val2:($20,0);name2:('Don''t Erase','Erase on Reset')));
        hw88games_dip_b:array [0..1] of def_dip2=(
        (mask:$0f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),
        (mask:$f0;name:'Coin B';number:16;val16:($20,$50,$80,$40,$10,$f0,$30,$70,$30,$60,$d0,$c0,$b0,$a0,$90,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','No Coin')));
        hw88games_dip_c:array [0..2] of def_dip2=(
        (mask:$6;name:'Cabinet';number:4;val4:(6,4,2,0);name4:('Cocktail','Cocktail (A)','Upright','Upright (D)')),
        (mask:$60;name:'Difficulty';number:4;val4:($60,$40,$20,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')));

var
 zoom_rom,tiles_rom,sprite_rom:pbyte;
 speech_chip,rom_nbank,sound_latch:byte;
 rom_bank_mem:array[0..$7,0..$1fff] of byte;
 videobank,zoomreadroms,pal_ram,priority:boolean;

procedure hw88games_sprite_cb(var code:word;var color:word;var pri:word;var shadow:word);
const
  sprite_colorbase=512 div 16;
begin
pri:=(color and $20) shr 5;
color:=sprite_colorbase+(color and $f);
end;

procedure hw88games_cb(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
const
  layer_colorbase:array of word=[1024 div 16,0 div 16,256 div 16];
begin
	code:=code or (((color and $f) shl 8) or (bank shl 12));
	color:=layer_colorbase[layer]+((color and $f0) shr 4);
end;

procedure hw88games_k051316_cb(var code:word;var color:word;var priority_mask:word);
const
    zoom_colorbase=768 div 16;
begin
	code:=code or ((color and $07) shl 8);
	color:=zoom_colorbase+((color and $38) shr 3)+((color and $80) shr 4);
end;

procedure update_video_hw88games;
begin
k052109_0.draw_tiles;
k051960_0.update_sprites;
if priority then begin
  k052109_0.draw_layer(0,4);
  k051960_0.draw_sprites(1,-1);
  k052109_0.draw_layer(2,4);
  k052109_0.draw_layer(1,4);
  k051960_0.draw_sprites(0,-1);
  //k051316_0.draw(4);
end else begin
  k052109_0.draw_layer(2,4);
  //k051316_0.draw(4);
  k051960_0.draw_sprites(0,-1);
  k052109_0.draw_layer(1,4);
  k051960_0.draw_sprites(1,-1);
  k052109_0.draw_layer(0,4);
end;
actualiza_trozo_final(96,16,320,224,4);
end;

procedure eventos_hw88games;
begin
if event.arcade then begin
  //System
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  //P1+P2
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  //P3+P4
end;
end;

procedure hw88games_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
    for f:=0 to 255 do begin
      if f=240 then begin
        if k052109_0.is_irq_enabled then konami_0.change_irq(HOLD_LINE);
        update_video_hw88games;
      end;
      //main
      konami_0.run(frame_main);
      frame_main:=frame_main+konami_0.tframes-konami_0.contador;
      //sound
      z80_0.run(frame_snd);
      frame_snd:=frame_snd+z80_0.tframes-z80_0.contador;
    end;
eventos_hw88games;
video_sync;
end;
end;

//Main CPU
function hw88games_getbyte(direccion:word):byte;
begin
case direccion of
    0..$fff:hw88games_getbyte:=rom_bank_mem[rom_nbank,direccion];
    $1000..$1fff:if pal_ram then hw88games_getbyte:=buffer_paleta[direccion and $fff]
                    else hw88games_getbyte:=rom_bank_mem[rom_nbank,direccion];
    $2000..$37ff,$8000..$ffff:hw88games_getbyte:=memoria[direccion];
    $3800..$3fff:if videobank then hw88games_getbyte:=memoria[direccion]
                  else if zoomreadroms then hw88games_getbyte:=k051316_0.rom_read(direccion-$3800)
                        else hw88games_getbyte:=k051316_0.read(direccion-$3800);
    $4000..$7fff:case direccion of
                    $5f94:hw88games_getbyte:=marcade.in0 or marcade.dswa;
                    $5f95:hw88games_getbyte:=marcade.in1;
                    $5f96:hw88games_getbyte:=marcade.in2;
                    $5f97:hw88games_getbyte:=marcade.dswb;
                    $5f9b:hw88games_getbyte:=marcade.dswc;
                    else if k052109_0.get_rmrd_line=CLEAR_LINE then begin
                            direccion:=direccion and $3fff;
                            case direccion of
                                0..$37ff,$3808..$3bff:hw88games_getbyte:=k052109_0.read(direccion);
                                $3800..$3807:hw88games_getbyte:=k051960_0.k051937_read(direccion-$3800);
                                $3c00..$3fff:hw88games_getbyte:=k051960_0.read(direccion-$3c00);
                            end;
                         end else hw88games_getbyte:=k052109_0.read(direccion and $3fff);
                 end;
    end;
end;

procedure hw88games_putbyte(direccion:word;valor:byte);
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
    0..$fff,$8000..$ffff:; //ROM
    $1000..$1fff:if pal_ram then if buffer_paleta[direccion and $fff]<>valor then begin
                                    buffer_paleta[direccion and $fff]:=valor;
                                    cambiar_color((direccion and $fff) shr 1);
                                 end;
    $2000..$37ff:memoria[direccion]:=valor;
    $3800..$3fff:if videobank then memoria[direccion]:=valor
                  else k051316_0.write(direccion-$3800,valor);
    $4000..$7fff:case direccion of
                    $5f84:zoomreadroms:=(valor and $4)<>0;
	                  $5f88:; //WD
	                  $5f8c:sound_latch:=valor;
	                  $5f90:z80_0.change_irq(HOLD_LINE);
    	              $5fc0..$5fcf:k051316_0.control_w(direccion and $f,valor);
                    else begin
                            direccion:=direccion and $3fff;
                            case direccion of
                              0..$37ff,$3808..$3bff:k052109_0.write(direccion,valor);
                              $3800..$3807:k051960_0.k051937_write(direccion-$3800,valor);
                              $3c00..$3fff:k051960_0.write(direccion-$3c00,valor);
                            end;
                    end;
                 end;
end;
end;

procedure hw88games_bank(valor:byte);
begin
  // bits 0-2 select ROM bank for 0000-1fff
	// bit 3: when 1, palette RAM at 1000-1fff
	// bit 4: when 0, 051316 RAM at 3800-3fff; when 1, work RAM at 2000-3fff (NVRAM 3700-37ff)
	rom_nbank:=valor and $7;
  pal_ram:=(valor and $8)<>0;
	videobank:=(valor and $10)<>0;
	// bit 5 = enable char ROM reading through the video RAM
  if (valor and $20)<>0 then k052109_0.set_rmrd_line(ASSERT_LINE)
        else k052109_0.set_rmrd_line(CLEAR_LINE);
	// bit 6 is unknown, 1 most of the time
	// bit 7 controls layer priority
	priority:=(valor and $80)<>0;
end;

//Audio CPU
function hw88games_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$87ff:hw88games_snd_getbyte:=mem_snd[direccion];
  $a000:hw88games_snd_getbyte:=sound_latch;
  $c001:hw88games_snd_getbyte:=ym2151_0.status;
end;
end;

procedure hw88games_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$87ff:mem_snd[direccion]:=valor;
  $9000:if speech_chip<>0 then upd7759_1.port_w(valor)
          else upd7759_0.port_w(valor);
  $c000:ym2151_0.reg(valor);
  $c001:ym2151_0.write(valor);
  $e000:begin
          speech_chip:=(valor and 4);
          if speech_chip<>0 then begin
	          upd7759_1.reset_w((valor and 2) shr 1);
	          upd7759_1.start_w(not(valor) and 1);
          end else begin
            upd7759_0.reset_w((valor and 2) shr 1);
	          upd7759_0.start_w(not(valor) and 1);
          end;
        end;
end;
end;

procedure hw88games_sound_update;
begin
  ym2151_0.update;
  upd7759_0.update;
  upd7759_1.update;
end;

//Main
procedure reset_hw88games;
begin
 konami_0.reset;
 z80_0.reset;
 frame_main:=konami_0.tframes;
 frame_snd:=z80_0.tframes;
 k052109_0.reset;
 k051960_0.reset;
 k051316_0.reset;
 ym2151_0.reset;
 upd7759_0.reset;
 upd7759_1.reset;
 marcade.in0:=$f;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 rom_nbank:=0;
end;

procedure cerrar_hw88games;
begin
if sprite_rom<>nil then freemem(sprite_rom);
if tiles_rom<>nil then freemem(tiles_rom);
if zoom_rom<>nil then freemem(zoom_rom);
sprite_rom:=nil;
tiles_rom:=nil;
zoom_rom:=nil;
end;

function iniciar_hw88games:boolean;
var
   memoria_temp:array[0..$1ffff] of byte;
   f:byte;
begin
llamadas_maquina.close:=cerrar_hw88games;
llamadas_maquina.reset:=reset_hw88games;
llamadas_maquina.bucle_general:=hw88games_principal;
llamadas_maquina.fps_max:=60;
llamadas_maquina.scanlines:=256;
iniciar_hw88games:=false;
//Pantallas para el K052109
screen_init(1,512,256,true);
screen_init(2,512,256,true);
screen_init(3,512,256,true);
screen_init(5,512,512,true); //Para el K051316
screen_init(4,1024,1024,false,true);
iniciar_video(320,224,true);
iniciar_audio(true);
//Main CPU
konami_0:=cpu_konami.create(12000000);
konami_0.change_ram_calls(hw88games_getbyte,hw88games_putbyte);
konami_0.change_set_lines(hw88games_bank);
if not(roms_load(@memoria_temp,hw88games_rom)) then exit;
copymemory(@memoria[$8000],@memoria_temp[0],$8000);
for f:=0 to $7 do copymemory(@rom_bank_mem[f,0],@memoria_temp[$8000+(f*$2000)],$2000);
//Sound CPU
z80_0:=cpu_z80.create(3579545);
z80_0.change_ram_calls(hw88games_snd_getbyte,hw88games_snd_putbyte);
z80_0.init_sound(hw88games_sound_update);
if not(roms_load(@mem_snd,hw88games_sound)) then exit;
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
upd7759_0:=upd7759_chip.create(1);
upd7759_1:=upd7759_chip.create(1);
if not(roms_load(upd7759_0.get_rom_addr,hw88games_upd7759_0)) then exit;
if not(roms_load(upd7759_1.get_rom_addr,hw88games_upd7759_1)) then exit;
//Iniciar video
getmem(tiles_rom,$80000);
if not(roms_load32b_b(tiles_rom,hw88games_tiles)) then exit;
k052109_0:=k052109_chip.create(1,2,3,0,hw88games_cb,tiles_rom,$80000);
getmem(sprite_rom,$100000);
if not(roms_load32b_b(sprite_rom,hw88games_sprites)) then exit;
k051960_0:=k051960_chip.create(4,1,sprite_rom,$100000,hw88games_sprite_cb,2);
getmem(zoom_rom,$40000);
if not(roms_load(zoom_rom,hw88games_zoom)) then exit;
k051316_0:=k051316_chip.create(5,2,hw88games_k051316_cb,zoom_rom,$40000,BPP4);
//DIP
init_dips(1,hw88games_dip_a,$f0);
init_dips(2,hw88games_dip_b,$ff);
init_dips(3,hw88games_dip_c,$7b);
//final
iniciar_hw88games:=true;
end;

end.
