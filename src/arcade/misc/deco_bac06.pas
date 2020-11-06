unit deco_bac06;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     gfx_engine,main_engine,pal_engine;

type
  tyle_chip=class
          constructor create(screen,screen_pri:byte;color_add,num_mask:word;mult:byte);
          destructor free;
          public
            data:array[0..$1fff] of word;
            control_0,control_1:array[0..3] of word;
            colscroll:array[0..$3f] of word;
            rowscroll:array[0..$1ff] of word;
            buffer_color:array[0..$f] of boolean;
            procedure reset;
            procedure update_pf(gfx_num:byte;trans,pri:boolean);
            procedure show_pf;
            procedure show_pf_pri;
            procedure change_control0(pos,valor:word);
            procedure change_control1(pos,valor:word);
          private
            pos_scroll_x:array[0..$ff] of word;
            pos_scroll_y:array[0..$f] of word;
            mult,screen,screen_pri:byte;
            mask_x,mask_y,color_add,scroll_x,scroll_y,control,num_mask,long_bloque_x,long_bloque_y:word;
            procedure update_16x16(gfx_num:byte;trans,pri:boolean);
            procedure update_8x8(gfx_num:byte;trans:boolean);
        end;
  bac06_chip=class
          constructor create(pri1,pri2,pri3:boolean;color_add1,color_add2,color_add3,num_mask1,num_mask2,num_mask3:word;mult1,mult2,mult3:byte;sprite_color:word);
          destructor free;
          public
            tile_1,tile_2,tile_3:tyle_chip;
            procedure reset;
            procedure draw_sprites(pri_mask,pri_val,num_gfx:byte);
            procedure update_sprite_data(data:pbyte);
          private
            sprite_color:word;
            sprite_ram:array[0..$3ff] of word;
        end;

var
  bac06_0:bac06_chip;

implementation

constructor tyle_chip.create(screen,screen_pri:byte;color_add,num_mask:word;mult:byte);
begin
  self.screen:=screen;
  self.screen_pri:=screen_pri;
  self.color_add:=color_add;
  self.num_mask:=num_mask;
  self.mult:=mult;
end;

destructor tyle_chip.free;
begin
end;

procedure tyle_chip.reset;
begin
 fillchar(self.data[0],$2000*2,0);
 fillchar(self.control_0[0],4*2,0);
 fillchar(self.control_1[0],4*2,0);
 self.mask_x:=0;
 self.mask_y:=0;
 self.scroll_x:=0;
 self.scroll_y:=0;
 self.long_bloque_x:=0;
 self.long_bloque_y:=0;
 self.control:=0;
 fillchar(self.colscroll[0],$40*2,0);
 fillchar(self.rowscroll[0],$200*2,0);
 fillchar(self.pos_scroll_x[0],$100*2,0);
 fillchar(self.pos_scroll_y[0],$10*2,0);
end;

constructor bac06_chip.create(pri1,pri2,pri3:boolean;color_add1,color_add2,color_add3,num_mask1,num_mask2,num_mask3:word;mult1,mult2,mult3:byte;sprite_color:word);
var
  sc_pri1,sc_pri2,sc_pri3:byte;
begin
  if mult1<>0 then screen_init(1,1024*mult1,1024,true);
  if mult2<>0 then screen_init(2,1024*mult2,1024,true);
  if mult3<>0 then screen_init(3,1024*mult3,1024,true);
  sc_pri1:=4;
  sc_pri2:=5;
  sc_pri3:=6;
  if pri1 then screen_init(4,1024,1024,true)
    else sc_pri1:=1;
  if pri2 then screen_init(5,1024,1024,true)
    else sc_pri2:=2;
  if pri3 then screen_init(6,1024,1024,true)
    else sc_pri3:=3;
  screen_init(7,512,512,false,true);
  self.tile_1:=tyle_chip.create(1,sc_pri1,color_add1,num_mask1,mult1);
  self.tile_2:=tyle_chip.create(2,sc_pri2,color_add2,num_mask2,mult2);
  self.tile_3:=tyle_chip.create(3,sc_pri3,color_add3,num_mask3,mult3);
  self.sprite_color:=sprite_color;
  iniciar_video(256,240);
end;

destructor bac06_chip.free;
begin
  self.tile_1.free;
  self.tile_2.free;
  self.tile_3.free;
end;

procedure bac06_chip.reset;
begin
 self.tile_1.reset;
 self.tile_2.reset;
 self.tile_3.reset;
 fillchar(self.sprite_ram,$400*2,0);
end;

//Sprites
procedure bac06_chip.draw_sprites(pri_mask,pri_val,num_gfx:byte);
var
  f,y,x,nchar:word;
  color:byte;
  fx,fy:boolean;
  multi,inc,mult:integer;
begin
for f:=0 to $ff do begin
		y:=self.sprite_ram[f*4];
		if ((y and $8000)=0) then continue;
		x:=self.sprite_ram[(f*4)+2];
		color:=x shr 12;
		if ((color and pri_mask)<>pri_val) then continue;
		if (((x and $800)<>0) and ((main_vars.frames_sec and 1)<>0)) then continue;
		fx:=(y and $2000)<>0;
		fy:=(y and $4000)<>0;
		multi:=(1 shl ((y and $1800) shr 11))-1; // 1x, 2x, 4x, 8x height */
											                       // multi = 0   1   3   7 */
		nchar:=self.sprite_ram[(f*4)+1] and $fff;
		x:=(240-x) and $1ff;
  	y:=(240-y) and $1ff;
		nchar:=nchar and not(multi);
		if fy then inc:=-1
  		else begin
  			nchar:=nchar+multi;
	  		inc:=1;
		  end;
    mult:=-16;
		while (multi>=0) do begin
      if nchar<>0 then begin
        put_gfx_sprite(nchar-multi*inc,(color shl 4)+sprite_color,fx,fy,num_gfx);
        actualiza_gfx_sprite(x,(y+mult*multi) and $1ff,7,num_gfx);
      end;
			multi:=multi-1;
		end;
	end;
end;

procedure bac06_chip.update_sprite_data(data:pbyte);
begin
  copymemory(@self.sprite_ram,data,$400*2);
end;

//Video
procedure put_gfx_dec0(pos_x,pos_y,nchar,color:word;screen,ngfx:byte);
var
  x,y:byte;
  temp:pword;
  pos:pbyte;
  punto:word;
begin
pos:=gfx[ngfx].datos;
inc(pos,nchar*16*16);
for y:=0 to 15 do begin
  temp:=punbuf;
  for x:=0 to 15 do begin
    punto:=gfx[ngfx].colores[pos^+color];
    if (punto and $8)=$8 then temp^:=paleta[punto]
      else temp^:=paleta[MAX_COLORES];
    inc(pos);
    inc(temp);
  end;
  putpixel(pos_x,pos_y+y,16,punbuf,screen);
end;
end;

procedure tyle_chip.update_8x8(gfx_num:byte;trans:boolean);
var
  f,x,y,nchar,atrib,pos:word;
  color:byte;
begin
for f:=0 to $fff do begin
  case (self.control_0[3] and $3) of
    0:begin
        x:=f mod 128;
        y:=f div 128;
        pos:=(x and $1f)+((y and $1f) shl 5)+((x and $60) shl 5);
      end;
    1:begin
        x:=f mod 64;
        y:=f div 64;
        pos:=(x and $1f)+((y and $1f) shl 5)+((y and $20) shl 5)+((x and $20) shl 6);
      end;
    2:begin
        x:=f mod 32;
        y:=f div 32;
        pos:=(x and $1f)+((y and $7f) shl 5);
      end;
  end;
  atrib:=self.data[pos];
  color:=(atrib shr 12);
  if (gfx[gfx_num].buffer[pos] or self.buffer_color[color]) then begin
    nchar:=atrib and self.num_mask;
    if trans then put_gfx_trans(x*8,y*8,nchar,(color shl 4)+self.color_add,self.screen,gfx_num)
      else put_gfx(x*8,y*8,nchar,(color shl 4)+self.color_add,self.screen,gfx_num);
    gfx[gfx_num].buffer[pos]:=false;
  end;
end;
fillchar(self.buffer_color[0],$10,0);
end;

procedure tyle_chip.update_16x16(gfx_num:byte;trans,pri:boolean);
var
  f,x,y,atrib,nchar,pos:word;
  color:byte;
begin
for f:=0 to ($3ff*self.mult) do begin
  case (self.control_0[3] and $3) of
    0:begin
        x:=f mod (64*self.mult);
        y:=f div (64*self.mult);
        pos:=(x and $f)+((y and $f) shl 4)+((x and $1f0) shl 4);
      end;
    1:begin
        x:=f mod (32*self.mult);
        y:=f div (32*self.mult);
        pos:=(x and $f)+((y and $1f) shl 4)+((x and $f0) shl 5);
      end;
    2:begin
        x:=f mod (16*self.mult);
        y:=f div (16*self.mult);
        pos:=(x and $f)+((y and $3f) shl 4)+((x and $70) shl 6);
      end;
  end;
  atrib:=self.data[pos];
  color:=(atrib shr 12);
  if ((gfx[gfx_num].buffer[pos]) or (self.buffer_color[color])) then begin
    nchar:=atrib and self.num_mask;
    if trans then put_gfx_trans(x*16,y*16,nchar,(color shl 4)+self.color_add,self.screen,gfx_num)
      else put_gfx(x*16,y*16,nchar,(color shl 4)+color_add,self.screen,gfx_num);
    if pri then begin
      if (color and $8)=8 then put_gfx_dec0(x*16,y*16,nchar,(color shl 4)+self.color_add,self.screen_pri,gfx_num)
        else put_gfx_block_trans(x*16,y*16,self.screen_pri,16,16);
    end;
    gfx[gfx_num].buffer[pos]:=false;
  end;
end;
fillchar(self.buffer_color[0],$10,0);
end;

procedure tyle_chip.update_pf(gfx_num:byte;trans,pri:boolean);
begin
if (self.control_0[0] and 1)=0 then self.update_16x16(gfx_num,trans,pri)
  else self.update_8x8(gfx_num,trans);
end;

procedure tyle_chip.show_pf;
begin
if self.control=0 then begin
  scroll_x_y(self.screen,7,self.scroll_x,self.scroll_y);
end else begin
  if (self.control and $4)<>0 then copymemory(@self.pos_scroll_x,@self.rowscroll,$100*2)
    else fillchar(self.pos_scroll_x,$100*2,0);
  if (self.control and $8)<>0 then copymemory(@self.pos_scroll_y,@self.colscroll,$10*2)
    else fillchar(self.pos_scroll_y,$10*2,0);
  scroll_xy_part(self.screen,7,self.long_bloque_x,self.long_bloque_y,@self.pos_scroll_x[0],@self.pos_scroll_y[0],self.scroll_x,self.scroll_y);
end;
end;

procedure tyle_chip.show_pf_pri;
begin
if self.control=0 then scroll_x_y(self.screen_pri,7,self.scroll_x,self.scroll_y)
  else scroll_xy_part(self.screen_pri,7,self.long_bloque_x,self.long_bloque_y,@self.pos_scroll_x[0],@self.pos_scroll_y[0],self.scroll_x,self.scroll_y);
end;

procedure tyle_chip.change_control0(pos,valor:word);
var
  tempw:word;
begin
self.control_0[pos]:=valor;
if pos=3 then begin
  case (self.control_0[3] and $3) of
    0:begin
        tempw:=1024*self.mult;
        screen_mod_scroll(self.screen,tempw,256,tempw-1,256,256,255);
        screen_mod_scroll(self.screen_pri,tempw,256,tempw-1,256,256,255);
        self.mask_x:=tempw-1;
        self.mask_y:=$ff;
      end;
    1:begin
        tempw:=512*self.mult;
        screen_mod_scroll(self.screen,tempw,256,tempw-1,512,256,511);
        screen_mod_scroll(self.screen_pri,tempw,256,tempw-1,512,256,511);
        self.mask_x:=tempw-1;
        self.mask_y:=$1ff;
      end;
    2:begin
        tempw:=256*self.mult;
        screen_mod_scroll(self.screen,tempw,256,tempw-1,1024,256,1023);
        screen_mod_scroll(self.screen_pri,tempw,256,tempw-1,1024,256,1023);
        self.mask_x:=tempw-1;
        self.mask_y:=$3ff;
      end;
  end;
end;
self.control:=self.control_0[0] and $c;
end;

procedure tyle_chip.change_control1(pos,valor:word);
begin
self.control_1[pos]:=valor;
case pos of
  0:self.scroll_x:=valor;
  1:self.scroll_y:=valor;
  2:self.long_bloque_x:=1 shl valor;
  3:self.long_bloque_y:=16 shl valor;
end;
end;

end.
