unit burgertime_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,
     pal_engine,sound_engine,misc_functions,m6502;

function iniciar_btime:boolean;

implementation
const
        btime_rom:array[0..3] of tipo_roms=(
        (n:'aa04.9b';l:$1000;p:$c000;crc:$368a25b5),(n:'aa06.13b';l:$1000;p:$d000;crc:$b4ba400d),
        (n:'aa05.10b';l:$1000;p:$e000;crc:$8005bffa),(n:'aa07.15b';l:$1000;p:$f000;crc:$086440ad));
        btime_char:array[0..5] of tipo_roms=(
        (n:'aa12.7k';l:$1000;p:$0000;crc:$c4617243),(n:'ab13.9k';l:$1000;p:$1000;crc:$ac01042f),
        (n:'ab10.10k';l:$1000;p:$2000;crc:$854a872a),(n:'ab11.12k';l:$1000;p:$3000;crc:$d4848014),
        (n:'aa8.13k';l:$1000;p:$4000;crc:$8650c788),(n:'ab9.15k';l:$1000;p:$5000;crc:$8dec15e6));
        btime_tiles:array[0..2] of tipo_roms=(
        (n:'ab00.1b';l:$800;p:$0000;crc:$c7a14485),(n:'ab01.3b';l:$800;p:$800;crc:$25b49078),
        (n:'ab02.4b';l:$800;p:$1000;crc:$b8ef56c3));
        btime_snd:tipo_roms=(n:'ab14.12h';l:$1000;p:$e000;crc:$f55e5211);
        btime_tiles_mem:tipo_roms=(n:'ab03.6b';l:$800;p:$0;crc:$d26bc1f3);
        btime_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$1;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Cross Hatch Pattern';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        btime_dip_b:array [0..4] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Bonus Life';number:4;dip:((dip_val:$6;dip_name:'10K'),(dip_val:$4;dip_name:'15K'),(dip_val:$2;dip_name:'20K'),(dip_val:$0;dip_name:'30K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Enemies';number:2;dip:((dip_val:$8;dip_name:'4'),(dip_val:$0;dip_name:'6'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'End of Level Pepper';number:2;dip:((dip_val:$10;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        lnc_rom:array[0..3] of tipo_roms=(
        (n:'s3-3d';l:$1000;p:$c000;crc:$1ab4f2c2),(n:'s2-3c';l:$1000;p:$d000;crc:$5e46b789),
        (n:'s1-3b';l:$1000;p:$e000;crc:$1308a32e),(n:'s0-3a';l:$1000;p:$f000;crc:$beb4b1fc));
        lnc_snd:tipo_roms=(n:'sa-1h';l:$1000;p:$e000;crc:$379387ec);
        lnc_char:array[0..5] of tipo_roms=(
        (n:'s4-11l';l:$1000;p:$0000;crc:$a2162a9e),(n:'s5-11m';l:$1000;p:$1000;crc:$12f1c2db),
        (n:'s6-13l';l:$1000;p:$2000;crc:$d21e2a57),(n:'s7-13m';l:$1000;p:$3000;crc:$c4f247cd),
        (n:'s8-15l';l:$1000;p:$4000;crc:$672a92d0),(n:'s9-15m';l:$1000;p:$5000;crc:$87c8ee9a));
        lnc_prom:tipo_roms=(n:'sc-5m';l:$20;p:$0;crc:$2a976ebe);
        lnc_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$1;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Test Mode';number:4;dip:((dip_val:$30;dip_name:'Off'),(dip_val:$0;dip_name:'RAM test only'),(dip_val:$20;dip_name:'Watchdog test only'),(dip_val:$10;dip_name:'Test All'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        lnc_dip_b:array [0..3] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Bonus Life';number:4;dip:((dip_val:$6;dip_name:'15K'),(dip_val:$4;dip_name:'20K'),(dip_val:$2;dip_name:'30K'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Game Speed';number:2;dip:((dip_val:$8;dip_name:'Slow'),(dip_val:$0;dip_name:'Fast'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        mmonkey_rom:array[0..3] of tipo_roms=(
        (n:'mmonkey.e4';l:$1000;p:$c000;crc:$8d31bf6a),(n:'mmonkey.d4';l:$1000;p:$d000;crc:$e54f584a),
        (n:'mmonkey.b4';l:$1000;p:$e000;crc:$399a161e),(n:'mmonkey.a4';l:$1000;p:$f000;crc:$f7d3d1e3));
        mmonkey_snd:tipo_roms=(n:'mmonkey.h1';l:$1000;p:$e000;crc:$5bcb2e81);
        mmonkey_char:array[0..5] of tipo_roms=(
        (n:'mmonkey.l11';l:$1000;p:$0000;crc:$b6aa8566),(n:'mmonkey.m11';l:$1000;p:$1000;crc:$6cc4d0c4),
        (n:'mmonkey.l13';l:$1000;p:$2000;crc:$2a343b7e),(n:'mmonkey.m13';l:$1000;p:$3000;crc:$0230b50d),
        (n:'mmonkey.l14';l:$1000;p:$4000;crc:$922bb3e1),(n:'mmonkey.m14';l:$1000;p:$5000;crc:$f943e28c));
        mmonkey_prom:tipo_roms=(n:'mmi6331.m5';l:$20;p:$0;crc:$55e28b32);
        mmonkey_dip_a:array [0..4] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$3;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$1;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'2C 1C'),(dip_val:$c;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$4;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Free Play';number:4;dip:((dip_val:$10;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$40;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        mmonkey_dip_b:array [0..3] of def_dip=(
        (mask:$1;name:'Lives';number:2;dip:((dip_val:$1;dip_name:'3'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$6;name:'Bonus Life';number:4;dip:((dip_val:$2;dip_name:'15K+'),(dip_val:$4;dip_name:'30K+'),(dip_val:$0;dip_name:'20K'),(dip_val:$6;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Difficulty';number:4;dip:((dip_val:$18;dip_name:'Easy'),(dip_val:$8;dip_name:'Medium'),(dip_val:$10;dip_name:'Hard'),(dip_val:$0;dip_name:'Level Skip Mode'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
  haz_nmi,bg_cambiado,had_written:boolean;
  charbank,sound_latch,bg_control,y_comp:byte;
  video_ram,video_ram2:array[0..$3ff] of byte;
  mem_tiles:array[0..$7ff] of byte;
  update_video,update_events:procedure;
  //Minky Monkey
  protection_status,protection_ret,protection_command,protection_value:byte;

procedure update_video_btime;inline;
const
  pant_pos:array[0..7] of byte=(1,2,3,0,5,6,7,4);
var
  f,nchar,x,y:word;
  atrib:byte;
begin
if (bg_control and $10)<>0 then begin
  if bg_cambiado then begin
    for f:=0 to $ff do begin
      x:=f and $f;
      y:=f shr 4;
      nchar:=mem_tiles[pant_pos[bg_control and $7]*$100+f];
      put_gfx(x*16,y*16,nchar,8,1,2);
    end;
    bg_cambiado:=false;
  end;
end else fill_full_screen(1,0);
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
for f:=0 to $3ff do begin
 if gfx[0].buffer[f] then begin
    x:=f and $1f;
    y:=f shr 5;
    nchar:=video_ram[f]+((video_ram2[f] and $3) shl 8);
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

procedure update_video_lnc;inline;
var
  f,nchar,x,y:word;
  atrib:byte;
begin
for f:=0 to $3ff do begin
 if gfx[0].buffer[f] then begin
    x:=f and $1f;
    y:=f shr 5;
    nchar:=video_ram[f]+((video_ram2[f] and $3) shl 8);
    put_gfx(x*8,y*8,nchar,0,1,0);
    gfx[0].buffer[f]:=false;
 end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
//Sprites
for f:=0 to 7 do begin
  atrib:=video_ram[f*$80];
  if (atrib and 1)<>0 then begin
    x:=240-video_ram[$40+(f*$80)];
    y:=video_ram[$60+(f*$80)]-y_comp;
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

procedure eventos_lnc;
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
      marcade.in2:=(marcade.in2 and $bf);
      m6502_0.change_nmi(ASSERT_LINE);
  end else begin
      marcade.in2:=(marcade.in2 or $40);
      if arcade_input.coin[1] then begin
          marcade.in2:=(marcade.in2 and $7f);
          m6502_0.change_nmi(ASSERT_LINE);
      end else begin
          marcade.in2:=(marcade.in2 or $80);
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
          marcade.dswa:=marcade.dswa or $80;
          update_video;
        end;
    271:marcade.dswa:=marcade.dswa and $7f;
  end;
 end;
 update_events;
 video_sync;
end;
end;

//Burger Time
function getbyte_btime(direccion:word):byte;
var
  tempb:byte;
begin
case direccion of
  0..$7ff,$b000..$ffff:begin
                          tempb:=memoria[direccion];
                          if m6502_0.opcode and had_written then begin
                            had_written:=false;
                            if((direccion and $104)=$104) then tempb:=bitswap8(tempb,6,5,3,4,2,7,1,0);
                          end;
                          getbyte_btime:=tempb;
                       end;
  $1000..$13ff:getbyte_btime:=video_ram[direccion and $3ff];
  $1400..$17ff:getbyte_btime:=video_ram2[direccion and $3ff];
  //OJO! Esto lo quiere SIN ordenar!!!
  $1800..$1bff,$1c00..$1fff:getbyte_btime:=memoria[direccion];
  $4000:getbyte_btime:=marcade.in0;
  $4001:getbyte_btime:=marcade.in1;
  $4002:getbyte_btime:=marcade.in2;
  $4003:getbyte_btime:=marcade.dswa;
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
//Colores 0-7 para chars y sprites
//Colores 8-15 para el fondo
if ncolor<8 then fillchar(gfx[0].buffer[0],$400,1)
  else bg_cambiado:=true;
end;

function calc_pos(dir:word):word;inline;
var
  x,y:byte;
begin
  x:=(dir and $3ff) shr 5;
  y:=(dir and $3ff) and $1f;
  calc_pos:=(y shl 5)+x;
end;

procedure putbyte_btime(direccion:word;valor:byte);
var
  pos:word;
begin
had_written:=true;
case direccion of
  0..$7ff:memoria[direccion]:=valor;
  $c00..$c0f:if buffer_paleta[direccion and $f]<>valor then begin
                  buffer_paleta[direccion and $f]:=valor;
                  cambiar_paleta(direccion and $f);
               end;
  $1000..$13ff:if video_ram[direccion and $3ff]<>valor then begin
                  video_ram[direccion and $3ff]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
               end;
  $1400..$17ff:if video_ram2[direccion and $3ff]<>valor then begin
                  video_ram2[direccion and $3ff]:=valor;
                  gfx[0].buffer[direccion and $3ff]:=true;
               end;
  //Hay un mirror del video y atributos, pero con las coordenadas
  //invertidas  ?¿?¿?¿?¿?, pero lo mas flipante es que luego lo quiere
  //bien en la RAM!!!
  $1800..$1bff:begin
                  pos:=calc_pos(direccion);
                  if video_ram[pos]<>valor then begin
                    video_ram[pos]:=valor;
                    gfx[0].buffer[pos]:=true;
                    memoria[direccion]:=valor;
                  end;
               end;
  $1c00..$1fff:begin
                  pos:=calc_pos(direccion);
                  if video_ram2[pos]<>valor then begin
                    video_ram2[pos]:=valor;
                    gfx[0].buffer[pos]:=true;
                    memoria[direccion]:=valor;
                  end;
               end;
  $4002:main_screen.flip_main_screen:=(valor and 1)<>0;
  $4003:begin
          sound_latch:=valor;
          m6502_1.change_irq(ASSERT_LINE);
        end;
  $4004:if bg_control<>valor then begin
          bg_cambiado:=(bg_control and 7)<>(valor and 7);
          bg_control:=valor;
        end;
  $b000..$ffff:; //ROM
end;
end;

//Lock'n'chase
function getbyte_lnc(direccion:word):byte;
begin
case direccion of
  0..$3bff,$b000..$b1ff,$c000..$ffff:if m6502_0.opcode then getbyte_lnc:=bitswap8(memoria[direccion],7,5,6,4,3,2,1,0)
                                        else getbyte_lnc:=memoria[direccion];
  $3c00..$3fff:getbyte_lnc:=video_ram[direccion and $3ff];
  //OJO! Esto lo quiere SIN ordenar!!!
  $7c00..$7fff:getbyte_lnc:=memoria[direccion];
  $8000:getbyte_lnc:=marcade.dswa;
  $8001:getbyte_lnc:=marcade.dswb;
  $9000:getbyte_lnc:=marcade.in0;
  $9001:getbyte_lnc:=marcade.in1;
  $9002:getbyte_lnc:=marcade.in2;
end;
end;

procedure putbyte_lnc(direccion:word;valor:byte);
var
  pos:word;
begin
case direccion of
  0..$3bff,$b000..$b1ff:memoria[direccion]:=valor;
  $3c00..$3fff:begin
                  if video_ram[direccion and $3ff]<>valor then begin
                    video_ram[direccion and $3ff]:=valor;
                    gfx[0].buffer[direccion and $3ff]:=true;
                  end;
                  if video_ram2[direccion and $3ff]<>charbank then begin
                    video_ram2[direccion and $3ff]:=charbank;
                    gfx[0].buffer[direccion and $3ff]:=true;
                  end;
               end;
  //Hay un mirror del video, pero con las coordenadas
  //invertidas  ?¿?¿?¿?¿?, pero lo mas flipante es que luego lo quiere
  //bien en la RAM!!!
  $7c00..$7fff:begin
                  pos:=calc_pos(direccion);
                  if video_ram[pos]<>valor then begin
                    video_ram[pos]:=valor;
                    gfx[0].buffer[pos]:=true;
                    memoria[direccion]:=valor;
                  end;
               end;
  $8001:main_screen.flip_main_screen:=(valor and 1)<>0;
  $8003:charbank:=valor;
  $9002:begin
          sound_latch:=valor;
          m6502_1.change_irq(ASSERT_LINE);
        end;
  $c000..$ffff:; //ROM
end;
end;

//Minky Monkey
function getbyte_mmonkey(direccion:word):byte;
var
  ret:byte;
begin
case direccion of
  0..$afff,$c000..$ffff:getbyte_mmonkey:=getbyte_lnc(direccion);
  $b000..$bfff:begin
    ret:=0;
    direccion:=direccion and $fff;
    case direccion of
      0:ret:=protection_status;
      $d00..$d02:ret:=memoria[$b000+direccion];
      $e00:ret:=protection_ret;
    end;
    getbyte_mmonkey:=ret;
  end;
end;
end;

procedure putbyte_mmonkey(direccion:word;valor:byte);
var
  s1,s2,r:integer;
  f:byte;
begin
case direccion of
  0..$afff:putbyte_lnc(direccion,valor);
  $b000..$bfff:begin
    direccion:=direccion and $fff;
    case direccion of
      0:begin
          if valor=0 then begin // protection trigger
            case protection_command of
              0:begin // score addition
                  s1:=(1*(memoria[$bd00] and $f))+(10*(memoria[$bd00] shr 4))+
					            (100*(memoria[$bd01] and $f))+(1000*(memoria[$bd01] shr 4))+
					            (10000*(memoria[$bd02] and $f))+(100000*(memoria[$bd02] shr 4));
				          s2:=(1*(memoria[$bd03] and $f))+(10*(memoria[$bd03] shr 4)) +
					            (100*(memoria[$bd04] and $f))+(1000*(memoria[$bd04] shr 4)) +
					            (10000*(memoria[$bd05] and $f))+(100000*(memoria[$bd05] shr 4));
				          r:=s1+s2;
				          memoria[$bd00]:=r mod 10;
                  r:=r div 10;
				          memoria[$bd00]:=memoria[$bd00] or ((r mod 10) shl 4);
                  r:=r div 10;
				          memoria[$bd01]:=r mod 10;
                  r:=r div 10;
				          memoria[$bd01]:=memoria[$bd01] or ((r mod 10) shl 4);
                  r:=r div 10;
				          memoria[$bd02]:=r mod 10;
                  r:=r div 10;
                  memoria[$bd02]:=memoria[$bd02] or ((r mod 10) shl 4);
                end;
              1:begin // decryption
				          { Compute return value by searching the decryption table.
                    During the search the status should be 2, but we're done
				            instanteniously in emulation time }
				            for f:=0 to $ff do begin
					            if (memoria[$bf00+f]=protection_value) then begin
						            protection_ret:=f;
						            break;
                      end;
                    end;
                end;
            end;
            protection_status:=0;
          end;
      end;
      $c00:protection_command:=valor;
      $d00..$d05:memoria[$b000+direccion]:=valor;   // source table
      $e00:protection_value:=valor;
      $f00..$fff:memoria[$b000+direccion]:=valor;   // decrypt table
    end;
  end;
end;
end;

//Sound
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
case direccion of
    0..$1fff:mem_snd[direccion and $3ff]:=valor;
    $2000..$3fff:ay8910_0.Write(valor);
    $4000..$5fff:ay8910_0.Control(valor);
    $6000..$7fff:ay8910_1.Write(valor);
    $8000..$9fff:ay8910_1.Control(valor);
    $c000..$dfff:haz_nmi:=(valor and 1)<>0;
    $e000..$ffff:; //ROM
end;
end;

procedure btime_porta_w(valor:byte);
begin
  haz_nmi:=(valor and 1)<>1;
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
if main_vars.tipo_maquina=31 then marcade.in2:=$3f
  else marcade.in2:=$ff;
sound_latch:=0;
haz_nmi:=false;
charbank:=1;
//Burger Time
bg_cambiado:=false;
bg_control:=0;
had_written:=false;
//Minky Monkey
protection_status:=0;
protection_ret:=0;
protection_command:=0;
protection_value:=0;
end;

function iniciar_btime:boolean;
const
    ps_x:array[0..15] of dword=(16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7,
			0, 1, 2, 3, 4, 5, 6, 7);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
var
    memoria_temp:array[0..$5fff] of byte;
procedure set_lnc_pal;
var
  color:tcolor;
  f,bit0,bit1,bit2:byte;
begin
for f:=0 to $1f do begin
  bit0:=(memoria_temp[f] shr 7) and $01;
  bit1:=(memoria_temp[f] shr 6) and $01;
  bit2:=(memoria_temp[f] shr 5) and $01;
  color.r:=$21*bit0+$47*bit1+$97*bit2;
  bit0:=(memoria_temp[f] shr 4) and $01;
  bit1:=(memoria_temp[f] shr 3) and $01;
  bit2:=(memoria_temp[f] shr 2) and $01;
  color.g:=$21*bit0+$47*bit1+$97*bit2;
  bit0:=0;
  bit1:=(memoria_temp[f] shr 1) and $01;
  bit2:=(memoria_temp[f] shr 0) and $01;
  color.b:=$21*bit0+$47*bit1+$97*bit2;
  set_pal_color(color,f);
end;
end;
begin
llamadas_maquina.bucle_general:=principal_btime;
llamadas_maquina.reset:=reset_btime;
llamadas_maquina.fps_max:=57.444855;
iniciar_btime:=false;
iniciar_audio(false);
screen_init(1,256,256); //Fondo
screen_init(2,256,256,true); //Chars
screen_init(3,256,256,false,true); //Final
iniciar_video(240,240);
//Main CPU
m6502_0:=cpu_m6502.create(1500000,272,TCPU_M6502);
//Sound CPU
m6502_1:=cpu_m6502.create(500000,272,TCPU_M6502);
m6502_1.change_ram_calls(getbyte_snd_btime,putbyte_snd_btime);
m6502_1.init_sound(btime_sound_update);
//Sound Chip
AY8910_0:=ay8910_chip.create(1500000,AY8910,1);
AY8910_0.change_io_calls(nil,nil,btime_porta_w,nil);
AY8910_1:=ay8910_chip.create(1500000,AY8910,1);
case main_vars.tipo_maquina of
  31:begin //Burguer Time
        m6502_0.change_ram_calls(getbyte_btime,putbyte_btime);
        //cargar roms
        if not(roms_load(@memoria,btime_rom)) then exit;
        //cargar roms audio
        if not(roms_load(@mem_snd,btime_snd)) then exit;
        //Cargar chars
        if not(roms_load(@memoria_temp,btime_char)) then exit;
        init_gfx(0,8,8,1024);
        gfx[0].trans[0]:=true;
        gfx_set_desc_data(3,0,8*8,2*1024*8*8,1024*8*8,0);
        convert_gfx(0,0,@memoria_temp,@ps_x[8],@ps_y,false,true);
        //sprites
        init_gfx(1,16,16,256);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(3,0,32*8,2*256*16*16,256*16*16,0);
        convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,true);
        //Cargar tiles
        if not(roms_load(@memoria_temp,btime_tiles)) then exit;
        init_gfx(2,16,16,64);
        gfx_set_desc_data(3,0,32*8,2*64*16*16,64*16*16,0);
        convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,true);
        if not(roms_load(@mem_tiles,btime_tiles_mem)) then exit;
        //DIP
        marcade.dswa:=$3f;
        marcade.dswb:=$eb;
        marcade.dswa_val:=@btime_dip_a;
        marcade.dswb_val:=@btime_dip_b;
        //Misc
        update_video:=update_video_btime;
        update_events:=eventos_btime;
  end;
  299:begin //Lock'n'Chase
        m6502_0.change_ram_calls(getbyte_lnc,putbyte_lnc);
        //cargar roms
        if not(roms_load(@memoria,lnc_rom)) then exit;
        //cargar roms audio
        if not(roms_load(@mem_snd,lnc_snd)) then exit;
        //Cargar chars
        if not(roms_load(@memoria_temp,lnc_char)) then exit;
        init_gfx(0,8,8,1024);
        gfx_set_desc_data(3,0,8*8,2*1024*8*8,1024*8*8,0);
        convert_gfx(0,0,@memoria_temp,@ps_x[8],@ps_y,false,true);
        //sprites
        init_gfx(1,16,16,256);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(3,0,32*8,2*256*16*16,256*16*16,0);
        convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,true);
        //paleta
        if not(roms_load(@memoria_temp,lnc_prom)) then exit;
        set_lnc_pal;
        //DIP
        marcade.dswa:=$3f;
        marcade.dswb:=$ff;
        marcade.dswa_val:=@lnc_dip_a;
        marcade.dswb_val:=@lnc_dip_b;
        //Misc
        update_video:=update_video_lnc;
        update_events:=eventos_lnc;
        y_comp:=1;
  end;
  300:begin //Minky Monkey
        m6502_0.change_ram_calls(getbyte_mmonkey,putbyte_mmonkey);
        //cargar roms
        if not(roms_load(@memoria,mmonkey_rom)) then exit;
        //cargar roms audio
        if not(roms_load(@mem_snd,mmonkey_snd)) then exit;
        //Cargar chars
        if not(roms_load(@memoria_temp,mmonkey_char)) then exit;
        init_gfx(0,8,8,1024);
        gfx_set_desc_data(3,0,8*8,2*1024*8*8,1024*8*8,0);
        convert_gfx(0,0,@memoria_temp,@ps_x[8],@ps_y,false,true);
        //sprites
        init_gfx(1,16,16,256);
        gfx[1].trans[0]:=true;
        gfx_set_desc_data(3,0,32*8,2*256*16*16,256*16*16,0);
        convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,true);
        //paleta
        if not(roms_load(@memoria_temp,mmonkey_prom)) then exit;
        set_lnc_pal;
        //DIP
        marcade.dswa:=$3f;
        marcade.dswb:=$e9;
        marcade.dswa_val:=@mmonkey_dip_a;
        marcade.dswb_val:=@mmonkey_dip_b;
        //Misc
        update_video:=update_video_lnc;
        update_events:=eventos_lnc;
        y_comp:=0;
  end;
end;
//final
reset_btime;
iniciar_btime:=true;
end;

end.
