unit rainbowislands_hw;
interface
uses rom_engine;

function iniciar_rainbow:boolean;

const
        rainbow_cchip_eeprom:tipo_roms=(n:'cchip_b22-15.53';l:$2000;p:0;crc:$08c588a6);
        rainbowe_cchip_eeprom:tipo_roms=(n:'cchip_b39-05.53';l:$2000;p:0;crc:$397735e3);
        rainbow_rom:array[0..3] of tipo_roms=(
        (n:'b22-10-1.19';l:$10000;p:0;crc:$e34a50ca),(n:'b22-11-1.20';l:$10000;p:1;crc:$6a31a093),
        (n:'b22-08-1.21';l:$10000;p:$20000;crc:$15d6e17a),(n:'b22-09-1.22';l:$10000;p:$20001;crc:$454e66bc));
        rainbow_rom2:array[0..1] of tipo_roms=(
        (n:'b22-03.23';l:$20000;p:$40000;crc:$3ebb0fb8),(n:'b22-04.24';l:$20000;p:$40001;crc:$91625e7f));
        rainbow_char:tipo_roms=(n:'b22-01.2';l:$80000;p:0;crc:$b76c9168);
        rainbow_sound:tipo_roms=(n:'b22-14.43';l:$10000;p:0;crc:$113c1a5b);
        rainbow_sprites1:tipo_roms=(n:'b22-02.5';l:$80000;p:0;crc:$1b87ecf0);
        rainbow_sprites2:array[0..2] of tipo_roms=(
        (n:'b22-12.7';l:$10000;p:$80000;crc:$67a76dc6),(n:'b22-13.6';l:$10000;p:$80001;crc:$2fda099f),());
        rainbowe_rom:array[0..4] of tipo_roms=(
        (n:'b39-01.19';l:$10000;p:0;crc:$50690880),(n:'b39-02.20';l:$10000;p:1;crc:$4dead71f),
        (n:'b39-03.21';l:$10000;p:$20000;crc:$4a4cb785),(n:'b39-04.22';l:$10000;p:$20001;crc:$4caa53bd),());

implementation
uses m68000,main_engine,controls_engine,gfx_engine,ym_2151,taito_sound,
     pal_engine,sound_engine,taito_cchip;

const
        rainbow_dip_a:array [0..1] of def_dip2=(
        (mask:$30;name:'Coin A';number:4;val4:($10,$30,0,$20);name4:('ModeA 2C-1C/ModeB 3C-1C','ModeAB 1C-1C','ModeA 2C-3C/ModeB 4C-1C','ModeA 1C-2C/ModeB 2C-1C')),
        (mask:$c0;name:'Coin B';number:4;val4:($40,$c0,0,$80);name4:('ModeA 2C-1C/ModeB 1C-4C','ModeA 1C-1C/ModeB 1C-2C','ModeA 2C-3C/ModeB 1C-6C','ModeA 1C-2C/ModeB 1C-3C')));
        rainbow_dip_b:array [0..4] of def_dip2=(
        (mask:4;name:'Bonus Life';number:2;val2:(4,0);name2:('100k 1000k','None')),
        (mask:8;name:'Complete Bonus';number:2;val2:(8,0);name2:('1up','100k')),
        (mask:$30;name:'Lives';number:4;val4:($10,0,$30,$20);name4:('1','2','3','4')),
        (mask:$40;name:'Languaje';number:2;val2:(0,$40);name2:('English','Japanese')),
        (mask:$80;name:'Coin Mode';number:2;val2:($80,0);name2:('Mode A (Japan)','Mode B (World)')));

var
 scroll_x1,scroll_y1,scroll_x2,scroll_y2:word;
 rom:array[0..$3ffff] of word;
 ram1,ram3:array[0..$1fff] of word;
 ram2:array [0..$7fff] of word;
 spritebank:byte;

procedure update_video_rainbow;
var
  f,x,y,nchar,atrib,color:word;
  flipx,flipy:boolean;
begin
for f:=$fff downto 0 do begin
    //background
    atrib:=ram2[f*2];
    color:=atrib and $7f;
    if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=(ram2[1+(f*2)]) and $3fff;
      flipx:=(atrib and $4000)<>0;
      flipy:=(atrib and $8000)<>0;
      put_gfx_flip(x*8,y*8,nchar,color shl 4,1,0,flipx,flipy);
      gfx[0].buffer[f]:=false;
    end;
    //foreground
    atrib:=ram2[$4000+(f*2)];
    color:=atrib and $7f;
    if (gfx[0].buffer[f+$1000] or buffer_color[color]) then begin
      x:=f mod 64;
      y:=f div 64;
      nchar:=(ram2[$4001+(f*2)]) and $3fff;
      flipx:=(atrib and $4000)<>0;
      flipy:=(atrib and $8000)<>0;
      put_gfx_trans_flip(x*8,y*8,nchar,color shl 4,2,0,flipx,flipy);
      gfx[0].buffer[f+$1000]:=false;
    end;
end;
scroll_x_y(1,3,scroll_x1,scroll_y1);
//Sprites
for f:=$ff downto 0 do begin
    nchar:=(ram3[2+(f*4)]) mod $1400;
    atrib:=ram3[f*4];
    color:=((atrib and $f) or (spritebank shl 4)) shl 4;
    put_gfx_sprite(nchar,color,(atrib and $4000)<>0,(atrib and $8000)<>0,1);
    x:=ram3[3+(f*4)]+16;
    y:=ram3[1+(f*4)];
    actualiza_gfx_sprite(x and $1ff,y and $1ff,3,1);
end;
scroll_x_y(2,3,scroll_x2,scroll_y2);
actualiza_trozo_final(16,16,320,224,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_rainbow;
begin
if event.arcade then begin
  marcade.in0:=$ff;
  marcade.in1:=0;
  marcade.in2:=$ff;
  //800007
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $df;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $bf;
  //800009
  if arcade_input.coin[0] then marcade.in1:=marcade.in1 or 1;
  if arcade_input.coin[1] then marcade.in1:=marcade.in1 or 2;
  //80000B
  if arcade_input.left[0] then marcade.in2:=marcade.in2 and $ef;
  if arcade_input.right[0] then marcade.in2:=marcade.in2 and $df;
  if arcade_input.but0[0] then marcade.in2:=marcade.in2 and $bf;
  if arcade_input.but1[0] then marcade.in2:=marcade.in2 and $7f;
end;
end;

procedure rainbow_principal;
var
  h,f:byte;
begin
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
    eventos_rainbow;
    if f=240 then begin
        update_video_rainbow;
        m68000_0.irq[4]:=HOLD_LINE;
        cchip_0.set_int;
    end;
    //Main CPU
    m68000_0.run(frame_main);
    frame_main:=frame_main+m68000_0.tframes-m68000_0.contador;
    //Sound CPU
    tc0140syt_0.run;
    //MCU
    cchip_0.upd7810.run(frame_mcu);
    frame_mcu:=frame_mcu+cchip_0.upd7810.tframes-cchip_0.upd7810.contador;
 end;
 video_sync;
end;
end;

function rainbow_getword(direccion:dword):word;
begin
case direccion of
  0..$7ffff:rainbow_getword:=rom[direccion shr 1];
  $10c000..$10ffff:rainbow_getword:=ram1[(direccion and $3fff) shr 1];
  $200000..$203fff:rainbow_getword:=buffer_paleta[(direccion and $3fff) shr 1];
  $390000..$390002:rainbow_getword:=marcade.dswa;
  $3b0000..$3b0002:rainbow_getword:=marcade.dswb;
  $3e0002:if m68000_0.read_8bits_hi_dir then rainbow_getword:=tc0140syt_0.comm_r;
  $800000..$8007ff:rainbow_getword:=cchip_0.mem68_r((direccion and $7ff) shr 1);
  $800800..$800fff:rainbow_getword:=cchip_0.asic_r((direccion and $7ff) shr 1);
  $c00000..$c0ffff:rainbow_getword:=ram2[(direccion and $ffff) shr 1];
  $d00000..$d03fff:rainbow_getword:=ram3[(direccion and $3fff) shr 1];
end;
end;

procedure rainbow_putword(direccion:dword;valor:word);
procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.b:=pal5bit(tmp_color shr 10);
  color.g:=pal5bit(tmp_color shr 5);
  color.r:=pal5bit(tmp_color);
  set_pal_color(color,numero);
  buffer_color[(numero shr 4) and $7f]:=true;
end;
begin
case direccion of
      0..$7ffff:;
      $10c000..$10ffff:ram1[(direccion and $3fff) shr 1]:=valor;
      $200000..$200fff:if buffer_paleta[(direccion and $fff) shr 1]<>valor then begin
                            buffer_paleta[(direccion and $fff) shr 1]:=valor;
                            cambiar_color(valor,(direccion and $fff) shr 1);
                       end;
      $201000..$203fff:buffer_paleta[(direccion and $3fff) shr 1]:=valor;
      $350008,$3c0000:;
      $3a0000:spritebank:=(valor and $e0) shr 5;
      $3e0000:tc0140syt_0.port_w(valor and $ff);
      $3e0002:tc0140syt_0.comm_w(valor and $ff);
      $800000..$8007ff:cchip_0.mem68_w((direccion and $7ff) shr 1,valor);
      $800800..$800fff:cchip_0.asic68_w((direccion and $7ff) shr 1,valor);
      $c00000..$c03fff:begin
                      ram2[(direccion and $ffff) shr 1]:=valor;
                      gfx[0].buffer[(direccion and $3fff) shr 2]:=true;
                   end;
      $c04000..$c07fff,$c0c000..$c0ffff:ram2[(direccion and $ffff) shr 1]:=valor;
      $c08000..$c0bfff:begin
                      ram2[(direccion and $ffff) shr 1]:=valor;
                      gfx[0].buffer[((direccion and $3fff) shr 2)+$1000]:=true;
                   end;
      $c20000:scroll_y1:=(512-valor) and $1ff;
      $c20002:scroll_y2:=(512-valor) and $1ff;
      $c40000:scroll_x1:=(512-valor) and $1ff;
      $c40002:scroll_x2:=(512-valor) and $1ff;
      $c50000..$c50003:;
      $d00000..$d03fff:ram3[(direccion and $3fff) shr 1]:=valor;
end;
end;

function rainbow_800007:byte;
begin
  rainbow_800007:=marcade.in0;
end;

function rainbow_800009:byte;
begin
  rainbow_800009:=marcade.in1;
end;

function rainbow_80000c:byte;
begin
  rainbow_80000c:=marcade.in2;
end;

function rainbow_80000d:byte;
begin
  rainbow_80000d:=marcade.in3;
end;

//Main
procedure reset_rainbow;
begin
 m68000_0.reset;
 tc0140syt_0.reset;
 cchip_0.reset;
 frame_main:=m68000_0.tframes;
 frame_mcu:=cchip_0.upd7810.tframes;
 marcade.in0:=$ff;
 marcade.in1:=0;//$fc;
 marcade.in2:=$ff;
 marcade.in3:=$ff;
 scroll_x1:=0;
 scroll_y1:=0;
 scroll_x2:=0;
 scroll_y2:=0;
end;

function iniciar_rainbow:boolean;
const
  pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
  ps_x:array[0..15] of dword=(8, 12, 0, 4, 24, 28, 16, 20, 40, 44, 32, 36, 56, 60, 48, 52);
  ps_y:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64,
			8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64);
var
  memoria_temp:pbyte;
procedure convert_chars;
begin
  init_gfx(0,8,8,$4000);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(4,0,32*8,0,1,2,3);
  convert_gfx(0,0,memoria_temp,@ps_x,@pc_y,false,false);
end;
procedure convert_sprites;
begin
  init_gfx(1,16,16,$1400);
  gfx[1].trans[0]:=true;
  gfx_set_desc_data(4,0,128*8,0,1,2,3);
  convert_gfx(1,0,memoria_temp,@ps_x,@ps_y,false,false);
end;
begin
iniciar_rainbow:=false;
llamadas_maquina.bucle_general:=rainbow_principal;
llamadas_maquina.reset:=reset_rainbow;
llamadas_maquina.scanlines:=256;
iniciar_audio(false);
screen_init(1,512,512);
screen_init(2,512,512,true);
screen_init(3,512,512,false,true);
iniciar_video(320,224);
//Main CPU
m68000_0:=cpu_m68000.create(8000000);
m68000_0.change_ram16_calls(rainbow_getword,rainbow_putword);
//Sound CPU
tc0140syt_0:=tc0140syt_chip.create(4000000,SOUND_RAINBOWI);
//cargar roms
getmem(memoria_temp,$100000);
case main_vars.tipo_maquina of
  179:begin
         //MCU
         cchip_0:=cchip_chip.create(12000000);
         cchip_0.change_ad(rainbow_80000d);
         cchip_0.change_in(rainbow_800007,rainbow_800009,rainbow_80000c,nil,nil);
         if not(roms_load(cchip_0.get_eeprom_dir,rainbow_cchip_eeprom)) then exit;
         if not(roms_load16w(@rom,rainbow_rom)) then exit;
         if not(roms_load16w(@rom,rainbow_rom2)) then exit;
         //cargar sonido+ponerlas en su banco
         if not(roms_load(memoria_temp,rainbow_sound)) then exit;
         copymemory(@tc0140syt_0.snd_rom,memoria_temp,$4000);
         copymemory(@tc0140syt_0.snd_bank_rom[0,0],@memoria_temp[0],$4000);
         copymemory(@tc0140syt_0.snd_bank_rom[1,0],@memoria_temp[$4000],$4000);
         copymemory(@tc0140syt_0.snd_bank_rom[2,0],@memoria_temp[$8000],$4000);
         copymemory(@tc0140syt_0.snd_bank_rom[3,0],@memoria_temp[$c000],$4000);
         //convertir chars
         if not(roms_load(memoria_temp,rainbow_char)) then exit;
         convert_chars;
         //convertir sprites
         if not(roms_load(memoria_temp,rainbow_sprites1)) then exit;
         if not(roms_load16b(memoria_temp,rainbow_sprites2)) then exit;
         convert_sprites;
      end;
  180:begin
         //MCU
         cchip_0:=cchip_chip.create(12000000);
         cchip_0.change_ad(rainbow_80000d);
         cchip_0.change_in(rainbow_800007,rainbow_800009,rainbow_80000c,nil,nil);
         if not(roms_load(cchip_0.get_eeprom_dir,rainbowe_cchip_eeprom)) then exit;
         if not(roms_load16w(@rom,rainbowe_rom)) then exit;
         if not(roms_load16w(@rom,rainbow_rom2,true,true,'rbisland.zip')) then exit;
         //cargar sonido+ponerlas en su banco
         if not(roms_load(memoria_temp,rainbow_sound,true,true,'rbisland.zip')) then exit;
         copymemory(@tc0140syt_0.snd_rom,memoria_temp,$4000);
         copymemory(@tc0140syt_0.snd_bank_rom[0,0],@memoria_temp[0],$4000);
         copymemory(@tc0140syt_0.snd_bank_rom[1,0],@memoria_temp[$4000],$4000);
         copymemory(@tc0140syt_0.snd_bank_rom[2,0],@memoria_temp[$8000],$4000);
         copymemory(@tc0140syt_0.snd_bank_rom[3,0],@memoria_temp[$c000],$4000);
         //convertir chars
         if not(roms_load(memoria_temp,rainbow_char,true,true,'rbisland.zip')) then exit;
         convert_chars;
         //convertir sprites
         if not(roms_load(memoria_temp,rainbow_sprites1,true,true,'rbisland.zip')) then exit;
         if not(roms_load16b(memoria_temp,rainbow_sprites2,true,true,'rbisland.zip')) then exit;
         convert_sprites;
      end;
end;
//DIP
init_dips(1,rainbow_dip_a,$fe);
init_dips(2,rainbow_dip_b,$bf);
//final
freemem(memoria_temp);
iniciar_rainbow:=true;
end;

end.
