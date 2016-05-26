unit sonson_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,ay_8910,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,timer_engine,qsnapshot;

procedure Cargar_sonson;
procedure sonson_principal;
function iniciar_sonson:boolean;
procedure reset_sonson;
//Main CPU
function sonson_getbyte(direccion:word):byte;
procedure sonson_putbyte(direccion:word;valor:byte);
//Sound CPU
function ssonson_getbyte(direccion:word):byte;
procedure ssonson_putbyte(direccion:word;valor:byte);
procedure sonson_sound_update;
procedure sonson_snd_irq;
//Save/load
procedure sonson_qsave(nombre:string);
procedure sonson_qload(nombre:string);

implementation
const
        sonson_rom:array[0..3] of tipo_roms=(
        (n:'ss.01e';l:$4000;p:$4000;crc:$cd40cc54),(n:'ss.02e';l:$4000;p:$8000;crc:$c3476527),
        (n:'ss.03e';l:$4000;p:$c000;crc:$1fd0e729),());
        sonson_sonido:tipo_roms=(n:'ss_6.c11';l:$2000;p:$e000;crc:$1135c48a);
        sonson_char:array[0..2] of tipo_roms=(
        (n:'ss_7.b6';l:$2000;p:0;crc:$990890b1),(n:'ss_8.b5';l:$2000;p:$2000;crc:$9388ff82),());
        sonson_sprites:array[0..6] of tipo_roms=(
        (n:'ss_9.m5';l:$2000;p:0;crc:$8cb1cacf),(n:'ss_10.m6';l:$2000;p:$2000;crc:$f802815e),
        (n:'ss_11.m3';l:$2000;p:$4000;crc:$4dbad88a),(n:'ss_12.m4';l:$2000;p:$6000;crc:$aa05e687),
        (n:'ss_13.m1';l:$2000;p:$8000;crc:$66119bfa),(n:'ss_14.m2';l:$2000;p:$a000;crc:$e14ef54e),());
        sonson_prom:array[0..4] of tipo_roms=(
        (n:'ssb4.b2';l:$20;p:0;crc:$c8eaf234),(n:'ssb5.b1';l:$20;p:$20;crc:$0e434add),
        (n:'ssb2.c4';l:$100;p:$40;crc:$c53321c6),(n:'ssb3.h7';l:$100;p:$140;crc:$7d2c324a),());
        //Dip
        sonson_dip_a:array [0..5] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$2;dip_name:'4C 1C'),(dip_val:$5;dip_name:'3C 1C'),(dip_val:$8;dip_name:'2C 1C'),(dip_val:$4;dip_name:'3C 2C'),(dip_val:$1;dip_name:'4C 3C'),(dip_val:$f;dip_name:'1C 1C'),(dip_val:$3;dip_name:'3C 4C'),(dip_val:$7;dip_name:'2C 3C'),(dip_val:$e;dip_name:'1C 2C'),(dip_val:$6;dip_name:'2C 5C'),(dip_val:$d;dip_name:'1C 3C'),(dip_val:$c;dip_name:'1C 4C'),(dip_val:$b;dip_name:'1C 5C'),(dip_val:$a;dip_name:'1C 6C'),(dip_val:$9;dip_name:'1C 7C'),(dip_val:$0;dip_name:'Free Play'))),
        (mask:$10;name:'Coinage affects';number:2;dip:((dip_val:$10;dip_name:'Coin A'),(dip_val:$0;dip_name:'Coin B'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Demo Sounds';number:2;dip:((dip_val:$20;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Service';number:2;dip:((dip_val:$40;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Flip Screen';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        sonson_dip_b:array [0..5] of def_dip=(
        (mask:$3;name:'Lives';number:4;dip:((dip_val:$3;dip_name:'3'),(dip_val:$2;dip_name:'4'),(dip_val:$1;dip_name:'5'),(dip_val:$0;dip_name:'7'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$4;name:'2 Players Game';number:2;dip:((dip_val:$4;dip_name:'1 Credit'),(dip_val:$0;dip_name:'2 Credit'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$18;name:'Bonus Life';number:4;dip:((dip_val:$8;dip_name:'20K 80K 100K'),(dip_val:$0;dip_name:'30K 90K 120K'),(dip_val:$18;dip_name:'20K'),(dip_val:$10;dip_name:'30K'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$60;name:'Difficulty';number:4;dip:((dip_val:$60;dip_name:'Easy'),(dip_val:$40;dip_name:'Normal'),(dip_val:$20;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Freeze';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 soundlatch,last,scroll_x:byte;

procedure Cargar_sonson;
begin
llamadas_maquina.iniciar:=iniciar_sonson;
llamadas_maquina.bucle_general:=sonson_principal;
llamadas_maquina.reset:=reset_sonson;
llamadas_maquina.save_qsnap:=sonson_qsave;
llamadas_maquina.load_qsnap:=sonson_qload;
end;

function iniciar_sonson:boolean;
var
      colores:tpaleta;
      f:word;
      memoria_temp:array[0..$bfff] of byte;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  ps_x:array[0..15] of dword=(8*16+7, 8*16+6, 8*16+5, 8*16+4, 8*16+3, 8*16+2, 8*16+1, 8*16+0,
			7, 6, 5, 4, 3, 2, 1, 0);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
iniciar_sonson:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256,false,true);
screen_init(2,256,256);
screen_mod_scroll(2,256,256,255,0,0,0);
iniciar_video(240,240);
//Main CPU
main_m6809:=cpu_m6809.Create(2000000,256);
main_m6809.change_ram_calls(sonson_getbyte,sonson_putbyte);
//Sound CPU
snd_m6809:=cpu_m6809.Create(2000000,256);
snd_m6809.change_ram_calls(ssonson_getbyte,ssonson_putbyte);
snd_m6809.init_sound(sonson_sound_update);
//IRQ Sound CPU
init_timer(1,2000000/(4*60),sonson_snd_irq,true);
//Sound Chip
AY8910_0:=ay8910_chip.create(1500000,1);
AY8910_1:=ay8910_chip.create(1500000,1);
//cargar roms
if not(cargar_roms(@memoria[0],@sonson_rom[0],'sonson.zip',0)) then exit;
//Cargar Sound
if not(cargar_roms(@mem_snd[0],@sonson_sonido,'sonson.zip')) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@sonson_char[0],'sonson.zip',0)) then exit;
init_gfx(0,8,8,1024);
gfx_set_desc_data(2,0,8*8,$2000*8,0*8);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,false);
//sprites
if not(cargar_roms(@memoria_temp[0],@sonson_sprites[0],'sonson.zip',0)) then exit;
init_gfx(1,16,16,512);
gfx[1].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,$8000*8,$4000*8,0*8);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,false);
//colores
if not(cargar_roms(@memoria_temp[0],@sonson_prom[0],'sonson.zip',0)) then exit;
for f:=0 to 31 do begin
  colores[f].r:=((memoria_temp[f+$20] and $f) shl 4) or (memoria_temp[f+$20] and $f);
  colores[f].g:=((memoria_temp[f] and $f0) shr 4) or (memoria_temp[f] and $f0);
  colores[f].b:=((memoria_temp[f] and $f) shl 4) or (memoria_temp[f] and $f);
end;
set_pal(colores,32);
for f:=0 to 255 do begin
  gfx[0].colores[f]:=memoria_temp[$40+f];
  gfx[1].colores[f]:=memoria_temp[$140+f]+16;
end;
//DIP
marcade.dswa:=$df;
marcade.dswb:=$cb;
marcade.dswa_val:=@sonson_dip_a;
marcade.dswb_val:=@sonson_dip_b;
//final
reset_sonson;
iniciar_sonson:=true;
end;

procedure reset_sonson;
begin
 main_m6809.reset;
 snd_m6809.reset;
 AY8910_0.reset;
 AY8910_1.reset;
 reset_audio;
 soundlatch:=0;
 last:=0;
 scroll_x:=0;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
end;

procedure update_video_sonson;inline;
var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
//chars
for f:=$0 to $3ff do begin
 if gfx[0].buffer[f] then begin
    y:=f div 32;
    x:=f mod 32;
    atrib:=memoria[$1400+f];
    color:=atrib and $fc;
    nchar:=memoria[$1000+f]+((atrib and $3) shl 8);
    put_gfx(x*8,y*8,nchar,color,2,0);
    gfx[0].buffer[f]:=false;
 end;
end;
scroll__x(2,1,scroll_x);
actualiza_trozo(0,0,256,40,2,0,0,256,40,1);
//sprites
for f:=$17 downto 0 do begin
  atrib:=memoria[$2021+(f*4)];
  nchar:=memoria[$2022+(f*4)]+((atrib and $20) shl 3);
  color:=(atrib and $1f) shl 3;
  x:=memoria[$2023+(f*4)];
  y:=memoria[$2020+(f*4)];
  put_gfx_sprite(nchar,color,(atrib and $40)=0,(atrib and $80)=0,1);
  actualiza_gfx_sprite(x,y,1,1);
end;
actualiza_trozo_final(8,8,240,240,1);
end;

procedure eventos_sonson;
begin
if event.arcade then begin
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or $8);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
end;
end;

procedure sonson_principal;
var
  f:byte;
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_m6809.tframes;
frame_s:=snd_m6809.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 255 do begin
    //Main CPU
    main_m6809.run(frame_m);
    frame_m:=frame_m+main_m6809.tframes-main_m6809.contador;
    //Snd CPU
    snd_m6809.run(frame_s);
    frame_s:=frame_s+snd_m6809.tframes-snd_m6809.contador;
    if f=247 then begin
      main_m6809.change_irq(HOLD_LINE);
      update_video_sonson;
    end;
  end;
  eventos_sonson;
  video_sync;
end;
end;

function sonson_getbyte(direccion:word):byte;
begin
    case direccion of
        0..$17ff,$2020..$207f,$4000..$ffff:sonson_getbyte:=memoria[direccion];
        $3002:sonson_getbyte:=marcade.in0;
        $3003:sonson_getbyte:=marcade.in1;
        $3004:sonson_getbyte:=marcade.in2;
        $3005:sonson_getbyte:=marcade.dswa;
        $3006:sonson_getbyte:=marcade.dswb;
    end;
end;

procedure sonson_putbyte(direccion:word;valor:byte);
begin
if direccion>$3fff then exit;
case direccion of
  $0..$fff,$2020..$207f:memoria[direccion]:=valor;
  $1000..$17ff:begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $3000:scroll_x:=valor;
  $3010:soundlatch:=valor;
  $3018:main_screen.flip_main_screen:=(valor and 1)<>1;
  $3019:begin
          if ((last=0) and ((valor and 1)=1)) then snd_m6809.change_firq(HOLD_LINE);
          last:=valor and 1;
        end;
end;
end;

function ssonson_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7ff,$e000..$ffff:ssonson_getbyte:=mem_snd[direccion];
  $a000:ssonson_getbyte:=soundlatch
end;
end;

procedure ssonson_putbyte(direccion:word;valor:byte);
begin
if direccion>$dfff then exit;
case direccion of
  0..$7ff:mem_snd[direccion]:=valor;
  $2000:ay8910_0.Control(valor);
  $2001:ay8910_0.Write(valor);
  $4000:ay8910_1.Control(valor);
  $4001:ay8910_1.Write(valor);
end;
end;

procedure sonson_snd_irq;
begin
  snd_m6809.change_irq(HOLD_LINE);
end;

procedure sonson_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

procedure sonson_qsave(nombre:string);
var
  data:pbyte;
  buffer:array[0..2] of byte;
  size:word;
begin
open_qsnapshot_save('sonson'+nombre);
getmem(data,250);
//CPU
size:=main_m6809.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=snd_m6809.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=AY8910_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=AY8910_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_com_qsnapshot(@memoria[$0],$4000);
savedata_com_qsnapshot(@mem_snd[$0],$e000);
//MISC
buffer[0]:=soundlatch;
buffer[1]:=last;
buffer[2]:=scroll_x;
savedata_qsnapshot(@buffer[0],3);
freemem(data);
close_qsnapshot;
end;

procedure sonson_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..2] of byte;
begin
if not(open_qsnapshot_load('sonson'+nombre)) then exit;
getmem(data,250);
//CPU
loaddata_qsnapshot(data);
main_m6809.load_snapshot(data);
loaddata_qsnapshot(data);
snd_m6809.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
AY8910_0.load_snapshot(data);
loaddata_qsnapshot(data);
AY8910_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[0]);
loaddata_qsnapshot(@mem_snd[$0]);
//MISC
loaddata_qsnapshot(@buffer[0]);
soundlatch:=buffer[0];
last:=buffer[1];
scroll_x:=buffer[2];
freemem(data);
close_qsnapshot;
//END
fillchar(gfx[0].buffer[0],$400,1);
end;

end.
