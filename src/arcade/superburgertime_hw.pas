unit superburgertime_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine,hu6280,deco_16ic,deco_decr,deco_common;

procedure cargar_supbtime;

implementation
const
        supbtime_rom:array[0..1] of tipo_roms=(
        (n:'gk03';l:$20000;p:0;crc:$aeaeed61),(n:'gk04';l:$20000;p:$1;crc:$2bc5a4eb));
        supbtime_sound:tipo_roms=(n:'gc06.bin';l:$10000;p:$0;crc:$e0e6c0f4);
        supbtime_char:tipo_roms=(n:'mae02.bin';l:$80000;p:0;crc:$a715cca0);
        supbtime_oki:tipo_roms=(n:'gc05.bin';l:$20000;p:0;crc:$2f2246ff);
        supbtime_sprites:array[0..1] of tipo_roms=(
        (n:'mae00.bin';l:$80000;p:1;crc:$30043094),(n:'mae01.bin';l:$80000;p:$0;crc:$434af3fb));
        supbtime_dip_a:array [0..8] of def_dip=(
        (mask:$0001;name:'Cabinet';number:2;dip:((dip_val:$1;dip_name:'Cocktail'),(dip_val:$0;dip_name:'Upright'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0002;name:'Flip Screen';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$001c;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$1c;dip_name:'1C 1C'),(dip_val:$0c;dip_name:'1C 2C'),(dip_val:$14;dip_name:'1C 3C'),(dip_val:$04;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(dip_val:$08;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$00e0;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$e0;dip_name:'1C 1C'),(dip_val:$60;dip_name:'1C 2C'),(dip_val:$a0;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$c0;dip_name:'1C 5C'),(dip_val:$40;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0100;name:'Demo Sounds';number:2;dip:((dip_val:$100;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0200;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$200;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$1000;dip_name:'Easy'),(dip_val:$3000;dip_name:'Normal'),(dip_val:$2000;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c000;name:'Lives';number:4;dip:((dip_val:$8000;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$c000;dip_name:'3'),(dip_val:$4000;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),());
        tumblep_rom:array[0..1] of tipo_roms=(
        (n:'hl00-1.f12';l:$40000;p:0;crc:$fd697c1b),(n:'hl01-1.f13';l:$40000;p:$1;crc:$d5a62a3f));
        tumblep_sound:tipo_roms=(n:'hl02-.f16';l:$10000;p:$0;crc:$a5cab888);
        tumblep_char:tipo_roms=(n:'map-02.rom';l:$80000;p:0;crc:$dfceaa26);
        tumblep_oki:tipo_roms=(n:'hl03-.j15';l:$20000;p:0;crc:$01b81da0);
        tumblep_sprites:array[0..1] of tipo_roms=(
        (n:'map-01.rom';l:$80000;p:0;crc:$e81ffa09),(n:'map-00.rom';l:$80000;p:$1;crc:$8c879cfe));
        tumblep_dip_a:array [0..8] of def_dip=(
        (mask:$0001;name:'Start Price';number:2;dip:((dip_val:$1;dip_name:'1 Coin'),(dip_val:$0;dip_name:'2 Coin'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0002;name:'Flip Screen';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$001c;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$1c;dip_name:'1C 1C'),(dip_val:$0c;dip_name:'1C 2C'),(dip_val:$14;dip_name:'1C 3C'),(dip_val:$04;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(dip_val:$08;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$00e0;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$e0;dip_name:'1C 1C'),(dip_val:$60;dip_name:'1C 2C'),(dip_val:$a0;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$c0;dip_name:'1C 5C'),(dip_val:$40;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0100;name:'Demo Sounds';number:2;dip:((dip_val:$100;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0200;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$200;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$1000;dip_name:'Easy'),(dip_val:$3000;dip_name:'Normal'),(dip_val:$2000;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c000;name:'Lives';number:4;dip:((dip_val:$8000;dip_name:'1'),(dip_val:$0;dip_name:'2'),(dip_val:$c000;dip_name:'3'),(dip_val:$4000;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$3ffff] of word;
 ram:array[0..$1fff] of word;
 video_update:procedure;

procedure update_video_supbtime;
begin
  fill_full_screen(3,768);
  deco16ic_0.update_pf_2(3,true);
  deco_sprites_0.draw_sprites;
  deco16ic_0.update_pf_1(3,true);
  actualiza_trozo_final(0,8,320,240,3);
end;

procedure update_video_tumblep;
begin
  deco16ic_0.update_pf_2(3,false);
  deco16ic_0.update_pf_1(3,true);
  deco_sprites_0.draw_sprites;
  actualiza_trozo_final(0,8,319,240,3);
end;


procedure eventos_supbtime;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
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
   h6280_0.run(frame_s);
   frame_s:=frame_s+h6280_0.tframes-h6280_0.contador;
   case f of
      247:begin
            m68000_0.irq[6]:=HOLD_LINE;
            video_update;
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
  $120000..$1207ff:supbtime_getword:=deco_sprites_0.ram[(direccion and $7ff) shr 1];
  $140000..$1407ff:supbtime_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $180000:supbtime_getword:=marcade.in0;
  $180004,$180006,$18000e:supbtime_getword:=$ffff;
  $180002:supbtime_getword:=marcade.dswa;
  $180008:supbtime_getword:=marcade.in1;
  $18000a,$18000c:supbtime_getword:=0;
  $300000..$30000f:supbtime_getword:=deco16ic_0.control_r((direccion and $f) shr 1);
  $320000..$320fff:supbtime_getword:=deco16ic_0.pf1.data[(direccion and $fff) shr 1];
  $322000..$322fff:supbtime_getword:=deco16ic_0.pf2.data[(direccion and $fff) shr 1];
end;
end;

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.b:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  set_pal_color(color,numero);
  case numero of
    $100..$1ff:deco16ic_0.pf1.buffer_color[(numero shr 4) and $f]:=true;
    $200..$2ff:deco16ic_0.pf2.buffer_color[(numero shr 4) and $f]:=true;
  end;
end;

procedure supbtime_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$3ffff:; //ROM
  $100000..$103fff:ram[(direccion and $3fff) shr 1]:=valor;
  $104000..$11ffff,$120800..$13ffff,$18000a..$18000d:;
  $120000..$1207ff:deco_sprites_0.ram[(direccion and $7ff) shr 1]:=valor;
  $140000..$1407ff:if buffer_paleta[(direccion and $7ff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
  $1a0000:begin
            deco16_sound_latch:=valor and $ff;
            h6280_0.set_irq_line(0,HOLD_LINE);
          end;
  $300000..$30000f:deco16ic_0.control_w((direccion and $f) shr 1,valor);
  $320000..$320fff:begin
                      deco16ic_0.pf1.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf1.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $321000..$321fff,$323000..$323fff:;
  $322000..$322fff:begin
                      deco16ic_0.pf2.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf2.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $340000..$3407ff:deco16ic_0.pf1.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $342000..$3427ff:deco16ic_0.pf2.rowscroll[(direccion and $7ff) shr 1]:=valor;
end;
end;

//Tumblepop
function tumblep_getword(direccion:dword):word;
begin
case direccion of
  $0..$7ffff:tumblep_getword:=rom[direccion shr 1];
  $120000..$123fff:tumblep_getword:=ram[(direccion and $3fff) shr 1];
  $180000..$18000f:case (direccion and $f) of
                    $0:tumblep_getword:=marcade.in0;
                    $2:tumblep_getword:=marcade.dswa;
                    $8:tumblep_getword:=marcade.in1;
                    $a,$c:tumblep_getword:=0;
                      else tumblep_getword:=$ffff;
                   end;
  $1a0000..$1a07ff:tumblep_getword:=deco_sprites_0.ram[(direccion and $7ff) shr 1];
  $320000..$320fff:tumblep_getword:=deco16ic_0.pf1.data[(direccion and $fff) shr 1];
  $322000..$322fff:tumblep_getword:=deco16ic_0.pf2.data[(direccion and $fff) shr 1];
end;
end;

procedure tumblep_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$7ffff:;
  $100000:begin
            deco16_sound_latch:=valor and $ff;
            h6280_0.set_irq_line(0,HOLD_LINE);
          end;
  $120000..$123fff:ram[(direccion and $3fff) shr 1]:=valor;
  $140000..$1407ff:if (buffer_paleta[(direccion and $7ff) shr 1]<>valor) then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
  $18000c:;
  $1a0000..$1a07ff:deco_sprites_0.ram[(direccion and $7ff) shr 1]:=valor;
  $300000..$30000f:deco16ic_0.control_w((direccion and $f) shr 1,valor);
  $320000..$320fff:begin
                      deco16ic_0.pf1.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf1.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $322000..$322fff:begin
                      deco16ic_0.pf2.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf2.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $340000..$3407ff:deco16ic_0.pf1.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $342000..$3427ff:deco16ic_0.pf2.rowscroll[(direccion and $7ff) shr 1]:=valor;
end;
end;

//Main
procedure reset_supbtime;
begin
 m68000_0.reset;
 deco16ic_0.reset;
 deco_sprites_0.reset;
 deco16_snd_simple_reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$f7;
end;

function iniciar_supbtime:boolean;
const
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
procedure convert_chars;
begin
  init_gfx(0,8,8,$4000);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,16*8,$4000*16*8+8,$4000*16*8+0,8,0);
  convert_gfx(0,0,memoria_temp,@pt_x[8],@pt_y,false,false);
end;
procedure convert_tiles;
begin
  init_gfx(1,16,16,$1000);
  gfx[1].trans[0]:=true;
  gfx_set_desc_data(4,0,32*16,$1000*32*16+8,$1000*32*16+0,8,0);
  convert_gfx(1,0,memoria_temp,@pt_x,@pt_y,false,false);
end;
procedure convert_sprites;
begin
  init_gfx(2,16,16,$2000);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(4,0,32*32,24,8,16,0);
  convert_gfx(2,0,memoria_temp,@ps_x,@ps_y,false,false);
end;
begin
iniciar_supbtime:=false;
iniciar_audio(false);
deco16ic_0:=chip_16ic.create(1,2,$100,$100,$f,$f,0,1,0,16,nil,nil);
deco_sprites_0:=tdeco16_sprite.create(2,3,304,0,$1fff);
screen_init(3,512,512,false,true);
iniciar_video(320,240);
//Main CPU
m68000_0:=cpu_m68000.create(14000000,$100);
//Sound CPU
deco16_snd_simple_init(32220000 div 8,32220000,nil);
getmem(memoria_temp,$100000);
case main_vars.tipo_maquina of
  161:begin //Superburger Time
        video_update:=update_video_supbtime;
        m68000_0.change_ram16_calls(supbtime_getword,supbtime_putword);
        //cargar roms
        if not(roms_load16w(@rom,supbtime_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,supbtime_sound)) then exit;
        //OKI rom
        if not(roms_load(oki_6295_0.get_rom_addr,supbtime_oki)) then exit;
        //convertir chars}
        if not(roms_load(memoria_temp,supbtime_char)) then exit;
        convert_chars;
        //Tiles
        convert_tiles;
        //Sprites
        if not(roms_load16b(memoria_temp,supbtime_sprites)) then exit;
        convert_sprites;
        //final
        freemem(memoria_temp);
        //Dip
        marcade.dswa:=$fefe;
        marcade.dswa_val:=@supbtime_dip_a;
  end;
  159:begin  //Tumblepop
        video_update:=update_video_tumblep;
        m68000_0.change_ram16_calls(tumblep_getword,tumblep_putword);
        //cargar roms
        if not(roms_load16w(@rom,tumblep_rom)) then exit;
        //cargar sonido
        if not(roms_load(@mem_snd,tumblep_sound)) then exit;
        //OKI rom
        if not(roms_load(oki_6295_0.get_rom_addr,tumblep_oki)) then exit;
        //convertir chars}
        if not(roms_load(memoria_temp,tumblep_char)) then exit;
        deco56_decrypt_gfx(memoria_temp,$80000);
        convert_chars;
        //Tiles
        convert_tiles;
        //Sprites
        if not(roms_load16b(memoria_temp,tumblep_sprites)) then exit;
        convert_sprites;
        //final
        freemem(memoria_temp);
        //Dip
        marcade.dswa:=$feff;
        marcade.dswa_val:=@tumblep_dip_a;
      end;
end;
reset_supbtime;
iniciar_supbtime:=true;
end;

procedure cargar_supbtime;
begin
llamadas_maquina.bucle_general:=supbtime_principal;
llamadas_maquina.iniciar:=iniciar_supbtime;
llamadas_maquina.reset:=reset_supbtime;
llamadas_maquina.fps_max:=58;
end;

end.
