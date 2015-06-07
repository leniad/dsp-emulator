unit vlm_5030;

interface
uses {$IFDEF WINDOWS}windows,{$else}main_engine,{$ENDIF}
     sound_engine,timer_engine;

const
  FR_SIZE=4;
  // samples per interpolator */
  IP_SIZE_SLOWER=(240 div FR_SIZE);
  IP_SIZE_SLOW=(200 div FR_SIZE);
  IP_SIZE_NORMAL=(160 div FR_SIZE);
  IP_SIZE_FAST=(120 div FR_SIZE);
  IP_SIZE_FASTER=(80 div FR_SIZE);

	PH_RESET=0;
	PH_IDLE=1;
	PH_SETUP=2;
	PH_WAIT=3;
	PH_RUN=4;
	PH_STOP=5;
	PH_END=6;

// ROM Tables */
VLM5030_speed_table:array[0..8-1] of integer=(
 IP_SIZE_NORMAL,
 IP_SIZE_FAST,
 IP_SIZE_FASTER,
 IP_SIZE_FASTER,
 IP_SIZE_NORMAL,
 IP_SIZE_SLOWER,
 IP_SIZE_SLOW,
 IP_SIZE_SLOW
);

// This is the energy lookup table */
// sampled from real chip */
  energytable:array[0..$20-1] of byte=(
	  0,  2,  4,  6, 10, 12, 14, 18, // 0-7
	 22, 26, 30, 34, 38, 44, 48, 54, //  8-15
	 62, 68, 76, 84, 94,102,114,124, // 16-23
	136,150,164,178,196,214,232,254  // 24-31
  );
// This is the pitch lookup table */
  pitchtable:array[0..$20-1] of byte=(
   1,                               // 0     : random mode */
   22,                              // 1     : start=22    */
   23, 24, 25, 26, 27, 28, 29, 30,  //  2- 9 : 1step       */
   32, 34, 36, 38, 40, 42, 44, 46,  // 10-17 : 2step       */
   50, 54, 58, 62, 66, 70, 74, 78,  // 18-25 : 4step       */
   86, 94, 102,110,118,126          // 26-31 : 8step       */
   );

  K1_table:array[0..63] of integer= (
  -24898,  -25672,  -26446,  -27091,  -27736,  -28252,  -28768,  -29155,
  -29542,  -29929,  -30316,  -30574,  -30832,  -30961,  -31219,  -31348,
  -31606,  -31735,  -31864,  -31864,  -31993,  -32122,  -32122,  -32251,
  -32251,  -32380,  -32380,  -32380,  -32509,  -32509,  -32509,  -32509,
   24898,   23995,   22963,   21931,   20770,   19480,   18061,   16642,
   15093,   13416,   11610,    9804,    7998,    6063,    3999,    1935,
       0,   -1935,   -3999,   -6063,   -7998,   -9804,  -11610,  -13416,
  -15093,  -16642,  -18061,  -19480,  -20770,  -21931,  -22963,  -23995
);

  K2_table:array[0..31] of integer= (
       0,   -3096,   -6321,   -9417,  -12513,  -15351,  -18061,  -20770,
  -23092,  -25285,  -27220,  -28897,  -30187,  -31348,  -32122,  -32638,
       0,   32638,   32122,   31348,   30187,   28897,   27220,   25285,
   23092,   20770,   18061,   15351,   12513,    9417,    6321,    3096
);
  K3_table:array[0..15] of integer= (
       0,   -3999,   -8127,  -12255,  -16384,  -20383,  -24511,  -28639,
   32638,   28639,   24511,   20383,   16254,   12255,    8127,    3999
);
  K5_table:array[0..7] of integer= (
       0,   -8127,  -16384,  -24511,   32638,   24511,   16254,    8127
);


type
  vlm5030_chip=class(snd_chip_class)
        constructor Create(clock:integer;rom_size:dword;amplificador:byte);
        procedure Free;
        destructor Destroy;
      public
        procedure reset;
        procedure update;
        function get_bsy:byte;
        procedure data_w(data:byte);
        function get_rom_addr:pbyte;
        procedure set_st(pin:byte);
        procedure set_rst(pin:byte);
        procedure update_vcu(pin:byte);
        function save_snapshot(data:pbyte):word;
        procedure load_snapshot(data:pbyte);
      protected
    	  rom:pbyte;
    	  address_mask:integer;
    	  address:word;
    	  pin_BSY:byte;
    	  pin_ST:byte;
    	  pin_VCU:byte;
    	  pin_RST:byte;
    	  latch_data:byte;
    	  vcu_addr_h:word;
    	  parameter:byte;
    	  phase:byte;
    	  // state of option paramter */
    	  frame_size:integer;
    	  pitch_offset:integer;
    	  interp_step:byte;
    	  interp_count:byte;       // number of interp periods    */
    	  sample_count:byte;       // sample number within interp */
    	  pitch_count:byte;
    	// these contain data describing the current and previous voice frames */
    	  old_energy:word;
    	  old_pitch:byte;
    	  old_k:array[0..10-1] of integer;
    	  target_energy:word;
    	  target_pitch:byte;
    	  target_k:array[0..10-1] of integer;
    	  new_energy:word;
    	  new_pitch:byte;
    	  new_k:array[0..10-1] of integer;
    	  // these are all used to contain the current state of the sound generation */
    	  current_energy:cardinal;
    	  current_pitch:cardinal;
    	  current_k:array[0..10-1] of integer;
    	  x:array[0..10-1] of integer;
        out_:integer;
        function get_bits(sbit,bits:integer):integer;
        function parse_frame:integer;
        procedure update_stream;
        procedure setup_parameter(param:byte);
  end;
var
  vlm5030_0:vlm5030_chip;

procedure vlm5030_update_stream;

implementation

// start VLM5030 with sound rom              */
constructor vlm5030_chip.Create(clock:integer;rom_size:dword;amplificador:byte);
begin
  getmem(self.rom,rom_size);
	//emulation_rate:= clock / 440;
	// reset input pins */
	self.pin_RST:=0;
  self.pin_ST:=0;
  self.pin_VCU:= 0;
	self.latch_data:= 0;
	self.reset;
	self.phase:= PH_IDLE;
  self.amp:=amplificador;
	// memory size */
	self.address_mask:=rom_size-1;
  self.tsample_num:=init_channel;
  //timer interno
  init_timer(sound_status.cpu_num,sound_status.cpu_clock/(clock/440),vlm5030_update_stream,true);
  self.out_:=0;
end;

destructor vlm5030_chip.Destroy;
begin
  freemem(self.rom);
  self.rom:=nil;
end;

procedure vlm5030_chip.free;
begin
  if self.rom<>nil then self.Destroy;
end;

function vlm5030_chip.get_rom_addr;
begin
  get_rom_addr:=self.rom;
end;

procedure vlm5030_chip.reset;
begin
	self.phase:=PH_RESET;
	self.address:=0;
	self.vcu_addr_h:=0;
	self.pin_BSY:=0;

	self.old_energy:=0;
  self.old_pitch:=0;
	self.new_energy:=0;
  self.new_pitch:=0;
	self.current_energy:=0;
  self.current_pitch:= 0;
	self.target_energy:=0;
  self.target_pitch:= 0;

	fillchar(self.old_k[0],10*4,0);
	fillchar(self.new_k[0],10*4,0);
	fillchar(self.current_k,10*4,0);
	fillchar(self.target_k,10*4,0);
	self.interp_count:=0;
  self.sample_count:=0;
  self.pitch_count:= 0;
	fillchar(self.x[0],10*4,0);
	// reset parameters */
	self.setup_parameter($00);
end;

function vlm5030_chip.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
begin
  temp:=data;
  copymemory(temp,@self.address_mask,4);inc(temp,4);size:=4;
  copymemory(temp,@self.address,2);inc(temp,2);size:=size+2;
  temp^:=self.pin_BSY;inc(temp);size:=size+1;
  temp^:=self.pin_ST;inc(temp);size:=size+1;
  temp^:=self.pin_VCU;inc(temp);size:=size+1;
  temp^:=self.pin_RST;inc(temp);size:=size+1;
  temp^:=self.latch_data;inc(temp);size:=size+1;
  copymemory(temp,@self.vcu_addr_h,2);inc(temp,2);size:=size+2;
  temp^:=self.parameter;inc(temp);size:=size+1;
  temp^:=self.phase;inc(temp);size:=size+1;
  copymemory(temp,@self.frame_size,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.pitch_offset,4);inc(temp,4);size:=size+4;
  temp^:=self.interp_step;inc(temp);size:=size+1;
  temp^:=self.interp_count;inc(temp);size:=size+1;
  temp^:=self.sample_count;inc(temp);size:=size+1;
  temp^:=self.pitch_count;inc(temp);size:=size+1;
  copymemory(temp,@self.old_energy,2);inc(temp,2);size:=size+2;
  temp^:=self.old_pitch;inc(temp);size:=size+1;
  copymemory(temp,@self.old_k[0],4*10);inc(temp,4*10);size:=size+(4*10);
  copymemory(temp,@self.target_energy,2);inc(temp,2);size:=size+2;
  temp^:=self.target_pitch;inc(temp);size:=size+1;
  copymemory(temp,@self.target_k[0],4*10);inc(temp,4*10);size:=size+(4*10);
  copymemory(temp,@self.new_energy,2);inc(temp,2);size:=size+2;
  temp^:=self.new_pitch;inc(temp);size:=size+1;
  copymemory(temp,@self.new_k[0],4*10);inc(temp,4*10);size:=size+(4*10);
  copymemory(temp,@self.current_energy,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.current_pitch,4);inc(temp,4);size:=size+4;
  copymemory(temp,@self.current_k[0],4*10);inc(temp,4*10);size:=size+(4*10);
  copymemory(temp,@self.x[0],4*10);inc(temp,4*10);size:=size+(4*10);
  copymemory(temp,@self.out_,4);size:=size+4;
  save_snapshot:=size;
end;

procedure vlm5030_chip.load_snapshot(data:pbyte);
var
  temp:pbyte;
begin
  temp:=data;
  copymemory(@self.address_mask,temp,4);inc(temp,4);
  copymemory(@self.address,temp,2);inc(temp,2);
  self.pin_BSY:=temp^;inc(temp);
  self.pin_ST:=temp^;inc(temp);
  self.pin_VCU:=temp^;inc(temp);
  self.pin_RST:=temp^;inc(temp);
  self.latch_data:=temp^;inc(temp);
  copymemory(@self.vcu_addr_h,temp,2);inc(temp,2);
  self.parameter:=temp^;inc(temp);
  self.phase:=temp^;inc(temp);
  copymemory(@self.frame_size,temp,4);inc(temp,4);
  copymemory(@self.pitch_offset,temp,4);inc(temp,4);
  self.interp_step:=temp^;inc(temp);
  self.interp_count:=temp^;inc(temp);
  self.sample_count:=temp^;inc(temp);
  self.pitch_count:=temp^;inc(temp);
  copymemory(@self.old_energy,temp,2);inc(temp,2);
  self.old_pitch:=temp^;inc(temp);
  copymemory(@self.old_k[0],temp,4*10);inc(temp,4*10);
  copymemory(@self.target_energy,temp,2);inc(temp,2);
  self.target_pitch:=temp^;inc(temp);
  copymemory(@self.target_k[0],temp,4*10);inc(temp,4*10);
  copymemory(@self.new_energy,temp,2);inc(temp,2);
  self.new_pitch:=temp^;inc(temp);
  copymemory(@self.new_k[0],temp,4*10);inc(temp,4*10);
  copymemory(@self.current_energy,temp,4);inc(temp,4);
  copymemory(@self.current_pitch,temp,4);inc(temp,4);
  copymemory(@self.current_k[0],temp,4*10);inc(temp,4*10);
  copymemory(@self.x[0],temp,4*10);inc(temp,4*10);
  copymemory(@self.out_,temp,4);
end;

function vlm5030_chip.get_bits(sbit,bits:integer):integer;
var
  data:integer;
  ptemp:pbyte;
begin
  ptemp:=self.rom;
  inc(ptemp,(self.address+(sbit shr 3)) and self.address_mask);
  copymemory(@data,ptemp,2);
	data:=data shr (sbit and 7);
	data:=data and ($ff shr (8-bits));
	get_bits:=data;
end;

// get next frame */
function vlm5030_chip.parse_frame:integer;
var
  cmd:byte;
	i,nums:integer;
  ptemp:pbyte;
begin
	// remember previous frame */
	self.old_energy:=self.new_energy;
	self.old_pitch:=self.new_pitch;
	for i:=0 to 9 do self.old_k[i]:= self.new_k[i];
  // command byte check */
  ptemp:=self.rom;
  inc(ptemp,self.address and self.address_mask);
  cmd:=ptemp^;
  if (cmd and $01)<>0 then begin
	    // extend frame */
		  self.new_energy:=0;
      self.new_pitch:=0;
		  for i:=0 to 9 do self.new_k[i]:=0;
		  self.address:=self.address+1;
      if (cmd and $02 )<>0 then begin
			  // end of speech */
			  // logerror("VLM5030 %04X end \n",chip->address ); */
			  parse_frame:=0;
        exit;
		  end else begin
			  // silent frame */
			  nums:= ( (cmd shr 2)+1 )*2;
			  // logerror("VLM5030 %04X silent %d frame\n",chip->address,nums ); */
			  parse_frame:=nums * FR_SIZE;
        exit;
		  end;
	end;
	// pitch */
	self.new_pitch:=(pitchtable[get_bits(1,5)] + self.pitch_offset ) and $ff;
	// energy */
	self.new_energy:= energytable[get_bits(6,5)];
	// 10 K's */
	self.new_k[9]:= K5_table[get_bits(11,3)];
	self.new_k[8]:= K5_table[get_bits(14,3)];
	self.new_k[7]:= K5_table[get_bits(17,3)];
	self.new_k[6]:= K5_table[get_bits(20,3)];
	self.new_k[5]:= K5_table[get_bits(23,3)];
	self.new_k[4]:= K5_table[get_bits(26,3)];
	self.new_k[3]:= K3_table[get_bits(29,4)];
	self.new_k[2]:= K3_table[get_bits(33,4)];
	self.new_k[1]:= K2_table[get_bits(37,5)];
	self.new_k[0]:= K1_table[get_bits(42,6)];

	self.address:=self.address+6;
	//logerror("VLM5030 %04X voice \n",chip->address );
	parse_frame:=FR_SIZE;
end;

// decode and buffering data */
procedure vlm5030_chip.update_stream;
var
	interp_effect,i,current_val:integer;
	u:array[0..11-1] of integer;
  val:integer;
label
  phase_stop;
begin
	// running */
	if ((self.phase=PH_RUN) or (self.phase=PH_STOP)) then begin
		// playing speech */
		//while (length > 0) do begin
			// check new interpolator or  new frame */
			if (self.sample_count=0) then begin
				if (self.phase=PH_STOP) then begin
					self.phase:=PH_END;
					self.sample_count:= 1;
					goto phase_stop; // continue to end phase */
				end;
				self.sample_count:= self.frame_size;
				// interpolator changes */
				if (self.interp_count=0) then begin
					// change to new frame */
					self.interp_count:=parse_frame; // with change phase */
					if (self.interp_count=0) then begin
					 	// end mark found */
						self.interp_count:= FR_SIZE;
						self.sample_count:= self.frame_size; // end -> stop time */
						self.phase:= PH_STOP;
					end;
					// Set old target as new start of frame */
					self.current_energy:= self.old_energy;
					self.current_pitch:= self.old_pitch;
					for i:=0 to 9 do self.current_k[i]:=self.old_k[i];
					// is this a zero energy frame? */
					if (self.current_energy=0) then begin
						//mame_printf_debug("processing frame: zero energy\n");*/
						self.target_energy:= 0;
						self.target_pitch:= self.current_pitch;
						for i:=0 to 9 do self.target_k[i]:=self.current_k[i];
					end else begin
						self.target_energy:= self.new_energy;
						self.target_pitch:= self.new_pitch;
						for i:=0 to 9 do self.target_k[i]:=self.new_k[i];
					end;
				end;
				// next interpolator */
				// Update values based on step values 25% , 50% , 75% , 100% */
				self.interp_count:=self.interp_count-self.interp_step;
				// 3,2,1,0 -> 1,2,3,4 */
				interp_effect:= FR_SIZE - (self.interp_count mod FR_SIZE);
				self.current_energy:= self.old_energy + (self.target_energy - self.old_energy) * interp_effect div FR_SIZE;
				if (self.old_pitch>1) then self.current_pitch:= self.old_pitch + (self.target_pitch - self.old_pitch) * interp_effect div FR_SIZE;
				for i:=0 to 9 do self.current_k[i]:=self.old_k[i] + (self.target_k[i] - self.old_k[i]) * interp_effect div FR_SIZE;
			end;
			// calcrate digital filter */
			if (self.old_energy=0) then begin
				// generate silent samples here */
				current_val:=0;
			end else if (self.old_pitch <= 1) then begin
				  // generate unvoiced samples here */
          if (random(256) and 1)<>0 then current_val:=self.current_energy
            else current_val:=-self.current_energy;
			  end else begin
				  // generate voiced samples here */
				  if (self.pitch_count=0) then current_val:=self.current_energy
            else current_val:=0;
			  end;

			// Lattice filter here */
			u[10]:=current_val;
			for i:=9 downto 0 do u[i]:=u[i+1]-((self.current_k[i] * self.x[i]) div 32768);
			for i:=9 downto 1 do self.x[i]:=self.x[i-1] + ((self.current_k[i-1] * u[i-1]) div 32768);
			self.x[0]:=u[0];

			// clipping, buffering */
			if (u[0] > 511) then val:=511 shl 6
			  else if (u[0] < -511) then val:=-511 shl 6
			    else val:=u[0] shl 6;
      self.out_:=trunc(val*self.amp);
      if self.out_<-32767 then self.out_:=-32767
        else if self.out_>32767 then self.out_:=32767;
			// sample count */
			self.sample_count:=self.sample_count-1;
			// pitch */
			self.pitch_count:=self.pitch_count+1;
			if (self.pitch_count >= self.current_pitch ) then self.pitch_count:=0;
		//end; //del while
    exit;
	end;
	// stop phase */
phase_stop:
	case (self.phase) of
	  PH_SETUP:if (self.sample_count<=1) then begin
			        self.sample_count:=0;
			        // logerror("VLM5030 BSY=H\n" ); */
			        // pin_BSY = 1; */
			        self.phase:=PH_WAIT;
		         end else begin
			        self.sample_count:=self.sample_count-1;
		         end;
	  PH_END:if (self.sample_count<=1) then begin
			      self.sample_count:= 0;
			      // logerror("VLM5030 BSY=L\n" ); */
			      self.pin_BSY:= 0;
			      self.phase:= PH_IDLE;
		      end	else begin
			      self.sample_count:=self.sample_count-1;
		      end;
	end;
	// silent buffering
  self.out_:=0;
end;

// get BSY pin level */
function vlm5030_chip.get_bsy:byte;
begin
	get_bsy:=self.pin_BSY;
end;

// latch contoll data */
procedure vlm5030_chip.data_w(data:byte);
begin
	self.latch_data:=data;
end;

// setup parameteroption when RST=H */
procedure vlm5030_chip.setup_parameter(param:byte);
begin
	// latch parameter value */
	self.parameter:=param;

	// bit 0,1 : 4800bps / 9600bps , interporator step */
	if (param and 2)<>0 then // bit 1 = 1 , 9600bps */
		self.interp_step:= 4 // 9600bps : no interporator */
	else if(param and 1)<>0 then // bit1 = 0 & bit0 = 1 , 4800bps */
		self.interp_step:= 2 // 4800bps : 2 interporator */
	else	// bit1 = bit0 = 0 : 2400bps */
		self.interp_step:= 1; // 2400bps : 4 interporator */

	// bit 3,4,5 : speed (frame size) */
	self.frame_size:=VLM5030_speed_table[(param shr 3) and 7];

	// bit 6,7 : low / high pitch */
	if (param and $80)<>0 then	// bit7=1 , high pitch */
		self.pitch_offset:= -8
	else if (param and $40)<>0 then	// bit6=1 , low pitch */
		self.pitch_offset:= 8
	else
		self.pitch_offset:= 0;
end;

// set RST pin level : reset / set table address A8-A15 */
procedure vlm5030_chip.set_rst(pin:byte);
begin
	if self.pin_RST<>0 then begin
		if (pin=0) then begin
			// H -> L : latch parameters */
			self.pin_RST:= 0;
			self.setup_parameter(self.latch_data);
		end;
	end else begin
		if (pin<>0) then begin
			// L -> H : reset chip */
			self.pin_RST:= 1;
			if self.pin_BSY<>0 then begin
				self.reset;
			end;
		end;
	end;
end;

// set VCU pin level : ?? unknown */
procedure vlm5030_chip.update_vcu(pin:byte);
begin
	// direct mode / indirect mode */
	self.pin_VCU:= pin;
end;

// set ST pin level  : set table address A0-A7 / start speech */
procedure vlm5030_chip.set_st(pin:byte);
var
  table:integer;
  ptemp:pbyte;
begin
	if (self.pin_ST<>pin) then begin
		// pin level is change */
		if (pin=0) then begin
			// H -> L */
			self.pin_ST:= 0;
			if( self.pin_VCU<>0 ) then begin
				// direct access mode & address High */
				self.vcu_addr_h:=(self.latch_data shl 8) + $01;
			end	else begin
				// start speech */
				// check access mode */
				if (self.vcu_addr_h<>0) then begin
					// direct access mode */
					self.address:= (self.vcu_addr_h and $ff00) + self.latch_data;
					self.vcu_addr_h:= 0;
				end	else begin
					// indirect accedd mode */
					table:= (self.latch_data and $fe) + ((self.latch_data and 1) shl 8);
          ptemp:=self.rom;
          inc(ptemp,table and self.address_mask);
          self.address:=(ptemp^ shl 8);
          inc(ptemp);
          self.address:=self.address or ptemp^;
				end;
				// logerror("VLM5030 %02X start adr=%04X\n",table/2,chip->address ); */
				// reset process status */
				self.sample_count:= self.frame_size;
				self.interp_count:= FR_SIZE;
				// clear filter */
				// start after 3 sampling cycle */
				self.phase:= PH_RUN;
			end;
		end	else begin
			// L -> H */
			self.pin_ST:= 1;
			// setup speech , BSY on after 30ms? */
			self.phase:= PH_SETUP;
			self.sample_count:= 1; // wait time for busy on */
			self.pin_BSY:= 1;
		end;
	end;
end;

procedure vlm5030_chip.update;
begin
tsample[self.tsample_num,sound_status.posicion_sonido]:=self.out_;
end;

procedure vlm5030_update_stream;
begin
  vlm5030_0.update_stream;
end;

end.
