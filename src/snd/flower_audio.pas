unit flower_audio;

interface
uses sound_engine,timer_engine{$ifdef windows},windows{$endif};

const
  MAX_VOICES=8;
  DEFGAIN=48;
  MIXER_LOOKUP=MAX_VOICES*128;

type
  flower_sound_channel=record
    start_nibbles:array[0..5] of byte;
		raw_frequency:array[0..3] of byte;
		start_address:dword;
		position:dword;
		frequency:word;
		volume:byte;
		volume_bank:byte;
		effect:byte;
		enable:boolean;
		repeat_:boolean;
  end;
  flower_chip=class(snd_chip_class)
        constructor create(clock:dword);
        destructor free;
    public
        sample_rom:array[0..$7fff] of byte;
        sample_vol:array[0..$3fff] of byte;
        procedure reset;
        procedure write(direccion,valor:byte);
        procedure update;
    private
        channel_list:array[0..(MAX_VOICES-1)] of flower_sound_channel;
        mixer_table:array[0..(256*MAX_VOICES)-1] of smallint;
        buffer:array[0..1] of smallint;
        buffer_pos:byte;
        procedure make_mixer_table;
  end;

var
  flower_0:flower_chip;

implementation

function sshr(num:int64;fac:byte):int64;inline;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

procedure flower_chip.make_mixer_table;
var
  f:word;
  val:integer;
begin
	// fill in the table - 16 bit case
	for f:=0 to (MAX_VOICES*128)-1 do begin
		val:=(f*DEFGAIN*16) div MAX_VOICES;
		if (val>32767) then val:=32767;
		mixer_table[mixer_lookup+f]:=val;
		mixer_table[mixer_lookup-f]:=-val;
  end;
end;

procedure internal_update_flower;
var
  voice,volume,raw_sample:byte;
  frequency:word;
  res:integer;
begin
res:=0;
for voice:=0 to (MAX_VOICES-1) do begin
    if not(flower_0.channel_list[voice].enable) then continue;
		volume:=flower_0.channel_list[voice].volume;
		frequency:=flower_0.channel_list[voice].frequency;
    if flower_0.channel_list[voice].repeat_ then begin
				raw_sample:=flower_0.sample_rom[((flower_0.channel_list[voice].start_address shr 7) and $7e00) or ((flower_0.channel_list[voice].position shr 7) and $1ff)];
				// guess: cut off after a number of repetitions
				if ((flower_0.channel_list[voice].position shr 7) and $20000)<>0 then flower_0.channel_list[voice].enable:=false;
    end else begin
				raw_sample:=flower_0.sample_rom[((flower_0.channel_list[voice].start_address+flower_0.channel_list[voice].position) shr 7) and $7fff];
				if (raw_sample=$ff) then flower_0.channel_list[voice].enable:=false;
    end;
    volume:=volume or flower_0.channel_list[voice].volume_bank;
		res:=res+flower_0.sample_vol[((volume shl 8) or raw_sample) and $3fff]-$80;
    flower_0.channel_list[voice].position:=flower_0.channel_list[voice].position+frequency;
end;
flower_0.buffer[flower_0.buffer_pos]:=flower_0.mixer_table[MIXER_LOOKUP+res];
flower_0.buffer_pos:=flower_0.buffer_pos+1;
end;

constructor flower_chip.create(clock:dword);
begin
  self.make_mixer_table;
  self.tsample_num:=init_channel;
  timers.init(sound_status.cpu_num,sound_status.cpu_clock/(clock/2),internal_update_flower,nil,true);
end;

destructor flower_chip.free;
begin
end;

procedure flower_chip.reset;
var
  f:byte;
begin
for f:=0 to (MAX_VOICES-1) do begin
    channel_list[f].start_address:=0;
    channel_list[f].position:=0;
    channel_list[f].volume:=0;
    channel_list[f].enable:=false;
    channel_list[f].repeat_:=false;
end;
self.buffer_pos:=0;
self.buffer[0]:=0;
self.buffer[1]:=0;
end;

procedure flower_chip.write(direccion,valor:byte);
var
  ch,f:byte;
begin
  ch:=(direccion shr 3) and $7;
  case (direccion and $47) of
    0..3:begin //frequency_w
            channel_list[ch].raw_frequency[direccion and $3]:=valor and $f;
            channel_list[ch].frequency:=channel_list[ch].raw_frequency[2] shl 12;
	          channel_list[ch].frequency:=channel_list[ch].frequency or (channel_list[ch].raw_frequency[3] shl 8);
	          channel_list[ch].frequency:=channel_list[ch].frequency or (channel_list[ch].raw_frequency[0] shl 4);
	          channel_list[ch].frequency:=channel_list[ch].frequency or (channel_list[ch].raw_frequency[1] shl 0);
         end;
    4:channel_list[ch].repeat_:=(valor and $10)<>0;
	  5:; //unk_w
	  7:channel_list[ch].volume:=valor shr 4;
	  $40..$45:begin
            channel_list[ch].start_nibbles[direccion and 7]:=valor and $f;
	          if ((direccion and 7)=4) then channel_list[ch].effect:=valor shr 4;
    end;
	  $47:begin
            channel_list[ch].enable:=true;
	          channel_list[ch].volume_bank:=(valor and 3) shl 4;
	          channel_list[ch].start_address:=0;
	          channel_list[ch].position:=0;
            for f:=5 downto 0 do channel_list[ch].start_address:=(channel_list[ch].start_address shl 4) or channel_list[ch].start_nibbles[f];
        end;
  end;
end;

procedure flower_chip.update;
var
  f:byte;
  res:integer;
begin
  res:=0;
  for f:=0 to (self.buffer_pos-1) do res:=res+self.buffer[f];
  res:=sshr(res,self.buffer_pos-1);
  if res>32767 then res:=32767
    else if res<-32767 then res:=-32767;
  tsample[self.tsample_num,sound_status.posicion_sonido]:=res;
  flower_0.buffer_pos:=0;
end;

end.
