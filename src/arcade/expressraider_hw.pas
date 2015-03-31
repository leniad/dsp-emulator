unit expressraider_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m6809,main_engine,controls_engine,ym_2203,ym_3812,gfx_engine,
     rom_engine,pal_engine,sound_engine;

procedure Cargar_expraid;
procedure principal_expraid;
function iniciar_expraid:boolean;
procedure cerrar_expraid;
procedure reset_expraid;
//Main CPU
function getbyte_expraid(direccion:word):byte;
procedure putbyte_expraid(direccion:word;valor:byte);
function get_io_expraid:byte;
//Sound CPU
function getbyte_snd_expraid(direccion:word):byte;
procedure putbyte_snd_expraid(direccion:word;valor:byte);
procedure expraid_sound_update;
procedure snd_irq(irqstate:byte);

const
        expraid_rom:array[0..2] of tipo_roms=(
        (n:'cz01';l:$4000;p:$4000;crc:$dc8f9fba),(n:'cz00';l:$8000;p:$8000;crc:$a81290bc),());
        expraid_char:tipo_roms=(n:'cz07';l:$4000;p:$0000;crc:$686bac23);
        expraid_tiles:array[0..3] of tipo_roms=(
        (n:'cz04';l:$8000;p:$0000;crc:$643a1bd3),(n:'cz05';l:$8000;p:$10000;crc:$c44570bf),
        (n:'cz06';l:$8000;p:$18000;crc:$b9bb448b),());
        expraid_snd:tipo_roms=(n:'cz02';l:$8000;p:$8000;crc:$552e6112);
        expraid_tiles_mem:tipo_roms=(n:'cz03';l:$8000;p:$0000;crc:$6ce11971);
        expraid_sprites:array[0..6] of tipo_roms=(
        (n:'cz09';l:$8000;p:$0000;crc:$1ed250d1),(n:'cz08';l:$8000;p:$8000;crc:$2293fc61),
        (n:'cz13';l:$8000;p:$10000;crc:$7c3bfd00),(n:'cz12';l:$8000;p:$18000;crc:$ea2294c8),
        (n:'cz11';l:$8000;p:$20000;crc:$b7418335),(n:'cz10';l:$8000;p:$28000;crc:$2f611978),());
        expraid_proms:array[0..4] of tipo_roms=(
        (n:'cz17.prm';l:$100;p:$000;crc:$da31dfbc),(n:'cz16.prm';l:$100;p:$100;crc:$51f25b4c),
        (n:'cz15.prm';l:$100;p:$200;crc:$a6168d7f),(n:'cz14.prm';l:$100;p:$300;crc:$52aad300),());

implementation

var
  vb:byte;
  mem_tiles:array[0..$7fff] of byte;
  scroll_x,scroll_y,scroll_x2:byte;
  bg_tiles:array[0..3] of byte;
  bg_tiles_cam:array[0..3] of boolean;
  sound_latch:byte;
  old_val,old_val2:boolean;

procedure Cargar_expraid;
begin
llamadas_maquina.iniciar:=iniciar_expraid;
llamadas_maquina.bucle_general:=principal_expraid;
llamadas_maquina.cerrar:=cerrar_expraid;
llamadas_maquina.reset:=reset_expraid;
end;

function iniciar_expraid:boolean;
const
    pc_x:array[0..7] of dword=(0+($2000*8),1+($2000*8), 2+($2000*8), 3+($2000*8), 0, 1, 2, 3);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    ps_x:array[0..15] of dword=(128+0, 128+1, 128+2, 128+3, 128+4, 128+5, 128+6, 128+7,
			0, 1, 2, 3, 4, 5, 6, 7);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 1024*32*2,1024*32*2+1,1024*32*2+2,1024*32*2+3,
		128+0,128+1,128+2,128+3,128+1024*32*2,128+1024*32*2+1,128+1024*32*2+2,128+1024*32*2+3);
    pt_y:array[0..15] of dword=(0*8,1*8,2*8,3*8,4*8,5*8,6*8,7*8,
		64+0*8,64+1*8,64+2*8,64+3*8,64+4*8,64+5*8,64+6*8,64+7*8);
var
  colores:tpaleta;
  f:word;
  i,offs:integer;
  memoria_temp:array[0..$2ffff] of byte;
begin
iniciar_expraid:=false;
iniciar_audio(false);
screen_init(1,256,256,false,true);
screen_mod_sprites(1,512,0,$1ff,0);
screen_init(2,512,512);
screen_init(3,512,512,true);
screen_init(4,512,512,true);
screen_init(6,256,256,true);
iniciar_video(240,240);
//Main CPU
main_m6502:=cpu_m6502.create(4000000,256,TCPU_DECO16);
main_m6502.change_ram_calls(getbyte_expraid,putbyte_expraid);
main_m6502.change_io_calls(nil,get_io_expraid);
//Sound CPU
snd_m6809:=cpu_m6809.Create(2000000,256);
snd_m6809.change_ram_calls(getbyte_snd_expraid,putbyte_snd_expraid);
snd_m6809.init_sound(expraid_sound_update);
//Sound Chip
ym2203_0:=ym2203_chip.create(0,1500000,2);
ym3812_init(0,3600000,snd_irq);
//cargar roms
if not(cargar_roms(@memoria[0],@expraid_rom[0],'exprraid.zip',0)) then exit;
//cargar roms audio
if not(cargar_roms(@mem_snd[0],@expraid_snd,'exprraid.zip',1)) then exit;
//Cargar chars
if not(cargar_roms(@memoria_temp[0],@expraid_char,'exprraid.zip',1)) then exit;
init_gfx(0,8,8,1024);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,8*8,0,4);
convert_gfx(@gfx[0],0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//sprites
if not(cargar_roms(@memoria_temp[0],@expraid_sprites[0],'exprraid.zip',0)) then exit;
init_gfx(1,16,16,2048);
gfx[1].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,2*2048*32*8,2048*32*8,0);
convert_gfx(@gfx[1],0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//Cargar tiles
if not(cargar_roms(@memoria_temp[0],@expraid_tiles[0],'exprraid.zip',0)) then exit;
//Mover los datos de los tiles para poder usar las rutinas de siempre...
i:=$8000-$1000;
offs:=$10000-$1000;
repeat
  copymemory(@memoria_temp[offs],@memoria_temp[i],$1000);
	offs:=offs-$1000;
  copymemory(@memoria_temp[offs],@memoria_temp[i],$1000);
  offs:=offs-$1000;
	i:=i-$1000;
until (i<0);
init_gfx(2,16,16,1024);
gfx[2].trans[0]:=true;
for f:=0 to 3 do begin
  gfx_set_desc_data(3,8,32*8,4+(f*$4000)*8,($10000+f*$4000)*8+0,($10000+f*$4000)*8+4);
  convert_gfx(@gfx[2],f*$100*16*16,@memoria_temp[0],@pt_x[0],@pt_y[0],false,false);
  gfx_set_desc_data(3,8,32*8,0+(f*$4000)*8,($11000+f*$4000)*8+0,($11000+f*$4000)*8+4);
  convert_gfx(@gfx[2],(f*$100*16*16)+($80*16*16),@memoria_temp[0],@pt_x[0],@pt_y[0],false,false);
end;
if not(cargar_roms(@mem_tiles[0],@expraid_tiles_mem,'exprraid.zip',1)) then exit;
//Paleta
if not(cargar_roms(@memoria_temp[0],@expraid_proms[0],'exprraid.zip',0)) then exit;
for f:=0 to 255 do begin
  colores[f].r:=((memoria_temp[f] and $f) shl 4) or (memoria_temp[f] and $f);
  colores[f].g:=((memoria_temp[f+$100] and $f) shl 4) or (memoria_temp[f+$100] and $f);
  colores[f].b:=((memoria_temp[f+$200] and $f) shl 4) or (memoria_temp[f+$200] and $f);
end;
set_pal(colores,256);
//final
reset_expraid;
iniciar_expraid:=true;
end;

procedure cerrar_expraid;
begin
main_m6502.free;
snd_m6809.Free;
YM2203_0.Free;
YM3812_close(0);
close_audio;
close_video;
end;

procedure reset_expraid;
begin
main_m6502.reset;
snd_m6809.reset;
YM2203_0.Reset;
YM3812_reset(0);
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
vb:=0;
sound_latch:=0;
old_val:=false;
old_val2:=false;
scroll_x:=0;
scroll_y:=0;
scroll_x2:=0;
end;

procedure update_video_expraid;inline;
var
  f,i,nchar,color,atrib:word;
  x,y,pos_ini:word;
  rest_scroll:word;
begin
//Background
for i:=0 to 3 do begin
 if bg_tiles_cam[i] then begin
  pos_ini:=bg_tiles[i]*$100;
  for f:=0 to $ff do begin
    x:=(f mod 16)*16;
    y:=(f div 16)*16;
    if i>1 then y:=y+256;
    if (i and 1)<>0 then x:=x+256;
    atrib:=mem_tiles[$4000+pos_ini+f];
    nchar:=mem_tiles[pos_ini+f]+((atrib and $03) shl 8);
    color:=atrib and $18;
    put_gfx_flip(x,y,nchar,color,2,2,(atrib and 4)<>0,false);
    if (atrib and $80)<>0 then put_gfx_trans_flip(x,y,nchar,color,4,2,(atrib and 4)<>0,false)
      else put_gfx_block_trans(x,y,4,16,16);
  end;
  bg_tiles_cam[i]:=false;
 end;
end;
//Para acelerar las cosas (creo)
rest_scroll:=256-scroll_y;
//Express Rider divide en dos la pantalla vertical, con dos scrolls
//diferentes, en total 512x256 y otra de 512x256
actualiza_trozo(scroll_x,scroll_y,256,rest_scroll,2,0,0,256,rest_scroll,1);
actualiza_trozo(scroll_x2,256,256,scroll_y,2,0,rest_scroll,256,scroll_y,1);
//Sprites
for f:=0 to $7f do begin
    x:=((248-memoria[$602+(f*4)]) and $ff)-8;
    y:=memoria[$600+(f*4)];
    nchar:=memoria[$603+(f*4)]+((memoria[$601+(f*4)] and $e0) shl 3);
    color:=((memoria[$601+(f*4)] and $03) + ((memoria[$601+(f*4)] and $08) shr 1)) shl 3;
    put_gfx_sprite(nchar,64+color,(memoria[$601+(f*4)] and 4)<>0,false,1);
    actualiza_gfx_sprite(x,y,1,1);
    if (memoria[$601+(f*4)] and $10)<>0 then begin
        put_gfx_sprite(nchar+1,64+color,(memoria[$601+(f*4)] and 4)<>0,false,1);
        actualiza_gfx_sprite(x,y+16,1,1);
    end;
end;
//Prioridad del fondo
actualiza_trozo(scroll_x,scroll_y,256,rest_scroll,4,0,0,256,rest_scroll,1);
actualiza_trozo(scroll_x2,256,256,scroll_y,4,0,rest_scroll,256,scroll_y,1);
//Foreground
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria[$800+f]+((memoria[$c00+f] and $07) shl 8);
    color:=(memoria[$c00+f] and $10) shr 2;
    put_gfx_trans(x*8,y*8,nchar,128+color,6,0);
    gfx[0].buffer[f]:=false;
 end;
end;
actualiza_trozo(0,0,256,256,6,0,0,256,256,1);
actualiza_trozo_final(8,8,240,240,1);
end;

procedure eventos_expraid;
begin
if event.arcade then begin
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if (arcade_input.coin[0] and not(old_val)) then begin
      marcade.in2:=(marcade.in2 and $bf);
      main_m6502.pedir_nmi:=PULSE_LINE;
  end else begin
      marcade.in2:=(marcade.in2 or $40);
  end;
  if (arcade_input.coin[1] and not(old_val2)) then begin
      marcade.in2:=(marcade.in2 and $7f);
      main_m6502.pedir_nmi:=PULSE_LINE;
  end else begin
      marcade.in2:=(marcade.in2 or $80);
  end;
  old_val:=arcade_input.coin[0];
  old_val2:=arcade_input.coin[1];
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
end;
end;

procedure principal_expraid;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_m6502.tframes;
frame_s:=snd_m6809.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
   main_m6502.run(frame_m);
   frame_m:=frame_m+main_m6502.tframes-main_m6502.contador;
   //Sound
   snd_m6809.run(frame_s);
   frame_s:=frame_s+snd_m6809.tframes-snd_m6809.contador;
   case f of
      239:begin
            update_video_expraid;
            vb:=$2;
          end;
      255:vb:=0;
   end;
 end;
 eventos_expraid;
 video_sync;
end;
end;

function getbyte_expraid(direccion:word):byte;
begin
case direccion of
   $1800:getbyte_expraid:=$bf;
   $1801:getbyte_expraid:=marcade.in0;
   $1802:getbyte_expraid:=marcade.in2;
   $1803:getbyte_expraid:=$ff;
   $2800:getbyte_expraid:=memoria[$02a9]; //Proteccion (parte 1)
   $2801:getbyte_expraid:=$2; //Proteccion (parte 2)
    else getbyte_expraid:=memoria[direccion];
end;
end;

procedure putbyte_expraid(direccion:word;valor:byte);
begin
if direccion>$3fff then exit;
memoria[direccion]:=valor;
case direccion of
  $800..$fff:gfx[0].buffer[direccion and $3ff]:=true;
  $2001:begin
           sound_latch:=valor;
           snd_m6809.pedir_nmi:=PULSE_LINE;
        end;
  $2800..$2803:if bg_tiles[direccion and $3]<>(valor and $3f) then begin
                bg_tiles[direccion and $3]:=valor and $3f;
                bg_tiles_cam[direccion and $3]:=true;
               end;
  $2804:scroll_y:=valor;
  $2805:scroll_x:=valor;
  $2806:scroll_x2:=valor;
end;
end;

function get_io_expraid:byte;
begin
  get_io_expraid:=vb;
end;

function getbyte_snd_expraid(direccion:word):byte;
begin
  case direccion of
    $2000:getbyte_snd_expraid:=ym2203_0.read_status;
    $2001:getbyte_snd_expraid:=ym2203_0.Read_Reg;
    $4000:getbyte_snd_expraid:=ym3812_status_port(0);
    $6000:getbyte_snd_expraid:=sound_latch;
      else getbyte_snd_expraid:=mem_snd[direccion];
  end;
end;

procedure putbyte_snd_expraid(direccion:word;valor:byte);
begin
if direccion>$7fff then exit;
mem_snd[direccion]:=valor;
case direccion of
  $2000:ym2203_0.control(valor);
  $2001:ym2203_0.write_reg(valor);
  $4000:ym3812_control_port(0,valor);
  $4001:ym3812_write_port(0,valor);
end;
end;

procedure expraid_sound_update;
begin
  ym2203_0.Update;
  ym3812_Update(0);
end;

procedure snd_irq(irqstate:byte);
begin
  if (irqstate<>0) then snd_m6809.pedir_irq:=ASSERT_LINE
    else snd_m6809.pedir_irq:=CLEAR_LINE;
end;

end.
