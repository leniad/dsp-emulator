unit badlands_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,m68000,main_engine,controls_engine,gfx_engine,rom_engine,
     pal_engine,sound_engine,ym_2151,atari_mo,file_engine;

function iniciar_badlands:boolean;

implementation
const
        badlands_rom:array[0..3] of tipo_roms=(
        (n:'136074-1008.20f';l:$10000;p:0;crc:$a3da5774),(n:'136074-1006.27f';l:$10000;p:$1;crc:$aa03b4f3),
        (n:'136074-1009.17f';l:$10000;p:$20000;crc:$0e2e807f),(n:'136074-1007.24f';l:$10000;p:$20001;crc:$99a20c2c));
        badlands_sound:tipo_roms=(n:'136074-1018.9c';l:$10000;p:$0;crc:$a05fd146);
        badlands_back:array[0..5] of tipo_roms=(
        (n:'136074-1012.4n';l:$10000;p:0;crc:$5d124c6c),(n:'136074-1013.2n';l:$10000;p:$10000;crc:$b1ec90d6),
        (n:'136074-1014.4s';l:$10000;p:$20000;crc:$248a6845),(n:'136074-1015.2s';l:$10000;p:$30000;crc:$792296d8),
        (n:'136074-1016.4u';l:$10000;p:$40000;crc:$878f7c66),(n:'136074-1017.2u';l:$10000;p:$50000;crc:$ad0071a3));
        badlands_mo:array[0..2] of tipo_roms=(
        (n:'136074-1010.14r';l:$10000;p:0;crc:$c15f629e),(n:'136074-1011.10r';l:$10000;p:$10000;crc:$fb0b6717),
        (n:'136074-1019.14t';l:$10000;p:$20000;crc:$0e26bff6));
        badlands_proms:array[0..2] of tipo_roms=(
        (n:'74s472-136037-101.7u';l:$200;p:0;crc:$2964f76f),(n:'74s472-136037-102.5l';l:$200;p:$200;crc:$4d4fec6c),
        (n:'74s287-136037-103.4r';l:$100;p:$400;crc:$6c5ccf08));
        badlands_mo_config:atari_motion_objects_config=(
        	gfxindex:1;               // index to which gfx system */
	        bankcount:1;              // number of motion object banks */
	        linked:false;              // are the entries linked? */
	        split:true;               // are the entries split? */
	        reverse:false;            // render in reverse order? */
	        swapxy:false;             // render in swapped X/Y order? */
	        nextneighbor:false;       // does the neighbor bit affect the next object? */
	        slipheight:0;             // pixels per SLIP entry (0 for no-slip) */
	        slipoffset:0;             // pixel offset for SLIPs */
	        maxperline:0;             // maximum number of links to visit/scanline (0=all) */
	        palettebase:$80;         // base palette entry */
	        maxcolors:$80;           // maximum number of colors */
	        transpen:0;               // transparent pen index */
	        link_entry:(0,0,0,$03f); // mask for the link */
	        code_entry:(data_lower:($0fff,0,0,0);data_upper:(0,0,0,0)); // mask for the code index */
	        color_entry:(data_lower:(0,0,0,$0007);data_upper:(0,0,0,0)); // mask for the color */
	        xpos_entry:(0,0,0,$ff80); // mask for the X position */
          ypos_entry:(0,$ff80,0,0); // mask for the Y position */
	        width_entry:(0,0,0,0); // mask for the width, in tiles*/
	        height_entry:(0,$000f,0,0); // mask for the height, in tiles */
	        hflip_entry:(0,0,0,0); // mask for the horizontal flip */
	        vflip_entry:(0,0,0,0);     // mask for the vertical flip */
	        priority_entry:(0,0,0,$0008); // mask for the priority */
	        neighbor_entry:(0,0,0,0); // mask for the neighbor */
	        absolute_entry:(0,0,0,0);// mask for absolute coordinates */
	        special_entry:(0,0,0,0);  // mask for the special value */
	        specialvalue:0;           // resulting value to indicate "special" */
        );

var
 rom:array[0..$1ffff] of word;
 ram:array[0..$fff] of word;
 eeprom_ram:array[0..$fff] of byte;
 sound_rom:array[0..3,0..$fff] of byte;
 pedal1,pedal2,sound_bank,playfield_tile_bank,soundlatch,mainlatch:byte;
 write_eeprom,main_pending,sound_pending:boolean;
 pant_bl:array [0..((512*256)-1)] of word;

procedure put_gfx_bl(pos_x,pos_y,nchar,color:word;ngfx:byte;pant_dest:pword);inline;
var
  x,y:byte;
  temp,temp2:pword;
  pos:pbyte;
begin
pos:=gfx[ngfx].datos;
inc(pos,nchar*8*8);
for y:=0 to 7 do begin
  temp:=punbuf;
  for x:=0 to 7 do begin
    temp^:=gfx[ngfx].colores[pos^+color];
    inc(pos);
    inc(temp);
  end;
  temp2:=pant_dest;
  inc(temp2,((pos_y+y)*512)+pos_x);
  copymemory(temp2,punbuf,8*2);
end;
end;

procedure update_video_badlands;
var
  f,color,x,y,nchar,atrib:word;
  pant1,pant2:array[0..((512*256)-1)] of word;
  cont:dword;
  repaint:boolean;
begin
repaint:=false;
for f:=0 to $7ff do begin
  x:=f mod 64;
  y:=f div 64;
  atrib:=ram[f];
  if (atrib and $1000)<>0 then nchar:=(atrib and $1fff)+(playfield_tile_bank shl 12)
    else nchar:=(atrib and $1fff);
  color:=(atrib shr 13) and 7;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    put_gfx_bl(x*8,y*8,nchar,color shl 4,0,@pant_bl);
    gfx[0].buffer[f]:=false;
    repaint:=true;
  end;
end;
if repaint then begin
  for cont:=0 to ((512*256)-1) do begin
    atrib:=pant_bl[cont];
    if (atrib and 8)<>0 then begin
      pant1[cont]:=paleta[0];
      pant2[cont]:=paleta[atrib];
    end else begin
      pant1[cont]:=paleta[atrib];
      pant2[cont]:=paleta[MAX_COLORES];
    end;
  end;
  putpixel(0,0,512*256,@pant1,1);
  putpixel(0,0,512*256,@pant2,2);
end;
actualiza_trozo(0,0,512,256,1,0,0,512,256,3);
atari_mo_0.draw(0,0,0);
actualiza_trozo(0,0,512,256,2,0,0,512,256,3);
atari_mo_0.draw(0,0,1);
actualiza_trozo_final(0,0,336,240,3);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_badlands;
begin
if event.arcade then begin
  //Audio CPU
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 or 1) else marcade.in0:=(marcade.in0 and $fe);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 or 2) else marcade.in0:=(marcade.in0 and $fd);
  //Buttons
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $ef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.but0[1] then marcade.in1:=(marcade.in1 and $df) else marcade.in1:=(marcade.in1 or $20);
  //Pedals
  if arcade_input.but1[0] then marcade.in2:=(marcade.in2 or 1) else marcade.in2:=(marcade.in2 and $fe);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 or 2) else marcade.in2:=(marcade.in2 and $fd);
end;
end;

procedure badlands_principal;
var
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=m6502_0.tframes;
while EmuStatus=EsRuning do begin
 for f:=0 to 261 do begin
    //main
    m68000_0.run(frame_m);
    frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
    //sound
    m6502_0.run(frame_s);
    frame_s:=frame_s+m6502_0.tframes-m6502_0.contador;
    case f of
      0,64,128,192:m6502_0.change_irq(ASSERT_LINE);
      239:begin  //VBLANK
          update_video_badlands;
          m68000_0.irq[1]:=ASSERT_LINE;
          marcade.in1:=marcade.in1 or $40;
        end;
      261:marcade.in1:=marcade.in1 and $bf;
    end;
 end;
 if (marcade.in2 and 1)=0 then pedal1:=pedal1-1;
 if (marcade.in2 and 2)=0 then pedal2:=pedal2-1;
 eventos_badlands;
 video_sync;
end;
end;

function badlands_getword(direccion:dword):word;
begin
case direccion of
    0..$3ffff:badlands_getword:=rom[direccion shr 1];
    $fc0000..$fc1fff:badlands_getword:=$feff or ($100*byte(sound_pending));
    $fd0000..$fd1fff:badlands_getword:=$ff00 or eeprom_ram[(direccion and $1fff) shr 1];
    $fe4000..$fe5fff:badlands_getword:=marcade.in1; //in1
    $fe6000:badlands_getword:=$ff00 or analog.c[0].x[0]; //in2
    $fe6002:badlands_getword:=$ff00 or analog.c[0].x[1]; //in3
    $fe6004:badlands_getword:=pedal1; //pedal1
    $fe6006:badlands_getword:=pedal2; //pedal2
    $fea000..$febfff:begin
                        badlands_getword:=mainlatch shl 8;
                        main_pending:=false;
                        m68000_0.irq[2]:=CLEAR_LINE;
                     end;
    $ffc000..$ffc3ff:badlands_getword:=buffer_paleta[(direccion and $3ff) shr 1];
    $ffe000..$ffffff:badlands_getword:=ram[(direccion and $1fff) shr 1];
end;
end;

procedure cambiar_color(numero:word);
var
  color:tcolor;
  i:byte;
  tmp_color:word;
begin
  numero:=numero shr 1;
  tmp_color:=(buffer_paleta[numero*2] and $ff00) or (buffer_paleta[(numero*2)+1] shr 8);
  i:=(tmp_color shr 15) and 1;
  color.r:=pal6bit(((tmp_color shr 9) and $3e) or i);
  color.g:=pal6bit(((tmp_color shr 4) and $3e) or i);
  color.b:=pal6bit(((tmp_color shl 1) and $3e) or i);
  set_pal_color(color,numero);
  if numero<$80 then  buffer_color[(numero shr 4) and 7]:=true;
end;

procedure badlands_putword(direccion:dword;valor:word);
begin
case direccion of
    0..$3ffff:; //ROM
    $fc0000..$fc1fff:begin
                        m6502_0.change_reset(PULSE_LINE);
                        sound_bank:=0;
                        ym2151_0.reset;
                     end;
    $fd0000..$fd1fff:if write_eeprom then begin
                        eeprom_ram[(direccion and $1fff) shr 1]:=valor;
                        write_eeprom:=false;
                     end;
    $fe0000..$fe1fff:; //WD
    $fe2000..$fe3fff:m68000_0.irq[1]:=CLEAR_LINE;
    $fe8000..$fe9fff:begin
                        soundlatch:=valor shr 8;
                        m6502_0.change_nmi(ASSERT_LINE);
                        sound_pending:=true;
                     end;
    $fec000..$fedfff:begin
                        playfield_tile_bank:=valor and 1;
                        fillchar(gfx[0].buffer,$800,1);
                     end;
    $fee000..$feffff:write_eeprom:=true;
    $ffc000..$ffc3ff:if buffer_paleta[(direccion and $3ff) shr 1]<>valor then begin
                        buffer_paleta[(direccion and $3ff) shr 1]:=valor;
                        cambiar_color((direccion and $3ff) shr 1);
                     end;
    $ffe000..$ffefff:if ram[(direccion and $fff) shr 1]<>valor then begin
                        ram[(direccion and $fff) shr 1]:=valor;
                        gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                     end;
    $fff000..$ffffff:ram[(direccion and $1fff) shr 1]:=valor;
end;
end;

function badlands_snd_getbyte(direccion:word):byte;
begin
case direccion of
     0..$1fff,$4000..$ffff:badlands_snd_getbyte:=mem_snd[direccion];
     $2000..$27ff:if (direccion and $1)<>0 then badlands_snd_getbyte:=ym2151_0.status;
     $2800..$29ff:case (direccion and 6) of
                    2:begin
                        badlands_snd_getbyte:=soundlatch;
                        sound_pending:=false;
                        m6502_0.change_nmi(CLEAR_LINE);
                      end;
                    4:badlands_snd_getbyte:=marcade.in0 or $10 or ($20*byte(main_pending)) or ($40*(byte(not(sound_pending))));
                    6:m6502_0.change_irq(CLEAR_LINE);
                  end;
     $3000..$3fff:badlands_snd_getbyte:=sound_rom[sound_bank,direccion and $fff];
end;
end;

procedure badlands_snd_putbyte(direccion:word;valor:byte);
begin
case direccion of
     0..$1fff:mem_snd[direccion]:=valor;
     $2000..$27ff:case (direccion and 1) of
                      0:ym2151_0.reg(valor);
                      1:ym2151_0.write(valor);
                  end;
     $2800..$29ff:if (direccion and 6)=6 then m6502_0.change_irq(CLEAR_LINE);
     $2a00..$2bff:case (direccion and 6) of
                    2:begin
                        mainlatch:=valor;
                        m68000_0.irq[2]:=ASSERT_LINE;
                        main_pending:=true;
                      end;
                    4:begin
                        sound_bank:=(valor shr 6) and 3;
                        if (valor and 1)=0 then ym2151_0.reset;
                      end;
                  end;
     $3000..$ffff:; //ROM
end;
end;

procedure badlands_sound_update;
begin
  ym2151_0.update;
end;

//Main
procedure reset_badlands;
begin
 m68000_0.reset;
 m6502_0.reset;
 YM2151_0.reset;
 reset_audio;
 marcade.in0:=0;
 marcade.in1:=$ffbf;
 marcade.in2:=0;
 write_eeprom:=false;
 sound_pending:=false;
 main_pending:=false;
 soundlatch:=0;
 mainlatch:=0;
 playfield_tile_bank:=0;
 sound_bank:=0;
 pedal1:=$80;
 pedal2:=$80;
end;

procedure cerrar_badlands;
var
  nombre:string;
begin
  nombre:='badlands.nv';
  write_file(Directory.Arcade_nvram+nombre,@eeprom_ram,$1000);
end;

function iniciar_badlands:boolean;
var
  memoria_temp:array[0..$5ffff] of byte;
  f:dword;
  longitud:integer;
const
  pc_x:array[0..15] of dword=(0, 4, 8, 12, 16, 20, 24, 28,
                             32, 36, 40, 44, 48, 52, 56, 60);
  pc_y:array[0..7] of dword=(0*8, 4*8, 8*8, 12*8, 16*8, 20*8, 24*8, 28*8);
  ps_y:array[0..7] of dword=(0*8, 8*8, 16*8, 24*8, 32*8, 40*8, 48*8, 56*8);
begin
llamadas_maquina.bucle_general:=badlands_principal;
llamadas_maquina.reset:=reset_badlands;
llamadas_maquina.close:=cerrar_badlands;
llamadas_maquina.fps_max:=59.922743;
iniciar_badlands:=false;
iniciar_audio(true);
//Chars
screen_init(1,512,256,false);
screen_init(2,512,256,true);
//Final
screen_init(3,512,256,false,true);
iniciar_video(336,240);
//Main CPU
m68000_0:=cpu_m68000.create(14318180 div 2,262,TCPU_68000);
m68000_0.change_ram16_calls(badlands_getword,badlands_putword);
//Sound CPU
m6502_0:=cpu_m6502.create(14318180 div 8,262,TCPU_M6502);
m6502_0.change_ram_calls(badlands_snd_getbyte,badlands_snd_putbyte);
m6502_0.init_sound(badlands_sound_update);
//Sound Chips
ym2151_0:=ym2151_chip.create(14318180 div 4);
//cargar roms
if not(roms_load16w(@rom,badlands_rom)) then exit;
//cargar sonido
if not(roms_load(@memoria_temp,badlands_sound)) then exit;
copymemory(@mem_snd[$4000],@memoria_temp[$4000],$c000);
for f:=0 to 3 do copymemory(@sound_rom[f,0],@memoria_temp[f*$1000],$1000);
//convertir gfx
if not(roms_load(@memoria_temp,badlands_back)) then exit;
for f:=0 to $5ffff do memoria_temp[f]:=not(memoria_temp[f]);
init_gfx(0,8,8,$3000);
gfx_set_desc_data(4,0,32*8,0,1,2,3);
convert_gfx(0,0,@memoria_temp,@pc_x,@pc_y,false,false);
//eeprom
if read_file_size(Directory.Arcade_nvram+'badlands.nv',longitud) then read_file(Directory.Arcade_nvram+'badlands.nv',@eeprom_ram,longitud)
  else fillchar(eeprom_ram[0],$1000,$ff);
//atari mo
if not(roms_load(@memoria_temp,badlands_mo)) then exit;
for f:=0 to $2ffff do memoria_temp[f]:=not(memoria_temp[f]);
init_gfx(1,16,8,$c00);
gfx[1].trans[0]:=true;
gfx_set_desc_data(4,0,64*8,0,1,2,3);
convert_gfx(1,0,@memoria_temp,@pc_x,@ps_y,false,false);
atari_mo_0:=tatari_mo.create(nil,@ram[$1000 shr 1],badlands_mo_config,3,336+8,240+8);
//Init Analog
init_analog(m68000_0.numero_cpu,m68000_0.clock);
analog_0(50,10,$0,$ff,$0,false,true,true,true);
//final
reset_badlands;
iniciar_badlands:=true;
end;

end.
