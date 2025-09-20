unit funkyjet_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine,hu6280,deco_16ic,deco_decr,deco_common,misc_functions,
     deco_146;

function iniciar_funkyjet:boolean;

implementation
const
        funkyjet_rom:array[0..1] of tipo_roms=(
        (n:'jk00.12f';l:$40000;p:0;crc:$712089c1),(n:'jk01.13f';l:$40000;p:1;crc:$be3920d7));
        funkyjet_sound:tipo_roms=(n:'jk02.16f';l:$10000;p:0;crc:$748c0bd8);
        funkyjet_char:tipo_roms=(n:'mat02';l:$80000;p:0;crc:$e4b94c7e);
        funkyjet_oki:tipo_roms=(n:'jk03.15h';l:$20000;p:0;crc:$69a0eaf7);
        funkyjet_sprites:array[0..1] of tipo_roms=(
        (n:'mat01';l:$80000;p:0;crc:$24093a8d),(n:'mat00';l:$80000;p:$80000;crc:$fbda0228));
        funkyjet_dip_a:array [0..8] of def_dip2=(
        (mask:2;name:'Flip Screen';number:2;val2:(2,0);name2:('Off','On')),
        (mask:$1c;name:'Coin B';number:8;val8:(0,$10,$1c,$c,$14,4,$18,8);name8:('3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C')),
        (mask:$e0;name:'Coin A';number:8;val8:(0,$80,$e0,$60,$a0,$20,$c0,$40);name8:('3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C')),
        (mask:$100;name:'Demo Sounds';number:2;val2:(0,$100);name2:('Off','On')),
        (mask:$200;name:'Allow Continue';number:2;val2:(0,$200);name2:('No','Yes')),
        (mask:$400;name:'Free Play';number:2;val2:($400,0);name2:('Off','On')),
        (mask:$800;name:'Flip Screen';number:2;val2:($800,0);name2:('Off','On')),
        (mask:$3000;name:'Difficulty';number:4;val4:($1000,$3000,$2000,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$c000;name:'Lives';number:4;val4:($8000,$c000,$4000,0);name4:('1','2','3','4')));

var
 rom:array[0..$3ffff] of word;
 ram:array[0..$1fff] of word;

procedure update_video_funkyjet;
begin
//fill_full_screen(3,$200);
deco16ic_0.update_pf_2(3,false);
deco16ic_0.update_pf_1(3,true);
deco_sprites_0.draw_sprites;
actualiza_trozo_final(0,8,320,240,3);
end;

procedure eventos_funkyjet;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or 2);
end;
end;

procedure funkyjet_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 273 do begin
   case f of
      8:marcade.in1:=marcade.in1 and $fff7;
      248:begin
            m68000_0.irq[6]:=HOLD_LINE;
            update_video_funkyjet;
            marcade.in1:=marcade.in1 or 8;
          end;
   end;
   m68000_0.run(frame_main);
   frame_main:=frame_main+m68000_0.tframes-m68000_0.contador;
   h6280_0.run(frame_snd);
   frame_snd:=frame_snd+h6280_0.tframes-h6280_0.contador;
 end;
 eventos_funkyjet;
 video_sync;
end;
end;

function funkyjet_deco146_r(real_address:word):word;
var
  deco146_addr:dword;
  data:word;
  cs:byte;
begin
  //real_address:=0+(offset*2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18,13,12,11,17,16,15,14,10,  9,  8,  7,  6,   5,  4,  3,  2,  1,    0) and $7fff;
	cs:=0;
	data:=deco146_0.read_data(deco146_addr,cs);
	funkyjet_deco146_r:=data;
end;

function funkyjet_getword(direccion:dword):word;
begin
case direccion of
  0..$7ffff:funkyjet_getword:=rom[direccion shr 1];
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

procedure funkyjet_putword(direccion:dword;valor:word);

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

procedure funkyjet_deco146_w(real_address,data:word);
var
  deco146_addr:dword;
  cs:byte;
begin
	//real_address:=0+(offset *2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,17,16,15,14,10,  9,  8,  7,  6,   5,  4,  3,  2,  1,    0) and $7fff;
	cs:=0;
	deco146_0.write_data(deco146_addr,data,cs);
end;

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
 frame_main:=m68000_0.tframes;
 deco146_0.reset;
 deco16ic_0.reset;
 deco_sprites_0.reset;
 deco16_snd_simple_reset;
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
llamadas_maquina.bucle_general:=funkyjet_principal;
llamadas_maquina.reset:=reset_funkyjet;
llamadas_maquina.fps_max:=58;
llamadas_maquina.scanlines:=274;
iniciar_audio(false);
deco16ic_0:=chip_16ic.create(1,2,$100,$100,$f,$f,0,1,0,16,nil,nil);
deco_sprites_0:=tdeco16_sprite.create(2,3,304,0);
screen_init(3,512,512,false,true);
iniciar_video(320,240);
//Main CPU
m68000_0:=cpu_m68000.create(14000000);
m68000_0.change_ram16_calls(funkyjet_getword,funkyjet_putword);
if not(roms_load16w(@rom,funkyjet_rom)) then exit;
//Sound CPU
deco16_snd_simple_init(32220000 div 4,32220000,nil);
getmem(memoria_temp,$100000);
if not(roms_load(@mem_snd,funkyjet_sound)) then exit;
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
deco146_0:=cpu_deco_146.create(INTERFACE_SCRAMBLE_INTERLEAVE);
//Dip
init_dips(1,funkyjet_dip_a,$ffff);
//final
freemem(memoria_temp);
reset_funkyjet;
iniciar_funkyjet:=true;
end;

end.
