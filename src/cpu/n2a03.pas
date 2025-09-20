unit n2a03;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     cpu_misc,sound_engine,timer_engine,main_engine,m6502;

const
  // GLOBAL CONSTANTS
  SYNCS_MAX1=$20;
  SYNCS_MAX2=$80;
  TOTAL_BUFFER_SIZE=200;
// CHANNEL TYPE DEFINITIONS
type
  tcall_frame_irq=procedure (status:byte);
  tadditional_sound=procedure;
  square_t=packed record // Square Wave
	  regs:array[0..3] of byte;
	  vbl_length:integer;
	  freq:integer;
	  phaseacc:integer;
    env_phase:integer;
    sweep_phase:integer;
    adder:byte;
    env_vol:byte;
    enabled:boolean;
    output_:byte;
  end;
  triangle_t=packed record // Triangle Wave
	  regs:array[0..3] of byte; // regs[1] unused
	  linear_length:integer;
    vbl_length:integer;
    write_latency:integer;
    phaseacc:integer;
    adder:byte;
    counter_started:boolean;
    enabled:boolean;
    output_:integer;
    linear_reload:boolean;
  end;
  noise_t=packed record // Noise Wave
	  regs:array[0..3] of byte; // regs[1] unused
    lfsr:dword;
    vbl_length:integer;
    phaseacc:integer;
    env_phase:integer;
    env_vol:byte;
    enabled:boolean;
    output_:byte;
  end;
  dpcm_t=packed record // DPCM Wave
    regs:array[0..3] of byte;
    address:dword;
    length:word;
    bits_left:byte;
    phaseacc:integer;
    cur_byte:byte;
    enabled:boolean;
    irq:boolean;
    output_:byte;
    vol:byte;
  end;
  apu_t=packed record // APU type
	  // Sound channels
	  squ:array[0..1] of square_t;
    tri:triangle_t;
    noi:noise_t;
    dpcm:dpcm_t;
	  // APU registers
	  regs:array[0..$17] of byte;
    step_mode:integer;
  end;
  cpu_n2a03=class(snd_chip_class)
      constructor create(clock:dword;frames:word);
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
      apu:apu_t;			       // Actual APUs
      samps_per_sync:dword;        // Number of samples per vsync
      buffer:array[1..TOTAL_BUFFER_SIZE] of single;
      buffer_pos:byte;
      frame_irq_timer:byte;
      old_res:single;
      frame_irq:boolean;
      frame_call_irq:tcall_frame_irq;
      dpcm_getbyte:tgetbyte;
      procedure apu_regwrite(address,value:byte);
      procedure apu_square(chan:byte);
      procedure apu_triangle;
      procedure apu_noise;
      procedure apu_dpcm;
      procedure apu_dpcm_reset;
      procedure sound_advance;
      procedure sound_update;
  end;

var
    n2a03_0,n2a03_1:cpu_n2a03;

implementation
var
  chips_total:integer=-1;
  vbl_times:array[0..$1f] of dword;       // VBL durations in samples
  sync_times1:array[0..(SYNCS_MAX1-1)] of dword; // Samples per sync table
  sync_times2:array[0..(SYNCS_MAX2-1)] of dword; // Samples per sync table
  square_lut:array[0..31] of single;
  tnd_lut:array[0..15,0..15,0..127] of single;
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
  // vblank length table used for squares, triangle, noise
  vbl_length:array[0..31] of byte=(
     10, 254, 20,  2, 40,  4, 80,  6, 160,  8, 60, 10, 14, 12, 26, 14,
	   12,  16, 24, 18, 48, 20, 96, 22, 192, 24, 72, 26, 16, 28, 32, 30);
  //frequency limit of square channels
  freq_limit:array[0..7] of word=($3FF,$555,$666,$71C,$787,$7C1,$7E0,$7F0);
  // table of noise frequencies
  noise_freq:array[0..15] of word=(
   4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 4068);
  // dpcm transfer freqs
  dpcm_clocks:array[0..15] of word=(
   428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 85, 72, 54);
  // ratios of pos/neg pulse for square waves
  // 2/16 = 12.5%, 4/16 = 25%, 8/16 = 50%, 12/16 = 75%
  duty_lut:array[0..3] of byte=($40,$60,$78,$9f);

function sshr(num:integer;fac:byte):integer;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

function cpu_n2a03.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  buffer:array[0..6] of byte;
  size:word;
begin
  temp:=data;
  inc(temp,2);
  size:=self.m6502.save_snapshot(temp);
  dec(temp,2);
  copymemory(temp,@size,2);
  inc(temp,size+2);
  copymemory(temp,@self.apu,sizeof(apu_t));
  size:=size+sizeof(apu_t);
  inc(temp,sizeof(apu_t));
  copymemory(temp,@self.buffer,sizeof(self.buffer));
  size:=size+sizeof(self.buffer);
  inc(temp,sizeof(self.buffer));
  buffer[0]:=self.buffer_pos;
  buffer[1]:=self.frame_irq_timer;
  buffer[2]:=byte(frame_irq);
  copymemory(@buffer[3],@self.old_res,4);
  copymemory(temp,@buffer[0],7);
  save_snapshot:=2+size+7;
end;

procedure cpu_n2a03.load_snapshot(data:pbyte);
var
  temp:pbyte;
  buffer:array[0..6] of byte;
  size:word;
begin
  temp:=data;
  copymemory(@size,temp,2);
  inc(temp,2);
  self.m6502.load_snapshot(temp);
  inc(temp,size);
  copymemory(@self.apu,temp,sizeof(apu_t));
  inc(temp,sizeof(apu_t));
  copymemory(@self.buffer,temp,sizeof(self.buffer));
  inc(temp,sizeof(self.buffer));
  copymemory(@buffer[0],temp,7);
  self.buffer_pos:=buffer[0];
  self.frame_irq_timer:=buffer[1];
  frame_irq:=buffer[2]<>0;
  copymemory(@self.old_res,@buffer[3],4);
end;

procedure create_syncs(clock:dword);
var
  t,n,d:byte;
  val,tnd_out:single;
begin
val:=clock/llamadas_maquina.fps_max/4;
for t:=0 to (SYNCS_MAX1-1) do begin
    vbl_times[t]:=trunc(vbl_length[t]*val/2);
  	sync_times1[t]:=trunc(val*(t+1));
end;
for t:=0 to (SYNCS_MAX2-1) do sync_times2[t]:=trunc(val*t) shr 2;
square_lut[0]:=0;
for t:=1 to 31 do square_lut[t]:=95.88/((8128/t)+100);
for t:=0 to 15 do
	for n:=0 to 15 do
			for d:=0 to 127 do begin
				tnd_out:=(t/8227)+(n/12241)+(d/22638);
        if tnd_out<>0 then tnd_out:=159.79/((1/tnd_out)+100);
				tnd_lut[t,n,d]:=tnd_out;
      end;
end;

procedure n2a03_sound_advance(index:byte);
begin
  case index of
    0:n2a03_0.sound_advance;
    1:n2a03_1.sound_advance;
  end;
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

procedure n2a03_irq_call(index:byte);
begin
  case index of
    0:if n2a03_0.frame_irq then n2a03_0.m6502.change_irq(HOLD_LINE);
    1:if n2a03_1.frame_irq then n2a03_1.m6502.change_irq(HOLD_LINE);
  end;
end;

constructor cpu_n2a03.create(clock:dword;frames:word);
begin
  self.clock:=clock;
  self.m6502:=cpu_m6502.create(clock,frames,TCPU_NES);
  // Initialize global variables
  self.samps_per_sync:=round(clock/4/llamadas_maquina.fps_max);
  chips_total:=chips_total+1;
  self.frame_irq_timer:=timers.init(self.m6502.numero_cpu,clock/llamadas_maquina.fps_max{29830},nil,n2a03_irq_call,false,chips_total);
  case chips_total of
    0:begin
        create_syncs(clock);
        self.m6502.init_sound(n2a03_update_sound_0);
      end;
    1:timers.init(self.m6502.numero_cpu,clock/FREQ_BASE_AUDIO,nil,n2a03_update_sound,true,chips_total);
  end;
  //Crear aqui este timer es muy IMPORTANTE, por el orden despues
  timers.init(self.m6502.numero_cpu,4,nil,n2a03_sound_advance,true,chips_total);
  self.tsample_num:=init_channel;
  self.dpcm_getbyte:=nil;
  self.frame_call_irq:=nil;
  self.additional_sound:=nil;
end;

procedure cpu_n2a03.change_internals(read_byte_dpcm:tgetbyte);
begin
  self.dpcm_getbyte:=read_byte_dpcm;
end;

procedure cpu_n2a03.add_more_sound(additional_sound:tadditional_sound);
begin
    self.additional_sound:=additional_sound;
end;

destructor cpu_n2a03.free;
begin
  self.m6502.free;
  chips_total:=chips_total-1;
end;

procedure cpu_n2a03.reset;
begin
  fillchar(self.apu,sizeof(apu_t),0);
  self.apu.noi.lfsr:=1;
  self.apu_dpcm_reset;
  self.apu.dpcm.enabled:=false;
  self.apu.step_mode:=4;
  fillchar(self.buffer[1],TOTAL_BUFFER_SIZE*sizeof(single),0);
  self.buffer_pos:=1;
  self.frame_irq:=true;
  timers.enabled(self.frame_irq_timer,false);
  self.m6502.reset;
  self.write($15,0);
end;

// WRITE REGISTER VALUE
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
			    self.apu.squ[chan].vbl_length:=vbl_times[value shr 3];
			    self.apu.squ[chan].env_vol:=0;
			    self.apu.squ[chan].freq:=((((value and 7) shl 8)+self.apu.squ[chan].regs[2])+1) shl 16;
		    end;
		  end;
	  // triangle
	  APU_WRC0:begin
		    self.apu.tri.regs[0]:=value;
		    if self.apu.tri.enabled then begin
			    if not(self.apu.tri.counter_started) then self.apu.tri.linear_length:=sync_times2[value and $7F];
		    end;
      end;
	  $09:self.apu.tri.regs[1]:=value;	// unused
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
    			self.apu.tri.vbl_length:=vbl_times[value shr 3];
    			self.apu.tri.linear_length:=sync_times2[apu.tri.regs[0] and $7f];
          self.apu.tri.linear_reload:=true;
        end;
    end;
	  // noise
	  APU_WRD0:self.apu.noi.regs[0]:=value;
	  $0D:self.apu.noi.regs[1]:=value; // unused
	  APU_WRD2:self.apu.noi.regs[2]:=value;
	  APU_WRD3:begin
        self.apu.noi.regs[3]:=value;
		    if self.apu.noi.enabled then begin
    			self.apu.noi.vbl_length:=vbl_times[value shr 3];
		    	self.apu.noi.env_vol:=0; // reset envelope
		    end;
		  end;
	  // DMC
	  APU_WRE0:begin
		      self.apu.dpcm.regs[0]:=value;
		      self.apu.dpcm.irq:=(value and $80)<>0;
		  end;
	  APU_WRE1:begin // 7-bit DAC
		    self.apu.dpcm.regs[1]:=value and $7f;
        self.apu.dpcm.vol:=self.apu.dpcm.regs[1];
		  end;
	  APU_WRE2:begin
                self.apu.dpcm.regs[2]:=value;
                self.apu.dpcm.address:=$c000+(value shl 6);
             end;
	  APU_WRE3:self.apu.dpcm.regs[3]:=value;
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
    		if (value and $8)<>0 then self.apu.noi.enabled:=true
		      else begin
      			self.apu.noi.enabled:=false;
    			  self.apu.noi.vbl_length:=0;
    		  end;
    		if (value and $10)<>0 then begin
    			// only reset dpcm values if DMA is finished
		    	if not(self.apu.dpcm.enabled) then self.apu_dpcm_reset;
		    end else self.apu.dpcm.enabled:=false;
      end;
  end;
end;

// READ VALUES FROM REGISTERS
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

// WRITE VALUE TO TEMP REGISTRY AND QUEUE EVENT
procedure cpu_n2a03.write(posicion:word;value:byte);
var
  address:byte;
begin
  address:=posicion and $ff;
	self.apu.regs[address]:=value;
	self.apu_regwrite(address,value);
end;

// OUTPUT SQUARE WAVE SAMPLE (VALUES FROM 0 to +15)
procedure cpu_n2a03.apu_square(chan:byte);
var
	env_delay,sweep_delay:integer;
  temp1,temp2,temp3,temp4:byte;
begin
	{ reg0: 0-3=volume, 4=envelope, 5=hold, 6-7=duty cycle
    ** reg1: 0-2=sweep shifts, 3=sweep inc/dec, 4-6=sweep length, 7=sweep on
    ** reg2: 8 bits of freq
    ** reg3: 0-2=high freq, 7-4=vbl length counter}
	if not(self.apu.squ[chan].enabled) then begin
    self.apu.squ[chan].output_:=0;
    exit;
  end;
	// enveloping
	env_delay:=sync_times1[self.apu.squ[chan].regs[0] and $f];
	// decay is at a rate of (env_regs + 1) / 240 secs
	self.apu.squ[chan].env_phase:=self.apu.squ[chan].env_phase-4;
	while (self.apu.squ[chan].env_phase<0) do begin
		self.apu.squ[chan].env_phase:=self.apu.squ[chan].env_phase+env_delay;
		if (self.apu.squ[chan].regs[0] and $20)<>0 then self.apu.squ[chan].env_vol:=(self.apu.squ[chan].env_vol+1) and $f
		  else if (self.apu.squ[chan].env_vol<15) then self.apu.squ[chan].env_vol:=self.apu.squ[chan].env_vol+1;
	end;
	// vbl length counter
	if ((self.apu.squ[chan].vbl_length>0) and ((self.apu.squ[chan].regs[0] and $20)=0)) then self.apu.squ[chan].vbl_length:=self.apu.squ[chan].vbl_length-1;
	if (self.apu.squ[chan].vbl_length=0) then begin
    self.apu.squ[chan].output_:=0;
    exit;
  end;
	// freqsweeps
	if (((self.apu.squ[chan].regs[1] and $80)<>0) and ((self.apu.squ[chan].regs[1] and 7)<>0)) then begin
		sweep_delay:=sync_times1[(self.apu.squ[chan].regs[1] shr 4) and 7];
		self.apu.squ[chan].sweep_phase:=self.apu.squ[chan].sweep_phase-2;
		while (self.apu.squ[chan].sweep_phase<0) do begin
			self.apu.squ[chan].sweep_phase:=self.apu.squ[chan].sweep_phase+sweep_delay;
			if (self.apu.squ[chan].regs[1] and 8)<>0 then self.apu.squ[chan].freq:=self.apu.squ[chan].freq-(self.apu.squ[chan].freq shr (self.apu.squ[chan].regs[1] and 7))
			  else self.apu.squ[chan].freq:=self.apu.squ[chan].freq+(self.apu.squ[chan].freq shr (self.apu.squ[chan].regs[1] and 7));
		end;
	end;
	if (((self.apu.squ[chan].regs[1] and 8)=0) and
    ((self.apu.squ[chan].freq shr 16)>(freq_limit[self.apu.squ[chan].regs[1] and 7])) or
    ((self.apu.squ[chan].freq shr 16)<4)) then begin
		  self.apu.squ[chan].output_:=0;
      exit;
  end;
	self.apu.squ[chan].phaseacc:=self.apu.squ[chan].phaseacc-4;
	while (self.apu.squ[chan].phaseacc<0) do begin
		self.apu.squ[chan].phaseacc:=self.apu.squ[chan].phaseacc+(self.apu.squ[chan].freq shr 16);
		self.apu.squ[chan].adder:=(self.apu.squ[chan].adder+1) and $f;
	end;
	if (self.apu.squ[chan].regs[0] and $10)<>0 then temp3:=self.apu.squ[chan].regs[0] and $f
	  else temp3:=$f-self.apu.squ[chan].env_vol;
  temp1:=duty_lut[self.apu.squ[chan].regs[0] shr 6];
  temp2:=(self.apu.squ[chan].adder shr 1) and 7;
  temp4:=temp3*((temp1 shr (7-temp2)) and 1);
  self.apu.squ[chan].output_:=temp4;
end;

// OUTPUT TRIANGLE WAVE SAMPLE (VALUES FROM 0 to +15)
procedure cpu_n2a03.apu_triangle;
var
	freq:word;
  not_held:boolean;
begin
	{ reg0: 7=holdnote, 6-0=linear length counter
    ** reg2: low 8 bits of frequency
    ** reg3: 7-3=length counter, 2-0=high 3 bits of frequency}
	if not(self.apu.tri.enabled) then exit;
  not_held:=(self.apu.tri.regs[0] and $80)=0;
	if (not(self.apu.tri.counter_started) and not_held) then begin
		if (self.apu.tri.write_latency)<>0 then self.apu.tri.write_latency:=self.apu.tri.write_latency-1;
		if (self.apu.tri.write_latency=0) then self.apu.tri.counter_started:=true;
	end;
	if (self.apu.tri.counter_started) then begin
		if self.apu.tri.linear_reload then self.apu.tri.linear_length:=sync_times2[self.apu.tri.regs[0] and $7f]
      else if (self.apu.tri.linear_length>0) then self.apu.tri.linear_length:=self.apu.tri.linear_length-1;
    if not_held then self.apu.tri.linear_reload:=false;
		if ((self.apu.tri.vbl_length<>0) and not_held) then self.apu.tri.vbl_length:=self.apu.tri.vbl_length-1;
	end;
	if not((self.apu.tri.linear_length<>0) and (self.apu.tri.vbl_length<>0)) then exit;
	freq:=((self.apu.tri.regs[3] and 7) shl 8)+self.apu.tri.regs[2]+1;
	if (freq<2) then exit;
	self.apu.tri.phaseacc:=self.apu.tri.phaseacc-4; // # of cycles per sample
	while (self.apu.tri.phaseacc<0) do begin
		self.apu.tri.phaseacc:=self.apu.tri.phaseacc+freq;
		self.apu.tri.adder:=self.apu.tri.adder+1;
		self.apu.tri.output_:=self.apu.tri.adder and $f;
		if (self.apu.tri.adder and $10)=0 then self.apu.tri.output_:=self.apu.tri.output_ xor $f;
	end;
end;

// OUTPUT NOISE WAVE SAMPLE (VALUES FROM 0 to +15)
procedure cpu_n2a03.apu_noise;
var
  temp2,freq,env_delay:integer;
	temp1:byte;
begin
	 {reg0: 0-3=volume, 4=envelope, 5=hold
    ** reg2: 7=small(93 byte) sample,3-0=freq lookup
    ** reg3: 7-4=vbl length counter}
	if not(self.apu.noi.enabled) then begin
    self.apu.noi.output_:=0;
    exit;
  end;
	// enveloping
	env_delay:=sync_times1[self.apu.noi.regs[0] and $0f];
	// decay is at a rate of (env_regs + 1) / 240 secs
	self.apu.noi.env_phase:=self.apu.noi.env_phase-4;
	while (self.apu.noi.env_phase<0) do begin
		self.apu.noi.env_phase:=self.apu.noi.env_phase+env_delay;
		if (self.apu.noi.regs[0] and $20)<>0 then self.apu.noi.env_vol:=(self.apu.noi.env_vol+1) and 15
		  else if (self.apu.noi.env_vol<15) then self.apu.noi.env_vol:=self.apu.noi.env_vol+1;
	end;
	// length counter
	if (self.apu.noi.regs[0] and $20)=0 then begin
		if (self.apu.noi.vbl_length>0) then self.apu.noi.vbl_length:=self.apu.noi.vbl_length-1;
	end;
	if self.apu.noi.vbl_length=0 then begin
		self.apu.noi.output_:=0;
    exit;
  end;
	freq:=noise_freq[self.apu.noi.regs[2] and $0f];
	self.apu.noi.phaseacc:=self.apu.noi.phaseacc-4; // # of cycles per sample
	while (self.apu.noi.phaseacc<0) do begin
    self.apu.noi.phaseacc:=self.apu.noi.phaseacc+freq;
    //if (self.apu.noi.regs[2]<>$80) then temp1:=6
    //  else
    temp1:=1;
    temp2:=((self.apu.noi.lfsr and 1) xor ((self.apu.noi.lfsr shr temp1) and 1)) shl 15;
    self.apu.noi.lfsr:=(self.apu.noi.lfsr or temp2) shr 1;
	end;
  if (self.apu.noi.lfsr and 1)<>0 then begin // silence channel
		self.apu.noi.output_:=0;
	end else begin // fixed volume
	  if (self.apu.noi.regs[0] and $10)<>0 then self.apu.noi.output_:=self.apu.noi.regs[0] and $0f
	    else self.apu.noi.output_:=$0f-self.apu.noi.env_vol;
  end;
end;

procedure cpu_n2a03.apu_dpcm_reset;
begin
  self.apu.dpcm.address:=$c000+(self.apu.dpcm.regs[2] shl 6);
  self.apu.dpcm.length:=(self.apu.dpcm.regs[3] shl 4)+1;
  self.apu.dpcm.bits_left:=8;
  self.apu.dpcm.irq:=(self.apu.dpcm.regs[0] and $80)<>0;
  self.apu.dpcm.enabled:=true;
end;
// OUTPUT DPCM WAVE SAMPLE
procedure cpu_n2a03.apu_dpcm;
var
  freq:integer;
  bit_pos:byte;
begin
if self.apu.dpcm.enabled then begin
  freq:=dpcm_clocks[self.apu.dpcm.regs[0] and $f];
  self.apu.dpcm.phaseacc:=self.apu.dpcm.phaseacc-4; // # of cycles per sample
  while (self.apu.dpcm.phaseacc<0) do begin
      self.apu.dpcm.phaseacc:=self.apu.dpcm.phaseacc+freq;
      if (self.apu.dpcm.length=0) then begin
          self.apu.dpcm.enabled:=false;
          //self.apu.dpcm.vol:=0;
          if (self.apu.dpcm.regs[0] and $40)<>0 then begin  //Loop
              self.apu_dpcm_reset;
          end else begin // Final - IRQ Generator
              if self.apu.dpcm.irq then n2a03_0.m6502.change_irq(HOLD_LINE);
              self.apu.dpcm.vol:=0;
					    break;
          end;
      end;
      self.apu.dpcm.bits_left:=self.apu.dpcm.bits_left-1;
      bit_pos:=7-(self.apu.dpcm.bits_left and 7);
      if (bit_pos=7) then begin
			    self.apu.dpcm.cur_byte:=self.dpcm_getbyte(self.apu.dpcm.address);
          self.apu.dpcm.address:=self.apu.dpcm.address+1;
          if self.apu.dpcm.address=$10000 then self.apu.dpcm.address:=$8000;
				  self.apu.dpcm.length:=self.apu.dpcm.length-1;
          self.apu.dpcm.bits_left:=8;
      end;
      if (((self.apu.dpcm.cur_byte and (1 shl bit_pos))<>0) and (self.apu.dpcm.vol<126)) then self.apu.dpcm.vol:=self.apu.dpcm.vol+2
        else if (self.apu.dpcm.vol>1) then self.apu.dpcm.vol:=self.apu.dpcm.vol-2;
  end;
end;
self.apu.dpcm.output_:=self.apu.dpcm.vol;
end;

procedure cpu_n2a03.sound_advance;
var
  pulse_out:single;
begin
    self.apu_square(0);
    self.apu_square(1);
    self.apu_triangle;
    self.apu_noise;
    self.apu_dpcm;
    pulse_out:=square_lut[self.apu.squ[0].output_+self.apu.squ[1].output_];
    self.buffer[self.buffer_pos]:=pulse_out+tnd_lut[self.apu.tri.output_,self.apu.noi.output_,self.apu.dpcm.output_];
    self.buffer_pos:=self.buffer_pos+1;
end;

procedure cpu_n2a03.sound_update;
var
  f:byte;
  res:single;
begin  //Resample from 447443hz to 44100hz
if self.buffer_pos>11 then begin
  res:=0;
  for f:=1 to 11 do res:=res+self.buffer[f];
  res:=(res/11)*$7fff;
  for f:=12 to self.buffer_pos do self.buffer[f-11]:=self.buffer[f];
  self.buffer_pos:=self.buffer_pos-11;
  self.old_res:=res;
end else res:=self.old_res;
tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc(res);
if @self.additional_sound<>nil then self.additional_sound;
end;

end.
