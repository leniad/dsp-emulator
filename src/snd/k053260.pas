unit k053260;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}sound_engine,misc_functions,timer_engine;

type
  tKDSC_Voice=class
      constructor create(adpcm_rom:pbyte;size:dword);
      destructor free;
	  public
		  procedure voice_reset;
		  procedure set_register(offset:word;data:byte);
		  procedure set_loop_kadpcm(data:byte);
		  procedure set_pan(data:byte);
		  procedure update_pan_volume;
		  procedure key_on;
		  procedure key_off;
		  procedure play;
		  function voice_playing:boolean;
		  function read_rom:byte;
	private
		  // live state
		  position:dword;
		  pan_volume:array[0..1] of word;
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
		  kadpcm:boolean;
      rom:pbyte;
      rom_size:dword;
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
   private
      // configuration
	    rgnoverride:byte;
	    // live state
	    portdata:array[0..3] of byte;
	    keyon:byte;
	    mode:byte;
      voice:array[0..3] of tKDSC_Voice;
      ntimer,tsample_num2:byte;
      buffer:array[0..1,0..4] of integer;
      posicion:byte;
      procedure internal_update;
  end;

var
  k053260_0:tk053260_chip;

procedure internal_update_k053260;

implementation
const
  CLOCKS_PER_SAMPLE=32;

constructor tk053260_chip.create(clock:dword;rom:pbyte;size:dword;amp:single);
var
  f:byte;
begin
  for f:=0 to 3 do voice[f]:=tKDSC_Voice.create(rom,size);
  self.ntimer:=init_timer(sound_status.cpu_num,sound_status.cpu_clock/(clock/CLOCKS_PER_SAMPLE),internal_update_k053260,true);
  self.tsample_num:=init_channel;
  self.tsample_num2:=init_channel;
  self.amp:=amp;
end;

destructor tk053260_chip.free;
var
  f:byte;
begin
  for f:=0 to 3 do self.voice[f].free;
end;

procedure tk053260_chip.reset;
var
  f:byte;
begin
	for f:=0 to 3 do self.voice[f].voice_reset;
  self.posicion:=0;
  for f:=0 to 4 do begin
    self.buffer[0,f]:=0;
    self.buffer[1,f]:=0;
  end;
end;

function tk053260_chip.main_read(direccion:byte):byte;
begin
  main_read:=self.portdata[2+(direccion and 1)];
end;

procedure tk053260_chip.main_write(direccion,valor:byte);
begin
  portdata[direccion and 1]:=valor;
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

procedure tk053260_chip.update;
var
  out1,out2:integer;
  f:byte;
begin
out1:=0;
out2:=0;
if self.posicion<>0 then begin
   for f:=0 to (self.posicion-1) do begin
       out1:=out1+self.buffer[0,f];
       out2:=out2+self.buffer[1,f];
   end;
   out1:=round(out1/self.posicion);
   out2:=round(out2/self.posicion);
   if out1<-32767 then out1:=-32767
      else if out1>32767 then out1:=32767;
   if out2<-32767 then out2:=-32767
      else if out2>32767 then out2:=32767;
end;
//Channel 1
tsample[self.tsample_num,sound_status.posicion_sonido]:=round(out1*self.amp);
if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=round(out1*self.amp);
//Channel 2
tsample[self.tsample_num2,sound_status.posicion_sonido]:=round(out2*self.amp);
if sound_status.stereo then tsample[self.tsample_num2,sound_status.posicion_sonido+1]:=round(out2*self.amp);
self.posicion:=0;
fillchar(self.buffer[0,0],sizeof(integer)*5,0);
fillchar(self.buffer[1,0],sizeof(integer)*5,0);
end;

procedure internal_update_k053260;
begin
  k053260_0.internal_update;
end;

function sshr(num:int64;fac:byte):int64;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

procedure tk053260_chip.internal_update;
var
  f:byte;
begin
if (self.mode and 2)<>0 then begin
			for f:=0 to 3 do begin
				if (self.voice[f].voice_playing) then self.voice[f].play;
        self.buffer[0,self.posicion]:=self.buffer[0,self.posicion]+sshr(self.voice[f].out1,1);
        self.buffer[1,self.posicion]:=self.buffer[1,self.posicion]+sshr(self.voice[f].out2,1);
			end;
end;
self.posicion:=self.posicion+1;
end;

//KDSC Voice
constructor tKDSC_Voice.create(adpcm_rom:pbyte;size:dword);
begin
  self.rom:=adpcm_rom;
  self.rom_size:=size;
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
	self.is_playing:=false;
	self.start:=0;
	self.length:=0;
	self.pitch:=0;
	self.volume:=0;
	self.pan:=0;
	self.loop:=false;
	self.kadpcm:=false;
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
begin
	self.pan_volume[0]:=self.volume*(8-self.pan);
	self.pan_volume[1]:=self.volume*self.pan;
end;

procedure tKDSC_Voice.key_on;
begin
{	if (self.start >= m_device->m_rom_size)
		logerror("K053260: Attempting to start playing past the end of the ROM ( start = %06x, length = %06x )\n", m_start, m_length);

	else if (m_start + m_length >= m_device->m_rom_size)
		logerror("K053260: Attempting to play past the end of the ROM ( start = %06x, length = %06x )\n",
					m_start, m_length);

	else }
		if self.kadpcm then self.position:=1
      else self.position:=0; // for kadpcm low bit is nybble offset, so must start at 1 due to preincrement
		self.counter:=$1000-CLOCKS_PER_SAMPLE; // force update on next sound_stream_update
		self.output:=0;
		self.is_playing:=true;
end;

procedure tKDSC_Voice.key_off;
begin
	self.position:=0;
	self.output:=0;
	self.is_playing:=false;
end;

procedure tKDSC_Voice.play;
const
  kadpcm_table:array[0..15] of shortint=(0,1,2,4,8,16,32,64,-128,-64,-32,-16,-8,-4,-2,-1);
var
  bytepos:dword;
  romdata:byte;
begin
	self.counter:=self.counter+CLOCKS_PER_SAMPLE;
	while (self.counter>=$1000) do begin
		self.counter:=self.counter-$1000+self.pitch;
    self.position:=self.position+1;
    if self.kadpcm then bytepos:=self.position shr 1
      else bytepos:=self.position shr 0;
		{Yes, _pre_increment. Playback must start 1 byte position after the
		start address written to the register, or else ADPCM sounds will
		have DC offsets (e.g. TMNT2 theme song) or will overflow and be
		distorted (e.g. various Vendetta sound effects)
		The "headers" in the Simpsons and Vendetta sound ROMs provide
		further evidence of this quirk (the start addresses listed in the
		ROM header are all 1 greater than the addresses the CPU writes
		into the register) }
		if (bytepos>self.length) then begin
			if (self.loop) then begin
        self.position:=0;
        self.output:=0;
        bytepos:=0;
			end else begin
				self.is_playing:=false;
				exit;
			end;
		end;
		romdata:=self.rom[self.start+bytepos];
		if (self.kadpcm) then begin
			if (self.position and 1)<>0 then romdata:=romdata shr 4; // decode low nybble, then high nybble
			self.output:=self.output+kadpcm_table[romdata and $f];
    end else begin
			self.output:=romdata;
    end;
    self.out1:=self.output*self.pan_volume[0];
	  self.out2:=self.output*self.pan_volume[1];
end;
end;

function tKDSC_Voice.read_rom:byte;
var
  offs:dword;
begin
	offs:=self.start+self.position;
	self.position:=(self.position+1) and $ffff;
	if (offs>=self.rom_size) then begin
		//logerror("%s: K053260: Attempting to read past the end of the ROM (offs = %06x, size = %06x)\n",
		//			m_device->machine().describe_context(), offs, m_device->m_rom_size);
		read_rom:=0;
    exit;
	end;
	read_rom:=self.rom[offs];
end;

end.
