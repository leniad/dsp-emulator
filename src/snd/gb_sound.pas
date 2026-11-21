unit gb_sound;

interface
uses main_engine,sound_engine;

const
  MAX_FREQUENCIES=2048;

type
  tipo_sound=record
  	// Common
  	on_:boolean;
  	channel:byte;
  	length:word;
  	pos:dword;
  	period:dword;
  	count:integer;
  	mode:boolean;
  	// Mode 1, 2, 3
  	duty:shortint;
  	// Mode 1, 2, 4
  	env_value:integer;
    env_direction:shortint;
  	env_length:word;
  	env_count:integer;
  	signal:shortint;
  	// Mode 1
  	frequency:dword;
  	swp_shift:integer;
  	swp_direction:integer;
  	swp_time:word;
  	swp_count:integer;
  	// Mode 3
  	level:byte;
  	offset:byte;
  	dutycount:dword;
  	// Mode 4
  	ply_step:boolean;
  	ply_value:dword;
  end;
  tipo_soundc=record
	  on_:boolean;
  	vol_left:byte;
  	vol_right:byte;
  	mode_left:array[1..4] of boolean;
  	mode_right:array[1..4] of boolean;
  end;

  gb_sound_chip=class(snd_chip_class)
      constructor create;
      destructor free;
  public
    procedure reset;
    procedure update;
    function sound_r(offset:byte):byte;
    procedure sound_w(offset,valor:byte);
    function wave_r(offset:byte):byte;
    procedure wave_w(offset,valor:byte);
    function save_snapshot(datos:pbyte):word;
    procedure load_snapshot(datos:pbyte);
  private
    channel:array[1..4] of tipo_sound;
  	control:tipo_soundc;
    regs:array[0..$2f] of byte;
    timer:array[1..4] of integer;
    env_running:array[1..4] of boolean;
    sweep_shadow:integer;
    sweep_enabled,sweep_neg_used,cgb_mode:boolean;
    frame_step:byte;
    frame_remaining:integer;
    sample_fraction:dword;
    wave_sample,wave_window:byte;
    capacitor_left,capacitor_right,hpf_factor:double;
    procedure w_internal(offset,valor:byte);
    function dac_enabled(ch:integer):boolean;
    function timer_period(ch:integer):integer;
    procedure tick_length(ch:integer);
    procedure tick_frame;
    function sweep_calculate:integer;
    procedure tick_sweep;
    procedure trigger(ch:integer);
    procedure channel_control(ch:integer;valor:byte);
    procedure advance_cycles(cycles:integer;var area_left,area_right:int64);
    procedure mix(var left,right:integer);
    procedure power_off;
  public
    procedure set_cgb_mode(enabled:boolean);
    procedure div_reset(apu_bit_was_high:boolean);
  end;

var
  gb_snd_0:gb_sound_chip;

implementation
uses Math;

const
  NR10=$00; NR11=$01; NR12=$02; NR13=$03; NR14=$04;
  NR21=$06; NR22=$07; NR23=$08; NR24=$09;
  NR30=$0a; NR31=$0b; NR32=$0c; NR33=$0d; NR34=$0e;
  NR41=$10; NR42=$11; NR43=$12; NR44=$13;
  NR50=$14; NR51=$15; NR52=$16; AUD3W0=$20;
  APU_CLOCK=4194304;
  DUTY_BITS:array[0..3] of byte=($80,$81,$e1,$7e);
  NOISE_DIV:array[0..7] of integer=(8,16,32,48,64,80,96,112);
  LENGTH_REG:array[1..4] of byte=(NR11,NR21,NR31,NR41);
  ENV_REG:array[1..4] of byte=(NR12,NR22,NR32,NR42);
  CTRL_REG:array[1..4] of byte=(NR14,NR24,NR34,NR44);
  READ_MASK:array[0..$2f] of byte=(
    $80,$3f,$00,$ff,$bf,$ff,$3f,$00,$ff,$bf,$7f,$ff,$9f,$ff,$bf,$ff,
    $ff,$00,$00,$bf,$00,$00,$70,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,$ff,
    $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00);

constructor gb_sound_chip.create;
begin
  self.tsample_num:=init_channel;
  self.cgb_mode:=false;
  self.reset;
end;

destructor gb_sound_chip.free;
begin

end;

procedure gb_sound_chip.set_cgb_mode(enabled:boolean);
begin
  self.cgb_mode:=enabled;
  if enabled then self.hpf_factor:=Power(0.998943,APU_CLOCK/FREQ_BASE_AUDIO)
    else self.hpf_factor:=Power(0.999958,APU_CLOCK/FREQ_BASE_AUDIO);
  self.capacitor_left:=0;
  self.capacitor_right:=0;
end;

procedure gb_sound_chip.reset;
begin
  FillChar(self.channel,SizeOf(self.channel),0);
  FillChar(self.control,SizeOf(self.control),0);
  FillChar(self.regs,SizeOf(self.regs),0);
  FillChar(self.timer,SizeOf(self.timer),0);
  FillChar(self.env_running,SizeOf(self.env_running),0);
  self.channel[1].swp_direction:=1;
  self.sweep_shadow:=0;
  self.sweep_enabled:=false;
  self.sweep_neg_used:=false;
  self.frame_step:=0;
  self.frame_remaining:=8192;
  self.sample_fraction:=0;
  self.wave_sample:=0;
  self.wave_window:=0;
  self.set_cgb_mode(self.cgb_mode);
end;

function gb_sound_chip.dac_enabled(ch:integer):boolean;
begin
  if ch=3 then Result:=(self.regs[NR30] and $80)<>0
    else Result:=(self.regs[ENV_REG[ch]] and $f8)<>0;
end;

function gb_sound_chip.timer_period(ch:integer):integer;
var f:integer;
begin
  if ch=4 then begin
    Result:=NOISE_DIV[self.regs[NR43] and 7] shl (self.regs[NR43] shr 4);
    exit;
  end;
  f:=((self.regs[CTRL_REG[ch]] and 7) shl 8) or self.regs[CTRL_REG[ch]-1];
  if ch=3 then Result:=(2048-f)*2 else Result:=(2048-f)*4;
end;

procedure gb_sound_chip.tick_length(ch:integer);
begin
  if self.channel[ch].mode and (self.channel[ch].length>0) then begin
    dec(self.channel[ch].length);
    if self.channel[ch].length=0 then self.channel[ch].on_:=false;
  end;
end;

function gb_sound_chip.sweep_calculate:integer;
var
  delta:integer;
begin
  delta:=self.sweep_shadow shr self.channel[1].swp_shift;
  if self.channel[1].swp_direction<0 then begin
    Result:=self.sweep_shadow-delta;
    self.sweep_neg_used:=true;
  end else Result:=self.sweep_shadow+delta;
  if Result>2047 then self.channel[1].on_:=false;
end;

procedure gb_sound_chip.tick_sweep;
var
  f:integer;
begin
  Dec(self.channel[1].swp_count);
  if self.channel[1].swp_count>0 then exit;
  self.channel[1].swp_count:=self.channel[1].swp_time;
  if self.channel[1].swp_count=0 then self.channel[1].swp_count:=8;
  if (not self.sweep_enabled) or (self.channel[1].swp_time=0) then exit;
  f:=self.sweep_calculate;
  if (f<=2047) and (self.channel[1].swp_shift>0) then begin
    self.sweep_shadow:=f;
    self.channel[1].frequency:=f;
    self.regs[NR13]:=byte(f and $ff);
    self.regs[NR14]:=(self.regs[NR14] and $f8) or byte(f shr 8);
    // Frequency changes affect the next timer reload, not the current countdown.
    f:=self.sweep_calculate;
  end;
end;

procedure gb_sound_chip.tick_frame;
var
  ch,v:integer;
begin
  if (self.frame_step and 1)=0 then for ch:=1 to 4 do self.tick_length(ch);
  if (self.frame_step=2) or (self.frame_step=6) then self.tick_sweep;
  if self.frame_step=7 then begin
    for ch:=1 to 4 do begin
      if (ch=3) or (not self.env_running[ch]) then continue;
      Dec(self.channel[ch].env_count);
      if self.channel[ch].env_count>0 then continue;
      self.channel[ch].env_count:=self.channel[ch].env_length;
      if self.channel[ch].env_count=0 then self.channel[ch].env_count:=8;
      if self.channel[ch].env_length=0 then continue;
      v:=self.channel[ch].env_value+self.channel[ch].env_direction;
      if (v<0) or (v>15) then self.env_running[ch]:=false
        else self.channel[ch].env_value:=v;
    end;
  end;
  self.frame_step:=(self.frame_step+1) and 7;
end;

procedure gb_sound_chip.div_reset(apu_bit_was_high:boolean);
begin
  if self.control.on_ and apu_bit_was_high then self.tick_frame;
  self.frame_remaining:=8192;
end;

procedure gb_sound_chip.trigger(ch:integer);
var
  v,f:integer;
begin
  self.channel[ch].on_:=self.dac_enabled(ch);
  if self.channel[ch].length=0 then begin
    if ch=3 then self.channel[ch].length:=256
      else self.channel[ch].length:=64;
    if self.channel[ch].mode and ((self.frame_step and 1)<>0) then dec(self.channel[ch].length);
  end;
  self.timer[ch]:=self.timer_period(ch);
  if ch<>3 then begin
    v:=self.regs[ENV_REG[ch]];
    self.channel[ch].env_value:=v shr 4;
    self.channel[ch].env_length:=v and 7;
    self.channel[ch].env_count:=v and 7;
    if self.channel[ch].env_count=0 then self.channel[ch].env_count:=8;
    self.env_running[ch]:=true;
  end;
  if ch=1 then begin
    self.sweep_shadow:=((self.regs[NR14] and 7) shl 8) or self.regs[NR13];
    self.channel[1].frequency:=self.sweep_shadow;
    self.channel[1].swp_count:=self.channel[1].swp_time;
    if self.channel[1].swp_count=0 then self.channel[1].swp_count:=8;
    self.sweep_enabled:=(self.channel[1].swp_time<>0) or (self.channel[1].swp_shift<>0);
    self.sweep_neg_used:=false;
    if self.channel[1].swp_shift<>0 then f:=self.sweep_calculate;
  end;
  if ch=3 then begin
    self.channel[3].offset:=0;
    self.wave_sample:=0;
    self.wave_window:=0;
    Inc(self.timer[3],6);
  end;
  if ch=4 then self.channel[4].ply_value:=$7fff;
end;

procedure gb_sound_chip.channel_control(ch:integer;valor:byte);
var
  old_mode:boolean;
begin
  old_mode:=self.channel[ch].mode;
  self.channel[ch].mode:=(valor and $40)<>0;
  if (not old_mode) and self.channel[ch].mode and ((self.frame_step and 1)<>0) then self.tick_length(ch);
  if (valor and $80)<>0 then self.trigger(ch);
end;

procedure gb_sound_chip.power_off;
var
  ch:integer;
  keep_length:array[1..4] of word;
begin
  for ch:=1 to 4 do keep_length[ch]:=self.channel[ch].length;
  FillChar(self.channel,SizeOf(self.channel),0);
  FillChar(self.control,SizeOf(self.control),0);
  FillChar(self.timer,SizeOf(self.timer),0);
  FillChar(self.env_running,SizeOf(self.env_running),0);
  // Power off preserves Wave RAM. DMG also preserves length counters.
  for ch:=0 to NR52 do self.regs[ch]:=0;
  if not self.cgb_mode then for ch:=1 to 4 do self.channel[ch].length:=keep_length[ch];
  self.sweep_enabled:=false;
  self.sweep_neg_used:=false;
  self.channel[1].swp_direction:=1;
  self.sweep_shadow:=0;
  self.wave_sample:=0;
  self.wave_window:=0;
  self.frame_step:=0;
end;

function gb_sound_chip.wave_r(offset:byte):byte;
begin
  if offset>15 then begin Result:=$ff; exit; end;
  if self.channel[3].on_ then begin
    if (not self.cgb_mode) and (self.wave_window=0) then begin
      Result:=$ff; exit;
    end;
    offset:=self.channel[3].offset shr 1;
  end;
  Result:=self.regs[AUD3W0+offset];
end;

procedure gb_sound_chip.wave_w(offset,valor:byte);
begin
  if offset>15 then exit;
  if self.channel[3].on_ then begin
    if (not self.cgb_mode) and (self.wave_window=0) then exit;
    offset:=self.channel[3].offset shr 1;
  end;
  self.regs[AUD3W0+offset]:=valor;
end;

function gb_sound_chip.sound_r(offset:byte):byte;
var
  ch:integer;
begin
  if offset>$2f then begin
    result:=$ff;
    exit;
  end;
  if offset>=AUD3W0 then begin
    result:=self.wave_r(offset-AUD3W0);
    exit;
  end;
  if offset=NR52 then begin
    Result:=$70 or (byte(self.control.on_) shl 7);
    for ch:=1 to 4 do if self.channel[ch].on_ then Result:=Result or (1 shl (ch-1));
  end else Result:=self.regs[offset] or READ_MASK[offset];
end;

procedure gb_sound_chip.sound_w(offset,valor:byte);
var
  ch:integer;
begin
  if offset>$2f then exit;
  if offset>=AUD3W0 then begin
    self.wave_w(offset-AUD3W0,valor);
    exit;
  end;
  if (offset>NR52) or (offset=$05) or (offset=$0f) then exit;
  if (not self.control.on_) and (offset<>NR52) then begin
    if not self.cgb_mode then
      for ch:=1 to 4 do
        if offset=LENGTH_REG[ch] then begin
          if ch=3 then self.channel[ch].length:=256-valor
            else self.channel[ch].length:=64-(valor and $3f);
        end;
    exit;
  end;
  self.w_internal(offset,valor);
end;

procedure gb_sound_chip.w_internal(offset,valor:byte);
var
  ch,old:integer;
begin
  old:=self.regs[offset];
  if offset=NR52 then begin
    if (valor and $80)=0 then begin
      self.power_off;
      exit;
    end;
    if not self.control.on_ then self.frame_step:=0;
    self.control.on_:=true;
    self.regs[NR52]:=$80;
    exit;
  end;
  self.regs[offset]:=valor;
  case offset of
    NR10:begin
      self.channel[1].swp_shift:=valor and 7;
      if (valor and 8)<>0 then self.channel[1].swp_direction:=-1
        else self.channel[1].swp_direction:=1;
      self.channel[1].swp_time:=(valor shr 4) and 7;
      if ((old and 8)<>0) and ((valor and 8)=0) and self.sweep_neg_used then
        self.channel[1].on_:=false;
    end;
    NR11,NR21,NR31,NR41:begin
      if offset=NR11 then ch:=1 else if offset=NR21 then ch:=2
        else if offset=NR31 then ch:=3 else ch:=4;
      if ch=3 then self.channel[ch].length:=256-valor
        else self.channel[ch].length:=64-(valor and $3f);
      if ch<=2 then self.channel[ch].duty:=valor shr 6;
    end;
    NR12,NR22,NR42:begin
      if offset=NR12 then ch:=1 else if offset=NR22 then ch:=2 else ch:=4;
      if (valor and 8)<>0 then self.channel[ch].env_direction:=1
        else self.channel[ch].env_direction:=-1;
      self.channel[ch].env_length:=valor and 7;
      if not self.dac_enabled(ch) then self.channel[ch].on_:=false;
    end;
    NR14:self.channel_control(1,valor);
    NR24:self.channel_control(2,valor);
    NR30:if not self.dac_enabled(3) then self.channel[3].on_:=false;
    NR32:self.channel[3].level:=(valor shr 5) and 3;
    NR34:self.channel_control(3,valor);
    NR43:self.channel[4].ply_step:=(valor and 8)<>0;
    NR44:self.channel_control(4,valor);
    NR50:begin
      self.control.vol_left:=(valor shr 4) and 7;
      self.control.vol_right:=valor and 7;
    end;
    NR51:for ch:=1 to 4 do begin
      self.control.mode_left[ch]:=(valor and (1 shl (ch+3)))<>0;
      self.control.mode_right[ch]:=(valor and (1 shl (ch-1)))<>0;
    end;
  end;
end;

procedure gb_sound_chip.mix(var left,right:integer);
var
  ch,digital,s:integer;
begin
  left:=0; right:=0;
  if not self.control.on_ then exit;
  for ch:=1 to 4 do begin
    if not self.dac_enabled(ch) then continue;
    digital:=0;
    if self.channel[ch].on_ then
      case ch of
        1,2:digital:=((DUTY_BITS[self.channel[ch].duty] shr
                     (self.channel[ch].pos and 7)) and 1)*self.channel[ch].env_value;
        3:if self.channel[3].level<>0 then
            digital:=self.wave_sample shr (self.channel[3].level-1);
        4:digital:=integer((not self.channel[4].ply_value) and 1)*
                   self.channel[4].env_value;
      end;
    s:=15-2*digital;
    if self.control.mode_left[ch] then Inc(left,s);
    if self.control.mode_right[ch] then Inc(right,s);
  end;
  left:=left*(integer(self.control.vol_left)+1);
  right:=right*(integer(self.control.vol_right)+1);
end;

procedure gb_sound_chip.advance_cycles(cycles:integer;var area_left,area_right:int64);
var
  step,ch,left,right,feedback,v:integer;
begin
  while cycles>0 do begin
    step:=cycles;
    if self.frame_remaining<step then step:=self.frame_remaining;
    if self.control.on_ then
      for ch:=1 to 4 do
        if self.channel[ch].on_ and (self.timer[ch]<step) then step:=self.timer[ch];
    self.mix(left,right);
    area_left:=area_left+int64(left)*step;
    area_right:=area_right+int64(right)*step;
    Dec(cycles,step);
    Dec(self.frame_remaining,step);
    if self.wave_window>step then Dec(self.wave_window,step)
      else self.wave_window:=0;
    if self.control.on_ then begin
      for ch:=1 to 4 do if self.channel[ch].on_ then begin
        Dec(self.timer[ch],step);
        if self.timer[ch]=0 then begin
          self.timer[ch]:=self.timer_period(ch);
          case ch of
            1,2:self.channel[ch].pos:=(self.channel[ch].pos+1) and 7;
            3:begin
              self.channel[3].offset:=(self.channel[3].offset+1) and 31;
              v:=self.regs[AUD3W0+(self.channel[3].offset shr 1)];
              if (self.channel[3].offset and 1)=0 then v:=v shr 4;
              self.wave_sample:=v and 15;
              self.wave_window:=2;
            end;
            4:begin
              feedback:=((self.channel[4].ply_value shr 1) xor self.channel[4].ply_value) and 1;
              self.channel[4].ply_value:=(self.channel[4].ply_value shr 1) or (dword(feedback) shl 14);
              if self.channel[4].ply_step then
                self.channel[4].ply_value:=(self.channel[4].ply_value and $7fbf) or (dword(feedback) shl 6);
            end;
          end;
        end;
      end;
    end;
    if self.frame_remaining=0 then begin
      self.frame_remaining:=8192;
      if self.control.on_ then self.tick_frame;
    end;
  end;
end;

procedure gb_sound_chip.update;
var
  cycles,left,right:integer;
  area_left,area_right:int64;
  x,y:double;
begin
  self.sample_fraction:=self.sample_fraction+APU_CLOCK;
  cycles:=self.sample_fraction div FREQ_BASE_AUDIO;
  self.sample_fraction:=self.sample_fraction mod FREQ_BASE_AUDIO;
  area_left:=0; area_right:=0;
  self.advance_cycles(cycles,area_left,area_right);
  left:=0; right:=0;
  if cycles>0 then begin
    x:=area_left/cycles;
    y:=area_right/cycles;
    if self.dac_enabled(1) or self.dac_enabled(2) or self.dac_enabled(3) or self.dac_enabled(4) then begin
      x:=x-self.capacitor_left;
      y:=y-self.capacitor_right;
      self.capacitor_left:=area_left/cycles-x*self.hpf_factor;
      self.capacitor_right:=area_right/cycles-y*self.hpf_factor;
      left:=Round(x*48);
      right:=Round(y*48);
    end;
  end;
  if left>32767 then left:=32767
    else if left<-32768 then left:=-32768;
  if right>32767 then right:=32767
    else if right< -32768 then right:=-32768;
  tsample[self.tsample_num,sound_status.posicion_sonido]:=left;
  tsample[self.tsample_num,sound_status.posicion_sonido+1]:=right;
end;

function gb_sound_chip.save_snapshot(datos:pbyte):word;
var
  p:pbyte;
procedure put(src:pointer; n:integer);
begin
  CopyMemory(p,src,n);
  Inc(p,n);
end;
begin
  p:=datos;
  put(@self.channel,SizeOf(self.channel)); put(@self.control,SizeOf(self.control));
  put(@self.regs,SizeOf(self.regs)); put(@self.timer,SizeOf(self.timer));
  put(@self.env_running,SizeOf(self.env_running));
  put(@self.sweep_shadow,SizeOf(self.sweep_shadow));
  put(@self.sweep_enabled,SizeOf(self.sweep_enabled));
  put(@self.sweep_neg_used,SizeOf(self.sweep_neg_used));
  put(@self.cgb_mode,SizeOf(self.cgb_mode));
  put(@self.frame_step,SizeOf(self.frame_step));
  put(@self.frame_remaining,SizeOf(self.frame_remaining));
  put(@self.sample_fraction,SizeOf(self.sample_fraction));
  put(@self.wave_sample,SizeOf(self.wave_sample));
  put(@self.wave_window,SizeOf(self.wave_window));
  put(@self.capacitor_left,SizeOf(self.capacitor_left));
  put(@self.capacitor_right,SizeOf(self.capacitor_right));
  Result:=6+SizeOf(self.channel)+SizeOf(self.control)+SizeOf(self.regs)+
    SizeOf(self.timer)+SizeOf(self.env_running)+SizeOf(self.sweep_shadow)+
    3*SizeOf(boolean)+SizeOf(self.frame_step)+SizeOf(self.frame_remaining)+
    SizeOf(self.sample_fraction)+2*SizeOf(byte)+2*SizeOf(double);
end;

procedure gb_sound_chip.load_snapshot(datos:pbyte);
var p:pbyte;
procedure get(dst:pointer; n:integer);
begin
  CopyMemory(dst,p,n);
  Inc(p,n);
end;
begin
  p:=datos;
  get(@self.channel,SizeOf(self.channel)); get(@self.control,SizeOf(self.control));
  get(@self.regs,SizeOf(self.regs)); get(@self.timer,SizeOf(self.timer));
  get(@self.env_running,SizeOf(self.env_running));
  get(@self.sweep_shadow,SizeOf(self.sweep_shadow));
  get(@self.sweep_enabled,SizeOf(self.sweep_enabled));
  get(@self.sweep_neg_used,SizeOf(self.sweep_neg_used));
  get(@self.cgb_mode,SizeOf(self.cgb_mode));
  get(@self.frame_step,SizeOf(self.frame_step));
  get(@self.frame_remaining,SizeOf(self.frame_remaining));
  get(@self.sample_fraction,SizeOf(self.sample_fraction));
  get(@self.wave_sample,SizeOf(self.wave_sample));
  get(@self.wave_window,SizeOf(self.wave_window));
  get(@self.capacitor_left,SizeOf(self.capacitor_left));
  get(@self.capacitor_right,SizeOf(self.capacitor_right));
  if self.cgb_mode then self.hpf_factor:=Power(0.998943,APU_CLOCK/FREQ_BASE_AUDIO)
    else self.hpf_factor:=Power(0.999958,APU_CLOCK/FREQ_BASE_AUDIO);
end;

end.
