unit pengo_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,main_engine,namco_snd,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,sega_decrypt;

procedure Cargar_pengo;
procedure pengo_principal;
function iniciar_pengo:boolean;
procedure reset_pengo;
//Main CPU
function pengo_getbyte(direccion:word):byte;
procedure pengo_putbyte(direccion:word;valor:byte);

implementation
const
        pengo_rom:array[0..8] of tipo_roms=(
        (n:'ep1689c.8';l:$1000;p:0;crc:$f37066a8),(n:'ep1690b.7';l:$1000;p:$1000;crc:$baf48143),
        (n:'ep1691b.15';l:$1000;p:$2000;crc:$adf0eba0),(n:'ep1692b.14';l:$1000;p:$3000;crc:$a086d60f),
        (n:'ep1693b.21';l:$1000;p:$4000;crc:$b72084ec),(n:'ep1694b.20';l:$1000;p:$5000;crc:$94194a89),
        (n:'ep5118b.32';l:$1000;p:$6000;crc:$af7b12c4),(n:'ep5119c.31';l:$1000;p:$7000;crc:$933950fe),());
        pengo_pal:array[0..2] of tipo_roms=(
        (n:'pr1633.78';l:$20;p:0;crc:$3a5844ec),(n:'pr1634.88';l:$400;p:$20;crc:$766b139b),());
        pengo_sound:tipo_roms=(n:'pr1635.51';l:$100;p:0;crc:$c29dea27);
        pengo_sprites:array[0..2] of tipo_roms=(
        (n:'ep1640.92';l:$2000;p:$0;crc:$d7eec6cd),(n:'ep1695.105';l:$2000;p:$4000;crc:$5bfd26e9),());
var
 irq_enable:boolean;
 rom_opcode:array[0..$7fff] of byte;
 colortable_bank,gfx_bank,pal_bank:byte;

procedure Cargar_pengo;
begin
llamadas_maquina.iniciar:=iniciar_pengo;
llamadas_maquina.bucle_general:=pengo_principal;
llamadas_maquina.reset:=reset_pengo;
llamadas_maquina.fps_max:=60.6060606060;
end;

function iniciar_pengo:boolean;
var
      colores:tpaleta;
      f:word;
      bit0,bit1,bit2:byte;
      memoria_temp:array[0..$ffff] of byte;
      rweights,gweights,bweights:array[0..3] of single;
const
  ps_x:array[0..15] of dword=(8*8, 8*8+1, 8*8+2, 8*8+3, 16*8+0, 16*8+1, 16*8+2, 16*8+3,
			24*8+0, 24*8+1, 24*8+2, 24*8+3, 0, 1, 2, 3);
  ps_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			32*8, 33*8, 34*8, 35*8, 36*8, 37*8, 38*8, 39*8);
  pc_x:array[0..7] of dword=(8*8+0, 8*8+1, 8*8+2, 8*8+3, 0, 1, 2, 3);
  pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  resistances:array[0..2] of integer=(1000,470,220);
begin
iniciar_pengo:=false;
iniciar_audio(false);
screen_init(1,224,288);
screen_init(2,224,288,false,true);
screen_mod_sprites(2,256,512,$ff,$1ff);
iniciar_video(224,288);
//Main CPU
main_z80:=cpu_z80.create(3072000,264);
main_z80.change_ram_calls(pengo_getbyte,pengo_putbyte);
//cargar roms
if not(cargar_roms(@memoria[0],@pengo_rom[0],'pengo.zip',0)) then exit;
decrypt_sega(@memoria[0],@rom_opcode[0],2);
//cargar sonido & iniciar_sonido
namco_sound_init(3,false);
if not(cargar_roms(@namco_sound.onda_namco[0],@pengo_sound,'pengo.zip')) then exit;
//organizar y convertir gfx
if not(cargar_roms(@memoria_temp[0],@pengo_sprites,'pengo.zip',0)) then exit;
copymemory(@memoria_temp[$2000],@memoria_temp[$1000],$1000);
copymemory(@memoria_temp[$1000],@memoria_temp[$4000],$1000);
copymemory(@memoria_temp[$3000],@memoria_temp[$5000],$1000);
//chars
init_gfx(0,8,8,$200);
gfx_set_desc_data(2,0,16*8,0,4);
convert_gfx(0,0,@memoria_temp[0],@pc_x[0],@pc_y[0],true,false);
//sprites
init_gfx(1,16,16,$80);
gfx_set_desc_data(2,0,64*8,0,4);
convert_gfx(1,0,@memoria_temp[$2000],@ps_x[0],@ps_y[0],true,false);
//poner la paleta
if not(cargar_roms(@memoria_temp[0],@pengo_pal[0],'pengo.zip',0)) then exit;
compute_resistor_weights(0,	255, -1.0,
			3,@resistances[0],@rweights[0],0,0,
			3,@resistances[0],@gweights[0],0,0,
			2,@resistances[1],@bweights[0],0,0);
for f:=0 to $1f do begin
		// red component */
		bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
		colores[f].r:=combine_3_weights(@rweights[0], bit0, bit1, bit2);
		// green component */
		bit0:=(memoria_temp[f] shr 3) and $01;
		bit1:=(memoria_temp[f] shr 4) and $01;
		bit2:=(memoria_temp[f] shr 5) and $01;
		colores[f].g:=combine_3_weights(@gweights[0], bit0, bit1, bit2);
		// blue component */
		bit0:=(memoria_temp[f] shr 6) and $01;
		bit1:=(memoria_temp[f] shr 7) and $01;
		colores[f].b:=combine_2_weights(@bweights[0], bit0, bit1);
end;
set_pal(colores,$20);
for f:=0 to 255 do begin
  gfx[0].colores[f]:=memoria_temp[$20+f] and $f;
  gfx[1].colores[f]:=memoria_temp[$20+f] and $f;
  gfx[0].colores[f+$100]:=(memoria_temp[$20+f] and $f)+$10;
  gfx[1].colores[f+$100]:=(memoria_temp[$20+f] and $f)+$10;
end;
//final
reset_pengo;
iniciar_pengo:=true;
end;

procedure reset_pengo;
begin
 main_z80.reset;
 namco_sound_reset;
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 irq_enable:=false;
 gfx_bank:=0;
 pal_bank:=0;
 colortable_bank:=0;
end;

procedure update_video_pengo;inline;
var
  x,y,f,color,nchar,offs:word;
  sx,sy,atrib:byte;
begin
for x:=0 to 27 do begin
  for y:=0 to 35 do begin
     sx:=29-x;
     sy:=y-2;
	   if (sy and $20)<>0 then offs:=sx+((sy and $1f) shl 5)
	    else offs:=sy+(sx shl 5);
     if gfx[0].buffer[offs] then begin
        color:=(((memoria[$8400+offs]) and $1f) or (colortable_bank shl 5) or (pal_bank shl 6)) shl 2 ;
        nchar:=memoria[$8000+offs]+(gfx_bank shl 8);
        put_gfx(x*8,y*8,nchar,color,1,0);
        gfx[0].buffer[offs]:=false;
     end;
  end;
end;
actualiza_trozo(0,0,224,288,1,0,0,224,288,2);
for f:=7 downto 0 do begin
  atrib:=memoria[$8ff0+(f*2)];
  nchar:=(atrib shr 2) or (gfx_bank shl 6);
  color:=(((memoria[$8ff1+(f*2)]) and $1f) or (colortable_bank shl 5) or (pal_bank shl 6)) shl 2 ;
  x:=240-memoria[$9020+(f*2)];
  y:=272-memoria[$9021+(f*2)];
  put_gfx_sprite_mask(nchar,color,(atrib and 2)<>0,(atrib and 1)<>0,1,0,$f);
  actualiza_gfx_sprite((x-1) and $ff,y,2,1);
end;
actualiza_trozo_final(0,0,224,288,2);
end;

procedure eventos_pengo;
begin
if event.arcade then begin
  //marcade.in0
  if arcade_input.up[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.down[0] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
  if arcade_input.left[0] then marcade.in0:=(marcade.in0 and $Fb) else marcade.in0:=(marcade.in0 or $4);
  if arcade_input.right[0] then marcade.in0:=(marcade.in0 and $F7) else marcade.in0:=(marcade.in0 or $8);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.but0[0] then marcade.in0:=(marcade.in0 and $7f) else marcade.in0:=(marcade.in0 or $80);
  //marcade.in1
  if arcade_input.start[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.start[1] then marcade.in1:=(marcade.in1 and $bf) else marcade.in1:=(marcade.in1 or $40);
end;
end;

procedure pengo_principal;
var
  frame:single;
  f:word;
begin
init_controls(false,false,false,true);
frame:=main_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 263 do begin
    main_z80.run(frame);
    frame:=frame+main_z80.tframes-main_z80.contador;
    if f=223 then begin
      update_video_pengo;
      if irq_enable then main_z80.pedir_irq:=HOLD_LINE;
    end;
  end;
  if sound_status.hay_sonido then begin
      namco_playsound;
      play_sonido;
  end;
  eventos_pengo;
  video_sync;
end;
end;

function pengo_getbyte(direccion:word):byte;
begin
case direccion of
        0..$7fff:if main_z80.opcode then pengo_getbyte:=rom_opcode[direccion]
                    else pengo_getbyte:=memoria[direccion];
        $9000..$903f:pengo_getbyte:=$cc;
        $9040..$907f:pengo_getbyte:=$b0;
        $9080..$90bf:pengo_getbyte:=marcade.in1;
        $90c0..$90ff:pengo_getbyte:=marcade.in0;
        else pengo_getbyte:=memoria[direccion];
end;
end;

procedure pengo_putbyte(direccion:word;valor:byte);
begin
if direccion<$8000 then exit;
memoria[direccion]:=valor;
case direccion of
        $8000..$87ff:gfx[0].buffer[(direccion and $3ff)]:=true;
        $9000..$901f:namco_sound.registros_namco[direccion and $1f]:=valor;
        $9040:irq_enable:=(valor<>0);
        $9041:namco_sound.enabled:=valor<>0;
        $9042:if pal_bank<>valor then begin
                pal_bank:=valor;
                fillchar(gfx[0].buffer,$400,0);
              end;
        $9046:if colortable_bank<>valor then begin
                colortable_bank:=valor;
                fillchar(gfx[0].buffer,$400,0);
              end;
        $9047:if (gfx_bank<>(valor and $1)) then begin
                gfx_bank:=valor and $1;
                fillchar(gfx[0].buffer,$400,0);
              end;
end;
end;

end.
