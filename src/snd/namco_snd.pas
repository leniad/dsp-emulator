unit namco_snd;

interface
uses main_engine,sound_engine,timer_engine,dialogs;

const
  max_voices=8;

type
  tipo_voice=record
    volume:byte;
    numero_onda:byte;
    frecuencia:dword;
    activa:boolean;
    dentro_onda:dword;
    volume_right:byte;
    raw_frequency:dword;
    noise_sw:boolean;
    noise_state:boolean;
    noise_seed:dword;
    noise_counter:dword;
    noise_hold:integer;
    noise_phase:Int64;
  end;
  tnamco_63701=record
    select:integer;
    playing:boolean;
    base_addr,position,volume,silence_counter:integer;
    timer,tsample:byte;
    signal:integer;
  end;

  namco_snd_chip=class(snd_chip_class)
    constructor create(num_voces:byte;wave_ram:boolean=false;clock:dword=0);
    destructor free;
  public
    enabled:boolean;
    regs:array[0..$3f] of byte;
    procedure update;
    procedure reset;
    function get_wave_dir:pbyte;
    procedure namcos1_sound_w(direccion:word;valor:byte);
    procedure namcos1_cus30_w(direccion:word;valor:byte);
    function namcos1_cus30_r(direccion:word):byte;
    function save_snapshot(data:pbyte):word;
    procedure load_snapshot(data:pbyte);
  private
    onda:array[0..$ff] of byte;
    ram:array[0..$3ff] of byte;
    num_voces:byte;
    namco_wave:array[0..$1ff] of byte;
    wave_on_ram:boolean;
    chip_clock:dword;
    frequency_scale:Int64;
    noise_rate:integer;
    noise_hold_reload:integer;
    voice:array[0..max_voices-1] of tipo_voice;
    procedure update_waveform(offset:word;data:byte);
    procedure rebuild_waveforms;
    procedure getvoice_3(numero_voz:byte);
    procedure getvoice_8(numero_voz:byte);
    function scale_frequency(f:dword):dword;
    procedure advance_noise(ch:byte);
  end;

procedure namco_63701x_start(clock:dword);
procedure namco_63701x_close;
procedure namco_63701x_update;
procedure namco_63701x_w(dir:word;valor:byte);
procedure namco_63701x_internal_update;
procedure namco_63701x_reset;

var
  namco_63701:array[0..1] of tnamco_63701;
  namco_63701_rom:pbyte;
  namco_snd_0:namco_snd_chip;

implementation
var
  pcm_started:boolean=false;

function clip16(value:integer):smallint;
begin
  if value>32767 then clip16:=32767
    else if value< -32768 then clip16:=-32768
      else clip16:=value;
end;

constructor namco_snd_chip.create(num_voces:byte;wave_ram:boolean=false;clock:dword=0);
var
  input_clock:double;
  multiple:integer;
begin
  if addr(update_sound_proc)=nil then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!',mtInformation,[mbOk],0);
  self.num_voces:=num_voces;
  self.wave_on_ram:=wave_ram;
  self.chip_clock:=clock;
  if clock<>0 then self.frequency_scale:=Int64(clock)*1024
    else if (num_voces=3) and (not wave_ram) then self.frequency_scale:=96000000
      else self.frequency_scale:=24000000;
  input_clock:=self.frequency_scale/1024.0;
  multiple:=0;
  while input_clock<192000 do begin
    input_clock:=input_clock*2;
    inc(multiple);
  end;
  self.noise_rate:=Round(input_clock);
  // Reproduce the hold counter used by the classic Namco noise generator.
  if multiple>0 then self.noise_hold_reload:=1 shl (multiple-1)
    else self.noise_hold_reload:=1;
  self.tsample_num:=init_channel;
  self.reset;
end;

destructor namco_snd_chip.free;
begin
end;

function namco_snd_chip.get_wave_dir:pbyte;
begin
  get_wave_dir:=@self.onda[0];
end;

procedure namco_snd_chip.update_waveform(offset:word;data:byte);
begin
  if offset>$ff then exit;
  if self.wave_on_ram then begin
    self.namco_wave[offset*2]:=(data shr 4) and $f;
    self.namco_wave[offset*2+1]:=data and $f;
  end else self.namco_wave[offset]:=data and $f;
end;

procedure namco_snd_chip.rebuild_waveforms;
var
  f:integer;
begin
  fillchar(self.namco_wave,SizeOf(self.namco_wave),0);
  for f:=0 to $ff do
    if self.wave_on_ram then self.update_waveform(f,self.ram[f])
      else self.update_waveform(f,self.onda[f]);
end;

procedure namco_snd_chip.reset;
var
  f:integer;
begin
  self.enabled:=true;
  fillchar(self.voice,SizeOf(self.voice),0);
  fillchar(self.regs,SizeOf(self.regs),0);
  // Wave RAM and shared RAM are retained; sound registers are cleared.
  FillChar(self.ram[$100],$40,0);
  for f:=0 to max_voices-1 do self.voice[f].noise_seed:=1;
  self.rebuild_waveforms;
end;

function namco_snd_chip.scale_frequency(f:dword):dword;
var
  value:Int64;
begin
  value:=(Int64(f)*self.frequency_scale) div FREQ_BASE_AUDIO;
  scale_frequency:=dword(value and Int64($ffffffff));
end;

procedure namco_snd_chip.getvoice_3(numero_voz:byte);
var
  base:integer;
  f:dword;
begin
  base:=5*numero_voz;
  self.voice[numero_voz].numero_onda:=self.regs[$5+base] and 7;
  self.voice[numero_voz].volume:=self.regs[$15+base] and $f;
  self.voice[numero_voz].volume_right:=self.voice[numero_voz].volume;
  f:=dword(self.regs[$14+base] and $f) shl 16;
  f:=f or (dword(self.regs[$13+base] and $f) shl 12);
  f:=f or (dword(self.regs[$12+base] and $f) shl 8);
  f:=f or (dword(self.regs[$11+base] and $f) shl 4);
  if numero_voz=0 then f:=f or (self.regs[$10] and $f);
  self.voice[numero_voz].raw_frequency:=f;
  self.voice[numero_voz].frecuencia:=self.scale_frequency(f);
  self.voice[numero_voz].activa:=(f<>0) and (self.voice[numero_voz].volume<>0);
end;

procedure namco_snd_chip.getvoice_8(numero_voz:byte);
var
  base:integer;
  f:dword;
begin
  base:=numero_voz*8;
  self.voice[numero_voz].numero_onda:=(self.regs[base+6] shr 4) and 7;
  self.voice[numero_voz].volume:=self.regs[base+3] and $f;
  self.voice[numero_voz].volume_right:=self.voice[numero_voz].volume;
  f:=self.regs[base+4];
  f:=f or (dword(self.regs[base+5]) shl 8);
  f:=f or (dword(self.regs[base+6] and $f) shl 16);
  self.voice[numero_voz].raw_frequency:=f;
  self.voice[numero_voz].frecuencia:=self.scale_frequency(f);
  self.voice[numero_voz].activa:=(f<>0) and (self.voice[numero_voz].volume<>0);
end;

procedure namco_snd_chip.advance_noise(ch:byte);
var
  count:integer;
begin
  self.voice[ch].noise_phase:=self.voice[ch].noise_phase+self.noise_rate;
  while self.voice[ch].noise_phase>=FREQ_BASE_AUDIO do begin
    self.voice[ch].noise_phase:=self.voice[ch].noise_phase-FREQ_BASE_AUDIO;
    if self.voice[ch].noise_hold<>0 then Dec(self.voice[ch].noise_hold)
    else begin
      self.voice[ch].noise_hold:=self.noise_hold_reload;
      self.voice[ch].noise_counter:=self.voice[ch].noise_counter+((self.voice[ch].raw_frequency and $ff) shl 4);
      count:=self.voice[ch].noise_counter shr 12;
      self.voice[ch].noise_counter:=self.voice[ch].noise_counter and $fff;
      while count>0 do begin
        if ((self.voice[ch].noise_seed+1) and 2)<>0 then self.voice[ch].noise_state:=not(self.voice[ch].noise_state);
        if (self.voice[ch].noise_seed and 1)<>0 then self.voice[ch].noise_seed:=self.voice[ch].noise_seed xor $28000;
        self.voice[ch].noise_seed:=self.voice[ch].noise_seed shr 1;
        dec(count);
      end;
    end;
  end;
end;

procedure namco_snd_chip.update;
var
  ch,index,wave_sample,lv,rv,left_mix,right_mix:integer;
  left_sample,right_sample:smallint;
begin
  left_mix:=0;
  right_mix:=0;
  if self.enabled then begin
    for ch:=0 to self.num_voces-1 do begin
      if not self.wave_on_ram then begin
        if self.num_voces=3 then self.getvoice_3(ch)
          else self.getvoice_8(ch);
      end;
      lv:=self.voice[ch].volume;
      rv:=self.voice[ch].volume_right;
      if self.wave_on_ram and self.voice[ch].noise_sw then begin
        if ((lv<>0) or (rv<>0)) and ((self.voice[ch].raw_frequency and $ff)<>0) then begin
          if self.voice[ch].noise_state then wave_sample:=7 else wave_sample:=-7;
          left_mix:=left_mix+wave_sample*(lv shr 1);
          right_mix:=right_mix+wave_sample*(rv shr 1);
          self.advance_noise(ch);
        end;
      end else if (self.voice[ch].raw_frequency<>0) and ((lv<>0) or (rv<>0)) then begin
        index:=32*Integer(self.voice[ch].numero_onda)+Integer((self.voice[ch].dentro_onda shr 25) and $1f);
        wave_sample:=Integer(self.namco_wave[index])-8;
        left_mix:=left_mix+wave_sample*lv;
        right_mix:=right_mix+wave_sample*rv;
        self.voice[ch].dentro_onda:=dword((Int64(self.voice[ch].dentro_onda)+Int64(self.voice[ch].frecuencia)) and Int64($ffffffff));
      end;
    end;
  end;
  left_mix:=(left_mix*256) div self.num_voces;
  right_mix:=(right_mix*256) div self.num_voces;
  left_sample:=clip16(left_mix);
  right_sample:=clip16(right_mix);
  if sound_status.stereo then begin
    tsample[self.tsample_num,sound_status.posicion_sonido]:=left_sample;
    tsample[self.tsample_num,sound_status.posicion_sonido+1]:=right_sample;
  end else tsample[self.tsample_num,sound_status.posicion_sonido]:=
    clip16((left_mix+right_mix) div 2);
end;

procedure namco_snd_chip.namcos1_sound_w(direccion:word;valor:byte);
var
  ch,next_ch:integer;
  f:dword;
begin
  if (direccion>$3f) or (not self.wave_on_ram) then exit;
  self.ram[$100+direccion]:=valor;
  if self.regs[direccion]=valor then Exit;
  self.regs[direccion]:=valor;
  ch:=direccion div 8;
  if ch>=self.num_voces then exit;
  case direccion and 7 of
    0:self.voice[ch].volume:=valor and $f;
    1,2,3:begin
      self.voice[ch].numero_onda:=(self.regs[ch*8+1] shr 4) and $f;
      f:=(dword(self.regs[ch*8+1] and $f) shl 16) or (dword(self.regs[ch*8+2]) shl 8) or self.regs[ch*8+3];
      self.voice[ch].raw_frequency:=f;
      self.voice[ch].frecuencia:=self.scale_frequency(f);
    end;
    4:begin
      self.voice[ch].volume_right:=valor and $f;
      next_ch:=ch+1;
      if next_ch=self.num_voces then next_ch:=0;
      self.voice[next_ch].noise_sw:=(valor and $80)<>0;
    end;
  end;
  self.voice[ch].activa:=(self.voice[ch].raw_frequency<>0) and ((self.voice[ch].volume<>0) or (self.voice[ch].volume_right<>0));
end;

procedure namco_snd_chip.namcos1_cus30_w(direccion:word;valor:byte);
begin
  if direccion>$3ff then exit;
  if direccion<$100 then begin
    if self.ram[direccion]<>valor then begin
      self.ram[direccion]:=valor;
      self.update_waveform(direccion,valor);
    end;
  end else if direccion<$140 then self.namcos1_sound_w(direccion-$100,valor)
    else self.ram[direccion]:=valor;
end;

function namco_snd_chip.namcos1_cus30_r(direccion:word):byte;
begin
  if direccion<=$3ff then namcos1_cus30_r:=self.ram[direccion]
    else namcos1_cus30_r:=$ff;
end;

function namco_snd_chip.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
procedure put(const value;count:integer);
begin
  copymemory(temp,@value,count);
  inc(temp,count);
  size:=size+count;
end;
begin
  temp:=data;
  size:=0;
  put(self.num_voces,SizeOf(self.num_voces));
  put(self.wave_on_ram,SizeOf(self.wave_on_ram));
  put(self.chip_clock,SizeOf(self.chip_clock));
  put(self.enabled,SizeOf(self.enabled));
  put(self.voice,SizeOf(self.voice));
  put(self.regs,SizeOf(self.regs));
  put(self.ram,SizeOf(self.ram));
  put(self.onda,SizeOf(self.onda));
  save_snapshot:=size;
end;

procedure namco_snd_chip.load_snapshot(data:pbyte);
var
  temp:pbyte;
  clock:dword;
  voices:byte;
  wave_ram:boolean;
procedure get(var value;count:integer);
begin
  copymemory(@value,temp,count);
  inc(temp,count);
end;
begin
  temp:=data;
  get(voices,SizeOf(voices));
  get(wave_ram,SizeOf(wave_ram));
  get(clock,SizeOf(clock));
  get(self.enabled,SizeOf(self.enabled));
  get(self.voice,SizeOf(self.voice));
  get(self.regs,SizeOf(self.regs));
  get(self.ram,SizeOf(self.ram));
  get(self.onda,SizeOf(self.onda));
  self.rebuild_waveforms;
end;

procedure namco_63701x_start(clock:dword);
begin
  if not pcm_started then begin
    getmem(namco_63701_rom,$80000);
    fillchar(namco_63701_rom^,$80000,$ff);
    namco_63701[0].tsample:=init_channel;
    namco_63701[1].tsample:=init_channel;
    namco_63701[0].timer:=timers.init(sound_status.cpu_num,sound_status.cpu_clock/(clock/1000.0),namco_63701x_internal_update,nil,false);
    pcm_started:=true;
  end else begin
    timers.enabled(namco_63701[0].timer,false);
    timers.timer[namco_63701[0].timer].time_final:=sound_status.cpu_clock/(clock/1000.0);
  end;
  namco_63701x_reset;
  timers.enabled(namco_63701[0].timer,true);
end;

procedure namco_63701x_close;
begin
  if pcm_started then timers.enabled(namco_63701[0].timer,false);
  pcm_started:=false;
  namco_63701x_reset;
  if namco_63701_rom<>nil then FreeMem(namco_63701_rom);
  namco_63701_rom:=nil;
end;

procedure namco_63701x_reset;
var
  f:integer;
begin
  for f:=0 to 1 do begin
    namco_63701[f].select:=0;
    namco_63701[f].playing:=false;
    namco_63701[f].base_addr:=0;
    namco_63701[f].position:=0;
    namco_63701[f].volume:=0;
    namco_63701[f].silence_counter:=0;
    namco_63701[f].signal:=0;
  end;
end;

procedure namco_63701x_update;
var
  f:integer;
begin
  if not pcm_started then Exit;
  for f:=0 to 1 do begin
    tsample[namco_63701[f].tsample,sound_status.posicion_sonido]:=namco_63701[f].signal;
    if sound_status.stereo then
      tsample[namco_63701[f].tsample,sound_status.posicion_sonido+1]:=namco_63701[f].signal;
  end;
end;

procedure namco_63701x_internal_update;
const
  vol_table:array[0..3] of word=(26,84,200,258);
var
  data:byte;
  ch,pos:integer;
  base,ptr:pbyte;
begin
  if not pcm_started then exit;
  if namco_63701_rom=nil then exit;
  for ch:=0 to 1 do begin
    namco_63701[ch].signal:=0;
    if namco_63701[ch].playing then begin
      base:=namco_63701_rom;
      Inc(base,namco_63701[ch].base_addr);
      pos:=namco_63701[ch].position;
      if namco_63701[ch].silence_counter<>0 then dec(namco_63701[ch].silence_counter)
      else begin
        ptr:=base;
        Inc(ptr,pos and $ffff);
        Inc(pos);
        data:=ptr^;
        if data=$ff then namco_63701[ch].playing:=false
        else if data=0 then begin
          ptr:=base;
          Inc(ptr,pos and $ffff);
          Inc(pos);
          namco_63701[ch].silence_counter:=ptr^;
        end else namco_63701[ch].signal:=vol_table[namco_63701[ch].volume]*(Integer(data)-$80);
      end;
      namco_63701[ch].position:=pos and $ffff;
    end;
  end;
end;

procedure namco_63701x_w(dir:word;valor:byte);
var
  ch,rom_offs:integer;
  ptr:pbyte;
begin
  if (not pcm_started) or (dir>3) then exit;
  if namco_63701_rom=nil then exit;
  ch:=dir shr 1;
  if (dir and 1)<>0 then namco_63701[ch].select:=valor
  else if (namco_63701[ch].select and $1f)<>0 then begin
    namco_63701[ch].base_addr:=$10000*((namco_63701[ch].select and $e0) shr 5);
    rom_offs:=namco_63701[ch].base_addr+2*((namco_63701[ch].select and $1f)-1);
    ptr:=namco_63701_rom;
    Inc(ptr,rom_offs);
    namco_63701[ch].position:=Integer(ptr^) shl 8;
    Inc(ptr);
    namco_63701[ch].position:=namco_63701[ch].position+ptr^;
    namco_63701[ch].volume:=valor shr 6;
    namco_63701[ch].silence_counter:=0;
    namco_63701[ch].signal:=0;
    namco_63701[ch].playing:=true;
  end;
end;

end.
