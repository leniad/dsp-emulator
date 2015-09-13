unit kaneco_pandora;

interface
uses gfx_engine,misc_functions;

type
  pandora_type=record
    sprite_ram:array[0..$fff] of byte;
    bg_color:byte;
    clear_screen:boolean;
    mask_nchar:word;
    color_offset:word;
  end;

procedure pandora_reset;
procedure pandora_update_video(screen,ngfx:byte);
//Read/write 8 bits
procedure pandora_spriteram_w(offset:word;data:byte);
function pandora_spriteram_r(offset:word):byte;

var
  pandora:pandora_type;

implementation

procedure pandora_reset;
begin
  pandora.bg_color:=0;
  fillchar(pandora.sprite_ram[0],$1000,0);
end;

procedure pandora_update_video(screen,ngfx:byte);
var
  f:word;
  color:word;
  sx,sy,x,y,nchar,atrib:word;
begin
if pandora.clear_screen then fill_full_screen(screen,pandora.bg_color);
x:=0;
y:=0;
for f:=0 to $1ff do begin
  atrib:=pandora.sprite_ram[(f*8)+7];
  nchar:=((atrib and $3f) shl 8)+pandora.sprite_ram[(f*8)+6];
  sx:=pandora.sprite_ram[(f*8)+4];
	sy:=pandora.sprite_ram[(f*8)+5];
  color:=pandora.sprite_ram[(f*8)+3];
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
  put_gfx_sprite(nchar and pandora.mask_nchar,(color and $f0)+pandora.color_offset,(atrib and $80)<>0,(atrib and $40)<>0,ngfx);
  actualiza_gfx_sprite(x,y,screen,ngfx);
end;
end;

procedure pandora_spriteram_w(offset:word;data:byte);
begin
	// it's either hooked up oddly on this, or on the 16-bit games
	// either way, we swap the address lines so that the spriteram is in the same format
	offset:=BITSWAP16(offset,15,14,13,12,11,7,6,5,4,3,2,1,0,10,9,8);
	pandora.sprite_ram[offset]:=data;
end;

function pandora_spriteram_r(offset:word):byte;
begin
	offset:=BITSWAP16(offset,15,14,13,12,11,7,6,5,4,3,2,1,0,10,9,8);
	pandora_spriteram_r:=pandora.sprite_ram[offset];
end;

end.
