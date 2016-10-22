unit megazone_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,konami_decrypt,ay_8910,mcs48,dac;

procedure cargar_megazone;

implementation
const
        megazone_rom:array[0..5] of tipo_roms=(
        (n:'319i07.bin';l:$2000;p:$6000;crc:$94b22ea8),(n:'319i06.bin';l:$2000;p:$8000;crc:$0468b619),
        (n:'319i05.bin';l:$2000;p:$a000;crc:$ac59000c),(n:'319i04.bin';l:$2000;p:$c000;crc:$1e968603),
        (n:'319i03.bin';l:$2000;p:$e000;crc:$0888b803),());
        megazone_char:array[0..2] of tipo_roms=(
        (n:'319e12.bin';l:$2000;p:0;crc:$e0fb7835),(n:'319e13.bin';l:$2000;p:$2000;crc:$3d8f3743),());
        megazone_sprites:array[0..4] of tipo_roms=(
        (n:'319e11.bin';l:$2000;p:0;crc:$965a7ff6),(n:'319e09.bin';l:$2000;p:$2000;crc:$5eaa7f3e),
        (n:'319e10.bin';l:$2000;p:$4000;crc:$7bb1aeee),(n:'319e08.bin';l:$2000;p:$6000;crc:$6add71b1),());
        megazone_pal:array[0..3] of tipo_roms=(
        (n:'319b18.a16';l:$20;p:$0;crc:$23cb02af),(n:'319b16.c6';l:$100;p:$20;crc:$5748e933),
        (n:'319b17.a11';l:$100;p:$120;crc:$1fbfce73),());
        megazone_snd:tipo_roms=(n:'319e02.bin';l:$2000;p:$0;crc:$d5d45edb);
        megazone_snd_sub:tipo_roms=(n:'319e01.bin';l:$1000;p:$0;crc:$ed5725a0);
        megazone_dip_a:array [0..1] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),());
        megazone_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'20K 70K 70K+'),(dip_val:$10;dip_name:'20K 80K 80K+'),(dip_val:$8;dip_name:'30K 90K 90K+'),(dip_val:$0;dip_name:'30K 100K 100K+'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 mem_opcodes:array[0..$bfff] of byte;
 irq_enable:boolean;
 frame,i8039_status,sound_latch,scroll_x,scroll_y:byte;
 mem_snd_sub:array[0..$fff] of byte;

procedure update_video_megazone;
var
    x,y,atrib:byte;
    f,nchar,color:word;
begin
for f:=$3ff downto 0 do begin
 if gfx[0].buffer[f] then begin
    x:=31-(f div 32);
    y:=f mod 32;
    atrib:=memoria[$2800+f];
    color:=(atrib and $f) shl 4;
    nchar:=memoria[$2000+f]+((atrib and $80) shl 1);
    put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $20)<>0,(atrib and $40)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll_x_y(1,3,scroll_x,scroll_y,0,32);
//Sprites
for f:=$ff downto $0 do begin
  atrib:=memoria[$3000+(f*4)];
  nchar:=memoria[$3002+(f*4)];
  color:=(atrib and $f) shl 4;
  x:=memoria[$3001+(f*4)];
  y:=memoria[$3003+(f*4)];
  put_gfx_sprite_mask(nchar,color,(atrib and $80)<>0,(atrib and $40)=0,1,0,$f);
  actualiza_gfx_sprite(x,y+32,3,1);
end;
//Parte de arriba
for x:=31 downto 0 do begin
  f:=(31-x)*32;
  for y:=0 to 5 do begin
    if gfx[1].buffer[f] then begin
      atrib:=memoria[$2c00+f];
      color:=(atrib and $f) shl 4;
      nchar:=memoria[$2400+f]+((atrib and $80) shl 1);
      put_gfx_flip(x*8,y*8,nchar,color,2,0,(atrib and $20)<>0,(atrib and $40)<>0);
      gfx[1].buffer[f]:=false;
    end;
    f:=f+1;
  end;
end;
actualiza_trozo(0,0,256,48,2,0,0,256,48,3);
actualiza_trozo_final(16,0,224,288,3);
end;

procedure eventos_megazone;
begin
if event.arcade then begin
  //marcade.in1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
  //marcade.in2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  //service
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
end;
end;

procedure megazone_principal;
var
  frame_m,frame_s,frame_s_sub:single;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=z80_0.tframes;
frame_s_sub:=mcs48_0.tframes;
while EmuStatus=EsRuning do begin
  for frame:=0 to $ff do begin
    //Main CPU
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //Sound CPU
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    //snd sub
    mcs48_0.run(frame_s_sub);
    frame_s_sub:=frame_s_sub+mcs48_0.tframes-mcs48_0.contador;
    if frame=239 then begin
      if irq_enable then m6809_0.change_irq(HOLD_LINE);
      z80_0.change_irq(HOLD_LINE);
      update_video_megazone;
    end;
  end;
  eventos_megazone;
  video_sync;
end;
end;

function megazone_getbyte(direccion:word):byte;
begin
case direccion of
  $2000..$33ff,$3800..$3fff:megazone_getbyte:=memoria[direccion];
  $4000..$5fff:;
  $6000..$ffff:if m6809_0.opcode then megazone_getbyte:=mem_opcodes[direccion-$6000]
                  else megazone_getbyte:=memoria[direccion];
end;
end;

procedure megazone_putbyte(direccion:word;valor:byte);
begin
if direccion>$4000 then exit;
case direccion of
  $0..$1,$800:; //Coin counter + Watchdog
  $5:main_screen.flip_main_screen:=(valor and $1)<>0;
  $7:irq_enable:=(valor and 1)<>0;
  $1000:scroll_y:=valor;
  $1800:scroll_x:=valor;
  $2000..$23ff,$2800..$2bff:begin
          gfx[0].buffer[direccion and $3ff]:=true;
          memoria[direccion]:=valor;
      end;
  $2400..$27ff,$2c00..$2fff:begin
          gfx[1].buffer[direccion and $3ff]:=true;
          memoria[direccion]:=valor;
      end;
  $3000..$33ff,$3800..$3fff:memoria[direccion]:=valor;
end;
end;

function megazone_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff:megazone_snd_getbyte:=mem_snd[direccion];
  $6000:megazone_snd_getbyte:=marcade.in0; //service
  $6001:megazone_snd_getbyte:=marcade.in1; //in1
  $6002:megazone_snd_getbyte:=marcade.in2; //in2
  $8000:megazone_snd_getbyte:=marcade.dswb; //dsw2
  $8001:megazone_snd_getbyte:=marcade.dswa; //dsw1
  $e000..$e7ff:megazone_snd_getbyte:=memoria[(direccion and $7ff)+$3800];
end;
end;

procedure megazone_snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$2000 then exit;
case direccion of
  $2000:mcs48_0.change_irq(ASSERT_LINE);
  $4000:sound_latch:=valor;
  $a000,$c000,$c001:; //NMI+Watch Dog
  $e000..$e7ff:memoria[(direccion and $7ff)+$3800]:=valor;
end;
end;

function megazone_sound_inbyte(puerto:word):byte;
begin
if (puerto and $ff)<3 then megazone_sound_inbyte:=ay8910_0.Read;
end;

procedure megazone_sound_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $00:ay8910_0.Control(valor);
  $02:ay8910_0.Write(valor);
end;
end;

//I8039
function megazone_sound2_getbyte(direccion:word):byte;
begin
if direccion<$1000 then megazone_sound2_getbyte:=mem_snd_sub[direccion];
end;

function megazone_sound2_inport(puerto:word):byte;
begin
if puerto<$100 then megazone_sound2_inport:=sound_latch;
end;

procedure megazone_sound2_outport(valor:byte;puerto:word);
begin
case puerto of
  MCS48_PORT_P1:dac_0.data8_w(valor);
  MCS48_PORT_P2:begin
                  if (valor and $80)=0 then mcs48_0.change_irq(CLEAR_LINE);
                  i8039_status:=(valor and $70) shr 4;
                end;
end;
end;

function megazone_portar:byte;
var
  timer:byte;
begin
timer:=trunc(((z80_0.contador+(z80_0.tframes*frame))*(7159/12288))/(1024/2)) and $f;
megazone_portar:=(timer shl 4) or i8039_status;
end;

procedure megazone_portbw(valor:byte); //filter RC
begin
end;

procedure megazone_sound_update;
begin
  ay8910_0.update;
  dac_0.update;
end;

//Main
procedure reset_megazone;
begin
 m6809_0.reset;
 z80_0.reset;
 mcs48_0.reset;
 ay8910_0.reset;
 dac_0.reset;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 irq_enable:=false;
 sound_latch:=0;
 scroll_x:=0;
 scroll_y:=0;
 i8039_status:=0;
end;

function iniciar_megazone:boolean;
var
  colores:tpaleta;
  f:word;
  bit0,bit1,bit2:byte;
  memoria_temp:array[0..$ffff] of byte;
  rweights,gweights:array[0..3] of single;
  bweights:array[0..2] of single;
const
    pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
    pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 24*8+0, 24*8+1, 24*8+2, 24*8+3);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8 ,
		32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
    resistances_rg:array[0..2] of integer=(1000,470,220);
    resistances_b:array[0..1] of integer=(470,220);
begin
iniciar_megazone:=false;
iniciar_audio(false);
//Pantallas
screen_init(1,256,256);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,48);
screen_init(3,256,288,false,true);
screen_mod_sprites(3,256,512,255,511);
iniciar_video(224,288);
//Main CPU
m6809_0:=cpu_m6809.Create(18432000 div 9,$100);
m6809_0.change_ram_calls(megazone_getbyte,megazone_putbyte);
//Sound CPU
z80_0:=cpu_z80.create(18432000 div 6,$100);
z80_0.change_ram_calls(megazone_snd_getbyte,megazone_snd_putbyte);
z80_0.change_io_calls(megazone_sound_inbyte,megazone_sound_outbyte);
z80_0.init_sound(megazone_sound_update);
//Sound CPU 2
mcs48_0:=cpu_mcs48.create(14318000 div 2,$100,I8039);
mcs48_0.change_ram_calls(megazone_sound2_getbyte,nil);
mcs48_0.change_io_calls(megazone_sound2_inport,megazone_sound2_outport);
//Sound Chip
ay8910_0:=ay8910_chip.create(14318000 div 8,AY8910,0.3);
ay8910_0.change_io_calls(megazone_portar,nil,nil,megazone_portbw);
dac_0:=dac_chip.Create(0.5);
//cargar roms
if not(cargar_roms(@memoria[0],@megazone_rom[0],'megazone.zip',0)) then exit;
konami1_decode(@memoria[$6000],@mem_opcodes[0],$c000);
//Cargar roms sound
if not(cargar_roms(@mem_snd[0],@megazone_snd,'megazone.zip',1)) then exit;
if not(cargar_roms(@mem_snd_sub[0],@megazone_snd_sub,'megazone.zip',1)) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@megazone_char,'megazone.zip',0)) then exit;
init_gfx(0,8,8,$200);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//sprites
if not(cargar_roms(@memoria_temp[0],@megazone_sprites[0],'megazone.zip',0)) then exit;
init_gfx(1,16,16,$100);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,$4000*8+4,$4000*8+0,4,0);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
//paleta
if not(cargar_roms(@memoria_temp[0],@megazone_pal[0],'megazone.zip',0)) then exit;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances_rg[0],@rweights[0],1000,0,
			3,@resistances_rg[0],@gweights[0],1000,0,
			2,@resistances_b[0],@bweights[0],1000,0);
for f:=0 to $1f do begin
		// red component */
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=combine_3_weights(@rweights[0], bit0, bit1, bit2);
		// green component */
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=combine_3_weights(@gweights[0], bit0, bit1, bit2);
		// blue component */
		bit0:=(memoria_temp[f] shr 6) and $01;
		bit1:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=combine_2_weights(@bweights[0], bit0, bit1);
end;
set_pal(colores,$20);
for f:=0 to $ff do begin
    gfx[0].colores[f]:=(memoria_temp[$120+f] and $f) or $10;
    gfx[1].colores[f]:=memoria_temp[$20+f] and $f;
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$5b;
marcade.dswa_val:=@megazone_dip_a;
marcade.dswb_val:=@megazone_dip_b;
//final
reset_megazone;
iniciar_megazone:=true;
end;

procedure Cargar_megazone;
begin
llamadas_maquina.iniciar:=iniciar_megazone;
llamadas_maquina.bucle_general:=megazone_principal;
llamadas_maquina.reset:=reset_megazone;
end;

end.
