unit gfx_engine;
{$ifdef fpc}{$ifdef CPU386}{$asmmode intel}{$endif}{$endif}

interface
uses main_engine,pal_engine;

const
  MAX_GFX=8;
  ADD_SPRITE=64;
  MAX_COLOR_BUFFER=$200;
type
  gfx_tipo=record
    x,y:byte;
    datos:pbyte;
    colores:array[0..MAX_COLORES-1] of word;
    trans:array[0..$ff] of boolean;
    shadow:array[0..$1f] of boolean;
    alpha:array[0..$1f] of boolean;
    trans_alt:array[0..4,0..$1f] of boolean;
    buffer:array[0..$7fff] of boolean;
    elements:dword;
  end;
  pgfx=^gfx_tipo;
var
  gfx:array[0..MAX_GFX-1] of gfx_tipo;
  buffer_sprites:array[0..$1fff] of byte;
  buffer_sprites_w:array[0..$fff] of word;

//GFX
procedure init_gfx(num,x_size,y_size:byte;num_elements:dword);
procedure convert_gfx(num_gfx:byte;increment:dword;SpriteRom:pbyte;cx,cy:pdword;rot90,rol90:boolean;invert:boolean=false);
procedure convert_gfx_single(num_gfx:byte;increment:dword;SpriteRom:pbyte;cx,cy:pdword;rot90,rol90:boolean;n:dword);
procedure gfx_set_desc_data(bits_pixel,banks:byte;size,p0:dword;p1:dword=0;p2:dword=0;p3:dword=0;p4:dword=0;p5:dword=0;p6:dword=0;p7:dword=0);
//GFX put
procedure put_gfx(pos_x,pos_y,nchar,color:word;screen,ngfx:byte);
procedure put_gfx_mask(pos_x,pos_y,nchar,color:word;screen,ngfx,trans,mask:word);
procedure put_gfx_mask_flip(pos_x,pos_y,nchar,color:word;screen,ngfx,trans,mask:byte;flipx,flipy:boolean);
procedure put_gfx_trans(pos_x,pos_y,nchar,color:word;screen,ngfx:byte);
procedure put_gfx_trans_alt(pos_x,pos_y,nchar,color:word;screen,ngfx,index:byte);
procedure put_gfx_block_trans(pos_x,pos_y:word;screen,size_x,size_y:byte);
procedure put_gfx_block(pos_x,pos_y:word;screen,size_x,size_y:byte;color:word);
procedure put_gfx_flip(pos_x,pos_y,nchar,color:word;screen,ngfx:byte;flipx,flipy:boolean);
procedure put_gfx_trans_flip(pos_x,pos_y,nchar:dword;color:word;screen,ngfx:byte;flipx,flipy:boolean);
procedure put_gfx_trans_flip_alt(pos_x,pos_y,nchar:dword;color:word;screen,ngfx:byte;flipx,flipy:boolean;trans_index:byte);
//Sprites put
procedure put_gfx_sprite(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte);
procedure put_gfx_sprite_diff(nchar,color:word;flipx,flipy:boolean;ngfx:byte;x_diff,y_diff:word);
procedure put_gfx_sprite_mask(nchar,color:word;flipx,flipy:boolean;ngfx:byte;trans,mask:word);
procedure put_gfx_sprite_mask_diff(nchar,color:word;flipx,flipy:boolean;ngfx,trans,mask,x_diff,y_diff:byte);
procedure put_gfx_sprite_zoom(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;zx,zy:single);
procedure put_gfx_sprite_shadow(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;shadow_color:word);
procedure put_gfx_sprite_zoom_alpha(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;zx,zy:single);
procedure put_gfx_sprite_alpha(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte);
//Sprites Update
procedure actualiza_gfx_sprite(pos_x,pos_y:word;dest,ngfx:byte);
procedure actualiza_gfx_sprite_line(pos_x,pos_y:word;dest,ngfx,line:byte);
procedure actualiza_gfx_sprite_size(pos_x,pos_y:word;dest:byte;x_size,y_size:word;ipos_x:word=0;ipos_y:word=0);
procedure actualiza_gfx_sprite_zoom(pos_x,pos_y:word;dest,ngfx:byte;zx,zy:single);
procedure actualiza_gfx_sprite_alpha(pos_x,pos_y:word;dest,ngfx:byte);
procedure actualiza_gfx_sprite_zoom_alpha(pos_x,pos_y:word;dest,ngfx:byte;zx,zy:single);
//Scroll
procedure scroll_x_y(porigen,pdestino:byte;scroll_x,scroll_y:word;diff_x:word=0;diff_y:word=0;adj_x:word=0;adj_y:word=0);
procedure scroll__x(porigen,pdestino:byte;scroll_x:word);
procedure scroll_x_cut(porigen,pdestino:byte;scroll_x,pos_y,size_y:word);
procedure scroll__x_part2(porigen,pdestino:byte;long_bloque_y:word;posicion_x:pword;scroll_x:word=0;scroll_y:word=0);
procedure scroll__y(porigen,pdestino:byte;scroll_y:word);
procedure scroll__y_part2(porigen,pdestino:byte;long_bloque_x:word;posicion_y:pword;scroll_x:word=0;scroll_y:word=0);
procedure scroll_xy_part(porigen,pdestino:byte;posicion_x,posicion_y:pword;scroll_x,scroll_y:word;row_shift,col_shift:byte);
//Basic draw functions
procedure putpixel(x,y:word;cantidad:dword;pixel:pword;sitio:byte);
function getpixel(x,y:word;sitio:byte):word;
procedure putpixel_alpha(x,y:word;cantidad:dword;pixel:pdword;sitio:byte);
procedure single_line(x,y,color,longitud:word;pant:byte);
procedure draw_line(x0,y0,x1,y1:integer;color:word;pant:byte);
//Screen functions
procedure fill_full_screen(screen:byte;color:word);
procedure putpixel_gfx_int(x,y,cantidad:word;sitio:byte);
//Misc
procedure fillword(dest:pword;cantidad:cardinal;valor:word);
procedure reset_gfx;

implementation
uses spectrum_misc,lib_sdl2;

function zoom_extent(size:byte;zoom:single):word;
var
  scaled:single;
  rounded:integer;
begin
  scaled:=size*zoom;
  rounded:=trunc(scaled);
  if scaled>rounded then inc(rounded);
  zoom_extent:=rounded;
end;

procedure blit_wrapped_block(porigen,pdestino:byte;sx,sy,block_w,block_h,dx,dy:word);
var
  source_w,source_h,w1,w2,h1,h2:word;
begin
  source_w:=p_final[porigen].x;
  source_h:=p_final[porigen].y;
  if (source_w=0) or (source_h=0) or (block_w=0) or (block_h=0) or (dx>=scroll_final_x) or (dy>=scroll_final_y) then exit;
  if block_w>scroll_final_x-dx then block_w:=scroll_final_x-dx;
  if block_h>scroll_final_y-dy then block_h:=scroll_final_y-dy;
  sx:=sx mod source_w;
  sy:=sy mod source_h;
  w1:=block_w;
  if w1>source_w-sx then w1:=source_w-sx;
  w2:=block_w-w1;
  h1:=block_h;
  if h1>source_h-sy then h1:=source_h-sy;
  h2:=block_h-h1;
  if (w1>0) and (h1>0) then
    actualiza_trozo(sx,sy,w1,h1,porigen,dx,dy,w1,h1,pdestino);
  if (w2>0) and (h1>0) then
    actualiza_trozo(0,sy,w2,h1,porigen,dx+w1,dy,w2,h1,pdestino);
  if (w1>0) and (h2>0) then
    actualiza_trozo(sx,0,w1,h2,porigen,dx,dy+h1,w1,h2,pdestino);
  if (w2>0) and (h2>0) then
    actualiza_trozo(0,0,w2,h2,porigen,dx+w1,dy+h1,w2,h2,pdestino);
end;

//GFX
procedure gfx_set_desc_data(bits_pixel,banks:byte;size,p0:dword;p1:dword=0;p2:dword=0;p3:dword=0;p4:dword=0;p5:dword=0;p6:dword=0;p7:dword=0);
begin
  des_gfx.pos_planos[0]:=p0;
  des_gfx.pos_planos[1]:=p1;
  des_gfx.pos_planos[2]:=p2;
  des_gfx.pos_planos[3]:=p3;
  des_gfx.pos_planos[4]:=p4;
  des_gfx.pos_planos[5]:=p5;
  des_gfx.pos_planos[6]:=p6;
  des_gfx.pos_planos[7]:=p7;
  des_gfx.bit_pixel:=bits_pixel;
  des_gfx.long_sprites:=size;
  des_gfx.banks:=banks;
end;

procedure init_gfx(num,x_size,y_size:byte;num_elements:dword);
var
  f:word;
begin
  gfx[num].x:=x_size;
  gfx[num].y:=y_size;
  gfx[num].elements:=num_elements;
  fillchar(gfx[num].buffer,$8000,1);
  fillchar(gfx[num].trans[0],$20,0);
  fillchar(gfx[num].shadow[0],$20,0);
  fillchar(gfx[num].alpha[0],$20,0);
  for f:=0 to 4 do fillchar(gfx[num].trans_alt[f],$20,0);
  for f:=0 to MAX_COLORES-1 do gfx[num].colores[f]:=f;
  getmem(gfx[num].datos,num_elements*x_size*y_size);
end;

function GetBit(bit_nbr:dword;buffer:pbyte):byte;
var
  oct_nbr:dword;
  bit_n:byte;
begin
oct_nbr:=bit_nbr shr 3;
bit_n:=bit_nbr and 7;
getbit:=(buffer[oct_nbr] shr (7-bit_n)) and 1;
end;

procedure Rotatel(n:dword;ngfx:pgfx;increment:dword);
var
  y,cojo_la_x:byte;
  src,t:array[0..((ADD_SPRITE*ADD_SPRITE)-1)] of byte;
  pos:pbyte;
  long,x:word;
begin
long:=ngfx.x*ngfx.y;
pos:=ngfx.datos;
inc(pos,long*n+increment);
copymemory(@src[0],pos,long);
x:=0;
for cojo_la_x:=(ngfx.x-1) downto 0 do
  for y:=0 to (ngfx.y-1) do begin
    t[x]:=src[cojo_la_x+(ngfx.x*y)];
    x:=x+1;
  end;
copymemory(pos,@t[0],long);
end;

procedure Rotater(n:dword;ngfx:pgfx;increment:dword);
var
  cojo_la_y,y_final:byte;
  src,t:array[0..((ADD_SPRITE*ADD_SPRITE)-1)] of byte;
  pos:pbyte;
  long,x:word;
begin
long:=ngfx.x*ngfx.y;
pos:=ngfx.datos;
inc(pos,long*n+increment);
copymemory(@src[0],pos,long);
x:=0;
for y_final:=0 to (ngfx.x-1) do
  for cojo_la_y:=(ngfx.y-1) downto 0 do begin
    t[x]:=src[(cojo_la_y*ngfx.x)+y_final];
    x:=x+1;
  end;
copymemory(pos,@t[0],long);
end;

procedure convert_gfx(num_gfx:byte;increment:dword;SpriteRom:pbyte;cx,cy:pdword;rot90,rol90:boolean;invert:boolean=false);
var
  n,elements:dword;
  oct,b0,o,i,bit_pixel:byte;
  SpriteNbr,ind:dword;
  temp_cx,temp_cy:pdword;
  ngfx:pgfx;
  change_again:boolean;
begin
ngfx:=@gfx[num_gfx];
change_again:=false;
if ((rot90 or rol90) and (increment<>0)) then begin
  b0:=ngfx.x;
  ngfx.x:=ngfx.y;
  ngfx.y:=b0;
  change_again:=true;
end;
ind:=0;
temp_cx:=cx;
temp_cy:=cy;
if des_gfx.banks<>0 then elements:=(ngfx.elements div des_gfx.banks)-1
  else elements:=ngfx.elements-1;
for n:=0 to elements do begin
	SpriteNbr:=n*des_gfx.long_sprites;
  cy:=temp_cy;
	for o:=0 to (ngfx.y-1) do begin
    cx:=temp_cx;
		for i:=0 to (ngfx.x-1) do begin
     oct:=0;
     for bit_pixel:=0 to (des_gfx.bit_pixel-1) do begin
      b0:=GetBit(des_gfx.pos_planos[bit_pixel]+Cy^+Cx^+SpriteNbr,SpriteRom);
      if invert then b0:=not(b0) and 1;
      oct:=oct or (b0 shl (des_gfx.bit_pixel-1-bit_pixel));
     end;
     ngfx.datos[ind+increment]:=oct;
     ind:=ind+1;
     inc(cx);
    end;  //del i
    inc(cy);
  end; //del o
	if rot90 then Rotater(n,ngfx,increment);
  if rol90 then Rotatel(n,ngfx,increment);
end;
  if (((rot90 or rol90) and (increment=0)) or change_again) then begin
      b0:=ngfx.x;
      ngfx.x:=ngfx.y;
      ngfx.y:=b0;
  end;
end;

procedure convert_gfx_single(num_gfx:byte;increment:dword;SpriteRom:pbyte;cx,cy:pdword;rot90,rol90:boolean;n:dword);
var
  oct,b0,o,i,bit_pixel:byte;
  SpriteNbr,ind:dword;
  temp_cx:pdword;
  ngfx:pgfx;
begin
ngfx:=@gfx[num_gfx];
ind:=n*ngfx.y*ngfx.x;
temp_cx:=cx;
SpriteNbr:=n*des_gfx.long_sprites;
for o:=0 to (ngfx.y-1) do begin
    cx:=temp_cx;
		for i:=0 to (ngfx.x-1) do begin
        oct:=0;
        for bit_pixel:=0 to (des_gfx.bit_pixel-1) do begin
            b0:=GetBit(des_gfx.pos_planos[bit_pixel]+Cy^+Cx^+SpriteNbr,SpriteRom);
            oct:=oct or (b0 shl (des_gfx.bit_pixel-1-bit_pixel));
        end;
        ngfx.datos[ind+increment]:=oct;
        ind:=ind+1;
        inc(cx);
    end;  //del i
    inc(cy);
end; //del o
if rot90 then Rotater(n,ngfx,increment);
if rol90 then Rotatel(n,ngfx,increment);
end;

//Scroll functions
procedure scroll_x_y(porigen,pdestino:byte;scroll_x,scroll_y:word;diff_x:word=0;diff_y:word=0;adj_x:word=0;adj_y:word=0);
var
  long_x,long_y,long_x2,long_y2:word;
begin
scroll_x:=scroll_x and p_final[porigen].mask_x;
scroll_y:=scroll_y and p_final[porigen].mask_y;
if ((scroll_x+scroll_final_x)>p_final[porigen].x) then long_x:=scroll_final_x-((scroll_x+scroll_final_x)-p_final[porigen].x)
  else long_x:=scroll_final_x;
if ((scroll_y+scroll_final_y)>p_final[porigen].y) then long_y:=scroll_final_y-((scroll_y+scroll_final_y)-p_final[porigen].y)
  else long_y:=scroll_final_y;
long_x2:=scroll_final_x-long_x;
long_y2:=scroll_final_y-long_y;
actualiza_trozo(scroll_x,scroll_y,long_x,long_y,porigen,diff_x,diff_y,long_x,long_y,pdestino);
if long_x<scroll_final_x then actualiza_trozo(adj_x,scroll_y,long_x2,long_y,porigen,long_x+diff_x,diff_y,long_x2,long_y,pdestino);
if long_y<scroll_final_y then actualiza_trozo(scroll_x,adj_y,long_x,long_y2,porigen,diff_x,long_y+diff_y,long_x,long_y2,pdestino);
if ((long_x<scroll_final_x) and (long_y<scroll_final_y)) then
  actualiza_trozo(adj_x,adj_y,long_x2,long_y2,porigen,long_x+diff_x,long_y+diff_y,long_x2,long_y2,pdestino);
end;

procedure scroll_x_cut(porigen,pdestino:byte;scroll_x,pos_y,size_y:word);
var
  long_x,long_x2:word;
begin
scroll_x:=scroll_x and p_final[porigen].mask_x;
if ((scroll_x+scroll_final_x)>p_final[porigen].x) then begin
  long_x:=p_final[porigen].x-scroll_x;
  long_x2:=scroll_final_x-long_x;
  actualiza_trozo(0,pos_y,long_x2,size_y,porigen,long_x,pos_y,long_x2,size_y,pdestino);
end else begin
  long_x:=scroll_final_x;
end;
actualiza_trozo(scroll_x,pos_y,long_x,size_y,porigen,0,pos_y,long_x,size_y,pdestino);
end;

procedure scroll__x(porigen,pdestino:byte;scroll_x:word);
var
  long_x,long_x2,long_y:word;
begin
long_y:=p_final[porigen].y;
scroll_x:=scroll_x and p_final[porigen].mask_x;
if ((scroll_x+scroll_final_x)>p_final[porigen].x) then begin
  long_x:=p_final[porigen].x-scroll_x;
  long_x2:=scroll_final_x-long_x;
  actualiza_trozo(0,0,long_x2,long_y,porigen,long_x,0,long_x2,long_y,pdestino);
end else begin
  long_x:=scroll_final_x;
end;
actualiza_trozo(scroll_x,0,long_x,long_y,porigen,0,0,long_x,long_y,pdestino);
end;

procedure scroll__y(porigen,pdestino:byte;scroll_y:word);
var
  long_x,long_y,long_y2:word;
begin
long_x:=scroll_final_x;
scroll_y:=scroll_y and p_final[porigen].mask_y;
if ((scroll_y+scroll_final_y)>p_final[porigen].y) then begin
  long_y:=p_final[porigen].y-scroll_y;
  long_y2:=scroll_final_y-long_y;
  actualiza_trozo(0,0,long_x,long_y2,porigen,0,long_y,long_x,long_y2,pdestino);
end else begin
    long_y:=scroll_final_y;
end;
actualiza_trozo(0,scroll_y,long_x,long_y,porigen,0,0,long_x,long_y,pdestino);
end;

procedure scroll__x_part2(porigen,pdestino:byte;long_bloque_y:word;posicion_x:pword;scroll_x:word=0;scroll_y:word=0);
var
  pos_y,posicion_x_def,posicion_y_def,size_of_y:word;
  temp_pos_x:pword;
begin
if (long_bloque_y=0) or (p_final[porigen].x=0) or (p_final[porigen].y=0) then exit;
temp_pos_x:=posicion_x;
pos_y:=0;
while (pos_y<scroll_final_y) do begin
    posicion_x_def:=(temp_pos_x^+scroll_x) and p_final[porigen].mask_x;
    posicion_y_def:=(pos_y+scroll_y) and p_final[porigen].mask_y;
    size_of_y:=long_bloque_y;
    if size_of_y>scroll_final_y-pos_y then size_of_y:=scroll_final_y-pos_y;
    blit_wrapped_block(porigen,pdestino,posicion_x_def,posicion_y_def,scroll_final_x,size_of_y,0,pos_y);
    pos_y:=pos_y+long_bloque_y;
    inc(temp_pos_x);
end;
end;

procedure scroll__y_part2(porigen,pdestino:byte;long_bloque_x:word;posicion_y:pword;scroll_x:word=0;scroll_y:word=0);
var
  pos_x,posicion_x_def,posicion_y_def,size_of_x:word;
  temp_pos_y:pword;
begin
if (long_bloque_x=0) or (p_final[porigen].x=0) or (p_final[porigen].y=0) then exit;
temp_pos_y:=posicion_y;
pos_x:=0;
while (pos_x<scroll_final_x) do begin
    posicion_y_def:=(temp_pos_y^+scroll_y) and p_final[porigen].mask_y;
    posicion_x_def:=(pos_x+scroll_x) and p_final[porigen].mask_x;
    size_of_x:=long_bloque_x;
    if size_of_x>scroll_final_x-pos_x then size_of_x:=scroll_final_x-pos_x;
    blit_wrapped_block(porigen,pdestino,posicion_x_def,posicion_y_def,size_of_x,scroll_final_y,pos_x,0);
    pos_x:=pos_x+long_bloque_x;
    inc(temp_pos_y);
end;
end;

procedure scroll_xy_part_inplace(porigen,pdestino:byte;posicion_x,posicion_y:pword;scroll_x,scroll_y:word;row_shift,col_shift:byte);
var
  dst_x,dst_y,remaining,segment_w,row_index,col_index,col_group,col_phase:integer;
  source_x,source_y,base_source_y:integer;
  wrapped_x,wrapped_y:word;
  row_values,col_values,row_ptr,col_ptr:pword;
  col_offset:word;
begin
  if ((p_final[porigen].x=0) or (p_final[porigen].y=0)) then exit;
  row_values:=posicion_x;
  col_values:=posicion_y;
  col_group:=8 shl col_shift;
  for dst_y:=0 to scroll_final_y-1 do begin
    base_source_y:=scroll_y+dst_y;
    row_index:=(base_source_y shr row_shift) and ($1ff shr row_shift);
    row_ptr:=row_values;
    inc(row_ptr,row_index);
    source_x:=scroll_x+row_ptr^;
    dst_x:=0;
    while dst_x<scroll_final_x do begin
      col_index:=(source_x shr (3+col_shift)) and ($3f shr col_shift);
      col_ptr:=col_values;
      inc(col_ptr,col_index);
      col_offset:=col_ptr^;
      col_phase:=source_x and (col_group-1);
      segment_w:=col_group-col_phase;
      remaining:=scroll_final_x-dst_x;
      if segment_w>remaining then segment_w:=remaining;
      source_y:=base_source_y+col_offset;
      wrapped_x:=((source_x mod p_final[porigen].x)+p_final[porigen].x) mod p_final[porigen].x;
      wrapped_y:=((source_y mod p_final[porigen].y)+p_final[porigen].y) mod p_final[porigen].y;
      blit_wrapped_block(porigen,pdestino,wrapped_x,wrapped_y,segment_w,1,dst_x,dst_y);
      source_x:=source_x+segment_w;
      dst_x:=dst_x+segment_w;
    end;
  end;
end;

procedure scroll_xy_part(porigen,pdestino:byte;posicion_x,posicion_y:pword;scroll_x,scroll_y:word;row_shift,col_shift:byte);
var
  source_w,source_h,visible_w,visible_h:integer;
  dst_x,dst_y,band_h,next_y,row_index,row_mask:integer;
  source_x,base_source_y,wrapped_x,wrapped_y:integer;
  col_mask,col_count,col_group,col_index,col_phase:integer;
  segment_w,remaining,i,j,run_groups:integer;
  row_offset:word;
  row_ptr,col_ptr:pword;
  col_offsets:array[0..63] of integer;
  col_runs:array[0..63] of integer;
  constant_columns,power2_x,power2_y:boolean;
begin
  source_w:=p_final[porigen].x;
  source_h:=p_final[porigen].y;
  visible_w:=scroll_final_x;
  visible_h:=scroll_final_y;
  if (source_w=0) or (source_h=0) or (visible_w=0) or (visible_h=0) then exit;
  if porigen=pdestino then begin
    scroll_xy_part_inplace(porigen,pdestino,posicion_x,posicion_y,scroll_x,scroll_y,row_shift,col_shift);
    exit;
  end;
  power2_x:=(source_w and (source_w-1))=0;
  power2_y:=(source_h and (source_h-1))=0;
  row_mask:=$1ff shr row_shift;
  col_mask:=$3f shr col_shift;
  col_count:=col_mask+1;
  col_group:=8 shl col_shift;
  col_ptr:=posicion_y;
  constant_columns:=true;
  for i:=0 to col_mask do begin
    col_offsets[i]:=col_ptr^ mod source_h;
    if col_offsets[i]<>col_offsets[0] then constant_columns:=false;
    inc(col_ptr);
  end;
  if not constant_columns then
    for i:=0 to col_mask do begin
      run_groups:=1;
      j:=(i+1) and col_mask;
      while run_groups<col_count do begin
        if col_offsets[j]<>col_offsets[i] then break;
        inc(run_groups);
        j:=(j+1) and col_mask;
      end;
      col_runs[i]:=run_groups;
    end;
  dst_y:=0;
  while dst_y<visible_h do begin
    base_source_y:=integer(scroll_y)+dst_y;
    row_index:=(base_source_y shr row_shift) and row_mask;
    row_ptr:=posicion_x;
    inc(row_ptr,row_index);
    row_offset:=row_ptr^;
    band_h:=1;
    while (band_h<visible_h-dst_y) and (band_h<source_h) do begin
      next_y:=base_source_y+band_h;
      row_index:=(next_y shr row_shift) and row_mask;
      row_ptr:=posicion_x;
      inc(row_ptr,row_index);
      if row_ptr^<>row_offset then break;
      inc(band_h);
    end;
    source_x:=integer(scroll_x)+row_offset;
    dst_x:=0;
    while dst_x<visible_w do begin
      remaining:=visible_w-dst_x;
      if constant_columns then begin
        col_index:=0;
        segment_w:=remaining;
      end else begin
        col_index:=(source_x shr (3+col_shift)) and col_mask;
        col_phase:=source_x and (col_group-1);
        segment_w:=col_runs[col_index]*col_group-col_phase;
        if segment_w>remaining then segment_w:=remaining;
      end;
      // blit_wrapped_block supports one wrap per axis; split larger spans.
      if segment_w>source_w then segment_w:=source_w;
      if power2_x then wrapped_x:=source_x and (source_w-1)
        else wrapped_x:=source_x mod source_w;
      wrapped_y:=base_source_y+col_offsets[col_index];
      if power2_y then wrapped_y:=wrapped_y and (source_h-1)
        else wrapped_y:=wrapped_y mod source_h;
      if (wrapped_x+segment_w<=source_w) and (wrapped_y+band_h<=source_h) then actualiza_trozo(wrapped_x,wrapped_y,segment_w,band_h,porigen,dst_x,dst_y,segment_w,band_h,pdestino)
        else blit_wrapped_block(porigen,pdestino,wrapped_x,wrapped_y,segment_w,band_h,dst_x,dst_y);
      source_x:=source_x+segment_w;
      dst_x:=dst_x+segment_w;
    end;
    dst_y:=dst_y+band_h;
  end;
end;

//put pixel especial interno solo para los gfx...
procedure putpixel_gfx_int(x,y,cantidad:word;sitio:byte);
var
  punt:pword;
begin
//SDL_LockSurface(pantalla[sitio]);
punt:=pantalla[sitio].pixels;
inc(punt,(y*pantalla[sitio].w)+x);
copymemory(punt,punbuf,cantidad shl 1);
//SDL_UnlockSurface(pantalla[sitio]);
end;

procedure putpixel_gfx_int_32(x,y,cantidad:word;sitio:byte);
var
   punt:pdword;
begin
punt:=pantalla[sitio].pixels;
inc(punt,(y*pantalla[sitio].w)+x);
copymemory(punt,punbuf_alpha,cantidad shl 2);
end;

procedure put_gfx(pos_x,pos_y,nchar,color:word;screen,ngfx:byte);
var
  x,y:byte;
  temp:pword;
  pos:pbyte;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=punbuf;
  for x:=0 to (gfx[ngfx].x-1) do begin
    temp^:=paleta[gfx[ngfx].colores[pos^+color]];
    inc(pos);
    inc(temp);
  end;
  putpixel_gfx_int(pos_x,pos_y+y,gfx[ngfx].x,screen);
end;
end;

procedure put_gfx_trans(pos_x,pos_y,nchar,color:word;screen,ngfx:byte);
var
  x,y:byte;
  temp:pword;
  pos:pbyte;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=punbuf;
  for x:=0 to (gfx[ngfx].x-1) do begin
    if not(gfx[ngfx].trans[pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
      else temp^:=paleta[MAX_COLORES];
    inc(pos);
    inc(temp);
  end;
  putpixel_gfx_int(pos_x,pos_y+y,gfx[ngfx].x,screen);
end;
end;

procedure put_gfx_trans_alt(pos_x,pos_y,nchar,color:word;screen,ngfx,index:byte);
var
  x,y:byte;
  temp:pword;
  pos:pbyte;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=punbuf;
  for x:=0 to (gfx[ngfx].x-1) do begin
    if not(gfx[ngfx].trans_alt[index][pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
      else temp^:=paleta[MAX_COLORES];
    inc(pos);
    inc(temp);
  end;
  putpixel_gfx_int(pos_x,pos_y+y,gfx[ngfx].x,screen);
end;
end;

procedure fillword(dest:pword;cantidad:cardinal;valor:word);
{$ifdef CPU386}
asm
    cmp cantidad,0
    je @salir
    push edi
    push eax
    push ecx
    mov edi,dest   //poner destino
    mov ax,valor            // Get the fill word.
    mov ecx,cantidad    // Get the size.
    cld                     // Clear the direction flag.
    rep stosw
    pop ecx
    pop eax
    pop edi
  @salir:
end;
{$ELSE}
var
  f:cardinal;
begin
  if cantidad=0 then exit;
  for f:=1 to cantidad do begin
      dest^:=valor;
      inc(dest);
  end;
end;
{$ENDIF}

procedure put_gfx_block_trans(pos_x,pos_y:word;screen,size_x,size_y:byte);
var
  y:byte;
begin
fillword(punbuf,size_x,paleta[MAX_COLORES]);
for y:=0 to (size_y-1) do putpixel_gfx_int(pos_x,pos_y+y,size_x,screen);
end;

procedure put_gfx_block(pos_x,pos_y:word;screen,size_x,size_y:byte;color:word);
var
  y:byte;
begin
fillword(punbuf,size_x,paleta[color]);
for y:=0 to (size_y-1) do putpixel_gfx_int(pos_x,pos_y+y,size_x,screen);
end;

procedure put_gfx_mask(pos_x,pos_y,nchar,color:word;screen,ngfx,trans,mask:word);
var
  x,y:byte;
  temp:pword;
  pos:pbyte;
  punto:word;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=punbuf;
  for x:=0 to (gfx[ngfx].x-1) do begin
    punto:=gfx[ngfx].colores[pos^+color];
    if (punto and mask)<>trans then temp^:=paleta[punto]
      else temp^:=paleta[MAX_COLORES];
    inc(pos);
    inc(temp);
  end;
  putpixel_gfx_int(pos_x,pos_y+y,gfx[ngfx].x,screen);
end;
end;

procedure put_gfx_mask_flip(pos_x,pos_y,nchar,color:word;screen,ngfx,trans,mask:byte;flipx,flipy:boolean);
var
  x,y,py,cant_x,cant_y,punto:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
cant_y:=gfx[ngfx].y;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*cant_x*gfx[ngfx].y);
temp2:=punbuf;
if flipy then begin
  py:=cant_y-1;
  dir_y:=-1;
end else begin
  py:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to (cant_y-1) do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    punto:=gfx[ngfx].colores[pos^+color];
    if (punto and mask)<>trans then temp^:=paleta[punto]
      else temp^:=paleta[MAX_COLORES];
    inc(pos);
    inc(temp,dir_x);
  end;
  putpixel_gfx_int(pos_x,pos_y+py,cant_x,screen);
  py:=py+dir_y;
end;
end;

procedure put_gfx_flip(pos_x,pos_y,nchar,color:word;screen,ngfx:byte;flipx,flipy:boolean);
var
  x,y,py,cant_x,cant_y:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
cant_y:=gfx[ngfx].y;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*cant_x*gfx[ngfx].y);
temp2:=punbuf;
if flipy then begin
  py:=cant_y-1;
  dir_y:=-1;
end else begin
  py:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to (cant_y-1) do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    temp^:=paleta[gfx[ngfx].colores[pos^+color]];
    inc(pos);
    inc(temp,dir_x);
  end;
  putpixel_gfx_int(pos_x,pos_y+py,cant_x,screen);
  py:=py+dir_y;
end;
end;

procedure put_gfx_trans_flip(pos_x,pos_y,nchar:dword;color:word;screen,ngfx:byte;flipx,flipy:boolean);
var
  x,y,py,cant_x,cant_y:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
cant_y:=gfx[ngfx].y;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*cant_x*gfx[ngfx].y);
temp2:=punbuf;
if flipy then begin
  py:=cant_y-1;
  dir_y:=-1;
end else begin
  py:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to (cant_y-1) do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    if not(gfx[ngfx].trans[pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
      else temp^:=paleta[MAX_COLORES];
    inc(pos);
    inc(temp,dir_x);
  end;
  putpixel_gfx_int(pos_x,pos_y+py,cant_x,screen);
  py:=py+dir_y;
end;
end;

procedure put_gfx_trans_flip_alt(pos_x,pos_y,nchar:dword;color:word;screen,ngfx:byte;flipx,flipy:boolean;trans_index:byte);
var
  x,y,py,cant_x,cant_y:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
cant_y:=gfx[ngfx].y;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*cant_x*gfx[ngfx].y);
temp2:=punbuf;
if flipy then begin
  py:=cant_y-1;
  dir_y:=-1;
end else begin
  py:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to (cant_y-1) do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    if not(gfx[ngfx].trans_alt[trans_index][pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
       else temp^:=paleta[MAX_COLORES];
    inc(pos);
    inc(temp,dir_x);
  end;
  putpixel_gfx_int(pos_x,pos_y+py,cant_x,screen);
  py:=py+dir_y;
end;
end;

procedure put_gfx_sprite(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte);
var
  x,y,pos_y,cant_x,cant_y:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
cant_y:=gfx[ngfx].y-1;
inc(pos,nchar*cant_x*(cant_y+1));
temp2:=punbuf;
if flipy then begin
  pos_y:=cant_y;
  dir_y:=-1;
end else begin
  pos_y:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to cant_y do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    if not(gfx[ngfx].trans[pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
      else temp^:=paleta[MAX_COLORES];
    inc(temp,dir_x);
    inc(pos);
  end;
  putpixel_gfx_int(0,pos_y,cant_x,PANT_SPRITES);
  pos_y:=pos_y+dir_y;
end;
end;

procedure put_gfx_sprite_diff(nchar,color:word;flipx,flipy:boolean;ngfx:byte;x_diff,y_diff:word);
var
  x,y,pos_y,cant_x,cant_y:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
cant_y:=gfx[ngfx].y;
inc(pos,nchar*cant_x*cant_y);
temp2:=punbuf;
if flipy then begin
  pos_y:=cant_y-1;
  dir_y:=-1;
end else begin
  pos_y:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to (cant_y-1) do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    if not(gfx[ngfx].trans[pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
      else temp^:=paleta[MAX_COLORES];
    inc(temp,dir_x);
    inc(pos);
  end;
  putpixel_gfx_int(0+x_diff,pos_y+y_diff,cant_x,PANT_SPRITES);
  pos_y:=pos_y+dir_y;
end;
end;

procedure put_gfx_sprite_mask(nchar,color:word;flipx,flipy:boolean;ngfx:byte;trans,mask:word);
var
  x,y,pos_y,cant_x,cant_y,punto:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
cant_y:=gfx[ngfx].y;
inc(pos,nchar*cant_x*cant_y);
temp2:=punbuf;
if flipy then begin
  pos_y:=cant_y-1;
  dir_y:=-1;
end else begin
  pos_y:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to (cant_y-1) do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    punto:=gfx[ngfx].colores[pos^+color];
    if (punto and mask)<>trans then temp^:=paleta[punto]
      else temp^:=paleta[MAX_COLORES];
    inc(temp,dir_x);
    inc(pos);
  end;
  putpixel_gfx_int(0,pos_y,cant_x,PANT_SPRITES);
  pos_y:=pos_y+dir_y;
end;
end;

procedure put_gfx_sprite_mask_diff(nchar,color:word;flipx,flipy:boolean;ngfx,trans,mask,x_diff,y_diff:byte);
var
  x,y,pos_y,cant_x,cant_y,punto:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
cant_y:=gfx[ngfx].y;
inc(pos,nchar*cant_x*cant_y);
temp2:=punbuf;
if flipy then begin
  pos_y:=cant_y-1;
  dir_y:=-1;
end else begin
  pos_y:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to (cant_y-1) do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    punto:=gfx[ngfx].colores[pos^+color];
    if (punto and mask)<>trans then temp^:=paleta[punto]
      else temp^:=paleta[MAX_COLORES];
    inc(temp,dir_x);
    inc(pos);
  end;
  putpixel_gfx_int(0+x_diff,pos_y+y_diff,cant_x,PANT_SPRITES);
  pos_y:=pos_y+dir_y;
end;
end;

procedure put_gfx_sprite_zoom(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;zx,zy:single);
var
  x,y:byte;
  pos:pbyte;
  temp,temp2:pword;
  zoom_x,zoom_y:single;
  dir_x,dir_y:integer;
  pos_y,cant_x,cant_y:word;
begin
if ((zx<=0) or (zy<=0)) then exit;
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
cant_x:=zoom_extent(gfx[ngfx].x,zx);
cant_y:=zoom_extent(gfx[ngfx].y,zy);
if (cant_x=0) or (cant_y=0) then exit;
if cant_x>pantalla[PANT_SPRITES].w then exit;
temp2:=punbuf;
if flipy then begin
  pos_y:=cant_y-1;
  dir_y:=-1;
end else begin
  pos_y:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
zoom_y:=0;
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=temp2;
  zoom_x:=0;
  for x:=0 to (gfx[ngfx].x-1) do begin
      zoom_x:=zoom_x+zx;
      while zoom_x>0 do begin
        if not(gfx[ngfx].trans[pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
          else temp^:=paleta[MAX_COLORES];
        inc(temp,dir_x);
        zoom_x:=zoom_x-1;
      end;
      inc(pos);
  end;
  zoom_y:=zoom_y+zy;
  while ((zoom_y>0) and (pos_y<pantalla[PANT_SPRITES].h)) do begin
    putpixel_gfx_int(0,pos_y,cant_x,PANT_SPRITES);
    zoom_y:=zoom_y-1;
    pos_y:=pos_y+dir_y;
  end;
end;
end;

procedure put_gfx_sprite_shadow(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;shadow_color:word);
var
  x,y,pos_y,cant_x,cant_y:byte;
  temp,temp2:pword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
cant_y:=gfx[ngfx].y;
inc(pos,nchar*cant_x*cant_y);
temp2:=punbuf;
if flipy then begin
  pos_y:=cant_y-1;
  dir_y:=-1;
end else begin
  pos_y:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to (cant_y-1) do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    if gfx[ngfx].trans[pos^] then temp^:=paleta[MAX_COLORES]
      else if gfx[ngfx].shadow[pos^] then temp^:=paleta[shadow_color]
        else temp^:=paleta[gfx[ngfx].colores[pos^+color]];
    inc(temp,dir_x);
    inc(pos);
  end;
  putpixel_gfx_int(0,pos_y,cant_x,PANT_SPRITES);
  pos_y:=pos_y+dir_y;
end;
end;

procedure put_gfx_sprite_alpha(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte);
var
  x,y,pos_y,cant_x,cant_y:byte;
  temp,temp2:pdword;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
cant_y:=gfx[ngfx].y;
inc(pos,nchar*cant_x*cant_y);
temp2:=punbuf_alpha;
if flipy then begin
  pos_y:=cant_y-1;
  dir_y:=-1;
end else begin
  pos_y:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to (cant_y-1) do begin
  temp:=temp2;
  for x:=0 to (cant_x-1) do begin
    if not(gfx[ngfx].trans[pos^]) then begin
      if gfx[ngfx].alpha[pos^] then temp^:=paleta_alpha[gfx[ngfx].colores[pos^+color]]
        else temp^:=paleta32[gfx[ngfx].colores[pos^+color]];
    end else temp^:=paleta32[MAX_COLORES];
    inc(temp,dir_x);
    inc(pos);
  end;
  putpixel_gfx_int_32(0,pos_y,cant_x,PANT_SPRITES_ALPHA);
  pos_y:=pos_y+dir_y;
end;
end;

procedure put_gfx_sprite_zoom_alpha(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;zx,zy:single);
var
  x,y:byte;
  pos:pbyte;
  temp,temp2:pdword;
  zoom_x,zoom_y:single;
  dir_x,dir_y:integer;
  pos_y,cant_x,cant_y:word;
begin
if ((zx<=0) or (zy<=0)) then exit;
nchar:=nchar mod gfx[ngfx].elements;
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
zoom_y:=0;
cant_x:=zoom_extent(gfx[ngfx].x,zx);
cant_y:=zoom_extent(gfx[ngfx].y,zy);
if (cant_x=0) or (cant_y=0) then exit;
if cant_x>pantalla[PANT_SPRITES_ALPHA].w then exit;
temp2:=punbuf_alpha;
if flipy then begin
  pos_y:=cant_y-1;
  dir_y:=-1;
end else begin
  pos_y:=0;
  dir_y:=1;
end;
if flipx then begin
  inc(temp2,cant_x-1);
  dir_x:=-1;
end else dir_x:=1;
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=temp2;
  zoom_x:=0;
  for x:=0 to (gfx[ngfx].x-1) do begin
      zoom_x:=zoom_x+zx;
      while zoom_x>0 do begin
        if not(gfx[ngfx].trans[pos^]) then begin
          if gfx[ngfx].alpha[pos^] then temp^:=paleta_alpha[gfx[ngfx].colores[pos^+color]]
            else temp^:=paleta32[gfx[ngfx].colores[pos^+color]];
        end else temp^:=paleta32[MAX_COLORES];
        inc(temp,dir_x);
        zoom_x:=zoom_x-1;
      end;
      inc(pos);
  end;
  zoom_y:=zoom_y+zy;
  while ((zoom_y>0) and (pos_y<pantalla[PANT_SPRITES_ALPHA].h)) do begin
    putpixel_gfx_int_32(0,pos_y,cant_x,PANT_SPRITES_ALPHA);
    zoom_y:=zoom_y-1;
    pos_y:=pos_y+dir_y;
  end;
end;
end;

procedure actualiza_gfx_sprite_size(pos_x,pos_y:word;dest:byte;x_size,y_size:word;ipos_x:word=0;ipos_y:word=0);
var
  origen,destino:libsdl_rect;
begin
origen.x:=ipos_x;
origen.y:=ipos_y;
origen.w:=x_size;
origen.h:=y_size;
pos_x:=pos_x and p_final[dest].sprite_mask_x;
destino.x:=pos_x+ADD_SPRITE;
pos_y:=pos_y and p_final[dest].sprite_mask_y;
destino.y:=pos_y+ADD_SPRITE;
destino.w:=x_size;
destino.h:=y_size;
SDL_UpperBlit(pantalla[PANT_SPRITES],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[PANT_SPRITES],@origen,pantalla[dest],@destino);
end;
end;

procedure actualiza_gfx_sprite(pos_x,pos_y:word;dest,ngfx:byte);
var
  origen,destino:libsdl_rect;
begin
origen.x:=0;
origen.y:=0;
origen.w:=gfx[ngfx].x;
origen.h:=gfx[ngfx].y;
pos_x:=pos_x and p_final[dest].sprite_mask_x;
pos_y:=pos_y and p_final[dest].sprite_mask_y;
destino.w:=origen.w;
destino.h:=origen.h;
destino.x:=pos_x+ADD_SPRITE;
destino.y:=pos_y+ADD_SPRITE;
SDL_UpperBlit(pantalla[PANT_SPRITES],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[PANT_SPRITES],@origen,pantalla[dest],@destino);
end;
end;

procedure actualiza_gfx_sprite_line(pos_x,pos_y:word;dest,ngfx,line:byte);
var
  origen,destino:libsdl_rect;
begin
origen.x:=0;
origen.y:=line;
origen.w:=gfx[ngfx].x;
origen.h:=1;
pos_x:=pos_x and p_final[dest].sprite_mask_x;
pos_y:=(pos_y+line) and p_final[dest].sprite_mask_y;
destino.w:=origen.w;
destino.h:=origen.h;
destino.x:=pos_x+ADD_SPRITE;
destino.y:=pos_y+ADD_SPRITE;
SDL_UpperBlit(pantalla[PANT_SPRITES],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[PANT_SPRITES],@origen,pantalla[dest],@destino);
end;
end;

procedure actualiza_gfx_sprite_zoom(pos_x,pos_y:word;dest,ngfx:byte;zx,zy:single);
var
  origen,destino:libsdl_rect;
begin
if ((zx<=0) or (zy<=0)) then exit;
origen.x:=0;
origen.y:=0;
origen.w:=zoom_extent(gfx[ngfx].x,zx);
origen.h:=zoom_extent(gfx[ngfx].y,zy);
if (origen.w=0) or (origen.h=0) then exit;
pos_x:=pos_x and p_final[dest].sprite_mask_x;
pos_y:=pos_y and p_final[dest].sprite_mask_y;
destino.w:=origen.w;
destino.h:=origen.h;
destino.x:=pos_x+ADD_SPRITE;
destino.y:=pos_y+ADD_SPRITE;
SDL_UpperBlit(pantalla[PANT_SPRITES],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if destino.x<0 then destino.x:=0;
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  if destino.y<0 then destino.y:=0;
  SDL_UpperBlit(pantalla[PANT_SPRITES],@origen,pantalla[dest],@destino);
end;
end;

procedure actualiza_gfx_sprite_alpha(pos_x,pos_y:word;dest,ngfx:byte);
var
  origen,destino:libsdl_rect;
begin
origen.x:=0;
origen.y:=0;
origen.w:=gfx[ngfx].x;
origen.h:=gfx[ngfx].y;
pos_x:=pos_x and p_final[dest].sprite_mask_x;
pos_y:=pos_y and p_final[dest].sprite_mask_y;
destino.w:=origen.w;
destino.h:=origen.h;
destino.x:=pos_x+ADD_SPRITE;
destino.y:=pos_y+ADD_SPRITE;
SDL_UpperBlit(pantalla[PANT_SPRITES_ALPHA],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[PANT_SPRITES_ALPHA],@origen,pantalla[dest],@destino);
end;
end;

procedure actualiza_gfx_sprite_zoom_alpha(pos_x,pos_y:word;dest,ngfx:byte;zx,zy:single);
var
  origen,destino:libsdl_rect;
begin
if ((zx<=0) or (zy<=0)) then exit;
origen.x:=0;
origen.y:=0;
origen.w:=zoom_extent(gfx[ngfx].x,zx);
origen.h:=zoom_extent(gfx[ngfx].y,zy);
if (origen.w=0) or (origen.h=0) then exit;
pos_x:=pos_x and p_final[dest].sprite_mask_x;
pos_y:=pos_y and p_final[dest].sprite_mask_y;
destino.w:=origen.w;
destino.h:=origen.h;
destino.x:=pos_x+ADD_SPRITE;
destino.y:=pos_y+ADD_SPRITE;
SDL_UpperBlit(pantalla[PANT_SPRITES_ALPHA],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if destino.x<0 then destino.x:=0;
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  if destino.y<0 then destino.y:=0;
  SDL_UpperBlit(pantalla[PANT_SPRITES_ALPHA],@origen,pantalla[dest],@destino);
end;
end;

//Put pixel basics
procedure putpixel(x,y:word;cantidad:dword;pixel:pword;sitio:byte);
var
   punt:pword;
begin
punt:=pantalla[sitio].pixels;
inc(punt,((y*pantalla[sitio].pitch) shr 1)+x);
copymemory(punt,pixel,cantidad shl 1);
end;

function getpixel(x,y:word;sitio:byte):word;
var
   punt:pword;
begin
punt:=pantalla[sitio].pixels;
inc(punt,((y*pantalla[sitio].pitch) shr 1)+x);
getpixel:=punt^;
end;

procedure putpixel_alpha(x,y:word;cantidad:dword;pixel:pdword;sitio:byte);
var
   punt:pdword;
begin
punt:=pantalla[sitio].pixels;
inc(punt,((y*pantalla[sitio].pitch) shr 2)+x);
copymemory(punt,pixel,cantidad shl 2);
end;

//Draw lines
procedure single_line(x,y,color,longitud:word;pant:byte);
var
  punt:pword;
begin
punt:=pantalla[pant].pixels;
inc(punt,((y*pantalla[pant].pitch) shr 1)+x);
fillword(punt,longitud,color);
end;

procedure draw_line(x0,y0,x1,y1:integer;color:word;pant:byte);
var
  dy,dx,stepx,stepy:integer;
  fraction:single;
begin
punbuf^:=paleta[color];
//Metodo Bresenham
dy:=y1-y0;
dx:=x1-x0;
if (dy<0) then begin
  dy:=-dy;
  stepy:=-1;
end else stepy:=1;
if (dx<0) then begin
  dx:=-dx;
  stepx:=-1;
end else stepx:=1;
dy:=dy shl 1; // dy is now 2*dy
dx:=dx shl 1; // dx is now 2*dx
putpixel_gfx_int(x0,y0,1,pant);
if (dx>dy) then begin
  fraction:=dy-(dx/2); // same as 2*dy - dx
  while (x0<>x1) do begin
    if (fraction>=0) then begin
      y0:=y0+stepy;
      fraction:=fraction-dx; // same as fraction -= 2*dx
    end;
    x0:=x0+stepx;
    fraction:=fraction+dy;  // same as fraction -= 2*dy
    putpixel_gfx_int(x0,y0,1,pant);
  end;
end else begin
  fraction:=dx-(dy/2);
  while (y0<>y1) do begin
    if (fraction>=0) then begin
      x0:=x0+stepx;
      fraction:=fraction-dy;
    end;
    y0:=y0+stepy;
    fraction:=fraction+dx;
    putpixel_gfx_int(x0,y0,1,pant);
  end;
end;
end;

//Screen functions
procedure fill_full_screen(screen:byte;color:word);
begin
fillword(pantalla[screen].pixels,pantalla[screen].w*pantalla[screen].h,paleta[color]);
end;

procedure reset_gfx;
var
  f:byte;
begin
  for f:=0 to MAX_GFX-1 do fillchar(gfx[f].buffer,$8000,1);
  fillchar(buffer_sprites,$2000,0);
  fillchar(buffer_sprites_w,$2000,0);
  fillchar(buffer_color,MAX_COLOR_BUFFER,1);
  //Spectrum
  fillchar(borde.buffer,78000,$80);
end;

end.
