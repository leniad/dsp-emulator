unit gfx_engine;

{$ifdef fpc}{$asmmode intel}{$endif}

interface
uses lib_sdl2,{$IFDEF windows}windows,{$ENDIF}
     pal_engine,vars_hide;

const
  MAX_GFX=8;
  ADD_SPRITE=64;
  MAX_COLOR_BUFFER=$200;
type
  gfx_tipo=record
    x,y:byte;
    datos:pbyte;
    colores:array[0..max_colores-1] of word;
    trans:array[0..$1f] of boolean;
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
procedure convert_gfx(num_gfx:byte;increment:dword;SpriteRom:pbyte;cx,cy:pdword;rot90,rol90:boolean);
procedure gfx_set_desc_data(bits_pixel,banks:byte;size,p0:dword;p1:dword=0;p2:dword=0;p3:dword=0;p4:dword=0;p5:dword=0;p6:dword=0;p7:dword=0);
//GFX put
procedure put_gfx(pos_x,pos_y,nchar,color:word;screen,ngfx:byte);
procedure put_gfx_mask(pos_x,pos_y,nchar,color:word;screen,ngfx,trans,mask:byte);
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
procedure put_gfx_sprite_zoom_alpha(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;zx,zy:single);
procedure put_gfx_sprite_alpha(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte);
procedure actualiza_gfx_sprite_zoom_alpha(pos_x,pos_y:word;dest,ngfx:byte;zx,zy:single);
//Sprites Update
procedure actualiza_gfx_sprite(pos_x,pos_y:word;dest,ngfx:byte);
procedure actualiza_gfx_sprite_over(pos_x,pos_y:word;dest,ngfx,src_over:byte;scr_x,scr_y:word);
procedure actualiza_gfx_sprite_size(pos_x,pos_y:word;dest:byte;x_size,y_size:word);
procedure actualiza_gfx_sprite_size_pos(pos_x,pos_y:word;dest:byte;x_size,y_size,ipos_x,ipos_y:word);
procedure actualiza_gfx_sprite_zoom(pos_x,pos_y:word;dest,ngfx:byte;zx,zy:single);
procedure actualiza_gfx_sprite_alpha(pos_x,pos_y:word;dest,ngfx:byte);
//Scroll
procedure scroll_x_y(porigen,pdestino:byte;scroll_x,scroll_y:word);
procedure scroll__x(porigen,pdestino:byte;scroll_x:word);
procedure scroll__x_part(porigen,pdestino:byte;scroll_x,scroll_y:word;orgy,sizey:word);
procedure scroll__y(porigen,pdestino:byte;scroll_y:word);
procedure scroll__y_part(porigen,pdestino:byte;scroll_y,scroll_x:word;orgx,sizex:word);
//Basic draw functions
procedure putpixel(x,y:word;cantidad:dword;pixel:pword;sitio:byte);
procedure single_line(x,y,color,longitud:word;pant:byte);
procedure draw_line(x0,y0,x1,y1:integer;color:word;pant:byte);
//Screen functions
procedure fill_full_screen(screen:byte;color:word);
//Misc
procedure fillword(dest:pword;cantidad:cardinal;valor:word);

implementation
uses main_engine;

procedure copymemory_invw(dest,orig:pword;cant:dword);inline;
var
   temp,temp2:pword;
   f:dword;
begin
if cant=0 then exit;
temp:=dest;
temp2:=orig;
inc(temp2,cant-1);
for f:=(cant-1) downto 0 do begin
    temp^:=temp2^;
    inc(temp);
    dec(temp2);
end;
end;

procedure copymemory_invw_32(dest,orig:pdword;cant:dword);inline;
var
   temp,temp2:pdword;
   f:dword;
begin
if cant=0 then exit;
temp:=dest;
temp2:=orig;
inc(temp2,cant-1);
for f:=(cant-1) downto 0 do begin
    temp^:=temp2^;
    inc(temp);
    dec(temp2);
end;
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
  fillchar(gfx[num].alpha[0],$20,0);
  for f:=0 to 4 do fillchar(gfx[num].trans_alt[f],$20,0);
  for f:=0 to max_colores-1 do gfx[num].colores[f]:=f;
  getmem(gfx[num].datos,num_elements*x_size*y_size);
end;

function GetBit(bit_nbr:dword;buffer:pbyte):byte;inline;
var
  oct_nbr:dword;
  bit_n:byte;
begin
oct_nbr:=bit_nbr shr 3;
bit_n:=bit_nbr and 7;
getbit:=((buffer[oct_nbr] shr (7-bit_n)) and 1);
end;

procedure Rotatel(n:word;ngfx:pgfx;increment:dword);
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

procedure Rotater(n:word;ngfx:pgfx;increment:dword);
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

procedure convert_gfx(num_gfx:byte;increment:dword;SpriteRom:pbyte;cx,cy:pdword;rot90,rol90:boolean);
var
  n,elements:dword;
  oct,b0,o,i,bit_pixel:byte;
  SpriteNbr,ind:dword;
  temp_cx,temp_cy:pdword;
  ngfx:pgfx;
begin
ngfx:=@gfx[num_gfx];
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
end;

//Scroll functions
procedure scroll_x_y2(porigen,pdestino:byte;scroll_x,scroll_y:word);
var
  long_x,long_x2,long_y,long_y2:word;
begin
scroll_x:=scroll_x and p_final[porigen].scroll.mask_x;
scroll_y:=scroll_y and p_final[porigen].scroll.mask_y;
if ((scroll_x+p_final[porigen].scroll.max_x)>=p_final[porigen].scroll.long_x) then begin
  long_x:=p_final[porigen].scroll.long_x-scroll_x;
  long_x2:=p_final[porigen].scroll.max_x-long_x;
  actualiza_trozo(0,scroll_y,long_x2,p_final[porigen].scroll.max_y,porigen,long_x,0,long_x2,p_final[porigen].scroll.max_y,pdestino);
end else begin
  long_x:=p_final[porigen].scroll.max_x;
end;
if ((scroll_y+p_final[porigen].scroll.max_y)>=p_final[porigen].scroll.long_y) then begin
  long_y:=p_final[porigen].scroll.long_y-scroll_y;
  long_y2:=p_final[porigen].scroll.max_y-long_y;
  actualiza_trozo(scroll_x,0,long_x,long_y2,porigen,0,long_y,long_x,long_y2,pdestino);
end else begin
  long_y:=p_final[porigen].scroll.max_y;
end;
actualiza_trozo(scroll_x,scroll_y,long_x,long_y,porigen,0,0,long_x,long_y,pdestino);
if ((long_x<p_final[porigen].scroll.max_x) and (long_y<p_final[porigen].scroll.max_y)) then
  actualiza_trozo(0,0,p_final[porigen].scroll.max_x-long_x,p_final[porigen].scroll.max_y-long_y,porigen,long_x,long_y,p_final[porigen].scroll.max_x-long_x,p_final[porigen].scroll.max_y-long_y,pdestino);
end;

procedure scroll_x_y(porigen,pdestino:byte;scroll_x,scroll_y:word);
var
  long_x,long_y,long_x2,long_y2:word;
begin
scroll_x:=scroll_x and p_final[porigen].scroll.mask_x;
scroll_y:=scroll_y and p_final[porigen].scroll.mask_y;
if ((scroll_x+p_final[porigen].scroll.max_x)>=p_final[porigen].scroll.long_x) then long_x:=p_final[porigen].scroll.long_x-scroll_x
  else long_x:=p_final[porigen].scroll.max_x;
if ((scroll_y+p_final[porigen].scroll.max_y)>=p_final[porigen].scroll.long_y) then long_y:=p_final[porigen].scroll.long_y-scroll_y
  else long_y:=p_final[porigen].scroll.max_y;
long_x2:=p_final[porigen].scroll.max_x-long_x;
long_y2:=p_final[porigen].scroll.max_y-long_y;
actualiza_trozo(scroll_x,scroll_y,long_x,long_y,porigen,0,0,long_x,long_y,pdestino);
if long_x<p_final[porigen].scroll.max_x then actualiza_trozo(0,scroll_y,long_x2,long_y,porigen,long_x,0,long_x2,long_y,pdestino);
if long_y<p_final[porigen].scroll.max_y then actualiza_trozo(scroll_x,0,long_x,long_y2,porigen,0,long_y,long_x,long_y2,pdestino);
if ((long_x<p_final[porigen].scroll.max_x) and (long_y<p_final[porigen].scroll.max_y)) then
actualiza_trozo(0,0,long_x2,long_y2,porigen,long_x,long_y,long_x2,long_y2,pdestino);
end;

procedure scroll__x(porigen,pdestino:byte;scroll_x:word);
var
  long_x,long_x2,long_y:word;
begin
long_y:=256;//p_final[0].y;
scroll_x:=scroll_x and p_final[porigen].scroll.mask_x;
if ((scroll_x+p_final[porigen].scroll.max_x)>=p_final[porigen].scroll.long_x) then begin
  long_x:=p_final[porigen].scroll.long_x-scroll_x;
  long_x2:=p_final[porigen].scroll.max_x-long_x;
  actualiza_trozo(0,0,long_x2,long_y,porigen,long_x,0,long_x2,long_y,pdestino);
end else begin
  long_x:=p_final[porigen].scroll.max_x;
end;
actualiza_trozo(scroll_x,0,long_x,long_y,porigen,0,0,long_x,long_y,pdestino);
end;

procedure scroll__y(porigen,pdestino:byte;scroll_y:word);
var
  long_x,long_y,long_y2:word;
begin
long_x:=256;//p_final[0].x;
scroll_y:=scroll_y and p_final[porigen].scroll.mask_y;
if ((scroll_y+p_final[porigen].scroll.max_y)>p_final[porigen].scroll.long_y) then begin
  long_y:=p_final[porigen].scroll.long_y-scroll_y;
  long_y2:=p_final[porigen].scroll.max_y-long_y;
  actualiza_trozo(0,0,long_x,long_y2,porigen,0,long_y,long_x,long_y2,pdestino);
end else begin
    long_y:=p_final[porigen].scroll.max_y;
end;
actualiza_trozo(0,scroll_y,long_x,long_y,porigen,0,0,long_x,long_y,pdestino);
end;

procedure scroll__x_part(porigen,pdestino:byte;scroll_x,scroll_y:word;orgy,sizey:word);
var
  long_x,long_x2,scroll_y2:word;
begin
scroll_x:=scroll_x and p_final[porigen].scroll.mask_x;
scroll_y:=(p_final[porigen].scroll.long_y-scroll_y) and p_final[porigen].scroll.mask_y;
scroll_y2:=scroll_y+orgy;
if (scroll_y2>p_final[porigen].scroll.long_y) then scroll_y2:=scroll_y2-p_final[porigen].scroll.max_y;
if ((scroll_x+p_final[porigen].scroll.max_x)>=p_final[porigen].scroll.long_x) then begin
  long_x:=p_final[porigen].scroll.long_x-scroll_x;
  long_x2:=p_final[porigen].scroll.max_x-long_x;
  actualiza_trozo(0,orgy,long_x2,sizey,porigen,long_x,scroll_y2,long_x2,sizey,pdestino);
end else begin
  long_x:=p_final[porigen].scroll.max_x;
end;
actualiza_trozo(scroll_x,orgy,long_x,sizey,porigen,0,scroll_y2,long_x,sizey,pdestino);
end;

procedure scroll__y_part(porigen,pdestino:byte;scroll_y,scroll_x:word;orgx,sizex:word);
var
  long_y,long_y2,scroll_x2:word;
begin
scroll_y:=scroll_y and p_final[porigen].scroll.mask_y;
scroll_x:=(p_final[porigen].scroll.long_x-scroll_x) and p_final[porigen].scroll.mask_x;
scroll_x2:=scroll_x+orgx;
if (scroll_x2>p_final[porigen].scroll.long_x) then scroll_x2:=scroll_x2-p_final[porigen].scroll.max_x;
if ((scroll_y+p_final[porigen].scroll.max_y)>p_final[porigen].scroll.long_y) then begin
  long_y:=p_final[porigen].scroll.long_y-scroll_y;
  long_y2:=p_final[porigen].scroll.max_y-long_y;
  actualiza_trozo(orgx,0,sizex,long_y2,porigen,scroll_x2,long_y,sizex,long_y2,pdestino);
end else begin
  long_y:=p_final[porigen].scroll.max_y;
end;
actualiza_trozo(orgx,scroll_y,sizex,long_y,porigen,scroll_x2,0,sizex,long_y,pdestino);
end;

//put pixel especial interno solo para los gfx...
procedure putpixel_gfx_int(x,y,cantidad:word;sitio:byte);inline;
var
   punt:pword;
begin
punt:=pantalla[sitio].pixels;
inc(punt,(y*pantalla[sitio].w)+x);
copymemory(punt,punbuf,cantidad shl 1);
end;

procedure putpixel_gfx_int_32(x,y,cantidad:word;sitio:byte);inline;
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
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=punbuf;
  for x:=0 to (gfx[ngfx].x-1) do begin
    if not(gfx[ngfx].trans[pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
      else temp^:=paleta[max_colores];
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
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=punbuf;
  for x:=0 to (gfx[ngfx].x-1) do begin
    if not(gfx[ngfx].trans_alt[index][pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
      else temp^:=paleta[max_colores];
    inc(pos);
    inc(temp);
  end;
  putpixel_gfx_int(pos_x,pos_y+y,gfx[ngfx].x,screen);
end;
end;

{$IFDEF CPU64}
procedure fillword(dest:pword;cantidad:cardinal;valor:word);
var
  f:cardinal;
  ptemp:pword;
begin
  if cantidad=0 then exit;
  ptemp:=dest;
  for f:=1 to cantidad do begin
      ptemp^:=valor;
      inc(ptemp);
  end;
end;
{$ELSE}
procedure fillword(dest:pword;cantidad:cardinal;valor:word);
asm
    cmp cantidad,0
    je @salir
    push edi
    push eax
    push ecx
    mov edi,eax   //poner destino
    mov ax,valor            // Get the fill word.
    mov ecx,cantidad    // Get the size.
    cld                     // Clear the direction flag.
    rep stosw
    pop ecx
    pop eax
    pop edi
  @salir:
end;
{$ENDIF}

procedure put_gfx_block_trans(pos_x,pos_y:word;screen,size_x,size_y:byte);
var
  y:byte;
begin
fillword(punbuf,size_x,paleta[max_colores]);
for y:=0 to (size_y-1) do putpixel_gfx_int(pos_x,pos_y+y,size_x,screen);
end;

procedure put_gfx_block(pos_x,pos_y:word;screen,size_x,size_y:byte;color:word);
var
  y:byte;
begin
fillword(punbuf,size_x,paleta[color]);
for y:=0 to (size_y-1) do putpixel_gfx_int(pos_x,pos_y+y,size_x,screen);
end;

procedure put_gfx_mask(pos_x,pos_y,nchar,color:word;screen,ngfx,trans,mask:byte);
var
  x,y:byte;
  temp:pword;
  pos:pbyte;
  punto:word;
begin
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=punbuf;
  for x:=0 to (gfx[ngfx].x-1) do begin
    punto:=gfx[ngfx].colores[pos^+color];
    if (punto and mask)<>trans then temp^:=paleta[punto]
      else temp^:=paleta[max_colores];
    inc(pos);
    inc(temp);
  end;
  putpixel_gfx_int(pos_x,pos_y+y,gfx[ngfx].x,screen);
end;
end;

procedure put_gfx_mask_flip(pos_x,pos_y,nchar,color:word;screen,ngfx,trans,mask:byte;flipx,flipy:boolean);
var
  x,y,py,cant_x,punto:byte;
  temp:pword;
  pos:pbyte;
  direccion:integer;
begin
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*cant_x*gfx[ngfx].y);
if flipy then begin
  py:=gfx[ngfx].y-1;
  direccion:=-1;
end else begin
  py:=0;
  direccion:=1;
end;
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=tpunbuf;
  for x:=0 to (cant_x-1) do begin
    punto:=gfx[ngfx].colores[pos^+color];
    if (punto and mask)<>trans then temp^:=paleta[punto]
      else temp^:=paleta[max_colores];
    inc(pos);
    inc(temp);
  end;
  if flipx then copymemory_invw(punbuf,tpunbuf,cant_x)
     else copymemory(punbuf,tpunbuf,cant_x*2);
  putpixel_gfx_int(pos_x,pos_y+py,cant_x,screen);
  py:=py+direccion;
  end;
end;

procedure put_gfx_flip(pos_x,pos_y,nchar,color:word;screen,ngfx:byte;flipx,flipy:boolean);
var
  x,y,py,cant_x:byte;
  temp:pword;
  pos:pbyte;
  direccion:integer;
begin
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*cant_x*gfx[ngfx].y);
if flipy then begin
  py:=gfx[ngfx].y-1;
  direccion:=-1;
end else begin
  py:=0;
  direccion:=1;
end;
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=tpunbuf;
  for x:=0 to (cant_x-1) do begin
    temp^:=paleta[gfx[ngfx].colores[pos^+color]];
    inc(pos);
    inc(temp);
  end;
  if flipx then copymemory_invw(punbuf,tpunbuf,cant_x)
     else copymemory(punbuf,tpunbuf,cant_x*2);
  putpixel_gfx_int(pos_x,pos_y+py,cant_x,screen);
  py:=py+direccion;
  end;
end;

procedure put_gfx_trans_flip(pos_x,pos_y,nchar:dword;color:word;screen,ngfx:byte;flipx,flipy:boolean);
var
  x,y,py,cant_x:byte;
  temp:pword;
  pos:pbyte;
  direccion:integer;
begin
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*cant_x*gfx[ngfx].y);
if flipy then begin
  py:=gfx[ngfx].y-1;
  direccion:=-1;
end else begin
  py:=0;
  direccion:=1;
end;
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=tpunbuf;
  for x:=0 to (cant_x-1) do begin
    if not(gfx[ngfx].trans[pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
      else temp^:=paleta[max_colores];
    inc(pos);
    inc(temp);
  end;
  if flipx then
    copymemory_invw(punbuf,tpunbuf,cant_x)
     else copymemory(punbuf,tpunbuf,cant_x*2);
    putpixel_gfx_int(pos_x,pos_y+py,cant_x,screen);
  py:=py+direccion;
end;
end;

procedure put_gfx_trans_flip_alt(pos_x,pos_y,nchar:dword;color:word;screen,ngfx:byte;flipx,flipy:boolean;trans_index:byte);
var
  x,y,py,cant_x:byte;
  temp:pword;
  pos:pbyte;
  direccion:integer;
begin
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*cant_x*gfx[ngfx].y);
if flipy then begin
  py:=gfx[ngfx].y-1;
  direccion:=-1;
end else begin
  py:=0;
  direccion:=1;
end;
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=tpunbuf;
  for x:=0 to (cant_x-1) do begin
    if not(gfx[ngfx].trans_alt[trans_index][pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
       else temp^:=paleta[max_colores];
    inc(pos);
    inc(temp);
  end;
  if flipx then copymemory_invw(punbuf,tpunbuf,cant_x)
     else copymemory(punbuf,tpunbuf,cant_x*2);
    putpixel_gfx_int(pos_x,pos_y+py,cant_x,screen);
  py:=py+direccion;
end;
end;

procedure put_gfx_sprite(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte);
var
  x,y,pos_y,cant_x:byte;
  temp:pword;
  pos:pbyte;
  direccion:integer;
begin
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
if flipy then begin
  pos_y:=gfx[ngfx].y-1;
  direccion:=-1;
end else begin
  pos_y:=0;
  direccion:=1;
end;
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=tpunbuf;
  for x:=0 to (cant_x-1) do begin
    if not(gfx[ngfx].trans[pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
      else temp^:=paleta[max_colores];
    inc(temp);
    inc(pos);
  end;
  if flipx then copymemory_invw(punbuf,tpunbuf,cant_x)
     else copymemory(punbuf,tpunbuf,cant_x*2);
  putpixel_gfx_int(0,pos_y,cant_x,pant_sprites);
  pos_y:=pos_y+direccion;
end;
end;

procedure put_gfx_sprite_diff(nchar,color:word;flipx,flipy:boolean;ngfx:byte;x_diff,y_diff:word);
var
        x,y:byte;
        temp:pword;
        pos,post:pbyte;
begin
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
if flipx then begin
  for y:=0 to (gfx[ngfx].y-1) do begin
    post:=pos;
    inc(post,(y*gfx[ngfx].x)+gfx[ngfx].x-1);
    temp:=punbuf;
    for x:=(gfx[ngfx].x-1) downto 0 do begin
      if not(gfx[ngfx].trans[post^]) then temp^:=paleta[gfx[ngfx].colores[post^+color]]
        else temp^:=paleta[max_colores];
      dec(post);
      inc(temp);
    end;
    if flipy then
      putpixel(0+x_diff,((gfx[ngfx].y-1)-y)+y_diff,gfx[ngfx].x,punbuf,pant_sprites)
      else putpixel(0+x_diff,y+y_diff,gfx[ngfx].x,punbuf,pant_sprites);
  end;
end else begin
  for y:=0 to (gfx[ngfx].y-1) do begin
    temp:=punbuf;
    for x:=0 to (gfx[ngfx].x-1) do begin
      if not(gfx[ngfx].trans[pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
        else temp^:=paleta[max_colores];
      inc(temp);
      inc(pos);
    end;
    if flipy then putpixel(0+x_diff,((gfx[ngfx].y-1)-y)+y_diff,gfx[ngfx].x,punbuf,pant_sprites)
      else putpixel(0+x_diff,y+y_diff,gfx[ngfx].x,punbuf,pant_sprites);
  end;
end;
end;

procedure put_gfx_sprite_mask(nchar,color:word;flipx,flipy:boolean;ngfx:byte;trans,mask:word);
var
        x,y,punto:byte;
        temp:pword;
        pos,post:pbyte;
begin
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
if flipx then begin
  for y:=0 to (gfx[ngfx].y-1) do begin
    post:=pos;
    inc(post,(y*gfx[ngfx].x)+gfx[ngfx].x-1);
    temp:=punbuf;
    for x:=(gfx[ngfx].x-1) downto 0 do begin
      punto:=gfx[ngfx].colores[post^+color];
      if (punto and mask)<>trans then temp^:=paleta[punto]
        else temp^:=paleta[max_colores];
      dec(post);
      inc(temp);
    end;
    if flipy then putpixel(0,((gfx[ngfx].y-1)-y),gfx[ngfx].x,punbuf,pant_sprites)
      else putpixel(0,y,gfx[ngfx].x,punbuf,pant_sprites);
  end;
end else begin
  for y:=0 to (gfx[ngfx].y-1) do begin
    temp:=punbuf;
    for x:=0 to (gfx[ngfx].x-1) do begin
      punto:=gfx[ngfx].colores[pos^+color];
      if (punto and mask)<>trans then temp^:=paleta[punto]
        else temp^:=paleta[max_colores];
      inc(temp);
      inc(pos);
    end;
    if flipy then putpixel(0,((gfx[ngfx].y-1)-y),gfx[ngfx].x,punbuf,pant_sprites)
      else putpixel(0,y,gfx[ngfx].x,punbuf,pant_sprites);
  end;
end;
end;

procedure put_gfx_sprite_mask_diff(nchar,color:word;flipx,flipy:boolean;ngfx,trans,mask,x_diff,y_diff:byte);
var
  x,y,punto:byte;
  temp:pword;
  pos,post:pbyte;
begin
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
if flipx then begin
  for y:=0 to (gfx[ngfx].y-1) do begin
    post:=pos;
    inc(post,(y*gfx[ngfx].x)+gfx[ngfx].x-1);
    temp:=punbuf;
    for x:=(gfx[ngfx].x-1) downto 0 do begin
      punto:=gfx[ngfx].colores[post^+color];
      if (punto and mask)<>trans then temp^:=paleta[punto]
        else temp^:=paleta[max_colores];
      dec(post);
      inc(temp);
    end;
    if flipy then putpixel(0+x_diff,((gfx[ngfx].y-1)-y)+y_diff,gfx[ngfx].x,punbuf,pant_sprites)
      else putpixel(0+x_diff,y+y_diff,gfx[ngfx].x,punbuf,pant_sprites);
  end;
end else begin
  for y:=0 to (gfx[ngfx].y-1) do begin
    temp:=punbuf;
    for x:=0 to (gfx[ngfx].x-1) do begin
      punto:=gfx[ngfx].colores[pos^+color];
      if (punto and mask)<>trans then temp^:=paleta[punto]
        else temp^:=paleta[max_colores];
      inc(temp);
      inc(pos);
    end;
    if flipy then putpixel(0+x_diff,((gfx[ngfx].y-1)-y)+y_diff,gfx[ngfx].x,punbuf,pant_sprites)
      else putpixel(0+x_diff,y+y_diff,gfx[ngfx].x,punbuf,pant_sprites);
  end;
end;
end;

procedure put_gfx_sprite_zoom(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;zx,zy:single);
var
  x,y,pos_y,cant_x:byte;
  pos:pbyte;
  temp:pword;
  zoom_x,zoom_y:single;
  direccion:integer;
begin
if ((zx<=0) and (zy<=0)) then exit;
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
zoom_y:=0;
cant_x:=round(gfx[ngfx].x*zx);
if flipy then begin
  pos_y:=round((gfx[ngfx].y-1)*zy);
  direccion:=-1;
end else begin
  pos_y:=0;
  direccion:=1;
end;
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=tpunbuf;
  zoom_x:=0;
  for x:=0 to (gfx[ngfx].x-1) do begin
      zoom_x:=zoom_x+zx;
      while zoom_x>0 do begin
        if not(gfx[ngfx].trans[pos^]) then temp^:=paleta[gfx[ngfx].colores[pos^+color]]
          else temp^:=paleta[max_colores];
        inc(temp);
        zoom_x:=zoom_x-1;
      end;
      inc(pos);
  end;
  zoom_y:=zoom_y+zy;
  if flipx then copymemory_invw(punbuf,tpunbuf,cant_x)
     else copymemory(punbuf,tpunbuf,cant_x*2);
  while zoom_y>0 do begin
    putpixel_gfx_int(0,pos_y,cant_x,pant_sprites);
    zoom_y:=zoom_y-1;
    pos_y:=pos_y+direccion;
  end;
end;
end;

procedure put_gfx_sprite_alpha(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte);
var
  x,y,pos_y,cant_x:byte;
  pos:pbyte;
  direccion:integer;
  temp:pdword;
begin
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
if flipy then begin
  pos_y:=gfx[ngfx].y-1;
  direccion:=-1;
end else begin
  pos_y:=0;
  direccion:=1;
end;
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=tpunbuf_alpha;
  for x:=0 to (cant_x-1) do begin
    if not(gfx[ngfx].trans[pos^]) then begin
      if gfx[ngfx].alpha[pos^] then temp^:=paleta_alpha[gfx[ngfx].colores[pos^+color]]
        else temp^:=paleta32[gfx[ngfx].colores[pos^+color]];
    end else temp^:=paleta32[max_colores];
    inc(temp);
    inc(pos);
  end;
  if flipx then copymemory_invw_32(punbuf_alpha,tpunbuf_alpha,cant_x)
     else copymemory(punbuf_alpha,tpunbuf_alpha,cant_x*4);
  putpixel_gfx_int_32(0,pos_y,cant_x,pant_sprites_alpha);
  pos_y:=pos_y+direccion;
end;
end;

procedure put_gfx_sprite_zoom_alpha(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;zx,zy:single);
var
  x,y,pos_y,cant_x:byte;
  pos:pbyte;
  temp:pdword;
  zoom_x,zoom_y:single;
  direccion:integer;
begin
if ((zx<=0) and (zy<=0)) then exit;
pos:=gfx[ngfx].datos;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
zoom_y:=0;
cant_x:=round(gfx[ngfx].x*zx);
if flipy then begin
  pos_y:=round((gfx[ngfx].y-1)*zy);
  direccion:=-1;
end else begin
  pos_y:=0;
  direccion:=1;
end;
for y:=0 to (gfx[ngfx].y-1) do begin
  temp:=tpunbuf_alpha;
  zoom_x:=0;
  for x:=0 to (gfx[ngfx].x-1) do begin
      zoom_x:=zoom_x+zx;
      while zoom_x>0 do begin
        if not(gfx[ngfx].trans[pos^]) then begin
          if gfx[ngfx].alpha[pos^] then temp^:=paleta_alpha[gfx[ngfx].colores[pos^+color]]
            else temp^:=paleta32[gfx[ngfx].colores[pos^+color]];
        end else temp^:=paleta32[max_colores];
        inc(temp);
        zoom_x:=zoom_x-1;
      end;
      inc(pos);
  end;
  zoom_y:=zoom_y+zy;
  if flipx then copymemory_invw_32(punbuf_alpha,tpunbuf_alpha,cant_x)
     else copymemory(punbuf_alpha,tpunbuf_alpha,cant_x*4);
  while zoom_y>0 do begin
    putpixel_gfx_int_32(0,pos_y,cant_x,pant_sprites_alpha);
    zoom_y:=zoom_y-1;
    pos_y:=pos_y+direccion;
  end;
end;
end;

procedure actualiza_gfx_sprite_size_pos(pos_x,pos_y:word;dest:byte;x_size,y_size,ipos_x,ipos_y:word);
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
SDL_UpperBlit(pantalla[pant_sprites],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[pant_sprites],@origen,pantalla[dest],@destino);
end;
end;

procedure actualiza_gfx_sprite_size(pos_x,pos_y:word;dest:byte;x_size,y_size:word);
var
  origen,destino:libsdl_rect;
begin
origen.x:=0;
origen.y:=0;
origen.w:=x_size;
origen.h:=y_size;
pos_x:=pos_x and p_final[dest].sprite_mask_x;
destino.x:=pos_x+ADD_SPRITE;
pos_y:=pos_y and p_final[dest].sprite_mask_y;
destino.y:=pos_y+ADD_SPRITE;
destino.w:=x_size;
destino.h:=y_size;
SDL_UpperBlit(pantalla[pant_sprites],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[pant_sprites],@origen,pantalla[dest],@destino);
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
SDL_UpperBlit(pantalla[pant_sprites],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[pant_sprites],@origen,pantalla[dest],@destino);
end;
end;

procedure actualiza_gfx_sprite_over(pos_x,pos_y:word;dest,ngfx,src_over:byte;scr_x,scr_y:word);
var
  origen,destino:libsdl_rect;
begin
origen.x:=0;
origen.y:=0;
origen.w:=gfx[ngfx].x;
origen.h:=gfx[ngfx].y;
pos_x:=pos_x and p_final[dest].sprite_mask_x;
destino.x:=pos_x+ADD_SPRITE;
pos_y:=pos_y and p_final[dest].sprite_mask_y;
destino.y:=pos_y+ADD_SPRITE;
destino.w:=origen.w;
destino.h:=origen.h;
SDL_UpperBlit(pantalla[pant_sprites],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[pant_sprites],@origen,pantalla[dest],@destino);
end;
origen.x:=(pos_x+scr_x) and p_final[src_over].scroll.mask_x;
origen.y:=(pos_y+scr_y) and p_final[src_over].scroll.mask_y;
SDL_UpperBlit(pantalla[src_over],@origen,pantalla[dest],@destino);
end;

procedure actualiza_gfx_sprite_zoom(pos_x,pos_y:word;dest,ngfx:byte;zx,zy:single);
var
  origen,destino:libsdl_rect;
begin
if ((zx<=0) and (zy<=0)) then exit;
origen.x:=0;
origen.y:=0;
origen.w:=round(gfx[ngfx].x*zx);
origen.h:=round(gfx[ngfx].y*zy);
pos_x:=pos_x and p_final[dest].sprite_mask_x;
pos_y:=pos_y and p_final[dest].sprite_mask_y;
destino.w:=origen.w;
destino.h:=origen.h;
destino.x:=pos_x+ADD_SPRITE;
destino.y:=pos_y+ADD_SPRITE;
SDL_UpperBlit(pantalla[pant_sprites],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[pant_sprites],@origen,pantalla[dest],@destino);
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
SDL_UpperBlit(pantalla[pant_sprites_alpha],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[pant_sprites_alpha],@origen,pantalla[dest],@destino);
end;
end;

procedure actualiza_gfx_sprite_zoom_alpha(pos_x,pos_y:word;dest,ngfx:byte;zx,zy:single);
var
  origen,destino:libsdl_rect;
begin
if ((zx<=0) and (zy<=0)) then exit;
origen.x:=0;
origen.y:=0;
origen.w:=round(gfx[ngfx].x*zx);
origen.h:=round(gfx[ngfx].y*zy);
pos_x:=pos_x and p_final[dest].sprite_mask_x;
pos_y:=pos_y and p_final[dest].sprite_mask_y;
destino.w:=origen.w;
destino.h:=origen.h;
destino.x:=pos_x+ADD_SPRITE;
destino.y:=pos_y+ADD_SPRITE;
SDL_UpperBlit(pantalla[pant_sprites_alpha],@origen,pantalla[dest],@destino);
if (pos_x+origen.w>p_final[dest].sprite_end_x) or (pos_y+origen.h>p_final[dest].sprite_end_y) then begin
  if (pos_x+origen.w)>p_final[dest].sprite_end_x then destino.x:=ADD_SPRITE-(p_final[dest].sprite_end_x-pos_x);
  if (pos_y+origen.h)>p_final[dest].sprite_end_y then destino.y:=ADD_SPRITE-(p_final[dest].sprite_end_y-pos_y);
  SDL_UpperBlit(pantalla[pant_sprites_alpha],@origen,pantalla[dest],@destino);
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

//Draw lines
procedure single_line(x,y,color,longitud:word;pant:byte);
var
  punt:pword;
begin
punt:=pantalla[pant].pixels;
inc(punt,((y*pantalla[pant].pitch) shr 1)+x);
fillword(punt,longitud,paleta[color]);
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
procedure fill_full_screen(screen:byte;color:word);inline;
begin
fillword(pantalla[screen].pixels,pantalla[screen].w*pantalla[screen].h,paleta[color]);
end;

end.
