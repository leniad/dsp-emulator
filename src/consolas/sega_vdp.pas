unit sega_vdp;

interface

uses gfx_engine,{$IFDEF WINDOWS}windows,{$endif}
     main_engine,pal_engine,nz80;

  type
    tsega_vdp=packed record
      regs:array[0..$f] of byte;
      addr:word;
      modo_video,status_reg,buffer:byte;
      int,segundo_byte:boolean;
      memory:array[0..$3FFF] of byte;
      IRQ_Handler:procedure(int:boolean);
      pant:byte;

      vdp_mode,display_disabled,is_pal:boolean;
      current_pal:array[0..31] of word;
      cram:array[0..63] of byte;
      addr_mode,cram_mask,pending_status:byte;
      line_counter,sprite_count,sprite_height,sprite_zoom:byte;
      sprite_base,y_pixels,linea_back:word;
      sprite_x,sprite_flags:array[0..7] of byte;
      sprite_tile_selected,sprite_pattern_line:array[0..7] of word;
      hpos,hpos_temp,reg9tmp,port_3f:byte;
      LINEAS_TOP_BORDE,BORDER_COLOR:byte;
      LINEAS_Y_BORDE_INFERIOR,LINEAS_Y_SYNC,VIDEO_VISIBLE_Y_TOTAL,VIDEO_Y_TOTAL:word;
    end;

procedure sega_vdp_Init(pant:byte);
procedure sega_vdp_refresh(linea:word);
procedure sega_vdp_reset;
function sega_vdp_vram_r:byte;
function sega_vdp_register_r:integer;
procedure sega_vdp_register_w(valor:byte);
procedure sega_vdp_vram_w(valor:byte);
procedure sega_vdp_close;
procedure sega_vdp_hlines(estados:word);

var
  vdp:^tsega_vdp;
  priority_selected:array[0..255] of word;

implementation
const
    PIXELS_TOTAL=342;
    PIXELS_VISIBLES_TOTAL=284;
    PIXELS_RIGHT_BORDER_VISIBLES=15;
    PIXELS_LEFT_BORDER_VISIBLES=13;
    PRIORITY_BIT=$1000;
    STATUS_SPROVR=$40;
    STATUS_SPRCOL=$20;

    hpos_conv:array[0..227] of byte=(
    $F4,$F5,$F6,$F6,$F7,$F8,$F9,$F9,$FA,$FB,$FC,$FC,$FD,$FE,$FF,$FF,
    $00,$01,$02,$02,$03,$04,$05,$05,$06,$07,$08,$08,$09,$0A,$0B,$0B,
    $0C,$0D,$0E,$0E,$0F,$10,$11,$11,$12,$13,$14,$14,$15,$16,$17,$17,
    $18,$19,$1A,$1A,$1B,$1C,$1D,$1D,$1E,$1F,$20,$20,$21,$22,$23,$23,
    $24,$25,$26,$26,$27,$28,$29,$29,$2A,$2B,$2C,$2C,$2D,$2E,$2F,$2F,
    $30,$31,$32,$32,$33,$34,$35,$35,$36,$37,$38,$38,$39,$3A,$3B,$3B,
    $3C,$3D,$3E,$3E,$3F,$40,$41,$41,$42,$43,$44,$44,$45,$46,$47,$47,
    $48,$49,$4A,$4A,$4B,$4C,$4D,$4D,$4E,$4F,$50,$50,$51,$52,$53,$53,
    $54,$55,$56,$56,$57,$58,$59,$59,$5A,$5B,$5C,$5C,$5D,$5E,$5F,$5F,
    $60,$61,$62,$62,$63,$64,$65,$65,$66,$67,$68,$68,$69,$6A,$6B,$6B,
    $6C,$6D,$6E,$6E,$6F,$70,$71,$71,$72,$73,$74,$74,$75,$76,$77,$77,
    $78,$79,$7A,$7A,$7B,$7C,$7D,$7D,$7E,$7F,$80,$80,$81,$82,$83,$83,
    $84,$85,$86,$86,$87,$88,$89,$89,$8A,$8B,$8C,$8C,$8D,$8E,$8F,$8F,
    $90,$91,$92,$92,$93,
                             $E9,$EA,$EA,$EB,$EC,$ED,$ED,$EE,$EF,$F0,$F0,
    $F1,$F2,$F3,$F3);


procedure sega_vdp_reset;
begin
  fillchar(vdp.regs[0],16,0);
  vdp.regs[10]:=$ff;
  vdp.segundo_byte:=false;
  vdp.cram_mask:=$1f;
  vdp.addr:=0;
  vdp.buffer:=0;
  vdp.status_reg:=0;
  vdp.int:=false;
  fillchar(vdp.memory[0],$4000,0);
  vdp.vdp_mode:=false;
  vdp.BORDER_COLOR:=$20;
  //video
  vdp.y_pixels:=192;
  if vdp.is_pal then begin
    vdp.LINEAS_TOP_BORDE:=54;
    vdp.LINEAS_Y_BORDE_INFERIOR:=240;
    vdp.LINEAS_Y_SYNC:=259;
  end else begin
    vdp.LINEAS_TOP_BORDE:=27;
    vdp.LINEAS_Y_BORDE_INFERIOR:=216;
    vdp.LINEAS_Y_SYNC:=235;
  end;
end;

procedure sega_vdp_init(pant:byte);
const
    tms992X_palete:array[0..15, 0..2] of byte =(
     (0,0,0),(0,0,0),(33, 200, 66),(94, 220, 120),
	  (84, 85, 237),(125, 118, 252),(212, 82, 77),(66, 235, 245),
    (252, 85, 84),(255, 121, 120),(212, 193, 84),(230, 206, 128),
	  (33, 176, 59),(201, 91, 186),(204, 204, 204),(255,255,255));
var
  f:byte;
  colores:tpaleta;
begin
//poner la paleta
for f:=0 to 15 do begin
  colores[f].r:=tms992X_palete[f,0];
  colores[f].g:=tms992X_palete[f,1];
  colores[f].b:=tms992X_palete[f,2];
end;
for f:=0 to 63 do begin
    colores[f+16].r:=pal2bit(f and $3);
    colores[f+16].g:=pal2bit((f and $c) shr 2);
    colores[f+16].b:=pal2bit((f and $30) shr 4);
end;
set_pal(colores,16+64);
getmem(vdp,sizeof(tsega_vdp));
vdp.pant:=pant;
main_z80.change_misc_calls(sega_vdp_hlines,nil);
sega_vdp_reset;
end;

procedure select_sprites(linea:word);
var
  max_sprites,sprite_index,sprite_x,flags:byte;
  parse_line,sprite_tile_selected:word;
  sprite_line,sprite_y:integer;
begin
	// At this point the VDP vcount still doesn't refer the new line,
  //because the logical start point is slightly shifted on the scanline */
	parse_line:=linea-1;
	// Check if SI is set */
	if (vdp.regs[1] and 2)<>0 then vdp.sprite_height:=16
    else vdp.sprite_height:=8;
	// Check if MAG is set */
	if (vdp.regs[1] and 1)<>0 then vdp.sprite_zoom:=2
    else vdp.sprite_zoom:=1;
	if (vdp.sprite_zoom>1) then begin
		// Divide before use the value for comparison, same later with sprite_y, or
    // else an off-by-one bug could occur, as seen with Tarzan, for Game Gear
		parse_line:=parse_line shr 1;
	end;
	vdp.sprite_count:=0;
	if not(vdp.vdp_mode) then begin
		// TMS9918 compatibility sprites */
		max_sprites:=4;
		vdp.sprite_base:=((vdp.regs[5] and $7f) shl 7);
		for sprite_index:=0 to 31 do begin
      if vdp.sprite_count>max_sprites then break;
			sprite_y:=vdp.memory[vdp.sprite_base+(sprite_index*4)];
			if (sprite_y=$d0) then break;
			if (sprite_y>240) then sprite_y:=sprite_y-256;
			if (vdp.sprite_zoom>1) then sprite_y:=sprite_y shr 1;
			if ((parse_line>=sprite_y) and (parse_line<(sprite_y+vdp.sprite_height))) then begin
				if (vdp.sprite_count < max_sprites) then begin
					sprite_x:=vdp.memory[vdp.sprite_base+(sprite_index*4)+1];
          sprite_tile_selected:=vdp.memory[vdp.sprite_base+(sprite_index*4)+2];
					flags:=vdp.memory[vdp.sprite_base+(sprite_index*4)+3];
					if (flags and $80)<>0 then sprite_x:=sprite_x-32;
					sprite_line:=parse_line-sprite_y;
					if (vdp.regs[1] and 1)<>0 then sprite_line:=sprite_line shr 1;
					if (vdp.regs[1] and 2)<>0 then begin
						sprite_tile_selected:=sprite_tile_selected and $fc;
						if (sprite_line>7) then begin
							sprite_tile_selected:=sprite_tile_selected+1;
							sprite_line:=sprite_line-8;
						end;
          end;
 					vdp.sprite_x[vdp.sprite_count]:=sprite_x;
 					vdp.sprite_tile_selected[vdp.sprite_count]:=sprite_tile_selected;
 					vdp.sprite_flags[vdp.sprite_count]:=flags;
 					vdp.sprite_pattern_line[vdp.sprite_count]:=((vdp.regs[6] and 7) shl 11)+sprite_line;
 				end;
 				vdp.sprite_count:=vdp.sprite_count+1;
 			end;
    end;
	end else begin
		// Regular sprites */
		max_sprites:=8;
		vdp.sprite_base:=((vdp.regs[5] shl 7) and $3f00);
		for sprite_index:=0 to 63 do begin
      if (vdp.sprite_count>max_sprites) then break;
			sprite_y:=vdp.memory[(vdp.sprite_base+sprite_index) and $3fff];
			if ((vdp.y_pixels=192) and (sprite_y=$d0)) then break;
			if (sprite_y>240) then sprite_y:=sprite_y-256; // wrap from top if y position is > 240
			if (vdp.sprite_zoom>1) then sprite_y:=sprite_y shr 1;
			if ((parse_line>=sprite_y) and (parse_line<(sprite_y+vdp.sprite_height))) then begin
				if (vdp.sprite_count<max_sprites) then begin
					sprite_x:=vdp.memory[(vdp.sprite_base+$80+(sprite_index shl 1)) and $3fff];
					sprite_tile_selected:=vdp.memory[(vdp.sprite_base+$81+(sprite_index shl 1)) and $3fff];
					if (vdp.regs[0] and 8)<>0 then sprite_x:=sprite_x-8;    // sprite shift */
					if (vdp.regs[6] and 4)<>0 then sprite_tile_selected:=sprite_tile_selected+256; // pattern table select */
					if (vdp.regs[1] and 2)<>0 then sprite_tile_selected:=sprite_tile_selected and $01fe; // force even index */
					sprite_line:=parse_line-sprite_y;
					if (sprite_line>7) then sprite_tile_selected:=sprite_tile_selected+1;
					vdp.sprite_x[vdp.sprite_count]:=sprite_x;
					vdp.sprite_tile_selected[vdp.sprite_count]:=sprite_tile_selected;
					vdp.sprite_pattern_line[vdp.sprite_count]:=((sprite_line and 7) shl 2);
				end;
				vdp.sprite_count:=vdp.sprite_count+1;
			end;
		end;
	end;
	if (vdp.sprite_count>max_sprites) then begin
		// Too many sprites per line */
		vdp.sprite_count:=max_sprites;
		vdp.status_reg:=vdp.status_reg or STATUS_SPROVR;
	end;
end;

procedure draw_sprites(linea:byte);
var
  sprite_col_occurred:boolean;
  sprite_col_x,plot_min_x,sprite_x,pixel_plot_x,sprite_tile_selected,sprite_pattern_line:word;
  collision_buffer:array[0..341] of byte;
  sprite_buffer_index:byte;
  bit_plane_0,bit_plane_1,bit_plane_2,bit_plane_3,pixel_x:byte;
  pen_bit_0,pen_bit_1,pen_bit_2,pen_bit_3,pen_selected:byte;
  ptemp:pword;
begin
	sprite_col_occurred:=false;
	sprite_col_x:=PIXELS_TOTAL;
	plot_min_x:= 0;
	if (vdp.display_disabled or (vdp.sprite_count=0)) then exit;
	// Sprites aren't drawn and collisions don't occur on column 0 if it is disabled */
	if (vdp.regs[0] and $20)<>0 then plot_min_x:=8;
	fillchar(collision_buffer[0],PIXELS_TOTAL,0);
	// Draw sprite layer
	for sprite_buffer_index:=(vdp.sprite_count-1) downto 0 do begin
		sprite_x:=vdp.sprite_x[sprite_buffer_index];
		sprite_tile_selected:=vdp.sprite_tile_selected[sprite_buffer_index];
		sprite_pattern_line:=vdp.sprite_pattern_line[sprite_buffer_index];
		bit_plane_0:=vdp.memory[(sprite_tile_selected shl 5)+sprite_pattern_line+0];
		bit_plane_1:=vdp.memory[(sprite_tile_selected shl 5)+sprite_pattern_line+1];
		bit_plane_2:=vdp.memory[(sprite_tile_selected shl 5)+sprite_pattern_line+2];
		bit_plane_3:=vdp.memory[(sprite_tile_selected shl 5)+sprite_pattern_line+3];
		for pixel_x:=0 to 7 do begin
			pen_bit_0:=(bit_plane_0 shr (7-pixel_x)) and 1;
			pen_bit_1:=(bit_plane_1 shr (7-pixel_x)) and 1;
			pen_bit_2:=(bit_plane_2 shr (7-pixel_x)) and 1;
			pen_bit_3:=(bit_plane_3 shr (7-pixel_x)) and 1;
			pen_selected:=(pen_bit_3 shl 3) or (pen_bit_2 shl 2) or (pen_bit_1 shl 1) or (pen_bit_0) or $10;
			if (pen_selected=$10) then continue;       // Transparent palette so skip draw
			if (vdp.sprite_zoom>1) then begin
				// sprite doubling is enabled */
				pixel_plot_x:=sprite_x+(pixel_x shl 1);
				// check to prevent going outside of active display area */
				if (pixel_plot_x<plot_min_x) or (pixel_plot_x>255) then continue;
				if ((priority_selected[pixel_plot_x] and PRIORITY_BIT)=0) then begin
          ptemp:=punbuf;
          inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
					ptemp^:=paleta[vdp.current_pal[pen_selected]];
					priority_selected[pixel_plot_x]:=pen_selected;
          inc(ptemp);
					ptemp^:=paleta[vdp.current_pal[pen_selected]];
					priority_selected[pixel_plot_x+1]:=pen_selected;
				end else begin
					if (priority_selected[pixel_plot_x]=PRIORITY_BIT) then begin
            ptemp:=punbuf;
            inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
					  ptemp^:=paleta[vdp.current_pal[pen_selected]];
						priority_selected[pixel_plot_x]:=pen_selected;
					end;
					if (priority_selected[pixel_plot_x+1]=PRIORITY_BIT) then begin
            ptemp:=punbuf;
            inc(ptemp,pixel_plot_x+1+PIXELS_LEFT_BORDER_VISIBLES);
					  ptemp^:=paleta[vdp.current_pal[pen_selected]];
						priority_selected[pixel_plot_x+1]:=pen_selected;
					end;
				end;
				if (collision_buffer[pixel_plot_x]<>1) then begin
					collision_buffer[pixel_plot_x]:=1;
				end else begin
					sprite_col_occurred:=true;
					if (sprite_col_x<pixel_plot_x) then sprite_col_x:=sprite_col_x
            else sprite_col_x:=pixel_plot_x;
				end;
				if (collision_buffer[pixel_plot_x+1]<>1) then begin
					collision_buffer[pixel_plot_x+1]:=1;
				end else begin
					sprite_col_occurred:=true;
					if (sprite_col_x<pixel_plot_x) then sprite_col_x:=sprite_col_x
            else sprite_col_x:=pixel_plot_x;
				end;
			end else begin
				pixel_plot_x:=sprite_x+pixel_x;
				// check to prevent going outside of active display area
				if ((pixel_plot_x<plot_min_x) or (pixel_plot_x>255)) then continue;
				if ((priority_selected[pixel_plot_x] and PRIORITY_BIT)=0) then begin
          ptemp:=punbuf;
          inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
          ptemp^:=paleta[vdp.current_pal[pen_selected]];
					priority_selected[pixel_plot_x]:=pen_selected;
				end else begin
					if (priority_selected[pixel_plot_x]=PRIORITY_BIT) then begin
            ptemp:=punbuf;
            inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
					  ptemp^:=paleta[vdp.current_pal[pen_selected]];
						priority_selected[pixel_plot_x]:=pen_selected;
					end;
				end;
				if (collision_buffer[pixel_plot_x]<>1) then begin
					collision_buffer[pixel_plot_x]:=1;
				end else begin
					sprite_col_occurred:=true;
					if (sprite_col_x<pixel_plot_x) then sprite_col_x:=sprite_col_x
            else sprite_col_x:=pixel_plot_x;
				end;
			end;
		end;
		if sprite_col_occurred then begin
			vdp.status_reg:=vdp.status_reg or STATUS_SPRCOL;
			//m_pending_sprcol_x = SPRCOL_BASEHPOS + sprite_col_x;
		end;
	end;
end;

procedure draw_sprites_tms(linea:word);
begin

end;

function get_name_table_row(row:word):word;
var
  tempw:word;
begin
  if vdp.y_pixels=192 then tempw:=((row shr 3) shl 6) and (((vdp.regs[2] and 1) shl 10) or $3bff)
    else tempw:=((row shr 3) shl 6);
  get_name_table_row:=tempw;
end;

procedure draw_mode_sms(linea:byte);
var
   y_scroll,x_scroll,x_scroll_start_column,tile_column:byte;
   scroll_mod,name_table_address:word;
   tile_line,pixel_x,bit_plane_0,bit_plane_1,bit_plane_2,bit_plane_3:byte;
   tile_data,tile_selected,addr_tmp,priority_select:word;
   palette_selected,vert_selected,horiz_selected:boolean;
   pen_bit_0,pen_bit_1,pen_bit_2,pen_bit_3,pen_selected:byte;
   pixel_plot_x:integer;
   ptemp:pword;
begin
// if top 2 rows of screen not affected by horizontal scrolling, then x_scroll = 0 */
// else x_scroll = m_reg8copy                                                      */
if (((vdp.regs[0] and $40)<>0) and (linea<16)) then x_scroll:=0
   else x_scroll:=$0100-vdp.regs[8];
x_scroll_start_column:=(x_scroll shr 3); // x starting column tile
if (vdp.y_pixels<>192) then begin
   name_table_address:=((vdp.regs[2] and $0c) shl 10) or $0700;
   scroll_mod:=256;
end else begin
    name_table_address:=((vdp.regs[2] and $e) shl 10) and $3800;
    scroll_mod:=224;
end;
// Draw background layer */
for tile_column:=0 to 32 do begin
    // Rightmost 8 columns for SMS (or 2 columns for GG) not affected by */
    // vertical scrolling when bit 7 of reg[0x00] is set */
    if (((vdp.regs[0] and $80)<>0) and (tile_column>23)) then y_scroll:=0
       else y_scroll:=vdp.reg9tmp;
    tile_line:=((tile_column+x_scroll_start_column) and $1f) shl 1;
    addr_tmp:=name_table_address+get_name_table_row((linea+y_scroll) mod scroll_mod)+tile_line;
    tile_data:=vdp.memory[addr_tmp]+(vdp.memory[addr_tmp+1] shl 8);
    tile_selected:=(tile_data and $1ff);
    priority_select:=tile_data and PRIORITY_BIT;
    palette_selected:=((tile_data shr 11) and 1)<>0;
    vert_selected:=((tile_data shr 10) and 1)<>0;
    horiz_selected:=((tile_data shr 9) and 1)<>0;
    tile_line:= linea-((7-(y_scroll and 7))+1);
    if vert_selected then tile_line:=7-tile_line;
    bit_plane_0:=vdp.memory[((tile_selected shl 5)+((tile_line and 7) shl 2))+0];
    bit_plane_1:=vdp.memory[((tile_selected shl 5)+((tile_line and 7) shl 2))+1];
    bit_plane_2:=vdp.memory[((tile_selected shl 5)+((tile_line and 7) shl 2))+2];
    bit_plane_3:=vdp.memory[((tile_selected shl 5)+((tile_line and 7) shl 2))+3];
    for pixel_x:=0 to 7 do begin
      pen_bit_0:=(bit_plane_0 shr (7-pixel_x)) and 1;
      pen_bit_1:=(bit_plane_1 shr (7-pixel_x)) and 1;
	    pen_bit_2:=(bit_plane_2 shr (7-pixel_x)) and 1;
	    pen_bit_3:=(bit_plane_3 shr (7-pixel_x)) and 1;
	    pen_selected:=(pen_bit_3 shl 3) or (pen_bit_2 shl 2) or (pen_bit_1 shl 1) or pen_bit_0;
	    if palette_selected then pen_selected:=pen_selected or $10;
	    if not(horiz_selected) then pixel_plot_x:=pixel_x
        else pixel_plot_x:=7-pixel_x;
	    pixel_plot_x:=(0-(x_scroll and 7)+(tile_column shl 3)+pixel_plot_x);
	    if ((pixel_plot_x>=0) and (pixel_plot_x <256)) then begin
        ptemp:=punbuf;
        inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
	      if ((tile_column=0) and ((x_scroll and 7)<>0)) then begin
	        //when the first column hasn't completely entered in the screen, its
	        //background is filled only with color #0 of the selected palette */
	        if palette_selected then ptemp^:=paleta[vdp.current_pal[$10]]
            else ptemp^:=paleta[vdp.current_pal[0]];
	        priority_selected[pixel_plot_x]:=priority_select;
	      end else begin
	        ptemp^:=paleta[vdp.current_pal[pen_selected]];
	        priority_selected[pixel_plot_x]:=priority_select or (pen_selected and $f);
	      end;
	    end;
    end;
end;
fillword(punbuf,PIXELS_LEFT_BORDER_VISIBLES,paleta[vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f]]);
ptemp:=punbuf;
inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES+256);
fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f]]);
end;

procedure draw_mode_tms(linea:word);
var
  name_table_base,color_base,pattern_base,color_mask,pattern_mask,pattern_offset,pixel_plot_x:word;
  tile_column,name,pattern,colors,pixel_x,pen_selected:byte;
  ptemp:pword;
begin
if vdp.modo_video=2 then begin
	name_table_base:=((vdp.regs[2] and $f) shl 10)+((linea shr 3)*32);
	color_base:=((vdp.regs[3] and $80) shl 6);
	color_mask:=((vdp.regs[3] and $7f) shl 3) or 7;
	pattern_base:=((vdp.regs[4] and 4) shl 11);
	pattern_mask:=((vdp.regs[4] and 3) shl 8) or $ff;
	pattern_offset:=(linea and $c0) shl 2;
	// Draw background layer */
	for tile_column:=0 to 31 do begin
		name:=vdp.memory[name_table_base+tile_column];
		pattern:=vdp.memory[pattern_base+(((pattern_offset + name) and pattern_mask)*8)+(linea and 7)];
		colors:=vdp.memory[color_base+(((pattern_offset + name) and color_mask)*8)+(linea and 7)];
		for pixel_x:=0 to 7 do  begin
			if (pattern and (1 shl (7-pixel_x)))<>0 then pen_selected:=colors shr 4
			  else pen_selected:=colors and $f;
			if (pen_selected=0) then pen_selected:=vdp.BORDER_COLOR+(vdp.regs[7] and $f);
			pixel_plot_x:=(tile_column shl 3)+pixel_x;
      ptemp:=punbuf;
      inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
			ptemp^:=paleta[pen_selected];
		end
	end
end else begin

end;
fillword(punbuf,PIXELS_LEFT_BORDER_VISIBLES,paleta[vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f]]);
ptemp:=punbuf;
inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES+256);
fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f]]);
end;

{Lineas de video fisicas NTSC
                               visible
Active display       192  224    *
Bottom border         24    8    *
Bottom blanking        3    3    -
Vertical sync          3    3    -
Top blanking          13   13    -
Top border            27   11    *
Total                262  262  243

Pixes fisicos dentro de la linea
                    Visible
Active display 256     *
Right border    15     *
Right blanking   8     -
Horiz sync      26     -
Left blanking    2     -
Color burst     14     -
Left blanking    8     -
Left border     13     *
Total          342   284}
procedure sega_vdp_refresh(linea:word);
var
  ptemp:pword;
begin
vdp.linea_back:=linea;
if linea<vdp.y_pixels then begin //Visible
  if not(vdp.display_disabled) then begin
    fillword(@priority_selected[0],256,0);
    if vdp.vdp_mode then draw_mode_sms(linea)
      else draw_mode_tms(linea);
    select_sprites(linea);
    if vdp.vdp_mode then draw_sprites(linea)
      else draw_sprites_tms(linea);
    if (vdp.regs[0] and $20)<>0 then begin
      ptemp:=punbuf;
      inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
      fillword(ptemp,8,paleta[vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f]]);
    end;
    putpixel(0,linea+vdp.LINEAS_TOP_BORDE,PIXELS_VISIBLES_TOTAL,punbuf,vdp.pant);
  end else single_line(0,linea+vdp.LINEAS_TOP_BORDE,vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f],PIXELS_VISIBLES_TOTAL,vdp.pant);
  if vdp.line_counter=0 then begin
    vdp.line_counter:=vdp.regs[$a];
    vdp.status_reg:=vdp.status_reg or $40;
    vdp.int:=true;
    if (vdp.regs[0] and $10)<>0 then vdp.IRQ_Handler(true);
  end else vdp.line_counter:=vdp.line_counter-1;
end else if linea=vdp.y_pixels then begin //1da linea borde inferior
              single_line(0,linea+vdp.LINEAS_TOP_BORDE,vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f],PIXELS_VISIBLES_TOTAL,vdp.pant);
              if vdp.line_counter=0 then begin
                 vdp.line_counter:=vdp.regs[$a];
                 vdp.status_reg:=vdp.status_reg or $40;
                 vdp.int:=true;
                 if (vdp.regs[0] and $10)<>0 then vdp.IRQ_Handler(true);
              end else vdp.line_counter:=vdp.line_counter-1;
              //La señal de que estoy en el final del frame hay que ponerla antes que ejecute la IRQ
              //sino 'Zool' se para...
              vdp.status_reg:=vdp.status_reg or $80;
         end else if linea=(vdp.y_pixels+1) then begin //2da linea borde inferior
                    single_line(0,linea+vdp.LINEAS_TOP_BORDE,vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f],PIXELS_VISIBLES_TOTAL,vdp.pant);
                    vdp.line_counter:=vdp.regs[$a];
                    if (vdp.regs[1] and $20)<>0 then begin
                      vdp.int:=true;
                      vdp.IRQ_Handler(true);
                    end;
                  end else if linea<vdp.LINEAS_Y_BORDE_INFERIOR then begin //Resto borde inferior
                              single_line(0,linea+vdp.LINEAS_TOP_BORDE,vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f],PIXELS_VISIBLES_TOTAL,vdp.pant);
                              vdp.line_counter:=vdp.regs[$a];
                           end else if linea<(vdp.LINEAS_Y_BORDE_INFERIOR+3) then begin //Resto borde inferior
                              single_line(0,linea+vdp.LINEAS_TOP_BORDE,vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f],PIXELS_VISIBLES_TOTAL,vdp.pant);
                              vdp.line_counter:=vdp.regs[$a];
                              if vdp.is_pal then vdp.linea_back:=vdp.linea_back-$38
                                else vdp.linea_back:=vdp.linea_back-5;
                              end else if linea<vdp.LINEAS_Y_SYNC then begin //Sincronismos
                                          vdp.line_counter:=vdp.regs[$a];
                                        end else begin //Borde superior
                                            single_line(0,linea-vdp.LINEAS_Y_SYNC,vdp.current_pal[vdp.BORDER_COLOR+vdp.regs[7] and $f],PIXELS_VISIBLES_TOTAL,vdp.pant);
                                            vdp.line_counter:=vdp.regs[$a];
                                        end;
end;

//change register
procedure change_reg(addr,Val:byte);
begin
  vdp.regs[addr]:=val;
  case addr of
     0:begin
         vdp.vdp_mode:=(val and 4)<>0;
         if not(vdp.vdp_mode) then begin
            vdp.modo_video:=vdp.regs[0] and 2;
            vdp.BORDER_COLOR:=$0;
         end else vdp.BORDER_COLOR:=$10;
         if (vdp.status_reg and $40)<>0 then begin
          if not((val and $10)<>0) then begin
            if vdp.int then begin
              vdp.int:=false;
              vdp.IRQ_Handler(false);
            end;
          end else begin
            vdp.int:=true;
            vdp.IRQ_Handler(true);
         end;
       end;
     end;
     1:begin
         vdp.display_disabled:=(val and $40)=0;
         if (vdp.regs[1] and $10)<>0 then begin
            vdp.y_pixels:=224;
            if vdp.is_pal then begin
              vdp.LINEAS_TOP_BORDE:=38;
              vdp.LINEAS_Y_BORDE_INFERIOR:=256;
              vdp.LINEAS_Y_SYNC:=275;
            end else begin
              vdp.LINEAS_TOP_BORDE:=11;
              vdp.LINEAS_Y_BORDE_INFERIOR:=232;
              vdp.LINEAS_Y_SYNC:=251;
            end;
         end else begin
            vdp.y_pixels:=192;
            if vdp.is_pal then begin
              vdp.LINEAS_TOP_BORDE:=54;
              vdp.LINEAS_Y_BORDE_INFERIOR:=240;
              vdp.LINEAS_Y_SYNC:=259;
            end else begin
              vdp.LINEAS_TOP_BORDE:=27;
              vdp.LINEAS_Y_BORDE_INFERIOR:=216;
              vdp.LINEAS_Y_SYNC:=235;
            end;
         end;
         if (vdp.status_reg and $80)<>0 then begin
            if not((val and $20)<>0) then begin
              if vdp.int then begin
                vdp.int:=false;
                vdp.IRQ_Handler(false);
              end;
            end else begin
              vdp.int:=true;
              vdp.IRQ_Handler(true);
            end;
         end;
       end;
  end;
end;

function sega_vdp_register_r:integer;
begin
  //'PGA Tour Golf' se cuelga si no pongo esto $1d
  sega_vdp_register_r:=vdp.status_reg or $1f;
  vdp.status_reg:=0;
  if vdp.int then begin
     vdp.int:=false;
     vdp.IRQ_Handler(false);
  end;
  vdp.segundo_byte:=false;
end;

procedure sega_vdp_register_w(valor:byte);
begin
if not(vdp.segundo_byte) then begin
  vdp.addr:=((vdp.addr and $ff00) or valor) and $3FFF;
  vdp.segundo_byte:=true;
end else begin
  vdp.segundo_byte:=false;
  vdp.addr:=((vdp.addr and $ff) or (valor shl 8)) and $3FFF;
  vdp.addr_mode:=(valor and $c0) shr 6;
  case vdp.addr_mode of
    0:begin // VRAM reading mode
          vdp.buffer:=vdp.memory[vdp.addr];
          vdp.addr:=(vdp.addr+1) and $3FFF;
          vdp.segundo_byte:=false;
        end;
    1,3:; // VRAM writing mode o CRAM writing mode
    2:change_reg(valor and $f,vdp.addr and $ff); // VDP register write
  end;
end;
end;

function sega_vdp_vram_r:byte;  //ReadDataPort
begin
  sega_vdp_vram_r:=vdp.buffer;
  vdp.buffer:=vdp.memory[vdp.addr];
  vdp.addr:=(vdp.addr+1) and $3FFF;
  vdp.segundo_byte:=false;
end;

procedure cram_write(valor:byte);
var
   address:word;
   f:byte;
begin
address:=vdp.addr and vdp.cram_mask;
if (vdp.cram[address]<>valor) then begin
   vdp.CRAM[address]:=valor;
   for f:=0 to 31 do vdp.current_pal[f]:=(vdp.cram[f] and $3f)+$10;
end;
end;

procedure sega_vdp_vram_w(valor:byte);
begin
if vdp.addr_mode=3 then cram_write(valor)
   else vdp.memory[vdp.addr]:=valor;
vdp.buffer:=valor;
vdp.addr:=(vdp.addr+1) and $3FFF;
vdp.segundo_byte:=false;
end;

procedure sega_vdp_close;
begin
if vdp<>nil then begin
  freemem(vdp);
  vdp:=nil;
end;
end;

procedure sega_vdp_hlines(estados:word);
begin
  vdp.hpos_temp:=hpos_conv[round(main_z80.contador) mod 228];
  if vdp.hpos_temp>$7f then vdp.reg9tmp:=vdp.regs[9];
end;

end.
