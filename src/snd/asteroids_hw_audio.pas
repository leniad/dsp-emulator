unit asteroids_hw_audio;

interface
uses sound_engine,samples;

procedure asteroid_sound_update(hay_samples:boolean);
procedure asteroid_sound_init;
procedure asteroid_explode_w(data:byte;hay_samples:boolean);
procedure asteroid_thump_w(data:byte);
procedure asteroid_sounds_w(offset,data:byte);

implementation
const
  VMAX=32767;
  VMIN=0;

  SAUCEREN   =0;
  SAUCRFIREEN=1;
  SAUCERSEL  =2;
  THRUSTEN   =3;
  SHIPFIREEN =4;
  LIFEEN     =5;

  EXPITCH0 =(1 shl 6);
  EXPITCH1 =(1 shl 7);
  EXPAUDSHIFT=2;
  EXPAUDMASK=($0f shl EXPAUDSHIFT);
var
  explosion_latch:integer;
  thump_latch:integer;
  sound_latch:array[0..7] of byte;

  polynome:integer;
  thump_frequency:integer;

  discharge:array[0..$7fff] of integer;
  vol_explosion:array[0..15] of integer;
  //explosion
  counter_exp, sample_counter_exp:integer;
	out_exp:integer;
  //Thrust
  counter_thr,out_thr,amp_thr:integer;
  //Thump
  counter_thu,out_thu:integer;
  //Saucer
  vco_sau,vco_charge_sau,vco_counter_sau,out_sau,counter_sau:integer;
  //Saucerfire
  vco_sfi,vco_counter_sfi,amp_sfi,amp_counter_sfi,out_sfi,counter_sfi:integer;
  //Shipfire
  vco_shi,vco_counter_shi,amp_shi,amp_counter_shi,out_shi,counter_shi:integer;
  //Life
  counter_lif, out_lif:integer;
  tsample_as:byte;

function EXP_ast(charge,n:integer):integer;inline;
begin
 if charge<>0 then EXP_ast:=$7fff-discharge[$7fff-n]
  else EXP_ast:=discharge[n];
end;

function NE555_T1(Ra,Rb:integer;C:single):integer;inline;
begin
  NE555_T1:=round(VMAX*2/3/(0.639*((Ra)+(Rb))*(C)));
end;

function NE555_T2(Rb:integer;C:single):integer;inline;
begin
  NE555_T2:=round(VMAX*2/3/(0.639*(Rb)*(C)));
end;

function NE555_F(Ra,Rb,C:integer):integer;inline;
begin
  NE555_F:=round(1.44/(((Ra)+2*(Rb))*(C)));
end;

function explosion:integer;inline;
begin
	counter_exp:=counter_exp-12000;
	while (counter_exp <= 0) do begin
		counter_exp:=counter_exp+freq_base_audio; //samplerate
		if (((polynome and $4000)=0) and ((polynome and $0040)=0)) then
			polynome:= (polynome shl 1) or 1
		else polynome:=polynome shl 1;
    sample_counter_exp:=sample_counter_exp+1;
		if (sample_counter_exp=16) then begin
			sample_counter_exp:=0;
			if (explosion_latch and EXPITCH0)<>0 then sample_counter_exp:=sample_counter_exp or (2 + 8)
			  else sample_counter_exp:=sample_counter_exp or 4;
			if (explosion_latch and EXPITCH1 )<>0 then sample_counter_exp:=sample_counter_exp or (1 + 8);
		end;
		// ripple count output is high? */
		if (sample_counter_exp=15) then out_exp:= polynome and 1;
	end;
	if (out_exp<>0) then begin
		explosion:=vol_explosion[(explosion_latch and EXPAUDMASK) shr EXPAUDSHIFT];
    exit;
  end;
explosion:=0;
end;

function thrust:integer;inline;
begin
  if (sound_latch[THRUSTEN]<>0) then begin
		// SHPSND filter */
		counter_thr:=counter_thr-110;
		while (counter_thr<= 0) do begin
			counter_thr:=counter_thr+freq_base_audio;// samplerate;
			out_thr:=polynome and 1;
		end;
		if (out_thr<>0) then begin
			if (amp_thr<VMAX) then
				amp_thr:=amp_thr+round((VMAX - amp_thr) * 32768 / 32 / freq_base_audio + 1);
		end	else begin
			if (amp_thr>VMIN) then
				amp_thr:=amp_thr - round(amp_thr * 32768 / 32 / freq_base_audio + 1);
		end;
		thrust:=amp_thr;
    exit;
	end;
  thrust:=0;
end;

function thump:integer;inline;
begin
  if (thump_latch and $10)<>0 then begin
		counter_thu:=counter_thu-thump_frequency;
		while (counter_thu<= 0) do begin
			counter_thu:=counter_thu+freq_base_audio;// samplerate;
			out_thu:=out_thu xor 1;
		end;
		if (out_thu<>0) then begin
      thump:=VMAX;
      exit;
    end;
	end;
  thump:=0;
end;

function saucer:integer;inline;
var
	v5:single;
  steps:integer;
begin
    // saucer sound enabled ? */
	if (sound_latch[SAUCEREN]<>0) then begin
		{ NE555 setup as astable multivibrator:
		 * C = 10u, Ra = 5.6k, Rb = 10k
		 * or, with /SAUCERSEL being low:
		 * C = 10u, Ra = 5.6k, Rb = 6k (10k parallel with 15k)}
		if (vco_charge_sau<>0) then begin
			if (sound_latch[SAUCERSEL]<>0) then
				vco_counter_sau:=vco_counter_sau-NE555_T1(5600,10000,10e-6)
			else vco_counter_sau:=vco_counter_sau-NE555_T1(5600,6000,10e-6);
			if (vco_counter_sau<= 0) then begin
				steps:=round(-vco_counter_sau / freq_base_audio) + 1;
				vco_counter_sau:=vco_counter_sau+steps *freq_base_audio;
        vco_sau:=vco_sau+steps;
				if (vco_sau >= VMAX*2/3) then begin
					vco_sau:=round(VMAX*2/3);
					vco_charge_sau:= 0;
        end;
      end;
		end	else begin
			if (sound_latch[SAUCERSEL]<>0) then
				vco_counter_sau:=vco_counter_sau-NE555_T2(10000,10e-6)
			else vco_counter_sau:=vco_counter_sau-NE555_T2(6000,10e-6);
			if (vco_counter_sau <= 0) then begin
				steps:=round(-vco_counter_sau / freq_base_audio) + 1;
				vco_counter_sau:=vco_counter_sau+steps * freq_base_audio;
        vco_sau:=vco_sau-steps;
				if (vco_sau <= VMAX*1/3 ) then begin
					vco_sau:=round(VMIN*1/3);
					vco_charge_sau:= 1;
				end;
			end;
		end;
		 {* NE566 voltage controlled oscillator
		 * Co = 0.047u, Ro = 10k
		 * to = 2.4 * (Vcc - V5) / (Ro * Co * Vcc)}
		if (sound_latch[SAUCERSEL]<>0) then
			v5:= 12.0 - 1.66 - 5.0 * EXP_ast(vco_charge_sau,vco_sau) / 32768
		else
			v5:= 11.3 - 1.66 - 5.0 * EXP_ast(vco_charge_sau,vco_sau) / 32768;
		counter_sau:=counter_sau-trunc(2.4 * (12.0 - v5) / (10000 * 0.047e-6 * 12.0));
		while (counter_sau<= 0) do begin
			counter_sau:=counter_sau+freq_base_audio;
			out_sau:=out_sau xor 1;
		end;
		if (out_sau<>0) then begin
      saucer:=VMAX;
      exit;
    end;
  end;
	saucer:=0;
end;

function saucerfire:integer;inline;
const
  C38_CHARGE_TIME=VMAX;
  C39_DISCHARGE_TIME=VMAX;
var
  n:integer;
begin
    if (sound_latch[SAUCRFIREEN]<>0) then begin
		if (vco_sfi<VMAX*12/5 ) then begin
			// charge C38 (10u) through R54 (10K) from 5V to 12V */
			vco_counter_sfi:=vco_counter_sfi-C38_CHARGE_TIME;
			while (vco_counter_sfi<= 0) do begin
				vco_counter_sfi:=vco_counter_sfi+freq_base_audio;// += samplerate;
        vco_sfi:=vco_sfi+1;
				if (vco_sfi=VMAX*12/5 ) then break;
			end;
		end;
		if (amp_sfi>VMIN ) then begin
			{ discharge C39 (10u) through R58 (10K) and diode CR6,
			 * but only during the time the output of the NE555 is low.}
			if (out_sfi<>0) then begin
				amp_counter_sfi:=amp_counter_sfi-C39_DISCHARGE_TIME;
				while (amp_counter_sfi<=0) do begin
					amp_counter_sfi:=amp_counter_sfi+freq_base_audio;//= samplerate;
          amp_sfi:=amp_sfi-1;
					if (amp_sfi=VMIN) then break;
				end;
			end;
		end;
		if (out_sfi<>0) then begin
			{ C35 = 1u, Ra = 3.3k, Rb = 680
			 * discharge = 0.693 * 680 * 1e-6 = 4.7124e-4 -> 2122 Hz}
			counter_sfi:=counter_sfi-2122;
			if (counter_sfi<= 0 ) then begin
				n:=round(-counter_sfi / freq_base_audio)+1;
				counter_sfi:=counter_sfi+n * freq_base_audio;
				out_sfi:=0;
			end;
		end else begin
			{ C35 = 1u, Ra = 3.3k, Rb = 680
			 * charge 0.693 * (3300+680) * 1e-6 = 2.75814e-3 -> 363Hz}
			counter_sfi:=counter_sfi-round(363 * 2 * (VMAX*12/5-vco_sfi) / 32768);
			if (counter_sfi <= 0 ) then begin
				n:=round(-counter_sfi / freq_base_audio)+1;
				counter_sfi:=counter_sfi+n * freq_base_audio;
				out_sfi:=1;
			end;
		end;
    if (out_sfi)<>0 then begin
			saucerfire:=amp_sfi;
      exit;
    end;
	end else begin
		// charge C38 and C39 */
		amp_sfi:= VMAX;
		vco_sfi:= VMAX;
	end;
	saucerfire:=0;
end;

function shipfire:integer;inline;
const
  C47_CHARGE_TIME=(VMAX * 3);
  C48_DISCHARGE_TIME=(VMAX * 3);
var
  n:integer;
begin
    if (sound_latch[SHIPFIREEN]<>0) then begin
		if (vco_shi< VMAX*12/5 ) then begin
			// charge C47 (1u) through R52 (33K) and Q3 from 5V to 12V */
			vco_counter_shi:=vco_counter_shi-C47_CHARGE_TIME;
			while (vco_counter_shi<=0) do begin
				vco_counter_shi:=vco_counter_shi+freq_base_audio;
        vco_shi:=vco_shi+1;
				if (vco_shi= VMAX*12/5 ) then break;
			end;
    end;
		if (amp_shi>VMIN) then begin
			{ discharge C48 (10u) through R66 (2.7K) and CR8,
			 * but only while the output of theNE555 is low.}
			if (out_shi<>0) then begin
				amp_counter_shi:=amp_counter_shi-C48_DISCHARGE_TIME;
				while (amp_counter_shi<= 0) do begin
					amp_counter_shi:=amp_counter_shi+freq_base_audio;
          amp_shi:=amp_shi-1;
					if (amp_shi=VMIN ) then break;
				end;
			end;
		end;

		if (out_shi)<>0 then begin
			{ C50 = 1u, Ra = 3.3k, Rb = 680
			 * discharge = 0.693 * 680 * 1e-6 = 4.7124e-4 -> 2122 Hz}
			counter_shi:=counter_shi-2122;
			if (counter_shi<= 0) then begin
				n:=round(-counter_shi/freq_base_audio)+1;
				counter_shi:=counter_shi+n*freq_base_audio;
				out_shi:=0;
			end;
		end	else begin
			{ C50 = 1u, Ra = R65 (3.3k), Rb = R61 (680)
			 * charge = 0.693 * (3300+680) * 1e-6) = 2.75814e-3 -> 363Hz}
			counter_shi:=counter_shi-round(363 * 2 * (VMAX*12/5-vco_shi) / 32768);
			if (counter_shi<= 0 ) then begin
				n:=round(-counter_shi /freq_base_audio)+ 1;
				counter_shi:=counter_shi+ n *freq_base_audio;
				out_shi:= 1;
			end;
		end;
		if (out_shi<>0) then begin
			shipfire:=amp_shi;
      exit;
    end;
	end else begin
		// charge C47 and C48 */
		amp_shi:= VMAX;
		vco_shi:= VMAX;
	end;
	shipfire:=0;
end;

function life:integer;inline;
begin
    if (sound_latch[LIFEEN]<>0) then begin
		counter_lif:=counter_lif-3000;
		while (counter_lif<= 0 ) do begin
			counter_lif:=counter_lif+freq_base_audio;//= samplerate;
			out_lif:=out_lif xor 1;
		end;
		if (out_lif<>0) then begin
			life:=VMAX;
      exit;
    end;
	end;
	life:=0;
end;

procedure asteroid_sound_update(hay_samples:boolean);
var
  sum:integer;
begin
     sum:=trunc(thrust/7);
     sum:=sum+trunc(thump/7);
     sum:=sum+trunc(saucer/7);
     sum:=sum+trunc(saucerfire/7);
     sum:=sum+trunc(shipfire/7);
     sum:=sum+trunc(life/7);
     if not(hay_samples) then sum:=sum+trunc(explosion/7)
      else samples_update;
     if sum>32767 then sum:=32767
       else if sum<-32767 then sum:=-32767;
    tsample[tsample_as,sound_status.posicion_sonido]:=sum;
end;

procedure explosion_init;
var
	i:integer;
  r0,r1:single;
begin
    for i:=0 to 15 do begin
        // r0 = open, r1 = open */
        r0:=1.0/1e12;
        r1:=1.0/1e12;
        // R14 */
        if (i and 1)<>0 then r1:=r1+ 1.0/47000
          else r0:=r0+ 1.0/47000;
        // R15 */
        if (i and 2)<>0 then r1:=r1+1.0/22000
          else r0:=r0+1.0/22000;
        // R16 */
        if (i and 4)<>0 then r1:=r1+1.0/12000
          else r0:=r0+1.0/12000;
        // R17 */
        if (i and 8)<>0 then r1:=r1+1.0/5600
          else r0:=r0+1.0/5600;
        r0:=1.0/r0;
        r1:=1.0/r1;
        vol_explosion[i]:=trunc( VMAX * r0 / (r0 + r1));
    end;
end;

procedure asteroid_sound_init;
var
  i:integer;
begin
    for i:=0 to $7fff do
		  discharge[$7fff-i]:=trunc($7fff/exp(1.0*i/4096));
	  // initialize explosion volume lookup table */
    explosion_init;
    tsample_as:=init_channel;
end;

procedure asteroid_explode_w(data:byte;hay_samples:boolean);
begin
if hay_samples then begin
  if (data and $3c)<>0 then
    case (data shr 6) of
      0,1:start_sample(0);
      2:start_sample(1);
      3:start_sample(2);
    end;
end else if (data<>explosion_latch) then explosion_latch:=data;
end;

procedure asteroid_thump_w(data:byte);
var
  r0,r1:single;
begin
	r0:=1/47000;
  r1:= 1/1e12;
  if (data=thump_latch ) then exit;
	thump_latch:= data;
	if( thump_latch and 1)<>0 then r1:=r1+1.0/220000
	  else r0:=r0+ 1.0/220000;
	if (thump_latch and 2)<>0 then r1:=r1+1.0/100000
	  else r0:=r0+1.0/100000;
	if (thump_latch and 4 )<>0 then r1:=r1+1.0/47000
	  else r0:=r0+1.0/47000;
	if (thump_latch and 8)<>0 then r1:=r1+1.0/22000
	  else r0:=r0+1.0/22000;
	{ NE555 setup as voltage controlled astable multivibrator
	 * C = 0.22u, Ra = 22k...???, Rb = 18k
	 * frequency = 1.44 / ((22k + 2*18k) * 0.22n) = 56Hz .. huh?}
	thump_frequency:=round(56 + 56 * r0 / (r0 + r1));
end;

procedure asteroid_sounds_w(offset,data:byte);
begin
	data:=data and $80;
  if (data=sound_latch[offset]) then exit;
	sound_latch[offset]:=data;
end;

end.
