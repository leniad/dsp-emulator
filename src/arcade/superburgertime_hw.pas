unit superburgertime_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine,hu6280,deco16ic,deco_common;

procedure cargar_supbtime;

implementation
const
        supbtime_rom:array[0..2] of tipo_roms=(
        (n:'gk03';l:$20000;p:0;crc:$aeaeed61),(n:'gk04';l:$20000;p:$1;crc:$2bc5a4eb),());
        supbtime_sound:tipo_roms=(n:'gc06.bin';l:$10000;p:$0;crc:$e0e6c0f4);
        supbtime_char:tipo_roms=(n:'mae02.bin';l:$80000;p:0;crc:$a715cca0);
        supbtime_oki:tipo_roms=(n:'gc05.bin';l:$20000;p:0;crc:$2f2246ff);
        supbtime_sprites:array[0..2] of tipo_roms=(
        (n:'mae00.bin';l:$80000;p:1;crc:$30043094),(n:'mae01.bin';l:$80000;p:$0;crc:$434af3fb),());

var
 rom:array[0..$1ffff] of word;
 ram:array[0..$1fff] of word;

procedure update_video_supbtime;
begin
fill_full_screen(3,768);
update_pf_2(0,3,true);
deco16_sprites;
update_pf_1(0,3,true);
actualiza_trozo_final(0,8,320,240,3);
end;

procedure eventos_supbtime;
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
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $Fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $F7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
end;
end;

procedure supbtime_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=h6280_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
   m68000_0.run(frame_m);
   frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
   h6280_0.run(trunc(frame_s));
   frame_s:=frame_s+h6280_0.tframes-h6280_0.contador;
   case f of
      247:begin
            m68000_0.irq[6]:=HOLD_LINE;
            update_video_supbtime;
            marcade.in1:=marcade.in1 or $8;
          end;
      255:marcade.in1:=marcade.in1 and $f7;
   end;
 end;
 eventos_supbtime;
 video_sync;
end;
end;

function supbtime_getword(direccion:dword):word;
begin
case direccion of
  $0..$3ffff:supbtime_getword:=rom[direccion shr 1];
  $100000..$103fff:supbtime_getword:=ram[(direccion and $3fff) shr 1];
  $120000..$1207ff:supbtime_getword:=deco_sprite_ram[(direccion and $7ff) shr 1];
  $140000..$1407ff:supbtime_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $180000:supbtime_getword:=marcade.in0;
  $180004,$180006,$18000e:supbtime_getword:=$ffff;
  $180002:supbtime_getword:=$feff;
  $180008:supbtime_getword:=marcade.in1;
  $18000a,$18000c:supbtime_getword:=0;
  $320000..$320fff:supbtime_getword:=deco16ic_chip[0].dec16ic_pf_data[1,(direccion and $fff) shr 1];
  $322000..$322fff:supbtime_getword:=deco16ic_chip[0].dec16ic_pf_data[2,(direccion and $fff) shr 1];
end;
end;

procedure cambiar_color(tmp_color,numero:word);inline;
var
  color:tcolor;
begin
  color.b:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  set_pal_color(color,numero);
  case numero of
    $100..$1ff:deco16ic_chip[0].dec16ic_buffer_color[1,(numero shr 4) and $f]:=true;
    $200..$2ff:deco16ic_chip[0].dec16ic_buffer_color[2,(numero shr 4) and $f]:=true;
  end;
end;

procedure supbtime_putword(direccion:dword;valor:word);
begin
if direccion<$40000 then exit;
case direccion of
  $100000..$103fff:ram[(direccion and $3fff) shr 1]:=valor;
  $104000..$11ffff,$120800..$13ffff,$18000a..$18000d:;
  $120000..$1207ff:deco_sprite_ram[(direccion and $7ff) shr 1]:=valor;
  $140000..$1407ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
  $1a0000:begin
            deco16_sound_latch:=valor and $ff;
            h6280_0.set_irq_line(0,HOLD_LINE);
          end;
  $300000..$30000f:dec16ic_pf_control_w(0,(direccion and $f) shr 1,valor);
  $320000..$320fff:begin
                      deco16ic_chip[0].dec16ic_pf_data[1,(direccion and $fff) shr 1]:=valor;
                      deco16ic_chip[0].dec16ic_buffer[1,(direccion and $fff) shr 1]:=true
                   end;
  $321000..$321fff,$323000..$323fff:;
  $322000..$322fff:begin
                      deco16ic_chip[0].dec16ic_pf_data[2,(direccion and $fff) shr 1]:=valor;
                      deco16ic_chip[0].dec16ic_buffer[2,(direccion and $fff) shr 1]:=true
                   end;
  $340000..$3407ff:deco16ic_chip[0].dec16ic_pf_rowscroll[1,(direccion and $7ff) shr 1]:=valor;
  $342000..$3427ff:deco16ic_chip[0].dec16ic_pf_rowscroll[2,(direccion and $7ff) shr 1]:=valor;
end;
end;

//Main
procedure reset_supbtime;
begin
 m68000_0.reset;
 reset_dec16ic(0);
 deco16_snd_simple_reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$F7;
end;

function iniciar_supbtime:boolean;
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
iniciar_supbtime:=false;
iniciar_audio(false);
init_dec16ic(0,1,2,$100,$100,$f,$f,0,1,0,16,nil,nil);
screen_init(3,512,512,false,true);
iniciar_video(320,240);
//Main CPU
m68000_0:=cpu_m68000.create(14000000,$100);
m68000_0.change_ram16_calls(supbtime_getword,supbtime_putword);
//Sound CPU
deco16_sprite_color_add:=0;
deco16_sprite_mask:=$1fff;
deco16_snd_simple_init(32220000 div 8,32220000,nil);
getmem(memoria_temp,$100000);
//cargar roms
if not(cargar_roms16w(@rom[0],@supbtime_rom[0],'supbtime.zip',0)) then exit;
//cargar sonido
if not(cargar_roms(@mem_snd[0],@supbtime_sound,'supbtime.zip',1)) then exit;
//OKI rom
if not(cargar_roms(oki_6295_0.get_rom_addr,@supbtime_oki,'supbtime.zip',1)) then exit;
//convertir chars}
if not(cargar_roms(memoria_temp,@supbtime_char,'supbtime.zip',1)) then exit;
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
if not(cargar_roms16b(memoria_temp,@supbtime_sprites[0],'supbtime.zip',0)) then exit;
init_gfx(2,16,16,$2000);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,32*32,24,8,16,0);
convert_gfx(2,0,memoria_temp,@ps_x[0],@ps_y[0],false,false);
//final
freemem(memoria_temp);
reset_supbtime;
iniciar_supbtime:=true;
end;

procedure cerrar_supbtime;
begin
close_dec16ic(0);
end;

procedure Cargar_supbtime;
begin
llamadas_maquina.bucle_general:=supbtime_principal;
llamadas_maquina.iniciar:=iniciar_supbtime;
llamadas_maquina.close:=cerrar_supbtime;
llamadas_maquina.reset:=reset_supbtime;
llamadas_maquina.fps_max:=58;
end;

end.
