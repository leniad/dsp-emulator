unit cabal_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,ym_2151,seibu_sound,
     rom_engine,pal_engine,sound_engine;

function iniciar_cabal:boolean;

implementation
const
        cabal_rom:array[0..3] of tipo_roms=(
        (n:'13.7h';l:$10000;p:0;crc:$00abbe0c),(n:'11.6h';l:$10000;p:$1;crc:$44736281),
        (n:'12.7j';l:$10000;p:$20000;crc:$d763a47c),(n:'10.6j';l:$10000;p:$20001;crc:$96d5e8af));
        cabal_char:tipo_roms=(n:'5-6s';l:$4000;p:0;crc:$6a76955a);
        cabal_sprites:array[0..7] of tipo_roms=(
        (n:'sp_rom1.bin';l:$10000;p:0;crc:$34d3cac8),(n:'sp_rom2.bin';l:$10000;p:$1;crc:$4e49c28e),
        (n:'sp_rom3.bin';l:$10000;p:$20000;crc:$7065e840),(n:'sp_rom4.bin';l:$10000;p:$20001;crc:$6a0e739d),
        (n:'sp_rom5.bin';l:$10000;p:$40000;crc:$0e1ec30e),(n:'sp_rom6.bin';l:$10000;p:$40001;crc:$581a50c1),
        (n:'sp_rom7.bin';l:$10000;p:$60000;crc:$55c44764),(n:'sp_rom8.bin';l:$10000;p:$60001;crc:$702735c9));
        cabal_tiles:array[0..7] of tipo_roms=(
        (n:'bg_rom1.bin';l:$10000;p:0;crc:$1023319b),(n:'bg_rom2.bin';l:$10000;p:$1;crc:$3b6d2b09),
        (n:'bg_rom3.bin';l:$10000;p:$20000;crc:$420b0801),(n:'bg_rom4.bin';l:$10000;p:$20001;crc:$77bc7a60),
        (n:'bg_rom5.bin';l:$10000;p:$40000;crc:$543fcb37),(n:'bg_rom6.bin';l:$10000;p:$40001;crc:$0bc50075),
        (n:'bg_rom7.bin';l:$10000;p:$60000;crc:$d28d921e),(n:'bg_rom8.bin';l:$10000;p:$60001;crc:$67e4fe47));
        cabal_sound:array[0..1] of tipo_roms=(
        (n:'4-3n';l:$2000;p:0;crc:$4038eff2),(n:'3-3p';l:$8000;p:$8000;crc:$d9defcbf));
        cabal_adpcm:array[0..1] of tipo_roms=(
        (n:'2-1s';l:$10000;p:0;crc:$850406b4),(n:'1-1u';l:$10000;p:$10000;crc:$8b3e0789));
        //Dip
        cabal_dip_a:array [0..11] of def_dip=(
        (mask:$f;name:'Coinage';number:16;dip:((dip_val:$a;dip_name:'6C 1C'),(dip_val:$b;dip_name:'5C 1C'),(dip_val:$c;dip_name:'4C 1C'),(dip_val:$d;dip_name:'3C 1C'),(dip_val:$1;dip_name:'8C 3C'),(dip_val:$e;dip_name:'2C 1C'),(dip_val:$2;dip_name:'5C 3C'),(dip_val:$3;dip_name:'3C 2C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$4;dip_name:'2C 3C'),(dip_val:$9;dip_name:'1C 2C'),(dip_val:$8;dip_name:'1C 3C'),(dip_val:$7;dip_name:'1C 4C'),(dip_val:$6;dip_name:'1C 5C'),(dip_val:$5;dip_name:'1C 6C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'5C 1C'),(dip_val:$1;dip_name:'3C 1C'),(dip_val:$2;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$c;dip_name:'1C 2C'),(dip_val:$8;dip_name:'1C 3C'),(dip_val:$4;dip_name:'1C 5C'),(dip_val:$0;dip_name:'1C 6C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Coin Mode';number:2;dip:((dip_val:$10;dip_name:'Mode 1'),(dip_val:$0;dip_name:'Mode 2'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Invert Buttons';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Flip Screen';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Track Ball';number:2;dip:((dip_val:$80;dip_name:'Small'),(dip_val:$0;dip_name:'Large'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$300;name:'Lives';number:4;dip:((dip_val:$200;dip_name:'2'),(dip_val:$300;dip_name:'3'),(dip_val:$100;dip_name:'5'),(dip_val:$0;dip_name:'121 (Cheat)'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c00;name:'Bonus Life';number:4;dip:((dip_val:$c00;dip_name:'150k 650k 500k+'),(dip_val:$800;dip_name:'200k 800k 600k+'),(dip_val:$400;dip_name:'300k 1000k 700k+'),(dip_val:$0;dip_name:'300k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$3000;name:'Difficulty';number:4;dip:((dip_val:$3000;dip_name:'Easy'),(dip_val:$2000;dip_name:'Normal'),(dip_val:$1000;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8000;name:'Demo Sounds';number:2;dip:((dip_val:$0;dip_name:'Off'),(dip_val:$8000;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 rom:array[0..$1ffff] of word;
 decrypt:array[0..$1fff] of byte;
 main_ram:array[0..$7fff] of word;
 bg_ram:array[0..$1ff] of word;
 fg_ram:array[0..$3ff] of word;

procedure update_video_cabal;
var
  f,color,x,y,nchar,atrib:word;
begin
//Background
for f:=0 to $ff do begin
  atrib:=bg_ram[f];
  color:=(atrib shr 12) and $f;
  if (gfx[2].buffer[f] or buffer_color[color+$40]) then begin
    x:=f mod 16;
    y:=f div 16;
    nchar:=atrib and $fff;
    put_gfx(x*16,y*16,nchar,(color shl 4)+512,2,2);
    gfx[2].buffer[f]:=false;
  end;
end;
//Foreground
for f:=0 to $3ff do begin
  atrib:=fg_ram[f];
  color:=(atrib shr 10) and $3f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=atrib and $3ff;
    put_gfx_trans(x*8,y*8,nchar,color shl 2,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
//Sprites
for f:=$1ff downto 0 do begin
    y:=main_ram[(f*4)+$1c00];
		if (y and $100)<>0 then begin
      atrib:=main_ram[(f*4)+$1c01];
      x:=main_ram[(f*4)+$1c02];
      nchar:=atrib and $fff;
      color:=(x and $7800) shr 7;
      put_gfx_sprite(nchar,color+256,(x and $400)<>0,false,1);
      actualiza_gfx_sprite(x,y,3,1);
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
actualiza_trozo_final(0,16,256,224,3);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_cabal;
begin
if event.arcade then begin
  //CONTROL1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $feff) else marcade.in0:=(marcade.in0 or $100);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fdff) else marcade.in0:=(marcade.in0 or $200);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fbff) else marcade.in0:=(marcade.in0 or $400);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7ff) else marcade.in0:=(marcade.in0 or $800);
  if arcade_input.up[1] then marcade.in0:=(marcade.in0 and $efff) else marcade.in0:=(marcade.in0 or $1000);
  if arcade_input.down[1] then marcade.in0:=(marcade.in0 and $dfff) else marcade.in0:=(marcade.in0 or $2000);
  if arcade_input.left[1] then marcade.in0:=(marcade.in0 and $bfff) else marcade.in0:=(marcade.in0 or $4000);
  if arcade_input.right[1] then marcade.in0:=(marcade.in0 and $7fff) else marcade.in0:=(marcade.in0 or $8000);
  //CONTROL2
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 and $fff7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 and $efff) else marcade.in1:=(marcade.in1 or $1000);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $dfff) else marcade.in1:=(marcade.in1 or $2000);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bfff) else marcade.in1:=(marcade.in1 or $4000);
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $7fff) else marcade.in1:=(marcade.in1 or $8000);
  //Coins
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or $1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or $2) else marcade.in2:=(marcade.in2 and $fd);
end;
end;

procedure cabal_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
///PRECAUCION EL Z80 ES EL 1, PORQUE EL SISTEMA DE SONIDO LO COGE ASI, HAY QUE CAMBIARLO...
frame_s:=z80_1.tframes;
while EmuStatus=EsRuning do begin
   for f:=0 to $ff do begin
      //Main CPU
      m68000_0.run(frame_m);
      frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
      //Sound CPU
      z80_1.run(frame_s);
      frame_s:=frame_s+z80_1.tframes-z80_1.contador;
      if f=239 then begin
          update_video_cabal;
          m68000_0.irq[1]:=HOLD_LINE;
      end;
   end;
   eventos_cabal;
   video_sync;
end;
end;

function cabal_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:cabal_getword:=rom[direccion shr 1];
    $40000..$4ffff:cabal_getword:=main_ram[(direccion and $ffff) shr 1];
    $60000..$607ff:cabal_getword:=fg_ram[(direccion and $7ff) shr 1];
    $80000..$803ff:cabal_getword:=bg_ram[(direccion and $3ff) shr 1];
    $a0000:cabal_getword:=marcade.dswa;  //DSW
    $a0008:cabal_getword:=marcade.in0;
    $a000c:cabal_getword:=$ffff;  //track 0
    $a000a,$a000e:cabal_getword:=$0;  //track 1
    $a0010:cabal_getword:=marcade.in1;  //input
    $e0000..$e07ff:cabal_getword:=buffer_paleta[(direccion and $7ff) shr 1];
    $e8000..$e800d:cabal_getword:=seibu_get(direccion and $e);
end;
end;

procedure cabal_putword(direccion:dword;valor:word);

procedure cambiar_color(tmp_color,numero:word);
var
  color:tcolor;
begin
  color.b:=pal4bit(tmp_color shr 8);
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  set_pal_color(color,numero);
  case numero of
    0..$ff:buffer_color[numero shr 2]:=true;
    512..767:buffer_color[((numero shl 4) and $f)+$40]:=true;
  end;
end;

begin
case direccion of
  0..$3ffff:; //ROM
  $40000..$4ffff:main_ram[(direccion and $ffff) shr 1]:=valor;
  $60000..$607ff:if fg_ram[(direccion and $7ff) shr 1]<>valor then begin
                    fg_ram[(direccion and $7ff) shr 1]:=valor;
                    gfx[0].buffer[(direccion and $7ff) shr 1]:=true;
                 end;
  $80000..$803ff:if bg_ram[(direccion and $3ff) shr 1]<>valor then begin
                    bg_ram[(direccion and $3ff) shr 1]:=valor;
                    gfx[2].buffer[(direccion and $3ff) shr 1]:=true;
                 end;
  $c0040:; //NOP
  $c0080:main_screen.flip_main_screen:=(valor<>0);  //Flip screen
  $e0000..$e07ff:if (buffer_paleta[(direccion and $7ff) shr 1]<>valor) then begin
                    buffer_paleta[(direccion and $7ff) shr 1]:=valor;
                    cambiar_color(valor,(direccion and $7ff) shr 1);
                 end;
  $e8000..$e800d:seibu_put(direccion and $e,valor);
end;
end;

function cabal_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:if z80_1.opcode then cabal_snd_getbyte:=decrypt[direccion]
              else cabal_snd_getbyte:=mem_snd[direccion];
  $2000..$27ff,$8000..$ffff:cabal_snd_getbyte:=mem_snd[direccion];
  $4008:cabal_snd_getbyte:=ym2151_0.status;
  $4010:cabal_snd_getbyte:=sound_latch[0];
  $4011:cabal_snd_getbyte:=sound_latch[1];
  $4012:cabal_snd_getbyte:=byte(sub2main_pending);
  $4013:cabal_snd_getbyte:=marcade.in2;
end;
end;

procedure cabal_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff,$8000..$ffff:; //ROM
  $2000..$27ff:mem_snd[direccion]:=valor;
  $4001,$4002:;
  $4003:seibu_update_irq_lines(RST18_CLEAR);
  $4005:seibu_adpcm_adr_w(0,0,valor);
  $4006:seibu_adpcm_adr_w(0,1,valor);
  $4008:ym2151_0.reg(valor);
  $4009:ym2151_0.write(valor);
  $4018:sub2main[0]:=valor;
  $4019:sub2main[1]:=valor;
  $401a:seibu_adpcm_ctl_w(0,valor);
  $6005,$6006:seibu_adpcm_adr_w(1,(direccion and 1) xor 1,valor);
  $601a:seibu_adpcm_ctl_w(1,valor);
end;
end;

procedure cabal_sound_act;
begin
  ym2151_0.update;
  seibu_adpcm_update;
end;

procedure snd_irq(irqstate:byte);
begin
  if irqstate=1 then seibu_update_irq_lines(RST10_ASSERT)
    else seibu_update_irq_lines(RST10_CLEAR);
end;

//Main
procedure reset_cabal;
begin
 m68000_0.reset;
 z80_1.reset;
 ym2151_0.reset;
 seibu_adpcm_reset;
 seibu_reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 marcade.in2:=$fc;
end;

procedure cerrar_cabal;
begin
  seibu_adpcm_close;
end;

function iniciar_cabal:boolean;
const
  pc_x:array[0..7] of dword=(3, 2, 1, 0, 8+3, 8+2, 8+1, 8+0);
  pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
  pt_x:array[0..15] of dword=(3, 2, 1, 0, 16+3, 16+2, 16+1, 16+0,
			32*16+3, 32*16+2, 32*16+1, 32*16+0, 33*16+3, 33*16+2, 33*16+1, 33*16+0);
  pt_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
			8*32, 9*32, 10*32,  11*32,  12*32,  13*32, 14*32,  15*32 );
  ps_x:array[0..15] of dword=(3, 2, 1, 0, 16+3, 16+2, 16+1, 16+0,
			32+3, 32+2, 32+1, 32+0, 48+3, 48+2, 48+1, 48+0);
  ps_y:array[0..15] of dword=(30*32, 28*32, 26*32, 24*32, 22*32, 20*32, 18*32, 16*32,
			14*32, 12*32, 10*32,  8*32,  6*32,  4*32,  2*32,  0*32 );
var
  memoria_temp:array[0..$7ffff] of byte;
begin
llamadas_maquina.bucle_general:=cabal_principal;
llamadas_maquina.close:=cerrar_cabal;
llamadas_maquina.reset:=reset_cabal;
llamadas_maquina.fps_max:=59.60;
iniciar_cabal:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_init(2,256,256,true);
screen_init(3,512,256,false,true);
iniciar_video(256,224);
//Main CPU
m68000_0:=cpu_m68000.create(10000000,256);
m68000_0.change_ram16_calls(cabal_getword,cabal_putword);
//Sound CPU
z80_1:=cpu_z80.create(3579545,256);
z80_1.change_ram_calls(cabal_snd_getbyte,cabal_snd_putbyte);
z80_1.init_sound(cabal_sound_act);
//Sound Chips
ym2151_0:=ym2151_chip.create(3579545);
ym2151_0.change_irq_func(snd_irq);
//cargar roms
if not(roms_load16w(@rom,cabal_rom)) then exit;
//cargar sonido
if not(roms_load(@memoria_temp,cabal_sound)) then exit;
decript_seibu_sound(@memoria_temp,@decrypt,@mem_snd);
copymemory(@mem_snd[$8000],@memoria_temp[$8000],$8000);
//adpcm
if not(roms_load(@memoria_temp,cabal_adpcm)) then exit;
seibu_adpcm_init(@memoria_temp);
//convertir chars
if not(roms_load(@memoria_temp,cabal_char)) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[3]:=true;
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//sprites
if not(roms_load16b(@memoria_temp,cabal_sprites)) then exit;
init_gfx(1,16,16,$1000);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,64*16,2*4,3*4,0*4,1*4);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//tiles
if not(roms_load16b(@memoria_temp,cabal_tiles)) then exit;
init_gfx(2,16,16,$1000);
gfx_set_desc_data(4,0,64*16,2*4,3*4,0*4,1*4);
convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
//Dip
marcade.dswa:=$efff;
marcade.dswa_val:=@cabal_dip_a;
//final
reset_cabal;
iniciar_cabal:=true;
end;

end.
