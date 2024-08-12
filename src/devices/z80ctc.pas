unit z80ctc;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
      z80daisy,timer_engine,main_engine,cpu_misc;

function ctc0_irq_state:byte;
function ctc0_irq_ack:byte;
procedure ctc0_irq_reti;

const
  NOTIMER_0=(1 shl 0);
  NOTIMER_1=(1 shl 1);
  NOTIMER_2=(1 shl 2);
  NOTIMER_3=(1 shl 3);
  CTC0_TRG00=0;
  CTC0_TRG01=1;
  CTC0_TRG02=2;
  CTC0_TRG03=3;
  CTC0_NONE=4;

type
  zc_call=procedure(state:boolean);
  tctc_channel=class
      constructor create(num_cpu,index:byte;notimer:boolean;write_line:zc_call);
      destructor free;
    public
      procedure reset;
    private
		  zc:zc_call;			// zero crossing callbacks
		  notimer:boolean;				// timer disabled?
		  mode:word;					// current mode
		  tconst:word;				// time constant
		  down:word;					// down counter (clock mode only)
		  extclk:boolean;				// current signal from the external clock
		  timer:byte;				// array of active timers
		  int_state:byte;			// interrupt status (for daisy chain)
  end;
  tz80ctc=class
        constructor create(num_cpu:byte;clock,clock_cpu:uint64;notimer:byte;zc0_call:byte;zc1_call:byte=4;zc2_call:byte=4);
        destructor free;
      public
        procedure reset;
        function read(chan:byte):byte;
        procedure write(chan,valor:byte);
        procedure change_calls(int:cpu_outport_call);
        procedure trigger(chan:byte;valor:boolean);
      private
        intr:cpu_outport_call;			// interrupt callback
	      vector:byte;				// interrupt vector
	      period16:dword;				// 16/system clock
	      period256:dword;			// 256/system clock
        clock_cpu:uint64;
	      ctc_channel:array[0..3] of tctc_channel;			// data for each channel
        procedure interrupt_check;
        function period(chan:byte):uint64;
        procedure timer_callback(chan:byte);
        function irq_state:byte;
        function irq_ack:byte;
        procedure irq_reti;
  end;

var
  ctc_0:tz80ctc;

implementation
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
  TRIGGER_			= $08;
  TRIGGER_AUTO		= $00;
  TRIGGER_CLOCK		= $08;
  CONSTANT			= $04;
  CONSTANT_LOAD		= $04;
  CONSTANT_NONE		= $00;
  RESET_				= $02;
  RESET_CONTINUE	= $00;
  RESET_ACTIVE		= $02;
  CONTROL			= $01;
  CONTROL_VECTOR	= $00;
  CONTROL_WORD		= $01;
  // these extra bits help us keep things accurate
  WAITING_FOR_TRIG	= $100;
var
  chips_total:integer=-1;

//Public
procedure ctc0_trg00_w(valor:boolean);
begin
  ctc_0.trigger(0,valor);
end;

procedure ctc0_trg01_w(valor:boolean);
begin
  ctc_0.trigger(1,valor);
end;

procedure ctc0_trg02_w(valor:boolean);
begin
  ctc_0.trigger(2,valor);
end;

procedure ctc0_trg03_w(valor:boolean);
begin
  ctc_0.trigger(3,valor);
end;

function ctc0_irq_state:byte;
begin
  ctc0_irq_state:=ctc_0.irq_state;
end;

function ctc0_irq_ack:byte;
begin
  ctc0_irq_ack:=ctc_0.irq_ack;
end;

procedure ctc0_irq_reti;
begin
  ctc_0.irq_reti;
end;

//CTC
constructor tz80ctc.create(num_cpu:byte;clock,clock_cpu:uint64;notimer:byte;zc0_call:byte;zc1_call:byte=4;zc2_call:byte=4);
function select_zc(zc_call:byte):zc_call;
begin
  case zc_call of
    0:select_zc:=ctc0_trg00_w;
    1:select_zc:=ctc0_trg01_w;
    2:select_zc:=ctc0_trg02_w;
    3:select_zc:=ctc0_trg03_w;
    4:select_zc:=nil;
  end;
end;
begin
  chips_total:=chips_total+1;
  self.period16:=clock*16;
  self.period256:=clock*256;
  self.clock_cpu:=clock_cpu;
  // start each channel
  self.ctc_channel[0]:=tctc_channel.create(num_cpu,0,(notimer and NOTIMER_0)<>0,select_zc(zc0_call));
  self.ctc_channel[1]:=tctc_channel.create(num_cpu,1,(notimer and NOTIMER_1)<>0,select_zc(zc1_call));
  self.ctc_channel[2]:=tctc_channel.create(num_cpu,2,(notimer and NOTIMER_2)<>0,select_zc(zc2_call));
  self.ctc_channel[3]:=tctc_channel.create(num_cpu,3,(notimer and NOTIMER_3)<>0,nil);
end;

destructor tz80ctc.free;
var
  f:byte;
begin
  for f:=0 to 3 do self.ctc_channel[f].free;
  chips_total:=chips_total-1;
end;

procedure tz80ctc.reset;
var
  f:byte;
begin
  for f:=0 to 3 do self.ctc_channel[f].reset;
  self.interrupt_check;
end;

procedure tz80ctc.change_calls(int:cpu_outport_call);
begin
  self.intr:=int;
end;

function tz80ctc.read(chan:byte):byte;
var
  period:uint64;
begin
	// if we're in counter mode, just return the count
	if (((self.ctc_channel[chan].mode and MODE)=MODE_COUNTER) or ((self.ctc_channel[chan].mode and WAITING_FOR_TRIG)<>0)) then begin
		read:=self.ctc_channel[chan].down;
  end else begin
	// else compute the down counter value
    if ((self.ctc_channel[chan].mode and PRESCALER)=PRESCALER_16) then period:=self.period16
      else period:=self.period256;
		if (@timers.timer[self.ctc_channel[chan].timer].execute_param<>nil) then
      read:=trunc(timers.timer[self.ctc_channel[chan].timer].actual_time/period) and $ff
		else read:=0;
	end;
end;

procedure tz80ctc.write(chan,valor:byte);
var
  curperiod:uint64;
begin
	// if we're waiting for a time constant, this is it
	if ((self.ctc_channel[chan].mode and CONSTANT)=CONSTANT_LOAD) then begin
		// set the time constant (0 -> 0x100)
    if valor<>0 then self.ctc_channel[chan].tconst:=valor
      else self.ctc_channel[chan].tconst:=$100;
		// clear the internal mode -- we're no longer waiting
		self.ctc_channel[chan].mode:=self.ctc_channel[chan].mode and not(CONSTANT);
		// also clear the reset, since the constant gets it going again
		self.ctc_channel[chan].mode:=self.ctc_channel[chan].mode and not(RESET_);
		// if we're in timer mode....
		if ((self.ctc_channel[chan].mode and MODE)=MODE_TIMER) then begin
			// if we're triggering on the time constant, reset the down counter now
			if ((self.ctc_channel[chan].mode and TRIGGER_)=TRIGGER_AUTO) then begin
				if not(self.ctc_channel[chan].notimer) then begin
					curperiod:=self.period(chan);
          timers.timer[self.ctc_channel[chan].timer].time_final:=curperiod/self.clock_cpu;
          timers.enabled(self.ctc_channel[chan].timer,true);
				end else timers.enabled(self.ctc_channel[chan].timer,false);
			end else
			// else set the bit indicating that we're waiting for the appropriate trigger
				self.ctc_channel[chan].mode:=self.ctc_channel[chan].mode or WAITING_FOR_TRIG;
		end;
		// also set the down counter in case we're clocking externally
		self.ctc_channel[chan].down:=self.ctc_channel[chan].tconst;
	end else if (((valor and CONTROL)=CONTROL_VECTOR) and (chan=0)) then begin
		self.vector:=valor and $f8;
	end else
	    // this must be a control word
	    if ((valor and CONTROL)=CONTROL_WORD) then begin
		// set the new mode
		self.ctc_channel[chan].mode:=valor;
		// if we're being reset, clear out any pending timers for this channel
		if ((valor and RESET_)=RESET_ACTIVE) then begin
			timers.enabled(self.ctc_channel[chan].timer,false);
    end;
  end;
end;

function tz80ctc.period(chan:byte):uint64;
var
  temp:uint64;
begin
	// if reset active, no period
	if ((self.ctc_channel[chan].mode and RESET_)=RESET_ACTIVE) then begin
		period:=0;
    exit;
  end;
	// if counter mode, no real period
	if ((self.ctc_channel[chan].mode and MODE)=MODE_COUNTER) then begin
	  period:=0;
    exit;
  end;
	// compute the period
  if ((self.ctc_channel[chan].mode and PRESCALER)=PRESCALER_16) then temp:=self.period16
    else temp:=self.period256;
	period:=temp*self.ctc_channel[chan].tconst;
end;

procedure tz80ctc.interrupt_check;
var
  state:byte;
begin
  if (self.irq_state and Z80_DAISY_INT)<>0 then state:=ASSERT_LINE
    else state:=CLEAR_LINE;
  self.intr(state);
end;

function tz80ctc.irq_state:byte;
var
  f,state:byte;
begin
	// loop over all channels
	state:=0;
	for f:=0 to 3 do begin
		// if we're servicing a request, don't indicate more interrupts
		if (self.ctc_channel[f].int_state and Z80_DAISY_IEO)<>0 then begin
			state:=state or Z80_DAISY_IEO;
			break;
    end;
		state:=state or self.ctc_channel[f].int_state;
	end;
	irq_state:=state;
end;

function tz80ctc.irq_ack:byte;
var
  f:byte;
begin
	// loop over all channels
	for f:=0 to 3 do begin
		// find the first channel with an interrupt requested
		if (self.ctc_channel[f].int_state and Z80_DAISY_INT)<>0 then begin
			// clear interrupt, switch to the IEO state, and update the IRQs
			self.ctc_channel[f].int_state:=Z80_DAISY_IEO;
			self.interrupt_check;
			irq_ack:=self.vector+f*2;
      exit;
		end;
  end;
	irq_ack:=self.vector;
end;

procedure tz80ctc.irq_reti;
var
  f:byte;
begin
	// loop over all channels
	for f:=0 to 3 do begin
		// find the first channel with an IEO pending
		if (self.ctc_channel[f].int_state and Z80_DAISY_IEO)<>0 then begin
			// clear the IEO state and update the IRQs
			self.ctc_channel[f].int_state:=self.ctc_channel[f].int_state and not(Z80_DAISY_IEO);
			self.interrupt_check;
			exit;
		end;
	end;
end;

procedure tz80ctc.trigger(chan:byte;valor:boolean);
var
  curperiod:uint64;
begin
	// see if the trigger value has changed
	if (valor<>self.ctc_channel[chan].extclk) then begin
	  self.ctc_channel[chan].extclk:=valor;
		// see if this is the active edge of the trigger
		if ((((self.ctc_channel[chan].mode and EDGE)=EDGE_RISING) and valor) or (((self.ctc_channel[chan].mode and EDGE)=EDGE_FALLING) and not(valor))) then begin
			// if we're waiting for a trigger, start the timer
			if (((self.ctc_channel[chan].mode and WAITING_FOR_TRIG)<>0) and ((self.ctc_channel[chan].mode and MODE)=MODE_TIMER)) then begin
				if not(self.ctc_channel[chan].notimer) then begin
					curperiod:=self.period(chan);
          timers.timer[self.ctc_channel[chan].timer].time_final:=curperiod/self.clock_cpu;
          timers.enabled(self.ctc_channel[chan].timer,true);
				end else begin
          timers.enabled(self.ctc_channel[chan].timer,false);
        end;
			end;
			// we're no longer waiting
			self.ctc_channel[chan].mode:=self.ctc_channel[chan].mode and not(WAITING_FOR_TRIG);
			// if we're clocking externally, decrement the count
			if ((self.ctc_channel[chan].mode and MODE)=MODE_COUNTER) then begin
				// if we hit zero, do the same thing as for a timer interrupt
        self.ctc_channel[chan].down:=self.ctc_channel[chan].down-1;
				if (self.ctc_channel[chan].down=0) then self.timer_callback(chan);
			end;
		end;
	end;
end;

procedure tz80ctc.timer_callback(chan:byte);
begin
	// down counter has reached zero - see if we should interrupt
	if ((self.ctc_channel[chan].mode and INTERRUPT)=INTERRUPT_ON) then begin
		self.ctc_channel[chan].int_state:=self.ctc_channel[chan].int_state or Z80_DAISY_INT;
		self.interrupt_check;
	end;
	// generate the clock pulse
  if @self.ctc_channel[chan].zc<>nil then begin
    self.ctc_channel[chan].zc(true);
    self.ctc_channel[chan].zc(false);
  end;
	// reset the down counter
	self.ctc_channel[chan].down:=self.ctc_channel[chan].tconst;
end;

procedure ctc0_channnel(index:byte);
begin
  ctc_0.timer_callback(index);
end;

//Channel
constructor tctc_channel.create(num_cpu,index:byte;notimer:boolean;write_line:zc_call);
begin
  self.zc:=write_line;
  self.notimer:=notimer;
  case chips_total of
    0:self.timer:=timers.init(num_cpu,0,nil,ctc0_channnel,false,index);
  end;
end;

destructor tctc_channel.free;
begin
end;

procedure tctc_channel.reset;
begin
  self.mode:=RESET_ACTIVE;
	self.tconst:=$100;
  timers.enabled(self.timer,false);
	self.int_state:=0;
end;

end.
