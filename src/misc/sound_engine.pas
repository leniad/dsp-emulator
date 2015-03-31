unit sound_engine;

interface
uses {$ifdef fpc}
     {$ifndef windows}sdl2,SDL2_mixer,{$else}windows,mmsystem,{$endif}
     {$else}
     {$ifdef windows}windows,mmsystem,{$endif}
     {$endif}
     timer_engine;

const
        max_audio_buffer=$f;
        max_canales=9;
        long_max_audio=1800;
        freq_base_audio=44100;

type
        tipo_sonido=record
          posicion_sonido:word;
          {$ifdef windows}
          audio:array[0..max_canales-1] of HWAVEOUT;
          {$endif}
          cpu_clock:dword;
          cpu_num:byte;
          num_buffer,calidad_audio:byte;
          long_sample,sample_final:word;
          canales_usados:integer;
          stereo,hay_sonido,hay_tsonido:boolean;
        end;
        snd_chip_class=class
          public
            function get_sample_num:byte;
          protected
            tsample_num,amp:byte;
            clock:dword;
        end;

var
        tsample:array[0..max_canales-1,0..long_max_audio-1] of smallint;
        sound_status:tipo_sonido;
        update_sound_proc:exec_type;
        sound_engine_timer:byte;
        {$ifdef windows}
        cab_audio:array[0..max_canales-1,0..max_audio_buffer-1] of wavehdr;
        {$else}
        chunks:array[0..max_canales-1,0..max_audio_buffer-1] of tmix_chunk;
        {$endif}

function iniciar_audio(stereo_sound:boolean):boolean;
procedure sound_engine_init(num_cpu:byte;clock:dword;update_call:exec_type);
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

{$ifdef windows}
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
case sound_status.calidad_audio of
  0:Format.nSamplesPerSec:=11025;
  1:Format.nSamplesPerSec:=22050;
  3:begin
      sound_status.hay_sonido:=false;
      Format.nSamplesPerSec:=44100;
    end;
  else Format.nSamplesPerSec:=44100;
end;
Format.wBitsPerSample:=16;
Format.nBlockAlign:=Format.nChannels*(Format.wBitsPerSample div 8);
Format.nAvgBytesPerSec:=Format.nSamplesPerSec*Format.nBlockAlign;
format.cbSize:=0;
sound_status.long_sample:=round(FREQ_BASE_AUDIO/llamadas_maquina.fps_max)*canales;
sound_status.sample_final:=round(Format.nSamplesPerSec/llamadas_maquina.fps_max)*canales;
for g:=0 to max_canales-1 do begin
  if not((waveoutopen(@sound_status.audio[g],WAVE_MAPPER,@format,0,1,CALLBACK_NULL))=0) then exit;
  For f:=0 To max_audio_buffer-1 do begin
        getmem(cab_audio[g][f].lpData,sound_status.sample_final*2);
        cab_audio[g][f].dwBufferLength:=sound_status.sample_final*2;
        cab_audio[g][f].dwUser :=0;
        cab_audio[g][f].dwFlags := 0;
        cab_audio[g][f].dwLoops := 0;
        cab_audio[g][f].lpNext := nil;
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
for j:=0 to max_canales-1 do begin
  waveOutReset(sound_status.audio[j]);
  for f:=0 to max_audio_buffer-1 do begin
    waveoutunprepareheader(sound_status.audio[j],@cab_audio[j][f],sizeof(cab_audio[j][f]));
    freemem(cab_audio[j][f].lpData);
    cab_audio[j][f].lpData:=nil;
  end;
  waveoutclose(sound_status.audio[j]);
end;
end;
{$else}
//Funciones de Linux
function iniciar_audio(stereo_sound:boolean):boolean;
var
  audio_rate,audio_format,audio_channels:integer;
  f,g,canales:byte;
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
case sound_status.calidad_audio of
  0:audio_rate:=11025;
  1:audio_rate:=22050;
  3:begin
      audio_rate:=44100;
      sound_status.hay_sonido:=false;
    end;
    else audio_rate:=44100;
end;
audio_format:=AUDIO_S16;
audio_channels:=canales;
sound_status.sample_final:=(trunc(audio_rate/llamadas_maquina.fps_max)+1)*canales;
//audio_buffers:=sound_status.sample_final;
if (Mix_OpenAudio(audio_rate, audio_format, audio_channels,sound_status.sample_final)<>0) then exit;
//preparar canales
if (mix_allocatechannels(max_canales)=0) then exit;
for g:=0 to max_canales-1 do begin
    for f:=0 to max_audio_buffer-1 do begin
          chunks[g,f].allocated:=1;
          getmem(chunks[g,f].abuf,sound_status.sample_final*2);
          chunks[g,f].alen:=sound_status.sample_final*2;
          chunks[g,f].volume:=128;
    end;
end;
sound_status.hay_tsonido:=true;
reset_audio;
iniciar_audio:=true;
end;

procedure close_audio;
var
   f,g:byte;
begin
if not(sound_status.hay_tsonido) then exit;
for g:=0 to max_canales-1 do
    for f:=0 to max_audio_buffer-1 do if chunks[g,f].abuf<>nil then begin
                                          freemem(chunks[g,f].abuf);
                                          chunks[g,f].abuf:=nil;
                                       end;
mix_closeaudio();
end;
{$endif}

procedure play_sonido;
var
  f:integer;
  g,h:word;
begin
if ((sound_status.hay_tsonido) and (sound_status.hay_sonido)) then begin
for f:=0 to sound_status.canales_usados do begin
  h:=0;
  //Resampleado
  case sound_status.calidad_audio of
    0:if sound_status.stereo then begin
        g:=0;
        while g<sound_status.sample_final do begin
          tsample[f,g]:=(tsample[f,h]+tsample[f,h+2]+tsample[f,h+4]+tsample[f,h+6]) shr 2;
          tsample[f,g+1]:=(tsample[f,h+1]+tsample[f,h+3]+tsample[f,h+5]+tsample[f,h+7]) shr 2;
          h:=h+8;
          g:=g+2;
        end;
      end else begin
         for g:=0 to (sound_status.sample_final-1) do begin
          tsample[f,g]:=(tsample[f,h]+tsample[f,h+1]+tsample[f,h+2]+tsample[f,h+3]) shr 2;
          h:=h+4;
         end;
      end;
    1:if sound_status.stereo then begin
          g:=0;
          while g<sound_status.sample_final do begin
            tsample[f,g]:=(tsample[f,h]+tsample[f,h+2]) shr 1;
            tsample[f,g+1]:=(tsample[f,h+1]+tsample[f,h+3]) shr 1;
            h:=h+4;
            g:=g+2;
          end;
       end else begin
          for g:=0 to (sound_status.sample_final-1) do begin
            tsample[f,g]:=(tsample[f,h]+tsample[f,h+1]) shr 1;
            h:=h+2;
          end;
      end;
    2:;
  end;
  {$ifdef windows}
  copymemory(cab_audio[f][sound_status.num_buffer].lpData,@tsample[f],sound_status.sample_final*2);
  waveOutWrite(sound_status.audio[f],@cab_audio[f][sound_status.num_buffer],sizeof(WAVEHDR));
  {$else}
  copymemory(chunks[f,sound_status.num_buffer].abuf,@tsample[f],sound_status.sample_final*2);
  mix_playchannel(f,@chunks[f,sound_status.num_buffer],-1);
  {$endif}
  fillchar(tsample[f],long_max_audio,0);
end;
end;
sound_status.num_buffer:=sound_status.num_buffer+1;
if sound_status.num_buffer=max_audio_buffer then sound_status.num_buffer:=0;
sound_status.posicion_sonido:=0;
end;

procedure sound_engine_init(num_cpu:byte;clock:dword;update_call:exec_type);
begin
  sound_status.cpu_clock:=clock;
  sound_status.cpu_num:=num_cpu;
  sound_engine_timer:=init_timer(num_cpu,clock/FREQ_BASE_AUDIO,sound_update_internal,true);
  update_sound_proc:=update_call;
end;

procedure sound_engine_change_clock(clock:single);
begin
  timer[sound_engine_timer].time_final:=clock/FREQ_BASE_AUDIO;
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
for f:=0 to (max_canales-1) do fillchar(tsample[f,0],long_max_audio,0);
end;

function init_channel:byte;
begin
  sound_status.canales_usados:=sound_status.canales_usados+1;
  init_channel:=sound_status.canales_usados;
end;

end.
