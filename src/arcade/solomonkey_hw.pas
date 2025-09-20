unit solomonkey_hw;
interface

uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,ay_8910,gfx_engine,rom_engine,
     pal_engine,sound_engine,timer_engine;

function iniciar_solomon:boolean;

implementation

const
        solomon_rom:array[0..2] of tipo_roms=(
        (n:'6.3f';l:$4000;p:0;crc:$645eb0f3),(n:'7.3h';l:$8000;p:$4000;crc:$1bf5c482),
        (n:'8.3jk';l:$8000;p:$c000;crc:$0a6cdefc));
        solomon_snd_rom:tipo_roms=(n:'1.3jk';l:$4000;p:0;crc:$fa6e562e);
        solomon_chars:array[0..1] of tipo_roms=(
        (n:'12.3t';l:$8000;p:0;crc:$b371291c),(n:'11.3r';l:$8000;p:$8000;crc:$6f94d2af));
        solomon_sprites:array[0..3] of tipo_roms=(
        (n:'2.5lm';l:$4000;p:0;crc:$80fa2be3),(n:'3.6lm';l:$4000;p:$4000;crc:$236106b4),
        (n:'4.7lm';l:$4000;p:$8000;crc:$088fe5d9),(n:'5.8lm';l:$4000;p:$c000;crc:$8366232a));
        solomon_tiles:array[0..1] of tipo_roms=(
        (n:'10.3p';l:$8000;p:0;crc:$8310c2a1),(n:'9.3m';l:$8000;p:$8000;crc:$ab7e6c42));
        //Dip
        solomon_dip_a:array [0..5] of def_dip2=(
        (mask:1;name:'Demo Sound';number:2;val2:(1,0);name2:('Off','On')),
        (mask:2;name:'Cabinet';number:2;val2:(2,0);name2:('Upright','Cocktail')),
        (mask:$c;name:'Lives';number:4;val4:($c,0,8,4);name4:('2','3','4','5')),
        (mask:$30;name:'Coin B';number:4;val4:($20,0,$10,$30);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),
        (mask:$c0;name:'Coin A';number:4;val4:($80,0,$40,$c0);name4:('2C 1C','1C 1C','1C 2C','1C 3C')),());
        solomon_dip_b:array [0..4] of def_dip2=(
        (mask:3;name:'Difficulty';number:4;val4:(2,0,1,3);name4:('Easy','Normal','Harder','Difficult')),
        (mask:$c;name:'Time Speed';number:4;val4:(8,0,4,$c);name4:('Slow','Normal','Faster','Fastest')),
        (mask:$10;name:'Extra';number:2;val2:(0,$10);name2:('Normal','Difficult')),
        (mask:$e0;name:'Bonus Life';number:8;val8:(0,$80,$40,$c0,$20,$a0,$60,$e0);name8:('30K 200K 500K','100K 300K 800K','30K 200K','100K 300K','30K','100K','200K','None')),());

var
 sound_latch:byte;
 nmi_enable:boolean;

procedure update_video_solomon;
var
  f,color,nchar,x,y:word;
  atrib:byte;
begin
for f:=$3ff downto 0 do begin
  //tiles
  atrib:=memoria[$d800+f];
  color:=(atrib and $70) shr 4;
  if (gfx[1].buffer[f] or buffer_color[color+8]) then begin
    x:=(f and $1f) shl 3;
    y:=(f shr 5) shl 3;
    nchar:=memoria[$dc00+f]+((atrib and 7) shl 8);
    put_gfx_flip(x,y,nchar,(color shl 4)+128,1,1,(atrib and $80)<>0,(atrib and 8)<>0);
    gfx[1].buffer[f]:=false;
  end;
  //Chars
  atrib:=memoria[$d000+f];
  color:=(atrib and $70) shr 4;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=(f and $1f) shl 3;
    y:=(f shr 5) shl 3;
    nchar:=memoria[$d400+f]+((atrib and 7) shl 8);
    put_gfx_trans(x,y,nchar,color shl 4,2,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,3);
actualiza_trozo(0,0,256,256,2,0,0,256,256,3);
//sprites
for f:=$1f downto 0 do begin
    atrib:=memoria[$e001+(f*4)];
    nchar:=memoria[$e000+(f*4)]+16*(atrib and $10);
		color:=(atrib and $e) shl 3;
    x:=memoria[$e003+(f*4)];
		y:=241-memoria[$e002+(f*4)];
    put_gfx_sprite(nchar,color,(atrib and $40)<>0,(atrib and $80)<>0,2);
    actualiza_gfx_sprite(x,y,3,2);
end;
actualiza_trozo_final(0,16,256,224,3);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_solomon;
begin
if event.arcade then begin
  //p1
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10)else marcade.in0:=(marcade.in0 and $ef);
  if arcade_input.but1[0] then marcade.in0:=(marcade.in0 or $20) else marcade.in0:=(marcade.in0 and $df);
  //p2
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10)else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.but1[1] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  //system
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure solomon_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    if f=240 then begin
        if nmi_enable then z80_0.change_nmi(PULSE_LINE);
        update_video_solomon;
    end;
    //main
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //snd
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
  end;
  eventos_solomon;
  video_sync;
end;
end;

//Main
function solomon_getbyte(direccion:word):byte;
var
  z80_0_reg:npreg_z80;
begin
case direccion of
  0..$e07f,$f000..$ffff:solomon_getbyte:=memoria[direccion];
  $e400..$e5ff:solomon_getbyte:=buffer_paleta[direccion and $1ff];
  $e600:solomon_getbyte:=marcade.in0;
  $e601:solomon_getbyte:=marcade.in1;
  $e602:solomon_getbyte:=marcade.in2;
  $e603:begin
          z80_0_reg:=z80_0.get_internal_r;
          if (z80_0_reg.pc=$4cf0) then solomon_getbyte:=z80_0_reg.bc.w and 8 //proteccion ???
            else solomon_getbyte:=0;
        end;
  $e604:solomon_getbyte:=marcade.dswa;
  $e605:solomon_getbyte:=marcade.dswb;
  $e606:;
end;
end;

procedure solomon_putbyte(direccion:word;valor:byte);

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
  case dir of
    0..$7f:buffer_color[dir shr 4]:=true;
    $80..$ff:buffer_color[((dir shr 4) and 7)+8]:=true;
  end;
end;

begin
case direccion of
   0..$bfff:; //ROM
   $c000..$cfff,$e000..$e07f:memoria[direccion]:=valor;
   $d000..$d7ff:if (valor<>memoria[direccion]) then begin
                    gfx[0].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                end;
   $d800..$dfff:if (valor<>memoria[direccion]) then begin
                    gfx[1].buffer[direccion and $3ff]:=true;
                    memoria[direccion]:=valor;
                end;
   $e400..$e5ff:if buffer_paleta[direccion and $1ff]<>valor then begin
                    buffer_paleta[direccion and $1ff]:=valor;
                    cambiar_color(direccion and $1fe);
                end;
   $e600:nmi_enable:=valor<>0;
   $e604:main_screen.flip_main_screen:=(valor and 1)<>0;
   $e800:begin
            sound_latch:=valor;
            z80_1.change_nmi(PULSE_LINE);
         end;
   $f000..$ffff:;
end;
end;

//Sound
function solomon_snd_getbyte(direccion:word):byte;
begin
case direccion of
  0..$47ff:solomon_snd_getbyte:=mem_snd[direccion];
  $8000:solomon_snd_getbyte:=sound_latch;
end;
end;

procedure solomon_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$3fff:;
  $4000..$47ff:mem_snd[direccion]:=valor;
end;
end;

procedure solomon_snd_outbyte(puerto:word;valor:byte);
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

procedure solomon_snd_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

procedure solomon_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
  ay8910_2.update;
end;

//Main
procedure reset_solomon;
begin
 z80_0.reset;
 z80_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 ay8910_0.reset;
 ay8910_1.reset;
 ay8910_2.reset;
 reset_video;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 sound_latch:=0;
 nmi_enable:=true;
end;

function iniciar_solomon:boolean;
var
    memoria_temp:array[0..$13fff] of byte;
const
    pc_x:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
    pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
    ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7);
    ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
begin
llamadas_maquina.bucle_general:=solomon_principal;
llamadas_maquina.reset:=reset_solomon;
iniciar_solomon:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(4000000,256);
z80_0.change_ram_calls(solomon_getbyte,solomon_putbyte);
if not(roms_load(@memoria_temp,solomon_rom)) then exit;
copymemory(@memoria,@memoria_temp,$4000);
copymemory(@memoria[$4000],@memoria_temp[$8000],$4000);
copymemory(@memoria[$8000],@memoria_temp[$4000],$4000);
copymemory(@memoria[$f000],@memoria_temp[$c000],$1000);
//Sound CPU
z80_1:=cpu_z80.create(3072000,256);
z80_1.change_ram_calls(solomon_snd_getbyte,solomon_snd_putbyte);
z80_1.change_io_calls(nil,solomon_snd_outbyte);
z80_1.init_sound(solomon_sound_update);
timers.init(z80_1.numero_cpu,3072000/(60*2),solomon_snd_irq,nil,true);
if not(roms_load(@mem_snd,solomon_snd_rom)) then exit;
//Sound Chips
ay8910_0:=ay8910_chip.create(1500000,AY8910);
ay8910_1:=ay8910_chip.create(1500000,AY8910);
ay8910_2:=ay8910_chip.create(1500000,AY8910);
//convertir chars
if not(roms_load(@memoria_temp,solomon_chars)) then exit;
init_gfx(0,8,8,$800);
gfx[0].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//tiles
if not(roms_load(@memoria_temp,solomon_tiles)) then exit;
init_gfx(1,8,8,$800);
convert_gfx(1,0,@memoria_temp,@pc_x,@pc_y,false,false);
//convertir sprites
if not(roms_load(@memoria_temp,solomon_sprites)) then exit;
init_gfx(2,16,16,$400);
gfx[2].trans[0]:=true;
gfx_set_desc_data(4,0,32*8,0,512*32*8,2*512*32*8,3*512*32*8);
convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
//DIP
marcade.dswa:=2;
marcade.dswa_val2:=@solomon_dip_a;
marcade.dswb:=0;
marcade.dswb_val2:=@solomon_dip_b;
//final
reset_solomon;
iniciar_solomon:=true;
end;

end.
