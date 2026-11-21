unit shootout_hw;

interface
uses rom_engine;

function iniciar_shootout:boolean;

const
        shootout_rom:array[0..2] of tipo_roms=(
        (n:'cu00.b1';l:$8000;p:0;crc:$090edeb6),(n:'cu02.c3';l:$8000;p:$8000;crc:$2a913730),
        (n:'cu01.c1';l:$4000;p:$10000;crc:$8843c3ae));
        shootout_char:tipo_roms=(n:'cu11.h19';l:$4000;p:0;crc:$eff00460);
        shootout_audio:tipo_roms=(n:'cu09.j1';l:$4000;p:$c000;crc:$c4cbd558);
        shootout_tiles:tipo_roms=(n:'cu10.h17';l:$8000;p:0;crc:$3854c877);
        shootout_pal:tipo_roms=(n:'gb08.k10';l:$100;p:0;crc:$509c65b6);
        shootout_sprite:array[0..6] of tipo_roms=(
        (n:'cu04.c7';l:$8000;p:0;crc:$ceea6b20),(n:'cu03.c5';l:$8000;p:$8000;crc:$b786bb3e),
        (n:'cu06.c10';l:$8000;p:$10000;crc:$2ec1d17f),(n:'cu05.c9';l:$8000;p:$18000;crc:$dd038b85),
        (n:'cu08.c13';l:$8000;p:$20000;crc:$91290933),(n:'cu07.c12';l:$8000;p:$28000;crc:$19b6b94f),());

implementation
uses m6502,main_engine,controls_engine,ym_2203,gfx_engine,pal_engine,
     sound_engine,misc_functions;

const
        shootout_dip_a:array [0..4] of def_dip2=(
        (mask:3;name:'Coin A';number:4;val4:(0,3,2,1);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$c;name:'Coin B';number:4;val4:(0,$c,8,4);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$40;name:'Cabinet';number:2;val2:(0,$40);name2:('Upright','Cocktail')),
        (mask:$80;name:'Freeze';number:2;val2:($80,0);name2:('Off','On')));
        shootout_dip_b:array [0..2] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(1,3,2,0);name4:('1','3','5','Infinite')),
        (mask:$c;name:'Bonus Life';number:4;val4:($c,8,4,0);name4:('20K 70K+','30K 80K+','40K 90K+','70K')),
        (mask:$30;name:'Difficulty';number:4;val4:($30,$20,$10,0);name4:('Easy','Normal','Hard','Very Hard')));

var
  mem_bank,mem_bank_dec:array[0..2,0..$3fff] of byte;
  mem_dec:array[0..$7fff] of byte;
  banco,sound_latch:byte;
  bflicker:boolean;
  prioridad:array[0..255,0..255] of boolean;

procedure update_video_shootout;
var
  f,nchar,color:word;
  x,y,atrib:byte;

procedure put_gfx_sprite_shot(nchar:word;flipx:boolean;y_diff,sx,sy:word;atrib:boolean);
var
  x,y,x_real:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x:integer;
begin
nchar:=nchar mod 2048;
pos:=gfx[1].datos;
inc(pos,nchar*16*16);
temp2:=punbuf;
if flipx then begin
  inc(temp2,15);
  dir_x:=-1;
end else begin
  dir_x:=1;
end;
for y:=0 to 15 do begin
  temp:=temp2;
  if flipx then x_real:=15
    else x_real:=0;
  for x:=0 to 15 do begin
    if not(atrib) then begin
      if (pos^<>0) then temp^:=paleta[gfx[1].colores[pos^+64]]
        else temp^:=paleta[MAX_COLORES];
    end else begin
      if ((pos^<>0) and prioridad[x_real+sx,y+sy+y_diff]) then temp^:=paleta[gfx[1].colores[pos^+64]]
        else temp^:=paleta[MAX_COLORES];
    end;
    inc(temp,dir_x);
    inc(x_real,dir_x);
    inc(pos);
  end;
  putpixel_gfx_int(0,y+y_diff,16,PANT_SPRITES);
end;
end;

procedure sprites_update;
var
  f,atrib,x,y:byte;
  nchar:word;
begin
for f:=$7f downto 0 do begin
  atrib:=memoria[$19fd-(f*4)];
  if ((atrib and 1)=0) then continue;
  if (bflicker or ((atrib and 2)=0)) then begin
      nchar:=memoria[$19ff-(f*4)]+((atrib shl 3) and $700);
      x:=240-memoria[$19fe-(f*4)];
      y:=240-memoria[$19fc-(f*4)];
      if (atrib and $10)<>0 then begin //tamaño doble
         nchar:=nchar and $7fe;
         put_gfx_sprite_shot(nchar,(atrib and 4)<>0,0,x,y-16,(atrib and 8)<>0);
         put_gfx_sprite_shot(nchar+1,(atrib and 4)<>0,16,x,y-16,(atrib and 8)<>0);
         actualiza_gfx_sprite_size(x,y-16,3,16,32);
      end else begin
         put_gfx_sprite_shot(nchar,(atrib and 4)<>0,0,x,y,(atrib and 8)<>0);
         actualiza_gfx_sprite(x,y,3,1);
      end;
  end;
end;
end;

procedure put_gfx_shoot(pos_x,pos_y,nchar,color:word);
var
  x,y:byte;
  temp:pword;
  pos:pbyte;
begin
nchar:=nchar mod 2048;
pos:=gfx[0].datos;
inc(pos,nchar*8*8);
for y:=0 to 7 do begin
  temp:=punbuf;
  for x:=0 to 7 do begin
    if pos^<>0 then temp^:=paleta[gfx[0].colores[pos^+color]]
      else temp^:=paleta[MAX_COLORES];
    prioridad[pos_x+x,pos_y+y]:=(pos^=0);
    inc(pos);
    inc(temp);
  end;
  putpixel_gfx_int(pos_x,pos_y+y,8,1);
end;
end;

begin
for f:=0 to $3ff do begin
  //tiles
  if gfx[2].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    atrib:=memoria[$2c00+f];
    color:=(atrib and $f0) shr 2;
    nchar:=memoria[$2800+f]+((atrib and 7) shl 8);
    put_gfx(x*8,y*8,nchar,color,2,2);
    gfx[2].buffer[f]:=false;
  end;
  //Chars
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    atrib:=memoria[$2400+f];
    color:=(atrib and $f0) shr 2;
    nchar:=memoria[$2000+f]+((atrib and 3) shl 8);
    put_gfx_shoot(x*8,y*8,nchar,color+128);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
//La prioridad de los sprites funciona asi:
//Si tiene en el atributo 0 tiene prioridad sobre los chars, pero si tiene 8 se
//pinta por debajo de los chars. Pero tambien se pintan con prioridad entre ellos,
//por lo que no se puede hacer en dos pasadas, creo una matriz con los pixeles si
//son diferentes a 0, y si cuando pinto un sprite tiene el atributo a 8 comparo con
//la matrix del fondo, si no es transparente, pinto el sprite
sprites_update;
actualiza_trozo_final(0,8,256,240,3);
bflicker:=not(bflicker);
end;

procedure eventos_shootout;
begin
if event.arcade then begin
  marcade.in0:=$ff;
  marcade.in1:=$3f;
  //P1
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $fe;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fd;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fb;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $f7;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $bf;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $7f;
  //P2
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $fe;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fd;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fb;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $f7;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef;
  if arcade_input.but1[1] then marcade.in1:=marcade.in1 and $df;
  if arcade_input.coin[0] then begin
      marcade.in1:=marcade.in1 or $80;
      m6502_0.change_nmi(ASSERT_LINE);
  end else if arcade_input.coin[1] then begin
               marcade.in1:=marcade.in1 or $40;
               m6502_0.change_nmi(ASSERT_LINE);
            end else m6502_0.change_nmi(CLEAR_LINE);
end;
end;

procedure principal_shootout;
var
  f:word;
begin
while EmuStatus=EsRunning do begin
 for f:=0 to 261 do begin
   case f of
      8:marcade.dswb:=marcade.dswb or $80;
      248:begin
            marcade.dswb:=marcade.dswb and $7f;
            update_video_shootout;
          end;
   end;
   m6502_0.run(frame_main);
   frame_main:=frame_main+m6502_0.tframes-m6502_0.contador;
   m6502_1.run(frame_snd);
   frame_snd:=frame_snd+m6502_1.tframes-m6502_1.contador;
 end;
 eventos_shootout;
 video_sync;
end;
end;

function getbyte_shootout(direccion:word):byte;
begin
case direccion of
  0..$fff,$1004..$19ff,$2000..$2fff:getbyte_shootout:=memoria[direccion];
  $1000:getbyte_shootout:=marcade.dswa;
  $1001:getbyte_shootout:=marcade.in0;
  $1002:getbyte_shootout:=marcade.in1;
  $1003:getbyte_shootout:=marcade.dswb;
  $4000..$7fff:if m6502_0.opcode then getbyte_shootout:=mem_bank_dec[banco,direccion and $3fff]
                  else getbyte_shootout:=mem_bank[banco,direccion and $3fff];
  $8000..$ffff:if m6502_0.opcode then getbyte_shootout:=mem_dec[direccion and $7fff]
                  else getbyte_shootout:=memoria[direccion];
end;
end;

procedure putbyte_shootout(direccion:word;valor:byte);
begin
case direccion of
  0..$fff,$1004..$19ff:memoria[direccion]:=valor;
  $1000:banco:=valor and $f;
  $1003:begin
          sound_latch:=valor;
          m6502_1.change_nmi(ASSERT_LINE);
        end;
  $2000..$27ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $2800..$2fff:if memoria[direccion]<>valor then begin
                  gfx[2].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $4000..$ffff:; //ROM
end;
end;

function getbyte_snd_shootout(direccion:word):byte;
begin
case direccion of
  0..$7ff,$c000..$ffff:getbyte_snd_shootout:=mem_snd[direccion];
  $4000:getbyte_snd_shootout:=ym2203_0.status;
  $a000:begin
          getbyte_snd_shootout:=sound_latch;
          m6502_1.change_nmi(CLEAR_LINE);
        end;
end;
end;

procedure putbyte_snd_shootout(direccion:word;valor:byte);
begin
case direccion of
  0..$7ff:mem_snd[direccion]:=valor;
  $4000:ym2203_0.control(valor);
  $4001:ym2203_0.write(valor);
  $c000..$ffff:; //ROM
end;
end;

procedure shootout_sound_update;
begin
  ym2203_0.update;
end;

procedure snd_irq(irqstate:byte);
begin
  m6502_1.change_irq(irqstate);
end;

//Main
procedure reset_shootout;
begin
m6502_0.reset;
m6502_1.reset;
frame_main:=m6502_0.tframes;
frame_snd:=m6502_1.tframes;
ym2203_0.reset;
marcade.in0:=$ff;
marcade.in1:=$3f;
bflicker:=false;
banco:=0;
sound_latch:=0;
end;

function iniciar_shootout:boolean;
var
  colores:tpaleta;
  f:word;
  mem_temp:array[0..$7fff] of byte;
  memoria_temp:array[0..$2ffff] of byte;
const
    pc_x:array[0..7] of dword=(($2000*8)+0, ($2000*8)+1, ($2000*8)+2, ($2000*8)+3, 0, 1, 2, 3);
    ps_x:array[0..15] of dword=(128+0, 128+1, 128+2, 128+3, 128+4, 128+5, 128+6, 128+7, 0, 1, 2, 3, 4, 5, 6, 7);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8, 8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
    pt_x:array[0..7] of dword=(($4000*8)+0, ($4000*8)+1, ($4000*8)+2, ($4000*8)+3, 0, 1, 2, 3);
begin
llamadas_maquina.bucle_general:=principal_shootout;
llamadas_maquina.reset:=reset_shootout;
llamadas_maquina.fps_max:=12000000/2/384/262;
llamadas_maquina.scanlines:=262;
iniciar_shootout:=false;
iniciar_audio(false);
//Chars trans
screen_init(1,256,256,true);
screen_init(2,256,256);
screen_init(3,256,256,false,true);
iniciar_video(256,240);
//Main CPU
m6502_0:=cpu_m6502.create(2000000,TCPU_M6502);
m6502_0.change_ram_calls(getbyte_shootout,putbyte_shootout);
//sound CPU
m6502_1:=cpu_m6502.create(1500000,TCPU_M6502);
m6502_1.change_ram_calls(getbyte_snd_shootout,putbyte_snd_shootout);
m6502_1.init_sound(shootout_sound_update);
//Sound Chip
ym2203_0:=ym2203_chip.create(1500000);
ym2203_0.change_irq_calls(snd_irq);
//cargar roms
if not(roms_load(@memoria_temp,shootout_rom)) then exit;
//Copio las ROM en su sitio
copymemory(@memoria[$8000],@memoria_temp[0],$8000);
copymemory(@mem_bank[0,0],@memoria_temp[$8000],$4000);
copymemory(@mem_bank[1,0],@memoria_temp[$c000],$4000);
copymemory(@mem_bank[2,0],@memoria_temp[$10000],$4000);
//Y las desencripto
for f:=0 to $7fff do mem_dec[f]:=BITSWAP8(memoria[f+$8000],7,5,6,4,3,2,1,0);
for f:=0 to $3fff do begin
  mem_bank_dec[0,f]:=BITSWAP8(mem_bank[0,f],7,5,6,4,3,2,1,0);
  mem_bank_dec[1,f]:=BITSWAP8(mem_bank[1,f],7,5,6,4,3,2,1,0);;
  mem_bank_dec[2,f]:=BITSWAP8(mem_bank[2,f],7,5,6,4,3,2,1,0);;
end;
//Roms audio
if not(roms_load(@mem_snd,shootout_audio)) then exit;
//Cargar chars
if not(roms_load(@memoria_temp,shootout_char)) then exit;
init_gfx(0,8,8,1024);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,8*8,0,4);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
//sprites
if not(roms_load(@memoria_temp,shootout_sprite)) then exit;
init_gfx(1,16,16,2048);
gfx[1].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,0*$10000*8,1*$10000*8,2*$10000*8);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//tiles
if not(roms_load(@memoria_temp,shootout_tiles)) then exit;
//mover para sacar tiles
copymemory(@mem_temp[0],@memoria_temp[0],$2000);
copymemory(@mem_temp[$4000],@memoria_temp[$2000],$2000);
copymemory(@mem_temp[$2000],@memoria_temp[$4000],$2000);
copymemory(@mem_temp[$6000],@memoria_temp[$6000],$2000);
init_gfx(2,8,8,2048);
gfx_set_desc_data(2,0,8*8,0,4);
convert_gfx(2,0,@mem_temp,@pt_x,@ps_y,false,false);
//poner la paleta
if not(roms_load(@memoria_temp,shootout_pal)) then exit;
for f:=0 to 255 do begin
    colores[f].r:=$21*((memoria_temp[f] shr 0) and 1)+$47*((memoria_temp[f] shr 1) and 1)+$97*((memoria_temp[f] shr 2) and 1);
    colores[f].g:=$21*((memoria_temp[f] shr 3) and 1)+$47*((memoria_temp[f] shr 4) and 1)+$97*((memoria_temp[f] shr 5) and 1);
    colores[f].b:=$21*0+$47*((memoria_temp[f] shr 6) and 1)+$97*((memoria_temp[f] shr 7) and 1);
end;
set_pal(colores,256);
//Dip
init_dips(1,shootout_dip_a,$bf);
init_dips(2,shootout_dip_b,$bf);
//final
reset_shootout;
iniciar_shootout:=true;
end;

end.
