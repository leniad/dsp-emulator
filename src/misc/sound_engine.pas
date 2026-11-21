unit sound_engine;

interface
uses {$ifndef fpc}mmsystem,{$else}lib_sdl2,{$endif}
     timer_engine,dialogs,main_engine;

const
        MAX_AUDIO_BUFFER=$f;
        MAX_CANALES=9;
        LONG_MAX_AUDIO=3000;  //Tapper necesita esto tan alto...
        FREQ_BASE_AUDIO=44100;
        M_PI=3.1415926535;

type
        tipo_sonido=record
          posicion_sonido:word;
          {$ifndef fpc}
          audio:array[0..MAX_CANALES-1] of HWAVEOUT;
          {$endif}
          cpu_clock:dword;
          cpu_num:byte;
          num_buffer:byte;
          long_sample:word;
          canales_usados:integer;
          stereo,sonido_activo,hay_tsonido:boolean;
          output_paused:boolean;
          output_discarding:boolean;
          filter_call:array[0..MAX_CANALES-1] of procedure(canal:byte);
        end;
        snd_chip_class=class
          public
            function get_sample_num:byte;
          protected
            tsample_num:byte;
            amp:single;
            clock:dword;
        end;

var
        sound_status:tipo_sonido;
        update_sound_proc:exec_type_simple;
        sound_engine_timer:byte;
        {$ifndef fpc}
        tsample:array[0..MAX_CANALES-1,0..LONG_MAX_AUDIO-1] of smallint;
        cab_audio:array[0..MAX_CANALES-1,0..MAX_AUDIO_BUFFER-1] of wavehdr;
        {$else}
        sound_device:libSDL_AudioDeviceID;
        tsample:array[0..MAX_CANALES-1,0..LONG_MAX_AUDIO-1] of integer;
        {$endif}
        sample_final:array[0..LONG_MAX_AUDIO-1] of smallint;

function iniciar_audio(stereo_sound:boolean):boolean;
procedure sound_engine_init(num_cpu:byte;clock:dword;update_call:exec_type_simple);
procedure sound_engine_close;
procedure sound_engine_change_clock(clock:dword);
procedure reset_audio;
procedure play_sonido;
procedure close_audio;
procedure sound_update_internal;
function init_channel:byte;

implementation

const AUDIO_QUEUE_BLOCKS=3;
      AUDIO_PREFILL_BLOCKS=2;

{$ifndef fpc}
var
    device_open:boolean;
    header_prepared:array[0..MAX_AUDIO_BUFFER-1] of boolean;
    {$endif}

function snd_chip_class.get_sample_num:byte;
begin
  Result:=self.tsample_num;
end;

procedure clear_samples;
begin
  FillChar(tsample,SizeOf(tsample),0);
  FillChar(sample_final,SizeOf(sample_final),0);
end;

procedure flush_output;
begin
  {$ifndef fpc}
  if device_open then begin
    waveOutReset(sound_status.audio[0]);
    waveOutPause(sound_status.audio[0]);
  end;
  {$else}
  if sound_device<>0 then begin
    SDL_PauseAudioDevice(sound_device,1);
    SDL_ClearQueuedAudio(sound_device);
  end;
  {$endif}
  sound_status.output_paused:=true;
  sound_status.num_buffer:=0;
end;

procedure close_audio;
{$ifndef fpc}
var f:integer;
{$endif}
begin
  sound_status.hay_tsonido:=false;
  {$ifndef fpc}
  if device_open then waveOutReset(sound_status.audio[0]);
  for f:=0 to MAX_AUDIO_BUFFER-1 do begin
    if header_prepared[f] then begin
      // Never free a buffer still owned by the output device.
      if waveOutUnprepareHeader(sound_status.audio[0],@cab_audio[0,f],SizeOf(WAVEHDR))<>0 then continue;
      header_prepared[f]:=false;
    end;
    if cab_audio[0,f].lpData<>nil then begin
      FreeMem(cab_audio[0,f].lpData);
      cab_audio[0,f].lpData:=nil;
    end;
  end;
  if device_open then
    if waveOutClose(sound_status.audio[0])=0 then begin
      device_open:=false;
      sound_status.audio[0]:=0;
    end;
  {$else}
  if sound_device<>0 then begin
    SDL_CloseAudioDevice(sound_device);
    sound_device:=0;
  end;
  {$endif}
  sound_status.posicion_sonido:=0;
  sound_status.output_paused:=true;
  sound_status.output_discarding:=false;
  clear_samples;
end;

function iniciar_audio(stereo_sound:boolean):boolean;
var channels,frames:integer;
{$ifndef fpc}
    format:TWaveFormatEx;
    f:integer;
{$else}
    wanted,have:libsdl_AudioSpec;
{$endif}
begin
  Result:=false;
  close_audio;
  {$ifndef fpc}
  if device_open then exit;
  {$endif}
  sound_status.long_sample:=0;
  sound_status.stereo:=stereo_sound;
  channels:=1+byte(stereo_sound);
  if not(llamadas_maquina.fps_max>0) then exit;
  // Check before rounding or narrowing to Word.
  if (FREQ_BASE_AUDIO/llamadas_maquina.fps_max)>(LONG_MAX_AUDIO div channels) then exit;
  frames:=Round(FREQ_BASE_AUDIO/llamadas_maquina.fps_max);
  if (frames<1) or (frames>LONG_MAX_AUDIO div channels) then exit;
  sound_status.long_sample:=frames*channels;
  {$ifndef fpc}
  FillChar(format,SizeOf(format),0);
  format.wFormatTag:=WAVE_FORMAT_PCM;
  format.nChannels:=channels;
  format.nSamplesPerSec:=FREQ_BASE_AUDIO;
  format.wBitsPerSample:=16;
  format.nBlockAlign:=channels*SizeOf(smallint);
  format.nAvgBytesPerSec:=FREQ_BASE_AUDIO*format.nBlockAlign;
  if waveOutOpen(@sound_status.audio[0],WAVE_MAPPER,@format,0,0,CALLBACK_NULL)<>0 then exit;
  device_open:=true;
  try
    for f:=0 to MAX_AUDIO_BUFFER-1 do begin
      FillChar(cab_audio[0,f],SizeOf(WAVEHDR),0);
      GetMem(cab_audio[0,f].lpData,sound_status.long_sample*SizeOf(smallint));
      cab_audio[0,f].dwBufferLength:=sound_status.long_sample*SizeOf(smallint);
      if waveOutPrepareHeader(sound_status.audio[0],@cab_audio[0,f],SizeOf(WAVEHDR))<>0 then begin
        close_audio;
        exit;
      end;
      header_prepared[f]:=true;
    end;
  except
    close_audio;
    raise;
  end;
  {$else}
  FillChar(wanted,SizeOf(wanted),0);
  FillChar(have,SizeOf(have),0);
  wanted.freq:=FREQ_BASE_AUDIO;
  wanted.format:=libAUDIO_S16;
  wanted.channels:=channels;
  // SDL counts sample frames, not interleaved channel values.
  wanted.samples:=512;
  wanted.callback:=nil;
  sound_device:=SDL_OpenAudioDevice(nil,0,@wanted,@have,0);
  if sound_device=0 then exit;
  if (have.freq<>wanted.freq) or (have.format<>wanted.format) or
      (have.channels<>wanted.channels) then begin
    close_audio;
    exit;
  end;
  {$endif}
  sound_status.hay_tsonido:=true;
  reset_audio;
  Result:=true;
end;

procedure queue_output;
var
  block_bytes:cardinal;
{$ifndef fpc}
  f,slot,pending:integer;
{$else}
  queued:cardinal;
{$endif}
begin
  block_bytes:=sound_status.long_sample*SizeOf(smallint);
  {$ifndef fpc}
  pending:=0;
  for f:=0 to MAX_AUDIO_BUFFER-1 do
    if (cab_audio[0,f].dwFlags and WHDR_INQUEUE)<>0 then inc(pending);
  if pending>=AUDIO_QUEUE_BLOCKS then exit;
  slot:=sound_status.num_buffer;
  for f:=0 to MAX_AUDIO_BUFFER-1 do begin
    if (cab_audio[0,slot].dwFlags and WHDR_INQUEUE)=0 then break;
    slot:=(slot+1) mod MAX_AUDIO_BUFFER;
  end;
  if (cab_audio[0,slot].dwFlags and WHDR_INQUEUE)<>0 then exit;
  if pending=0 then begin
    waveOutPause(sound_status.audio[0]);
    sound_status.output_paused:=true;
  end;
  copymemory(cab_audio[0,slot].lpData,@sample_final[0],block_bytes);
  if waveOutWrite(sound_status.audio[0],@cab_audio[0,slot],SizeOf(WAVEHDR))<>0 then begin
    close_audio;
    exit;
  end;
  sound_status.num_buffer:=(slot+1) mod MAX_AUDIO_BUFFER;
  if sound_status.output_paused and (pending+1>=AUDIO_PREFILL_BLOCKS) then
    if waveOutRestart(sound_status.audio[0])=0 then sound_status.output_paused:=false;
  {$else}
  queued:=SDL_GetQueuedAudioSize(sound_device);
  // Bound latency without clearing partially played blocks. At saturation
  // discard the newly generated block; normal speed should not reach this.
  if queued+block_bytes>AUDIO_QUEUE_BLOCKS*block_bytes then exit;
  if queued=0 then begin
    SDL_PauseAudioDevice(sound_device,1);
    sound_status.output_paused:=true;
  end;
  if SDL_QueueAudio(sound_device,@sample_final[0],block_bytes)<>0 then begin
    close_audio;
    exit;
  end;
  if sound_status.output_paused and (SDL_GetQueuedAudioSize(sound_device)>=AUDIO_PREFILL_BLOCKS*block_bytes) then begin
    SDL_PauseAudioDevice(sound_device,0);
    sound_status.output_paused:=false;
  end;
  {$endif}
end;

procedure play_sonido;
var
    f,h,last_channel:integer;
    mixed:int64;
begin
  if sound_status.hay_tsonido then begin
    if not(sound_status.sonido_activo) then begin
      if not(sound_status.output_discarding) then flush_output;
      sound_status.output_discarding:=true;
    end else if ((sound_status.long_sample>0) and (sound_status.long_sample<=LONG_MAX_AUDIO)) then begin
      sound_status.output_discarding:=false;
      last_channel:=sound_status.canales_usados;
      if last_channel>=MAX_CANALES then last_channel:=MAX_CANALES-1;
      for f:=0 to last_channel do
        if Assigned(sound_status.filter_call[f]) then sound_status.filter_call[f](f);
      for h:=0 to sound_status.long_sample-1 do begin
        mixed:=0;
        for f:=0 to last_channel do mixed:=mixed+tsample[f,h];
        if mixed>32767 then mixed:=32767
          else if mixed< -32768 then mixed:=-32768;
        sample_final[h]:=mixed;
      end;
      queue_output;
    end;
  end;
  // Also discard old samples while muted or when no device is available.
  clear_samples;
  sound_status.posicion_sonido:=0;
end;

procedure sound_engine_init(num_cpu:byte;clock:dword;update_call:exec_type_simple);
begin
  sound_status.cpu_clock:=clock;
  sound_status.cpu_num:=num_cpu;
  sound_engine_timer:=timers.init(num_cpu,clock/FREQ_BASE_AUDIO,sound_update_internal,nil,true);
  update_sound_proc:=update_call;
end;

procedure sound_engine_close;
begin
  sound_status.cpu_clock:=0;
  sound_status.cpu_num:=$ff;
  sound_engine_timer:=$ff;
  update_sound_proc:=nil;
end;

procedure sound_engine_change_clock(clock:dword);
begin
  timers.timer[sound_engine_timer].time_final:=clock/FREQ_BASE_AUDIO;
  sound_status.cpu_clock:=clock;
  close_audio;
  iniciar_audio(sound_status.stereo);
end;

procedure sound_update_internal;
var stride:integer;
begin
  if (sound_status.long_sample=0) or (sound_status.long_sample>LONG_MAX_AUDIO) then exit;
  stride:=1+Ord(sound_status.stereo);
  // Validate the write position before the callback touches tsample.
  if sound_status.posicion_sonido+stride>sound_status.long_sample then play_sonido;
  if Assigned(update_sound_proc) then update_sound_proc;
  sound_status.posicion_sonido:=sound_status.posicion_sonido+stride;
  if sound_status.posicion_sonido>=sound_status.long_sample then play_sonido;
end;

procedure reset_audio;
begin
  flush_output;
  sound_status.posicion_sonido:=0;
  sound_status.output_discarding:=false;
  clear_samples;
end;

function init_channel:byte;
begin
  sound_status.canales_usados:=sound_status.canales_usados+1;
  if sound_status.canales_usados>=MAX_CANALES then MessageDlg('Utilizados mas canales de sonido de los disponibles!!', mtInformation,[mbOk], 0);
  init_channel:=sound_status.canales_usados;
end;

end.
