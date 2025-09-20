unit circuscharlie_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,main_engine,controls_engine,sn_76496,gfx_engine,dac,rom_engine,
     pal_engine,konami_decrypt,sound_engine;

function iniciar_circusc:boolean;

implementation
const
        circusc_rom:array[0..4] of tipo_roms=(
        (n:'380_s05.3h';l:$2000;p:$6000;crc:$48feafcf),(n:'380_r04.4h';l:$2000;p:$8000;crc:$c283b887),
        (n:'380_r03.5h';l:$2000;p:$a000;crc:$e90c0e86),(n:'380_q02.6h';l:$2000;p:$c000;crc:$4d847dc6),
        (n:'380_q01.7h';l:$2000;p:$e000;crc:$18c20adf));
        circusc_snd:array[0..1] of tipo_roms=(
        (n:'380_l14.5c';l:$2000;p:0;crc:$607df0fb),(n:'380_l15.7c';l:$2000;p:$2000;crc:$a6ad30e1));
        circusc_char:array[0..1] of tipo_roms=(
        (n:'380_j12.4a';l:$2000;p:0;crc:$56e5b408),(n:'380_j13.5a';l:$2000;p:$2000;crc:$5aca0193));
        circusc_sprites:array[0..5] of tipo_roms=(
        (n:'380_j06.11e';l:$2000;p:0;crc:$df0405c6),(n:'380_j07.12e';l:$2000;p:$2000;crc:$23dfe3a6),
        (n:'380_j08.13e';l:$2000;p:$4000;crc:$3ba95390),(n:'380_j09.14e';l:$2000;p:$6000;crc:$a9fba85a),
        (n:'380_j10.15e';l:$2000;p:$8000;crc:$0532347e),(n:'380_j11.16e';l:$2000;p:$a000;crc:$e1725d24));
        circusc_pal:array[0..2] of tipo_roms=(
        (n:'380_j18.2a';l:$20;p:0;crc:$10dd4eaa),(n:'380_j17.7b';l:$100;p:$20;crc:$13989357),
        (n:'380_j16.10c';l:$100;p:$120;crc:$c244f2aa));
        //Dip
        circusc_dip_a:array [0..2] of def_dip2=(
        (mask:$f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),
        (mask:$f0;name:'Coin B';number:16;val16:($20,$50,$80,$40,$10,$f0,$30,$70,$e0,$60,$d0,$c0,$b0,$a0,$90,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),());
        circusc_dip_b:array [0..5] of def_dip2=(
        (mask:$3;name:'Lives';number:4;val4:(3,2,1,0);name4:('3','4','5','7')),
        (mask:$4;name:'Cabinet';number:2;val2:(0,4);name2:('Upright','Cocktail')),
        (mask:$8;name:'Bonus Life';number:2;val2:(8,0);name2:('20K 90K 70K+','30K 110K 80K+')),
        (mask:$60;name:'Difficulty';number:4;val4:($60,$40,$20,0);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')),());

var
 irq_ena:boolean;
 mem_opcodes:array[0..$9fff] of byte;
 sound_latch,scroll_x:byte;
 spritebank:word;

procedure update_video_circusc;
var
  x,y,atrib:byte;
  f,nchar,color:word;
begin
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=31-(f div 32);
      y:=f mod 32;
      atrib:=memoria[$3000+f];
      nchar:=memoria[$3400+f]+((atrib and $20) shl 3);
      color:=(atrib and $f) shl 4;
      if (atrib and $10)=0 then begin
        put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $80)<>0,(atrib and $40)<>0);
        put_gfx_block(x*8,y*8,2,8,8,0);
      end else begin
        put_gfx_block_trans(x*8,y*8,1,8,8);
        put_gfx_flip(x*8,y*8,nchar,color,2,0,(atrib and $80)<>0,(atrib and $40)<>0);
      end;
      gfx[0].buffer[f]:=false;
    end;
end;
actualiza_trozo(0,0,256,80,2,0,0,256,80,3);
scroll__x_part(2,3,scroll_x,0,80,176);
//Sprites
for f:=0 to $3f do begin
  atrib:=memoria[spritebank+1+(f*4)];
  nchar:=(memoria[spritebank+(f*4)]+((atrib and $20) shl 3)) mod 384;
  color:=(atrib and $f) shl 4;
  x:=240-memoria[spritebank+3+(f*4)];
  y:=memoria[spritebank+2+(f*4)];
  put_gfx_sprite_mask(nchar,color,(atrib and $80)<>0,(atrib and $40)<>0,1,0,$f);
  actualiza_gfx_sprite(x,y,3,1);
end;
actualiza_trozo(0,0,256,80,1,0,0,256,80,3);
scroll__x_part(1,3,scroll_x,0,80,176);
actualiza_trozo_final(16,0,224,256,3);
end;

procedure eventos_circusc;
begin
if event.arcade then begin
  //p1
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  //p2
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  //misc
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
end;
end;

procedure circusc_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=m6809_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    //main
    m6809_0.run(frame_m);
    frame_m:=frame_m+m6809_0.tframes-m6809_0.contador;
    //snd
    z80_0.run(frame_s);
    frame_s:=frame_s+z80_0.tframes-z80_0.contador;
    if f=239 then begin
      if irq_ena then m6809_0.change_irq(HOLD_LINE);
      update_video_circusc;
    end;
  end;
  eventos_circusc;
  video_sync;
end;
end;

function circusc_getbyte(direccion:word):byte;
begin
case direccion of
    $1000..$13ff:case (direccion and $3) of
                0:circusc_getbyte:=marcade.in2;  //system
                1:circusc_getbyte:=marcade.in0;  //p1
                2:circusc_getbyte:=marcade.in1;  //p2
                3:circusc_getbyte:=0;
               end;
    $1400..$17ff:circusc_getbyte:=marcade.dswa;  //dsw1
    $1800..$1bff:circusc_getbyte:=marcade.dswb;  //dsw2
    $2000..$3fff:circusc_getbyte:=memoria[direccion];
    $6000..$ffff:if m6809_0.opcode then circusc_getbyte:=mem_opcodes[direccion-$6000]
                    else circusc_getbyte:=memoria[direccion];
end;
end;

procedure circusc_putbyte(direccion:word;valor:byte);
begin
case direccion of
  $0..$3ff:case (direccion and $7) of
              0:main_screen.flip_main_screen:=(valor and 1)<>0;
              1:irq_ena:=(valor<>0);
              5:spritebank:=$3800+((valor and 1) shl 8);
           end;
  $800..$bff:sound_latch:=valor;
  $c00..$fff:z80_0.change_irq(HOLD_LINE);
  $1c00..$1fff:scroll_x:=256-valor;
  $2000..$2fff,$3800..$3fff:memoria[direccion]:=valor;
  $3000..$37ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $6000..$ffff:; //ROM
end;
end;

function circusc_snd_getbyte(direccion:word):byte;
begin
case direccion of
 $0..$3fff:circusc_snd_getbyte:=mem_snd[direccion];
 $4000..$5fff:circusc_snd_getbyte:=mem_snd[$4000+(direccion and $3ff)];
 $6000..$7fff:circusc_snd_getbyte:=sound_latch;
 $8000..$9fff:circusc_snd_getbyte:=(z80_0.totalt shr 9) and $1e;
end;
end;

procedure circusc_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:; //ROM
  $4000..$5fff:mem_snd[$4000+(direccion and $3ff)]:=valor;
  $a000..$bfff:case (direccion and $7) of
                0:sound_latch:=valor;
                1:sn_76496_0.Write(sound_latch);
		            2:sn_76496_1.Write(sound_latch);
                3:dac_0.data8_w(valor);
              end;
end;
end;

procedure circusc_sound;
begin
  sn_76496_0.Update;
  sn_76496_1.Update;
  dac_0.update;
end;

//Main
procedure reset_circusc;
begin
 m6809_0.reset;
 z80_0.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 dac_0.reset;
 reset_video;
 reset_audio;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
 irq_ena:=false;
 sound_latch:=0;
 scroll_x:=0;
 spritebank:=$3800;
end;

function iniciar_circusc:boolean;
var
  colores:tpaleta;
  bit0,bit1,bit2:byte;
  f:word;
  memoria_temp:array[0..$ffff] of byte;
const
    pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
    ps_x:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
			8*4, 9*4, 10*4, 11*4, 12*4, 13*4, 14*4, 15*4);
    ps_y:array[0..15] of dword=(0*4*16, 1*4*16, 2*4*16, 3*4*16, 4*4*16, 5*4*16, 6*4*16, 7*4*16,
			8*4*16, 9*4*16, 10*4*16, 11*4*16, 12*4*16, 13*4*16, 14*4*16, 15*4*16);
begin
llamadas_maquina.bucle_general:=circusc_principal;
llamadas_maquina.reset:=reset_circusc;
iniciar_circusc:=false;
iniciar_audio(false);
screen_init(1,256,256,true);
screen_mod_scroll(1,256,256,255,256,256,255);
screen_init(2,256,256);
screen_mod_scroll(2,256,256,255,256,256,255);
screen_init(3,256,256,false,true);
iniciar_video(224,256);
//Main CPU
m6809_0:=cpu_m6809.Create(2048000,$100,TCPU_M6809);
m6809_0.change_ram_calls(circusc_getbyte,circusc_putbyte);
//Sound CPU
z80_0:=cpu_z80.create(3579545,$100);
z80_0.change_ram_calls(circusc_snd_getbyte,circusc_snd_putbyte);
z80_0.init_sound(circusc_sound);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(1789772);
sn_76496_1:=sn76496_chip.Create(1789772);
dac_0:=dac_chip.Create;
//cargar roms y desencriptarlas
if not(roms_load(@memoria,circusc_rom)) then exit;
konami1_decode(@memoria[$6000],@mem_opcodes[0],$a000);
//roms sonido
if not(roms_load(@mem_snd,circusc_snd)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,circusc_char)) then exit;
init_gfx(0,8,8,512);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@ps_x,@pc_y,true,false);
//sprites
if not(roms_load(@memoria_temp,circusc_sprites)) then exit;
init_gfx(1,16,16,384);
gfx_set_desc_data(4,0,128*8,0,1,2,3);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,true,false);
//paleta
if not(roms_load(@memoria_temp,circusc_pal)) then exit;
for f:=0 to $1f do begin
    bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=$21*bit0+$47*bit1+$97*bit2;
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=$21*bit0+$47*bit1+$97*bit2;
		bit0:=0;
		bit1:=(memoria_temp[f] shr 6) and $01;
		bit2:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=$21*bit0+$47*bit1+$97*bit2;
end;
set_pal(colores,32);
for f:=0 to $ff do begin
  gfx[0].colores[f]:=(memoria_temp[$20+f] and $f)+$10;  //chars
  gfx[1].colores[f]:=memoria_temp[$120+f] and $f;  //sprites
end;
//DIP
marcade.dswa:=$ff;
marcade.dswb:=$4b;
marcade.dswa_val2:=@circusc_dip_a;
marcade.dswb_val2:=@circusc_dip_b;
//final
reset_circusc;
iniciar_circusc:=true;
end;

end.
