unit n2a03;
interface
uses cpu_misc,sound_engine,timer_engine,main_engine,m6502;

const
  SYNCS_MAX1=$20;
  SYNCS_MAX2=$80;
  TOTAL_BUFFER_SIZE=200;
  APU_FILTER_TAPS=320;
  APU_FILTER_PHASES=64;
  NTSC_CLOCK=1789773;
  PAL_CLOCK=1662607;
  NTSC_REFRESH=60.0988;
  PAL_REFRESH=50.0070;
  NTSC_LINES=262;
  PAL_LINES=312;

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
  apu_runtime_t=packed record
    pal,noise_short_supported:boolean;
    env_start:array[0..1] of boolean;
    sweep_reload:array[0..1] of boolean;
    noise_env_start:boolean;
    frame_irq_enabled,frame_irq_pending,irq_line:boolean;
    frame_cycle:integer;
    frame_write_delay,frame_next_value:byte;
    cpu_cycles:uint64;
    dmc_buffer:byte;
    dmc_buffer_empty,dmc_silence:boolean;
    buffer_read,buffer_write,buffer_count:word;
    resample_sum,resample_weight:double;
    last_res:single;
    generated_samples:uint64;
  end;
  apu_output_state_t=packed record
    enabled,primed:boolean;
    hp90_x,hp90_y,hp440_x,hp440_y,lp14_x,lp14_y:double;
  end;
  cpu_n2a03=class(snd_chip_class)
    public
      m6502:cpu_m6502;
      additional_sound:tadditional_sound;
      constructor create(clock:dword);
      destructor free;
      procedure reset;
      procedure set_external_clock(enabled:boolean);
      procedure clock_cpu;
      function dmc_request(var address:word):boolean;
      procedure dmc_complete(value:byte);
      function read(direccion:word):byte;
      procedure write(posicion:word;value:byte);
      procedure change_internals(read_byte_dpcm:tgetbyte);
      procedure add_more_sound(additional_sound:tadditional_sound);
      procedure change_irq_call(irq_call:tcall_frame_irq);
      procedure set_noise_mode_supported(supported:boolean);
      procedure set_output_filter_enabled(enabled:boolean);
      function save_snapshot(data:pbyte):word;
      procedure load_snapshot(data:pbyte);
    private
      external_clock,dmc_requested:boolean;
      external_div:byte;
      external_sum:single;
      apu:apu_t;
      state:apu_runtime_t;
      buffer:array[1..TOTAL_BUFFER_SIZE] of single;
      resample_period:double;
      advance_timer,output_timer,chip_index:byte;
      frame_call_irq:tcall_frame_irq;
      dpcm_getbyte:tgetbyte;
      filter_history:array[0..APU_FILTER_TAPS-1] of single;
      filter_coeff:array[0..APU_FILTER_PHASES-1,0..APU_FILTER_TAPS-1] of single;
      filter_pos:word;
      output_state:apu_output_state_t;
      hp90_a,hp90_b,hp440_a,hp440_b,lp14_a,lp14_b:double;
      procedure init_output_filter;
      function filter_output(value:single):single;
      procedure init_filter;
      function filtered_sample(fraction:double):single;
      procedure update_irq;
      procedure quarter_frame;
      procedure half_frame;
      procedure clock_frame;
      function sweep_target(chan:byte):integer;
      procedure apu_regwrite(address,value:byte);
      procedure apu_square(chan:byte);
      procedure apu_triangle;
      procedure apu_noise;
      procedure apu_dpcm;
      procedure apu_dpcm_reset;
      procedure push_sample(value:single);
      procedure sound_advance;
      procedure sound_update;
  end;
var n2a03_0,n2a03_1:cpu_n2a03;

implementation
uses sysutils;

const
  vbl_length:array[0..31] of byte=(
    10,254,20,2,40,4,80,6,160,8,60,10,14,12,26,14,
    12,16,24,18,48,20,96,22,192,24,72,26,16,28,32,30);
  noise_period:array[0..1,0..15] of word=(
    (4,8,16,32,64,96,128,160,202,254,380,508,762,1016,2034,4068),
    (4,8,14,30,60,88,118,148,188,236,354,472,708,944,1890,3778));
  dmc_period:array[0..1,0..15] of word=(
    (428,380,340,320,286,254,226,214,190,160,142,128,106,84,72,54),
    (398,354,316,298,276,236,210,198,176,148,132,118,98,78,66,50));
  duty_lut:array[0..3] of byte=($40,$60,$78,$9f);
  frame_events:array[0..1,0..7] of integer=(
    (7457,14913,22371,29828,29829,29830,37281,37282),
    (8313,16627,24939,33252,33253,33254,41565,41566));
var
  chip_slots:array[0..1] of cpu_n2a03;
  square_lut:array[0..31] of single;
  tnd_lut:array[0..15,0..15,0..127] of single;
  lut_ready:boolean=false;

procedure init_mixer;
var
  p,t,n,d:integer;
  x:double;
begin
  if lut_ready then exit;
  square_lut[0]:=0;
  for p:=1 to 31 do square_lut[p]:=95.88/(8128/p+100);
  for t:=0 to 15 do for n:=0 to 15 do for d:=0 to 127 do begin
    x:=t/8227+n/12241+d/22638;
    if x<>0 then x:=159.79/(1/x+100);
    tnd_lut[t,n,d]:=x;
  end;
  lut_ready:=true;
end;

procedure n2a03_sound_advance(index:byte);
begin
  if chip_slots[index]<>nil then chip_slots[index].sound_advance;
end;

procedure n2a03_update_sound_0;
begin
  if chip_slots[0]<>nil then chip_slots[0].sound_update;
end;

procedure n2a03_update_sound(index:byte);
begin
  if chip_slots[index]<>nil then chip_slots[index].sound_update;
end;

constructor cpu_n2a03.create(clock:dword);
var
  slot:integer;
begin
  inherited create;
  slot:=0;
  while (slot<2) and (chip_slots[slot]<>nil) do inc(slot);
  self.clock:=clock;
  self.chip_index:=slot;
  self.advance_timer:=$ff;
  self.output_timer:=$ff;
  self.frame_call_irq:=nil;
  self.dpcm_getbyte:=nil;
  self.additional_sound:=nil;
  self.m6502:=cpu_m6502.create(clock,TCPU_NES);
  self.resample_period:=clock/(4.0*FREQ_BASE_AUDIO);
  self.init_filter;
  self.init_output_filter;
  self.output_state.enabled:=true;
  init_mixer;
  self.state.pal:=abs(Int64(clock)-PAL_CLOCK)<abs(Int64(clock)-NTSC_CLOCK);
  self.state.noise_short_supported:=true;
  self.state.buffer_read:=1;
  self.state.buffer_write:=1;
  self.state.dmc_buffer_empty:=true;
  self.state.dmc_silence:=true;
  self.apu.step_mode:=4;
  chip_slots[slot]:=self;
  if slot=0 then begin
    self.m6502.init_sound(n2a03_update_sound_0);
    self.output_timer:=sound_engine_timer;
  end else self.output_timer:=timers.init(self.m6502.numero_cpu,clock/FREQ_BASE_AUDIO,nil,n2a03_update_sound,true,slot);
  self.advance_timer:=timers.init(self.m6502.numero_cpu,4,nil,n2a03_sound_advance,true,slot);
  self.tsample_num:=init_channel;
end;

destructor cpu_n2a03.free;
begin
  if self.advance_timer<>$ff then timers.enabled(self.advance_timer,false);
  if self.output_timer<>$ff then timers.enabled(self.output_timer,false);
  if chip_slots[self.chip_index]=self then chip_slots[self.chip_index]:=nil;
  self.m6502.free;
end;

procedure cpu_n2a03.change_internals(read_byte_dpcm:tgetbyte);
begin
  self.dpcm_getbyte:=read_byte_dpcm;
end;

procedure cpu_n2a03.add_more_sound(additional_sound:tadditional_sound);
begin
  self.additional_sound:=additional_sound;
end;

procedure cpu_n2a03.change_irq_call(irq_call:tcall_frame_irq);
begin
  self.frame_call_irq:=irq_call;
  if (@irq_call<>nil) then irq_call(byte(self.state.irq_line))
    else self.m6502.change_irq(byte(self.state.irq_line));
end;

procedure cpu_n2a03.set_noise_mode_supported(supported:boolean);
begin
  self.state.noise_short_supported:=supported;
end;

procedure cpu_n2a03.set_output_filter_enabled(enabled:boolean);
begin
  fillchar(self.output_state,sizeof(self.output_state),0);
  self.output_state.enabled:=enabled;
end;

procedure cpu_n2a03.init_output_filter;
const
  pi_value=3.14159265358979323846;
var
  g,angle:double;
begin
  // Bilinear one-pole sections, prewarped to the specified cutoff at 44.1 kHz.
  angle:=pi_value*90/FREQ_BASE_AUDIO;
  g:=sin(angle)/cos(angle);
  self.hp90_a:=(1-g)/(1+g);
  self.hp90_b:=1/(1+g);
  angle:=pi_value*440/FREQ_BASE_AUDIO;
  g:=sin(angle)/cos(angle);
  self.hp440_a:=(1-g)/(1+g);
  self.hp440_b:=1/(1+g);
  angle:=pi_value*14000/FREQ_BASE_AUDIO;
  g:=sin(angle)/cos(angle);
  self.lp14_a:=(1-g)/(1+g);
  self.lp14_b:=g/(1+g);
end;

function cpu_n2a03.filter_output(value:single):single;
var
  x,y:double;
begin
  if not self.output_state.enabled then begin
    result:=value;
    exit;
  end;
  if not self.output_state.primed then begin
    // Prime the DC-coupling state without an artificial startup impulse.
    self.output_state.hp90_x:=value;
    self.output_state.primed:=true;
  end;
  x:=value;
  y:=self.hp90_b*(x-self.output_state.hp90_x)+self.hp90_a*self.output_state.hp90_y;
  self.output_state.hp90_x:=x;self.output_state.hp90_y:=y;
  x:=y;
  y:=self.hp440_b*(x-self.output_state.hp440_x)+self.hp440_a*self.output_state.hp440_y;
  self.output_state.hp440_x:=x;self.output_state.hp440_y:=y;
  x:=y;
  y:=self.lp14_b*(x+self.output_state.lp14_x)+self.lp14_a*self.output_state.lp14_y;
  self.output_state.lp14_x:=x;self.output_state.lp14_y:=y;
  Result:=y;
end;

procedure cpu_n2a03.update_irq;
var
  level:boolean;
begin
  level:=self.state.frame_irq_pending or self.apu.dpcm.irq;
  if level=self.state.irq_line then exit;
  self.state.irq_line:=level;
  if (@self.frame_call_irq<>nil) then self.frame_call_irq(byte(level))
    else if level then self.m6502.change_irq(ASSERT_LINE)
            else self.m6502.change_irq(CLEAR_LINE);
end;

procedure cpu_n2a03.reset;
var
  pal,short_mode,old_irq,output_enabled:boolean;
begin
  pal:=self.state.pal;
  short_mode:=self.state.noise_short_supported;
  old_irq:=self.state.irq_line;
  output_enabled:=self.output_state.enabled;
  fillchar(self.output_state,sizeof(self.output_state),0);
  self.output_state.enabled:=output_enabled;
  fillchar(self.apu,sizeof(self.apu),0);
  fillchar(self.state,sizeof(self.state),0);
  fillchar(self.buffer,sizeof(self.buffer),0);
  fillchar(self.filter_history,sizeof(self.filter_history),0);
  self.filter_pos:=0;
  self.state.pal:=pal;
  self.state.noise_short_supported:=short_mode;
  self.state.frame_irq_enabled:=true;
  self.state.buffer_read:=1;
  self.state.buffer_write:=1;
  self.state.dmc_buffer_empty:=true;
  self.state.dmc_silence:=true;
  self.apu.noi.lfsr:=1;
  self.apu.dpcm.bits_left:=8;
  self.apu.step_mode:=4;
  external_div:=0;external_sum:=0;dmc_requested:=false;
  self.m6502.reset;
  if (old_irq and (@self.frame_call_irq<>nil)) then self.frame_call_irq(CLEAR_LINE);
  // Only reset these timers, not timer_engine.reset (which also resets one-shots).
  timers.timer[self.advance_timer].actual_time:=0;
  timers.timer[self.output_timer].actual_time:=0;
end;

procedure cpu_n2a03.quarter_frame;
var
  c:integer;
begin
  for c:=0 to 1 do begin
    if self.state.env_start[c] then begin
      self.state.env_start[c]:=false;
      self.apu.squ[c].env_vol:=15;
      self.apu.squ[c].env_phase:=self.apu.squ[c].regs[0] and 15;
    end else if self.apu.squ[c].env_phase>0 then
      dec(self.apu.squ[c].env_phase)
    else begin
      self.apu.squ[c].env_phase:=self.apu.squ[c].regs[0] and 15;
      if self.apu.squ[c].env_vol>0 then dec(self.apu.squ[c].env_vol)
        else if (self.apu.squ[c].regs[0] and $20)<>0 then
          self.apu.squ[c].env_vol:=15;
    end;
  end;
  if self.state.noise_env_start then begin
    self.state.noise_env_start:=false;
    self.apu.noi.env_vol:=15;
    self.apu.noi.env_phase:=self.apu.noi.regs[0] and 15;
  end else if self.apu.noi.env_phase>0 then dec(self.apu.noi.env_phase)
  else begin
    self.apu.noi.env_phase:=self.apu.noi.regs[0] and 15;
    if self.apu.noi.env_vol>0 then dec(self.apu.noi.env_vol)
      else if (self.apu.noi.regs[0] and $20)<>0 then self.apu.noi.env_vol:=15;
  end;
  if self.apu.tri.linear_reload then
    self.apu.tri.linear_length:=self.apu.tri.regs[0] and $7f
  else if self.apu.tri.linear_length>0 then dec(self.apu.tri.linear_length);
  if (self.apu.tri.regs[0] and $80)=0 then self.apu.tri.linear_reload:=false;
end;

function cpu_n2a03.sweep_target(chan:byte):integer;
var
  delta:integer;
begin
  delta:=self.apu.squ[chan].freq shr (self.apu.squ[chan].regs[1] and 7);
  if (self.apu.squ[chan].regs[1] and 8)<>0 then begin
    Result:=self.apu.squ[chan].freq-delta;
    if chan=0 then dec(Result);
  end else Result:=self.apu.squ[chan].freq+delta;
end;

procedure cpu_n2a03.half_frame;
var
  c,target:integer;
begin
  for c:=0 to 1 do begin
    if (self.apu.squ[c].vbl_length>0) and
       ((self.apu.squ[c].regs[0] and $20)=0) then dec(self.apu.squ[c].vbl_length);
    if self.apu.squ[c].sweep_phase=0 then begin
      target:=self.sweep_target(c);
      if ((self.apu.squ[c].regs[1] and $80)<>0) and
         ((self.apu.squ[c].regs[1] and 7)<>0) and
         (self.apu.squ[c].freq>=8) and (target<=$7ff) then begin
        self.apu.squ[c].freq:=target;
        self.apu.squ[c].regs[2]:=target and $ff;
        self.apu.squ[c].regs[3]:=(self.apu.squ[c].regs[3] and $f8) or
          ((target shr 8) and 7);
      end;
    end;
    if (self.apu.squ[c].sweep_phase=0) or self.state.sweep_reload[c] then begin
      self.apu.squ[c].sweep_phase:=(self.apu.squ[c].regs[1] shr 4) and 7;
      self.state.sweep_reload[c]:=false;
    end else dec(self.apu.squ[c].sweep_phase);
  end;
  if (self.apu.noi.vbl_length>0) and ((self.apu.noi.regs[0] and $20)=0) then
    dec(self.apu.noi.vbl_length);
  if (self.apu.tri.vbl_length>0) and ((self.apu.tri.regs[0] and $80)=0) then
    dec(self.apu.tri.vbl_length);
end;

procedure cpu_n2a03.clock_frame;
var
  region:byte;
  restart:boolean;
begin
  region:=byte(self.state.pal);
  restart:=false;
  if self.state.frame_write_delay>0 then begin
    dec(self.state.frame_write_delay);
    if self.state.frame_write_delay=0 then begin
      self.state.frame_cycle:=0;
      if (self.state.frame_next_value and $80)<>0 then begin
        self.apu.step_mode:=5;
        self.quarter_frame;
        self.half_frame;
      end else self.apu.step_mode:=4;
      restart:=true;
    end;
  end;
  if restart then exit;
  inc(self.state.frame_cycle);
  if (self.state.frame_cycle=frame_events[region,0]) or
     (self.state.frame_cycle=frame_events[region,2]) then self.quarter_frame;
  if self.state.frame_cycle=frame_events[region,1] then begin
    self.quarter_frame;
    self.half_frame;
  end;
  if self.apu.step_mode=4 then begin
    if self.state.frame_cycle=frame_events[region,4] then begin
      self.quarter_frame;
      self.half_frame;
    end;
    if self.state.frame_irq_enabled and
       (self.state.frame_cycle>=frame_events[region,3]) and
       (self.state.frame_cycle<=frame_events[region,5]) then begin
      self.state.frame_irq_pending:=true;
      self.update_irq;
    end;
    if self.state.frame_cycle=frame_events[region,5] then self.state.frame_cycle:=0;
  end else begin
    if self.state.frame_cycle=frame_events[region,6] then begin
      self.quarter_frame;
      self.half_frame;
    end;
    if self.state.frame_cycle=frame_events[region,7] then self.state.frame_cycle:=0;
  end;
end;

procedure cpu_n2a03.apu_dpcm_reset;
begin
  self.apu.dpcm.address:=$c000+(word(self.apu.dpcm.regs[2]) shl 6);
  self.apu.dpcm.length:=(word(self.apu.dpcm.regs[3]) shl 4)+1;
  self.apu.dpcm.enabled:=true;
  // Restart the memory reader only. Do not reset the DAC/output shifter.
end;

procedure cpu_n2a03.apu_regwrite(address,value:byte);
var
  c:byte;
begin
  c:=(address shr 2) and 1;
  case address of
    $00,$04:self.apu.squ[c].regs[0]:=value;
    $01,$05:begin
      self.apu.squ[c].regs[1]:=value;
      self.state.sweep_reload[c]:=true;
    end;
    $02,$06:begin
      self.apu.squ[c].regs[2]:=value;
      self.apu.squ[c].freq:=(self.apu.squ[c].freq and $700) or value;
    end;
    $03,$07:begin
      self.apu.squ[c].regs[3]:=value;
      self.apu.squ[c].freq:=(self.apu.squ[c].freq and $ff) or
        ((value and 7) shl 8);
      if self.apu.squ[c].enabled then self.apu.squ[c].vbl_length:=vbl_length[value shr 3];
      self.apu.squ[c].adder:=0;
      self.state.env_start[c]:=true;
    end;
    $08:self.apu.tri.regs[0]:=value;
    $09:self.apu.tri.regs[1]:=value;
    $0a:self.apu.tri.regs[2]:=value;
    $0b:begin
      self.apu.tri.regs[3]:=value;
      if self.apu.tri.enabled then self.apu.tri.vbl_length:=vbl_length[value shr 3];
      self.apu.tri.linear_reload:=true;
    end;
    $0c:self.apu.noi.regs[0]:=value;
    $0d:self.apu.noi.regs[1]:=value;
    $0e:self.apu.noi.regs[2]:=value;
    $0f:begin
      self.apu.noi.regs[3]:=value;
      if self.apu.noi.enabled then self.apu.noi.vbl_length:=vbl_length[value shr 3];
      self.state.noise_env_start:=true;
    end;
    $10:begin
      self.apu.dpcm.regs[0]:=value;
      if (value and $80)=0 then self.apu.dpcm.irq:=false;
      self.update_irq;
    end;
    $11:begin
      self.apu.dpcm.regs[1]:=value and $7f;
      self.apu.dpcm.vol:=value and $7f;
      self.apu.dpcm.output_:=self.apu.dpcm.vol;
    end;
    $12:self.apu.dpcm.regs[2]:=value;
    $13:self.apu.dpcm.regs[3]:=value;
    $15:begin
      self.apu.squ[0].enabled:=(value and 1)<>0;
      self.apu.squ[1].enabled:=(value and 2)<>0;
      self.apu.tri.enabled:=(value and 4)<>0;
      self.apu.noi.enabled:=(value and 8)<>0;
      if not self.apu.squ[0].enabled then self.apu.squ[0].vbl_length:=0;
      if not self.apu.squ[1].enabled then self.apu.squ[1].vbl_length:=0;
      if not self.apu.tri.enabled then self.apu.tri.vbl_length:=0;
      if not self.apu.noi.enabled then self.apu.noi.vbl_length:=0;
      if (value and $10)=0 then begin
        self.apu.dpcm.length:=0;
        self.apu.dpcm.enabled:=false;
      end else if self.apu.dpcm.length=0 then self.apu_dpcm_reset;
      self.apu.dpcm.irq:=false;
      self.update_irq;
    end;
    $17:begin
      self.state.frame_irq_enabled:=(value and $40)=0;
      if not self.state.frame_irq_enabled then self.state.frame_irq_pending:=false;
      self.state.frame_next_value:=value;
      if (self.state.cpu_cycles and 1)=0 then self.state.frame_write_delay:=3
        else self.state.frame_write_delay:=4;
      self.update_irq;
    end;
  end;
end;

function cpu_n2a03.read(direccion:word):byte;
var
  address:byte;
begin
  address:=direccion and $ff;
  Result:=0;
  if address<>$15 then exit; // Other APU sound registers are write-only.
  if self.apu.squ[0].vbl_length>0 then Result:=Result or 1;
  if self.apu.squ[1].vbl_length>0 then Result:=Result or 2;
  if self.apu.tri.vbl_length>0 then Result:=Result or 4;
  if self.apu.noi.vbl_length>0 then Result:=Result or 8;
  if self.apu.dpcm.length>0 then Result:=Result or $10;
  if self.state.frame_irq_pending then Result:=Result or $40;
  if self.apu.dpcm.irq then Result:=Result or $80;
  self.state.frame_irq_pending:=false;
  self.update_irq;
  // Bit 5/open bus must be supplied by the driver's CPU-bus implementation.
end;

procedure cpu_n2a03.write(posicion:word;value:byte);
var
  address:byte;
begin
  address:=posicion and $ff;
  if address>$17 then exit;
  self.apu.regs[address]:=value;
  self.apu_regwrite(address,value);
end;

procedure cpu_n2a03.apu_square(chan:byte);
var
  target,volume:integer;
begin
  if (self.state.cpu_cycles and 1)=0 then begin
    if self.apu.squ[chan].phaseacc=0 then begin
      self.apu.squ[chan].phaseacc:=self.apu.squ[chan].freq;
      self.apu.squ[chan].adder:=(self.apu.squ[chan].adder+1) and 7;
    end else dec(self.apu.squ[chan].phaseacc);
  end;
  target:=self.sweep_target(chan);
  self.apu.squ[chan].output_:=0;
  if (not self.apu.squ[chan].enabled) or (self.apu.squ[chan].vbl_length=0) or
     (self.apu.squ[chan].freq<8) or (target>$7ff) then exit;
  if (self.apu.squ[chan].regs[0] and $10)<>0 then volume:=self.apu.squ[chan].regs[0] and 15
    else volume:=self.apu.squ[chan].env_vol;
  if ((duty_lut[self.apu.squ[chan].regs[0] shr 6] shr
      (7-self.apu.squ[chan].adder)) and 1)<>0 then
    self.apu.squ[chan].output_:=volume;
end;

procedure cpu_n2a03.apu_triangle;
var
  period:integer;
begin
  period:=((self.apu.tri.regs[3] and 7) shl 8) or self.apu.tri.regs[2];
  // Conservative compatibility guard from the original core: its timer was
  // stored as period+1 and rejected values <2. This means RAW period=0 only.
  // Hold the DAC and sequencer here; forcing output to zero creates a click.
  if period=0 then exit;
  if self.apu.tri.phaseacc=0 then begin
    self.apu.tri.phaseacc:=period;
    if (self.apu.tri.vbl_length>0) and (self.apu.tri.linear_length>0) then begin
      self.apu.tri.adder:=(self.apu.tri.adder+1) and 31;
      if self.apu.tri.adder<16 then self.apu.tri.output_:=15-self.apu.tri.adder
        else self.apu.tri.output_:=self.apu.tri.adder-16;
    end;
  end else dec(self.apu.tri.phaseacc);
  // When counters stop the sequencer, the DAC retains its last value.
end;

procedure cpu_n2a03.apu_noise;
var
  tap,feedback:integer;
begin
  if self.apu.noi.phaseacc=0 then begin
    self.apu.noi.phaseacc:=noise_period[byte(self.state.pal),self.apu.noi.regs[2] and 15]-1;
    tap:=1;
    if self.state.noise_short_supported and ((self.apu.noi.regs[2] and $80)<>0) then tap:=6;
    feedback:=(self.apu.noi.lfsr xor (self.apu.noi.lfsr shr tap)) and 1;
    self.apu.noi.lfsr:=(self.apu.noi.lfsr shr 1) or (dword(feedback) shl 14);
  end else dec(self.apu.noi.phaseacc);
  self.apu.noi.output_:=0;
  if (not self.apu.noi.enabled) or (self.apu.noi.vbl_length=0) or
     ((self.apu.noi.lfsr and 1)<>0) then exit;
  if (self.apu.noi.regs[0] and $10)<>0 then
    self.apu.noi.output_:=self.apu.noi.regs[0] and 15
  else self.apu.noi.output_:=self.apu.noi.env_vol;
end;

procedure cpu_n2a03.apu_dpcm;
begin
  // In external-clock mode the console owns CPU bus stalls and supplies data.
  if (self.state.dmc_buffer_empty and (self.apu.dpcm.length>0) and (@self.dpcm_getbyte<>nil)) then begin
    if external_clock then dmc_requested:=true
      else self.dmc_complete(self.dpcm_getbyte(word(self.apu.dpcm.address)));
  end;
  if self.apu.dpcm.phaseacc=0 then begin
    self.apu.dpcm.phaseacc:=dmc_period[byte(self.state.pal),self.apu.dpcm.regs[0] and 15]-1;
    if not self.state.dmc_silence then begin
      if (self.apu.dpcm.cur_byte and 1)<>0 then begin
        if self.apu.dpcm.vol<=125 then inc(self.apu.dpcm.vol,2);
      end else if self.apu.dpcm.vol>=2 then dec(self.apu.dpcm.vol,2);
    end;
    self.apu.dpcm.cur_byte:=self.apu.dpcm.cur_byte shr 1;
    if self.apu.dpcm.bits_left>0 then dec(self.apu.dpcm.bits_left);
    if self.apu.dpcm.bits_left=0 then begin
      self.apu.dpcm.bits_left:=8;
      self.state.dmc_silence:=self.state.dmc_buffer_empty;
      if not self.state.dmc_buffer_empty then begin
        self.apu.dpcm.cur_byte:=self.state.dmc_buffer;
        self.state.dmc_buffer_empty:=true;
      end;
    end;
  end else dec(self.apu.dpcm.phaseacc);
  self.apu.dpcm.output_:=self.apu.dpcm.vol;
end;

procedure cpu_n2a03.init_filter;
const
  pi_value=3.14159265358979323846;
var
  phase,tap:integer;
  cutoff,x,window,coefficient,total:double;
begin
  // 17.64 kHz low-pass at 44.1 kHz output, Blackman window. Coefficients are
  // prepared once, per clock. The FIR runs at the output rate, not CPU rate.
  cutoff:=(FREQ_BASE_AUDIO*0.4)/(self.clock/4.0);
  if cutoff>0.45 then cutoff:=0.45;
  for phase:=0 to APU_FILTER_PHASES-1 do begin
    total:=0;
    for tap:=0 to APU_FILTER_TAPS-1 do begin
      x:=tap-(APU_FILTER_TAPS-1)/2.0-phase/APU_FILTER_PHASES;
      window:=0.42-0.5*cos(2*pi_value*tap/(APU_FILTER_TAPS-1))+
        0.08*cos(4*pi_value*tap/(APU_FILTER_TAPS-1));
      if abs(x)<1.0e-12 then coefficient:=2*cutoff
        else coefficient:=sin(2*pi_value*cutoff*x)/(pi_value*x);
      coefficient:=coefficient*window;
      self.filter_coeff[phase,tap]:=coefficient;
      total:=total+coefficient;
    end;
    for tap:=0 to APU_FILTER_TAPS-1 do
      self.filter_coeff[phase,tap]:=self.filter_coeff[phase,tap]/total;
  end;
end;

function cpu_n2a03.filtered_sample(fraction:double):single;
var phase,tap,pos:integer;value:double;
begin
  phase:=trunc(fraction*APU_FILTER_PHASES);
  if phase<0 then phase:=0;
  if phase>=APU_FILTER_PHASES then phase:=APU_FILTER_PHASES-1;
  value:=0;
  pos:=self.filter_pos;
  for tap:=0 to APU_FILTER_TAPS-1 do begin
    value:=value+self.filter_history[pos]*self.filter_coeff[phase,tap];
    dec(pos);
    if pos<0 then pos:=APU_FILTER_TAPS-1;
  end;
  Result:=value;
end;

procedure cpu_n2a03.push_sample(value:single);
begin
  self.filter_history[self.filter_pos]:=value;
  self.state.resample_weight:=self.state.resample_weight+1.0;
  while self.state.resample_weight>=self.resample_period-1.0e-10 do begin
    self.state.resample_weight:=self.state.resample_weight-self.resample_period;
    if self.state.resample_weight<0 then self.state.resample_weight:=0;
    if self.state.buffer_count=TOTAL_BUFFER_SIZE then begin
      inc(self.state.buffer_read);
      if self.state.buffer_read>TOTAL_BUFFER_SIZE then self.state.buffer_read:=1;
      dec(self.state.buffer_count);
    end;
    self.buffer[self.state.buffer_write]:=
      self.filtered_sample(self.state.resample_weight);
    inc(self.state.buffer_write);
    if self.state.buffer_write>TOTAL_BUFFER_SIZE then self.state.buffer_write:=1;
    inc(self.state.buffer_count);
    inc(self.state.generated_samples);
    self.state.resample_sum:=0; // Retained in the state layout for NAP2/v1.
  end;
  inc(self.filter_pos);
  if self.filter_pos>=APU_FILTER_TAPS then self.filter_pos:=0;
end;

procedure cpu_n2a03.set_external_clock(enabled:boolean);
begin
  external_clock:=enabled;
  if advance_timer<>$ff then timers.enabled(advance_timer,not enabled);
end;
procedure cpu_n2a03.clock_cpu;
begin
  if not external_clock then Exit;
  Inc(state.cpu_cycles);clock_frame;
  apu_square(0);apu_square(1);apu_triangle;apu_noise;apu_dpcm;
  external_sum:=external_sum+square_lut[apu.squ[0].output_+apu.squ[1].output_]+
    tnd_lut[apu.tri.output_,apu.noi.output_,apu.dpcm.output_];
  Inc(external_div);
  if external_div=4 then begin push_sample(external_sum/4);external_div:=0;external_sum:=0;end;
end;
function cpu_n2a03.dmc_request(var address:word):boolean;
begin
  Result:=external_clock and dmc_requested and state.dmc_buffer_empty and(apu.dpcm.length>0);
  if Result then address:=word(apu.dpcm.address)
    else if apu.dpcm.length=0 then dmc_requested:=false;
end;
procedure cpu_n2a03.dmc_complete(value:byte);
begin
  dmc_requested:=false;
  if not state.dmc_buffer_empty or(apu.dpcm.length=0)then Exit;
  state.dmc_buffer:=value;state.dmc_buffer_empty:=false;
  if apu.dpcm.address=$ffff then apu.dpcm.address:=$8000 else Inc(apu.dpcm.address);
  Dec(apu.dpcm.length);
  if apu.dpcm.length=0 then begin
    apu.dpcm.enabled:=false;
    if(apu.dpcm.regs[0]and $40)<>0 then apu_dpcm_reset
      else if(apu.dpcm.regs[0]and $80)<>0 then begin apu.dpcm.irq:=true;update_irq;end;
  end;
end;

procedure cpu_n2a03.sound_advance;
var
  i:integer;
  value:single;
begin
  if external_clock then Exit;
  value:=0;
  for i:=1 to 4 do begin
    inc(self.state.cpu_cycles);
    self.clock_frame;
    self.apu_square(0);
    self.apu_square(1);
    self.apu_triangle;
    self.apu_noise;
    self.apu_dpcm;
    value:=value+square_lut[self.apu.squ[0].output_+self.apu.squ[1].output_]+
      tnd_lut[self.apu.tri.output_,self.apu.noi.output_,self.apu.dpcm.output_];
  end;
  self.push_sample(value/4);
end;

procedure cpu_n2a03.sound_update;
var
  res:single;
  sample_value:integer;
begin
  if self.state.buffer_count>0 then begin
    res:=self.buffer[self.state.buffer_read];
    inc(self.state.buffer_read);
    if self.state.buffer_read>TOTAL_BUFFER_SIZE then self.state.buffer_read:=1;
    dec(self.state.buffer_count);
    self.state.last_res:=res;
  end else res:=self.state.last_res;
  res:=self.filter_output(res);
  sample_value:=trunc(res*$7fff);
  if sample_value>32767 then sample_value:=32767
    else if sample_value< -32768 then sample_value:=-32768;
  tsample[self.tsample_num,sound_status.posicion_sonido]:=sample_value;
  if (@self.additional_sound<>nil) then self.additional_sound;
end;

function cpu_n2a03.save_snapshot(data:pbyte):word;
var
  p,cpusize_ptr:pbyte;
  cpusize,version:word;
  advance_phase,output_phase:single;
begin
  p:=data;
  cpusize_ptr:=p;inc(p,2);
  cpusize:=self.m6502.save_snapshot(p);copymemory(cpusize_ptr,@cpusize,2);inc(p,cpusize);
  copymemory(p,@self.apu,sizeof(self.apu));inc(p,sizeof(self.apu));
  copymemory(p,@self.state,sizeof(self.state));inc(p,sizeof(self.state));
  copymemory(p,@self.buffer,sizeof(self.buffer));inc(p,sizeof(self.buffer));
  advance_phase:=timers.timer[self.advance_timer].actual_time;
  output_phase:=timers.timer[self.output_timer].actual_time;
  copymemory(p,@advance_phase,4);inc(p,4);
  copymemory(p,@output_phase,4);inc(p,4);
  copymemory(p,@self.filter_pos,2);inc(p,2);
  copymemory(p,@self.filter_history,sizeof(self.filter_history));inc(p,sizeof(self.filter_history));
  copymemory(p,@self.output_state,sizeof(self.output_state));
  Result:=12+cpusize+sizeof(self.apu)+sizeof(self.state)+sizeof(self.buffer)+8+
    2+sizeof(self.filter_history)+sizeof(self.output_state);
end;

procedure cpu_n2a03.load_snapshot(data:pbyte);
var
  p:pbyte;cpusize,version:word;
  advance_phase,output_phase:single;
  tap:integer;
begin
  p:=data;
  copymemory(@cpusize,p,2);inc(p,2);
  self.m6502.load_snapshot(p);inc(p,cpusize);
  copymemory(@self.apu,p,sizeof(self.apu));inc(p,sizeof(self.apu));
  copymemory(@self.state,p,sizeof(self.state));inc(p,sizeof(self.state));
  copymemory(@self.buffer,p,sizeof(self.buffer));inc(p,sizeof(self.buffer));
  copymemory(@advance_phase,p,4);inc(p,4);
  copymemory(@output_phase,p,4);inc(p,4);
  if version>=2 then begin
    copymemory(@self.filter_pos,p,2);inc(p,2);
    copymemory(@self.filter_history,p,sizeof(self.filter_history));inc(p,sizeof(self.filter_history));
    if self.filter_pos>=APU_FILTER_TAPS then
      raise Exception.Create('n2a03: invalid snapshot filter position');
  end else begin
    // Preserve the DC level when migrating a snapshot from the unfiltered core.
    self.filter_pos:=0;
    for tap:=0 to APU_FILTER_TAPS-1 do
      self.filter_history[tap]:=self.state.last_res;
    self.state.resample_sum:=0;
  end;
  if version>=3 then copymemory(@self.output_state,p,sizeof(self.output_state))
  else begin
    fillchar(self.output_state,sizeof(self.output_state),0);
    self.output_state.enabled:=true;
  end;
  if (self.state.buffer_read<1) or (self.state.buffer_read>TOTAL_BUFFER_SIZE) or
     (self.state.buffer_write<1) or (self.state.buffer_write>TOTAL_BUFFER_SIZE) or
     (self.state.buffer_count>TOTAL_BUFFER_SIZE) then
    raise Exception.Create('n2a03: invalid snapshot buffer state');
  timers.timer[self.advance_timer].actual_time:=advance_phase;
  timers.timer[self.output_timer].actual_time:=output_phase;
  self.state.irq_line:=not(self.state.frame_irq_pending or self.apu.dpcm.irq);
  self.update_irq;
end;
end.
