unit system2_hw_misc;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,gfx_engine,nz80,sn_76496,controls_engine,rom_engine,
     pal_engine,sound_engine,ppi8255,timer_engine;

function iniciar_system2:boolean;
procedure system2_principal;
procedure reset_system2;

var
  bg_ram_bank,rom_bank:byte;

implementation
uses system1_hw;

const
    //Wonder Boy in Monster Land
    wbml_rom:array[0..2] of tipo_roms=(
    (n:'wbml.01';l:$10000;p:0;crc:$66482638),(n:'wbml.02';l:$10000;p:$10000;crc:$48746bb6),
    (n:'wbml.03';l:$10000;p:$20000;crc:$d57ba8aa));
    wbml_char:array[0..2] of tipo_roms=(
    (n:'wbml.08';l:$8000;p:0;crc:$bbea6afe),(n:'wbml.09';l:$8000;p:$8000;crc:$77567d41),
    (n:'wbml.10';l:$8000;p:$10000;crc:$a52ffbdd));
    wbml_sound:tipo_roms=(n:'epr11037.126';l:$8000;p:0;crc:$7a4ee585);
    wbml_sprites:array[0..3] of tipo_roms=(
    (n:'epr11028.87';l:$8000;p:0;crc:$af0b3972),(n:'epr11027.86';l:$8000;p:$8000;crc:$277d8f1d),
    (n:'epr11030.89';l:$8000;p:$10000;crc:$f05ffc76),(n:'epr11029.88';l:$8000;p:$18000;crc:$cedc9c61));
    wbml_proms:array[0..2] of tipo_roms=(
    (n:'pr11026.20';l:$100;p:0;crc:$27057298),(n:'pr11025.14';l:$100;p:$100;crc:$41e4d86b),
    (n:'pr11024.8';l:$100;p:$200;crc:$08d71954));
    wbml_video_prom:tipo_roms=(n:'pr5317.37';l:$100;p:0;crc:$648350b8);
    wbml_dip_a:array [0..6] of def_dip=(
    (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$2;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$c;name:'Lives';number:4;dip:((dip_val:$4;dip_name:'3'),(dip_val:$c;dip_name:'4'),(dip_val:$8;dip_name:'5'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$10;name:'Bonus Life';number:2;dip:((dip_val:$10;dip_name:'30K 100K 200K'),(dip_val:$0;dip_name:'50K 150K 250K'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$20;name:'Difficulty';number:2;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$40;name:'Test Mode';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
    //Choplifter
    choplift_rom:array[0..2] of tipo_roms=(
    (n:'epr-7152.ic90';l:$8000;p:0;crc:$fe49d83e),(n:'epr-7153.ic91';l:$8000;p:$8000;crc:$48697666),
    (n:'epr-7154.ic92';l:$8000;p:$10000;crc:$56d6222a));
    choplift_char:array[0..2] of tipo_roms=(
    (n:'epr-7127.ic4';l:$8000;p:0;crc:$1e708f6d),(n:'epr-7128.ic5';l:$8000;p:$8000;crc:$b922e787),
    (n:'epr-7129.ic6';l:$8000;p:$10000;crc:$bd3b6e6e));
    choplift_sound:tipo_roms=(n:'epr-7130.ic126';l:$8000;p:0;crc:$346af118);
    choplift_sprites:array[0..3] of tipo_roms=(
    (n:'epr-7121.ic87';l:$8000;p:0;crc:$f2b88f73),(n:'epr-7120.ic86';l:$8000;p:$8000;crc:$517d7fd3),
    (n:'epr-7123.ic89';l:$8000;p:$10000;crc:$8f16a303),(n:'epr-7122.ic88';l:$8000;p:$18000;crc:$7c93f160));
    choplift_proms:array[0..2] of tipo_roms=(
    (n:'pr7119.ic20';l:$100;p:0;crc:$b2a8260f),(n:'pr7118.ic14';l:$100;p:$100;crc:$693e20c7),
    (n:'pr7117.ic8';l:$100;p:$200;crc:$4124307e));
    choplift_video_prom:tipo_roms=(n:'pr5317.ic28';l:$100;p:0;crc:$648350b8);
    choplift_dip_a:array [0..5] of def_dip=(
    (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$4;dip_name:'4'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$10;name:'Bonus Life';number:2;dip:((dip_val:$10;dip_name:'20K 70K 120K 170K'),(dip_val:$0;dip_name:'50K 100K 150K 200K'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$20;name:'Difficulty';number:2;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  type_row_scroll:boolean;
  roms,roms_dec:array[0..3,0..$3fff] of byte;

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
  f:word;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
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
  color:tcolor;
begin
  color.r:=pal4bit(memoria_proms[numero]);
  color.g:=pal4bit(memoria_proms[numero+$100]);
  color.b:=pal4bit(memoria_proms[numero+$200]);
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
var
  memoria_temp:array[0..$3ffff] of byte;
procedure convert_gfx_system2;
begin
  init_gfx(0,8,8,4096);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(3,0,8*8,0,$8000*8,$10000*8);
  convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
end;

begin
iniciar_system2:=false;
iniciar_audio(false);
//Fondo normal y encima
screen_init(1,256,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(4000000,260);
z80_0.change_ram_calls(system2_getbyte,system2_putbyte);
z80_0.change_io_calls(system1_inbyte_ppi,system1_outbyte_ppi);
z80_0.change_misc_calls(system1_delay,nil);
//Sound CPU
z80_1:=cpu_z80.create(4000000,260);
z80_1.change_ram_calls(system1_snd_getbyte_ppi,system1_snd_putbyte);
z80_1.init_sound(system1_sound_update);
init_timer(z80_1.numero_cpu,4000000/llamadas_maquina.fps_max/(260/64),system1_sound_irq,true);
//PPI 8255
pia8255_0:=pia8255_chip.create;
pia8255_0.change_ports(nil,nil,nil,system1_port_a_write,system1_port_b_write,system1_port_c_write);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(2000000,0.5);
sn_76496_1:=sn76496_chip.Create(4000000);
//Timers
case main_vars.tipo_maquina of
  37:begin
      //cargar roms
      if not(roms_load(@memoria_temp,@wbml_rom,'wbml.zip',sizeof(wbml_rom))) then exit;
      //poner en su sitio las ROMS opcodes y datos
      copymemory(@mem_dec,@memoria_temp[0],$8000); //opcodes
      copymemory(@memoria,@memoria_temp[$8000],$8000);  //datos
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
      if not(roms_load(@mem_snd,@wbml_sound,'wbml.zip',sizeof(wbml_sound))) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,@wbml_char,'wbml.zip',sizeof(wbml_char))) then exit;
      convert_gfx_system2;
      //Meter los sprites en memoria
      if not(roms_load(@memoria_sprites,@wbml_sprites,'wbml.zip',sizeof(wbml_sprites))) then exit;
      //Cargar PROMS
      if not(roms_load(@memoria_proms,@wbml_proms,'wbml.zip',sizeof(wbml_proms))) then exit;
      if not(roms_load(@lookup_memory,@wbml_video_prom,'wbml.zip',sizeof(wbml_video_prom))) then exit;
      type_row_scroll:=false;
      //dip
      marcade.dswa:=$fe;
      marcade.dswa_val:=@wbml_dip_a;
     end;
  151:begin  //Choplifter
      //cargar roms
      if not(roms_load(@memoria_temp,@choplift_rom,'choplift.zip',sizeof(choplift_rom))) then exit;
      //poner en su sitio las ROMS opcodes y datos
      copymemory(@mem_dec,@memoria_temp[0],$8000); //opcodes
      copymemory(@memoria,@memoria_temp[0],$8000);  //datos
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
      if not(roms_load(@mem_snd,@choplift_sound,'choplift.zip',sizeof(choplift_sound))) then exit;
      //convertir chars
      if not(roms_load(@memoria_temp,@choplift_char,'choplift.zip',sizeof(choplift_char))) then exit;
      convert_gfx_system2;
      //Meter los sprites en memoria
      if not(roms_load(@memoria_sprites,@choplift_sprites,'choplift.zip',sizeof(choplift_sprites))) then exit;
      //Cargar PROMS
      if not(roms_load(@memoria_proms,@choplift_proms,'choplift.zip',sizeof(choplift_proms))) then exit;
      if not(roms_load(@lookup_memory,@choplift_video_prom,'choplift.zip',sizeof(choplift_video_prom))) then exit;
      type_row_scroll:=true;
      marcade.dswa:=$dc;
      marcade.dswa_val:=@choplift_dip_a;
     end;
end;
marcade.dswb:=$ef;
marcade.dswb_val:=@system1_dip_credit;
sprite_num_banks:=4;
char_screen:=0;
sprite_offset:=7;
mask_char:=$fff;
reset_system2;
iniciar_system2:=true;
end;

end.
