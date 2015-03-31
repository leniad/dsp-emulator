unit tms36xx;

interface
uses sound_engine;

const
   VMIN=$0000;
   VMAX=$7fff;
   A_1=0;A_2=1;A_3=2;A_4=3;A_5=4;
   Ax_1=5;Ax_2=6;Ax_3=7;Ax_4=8;Ax_5=9;
   B_1=10;B_2=11;B_3=12;B_4=13;B_5=14;B_0=60;
   C_1=15;C_2=16;C_3=17;C_4=18;C_5=19;
   Cx_1=20;Cx_2=21;Cx_3=22;Cx_4=23;Cx_5=24;
   D_1=25;D_2=26;D_3=27;D_4=28;D_5=29;
   Dx_1=30;Dx_2=31;Dx_3=32;Dx_4=33;Dx_5=34;
   E_1=35;E_2=36;E_3=37;E_4=38;E_5=39;
   F_1=40;F_2=41;F_3=42;F_4=43;F_5=44;
   Fx_1=45;Fx_2=46;Fx_3=47;Fx_4=48;Fx_5=49;
   G_1=50;G_2=51;G_3=52;G_4=53;G_5=54;
   Gx_1=55;Gx_2=56;Gx_3=57;Gx_4=58;Gx_5=59;
// the frequencies are later adjusted by "* clock / FSCALE" */
  FSCALE=1024;
  tune1_d:array[0..191] of byte=(
	C_3,	0,		0,		C_2,	0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		C_4,	0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		C_2,	0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		C_4,	0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0,
	C_3,	0,		0,		0,		0,		0,
	G_3,	0,		0,		0,		0,		0);

  tune2_d:array[0..287] of byte=(
	D_3,	D_4,	D_5,	0,		0,		0,
	Cx_3,	Cx_4,	Cx_5,	0,		0,		0,
	D_3,	D_4,	D_5,	0,		0,		0,
	Cx_3,	Cx_4,	Cx_5,	0,		0,		0,
	D_3,	D_4,	D_5,	0,		0,		0,
	A_2,	A_3,	A_4,	0,		0,		0,
	C_3,	C_4,	C_5,	0,		0,		0,
	Ax_2,	Ax_3,	Ax_4,	0,		0,		0,
	G_2,	G_3,	G_4,	0,		0,		0,
	D_1,	D_2,	D_3,	0,		0,		0,
	G_1,	G_2,	G_3,	0,		0,		0,
	Ax_1,	Ax_2,	Ax_3,	0,		0,		0,

	D_2,	D_3,	D_4,	0,		0,		0,
	G_2,	G_3,	G_4,	0,		0,		0,
	A_2,	A_3,	A_4,	0,		0,		0,
	D_1,	D_2,	D_3,	0,		0,		0,
	A_1,	A_2,	A_3,	0,		0,		0,
	D_2,	D_3,	D_4,	0,		0,		0,
	Fx_2,	Fx_3,	Fx_4,	0,		0,		0,
	A_2,	A_3,	A_4,	0,		0,		0,
	Ax_2,	Ax_3,	Ax_4,	0,		0,		0,
	D_1,	D_2,	D_3,	0,		0,		0,
	G_1,	G_2,	G_3,	0,		0,		0,
	Ax_1,	Ax_2,	Ax_3,	0,		0,		0,

	D_3,	D_4,	D_5,	0,		0,		0,
	Cx_3,	Cx_4,	Cx_5,	0,		0,		0,
	D_3,	D_4,	D_5,	0,		0,		0,
	Cx_3,	Cx_4,	Cx_5,	0,		0,		0,
	D_3,	D_4,	D_5,	0,		0,		0,
	A_2,	A_3,	A_4,	0,		0,		0,
	C_3,	C_4,	C_5,	0,		0,		0,
	Ax_2,	Ax_3,	Ax_4,	0,		0,		0,
	G_2,	G_3,	G_4,	0,		0,		0,
	D_1,	D_2,	D_3,	0,		0,		0,
	G_1,	G_2,	G_3,	0,		0,		0,
	Ax_1,	Ax_2,	Ax_3,	0,		0,		0,

	D_2,	D_3,	D_4,	0,		0,		0,
	G_2,	G_3,	G_4,	0,		0,		0,
	A_2,	A_3,	A_4,	0,		0,		0,
	D_1,	D_2,	D_3,	0,		0,		0,
	A_1,	A_2,	A_3,	0,		0,		0,
	D_2,	D_3,	D_4,	0,		0,		0,
	Ax_2,	Ax_3,	Ax_4,	0,		0,		0,
	A_2,	A_3,	A_4,	0,		0,		0,
	0,		0,		0,		G_2,	G_3,	G_4,
	D_1,	D_2,	D_3,	0,		0,		0,
	G_1,	G_2,	G_3,	0,		0,		0,
	0,		0,		0,		0,		0,		0);

  tune3_d:array[0..(96*6)-1] of byte = (
	A_2,	A_3,	A_4,	D_1,	 D_2,	  D_3,
	0,		0,		0,		0,		 0, 	  0,
	A_2,	A_3,	A_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	A_2,	A_3,	A_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	A_2,	A_3,	A_4,	A_1,	 A_2,	  A_3,
	0,		0,		0,		0,		 0, 	  0,
	G_2,	G_3,	G_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	F_2,	F_3,	F_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	F_2,	F_3,	F_4,	F_1,	 F_2,	  F_3,
	0,		0,		0,		0,		 0, 	  0,
	E_2,	E_3,	E_4,	F_1,	 F_2,	  F_3,
	0,		0,		0,		0,		 0, 	  0,
	D_2,	D_3,	D_4,	F_1,	 F_2,	  F_3,
	0,		0,		0,		0,		 0, 	  0,

	D_2,	D_3,	D_4,	A_1,	 A_2,	  A_3,
	0,		0,		0,		0,		 0, 	  0,
	F_2,	F_3,	F_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	A_2,	A_3,	A_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	D_3,	D_4,	D_5,	D_1,	 D_2,	  D_3,
	0,		0,		0,		0,		 0, 	  0,
	0,		0,		0,		D_1,	 D_2,	  D_3,
	0,		0,		0,		F_1,	 F_2,	  F_3,
	0,		0,		0,		A_1,	 A_2,	  A_3,
	0,		0,		0,		D_2,	 D_2,	  D_2,

	D_3,	D_4,	D_5,	D_1,	 D_2,	  D_3,
	0,		0,		0,		0,		 0, 	  0,
	C_3,	C_4,	C_5,	0,		 0, 	  0,
	0,		0,		0, 	  0,		 0, 	  0,
	Ax_2,	Ax_3,	Ax_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	Ax_2,	Ax_3,	Ax_4,	Ax_1,	 Ax_2,   Ax_3,
	0,		0,		0,		0,		 0, 	  0,
	A_2,	A_3,	A_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	G_2,	G_3,	G_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	G_2,	G_3,	G_4,	G_1,	 G_2,	  G_3,
	0,		0,		0,		0,		 0, 	  0,
	A_2,	A_3,	A_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	Ax_2,	Ax_3,	Ax_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	A_2,	A_3,	A_4,	A_1,	 A_2,	  A_3,
	0,		0,		0,		0,		 0, 	  0,
	Ax_2,	Ax_3,	Ax_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	A_2,	A_3,	A_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	Cx_3,	Cx_4,	Cx_5,	A_1,	 A_2,	  A_3,
	0,		0,		0,		0,		 0, 	  0,
	Ax_2,	Ax_3,	Ax_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	A_2,	A_3,	A_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	A_2,	A_3,	A_4,	F_1,	 F_2,	  F_3,
	0,		0,		0,		0,		 0, 	  0,
	G_2,	G_3,	G_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	F_2,	F_3,	F_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	F_2,	F_3,	F_4,	D_1,	 D_2,	  D_3,
	0,		0,		0,		0,		 0, 	  0,
	E_2,	E_3,	E_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	D_2,	D_3,	D_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	E_2,	E_3,	E_4,	E_1,	 E_2,	  E_3,
	0,		0,		0,		0,		 0, 	  0,
	E_2,	E_3,	E_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	E_2,	E_3,	E_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,

	E_2,	E_3,	E_4,	Ax_1,	 Ax_2,   Ax_3,
	0,		0,		0,		0,		 0, 	  0,
	F_2,	F_3,	F_4,	0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	E_2,	E_3,	E_4,	F_1,	 F_2,	  F_3,
	0,		0,		0,		0,		 0, 	  0,

	D_2,	D_3,	D_4,	D_1,	 D_2,	  D_3,
	0,		0,		0,		0,		 0, 	  0,
	F_2,	F_3,	F_4,	A_1,	 A_2,	  A_3,
	0,		0,		0,		0,		 0, 	  0,
	A_2,	A_3,	A_4,	F_1,	 F_2,	  F_3,
	0,		0,		0,		0,		 0, 	  0,

	D_3,	D_4,	D_5,	D_1,	 D_2,	  D_3,
	0,		0,		0,		0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0,
	0,		0,		0,		0,		 0, 	  0);

  tune4_d:array [0..(13*6)-1] of byte = (
//  16'     8'      5 1/3'  4'      2 2/3'  2'      */
	B_0,	B_1,	Dx_2,	B_2,	Dx_3,	B_3,
	C_1,	C_2,	E_2,	C_3,	E_3,	C_4,
	Cx_1,	Cx_2,	F_2,	Cx_3,	F_3,	Cx_4,
	D_1,	D_2,	Fx_2,	D_3,	Fx_3,	D_4,
	Dx_1,	Dx_2,	G_2,	Dx_3,	G_3,	Dx_4,
	E_1,	E_2,	Gx_2,	E_3,	Gx_3,	E_4,
	F_1,	F_2,	A_2,	F_3,	A_3,	F_4,
	Fx_1,	Fx_2,	Ax_2,	Fx_3,	Ax_3,	Fx_4,
	G_1,	G_2,	B_2,	G_3,	B_3,	G_4,
	Gx_1,	Gx_2,	C_3,	Gx_3,	C_4,	Gx_4,
	A_1,	A_2,	Cx_3,	A_3,	Cx_4,	A_4,
	Ax_1,	Ax_2,	D_3,	Ax_3,	D_4,	Ax_4,
	B_1,	B_2,	Dx_3,	B_3,	Dx_4,	B_4);


type

  TMS36XX_type=record
	  samplerate:integer; 	// from Machine->sample_rate */

	  basefreq:integer;		// chip's base frequency */
	  octave:integer; 		// octave select of the TMS3615 */

	  speed:integer;			// speed of the tune */
	  tune_counter:integer;	// tune counter */
	  note_counter:integer;	// note counter */

	  voices:integer; 		// active voices */
	  shift:integer;			// shift toggles between 0 and 6 to allow decaying voices */
	  vol:array[0..12-1] of integer;		// (decaying) volume of harmonics notes */
	  vol_counter:array[0..12-1] of integer;// volume adjustment counter */
	  decay:array[0..12-1] of integer;		// volume adjustment rate - dervied from decay */

	  counter:array[0..12-1] of integer;	// tone frequency counter */
	  frequency:array[0..12-1] of integer;	// tone frequency */
	  output:integer; 		// output signal bits */
	  enable:integer; 		// mask which harmoics */

	  tune_num:integer;		// tune currently playing */
	  tune_ofs:integer;		// note currently playing */
	  tune_max:integer;		// end of tune */
    tsample:byte;
  end;
  ptms36xx=^tms36xx_type;
var
  tms_chip:ptms36xx;
  tunes:array[0..4,0..(96*6)-1] of integer;

procedure tms36xx_sound_update;
procedure tms36xx_start(clock:integer;speed:extended;pdecay:pextended);
procedure mm6221aa_tune_w(tune:integer);
procedure tms36xx_close;

implementation

function C(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl (n-1))*1.18921;	// 2^(3/12) */
  c:=trunc(temp);
end;

function Cx(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl (n-1))*1.25992;	// 2^(4/12) */
  cx:=trunc(temp);
end;

function D(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl (n-1))*1.33484;	// 2^(5/12) */
  d:=trunc(temp);
end;

function Dx(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl (n-1))*1.41421;	// 2^(6/12) */
  Dx:=trunc(temp);
end;

function E(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl (n-1))*1.49831;	// 2^(7/12) */
  e:=trunc(temp);
end;

function F_n(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl (n-1))*1.58740;	// 2^(8/12) */
  f_n:=trunc(temp);
end;

function Fx(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl (n-1))*1.68179;	// 2^(9/12) */
  fx:=trunc(temp);
end;

function G(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl (n-1))*1.78180;	// 2^(10/12) */
  g:=trunc(temp);
end;

function Gx(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl (n-1))*1.88775;	// 2^(11/12) */
  gx:=trunc(temp);
end;
function A(n:byte):integer;inline;
begin
  a:=(FSCALE shl n);
end;

function Ax(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl n)*1.05946;		// 2^(1/12) */
  ax:=trunc(temp);
end;

function B(n:byte):integer;inline;
var
  temp:extended;
begin
	temp:=(FSCALE shl n)*1.12246;		// 2^(2/12) */
  b:=trunc(temp);
end;

procedure DECAY(voice:integer);inline;
begin
	if (tms_chip.vol[voice] > VMIN )	then begin
		// decay of first voice */
		tms_chip.vol_counter[voice]:=tms_chip.vol_counter[voice]-tms_chip.decay[voice];
		while (tms_chip.vol_counter[voice]<= 0 ) do begin
			tms_chip.vol_counter[voice]:=tms_chip.vol_counter[voice]+44100;//samplerate;
      tms_chip.vol[voice]:=tms_chip.vol[voice]-1;
			if( tms_chip.vol[voice]<= VMIN ) then begin
				tms_chip.frequency[voice]:= 0;
				tms_chip.vol[voice]:= VMIN;
				break;
			end;
		end;
  end;
end;

procedure RESTART(voice:integer);inline;
var
  temp:extended;
begin
	if (tunes[tms_chip.tune_num,tms_chip.tune_ofs*6+voice]<>0) then begin
    temp:=tunes[tms_chip.tune_num,tms_chip.tune_ofs*6+voice]*(tms_chip.basefreq shl tms_chip.octave)/FSCALE;
    tms_chip.frequency[tms_chip.shift+voice]:=round(temp);
		tms_chip.vol[tms_chip.shift+voice]:= VMAX;
	end;
end;

function TONE(voice:integer):integer;inline;
begin
  tone:=0;
	if (((tms_chip.enable and (1 shl voice))<>0) and (tms_chip.frequency[voice]<>0)) then begin
		// first note */
		tms_chip.counter[voice]:=tms_chip.counter[voice]-tms_chip.frequency[voice];
		while (tms_chip.counter[voice]<=0) do begin
			tms_chip.counter[voice]:=tms_chip.counter[voice]+44100;//= samplerate;
			tms_chip.output:=tms_chip.output xor (1 shl voice);
		end;
		if (tms_chip.output and tms_chip.enable and (1 shl voice)) <>0 then tone:=tms_chip.vol[voice];
	end;
end;

procedure tms36xx_sound_update;
var
  n,sum:integer;
  f:byte;
begin
    // no tune played? */
	if ((tms_chip.tune_num=0) or (tms_chip.voices=0)) then begin
		tsample[tms_chip.tsample,sound_status.posicion_sonido]:=0;
    exit;
  end;
  // decay the twelve voices */
  for f:=0 to 11 do DECAY(f);
  // musical note timing */
  tms_chip.tune_counter:=tms_chip.tune_counter-tms_chip.speed;
  if (tms_chip.tune_counter <= 0 ) then begin
    n:=trunc((-tms_chip.tune_counter/44100)+1);
    tms_chip.tune_counter:=tms_chip.tune_counter+(n*44100);//samplerate;
    tms_chip.note_counter:=tms_chip.note_counter-n;
    if (tms_chip.note_counter<=0) then begin
      tms_chip.note_counter:=tms_chip.note_counter+VMAX;
      if (tms_chip.tune_ofs < tms_chip.tune_max) then begin
        // shift to the other 'bank' of voices */
        tms_chip.shift:=tms_chip.shift xor 6;
        // restart one 'bank' of voices */
        for f:=0 to 5 do RESTART(f);
        tms_chip.tune_ofs:=tms_chip.tune_ofs+1;
      end;
    end;
  end;
  // update the twelve voices */
  sum:=0;
  for f:=0 to 11 do sum:=sum+TONE(f);
  tsample[tms_chip.tsample,sound_status.posicion_sonido]:=trunc(sum/tms_chip.voices);
end;

procedure mm6221aa_tune_w(tune:integer);
begin
    // which tune? */
    tune:=tune and 3;
    if (tune=tms_chip.tune_num) then exit;
    tms_chip.tune_num:= tune;
    tms_chip.tune_ofs:= 0;
    tms_chip.tune_max:= 96; // fixed for now */
end;

procedure tms36xx_reset_counters;
begin
    tms_chip.tune_counter:= 0;
    tms_chip.note_counter:= 0;
	  fillchar(tms_chip.vol_counter[0],sizeof(tms_chip.vol_counter),0);
	  fillchar(tms_chip.counter[0],sizeof(tms_chip.counter),0);
end;

procedure tms36xx_note_w(octave,note:integer);
begin
	octave:=octave and 3;
	note:=note and 15;

	if (note > 12) then exit;

	// play a single note from 'tune 4', a list of the 13 tones */
	tms36xx_reset_counters;
	tms_chip.octave:= octave;
  tms_chip.tune_num:=4;
	tms_chip.tune_ofs:= note;
	tms_chip.tune_max:= note + 1;
end;

procedure tms3617_enable(enable:integer);
var
  i,bits:integer;
begin
  bits:= 0;
	// duplicate the 6 voice enable bits */
  enable:= (enable and $3f) or ((enable and $3f) shl 6);
	if (enable=tms_chip.enable) then exit;

    for i:=0 to 5 do begin
		  if (enable and (1 shl i))<>0 then bits:=bits+2;	// each voice has two instances */
    end;
	// set the enable mask and number of active voices */
	tms_chip.enable:= enable;
  tms_chip.voices:= bits;
end;

procedure tms36xx_start(clock:integer;speed:extended;pdecay:pextended);
var
	j,f:integer;
	enable:integer;
  p:pextended;
  temp:extended;
begin
  //Primero las tablas
  fillchar(tunes[0][0],sizeof(tunes),0);
  //tune 1
  for f:=0 to 191 do begin
   case tune1_d[f] of
     A_1:tunes[1][f]:=A(1);A_2:tunes[1][f]:=A(2);A_3:tunes[1][f]:=A(3);A_4:tunes[1][f]:=A(4);A_5:tunes[1][f]:=A(5);
     Ax_1:tunes[1][f]:=Ax(1);Ax_2:tunes[1][f]:=Ax(2);Ax_3:tunes[1][f]:=Ax(3);Ax_4:tunes[1][f]:=Ax(4);Ax_5:tunes[1][f]:=Ax(5);
     B_1:tunes[1][f]:=B(1);B_2:tunes[1][f]:=B(2);B_3:tunes[1][f]:=B(3);B_4:tunes[1][f]:=B(4);B_5:tunes[1][f]:=B(5);
     C_1:tunes[1][f]:=C(1);C_2:tunes[1][f]:=C(2);C_3:tunes[1][f]:=C(3);C_4:tunes[1][f]:=C(4);C_5:tunes[1][f]:=C(5);
     Cx_1:tunes[1][f]:=Cx(1);Cx_2:tunes[1][f]:=Cx(2);Cx_3:tunes[1][f]:=Cx(3);Cx_4:tunes[1][f]:=Cx(4);Cx_5:tunes[1][f]:=Cx(5);
     D_1:tunes[1][f]:=D(1);D_2:tunes[1][f]:=D(2);D_3:tunes[1][f]:=D(3);D_4:tunes[1][f]:=D(4);D_5:tunes[1][f]:=D(5);
     Dx_1:tunes[1][f]:=Dx(1);Dx_2:tunes[1][f]:=Dx(2);Dx_3:tunes[1][f]:=Dx(3);Dx_4:tunes[1][f]:=Dx(4);Dx_5:tunes[1][f]:=Dx(5);
     E_1:tunes[1][f]:=E(1);E_2:tunes[1][f]:=E(2);E_3:tunes[1][f]:=E(3);E_4:tunes[1][f]:=E(4);E_5:tunes[1][f]:=E(5);
     F_1:tunes[1][f]:=F_n(1);F_2:tunes[1][f]:=F_n(2);F_3:tunes[1][f]:=F_n(3);F_4:tunes[1][f]:=F_n(4);F_5:tunes[1][f]:=F_n(5);
     Fx_1:tunes[1][f]:=Fx(1);Fx_2:tunes[1][f]:=Fx(2);Fx_3:tunes[1][f]:=Fx(3);Fx_4:tunes[1][f]:=Fx(4);Fx_5:tunes[1][f]:=Fx(5);
     G_1:tunes[1][f]:=G(1);G_2:tunes[1][f]:=G(2);G_3:tunes[1][f]:=G(3);G_4:tunes[1][f]:=G(4);G_5:tunes[1][f]:=G(5);
     Gx_1:tunes[1][f]:=Gx(1);Gx_2:tunes[1][f]:=Gx(2);Gx_3:tunes[1][f]:=Gx(3);Gx_4:tunes[1][f]:=Gx(4);Gx_5:tunes[1][f]:=Gx(5);
   end;
  end;
  //tune 2
  for f:=0 to 287 do begin
   case tune2_d[f] of
     A_1:tunes[2][f]:=A(1);A_2:tunes[2][f]:=A(2);A_3:tunes[2][f]:=A(3);A_4:tunes[2][f]:=A(4);A_5:tunes[2][f]:=A(5);
     Ax_1:tunes[2][f]:=Ax(1);Ax_2:tunes[2][f]:=Ax(2);Ax_3:tunes[2][f]:=Ax(3);Ax_4:tunes[2][f]:=Ax(4);Ax_5:tunes[2][f]:=Ax(5);
     B_1:tunes[2][f]:=B(1);B_2:tunes[2][f]:=B(2);B_3:tunes[2][f]:=B(3);B_4:tunes[2][f]:=B(4);B_5:tunes[2][f]:=B(5);
     C_1:tunes[2][f]:=C(1);C_2:tunes[2][f]:=C(2);C_3:tunes[2][f]:=C(3);C_4:tunes[2][f]:=C(4);C_5:tunes[2][f]:=C(5);
     Cx_1:tunes[2][f]:=Cx(1);Cx_2:tunes[2][f]:=Cx(2);Cx_3:tunes[2][f]:=Cx(3);Cx_4:tunes[2][f]:=Cx(4);Cx_5:tunes[2][f]:=Cx(5);
     D_1:tunes[2][f]:=D(1);D_2:tunes[2][f]:=D(2);D_3:tunes[2][f]:=D(3);D_4:tunes[2][f]:=D(4);D_5:tunes[2][f]:=D(5);
     Dx_1:tunes[2][f]:=Dx(1);Dx_2:tunes[2][f]:=Dx(2);Dx_3:tunes[2][f]:=Dx(3);Dx_4:tunes[2][f]:=Dx(4);Dx_5:tunes[2][f]:=Dx(5);
     E_1:tunes[2][f]:=E(1);E_2:tunes[2][f]:=E(2);E_3:tunes[2][f]:=E(3);E_4:tunes[2][f]:=E(4);E_5:tunes[2][f]:=E(5);
     F_1:tunes[2][f]:=F_n(1);F_2:tunes[2][f]:=F_n(2);F_3:tunes[2][f]:=F_n(3);F_4:tunes[2][f]:=F_n(4);F_5:tunes[2][f]:=F_n(5);
     Fx_1:tunes[2][f]:=Fx(1);Fx_2:tunes[2][f]:=Fx(2);Fx_3:tunes[2][f]:=Fx(3);Fx_4:tunes[2][f]:=Fx(4);Fx_5:tunes[2][f]:=Fx(5);
     G_1:tunes[2][f]:=G(1);G_2:tunes[2][f]:=G(2);G_3:tunes[2][f]:=G(3);G_4:tunes[2][f]:=G(4);G_5:tunes[2][f]:=G(5);
     Gx_1:tunes[2][f]:=Gx(1);Gx_2:tunes[2][f]:=Gx(2);Gx_3:tunes[2][f]:=Gx(3);Gx_4:tunes[2][f]:=Gx(4);Gx_5:tunes[2][f]:=Gx(5);
   end;
  end;
  //tune 3
  for f:=0 to 575 do begin
   case tune3_d[f] of
     A_1:tunes[3][f]:=A(1);A_2:tunes[3][f]:=A(2);A_3:tunes[3][f]:=A(3);A_4:tunes[3][f]:=A(4);A_5:tunes[3][f]:=A(5);
     Ax_1:tunes[3][f]:=Ax(1);Ax_2:tunes[3][f]:=Ax(2);Ax_3:tunes[3][f]:=Ax(3);Ax_4:tunes[3][f]:=Ax(4);Ax_5:tunes[3][f]:=Ax(5);
     B_1:tunes[3][f]:=B(1);B_2:tunes[3][f]:=B(2);B_3:tunes[3][f]:=B(3);B_4:tunes[3][f]:=B(4);B_5:tunes[3][f]:=B(5);
     C_1:tunes[3][f]:=C(1);C_2:tunes[3][f]:=C(2);C_3:tunes[3][f]:=C(3);C_4:tunes[3][f]:=C(4);C_5:tunes[3][f]:=C(5);
     Cx_1:tunes[3][f]:=Cx(1);Cx_2:tunes[3][f]:=Cx(2);Cx_3:tunes[3][f]:=Cx(3);Cx_4:tunes[3][f]:=Cx(4);Cx_5:tunes[3][f]:=Cx(5);
     D_1:tunes[3][f]:=D(1);D_2:tunes[3][f]:=D(2);D_3:tunes[3][f]:=D(3);D_4:tunes[3][f]:=D(4);D_5:tunes[3][f]:=D(5);
     Dx_1:tunes[3][f]:=Dx(1);Dx_2:tunes[3][f]:=Dx(2);Dx_3:tunes[3][f]:=Dx(3);Dx_4:tunes[3][f]:=Dx(4);Dx_5:tunes[3][f]:=Dx(5);
     E_1:tunes[3][f]:=E(1);E_2:tunes[3][f]:=E(2);E_3:tunes[3][f]:=E(3);E_4:tunes[3][f]:=E(4);E_5:tunes[3][f]:=E(5);
     F_1:tunes[3][f]:=F_n(1);F_2:tunes[3][f]:=F_n(2);F_3:tunes[3][f]:=F_n(3);F_4:tunes[3][f]:=F_n(4);F_5:tunes[3][f]:=F_n(5);
     Fx_1:tunes[3][f]:=Fx(1);Fx_2:tunes[3][f]:=Fx(2);Fx_3:tunes[3][f]:=Fx(3);Fx_4:tunes[3][f]:=Fx(4);Fx_5:tunes[3][f]:=Fx(5);
     G_1:tunes[3][f]:=G(1);G_2:tunes[3][f]:=G(2);G_3:tunes[3][f]:=G(3);G_4:tunes[3][f]:=G(4);G_5:tunes[3][f]:=G(5);
     Gx_1:tunes[3][f]:=Gx(1);Gx_2:tunes[3][f]:=Gx(2);Gx_3:tunes[3][f]:=Gx(3);Gx_4:tunes[3][f]:=Gx(4);Gx_5:tunes[3][f]:=Gx(5);
   end;
  end;
  //tune 4
  for f:=0 to 77 do begin
   case tune4_d[f] of
     A_1:tunes[4][f]:=A(1);A_2:tunes[4][f]:=A(2);A_3:tunes[4][f]:=A(3);A_4:tunes[4][f]:=A(4);A_5:tunes[4][f]:=A(5);
     Ax_1:tunes[4][f]:=Ax(1);Ax_2:tunes[4][f]:=Ax(2);Ax_3:tunes[4][f]:=Ax(3);Ax_4:tunes[4][f]:=Ax(4);Ax_5:tunes[4][f]:=Ax(5);
     B_1:tunes[4][f]:=B(1);B_2:tunes[4][f]:=B(2);B_3:tunes[4][f]:=B(3);B_4:tunes[4][f]:=B(4);B_5:tunes[4][f]:=B(5);
     C_1:tunes[4][f]:=C(1);C_2:tunes[4][f]:=C(2);C_3:tunes[4][f]:=C(3);C_4:tunes[4][f]:=C(4);C_5:tunes[4][f]:=C(5);
     Cx_1:tunes[4][f]:=Cx(1);Cx_2:tunes[4][f]:=Cx(2);Cx_3:tunes[4][f]:=Cx(3);Cx_4:tunes[4][f]:=Cx(4);Cx_5:tunes[4][f]:=Cx(5);
     D_1:tunes[4][f]:=D(1);D_2:tunes[4][f]:=D(2);D_3:tunes[4][f]:=D(3);D_4:tunes[4][f]:=D(4);D_5:tunes[4][f]:=D(5);
     Dx_1:tunes[4][f]:=Dx(1);Dx_2:tunes[4][f]:=Dx(2);Dx_3:tunes[4][f]:=Dx(3);Dx_4:tunes[4][f]:=Dx(4);Dx_5:tunes[4][f]:=Dx(5);
     E_1:tunes[4][f]:=E(1);E_2:tunes[4][f]:=E(2);E_3:tunes[4][f]:=E(3);E_4:tunes[4][f]:=E(4);E_5:tunes[4][f]:=E(5);
     F_1:tunes[4][f]:=F_n(1);F_2:tunes[4][f]:=F_n(2);F_3:tunes[4][f]:=F_n(3);F_4:tunes[4][f]:=F_n(4);F_5:tunes[4][f]:=F_n(5);
     Fx_1:tunes[4][f]:=Fx(1);Fx_2:tunes[4][f]:=Fx(2);Fx_3:tunes[4][f]:=Fx(3);Fx_4:tunes[4][f]:=Fx(4);Fx_5:tunes[4][f]:=Fx(5);
     G_1:tunes[4][f]:=G(1);G_2:tunes[4][f]:=G(2);G_3:tunes[4][f]:=G(3);G_4:tunes[4][f]:=G(4);G_5:tunes[4][f]:=G(5);
     Gx_1:tunes[4][f]:=Gx(1);Gx_2:tunes[4][f]:=Gx(2);Gx_3:tunes[4][f]:=Gx(3);Gx_4:tunes[4][f]:=Gx(4);Gx_5:tunes[4][f]:=Gx(5);
   end;
  end;
  p:=pdecay;
  if tms_chip=nil then begin
    getmem(tms_chip,sizeof(tms36xx_type));
    fillchar(tms_chip^,sizeof(tms36xx_type),0);
  end;
	tms_chip.samplerate:=freq_base_audio;
	tms_chip.basefreq:=clock;
	enable:=0;
   for j:=0 to 5 do begin
		if (p^>0) then begin
      temp:=VMAX/p^;
			tms_chip.decay[j+0]:=trunc(temp);
      tms_chip.decay[j+6]:=trunc(temp);
			enable:=enable or ($41 shl j);
		end;
    inc(p);
	end;
  temp:=VMAX/speed;
	if (speed>0) then tms_chip.speed:=trunc(temp)
    else tms_chip.speed:=VMAX;
	tms3617_enable(enable);
  tms_chip.tsample:=init_channel;
end;

procedure tms36xx_close;
begin
if tms_chip<>nil then begin
    freemem(tms_chip);
    tms_chip:=nil;
end;
end;

end.
