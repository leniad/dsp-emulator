unit sound_engine;

interface
uses {$ifdef windows}windows,{$endif}{$ifndef fpc}mmsystem,{$endif}lib_sdl2,timer_engine,dialogs;

const
        max_audio_buffer=$f;
        max_canales=9;
        long_max_audio=1800;
        freq_base_audio=44100;

type
        tipo_sonido=record
          posicion_sonido:word;
          {$ifndef fpc}
          audio:array[0..max_canales-1] of HWAVEOUT;
          {$endif}
          cpu_clock:dword;
          cpu_num:byte;
          num_buffer,calidad_audio:byte;
          long_sample,sample_final:word;
          canales_usados:integer;
          stereo,hay_sonido,hay_tsonido:boolean;
          filter_call:array[0..max_canales-1] of procedure(canal:byte);
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
        tsample:array[0..max_canales-1,0..long_max_audio-1] of smallint;
        sound_status:tipo_sonido;
        update_sound_proc:exec_type;
        sound_engine_timer:byte;
        {$ifndef fpc}
        cab_audio:array[0..max_canales-1,0..max_audio_buffer-1] of wavehdr;
        {$else}
        sample_final:array[0..long_max_audio-1] of smallint;
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
Format.nSamplesPerSec:=44100;
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
for g:=0 to max_canales-1 do begin
  if not((waveoutopen(@sound_status.audio[g],WAVE_MAPPER,@format,0,1,CALLBACK_NULL))=0) then exit;
  For f:=0 To max_audio_buffer-1 do begin
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
audio_rate:=44100;
case sound_status.calidad_audio of
  0:audio_rate:=11025;
  1:audio_rate:=22050;
  3:sound_status.hay_sonido:=false;
end;
sound_status.sample_final:=round(audio_rate/llamadas_maquina.fps_max)*canales;
wanted.freq:=audio_rate;
wanted.padding:=0;
wanted.format:=libAUDIO_S16;
wanted.channels:=canales;
wanted.samples:=sound_status.sample_final;
wanted.silence:=0; //wanted.size:=sound_status.sample_final*2;
wanted.size_:=0;
wanted.callback:=nil;//sound_call_back;
wanted.userdata:=nil;
if (SDL_OpenAudio(@wanted,@have)<>0) then exit;
SDL_PauseAudio(0);
SDL_ClearQueuedAudio(1);
sound_status.hay_tsonido:=true;
reset_audio;
iniciar_audio:=true;
end;

procedure close_audio;
begin
SDL_CloseAudio;
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
  if @sound_status.filter_call[f]<>nil then sound_status.filter_call[f](f);
  {$ifndef fpc}
  copymemory(cab_audio[f][sound_status.num_buffer].lpData,@tsample[f],sound_status.sample_final*2);
  waveOutWrite(sound_status.audio[f],@cab_audio[f][sound_status.num_buffer],sizeof(WAVEHDR));
  {$else}
  for h:=0 to (sound_status.sample_final-1) do sample_final[h]:=sample_final[h]+tsample[f,h];
  {$endif}
  fillchar(tsample[f],long_max_audio,0);
end;
end;
{$ifdef fpc}
if main_screen.rapido then SDL_ClearQueuedAudio(1);
for h:=0 to (sound_status.sample_final-1) do sample_final[h]:=sample_final[h] div (sound_status.canales_usados+1);
SDL_QueueAudio(1,@sample_final[0],sound_status.long_sample*sizeof(smallint));
fillchar(sample_final[0],long_max_audio*sizeof(smallint),0);
{$endif}
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
for f:=0 to (max_canales-1) do fillchar(tsample[f,0],long_max_audio,0);
end;

function init_channel:byte;
begin
  sound_status.canales_usados:=sound_status.canales_usados+1;
  if sound_status.canales_usados>max_canales then MessageDlg('Utilizados mas canales de sonido de los disponibles!!', mtInformation,[mbOk], 0);
  init_channel:=sound_status.canales_usados;
end;

end.
