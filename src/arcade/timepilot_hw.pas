unit timepilot_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     konami_snd,sound_engine;

procedure Cargar_timepilot;
procedure timepilot_principal;
function timepilot_iniciar:boolean;
procedure timepilot_reset;
procedure timepilot_cerrar;
//Main CPU
function timepilot_getbyte(direccion:word):byte;
procedure timepilot_putbyte(direccion:word;valor:byte);

const
    timepilot_rom:array[0..3] of tipo_roms=(
    (n:'tm1';l:$2000;p:0;crc:$1551f1b9),(n:'tm2';l:$2000;p:$2000;crc:$58636cb5),
    (n:'tm3';l:$2000;p:$4000;crc:$ff4e0d83),());
    timepilot_char:tipo_roms=(n:'tm6';l:$2000;p:0;crc:$c2507f40);
    timepilot_sprt:array[0..2] of tipo_roms=(
    (n:'tm4';l:$2000;p:0;crc:$7e437c3e),(n:'tm5';l:$2000;p:$2000;crc:$e8ca87b9),());
    timepilot_pal:array[0..4] of tipo_roms=(
    (n:'timeplt.b4';l:$20;p:0;crc:$34c91839),(n:'timeplt.b5';l:$20;p:$20;crc:$463b2b07),
    (n:'timeplt.e9';l:$100;p:$40;crc:$4bbb2150),(n:'timeplt.e12';l:$100;p:$140;crc:$f7b7663e),());
    timepilot_sound:tipo_roms=(n:'tm7';l:$1000;p:0;crc:$d66da813);

var
  scan_line,last:byte;
  nmi_enable:boolean;

implementation

procedure Cargar_timepilot;
begin
llamadas_maquina.iniciar:=timepilot_iniciar;
llamadas_maquina.bucle_general:=timepilot_principal;
llamadas_maquina.cerrar:=timepilot_cerrar;
llamadas_maquina.reset:=timepilot_reset;
end;

function timepilot_iniciar:boolean;
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3,8*8+0,8*8+1,8*8+2,8*8+3);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 8*8+0,8*8+1,8*8+2,8*8+3,
			16*8+0,16*8+1,16*8+2,16*8+3,24*8+0,24*8+1,24*8+2,24*8+3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
var
        colores:tpaleta;
        f:word;
        bit0,bit1,bit2,bit3,bit4:byte;
        memoria_temp:array[0..$3fff] of byte;
begin
timepilot_iniciar:=false;
iniciar_audio(false);
screen_init(1,256,256);
screen_init(2,256,256,true);
screen_init(3,256,256,false,true);
iniciar_video(224,256);
//Main CPU
main_z80:=cpu_z80.create(3072000,256);
main_z80.change_ram_calls(timepilot_getbyte,timepilot_putbyte);
//Sound CPU
snd_z80:=cpu_z80.create(1789772,256);
snd_z80.change_ram_calls(konamisnd_getbyte,konamisnd_putbyte);
//Sound Chip
konamisnd_init(2,snd_z80.numero_cpu,TWO_AY8910,snd_z80.clock,nil);
//Cargar las roms...
if not(cargar_roms(@memoria[0],@timepilot_rom[0],'timeplt.zip',0)) then exit;
//roms de sonido
if not(cargar_roms(@mem_snd[0],@timepilot_sound,'timeplt.zip')) then exit;
//cargar chars
if not(cargar_roms(@memoria_temp[0],@timepilot_char,'timeplt.zip')) then exit;
init_gfx(0,8,8,$200);
gfx[0].trans[0]:=true;
gfx_set_desc_data(2,0,16*8,4,0);
convert_gfx(@gfx[0],0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//cargar sprites
if not(cargar_roms(@memoria_temp[0],@timepilot_sprt[0],'timeplt.zip',0)) then exit;
init_gfx(1,16,16,$100);
gfx[1].trans[0]:=true;
gfx_set_desc_data(2,0,64*8,4,0);
convert_gfx(@gfx[1],0,@memoria_temp[0],@ps_x[0],@ps_y[0],true,false);
//paleta de colores
if not(cargar_roms(@memoria_temp[0],@timepilot_pal[0],'timeplt.zip',0)) then exit;
for f:=0 to 31 do begin
		bit0:= (memoria_temp[f+$20] shr 1) and $01;
		bit1:= (memoria_temp[f+$20] shr 2) and $01;
		bit2:= (memoria_temp[f+$20] shr 3) and $01;
		bit3:= (memoria_temp[f+$20] shr 4) and $01;
		bit4:= (memoria_temp[f+$20] shr 5) and $01;
		colores[f].r:=$19*bit0+$24*bit1+$35*bit2+$40*bit3+$4d*bit4;
		bit0:= (memoria_temp[f+$20] shr 6) and $01;
		bit1:= (memoria_temp[f+$20] shr 7) and $01;
		bit2:= (memoria_temp[f] shr 0) and $01;
		bit3:= (memoria_temp[f] shr 1) and $01;
		bit4:= (memoria_temp[f] shr 2) and $01;
		colores[f].g:=$19*bit0+$24*bit1+$35*bit2+$40*bit3+$4d*bit4;
		bit0:= (memoria_temp[f] shr 3) and $01;
		bit1:= (memoria_temp[f] shr 4) and $01;
		bit2:= (memoria_temp[f] shr 5) and $01;
		bit3:= (memoria_temp[f] shr 6) and $01;
		bit4:= (memoria_temp[f] shr 7) and $01;
		colores[f].b:=$19*bit0+$24*bit1+$35*bit2+$40*bit3+$4d*bit4;
end;
set_pal(colores,$40);
//CLUT Sprites
for f:=0 to $ff do gfx[1].colores[f]:=memoria_temp[$40+f] and $f;
//CLUT chars
for f:=0 to $7f do gfx[0].colores[f]:=(memoria_temp[$140+f] and $f)+$10;
//Final
timepilot_reset;
timepilot_iniciar:=true;
end;

procedure timepilot_reset;
begin
main_z80.reset;
snd_z80.reset;
konamisnd_reset;
reset_audio;
nmi_enable:=false;
marcade.in0:=$ff;
marcade.in1:=$ff;
marcade.in2:=$ff;
end;

procedure timepilot_cerrar;
begin
main_z80.free;
snd_z80.free;
konamisnd_close;
close_audio;
close_video;
end;

procedure update_video_timepilot;inline;
var
    x,y,atrib:byte;
    f,nchar,color:word;
begin
for f:=0 to $3ff do begin
 if gfx[0].buffer[f] then begin
    x:=31-(f div 32);
    y:=f mod 32;
    atrib:=memoria[$a000+f];
    color:=(atrib and $1f) shl 2;
    nchar:=memoria[$a400+f]+((atrib and $20) shl 3);
    put_gfx_flip(x*8,y*8,nchar,color,1,0,(atrib and $80)<>0,(atrib and $40)<>0);
    if (atrib and $10)<>0 then put_gfx_flip(x*8,y*8,nchar,color,2,0,(atrib and $80)<>0,(atrib and $40)<>0)
      else put_gfx_block_trans(x*8,y*8,2,8,8);
    gfx[0].buffer[f]:=false;
  end;
end;
actualiza_trozo(0,32,256,224,1,0,32,256,224,3);
for f:=$1f downto $8 do begin
  atrib:=memoria[$b400+(f*2)];
  nchar:=memoria[$b001+(f*2)];
  color:=(atrib and $3f) shl 2;
  x:=memoria[$b401+(f*2)]-1;
  y:=memoria[$b000+(f*2)];
  put_gfx_sprite(nchar,color,(atrib and $80)<>0,(atrib and $40)=0,1);
  actualiza_gfx_sprite_over(x,y,3,1,2,0,0);
end;
actualiza_trozo(0,0,256,32,1,0,0,256,32,3);
actualiza_trozo_final(16,0,256,256,3);
end;

procedure eventos_timepilot;
begin
if event.arcade then begin
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $Fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $Fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $eF) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.left[0] then marcade.in1:=marcade.in1 and $Fe else marcade.in1:=marcade.in1 or $1;
  if arcade_input.right[0] then marcade.in1:=marcade.in1 and $Fd else marcade.in1:=marcade.in1 or $2;
  if arcade_input.up[0] then marcade.in1:=marcade.in1 and $fb else marcade.in1:=marcade.in1 or $4;
  if arcade_input.down[0] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or $8;
  if arcade_input.but0[0] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
end;
end;

procedure timepilot_principal;
var
  frame_m,frame_s:single;
begin
init_controls(false,false,false,true);
frame_m:=main_z80.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for scan_line:=0 to $ff do begin
    konami_sound.frame:=scan_line;
    main_z80.run(frame_m);
    frame_m:=frame_m+main_z80.tframes-main_z80.contador;
    snd_z80.run(frame_s);
    frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
    if (scan_line=244) then begin
      if nmi_enable then main_z80.pedir_nmi:=ASSERT_LINE;
    end;
  end;
  update_video_timepilot;
  eventos_timepilot;
  video_sync;
end;
end;

function timepilot_getbyte(direccion:word):byte;
begin
case direccion of
  $0000..$5fff,$a000..$afff:timepilot_getbyte:=memoria[direccion];
  $b000..$bfff:case (direccion and $7ff) of
                $000..$3ff:timepilot_getbyte:=memoria[$b000+(direccion and $ff)];
                $400..$7ff:timepilot_getbyte:=memoria[$b400+(direccion and $ff)];
               end;
  $c000..$cfff:case (direccion and $3ff) of
                $000..$0ff:timepilot_getbyte:=scan_line;
                $200..$2ff:timepilot_getbyte:=$4b; //dsw1
                $300..$31f,$380..$39f:timepilot_getbyte:=marcade.in0;
                $320..$33f,$3a0..$3bf:timepilot_getbyte:=marcade.in1;
                $340..$35f,$3c0..$3df:timepilot_getbyte:=marcade.in2;
                $360..$37f,$3e0..$3ff:timepilot_getbyte:=$ff; //dsw2
               end;
end;
end;

procedure timepilot_putbyte(direccion:word;valor:byte);
begin
if direccion<$6000 then exit;
case direccion of
    $a000..$a7ff:begin
                    memoria[direccion]:=valor;
                    gfx[0].buffer[direccion and $3ff]:=true;
                 end;
    $a800..$afff:memoria[direccion]:=valor;
    $b000..$bfff:case (direccion and $7ff) of
                $000..$3ff:memoria[$b000+(direccion and $ff)]:=valor;
                $400..$7ff:memoria[$b400+(direccion and $ff)]:=valor;
               end;
    $c000..$cfff:case (direccion and $3ff) of
                $000..$0ff:konami_sound.sound_latch:=valor;
                $300..$3ff:case (direccion and $f) of
                    $0..$1:begin
                              nmi_enable:=(valor and 1)<>0;
	                            if not(nmi_enable) then main_z80.clear_nmi;
                           end;
                    $02:main_screen.flip_main_screen:=(valor and $1)=0;
                    $04:begin
                        if ((last=0) and (valor<>0)) then snd_z80.pedir_irq:=HOLD_LINE;
                        last:=valor;
                     end;
                end;
               end;
end;
end;

end.
