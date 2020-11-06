unit n2a03;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     cpu_misc,sound_engine,timer_engine,main_engine,m6502,misc_functions;

const
  // GLOBAL CONSTANTS */
  SYNCS_MAX1=$20;
  SYNCS_MAX2=$80;
  TOTAL_BUFFER_SIZE=150;

// CHANNEL TYPE DEFINITIONS */
type
  tcall_frame_irq=procedure (status:byte);
  tadditional_sound=procedure;
  square_t=packed record // Square Wave */
	  regs:array[0..3] of byte;
	  vbl_length:integer;
	  freq:integer;
	  phaseacc:single;
    env_phase:single;
    sweep_phase:single;
    adder:byte;
    env_vol:byte;
    enabled:boolean;
  end;
  psquare_t=^square_t;
  triangle_t=packed record // Triangle Wave */
	  regs:array[0..3] of byte; // regs[1] unused */
	  linear_length:integer;
    vbl_length:integer;
    write_latency:integer;
    phaseacc:single;
    output_vol:shortint;
    adder:byte;
    counter_started:boolean;
    enabled:boolean;
  end;
  ptriangle_t=^triangle_t;
  noise_t=packed record // Noise Wave */
	  regs:array[0..3] of byte; // regs[1] unused */
    seed:dword;
    vbl_length:integer;
    phaseacc:single;
    env_phase:single;
    env_vol:byte;
    enabled:boolean;
  end;
  pnoise_t=^noise_t;
  dpcm_t=packed record // DPCM Wave */
    regs:array[0..3] of byte;
    address:word;
    length:dword;
    bits_left:integer;
    phaseacc:single;
    cur_byte:byte;
    enabled:boolean;
    irq:boolean;
    output:smallint;
    getbyte:tgetbyte;
  end;
  pdpcm_t=^dpcm_t;
  apu_t=packed record // APU type */
	  // Sound channels */
	  squ:array[0..1] of psquare_t;
    tri:ptriangle_t;
    noi:pnoise_t;
    dpcm:pdpcm_t;
	  // APU registers */
	  regs:array[0..$17] of byte;
    step_mode:integer;
  end;
  papu_t=^apu_t;
  cpu_n2a03=class
    constructor Create(clock:dword;frames:word);
    destructor free;
    public
      m6502:cpu_m6502;
      additional_sound:tadditional_sound;
      procedure reset;
      function read(direccion:word):byte;
      procedure write(posicion:word;value:byte);
      procedure change_internals(read_byte_dpcm:tgetbyte);
      procedure add_more_sound(additional_sound:tadditional_sound);
      function save_snapshot(data:pbyte):word;
      procedure load_snapshot(data:pbyte);
    private
      apu:papu_t;			       // Actual APUs */
      samps_per_sync:dword;        // Number of samples per vsync */
      vbl_times:array[0..$1f] of dword;       // VBL durations in samples */
      sync_times1:array[0..(SYNCS_MAX1-1)] of dword; // Samples per sync table */
      sync_times2:array[0..(SYNCS_MAX2-1)] of dword; // Samples per sync table */
      buffer:array[1..TOTAL_BUFFER_SIZE] of integer;
      buffer_pos:byte;
      num_sample:byte;
      frame_irq_timer:byte;
      old_res:integer;
      frame_irq:boolean;
      frame_call_irq:tcall_frame_irq;
      procedure apu_regwrite(address,value:byte);
      procedure create_vbltimes(rate:dword);
      procedure create_syncs(sps:dword);
      function apu_square(chan:byte):integer;
      function apu_triangle:integer;
      function apu_noise:integer;
      function apu_dpcm:integer;
      procedure sound_advance;
      procedure sound_update;
  end;

var
    n2a03_0,n2a03_1:cpu_n2a03;

procedure n2a03_sound_advance(index:byte);
procedure n2a03_update_sound_0;
procedure n2a03_update_sound(index:byte);
procedure n2a03_irq_call(index:byte);

implementation

var
  chips_total:integer=-1;
const
  APU_WRA0=$00;
  APU_WRA1=$01;
  APU_WRA2=$02;
  APU_WRA3=$03;
  APU_WRB0=$04;
  APU_WRB1=$05;
  APU_WRB2=$06;
  APU_WRB3=$07;
  APU_WRC0=$08;
  APU_WRC2=$0A;
  APU_WRC3=$0B;
  APU_WRD0=$0C;
  APU_WRD2=$0E;
  APU_WRD3=$0F;
  APU_WRE0=$10;
  APU_WRE1=$11;
  APU_WRE2=$12;
  APU_WRE3=$13;
  APU_SMASK=$15;
  APU_IRQCTRL=$17;

// CONSTANTS */

// vblank length table used for squares, triangle, noise */
vbl_length:array[0..31] of byte=(
   5, 127, 10, 1, 19,  2, 40,  3, 80,  4, 30,  5, 7,  6, 13,  7,
   6,   8, 12, 9, 24, 10, 48, 11, 96, 12, 36, 13, 8, 14, 16, 15);
// frequency limit of square channels */
freq_limit:array[0..7] of word=($3FF,$555,$666,$71C,$787,$7C1,$7E0,$7F0);
// table of noise frequencies */
noise_freq:array[0..15] of word=(
   4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 2046);
// dpcm transfer freqs */
dpcm_clocks:array[0..15] of word=(
   428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 85, 72, 54);
// ratios of pos/neg pulse for square waves */
// 2/16 = 12.5%, 4/16 = 25%, 8/16 = 50%, 12/16 = 75% */
duty_lut:array[0..3] of byte=(2,4,8,12);

function sshr(num:integer;fac:byte):integer;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

function cpu_n2a03.save_snapshot(data:pbyte):word;
begin

end;

procedure cpu_n2a03.load_snapshot(data:pbyte);
begin

end;

// INITIALIZE WAVE TIMES RELATIVE TO SAMPLE RATE */
procedure cpu_n2a03.create_vbltimes(rate:dword);
var
	i:integer;
begin
	for i:=0 to $1f do self.vbl_times[i]:=vbl_length[i]*rate;
end;

// INITIALIZE SAMPLE TIMES IN TERMS OF VSYNCS */
procedure cpu_n2a03.create_syncs(sps:dword);
var
	i:integer;
	val:dword;
begin
  val:=sps;
	for i:=0 to (SYNCS_MAX1-1) do begin
		self.sync_times1[i]:=val;
		val:=val+sps;
	end;
	val:=0;
	for i:=0 to (SYNCS_MAX2-1) do begin
		self.sync_times2[i]:=val;
		self.sync_times2[i]:=sshr(self.sync_times2[i],2);
		val:=val+sps;
	end;
end;

constructor cpu_n2a03.create(clock:dword;frames:word);
var
  rate:integer;
begin
  self.m6502:=cpu_m6502.Create(clock,frames,TCPU_NES);
  getmem(self.apu,sizeof(apu_t));
  getmem(self.apu.squ[0],sizeof(square_t));
  getmem(self.apu.squ[1],sizeof(square_t));
  getmem(self.apu.tri,sizeof(triangle_t));
  getmem(self.apu.noi,sizeof(noise_t));
  getmem(self.apu.dpcm,sizeof(dpcm_t));
  // Initialize global variables */
  rate:=clock div 4;
  self.samps_per_sync:=round(rate/llamadas_maquina.fps_max);
  // Use initializer calls */
  self.create_vbltimes(self.samps_per_sync);
  self.create_syncs(self.samps_per_sync);
  chips_total:=chips_total+1;
  self.frame_irq_timer:=timers.init(self.m6502.numero_cpu,29830,nil,n2a03_irq_call,false,chips_total);
  if chips_total=0 then self.m6502.init_sound(n2a03_update_sound_0)
    else timers.init(self.m6502.numero_cpu,clock/FREQ_BASE_AUDIO,nil,n2a03_update_sound,true,chips_total);
  //Crear aqui este timer es muy IMPORTANTE, por el orden despues
  timers.init(self.m6502.numero_cpu,4,nil,n2a03_sound_advance,true,chips_total);
  self.num_sample:=init_channel;
  self.apu.dpcm.getbyte:=nil;
  self.frame_call_irq:=nil;
  self.additional_sound:=nil;
end;

procedure cpu_n2a03.change_internals(read_byte_dpcm:tgetbyte);
begin
  self.apu.dpcm.getbyte:=read_byte_dpcm;
end;

procedure cpu_n2a03.add_more_sound(additional_sound:tadditional_sound);
begin
    self.additional_sound:=additional_sound;
end;

destructor cpu_n2a03.free;
begin
  freemem(self.apu.squ[0]);
  self.apu.squ[0]:=nil;
  freemem(self.apu.squ[1]);
  self.apu.squ[1]:=nil;
  freemem(self.apu.tri);
  self.apu.tri:=nil;
  freemem(self.apu.noi);
  self.apu.noi:=nil;
  freemem(self.apu.dpcm);
  self.apu.dpcm:=nil;
  freemem(self.apu);
  self.apu:=nil;
  self.m6502.Free;
  chips_total:=chips_total-1;
end;

procedure cpu_n2a03.reset;
var
  f:byte;
begin
  fillchar(self.apu.squ[0]^,sizeof(square_t),0);
  fillchar(self.apu.squ[1]^,sizeof(square_t),0);
  fillchar(self.apu.tri^,sizeof(triangle_t),0);
  fillchar(self.apu.noi^,sizeof(noise_t),0);
  self.apu.noi.seed:=1;
  for f:=0 to 3 do self.apu.dpcm.regs[f]:=0;
  self.apu.dpcm.address:=$c000;
  self.apu.dpcm.length:=1;
  self.apu.dpcm.bits_left:=8;
  self.apu.dpcm.phaseacc:=dpcm_clocks[0];
  self.apu.dpcm.cur_byte:=0;
  self.apu.dpcm.enabled:=false;
  self.apu.dpcm.irq:=false;
  self.apu.dpcm.output:=0;
  fillchar(self.apu.regs[0],$17,0);
  fillchar(self.buffer[1],TOTAL_BUFFER_SIZE*sizeof(integer),0);
  self.apu.step_mode:=0;
  self.buffer_pos:=1;
  self.frame_irq:=false;
  timers.enabled(self.frame_irq_timer,false);
  self.m6502.reset;
end;

procedure apu_dpcmreset(dpcm:pdpcm_t);
begin
  dpcm.address:=$c000+(dpcm.regs[2] shl 6);
  dpcm.length:=(dpcm.regs[3] shl 4)+1;
  dpcm.bits_left:=8;
  dpcm.irq:=(dpcm.regs[0] and $80)<>0;
  dpcm.enabled:=true;
  dpcm.output:=0;
end;

// WRITE REGISTER VALUE */
procedure cpu_n2a03.apu_regwrite(address,value:byte);
var
  chan:byte;
begin
  if (address and 4)<>0 then chan:=1
    else chan:=0;
	case address of
    // squares
	  APU_WRA0,APU_WRB0:self.apu.squ[chan].regs[0]:=value;
	  APU_WRA1,APU_WRB1:self.apu.squ[chan].regs[1]:=value;
	  APU_WRA2,APU_WRB2:begin
        self.apu.squ[chan].regs[2]:=value;
		    if (self.apu.squ[chan].enabled) then self.apu.squ[chan].freq:=((((self.apu.squ[chan].regs[3] and 7) shl 8)+value)+1) shl 16;
		  end;
	  APU_WRA3,APU_WRB3:begin
		    self.apu.squ[chan].regs[3]:=value;
		    if self.apu.squ[chan].enabled then begin
			    self.apu.squ[chan].vbl_length:=self.vbl_times[value shr 3];
			    self.apu.squ[chan].env_vol:=0;
			    self.apu.squ[chan].freq:=((((value and 7) shl 8)+self.apu.squ[chan].regs[2])+1) shl 16;
		    end;
		  end;
	  // triangle */
	  APU_WRC0:begin
		    self.apu.tri.regs[0]:=value;
		    if self.apu.tri.enabled then begin
			    if not(self.apu.tri.counter_started) then self.apu.tri.linear_length:=self.sync_times2[value and $7F];
		    end;
      end;
	  $09:self.apu.tri.regs[1]:=value;	// unused */
	  APU_WRC2:self.apu.tri.regs[2]:=value;
	  APU_WRC3:begin
        self.apu.tri.regs[3]:=value;
		    {this is somewhat of a hack.  there is some latency on the Real
        ** Thing between when trireg0 is written to and when the linear
        ** length counter actually begins its countdown.  we want to prevent
        ** the case where the program writes to the freq regs first, then
        ** to reg 0, and the counter accidentally starts running because of
        ** the sound queue's timestamp processing.
        **
        ** set to a few NES sample -- should be sufficient
        **
        **    3 * (1789772.727 / 44100) = ~122 cycles, just around one scanline
        **
        ** should be plenty of time for the 6502 code to do a couple of table
        ** dereferences and load up the other triregs}

	      // used to be 3, but now we run the clock faster, so base it on samples/sync */
		    self.apu.tri.write_latency:=trunc((self.samps_per_sync+239)/240);
		    if self.apu.tri.enabled then begin
    			self.apu.tri.counter_started:=false;
    			self.apu.tri.vbl_length:=self.vbl_times[value shr 3];
    			self.apu.tri.linear_length:=self.sync_times2[apu.tri.regs[0] and $7f];
        end;
    end;
	  // noise */
	  APU_WRD0:self.apu.noi.regs[0]:=value;
	  $0D:self.apu.noi.regs[1]:=value; // unused */
	  APU_WRD2:self.apu.noi.regs[2]:=value;
	  APU_WRD3:begin
        self.apu.noi.regs[3]:=value;
		    if self.apu.noi.enabled then begin
    			self.apu.noi.vbl_length:=self.vbl_times[value shr 3];
		    	self.apu.noi.env_vol:=0; // reset envelope */
		    end;
		  end;
	  // DMC */
	  APU_WRE0:begin
		      self.apu.dpcm.regs[0]:=value;
		      self.apu.dpcm.irq:=(value and $80)<>0;
		  end;
	  APU_WRE1:begin // 7-bit DAC */
		    self.apu.dpcm.output:=(value and $7f)-64;
		  end;
	  APU_WRE2:begin
                self.apu.dpcm.regs[2]:=value;
                self.apu.dpcm.address:=$c000+(value shl 6);
             end;
	  APU_WRE3:begin
                self.apu.dpcm.regs[3]:=value;
                self.apu.dpcm.length:=(value shl 4)+1;
             end;
	  APU_IRQCTRL:if (value and $80)<>0 then begin
                    self.apu.step_mode:=5;
                    timers.enabled(self.frame_irq_timer,false);
                  end else begin
                    self.apu.step_mode:=4;
                    timers.enabled(self.frame_irq_timer,true);
                    n2a03_0.frame_irq:=(value and $40)=0;
                  end;
	  APU_SMASK:begin
        //Necesario para TimeLord!!!!
        self.apu.dpcm.irq:=false;
    		if (value and $01)<>0 then self.apu.squ[0].enabled:=true
		    else begin
    			self.apu.squ[0].enabled:=false;
    			self.apu.squ[0].vbl_length:=0;
		    end;
    		if (value and $02)<>0 then self.apu.squ[1].enabled:=true
		      else begin
    			  self.apu.squ[1].enabled:=false;
		    	  self.apu.squ[1].vbl_length:=0;
		      end;
    		if (value and $04)<>0 then self.apu.tri.enabled:=true
      		else begin
      			self.apu.tri.enabled:=false;
      			self.apu.tri.vbl_length:=0;
      			self.apu.tri.linear_length:=0;
      			self.apu.tri.counter_started:=false;
      			self.apu.tri.write_latency:=0;
      		end;
    		if (value and $08)<>0 then self.apu.noi.enabled:=true
		      else begin
      			self.apu.noi.enabled:=false;
    			  self.apu.noi.vbl_length:=0;
    		  end;
    		if (value and $10)<>0 then begin
    			// only reset dpcm values if DMA is finished */
		    	if not(self.apu.dpcm.enabled) then begin
    				self.apu.dpcm.enabled:=true;
            apu_dpcmreset(self.apu.dpcm);
			    end;
		    end else self.apu.dpcm.enabled:=false;
      end;
  end;
end;

// READ VALUES FROM REGISTERS */
function cpu_n2a03.read(direccion:word):byte;
var
  address,readval:byte;
begin
  address:=direccion and $ff;
	if (address=$15) then begin
		readval:=0;
		if self.apu.squ[0].vbl_length<>0 then readval:=readval or 1;
		if self.apu.squ[1].vbl_length<>0 then readval:=readval or 2;
		if self.apu.tri.vbl_length<>0 then readval:=readval or 4;
		if self.apu.noi.vbl_length<>0 then readval:=readval or 8;
		if self.apu.dpcm.length<>0 then readval:=readval or $10;
    if self.frame_irq then readval:=readval or $40;
		if self.apu.dpcm.irq then readval:=readval or $80;
    self.frame_irq:=false;
	end else readval:=self.apu.regs[address];
  read:=readval;
end;

// WRITE VALUE TO TEMP REGISTRY AND QUEUE EVENT */
procedure cpu_n2a03.write(posicion:word;value:byte);
var
  address:byte;
begin
  address:=posicion and $ff;
	self.apu.regs[address]:=value;
	self.apu_regwrite(address,value);
end;

// OUTPUT SQUARE WAVE SAMPLE (VALUES FROM -16 to +15) */
function cpu_n2a03.apu_square(chan:byte):integer;
var
	env_delay,sweep_delay:integer;
  output_:shortint;
begin
	{ reg0: 0-3=volume, 4=envelope, 5=hold, 6-7=duty cycle
    ** reg1: 0-2=sweep shifts, 3=sweep inc/dec, 4-6=sweep length, 7=sweep on
    ** reg2: 8 bits of freq
    ** reg3: 0-2=high freq, 7-4=vbl length counter}
	if not(self.apu.squ[chan].enabled) then begin
    apu_square:=0;
    exit;
  end;
	// enveloping */
	env_delay:=self.sync_times1[self.apu.squ[chan].regs[0] and $f];
	// decay is at a rate of (env_regs + 1) / 240 secs */
	self.apu.squ[chan].env_phase:=self.apu.squ[chan].env_phase-4;
	while (self.apu.squ[chan].env_phase<0) do begin
		self.apu.squ[chan].env_phase:=self.apu.squ[chan].env_phase+env_delay;
		if (self.apu.squ[chan].regs[0] and $20)<>0 then self.apu.squ[chan].env_vol:=(self.apu.squ[chan].env_vol+1) and 15
		  else if (self.apu.squ[chan].env_vol<15) then self.apu.squ[chan].env_vol:=self.apu.squ[chan].env_vol+1;
	end;
	// vbl length counter */
	if ((self.apu.squ[chan].vbl_length>0) and ((self.apu.squ[chan].regs[0] and $20)=0)) then self.apu.squ[chan].vbl_length:=self.apu.squ[chan].vbl_length-1;
	if (self.apu.squ[chan].vbl_length=0) then begin
    apu_square:=0;
    exit;
  end;
	// freqsweeps */
	if (((self.apu.squ[chan].regs[1] and $80)<>0) and ((self.apu.squ[chan].regs[1] and 7)<>0)) then begin
		sweep_delay:=self.sync_times1[(self.apu.squ[chan].regs[1] shr 4) and 7];
		self.apu.squ[chan].sweep_phase:=self.apu.squ[chan].sweep_phase-2;
		while (self.apu.squ[chan].sweep_phase<0) do begin
			self.apu.squ[chan].sweep_phase:=self.apu.squ[chan].sweep_phase+sweep_delay;
			if (self.apu.squ[chan].regs[1] and 8)<>0 then self.apu.squ[chan].freq:=self.apu.squ[chan].freq-sshr(self.apu.squ[chan].freq,(self.apu.squ[chan].regs[1] and 7))
			  else self.apu.squ[chan].freq:=self.apu.squ[chan].freq+sshr(self.apu.squ[chan].freq,(self.apu.squ[chan].regs[1] and 7));
		end;
	end;
	if ((((self.apu.squ[chan].regs[1] and 8)=0) and (sshr(self.apu.squ[chan].freq,16)>freq_limit[self.apu.squ[chan].regs[1] and 7])) or (sshr(self.apu.squ[chan].freq,16)<4)) then begin
		apu_square:=0;
    exit;
  end;
	self.apu.squ[chan].phaseacc:=self.apu.squ[chan].phaseacc-4; // # of cycles per sample */
	while (self.apu.squ[chan].phaseacc<0) do begin
		self.apu.squ[chan].phaseacc:=self.apu.squ[chan].phaseacc+sshr(self.apu.squ[chan].freq,16);
		self.apu.squ[chan].adder:=(self.apu.squ[chan].adder+1) and $0F;
	end;
	if (self.apu.squ[chan].regs[0] and $10)<>0 then output_:=self.apu.squ[chan].regs[0] and $0F
	  else output_:=$0F-self.apu.squ[chan].env_vol;
	if (self.apu.squ[chan].adder<(duty_lut[self.apu.squ[chan].regs[0] shr 6])) then output_:=-output_;
  apu_square:=shortint(output_);
end;

// OUTPUT TRIANGLE WAVE SAMPLE (VALUES FROM -16 to +15) */
function cpu_n2a03.apu_triangle:integer;
var
	freq:word;
	output_:integer;
begin
	{ reg0: 7=holdnote, 6-0=linear length counter
    ** reg2: low 8 bits of frequency
    ** reg3: 7-3=length counter, 2-0=high 3 bits of frequency}
  apu_triangle:=0;
	if not(self.apu.tri.enabled) then exit;
	if (not(self.apu.tri.counter_started) and ((self.apu.tri.regs[0] and $80)=0)) then begin
		if (self.apu.tri.write_latency)<>0 then self.apu.tri.write_latency:=self.apu.tri.write_latency-1;
		if (self.apu.tri.write_latency=0) then self.apu.tri.counter_started:=true;
	end;
	if (self.apu.tri.counter_started) then begin
		if (self.apu.tri.linear_length>0) then self.apu.tri.linear_length:=self.apu.tri.linear_length-1;
		if ((self.apu.tri.vbl_length<>0) and ((self.apu.tri.regs[0] and $80)=0)) then self.apu.tri.vbl_length:=self.apu.tri.vbl_length-1;
		if (self.apu.tri.vbl_length=0) then exit;
	end;
	if (self.apu.tri.linear_length=0) then exit;
	freq:=(((self.apu.tri.regs[3] and 7) shl 8)+self.apu.tri.regs[2])+1;
	if (freq<4) then exit; // inaudible */
	self.apu.tri.phaseacc:=self.apu.tri.phaseacc-4; // # of cycles per sample
	while (self.apu.tri.phaseacc<0) do begin
		self.apu.tri.phaseacc:=self.apu.tri.phaseacc+freq;
		self.apu.tri.adder:=(self.apu.tri.adder+1) and $1f;
		output_:=(self.apu.tri.adder and 7) shl 1;
		if (self.apu.tri.adder and 8)<>0 then output_:=$10-output_;
		if (self.apu.tri.adder and $10)<>0 then output_:=-output_;
		self.apu.tri.output_vol:=output_;
	end;
	apu_triangle:=self.apu.tri.output_vol;
end;

// OUTPUT NOISE WAVE SAMPLE (VALUES FROM -16 to +15) */
function cpu_n2a03.apu_noise:integer;
var
	freq,env_delay:integer;
	outvol,output_:byte;
begin
	 {reg0: 0-3=volume, 4=envelope, 5=hold
    ** reg2: 7=small(93 byte) sample,3-0=freq lookup
    ** reg3: 7-4=vbl length counter}
	if not(self.apu.noi.enabled) then begin
    apu_noise:=0;
    exit;
  end;
	// enveloping */
	env_delay:=self.sync_times1[self.apu.noi.regs[0] and $0f];
	// decay is at a rate of (env_regs + 1) / 240 secs */
	self.apu.noi.env_phase:=self.apu.noi.env_phase-4;
	while (self.apu.noi.env_phase<0) do begin
		self.apu.noi.env_phase:=self.apu.noi.env_phase+env_delay;
		if (self.apu.noi.regs[0] and $20)<>0 then self.apu.noi.env_vol:=(self.apu.noi.env_vol+1) and 15
		  else if (self.apu.noi.env_vol<15) then self.apu.noi.env_vol:=self.apu.noi.env_vol+1;
	end;
	// length counter */
	if (self.apu.noi.regs[0] and $20)=0 then begin
		if (self.apu.noi.vbl_length>0) then self.apu.noi.vbl_length:=self.apu.noi.vbl_length-1;
	end;
	if self.apu.noi.vbl_length=0 then begin
		apu_noise:=0;
    exit;
  end;
	freq:=noise_freq[self.apu.noi.regs[2] and $0f];
	self.apu.noi.phaseacc:=self.apu.noi.phaseacc-4; // # of cycles per sample */
	while (self.apu.noi.phaseacc<0) do begin
    self.apu.noi.phaseacc:=self.apu.noi.phaseacc+freq;
    if (self.apu.noi.regs[2] and $80)<>0 then
          self.apu.noi.seed:=(self.apu.noi.seed shr 1) or ((BIT_n(self.apu.noi.seed,0) xor BIT_n(self.apu.noi.seed,6)) shl 14)
          else self.apu.noi.seed:= (self.apu.noi.seed shr 1) or ((BIT_n(self.apu.noi.seed,0) xor BIT_n(self.apu.noi.seed, 1)) shl 14);
	end;
	if (self.apu.noi.regs[0] and $10)<>0 then outvol:=self.apu.noi.regs[0] and $f
	  else outvol:=$0F-self.apu.noi.env_vol;
	output_:=self.apu.noi.seed and $ff;
	if (output_>outvol) then output_:=outvol;
	if (self.apu.noi.seed and $80)<>0 then apu_noise:=-output_
    else apu_noise:=output_;
end;

// OUTPUT DPCM WAVE SAMPLE
function cpu_n2a03.apu_dpcm:integer;
var
  freq:integer;
begin
  if not(self.apu.dpcm.enabled) then begin
    apu_dpcm:=0;
    exit;
  end;
  freq:=dpcm_clocks[self.apu.dpcm.regs[0] and $0f];
  self.apu.dpcm.phaseacc:=self.apu.dpcm.phaseacc-4; // # of cycles per sample
  while (self.apu.dpcm.phaseacc<0) do begin
      self.apu.dpcm.phaseacc:=self.apu.dpcm.phaseacc+freq;
      if (self.apu.dpcm.bits_left=0) then begin
          self.apu.dpcm.bits_left:=8;
			    self.apu.dpcm.cur_byte:=self.apu.dpcm.getbyte(self.apu.dpcm.address);
          if self.apu.dpcm.address=$ffff then self.apu.dpcm.address:=$8000
             else self.apu.dpcm.address:=self.apu.dpcm.address+1;
				  self.apu.dpcm.length:=self.apu.dpcm.length-1;
      end;
      self.apu.dpcm.bits_left:=self.apu.dpcm.bits_left-1;
      if (self.apu.dpcm.cur_byte and (1 shl self.apu.dpcm.bits_left))<>0 then begin
          if (self.apu.dpcm.output<126) then self.apu.dpcm.output:=self.apu.dpcm.output+2;
      end else begin
          if (self.apu.dpcm.output>1) then self.apu.dpcm.output:=self.apu.dpcm.output-2;
      end;
      if (self.apu.dpcm.length=0) then begin
          self.apu.dpcm.enabled:=false; // Fixed * Proper DPCM channel ENABLE/DISABLE flag behaviour*/
          self.apu.dpcm.output:=0; // Fixed * DPCM DAC resets itself when restarted
          if (self.apu.dpcm.regs[0] and $40)<>0 then begin  //Loop
					    apu_dpcmreset(self.apu.dpcm);
          end else begin // Final - IRQ Generator
              if self.apu.dpcm.irq then n2a03_0.m6502.change_irq(HOLD_LINE);
					    break;
          end;
      end;
  end; //while
	apu_dpcm:=self.apu.dpcm.output;
end;

procedure cpu_n2a03.sound_advance;
var
  tnd_out,pulse_out:single;
begin
    pulse_out:=0.00752*(self.apu_square(0)+self.apu_square(1));
    tnd_out:=0.00851*self.apu_triangle+0.00494*self.apu_noise+0.00335*self.apu_dpcm;
    self.buffer[self.buffer_pos]:=trunc((pulse_out+tnd_out)*255) shl 7;
    self.buffer_pos:=self.buffer_pos+1;
end;

procedure cpu_n2a03.sound_update;
var
  f:byte;
  res:integer;
begin  //Resample from 447443hz to 44100hz
res:=0;
if self.buffer_pos>11 then begin
  for f:=1 to 11 do res:=res+self.buffer[f];
  res:=res div 11;
  for f:=12 to self.buffer_pos do self.buffer[f-11]:=self.buffer[f];
  self.buffer_pos:=self.buffer_pos-11;
end else res:=self.old_res;
tsample[self.num_sample,sound_status.posicion_sonido]:=res;
self.old_res:=res;
if @self.additional_sound<>nil then self.additional_sound;
end;

procedure n2a03_update_sound_0;
begin
  n2a03_0.sound_update;
end;

procedure n2a03_update_sound(index:byte);
begin
  case index of
    1:n2a03_1.sound_update;
  end;
end;

procedure n2a03_sound_advance(index:byte);
begin
  case index of
    0:n2a03_0.sound_advance;
    1:n2a03_1.sound_advance;
  end;
end;

procedure n2a03_irq_call(index:byte);
begin
  case index of
    0:if n2a03_0.frame_irq then n2a03_0.m6502.change_irq(HOLD_LINE);
    1:if n2a03_1.frame_irq then n2a03_1.m6502.change_irq(HOLD_LINE);
  end;
end;

end.
