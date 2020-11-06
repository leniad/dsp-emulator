unit k005289;

interface
uses {$IFDEF WINDOWS}windows,{$else}main_engine,{$ENDIF}
     sound_engine,timer_engine;

type
    k005289_snd_chip=class(snd_chip_class)
        constructor create(clock:dword;amp:single=1);
        destructor free;
      public
        sound_prom:array[0..$1ff] of byte;
        procedure reset;
        procedure update;
        procedure control_A_w(valor:byte);
        procedure control_B_w(valor:byte);
        procedure ld1_w(dir:word;valor:byte);
        procedure ld2_w(dir:word;valor:byte);
        procedure tg1_w(valor:byte);
        procedure tg2_w(valor:byte);
      private
        mixer_table:array[0..511] of smallint;
        rate:dword;
        timer:byte;
        counter:array[0..1] of dword;
	      frequency:array[0..1] of word;
	      freq_latch:array[0..1] of word;
	      waveform:array[0..1] of word;
	      volume:array[0..1] of byte;
        buffer:array[0..15] of smallint;
        internal_pos:byte;
        procedure make_mixer_table(voices:byte);
    end;

const
  CLOCK_DIVIDER=32;

var
  k005289_0:k005289_snd_chip;

implementation

procedure k005289_update_internal_0;
var
  v:byte;
  frq:word;
  offs,c:dword;
  sample:smallint;
  chip:k005289_snd_chip;
begin
  chip:=k005289_0;
	v:=chip.volume[0];
	frq:=chip.frequency[0];
  sample:=0;
	if ((v<>0) and (frq<>0)) then begin
		c:=chip.counter[0]+CLOCK_DIVIDER;
    offs:=trunc(c/frq) and $1f;
		sample:=((chip.sound_prom[chip.waveform[0]+offs] and $0f)-8)*v;
		chip.counter[0]:=c mod (frq*$20);
  end;
	v:=chip.volume[1];
	frq:=chip.frequency[1];
	if ((v<>0) and (frq<>0)) then begin
		c:=chip.counter[1]+CLOCK_DIVIDER;
    offs:=trunc(c/frq) and $1f;
		sample:=sample+(((chip.sound_prom[chip.waveform[1]+offs] and $0f)-8)*v);
		chip.counter[1]:=c mod (frq*$20);
	end;
  chip.buffer[chip.internal_pos]:=chip.mixer_table[(128*2)+sample];
  chip.internal_pos:=chip.internal_pos+1;
end;

procedure k005289_snd_chip.make_mixer_table(voices:byte);
var
  f,count:word;
  val:integer;
const
  gain=16;
begin
	count:=voices*128;
	for f:=0 to (count-1) do begin
		val:=trunc(f*gain*16/voices);
		if (val>32767) then val:=32767;
    self.mixer_table[(128*voices)+f]:=val;
    self.mixer_table[(128*voices)-f]:=-val;
	end;
end;

constructor k005289_snd_chip.create(clock:dword;amp:single=1);
begin
  self.amp:=amp;
  self.rate:=clock div CLOCK_DIVIDER;
	self.tsample_num:=init_channel;
	make_mixer_table(2);
	self.reset;
  self.timer:=timers.init(sound_status.cpu_num,sound_status.cpu_clock/self.rate,k005289_update_internal_0,nil,true);
end;

destructor k005289_snd_chip.free;
begin
end;

procedure k005289_snd_chip.reset;
var
  f:byte;
begin
for f:=0 to 1 do begin
		self.counter[f]:=0;
		self.frequency[f]:=0;
		self.freq_latch[f]:=0;
		self.waveform[f]:=f*$100;
		self.volume[f]:=0;
end;
self.internal_pos:=0;
for f:=0 to 15 do self.buffer[f]:=0;
end;

procedure k005289_snd_chip.update;
var
  f:byte;
  sample:integer;
begin
  sample:=0;
  if self.internal_pos<>0 then begin
    for f:=0 to (self.internal_pos-1) do sample:=sample+self.buffer[f];
    sample:=trunc(sample/self.internal_pos);
    self.internal_pos:=0;
    for f:=0 to 15 do self.buffer[f]:=0;
  end;
  tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc(sample*self.amp);
end;

procedure k005289_snd_chip.control_A_w(valor:byte);
begin
	self.volume[0]:=valor and $f;
	self.waveform[0]:=valor and $e0;
end;

procedure k005289_snd_chip.control_B_w(valor:byte);
begin
	self.volume[1]:=valor and $f;
	self.waveform[1]:=(valor and $e0)+$100;
end;

procedure k005289_snd_chip.ld1_w(dir:word;valor:byte);
begin
	self.freq_latch[0]:=$fff-dir;
end;

procedure k005289_snd_chip.ld2_w(dir:word;valor:byte);
begin
	self.freq_latch[1]:=$fff-dir;
end;

procedure k005289_snd_chip.tg1_w(valor:byte);
begin
	self.frequency[0]:=self.freq_latch[0];
end;

procedure k005289_snd_chip.tg2_w(valor:byte);
begin
	self.frequency[1]:=self.freq_latch[1];
end;

end.
