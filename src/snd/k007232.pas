unit k007232;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
      sound_engine,timer_engine;

const
   KDAC_A_PCM_MAX=2;
type
  tk007232_call_back=procedure (valor:byte);
  k007232_chip=class(snd_chip_class)
        constructor create(clock:dword;rom_adpcm:pbyte;size:dword;amplifi:single;call_back:tk007232_call_back);
        destructor free;
    public
        procedure update;
        procedure set_volume(channel,volumeA,volumeB:byte);
        procedure write(direccion:word;valor:byte);
        function read(direccion:word):byte;
        procedure set_bank(chABank,chBBank:byte);
    private
        vol:array[0..KDAC_A_PCM_MAX-1,0..1] of byte; // volume for the left and right channel */
	      address,start,step,bank:array[0..KDAC_A_PCM_MAX-1] of dword;
	      play:array[0..KDAC_A_PCM_MAX-1] of boolean;
	      wreg:array[0..$f] of byte; //write data */
	      pcmlimit:dword;
	      ntimer:byte;
	      fncode:array[0..$1ff] of dword;
        call_back:tk007232_call_back;
        rom:pbyte;
        out1,out2:integer;
        tsample_num2:byte;
        procedure internal_update;
    end;

procedure internal_update_k007232_0;

var
  k007232_0:k007232_chip;

implementation
const
   BASE_SHIFT=12;
   kdac_note:array[0..12] of single=(
	  261.63/8, 277.18/8,
	  293.67/8, 311.13/8,
	  329.63/8,
	  349.23/8, 369.99/8,
	  392.00/8, 415.31/8,
	  440.00/8, 466.16/8,
	  493.88/8,
	  523.25/8);
  kdaca_fn:array[0..52,0..1] of single=(
	// B */
	( $03f, 493.88/8 ),        // ?? */
	( $11f, 493.88/4 ),        // ?? */
	( $18f, 493.88/2 ),        // ?? */
	( $1c7, 493.88   ),
	( $1e3, 493.88*2 ),
	( $1f1, 493.88*4 ),        // ?? */
	( $1f8, 493.88*8 ),        // ?? */
	// A+ */
	( $020, 466.16/8 ),        // ?? */
	( $110, 466.16/4 ),        // ?? */
	( $188, 466.16/2 ),
	( $1c4, 466.16   ),
	( $1e2, 466.16*2 ),
	( $1f1, 466.16*4 ),        // ?? */
	( $1f8, 466.16*8 ),        // ?? */
	// A */
	( $000, 440.00/8 ),        // ?? */
	( $100, 440.00/4 ),        // ?? */
	( $180, 440.00/2 ),
	( $1c0, 440.00   ),
	( $1e0, 440.00*2 ),
	( $1f0, 440.00*4 ),        // ?? */
	( $1f8, 440.00*8 ),        // ?? */
	( $1fc, 440.00*16),        // ?? */
	( $1fe, 440.00*32),        // ?? */
	( $1ff, 440.00*64),        // ?? */
	// G+ */
	( $0f2, 415.31/4 ),
	( $179, 415.31/2 ),
	( $1bc, 415.31   ),
	( $1de, 415.31*2 ),
	( $1ef, 415.31*4 ),        // ?? */
	( $1f7, 415.31*8 ),        // ?? */
	// G */
	( $0e2, 392.00/4 ),
	( $171, 392.00/2 ),
	( $1b8, 392.00   ),
	( $1dc, 392.00*2 ),
	( $1ee, 392.00*4 ),        // ?? */
	( $1f7, 392.00*8 ),        // ?? */
	// F+ */
	( $0d0, 369.99/4 ),        // ?? */
	( $168, 369.99/2 ),
	( $1b4, 369.99   ),
	( $1da, 369.99*2 ),
	( $1ed, 369.99*4 ),        // ?? */
	( $1f6, 369.99*8 ),        // ?? */
	// F */
	( $0bf, 349.23/4 ),        // ?? */
	( $15f, 349.23/2 ),
	( $1af, 349.23   ),
	( $1d7, 349.23*2 ),
	( $1eb, 349.23*4 ),        // ?? */
	( $1f5, 349.23*8 ),        // ?? */
	// E */
	( $0ac, 329.63/4 ),
	( $155, 329.63/2 ),        // ?? */
	( $1e5, 261.63*4 ),
	( $1f2, 261.63*8 ),        // ?? */
	( -1, -1 ));

constructor k007232_chip.create(clock:dword;rom_adpcm:pbyte;size:dword;amplifi:single;call_back:tk007232_call_back);
var
  f:word;
begin
	// Set up the chips */
	self.pcmlimit:=size;
  self.call_back:=call_back;
  self.clock:=clock;
	for f:=0 to (KDAC_A_PCM_MAX-1) do begin
		self.address[f]:=0;
		self.start[f]:=0;
		self.step[f]:=0;
		self.play[f]:=false;
		self.bank[f]:=0;
	end;
	self.vol[0,0]:=255;  // channel A output to output A */
	self.vol[0,1]:=0;
	self.vol[1,0]:=0;
	self.vol[1,1]:=255;  // channel B output to output B */
  self.amp:=amplifi;
	for f:=0 to $f do self.wreg[f]:=0;
  self.ntimer:=init_timer(sound_status.cpu_num,sound_status.cpu_clock/(clock/128),internal_update_k007232_0,true);
  self.tsample_num:=init_channel;
  self.tsample_num2:=init_channel;
  self.rom:=rom_adpcm;
	//KDAC_A_make_fncode;
  for f:=0 to $1ff do self.fncode[f]:=round((32 shl BASE_SHIFT)/($200-f));
end;

destructor k007232_chip.free;
begin
end;

procedure k007232_chip.write(direccion:word;valor:byte);
var
  r,idx:word;
  v,reg_port:byte;
begin
	r:=direccion;
	v:=valor;
	self.wreg[r]:=v;          // stock write data */
	if (r=$0c) then begin
	  // external port, usually volume control */
	  if (@self.call_back<>nil) then self.call_back(v);
	  exit;
	end else if (r=$0d) then begin
	            // loopflag. */
	            exit;
	         end else begin
	                  reg_port:=0;
	                  if (r>=$06) then begin
		                  reg_port:=1;
		                  r:=r-$06;
	                  end;
	                  case r of
	                  	  $00,01:begin
	                  				    //*** address step ****/
	                  		        idx:=((((self.wreg[reg_port*$06+$01]) shl 8) and $0100) or ((self.wreg[reg_port*$06+$00]) and $00ff));
	                  		        self.step[reg_port]:=self.fncode[idx];
	                             end;
	                  	  $02,$03,$04:;
	                  	  05:begin
	                  				//*** start address ****/
	                  		    self.start[reg_port]:=(((self.wreg[reg_port*$06+$04] shl 16) and $00010000) or
	                  		                          ((self.wreg[reg_port*$06+$03] shl 8) and $0000ff00) or
	                  		                          ((self.wreg[reg_port*$06+$02]) and $000000ff) or self.bank[reg_port]);
	                  		    if (self.start[reg_port]<self.pcmlimit) then begin
	                  	          self.play[reg_port]:=true;
	                  	          self.address[reg_port]:=0;
	                  		    end;
	                  		   end;
                    end;
           end;
end;

function k007232_chip.read(direccion:word):byte;
var
  r:word;
  ch:byte;
begin
	r:=direccion;
	ch:=0;
	if ((r=$0005) or (r=$000b)) then begin
	  ch:=r div $0006;
	  r:=ch*$0006;
	  self.start[ch]:=(((self.wreg[r+$04] shl 16) and $00010000) or
		                ((self.wreg[r+$03] shl 8) and $0000ff00) or
		                ((self.wreg[r+$02]) and $000000ff) or self.bank[ch]);
	  if (self.start[ch]<self.pcmlimit) then begin
		  self.play[ch]:=true;
		  self.address[ch]:=0;
	  end;
  end;
read:=0;
end;

procedure k007232_chip.set_volume(channel,volumeA,volumeB:byte);
begin
	self.vol[channel,0]:=volumeA;
	self.vol[channel,1]:=volumeB;
end;

procedure k007232_chip.set_bank(chABank,chBBank:byte);
begin
	self.bank[0]:=chABank shl 17;
	self.bank[1]:=chBBank shl 17;
end;

procedure k007232_chip.internal_update;
var
  f:byte;
  out_temp1,out_temp2:integer;
  addr,old_addr:dword;
  volA,volB:word;
begin
	for f:=0 to (KDAC_A_PCM_MAX-1) do begin
		if self.play[f] then begin
		  //*** PCM setup ****/
		  addr:=self.start[f]+((self.address[f] shr BASE_SHIFT) and $000fffff);
		  volA:=self.vol[f,0]*2;
		  volB:=self.vol[f,1]*2;
			old_addr:=addr;
			addr:=self.start[f]+((self.address[f] shr BASE_SHIFT) and $000fffff);
			while (old_addr<=addr) do begin
  			if (((self.rom[old_addr] and $80)<>0) or (old_addr>=self.pcmlimit)) then begin
		  		// end of sample */
			  	if (self.wreg[$0d] and (1 shl f))<>0 then begin
			  	  // loop to the beginning */
	  			  self.start[f]:=((self.wreg[f*$06+$04] shl 16) and $00010000) or
                           ((self.wreg[f*$06+$03] shl 8) and $0000ff00) or
	 			  	               ((self.wreg[f*$06+$02]) and $000000ff) or self.bank[f];
	  			  addr:=self.start[f];
		  		  self.address[f]:=0;
			  	  old_addr:=addr; // skip loop */
		  	  end else begin
			  	  // stop sample */
		  		  self.play[f]:=false;
			    end;
          break;
        end;
        old_addr:=old_addr+1;
		  end;
			if not(self.play[f]) then break;
			self.address[f]:=self.address[f]+self.step[f];
			self.out1:=((self.rom[addr] and $7f)-$40)*volA;
			self.out2:=((self.rom[addr] and $7f)-$40)*volB;
    end;
  end;
end;

procedure internal_update_k007232_0;
begin
  k007232_0.internal_update;
end;

procedure k007232_chip.update;
begin
  //Channel 1
  tsample[self.tsample_num,sound_status.posicion_sonido]:=round(self.out1*self.amp);
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=round(self.out1*self.amp);
  //Channel 2
  tsample[self.tsample_num2,sound_status.posicion_sonido]:=round(self.out2*self.amp);
  if sound_status.stereo then tsample[self.tsample_num2,sound_status.posicion_sonido+1]:=round(self.out2*self.amp);
end;

end.
