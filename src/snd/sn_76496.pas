unit sn_76496;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,sound_engine,timer_engine,
     dialogs;

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
    	VolTable:array[0..15] of single;	// volume table
    	Registers:array[0..7] of word;	// registers
    	LastRegister:byte;	// last register written
    	Volume:array [0..3] of single;
      Period,Count:array [0..3] of integer;		// volume of voice 0-2 and noise
      Output:array [0..3] of byte;
    	RNG:cardinal;		// noise generator
    	NoiseFB:integer;		// noise feedback mask
      ready_state:byte;
      ready_cb:type_ready_cb;
      chip_num:byte;
      procedure set_gain(gain:integer);
      procedure resample;
 end;

var
  sn_76496_0,sn_76496_1,sn_76496_2,sn_76496_3:sn76496_chip;

implementation
const
     MAX_OUTPUT=$7fff;
     SN_STEP=$10000;
     FB_WNOISE=$14002;
     FB_PNOISE=$8000;
     NG_PRESET=$0f35;
var
  chips_total:integer=-1;

constructor sn76496_chip.create(clock:dword;ready_cb:type_ready_cb=nil;amp:single=1);
begin
  if addr(update_sound_proc)=nil then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!', mtInformation,[mbOk], 0);
  self.amp:=amp;
  self.set_gain(0);
	self.clock:=clock;
  self.tsample_num:=init_channel;
	self.resample;
  self.reset;
  self.ready_cb:=ready_cb;
  chips_total:=chips_total+1;
  self.chip_num:=chips_total;
end;

destructor sn76496_chip.free;
begin
  chips_total:=chips_total-1;
end;

procedure sn76496_chip.change_clock(clock:dword);
begin
  self.clock:=clock;
  self.resample;
end;

function sn76496_chip.save_snapshot(data:pbyte):word;
var
  ptemp:pbyte;
  size_:dword;
begin
  ptemp:=data;
  copymemory(ptemp,@self.UpdateStep,4);
  inc(ptemp,4);size_:=4;
  copymemory(ptemp,@self.VolTable,16*sizeof(single));
  inc(ptemp,16*sizeof(single));size_:=size_+16*sizeof(single);
  copymemory(ptemp,@self.Registers,8*2);
  inc(ptemp,8*2);size_:=size_+8*2;
  copymemory(ptemp,@self.LastRegister,1);
  inc(ptemp);size_:=size_+1;
  copymemory(ptemp,@self.Volume,4*sizeof(single));
  inc(ptemp,4*sizeof(single));size_:=size_+4*sizeof(single);
  copymemory(ptemp,@self.Period,4*4);
  inc(ptemp,4*4);size_:=size_+4*4;
  copymemory(ptemp,@self.Count,4*4);
  inc(ptemp,4*4);size_:=size_+4*4;
  copymemory(ptemp,@self.Output,4);
  inc(ptemp,4);size_:=size_+4;
  copymemory(ptemp,@self.RNG,4);
  inc(ptemp,4);size_:=size_+4;
  copymemory(ptemp,@self.NoiseFB,4);
  inc(ptemp,4);size_:=size_+4;
  save_snapshot:=size_;
end;

procedure sn76496_chip.load_snapshot(data:pbyte);
var
  ptemp:pbyte;
begin
  ptemp:=data;
  copymemory(@self.UpdateStep,ptemp,4);
  inc(ptemp,4);
  copymemory(@self.VolTable,ptemp,16*sizeof(single));
  inc(ptemp,16*sizeof(single));
  copymemory(@self.Registers,ptemp,8*2);
  inc(ptemp,8*2);
  copymemory(@self.LastRegister,ptemp,1);
  inc(ptemp);
  copymemory(@self.Volume,ptemp,4*sizeof(single));
  inc(ptemp,4*sizeof(single));
  copymemory(@self.Period,ptemp,4*4);
  inc(ptemp,4*4);
  copymemory(@self.Count,ptemp,4*4);
  inc(ptemp,4*4);
  copymemory(@self.Output,ptemp,4);
  inc(ptemp,4);
  copymemory(@self.RNG,ptemp,4);
  inc(ptemp,4);
  copymemory(@self.NoiseFB,ptemp,4);
end;

procedure end_ready_0;
begin
  sn_76496_0.ready_state:=ASSERT_LINE;
  sn_76496_0.ready_cb(sn_76496_0.ready_state);
end;

procedure end_ready_1;
begin
  sn_76496_1.ready_state:=ASSERT_LINE;
  sn_76496_1.ready_cb(sn_76496_1.ready_state);
end;

procedure sn76496_chip.write(data:byte);
var
  r,c,n:integer;
begin
	// update the output buffer before changing the registers
  //SN76496update(num);
	if (data and $80)<>0 then begin
		r:=(data and $70) shr 4;
		c:=r div 2;
		self.LastRegister:=r;
		self.Registers[r]:=(self.Registers[r] and $3f0) or (data and $0f);
		case r of
			0,2,4:begin	// tone 0 : frequency,tone 1 : frequency,tone 2 : frequency */
				      self.Period[c]:=self.UpdateStep*self.Registers[r];
				      if (self.Period[c]=0) then self.Period[c]:=self.UpdateStep;
				      if (r=4) then begin //update noise shift frequency */
					      if ((self.Registers[6] and $03)=$03) then self.Period[3]:=self.Period[2]*2;
              end;
            end;
			1,3,5,7:begin	// tone 0 : volume,tone 1 : volume,tone 2 : volume,noise  : volume */
				        self.Volume[c]:=self.VolTable[data and $0f];
              end;
			6:begin	// noise  : frequency, mode */
					n:=self.Registers[6];
					if (n and 4)<>0 then self.NoiseFB:=FB_WNOISE
            else self.NoiseFB:=FB_PNOISE;
					n:=n and 3;
					//* N/512,N/1024,N/2048,Tone #3 output */
          if ((n and 3)=3) then self.Period[3]:=self.Period[2]*2
            else self.Period[3]:=self.UpdateStep shl (5+(n and 3));
					// reset noise shifter */
					self.RNG:=NG_PRESET;
					self.Output[3]:=self.RNG and 1;
        end;
    end; //del case
	end else begin  //del if
		r:=self.LastRegister;
    c:=r div 2;
		case r of
			0,2,4:begin	// tone 0 : frequency,tone 1 : frequency,tone 2 : frequency */
				      self.Registers[r]:= (self.Registers[r] and $0f) or ((data and $3f) shl 4);
				      self.Period[c]:=self.UpdateStep*self.Registers[r];
				      if (self.Period[c]=0) then self.Period[c]:=self.UpdateStep;
				      if (r=4) then begin // update noise shift frequency */
					        if ((self.Registers[6] and $03) = $03) then self.Period[3]:=self.Period[2]*2;
				      end;
            end;
      1,3,5,7:begin	//* tone 0 : volume,tone 1 : volume,tone 2 : volume,noise  : volume */
				        self.volume[c]:= self.VolTable[data and $0f];
				        self.Registers[r]:=(self.Registers[r] and $3f0) or (data and $0f);
              end;
			6:begin	// noise  : frequency, mode */
					self.Registers[r]:= (self.Registers[r] and $3f0) or (data and $0f);
					n:= self.Registers[6];
					if (n and 4)<>0 then self.NoiseFB:=FB_WNOISE
            else self.NoiseFB:=FB_PNOISE;
					n:=n and 3;
					// N/512,N/1024,N/2048,Tone #3 output */
					if ((n and 3)=3) then self.Period[3]:=2 * self.Period[2]
            else self.Period[3]:=self.UpdateStep shl (5+(n and 3));
					// reset noise shifter */
					self.RNG:=NG_PRESET;
					self.Output[3]:= self.RNG and 1;
				end;
    end;  //del case
	end;
  self.ready_state:=CLEAR_LINE;
	if @self.ready_cb<>nil then begin
    self.ready_cb(self.ready_state);
    //(clock()/(4*m_clock_divider))); clockdivider=8;
    case self.chip_num of
      0:one_shot_timer_0(sound_status.cpu_num,sound_status.cpu_clock/(self.clock/(4*8)),end_ready_0);
      1:one_shot_timer_1(sound_status.cpu_num,sound_status.cpu_clock/(self.clock/(4*8)),end_ready_1);
    end;
  end;

end;

procedure sn76496_chip.set_gain(gain:integer);
var
  i:integer;
  out_sn:single;
begin
	// increase max output basing on gain (0.2 dB per step) */
	out_sn:=MAX_OUTPUT/3;
	while (gain> 0) do begin
    gain:=gain-1;
		out_sn:=out_sn*1.023292992;	// = (10 ^ (0.2/20)) */
  end;
  // build volume table (2dB per step) */
  for i:=0 to 14 do begin
    // limit volume to avoid clipping */
    if (out_sn>(MAX_OUTPUT/3)) then self.VolTable[i]:=MAX_OUTPUT/3
      else self.VolTable[i]:=out_sn;
    out_sn:=out_sn/1.258925412;	// = 10 ^ (2/20) = 2dB */
  end;
  self.VolTable[15]:=0;
end;

procedure sn76496_chip.reset;
var
  i:byte;
begin
for i:=0 to 3 do self.Volume[i]:=0;
self.LastRegister:= 0;
for i:=0 to 3 do begin
  self.Registers[i*2]:=0;
  self.Registers[(i*2) + 1]:=$0f;	// volume = 0 */
end;
for i:=0 to 3 do begin
  self.Output[i]:=0;
  self.Period[i]:=self.UpdateStep;
  self.Count[i]:=self.UpdateStep;
end;
self.RNG:=NG_PRESET;
self.Output[3]:=self.RNG and 1;
self.ready_state:=ASSERT_LINE;
if @self.ready_cb<>nil then self.ready_cb(self.ready_state);
end;

procedure sn76496_chip.resample;
var
  tmp:uint64;
begin
	{ the base clock for the tone generators is the self clock divided by 16
	for the noise generator, it is clock / 256.
	Here we calculate the number of steps which happen during one sample
	at the given sample rate. No. of events = sample rate / (clock/16).
	STEP is a multiplier used to turn the fraction into a fixed point
	number. }
  tmp:=SN_STEP*16;
  tmp:=tmp*FREQ_BASE_AUDIO;
  self.UpdateStep:=round(tmp/self.clock);
end;

procedure sn76496_chip.update;
Var
  i,left,nextevent:Integer;
  out_sn:single;
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
				if (self.RNG and 1)<>0 then self.RNG:=self.RNG xor self.NoiseFB;
				self.RNG:=self.RNG shr 1;
				self.Output[3]:=self.RNG and 1;
				inc(self.Count[3],self.Period[3]);
				if (self.Output[3])<>0 then inc(vol[3],self.Period[3]);
			end;
			if (self.Output[3])<>0 then dec(vol[3],self.Count[3]);
			dec(left,nextevent);
    until (left=0);
		out_sn:= vol[0] * self.Volume[0] + vol[1] * self.Volume[1] +
				vol[2] * self.Volume[2] + vol[3] * self.Volume[3];
    if (out_sn>MAX_OUTPUT*SN_STEP) then out_sn:=MAX_OUTPUT*SN_STEP;
    tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc((out_sn/SN_STEP)*self.amp);
    if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=trunc((out_sn/SN_STEP)*self.amp);
end;

end.
