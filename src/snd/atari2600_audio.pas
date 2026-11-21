unit atari2600_audio;
interface

type
  ttia_audio_sample_callback=procedure;

procedure tia_audio_init(color_clock:cardinal;attach_engine:boolean=true);
procedure tia_audio_set_clock(color_clock:cardinal);
procedure tia_audio_reset;
procedure tia_audio_write(reg,value:byte);
procedure tia_audio_tick;
procedure tia_audio_set_sample_callback(callback:ttia_audio_sample_callback);

implementation
uses sound_engine;

type
  ttia_audio_channel=record
    control,frequency,volume:byte;
    divider,divide3,divide31:integer;
    poly4,poly5,poly9:word;
    output:boolean;
  end;
  ttia_audio_state=record
    channel:array[0..1]of ttia_audio_channel;
    color_clock,sample_phase:cardinal;
    base_divider,sample_count:integer;
    sample_sum:int64;
    last_input,highpass:integer;
    engine_channel:byte;
    attached:boolean;
  end;

var
  tia_audio:ttia_audio_state;
  sample_callback:ttia_audio_sample_callback=nil;

procedure tia_audio_set_clock(color_clock:cardinal);
begin
  if color_clock=0 then exit;
  if tia_audio.color_clock<>0 then tia_audio.sample_phase:=(int64(tia_audio.sample_phase)*color_clock) div tia_audio.color_clock;
  tia_audio.color_clock:=color_clock;
end;

procedure tia_audio_set_sample_callback(callback:ttia_audio_sample_callback);
begin
  sample_callback:=callback;
end;

procedure tia_audio_reset;
var
  i:integer;
  clock:cardinal;
  ch:byte;
  a:boolean;
begin
  clock:=tia_audio.color_clock;
  ch:=tia_audio.engine_channel;
  a:=tia_audio.attached;
  FillChar(tia_audio,SizeOf(tia_audio),0);
  tia_audio.color_clock:=clock;
  tia_audio.engine_channel:=ch;
  tia_audio.attached:=a;
  for i:=0 to 1 do begin
    tia_audio.channel[i].poly4:=$f;
    tia_audio.channel[i].poly5:=$1f;
    tia_audio.channel[i].poly9:=$1ff;
    tia_audio.channel[i].divide3:=3;
    tia_audio.channel[i].divider:=1;
  end;
end;

procedure tia_audio_init(color_clock:cardinal;attach_engine:boolean);
begin
  // Each owner explicitly connects its extra sound chips after initialization.
  sample_callback:=nil;
  tia_audio.color_clock:=color_clock;
  tia_audio.attached:=attach_engine;
  if attach_engine then tia_audio.engine_channel:=init_channel;
  tia_audio_reset;
end;

procedure tia_audio_write(reg,value:byte);
var
  n:integer;
begin
  if ((reg<$15) or (reg>$1a)) then exit;
  n:=(reg-$15) and 1;
  case reg of
    $15,$16:begin
              tia_audio.channel[n].control:=value and $f;
              if ((tia_audio.channel[n].control=0) or (tia_audio.channel[n].control=11)) then tia_audio.channel[n].output:=true;
            end;
    $17,$18:tia_audio.channel[n].frequency:=value and $1f;
    $19,$1a:tia_audio.channel[n].volume:=value and $f;
  end;
end;

procedure tia_audio_tick;
procedure emit_sample(value:integer);
var
  pos:integer;
begin
  // AC coupling removes the large unipolar DAC DC component.
  tia_audio.highpass:=value-tia_audio.last_input+(tia_audio.highpass*995)div 1000;
  tia_audio.last_input:=value;
  if not tia_audio.attached then exit;
  pos:=sound_status.posicion_sonido;
  if ((sound_status.long_sample=0) or (pos>=LONG_MAX_AUDIO)) then exit;
  // All chips must fill the current PCM slot before play_sonido can flush it.
  if (@sample_callback<>nil) then sample_callback;
  tsample[tia_audio.engine_channel,pos]:=tia_audio.highpass;
  if pos+1>=sound_status.long_sample then play_sonido
    else sound_status.posicion_sonido:=pos+1;
end;
function shift_poly(value:word;bits,tap:integer):word;
begin
  result:=(value shr 1) or (((value xor (value shr tap)) and 1) shl (bits-1));
end;
procedure step_channel(n:integer);
var
  gate,old5,new5:boolean;
  period:integer;
begin
    if ((tia_audio.channel[n].control=0) or (tia_audio.channel[n].control=11)) then begin
      tia_audio.channel[n].output:=true;
      exit;
    end;
    dec(tia_audio.channel[n].divider);
    if tia_audio.channel[n].divider>0 then exit;
    period:=tia_audio.channel[n].frequency+1;
    if tia_audio.channel[n].control in [12,13,14] then period:=period*3;
    tia_audio.channel[n].divider:=period;
    old5:=(tia_audio.channel[n].poly5 and 1)<>0;
    tia_audio.channel[n].poly5:=shift_poly(tia_audio.channel[n].poly5,5,2);
    new5:=(tia_audio.channel[n].poly5 and 1)<>0;
    tia_audio.channel[n].divide31:=(tia_audio.channel[n].divide31+1)mod 31;
    gate:=true;
    case tia_audio.channel[n].control of
      2,6,10,14:gate:=(tia_audio.channel[n].divide31=1)or(tia_audio.channel[n].divide31=19);
      3,7:gate:=new5;
      15:begin
        gate:=false;
        if old5<>new5 then begin
          dec(tia_audio.channel[n].divide3);
          if tia_audio.channel[n].divide3=0 then begin
            tia_audio.channel[n].divide3:=3;
            gate:=true;
          end;
        end;
      end;
    end;
    if not(gate) then exit;
    case tia_audio.channel[n].control of
      1,2,3:begin
              tia_audio.channel[n].poly4:=shift_poly(tia_audio.channel[n].poly4,4,1);
              tia_audio.channel[n].output:=(tia_audio.channel[n].poly4 and 1)<>0;
            end;
      4,5,6,7,10,12,13,14,15:tia_audio.channel[n].output:=not(tia_audio.channel[n].output);
      8:begin
          tia_audio.channel[n].poly9:=shift_poly(tia_audio.channel[n].poly9,9,4);
          tia_audio.channel[n].output:=(tia_audio.channel[n].poly9 and 1)<>0;
        end;
      9:tia_audio.channel[n].output:=new5;
    end;
end;
function tia_audio_level:integer;
var
  i:integer;
begin
  result:=0;
  for i:=0 to 1 do
    if tia_audio.channel[i].output then inc(result,integer(tia_audio.channel[i].volume)*512);
end;
var
  sample:integer;
begin
  // TIA audio reference = color clock / 114; PAL pitch follows its own crystal.
  Inc(tia_audio.base_divider);
  if tia_audio.base_divider=114 then begin
    tia_audio.base_divider:=0;
    step_channel(0);
    step_channel(1);
  end;
  inc(tia_audio.sample_sum,tia_audio_level);
  inc(tia_audio.sample_count);
  inc(tia_audio.sample_phase,FREQ_BASE_AUDIO);
  if tia_audio.sample_phase>=tia_audio.color_clock then begin
    dec(tia_audio.sample_phase,tia_audio.color_clock);
    sample:=tia_audio.sample_sum div tia_audio.sample_count;
    tia_audio.sample_sum:=0;
    tia_audio.sample_count:=0;
    emit_sample(sample);
  end;
end;

end.

