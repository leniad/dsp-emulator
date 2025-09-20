unit gyruss_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m6809,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     ay_8910,sound_engine,konami_decrypt,mcs48,dac;

procedure cargar_gyruss;

implementation
const
    gyruss_rom:array[0..2] of tipo_roms=(
    (n:'gyrussk.1';l:$2000;p:0;crc:$c673b43d),(n:'gyrussk.2';l:$2000;p:$2000;crc:$a4ec03e4),
    (n:'gyrussk.3';l:$2000;p:$4000;crc:$27454a98));
    gyruss_sub:tipo_roms=(n:'gyrussk.9';l:$2000;p:$e000;crc:$822bf27e);
    gyruss_sound:array[0..1] of tipo_roms=(
    (n:'gyrussk.1a';l:$2000;p:0;crc:$f4ae1c17),(n:'gyrussk.2a';l:$2000;p:$2000;crc:$ba498115));
    gyruss_sound_sub:tipo_roms=(n:'gyrussk.3a';l:$1000;p:$0;crc:$3f9b5dea);
    gyruss_char:tipo_roms=(n:'gyrussk.4';l:$2000;p:$0;crc:$27d8329b);
    gyruss_sprites:array[0..3] of tipo_roms=(
    (n:'gyrussk.6';l:$2000;p:0;crc:$c949db10),(n:'gyrussk.5';l:$2000;p:$2000;crc:$4f22411a),
    (n:'gyrussk.8';l:$2000;p:$4000;crc:$47cd1fbc),(n:'gyrussk.7';l:$2000;p:$6000;crc:$8e8d388c));
    gyruss_pal:array[0..2] of tipo_roms=(
    (n:'gyrussk.pr3';l:$20;p:0;crc:$98782db3),(n:'gyrussk.pr1';l:$100;p:$20;crc:$7ed057de),
    (n:'gyrussk.pr2';l:$100;p:$120;crc:$de823a81));
    //Dip
    gyruss_dip_a:array [0..2] of def_dip=(
    (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
    (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$20;dip_name:'4C 1C'),(dip_val:$50;dip_name:'3C 1C'),(dip_val:$80;dip_name:'2C 1C'),(dip_val:$40;dip_name:'3C 2C'),(dip_val:$10;dip_name:'4C 3C'),(dip_val:$f0;dip_name:'1C 1C'),(dip_val:$30;dip_name:'3C 4C'),(dip_val:$70;dip_name:'2C 3C'),(dip_val:$e0;dip_name:'1C 2C'),(dip_val:$60;dip_name:'2C 5C'),(dip_val:$d0;dip_name:'1C 3C'),(dip_val:$c0;dip_name:'1C 4C'),(dip_val:$b0;dip_name:'1C 5C'),(dip_val:$a0;dip_name:'1C 6C'),(dip_val:$90;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),());
    gyruss_dip_b:array [0..5] of def_dip=(
    (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'255'),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$8;name:'Bonus Life';number:2;dip:((dip_val:$8;dip_name:'30K 90K 60K+'),(dip_val:$0;dip_name:'40K 110K 70K+'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
    (mask:$70;name:'Difficulty';number:8;dip:((dip_val:$70;dip_name:'1 (Easiest)'),(dip_val:$60;dip_name:'2'),(dip_val:$50;dip_name:'3'),(dip_val:$40;dip_name:'4'),(dip_val:$30;dip_name:'5 (Average)'),(dip_val:$20;dip_name:'6'),(dip_val:$10;dip_name:'7'),(dip_val:$0;dip_name:'8 (Hardest)'),(),(),(),(),(),(),(),())),
    (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
    gyruss_dip_c:array [0..1] of def_dip=(
    (mask:$1;name:'Demo Music';number:2;dip:((dip_val:$1;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
    gyruss_timer:array[0..9] of byte=($00,$01,$02,$03,$04,$09,$0a,$0b,$0a,$0d);

var
  scan_line,sound_latch,sound_latch2:byte;
  main_nmi,sub_irq:boolean;
  mem_opcodes:array[0..$1fff] of byte;
  mem_sound_sub:array[0..$fff] of byte;

procedure update_video_gyruss;
var
    x,y,atrib:byte;
    f,nchar,color:word;
    flip_y:boolean;
begin
for f:=0 to $3ff do begin
 if gfx[0].buffer[f] then begin
    x:=31-(f div 32);
    y:=f mod 32;
    atrib:=memoria[$8000+f];
    color:=(atrib and $f) shl 2;
    nchar:=memoria[$8400+f]+((atrib and $20) shl 3);
    put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $80)<>0,(atrib and $40)<>0);
    if (atrib and $10)<>0 then put_gfx_flip(x*8,y*8,nchar,color,2,0,(atrib and $80)<>0,(atrib and $40)<>0)
      else put_gfx_block_trans(x*8,y*8,2,8,8);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
for f:=$2f downto $0 do begin
  atrib:=mem_misc[$4042+(f*4)];
  nchar:=(mem_misc[$4041+(f*4)] shr 1)+((atrib and $20) shl 2)+((mem_misc[$4041+(f*4)] and 1) shl 8);
  color:=(atrib and $f) shl 4;
  y:=mem_misc[$4040+(f*4)];
  flip_y:=(atrib and $40)=0;
  if main_screen.flip_main_screen then begin
    flip_y:=not(flip_y);
    y:=not(y);
  end;
  x:=mem_misc[$4043+(f*4)]-1;
  put_gfx_sprite_mask(nchar,color,(atrib and $80)<>0,flip_y,1,0,$f);
  actualiza_gfx_sprite(x,y,3,1);
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
actualiza_trozo_final(16,0,224,256,3);
end;

procedure eventos_gyruss;
begin
if event.arcade then begin
  //system
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $Fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $Fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $F7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $eF) else marcade.in2:=(marcade.in2 or $10);
  //p1
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $Fe else marcade.in0:=marcade.in0 or $1;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $Fd else marcade.in0:=marcade.in0 or $2;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or $4;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or $8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  //p2
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $Fe else marcade.in1:=marcade.in1 or $1;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $Fd else marcade.in1:=marcade.in1 or $2;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or $4;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or $8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
end;
end;

procedure gyruss_principal;
var
  frame_m,frame_sub,frame_s,frame_s_sub:single;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_sub:=m6809_0.tframes;
frame_s:=z80_1.tframes;
frame_s_sub:=mcs48_0.tframes;
while EmuStatus=EsRuning do begin
  for scan_line:=0 to $ff do begin
    //main
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //sub
    m6809_0.run(frame_sub);
    frame_sub:=frame_sub+m6809_0.tframes-m6809_0.contador;
    //snd
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    //snd sub
    mcs48_0.run(frame_s_sub);
    frame_s_sub:=frame_s_sub+mcs48_0.tframes-mcs48_0.contador;
    if (scan_line=239) then begin
      if main_nmi then z80_0.change_nmi(ASSERT_LINE);
      if sub_irq then m6809_0.change_irq(ASSERT_LINE);
      update_video_gyruss;
    end;
  end;
  eventos_gyruss;
  video_sync;
end;
end;

function gyruss_getbyte(direccion:word):byte;
begin
case direccion of
  $0000..$87ff,$9000..$a7ff:gyruss_getbyte:=memoria[direccion];
  $c000:gyruss_getbyte:=marcade.dswb; //dsw2
  $c080:gyruss_getbyte:=marcade.in2; //system
  $c0a0:gyruss_getbyte:=marcade.in0; //p1
  $c0c0:gyruss_getbyte:=marcade.in1; //p2
  $c0e0:gyruss_getbyte:=marcade.dswa; //dsw1
  $c100:gyruss_getbyte:=marcade.dswc; //dsw3
end;
end;

procedure gyruss_putbyte(direccion:word;valor:byte);
begin
case direccion of
    $7fff:;
    $8000..$87ff:if memoria[direccion]<>valor then begin
                    memoria[direccion]:=valor;
                    gfx[0].buffer[direccion and $3ff]:=true;
                 end;
    $9000..$a7ff:memoria[direccion]:=valor;
    $c080:z80_1.change_irq(HOLD_LINE);
    $c100:sound_latch:=valor;
    $c180:begin
            main_nmi:=(valor and 1)<>0;
            if not(main_nmi) then z80_0.change_nmi(CLEAR_LINE);
          end;
    $c185:main_screen.flip_main_screen:=(valor and $1)<>0;
end;
end;

function gyruss_sub_getbyte(direccion:word):byte;
begin
case direccion of
  0:gyruss_sub_getbyte:=scan_line;
  $6000..$67ff:gyruss_sub_getbyte:=memoria[$a000+(direccion and $7ff)];
  $4000..$47ff:gyruss_sub_getbyte:=mem_misc[direccion];
  $e000..$ffff:if m6809_0.opcode then gyruss_sub_getbyte:=mem_opcodes[direccion and $1fff]
                  else gyruss_sub_getbyte:=mem_misc[direccion];
end;
end;

procedure gyruss_sub_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $2000:begin
            sub_irq:=(valor and 1)<>0;
            if not(sub_irq) then m6809_0.change_irq(CLEAR_LINE);
        end;
  $4000..$47ff:mem_misc[direccion]:=valor;
  $6000..$67ff:memoria[$a000+(direccion and $7ff)]:=valor;
  $e000..$ffff:;
end;
end;

function gyruss_sound_getbyte(direccion:word):byte;
begin
case direccion of
  0..$63ff:gyruss_sound_getbyte:=mem_snd[direccion];
  $8000:gyruss_sound_getbyte:=sound_latch;
end;
end;

procedure gyruss_sound_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$5fff:;
  $6000..$63ff:mem_snd[direccion]:=valor;
end;
end;

function gyruss_sound_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
 $01:gyruss_sound_inbyte:=ay8910_0.Read;
 $05:gyruss_sound_inbyte:=ay8910_1.Read;
 $09:gyruss_sound_inbyte:=ay8910_2.Read;
 $0d:gyruss_sound_inbyte:=ay8910_3.Read;
 $11:gyruss_sound_inbyte:=ay8910_4.Read;
end;
end;

procedure gyruss_sound_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $00:ay8910_0.Control(valor);
  $02:ay8910_0.Write(valor);
  $04:ay8910_1.Control(valor);
  $06:ay8910_1.Write(valor);
  $08:ay8910_2.Control(valor);
  $0a:ay8910_2.Write(valor);
  $0c:ay8910_3.Control(valor);
  $0e:ay8910_3.Write(valor);
  $10:ay8910_4.Control(valor);
  $12:ay8910_4.Write(valor);
  $14:mcs48_0.change_irq(ASSERT_LINE);
  $18:sound_latch2:=valor;
end;
end;

function gyruss_sound2_getbyte(direccion:word):byte;
begin
if direccion<$1000 then gyruss_sound2_getbyte:=mem_sound_sub[direccion];
end;

function gyruss_sound2_inport(puerto:word):byte;
begin
if puerto<$100 then gyruss_sound2_inport:=sound_latch2;
end;

procedure gyruss_sound2_outport(puerto:word;valor:byte);
begin
case puerto of
  MCS48_PORT_P1:dac_0.data8_w(valor);
  MCS48_PORT_P2:mcs48_0.change_irq(CLEAR_LINE);
end;
end;

function gyruss_portar:byte;
begin
  gyruss_portar:=gyruss_timer[((z80_1.contador+round(scan_line*z80_1.tframes)) div 1024) mod 10];
end;

procedure gyruss_sound_update;
var
  out_left,out_right:integer;
begin
  out_right:=ay8910_0.update_internal^;
  out_left:=ay8910_1.update_internal^;
  out_right:=out_right+ay8910_2.update_internal^;
  out_right:=(out_right+ay8910_3.update_internal^) div 3;
  out_left:=out_left+ay8910_4.update_internal^;
  out_left:=(out_left+dac_0.internal_update) div 3;
  tsample[ay8910_0.get_sample_num,sound_status.posicion_sonido]:=out_left;
  tsample[ay8910_0.get_sample_num,sound_status.posicion_sonido+1]:=out_right;
end;

//Main
procedure gyruss_reset;
begin
z80_0.reset;
m6809_0.reset;
z80_1.reset;
mcs48_0.reset;
ay8910_0.reset;
ay8910_1.reset;
ay8910_2.reset;
ay8910_3.reset;
ay8910_4.reset;
dac_0.reset;
reset_audio;
main_nmi:=false;
sub_irq:=false;
sound_latch:=0;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
end;

function gyruss_iniciar:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 8*8+0,8*8+1,8*8+2,8*8+3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
var
  colores:tpaleta;
  f:word;
  bit0,bit1,bit2:byte;
  memoria_temp:array[0..$7fff] of byte;
  rgweights:array[0..2] of single;
  bweights:array[0..1] of single;
const
  resistances_rg:array[0..2] of integer=(1000,470,220);
  resistances_b:array[0..1] of integer=(470,220);
begin
gyruss_iniciar:=false;
iniciar_audio(true);
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(18432000 div 6,256);
z80_0.change_ram_calls(gyruss_getbyte,gyruss_putbyte);
//Sub CPU
m6809_0:=cpu_m6809.Create(18432000 div 12,256,TCPU_M6809);
m6809_0.change_ram_calls(gyruss_sub_getbyte,gyruss_sub_putbyte);
//Sound CPU
z80_1:=cpu_z80.create(14318180 div 4,256);
z80_1.change_ram_calls(gyruss_sound_getbyte,gyruss_sound_putbyte);
z80_1.change_io_calls(gyruss_sound_inbyte,gyruss_sound_outbyte);
z80_1.init_sound(gyruss_sound_update);
//Sound CPU 2
mcs48_0:=cpu_mcs48.create(8000000,256,I8039);
mcs48_0.change_ram_calls(gyruss_sound2_getbyte,nil);
mcs48_0.change_io_calls(gyruss_sound2_inport,gyruss_sound2_outport);
//Sound Chip
ay8910_0:=ay8910_chip.create(14318180 div 8,AY8910,1);
ay8910_1:=ay8910_chip.create(14318180 div 8,AY8910,1,true);
ay8910_2:=ay8910_chip.create(14318180 div 8,AY8910,1,true);
ay8910_2.change_io_calls(gyruss_portar,nil,nil,nil);
ay8910_3:=ay8910_chip.create(14318180 div 8,AY8910,1,true);
ay8910_4:=ay8910_chip.create(14318180 div 8,AY8910,1,true);
dac_0:=dac_chip.Create(1,true);
//Main ROMS
if not(roms_load(@memoria,gyruss_rom)) then exit;
//Sub ROMS
if not(roms_load(@mem_misc,gyruss_sub)) then exit;
konami1_decode(@mem_misc[$e000],@mem_opcodes[0],$2000);
//Sound ROMS
if not(roms_load(@mem_snd,gyruss_sound)) then exit;
if not(roms_load(@mem_sound_sub,gyruss_sound_sub)) then exit;
//cargar chars
if not(roms_load(@memoria_temp,gyruss_char)) then exit;
init_gfx(0,8,8,$200);
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,true,false);
//cargar sprites
if not(roms_load(@memoria_temp,gyruss_sprites)) then exit;
init_gfx(1,8,16,$200);
gfx_set_desc_data(4,2,64*8,$4000*8+4,$4000*8+0,4,0);
convert_gfx(1,0,@memoria_temp,@pc_x,@ps_y,true,false);
gfx_set_desc_data(4,2,64*8,($4000+$10)*8+4,($4000+$10)*8+0,($10*8)+4,($10*8)+0);
convert_gfx(1,$100*8*16,@memoria_temp,@pc_x,@ps_y,true,false);
gfx[1].x:=16;
gfx[1].y:=8;
//paleta de colores
if not(roms_load(@memoria_temp,gyruss_pal)) then exit;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances_rg[0],@rgweights[0],0,0,
			2,@resistances_b[0],@bweights[0],0,0,
			0,nil,nil,0,0);
for f:=0 to 31 do begin
		// red component */
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=combine_3_weights(@rgweights, bit0, bit1, bit2);
		// green component */
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=combine_3_weights(@rgweights, bit0, bit1, bit2);
		// blue component */
		bit0:=(memoria_temp[f] shr 6) and $01;
		bit1:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=combine_2_weights(@bweights, bit0, bit1);
end;
set_pal(colores,$20);
//CLUT Sprites y chars
for f:=0 to $ff do begin
  gfx[1].colores[f]:=memoria_temp[$20+f] and $f;
  gfx[0].colores[f]:=(memoria_temp[$120+f] and $f)+$10;
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$3b;
marcade.dswc:=$fe;
marcade.dswa_val:=@gyruss_dip_a;
marcade.dswb_val:=@gyruss_dip_b;
marcade.dswc_val:=@gyruss_dip_c;
//Final
gyruss_reset;
gyruss_iniciar:=true;
end;

procedure Cargar_gyruss;
begin
llamadas_maquina.iniciar:=gyruss_iniciar;
llamadas_maquina.bucle_general:=gyruss_principal;
llamadas_maquina.reset:=gyruss_reset;
llamadas_maquina.fps_max:=60.606060606060606060;
end;

end.
