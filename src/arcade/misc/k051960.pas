unit k051960;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}gfx_engine;

type
  t_k051960_cb=procedure(var code:word;var color:word;var pri:word;var shadow:word);
  k051960_chip=class
      constructor create(pant:byte;spr_rom:pbyte;spr_size:dword;call_back:t_k051960_cb;tipo:byte=0);
      destructor free;
    public
      procedure reset;
      function read(direccion:word):byte;
      procedure write(direccion:word;valor:byte);
      function k051937_read(direccion:word):byte;
      procedure k051937_write(direccion:word;valor:byte);
      procedure draw_sprites(min_priority,max_priority:integer);
      function is_irq_enabled:boolean;
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

constructor k051960_chip.create(pant:byte;spr_rom:pbyte;spr_size:dword;call_back:t_k051960_cb;tipo:byte=0);
const
  ps_x:array[0..15] of dword=(0, 1, 2, 3, 4, 5, 6, 7,
		8*32+0, 8*32+1, 8*32+2, 8*32+3, 8*32+4, 8*32+5, 8*32+6, 8*32+7);
  ps_y:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
		16*32, 17*32, 18*32, 19*32, 20*32, 21*32, 22*32, 23*32);
  ps_x_gra3:array[0..15] of dword=(2*4, 3*4, 0*4, 1*4, 6*4, 7*4, 4*4, 5*4,
		32*8+2*4, 32*8+3*4, 32*8+0*4, 32*8+1*4, 32*8+6*4, 32*8+7*4, 32*8+4*4, 32*8+5*4);
  ps_y_gra3:array[0..15] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32,
		64*8+0*32, 64*8+1*32, 64*8+2*32, 64*8+3*32, 64*8+4*32, 64*8+5*32, 64*8+6*32, 64*8+7*32);
begin
  self.sprite_rom:=spr_rom;
  self.sprite_size:=spr_size;
  self.k051960_cb:=call_back;
  self.pant:=pant;
  init_gfx(1,16,16,sprite_size div 128);
  case tipo of
    0:begin
        gfx_set_desc_data(4,0,8*128,24,16,8,0);
        convert_gfx(1,0,spr_rom,@ps_x[0],@ps_y[0],false,false);
      end;
    1:begin
        gfx_set_desc_data(4,0,8*128,0,1,2,3);
        convert_gfx(1,0,spr_rom,@ps_x_gra3[0],@ps_y_gra3[0],false,false);
      end;
    2:begin
        gfx_set_desc_data(4,0,8*128,0,8,16,24);
        convert_gfx(1,0,spr_rom,@ps_x[0],@ps_y[0],false,false);
      end;
  end;
  gfx[1].trans[0]:=true;
  gfx[1].alpha[$f]:=true;
end;

destructor k051960_chip.free;
begin
end;

function k051960_chip.is_irq_enabled:boolean;
begin
  is_irq_enabled:=self.irq_enabled;
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
		xoffset:array[0..7] of byte=(0,1,4,5,16,17,20,21);
		yoffset:array[0..7] of byte=(0,2,8,10,32,34,40,42);
		width:array[0..7] of byte=(1,2,1,2,4,2,4,8);
		height:array[0..7] of byte=(1,1,2,2,2,4,4,8);
var
  sortedlist:array[0..(NUM_SPRITES)-1] of integer;
  offs:integer;
  size,w,h,x,y,pri_code:byte;
  c,nchar,color,pri,shadow,zoom_x,zoom_y,ox,oy,sx,sy:word;
  flipx,flipy:boolean;
  zx,zy:single;
begin
  for offs:=0 to (NUM_SPRITES)-1 do sortedlist[offs]:=-1;
	for offs:=0 to (NUM_SPRITES)-1 do
		if (self.ram[offs*8] and $80)<>0 then sortedlist[self.ram[offs*8] and $7f]:=offs*8;
	for pri_code:=0 to (NUM_SPRITES-1) do begin
		offs:=sortedlist[pri_code];
		if (offs=-1) then continue;
		nchar:=self.ram[offs+2]+((self.ram[offs+1] and $1f) shl 8);
		color:=self.ram[offs+3];
		pri:=0;
		shadow:=color and $80;
		self.k051960_cb(nchar,color,pri,shadow);
		if (max_priority<>-1) then begin //Prioridad por llamada
			if ((pri<min_priority) or (pri>max_priority)) then continue;
    end else begin //Prioridad por funcion
      if pri<>min_priority then continue;
    end;
		size:=(self.ram[offs+1] and $e0) shr 5;
		w:=width[size];
		h:=height[size];
		if (w>=2) then nchar:=nchar and $fffe;
		if (h>=2) then nchar:=nchar and $fffd;
		if (w>=4) then nchar:=nchar and $fffb;
		if (h>=4) then nchar:=nchar and $fff7;
		if (w>=8) then nchar:=nchar and $ffef;
		if (h>=8) then nchar:=nchar and $ffdf;
		ox:=(256*self.ram[offs+6]+self.ram[offs+7]) and $1ff;
		oy:=256-((256*self.ram[offs+4]+self.ram[offs+5]) and $1ff);
		flipx:=(self.ram[offs+6] and $02)<>0;
		flipy:=(self.ram[offs+4] and $02)<>0;
		zoom_x:=(self.ram[offs+6] and $fc) shr 2;
    zx:=($100-zoom_x)/$100;
		zoom_y:=(self.ram[offs+4] and $fc) shr 2;
    zy:=($100-zoom_y)/$100;
		if self.spriteflip then begin
			ox:=512-round(zx*w*16)-ox;
			oy:=256-round(zy*h*16)-oy;
			flipx:=not flipx;
			flipy:=not flipy;
    end;
    for y:=0 to (h-1) do begin
        sy:=oy+round(zy*y*16);
				for x:=0 to (w-1) do begin
					c:=nchar;
					sx:=ox+round(zx*x*16);
					if flipx then c:=c+xoffset[w-1-x]
					  else c:=c+xoffset[x];
					if flipy then c:=c+yoffset[h-1-y]
					  else c:=c+yoffset[y];
          if (shadow<>0) then begin
            if ((zx=1) and (zy=1)) then begin
              put_gfx_sprite_alpha(c,color shl 4,flipx,flipy,1);
              actualiza_gfx_sprite_alpha(sx,sy,self.pant,1);
            end else begin
              put_gfx_sprite_zoom_alpha(c,color shl 4,flipx,flipy,1,zx,zy);
              actualiza_gfx_sprite_zoom_alpha(sx,sy,self.pant,1,zx,zy);
            end;
          end else begin
            if ((zx=1) and (zy=1)) then begin
              put_gfx_sprite(c,color shl 4,flipx,flipy,1);
              actualiza_gfx_sprite(sx,sy,self.pant,1);
            end else begin
              put_gfx_sprite_zoom(c,color shl 4,flipx,flipy,1,zx,zy);
              actualiza_gfx_sprite_zoom(sx,sy,self.pant,1,zx,zy);
            end;
          end;
				end;
			end;
		end;
end;

end.
