unit kaneco_pandora;

interface
uses gfx_engine,misc_functions;

type
  pandora_gfx=class
    constructor create(color_offset:word;clear_screen:boolean);
    destructor free;
    public
      procedure reset;
      procedure update_video(screen,ngfx:byte);
      //Read/write 8 bits
      procedure spriteram_w8(offset:word;data:byte);
      function spriteram_r8(offset:word):byte;
      procedure spriteram_w16(offset:word;data:byte);
      function spriteram_r16(offset:word):byte;
    private
      sprite_ram:array[0..$fff] of byte;
      bg_color:byte;
      clear_screen:boolean;
      color_offset:word;
  end;

var
  pandora_0:pandora_gfx;

implementation

constructor pandora_gfx.create(color_offset:word;clear_screen:boolean);
begin
  self.color_offset:=color_offset;
  self.clear_screen:=clear_screen;
end;

destructor pandora_gfx.free;
begin
end;

procedure pandora_gfx.reset;
begin
  self.bg_color:=0;
  fillchar(self.sprite_ram,$1000,0);
end;

procedure pandora_gfx.update_video(screen,ngfx:byte);
var
  f,color,sx,sy,x,y,nchar,atrib:word;
begin
if self.clear_screen then fill_full_screen(screen,self.bg_color);
x:=0;
y:=0;
for f:=0 to $1ff do begin
  atrib:=self.sprite_ram[(f*8)+7];
  nchar:=((atrib and $3f) shl 8)+self.sprite_ram[(f*8)+6];
  sx:=self.sprite_ram[(f*8)+4];
	sy:=self.sprite_ram[(f*8)+5];
  color:=self.sprite_ram[(f*8)+3];
  sx:=sx+((color and 1) shl 8);
  sy:=sy+((color and 2) shl 7);
  if (color and 4)<>0 then begin
			x:=(x+sx) and $1ff;
			y:=(y+sy) and $1ff;
  end else begin
			x:=sx and $1ff;
			y:=sy and $1ff;
  end;
  if nchar=0 then continue;
  put_gfx_sprite(nchar,(color and $f0)+self.color_offset,(atrib and $80)<>0,(atrib and $40)<>0,ngfx);
  actualiza_gfx_sprite(x,y,screen,ngfx);
end;
end;

procedure pandora_gfx.spriteram_w8(offset:word;data:byte);
begin
	// it's either hooked up oddly on this, or on the 16-bit games
	// either way, we swap the address lines so that the spriteram is in the same format
	offset:=BITSWAP16(offset,15,14,13,12,11,7,6,5,4,3,2,1,0,10,9,8);
	self.sprite_ram[offset]:=data;
end;

function pandora_gfx.spriteram_r8(offset:word):byte;
begin
	offset:=BITSWAP16(offset,15,14,13,12,11,7,6,5,4,3,2,1,0,10,9,8);
	spriteram_r8:=self.sprite_ram[offset];
end;

procedure pandora_gfx.spriteram_w16(offset:word;data:byte);
begin
  self.sprite_ram[offset shr 1]:=data;
end;

function pandora_gfx.spriteram_r16(offset:word):byte;
begin
  spriteram_r16:=self.sprite_ram[offset shr 1];
end;

end.
