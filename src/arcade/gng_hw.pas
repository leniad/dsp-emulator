unit gng_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,nz80,ym_2203,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,timer_engine,qsnapshot;

procedure Cargar_gng;
procedure gng_principal;
procedure reset_gng;
procedure cerrar_gng;
function iniciar_gng:boolean;
//Main CPU
function gng_getbyte(direccion:word):byte;
procedure gng_putbyte(direccion:word;valor:byte);
//Sound CPU
function sound_getbyte(direccion:word):byte;
procedure sound_putbyte(direccion:word;valor:byte);
procedure gng_sound_update;
procedure gng_snd_irq;
//Save/load
procedure gng_qsave(nombre:string);
procedure gng_qload(nombre:string);

implementation
const
        gng_rom:array[0..3] of tipo_roms=(
        (n:'gg3.bin';l:$8000;p:$8000;crc:$9e01c65e),(n:'gg4.bin';l:$4000;p:$4000;crc:$66606beb),
        (n:'gg5.bin';l:$8000;p:$10000;crc:$d6397b2b),());
        gng_char:tipo_roms=(n:'gg1.bin';l:$4000;p:0;crc:$ecfccf07);
        gng_tiles:array[0..6] of tipo_roms=(
        (n:'gg11.bin';l:$4000;p:0;crc:$ddd56fa9),(n:'gg10.bin';l:$4000;p:$4000;crc:$7302529d),(n:'gg9.bin';l:$4000;p:$8000;crc:$20035bda),
        (n:'gg8.bin';l:$4000;p:$c000;crc:$f12ba271),(n:'gg7.bin';l:$4000;p:$10000;crc:$e525207d),(n:'gg6.bin';l:$4000;p:$14000;crc:$2d77e9b2),());
        gng_sprites:array[0..6] of tipo_roms=(
        (n:'gg17.bin';l:$4000;p:0;crc:$93e50a8f),(n:'gg16.bin';l:$4000;p:$4000;crc:$06d7e5ca),(n:'gg15.bin';l:$4000;p:$8000;crc:$bc1fe02d),
        (n:'gg14.bin';l:$4000;p:$c000;crc:$6aaf12f9),(n:'gg13.bin';l:$4000;p:$10000;crc:$e80c3fca),(n:'gg12.bin';l:$4000;p:$14000;crc:$7780a925),());
        gng_sound:tipo_roms=(n:'gg2.bin';l:$8000;p:0;crc:$615f5b6f);
        //Dip
        gng_dip_a:array [0..5] of def_dip=(
        (mask:$f;name:'Coinage';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$10;name:'Coinage affects';number:2;dip:((dip_val:$10;dip_name:'Coin A'),(dip_val:$0;dip_name:'Coin B'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Service Mode';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        gng_dip_b:array [0..4] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$4;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$18;dip_name:'20K 70K+'),(dip_val:$10;dip_name:'30K 80K+'),(dip_val:$8;dip_name:'20K 80K'),(dip_val:$0;dip_name:'30K 80K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$40;dip_name:'Easy'),(dip_val:$60;dip_name:'Normal'),(dip_val:$20;dip_name:'Difficult'),(dip_val:$0;dip_name:'Very Difficult'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 memoria_rom:array[0..4,0..$1FFF] of byte;
 banco,soundlatch:byte;
 scroll_x,scroll_y:word;

procedure Cargar_Gng;
begin
llamadas_maquina.iniciar:=iniciar_gng;
llamadas_maquina.bucle_general:=gng_principal;
llamadas_maquina.cerrar:=cerrar_gng;
llamadas_maquina.reset:=reset_gng;
llamadas_maquina.fps_max:=59.59;
llamadas_maquina.save_qsnap:=gng_qsave;
llamadas_maquina.load_qsnap:=gng_qload;
end;

function iniciar_gng:boolean;
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$1ffff] of byte;
const
    pc_x:array[0..7] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3 );
    pc_y:array[0..7] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 33*8+0, 33*8+1, 33*8+2, 33*8+3);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
iniciar_gng:=false;
iniciar_audio(false);
//Background
screen_init(1,512,512);
screen_mod_scroll(1,512,256,511,512,256,511);
//Foreground
screen_init(2,512,512,true);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,256,256,true); //Chars
screen_init(4,512,256,false,true); //Final
iniciar_video(256,224);
//Main CPU
main_m6809:=cpu_m6809.Create(1500000,256);
main_m6809.change_ram_calls(gng_getbyte,gng_putbyte);
//Sound CPU
snd_z80:=cpu_z80.create(3000000,256);
snd_z80.change_ram_calls(sound_getbyte,sound_putbyte);
snd_z80.init_sound(gng_sound_update);
//IRQ Sound CPU
init_timer(snd_z80.numero_cpu,3000000/(4*60),gng_snd_irq,true);
//Sound Chip
ym2203_0:=ym2203_chip.create(1500000,0.2);
ym2203_1:=ym2203_chip.create(1500000,0.2);
//cargar roms
if not(cargar_roms(@memoria_temp,@gng_rom,'gng.zip',0)) then exit;
//Pongo las ROMs en su banco
copymemory(@memoria[$8000],@memoria_temp[$8000],$8000);
for f:=0 to 3 do copymemory(@memoria_rom[f,0],@memoria_temp[$10000+(f*$2000)],$2000);
copymemory(@memoria[$6000],@memoria_temp[$6000],$2000);
copymemory(@memoria_rom[4,0],@memoria_temp[$4000],$2000);
//Cargar Sound
if not(cargar_roms(@mem_snd,@gng_sound,'gng.zip')) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp,@gng_char,'gng.zip')) then exit;
init_gfx(0,8,8,1024);
gfx[0].trans[3]:=true;
gfx[0].trans_alt[0,3]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//sprites
if not(cargar_roms(@memoria_temp,@gng_sprites,'gng.zip',0)) then exit;
init_gfx(1,16,16,1024);
gfx[1].trans[15]:=true;
gfx_set_desc_data(4,0,64*8,$c000*8+4,$c000*8+0,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//tiles
if not(cargar_roms(@memoria_temp,@gng_tiles,'gng.zip',0)) then exit;
init_gfx(2,16,16,1024);
gfx[2].trans[0]:=true;
gfx[2].trans[6]:=true;
gfx[2].trans_alt[0,0]:=true;
gfx[2].trans_alt[0,6]:=true;
gfx_set_desc_data(3,0,32*8,$10000*8,$8000*8,0);
convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
//Poner colores aleatorios hasta que inicie la paleta
for f:=0 to 255 do begin
  colores[f].r:=random(256);
  colores[f].g:=random(256);
  colores[f].b:=random(256);
end;
set_pal(colores,256);
//Dip
marcade.dswa:=$df;
marcade.dswb:=$7b;
marcade.dswa_val:=@gng_dip_a;
marcade.dswb_val:=@gng_dip_b;
//final
reset_gng;
iniciar_gng:=true;
end;

procedure cerrar_gng;
begin
main_m6809.Free;
snd_z80.free;
YM2203_0.Free;
YM2203_1.Free;
close_audio;
close_video;
end;

procedure reset_gng;
begin
 main_m6809.reset;
 snd_z80.reset;
 ym2203_0.reset;
 ym2203_1.reset;
 reset_audio;
 banco:=0;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 soundlatch:=0;
 scroll_x:=0;
 scroll_y:=0;
end;

procedure update_video_gng;
var
  x,y,f,color,nchar:word;
  atrib:byte;
  flip_x,flip_y:boolean;
begin
//background y foreground
for f:=$0 to $3ff do begin
    atrib:=memoria[$2c00+f];
    color:=atrib and $7;
    if (gfx[2].buffer[f] or buffer_color[color+$10]) then begin
      x:=(f shr 5) shl 4;
      y:=(f and $1f) shl 4;
      nchar:=memoria[$2800+f]+(atrib and $c0) shl 2;
      flip_x:=(atrib and $10)<>0;
      flip_y:=(atrib and $20)<>0;
      put_gfx_flip(x,y,nchar,color shl 3,1,2,flip_x,flip_y);
      if (atrib and 8)=0 then put_gfx_block_trans(x,y,2,16,16)
        else put_gfx_trans_flip(x,y,nchar,color shl 3,2,2,flip_x,flip_y);
      gfx[2].buffer[f]:=false;
    end;
    //chars
    atrib:=memoria[$2400+f];
    color:=atrib and $f;
    if (gfx[0].buffer[f] or buffer_color[color]) then begin
      y:=(f shr 5) shl 3;
      x:=(f and $1f) shl 3;
      nchar:=memoria[$2000+f]+((atrib and $c0) shl 2);
      put_gfx_trans(x,y,nchar,(color shl 2)+$80,3,0);
      gfx[0].buffer[f]:=false;
    end;
end;
//scroll del fondo
scroll_x_y(1,4,scroll_x,scroll_y);
//sprites
for f:=$7f downto 0 do begin
  atrib:=buffer_sprites[(f shl 2)+1];
  nchar:=buffer_sprites[f shl 2]+((atrib shl 2) and $300);
  color:=(atrib and $30)+64;
  x:=buffer_sprites[$3+(f shl 2)]+((atrib and $1) shl 8);
  y:=buffer_sprites[$2+(f shl 2)];
  put_gfx_sprite(nchar,color,(atrib and 4)<>0,(atrib and 8)<>0,1);
  actualiza_gfx_sprite_over(x,y,4,1,2,scroll_x,scroll_y);
end;
//chars
actualiza_trozo(0,0,256,256,3,0,0,256,256,4);
actualiza_trozo_final(0,16,256,224,4);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
//Actualiza buffer sprites
copymemory(@buffer_sprites[0],@memoria[$1e00],$200);
end;

procedure eventos_gng;
begin
if main_vars.service1 then marcade.dswa:=(marcade.dswa and $bf) else marcade.dswa:=(marcade.dswa or $40);
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $f7) else marcade.in2:=(marcade.in2 or $8);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  //SYS
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $bf) else marcade.in0:=(marcade.in0 or $40);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
end;
end;

procedure gng_principal;
var
  f:byte;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_m6809.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
    //Main CPU
    main_m6809.run(frame_m);
    frame_m:=frame_m+main_m6809.tframes-main_m6809.contador;
    //Sound CPU
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if f=239 then begin
        update_video_gng;
        main_m6809.pedir_irq:=HOLD_LINE;
    end;
  end;
  eventos_gng;
  video_sync;
end;
end;

procedure cambiar_color(pos:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[pos];
  color.r:=pal4bit(tmp_color shr 4);
  color.g:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[$100+pos];
  color.b:=pal4bit(tmp_color shr 4);
  set_pal_color(color,pos);
  case pos of
    0..$3f:buffer_color[(pos shr 3)+$10]:=true;
    $80..$ff:buffer_color[(pos shr 2) and $f]:=true;
  end;
end;

function gng_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$2fff,$6000..$ffff:gng_getbyte:=memoria[direccion];
  $3000:gng_getbyte:=marcade.in0;
  $3001:gng_getbyte:=marcade.in1;
  $3002:gng_getbyte:=marcade.in2;
  $3003:gng_getbyte:=marcade.dswa;
  $3004:gng_getbyte:=marcade.dswb;
  $4000..$5fff:gng_getbyte:=memoria_rom[banco,direccion and $1FFF];
end;
end;

procedure gng_putbyte(direccion:word;valor:byte);
begin
if direccion>$3fff then exit;
case direccion of
  0..$1fff:memoria[direccion]:=valor;
  $2000..$27ff:begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $2800..$2fff:begin
                  gfx[2].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $3800..$39ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                  buffer_paleta[direccion and $1ff]:=valor;
                  cambiar_color(direccion and $ff);
               end;
  $3a00:soundlatch:=valor;
  $3b08:scroll_x:=(scroll_x and $100) or valor;
  $3b09:scroll_x:=(scroll_x and $ff) or ((valor and 1) shl 8);
  $3b0a:scroll_y:=(scroll_y and $100) or valor;
  $3b0b:scroll_y:=(scroll_y and $ff) or ((valor and 1) shl 8);
  $3d00:main_screen.flip_main_screen:=(valor and 1)=0;
  $3e00:banco:=valor and 7;
end;
end;

function sound_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$c7ff:sound_getbyte:=mem_snd[direccion];
  $c800:sound_getbyte:=soundlatch
end;
end;

procedure sound_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
  $c000..$c7ff:mem_snd[direccion]:=valor;
  $e000:ym2203_0.Control(valor);
  $e001:ym2203_0.Write_Reg(valor);
  $e002:ym2203_1.Control(valor);
  $e003:ym2203_1.Write_Reg(valor);
end;
end;

procedure gng_sound_update;
begin
  ym2203_0.Update;
  ym2203_1.Update;
end;

procedure gng_snd_irq;
begin
  snd_z80.pedir_irq:=HOLD_LINE;
end;

procedure gng_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..5] of byte;
  size:word;
begin
open_qsnapshot_save('gng'+nombre);
getmem(data,20000);
//CPU
size:=main_m6809.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=snd_z80.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=ym2203_0.save_snapshot(data);
savedata_com_qsnapshot(data,size);
size:=ym2203_1.save_snapshot(data);
savedata_com_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$0],$4000);
savedata_com_qsnapshot(@mem_snd[$8000],$8000);
//MISC
buffer[0]:=banco;
buffer[1]:=soundlatch;
buffer[2]:=scroll_x and $ff;
buffer[3]:=scroll_x shr 8;
buffer[4]:=scroll_y and $ff;
buffer[5]:=scroll_y shr 8;
savedata_qsnapshot(@buffer[0],6);
savedata_com_qsnapshot(@buffer_sprites[0],$200);
savedata_com_qsnapshot(@buffer_paleta[0],$200*2);
freemem(data);
close_qsnapshot;
end;

procedure gng_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..5] of byte;
  f:byte;
begin
if not(open_qsnapshot_load('gng'+nombre)) then exit;
getmem(data,20000);
//CPU
loaddata_qsnapshot(data);
main_m6809.load_snapshot(data);
loaddata_qsnapshot(data);
snd_z80.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ym2203_0.load_snapshot(data);
loaddata_qsnapshot(data);
ym2203_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[0]);
loaddata_qsnapshot(@mem_snd[$8000]);
//MISC
loaddata_qsnapshot(@buffer[0]);
banco:=buffer[0];
soundlatch:=buffer[1];
scroll_x:=buffer[2] or (buffer[3] shl 8);
scroll_y:=buffer[4] or (buffer[5] shl 8);
loaddata_qsnapshot(@buffer_sprites[0]);
loaddata_qsnapshot(@buffer_paleta[0]);
freemem(data);
close_qsnapshot;
//END
for f:=0 to $ff do cambiar_color(f);
end;

end.
