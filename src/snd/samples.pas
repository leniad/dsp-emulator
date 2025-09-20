unit samples;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     dialogs,sound_engine,file_engine,main_engine;

const
  MAX_SAMPLES=30;
  MAX_CHANNELS=6;

type
  tipo_nombre_samples=record
      nombre:string;
      restart,loop:boolean;
  end;
  tipo_audio=record
             long:dword;
             playing:boolean;
             data:pword;
             pos:dword;
             restart,loop:boolean;
             tsample:byte;
             amp:single;
        end;
  ptipo_audio=^tipo_audio;
  tipo_samples=record
             num_samples:byte;
             audio:array[0..MAX_SAMPLES] of ptipo_audio;
             tsample_use:array[0..MAX_CHANNELS] of boolean;
             tsample_reserved:array[0..MAX_CHANNELS] of integer;
             amp:single;
        end;
  ptipo_samples=^tipo_samples;

var
  data_samples:ptipo_samples;
  samples_loaded:boolean;

function convert_wav(source:pbyte;var data:pword;source_long:dword;var long:dword):boolean;
function load_samples(const nombre_samples:array of tipo_nombre_samples;amp:single=1;name:string=''):boolean;
function load_samples_raw(sample_data:pword;longitud:dword;restart,loop:boolean;amp:single=1):boolean;
procedure start_sample(num:byte);
procedure samples_update;
procedure stop_sample(num:byte);
procedure close_samples;
procedure reset_samples;
procedure stop_all_samples;
function sample_status(num:byte):boolean;
procedure change_vol_sample(num_sample:byte;amp:single);

implementation
uses init_games;

type
  theader=packed record
    magic1:array[0..3] of ansichar;
    size:dword;
    magic2:array[0..3] of ansichar;
  end;
  tchunk_info=packed record
    name:array[0..3] of ansichar;
    size:dword;
  end;
  tfmt_info=packed record
    audio_format:word;
    num_channles:word;
    sample_rate:dword;
    byte_rate:dword;
    block_aling:word;
    bits_per_sample:word;
  end;

function convert_wav(source:pbyte;var data:pword;source_long:dword;var long:dword):boolean;
var
  h:integer;
  f,longitud:dword;
  salir,fmt,datos:boolean;
  temp,temp_w:word;
  data2:pword;
  lsamples_m,lsamples_loop:single;
  header:^theader;
  chunk:^tchunk_info;
  fmt_info:^tfmt_info;
  ptemp:pbyte;
begin
convert_wav:=false;
longitud:=0;
ptemp:=source;
getmem(header,sizeof(theader));
copymemory(header,ptemp,12);
inc(ptemp,12);
inc(longitud,12);
if header.magic1<>'RIFF' then begin
  freemem(header);
  exit;
end;
if header.magic2<>'WAVE' then begin
  freemem(header);
  exit;
end;
freemem(header);
getmem(chunk,sizeof(tchunk_info));
fmt:=false;
datos:=false;
salir:=false;
while not(salir) do begin
  copymemory(chunk,ptemp,8);
  inc(ptemp,8);
  inc(longitud,8);
  if chunk.name='fmt ' then begin
    getmem(fmt_info,sizeof(tfmt_info));
    copymemory(fmt_info,ptemp,16);
    inc(ptemp,chunk.size);
    inc(longitud,chunk.size);
    //Tipo de compresion
    if fmt_info.audio_format<>1 then begin //Solo soporto PCM!
      freemem(chunk);
      freemem(fmt_info);
      exit;
    end;
    //Numero de canales
    if ((fmt_info.num_channles<>1) and (fmt_info.num_channles<>2)) then begin
      freemem(chunk);
      freemem(fmt_info);
      exit;
    end;
    //Samples seg.
    lsamples_m:=FREQ_BASE_AUDIO/fmt_info.sample_rate;
    lsamples_loop:=lsamples_m;
    fmt:=true;
  end;
  if chunk.name='data' then begin
    if not(fmt) then begin
      freemem(chunk);
      freemem(fmt_info);
      exit;
    end;
    //Y ahora resampleado a 44100, 16bits, mono
    if (fmt_info.bits_per_sample=16) then chunk.size:=chunk.size shr 1;
    if (fmt_info.num_channles=2) then chunk.size:=chunk.size shr 1;
    long:=round(chunk.size*lsamples_m)+1;
    getmem(data,long*2);
    data2:=data;
    for f:=0 to (chunk.size-1) do begin
      if fmt_info.bits_per_sample=8 then begin
        temp:=byte(ptemp^-128) shl 8;
        inc(ptemp);inc(longitud);
        if fmt_info.num_channles=2 then begin
          temp:=(temp+(byte(ptemp^-128) shl 8)) shr 1;
          inc(ptemp);
        end;
      end else begin
        copymemory(@temp,ptemp,2);
        inc(ptemp,2);inc(longitud,2);
        if fmt_info.num_channles=2 then begin
          copymemory(@temp_w,ptemp,2);
          inc(ptemp,2);
          temp:=(temp+temp_w) shr 1;
        end;
      end;
     for h:=0 to (trunc(lsamples_loop)-1) do begin
        data2^:=temp;
        inc(data2);
     end;
     lsamples_loop:=(lsamples_loop-trunc(lsamples_loop))+lsamples_m;
    end;
    datos:=true;
  end;
  if ((chunk.name='fact') or (chunk.name='list') or (chunk.name='cue') or (chunk.name='plst') or (chunk.name='labl') or (chunk.name='ltxt') or (chunk.name='smpl') or (chunk.name='note') or (chunk.name='inst')) then begin
    //Longitud
    inc(ptemp,chunk.size);
    inc(longitud,chunk.size);
  end;
  if (fmt and datos) then begin
    salir:=true;
    convert_wav:=true;
  end;
  if longitud>source_long then salir:=true;
end;
freemem(chunk);
freemem(fmt_info);
end;

function load_samples_raw(sample_data:pword;longitud:dword;restart,loop:boolean;amp:single=1):boolean;
var
  sample_pos:byte;
begin
load_samples_raw:=false;
//Inicializo los samples
if data_samples=nil then begin
  getmem(data_samples,sizeof(tipo_samples));
  data_samples.num_samples:=1;
  sample_pos:=0;
end else begin
  sample_pos:=data_samples.num_samples;
  data_samples.num_samples:=data_samples.num_samples+1;
end;
//Inicializo el sample
getmem(data_samples.audio[sample_pos],sizeof(tipo_audio));
data_samples.audio[sample_pos].pos:=0;
data_samples.amp:=amp;
data_samples.audio[sample_pos].playing:=false;
getmem(data_samples.audio[sample_pos].data,longitud*2);
//cargar datos sample
data_samples.audio[sample_pos].long:=longitud;
data_samples.audio[sample_pos].restart:=restart;
data_samples.audio[sample_pos].loop:=loop;
data_samples.audio[sample_pos].amp:=1;
copymemory(data_samples.audio[sample_pos].data,sample_data,longitud*2);
//Inicializar solo el sample
if ((data_samples.num_samples-1)<=MAX_CHANNELS) then begin
  data_samples.tsample_reserved[data_samples.num_samples-1]:=init_channel;
  data_samples.tsample_use[data_samples.num_samples-1]:=false;
end;
load_samples_raw:=true;
end;

function load_samples(const nombre_samples:array of tipo_nombre_samples;amp:single=1;name:string=''):boolean;
var
  f,sample_size:word;
  ptemp:pbyte;
  longitud:integer;
  nombre_zip:string;
  crc:dword;
begin
if name<>'' then begin
    nombre_zip:=name;
end else begin
  for f:=1 to GAMES_CONT do begin
    if GAMES_DESC[f].grid=main_vars.tipo_maquina then begin
      nombre_zip:=GAMES_DESC[f].zip+'.zip';
      break;
    end;
  end;
end;
load_samples:=false;
//Inicializo los samples
getmem(data_samples,sizeof(tipo_samples));
//Inicializo un buffer
getmem(ptemp,$100000);
sample_size:=sizeof(nombre_samples) div sizeof(tipo_nombre_samples);
for f:=0 to (sample_size-1) do begin
    if not(load_file_from_zip(Directory.Arcade_samples+nombre_zip,nombre_samples[f].nombre,ptemp,longitud,crc,false)) then begin
        freemem(data_samples);
        data_samples:=nil;
        freemem(ptemp);
        exit;
    end;
    //Inicializo el sample
    getmem(data_samples.audio[f],sizeof(tipo_audio));
    data_samples.audio[f].data:=nil;
    data_samples.audio[f].pos:=0;
    data_samples.audio[f].playing:=false;
    //cargar datos wav
    if not(convert_wav(ptemp,data_samples.audio[f].data,longitud,data_samples.audio[f].long)) then begin
      MessageDlg('Error loading sample file: '+'"'+nombre_samples[f].nombre+'"', mtError,[mbOk], 0);
      freemem(data_samples);
      data_samples:=nil;
      freemem(ptemp);
      exit;
    end;
    data_samples.audio[f].restart:=nombre_samples[f].restart;
    data_samples.audio[f].loop:=nombre_samples[f].loop;
    data_samples.audio[f].amp:=1;
end;
freemem(ptemp);
data_samples.num_samples:=sample_size;
data_samples.amp:=amp;
//Inicializar solor los necesarios...
for f:=0 to MAX_CHANNELS do data_samples.tsample_reserved[f]:=-1;
if (sample_size-1)>MAX_CHANNELS then sample_size:=MAX_CHANNELS;
for f:=0 to (sample_size-1) do begin
  data_samples.tsample_reserved[f]:=init_channel;
  data_samples.tsample_use[f]:=false;
end;
load_samples:=true;
end;

procedure reset_samples;
var
  f:byte;
begin
if data_samples=nil then exit;
for f:=0 to data_samples.num_samples-1 do begin
  data_samples.audio[f].playing:=false;
  data_samples.audio[f].pos:=0;
end;
for f:=0 to MAX_CHANNELS do data_samples.tsample_use[f]:=false;
end;

function first_sample_free:byte;
var
  f:byte;
begin
  for f:=0 to MAX_CHANNELS do begin
      if (not(data_samples.tsample_use[f]) and (data_samples.tsample_reserved[f]<>-1)) then begin
        data_samples.tsample_use[f]:=true;
        first_sample_free:=data_samples.tsample_reserved[f];
        exit;
      end;
  end;
  //Si no hay libres, que coja el primero...
  first_sample_free:=data_samples.tsample_reserved[0];
end;

procedure start_sample(num:byte);
begin
if data_samples=nil then exit;
//Si no esta en marcha que comience
if not(data_samples.audio[num].playing) then begin
  data_samples.audio[num].playing:=true;
  data_samples.audio[num].pos:=0;
  data_samples.audio[num].tsample:=first_sample_free;
end else begin //Si ya ha empezado, pero puede volver a comenzar lo hace
  if data_samples.audio[num].restart then data_samples.audio[num].pos:=0;
end;
end;

procedure stop_sample(num:byte);
begin
if data_samples=nil then exit;
if data_samples.audio[num].playing then begin
  data_samples.audio[num].playing:=false;
  data_samples.tsample_use[data_samples.audio[num].tsample]:=false;
end;
end;

function sample_status(num:byte):boolean;
begin
  if data_samples<>nil then sample_status:=data_samples.audio[num].playing;
end;

procedure stop_all_samples;
var
  f:word;
begin
if data_samples=nil then exit;
for f:=0 to (data_samples.num_samples-1) do begin
  if data_samples.audio[f].playing then begin
    data_samples.audio[f].playing:=false;
    data_samples.tsample_use[data_samples.audio[f].tsample]:=false;
  end;
end;
end;

procedure samples_update;
var
  f:word;
  ptemp:pword;
begin
if data_samples=nil then exit;
for f:=0 to (data_samples.num_samples-1) do begin
 if data_samples.audio[f].playing then begin
    ptemp:=data_samples.audio[f].data;
    inc(ptemp,data_samples.audio[f].pos);
    data_samples.audio[f].pos:=data_samples.audio[f].pos+1;
    tsample[data_samples.audio[f].tsample,sound_status.posicion_sonido]:=trunc(smallint(ptemp^)*data_samples.amp*data_samples.audio[f].amp);
    if data_samples.audio[f].pos=data_samples.audio[f].long then begin
      if data_samples.audio[f].loop then begin
        data_samples.audio[f].pos:=0;
      end else begin
        data_samples.audio[f].playing:=false;
        data_samples.tsample_use[data_samples.audio[f].tsample]:=false;
      end;
    end;
 end;
end;
end;

procedure close_samples;
var
  f:byte;
begin
if data_samples=nil then exit;
for f:=0 to data_samples.num_samples-1 do begin
  if data_samples.audio[f]<>nil then begin
    if data_samples.audio[f].data<>nil then freemem(data_samples.audio[f].data);
    freemem(data_samples.audio[f]);
  end;
end;
freemem(data_samples);
data_samples:=nil;
end;

procedure change_vol_sample(num_sample:byte;amp:single);
begin
  data_samples.audio[num_sample].amp:=amp;
end;

end.
