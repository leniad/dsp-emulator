unit k051316;

interface
uses gfx_engine,main_engine;

type
     t_k051316_cb=procedure(var code:word;var color:word;var priority_mask:word);
     k051316_chip=class
              constructor create(pant,ngfx:byte;call_back:t_k051316_cb;rom:pbyte;rom_size:dword;tipo:byte);
              destructor free;
          public
              procedure reset;
              function read(direccion:word):byte;
              function rom_read(direccion:word):byte;
              procedure write(direccion:word;valor:byte);
              procedure draw(screen:byte;dest_x,dest_y,draw_w,draw_h:word;screen_x,screen_y:integer);
              procedure control_w(direccion,valor:byte);
              procedure wraparound_enable(status:boolean);
              procedure clean_video_buffer;
          private
              ram:array[0..$7ff] of byte;
              rom:pbyte;
              control:array[0..$f] of byte;
              rom_size,rom_mask:dword;
              k051316_cb:t_k051316_cb;
              color_type,pant,ngfx,pixels_per_byte:byte;
              wraparound:boolean;
     end;

const
  BPP4=0;
  BPP7=1;

var
   k051316_0:k051316_chip;

implementation
uses pal_engine;

constructor k051316_chip.create(pant,ngfx:byte;call_back:t_k051316_cb;rom:pbyte;rom_size:dword;tipo:byte);
const
  pc_x_4:array[0..15] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4,
		8*4, 9*4, 10*4, 11*4, 12*4, 13*4, 14*4, 15*4);
  pc_y_4:array[0..15] of dword=(0*64, 1*64, 2*64, 3*64, 4*64, 5*64, 6*64, 7*64,
		8*64, 9*64, 10*64, 11*64, 12*64, 13*64, 14*64, 15*64);
  pc_x_7:array[0..15] of dword=(0*8, 1*8, 2*8, 3*8, 4*8, 5*8, 6*8, 7*8,
		8*8, 9*8, 10*8, 11*8, 12*8, 13*8, 14*8, 15*8);
  pc_y_7:array[0..15] of dword=(0*128, 1*128, 2*128, 3*128, 4*128, 5*128, 6*128, 7*128,
		8*128, 9*128, 10*128, 11*128, 12*128, 13*128, 14*128, 15*128);
begin
  self.pant:=pant;
  self.rom:=rom;
  self.rom_size:=rom_size;
  self.rom_mask:=rom_size-1;
  self.k051316_cb:=call_back;
  self.ngfx:=ngfx;
  case tipo of
    BPP4:begin
        init_gfx(ngfx,16,16,rom_size div 128);
        gfx_set_desc_data(4,0,8*128,0,1,2,3);
        convert_gfx(ngfx,0,rom,@pc_x_4,@pc_y_4,false,false);
        self.pixels_per_byte:=2;
        self.color_type:=4;
      end;
    BPP7:begin
        init_gfx(ngfx,16,16,rom_size div 256);
        gfx_set_desc_data(7,0,8*256,1,2,3,4,5,6,7);
        convert_gfx(ngfx,0,rom,@pc_x_7,@pc_y_7,false,false);
        self.pixels_per_byte:=1;
        self.color_type:=7;
      end;
  end;
  gfx[ngfx].trans[0]:=true;
end;

destructor k051316_chip.free;
begin
end;

procedure k051316_chip.reset;
begin
  fillchar(self.control,$10,0);
  self.wraparound:=false;
  self.clean_video_buffer;
end;

procedure k051316_chip.clean_video_buffer;
begin
  fillchar(gfx[self.ngfx].buffer,$400,1);
end;

function k051316_chip.rom_read(direccion:word):byte;
var
  addr:dword;
begin
  if ((self.control[$e] and $1)=0) then begin
		addr:=direccion+(self.control[$0c] shl 11)+(self.control[$0d] shl 19);
		addr:=(addr div self.pixels_per_byte) and self.rom_mask;
		rom_read:=self.rom[addr];
	end else rom_read:=0;
end;

procedure k051316_chip.control_w(direccion,valor:byte);
var
  offset:byte;
begin
  offset:=direccion and $f;
  if (offset=$e) and (((self.control[offset] xor valor) and $06)<>0) then
    self.clean_video_buffer;
  self.control[offset]:=valor;
end;

procedure k051316_chip.wraparound_enable(status:boolean);
begin
  self.wraparound:=status;
end;

function k051316_chip.read(direccion:word):byte;
begin
  read:=self.ram[direccion];
end;

procedure k051316_chip.write(direccion:word;valor:byte);
begin
  self.ram[direccion]:=valor;
  gfx[self.ngfx].buffer[direccion and $3ff]:=true;
end;

procedure k051316_chip.draw(screen:byte;dest_x,dest_y,draw_w,draw_h:word;screen_x,screen_y:integer);
var
  f,color,nchar,pri:word;
  x,y:byte;
  raw_color:byte;
  flipx,flipy:boolean;
  startx,starty,incxx,incxy,incyx,incyy:integer;
  dx,dy,sx,sy,src_pitch,dst_pitch,dst_offset:integer;
  affine_x,affine_y:int64;
  src_line,dst_line,p_src,p_dst:pword;
  trans_color:word;
begin
// Regenerate modified tiles. Color bits 6/7 select flips only when control
// register $0e enables them; preserve them before the board callback consumes
// the board-specific color attribute.
pri:=0;
for f:=0 to $3ff do begin
  if gfx[self.ngfx].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    raw_color:=self.ram[f+$400];
    color:=raw_color;
    nchar:=self.ram[f];
    flipx:=((self.control[$e] and $02)<>0) and ((raw_color and $40)<>0);
    flipy:=((self.control[$e] and $04)<>0) and ((raw_color and $80)<>0);
    self.k051316_cb(nchar,color,pri);
    put_gfx_trans_flip(x*16,y*16,nchar,color shl self.color_type,self.pant,self.ngfx,flipx,flipy);
    gfx[self.ngfx].buffer[f]:=false;
  end;
end;
// Registers are signed 16-bit values. The two counter registers have eight
// fractional bits; the four increments are signed 8.8 values.
startx:=smallint((self.control[0] shl 8) or self.control[1])*256;
starty:=smallint((self.control[6] shl 8) or self.control[7])*256;
incxx:=smallint((self.control[$02] shl 8) or self.control[$03]);
incyx:=smallint((self.control[$04] shl 8) or self.control[$05]);
incxy:=smallint((self.control[$08] shl 8) or self.control[$09]);
incyy:=smallint((self.control[$0a] shl 8) or self.control[$0b]);
// Match MAME's K051316 zoom_draw alignment for default offsets (dx=dy=0).
startx:=startx-(16*incyx)+7*incxx;
starty:=starty-(16*incyy)+7*incxy;
if (draw_w=0) or (draw_h=0) or (pantalla[self.pant]=nil) or (pantalla[screen]=nil) then exit;
src_pitch:=pantalla[self.pant].pitch shr 1;
dst_pitch:=pantalla[screen].pitch shr 1;
trans_color:=paleta[MAX_COLORES];
for dy:=0 to draw_h-1 do begin
  dst_offset:=(dest_y+dy)*dst_pitch+dest_x;
  if p_final[screen].final_mix then inc(dst_offset,ADD_SPRITE*dst_pitch+ADD_SPRITE);
  if (dest_y+dy>=pantalla[screen].h) then continue;
  dst_line:=pantalla[screen].pixels;
  inc(dst_line,dst_offset);
  affine_y:=int64(starty)+int64(screen_y+dy)*incyy+int64(screen_x)*incxy;
  affine_x:=int64(startx)+int64(screen_y+dy)*incyx+int64(screen_x)*incxx;
  for dx:=0 to draw_w-1 do begin
    // MAME passes all matrix values to tilemap::draw_roz shifted left by 5;
    // the source coordinate is therefore fixed point with 11 fractional bits.
    if affine_x>=0 then sx:=affine_x div 2048
      else sx:=-(((-affine_x)+2047) div 2048);
    if affine_y>=0 then sy:=affine_y div 2048
      else sy:=-(((-affine_y)+2047) div 2048);
    if self.wraparound then begin
      sx:=sx and $1ff;
      sy:=sy and $1ff;
    end;
    if (sx>=0) and (sx<512) and (sy>=0) and (sy<512) and (dest_x+dx<pantalla[screen].w) then begin
      src_line:=pantalla[self.pant].pixels;
      inc(src_line,sy*src_pitch);
      p_src:=src_line;
      inc(p_src,sx);
      p_dst:=dst_line;
      inc(p_dst,dx);
      if p_src^<>trans_color then p_dst^:=p_src^;
    end;
    inc(affine_x,incxx);
    inc(affine_y,incxy);
  end;
end;
end;

end.
