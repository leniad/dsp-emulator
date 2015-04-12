unit mikie_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,main_engine,controls_engine,sn_76496,gfx_engine,rom_engine,
     pal_engine,sound_engine,qsnapshot;

procedure Cargar_mikie;
procedure mikie_principal;
function iniciar_mikie:boolean;
procedure reset_mikie;
procedure cerrar_mikie;
//Main CPU
function mikie_getbyte(direccion:word):byte;
procedure mikie_putbyte(direccion:word;valor:byte);
//Sound CPU
function sound_getbyte(direccion:word):byte;
procedure sound_putbyte(direccion:word;valor:byte);
procedure sound_despues_instruccion;
//Save/load
procedure mikie_qsave(nombre:string);
procedure mikie_qload(nombre:string);

const
        mikie_rom:array[0..3] of tipo_roms=(
        (n:'n14.11c';l:$2000;p:$6000;crc:$f698e6dd),(n:'o13.12a';l:$4000;p:$8000;crc:$826e7035),
        (n:'o17.12d';l:$4000;p:$c000;crc:$161c25c8),());
        mikie_sound:tipo_roms=(n:'n10.6e';l:$2000;p:0;crc:$2cf9d670);
        mikie_char:tipo_roms=(n:'o11.8i';l:$4000;p:0;crc:$3c82aaf3);
        mikie_sprites:array[0..4] of tipo_roms=(
        (n:'001.f1';l:$4000;p:0;crc:$a2ba0df5),(n:'003.f3';l:$4000;p:$4000;crc:$9775ab32),
        (n:'005.h1';l:$4000;p:$8000;crc:$ba44aeef),(n:'007.h3';l:$4000;p:$c000;crc:$31afc153),());
        mikie_pal:array[0..5] of tipo_roms=(
        (n:'d19.1i';l:$100;p:$0;crc:$8b83e7cf),(n:'d21.3i';l:$100;p:$100;crc:$3556304a),
        (n:'d20.2i';l:$100;p:$200;crc:$676a0669),(n:'d22.12h';l:$100;p:$300;crc:$872be05c),
        (n:'d18.f9';l:$100;p:$400;crc:$7396b374),());

var
 banco_pal,video_line:byte;
 pedir_irq:boolean;
 sound_latch,sound_trq:byte;

implementation

procedure Cargar_mikie;
begin
llamadas_maquina.iniciar:=iniciar_mikie;
llamadas_maquina.bucle_general:=mikie_principal;
llamadas_maquina.cerrar:=cerrar_mikie;
llamadas_maquina.reset:=reset_mikie;
llamadas_maquina.save_qsnap:=mikie_qsave;
llamadas_maquina.load_qsnap:=mikie_qload;
end;

function iniciar_mikie:boolean;
var
  colores:tpaleta;
  f,bit0,bit1,bit2,bit3:byte;
  memoria_temp:array[0..$ffff] of byte;
  rweights,gweights,bweights:array[0..3] of single;
const
  ps_x:array[0..15] of dword=(32*8+0, 32*8+1, 32*8+2, 32*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
		0, 1, 2, 3, 48*8+0, 48*8+1, 48*8+2, 48*8+3);
  ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
		32*16, 33*16, 34*16, 35*16, 36*16, 37*16, 38*16, 39*16);
  pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
  pc_y:array[0..7] of dword=(0*4*8, 1*4*8, 2*4*8, 3*4*8, 4*4*8, 5*4*8, 6*4*8, 7*4*8);
  resistances:array[0..3] of integer=(2200,1000,470,220);
begin
iniciar_mikie:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(224,256);
//Main CPU
main_m6809:=cpu_m6809.Create(1536000,256);
main_m6809.change_ram_calls(mikie_getbyte,mikie_putbyte);
//Sound CPU
snd_z80:=cpu_z80.create(3579545,256);
snd_z80.change_ram_calls(sound_getbyte,sound_putbyte);
snd_z80.init_sound(sound_despues_instruccion);
//Sound Chip
sn_76496_0:=sn76496_chip.Create(1789772);
sn_76496_1:=sn76496_chip.Create(3579545);
//cargar roms
if not(cargar_roms(@memoria[0],@mikie_rom[0],'mikie.zip',0)) then exit;
//cargar rom sonido
if not(cargar_roms(@mem_snd[0],@mikie_sound,'mikie.zip',1)) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@mikie_char,'mikie.zip',1)) then exit;
init_gfx(0,8,8,512);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//sprites
if not(cargar_roms(@memoria_temp[0],@mikie_sprites[0],'mikie.zip',0)) then exit;
init_gfx(1,16,16,512);
gfx[1].trans[0]:=true;
for f:=0 to 1 do begin
  gfx_set_desc_data(4,2,128*8,0+f*8,4+f*8,f*8+$8000*8+0,f*8+$8000*8+4);
  convert_gfx(1,$100*f*16*16,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
end;
//paleta
if not(cargar_roms(@memoria_temp[0],@mikie_pal[0],'mikie.zip',0)) then exit;
compute_resistor_weights(0,	255, -1.0,
			4,@resistances[0],@rweights[0],470,0,
			4,@resistances[0],@gweights[0],470,0,
			4,@resistances[0],@bweights[0],470,0);
for f:=0 to $ff do begin
		// red component */
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
    bit2:=(memoria_temp[f] shr 2) and $01;
    bit3:=(memoria_temp[f] shr 3) and $01;
		colores[f].r:=combine_4_weights(@rweights[0],bit0,bit1,bit2,bit3);
		// green component */
		bit0:=(memoria_temp[f+$100] shr 0) and $01;
		bit1:=(memoria_temp[f+$100] shr 1) and $01;
    bit2:=(memoria_temp[f+$100] shr 2) and $01;
    bit3:=(memoria_temp[f+$100] shr 3) and $01;
		colores[f].g:=combine_4_weights(@gweights[0],bit0,bit1,bit2,bit3);
		// blue component */
		bit0:=(memoria_temp[f+$200] shr 0) and $01;
		bit1:=(memoria_temp[f+$200] shr 1) and $01;
    bit2:=(memoria_temp[f+$200] shr 2) and $01;
    bit3:=(memoria_temp[f+$200] shr 3) and $01;
		colores[f].b:=combine_4_weights(@bweights[0],bit0,bit1,bit2,bit3);
end;
set_pal(colores,256);
//tabla_colores char & sprites
for bit1:=0 to $ff do begin
	for bit2:=0 to 7 do begin
		gfx[0].colores[bit1+(bit2 shl 8)]:=(memoria_temp[bit1+$300] and $f)+(bit2 shl 5)+16;
    gfx[1].colores[bit1+(bit2 shl 8)]:=(memoria_temp[bit1+$400] and $f)+(bit2 shl 5);
  end;
end;
//final
reset_mikie;
iniciar_mikie:=true;
end;

procedure cerrar_mikie;
begin
main_m6809.Free;
snd_z80.free;
sn_76496_0.Free;
sn_76496_1.Free;
close_audio;
close_video;
end;

procedure reset_mikie;
begin
 main_m6809.reset;
 snd_z80.reset;
 sn_76496_0.reset;
 sn_76496_1.reset;
 reset_audio;
 banco_pal:=0;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 pedir_irq:=false;
 sound_trq:=0;
end;

procedure update_video_mikie;inline;
var
  x,y,atrib:byte;
  f,color,nchar:word;
  flip_x,flip_y:boolean;
begin
for f:=$3ff downto 0 do begin
    if gfx[0].buffer[f] then begin
      y:=31-(f mod 32);
      x:=f div 32;
      atrib:=memoria[$3800+f];
      color:=((atrib and $f)+($10*banco_pal)) shl 4;
      nchar:=memoria[$3c00+f]+((atrib and $20) shl 3);
      flip_x:=(atrib and $80)=0;
      flip_y:=(atrib and $40)=0;
      put_gfx_flip(x*8,y*8,nchar,color,1,0,flip_x,flip_y);
      if (atrib and $10)<>0 then put_gfx_mask_flip(x*8,y*8,nchar,color,2,0,0,$ff,flip_x,flip_y)
        else put_gfx_block_trans(x*8,y*8,2,8,8);
      gfx[0].buffer[f]:=false;
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
for f:=0 to $23 do begin
  atrib:=memoria[$2800+(f*4)];
  nchar:=((atrib and $40) shl 1)+(memoria[$2802+(f*4)] and $3f)+((memoria[$2802+(f*4)] and $80) shr 1)+(memoria[$2802+(f*4)] and $40) shl 2;
  color:=((atrib and $f)+($10*banco_pal)) shl 4;
  x:=244-memoria[$2801+(f*4)];
  y:=240-memoria[$2803+(f*4)];
  flip_x:=(atrib and $20)=0;
  flip_y:=(atrib and $10)<>0;
  put_gfx_sprite(nchar,color,flip_x,flip_y,1);
  actualiza_gfx_sprite_over(x,y,3,1,2,0,0);
end;
actualiza_trozo_final(16,0,224,256,3);
end;

procedure eventos_mikie;
begin
if event.arcade then begin
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
end;
end;

procedure mikie_principal;
var
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_m6809.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for video_line:=0 to $ff do begin
    //Main CPU
    main_m6809.run(frame_m);
    frame_m:=frame_m+main_m6809.tframes-main_m6809.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if video_line=239 then begin
      main_m6809.pedir_irq:=HOLD_LINE;
      update_video_mikie;
    end;
  end;
  eventos_mikie;
  video_sync;
end;
end;

function mikie_getbyte(direccion:word):byte;
begin
case direccion of
  0..$ff,$2800..$ffff:mikie_getbyte:=memoria[direccion];
  $2400:mikie_getbyte:=marcade.in0;
  $2401:mikie_getbyte:=marcade.in1;
  $2402:mikie_getbyte:=marcade.in2;
  $2403:mikie_getbyte:=$2;
  $2500:mikie_getbyte:=$ff;
  $2501:mikie_getbyte:=$7b;
end;
end;

procedure mikie_putbyte(direccion:word;valor:byte);
begin
if direccion>$3fff then exit;
memoria[direccion]:=valor;
case direccion of
  $2002:begin
          if ((sound_trq=0) and (valor=1)) then snd_z80.pedir_irq:=HOLD_LINE;
          sound_trq:=valor;
        end;
  $2006:main_screen.flip_main_screen:=(valor and 1)<>0;
  $2007:pedir_irq:=(valor<>0);
  $2200:banco_pal:=valor and $7;
  $2400:sound_latch:=valor;
  $3800..$3fff:gfx[0].buffer[direccion and $3ff]:=true;
end;
end;

function sound_getbyte(direccion:word):byte;
begin
case direccion of
  0..$43ff:sound_getbyte:=mem_snd[direccion];
  $8003:sound_getbyte:=sound_latch;
  $8005:sound_getbyte:=(trunc(video_line*snd_z80.tframes)+snd_z80.contador) shr 9;
end;
end;

procedure sound_putbyte(direccion:word;valor:byte);
begin
if direccion<$2000 then exit;
mem_snd[direccion]:=valor;
case direccion of
  $8002:sn_76496_0.Write(valor);
  $8004:sn_76496_1.Write(valor);
end;
end;

procedure sound_despues_instruccion;
begin
  sn_76496_0.update;
  sn_76496_1.update;
end;

procedure mikie_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
  size:word;
begin
open_qsnapshot_save('mikie'+nombre);
getmem(data,180);
//CPU
size:=main_m6809.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=snd_z80.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=sn_76496_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=sn_76496_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$0],$4000);
savedata_com_qsnapshot(@mem_snd[$2000],$e000);
//MISC
buffer[0]:=banco_pal;
buffer[1]:=video_line;
buffer[2]:=byte(pedir_irq);
buffer[3]:=sound_latch;
buffer[4]:=sound_trq;
savedata_qsnapshot(@buffer[0],5);
freemem(data);
close_qsnapshot;
end;

procedure mikie_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..4] of byte;
begin
if not(open_qsnapshot_load('mikie'+nombre)) then exit;
getmem(data,180);
//CPU
loaddata_qsnapshot(data);
main_m6809.load_snapshot(data);
loaddata_qsnapshot(data);
snd_z80.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
sn_76496_0.load_snapshot(data);
loaddata_qsnapshot(data);
sn_76496_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[0]);
loaddata_qsnapshot(@mem_snd[$2000]);
//MISC
loaddata_qsnapshot(@buffer[0]);
banco_pal:=buffer[0];
video_line:=buffer[1];
pedir_irq:=buffer[2]<>0;
sound_latch:=buffer[3];
sound_trq:=buffer[4];
freemem(data);
close_qsnapshot;
//END
fillchar(gfx[0].buffer[0],$400,1);
end;

end.
