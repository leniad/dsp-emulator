unit sound_engine;

interface
uses {$ifdef windows}windows,{$endif}{$ifndef fpc}mmsystem,{$endif}lib_sdl2,timer_engine,dialogs;

const
        MAX_AUDIO_BUFFER=$f;
        MAX_CANALES=9;
        LONG_MAX_AUDIO=1800;
        FREQ_BASE_AUDIO=44100;

type
        tipo_sonido=record
          posicion_sonido:word;
          {$ifndef fpc}
          audio:array[0..MAX_CANALES-1] of HWAVEOUT;
          {$endif}
          cpu_clock:dword;
          cpu_num:byte;
          num_buffer,calidad_audio:byte;
          long_sample,sample_final:word;
          canales_usados:integer;
          stereo,hay_sonido,hay_tsonido:boolean;
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
        sample_final:array[0..LONG_MAX_AUDIO-1] of smallint;
        {$endif}

function iniciar_audio(stereo_sound:boolean):boolean;
procedure sound_engine_init(num_cpu:byte;clock:dword;update_call:exec_type_simple);
procedure sound_engine_change_clock(clock:single);
procedure reset_audio;
procedure play_sonido;
procedure close_audio;
procedure sound_update_internal;
function init_channel:byte;

implementation
uses main_engine;

function snd_chip_class.get_sample_num:byte;
begin
  get_sample_num:=self.tsample_num;
end;

{$ifndef fpc}
function iniciar_audio(stereo_sound:boolean):boolean;
var
  format:TWaveFormatEx;
  f,g:byte;
  canales:byte;
begin
iniciar_audio:=false;
sound_status.hay_tsonido:=false;
sound_status.hay_sonido:=true;
if stereo_sound then begin
    sound_status.stereo:=true;
    canales:=2;
end else begin
    sound_status.stereo:=false;
    canales:=1;
end;
fillchar(Format,SizeOf(TWaveFormatEx),0);
Format.wFormatTag:=WAVE_FORMAT_PCM;
Format.nChannels:=canales;
Format.nSamplesPerSec:=FREQ_BASE_AUDIO;
case sound_status.calidad_audio of
  0:Format.nSamplesPerSec:=11025;
  1:Format.nSamplesPerSec:=22050;
  3:sound_status.hay_sonido:=false;
end;
Format.wBitsPerSample:=16;
Format.nBlockAlign:=Format.nChannels*(Format.wBitsPerSample div 8);
Format.nAvgBytesPerSec:=Format.nSamplesPerSec*Format.nBlockAlign;
format.cbSize:=0;
sound_status.long_sample:=round(FREQ_BASE_AUDIO/llamadas_maquina.fps_max)*canales;
sound_status.sample_final:=round(Format.nSamplesPerSec/llamadas_maquina.fps_max)*canales;
for g:=0 to MAX_CANALES-1 do begin
  if not((waveoutopen(@sound_status.audio[g],WAVE_MAPPER,@format,0,1,CALLBACK_NULL))=0) then exit;
  For f:=0 To MAX_AUDIO_BUFFER-1 do begin
        getmem(cab_audio[g][f].lpData,sound_status.sample_final*2);
        cab_audio[g][f].dwBufferLength:=sound_status.sample_final*2;
        cab_audio[g][f].dwUser:=0;
        cab_audio[g][f].dwFlags:=0;
        cab_audio[g][f].dwLoops:=0;
        cab_audio[g][f].lpNext:=nil;
        if not(waveOutPrepareHeader(sound_status.audio[g],@cab_audio[g][f],uint(sizeof(WAVEHDR)))=0) then exit;
  end;
end;
reset_audio;
iniciar_audio:=true;
sound_status.hay_tsonido:=true;
end;

procedure close_audio;
var
  j,f:byte;
begin
if not(sound_status.hay_tsonido) then exit;
for j:=0 to MAX_CANALES-1 do begin
  waveOutReset(sound_status.audio[j]);
  for f:=0 to MAX_AUDIO_BUFFER-1 do begin
    waveoutunprepareheader(sound_status.audio[j],@cab_audio[j][f],sizeof(cab_audio[j][f]));
    freemem(cab_audio[j][f].lpData);
    cab_audio[j][f].lpData:=nil;
  end;
  waveoutclose(sound_status.audio[j]);
end;
end;
{$else}
function iniciar_audio(stereo_sound:boolean):boolean;
var
  wanted,have:libsdl_AudioSpec;
  canales:byte;
  audio_rate:dword;
begin
iniciar_audio:=false;
sound_status.hay_tsonido:=false;
sound_status.hay_sonido:=true;
//abrir el audio
if stereo_sound then begin
    sound_status.stereo:=true;
    canales:=2;
end else begin
    sound_status.stereo:=false;
    canales:=1;
end;
sound_status.long_sample:=round(FREQ_BASE_AUDIO/llamadas_maquina.fps_max)*canales;
audio_rate:=FREQ_BASE_AUDIO;
case sound_status.calidad_audio of
  0:audio_rate:=11025;
  1:audio_rate:=22050;
  3:sound_status.hay_sonido:=false;
end;
sound_status.sample_final:=round(audio_rate/llamadas_maquina.fps_max)*canales;
wanted.freq:=audio_rate;
wanted.format:=libAUDIO_S16;
wanted.channels:=canales;
wanted.samples:=sound_status.sample_final;
wanted.silence:=0;
wanted.size_:=0; //wanted.size:=sound_status.sample_final*2;
wanted.callback:=nil;//sound_call_back;
wanted.userdata:=nil;
wanted.padding:=0;
sound_device:=SDL_OpenAudioDevice(nil,0,@wanted,@have,0);
if (sound_device=0) then exit;
SDL_PauseAudioDevice(sound_device,0);
SDL_ClearQueuedAudio(sound_device);
sound_status.hay_tsonido:=true;
reset_audio;
iniciar_audio:=true;
end;

procedure close_audio;
begin
SDL_CloseAudioDevice(sound_device);
end;
{$endif}

procedure play_sonido;
var
  f{$ifdef fpc},j{$endif}:integer;
  g,h:word;
begin
if ((sound_status.hay_tsonido) and (sound_status.hay_sonido)) then begin
for f:=0 to sound_status.canales_usados do begin
  h:=0;
  //Resampleado
  case sound_status.calidad_audio of
    0:if sound_status.stereo then begin
        g:=0;
        while g<sound_status.long_sample do begin
          tsample[f,g]:=(tsample[f,h]+tsample[f,h+2]+tsample[f,h+4]+tsample[f,h+6]) shr 2;
          tsample[f,g+1]:=(tsample[f,h+1]+tsample[f,h+3]+tsample[f,h+5]+tsample[f,h+7]) shr 2;
          h:=h+8;
          g:=g+2;
        end;
      end else begin
         for g:=0 to (sound_status.long_sample-1) do begin
          tsample[f,g]:=(tsample[f,h]+tsample[f,h+1]+tsample[f,h+2]+tsample[f,h+3]) shr 2;
          h:=h+4;
         end;
      end;
    1:if sound_status.stereo then begin
          g:=0;
          while g<sound_status.long_sample do begin
            tsample[f,g]:=(tsample[f,h]+tsample[f,h+2]) shr 1;
            tsample[f,g+1]:=(tsample[f,h+1]+tsample[f,h+3]) shr 1;
            h:=h+4;
            g:=g+2;
          end;
       end else begin
          for g:=0 to (sound_status.long_sample-1) do begin
            tsample[f,g]:=(tsample[f,h]+tsample[f,h+1]) shr 1;
            h:=h+2;
          end;
      end;
    2:;
  end;
  if @sound_status.filter_call[f]<>nil then sound_status.filter_call[f](f);
  {$ifndef fpc}
  copymemory(cab_audio[f][sound_status.num_buffer].lpData,@tsample[f],sound_status.sample_final*sizeof(smallint));
  waveOutWrite(sound_status.audio[f],@cab_audio[f][sound_status.num_buffer],sizeof(WAVEHDR));
  fillchar(tsample[f],LONG_MAX_AUDIO*sizeof(smallint),0);
  {$endif}
end;
{$ifdef fpc}
if main_screen.rapido then SDL_ClearQueuedAudio(sound_device);
for h:=0 to (sound_status.sample_final-1) do begin
    j:=0;
    for f:=0 to sound_status.canales_usados do j:=j+tsample[f,h];
    j:=j div (sound_status.canales_usados+1);
    if j<-32767 then j:=-32767
       else if j>32768 then j:=32768;
    sample_final[h]:=j;
end;
SDL_QueueAudio(sound_device,@sample_final[0],sound_status.sample_final*sizeof(smallint));
for f:=0 to sound_status.canales_usados do fillchar(tsample[f],LONG_MAX_AUDIO*sizeof(integer),0);
{$else}
sound_status.num_buffer:=sound_status.num_buffer+1;
if sound_status.num_buffer=MAX_AUDIO_BUFFER then sound_status.num_buffer:=0;
{$endif}
end;
sound_status.posicion_sonido:=0;
end;

procedure sound_engine_init(num_cpu:byte;clock:dword;update_call:exec_type_simple);
begin
  sound_status.cpu_clock:=clock;
  sound_status.cpu_num:=num_cpu;
  sound_engine_timer:=timers.init(num_cpu,clock/FREQ_BASE_AUDIO,sound_update_internal,nil,true);
  update_sound_proc:=update_call;
end;

procedure sound_engine_change_clock(clock:single);
begin
  timers.timer[sound_engine_timer].time_final:=clock/FREQ_BASE_AUDIO;
  sound_status.cpu_clock:=trunc(clock);
end;

procedure sound_update_internal;
begin
if @update_sound_proc<>nil then update_sound_proc;
if sound_status.posicion_sonido=sound_status.long_sample then begin
  play_sonido;
end else begin
  if sound_status.stereo then sound_status.posicion_sonido:=sound_status.posicion_sonido+2
    else sound_status.posicion_sonido:=sound_status.posicion_sonido+1;
end;
end;

procedure reset_audio;
var
  f:byte;
begin
sound_status.posicion_sonido:=0;
sound_status.num_buffer:=0;
for f:=0 to (MAX_CANALES-1) do fillchar(tsample[f,0],LONG_MAX_AUDIO,0);
end;

function init_channel:byte;
begin
  sound_status.canales_usados:=sound_status.canales_usados+1;
  if sound_status.canales_usados>=MAX_CANALES then MessageDlg('Utilizados mas canales de sonido de los disponibles!!', mtInformation,[mbOk], 0);
  init_channel:=sound_status.canales_usados;
end;

end.
