unit kyugo_hw;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,ay_8910,rom_engine,
     pal_engine,sound_engine,timer_engine;

function iniciar_kyugo_hw:boolean;

implementation
const
        repulse_rom:array[0..2] of tipo_roms=(
        (n:'repulse.b5';l:$2000;p:0;crc:$fb2b7c9d),(n:'repulse.b6';l:$2000;p:$2000;crc:$99129918),
        (n:'7.j4';l:$2000;p:$4000;crc:$57a8e900));
        repulse_snd:array[0..3] of tipo_roms=(
        (n:'1.f2';l:$2000;p:0;crc:$c485c621),(n:'2.h2';l:$2000;p:$2000;crc:$b3c6a886),
        (n:'3.j2';l:$2000;p:$4000;crc:$197e314c),(n:'repulse.b4';l:$2000;p:$6000;crc:$86b267f3));
        repulse_char:tipo_roms=(n:'repulse.a11';l:$1000;p:0;crc:$8e1de90a);
        repulse_tiles:array[0..2] of tipo_roms=(
        (n:'15.9h';l:$2000;p:0;crc:$c9213469),(n:'16.10h';l:$2000;p:$2000;crc:$7de5d39e),
        (n:'17.11h';l:$2000;p:$4000;crc:$0ba5f72c));
        repulse_sprites:array[0..5] of tipo_roms=(
        (n:'8.6a';l:$4000;p:0;crc:$0e9f757e),(n:'9.7a';l:$4000;p:$4000;crc:$f7d2e650),
        (n:'10.8a';l:$4000;p:$8000;crc:$e717baf4),(n:'11.9a';l:$4000;p:$c000;crc:$04b2250b),
        (n:'12.10a';l:$4000;p:$10000;crc:$d110e140),(n:'13.11a';l:$4000;p:$14000;crc:$8fdc713c));
        repulse_prom:array[0..2] of tipo_roms=(
        (n:'b.1j';l:$100;p:0;crc:$3ea35431),(n:'g.1h';l:$100;p:$100;crc:$acd7a69e),
        (n:'r.1f';l:$100;p:$200;crc:$b7f48b41));
        srdmission_rom:array[0..1] of tipo_roms=(
        (n:'5.t2';l:$4000;p:0;crc:$a682b48c),(n:'7.t3';l:$4000;p:$4000;crc:$1719c58c));
        srdmission_snd:array[0..1] of tipo_roms=(
        (n:'1.t7';l:$4000;p:0;crc:$dc48595e),(n:'3.t8';l:$4000;p:$4000;crc:$216be1e8));
        srdmission_char:tipo_roms=(n:'15.4a';l:$1000;p:0;crc:$4961f7fd);
        srdmission_tiles:array[0..2] of tipo_roms=(
        (n:'17.9h';l:$2000;p:0;crc:$41211458),(n:'18.10h';l:$2000;p:$2000;crc:$740eccd4),
        (n:'16.11h';l:$2000;p:$4000;crc:$c1f4a5db));
        srdmission_sprites:array[0..5] of tipo_roms=(
        (n:'14.6a';l:$4000;p:0;crc:$3d4c0447),(n:'13.7a';l:$4000;p:$4000;crc:$22414a67),
        (n:'12.8a';l:$4000;p:$8000;crc:$61e34283),(n:'11.9a';l:$4000;p:$c000;crc:$bbbaffef),
        (n:'10.10a';l:$4000;p:$10000;crc:$de564f97),(n:'9.11a';l:$4000;p:$14000;crc:$890dc815));
        srdmission_prom:array[0..3] of tipo_roms=(
        (n:'mr.1j';l:$100;p:0;crc:$110a436e),(n:'mg.1h';l:$100;p:$100;crc:$0fbfd9f0),
        (n:'mb.1f';l:$100;p:$200;crc:$a342890c),(n:'m2.5j';l:$20;p:$300;crc:$190a55ad));
        airwolf_rom:tipo_roms=(n:'b.2s';l:$8000;p:0;crc:$8c993cce);
        airwolf_snd:tipo_roms=(n:'a.7s';l:$8000;p:0;crc:$a3c7af5c);
        airwolf_char:tipo_roms=(n:'f.4a';l:$1000;p:0;crc:$4df44ce9);
        airwolf_tiles:array[0..2] of tipo_roms=(
        (n:'09h_14.bin';l:$2000;p:0;crc:$25e57e1f),(n:'10h_13.bin';l:$2000;p:$2000;crc:$cf0de5e9),
        (n:'11h_12.bin';l:$2000;p:$4000;crc:$4050c048));
        airwolf_sprites:array[0..2] of tipo_roms=(
        (n:'e.6a';l:$8000;p:0;crc:$e8fbc7d2),(n:'d.8a';l:$8000;p:$8000;crc:$c5d4156b),
        (n:'c.10a';l:$8000;p:$10000;crc:$de91dfb1));
        airwolf_prom:array[0..3] of tipo_roms=(
        (n:'01j.bin';l:$100;p:0;crc:$6a94b2a3),(n:'01h.bin';l:$100;p:$100;crc:$ec0923d3),
        (n:'01f.bin';l:$100;p:$200;crc:$ade97052),(n:'74s288-2.bin';l:$20;p:$300;crc:$190a55ad));
var
  scroll_x:word;
  scroll_y,fg_color,bg_pal_bank:byte;
  nmi_enable:boolean;
  color_codes:array[0..$1f] of byte;

procedure update_video_kyugo_hw;
var
  f,nchar:word;
  atrib,x,y,color:byte;

procedure draw_sprites;
var
  n,y:byte;
  offs,color,sx,sy,nchar,atrib:word;
begin
for n:=0 to (12*2)-1 do begin
		offs:=(n mod 12) shl 1+64*(n div 12);
		sx:=memoria[$9029+offs]+256*(memoria[$9829+offs] and 1);
		sy:=255-memoria[$a028+offs]+2;
		color:=(memoria[$a029+offs] and $1f) shl 3;
		for y:=0 to 15 do begin
			nchar:=memoria[$9028+offs+128*y];
			atrib:=memoria[$9828+offs+128*y];
			nchar:=nchar or ((atrib and $01) shl 9) or ((atrib and $02) shl 7);
      put_gfx_sprite(nchar,color,(atrib and 8)<>0,(atrib and 4)<>0,2);
      actualiza_gfx_sprite(sx,sy+16*y,3,2);
		end;
end;
end;

begin
for f:=0 to $7ff do begin
  //background
  if gfx[1].buffer[f] then begin
    x:=f mod 64;
    y:=f div 64;
    atrib:=memoria[$8800+f];
    nchar:=memoria[$8000+f]+((atrib and $03) shl 8);
    color:=((atrib shr 4) or bg_pal_bank) shl 3;
    put_gfx_flip(x*8,y*8,nchar,color,2,1,(atrib and $4)<>0,(atrib and $8)<>0);
    gfx[1].buffer[f]:=false;
  end;
  //foreground
  if gfx[0].buffer[f] then begin
    x:=f mod 64;
    y:=f div 64;
    nchar:=memoria[$9000+f];
    put_gfx_trans(x*8,y*8,nchar,2*color_codes[nchar shr 3]+fg_color,1,0);
    gfx[0].buffer[f]:=false;
  end;
end;
scroll_x_y(2,3,scroll_x+32,scroll_y);
draw_sprites;
actualiza_trozo(0,0,256,512,1,0,0,256,512,3);
actualiza_trozo_final(0,16,288,224,3);
end;

procedure eventos_kyugo_hw;
begin
if event.arcade then begin
  //system
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 or 8) else marcade.in0:=(marcade.in0 and $f7);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 or $10) else marcade.in0:=(marcade.in0 and $ef);
  //P1
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 or 1) else marcade.in1:=(marcade.in1 and $fe);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 or 2) else marcade.in1:=(marcade.in1 and $fd);
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 or 4) else marcade.in1:=(marcade.in1 and $fb);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 or 8) else marcade.in1:=(marcade.in1 and $f7);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 or $10) else marcade.in1:=(marcade.in1 and $ef);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 or $20) else marcade.in1:=(marcade.in1 and $df);
  //P2
  if arcade_input.left[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.right[0] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
  if arcade_input.up[0] then marcade.in2:=(marcade.in2 or 4) else marcade.in2:=(marcade.in2 and $fb);
  if arcade_input.down[0] then marcade.in2:=(marcade.in2 or 8) else marcade.in2:=(marcade.in2 and $f7);
  if arcade_input.but0[0] then marcade.in2:=(marcade.in2 or $10) else marcade.in2:=(marcade.in2 and $ef);
  if arcade_input.but1[0] then marcade.in2:=(marcade.in2 or $20) else marcade.in2:=(marcade.in2 and $df);
end;
end;

procedure kyugo_hw_principal;
var
  f:byte;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for f:=0 to $ff do begin
    eventos_kyugo_hw;
    if f=240 then begin
      if nmi_enable then z80_0.change_nmi(PULSE_LINE);
      update_video_kyugo_hw;
    end;
    //Main CPU
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //Sound CPU
    z80_1.run(frame_snd);
    frame_snd:=frame_snd+z80_1.tframes-z80_1.contador;
  end;
  video_sync;
end;
end;

function kyugo_getbyte(direccion:word):byte;
begin
case direccion of
  0..$a7ff,$f000..$f7ff:kyugo_getbyte:=memoria[direccion];
end;
end;

procedure kyugo_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$7fff:;
    $8000..$8fff:if memoria[direccion]<>valor then begin
                    gfx[1].buffer[direccion and $7ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $9000..$97ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $7ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $9800..$9fff:memoria[direccion]:=valor or $f0;
    $a000..$a7ff,$f000..$f7ff:memoria[direccion]:=valor;
    $a800:scroll_x:=(scroll_x and $100) or valor;
    $b000:begin
            scroll_x:=(scroll_x and $ff) or ((valor and $1) shl 8);
            if fg_color<>((valor and $20) shr 3) then begin
              fg_color:=(valor and $20) shr 3;
              fillchar(gfx[0].buffer[0],$800,1);
            end;
            if bg_pal_bank<>((valor and $40) shr 2) then begin
              bg_pal_bank:=(valor and $40) shr 2;
              fillchar(gfx[1].buffer[0],$800,1);
            end;
          end;
    $b800:scroll_y:=valor;
end;
end;

procedure kyugo_outbyte(puerto:word;valor:byte);
begin
  case (puerto and $7) of
    0:nmi_enable:=(valor and 1)<>0;
    1:main_screen.flip_main_screen:=(valor<>0);
    2:if (valor<>0) then z80_1.change_halt(CLEAR_LINE)
        else z80_1.change_halt(ASSERT_LINE);
  end;
end;

//Sound
function snd_kyugo_hw_getbyte(direccion:word):byte;
begin
case direccion of
   0..$7fff:snd_kyugo_hw_getbyte:=mem_snd[direccion];
   $a000..$a7ff:snd_kyugo_hw_getbyte:=memoria[direccion+$5000];
   $c000:snd_kyugo_hw_getbyte:=marcade.in2;
   $c040:snd_kyugo_hw_getbyte:=marcade.in1;
   $c080:snd_kyugo_hw_getbyte:=marcade.in0;
end;
end;

procedure snd_kyugo_hw_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $a000..$a7ff:memoria[direccion+$5000]:=valor;
end;
end;

function snd_kyugo_inbyte(puerto:word):byte;
begin
  if (puerto and $ff)=2 then snd_kyugo_inbyte:=ay8910_0.read;
end;

procedure snd_kyugo_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $00:ay8910_0.Control(valor);
  $01:ay8910_0.write(valor);
  $40:ay8910_1.Control(valor);
  $41:ay8910_1.write(valor);
end;
end;

function kyugo_porta_r:byte;
begin
  kyugo_porta_r:=marcade.dswa;
end;

function kyugo_portb_r:byte;
begin
  kyugo_portb_r:=marcade.dswb;
end;

procedure kyugo_snd_irq;
begin
  z80_1.change_irq(HOLD_LINE);
end;

procedure kyugo_snd_update;
begin
  ay8910_0.update;
  ay8910_1.update;
end;

//SRD Mission
function srdmission_getbyte(direccion:word):byte;
begin
case direccion of
  0..$a7ff,$e000..$e7ff:srdmission_getbyte:=memoria[direccion];
end;
end;

procedure srdmission_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$7fff:;
    $8000..$8fff:if memoria[direccion]<>valor then begin
                    gfx[1].buffer[direccion and $7ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $9000..$97ff:if memoria[direccion]<>valor then begin
                    gfx[0].buffer[direccion and $7ff]:=true;
                    memoria[direccion]:=valor;
                 end;
    $9800..$9fff:memoria[direccion]:=valor or $f0;
    $a000..$a7ff,$e000..$e7ff:memoria[direccion]:=valor;
    $a800:scroll_x:=(scroll_x and $100) or valor;
    $b000:begin
            scroll_x:=(scroll_x and $ff) or ((valor and $1) shl 8);
            if fg_color<>((valor and $20) shr 5) then begin
              fg_color:=(valor and $20) shr 5;
              fillchar(gfx[0].buffer[0],$800,1);
            end;
            if bg_pal_bank<>((valor and $40) shr 6) then begin
              bg_pal_bank:=(valor and $40) shr 6;
              fillchar(gfx[1].buffer[0],$800,1);
            end;
          end;
    $b800:scroll_y:=valor;
end;
end;

function snd_srdmission_hw_getbyte(direccion:word):byte;
begin
case direccion of
   0..$7fff,$8800..$8fff:snd_srdmission_hw_getbyte:=mem_snd[direccion];
   $8000..$87ff:snd_srdmission_hw_getbyte:=memoria[direccion+$6000];
   $f400:snd_srdmission_hw_getbyte:=marcade.in0;
   $f401:snd_srdmission_hw_getbyte:=marcade.in1;
   $f402:snd_srdmission_hw_getbyte:=marcade.in2;
end;
end;

procedure snd_srdmission_hw_putbyte(direccion:word;valor:byte);
begin
case direccion of
  0..$7fff:;
  $8000..$87ff:memoria[direccion+$6000]:=valor;
  $8800..$8fff:mem_snd[direccion]:=valor;
end;
end;

function snd_srdmission_inbyte(puerto:word):byte;
begin
  if (puerto and $ff)=$82 then snd_srdmission_inbyte:=ay8910_0.read;
end;

procedure snd_srdmission_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $80:ay8910_0.Control(valor);
  $81:ay8910_0.write(valor);
  $84:ay8910_1.Control(valor);
  $85:ay8910_1.write(valor);
end;
end;

//Main
procedure reset_kyugo_hw;
begin
 z80_0.reset;
 z80_1.reset;
 ay8910_0.reset;
 ay8910_1.reset;
 frame_main:=z80_0.tframes;
 frame_snd:=z80_1.tframes;
 marcade.in0:=0;
 marcade.in1:=0;
 marcade.in2:=0;
 scroll_x:=0;
 scroll_y:=0;
 fg_color:=0;
 bg_pal_bank:=0;
 nmi_enable:=false;
 z80_1.change_halt(ASSERT_LINE);
end;

function iniciar_kyugo_hw:boolean;
var
  memoria_temp,memoria_temp2:array[0..$17fff] of byte;
  colores:tpaleta;
  f,bit0,bit1,bit2,bit3:byte;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 8*8+0, 8*8+1, 8*8+2, 8*8+3);
  ps_x:array[0..15] of dword=(0,1,2,3,4,5,6,7,
	  8*8+0, 8*8+1, 8*8+2, 8*8+3, 8*8+4, 8*8+5, 8*8+6, 8*8+7);
  ps_y:array[0..15] of dword=(0*8,  1*8,  2*8,  3*8,  4*8,  5*8,  6*8,  7*8,
	  16*8, 17*8, 18*8, 19*8, 20*8, 21*8, 22*8, 23*8);
procedure convert_chars;
begin
  init_gfx(0,8,8,$100);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(2,0,8*8*2,0,4);
  convert_gfx(0,0,@memoria_temp,@pc_x,@ps_y,false,false);
end;
procedure convert_tiles;
begin
  init_gfx(1,8,8,$400);
  gfx_set_desc_data(3,0,8*8,0,$400*8*8,$400*8*8*2);
  convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;
procedure convert_sprites;
begin
  init_gfx(2,16,16,$400);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(3,0,16*16,0,$400*16*16,$400*16*16*2);
  convert_gfx(2,0,@memoria_temp,@ps_x,@ps_y,false,false);
end;
begin
llamadas_maquina.bucle_general:=kyugo_hw_principal;
llamadas_maquina.reset:=reset_kyugo_hw;
llamadas_maquina.scanlines:=256;
iniciar_kyugo_hw:=false;
iniciar_audio(false);
screen_init(1,512,256,true);
screen_init(2,512,256);
screen_init(3,512,256,false,true);
if ((main_vars.tipo_maquina=128) or (main_vars.tipo_maquina=330)) then main_screen.rot90_screen:=true;
iniciar_video(288,224);
//Main CPU
z80_0:=cpu_z80.create(3072000);
z80_0.change_io_calls(nil,kyugo_outbyte);
//Sound CPU
z80_1:=cpu_z80.create(3072000);
z80_1.init_sound(kyugo_snd_update);
timers.init(z80_1.numero_cpu,3072000/(60*4),kyugo_snd_irq,nil,true);
//Sound Chip
ay8910_0:=ay8910_chip.create(1536000,AY8910);
ay8910_0.change_io_calls(kyugo_porta_r,kyugo_portb_r,nil,nil);
ay8910_1:=ay8910_chip.create(1536000,AY8910);
case main_vars.tipo_maquina of
  128:begin //repulse
        //cargar roms
        z80_0.change_ram_calls(kyugo_getbyte,kyugo_putbyte);
        if not(roms_load(@memoria,repulse_rom)) then exit;
        //cargar roms snd
        z80_1.change_ram_calls(snd_kyugo_hw_getbyte,snd_kyugo_hw_putbyte);
        z80_1.change_io_calls(snd_kyugo_inbyte,snd_kyugo_outbyte);
        if not(roms_load(@mem_snd,repulse_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,repulse_char)) then exit;
        convert_chars;
        //convertir tiles
        if not(roms_load(@memoria_temp,repulse_tiles)) then exit;
        convert_tiles;
        //convertir sprites
        if not(roms_load(@memoria_temp,repulse_sprites)) then exit;
        convert_sprites;
        //paleta
        if not(roms_load(@memoria_temp,repulse_prom)) then exit;
        fillchar(color_codes,$20,0);
        marcade.dswa:=$bf;
        marcade.dswb:=$bf;
  end;
  330:begin //SRD Mission
        //cargar roms
        z80_0.change_ram_calls(srdmission_getbyte,srdmission_putbyte);
        if not(roms_load(@memoria,srdmission_rom)) then exit;
        //cargar roms snd
        z80_1.change_ram_calls(snd_srdmission_hw_getbyte,snd_srdmission_hw_putbyte);
        z80_1.change_io_calls(snd_srdmission_inbyte,snd_srdmission_outbyte);
        if not(roms_load(@mem_snd,srdmission_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,srdmission_char)) then exit;
        convert_chars;
        //convertir tiles
        if not(roms_load(@memoria_temp,srdmission_tiles)) then exit;
        convert_tiles;
        //convertir sprites
        if not(roms_load(@memoria_temp,srdmission_sprites)) then exit;
        convert_sprites;
        //paleta
        if not(roms_load(@memoria_temp,srdmission_prom)) then exit;
        fillchar(color_codes,$20,0);
        copymemory(@color_codes,@memoria_temp[$300],$20);
        marcade.dswa:=$bf;
        marcade.dswb:=$ff;
  end;
  331:begin //Airwolf
        //cargar roms
        z80_0.change_ram_calls(srdmission_getbyte,srdmission_putbyte);
        if not(roms_load(@memoria,airwolf_rom)) then exit;
        //cargar roms snd
        z80_1.change_ram_calls(snd_srdmission_hw_getbyte,snd_srdmission_hw_putbyte);
        z80_1.change_io_calls(snd_srdmission_inbyte,snd_srdmission_outbyte);
        if not(roms_load(@mem_snd,airwolf_snd)) then exit;
        //convertir chars
        if not(roms_load(@memoria_temp,airwolf_char)) then exit;
        convert_chars;
        //convertir tiles
        if not(roms_load(@memoria_temp,airwolf_tiles)) then exit;
        convert_tiles;
        //convertir sprites
        if not(roms_load(@memoria_temp2,airwolf_sprites)) then exit;
        copymemory(@memoria_temp[0],@memoria_temp2[0],$2000);
        copymemory(@memoria_temp[$4000],@memoria_temp2[$2000],$2000);
        copymemory(@memoria_temp[$2000],@memoria_temp2[$4000],$2000);
        copymemory(@memoria_temp[$6000],@memoria_temp2[$6000],$2000);
        copymemory(@memoria_temp[$8000],@memoria_temp2[$8000],$2000);
        copymemory(@memoria_temp[$c000],@memoria_temp2[$a000],$2000);
        copymemory(@memoria_temp[$a000],@memoria_temp2[$c000],$2000);
        copymemory(@memoria_temp[$e000],@memoria_temp2[$e000],$2000);
        copymemory(@memoria_temp[$10000],@memoria_temp2[$10000],$2000);
        copymemory(@memoria_temp[$14000],@memoria_temp2[$12000],$2000);
        copymemory(@memoria_temp[$12000],@memoria_temp2[$14000],$2000);
        copymemory(@memoria_temp[$16000],@memoria_temp2[$16000],$2000);
        convert_sprites;
        //paleta
        if not(roms_load(@memoria_temp,airwolf_prom)) then exit;
        fillchar(color_codes,$20,0);
        copymemory(@color_codes,@memoria_temp[$300],$20);
        marcade.dswa:=$bf;
        marcade.dswb:=$ff;
  end;
end;
for f:=0 to $ff do begin
  bit0:=(memoria_temp[f] shr 0) and 1;
  bit1:=(memoria_temp[f] shr 1) and 1;
  bit2:=(memoria_temp[f] shr 2) and 1;
  bit3:=(memoria_temp[f] shr 3) and 1;
  colores[f].r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  bit0:=(memoria_temp[f+$100] shr 0) and 1;
  bit1:=(memoria_temp[f+$100] shr 1) and 1;
  bit2:=(memoria_temp[f+$100] shr 2) and 1;
  bit3:=(memoria_temp[f+$100] shr 3) and 1;
  colores[f].g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
  bit0:=(memoria_temp[f+$200] shr 0) and 1;
  bit1:=(memoria_temp[f+$200] shr 1) and 1;
  bit2:=(memoria_temp[f+$200] shr 2) and 1;
  bit3:=(memoria_temp[f+$200] shr 3) and 1;
  colores[f].b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
end;
set_pal(colores,$100);
iniciar_kyugo_hw:=true;
end;

end.
