unit k052109;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,gfx_engine;

type
  t_k052109_cb=procedure(layer,bank:word;var code:dword;var color:word;var flags:word;var priority:word);
  k052109_chip=class
        constructor create(pant1,pant2,pant3:byte;call_back:t_k052109_cb;rom:pbyte;rom_size:dword);
        destructor free;
    public
        rmrd_line:byte;
        recalc_char:boolean;
        scroll_x:array[1..2,0..$ff] of word;
        scroll_y:array[1..2,0..$1ff] of byte;
        scroll_tipo:array[1..2] of byte;
        function read_msb(direccion:word):byte;
        function read_lsb(direccion:word):byte;
        function word_r(direccion:word):word;
        procedure word_w(direccion,valor:word);
        procedure write_msb(direccion:word;valor:byte);
        procedure write_lsb(direccion:word;valor:byte);
        function read(direccion:word):byte;
        procedure write(direccion:word;val:byte);
        procedure draw_tiles;
        procedure reset;
        function is_irq_enabled:boolean;
        procedure clean_video_buffer;
        procedure clean_video_buffer_layer(layer:byte);
        procedure set_rmrd_line(state:byte);
        function get_rmrd_line:byte;
        procedure draw_layer(layer,final_screen:byte);
    protected
        ram:array[0..$5fff] of byte;
        tileflip_enable,romsubbank,scrollctrl:byte;
        charrombank,charrombank_2:array[0..3] of byte;
        pant:array[0..2] of byte;
        irq_enabled,has_extra_video_ram:boolean;
        char_rom:pbyte;
        char_size,char_mask:dword;
        k052109_cb:t_k052109_cb;
        video_buffer:array[0..2,0..$7ff] of boolean;
        procedure recalc_chars;
        procedure update_all_tile(layer:byte);
        procedure calc_scroll_1;
        procedure calc_scroll_2;
  end;

var
  k052109_0:k052109_chip;

implementation

constructor k052109_chip.create(pant1,pant2,pant3:byte;call_back:t_k052109_cb;rom:pbyte;rom_size:dword);
const
  pc_x:array[0..7] of dword=(0, 1, 2, 3, 4, 5, 6, 7);
  pc_y:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
begin
  self.has_extra_video_ram:=false;
  self.pant[0]:=pant1;
  self.pant[1]:=pant2;
  self.pant[2]:=pant3;
  self.k052109_cb:=call_back;
  self.recalc_char:=false;
  self.char_rom:=rom;
  self.char_size:=rom_size;
  self.char_mask:=(rom_size div 32)-1;
  init_gfx(0,8,8,rom_size div 32);
  gfx_set_desc_data(4,0,8*32,24,16,8,0);
  convert_gfx(0,0,rom,@pc_x[0],@pc_y[0],false,false);
  gfx[0].trans[0]:=true;
end;

destructor k052109_chip.free;
begin
end;

procedure k052109_chip.clean_video_buffer;
var
  f:byte;
begin
for f:=0 to 2 do fillchar(self.video_buffer[f,0],$800,1);
end;

procedure k052109_chip.clean_video_buffer_layer(layer:byte);
begin
fillchar(self.video_buffer[layer,0],$800,1);
end;

procedure k052109_chip.reset;
var
  f:byte;
begin
	self.rmrd_line:=CLEAR_LINE;
	self.irq_enabled:=false;
	self.romsubbank:=0;
	self.scrollctrl:=0;
	self.has_extra_video_ram:=false;
  self.tileflip_enable:=0;
	for f:=0 to 3 do begin
		self.charrombank[f]:=0;
		self.charrombank_2[f]:=0;
	end;
  clean_video_buffer;
end;

function k052109_chip.read(direccion:word):byte;
var
  color,flags,priority,bank,addr:word;
  code:dword;
begin
	if (self.rmrd_line=CLEAR_LINE) then begin
		read:=self.ram[direccion];
	end else begin  // Punk Shot and TMNT read from 0000-1fff, Aliens from 2000-3fff */
	 //	assert (m_char_size != 0);
		code:=(direccion and $1fff) shr 5;
		color:=self.romsubbank;
		flags:=0;
		priority:=0;
		bank:=self.charrombank[(color and $0c) shr 2] shr 2;   // discard low bits (TMNT) */
		bank:=bank or (self.charrombank_2[(color and $0c) shr 2] shr 2); // Surprise Attack uses this 2nd bank in the rom test
	  if self.has_extra_video_ram then code:=code or (color shl 8) // kludge for X-Men */
	    else k052109_cb(0,bank,code,color,flags,priority);
		addr:=(code shl 5)+(direccion and $1f);
		addr:=addr and (char_size-1);
//      logerror("%04x: off = %04x sub = %02x (bnk = %x) adr = %06x\n", space.device().safe_pc(), offset, m_romsubbank, bank, addr);
		read:=self.char_rom[addr];
	end;
end;

procedure k052109_chip.write(direccion:word;val:byte);
var
  bank,dirty:byte;
  i:word;
begin
if ((direccion and $1fff)<$1800) then begin // tilemap RAM */
		if (direccion>=$4000) then self.has_extra_video_ram:=true;  // kludge for X-Men */
		self.ram[direccion]:=val;
    self.video_buffer[(direccion and $1800) shr 11,direccion and $7ff]:=true;
end	else begin   // control registers
		self.ram[direccion]:=val;
    case direccion of
      $1c80:self.scrollctrl:=val;
      $1d00:self.irq_enabled:=(val and $04)<>0; // bit 2 = irq enable * the custom chip can also generate NMI and FIRQ, for use with a 6809 */
      $1d80:begin
              dirty:=0;
			        if (self.charrombank[0]<>(val and $0f)) then dirty:=dirty or 1;
			        if (self.charrombank[1]<>((val shr 4) and $0f)) then dirty:=dirty or 2;
			        if (dirty<>0) then begin
				        self.charrombank[0]:=val and $0f;
				        self.charrombank[1]:=(val shr 4) and $0f;
                for i:=0 to $17ff do begin
				        	  bank:=(self.ram[i] and $0c) shr 2;
				          	if (((bank=0) and ((dirty and 1)<>0)) or ((bank=1) and ((dirty and 2)<>0))) then
                      self.video_buffer[(direccion and $1800) shr 11,direccion and $7ff]:=true;
			          end;
              end;
            end;
      $1e00,$3e00:self.romsubbank:=val; // Surprise Attack uses offset 0x3e00
      $1e80:begin
                main_screen.flip_main_screen:=(val and 1)<>0;
			          if (self.tileflip_enable<>((val and $06) shr 1)) then begin
				          self.tileflip_enable:=((val and $06) shr 1);
                  clean_video_buffer;
			          end;
            end;
      $1f00:begin
                dirty:=0;
			          if (self.charrombank[2]<>(val and $0f)) then dirty:=dirty or 1;
			          if (self.charrombank[3]<>((val shr 4) and $0f)) then dirty:=dirty or 2;
			          if (dirty<>0) then begin
				          self.charrombank[2]:=val and $0f;
				          self.charrombank[3]:=(val shr 4) and $0f;
                  for i:=0 to $17ff do begin
				        	  bank:=(self.ram[i] and $0c) shr 2;
				          	if (((bank=2) and ((dirty and 1)<>0)) or ((bank=3) and ((dirty and 2)<>0))) then
                      self.video_buffer[(direccion and $1800) shr 11,direccion and $7ff]:=true;
			            end;
			          end;
            end;
      $3d80:begin // Surprise Attack uses offset 0x3d80 in rom test
			            // mirroring this write, breaks Surprise Attack in game tilemaps
                self.charrombank_2[0]:=val and $0f;
			          self.charrombank_2[1]:=(val shr 4) and $0f;
            end;
      $3f00:begin // Surprise Attack uses offset 0x3f00 in rom test
			// mirroring this write, breaks Surprise Attack in game tilemaps
			          self.charrombank_2[2]:=val and $0f;
			          self.charrombank_2[3]:=(val shr 4) and $0f;
            end;
    end;
end;
end;

function k052109_chip.read_msb(direccion:word):byte;
begin
  read_msb:=self.read(direccion+$2000);
end;

function k052109_chip.read_lsb(direccion:word):byte;
begin
  read_lsb:=self.read(direccion);
end;

function k052109_chip.word_r(direccion:word):word;
begin
word_r:=self.read(direccion+$2000)+self.read(direccion) shl 8;
end;

procedure k052109_chip.word_w(direccion,valor:word);
begin
self.write(direccion+$2000,valor and $ff);
self.write(direccion,valor shr 8);
end;

procedure k052109_chip.write_msb(direccion:word;valor:byte);
begin
  self.write(direccion+$2000,valor)
end;

procedure k052109_chip.write_lsb(direccion:word;valor:byte);
begin
  self.write(direccion,valor);
end;

function k052109_chip.is_irq_enabled:boolean;
begin
  is_irq_enabled:=self.irq_enabled;
end;

procedure k052109_chip.set_rmrd_line(state:byte);
begin
     self.rmrd_line:=state;
end;

function k052109_chip.get_rmrd_line:byte;
begin
     get_rmrd_line:=self.rmrd_line;
end;

procedure k052109_chip.update_all_tile(layer:byte);
var
  f,pos_x,pos_y,bank,flags,priority,color:word;
  flip_x,flip_y,old_flip_y:boolean;
  nchar:dword;
begin
for f:=0 to $7ff do begin
  pos_x:=f mod 64;
  pos_y:=f div 64;
  if video_buffer[layer,f] then begin
	  nchar:=self.ram[$2000+f+($800*layer)]+256*self.ram[$4000+f+($800*layer)];
	  color:=self.ram[f+($800*layer)];
	  flags:=0;
	  priority:=0;
	  bank:=self.charrombank[(color and $0c) shr 2];
	  if self.has_extra_video_ram then bank:=(color and $0c) shr 2; // kludge for X-Men */
	  color:=(color and $f3) or ((bank and $03) shl 2);
	  bank:=bank shr 2;
    old_flip_y:=(color and $02)<>0;
	  self.k052109_cb(layer,bank,nchar,color,flags,priority);
	  // if the callback set flip X but it is not enabled, turn it off */
	  if ((self.tileflip_enable and 1)=0) then flip_x:=false
      else flip_x:=(flags and 1)<>0;
	  // if flip Y is enabled and the attribute but is set, turn it on */
	  if (old_flip_y and ((self.tileflip_enable and 2)<>0)) then flip_y:=true
      else flip_y:=(flags and 2)<>0;
    put_gfx_trans_flip(pos_x*8,pos_y*8,nchar and self.char_mask,color shl 4,self.pant[layer],0,flip_x,flip_y);
	  //tileinfo.category = priority;
    video_buffer[layer,f]:=false;
  end;
end;
end;

procedure k052109_chip.calc_scroll_1;
var
  xscroll,yscroll,offs:word;
begin
if ((self.scrollctrl and $03)=$02) then begin
    yscroll:=self.ram[$180c];
		self.scroll_y[1,0]:=yscroll;
		for offs:=0 to $ff do begin
			xscroll:=self.ram[$1a00+(2*(offs and $fff8))]+256*self.ram[$1a00+(2*(offs and $fff8)+1)];
			xscroll:=xscroll-6;
      self.scroll_x[1,(offs+yscroll) and $ff]:=xscroll;
		end;
    self.scroll_tipo[1]:=0;
	end else if ((self.scrollctrl and $03)=$03) then begin
		yscroll:=self.ram[$180c];
		self.scroll_y[1,0]:=yscroll;
		for offs:=0 to $ff do begin
			xscroll:=self.ram[$1a00+(2*offs)]+256*self.ram[$1a00+(2*offs+1)];
			xscroll:=xscroll-6;
      self.scroll_x[1,(offs+yscroll) and $ff]:=xscroll;
		end;
    self.scroll_tipo[1]:=1;
	end else if ((self.scrollctrl and $04)=$04) then begin
		xscroll:=(self.ram[$1a00]+256*self.ram[$1a01])-6;
    self.scroll_x[1,0]:=xscroll;
		for offs:=0 to 511 do begin
			yscroll:=self.ram[$1800+(offs div 8)];
      self.scroll_y[1,(offs+xscroll) and $1ff]:=yscroll;
		end;
    self.scroll_tipo[1]:=2;
	end else begin
    self.scroll_x[1,0]:=(self.ram[$1a00]+(self.ram[$1a01] shl 8))-6;
		self.scroll_y[1,0]:=self.ram[$180c];
    self.scroll_tipo[1]:=3;
	end;
end;

procedure k052109_chip.calc_scroll_2;
var
  xscroll,yscroll,offs:word;
begin
if ((self.scrollctrl and $18)=$10) then begin
    yscroll:=self.ram[$380c];
		self.scroll_y[2,0]:=yscroll;
		for offs:=0 to $ff do begin
			xscroll:=self.ram[$3a00+(2*(offs and $fff8))]+256*self.ram[$3a00+(2*(offs and $fff8)+1)];
			xscroll:=xscroll-6;
      self.scroll_x[2,(offs+yscroll) and $ff]:=xscroll;
		end;
    self.scroll_tipo[2]:=0;
	end else if ((self.scrollctrl and $18)=$18) then begin
    yscroll:=self.ram[$380c];
		self.scroll_y[2,0]:=yscroll;
		for offs:=0 to $ff do begin
			xscroll:=self.ram[$3a00+(2*offs)]+256*self.ram[$3a00+(2*offs+1)];
			xscroll:=xscroll-6;
      self.scroll_x[2,(offs+yscroll) and $ff]:=xscroll;
		end;
    self.scroll_tipo[2]:=1;
	end else if ((self.scrollctrl and $20)=$20) then begin
    xscroll:=(self.ram[$3a00]+256*self.ram[$3a01])-6;
    self.scroll_x[2,0]:=xscroll;
		for offs:=0 to 511 do begin
			yscroll:=self.ram[$3800+(offs div 8)];
      self.scroll_y[2,(offs+xscroll) and $1ff]:=yscroll;
		end;
    self.scroll_tipo[2]:=2;
	end else begin
    self.scroll_x[2,0]:=(self.ram[$3a00]+(self.ram[$3a01] shl 8))-6;
		self.scroll_y[2,0]:=self.ram[$380c];
    self.scroll_tipo[2]:=3;
	end;
end;

procedure k052109_chip.recalc_chars;
const
  pc_x_ram:array[0..7] of dword=(0*4, 1*4, 2*4, 3*4, 4*4, 5*4, 6*4, 7*4);
  pc_y_ram:array[0..7] of dword=(0*32, 1*32, 2*32, 3*32, 4*32, 5*32, 6*32, 7*32);
begin
  self.recalc_char:=false;
  gfx_set_desc_data(4,0,8*32,0,1,2,3);
  convert_gfx(0,0,self.char_rom,@pc_x_ram[0],@pc_y_ram[0],false,false);
  self.clean_video_buffer;
end;

procedure k052109_chip.draw_tiles;
begin
  if self.recalc_char then recalc_chars;
  self.calc_scroll_1;
  self.calc_scroll_2;
  self.update_all_tile(0);
  self.update_all_tile(1);
  self.update_all_tile(2);
end;

procedure k052109_chip.draw_layer(layer,final_screen:byte);
var
  f:word;
begin
case layer of
  0:actualiza_trozo(0,0,512,256,self.pant[0],0,0,512,256,final_screen); //Esta es fija
  1,2:begin
      case self.scroll_tipo[layer] of
        0,1:for f:=0 to $ff do scroll__x_part(self.pant[layer],final_screen,k052109_0.scroll_x[layer,f],self.scroll_y[layer,0],f,1);
        2:for f:=0 to $1ff do scroll__y_part(self.pant[layer],final_screen,k052109_0.scroll_y[layer,f],self.scroll_x[layer,0],f,1);
        3:scroll_x_y(self.pant[layer],final_screen,self.scroll_x[layer,0],self.scroll_y[layer,0]);
      end;
    end;
end;
end;

end.
