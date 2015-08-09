unit pinballaction_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ay_8910,rom_engine,
     pal_engine,sound_engine,timer_engine;

procedure Cargar_pinballaction;
procedure pinballaction_principal;
function iniciar_pinballaction:boolean;
procedure reset_pinballaction;
procedure cerrar_pinballaction;
//Main CPU
function pinballaction_getbyte(direccion:word):byte;
procedure pinballaction_putbyte(direccion:word;valor:byte);
//Sound CPU
function snd_getbyte(direccion:word):byte;
procedure snd_putbyte(direccion:word;valor:byte);
procedure snd_outbyte(valor:byte;puerto:word);
procedure pbaction_sound_irq;
procedure pinballaction_sound_update;

const
        pinballaction_rom:array[0..3] of tipo_roms=(
        (n:'b-p7.bin';l:$4000;p:0;crc:$8d6dcaae),(n:'b-n7.bin';l:$4000;p:$4000;crc:$d54d5402),
        (n:'b-l7.bin';l:$2000;p:$8000;crc:$e7412d68),());
        pinballaction_sound:tipo_roms=(n:'a-e3.bin';l:$2000;p:0;crc:$0e53a91f);
        pinballaction_chars:array[0..3] of tipo_roms=(
        (n:'a-s6.bin';l:$2000;p:0;crc:$9a74a8e1),(n:'a-s7.bin';l:$2000;p:$2000;crc:$5ca6ad3c),
        (n:'a-s8.bin';l:$2000;p:$4000;crc:$9f00b757),());
        pinballaction_sprites:array[0..3] of tipo_roms=(
        (n:'b-c7.bin';l:$2000;p:0;crc:$d1795ef5),(n:'b-d7.bin';l:$2000;p:$2000;crc:$f28df203),
        (n:'b-f7.bin';l:$2000;p:$4000;crc:$af6e9817),());
        pinballaction_tiles:array[0..4] of tipo_roms=(
        (n:'a-j5.bin';l:$4000;p:0;crc:$21efe866),(n:'a-j6.bin';l:$4000;p:$4000;crc:$7f984c80),
        (n:'a-j7.bin';l:$4000;p:$8000;crc:$df69e51b),(n:'a-j8.bin';l:$4000;p:$c000;crc:$0094cb8b),());
        //DIP
        pinballaction_dipa:array [0..5] of def_dip=(
        (mask:$3;name:'Coin B';number:4;dip:((dip_val:$0;dip_name:'1C 1C'),(dip_val:$1;dip_name:'1C 2C'),(dip_val:$2;dip_name:'1C 3C'),(dip_val:$3;dip_name:'1C 6C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin A';number:4;dip:((dip_val:$4;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$c;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$30;dip_name:'2'),(dip_val:$0;dip_name:'3'),(dip_val:$10;dip_name:'4'),(dip_val:$20;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$40;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        pinballaction_dipb:array [0..4] of def_dip=(
        (mask:$7;name:'Bonus Life';number:8;dip:((dip_val:$1;dip_name:'70k 200k 1000k'),(dip_val:$4;dip_name:'100k 300k 1000k'),(dip_val:$0;dip_name:'70k 200k'),(dip_val:$3;dip_name:'100k 300k'),(dip_val:$6;dip_name:'200k 1000k'),(dip_val:$2;dip_name:'100k'),(dip_val:$5;dip_name:'200k'),(dip_val:$7;dip_name:'None'),(),(),(),(),(),(),(),())),
        (mask:$8;name:'Extra';number:2;dip:((dip_val:$8;dip_name:'Hard'),(dip_val:$0;dip_name:'Easy'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Flippers';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$10;dip_name:'Medium'),(dip_val:$20;dip_name:'Hard'),(dip_val:$30;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty (Outlanes)';number:4;dip:((dip_val:$0;dip_name:'Easy'),(dip_val:$40;dip_name:'Medium'),(dip_val:$80;dip_name:'Hard'),(dip_val:$c0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());

var
 sound_latch,scroll_y:byte;
 nmi_mask:boolean;

implementation

procedure Cargar_pinballaction;
begin
llamadas_maquina.iniciar:=iniciar_pinballaction;
llamadas_maquina.bucle_general:=pinballaction_principal;
llamadas_maquina.cerrar:=cerrar_pinballaction;
llamadas_maquina.reset:=reset_pinballaction;
end;

function iniciar_pinballaction:boolean;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			64, 65, 66, 67, 68, 69, 70, 71);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			128+(8*0), 128+(8*1), 128+(8*2), 128+(8*3), 128+(8*4), 128+(8*5), 128+(8*6), 128+(8*7));
  psd_x:array[0..31] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
      64, 65, 66, 67, 68, 69, 70, 71,
      256,257,258,259,260,261,262,263,
      320,321,322,323,324,325,326,327);
  psd_y:array[0..31] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			128+(8*0), 128+(8*1), 128+(8*2), 128+(8*3), 128+(8*4), 128+(8*5), 128+(8*6), 128+(8*7),
      512+(8*0), 512+(8*1), 512+(8*2), 512+(8*3), 512+(8*4), 512+(8*5), 512+(8*6), 512+(8*7),
      640+(8*0), 640+(8*1), 640+(8*2), 640+(8*3), 640+(8*4), 640+(8*5), 640+(8*6), 640+(8*7));
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
var
  memoria_temp:array[0..$ffff] of byte;
begin
iniciar_pinballaction:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_mod_scroll(1,0,0,0,256,256,255);
screen_init(2,256,256,true);
screen_mod_scroll(2,0,0,0,256,256,255);
screen_init(3,256,256,false,true);
iniciar_video(224,256);
//Main CPU
main_z80:=cpu_z80.create(4000000,$100);
main_z80.change_ram_calls(pinballaction_getbyte,pinballaction_putbyte);
//Sound CPU
snd_z80:=cpu_z80.create(3072000,$100);
snd_z80.change_ram_calls(snd_getbyte,snd_putbyte);
snd_z80.change_io_calls(nil,snd_outbyte);
snd_z80.init_sound(pinballaction_sound_update);
init_timer(snd_z80.numero_cpu,3072000/(2*60),pbaction_sound_irq,true);
//Sound Chip
ay8910_0:=ay8910_chip.create(1500000,1);
ay8910_1:=ay8910_chip.create(1500000,1);
ay8910_2:=ay8910_chip.create(1500000,1);
//cargar roms
if not(cargar_roms(@memoria[0],@pinballaction_rom[0],'pbaction.zip',0)) then exit;
//cargar sonido
if not(cargar_roms(@mem_snd[0],@pinballaction_sound,'pbaction.zip')) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@pinballaction_chars[0],'pbaction.zip',0)) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,$400*0*8*8,$400*1*8*8,$400*2*8*8);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//tiles
if not(cargar_roms(@memoria_temp[0],@pinballaction_tiles[0],'pbaction.zip',0)) then exit;
init_gfx(1,8,8,$800);
gfx_set_desc_data(4,0,8*8,$800*0*8*8,$800*1*8*8,$800*2*8*8,$800*3*8*8);
convert_gfx(1,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//convertir sprites
if not(cargar_roms(@memoria_temp[0],@pinballaction_sprites[0],'pbaction.zip',0)) then exit;
init_gfx(2,16,16,$100);
gfx[2].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,$100*0*8*32,$100*1*8*32,$100*2*8*32);
convert_gfx(2,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
//convertir sprites double
init_gfx(3,32,32,$20);
gfx[3].trans[0]:=true;
gfx_set_desc_data(3,0,128*8,$40*0*8*128,$40*1*8*128,$40*2*8*128);
convert_gfx(3,0,@memoria_temp[$1000],@psd_x[0],@psd_y[0],true,false);
//DIP
marcade.dswa:=$40;
marcade.dswa_val:=@pinballaction_dipa;
marcade.dswb:=$0;
marcade.dswb_val:=@pinballaction_dipb;
reset_pinballaction;
iniciar_pinballaction:=true;
end;

procedure cerrar_pinballaction;
begin
main_z80.free;
snd_z80.free;
ay8910_0.Free;
ay8910_1.Free;
ay8910_2.Free;
close_audio;
close_video;
end;

procedure reset_pinballaction;
begin
 main_z80.reset;
 snd_z80.reset;
 ay8910_0.reset;
 ay8910_1.reset;
 ay8910_2.reset;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 scroll_y:=0;
 sound_latch:=0;
 nmi_mask:=false;
end;

procedure update_video_pinballaction;
var
  f,color,nchar,x,y:word;
  atrib,atrib2:byte;
begin
//background
for f:=0 to $3ff do begin
  atrib:=memoria[$dc00+f];
  color:=atrib and $7;
  if (gfx[1].buffer[f] or buffer_color[color+$10]) then begin
      x:=31-(f div 32);
      y:=f mod 32;
      nchar:=memoria[$d800+f]+$10*(atrib and $70);
      put_gfx_flip(x*8,y*8,nchar,(color shl 4)+128,1,1,(atrib and $80)<>0,false);
      gfx[1].buffer[f]:=false;
  end;
  //chars
  atrib:=memoria[$d400+f];
  color:=atrib and $f;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=31-(f div 32);
      y:=f mod 32;
      nchar:=memoria[$d000+f]+$10*(atrib and $30);
      put_gfx_trans_flip(x*8,y*8,nchar,color shl 3,2,0,(atrib and $80)<>0,(atrib and $40)<>0);
      gfx[0].buffer[f]:=false;
  end;
end;
scroll__y(1,3,scroll_y);
//Sprites
for f:=$1f downto 0 do begin
  //Si el siguiente es doble no lo pongo
  if ((f>0) and ((memoria[($e000+(f*4))-4] and $80)<>0)) then continue;
  atrib:=memoria[$e000+(f*4)];
  atrib2:=memoria[$e001+(f*4)];
  y:=memoria[$e003+(f*4)];
  x:=memoria[$e002+(f*4)];
  color:=(atrib2 and $f) shl 3;
  if (atrib and $80)<>0 then begin
    nchar:=3;
    atrib:=atrib and $1f;
  end else begin
    nchar:=2;
  end;
  put_gfx_sprite(atrib,color,(atrib2 and $40)<>0,(atrib2 and $80)<>0,nchar);
  actualiza_gfx_sprite(x,y,3,nchar);
end;
scroll__y(2,3,scroll_y);
actualiza_trozo_final(16,0,224,256,3);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_pinballaction;
begin
if event.arcade then begin
  //Player 1
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 or $1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.but3[0] then marcade.in0:=(marcade.in0 or $4) else marcade.in0:=(marcade.in0 and $fb);
  //Player 2
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 or $1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.but3[1] then marcade.in1:=(marcade.in1 or $4) else marcade.in1:=(marcade.in1 and $fb);
  //System
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure pinballaction_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to $ff do begin
  //CPU 1
  main_z80.run(frame_m);
  frame_m:=frame_m+main_z80.tframes-main_z80.contador;
  //CPU Sound
  snd_z80.run(frame_s);
  frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
  if f=240 then begin
     if nmi_mask then main_z80.pedir_nmi:=PULSE_LINE;
     update_video_pinballaction;
  end;
 end;
 eventos_pinballaction;
 video_sync;
end;
end;

procedure cambiar_color(dir:word);inline;
var
  tmp_color:byte;
  color:tcolor;
begin
  tmp_color:=buffer_paleta[dir+1];
  color.b:=pal4bit(tmp_color);
  tmp_color:=buffer_paleta[dir];
  color.g:=pal4bit(tmp_color shr 4);
  color.r:=pal4bit(tmp_color);
  dir:=dir shr 1;
  set_pal_color(color,@paleta[dir]);
  case dir of
    0..127:buffer_color[dir shr 3]:=true;
    128..255:buffer_color[((dir shr 4) and $7)+$10]:=true;
  end;
end;

function pinballaction_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$e07f:pinballaction_getbyte:=memoria[direccion];
  $e400..$e5ff:pinballaction_getbyte:=buffer_paleta[direccion and $1ff];
  $e600:pinballaction_getbyte:=marcade.in0; //p1
  $e601:pinballaction_getbyte:=marcade.in1; //p2
  $e602:pinballaction_getbyte:=marcade.in2; //system
  $e604:pinballaction_getbyte:=marcade.dswa;
  $e605:pinballaction_getbyte:=marcade.dswb;
end;
end;

procedure pinballaction_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
case direccion of
    $8000..$cfff,$e000..$e07f:memoria[direccion]:=valor;
    $d000..$d7ff:begin //chars
                    memoria[direccion]:=valor;
                    gfx[0].buffer[direccion and $3ff]:=true;
                 end;
    $d800..$dfff:begin //tiles
                    memoria[direccion]:=valor;
                    gfx[1].buffer[direccion and $3ff]:=true;
                 end;
    $e400..$e5ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                    buffer_paleta[direccion and $1ff]:=valor;
                    cambiar_color(direccion and $1fe);
                 end;
    $e600:nmi_mask:=(valor and $1)<>0;
    $e604:main_screen.flip_main_screen:=(valor and 1)<>0;
    $e606:scroll_y:=valor-3;
    $e800:begin
            sound_latch:=valor;
            snd_z80.pedir_irq:=HOLD_LINE;
            snd_z80.im2_lo:=0;
          end;
end;
end;

function snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$1fff,$4000..$47ff:snd_getbyte:=mem_snd[direccion];
  $8000:snd_getbyte:=sound_latch;
end;
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$2000 then exit;
case direccion of
  $4000..$47ff:mem_snd[direccion]:=valor;
end;
end;

procedure snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $10:ay8910_0.Control(valor);
  $11:ay8910_0.Write(valor);
  $20:ay8910_1.Control(valor);
  $21:ay8910_1.Write(valor);
  $30:ay8910_2.Control(valor);
  $31:ay8910_2.Write(valor);
end;
end;

procedure pbaction_sound_irq;
begin
snd_z80.pedir_irq:=HOLD_LINE;
snd_z80.im2_lo:=2;
end;

procedure pinballaction_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
  ay8910_2.update;
end;

end.
