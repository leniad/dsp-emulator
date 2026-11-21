unit upd7759;

interface
uses sound_engine,dialogs,main_engine,timer_engine;

const
  CLOCK_UPD=640000;
  FRAC_BITS=20;
  FRAC_ONE=(1 shl FRAC_BITS);
  FRAC_MASK=(FRAC_ONE-1);
  // chip states
  STATE_IDLE=0;
	STATE_DROP_DRQ=1;
	STATE_START=2;
	STATE_FIRST_REQ=3;
	STATE_LAST_SAMPLE=4;
	STATE_DUMMY1=5;
	STATE_ADDR_MSB=6;
	STATE_ADDR_LSB=7;
	STATE_DUMMY2=8;
	STATE_BLOCK_HEADER=9;
	STATE_NIBBLE_COUNT=10;
	STATE_NIBBLE_MSN=11;
	STATE_NIBBLE_LSN=12;
  upd7759_step:array[0..15,0..15] of integer=(
	( 0,  0,  1,  2,  3,   5,   7,  10,  0,   0,  -1,  -2,  -3,   -5,   -7,  -10 ),
	( 0,  1,  2,  3,  4,   6,   8,  13,  0,  -1,  -2,  -3,  -4,   -6,   -8,  -13 ),
	( 0,  1,  2,  4,  5,   7,  10,  15,  0,  -1,  -2,  -4,  -5,   -7,  -10,  -15 ),
	( 0,  1,  3,  4,  6,   9,  13,  19,  0,  -1,  -3,  -4,  -6,   -9,  -13,  -19 ),
	( 0,  2,  3,  5,  8,  11,  15,  23,  0,  -2,  -3,  -5,  -8,  -11,  -15,  -23 ),
	( 0,  2,  4,  7, 10,  14,  19,  29,  0,  -2,  -4,  -7, -10,  -14,  -19,  -29 ),
	( 0,  3,  5,  8, 12,  16,  22,  33,  0,  -3,  -5,  -8, -12,  -16,  -22,  -33 ),
	( 1,  4,  7, 10, 15,  20,  29,  43, -1,  -4,  -7, -10, -15,  -20,  -29,  -43 ),
	( 1,  4,  8, 13, 18,  25,  35,  53, -1,  -4,  -8, -13, -18,  -25,  -35,  -53 ),
	( 1,  6, 10, 16, 22,  31,  43,  64, -1,  -6, -10, -16, -22,  -31,  -43,  -64 ),
	( 2,  7, 12, 19, 27,  37,  51,  76, -2,  -7, -12, -19, -27,  -37,  -51,  -76 ),
	( 2,  9, 16, 24, 34,  46,  64,  96, -2,  -9, -16, -24, -34,  -46,  -64,  -96 ),
	( 3, 11, 19, 29, 41,  57,  79, 117, -3, -11, -19, -29, -41,  -57,  -79, -117 ),
	( 4, 13, 24, 36, 50,  69,  96, 143, -4, -13, -24, -36, -50,  -69,  -96, -143 ),
	( 4, 16, 29, 44, 62,  85, 118, 175, -4, -16, -29, -44, -62,  -85, -118, -175 ),
	( 6, 20, 36, 54, 76, 104, 144, 214, -6, -20, -36, -54, -76, -104, -144, -214 ));
  upd7759_state_table:array[0..15] of integer=( -1, -1, 0, 0, 1, 2, 2, 3, -1, -1, 0, 0, 1, 2, 2, 3);

type
  tcall_drq=procedure(drq:byte);
  upd7759_chip=class(snd_chip_class)
       constructor create(amp:single;slave:byte=1;call_drq:tcall_drq=nil);
       destructor free;
    public
       procedure update;
       procedure reset;
       function get_rom_addr:pbyte;
       procedure start_w(data:byte);
       procedure port_w(data:byte);
       procedure reset_w(data:byte);
       function busy_r:byte;
       procedure md_w(data:byte);
    private
   	   // internal clock to output sample rate mapping */
   	   pos:dword;						// current output sample position */
   	   step:dword;						// step value per output sample */
    	 //attotime	clock_period;				/* clock period */
   	   //emu_timer *timer;						/* timer */
  	   // I/O lines */
  	   fifo_in:byte;					// last data written to the sound chip */
  	   reset_pin:byte;						// current state of the RESET line */
  	   start:byte;						// current state of the START line */
  	   drq:byte;						// current state of the DRQ line */
    	 // internal state machine */
  	   state:byte;						// current overall chip state */
    	 clocks_left:integer;				// number of clocks left in this state */
       nibbles_left:word;				// number of ADPCM nibbles left to process */
       repeat_count:byte;				// number of repeats remaining in current repeat block */
       post_drq_state:shortint;				// state we will be in after the DRQ line is dropped */
       post_drq_clocks:integer;			// clocks that will be left after the DRQ line is dropped */
    	 req_sample:byte;					// requested sample number */
       last_sample:byte;				// last sample number available */
       block_header:byte;				// header byte *
       sample_rate:byte;				// number of UPD clocks per ADPCM nibble */
       first_valid_header:byte;			// did we get our first valid header yet? */
       offset:dword;						// current ROM offset */
       repeat_offset:dword;				// current ROM repeat offset */
       start_delay:dword;
    	 // ADPCM processing */
       adpcm_state:shortint;				// ADPCM state index */
    	 adpcm_data:byte;					// current byte of ADPCM data */
       sample:integer;						// current sample value */
    	 // ROM access
    	 rom:pbyte;						// pointer to ROM data or NULL for slave mode */
       resample_pos:single;
       resample_inc:single;
       drq_call:tcall_drq;
       mode_standalone:boolean;
       md_pin,slave_timer,instance_slot:byte;
       clock_phase:dword;
       procedure begin_playback;
       procedure allocate_slave_timer;
       procedure slave_tick;
       procedure advance_with_drq;
       function render_master:int64;
       procedure update_adpcm(data:integer);
       procedure advance_state;
  end;

var
  upd7759_0,upd7759_1:upd7759_chip;

implementation

const
  MAX_UPD7759_INSTANCES=16;
  NO_TIMER=$ff;
var
  upd7759_instances:array[0..MAX_UPD7759_INSTANCES-1] of upd7759_chip;

procedure upd7759_slave_callback(slot:byte);
begin
  if slot>=MAX_UPD7759_INSTANCES then exit;
  if upd7759_instances[slot]<>nil then upd7759_instances[slot].slave_tick;
end;

constructor upd7759_chip.create(amp:single;slave:byte=1;call_drq:tcall_drq=nil);
var
  slot:integer;
begin
  self.slave_timer:=NO_TIMER;
  self.instance_slot:=NO_TIMER;
  if not Assigned(update_sound_proc) then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!',mtInformation,[mbOk],0);
  self.step:=4*FRAC_ONE;
  self.mode_standalone:=slave=1;
  self.md_pin:=byte(self.mode_standalone);
  if self.mode_standalone then begin
    GetMem(self.rom,$20000);
    FillChar(self.rom^,$20000,$ff);
  end;
  self.drq_call:=call_drq;
  self.reset_pin:=1;
  self.start:=1;
  self.resample_inc:=CLOCK_UPD/4/FREQ_BASE_AUDIO;
  self.tsample_num:=init_channel;
  self.amp:=amp;
  if not self.mode_standalone then begin
    slot:=0;
    while slot<MAX_UPD7759_INSTANCES do begin
      if upd7759_instances[slot]=nil then break;
      inc(slot);
    end;
    self.instance_slot:=slot;
    upd7759_instances[slot]:=self;
    self.allocate_slave_timer;
  end;
  self.reset;
end;

destructor upd7759_chip.free;
begin
  if (self.slave_timer<>NO_TIMER) and (timers<>nil) then timers.enabled(self.slave_timer,false);
  if self.instance_slot<MAX_UPD7759_INSTANCES then
    if upd7759_instances[self.instance_slot]=self then
      upd7759_instances[self.instance_slot]:=nil;
  if self.rom<>nil then FreeMem(self.rom);
  self.rom:=nil;
  if upd7759_0=self then upd7759_0:=nil;
  if upd7759_1=self then upd7759_1:=nil;
end;

procedure upd7759_chip.allocate_slave_timer;
var
  slot:integer;
begin
  if self.slave_timer<>NO_TIMER then exit;
  if self.instance_slot=NO_TIMER then begin
    slot:=0;
    while slot<MAX_UPD7759_INSTANCES do begin
      if upd7759_instances[slot]=nil then break;
      inc(slot);
    end;
    self.instance_slot:=slot;
    upd7759_instances[slot]:=self;
  end;
  self.slave_timer:=timers.init(sound_status.cpu_num,1,nil,upd7759_slave_callback,false,self.instance_slot);
end;

procedure upd7759_chip.advance_with_drq;
var
  old_drq:byte;
begin
  old_drq:=self.drq;
  self.advance_state;
  if (old_drq<>self.drq) and (@self.drq_call<>nil) then self.drq_call(self.drq);
end;

procedure upd7759_chip.slave_tick;
begin
  if self.mode_standalone or (self.state=STATE_IDLE) then begin
    timers.enabled(self.slave_timer,false);
    exit;
  end;
  self.advance_with_drq;
  if self.mode_standalone or (self.state=STATE_IDLE) then begin
    timers.enabled(self.slave_timer,false);
    exit;
  end;
  while self.clocks_left<=0 do begin
    self.advance_with_drq;
    if self.mode_standalone or (self.state=STATE_IDLE) then begin
      timers.enabled(self.slave_timer,false);
      exit;
    end;
  end;
  timers.timer[self.slave_timer].time_final:=sound_status.cpu_clock*(self.clocks_left/CLOCK_UPD);
end;

procedure upd7759_chip.begin_playback;
begin
  self.state:=STATE_START;
  self.clocks_left:=0;
  self.pos:=0;
  self.clock_phase:=0;
  if not self.mode_standalone then begin
    self.allocate_slave_timer;
    timers.timer[self.slave_timer].actual_time:=0;
    self.slave_tick;
    if self.state<>STATE_IDLE then timers.enabled(self.slave_timer,true);
  end;
end;

procedure upd7759_chip.md_w(data:byte);
var
  old_md:byte;
begin
  old_md:=self.md_pin;
  self.md_pin:=byte(data<>0);
  if (self.state<>STATE_IDLE) or (self.reset_pin=0) then exit;
  if (old_md<>0) and (self.md_pin=0) then begin
    self.mode_standalone:=false;
    self.begin_playback;
  end else if (old_md=0) and (self.md_pin<>0) then begin
    if self.rom=nil then begin
      getmem(self.rom,$20000);
      fillchar(self.rom^,$20000,$ff);
    end;
    self.mode_standalone:=true;
    if self.slave_timer<>NO_TIMER then timers.enabled(self.slave_timer,false);
  end;
end;

procedure upd7759_chip.reset;
var
  old_drq:byte;
begin
  old_drq:=self.drq;
  if (self.slave_timer<>NO_TIMER) and (timers<>nil) then timers.enabled(self.slave_timer,false);
  self.resample_pos:=0;
  self.clock_phase:=0;
	self.pos:=0;
	//self.fifo_in           := 0;
	self.state:=STATE_IDLE;
	self.clocks_left:=0;
	self.nibbles_left:=0;
	self.repeat_count:=0;
	self.post_drq_state:=STATE_IDLE;
	self.post_drq_clocks:=0;
	self.req_sample:=0;
	self.last_sample:=0;
	self.block_header:=0;
	self.sample_rate:=0;
	self.first_valid_header:=0;
	self.offset:=0;
	self.repeat_offset:=0;
	self.adpcm_state:=0;
	self.adpcm_data:=0;
	self.sample:=0;
  self.drq:=0;
  if (old_drq<>0) and (@self.drq_call<>nil) then self.drq_call(0);
end;

function upd7759_chip.get_rom_addr:pbyte;
begin
  get_rom_addr:=self.rom;
end;

procedure upd7759_chip.update_adpcm(data:integer);
begin
	// update the sample and the state */
	self.sample:=self.sample+upd7759_step[self.adpcm_state,data];
	self.adpcm_state:=self.adpcm_state+upd7759_state_table[data];
	// clamp the state to 0..15 */
	if (self.adpcm_state<0) then self.adpcm_state:=0
	  else if (self.adpcm_state>15) then self.adpcm_state:=15;
end;

procedure upd7759_chip.advance_state;
var
  ptemp:pbyte;
begin
	case self.state of
		// Idle state: we stick around here while there's nothing to do */
		STATE_IDLE:self.clocks_left:=4;
		// drop DRQ state: update to the intended state */
		STATE_DROP_DRQ:begin
			  self.drq:=0;
			  self.clocks_left:=self.post_drq_clocks;
			  self.state:=self.post_drq_state;
      end;
		// Start state: we begin here as soon as a sample is triggered */
		STATE_START:begin
			  if self.mode_standalone then self.req_sample:=self.fifo_in
          else self.req_sample:=$10;
	  		self.clocks_left:=70+self.start_delay;	// 35 - breaks cotton */
  			self.state:=STATE_FIRST_REQ;
      end;
		// First request state: issue a request for the first byte */
		// The expected response will be the index of the last sample */
		STATE_FIRST_REQ:begin
			  self.drq:=1;
  			// 44 cycles later, we will latch this value and request another byte */
  			self.clocks_left:=44;
  			self.state:=STATE_LAST_SAMPLE;
			end;
		// Last sample state: latch the last sample value and issue a request for the second byte */
		// The second byte read will be just a dummy */
		STATE_LAST_SAMPLE:begin
  			if self.mode_standalone then self.last_sample:=self.rom^
          else self.last_sample:=self.fifo_in;
  			self.drq:= 1;
  			// 28 cycles later, we will latch this value and request another byte */
  			self.clocks_left:=28;	// 28 - breaks cotton */
  			if (self.req_sample>self.last_sample) then self.state:=STATE_IDLE
          else self.state:=STATE_DUMMY1;
			end;
		// First dummy state: ignore any data here and issue a request for the third byte */
		// The expected response will be the MSB of the sample address */
		STATE_DUMMY1:begin
  			self.drq:=1;
  			// 32 cycles later, we will latch this value and request another byte */
	  		self.clocks_left:= 32;
		  	self.state:=STATE_ADDR_MSB;
			end;
		// Address MSB state: latch the MSB of the sample address and issue a request for the fourth byte */
		// The expected response will be the LSB of the sample address */
		STATE_ADDR_MSB:begin
			if self.mode_standalone then begin
        ptemp:=self.rom;
        inc(ptemp,self.req_sample*2+5);
        self.offset:=ptemp^ shl 9 //sample_offset_shift!!!!!
      end else self.offset:=self.fifo_in shl 9;
			self.drq:=1;
			// 44 cycles later, we will latch this value and request another byte */
			self.clocks_left:=44;
			self.state:=STATE_ADDR_LSB;
    end;
		// Address LSB state: latch the LSB of the sample address and issue a request for the fifth byte */
		// The expected response will be just a dummy */
		STATE_ADDR_LSB:begin
			if self.mode_standalone then begin
        ptemp:=self.rom;
        inc(ptemp,self.req_sample*2+6);
        self.offset:=self.offset or (ptemp^ shl 1)
      end else self.offset:=self.offset or (self.fifo_in shl 1);
			self.drq:=1;
			// 36 cycles later, we will latch this value and request another byte */
			self.clocks_left:=36;
			self.state:=STATE_DUMMY2;
    end;
		// Second dummy state: ignore any data here and issue a request for the the sixth byte */
		// The expected response will be the first block header */
		STATE_DUMMY2:begin
			self.offset:=self.offset+1;
			self.first_valid_header:=0;
			self.drq:=1;
			// 36?? cycles later, we will latch this value and request another byte */
			self.clocks_left:=36;
			self.state:=STATE_BLOCK_HEADER;
    end;
		// Block header state: latch the header and issue a request for the first byte afterwards */
		STATE_BLOCK_HEADER:begin
			// if we're in a repeat loop, reset the offset to the repeat point and decrement the count */
			if (self.repeat_count<>0) then begin
				self.repeat_count:=self.repeat_count-1;
				self.offset:=self.repeat_offset;
			end;
			if self.mode_standalone then begin
        ptemp:=self.rom;
        inc(ptemp,self.offset and $1ffff);
        self.block_header:=ptemp^
      end else self.block_header:=self.fifo_in;
      self.offset:=self.offset+1;
			self.drq:=1;
			// our next step depends on the top two bits */
			case (self.block_header and $c0) of
				$00:begin	// silence */
    					self.clocks_left:=1024*((self.block_header and $3f)+1);
              if ((self.block_header=0) and ((self.first_valid_header and 1)<>0)) then self.state:=STATE_IDLE
                else self.state:=STATE_BLOCK_HEADER;
    					self.sample:=0;
    					self.adpcm_state:=0;
            end;
				$40:begin	// 256 nibbles */
    					self.sample_rate:=(self.block_header and $3f)+1;
    					self.nibbles_left:= 256;
    					self.clocks_left:=36;	// just a guess */
    					self.state:=STATE_NIBBLE_MSN;
            end;
	  		$80:begin	// n nibbles */
    					self.sample_rate:=(self.block_header and $3f)+1;
    					self.clocks_left:=36;	// just a guess */
    					self.state:=STATE_NIBBLE_COUNT;
  					end;
				$c0:begin	// repeat loop */
    					self.repeat_count:=(self.block_header and 7)+1;
    					self.repeat_offset:=self.offset;
    					self.clocks_left:=36;	// just a guess */
    					self.state:=STATE_BLOCK_HEADER;
  					end;
			end;
			// set a flag when we get the first non-zero header */
			if (self.block_header<>0) then self.first_valid_header:=1;
    end;
		// Nibble count state: latch the number of nibbles to play and request another byte */
		// The expected response will be the first data byte */
		STATE_NIBBLE_COUNT:begin
    			if self.mode_standalone then begin
            ptemp:=self.rom;
            inc(ptemp,self.offset and $1ffff);
            self.nibbles_left:=ptemp^+1
          end else self.nibbles_left:=self.fifo_in+1;
          self.offset:=self.offset+1;
    			self.drq:= 1;
    			// 36?? cycles later, we will latch this value and request another byte */
    			self.clocks_left:=36;	// just a guess */
    			self.state:=STATE_NIBBLE_MSN;
			end;
		// MSN state: latch the data for this pair of samples and request another byte */
		// The expected response will be the next sample data or another header */
		STATE_NIBBLE_MSN:begin
			if self.mode_standalone then begin
        ptemp:=self.rom;
        inc(ptemp,self.offset and $1ffff);
        self.adpcm_data:=ptemp^;
      end else self.adpcm_data:=self.fifo_in;
      self.offset:=self.offset+1;
			self.update_adpcm(self.adpcm_data shr 4);
			self.drq:=1;
			// we stay in this state until the time for this sample is complete */
			self.clocks_left:=self.sample_rate*4;
      self.nibbles_left:=self.nibbles_left-1;
			if self.nibbles_left=0 then self.state:=STATE_BLOCK_HEADER
  			else self.state:=STATE_NIBBLE_LSN;
    end;
		// LSN state: process the lower nibble */
		STATE_NIBBLE_LSN:begin
			self.update_adpcm(self.adpcm_data and 15);
			// we stay in this state until the time for this sample is complete */
			self.clocks_left:=self.sample_rate*4;
      self.nibbles_left:=self.nibbles_left-1;
			if (self.nibbles_left=0) then self.state:=STATE_BLOCK_HEADER
  			else self.state:=STATE_NIBBLE_MSN;
    end;
	end;
	// if there's a DRQ, fudge the state */
	if ((self.drq and 1)<>0) then begin
		self.post_drq_state:=self.state;
		self.post_drq_clocks:=self.clocks_left-21;
		self.state:=STATE_DROP_DRQ;
		self.clocks_left:=21;
	end;
end;

procedure upd7759_chip.reset_w(data:byte);
var
  oldreset:byte;
begin
	// update the reset value */
	oldreset:=self.reset_pin;
	if (data<>0) then self.reset_pin:=1
    else self.reset_pin:=0;
	// on the falling edge, reset everything */
	if ((oldreset<>0) and ((not(self.reset_pin) and 1)<>0)) then self.reset;
end;

procedure upd7759_chip.start_w(data:byte);
var oldstart:byte; trigger:boolean;
begin
  oldstart:=self.start;
  self.start:=byte(data<>0);
  if self.mode_standalone then begin
    trigger:=(oldstart<>0) and (self.start=0);
  end else
    // Preserve entry for existing fixed-FIFO drivers; real mode entry is md_w.
    trigger:=(oldstart=0) and (self.start<>0);
  if (self.state=STATE_IDLE) and (self.reset_pin<>0) and trigger then self.begin_playback;
end;

procedure upd7759_chip.port_w(data:byte);
begin
	// update the FIFO value */
	self.fifo_in:=data;
end;

function upd7759_chip.busy_r:byte;
begin
	// return /BUSY */
  if self.state=STATE_IDLE then busy_r:=1
    else busy_r:=0;
end;

function upd7759_chip.render_master:int64;
var
  remaining,chunk,until_event,total_phase:int64;
begin
  result:=0;
  remaining:=CLOCK_UPD;
  while (remaining>0) and (self.state<>STATE_IDLE) do begin
    if self.clocks_left<=0 then begin
      self.advance_with_drq;
      continue;
    end;
    until_event:=int64(self.clocks_left)*FREQ_BASE_AUDIO-self.clock_phase;
    if until_event<remaining then chunk:=until_event else chunk:=remaining;
    result:=result+int64(self.sample)*128*chunk;
    dec(remaining,chunk);
    total_phase:=self.clock_phase+chunk;
    self.clocks_left:=self.clocks_left-integer(total_phase div FREQ_BASE_AUDIO);
    self.clock_phase:=dword(total_phase mod FREQ_BASE_AUDIO);
    if self.clocks_left=0 then self.advance_with_drq;
  end;
end;

procedure upd7759_chip.update;
var
  value,gain:double;out_:integer;
begin
  if self.mode_standalone then value:=self.render_master/CLOCK_UPD
    else if self.state<>STATE_IDLE then value:=self.sample*128.0
            else value:=0;
  gain:=self.amp;
  value:=value*gain;
  if value>32767 then out_:=32767
    else if value< -32768 then out_:=-32768
            else out_:=trunc(value);
  tsample[self.tsample_num,sound_status.posicion_sonido]:=out_;
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=out_;
end;

end.
