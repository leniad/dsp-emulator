unit system16b_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,ym_2151,dialogs,upd7759,mcs51;

procedure cargar_system16b;

implementation
const
        //Altered Beast
        altbeast_rom:array[0..1] of tipo_roms=(
        (n:'epr-11907.a7';l:$20000;p:0;crc:$29e0c3ad),(n:'epr-11906.a5';l:$20000;p:$1;crc:$4c9e9cd8));
        altbeast_sound:array[0..2] of tipo_roms=(
        (n:'epr-11671.a10';l:$8000;p:0;crc:$2b71343b),(n:'opr-11672.a11';l:$20000;p:$8000;crc:$bbd7f460),
        (n:'opr-11673.a12';l:$20000;p:$28000;crc:$400c4a36));
        altbeast_mcu:tipo_roms=(n:'317-0078.c2';l:$1000;p:0;crc:$8101925f);
        altbeast_tiles:array[0..2] of tipo_roms=(
        (n:'opr-11674.a14';l:$20000;p:0;crc:$a57a66d5),(n:'opr-11675.a15';l:$20000;p:$20000;crc:$2ef2f144),
        (n:'opr-11676.a16';l:$20000;p:$40000;crc:$0c04acac));
        altbeast_sprites:array[0..7] of tipo_roms=(
        (n:'epr-11677.b1';l:$20000;p:1;crc:$a01425cd),(n:'epr-11681.b5';l:$20000;p:$0;crc:$d9e03363),
        (n:'epr-11678.b2';l:$20000;p:$40001;crc:$17a9fc53),(n:'epr-11682.b6';l:$20000;p:$40000;crc:$e3f77c5e),
        (n:'epr-11679.b3';l:$20000;p:$80001;crc:$14dcc245),(n:'epr-11683.b7';l:$20000;p:$80000;crc:$f9a60f06),
        (n:'epr-11680.b4';l:$20000;p:$c0001;crc:$f43dcdec),(n:'epr-11684.b8';l:$20000;p:$c0000;crc:$b20c0edb));
        //Golden Axe
        goldnaxe_rom:array[0..1] of tipo_roms=(
        (n:'epr-12545.ic2';l:$40000;p:0;crc:$a97c4e4d),(n:'epr-12544.ic1';l:$40000;p:$1;crc:$5e38f668));
        goldnaxe_sound:array[0..1] of tipo_roms=(
        (n:'epr-12390.ic8';l:$8000;p:0;crc:$399fc5f5),(n:'mpr-12384.ic6';l:$20000;p:$8000;crc:$6218d8e7));
        goldnaxe_mcu:tipo_roms=(n:'317-0123a.c2';l:$1000;p:0;crc:$cf19e7d4);
        goldnaxe_tiles:array[0..2] of tipo_roms=(
        (n:'epr-12385.ic19';l:$20000;p:0;crc:$b8a4e7e0),(n:'epr-12386.ic20';l:$20000;p:$20000;crc:$25d7d779),
        (n:'epr-12387.ic21';l:$20000;p:$40000;crc:$c7fcadf3));
        goldnaxe_sprites:array[0..5] of tipo_roms=(
        (n:'mpr-12378.ic9';l:$40000;p:1;crc:$119e5a82),(n:'mpr-12379.ic12';l:$40000;p:$0;crc:$1a0e8c57),
        (n:'mpr-12380.ic10';l:$40000;p:$80001;crc:$bb2c0853),(n:'mpr-12381.ic13';l:$40000;p:$80000;crc:$81ba6ecc),
        (n:'mpr-12382.ic11';l:$40000;p:$100001;crc:$81601c6f),(n:'mpr-12383.ic14';l:$40000;p:$100000;crc:$5dbacf7a));
        //Dip
        system16b_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$7;dip_name:'4C/1C'),(dip_val:$8;dip_name:'3C/1C'),(dip_val:$9;dip_name:'2C/1C'),(dip_val:$5;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$4;dip_name:'2C/1C 4C/3C'),(dip_val:$f;dip_name:'1C/1C'),(dip_val:$3;dip_name:'1C/1C 5C/6C'),(dip_val:$2;dip_name:'1C/1C 4C/5C'),(dip_val:$1;dip_name:'1C/1C 2C/3C'),(dip_val:$6;dip_name:'2C/3C'),(dip_val:$e;dip_name:'1C/2C'),(dip_val:$d;dip_name:'1C/3C'),(dip_val:$c;dip_name:'1C/4C'),(dip_val:$b;dip_name:'1C/5C'),(dip_val:$a;dip_name:'1C/6C'),(dip_val:$0;dip_name:'Free Play (if Coin B too) or 1C/1C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$70;dip_name:'4C/1C'),(dip_val:$80;dip_name:'3C/1C'),(dip_val:$90;dip_name:'2C/1C'),(dip_val:$50;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$40;dip_name:'2C/1C 4C/3C'),(dip_val:$f0;dip_name:'1C/1C'),(dip_val:$30;dip_name:'1C/1C 5C/6C'),(dip_val:$20;dip_name:'1C/1C 4C/5C'),(dip_val:$10;dip_name:'1C/1C 2C/3C'),(dip_val:$60;dip_name:'2C/3C'),(dip_val:$e0;dip_name:'1C/2C'),(dip_val:$d0;dip_name:'1C/3C'),(dip_val:$c0;dip_name:'1C/4C'),(dip_val:$b0;dip_name:'1C/5C'),(dip_val:$a0;dip_name:'1C/6C'),(dip_val:$00;dip_name:'Free Play (if Coin A too) or 1C/1C'))),());
        altbeast_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Credits Needed';number:2;dip:((dip_val:$1;dip_name:'1 Credit To Start'),(dip_val:$0;dip_name:'2 Credit To Start'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2'),(dip_val:$c;dip_name:'3'),(dip_val:$4;dip_name:'4'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Player Meter';number:4;dip:((dip_val:$20;dip_name:'2'),(dip_val:$30;dip_name:'3'),(dip_val:$10;dip_name:'4'),(dip_val:$0;dip_name:'5'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());

type
  tsystem16_info=record
    	normal,shadow,hilight:array[0..31] of byte;	//RGB translations for hilighted pixels
      s_banks:byte;
   end;

var
 rom:array[0..$3ffff] of word;
 ram:array[0..$ffff] of word;
 tile_ram:array[0..$7fff] of word;
 tile_buffer:array[0..$7fff] of boolean;
 char_ram:array[0..$7ff] of word;
 sprite_ram:array[0..$3ff] of word;
 sprite_rom:array[0..$1fffff] of word;
 sprite_bank:array[0..$f] of byte;
 s16_info:tsystem16_info;
 s16_screen:array[0..7] of byte;
 screen_enabled:boolean;
 sound_latch:byte;
 from_sound:byte;
 tile_bank:array[0..1] of byte;
 sound_bank:array[0..$f,0..$3fff] of byte;
 sound_bank_num:byte;
 s315_5195_regs:array[0..$1f] of byte;
 s315_5195_dirs_start:array[0..7] of dword;
 s315_5195_dirs_end:array[0..7] of dword;

procedure s315_5195_set_map;
var
  f:byte;
const
  size:array[0..3] of dword=($10000,$20000,$80000,$200000);
begin
for f:=0 to 7 do begin
  s315_5195_dirs_start[f]:=s315_5195_regs[$11+(f*2)] shl 16;
  s315_5195_dirs_end[f]:=s315_5195_dirs_start[f]+size[s315_5195_regs[$10+(f*2)] and $3];
end;
end;

function s315_5195_read_reg(dir:byte):byte;
var
  res:byte;
begin
  res:=$ff;
  case dir of
    0,1:res:=s315_5195_regs[dir];
    2:if (s315_5195_regs[2] and 3)=3 then res:=0
        else res:=$f;
    3:res:=from_sound;
  end;
  s315_5195_read_reg:=res;
end;

procedure s315_5195_write_reg(dir,valor:byte);
var
  old_val:byte;
  addr:dword;
  res:word;
begin
  old_val:=s315_5195_regs[dir];
  s315_5195_regs[dir]:=valor;
  case dir of
    2:; //resume M68000
    3:begin
        sound_latch:=valor;
        z80_0.change_irq(ASSERT_LINE);
      end;
    4:if valor=$b then m68000_0.irq[4]:=HOLD_LINE;
    5:case valor of
      1:begin
          addr:=(s315_5195_regs[$a] shl 17) or (s315_5195_regs[$b] shl 9) or (s315_5195_regs[$c] shl 1);
          res:=(s315_5195_regs[0] shl 8) or s315_5195_regs[1];
          m68000_0.putword_(addr,res);
        end;
      2:begin
          addr:=(s315_5195_regs[7] shl 17) or (s315_5195_regs[8] shl 9) or (s315_5195_regs[9] shl 1);
          res:=m68000_0.getword_(addr);
          s315_5195_regs[0]:=res shr 8;
          s315_5195_regs[1]:=res and $ff;
        end;
    end;
    7,8,9,$a,$b,$c:; //write latch
    $10..$1f:if old_val<>valor then s315_5195_set_map;
  end;
end;

procedure draw_sprites(pri:byte);
var
  f,sprpri,vzoom,hzoom:byte;
  bottom,top,xacc:word;
  xpos,addr,bank,x,y,pix,data_7,pixels,color:word;
  pitch:integer;
  spritedata:dword;
  hide,flip:boolean;

procedure system16b_draw_pixel(x,y,pix,color:word;pri:byte);inline;
const
  pal_cons:array[0..3] of word=(0,$800,$400,$c00);
var
  punt:word;
begin
  //only draw if onscreen, not 0 or 15
	if ((x<512) and (pix<>0) and (pix<>15)) then begin
      punt:=paleta[color+pix+pal_cons[pri]];
      putpixel(x+ADD_SPRITE,y+ADD_SPRITE,1,@punt,7);
	end;
end;

begin
  for f:=0 to $7f do begin
    if (sprite_ram[(f*$8)+2] and $8000)<>0 then exit;
    sprpri:=(sprite_ram[(f*$8)+4] and $ff) shr 6;
    if sprpri<>pri then continue;
    bottom:=(sprite_ram[f*$8] shr 8);
    top:=sprite_ram[f*$8] and $ff;
    hide:=(sprite_ram[(f*$8)+2] and $4000)<>0;
    // initialize the end address to the start address
    addr:=sprite_ram[(f*$8)+3];
    sprite_ram[(f*$8)+$7]:=addr;
    bank:=sprite_bank[(sprite_ram[(f*$8)+4] shr 8) and $f];
    // if hidden, or top greater than/equal to bottom, or invalid bank, punt
		if (hide or (top>=bottom) or (bank=255)) then continue;

		xpos:=(sprite_ram[(f*$8)+1] and $1ff)-$bd+6;
		pitch:=shortint(sprite_ram[(f*$8)+2] and $ff);
		color:=(sprite_ram[(f*$8)+4] and $3f) shl 4;

    flip:=(sprite_ram[(f*$8)+2] and $100)<>0;

    vzoom:=(sprite_ram[(f*$8)+5] shr 5) and $1f;
    hzoom:=sprite_ram[(f*$8)+5] and $1f;
		// clamp to within the memory region size
		spritedata:=$10000*(bank mod s16_info.s_banks);
    // reset the yzoom counter
    sprite_ram[(f*$8)+5]:=sprite_ram[(f*$8)+5] and $3ff;
		// loop from top to bottom
		for y:=top to (bottom-1) do begin
			// advance a row
			addr:=addr+pitch;
      // accumulate zoom factors; if we carry into the high bit, skip an extra row
      sprite_ram[(f*$8)+5]:=sprite_ram[(f*$8)+5]+(vzoom shl 10);
      if (sprite_ram[(f*$8)+5] and $8000)<>0 then begin
        addr:=addr+pitch;
        sprite_ram[(f*$8)+5]:=sprite_ram[(f*$8)+5] and $7fff;
      end;
			// skip drawing if not within the cliprect
			if (y<=256) then begin
        xacc:=4*hzoom;
				if not(flip) then begin
					// start at the word before because we preincrement below
          sprite_ram[(f*$8)+$7]:=addr-1;
					x:=xpos;
          while ((xpos-x) and $1ff)<>1 do begin
            data_7:=sprite_ram[(f*$8)+$7]+1;
            sprite_ram[(f*$8)+$7]:=data_7;
						pixels:=sprite_rom[spritedata+data_7];
						// draw four pixels
						pix:=(pixels shr 12) and $f;
            xacc:=(xacc and $3f)+hzoom;
            if xacc<$40 then begin
              system16b_draw_pixel(x,y,pix,color,sprpri);
              x:=x+1;
            end;
						pix:=(pixels shr 8) and $f;
            xacc:=(xacc and $3f)+hzoom;
            if xacc<$40 then begin
              system16b_draw_pixel(x,y,pix,color,sprpri);
              x:=x+1;
            end;
						pix:=(pixels shr 4) and $f;
            xacc:=(xacc and $3f)+hzoom;
            if xacc<$40 then begin
              system16b_draw_pixel(x,y,pix,color,sprpri);
              x:=x+1;
            end;
						pix:=(pixels shr 0) and $f;
            xacc:=(xacc and $3f)+hzoom;
            if xacc<$40 then begin
              system16b_draw_pixel(x,y,pix,color,sprpri);
              x:=x+1;
            end;
						// stop if the last pixel in the group was 0xf
						if (pix=15) then break;
					end;
				end else begin
				// flipped case
					// start at the word after because we predecrement below
          sprite_ram[(f*$8)+$7]:=addr+1;
					x:=xpos;
          while ((xpos-x) and $1ff)<>1 do begin
            data_7:=sprite_ram[(f*$8)+$7]-1;
            sprite_ram[(f*$8)+$7]:=data_7;
						pixels:=sprite_rom[spritedata+data_7];
						// draw four pixels
						pix:=(pixels shr 0) and $f;
            xacc:=(xacc and $3f)+hzoom;
            if xacc<$40 then begin
              system16b_draw_pixel(x,y,pix,color,sprpri);
              x:=x+1;
            end;
						pix:=(pixels shr 4) and $f;
            xacc:=(xacc and $3f)+hzoom;
            if xacc<$40 then begin
              system16b_draw_pixel(x,y,pix,color,sprpri);
              x:=x+1;
            end;
						pix:=(pixels shr 8) and $f;
            xacc:=(xacc and $3f)+hzoom;
            if xacc<$40 then begin
              system16b_draw_pixel(x,y,pix,color,sprpri);
              x:=x+1;
            end;
						pix:=(pixels shr 12) and $f;
            xacc:=(xacc and $3f)+hzoom;
            if xacc<$40 then begin
              system16b_draw_pixel(x,y,pix,color,sprpri);
              x:=x+1;
            end;
						// stop if the last pixel in the group was 0xf
						if (pix=15) then break;
					end;
				end;
			end;
		end;
	end;
end;

procedure draw_tiles(num:byte;px,py:word;scr:byte;trans:boolean);
var
  pos,f,nchar,color,data:word;
  x,y:word;
begin
  pos:=s16_screen[num]*$800;
  for f:=$0 to $7ff do begin
    data:=tile_ram[pos];
    color:=(data shr 6) and $7f;
    if (tile_buffer[(num*$800)+f] or buffer_color[color]) then begin
      x:=((f and $3f) shl 3)+px;
      y:=((f shr 6) shl 3)+py;
      nchar:=data and $1fff;
      nchar:=tile_bank[nchar div $1000]*$1000+(nchar mod $1000);
      if trans then begin
        put_gfx_trans(x,y,nchar,color shl 3,scr,0);
        if (data and $8000)<>0 then put_gfx_trans(x,y,nchar,color shl 3,scr+1,0)
          else put_gfx_block_trans(x,y,scr+1,8,8);
      end else begin
        put_gfx(x,y,nchar,color shl 3,scr,0);
        if (data and $8000)<>0 then put_gfx(x,y,nchar,color shl 3,scr+1,0)
          else put_gfx_block(x,y,scr+1,8,8,$1fff);
      end;
    end;
    pos:=pos+1;
  end;
end;

procedure update_video_system16b;
var
  f,nchar,color,scroll_x1,scroll_x2,x,y,atrib,scroll_y1,scroll_y2:word;
begin
if not(screen_enabled) then begin
  actualiza_trozo_final(0,0,320,224,7);
  fill_full_screen(7,$1000);
  exit;
end;
//Background
draw_tiles(0,0,256,3,false);
draw_tiles(1,512,256,3,false);
draw_tiles(2,0,0,3,false);
draw_tiles(3,512,0,3,false);
scroll_x1:=char_ram[$74d] and $3ff;
scroll_x1:=(704-scroll_x1) and $3ff;
scroll_y1:=char_ram[$749] and $1ff;
//Foreground
draw_tiles(4,0,256,5,true);
draw_tiles(5,512,256,5,true);
draw_tiles(6,0,0,5,true);
draw_tiles(7,512,0,5,true);
scroll_x2:=char_ram[$74c] and $3ff;
scroll_x2:=(704-scroll_x2) and $3ff;
scroll_y2:=char_ram[$748] and $1ff;
//text
for f:=$0 to $6ff do begin
  atrib:=char_ram[f];
  color:=(atrib shr 9) and $7;
  if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=(f and $3f) shl 3;
    y:=(f shr 6) shl 3;
    nchar:=tile_bank[0]*$1000+(atrib and $1ff);
    put_gfx_trans(x,y,nchar,color shl 3,1,0);
    if (nchar and $8000)<>0 then put_gfx_trans(x,y,nchar,color shl 3,2,0)
      else put_gfx_block_trans(x,y,2,8,8);
    gfx[0].buffer[f]:=false;
  end;
end;
//Lo pongo todo con prioridades, falta scrollrow y scrollcol!!
scroll_x_y(4,7,scroll_x1,scroll_y1); //0
draw_sprites(0);
scroll_x_y(3,7,scroll_x1,scroll_y1); //1
draw_sprites(1);
scroll_x_y(5,7,scroll_x2,scroll_y2);  //2
draw_sprites(2);
scroll_x_y(6,7,scroll_x2,scroll_y2); //2
actualiza_trozo(192,0,320,224,2,0,0,320,224,7); //4
draw_sprites(3);
actualiza_trozo(192,0,320,224,1,0,0,320,224,7); //8
//Y lo pinto a la pantalla principal
actualiza_trozo_final(0,0,320,224,7);
//OJO: No limpio el buffer cuando pongo los tiles por que puede usar la misma pantalla
//para componer la pantalla final! Lo limpio todo cuando ya lo he terminado de poner las pantallas
fillchar(tile_buffer[0],$8000,0);
fillchar(buffer_color,MAX_COLOR_BUFFER,0);
end;

procedure eventos_system16b;
begin
if event.arcade then begin
  //P1
  if arcade_input.up[0] then marcade.in1:=(marcade.in1 and $ffdf) else marcade.in1:=(marcade.in1 or $20);
  if arcade_input.down[0] then marcade.in1:=(marcade.in1 and $ffef) else marcade.in1:=(marcade.in1 or $10);
  if arcade_input.left[0] then marcade.in1:=(marcade.in1 and $ff7f) else marcade.in1:=(marcade.in1 or $80);
  if arcade_input.right[0] then marcade.in1:=(marcade.in1 and $ffbf) else marcade.in1:=(marcade.in1 or $40);
  if arcade_input.but0[0] then marcade.in1:=(marcade.in1 and $fffb) else marcade.in1:=(marcade.in1 or $4);
  if arcade_input.but1[0] then marcade.in1:=(marcade.in1 and $fffd) else marcade.in1:=(marcade.in1 or $2);
  if arcade_input.but2[0] then marcade.in1:=(marcade.in1 and $fffe) else marcade.in1:=(marcade.in1 or $1);
  //P2
  if arcade_input.up[1] then marcade.in2:=(marcade.in2 and $ffdf) else marcade.in2:=(marcade.in2 or $20);
  if arcade_input.down[1] then marcade.in2:=(marcade.in2 and $ffef) else marcade.in2:=(marcade.in2 or $10);
  if arcade_input.left[1] then marcade.in2:=(marcade.in2 and $ff7f) else marcade.in2:=(marcade.in2 or $80);
  if arcade_input.right[1] then marcade.in2:=(marcade.in2 and $ffbf) else marcade.in2:=(marcade.in2 or $40);
  if arcade_input.but0[1] then marcade.in2:=(marcade.in2 and $fffb) else marcade.in2:=(marcade.in2 or $4);
  if arcade_input.but1[1] then marcade.in2:=(marcade.in2 and $fffd) else marcade.in2:=(marcade.in2 or $2);
  if arcade_input.but2[1] then marcade.in2:=(marcade.in2 and $fffe) else marcade.in2:=(marcade.in2 or $1);
  //Service
  if arcade_input.start[0] then marcade.in0:=(marcade.in0 and $ffef) else marcade.in0:=(marcade.in0 or $10);
  if arcade_input.start[1] then marcade.in0:=(marcade.in0 and $ffdf) else marcade.in0:=(marcade.in0 or $20);
  if arcade_input.coin[0] then marcade.in0:=(marcade.in0 and $fffe) else marcade.in0:=(marcade.in0 or $1);
  if arcade_input.coin[1] then marcade.in0:=(marcade.in0 and $fffd) else marcade.in0:=(marcade.in0 or $2);
end;
end;

procedure system16b_principal;
var
  frame_m,frame_s,frame_mcu:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
frame_mcu:=mcs51_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
     //main
     m68000_0.run(frame_m);
     frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
     //sound
     z80_0.run(frame_s);
     frame_s:=frame_s+z80_0.tframes-z80_0.contador;
     //MCU
     mcs51_0.run(frame_mcu);
     frame_mcu:=frame_mcu+mcs51_0.tframes-mcs51_0.contador;
     if f=223 then begin
       mcs51_0.change_irq0(HOLD_LINE);
       update_video_system16b;
     end;
  end;
  eventos_system16b;
  video_sync;
end;
end;

function standar_s16_io_r(direccion:word):word;inline;
var
  res:word;
begin
case (direccion and $3000) of
	$1000:case (direccion and 7) of
          0,1:res:=marcade.in0; //SERVICE
          2,3:res:=marcade.in1; //P1
          4,5:res:=$ff; //UNUSED
          6,7:res:=marcade.in2; //P2
       end;
  $2000:case (direccion and $1) of
                  0:res:=marcade.dswa; //DSW1
                  1:res:=marcade.dswb; //DSW2
               end;
  else res:=$ffff;
end;
standar_s16_io_r:=res;
end;

procedure change_pal(direccion:word);inline;
var
	val:word;
  color:tcolor;
  r,g,b:integer;
begin
  val:=buffer_paleta[direccion];
	//     byte 0    byte 1
	//  sBGR BBBB GGGG RRRR
	//  x000 4321 4321 4321
	r:=((val shr 12) and $01) or ((val shl 1) and $1e);
	g:=((val shr 13) and $01) or ((val shr 3) and $1e);
	b:=((val shr 14) and $01) or ((val shr 7) and $1e);
  //normal
  color.r:=s16_info.normal[r];
  color.g:=s16_info.normal[g];
  color.b:=s16_info.normal[b];
  set_pal_color(color,direccion);
  //shadow
  if (val and $8000)<>0 then begin
    color.r:=s16_info.shadow[r];
    color.g:=s16_info.shadow[g];
    color.b:=s16_info.shadow[b];
  end else begin
    //hilight
    color.r:=s16_info.hilight[r];
    color.g:=s16_info.hilight[g];
    color.b:=s16_info.hilight[b];
  end;
  set_pal_color(color,direccion+$800);
  buffer_color[(direccion shr 3) and $7f]:=true;
end;

procedure test_screen_change(direccion:word);
begin
if direccion=$740 then begin
          //Foreground
          if ((char_ram[$740] shr 12) and $f)<>s16_screen[4] then begin
            s16_screen[4]:=(char_ram[$740] shr 12) and $f;
            fillchar(tile_buffer[$800*4],$800,1);
          end;
          if ((char_ram[$740] shr 8) and $f)<>s16_screen[5] then begin
            s16_screen[5]:=(char_ram[$740] shr 8) and $f;
            fillchar(tile_buffer[$800*5],$800,1);
          end;
          if ((char_ram[$740] shr 4) and $f)<>s16_screen[6] then begin
            s16_screen[6]:=(char_ram[$740] shr 4) and $f;
            fillchar(tile_buffer[$800*6],$800,1);
          end;
          if (char_ram[$740] and $f)<>s16_screen[7] then begin
            s16_screen[7]:=char_ram[$740] and $f;
            fillchar(tile_buffer[$800*7],$800,1);
          end;
end;
if direccion=$741 then begin
          //Background
          if ((char_ram[$741] shr 12) and $f)<>s16_screen[0] then begin
            s16_screen[0]:=(char_ram[$741] shr 12) and $f;
            fillchar(tile_buffer[$800*0],$800,1);
          end;
          if ((char_ram[$741] shr 8) and $f)<>s16_screen[1] then begin
            s16_screen[1]:=(char_ram[$741] shr 8) and $f;
            fillchar(tile_buffer[$800*1],$800,1);
          end;
          if ((char_ram[$741] shr 4) and $f)<>s16_screen[2] then begin
            s16_screen[2]:=(char_ram[$741] shr 4) and $f;
            fillchar(tile_buffer[$800*2],$800,1);
          end;
          if (char_ram[$741] and $f)<>s16_screen[3] then begin
            s16_screen[3]:=char_ram[$741] and $f;
            fillchar(tile_buffer[$800*3],$800,1);
          end;
end;
end;

function system16b_getword(direccion:dword):word;
begin
if ((direccion>=s315_5195_dirs_start[0]) and (direccion<=s315_5195_dirs_end[0])) then
  system16b_getword:=rom[(direccion and $3ffff) shr 1]
  else if ((direccion>=s315_5195_dirs_start[1]) and (direccion<=s315_5195_dirs_end[1])) then
    else if ((direccion>=s315_5195_dirs_start[2]) and (direccion<=s315_5195_dirs_end[2])) then
      else if ((direccion>=s315_5195_dirs_start[3]) and (direccion<=s315_5195_dirs_end[3])) then
        system16b_getword:=ram[(direccion and $ffff) shr 1] //RAM
        else if ((direccion>=s315_5195_dirs_start[4]) and (direccion<=s315_5195_dirs_end[4])) then
           system16b_getword:=sprite_ram[(direccion and $7ff) shr 1] //Object RAM
           else if ((direccion>=s315_5195_dirs_start[5]) and (direccion<=s315_5195_dirs_end[5])) then
              case direccion and $1ffff of //Text/Tile RAM
                0..$ffff:system16b_getword:=tile_ram[(direccion and $ffff) shr 1];
                $10000..$1ffff:system16b_getword:=char_ram[(direccion and $fff) shr 1];
            end else if ((direccion>=s315_5195_dirs_start[6]) and (direccion<=s315_5195_dirs_end[6])) then
              system16b_getword:=buffer_paleta[(direccion and $fff) shr 1] //Color RAM
              else if ((direccion>=s315_5195_dirs_start[7]) and (direccion<=s315_5195_dirs_end[7])) then
                system16b_getword:=standar_s16_io_r(direccion and $ffff) //IO Read
  else system16b_getword:=s315_5195_read_reg((direccion shr 1) and $1f);
end;

procedure system16b_putword(direccion:dword;valor:word);
begin
{Region 0 - Program ROM
 Region 3 - 68000 work RAM
 Region 4 - Object RAM
 Region 5 - Text/tile RAM
 Region 6 - Color RAM
 Region 7 - I/O area
 Si tiene una region mapeada hace lo que toca, pero si no tiene nada mapeado
 rellena los registros del 315-5195 y mapea
 }
if ((direccion>=s315_5195_dirs_start[0]) and (direccion<=s315_5195_dirs_end[0])) then
  else if ((direccion>=s315_5195_dirs_start[1]) and (direccion<=s315_5195_dirs_end[1])) then
    else if ((direccion>=s315_5195_dirs_start[2]) and (direccion<=s315_5195_dirs_end[2])) then
      tile_bank[(direccion shr 1) and 1]:=valor and 7 //Tile bank!
      else if ((direccion>=s315_5195_dirs_start[3]) and (direccion<=s315_5195_dirs_end[3])) then
      ram[(direccion and $ffff) shr 1]:=valor //RAM
        else if ((direccion>=s315_5195_dirs_start[4]) and (direccion<=s315_5195_dirs_end[4])) then
          sprite_ram[(direccion and $7ff) shr 1]:=valor //Object RAM
          else if ((direccion>=s315_5195_dirs_start[5]) and (direccion<=s315_5195_dirs_end[5])) then
            case direccion and $1ffff of
                0..$ffff:begin
                            tile_ram[(direccion and $ffff) shr 1]:=valor;
                            tile_buffer[((((direccion shr 1) and $7fff) shr 11)*$800)+((direccion shr 1) and $7ff)]:=true;
                         end;
                $10000..$1ffff:begin
                                char_ram[(direccion and $fff) shr 1]:=valor;
                                gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                                test_screen_change((direccion and $fff) shr 1);
                               end;
            end else if ((direccion>=s315_5195_dirs_start[6]) and (direccion<=s315_5195_dirs_end[6])) then begin
              buffer_paleta[(direccion and $fff) shr 1]:=valor;
              change_pal((direccion and $fff) shr 1);
              end else if ((direccion>=s315_5195_dirs_start[7]) and (direccion<=s315_5195_dirs_end[7])) then begin
                case ((direccion and $1fff) shr 1) of //IO
                  0:screen_enabled:=(valor and $20)<>0;
                end;
              end
  else s315_5195_write_reg((direccion shr 1) and $1f,valor and $ff);
end;

function system16b_snd_getbyte(direccion:word):byte;
var
  res:byte;
begin
res:=$ff;
case direccion of
  0..$7fff:res:=mem_snd[direccion];
  $8000..$dfff:res:=sound_bank[sound_bank_num,direccion and $3fff];
  $e800:begin
           res:=sound_latch;
           z80_0.change_irq(CLEAR_LINE);
        end;
  $f800..$ffff:res:=mem_snd[direccion];
end;
system16b_snd_getbyte:=res;
end;

procedure system16b_snd_putbyte(direccion:word;valor:byte);
begin
if direccion>$f7ff then mem_snd[direccion]:=valor;
end;

function system16b_snd_inbyte(puerto:word):byte;
var
  res:byte;
begin
res:=$ff;
case (puerto and $ff) of
  $00..$3f:if (puerto and 1)<>0 then res:=ym2151_0.status;
  $80..$bf:res:=upd7759_0.busy_r shl 7;
  $c0..$ff:begin
              res:=sound_latch;
              z80_0.change_irq(CLEAR_LINE);
           end;
end;
system16b_snd_inbyte:=res;
end;

procedure system16b_snd_outbyte(puerto:word;valor:byte);
begin
case (puerto and $ff) of
  $00..$3f:case (puerto and 1) of
              0:ym2151_0.reg(valor);
              1:ym2151_0.write(valor);
           end;
  $40..$7f:begin
              upd7759_0.start_w((valor shr 7) and 1);
      	      upd7759_0.reset_w((valor shr 6) and 1);
              sound_bank_num:=valor and $f;
           end;
  $80..$bf:upd7759_0.port_w(valor);
end;
end;

function system16b_mcu_getbyte(direccion:word):byte;
begin
  system16b_mcu_getbyte:=s315_5195_read_reg(direccion and $1f);
end;

procedure system16b_mcu_putbyte(direccion:word;valor:byte);
begin
  s315_5195_write_reg(direccion and $1f,valor);
end;

procedure out_port1(valor:byte);
begin
end;

function in_port1:byte;
begin
  in_port1:=marcade.in0;
end;

procedure system16b_sound_act;
begin
  ym2151_0.update;
  upd7759_0.update;
end;

procedure upd7759_drq(valor:byte);
begin
  if (valor and 1)<>0 then z80_0.change_nmi(PULSE_LINE);
end;

//Main
procedure reset_system16b;
var
  f:byte;
begin
 //Debo poner el direccionamiento antes del reset de la CPU!!!
 for f:=0 to $1f do s315_5195_regs[f]:=0;
 s315_5195_set_map;
 m68000_0.reset;
 z80_0.reset;
 mcs51_0.reset;
 upd7759_0.reset;
 ym2151_0.reset;
 reset_audio;
 marcade.in0:=$ffff;
 marcade.in1:=$ffff;
 marcade.in2:=$ffff;
 for f:=0 to $f do sprite_bank[f]:=f;
 screen_enabled:=true;
 fillchar(tile_buffer[0],$800*8,1);
 sound_latch:=0;
 from_sound:=0;
 tile_bank[0]:=0;
 tile_bank[1]:=1;
 sound_bank_num:=0;
end;

function iniciar_system16b:boolean;
var
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
  weights:array[0..1,0..5] of single;
  i0,i1,i2,i3,i4:integer;
const
  resistances_normal:array[0..5] of integer=(900, 2000, 1000, 1000 div 2,1000 div 4, 0);
	resistances_sh:array[0..5] of integer=(3900, 2000, 1000, 1000 div 2, 1000 div 4, 470);

procedure convert_chars(n:byte);
const
  pt_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7 );
  pt_y:array[0..7] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8);
begin
init_gfx(0,8,8,n*$1000);
gfx[0].trans[0]:=true;
gfx_set_desc_data(3,0,8*8,n*$10000*8,n*$8000*8,0);
convert_gfx(0,0,@memoria_temp,@pt_x,@pt_y,false,false);
end;

begin
iniciar_system16b:=false;
iniciar_audio(false);
//text
screen_init(1,512,256,true);
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
m68000_0:=cpu_m68000.create(10000000,262);
m68000_0.change_ram16_calls(system16b_getword,system16b_putword);
//Sound CPU
z80_0:=cpu_z80.create(5000000,262);
z80_0.change_ram_calls(system16b_snd_getbyte,system16b_snd_putbyte);
z80_0.change_io_calls(system16b_snd_inbyte,system16b_snd_outbyte);
z80_0.init_sound(system16b_sound_act);
//MCU
mcs51_0:=cpu_mcs51.create(8000000,262);
mcs51_0.change_ram_calls(system16b_mcu_getbyte,system16b_mcu_putbyte);
mcs51_0.change_io_calls(nil,in_port1,nil,nil,nil,out_port1,nil,nil);
//Sound
ym2151_0:=ym2151_chip.create(4000000);
upd7759_0:=upd7759_chip.create(0.9,0,upd7759_drq);
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@system16b_dip_a;
case main_vars.tipo_maquina of
  292:begin  //Altered Beast
        //Main CPU
        if not(roms_load16w(@rom,altbeast_rom)) then exit;
        //Sound CPU
        if not(roms_load(@memoria_temp,altbeast_sound)) then exit;
        copymemory(@mem_snd,@memoria_temp,$8000);
        for f:=0 to $f do copymemory(@sound_bank[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //MCU
        if not(roms_load(mcs51_0.get_rom_addr,altbeast_mcu)) then exit;
        //tiles
        if not(roms_load(@memoria_temp,altbeast_tiles)) then exit;
        convert_chars(4);
        //Sprite ROM
        if not(roms_load16w(@sprite_rom,altbeast_sprites)) then exit;
        s16_info.s_banks:=8;
        marcade.dswb:=$fd;
        marcade.dswb_val:=@altbeast_dip_b;
  end;
  293:begin  //Golden Axe
        //Main CPU
        if not(roms_load16w(@rom,goldnaxe_rom)) then exit;
        //Sound CPU
        if not(roms_load(@memoria_temp,goldnaxe_sound)) then exit;
        copymemory(@mem_snd,@memoria_temp,$8000);
        for f:=0 to 7 do copymemory(@sound_bank[f,0],@memoria_temp[$8000+(f*$4000)],$4000);
        //MCU
        if not(roms_load(mcs51_0.get_rom_addr,goldnaxe_mcu)) then exit;
        //tiles
        if not(roms_load(@memoria_temp,goldnaxe_tiles)) then exit;
        convert_chars(4);
        //Sprite ROM
        if not(roms_load16w(@sprite_rom,goldnaxe_sprites)) then exit;
        s16_info.s_banks:=$10;
        marcade.dswb:=$fd;
        marcade.dswb_val:=@altbeast_dip_b;
  end;
end;
//poner la paleta
compute_resistor_weights(0,255,-1.0,
  6,@resistances_normal[0],@weights[0],0,0,
  0,nil,nil,0,0,
  0,nil,nil,0,0);
compute_resistor_weights(0,255,-1.0,
  6,@resistances_sh[0],@weights[1],0,0,
  0,nil,nil,0,0,
  0,nil,nil,0,0);
for f:=0 to 31 do begin
  i4:=(f shr 4) and 1;
  i3:=(f shr 3) and 1;
  i2:=(f shr 2) and 1;
  i1:=(f shr 1) and 1;
  i0:=(f shr 0) and 1;
  s16_info.normal[f]:=combine_6_weights(@weights[0],i0,i1,i2,i3,i4,0);
  s16_info.shadow[f]:=combine_6_weights(@weights[1],i0,i1,i2,i3,i4,0);
  s16_info.hilight[f]:=combine_6_weights(@weights[1],i0,i1,i2,i3,i4,1);
end;
//final
reset_system16b;
iniciar_system16b:=true;
end;

procedure Cargar_system16b;
begin
llamadas_maquina.iniciar:=iniciar_system16b;
llamadas_maquina.bucle_general:=system16b_principal;
llamadas_maquina.reset:=reset_system16b;
llamadas_maquina.fps_max:=60.05439;
end;

end.
