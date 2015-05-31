unit fmopl;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}math;

const
M_PI=3.1415926535;
FREQ_SH=16;  // 16.16 fixed point (frequency calculations) */
EG_SH=16;  // 16.16 fixed point (EG timing)              */
LFO_SH=24;  //  8.24 fixed point (LFO calculations)       */
TIMER_SH=16;  // 16.16 fixed point (timers calculations)    */

FREQ_MASK=$FFFF;//((1 shl FREQ_SH)-1);

// envelope output entries */
ENV_BITS=10;
ENV_LEN=$400;//(1 shl ENV_BITS);
ENV_STEP=(128.0/ENV_LEN);

MAX_ATT_INDEX=$3ff;//((1 shl (ENV_BITS-1))-1); //511*/
MIN_ATT_INDEX=0;

// sinwave entries */
SIN_BITS=10;
SIN_LEN=$400;//(1 shl SIN_BITS);
SIN_MASK=$3ff;//(SIN_LEN-1);

TL_RES_LEN=256;	// 8 bits addressing (real chip) */

// register number to channel number , slot offset */
SLOT1=0;
SLOT2=1;

// Envelope Generator phases */
EG_ATT=4;
EG_DEC=3;
EG_SUS=2;
EG_REL=1;
EG_OFF=0;

OPL_TYPE_WAVESEL=$01;  // waveform select     */
OPL_TYPE_ADPCM=$02;  // DELTA-T ADPCM unit  */
OPL_TYPE_KEYBOARD=$04;  // keyboard interface  */
OPL_TYPE_IO=$08;  // I/O port            */

// mapping of register number (offset) to slot number used by the emulator */
slot_array:array[0..31] of integer=(
	 0, 2, 4, 1, 3, 5,-1,-1,
	 6, 8,10, 7, 9,11,-1,-1,
	12,14,16,13,15,17,-1,-1,
	-1,-1,-1,-1,-1,-1,-1,-1
);

// key scale level */
// table is 3dB/octave , DV converts this into 6dB/octave */
// 0.1875 is bit 0 weight of the envelope counter (volume) expressed in the 'decibel' scale */
DV=(0.1875/2.0);
base_ksl_tab:array[0..(8*16)-1] of double=(
	// OCT 0 */
	 0,0,0,0,
	 0,0,0,0,
	 0,0,0,0,
	 0,0,0,0,
	// OCT 1 */
	 0,0,0,0,
	 0,0,0,0,
	 0,0.750,1.125,1.5,
	 1.875,2.25,2.625,3,
	// OCT 2 */
	 0,0,0,0,
	 0,1.125,1.875,2.625,
	 3,3.750,4.125,4.500,
	 4.875,5.250,5.625,6,
	// OCT 3 */
	 0,0,0,1.875,
	 3,4.125,4.875,5.625,
	 6,6.750,7.125,7.500,
	 7.875,8.250,8.625,9,
	// OCT 4 */
	 0,0,3,4.875,
	 6,7.125,7.875,8.625,
	 9,9.750,10.125,10.500,
	 10.875,11.250,11.625,12,
	// OCT 5 */
	 0,3,6,7.875,
	 9,10.125,10.875,11.625,
	 12,12.750,13.125,13.500,
	 13.875,14.250,14.625,15.000,
	// OCT 6 */
	 0,6,9,10.875,
	12,13.125,13.875,14.625,
	15,15.750,16.125,16.500,
	16.875,17.250,17.625,18.000,
	// OCT 7 */
	0,9,12,13.875,
	15,16.125,16.875,17.625,
	18,18.750,19.125,19.500,
	19.875,20.250,20.625,21.000);

// sustain level table (3dB per step) */
// 0 - 15: 0, 3, 6, 9,12,15,18,21,24,27,30,33,36,39,42,93 (dB)*/
sl_tab:array[0..15] of dword=(
 trunc( 0* (2.0/ENV_STEP)),trunc( 1* (2.0/ENV_STEP)),trunc( 2* (2.0/ENV_STEP)),trunc(3* (2.0/ENV_STEP) ),trunc(4* (2.0/ENV_STEP) ),trunc(5* (2.0/ENV_STEP) ),trunc(6* (2.0/ENV_STEP) ),trunc( 7* (2.0/ENV_STEP)),
 trunc( 8* (2.0/ENV_STEP)),trunc( 9* (2.0/ENV_STEP)),trunc(10* (2.0/ENV_STEP)),trunc(11* (2.0/ENV_STEP)),trunc(12* (2.0/ENV_STEP)),trunc(13* (2.0/ENV_STEP)),trunc(14* (2.0/ENV_STEP)),trunc(31* (2.0/ENV_STEP))
);

RATE_STEPS=8;
eg_inc:array[0..(15*RATE_STEPS)-1] of byte=(
//cycle:0 1  2 3  4 5  6 7*/

{ 0 } 0,1, 0,1, 0,1, 0,1, // rates 00..12 0 (increment by 0 or 1) */
{ 1 } 0,1, 0,1, 1,1, 0,1, // rates 00..12 1 */
{ 2 } 0,1, 1,1, 0,1, 1,1, // rates 00..12 2 */
{ 3 } 0,1, 1,1, 1,1, 1,1, // rates 00..12 3 */

{ 4 } 1,1, 1,1, 1,1, 1,1, // rate 13 0 (increment by 1) */
{ 5 } 1,1, 1,2, 1,1, 1,2, // rate 13 1 */
{ 6 } 1,2, 1,2, 1,2, 1,2, // rate 13 2 */
{ 7 } 1,2, 2,2, 1,2, 2,2, // rate 13 3 */

{ 8 } 2,2, 2,2, 2,2, 2,2, // rate 14 0 (increment by 2) */
{ 9 } 2,2, 2,4, 2,2, 2,4, // rate 14 1 */
{10 } 2,4, 2,4, 2,4, 2,4, // rate 14 2 */
{11 } 2,4, 4,4, 2,4, 4,4, // rate 14 3 */

{12 } 4,4, 4,4, 4,4, 4,4, // rates 15 0, 15 1, 15 2, 15 3 (increment by 4) */
{13 } 8,8, 8,8, 8,8, 8,8, // rates 15 2, 15 3 for attack */
{14 } 0,0, 0,0, 0,0, 0,0 // infinity rates for attack and decay(s) */
);

//note that there is no O(13) in this table - it's directly in the code */
eg_rate_select:array[0..(16+64+16)-1] of byte=(	// Envelope Generator rates (16 + 64 rates + 16 RKS) */
// 16 infinite time rates */
(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),
(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),(14*RATE_STEPS),

// rates 00-12 */
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),
( 0*RATE_STEPS),( 1*RATE_STEPS),( 2*RATE_STEPS),( 3*RATE_STEPS),

// rate 13 */
( 4*RATE_STEPS),( 5*RATE_STEPS),( 6*RATE_STEPS),( 7*RATE_STEPS),

// rate 14 */
( 8*RATE_STEPS),( 9*RATE_STEPS),(10*RATE_STEPS),(11*RATE_STEPS),

// rate 15 */
(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),

// 16 dummy rates (same as 15 3) */
(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),
(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS),(12*RATE_STEPS)
);

//rate  0,    1,    2,    3,   4,   5,   6,  7,  8,  9,  10, 11, 12, 13, 14, 15 */
//shift 12,   11,   10,   9,   8,   7,   6,  5,  4,  3,  2,  1,  0,  0,  0,  0  */
//mask  4095, 2047, 1023, 511, 255, 127, 63, 31, 15, 7,  3,  1,  0,  0,  0,  0  */

eg_rate_shift:array[0..(16+64+16)-1] of byte=(	// Envelope Generator counter shifts (16 + 64 rates + 16 RKS) */
// 16 infinite time rates */
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,

// rates 00-12 */
12,12,12,12,
11,11,11,11,
10,10,10,10,
 9, 9, 9, 9,
 8, 8, 8, 8,
 7, 7, 7, 7,
 6, 6, 6, 6,
 5, 5, 5, 5,
 4, 4, 4, 4,
 3, 3, 3, 3,
 2, 2, 2, 2,
 1, 1, 1, 1,
 0, 0, 0, 0,

// rate 13 */
 0, 0, 0, 0,

// rate 14 */
 0, 0, 0, 0,

// rate 15 */
 0, 0, 0, 0,

// 16 dummy rates (same as 15 3) */
0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0
);

// multiple table */
ML=2;
base_mul_tab:array[0..15] of double= (
// 1/2, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,10,12,12,15,15 */
   0.50*ML,1.00*ML,2.00*ML,3.00*ML,4.00*ML,5.00*ML,6.00*ML,7.00*ML,
   8.00*ML,9.00*ML,10.00*ML,10.00*ML,12.00*ML,12.00*ML,15.00*ML,15.00*ML
);

{  TL_TAB_LEN is calculated as:
*   12 - sinus amplitude bits     (Y axis)
*   2  - sinus sign bit           (Y axis)
*   TL_RES_LEN - sinus resolution (X axis)}

TL_TAB_LEN=(12*2*TL_RES_LEN);
ENV_QUIET=$180;//(TL_TAB_LEN shr 4);

{ LFO Amplitude Modulation table (verified on real YM3812)
   27 output levels (triangle waveform); 1 level takes one of: 192, 256 or 448 samples

   Length: 210 elements.

    Each of the elements has to be repeated
    exactly 64 times (on 64 consecutive samples).
    The whole table takes: 64 * 210 = 13440 samples.

    When AM = 1 data is used directly
    When AM = 0 data is divided by 4 before being used (loosing precision is important)
}

LFO_AM_TAB_ELEMENTS=210;

lfo_am_table:array[0..(LFO_AM_TAB_ELEMENTS)-1] of byte= (
0,0,0,0,0,0,0,
1,1,1,1,
2,2,2,2,
3,3,3,3,
4,4,4,4,
5,5,5,5,
6,6,6,6,
7,7,7,7,
8,8,8,8,
9,9,9,9,
10,10,10,10,
11,11,11,11,
12,12,12,12,
13,13,13,13,
14,14,14,14,
15,15,15,15,
16,16,16,16,
17,17,17,17,
18,18,18,18,
19,19,19,19,
20,20,20,20,
21,21,21,21,
22,22,22,22,
23,23,23,23,
24,24,24,24,
25,25,25,25,
26,26,26,
25,25,25,25,
24,24,24,24,
23,23,23,23,
22,22,22,22,
21,21,21,21,
20,20,20,20,
19,19,19,19,
18,18,18,18,
17,17,17,17,
16,16,16,16,
15,15,15,15,
14,14,14,14,
13,13,13,13,
12,12,12,12,
11,11,11,11,
10,10,10,10,
9,9,9,9,
8,8,8,8,
7,7,7,7,
6,6,6,6,
5,5,5,5,
4,4,4,4,
3,3,3,3,
2,2,2,2,
1,1,1,1);

// LFO Phase Modulation table (verified on real YM3812) */
lfo_pm_table:array[0..(8*8*2)-1] of integer= (

// FNUM2/FNUM = 00 0xxxxxxx (0x0000) */
0, 0, 0, 0, 0, 0, 0, 0,	//LFO PM depth = 0*/
0, 0, 0, 0, 0, 0, 0, 0,	//LFO PM depth = 1*/

// FNUM2/FNUM = 00 1xxxxxxx (0x0080) */
0, 0, 0, 0, 0, 0, 0, 0,	//LFO PM depth = 0*/
1, 0, 0, 0,-1, 0, 0, 0,	//LFO PM depth = 1*/

// FNUM2/FNUM = 01 0xxxxxxx (0x0100) */
1, 0, 0, 0,-1, 0, 0, 0,	//LFO PM depth = 0*/
2, 1, 0,-1,-2,-1, 0, 1,	//LFO PM depth = 1*/

// FNUM2/FNUM = 01 1xxxxxxx (0x0180) */
1, 0, 0, 0,-1, 0, 0, 0,	//LFO PM depth = 0*/
3, 1, 0,-1,-3,-1, 0, 1,	//LFO PM depth = 1*/

// FNUM2/FNUM = 10 0xxxxxxx (0x0200) */
2, 1, 0,-1,-2,-1, 0, 1,	//LFO PM depth = 0*/
4, 2, 0,-2,-4,-2, 0, 2,	//LFO PM depth = 1*/

// FNUM2/FNUM = 10 1xxxxxxx (0x0280) */
2, 1, 0,-1,-2,-1, 0, 1,	//LFO PM depth = 0*/
5, 2, 0,-2,-5,-2, 0, 2,	//LFO PM depth = 1*/

// FNUM2/FNUM = 11 0xxxxxxx (0x0300) */
3, 1, 0,-1,-3,-1, 0, 1,	//LFO PM depth = 0*/
6, 3, 0,-3,-6,-3, 0, 3,	//LFO PM depth = 1*/

// FNUM2/FNUM = 11 1xxxxxxx (0x0380) */
3, 1, 0,-1,-3,-1, 0, 1,	//LFO PM depth = 0*/
7, 3, 0,-3,-7,-3, 0, 3	//LFO PM depth = 1*/
);

type
  OPL_SLOT=record
	  ar:dword;			// attack rate: AR<<2           */
	  dr:dword;			// decay rate:  DR<<2           */
	  rr:dword;			// release rate:RR<<2           */
	  KSR_m:byte;		// key scale rate               */
	  ksl:byte;		// keyscale level               */
	  ksr:byte;		// key scale rate: kcode>>KSR   */
	  mul:byte;		// multiple: mul_tab[ML]        */
	  // Phase Generator */
	  Cnt:dword;		// frequency counter            */
	  Incr:dword;		// frequency counter step       */
	  FB:byte;			// feedback shift value         */
	  connect1:pinteger;	// slot1 output pointer         */
	  op1_out:array[0..1] of integer;	// slot1 output for feedback    */
	  CON:byte;		// connection (algorithm) type  */
	  // Envelope Generator */
	  eg_type:byte;	// percussive/non-percussive mode */
	  state:byte;		// phase type                   */
	  TL:dword;			// total level: TL << 2         */
	  TLL:integer;		// adjusted now TL              */
	  volume:integer;		// envelope counter             */
	  sl:dword;			// sustain level: sl_tab[SL]    */
	  eg_sh_ar:byte;	// (attack state)               */
	  eg_sel_ar:byte;	// (attack state)               */
	  eg_sh_dr:byte;	// (decay state)                */
	  eg_sel_dr:byte;	// (decay state)                */
	  eg_sh_rr:byte;	// (release state)              */
	  eg_sel_rr:byte;	// (release state)              */
	  key:dword;		// 0 = KEY OFF, >0 = KEY ON     */
	  // LFO */
	  AMmask:dword;		// LFO Amplitude Modulation enable mask */
	  vib:byte;		// LFO Phase Modulation enable flag (active high)*/
	  // waveform select */
	  wavetable:word;
  end;
  popl_slot=^OPL_SLOT;

  OPL_CH=record
	  SLOT:array[0..1] of pOPL_SLOT;
	  // phase generator state */
	  block_fnum:dword;	// block+fnum                   */
	  fc:dword;			// Freq. Increment base         */
	  ksl_base:dword;	// KeyScaleLevel Base step      */
	  kcode:byte;		// key code (for key scaling)   */
  end;
  pOPL_CH=^OPL_CH;

  // OPL state */
  FM_OPL=record
	  // FM channel slots */
	  P_CH:array[0..8] of pOPL_CH;				// OPL/OPL2 chips have 9 channels*/
	  eg_cnt:dword;					// global envelope generator counter    */
	  eg_timer:dword;				// global envelope generator counter works at frequency = chipclock/72 */
	  eg_timer_add:single;			// step of eg_timer                     */
	  eg_timer_overflow:dword;		// envelope generator timer overlfows every 1 sample (on real chip) */

	  rhythm:byte;					// Rhythm mode                  */

	  fn_tab:array[0..1024-1] of dword;			// fnumber->increment counter   */

	  // LFO */
	  lfo_am_depth:byte;
	  lfo_pm_depth_range:byte;
	  lfo_am_cnt:dword;
	  lfo_am_inc:single;
	  lfo_pm_cnt:dword;
	  lfo_pm_inc:single;

	  noise_rng:dword;				// 23 bit noise shift register  */
	  noise_p:dword;				// current noise 'phase'        */
	  noise_f:single;				// current noise period         */

	  wavesel:byte;				// waveform select enable flag  */

	  T:array[0..1] of dword;					// timer counters               */
    TC:array[0..1] of single;
	  st:array[0..1] of byte;					// timer enable                 */

	  // external event callback handlers */
    IRQ_Handler:procedure (irqstate:byte);
    {--!!!!
	  OPL_TIMERHANDLER  timer_handler;	/* TIMER handler                */
	  void *TimerParam;					/* TIMER parameter              */
	  OPL_UPDATEHANDLER UpdateHandler;/* stream update handler        */
	  void *UpdateParam;				/* stream update parameter      */
    !!--}

	  type_:byte;						// chip type                    */
	  address:byte;					// address register             */
	  status:byte;					// status flag                  */
	  statusmask:byte;				// status mask                  */
	  mode:byte;						// Reg.08 : CSM,notesel,etc.    */

	  clock:dword;					// master clock  (Hz)           */
	  rate:dword;					// sampling rate (Hz)           */
	  freqbase:single;				// frequency base               */
	  TimerBase:single;			// Timer base time (==sampling time)*/
    LFO_AM:dword;
    LFO_PM:integer;
    output:integer;
  end;
  pFM_OPL=^FM_OPL;

var
  SLOT7_1,SLOT7_2,SLOT8_1,SLOT8_2:pOPL_SLOT;
  phase_modulation:integer;	// phase modulation input (SLOT 2) */
  tl_tab:array[0..(TL_TAB_LEN-1)] of integer;
  ksl_tab:array[0..(8*16)-1] of single;
  mul_tab:array[0..15] of integer;
// sin waveform table in 'decibel' scale */
// four waveforms on OPL2 type chips */
  sin_tab:array[0..(SIN_LEN * 4)-1] of cardinal;

procedure OPLClose(OPL:pfm_opl);
function OPLCreate(sound_clock:single;clock,rate:dword):pfm_OPL;
procedure OPLWriteReg(num:byte;OPL:pFM_OPL;r,v:integer);
procedure OPLResetChip(num:byte;OPL:pfm_opl);
procedure advance_lfo(OPL:pFM_OPL);
procedure advance(OPL:pFM_OPL);
procedure OPL_CALC_CH(OPL:pFM_OPL;CH:pOPL_CH);
procedure OPL_CALC_RH(OPL:pFM_OPL;noise:cardinal);
procedure OPLTimerOver(num:byte;OPL:pFM_OPL;c:byte);

implementation
uses ym_3812;

function sshr(num:integer;fac:byte):integer;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

// generic table initialize */
procedure init_tables;
var
	i,x:integer;
	n:integer;
	o,m:single;
begin
  for i:=0 to ((8*16)-1) do ksl_tab[i]:=base_ksl_tab[i]/DV;
  for i:=0 to 15 do mul_tab[i]:=trunc(base_mul_tab[i]);
	for x:=0 to TL_RES_LEN-1 do begin
		m:= (1 shl 16) / power(2, (x+1) * (ENV_STEP/4.0) / 8.0);
		m:=floor(m);

		// we never reach (1<<16) here due to the (x+1) */
		// result fits within 16 bits at maximum */
		n:=word(trunc(m));		// 16 bits here */
		n:=n shr 4;		// 12 bits here */
		if (n and 1)<>0 then		// round to nearest */
			n:= (n shr 1)+1
		else
			n:= n shr 1;
						// 11 bits here (rounded) */
		n:=n shl 1;		// 12 bits here (as in real chip) */
		tl_tab[x*2 + 0]:= n;
		tl_tab[ x*2 + 1 ]:= -tl_tab[ x*2 + 0 ];

		for i:=1 to 11 do begin
			tl_tab[ x*2+0 + i*2*TL_RES_LEN ]:=tl_tab[ x*2+0 ] shr i;
			tl_tab[ x*2+1 + i*2*TL_RES_LEN ]:= -tl_tab[ x*2+0 + i*2*TL_RES_LEN ];
		end;
  end;

	for i:=0 to SIN_LEN-1 do begin
		// non-standard sinus */
		m:= sin( ((i*2)+1) * M_PI / SIN_LEN ); // checked against the real chip */

		// we never reach zero here due to ((i*2)+1) */

		if (m>0.0) then
			o:= 8*log10(1.0/m)/log10(2)	// convert to 'decibels' */
		else
			o:= 8*log10(-1.0/m)/log10(2);	// convert to 'decibels' */

		o:= o / (ENV_STEP/4);

		n:=trunc(2.0*o);
		if (n and 1)<>0 then				// round to nearest */
			n:= (n shr 1)+1
		else
			n:= n shr 1;
    if m>=0.0 then sin_tab[ i ]:=n*2+0
      else sin_tab[ i ]:=n*2+1;
	end;

	for i:=0 to SIN_LEN-1 do begin
		{ waveform 1:  __      __     */
		/*             /  \____/  \____*/
		/* output only first half of the sinus waveform (positive one) */}

		if (i and (1 shl (SIN_BITS-1)) )<>0 then
			sin_tab[1*SIN_LEN+i]:= TL_TAB_LEN
		else
			sin_tab[1*SIN_LEN+i]:= sin_tab[i];

		{ waveform 2:  __  __  __  __ */
		/*             /  \/  \/  \/  \*/
		/* abs(sin) }

		sin_tab[2*SIN_LEN+i]:= sin_tab[i and (SIN_MASK shr 1) ];

		{ waveform 3:  _   _   _   _  */
		/*             / |_/ |_/ |_/ |_*/
		/* abs(output only first quarter of the sinus waveform) }

		if (i and (1 shl (SIN_BITS-2)) )<>0 then
			sin_tab[3*SIN_LEN+i]:= TL_TAB_LEN
		else
			sin_tab[3*SIN_LEN+i]:= sin_tab[i and (SIN_MASK shr 2)];
	end;
end;

procedure OPL_initalize(sound_cpu_clock:single;OPL:pfm_opl);
var
	i:integer;
begin
	// frequency base */
  if opl.rate<>0 then OPL.freqbase:=(OPL.clock / 72.0) / OPL.rate
    else OPL.freqbase:=0;

	// Timer base time */
	OPL.TimerBase:=(sound_cpu_clock/OPL.clock)*72;

	// make fnumber -> increment counter table */
	for i:=0 to 1023 do
		// opn phase increment counter = 20bit */
		OPL.fn_tab[i]:=trunc(i * 64 * OPL.freqbase * (1 shl (FREQ_SH-10)) ); // -10 because chip works with 10.10 fixed point, while we use 16.16 */


	// Amplitude modulation: 27 output levels (triangle waveform); 1 level takes one of: 192, 256 or 448 samples */
	// One entry from LFO_AM_TABLE lasts for 64 samples */
	OPL.lfo_am_inc:=(1.0 / 64.0 ) * (1 shl LFO_SH) * OPL.freqbase;

	// Vibrato: 8 output levels (triangle waveform); 1 level takes 1024 samples */
	OPL.lfo_pm_inc:=(1.0 / 1024.0)*(1 shl LFO_SH)*OPL.freqbase;
	// Noise generator: a step takes 1 sample */
	OPL.noise_f:=(1.0 / 1.0) * (1 shl FREQ_SH) * OPL.freqbase;

	OPL.eg_timer_add:=(1 shl EG_SH)  * OPL.freqbase;
	OPL.eg_timer_overflow:= ( 1 ) * (1 shl EG_SH);
end;

procedure OPLClose(OPL:pfm_opl);
var
  f:byte;
begin
for f:=0 to 8 do begin
    freemem(OPL.P_CH[f].SLOT[0]);
    OPL.P_CH[f].SLOT[0]:=nil;
    freemem(OPL.P_CH[f].SLOT[1]);
    OPL.P_CH[f].SLOT[1]:=nil;
    freemem(OPL.P_CH[f]);
    OPL.P_CH[f]:=nil;
  end;
  freemem(OPL);
end;


function OPLCreate(sound_clock:single;clock,rate:dword):pfm_OPL;
var
  OPL:pfm_opl;
  f:byte;
begin
	init_tables;
	// calculate OPL state size */
  //if OPL=nil then begin
    getmem(OPL,sizeof(fm_opl));
    fillchar(OPL^,sizeof(fm_opl),0);
  //end;
	OPL.clock:= clock;
	OPL.rate:= rate;
  for f:=0 to 8 do begin
    getmem(OPL.P_CH[f],sizeof(OPL_CH));
    fillchar(OPL.P_CH[f]^,sizeof(OPL_CH),0);
    getmem(OPL.P_CH[f].SLOT[0],sizeof(OPL_SLOT));
    fillchar(OPL.P_CH[f].SLOT[0]^,sizeof(OPL_SLOT),0);
    getmem(OPL.P_CH[f].SLOT[1],sizeof(OPL_SLOT));
    fillchar(OPL.P_CH[f].SLOT[1]^,sizeof(OPL_SLOT),0);
  end;
	// init global tables */
	OPL_initalize(sound_clock,OPL);
	OPLCreate:=OPL;
end;

// status set and IRQ handling */
procedure OPL_STATUS_SET(OPL:pFM_OPL;flag:integer);
begin
	// set status flag */
	OPL.status:=OPL.status or flag;
	if (OPL.status and $80)=0 then begin
		if (OPL.status and OPL.statusmask)<>0 then begin
			// IRQ on */
			OPL.status:=OPL.status or $80;
			// callback user interrupt handler (IRQ is OFF to ON) */
			 if (@OPL.IRQ_Handler<>nil) then OPL.IRQ_Handler(1);
		end;
	end;
end;

procedure OPL_STATUS_RESET(OPL:pFM_OPL;flag:integer);
begin
	// reset status flag */
	OPL.status:=OPL.status and not(flag);
	if ((OPL.status and $80)<>0) then begin
		if (OPL.status and OPL.statusmask)=0 then begin
			OPL.status:=OPL.status and $7f;
			// callback user interrupt handler (IRQ is ON to OFF) */
			if (@OPL.IRQ_Handler<>nil) then OPL.IRQ_Handler(0);
	 	end;
	end;
end;

procedure OPL_STATUSMASK_SET(OPL:pFM_OPL;flag:integer);
begin
	OPL.statusmask:= flag;
	// IRQ handling check */
	OPL_STATUS_SET(OPL,0);
	OPL_STATUS_RESET(OPL,0);
end;

procedure OPLResetChip(num:byte;OPL:pfm_opl);
var
	c,s:integer;
	i:integer;
  CH:pOPL_CH;
begin
	OPL.eg_timer:= 0;
	OPL.eg_cnt:= 0;

	OPL.noise_rng:= 1;	// noise shift register */
	OPL.mode:=0;	// normal mode */
	OPL_STATUS_RESET(OPL,$7f);

	// reset with register write */
	OPLWriteReg(num,OPL,$01,0); // wavesel disable */
	OPLWriteReg(num,OPL,$02,0); // Timer1 */
	OPLWriteReg(num,OPL,$03,0); // Timer2 */
	OPLWriteReg(num,OPL,$04,0); // IRQ mask clear */
	for i:=$ff downto $20 do OPLWriteReg(num,OPL,i,0);

	// reset operator parameters */
	for c:=0 to 8 do begin
		CH:=OPL.P_CH[c];
		for s:=0 to 1 do begin
			// wave table */
			CH.SLOT[s].wavetable:= 0;
			CH.SLOT[s].state:= EG_OFF;
			CH.SLOT[s].volume:= MAX_ATT_INDEX;
		end;
	end;
end;

// update phase increment counter of operator (also update the EG rates if necessary) */
procedure CALC_FCSLOT(CH:pOPL_CH;SLOT:pOPL_SLOT);
var
	ksr:integer;
begin
	// (frequency) phase increment counter */
	SLOT.Incr:= CH.fc * SLOT.mul;
	ksr:= CH.kcode shr SLOT.KSR_m;

	if ( SLOT.ksr<>ksr ) then begin
		SLOT.ksr:= ksr;

		// calculate envelope generator rates */
		if ((SLOT.ar + SLOT.ksr) < 16+62) then begin
			SLOT.eg_sh_ar:= eg_rate_shift [SLOT.ar + SLOT.ksr ];
			SLOT.eg_sel_ar:= eg_rate_select[SLOT.ar + SLOT.ksr ];
		end else begin
			SLOT.eg_sh_ar:= 0;
			SLOT.eg_sel_ar:= 13*RATE_STEPS;
		end;
		SLOT.eg_sh_dr:= eg_rate_shift [SLOT.dr + SLOT.ksr ];
		SLOT.eg_sel_dr:= eg_rate_select[SLOT.dr + SLOT.ksr ];
		SLOT.eg_sh_rr:= eg_rate_shift [SLOT.rr + SLOT.ksr ];
		SLOT.eg_sel_rr:= eg_rate_select[SLOT.rr + SLOT.ksr ];
	end;
end;

// set multi,am,vib,EG-TYP,KSR,mul */
procedure set_mul(OPL:pFM_OPL;slot_v,v:integer);
var
  CH:pOPL_CH;
  SLOT:pOPL_SLOT;
begin
	CH:=OPL.P_CH[slot_v shr 1];
	SLOT:=CH.SLOT[slot_v and 1];
	SLOT.mul:=byte(mul_tab[v and $0f]);
  if (v and $10)<>0 then SLOT.KSR_m:=0
    else SLOT.KSR_m:=2;
	SLOT.eg_type:=(v and $20);
	SLOT.vib:=(v and $40);
	if (v and $80)<>0 then SLOT.AMmask:=cardinal(not(0))
    else SLOT.AMmask:=0;
	CALC_FCSLOT(CH,SLOT);
end;

// set ksl & tl */
procedure set_ksl_tl(OPL:pFM_OPL;slot_v,v:integer);
var
  CH:pOPL_CH;
  SLOT:pOPL_SLOT;
  ksl:integer;
begin
	CH:=OPL.P_CH[slot_v shr 1];
	SLOT:=CH.SLOT[slot_v and 1];
	ksl:=v shr 6; // 0 / 1.5 / 3.0 / 6.0 dB/OCT */
  if ksl<>0 then SLOT.ksl:=3-ksl
    else SLOT.ksl:=31;
	SLOT.TL:= (v and $3f) shl (ENV_BITS-1-7); // 7 bits TL (bit 6 = always 0) */

	SLOT.TLL:= SLOT.TL + (CH.ksl_base shr SLOT.ksl);
end;

// set attack rate & decay rate  */
procedure set_ar_dr(OPL:pFM_OPL;slot_v,v:integer);
var
  CH:pOPL_CH;
  SLOT:pOPL_SLOT;
begin
	CH:=OPL.P_CH[slot_v shr 1];
	SLOT:=CH.SLOT[slot_v and 1];
  if (v shr 4)<>0 then SLOT.ar:=16 + ((v shr 4)  shl 2)
    else SLOT.ar:=0;

	if ((SLOT.ar + SLOT.ksr) < 16+62) then begin
		SLOT.eg_sh_ar:= eg_rate_shift [SLOT.ar + SLOT.ksr ];
		SLOT.eg_sel_ar:= eg_rate_select[SLOT.ar + SLOT.ksr ];
	end else begin
		SLOT.eg_sh_ar:= 0;
		SLOT.eg_sel_ar:= 13*RATE_STEPS;
	end;

  if (v and $0f)<>0 then SLOT.dr:=16 + ((v and $0f) shl 2)
    else SLOT.dr:=0;
	SLOT.eg_sh_dr:= eg_rate_shift [SLOT.dr + SLOT.ksr ];
	SLOT.eg_sel_dr:= eg_rate_select[SLOT.dr + SLOT.ksr ];
end;

// set sustain level & release rate */
procedure set_sl_rr(OPL:pFM_OPL;slot_v,v:integer);
var
  CH:pOPL_CH;
  SLOT:pOPL_SLOT;
begin
	CH:=OPL.P_CH[slot_v shr 1];
	SLOT:=CH.SLOT[slot_v and 1];

	SLOT.sl:= sl_tab[ v shr 4 ];

  if (v and $0f)<>0 then SLOT.rr:=16 + ((v and $0f) shl 2)
    else SLOT.rr:=0;
	SLOT.eg_sh_rr:= eg_rate_shift [SLOT.rr + SLOT.ksr ];
	SLOT.eg_sel_rr:= eg_rate_select[SLOT.rr + SLOT.ksr ];
end;

procedure FM_KEYON(SLOT:pOPL_SLOT;key_set:dword);
begin
	if (SLOT.key=0) then begin
		// restart Phase Generator */
		SLOT.Cnt:=0;
		// phase -> Attack */
		SLOT.state:= EG_ATT;
	end;
	SLOT.key:=SLOT.key or key_set;
end;

procedure FM_KEYOFF(SLOT:pOPL_SLOT;key_clr:dword);
begin
	if (SLOT.key<>0) then begin
		SLOT.key:=SLOT.key and key_clr;

		if (SLOT.key=0) then begin
			// phase -> Release */
			if (SLOT.state>EG_REL) then SLOT.state:= EG_REL;
		end;
	end;
end;

// CSM Key Controll */
procedure CSMKeyControll(CH:pOPL_CH);
begin
	FM_KEYON (CH.SLOT[SLOT1], 4);
	FM_KEYON (CH.SLOT[SLOT2], 4);

	// The key off should happen exactly one sample later - not implemented correctly yet */

	FM_KEYOFF(CH.SLOT[SLOT1],cardinal(not(4)));
	FM_KEYOFF(CH.SLOT[SLOT2],cardinal(not(4)));
end;

procedure OPLTimerOver(num:byte;OPL:pFM_OPL;c:byte);
var
  ch:byte;
begin
  if (c<>0) then begin   // Timer B */
    OPL_STATUS_SET(OPL,$20);
  end else begin // Timer A */
    OPL_STATUS_SET(OPL,$40);
    // CSM mode key,TL controll */
    if (OPL.mode and $80)<>0 then begin
        // CSM mode total level latch and auto key on */
        //if(OPL->UpdateHandler) OPL->UpdateHandler(OPL->UpdateParam,0);
        for ch:=0 to 8 do CSMKeyControll(OPL.P_CH[ch]);
    end;
  end;
  // reload timer */
  ym3812_timer_handler(num,c,OPL.TimerBase*OPL.T[c]);
end;

// write a value v to register r on OPL chip */
procedure OPLWriteReg(num:byte;OPL:pFM_OPL;r,v:integer);
var
	CH:pOPL_CH;
	slot:integer;
	block_fnum:integer;
  block,st1,st2:byte;
  period:single;
begin
 // adjust bus to 8 bits */
 r:=r and $ff;
 v:=v and $ff;

 case (r and $e0) of
	 $00:case (r and $1f) of // 00-1f:control */
		    $01:if (OPL.type_ and OPL_TYPE_WAVESEL)<>0 then begin // waveform select enable */
				      OPL.wavesel:=v and $20;
				      // do not change the waveform previously selected */
            end;
		    $02:OPL.T[0]:=(256-v)*4;	// Timer 1 */
		    $03:OPL.T[1]:=(256-v)*16;	// Timer 2 */
		    $04:if (v and $80)<>0 then begin	// IRQ clear / mask and Timer enable */
			        // IRQ flag clear */
				      OPL_STATUS_RESET(OPL,$7f-$08); // don't reset BFRDY flag or we will have to call deltat module to set the flag */
            end	else begin
              st1:=v and 1;
              st2:=(v shr 1) and 1;
              // IRQRST,T1MSK,t2MSK,EOSMSK,BRMSK,x,ST2,ST1 */
				      OPL_STATUS_RESET(OPL, v and ($78-$08) );
				      OPL_STATUSMASK_SET(OPL,not(v) and $78 );
              // timer 2
              if (OPL.st[1]<>st2) then begin
                  if st2<>0 then period:=(OPL.TimerBase*OPL.T[1])
                    else period:=0;
                  OPL.st[1]:=st2;
                  ym3812_timer_handler(num,1,period);
              end;
              // timer 1
              if (OPL.st[0]<>st1) then begin
                  if st1<>0 then period:=(OPL.TimerBase*OPL.T[0])
                    else period:=0;
                  OPL.st[0]:=st1;
                  ym3812_timer_handler(num,0,period);
              end;
            end;
		    $08:OPL.mode:= v;	// MODE,DELTA-T control 2 : CSM,NOTESEL,x,x,smpl,da/ad,64k,rom */
      end;

	 $20:begin	// am ON, vib ON, ksr, eg_type, mul */
		    slot:=slot_array[r and $1f];
		    if (slot<0) then exit;
		    set_mul(OPL,slot,v);
       end;
	 $40:begin
		    slot:=slot_array[r and $1f];
		    if(slot<0) then exit;
		    set_ksl_tl(OPL,slot,v);
       end;
	 $60:begin
		    slot:=slot_array[r and $1f];
		    if (slot<0) then exit;
		    set_ar_dr(OPL,slot,v);
		   end;
	 $80:begin
		    slot:= slot_array[r and $1f];
		    if (slot<0) then exit;
		    set_sl_rr(OPL,slot,v);
       end;
   $a0:begin
		      if (r=$bd) then begin		// am depth, vibrato depth, r,bd,sd,tom,tc,hh */
			      OPL.lfo_am_depth:= v and $80;
            if (v and $40)<>0 then OPL.lfo_pm_depth_range:=8
             else OPL.lfo_pm_depth_range:=0;
			      OPL.rhythm:=v and $3f;
			      if (OPL.rhythm and $20)<>0 then begin
				      // BD key on/off */
				      if (v and $10)<>0 then begin
					      FM_KEYON(OPL.P_CH[6].SLOT[SLOT1], 2);
					      FM_KEYON(OPL.P_CH[6].SLOT[SLOT2], 2);
              end else begin
					      FM_KEYOFF(OPL.P_CH[6].SLOT[SLOT1],cardinal(not(2)));
					      FM_KEYOFF(OPL.P_CH[6].SLOT[SLOT2],cardinal(not(2)));
              end;
				      // HH key on/off */
				      if (v and $01)<>0 then FM_KEYON(OPL.P_CH[7].SLOT[SLOT1],2)
				        else FM_KEYOFF(OPL.P_CH[7].SLOT[SLOT1],cardinal(not(2)));
				      // SD key on/off */
				      if (v and $08)<>0 then FM_KEYON(OPL.P_CH[7].SLOT[SLOT2],2)
				        else FM_KEYOFF(OPL.P_CH[7].SLOT[SLOT2],cardinal(not(2)));
				      // TOM key on/off */
				      if (v and $04)<>0 then FM_KEYON(OPL.P_CH[8].SLOT[SLOT1], 2)
				        else FM_KEYOFF(OPL.P_CH[8].SLOT[SLOT1],cardinal(not(2)));
				      // TOP-CY key on/off */
				      if (v and $02)<>0 then FM_KEYON (OPL.P_CH[8].SLOT[SLOT2],2)
				        else FM_KEYOFF(OPL.P_CH[8].SLOT[SLOT2],cardinal(not(2)));
            end	else begin
				      // BD key off */
				      FM_KEYOFF(OPL.P_CH[6].SLOT[SLOT1],cardinal(not(2)));
				      FM_KEYOFF(OPL.P_CH[6].SLOT[SLOT2],cardinal(not(2)));
				      // HH key off */
				      FM_KEYOFF(OPL.P_CH[7].SLOT[SLOT1],cardinal(not(2)));
				      // SD key off */
				      FM_KEYOFF(OPL.P_CH[7].SLOT[SLOT2],cardinal(not(2)));
				      // TOM key off */
				      FM_KEYOFF(OPL.P_CH[8].SLOT[SLOT1],cardinal(not(2)));
				      // TOP-CY off */
				      FM_KEYOFF(OPL.P_CH[8].SLOT[SLOT2],cardinal(not(2)));
            end;
            exit;
          end;
		      // keyon,block,fnum */
		      if ((r and $0f)>8) then exit;
		      CH:=OPL.P_CH[r and $0f];
		      if (r and $10)=0 then begin
		        // a0-a8 */
			      block_fnum:= (CH.block_fnum and $1f00) or v;
          end else begin
		        // b0-b8 */
			      block_fnum:= ((v and $1f) shl 8) or (CH.block_fnum and $ff);

			      if (v and $20)<>0 then begin
				      FM_KEYON (CH.SLOT[SLOT1], 1);
				      FM_KEYON (CH.SLOT[SLOT2], 1);
            end	else begin
				      FM_KEYOFF(CH.SLOT[SLOT1],cardinal(not(1)));
				      FM_KEYOFF(CH.SLOT[SLOT2],cardinal(not(1)));
            end;
          end;
		      // update */
		      if (CH.block_fnum<>block_fnum) then begin
			      block:=block_fnum shr 10;

			      CH.block_fnum:=block_fnum;

			      CH.ksl_base:=word(trunc(ksl_tab[block_fnum shr 6]));
			      CH.fc:= OPL.fn_tab[block_fnum and $03ff] shr (7-block);

			      // BLK 2,1,0 bits -> bits 3,2,1 of kcode */
			      CH.kcode:= (CH.block_fnum and $1c00) shr 9;

			      // the info below is actually opposite to what is stated in the Manuals (verifed on real YM3812) */
            // if notesel == 0 -> lsb of kcode is bit 10 (MSB) of fnum  */
			      // if notesel == 1 -> lsb of kcode is bit 9 (MSB-1) of fnum */
			      if (OPL.mode and $40)<>0 then
				      CH.kcode:=CH.kcode or ((CH.block_fnum and $100) shr 8)	// notesel == 1 */
			      else
				      CH.kcode:=CH.kcode or ((CH.block_fnum and $200) shr 9);	// notesel == 0 */

			      // refresh Total Level in both SLOTs of this channel */
			      CH.SLOT[SLOT1].TLL:= CH.SLOT[SLOT1].TL + (CH.ksl_base shr CH.SLOT[SLOT1].ksl);
			      CH.SLOT[SLOT2].TLL:= CH.SLOT[SLOT2].TL + (CH.ksl_base shr CH.SLOT[SLOT2].ksl);

			      // refresh frequency counter in both SLOTs of this channel */
			      CALC_FCSLOT(CH,CH.SLOT[SLOT1]);
			      CALC_FCSLOT(CH,CH.SLOT[SLOT2]);
          end;
        end;
	 $c0:begin
		    // FB,C */
		    if( (r and $0f) > 8) then exit;
        CH:=OPL.P_CH[r and $0f];
        if ((v shr 1)and 7)<>0 then CH.SLOT[SLOT1].FB:=((v shr 1) and 7) + 7
          else CH.SLOT[SLOT1].FB:=0;
		    CH.SLOT[SLOT1].CON:= v and 1;
        if CH.SLOT[SLOT1].CON<>0 then CH.SLOT[SLOT1].connect1:=@output
          else CH.SLOT[SLOT1].connect1:=@phase_modulation;
        end;
   $e0:begin // waveform select */
		    // simply ignore write to the waveform select register if selecting not enabled in test register */
		    if (OPL.wavesel)<>0 then begin
			    slot:= slot_array[r and $1f];
			    if(slot<0) then exit;
			    CH:=OPL.P_CH[slot shr 1];
			    CH.SLOT[slot and 1].wavetable:=(v and $03)*SIN_LEN;
        end;
        end;
	end;
end;

// advance LFO to next sample */
procedure advance_lfo(OPL:pFM_OPL);
var
  temp:byte;
begin
	// LFO */
	OPL.lfo_am_cnt:=trunc(OPL.lfo_am_cnt+OPL.lfo_am_inc);
	if OPL.lfo_am_cnt>=cardinal(LFO_AM_TAB_ELEMENTS shl LFO_SH) then //lfo_am_table is 210 elements long */
		OPL.lfo_am_cnt:=OPL.lfo_am_cnt-(LFO_AM_TAB_ELEMENTS shl LFO_SH);
  temp:=lfo_am_table[OPL.lfo_am_cnt shr LFO_SH];
	if (OPL.lfo_am_depth<>0) then	OPL.LFO_AM:=temp
	  else OPL.LFO_AM:=temp shr 2;
	OPL.lfo_pm_cnt:=trunc(OPL.lfo_pm_cnt+OPL.lfo_pm_inc);
	OPL.LFO_PM:=((OPL.lfo_pm_cnt shr LFO_SH) and 7) or OPL.lfo_pm_depth_range;
end;

// advance to next sample */
procedure advance(OPL:pFM_OPL);
var
	CH:pOPL_CH;
  op:pOPL_SLOT;
	i:integer;
  block:byte;
  block_fnum:cardinal;
  fnum_lfo:cardinal;
  lfo_fn_table_index_offset:integer;
begin
	OPL.eg_timer:=trunc(OPL.eg_timer+OPL.eg_timer_add);

	while (OPL.eg_timer >= OPL.eg_timer_overflow) do begin
		OPL.eg_timer:=OPL.eg_timer-OPL.eg_timer_overflow;

		OPL.eg_cnt:=OPL.eg_cnt+1;

		for i:=0 to (9*2)-1 do begin
			CH:=OPL.P_CH[i shr 1];
			op:=CH.SLOT[i and 1];

			// Envelope Generator */
			case (op.state) of
			  EG_ATT:begin		// attack phase */
				        if ((OPL.eg_cnt and ((1 shl op.eg_sh_ar)-1))=0) then begin
					        op.volume:=op.volume+sshr((not(op.volume)*
	                        		           (eg_inc[op.eg_sel_ar + ((OPL.eg_cnt shr op.eg_sh_ar) and 7)])
        			                          ),3);
                                        //JODER!!! Otra vez la misma historia. En delphi
                                        //los enteros con signo cuando haces shr PIERDEN EL SIGNO
					        if (op.volume <= MIN_ATT_INDEX) then begin
						        op.volume:= MIN_ATT_INDEX;
						        op.state:= EG_DEC;
                  end;
                end;
              end;
			  EG_DEC:begin	// decay phase */
				        if ((OPL.eg_cnt and ((1 shl op.eg_sh_dr)-1))=0) then begin
					        op.volume:=op.volume +( eg_inc[op.eg_sel_dr + ((OPL.eg_cnt shr op.eg_sh_dr)and 7)]);
					        if ( op.volume >= op.sl ) then op.state:= EG_SUS;
                end;
               end;
			  EG_SUS:begin	// sustain phase */

				{ this is important behaviour:
                one can change percusive/non-percussive modes on the fly and
                the chip will remain in sustain phase - verified on real YM3812 }

				        if (op.eg_type<>0) then begin		// non-percussive mode */
									// do nothing */
                end else begin				// percussive mode */
					        // during sustain phase chip adds Release Rate (in percussive mode) */
					        if ((OPL.eg_cnt and ((1 shl op.eg_sh_rr)-1))=0) then begin
						        op.volume:=op.volume+(eg_inc[op.eg_sel_rr + ((OPL.eg_cnt shr op.eg_sh_rr) and 7)]);

						        if (op.volume>=MAX_ATT_INDEX) then op.volume:= MAX_ATT_INDEX;
                  end;
					      // else do nothing in sustain phase */
				       end;
              end;
			  EG_REL:begin	// release phase */
				        if ((OPL.eg_cnt and ((1 shl op.eg_sh_rr)-1))=0) then begin
					        op.volume:=op.volume+(eg_inc[op.eg_sel_rr + ((OPL.eg_cnt shr op.eg_sh_rr) and 7)]);

					        if (op.volume >= MAX_ATT_INDEX) then begin
						        op.volume:= MAX_ATT_INDEX;
						        op.state:= EG_OFF;
                  end;
                end;
               end;
      end; //del case
    end;
  end; //del while
	for i:=0 to (9*2)-1 do begin
		CH:=OPL.P_CH[i shr 1];
		op:=CH.SLOT[i and 1];

		// Phase Generator */
		if (op.vib)<>0 then begin
      block_fnum:= CH.block_fnum;
			fnum_lfo:=(block_fnum and $0380) shr 7;
			lfo_fn_table_index_offset:= lfo_pm_table[(OPL.LFO_PM+16*fnum_lfo) and $7f];
			if (lfo_fn_table_index_offset)<>0 then begin	// LFO phase modulation active */
				block_fnum:=block_fnum+lfo_fn_table_index_offset;
				block:=(block_fnum and $1c00) shr 10;
				op.Cnt:=op.Cnt+(sshr(OPL.fn_tab[block_fnum and $03ff],(7-block))*op.mul);
			end	else begin	// LFO phase modulation  = zero */
				op.Cnt:=op.Cnt+op.Incr;
			end;
		end else begin	// LFO phase modulation disabled for this operator */
			op.Cnt:=op.Cnt+op.Incr;
		end;
  end;

	{  The Noise Generator of the YM3812 is 23-bit shift register.
    *   Period is equal to 2^23-2 samples.
    *   Register works at sampling frequency of the chip, so output
    *   can change on every sample.
    *
    *   Output of the register and input to the bit 22 is:
    *   bit0 XOR bit14 XOR bit15 XOR bit22
    *
    *   Simply use bit 22 as the noise output.}

	OPL.noise_p:=trunc(OPL.noise_p+OPL.noise_f);
	i:=OPL.noise_p shr FREQ_SH;		// number of events (shifts of the shift register) */
	OPL.noise_p:=OPL.noise_p and FREQ_MASK;
	while (i>0) do begin
     {   UINT32 j;
        j = ( (OPL->noise_rng) ^ (OPL->noise_rng>>14) ^ (OPL->noise_rng>>15) ^ (OPL->noise_rng>>22) ) & 1;
        OPL->noise_rng = (j<<22) | (OPL->noise_rng>>1);

            Instead of doing all the logic operations above, we
            use a trick here (and use bit 0 as the noise output).
            The difference is only that the noise bit changes one
            step ahead. This doesn't matter since we don't know
            what is real state of the noise_rng after the reset.
     }

		if (OPL.noise_rng and 1)<>0 then OPL.noise_rng:=OPL.noise_rng xor $800302
		  else OPL.noise_rng:=OPL.noise_rng shr 1;

		i:=i-1;
	end; //del while!!
end;

function op_calc(phase:dword;env:cardinal;pm:integer;wave_tab:cardinal):integer;
var
	p:dword;
  tmp:integer;
begin
  tmp:=integer((phase and not(FREQ_MASK))+(pm shl 16));
	p:=(env shl 4)+sin_tab[wave_tab+(sshr(tmp,FREQ_SH) and SIN_MASK)];
	if (p>=TL_TAB_LEN) then op_calc:=0
    else op_calc:=tl_tab[p];
end;

function op_calc1(phase:dword;env:cardinal;pm:integer;wave_tab:cardinal):integer;
var
	p:dword;
  tmp:integer;
begin
  tmp:=integer((phase and not(FREQ_MASK))+pm);
	p:= (env shl 4)+sin_tab[wave_tab +(sshr(tmp,FREQ_SH) and SIN_MASK) ];
	if (p>=TL_TAB_LEN) then op_calc1:=0
    else op_calc1:=tl_tab[p];
end;

function volume_calc(OPL:pFM_OPL;OP:pOPL_SLOT):integer;
begin
   volume_calc:=OP.TLL+(cardinal(OP.volume)+(OPL.LFO_AM and OP.AMmask));
end;

// calculate output */
procedure OPL_CALC_CH(OPL:pFM_OPL;CH:pOPL_CH);
var
	SLOT:pOPL_SLOT;
	env:cardinal;
	out_:integer;
begin
	phase_modulation:= 0;
	// SLOT 1 */
	SLOT:=CH.SLOT[SLOT1];
	env:= volume_calc(OPL,SLOT);
	out_:=SLOT.op1_out[0] + SLOT.op1_out[1];
	SLOT.op1_out[0]:= SLOT.op1_out[1];
	SLOT.connect1^:=SLOT.connect1^+SLOT.op1_out[0];
	SLOT.op1_out[1]:= 0;
	if (env < ENV_QUIET ) then begin
		if (SLOT.FB=0) then out_:= 0;
		SLOT.op1_out[1]:=op_calc1(SLOT.Cnt, env, (out_ shl SLOT.FB), SLOT.wavetable );
	end;
	// SLOT 2 */
	SLOT:=CH.SLOT[SLOT2];
	env:= volume_calc(OPL,SLOT);
	if (env<ENV_QUIET ) then
		OPL.output:=OPL.output+op_calc(SLOT.Cnt, env, phase_modulation, SLOT.wavetable);
end;

procedure OPL_CALC_RH(OPL:pFM_OPL;noise:cardinal);
var
	SLOT:pOPL_SLOT;
	out_:integer;
	env:cardinal;
  bit7,bit3,bit2,res1:byte;
  phase:cardinal;
	bit5e,bit3e,res2,bit8:byte;
begin
	{ Bass Drum (verified on real YM3812):
      - depends on the channel 6 'connect' register:
          when connect = 0 it works the same as in normal (non-rhythm) mode (op1->op2->out)
          when connect = 1 _only_ operator 2 is present on output (op2->out), operator 1 is ignored
      - output sample always is multiplied by 2}

	phase_modulation:=0;
	// SLOT 1 */
	SLOT:=OPL.P_CH[6].SLOT[SLOT1];
	env:=volume_calc(OPL,SLOT);

	out_:= SLOT.op1_out[0] + SLOT.op1_out[1];
	SLOT.op1_out[0]:= SLOT.op1_out[1];

	if (SLOT.CON=0) then phase_modulation:=SLOT.op1_out[0];
	// else ignore output of operator 1 */

	SLOT.op1_out[1]:=0;
	if (env<ENV_QUIET) then begin
		if (SLOT.FB=0) then out_:=0;
		SLOT.op1_out[1]:= op_calc1(SLOT.Cnt, env, (out_ shl SLOT.FB), SLOT.wavetable );
	end;

	// SLOT 2 */
	SLOT:=OPL.P_CH[6].SLOT[SLOT2];
	env:=volume_calc(OPL,SLOT);
	if (env < ENV_QUIET ) then
		OPL.output:=OPL.output+op_calc(SLOT.Cnt, env, phase_modulation, SLOT.wavetable) * 2;
	// Phase generation is based on: */
	// HH  (13) channel 7->slot 1 combined with channel 8->slot 2 (same combination as TOP CYMBAL but different output phases) */
	// SD  (16) channel 7->slot 1 */
	// TOM (14) channel 8->slot 1 */
	// TOP (17) channel 7->slot 1 combined with channel 8->slot 2 (same combination as HIGH HAT but different output phases) */
	// Envelope generation based on: */
	// HH  channel 7->slot1 */
	// SD  channel 7->slot2 */
	// TOM channel 8->slot1 */
	// TOP channel 8->slot2 */
	// The following formulas can be well optimized.
  //     I leave them in direct form for now (in case I've missed something).

 // High Hat (verified on real YM3812)
	env:=volume_calc(OPL,SLOT7_1);
	if (env<ENV_QUIET) then begin
	 // high hat phase generation:
   //phase = d0 or 234 (based on frequency only)
   //phase = 34 or 2d0 (based on noise)
   // base frequency derived from operator 1 in channel 7
		bit7:= ((SLOT7_1.Cnt shr FREQ_SH) shr 7) and 1;
		bit3:= ((SLOT7_1.Cnt shr FREQ_SH) shr 3) and 1;
		bit2:= ((SLOT7_1.Cnt shr FREQ_SH) shr 2) and 1;
		res1:= (bit2 xor bit7) or bit3;
		// when res1 = 0 phase = 0x000 | 0xd0;
		// when res1 = 1 phase = 0x200 | (0xd0>>2);
    if res1<>0 then phase:=($200 or ($d0 shr 2))
      else phase:=$d0;
		// enable gate based on frequency of operator 2 in channel 8
		bit5e:=((SLOT8_2.Cnt shr FREQ_SH) shr 5) and 1;
		bit3e:=((SLOT8_2.Cnt shr FREQ_SH) shr 3) and 1;
		res2:=(bit3e xor bit5e);
		// when res2 = 0 pass the phase from calculation above (res1);
		// when res2 = 1 phase = 0x200 | (0xd0>>2);
		if (res2<>0) then	phase:=($200 or ($d0 shr 2));
		// when phase & 0x200 is set and noise=1 then phase = 0x200|0xd0
		// when phase & 0x200 is set and noise=0 then phase = 0x200|(0xd0>>2), ie no change
		if (phase and $200)<>0 then begin
			if (noise<>0) then phase:= $200 or $d0;
		end	else begin
		// when phase & 0x200 is clear and noise=1 then phase = 0xd0>>2
		// when phase & 0x200 is clear and noise=0 then phase = 0xd0, ie no change
			if (noise<>0) then phase:=$d0 shr 2;
		end;
		OPL.output:=OPL.output+(op_calc(phase shl FREQ_SH, env, 0, SLOT7_1.wavetable)*2);
	end;
	// Snare Drum (verified on real YM3812)
	env:= volume_calc(OPL,SLOT7_2);
	if (env<ENV_QUIET) then begin
		// base frequency derived from operator 1 in channel 7
		bit8:= ((SLOT7_1.Cnt shr FREQ_SH) shr 8) and 1;
		// when bit8 = 0 phase = 0x100;
		// when bit8 = 1 phase = 0x200;
    if bit8<>0 then phase:=$200
      else phase:=$100;
		// Noise bit XOR'es phase by 0x100
		// when noisebit = 0 pass the phase from calculation above
		// when noisebit = 1 phase ^= 0x100;
		// in other words: phase ^= (noisebit<<8);
		if (noise<>0) then phase:=phase xor $100;
		OPL.output:=OPL.output +(op_calc(phase shl FREQ_SH, env, 0, SLOT7_2.wavetable) * 2);
	end;

	// Tom Tom (verified on real YM3812) */
	env:= volume_calc(OPL,SLOT8_1);
	if ( env<ENV_QUIET ) then
		OPL.output:=OPL.output+(op_calc(SLOT8_1.Cnt, env, 0, SLOT8_1.wavetable) * 2);

	// Top Cymbal (verified on real YM3812)
	env:=volume_calc(OPL,SLOT8_2);
	if (env<ENV_QUIET) then begin
		// base frequency derived from operator 1 in channel 7
	  bit7:= ((SLOT7_1.Cnt shr FREQ_SH) shr 7) and 1;
		bit3:= ((SLOT7_1.Cnt shr FREQ_SH) shr 3) and 1;
		bit2:= ((SLOT7_1.Cnt shr FREQ_SH) shr 2) and 1;
		res1:= (bit2 xor bit7) or bit3;
		// when res1 = 0 phase = 0x000 | 0x100;
		// when res1 = 1 phase = 0x200 | 0x100;
    if res1<>0 then phase:=$300
      else phase:=$100;
		// enable gate based on frequency of operator 2 in channel 8
		bit5e:=((SLOT8_2.Cnt shr FREQ_SH) shr 5) and 1;
		bit3e:= ((SLOT8_2.Cnt shr FREQ_SH) shr 3) and 1;
		res2:= (bit3e xor bit5e);
		// when res2 = 0 pass the phase from calculation above (res1);
		// when res2 = 1 phase = 0x200 | 0x100;
		if (res2<>0) then phase:=$300;
		OPL.output:=OPL.output +(op_calc(phase shl FREQ_SH, env, 0, SLOT8_2.wavetable) * 2);
	end;

end;

end.
