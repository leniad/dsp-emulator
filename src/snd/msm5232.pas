unit msm5232;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}sound_engine,main_engine,timer_engine;

type
      msm5232_voice=record
          mode:byte;
          tg_count_period:integer;
          tg_count:integer;
          tg_cnt:byte;
          tg_out16:byte;
          tg_out8:byte;
          tg_out4:byte;
          tg_out2:byte;
          egvol:integer;
          eg_sect:integer;
          counter:integer;
          eg:integer;
          eg_arm:byte;
          ar_rate:double;
          dr_rate:double;
          rr_rate:double;
          pitch:integer;
          gf:integer;
      end;
      msm5232_chip=class(snd_chip_class)
          constructor create(clock:dword;amp:single=1);
          destructor free;
        public
          procedure reset;
          procedure write(pos,valor:byte);
          procedure set_capacitors(cap1,cap2,cap3,cap4,cap5,cap6,cap7,cap8:single);
          procedure update;
        private
          voice:array[0..7] of msm5232_voice;
          en_out16:array[0..1] of dword;
	        en_out8:array[0..1] of dword;
	        en_out4:array[0..1] of dword;
          en_out2:array[0..1] of dword;
          noise_cnt:integer;
	        noise_step:integer;
          noise_rng:integer;
          noise_clocks:integer;
          updatestep:cardinal;
          ar_tbl:array[0..7] of double;
	        dr_tbl:array[0..15] of double;
          control1:byte;
          control2:byte;
          gate:integer;
          rate:integer;
          external_capacitance:array[0..7] of double;
	        gate_handler_cb:procedure (valor:integer);
          final_buffer:array[0..3] of smallint;
          final_count:byte;
          procedure init_tables;
          procedure init_voice(voice:byte);
          procedure gate_update;
          procedure internal_update;
          procedure eg_voices_advance;
          procedure tg_group_advance(groupidx:byte);
        end;

var
  msm5232_0:msm5232_chip;

implementation
const
  CLOCK_RATE_DIVIDER=16;
  STEP_SH=16;
  R51=870;    // attack resistance
  R52=17400;    // decay 1 resistance
  R53=101000;
  VMIN=0;
  VMAX=32768;
  MSM5232_ROM:array[0..175] of word=(
  506, 7,

  478, 7,451, 7,426, 7,402, 7,
  379, 7,358, 7,338, 7,319, 7,
  301, 7,284, 7,268, 7,253, 7,

  478, 6,451, 6,426, 6,402, 6,
  379, 6,358, 6,338, 6,319, 6,
  301, 6,284, 6,268, 6,253, 6,

  478, 5,451, 5,426, 5,402, 5,
  379, 5,358, 5,338, 5,319, 5,
  301, 5,284, 5,268, 5,253, 5,

  478, 4,451, 4,426, 4,402, 4,
  379, 4,358, 4,338, 4,319, 4,
  301, 4,284, 4,268, 4,253, 4,

  478, 3,451, 3,426, 3,402, 3,
  379, 3,358, 3,338, 3,319, 3,
  301, 3,284, 3,268, 3,253, 3,

  478, 2,451, 2,426, 2,402, 2,
  379, 2,358, 2,338, 2,319, 2,
  301, 2,284, 2,268, 2,253, 2,

  478, 1,451, 1,426, 1,402, 1,
  379, 1,358, 1,338, 1,319, 1,
  301, 1,284, 1,268, 1,253, 1,

  253, 1,253, 1,

  13, 7);
var
  o2,o4,o8,o16,solo8,solo16:integer;
  msm5232_rom_def:array[0..87] of word;

procedure msm5232_update_internal_0;
begin
  msm5232_0.internal_update;
end;

constructor msm5232_chip.create(clock:dword;amp:single=1);
begin
  clock:=clock;
  self.rate:=trunc(clock/CLOCK_RATE_DIVIDER);
  self.amp:=amp;
  self.clock:=clock;
  self.tsample_num:=init_channel;
  timers.init(sound_status.cpu_num,sound_status.cpu_clock/self.rate,msm5232_update_internal_0,nil,true);
end;

destructor msm5232_chip.free;
begin
end;

procedure msm5232_chip.reset;
var
  f:byte;
begin
  for f:=0 to 7 do begin
    self.write(f,$80);
    self.write(f,0);
  end;
  self.noise_cnt:=0;
	self.noise_rng:=1;
	self.noise_clocks:=0;
	self.control1:=0;
	self.en_out16[0]:=0;
	self.en_out8[0]:=0;
	self.en_out4[0]:=0;
	self.en_out2[0]:=0;
	self.control2:=0;
	self.en_out16[1]:=0;
	self.en_out8[1]:=0;
	self.en_out4[1]:=0;
	self.en_out2[1]:=0;
  self.gate_update;
  final_count:=0;
  for f:=0 to 3 do final_buffer[f]:=0;
end;

procedure msm5232_chip.write(pos,valor:byte);
var
  f,ch:byte;
  pg:word;
  n:integer;
begin
case pos of
  0..7:begin  // pitch
          ch:=pos and 7;
          self.voice[ch].gf:=(valor and $80) shr 7;
		      if (ch=7) then self.gate_update;

		      if (valor and $80)<>0 then begin
			      if (valor>=$d8) then begin
				      self.voice[ch].mode:=1;  // noise mode
				      self.voice[ch].eg_sect:=0;  // Key On
			      end else begin
				      if (self.voice[ch].pitch<>(valor and $7f)) then begin
					      self.voice[ch].pitch:=valor and $7f;
					      pg:=msm5232_rom_def[valor and $7f];
					      self.voice[ch].tg_count_period:=(pg and $1ff)*(self.updatestep div 2);

					      n:=(pg shr 9) and 7;  // n = bit number for 16' output
					      self.voice[ch].tg_out16:=1 shl n;
										// for 8' it is bit n-1 (bit 0 if n-1<0)
										// for 4' it is bit n-2 (bit 0 if n-2<0)
										// for 2' it is bit n-3 (bit 0 if n-3<0)
                if n>0 then n:=n-1
                  else n:=0;
					      self.voice[ch].tg_out8:=1 shl n;

                if n>0 then n:=n-1
                  else n:=0;
					      self.voice[ch].tg_out4:=1 shl n;

                if n>0 then n:=n-1
                  else n:=0;
					      self.voice[ch].tg_out2:=1 shl n;
              end;
				      self.voice[ch].mode:=0;     // tone mode
				      self.voice[ch].eg_sect:=0;  // Key On
			      end;
		      end else begin
			      if (self.voice[ch].eg_arm=0) then // arm = 0
				      self.voice[ch].eg_sect:=2  // Key Off -> go to release
			      else                            // arm = 1
				      self.voice[ch].eg_sect:=1;  // Key Off -> go to decay
		      end;
       end;
  8:for f:=0 to 3 do // group1 attack
				self.voice[f].ar_rate:=self.ar_tbl[valor and $7]*self.external_capacitance[f];
  9:for f:=0 to 3 do // group2 attack
				self.voice[f+4].ar_rate:=self.ar_tbl[valor and $7]*self.external_capacitance[f+4];
  $a:for f:=0 to 3 do  // group1 decay
				self.voice[f].dr_rate:=self.dr_tbl[valor and $f]*self.external_capacitance[f];
  $b:for f:=0 to 3 do  // group2 decay
				self.voice[f+4].dr_rate:=self.dr_tbl[valor and $f]*self.external_capacitance[f+4];
  $c:begin  // group1 control
			  self.control1:=valor;

			  for f:=0 to 3 do begin
				  if (((valor and $10)<>0) and (self.voice[f].eg_sect=1)) then self.voice[f].eg_sect:=0;
				  self.voice[f].eg_arm:=valor and $10;
        end;

        if (valor and 1)<>0 then self.en_out16[0]:=$ffffffff
          else self.en_out16[0]:=0;
        if (valor and 2)<>0 then self.en_out8[0]:=$ffffffff
          else self.en_out8[0]:=0;
        if (valor and 4)<>0 then self.en_out4[0]:=$ffffffff
          else self.en_out4[0]:=0;
        if (valor and 8)<>0 then self.en_out2[0]:=$ffffffff
          else self.en_out2[0]:=0;
			end;
		$d:begin  // group2 control
			  self.control2:=valor;
			  self.gate_update;

			for f:=0 to 3 do begin
				if (((valor and $10)<>0) and (self.voice[f+4].eg_sect=1)) then self.voice[f+4].eg_sect:=0;
				self.voice[f+4].eg_arm:=valor and $10;
			end;

			if (valor and 1)<>0 then self.en_out16[1]:=$ffffffff
          else self.en_out16[1]:=0;
        if (valor and 2)<>0 then self.en_out8[1]:=$ffffffff
          else self.en_out8[1]:=0;
        if (valor and 4)<>0 then self.en_out4[1]:=$ffffffff
          else self.en_out4[1]:=0;
        if (valor and 8)<>0 then self.en_out2[1]:=$ffffffff
          else self.en_out2[1]:=0;
      end;
end;
end;

procedure msm5232_chip.set_capacitors(cap1,cap2,cap3,cap4,cap5,cap6,cap7,cap8:single);
var
  f:byte;
begin
	self.external_capacitance[0]:=cap1;
	self.external_capacitance[1]:=cap2;
	self.external_capacitance[2]:=cap3;
	self.external_capacitance[3]:=cap4;
	self.external_capacitance[4]:=cap5;
	self.external_capacitance[5]:=cap6;
	self.external_capacitance[6]:=cap7;
	self.external_capacitance[7]:=cap8;
  self.init_tables;
  for f:=0 to 7 do begin
		fillchar(self.voice[f],0,sizeof(msm5232_voice));
		self.init_voice(f);
  end;
end;

procedure msm5232_chip.update;
var
  final_out:smallint;
  f:byte;
begin
  final_out:=0;
  if self.final_count<>0 then begin
    for f:=0 to (self.final_count-1) do final_out:=final_out+self.final_buffer[f];
    final_out:=final_out div self.final_count;
  end;
  tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc(final_out*self.amp);
  self.final_count:=0;
end;

procedure msm5232_chip.init_tables;
var
  f:byte;
  scale,clockscale:double;
  rcp_duty_cycle:integer;
begin
	// sample rate = chip clock !!!  But :
	// highest possible frequency is chipclock/13/16 (pitch data=0x57)
	// at 2MHz : 2000000/13/16 = 9615 Hz
	self.updatestep:=round((1 shl STEP_SH)*(self.rate/self.clock));

	scale:=self.clock/self.rate;
	self.noise_step:=round(((1 shl STEP_SH)/128)*scale); // step of the rng reg in 16.16 format

  clockscale:=self.clock/2119040;
	for f:=0 to 7 do begin
    if (f and 4)<>0 then rcp_duty_cycle:=1 shl (f and $fd) // bit 1 is ignored if bit 2 is set
      else rcp_duty_cycle:=1 shl f;
		self.ar_tbl[f]:=(rcp_duty_cycle/clockscale)*R51;
	end;

	for f:=0 to 7 do begin
		if (f and 4)<>0 then
    rcp_duty_cycle:=1 shl (f and $fd) // bit 1 is ignored if bit 2 is set
      else rcp_duty_cycle:=1 shl f;
		self.dr_tbl[f]:=(rcp_duty_cycle/clockscale)*R52;
		self.dr_tbl[f+8]:=(rcp_duty_cycle/clockscale)*R53;
	end;
  for f:=0 to 87 do
    msm5232_rom_def[f]:=MSM5232_ROM[f*2] or (MSM5232_ROM[(f*2)+1] shl 9);
end;

procedure msm5232_chip.init_voice(voice:byte);
begin
	self.voice[voice].ar_rate:=self.ar_tbl[0]*self.external_capacitance[voice];
	self.voice[voice].dr_rate:=self.dr_tbl[0]*self.external_capacitance[voice];
	self.voice[voice].rr_rate:=self.dr_tbl[0]*self.external_capacitance[voice]; // this is constant value
	self.voice[voice].eg_sect:=-1;
	self.voice[voice].eg:=0;
	self.voice[voice].eg_arm:=0;
	self.voice[voice].pitch:=-1;
end;

procedure msm5232_chip.gate_update;
var
  new_state:integer;
begin
  if (self.control2 and $20)<>0 then new_state:=self.voice[7].gf
    else new_state:=0;
	if (self.gate<>new_state) then begin
		self.gate:=new_state;
		if @self.gate_handler_cb<>nil then self.gate_handler_cb(new_state);
	end;
end;

procedure msm5232_chip.eg_voices_advance;
var
  f:byte;
  n,samplerate:integer;
begin
	samplerate:=self.rate;
	for f:=7 downto 0 do begin
		case self.voice[f].eg_sect of
		  0:begin // attack
			  // capacitor charge
			  if (self.voice[f].eg<VMAX) then begin
				  self.voice[f].counter:=self.voice[f].counter-round((VMAX-self.voice[f].eg)/self.voice[f].ar_rate);
				  if (self.voice[f].counter<=0) then begin
					  n:=-self.voice[f].counter div (samplerate+1);
					  self.voice[f].counter:=self.voice[f].counter+(n*samplerate);
            self.voice[f].eg:=self.voice[f].eg+n;
					  if (self.voice[f].eg>VMAX) then self.voice[f].eg:=VMAX;
          end;
        end;
			  // when ARM=0, EG switches to decay as soon as cap is charged to VT (EG inversion voltage; about 80% of MAX)
			  if (self.voice[f].eg_arm=0) then begin
			  	if (self.voice[f].eg>=(VMAX*(80/100))) then self.voice[f].eg_sect:=1;
			  end; // when ARM=1, EG stays at maximum until key off
			  self.voice[f].egvol:=self.voice[f].eg div 16; // 32768/16 = 2048 max
        end;
		  1:begin // decay
			  // capacitor discharge
			  if (self.voice[f].eg>VMIN) then begin
				  self.voice[f].counter:=self.voice[f].counter-round((self.voice[f].eg-VMIN)/self.voice[f].dr_rate);
				  if (self.voice[f].counter<=0) then begin
					  n:=-self.voice[f].counter div (samplerate+1);
					  self.voice[f].counter:=self.voice[f].counter+(n*samplerate);
            self.voice[f].eg:=self.voice[f].eg-n;
					  if (self.voice[f].eg<VMIN) then self.voice[f].eg:=VMIN;
          end;
        end	else begin// voi->eg <= VMIN
				  self.voice[f].eg_sect:=-1;
			  end;
			  self.voice[f].egvol:=self.voice[f].eg div 16; //32768/16 = 2048 max
        end;
		  2:begin // release
			  // capacitor discharge
			  if (self.voice[f].eg>VMIN) then begin
				  self.voice[f].counter:=self.voice[f].counter-round((self.voice[f].eg-VMIN)/self.voice[f].rr_rate);
				  if (self.voice[f].counter<=0) then begin
					  n:=-self.voice[f].counter div (samplerate+1);
					  self.voice[f].counter:=self.voice[f].counter+(n*samplerate);
            self.voice[f].eg:=self.voice[f].eg-n;
					  if (self.voice[f].eg<VMIN) then self.voice[f].eg:=VMIN;
          end;
        end else begin // voi->eg <= VMIN
				  self.voice[f].eg_sect:=-1;
        end;
			  self.voice[f].egvol:=self.voice[f].eg div 16; //32768/16 = 2048 max
			  end;
		end; //Del case
  end;
end;

function sshr(num:integer;fac:byte):integer;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

procedure msm5232_chip.tg_group_advance(groupidx:byte);
var
  f:byte;
  out2,out4,out8,out16,left,nextevent:integer;
begin
	//VOICE *voi = &m_voi[groupidx*4];
	o2:=0;
  o4:=0;
  o8:=0;
  o16:=0;
  solo8:=0;
  solo16:=0;

  for f:=0 to 3 do begin
		out2:=0;
    out4:=0;
    out8:=0;
    out16:=0;

		if (self.voice[f+groupidx*4].mode=0) then begin// generate square tone
			left:=1 shl STEP_SH;
			repeat
				nextevent:=left;

				if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out16)<>0 then out16:=out16+self.voice[f+groupidx*4].tg_count;
				if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out8)<>0 then out8:=out8+self.voice[f+groupidx*4].tg_count;
				if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out4)<>0 then out4:=out4+self.voice[f+groupidx*4].tg_count;
				if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out2)<>0 then out2:=out2+self.voice[f+groupidx*4].tg_count;

				self.voice[f+groupidx*4].tg_count:=self.voice[f+groupidx*4].tg_count-nextevent;

				while (self.voice[f+groupidx*4].tg_count<=0) do begin
					self.voice[f+groupidx*4].tg_count:=self.voice[f+groupidx*4].tg_count+self.voice[f+groupidx*4].tg_count_period;
					self.voice[f+groupidx*4].tg_cnt:=self.voice[f+groupidx*4].tg_cnt+1;
					if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out16)<>0 then out16:=out16+self.voice[f+groupidx*4].tg_count_period;
					if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out8)<>0 then out8:=out8+self.voice[f+groupidx*4].tg_count_period;
					if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out4)<>0 then out4:=out4+self.voice[f+groupidx*4].tg_count_period;
					if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out2)<>0 then out2:=out2+self.voice[f+groupidx*4].tg_count_period;

					if (self.voice[f+groupidx*4].tg_count>0) then break;

					self.voice[f+groupidx*4].tg_count:=self.voice[f+groupidx*4].tg_count+self.voice[f+groupidx*4].tg_count_period;
					self.voice[f+groupidx*4].tg_cnt:=self.voice[f+groupidx*4].tg_cnt+1;
					if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out16)<>0 then out16:=out16+self.voice[f+groupidx*4].tg_count_period;
					if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out8)<>0 then out8:=out8+self.voice[f+groupidx*4].tg_count_period;
					if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out4)<>0 then out4:=out4+self.voice[f+groupidx*4].tg_count_period;
					if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out2)<>0 then out2:=out2+self.voice[f+groupidx*4].tg_count_period;
				end;
				if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out16)<>0 then out16:=out16-self.voice[f+groupidx*4].tg_count;
				if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out8)<>0 then out8:=out8-self.voice[f+groupidx*4].tg_count;
				if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out4)<>0 then out4:=out4-self.voice[f+groupidx*4].tg_count;
				if (self.voice[f+groupidx*4].tg_cnt and self.voice[f+groupidx*4].tg_out2)<>0 then out2:=out2-self.voice[f+groupidx*4].tg_count;

				left:=left-nextevent;
			until (left<=0);
    end else begin   // generate noise
			if (self.noise_clocks and 8)<>0 then out16:=out16+(1 shl STEP_SH);
			if (self.noise_clocks and 4)<>0 then out8:=out8+(1 shl STEP_SH);
			if (self.noise_clocks and 2)<>0 then out4:=out4+(1 shl STEP_SH);
			if (self.noise_clocks and 1)<>0 then out2:=out2+(1 shl STEP_SH);
		end;

		// calculate signed output
		o16:=o16+sshr(((out16-(1 shl (STEP_SH-1)))*self.voice[f+groupidx*4].egvol),STEP_SH);
		o8:=o8+sshr(((out8-(1 shl (STEP_SH-1)))*self.voice[f+groupidx*4].egvol),STEP_SH);
		o4:=o4+sshr(((out4-(1 shl (STEP_SH-1)))*self.voice[f+groupidx*4].egvol),STEP_SH);
		o2:=o2+sshr(((out2-(1 shl (STEP_SH-1)))*self.voice[f+groupidx*4].egvol),STEP_SH);

		if ((f=1) and (groupidx=1)) then begin
			solo16:=solo16+sshr(((out16-(1 shl (STEP_SH-1))) shl 11),STEP_SH);
			solo8:=solo8+sshr(((out8-(1 shl (STEP_SH-1))) shl 11),STEP_SH);
		end;
	end; //Del for

	// cut off disabled output lines
	o16:=o16 and self.en_out16[groupidx];
	o8:=o8 and self.en_out8[groupidx];
	o4:=o4 and self.en_out4[groupidx];
	o2:=o4 and self.en_out2[groupidx];
end;

procedure msm5232_chip.internal_update;
var
  outputs:array[0..10] of smallint;
  cnt,tmp,final_out:integer;
  f,divt:byte;
begin
		// calculate all voices' envelopes
		self.eg_voices_advance;
		self.tg_group_advance(0);   // calculate tones group 1
		outputs[0]:=o2;
		outputs[1]:=o4;
		outputs[2]:=o8;
		outputs[3]:=o16;
		self.tg_group_advance(1);   // calculate tones group 2
		outputs[4]:=o2;
		outputs[5]:=o4;
		outputs[6]:=o8;
		outputs[7]:=o16;
		outputs[8]:=solo8;
		outputs[9]:=solo16;
		// update noise generator
    self.noise_cnt:=self.noise_cnt+self.noise_step;
    cnt:=sshr(self.noise_cnt,STEP_SH);
		self.noise_cnt:=self.noise_cnt and ((1 shl STEP_SH)-1);
		while (cnt>0) do begin
				tmp:=self.noise_rng and (1 shl 16); // store current level
				if (self.noise_rng and 1)<>0 then self.noise_rng:=self.noise_rng xor $24000;
				self.noise_rng:=self.noise_rng shr 1;
				if ((self.noise_rng and (1 shl 16))<>tmp) then self.noise_clocks:=self.noise_clocks+1;   // level change detect
				cnt:=cnt-1;
    end;
    if (self.noise_rng and (1 shl 16))<>0 then outputs[10]:=1
      else outputs[10]:=0;
    final_out:=0;
    divt:=0;
    for f:=0 to 10 do begin
      if outputs[f]<>0 then begin
        final_out:=final_out+outputs[f];
        divt:=divt+1;
      end;
    end;
    if divt<>0 then final_out:=final_out div divt;
    if final_out>32768 then final_out:=32768
      else if final_out<-32767 then final_out:=-32767;
    self.final_buffer[self.final_count]:=final_out;
    self.final_count:=(self.final_count+1) mod 4;
end;

end.
