unit sonson_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,ay_8910,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,timer_engine,qsnapshot;

function iniciar_sonson:boolean;

implementation
const
        sonson_rom:array[0..2] of tipo_roms=(
        (n:'ss.01e';l:$4000;p:$4000;crc:$cd40cc54),(n:'ss.02e';l:$4000;p:$8000;crc:$c3476527),
        (n:'ss.03e';l:$4000;p:$c000;crc:$1fd0e729));
        sonson_sonido:tipo_roms=(n:'ss_6.c11';l:$2000;p:$e000;crc:$1135c48a);
        sonson_char:array[0..1] of tipo_roms=(
        (n:'ss_7.b6';l:$2000;p:0;crc:$990890b1),(n:'ss_8.b5';l:$2000;p:$2000;crc:$9388ff82));
        sonson_sprites:array[0..5] of tipo_roms=(
        (n:'ss_9.m5';l:$2000;p:0;crc:$8cb1cacf),(n:'ss_10.m6';l:$2000;p:$2000;crc:$f802815e),
        (n:'ss_11.m3';l:$2000;p:$4000;crc:$4dbad88a),(n:'ss_12.m4';l:$2000;p:$6000;crc:$aa05e687),
        (n:'ss_13.m1';l:$2000;p:$8000;crc:$66119bfa),(n:'ss_14.m2';l:$2000;p:$a000;crc:$e14ef54e));
        sonson_prom:array[0..3] of tipo_roms=(
        (n:'ssb4.b2';l:$20;p:0;crc:$c8eaf234),(n:'ssb5.b1';l:$20;p:$20;crc:$0e434add),
        (n:'ssb2.c4';l:$100;p:$40;crc:$c53321c6),(n:'ssb3.h7';l:$100;p:$140;crc:$7d2c324a));
        //Dip
        sonson_dip_a:array [0..5] of def_dip2=(
        (mask:$f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),
        (mask:$10;name:'Coinage affects';number:2;val2:($10,0);name2:('Coin A','Coin B')),
        (mask:$20;name:'Demo Sounds';number:2;val2:($20,0);name2:('Off','On')),
        (mask:$40;name:'Service';number:2;val2:($40,0);name2:('Off','On')),
        (mask:$80;name:'Flip Screen';number:2;val2:($80,0);name2:('Off','On')),());
        sonson_dip_b:array [0..5] of def_dip2=(
        (mask:3;name:'Lives';number:4;val4:(3,2,1,0);name4:('3','4','5','7')),
        (mask:4;name:'2 Players Game';number:2;val2:(4,0);name2:('1 Credit','2 Credit')),
        (mask:$18;name:'Bonus Life';number:4;val4:(8,0,$18,$10);name4:('20K 80K 100K','30K 90K 120K','20K','30K')),
        (mask:$60;name:'Difficulty';number:4;val4:($60,$40,$20,0);name4:('Easy','Normal','Hard','Very Hard')),
        (mask:$80;name:'Freeze';number:2;val2:($80,0);name2:('Off','On')),());

var
 soundlatch,last,scroll_x:byte;

procedure update_video_sonson;
var
  f,color,nchar:word;
  x,y,atrib:byte;
begin
//chars
for f:=0 to $3ff do begin
 if gfx[0].buffer[f] then begin
    y:=f div 32;
    x:=f mod 32;
    atrib:=memoria[$1400+f];
    color:=atrib and $fc;
    nchar:=memoria[$1000+f]+((atrib and 3) shl 8);
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
  //P1
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  //P2
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or 1);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or 4);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 and $f7) else marcade.in1:=(marcade.in1 or 8);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //Sys
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or 1);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or 2);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 and $ef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
end;
end;

procedure sonson_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 255 do begin
    if f=248 then begin
      m6809_0.change_irq(HOLD_LINE);
      update_video_sonson;
    end;
    //Main CPU
    m6809_0.run(frame_main);
    frame_main:=frame_main+m6809_0.tframes-m6809_0.contador;
    //Snd CPU
    m6809_1.run(frame_snd);
    frame_snd:=frame_snd+m6809_1.tframes-m6809_1.contador;
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
case direccion of
  0..$fff,$2020..$207f:memoria[direccion]:=valor;
  $1000..$17ff:if memoria[direccion]<>valor then begin
                  gfx[0].buffer[direccion and $3ff]:=true;
                  memoria[direccion]:=valor;
               end;
  $3000:scroll_x:=valor;
  $3010:soundlatch:=valor;
  $3018:main_screen.flip_main_screen:=(valor and 1)<>1;
  $3019:begin
          if ((last=0) and ((valor and 1)=1)) then m6809_1.change_firq(HOLD_LINE);
          last:=valor and 1;
        end;
  $4000..$ffff:; //ROM
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
case direccion of
  0..$7ff:mem_snd[direccion]:=valor;
  $2000:ay8910_0.control(valor);
  $2001:ay8910_0.write(valor);
  $4000:ay8910_1.control(valor);
  $4001:ay8910_1.write(valor);
  $e000..$ffff:; //ROM
end;
end;

procedure sonson_snd_irq;
begin
  m6809_1.change_irq(HOLD_LINE);
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
size:=m6809_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=m6809_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=AY8910_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=AY8910_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_qsnapshot(@memoria,$4000);
savedata_qsnapshot(@mem_snd,$e000);
//MISC
buffer[0]:=soundlatch;
buffer[1]:=last;
buffer[2]:=scroll_x;
savedata_qsnapshot(@buffer,3);
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
m6809_0.load_snapshot(data);
loaddata_qsnapshot(data);
m6809_1.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
AY8910_0.load_snapshot(data);
loaddata_qsnapshot(data);
AY8910_1.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria);
loaddata_qsnapshot(@mem_snd);
//MISC
loaddata_qsnapshot(@buffer);
soundlatch:=buffer[0];
last:=buffer[1];
scroll_x:=buffer[2];
freemem(data);
close_qsnapshot;
//END
fillchar(gfx[0].buffer,$400,1);
end;

//Main
procedure reset_sonson;
begin
 m6809_0.reset;
 m6809_1.reset;
 frame_main:=m6809_0.tframes;
 frame_snd:=m6809_1.tframes;
 ay8910_0.reset;
 ay8910_1.reset;
 reset_audio;
 soundlatch:=0;
 last:=0;
 scroll_x:=0;
 marcade.in0:=$ff;
 marcade.in1:=$ff;
 marcade.in2:=$ff;
end;

function iniciar_sonson:boolean;
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$bfff] of byte;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  ps_x:array[0..15] of dword=(8*16+7, 8*16+6, 8*16+5, 8*16+4, 8*16+3, 8*16+2, 8*16+1, 8*16+0,
			7, 6, 5, 4, 3, 2, 1, 0);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
begin
llamadas_maquina.bucle_general:=sonson_principal;
llamadas_maquina.reset:=reset_sonson;
llamadas_maquina.save_qsnap:=sonson_qsave;
llamadas_maquina.load_qsnap:=sonson_qload;
iniciar_sonson:=false;
iniciar_audio(false);
screen_init(1,256,256,false,true);
screen_init(2,256,256);
screen_mod_scroll(2,256,256,255,256,256,255);
iniciar_video(240,240);
//Main CPU
m6809_0:=cpu_m6809.Create(12000000 div 8,256,TCPU_M6809);
m6809_0.change_ram_calls(sonson_getbyte,sonson_putbyte);
//Sound CPU
m6809_1:=cpu_m6809.Create(12000000 div 8,256,TCPU_M6809);
m6809_1.change_ram_calls(ssonson_getbyte,ssonson_putbyte);
m6809_1.init_sound(sonson_sound_update);
//IRQ Sound CPU
timers.init(1,(12000000/8)/(4*60),sonson_snd_irq,nil,true);
//Sound Chip
AY8910_0:=ay8910_chip.create(1500000,AY8910,0.3);
AY8910_1:=ay8910_chip.create(1500000,AY8910,0.3);
//cargar roms
if not(roms_load(@memoria,sonson_rom)) then exit;
//Cargar Sound
if not(roms_load(@mem_snd,sonson_sonido)) then exit;
//convertir chars
if not(roms_load(@memoria_temp,sonson_char)) then exit;
init_gfx(0,8,8,1024);
gfx_set_desc_data(2,0,8*8,$2000*8,0*8);
convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
//sprites
if not(roms_load(@memoria_temp,sonson_sprites)) then exit;
init_gfx(1,16,16,512);
gfx[1].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,$8000*8,$4000*8,0*8);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//colores
if not(roms_load(@memoria_temp,sonson_prom)) then exit;
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
marcade.dswa_val2:=@sonson_dip_a;
marcade.dswb_val2:=@sonson_dip_b;
//final
reset_sonson;
iniciar_sonson:=true;
end;

end.
