unit outrun_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,
     dialogs,sysutils,pal_engine,ppi8255,sound_engine,ym_2151;

procedure Cargar_outrun;
procedure outrun_principal;
function outrun_getword(direccion:dword;putbyte:boolean):word;
procedure outrun_putword(direccion:dword;valor:word);
function iniciar_outrun:boolean;
procedure reset_outrun;
procedure cerrar_outrun;
function outrun_snd_getbyte(direccion:word):byte;
procedure outrun_snd_putbyte(direccion:word;valor:byte);
procedure outrun_sound_act;
function outrun_snd_inbyte(puerto:word):byte;
procedure outrun_snd_outbyte(valor:byte;puerto:word);
procedure ppi8255_wporta(valor:byte);
procedure ppi8255_wportb(valor:byte);
procedure ppi8255_wportc(valor:byte);
procedure ym2151_snd_irq(irqstate:byte);

const
        //Outrun
        outrun_rom:array[0..4] of tipo_roms=(
        (n:'epr-10380b.133';l:$10000;p:0;crc:$1f6cadad),(n:'epr-10382b.118';l:$10000;p:$1;crc:$c4c3fa1a),
        (n:'epr-10381b.132';l:$10000;p:$20000;crc:$be8c412b),(n:'epr-10383b.117';l:$10000;p:$20001;crc:$10a2014a),());
        outrun_sub:array[0..4] of tipo_roms=(
        (n:'epr-10327a.76';l:$10000;p:0;crc:$e28a5baf),(n:'epr-10329a.58';l:$10000;p:$1;crc:$da131c81),
        (n:'epr-10328a.75';l:$10000;p:$20000;crc:$d5ec5e5d),(n:'epr-10330a.57';l:$10000;p:$20001;crc:$ba9ec82a),());
        outrun_sound:tipo_roms=(n:'epr-10187.88';l:$8000;p:0;crc:$a10abaa9);
        outrun_tiles:array[0..6] of tipo_roms=(
        (n:'opr-10268.99';l:$8000;p:0;crc:$95344b04),(n:'opr-10232.102';l:$8000;p:$8000;crc:$776ba1eb),
        (n:'opr-10267.100';l:$8000;p:$10000;crc:$a85bb823),(n:'opr-10231.103';l:$8000;p:$18000;crc:$8908bcbf),
        (n:'opr-10266.101';l:$8000;p:$20000;crc:$9f6f1a74),(n:'opr-10230.104';l:$8000;p:$28000;crc:$686f5e50),());
        outrun_sprites:array[0..8] of tipo_roms=(
        (n:'epr-11290.10';l:$10000;p:1;crc:$611f413a),(n:'epr-11294.11';l:$10000;p:$0;crc:$5eb00fc1),
        (n:'epr-11291.17';l:$10000;p:$20001;crc:$3c0797c0),(n:'epr-11295.18';l:$10000;p:$20000;crc:$25307ef8),
        (n:'epr-11292.23';l:$10000;p:$40001;crc:$c29ac34e),(n:'epr-11296.24';l:$10000;p:$40000;crc:$04a437f8),
        (n:'epr-11293.29';l:$10000;p:$60001;crc:$41f41063),(n:'epr-11297.30';l:$10000;p:$60000;crc:$b6e1fd72),());

type
  tsystem16_info=record
    	entries:word;						// number of entries (not counting shadows) */
					// RGB translations for normal pixels */
  				// RGB translations for shadowed pixels */
    	normal,shadow,hilight:array[0..31] of byte;	// RGB translations for hilighted pixels */
      color_base:word;
      s_banks:byte;
   end;

var
 rom:array[0..$1ffff] of word;
 ram:array[0..$1fff] of word;
 tile_ram:array[0..$7fff] of byte;
 tile_buffer:array[0..$3fff] of boolean;
 char_ram:array[0..$fff] of byte;
 sprite_ram:array[0..$7ff] of byte;
 sprite_rom:array[0..$7ffff] of byte;
 sprite_bank:array[0..$f] of byte;
 s16_info:tsystem16_info;
 s16_screen:array[0..7] of byte;
 screen_enabled:boolean;
 sound_latch:byte;

implementation

procedure Cargar_outrun;
begin
llamadas_maquina.iniciar:=iniciar_outrun;
llamadas_maquina.bucle_general:=outrun_principal;
llamadas_maquina.cerrar:=cerrar_outrun;
llamadas_maquina.reset:=reset_outrun;
end;

function iniciar_outrun:boolean;
var
      f:word;
      memoria_temp:array[0..$7ffff] of byte;
      weights:array[0..1,0..5] of single;
      i0,i1,i2,i3,i4:integer;
const
  pt_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7 );
  pt_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
  resistances_normal:array[0..5] of integer=(900, 2000, 1000, 1000 div 2,1000 div 4, 0);
	resistances_sh:array[0..5] of integer=(3900, 2000, 1000, 1000 div 2, 1000 div 4, 470);
begin
iniciar_outrun:=false;
iniciar_audio(false);
screen_init(1,512,256,true); //text
screen_init(2,512,256,true);
//Background
screen_init(3,1024,512);
screen_mod_scroll(3,1024,512,1023,512,256,511);
screen_init(4,1024,512,true);
screen_mod_scroll(4,1024,512,1023,512,256,511);
//Foreground
screen_init(5,1024,512,true);
screen_mod_scroll(5,1024,512,1023,512,256,511);
screen_init(6,1024,512,true);
screen_mod_scroll(6,1024,512,1023,512,256,511);
//Final
screen_init(7,512,256,false,true);
iniciar_video(320,224);
//Main CPU
main_m68000:=cpu_m68000.create(10000000,262);
main_m68000.change_ram16_calls(outrun_getword,outrun_putword);
//Sound CPU
snd_z80:=cpu_z80.create(4000000,262);
snd_z80.change_ram_calls(outrun_snd_getbyte,outrun_snd_putbyte);
snd_z80.change_io_calls(outrun_snd_inbyte,outrun_snd_outbyte);
snd_z80.init_sound(outrun_sound_act);
//PPI 825
init_ppi8255(0,nil,nil,nil,ppi8255_wporta,ppi8255_wportb,ppi8255_wportc);
//Timers
YM2151_Init(0,4000000,nil,ym2151_snd_irq);
//cargar roms
if not(cargar_roms16w(@rom[0],@outrun_rom[0],'outrun.zip',0)) then exit;
//cargar sonido
if not(cargar_roms(@mem_snd[0],@outrun_sound,'outrun.zip',1)) then exit;
//convertir tiles
if not(cargar_roms(@memoria_temp[0],@outrun_tiles[0],'outrun.zip',0)) then exit;
init_gfx(0,8,8,$2000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,$20000*8,$10000*8,0);
convert_gfx(@gfx[0],0,@memoria_temp[0],@pt_x[0],@pt_y[0],false,false);
//Cargar ROM de los sprites y recolocarlos
{if not(cargar_roms16b(@memoria_temp[0],@outrun_sprites[0],'outrun.zip',0)) then exit;
for f:=0 to 7 do begin
  copymemory(@sprite_rom[0],@memoria_temp[0],$10000);
  copymemory(@sprite_rom[$40000],@memoria_temp[$10000],$10000);
  copymemory(@sprite_rom[$10000],@memoria_temp[$20000],$10000);
  copymemory(@sprite_rom[$50000],@memoria_temp[$30000],$10000);
  copymemory(@sprite_rom[$20000],@memoria_temp[$40000],$10000);
  copymemory(@sprite_rom[$60000],@memoria_temp[$50000],$10000);
  copymemory(@sprite_rom[$30000],@memoria_temp[$60000],$10000);
  copymemory(@sprite_rom[$70000],@memoria_temp[$70000],$10000);
end;}
s16_info.entries:=$800;
s16_info.color_base:=$400;
s16_info.s_banks:=8;
//poner la paleta
compute_resistor_weights(0,255,-1.0,
  6,addr(resistances_normal[0]),addr(weights[0]),0,0,
  0,nil,nil,0,0,
  0,nil,nil,0,0);
compute_resistor_weights(0,255,-1.0,
  6,addr(resistances_sh[0]),addr(weights[1]),0,0,
  0,nil,nil,0,0,
  0,nil,nil,0,0);
for f:=0 to 31 do begin
  i4:=(f shr 4) and 1;
  i3:=(f shr 3) and 1;
  i2:=(f shr 2) and 1;
  i1:=(f shr 1) and 1;
  i0:=(f shr 0) and 1;
  s16_info.normal[f]:=combine_6_weights(addr(weights[0]),i0,i1,i2,i3,i4,0);
  s16_info.shadow[f]:=combine_6_weights(addr(weights[1]),i0,i1,i2,i3,i4,0);
  s16_info.hilight[f]:=combine_6_weights(addr(weights[1]),i0,i1,i2,i3,i4,1);
end;
//final
reset_outrun;
iniciar_outrun:=true;
end;

procedure outrun_draw_pixel(x,y,pix,color:word);inline;
var
  punt:word;
begin
  // only draw if onscreen, not 0 or 15 */
	if ((x<512) and (pix<>0) and (pix<>15)) then begin
			/// shadow/hilight mode? */
			if (color=(s16_info.color_base+($3f shl 4))) then begin
        punt:=paleta[pix+color+s16_info.entries];//dest[x] += (segaic16_paletteram[dest[x]] & 0x8000) ? segaic16_palette.entries*2 : segaic16_palette.entries
      end else begin
        punt:=paleta[pix+color];  // regular draw
      end;
      putpixel(x+32,y+32,1,addr(punt),7);
	end;
end;

//Cada sprite 16bytes (8 words)
//parte alta 0
procedure draw_sprites(pri:byte;last_sprite:integer);inline;
var
  sprpri:byte;
  f:integer;
  bottom,top:word;
  xpos,addr,bank,x,y,pix,data_7,pixels:word;
  pitch:integer;
  spritedata,color:dword;
begin
  for f:=0 to last_sprite do begin
    sprpri:=sprite_ram[(f*$10)+9] and $3;
    if sprpri<>pri then continue;
    bank:=sprite_bank[(sprite_ram[(f*$10)+9] shr 4) and $7];
    top:=(sprite_ram[(f*$10)+1])+1;
		bottom:=(sprite_ram[(f*$10)+0])+1;
    // if hidden, or top greater than/equal to bottom, or invalid bank, punt */
		if ((top>=bottom) or (bank=255)) then continue;
		xpos:=(((sprite_ram[(f*$10)+2] shl 8)+sprite_ram[(f*$10)+3]) and $1ff)-$bd;
		pitch:=smallint((sprite_ram[(f*$10)+4] shl 8)+sprite_ram[(f*$10)+5]);
		addr:=((sprite_ram[(f*$10)+6] shl 8)+sprite_ram[(f*$10)+7]);
		color:=s16_info.color_base+((sprite_ram[(f*$10)+8] and $3f) shl 4);
		// initialize the end address to the start address */
    sprite_ram[(f*$10)+$e]:=addr shr 8;
    sprite_ram[(f*$10)+$f]:=addr and $ff;
		// clamp to within the memory region size */
		bank:=bank mod s16_info.s_banks;
		spritedata:=$8000*bank;
		// loop from top to bottom */
		for y:=top to (bottom-1) do begin
			// advance a row */
			addr:=addr+pitch;
			// skip drawing if not within the cliprect
			if (y<=256) then begin
				// note that the System 16A sprites have a design flaw that allows the address */
				// to carry into the flip flag, which is the topmost bit -- it is very important */
				// to emulate this as the games compensate for it */
				// non-flipped case */
				if (addr and $8000)=0 then begin
					// start at the word before because we preincrement below */
          sprite_ram[(f*$10)+$e]:=(addr-1) shr 8;
          sprite_ram[(f*$10)+$f]:=(addr-1) and $ff;
					x:=xpos;
          while ((xpos-x) and $1ff)<>1 do begin
            data_7:=((sprite_ram[(f*$10)+$e] shl 8)+sprite_ram[(f*$10)+$f]);
            data_7:=data_7+1;
            sprite_ram[(f*$10)+$e]:=data_7 shr 8;
            sprite_ram[(f*$10)+$f]:=data_7 and $ff;
						pixels:=(sprite_rom[(spritedata+(data_7 and $7fff)) shl 1] shl 8)+sprite_rom[((spritedata+(data_7 and $7fff)) shl 1)+1];
						// draw four pixels */
						pix:=(pixels shr 12) and $f;
            outrun_draw_pixel(x,y,pix,color);x:=x+1;
						pix:=(pixels shr 8) and $f;
            outrun_draw_pixel(x,y,pix,color);x:=x+1;
						pix:=(pixels shr 4) and $f;
            outrun_draw_pixel(x,y,pix,color);x:=x+1;
						pix:=(pixels shr 0) and $f;
            outrun_draw_pixel(x,y,pix,color);x:=x+1;
						// stop if the last pixel in the group was 0xf */
						if (pix=15) then break;
					end;
				end else begin
				// flipped case */
					// start at the word after because we predecrement below */
          sprite_ram[(f*$10)+$e]:=(addr+1) shr 8;
          sprite_ram[(f*$10)+$f]:=(addr+1) and $ff;
					x:=xpos;
          while ((xpos-x) and $1ff)<>1 do begin
            data_7:=((sprite_ram[(f*$10)+$e] shl 8)+sprite_ram[(f*$10)+$f]);
            data_7:=data_7-1;
            sprite_ram[(f*$10)+$e]:=data_7 shr 8;
            sprite_ram[(f*$10)+$f]:=data_7 and $ff;
						pixels:=(sprite_rom[(spritedata+(data_7 and $7fff)) shl 1] shl 8)+sprite_rom[((spritedata+(data_7 and $7fff)) shl 1)+1];
						// draw four pixels */
						pix:=(pixels shr 0) and $f;
            outrun_draw_pixel(x,y,pix,color);x:=x+1;
						pix:=(pixels shr 4) and $f;
            outrun_draw_pixel(x,y,pix,color);x:=x+1;
						pix:=(pixels shr 8) and $f;
            outrun_draw_pixel(x,y,pix,color);x:=x+1;
						pix:=(pixels shr 12) and $f;
            outrun_draw_pixel(x,y,pix,color);x:=x+1;
						// stop if the last pixel in the group was 0xf */
						if (pix=15) then break;
					end;
				end;
			end;
		end;
	end;
end;

procedure draw_tiles(num:byte;px,py:word;scr:byte;trans:boolean);inline;
var
  pos,f,nchar,color,data:word;
  x,y:word;
begin
  pos:=s16_screen[num]*$800;
  for f:=$0 to $7ff do begin
    data:=(tile_ram[$0+(pos*2)] shl 8) or tile_ram[$1+(pos*2)];
    color:=(data shr 5) and $7f;
    if ((tile_buffer[(num*$800)+f]) or (buffer_color[color])) then begin
      x:=((f and $3f) shl 3)+px;
      y:=((f shr 6) shl 3)+py;
      nchar:=((data shr 1) and $1000) or (data and $fff);
      if trans then begin
        put_gfx_trans(x,y,nchar,color shl 3,scr,0);
        if ((data shr 12) and 1)<>1 then put_gfx_trans(x,y,nchar,color shl 3,scr+1,0)
          else put_gfx_block_trans(x,y,scr+1,8,8);
      end else begin
        put_gfx(x,y,nchar,color shl 3,scr,0);
        if ((data shr 12) and 1)<>1 then put_gfx(x,y,nchar,color shl 3,scr+1,0)
          else put_gfx_block(x,y,scr+1,8,8,$1fff);
      end;
      tile_buffer[(num*$800)+f]:=false;
    end;
    pos:=pos+1;
  end;
end;

procedure update_video_outrun;inline;
var
  f,nchar,color,scroll_x1,scroll_x2,x,y:word;
  scroll_y1,scroll_y2:byte;
  last_sprite:integer;
begin
if not(screen_enabled) then begin
  fill_full_screen(7,$1fff);
  actualiza_trozo_final(0,0,320,224,7);
  exit;
end;
{//Background
draw_tiles(0,0,256,3,false);
draw_tiles(1,512,256,3,false);
draw_tiles(2,0,0,3,false);
draw_tiles(3,512,0,3,false);
scroll_x1:=((char_ram[$ffa] shl 8) or char_ram[$ffb]) and $1ff;
scroll_x1:=($c8-scroll_x1) and $3ff;
scroll_y1:=char_ram[$f27];
//Foreground
draw_tiles(4,0,256,5,true);
draw_tiles(5,512,256,5,true);
draw_tiles(6,0,0,5,true);
draw_tiles(7,512,0,5,true);
scroll_x2:=((char_ram[$ff8] shl 8) or char_ram[$ff9]) and $1ff;
scroll_x2:=($c8-scroll_x2) and $3ff;
scroll_y2:=char_ram[$f25];
fillchar(gfx[1].color_buffer[0],$80,0);}
//text
for f:=$0 to $6ff do begin
  color:=(char_ram[$0+(f*2)]) and $7;
  if ((gfx[0].buffer[f]) or (buffer_color[color])) then begin
    x:=(f and $3f) shl 3;
    y:=(f shr 6) shl 3;
    nchar:=char_ram[$1+(f*2)];
    put_gfx_trans(x,y,nchar,color shl 3,1,0);
    if ((nchar shr 11) and 1)<>0 then put_gfx_trans(x,y,nchar,color shl 3,2,0)
      else put_gfx_block_trans(x,y,2,8,8);
    gfx[0].buffer[f]:=false;
  end;
end;
//buscar el ultimo sprite de la lista...
{last_sprite:=-1;
for f:=0 to $7f do begin
  if sprite_ram[(f*$10)+1]>$f0 then begin
    last_sprite:=f;
    break;
  end;
end;}
//Lo pongo todo con prioridades, falta scrollrow y scrollcol!!
//scroll_x_y(3,7,scroll_x1,scroll_y1);
//draw_sprites(0,last_sprite);
//scroll_x_y(4,7,scroll_x1,scroll_y1);
//scroll_x_y(5,7,scroll_x2,scroll_y2);
//draw_sprites(1,last_sprite);
//scroll_x_y(6,7,scroll_x2,scroll_y2);
actualiza_trozo(192,0,320,224,2,0,0,320,224,7);
//draw_sprites(2,last_sprite);
//actualiza_trozo(192,0,320,224,1,0,0,320,224,7);
//draw_sprites(3,last_sprite);
//Y lo pinto a la pantalla principal
actualiza_trozo_final(0,0,320,224,7);
fillchar(buffer_color[0],MAX_COLOR_BUFFER,0);
end;

procedure eventos_outrun;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $eF) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $7f) else marcade.in1:=(marcade.in1 or $80);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $bF) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $fe) else marcade.in1:=(marcade.in1 or $1);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $df) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $eF) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $7f) else marcade.in2:=(marcade.in2 or $80);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $bF) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $fb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $fd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $fe) else marcade.in2:=(marcade.in2 or $1);
  //Service
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $df) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fd) else marcade.in0:=(marcade.in0 or $2);
end;
end;

procedure cerrar_outrun;
begin
main_m68000.free;
snd_z80.free;
close_ppi8255(0);
YM2151_close(0);
close_audio;
close_video;
end;

procedure reset_outrun;
var
  f:byte;
begin
 main_m68000.reset;
 snd_z80.reset;
 YM2151_reset(0);
 reset_ppi8255(0);
 reset_audio;
 marcade.in0:=$FF;
 marcade.in1:=$FF;
 marcade.in2:=$FF;
 for f:=0 to $f do sprite_bank[f]:=f;
 screen_enabled:=true;
 fillchar(tile_buffer[0],$800*8,1);
 sound_latch:=0;
end;

procedure outrun_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=main_m68000.tframes;
frame_s:=snd_z80.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
     //main
     main_m68000.run(frame_m);
     frame_m:=frame_m+main_m68000.tframes-main_m68000.contador;
     //sound
     snd_z80.run(frame_s);
     frame_s:=frame_s+snd_z80.tframes-snd_z80.contador;
     if f=223 then begin
       main_m68000.irq[4]:=HOLD_LINE;
       update_video_outrun;
     end;
  end;
  eventos_outrun;
  video_sync;
end;
end;

function standar_s16_io_r(direccion:word):word;inline;
var
  res:word;
begin
case (direccion and $3000) of
	$0000:res:=ppi8255_r(0,(direccion shr 1) and 3);
	$1000:case (direccion and 7) of
          0,1:res:=marcade.in0; //SERVICE
          2,3:res:=marcade.in1; //P1
          4,5:res:=$ff; //UNUSED
          6,7:res:=marcade.in2; //P2
       end;
  $2000:case (direccion and $3) of
                  0,1:res:=$ff; //DSW1
                  2,3:res:=$ff; //DSW2
               end;
  else res:=$ffff;
	end;
standar_s16_io_r:=res;
end;

function outrun_getword(direccion:dword;putbyte:boolean):word;
begin
direccion:=direccion and $fffffe;
case direccion of
    0..$3fffff:outrun_getword:=rom[(direccion and $3ffff) shr 1];
    $400000..$7fffff:case (direccion and $7ffff) of
                        $00000..$0ffff:outrun_getword:=(tile_ram[direccion and $7fff] shl 8) or tile_ram[(direccion+1) and $7fff];
                        $10000..$1ffff:outrun_getword:=(char_ram[direccion and $fff] shl 8) or char_ram[(direccion+1) and $fff];
                        $40000..$7ffff:outrun_getword:=(sprite_ram[direccion and $7ff] shl 8) or sprite_ram[(direccion+1) and $7ff];
                          else outrun_getword:=$ffff;
                     end;
    $800000..$bfffff:case (direccion and $fffff) of
                        $40000..$7ffff:outrun_getword:=buffer_paleta[(direccion and $fff) shr 1];
                          else outrun_getword:=$ffff;
                     end;
    $c00000..$ffffff:case (direccion and $7ffff) of
                        $00000..$0ffff:outrun_getword:=(tile_ram[direccion and $7fff] shl 8) or tile_ram[(direccion+1) and $7fff];
                        $10000..$1ffff:outrun_getword:=(char_ram[direccion and $fff] shl 8) or char_ram[(direccion+1) and $fff];
                        $40000..$5ffff:outrun_getword:=standar_s16_io_r(direccion and $3fff);  //misc_io
                        $60000..$6ffff:outrun_getword:=$ffff;  //watch dog
                        $70000..$7ffff:outrun_getword:=ram[(direccion and $3fff) shr 1];
    end;
end;
end;

procedure test_screen_change(direccion:word);inline;
begin
case direccion of
  $e9c..$e9f:begin //Background abajo 1-2
          if ((char_ram[$e9c] shr 4) and $7)<>s16_screen[0] then begin
            s16_screen[0]:=(char_ram[$e9c] shr 4) and $7;
            fillchar(tile_buffer[$800*0],$800,1);
          end;
          if (char_ram[$e9c] and $7)<>s16_screen[1] then begin
            s16_screen[1]:=char_ram[$e9c] and $7;
            fillchar(tile_buffer[$800*1],$800,1);
          end;
            //Background arriba 1-2
          if ((char_ram[$e9d] shr 4) and $7)<>s16_screen[2] then begin
            s16_screen[2]:=(char_ram[$e9d] shr 4) and $7;
            fillchar(tile_buffer[$800*2],$800,1);
          end;
          if (char_ram[$e9d] and $7)<>s16_screen[3] then begin
            s16_screen[3]:=char_ram[$e9d] and $7;
            fillchar(tile_buffer[$800*3],$800,1);
          end;
            //Foreground abajo
          if ((char_ram[$e9e] shr 4) and $7)<>s16_screen[4] then begin
            s16_screen[4]:=(char_ram[$e9e] shr 4) and $7;
            fillchar(tile_buffer[$800*4],$800,1);
          end;
          if (char_ram[$e9e] and $7)<>s16_screen[5] then begin
            s16_screen[5]:=char_ram[$e9e] and $7;
            fillchar(tile_buffer[$800*5],$800,1);
          end;
            //Foreground arriba
          if ((char_ram[$e9f] shr 4) and $7)<>s16_screen[6] then begin
            s16_screen[6]:=(char_ram[$e9f] shr 4) and $7;
            fillchar(tile_buffer[$800*6],$800,1);
          end;
          if (char_ram[$e9f] and $7)<>s16_screen[7] then begin
            s16_screen[7]:=char_ram[$e9f] and $7;
            fillchar(tile_buffer[$800*7],$800,1);
          end;
       end;
end;
end;

procedure change_pal(direccion:word);inline;
var
	val:word;
  color1,color2,color3:tcolor;
  r,g,b:integer;
begin
	// get the new value */
  val:=buffer_paleta[direccion];
	//     byte 0    byte 1 */
	//  sBGR BBBB GGGG RRRR */
	//  x000 4321 4321 4321 */
	r:=((val shr 12) and $01) or ((val shl 1) and $1e);
	g:=((val shr 13) and $01) or ((val shr 3) and $1e);
	b:=((val shr 14) and $01) or ((val shr 7) and $1e);
  //normal
  color1.r:=s16_info.normal[r];
  color1.g:=s16_info.normal[g];
  color1.b:=s16_info.normal[b];
  //shadow
  color2.r:=s16_info.shadow[r];
  color2.g:=s16_info.shadow[g];
  color2.b:=s16_info.shadow[b];
  //hilight
  color3.r:=s16_info.hilight[r];
  color3.g:=s16_info.hilight[g];
  color3.b:=s16_info.hilight[b];
  //Poner colores
  set_pal_color(color1,addr(paleta[direccion]));
  set_pal_color(color2,addr(paleta[direccion+1*s16_info.entries]));
  set_pal_color(color3,addr(paleta[direccion+2*s16_info.entries]));
  buffer_color[(direccion shr 3) and $7]:=true;
  buffer_color[(direccion shr 3) and $7f]:=true;
end;

procedure test_tile_buffer(direccion:word);inline;
var
  num_scr,f:byte;
  pos:word;
begin
  num_scr:=direccion shr 11;
  pos:=direccion and $7ff;
  for f:=0 to 7 do
    if s16_screen[f]=num_scr then tile_buffer[(f shl 11)+pos]:=true;
end;

procedure standard_io_w(direccion,valor:word);inline;
begin
case (direccion and $3000) of
		$0:ppi8255_w(0,(direccion shr 1) and $3,valor and $ff);
end;
end;

procedure outrun_putword(direccion:dword;valor:word);
begin
direccion:=direccion and $fffffe;
case direccion of
    0..$3fffff:exit;
    $400000..$7fffff:case (direccion and $7ffff) of
                        $00000..$0ffff:begin
                                        tile_ram[direccion and $7fff]:=valor shr 8;
                                        tile_ram[(direccion+1) and $7fff]:=valor and $ff;
                                        test_tile_buffer((direccion and $7fff) shr 1);
                                       end;
                        $10000..$1ffff:begin
                                          char_ram[direccion and $fff]:=valor shr 8;
                                          char_ram[(direccion+1) and $fff]:=valor and $ff;
                                          gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                                          test_screen_change(direccion and $fff);
                                       end;
                        $40000..$7ffff:begin
                                          sprite_ram[direccion and $7ff]:=valor shr 8;
                                          sprite_ram[(direccion+1) and $7ff]:=valor and $ff;
                                       end;
                     end;
    $800000..$bfffff:case (direccion and $fffff) of
                        $40000..$7ffff:if (buffer_paleta[(direccion and $fff) shr 1]<>valor) then begin
                                          buffer_paleta[(direccion and $fff) shr 1]:=valor;
                                          change_pal((direccion and $fff) shr 1);
                                       end;
                   end;
    $c00000..$ffffff:case (direccion and $7ffff) of
                        $00000..$0ffff:begin
                                        tile_ram[direccion and $7fff]:=valor shr 8;
                                        tile_ram[(direccion+1) and $7fff]:=valor and $ff;
                                        test_tile_buffer((direccion and $7fff) shr 1);
                                       end;
                        $10000..$1ffff:begin
                                          char_ram[direccion and $fff]:=valor shr 8;
                                          char_ram[(direccion+1) and $fff]:=valor and $ff;
                                          gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                                          test_screen_change(direccion and $fff);
                                       end;
                        $40000..$5ffff:standard_io_w(direccion and $3fff,valor);  //misc_io
                        $70000..$7ffff:ram[(direccion and $3fff) shr 1]:=valor;
                     end;
  end;
end;

function outrun_snd_getbyte(direccion:word):byte;
var
  res:byte;
begin
res:=$ff;
case direccion of
  $0..$7fff,$f800..$ffff:res:=mem_snd[direccion];
  $e800:begin
          ppi8255_set_port(0,2,0);
          res:=sound_latch;
        end;
end;
outrun_snd_getbyte:=res;
end;

procedure outrun_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$f7ff then mem_snd[direccion]:=valor;
end;

function outrun_snd_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$ff;
case (puerto and $ff) of
  $00..$3f:if (puerto and 1)<>0 then res:=YM2151_status_port_read(0);
  $c0..$ff:begin
              ppi8255_set_port(0,2,0);
              res:=sound_latch;
           end;
end;
outrun_snd_inbyte:=res;
end;

procedure outrun_snd_outbyte(valor:byte;puerto:word);
begin
case (puerto and $ff) of
  $00..$3f:case (puerto and 1) of
              0:YM2151_register_port_write(0,valor);
              1:YM2151_data_port_write(0,valor);
           end;
end;
end;

procedure ppi8255_wporta(valor:byte);
begin
  sound_latch:=valor;
end;

procedure ppi8255_wportb(valor:byte);
begin
  screen_enabled:=(valor and $10)<>0;
end;

procedure ppi8255_wportc(valor:byte);
begin
if (valor and $80)<>0 then snd_z80.clear_nmi
  else snd_z80.pedir_nmi:=ASSERT_LINE;
end;

procedure outrun_sound_act;
begin
  ym2151_Update(0);
end;

procedure ym2151_snd_irq(irqstate:byte);
begin
end;

end.
