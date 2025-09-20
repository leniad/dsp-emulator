unit dietgogo_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     oki6295,sound_engine,hu6280,deco_16ic,deco_decr,deco_common,deco_104,
     misc_functions;

function iniciar_dietgo:boolean;

implementation
const
        dietgo_rom:array[0..1] of tipo_roms=(
        (n:'jy00-2.h4';l:$40000;p:1;crc:$014dcf62),(n:'jy01-2.h5';l:$40000;p:0;crc:$793ebd83));
        dietgo_sound:tipo_roms=(n:'jy02.m14';l:$10000;p:0;crc:$4e3492a5);
        dietgo_char:tipo_roms=(n:'may00';l:$100000;p:0;crc:$234d1f8d);
        dietgo_oki:tipo_roms=(n:'may03';l:$80000;p:0;crc:$b6e42bae);
        dietgo_sprites:array[0..1] of tipo_roms=(
        (n:'may01';l:$100000;p:0;crc:$2da57d04),(n:'may02';l:$100000;p:1;crc:$3a66a713));
        dietgo_dip_a:array [0..6] of def_dip2=(
        (mask:7;name:'Coin A';number:8;val8:(0,1,7,6,5,4,3,2);name8:('3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C')),
        (mask:$38;name:'Coin B';number:8;val8:(0,8,$38,$30,$28,$20,$18,$10);name8:('3C 1C','2C 1C','1C 1C','1C 2C','1C 3C','1C 4C','1C 5C','1C 6C')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Continue Coin';number:2;val2:($80,0);name2:('1 Start/1 Continue','2 Start/1 Continue')),
        (mask:$300;name:'Lives';number:4;val4:($100,0,$300,$200);name4:('1','2','3','4')),
        (mask:$c00;name:'Difficulty';number:4;val4:($800,$c00,$400,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$1000;name:'Free Play';number:2;val2:($1000,0);name2:('Off','On')));

var
 rom_opcode,rom_data:array[0..$3ffff] of word;
 ram:array[0..$7fff] of word;

procedure update_video_dietgo;
begin
deco16ic_0.update_pf_2(3,false);
deco16ic_0.update_pf_1(3,true);
deco_sprites_0.draw_sprites;
actualiza_trozo_final(0,8,320,240,3);
end;

procedure eventos_dietgo;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fffb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fff7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 and $ffbf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ff7f) else marcade.in0:=(marcade.in0 or $80);
  //P2
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.but0[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.but1[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.but2[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //SYSTEM
  if arcade_input.coin[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.coin[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or 2);
end;
end;

procedure dietgo_principal;
var
  f:word;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to 273 do begin
   case f of
      8:marcade.in1:=marcade.in1 and 7;
      248:begin
            m68000_0.irq[6]:=HOLD_LINE;
            update_video_dietgo;
            marcade.in1:=marcade.in1 or 8;
          end;
   end;
   //Main
   m68000_0.run(frame_main);
   frame_main:=frame_main+m68000_0.tframes-m68000_0.contador;
   //Sound
   h6280_0.run(frame_snd);
   frame_snd:=frame_snd+h6280_0.tframes-h6280_0.contador;
 end;
 eventos_dietgo;
 video_sync;
end;
end;

function dietgo_getword(direccion:dword):word;
function dietgo_protection_region_0_104_r(real_address:word):word;
var
  deco146_addr:word;
  cs:byte;
begin
   //int real_address = 0 + (offset *2);
   deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
   cs:=0;
   dietgo_protection_region_0_104_r:=deco104_0.read_data(deco146_addr,cs);
end;

begin
case direccion of
  0..$7ffff:if m68000_0.opcode then dietgo_getword:=rom_opcode[direccion shr 1]
                  else dietgo_getword:=rom_data[direccion shr 1];
  $210000..$210fff:dietgo_getword:=deco16ic_0.pf1.data[(direccion and $fff) shr 1];
  $212000..$212fff:dietgo_getword:=deco16ic_0.pf2.data[(direccion and $fff) shr 1];
  $280000..$2807ff:dietgo_getword:=deco_sprites_0.ram[(direccion and $7ff) shr 1];
  $300000..$300bff:dietgo_getword:=buffer_paleta[(direccion and $fff) shr 1];
  $340000..$343fff:dietgo_getword:=dietgo_protection_region_0_104_r(direccion and $3fff);
  $380000..$38ffff:dietgo_getword:=ram[(direccion and $ffff) shr 1];
end;
end;

procedure dietgo_putword(direccion:dword;valor:word);

procedure cambiar_color(numero:word);
var
  color:tcolor;
begin
  color.b:=buffer_paleta[(numero shl 1)] and $ff;
  color.g:=buffer_paleta[(numero shl 1)+1] shr 8;
  color.r:=buffer_paleta[(numero shl 1)+1] and $ff;
  set_pal_color(color,numero);
  case numero of
    0..$ff:deco16ic_0.pf1.buffer_color[(numero shr 4) and $f]:=true;
    $100..$1ff:deco16ic_0.pf2.buffer_color[(numero shr 4) and $f]:=true;
  end;
end;

procedure dietgo_protection_region_0_104_w(real_address,data:word);
var
  deco146_addr:word;
  cs:byte;
begin
	//int real_address = 0 + (offset *2);
	deco146_addr:=BITSWAP32(real_address,31,30,29,28,27,26,25,24,23,22,21,20,19,18, 13,12,11,  17,16,15,14,    10,9,8, 7,6,5,4, 3,2,1,0) and $7fff;
	cs:=0;
	deco104_0.write_data(deco146_addr, data,cs);
end;

begin
case direccion of
  0..$7ffff:; //ROM
  $200000..$20000f:deco16ic_0.control_w((direccion and $f) shr 1,valor);
  $210000..$210fff:begin
                      deco16ic_0.pf1.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf1.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $212000..$212fff:begin
                      deco16ic_0.pf2.data[(direccion and $fff) shr 1]:=valor;
                      deco16ic_0.pf2.buffer[(direccion and $fff) shr 1]:=true
                   end;
  $220000..$2207ff:deco16ic_0.pf1.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $222000..$2227ff:deco16ic_0.pf2.rowscroll[(direccion and $7ff) shr 1]:=valor;
  $280000..$2807ff:deco_sprites_0.ram[(direccion and $7ff) shr 1]:=valor;
  $211000..$211fff,$213000..$213fff,$2c0002,$2c000a,$230000..$2300ff,$240000:;
  $300000..$300bff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                      buffer_paleta[(direccion and $fff) shr 1]:=valor;
                      cambiar_color((direccion and $fff) shr 2);
                   end;
  $340000..$343fff:dietgo_protection_region_0_104_w(direccion and $3fff,valor);
  $380000..$38ffff:ram[(direccion and $ffff) shr 1]:=valor;
end;
end;

function dietgo_bank_callback(bank:word):word;
begin
  	dietgo_bank_callback:=((bank shr 4) and 7)*$1000;
end;

procedure sound_bank_rom(valor:byte);
begin
  copymemory(oki_6295_0.get_rom_addr,@oki_rom[valor and 1],$40000);
end;

//Main
procedure reset_dietgo;
begin
 m68000_0.reset;
 frame_main:=m68000_0.tframes;
 deco16ic_0.reset;
 deco_sprites_0.reset;
 deco104_0.reset;
 copymemory(oki_6295_0.get_rom_addr,@oki_rom[0],$40000);
 deco16_snd_simple_reset;
 marcade.in0:=$ffff;
 marcade.in1:=7;
end;

function iniciar_dietgo:boolean;
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
  memoria_temp,ptemp:pbyte;
  memoria_temp_rom:pword;
begin
llamadas_maquina.bucle_general:=dietgo_principal;
llamadas_maquina.reset:=reset_dietgo;
llamadas_maquina.fps_max:=58;
llamadas_maquina.scanlines:=274;
iniciar_dietgo:=false;
iniciar_audio(false);
deco16ic_0:=chip_16ic.create(1,2,0,0,$f,$f,0,1,0,16,dietgo_bank_callback,dietgo_bank_callback);
deco_sprites_0:=tdeco16_sprite.create(2,3,304,$200);
screen_init(3,512,512,false,true);
iniciar_video(320,240);
//Main CPU
m68000_0:=cpu_m68000.create(14000000);
m68000_0.change_ram16_calls(dietgo_getword,dietgo_putword);
//Sound CPU
deco16_snd_simple_init(32220000 div 12,32220000,sound_bank_rom);
getmem(memoria_temp,$200000);
getmem(memoria_temp_rom,$80000);
//cargar roms
if not(roms_load16w(memoria_temp_rom,dietgo_rom)) then exit;
deco102_decrypt_cpu(memoria_temp_rom,@rom_opcode,@rom_data,$e9ba,1,$19,$80000);
//cargar sonido
if not(roms_load(@mem_snd,dietgo_sound)) then exit;
//OKI rom
if not(roms_load(memoria_temp,dietgo_oki)) then exit;
ptemp:=memoria_temp;
copymemory(@oki_rom[0],ptemp,$40000);
inc(ptemp,$40000);
copymemory(@oki_rom[1],ptemp,$40000);
//convertir chars
if not(roms_load(memoria_temp,dietgo_char)) then exit;
deco56_decrypt_gfx(memoria_temp,$100000);
init_gfx(0,8,8,$8000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,16*8,$8000*16*8+8,$8000*16*8+0,8,0);
convert_gfx(0,0,memoria_temp,@pt_x[8],@pt_y,false,false);
//Tiles
init_gfx(1,16,16,$2000);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,32*16,$2000*32*16+8,$2000*32*16+0,8,0);
convert_gfx(1,0,memoria_temp,@pt_x,@pt_y,false,false);
//Sprites
if not(roms_load16b(memoria_temp,dietgo_sprites)) then exit;
init_gfx(2,16,16,$4000);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,32*32,24,8,16,0);
convert_gfx(2,0,memoria_temp,@ps_x,@ps_y,false,false);
//Proteccion deco104
deco104_0:=cpu_deco_104.create(USE_MAGIC_ADDRESS_XOR or INTERFACE_SCRAMBLE_INTERLEAVE);
//Dip
init_dips(1,dietgo_dip_a,$ffff);
//final
freemem(memoria_temp_rom);
freemem(memoria_temp);
reset_dietgo;
iniciar_dietgo:=true;
end;

end.
