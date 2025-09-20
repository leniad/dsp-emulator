unit ym_2413;
interface
uses {$ifdef windows}windows,{$else}main_engine,{$endif}fm_2151,sound_engine,
     cpu_misc,dialogs,math;

type
  topll_slot=record
		ar:dword;         // attack rate: AR<<2
		dr:dword;         // decay rate:  DR<<2
		rr:dword;         // release rate:RR<<2
		KSR_m:byte;       // key scale rate
		ksl:byte;        // keyscale level
		ksr:byte;        // key scale rate: kcode>>KSR
		mul:byte;        // multiple: mul_tab[ML]
		// Phase Generator
		phase:dword;      // frequency counter
		freq:dword;       // frequency counter step
		fb_shift:byte;   // feedback shift value
		op1_out:array[0..1] of integer; // slot1 output for feedback
		// Envelope Generator
		eg_type:byte;    // percussive/nonpercussive mode
		state:byte;      // phase type
		TL:dword;         // total level: TL << 2
		TLL:integer;        // adjusted now TL
		volume:integer;     // envelope counter
		sl:dword;         // sustain level: sl_tab[SL]
		eg_sh_dp:byte;   // (dump state)
		eg_sel_dp:byte;  // (dump state)
		eg_sh_ar:byte;   // (attack state)
		eg_sel_ar:byte;  // (attack state)
		eg_sh_dr:byte;   // (decay state)
		eg_sel_dr:byte;  // (decay state)
		eg_sh_rr:byte;   // (release state for non-perc.)
		eg_sel_rr:byte;  // (release state for non-perc.)
		eg_sh_rs:byte;   // (release state for perc.mode)
		eg_sel_rs:byte;  // (release state for perc.mode)
		key:dword;        // 0 = KEY OFF, >0 = KEY ON
		// LFO
		AMmask:dword;     // LFO Amplitude Modulation enable mask
		vib:byte;        // LFO Phase Modulation enable flag (active high)
		// waveform select
		wavetable:dword;
	end;
  topll_ch=record
		slot:array[0..1] of topll_slot;
		// phase generator state
		block_fnum:dword; // block+fnum
		fc:dword;         // Freq. freqement base
		ksl_base:dword;   // KeyScaleLevel Base step
		kcode:byte;      // key code (for key scaling)
		sus:byte;        // sus on/off (release speed in percussive mode)
  end;
  ym2413_chip=class(snd_chip_class)
       constructor create(clock:dword;amp:single=1);
       destructor free;
    public
       procedure reset;
       procedure update;
       procedure write(valor:byte);
       procedure address(valor:byte);
    private
      ch:array[0..8] of topll_ch;  // OPLL chips have 9 channels
	    instvol_r:array[0..8] of byte;           // instrument/volume (or volume/volume in percussive mode)
	    eg_cnt:dword;                 // global envelope generator counter    
      eg_timer:dword;               // global envelope generator counter works at frequency = chipclock/72 
      eg_timer_add:dword;           // step of eg_timer                     
      eg_timer_overflow:dword;      // envelope generator timer overflows every 1 sample (on real chip) 
      rhythm:byte;                 // Rhythm mode                  
      addrs:byte;
    	// LFO 
      LFO_AM:dword;
      LFO_PM:integer;
      lfo_am_cnt:dword;
      lfo_am_inc:dword;
      lfo_pm_cnt:dword;
      lfo_pm_inc:dword;
      noise_rng:dword;              // 23 bit noise shift register  
      noise_p:dword;                // current noise 'phase'        
      noise_f:dword;                // current noise period         
      inst_tab:array[0..18,0..7] of byte;
      output:array[0..1] of integer;
      procedure write_int(reg,valor:byte);
      procedure update_instrument_zero(r:byte);
      procedure set_mul(slot,v:byte);
      procedure calc_fcslot(ch_m,slot_m:byte);
      procedure set_ksl_tl(chan,v:byte);
      procedure set_ksl_wave_fb(chan,v:byte);
      procedure set_ar_dr(slot,v:byte);
      procedure set_sl_rr(slot,v:byte);
      procedure load_instrument(chan,slot:byte;inst:pbyte);
      procedure key_on(slot,chan:byte;key_set:dword);
      procedure key_off(slot,chan:byte;key_clr:dword);
      procedure advance_lfo;
      procedure chan_calc(ch:byte);
      procedure rhythm_calc(ch:byte;noise:dword);
      function volume_calc(ch,slot:byte):integer;
      function op_calc1(phase,env:dword;pm:integer;wave_tab:dword):integer;
      function op_calc(phase,env:dword;pm:integer;wave_tab:dword):integer;
      procedure advance;
  end;

var
  ym2413_0:ym2413_chip;

implementation
const
  FREQ_SH=         16;  // 16.16 fixed point (frequency calculations)
  EG_SH=           16;  // 16.16 fixed point (EG timing)
  LFO_SH=          24;  //  8.24 fixed point (LFO calculations)

  FREQ_MASK=       ((1 shl FREQ_SH)-1);

  // envelope output entries
  ENV_BITS=        10;
  ENV_LEN=        (1 shl ENV_BITS);
  ENV_STEP=        (128.0/ENV_LEN);

  MAX_ATT_INDEX=   ((1 shl (ENV_BITS-2))-1); //255
  MIN_ATT_INDEX=   0;

  // register number to channel number , slot offset
  SLOT1=0;
  SLOT2=1;

  // Envelope Generator phases
  EG_DMP=          5;
  EG_ATT=          4;
  EG_DEC=          3;
  EG_SUS=          2;
  EG_REL=          1;
  EG_OFF=          0;

  RATE_STEPS=8;
  TL_RES_LEN =     256;
  TL_TAB_LEN = (11*2*TL_RES_LEN);
  ENV_QUIET=       (TL_TAB_LEN shr 5);
  LFO_AM_TAB_ELEMENTS = 210;
  SIN_BITS =       10;
  SIN_LEN  =       (1 shl SIN_BITS);
  SIN_MASK =       (SIN_LEN-1);

  // key scale level
  // table is 3dB/octave, DV converts this into 6dB/octave
  // 0.1875 is bit 0 weight of the envelope counter (volume) expressed in the 'decibel' scale
  DV=(0.1875/1.0);

  KSL_TAB:array[0..(8*16)-1] of single=(
	// OCT 0
		0.000/DV, 0.000/DV, 0.000/DV, 0.000/DV,
		0.000/DV, 0.000/DV, 0.000/DV, 0.000/DV,
		0.000/DV, 0.000/DV, 0.000/DV, 0.000/DV,
		0.000/DV, 0.000/DV, 0.000/DV, 0.000/DV,
	// OCT 1
		0.000/DV, 0.000/DV, 0.000/DV, 0.000/DV,
		0.000/DV, 0.000/DV, 0.000/DV, 0.000/DV,
		0.000/DV, 0.750/DV, 1.125/DV, 1.500/DV,
		1.875/DV, 2.250/DV, 2.625/DV, 3.000/DV,
	// OCT 2
		0.000/DV, 0.000/DV, 0.000/DV, 0.000/DV,
		0.000/DV, 1.125/DV, 1.875/DV, 2.625/DV,
		3.000/DV, 3.750/DV, 4.125/DV, 4.500/DV,
		4.875/DV, 5.250/DV, 5.625/DV, 6.000/DV,
	// OCT 3
		0.000/DV, 0.000/DV, 0.000/DV, 1.875/DV,
		3.000/DV, 4.125/DV, 4.875/DV, 5.625/DV,
		6.000/DV, 6.750/DV, 7.125/DV, 7.500/DV,
		7.875/DV, 8.250/DV, 8.625/DV, 9.000/DV,
	// OCT 4
		0.000/DV, 0.000/DV, 3.000/DV, 4.875/DV,
		6.000/DV, 7.125/DV, 7.875/DV, 8.625/DV,
		9.000/DV, 9.750/DV,10.125/DV,10.500/DV,
		10.875/DV,11.250/DV,11.625/DV,12.000/DV,
	// OCT 5
		0.000/DV, 3.000/DV, 6.000/DV, 7.875/DV,
		9.000/DV,10.125/DV,10.875/DV,11.625/DV,
		12.000/DV,12.750/DV,13.125/DV,13.500/DV,
		13.875/DV,14.250/DV,14.625/DV,15.000/DV,
	// OCT 6
		0.000/DV, 6.000/DV, 9.000/DV,10.875/DV,
		12.000/DV,13.125/DV,13.875/DV,14.625/DV,
		15.000/DV,15.750/DV,16.125/DV,16.500/DV,
		16.875/DV,17.250/DV,17.625/DV,18.000/DV,
	// OCT 7
		0.000/DV, 9.000/DV,12.000/DV,13.875/DV,
		15.000/DV,16.125/DV,16.875/DV,17.625/DV,
		18.000/DV,18.750/DV,19.125/DV,19.500/DV,
		19.875/DV,20.250/DV,20.625/DV,21.000/DV);

  // 0 / 1.5 / 3.0 / 6.0 dB/OCT, confirmed on a real YM2413 (the application manual is incorrect)
  KSL_SHIFT:array[0..3] of byte=(31,2,1,0);

  // sustain level table (3dB per step)
  // 0 - 15: 0, 3, 6, 9,12,15,18,21,24,27,30,33,36,39,42,45 (dB)
  //SC(db) (uint32_t) ( db * (1.0/ENV_STEP) )
  SL_TAB:array[0..15] of word=(
	0,8,16,24,32,40,48,56,64,72,80,88,96,104,112,120);

  EG_INC:array [0..(15*RATE_STEPS-1)] of byte=(
	//cycle:0 1  2 3  4 5  6 7
	// 0
  0,1, 0,1, 0,1, 0,1, // rates 00..12 0 (increment by 0 or 1)
	// 1
  0,1, 0,1, 1,1, 0,1, // rates 00..12 1
	// 2
  0,1, 1,1, 0,1, 1,1, // rates 00..12 2
	// 3
  0,1, 1,1, 1,1, 1,1, // rates 00..12 3
	// 4
  1,1, 1,1, 1,1, 1,1, // rate 13 0 (increment by 1)
	// 5
  1,1, 1,2, 1,1, 1,2, // rate 13 1
	// 6
  1,2, 1,2, 1,2, 1,2, // rate 13 2
	// 7
  1,2, 2,2, 1,2, 2,2, // rate 13 3
	// 8
  2,2, 2,2, 2,2, 2,2, // rate 14 0 (increment by 2)
	// 9
  2,2, 2,4, 2,2, 2,4, // rate 14 1
	//10
  2,4, 2,4, 2,4, 2,4, // rate 14 2
	//11
  2,4, 4,4, 2,4, 4,4, // rate 14 3
	//12
  4,4, 4,4, 4,4, 4,4, // rates 15 0, 15 1, 15 2, 15 3 (increment by 4)
	//13
  8,8, 8,8, 8,8, 8,8, // rates 15 2, 15 3 for attack
	//14
  0,0, 0,0, 0,0, 0,0); // infinity rates for attack and decay(s)


//note that there is no O(13) in this table - it's directly in the code */
EG_RATE_SELECT:array[0..(16+64+16)-1] of byte = (   // Envelope Generator rates (16 + 64 rates + 16 RKS)
	// 16 infinite time rates */
	14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,
	14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,14*RATE_STEPS,
	// rates 00-12
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
  0*RATE_STEPS,1*RATE_STEPS,2*RATE_STEPS,3*RATE_STEPS,
	// rate 13
  4*RATE_STEPS,5*RATE_STEPS,6*RATE_STEPS,7*RATE_STEPS,
	// rate 14
  8*RATE_STEPS,9*RATE_STEPS,10*RATE_STEPS,11*RATE_STEPS,
	// rate 15
  12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,
	// 16 dummy rates (same as 15 3)
	12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,
	12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS,12*RATE_STEPS);

//rate  0,    1,    2,    3,    4,   5,   6,   7,  8,  9, 10, 11, 12, 13, 14, 15
//shift 13,   12,   11,   10,   9,   8,   7,   6,  5,  4,  3,  2,  1,  0,  0,  0
//mask  8191, 4095, 2047, 1023, 511, 255, 127, 63, 31, 15, 7,  3,  1,  0,  0,  0

EG_RATE_SHIFT:array[0..(16+64+16)-1] of byte= (    // Envelope Generator counter shifts (16 + 64 rates + 16 RKS)
	// 16 infinite time rates
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,
	// rates 00-12
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
  1,1,1,1,
	// rate 13
  0,0,0,0,
	// rate 14
  0,0,0,0,
	// rate 15
  0,0,0,0,
	// 16 dummy rates (same as 15 3) */
	0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0);

// multiple table */
MUL_TAB:array[0..15] of byte=(
	// 1/2, 1, 2, 3, 4, 5, 6, 7, 8, 9,10,10,12,12,15,15
	1, 2, 4, 6, 8, 10, 12, 14,
	16, 18,20,20,24,24,30,30);


{ LFO Amplitude Modulation table (verified on real YM3812)
   27 output levels (triangle waveform); 1 level takes one of: 192, 256 or 448 samples

   Length: 210 elements.

    Each of the elements has to be repeated
    exactly 64 times (on 64 consecutive samples).
    The whole table takes: 64 * 210 = 13440 samples.

We use data>>1, until we find what it really is on real chip...}
LFO_AM_TABLE:array[0..(LFO_AM_TAB_ELEMENTS-1)] of byte = (
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

// LFO Phase Modulation table (verified on real YM2413)
LFO_PM_TABLE:array[0..63] of integer = (
	// FNUM2/FNUM = 0 00xxxxxx (0x0000)
	0, 0, 0, 0, 0, 0, 0, 0,
	// FNUM2/FNUM = 0 01xxxxxx (0x0040)
	1, 0, 0, 0,-1, 0, 0, 0,
	// FNUM2/FNUM = 0 10xxxxxx (0x0080)
	2, 1, 0,-1,-2,-1, 0, 1,
	// FNUM2/FNUM = 0 11xxxxxx (0x00C0)
	3, 1, 0,-1,-3,-1, 0, 1,
	// FNUM2/FNUM = 1 00xxxxxx (0x0100)
	4, 2, 0,-2,-4,-2, 0, 2,
	// FNUM2/FNUM = 1 01xxxxxx (0x0140)
	5, 2, 0,-2,-5,-2, 0, 2,
	// FNUM2/FNUM = 1 10xxxxxx (0x0180)
	6, 3, 0,-3,-6,-3, 0, 3,
	// FNUM2/FNUM = 1 11xxxxxx (0x01C0)
	7, 3, 0,-3,-7,-3, 0, 3);

{ This is not 100% perfect yet but very close
 - multi parameters are 100% correct (instruments and drums)
 - LFO PM and AM enable are 100% correct
 - waveform DC and DM select are 100% correct}

TABLE:array[0..18,0..7] of byte =(
// MULT  MULT modTL DcDmFb AR/DR AR/DR SL/RR SL/RR */
//   0     1     2     3     4     5     6    7    */
// These YM2413(OPLL) patch dumps are done via audio analysis (and a/b testing?) from Jarek and are known to be inaccurate */
	($49, $4c, $4c, $12, $00, $00, $00, $00 ),  //0

	($61, $61, $1e, $17, $f0, $78, $00, $17 ),  //1
	($13, $41, $1e, $0d, $d7, $f7, $13, $13 ),  //2
	($13, $01, $99, $04, $f2, $f4, $11, $23 ),  //3
	($21, $61, $1b, $07, $af, $64, $40, $27 ),  //4

	($22, $21, $1e, $06, $f0, $75, $08, $18 ),  //5

	($31, $22, $16, $05, $90, $71, $00, $13 ),  //6

	($21, $61, $1d, $07, $82, $80, $10, $17 ),  //7
	($23, $21, $2d, $16, $c0, $70, $07, $07 ),  //8
	($61, $61, $1b, $06, $64, $65, $10, $17 ),  //9

	($61, $61, $0c, $18, $85, $f0, $70, $07 ),  //A

	($23, $01, $07, $11, $f0, $a4, $00, $22 ),  //B
	($97, $c1, $24, $07, $ff, $f8, $22, $12 ),  //C

	($61, $10, $0c, $05, $f2, $f4, $40, $44 ),  //D

	($01, $01, $55, $03, $f3, $92, $f3, $f3 ),  //E
	($61, $41, $89, $03, $f1, $f4, $f0, $13 ),  //F

// drum instruments definitions */
// MULTI MULTI modTL  xxx  AR/DR AR/DR SL/RR SL/RR
//   0     1     2     3     4     5     6    7
// Drums dumped from the VRC7 using debug mode, these are likely also correct for ym2413(OPLL) but need verification
	($01, $01, $18, $0f, $df, $f8, $6a, $6d ), // BD
	($01, $01, $00, $00, $c8, $d8, $a7, $68 ), // HH, SD
	($05, $01, $00, $00, $f8, $aa, $59, $55 ));// TOM, TOP CYM


// VRC7 Instruments : Dumped from internal ROM
// reference : https://siliconpr0n.org/archive/doku.php?id=vendor:yamaha:opl2
VRC7_TABLE:array[0..18,0..7] of byte= (
// MULT  MULT modTL DcDmFb AR/DR AR/DR SL/RR SL/RR */
//   0     1     2     3     4     5     6    7    */
	($00, $00, $00, $00, $00, $00, $00, $00 ),  //0 (This is the user-defined instrument, should this default to anything?)

	($03, $21, $05, $06, $e8, $81, $42, $27 ),  //1
	($13, $41, $14, $0d, $d8, $f6, $23, $12 ),  //2
	($11, $11, $08, $08, $fa, $b2, $20, $12 ),  //3
	($31, $61, $0c, $07, $a8, $64, $61, $27 ),  //4
	($32, $21, $1e, $06, $e1, $76, $01, $28 ),  //5
	($02, $01, $06, $00, $a3, $e2, $f4, $f4 ),  //6
	($21, $61, $1d, $07, $82, $81, $11, $07 ),  //7
	($23, $21, $22, $17, $a2, $72, $01, $17 ),  //8
	($35, $11, $25, $00, $40, $73, $72, $01 ),  //9
	($b5, $01, $0f, $0f, $a8, $a5, $51, $02 ),  //A
	($17, $c1, $24, $07, $f8, $f8, $22, $12 ),  //B
	($71, $23, $11, $06, $65, $74, $18, $16 ),  //C
	($01, $02, $d3, $05, $c9, $95, $03, $02 ),  //D
	($61, $63, $0c, $00, $94, $c0, $33, $f6 ),  //E
	($21, $72, $0d, $00, $c1, $d5, $56, $06 ),  //F

// Drums (silent due to no RO output pin(?) on VRC7, but present internally; these are probably shared with YM2413)
// MULTI MULTI modTL  xxx  AR/DR AR/DR SL/RR SL/RR
//   0     1     2     3     4     5     6    7
	($01, $01, $18, $0f, $df, $f8, $6a, $6d ),// BD
	($01, $01, $00, $00, $c8, $d8, $a7, $68 ),// HH, SD
	($05, $01, $00, $00, $f8, $aa, $59, $55 ));// TOM, TOP CYM

var
  chips_total:integer=-1;
  tl_tab:array[0..(TL_TAB_LEN-1)] of integer;
  sin_tab:array[0..((SIN_LEN*2)-1)] of dword;
  fn_tab:array[0..1023] of dword;

constructor ym2413_chip.create(clock:dword;amp:single=1);
var
  n:integer;
  m,o:double;
  x:byte;
  i:word;
begin
  if addr(update_sound_proc)=nil then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!', mtInformation,[mbOk], 0);
  chips_total:=chips_total+1;
  self.tsample_num:=init_channel;
  self.amp:=amp;
  copymemory(@self.inst_tab,@table,sizeof(table));
	for x:=0 to (TL_RES_LEN-1) do begin
		m:=(1 shl 16)/power(2,(x+1)*(ENV_STEP/4.0)/8.0);
		m:=floor(m);
		// we never reach (1<<16) here due to the (x+1) 
		// result fits within 16 bits at maximum 
		n:=integer(trunc(m)); // 16 bits here 
		n:=n shr 4;  // 12 bits here 
		if (n and 1)<>0 then n:=(n shr 1)+1   // round to nearest
		  else n:=n shr 1;
		// 11 bits here (rounded) 
		tl_tab[x*2+0]:=n;
		tl_tab[x*2+1]:=-tl_tab[x*2+0];
		for i:=1 to 10 do begin
			tl_tab[x*2+0+i*2*TL_RES_LEN]:= tl_tab[x*2+0] shr i;
			tl_tab[x*2+1+i*2*TL_RES_LEN]:=-tl_tab[x*2+0+i*2*TL_RES_LEN];
		end;
	end;
	for i:=0 to (SIN_LEN-1) do begin
		// non-standard sinus 
		m:=sin(((i*2)+1)*M_PI/SIN_LEN); // checked against the real chip
		// we never reach zero here due to ((i*2)+1)
		//o:=8*ln(1.0/abs(m))/ln(2.0);  // convert to 'decibels' 
    if (m>0.0) then o:= 8*ln(1.0/m)/ln(2)	// convert to 'decibels' */
		  else o:=8*ln(-1.0/m)/ln(2);	// convert to 'decibels' */
		o:=o/(ENV_STEP/4);
		n:=trunc(2.0*o);
		if (n and 1)<>0 then n:=(n shr 1)+1  // round to nearest 
		  else n:=n shr 1;
		// waveform 0: standard sinus  
    if m>=0 then sin_tab[i]:=n*2+0
      else sin_tab[i]:=n*2+1;
		// waveform 1:  __      __     
		//             /  \____/  \____
		// output only first half of the sinus waveform (positive one) 
		if (i and (1 shl (SIN_BITS-1)))<>0 then sin_tab[1*SIN_LEN+i]:=TL_TAB_LEN
		  else sin_tab[1*SIN_LEN+i]:=sin_tab[i];
	end;

	// make fnumber -> increment counter table 
	for i:=0 to 1023 do begin
		// OPLL (YM2413) phase increment counter = 18bit
		fn_tab[i]:=i*(64 shl (FREQ_SH-10)); // -10 because chip works with 10.10 fixed point, while we use 16.16 
	end;
	// Amplitude modulation: 27 output levels (triangle waveform); 1 level takes one of: 192, 256 or 448 samples 
	// One entry from LFO_AM_TABLE lasts for 64 samples 
	self.lfo_am_inc:=(1 shl LFO_SH) div 64;
	// Vibrato: 8 output levels (triangle waveform); 1 level takes 1024 samples 
	self.lfo_pm_inc:=(1 shl LFO_SH) div 1024;
	// Noise generator: a step takes 1 sample 
	self.noise_f:=1 shl FREQ_SH;
	self.eg_timer_add:=1 shl EG_SH;
	self.eg_timer_overflow:=1 shl EG_SH;
end;

destructor ym2413_chip.free;
begin
end;

procedure ym2413_chip.reset;
var
  i,c,s:byte;
begin
	self.eg_timer:=0;
	self.eg_cnt:=0;
	self.noise_rng:=1;    // noise shift register
	// reset with register write
	self.write_int($f,0); //test reg
	for i:=$3f downto $10 do self.write_int(i,0);
	// reset operator parameters
	for c:=0 to 8 do begin
		for s:=0 to 1 do begin
			// wave table
			self.ch[c].slot[s].wavetable:=0;
			self.ch[c].slot[s].state:=EG_OFF;
			self.ch[c].slot[s].volume:=MAX_ATT_INDEX;
		end;
	end;
end;

// advance LFO to next sample
procedure ym2413_chip.advance_lfo;
var
  tempdw:dword;
begin
	// LFO
	self.lfo_am_cnt:=self.lfo_am_cnt+self.lfo_am_inc;
  //Whaaaaaaaat????? Si hago el shl 24, delphi falla...
  tempdw:=$d2000000; //LFO_AM_TAB_ELEMENTS shl LFO_SH;
	if (self.lfo_am_cnt>=tempdw) then self.lfo_am_cnt:=self.lfo_am_cnt-tempdw;
	self.LFO_AM:=lfo_am_table[self.lfo_am_cnt shr LFO_SH] shr 1;
	self.lfo_pm_cnt:=self.lfo_pm_cnt+self.lfo_pm_inc;
	self.LFO_PM:=(self.lfo_pm_cnt shr LFO_SH) and 7;
end;

function ym2413_chip.volume_calc(ch,slot:byte):integer;
begin
  volume_calc:=self.ch[ch].slot[slot].TLL+self.ch[ch].slot[slot].volume+(self.LFO_AM and self.ch[ch].slot[slot].AMmask);
end;

function ym2413_chip.op_calc1(phase,env:dword;pm:integer;wave_tab:dword):integer;
var
	p:dword;
	i,tmp:integer;
begin
	i:=(phase and not(FREQ_MASK))+pm;
  tmp:=((i shr FREQ_SH) and SIN_MASK);
	p:=(env shl 5)+sin_tab[wave_tab+tmp];
	if (p>=TL_TAB_LEN) then op_calc1:=0
    else op_calc1:=tl_tab[p];
end;

function ym2413_chip.op_calc(phase,env:dword;pm:integer;wave_tab:dword):integer;
var
	p:dword;
  tmp:integer;
begin
  tmp:=(((phase and not(FREQ_MASK))+(pm shl 17)) shr FREQ_SH) and SIN_MASK;
	p:=(env shl 5)+sin_tab[wave_tab+tmp];
	if (p>=TL_TAB_LEN) then op_calc:=0
    else op_calc:=tl_tab[p];
end;

// calculate output 
procedure ym2413_chip.chan_calc(ch:byte);
var
  env:dword;
  out_,phase_modulation:integer;
begin
	// SLOT 1 
	env:=self.volume_calc(ch,SLOT1);
	out_:=self.ch[ch].slot[SLOT1].op1_out[0]+self.ch[ch].slot[SLOT1].op1_out[1];
	self.ch[ch].slot[SLOT1].op1_out[0]:=self.ch[ch].slot[SLOT1].op1_out[1];
	phase_modulation:=self.ch[ch].slot[SLOT1].op1_out[0];
	self.ch[ch].slot[SLOT1].op1_out[1]:=0;
	if (env<ENV_QUIET) then begin
		if (self.ch[ch].slot[SLOT1].fb_shift=0) then out_:=0;
		self.ch[ch].slot[SLOT1].op1_out[1]:=self.op_calc1(self.ch[ch].slot[SLOT1].phase,env,(out_ shl self.ch[ch].slot[SLOT1].fb_shift), self.ch[ch].slot[SLOT1].wavetable);
	end;
	// SLOT 2 
	env:=self.volume_calc(ch,SLOT2);
	if (env<ENV_QUIET) then begin
		self.output[0]:=self.output[0]+op_calc(self.ch[ch].slot[SLOT2].phase,env,phase_modulation,self.ch[ch].slot[SLOT2].wavetable);
	end;
end;

procedure ym2413_chip.rhythm_calc(ch:byte;noise:dword);
var
	out_:integer;
	env,phase:dword;
	phase_modulation:integer;    // phase modulation input (SLOT 2) 
  res1,res2,bit2,bit3,bit7,bit8,bit5e,bit3e:byte;
begin
	{ Bass Drum (verified on real YM3812):
	  - depends on the channel 6 'connect' register:
	      when connect = 0 it works the same as in normal (non-rhythm) mode (op1->op2->out)
	      when connect = 1 _only_ operator 2 is present on output (op2->out), operator 1 is ignored
	  - output sample always is multiplied by 2}
	// SLOT 1 
	env:=volume_calc(6,SLOT1);
	out_:=self.ch[6].slot[SLOT1].op1_out[0]+self.ch[6].slot[SLOT1].op1_out[1];
	self.ch[6].slot[SLOT1].op1_out[0]:=self.ch[6].slot[SLOT1].op1_out[1];
	phase_modulation:=self.ch[6].slot[SLOT1].op1_out[0];
	self.ch[6].slot[SLOT1].op1_out[1]:=0;
	if (env<ENV_QUIET) then begin
		if (self.ch[6].slot[SLOT1].fb_shift=0) then out_:=0;
		self.ch[6].slot[SLOT1].op1_out[1]:=op_calc1(self.ch[6].slot[SLOT1].phase,env,(out_ shl self.ch[6].slot[SLOT1].fb_shift),self.ch[6].slot[SLOT1].wavetable);
	end;
	// SLOT 2 
	env:=volume_calc(6,SLOT2);
	if (env<ENV_QUIET) then self.output[1]:=self.output[1]+(op_calc(self.ch[6].slot[SLOT2].phase,env,phase_modulation,self.ch[6].slot[SLOT2].wavetable)*2);
	{ Phase generation is based on: 
	// HH  (13) channel 7->slot 1 combined with channel 8->slot 2 (same combination as TOP CYMBAL but different output phases)
	// SD  (16) channel 7->slot 1
	// TOM (14) channel 8->slot 1
	// TOP (17) channel 7->slot 1 combined with channel 8->slot 2 (same combination as HIGH HAT but different output phases)
	// Envelope generation based on: 
	// HH  channel 7->slot1
	// SD  channel 7->slot2
	// TOM channel 8->slot1
	// TOP channel 8->slot2
	 The following formulas can be well optimized.
	   I leave them in direct form for now (in case I've missed something).
	 High Hat (verified on real YM3812) }
	env:=volume_calc(7,SLOT1);
	if (env<ENV_QUIET) then begin
		{ high hat phase generation:
		    phase = d0 or 234 (based on frequency only)
		    phase = 34 or 2d0 (based on noise)}
		// base frequency derived from operator 1 in channel 7 
		bit7:=((self.ch[7].slot[SLOT1].phase shr FREQ_SH) shr 7) and 1;
		bit3:=((self.ch[7].slot[SLOT1].phase shr FREQ_SH) shr 3) and 1;
		bit2:=((self.ch[7].slot[SLOT1].phase shr FREQ_SH) shr 2) and 1;
		res1:=(bit2 xor bit7) or bit3;
		// when res1 = 0 phase = 0x000 | 0xd0; 
		// when res1 = 1 phase = 0x200 | (0xd0>>2); 
    if (res1<>0) then phase:=$200 or ($d0 shr 2)
      else phase:=$d0;
		// enable gate based on frequency of operator 2 in channel 8 
		bit5e:= ((self.ch[8].slot[SLOT2].phase shr FREQ_SH) shr 5) and 1;
		bit3e:= ((self.ch[8].slot[SLOT2].phase shr FREQ_SH) shr 3) and 1;
		res2:=bit3e or bit5e;
		// when res2 = 0 pass the phase from calculation above (res1); 
		// when res2 = 1 phase = 0x200 | (0xd0>>2); 
		if (res2<>0) then phase:=($200 or ($d0 shr 2));
		// when phase & 0x200 is set and noise=1 then phase = 0x200|0xd0 
		// when phase & 0x200 is set and noise=0 then phase = 0x200|(0xd0>>2), ie no change 
		if (phase and $200)<>0 then begin
			if (noise<>0) then phase:=$200 or $d0;
		end else begin
		// when phase & 0x200 is clear and noise=1 then phase = 0xd0>>2 
		// when phase & 0x200 is clear and noise=0 then phase = 0xd0, ie no change 
			if (noise<>0) then phase:=$d0 shr 2;
		end;
		self.output[1]:=self.output[1]+(op_calc(phase shl FREQ_SH,env,0,self.ch[7].slot[SLOT1].wavetable)*2);
	end;
	// Snare Drum (verified on real YM3812) 
	env:=volume_calc(7,SLOT2);
	if (env<ENV_QUIET) then begin
		// base frequency derived from operator 1 in channel 7 
		bit8:=((self.ch[7].slot[SLOT1].phase shr FREQ_SH) shr 8) and 1;
		// when bit8 = 0 phase = 0x100; 
		// when bit8 = 1 phase = 0x200; 
    if (bit8<>0) then phase:=$200
      else phase:=$100;
		// Noise bit XOR'es phase by 0x100 
		// when noisebit = 0 pass the phase from calculation above 
		// when noisebit = 1 phase ^= 0x100; 
		// in other words: phase ^= (noisebit<<8); 
		if (noise<>0) then phase:=phase xor $100;
		self.output[1]:=self.output[1]+(op_calc(phase shl FREQ_SH,env,0,self.ch[7].slot[SLOT2].wavetable)*2);
	end;
	// Tom Tom (verified on real YM3812) 
	env:=volume_calc(8,SLOT1);
	if (env<ENV_QUIET) then self.output[1]:=self.output[1]+(op_calc(self.ch[8].slot[SLOT1].phase,env,0,self.ch[8].slot[SLOT1].wavetable)*2);
	// Top Cymbal (verified on real YM2413) 
	env:=volume_calc(8,SLOT2);
	if (env<ENV_QUIET) then begin
		// base frequency derived from operator 1 in channel 7 
		bit7:=((self.ch[7].slot[SLOT1].phase shr FREQ_SH) shr 7) and 1;
		bit3:=((self.ch[7].slot[SLOT1].phase shr FREQ_SH) shr 3) and 1;
		bit2:=((self.ch[7].slot[SLOT1].phase shr FREQ_SH) shr 2) and 1;
		res1:=(bit2 xor bit7) or bit3;
		// when res1 = 0 phase = 0x000 | 0x100; 
		// when res1 = 1 phase = 0x200 | 0x100; 
    if (res1<>0) then phase:=$300
      else phase:=$100;
		// enable gate based on frequency of operator 2 in channel 8 
		bit5e:=((self.ch[8].slot[SLOT2].phase shr FREQ_SH) shr 5) and 1;
		bit3e:=((self.ch[8].slot[SLOT2].phase shr FREQ_SH) shr 3) and 1;
		res2:=(bit3e or bit5e);
		// when res2 = 0 pass the phase from calculation above (res1); 
		// when res2 = 1 phase = 0x200 | 0x100; 
		if (res2<>0) then phase:=$300;
		self.output[1]:=self.output[1]+(op_calc(phase shl FREQ_SH,env,0,self.ch[8].slot[SLOT2].wavetable)*2);
	end;
end;

// advance to next sample 
procedure ym2413_chip.advance;
var
  i:dword;
  ch,op:byte;
  block:byte;
	fnum_lfo:dword;
	block_fnum:dword;
	lfo_fn_table_index_offset:integer;
  tmp:single;
begin
	// Envelope Generator 
	self.eg_timer:=self.eg_timer+self.eg_timer_add;
	while (self.eg_timer>=self.eg_timer_overflow) do begin
		self.eg_timer:=self.eg_timer-self.eg_timer_overflow;
		self.eg_cnt:=self.eg_cnt+1;
		for i:=0 to 17 do begin
			ch:=i div 2;
			op:=i and 1;
			case self.ch[ch].slot[op].state of
			  EG_DMP:begin        // dump phase
			            //dump phase is performed by both operators in each channel
			            //when CARRIER envelope gets down to zero level,
			            //  phases in BOTH opearators are reset (at the same time ?)
				          if ((self.eg_cnt and ((1 shl self.ch[ch].slot[op].eg_sh_dp)-1))=0) then begin
					          self.ch[ch].slot[op].volume:=self.ch[ch].slot[op].volume+eg_inc[self.ch[ch].slot[op].eg_sel_dp+((eg_cnt shr self.ch[ch].slot[op].eg_sh_dp) and 7)];
					          if (self.ch[ch].slot[op].volume>=MAX_ATT_INDEX) then begin
						          self.ch[ch].slot[op].volume:=MAX_ATT_INDEX;
						          self.ch[ch].slot[op].state:=EG_ATT;
                      // restart Phase Generator  
						          self.ch[ch].slot[op].phase:=0;
                    end;
				          end;
			          end;
			  EG_ATT:begin        // attack phase 
				        if ((self.eg_cnt and ((1 shl self.ch[ch].slot[op].eg_sh_ar)-1))=0) then begin
                  tmp:=(not(self.ch[ch].slot[op].volume)*
												(eg_inc[self.ch[ch].slot[op].eg_sel_ar+((eg_cnt shr self.ch[ch].slot[op].eg_sh_ar) and 7)])
												)/4;
					        self.ch[ch].slot[op].volume:=trunc(self.ch[ch].slot[op].volume+tmp);
					        if (self.ch[ch].slot[op].volume<=MIN_ATT_INDEX) then begin
						        self.ch[ch].slot[op].volume:=MIN_ATT_INDEX;
						        self.ch[ch].slot[op].state:=EG_DEC;
                  end;
                end;
               end;
			  EG_DEC:begin    // decay phase
				          if ((self.eg_cnt and ((1 shl self.ch[ch].slot[op].eg_sh_dr)-1))=0) then begin
					          self.ch[ch].slot[op].volume:=self.ch[ch].slot[op].volume+eg_inc[self.ch[ch].slot[op].eg_sel_dr+((eg_cnt shr self.ch[ch].slot[op].eg_sh_dr) and 7)];
					          if (self.ch[ch].slot[op].volume>=self.ch[ch].slot[op].sl) then self.ch[ch].slot[op].state:=EG_SUS;
                  end;
               end;
			  EG_SUS:begin    // sustain phase 
				          // this is important behaviour:
				          //one can change percusive/non-percussive modes on the fly and
				          //the chip will remain in sustain phase - verified on real YM3812 
				          if(self.ch[ch].slot[op].eg_type)<>0 then begin // non-percussive mode (sustained tone) 
									  // do nothing 
                  end else begin // percussive mode 
					          // during sustain phase chip adds Release Rate (in percussive mode) 
					          if ((self.eg_cnt and ((1 shl self.ch[ch].slot[op].eg_sh_rr)-1))=0) then begin
						          self.ch[ch].slot[op].volume:=self.ch[ch].slot[op].volume+eg_inc[self.ch[ch].slot[op].eg_sel_rr+((self.eg_cnt shr self.ch[ch].slot[op].eg_sh_rr) and 7)];
						          if (self.ch[ch].slot[op].volume>=MAX_ATT_INDEX) then self.ch[ch].slot[op].volume:=MAX_ATT_INDEX;
					          end;
					          // else do nothing in sustain phase */
				          end;
                end;
			  EG_REL:begin    // release phase 
			          { exclude modulators in melody channels from performing anything in this mode
			           allowed are only carriers in melody mode and rhythm slots in rhythm mode 
			           This table shows which operators and on what conditions are allowed to perform EG_REL:
            			(a) - always perform EG_REL
            			(n) - never perform EG_REL
            			(r) - perform EG_REL in Rhythm mode ONLY
          			    0: 0 (n),  1 (a)
          			    1: 2 (n),  3 (a)
           			    2: 4 (n),  5 (a)
          			    3: 6 (n),  7 (a)
           			    4: 8 (n),  9 (a)
          			    5: 10(n),  11(a)
          			    6: 12(r),  13(a)
          			    7: 14(r),  15(a)
          			    8: 16(r),  17(a)}
				         if ( ((i and 1)<>0) or (((self.rhythm and $20)<>0) and (i>=12))) then begin // exclude modulators 
					          if (self.ch[ch].slot[op].eg_type<>0) then begin     // non-percussive mode (sustained tone) 
					            //this is correct: use RR when SUS = OFF
					            //and use RS when SUS = ON
						          if (self.ch[ch].sus<>0) then begin
							          if ((self.eg_cnt and ((1 shl self.ch[ch].slot[op].eg_sh_rs)-1) )=0) then begin
							            self.ch[ch].slot[op].volume:=self.ch[ch].slot[op].volume+eg_inc[self.ch[ch].slot[op].eg_sel_rs+((self.eg_cnt shr self.ch[ch].slot[op].eg_sh_rs) and 7)];
								          if (self.ch[ch].slot[op].volume>=MAX_ATT_INDEX) then begin
									          self.ch[ch].slot[op].volume:=MAX_ATT_INDEX;
									          self.ch[ch].slot[op].state:=EG_OFF;
								          end;
							          end;
						          end else begin
							          if ((self.eg_cnt and ((1 shl self.ch[ch].slot[op].eg_sh_rr)-1))=0) then begin
								          self.ch[ch].slot[op].volume:=self.ch[ch].slot[op].volume+eg_inc[self.ch[ch].slot[op].eg_sel_rr+((self.eg_cnt shr self.ch[ch].slot[op].eg_sh_rr) and 7)];
								          if (self.ch[ch].slot[op].volume>=MAX_ATT_INDEX) then begin
									          self.ch[ch].slot[op].volume:=MAX_ATT_INDEX;
									          self.ch[ch].slot[op].state:=EG_OFF;
								          end;
							          end;
						          end;
					          end else begin // percussive mode 
						          if ((self.eg_cnt and ((1 shl self.ch[ch].slot[op].eg_sh_rs)-1))=0) then begin
							          self.ch[ch].slot[op].volume:=self.ch[ch].slot[op].volume+eg_inc[self.ch[ch].slot[op].eg_sel_rs+((self.eg_cnt shr self.ch[ch].slot[op].eg_sh_rs) and 7)];
							          if (self.ch[ch].slot[op].volume>=MAX_ATT_INDEX) then begin
								          self.ch[ch].slot[op].volume:=MAX_ATT_INDEX;
								          self.ch[ch].slot[op].state:=EG_OFF;
							          end;
						          end;
					          end;
				          end;// primer if
			         end;
			end; //Del case
		end; //Del for
	end; //Del while!
	for i:=0 to 17 do begin
		ch:=i div 2;
		op:=i and 1;
		// Phase Generator 
		if(self.ch[ch].slot[op].vib<>0) then begin
			fnum_lfo:=8*((self.ch[ch].block_fnum and $1c0) shr 6);
			block_fnum:=self.ch[ch].block_fnum*2;
			lfo_fn_table_index_offset:=lfo_pm_table[self.LFO_PM+fnum_lfo];
			if (lfo_fn_table_index_offset<>0) then begin  // LFO phase modulation active 
				block_fnum:=block_fnum+lfo_fn_table_index_offset;
				block:=(block_fnum and $1c00) shr 10;
				self.ch[ch].slot[op].phase:=self.ch[ch].slot[op].phase+((fn_tab[block_fnum and $3ff] shr (7-block))*self.ch[ch].slot[op].mul);
			end	else begin   // LFO phase modulation  = zero 
				self.ch[ch].slot[op].phase:=self.ch[ch].slot[op].phase+self.ch[ch].slot[op].freq;
			end;
		end else begin // LFO phase modulation disabled for this operator 
			self.ch[ch].slot[op].phase:=self.ch[ch].slot[op].phase+self.ch[ch].slot[op].freq;
		end;
	end; //Del for
	{  The Noise Generator of the YM3812 is 23-bit shift register.
	   Period is equal to 2^23-2 samples.
	   Register works at sampling frequency of the chip, so output
	   can change on every sample.
	
	   Output of the register and input to the bit 22 is:
	   bit0 XOR bit14 XOR bit15 XOR bit22
	
	   Simply use bit 22 as the noise output.}
	self.noise_p:=self.noise_p+self.noise_f;
	i:=self.noise_p shr FREQ_SH;       // number of events (shifts of the shift register) 
	self.noise_p:=self.noise_p and FREQ_MASK;
	while (i<>0) do begin
		{
		uint32_t j;
		j = ( (noise_rng) ^ (noise_rng>>14) ^ (noise_rng>>15) ^ (noise_rng>>22) ) & 1;
		noise_rng = (j<<22) | (noise_rng>>1);
		*/

		/*
		    Instead of doing all the logic operations above, we
		    use a trick here (and use bit 0 as the noise output).
		    The difference is only that the noise bit changes one
		    step ahead. This doesn't matter since we don't know
		    what is real state of the noise_rng after the reset.}
		if (self.noise_rng and 1)<>0 then self.noise_rng:=self.noise_rng xor $800302;
		self.noise_rng:=self.noise_rng shr 1;
		i:=i-1;
	end; //Del while
end;

// update phase increment counter of operator (also update the EG rates if necessary) 
procedure ym2413_chip.calc_fcslot(ch_m,slot_m:byte);
var
	ksr:integer;
	SLOT_rs:dword;
	SLOT_dp:dword;
begin
	// (frequency) phase increment counter 
	self.ch[ch_m].slot[slot_m].freq:=self.ch[ch_m].fc*self.ch[ch_m].slot[slot_m].mul;
	ksr:=self.ch[ch_m].kcode shr self.ch[ch_m].slot[slot_m].KSR_m;
	if (self.ch[ch_m].slot[slot_m].ksr<>ksr) then begin
		self.ch[ch_m].slot[slot_m].ksr:=ksr;
		// calculate envelope generator rates 
		if ((self.ch[ch_m].slot[slot_m].ar+self.ch[ch_m].slot[slot_m].ksr)<(16+62)) then begin
			self.ch[ch_m].slot[slot_m].eg_sh_ar :=eg_rate_shift [self.ch[ch_m].slot[slot_m].ar+self.ch[ch_m].slot[slot_m].ksr];
			self.ch[ch_m].slot[slot_m].eg_sel_ar:=eg_rate_select[self.ch[ch_m].slot[slot_m].ar+self.ch[ch_m].slot[slot_m].ksr];
		end else begin
			self.ch[ch_m].slot[slot_m].eg_sh_ar:=0;
			self.ch[ch_m].slot[slot_m].eg_sel_ar:=13*RATE_STEPS;
		end;
		self.ch[ch_m].slot[slot_m].eg_sh_dr :=eg_rate_shift [self.ch[ch_m].slot[slot_m].dr+self.ch[ch_m].slot[slot_m].ksr];
		self.ch[ch_m].slot[slot_m].eg_sel_dr:=eg_rate_select[self.ch[ch_m].slot[slot_m].dr+self.ch[ch_m].slot[slot_m].ksr];
		self.ch[ch_m].slot[slot_m].eg_sh_rr :=eg_rate_shift [self.ch[ch_m].slot[slot_m].rr+self.ch[ch_m].slot[slot_m].ksr];
		self.ch[ch_m].slot[slot_m].eg_sel_rr:=eg_rate_select[self.ch[ch_m].slot[slot_m].rr+self.ch[ch_m].slot[slot_m].ksr];
	end;
	if (self.ch[ch_m].sus<>0) then SLOT_rs:=16+(5 shl 2)
	  else SLOT_rs:=16+(7 shl 2);
	self.ch[ch_m].slot[slot_m].eg_sh_rs:=eg_rate_shift [SLOT_rs+self.ch[ch_m].slot[slot_m].ksr];
	self.ch[ch_m].slot[slot_m].eg_sel_rs:=eg_rate_select[SLOT_rs+self.ch[ch_m].slot[slot_m].ksr];
	SLOT_dp:=16+(13 shl 2);
	self.ch[ch_m].slot[slot_m].eg_sh_dp:= eg_rate_shift[SLOT_dp+self.ch[ch_m].slot[slot_m].ksr];
	self.ch[ch_m].slot[slot_m].eg_sel_dp:= eg_rate_select[SLOT_dp+self.ch[ch_m].slot[slot_m].ksr];
end;

// set multi,am,vib,EG-TYP,KSR,mul 
procedure ym2413_chip.set_mul(slot,v:byte);
var
  ch_m:byte;
  slot_m:byte;
begin
  ch_m:=slot div 2;
  slot_m:=slot and 1;
  self.ch[ch_m].slot[slot_m].mul:=mul_tab[v and $f];
  if (v and $10)<>0 then self.ch[ch_m].slot[slot_m].KSR_m:=0
    else self.ch[ch_m].slot[slot_m].KSR_m:=2;
	self.ch[ch_m].slot[slot_m].eg_type:=v and $20;
	self.ch[ch_m].slot[slot_m].vib:=v and $40;
  if (v and $80)<>0 then self.ch[ch_m].slot[slot_m].AMmask:=$ffffffff
    else self.ch[ch_m].slot[slot_m].AMmask:=0;
	calc_fcslot(ch_m,slot_m);
end;

// set ksl, tl 
procedure ym2413_chip.set_ksl_tl(chan,v:byte);
begin
	self.ch[chan].slot[SLOT1].ksl:=ksl_shift[v shr 6];
	self.ch[chan].slot[SLOT1].TL := (v and $3f) shl (ENV_BITS-2-7); // 7 bits TL (bit 6 = always 0) 
	self.ch[chan].slot[SLOT1].TLL:=self.ch[chan].slot[SLOT1].TL+(self.ch[chan].ksl_base shr self.ch[chan].slot[SLOT1].ksl);
end;

// set ksl , waveforms, feedback 
procedure ym2413_chip.set_ksl_wave_fb(chan,v:byte);
begin
	self.ch[chan].slot[SLOT1].wavetable:=((v and 8) shr 3)*SIN_LEN;
  if (v and 7)<>0 then self.ch[chan].slot[SLOT1].fb_shift:=(v and 7)+8
    else self.ch[chan].slot[SLOT1].fb_shift:=0;
  //carrier
	self.ch[chan].slot[SLOT2].ksl:=ksl_shift[v shr 6];
	self.ch[chan].slot[SLOT2].TLL:=self.ch[chan].slot[SLOT2].TL+(self.ch[chan].ksl_base shr self.ch[chan].slot[SLOT2].ksl);
	self.ch[chan].slot[SLOT2].wavetable:=((v and $10) shr 4)*SIN_LEN;
end;

// set attack rate & decay rate  
procedure ym2413_chip.set_ar_dr(slot,v:byte);
var
  slot_m:byte;
  ch_m:byte;
begin
  ch_m:=slot div 2;
	slot_m:=slot and 1;
  if (v shr 4)<>0 then self.ch[ch_m].slot[slot_m].ar:=16+((v shr 4) shl 2)
    else self.ch[ch_m].slot[slot_m].ar:=0;
	if ((self.ch[ch_m].slot[slot_m].ar+self.ch[ch_m].slot[slot_m].ksr)<(16+62)) then begin
		self.ch[ch_m].slot[slot_m].eg_sh_ar :=eg_rate_shift [self.ch[ch_m].slot[slot_m].ar+self.ch[ch_m].slot[slot_m].ksr];
		self.ch[ch_m].slot[slot_m].eg_sel_ar:=eg_rate_select[self.ch[ch_m].slot[slot_m].ar+self.ch[ch_m].slot[slot_m].ksr];
	end else begin
		self.ch[ch_m].slot[slot_m].eg_sh_ar:=0;
		self.ch[ch_m].slot[slot_m].eg_sel_ar:=13*RATE_STEPS;
	end;
  if (v and $f)<>0 then self.ch[ch_m].slot[slot_m].dr:=16+((v and $f) shl 2)
    else self.ch[ch_m].slot[slot_m].dr:=0;
	self.ch[ch_m].slot[slot_m].eg_sh_dr:=eg_rate_shift[self.ch[ch_m].slot[slot_m].dr+self.ch[ch_m].slot[slot_m].ksr];
	self.ch[ch_m].slot[slot_m].eg_sel_dr:=eg_rate_select[self.ch[ch_m].slot[slot_m].dr+self.ch[ch_m].slot[slot_m].ksr];
end;

// set sustain level & release rate 
procedure ym2413_chip.set_sl_rr(slot,v:byte);
var
  ch_m:byte;
  slot_m:byte;
begin
	ch_m:=slot div 2;
	slot_m:=slot and 1;
	self.ch[ch_m].slot[slot_m].sl:=sl_tab[v shr 4];
  if (v and $f)<>0 then self.ch[ch_m].slot[slot_m].rr:=16+((v and $f) shr 2)
    else self.ch[ch_m].slot[slot_m].rr:=0;
	self.ch[ch_m].slot[slot_m].eg_sh_rr :=eg_rate_shift [self.ch[ch_m].slot[slot_m].rr+self.ch[ch_m].slot[slot_m].ksr];
	self.ch[ch_m].slot[slot_m].eg_sel_rr:=eg_rate_select[self.ch[ch_m].slot[slot_m].rr+self.ch[ch_m].slot[slot_m].ksr];
end;

procedure ym2413_chip.load_instrument(chan,slot:byte;inst:pbyte);
begin
	self.set_mul         (slot,   inst[0]);
	self.set_mul         (slot+1, inst[1]);
	self.set_ksl_tl      (chan,   inst[2]);
	self.set_ksl_wave_fb (chan,   inst[3]);
	self.set_ar_dr       (slot,   inst[4]);
	self.set_ar_dr       (slot+1, inst[5]);
	self.set_sl_rr       (slot,   inst[6]);
	self.set_sl_rr       (slot+1, inst[7]);
end;

procedure ym2413_chip.key_on(slot,chan:byte;key_set:dword);
begin
	if (self.ch[chan].slot[slot].key=0) then begin
		// do NOT restart Phase Generator (verified on real YM2413)
		// phase -> Dump 
		self.ch[chan].slot[slot].state:=EG_DMP;
	end;
	self.ch[chan].slot[slot].key:=self.ch[chan].slot[slot].key or key_set;
end;

procedure ym2413_chip.key_off(slot,chan:byte;key_clr:dword);
begin
	if (self.ch[chan].slot[slot].key<>0) then begin
		self.ch[chan].slot[slot].key:=self.ch[chan].slot[slot].key and key_clr;
		if (self.ch[chan].slot[slot].key=0) then begin
			// phase -> Release 
			if (self.ch[chan].slot[slot].state>EG_REL) then self.ch[chan].slot[slot].state:=EG_REL;
		end;
	end;
end;

procedure ym2413_chip.update_instrument_zero(r:byte);
var
  inst:pbyte;
  chan,chan_max:dword;
begin
  inst:=@inst_tab[0,0]; // point to user instrument 
	chan_max:=9;
	if (self.rhythm and $20)<>0 then chan_max:=6;
	case r of 
	  0:for chan:=0 to (chan_max-1) do
			  if ((instvol_r[chan] and $f0)=0) then set_mul(chan*2,inst[0]);
	  1:for chan:=0 to (chan_max-1) do
			  if ((instvol_r[chan] and $f0)=0) then set_mul(chan*2+1,inst[1]);
	  2:for chan:=0 to (chan_max-1) do
			  if ((instvol_r[chan] and $f0)=0) then set_ksl_tl(chan,inst[2]);
	  3:for chan:=0 to (chan_max-1) do
			  if ((instvol_r[chan] and $f0)=0) then set_ksl_wave_fb(chan,inst[3]);
	  4:for chan:=0 to (chan_max-1) do
			  if ((instvol_r[chan] and $f0)=0) then set_ar_dr(chan*2,inst[4]);
	  5:for chan:=0 to (chan_max-1) do
			  if ((instvol_r[chan] and $f0)=0) then set_ar_dr(chan*2+1,inst[5]);
	  6:for chan:=0 to (chan_max-1) do
			  if ((instvol_r[chan] and $f0)=0) then set_sl_rr(chan*2,inst[6]);
	  7:for chan:=0 to (chan_max-1) do
			  if ((instvol_r[chan] and $f0)=0) then set_sl_rr(chan*2+1,inst[7]);
  end;
end;

procedure ym2413_chip.address(valor:byte);
begin
  self.addrs:=valor;
end;

procedure ym2413_chip.write(valor:byte);
begin
  self.write_int(self.addrs,valor);
end;

procedure ym2413_chip.write_int(reg,valor:byte);
var
  chan,slot:byte;
  block:byte;
  old_instvol:byte;
  inst:pbyte;
  block_fnum:dword;
begin
case (reg and $f0) of
	0:begin  // 00-0f:control 
		  case (reg and $f) of 
		    0,  // AM/VIB/EGTYP/KSR/MULTI (modulator) 
		    1,  // AM/VIB/EGTYP/KSR/MULTI (carrier) 
		    2,  // Key Scale Level, Total Level (modulator) 
		    3,  // Key Scale Level, carrier waveform, modulator waveform, Feedback 
		    4,  // Attack, Decay (modulator) 
		    5,  // Attack, Decay (carrier)
		    6,  // Sustain, Release (modulator) 
		    7:begin  // Sustain, Release (carrier) 
			      self.inst_tab[0,reg and $7]:=valor;
			      update_instrument_zero(reg and 7);
          end;
        $e:begin  // x, x, r,bd,sd,tom,tc,hh 
			      if(valor and $20)<>0 then begin
				      if ((self.rhythm and $20)=0) then begin
				        //rhythm off to on
	              // Load instrument settings for channel seven(chan=6 since we're zero based). (Bass drum) */
					      chan:=6;
					      inst:=@inst_tab[16,0];
					      slot:=chan*2;
					      load_instrument(chan, slot, inst);
	              // Load instrument settings for channel eight. (High hat and snare drum) 
					      chan:=7;
					      inst:=@inst_tab[17,0];
					      slot:=chan*2;
					      load_instrument(chan, slot, inst);
					      self.ch[chan].slot[SLOT1].TL:=((instvol_r[chan] shr 4) shl 2) shl (ENV_BITS-2-7); // 7 bits TL (bit 6 = always 0) 
					      self.ch[chan].slot[SLOT1].TLL:=self.ch[chan].slot[SLOT1].TL+(self.ch[chan].ksl_base shr self.ch[chan].slot[SLOT1].ksl);
	              // Load instrument settings for channel nine. (Tom-tom and top cymbal) 
					      chan:=8;
					      inst:=@inst_tab[18,0];
					      slot:=chan*2;
					      load_instrument(chan, slot, inst);
					      self.ch[chan].slot[SLOT1].TL:=((instvol_r[chan] shr 4) shl 2) shl (ENV_BITS-2-7); // 7 bits TL (bit 6 = always 0) 
					      self.ch[chan].slot[SLOT1].TLL:=self.ch[chan].slot[SLOT1].TL+(self.ch[chan].ksl_base shr self.ch[chan].slot[SLOT1].ksl);
				      end;
				      // BD key on/off 
				      if (valor and $10)<>0 then begin
					      key_on(SLOT1,6,2);
					      key_on(SLOT2,6,2);
              end else begin
					      key_off(SLOT1,6,$fffffffd);
					      key_off(SLOT2,6,$fffffffd);
				      end;
				      // HH key on/off 
				      if (valor and 1)<>0 then key_on(SLOT1,7,2)
				        else key_off(SLOT1,7,$fffffffd);
				      // SD key on/off 
				      if (valor and 8)<>0 then key_on(SLOT2,7,2)
				        else  key_off(SLOT2,7,$fffffffd);
				      // TOM key on/off 
				      if (valor and 4)<>0 then key_on(SLOT1,8,2)
				        else key_off(SLOT1,8,$fffffffd);
				      // TOP-CY key on/off 
				      if (valor and 2)<>0 then key_on(SLOT2,8,2)
				        else key_off(SLOT2,8,$fffffffd);
			      end else begin
              if (self.rhythm and $20)<>0 then begin
				        //rhythm on to off
	              // Load instrument settings for channel seven(chan=6 since we're zero based).
					      chan:=6;
					      inst:=@inst_tab[instvol_r[chan] shr 4,0];
					      slot:=chan*2;
					      load_instrument(chan,slot,inst);
	              // Load instrument settings for channel eight.
					      chan:=7;
					      inst:=@inst_tab[instvol_r[chan] shr 4,0];
					      slot:=chan*2;
					      load_instrument(chan,slot,inst);
	              // Load instrument settings for channel nine.
					      chan:=8;
					      inst:=@inst_tab[instvol_r[chan] shr 4,0];
					      slot:=chan*2;
					      load_instrument(chan,slot,inst);
				      end;
				      // BD key off 
				      key_off(SLOT1,6,$fffffffd);
				      key_off(SLOT2,6,$fffffffd);
				      // HH key off 
				      key_off(SLOT1,7,$fffffffd);
				      // SD key off 
				      key_off(SLOT2,7,$fffffffd);
				      // TOM key off 
				      key_off(SLOT1,8,$fffffffd);
				      // TOP-CY off 
				      key_off(SLOT2,8,$fffffffd);
			      end;
			    self.rhythm:=valor and $3f;
		      end;
      end;     
    end;
	$10,$20:begin
		        chan:=reg and $f;
		        if (chan>=9) then chan:=chan-9;  // verified on real YM2413 
		        if (reg and $10)<>0 then begin
              // 10-18: FNUM 0-7 
			        block_fnum:=(self.ch[chan].block_fnum and $f00) or valor;
            end else begin // 20-28: suson, keyon, block, FNUM 8 
			        block_fnum:=((valor and $f) shl 8) or (self.ch[chan].block_fnum and $ff);
			        if (valor and $10)<>0 then begin
				        key_on(SLOT1,chan,1);
				        key_on(SLOT2,chan,1);
			        end else begin
				        key_off(SLOT1,chan,$fffffffe);
				        key_off(SLOT2,chan,$fffffffe);
			        end;                         
              self.ch[chan].sus:=valor and $20;
		        end;
		        // update 
		        if(self.ch[chan].block_fnum<>block_fnum) then begin
			        self.ch[chan].block_fnum:=block_fnum;
			        // BLK 2,1,0 bits -> bits 3,2,1 of kcode, FNUM MSB -> kcode LSB 
			        self.ch[chan].kcode:=(block_fnum and $f00) shr 8;
			        self.ch[chan].ksl_base:=trunc(ksl_tab[block_fnum shr 5]);
			        block_fnum  :=block_fnum*2;
			        block       :=(block_fnum and $1c00) shr 10;
			        self.ch[chan].fc:=fn_tab[block_fnum and $3ff] shr (7-block);
              // refresh Total Level in both SLOTs of this channel 
			        self.ch[chan].SLOT[SLOT1].TLL:=self.ch[chan].SLOT[SLOT1].TL+(self.ch[chan].ksl_base shr self.ch[chan].SLOT[SLOT1].ksl);
			        self.ch[chan].SLOT[SLOT2].TLL:=self.ch[chan].SLOT[SLOT2].TL+(self.ch[chan].ksl_base shr self.ch[chan].SLOT[SLOT2].ksl);
			        //refresh frequency counter in both SLOTs of this channel */
			        calc_fcslot(chan,SLOT1);
			        calc_fcslot(chan,SLOT2);
		        end;
          end;
	$30:begin  // inst 4 MSBs, VOL 4 LSBs 
		    chan:=reg and $f;
		    if (chan>=9) then chan:=chan-9;  // verified on real YM2413 
		    old_instvol:=instvol_r[chan];
		    instvol_r[chan]:=valor;  // store for later use 
		    self.ch[chan].SLOT[SLOT2].TL:=((valor and $f) shl 2) shl (ENV_BITS-2-7); // 7 bits TL (bit 6 = always 0)
		    self.ch[chan].SLOT[SLOT2].TLL:=self.ch[chan].SLOT[SLOT2].TL+(self.ch[chan].ksl_base shr self.ch[chan].SLOT[SLOT2].ksl);
		    //check whether we are in rhythm mode and handle instrument/volume register accordingly
		    if ((chan>=6) and ((rhythm and $20)<>0)) then begin
			    // we're in rhythm mode
			    if (chan>=7) then begin // only for channel 7 and 8 (channel 6 is handled in usual way)
				    self.ch[chan].SLOT[SLOT1].TL:=((instvol_r[chan] shr 4) shl 2) shl (ENV_BITS-2-7); // 7 bits TL (bit 6 = always 0) 
				    self.ch[chan].SLOT[SLOT1].TLL:=self.ch[chan].SLOT[SLOT1].TL+(self.ch[chan].ksl_base shr self.ch[chan].SLOT[SLOT1].ksl);
          end;
		    end else begin
			    if ((old_instvol and $f0)=(valor and $f0)) then exit;
			    inst:=@inst_tab[instvol_r[chan] shr 4,0];
			    slot:=chan*2;
			    load_instrument(chan,slot,inst);
		    end;
      end;
end;
end;

procedure ym2413_chip.update;
var
  j:byte;
begin
  self.output[0]:=0;
	self.output[1]:=0;
  self.advance_lfo;
	// FM part 
  for j:=0 to 5 do self.chan_calc(j);
  if ((self.rhythm and $20)=0) then begin
			for j:=6 to 8 do self.chan_calc(j);
  end else begin // Rhythm part 
			self.rhythm_calc(0,noise_rng and 1);
  end;
  if self.output[0]>32767 then self.output[0]:=32767
    else if self.output[0]<-32768 then self.output[0]:=-32768;
  if self.output[1]>32767 then self.output[1]:=32767
    else if self.output[1]<-32768 then self.output[1]:=-32768;
  if sound_status.stereo then begin
    tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc(self.output[0]*self.amp);
    tsample[self.tsample_num,sound_status.posicion_sonido+1]:=trunc(self.output[1]*self.amp);
  end else tsample[self.tsample_num,sound_status.posicion_sonido]:=trunc((self.output[0]+self.output[1])*self.amp);
  self.advance;
end;

end.
