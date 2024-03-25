unit msm5205;
interface
uses math,timer_engine,sound_engine{$ifdef windows},windows{$endif};

const
  MSM5205_S96_3B=0;     // prescaler 1/96(4KHz) , data 3bit
  MSM5205_S48_3B=1;     // prescaler 1/48(8KHz) , data 3bit
  MSM5205_S64_3B=2;     // prescaler 1/64(6KHz) , data 3bit
  MSM5205_SEX_3B=3;     // VCLK slave mode      , data 3bit
  MSM5205_S96_4B=4;     // prescaler 1/96(4KHz) , data 4bit
  MSM5205_S48_4B=5;     // prescaler 1/48(8KHz) , data 4bit
  MSM5205_S64_4B=6;     // prescaler 1/64(6KHz) , data 4bit
  MSM5205_SEX_4B=7;     // VCLK slave mode      , data 4bit
type
  MSM5205_chip=class(snd_chip_class)
        constructor create(clock:dword;select:byte;amp:single;size:dword);
        destructor free;
      public
        pos,end_,rom_size:dword;
        data_val:integer;
        rom_data:pbyte;
        idle:boolean;
        procedure reset;
        procedure reset_w(reset_data:boolean);
        procedure data_w(data:byte);
        procedure vclk_w(vclk:boolean);
        procedure update;
        procedure change_advance(snd_timer_call:exec_type_simple);
      private
        data:byte;          // next adpcm data
        vclk:boolean;       // vclk signal (external mode)
        reset_data:boolean; // reset pin signal
        prescaler:byte;     // prescaler selector S1 and S2
        bitwidth:byte;      // bit width selector -3B/4B
        signal:integer;     // current ADPCM signal
        step:integer;       // current ADPCM step
        select:byte;
        timer_:byte;
        external_call:procedure;
        procedure playmode_w(select:byte);
        procedure stream_update;
  end;

var
  msm5205_0,msm5205_1:MSM5205_chip;

implementation

var
  diff_lookup:array[0..(49*16)-1] of integer;
  chips_total:integer=-1;
const
  index_shift:array[0..7] of integer=(-1, -1, -1, -1, 2, 4, 6, 8);

procedure msm5205_computetables;
// nibble to bit map
const
  nbl2bit:array[0..15,0..3] of integer= (
		( 1, 0, 0, 0), ( 1, 0, 0, 1), ( 1, 0, 1, 0), ( 1, 0, 1, 1),
		( 1, 1, 0, 0), ( 1, 1, 0, 1), ( 1, 1, 1, 0), ( 1, 1, 1, 1),
		(-1, 0, 0, 0), (-1, 0, 0, 1), (-1, 0, 1, 0), (-1, 0, 1, 1),
		(-1, 1, 0, 0), (-1, 1, 0, 1), (-1, 1, 1, 0), (-1, 1, 1, 1));
var
	step,nib,stepval:integer;
begin
	// loop over all possible steps
	for step:=0 to 48 do begin
		// compute the step value
		stepval:=floor(16.0*power(11.0/10.0,step));
		// loop over all nibbles and compute the difference
		for nib:=0 to 15 do begin
			diff_lookup[step*16+nib]:=nbl2bit[nib][0]*
				(stepval*nbl2bit[nib][1]+
				(stepval shr 1)*nbl2bit[nib][2]+
				(stepval shr 2)*nbl2bit[nib][3]+
				(stepval shr 3));
		end;
	end;
end;

procedure MSM5205_chip.stream_update;
begin
  if @self.external_call<>nil then self.external_call;
	// reset check at last hieddge of VCLK
	if self.reset_data then begin
		self.signal:=0;
		self.step:=0;
    self.data_val:=-1;
	end else begin //Clock signal
    // !! MSM5205 has internal 12bit decoding, signal width is 0 to 8191 !!
    self.signal:=self.signal+diff_lookup[self.step*16+(self.data and 15)];
    if (self.signal>2047) then self.signal:=2047
      else if (self.signal<-2048) then self.signal:=-2048;
    self.step:=self.step+index_shift[self.data and 7];
    if (self.step>48) then self.step:=48
      else if (self.step<0) then self.step:=0;
  end;
end;

procedure msm5205_internal_update(index:byte);
begin
  case index of
    0:begin
        msm5205_0.stream_update;
        //Slave!!
        if msm5205_1<>nil then if msm5205_1.prescaler=0 then msm5205_1.stream_update;
    end;
    1:msm5205_1.stream_update;
  end;
end;

procedure MSM5205_chip.update;
begin
  tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc((self.signal shl 4)*self.amp);
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=round((self.signal shl 4)*self.amp);
end;

procedure advance_0;
begin
if msm5205_0.idle then exit;
if (msm5205_0.data_val<>-1) then begin
  msm5205_0.data_w(msm5205_0.data_val and $f);
  msm5205_0.data_val:=-1;
  msm5205_0.pos:=msm5205_0.pos+1;
  if ((msm5205_0.pos>=msm5205_0.end_) or (msm5205_0.pos>msm5205_0.rom_size)) then msm5205_0.reset_w(true);
end else begin
  msm5205_0.data_val:=msm5205_0.rom_data[msm5205_0.pos];
  msm5205_0.data_w(msm5205_0.data_val shr 4);
end;
end;

procedure advance_1;
begin
if msm5205_1.idle then exit;
if (msm5205_1.data_val<>-1) then begin
  msm5205_1.data_w(msm5205_1.data_val and $f);
  msm5205_1.data_val:=-1;
  msm5205_1.pos:=msm5205_1.pos+1;
  if ((msm5205_1.pos>=msm5205_1.end_) or (msm5205_1.pos=msm5205_1.rom_size)) then msm5205_1.reset_w(true);
end else begin
  msm5205_1.data_val:=msm5205_1.rom_data[msm5205_1.pos];
  msm5205_1.data_w(msm5205_1.data_val shr 4);
end;
end;

constructor MSM5205_chip.create(clock:dword;select:byte;amp:single;size:dword);
begin
  chips_total:=chips_total+1;
  self.prescaler:=$ff;
  self.amp:=amp;
	self.clock:=clock;
  self.select:=select;
  self.tsample_num:=init_channel;
  case chips_total of
    0:begin
        msm5205_computetables;
        self.external_call:=advance_0;
    end;
    1:self.external_call:=advance_1;
  end;
  self.timer_:=timers.init(sound_status.cpu_num,1,nil,msm5205_internal_update,false,chips_total);
  if size<>0 then getmem(self.rom_data,size);
  self.rom_size:=size;
  self.reset;
end;

destructor MSM5205_chip.free;
begin
chips_total:=chips_total-1;
if self.rom_size<>0 then freemem(self.rom_data);
end;

procedure MSM5205_chip.reset;
begin
	// initialize work
	self.data:=0;
	self.vclk:=false;
	self.reset_data:=true;
	self.signal:=0;
	self.step:=-2;
	// timer and bitwidth set
	self.playmode_w(self.select);
  self.pos:=0;
  self.end_:=0;
  self.data_val:=-1;
  self.idle:=true;
end;

procedure MSM5205_chip.change_advance(snd_timer_call:exec_type_simple);
begin
  self.external_call:=snd_timer_call;
end;

procedure MSM5205_chip.playmode_w(select:byte);
const
  prescaler_table:array[0..3] of integer=(96,48,64,0);
var
  prescaler,bitwidth:byte;
begin
	prescaler:=prescaler_table[select and 3];
	if (select and 4)<>0 then bitwidth:=4
    else bitwidth:=3;
	if (self.prescaler<>prescaler) then begin
		self.prescaler:=prescaler;
		// timer set
    if (prescaler<>0) then begin
  			timers.timer[self.timer_].time_final:=sound_status.cpu_clock/(self.clock/prescaler);
        timers.enabled(self.timer_,true);
  		end else timers.enabled(self.timer_,false);
  end;
	if (self.bitwidth<>bitwidth) then self.bitwidth:=bitwidth;
end;

procedure MSM5205_chip.data_w(data:byte);
begin
if (self.bitwidth=4) then self.data:=data and $f
    else self.data:=(data and $7) shl 1; // unknown
end;

procedure MSM5205_chip.reset_w(reset_data:boolean);
begin
  self.reset_data:=reset_data;
  self.idle:=reset_data;
end;

procedure MSM5205_chip.vclk_w(vclk:boolean);
begin
  if (self.vclk<>vclk) then begin
			self.vclk:=vclk;
			if not(vclk) then self.stream_update;
  end;
end;
end.
