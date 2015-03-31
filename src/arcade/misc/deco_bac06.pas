unit deco_bac06;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     gfx_engine,main_engine,pal_engine;

type
    tipo_pf_data=record
      data:array[1..3,0..$1fff] of word;
      control_0,control_1:array[1..3,0..3] of word;
      colscroll:array[1..3,0..$3f] of word;
      rowscroll:array[1..3,0..$1ff] of word;
      pos_scroll_x:array[1..3,0..$ff] of word;
      pos_scroll_y:array [1..3,0..$f] of word;
      buffer_color:array [1..3,0..$f] of boolean;
      mult:array[1..3] of byte;
      mask_x,mask_y,color_add,scroll_x,scroll_y,control,
        num_mask,long_bloque_x,long_bloque_y:array[1..3] of word;
      screen:array[1..3] of byte;
      screen_pri:array[1..3] of byte;
    end;
    ptipo_pf_data=^tipo_pf_data;

var
  sprite_ram_bac06:array[0..$7ff] of byte;
  sprite_bac06_color:word;
  bac06_pf:ptipo_pf_data;

procedure deco_bac06_init(num,scr1,scr2,scr3,scrp1,scrp2,scrp3:byte;color_add1,color_add2,color_add3,num_mask1,num_mask2,num_mask3:word;mult1,mult2,mult3:byte);
procedure deco_bac06_close(num:byte);
procedure deco_bac06_reset(num:byte);
procedure sprites_deco_bac06(pri_mask,pri_val,num_gfx,screen:byte);
procedure show_pf(tile,dest_screen:byte);
procedure show_pf_pri(tile,dest_screen:byte);
procedure update_pf(tile,gfx_num:byte;trans,pri:boolean);
procedure change_control0(tile:byte;pos,valor:word);
procedure change_control1(tile:byte;pos,valor:word);

implementation

procedure deco_bac06_init(num,scr1,scr2,scr3,scrp1,scrp2,scrp3:byte;color_add1,color_add2,color_add3,num_mask1,num_mask2,num_mask3:word;mult1,mult2,mult3:byte);
begin
  getmem(bac06_pf,sizeof(tipo_pf_data));
  bac06_pf.screen[1]:=scr1;
  bac06_pf.screen[2]:=scr2;
  bac06_pf.screen[3]:=scr3;
  bac06_pf.screen_pri[1]:=scrp1;
  bac06_pf.screen_pri[2]:=scrp2;
  bac06_pf.screen_pri[3]:=scrp3;
  bac06_pf.color_add[1]:=color_add1;
  bac06_pf.color_add[2]:=color_add2;
  bac06_pf.color_add[3]:=color_add3;
  bac06_pf.num_mask[1]:=num_mask1;
  bac06_pf.num_mask[2]:=num_mask2;
  bac06_pf.num_mask[3]:=num_mask3;
  bac06_pf.mult[1]:=mult1;
  bac06_pf.mult[2]:=mult2;
  bac06_pf.mult[3]:=mult3;
end;

procedure deco_bac06_close(num:byte);
begin
  freemem(bac06_pf);
end;

procedure deco_bac06_reset(num:byte);
begin
 fillchar(bac06_pf.data[1,0],$4000,0);
 fillchar(bac06_pf.data[2,0],$4000,0);
 fillchar(bac06_pf.data[3,0],$4000,0);
 fillchar(bac06_pf.control_0[1,0],8,0);
 fillchar(bac06_pf.control_0[2,0],8,0);
 fillchar(bac06_pf.control_0[3,0],8,0);
 fillchar(bac06_pf.control_1[1,0],8,0);
 fillchar(bac06_pf.control_1[2,0],8,0);
 fillchar(bac06_pf.control_1[3,0],8,0);
 fillchar(bac06_pf.mask_x[1],6,0);
 fillchar(bac06_pf.mask_y[1],6,0);
 fillchar(bac06_pf.scroll_x[1],6,0);
 fillchar(bac06_pf.scroll_y[1],6,0);
 fillchar(bac06_pf.long_bloque_x[1],6,0);
 fillchar(bac06_pf.long_bloque_y[1],6,0);
 fillchar(bac06_pf.control[1],6,0);
 fillchar(bac06_pf.colscroll[1,0],$80,0);
 fillchar(bac06_pf.colscroll[2,0],$80,0);
 fillchar(bac06_pf.colscroll[3,0],$80,0);
 fillchar(bac06_pf.rowscroll[1,0],$400,0);
 fillchar(bac06_pf.rowscroll[2,0],$400,0);
 fillchar(bac06_pf.rowscroll[3,0],$400,0);
 fillchar(bac06_pf.pos_scroll_x[1,0],$200,0);
 fillchar(bac06_pf.pos_scroll_x[2,0],$200,0);
 fillchar(bac06_pf.pos_scroll_x[3,0],$200,0);
 fillchar(bac06_pf.pos_scroll_y[1,0],$20,0);
 fillchar(bac06_pf.pos_scroll_y[2,0],$20,0);
 fillchar(bac06_pf.pos_scroll_y[3,0],$20,0);
end;

//Sprites
procedure sprites_deco_bac06(pri_mask,pri_val,num_gfx,screen:byte);inline;
var
  f,y,x,nchar:word;
  color:byte;
  fx,fy:boolean;
  multi,inc,mult:integer;
begin
for f:=0 to $ff do begin
		y:=buffer_sprites[(f*8)+1]+(buffer_sprites[f*8] shl 8);
		if ((y and $8000)=0) then continue;
		x:=buffer_sprites[(f*8)+5]+(buffer_sprites[f*8+4] shl 8);
		color:=x shr 12;
		if ((color and pri_mask)<>pri_val) then continue;
		if (((x and $800)<>0) and ((main_vars.frames_sec and 1)<>0)) then continue;
		fx:=(y and $2000)<>0;
		fy:=(y and $4000)<>0;
		multi:=(1 shl ((y and $1800) shr 11))-1; // 1x, 2x, 4x, 8x height */
											// multi = 0   1   3   7 */
		nchar:=buffer_sprites[(f*8)+3]+(buffer_sprites[f*8+2] shl 8) and $fff;
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
        put_gfx_sprite(nchar-multi*inc,(color shl 4)+sprite_bac06_color,fx,fy,num_gfx);
        actualiza_gfx_sprite(x,(y+mult*multi) and $1ff,screen,num_gfx);
      end;
			multi:=multi-1;
		end;
	end;
end;

//Video
procedure put_gfx_dec0(pos_x,pos_y,nchar,color:word;screen,ngfx:byte);inline;
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
      else temp^:=paleta[max_colores];
    inc(pos);
    inc(temp);
  end;
  putpixel(pos_x,pos_y+y,16,punbuf,screen);
end;
end;

procedure scroll_xy_part(porigen,pdestino:byte;size_x_pantalla,size_y_pantalla,long_bloque_x,long_bloque_y:word;posicion_x,posicion_y:pword;mask_x,mask_y:word);inline;
var
  pos_y,pos_x:word;
  temp_pos_x:pword;
  posicion_x_def,posicion_y_def:word;
  long_def_x,long_def_y:word;
begin
pos_y:=0;
while (pos_y<>size_y_pantalla) do begin
  temp_pos_x:=posicion_x;
  pos_x:=0;
  while (pos_x<>size_x_pantalla) do begin
    posicion_x_def:=(temp_pos_x^+pos_y) and mask_x;
    posicion_y_def:=(posicion_y^+pos_x) and mask_y;
    if (posicion_y_def+long_bloque_x)>mask_y then long_def_y:=mask_y-posicion_y_def
      else long_def_y:=long_bloque_x;
    if (posicion_x_def+long_bloque_y)>mask_x then long_def_x:=mask_x-posicion_x_def
      else long_def_x:=long_bloque_y;
    actualiza_trozo(posicion_x_def,posicion_y_def,long_def_x,long_def_y,porigen,pos_y,pos_x,long_def_x,long_def_y,pdestino);
    if long_def_x<long_bloque_y then actualiza_trozo(0,posicion_y_def,long_bloque_y-long_def_x,long_def_y,porigen,pos_y+long_def_x,pos_x,long_def_x-long_bloque_y,long_def_y,pdestino);
    pos_x:=pos_x+long_bloque_x;
    inc(temp_pos_x);
  end;
  inc(posicion_y);
  pos_y:=pos_y+long_bloque_y;
end;
end;

procedure update_8x8(tile,screen_num,gfx_num:byte;color_add:word;trans:boolean);inline;
var
  f,x,y,nchar,atrib,pos:word;
  color:byte;
begin
for f:=0 to $fff do begin
  case (bac06_pf.control_0[tile,3] and $3) of
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
  atrib:=bac06_pf.data[tile,pos];
  color:=(atrib shr 12);
  if (gfx[gfx_num].buffer[pos] or bac06_pf.buffer_color[tile,color]) then begin
    nchar:=atrib and bac06_pf.num_mask[tile];
    if trans then put_gfx_trans(x*8,y*8,nchar,(color shl 4)+color_add,screen_num,gfx_num)
      else put_gfx(x*8,y*8,nchar,(color shl 4)+color_add,screen_num,gfx_num);
    gfx[gfx_num].buffer[pos]:=false;
  end;
end;
fillchar(bac06_pf.buffer_color[tile,0],0,$10);
end;

procedure update_16x16(tile,screen_num,screen_num_pri,gfx_num:byte;color_add:word;trans,pri:boolean);inline;
var
  f,x,y,atrib,nchar,pos:word;
  color:byte;
begin
for f:=0 to ($3ff*bac06_pf.mult[tile]) do begin
  case (bac06_pf.control_0[tile,3] and $3) of
    0:begin
        x:=f mod (64*bac06_pf.mult[tile]);
        y:=f div (64*bac06_pf.mult[tile]);
        pos:=(x and $f)+((y and $f) shl 4)+((x and $1f0) shl 4);
      end;
    1:begin
        x:=f mod (32*bac06_pf.mult[tile]);
        y:=f div (32*bac06_pf.mult[tile]);
        pos:=(x and $f)+((y and $1f) shl 4)+((x and $f0) shl 5);
      end;
    2:begin
        x:=f mod (16*bac06_pf.mult[tile]);
        y:=f div (16*bac06_pf.mult[tile]);
        pos:=(x and $f)+((y and $3f) shl 4)+((x and $70) shl 6);
      end;
  end;
  atrib:=bac06_pf.data[tile,pos];
  color:=(atrib shr 12);
  if ((gfx[gfx_num].buffer[pos]) or (bac06_pf.buffer_color[tile,color])) then begin
    nchar:=atrib and bac06_pf.num_mask[tile];
    if trans then put_gfx_trans(x*16,y*16,nchar,(color shl 4)+color_add,screen_num,gfx_num)
      else put_gfx(x*16,y*16,nchar,(color shl 4)+color_add,screen_num,gfx_num);
    if pri then begin
      if (color and $8)=8 then put_gfx_dec0(x*16,y*16,nchar,(color shl 4)+color_add,screen_num_pri,gfx_num)
        else put_gfx_block_trans(x*16,y*16,screen_num_pri,16,16);
    end;
    gfx[gfx_num].buffer[pos]:=false;
  end;
end;
fillchar(bac06_pf.buffer_color[tile,0],0,$10);
end;

procedure update_pf(tile,gfx_num:byte;trans,pri:boolean);inline;
begin
if (bac06_pf.control_0[tile,0] and 1)=0 then begin //16x16
  update_16x16(tile,bac06_pf.screen[tile],bac06_pf.screen_pri[tile],gfx_num,bac06_pf.color_add[tile],trans,pri);
end else begin //8x8
  update_8x8(tile,bac06_pf.screen[tile],gfx_num,bac06_pf.color_add[tile],trans);
end;
end;

procedure show_pf(tile,dest_screen:byte);inline;
var
  scroll_x,scroll_y,control:word;
  f:word;
begin
scroll_x:=bac06_pf.scroll_x[tile];
scroll_y:=bac06_pf.scroll_y[tile];
control:=bac06_pf.control[tile];
if control=0 then begin
  scroll_x_y(bac06_pf.screen[tile],dest_screen,scroll_x,scroll_y);
end else begin
  if (control and $4)<>0 then for f:=0 to ((256 shr bac06_pf.control_1[tile,2])-1) do bac06_pf.pos_scroll_x[tile,f]:=scroll_x+bac06_pf.rowscroll[tile,f]
    else fillword(@bac06_pf.pos_scroll_x[tile,0],256,scroll_x);
  if (control and $8)<>0 then for f:=0 to ((16 shr bac06_pf.control_1[tile,3])-1) do bac06_pf.pos_scroll_y[tile,f]:=scroll_y+bac06_pf.colscroll[tile,f]
    else fillword(@bac06_pf.pos_scroll_y[tile,0],16,scroll_y);
  scroll_xy_part(bac06_pf.screen[tile],dest_screen,256,256,bac06_pf.long_bloque_x[tile],bac06_pf.long_bloque_y[tile],@bac06_pf.pos_scroll_x[tile,0],@bac06_pf.pos_scroll_y[tile,0],bac06_pf.mask_x[tile],bac06_pf.mask_y[tile]);
end;
end;

procedure show_pf_pri(tile,dest_screen:byte);
var
  scroll_x,scroll_y:word;
begin
scroll_x:=bac06_pf.scroll_x[tile];
scroll_y:=bac06_pf.scroll_y[tile];
if bac06_pf.control[tile]=0 then begin
  scroll_x_y(bac06_pf.screen_pri[tile],dest_screen,scroll_x,scroll_y);
end else begin
  scroll_xy_part(bac06_pf.screen_pri[tile],dest_screen,256,256,bac06_pf.long_bloque_x[tile],bac06_pf.long_bloque_y[tile],@bac06_pf.pos_scroll_x[tile,0],@bac06_pf.pos_scroll_y[tile,0],bac06_pf.mask_x[tile],bac06_pf.mask_y[tile]);
end;
end;

procedure change_control0(tile:byte;pos,valor:word);
var
  tempw:word;
begin
bac06_pf.control_0[tile,pos]:=valor;
if pos=3 then begin
  case (bac06_pf.control_0[tile,3] and $3) of
    0:begin
        tempw:=1024*bac06_pf.mult[tile];
        screen_mod_scroll(bac06_pf.screen[tile],tempw,256,tempw-1,256,256,255);
        screen_mod_scroll(bac06_pf.screen_pri[tile],tempw,256,tempw-1,256,256,255);
        bac06_pf.mask_x[tile]:=tempw-1;
        bac06_pf.mask_y[tile]:=$ff;
      end;
    1:begin
        tempw:=512*bac06_pf.mult[tile];
        screen_mod_scroll(bac06_pf.screen[tile],tempw,256,tempw-1,512,256,511);
        screen_mod_scroll(bac06_pf.screen_pri[tile],tempw,256,tempw-1,512,256,511);
        bac06_pf.mask_x[tile]:=tempw-1;
        bac06_pf.mask_y[tile]:=$1ff;
      end;
    2:begin
        tempw:=256*bac06_pf.mult[tile];
        screen_mod_scroll(bac06_pf.screen[tile],tempw,256,tempw-1,1024,256,1023);
        screen_mod_scroll(bac06_pf.screen_pri[tile],tempw,256,tempw-1,1024,256,1023);
        bac06_pf.mask_x[tile]:=tempw-1;
        bac06_pf.mask_y[tile]:=$3ff;
      end;
  end;
end;
bac06_pf.control[tile]:=bac06_pf.control_0[tile,0] and $c;
end;

procedure change_control1(tile:byte;pos,valor:word);
begin
bac06_pf.control_1[tile,pos]:=valor;
case pos of
  0:bac06_pf.scroll_x[tile]:=valor;
  1:bac06_pf.scroll_y[tile]:=valor;
  2:bac06_pf.long_bloque_x[tile]:=1 shl valor;
  3:bac06_pf.long_bloque_y[tile]:=16 shl valor;
end;
end;

end.
