unit samples;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     dialogs,sysutils,sound_engine,file_engine,main_engine;

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
        end;
  ptipo_audio=^tipo_audio;
  tipo_samples=record
             num_samples:byte;
             audio:array[0..MAX_SAMPLES] of ptipo_audio;
             tsample_use:array[0..MAX_CHANNELS] of boolean;
             tsample_reserved:array[0..MAX_CHANNELS] of byte;
        end;
  pnom_sample=^tipo_nombre_samples;
  ptipo_samples=^tipo_samples;
var
  data_samples:ptipo_samples;
  samples_loaded:boolean;

function convert_wav(source:pbyte;var data:pword;source_long:dword;var long:dword):boolean;
function load_samples(nombre_zip:string;nombre_samples:pnom_sample;num_samples:byte):boolean;
function load_samples_raw(sample_data:pword;longitud:dword;restart,loop:boolean):boolean;
procedure start_sample(num:byte);
procedure samples_update;
procedure stop_sample(num:byte);
procedure close_samples;
procedure reset_samples;
procedure stop_all_samples;
function sample_status(num:byte):boolean;

implementation

function convert_wav(source:pbyte;var data:pword;source_long:dword;var long:dword):boolean;
var
  cadena:string;
  h:integer;
  ltemp,f,longitud,lsamples,total_size:dword;
  salir,fmt,datos,loop:boolean;
  temp2,ncanales,nbits,temp,temp_w:word;
  data2:pword;
  lsamples_m,lsamples_loop:single;
begin
convert_wav:=false;
cadena:='';
longitud:=0;
loop:=false;
for temp:=0 to 3 do begin
  cadena:=cadena+chr(source^);
  inc(source);inc(longitud);
end;
inc(source,4);inc(longitud,4);
for temp:=0 to 3 do begin
  cadena:=cadena+chr(source^);
  inc(source);inc(longitud);
end;
if cadena<>'RIFFWAVE' then exit;
fmt:=false;
datos:=false;
salir:=false;
while not(salir) do begin
  cadena:='';
  for temp:=0 to 3 do begin
    cadena:=cadena+chr(source^);
    inc(source);inc(longitud);
  end;
  if cadena='fmt ' then begin
    copymemory(@total_size,source,4);
    inc(source,4);inc(longitud,4);
    //Tipo de compresion
    copymemory(@temp2,source,2);
    inc(source,2);inc(longitud,2);
    if temp2<>1 then exit; //Solo soporto PCM!
    //Numero de canales
    copymemory(@ncanales,source,2);
    if ((ncanales<>1) and (ncanales<>2)) then exit;
    inc(source,2);inc(longitud,2);
    //Samples seg.
    copymemory(@lsamples,source,4);
    inc(source,4);inc(longitud,4);
    lsamples_m:=44100/lsamples;
    lsamples_loop:=lsamples_m;
    //Me salto 'Average bytes seg' y 'Bloq align'
    inc(source,6);inc(longitud,6);
    //Bits por sample (8 o 16)
    copymemory(@nbits,source,2);
    inc(source,2);inc(longitud,2);
    inc(source,total_size-16);inc(longitud,total_size-16);
    fmt:=true;
  end;
  if cadena='data' then begin
    if not(fmt) then exit;
    //Longitud en samples
    copymemory(@ltemp,source,4);
    inc(source,4);inc(longitud,4);
    //Y ahora resampleado a 44100, 16bits, mono
    if (nbits=16) then ltemp:=ltemp shr 1;
    if (ncanales=2) then ltemp:=ltemp shr 1;
    long:=round(ltemp*lsamples_m)+1;
    getmem(data,long*2);
    data2:=data;
    for f:=0 to (ltemp-1) do begin
      if nbits=8 then begin
        temp:=byte(source^-128) shl 8;
        inc(source);inc(longitud);
        if ncanales=2 then begin
          temp:=(temp+(byte(source^-128) shl 8)) shr 1;
          inc(source);
        end;
      end else begin
        copymemory(@temp_w,source,2);
        inc(source,2);inc(longitud,2);
        temp:=temp_w;
        if ncanales=2 then begin
          copymemory(@temp_w,source,2);
          inc(source,2);
          temp:=(temp+temp_w) shr 1;
        end;
      end;
     for h:=0 to (trunc(lsamples_loop)-1) do begin
        data2^:=temp;
        inc(data2);
        loop:=true;
     end;
     if loop then lsamples_loop:=lsamples_loop-round(lsamples_m);
     lsamples_loop:=lsamples_loop+lsamples_m;
     loop:=false;
    end;
    datos:=true;
  end;
  if ((cadena='fact') or (cadena='list') or (cadena='cue') or (cadena='plst') or (cadena='labl') or (cadena='ltxt') or (cadena='smpl') or (cadena='note') or (cadena='inst')) then begin
    //Longitud
    copymemory(@ltemp,source,4);
    inc(source,4);inc(longitud,4);
    inc(data,ltemp);inc(longitud,ltemp);
  end;
  if (fmt and datos) then begin
    salir:=true;
    convert_wav:=true;
  end;
  if longitud>source_long then salir:=true;
end;
end;

function load_samples_raw(sample_data:pword;longitud:dword;restart,loop:boolean):boolean;
var
  f,sample_pos:byte;
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
data_samples.audio[sample_pos].playing:=false;
getmem(data_samples.audio[sample_pos].data,longitud*2);
//cargar datos sample
data_samples.audio[sample_pos].long:=longitud;
data_samples.audio[sample_pos].restart:=restart;
data_samples.audio[sample_pos].loop:=loop;
copymemory(data_samples.audio[sample_pos].data,sample_data,longitud*2);
for f:=0 to MAX_CHANNELS do begin
  data_samples.tsample_reserved[f]:=init_channel;
  data_samples.tsample_use[f]:=false;
end;
load_samples_raw:=true;
end;

function load_samples(nombre_zip:string;nombre_samples:pnom_sample;num_samples:byte):boolean;
var
  nsamples,f:byte;
  ptemp:pbyte;
  longitud,crc:integer;
begin
load_samples:=false;
nsamples:=0;
//Inicializo los samples
getmem(data_samples,sizeof(tipo_samples));
//Inicializo un buffer
getmem(ptemp,$100000);
repeat
    if not(load_file_from_zip(Directory.Arcade_samples+nombre_zip,nombre_samples.nombre,ptemp,longitud,crc,false)) then begin
        freemem(data_samples);
        data_samples:=nil;
        freemem(ptemp);
        exit;
    end;
    //Inicializo el sample
    getmem(data_samples.audio[nsamples],sizeof(tipo_audio));
    data_samples.audio[nsamples].data:=nil;
    data_samples.audio[nsamples].pos:=0;
    data_samples.audio[nsamples].playing:=false;
    //cargar datos wav
    if not(convert_wav(ptemp,data_samples.audio[nsamples].data,longitud,data_samples.audio[nsamples].long)) then begin
      MessageDlg('Error loading sample file: '+'"'+nombre_samples.nombre+'"', mtError,[mbOk], 0);
      freemem(data_samples);
      data_samples:=nil;
      freemem(ptemp);
      exit;
    end;
    data_samples.audio[nsamples].restart:=nombre_samples.restart;
    data_samples.audio[nsamples].loop:=nombre_samples.loop;
    inc(nombre_samples);
    inc(nsamples);
until nsamples=num_samples;
freemem(ptemp);
data_samples.num_samples:=num_samples;
for f:=0 to MAX_CHANNELS do begin
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
      if not(data_samples.tsample_use[f]) then begin
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
    tsample[data_samples.audio[f].tsample,sound_status.posicion_sonido]:=smallint(ptemp^);
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

end.
