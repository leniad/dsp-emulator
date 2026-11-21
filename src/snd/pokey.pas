unit pokey;
{$INLINE ON}

interface
uses main_engine,sound_engine,timer_engine,dialogs,Math;

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
  // Borrow completes three chip clocks after underflow; the current
  // clock consumes the first of these four propagation steps.
  DIVADD_LOCLK=4;
  DIVADD_HICLK=4;
  // A joined pair propagates through each counter separately (4 + 3).
  DIVADD_HICLK_JOINED=4;
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
      AUDF_latched:byte; // AUDF at the physical reload, before the IRQ event
      AUDF:byte;           // AUDFx (D200, D202, D204, D206) */
      AUDC:byte;           // AUDCx (D201, D203, D205, D207) */
      borrow_cnt:integer;     // borrow counter */
      counter:integer;        // channel counter */
      output_:byte;         // channel output signal (1 active, 0 inactive) */
      filter_sample:byte;  // high-pass filter sample */
      div2:byte;           // division by 2 */
      procedure sample; inline;
      procedure reset_channel(latched:boolean=false); inline;
      procedure inc_chan(chip_num,IRQEN:byte;cycles:integer);
      function check_borrow:boolean; inline;
  end;

  pokey_chip=class(snd_chip_class)
        constructor create(clock:dword);
        destructor free;
        procedure update;
        // Opt-in band-limited PCM output, without changing POKEY digital state.
        procedure set_resampling(enabled:boolean);
        // Opt-in bus clocking; the automatic timer remains the default.
        procedure set_external_clock(enabled:boolean);
        procedure clock;
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
        clock_timer:byte;
        external_clock:boolean;
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
        resample_enabled:boolean;
        resample_clock,resample_phase:cardinal;
        resample_history:array[0..1023]of smallint; // mirrored 512-sample ring
        resample_delta_index:array[0..255]of word;
        resample_delta:array[0..255]of integer;
        resample_delta_count:integer;
        resample_coeff:array[0..511]of smallint;
        resample_queue:array[0..255]of smallint;
        resample_pos,resample_read,resample_write,resample_count:integer;
        resample_hold:smallint;
        procedure resample_tick(value:integer);
        procedure step_one_clock;
	      //procedure step_keyboard;

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
  out_:integer;
begin
  //aqui me faltan el resto de salidas...para empezar va bien...
  // Sum the four packed 4-bit volumes without a per-clock loop.
  out_:=(self.output_ and $0f0f)+((self.output_ shr 4) and $0f0f);
  out_:=((out_ and $ff)+(out_ shr 8))*POKEY_DEFAULT_GAIN;
  if (out_>$7fff) then out_:=$7fff;
  self.output_:=out_;
  if self.resample_enabled then self.resample_tick(out_);
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
      chip.SKSTAT:=chip.SKSTAT and not SK_SEROUT;
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

procedure pokey_channel.reset_channel(latched:boolean);
begin
   if latched then self.counter:=self.AUDF_latched xor $ff
     else self.counter:=self.AUDF xor $ff;
   self.borrow_cnt:=0;
end;

procedure pokey_channel.inc_chan(chip_num,IRQEN:byte;cycles:integer);
begin
  self.counter:=(self.counter+1) and $ff;
  if ((self.counter=0) and (self.borrow_cnt=0)) then begin
    self.borrow_cnt:=cycles;

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
  self.set_resampling(self.resample_enabled);
  // Clear audio state on emulator reset.
  for i:=0 to (POKEY_CHANNELS-1) do begin
    self.channel[i].AUDF:=0;
    self.channel[i].AUDF_latched:=0;
    self.channel[i].AUDC:=0;
    self.channel[i].counter:=0;
    self.channel[i].borrow_cnt:=0;
    self.channel[i].output_:=0;
    self.channel[i].filter_sample:=0;
    self.channel[i].div2:=0;
  end;
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

procedure poly_init_4_5(poly:pdword;size:integer);
var
  mask,i:integer;
  feedback,lfsr:dword;
  ptemp:pdword;
begin
  ptemp:=poly;
  mask:=(1 shl size)-1;
  lfsr:=0;
  for i:=0 to (mask-1) do begin
    feedback:=(not ((lfsr shr 2) xor (lfsr shr (size-1)))) and 1;
    lfsr:=((lfsr shl 1) or feedback) and mask;
    ptemp^:=lfsr;
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
  if addr(update_sound_proc)=nil then MessageDlg('ERROR: Chip de sonido inicializado sin CPU de sonido!', mtInformation,[mbOk], 0);
  self.resample_clock:=clock;
  self.resample_enabled:=false;
  chips_total:=chips_total+1;
  self.number:=chips_total;
  self.buf_pos:=0;
  self.external_clock:=false;
  self.clock_timer:=timers.init(sound_status.cpu_num,sound_status.cpu_clock/clock,nil,pokey_update_internal,true,self.number);
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
	poly_init_4_5(@self.poly4[0], 4);
	poly_init_4_5(@self.poly5[0], 5);

	// initialize 9 / 17 arrays */
	poly_init_9_17(@self.poly9[0],   9);
	poly_init_9_17(@self.poly17[0], 17);

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
	// determine which address was changed
	case (offset and $f) of
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
    self.clock_cnt[CLK_1]:=0;
    clock_triggered[CLK_1]:=1;
		for clk:=1 to 2 do begin
			self.clock_cnt[clk]:=self.clock_cnt[clk]+1;
			if (self.clock_cnt[clk]>=clock_divisors[clk]) then begin
				self.clock_cnt[clk]:=0;
				clock_triggered[clk]:=1;
			end;
    end;
		Inc(self.p4);if self.p4=$0000f then self.p4:=0;
		Inc(self.p5);if self.p5=$0001f then self.p5:=0;
		Inc(self.p9);if self.p9=$001ff then self.p9:=0;
		Inc(self.p17);if self.p17=$1ffff then self.p17:=0;
    if (self.AUDCTL and CH1_HICLK)<>0 then begin
      if (clock_triggered[CLK_1]<>0) then begin
        if (self.AUDCTL and CH12_JOINED)<>0 then self.channel[CHAN1].inc_chan(self.number,self.IRQEN,DIVADD_HICLK_JOINED)
          else self.channel[CHAN1].inc_chan(self.number,self.IRQEN,DIVADD_HICLK);
      end;
    end else if (clock_triggered[base_clock]<>0) then self.channel[CHAN1].inc_chan(self.number,self.IRQEN,DIVADD_LOCLK);
    if (self.AUDCTL and CH3_HICLK)<>0 then begin
      if (clock_triggered[CLK_1]<>0) then begin
        if (self.AUDCTL and CH34_JOINED)<>0 then self.channel[CHAN3].inc_chan(self.number,self.IRQEN,DIVADD_HICLK_JOINED)
          else self.channel[CHAN3].inc_chan(self.number,self.IRQEN,DIVADD_HICLK);
      end;
    end else if (clock_triggered[base_clock]<>0) then self.channel[CHAN3].inc_chan(self.number,self.IRQEN,DIVADD_LOCLK);
    if (clock_triggered[base_clock]<>0) then begin
      if (self.AUDCTL and CH12_JOINED)=0 then self.channel[CHAN2].inc_chan(self.number,self.IRQEN,DIVADD_LOCLK);
      if (self.AUDCTL and CH34_JOINED)=0 then self.channel[CHAN4].inc_chan(self.number,self.IRQEN,DIVADD_LOCLK);
    end;
		// Potentiometer handling */
		if (((clock_triggered[CLK_114]<>0) or ((self.SKCTL and SK_PADDLE)<>0)) and (self.pot_counter<228)) then self.step_pot;
		// Keyboard */
		//if ((clock_triggered[CLK_114]<>0) and ((self.SKCTL and SK_KEYSCAN)<>0)) then self.step_keyboard;
	end;
  // Match the borrow propagation and filter sampling order: 3, 4, 1, 2.
	if (self.channel[CHAN3].check_borrow) then begin
		isJoined:=(self.AUDCTL and CH34_JOINED)<>0;
		if isJoined then self.channel[CHAN4].inc_chan(self.number,self.IRQEN,DIVADD_LOCLK)
		  else self.channel[CHAN3].reset_channel(true);
		self.process_channel(CHAN3);
		// is this a filtering channel (3/4) and is the filter active? */
		if (self.AUDCTL and CH1_FILTER)<>0 then self.channel[CHAN1].sample
      else self.channel[CHAN1].filter_sample:=1;
	end;
	if (self.channel[CHAN4].check_borrow) then begin
    // IRQ enable is sampled when the borrow arrives, not at underflow.
    if (self.IRQEN and self.channel[CHAN4].INTMask)<>0 then
      synchronize(SYNC_SET_IRQST,self.channel[CHAN4].INTMask,self.number);
		isJoined:=(self.AUDCTL and CH34_JOINED)<>0;
		if isJoined then self.channel[CHAN3].reset_channel(true);
		self.channel[CHAN4].reset_channel(true);
		self.process_channel(CHAN4);
		// is this a filtering channel (3/4) and is the filter active? */
		if ((self.AUDCTL and CH2_FILTER)<>0) then self.channel[CHAN2].sample
		  else self.channel[CHAN2].filter_sample:=1;
		if (((self.IRQST and IRQ_TIMR4)<>0) and (@self.irq_f<>nil)) then self.irq_f(IRQ_TIMR4);
	end;
	if (self.channel[CHAN1].check_borrow) then begin
    // IRQ enable is sampled when the borrow arrives, not at underflow.
    if (self.IRQEN and self.channel[CHAN1].INTMask)<>0 then
      synchronize(SYNC_SET_IRQST,self.channel[CHAN1].INTMask,self.number);
		isJoined:=(self.AUDCTL and CH12_JOINED)<>0;
		if isJoined then self.channel[CHAN2].inc_chan(self.number,self.IRQEN,DIVADD_LOCLK)
		  else self.channel[CHAN1].reset_channel(true);
		self.process_channel(CHAN1);
		// check if some of the requested timer interrupts are enabled */
		if (((self.IRQST and IRQ_TIMR1)<>0) and (@self.irq_f<>nil)) then self.irq_f(IRQ_TIMR1);
	end;
	if (self.channel[CHAN2].check_borrow) then begin
    // IRQ enable is sampled when the borrow arrives, not at underflow.
    if (self.IRQEN and self.channel[CHAN2].INTMask)<>0 then
      synchronize(SYNC_SET_IRQST,self.channel[CHAN2].INTMask,self.number);
		isJoined:=(self.AUDCTL and CH12_JOINED)<>0;
		if isJoined then self.channel[CHAN1].reset_channel(true);
    self.channel[CHAN2].reset_channel(true);
		self.process_channel(CHAN2);
		// check if some of the requested timer interrupts are enabled */
		if (((self.IRQST and IRQ_TIMR2)<>0) and (@self.irq_f<>nil)) then self.irq_f(IRQ_TIMR2);
	end;
	for ch:=0 to 3 do
    if (((self.channel[ch].output_ xor self.channel[ch].filter_sample)<>0) or ((self.channel[ch].AUDC and VOLUME_ONLY)<>0)) then
      sum:=sum or ((self.channel[ch].AUDC and VOLUME_MASK) shl (ch*4));
      //else sum:= sum or (0 shl (ch*4))
  self.output_:=sum;
  // The physical reload precedes the borrow/IRQ event by one chip cycle.
  for ch:=0 to 3 do self.channel[ch].AUDF_latched:=self.channel[ch].AUDF;
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

procedure pokey_chip.set_external_clock(enabled:boolean);
begin
  self.external_clock:=enabled;
  // Disable the automatic source, avoiding two POKEY clocks per CPU cycle.
  timers.enabled(self.clock_timer,not enabled);
end;

procedure pokey_chip.clock;
begin
  if not self.external_clock then exit;
  self.step_one_clock;
  self.update_internal;
end;

procedure pokey_chip.set_resampling(enabled:boolean);
var
  i,total:integer;
  x,fc,h,coefficient_sum:double;
  weights:array[0..511]of double;
begin
  self.resample_enabled:=enabled;
  self.resample_phase:=0;
  self.resample_pos:=0;
  self.resample_read:=0;
  self.resample_write:=0;
  self.resample_count:=0;
  self.resample_hold:=0;
  FillChar(self.resample_history,SizeOf(self.resample_history),0);
  FillChar(self.resample_queue,SizeOf(self.resample_queue),0);
  if not enabled then exit;
  // Hamming-windowed low pass at the chip clock, before decimation.
  // 512 taps, 18 kHz cutoff at the 5200 clock. Coefficients sum to 32768.
  fc:=Min(18000.0,FREQ_BASE_AUDIO*0.4081632653)/self.resample_clock;
  coefficient_sum:=0;
  for i:=0 to 511 do begin
    x:=i-255.5;
    h:=Sin(2*Pi*fc*x)/(Pi*x);
    weights[i]:=h*(0.54-0.46*Cos(2*Pi*i/511));
    coefficient_sum:=coefficient_sum+weights[i];
  end;
  total:=0;
  for i:=0 to 511 do begin
    self.resample_coeff[i]:=Round(weights[i]*32768/coefficient_sum);
    Inc(total,self.resample_coeff[i]);
  end;
  Inc(self.resample_coeff[255],32768-total);
  // Keep the original quantized coefficients exactly, including the DC fix.
  // Symmetric pairs share one multiply; only unequal pairs need a correction.
  self.resample_delta_count:=0;
  for i:=0 to 255 do
    if self.resample_coeff[511-i]<>self.resample_coeff[i] then begin
      self.resample_delta_index[self.resample_delta_count]:=i;
      self.resample_delta[self.resample_delta_count]:=integer(self.resample_coeff[511-i])-self.resample_coeff[i];
      Inc(self.resample_delta_count);
    end;
end;

procedure pokey_chip.resample_tick(value:integer);
var
  i,near_pos,far_pos,sample_value:integer;
  sum:int64;
begin
  self.resample_history[self.resample_pos]:=value;
  self.resample_history[self.resample_pos+512]:=value;
  self.resample_phase:=self.resample_phase+FREQ_BASE_AUDIO;
  if self.resample_phase>=self.resample_clock then begin
    self.resample_phase:=self.resample_phase-self.resample_clock;
    sum:=0;
    near_pos:=self.resample_pos+512;
    far_pos:=self.resample_pos+1;
    for i:=0 to 255 do
      sum:=sum+int64(integer(self.resample_history[near_pos-i])+self.resample_history[far_pos+i])*self.resample_coeff[i];
    for i:=0 to self.resample_delta_count-1 do
      sum:=sum+int64(self.resample_history[far_pos+self.resample_delta_index[i]])*self.resample_delta[i];
    sample_value:=Round(sum/32768.0);
    if sample_value>32767 then sample_value:=32767
      else if sample_value< -32768 then sample_value:=-32768;
    // Normal CPU/DMA batches produce only a few PCM samples at a time.
    if self.resample_count=256 then begin
      self.resample_read:=(self.resample_read+1) and 255;
      Dec(self.resample_count);
    end;
    self.resample_queue[self.resample_write]:=sample_value;
    self.resample_write:=(self.resample_write+1) and 255;
    Inc(self.resample_count);
  end;
  self.resample_pos:=(self.resample_pos+1) and 511;
end;

procedure pokey_chip.update;
var
  value:integer;
begin
  value:=self.output_;
  if self.resample_enabled then begin
    if self.resample_count<>0 then begin
      self.resample_hold:=self.resample_queue[self.resample_read];
      self.resample_read:=(self.resample_read+1) and 255;
      Dec(self.resample_count);
    end;
    value:=self.resample_hold;
  end;
  tsample[self.tsample_num,sound_status.posicion_sonido]:=value;
  if sound_status.stereo then tsample[self.tsample_num,sound_status.posicion_sonido+1]:=value;
end;

end.

