unit sn_76496;

interface
uses main_engine,sound_engine,timer_engine,dialogs;

type
  type_ready_cb=procedure(state:byte);
  SN76496_chip=class(snd_chip_class)
    constructor create(clock:dword;ready_cb:type_ready_cb=nil;amp:single=1);
    destructor free;
  public
    procedure write(data:byte);
    procedure update;
    procedure reset;
    function save_snapshot(data:pbyte):word;
    procedure load_snapshot(data:pbyte);
    procedure change_clock(clock:dword);
  private
    UpdateStep:dword;
    VolTable:array[0..15] of single;
    Registers:array[0..7] of word;
    LastRegister:byte;
    Volume:array[0..3] of single;
    Period,Count:array[0..3] of integer;
    Output:array[0..3] of byte;
    RNG:cardinal;
    ready_state:byte;
    ready_cb:type_ready_cb;
    chip_num,ready_timer:byte;
    procedure set_gain(gain:integer);
    procedure resample;
    procedure recalculate_periods(preserve_phase:boolean);
    procedure advance_noise;
    procedure schedule_ready;
  end;

var
  sn_76496_0,sn_76496_1,sn_76496_2,sn_76496_3:sn76496_chip;

implementation
const
  MAX_OUTPUT=$7fff;
  SN_STEP=$10000;
  TI_FEEDBACK=$10000;
var
  instances:array[0..3] of sn76496_chip;

procedure end_ready(index:byte);
var
  chip:sn76496_chip;
begin
  if index>3 then Exit;
  chip:=instances[index];
  if chip=nil then Exit;
  timers.enabled(chip.ready_timer,false);
  chip.ready_state:=ASSERT_LINE;
  if @chip.ready_cb<>nil then chip.ready_cb(ASSERT_LINE);
end;

constructor sn76496_chip.create(clock:dword;ready_cb:type_ready_cb=nil;amp:single=1);
var
  i:integer;
begin
  if addr(update_sound_proc)=nil then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!',mtInformation,[mbOk],0);
  for i:=0 to 3 do
    if instances[i]=nil then begin
      self.chip_num:=i;
      break;
    end;
  self.clock:=clock;
  self.amp:=amp;
  self.ready_cb:=ready_cb;
  self.set_gain(0);
  self.resample;
  self.tsample_num:=init_channel;
  self.ready_timer:=timers.init(sound_status.cpu_num,1,nil,end_ready,false,self.chip_num);
  instances[self.chip_num]:=self;
  self.reset;
end;

destructor sn76496_chip.free;
begin
  if self.chip_num<=3 then begin
    if instances[self.chip_num]=self then begin
      timers.enabled(self.ready_timer,false);
      instances[self.chip_num]:=nil;
    end;
  end;
end;

procedure sn76496_chip.resample;
var
  value:Int64;
begin
  value:=Round((Double(SN_STEP)*16*FREQ_BASE_AUDIO)/self.clock);
  self.UpdateStep:=value;
end;

procedure sn76496_chip.recalculate_periods(preserve_phase:boolean);
var
  i,divisor,new_period:integer;
begin
  for i:=0 to 3 do begin
    if i<3 then begin
      divisor:=self.Registers[i*2] and $3ff;
      if divisor=0 then divisor:=$400; // TI SN76496, not Sega PSG.
      new_period:=Integer(self.UpdateStep)*divisor;
    end else begin
      if (self.Registers[6] and 3)=3 then new_period:=self.Period[2]*2
        else new_period:=Integer(self.UpdateStep) shl (5+(self.Registers[6] and 3));
    end;
    if preserve_phase and (self.Period[i]>0) then self.Count[i]:=(Int64(self.Count[i])*new_period) div self.Period[i]
      else self.Count[i]:=new_period;
    self.Period[i]:=new_period;
    if self.Count[i]<1 then self.Count[i]:=1;
  end;
end;

procedure sn76496_chip.change_clock(clock:dword);
var
  previous_clock:dword;
begin
  previous_clock:=self.clock;
  self.clock:=clock;
  self.resample;
  self.recalculate_periods(true);
  // A pending READY interval restarts at the new clock.
  if self.ready_state=CLEAR_LINE then self.schedule_ready;
end;

procedure sn76496_chip.set_gain(gain:integer);
var
  i:integer;
  value:double;
begin
  value:=MAX_OUTPUT/4.0;
  while gain>0 do begin
    value:=value*1.023292992;
    dec(gain);
  end;
  for i:=0 to 14 do begin
    if value>MAX_OUTPUT/4.0 then self.VolTable[i]:=MAX_OUTPUT/4.0
      else self.VolTable[i]:=value;
    value:=value/1.258925412;
  end;
  self.VolTable[15]:=0;
end;

procedure sn76496_chip.reset;
var
  i:integer;
begin
  timers.enabled(self.ready_timer,false);
  self.LastRegister:=0;
  for i:=0 to 3 do begin
    self.Registers[i*2]:=0;
    self.Registers[i*2+1]:=$f;
    self.Volume[i]:=0;
    self.Output[i]:=0;
  end;
  self.recalculate_periods(false);
  self.RNG:=TI_FEEDBACK;
  self.Output[3]:=self.RNG and 1;
  self.ready_state:=ASSERT_LINE;
  if @self.ready_cb<>nil then self.ready_cb(ASSERT_LINE);
end;

procedure sn76496_chip.advance_noise;
var
  tap1,tap2:boolean;
begin
  tap1:=(self.RNG and $04)<>0;
  tap2:=((self.RNG and $08)<>0) and ((self.Registers[6] and 4)<>0);
  self.RNG:=self.RNG shr 1;
  if tap1<>tap2 then self.RNG:=self.RNG or TI_FEEDBACK;
  self.Output[3]:=self.RNG and 1;
end;

procedure sn76496_chip.schedule_ready;
begin
  // Per-instance timer, avoiding shared one-shot slots and global pointers.
  // Preserve the previous nominal READY delay of 32 input-clock cycles.
  timers.enabled(self.ready_timer,false);
  timers.timer[self.ready_timer].time_final:=(sound_status.cpu_clock*32.0)/self.clock;
  timers.enabled(self.ready_timer,true);
end;

procedure sn76496_chip.write(data:byte);
var
  r,c,n:integer;
begin
  // The host driver must synchronize pending audio before this call.
  if (data and $80)<>0 then begin
    r:=(data shr 4) and 7;
    self.LastRegister:=r;
    self.Registers[r]:=(self.Registers[r] and $3f0) or (data and $f);
  end else r:=self.LastRegister;
  c:=r shr 1;
  case r of
    0,2,4:begin
      if (data and $80)=0 then self.Registers[r]:=(self.Registers[r] and $f) or ((data and $3f) shl 4);
      n:=self.Registers[r] and $3ff;
      if n=0 then n:=$400;
      self.Period[c]:=Integer(self.UpdateStep)*n;
      if (r=4) and ((self.Registers[6] and 3)=3) then self.Period[3]:=self.Period[2]*2;
    end;
    1,3,5,7:begin
      self.Registers[r]:=data and $f;
      self.Volume[c]:=self.VolTable[data and $f];
    end;
    6:begin
      self.Registers[6]:=data and $f;
      n:=self.Registers[6] and 3;
      if n=3 then self.Period[3]:=self.Period[2]*2
        else self.Period[3]:=Integer(self.UpdateStep) shl (5+n);
      self.RNG:=TI_FEEDBACK;
    end;
  end;
  self.ready_state:=CLEAR_LINE;
  self.schedule_ready;
  if @self.ready_cb<>nil then self.ready_cb(CLEAR_LINE);
end;

function sn76496_chip.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
  clock:dword;
  gain:single;
  procedure put(const value;count:integer);
  begin
    CopyMemory(temp,@value,count);
    Inc(temp,count);
    size:=size+count;
  end;
begin
  temp:=data;
  size:=0;
  clock:=self.clock;
  gain:=self.amp;
  put(clock,4);
  put(gain,SizeOf(gain));
  put(self.UpdateStep,4);
  put(self.VolTable,SizeOf(self.VolTable));
  put(self.Registers,SizeOf(self.Registers));
  put(self.LastRegister,1);
  put(self.Volume,SizeOf(self.Volume));
  put(self.Period,SizeOf(self.Period));
  put(self.Count,SizeOf(self.Count));
  put(self.Output,SizeOf(self.Output));
  put(self.RNG,4);
  put(self.ready_state,1);
  save_snapshot:=size;
end;

procedure sn76496_chip.load_snapshot(data:pbyte);
var
  temp:pbyte;
  clock:dword;
  gain:single;
  i:integer;
  procedure get(var value;count:integer);
  begin
    CopyMemory(@value,temp,count);
    Inc(temp,count);
  end;
begin
  temp:=data;
  timers.enabled(self.ready_timer,false);
  get(clock,4);
  get(gain,SizeOf(gain));
  self.clock:=clock;
  self.amp:=gain;
  get(self.UpdateStep,4);
  get(self.VolTable,SizeOf(self.VolTable));
  get(self.Registers,SizeOf(self.Registers));
  get(self.LastRegister,1);
  get(self.Volume,SizeOf(self.Volume));
  get(self.Period,SizeOf(self.Period));
  get(self.Count,SizeOf(self.Count));
  get(self.Output,SizeOf(self.Output));
  get(self.RNG,4);
  get(self.ready_state,1);
  if self.ready_state=CLEAR_LINE then self.schedule_ready;
  if @self.ready_cb<>nil then self.ready_cb(self.ready_state);
end;

procedure sn76496_chip.update;
Var
  i,left,nextevent:Integer;
  out_sn:double;
  sample:smallint;
  vol:array[0..3] of integer;
begin
	// If the volume is 0, increase the counter */
	for i:=0 to 3 do begin
		if (self.Volume[i]=0) then begin
			{ note that I do count += length, NOT count = length + 1. You might think */
			 it's the same since the volume is 0, but doing the latter could cause */
			 interferencies when the program is rapidly modulating the volume. }
         if (self.Count[i]<=SN_STEP) then inc(self.Count[i],SN_STEP);
		end;
   end;
		{ vol[] keeps track of how long each square wave stays
		 in the 1 position during the sample period. }
    for i:=0 to 3 do vol[i]:=0;
		for i:=0 to 2 do begin
			if (self.Output[i])<>0 then inc(vol[i],self.Count[i]);
			dec(self.Count[i],SN_STEP);
			{ Period[i] is the half period of the square wave. Here, in each */
			loop I add Period[i] twice, so that at the end of the loop the */
			square wave is in the same status (0 or 1) it was at the start. */
			vol[i] is also incremented by Period[i], since the wave has been 1 */
			exactly half of the time, regardless of the initial position. */
			If we exit the loop in the middle, Output[i] has to be inverted */
			and vol[i] incremented only if the exit status of the square */
			wave is 1. }
			while (self.Count[i] <= 0) do begin
				inc(self.Count[i],self.Period[i]);
				if (self.Count[i] > 0) then begin
					self.Output[i]:=self.Output[i] xor 1;
					if (self.Output[i])<>0 then inc(vol[i],self.Period[i]);
          break;
				end;
				inc(self.Count[i],self.Period[i]);
				inc(vol[i],self.Period[i]);
			end; //del while
			if (self.Output[i])<>0 then dec(vol[i],self.Count[i]);
		end; //del for
		left:=SN_STEP;
    repeat
			if (self.Count[3] < left) then nextevent:=self.Count[3]
			  else nextevent:=left;
			if (self.Output[3])<>0 then inc(vol[3],self.Count[3]);
			dec(self.Count[3],nextevent);
			if (self.Count[3] <= 0) then begin
				self.advance_noise;
				inc(self.Count[3],self.Period[3]);
				if (self.Output[3])<>0 then inc(vol[3],self.Period[3]);
			end;
			if (self.Output[3])<>0 then dec(vol[3],self.Count[3]);
			dec(left,nextevent);
    until (left=0);
		out_sn:=vol[0]*self.Volume[0]+vol[1]*self.Volume[1]+vol[2]*self.Volume[2]+vol[3]*self.Volume[3];
    out_sn:=(out_sn/SN_STEP)*self.amp;
    if out_sn>32767 then sample:=32767
      else if out_sn< -32768 then sample:=-32768
        else sample:=trunc(out_sn);
    tsample[self.tsample_num,sound_status.posicion_sonido]:=sample;
    if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=sample;
end;

end.
