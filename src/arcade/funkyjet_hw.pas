unit funkyjet_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine,hu6280,deco_16ic,deco_decr,deco_common,misc_functions,
     deco_146;

procedure cargar_funkyjet;

implementation
const
        funkyjet_rom:array[0..1] of tipo_roms=(
        (n:'jk00.12f';l:$40000;p:0;crc:$712089c1),(n:'jk01.13f';l:$40000;p:$1;crc:$be3920d7));
        funkyjet_sound:tipo_roms=(n:'jk02.16f';l:$10000;p:$0;crc:$748c0bd8);
        funkyjet_char:tipo_roms=(n:'mat02';l:$80000;p:0;crc:$e4b94c7e);
        funkyjet_oki:tipo_roms=(n:'jk03.15h';l:$20000;p:0;crc:$69a0eaf7);
        funkyjet_sprites:array[0..1] of tipo_roms=(
        (n:'mat01';l:$80000;p:0;crc:$24093a8d),(n:'mat00';l:$80000;p:$80000;crc:$fbda0228));
        funkyjet_dip_a:array [0..9] of def_dip=(
        (mask:$0002;name:'Flip Screen';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$001c;name:'Coin B';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$10;dip_name:'2C 1C'),(dip_val:$1c;dip_name:'1C 1C'),(dip_val:$0c;dip_name:'1C 2C'),(dip_val:$14;dip_name:'1C 3C'),(dip_val:$04;dip_name:'1C 4C'),(dip_val:$18;dip_name:'1C 5C'),(dip_val:$08;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$00e0;name:'Coin A';number:8;dip:((dip_val:$0;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$e0;dip_name:'1C 1C'),(dip_val:$60;dip_name:'1C 2C'),(dip_val:$a0;dip_name:'1C 3C'),(dip_val:$20;dip_name:'1C 4C'),(dip_val:$c0;dip_name:'1C 5C'),(dip_val:$40;dip_name:'1C 6C'),(),(),(),(),(),(),(),())),
        (mask:$0100;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$100;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0200;name:'Allow Continue';number:2;dip:((dip_val:$0;dip_name:'No'),(dip_val:$200;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0400;name:'Free Play';number:2;dip:((dip_val:$400;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$0800;name:'Flip Screen';number:2;dip:((dip_val:$800;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$1000;dip_name:'Easy'),(dip_val:$3000;dip_name:'Normal'),(dip_val:$2000;dip_name:'Hard'),(dip_val:$0000;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c000;name:'Lives';number:4;dip:((dip_val:$8000;dip_name:'1'),(dip_val:$c000;dip_name:'2'),(dip_val:$4000;dip_name:'3'),(dip_val:$0000;dip_name:'4'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$3ffff] of word;
 ram:array[0..$1fff] of word;

procedure update_video_funkyjet;inline;
begin
//fill_full_screen(3,$200);
deco16ic_0.update_pf_2(3,false);
deco16ic_0.update_pf_1(3,true);
deco_sprites_0.draw_sprites;
actualiza_trozo_final(0,8,320,240,3);
end;

procedure eventos_funkyjet;inline;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $FFfe) else marcade.in0:=(marcade.in0 or $0001);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $FFFd) else marcade.in0:=(marcade.in0 or $0002);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $FFfb) else marcade.in0:=(marcade.in0 or $0004);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $FFF7) else marcade.in0:=(marcade.in0 or $0008);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $FFef) else marcade.in0:=(marcade.in0 or $0010);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $FFdf) else marcade.in0:=(marcade.in0 or $0020);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $FF7f) else marcade.in0:=(marcade.in0 or $0080);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $0100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $Fdff) else marcade.in0:=(marcade.in0 or $0200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $0400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $F7ff) else marcade.in0:=(marcade.in0 or $0800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $FFfe) else marcade.in1:=(marcade.in1 or $0001);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $FFfd) else marcade.in1:=(marcade.in1 or $0002);
end;
end;

procedure funkyjet_principal;
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
            update_video_funkyjet;
            marcade.in1:=marcade.in1 or $8;
          end;
      255:marcade.in1:=marcade.in1 and $fff7;
   end;
 end;
 eventos_funkyjet;
 video_sync;
end;
end;

function funkyjet_deco146_r(real_address:word):word;inline;
var
  deco146_addr:dword;
  data:word;
  cs:byte;
begin
  //real_address:=0+(offset*2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18,13,12,11,17,16,15,14,10,  9,  8,  7,  6,   5,  4,  3,  2,  1,    0) and $7fff;
	cs:=0;
	data:=main_deco146.read_data(deco146_addr,cs);
	funkyjet_deco146_r:=data;
end;

function funkyjet_getword(direccion:dword):word;
begin
case direccion of
  $0..$7ffff:funkyjet_getword:=rom[direccion shr 1];
  $120000..$1207ff:funkyjet_getword:=buffer_paleta[(direccion and $7ff) shr 1];
  $140000..$143fff:funkyjet_getword:=ram[(direccion and $3fff) shr 1];
  $160000..$1607ff:funkyjet_getword:=deco_sprites_0.ram[(direccion and $7ff) shr 1];
  $180000..$1807ff:funkyjet_getword:=funkyjet_deco146_r(direccion and $7ff);//funkyjet_prot146(direccion and $7ff);
  $320000..$320fff:funkyjet_getword:=deco16ic_0.pf1.data[(direccion and $fff) shr 1];
  $322000..$322fff:funkyjet_getword:=deco16ic_0.pf2.data[(direccion and $fff) shr 1];
  $340000..$340bff:funkyjet_getword:=deco16ic_0.pf1.rowscroll[(direccion and $fff) shr 1];
  $342000..$342bff:funkyjet_getword:=deco16ic_0.pf2.rowscroll[(direccion and $fff) shr 1];
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
    $100..$1ff:deco16ic_0.pf1.buffer_color[(numero shr 4) and $f]:=true;
    $200..$2ff:deco16ic_0.pf2.buffer_color[(numero shr 4) and $f]:=true;
  end;
end;

procedure funkyjet_deco146_w(real_address,data:word);inline;
var
  deco146_addr:dword;
  cs:byte;
begin
	//real_address:=0+(offset *2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,17,16,15,14,10,  9,  8,  7,  6,   5,  4,  3,  2,  1,    0) and $7fff;
	cs:=0;
	main_deco146.write_data(deco146_addr,data,cs);
end;

procedure funkyjet_putword(direccion:dword;valor:word);
begin
case direccion of
  0..$7ffff:; //ROM
  $120000..$1207ff:if (buffer_paleta[(direccion and $7ff) shr 1]<>valor) then begin
                      buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                      cambiar_color(valor,(direccion and $7ff) shr 1);
                   end;
  $140000..$143fff:ram[(direccion and $3fff) shr 1]:=valor;
  $160000..$1607ff:deco_sprites_0.ram[(direccion and $7ff) shr 1]:=valor;
  $180000..$1807ff:funkyjet_deco146_w(direccion and $7ff,valor);
  $184000,$188000,$1a0002,$1a0400,$1a0402:;
  $300000..$30000f:deco16ic_0.control_w((direccion and $f) shr 1,valor);
  $320000..$320fff:begin
                      deco16ic_0.pf1.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf1.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $322000..$322fff:begin
                      deco16ic_0.pf2.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf2.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $340000..$340bff:deco16ic_0.pf1.rowscroll[(direccion and $fff) shr 1]:=valor;
  $342000..$342bff:deco16ic_0.pf2.rowscroll[(direccion and $fff) shr 1]:=valor;
end;
end;

//Main
procedure reset_funkyjet;
begin
 m68000_0.reset;
 main_deco146.reset;
 deco16ic_0.reset;
 deco_sprites_0.reset;
 deco16_snd_simple_reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$fff7;
end;

function iniciar_funkyjet:boolean;
const
  pt_x:array[0..15] of dword=(32*8+0, 32*8+1, 32*8+2, 32*8+3, 32*8+4, 32*8+5, 32*8+6, 32*8+7,
			0, 1, 2, 3, 4, 5, 6, 7);
  pt_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
var
  memoria_temp:pbyte;
begin
iniciar_funkyjet:=false;
iniciar_audio(false);
deco16ic_0:=chip_16ic.create(1,2,$100,$100,$f,$f,0,1,0,16,nil,nil);
deco_sprites_0:=tdeco16_sprite.create(2,3,304,0,$1fff);
screen_init(3,512,512,false,true);
iniciar_video(320,240);
//Main CPU
m68000_0:=cpu_m68000.create(14000000,$100);
m68000_0.change_ram16_calls(funkyjet_getword,funkyjet_putword);
//Sound CPU
deco16_snd_simple_init(32220000 div 4,32220000,nil);
getmem(memoria_temp,$100000);
//cargar roms
if not(roms_load16w(@rom,funkyjet_rom)) then exit;
//cargar sonido
if not(roms_load(@mem_snd,funkyjet_sound)) then exit;
//OKI rom
if not(roms_load(oki_6295_0.get_rom_addr,funkyjet_oki)) then exit;
//convertir chars
if not(roms_load(memoria_temp,funkyjet_char)) then exit;
deco74_decrypt_gfx(memoria_temp,$80000);
init_gfx(0,8,8,$4000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,16*8,$4000*16*8+8,$4000*16*8+0,8,0);
convert_gfx(0,0,memoria_temp,@pt_x[8],@pt_y,false,false);
//Tiles
init_gfx(1,16,16,$1000);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,$1000*64*8+8,$1000*64*8+0,8,0);
convert_gfx(1,0,memoria_temp,@pt_x,@pt_y,false,false);
//Sprites
if not(roms_load(memoria_temp,funkyjet_sprites)) then exit;
init_gfx(2,16,16,$2000);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,$2000*64*8+8,$2000*64*8+0,8,0);
convert_gfx(2,0,memoria_temp,@pt_x,@pt_y,false,false);
//Deco 146
main_deco146:=cpu_deco_146.create;
main_deco146.SET_INTERFACE_SCRAMBLE_INTERLEAVE;
//Dip
marcade.dswa:=$ffff;
marcade.dswa_val:=@funkyjet_dip_a;
//final
freemem(memoria_temp);
reset_funkyjet;
iniciar_funkyjet:=true;
end;

procedure Cargar_funkyjet;
begin
llamadas_maquina.bucle_general:=funkyjet_principal;
llamadas_maquina.iniciar:=iniciar_funkyjet;
llamadas_maquina.reset:=reset_funkyjet;
llamadas_maquina.fps_max:=58;
end;

end.
