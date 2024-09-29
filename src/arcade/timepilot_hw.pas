unit timepilot_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     konami_snd,sound_engine;

function timepilot_iniciar:boolean;

implementation
const
    timepilot_rom:array[0..2] of tipo_roms=(
    (n:'tm1';l:$2000;p:0;crc:$1551f1b9),(n:'tm2';l:$2000;p:$2000;crc:$58636cb5),
    (n:'tm3';l:$2000;p:$4000;crc:$ff4e0d83));
    timepilot_char:tipo_roms=(n:'tm6';l:$2000;p:0;crc:$c2507f40);
    timepilot_sprt:array[0..1] of tipo_roms=(
    (n:'tm4';l:$2000;p:0;crc:$7e437c3e),(n:'tm5';l:$2000;p:$2000;crc:$e8ca87b9));
    timepilot_pal:array[0..3] of tipo_roms=(
    (n:'timeplt.b4';l:$20;p:0;crc:$34c91839),(n:'timeplt.b5';l:$20;p:$20;crc:$463b2b07),
    (n:'timeplt.e9';l:$100;p:$40;crc:$4bbb2150),(n:'timeplt.e12';l:$100;p:$140;crc:$f7b7663e));
    timepilot_sound:tipo_roms=(n:'tm7';l:$1000;p:0;crc:$d66da813);
    //Dip
    timepilot_dip_a:array [0..2] of def_dip2=(
    (mask:$f;name:'Coin A';number:16;val16:(2,5,8,4,1,$f,3,7,$e,6,$d,$c,$b,$a,9,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Free Play')),
    (mask:$f0;name:'Coin B';number:16;val16:($20,$50,$80,$40,$10,$f0,$30,$70,$e0,$60,$d0,$c0,$b0,$a0,$90,0);name16:('4C 1C','3C 1C','2C 1C','3C 2C','4C 3C','1C 1C','3C 4C','2C 3C','1C 2C','2C 5C','1C 3C','1C 4C','1C 5C','1C 6C','1C 7C','Invalid')),());
    timepilot_dip_b:array [0..5] of def_dip2=(
    (mask:3;name:'Lives';number:4;val4:(3,2,1,0);name4:('3','4','5','255')),
    (mask:4;name:'Cabinet';number:2;val2:(0,4);name2:('Upright','Cocktail')),
    (mask:8;name:'Bonus Life';number:2;val2:(8,0);name2:('10K 50K','20K 60K')),
    (mask:$70;name:'Difficulty';number:8;val8:($70,$60,$50,$40,$30,$20,$10,0);name8:('1','2','3','4','5','6','7','8')),
    (mask:$80;name:'Demo Sounds';number:2;val2:($80,0);name2:('Off','On')),());

var
  scan_line,last:byte;
  video_enable,nmi_enable:boolean;

procedure draw_sprites(line:byte);
var
  f,atrib,nchar,color,x,y:byte;
  y_line:integer;
begin
for f:=$1f downto 8 do begin
  y:=241-memoria[$b401+(f*2)];
  y_line:=line-y;
  if ((y_line>=0) and (y_line<16)) then begin
    atrib:=memoria[$b400+(f*2)];
    nchar:=memoria[$b001+(f*2)];
    color:=(atrib and $3f) shl 2;
    x:=memoria[$b000+(f*2)];
    put_gfx_sprite(nchar,color,(atrib and $40)=0,(atrib and $80)<>0,1);
    actualiza_gfx_sprite_line(x,y,3,1,y_line);
  end;
end;
end;

procedure update_video_timepilot_bg;
var
  color,x,y,atrib:byte;
  f,nchar:word;
  flipx,flipy:boolean;
begin
for f:=0 to $3ff do begin
  if gfx[0].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    atrib:=memoria[$a000+f];
    color:=(atrib and $1f) shl 2;
    nchar:=memoria[$a400+f]+((atrib and $20) shl 3);
    flipx:=(atrib and $40)<>0;
    flipy:=(atrib and $80)<>0;
    put_gfx_flip(x*8,y*8,nchar,color,1,0,flipx,flipy);
    if (atrib and $10)<>0 then put_gfx_flip(x*8,y*8,nchar,color,2,0,flipx,flipy)
      else put_gfx_block_trans(x*8,y*8,2,8,8);
    gfx[0].buffer[f]:=false;
  end;
end;
end;

procedure eventos_timepilot;
begin
if event.arcade then begin
  //Sys
  if arcade_input.coin[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.coin[1] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  //P1
  if arcade_input.left[0] then marcade.in1:=marcade.in1 and $fe else marcade.in1:=marcade.in1 or 1;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 and $fd else marcade.in1:=marcade.in1 or 2;
  if arcade_input.up[0] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or 4;
  if arcade_input.down[0] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.but0[0] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
  //P2
  if arcade_input.left[1] then marcade.in2:=marcade.in2 and $fe else marcade.in2:=marcade.in2 or 1;
  if arcade_input.right[1] then marcade.in2:=marcade.in2 and $fd else marcade.in2:=marcade.in2 or 2;
  if arcade_input.up[1] then marcade.in2:=marcade.in2 and $fb else marcade.in2:=marcade.in2 or 4;
  if arcade_input.down[1] then marcade.in2:=marcade.in2 and $f7 else marcade.in2:=marcade.in2 or 8;
  if arcade_input.but0[1] then marcade.in2:=marcade.in2 and $ef else marcade.in2:=marcade.in2 or $10;
end;
end;

procedure timepilot_principal;
begin
init_controls(false,false,false,true);
while EmuStatus=EsRunning do begin
  for scan_line:=0 to 255 do begin
    //Pinto linea a linea
    if video_enable then begin
      actualiza_trozo(0,scan_line,256,1,1,0,scan_line,256,1,3);
      draw_sprites(scan_line);
      actualiza_trozo(0,scan_line,256,1,2,0,scan_line,256,1,3);
    end;
    if (scan_line=240) then begin
       if nmi_enable then z80_0.change_nmi(ASSERT_LINE);
       //Pongo la pantalla final
       if not(video_enable) then fill_full_screen(3,$100)
          else actualiza_trozo_final(0,16,256,224,3);
       //Actualizo el fondo
       update_video_timepilot_bg;
    end;
    //Main
    z80_0.run(frame_main);
    frame_main:=frame_main+z80_0.tframes-z80_0.contador;
    //Sound
    konamisnd_0.run;
  end;
  eventos_timepilot;
  video_sync;
end;
end;

function timepilot_getbyte(direccion:word):byte;
begin
case direccion of
  0..$5fff,$a000..$afff:timepilot_getbyte:=memoria[direccion];
  $b000..$bfff:case (direccion and $7ff) of
                0..$3ff:timepilot_getbyte:=memoria[$b000+(direccion and $ff)];
                $400..$7ff:timepilot_getbyte:=memoria[$b400+(direccion and $ff)];
               end;
  $c000..$cfff:case (direccion and $3ff) of
                0..$ff:timepilot_getbyte:=scan_line;
                $200..$2ff:timepilot_getbyte:=marcade.dswb;
                $300..$31f,$380..$39f:timepilot_getbyte:=marcade.in0;
                $320..$33f,$3a0..$3bf:timepilot_getbyte:=marcade.in1;
                $340..$35f,$3c0..$3df:timepilot_getbyte:=marcade.in2;
                $360..$37f,$3e0..$3ff:timepilot_getbyte:=marcade.dswa;
               end;
  else timepilot_getbyte:=$ff;
end;
end;

procedure timepilot_putbyte(direccion:word;valor:byte);
begin
case direccion of
    0..$5fff:;
    $a000..$a7ff:if memoria[direccion]<>valor then begin
                    memoria[direccion]:=valor;
                    gfx[0].buffer[direccion and $3ff]:=true;
                 end;
    $a800..$afff:memoria[direccion]:=valor;
    $b000..$bfff:case (direccion and $7ff) of
                0..$3ff:memoria[$b000+(direccion and $ff)]:=valor;
                $400..$7ff:memoria[$b400+(direccion and $ff)]:=valor;
               end;
    $c000..$cfff:case (direccion and $3ff) of
                0..$ff:konamisnd_0.sound_latch:=valor;
                $300..$3ff:begin
                    valor:=valor and 1;
                    case ((direccion and $f) shr 1) of
                      0:begin
                          nmi_enable:=(valor<>0);
	                        if not(nmi_enable) then z80_0.change_nmi(CLEAR_LINE);
                        end;
                      1:main_screen.flip_main_screen:=(valor=0);
                      2:begin
                          if ((last=0) and (valor<>0)) then konamisnd_0.pedir_irq:=HOLD_LINE;
                          last:=valor;
                        end;
                      3:konamisnd_0.enabled:=(valor=0);
                      4:video_enable:=(valor<>0);
                    end;
                end;
               end;
end;
end;

//Main
procedure timepilot_reset;
begin
z80_0.reset;
frame_main:=z80_0.tframes;
konamisnd_0.reset;
reset_audio;
nmi_enable:=false;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
end;

function timepilot_iniciar:boolean;
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8+0,8*8+1,8*8+2,8*8+3,
			16*8+0,16*8+1,16*8+2,16*8+3,24*8+0,24*8+1,24*8+2,24*8+3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
var
  colores:tpaleta;
  f,bit0,bit1,bit2,bit3,bit4:byte;
  memoria_temp:array[0..$3fff] of byte;
begin
llamadas_maquina.bucle_general:=timepilot_principal;
llamadas_maquina.reset:=timepilot_reset;
timepilot_iniciar:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
main_screen.rot90_screen:=true;
iniciar_video(256,224);
//Main CPU
z80_0:=cpu_z80.create(3072000,256);
z80_0.change_ram_calls(timepilot_getbyte,timepilot_putbyte);
//Sound Chip
konamisnd_0:=konamisnd_chip.create(2,TIPO_TIMEPLT,1789772,256);
if not(roms_load(@konamisnd_0.memoria,timepilot_sound)) then exit;
//Cargar las roms...
if not(roms_load(@memoria,timepilot_rom)) then exit;
//cargar chars
if not(roms_load(@memoria_temp,timepilot_char)) then exit;
init_gfx(0,8,8,$200);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
//cargar sprites
if not(roms_load(@memoria_temp,timepilot_sprt)) then exit;
init_gfx(1,16,16,$100);
gfx[1].trans[0]:=true;
gfx_set_desc_data(2,0,64*8,4,0);
convert_gfx(1,0,@memoria_temp,@ps_x,@ps_y,false,false);
//paleta de colores
if not(roms_load(@memoria_temp,timepilot_pal)) then exit;
for f:=0 to 31 do begin
		bit0:= (memoria_temp[f+$20] shr 1) and 1;
		bit1:= (memoria_temp[f+$20] shr 2) and 1;
		bit2:= (memoria_temp[f+$20] shr 3) and 1;
		bit3:= (memoria_temp[f+$20] shr 4) and 1;
		bit4:= (memoria_temp[f+$20] shr 5) and 1;
		colores[f].r:=$19*bit0+$24*bit1+$35*bit2+$40*bit3+$4d*bit4;
		bit0:= (memoria_temp[f+$20] shr 6) and 1;
		bit1:= (memoria_temp[f+$20] shr 7) and 1;
		bit2:= (memoria_temp[f] shr 0) and 1;
		bit3:= (memoria_temp[f] shr 1) and 1;
		bit4:= (memoria_temp[f] shr 2) and 1;
		colores[f].g:=$19*bit0+$24*bit1+$35*bit2+$40*bit3+$4d*bit4;
		bit0:= (memoria_temp[f] shr 3) and 1;
		bit1:= (memoria_temp[f] shr 4) and 1;
		bit2:= (memoria_temp[f] shr 5) and 1;
		bit3:= (memoria_temp[f] shr 6) and 1;
		bit4:= (memoria_temp[f] shr 7) and 1;
		colores[f].b:=$19*bit0+$24*bit1+$35*bit2+$40*bit3+$4d*bit4;
end;
set_pal(colores,$40);
//CLUT Sprites
for f:=0 to $ff do gfx[1].colores[f]:=memoria_temp[$40+f] and $f;
//CLUT chars
for f:=0 to $7f do gfx[0].colores[f]:=(memoria_temp[$140+f] and $f)+$10;
//Final
marcade.dswa:=$ff;
marcade.dswb:=$4b;
marcade.dswa_val2:=@timepilot_dip_a;
marcade.dswb_val2:=@timepilot_dip_b;
timepilot_reset;
timepilot_iniciar:=true;
end;

end.
