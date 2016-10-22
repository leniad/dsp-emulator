unit burgertime_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,
     pal_engine,sound_engine,misc_functions,m6502;

procedure cargar_btime;

implementation
const
        btime_rom:array[0..4] of tipo_roms=(
        (n:'aa04.9b';l:$1000;p:$c000;crc:$368a25b5),(n:'aa06.13b';l:$1000;p:$d000;crc:$b4ba400d),
        (n:'aa05.10b';l:$1000;p:$e000;crc:$8005bffa),(n:'aa07.15b';l:$1000;p:$f000;crc:$086440ad),());
        btime_char:array[0..6] of tipo_roms=(
        (n:'aa12.7k';l:$1000;p:$0000;crc:$c4617243),(n:'ab13.9k';l:$1000;p:$1000;crc:$ac01042f),
        (n:'ab10.10k';l:$1000;p:$2000;crc:$854a872a),(n:'ab11.12k';l:$1000;p:$3000;crc:$d4848014),
        (n:'aa8.13k';l:$1000;p:$4000;crc:$8650c788),(n:'ab9.15k';l:$1000;p:$5000;crc:$8dec15e6),());
        btime_tiles:array[0..3] of tipo_roms=(
        (n:'ab00.1b';l:$800;p:$0000;crc:$c7a14485),(n:'ab01.3b';l:$800;p:$800;crc:$25b49078),
        (n:'ab02.4b';l:$800;p:$1000;crc:$b8ef56c3),());
        btime_snd:tipo_roms=(n:'ab14.12h';l:$1000;p:$e000;crc:$f55e5211);
        btime_tiles_mem:tipo_roms=(n:'ab03.6b';l:$800;p:$0;crc:$d26bc1f3);
        //Dip
        btime_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$1;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cross Hatch Pattern';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        btime_dip_b:array [0..4] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Bonus Life';number:4;dip:((dip_val:$6;dip_name:'10k'),(dip_val:$4;dip_name:'15k'),(dip_val:$2;dip_name:'20k'),(dip_val:$0;dip_name:'30k'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Enemies';number:2;dip:((dip_val:$8;dip_name:'4'),(dip_val:$0;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'End of Level Pepper';number:2;dip:((dip_val:$10;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  memoria_dec:array[0..$ffff] of byte;
  haz_nmi,bg_cambiado:boolean;
  sound_latch,haz_vb,scroll_bg:byte;
  video_ram,color_ram:array[0..$3ff] of byte;
  mem_tiles:array[0..$7ff] of byte;

procedure update_video_btime;inline;
const
  pant_pos:array[0..7] of byte=(1,2,3,0,5,6,7,4);
var
  f,nchar:word;
  x,y:word;
  atrib:byte;
begin
if bg_cambiado then begin
 if (scroll_bg and $10)<>0 then begin
  for f:=0 to $ff do begin
    x:=f and $f;
    y:=f shr 4;
    nchar:=mem_tiles[pant_pos[scroll_bg and $7]*$100+f];
    put_gfx(x*16,y*16,nchar,8,1,2);
  end;
 end;
 bg_cambiado:=false;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
for f:=0 to $3ff do begin
 if gfx[0].buffer[f] then begin
    x:=f and $1f;
    y:=f shr 5;
    nchar:=video_ram[f]+((color_ram[f] and $3) shl 8);
    put_gfx_trans(x*8,y*8,nchar,0,2,0);
    gfx[0].buffer[f]:=false;
 end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
//Sprites
for f:=0 to 7 do begin
  atrib:=video_ram[f*$80];
  if (atrib and 1)<>0 then begin
    x:=240-video_ram[$40+(f*$80)];
    y:=video_ram[$60+(f*$80)]-1;
    nchar:=video_ram[$20+(f*$80)];
    put_gfx_sprite(nchar,0,(atrib and 2)<>0,(atrib and 4)<>0,1);
    actualiza_gfx_sprite(x,y,3,1);
  end;
end;
actualiza_trozo_final(8,8,240,240,3);
end;

procedure eventos_btime;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  //P2
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  //SYS
  if arcade_input.coin[0] then begin
      marcade.in2:=(marcade.in2 or $40);
      m6502_0.change_nmi(ASSERT_LINE);
  end else begin
      marcade.in2:=(marcade.in2 and $bf);
      if arcade_input.coin[1] then begin
          marcade.in2:=(marcade.in2 or $80);
          m6502_0.change_nmi(ASSERT_LINE);
      end else begin
          marcade.in2:=(marcade.in2 and $7f);
          m6502_0.change_nmi(CLEAR_LINE);
      end;
  end;
  if arcade_input.start[0] then marcade.in2:=marcade.in2 and $fe else marcade.in2:=marcade.in2 or $1;
  if arcade_input.start[1] then marcade.in2:=marcade.in2 and $fd else marcade.in2:=marcade.in2 or $2;
end;
end;

procedure principal_btime;
var
  f:word;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=m6502_0.tframes;
frame_s:=m6502_1.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 271 do begin
  //Main CPU
  m6502_0.run(frame_m);
  frame_m:=frame_m+m6502_0.tframes-m6502_0.contador;
  //Sound CPU
  m6502_1.run(frame_s);
  frame_s:=frame_s+m6502_1.tframes-m6502_1.contador;
  if (((f and 8)<>0) and haz_nmi) then m6502_1.change_nmi(ASSERT_LINE)
    else m6502_1.change_nmi(CLEAR_LINE);
  case f of
    247:begin
          haz_vb:=$80;
          update_video_btime;
        end;
    271:haz_vb:=0;
  end;
 end;
 eventos_btime;
 video_sync;
end;
end;

procedure desencriptar_btime;inline;
var
  act_pc,old_pc:word;
  temp_r:preg_m6502;
begin
//Para desencriptar la ROM hay que tener en cuenta dos cosas, la primera
//solo despues de un opcode de escritura y si el opcode esta en la direccion
//cuya mascara es $0104 se debe desencriptar. Hay que tener cuidado con el
//salto a subrutina (opcode $20) que tambien puede ir encriptado.
temp_r:=m6502_0.get_internal_r;
act_pc:=temp_r.pc;
old_pc:=temp_r.old_pc;
if memoria_dec[old_pc]=$20 then act_pc:=memoria[old_pc+1]+256*memoria[old_pc+2];
if ((act_pc and $0104)=$0104) then memoria_dec[act_pc]:=bitswap8(memoria[act_pc],6,5,3,4,2,7,1,0);
end;

function getbyte_btime(direccion:word):byte;
begin
case direccion of
  0..$7ff,$1000..$1fff,$b000..$ffff:getbyte_btime:=memoria_dec[direccion];
  $4000:getbyte_btime:=marcade.in0;
  $4001:getbyte_btime:=marcade.in1;
  $4002:getbyte_btime:=marcade.in2;
  $4003:getbyte_btime:=marcade.dswa+haz_vb;
  $4004:getbyte_btime:=marcade.dswb;
end;
end;

procedure cambiar_paleta(ncolor:byte);inline;
var
  color:tcolor;
  valor:byte;
begin
valor:=not(buffer_paleta[ncolor]);
color.r:=$21*(valor and 1)+$47*((valor shr 1) and 1)+$97*((valor shr 2) and 1);
color.g:=$21*((valor shr 3) and 1)+$47*((valor shr 4) and 1)+$97*((valor shr 5) and 1);
color.b:=0+$47*((valor shr 6) and 1)+$97*((valor shr 7) and 1);
set_pal_color(color,ncolor);
if ncolor<8 then fillchar(gfx[0].buffer[0],$400,1);
end;

procedure putbyte_btime(direccion:word;valor:byte);
var
  x,y,pos:word;
begin
memoria[direccion]:=valor;
memoria_dec[direccion]:=valor;
case direccion of
  $c00..$c0f:if buffer_paleta[direccion and $f]<>valor then begin
                  buffer_paleta[direccion and $f]:=valor;
                  cambiar_paleta(direccion and $f);
               end;
  $1000..$13ff:if video_ram[direccion and $3ff]<>valor then begin
                  video_ram[direccion and $3ff]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
               end;
  $1400..$17ff:if color_ram[direccion and $3ff]<>valor then begin
                  color_ram[direccion and $3ff]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
               end;
  //Hay un mirror del video y atributos, pero con las coordenadas
  //invertidas  ?¿?¿?¿?¿?
  $1800..$1bff:begin
                  x:=(direccion and $3ff) shr 5;
                  y:=(direccion and $3ff) and $1f;
                  pos:=(y shl 5)+x;
                  if video_ram[pos]<>valor then begin
                    video_ram[pos]:=valor;
                    gfx[0].buffer[pos]:=true;
                  end;
               end;
  $1c00..$1fff:begin
                  x:=(direccion and $3ff) shr 5;
                  y:=(direccion and $3ff) and $1f;
                  pos:=(y shl 5)+x;
                  if color_ram[pos]<>valor then begin
                    color_ram[pos]:=valor;
                    gfx[0].buffer[pos]:=true;
                  end;
               end;
  $4002:main_screen.flip_main_screen:=(valor and 1)<>0;
  $4003:begin
          sound_latch:=valor;
          m6502_1.change_irq(ASSERT_LINE);
        end;
  $4004:if scroll_bg<>valor then begin
          scroll_bg:=valor;
          //Si el fondo no esta activo, lo pinto de negro
          if (scroll_bg shr 2 and $10)=0 then fill_full_screen(1,0);
          bg_cambiado:=true;
        end;
end;
desencriptar_btime;
end;

function getbyte_snd_btime(direccion:word):byte;
begin
case direccion of
  0..$1fff:getbyte_snd_btime:=mem_snd[direccion and $3ff];
  $a000..$bfff:begin
                  getbyte_snd_btime:=sound_latch;
                  m6502_1.change_irq(CLEAR_LINE);
               end;
   $e000..$ffff:getbyte_snd_btime:=mem_snd[$e000+(direccion and $fff)];
end;
end;

procedure putbyte_snd_btime(direccion:word;valor:byte);
begin
if direccion>$dfff then exit;
case direccion of
    0..$1fff:mem_snd[direccion and $3ff]:=valor;
    $2000..$3fff:ay8910_0.Write(valor);
    $4000..$5fff:ay8910_0.Control(valor);
    $6000..$7fff:ay8910_1.Write(valor);
    $8000..$9fff:ay8910_1.Control(valor);
    $c000..$dfff:haz_nmi:=valor<>0;
end;
end;

procedure btime_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

//Main
procedure reset_btime;
begin
m6502_0.reset;
m6502_1.reset;
AY8910_0.reset;
AY8910_1.reset;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$3f;
haz_vb:=0;
sound_latch:=0;
haz_nmi:=false;
bg_cambiado:=true;
scroll_bg:=$10;
end;

function iniciar_btime:boolean;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    ps_x:array[0..15] of dword=(16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7,
			0, 1, 2, 3, 4, 5, 6, 7);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
var
    memoria_temp:array[0..$5fff] of byte;
begin
iniciar_btime:=false;
iniciar_audio(false);
screen_init(1,256,256); //Fondo
screen_init(2,256,256,true); //Chars
screen_init(3,256,256,false,true); //Final
iniciar_video(240,240);
//Main CPU
m6502_0:=cpu_m6502.create(1500000,272,TCPU_M6502);
m6502_0.change_ram_calls(getbyte_btime,putbyte_btime);
//Sound CPU
m6502_1:=cpu_m6502.create(500000,272,TCPU_M6502);
m6502_1.change_ram_calls(getbyte_snd_btime,putbyte_snd_btime);
m6502_1.init_sound(btime_sound_update);
//Sound Chip
AY8910_0:=ay8910_chip.create(1500000,AY8910,1);
AY8910_1:=ay8910_chip.create(1500000,AY8910,1);
//cargar roms
if not(cargar_roms(@memoria[0],@btime_rom[0],'btime.zip',0)) then exit;
copymemory(@memoria_dec[0],@memoria[0],$10000);
//cargar roms audio
if not(cargar_roms(@mem_snd[0],@btime_snd,'btime.zip',1)) then exit;
//Cargar chars
if not(cargar_roms(@memoria_temp[0],@btime_char[0],'btime.zip',0)) then exit;
init_gfx(0,8,8,1024);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,2*1024*8*8,1024*8*8,0);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,true);
//sprites
init_gfx(1,16,16,256);
gfx[1].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,2*256*16*16,256*16*16,0);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,true);
//Cargar tiles
if not(cargar_roms(@memoria_temp[0],@btime_tiles[0],'btime.zip',0)) then exit;
init_gfx(2,16,16,64);
gfx_set_desc_data(3,0,32*8,2*64*16*16,64*16*16,0);
convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,true);
if not(cargar_roms(@mem_tiles[0],@btime_tiles_mem,'btime.zip',1)) then exit;
//DIP
marcade.dswa:=$3f;
marcade.dswb:=$eb;
marcade.dswa_val:=@btime_dip_a;
marcade.dswb_val:=@btime_dip_b;
//final
reset_btime;
iniciar_btime:=true;
end;

procedure Cargar_btime;
begin
llamadas_maquina.iniciar:=iniciar_btime;
llamadas_maquina.bucle_general:=principal_btime;
llamadas_maquina.reset:=reset_btime;
llamadas_maquina.fps_max:=57.444853;
end;

end.
