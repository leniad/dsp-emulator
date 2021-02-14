unit system16b_hw;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     nz80,m68000,main_engine,controls_engine,gfx_engine,rom_engine,pal_engine,
     sound_engine,ym_2151,dialogs,mc8123,upd7759;

procedure cargar_system16b;

implementation
const
        //Altered Beast
        altbeast_rom:array[0..1] of tipo_roms=(
        (n:'epr-11740.a7';l:$20000;p:0;crc:$ce227542),(n:'epr-11739.a5';l:$20000;p:$1;crc:$e466eb65));
        altbeast_sound:array[0..2] of tipo_roms=(
        (n:'epr-11686.a10';l:$8000;p:0;crc:$828a45b3),(n:'opr-11672.a11';l:$20000;p:$8000;crc:$bbd7f460),
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
        altbeast_key:tipo_roms=(n:'317-0066.key';l:$2000;p:0;crc:$ed85a054);
        //Dip
        system16b_dip_a:array [0..2] of def_dip=(
        (mask:$0f;name:'Coin A';number:16;dip:((dip_val:$7;dip_name:'4C/1C'),(dip_val:$8;dip_name:'3C/1C'),(dip_val:$9;dip_name:'2C/1C'),(dip_val:$5;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$4;dip_name:'2C/1C 4C/3C'),(dip_val:$f;dip_name:'1C/1C'),(dip_val:$3;dip_name:'1C/1C 5C/6C'),(dip_val:$2;dip_name:'1C/1C 4C/5C'),(dip_val:$1;dip_name:'1C/1C 2C/3C'),(dip_val:$6;dip_name:'2C/3C'),(dip_val:$e;dip_name:'1C/2C'),(dip_val:$d;dip_name:'1C/3C'),(dip_val:$c;dip_name:'1C/4C'),(dip_val:$b;dip_name:'1C/5C'),(dip_val:$a;dip_name:'1C/6C'),(dip_val:$0;dip_name:'Free Play (if Coin B too) or 1C/1C'))),
        (mask:$f0;name:'Coin B';number:16;dip:((dip_val:$70;dip_name:'4C/1C'),(dip_val:$80;dip_name:'3C/1C'),(dip_val:$90;dip_name:'2C/1C'),(dip_val:$50;dip_name:'2C/1C 5C/3C 6C/4C'),(dip_val:$40;dip_name:'2C/1C 4C/3C'),(dip_val:$f0;dip_name:'1C/1C'),(dip_val:$30;dip_name:'1C/1C 5C/6C'),(dip_val:$20;dip_name:'1C/1C 4C/5C'),(dip_val:$10;dip_name:'1C/1C 2C/3C'),(dip_val:$60;dip_name:'2C/3C'),(dip_val:$e0;dip_name:'1C/2C'),(dip_val:$d0;dip_name:'1C/3C'),(dip_val:$c0;dip_name:'1C/4C'),(dip_val:$b0;dip_name:'1C/5C'),(dip_val:$a0;dip_name:'1C/6C'),(dip_val:$00;dip_name:'Free Play (if Coin A too) or 1C/1C'))),());
        shinobi_dip_b:array [0..6] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2 Lives'),(dip_val:$c;dip_name:'3 Lives'),(dip_val:$4;dip_name:'5 Lives'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Difficulty';number:4;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Enemy''s Bullet Speed';number:2;dip:((dip_val:$40;dip_name:'Slow'),(dip_val:$0;dip_name:'Fast'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$80;name:'Lenguage';number:2;dip:((dip_val:$80;dip_name:'Japanese'),(dip_val:$0;dip_name:'English'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        alexkidd_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Continue';number:2;dip:((dip_val:$1;dip_name:'Only before level 5'),(dip_val:$0;dip_name:'Unlimited'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$c;dip_name:'3 Lives'),(dip_val:$8;dip_name:'4 Lives'),(dip_val:$4;dip_name:'5 Lives'),(dip_val:$0;dip_name:'240'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Bonus Life';number:4;dip:((dip_val:$20;dip_name:'10000'),(dip_val:$30;dip_name:'20000'),(dip_val:$10;dip_name:'40000'),(dip_val:$0;dip_name:'None'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Time Adjust';number:4;dip:((dip_val:$80;dip_name:'70'),(dip_val:$c0;dip_name:'60'),(dip_val:$40;dip_name:'50'),(dip_val:$0;dip_name:'40'),(),(),(),(),(),(),(),(),(),(),(),())),());
        fantzone_dip_b:array [0..5] of def_dip=(
        (mask:$1;name:'Cabinet';number:2;dip:((dip_val:$0;dip_name:'Upright'),(dip_val:$1;dip_name:'Cocktail'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2 Lives'),(dip_val:$c;dip_name:'3 Lives'),(dip_val:$4;dip_name:'4 Lives'),(dip_val:$0;dip_name:'240'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Extra Ship Cost';number:4;dip:((dip_val:$30;dip_name:'5000'),(dip_val:$20;dip_name:'10000'),(dip_val:$10;dip_name:'15000'),(dip_val:$0;dip_name:'20000'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());
        aliensynd_dip_b:array [0..4] of def_dip=(
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$8;dip_name:'2 Lives'),(dip_val:$c;dip_name:'3 Lives'),(dip_val:$4;dip_name:'4 Lives'),(dip_val:$0;dip_name:'Free Play'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Timer';number:4;dip:((dip_val:$0;dip_name:'120'),(dip_val:$10;dip_name:'130'),(dip_val:$20;dip_name:'140'),(dip_val:$30;dip_name:'150'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c0;name:'Difficulty';number:4;dip:((dip_val:$80;dip_name:'Easy'),(dip_val:$c0;dip_name:'Normal'),(dip_val:$40;dip_name:'Hard'),(dip_val:$0;dip_name:'Very Hard'),(),(),(),(),(),(),(),(),(),(),(),())),());
        wb3_dip_b:array [0..5] of def_dip=(
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$c;name:'Lives';number:4;dip:((dip_val:$0;dip_name:'2 Lives'),(dip_val:$c;dip_name:'3 Lives'),(dip_val:$8;dip_name:'4 Lives'),(dip_val:$8;dip_name:'5 Lives'),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$10;name:'Bonus Life';number:2;dip:((dip_val:$10;dip_name:'50k/100k/180k/300k'),(dip_val:$0;dip_name:'50k/150k/300k'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$20;name:'Difficulty';number:2;dip:((dip_val:$20;dip_name:'Normal'),(dip_val:$0;dip_name:'Hard'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$40;name:'Test Mode';number:2;dip:((dip_val:$40;dip_name:'No'),(dip_val:$0;dip_name:'Yes'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),());
        tetris_dip_b:array [0..2] of def_dip=(
        (mask:$2;name:'Demo Sounds';number:2;dip:((dip_val:$2;dip_name:'Off'),(dip_val:$0;dip_name:'On'),(),(),(),(),(),(),(),(),(),(),(),(),(),())),
        (mask:$30;name:'Difficulty';number:4;dip:((dip_val:$20;dip_name:'Easy'),(dip_val:$30;dip_name:'Normal'),(dip_val:$10;dip_name:'Hard'),(dip_val:$0;dip_name:'Hardest'),(),(),(),(),(),(),(),(),(),(),(),())),());

type
  tsystem16_info=record
    	normal,shadow,hilight:array[0..31] of byte;	//RGB translations for hilighted pixels
      s_banks:byte;
   end;

var
 rom,rom_data:array[0..$1ffff] of word;
 ram:array[0..$ffff] of word;
 tile_ram:array[0..$7fff] of word;
 tile_buffer:array[0..$3fff] of boolean;
 char_ram:array[0..$7ff] of word;
 sprite_ram:array[0..$3ff] of word;
 sprite_rom:array[0..$7ffff] of byte;
 sprite_bank:array[0..$f] of byte;
 s16_info:tsystem16_info;
 s16_screen:array[0..7] of byte;
 screen_enabled:boolean;
 sound_latch:byte;

 sound_rom_dec:array[0..$7fff] of byte;
 from_sound:byte;
 tile_bank:array[0..1] of byte;

 s315_5195_regs:array[0..$1f] of byte;
 s315_5195_dirs_start:array[0..7] of dword;
 s315_5195_dirs_end:array[0..7] of dword;
 s315_5195_dirs_mask:array[0..7] of dword;

procedure s315_5195_set_map;
var
  f:byte;
const
  mask:array[0..3] of dword=($ffff,$1ffff,$7ffff,$1fffff);
  size:array[0..3] of dword=($10000,$20000,$80000,$200000);
begin
for f:=0 to 7 do begin
  s315_5195_dirs_start[f]:=s315_5195_regs[$11+(f*2)] shl 16;
  s315_5195_dirs_end[f]:=s315_5195_dirs_start[f]+size[s315_5195_regs[$10+(f*2)] and $3];
  s315_5195_dirs_mask[f]:=mask[s315_5195_regs[$10+(f*2)] and $3];
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
begin
  old_val:=s315_5195_regs[dir];
  s315_5195_regs[dir]:=valor;
  case dir of
    //2:; //Resume M68000
    3:begin
        sound_latch:=valor;
        z80_0.change_irq(ASSERT_LINE);
      end;
    //4:; //IRQ M68000
    2,4,5,6,7,8,9,$a,$b,$c:halt(0);
    $10..$1f:if old_val<>valor then s315_5195_set_map;
  end;
end;

//Cada sprite 16bytes (8 words)
//parte alta byte 0
procedure draw_sprites(pri:byte);
var
  sprpri:byte;
  f:integer;
  bottom,top:word;
  xpos,addr,bank,x,y,pix,data_7,pixels,color:word;
  pitch:integer;
  spritedata:dword;

procedure system16b_draw_pixel(x,y,pix,color:word;pri:byte);
const
  pal_cons:array[0..3] of word=(0,$c00,$400,$1400);
var
  punt:word;
begin
  //color segun la prioridad:
  //0 --> $0
  //1 --> $400
  //2 --> $400+$800
  //3 --> $400+$800+$800
  //only draw if onscreen, not 0 or 15
	if ((x<512) and (pix<>0) and (pix<>15)) then begin
      punt:=paleta[color+pix+pal_cons[pri]];
      putpixel(x+ADD_SPRITE,y+ADD_SPRITE,1,@punt,7);
	end;
end;

begin
  for f:=0 to $7f do begin
    bottom:=(sprite_ram[f*$8] shr 8)+1;
    if bottom>$f0 then break;
    sprpri:=(sprite_ram[(f*$8)+4] and $ff) and $3;
    if sprpri<>pri then continue;
    bank:=sprite_bank[(sprite_ram[(f*$8)+4] shr 4) and $7];
    top:=(sprite_ram[f*$8] and $ff)+1;
    // if hidden, or top greater than/equal to bottom, or invalid bank, punt */
		if ((top>=bottom) or (bank=255)) then continue;
		xpos:=(sprite_ram[(f*$8)+1] and $1ff)-$bd;
		pitch:=smallint(sprite_ram[(f*$8)+2]);
		addr:=sprite_ram[(f*$8)+3];
		color:=((sprite_ram[(f*$8)+4] shr 8) and $3f) shl 4;
		// initialize the end address to the start address */
    sprite_ram[(f*$8)+$7]:=addr;
		// clamp to within the memory region size */
		spritedata:=$8000*(bank mod s16_info.s_banks);
		// loop from top to bottom */
		for y:=top to (bottom-1) do begin
			// advance a row */
			addr:=addr+pitch;
			// skip drawing if not within the cliprect
			if (y<=256) then begin
				// note that the System 16A sprites have a design flaw that allows the address
				// to carry into the flip flag, which is the topmost bit -- it is very important
				// to emulate this as the games compensate for it
				// non-flipped case
				if (addr and $8000)=0 then begin
					// start at the word before because we preincrement below
          sprite_ram[(f*$8)+$7]:=addr-1;
					x:=xpos;
          while ((xpos-x) and $1ff)<>1 do begin
            data_7:=sprite_ram[(f*$8)+$7]+1;
            sprite_ram[(f*$8)+$7]:=data_7;
						pixels:=(sprite_rom[(spritedata+(data_7 and $7fff)) shl 1] shl 8)+sprite_rom[((spritedata+(data_7 and $7fff)) shl 1)+1];
						// draw four pixels */
						pix:=(pixels shr 12) and $f;
            system16b_draw_pixel(x,y,pix,color,sprpri);
						pix:=(pixels shr 8) and $f;
            system16b_draw_pixel(x+1,y,pix,color,sprpri);
						pix:=(pixels shr 4) and $f;
            system16b_draw_pixel(x+2,y,pix,color,sprpri);
						pix:=(pixels shr 0) and $f;
            system16b_draw_pixel(x+3,y,pix,color,sprpri);
            x:=x+4;
						// stop if the last pixel in the group was 0xf */
						if (pix=15) then break;
					end;
				end else begin
				// flipped case */
					// start at the word after because we predecrement below */
          sprite_ram[(f*$8)+$7]:=addr+1;
					x:=xpos;
          while ((xpos-x) and $1ff)<>1 do begin
            data_7:=sprite_ram[(f*$8)+$7]-1;
            sprite_ram[(f*$8)+$7]:=data_7;
						pixels:=(sprite_rom[(spritedata+(data_7 and $7fff)) shl 1] shl 8)+sprite_rom[((spritedata+(data_7 and $7fff)) shl 1)+1];
						// draw four pixels */
						pix:=(pixels shr 0) and $f;
            system16b_draw_pixel(x,y,pix,color,sprpri);
						pix:=(pixels shr 4) and $f;
            system16b_draw_pixel(x+1,y,pix,color,sprpri);
						pix:=(pixels shr 8) and $f;
            system16b_draw_pixel(x+2,y,pix,color,sprpri);
						pix:=(pixels shr 12) and $f;
            system16b_draw_pixel(x+3,y,pix,color,sprpri);
            x:=x+4;
						// stop if the last pixel in the group was 0xf */
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
    //if (tile_buffer[(num*$800)+f] or buffer_color[color]) then begin
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
      tile_buffer[(num*$800)+f]:=false;
    //end;
    pos:=pos+1;
  end;
end;

procedure update_video_system16b;
var
  f,nchar,color,scroll_x1,scroll_x2,x,y,atrib:word;
  scroll_y1,scroll_y2:byte;
begin
{if not(screen_enabled) then begin
  fill_full_screen(7,$1fff);
  actualiza_trozo_final(0,0,320,224,7);
  exit;
end; }
//Background
draw_tiles(0,0,256,3,false);
draw_tiles(1,512,256,3,false);
draw_tiles(2,0,0,3,false);
draw_tiles(3,512,0,3,false);
scroll_x1:=char_ram[$74c] and $3ff;
scroll_x1:=($c8-(scroll_x1+520)) and $3ff;
scroll_y1:=char_ram[$748] and $1ff;
//Foreground
draw_tiles(4,0,256,5,true);
draw_tiles(5,512,256,5,true);
draw_tiles(6,0,0,5,true);
draw_tiles(7,512,0,5,true);
scroll_x2:=char_ram[$74d] and $3ff;
scroll_x2:=($c8-(scroll_x2+520)) and $3ff;
scroll_y2:=char_ram[$749] and $1ff;
//text
for f:=$0 to $6ff do begin
  atrib:=char_ram[f];
  color:=(atrib shr 9) and $7;
  //if (gfx[0].buffer[f] or buffer_color[color]) then begin
    x:=(f and $3f) shl 3;
    y:=(f shr 6) shl 3;
    nchar:=tile_bank[0]*$1000+(atrib and $1ff);
    put_gfx_trans(x,y,nchar,color shl 3,1,0);
    if (nchar and $8000)<>0 then put_gfx_trans(x,y,nchar,color shl 3,2,0)
      else put_gfx_block_trans(x,y,2,8,8);
    gfx[0].buffer[f]:=false;
  //end;
end;
//Lo pongo todo con prioridades, falta scrollrow y scrollcol!!
scroll_x_y(4,7,scroll_x1,scroll_y1); //0
//draw_sprites(0);
scroll_x_y(3,7,scroll_x1,scroll_y1); //1
//draw_sprites(1);
scroll_x_y(6,7,scroll_x2,scroll_y2); //2
scroll_x_y(5,7,scroll_x2,scroll_y2);  //2
//draw_sprites(2);
actualiza_trozo(192,0,320,224,2,0,0,320,224,7); //4
//draw_sprites(3);
actualiza_trozo(192,0,320,224,1,0,0,320,224,7); //8
//Y lo pinto a la pantalla principal
actualiza_trozo_final(0,0,320,224,7);
//actualiza_trozo_final(0,0,1024,512,7);
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
  frame_m,frame_s:single;
  f:word;
begin
init_controls(false,false,false,true);
frame_m:=m68000_0.tframes;
frame_s:=z80_0.tframes;
while EmuStatus=EsRuning do begin
  for f:=0 to 261 do begin
     //main
     m68000_0.run(frame_m);
     frame_m:=frame_m+m68000_0.tframes-m68000_0.contador;
     //sound
     z80_0.run(frame_s);
     frame_s:=frame_s+z80_0.tframes-z80_0.contador;
     if f=223 then begin
       m68000_0.irq[4]:=HOLD_LINE;
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
  $2000:case (direccion and $3) of
                  0,1:res:=marcade.dswa; //DSW1
                  2,3:res:=marcade.dswb; //DSW2
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
	// get the new value */
  val:=buffer_paleta[direccion];
	//     byte 0    byte 1 */
	//  sBGR BBBB GGGG RRRR */
	//  x000 4321 4321 4321 */
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
  //Buffer
  buffer_color[(direccion shr 3) and $7f]:=true;
end;

procedure test_screen_change(direccion:word);
begin
if direccion=$741 then begin
          //Foreground
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
if direccion=$740 then begin
            //Background
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
end;

function system16b_getword(direccion:dword):word;
begin
if ((direccion>=s315_5195_dirs_start[0]) and (direccion<=s315_5195_dirs_end[0])) then
  system16b_getword:=rom[(direccion and $3ffff) shr 1]
  else if ((direccion>=s315_5195_dirs_start[1]) and (direccion<=s315_5195_dirs_end[1])) then
    halt(direccion)
    else if ((direccion>=s315_5195_dirs_start[2]) and (direccion<=s315_5195_dirs_end[2])) then
      exit //MISc
      else if ((direccion>=s315_5195_dirs_start[3]) and (direccion<=s315_5195_dirs_end[3])) then
        system16b_getword:=ram[(direccion and $ffff) shr 1] //RAM
        else if ((direccion>=s315_5195_dirs_start[4]) and (direccion<=s315_5195_dirs_end[4])) then
           system16b_getword:=sprite_ram[(direccion and $7ff) shr 1] //Object RAM
           else if ((direccion>=s315_5195_dirs_start[5]) and (direccion<=s315_5195_dirs_end[5])) then
            system16b_getword:=tile_ram[(direccion and $ffff) shr 1] //Text/Tile RAM
            else if ((direccion>=s315_5195_dirs_start[6]) and (direccion<=s315_5195_dirs_end[6])) then
              system16b_getword:=buffer_paleta[(direccion and $fff) shr 1] //Color RAM
              else if ((direccion>=s315_5195_dirs_start[7]) and (direccion<=s315_5195_dirs_end[7])) then
                system16b_getword:=$ffff //IO Read
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
  exit
  else if ((direccion>=s315_5195_dirs_start[1]) and (direccion<=s315_5195_dirs_end[1])) then
    halt(1)
    else if ((direccion>=s315_5195_dirs_start[2]) and (direccion<=s315_5195_dirs_end[2])) then begin
      if (direccion and $3)=1 then
        tile_bank[0]:=valor and 7; //Tile bank!
      if (direccion and $3)=3 then
        tile_bank[1]:=valor and 7;
    end
      else if ((direccion>=s315_5195_dirs_start[3]) and (direccion<=s315_5195_dirs_end[3])) then
      ram[(direccion and $ffff) shr 1]:=valor //RAM
        else if ((direccion>=s315_5195_dirs_start[4]) and (direccion<=s315_5195_dirs_end[4])) then
          sprite_ram[(direccion and $7ff) shr 1]:=valor //Object RAM
          else if ((direccion>=s315_5195_dirs_start[5]) and (direccion<=s315_5195_dirs_end[5])) then begin
            if (s315_5195_regs[$1a] and 3)=0 then begin
              char_ram[(direccion and $fff) shr 1]:=valor;
            end else begin
              case direccion and $1ffff of
                0..$ffff:tile_ram[(direccion and $ffff) shr 1]:=valor;
                $10000..$1ffff:begin
                                char_ram[(direccion and $fff) shr 1]:=valor;
                                gfx[0].buffer[(direccion and $fff) shr 1]:=true;
                                test_screen_change((direccion and $fff) shr 1);
                               end;
              end;
            end;
            end else if ((direccion>=s315_5195_dirs_start[6]) and (direccion<=s315_5195_dirs_end[6])) then begin
              buffer_paleta[(direccion and $fff) shr 1]:=valor;
              change_pal((direccion and $fff) shr 1);
              end else if ((direccion>=s315_5195_dirs_start[7]) and (direccion<=s315_5195_dirs_end[7])) then
                exit //IO
else s315_5195_write_reg((direccion shr 1) and $1f,valor and $ff);
end;

function system16b_snd_getbyte(direccion:word):byte;
var
  res:byte;
begin
res:=$ff;
case direccion of
  0..$7fff:if z80_0.opcode then res:=sound_rom_dec[direccion]
              else res:=mem_snd[direccion];
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
      	      upd7759_0.start_w((valor shr 6) and 1);
              //Calcular el banco de sonido!!
           end;
  $80..$bf:upd7759_0.port_w(valor);
end;
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
end;

function iniciar_system16b:boolean;
var
  f:word;
  memoria_temp:array[0..$7ffff] of byte;
  mem_key:array[0..$1fff] of byte;
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
//Sound CPU
z80_0:=cpu_z80.create(4000000,262);
z80_0.change_ram_calls(system16b_snd_getbyte,system16b_snd_putbyte);
z80_0.change_io_calls(system16b_snd_inbyte,system16b_snd_outbyte);
z80_0.init_sound(system16b_sound_act);
//PPI 825
//Timers
ym2151_0:=ym2151_chip.create(4000000);
upd7759_0:=upd7759_chip.create(640000,0.9,upd7759_drq);
//DIP
marcade.dswa:=$ff;
marcade.dswa_val:=@system16b_dip_a;
case main_vars.tipo_maquina of
  292:begin  //Altered Beast
        //Main CPU
        m68000_0.change_ram16_calls(system16b_getword,system16b_putword);
        //cargar roms
        if not(roms_load16w(@rom,altbeast_rom)) then exit;
        //cargar sonido
        if not(roms_load(@memoria_temp,altbeast_sound)) then exit;
        copymemory(@mem_snd,@memoria_temp,$8000);
        if not(roms_load(@mem_key,altbeast_key)) then exit;
        mc8123_decrypt_rom(@mem_key,@mem_snd,@sound_rom_dec,$8000);
        copymemory(@mem_snd[$8000],@memoria_temp[$8000],$6000);
        //convertir tiles
        if not(roms_load(@memoria_temp,altbeast_tiles)) then exit;
        convert_chars(4);
        //Cargar ROM de los sprites y recolocarlos
        {if not(roms_load16b(@memoria_temp,altbeast_sprites)) then exit;
        for f:=0 to 7 do begin
          copymemory(@sprite_rom[0],@memoria_temp[0],$10000);
          copymemory(@sprite_rom[$40000],@memoria_temp[$10000],$10000);
          copymemory(@sprite_rom[$10000],@memoria_temp[$20000],$10000);
          copymemory(@sprite_rom[$50000],@memoria_temp[$30000],$10000);
          copymemory(@sprite_rom[$20000],@memoria_temp[$40000],$10000);
          copymemory(@sprite_rom[$60000],@memoria_temp[$50000],$10000);
          copymemory(@sprite_rom[$30000],@memoria_temp[$60000],$10000);
          copymemory(@sprite_rom[$70000],@memoria_temp[$70000],$10000);
        end; }
        s16_info.s_banks:=8;
        marcade.dswb:=$fc;
        marcade.dswb_val:=@shinobi_dip_b;
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
end;

end.
