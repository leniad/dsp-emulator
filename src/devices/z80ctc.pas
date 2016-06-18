unit z80ctc;

interface
uses z80daisy,timer_engine,main_engine,cpu_misc;

const
  INTERRUPT			= $80;
  INTERRUPT_ON		= $80;
  INTERRUPT_OFF		= $00;

  MODE				= $40;
  MODE_TIMER		= $00;
  MODE_COUNTER		= $40;

  PRESCALER			= $20;
  PRESCALER_256		= $20;
  PRESCALER_16		= $00;

  EDGE				= $10;
  EDGE_FALLING		= $00;
  EDGE_RISING		= $10;

  TRIGGER			= $08;
  TRIGGER_AUTO		= $00;
  TRIGGER_CLOCK		= $08;

  CONSTANT			= $04;
  CONSTANT_LOAD		= $04;
  CONSTANT_NONE		= $00;

  RESET				= $02;
  RESET_CONTINUE	= $00;
  RESET_ACTIVE		= $02;

  CONTROL			= $01;
  CONTROL_VECTOR	= $00;
  CONTROL_WORD		= $01;
// these extra bits help us keep things accurate
  WAITING_FOR_TRIG	= $100;


  NOTIMER_0=(1 shl 0);
  NOTIMER_1=(1 shl 1);
  NOTIMER_2=(1 shl 2);
  NOTIMER_3=(1 shl 3);


type
  tipo_ctc_channel=record
		m_zc:cpu_outport_call;			// zero crossing callbacks
		m_notimer:boolean;				// timer disabled?
		m_mode:word;					// current mode
		m_tconst:word;				// time constant
		m_down:word;					// down counter (clock mode only)
		m_extclk:byte;				// current signal from the external clock
		m_timer:byte;				// array of active timers
		m_int_state:byte;			// interrupt status (for daisy chain)
  end;
  ptipo_ctc_channel=^tipo_ctc_channel;
  tipo_z80ctc=record
    m_intr:cpu_outport_call;			// interrupt callback
	  m_vector:byte;				// interrupt vector
	  m_period16:single;				// 16/system clock
	  m_period256:single;			// 256/system clock
    clock_cpu:single;
	  ctc_channel:array[0..3] of ptipo_ctc_channel;			// data for each channel */
  end;
  ptipo_z80ctc=^tipo_z80ctc;

var
  z80_ctc:array[0..1] of ptipo_z80ctc;

procedure z80ctc_init(num,num_cpu:byte;clock,clock_cpu:single;m_notimer:byte;intr:cpu_outport_call=nil;m_zc0:cpu_outport_call=nil;m_zc1:cpu_outport_call=nil;m_zc2:cpu_outport_call=nil);
procedure z80ctc_close(num:byte);
procedure z80ctc_reset(num:byte);
function z80ctc_irq_state(num:byte):byte;
function z80ctc_irq_ack(num:byte):byte;
procedure z80ctc_irq_reti(num:byte);
procedure ctc_chan_00;
procedure ctc_chan_01;
procedure ctc_chan_02;
procedure ctc_chan_03;
procedure z80ctc_trg00_w(data:byte);
procedure z80ctc_trg01_w(data:byte);
procedure z80ctc_trg02_w(data:byte);
function z80ctc_r(num,chan:byte):byte;
procedure z80ctc_w(num,chan,data:byte);

implementation

procedure z80ctc_close(num:byte);
begin
if z80_ctc[num]<>nil then begin
  freemem(z80_ctc[num].ctc_channel[0]);
  z80_ctc[num].ctc_channel[0]:=nil;
  freemem(z80_ctc[num].ctc_channel[1]);
  z80_ctc[num].ctc_channel[1]:=nil;
  freemem(z80_ctc[num].ctc_channel[2]);
  z80_ctc[num].ctc_channel[2]:=nil;
  freemem(z80_ctc[num].ctc_channel[3]);
  z80_ctc[num].ctc_channel[3]:=nil;
  freemem(z80_ctc[num]);
  z80_ctc[num]:=nil;
end;
end;

procedure interrupt_check(num:byte);
var
  state:byte;
begin
  if (z80ctc_irq_state(num) and Z80_DAISY_INT)<>0 then state:=ASSERT_LINE
    else state:=CLEAR_LINE;
  z80_ctc[num].m_intr(state);
end;

procedure chanel_reset(ctc_channel:ptipo_ctc_channel);
begin
	ctc_channel.m_mode:=RESET_ACTIVE;
	ctc_channel.m_tconst:=$100;
  timer[ctc_channel.m_timer].enabled:=false;
	ctc_channel.m_int_state:=0;
end;

procedure z80ctc_reset(num:byte);
begin
	// reset each channel
	chanel_reset(z80_ctc[num].ctc_channel[0]);
	chanel_reset(z80_ctc[num].ctc_channel[1]);
	chanel_reset(z80_ctc[num].ctc_channel[2]);
	chanel_reset(z80_ctc[num].ctc_channel[3]);
	// check for interrupts
	interrupt_check(num);
end;

procedure start(num,num_cpu,index:byte;notimer:boolean;write_line:cpu_outport_call);
var
  ctc_channel:ptipo_ctc_channel;
begin
	// initialize state
	ctc_channel:=z80_ctc[num].ctc_channel[index];
	ctc_channel.m_zc:=write_line;
	ctc_channel.m_notimer:=notimer;
  case index of
    0:ctc_channel.m_timer:=init_timer(num_cpu,0,ctc_chan_00,false);
    1:ctc_channel.m_timer:=init_timer(num_cpu,0,ctc_chan_01,false);
    2:ctc_channel.m_timer:=init_timer(num_cpu,0,ctc_chan_02,false);
    3:ctc_channel.m_timer:=init_timer(num_cpu,0,ctc_chan_03,false);
  end;
end;

procedure z80ctc_init(num,num_cpu:byte;clock,clock_cpu:single;m_notimer:byte;intr:cpu_outport_call;m_zc0,m_zc1,m_zc2:cpu_outport_call);
var
  chip:ptipo_z80ctc;
begin
  getmem(z80_ctc[num],sizeof(tipo_z80ctc));
  chip:=z80_ctc[num];
  getmem(chip.ctc_channel[0],sizeof(tipo_ctc_channel));
  getmem(chip.ctc_channel[1],sizeof(tipo_ctc_channel));
  getmem(chip.ctc_channel[2],sizeof(tipo_ctc_channel));
  getmem(chip.ctc_channel[3],sizeof(tipo_ctc_channel));
	chip.m_period16:=clock*16;
	chip.m_period256:=clock*256;
  chip.clock_cpu:=clock_cpu;
	// resolve callbacks
	chip.m_intr:=intr;
	// start each channel
	start(num,num_cpu,0,(m_notimer and NOTIMER_0)<>0,m_zc0);
	start(num,num_cpu,1,(m_notimer and NOTIMER_1)<>0,m_zc1);
	start(num,num_cpu,2,(m_notimer and NOTIMER_2)<>0,m_zc2);
	start(num,num_cpu,3,(m_notimer and NOTIMER_3)<>0,nil);
end;

function z80ctc_irq_state(num:byte):byte;
var
  f,state:byte;
  chip:ptipo_z80ctc;
begin
  chip:=z80_ctc[num];
	// loop over all channels
	state:=0;
	for f:=0 to 3 do begin
		// if we're servicing a request, don't indicate more interrupts
		if (chip.ctc_channel[f].m_int_state and Z80_DAISY_IEO)<>0 then begin
			state:=state or Z80_DAISY_IEO;
			break;
    end;
		state:=state or chip.ctc_channel[f].m_int_state;
	end;
	z80ctc_irq_state:=state;
end;

function z80ctc_irq_ack(num:byte):byte;
var
  f:byte;
  chip:ptipo_z80ctc;
begin
  chip:=z80_ctc[num];
	// loop over all channels
	for f:=0 to 3 do begin
		// find the first channel with an interrupt requested
		if (chip.ctc_channel[f].m_int_state and Z80_DAISY_INT)<>0 then begin
			// clear interrupt, switch to the IEO state, and update the IRQs
			chip.ctc_channel[f].m_int_state:=Z80_DAISY_IEO;
			interrupt_check(num);
			z80ctc_irq_ack:=z80_ctc[num].m_vector+f*2;
      exit;
		end;
  end;
	z80ctc_irq_ack:=z80_ctc[num].m_vector;
end;

procedure z80ctc_irq_reti(num:byte);
var
  f:byte;
  chip:ptipo_z80ctc;
begin
  chip:=z80_ctc[num];
	// loop over all channels
	for f:=0 to 3 do begin
		// find the first channel with an IEO pending
		if (chip.ctc_channel[f].m_int_state and Z80_DAISY_IEO)<>0 then begin
			// clear the IEO state and update the IRQs
			chip.ctc_channel[f].m_int_state:=chip.ctc_channel[f].m_int_state and not(Z80_DAISY_IEO);
			interrupt_check(num);
			exit;
		end;
	end;
end;

procedure timer_callback(num,channel:byte);
var
  ctc_channel:ptipo_ctc_channel;
begin
  ctc_channel:=z80_ctc[num].ctc_channel[channel];
	// down counter has reached zero - see if we should interrupt
	if ((ctc_channel.m_mode and INTERRUPT)=INTERRUPT_ON) then begin
		ctc_channel.m_int_state:=ctc_channel.m_int_state or Z80_DAISY_INT;
		interrupt_check(num);
	end;
	// generate the clock pulse
  if @ctc_channel.m_zc<>nil then ctc_channel.m_zc(1);
  if @ctc_channel.m_zc<>nil then ctc_channel.m_zc(0);
	// reset the down counter
	ctc_channel.m_down:=ctc_channel.m_tconst;
end;

procedure ctc_chan_00;
begin
  timer_callback(0,0);
end;

procedure ctc_chan_01;
begin
  timer_callback(0,1);
end;

procedure ctc_chan_02;
begin
  timer_callback(0,2);
end;

procedure ctc_chan_03;
begin
  timer_callback(0,3);
end;

function period(num:byte;ctc_channel:ptipo_ctc_channel):single;
var
  temp:single;
begin
	// if reset active, no period
	if ((ctc_channel.m_mode and RESET)=RESET_ACTIVE) then begin
		period:=0;
    exit;
  end;
	// if counter mode, no real period
	if ((ctc_channel.m_mode and MODE)=MODE_COUNTER) then begin
	  period:=0;
    exit;
  end;
	// compute the period
  if ((ctc_channel.m_mode and PRESCALER)=PRESCALER_16) then temp:=z80_ctc[num].m_period16
    else temp:=z80_ctc[num].m_period256;
	period:=temp*ctc_channel.m_tconst;
end;

procedure ctc_trigger(num,chan,data:byte);
var
  curperiod:single;
  ctc_channel:ptipo_ctc_channel;
begin
  ctc_channel:=z80_ctc[num].ctc_channel[chan];
	// normalize data
	if data<>0 then data:=1;
	// see if the trigger value has changed
	if (data<>ctc_channel.m_extclk) then begin
	  ctc_channel.m_extclk:=data;
		// see if this is the active edge of the trigger
		if ((((ctc_channel.m_mode and EDGE)=EDGE_RISING) and (data<>0)) or (((ctc_channel.m_mode and EDGE)=EDGE_FALLING) and (data=0))) then begin
			// if we're waiting for a trigger, start the timer
			if (((ctc_channel.m_mode and WAITING_FOR_TRIG)<>0) and ((ctc_channel.m_mode and MODE)=MODE_TIMER)) then begin
				if not(ctc_channel.m_notimer) then begin
					curperiod:=period(num,ctc_channel);
          timer[ctc_channel.m_timer].time_final:=curperiod/z80_ctc[num].clock_cpu;
          timer[ctc_channel.m_timer].enabled:=true;
				end else begin
          timer[ctc_channel.m_timer].enabled:=false;
        end;
			end;
			// we're no longer waiting
			ctc_channel.m_mode:=ctc_channel.m_mode and not(WAITING_FOR_TRIG);
			// if we're clocking externally, decrement the count
			if ((ctc_channel.m_mode and MODE)=MODE_COUNTER) then begin
				// if we hit zero, do the same thing as for a timer interrupt
        ctc_channel.m_down:=ctc_channel.m_down-1;
				if (ctc_channel.m_down=0) then timer_callback(num,chan);
			end;
		end;
	end;
end;

procedure z80ctc_trg00_w(data:byte);
begin
  ctc_trigger(0,0,data);
end;

procedure z80ctc_trg01_w(data:byte);
begin
  ctc_trigger(0,1,data);
end;

procedure z80ctc_trg02_w(data:byte);
begin
  ctc_trigger(0,2,data);
end;

function ctc_read(num:byte;ctc_channel:ptipo_ctc_channel):byte;
var
  period:single;
begin
	// if we're in counter mode, just return the count
	if (((ctc_channel.m_mode and MODE)=MODE_COUNTER) or ((ctc_channel.m_mode and WAITING_FOR_TRIG)<>0)) then begin
		ctc_read:=ctc_channel.m_down;
  end else begin
	// else compute the down counter value
    if ((ctc_channel.m_mode and PRESCALER)=PRESCALER_16) then period:=z80_ctc[num].m_period16
      else period:=z80_ctc[num].m_period256;
		if (@timer[ctc_channel.m_timer].execute<>nil) then
      ctc_read:=trunc(timer[ctc_channel.m_timer].actual_time/period) and $ff
		else ctc_read:=0;
	end;
end;

procedure ctc_write(num,chan,data:byte);
var
  curperiod:single;
  ctc_channel:ptipo_ctc_channel;
begin
  ctc_channel:=z80_ctc[num].ctc_channel[chan];
	// if we're waiting for a time constant, this is it
	if ((ctc_channel.m_mode and CONSTANT)=CONSTANT_LOAD) then begin
		// set the time constant (0 -> 0x100)
    if data<>0 then ctc_channel.m_tconst:=data
      else ctc_channel.m_tconst:=$100;
		// clear the internal mode -- we're no longer waiting
		ctc_channel.m_mode:=ctc_channel.m_mode and not(CONSTANT);
		// also clear the reset, since the constant gets it going again
		ctc_channel.m_mode:=ctc_channel.m_mode and not(RESET);
		// if we're in timer mode....
		if ((ctc_channel.m_mode and MODE)=MODE_TIMER) then begin
			// if we're triggering on the time constant, reset the down counter now
			if ((ctc_channel.m_mode and TRIGGER)=TRIGGER_AUTO) then begin
				if not(ctc_channel.m_notimer) then begin
					curperiod:=period(num,ctc_channel);
          timer[ctc_channel.m_timer].time_final:=curperiod/z80_ctc[num].clock_cpu;
          timer[ctc_channel.m_timer].enabled:=true;
				end else timer[ctc_channel.m_timer].enabled:=false;
			end else
			// else set the bit indicating that we're waiting for the appropriate trigger
				ctc_channel.m_mode:=ctc_channel.m_mode or WAITING_FOR_TRIG;
		end;
		// also set the down counter in case we're clocking externally
		ctc_channel.m_down:=ctc_channel.m_tconst;
	end else if (((data and CONTROL)=CONTROL_VECTOR) and (chan=0)) then begin
		z80_ctc[num].m_vector:=data and $f8;
	end else
	    // this must be a control word
	    if ((data and CONTROL)=CONTROL_WORD) then begin
		// set the new mode
		ctc_channel.m_mode:=data;
		// if we're being reset, clear out any pending timers for this channel
		if ((data and RESET)=RESET_ACTIVE) then begin
			timer[ctc_channel.m_timer].enabled:=false;
    end;
  end;
end;

function z80ctc_r(num,chan:byte):byte;
begin
  z80ctc_r:=ctc_read(num,z80_ctc[num].ctc_channel[chan]);
end;

procedure z80ctc_w(num,chan,data:byte);
begin
  ctc_write(num,chan,data);
end;

end.
