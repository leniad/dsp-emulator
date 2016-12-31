unit sprite_engine;

interface
uses windows,pal_engine,gfx_engine,vars_hide;

const
  MAX_SCREEN_SPRITE=$400;

type
  tsprite_val=record
    screen_x,screen_y:word;
    mask_x,mask_y:dword;
  end;

var
  sprite_val:tsprite_val;
  screen_sprites:array[0..1,0..(MAX_SCREEN_SPRITE-1),0..(MAX_SCREEN_SPRITE-1)] of word;

procedure draw_sprites(spri_pri,final_screen:byte);
procedure clear_sprites(spri_pri:byte);
procedure put_sprite(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;x_pos,y_pos:word;spri_pri:byte);
procedure sprites_init(sprite_end_x,sprite_end_y,sprite_mask_x,sprite_mask_y:word);

implementation
uses main_engine;

procedure clear_sprites(spri_pri:byte);
begin
  fillword(@screen_sprites[spri_pri],MAX_SCREEN_SPRITE*MAX_SCREEN_SPRITE,set_trans_color);
end;

procedure draw_sprites(spri_pri,final_screen:byte);
var
  y:word;
begin
  for y:=0 to sprite_val.screen_y-1 do putpixel(0,y,sprite_val.screen_x,@screen_sprites[spri_pri,y,0],pant_sprites_plus);
  actualiza_trozo(0,0,sprite_val.screen_x,sprite_val.screen_y,pant_sprites_plus,0,0,sprite_val.screen_x,sprite_val.screen_y,final_screen);
end;

procedure sprites_init(sprite_end_x,sprite_end_y,sprite_mask_x,sprite_mask_y:word);
begin
  sprite_val.screen_x:=sprite_end_x;
  sprite_val.screen_y:=sprite_end_y;
  sprite_val.mask_x:=sprite_mask_x;
  sprite_val.mask_y:=sprite_mask_y;
end;

procedure put_sprite(nchar:dword;color:word;flipx,flipy:boolean;ngfx:byte;x_pos,y_pos:word;spri_pri:byte);
var
  x,y,pos_x,pos_y,cant_x,cant_y,init_x:byte;
  pos:pbyte;
  dir_x,dir_y:integer;
begin
x_pos:=x_pos and sprite_val.mask_x;
y_pos:=y_pos and sprite_val.mask_y;
pos:=gfx[ngfx].datos;
cant_x:=gfx[ngfx].x-1;
cant_y:=gfx[ngfx].y-1;
inc(pos,nchar*gfx[ngfx].x*gfx[ngfx].y);
if flipy then begin
  pos_y:=cant_y;
  dir_y:=-1;
end else begin
  pos_y:=0;
  dir_y:=1;
end;
if flipx then begin
  init_x:=cant_x;
  dir_x:=-1;
end else begin
  init_x:=0;
  dir_x:=1;
end;
for y:=0 to cant_y do begin
  pos_x:=init_x;
  for x:=0 to cant_x do begin
    if not(gfx[ngfx].trans[pos^]) then screen_sprites[spri_pri,pos_y+y_pos,pos_x+x_pos]:=paleta[gfx[ngfx].colores[pos^+color]];
    inc(pos);
    pos_x:=pos_x+dir_x;
  end;
  pos_y:=pos_y+dir_y;
end;
end;

end.
