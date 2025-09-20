unit mos6526;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}dialogs,sysutils,cpu_misc,main_engine;

type
  registros=packed record
    pra,prb,ddra,ddrb:byte;
	  ta,tb:word;
	  latcha,latchb: word;
	  tod_10ths,tod_sec,tod_min,tod_hr:byte;
    alm_10ths,alm_sec,alm_min,alm_hr:byte;
	  sdr, icr,cra,crb,int_mask:byte;
	  tod_halt,ta_cnt_phi2,tb_cnt_phi2,tb_cnt_ta:boolean;
	  tod_divider:integer;
  end;
  mos6526_chip=class
      constructor create(clock:dword);
      destructor free;
    public
      reg1,reg2:registros;
      Joystick1,Joystick2:byte;
      procedure reset;
      procedure EmulateLine1(cycles:byte);
      procedure EmulateLine2(cycles:byte);
      function read1(direccion:byte):byte;
      procedure write1(direccion,valor:byte);
      function read2(direccion:byte):byte;
      procedure write2(direccion,valor:byte);
      procedure change_calls(pa_read,pb_read:cpu_inport_call;pa_write,pb_write,irq_call1,irq_call2:cpu_outport_call);
      procedure flag_w(valor:byte);
      procedure CountTOD1;
      procedure CountTOD2;
    private
      clock:dword;
      flag,prev_lp:byte;
      irq_call1,irq_call2:cpu_outport_call;
      pa_read,pb_read:cpu_inport_call;
      pa_write,pb_write:cpu_outport_call;
      procedure TriggerInterrupt1(bit:byte);
      procedure TriggerInterrupt2(bit:byte);
  end;

var
  mos6526_0,mos6526_1:mos6526_chip;

implementation
uses commodore64,mos6566;

constructor mos6526_chip.create(clock:dword);
begin
  self.clock:=clock;
end;

destructor mos6526_chip.free;
begin
end;

procedure mos6526_chip.change_calls(pa_read,pb_read:cpu_inport_call;pa_write,pb_write,irq_call1,irq_call2:cpu_outport_call);
begin
  self.pa_read:=pa_read;
  self.pb_read:=pb_read;
  self.pa_write:=pa_write;
  self.pb_write:=pb_write;
  self.irq_call1:=irq_call1;
  self.irq_call2:=irq_call2;
end;

procedure mos6526_chip.reset;
begin
  //CIA1
  self.reg1.pra:=0;
  self.reg1.prb:=0;
  self.reg1.ddra:=0;
  self.reg1.ddrb:=0;
	self.reg1.ta:=$ffff;
  self.reg1.tb:=$ffff;
	self.reg1.latcha:=1;
  self.reg1.latchb:=1;
	self.reg1.tod_10ths:=0;
  self.reg1.tod_sec:=0;
  self.reg1.tod_min:=0;
  self.reg1.tod_hr:=0;
	self.reg1.alm_10ths:=0;
  self.reg1.alm_sec:=0;
  self.reg1.alm_min:=0;
  self.reg1.alm_hr:=0;
	self.reg1.sdr:=0;
  self.reg1.icr:=0;
  self.reg1.cra:=0;
  self.reg1.crb:=0;
  self.reg1.int_mask:=0;
	self.reg1.tod_halt:=false;
  self.reg1.ta_cnt_phi2:=false;
  self.reg1.tb_cnt_phi2:=false;
  self.reg1.tb_cnt_ta:=false;
	self.reg1.tod_divider:=0;
	self.Joystick1:=$ff;
  self.Joystick2:=$ff;
	self.prev_lp:=$10;
  //CIA2
  self.reg2.pra:=0;
  self.reg2.prb:=0;
  self.reg2.ddra:=0;
  self.reg2.ddrb:=0;
	self.reg2.ta:=$ffff;
  self.reg2.tb:=$ffff;
	self.reg2.latcha:=1;
  self.reg2.latchb:=1;
	self.reg2.tod_10ths:=0;
  self.reg2.tod_sec:=0;
  self.reg2.tod_min:=0;
  self.reg2.tod_hr:=0;
	self.reg2.alm_10ths:=0;
  self.reg2.alm_sec:=0;
  self.reg2.alm_min:=0;
  self.reg2.alm_hr:=0;
	self.reg2.sdr:=0;
  self.reg2.icr:=0;
  self.reg2.cra:=0;
  self.reg2.crb:=0;
  self.reg2.int_mask:=0;
	self.reg2.tod_halt:=false;
  self.reg2.ta_cnt_phi2:=false;
  self.reg2.tb_cnt_phi2:=false;
  self.reg2.tb_cnt_ta:=false;
	self.reg2.tod_divider:=0;
	// VA14/15 = 0
  mos6566_0.ChangedVA(0);
	// IEC
	//self.IECLines:=$d0;
  self.flag:=1;
end;

procedure mos6526_chip.TriggerInterrupt1(bit:byte);
begin
	self.reg1.icr:=self.reg1.icr or bit;
	if (self.reg1.int_mask and bit)<>0 then begin
		self.reg1.icr:=self.reg1.icr or $80;
		self.irq_call1(ASSERT_LINE);
  end;
end;


procedure mos6526_chip.TriggerInterrupt2(bit:byte);

begin
	self.reg2.icr:=self.reg2.icr or bit;
	if (self.reg2.int_mask and bit)<>0 then begin
		self.reg2.icr:=self.reg2.icr or $80;
		self.irq_call2(ASSERT_LINE);
  end;
end;

function mos6526_chip.read1(direccion:byte):byte;
var
  ret,tst:byte;
begin
ret:=$ff;
case direccion of
		$00:begin
          ret:=self.reg1.pra or not(self.reg1.ddra);
          tst:=(self.reg1.prb or not(self.reg1.ddrb)) and self.Joystick1;
          //Columnas
          if ((tst and $01)=0) then ret:=ret and c64_keyboard_i[0];
          if ((tst and $02)=0) then ret:=ret and c64_keyboard_i[1];
			    if ((tst and $04)=0) then ret:=ret and c64_keyboard_i[2];
			    if ((tst and $08)=0) then ret:=ret and c64_keyboard_i[3];
			    if ((tst and $10)=0) then ret:=ret and c64_keyboard_i[4];
			    if ((tst and $20)=0) then ret:=ret and c64_keyboard_i[5];
			    if ((tst and $40)=0) then ret:=ret and c64_keyboard_i[6];
			    if ((tst and $80)=0) then ret:=ret and c64_keyboard_i[7];
          ret:=ret and self.Joystick2;
        end;
		$01:begin
			    ret:=not(self.reg1.ddrb);
          tst:=(self.reg1.pra or not(self.reg1.ddra)) and self.Joystick2;
          //Filas
			    if ((tst and $01)=0) then ret:=ret and c64_keyboard[0];
          if ((tst and $02)=0) then ret:=ret and c64_keyboard[1];
			    if ((tst and $04)=0) then ret:=ret and c64_keyboard[2];
			    if ((tst and $08)=0) then ret:=ret and c64_keyboard[3];
			    if ((tst and $10)=0) then ret:=ret and c64_keyboard[4];
			    if ((tst and $20)=0) then ret:=ret and c64_keyboard[5];
			    if ((tst and $40)=0) then ret:=ret and c64_keyboard[6];
			    if ((tst and $80)=0) then ret:=ret and c64_keyboard[7];
			    ret:=(ret or (self.reg1.prb and self.reg1.ddrb)) and self.Joystick1;
        end;
		$02:ret:=self.reg1.ddra;
		$03:ret:=self.reg1.ddrb;
		$04:ret:=self.reg1.ta and $ff;
		$05:ret:=self.reg1.ta shr 8;
		$06:ret:=self.reg1.tb and $ff;
		$07:ret:=self.reg1.tb shr 8;
		$08:begin
           self.reg1.tod_halt:=false;
           ret:=self.reg1.tod_10ths;
        end;
		$09:ret:=self.reg1.tod_sec;
		$0a:ret:=self.reg1.tod_min;
		$0b:begin
          self.reg1.tod_halt:=true;
          ret:=self.reg1.tod_hr;
        end;
		$0c:ret:=self.reg1.sdr;
		$0d:begin
			    ret:=self.reg1.icr;		// Read and clear ICR
			    self.reg1.icr:=0;
          self.irq_call1(CLEAR_LINE);
		    end;
		$0e:ret:=self.reg1.cra;
		$0f:ret:=self.reg1.crb;
  end;
read1:=ret;
end;

procedure mos6526_chip.write1(direccion,valor:byte);
begin
case direccion of
		$00:self.reg1.pra:=valor;
		$01:begin
			    self.reg1.prb:=valor;
			    //check_lp();
			  end;
		$02:self.reg1.ddra:=valor;
		$03:begin
			    self.reg1.ddrb:=valor;
			    //check_lp();
			  end;
		$04:self.reg1.latcha:=(self.reg1.latcha and $ff00) or valor;
		$05:begin
			    self.reg1.latcha:=(self.reg1.latcha and $ff) or (valor shl 8);
			    if ((self.reg1.cra and 1)=0) then self.reg1.ta:=self.reg1.latcha;	// Reload timer if stopped
        end;
		$06:self.reg1.latchb:=(self.reg1.latchb and $ff00) or valor;
		$07:begin
			    self.reg1.latchb:=(self.reg1.latchb and $ff) or (valor shl 8);
			    if ((self.reg1.crb and 1)=0) then self.reg1.tb:=self.reg1.latchb;	// Reload timer if stopped
				end;
		$08:if (self.reg1.crb and $80)<>0 then self.reg1.alm_10ths:=valor and $0f
			    else self.reg1.tod_10ths:=valor and $f;
		$09:if (self.reg1.crb and $80)<>0 then self.reg1.alm_sec:=valor and $7f
			    else self.reg1.tod_sec:=valor and $7f;
		$0a:if (self.reg1.crb and $80)<>0 then self.reg1.alm_min:=valor and $7f
			    else self.reg1.tod_min:=valor and $7f;
		$0b:if (self.reg1.crb and $80)<>0 then self.reg1.alm_hr:=valor and $9f
			    else self.reg1.tod_hr:=valor and $9f;
		$0c:begin
			    self.reg1.sdr:=valor;
			    self.TriggerInterrupt1(8);	// Fake SDR interrupt for programs that need it
        end;
		$0d:begin
          if (valor and $80)<>0 then self.reg1.int_mask:=self.reg1.int_mask or (valor and $1f)
            else self.reg1.int_mask:=self.reg1.int_mask and not(valor);
          if (self.reg1.icr and self.reg1.int_mask and $1f)<>0 then begin // Trigger IRQ if pending
					  self.reg1.icr:=self.reg1.icr or $80;
					  self.irq_call1(ASSERT_LINE);
          end;
        end;
		$0e:begin
			    self.reg1.cra:=valor and $ef;
			    if (valor and $10)<>0 then self.reg1.ta:=self.reg1.latcha; // Force load
			    self.reg1.ta_cnt_phi2:=((valor and $21)=$01);
        end;
		$0f:begin
			    self.reg1.crb:=valor and $ef;
			    if (valor and $10)<>0 then self.reg1.tb:=self.reg1.latchb; // Force load
			    self.reg1.tb_cnt_phi2:=((valor and $61)=$01);
			    self.reg1.tb_cnt_ta:=((valor and $61)=$41);
			  end;
  end;
end;

function mos6526_chip.read2(direccion:byte):byte;
var
  ret:byte;
begin
  ret:=$ff;
case direccion of
		$00:ret:=(self.reg2.pra or not(self.reg2.ddra)) and $3f; // or IECLines & the_cpu_1541->IECLines;
		$01:ret:=self.reg2.prb or not(self.reg2.ddrb);
		$02:ret:=self.reg2.ddra;
		$03:ret:=self.reg2.ddrb;
		$04:ret:=self.reg2.ta and $ff;
		$05:ret:=self.reg2.ta shr 8;
		$06:ret:=self.reg2.tb and $ff;
		$07:ret:=self.reg2.tb shr 8;
		$08:begin
          self.reg2.tod_halt:=false;
          ret:=self.reg2.tod_10ths;
        end;
		$09:ret:=self.reg2.tod_sec;
		$0a:ret:=self.reg2.tod_min;
		$0b:begin
          self.reg2.tod_halt:=true;
          ret:=self.reg2.tod_hr;
        end;
		$0c:ret:=self.reg2.sdr;
		$0d:begin
			    ret:=self.reg2.icr;		// Read and clear ICR
			    self.reg2.icr:=0;
			    self.irq_call2(CLEAR_LINE);	// Clear NMI
		    end;
		$0e:ret:=self.reg2.cra;
		$0f:ret:=self.reg2.crb;
	end;
  read2:=ret;
end;

procedure mos6526_chip.write2(direccion,valor:byte);
begin
  case direccion of
		$00:begin
			    self.reg2.pra:=valor;
			    valor:=not(self.reg2.pra) and self.reg2.ddra;
			    mos6566_0.ChangedVA(valor and 3);
			    //uint8 old_lines = IECLines;
			    //IECLines = (byte << 2) & 0x80	// DATA
				  //  | (byte << 2) & 0x40		// CLK
				  //  | (byte << 1) & 0x10;		// ATN
			    //if ((IECLines ^ old_lines) & 0x10) {	// ATN changed
				  //  the_cpu_1541->NewATNState();
				  //  if (old_lines & 0x10)				// ATN 1->0
          //  the_cpu_1541->IECInterrupt();
			    //}
        end;
		$01:self.reg2.prb:=valor;
		$02:begin
			    self.reg2.ddra:=valor;
          valor:=not(self.reg2.pra) and self.reg2.ddra;
          mos6566_0.ChangedVA(valor and 3);
			    //mos6566_0.ChangedVA(not(self.reg2.pra or not(self.reg2.ddra)) and 3);
			  end;
		$03:self.reg2.ddrb:=valor;
		$04:self.reg2.latcha:=(self.reg2.latcha and $ff00) or valor;
		$05:begin
			    self.reg2.latcha:=(self.reg2.latcha and $ff) or (valor shl 8);
			    if ((self.reg2.cra and 1)=0) then self.reg2.ta:=self.reg2.latcha;	// Reload timer if stopped
        end;
		$06:self.reg2.latchb:=(self.reg2.latchb and $ff00) or valor;
		$07:begin
			    self.reg2.latchb:=(self.reg2.latchb and $ff) or (valor shl 8);
			    if ((self.reg2.crb and 1)=0) then self.reg2.tb:=self.reg2.latchb;	// Reload timer if stopped
        end;
		$08:if (self.reg2.crb and $80)<>0 then self.reg2.alm_10ths:=valor and $0f
			    else self.reg2.tod_10ths:=valor and $0f;
		$09:if (self.reg2.crb and $80)<>0 then self.reg2.alm_sec:=valor and $7f
			    else self.reg2.tod_sec:=valor and $7f;
		$0a:if (self.reg2.crb and $80)<>0 then self.reg2.alm_min:=valor and $7f
			    else self.reg2.tod_min:=valor and $7f;
		$0b:if (self.reg2.crb and $80)<>0 then self.reg2.alm_hr:=valor and $9f
			    else self.reg2.tod_hr:=valor and $9f;
		$0c:begin
			    self.reg2.sdr:=valor;
			    self.TriggerInterrupt2(8);	// Fake SDR interrupt for programs that need it
        end;
		$0d:begin
          if (valor and $80)<>0 then self.reg2.int_mask:=self.reg2.int_mask or (valor and $1f)
            else self.reg2.int_mask:=self.reg2.int_mask and not(valor);
          if (self.reg2.icr and self.reg2.int_mask and $1f)<>0 then begin // Trigger NMI if pending
					  self.reg2.icr:=self.reg2.icr or $80;
            self.irq_call2(ASSERT_LINE);
          end;
        end;
		$0e:begin
			    self.reg2.cra:=valor and $ef;
			    if (valor and $10)<>0 then self.reg2.ta:=self.reg2.latcha; // Force load
			    self.reg2.ta_cnt_phi2:=((valor and $21)=$01);
        end;
    $0f:begin
			    self.reg2.crb:=valor and $ef;
          if (valor and $10)<>0 then self.reg2.tb:=self.reg2.latchb; // Force load
			    self.reg2.tb_cnt_phi2:=((valor and $61)=$01);
			    self.reg2.tb_cnt_ta:=((valor and $61)=$41);
			  end;
  end;
end;

procedure mos6526_chip.flag_w(valor:byte);
begin
	if (self.flag<>valor) then begin
    self.TriggerInterrupt1($10);
    self.flag:=valor;
  end;
end;

procedure mos6526_chip.CountTOD1;
var
	lo,hi:byte;
begin
	// Decrement frequency divider
	if (self.reg1.tod_divider<>0) then self.reg1.tod_divider:=self.reg1.tod_divider-1
	else begin
		// Reload divider according to 50/60 Hz flag
		if (self.reg1.cra and $80)<>0 then self.reg1.tod_divider:=4
		  else self.reg1.tod_divider:=5;
		// 1/10 seconds
		self.reg1.tod_10ths:=self.reg1.tod_10ths+1;
		if (self.reg1.tod_10ths>9) then begin
			self.reg1.tod_10ths:=0;
			// Seconds
			lo:=(self.reg1.tod_sec and $0f)+1;
			hi:= self.reg1.tod_sec shr 4;
			if (lo>9) then begin
				lo:=0;
				hi:=hi+1;
			end;
			if (hi>5) then begin
        self.reg1.tod_sec:=0;
				// Minutes
				lo:=(self.reg1.tod_min and $0f)+1;
				hi:=self.reg1.tod_min shr 4;
				if (lo>9) then begin
					lo:=0;
					hi:=hi+1;
				end;
				if (hi>5) then begin
					self.reg1.tod_min:=0;
					// Hours
					lo:=(self.reg1.tod_hr and $0f)+1;
					hi:=(self.reg1.tod_hr shr 4) and 1;
					self.reg1.tod_hr:=self.reg1.tod_hr and $80;		// Keep AM/PM flag
					if (lo>9) then begin
						lo:=0;
						hi:=hi+1;
					end;
					self.reg1.tod_hr:=self.reg1.tod_hr or ((hi shl 4) or lo);
					if ((self.reg1.tod_hr and $1f) > $11) then self.reg1.tod_hr:=self.reg1.tod_hr and $80 xor $80;
				end else self.reg1.tod_min:=(hi shl 4) or lo;
			end else self.reg1.tod_sec:=(hi shl 4) or lo;
    end;
		// Alarm time reached? Trigger interrupt if enabled
		if ((self.reg1.tod_10ths=self.reg1.alm_10ths) and (self.reg1.tod_sec=self.reg1.alm_sec)
      and (self.reg1.tod_min=self.reg1.alm_min) and (self.reg1.tod_hr=self.reg1.alm_hr)) then
			self.TriggerInterrupt1(4);
	end;
end;

procedure mos6526_chip.EmulateLine1(cycles:byte);
var
  tmp:integer;
begin
	// Timer A
	if self.reg1.ta_cnt_phi2 then begin
    tmp:=self.reg1.ta-cycles;		// Decrement timer
    self.reg1.ta:=self.reg1.ta-cycles;
		if (tmp<0) then begin			// Underflow?
			self.reg1.ta:=self.reg1.ta+self.reg1.latcha;			// Reload timer
			if (self.reg1.cra and 8)<>0 then begin			// One-shot?
				self.reg1.cra:=self.reg1.cra and $fe;
				self.reg1.ta_cnt_phi2:=false;
      end;
			self.TriggerInterrupt1(1);
			if (self.reg1.tb_cnt_ta) then begin		// Timer B counting underflows of Timer A?
        tmp:=self.reg1.tb-1;	// tmp = --tb doesn't work
				self.reg1.tb:=self.reg1.tb-1;
				if (tmp<0) then begin
          self.reg1.tb:=self.reg1.latchb;
			      if (self.reg1.crb and 8)<>0 then begin			// One-shot?
				      self.reg1.crb:=self.reg1.crb and $fe;
				      self.reg1.tb_cnt_phi2:=false;
				      self.reg1.tb_cnt_ta:=false;
            end;
			      self.TriggerInterrupt1(2);
            exit;
        end;
      end;
    end;
  end;
	// Timer B
	if self.reg1.tb_cnt_phi2 then begin
    tmp:=self.reg1.tb-cycles;
		self.reg1.tb:=self.reg1.tb-cycles;		// Decrement timer
		if (tmp<0) then begin			// Underflow?
			self.reg1.tb:=self.reg1.tb+self.reg1.latchb;
			if (self.reg1.crb and 8)<>0 then begin			// One-shot?
				self.reg1.crb:=self.reg1.crb and $fe;
				self.reg1.tb_cnt_phi2:=false;
				self.reg1.tb_cnt_ta:=false;
      end;
			self.TriggerInterrupt1(2);
    end;
	end;
end;

procedure mos6526_chip.CountTOD2;
var
	lo,hi:byte;
begin
	// Decrement frequency divider
	if (self.reg2.tod_divider<>0) then self.reg2.tod_divider:=self.reg2.tod_divider-1
	else begin
		// Reload divider according to 50/60 Hz flag
		if (self.reg2.cra and $80)<>0 then self.reg2.tod_divider:=4
		  else self.reg2.tod_divider:=5;
		// 1/10 seconds
		self.reg2.tod_10ths:=self.reg2.tod_10ths+1;
		if (self.reg2.tod_10ths>9) then begin
			self.reg2.tod_10ths:=0;
			// Seconds
			lo:=(self.reg2.tod_sec and $0f)+1;
			hi:= self.reg2.tod_sec shr 4;
			if (lo>9) then begin
				lo:=0;
				hi:=hi+1;
			end;
			if (hi>5) then begin
        self.reg2.tod_sec:=0;
				// Minutes
				lo:=(self.reg2.tod_min and $0f)+1;
				hi:=self.reg2.tod_min shr 4;
				if (lo>9) then begin
					lo:=0;
					hi:=hi+1;
				end;
				if (hi>5) then begin
					self.reg2.tod_min:=0;
					// Hours
					lo:=(self.reg2.tod_hr and $0f)+1;
					hi:=(self.reg2.tod_hr shr 4) and 1;
					self.reg2.tod_hr:=self.reg2.tod_hr and $80;		// Keep AM/PM flag
					if (lo>9) then begin
						lo:=0;
						hi:=hi+1;
					end;
					self.reg2.tod_hr:=self.reg2.tod_hr or ((hi shl 4) or lo);
					if ((self.reg2.tod_hr and $1f) > $11) then self.reg2.tod_hr:=self.reg2.tod_hr and $80 xor $80;
				end else self.reg2.tod_min:=(hi shl 4) or lo;
			end else self.reg2.tod_sec:=(hi shl 4) or lo;
    end;
		// Alarm time reached? Trigger interrupt if enabled
		if ((self.reg2.tod_10ths=self.reg2.alm_10ths) and (self.reg2.tod_sec=self.reg2.alm_sec)
      and (self.reg2.tod_min=self.reg2.alm_min) and (self.reg2.tod_hr=self.reg2.alm_hr)) then
			self.TriggerInterrupt2(4);
	end;
end;

procedure mos6526_chip.EmulateLine2(cycles:byte);
var
  tmp:integer;
begin
	// Timer A
	if self.reg2.ta_cnt_phi2 then begin
    tmp:=self.reg2.ta-cycles;		// Decrement timer
    self.reg2.ta:=self.reg2.ta-cycles;
		if (tmp<0) then begin			// Underflow?
			self.reg2.ta:=self.reg2.ta+self.reg2.latcha;			// Reload timer
			if (self.reg2.cra and 8)<>0 then begin			// One-shot?
				self.reg2.cra:=self.reg2.cra and $fe;
				self.reg2.ta_cnt_phi2:=false;
      end;
			self.TriggerInterrupt2(1);
			if (self.reg2.tb_cnt_ta) then begin		// Timer B counting underflows of Timer A?
        tmp:=self.reg2.tb-1;	// tmp = --tb doesn't work
				self.reg2.tb:=self.reg2.tb-1;
				if (tmp<0) then begin
          self.reg2.tb:=self.reg2.latchb;
			      if (self.reg2.crb and 8)<>0 then begin			// One-shot?
				      self.reg2.crb:=self.reg2.crb and $fe;
				      self.reg2.tb_cnt_phi2:=false;
				      self.reg2.tb_cnt_ta:=false;
            end;
			      self.TriggerInterrupt2(2);
            exit;
        end;
      end;
    end;
  end;
	// Timer B
	if self.reg2.tb_cnt_phi2 then begin
    tmp:=self.reg2.tb-cycles;
		self.reg2.tb:=self.reg2.tb-cycles;		// Decrement timer
		if (tmp<0) then begin			// Underflow?
			self.reg2.tb:=self.reg2.tb+self.reg2.latchb;
			if (self.reg2.crb and 8)<>0 then begin			// One-shot?
				self.reg2.crb:=self.reg2.crb and $fe;
				self.reg2.tb_cnt_phi2:=false;
				self.reg2.tb_cnt_ta:=false;
      end;
			self.TriggerInterrupt2(2);
    end;
	end;
end;

end.
