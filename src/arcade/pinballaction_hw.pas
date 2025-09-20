unit pinballaction_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ay_8910,rom_engine,
     pal_engine,sound_engine,timer_engine;

function iniciar_pinballaction:boolean;

const
        pinballaction_rom:array[0..2] of tipo_roms=(
        (n:'b-p7.bin';l:$4000;p:0;crc:$8d6dcaae),(n:'b-n7.bin';l:$4000;p:$4000;crc:$d54d5402),
        (n:'b-l7.bin';l:$2000;p:$8000;crc:$e7412d68));
        pinballaction_sound:tipo_roms=(n:'a-e3.bin';l:$2000;p:0;crc:$0e53a91f);
        pinballaction_chars:array[0..2] of tipo_roms=(
        (n:'a-s6.bin';l:$2000;p:0;crc:$9a74a8e1),(n:'a-s7.bin';l:$2000;p:$2000;crc:$5ca6ad3c),
        (n:'a-s8.bin';l:$2000;p:$4000;crc:$9f00b757));
        pinballaction_sprites:array[0..2] of tipo_roms=(
        (n:'b-c7.bin';l:$2000;p:0;crc:$d1795ef5),(n:'b-d7.bin';l:$2000;p:$2000;crc:$f28df203),
        (n:'b-f7.bin';l:$2000;p:$4000;crc:$af6e9817));
        pinballaction_tiles:array[0..3] of tipo_roms=(
        (n:'a-j5.bin';l:$4000;p:0;crc:$21efe866),(n:'a-j6.bin';l:$4000;p:$4000;crc:$7f984c80),
        (n:'a-j7.bin';l:$4000;p:$8000;crc:$df69e51b),(n:'a-j8.bin';l:$4000;p:$c000;crc:$0094cb8b));
        //DIP
        pinballaction_dipa:array [0..4] of def_dip2=(
        (mask:3;name:'Coin B';number:4;val4:(0,1,2,3);name4:('1C 1C','1C 2C','1C 3C','1C 6C')),
        (mask:$c;name:'Coin A';number:4;val4:(4,0,8,$c);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$30;name:'Lives';number:4;val4:($30,0,$10,$20);name4:('2','3','4','5')),
        (mask:$40;name:'Cabinet';number:2;val2:($40,0);name2:('Upright','Cocktail')),
        (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')));
        pinballaction_dipb:array [0..3] of def_dip2=(
        (mask:7;name:'Bonus Life';number:8;val8:(1,4,0,3,6,2,5,7);name8:('70K 200K 1000K','100K 300K 1000K','70K 200K','100K 300K','200K 1000K','100K','200K','None')),
        (mask:8;name:'Extra';number:2;val2:(8,0);name2:('Hard','Easy')),
        (mask:$30;name:'Flippers';number:4;val4:(0,$10,$20,$30);name4:('Easy','Medium','Hard','Hardest')),
        (mask:$c0;name:'Difficulty (Outlanes)';number:4;val4:(0,$40,$80,$c0);name4:('Easy','Medium','Hard','Hardest')));

var
 sound_latch,scroll_y:byte;
 nmi_mask:boolean;

implementation

procedure update_video_pinballaction;
var
  f,color,nchar,x,y:word;
  atrib,atrib2:byte;
begin
//background
for f:=0 to $3ff do begin
  atrib:=memoria[$dc00+f];
  color:=atrib and 7;
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
  if arcade_input.but2[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.but3[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  //Player 2
  if arcade_input.but2[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.but3[1] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  //System
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure pinballaction_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
 for f:=0 to $ff do begin
    eventos_pinballaction;
    if f=240 then begin
      if nmi_mask then z80_0.change_nmi(PULSE_LINE);
      update_video_pinballaction;
    end;
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
 end;
 video_sync;
end;
end;

function pinballaction_getbyte(direccion:word):byte;
begin
case direccion of
  0..$e07f:pinballaction_getbyte:=memoria[direccion];
  $e400..$e5ff:pinballaction_getbyte:=buffer_paleta[direccion and $1ff];
  $e600:pinballaction_getbyte:=marcade.in0; //p1
  $e601:pinballaction_getbyte:=marcade.in1; //p2
  $e602:pinballaction_getbyte:=marcade.in2; //system
  $e604:pinballaction_getbyte:=marcade.dswa;
  $e605:pinballaction_getbyte:=marcade.dswb;
end;
end;

procedure pinballaction_putbyte(direccion:word;valor:byte);
procedure cambiar_color(dir:word);
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
  set_pal_color(color,dir);
  case dir of
    0..127:buffer_color[dir shr 3]:=true;
    128..255:buffer_color[((dir shr 4) and 7)+$10]:=true;
  end;
end;
begin
case direccion of
    0..$7fff:;
    $8000..$cfff,$e000..$e07f:memoria[direccion]:=valor;
    $d000..$d7ff:if memoria[direccion]<>valor then begin //chars
                    memoria[direccion]:=valor;
                    gfx[0].buffer[direccion and $3ff]:=true;
                 end;
    $d800..$dfff:if memoria[direccion]<>valor then begin //tiles
                    memoria[direccion]:=valor;
                    gfx[1].buffer[direccion and $3ff]:=true;
                 end;
    $e400..$e5ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                    buffer_paleta[direccion and $1ff]:=valor;
                    cambiar_color(direccion and $1fe);
                 end;
    $e600:nmi_mask:=(valor and 1)<>0;
    $e604:main_screen.flip_main_screen:=(valor and 1)<>0;
    $e606:scroll_y:=valor-3;
    $e800:begin
            sound_latch:=valor;
            z80_1.change_irq_vector(HOLD_LINE,0);
          end;
end;
end;

function snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$1fff,$4000..$47ff:snd_getbyte:=mem_snd[direccion];
  $8000:snd_getbyte:=sound_latch;
end;
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$1fff:;
  $4000..$47ff:mem_snd[direccion]:=valor;
end;
end;

procedure snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $10:ay8910_0.control(valor);
  $11:ay8910_0.write(valor);
  $20:ay8910_1.control(valor);
  $21:ay8910_1.write(valor);
  $30:ay8910_2.control(valor);
  $31:ay8910_2.write(valor);
end;
end;

procedure pbaction_sound_irq;
begin
  z80_1.change_irq_vector(HOLD_LINE,2);
end;

procedure pinballaction_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
  ay8910_2.update;
end;

//Main
procedure reset_pinballaction;
begin
 z80_0.reset;
 z80_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 ay8910_0.reset;
 ay8910_1.reset;
 ay8910_2.reset;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 scroll_y:=0;
 sound_latch:=0;
 nmi_mask:=false;
end;

function iniciar_pinballaction:boolean;
const
  psd_x:array[0..31] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
      64, 65, 66, 67, 68, 69, 70, 71,
      256,257,258,259,260,261,262,263,
      320,321,322,323,324,325,326,327);
  psd_y:array[0..31] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			128+(8*0), 128+(8*1), 128+(8*2), 128+(8*3), 128+(8*4), 128+(8*5), 128+(8*6), 128+(8*7),
      512+(8*0), 512+(8*1), 512+(8*2), 512+(8*3), 512+(8*4), 512+(8*5), 512+(8*6), 512+(8*7),
      640+(8*0), 640+(8*1), 640+(8*2), 640+(8*3), 640+(8*4), 640+(8*5), 640+(8*6), 640+(8*7));
var
  memoria_temp:array[0..$ffff] of byte;
begin
llamadas_maquina.bucle_general:=pinballaction_principal;
llamadas_maquina.reset:=reset_pinballaction;
llamadas_maquina.scanlines:=256;
iniciar_pinballaction:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(4000000);
z80_0.change_ram_calls(pinballaction_getbyte,pinballaction_putbyte);
if not(roms_load(@memoria,pinballaction_rom)) then exit;
//Sound CPU
z80_1:=cpu_z80.create(3072000);
z80_1.change_ram_calls(snd_getbyte,snd_putbyte);
z80_1.change_io_calls(nil,snd_outbyte);
z80_1.init_sound(pinballaction_sound_update);
timers.init(z80_1.numero_cpu,3072000/(2*60),pbaction_sound_irq,nil,true);
if not(roms_load(@mem_snd,pinballaction_sound)) then exit;
//Sound Chip
ay8910_0:=ay8910_chip.create(1500000,AY8910);
ay8910_1:=ay8910_chip.create(1500000,AY8910);
ay8910_2:=ay8910_chip.create(1500000,AY8910);
//convertir chars
if not(roms_load(@memoria_temp,pinballaction_chars)) then exit;
init_gfx(0,8,8,$400);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,$400*0*8*8,$400*1*8*8,$400*2*8*8);
convert_gfx(0,0,@memoria_temp,@psd_x,@psd_y,true,false);
//tiles
if not(roms_load(@memoria_temp,pinballaction_tiles)) then exit;
init_gfx(1,8,8,$800);
gfx_set_desc_data(4,0,8*8,$800*0*8*8,$800*1*8*8,$800*2*8*8,$800*3*8*8);
convert_gfx(1,0,@memoria_temp,@psd_x,@psd_y,true,false);
//convertir sprites
if not(roms_load(@memoria_temp,pinballaction_sprites)) then exit;
init_gfx(2,16,16,$100);
gfx[2].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,$100*0*8*32,$100*1*8*32,$100*2*8*32);
convert_gfx(2,0,@memoria_temp,@psd_x,@psd_y,true,false);
//convertir sprites double
init_gfx(3,32,32,$20);
gfx[3].trans[0]:=true;
gfx_set_desc_data(3,0,128*8,$40*0*8*128,$40*1*8*128,$40*2*8*128);
convert_gfx(3,0,@memoria_temp[$1000],@psd_x,@psd_y,true,false);
//DIP
init_dips(1,pinballaction_dipa,$40);
init_dips(2,pinballaction_dipb,0);
iniciar_pinballaction:=true;
end;

end.
