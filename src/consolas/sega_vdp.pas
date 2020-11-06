unit sega_vdp;

interface

uses gfx_engine,{$IFDEF WINDOWS}windows,{$endif}
     main_engine,pal_engine,tms99xx,dialogs,timer_engine;

const
  LINES_NTSC=262;
  LINES_PAL=313;
  hpos_conv:array[0..227] of byte=(
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
	  $90,$91,$92,$92,$93,$E9,$EA,$EA,$EB,$EC,$ED,$ED,$EE,$EF,$F0,$F0,
	  $F1,$F2,$F3,$F3,$F4,$F5,$F6,$F6,$F7,$F8,$F9,$F9,$FA,$FB,$FC,$FC,
	  $FD,$FE,$FF,$FF);

  type
    read_mem_type=function(direccion:word):byte;
    write_mem_type=procedure(direccion:word;valor:byte);
    vdp_chip=class
      constructor create(pant:byte;irq_call:irq_type;cpu_num:byte;read_mem:read_mem_type=nil;write_mem:write_mem_type=nil;trans:boolean=false);
      destructor free;
      public
        irq_timer,linea_back,video_mode,hpos,hpos_temp:byte;
        VIDEO_VISIBLE_Y_TOTAL,VIDEO_Y_TOTAL:word;
        tms:tms99xx_chip;
        trans,is_pal:boolean;
        procedure refresh(linea:word);
        procedure reset;
        function vram_r:byte;
        function register_r:integer;
        procedure register_w(valor:byte);
        procedure vram_w(valor:byte);
        procedure video_pal(mode:byte);
        procedure video_ntsc(mode:byte);
        procedure set_hpos(estados:word);
      private
        SMS_IRQ_Handler:procedure(int:boolean);
        hint,display_disabled:boolean;
        current_pal:array[0..31] of word;
        cram:array[0..63] of byte;
        addr_mode,cram_mask,reg8tmp,reg9tmp:byte;
        line_counter,sprite_count,sprite_zoom:byte;
        sprite_x:array[0..7] of integer;
        sprite_tile_selected,sprite_pattern_line:array[0..7] of word;
        LINEAS_TOP_BORDE:byte;
        Y_PIXELS,LINEA_BORDE_DOWN:word;
        procedure select_sprites(linea:word);
        procedure draw_sprites;
        procedure draw_mode_sms(linea:word);
        procedure video_change;
    end;

var
  vdp_0,vdp_1:vdp_chip;

implementation

var
  priority_selected:array[0..255] of word;
  chips_total:integer=-1;

const
    PIXELS_VISIBLES_TOTAL=284;
    PIXELS_RIGHT_BORDER_VISIBLES=15;
    PIXELS_LEFT_BORDER_VISIBLES=13;
    PRIORITY_BIT=$1000;
    STATUS_SPROVR=$40;
    STATUS_SPRCOL=$20;

procedure vdp_chip.reset;
var
  f:byte;
begin
  self.tms.reset;
  self.tms.regs[$a]:=$ff;
  self.tms.regs[2]:=$e;
  self.cram_mask:=$1f;
  self.video_mode:=0;
  self.hpos:=0;
  self.reg8tmp:=0;
  self.reg9tmp:=0;
  self.tms.vdp_mode:=true;
  self.hint:=false;
  self.sprite_count:=0;
  self.sprite_zoom:=1;
  for f:=0 to 7 do begin
    self.sprite_x[f]:=0;
    self.sprite_tile_selected[f]:=0;
    self.sprite_pattern_line[0]:=0;
  end;
  if self.is_pal then self.video_pal(0)
    else self.video_ntsc(0);
  timers.enabled(self.irq_timer,false);
end;

destructor vdp_chip.free;
begin
chips_total:=chips_total-1;
self.tms.free;
end;

procedure irq_set(param:byte);
var
  vdp_t:vdp_chip;
begin
  case param of
    0:vdp_t:=vdp_0;
    1:vdp_t:=vdp_1;
  end;
  timers.enabled(vdp_t.irq_timer,false);
  vdp_t.tms.status_reg:=vdp_t.tms.status_reg or $80;
end;

constructor vdp_chip.create(pant:byte;irq_call:irq_type;cpu_num:byte;read_mem:read_mem_type=nil;write_mem:write_mem_type=nil;trans:boolean=false);
var
  f:byte;
  colores:tpaleta;
begin
chips_total:=chips_total+1;
for f:=0 to 63 do begin
    colores[f+16].r:=pal2bit(f and $3);
    colores[f+16].g:=pal2bit((f and $c) shr 2);
    colores[f+16].b:=pal2bit((f and $30) shr 4);
end;
set_pal(colores,64+16);
self.trans:=trans;
self.tms:=tms99xx_chip.create(pant,irq_call,read_mem,write_mem);
self.SMS_IRQ_Handler:=irq_call;
self.irq_timer:=timers.init(cpu_num,228-27,nil,irq_set,false,chips_total);
self.reset;
end;

procedure vdp_chip.select_sprites(linea:word);
var
  sprite_y,max_sprites,sprite_index:byte;
  parse_line,sprite_tile_selected,sprite_height,sprite_base:word;
  sprite_x,sprite_line:integer;
begin
	// 8x8 o 8x16
	if (self.tms.regs[1] and 2)<>0 then sprite_height:=16
    else sprite_height:=8;
	// Zoom
	if (self.tms.regs[1] and 1)<>0 then self.sprite_zoom:=2
    else self.sprite_zoom:=1;
	self.sprite_count:=0;
  max_sprites:=8;
  sprite_base:=((self.tms.regs[5] shl 7) and $3f00);
  for sprite_index:=0 to 63 do begin
      // At this point the VDP vcount still doesn't refer the new line,
      //because the logical start point is slightly shifted on the scanline
	    parse_line:=byte(linea-1);
      //--bb bbbb 0iii iii0
			sprite_y:=self.tms.read_m(sprite_base+sprite_index);
			if ((self.Y_PIXELS=192) and (sprite_y=$d0)) then break;
			if ((self.sprite_zoom>1) and (self.sprite_count<8)) then begin
        parse_line:=parse_line shr 1;
        sprite_y:=sprite_y shr 1;
      end;
      //La SMS es curiosa... Si quiere que un sprite aparezaca por arriba, lo pone en la linea
      //255, y como le resta 1 lo empieza a poner desde la 0. Tambien si lo pone por la linea
      //250, cuando llega a la linea 5 del sprite, lo pone en la linea 0 y luego sigue por la 1,2...
      //Con esto lo compenso...
      sprite_line:=parse_line-sprite_y;
      if (sprite_y>$e0) then sprite_line:=$ff+sprite_line;
			if ((sprite_line>=0) and (sprite_line<sprite_height)) then begin
				if (self.sprite_count<max_sprites) then begin
					sprite_x:=self.tms.read_m((sprite_base+$80)+(sprite_index shl 1));
					sprite_tile_selected:=self.tms.read_m((sprite_base+$81)+(sprite_index shl 1));
					if (self.tms.regs[0] and 8)<>0 then sprite_x:=sprite_x-8;
					if (self.tms.regs[6] and 4)<>0 then sprite_tile_selected:=sprite_tile_selected or $100;
					if (sprite_height=16) then sprite_tile_selected:=sprite_tile_selected and $1fe;
					if (sprite_line>7) then sprite_tile_selected:=sprite_tile_selected+1;
					self.sprite_x[self.sprite_count]:=sprite_x;
					self.sprite_tile_selected[self.sprite_count]:=sprite_tile_selected;
					self.sprite_pattern_line[self.sprite_count]:=(sprite_line and 7) shl 2;
          self.sprite_count:=self.sprite_count+1;
				end else begin
          self.tms.status_reg:=self.tms.status_reg or STATUS_SPROVR;
        end;
			end;
  end;
end;

procedure vdp_chip.draw_sprites;
var
  sprite_col_occurred:boolean;
  f,sprite_col_x,sprite_tile_selected,sprite_pattern_line:word;
  collision_buffer:array[0..255] of byte;
  sprite_buffer_index:byte;
  bit_plane_0,bit_plane_1,bit_plane_2,bit_plane_3,pixel_x:byte;
  pen_bit_0,pen_bit_1,pen_bit_2,pen_bit_3,pen_selected:byte;
  ptemp:pword;
  sprite_x,pixel_plot_x:integer;
begin
	sprite_col_occurred:=false;
	sprite_col_x:=255;
	if self.sprite_count=0 then exit;
	fillchar(collision_buffer[0],255,0);
	// Draw sprite layer
	for sprite_buffer_index:=(self.sprite_count-1) downto 0 do begin
		sprite_x:=self.sprite_x[sprite_buffer_index];
		sprite_tile_selected:=self.sprite_tile_selected[sprite_buffer_index];
		sprite_pattern_line:=self.sprite_pattern_line[sprite_buffer_index];
		bit_plane_0:=self.tms.read_m((sprite_tile_selected shl 5)+sprite_pattern_line+0);
		bit_plane_1:=self.tms.read_m((sprite_tile_selected shl 5)+sprite_pattern_line+1);
		bit_plane_2:=self.tms.read_m((sprite_tile_selected shl 5)+sprite_pattern_line+2);
		bit_plane_3:=self.tms.read_m((sprite_tile_selected shl 5)+sprite_pattern_line+3);
		for pixel_x:=0 to 7 do begin
			pen_bit_0:=(bit_plane_0 shr (7-pixel_x)) and 1;
			pen_bit_1:=(bit_plane_1 shr (7-pixel_x)) and 1;
			pen_bit_2:=(bit_plane_2 shr (7-pixel_x)) and 1;
			pen_bit_3:=(bit_plane_3 shr (7-pixel_x)) and 1;
			pen_selected:=(pen_bit_3 shl 3) or (pen_bit_2 shl 2) or (pen_bit_1 shl 1) or (pen_bit_0) or $10;
			if (pen_selected=$10) then continue;       // Transparent palette so skip draw
      if (self.sprite_zoom>1) then pixel_plot_x:=sprite_x+(pixel_x shl 1)
        else pixel_plot_x:=sprite_x+pixel_x;
      for f:=1 to self.sprite_zoom do begin
          pixel_plot_x:=pixel_plot_x+(f-1);
          if (pixel_plot_x<0) or (pixel_plot_x>255) then continue;
          //Sprite con mas prioridad
				  if ((priority_selected[pixel_plot_x] and PRIORITY_BIT)=0) then begin
              ptemp:=punbuf;
              inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
					    ptemp^:=paleta[self.current_pal[pen_selected]];
					    priority_selected[pixel_plot_x]:=pen_selected;
				  end else begin //Sprite con menos prioridad que el fondo
              //El fondo es transparente?
              //Para comprobarlo, veo que los cuatro ultimos bits (el color que he puesto cuando
              //pintaba el fondo) son 0
					    if (priority_selected[pixel_plot_x]=PRIORITY_BIT) then begin
                ptemp:=punbuf;
                inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
					      ptemp^:=paleta[self.current_pal[pen_selected]];
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
		end;
	end;
end;

function get_name_table_row(vdp:vdp_chip;row:word):word;
var
  tempw:word;
begin
  if vdp.Y_PIXELS=192 then tempw:=((row shr 3) shl 6) and (((vdp.tms.regs[2] and 1) shl 10) or $3bff)
    else tempw:=((row shr 3) shl 6);
  get_name_table_row:=tempw;
end;

procedure vdp_chip.draw_mode_sms(linea:word);
var
   y_scroll,x_scroll,x_scroll_start_column,tile_column:byte;
   scroll_mod,name_table_address:word;
   tile_line,bit_plane_0,bit_plane_1,bit_plane_2,bit_plane_3:byte;
   tile_data,tile_selected,addr_tmp,priority_select:word;
   palette_selected,flip_y,flip_x:boolean;
   pen_bit_0,pen_bit_1,pen_bit_2,pen_bit_3,pen_selected:byte;
   pixel_x,scroll_x_fine,pixel_plot_x:integer;
   ptemp:pword;
begin
ptemp:=punbuf;
inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
fillword(ptemp,8,paleta[self.current_pal[0]]);
//Las 16 primeras lineas puede que no les afecte el scroll...
if (((self.tms.regs[0] and $40)<>0) and (linea<16)) then x_scroll:=0
   else x_scroll:=self.reg8tmp;
x_scroll_start_column:=32-(x_scroll shr 3); // x starting column tile
scroll_x_fine:=x_scroll and 7;
if (self.Y_PIXELS<>192) then begin
   name_table_address:=((self.tms.regs[2] and $0c) shl 10) or $0700;
   scroll_mod:=256;
end else begin
    name_table_address:=(self.tms.regs[2] shl 10) and $3800;
    scroll_mod:=224;
end;
for tile_column:=0 to 31 do begin
    // Rightmost 8 columns for SMS (or 2 columns for GG) not affected by
    // vertical scrolling when bit 7 of reg[0x00] is set
    if (((self.tms.regs[0] and $80)<>0) and (tile_column>23)) then y_scroll:=0
       else y_scroll:=self.reg9tmp;
    tile_line:=((tile_column+x_scroll_start_column) and $1f) shl 1;
    addr_tmp:=name_table_address+get_name_table_row(self,(linea+y_scroll) mod scroll_mod)+tile_line;
    tile_data:=self.tms.read_m(addr_tmp)+(self.tms.read_m(addr_tmp+1) shl 8);
    tile_selected:=tile_data and $1ff;
    priority_select:=tile_data and PRIORITY_BIT; //Prioridad
    palette_selected:=((tile_data shr 11) and 1)<>0; //Usar la paleta de los sprites?
    flip_y:=((tile_data shr 10) and 1)<>0; //Flip vertical
    flip_x:=((tile_data shr 9) and 1)<>0; //Flip horizintal
    tile_line:=linea-((7-(y_scroll and 7))+1);
    if flip_y then tile_line:=7-tile_line;
    bit_plane_0:=self.tms.read_m(((tile_selected shl 5)+((tile_line and 7) shl 2))+0);
    bit_plane_1:=self.tms.read_m(((tile_selected shl 5)+((tile_line and 7) shl 2))+1);
    bit_plane_2:=self.tms.read_m(((tile_selected shl 5)+((tile_line and 7) shl 2))+2);
    bit_plane_3:=self.tms.read_m(((tile_selected shl 5)+((tile_line and 7) shl 2))+3);
    // Column 0 is the leftmost tile column that completely entered in the screen.
		// If the leftmost pixels aren't part of a complete tile, due to horizontal
		// scrolling, they are drawn only with color #0 of the selected palette
		{if ((tile_column=0) and (scroll_x_fine>0)) then begin
        pen_bit_1:=self.tms.read_m((($100 shl 5)+(((tile_line-1) and 7) shl 2))+1) and 8;
        for pixel_x:=0 to scroll_x_fine do begin
            ptemp:=punbuf;
            inc(ptemp,pixel_x+PIXELS_LEFT_BORDER_VISIBLES);
            if pen_bit_1<>0 then ptemp^:=paleta[self.current_pal[$10]]
               else ptemp^:=paleta[self.current_pal[0]];
            priority_selected[pixel_x]:=0;
        end;
    end;}
    for pixel_x:=0 to 7 do begin
      pen_bit_0:=(bit_plane_0 shr (7-pixel_x)) and 1;
      pen_bit_1:=(bit_plane_1 shr (7-pixel_x)) and 1;
	    pen_bit_2:=(bit_plane_2 shr (7-pixel_x)) and 1;
	    pen_bit_3:=(bit_plane_3 shr (7-pixel_x)) and 1;
	    pen_selected:=(pen_bit_3 shl 3) or (pen_bit_2 shl 2) or (pen_bit_1 shl 1) or pen_bit_0;
	    if palette_selected then pen_selected:=pen_selected or $10;
	    if not(flip_x) then pixel_plot_x:=pixel_x
        else pixel_plot_x:=7-pixel_x;
	    pixel_plot_x:=(tile_column shl 3)+pixel_plot_x+scroll_x_fine;
      if (pixel_plot_x<256) then begin
	      ptemp:=punbuf;
        inc(ptemp,pixel_plot_x+PIXELS_LEFT_BORDER_VISIBLES);
        if self.trans then begin
          if (pen_selected and $f)=$0 then ptemp^:=SET_TRANS_COLOR
            else ptemp^:=paleta[self.current_pal[pen_selected]];
        end else begin
          ptemp^:=paleta[self.current_pal[pen_selected]];
        end;
        priority_selected[pixel_plot_x]:=priority_select or (pen_selected and $f);
      end;
    end;
end;
fillword(punbuf,PIXELS_LEFT_BORDER_VISIBLES,paleta[self.current_pal[$10+self.tms.regs[7] and $f]]);
ptemp:=punbuf;
inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES+256);
fillword(ptemp,PIXELS_RIGHT_BORDER_VISIBLES,paleta[self.current_pal[$10+self.tms.regs[7] and $f]]);
end;

procedure vdp_chip.refresh(linea:word);
var
  ptemp:pword;
begin
self.display_disabled:=(self.tms.regs[1] and $40)=0;
//Arreglar la linea que devuelve...
if self.is_pal then begin
  case self.video_mode of
      0:if linea>$f2 then self.linea_back:=linea-$39
          else self.linea_back:=linea;
      1:if linea>$102 then self.linea_back:=linea-$39
          else self.linea_back:=linea and $ff;
      2:if linea>$10a then self.linea_back:=linea-$39
          else self.linea_back:=linea and $ff;
    end;
end else begin
  case self.video_mode of
      0:if linea>$da then self.linea_back:=linea-6
          else self.linea_back:=linea;
      1:if linea>$eb then self.linea_back:=linea-6
          else self.linea_back:=linea;
      2:self.linea_back:=linea and $ff;
    end;
end;
//Contador de linea, para IRQ...
if linea<=self.Y_PIXELS then begin
  if self.line_counter=0 then begin
      self.line_counter:=self.tms.regs[$a];
      self.hint:=true;
      self.tms.int:=true;
      if (self.tms.regs[0] and $10)<>0 then if @self.SMS_IRQ_Handler<>nil then self.SMS_IRQ_Handler(true);
  end else self.line_counter:=self.line_counter-1;
end else begin
  self.line_counter:=self.tms.regs[$a];
  self.reg9tmp:=self.tms.regs[9];
end;
if self.tms.vdp_mode then begin
  if linea<self.Y_PIXELS then begin //Visible
      if not(self.display_disabled) then begin
          fillword(@priority_selected[0],256,0);
          self.draw_mode_sms(linea);
          self.select_sprites(linea);
          self.draw_sprites;
          if (self.tms.regs[0] and $20)<>0 then begin
              ptemp:=punbuf;
              inc(ptemp,PIXELS_LEFT_BORDER_VISIBLES);
              fillword(ptemp,8,paleta[self.current_pal[$10+self.tms.regs[7] and $f]]);
          end;
          putpixel(0,linea+self.LINEAS_TOP_BORDE,PIXELS_VISIBLES_TOTAL,punbuf,self.tms.pant);
      end else begin
          self.select_sprites(linea);
          single_line(0,linea+self.LINEAS_TOP_BORDE,paleta[self.current_pal[$10+self.tms.regs[7] and $f]],PIXELS_VISIBLES_TOTAL,self.tms.pant);
      end;
  end else if linea=self.Y_PIXELS then begin
      single_line(0,linea+self.LINEAS_TOP_BORDE,paleta[self.current_pal[$10+self.tms.regs[7] and $f]],PIXELS_VISIBLES_TOTAL,self.tms.pant);
      //La señal de que estoy en el final del frame hay que ponerla antes que ejecute la IRQ
      //sino 'Zool' se para... Ademas la bandera no la pongo inmediatamente, si no Spiderman no funciona
      //Ademas no importa si va a ejecutar la IRQ, hay que poner la señal
      timers.enabled(self.irq_timer,true);
  end else if (linea=self.Y_PIXELS+1) then begin //borde inferior
      single_line(0,linea+self.LINEAS_TOP_BORDE,paleta[self.current_pal[$10+self.tms.regs[7] and $f]],PIXELS_VISIBLES_TOTAL,self.tms.pant);
      //OJO!! Tengo que comprobar que sigue activa la IRQ antes de lanzarla!!
      //Outrun la quita para hacer la carretera...
      if (((self.tms.regs[1] and $20)<>0) and ((self.tms.status_reg and $80)<>0)) then begin
          if @self.SMS_IRQ_Handler<>nil then self.SMS_IRQ_Handler(true);
          self.tms.int:=true;
      end;
  end else if linea<self.LINEA_BORDE_DOWN then begin //Resto borde inferior
      single_line(0,linea+self.LINEAS_TOP_BORDE,paleta[self.current_pal[$10+self.tms.regs[7] and $f]],PIXELS_VISIBLES_TOTAL,self.tms.pant);
  end else if linea>=(self.LINEA_BORDE_DOWN+19) then begin //Borde superior
      single_line(0,linea-(self.LINEA_BORDE_DOWN+19),paleta[self.current_pal[$10+self.tms.regs[7] and $f]],PIXELS_VISIBLES_TOTAL,self.tms.pant);
  end;
end else self.tms.refresh(linea);
end;

procedure vdp_chip.video_change;
var
  new_video:byte;
begin
  self.tms.vdp_mode:=(self.tms.regs[0] and 4)<>0;
  new_video:=0;
  if ((self.tms.regs[0] and 4)<>0) then begin
    self.tms.vdp_mode:=true;
    if ((self.tms.regs[0] and 2)<>0) then begin
      if (((self.tms.regs[1] and $10)<>0) and ((self.tms.regs[1] and $8)=0)) then new_video:=1;
      if (((self.tms.regs[1] and $10)=0) and ((self.tms.regs[1] and $8)<>0)) then new_video:=2;
    end;
  end else self.tms.vdp_mode:=false;
  if (self.video_mode<>new_video) then begin
    if self.is_pal then self.video_pal(new_video)
      else self.video_ntsc(new_video);
    self.video_mode:=new_video;
  end;
end;

function vdp_chip.register_r:integer;
begin
  if self.tms.vdp_mode then begin
    //'PGA Tour Golf' se cuelga si no pongo esto $1d
    register_r:=(self.tms.status_reg and $e0) or $1d;
    self.tms.status_reg:=0;
    self.hint:=false;
    if self.tms.int then begin
        if @self.SMS_IRQ_Handler<>nil then self.SMS_IRQ_Handler(false);
        self.tms.int:=false;
    end;
    self.tms.segundo_byte:=false;
  end else register_r:=self.tms.register_r;
end;

procedure vdp_chip.register_w(valor:byte);
var
  reg:byte;
begin
  if not(self.tms.segundo_byte) then begin
    self.tms.addr:=((self.tms.addr and $ff00) or valor) and $3fff;
    self.tms.segundo_byte:=true;
  end else begin
    self.addr_mode:=(valor and $c0) shr 6;
    if self.tms.vdp_mode then begin
      self.tms.segundo_byte:=false;
      self.tms.addr:=((self.tms.addr and $ff) or (valor shl 8)) and $3fff;
      case self.addr_mode of
        0:begin // VRAM reading mode
            self.tms.buffer:=self.tms.read_m(self.tms.addr);
            self.tms.addr:=(self.tms.addr+1) and $3fff;
          end;
        1,3:; // VRAM writing mode o CRAM writing mode
        2:begin // VDP register write
            reg:=valor and $f;
            self.tms.regs[reg]:=self.tms.addr and $ff;
            self.video_change;
            self.reg8tmp:=self.tms.regs[8];
            if ((reg=0) and self.hint) or ((reg=1) and ((self.tms.status_reg and $80)<>0)) then begin
               if ((reg=0) and ((self.tms.regs[0] and $10)=0)) or ((reg=1) and ((self.tms.regs[1] and $20)=0)) then begin
                  if self.tms.int then begin
                    self.tms.int:=false;
                    if @self.SMS_IRQ_Handler<>nil then self.SMS_IRQ_Handler(false);
                  end;
               end else begin
                  self.tms.int:=true;
                  if @self.SMS_IRQ_Handler<>nil then self.SMS_IRQ_Handler(true);
               end;
            end;
            self.addr_mode:=0;
          end;
      end;
    end else
      self.tms.register_w(valor);
  end;
end;

function vdp_chip.vram_r:byte;
begin
  vram_r:=self.tms.vram_r;
end;

procedure cram_write(vdp:vdp_chip;valor:byte);
var
   address:word;
begin
address:=vdp.tms.addr and vdp.cram_mask;
if (vdp.cram[address]<>valor) then begin
   vdp.CRAM[address]:=valor;
   vdp.current_pal[address]:=(vdp.cram[address] and $3f)+$10;
end;
end;

procedure vdp_chip.vram_w(valor:byte);
begin
  if self.addr_mode=3 then begin
    cram_write(self,valor);
    self.tms.buffer:=valor;
    self.tms.addr:=(self.tms.addr+1) and $3fff;
    self.tms.segundo_byte:=false;
  end else self.tms.vram_w(valor);
end;

procedure vdp_chip.video_pal(mode:byte);
begin
self.VIDEO_VISIBLE_Y_TOTAL:=294;
self.VIDEO_Y_TOTAL:=LINES_PAL;
self.is_pal:=true;
case mode of
  0:begin   //256x192
      self.Y_PIXELS:=192;
      self.LINEAS_TOP_BORDE:=54;
      self.LINEA_BORDE_DOWN:=240;
    end;
  1:begin  //256x224
      self.Y_PIXELS:=224;
      self.LINEAS_TOP_BORDE:=38;
      self.LINEA_BORDE_DOWN:=256;
    end;
  2:begin  //256x240
      self.Y_PIXELS:=240;
      self.LINEAS_TOP_BORDE:=30;
      self.LINEA_BORDE_DOWN:=264;
    end;
end;
end;

procedure vdp_chip.video_ntsc(mode:byte);
begin
self.VIDEO_VISIBLE_Y_TOTAL:=243;
self.VIDEO_Y_TOTAL:=LINES_NTSC;
self.is_pal:=false;
case mode of
  0:begin
      self.Y_PIXELS:=192;
      self.LINEAS_TOP_BORDE:=27;
      self.LINEA_BORDE_DOWN:=216;
    end;
  1:begin
      self.Y_PIXELS:=224;
      self.LINEAS_TOP_BORDE:=11;
      self.LINEA_BORDE_DOWN:=232;
    end;
  2:begin
      self.Y_PIXELS:=240;
      self.LINEAS_TOP_BORDE:=3;
      self.LINEA_BORDE_DOWN:=240;
    end;
end;
end;

procedure vdp_chip.set_hpos(estados:word);
begin
  self.hpos_temp:=hpos_conv[estados];
end;

end.
