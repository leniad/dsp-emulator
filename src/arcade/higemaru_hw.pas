unit higemaru_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,pal_engine,
     sound_engine;

procedure Cargar_higemaru;
procedure higemaru_principal;
function iniciar_higemaru:boolean;
procedure reset_higemaru;
//Main CPU
function higemaru_getbyte(direccion:word):byte;
procedure higemaru_putbyte(direccion:word;valor:byte);
procedure higemaru_sound;

implementation
const
        higemaru_rom:array[0..4] of tipo_roms=(
        (n:'hg4.p12';l:$2000;p:0;crc:$dc67a7f9),(n:'hg5.m12';l:$2000;p:$2000;crc:$f65a4b68),
        (n:'hg6.p11';l:$2000;p:$4000;crc:$5f5296aa),(n:'hg7.m11';l:$2000;p:$6000;crc:$dc5d455d),());
        higemaru_pal:array[0..3] of tipo_roms=(
        (n:'hgb3.l6';l:$20;p:0;crc:$629cebd8),(n:'hgb5.m4';l:$100;p:$20;crc:$dbaa4443),
        (n:'hgb1.h7';l:$100;p:$120;crc:$07c607ce),());
        higemaru_char:tipo_roms=(n:'hg3.m1';l:$2000;p:0;crc:$b37b88c8);
        higemaru_sprites:array[0..2] of tipo_roms=(
        (n:'hg1.c14';l:$2000;p:0;crc:$ef4c2f5d),(n:'hg2.e14';l:$2000;p:$2000;crc:$9133f804),());

procedure Cargar_higemaru;
begin
llamadas_maquina.iniciar:=iniciar_higemaru;
llamadas_maquina.bucle_general:=higemaru_principal;
llamadas_maquina.reset:=reset_higemaru;
end;

function iniciar_higemaru:boolean;
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$3fff] of byte;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3);
    pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
begin
iniciar_higemaru:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256);
screen_init(2,256,256,false,true);
iniciar_video(256,224);
//Main CPU
main_z80:=cpu_z80.create(3000000,256);
main_z80.change_ram_calls(higemaru_getbyte,higemaru_putbyte);
main_z80.init_sound(higemaru_sound);
//Sound Chips
AY8910_0:=ay8910_chip.create(1500000,1);
AY8910_1:=ay8910_chip.create(1500000,1);
//cargar ROMS
if not(cargar_roms(@memoria[0],@higemaru_rom[0],'higemaru.zip',0)) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@higemaru_char,'higemaru.zip',1)) then exit;
init_gfx(0,8,8,$200);
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//convertir sprites
if not(cargar_roms(@memoria_temp[0],@higemaru_sprites[0],'higemaru.zip',0)) then exit;
init_gfx(1,16,16,$80);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,64*8,$80*8*64+4,$80*8*64+0,4,0);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//poner la paleta
if not(cargar_roms(@memoria_temp[0],@higemaru_pal[0],'higemaru.zip',0)) then exit;
for f:=0 to $1f do begin
  colores[f].r:=($21*((memoria_temp[f] shr 0) and 1))+($47*((memoria_temp[f] shr 1) and 1))+($97*((memoria_temp[f] shr 2) and 1));
  colores[f].g:=($21*((memoria_temp[f] shr 3) and 1))+($47*((memoria_temp[f] shr 4) and 1))+($97*((memoria_temp[f] shr 5) and 1));
  colores[f].b:=0+($47*((memoria_temp[f] shr 6) and 1))+($97*((memoria_temp[f] shr 7) and 1));
end;
set_pal(colores,32);
//crear la tabla de colores
for f:=0 to $7f do gfx[0].colores[f]:=memoria_temp[f+$20] and $f;
for f:=0 to $ff do gfx[1].colores[f]:=(memoria_temp[f+$120] and $f) or $10;
//final
reset_higemaru;
iniciar_higemaru:=true;
end;

procedure reset_higemaru;
begin
 main_z80.reset;
 AY8910_0.reset;
 AY8910_1.reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$ff;
end;

procedure update_video_higemaru;inline;
var
  f,color,nchar,x,y:word;
  attr:byte;
begin
for f:=$3ff downto 0 do begin
  //Chars
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    attr:=memoria[f+$d400];
    color:=(attr and $1f) shl 2;
    nchar:=memoria[f+$d000]+((attr and $80) shl 1);
    put_gfx(x*8,y*8,nchar,color,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
//sprites
for f:=$17 downto 0 do begin
    attr:=memoria[$d884+(f*16)];
    nchar:=memoria[$d880+(f*16)] and $7f;
    color:=(attr and $f) shl 4;
    x:=memoria[$d88c+(f*16)];
    y:=memoria[$d888+(f*16)];
    if y<>0 then begin
      put_gfx_sprite(nchar,color,(attr and $10)<>0,(attr and $20)<>0,1);
      actualiza_gfx_sprite(x,y,2,1);
    end;
end;
actualiza_trozo_final(0,16,256,224,2);
end;

procedure eventos_higemaru;
begin
if event.arcade then begin
  //P1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  //System
  if arcade_input.but0[0] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $bf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
end;
end;

procedure higemaru_principal;
var
  f:byte;
  frame_m:single;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //main
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    //snd
    case f of
      239:begin
            main_z80.im0:=$cf;  //rst 8
            main_z80.pedir_irq:=HOLD_LINE;
            update_video_higemaru;
          end;
      255:begin
           main_z80.im0:=$d7;  //rst 10
           main_z80.pedir_irq:=HOLD_LINE;
        end;
    end;
  end;
  eventos_higemaru;
  video_sync;
end;
end;

function higemaru_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$7fff,$d000..$d7ff,$d880..$d9ff,$e000..$efff:higemaru_getbyte:=memoria[direccion];
  $c000:higemaru_getbyte:=marcade.in0;
  $c001:higemaru_getbyte:=marcade.in1;
  $c002:higemaru_getbyte:=marcade.in2;
  $c003:higemaru_getbyte:=$ff;
  $c004:higemaru_getbyte:=$fe;
end;
end;

procedure higemaru_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
memoria[direccion]:=valor;
case direccion of
   $c800:main_screen.flip_main_screen:=(valor and $80)<>0;
   $c801:ay8910_0.control(valor);
   $c802:ay8910_0.write(valor);
   $c803:ay8910_1.control(valor);
   $c804:ay8910_1.write(valor);
   $d000..$d7ff:gfx[0].buffer[direccion and $3ff]:=true;
end;
end;

procedure higemaru_sound;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

end.
