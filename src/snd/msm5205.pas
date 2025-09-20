unit msm5205;

interface
uses math,timer_engine,sound_engine{$ifdef windows},windows{$endif};

const
  MSM5205_S96_3B=0;     // prsicaler 1/96(4KHz) , data 3bit */
  MSM5205_S48_3B=1;     // prsicaler 1/48(8KHz) , data 3bit */
  MSM5205_S64_3B=2;     // prsicaler 1/64(6KHz) , data 3bit */
  MSM5205_SEX_3B=3;     // VCLK slave mode      , data 3bit */
  MSM5205_S96_4B=4;     // prsicaler 1/96(4KHz) , data 4bit */
  MSM5205_S48_4B=5;     // prsicaler 1/48(8KHz) , data 4bit */
  MSM5205_S64_4B=6;     // prsicaler 1/64(6KHz) , data 4bit */
  MSM5205_SEX_4B=7;     // VCLK slave mode      , data 4bit */

type
  MSM5205_chip=class(snd_chip_class)
        constructor create(clock:dword;select:byte;amp:single;snd_timer_call:exec_type_simple);
        destructor free;
      public
        procedure reset;
        procedure reset_w(reset_data:byte);
        procedure data_w(data:byte);
        procedure vclk_w(vclk:byte);
      private
        num:byte;
        clock:dword;				// clock rate
        data:byte;       // next adpcm data
        vclk:byte;       // vclk signal (external mode)
        reset_data:byte;    // reset pin signal
        prescaler:byte;     // prescaler selector S1 and S2
        bitwidth:byte;      // bit width selector -3B/4B
        signal:integer;     // current ADPCM signal
        step:integer;       // current ADPCM step
        select:byte;
        timer_,tsample_:byte;
        amp:single;
        external_call:procedure;
        procedure playmode_w(select:byte);
  end;

var
  msm_5205_0,msm_5205_1:MSM5205_chip;

procedure msm5205_internal_update(index:byte);
procedure msm5205_final_update(index:byte);
procedure msm5205_ComputeTables;
function msm5205_clock(val:integer;var step:integer;signal:integer):integer;

implementation
var
  diff_lookup:array[0..(49*16)-1] of integer;
  chips_total:integer=-1;

const
  index_shift:array[0..7] of integer=(-1, -1, -1, -1, 2, 4, 6, 8);

procedure msm5205_ComputeTables;
// nibble to bit map */
const
  nbl2bit:array[0..15,0..3] of integer= (
		( 1, 0, 0, 0), ( 1, 0, 0, 1), ( 1, 0, 1, 0), ( 1, 0, 1, 1),
		( 1, 1, 0, 0), ( 1, 1, 0, 1), ( 1, 1, 1, 0), ( 1, 1, 1, 1),
		(-1, 0, 0, 0), (-1, 0, 0, 1), (-1, 0, 1, 0), (-1, 0, 1, 1),
		(-1, 1, 0, 0), (-1, 1, 0, 1), (-1, 1, 1, 0), (-1, 1, 1, 1));
var
	step,nib,stepval:integer;
begin
	// loop over all possible steps */
	for step:=0 to 48 do begin
		// compute the step value */
		stepval:=floor(16.0*power(11.0/10.0,step));
		// loop over all nibbles and compute the difference */
		for nib:=0 to 15 do begin
			diff_lookup[step*16 + nib]:= nbl2bit[nib][0] *
				(stepval   * nbl2bit[nib][1] +
				 stepval div 2 * nbl2bit[nib][2] +
				 stepval div 4 * nbl2bit[nib][3] +
				 stepval div 8);
		end;
	end;
end;

constructor MSM5205_chip.Create(clock:dword;select:byte;amp:single;snd_timer_call:exec_type_simple);
begin
  chips_total:=chips_total+1;
  self.prescaler:=$ff;
	self.num:=chips_total;
  self.amp:=amp;
	self.clock:=clock;
  self.select:=select;
  self.tsample_:=init_channel;
  self.external_call:=snd_timer_call;
  self.timer_:=timers.init(sound_status.cpu_num,1,nil,msm5205_internal_update,false,chips_total);
  timers.init(sound_status.cpu_num,sound_status.cpu_clock/FREQ_BASE_AUDIO,nil,msm5205_final_update,true,chips_total);
  if chips_total=0 then msm5205_ComputeTables;
	self.reset;
end;

destructor MSM5205_chip.free;
begin
chips_total:=chips_total-1;
end;

procedure MSM5205_chip.reset;
begin
	// initialize work */
	self.data:=0;
	self.vclk:=0;
	self.reset_data:=0;
	self.signal:=0;
	self.step:=-2;
	// timer and bitwidth set */
	self.playmode_w(self.select);
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
		// timer set */
    if (prescaler<>0) then begin
  			timers.timer[self.timer_].time_final:=sound_status.cpu_clock/(self.clock/prescaler);
        timers.enabled(self.timer_,true);
  		end else timers.enabled(self.timer_,false);
  end;
	if (self.bitwidth<>bitwidth) then self.bitwidth:=bitwidth;
end;

procedure MSM5205_chip.data_w(data:byte);
begin
if (self.bitwidth=4) then self.data:=data and $0f
    else self.data:=(data and $07) shl 1; // unknown */
end;

procedure MSM5205_chip.reset_w(reset_data:byte);
begin
  self.reset_data:=reset_data;
end;

function msm5205_clock(val:integer;var step:integer;signal:integer):integer;
begin
// update signal */
// !! MSM5205 has internal 12bit decoding, signal width is 0 to 8191 !! */
signal:=signal+diff_lookup[step*16+(val and 15)];
if (signal>2047) then signal:=2047
  else if (signal<-2048) then signal:=-2048;
step:=step+index_shift[val and 7];
if (step>48) then step:=48
  else if (step<0) then step:=0;
msm5205_clock:=signal;
end;

procedure msm5205_stream_update(num:byte);
var
  voice:MSM5205_chip;
begin
  case num of
    0:voice:=msm_5205_0;
    1:voice:=msm_5205_1;
  end;
  if @voice.external_call<>nil then voice.external_call;
	// reset check at last hieddge of VCLK */
	if (voice.reset_data<>0) then begin
		voice.signal:=0;
		voice.step:=0;
	end else begin
    voice.signal:=msm5205_clock(voice.data,voice.step,voice.signal);
	end;
end;

procedure MSM5205_chip.vclk_w(vclk:byte);
begin
  if (self.vclk<>vclk) then begin
			self.vclk:=vclk;
			if (vclk=0) then begin
        case self.num of
          0:msm5205_stream_update(0);
          1:msm5205_stream_update(1);
        end;
      end;
  end;
end;

procedure msm5205_internal_update(index:byte);
begin
  case index of
    0:begin
        msm5205_stream_update(0);
        //Slave!!
        if msm_5205_1<>nil then if msm_5205_1.prescaler=0 then msm5205_stream_update(1);
    end;
    1:msm5205_stream_update(1);
  end;
end;

procedure msm5205_final_update(index:byte);
var
  chip:MSM5205_chip;
begin
  case index of
    0:chip:=msm_5205_0;
    1:chip:=msm_5205_1;
  end;
  tsample[chip.tsample_,sound_status.posicion_sonido]:=trunc((chip.signal shl 4)*chip.amp);
  if sound_status.stereo then tsample[chip.tsample_,sound_status.posicion_sonido+1]:=round((chip.signal shl 4)*chip.amp);
end;

end.
