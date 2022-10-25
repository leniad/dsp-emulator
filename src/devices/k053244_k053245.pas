unit k053244_k053245;

interface
uses {$IFDEF WINDOWS}windows,{$else}main_engine,{$ENDIF}gfx_engine;

const
  NUM_SPRITES=128;

type
  t_k053245_cb=procedure(var code:word;var color:word;var priority:word);

procedure k053245_init(spr_rom:pbyte;spr_size:dword;call_back:t_k053245_cb);
procedure k053245_reset;
procedure k053245_bankselect(bank:byte);
function k053245_word_r(direccion:word):word;
procedure k053245_word_w(direccion,valor:word);
procedure k053245_lsb_w(direccion,valor:word);
function k053244_read(direccion:byte):byte;
procedure k053244_write(direccion,valor:byte);
procedure k05324x_sprites_draw(prioridad:byte);
procedure k05324x_update_sprites;

var
  k053245_cb:t_k053245_cb;

implementation
var
  k053245_ram,buffer_ram:array[0..$3ff] of word;
  k053244_regs:array[0..$f] of byte;
  sprite_rom:pbyte;
  sprite_size:dword;
  rombank,z_rejection,dx,dy:byte;
  sorted_list:array[0..(NUM_SPRITES-1)] of integer;

procedure k053245_init(spr_rom:pbyte;spr_size:dword;call_back:t_k053245_cb);
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
		8*32+0, 8*32+1, 8*32+2, 8*32+3, 8*32+4, 8*32+5, 8*32+6, 8*32+7);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
		16*32, 17*32, 18*32, 19*32, 20*32, 21*32, 22*32, 23*32);
begin
  sprite_rom:=spr_rom;
  sprite_size:=spr_size;
  k053245_cb:=call_back;
  dx:=0;
  dy:=0;
  init_gfx(1,16,16,sprite_size div 128);
  gfx_set_desc_data(4,0,8*128,24,16,8,0);
  convert_gfx(1,0,spr_rom,@ps_x[0],@ps_y[0],false,false);
  gfx[1].trans[0]:=true;
  gfx[1].alpha[$f]:=true; //para shadow
end;

procedure k053245_reset;
var
  f:byte;
begin
  rombank:=0;
  z_rejection:=0;
	for f:=0 to $f do k053244_regs[f]:=0;
end;

procedure k053245_bankselect(bank:byte);
begin
	rombank:=bank;
end;

function k053245_word_r(direccion:word):word;
begin
  k053245_word_r:=k053245_ram[direccion];
end;

procedure k053245_word_w(direccion,valor:word);
begin
  k053245_ram[direccion]:=valor;
end;

procedure k053245_lsb_w(direccion,valor:word);
begin
  k053245_ram[direccion]:=(valor and $ff) or (k053245_ram[direccion] and $ff00);
end;

function k053244_read(direccion:byte):byte;
var
  addr:dword;
begin
  if (((k053244_regs[5] and $10)<>0) and (direccion>=$0c) and (direccion<$10)) then begin
		addr:=(rombank shl 19) or ((k053244_regs[11] and $7) shl 18)
			or (k053244_regs[8] shl 10) or (k053244_regs[9] shl 2)
			or ((direccion and 3) xor 1);
		addr:=addr and (sprite_size-1);
		k053244_read:=sprite_rom[addr];
	end else if (direccion=$06) then begin
		copymemory(@buffer_ram,@k053245_ram,$400*2);
		k053244_read:=0;
	end else begin
		k053244_read:=0;
	end;
end;

procedure k053244_write(direccion,valor:byte);
begin
  k053244_regs[direccion]:=valor;
  if direccion=6 then copymemory(@buffer_ram,@k053245_ram,$400*2);
end;

procedure k05324x_update_sprites;
var
  offs:byte;
  pri_code:word;
begin
for offs:=0 to (NUM_SPRITES-1) do sorted_list[offs]:=-1;
// prebuild a sorted table */
for offs:=0 to (NUM_SPRITES-1) do begin
		pri_code:=buffer_ram[offs*8];
		if (pri_code and $8000)<>0 then begin
			pri_code:=pri_code and $007f;
			if (((offs*8)<>0) and (pri_code=z_rejection)) then continue;
			if (sorted_list[pri_code]=-1) then sorted_list[pri_code]:=offs*8;
		end;
end;
end;

procedure k05324x_sprites_draw(prioridad:byte);
var
  size,w,h,x,y:byte;
	pri_code,code,color,pri,spriteoffsX,spriteoffsY,c,ox,oy,sx,sy,zoom_x,zoom_y:word;
  //flipscreenX,flipscreenY,
  flipx,flipy,mirrorx,mirrory,fx,fy,shadow:boolean;
  offs:integer;
  zx,zy:single;
begin
	//flipscreenX:=(k053244_regs[5] and $01)<>0;
	//flipscreenY:=(k053244_regs[5] and $02)<>0;
	spriteoffsX:=(k053244_regs[0] shl 8) or k053244_regs[1];
	spriteoffsY:=(k053244_regs[2] shl 8) or k053244_regs[3];
	for pri_code:=0 to NUM_SPRITES-1 do begin
		offs:=sorted_list[pri_code];
		if (offs=-1) then continue;
		code:=buffer_ram[offs+1];
		code:=((code and $ffe1)+((code and $0010) shr 2)+((code and $0008) shl 1)
					+((code and $0004) shr 1)+((code and $0002) shl 2));
		color:=buffer_ram[offs+6] and $00ff;
		pri:=0;
		if (@k053245_cb<>nil) then k053245_cb(code,color,pri);
    if pri<>prioridad then continue;
		size:=(buffer_ram[offs] and $0f00) shr 8;
		w:=1 shl (size and $03);
		h:=1 shl ((size shr 2) and $03);
		zoom_y:=buffer_ram[offs+4];
    if (zoom_y and $ff)<>0 then zy:=$40/(zoom_y and $ff)
      else zy:=0;
		if (zoom_y>$2000) then continue;
		if ((buffer_ram[offs] and $4000)=0) then begin
			zoom_x:=buffer_ram[offs+5];
      if (zoom_x and $ff)<>0 then zx:=$40/(zoom_x and $ff)
        else zx:=0;
			if (zoom_x>$2000) then continue;
		end else zx:=zy;
		ox:=(buffer_ram[offs+3]+spriteoffsX+$5d) and $3ff;
		oy:=(-(buffer_ram[offs+2]+spriteoffsY+$07)) and $3ff;
		ox:=ox+dx;
		oy:=oy+dy;
		flipx:=(buffer_ram[offs] and $1000)<>0;
		flipy:=(buffer_ram[offs] and $2000)<>0;
		mirrorx:=(buffer_ram[offs+6] and $0100)<>0;
		if mirrorx then flipx:=false; // documented and confirmed
		mirrory:=(buffer_ram[offs+6] and $0200)<>0;
		shadow:=(buffer_ram[offs+6] and $0080)<>0;
		// the coordinates given are for the *center* of the sprite
		ox:=ox-(round(zx*w*16) shr 1);
		oy:=oy-(round(zy*h*16) shr 1);
		for y:=0 to (h-1) do begin
			sy:=(oy+(round(zy*y*16))) and $3ff;
			for x:=0 to (w-1) do begin
				sx:=(ox+(round(zx*x*16))) and $3ff;
				c:=code;
				if mirrorx then begin
					if (not(flipx) xor (2*x<w)) then begin
						// mirror left/right
						c:=c+(w-x-1);
						fx:=true;
					end else begin
						c:=c+x;
						fx:=false;
          end;
				end else begin
					if flipx then c:=c+(w-1-x)
					  else c:=c+x;
					fx:=flipx;
				end;
				if mirrory then begin
					if (not(flipy) xor (2*y>=h)) then begin
						// mirror top/bottom
						c:=c+(8*(h-y-1));
						fy:=true;
					end else begin
						c:=c+(8*y);
						fy:=false;
					end;
				end else begin
					if flipy then c:=c+(8*(h-1-y))
					  else c:=c+(8*y);
					fy:=flipy;
				end;
				{ the sprite can start at any point in the 8x8 grid, but it must stay
				  in a 64 entries window, wrapping around at the edges. The animation
				  at the end of the saloon level in Sunset Riders breaks otherwise.}
				c:=(c and $3f) or (code and not($3f));
        if shadow then begin //alpha
          if ((zx=1) and (zy=1)) then begin
            put_gfx_sprite_alpha(c and $3fff,color shl 4,fx,fy,1);
            actualiza_gfx_sprite_alpha(sx,sy,4,1);
				  end else begin
            put_gfx_sprite_zoom_alpha(c and $3fff,color shl 4,fx,fy,1,zx,zy);
            actualiza_gfx_sprite_zoom_alpha(sx,sy,4,1,zx,zy);
          end;
        end else begin
				  if ((zx=1) and (zy=1)) then begin
            put_gfx_sprite(c and $3fff,color shl 4,fx,fy,1);
            actualiza_gfx_sprite(sx,sy,4,1);
				  end else begin
            put_gfx_sprite_zoom(c and $3fff,color shl 4,fx,fy,1,zx,zy);
            actualiza_gfx_sprite_zoom(sx,sy,4,1,zx,zy);
          end;
        end;
      end;
    end;
  end;
end;


end.
