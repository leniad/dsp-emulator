unit karatechamp_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,ay_8910,timer_engine,dac;

function karatechamp_iniciar:boolean;

implementation

const
    karatechamp_rom:array[0..5] of tipo_roms=(
    (n:'b014.bin';l:$2000;p:0;crc:$0000d1a0),(n:'b015.bin';l:$2000;p:$2000;crc:$03fae67e),
    (n:'b016.bin';l:$2000;p:$4000;crc:$3b6e1d08),(n:'b017.bin';l:$2000;p:$6000;crc:$c1848d1a),
    (n:'b018.bin';l:$2000;p:$8000;crc:$b824abc7),(n:'b019.bin';l:$2000;p:$a000;crc:$3b487a46));
    karatechamp_sound:array[0..6] of tipo_roms=(
    (n:'b026.bin';l:$2000;p:0;crc:$999ed2c7),(n:'b025.bin';l:$2000;p:$2000;crc:$33171e07),
    (n:'b024.bin';l:$2000;p:$4000;crc:$910b48b9),(n:'b023.bin';l:$2000;p:$6000;crc:$47f66aac),
    (n:'b022.bin';l:$2000;p:$8000;crc:$5928e749),(n:'b021.bin';l:$2000;p:$a000;crc:$ca17e3ba),
    (n:'b020.bin';l:$2000;p:$c000;crc:$ada4f2cd));
    karatechamp_char:array[0..1] of tipo_roms=(
    (n:'b000.bin';l:$2000;p:0;crc:$a4fa98a1),(n:'b001.bin';l:$2000;p:$4000;crc:$fea09f7c));
    karatechamp_sprt:array[0..11] of tipo_roms=(
    (n:'b013.bin';l:$2000;p:0;crc:$eaad4168),(n:'b004.bin';l:$2000;p:$2000;crc:$10a47e2d),
    (n:'b012.bin';l:$2000;p:$4000;crc:$b4842ea9),(n:'b003.bin';l:$2000;p:$6000;crc:$8cd166a5),
    (n:'b011.bin';l:$2000;p:$8000;crc:$4cbd3aa3),(n:'b002.bin';l:$2000;p:$a000;crc:$6be342a6),
    (n:'b007.bin';l:$2000;p:$c000;crc:$cb91d16b),(n:'b010.bin';l:$2000;p:$e000;crc:$489c9c04),
    (n:'b006.bin';l:$2000;p:$10000;crc:$7346db8a),(n:'b009.bin';l:$2000;p:$12000;crc:$b78714fc),
    (n:'b005.bin';l:$2000;p:$14000;crc:$b2557102),(n:'b008.bin';l:$2000;p:$16000;crc:$c85aba0e));
    karatechamp_pal:array[0..2] of tipo_roms=(
    (n:'br27';l:$100;p:0;crc:$f683c54a),(n:'br26';l:$100;p:$100;crc:$3ddbb6c4),
    (n:'br25';l:$100;p:$200;crc:$ba4a5651));
    //Dip
    karatechamp_dip:array [0..6] of def_dip2=(
    (mask:3;name:'Coin A';number:4;val4:(0,1,3,2);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
    (mask:$c;name:'Coin B';number:4;val4:(0,4,$c,8);name4:('3C 1C','2C 1C','1C 1C','1C 2C')),
    (mask:$10;name:'Difficulty';number:2;val2:(0,$10);name2:('Hard','Normal')),
    (mask:$20;name:'Free Play';number:2;val2:($20,0);name2:('Off','On')),
    (mask:$40;name:'Demo Sounds';number:2;val2:($40,0);name2:('Off','On')),
    (mask:$80;name:'Cabinet';number:2;val2:(0,$80);name2:('Upright','Cocktail')),());

var
  sound_latch:byte;
  nmi_enable,nmi_enable_sound:boolean;

procedure update_video_karatechamp;
var
    x,y,atrib,color:byte;
    f,nchar:word;
begin
for f:=0 to $3ff do begin
 if gfx[0].buffer[f] then begin
    x:=31-(f div 32);
    y:=f mod 32;
    atrib:=memoria[$e400+f];
    color:=atrib shr 3;
    nchar:=memoria[$e000+f]+((atrib and $7) shl 8);
    put_gfx(x*8,y*8,nchar,(color shl 2)+128,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,2);
for f:=0 to $3f do begin
  atrib:=memoria[$ea02+(f*4)];
  nchar:=memoria[$ea01+(f*4)]+((atrib and $10) shl 4);
  color:=(atrib and $f) shl 2;
  x:=memoria[$ea00+(f*4)]-9;
  y:=memoria[$ea03+(f*4)]-8;
  put_gfx_sprite(nchar,color,(atrib and $80)<>0,false,1+((atrib and $60) shr 5));
  actualiza_gfx_sprite(x,y,2,1);
end;
actualiza_trozo_final(16,0,224,256,2);
end;

procedure eventos_karatechamp;
begin
if event.arcade then begin
  //SYS
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or 1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or 2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $fb) else marcade.in0:=(marcade.in0 or 4);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $f7) else marcade.in0:=(marcade.in0 or 8);
  //P1
  if arcade_input.right[0] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.left[0] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.up[0] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.down[0] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.right[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  if arcade_input.left[1] then marcade.in1:=marcade.in1 and $df else marcade.in1:=marcade.in1 or $20;
  if arcade_input.up[1] then marcade.in1:=marcade.in1 and $bf else marcade.in1:=marcade.in1 or $40;
  if arcade_input.down[1] then marcade.in1:=marcade.in1 and $7f else marcade.in1:=marcade.in1 or $80;
end;
end;

procedure karatechamp_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to 255 do begin
    eventos_karatechamp;
    if f=242 then begin
      if nmi_enable then z80_0.change_nmi(ASSERT_LINE);
      update_video_karatechamp;
    end;
    //Main
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //Sound
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
  end;
  video_sync;
end;
end;

function karatechamp_getbyte(direccion:word):byte;
begin
  karatechamp_getbyte:=memoria[direccion];
end;

procedure karatechamp_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$bfff:; //ROM
    $c000..$dfff,$ea00..$ffff:memoria[direccion]:=valor;
    $e000..$e7ff:if memoria[direccion]<>valor then begin
                    memoria[direccion]:=valor;
                    gfx[0].buffer[direccion and $3ff]:=true;
                 end;
end;
end;

function karatechamp_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
  $80:karatechamp_inbyte:=marcade.dswa;
  $90:karatechamp_inbyte:=marcade.in1;
  $98:karatechamp_inbyte:=$ff;
  $a0:karatechamp_inbyte:=marcade.in0;
  $a8:;
end;
end;

procedure karatechamp_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $80:main_screen.flip_main_screen:=(valor and 1)<>0;
  $81:begin
        nmi_enable:=valor<>0;
        if not(nmi_enable) then z80_0.change_nmi(CLEAR_LINE);
      end;
  $a8:begin
        sound_latch:=valor;
        z80_1.change_irq(ASSERT_LINE);
      end;
end;
end;

//sound
function karatechamp_getbyte_snd(direccion:word):byte;
begin
  karatechamp_getbyte_snd:=mem_snd[direccion];
end;

procedure karatechamp_putbyte_snd(direccion:word;valor:byte);
begin
case direccion of
    0..$dfff:; //ROM
    $e000..$e2ff:mem_snd[direccion]:=valor;
end;
end;

function karatechamp_inbyte_snd(puerto:word):byte;
begin
if (puerto and $ff)=6 then begin
  karatechamp_inbyte_snd:=sound_latch;
  z80_1.change_irq(CLEAR_LINE);
end;
end;

procedure karatechamp_outbyte_snd(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  0:ay8910_0.write(valor);
  1:ay8910_0.control(valor);
  2:ay8910_1.write(valor);
  3:ay8910_1.control(valor);
  4:dac_0.data8_w(valor);
  5:begin
      nmi_enable_sound:=(valor and $80)<>0;
      if not(nmi_enable_sound) then z80_1.change_nmi(CLEAR_LINE);
    end;
end;
end;

procedure karatechamp_snd_irq;
begin
  if nmi_enable_sound then z80_1.change_nmi(ASSERT_LINE);
end;

procedure karatechamp_sound_update;
begin
  ay8910_0.update;
  ay8910_1.update;
  dac_0.update;
end;

//Main
procedure karatechamp_reset;
begin
z80_0.reset;
z80_1.reset;
ay8910_0.reset;
ay8910_1.reset;
dac_0.reset;
frame_main:=z80_0.tframes;
frame_snd:=z80_1.tframes;
nmi_enable:=false;
nmi_enable_sound:=false;
sound_latch:=0;
marcade.in0:=$ff;
marcade.in1:=$ff;
end;

function karatechamp_iniciar:boolean;
const
  ps_x:array[0..15] of dword=(0,1,2,3,4,5,6,7,
		$2000*8+0,$2000*8+1,$2000*8+2,$2000*8+3,$2000*8+4,$2000*8+5,$2000*8+6,$2000*8+7);
  ps_y:array[0..15] of dword=(0*8,1*8,2*8,3*8,4*8,5*8,6*8,7*8,
	8*8,9*8,10*8,11*8,12*8,13*8,14*8, 15*8);
var
  colores:tpaleta;
  f:word;
  memoria_temp:array[0..$17fff] of byte;
begin
llamadas_maquina.bucle_general:=karatechamp_principal;
llamadas_maquina.reset:=karatechamp_reset;
karatechamp_iniciar:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,false,true);
iniciar_video(224,256);
//Main CPU
z80_0:=cpu_z80.create(12000000 div 4,256);
z80_0.change_ram_calls(karatechamp_getbyte,karatechamp_putbyte);
z80_0.change_io_calls(karatechamp_inbyte,karatechamp_outbyte);
if not(roms_load(@memoria,karatechamp_rom)) then exit;
//Sound Chip
z80_1:=cpu_z80.create(12000000 div 4,256);
z80_1.change_ram_calls(karatechamp_getbyte_snd,karatechamp_putbyte_snd);
z80_1.change_io_calls(karatechamp_inbyte_snd,karatechamp_outbyte_snd);
z80_1.init_sound(karatechamp_sound_update);
if not(roms_load(@mem_snd,karatechamp_sound)) then exit;
//IRQ Sound CPU
timers.init(z80_1.numero_cpu,3000000/125,karatechamp_snd_irq,nil,true);
//Sound Chips
ay8910_0:=ay8910_chip.create(12000000 div 12,AY8910);
ay8910_1:=ay8910_chip.create(12000000 div 12,AY8910);
dac_0:=dac_chip.create;
//cargar chars
if not(roms_load(@memoria_temp,karatechamp_char)) then exit;
init_gfx(0,8,8,$800);
gfx_set_desc_data(2,0,8*8,$4000*8,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,true,false);
//cargar sprites (3 bancos)
if not(roms_load(@memoria_temp,karatechamp_sprt)) then exit;
init_gfx(1,16,16,$200*3);
gfx[1].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,$c000*8,0);
convert_gfx(1,0,@memoria_temp[$8000],@ps_x,@ps_y,true,false);
init_gfx(2,16,16,$200);
gfx[2].trans[0]:=true;
convert_gfx(2,0,@memoria_temp[$4000],@ps_x,@ps_y,true,false);
init_gfx(3,16,16,$200);
gfx[3].trans[0]:=true;
convert_gfx(3,0,@memoria_temp[$0],@ps_x,@ps_y,true,false);
//paleta de colores
if not(roms_load(@memoria_temp,karatechamp_pal)) then exit;
for f:=0 to 255 do begin
		colores[f].r:=pal4bit(memoria_temp[f]);
		colores[f].g:=pal4bit(memoria_temp[f+$100]);
		colores[f].b:=pal4bit(memoria_temp[f+$200]);
end;
set_pal(colores,$100);
//DIP
marcade.dswa:=$3f;
marcade.dswa_val2:=@karatechamp_dip;
//Final
karatechamp_iniciar:=true;
end;

end.
