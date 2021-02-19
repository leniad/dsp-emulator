unit upd7759;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     sound_engine;

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
       procedure update_adpcm(data:integer);
       procedure advance_state;
  end;

var
  upd7759_0:upd7759_chip;

implementation

constructor upd7759_chip.create(amp:single;slave:byte=1;call_drq:tcall_drq=nil);
begin
	// compute the stepping rate based on the chip's clock speed
	self.step:=4*FRAC_ONE;
	// compute the ROM base or allocate a timer
	if slave=1 then getmem(self.rom,$20000);
	// set the DRQ callback */
	self.drq_call:=call_drq;
	// assume /RESET and /START are both high
	self.reset_pin:=1;
	self.start:=1;
  self.resample_inc:=CLOCK_UPD/4/FREQ_BASE_AUDIO;
	// toggle the reset line to finish the reset
  self.tsample_num:=init_channel;
  self.amp:=amp;
	self.reset;
end;

destructor upd7759_chip.free;
begin
if self.rom<>nil then freemem(self.rom);
self.rom:=nil;
end;

procedure upd7759_chip.reset;
begin
	self.pos               := 0;
	//self.fifo_in           := 0;
	self.state             := STATE_IDLE;
	self.clocks_left       := 0;
	self.nibbles_left      := 0;
	self.repeat_count      := 0;
	self.post_drq_state    := STATE_IDLE;
	self.post_drq_clocks   := 0;
	self.req_sample        := 0;
	self.last_sample       := 0;
	self.block_header      := 0;
	self.sample_rate       := 0;
	self.first_valid_header:= 0;
	self.offset            := 0;
	self.repeat_offset     := 0;
	self.adpcm_state       := 0;
	self.adpcm_data        := 0;
	self.sample            := 0;
  self.drq:=0;
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
			  if self.rom<>nil then self.req_sample:=self.fifo_in
          else self.req_sample:=$10;
		  	{ 35+ cycles after we get here, the /DRQ goes low
             *     (first byte (number of samples in ROM) should be sent in response)
             *
             * (35 is the minimum number of cycles I found during heavy tests.
             * Depending on the state the self was in just before the /MD was set to 0 (reset, standby
             * or just-finished-playing-previous-sample) this number can range from 35 up to ~24000).
             * It also varies slightly from test to test, but not much - a few cycles at most.) }
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
  			if self.rom<>nil then self.last_sample:=self.rom^
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
			if self.rom<>nil then begin
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
			if self.rom<>nil then begin
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
			if self.rom<>nil then begin
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
    			if (self.rom<>nil) then begin
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
			if self.rom<>nil then begin
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
var
  oldstart:byte;
begin
	// update the start value */
	oldstart:=self.start;
	if (data<>0) then self.start:=1
    else self.start:=0;
	// on the rising edge, if we're idle, start going, but not if we're held in reset */
	if ((self.state=STATE_IDLE) and ((not(oldstart) and 1)<>0) and ((self.start and 1)<>0) and ((self.reset_pin and 1)<>0)) then begin
		self.state:=STATE_START;
		// for slave mode, start the timer going */
 {		if (chip->timer)
			timer_adjust_oneshot(chip->timer, attotime_zero, 0);}
	end;
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

procedure upd7759_chip.update;
var
  clocks_this_time,clocks_left:integer;
  step,pos:dword;
  out_:integer;
  num_samples,old_drq:byte;
begin
	clocks_left:=self.clocks_left;
  step:=self.step;
  pos:=self.pos;
  out_:=0;
  self.resample_pos:=self.resample_pos+self.resample_inc;
  num_samples:=trunc(self.resample_pos);
  self.resample_pos:=self.resample_pos-num_samples;
	// loop until done */
	if (self.state<>STATE_IDLE) then begin
    while (num_samples<>0) do begin
			// store the current sample */
			out_:=self.sample shl 7;
			// advance by the number of clocks/output sample */
			pos:=pos+step;
			// handle clocks, but only in standalone mode */
			while (pos>=FRAC_ONE) do begin
				clocks_this_time:=pos shr FRAC_BITS;
				if (clocks_this_time>clocks_left) then clocks_this_time:=clocks_left;
				// clock once */
				pos:=pos-(clocks_this_time*FRAC_ONE);
				clocks_left:=clocks_left-clocks_this_time;
				// if we're out of clocks, time to handle the next state */
				if (clocks_left=0) then begin
					// advance one state; if we hit idle, bail */
          old_drq:=self.drq;
					self.advance_state;
          if old_drq<>self.drq then begin
            if @self.drq_call<>nil then self.drq_call(self.drq);
          end;
					if (self.state=STATE_IDLE) then break;
					// reimport the variables that we cached */
					clocks_left:=self.clocks_left;
          out_:=(out_+(self.sample*64)) div 2;
				end;
      end;
      num_samples:=num_samples-1;
	  end;
  end;
	// flush the state back */
	self.clocks_left:= clocks_left;
	self.pos:=pos;
  if out_>32767 then out_:=32767
    else if out_<-32768 then out_:=-32768;
  tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc(out_*self.amp);
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=trunc(out_*self.amp);
end;

end.