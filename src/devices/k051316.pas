unit k051316;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}gfx_engine,main_engine;

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
              procedure draw(screen:byte);
              procedure control_w(direccion,valor:byte);
              procedure clean_video_buffer;
          private
              ram:array[0..$7ff] of byte;
              rom:pbyte;
              control:array[0..$f] of byte;
              rom_size,rom_mask:dword;
              k051316_cb:t_k051316_cb;
              color_type,pant,ngfx,pixels_per_byte:byte;
     end;

const
  BPP4=0;
  BPP7=1;

var
   k051316_0:k051316_chip;

implementation

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
begin
  self.control[direccion and $f]:=valor;
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

procedure k051316_chip.draw(screen:byte);
var
  f,color,nchar,pri:word;
  x,y:byte;
  startx,starty,incxx,incxy,incyx,incyy:integer;
begin
pri:=0;
for f:=0 to $3ff do begin //Background
  if gfx[self.ngfx].buffer[f] then begin
    x:=f mod 32;
    y:=f div 32;
    color:=self.ram[f+$400];
    nchar:=self.ram[f];
    self.k051316_cb(nchar,color,pri);
    put_gfx_trans(x*16,y*16,nchar,color shl self.color_type,self.pant,self.ngfx);
    gfx[self.ngfx].buffer[f]:=false;
  end;
end;
startx:=smallint((self.control[0] shl 8)+self.control[1]) shl 8;
starty:=smallint((self.control[6] shl 8)+self.control[7]) shl 8;
incxx:=smallint(256*self.control[$02]+self.control[$03]);
incyx:=smallint(256*self.control[$04]+self.control[$05]);
incxy:=smallint(256*self.control[$08]+self.control[$09]);
incyy:=smallint(256*self.control[$0a]+self.control[$0b]);
startx:=startx-(16*incyx);
starty:=starty-(16*incyy);
startx:=startx-(89*incxx);
starty:=starty-(89*incxy);
//actualiza_trozo(0,0,512,512,self.pant,0,0,512,512,screen);
scroll_x_y(self.pant,screen,startx,starty);
end;

end.
