unit fmopn;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     math;

type
  type_IRQ_Handler=procedure (irqstate:byte);
  type_Timer_set_Handler=procedure(counter:single);
  //FMSLOT3
  fm_3slot=record
    	fc:array[0..2] of dword;			// fnum3,blk3: calculated */
	    fn_h:byte;			// freq3 latch */
	    kcode:array[0..2] of byte;		// key code */
	    block_fnum:array[0..2] of dword;	// current fnum value for this slot (can be different betweeen slots of one channel in 3slot mode) */
  end;
  pfm_3slot=^fm_3slot;
//FMSTATE
  fm_state=record
	  clock:integer;		// master clock  (Hz)   */
	  rate:integer;		// sampling rate (Hz)   */
	  freqbase:single;	// frequency base       */
	  timer_prescaler:integer;	// Timer base time      */
	  address:byte;	// address register     */
	  irq:byte;		// interrupt level      */
	  irqmask:byte;	// irq mask             */
	  status:byte;		// status flag          */
	  mode:integer;		// mode  CSM / 3SLOT    */
	  prescaler_sel:byte; // prescaler selector */
	  fn_h:byte;		// freq latch           */
	  TA:integer;			// timer a              */
	  TAC:single;		// timer a counter      */
	  TB:integer;			// timer b              */
	  TBC:single;		// timer b counter      */
	  // local time tables */
	  dt_tab:array [0..7,0..31] of integer; // DeTune tables */
	  IRQ_Handler:type_IRQ_Handler;
    TIMER_set_a,TIMER_set_b:type_Timer_set_handler;
  end;
  pfm_state=^fm_state;

//FMSLOT
  fm_slot=record
    det_mul_val:byte;
    DT:pinteger;		// detune          :dt_tab[DT] */
    KSR_m:byte;		// key scale rate  :3-KSR */
	  ar:dword;			// attack rate  */
	  d1r:dword;		// decay rate   */
	  d2r:dword;		// sustain rate */
	  rr:dword;			// release rate */
	  ksr:byte;		// key scale rate  :kcode>>(3-KSR) */
	  mul:dword;		// multiple        :ML_TABLE[ML] */

	  // Phase Generator */
	  phase:dword;		// phase counter */
	  Incr:integer;		// phase step */

	  // Envelope Generator */
	  state:byte;		// phase type */
	  tl:dword;			// total level: TL << 3 */
	  volume:integer;		// envelope counter */
	  sl:dword;			// sustain level:sl_table[SL] */
	  vol_out:integer;	// current output from EG circuit (without AM from LFO) */

	  eg_sh_ar:byte;	//  (attack state) */
	  eg_sel_ar:byte;	//  (attack state) */
	  eg_sh_d1r:byte;	//  (decay state) */
	  eg_sel_d1r:byte;	//  (decay state) */
	  eg_sh_d2r:byte;	//  (sustain state) */
	  eg_sel_d2r:byte;	//  (sustain state) */
	  eg_sh_rr:byte;	// (release state) */
	  eg_sel_rr:byte;	//  (release state) */

	  ssg:byte;		// SSG-EG waveform */
	  ssgn:byte;		// SSG-EG negated output */

	  key:dword;		// 0=last key was KEY OFF, 1=KEY ON */
end;
  pfm_slot=^fm_slot;
//FMCHAN
  fm_chan=record
    SLOT:array[0..3] of pFM_Slot;
	  ALGO:byte;		// algorithm */
	  FB:byte;			// feedback shift */
	  op1_out:array[0..1] of integer;	// op1 output for feedback */
	  connect1:pinteger;	// SLOT1 output pointer */
	  connect3:pinteger;	// SLOT3 output pointer */
	  connect2:pinteger;	// SLOT2 output pointer */
    connect4:pinteger;	// SLOT4 output pointer */
	  mem_connect:pinteger;// where to put the delayed sample (MEM) */
	  mem_value:integer;	// delayed sample (MEM) value */
	  pms:integer;		// channel PMS */
	  ams:byte;		// channel AMS */
	  fc:dword;			// fnum,blk:adjusted to sample rate */
	  kcode:byte;		// key code:                        */
	  block_fnum:dword;	// current blk/fnum value for this slot (can be different betweeen slots of one channel in 3slot mode) */
  end;
  pfm_chan=^fm_chan;
//OPN
  fm_opn=record
    type_:byte; // chip type */
	  ST:pFM_state; // general state */
	  SL3:pFM_3Slot; // 3 slot mode state */
    P_CH:array[0..7] of pfm_chan; // pointer of CH */
	  pan:array[0..(6*2)-1] of dword;	// fm channels output masks (0xffffffff = enable) */
	  eg_cnt:dword;			// global envelope generator counter */
	  eg_timer:single;		// global envelope generator counter works at frequency = chipclock/64/3 */
	  eg_timer_add:single;	// step of eg_timer */
	  eg_timer_overflow:dword;// envelope generator timer overlfows every 3 samples (on real chip) */
	  // there are 2048 FNUMs that can be generated using FNUM/BLK registers
    //      but LFO works with one more bit of a precision so we really need 4096 elements */
    fn_table:array[0..4095] of dword;	// fnumber->increment counter */
    fn_max:dword;
  	// LFO */
	  lfo_cnt:dword;
	  lfo_inc:dword;
	  lfo_freq:array[0..7] of dword;	// LFO FREQ table */
    m2,c1,c2:integer;		// Phase Modulation input for operators 2,3,4 */
    mem:integer;			// one sample delay memory */
  end;
  pfm_opn=^fm_opn;

const
  CLEAR_LINE=0;
  ASSERT_LINE=1;
  //FMCONST
  M_PI=3.1415926535;
  // some globals */
  TYPE_SSG=$01;    // SSG support
  TYPE_OPN=$02;    // OPN device
  TYPE_LFOPAN=$04;    // OPN type LFO and PAN
  TYPE_6CH=$08;    // FM 6CH / 3CH
  TYPE_DAC=$10;    // YM2612's DAC device
  TYPE_ADPCM=$20;    // two ADPCM unit

  TYPE_YM2203=TYPE_SSG;
  // slot number */
  SLOT1=0;
  SLOT2=2;
  SLOT3=1;
  SLOT4=3;
  // sinwave entries */
	// used static memory = SIN_ENT * 4 (byte) */
  SIN_BITS=10;
  SIN_LEN=1 shl SIN_BITS;
  SIN_MASK=SIN_LEN-1;

  TL_RES_LEN=256;
  TL_TAB_LEN=13*2*TL_RES_LEN;

  ENV_QUIET=TL_TAB_LEN shr 3;

	// output level entries (envelope,sinwave) */
	// envelope counter lower bits */
	ENV_BITS = 10;
  ENV_LEN=1 shl ENV_BITS;
  ENV_STEP=128.0/ENV_LEN;

  MAX_ATT_INDEX=(ENV_LEN-1); // 1023 */
  MIN_ATT_INDEX=(0);			// 0 */

  FINAL_SH=0;

	//envelope output entries */
	EG_ATT=4;
  EG_DEC=3;
  EG_SUS=2;
  EG_REL=1;
  EG_OFF=0;

  FREQ_SH=16;  // 16.16 fixed point (frequency calculations) */
  EG_SH=16;  // 16.16 fixed point (envelope generator timing) */
  LFO_SH=24;  //  8.24 fixed point (LFO calculations)       */
  TIMER_SH=16;  // 16.16 fixed point (timers calculations)    */

  FREQ_MASK=((1 shl FREQ_SH)-1);

  RATE_STEPS=8;

  //FMOPN
  freq_table:array[0..7] of single=(3.98, 5.56, 6.02, 6.37, 6.88, 9.63, 48.1, 72.2);

  //note that there is no O(17) in this table - it's directly in the code */
  eg_rate_select_init:array[0..(32+64+32)-1] of byte=(	// Envelope Generator rates (32 + 64 rates + 32 RKS) */
    // 32 infinite time rates */
    18,18,18,18,18,18,18,18,
    18,18,18,18,18,18,18,18,
    18,18,18,18,18,18,18,18,
    18,18,18,18,18,18,18,18,

    // rates 00-11 */
    //Nuevo 29/08/08 0,1,2,3, 0,1,2,3,
    18,18,0,0,
    0,0,2,2,

    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,
    0,1,2,3,

    // rate 12 */
    4,5,6,7,

    // rate 13 */
    8,9,10,11,

    // rate 14 */
    12,13,14,15,

    // rate 15 */
    16,16,16,16,

    // 32 dummy rates (same as 15 3) */
    16,16,16,16,16,16,16,16,
    16,16,16,16,16,16,16,16,
    16,16,16,16,16,16,16,16,
    16,16,16,16,16,16,16,16
);

	OPN_FKTABLE:array[0..15] of byte=(0,0,0,0,0,0,0,1,2,3,3,3,3,3,3,3);
	dt_tab:array[0..127] of byte=(
			// this table is YM2151 and YM2612 data */
			// FD=0 */
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
			// FD=1 */
			0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2,
			2, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7, 8, 8, 8, 8,
			// FD=2 */
			1, 1, 1, 1, 2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5,
			5, 6, 6, 7, 8, 8, 9,10,11,12,13,14,16,16,16,16,
			// FD=3 */
			2, 2, 2, 2, 2, 3, 3, 3, 4, 4, 4, 5, 5, 6, 6, 7,
			8 , 8, 9,10,11,12,13,14,16,17,19,20,22,22,22,22
	);
  eg_rate_shift:array[0..(32+64+32)-1] of byte=(	// Envelope Generator counter shifts (32 + 64 rates + 32 RKS) */
      // 32 infinite time rates */
      0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,

      // rates 00-11 */
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
      0,0,0,0,

      // rate 12 */
      0,0,0,0,

      // rate 13 */
      0,0,0,0,

      // rate 14 */
      0,0,0,0,

      // rate 15 */
      0,0,0,0,

      // 32 dummy rates (same as 15 3) */
      0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0,
      0,0,0,0,0,0,0,0
      );

      eg_inc:array[0..(19*RATE_STEPS)-1] of byte=(

//cycle:0 1  2 3  4 5  6 7*/

{ 0 } 0,1, 0,1, 0,1, 0,1, // rates 00..11 0 (increment by 0 or 1) */
{ 1 } 0,1, 0,1, 1,1, 0,1, // rates 00..11 1 */
{ 2 } 0,1, 1,1, 0,1, 1,1, // rates 00..11 2 */
{ 3 } 0,1, 1,1, 1,1, 1,1, // rates 00..11 3 */

{ 4 } 1,1, 1,1, 1,1, 1,1, // rate 12 0 (increment by 1) */
{ 5 } 1,1, 1,2, 1,1, 1,2, // rate 12 1 */
{ 6 } 1,2, 1,2, 1,2, 1,2, // rate 12 2 */
{ 7 } 1,2, 2,2, 1,2, 2,2, // rate 12 3 */

{ 8 } 2,2, 2,2, 2,2, 2,2, // rate 13 0 (increment by 2) */
{ 9 } 2,2, 2,4, 2,2, 2,4, // rate 13 1 */
{10 } 2,4, 2,4, 2,4, 2,4, // rate 13 2 */
{11 } 2,4, 4,4, 2,4, 4,4, // rate 13 3 */

{12 } 4,4, 4,4, 4,4, 4,4, // rate 14 0 (increment by 4) */
{13 } 4,4, 4,8, 4,4, 4,8, // rate 14 1 */
{14 } 4,8, 4,8, 4,8, 4,8, // rate 14 2 */
{15 } 4,8, 8,8, 4,8, 8,8, // rate 14 3 */

{16 } 8,8, 8,8, 8,8, 8,8, // rates 15 0, 15 1, 15 2, 15 3 (increment by 8) */
{17 } 16,16,16,16,16,16,16,16, // rates 15 2, 15 3 for attack */
{18 } 0,0, 0,0, 0,0, 0,0 // infinity rates for attack and decay(s) */
);

var
  eg_rate_select:array[0..(32+64+32)-1] of byte;
  sl_table:array[0..15] of dword;
  SIN_TAB:array[0..SIN_LEN-1] of integer;
  TL_TAB:array[0..TL_TAB_LEN-1] of integer;
  out_fm:array[0..7] of integer;
  LFO_AM,LFO_PM:integer;
  fn_max:integer;

procedure OPNWriteMode(OPN:pfm_opn;r,v:integer);
procedure OPNWriteReg(OPN:pfm_opn;r,v:integer);
procedure OPNPrescaler_w(OPN:pfm_opn;addr,pre_divider:integer);
procedure advance_eg_channel(OPN:pfm_opn;CH:pfm_chan);
function opn_init(chan:byte):pfm_opn;
procedure opn_close(OPN:pfm_opn);
procedure FMInitTable;
//STATE
procedure FM_IRQMASK_SET(ST:pfm_state;flag:integer);
procedure FM_STATUS_RESET(ST:pfm_state;flag:integer);
procedure INTERNAL_TIMER_B(ST:pfm_state;step:integer);
procedure INTERNAL_TIMER_A(ST:pfm_state;CH:pFM_Chan);
procedure TimerAOver(ST:pfm_state);
procedure TimerBOver(ST:pfm_state);
procedure CSMKeyControll(tipo:byte;CH:pfm_chan);
//CHANNEL
procedure refresh_fc_eg_chan(OPN:pfm_opn;CH:pfm_chan);
procedure CHAN_Calc(OPN:pfm_opn;CH:pfm_chan;chnum:byte);
procedure setup_connection(OPN:pfm_opn;CH:pfm_chan;num:integer);
//SLOT
procedure refresh_fc_eg_slot(OPN:pfm_opn;SLOT:pfm_slot;fc,kc:integer);

implementation

//FMSLOT
// update phase increment and envelope generator */
procedure refresh_fc_eg_slot(OPN:pfm_opn;SLOT:pfm_slot;fc,kc:integer);
var
	ksr:integer;
  pos:pinteger;
begin
  {Nuevo 04/08/09}
  ksr:=kc shr SLOT.KSR_m;
  //fc += SLOT->DT[kc];
  pos:=SLOT.DT;
  inc(pos,kc);
	fc:=fc+pos^;
	// detects frequency overflow (credits to Nemesis) */
	if (fc<0) then fc:=fc+OPN.fn_max;
	// (frequency) phase increment counter */
	SLOT.Incr:=(fc*SLOT.mul) shr 1;
	if (SLOT.ksr<>ksr) then begin
		SLOT.ksr:=ksr;
		// calculate envelope generator rates */
		if ((SLOT.ar+SLOT.ksr)<(32+62)) then begin
			SLOT.eg_sh_ar:=eg_rate_shift[SLOT.ar+SLOT.ksr ];
			SLOT.eg_sel_ar:=eg_rate_select[SLOT.ar+SLOT.ksr ];
		end else begin
			SLOT.eg_sh_ar:=0;
			SLOT.eg_sel_ar:=17*RATE_STEPS;
		end;
    SLOT.eg_sh_d1r:= eg_rate_shift [SLOT.d1r + SLOT.ksr];
		SLOT.eg_sh_d2r:= eg_rate_shift [SLOT.d2r + SLOT.ksr];
		SLOT.eg_sh_rr:= eg_rate_shift [SLOT.rr  + SLOT.ksr];
    SLOT.eg_sel_d1r:= eg_rate_select[SLOT.d1r + SLOT.ksr];
    SLOT.eg_sel_d2r:= eg_rate_select[SLOT.d2r + SLOT.ksr];
    SLOT.eg_sel_rr:= eg_rate_select[SLOT.rr  + SLOT.ksr];
	end;
end;

//FMCHAN
function op_calc(phase:dword;env:word;pm:integer):integer;inline;
var
  tmp:integer;
  p:dword;
begin
  tmp:=((((phase and not(FREQ_MASK))+ (pm shl 15))) shr FREQ_SH) and SIN_MASK;
	p:= (env shl 3) + sin_tab[tmp];
	if (p >= TL_TAB_LEN) then	op_calc:=0
    else op_calc:=tl_tab[p];
end;

function op_calc1(phase:dword;env:word;pm:integer):integer;inline;
var
  p:dword;
  tmp:integer;
begin
  tmp:=(((phase and not(FREQ_MASK))+ pm) shr FREQ_SH) and SIN_MASK;
	p:= (env shl 3) + sin_tab[tmp];
	if (p >= TL_TAB_LEN) then op_calc1:=0
	  else op_calc1:=tl_tab[p];
end;

procedure CHAN_Calc(OPN:pfm_opn;CH:pfm_chan;chnum:byte);
var
  eg_out:integer;
  out_:integer;
begin
	  OPN.m2:=0;
    OPN.c1:=0;
    OPN.c2:=0;
    OPN.mem:=0;
	  CH.mem_connect^:=CH.mem_value;	// restore delayed sample (MEM) value to m2 or c2 */
	  eg_out:=CH.SLOT[SLOT1].vol_out;
    out_:=CH.op1_out[0] + CH.op1_out[1];
    CH.op1_out[0]:=CH.op1_out[1];
		if (CH.connect1=nil) then begin
			// algorithm 5  */
			OPN.mem:=CH.op1_out[0];
      OPN.c1:=CH.op1_out[0];
      OPN.c2:=CH.op1_out[0];
		end else begin
			// other algorithms */
			CH.connect1^:=CH.connect1^+CH.op1_out[0];
		end;
    CH.op1_out[1]:=0;
		if (eg_out<ENV_QUIET)	then begin // SLOT 1 */
			if (CH.FB=0) then out_:=0;
			CH.op1_out[1]:=op_calc1(CH.SLOT[SLOT1].phase, eg_out, (out_ shl CH.FB));
    end;
	  eg_out:=CH.SLOT[SLOT3].vol_out;
	  if (eg_out<ENV_QUIET)	then	// SLOT 3 */
		  CH.connect3^:=CH.connect3^+op_calc(CH.SLOT[SLOT3].phase, eg_out, OPN.m2);

	  eg_out:=CH.SLOT[SLOT2].vol_out;
	  if( eg_out < ENV_QUIET ) then	// SLOT 2 */
		  CH.connect2^:=CH.connect2^+op_calc(CH.SLOT[SLOT2].phase, eg_out, OPN.c1);

	  eg_out:=CH.SLOT[SLOT4].vol_out;
	  if (eg_out<ENV_QUIET)	then	// SLOT 4 */
		  CH.connect4^:=CH.connect4^+ op_calc(CH.SLOT[SLOT4].phase, eg_out, OPN.c2);

	  // store current MEM */
	  CH.mem_value:=OPN.mem;
    if (CH.pms<>0) then begin
      halt(0);
    end else begin
	  // update phase counters AFTER output calculations */
		  CH.SLOT[SLOT1].phase:=CH.SLOT[SLOT1].phase+CH.SLOT[SLOT1].Incr;
		  CH.SLOT[SLOT2].phase:=CH.SLOT[SLOT2].phase+CH.SLOT[SLOT2].Incr;
		  CH.SLOT[SLOT3].phase:=CH.SLOT[SLOT3].phase+CH.SLOT[SLOT3].Incr;
		  CH.SLOT[SLOT4].phase:=CH.SLOT[SLOT4].phase+CH.SLOT[SLOT4].Incr;
    end;
end;

procedure FM_KEYON(tipo:byte;CH:pfm_chan;s:integer);
var
  slot:pfm_slot;
begin
	SLOT:=CH.SLOT[s];
	if (SLOT.key=0) then begin
		SLOT.key:=1;
		SLOT.phase:=0;		// restart Phase Generator */
    SLOT.ssgn:=(SLOT.ssg and $4) shr 1;
		//Nuevo 29/08/08
    SLOT.state:=EG_ATT;	// phase -> Attack */
	end;
end;

// ----- key off of SLOT ----- */
procedure FM_KEYOFF(CH:pfm_chan;s:integer);
var
  slot:pfm_slot;
begin
		slot:=CH.SLOT[s];
	  if (SLOT.key<>0) then begin
		  SLOT.key:=0;
		  if (SLOT.state>EG_REL) then SLOT.state:=EG_REL; // phase -> Release */
    end;
end;

procedure CSMKeyControll(tipo:byte;CH:pfm_chan);
begin
	// all key on then off (only for operators which were OFF!) */
	if (CH.SLOT[SLOT1].key=0) then begin
		FM_KEYON(tipo, CH,SLOT1);
		FM_KEYOFF(CH, SLOT1);
	end;
	if (CH.SLOT[SLOT2].key=0) then begin
		FM_KEYON(tipo, CH,SLOT2);
		FM_KEYOFF(CH, SLOT2);
	end;
	if (CH.SLOT[SLOT3].key=0) then begin
		FM_KEYON(tipo, CH,SLOT3);
		FM_KEYOFF(CH, SLOT3);
	end;
	if (CH.SLOT[SLOT4].key=0) then begin
		FM_KEYON(tipo, CH,SLOT4);
		FM_KEYOFF(CH, SLOT4);
	end;
end;

// update phase increment counters */
procedure refresh_fc_eg_chan(OPN:pfm_opn;CH:pfm_chan);
var
  fc,kc:integer;
begin
	if (CH.SLOT[SLOT1].Incr=-1) then begin
		fc:=CH.fc;
		kc:=CH.kcode;
		refresh_fc_eg_slot(OPN,CH.SLOT[SLOT1],fc,kc);
		refresh_fc_eg_slot(OPN,CH.SLOT[SLOT2],fc,kc);
		refresh_fc_eg_slot(OPN,CH.SLOT[SLOT3],fc,kc);
		refresh_fc_eg_slot(OPN,CH.SLOT[SLOT4],fc,kc);
	end;
end;

procedure setup_connection(OPN:pfm_opn;CH:pfm_chan;num:integer);
var
  carrier:pinteger;
	om1,om2,oc1,memc:^pinteger;
begin
  carrier:=addr(out_fm[num]);
  om1:=addr(ch.connect1);
	om2:=addr(ch.connect3);
	oc1:=addr(ch.connect2);
	memc:=addr(ch.mem_connect);
		case CH.ALGO of
		  0:begin
			    //  PG---S1---S2---S3---S4---OUT */
			   om1^:=addr(OPN.c1);
		     oc1^:=addr(OPN.mem);
		     om2^:=addr(OPN.c2);
		     memc^:=addr(OPN.m2);
        end;
		  1:begin
			    //  PG---S1-+-S3---S4---OUT */
			    //  PG---S2-+               */
			    om1^:=addr(OPN.mem);
		      oc1^:=addr(OPN.mem);
		      om2^:=addr(OPN.c2);
		      memc^:=addr(OPN.m2);
			  end;
		  2:begin
			    // PG---S1------+-S4---OUT */
			    // PG---S2---S3-+          */
          om1^:=addr(OPN.c2);
		      oc1^:=addr(OPN.mem);
		      om2^:=addr(OPN.c2);
		      memc^:=addr(OPN.m2);
			  end;
		  3:begin
			    // PG---S1---S2-+-S4---OUT */
			    // PG---S3------+          */
			    om1^:=addr(OPN.c1);
		      oc1^:=addr(OPN.mem);
		      om2^:=addr(OPN.c2);
		      memc^:=addr(OPN.c2);
			  end;
		  4:begin
			    // PG---S1---S2-+--OUT */
			    // PG---S3---S4-+      */
			    om1^:=addr(OPN.c1);
		      oc1^:=carrier;
		      om2^:=addr(OPN.c2);
		      memc^:=addr(OPN.mem);	// store it anywhere where it will not be used */
			  end;
		  5:begin
			    //         +-S2-+     */
			    // PG---S1-+-S3-+-OUT */
			    //         +-S4-+     */
			    om1^:=nil;	// special mark */
		      oc1^:=carrier;
		      om2^:=carrier;
		      memc^:=addr(OPN.m2);
			  end;
		  6:begin
			    // PG---S1---S2-+     */
			    // PG--------S3-+-OUT */
			    // PG--------S4-+     */
			    om1^:=addr(OPN.c1);
		      oc1^:= carrier;
		      om2^:= carrier;
		      memc^:=addr(OPN.mem);	// store it anywhere where it will not be used */
		  	end;
		  7:begin
			    // PG---S1-+     */
			    // PG---S2-+-OUT */
			    // PG---S3-+     */
			    // PG---S4-+     */
			    om1^:=carrier;
		      oc1^:=carrier;
		      om2^:=carrier;
		      memc^:=addr(OPN.mem);	// store it anywhere where it will not be used */
      end;
		end;
		CH.connect4:=carrier;
end;

//FMSTATE
// status set and IRQ handling */
procedure FM_STATUS_SET(ST:pfm_state;flag:integer);
begin
		// set status flag */
  ST.status:=ST.status or flag;
  if (ST.irq=0) {and ((ST.status and ST.irqmask)<>0)} then begin
			ST.irq:=1;
			// callback user interrupt handler (IRQ is OFF to ON) */
      if (addr(ST.IRQ_Handler)<>nil) then ST.IRQ_Handler(ASSERT_LINE);
  end;
end;

	// status reset and IRQ handling */
procedure FM_STATUS_RESET(ST:pfm_state;flag:integer);
begin
		// reset status flag */
		ST.status:=ST.status and not(flag);
	 	if (ST.irq<>0) {and ((ST.status and ST.irqmask)=0) }then begin
			ST.irq:=0;
			// callback user interrupt handler (IRQ is ON to OFF) */
      if (addr(ST.IRQ_Handler)<>nil) then ST.IRQ_Handler(CLEAR_LINE);
    end;
end;

// IRQ mask set */
procedure FM_IRQMASK_SET(ST:pfm_state;flag:integer);
begin
		ST.irqmask:= flag;
		// IRQ handling check */
		FM_STATUS_SET(ST,0);
		FM_STATUS_RESET(ST,0);
end;

procedure set_timers(ST:pfm_state;n,v:integer);
begin
		// b7 = CSM MODE */
		// b6 = 3 slot mode */
		// b5 = reset b */
		// b4 = reset a */
		// b3 = timer enable b */
		// b2 = timer enable a */
		// b1 = load b */
		// b0 = load a */
		ST.mode:= v;

		// reset Timer b flag */
		if ((v and $20)<>0) then FM_STATUS_RESET(ST,$02);
		// reset Timer a flag */
		if ((v and $10)<>0) then FM_STATUS_RESET(ST,$01);
		// load b */
		if ((v and $02)<>0) then begin
        if ST.TBC=0 then begin
  				ST.TBC:=(256-ST.TB) shl 4;
	  			// External timer handler */
		  		ST.TIMER_set_b(ST.TBC*ST.timer_prescaler);
        end;
		end else begin
      if (ST.TBC<>0) then begin
				ST.TBC:=0;
				ST.TIMER_set_b(0);
			end;
		end;
		// load a */
		if ((v and $01)<>0) then begin
			if ST.TAC=0 then begin
				ST.TAC:=(1024-ST.TA);
				// External timer handler */
				ST.TIMER_set_a(ST.TAC*ST.timer_prescaler);
			end;
		end else begin
			if (ST.TAC<>0) then begin
				ST.TAC:=0;
				ST.TIMER_set_a(0);
			end;
		end;
end;

// Timer A Overflow */
procedure TimerAOver(ST:pfm_state);
begin
  // set status (if enabled) */
	if (ST.mode and $04)<>0 then FM_STATUS_SET(ST,$01);
	  // clear or reload the counter */
	  ST.TAC:=(1024-ST.TA);
	//llamada externa
  ST.TIMER_set_a(ST.TAC*ST.timer_prescaler);
end;

// Timer B Overflow */
procedure TimerBOver(ST:pfm_state);
begin
	// set status (if enabled) */
	if (ST.mode and $08)<>0 then FM_STATUS_SET(ST,$02);
  	// clear or reload the counter */
  	ST.TBC:=(256-ST.TB) shl 4;
	//llamada externa
  ST.TIMER_set_b(ST.TBC*ST.timer_prescaler);
end;

// ----- internal timer mode , update timer */
// ---------- calcrate timer A ---------- */
procedure INTERNAL_TIMER_A(ST:pfm_state;CH:pFM_Chan);
begin
  if ST.TAC<>0 then begin
    ST.TAC:=ST.TAC-ST.freqbase;//ST.freqbase;//*ST.FM_TIME;
    if (ST.TAC<=0) then begin
			TimerAOver(ST);
			// CSM mode total level latch and auto key on */
			if ((ST.mode and $80)<>0 ) then CSMKeyControll(0,CH);
		end;
  end;
end;

// ---------- calcrate timer B ---------- */
procedure INTERNAL_TIMER_B(ST:pfm_state;step:integer);
begin
		if ST.TBC<>0 then begin
      ST.TBC:=ST.TBC-ST.freqbase;//0.85;//ST.freqbase;//ST.freqbase;//*step*ST.FM_TIME;
		  if (ST.TBC<=0) then TimerBOver(ST);
    end;
end;

procedure init_timetables(ST:pfm_state;dttable:pbyte);
var
	i,d:integer;
	rate,divisor:single;
  dt_pos:pbyte;
begin
	// DeTune table */
	for d:=0 to 3 do begin
		for i:=0 to 31 do begin
      dt_pos:=dttable;
      inc(dt_pos,d*32+i);
      divisor:=(1 shl 20);
			rate:=dt_pos^*SIN_LEN*ST.freqbase*(1 shl FREQ_SH);
      rate:=rate/divisor;
			ST.dt_tab[d][i]:=trunc(rate);
			ST.dt_tab[d+4][i]:=-trunc(rate);
		end;
  end;
end;

function opn_init(chan:byte):pfm_opn;
var
  f,g:byte;
  opn:pfm_opn;
begin
  //Inicio las tablas
  FMInitTable;
  // sustain lebel table (3db per step) */
	// 0 - 15: 0, 3, 6, 9,12,15,18,21,24,27,30,33,36,39,42,93 (dB)*/
  for f:=0 to 127 do eg_rate_select[f]:=eg_rate_select_init[f]*RATE_STEPS;
  for f:=0 to 14 do sl_table[f]:=round(f*(4.0/ENV_STEP));
  sl_table[15]:=round(31*(4.0/ENV_STEP));
  getmem(opn,sizeof(fm_opn));
  //state
  getmem(opn.ST,sizeof(fm_state));
  opn.ST.TAC:=0;
  opn.ST.TBC:=0;
  getmem(opn.SL3,sizeof(fm_3slot));
  for f:=0 to chan-1 do begin
    getmem(OPN.P_CH[f],sizeof(fm_chan));
    opn.P_CH[f].pms:=0;
    for g:=0 to 3 do getmem(OPN.P_CH[f].SLOT[g],sizeof(fm_slot));
  end;
  for f:=chan to 7 do OPN.P_CH[f]:=nil;
  opn_init:=opn;
end;

procedure opn_close(OPN:pfm_opn);
  var
    f,g:byte;
begin
if opn<>nil then begin
  freemem(opn.SL3);
  opn.SL3:=nil;
  freemem(opn.ST);
  opn.st:=nil;
  for g:=0 to 7 do begin
    if opn.P_CH[g]<>nil then begin
      for f:=0 to 3 do begin
        freemem(opn.P_CH[g].SLOT[f]);
        opn.P_CH[g].SLOT[f]:=nil;
      end;
      freemem(opn.P_CH[g]);
      opn.P_ch[g]:=nil;
    end;
  end;
  freemem(opn);
end;
end;

procedure OPNWriteMode(OPN:pfm_opn;r,v:integer);
var
  c:byte;
  CH:pfm_chan;
begin
		case r of
		  $21:;	// Test */
			  //#if FM_LFO_SUPPORT
		  $22:;	// LFO FREQ (YM2608/YM2612) */
			  //if( (type & TYPE_LFOPAN) != 0 )
			  //{
			  //	LFOIncr = (v&0x08) ? LFO_FREQ[v&7] : 0;
			  //	cur_chip = NULL;
			  //}
			//#endif
		  $24:begin	// timer A High 8*/
			      opn.ST.TA:=(opn.ST.TA and $03) or (v shl 2);
          end;
		  $25:begin	// timer A Low 2*/
			      opn.ST.TA:=(opn.ST.TA and $3fc) or (v and 3);
          end;
      $26:begin	// timer B */
			      opn.ST.TB:= v;
          end;
		  $27:begin	// mode , timer control */
			      set_timers(OPN.ST,0,v);
			    end;
      $28:begin	// key on / off */
			      c:= v and $03;
			      if (c=3) then exit;
			      if (((v and $04)<>0) and ((opn.type_ and TYPE_6CH)<>0)) then c:=c+3;
			      CH:=opn.P_CH[c];
			      // csm mode */
            if ((v and $10)<>0) then FM_KEYON(OPN.type_,CH,SLOT1) else FM_KEYOFF(CH,SLOT1);
			      if ((v and $20)<>0) then FM_KEYON(OPN.type_,CH,SLOT2) else FM_KEYOFF(CH,SLOT2);
			      if ((v and $40)<>0) then FM_KEYON(OPN.type_,CH,SLOT3) else FM_KEYOFF(CH,SLOT3);
			      if ((v and $80)<>0) then FM_KEYON(OPN.type_,CH,SLOT4) else FM_KEYOFF(CH,SLOT4);
          end;
		end;
end;

// set detune & multiple */
procedure set_det_mul(ST:pfm_state;CH:pfm_chan;SLOT:pfm_slot;v:integer);
begin
		if (v and $0f)<>0 then SLOT.mul:=(v and $0f)*2
      else SLOT.mul:=1;
	  SLOT.DT:=addr(ST.dt_tab[(v shr 4) and 7]);
    slot.det_mul_val:=(v shr 4) and 7;
	  CH.SLOT[SLOT1].Incr:=-1;
end;

// set total level */
procedure set_tl(CH:pfm_chan;SLOT:pfm_slot;v:integer);
begin
  SLOT.tl:= (v and $7f) shl (ENV_BITS-7); // 7bit TL */
end;

// set attack rate & key scale  */
procedure set_ar_ksr(tipo:byte;CH:pfm_chan;SLOT:pfm_slot;v:integer);
var
  old_KSR:byte;
begin
	old_KSR:=SLOT.KSR_m;
  if (v and $1f)<>0 then SLOT.ar:=32+((v and $1f) shl 1)
    else SLOT.ar:=0;
	SLOT.KSR_m:=3-(v shr 6);
	if (SLOT.KSR_m<>old_KSR) then CH.SLOT[SLOT1].Incr:=-1;
  // refresh Attack rate */
  if ((SLOT.ar+SLOT.ksr)<(32+62)) then begin
			SLOT.eg_sh_ar:=eg_rate_shift[SLOT.ar+SLOT.ksr];
			SLOT.eg_sel_ar:=eg_rate_select[SLOT.ar+SLOT.ksr];
  end else begin
			SLOT.eg_sh_ar:=0;
			SLOT.eg_sel_ar:= 17*RATE_STEPS;
  end;
end;

// set decay rate */
procedure set_dr(tipo:byte;SLOT:pfm_slot;v:integer);
begin
  if (v and $1f)<>0 then SLOT.d1r:=32 + ((v and $1f) shl 1)
    else SLOT.d1r:=0;
	SLOT.eg_sh_d1r:= eg_rate_shift [SLOT.d1r + SLOT.ksr];
	SLOT.eg_sel_d1r:= eg_rate_select[SLOT.d1r + SLOT.ksr];
end;

// set sustain rate */
procedure set_sr(tipo:byte;SLOT:pfm_slot;v:integer);
begin
  if (v and $1f)<>0 then SLOT.d2r:=32+((v and $1f) shl 1)
    else SLOT.d2r:=0;
	SLOT.eg_sh_d2r:= eg_rate_shift [SLOT.d2r + SLOT.ksr];
	SLOT.eg_sel_d2r:= eg_rate_select[SLOT.d2r + SLOT.ksr];
end;

// set release rate */
procedure set_sl_rr(tipo:byte;SLOT:pfm_slot;v:integer);
begin
	SLOT.sl:= sl_table[ v shr 4 ];
	SLOT.rr:= 34 + ((v and $0f) shl 2);
	SLOT.eg_sh_rr:= eg_rate_shift [SLOT.rr  + SLOT.ksr];
	SLOT.eg_sel_rr:= eg_rate_select[SLOT.rr  + SLOT.ksr];
end;

function OPN_CHAN(N:integer):integer;
begin
		OPN_CHAN:=(N and 3);
end;

function OPN_SLOT(N:integer):integer;
begin
	OPN_SLOT:=((N shr 2) and 3);
end;

// prescaler set (and make time tables) */
procedure OPNSetPres(OPN:pfm_opn;pres,Timer_prescaler,SSGpres:integer);
var
	i:integer;
  tmp:single;
begin
	// frequency base */
	if OPN.ST.rate<>0 then OPN.ST.freqbase:=OPN.ST.clock/OPN.ST.rate/pres
    else OPN.ST.freqbase:=0;

	OPN.eg_timer_add:=(1 shl EG_SH)*OPN.ST.freqbase;
	OPN.eg_timer_overflow:= ( 3 ) * (1 shl EG_SH);

	// Timer base time */
	OPN.ST.Timer_prescaler:=timer_prescaler;

	// SSG part  prescaler set */
	//if (SSGpres ) (*OPN->ST.SSG->set_clock)( OPN->ST.param, OPN->ST.clock * 2 / SSGpres );

	// make time tables */
	init_timetables(OPN.ST,addr(dt_tab));

	// there are 2048 FNUMs that can be generated using FNUM/BLK registers
  //      but LFO works with one more bit of a precision so we really need 4096 elements */
	// calculate fnumber -> increment counter table */
	for i:=0 to 4095 do begin
		// freq table for octave 7 */
		// OPN phase increment counter = 20bit */
    tmp:=i * 32 * OPN.ST.freqbase * (1 shl (FREQ_SH-10));
		OPN.fn_table[i]:=round(tmp); // -10 because chip works with 10.10 fixed point, while we use 16.16 */
	end;
  OPN.fn_max:=trunc($20000 * OPN.ST.freqbase * (1 shl (FREQ_SH-10)));
end;

procedure OPNPrescaler_w(OPN:pfm_opn;addr,pre_divider:integer);
const
	opn_pres:array[0..3] of integer=( 2*12 , 2*12 , 6*12 , 3*12 );
	ssg_pres:array[0..3] of integer= ( 1    ,    1 ,    4 ,    2 );
var
	sel:integer;
begin
	case addr of
	  0:begin		// when reset */
		    OPN.ST.prescaler_sel:= 2;
      end;
	  1:begin		// when postload */
		  end;
	  $2d:begin	// divider sel : select 1/1 for 1/3line    */
		    OPN.ST.prescaler_sel:=OPN.ST.prescaler_sel or $02;
        end;
	  $2e:begin	// divider sel , select 1/3line for output */
		    OPN.ST.prescaler_sel:=OPN.ST.prescaler_sel or $01;
		    end;
	  $2f:begin	// divider sel , clear both selector to 1/2,1/2 */
		    OPN.ST.prescaler_sel:= 0;
        end;
	end;
	sel:= OPN.ST.prescaler_sel and 3;
	// update prescaler */
	OPNSetPres(OPN,opn_pres[sel]*pre_divider,opn_pres[sel]*pre_divider,ssg_pres[sel]*pre_divider);
end;

// ---------- write a OPN register (0x30-0xff) ---------- */
procedure OPNWriteReg(OPN:pfm_opn;r,v:integer);
var
  c:byte;
  CH:pfm_chan;
  SLOT:pfm_slot;
  fn:dword;
  blk:byte;
  feedback:integer;
begin
		// 0x30 - 0xff */
    c:=OPN_CHAN(r);
		if (c=3) then exit; // 0xX3,0xX7,0xXB,0xXF */
		if (r>= $100) then c:=c+3; // && (type & TYPE_6CH) */ )
		CH:=OPN.P_CH[c];

		SLOT:=(CH.SLOT[OPN_SLOT(r)]);
		case (r and $f0) of
		  $30:begin	// DET , MUL */
			      set_det_mul(OPN.ST,CH,SLOT,v);
          end;
		  $40:begin	// TL */
			      set_tl(CH,SLOT,v);
			    end;
      $50:begin	// KS, AR */
			      set_ar_ksr(OPN.type_,CH,SLOT,v);
          end;
		  $60:begin	//     DR */
			      // bit7 = AMS_ON ENABLE(YM2612) */
			      set_dr(OPN.type_,SLOT,v);
			      //#if FM_LFO_SUPPORT
			      //if( type & TYPE_LFOPAN)
			      //{
			      //	SLOT.amon = v>>7;
			      //	SLOT.ams = CH.ams * SLOT.amon;
			      //}
			      //#endif
          end;
		    $70:begin	//     SR */
			        set_sr(OPN.type_,SLOT,v);
			      end;
		    $80:begin	// SL, RR */
			        set_sl_rr(OPN.type_,SLOT,v);
			      end;
		    $90:begin	// SSG-EG */
			        SLOT.ssg :=  v and $0f;
		          SLOT.ssgn:= (v and $04) shr 1; // bit 1 in ssgn = attack */
			      end;
		    $a0:begin
			        case (OPN_SLOT(r)) of
			          0:begin		// 0xa0-0xa2 : FNUM1 */
				            fn:= ((dword((OPN.ST.fn_h) and 7)) shl 8) + v;
				            blk:= OPN.ST.fn_h shr 3;
				            // keyscale code */
				            CH.kcode:=(blk shl 2) or opn_fktable[fn shr 7];
                    // phase increment counter */
				            CH.fc:=OPN.fn_table[fn*2] shr (7-blk);
				            // store fnum in clear form for LFO PM calculations */
				            CH.block_fnum:= (blk shl 11) or fn;
				            CH.SLOT[SLOT1].Incr:=-1;
			            end;
			          1:begin		// 0xa4-0xa6 : FNUM2,BLK */
				            OPN.ST.fn_h:= v and $3f;
				          end;
			          2:begin		// 0xa8-0xaa : 3CH FNUM1 */
				           if (r<$100) then begin
				              fn:=((round(OPN.SL3.fn_h and 7)) shl 8) + v;
				              blk:=OPN.SL3.fn_h shr 3;
				              // keyscale code */
				              OPN.SL3.kcode[c]:=(blk shl 2) or opn_fktable[fn shr 7];
                      // phase increment counter */
				              OPN.SL3.fc[c]:=OPN.fn_table[fn*2] shr (7-blk);
                      OPN.SL3.block_fnum[c]:= fn;
                      OPN.P_CH[2].SLOT[SLOT1].Incr:=-1;
                   end;
                  end;
			          3:begin		// 0xac-0xae : 3CH FNUM2,BLK */
				            if (r<$100) then OPN.SL3.fn_h:= v and $3f;
                  end;
              end;
            end;
        $b0:begin
			        case OPN_SLOT(r) of
			          0:begin		// 0xb0-0xb2 : FB,ALGO */
				            feedback:= (v shr 3) and 7;
                    CH.ALGO:= v and 7;
                    if feedback<>0 then CH.FB:=feedback+6
                      else CH.FB:=0;
				            setup_connection(OPN,CH, c );
			            end;
			          1:begin		// 0xb4-0xb6 : L , R , AMS , PMS (YM2612/YM2608) */
				            {if( OPN->type & TYPE_LFOPAN) then begin
				              /* b0-2 PMS */
				              CH->pms = (v & 7) * 32; /* CH->pms = PM depth * 32 (index in lfo_pm_table) */

                      /* b4-5 AMS */
				              CH->ams = lfo_ams_depth_shift[(v>>4) & 0x03];

				              /* PAN :  b7 = L, b6 = R */
				              OPN->pan[ c*2   ] = (v & 0x80) ? ~0 : 0;
				              OPN->pan[ c*2+1 ] = (v & 0x40) ? ~0 : 0;
                    end;}
				          end;
              end;
        end;
		end;
end;

procedure advance_eg_channel(OPN:pfm_opn;CH:pfm_chan);
var
	out_:dword;
	swap_flag:dword;
	i:dword;
  SLOT:pfm_slot;
  tmp:integer;
begin
	i:=4; // four operators per channel */
  while i<>0 do begin
    swap_flag:=0;
    SLOT:=CH.SLOT[4-i];
		case SLOT.state of
		  EG_ATT:begin		// attack phase */
			  if ((OPN.eg_cnt and ((1 shl SLOT.eg_sh_ar)-1))=0) then begin
          tmp:=eg_inc[SLOT.eg_sel_ar+((OPN.eg_cnt shr SLOT.eg_sh_ar) and 7)];
          //Por raro que parezca Delphi no hace bien el shr con simbolo!!!
          //Lo hago asi para conservar el simbolo!!!!
				  SLOT.volume:=SLOT.volume+((not(SLOT.volume)*tmp) div 16);
				  if (SLOT.volume<=MIN_ATT_INDEX) then begin
					  SLOT.volume:=MIN_ATT_INDEX;
					  SLOT.state:=EG_DEC;
			  	end;
        end;
      end;
  		EG_DEC:begin	// decay phase */
	  		if (SLOT.ssg and $08)<>0 then begin // SSG EG type envelope selected */
		  		if ((OPN.eg_cnt and ((1 shl SLOT.eg_sh_d1r)-1) )=0) then begin
			  		SLOT.volume:=SLOT.volume+(4*eg_inc[SLOT.eg_sel_d1r + ((OPN.eg_cnt shr SLOT.eg_sh_d1r) and 7)]);
				  	if (SLOT.volume>= SLOT.sl ) then SLOT.state:= EG_SUS;
          end;
         end else begin
		    		if ((OPN.eg_cnt and ((1 shl SLOT.eg_sh_d1r)-1) )=0) then begin
			    		SLOT.volume:=SLOT.volume+(eg_inc[SLOT.eg_sel_d1r + ((OPN.eg_cnt shr SLOT.eg_sh_d1r) and 7)]);
  				   	if (SLOT.volume>= SLOT.sl) then SLOT.state:=EG_SUS;
            end;
         end;
      end;
		EG_SUS:begin	// sustain phase */
			if (SLOT.ssg and $08)<>0	then begin // SSG EG type envelope selected */
				if ((OPN.eg_cnt and ((1 shl SLOT.eg_sh_d2r)-1))=0) then begin
					SLOT.volume:=SLOT.volume+(4*eg_inc[SLOT.eg_sel_d2r + ((OPN.eg_cnt shr SLOT.eg_sh_d2r) and 7)]);
					if ( SLOT.volume >= ENV_QUIET ) then begin
						if (SLOT.ssg and $01)<>0 then begin	// bit 0 = hold */
							if (SLOT.ssgn and 1)<>0	then begin// have we swapped once ??? */
								// yes, so do nothing, just hold current level */
              end else begin
								swap_flag:= (SLOT.ssg and $02) or 1 ; // bit 1 = alternate */
              end;
						end else begin
							// same as KEY-ON operation */

							// restart of the Phase Generator should be here,
              //                  only if AR is not maximum ??? */
							//SLOT->phase = 0;*/

							// phase -> Attack */
							SLOT.phase:= EG_ATT;
              SLOT.volume:=511;
              SLOT.state:= EG_ATT;
							swap_flag:= (SLOT.ssg and $02); // bit 1 = alternate */
						end;
					end;
				end;
			end	else begin
				if ((OPN.eg_cnt and ((1 shl SLOT.eg_sh_d2r)-1))=0) then begin
					SLOT.volume:=SLOT.volume+ (eg_inc[SLOT.eg_sel_d2r + ((OPN.eg_cnt shr SLOT.eg_sh_d2r) and 7)]);
					if (SLOT.volume >= MAX_ATT_INDEX) then begin
						SLOT.volume:= MAX_ATT_INDEX;
						// do not change SLOT->state (verified on real chip) */
					end;
				end;
			end;
		end;

		EG_REL:begin	// release phase */
				if ((OPN.eg_cnt and ((1 shl SLOT.eg_sh_rr)-1) )=0) then begin
					SLOT.volume:=SLOT.volume+( eg_inc[SLOT.eg_sel_rr + ((OPN.eg_cnt shr SLOT.eg_sh_rr) and 7)]);
					if ( SLOT.volume >= MAX_ATT_INDEX ) then begin
						SLOT.volume:= MAX_ATT_INDEX;
						SLOT.state:= EG_OFF;
					end;
				end;
		end;
		end;

		out_:=dword(SLOT.volume);

		if ((SLOT.ssg and $08)<>0) and ((SLOT.ssgn and 2)<>0)	and (slot.state>EG_REL) then // negate output (changes come from alternate bit, init comes from attack bit) */
			out_:=out_ xor MAX_ATT_INDEX; // 1023 */

		// we need to store the result here because we are going to change ssgn
    //        in next instruction */
		SLOT.vol_out:= out_+slot.tl;

		SLOT.ssgn:=SLOT.ssgn xor swap_flag;
		i:=i-1;
	end;
end;

procedure FMInitTable;
var
		o,m:single;
		i,x:integer;
    n:integer;
begin
	  for x:=0 to TL_RES_LEN-1 do begin
		  m:= (1 shl 16) / power(2, (x+1) * (ENV_STEP/4.0) / 8.0);
		  m:= floor(m);
  		// we never reach (1<<16) here due to the (x+1) */
  		// result fits within 16 bits at maximum */
  		n:=round(m);		// 16 bits here */
  		n:=n shr 4;		// 12 bits here */
  		if (n and 1)<>0 then n:= (n shr 1)+1 	 // round to nearest */
  		  else n:= n shr 1; 	// 11 bits here (rounded) */
	  	n:=n shl 2;		// 13 bits here (as in real chip) */
	  	tl_tab[ x*2 + 0 ]:= n;
	  	tl_tab[ x*2 + 1 ]:= -tl_tab[ x*2 + 0 ];
	  	for i:=1 to 13-1 do begin
	  		tl_tab[ x*2+0 + i*2*TL_RES_LEN ]:=tl_tab[ x*2+0 ] shr i;
	  		tl_tab[ x*2+1 + i*2*TL_RES_LEN ]:= -tl_tab[ x*2+0 + i*2*TL_RES_LEN ];
     end;
    end;

    for i:=0 to SIN_LEN-1 do begin
		  // non-standard sinus */
		  m:= sin( ((i*2)+1) * M_PI / SIN_LEN ); // checked against the real chip */

		  // we never reach zero here due to ((i*2)+1) */

		  if (m>0.0) then o:= 8*log10(1.0/m)/log10(2)	// convert to 'decibels' */
		    else o:= 8*log10(-1.0/m)/log10(2);	// convert to 'decibels' */

		  o:= o / (ENV_STEP/4);

		  n:=round(2.0*o);
		  if (n and 1)<>0 then	n:= (n shr 1)+1 // round to nearest */
		    else n:= n shr 1;
      if (m>=0.0) then sin_tab[i]:=n*2+0
        else sin_tab[i]:= n*2+1;
		  //logerror("FM.C: sin [%4i]= %4i (tl_tab value=%5i)\n", i, sin_tab[i],tl_tab[sin_tab[i]]);*/
	  end;
end;

end.
