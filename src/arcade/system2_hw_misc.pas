unit system2_hw_misc;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,gfx_engine,nz80,sn_76496,controls_engine,rom_engine,
     pal_engine,sound_engine,ppi8255;

function iniciar_system2:boolean;
procedure system2_principal;
procedure reset_system2;

var
  type_row_scroll:boolean;
  bg_ram_bank,rom_bank:byte;
  roms,roms_dec:array[0..3,0..$3fff] of byte;

implementation
uses system1_hw;

const
    wbml_rom:array[0..3] of tipo_roms=(
        (n:'wbml.01';l:$10000;p:0;crc:$66482638),(n:'wbml.02';l:$10000;p:$10000;crc:$48746bb6),
        (n:'wbml.03';l:$10000;p:$20000;crc:$d57ba8aa),());
    wbml_char:array[0..3] of tipo_roms=(
        (n:'wbml.08';l:$8000;p:0;crc:$bbea6afe),(n:'wbml.09';l:$8000;p:$8000;crc:$77567d41),
        (n:'wbml.10';l:$8000;p:$10000;crc:$a52ffbdd),());
    wbml_sound:tipo_roms=(n:'epr11037.126';l:$8000;p:0;crc:$7a4ee585);
    wbml_sprites:array[0..4] of tipo_roms=(
        (n:'epr11028.87';l:$8000;p:0;crc:$af0b3972),(n:'epr11027.86';l:$8000;p:$8000;crc:$277d8f1d),
        (n:'epr11030.89';l:$8000;p:$10000;crc:$f05ffc76),(n:'epr11029.88';l:$8000;p:$18000;crc:$cedc9c61),());
    wbml_proms:array[0..3] of tipo_roms=(
        (n:'pr11026.20';l:$100;p:0;crc:$27057298),(n:'pr11025.14';l:$100;p:$100;crc:$41e4d86b),
        (n:'pr11024.8';l:$100;p:$200;crc:$08d71954),());
    wbml_video_prom:tipo_roms=(n:'pr5317.37';l:$100;p:0;crc:$648350b8);
    choplift_rom:array[0..3] of tipo_roms=(
        (n:'epr-7152.ic90';l:$8000;p:0;crc:$fe49d83e),(n:'epr-7153.ic91';l:$8000;p:$8000;crc:$48697666),
        (n:'epr-7154.ic92';l:$8000;p:$10000;crc:$56d6222a),());
    choplift_char:array[0..3] of tipo_roms=(
        (n:'epr-7127.ic4';l:$8000;p:0;crc:$1e708f6d),(n:'epr-7128.ic5';l:$8000;p:$8000;crc:$b922e787),
        (n:'epr-7129.ic6';l:$8000;p:$10000;crc:$bd3b6e6e),());
    choplift_sound:tipo_roms=(n:'epr-7130.ic126';l:$8000;p:0;crc:$346af118);
    choplift_sprites:array[0..4] of tipo_roms=(
        (n:'epr-7121.ic87';l:$8000;p:0;crc:$f2b88f73),(n:'epr-7120.ic86';l:$8000;p:$8000;crc:$517d7fd3),
        (n:'epr-7123.ic89';l:$8000;p:$10000;crc:$8f16a303),(n:'epr-7122.ic88';l:$8000;p:$18000;crc:$7c93f160),());
    choplift_proms:array[0..3] of tipo_roms=(
        (n:'pr7119.ic20';l:$100;p:0;crc:$b2a8260f),(n:'pr7118.ic14';l:$100;p:$100;crc:$693e20c7),
        (n:'pr7117.ic8';l:$100;p:$200;crc:$4124307e),());
    choplift_video_prom:tipo_roms=(n:'pr5317.ic28';l:$100;p:0;crc:$648350b8);

procedure update_video;inline;
var
  f:byte;
  x_temp:word;
begin
for f:=0 to 7 do update_backgroud(f);
x_temp:=(((bg_ram[$7c0] or (bg_ram[$7c1] shl 8)) div 2) and $ff)-256+5;
fillword(@xscroll[0],32,x_temp);
yscroll:=bg_ram[$7ba];
update_video_system1;
end;

procedure update_video_row_scroll;inline;
var
  f:byte;
begin
for f:=0 to 7 do update_backgroud(f);
for f:=0 to $1f do xscroll[f]:=(((bg_ram[$7c0+f*2] or (bg_ram[$7c1+f*2] shl 8)) div 2) and $ff)-256+5;
yscroll:=bg_ram[$7ba];
update_video_system1;
end;

procedure system2_principal;
var
  f,snd_irq:word;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
snd_irq:=32;
while EmuStatus=EsRuning do begin
  for f:=0 to 259 do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=223 then begin
      z80_0.change_irq(HOLD_LINE);
      if type_row_scroll then update_video_row_scroll
        else update_video;
      eventos_system1;
    end;
    if snd_irq=64 then begin
      snd_irq:=0;
      z80_1.change_irq(HOLD_LINE);
    end;
    snd_irq:=snd_irq+1;
  end;
  video_sync;
end;
end;

//Main CPU
function system2_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff:if z80_0.opcode then system2_getbyte:=mem_dec[direccion]
              else system2_getbyte:=memoria[direccion];
  $8000..$bfff:if z80_0.opcode then system2_getbyte:=roms_dec[rom_bank,direccion and $3fff] //Banked ROMS
                  else system2_getbyte:=roms[rom_bank,direccion and $3fff];
  $d800..$dfff:system2_getbyte:=buffer_paleta[direccion and $7ff];
  $e000..$efff:system2_getbyte:=bg_ram[$1000*bg_ram_bank+(direccion and $fff)]; //banked bg
  $f000..$f3ff:system2_getbyte:=mix_collide[direccion and $3f] or $7e or (mix_collide_summary shl 7);
  $f800..$fbff:system2_getbyte:=sprite_collide[direccion and $3ff] or $7e or (sprite_collide_summary shl 7);
  else system2_getbyte:=memoria[direccion];
end;
end;

procedure cambiar_color(numero:byte;pos:word);inline;
var
  val:byte;
  color:tcolor;
  bit0,bit1,bit2,bit3:byte;
begin
  val:=memoria_proms[numero];
  bit0:=(val shr 0) and $01;
  bit1:=(val shr 1) and $01;
  bit2:=(val shr 2) and $01;
  bit3:=(val shr 3) and $01;
  color.r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  val:=memoria_proms[numero+$100];
  bit0:=(val shr 0) and $01;
  bit1:=(val shr 1) and $01;
  bit2:=(val shr 2) and $01;
  bit3:=(val shr 3) and $01;
  color.g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  val:=memoria_proms[numero+$200];
  bit0:=(val shr 0) and $01;
  bit1:=(val shr 1) and $01;
  bit2:=(val shr 2) and $01;
  bit3:=(val shr 3) and $01;
  color.b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  set_pal_color(color,pos);
end;

procedure system2_putbyte(direccion:word;valor:byte);
var
  pos_bg:word;
begin
if direccion<$c000 then exit;
memoria[direccion]:=valor;
case direccion of
        $d800..$dfff:if buffer_paleta[direccion and $7ff]<>valor then begin
                        buffer_paleta[direccion and $7ff]:=valor;
                        cambiar_color(valor,direccion and $7ff);
                     end;
        $e000..$efff:begin
                        pos_bg:=$1000*bg_ram_bank+(direccion and $fff);
                        bg_ram[pos_bg]:=valor;
                        if ((pos_bg=$0740) or (pos_bg=$0742) or (pos_bg=$0744) or (pos_bg=$0746)) then begin
                          fillchar(bg_ram_w[$400],$1c00,1);
                          bgpixmaps[0]:=bg_ram[$740] and 7;
                          bgpixmaps[1]:=bg_ram[$742] and 7;
                          bgpixmaps[2]:=bg_ram[$744] and 7;
                          bgpixmaps[3]:=bg_ram[$746] and 7;
                        end else bg_ram_w[pos_bg shr 1]:=true;
                     end;
        $f000..$f3ff:mix_collide[direccion and $3f]:=0;
        $f400..$f7ff:mix_collide_summary:=0;
        $f800..$fbff:sprite_collide[direccion and $3ff]:=0;
        $fc00..$ffff:sprite_collide_summary:=0;
end;
end;

//Main
procedure reset_system2;
begin
pia8255_0.reset;
sn_76496_0.reset;
sn_76496_1.reset;
z80_0.reset;
z80_1.reset;
reset_audio;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
rom_bank:=0;
bg_ram_bank:=0;
sound_latch:=0;
mix_collide_summary:=0;
sprite_collide_summary:=0;
scroll_x:=0;
scroll_y:=0;
system1_videomode:=0;
end;

function iniciar_system2:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
var
  memoria_temp:array[0..$3ffff] of byte;

procedure convert_gfx_system2;
begin
  init_gfx(0,8,8,4096);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(3,0,8*8,0,$8000*8,$10000*8);
  convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
end;

begin
iniciar_system2:=false;
iniciar_audio(false);
//Fondo normal y encima
screen_init(1,256,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(20000000,260);
z80_0.change_ram_calls(system2_getbyte,system2_putbyte);
z80_0.change_io_calls(system1_inbyte_ppi,system1_outbyte_ppi);
z80_0.change_timmings(@z80_op,@z80_cb,@z80_dd,@z80_ddcb,@z80_ed,@z80_ex);
//Sound CPU
z80_1:=cpu_z80.create(4000000,260);
z80_1.change_ram_calls(system1_snd_getbyte_ppi,system1_snd_putbyte);
z80_1.init_sound(system1_sound_update);
//PPI 8255
pia8255_0:=pia8255_chip.create;
pia8255_0.change_ports(nil,nil,nil,system1_port_a_write,system1_port_b_write,system1_port_c_write);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(2000000);
sn_76496_1:=sn76496_chip.Create(4000000);
//Timers
case main_vars.tipo_maquina of
  37:begin
      //cargar roms
      if not(cargar_roms(@memoria_temp[0],@wbml_rom[0],'wbml.zip',0)) then exit;
      //poner en su sitio las ROMS opcodes y datos
      copymemory(@mem_dec[0],@memoria_temp[0],$8000); //opcodes
      copymemory(@memoria[0],@memoria_temp[$8000],$8000);  //datos
      //Bancos de ROM
      copymemory(@roms_dec[0,0],@memoria_temp[$10000],$4000);
      copymemory(@roms[0,0],@memoria_temp[$18000],$4000);
      copymemory(@roms_dec[1,0],@memoria_temp[$14000],$4000);
      copymemory(@roms[1,0],@memoria_temp[$1c000],$4000);
      copymemory(@roms_dec[2,0],@memoria_temp[$20000],$4000);
      copymemory(@roms[2,0],@memoria_temp[$28000],$4000);
      copymemory(@roms_dec[3,0],@memoria_temp[$24000],$4000);
      copymemory(@roms[3,0],@memoria_temp[$2c000],$4000);
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@wbml_sound,'wbml.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@wbml_char[0],'wbml.zip',0)) then exit;
      convert_gfx_system2;
      //Meter los sprites en memoria
      if not(cargar_roms(@memoria_sprites[0],@wbml_sprites[0],'wbml.zip',0)) then exit;
      //Cargar PROMS
      if not(cargar_roms(@memoria_proms[0],@wbml_proms[0],'wbml.zip',0)) then exit;
      if not(cargar_roms(@lookup_memory[0],@wbml_video_prom,'wbml.zip',1)) then exit;
      type_row_scroll:=false;
      dip_a:=$fe;
     end;
  151:begin  //Choplifter
      //cargar roms
      if not(cargar_roms(@memoria_temp[0],@choplift_rom[0],'choplift.zip',0)) then exit;
      //poner en su sitio las ROMS opcodes y datos
      copymemory(@mem_dec[0],@memoria_temp[0],$8000); //opcodes
      copymemory(@memoria[0],@memoria_temp[0],$8000);  //datos
      //Bancos de ROM
      copymemory(@roms_dec[0,0],@memoria_temp[$8000],$4000);
      copymemory(@roms[0,0],@memoria_temp[$8000],$4000);
      copymemory(@roms_dec[1,0],@memoria_temp[$c000],$4000);
      copymemory(@roms[1,0],@memoria_temp[$c000],$4000);
      copymemory(@roms_dec[2,0],@memoria_temp[$10000],$4000);
      copymemory(@roms[2,0],@memoria_temp[$10000],$4000);
      copymemory(@roms_dec[3,0],@memoria_temp[$14000],$4000);
      copymemory(@roms[3,0],@memoria_temp[$14000],$4000);
      //cargar sonido
      if not(cargar_roms(@mem_snd[0],@choplift_sound,'choplift.zip',1)) then exit;
      //convertir chars
      if not(cargar_roms(@memoria_temp[0],@choplift_char[0],'choplift.zip',0)) then exit;
      convert_gfx_system2;
      //Meter los sprites en memoria
      if not(cargar_roms(@memoria_sprites[0],@choplift_sprites[0],'choplift.zip',0)) then exit;
      //Cargar PROMS
      if not(cargar_roms(@memoria_proms[0],@choplift_proms[0],'choplift.zip',0)) then exit;
      if not(cargar_roms(@lookup_memory[0],@choplift_video_prom,'choplift.zip',1)) then exit;
      type_row_scroll:=true;
      dip_a:=$dc;
     end;
end;
dip_b:=$ef;
sprite_num_banks:=4;
char_screen:=0;
sprite_offset:=7;
mask_char:=$fff;
reset_system2;
iniciar_system2:=true;
end;

end.
