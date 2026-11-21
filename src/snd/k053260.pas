unit k053260;

interface
uses sound_engine,misc_functions,timer_engine,main_engine,cpu_misc,dialogs;

type
  tKDSC_Voice=class
      constructor create(adpcm_rom:pbyte;size:dword);
      destructor free;
	  public
		  procedure play;
		  function voice_playing:boolean;
		  function read_rom:byte;
	private
		  // live state
		  position:dword;
		  pan_volume:array[0..1] of integer;
		  counter:word;
		  output:shortint;
      out1,out2:integer;
		  is_playing:boolean;
		  // per voice registers
		  start:dword;
		  length:word;
		  pitch:word;
		  volume:byte;
		  // bit packed registers
		  pan:byte;
		  loop:boolean;
		  kadpcm,reverse:boolean;
      rom:pbyte;
      rom_size:dword;
      procedure voice_reset;
		  procedure set_register(offset:word;data:byte);
		  procedure set_loop_kadpcm(data:byte);
		  procedure set_pan(data:byte);
		  procedure update_pan_volume;
      procedure key_on;
		  procedure key_off;
  end;
  tk053260_chip=class(snd_chip_class)
      constructor create(clock:dword;rom:pbyte;size:dword;amp:single);
      destructor free;
   public
      procedure update;
      procedure reset;
      function main_read(direccion:byte):byte;
	    procedure main_write(direccion,valor:byte);
	    function read(direccion:byte):byte;
	    procedure write(direccion,valor:byte);
      procedure change_calls(sh1,sh2:cpu_outport_call);
      procedure change_clock(clock:dword);
   private
      // configuration
	    instance_id:byte;
      timers_ready:boolean;
	    // live state
	    portdata:array[0..3] of byte;
	    keyon:byte;
	    mode:byte;
      voice:array[0..3] of tKDSC_Voice;
      ntimer,ntimer2,state_output,tsample_num2:byte;
      mix_sum:array[0..1] of Int64;
      last_mix:array[0..1] of integer;
      sample_count:dword;
      sh1_call,sh2_call:cpu_outport_call;
      procedure internal_update;
  end;
var
  k053260_0:tk053260_chip;

implementation
const
  CLOCKS_PER_SAMPLE=64;
var
  instances:array[0..3] of tk053260_chip;

procedure internal_update_k053260(index:byte);
begin
  if instances[index]<>nil then instances[index].internal_update;
end;

procedure call_update_k053260(index:byte);
var
  chip:tk053260_chip;
begin
  chip:=instances[index];
  if chip=nil then exit;
  case chip.state_output of
    0:if @chip.sh1_call<>nil then chip.sh1_call(ASSERT_LINE);
    1:if @chip.sh1_call<>nil then chip.sh1_call(CLEAR_LINE);
    2:if @chip.sh2_call<>nil then chip.sh2_call(ASSERT_LINE);
    3:if @chip.sh2_call<>nil then chip.sh2_call(CLEAR_LINE);
  end;
  chip.state_output:=(chip.state_output+1) and 3;
end;

constructor tk053260_chip.create(clock:dword;rom:pbyte;size:dword;amp:single);
var
  f:integer;
begin
  self.instance_id:=$ff;
  for f:=0 to 3 do
    if instances[f]=nil then begin
      self.instance_id:=f;
      Break;
    end;
  if addr(update_sound_proc)=nil then
    MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!',mtInformation,[mbOk],0);
  self.clock:=clock;
  self.amp:=amp;
  for f:=0 to 3 do self.voice[f]:=tKDSC_Voice.create(rom,size);
  self.tsample_num:=init_channel;
  self.tsample_num2:=init_channel;
  self.ntimer:=timers.init(sound_status.cpu_num,sound_status.cpu_clock*64.0/clock,nil,internal_update_k053260,false,self.instance_id);
  self.ntimer2:=timers.init(sound_status.cpu_num,sound_status.cpu_clock*16.0/clock,nil,call_update_k053260,false,self.instance_id);
  self.timers_ready:=true;
  instances[self.instance_id]:=self;
  self.reset;
  timers.enabled(self.ntimer,true);
  timers.enabled(self.ntimer2,true);
end;

destructor tk053260_chip.free;
var
  f:integer;
begin
  if self.timers_ready then begin
    timers.enabled(self.ntimer,false);
    timers.enabled(self.ntimer2,false);
  end;
  if self.instance_id<=3 then
    if instances[self.instance_id]=self then instances[self.instance_id]:=nil;
  if k053260_0=self then k053260_0:=nil;
  for f:=0 to 3 do if self.voice[f]<>nil then self.voice[f].free;
end;

procedure tk053260_chip.reset;
var
  f:integer;
begin
  for f:=0 to 3 do self.voice[f].voice_reset;
  self.sample_count:=0;
  self.mix_sum[0]:=0;
  self.mix_sum[1]:=0;
  self.last_mix[0]:=0;
  self.last_mix[1]:=0;
  // Preserve communication ports and control latches on reset, as before.
  self.state_output:=0;
  if @self.sh1_call<>nil then self.sh1_call(CLEAR_LINE);
  if @self.sh2_call<>nil then self.sh2_call(CLEAR_LINE);
end;

procedure tk053260_chip.change_clock(clock:dword);
begin
  self.clock:=clock;
  // timer_engine owns the current timer phase; only update its period here.
  timers.timer[self.ntimer].time_final:=sound_status.cpu_clock*64.0/clock;
  timers.timer[self.ntimer2].time_final:=sound_status.cpu_clock*16.0/clock;
end;

procedure tk053260_chip.change_calls(sh1,sh2:cpu_outport_call);
begin
  self.sh1_call:=sh1;
  self.sh2_call:=sh2;
end;

function tk053260_chip.main_read(direccion:byte):byte;
begin
  main_read:=self.portdata[2+(direccion and 1)];
end;
procedure tk053260_chip.main_write(direccion,valor:byte);
begin
  self.portdata[direccion and 1]:=valor;
end;
function tk053260_chip.read(direccion:byte):byte;
var
  ret,f:byte;
begin
	direccion:=direccion and $3f;
	ret:=0;
	case direccion of
		$00,$01:ret:=self.portdata[direccion]; // main-to-sub ports
		$29:for f:=0 to 3 do ret:=ret or (byte(self.voice[f].voice_playing) shl f); // voice status
		$2e:if (self.mode and 1)<>0 then ret:=self.voice[0].read_rom; // read ROM
  end;
read:=ret;
end;
procedure tk053260_chip.write(direccion,valor:byte);
var
  f,rising_edge:byte;
begin
	direccion:=direccion and $3f;
	// per voice registers
	if ((direccion>=$08) and (direccion<=$27)) then begin
		self.voice[(direccion-8) div 8].set_register(direccion,valor);
		exit;
	end;
	case direccion of
		// 0x00 and 0x01 are read registers
    $02,$03:self.portdata[direccion]:=valor; // sub-to-main ports
		// 0x04 through 0x07 seem to be unused
    $28:begin // key on/off
			rising_edge:=valor and not(self.keyon);
			for f:=0 to 3 do begin
        self.voice[f].reverse:=(valor and (1 shl (f+4)))<>0;
				if ((rising_edge and (1 shl f))<>0) then self.voice[f].key_on
				  else if ((valor and (1 shl f))=0) then self.voice[f].key_off;
			end;
			self.keyon:=valor;
      end;
		// 0x29 is a read register
		$2a:begin // loop and pcm/adpcm select
			    for f:=0 to 3 do begin
            self.voice[f].set_loop_kadpcm(valor);
				    valor:=valor shr 1;
          end;
        end;
		// 0x2b seems to be unused
 		$2c:begin // pan, voices 0 and 1
			    self.voice[0].set_pan(valor);
			    self.voice[1].set_pan(valor shr 3);
			  end;
		$2d:begin // pan, voices 2 and 3
			    self.voice[2].set_pan(valor);
			    self.voice[3].set_pan(valor shr 3);
			  end;
		// 0x2e is a read register
		$2f:begin // control
			    self.mode:=valor;
			    // bit 0 = enable ROM read from register 0x2e
			    // bit 1 = enable sound output
			    // bit 2 = enable aux input?
			    //   (set by all games except Golfing Greats and Rollergames, both of which
			    //    don't have a YM2151. Over Drive only sets it on one of the two chips)
			    // bit 3 = aux input or ROM sharing related?
			    //   (only set by Over Drive, and only on the same chip that bit 2 is set on)
			  end;
end;
end;
function clip_sample(value:double):smallint;
begin
  if value>32767 then clip_sample:=32767
    else if value< -32768 then clip_sample:=-32768
      else clip_sample:=round(value);
end;

procedure tk053260_chip.update;
var
  out1,out2:smallint;
begin
  if self.sample_count<>0 then begin
    self.last_mix[0]:=Round(self.mix_sum[0]/self.sample_count);
    self.last_mix[1]:=Round(self.mix_sum[1]/self.sample_count);
  end;
  out1:=clip_sample(self.last_mix[0]*self.amp);
  out2:=clip_sample(self.last_mix[1]*self.amp);
  if sound_status.stereo then begin
    tsample[self.tsample_num,sound_status.posicion_sonido]:=out1;
    tsample[self.tsample_num,sound_status.posicion_sonido+1]:=out2;
  end else begin
    tsample[self.tsample_num,sound_status.posicion_sonido]:=out1;
    tsample[self.tsample_num2,sound_status.posicion_sonido]:=out2;
  end;
  self.sample_count:=0;
  self.mix_sum[0]:=0;
  self.mix_sum[1]:=0;
end;

function sshr(num:integer;fac:byte):integer;
begin
  if num<0 then sshr:=integer(-(((-Int64(num))+((Int64(1) shl fac)-1)) shr fac))
    else sshr:=num shr fac;
end;

procedure tk053260_chip.internal_update;
var
  f:integer;
  left,right:integer;
begin
  left:=0;
  right:=0;
  if (self.mode and 2)<>0 then
    for f:=0 to 3 do
      if self.voice[f].voice_playing then begin
        self.voice[f].play;
        left:=left+sshr(self.voice[f].out1,16);
        right:=right+sshr(self.voice[f].out2,16);
      end;
  // Bound the counter even if the host stops consuming audio indefinitely.
  if self.sample_count=High(dword) then begin
    self.mix_sum[0]:=Round(self.mix_sum[0]/self.sample_count);
    self.mix_sum[1]:=Round(self.mix_sum[1]/self.sample_count);
    self.sample_count:=1;
  end;
  self.mix_sum[0]:=self.mix_sum[0]+left;
  self.mix_sum[1]:=self.mix_sum[1]+right;
  Inc(self.sample_count);
end;
//KDSC Voice
constructor tKDSC_Voice.create(adpcm_rom:pbyte;size:dword);
begin
  self.rom:=adpcm_rom;
  self.rom_size:=size;
  self.voice_reset;
end;

destructor tKDSC_Voice.free;
begin
end;

function tKDSC_Voice.voice_playing:boolean;
begin
 voice_playing:=self.is_playing;
end;

procedure tKDSC_Voice.voice_reset;
begin
	self.position:=0;
	self.counter:=0;
	self.output:=0;
  self.out1:=0;
  self.out2:=0;
	self.is_playing:=false;
	self.start:=0;
	self.length:=0;
	self.pitch:=0;
	self.volume:=0;
	self.pan:=0;
	self.loop:=false;
	self.kadpcm:=false;
  self.reverse:=false;
	self.update_pan_volume;
end;

procedure tKDSC_Voice.set_register(offset:word;data:byte);
begin
	case offset and $7 of
		0:self.pitch:=(self.pitch and $0f00) or data; // pitch, lower 8 bits
		1:self.pitch:=(self.pitch and $00ff) or ((data shl 8) and $0f00); // pitch, upper 4 bits
		2:self.length:=(self.length and $ff00) or data; // length, lower 8 bits
		3:self.length:=(self.length and $00ff) or (data shl 8); // length, upper 8 bits
		4:self.start:=(self.start and $1fff00) or data; // start, lower 8 bits
		5:self.start:=(self.start and $1f00ff) or (data shl 8); // start, middle 8 bits
		6:self.start:=(self.start and $00ffff) or ((data shl 16) and $1f0000); // start, upper 5 bits
		7:begin // volume, 7 bits
			  self.volume:=data and $7f;
			  self.update_pan_volume;
      end;
	end;
end;

procedure tKDSC_Voice.set_loop_kadpcm(data:byte);
begin
	self.loop:=BIT(data,0);
	self.kadpcm:=BIT(data,4);
end;
procedure tKDSC_Voice.set_pan(data:byte);
begin
	self.pan:=data and $7;
	self.update_pan_volume;
end;

procedure tKDSC_Voice.update_pan_volume;
const pan_mul:array[0..7,0..1] of dword=(
	(     0,     0 ), // No sound for pan 0
	( 65536,     0 ), //  0 degrees
	( 59870, 26656 ), // 24 degrees
	( 53684, 37950 ), // 35 degrees
	( 46341, 46341 ), // 45 degrees
	( 37950, 53684 ), // 55 degrees
	( 26656, 59870 ), // 66 degrees
	(     0, 65536 ));  // 90 degrees
begin
	self.pan_volume[0]:=self.volume*pan_mul[self.pan,0];
	self.pan_volume[1]:=self.volume*pan_mul[self.pan,1];
end;

procedure tKDSC_Voice.key_on;
begin
  self.position:=byte(self.kadpcm); // for kadpcm low bit is nybble offset, so must start at 1 due to preincrement
	self.counter:=$1000-CLOCKS_PER_SAMPLE; // force update on next sound_stream_update
	self.output:=0;
  self.out1:=0;
  self.out2:=0;
	self.is_playing:=true;
end;

procedure tKDSC_Voice.key_off;
begin
	self.position:=0;
	self.output:=0;
  self.out1:=0;
  self.out2:=0;
	self.is_playing:=false;
end;

procedure tKDSC_Voice.play;
const
  kadpcm_table:array[0..15] of shortint=(0,1,2,4,8,16,32,64,-128,-64,-32,-16,-8,-4,-2,-1);
var
  bytepos:dword;
  romdata:byte;
  address:dword;
  value:integer;
begin
  self.out1:=0;
  self.out2:=0;
  if not self.is_playing then Exit;
	self.counter:=self.counter+CLOCKS_PER_SAMPLE;
	while (self.counter>=$1000) do begin
		self.counter:=self.counter-$1000+self.pitch;
    self.position:=self.position+1;
    bytepos:=self.position shr byte(self.kadpcm);
		if (bytepos>self.length) then begin
			if (self.loop) then begin
        self.position:=0;
        self.output:=0;
        self.out1:=0;
        self.out2:=0;
        bytepos:=0;
			end else begin
				self.is_playing:=false;
				exit;
			end;
		end;
    if self.reverse then address:=(self.start+$200000-bytepos) and $1fffff
      else address:=(self.start+bytepos) and $1fffff;
    if (self.rom=nil) or (address>=self.rom_size) then begin
      self.is_playing:=false;
      self.output:=0;
      exit;
    end;
    romdata:=self.rom[address];
		if self.kadpcm then begin
			if (self.position and 1)<>0 then romdata:=romdata shr 4; // decode low nybble, then high nybble
			value:=(Integer(self.output)+kadpcm_table[romdata and $f]) and $ff;
      if value>=128 then dec(value,256);
      self.output:=value;
    end else begin
			value:=romdata;
      if value>=128 then Dec(value,256);
      self.output:=value;
    end;
  end;
  // Apply current volume/pan even when no ROM byte was decoded this tick.
  self.out1:=Integer(self.output)*self.pan_volume[0];
  self.out2:=Integer(self.output)*self.pan_volume[1];
end;

function tKDSC_Voice.read_rom:byte;
var
  offs:dword;
begin
	offs:=(self.start+self.position) and $1fffff;
	self.position:=(self.position+1) and $ffff;
	if (self.rom=nil) or (offs>=self.rom_size) then read_rom:=0
	  else read_rom:=self.rom[offs];
end;

end.
