unit phoenix_audio_digital;

interface
uses sound_engine;

procedure phoenix_audio_reset;
procedure phoenix_audio_update;
procedure phoenix_audio_cerrar;
procedure phoenix_audio_start;
procedure phoenix_wsound_a(valor:byte);
procedure phoenix_wsound_b(valor:byte);

implementation
uses principal,sysutils;

type
  phoenix_voz=record
      frec:byte;
      vol:byte;
      activa:boolean;
      dentro_onda:integer;
      tsample:byte;
  end;
  pphoenix_voz=^phoenix_voz;
  c_state=record
	    counter:integer;
	    level:integer;
  end;
  n_state=record
	  counter:integer;
	  polyoffs:integer;
	  polybit:integer;
	  lowpass_counter:integer;
	  lowpass_polybit:integer;
    tsample:byte;
  end;

const
  phoenix_wave:array[0..31] of byte=(
        $07,$06,$05,$03,$03,$04,$04,$03,$03,$04,$03,$06,$07,$07,$06,$00,
	      $73,$6F,$70,$73,$76,$73,$74,$74,$74,$76,$76,$76,$74,$70,$70,$74);
  VMIN=0;
  VMAX=32767;

var
  phoenix_sound:array[0..1] of pphoenix_voz;
  poly18:array[0..8191] of cardinal;
  sound_latch_a:byte;
  c24_state,c25_state:c_state;
  noise_state:n_state;

procedure phoenix_audio_reset;
begin
  phoenix_sound[0].activa:=false;
  phoenix_sound[1].activa:=false;
end;

procedure phoenix_audio_start;
var
  i,j:integer;
  shiftreg,bits:cardinal;
begin
  getmem(phoenix_sound[0],sizeof(phoenix_voz));
  getmem(phoenix_sound[1],sizeof(phoenix_voz));
  fillchar(phoenix_sound[0]^,sizeof(phoenix_voz),0);
  fillchar(phoenix_sound[1]^,sizeof(phoenix_voz),0);
  phoenix_sound[0].tsample:=init_channel;
  phoenix_sound[1].tsample:=init_channel;
  noise_state.tsample:=init_channel;
  //Audio digital
  fillchar(c24_state,sizeof(c_state),0);
  fillchar(c25_state,sizeof(c_state),0);
  fillchar(noise_state,sizeof(c_state),0);
  sound_latch_a:=0;
  shiftreg:=0;
	for i:=0 to 8191 do begin
		bits:=0;
		for j:=0 to 31 do begin
			bits:=(bits shr 1) or (shiftreg shl 31);
			if (((shiftreg shr 16) and 1)=((shiftreg shr 17) and 1)) then
				shiftreg:= (shiftreg shl 1) or 1
			else
				shiftreg:=shiftreg shl 1;
		end;
		poly18[i]:= bits;
	end;
end;

procedure phoenix_audio_cerrar;
begin
  freemem(phoenix_sound[0]);
  freemem(phoenix_sound[1]);
  phoenix_sound[0]:=nil;
  phoenix_sound[1]:=nil;
end;

function update_c24(samplerate:integer):integer;inline;
var
	n:integer;
  temp:extended;
    {* Noise frequency control (Port B):
     * Bit 6 lo charges C24 (6.8u) via R51 (330) and when
     * bit 6 is hi, C24 is discharged through R52 (20k)
     * in approx. 20000 * 6.8e-6 = 0.136 seconds}
const
	C24=6.8e-6;
	R49=1000;
  R51=330;
	R52=20000;
begin
	if (sound_latch_a and $40)<>0 then begin
		if (c24_state.level > VMIN) then begin
      temp:=(c24_state.level - VMIN)/(R52 * C24);
			c24_state.counter:=c24_state.counter-trunc(temp);
			if (c24_state.counter<=0) then begin
				temp:= -c24_state.counter / samplerate + 1;
        n:=trunc(temp);
				c24_state.counter:=c24_state.counter+(n* samplerate);
        c24_state.level:=c24_state.level-n;
				if (c24_state.level<VMIN) then c24_state.level:= VMIN;
			end;
		end;
    end	else begin
		  if (c24_state.level< VMAX) then begin
        temp:=(VMAX-c24_state.level) / ((R51+R49) * C24);
			  c24_state.counter:=c24_state.counter-trunc(temp);
			  if (c24_state.counter<= 0) then begin
          temp:=-c24_state.counter/ samplerate + 1;
				  n:=trunc(temp);
				  c24_state.counter:=c24_state.counter+(n * samplerate);
          c24_state.level:=c24_state.level+n;
				  if (c24_state.level>VMAX) then c24_state.level:=VMAX;
        end;
		end;
  end;
	update_c24:=VMAX-c24_state.level;
end;

function update_c25(samplerate:integer):integer;inline;
var
	n:integer;
  temp:extended;
  {  * Bit 7 hi charges C25 (6.8u) over a R50 (1k) and R53 (330) and when
     * bit 7 is lo, C25 is discharged through R54 (47k)
     * in about 47000 * 6.8e-6 = 0.3196 seconds}
const
	C25=6.8e-6;
	R50=1000;
  R53=330;
	R54=47000;
begin
	if (sound_latch_a and $80)<>0 then begin
		if (c25_state.level< VMAX) then begin
      temp:=(VMAX -c25_state.level) / ((R50+R53) * C25);
			c25_state.counter:=c25_state.counter-trunc(temp);
			if (c25_state.counter<= 0) then begin
        temp:=-c25_state.counter/samplerate + 1;
				n:=trunc(temp);
				c25_state.counter:=c25_state.counter+(n * samplerate);
        c25_state.level:=c25_state.level+n;
				if (c25_state.level> VMAX ) then c25_state.level:= VMAX;
			end;
		end;
	end else begin
		if (c25_state.level> VMIN) then begin
      temp:=(c25_state.level- VMIN) / (R54 * C25);
			c25_state.counter:=c25_state.counter-trunc(temp);
			if (c25_state.counter<= 0 ) then begin
        temp:=-c25_state.counter / samplerate + 1;
				n:=trunc(temp);
				c25_state.counter:=c25_state.counter+(n*samplerate);
        c25_state.level:=c25_state.level-n;
				if (c25_state.level< VMIN ) then c25_state.level:=VMIN;
			end;
		end;
	end;
	update_c25:=c25_state.level;
end;

function noise(samplerate:integer):integer;inline;
var
  vc24,vc25,sum,n:integer;
  level,frequency,temp:extended;
begin
	vc24:=update_c24(44100);
	vc25:=update_c25(44100);
	sum:=0;
   { * The voltage levels are added and control I(CE) of transistor TR1
     * (NPN) which then controls the noise clock frequency (linearily?).
     * level = voltage at the output of the op-amp controlling the noise rate.}
	if( vc24 < vc25 ) then level:= vc24 + (vc25 - vc24) / 2
	  else level:= vc25 + (vc24 - vc25) / 2;
	frequency:= 588 + 6325 * level / 32768;
   { * NE555: Ra=47k, Rb=1k, C=0.05uF
     * minfreq = 1.44 / ((47000+2*1000) * 0.05e-6) = approx. 588 Hz
     * R71 (2700 Ohms) parallel to R73 (47k Ohms) = approx. 2553 Ohms
     * maxfreq = 1.44 / ((2553+2*1000) * 0.05e-6) = approx. 6325 Hz }
	noise_state.counter:=noise_state.counter-trunc(frequency);
	if (noise_state.counter <= 0) then begin
    temp:=(-noise_state.counter / samplerate) + 1;
		n:=trunc(temp);
		noise_state.counter:=noise_state.counter+(n * samplerate);
		noise_state.polyoffs:= (noise_state.polyoffs + n) and $3ffff;
		noise_state.polybit:= (poly18[noise_state.polyoffs shr 5] shr (noise_state.polyoffs and 31)) and 1;
	end;
	if (noise_state.polybit=0) then sum:=sum+vc24;
	  // 400Hz crude low pass filter: this is only a guess!! */
	  noise_state.lowpass_counter:=noise_state.lowpass_counter-400;
	  if (noise_state.lowpass_counter<=0) then begin
		  noise_state.lowpass_counter:=noise_state.lowpass_counter+samplerate;
		  noise_state.lowpass_polybit:=noise_state.polybit;
	  end;
	  if (noise_state.lowpass_polybit=0) then sum:=sum+vc25;
	  noise:=sum;
end;

procedure phoenix_audio_update;
var
  numero_voz:byte;
  i:word;
  offset,offset_step:integer;
  sum:integer;
begin
for numero_voz:=0 to 1 do begin
  if phoenix_sound[numero_voz].activa then begin
    offset:=phoenix_sound[numero_voz].dentro_onda;
    offset_step:=(44100 div (16-phoenix_sound[numero_voz].frec));
    for i:=0 to (sound_status.long_sample-1) do begin
      offset:=offset+offset_step;
      tsample[phoenix_sound[numero_voz].tsample,i]:=phoenix_wave[(offset shr 16) and $1f]*($20*(3-phoenix_sound[numero_voz].vol));
    end;
    phoenix_sound[numero_voz].dentro_onda:=offset;
  end;
end;
for i:=0 to (sound_status.long_sample-1) do begin
    sum:=noise(44100) div 2;
    if sum>32767 then sum:=32767
      else if sum<-32768 then sum:=-32768;
    tsample[noise_state.tsample,i]:=sum;
end;
end;

procedure phoenix_wsound_a(valor:byte);
begin
sound_latch_a:=valor;
//form1.statusbar1.panels[2].text:=inttostr(valor and $f);
phoenix_sound[0].frec:=valor and $F;
phoenix_sound[0].vol:=(valor and $30) shr 4;
phoenix_sound[0].activa:=phoenix_sound[0].frec<$f;
end;

procedure phoenix_wsound_b(valor:byte);
begin
phoenix_sound[1].frec:=valor and $F;
phoenix_sound[1].vol:=(valor and $10) shr 4;
phoenix_sound[1].activa:=phoenix_sound[0].frec<$f;
end;

end.
