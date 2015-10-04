unit sega_vdp;

interface

uses gfx_engine,{$IFDEF WINDOWS}windows,{$endif}
     main_engine,pal_engine,tms99xx;

const
  LINES_NTSC=262;
  LINES_PAL=313;

  type
    vdp_chip=class
      constructor create(pant:byte;irq_call:irq_type);
      procedure Free;
      destructor Destroy;
      public
        is_pal:boolean;
        hpos,hpos_temp,port_3f:byte;
        linea_back,VIDEO_VISIBLE_Y_TOTAL,VIDEO_Y_TOTAL:word;
        procedure refresh(linea:word);
        procedure reset;
        function vram_r:byte;
        function register_r:integer;
        procedure register_w(valor:byte);
        procedure vram_w(valor:byte);
        procedure hlines(estados:word);
        procedure set_pal_video;
        procedure set_ntsc_video;
      private
        SMS_IRQ_Handler:procedure(int:boolean);
        tms:tms99xx_chip;
        display_disabled:boolean;
        current_pal:array[0..31] of word;
        cram:array[0..63] of byte;
        addr_mode,cram_mask,reg9tmp:byte;
        line_counter,sprite_count,sprite_height,sprite_zoom:byte;
        sprite_base,y_pixels:word;
        sprite_x:array[0..7] of byte;
        sprite_tile_selected,sprite_pattern_line:array[0..7] of word;
        LINEAS_TOP_BORDE:byte;
        LINEAS_Y_BORDE_INFERIOR,LINEAS_Y_SYNC:word;
        procedure select_sprites(linea:word);
        procedure draw_sprites(linea:byte);
        procedure draw_mode_sms(linea:byte);
    end;

var
  vdp_0:vdp_chip;

implementation
var
  priority_selected:array[0..255] of word;

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

procedure vdp_chip.reset;
begin
  self.tms.reset;
  self.tms.regs[10]:=$ff;
  self.tms.regs[2]:=$e;
  self.cram_mask:=$1f;
  //video
  self.y_pixels:=192;
  if self.is_pal then begin
    self.LINEAS_TOP_BORDE:=54;
    self.LINEAS_Y_BORDE_INFERIOR:=240;
    self.LINEAS_Y_SYNC:=259;
  end else begin
    self.LINEAS_TOP_BORDE:=27;
    self.LINEAS_Y_BORDE_INFERIOR:=216;
    self.LINEAS_Y_SYNC:=235;
  end;
end;

destructor vdp_chip.destroy;
begin
self.tms.free;
end;

procedure vdp_chip.free;
begin
self.Destroy;
end;

constructor vdp_chip.create(pant:byte;irq_call:irq_type);
var
  f:byte;
  colores:tpaleta;
begin
for f:=0 to 63 do begin
    colores[f+16].r:=pal2bit(f and $3);
    colores[f+16].g:=pal2bit((f and $c) shr 2);
    colores[f+16].b:=pal2bit((f and $30) shr 4);
end;
set_pal(colores,64+16);
self.tms:=tms99xx_chip.create(pant,irq_call);
self.SMS_IRQ_Handler:=irq_call;
self.reset;
end;

procedure vdp_chip.select_sprites(linea:word);
var
  max_sprites,sprite_index,sprite_x,flags:byte;
  parse_line,sprite_tile_selected:word;
  sprite_line,sprite_y:integer;
begin
	// At this point the VDP vcount still doesn't refer the new line,
  //because the logical start point is slightly shifted on the scanline */
	parse_line:=linea-1;
	// Check if SI is set */
	if (self.tms.regs[1] and 2)<>0 then self.sprite_height:=16
    else self.sprite_height:=8;
	// Check if MAG is set */
	if (self.tms.regs[1] and 1)<>0 then self.sprite_zoom:=2
    else self.sprite_zoom:=1;
	if (self.sprite_zoom>1) then begin
		// Divide before use the value for comparison, same later with sprite_y, or
    // else an off-by-one bug could occur, as seen with Tarzan, for Game Gear
		parse_line:=parse_line shr 1;
	end;
	self.sprite_count:=0;
  max_sprites:=8;
  self.sprite_base:=((self.tms.regs[5] shl 7) and $3f00);
  for sprite_index:=0 to 63 do begin
      if (self.sprite_count>max_sprites) then break;
			sprite_y:=self.tms.memory[(self.sprite_base+sprite_index) and $3fff];
			if ((self.y_pixels=192) and (sprite_y=$d0)) then break;
			if (sprite_y>240) then sprite_y:=sprite_y-256; // wrap from top if y position is > 240
			if (self.sprite_zoom>1) then sprite_y:=sprite_y shr 1;
			if ((parse_line>=sprite_y) and (parse_line<(sprite_y+self.sprite_height))) then begin
				if (self.sprite_count<max_sprites) then begin
					sprite_x:=self.tms.memory[(self.sprite_base+$80+(sprite_index shl 1)) and $3fff];
					sprite_tile_selected:=self.tms.memory[(self.sprite_base+$81+(sprite_index shl 1)) and $3fff];
					if (self.tms.regs[0] and 8)<>0 then sprite_x:=sprite_x-8;    // sprite shift */
					if (self.tms.regs[6] and 4)<>0 then sprite_tile_selected:=sprite_tile_selected+256; // pattern table select */
					if (self.tms.regs[1] and 2)<>0 then sprite_tile_selected:=sprite_tile_selected and $01fe; // force even index */
					sprite_line:=parse_line-sprite_y;
					if (sprite_line>7) then sprite_tile_selected:=sprite_tile_selected+1;
					self.sprite_x[self.sprite_count]:=sprite_x;
					self.sprite_tile_selected[self.sprite_count]:=sprite_tile_selected;
					self.sprite_pattern_line[self.sprite_count]:=((sprite_line and 7) shl 2);
				end;
				self.sprite_count:=self.sprite_count+1;
			end;
  end;
	if (self.sprite_count>max_sprites) then begin
		// Too many sprites per line */
		self.sprite_count:=max_sprites;
		self.tms.status_reg:=self.tms.status_reg or STATUS_SPROVR;
	end;
end;

procedure vdp_chip.draw_sprites(linea:byte);
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
	if (self.display_disabled or (self.sprite_count=0)) then exit;
	// Sprites aren't drawn and collisions don't occur on column 0 if it is disabled */
	if (self.tms.regs[0] and $20)<>0 then plot_min_x:=8;
	fillchar(collision_buffer[0],PIXELS_TOTAL,0);
	// Draw sprite layer
	for sprite_buffer_index:=(self.sprite_count-1) downto 0 do begin
		sprite_x:=self.sprite_x[sprite_buffer_index];
		sprite_tile_selected:=self.sprite_tile_selected[sprite_buffer_index];
		sprite_pattern_line:=self.sprite_pattern_line[sprite_buffer_index];
		bit_plane_0:=self.tms.memory[(sprite_tile_selected shl 5)+sprite_pattern_line+0];
		bit_plane_1:=self.tms.memory[(sprite_tile_selected shl 5)+sprite_pattern_line+1];
		bit_plane_2:=self.tms.memory[(sprite_tile_selected shl 5)+sprite_pattern_line+2];
		bit_plane_3:=self.tms.memory[(sprite_tile_selected shl 5)+sprite_pattern_line+3];
		for pixel_x:=0 to 7 do begin
			pen_bit_0:=(bit_plane_0 shr (7-pixel_x)) and 1;
			pen_bit_1:=(bit_plane_1 shr (7-pixel_x)) and 1;
			pen_bit_2:=(bit_plane_2 shr (7-pixel_x)) and 1;
			pen_bit_3:=(bit_plane_3 shr (7-pixel_x)) and 1;
			pen_selected:=(pen_bit_3 shl 3) or (pen_bit_2 shl 2) or (pen_bit_1 shl 1) or (pen_bit_0) or $10;
			if (pen_selected=$10) then continue;       // Transparent palette so skip draw
			if (self.sprite_zoom>1) then begin
				// sprite doubling is enabled */
				pixel_plot_x:=sprite_x+(pixel_x shl 1);
				// check to prevent going outside of active display area */
				if (pixel_plot_x<plot_min_x) or (pixel_plot_x>255) then continue;
				if ((priority_selected[pixel_plot_x] and PRIORITY_BIT)=0) then begin
          ptemp:=punbuf;
          inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
					ptemp^:=paleta[self.current_pal[pen_selected]];
					priority_selected[pixel_plot_x]:=pen_selected;
          inc(ptemp);
					ptemp^:=paleta[self.current_pal[pen_selected]];
					priority_selected[pixel_plot_x+1]:=pen_selected;
				end else begin
					if (priority_selected[pixel_plot_x]=PRIORITY_BIT) then begin
            ptemp:=punbuf;
            inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
					  ptemp^:=paleta[self.current_pal[pen_selected]];
						priority_selected[pixel_plot_x]:=pen_selected;
					end;
					if (priority_selected[pixel_plot_x+1]=PRIORITY_BIT) then begin
            ptemp:=punbuf;
            inc(ptemp,pixel_plot_x+1+PIXELS_LEFT_BORDER_VISIBLES);
					  ptemp^:=paleta[self.current_pal[pen_selected]];
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
          ptemp^:=paleta[self.current_pal[pen_selected]];
					priority_selected[pixel_plot_x]:=pen_selected;
				end else begin
					if (priority_selected[pixel_plot_x]=PRIORITY_BIT) then begin
            ptemp:=punbuf;
            inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
					  ptemp^:=paleta[self.current_pal[pen_selected]];
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
			self.tms.status_reg:=self.tms.status_reg or STATUS_SPRCOL;
			//m_pending_sprcol_x = SPRCOL_BASEHPOS + sprite_col_x;
		end;
	end;
end;

function get_name_table_row(vdp:vdp_chip;row:word):word;
var
  tempw:word;
begin
  if vdp.y_pixels=192 then tempw:=((row shr 3) shl 6) and (((vdp.tms.regs[2] and 1) shl 10) or $3bff)
    else tempw:=((row shr 3) shl 6);
  get_name_table_row:=tempw;
end;

procedure vdp_chip.draw_mode_sms(linea:byte);
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
if (((self.tms.regs[0] and $40)<>0) and (linea<16)) then x_scroll:=0
   else x_scroll:=$0100-self.tms.regs[8];
x_scroll_start_column:=(x_scroll shr 3); // x starting column tile
if (self.y_pixels<>192) then begin
   name_table_address:=((self.tms.regs[2] and $0c) shl 10) or $0700;
   scroll_mod:=256;
end else begin
    name_table_address:=((self.tms.regs[2] and $e) shl 10) and $3800;
    scroll_mod:=224;
end;
// Draw background layer */
for tile_column:=0 to 32 do begin
    // Rightmost 8 columns for SMS (or 2 columns for GG) not affected by */
    // vertical scrolling when bit 7 of reg[0x00] is set */
    if (((self.tms.regs[0] and $80)<>0) and (tile_column>23)) then y_scroll:=0
       else y_scroll:=self.reg9tmp;
    tile_line:=((tile_column+x_scroll_start_column) and $1f) shl 1;
    addr_tmp:=name_table_address+get_name_table_row(self,(linea+y_scroll) mod scroll_mod)+tile_line;
    tile_data:=self.tms.memory[addr_tmp]+(self.tms.memory[addr_tmp+1] shl 8);
    tile_selected:=(tile_data and $1ff);
    priority_select:=tile_data and PRIORITY_BIT;
    palette_selected:=((tile_data shr 11) and 1)<>0;
    vert_selected:=((tile_data shr 10) and 1)<>0;
    horiz_selected:=((tile_data shr 9) and 1)<>0;
    tile_line:= linea-((7-(y_scroll and 7))+1);
    if vert_selected then tile_line:=7-tile_line;
    bit_plane_0:=self.tms.memory[((tile_selected shl 5)+((tile_line and 7) shl 2))+0];
    bit_plane_1:=self.tms.memory[((tile_selected shl 5)+((tile_line and 7) shl 2))+1];
    bit_plane_2:=self.tms.memory[((tile_selected shl 5)+((tile_line and 7) shl 2))+2];
    bit_plane_3:=self.tms.memory[((tile_selected shl 5)+((tile_line and 7) shl 2))+3];
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
	        if palette_selected then ptemp^:=paleta[self.current_pal[$10]]
            else ptemp^:=paleta[self.current_pal[0]];
	        priority_selected[pixel_plot_x]:=priority_select;
	      end else begin
	        ptemp^:=paleta[self.current_pal[pen_selected]];
	        priority_selected[pixel_plot_x]:=priority_select or (pen_selected and $f);
	      end;
	    end;
    end;
end;
fillword(punbuf,PIXELS_LEFT_BORDER_VISIBLES,paleta[self.current_pal[$10+self.tms.regs[7] and $f]]);
ptemp:=punbuf;
inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES+256);
fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[self.current_pal[$10+self.tms.regs[7] and $f]]);
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
procedure vdp_chip.refresh(linea:word);
var
  ptemp:pword;
begin
if self.tms.vdp_mode then begin
 self.linea_back:=linea;
 if linea<self.y_pixels then begin //Visible
  if not(self.display_disabled) then begin
    fillword(@priority_selected[0],256,0);
    self.draw_mode_sms(linea);
    self.select_sprites(linea);
    self.draw_sprites(linea);
    if (self.tms.regs[0] and $20)<>0 then begin
      ptemp:=punbuf;
      inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
      fillword(ptemp,8,paleta[self.current_pal[$10+self.tms.regs[7] and $f]]);
    end;
    putpixel(0,linea+self.LINEAS_TOP_BORDE,PIXELS_VISIBLES_TOTAL,punbuf,self.tms.pant);
  end else single_line(0,linea+self.LINEAS_TOP_BORDE,self.current_pal[$10+self.tms.regs[7] and $f],PIXELS_VISIBLES_TOTAL,self.tms.pant);
  if self.line_counter=0 then begin
    self.line_counter:=self.tms.regs[$a];
    self.tms.status_reg:=self.tms.status_reg or $40;
    self.tms.int:=true;
    if (self.tms.regs[0] and $10)<>0 then self.SMS_IRQ_Handler(true);
  end else self.line_counter:=self.line_counter-1;
 end else if linea=self.y_pixels then begin //1da linea borde inferior
              single_line(0,linea+self.LINEAS_TOP_BORDE,self.current_pal[$10+self.tms.regs[7] and $f],PIXELS_VISIBLES_TOTAL,self.tms.pant);
              if self.line_counter=0 then begin
                 self.line_counter:=self.tms.regs[$a];
                 self.tms.status_reg:=self.tms.status_reg or $40;
                 self.tms.int:=true;
                 if (self.tms.regs[0] and $10)<>0 then self.SMS_IRQ_Handler(true);
              end else self.line_counter:=self.line_counter-1;
              //La señal de que estoy en el final del frame hay que ponerla antes que ejecute la IRQ
              //sino 'Zool' se para...
              self.tms.status_reg:=self.tms.status_reg or $80;
         end else if linea=(self.y_pixels+1) then begin //2da linea borde inferior
                    single_line(0,linea+self.LINEAS_TOP_BORDE,self.current_pal[$10+self.tms.regs[7] and $f],PIXELS_VISIBLES_TOTAL,self.tms.pant);
                    self.line_counter:=self.tms.regs[$a];
                    if (self.tms.regs[1] and $20)<>0 then begin
                      self.tms.int:=true;
                      self.SMS_IRQ_Handler(true);
                    end;
                  end else if linea<self.LINEAS_Y_BORDE_INFERIOR then begin //Resto borde inferior
                              single_line(0,linea+self.LINEAS_TOP_BORDE,self.current_pal[$10+self.tms.regs[7] and $f],PIXELS_VISIBLES_TOTAL,self.tms.pant);
                              self.line_counter:=self.tms.regs[$a];
                           end else if linea<(self.LINEAS_Y_BORDE_INFERIOR+3) then begin //Resto borde inferior
                              single_line(0,linea+self.LINEAS_TOP_BORDE,self.current_pal[$10+self.tms.regs[7] and $f],PIXELS_VISIBLES_TOTAL,self.tms.pant);
                              self.line_counter:=self.tms.regs[$a];
                              if self.is_pal then self.linea_back:=self.linea_back-$38
                                else self.linea_back:=self.linea_back-5;
                              end else if linea<self.LINEAS_Y_SYNC then begin //Sincronismos
                                          self.line_counter:=self.tms.regs[$a];
                                        end else begin //Borde superior
                                            single_line(0,linea-self.LINEAS_Y_SYNC,self.current_pal[$10+self.tms.regs[7] and $f],PIXELS_VISIBLES_TOTAL,self.tms.pant);
                                            self.line_counter:=self.tms.regs[$a];
                                        end;
end else self.tms.refresh(linea);
end;

//change register
procedure change_reg(vdp:vdp_chip;addr,Val:byte);
begin
  vdp.tms.regs[addr]:=val;
  case addr of
     0:begin
         vdp.tms.vdp_mode:=(val and 4)<>0;
         if (vdp.tms.status_reg and $40)<>0 then begin
          if not((val and $10)<>0) then begin
              if vdp.tms.int then begin
                vdp.tms.int:=false;
                vdp.SMS_IRQ_Handler(false);
              end;
            end else begin
              vdp.tms.int:=true;
              vdp.SMS_IRQ_Handler(true);
            end;
         end;
     end;
     1:begin
         vdp.display_disabled:=(val and $40)=0;
         if (vdp.tms.regs[1] and $10)<>0 then begin
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
         if (vdp.tms.status_reg and $80)<>0 then begin
            if not((val and $20)<>0) then begin
              if vdp.tms.int then begin
                vdp.tms.int:=false;
                vdp.SMS_IRQ_Handler(false);
              end;
            end else begin
              vdp.tms.int:=true;
              vdp.SMS_IRQ_Handler(true);
            end;
         end;
       end;
  end;
end;

function vdp_chip.register_r:integer;
begin
  if self.tms.vdp_mode then begin
    //'PGA Tour Golf' se cuelga si no pongo esto $1d
    register_r:=self.tms.status_reg or $1f;
    self.tms.status_reg:=0;
    if self.tms.int then begin
       self.tms.int:=false;
       self.SMS_IRQ_Handler(false);
    end;
    self.tms.segundo_byte:=false;
  end else register_r:=self.tms.register_r;
end;

procedure vdp_chip.register_w(valor:byte);
begin
if self.tms.vdp_mode then begin
  if not(self.tms.segundo_byte) then begin
    self.tms.addr:=((self.tms.addr and $ff00) or valor) and $3FFF;
    self.tms.segundo_byte:=true;
  end else begin
    self.tms.segundo_byte:=false;
    self.tms.addr:=((self.tms.addr and $ff) or (valor shl 8)) and $3FFF;
    self.addr_mode:=(valor and $c0) shr 6;
    case self.addr_mode of
      0:begin // VRAM reading mode
          self.tms.buffer:=self.tms.memory[self.tms.addr];
          self.tms.addr:=(self.tms.addr+1) and $3FFF;
          self.tms.segundo_byte:=false;
        end;
      1,3:; // VRAM writing mode o CRAM writing mode
      2:change_reg(self,valor and $f,self.tms.addr and $ff); // VDP register write
    end;
  end;
end else self.tms.register_w(valor);
end;

function vdp_chip.vram_r:byte;
begin
if self.tms.vdp_mode then begin
  vram_r:=self.tms.buffer;
  self.tms.buffer:=self.tms.memory[self.tms.addr];
  self.tms.addr:=(self.tms.addr+1) and $3FFF;
  self.tms.segundo_byte:=false;
end else vram_r:=self.tms.vram_r;
end;

procedure cram_write(vdp:vdp_chip;valor:byte);
var
   address:word;
   f:byte;
begin
address:=vdp.tms.addr and vdp.cram_mask;
if (vdp.cram[address]<>valor) then begin
   vdp.CRAM[address]:=valor;
   for f:=0 to 31 do vdp.current_pal[f]:=(vdp.cram[f] and $3f)+$10;
end;
end;

procedure vdp_chip.vram_w(valor:byte);
begin
if self.tms.vdp_mode then begin
  if self.addr_mode=3 then cram_write(self,valor)
     else self.tms.memory[self.tms.addr]:=valor;
  self.tms.buffer:=valor;
  self.tms.addr:=(self.tms.addr+1) and $3FFF;
  self.tms.segundo_byte:=false;
end else self.tms.vram_w(valor);
end;

procedure vdp_chip.hlines(estados:word);
begin
  self.hpos_temp:=hpos_conv[estados mod 228];
  if self.hpos_temp>$7f then self.reg9tmp:=self.tms.regs[9];
end;

procedure vdp_chip.set_pal_video;
begin
self.is_pal:=true;
self.VIDEO_VISIBLE_Y_TOTAL:=294;
self.VIDEO_Y_TOTAL:=LINES_PAL;
self.LINEAS_TOP_BORDE:=54;
self.LINEAS_Y_BORDE_INFERIOR:=240;
self.LINEAS_Y_SYNC:=259;
end;

procedure vdp_chip.set_ntsc_video;
begin
self.is_pal:=false;
self.VIDEO_VISIBLE_Y_TOTAL:=243;
self.VIDEO_Y_TOTAL:=LINES_NTSC;
self.LINEAS_TOP_BORDE:=27;
self.LINEAS_Y_BORDE_INFERIOR:=216;
self.LINEAS_Y_SYNC:=235;
end;

end.
