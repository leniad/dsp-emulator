unit sega_315_5313;

interface

uses gfx_engine,{$IFDEF WINDOWS}windows,{$endif}
     main_engine,pal_engine,tms99xx,dialogs,timer_engine,m68000,sn_76496;

type
    irq_type=procedure(state:boolean);
    vdp_5313_chip=class
      constructor create(pal:boolean);
      destructor free;
      public
        function read(direccion:byte):word;
        procedure write(direccion:byte;valor:word);
        procedure reset;
        procedure handle_scanline(linea:word);
        procedure handle_eof;
        procedure change_irqs(sndirq,irq4,irq6:irq_type);
      private
        vdp_pal,vblank_flag,sprite_collision,command_pending:boolean;
        imode,imode_odd_frame,vdp_code:byte;
        total_scanlines,visible_scanlines,irq6_scanline,z80irq_scanline:word;
        irq4_pending,irq6_pending,vram_fill_pending:boolean;
        command_part1,command_part2,vdp_address,vram_fill_length:word;
        regs:array[0..$1f] of word;
        vram:array[0..$7fff] of word;
        cram,vsram:array[0..$3f] of word;
        lv4irqline_callback,lv6irqline_callback:irq_type;
        sega_psg:sn76496_chip;
        function control_port_read:word;
        procedure control_port_write(valor:word);
        procedure data_port_write(valor:word);
        procedure update_code_and_address;
        procedure vdp_set_register(regnum,value:byte);
        procedure handle_dma_bits;
    end;

var
  vdp_5313_0:vdp_5313_chip;

const
  PAL_TOTAL_SCANLINES=313;
  NTSC_TOTAL_SCANLINES=262;
  PSG_CLOCK_NTSC=3579545;

implementation

constructor vdp_5313_chip.create(pal:boolean);
begin
  self.vdp_pal:=pal;
  self.sega_psg:=sn76496_chip.Create(PSG_CLOCK_NTSC);
end;

destructor vdp_5313_chip.free;
begin
  self.sega_psg.free;
end;

procedure vdp_5313_chip.change_irqs(sndirq,irq4,irq6:irq_type);
begin
  self.lv4irqline_callback:=irq4;
  self.lv6irqline_callback:=irq6;
end;

procedure vdp_5313_chip.reset;
begin
  fillchar(regs,$40,0);
  fillchar(vram,$10000,0);
  fillchar(cram,$80,0);
  fillchar(vsram,$80,0);
  vblank_flag:=false;
  self.imode_odd_frame:=0;
	self.sprite_collision:=false;
	self.imode:=0;
  total_scanlines:=262;
  visible_scanlines:=224;
  irq6_scanline:=224;
  z80irq_scanline:=226;
  irq4_pending:=false;
  irq6_pending:=false;
  vram_fill_pending:=false;
  command_pending:=false;
  command_part1:=0;
  command_part2:=0;
  vdp_address:=0;
  vdp_code:=0;
  vram_fill_length:=0;
end;

function vdp_5313_chip.control_port_read:word;
var
  fifo_empty,fifo_full,sprite_overflow,odd_frame,hblank_flag,dma_active:byte;
  hpos,ret:word;
  vblank:boolean;
begin
  sprite_overflow:=0;
	odd_frame:=0;
	hblank_flag:=0;
	dma_active:=0;
	vblank:=self.vblank_flag;
	fifo_empty:=1;
	fifo_full:=0;

	if (self.imode and 1)<>0 then odd_frame:=self.imode_odd_frame xor 1;

	hpos:=m68000_0.contador;

	if (hpos>400) then hblank_flag:=1;
	if (hpos>460) then hblank_flag:=0;

	// extra case
	if ((self.regs[$01] and $40)=0) then vblank:=true;

{ these aren't *always* 0/1 some of them are open bus return
 d15 - Always 0
 d14 - Always 0
 d13 - Always 1
 d12 - Always 1

 d11 - Always 0
 d10 - Always 1
 d9  - FIFO Empty
 d8  - FIFO Full

 d7  - Vertical interrupt pending
 d6  - Sprite overflow on current scan line
 d5  - Sprite collision
 d4  - Odd frame

 d3  - Vertical blanking
 d2  - Horizontal blanking
 d1  - DMA in progress
 d0  - PAL mode flag
}

	ret:= (1 shl 13) or // ALWAYS 1
			(1 shl 12) or // ALWAYS 1
			(1 shl 10) or // ALWAYS 1
			(fifo_empty shl 9) or // FIFO EMPTY
			(fifo_full shl 8) or // FIFO FULL
			(byte(irq6_pending) shl 7) or // exmutants has a tight loop checking this ..
			(sprite_overflow shl 6) or
			(byte(sprite_collision) shl 5) or
			(odd_frame shl 4) or
			(byte(vblank) shl 3) or
			(hblank_flag shl 2) or
			(dma_active shl 1) or
			(byte(self.vdp_pal) shl 0); // PAL MODE FLAG checked by striker for region prot..

control_port_read:=ret;
end;

function vdp_5313_chip.read(direccion:byte):word;
begin
  case direccion of
    4,6:read:=self.control_port_read;
    $10,$12,$14,$16:read:=0;
      else halt(direccion);
  end;
end;

procedure vdp_5313_chip.update_code_and_address;
begin
	self.vdp_code:=((self.command_part1 and $c000) shr 14) or ((self.command_part2 and $00f0) shr 2);
	self.vdp_address:=((self.command_part1 and $3fff) shr 0) or ((self.command_part2 and $0003) shl 14);
end;

procedure vdp_5313_chip.vdp_set_register(regnum,value:byte);
begin
	self.regs[regnum]:=value;
	{ We need special handling for the IRQ enable registers, some games turn
	   off the irqs before they are taken, delaying them until the IRQ is turned
	   back on }
	if (regnum=$00) then begin
		if self.irq4_pending then begin
			if ((self.regs[$00] and $10)<>0) then lv4irqline_callback(true)
			  else lv4irqline_callback(false);
    end;
		{ ??? Fatal Rewind needs this but I'm not sure it's accurate behavior
		   it causes flickering in roadrash
	  //  m_irq6_pending = 0;
	  //  m_irq4_pending = 0; }
	end;
	if (regnum=$01) then begin
		if self.irq6_pending then begin
			if ((self.regs[$01] and $20)<>0) then lv6irqline_callback(true)
			else lv6irqline_callback(false);
    end;
		// ???
	  //  m_irq6_pending = 0;
	  //  m_irq4_pending = 0;
	end;
end;

procedure vdp_5313_chip.handle_dma_bits;
var
  source:dword;
  long:word;
begin
if (((self.regs[$17] and $c0)=0) or (((self.regs[$17] and $c0) shr 6)=1)) then begin
		source:=((self.regs[$15] and $ff) or ((self.regs[$16] and $ff) shl 8) or ((self.regs[$17] and $7f) shl 16)) shl 1;
		long:=((self.regs[$13] and $ff) or ((self.regs[$14] and $ff) shl 8)) shl 1;
    case (self.vdp_code and $0f) of
      // The 68k is frozen during this transfer, it should be safe to throw a few cycles away and do 'instant' DMA because the 68k can't detect it being in progress (can the z80?)
      $01:;//if ((self.regs[$01] and $10)<>0) then insta_68k_to_vram_dma(source,long);
      // The 68k is frozen during this transfer, it should be safe to throw a few cycles away and do 'instant' DMA because the 68k can't detect it being in progress (can the z80?)
      $03:;//if ((self.regs[$01] and $10)<>0) then insta_68k_to_cram_dma(source,long);
      // The 68k is frozen during this transfer, it should be safe to throw a few cycles away and do 'instant' DMA because the 68k can't detect it being in progress (can the z80?)
      $05:;//if ((self.regs[$01] and $10)<>0) then insta_68k_to_vsram_dma(source,long);
    end;
end else if (((self.regs[$17] and $c0) shr 6)=$2) then begin
		if (((self.vdp_code and $0f)=$01) or ((self.vdp_code and $0f)=$03) or ((self.vdp_code and $0f)=$05)) then begin// only effects when code is write
			if ((self.regs[$01] and $10)<>0) then begin
				self.vram_fill_pending:=true;
				self.vram_fill_length:=(self.regs[$13] and $ff) or ((self.regs[$14] and $ff) shl 8);
      end;
    end;
	end else if (((self.regs[$17] and $c0) shr 6)=$3) then begin
		if (((self.vdp_code and $10)<>0) or ((self.vdp_code and $0f)=$01)) then begin // 0x21 can be affects?
			source:=((self.regs[$15] and $ff) or ((self.regs[$16] and $ff) shl 8)); // source (byte offset)
			long:=((self.regs[$13] and $ff) or ((self.regs[$14] and $ff) shl 8)); // length in bytes
			//if ((self.regs[$01] and $10)<>0) then insta_vram_copy(source, long);
		end;
  end;
end;

procedure vdp_5313_chip.data_port_write(valor:word);
var
  count:word;
begin
  self.command_pending:=false;
 {0000b : VRAM read
	0001b : VRAM write
	0011b : CRAM write
	0100b : VSRAM read
	0101b : VSRAM write
	1000b : CRAM read
	1100b : VRAM byte read (unhandled)}
  if (self.vram_fill_pending) then begin
		if ((self.vdp_address and 1)<>0) then self.vram[(self.vdp_address shr 1) and $7fff]:=valor and $ff
		  else self.vram[(self.vdp_address shr 1) and $7fff]:=(valor and $ff) shl 8;
		for count:=0 to (self.vram_fill_length-1) do begin // <= for james pond 3
			if (self.vdp_address and 1)<>0 then self.vram[(self.vdp_address shr 1) and $7fff]:=valor and $ff00
			  else self.vram[(self.vdp_address shr 1) and $7fff]:=(valor and $ff00) shr 8;
			self.vdp_address:=self.vdp_address+(self.regs[$0f] and $ff);
		end;
		self.regs[$13]:=0;
    self.regs[$14]:=0;
  end else begin
    case (self.vdp_code and $f) of
			1:;//vdp_vram_write(valor);
			3:;//vdp_cram_write(valor);
			5:;//vdp_vsram_write(valor);
		end;
  end;

end;

procedure vdp_5313_chip.control_port_write(valor:word);
var
  regnum,value:byte;
begin
  self.vram_fill_pending:=false; // ??
	if self.command_pending then begin
		// 2nd part of 32-bit command
		self.command_pending:=false;
		self.command_part2:=valor;
		update_code_and_address;
		if ((self.vdp_code and $20)<>0) then self.handle_dma_bits;
  end else begin
		if ((valor and $c000)=$8000) then begin
		   //Register Setting Command
			regnum:=(valor and $3f00) shr 8;
			value:=(valor and $ff);
			vdp_set_register(regnum and $1f,value);
			self.vdp_code:=0;
			self.vdp_address:=0;
		end else begin
			self.command_pending:=true;
			self.command_part1:=valor;
			update_code_and_address;
		end;
	end;
end;

procedure vdp_5313_chip.write(direccion:byte;valor:word);
begin
  case direccion of
    0,2:self.data_port_write(valor);
    4,6:self.control_port_write(valor);
    $10,$12,$14,$16:if m68000_0.write_8bits_hi_dir then self.sega_psg.Write(valor and $ff);
      else halt(direccion);
  end;
end;

procedure vdp_5313_chip.handle_scanline(linea:word);
begin
end;

procedure vdp_5313_chip.handle_eof;
var
  scr_width:word;
  scr_mul:byte;
begin
  scr_width:=320;
	scr_mul:=1;
	self.vblank_flag:=false;
	//m_irq6_pending = 0; /* NO! (breaks warlock) */
	self.sprite_collision:=false;//? when to reset this ..
	self.imode:=(self.regs[$0c] and $06) shr 1; // can't change mid-frame..
	self.imode_odd_frame:=self.imode_odd_frame xor 1;
  //m_genesis_snd_z80->set_input_line(0, CLEAR_LINE); // if the z80 interrupt hasn't happened by now, clear it..
	if ((self.regs[$01] and $08)<>0) then begin
		// this is invalid in NTSC!
		self.total_scanlines:=PAL_TOTAL_SCANLINES;
		self.visible_scanlines:=240;
		self.irq6_scanline:=240;
		self.z80irq_scanline:=240;
	end else begin
		self.total_scanlines:=NTSC_TOTAL_SCANLINES;
		self.visible_scanlines:=224;
		self.irq6_scanline:=224;
		self.z80irq_scanline:=224;
	end;

	if (self.imode=3) then
    halt(0);
	{
		m_total_scanlines <<= 1;
		m_visible_scanlines <<= 1;
		m_irq6_scanline <<= 1;
		m_z80irq_scanline <<= 1;
	}

	// note, add 240 mode + init new timings!
	//scr_mul = m_lcm_scaling ? hres_mul[get_hres()] : 1;
	//scr_width = hres[get_hres()] * scr_mul;

	//visarea.set(0, scr_width - 1, 0, m_visible_scanlines - 1);

	//screen().configure(480 * scr_mul, m_total_scanlines, visarea, screen().frame_period().attoseconds());
end;

end.
