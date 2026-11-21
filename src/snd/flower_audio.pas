unit flower_audio;

interface
uses main_engine,sound_engine;

const
  MAX_VOICES=8;

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
        mix_sum:Int64;
        mix_count:Int64;
        last_sample:smallint;
        procedure make_mixer_table;
  end;

var
  flower_0:flower_chip;

implementation
uses timer_engine;

const
  DEFGAIN=15;
  MIXER_LOOKUP=MAX_VOICES*128;

procedure flower_chip.make_mixer_table;
var
  f:integer;
  val:integer;
begin
  for f:=-MIXER_LOOKUP to MIXER_LOOKUP-1 do begin
    val:=(f*DEFGAIN*16) div MAX_VOICES;
    if val>32767 then val:=32767
      else if val<-32767 then val:=-32767;
    mixer_table[MIXER_LOOKUP+f]:=val;
  end;
end;

procedure internal_update_flower;
var
  voice,volume,raw_sample:byte;
  frequency,volume_index:word;
  res:integer;
begin
res:=0;
for voice:=0 to (MAX_VOICES-1) do begin
    if not(flower_0.channel_list[voice].enable) then continue;
		volume:=flower_0.channel_list[voice].volume;
		frequency:=flower_0.channel_list[voice].frequency;
    if flower_0.channel_list[voice].repeat_ then begin
				raw_sample:=flower_0.sample_rom[((flower_0.channel_list[voice].start_address shr 7) and $7e00) or ((flower_0.channel_list[voice].position shr 7) and $1ff)];
        if (flower_0.channel_list[voice].volume_bank and $10)=0 then begin
          flower_0.channel_list[voice].enable:=false;
          continue;
        end;
    end else begin
				raw_sample:=flower_0.sample_rom[((flower_0.channel_list[voice].start_address+flower_0.channel_list[voice].position) shr 7) and $7fff];
				if raw_sample=$ff then begin
          flower_0.channel_list[voice].enable:=false;
          continue; // Terminator is not PCM data.
        end;
    end;
    volume_index:=((word(volume or flower_0.channel_list[voice].volume_bank) and $2f) shl 8) or (((flower_0.channel_list[voice].position shr 6) and 1) shl 12);
    res:=res+integer(flower_0.sample_vol[(volume_index or raw_sample) and $3fff])-$80;
    flower_0.channel_list[voice].position:=flower_0.channel_list[voice].position+frequency;
end;
flower_0.mix_sum:=flower_0.mix_sum+flower_0.mixer_table[MIXER_LOOKUP+res];
flower_0.mix_count:=flower_0.mix_count+1;
end;

constructor flower_chip.create(clock:dword);
begin
  self.reset;
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
self.mix_sum:=0;
self.mix_count:=0;
self.last_sample:=0;
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
  res:integer;
begin
  if self.mix_count>0 then begin
    res:=self.mix_sum div self.mix_count;
    if res>32767 then res:=32767
      else if res<-32767 then res:=-32767;
    self.last_sample:=res;
  end;
  tsample[self.tsample_num,sound_status.posicion_sonido]:=self.last_sample;
  self.mix_sum:=0;
  self.mix_count:=0;
end;

end.

