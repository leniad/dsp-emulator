unit crystalcastles_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     m6502,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,pokey,file_engine;

function iniciar_ccastles:boolean;

implementation
const
        ccastles_rom:array[0..4] of tipo_roms=(
        (n:'136022-403.1k';l:$2000;p:$2000;crc:$81471ae5),(n:'136022-404.1l';l:$2000;p:$0;crc:$820daf29),
        (n:'136022-405.1n';l:$2000;p:$4000;crc:$4befc296),(n:'136022-102.1h';l:$2000;p:$8000;crc:$f6ccfbd4),
        (n:'136022-101.1f';l:$2000;p:$6000;crc:$e2e17236));
        ccastles_sprites:array[0..1] of tipo_roms=(
        (n:'136022-106.8d';l:$2000;p:$0;crc:$9d1d89fc),(n:'136022-107.8b';l:$2000;p:$2000;crc:$39960b7d));
        ccastles_pal:array[0..3] of tipo_roms=(
        (n:'82s129-136022-108.7k';l:$100;p:$0;crc:$6ed31e3b),(n:'82s129-136022-109.6l';l:$100;p:$100;crc:$b3515f1a),
        (n:'82s129-136022-110.11l';l:$100;p:$200;crc:$068bdc7e),(n:'82s129-136022-111.10k';l:$100;p:$300;crc:$c29c18d9));

var
  rom_bank:array[0..1,0..$3fff] of byte;
  hscroll,vscroll,num_bank:byte;
  outlatch,bitmode_addr:array[0..1] of byte;
  video_ram:array[0..$7fff] of byte;
  syncprom,wpprom,priprom:array[0..$ff] of byte;
  weights_r,weights_g,weights_b:array[0..2] of single;

procedure update_video_ccastles;
var
  effy:integer;
  y,f,effx,mopix,pix,prindex,prvalue,flip,nchar,color:byte;
  x,pos_videoram:word;
  screen_data:array[0..255,0..319] of word;
  screen_sprites:array[0..255,0..319] of byte;

procedure put_sprite_cc(nchar:dword;color:word;flip:boolean;sx,sy:byte);
var
  x,y,pos_y,pos_x,pos_x_temp:byte;
  pos:pbyte;
  dir:integer;
begin
pos:=gfx[0].datos;
inc(pos,nchar*8*16);
if flip then begin
  pos_y:=15;
  dir:=-1;
  pos_x:=7;
end else begin
  pos_y:=0;
  dir:=1;
  pos_x:=0;
end;
for y:=0 to 15 do begin
  pos_x_temp:=pos_x;
  for x:=0 to 7 do begin
    if not(gfx[0].trans[pos^]) then screen_sprites[sx+pos_x_temp,sy+pos_y]:=pos^+color;
    pos_x_temp:=pos_x_temp+dir;
    inc(pos);
  end;
  pos_y:=pos_y+dir;
end;
end;
begin
if (outlatch[1] and $10)<>0 then flip:=$ff
  else flip:=0;
pos_videoram:=((outlatch[1] and $80) shl 1) or $8e00;
fillchar(screen_sprites,$14000,$ff);
for f:=0 to $27 do begin
		x:=memoria[pos_videoram+3+(f*4)];
		y:=(240-memoria[pos_videoram+1+(f*4)]) and $ff;
		nchar:=memoria[pos_videoram+(f*4)];
		color:=memoria[pos_videoram+2+(f*4)] shr 7;
    put_sprite_cc(nchar,color shl 3,flip<>0,x,y);
end;
for y:=0 to 255 do begin
		// if we're in the VBLANK region, just fill with black
		if (syncprom[y] and 1)<>0 then begin
      for x:=0 to 319 do screen_data[y,x]:=paleta[$400];
		// non-VBLANK region: merge the sprites and the bitmap
		end else begin
			// the "POTATO" chip does some magic here; this is just a guess
      if (flip<>0) then effy:=(((y-24)+0) xor flip) and $ff
        else effy:=(((y-24)+vscroll) xor flip) and $ff;
			if (effy<24) then effy:=24;
			pos_videoram:=effy*128;
			// loop over X
			for x:=0 to 319 do begin
				// if we're in the HBLANK region, just store black
				if (x>=256) then begin
          screen_data[y,x]:=paleta[$400]
				// otherwise, process normally
				end else begin
					effx:=(hscroll+(x xor flip)) and $ff;
					// low 4 bits = left pixel, high 4 bits = right pixel
					pix:=(video_ram[pos_videoram+(effx div 2)] shr ((effx and 1)*4)) and $0f;
          mopix:=screen_sprites[x,y];
					{ Inputs to the priority PROM:
					    Bit 7 = GND
					    Bit 6 = /CRAM
					    Bit 5 = BA4
					    Bit 4 = MV2
					    Bit 3 = MV1
					    Bit 2 = MV0
					    Bit 1 = MPI
					    Bit 0 = BIT3}
					prindex:=$40 or ((mopix and 7) shl 2) or ((mopix and 8) shr 2) or ((pix and 8) shr 3);
					prvalue:=priprom[prindex];
					// Bit 1 of prvalue selects the low 4 bits of the final pixel
					if (prvalue and 2)<>0 then pix:=mopix;
					// Bit 0 of prvalue selects bit 4 of the final color
					pix:=pix or ((prvalue and 1) shl 4);
					// store the pixel value and also a priority value based on the topmost bit
					screen_data[y,x]:=paleta[pix];
				end;
			end;
		end;
end;
putpixel(0,0,$14000,@screen_data,1);
actualiza_trozo(0,24,256,232,1,0,0,256,232,PANT_TEMP);
end;

procedure eventos_ccastles;
begin
if main_vars.service1 then marcade.in0:=marcade.in0 and $ef else marcade.in0:=marcade.in0 or $10;
if event.arcade then begin
  //in0
  if arcade_input.coin[1] then marcade.in0:=marcade.in0 and $fe else marcade.in0:=marcade.in0 or 1;
  if arcade_input.coin[0] then marcade.in0:=marcade.in0 and $fd else marcade.in0:=marcade.in0 or 2;
  if arcade_input.but0[0] then marcade.in0:=marcade.in0 and $bf else marcade.in0:=marcade.in0 or $40;
  if arcade_input.but1[0] then marcade.in0:=marcade.in0 and $7f else marcade.in0:=marcade.in0 or $80;
  //in1
  if arcade_input.start[0] then marcade.in1:=marcade.in1 and $f7 else marcade.in1:=marcade.in1 or 8;
  if arcade_input.start[1] then marcade.in1:=marcade.in1 and $ef else marcade.in1:=marcade.in1 or $10;
end;
end;

procedure principal_ccastles;
var
  f:byte;
  frame:single;
begin
init_controls(false,false,false,true);
frame:=m6502_0.tframes;
while EmuStatus=EsRunning do begin
 for f:=0 to 255 do begin
    case f of
      0:begin
          marcade.in0:=marcade.in0 or $20;
          m6502_0.change_irq(ASSERT_LINE);
        end;
      24:marcade.in0:=marcade.in0 and $df;
      64,128,192:m6502_0.change_irq(ASSERT_LINE);
    end;
    m6502_0.run(frame);
    frame:=frame+m6502_0.tframes-m6502_0.contador;
 end;
 update_video_ccastles;
 eventos_ccastles;
 video_sync;
end;
end;

procedure bitmode_autoinc;
begin
  // auto increment in the x-direction if it's enabled
	if (outlatch[1] and 1)=0 then begin // /AX
		if (outlatch[1] and 4)=0 then bitmode_addr[0]:=bitmode_addr[0]+1 // /XINC
		  else bitmode_addr[0]:=bitmode_addr[0]-1;
	end;
	// auto increment in the y-direction if it's enabled
	if (outlatch[1] and 2)=0 then begin // /AY
		if (outlatch[1] and 8)=0 then bitmode_addr[1]:=bitmode_addr[1]+1 // /YINC
      else bitmode_addr[1]:=bitmode_addr[1]-1;
	end;
end;

function getbyte_ccastles(direccion:word):byte;
var
  res:byte;
  tempw:word;
begin
case direccion of
  0,1,3..$7fff:getbyte_ccastles:=video_ram[direccion];
  2:begin
      // in bitmode, the address comes from the autoincrement latches
      tempw:=(bitmode_addr[1] shl 7) or (bitmode_addr[0] shr 1);
	    // the appropriate pixel is selected into the upper 4 bits
	    res:=video_ram[tempw] shl ((not(bitmode_addr[0]) and 1)*4);
	    // autoincrement because /BITMD was selected
	    bitmode_autoinc;
	    // the low 4 bits of the data lines are not driven so make them all 1's
	    getbyte_ccastles:=res or $0f;
    end;
  $8000..$8fff,$e000..$ffff:getbyte_ccastles:=memoria[direccion];
  $9000..$93ff:getbyte_ccastles:=memoria[(direccion and $ff)+$9000]; //nvram_r
  $9400..$95ff:case (direccion and 3) of
                  0:getbyte_ccastles:=analog.c[0].y[0];
                  1:getbyte_ccastles:=analog.c[0].x[0];
                  2,3:getbyte_ccastles:=$ff;
               end;
  $9600..$97ff:getbyte_ccastles:=marcade.in0; //in_0
  $9800..$99ff:getbyte_ccastles:=pokey_0.read(direccion and $f);
  $9a00..$9bff:getbyte_ccastles:=pokey_1.read(direccion and $f);
  $a000..$dfff:getbyte_ccastles:=rom_bank[num_bank,direccion and $3fff];
end;
end;

procedure ccastles_write_vram(direccion:word;valor:byte;bitmd:boolean;pixba:byte);
var
  promaddr,wpbits:byte;
  dest:word;
begin
  dest:=direccion and $7ffe;
	 {  Inputs to the write-protect PROM:
	    Bit 7 = BA1520 = 0 if (BA15-BA12 != 0), or 1 otherwise
	    Bit 6 = DRBA11
	    Bit 5 = DRBA10
	    Bit 4 = /BITMD
	    Bit 3 = GND
	    Bit 2 = BA0
	    Bit 1 = PIXB
	    Bit 0 = PIXA}
	promaddr:=(byte((direccion and $f000)=0) shl 7) or ((direccion and $0c00) shr 5)
            or (byte(not(bitmd)) shl 4) or ((direccion and $0001) shl 2) or (pixba shl 0);
	// look up the PROM result
	wpbits:=wpprom[promaddr];
	// write to the appropriate parts of VRAM depending on the result
	if ((wpbits and 1)=0) then video_ram[dest]:=(video_ram[dest] and $f0) or (valor and $0f);
	if ((wpbits and 2)=0) then video_ram[dest]:=(video_ram[dest] and $0f) or (valor and $f0);
	if ((wpbits and 4)=0) then video_ram[dest+1]:=(video_ram[dest+1] and $f0) or (valor and $0f);
	if ((wpbits and 8)=0) then video_ram[dest+1]:=(video_ram[dest+1] and $0f) or (valor and $f0);
end;

procedure putbyte_ccastles(direccion:word;valor:byte);
var
  tempw:word;
  r,g,b,bit0,bit1,bit2:byte;
  color:tcolor;
begin
case direccion of
  0..1:begin
        ccastles_write_vram(direccion,valor,false,0);
        bitmode_addr[direccion]:=valor;
       end;
  2:begin
        tempw:=(bitmode_addr[1] shl 7) or (bitmode_addr[0] shr 1);
	      // the upper 4 bits of data are replicated to the lower 4 bits
	      valor:=(valor and $f0) or (valor shr 4);
	      // write through the generic VRAM routine, passing the low 2 X bits as PIXB/PIXA
	      ccastles_write_vram(tempw,valor,true,bitmode_addr[0] and 3);
  	    // autoincrement because /BITMD was selected
	      bitmode_autoinc;
    end;
  3..$7fff:ccastles_write_vram(direccion,valor,false,0);
  $8000..$8fff:memoria[direccion]:=valor;
  $9000..$93ff:memoria[(direccion and $ff)+$9000]:=valor; //nvram_w
  $9800..$99ff:pokey_0.write(direccion and $f,valor);
  $9a00..$9bff:pokey_1.write(direccion and $f,valor);
  $9c00..$9c7f:; //nvram_recall_w
  $9c80..$9cff:hscroll:=valor;
  $9d00..$9d7f:vscroll:=valor;
  $9d80..$9dff:m6502_0.change_irq(CLEAR_LINE);
  $9e00..$9e7f:; //watchdog
  $9e80..$9eff:case (direccion and 7) of
                  0..6:;
                  7:num_bank:=valor and 1;
               end;
  $9f00..$9f7f:outlatch[1]:=(outlatch[1] and not(1 shl (direccion and 7))) or (((valor shr 3) and 1) shl (direccion and 7));
  $9f80..$9fff:begin
                  // extract the raw RGB bits
	                r:=not(((valor and $c0) shr 6) or ((direccion and $20) shr 3));
                  b:=not((valor and $38) shr 3);
	                g:=not(valor and $07);
	                // red component (inverted)
	                bit0:=(r shr 0) and $01;
	                bit1:=(r shr 1) and $01;
	                bit2:=(r shr 2) and $01;
	                color.r:=combine_3_weights(@weights_r,bit0,bit1,bit2);
	                // green component (inverted)
	                bit0:=(g shr 0) and $01;
	                bit1:=(g shr 1) and $01;
	                bit2:=(g shr 2) and $01;
	                color.g:=combine_3_weights(@weights_g,bit0,bit1,bit2);
	                // blue component (inverted)
	                bit0:=(b shr 0) and $01;
	                bit1:=(b shr 1) and $01;
	                bit2:=(b shr 2) and $01;
	                color.b:=combine_3_weights(@weights_b,bit0,bit1,bit2);
                  set_pal_color(color,direccion and $1f);
               end;
  $a000..$ffff:; //ROM
end;
end;

function input_in1(pot:byte):byte;
begin
  input_in1:=marcade.in1;
end;

procedure ccastles_sound_update;
begin
  pokey_0.update;
  pokey_1.update;
end;

//Main
procedure reset_ccastles;
begin
  m6502_0.reset;
  pokey_0.reset;
  pokey_1.reset;
  reset_audio;
  num_bank:=0;
  bitmode_addr[0]:=0;
  bitmode_addr[1]:=0;
  outlatch[0]:=0;
  outlatch[1]:=0;
  hscroll:=0;
  vscroll:=0;
  marcade.in0:=$ff;
  marcade.in1:=$df;
  reset_analog;
end;

procedure close_ccastles;
begin
  write_file(Directory.Arcade_nvram+'ccastles.nv',@memoria[$9000],$100);
end;

function iniciar_ccastles:boolean;
var
  memoria_temp:array[0..$ffff] of byte;
  longitud:integer;
const
    ps_x:array[0..7] of dword=(0, 1, 2, 3, 8+0, 8+1, 8+2, 8+3);
    ps_y:array[0..15] of dword=(0*16, 1*16, 2*16, 3*16, 4*16, 5*16, 6*16, 7*16,
			8*16, 9*16, 10*16, 11*16, 12*16, 13*16, 14*16, 15*16);
    resistances:array[0..2] of integer=(22000,10000,4700);
begin
llamadas_maquina.bucle_general:=principal_ccastles;
llamadas_maquina.reset:=reset_ccastles;
llamadas_maquina.fps_max:=61.035156;
llamadas_maquina.close:=close_ccastles;
iniciar_ccastles:=false;
iniciar_audio(false);
screen_init(1,320,256);
iniciar_video(256,232);
//Main CPU
m6502_0:=cpu_m6502.create(10000000 div 8,256,TCPU_M6502);
m6502_0.change_ram_calls(getbyte_ccastles,putbyte_ccastles);
m6502_0.init_sound(ccastles_sound_update);
//analog
init_analog(m6502_0.numero_cpu,m6502_0.clock);
analog_0(10,-30,$7f,$ff,0,false,true,false,true);
//Sound Chip
pokey_0:=pokey_chip.create(10000000 div 8);
pokey_1:=pokey_chip.create(10000000 div 8);
pokey_1.change_all_pot(input_in1);
//cargar roms
if not(roms_load(@memoria_temp,ccastles_rom)) then exit;
copymemory(@rom_bank[0,0],@memoria_temp[0],$4000);
copymemory(@memoria[$e000],@memoria_temp[$4000],$2000);
copymemory(@rom_bank[1,0],@memoria_temp[$6000],$4000);
//Cargar sprites
if not(roms_load(@memoria_temp,ccastles_sprites)) then exit;
init_gfx(0,8,16,$100);
gfx[0].trans[7]:=true;
gfx_set_desc_data(3,0,32*8,4,$2000*8,$2000*8+4);
convert_gfx(0,0,@memoria_temp,@ps_x,@ps_y,false,false);
//poner la paleta
if not(roms_load(@memoria_temp,ccastles_pal)) then exit;
copymemory(@syncprom,@memoria_temp[0],$100);
copymemory(@wpprom,@memoria_temp[$200],$100);
copymemory(@priprom,@memoria_temp[$300],$100);
compute_resistor_weights(0, 255, -1.0,
			3,@resistances,@weights_r,1000,0,
			3,@resistances,@weights_g,1000,0,
			3,@resistances,@weights_b,1000,0);
//cargar NVram
if read_file_size(Directory.Arcade_nvram+'ccastles.nv',longitud) then read_file(Directory.Arcade_nvram+'ccastles.nv',@memoria[$9000],longitud);
//final
reset_ccastles;
iniciar_ccastles:=true;
end;

end.
