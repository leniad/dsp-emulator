unit tumblepop_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine,hu6280,deco16ic,deco_decr,deco_common;

procedure Cargar_tumblep;
function iniciar_tumblep:boolean;
procedure reset_tumblep;
procedure cerrar_tumblep;
procedure tumblep_principal;
//Main CPU
function tumblep_getword(direccion:dword):word;
procedure tumblep_putword(direccion:dword;valor:word);

const
        tumblep_rom:array[0..2] of tipo_roms=(
        (n:'hl00-1.f12';l:$40000;p:0;crc:$fd697c1b),(n:'hl01-1.f13';l:$40000;p:$1;crc:$d5a62a3f),());
        tumblep_sound:tipo_roms=(n:'hl02-.f16';l:$10000;p:$0;crc:$a5cab888);
        tumblep_char:tipo_roms=(n:'map-02.rom';l:$80000;p:0;crc:$dfceaa26);
        tumblep_oki:tipo_roms=(n:'hl03-.j15';l:$20000;p:0;crc:$01b81da0);
        tumblep_sprites:array[0..2] of tipo_roms=(
        (n:'map-01.rom';l:$80000;p:0;crc:$e81ffa09),(n:'map-00.rom';l:$80000;p:$1;crc:$8c879cfe),());

var
 rom:array[0..$3ffff] of word;
 ram:array[0..$1fff] of word;

implementation

procedure Cargar_tumblep;
begin
llamadas_maquina.bucle_general:=tumblep_principal;
llamadas_maquina.iniciar:=iniciar_tumblep;
llamadas_maquina.cerrar:=cerrar_tumblep;
llamadas_maquina.reset:=reset_tumblep;
llamadas_maquina.fps_max:=58;
end;

//Inicio Normal
function iniciar_tumblep:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  pt_x:array[0..15] of dword=(256,257,258,259,260,261,262,263,
  0, 1, 2, 3, 4, 5, 6, 7);
  pt_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
  8*16,9*16,10*16,11*16,12*16,13*16,14*16,15*16);
  ps_x:array[0..15] of dword=(512,513,514,515,516,517,518,519,
   0, 1, 2, 3, 4, 5, 6, 7);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
	  8*32, 9*32,10*32,11*32,12*32,13*32,14*32,15*32 );
var
  memoria_temp:pbyte;
begin
iniciar_tumblep:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
init_dec16ic(0,1,2,$100,$100,$f,$f,0,1,0,16,nil,nil);
screen_init(3,512,512,false,true);
iniciar_video(319,240);
//Main CPU
main_m68000:=cpu_m68000.create(14000000,$100);
main_m68000.change_ram16_calls(tumblep_getword,tumblep_putword);
//Sound CPU
deco16_sprite_color_add:=0;
deco16_sprite_mask:=$1fff;
deco16_snd_simple_init(32220000 div 8,32220000,nil);
getmem(memoria_temp,$100000);
//cargar roms
if not(cargar_roms16w(@rom[0],@tumblep_rom[0],'tumblep.zip',0)) then exit;
//cargar sonido
if not(cargar_roms(@mem_snd[0],@tumblep_sound,'tumblep.zip',1)) then exit;
//OKI rom
if not(cargar_roms(oki_6295_0.get_rom_addr,@tumblep_oki,'tumblep.zip',1)) then exit;
//convertir chars}
if not(cargar_roms(memoria_temp,@tumblep_char,'tumblep.zip',1)) then exit;
deco56_decrypt_gfx(memoria_temp,$80000);
init_gfx(0,8,8,$4000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,16*8,$4000*16*8+8,$4000*16*8+0,8,0);
convert_gfx(0,0,memoria_temp,@pc_x[0],@pc_y[0],false,false);
//Tiles
init_gfx(1,16,16,$1000);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,32*16,$1000*32*16+8,$1000*32*16+0,8,0);
convert_gfx(1,0,memoria_temp,@pt_x[0],@pt_y[0],false,false);
//Sprites
if not(cargar_roms16b(memoria_temp,@tumblep_sprites[0],'tumblep.zip',0)) then exit;
init_gfx(2,16,16,$2000);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,32*32,24,8,16,0);
convert_gfx(2,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//final
freemem(memoria_temp);
reset_tumblep;
iniciar_tumblep:=true;
end;

procedure cerrar_tumblep;
begin
main_m68000.free;
close_dec16ic(0);
deco16_snd_simple_close;
close_audio;
close_video;
end;

procedure reset_tumblep;
begin
 main_m68000.reset;
 reset_dec16ic(0);
 deco16_snd_simple_reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$F7;
 marcade.in2:=$FF;
end;

procedure update_video_tumblep;inline;
begin
//fill_full_screen(3,$100);
update_pf_2(0,3,false);
update_pf_1(0,3,true);
deco16_sprites;
actualiza_trozo_final(0,8,319,240,3);
end;

procedure eventos_tumblep;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $Fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
end;
end;

procedure tumblep_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=main_h6280.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
   main_m68000.run(frame_m);
   frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
   main_h6280.run(frame_s);
   frame_s:=frame_s+main_h6280.tframes-main_h6280.contador;
   case f of
      247:begin
            main_m68000.irq[6]:=HOLD_LINE;
            update_video_tumblep;
            marcade.in1:=marcade.in1 and $f7;
          end;
      255:marcade.in1:=marcade.in1 or $8;
   end;
 end;
 eventos_tumblep;
 video_sync;
end;
end;

function tumblep_getword(direccion:dword):word;
begin
case direccion of
  $0..$7ffff:tumblep_getword:=rom[direccion shr 1];
  $120000..$123fff:tumblep_getword:=ram[(direccion and $3fff) shr 1];
  $180000:tumblep_getword:=(marcade.in2 shl 8)+marcade.in0;
  $180004,$180006,$18000e:tumblep_getword:=$ffff;
  $180002:tumblep_getword:=$feff;
  $180008:tumblep_getword:=$00+marcade.in1;
  $18000a,$18000c:tumblep_getword:=0;
  $1a0000..$1a07ff:tumblep_getword:=deco_sprite_ram[(direccion and $7ff) shr 1];
  $320000..$320fff:tumblep_getword:=deco16ic_chip[0].dec16ic_pf_data[1,(direccion and $fff)+1] or (deco16ic_chip[0].dec16ic_pf_data[1,direccion and $fff] shl 8);
  $322000..$322fff:tumblep_getword:=deco16ic_chip[0].dec16ic_pf_data[2,(direccion and $fff)+1] or (deco16ic_chip[0].dec16ic_pf_data[2,direccion and $fff] shl 8);
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.b:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  set_pal_color(color,@paleta[numero]);
  case numero of
    $100..$1ff:deco16ic_chip[0].dec16ic_buffer_color[1,(numero shr 4) and $f]:=true;
    $200..$2ff:deco16ic_chip[0].dec16ic_buffer_color[2,(numero shr 4) and $f]:=true;
  end;
end;

procedure tumblep_putword(direccion:dword;valor:word);
begin
if direccion<$80000 then exit;
case direccion of
  $100000:begin
            deco16_sound_latch:=valor and $ff;
            main_h6280.set_irq_line(0,HOLD_LINE);
          end;
  $120000..$123fff:ram[(direccion and $3fff) shr 1]:=valor;
  $140000..$1407ff:if (buffer_paleta[(direccion and $7ff) shr 1]<>valor) then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
  $18000c:;
  $1a0000..$1a07ff:deco_sprite_ram[(direccion and $7ff) shr 1]:=valor;
  $300000..$30000f:dec16ic_pf_control_w(0,(direccion and $f) shr 1,valor);
  $320000..$320fff:begin
                      deco16ic_chip[0].dec16ic_pf_data[1,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[0].dec16ic_pf_data[1,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[0].dec16ic_buffer[1,(direccion and $fff) shr 1]:=true
                   end;
  $322000..$322fff:begin
                      deco16ic_chip[0].dec16ic_pf_data[2,(direccion and $fff)+1]:=valor and $ff;
                      deco16ic_chip[0].dec16ic_pf_data[2,direccion and $fff]:=valor shr 8;
                      deco16ic_chip[0].dec16ic_buffer[2,(direccion and $fff) shr 1]:=true
                   end;
  $340000..$3407ff:deco16ic_chip[0].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1]:=valor;
  $342000..$3427ff:deco16ic_chip[0].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1]:=valor;
end;
end;

end.
