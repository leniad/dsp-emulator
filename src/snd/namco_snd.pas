unit namco_snd;

interface
uses {$IFDEF WINDOWS}windows,{$else}main_engine,{$ENDIF}
     sound_engine,timer_engine;

procedure namco_playsound;
procedure namco_sound_reset;
procedure namco_sound_init(num_voces:byte;wave_ram:boolean);
//Namco CUS30
procedure namcos1_cus30_w(direccion:word;valor:byte);
function namcos1_cus30_r(direccion:word):byte;
//ADPCM sound
procedure namco_63701x_start(clock:dword);
procedure namco_63701x_close;
procedure namco_63701x_update;
procedure namco_63701x_w(dir:word;valor:byte);
procedure namco_63701x_internal_update;
procedure namco_63701x_reset;
//Snapshot
function namco_sound_save_snapshot(data:pbyte):word;
procedure namco_sound_load_snapshot(data:pbyte);

type
  nvoice=record
            volume:byte;
            numero_onda:byte;
            frecuencia:integer;
            activa:boolean;
            dentro_onda:dword;
         end;
  tnamco_sound=record
            onda_namco:array[0..$ff] of byte;
            ram:array[0..$3ff] of byte;
            num_voces:byte;
            registros_namco:array[0..$3F] of byte;
            namco_wave:array[0..$1ff] of byte;
            wave_size:byte;
            wave_on_ram,enabled:boolean;
            tsample:byte;
         end;
  tnamco_63701=record
            select:integer;
	          playing:boolean;
	          base_addr,position,volume,silence_counter:integer;
            timer,tsample:byte;
            signal:integer;
          end;

const
  max_voices=8;
  MAX_VOLUME=16;
  MIXLEVEL=(1 shl (16-4-4));
var
  voice:array[0..(max_voices-1)] of nvoice;
  namco_sound:tnamco_sound;
  namco_63701:array[0..1] of tnamco_63701;
  namco_63701_rom:pbyte;

implementation

procedure getvoice_3(numero_voz:byte);inline;
var
  base:byte;
  f:integer;
begin
    base:=5*numero_voz;
    // Registro $5 --> Elegir la onda a reproducir
    voice[numero_voz].numero_onda:=namco_sound.registros_namco[$5+base] and 7;
    // Registro $15 --> Volumen de la onda
    voice[numero_voz].volume:=(namco_sound.registros_namco[$15+base] and $F) shr 1;
    // Resgistros $11, $12 y $14 --> Frecuencia
    // Si la voz es la 0 hay un registro mas de frecuencia
    f:=(namco_sound.registros_namco[$14+base] and $F) shl 16;
    f:=f+((namco_sound.registros_namco[$13+base] and $F) shl 12);
    f:=f or ((namco_sound.registros_namco[$12+base] and $F) shl 8);
    f:=f or ((namco_sound.registros_namco[$11+base] and $F) shl 4);
    if numero_voz=0 then f:=f or(namco_sound.registros_namco[$10] and $F);
    voice[numero_voz].frecuencia:=f*2177; //resample -> (96Mhz/44100)
    if ((voice[numero_voz].frecuencia=0) or (voice[numero_voz].volume=0)) then begin
        voice[numero_voz].activa:=false;
        voice[numero_voz].dentro_onda:=0;
    end else voice[numero_voz].activa:=true;
end;

procedure getvoice_8(numero_voz:byte);inline;
var
  base:byte;
  f:integer;
begin
    base:=($8*numero_voz)+$3;
    // Registro $3 --> Elegir la onda a reproducir
    voice[numero_voz].numero_onda:=namco_sound.registros_namco[$3+base] shr 4;
    // Registro $0 --> Volumen de la onda
    voice[numero_voz].volume:=(namco_sound.registros_namco[$0+base] and $F) shr 1;
    // Resgistros $1, $2 y $3 --> Frecuencia
    f:=namco_sound.registros_namco[$1+base];
    f:=f or (namco_sound.registros_namco[$2+base] shl 8);
    f:=f or ((namco_sound.registros_namco[$3+base] and $f) shl 16);
    voice[numero_voz].frecuencia:=f*544;  //resample -> (24Mhz/44100)
    if ((voice[numero_voz].frecuencia=0) and (voice[numero_voz].volume=0)) then begin
        voice[numero_voz].activa:=false;
        voice[numero_voz].dentro_onda:=0;
    end else voice[numero_voz].activa:=true;
end;

procedure update_namco_waveform(offset:word;data:byte);
begin
	if namco_sound.wave_on_ram then begin
		// use full byte, first 4 high bits, then low 4 bits */
    namco_sound.namco_wave[offset*2]:=(data shr 4) and $0f;
    namco_sound.namco_wave[offset*2+1]:=data and $0f;
  end else begin
		// use only low 4 bits */
    namco_sound.namco_wave[offset]:=data and $0f;
  end;
end;

procedure namco_sound_reset;
var
  f:byte;
begin
namco_sound.enabled:=true;
for f:=0 to (max_voices-1) do begin
  voice[f].volume:=0;
  voice[f].numero_onda:=0;
  voice[f].frecuencia:=0;
  voice[f].activa:=false;
  voice[f].dentro_onda:=0;
end;
for f:=0 to $3f do namco_sound.registros_namco[f]:=0;
if not(namco_sound.wave_on_ram) then
  for f:=0 to $ff do update_namco_waveform(f,namco_sound.onda_namco[f]);
end;

procedure namco_sound_init(num_voces:byte;wave_ram:boolean);
begin
  namco_sound.num_voces:=num_voces;
  namco_sound.wave_on_ram:=wave_ram;
  namco_sound.tsample:=init_channel;
end;

procedure namco_playsound;
var
  numero_voz:byte;
  wave_data:byte;
  i:word;
  offset,offset_step:integer;
  sample:word;
begin
    if not(namco_sound.enabled) then exit;
    for numero_voz:=0 to namco_sound.num_voces-1 do begin
        if not(namco_sound.wave_on_ram) then begin
          if namco_sound.num_voces=3 then getvoice_3(numero_voz)
            else getvoice_8(numero_voz);
        end;
        if voice[numero_voz].activa then begin
            offset:=voice[numero_voz].dentro_onda;
            offset_step:=voice[numero_voz].frecuencia;
            if namco_sound.wave_on_ram then begin
              wave_data:=32*voice[numero_voz].numero_onda*2;
              for i:=0 to ((sound_status.long_sample-1) div 2) do begin
                  sample:=namco_sound.namco_wave[wave_data+((offset shr 25) and $1F)]*voice[numero_voz].volume;
                  tsample[namco_sound.tsample,i*2]:=tsample[namco_sound.tsample,i*2]+((sample shl 8) div (namco_sound.num_voces*2));
                  sample:=namco_sound.namco_wave[wave_data+1+((offset shr 25) and $1F)]*voice[numero_voz].volume;
                  tsample[namco_sound.tsample,(i*2)+1]:=tsample[namco_sound.tsample,(i*2)+1]+((sample shl 8) div (namco_sound.num_voces*2));
                  offset:=offset+offset_step;
               end;
            end else begin
               wave_data:=32*voice[numero_voz].numero_onda;
               for i:=0 to (sound_status.long_sample-1) do begin
                  sample:=namco_sound.namco_wave[wave_data+((offset shr 25) and $1F)]*voice[numero_voz].volume;
                  tsample[namco_sound.tsample,i]:=tsample[namco_sound.tsample,i]+((sample shl 8) div namco_sound.num_voces);
                  offset:=offset+offset_step;
               end;
            end;
            voice[numero_voz].dentro_onda:=offset;
        end;
    end;
end;

//Namco System1
procedure namcos1_sound_w(direccion:word;valor:byte);
var
  ch:byte;
begin
	if (namco_sound.registros_namco[direccion]=valor) then exit;
	// set the register */
  namco_sound.registros_namco[direccion]:=valor;
	ch:=direccion div 8;
	// recompute the voice parameters */
	case (direccion-ch*8) of
	$00:voice[ch].volume:=valor and $0f;
	$01:voice[ch].numero_onda:=(valor shr 4) and $f;
	$02,$03:begin	// the frequency has 20 bits */
		        voice[ch].frecuencia:=(namco_sound.registros_namco[ch*8+$01] and 15) shl 16;	// high bits are from here
        		voice[ch].frecuencia:=voice[ch].frecuencia+(namco_sound.registros_namco[ch*8+$02] shl 8);
        		voice[ch].frecuencia:=(voice[ch].frecuencia+namco_sound.registros_namco[ch*8+$03])*544;
      end;
{	$04:begin
		    voice->volume[1] = data & 0x0f;
		    nssw = ((data & 0x80) >> 7);
		    if (++voice == chip->last_channel)
			      voice = chip->channel_list;
		    voice->noise_sw = nssw;
      end;}
	end;
  if ((voice[ch].frecuencia=0) and (voice[ch].volume=0)) then begin
        voice[ch].activa:=false;
        voice[ch].dentro_onda:=0;
    end else voice[ch].activa:=true;
end;

//Namco CUS30
procedure namcos1_cus30_w(direccion:word;valor:byte);
begin
  case direccion of
    0..$ff:begin
        	  	if (namco_sound.ram[direccion]<>valor) then begin
        		  	namco_sound.ram[direccion]:=valor;
        		  	// update the decoded waveform table */
        		  	update_namco_waveform(direccion,valor);
             end;
           end;
    $100..$13f:namcos1_sound_w(direccion and $3f,valor);
    $140..$3ff:namco_sound.ram[direccion]:=valor;
    end;
end;

function namcos1_cus30_r(direccion:word):byte;
begin
  namcos1_cus30_r:=namco_sound.ram[direccion];
end;

function namco_sound_save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
  f:byte;
begin
  temp:=data;
  size:=0;
  for f:=0 to 7 do copymemory(temp,@voice[f],sizeof(nvoice));inc(temp,sizeof(nvoice));size:=size+sizeof(nvoice);
  copymemory(temp,@namco_sound,sizeof(tnamco_sound));
  namco_sound_save_snapshot:=size;
end;

procedure namco_sound_load_snapshot(data:pbyte);
var
  temp:pbyte;
  f:byte;
begin
  temp:=data;
  for f:=0 to 7 do copymemory(@voice[f],temp,sizeof(nvoice));inc(temp,sizeof(nvoice));
  copymemory(@namco_sound,temp,sizeof(tnamco_sound));
end;

procedure namco_63701x_start(clock:dword);
begin
getmem(namco_63701_rom,$40000);
namco_63701[0].tsample:=init_channel;
namco_63701[1].tsample:=init_channel;
namco_63701[0].timer:=init_timer(sound_status.cpu_num,sound_status.cpu_clock/(clock/1000),namco_63701x_internal_update,true);
end;

procedure namco_63701x_close;
begin
freemem(namco_63701_rom);
end;

procedure namco_63701x_reset;
var
  f:byte;
begin
for f:=0 to 1 do begin
  namco_63701[f].select:=0;
  namco_63701[f].playing:=false;
  namco_63701[f].base_addr:=0;
  namco_63701[f].position:=0;
  namco_63701[f].volume:=0;
  namco_63701[f].silence_counter:=0;
  namco_63701[f].signal:=0;
end;
end;

procedure namco_63701x_update;
var
  f:byte;
begin
for f:=0 to 1 do begin
  tsample[namco_63701[f].tsample,sound_status.posicion_sonido]:=namco_63701[f].signal;
  if sound_status.stereo then tsample[namco_63701[f].tsample,sound_status.posicion_sonido+1]:=namco_63701[f].signal;
end;
end;

procedure namco_63701x_internal_update;
const
  vol_table:array[0..3] of word=(26,84,200,258);
var
  data,ch:byte;
  ptemp,ptemp2:pbyte;
  pos,vol:integer;
begin
for ch:=0 to 1 do begin
		if namco_63701[ch].playing then begin
      ptemp:=namco_63701_rom;
      inc(ptemp,namco_63701[ch].base_addr);
			pos:=namco_63701[ch].position;
			vol:=vol_table[namco_63701[ch].volume];
      if (namco_63701[ch].silence_counter<>0) then begin
					namco_63701[ch].silence_counter:=namco_63701[ch].silence_counter-1;
					namco_63701[ch].signal:=0;
      end	else begin
          ptemp2:=ptemp;
          inc(ptemp2,pos and $ffff);
          pos:=pos+1;
					data:=ptemp2^;
					if (data=$ff) then begin   // end of sample */
						namco_63701[ch].playing:=false;
            namco_63701[ch].signal:=0;
          end else begin
            if (data=$00) then begin  // silence compression */
              ptemp2:=ptemp;
              inc(ptemp2,pos and $ffff);
              pos:=pos+1;
						  data:=ptemp2^;
						  namco_63701[ch].silence_counter:=data;
						  namco_63701[ch].signal:=0;
            end else begin
						  namco_63701[ch].signal:=vol*(data-$80);
            end;
          end;
      end;
      namco_63701[ch].position:=pos;
    end else begin //si no esta en marcha...
      namco_63701[ch].signal:=0;
    end;
end;
end;

procedure namco_63701x_w(dir:word;valor:byte);
var
  ch:byte;
  rom_offs:integer;
  ptemp:pbyte;
begin
  ch:=(dir shl 1) and 1;
	if (dir and 1)<>0 then begin
		namco_63701[ch].select:=valor;
	end else begin
		  {should we stop the playing sample if voice_select[ch] == 0 ?
		  originally we were, but this makes us lose a sample in genpeitd,
		  after the continue counter reaches 0. Either we shouldn't stop
		  the sample, or genpeitd is returning to the title screen too soon.}
		if (namco_63701[ch].select and $1f)<>0 then begin
			// update the streams */
			namco_63701[ch].playing:=true;
			namco_63701[ch].base_addr:=$10000*((namco_63701[ch].select and $e0) shr 5);
			rom_offs:=namco_63701[ch].base_addr+2*((namco_63701[ch].select and $1f)-1);
      ptemp:=namco_63701_rom;
      inc(ptemp,rom_offs);
			namco_63701[ch].position:=(ptemp^ shl 8);
      inc(ptemp);
      namco_63701[ch].position:=namco_63701[ch].position+ptemp^;
			// bits 6-7 = volume */
			namco_63701[ch].volume:=valor shr 6;
			// bits 0-5 = counter to indicate new sample start? we don't use them */
			namco_63701[ch].silence_counter:=0;
    end;
  end;
end;

end.
