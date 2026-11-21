unit higemaru_hw;

interface
uses rom_engine;

function iniciar_higemaru:boolean;

const
        higemaru_rom:array[0..3] of tipo_roms=(
        (n:'hg4.p12';l:$2000;p:0;crc:$dc67a7f9),(n:'hg5.m12';l:$2000;p:$2000;crc:$f65a4b68),
        (n:'hg6.p11';l:$2000;p:$4000;crc:$5f5296aa),(n:'hg7.m11';l:$2000;p:$6000;crc:$dc5d455d));
        higemaru_pal:array[0..2] of tipo_roms=(
        (n:'hgb3.l6';l:$20;p:0;crc:$629cebd8),(n:'hgb5.m4';l:$100;p:$20;crc:$dbaa4443),
        (n:'hgb1.h7';l:$100;p:$120;crc:$07c607ce));
        higemaru_char:tipo_roms=(n:'hg3.m1';l:$2000;p:0;crc:$b37b88c8);
        higemaru_sprites:array[0..2] of tipo_roms=(
        (n:'hg1.c14';l:$2000;p:0;crc:$ef4c2f5d),(n:'hg2.e14';l:$2000;p:$2000;crc:$9133f804),());

implementation
uses nz80,main_engine,controls_engine,ay_8910,gfx_engine,pal_engine,sound_engine;

const
        higemaru_dip_a:array [0..2] of def_dip2=(
        (mask:7;name:'Coin A';number:8;val8:(1,2,3,4,7,6,5,0);name8:('5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 5C','Free Play')),
        (mask:$38;name:'Coin B';number:8;val8:(8,$10,$18,$20,$38,$30,$28,0);name8:('5C 1C','4C 1C','3C 1C','2C 1C','1C 1C','1C 2C','1C 5C','Free Play')),
        (mask:$c0;name:'Lives';number:4;val4:($80,$40,$c0,0);name4:('1','2','3','5')));
        higemaru_dip_b:array [0..4] of def_dip2=(
        (mask:1;name:'Cabinet';number:2;val2:(0,1);name2:('Upright','Cocktail')),
        (mask:$e;name:'Bonus Life';number:8;val8:($e,$c,$a,8,6,4,2,0);name8:('10K 50K 50K+','10K 60K 60K+','20K 60K 60K+','20K 70K 70K+','30K 70K 70K+','30K 80K 80K+','40K 100K 100K+','None')),
        (mask:$10;name:'Demo Sounds';number:2;val2:(0,$10);name2:('Off','On')),
        (mask:$20;name:'Demo Music';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Flip Screen';number:2;val2:($40,0);name2:('Off','On')));

procedure update_video_higemaru;
var
  f,nchar:word;
  color,x,y,attr:byte;
begin
for f:=$3ff downto 0 do begin
  //Chars
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    attr:=memoria[f+$d400];
    color:=(attr and $1f) shl 2;
    nchar:=memoria[f+$d000]+((attr and $80) shl 1);
    put_gfx_flip(x*8,y*8,nchar,color,1,0,(attr and $40)<>0,(attr and $20)<>0);
    if (attr and $80)=0 then put_gfx_block_trans(x*8,y*8,2,8,8)
        else put_gfx_trans_flip(x*8,y*8,nchar,color,2,0,(attr and $40)<>0,(attr and $20)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
//sprites
for f:=$17 downto 0 do begin
    nchar:=memoria[$d880+(f*16)];
    attr:=memoria[$d884+(f*16)];
    color:=(attr and $f) shl 4;
    x:=memoria[$d88c+(f*16)];
    y:=memoria[$d888+(f*16)];
    put_gfx_sprite(nchar,color,(attr and $10)<>0,(attr and $20)<>0,1);
    actualiza_gfx_sprite(x,y,3,1);
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
actualiza_trozo_final(0,16,256,224,3);
end;

procedure eventos_higemaru;
begin
if event.arcade then begin
  marcade.in0:=$ff;
  marcade.in1:=$ff;
  marcade.in2:=$ff;
  //P1
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $fe;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fd;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $fb;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $f7;
  //P2
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $fe;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fd;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $fb;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $f7;
  //System
  if arcade_input.but0[1] then marcade.in2:=marcade.in2 and $fd;
  if arcade_input.but0[0] then marcade.in2:=marcade.in2 and $f7;
  if arcade_input.start[1] then marcade.in2:=marcade.in2 and $ef;
  if arcade_input.start[0] then marcade.in2:=marcade.in2 and $df;
  if arcade_input.coin[1] then marcade.in2:=marcade.in2 and $bf;
  if arcade_input.coin[0] then marcade.in2:=marcade.in2 and $7f;
end;
end;

procedure higemaru_principal;
var
  f:word;
begin
while EmuStatus=EsRunning do begin
  for f:=0 to 261 do begin
    case f of
      109:z80_0.change_irq_vector(HOLD_LINE,$cf);
      240:begin
            z80_0.change_irq_vector(HOLD_LINE,$d7);
            update_video_higemaru;
          end;
    end;
    //main
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
  end;
  eventos_higemaru;
  video_sync;
end;
end;

function higemaru_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$d000..$d7ff,$d880..$d9ff,$e000..$efff:higemaru_getbyte:=memoria[direccion];
  $c000:higemaru_getbyte:=marcade.in0;
  $c001:higemaru_getbyte:=marcade.in1;
  $c002:higemaru_getbyte:=marcade.in2;
  $c003:higemaru_getbyte:=marcade.dswa;
  $c004:higemaru_getbyte:=marcade.dswb;
end;
end;

procedure higemaru_putbyte(direccion:word;valor:byte);
begin
case direccion of
   0..$7fff:;
   $c800:main_screen.flip_main_screen:=(valor and $80)<>0;
   $c801:ay8910_0.control(valor);
   $c802:ay8910_0.write(valor);
   $c803:ay8910_1.control(valor);
   $c804:ay8910_1.write(valor);
   $d000..$d7ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                end;
   $d880..$d9ff,$e000..$efff:memoria[direccion]:=valor;
end;
end;

procedure higemaru_sound;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

//Main
procedure reset_higemaru;
begin
 z80_0.reset;
 frame_main:=z80_0.tframes;
 ay8910_0.reset;
 ay8910_1.reset;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
end;

function iniciar_higemaru:boolean;
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$3fff] of byte;
const
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
begin
llamadas_maquina.bucle_general:=higemaru_principal;
llamadas_maquina.reset:=reset_higemaru;
llamadas_maquina.scanlines:=262;
llamadas_maquina.fps_max:=6000000/(384*262);
iniciar_higemaru:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(3000000);
z80_0.change_ram_calls(higemaru_getbyte,higemaru_putbyte);
z80_0.init_sound(higemaru_sound);
if not(roms_load(@memoria,higemaru_rom)) then exit;
//Sound Chips
ay8910_0:=ay8910_chip.create(1500000,AY8910);
ay8910_1:=ay8910_chip.create(1500000,AY8910);
//convertir chars
if not(roms_load(@memoria_temp,higemaru_char)) then exit;
init_gfx(0,8,8,$200);
gfx[0].trans[15]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
//convertir sprites
if not(roms_load(@memoria_temp,higemaru_sprites)) then exit;
init_gfx(1,16,16,$80);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,64*8,$80*8*64+4,$80*8*64+0,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//poner la paleta
if not(roms_load(@memoria_temp,higemaru_pal)) then exit;
for f:=0 to $1f do begin
  colores[f].r:=($21*((memoria_temp[f] shr 0) and 1))+($47*((memoria_temp[f] shr 1) and 1))+($97*((memoria_temp[f] shr 2) and 1));
  colores[f].g:=($21*((memoria_temp[f] shr 3) and 1))+($47*((memoria_temp[f] shr 4) and 1))+($97*((memoria_temp[f] shr 5) and 1));
  colores[f].b:=0+($47*((memoria_temp[f] shr 6) and 1))+($97*((memoria_temp[f] shr 7) and 1));
end;
set_pal(colores,32);
//crear la tabla de colores
for f:=0 to $7f do gfx[0].colores[f]:=memoria_temp[f+$20] and $f;
for f:=0 to $ff do gfx[1].colores[f]:=(memoria_temp[f+$120] and $f) or $10;
//Dip
init_dips(1,higemaru_dip_a,$ff);
init_dips(2,higemaru_dip_b,$fe);
//final
reset_higemaru;
iniciar_higemaru:=true;
end;

end.
