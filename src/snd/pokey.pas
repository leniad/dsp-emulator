unit pokey;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}sound_engine,timer_engine;

const
  // POKEY WRITE LOGICALS */
  AUDF1_C=$00;
  AUDC1_C=$01;
  AUDF2_C=$02;
  AUDC2_C=$03;
  AUDF3_C=$04;
  AUDC3_C=$05;
  AUDF4_C=$06;
  AUDC4_C=$07;
  AUDCTL_C=$08;
  STIMER_C=$09;
  SKREST_C=$0A;
  POTGO_C=$0B;
  SEROUT_C=$0D;
  IRQEN_C=$0E;
  SKCTL_C=$0F;
  // POKEY READ LOGICALS */
  POT0_C=$00;
  POT1_C=$01;
  POT2_C=$02;
  POT3_C=$03;
  POT4_C=$04;
  POT5_C=$05;
  POT6_C=$06;
  POT7_C=$07;
  ALLPOT_C=$08;
  KBCODE_C=$09;
  RANDOM_C=$0A;
  SERIN_C=$0D;
  IRQST_C=$0E;
  SKSTAT_C=$0F;

  SYNC_NOOP=11;
  SYNC_SET_IRQST=12;
  SYNC_POT=13;
  SYNC_WRITE=14;

  LEGACY_LINEAR=0;
  RC_LOWPASS=1;
  OPAMP_C_TO_GROUND=2;
  OPAMP_LOW_PASS=3;
  DISCRETE_VAR_R=4;

  POKEY_DEFAULT_GAIN=round(32767/11/4);
  CHAN1=0;
  CHAN2=1;
  CHAN3=2;
  CHAN4=3;
  TIMER1=0;
  TIMER2=1;
  TIMER4=2;

  // values to add to the divisors for the different modes */
  DIVADD_LOCLK=1;
  DIVADD_HICLK=4;
  DIVADD_HICLK_JOINED=7;
  // AUDCx */
  NOTPOLY5=$80;    // selects POLY5 or direct CLOCK */
  POLY4_=$40;    // selects POLY4 or POLY17 */
  PURE=$20;    // selects POLY4/17 or PURE tone */
  VOLUME_ONLY=$10;    // selects VOLUME OUTPUT ONLY */
  VOLUME_MASK=$0f;    // volume mask */
  // AUDCTL */
  POLY9_   =   $80;    // selects POLY9 or POLY17 */
  CH1_HICLK =  $40;    // selects 1.78979 MHz for Ch 1 */
  CH3_HICLK  = $20;    // selects 1.78979 MHz for Ch 3 */
  CH12_JOINED= $10;    // clocks channel 1 w/channel 2 */
  CH34_JOINED= $08;    // clocks channel 3 w/channel 4 */
  CH1_FILTER=  $04;    // selects channel 1 high pass filter */
  CH2_FILTER = $02;    // selects channel 2 high pass filter */
  CLK_15KHZ   =$01;    // selects 15.6999 kHz or 63.9211 kHz */
  // IRQEN (D20E) */
  IRQ_BREAK=   $80;    // BREAK key pressed interrupt */
  IRQ_KEYBD =  $40;    // keyboard data ready interrupt */
  IRQ_SERIN  = $20;    // serial input data ready interrupt */
  IRQ_SEROR=   $10;    // serial output register ready interrupt */
  IRQ_SEROC =  $08;    // serial output complete interrupt */
  IRQ_TIMR4  = $04;    // timer channel #4 interrupt */
  IRQ_TIMR2   =$02;    // timer channel #2 interrupt */
  IRQ_TIMR1 =  $01;    // timer channel #1 interrupt */
  // SKSTAT (R/D20F) */
  SK_FRAME=    $80;    // serial framing error */
  SK_KBERR=    $40;    // keyboard overrun error - pokey documentation states *some bit as IRQST */
  SK_OVERRUN=  $20;    // serial overrun error - pokey documentation states *some bit as IRQST */
  SK_SERIN=    $10;    // serial input high */
  SK_SHIFT =   $08;    // shift key pressed */
  SK_KEYBD  =  $04;    // keyboard key pressed */
  SK_SEROUT  = $02;    // serial output active */
  // SKCTL (W/D20F) */
  SK_BREAK=    $80;    // serial out break signal */
  SK_BPS   =   $70;    // bits per second */
  SK_FM     =  $08;    // FM mode */
  SK_PADDLE  = $04;    // fast paddle a/d conversion */
  SK_RESET    =$03;    // reset serial/keyboard interface */
  SK_KEYSCAN=  $02;    // key scanning enabled ? */
  SK_DEBOUNCE= $01;    // Debouncing ?*/

  DIV_64  =    28;       // divisor for 1.78979 MHz clock to 63.9211 kHz */
  DIV_15  =    114;      // divisor for 1.78979 MHz clock to 15.6999 kHz */

  CLK_1= 0;
  CLK_28= 1;
  CLK_114= 2;
  POKEY_CHANNELS = 4;

  clock_divisors:array[0..2] of integer= (1, DIV_64, DIV_15);

type
  serin_allpot=function(offset:byte):byte;
  single_pot=function(offset:byte):byte;
  irq_funct=procedure(irq:byte);

  pokey_channel=class
      constructor create;
      destructor free;
    private
      INTMask:byte;
      AUDF:byte;           // AUDFx (D200, D202, D204, D206) */
      AUDC:byte;           // AUDCx (D201, D203, D205, D207) */
      borrow_cnt:integer;     // borrow counter */
      counter:integer;        // channel counter */
      output_:byte;         // channel output signal (1 active, 0 inactive) */
      filter_sample:byte;  // high-pass filter sample */
      div2:byte;           // division by 2 */
      procedure sample;
      procedure reset_channel;
      procedure inc_chan(chip_num,IRQEN:byte);
      function check_borrow:boolean;
  end;

  pokey_chip=class(snd_chip_class)
        constructor create(clock:dword);
        destructor free;
        procedure update;
        procedure reset;
      public
        function read(offset:word):byte;
        procedure write(offset:word;data:byte);
        procedure change_pot(pot0,pot1,pot2,pot3,pot4,pot5,pot6,pot7:single_pot);
        procedure change_all_pot(pot_all:serin_allpot);
        //function save_snapshot(data:pbyte):word;
        //procedure load_snapshot(data:pbyte);
      private
	      // internal state
	      number,buf_pos:byte;
	      channel:array[0..POKEY_CHANNELS-1] of pokey_channel;

	      output_:dword;        // raw output */
	      out_filter:double;    // filtered output */
	      clock_cnt:array[0..2] of integer;       // clock counters */
        p4:dword;              // poly4 index */
	      p5:dword;              // poly5 index */
	      p9:dword;              // poly9 index */
	      p17:dword;             // poly17 index */

	      pot0_r_cb,pot1_r_cb,pot2_r_cb,pot3_r_cb,pot4_r_cb,pot5_r_cb,
        pot6_r_cb,pot7_r_cb:single_pot;
	      allpot_r_cb,serin_r_cb:serin_allpot;
        irq_f:irq_funct;
	      //devcb_write8 m_serout_w_cb;

        POTx:array[0..7] of byte;        // POTx   (R/D200-D207) */
        AUDCTL:byte;         // AUDCTL (W/D208) */
        ALLPOT:byte;         // ALLPOT (R/D208) */
        KBCODE:byte;         // KBCODE (R/D209) */
        SERIN:byte;          // SERIN  (R/D20D) */
        SEROUT:byte;         // SEROUT (W/D20D) */
        IRQST:byte;          // IRQST  (R/D20E) */
        IRQEN:byte;          // IRQEN  (W/D20E) */
        SKSTAT:byte;         // SKSTAT (R/D20F) */
        SKCTL:byte;          // SKCTL  (W/D20F) */

        pot_counter:byte;
        kbd_cnt:byte;
        kbd_latch:byte;
        kbd_state:byte;

	      clock_period:double;

	      poly4:array[0..$0f] of dword;
        poly5:array[0..$1f] of dword;
        poly9:array[0..$1ff] of dword;
        poly17:array[0..$1ffff] of dword;
        voltab:array[0..$10000] of dword;
        procedure step_one_clock;
	      //procedure step_keyboard;

        procedure vol_init;
        procedure write_internal(offset:word;data:byte);
        procedure update_internal;
        procedure process_channel(ch:integer);
        procedure step_pot;
        procedure potgo;

  end;
  procedure pokey_update_internal(index:byte);
  procedure pokey0_update_internal;
  procedure pokey1_update_internal;
  procedure pokey2_update_internal;

var
  pokey_0,pokey_1,pokey_2:pokey_chip;

implementation
var
  chips_total:integer=-1;

procedure pokey_chip.change_pot(pot0,pot1,pot2,pot3,pot4,pot5,pot6,pot7:single_pot);
begin
  self.pot0_r_cb:=pot0;
  self.pot1_r_cb:=pot1;
  self.pot2_r_cb:=pot2;
  self.pot3_r_cb:=pot3;
  self.pot4_r_cb:=pot4;
  self.pot5_r_cb:=pot5;
  self.pot6_r_cb:=pot6;
  self.pot7_r_cb:=pot7;
end;

procedure pokey_chip.change_all_pot(pot_all:serin_allpot);
begin
  self.allpot_r_cb:=pot_all;
end;

procedure pokey_chip.update_internal;
var
  out_,i:integer;
begin
  //aqui me faltan el resto de salidas...para empezar va bien...
  out_:=0;
  for i:=0 to 3 do out_:=out_+(((self.output_ shr (4*i)) and $0f));
  out_:=out_*POKEY_DEFAULT_GAIN;
  if (out_>$7fff) then out_:=$7fff;
  self.output_:=out_;
end;

procedure synchronize(tipo:byte;valor:dword;chip_num:byte);
var
  chip:pokey_chip;
begin
  case chip_num of
    0:chip:=pokey_0;
    1:chip:=pokey_1;
    2:chip:=pokey_2;
  end;
	case tipo of
	3:begin
		  // serout_ready_cb */
		  if (chip.IRQEN and IRQ_SEROR)<>0 then begin
			  chip.IRQST:=chip.IRQST or IRQ_SEROR;
			  if (@chip.irq_f<>nil) then chip.irq_f(IRQ_SEROR);
		  end;
		end;
	4:begin
		  // serout_complete */
		  if (chip.IRQEN and IRQ_SEROC)<>0 then begin
			  chip.IRQST:=chip.IRQST or IRQ_SEROC;
			  if (@chip.irq_f<>nil) then chip.irq_f(IRQ_SEROC);
		  end;
		end;
	5:begin
		  // serin_ready */
		  if (chip.IRQEN and IRQ_SERIN)<>0 then begin
			  // set the enabled timer irq status bits */
			  chip.IRQST:=chip.IRQST or IRQ_SERIN;
			  // call back an application supplied function to handle the interrupt */
        if (@chip.irq_f<>nil) then chip.irq_f(IRQ_SERIN);
		  end;
		end;
	SYNC_NOOP:; // do nothing, caused by a forced resync */
	SYNC_POT:begin
		//logerror("x %02x \n", (param & 0x20));
		chip.ALLPOT:=chip.ALLPOT or (valor and $ff);
		end;
	SYNC_SET_IRQST:begin
		chip.IRQST:=chip.IRQST or (valor and $ff);
		end;
  end;
end;

constructor pokey_channel.create;
begin
end;

destructor pokey_channel.free;
begin
end;

procedure pokey_channel.sample;
begin
  self.filter_sample:=self.output_;
end;

procedure pokey_channel.reset_channel;
begin
   self.counter:=self.AUDF xor $ff;
end;

procedure pokey_channel.inc_chan(chip_num,IRQEN:byte);
begin
  self.counter:=(self.counter+1) and $ff;
  if ((self.counter=0) and (self.borrow_cnt=0)) then begin
    self.borrow_cnt:=3;
    if ((IRQEN and self.INTMask)<>0) then begin
					// Exposed state has changed: This should only be updated after a resync ... */
					synchronize(SYNC_SET_IRQST,self.INTMask,chip_num);
    end;
  end;
end;

function pokey_channel.check_borrow:boolean;
begin
  if (self.borrow_cnt>0) then begin
				self.borrow_cnt:=self.borrow_cnt-1;
				check_borrow:=(self.borrow_cnt=0);
        exit;
  end;
  check_borrow:=false;
end;

procedure pokey_chip.reset;
var
  i:byte;
begin
  self.output_:=0;
  // Setup channels */
	for i:=0 to (POKEY_CHANNELS-1) do self.channel[i].INTMask:=0;
	self.channel[CHAN1].INTMask:=IRQ_TIMR1;
	self.channel[CHAN2].INTMask:=IRQ_TIMR2;
	self.channel[CHAN4].INTMask:=IRQ_TIMR4;
	self.KBCODE:=$09;         // Atari 800 'no key' */
	self.SKCTL:=SK_RESET;  // let the RNG run after reset */
	self.SKSTAT:=0;
	self.IRQST:=0;
	self.IRQEN:=0;
	self.AUDCTL:=0;
	self.p4:=0;
	self.p5:=0;
	self.p9:=0;
	self.p17:=0;
	self.ALLPOT:=0;
	self.pot_counter:=0;
	self.kbd_cnt:=0;
	self.out_filter:=0;
	self.output_:=0;
	self.kbd_state:=0;
	// reset more internal state */
	for i:=0 to 2 do self.clock_cnt[i]:=0;
	for i:=0 to 7 do self.POTx[i]:=0;
end;

procedure pokey_chip.vol_init;
const
  resistors:array[0..3] of double=(90000, 26500, 8050, 3400);
var
	r_off:double;
  r_chan:array[0..15] of double;
	rTot:double;
  j,i:integer;
begin
	// just a guess, there has to be a resistance since the doc specifies that
	// Vout is at least 4.2V if all channels turned off.
	r_off:=8e6;
	for j:=0 to 15 do begin
		rTot:= 1.0 / 1e12; // avoid div by 0 */;
		for i:=0 to 4 do begin
			if ((j and (1 shl i))<>0) then rTot:=rTot+(1.0/resistors[i])
			  else rTot:=rTot+(1.0/r_off);
		end;
		r_chan[j]:=1.0/rTot;
	end;
	for j:=0 to $ffff do begin
		rTot:=0;
		for i:=0 to 3 do begin
			rTot:=rTot +(1.0/r_chan[(j shr (i*4)) and $0f]);
		end;
		rTot:=1.0/rTot;
		self.voltab[j]:=round(rTot);
	end;
end;

procedure poly_init_4_5(poly:pdword;size,xorbit,invert:integer);
var
  mask,i,in_:integer;
  lfsr:dword;
  ptemp:pdword;
begin
  ptemp:=poly;
	mask:=(1 shl size)-1;
	lfsr:=0;
	for i:=0 to (mask-1) do begin
		// calculate next bit */
		in_:=(not((lfsr shr 0) and 1)) xor ((lfsr shr xorbit) and 1);
		lfsr:=lfsr shr 1;
		lfsr:=(in_ shl (size-1)) or lfsr;
		ptemp^:=lfsr xor invert;
		inc(ptemp);
	end;
end;

procedure poly_init_9_17(poly:pdword;size:integer);
var
  mask,i,in8,in_:integer;
  lfsr:dword;
  ptemp:pdword;
begin
	mask:=(1 shl size)-1;
	lfsr:=mask;
  ptemp:=poly;
	if (size=17) then begin
		for i:=0 to (mask-1) do begin
			// calculate next bit @ 7 */
			in8:=((lfsr shr 8) and 1) xor ((lfsr shr 13) and 1);
			in_:= (lfsr and 1);
			lfsr:=lfsr shr 1;
			lfsr:=(lfsr and $ff7f) or (in8 shl 7);
			lfsr:=(in_ shl 16) or lfsr;
			ptemp^:=lfsr;
			inc(ptemp);
		end;
	end else begin
		for i:=0 to (mask-1) do begin
			// calculate next bit */
			in_:= ((lfsr shr 0) and 1) xor ((lfsr shr 5) and 1);
			lfsr:=lfsr shr 1;
			lfsr:=(in_ shl 8) or lfsr;
			ptemp^:=lfsr;
			inc(ptemp);
		end;
	end;
end;

constructor pokey_chip.Create(clock:dword);
var
  i:integer;
begin
  chips_total:=chips_total+1;
  self.number:=chips_total;
  self.buf_pos:=0;
  timers.init(sound_status.cpu_num,sound_status.cpu_clock/clock,nil,pokey_update_internal,true,self.number);
	// Setup channels */
	for i:=0 to (POKEY_CHANNELS-1) do begin
		//self.channel[i].parent = this;
    self.channel[i]:=pokey_channel.create;
		self.channel[i].INTMask:=0;
	end;
	self.channel[CHAN1].INTMask:=IRQ_TIMR1;
	self.channel[CHAN2].INTMask:=IRQ_TIMR2;
	self.channel[CHAN4].INTMask:=IRQ_TIMR4;

	// calculate the A/D times
	// In normal, slow mode (SKCTL bit SK_PADDLE is clear) the conversion
	// takes N scanlines, where N is the paddle value. A single scanline
	// takes approximately 64us to finish (1.78979MHz clock).
	// In quick mode (SK_PADDLE set) the conversion is done very fast
	// (takes two scanlines) but the result is not as accurate.

	// initialize the poly counters */
	poly_init_4_5(@self.poly4[0], 4, 1, 0);
	poly_init_4_5(@self.poly5[0], 5, 2, 1);

	// initialize 9 / 17 arrays */
	poly_init_9_17(@self.poly9[0],   9);
	poly_init_9_17(@self.poly17[0], 17);
	self.vol_init;

	// The pokey does not have a reset line. These should be initialized
	// with random values.

	self.KBCODE:=$09;         // Atari 800 'no key' */
	self.SKCTL:=SK_RESET;  // let the RNG run after reset */
	self.SKSTAT:=0;
	self.IRQST:=0;
	self.IRQEN:=0;
	self.AUDCTL:=0;
	self.p4:=0;
	self.p5:=0;
	self.p9:=0;
	self.p17:=0;
	self.ALLPOT:=$00;

	self.pot_counter:=0;
	self.kbd_cnt:=0;
	self.out_filter:=0;
	self.output_:=0;
	self.kbd_state:=0;

	// reset more internal state */
	for i:=0 to 2 do self.clock_cnt[i]:=0;

	for i:=0 to 7 do self.POTx[i]:=0;

	self.pot0_r_cb:=nil;
	self.pot1_r_cb:=nil;
	self.pot2_r_cb:=nil;
	self.pot3_r_cb:=nil;
	self.pot4_r_cb:=nil;
	self.pot5_r_cb:=nil;
	self.pot6_r_cb:=nil;
	self.pot7_r_cb:=nil;
	self.allpot_r_cb:=nil;
	self.serin_r_cb:=nil;
  self.irq_f:=nil;

	//self.serout_w_cb:=nil;

	self.tsample_num:=init_channel;
end;

destructor pokey_chip.free;
var
  i:byte;
begin
for i:=0 to (POKEY_CHANNELS-1) do self.channel[i].free;
chips_total:=chips_total-1;
end;

function pokey_chip.read(offset:word):byte;
var
  data,pot:byte;
begin
	synchronize(SYNC_NOOP,0,self.number); // force resync */
	case (offset and $f) of
	  POT0_C,POT1_C,POT2_C,POT3_C,POT4_C,POT5_C,POT6_C,POT7_C:begin
		    pot:=offset and 7;
		    if ((self.ALLPOT and (1 shl pot))<>0) then begin
			    // we have a value measured */
			    data:=self.POTx[pot];
		    end else begin
			    data:=self.pot_counter;
		    end;
		  end;
	  ALLPOT_C:begin
		    // If the 2 least significant bits of SKCTL are 0, the ALLPOTs
		    // are disabled (SKRESET). Thanks to MikeJ for pointing this out.
		    if ((self.SKCTL and SK_RESET)=0) then begin
			    data:=0;
		    end else begin
          if (@self.allpot_r_cb<>nil) then begin
			      data:=self.allpot_r_cb(offset);
          end else begin
			      data:=self.ALLPOT xor $ff;
		      end;
        end;
      end;
	  KBCODE_C:data:=self.KBCODE;
	  RANDOM_C:begin
		    if ((self.AUDCTL and POLY9_)<>0) then begin
			    data:=self.poly9[self.p9] and $ff;
		    end else begin
			    data:=(self.poly17[self.p17] shr 8) and $ff;
        end;
		  end;
	  SERIN_C:begin
		    if (@self.serin_r_cb<>nil) then self.SERIN:=self.serin_r_cb(offset);
		    data:=self.SERIN;
		  end;
    IRQST_C:begin
		    // IRQST is an active low input port; we keep it active high */
		    // internally to ease the (un-)masking of bits */
		    data:=self.IRQST xor $ff;
		  end;
	  SKSTAT_C:begin
		    // SKSTAT is also an active low input port */
		    data:=self.SKSTAT xor $ff;
      end;
    else data:=0;
	end;
	read:=data;
end;

procedure pokey_chip.potgo;
var
  pot,r:byte;
procedure update_pot;
begin
if (r>=228) then r:=228;
if (r=0) then begin
  // immediately set the ready - bit of m_ALLPOT
  // In this case, most likely no capacitor is connected
  self.ALLPOT:=self.ALLPOT or (1 shl pot);
end;
// final value */
self.POTx[pot]:=r;
end;
begin
  self.ALLPOT:=0;
	self.pot_counter:=0;
	for pot:=0 to 7 do begin
		self.POTx[pot]:=228;
    case pot of
      0:if(addr(self.pot0_r_cb)<>nil) then begin
          r:=self.pot0_r_cb(pot);
          update_pot;
        end;
      1:if(addr(self.pot1_r_cb)<>nil) then begin
          r:=self.pot1_r_cb(pot);
          update_pot;
        end;
      2:if(addr(self.pot2_r_cb)<>nil) then begin
          r:=self.pot2_r_cb(pot);
          update_pot;
        end;
      3:if(addr(self.pot3_r_cb)<>nil) then begin
          r:=self.pot3_r_cb(pot);
          update_pot;
        end;
      4:if(addr(self.pot4_r_cb)<>nil) then begin
          r:=self.pot4_r_cb(pot);
          update_pot;
        end;
      5:if(addr(self.pot5_r_cb)<>nil) then begin
          r:=self.pot5_r_cb(pot);
          update_pot;
        end;
      6:if(addr(self.pot6_r_cb)<>nil) then begin
          r:=self.pot6_r_cb(pot);
          update_pot;
        end;
      7:if(addr(self.pot7_r_cb)<>nil) then begin
          r:=self.pot7_r_cb(pot);
          update_pot;
        end;
    end;
  end;
end;

procedure pokey_chip.write_internal(offset:word;data:byte);
var
  i:integer;
begin
	// determine which address was changed */
	case (offset and 15) of
	  AUDF1_C:self.channel[CHAN1].AUDF:=data;
	  AUDC1_C:self.channel[CHAN1].AUDC:=data;
	  AUDF2_C:self.channel[CHAN2].AUDF:=data;
	  AUDC2_C:self.channel[CHAN2].AUDC:=data;
	  AUDF3_C:self.channel[CHAN3].AUDF:=data;
	  AUDC3_C:self.channel[CHAN3].AUDC:=data;
    AUDF4_C:self.channel[CHAN4].AUDF:=data;
    AUDC4_C:self.channel[CHAN4].AUDC:=data;
    AUDCTL_C:self.AUDCTL:=data;
	  STIMER_C:begin
		  // From the pokey documentation:
		  // reset all counters to zero (side effect)
		  // Actually this takes 4 cycles to actually happen.
		  // FIXME: Use timer for delayed reset !
		  for i:=0 to (POKEY_CHANNELS-1) do begin
			  self.channel[i].reset_channel;
			  self.channel[i].output_:=0;
			  if (i<2) then self.channel[i].filter_sample:=1
          else self.channel[i].filter_sample:=0;
		  end;
    end;
	  SKREST_C:self.SKSTAT:=self.SKSTAT and not(SK_FRAME or SK_OVERRUN or SK_KBERR); // reset SKSTAT */
	  POTGO_C:self.potgo;
	  SEROUT_C:begin
		  //self.serout_w_cb(offset, data);
		  self.SKSTAT:=self.SKSTAT or SK_SEROUT;
		  //* These are arbitrary values, tested with some custom boot
		  //* loaders from Ballblazer and Escape from Fractalus
		  //* The real times are unknown
		  //timer_set(attotime::from_usec(200), 3);
		  // 10 bits (assumption 1 start, 8 data and 1 stop bit) take how long? */
		  //timer_set(attotime::from_usec(2000), 4);// FUNC(pokey_serout_complete), 0, p);
      synchronize(4,0,self.number);
		end;
	  IRQEN_C:begin
		  // acknowledge one or more IRQST bits ? */
		  if ((self.IRQST and not(data))<>0) then begin
			  // reset IRQST bits that are masked now */
			  self.IRQST:=self.IRQST and data;
		  end;
		  // store irq enable */
		  self.IRQEN:=data;
		end;
	  SKCTL_C:begin
		  self.SKCTL:=data;
		  if ((data and SK_RESET)=0) then begin
			  self.write_internal(IRQEN_C,0);
			  self.write_internal(SKREST_C,0);
			  // If the 2 least significant bits of SKCTL are 0, the random
			  // number generator is disabled (SKRESET). Thanks to Eric Smith
			  // for pointing out this critical bit of info!
			  // Couriersud: Actually, the 17bit poly is reset and kept in a
			  // reset state.
			  self.p9:=0;
			  self.p17:=0;
			  self.p4:=0;
			  self.p5:=0;
			  self.clock_cnt[0]:=0;
			  self.clock_cnt[1]:=0;
			  self.clock_cnt[2]:=0;
			  // FIXME: Serial port reset ! */
		  end;
    end;
  end;
end;
procedure pokey_chip.write(offset:word;data:byte);
begin
  self.write_internal(offset,data);
end;
procedure pokey_chip.process_channel(ch:integer);
begin
	if (((self.channel[ch].AUDC and NOTPOLY5)<>0) or ((self.poly5[self.p5] and 1)<>0)) then begin
		if (self.channel[ch].AUDC and PURE)<>0 then self.channel[ch].output_:=self.channel[ch].output_ xor 1
		  else if (self.channel[ch].AUDC and POLY4_)<>0 then self.channel[ch].output_:=self.poly4[self.p4] and 1
		    else if (self.AUDCTL and POLY9_)<>0 then self.channel[ch].output_:=self.poly9[self.p9] and 1
		      else self.channel[ch].output_:=self.poly17[self.p17] and 1;
	end;
end;

procedure pokey_chip.step_pot;
var
  pot:integer;
  upd:byte;
begin
	upd:=0;
	self.pot_counter:=self.pot_counter+1;
	for pot:=0 to 7 do begin
		if ((self.POTx[pot]<self.pot_counter) or (self.pot_counter=228)) then begin
			upd:=upd or (1 shl pot);
			// latching is emulated in read */
		end;
	end;
	synchronize(SYNC_POT,upd,self.number);
end;

procedure pokey_chip.step_one_clock;
var
  ch,clk,base_clock:integer;
  sum:dword;
  clock_triggered:array[0..2] of integer;
  isJoined:boolean;
begin
  sum:=0;
	clock_triggered[0]:=0;
  clock_triggered[1]:=0;
  clock_triggered[2]:=0;
	if ((self.AUDCTL and CLK_15KHZ)<>0) then base_clock:=CLK_114
    else base_clock:=CLK_28;

	if ((self.SKCTL and SK_RESET)<>0) then begin
		// Clocks only count if we are not in a reset */
		for clk:=0 to 2 do begin
			self.clock_cnt[clk]:=self.clock_cnt[clk]+1;
			if (self.clock_cnt[clk]>=clock_divisors[clk]) then begin
				self.clock_cnt[clk]:=0;
				clock_triggered[clk]:=1;
			end;
    end;
		self.p4:=(self.p4+1) mod $0000f;
		self.p5:=(self.p5+1) mod $0001f;
		self.p9:=(self.p9+1) mod $001ff;
		self.p17:=(self.p17+1) mod $1ffff;

		if (self.AUDCTL and CH1_HICLK)<>0 then clk:=CLK_1
      else clk:=base_clock;
		if (clock_triggered[clk]<>0) then self.channel[CHAN1].inc_chan(self.number,self.IRQEN);
		if ((self.AUDCTL and CH3_HICLK)<>0) then clk:=CLK_1
      else clk:=base_clock;
		if (clock_triggered[clk]<>0) then self.channel[CHAN3].inc_chan(self.number,self.IRQEN);
		if (clock_triggered[base_clock]<>0) then begin
			if ((self.AUDCTL and CH12_JOINED)=0) then self.channel[CHAN2].inc_chan(self.number,self.IRQEN);
			if ((self.AUDCTL and CH34_JOINED)=0) then self.channel[CHAN4].inc_chan(self.number,self.IRQEN);
		end;
		// Potentiometer handling */
		if (((clock_triggered[CLK_114]<>0) or ((self.SKCTL and SK_PADDLE)<>0)) and (self.pot_counter<228)) then self.step_pot;
		// Keyboard */
		//if ((clock_triggered[CLK_114]<>0) and ((self.SKCTL and SK_KEYSCAN)<>0)) then self.step_keyboard;
	end;
	// do CHAN2 before CHAN1 because CHAN1 may set borrow! */
	if (self.channel[CHAN2].check_borrow) then begin
		isJoined:=(self.AUDCTL and CH12_JOINED)<>0;
		if isJoined then self.channel[CHAN1].reset_channel;
    self.channel[CHAN2].reset_channel;
		self.process_channel(CHAN2);
		// check if some of the requested timer interrupts are enabled */
		if (((self.IRQST and IRQ_TIMR2)<>0) and (@self.irq_f<>nil)) then self.irq_f(IRQ_TIMR2);
	end;
	if (self.channel[CHAN1].check_borrow) then begin
		isJoined:=(self.AUDCTL and CH12_JOINED)<>0;
		if isJoined then self.channel[CHAN2].inc_chan(self.number,self.IRQEN)
		  else self.channel[CHAN1].reset_channel;
		self.process_channel(CHAN1);
		// check if some of the requested timer interrupts are enabled */
		if (((self.IRQST and IRQ_TIMR1)<>0) and (@self.irq_f<>nil)) then self.irq_f(IRQ_TIMR1);
	end;
	// do CHAN4 before CHAN3 because CHAN3 may set borrow! */
	if (self.channel[CHAN4].check_borrow) then begin
		isJoined:=(self.AUDCTL and CH34_JOINED)<>0;
		if isJoined then self.channel[CHAN3].reset_channel;
		self.channel[CHAN4].reset_channel;
		self.process_channel(CHAN4);
		// is this a filtering channel (3/4) and is the filter active? */
		if ((self.AUDCTL and CH2_FILTER)<>0) then self.channel[CHAN2].sample
		  else self.channel[CHAN2].filter_sample:=1;
		if (((self.IRQST and IRQ_TIMR4)<>0) and (@self.irq_f<>nil)) then self.irq_f(IRQ_TIMR4);
	end;

	if (self.channel[CHAN3].check_borrow) then begin
		isJoined:=(self.AUDCTL and CH34_JOINED)<>0;
		if isJoined then self.channel[CHAN4].inc_chan(self.number,self.IRQEN)
		  else self.channel[CHAN3].reset_channel;
		self.process_channel(CHAN3);
		// is this a filtering channel (3/4) and is the filter active? */
		if (self.AUDCTL and CH1_FILTER)<>0 then self.channel[CHAN1].sample
      else self.channel[CHAN1].filter_sample:=1;
	end;
	for ch:=0 to 3 do
    if (((self.channel[ch].output_ xor self.channel[ch].filter_sample)<>0) or ((self.channel[ch].AUDC and VOLUME_ONLY)<>0)) then
      sum:=sum or ((self.channel[ch].AUDC and VOLUME_MASK) shl (ch*4));
      //else sum:= sum or (0 shl (ch*4))
  self.output_:=sum;
end;

procedure pokey_update_internal(index:byte);
var
  chip:pokey_chip;
begin
  case index of
    0:chip:=pokey_0;
    1:chip:=pokey_1;
    2:chip:=pokey_2;
  end;
  chip.step_one_clock;
  chip.update_internal;
end;

procedure pokey0_update_internal;
begin
  pokey_0.step_one_clock;
  pokey_0.update_internal;
end;

procedure pokey1_update_internal;
begin
  pokey_1.step_one_clock;
  pokey_1.update_internal;
end;

procedure pokey2_update_internal;
begin
  pokey_2.step_one_clock;
  pokey_2.update_internal;
end;
procedure pokey_chip.update;
begin
  tsample[self.tsample_num,sound_status.posicion_sonido]:=self.output_;
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=self.output_;
end;
end.
