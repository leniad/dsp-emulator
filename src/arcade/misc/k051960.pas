unit k051960;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}gfx_engine;

type
  t_k051960_cb=procedure(var code:word;var color:word;var pri:word;var shadow:word);
  k051960_chip=class
      constructor create(pant:byte;spr_rom:pbyte;spr_size:dword;call_back:t_k051960_cb);
      destructor free;
    public
      procedure reset;
      function read(direccion:word):byte;
      procedure write(direccion:word;valor:byte);
      function k051937_read(direccion:word):byte;
      procedure k051937_write(direccion:word;valor:byte);
      procedure draw_sprites(min_priority,max_priority:integer);
    private
      ram:array[0..$3ff] of byte;
      counter,pant:byte;
      readroms,irq_enabled,nmi_enabled,spriteflip:boolean;
      romoffset:word;
      spriterombank:array[0..2] of byte;
      sprite_rom:pbyte;
      sprite_size:dword;
      k051960_cb:t_k051960_cb;
      function fetchromdata(direccion:word):byte;
    end;

var
  k051960_0:k051960_chip;

implementation

procedure k051960_chip.reset;
begin
  self.counter:=0;
	self.romoffset:=0;
	self.spriteflip:=false;
	self.readroms:=false;
	self.irq_enabled:=false;
	self.nmi_enabled:=false;
	self.spriterombank[0]:=0;
	self.spriterombank[1]:=0;
	self.spriterombank[2]:=0;
end;

constructor k051960_chip.create(pant:byte;spr_rom:pbyte;spr_size:dword;call_back:t_k051960_cb);
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
		8*32+0, 8*32+1, 8*32+2, 8*32+3, 8*32+4, 8*32+5, 8*32+6, 8*32+7);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
		16*32, 17*32, 18*32, 19*32, 20*32, 21*32, 22*32, 23*32);
begin
  self.sprite_rom:=spr_rom;
  self.sprite_size:=spr_size;
  self.k051960_cb:=call_back;
  self.pant:=pant;
  init_gfx(1,16,16,sprite_size div 128);
  gfx_set_desc_data(4,0,8*128,24,16,8,0);
  convert_gfx(1,0,spr_rom,@ps_x[0],@ps_y[0],false,false);
  gfx[1].trans[0]:=true;
end;

destructor k051960_chip.free;
begin
end;

function k051960_chip.fetchromdata(direccion:word):byte;
var
  code,color,pri,shadow:word;
  addr:dword;
  off1:byte;
begin
	addr:=self.romoffset+(self.spriterombank[0] shl 8)+((self.spriterombank[1] and $03) shl 16);
	code:=(addr and $3ffe0) shr 5;
	off1:=addr and $1f;
	color:=((self.spriterombank[1] and $fc) shr 2)+((self.spriterombank[2] and $03) shl 6);
	pri:=0;
	shadow:=color and $80;
	self.k051960_cb(code,color,pri,shadow);
	addr:=(code shl 7) or (off1 shl 2) or direccion;
	addr:=addr and (self.sprite_size-1);
	fetchromdata:=self.sprite_rom[addr];
end;

function k051960_chip.read(direccion:word):byte;
begin
	if self.readroms then begin
		// the 051960 remembers the last address read and uses it when reading the sprite ROMs */
		self.romoffset:=(direccion and $3fc) shr 2;
		read:=self.fetchromdata(direccion and 3);    // only 88 Games reads the ROMs from here */
	end else read:=self.ram[direccion];
end;

procedure k051960_chip.write(direccion:word;valor:byte);
begin
	self.ram[direccion]:=valor;
end;

// should this be split by k051960? */
function k051960_chip.k051937_read(direccion:word):byte;
begin
  k051937_read:=0;
	if (self.readroms and (direccion>=4) and (direccion<8)) then begin
		k051937_read:=self.fetchromdata(direccion and 3);
	end else if (direccion=0) then begin
		// some games need bit 0 to pulse */
		k051937_read:=self.counter and 1;
    self.counter:=self.counter+1;
  end;
end;

procedure k051960_chip.k051937_write(direccion:word;valor:byte);
begin
	if (direccion=0) then begin
		//if (data & 0xc2) popmessage("051937 reg 00 = %02x",data);
		// bit 0 is IRQ enable */
		self.irq_enabled:=(valor and $01)<>0;
		// bit 1: probably FIRQ enable */
		// bit 2 is NMI enable */
		self.nmi_enabled:=(valor and $04)<>0;
		// bit 3 = flip screen */
		self.spriteflip:=(valor and $08)<>0;
		// bit 4 used by Devastators and TMNT, unknown */
		// bit 5 = enable gfx ROM reading */
		self.readroms:=(valor and $20)<>0;
		//logerror("%04x: write %02x to 051937 address %x\n", machine().cpu->safe_pc(), data, offset);
	end else if (direccion=1) then begin
//  popmessage("%04x: write %02x to 051937 address %x", machine().cpu->safe_pc(), data, offset);
//logerror("%04x: write %02x to unknown 051937 address %x\n", machine().cpu->safe_pc(), data, offset);
	  end else if ((direccion>=2) and (direccion<5)) then begin
		  self.spriterombank[direccion-2]:=valor;
    end else begin
	      //  popmessage("%04x: write %02x to 051937 address %x", machine().cpu->safe_pc(), data, offset);
	      //logerror("%04x: write %02x to unknown 051937 address %x\n", machine().cpu->safe_pc(), data, offset);
	    end;
end;

procedure k051960_chip.draw_sprites(min_priority,max_priority:integer);
const
  NUM_SPRITES=128;
  { sprites can be grouped up to 8x8. The draw order is
		     0  1  4  5 16 17 20 21
		     2  3  6  7 18 19 22 23
		     8  9 12 13 24 25 28 29
		    10 11 14 15 26 27 30 31
		    32 33 36 37 48 49 52 53
		    34 35 38 39 50 51 54 55
		    40 41 44 45 56 57 60 61
		    42 43 46 47 58 59 62 63 }
		xoffset:array[0..7] of byte=(0,1,4,5,16,17,20,21);
		yoffset:array[0..7] of byte=(0,2,8,10,32,34,40,42);
		width:array[0..7] of byte=(1,2,1,2,4,2,4,8);
		height:array[0..7] of byte=(1,1,2,2,2,4,4,8);
var
  drawmode_table:array[0..255] of byte;
  sortedlist:array[0..(NUM_SPRITES)-1] of integer;
  offs,pri_code:integer;
  ox,oy,size,w,h,x,y,zoomx,zoomy,sx,sy,zw,zh:integer;
  c,nchar,color,pri,shadow:word;
  flipx,flipy:boolean;
begin
	//memset(drawmode_table, DRAWMODE_SOURCE, sizeof(drawmode_table));
	//drawmode_table[0] = DRAWMODE_NONE;
	for offs:=0 to (NUM_SPRITES-1) do sortedlist[offs]:=-1;
	// prebuild a sorted table */
	for offs:=0 to $7f do begin
		if (self.ram[offs*8] and $80)<>0 then begin
			if (max_priority=-1) then sortedlist[(self.ram[offs*8] and $7f) xor $7f]:=offs*8 // draw front to back when using priority buffer */
			else sortedlist[self.ram[offs*8] and $7f]:=offs*8;
		end;
	end;
	for pri_code:=0 to (NUM_SPRITES-1) do begin
		offs:=sortedlist[pri_code];
		if (offs=-1) then continue;
		nchar:=self.ram[offs+2]+((self.ram[offs+1] and $1f) shl 8);
		color:=self.ram[offs+3] and $ff;
		pri:=0;
		shadow:=color and $80;
		self.k051960_cb(nchar,color,pri,shadow);
		if (max_priority<>-1) then
			if ((pri<min_priority) or (pri>max_priority)) then continue;
		size:=(self.ram[offs+1] and $e0) shr 5;
		w:=width[size];
		h:=height[size];
		if (w>=2) then nchar:=nchar and $fffe;
		if (h>=2) then nchar:=nchar and $fffd;
		if (w>=4) then nchar:=nchar and $fffb;
		if (h>=4) then nchar:=nchar and $fff7;
		if (w>=8) then nchar:=nchar and $ffef;
		if (h>=8) then nchar:=nchar and $ffdf;
		ox:=(256*self.ram[offs+6]+self.ram[offs+7]) and $01ff;
		oy:=256-((256*self.ram[offs+4]+self.ram[offs+5]) and $01ff);
		flipx:=(self.ram[offs+6] and $02)<>0;
		flipy:=(self.ram[offs+4] and $02)<>0;
		zoomx:=(self.ram[offs+6] and $fc) shr 2;
		zoomy:=(self.ram[offs+4] and $fc) shr 2;
		zoomx:=$10000 div 128*(128-zoomx);
		zoomy:=$10000 div 128*(128-zoomy);
		if self.spriteflip then begin
			ox:=512-((zoomx*w) shr 12)-ox;
			oy:=256-((zoomy*h) shr 12)-oy;
			flipx:=not flipx;
			flipy:=not flipy;
    end;
		//drawmode_table[m_gfx[0]->granularity() - 1] = shadow ? DRAWMODE_SHADOW : DRAWMODE_SOURCE;
		if ((zoomx=$10000) and (zoomy=$10000)) then begin
			for y:=0 to (h-1) do begin
				sy:=oy+16*y;
				for x:=0 to (w-1) do begin
					c:=nchar;
					sx:=ox+16*x;
					if flipx then c:=c+xoffset[w-1-x]
					  else c:=c+xoffset[x];
					if flipy then c:=c+yoffset[h-1-y]
					  else c:=c+yoffset[y];
          put_gfx_sprite(c,color shl 4,flipx,flipy,1);
          actualiza_gfx_sprite(sx and $1ff,sy and $1ff,self.pant,1);
					{if (max_priority=-1) then
						m_gfx[0]->prio_transtable(bitmap,cliprect,
								c,color,
								flipx,flipy,
								sx & 0x1ff,sy,
								priority_bitmap,pri,
								drawmode_table);
					else
						m_gfx[0]->transtable(bitmap,cliprect,
								c,color,
								flipx,flipy,
								sx & 0x1ff,sy,
								drawmode_table);}
				end;
			end;
		end	else begin
			for y:=0 to (h-1) do begin
				sy:=oy+((zoomy*y+(1 shl 11)) shr 12);
				zh:=(oy+((zoomy*(y+1)+(1 shl 11)) shr 12))-sy;
				for x:=0 to (w-1) do begin
					c:=nchar;
					sx:=ox+((zoomx*x+(1 shl 11)) shr 12);
					zw:=(ox+((zoomx*(x+1)+(1 shl 11)) shr 12))-sx;
					if flipx then c:=c+xoffset[w-1-x]
					  else c:=c+xoffset[x];
					if flipy then c:=c+yoffset[h-1-y]
					  else c:=c+yoffset[y];
          put_gfx_sprite(c,color shl 4,flipx,flipy,1);
          actualiza_gfx_sprite(sx and $1ff,sy and $1ff,self.pant,1);
					{if (max_priority == -1)
						m_gfx[0]->prio_zoom_transtable(bitmap,cliprect,
								c,color,
								flipx,flipy,
								sx & 0x1ff,sy,
								(zw << 16) / 16,(zh << 16) / 16,
								priority_bitmap,pri,
								drawmode_table);
					else
						m_gfx[0]->zoom_transtable(bitmap,cliprect,
								c,color,
								flipx,flipy,
								sx & 0x1ff,sy,
								(zw << 16) / 16,(zh << 16) / 16,
								drawmode_table);}
				end;
			end;
		end;
	end;
end;

end.
