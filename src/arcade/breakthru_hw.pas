unit breakthru_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6809,main_engine,controls_engine,gfx_engine,ym_3812,ym_2203,rom_engine,
     pal_engine,sound_engine;

//main
procedure Cargar_brkthru;
procedure brkthru_principal;
function iniciar_brkthru:boolean;
procedure reset_brkthru;
procedure cerrar_brkthru;
//cpu Break Thru
function brkthru_getbyte(direccion:word):byte;
procedure brkthru_putbyte(direccion:word;valor:byte);
//cpu Darwin
function darwin_getbyte(direccion:word):byte;
procedure darwin_putbyte(direccion:word;valor:byte);
//snd cpu
function brkthru_snd_getbyte(direccion:word):byte;
procedure brkthru_snd_putbyte(direccion:word;valor:byte);
procedure brkthru_sound_update;
procedure brkthru_snd_irq(irqstate:byte);

const
        //Break Thru
        brkthru_rom:array[0..4] of tipo_roms=(
        (n:'brkthru.1';l:$4000;p:$0;crc:$cfb4265f),(n:'brkthru.2';l:$8000;p:$4000;crc:$fa8246d9),
        (n:'brkthru.4';l:$8000;p:$c000;crc:$8cabf252),(n:'brkthru.3';l:$8000;p:$14000;crc:$2f2c40c2),());
        brkthru_snd:tipo_roms=(n:'brkthru.5';l:$8000;p:$8000;crc:$c309435f);
        brkthru_char:tipo_roms=(n:'brkthru.12';l:$2000;p:0;crc:$58c0b29b);
        brkthru_sprites:array[0..3] of tipo_roms=(
        (n:'brkthru.9';l:$8000;p:0;crc:$f54e50a7),(n:'brkthru.10';l:$8000;p:$8000;crc:$fd156945),
        (n:'brkthru.11';l:$8000;p:$10000;crc:$c152a99b),());
        brkthru_tiles:array[0..3] of tipo_roms=(
        (n:'brkthru.7';l:$8000;p:0;crc:$920cc56a),(n:'brkthru.6';l:$8000;p:$8000;crc:$fd3cee40),
        (n:'brkthru.8';l:$8000;p:$10000;crc:$f67ee64e),());
        brkthru_pal:array[0..2] of tipo_roms=(
        (n:'brkthru.13';l:$100;p:0;crc:$aae44269),(n:'brkthru.14';l:$100;p:$100;crc:$f2d4822a),());
        //Darwin
        darwin_rom:array[0..4] of tipo_roms=(
        (n:'darw_04.rom';l:$4000;p:$0;crc:$0eabf21c),(n:'darw_05.rom';l:$8000;p:$4000;crc:$e771f864),
        (n:'darw_07.rom';l:$8000;p:$c000;crc:$97ac052c),(n:'darw_06.rom';l:$8000;p:$14000;crc:$2a9fb208),());
        darwin_snd:tipo_roms=(n:'darw_08.rom';l:$8000;p:$8000;crc:$6b580d58);
        darwin_char:tipo_roms=(n:'darw_09.rom';l:$2000;p:0;crc:$067b4cf5);
        darwin_sprites:array[0..3] of tipo_roms=(
        (n:'darw_10.rom';l:$8000;p:0;crc:$487a014c),(n:'darw_11.rom';l:$8000;p:$8000;crc:$548ce2d1),
        (n:'darw_12.rom';l:$8000;p:$10000;crc:$faba5fef),());
        darwin_tiles:array[0..3] of tipo_roms=(
        (n:'darw_03.rom';l:$8000;p:0;crc:$57d0350d),(n:'darw_02.rom';l:$8000;p:$8000;crc:$559a71ab),
        (n:'darw_01.rom';l:$8000;p:$10000;crc:$15a16973),());
        darwin_pal:array[0..2] of tipo_roms=(
        (n:'df.12';l:$100;p:0;crc:$89b952ef),(n:'df.13';l:$100;p:$100;crc:$d595e91d),());

type
    tipo_update_video=procedure;

var
 rom:array[0..7,0..$1fff] of byte;
 mem_sprt:array[0..$ff] of byte;
 sound_latch,rom_bank,bg_color:byte;
 nmi_ena,old_val,old_val2:boolean;
 scroll_x:word;
 proc_update_video:tipo_update_video;

implementation

procedure Cargar_brkthru;
begin
llamadas_maquina.iniciar:=iniciar_brkthru;
llamadas_maquina.bucle_general:=brkthru_principal;
llamadas_maquina.cerrar:=cerrar_brkthru;
llamadas_maquina.reset:=reset_brkthru;
llamadas_maquina.fps_max:=57.444885;
end;

procedure draw_sprites(prio:byte;invert:boolean);inline;
var
  f,x,y,nchar,color:word;
  atrib:byte;
begin
	{ Draw the sprites. Note that it is important to draw them exactly in this */
	/* order, to have the correct priorities. */

	/* Sprite RAM format
        0         1         2         3
        ccc- ---- ---- ---- ---- ---- ---- ---- = Color
        ---d ---- ---- ---- ---- ---- ---- ---- = Double Size
        ---- p--- ---- ---- ---- ---- ---- ---- = Priority
        ---- -bb- ---- ---- ---- ---- ---- ---- = Bank
        ---- ---e ---- ---- ---- ---- ---- ---- = Enable/Disable
        ---- ---- ssss ssss ---- ---- ---- ---- = Sprite code
        ---- ---- ---- ---- yyyy yyyy ---- ---- = Y position
        ---- ---- ---- ---- ---- ---- xxxx xxxx = X position
    }
	for f:=0 to $3f do begin
    atrib:=mem_sprt[$0+(f*4)];
		if ((atrib and $9)=prio) then begin	// Enable && Low Priority */
      nchar:=mem_sprt[$1+(f*4)]+((atrib and $06) shl 7);
			color:=(atrib and $e0) shr 2;
      if invert then begin
        x:=240-mem_sprt[$2+(f*4)];
			  y:=mem_sprt[$3+(f*4)];
        if (atrib and $10)<>0 then begin	// double height */
          put_gfx_sprite_diff((nchar and $3fe),$40+color,false,false,2,0,0);
          put_gfx_sprite_diff((nchar or 1),$40+color,false,false,2,16,0);
          actualiza_gfx_sprite_size(x-16,y,4,32,16);
  			end else begin
          put_gfx_sprite(nchar,$40+color,false,false,2);
          actualiza_gfx_sprite(x,y,4,2);
        end;
      end else begin
			  x:=240-mem_sprt[$3+(f*4)];
			  y:=224-mem_sprt[$2+(f*4)];
        if (atrib and $10)<>0 then begin	// double height */
          put_gfx_sprite_diff((nchar and $3fe),$40+color,false,false,2,0,0);
          put_gfx_sprite_diff((nchar or 1),$40+color,false,false,2,0,16);
          actualiza_gfx_sprite_size(x,y,4,16,32);
  			end else begin
          put_gfx_sprite(nchar,$40+color,false,false,2);
          actualiza_gfx_sprite(x,y+16,4,2);
        end;
      end;
    end;
	end;
end;

procedure update_video_brkthru;
var
  x,y,atrib:byte;
  f:word;
  nchar,color:word;
begin
for f:=0 to $1ff do begin
    if gfx[1].buffer[f] then begin
      x:=f div 16;
      y:=f mod 16;
      atrib:=memoria[$c01+(f*2)];
      nchar:=memoria[$c00+(f*2)]+((atrib and $3) shl 8);
      color:=(bg_color+((atrib and $4) shr 2)) shl 3;
      put_gfx(x*16,y*16,nchar,$80+color,2,1);
      put_gfx_trans(x*16,y*16,nchar,$80+color,3,1);
      gfx[1].buffer[f]:=false;
    end;
end;
scroll__x(2,4,scroll_x);
draw_sprites($1,false);
scroll__x(3,4,scroll_x);
draw_sprites($9,false);
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=f mod 32;
      y:=f div 32;
      nchar:=memoria[$0+f];
      put_gfx_trans(x*8,y*8,nchar,0,1,0);
      gfx[0].buffer[f]:=false;
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(8,8,240,240,4);
end;

procedure update_video_darwin;
var
  x,y,atrib:byte;
  f:word;
  nchar,color:word;
begin
for f:=0 to $1ff do begin
    if gfx[1].buffer[f] then begin
      x:=f mod 16;
      y:=31-(f div 16);
      atrib:=memoria[$1c01+(f*2)];
      nchar:=memoria[$1c00+(f*2)]+((atrib and $3) shl 8);
      color:=(bg_color+((atrib and $4) shr 2)) shl 3;
      put_gfx(x*16,y*16,nchar,$80+color,2,1);
      put_gfx_trans(x*16,y*16,nchar,$80+color,3,1);
      gfx[1].buffer[f]:=false;
    end;
end;
scroll__y(2,4,256-scroll_x);
draw_sprites($1,true);
scroll__y(3,4,256-scroll_x);
draw_sprites($9,true);
for f:=0 to $3ff do begin
    if gfx[0].buffer[f] then begin
      x:=f div 32;
      y:=31-(f mod 32);
      nchar:=memoria[$1000+f];
      put_gfx_trans(x*8,y*8,nchar,0,1,0);
      gfx[0].buffer[f]:=false;
    end;
end;
actualiza_trozo(0,0,256,256,1,0,0,256,256,4);
actualiza_trozo_final(8,8,240,240,4);
end;

function iniciar_brkthru:boolean; 
var
      colores:tpaleta;
      bit0,bit1,bit2,bit3:byte;
      f:word;
      memoria_temp:array[0..$1ffff] of byte;
const
    pc_x:array[0..7] of dword=(256*8*8+0, 256*8*8+1, 256*8*8+2, 256*8*8+3, 0, 1, 2, 3);
    pc_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
    ps_x:array[0..15] of dword=(16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+4, 16*8+5, 16*8+6, 16*8+7,
			0, 1, 2, 3, 4, 5, 6, 7);
    ps_y:array[0..15] of dword=( 0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8 );
    pt_x:array[0..15] of dword=(0, 1, 2, 3, 1024*8*8+0, 1024*8*8+1, 1024*8*8+2, 1024*8*8+3,
			16*8+0, 16*8+1, 16*8+2, 16*8+3, 16*8+1024*8*8+0, 16*8+1024*8*8+1, 16*8+1024*8*8+2, 16*8+1024*8*8+3);
    pt_y:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
			8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);

procedure convert_chars(invert:boolean);
begin
  init_gfx(0,8,8,$100);
  gfx[0].trans[0]:=true;
  gfx_set_desc_data(3,0,8*8,512*8*8+4,0,4);
  convert_gfx(@gfx[0],0,@memoria_temp[0],@pc_x[0],@pc_y[0],false,invert);
end;
procedure convert_tiles(invert:boolean);
var
  memoria_temp2:array[0..$1ffff] of byte;
  f:byte;
begin
  copymemory(@memoria_temp2[0],@memoria_temp[0],$4000);	// bitplanes 1,2 for bank 1,2 */
  copymemory(@memoria_temp2[$8000],@memoria_temp[$4000],$4000);  // bitplanes 1,2 for bank 3,4 */
  copymemory(@memoria_temp2[$10000],@memoria_temp[$8000],$4000); // bitplanes 1,2 for bank 5,6 */
  copymemory(@memoria_temp2[$18000],@memoria_temp[$c000],$4000); // bitplanes 1,2 for bank 7,8 */
  copymemory(@memoria_temp2[$4000],@memoria_temp[$10000],$1000); // bitplane 3 for bank 1,2 */
  copymemory(@memoria_temp2[$6000],@memoria_temp[$11000],$1000);
  copymemory(@memoria_temp2[$c000],@memoria_temp[$12000],$1000); // bitplane 3 for bank 3,4 */
  copymemory(@memoria_temp2[$e000],@memoria_temp[$13000],$1000);
  copymemory(@memoria_temp2[$14000],@memoria_temp[$14000],$1000);  // bitplane 3 for bank 5,6 */
  copymemory(@memoria_temp2[$16000],@memoria_temp[$15000],$1000);
  copymemory(@memoria_temp2[$1c000],@memoria_temp[$16000],$1000); // bitplane 3 for bank 7,8 */
  copymemory(@memoria_temp2[$1e000],@memoria_temp[$17000],$1000);
  init_gfx(1,16,16,$400);
  gfx[1].trans[0]:=true;
  for f:=0 to 3 do begin
    gfx_set_desc_data(3,8,32*8,$4000*8+4,0,4);
    convert_gfx(@gfx[1],(f*2)*16*16*$80,@memoria_temp2[$8000*f],@pt_x[0],@pt_y[0],false,invert);
    gfx_set_desc_data(3,8,32*8,$3000*8+0,0,4);
    convert_gfx(@gfx[1],((f*2)+1)*16*16*$80,@memoria_temp2[($8000*f)+$1000],@pt_x[0],@pt_y[0],false,invert);
  end;
end;
procedure convert_sprt(invert:boolean);
begin
  init_gfx(2,16,16,$400);
  gfx[2].trans[0]:=true;
  gfx_set_desc_data(3,0,32*8,2*1024*32*8,1024*32*8,0);
  convert_gfx(@gfx[2],0,@memoria_temp[0],@ps_x[0],@ps_y[0],false,invert);
end;

begin
iniciar_brkthru:=false;
iniciar_audio(false);
//Pantallas:  principal+char y sprites
screen_init(1,256,256,true);
screen_init(2,512,512);
screen_mod_scroll(2,512,256,511,512,256,511);
screen_init(3,512,512,true);
screen_mod_scroll(3,512,256,511,512,256,511);
screen_init(4,512,512,false,true);
iniciar_video(240,240);
//Main CPU
main_m6809:=cpu_m6809.Create(1500000,272);
//Sound CPU
snd_m6809:=cpu_m6809.Create(1500000,272);
snd_m6809.change_ram_calls(brkthru_snd_getbyte,brkthru_snd_putbyte);
snd_m6809.init_sound(brkthru_sound_update);
//Sound Chip
ym2203_0:=ym2203_chip.create(0,1500000,4);
ym3812_init(0,3000000,brkthru_snd_irq);
case main_vars.tipo_maquina of
  89:begin
        main_m6809.change_ram_calls(brkthru_getbyte,brkthru_putbyte);
        proc_update_video:=update_video_brkthru;
        //cargar roms y ponerlas en su sitio
        if not(cargar_roms(@memoria_temp[0],@brkthru_rom[0],'brkthru.zip',0)) then exit;
        copymemory(@memoria[$4000],@memoria_temp[0],$c000);
        for f:=0 to 7 do copymemory(@rom[f,0],@memoria_temp[$c000+(f*$2000)],$2000);
        //roms sonido
        if not(cargar_roms(@mem_snd[0],@brkthru_snd,'brkthru.zip',1)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@brkthru_char,'brkthru.zip',1)) then exit;
        convert_chars(false);
        //convertir tiles y organizar
        if not(cargar_roms(@memoria_temp[0],@brkthru_tiles[0],'brkthru.zip',0)) then exit;
        convert_tiles(false);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@brkthru_sprites[0],'brkthru.zip',0)) then exit;
        convert_sprt(false);
        //paleta
        if not(cargar_roms(@memoria_temp[0],@brkthru_pal[0],'brkthru.zip',0)) then exit;
     end;
  90:begin
        main_m6809.change_ram_calls(darwin_getbyte,darwin_putbyte);
        proc_update_video:=update_video_darwin;
        //cargar roms y ponerlas en su sitio
        if not(cargar_roms(@memoria_temp[0],@darwin_rom[0],'darwin.zip',0)) then exit;
        copymemory(@memoria[$4000],@memoria_temp[0],$c000);
        for f:=0 to 7 do copymemory(@rom[f,0],@memoria_temp[$c000+(f*$2000)],$2000);
        //roms sonido
        if not(cargar_roms(@mem_snd[0],@darwin_snd,'darwin.zip',1)) then exit;
        //convertir chars
        if not(cargar_roms(@memoria_temp[0],@darwin_char,'darwin.zip',1)) then exit;
        convert_chars(true);
        //convertir tiles y organizar
        if not(cargar_roms(@memoria_temp[0],@darwin_tiles[0],'darwin.zip',0)) then exit;
        convert_tiles(true);
        //convertir sprites
        if not(cargar_roms(@memoria_temp[0],@darwin_sprites[0],'darwin.zip',0)) then exit;
        convert_sprt(true);
        //paleta
        if not(cargar_roms(@memoria_temp[0],@darwin_pal[0],'darwin.zip',0)) then exit;
     end;
end;
for f:=0 to $ff do begin
    bit0:=(memoria_temp[f] shr 0) and $01;
		bit1:=(memoria_temp[f] shr 1) and $01;
		bit2:=(memoria_temp[f] shr 2) and $01;
    bit3:=(memoria_temp[f] shr 3) and $01;
		colores[f].r:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		bit0:=(memoria_temp[f] shr 4) and $01;
		bit1:=(memoria_temp[f] shr 5) and $01;
		bit2:=(memoria_temp[f] shr 6) and $01;
    bit3:=(memoria_temp[f] shr 7) and $01;
		colores[f].g:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
		bit0:=(memoria_temp[f+$100] shr 0) and $01;
		bit1:=(memoria_temp[f+$100] shr 1) and $01;
		bit2:=(memoria_temp[f+$100] shr 2) and $01;
    bit3:=(memoria_temp[f+$100] shr 3) and $01;
		colores[f].b:=$0e*bit0+$1f*bit1+$43*bit2+$8f*bit3;
end;
set_pal(colores,$100);
//final
reset_brkthru;
iniciar_brkthru:=true;
end;

procedure cerrar_brkthru; 
begin
main_m6809.Free;
snd_m6809.Free;
ym2203_0.Free;
ym3812_close(0);
close_audio;
close_video;
end;

procedure reset_brkthru;
begin
 main_m6809.reset;
 snd_m6809.reset;
 ym2203_0.reset;
 ym3812_reset(0);
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 rom_bank:=0;
 scroll_x:=0;
 old_val:=false;
 old_val2:=false;
 sound_latch:=0;
 bg_color:=0;
 nmi_ena:=true;
end;

procedure eventos_brkthru;
begin
if event.arcade then begin
  //p1
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.down[0] then marcade.in0:=marcade.in0 and $fb else marcade.in0:=marcade.in0 or 4;
  if arcade_input.up[0] then marcade.in0:=marcade.in0 and $f7 else marcade.in0:=marcade.in0 or 8;
  if arcade_input.left[0] then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
  if arcade_input.right[0] then marcade.in0:=marcade.in0 and $df else marcade.in0:=marcade.in0 or $20;
  if arcade_input.start[0] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.start[1] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
  //misc
  if (arcade_input.coin[0] and not(old_val)) then begin
      marcade.in2:=(marcade.in2 and $df);
      main_m6809.pedir_irq:=HOLD_LINE;
  end else begin
      marcade.in2:=(marcade.in2 or $20);
  end;
  if (arcade_input.coin[1] and not(old_val2)) then begin
      marcade.in2:=(marcade.in2 and $bf);
      main_m6809.pedir_irq:=HOLD_LINE;
  end else begin
      marcade.in2:=(marcade.in2 or $40);
  end;
  old_val:=arcade_input.coin[0];
  old_val2:=arcade_input.coin[1];
end;
end;

procedure brkthru_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=main_m6809.tframes;
frame_s:=snd_m6809.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 271 do begin
    //main
    main_m6809.run(frame_m);
    frame_m:=frame_m+main_m6809.tframes-main_m6809.contador;
    //snd
    snd_m6809.run(frame_s);
    frame_s:=frame_s+snd_m6809.tframes-snd_m6809.contador;
    if f=247 then begin
      if nmi_ena then main_m6809.pedir_nmi:=PULSE_LINE;
      proc_update_video;
    end;
  end;
  eventos_brkthru;
  video_sync;
end;
end;

function brkthru_getbyte(direccion:word):byte;
begin
case direccion of
    0..$fff,$1100..$17ff,$4000..$ffff:brkthru_getbyte:=memoria[direccion];
    $1000..$10ff:brkthru_getbyte:=mem_sprt[direccion and $ff];
    $1800:brkthru_getbyte:=marcade.in0;
    $1801:brkthru_getbyte:=$7f;
    $1802:brkthru_getbyte:=$3f;
    $1803:brkthru_getbyte:=marcade.in2;
    $2000..$3fff:brkthru_getbyte:=rom[rom_bank,direccion and $1fff];
end;
end;

procedure brkthru_putbyte(direccion:word;valor:byte);
begin
if direccion>$1fff then exit;
memoria[direccion]:=valor;
case direccion of
    $0..$3ff:gfx[0].buffer[direccion]:=true;
    $c00..$fff:gfx[1].buffer[(direccion and $3ff) shr 1]:=true;
    $1000..$10ff:mem_sprt[direccion and $ff]:=valor;
    $1800:scroll_x:=(scroll_x and $ff00) or valor;
    $1801:begin
            rom_bank:=valor and $7;
            if ((valor and $38) shr 2)<>bg_color then begin
              bg_color:=(valor and $38) shr 2;
              fillchar(gfx[1].buffer[0],$200,1);
            end;
            scroll_x:=(scroll_x and $00ff) or ((valor shr 7) shl 8);
          end;
    $1802:begin
            sound_latch:=valor;
            snd_m6809.pedir_nmi:=PULSE_LINE;
          end;
    $1803:nmi_ena:=((valor and 1)=0);
end;
end;

function darwin_getbyte(direccion:word):byte;
begin
case direccion of
    0..$ff:darwin_getbyte:=mem_sprt[direccion];
    $1000..$1fff,$4000..$ffff:darwin_getbyte:=memoria[direccion];
    $800:darwin_getbyte:=marcade.in0;
    $801:darwin_getbyte:=$7f;
    $802:darwin_getbyte:=$df;
    $803:darwin_getbyte:=marcade.in2;
    $2000..$3fff:darwin_getbyte:=rom[rom_bank,direccion and $1fff];
end;
end;

procedure darwin_putbyte(direccion:word;valor:byte);
begin
if direccion>$1fff then exit;
memoria[direccion]:=valor;
case direccion of
    $0..$ff:mem_sprt[direccion]:=valor;
    $800:scroll_x:=(scroll_x and $ff00) or valor;
    $801:begin
            rom_bank:=valor and $7;
            if ((valor and $38) shr 2)<>bg_color then begin
              bg_color:=(valor and $38) shr 2;
              fillchar(gfx[1].buffer[0],$200,1);
            end;
            scroll_x:=(scroll_x and $00ff) or ((valor shr 7) shl 8);
          end;
    $802:begin
            sound_latch:=valor;
            snd_m6809.pedir_nmi:=PULSE_LINE;
          end;
    $803:nmi_ena:=(valor and 1)<>0;
    $1000..$13ff:gfx[0].buffer[direccion and $3ff]:=true;
    $1c00..$1fff:gfx[1].buffer[(direccion and $3ff) shr 1]:=true;
end;
end;

function brkthru_snd_getbyte(direccion:word):byte;
begin
case direccion of
  $0..$1fff,$8000..$ffff:brkthru_snd_getbyte:=mem_snd[direccion];
  $4000:brkthru_snd_getbyte:=sound_latch;
  $6000:brkthru_snd_getbyte:=ym2203_0.read_status;
end;
end;

procedure brkthru_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$7fff then exit;
case direccion of
  $0..$1fff:mem_snd[direccion]:=valor;
  $2000:YM3812_control_port(0,valor);
	$2001:YM3812_write_port(0,valor);
	$6000:ym2203_0.control(valor);
	$6001:ym2203_0.write_reg(valor);
end;
end;

procedure brkthru_snd_irq(irqstate:byte);
begin
  if (irqstate<>0) then snd_m6809.pedir_irq:=ASSERT_LINE
    else snd_m6809.pedir_irq:=CLEAR_LINE;
end;

procedure brkthru_sound_update;
begin
  YM2203_0.Update;
  YM3812_Update(0);
end;

end.
