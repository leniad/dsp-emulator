unit qsound;

interface
uses timer_engine,sound_engine,dialogs,main_engine,rom_engine;

const
  QSOUND_CLOCKDIV=166;			 // Clock divider
  QSOUND_CHANNELS=16-1;
  qsound_rom:array[0..1] of tipo_roms=((n:'dl-1425.bin';l:$6000;p:0;crc:$D6CF5EF5),());

type

  QSOUND_CHANNEL_def=record
	  bank,	   // bank (x16)
	  address,	// start address
    pitch,	  // pitch
    reg3,	   // unknown (always 0x8000)
    loop,	   // loop address
    end_addr,		// end address
    vol,		// master volume
    pan,		// Pan value
    reg9:integer;	   // unknown
	  // Work variables
    key:integer;		// Key on / key off
    lvol,	   // left volume
    rvol,	   // right volume
    lastdt,	 // last sample value
    offset:integer;	 // current offset counter
  end;
  pQSOUND_CHANNEL_def=^QSOUND_CHANNEL_def;

  qsound_state_def=record
    // Private variables
	  channel:array[0..QSOUND_CHANNELS] of pQSOUND_CHANNEL_def;
    data:word;				  // register latch data
	  sample_rom:pbyte;	// Q sound sample ROM
	  sample_rom_length:dword;
	  pan_table:array[0..33-1] of integer;		 // Pan volume table
	  frq_ratio:single;		   // Frequency ratio
    tsample:byte;
    out_:array[0..1] of integer;
  end;
  pqsound_state_def=^qsound_state_def;

var
  qsound_state:pqsound_state_def;

function qsound_init(sample_size:dword):boolean;
procedure qsound_close;
procedure qsound_reset;
procedure qsound_w(offset,data:byte);
function qsound_r:byte;
procedure qsound_sound_update;

implementation

const
  ST_INIT1=$288;
  ST_INIT2=$61a;
  ST_REFRESH1=$039;
  ST_REFRESH2=$04f;
  ST_NORMAL1=$314;
  ST_NORMAL2=$6b2;
  PAN_BASE=$110;
  ADPCM_BASE=$9dc;
  FILTER_BASE=$d53;
  DELAY_BASE=$554;
  DELAY_BASE2=$53c;
  DSP_SAMPLE_RATE=60000000.0/2.0/1248.0;

type
  TVoice=record
    bank,addr,phase,rate,loop_len,end_addr,volume,echo:word;
  end;
  TAdpcm=record
    start_addr,end_addr,bank,volume,flag,cur_vol,step_size,cur_addr:word;
  end;
  TFir=record
    tap_count,delay_pos:integer;
    table_pos:word;
    taps,delay_line:array[0..94] of smallint;
  end;
  TDelay=record
    delay,volume:word;
    write_pos,read_pos:integer;
    delay_line:array[0..50] of smallint;
  end;
  TEcho=record
    end_pos,feedback:word;
    length,last_sample,delay_pos:integer;
    delay_line:array[0..1023] of smallint;
  end;
  TCore=record
    voice:array[0..15] of TVoice;
    adpcm:array[0..2] of TAdpcm;
    pan:array[0..18] of word;
    output:array[0..18] of smallint;
    echo:TEcho;
    filter,alt_filter:array[0..1] of TFir;
    wet,dry:array[0..1] of TDelay;
    state,next_state,delay_update:word;
    state_counter,ready_flag:integer;
    register_map:array[0..255] of pword;
    dsp_rom:array[0..4095] of word;
    rom_loaded:boolean;
  end;
var
  core:^TCore;
  timer_id:integer=-1;

function Signed16(v:word):integer;
begin
  if v>32767 then Signed16:=integer(v)-65536 else Signed16:=v;
end;

function Wrap32(v:int64):integer;
var
  u:cardinal;
begin
  u:=cardinal(v and $ffffffff);
  if u>$7fffffff then Wrap32:=integer(int64(u)-4294967296)
    else Wrap32:=integer(u);
end;

function ASR(v:int64;bits:integer):int64;
begin
  if v>=0 then ASR:=v shr bits
    else ASR:=-(((-v)+(int64(1) shl bits)-1) shr bits);
end;

function Clamp(v:int64;lo,hi:integer):integer;
begin
  if v<lo then Clamp:=lo
    else if v>hi then Clamp:=hi
            else Clamp:=integer(v);
end;

function DspRead(addr:integer):word;
begin
  DspRead:=core^.dsp_rom[addr and $fff];
end;

function SampleRead(bank,addr:word):integer;
var
  a:cardinal;
  b:byte;
begin
  // Capcom sample bus: 24-bit byte address, low DAC byte tied to zero.
  a:=((cardinal(bank and $7fff) shl 16) or addr) and $ffffff;
  if a>qsound_state^.sample_rom_length then b:=$ff
    else begin
      b:=pbyte(NativeUInt(qsound_state^.sample_rom)+a)^;
    end;
  SampleRead:=Signed16(word(b) shl 8);
end;

procedure StateNormal;
function FirApply(var f:TFir;input:smallint):integer;
var
  output,tap:integer;
begin
  output:=0;
  tap:=0;
  while tap<f.tap_count-1 do begin
    output:=Wrap32(int64(output)-int64(f.taps[tap])*f.delay_line[f.delay_pos]*4);
    inc(f.delay_pos);
    if f.delay_pos>=f.tap_count-1 then f.delay_pos:=0;
    inc(tap);
  end;
  output:=Wrap32(int64(output)-int64(f.taps[tap])*input*4);
  f.delay_line[f.delay_pos]:=input;inc(f.delay_pos);
  if f.delay_pos>=f.tap_count-1 then f.delay_pos:=0;
  FirApply:=output;
end;
function EchoApply(input:integer):smallint;
var
  old,new_sample:integer;
begin
  old:=core^.echo.delay_line[core^.echo.delay_pos];
  new_sample:=old;
  old:=integer(ASR(old+core^.echo.last_sample,1));
  core^.echo.last_sample:=new_sample;
  new_sample:=Wrap32(int64(input)+int64(old)*Signed16(core^.echo.feedback)*4);
  core^.echo.delay_line[core^.echo.delay_pos]:=Signed16(word(ASR(new_sample,16) and $ffff));
  inc(core^.echo.delay_pos);
  if core^.echo.delay_pos>=core^.echo.length then core^.echo.delay_pos:=0;
  EchoApply:=old;
end;
function AdpcmUpdate(var a:TAdpcm;curr,nibble:integer):smallint;
var
  step,delta,newstep:integer;
begin
  if nibble=0 then begin
    if a.cur_addr=a.end_addr then a.cur_vol:=0;
    if a.flag<>0 then begin
      curr:=0;a.flag:=0;a.step_size:=10;
      a.cur_vol:=a.volume;a.cur_addr:=a.start_addr;
    end;
    step:=integer(ASR(SampleRead(a.bank,a.cur_addr),12));
  end else begin
    // C++ narrows sample>>4 to int8 before arithmetic >>4.
    step:=(word(SampleRead(a.bank,a.cur_addr)) shr 8) and 15;
    if step>=8 then dec(step,16);
    a.cur_addr:=(a.cur_addr+1) and $ffff;
  end;
  delta:=((1+Abs(step*2))*Signed16(a.step_size)) div 2;
  if step<=0 then delta:=-delta;
  delta:=Clamp(delta+curr,-32768,32767);
  newstep:=(integer(DspRead(ADPCM_BASE+8+step))*Signed16(a.step_size)) shr 6;
  // Match int16 narrowing before MAME's int16 clamp.
  newstep:=Signed16(word(newstep and $ffff));
  a.step_size:=Clamp(newstep,1,2000);
  AdpcmUpdate:=integer(ASR(int64(delta)*Signed16(a.cur_vol),16));
end;
function VoiceUpdate(var v:TVoice;var echo_input:integer):smallint;
var
  output,new_phase:integer;
begin
  output:=Signed16(word(ASR(int64(Signed16(v.volume))*SampleRead(v.bank,v.addr),14) and $ffff));
  echo_input:=Wrap32(int64(echo_input)+int64(output)*Signed16(v.echo)*4);
  new_phase:=Signed16(v.addr)*4096+(v.phase shr 4)+v.rate;
  if ASR(new_phase,12)>=Signed16(v.end_addr) then new_phase:=new_phase-Signed16(v.loop_len)*4096;
  new_phase:=Clamp(new_phase,-$8000000,$7ffffff);
  v.addr:=word(ASR(new_phase,12) and $ffff);
  v.phase:=word((int64(new_phase)*16) and $ffff);
  VoiceUpdate:=output;
end;
function DelayApply(var d:TDelay;input:integer):integer;
begin
  d.delay_line[d.write_pos]:=Signed16(word(ASR(input,16) and $ffff));
  d.write_pos:=(d.write_pos+1) mod 51;
  DelayApply:=d.delay_line[d.read_pos]*Signed16(d.volume);
  d.read_pos:=(d.read_pos+1) mod 51;
end;
procedure DelayUpdate(var d:TDelay);
var
  p:integer;
begin
  p:=(d.write_pos-Signed16(d.delay)) mod 51;
  if p<0 then p:=p+51;
  d.read_pos:=p;
end;
var
  i,ch,voice_index,echo_input,echo_output,wet,dry,output,pan_index:integer;
begin
  core^.ready_flag:=$80;
  if core^.state=ST_NORMAL2 then i:=DELAY_BASE2
    else i:=DELAY_BASE;
  core^.echo.length:=Clamp(Signed16(word((integer(core^.echo.end_pos)-i) and $ffff)),0,1024);
  echo_input:=0;
  for i:=0 to 15 do core^.output[i]:=VoiceUpdate(core^.voice[i],echo_input);
  voice_index:=core^.state_counter mod 3;
  core^.output[16+voice_index]:=AdpcmUpdate(core^.adpcm[voice_index],core^.output[16+voice_index],core^.state_counter div 3);
  echo_output:=EchoApply(echo_input);
  for ch:=0 to 1 do begin
    wet:=0;dry:=0;
    if ch=1 then wet:=echo_output*16384
      else dry:=echo_output*16384;
    for i:=0 to 18 do begin
      pan_index:=(integer(core^.pan[i])+ch*196) and $ffff;
      dry:=Wrap32(int64(dry)-int64(core^.output[i])*Signed16(DspRead(pan_index)));
      wet:=Wrap32(int64(wet)-int64(core^.output[i])*Signed16(DspRead(pan_index+98)));
    end;
    dry:=Clamp(dry,-$1fffffff,$1fffffff)*4;
    wet:=Clamp(wet,-$1fffffff,$1fffffff)*4;
    wet:=FirApply(core^.filter[ch],smallint(ASR(wet,16)));
    if core^.state=ST_NORMAL2 then dry:=FirApply(core^.alt_filter[ch],smallint(ASR(dry,16)));
    output:=Wrap32(int64(DelayApply(core^.wet[ch],wet))+DelayApply(core^.dry[ch],dry));
    output:=Wrap32(int64(output)+$2000) and (not $3fff);
    qsound_state^.out_[ch]:=Clamp(ASR(output,14),-$7fff,$7fff);
    if core^.delay_update<>0 then begin
      DelayUpdate(core^.wet[ch]);
      DelayUpdate(core^.dry[ch]);
    end;
  end;
  core^.delay_update:=0;inc(core^.state_counter);
  if core^.state_counter>5 then begin
    core^.state_counter:=0;
    core^.state:=core^.next_state;
  end;
end;

procedure qsound_update_internal;
procedure RefreshFilters(mode:integer);
var
  ch,i:integer;
begin
  for ch:=0 to 1 do begin
    core^.filter[ch].delay_pos:=0;
    if mode=1 then core^.filter[ch].tap_count:=95
      else core^.filter[ch].tap_count:=45;
    for i:=0 to core^.filter[ch].tap_count-1 do core^.filter[ch].taps[i]:=Signed16(DspRead(core^.filter[ch].table_pos+i));
    if mode=2 then begin
      core^.alt_filter[ch].delay_pos:=0;
      core^.alt_filter[ch].tap_count:=44;
      for i:=0 to 43 do core^.alt_filter[ch].taps[i]:=Signed16(DspRead(core^.alt_filter[ch].table_pos+i));
    end;
  end;
  if mode=1 then core^.state:=ST_NORMAL1
    else core^.state:=ST_NORMAL2;
  core^.next_state:=core^.state;
end;
procedure StateInit;
var
  i,mode:integer;
begin
  if core^.state=ST_INIT2 then mode:=1
    else mode:=0;
  if core^.state_counter>=2 then begin
    core^.state_counter:=0;
    core^.state:=core^.next_state;
    exit;
  end;
  if core^.state_counter=1 then begin
    inc(core^.state_counter);
    exit;
  end;
  FillChar(core^.voice,SizeOf(core^.voice),0);
  FillChar(core^.adpcm,SizeOf(core^.adpcm),0);
  FillChar(core^.filter,SizeOf(core^.filter),0);
  FillChar(core^.alt_filter,SizeOf(core^.alt_filter),0);
  FillChar(core^.wet,SizeOf(core^.wet),0);
  FillChar(core^.dry,SizeOf(core^.dry),0);
  FillChar(core^.echo,SizeOf(core^.echo),0);
  for i:=0 to 18 do begin
    core^.pan[i]:=PAN_BASE+$10;
    core^.output[i]:=0;
  end;
  for i:=0 to 15 do core^.voice[i].bank:=$8000;
  for i:=0 to 2 do core^.adpcm[i].bank:=$8000;
  if mode=0 then begin
    core^.dry[0].delay:=46;core^.dry[1].delay:=48;
    core^.filter[0].table_pos:=FILTER_BASE+95;
    core^.filter[1].table_pos:=FILTER_BASE+190;
    core^.echo.end_pos:=DELAY_BASE+6;core^.next_state:=ST_REFRESH1;
  end else begin
    core^.wet[0].delay:=1;
    core^.filter[0].table_pos:=$f73;core^.filter[1].table_pos:=$fa4;
    core^.alt_filter[0].table_pos:=$f73;core^.alt_filter[1].table_pos:=$fa4;
    core^.echo.end_pos:=DELAY_BASE2+6;core^.next_state:=ST_REFRESH2;
  end;
  for i:=0 to 1 do begin
    core^.wet[i].volume:=$3fff;
    core^.dry[i].volume:=$3fff;
  end;
  core^.delay_update:=1;
  core^.ready_flag:=0;
  core^.state_counter:=1;
end;
begin
  case core^.state of
    ST_REFRESH1:RefreshFilters(1);
    ST_REFRESH2:RefreshFilters(2);
    ST_NORMAL1,ST_NORMAL2:StateNormal;
    else StateInit;
  end;
end;

procedure qsound_reset;
var
  i:integer;
begin
  core^.ready_flag:=0;
  core^.state:=0;core^.state_counter:=0;
  qsound_state^.data:=0;
  qsound_state^.out_[0]:=0;
  qsound_state^.out_[1]:=0;
  for i:=0 to QSOUND_CHANNELS do fillchar(qsound_state^.channel[i]^,SizeOf(QSOUND_CHANNEL_def),0);
end;

procedure qsound_w(offset,data:byte);
var
  dest:pword;
begin
  case offset of
    0:qsound_state^.data:=(qsound_state^.data and $ff) or (word(data) shl 8);
    1:qsound_state^.data:=(qsound_state^.data and $ff00) or data;
    2:begin
      dest:=core^.register_map[data];
      if dest<>nil then dest^:=qsound_state^.data;
      core^.ready_flag:=0;
    end;
  end;
end;

function qsound_r:byte;
begin
  qsound_r:=core^.ready_flag;
end;

procedure qsound_sound_update;
begin
  tsample[qsound_state^.tsample,sound_status.posicion_sonido]:=qsound_state^.out_[0];
  tsample[qsound_state^.tsample,sound_status.posicion_sonido+1]:=qsound_state^.out_[1];
end;

procedure qsound_close;
var
  i:integer;
begin
  if qsound_state^.sample_rom<>nil then FreeMem(qsound_state^.sample_rom);
  for i:=0 to QSOUND_CHANNELS do
    if qsound_state^.channel[i]<>nil then FreeMem(qsound_state^.channel[i]);
  freemem(qsound_state);qsound_state:=nil;
  dispose(core);
  core:=nil;
end;

function qsound_init(sample_size:dword):boolean;
procedure initmap;
var
  i:integer;
begin
  fillchar(core^.register_map,SizeOf(core^.register_map),0);
  for i:=0 to 15 do begin
    core^.register_map[i*8]:=@core^.voice[(i+1) mod 16].bank;
    core^.register_map[i*8+1]:=@core^.voice[i].addr;
    core^.register_map[i*8+2]:=@core^.voice[i].rate;
    core^.register_map[i*8+3]:=@core^.voice[i].phase;
    core^.register_map[i*8+4]:=@core^.voice[i].loop_len;
    core^.register_map[i*8+5]:=@core^.voice[i].end_addr;
    core^.register_map[i*8+6]:=@core^.voice[i].volume;
    core^.register_map[$80+i]:=@core^.pan[i];
    core^.register_map[$ba+i]:=@core^.voice[i].echo;
  end;
  for i:=0 to 2 do begin
    core^.register_map[$ca+i*4]:=@core^.adpcm[i].start_addr;
    core^.register_map[$cb+i*4]:=@core^.adpcm[i].end_addr;
    core^.register_map[$cc+i*4]:=@core^.adpcm[i].bank;
    core^.register_map[$cd+i*4]:=@core^.adpcm[i].volume;
    core^.register_map[$d6+i]:=@core^.adpcm[i].flag;
    core^.register_map[$90+i]:=@core^.pan[16+i];
  end;
  core^.register_map[$93]:=@core^.echo.feedback;
  core^.register_map[$d9]:=@core^.echo.end_pos;
  core^.register_map[$e2]:=@core^.delay_update;
  core^.register_map[$e3]:=@core^.next_state;
  for i:=0 to 1 do begin
    core^.register_map[$da+i*2]:=@core^.filter[i].table_pos;
    core^.register_map[$db+i*2]:=@core^.alt_filter[i].table_pos;
    core^.register_map[$de+i*2]:=@core^.wet[i].delay;
    core^.register_map[$df+i*2]:=@core^.dry[i].delay;
    core^.register_map[$e4+i*2]:=@core^.wet[i].volume;
    core^.register_map[$e5+i*2]:=@core^.dry[i].volume;
  end;
end;
var
  i:integer;
  memoria_temp:array[0..$5fff] of byte;
begin
  qsound_init:=false;
  getmem(qsound_state,SizeOf(qsound_state_def));
  fillchar(qsound_state^,SizeOf(qsound_state_def),0);
  for i:=0 to QSOUND_CHANNELS do begin
    getmem(qsound_state^.channel[i],SizeOf(QSOUND_CHANNEL_def));
    fillchar(qsound_state^.channel[i]^,SizeOf(QSOUND_CHANNEL_def),0);
  end;
  getmem(qsound_state^.sample_rom,sample_size);
  fillchar(qsound_state^.sample_rom^,sample_size,$ff);
  qsound_state^.sample_rom_length:=sample_size-1;
  qsound_state^.frq_ratio:=16;
  // Legacy diagnostic table retained; the DSP uses its own ROM pan tables.
  for i:=0 to 32 do qsound_state^.pan_table[i]:=trunc((256/Sqrt(32))*Sqrt(i));
  New(core);
  fillchar(core^,SizeOf(TCore),0);
  initmap;
  qsound_state^.tsample:=init_channel;
  qsound_reset;
  if not(roms_load(@memoria_temp,qsound_rom,true,true,'qsound.zip')) then exit;
  for i:=0 to 4095 do core^.dsp_rom[i]:=memoria_temp[i*2] or (word(memoria_temp[i*2+1]) shl 8);
  timer_id:=timers.init(sound_status.cpu_num,sound_status.cpu_clock/DSP_SAMPLE_RATE,qsound_update_internal,nil,true);
  timers.reset(timer_id);
  qsound_init:=true;
end;
end.
