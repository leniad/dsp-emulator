unit n2a03_sound;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,sound_engine,timer_engine;

const
  APU_WRA0=$00;
  APU_WRA1=$01;
  APU_WRA2=$02;
  APU_WRA3=$03;
  APU_WRB0=$04;
  APU_WRB1=$05;
  APU_WRB2=$06;
  APU_WRB3=$07;
  APU_WRC0=$08;
  APU_WRC2=$0A;
  APU_WRC3=$0B;
  APU_WRD0=$0C;
  APU_WRD2=$0E;
  APU_WRD3=$0F;
  APU_WRE0=$10;
  APU_WRE1=$11;
  APU_WRE2=$12;
  APU_WRE3=$13;
  APU_SMASK=$15;
  APU_IRQCTRL=$17;

  NOISE_LONG=$4000;
  NOISE_SHORT=93;

  TOTAL_BUFFER_SIZE=150;

// CONSTANTS */

// vblank length table used for squares, triangle, noise */
vbl_length:array[0..31] of byte=(
   5, 127, 10, 1, 19,  2, 40,  3, 80,  4, 30,  5, 7,  6, 13,  7,
   6,   8, 12, 9, 24, 10, 48, 11, 96, 12, 36, 13, 8, 14, 16, 15);
// frequency limit of square channels */
freq_limit:array[0..7] of word=($3FF,$555,$666,$71C,$787,$7C1,$7E0,$7F0);
// table of noise frequencies */
noise_freq:array[0..15] of word=(
   4, 8, 16, 32, 64, 96, 128, 160, 202, 254, 380, 508, 762, 1016, 2034, 2046);
// dpcm transfer freqs */
dpcm_clocks:array[0..15] of word=(
   428, 380, 340, 320, 286, 254, 226, 214, 190, 160, 142, 128, 106, 85, 72, 54);
// ratios of pos/neg pulse for square waves */
// 2/16 = 12.5%, 4/16 = 25%, 8/16 = 50%, 12/16 = 75% */
duty_lut:array[0..3] of byte=(2,4,8,12);

// GLOBAL CONSTANTS */
SYNCS_MAX1=$20;
SYNCS_MAX2=$80;

// CHANNEL TYPE DEFINITIONS */
type
  square_t=record // Square Wave */
	  regs:array[0..3] of byte;
	  vbl_length:integer;
	  freq:integer;
	  phaseacc:single;
    output_vol:single;
    env_phase:single;
    sweep_phase:single;
    adder:byte;
    env_vol:byte;
    enabled:boolean;
  end;
  psquare_t=^square_t;
  triangle_t=record // Triangle Wave */
	  regs:array[0..3] of byte; // regs[1] unused */
	  linear_length:integer;
    vbl_length:integer;
    write_latency:integer;
    phaseacc:single;
    output_vol:shortint;
    adder:byte;
    counter_started:boolean;
    enabled:boolean;
  end;
  ptriangle_t=^triangle_t;
  noise_t=record // Noise Wave */
	  regs:array[0..3] of byte; // regs[1] unused */
    cur_pos:integer;
    vbl_length:integer;
    phaseacc:single;
    output_vol:single;
    env_phase:single;
    env_vol:byte;
    enabled:boolean;
  end;
  pnoise_t=^noise_t;
  dpcm_t=record // DPCM Wave */
    regs:array[0..3] of byte;
    address:dword;
    length:dword;
    bits_left:integer;
    phaseacc:single;
    output_vol:single;
    cur_byte:byte;
    enabled:boolean;
    irq_occurred:boolean;
    vol:shortint;
  end;
  pdpcm_t=^dpcm_t;
  apu_t=record // APU type */
	  // Sound channels */
	  squ:array[0..1] of psquare_t;
    tri:ptriangle_t;
    noi:pnoise_t;
    dpcm:pdpcm_t;
	  // APU registers */
	  regs:array[0..$17] of byte;
    step_mode:integer;
  end;
  papu_t=^apu_t;
  tipo_n2a03_apu=record
    apu:papu_t;			       // Actual APUs */
    apu_incsize:single;           // Adjustment increment */
    samps_per_sync:dword;        // Number of samples per vsync */
    buffer_size:dword;           // Actual buffer size in bytes */
    real_rate:dword;             // Actual playback rate */
    noise_lut:array[0..(NOISE_LONG-1)] of byte; // Noise sample lookup table */
    vbl_times:array[0..$1f] of dword;       // VBL durations in samples */
    sync_times1:array[0..(SYNCS_MAX1-1)] of dword; // Samples per sync table */
    sync_times2:array[0..(SYNCS_MAX2-1)] of dword; // Samples per sync table */
    buffer:array[1..TOTAL_BUFFER_SIZE] of integer;
    buffer_pos:byte;
    tsample:byte;
  end;
  ptipo_n2a03_apu=^tipo_n2a03_apu;

var
    n2a03:array[0..1] of ptipo_n2a03_apu;

procedure init_n2a03_sound(num:byte);
procedure close_n2a03_sound(num:byte);
procedure reset_n2a03_sound(num:byte);
function n2a03_read(num:byte;direccion:word):byte;
procedure n2a03_write(num:byte;posicion:word;value:byte);
procedure n2a03_sound_update(num:byte);
procedure n2a03_sound_advance_0;
procedure n2a03_sound_advance_1;

implementation

function sshr(num:integer;fac:byte):integer;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

// INITIALIZE NOISE LOOKUP TABLE */
procedure create_noise(num:byte;bits,size:integer);
var
  m,xor_val,i:integer;
begin
	m:=$0011;
	for i:=0 to (size-1) do begin
		xor_val:=m and 1;
		m:=sshr(m,1);
		xor_val:=xor_val xor (m and 1);
		m:=m or (xor_val shl (bits-1));
		n2a03[num].noise_lut[i]:=m;
	end;
end;

// INITIALIZE WAVE TIMES RELATIVE TO SAMPLE RATE */
procedure create_vbltimes(num:byte;rate:dword);
var
	i:integer;
begin
	for i:=0 to $1f do n2a03[num].vbl_times[i]:=vbl_length[i]*rate;
end;

// INITIALIZE SAMPLE TIMES IN TERMS OF VSYNCS */
procedure create_syncs(num:byte;sps:dword);
var
	i:integer;
	val:dword;
begin
  val:=sps;
	for i:=0 to (SYNCS_MAX1-1) do begin
		n2a03[num].sync_times1[i]:=val;
		val:=val+sps;
	end;
	val:=0;
	for i:=0 to (SYNCS_MAX2-1) do begin
		n2a03[num].sync_times2[i]:=val;
		n2a03[num].sync_times2[i]:=sshr(n2a03[num].sync_times2[i],2);
		val:=val+sps;
	end;
end;

procedure init_n2a03_sound(num:byte);
var
  rate:integer;
begin
  getmem(n2a03[num],sizeof(tipo_n2a03_apu));
  getmem(n2a03[num].apu,sizeof(apu_t));
  getmem(n2a03[num].apu.squ[0],sizeof(square_t));
  getmem(n2a03[num].apu.squ[1],sizeof(square_t));
  getmem(n2a03[num].apu.tri,sizeof(triangle_t));
  getmem(n2a03[num].apu.noi,sizeof(noise_t));
  getmem(n2a03[num].apu.dpcm,sizeof(dpcm_t));
  rate:=sound_status.cpu_clock div 4;
  // Initialize global variables */
  n2a03[num].samps_per_sync:=round(rate/llamadas_maquina.fps_max);
  n2a03[num].buffer_size:=n2a03[num].samps_per_sync;
  n2a03[num].real_rate:=rate;
  n2a03[num].apu_incsize:=sound_status.cpu_clock/rate;
  // Use initializer calls */
  create_noise(num,13,NOISE_LONG);
  create_vbltimes(num,n2a03[num].samps_per_sync);
  create_syncs(num,n2a03[num].samps_per_sync);
  case num of
    0:init_timer(sound_status.cpu_num,4,n2a03_sound_advance_0,true);
    1:init_timer(sound_status.cpu_num,4,n2a03_sound_advance_1,true);
  end;
  n2a03[num].tsample:=init_channel;
end;

procedure reset_n2a03_sound(num:byte);
begin
  fillchar(n2a03[num].apu.squ[0]^,sizeof(square_t),0);
  fillchar(n2a03[num].apu.squ[1]^,sizeof(square_t),0);
  fillchar(n2a03[num].apu.tri^,sizeof(triangle_t),0);
  fillchar(n2a03[num].apu.noi^,sizeof(noise_t),0);
  fillchar(n2a03[num].apu.dpcm^,sizeof(dpcm_t),0);
  fillchar(n2a03[num].apu.regs[0],$17,0);
  fillchar(n2a03[num].buffer[1],TOTAL_BUFFER_SIZE*sizeof(integer),0);
  n2a03[num].apu.step_mode:=0;
  n2a03[num].buffer_pos:=1;
end;

procedure close_n2a03_sound(num:byte);
begin
  freemem(n2a03[num].apu.squ[0]);
  n2a03[num].apu.squ[0]:=nil;
  freemem(n2a03[num].apu.squ[1]);
  n2a03[num].apu.squ[1]:=nil;
  freemem(n2a03[num].apu.tri);
  n2a03[num].apu.tri:=nil;
  freemem(n2a03[num].apu.noi);
  n2a03[num].apu.noi:=nil;
  freemem(n2a03[num].apu.dpcm);
  n2a03[num].apu.dpcm:=nil;
  freemem(n2a03[num].apu);
  n2a03[num].apu:=nil;
  freemem(n2a03[num]);
  n2a03[num]:=nil;
end;

procedure apu_dpcmreset(dpcm:pdpcm_t);
begin
  dpcm.address:=$C000+((dpcm.regs[2] shl 6) and $ffff);
  dpcm.length:=((dpcm.regs[3] shl 4)+1) and $ffff;
  dpcm.bits_left:=dpcm.length shl 3;
  dpcm.irq_occurred:=false;
  dpcm.enabled:=true;
  dpcm.vol:=0;
end;

// WRITE REGISTER VALUE */
procedure apu_regwrite(num,address,value:byte);
var
  chan:byte;
  apu:papu_t;
  squ:psquare_t;
begin
  if (address and 4)<>0 then chan:=1
    else chan:=0;
  apu:=n2a03[num].apu;
  squ:=apu.squ[chan];
	case address of
    // squares
	  APU_WRA0,APU_WRB0:squ.regs[0]:=value;
	  APU_WRA1,APU_WRB1:squ.regs[1]:=value;
	  APU_WRA2,APU_WRB2:begin
        squ.regs[2]:=value;
		    if (squ.enabled) then squ.freq:=((((squ.regs[3] and 7) shl 8)+value)+1) shl 16;
		  end;
	  APU_WRA3,APU_WRB3:begin
		    squ.regs[3]:=value;
		    if squ.enabled then begin
			    squ.vbl_length:=n2a03[num].vbl_times[value shr 3];
			    squ.env_vol:=0;
			    squ.freq:=((((value and 7) shl 8)+squ.regs[2])+1) shl 16;
		    end;
		  end;
	  // triangle */
	  APU_WRC0:begin
		    apu.tri.regs[0]:=value;
		    if apu.tri.enabled then begin
			    if not(apu.tri.counter_started) then apu.tri.linear_length:=n2a03[num].sync_times2[value and $7F];
		    end;
      end;
	  $09:apu.tri.regs[1]:=value;	// unused */
	  APU_WRC2:apu.tri.regs[2]:=value;
	  APU_WRC3:begin
        apu.tri.regs[3]:=value;
		    {this is somewhat of a hack.  there is some latency on the Real
        ** Thing between when trireg0 is written to and when the linear
        ** length counter actually begins its countdown.  we want to prevent
        ** the case where the program writes to the freq regs first, then
        ** to reg 0, and the counter accidentally starts running because of
        ** the sound queue's timestamp processing.
        **
        ** set to a few NES sample -- should be sufficient
        **
        **    3 * (1789772.727 / 44100) = ~122 cycles, just around one scanline
        **
        ** should be plenty of time for the 6502 code to do a couple of table
        ** dereferences and load up the other triregs}

	      // used to be 3, but now we run the clock faster, so base it on samples/sync */
		    apu.tri.write_latency:=trunc((n2a03[num].samps_per_sync+239)/240);
		    if apu.tri.enabled then begin
    			apu.tri.counter_started:=false;
    			apu.tri.vbl_length:=n2a03[num].vbl_times[value shr 3];
    			apu.tri.linear_length:=n2a03[num].sync_times2[apu.tri.regs[0] and $7f];
        end;
    end;
	  // noise */
	  APU_WRD0:apu.noi.regs[0]:=value;
	  $0D:apu.noi.regs[1]:=value; // unused */
	  APU_WRD2:apu.noi.regs[2]:=value;
	  APU_WRD3:begin
        apu.noi.regs[3]:=value;
		    if apu.noi.enabled then begin
    			apu.noi.vbl_length:=n2a03[num].vbl_times[value shr 3];
		    	apu.noi.env_vol:=0; // reset envelope */
		    end;
		  end;
	  // DMC */
	  APU_WRE0:begin
		    apu.dpcm.regs[0]:=value;
		    if (value and $80)=0 then apu.dpcm.irq_occurred:=false;
		  end;
	  APU_WRE1:begin // 7-bit DAC */
		    apu.dpcm.regs[1]:=value and $7f;
		    apu.dpcm.vol:=apu.dpcm.regs[1]-64;
		  end;
	  APU_WRE2:apu.dpcm.regs[2]:=value;
	  APU_WRE3:apu.dpcm.regs[3]:=value;
	  APU_IRQCTRL:if (value and $80)<>0 then apu.step_mode:=5
		              else apu.step_mode:=4;
	  APU_SMASK:begin
    		if (value and $01)<>0 then apu.squ[0].enabled:=true
		    else begin
    			apu.squ[0].enabled:=false;
    			apu.squ[0].vbl_length:=0;
		    end;
    		if (value and $02)<>0 then apu.squ[1].enabled:=true
		      else begin
    			  apu.squ[1].enabled:=false;
		    	  apu.squ[1].vbl_length:=0;
		      end;
    		if (value and $04)<>0 then apu.tri.enabled:=true
      		else begin
      			apu.tri.enabled:=false;
      			apu.tri.vbl_length:=0;
      			apu.tri.linear_length:=0;
      			apu.tri.counter_started:=false;
      			apu.tri.write_latency:=0;
      		end;
    		if (value and $08)<>0 then apu.noi.enabled:=true
		      else begin
      			apu.noi.enabled:=false;
    			  apu.noi.vbl_length:=0;
    		  end;
    		if (value and $10)<>0 then begin
    			// only reset dpcm values if DMA is finished */
		    	if not(apu.dpcm.enabled) then begin
    				apu.dpcm.enabled:=true;
            apu_dpcmreset(apu.dpcm);
			    end;
		    end else apu.dpcm.enabled:=false;
  		  apu.dpcm.irq_occurred:=false;
      end;
  end;
end;

// READ VALUES FROM REGISTERS */
function n2a03_read(num:byte;direccion:word):byte;
var
  address,readval:byte;
  apu:papu_t;
begin
  address:=direccion and $ff;
  apu:=n2a03[num].apu;
	if (address=$15) then begin
		readval:=0;
		if (apu.squ[0].vbl_length>0) then readval:=readval or 1;
		if (apu.squ[1].vbl_length>0) then readval:=readval or 2;
		if (apu.tri.vbl_length>0) then readval:=readval or 4;
		if (apu.noi.vbl_length>0) then readval:=readval or 8;
		if apu.dpcm.enabled then readval:=readval or $10;
		if apu.dpcm.irq_occurred then readval:=readval or $80;
	end else readval:=apu.regs[address];
  n2a03_read:=readval;
end;

// WRITE VALUE TO TEMP REGISTRY AND QUEUE EVENT */
procedure n2a03_write(num:byte;posicion:word;value:byte);
var
  address:byte;
begin
  address:=posicion and $ff;
	n2a03[num].apu.regs[address]:=value;
	apu_regwrite(num,address,value);
end;

// OUTPUT SQUARE WAVE SAMPLE (VALUES FROM -16 to +15) */
function apu_square(num,chan:byte):integer;
var
	env_delay,sweep_delay:integer;
  output_:shortint;
  squ:psquare_t;
begin
	{ reg0: 0-3=volume, 4=envelope, 5=hold, 6-7=duty cycle
    ** reg1: 0-2=sweep shifts, 3=sweep inc/dec, 4-6=sweep length, 7=sweep on
    ** reg2: 8 bits of freq
    ** reg3: 0-2=high freq, 7-4=vbl length counter}
  squ:=n2a03[num].apu.squ[chan];
	if not(squ.enabled) then begin
    apu_square:=0;
    exit;
  end;
	// enveloping */
	env_delay:=n2a03[num].sync_times1[squ.regs[0] and $f];
	// decay is at a rate of (env_regs + 1) / 240 secs */
	squ.env_phase:=squ.env_phase-4;
	while (squ.env_phase<0) do begin
		squ.env_phase:=squ.env_phase+env_delay;
		if (squ.regs[0] and $20)<>0 then squ.env_vol:=(squ.env_vol+1) and 15
		  else if (squ.env_vol<15) then squ.env_vol:=squ.env_vol+1;
	end;
	// vbl length counter */
	if ((squ.vbl_length>0) and ((squ.regs[0] and $20)=0)) then squ.vbl_length:=squ.vbl_length-1;
	if (squ.vbl_length=0) then begin
    apu_square:=0;
    exit;
  end;
	// freqsweeps */
	if (((squ.regs[1] and $80)<>0) and ((squ.regs[1] and 7)<>0)) then begin
		sweep_delay:=n2a03[num].sync_times1[(squ.regs[1] shr 4) and 7];
		squ.sweep_phase:=squ.sweep_phase-2;
		while (squ.sweep_phase<0) do begin
			squ.sweep_phase:=squ.sweep_phase+sweep_delay;
			if (squ.regs[1] and 8)<>0 then squ.freq:=squ.freq-sshr(squ.freq,(squ.regs[1] and 7))
			  else squ.freq:=squ.freq+sshr(squ.freq,(squ.regs[1] and 7));
		end;
	end;
	if ((((squ.regs[1] and 8)=0) and (sshr(squ.freq,16)>freq_limit[squ.regs[1] and 7])) or (sshr(squ.freq,16)<4)) then begin
		apu_square:=0;
    exit;
  end;
	squ.phaseacc:=squ.phaseacc-n2a03[num].apu_incsize; // # of cycles per sample */
	while (squ.phaseacc<0) do begin
		squ.phaseacc:=squ.phaseacc+sshr(squ.freq,16);
		squ.adder:=(squ.adder+1) and $0F;
	end;
	if (squ.regs[0] and $10)<>0 then output_:=squ.regs[0] and $0F
	  else output_:=$0F-squ.env_vol;
	if (squ.adder<(duty_lut[squ.regs[0] shr 6])) then output_:=-output_;
  apu_square:=shortint(output_);
end;

// OUTPUT TRIANGLE WAVE SAMPLE (VALUES FROM -16 to +15) */
function apu_triangle(num:byte):integer;
var
	freq:integer;
	output_:shortint;
  tri:ptriangle_t;
begin
	{ reg0: 7=holdnote, 6-0=linear length counter
    ** reg2: low 8 bits of frequency
    ** reg3: 7-3=length counter, 2-0=high 3 bits of frequency}
  tri:=n2a03[num].apu.tri;
	if not(tri.enabled) then begin
    apu_triangle:=0;
    exit;
  end;
	if (not(tri.counter_started) and ((tri.regs[0] and $80)<>0)) then begin
		if (tri.write_latency)<>0 then tri.write_latency:=tri.write_latency-1;
		if (tri.write_latency=0) then tri.counter_started:=true;
	end;
	if (tri.counter_started) then begin
		if (tri.linear_length>0) then tri.linear_length:=tri.linear_length-1;
		if ((tri.vbl_length<>0) and ((tri.regs[0] and $80)<>0)) then tri.vbl_length:=tri.vbl_length-1;
		if (tri.vbl_length=0) then begin
      apu_triangle:=0;
      exit;
    end;
	end;
	if (tri.linear_length=0) then begin
    apu_triangle:=0;
    exit;
  end;
	freq:=(((tri.regs[3] and 7) shl 8)+tri.regs[2])+1;
	if (freq<4) then begin // inaudible */
		apu_triangle:=0;
    exit;
  end;
	tri.phaseacc:=tri.phaseacc-n2a03[num].apu_incsize; // # of cycles per sample
	while (tri.phaseacc<0) do begin
		tri.phaseacc:=tri.phaseacc+freq;
		tri.adder:=(tri.adder+1) and $1f;
		output_:=(tri.adder and 7) shl 1;
		if (tri.adder and 8)<>0 then output_:=$10-output_;
		if (tri.adder and $10)<>0 then output_:=-output_;
		tri.output_vol:=output_;
	end;
	apu_triangle:=shortint(tri.output_vol);
end;

// OUTPUT NOISE WAVE SAMPLE (VALUES FROM -16 to +15) */
function apu_noise(num:byte):integer;
var
	freq,env_delay:integer;
	outvol,output_:byte;
  noi:pnoise_t;
begin
	 {reg0: 0-3=volume, 4=envelope, 5=hold
    ** reg2: 7=small(93 byte) sample,3-0=freq lookup
    ** reg3: 7-4=vbl length counter}
  noi:=n2a03[num].apu.noi;
	if not(noi.enabled) then begin
    apu_noise:=0;
    exit;
  end;
	// enveloping */
	env_delay:=n2a03[num].sync_times1[noi.regs[0] and $0F];
	// decay is at a rate of (env_regs + 1) / 240 secs */
	noi.env_phase:=noi.env_phase-4;
	while (noi.env_phase<0) do begin
		noi.env_phase:=noi.env_phase+env_delay;
		if (noi.regs[0] and $20)<>0 then noi.env_vol:=(noi.env_vol+1) and 15
		  else if (noi.env_vol<15) then noi.env_vol:=noi.env_vol+1;
	end;
	// length counter */
	if (noi.regs[0] and $20)=0 then begin
		if (noi.vbl_length>0) then noi.vbl_length:=noi.vbl_length-1;
	end;
	if noi.vbl_length=0 then begin
		apu_noise:=0;
    exit;
  end;
	freq:=noise_freq[noi.regs[2] and $0F];
	noi.phaseacc:=noi.phaseacc-n2a03[num].apu_incsize; // # of cycles per sample */
	while (noi.phaseacc<0) do begin
		noi.phaseacc:=noi.phaseacc+freq;
		noi.cur_pos:=noi.cur_pos+1;
		if ((NOISE_SHORT=noi.cur_pos) and (((noi.regs[2] and $80)<>0))) then noi.cur_pos:=0
		  else if (NOISE_LONG=noi.cur_pos) then noi.cur_pos:=0;
	end;
	if (noi.regs[0] and $10)<>0 then outvol:=noi.regs[0] and $0F
	  else outvol:=$0F-noi.env_vol;
	output_:=n2a03[num].noise_lut[noi.cur_pos];
	if (output_>outvol) then output_:=outvol;
	if (n2a03[num].noise_lut[noi.cur_pos] and $80)<>0 then apu_noise:=-output_
    else apu_noise:=output_;
end;

// OUTPUT DPCM WAVE SAMPLE (VALUES FROM -64 to +63) */
function apu_dpcm(num:byte):integer;
var
  dpcm:pdpcm_t;
begin
  dpcm:=n2a03[num].apu.dpcm;
  if not(dpcm.enabled) then begin
    apu_dpcm:=0;
    exit;
  end;
  apu_dpcm:=0;
  //ufffffffff
end;

// UPDATE SOUND BUFFER USING CURRENT DATA */
procedure n2a03_sound_advance(num:byte);
var
	accum:integer;
begin
		accum:=apu_square(num,0);
    accum:=accum+apu_square(num,1);
		accum:=accum+apu_triangle(num);
		accum:=accum+apu_noise(num);
    accum:=accum+apu_dpcm(num);
		if (accum>127) then accum:=127
		  else if (accum<-128) then accum:=-128;
    n2a03[num].buffer[n2a03[num].buffer_pos]:=accum shl 8;
    n2a03[num].buffer_pos:=n2a03[num].buffer_pos+1;
end;

procedure n2a03_sound_update(num:byte);
var
  f:byte;
  res:integer;
begin  //Resample from 447443hz to 44100hz
res:=0;
for f:=1 to n2a03[num].buffer_pos do res:=res+n2a03[num].buffer[f];
res:=res div n2a03[num].buffer_pos;
if res>32767 then res:=32767
  else if res<-32767 then res:=-32767;
tsample[n2a03[num].tsample,sound_status.posicion_sonido]:=res;
n2a03[num].buffer_pos:=1;
end;

procedure n2a03_sound_advance_0;
begin
  n2a03_sound_advance(0);
end;

procedure n2a03_sound_advance_1;
begin
  n2a03_sound_advance(1);
end;

end.
