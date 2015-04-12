unit starforce_hw; //Senjyo

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,z80pio,z80daisy,main_engine,controls_engine,gfx_engine,sn_76496,
     z80ctc,rom_engine,pal_engine,sound_engine;

procedure Cargar_starforce;
procedure starforce_principal;
function iniciar_starforce:boolean;
procedure reset_starforce;
procedure cerrar_starforce;
//Main CPU
function starforce_getbyte(direccion:word):byte;
procedure starforce_putbyte(direccion:word;valor:byte);
//Sound CPU
function snd_getbyte(direccion:word):byte;
procedure snd_putbyte(direccion:word;valor:byte);
function snd_inbyte(puerto:word):byte;
procedure snd_outbyte(valor:byte;puerto:word);
procedure starforce_sound_update;
//PIO
function pio_read_porta:byte;
//PIO+CTC INT
procedure pio_int_main(state:byte);

const
        starforce_rom:array[0..2] of tipo_roms=(
        (n:'starforc.3';l:$4000;p:0;crc:$8ba27691),(n:'starforc.2';l:$4000;p:$4000;crc:$0fc4d2d6),());
        starforce_fg:array[0..3] of tipo_roms=(
        (n:'starforc.7';l:$1000;p:0;crc:$f4803339),(n:'starforc.8';l:$1000;p:$1000;crc:$96979684),
        (n:'starforc.9';l:$1000;p:$2000;crc:$eead1d5c),());
        starforce_bg1:array[0..3] of tipo_roms=(
        (n:'starforc.15';l:$2000;p:0;crc:$c3bda12f),(n:'starforc.14';l:$2000;p:$2000;crc:$9e9384fe),
        (n:'starforc.13';l:$2000;p:$4000;crc:$84603285),());
        starforce_bg2:array[0..3] of tipo_roms=(
        (n:'starforc.12';l:$2000;p:0;crc:$fdd9e38b),(n:'starforc.11';l:$2000;p:$2000;crc:$668aea14),
        (n:'starforc.10';l:$2000;p:$4000;crc:$c62a19c1),());
        starforce_bg3:array[0..3] of tipo_roms=(
        (n:'starforc.18';l:$1000;p:0;crc:$6455c3ad),(n:'starforc.17';l:$1000;p:$1000;crc:$68c60d0f),
        (n:'starforc.16';l:$1000;p:$2000;crc:$ce20b469),());
        starforce_sound:tipo_roms=(n:'starforc.1';l:$2000;p:0;crc:$2735bb22);
        starforce_sprites:array[0..3] of tipo_roms=(
        (n:'starforc.6';l:$4000;p:0;crc:$5468a21d),(n:'starforc.5';l:$4000;p:$4000;crc:$f71717f8),
        (n:'starforc.4';l:$4000;p:$8000;crc:$dd9d68a4),());
        //DIP
        starforce_dipa:array [0..5] of def_dip=(
        (mask:$3;name:'Coin A';number:4;dip:((dip_val:$1;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$2;dip_name:'1C 2C'),(dip_val:$3;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Coin B';number:4;dip:((dip_val:$4;dip_name:'2C 1C'),(dip_val:$0;dip_name:'1C 1C'),(dip_val:$8;dip_name:'1C 2C'),(dip_val:$c;dip_name:'1C 3C'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Lives';number:4;dip:((dip_val:$30;dip_name:'2'),(dip_val:$0;dip_name:'3'),(dip_val:$10;dip_name:'4'),(dip_val:$20;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Cabinet';number:2;dip:((dip_val:$40;dip_name:'Upright'),(dip_val:$0;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Demo Sounds';number:2;dip:((dip_val:$80;dip_name:'On'),(dip_val:$0;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        starforce_dipb:array [0..2] of def_dip=(
        (mask:$7;name:'Bonus Life';number:8;dip:((dip_val:$0;dip_name:'50k 200k 500k'),(dip_val:$1;dip_name:'100k 300k 800k'),(dip_val:$2;dip_name:'50k 200k'),(dip_val:$3;dip_name:'100k 300k'),(dip_val:$4;dip_name:'50k'),(dip_val:$5;dip_name:'100k'),(dip_val:$6;dip_name:'200k'),(dip_val:$7;dip_name:'None'),(),(),(),(),(),(),(),())),
        (mask:$38;name:'Difficulty';number:6;dip:((dip_val:$0;dip_name:'Easyest'),(dip_val:$8;dip_name:'Easy'),(dip_val:$10;dip_name:'Medium'),(dip_val:$18;dip_name:'Difficult'),(dip_val:$20;dip_name:'Hard'),(dip_val:$28;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),())),());
        starforce_dipc:array [0..1] of def_dip=(
        (mask:$1;name:'Inmunnity';number:2;dip:((dip_val:$1;dip_name:'On'),(dip_val:$0;dip_name:'Off'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
var
 x1,x2,x3:word;
 y1,y2,y3,sound_latch:byte;

implementation

procedure Cargar_starforce;
begin
llamadas_maquina.iniciar:=iniciar_starforce;
llamadas_maquina.bucle_general:=starforce_principal;
llamadas_maquina.cerrar:=cerrar_starforce;
llamadas_maquina.reset:=reset_starforce;
end;

function iniciar_starforce:boolean;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
  pbs_x:array[0..31] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
			8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7,
			32*8+0, 32*8+1, 32*8+2, 32*8+3, 32*8+4, 32*8+5, 32*8+6, 32*8+7,
			40*8+0, 40*8+1, 40*8+2, 40*8+3, 40*8+4, 40*8+5, 40*8+6, 40*8+7);
  pbs_y:array[0..31] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8,
			64*8, 65*8, 66*8, 67*8, 68*8, 69*8, 70*8, 71*8,
			80*8, 81*8, 82*8, 83*8, 84*8, 85*8, 86*8, 87*8);
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
var
  memoria_temp:array[0..$ffff] of byte;
begin
iniciar_starforce:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256,false,true);
//bg3
screen_init(2,512,256);
screen_mod_scroll(2,512,256,511,256,256,255);
//chars
screen_init(3,256,256,true);
//bg2
screen_init(4,512,256,true);
screen_mod_scroll(4,512,256,511,256,256,255);
//bg1
screen_init(5,512,256,true);
screen_mod_scroll(5,512,256,511,256,256,255);
iniciar_video(224,256);
//Main CPU
main_z80:=cpu_z80.create(4000000,$100);
main_z80.change_ram_calls(starforce_getbyte,starforce_putbyte);
//Sound CPU
snd_z80:=cpu_z80.create(2000000,$100);
snd_z80.daisy:=true;
snd_z80.change_ram_calls(snd_getbyte,snd_putbyte);
snd_z80.change_io_calls(snd_inbyte,snd_outbyte);
snd_z80.init_sound(starforce_sound_update);
//Daisy Chain PIO+CTC
z80ctc_init(0,snd_z80.numero_cpu,2000000,snd_z80.clock,NOTIMER_2,pio_int_main,z80ctc_trg01_w);
z80pio_init(0,pio_int_main,pio_read_porta);
z80daisy_init(Z80_PIO_TYPE,Z80_CTC_TYPE);
//Chip CPU
sn_76496_0:=sn76496_chip.Create(2000000);
sn_76496_1:=sn76496_chip.Create(2000000);
sn_76496_2:=sn76496_chip.Create(2000000);
//cargar roms
if not(cargar_roms(@memoria[0],@starforce_rom[0],'starforc.zip',0)) then exit;
//cargar sonido
if not(cargar_roms(@mem_snd[0],@starforce_sound,'starforc.zip',1)) then exit;
//convertir chars
if not(cargar_roms(@memoria_temp[0],@starforce_fg[0],'starforc.zip',0)) then exit;
init_gfx(0,8,8,512);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,0,512*8*8,2*512*8*8);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//big sprites
if not(cargar_roms(@memoria_temp[0],@starforce_sprites[0],'starforc.zip',0)) then exit;
init_gfx(2,32,32,128);
gfx[2].trans[0]:=true;
gfx_set_desc_data(3,0,128*8,0,128*32*32,2*128*32*32);
convert_gfx(2,0,@memoria_temp[0],@pbs_x[0],@pbs_y[0],true,false);
//sprites
init_gfx(1,16,16,512);
gfx[1].trans[0]:=true;
gfx_set_desc_data(3,0,32*8,0,512*16*16,2*512*16*16);
convert_gfx(1,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
//bg1
if not(cargar_roms(@memoria_temp[0],@starforce_bg1[0],'starforc.zip',0)) then exit;
init_gfx(3,16,16,768);
gfx[3].trans[0]:=true;
gfx_set_desc_data(3,3,32*8,0,256*16*16,2*256*16*16);
convert_gfx(3,0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
//bg2
if not(cargar_roms(@memoria_temp[0],@starforce_bg2[0],'starforc.zip',0)) then exit;
convert_gfx(3,256*16*16,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
//bg3
if not(cargar_roms(@memoria_temp[0],@starforce_bg3[0],'starforc.zip',0)) then exit;
gfx_set_desc_data(3,3,32*8,0,128*16*16,2*128*16*16);
convert_gfx(3,512*16*16,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
//DIP
marcade.dswa:=$c0;
marcade.dswa_val:=@starforce_dipa;
marcade.dswb:=0;
marcade.dswb_val:=@starforce_dipb;
marcade.dswc:=0;
marcade.dswc_val:=@starforce_dipc;

reset_starforce;
iniciar_starforce:=true;
end;

procedure cerrar_starforce;
begin
main_z80.free;
snd_z80.free;
z80pio_close(0);
z80ctc_close(0);
sn_76496_0.Free;
sn_76496_1.Free;
sn_76496_2.Free;
close_audio;
close_video;
end;

procedure reset_starforce;
begin
 z80pio_reset(0);
 z80ctc_reset(0);
 sn_76496_0.reset;
 sn_76496_1.reset;
 sn_76496_2.reset;
 main_z80.reset;
 snd_z80.reset;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
end;

procedure draw_sprites(prioridad:byte);inline;
var
  nchar,x,y,color,f:word;
  atrib:byte;
begin
for f:=$1f downto 0 do begin
  atrib:=memoria[$9801+(f*4)];
  if ((atrib and $30) shr 4)=prioridad then begin
    nchar:=memoria[$9800+(f*4)];
    y:=memoria[$9803+(f*4)];
    x:=memoria[$9802+(f*4)];
    color:=(atrib and 7) shl 3+320;
    if (nchar and $c0)<>$c0 then begin
      put_gfx_sprite(nchar,color,(atrib and $80)<>0,(atrib and $40)<>0,1);
      actualiza_gfx_sprite(x,y,1,1);
    end else begin
      put_gfx_sprite(nchar and $7f,color,(atrib and $80)<>0,(atrib and $40)<>0,2);
      actualiza_gfx_sprite(x,y,1,2);
    end;
  end;
end;
end;

procedure update_video_starforce;inline;
var
  f,color,nchar:word;
  x,y,atrib:byte;
const
  color_code:array[0..7] of byte=(0,2,4,6,1,3,5,7);
begin
for f:=0 to $1ff do begin
      //bg3
      atrib:=memoria[$a000+f];
      color:=(atrib and $e0) shr 5;
      if (gfx[3].buffer[f] or buffer_color[color+8])then begin
        x:=31-(f div 16);
        y:=f mod 16;
        nchar:=atrib+512;
        put_gfx(x*16,y*16,nchar,(color shl 3)+192,2,3);
        gfx[3].buffer[f]:=false;
      end;
      //bg2
      atrib:=memoria[$a800+f];
      color:=(atrib and $e0) shr 5;
      if (gfx[4].buffer[f] or buffer_color[color+$10]) then begin
        x:=31-(f div 16);
        y:=f mod 16;
        nchar:=atrib+256;
        put_gfx_trans(x*16,y*16,nchar,(color shl 3)+128,4,3);
        gfx[4].buffer[f]:=false;
      end;
      //bg1
      nchar:=memoria[$b000+f];
      color:=color_code[((nchar and $e0) shr 5)];
      if (gfx[5].buffer[f] or buffer_color[color+$18]) then begin
        x:=31-(f div 16);
        y:=f mod 16;
        put_gfx_trans(x*16,y*16,nchar,(color shl 3)+64,5,3);
        gfx[5].buffer[f]:=false;
      end;
end;
//chars
for f:=0 to $3ff do begin
    atrib:=memoria[$9400+f];
    color:=atrib and $7;
    if (gfx[0].buffer[f] or buffer_color[color]) then begin
      x:=31-(f div 32);
      y:=f mod 32;
      nchar:=memoria[$9000+f]+((atrib and $10) shl 4);
      put_gfx_trans(x*8,y*8,nchar,color shl 3,3,0);
      gfx[0].buffer[f]:=false;
    end;
end;
draw_sprites(0);
scroll_x_y(2,1,x3,y3);
draw_sprites(1);
scroll_x_y(4,1,x2,y1);
draw_sprites(2);
scroll_x_y(5,1,x1,y1);
draw_sprites(3);
actualiza_trozo(0,0,256,256,3,0,0,256,256,1);
actualiza_trozo_final(16,0,224,256,1);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_starforce;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 or 4) else marcade.in0:=(marcade.in0 and $fb);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  //P2
  if arcade_input.up[1] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[1] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.left[1] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.right[1] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  //SYS
  if arcade_input.coin[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.coin[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.start[0] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.start[1] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
end;
end;

procedure starforce_principal;
var
  frame_m,frame_s:single;
  f:byte;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to $ff do begin
      //Main CPU
      main_z80.run(frame_m);
      frame_m:=frame_m+main_z80.tframes-main_z80.contador;
      //Sound CPU
      snd_z80.run(frame_s);
      frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
      if f=239 then begin
        main_z80.pedir_irq:=ASSERT_LINE;
        update_video_starforce;
      end;
  end;
  eventos_starforce;
  video_sync;
end;
end;

function starforce_getbyte(direccion:word):byte;
begin
case direccion of
  0..$987f,$9e00..$9e3f,$a000..$bbff:starforce_getbyte:=memoria[direccion];
  $9c00..$9dff:starforce_getbyte:=buffer_paleta[direccion and $1ff];
  $d000:starforce_getbyte:=marcade.in0;
  $d001:starforce_getbyte:=marcade.in1;
  $d002:starforce_getbyte:=marcade.in2;
  $d003:starforce_getbyte:=marcade.dswc;   //0 --> inmunidad!!
  $d004:starforce_getbyte:=marcade.dswa;
  $d005:starforce_getbyte:=marcade.dswb;
end;
end;

procedure cambiar_color(numero:word);inline;
var
  i,c,data:byte;
  color:tcolor;
begin
  data:=buffer_paleta[numero and $1ff];
  i:= (data shr 6) and $03;
	c:=(data shl 2) and $0c;
	if (c<>0) then c:=c or i;
	color.r:=c*$11;
	c:=(data shr 0) and $0c;
	if (c<>0) then c:=c or i;
	color.g:=c*$11;
	c:= (data shr 2) and $0c;
	if (c<>0) then c:=c or i;
	color.b:=c*$11;
  set_pal_color(color,@paleta[numero]);
  case numero of
    0..63:buffer_color[numero shr 3]:=true;
    64..127:buffer_color[((numero shr 3) and $7)+$18]:=true;
    128..191:buffer_color[((numero shr 3) and $7)+$10]:=true;
    192..255:buffer_color[((numero shr 3) and $7)+8]:=true;
  end;
end;

procedure write_sound_command(valor:byte);inline;
begin
  sound_latch:=valor;
  z80pio_astb_w(0,false);
	z80pio_astb_w(0,true);
end;

procedure starforce_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
memoria[direccion]:=valor;
case direccion of
        $9000..$97ff:gfx[0].buffer[direccion and $3ff]:=true;
        $9c00..$9dff:if buffer_paleta[direccion and $1ff]<>valor then begin
                        buffer_paleta[direccion and $1ff]:=valor;
                        cambiar_color(direccion and $1ff);
                     end;
        $9e00..$9e3f:case (direccion and $3f) of
                        $20:x3:=(x3 and $100) or not(valor);
                        $21:x3:=(x3 and $ff) or ((valor and 1) shl 8);
                        $25:if main_screen.flip_main_screen then y3:=not(valor)
                              else y3:=valor;
                        $28:x2:=(x2 and $100) or not(valor);
                        $29:x2:=(x2 and $ff) or ((valor and 1) shl 8);
                        $2d:if main_screen.flip_main_screen then y2:=not(valor)
                              else y2:=valor;
                        $30:x1:=(x1 and $100) or not(valor);
                        $31:x1:=(x1 and $ff) or ((valor and 1) shl 8);
                        $35:if main_screen.flip_main_screen then y1:=not(valor)
                              else y1:=valor;
                     end;
        $a000..$a7ff:gfx[3].buffer[direccion and $7ff]:=true;
        $a800..$afff:gfx[4].buffer[direccion and $7ff]:=true;
        $b000..$b7ff:gfx[5].buffer[direccion and $7ff]:=true;
        $d000:main_screen.flip_main_screen:=(valor and 1)<>0;
        $d002:main_z80.pedir_irq:=CLEAR_LINE;
        $d004:write_sound_command(valor);
end;
end;

function snd_getbyte(direccion:word):byte;
begin
if direccion<$4400 then snd_getbyte:=mem_snd[direccion];
end;

procedure snd_putbyte(direccion:word;valor:byte);
begin
if direccion<$4000 then exit;
mem_snd[direccion]:=valor;
case direccion of
  $8000:sn_76496_0.Write(valor);
  $9000:sn_76496_1.Write(valor);
  $a000:sn_76496_2.Write(valor);
  //$d000:volumen
end;
end;

function snd_inbyte(puerto:word):byte;
begin
case (puerto and $ff) of
    $0..$3:snd_inbyte:=z80pio_ba_cd_r(0,puerto and $3);
    $8..$b:snd_inbyte:=z80ctc_r(0,puerto and $3);
end;
end;

procedure snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $0..$3:z80pio_ba_cd_w(0,puerto and $3,valor);
  $8..$b:z80ctc_w(0,puerto and $3,valor);
end;
end;

procedure starforce_sound_update;
begin
  sn_76496_0.Update;
  sn_76496_1.Update;
  sn_76496_2.Update;
end;

//PIO
function pio_read_porta:byte;
begin
  pio_read_porta:=sound_latch;
end;

//PIO+CTC INT
procedure pio_int_main(state:byte);
begin
  if state<>0 then snd_z80.pedir_irq:=ASSERT_LINE
    else snd_z80.pedir_irq:=CLEAR_LINE;
end;

end.
