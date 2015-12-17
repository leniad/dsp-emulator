unit k053244_k053245;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}gfx_engine;

type
  t_k053245_cb=procedure(var code:word;var color:word;var priority:word);

procedure k053245_init(spr_rom:pbyte;spr_size:dword;call_back:t_k053245_cb);
procedure k053245_reset;
procedure k053245_bankselect(bank:byte);
function k053245_word_r(direccion:word):word;
procedure k053245_word_w(direccion,valor:word;part:byte);
function k053244_read(direccion:byte):byte;
procedure k053244_write(direccion,valor:byte);
procedure k05324x_sprites_draw(prioridad:byte);

var
  k053245_cb:t_k053245_cb;

implementation
var
  k053245_ram,buffer_ram:array[0..$7ff] of word;
  k053244_regs:array[0..$f] of byte;
  sprite_rom:pbyte;
  sprite_size:dword;
  rombank,z_rejection,dx,dy:byte;

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

procedure k053245_word_w(direccion,valor:word;part:byte);
begin
  case part of
    0:k053245_ram[direccion]:=(valor and $ff) or (k053245_ram[direccion] and $ff00);
    1:k053245_ram[direccion]:=(valor and $ff00) or (k053245_ram[direccion] and $ff);
    2:k053245_ram[direccion]:=valor;
  end;
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
		copymemory(@buffer_ram,@k053245_ram,$800*2);
		k053244_read:=0;
	end else begin
		k053244_read:=0;
	end;
end;

procedure k053244_write(direccion,valor:byte);
begin
  k053244_regs[direccion]:=valor;
  if direccion=6 then copymemory(@buffer_ram,@k053245_ram,$800*2);
end;

{ the following changes the sprite draw order from
		     0  1  4  5 16 17 20 21
		     2  3  6  7 18 19 22 23
		     8  9 12 13 24 25 28 29
		    10 11 14 15 26 27 30 31
		    32 33 36 37 48 49 52 53
		    34 35 38 39 50 51 54 55
		    40 41 44 45 56 57 60 61
		    42 43 46 47 58 59 62 63

		    to

		     0  1  2  3  4  5  6  7
		     8  9 10 11 12 13 14 15
		    16 17 18 19 20 21 22 23
		    24 25 26 27 28 29 30 31
		    32 33 34 35 36 37 38 39
		    40 41 42 43 44 45 46 47
		    48 49 50 51 52 53 54 55
		    56 57 58 59 60 61 62 63
		*/

		/* NOTE: from the schematics, it looks like the top 2 bits should be ignored */
		/* (there are not output pins for them), and probably taken from the "color" */
		/* field to do bank switching. However this applies only to TMNT2, with its */
		/* protection mcu creating the sprite table, so we don't know where to fetch */
		/* the bits from. }

procedure k05324x_sprites_draw(prioridad:byte);
const
  NUM_SPRITES=128;
var
	sortedlist:array[0..(NUM_SPRITES-1)] of integer;
  size,w,h,x,y:byte;
	pri_code,i,code,color,pri,spriteoffsX,spriteoffsY,c,ox,oy,sx,sy:word;
  flipscreenX,flipscreenY,flipx,flipy,mirrorx,mirrory,fx,fy:boolean;
	drawmode_table:array[0..255] of byte;
  offs,shadow,zoomx,zoomy:integer;
begin

	//memset(drawmode_table, DRAWMODE_SOURCE, sizeof(drawmode_table));
	//drawmode_table[0] = DRAWMODE_NONE;
	flipscreenX:=(k053244_regs[5] and $01)<>0;
	flipscreenY:=(k053244_regs[5] and $02)<>0;
	spriteoffsX:=(k053244_regs[0] shl 8) or k053244_regs[1];
	spriteoffsY:=(k053244_regs[2] shl 8) or k053244_regs[3];

	for offs:=0 to (NUM_SPRITES-1) do sortedlist[offs]:=-1;
	// prebuild a sorted table */
	for offs:=0 to $ff do begin
		pri_code:=buffer_ram[offs*8];
		if (pri_code and $8000)<>0 then begin
			pri_code:=pri_code and $007f;
			if (((offs*8)<>0) and (pri_code=z_rejection)) then continue;
			if (sortedlist[pri_code]=-1) then sortedlist[pri_code]:=offs*8;
		end;
	end;
	for pri_code:=0 to NUM_SPRITES-1 do begin
		offs:=sortedlist[pri_code];
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
		{ zoom control:
		   0x40 = normal scale
		  <0x40 enlarge (0x20 = double size)
		  >0x40 reduce (0x80 = half size) }
		zoomy:=buffer_ram[offs+4];
		if (zoomy>$2000) then continue;
		if (zoomy<>0) then zoomy:=($400000+zoomy div 2) div zoomy
		  else zoomy:=2*$400000;
		if ((buffer_ram[offs] and $4000)=0) then begin
			zoomx:=buffer_ram[offs+5];
			if (zoomx>$2000) then continue;
			if (zoomx<>0) then zoomx:=($400000+zoomx div 2) div zoomx
			  else zoomx:=2*$400000;
//          else zoomx = zoomy; /* workaround for TMNT2 */
		end else zoomx:=zoomy;
		ox:=buffer_ram[offs+3]+spriteoffsX;
		oy:=buffer_ram[offs+2];
		ox:=ox+dx;
		oy:=oy+dy;

		flipx:=(buffer_ram[offs] and $1000)<>0;
		flipy:=(buffer_ram[offs] and $2000)<>0;
		mirrorx:=(buffer_ram[offs+6] and $0100)<>0;
		if mirrorx then flipx:=false; // documented and confirmed

		mirrory:=(buffer_ram[offs+6] and $0200)<>0;
		shadow:=buffer_ram[offs+6] and $0080;
		if flipscreenX then begin
			ox:=512-ox;
			if not(mirrorx) then flipx:=not(flipx);
		end;
		if flipscreenY then begin
			oy:=-oy;
			if not(mirrory) then flipy:=not(flipy);
		end;
		ox:=(ox+$5d) and $3ff;
		if (ox>=768) then ox:=ox-1024;
		oy:=(-(oy+spriteoffsY+$07)) and $3ff;
		if (oy>=640) then oy:=oy-1024;

		// the coordinates given are for the *center* of the sprite */
		ox:=ox-((zoomx*w) shr 13);
		oy:=oy-((zoomy*h) shr 13);

		//drawmode_table[m_gfx[0]->granularity() - 1] = shadow ? DRAWMODE_SHADOW : DRAWMODE_SOURCE;

		for y:=0 to (h-1) do begin
			sy:=(oy+((zoomy*y+(1 shl 11)) shr 12)) and $3ff;
			for x:=0 to (w-1) do begin
				sx:=(ox+((zoomx*x+(1 shl 11)) shr 12)) and $3ff;
				c:=code;
				if mirrorx then begin
					if (not(flipx) xor (2*x<w)) then begin
						// mirror left/right */
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
						// mirror top/bottom */
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

				{ the sprite can start at any point in the 8x8 grid, but it must stay */
				/* in a 64 entries window, wrapping around at the edges. The animation */
				/* at the end of the saloon level in Sunset Riders breaks otherwise.}
				c:=(c and $3f) or (code and not($3f));
				if ((zoomx=$10000) and (zoomy=$10000)) then begin
				{
					m_gfx[0]->prio_transtable(bitmap,cliprect,
							c,color,
							fx,fy,
							sx,sy,
							priority_bitmap,pri,
							drawmode_table);
				}
        put_gfx_sprite(c and $3fff,color shl 4,fx,fy,1);
        actualiza_gfx_sprite(sx,sy,4,1);
				end else begin
				{
					m_gfx[0]->prio_zoom_transtable(bitmap,cliprect,
							c,color,
							fx,fy,
							sx,sy,
							(zw << 16) / 16,(zh << 16) / 16,
							priority_bitmap,pri,
							drawmode_table);

				}
        put_gfx_sprite_zoom(c and $3fff,color shl 4,fx,fy,1,1,1);
        actualiza_gfx_sprite(sx,sy,4,1);
        end;
      end;
    end;
  end;
end;


end.
