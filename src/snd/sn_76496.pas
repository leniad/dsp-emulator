unit sn_76496;

interface
uses {$IFDEF WINDOWS}windows,{$else}main_engine,{$ENDIF}sound_engine;

type

 SN76496_chip=class(snd_chip_class)
      constructor Create(clock:dword;amp:single=1);
      destructor free;
    public
      procedure Write(data:byte);
      procedure update;
      procedure reset;
      function save_snapshot(data:pbyte):word;
      procedure load_snapshot(data:pbyte);
    private
    	UpdateStep:dword;
    	VolTable:array[0..15] of integer;	// volume table
    	Registers:array[0..7] of integer;	// registers
    	LastRegister:byte;	// last register written
    	Volume,Period,Count:array [0..3] of integer;		// volume of voice 0-2 and noise
      Output:array [0..3] of byte;
    	RNG:cardinal;		// noise generator      */
    	NoiseFB:integer;		// noise feedback mask */
      procedure set_gain(gain:integer);
      procedure resample;
 end;

var
  sn_76496_0,sn_76496_1,sn_76496_2,sn_76496_3:sn76496_chip;

implementation
const
     REGS_SIZE=161;
     MAX_OUTPUT=$7fff;
     SN_STEP=$10000;
     FB_WNOISE=$14002;
     FB_PNOISE=$8000;
     NG_PRESET=$0f35;

constructor sn76496_chip.Create(clock:dword;amp:single=1);
begin
  self.amp:=amp;
  self.set_gain(0);
	self.clock:=clock;
  self.tsample_num:=init_channel;
	self.resample;
  self.reset;
end;

destructor sn76496_chip.free;
begin
end;

type
    tsn76496=packed record
        UpdateStep:dword;
        VolTable:array[0..15] of integer;
        Registers:array[0..7] of integer;
        LastRegister:byte;
        Volume,Period,Count:array [0..3] of integer;
        Output:array [0..3] of byte;
        RNG:cardinal;
        NoiseFB:integer;
    end;

function sn76496_chip.save_snapshot(data:pbyte):word;
var
  sn76496:^tsn76496;
begin
  getmem(sn76496,sizeof(tsn76496));
  sn76496.UpdateStep:=self.UpdateStep;
  copymemory(@sn76496.VolTable,@self.VolTable,16*4);
  copymemory(@sn76496.Registers,@self.Registers,8*4);
  sn76496.LastRegister:=self.LastRegister;
  copymemory(@sn76496.Volume,@self.Volume,4*4);
  copymemory(@sn76496.Period,@self.Period,4*4);
  copymemory(@sn76496.Count,@self.Count,4*4);
  copymemory(@sn76496.Output,@self.Output,4);
  sn76496.RNG:=self.RNG;
  sn76496.NoiseFB:=self.NoiseFB;
  copymemory(data,sn76496,REGS_SIZE);
  freemem(sn76496);
  save_snapshot:=REGS_SIZE;
end;

procedure sn76496_chip.load_snapshot(data:pbyte);
var
  sn76496:^tsn76496;
begin
  getmem(sn76496,sizeof(tsn76496));
  copymemory(sn76496,data,REGS_SIZE);
  self.UpdateStep:=sn76496.UpdateStep;
  copymemory(@self.VolTable,@sn76496.VolTable,16*4);
  copymemory(@self.Registers,@sn76496.Registers,8*4);
  self.LastRegister:=sn76496.LastRegister;
  copymemory(@self.Volume,@sn76496.Volume,4*4);
  copymemory(@self.Period,@sn76496.Period,4*4);
  copymemory(@self.Count,@sn76496.Count,4*4);
  copymemory(@self.Output,@sn76496.Output,4);
  self.RNG:=sn76496.RNG;
  self.NoiseFB:=sn76496.NoiseFB;
  freemem(sn76496);
end;

procedure sn76496_chip.Write(data:byte);
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
    if (out_sn>(MAX_OUTPUT/3)) then self.VolTable[i]:=round(MAX_OUTPUT/3)
      else self.VolTable[i]:=round(out_sn);
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
  tmp:=tmp*freq_base_audio;
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
end;

end.
