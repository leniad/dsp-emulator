unit bombjack_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,
     pal_engine,sound_engine,qsnapshot,sega_decrypt_2;

function iniciar_bombjack:boolean;

implementation
const
        bombjack_rom:array[0..4] of tipo_roms=(
        (n:'09_j01b.bin';l:$2000;p:0;crc:$c668dc30),(n:'10_l01b.bin';l:$2000;p:$2000;crc:$52a1e5fb),
        (n:'11_m01b.bin';l:$2000;p:$4000;crc:$b68a062a),(n:'12_n01b.bin';l:$2000;p:$6000;crc:$1d3ecee5),
        (n:'13.1r';l:$2000;p:$c000;crc:$70e0244d));
        bombjack_char:array[0..2] of tipo_roms=(
        (n:'03_e08t.bin';l:$1000;p:0;crc:$9f0470d5),(n:'04_h08t.bin';l:$1000;p:$1000;crc:$81ec12e6),
        (n:'05_k08t.bin';l:$1000;p:$2000;crc:$e87ec8b1));
        bombjack_tiles:array[0..2] of tipo_roms=(
        (n:'06_l08t.bin';l:$2000;p:0;crc:$51eebd89),(n:'07_n08t.bin';l:$2000;p:$2000;crc:$9dd98e9d),
        (n:'08_r08t.bin';l:$2000;p:$4000;crc:$3155ee7d));
        bombjack_sprites:array[0..2] of tipo_roms=(
        (n:'16_m07b.bin';l:$2000;p:0;crc:$94694097),(n:'15_l07b.bin';l:$2000;p:$2000;crc:$013f58f2),
        (n:'14_j07b.bin';l:$2000;p:$4000;crc:$101c858d));
        bombjack_tiles_map:tipo_roms=(n:'02_p04t.bin';l:$1000;p:0;crc:$398d4a02);
        bombjack_sonido:tipo_roms=(n:'01_h03t.bin';l:$2000;p:0;crc:$8407917d);
        bombjack_dipa:array [0..5] of def_dip2=(
        (mask:$3;name:'Coin A';number:4;val4:(0,1,2,3);name4:('1C 1C','1C 2C','1C 3C','1C 6C')),
        (mask:$c;name:'Coin B';number:4;val4:(4,0,8,$c);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$30;name:'Lives';number:4;val4:($30,0,$10,$20);name4:('2','3','4','5')),
        (mask:$40;name:'Cabinet';number:2;val2:($40,0);name2:('Upright','Cocktail')),
        (mask:$80;name:'Demo Sounds';number:2;val2:(0,$80);name2:('Off','On')),());
        bombjack_dipb:array [0..4] of def_dip2=(
        (mask:$7;name:'Bonus Life';number:8;val8:(2,1,7,5,3,6,4,0);name8:('30K+','100K+','50K 100K 300K','50K 100K','50K','100K 300K','100K','None')),
        (mask:$18;name:'Bird Speed';number:4;val4:(0,8,$10,$18);name4:('Easy','Medium','Hard','Hardest')),
        (mask:$60;name:'Enemies Number && Speed';number:4;val4:($20,0,$40,$60);name4:('Easy','Medium','Hard','Hardest')),
        (mask:$80;name:'Special Coin';number:2;val2:(0,$80);name2:('Easy','Hard')),());
        //Calorie Kun
        caloriekun_rom:array[0..2] of tipo_roms=(
        (n:'epr10072.1j';l:$4000;p:0;crc:$ade792c1),(n:'epr10073.1k';l:$4000;p:$4000;crc:$b53e109f),
        (n:'epr10074.1m';l:$4000;p:$8000;crc:$a08da685));
        caloriekun_sonido:tipo_roms=(n:'epr10075.4d';l:$4000;p:0;crc:$ca547036);
        caloriekun_char:array[0..2] of tipo_roms=(
        (n:'epr10082.5r';l:$2000;p:0;crc:$5984ea44),(n:'epr10081.4r';l:$2000;p:$2000;crc:$e2d45dd8),
        (n:'epr10080.3r';l:$2000;p:$4000;crc:$42edfcfe));
        caloriekun_tiles:array[0..2] of tipo_roms=(
        (n:'epr10078.7d';l:$4000;p:0;crc:$5b8eecce),(n:'epr10077.6d';l:$4000;p:$4000;crc:$01bcb609),
        (n:'epr10076.5d';l:$4000;p:$8000;crc:$b1529782));
        caloriekun_sprites:array[0..2] of tipo_roms=(
        (n:'epr10071.7m';l:$4000;p:0;crc:$5f55527a),(n:'epr10070.7k';l:$4000;p:$4000;crc:$97f35a23),
        (n:'epr10069.7j';l:$4000;p:$8000;crc:$c0c3deaf));
        caloriekun_tiles_map:tipo_roms=(n:'epr10079.8d';l:$2000;p:0;crc:$3c61a42c);
        caloriekun_dipa:array [0..5] of def_dip2=(
        (mask:$3;name:'Coin A';number:4;val4:(0,1,2,3);name4:('1C 1C','1C 2C','1C 3C','1C 6C')),
        (mask:$c;name:'Coin B';number:4;val4:($c,0,4,8);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$10;name:'Cabinet';number:2;val2:($10,0);name2:('Upright','Cocktail')),
        (mask:$20;name:'Demo Sounds';number:2;val2:(0,$20);name2:('Off','On')),
        (mask:$c0;name:'Lives';number:4;val4:($c0,0,$40,$80);name4:('2','3','4','5')),());
        caloriekun_dipb:array [0..5] of def_dip2=(
        (mask:$3;name:'Bonus Life';number:4;val4:(0,1,3,2);name4:('None','20K','20K 60K','Invalid')),
        (mask:$4;name:'Number of Bombs';number:2;val2:(0,4);name2:('3','5')),
        (mask:$8;name:'Difficulty - Mogura Nian';number:2;val2:(0,8);name2:('Normal','Hard')),
        (mask:$30;name:'Difficulty - Select of Mogura';number:4;val4:(0,$20,$10,$30);name4:('Easy','Normal','Hard','Hardest')),
        (mask:$80;name:'Infinite Lives';number:2;val2:(0,$80);name2:('Off','On')),());

var
 memoria_fondo:array[0..$1fff] of byte;
 numero_fondo,sound_latch,mask_sprites:byte;
 fondo_activo,nmi_vblank,bombjack_video:boolean;
 memoria_sprites:array[0..$7f] of byte;
 memoria_screen:array[0..$7ff] of byte;
 memoria_ram:array[0..$fff] of byte;
 actualiza_fondo:boolean;
 //Bomb Jack
 sprite_control:array[0..1] of byte;
 //Calorie
 mem_dec:array[0..$7fff] of byte;

procedure update_video_bombjack;
procedure cambia_fondo(base:word);
var
  x,y,color,f,atrib:byte;
  nchar:word;
begin
for f:=0 to $ff do begin
  atrib:=memoria_fondo[$100+base+f];
  color:=atrib and $f;
  if (gfx[1].buffer[f] or buffer_color[color]) then begin
    x:=f mod 16;
    y:=f div 16;
    nchar:=memoria_fondo[base+f]+((atrib and $30) shl 4);
    put_gfx_flip(x*16,y*16,nchar,color shl 3,1,1,(atrib and $40)<>0,false);
    gfx[1].buffer[f]:=false;
  end;
end;
end;
var
  x,y,atrib:byte;
  f,nchar,color:word;
  large,rev:boolean;
begin
if fondo_activo then begin
  if actualiza_fondo then begin
    cambia_fondo(numero_fondo*$200);
    actualiza_fondo:=false;
  end;
  actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
end else fill_full_screen(3,0);
for f:=0 to $3ff do begin
  atrib:=memoria_screen[$400+f];
  color:=atrib and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=f mod 32;
    y:=f div 32;
    nchar:=memoria_screen[f]+(atrib and $30) shl 4;
    put_gfx_trans_flip(x*8,y*8,nchar,color shl 3,2,0,(atrib and $40)<>0,(atrib and $80)<>0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
for f:=31 downto 7 do begin
   x:=memoria_sprites[3+(f*4)];
   y:=240-memoria_sprites[2+(f*4)];
   nchar:=memoria_sprites[0+(f*4)];
   atrib:=memoria_sprites[1+(f*4)];
   color:=(atrib and $f) shl 3;
   if bombjack_video then begin
      rev:=sprite_control[0]>sprite_control[1];
      if rev then large:=((f shr 1)>sprite_control[1]) and ((f shr 1)<=sprite_control[0])
        else large:=((f shr 1)>sprite_control[0]) and ((f shr 1)<=sprite_control[1]);
      y:=y+1;
   end else begin
      large:=(atrib and $10)<>0;
   end;
   if not(large) then begin
      put_gfx_sprite(nchar,color,atrib and $40<>0,atrib and $80<>0,2);
      actualiza_gfx_sprite(x,y,3,2);
   end else begin
      if ((f and 1)<>0) then continue;
      put_gfx_sprite(nchar and mask_sprites,color,atrib and $40<>0,atrib and $80<>0,3);
      actualiza_gfx_sprite(x,y-16,3,3);
   end;
end;
actualiza_trozo_final(0,16,256,224,3);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_bombjack;
begin
if event.arcade then begin
  //p1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  //p2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  //System
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure eventos_caloriekun;
begin
if event.arcade then begin
  //p1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  //p2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  //System
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure bombjack_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=239 then begin
      if nmi_vblank then z80_0.change_nmi(ASSERT_LINE);
      update_video_bombjack;
      z80_1.change_nmi(PULSE_LINE);
    end;
  end;
  eventos_bombjack;
  video_sync;
end;
end;

procedure caloriekun_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=z80_0.tframes;
frame_s:=z80_1.tframes;
while EmuStatus=EsRunning do begin
  for f:=0 to 263 do begin
    //Main CPU
    z80_0.run(frame_m);
    frame_m:=frame_m+z80_0.tframes-z80_0.contador;
    //Sound
    z80_1.run(frame_s);
    frame_s:=frame_s+z80_1.tframes-z80_1.contador;
    if f=239 then begin
      update_video_bombjack;
      z80_0.change_irq(HOLD_LINE);
      z80_1.change_irq(HOLD_LINE);
    end;
  end;
  eventos_caloriekun;
  video_sync;
end;
end;

procedure cambiar_color(dir:word);
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir];
  color.r:=pal4bit(tmp_color);
  color.g:=pal4bit(tmp_color shr 4);
  tmp_color:=buffer_paleta[dir+1];
  color.b:=pal4bit(tmp_color);
  dir:=dir shr 1;
  set_pal_color(color,dir);
  buffer_color[(dir shr 3) and $f]:=true;
  actualiza_fondo:=true;
end;

function gen_map_read(direccion:word):byte;
begin
case direccion of
  $0..$fff:gen_map_read:=memoria_ram[direccion];
  $1000..$17ff:gen_map_read:=memoria_screen[direccion and $7ff];
  $1c00..$1dff:gen_map_read:=buffer_paleta[direccion and $ff];
  $3000..$37ff:case (direccion and 7) of
                  0:gen_map_read:=marcade.in0;
                  1:gen_map_read:=marcade.in1;
                  2:gen_map_read:=marcade.in2;
                  4:gen_map_read:=marcade.dswa;
                  5:gen_map_read:=marcade.dswb;
               end;
end;
end;

procedure gen_map_write(direccion:word;valor:byte);
begin
case direccion of
  $0..$fff:memoria_ram[direccion]:=valor;
  $1000..$17ff:if memoria_screen[(direccion and $7ff)]<>valor then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria_screen[(direccion and $7ff)]:=valor;
               end;
  $1800..$19ff:memoria_sprites[direccion and $7f]:=valor;
  $1c00..$1dff:if buffer_paleta[direccion and $ff]<>valor then begin
                  buffer_paleta[direccion and $ff]:=valor;
                  cambiar_color(direccion and $fe);
               end;
  $1e00..$1fff:begin
                  fondo_activo:=(valor and $10)<>0;
                  if (numero_fondo<>(valor and $f)) then begin
                    numero_fondo:=valor and $f;
                    actualiza_fondo:=true;
                    fillchar(gfx[1].buffer,$100,1);
                  end;
               end;
  $3800..$3fff:sound_latch:=valor;
end;
end;

function bombjack_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff,$c000..$dfff:bombjack_getbyte:=memoria[direccion]; //ROM
  $8000..$97ff,$9c00..$9dff,$b000..$b7ff:bombjack_getbyte:=gen_map_read(direccion-$8000);
end;
end;

procedure bombjack_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff,$c000..$dfff:; //ROM
  $8000..$99ff,$9c00..$9fff,$b800..$bfff:gen_map_write(direccion-$8000,valor);
  $9a00..$9bff:sprite_control[direccion and 1]:=valor and $f;
  $b000..$b7ff:case (direccion and 7) of
                  0:begin
                      nmi_vblank:=valor<>0;
                      if not(nmi_vblank) then z80_0.change_nmi(CLEAR_LINE);
                    end;
                  3:; //WD
                  4:main_screen.flip_main_screen:=(valor and 1)<>0;
               end;
end;
end;

function snd_getbyte(direccion:word):byte;
begin
case (direccion and $7fff) of
  0..$1fff:snd_getbyte:=mem_snd[direccion];
  $4000..$5fff:snd_getbyte:=mem_snd[$4000+(direccion and $7ff)];
  $6000..$7fff:begin
                snd_getbyte:=sound_latch;
                sound_latch:=0;
               end;
end;
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
case (direccion and $7fff) of
  0..$1fff:; //ROM
  $4000..$5fff:mem_snd[$4000+(direccion and $7ff)]:=valor;
end;
end;

function snd_inbyte(puerto:word):byte;
begin
case (puerto and $91) of
  $1:snd_inbyte:=ay8910_0.read;
  $11:snd_inbyte:=ay8910_1.read;
  $81:snd_inbyte:=ay8910_2.read;
end;
end;

procedure snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $91) of
  $0:ay8910_0.control(valor);
  $1:ay8910_0.write(valor);
  $10:ay8910_1.control(valor);
  $11:ay8910_1.write(valor);
  $80:ay8910_2.control(valor);
  $81:ay8910_2.write(valor);
end
end;

procedure bombjack_update_sound;
begin
  ay8910_0.update;
  ay8910_1.update;
  ay8910_2.update;
end;

//Calorie kun
function caloriekun_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:if z80_0.opcode then caloriekun_getbyte:=mem_dec[direccion]
                 else caloriekun_getbyte:=memoria[direccion];
  $8000..$bfff:caloriekun_getbyte:=memoria[direccion];  //ROM
  $c000..$ffff:caloriekun_getbyte:=gen_map_read(direccion-$c000);
end;
end;

procedure caloriekun_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$bfff:; //ROM
  $c000..$ffff:gen_map_write(direccion-$c000,valor);
end;
end;

function calorie_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$7fff:calorie_snd_getbyte:=mem_snd[direccion and $3fff];
  $8000..$bfff:calorie_snd_getbyte:=mem_snd[$8000+(direccion and $7ff)];
  $c000..$ffff:begin
                  calorie_snd_getbyte:=sound_latch;
                  sound_latch:=0;
               end;
end;
end;

procedure calorie_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:; //ROM
  $8000..$bfff:mem_snd[$8000+(direccion and $7ff)]:=valor;
end;
end;

procedure bombjack_qsave(nombre:string);
var
  data:pbyte;
  size:word;
  buffer:array[0..5] of byte;
begin
case main_vars.tipo_maquina of
  13:open_qsnapshot_save('bombjack'+nombre);
  383:open_qsnapshot_save('caloriekun'+nombre);
end;
getmem(data,200);
//CPU
size:=z80_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=z80_1.save_snapshot(data);
savedata_qsnapshot(data,size);
//SND
size:=ay8910_0.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=ay8910_1.save_snapshot(data);
savedata_qsnapshot(data,size);
size:=ay8910_2.save_snapshot(data);
savedata_qsnapshot(data,size);
//MEM
savedata_qsnapshot(@memoria[$8000],$8000);
savedata_qsnapshot(@mem_snd[$2000],$e000);
savedata_qsnapshot(@memoria_sprites[0],$80);
savedata_qsnapshot(@memoria_screen[0],$800);
savedata_qsnapshot(@memoria_ram[0],$1000);
//MISC
buffer[0]:=numero_fondo;
buffer[1]:=sound_latch;
buffer[2]:=byte(fondo_activo);
buffer[3]:=byte(nmi_vblank);
buffer[4]:=sprite_control[0];
buffer[5]:=sprite_control[1];
savedata_qsnapshot(@buffer,6);
savedata_qsnapshot(@buffer_paleta,$100*2);
freemem(data);
close_qsnapshot;
end;

procedure bombjack_qload(nombre:string);
var
  data:pbyte;
  buffer:array[0..5] of byte;
  f:byte;
begin
case main_vars.tipo_maquina of
  13:if not(open_qsnapshot_load('bombjack'+nombre)) then exit;
  383:if not(open_qsnapshot_load('caloriekun'+nombre)) then exit;
end;
getmem(data,200);
//CPU
loaddata_qsnapshot(data);
z80_0.load_snapshot(data);
loaddata_qsnapshot(data);
z80_1.load_snapshot(data);
//SND
loaddata_qsnapshot(data);
ay8910_0.load_snapshot(data);
loaddata_qsnapshot(data);
ay8910_1.load_snapshot(data);
loaddata_qsnapshot(data);
ay8910_2.load_snapshot(data);
//MEM
loaddata_qsnapshot(@memoria[$8000]);
loaddata_qsnapshot(@mem_snd[$2000]);
loaddata_qsnapshot(@memoria_sprites[0]);
loaddata_qsnapshot(@memoria_screen[0]);
loaddata_qsnapshot(@memoria_ram[0]);
//MISC
loaddata_qsnapshot(@buffer[0]);
numero_fondo:=buffer[0];
sound_latch:=buffer[1];
fondo_activo:=buffer[2]<>0;
nmi_vblank:=buffer[3]<>0;
sprite_control[0]:=buffer[4];
sprite_control[1]:=buffer[5];
loaddata_qsnapshot(@buffer_paleta);
freemem(data);
close_qsnapshot;
for f:=0 to $7f do cambiar_color(f*2);
actualiza_fondo:=true;
end;

//Main
procedure bombjack_reset;
begin
z80_0.reset;
z80_1.reset;
ay8910_0.reset;
ay8910_1.reset;
ay8910_2.reset;
reset_audio;
nmi_vblank:=false;
fondo_activo:=false;
sound_latch:=0;
numero_fondo:=$ff;
marcade.in0:=0;
marcade.in1:=0;
marcade.in2:=$f0;
sprite_control[0]:=0;
sprite_control[1]:=0;
end;

function iniciar_bombjack:boolean;
const
      pt_x:array[0..31] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 32*8+4, 32*8+5, 32*8+6, 32*8+7,
			40*8+0, 40*8+1, 40*8+2, 40*8+3, 40*8+4, 40*8+5, 40*8+6, 40*8+7);
      pt_y:array[0..31] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8,
			64*8, 65*8, 66*8, 67*8, 68*8, 69*8, 70*8, 71*8,
			80*8, 81*8, 82*8, 83*8, 84*8, 85*8, 86*8, 87*8);
var
  memoria_temp:array[0..$ffff] of byte;
procedure convert_chars(num:word);
begin
  init_gfx(0,8,8,num);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(3,0,8*8,0*8,num*8*8,num*8*2*8);
  convert_gfx(0,0,@memoria_temp,@pt_x,@pt_y,false,false);
end;
procedure convert_tiles(num:word);
begin
  init_gfx(1,16,16,num);
  gfx[1].trans[0]:=true;
  gfx_set_desc_data(3,0,32*8,0,$20*num*8,2*$20*num*8);
  convert_gfx(1,0,@memoria_temp,@pt_x,@pt_y,false,false);
end;
procedure convert_sprites(num:word);
begin
  init_gfx(2,16,16,num);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(3,0,32*8,0,$20*num*8,2*$20*num*8);
  convert_gfx(2,0,@memoria_temp,@pt_x,@pt_y,false,false);
  num:=num shr 2;
  init_gfx(3,32,32,num);
  gfx[3].trans[0]:=true;
  gfx_set_desc_data(3,0,128*8,0*8,$80*num*8,2*$80*num*8);
  convert_gfx(3,0,@memoria_temp[$40*num],@pt_x,@pt_y,false,false);
end;
begin
llamadas_maquina.reset:=bombjack_reset;
llamadas_maquina.save_qsnap:=bombjack_qsave;
llamadas_maquina.load_qsnap:=bombjack_qload;
iniciar_bombjack:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
if main_vars.tipo_maquina=13 then main_screen.rot90_screen:=true;
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(4000000,264);
//Sound CPU
z80_1:=cpu_z80.create(3000000,264);
z80_1.change_io_calls(snd_inbyte,snd_outbyte);
z80_1.init_sound(bombjack_update_sound);
//Sound Chip
ay8910_0:=ay8910_chip.create(1500000,AY8910,1);
ay8910_1:=ay8910_chip.create(1500000,AY8910,1);
ay8910_2:=ay8910_chip.create(1500000,AY8910,1);
case main_vars.tipo_maquina of
  13:begin //Bomb Jack
        llamadas_maquina.bucle_general:=bombjack_principal;
        bombjack_video:=true;
        //Main
        if not(roms_load(@memoria,bombjack_rom)) then exit;
        z80_0.change_ram_calls(bombjack_getbyte,bombjack_putbyte);
        //Snd
        if not(roms_load(@mem_snd,bombjack_sonido)) then exit;
        z80_1.change_ram_calls(snd_getbyte,snd_putbyte);
        //chars
        if not(roms_load(@memoria_temp,bombjack_char)) then exit;
        convert_chars($200);
        //tiles
        if not(roms_load(@memoria_fondo,bombjack_tiles_map)) then exit;
        if not(roms_load(@memoria_temp,bombjack_tiles)) then exit;
        convert_tiles($100);
        //sprites
        if not(roms_load(@memoria_temp,bombjack_sprites)) then exit;
        convert_sprites($100);
        mask_sprites:=$1f;
        //DIP
        marcade.dswa:=$c0;
        marcade.dswa_val2:=@bombjack_dipa;
        marcade.dswb:=$50;
        marcade.dswb_val2:=@bombjack_dipb;
  end;
  383:begin
        llamadas_maquina.bucle_general:=caloriekun_principal;
        bombjack_video:=false;
        if not(roms_load(@memoria,caloriekun_rom)) then exit;
        z80_0.change_ram_calls(caloriekun_getbyte,caloriekun_putbyte);
        decode_sega_type2(@memoria,@mem_dec,S317_000X,0);
        //Snd
        if not(roms_load(@mem_snd,caloriekun_sonido)) then exit;
        z80_1.change_ram_calls(calorie_snd_getbyte,calorie_snd_putbyte);
        //convertir chars
        if not(roms_load(@memoria_temp,caloriekun_char)) then exit;
        convert_chars($400);
        //convertir tiles
        if not(roms_load(@memoria_fondo,caloriekun_tiles_map)) then exit;
        if not(roms_load(@memoria_temp,caloriekun_tiles)) then exit;
        convert_tiles($200);
        //sprites
        if not(roms_load(@memoria_temp,caloriekun_sprites)) then exit;
        convert_sprites($200);
        mask_sprites:=$3f;
        //DIP
        marcade.dswa:=$30;
        marcade.dswa_val2:=@caloriekun_dipa;
        marcade.dswb:=0;
        marcade.dswb_val2:=@caloriekun_dipb;
      end;
end;
//final
bombjack_reset;
iniciar_bombjack:=true;
end;

end.
