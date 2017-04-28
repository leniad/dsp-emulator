unit namco_snd;

interface
uses {$IFDEF WINDOWS}windows,{$else}main_engine,{$ENDIF}
     sound_engine,timer_engine;

const
  max_voices=8;

type
  tipo_voice=record
            volume:byte;
            numero_onda:byte;
            frecuencia:integer;
            activa:boolean;
            dentro_onda:dword;
         end;
  tnamco_63701=record
            select:integer;
	          playing:boolean;
	          base_addr,position,volume,silence_counter:integer;
            timer,tsample:byte;
            signal:integer;
          end;

  namco_snd_chip=class(snd_chip_class)
        constructor create(num_voces:byte;wave_ram:boolean=false);
        destructor free;
      public
        enabled:boolean;
        regs:array[0..$3F] of byte;
        procedure update;
        procedure reset;
        function get_wave_dir:pbyte;
        procedure namcos1_sound_w(direccion:word;valor:byte);
        procedure namcos1_cus30_w(direccion:word;valor:byte);
        function namcos1_cus30_r(direccion:word):byte;
        function save_snapshot(data:pbyte):word;
        procedure load_snapshot(data:pbyte);
      private
        onda:array[0..$ff] of byte;
        ram:array[0..$3ff] of byte;
        num_voces:byte;
        namco_wave:array[0..$1ff] of byte;
        wave_on_ram:boolean;
        voice:array[0..(max_voices-1)] of tipo_voice;
        procedure update_waveform(offset:word;data:byte);
  end;

//ADPCM sound
procedure namco_63701x_start(clock:dword);
procedure namco_63701x_close;
procedure namco_63701x_update;
procedure namco_63701x_w(dir:word;valor:byte);
procedure namco_63701x_internal_update;
procedure namco_63701x_reset;

var
  namco_63701:array[0..1] of tnamco_63701;
  namco_63701_rom:pbyte;
  namco_snd_0:namco_snd_chip;

implementation

const
  CONST_RE96=round(96000000/freq_base_audio);
  CONST_RE24=round(24000000/freq_base_audio);

constructor namco_snd_chip.create(num_voces:byte;wave_ram:boolean=false);
begin
  self.num_voces:=num_voces;
  self.wave_on_ram:=wave_ram;
  self.tsample_num:=init_channel;
end;

destructor namco_snd_chip.free;
begin
end;

function namco_snd_chip.get_wave_dir:pbyte;
begin
  get_wave_dir:=@self.onda;
end;

procedure namco_snd_chip.update_waveform(offset:word;data:byte);
begin
	if self.wave_on_ram then begin
		// use full byte, first 4 high bits, then low 4 bits */
    self.namco_wave[offset*2]:=(data shr 4) and $0f;
    self.namco_wave[offset*2+1]:=data and $0f;
  end else begin
		// use only low 4 bits */
    self.namco_wave[offset]:=data and $0f;
  end;
end;

procedure namco_snd_chip.reset;
var
  f:byte;
begin
self.enabled:=true;
for f:=0 to (max_voices-1) do begin
  self.voice[f].volume:=0;
  self.voice[f].numero_onda:=0;
  self.voice[f].frecuencia:=0;
  self.voice[f].activa:=false;
  self.voice[f].dentro_onda:=0;
end;
for f:=0 to $3f do self.regs[f]:=0;
if not(self.wave_on_ram) then
  for f:=0 to $ff do self.update_waveform(f,self.onda[f]);
end;

procedure getvoice_3(numero_voz:byte);inline;
var
  base:byte;
  f:integer;
begin
    base:=5*numero_voz;
    // Registro $5 --> Elegir la onda a reproducir
    namco_snd_0.voice[numero_voz].numero_onda:=namco_snd_0.regs[$5+base] and 7;
    // Registro $15 --> Volumen de la onda
    namco_snd_0.voice[numero_voz].volume:=(namco_snd_0.regs[$15+base] and $F) shr 1;
    // Resgistros $11, $12 y $14 --> Frecuencia
    // Si la voz es la 0 hay un registro mas de frecuencia
    f:=(namco_snd_0.regs[$14+base] and $f) shl 16;
    f:=f or ((namco_snd_0.regs[$13+base] and $f) shl 12);
    f:=f or ((namco_snd_0.regs[$12+base] and $f) shl 8);
    f:=f or ((namco_snd_0.regs[$11+base] and $f) shl 4);
    if numero_voz=0 then f:=f or(namco_snd_0.regs[$10] and $F);
    namco_snd_0.voice[numero_voz].frecuencia:=f*CONST_RE96; //resample -> (96Mhz/44100)
    if ((namco_snd_0.voice[numero_voz].frecuencia=0) or (namco_snd_0.voice[numero_voz].volume=0)) then begin
        namco_snd_0.voice[numero_voz].activa:=false;
        namco_snd_0.voice[numero_voz].dentro_onda:=0;
    end else namco_snd_0.voice[numero_voz].activa:=true;
end;

procedure getvoice_8(numero_voz:byte);inline;
var
  base:byte;
  f:integer;
begin
    base:=($8*numero_voz)+$3;
    // Registro $3 --> Elegir la onda a reproducir
    namco_snd_0.voice[numero_voz].numero_onda:=namco_snd_0.regs[$3+base] shr 4;
    // Registro $0 --> Volumen de la onda
    namco_snd_0.voice[numero_voz].volume:=(namco_snd_0.regs[$0+base] and $F) shr 1;
    // Resgistros $1, $2 y $3 --> Frecuencia
    f:=namco_snd_0.regs[$1+base];
    f:=f or (namco_snd_0.regs[$2+base] shl 8);
    f:=f or ((namco_snd_0.regs[$3+base] and $f) shl 16);
    namco_snd_0.voice[numero_voz].frecuencia:=f*CONST_RE24;  //resample -> (24Mhz/44100)
    if ((namco_snd_0.voice[numero_voz].frecuencia=0) and (namco_snd_0.voice[numero_voz].volume=0)) then begin
        namco_snd_0.voice[numero_voz].activa:=false;
        namco_snd_0.voice[numero_voz].dentro_onda:=0;
    end else namco_snd_0.voice[numero_voz].activa:=true;
end;

procedure namco_snd_chip.update;
var
  numero_voz,wave_data:byte;
  sample,offset:integer;
begin
    if not(self.enabled) then exit;
    sample:=0;
    for numero_voz:=0 to self.num_voces-1 do begin
        if not(self.wave_on_ram) then begin
          if self.num_voces=3 then getvoice_3(numero_voz)
            else getvoice_8(numero_voz);
        end;
        if voice[numero_voz].activa then begin
            offset:=voice[numero_voz].dentro_onda;
            wave_data:=32*voice[numero_voz].numero_onda;
            sample:=sample+((self.namco_wave[wave_data+((offset shr 25) and $1f)]*voice[numero_voz].volume) shl 6);
            voice[numero_voz].dentro_onda:=offset+voice[numero_voz].frecuencia;
        end;
    end;
    sample:=(sample div self.num_voces)*4;
    if sample>32767 then tsample[self.tsample_num,sound_status.posicion_sonido]:=32767
      else tsample[self.tsample_num,sound_status.posicion_sonido]:=sample;
end;

//Namco System1
procedure namco_snd_chip.namcos1_sound_w(direccion:word;valor:byte);
var
  ch:byte;
begin
	if (self.regs[direccion]=valor) then exit;
	// set the register */
  self.regs[direccion]:=valor;
	ch:=direccion div 8;
	// recompute the voice parameters */
	case (direccion-ch*8) of
	$00:self.voice[ch].volume:=valor and $0f;
	$01:self.voice[ch].numero_onda:=(valor shr 4) and $f;
	$02,$03:begin	// the frequency has 20 bits */
		        self.voice[ch].frecuencia:=(self.regs[ch*8+$01] and 15) shl 16;	// high bits are from here
        		self.voice[ch].frecuencia:=self.voice[ch].frecuencia+(self.regs[ch*8+$02] shl 8);
        		self.voice[ch].frecuencia:=(self.voice[ch].frecuencia+self.regs[ch*8+$03])*544;
      end;
{	$04:begin
		    voice->volume[1] = data & 0x0f;
		    nssw = ((data & 0x80) >> 7);
		    if (++voice == chip->last_channel)
			      voice = chip->channel_list;
		    voice->noise_sw = nssw;
      end;}
	end;
  if ((self.voice[ch].frecuencia=0) and (self.voice[ch].volume=0)) then begin
        self.voice[ch].activa:=false;
        self.voice[ch].dentro_onda:=0;
    end else self.voice[ch].activa:=true;
end;

//Namco CUS30
procedure namco_snd_chip.namcos1_cus30_w(direccion:word;valor:byte);
begin
  case direccion of
    0..$ff:begin
        	  	if (self.ram[direccion]<>valor) then begin
        		  	self.ram[direccion]:=valor;
        		  	// update the decoded waveform table */
        		  	self.update_waveform(direccion,valor);
             end;
           end;
    $100..$13f:self.namcos1_sound_w(direccion and $3f,valor);
    $140..$3ff:self.ram[direccion]:=valor;
    end;
end;

function namco_snd_chip.namcos1_cus30_r(direccion:word):byte;
begin
  namcos1_cus30_r:=self.ram[direccion];
end;

function namco_snd_chip.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
  f:byte;
begin
  temp:=data;
  size:=0;
  for f:=0 to 7 do copymemory(temp,@self.voice[f],sizeof(tipo_voice));inc(temp,sizeof(tipo_voice));size:=size+sizeof(tipo_voice);
  copymemory(temp,@self.enabled,sizeof(boolean));inc(temp,sizeof(boolean));size:=size+sizeof(boolean);
  copymemory(temp,@self.regs,$40);inc(temp,$40);size:=size+$40;
  copymemory(temp,@self.ram,$400);size:=size+$400;
  save_snapshot:=size;
end;

procedure namco_snd_chip.load_snapshot(data:pbyte);
var
  temp:pbyte;
  f:byte;
begin
  temp:=data;
  for f:=0 to 7 do copymemory(@self.voice[f],temp,sizeof(tipo_voice));inc(temp,sizeof(tipo_voice));
  copymemory(@self.enabled,temp,sizeof(boolean));inc(temp,sizeof(boolean));
  copymemory(@self.regs,temp,$40);inc(temp,$40);
  copymemory(@self.ram,temp,$400);
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
