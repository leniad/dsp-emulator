unit mos6526;
//{$DEFINE DEBUG}
interface
uses dialogs,sysutils,cpu_misc,main_engine;

type
  mos6526_chip=class
      constructor create(clock:dword);
      destructor free;
    public
      tod_clock:word;
      pa,pb,pra,prb:byte;
      joystick1,joystick2:byte;
      procedure reset;
      function read(direccion:byte):byte;
      procedure write(direccion,valor:byte);
      procedure change_calls(pa_read,pb_read:cpu_inport_call;pa_write,pb_write,irq_call:cpu_outport_call);
      procedure sync(frame:word);
      procedure flag_w(valor:byte);
      procedure clock_tod;
      function port_a_pins:byte;
      function port_b_pins:byte;
    private
      clock:dword;
      tod_stopped,irq,icr_read:boolean;
      flag,ta_pb6,tb_pb7,cra,crb,ddra,ddrb,pa_in,pb_in,imr,icr:byte;
      alarm,tod,tod_latch:dword;
      tod_latched:boolean;
      ta_latch,tb_latch,ta,tb:word;
      tod_count,bits,ta_out,tb_out,ir0,ir1,load_a0,load_a1,load_a2,load_b0,load_b1,load_b2,pc:integer;
	    count_a0,count_a1,count_a2,count_a3,oneshot_a0,count_b0,count_b1,count_b2,count_b3,oneshot_b0,cnt:integer;
      pa_read,pb_read:cpu_inport_call;
      pa_write,pb_write:cpu_outport_call;
      irq_call:cpu_outport_call;
      procedure write_tod(offset,data:byte);
      procedure set_cra(data:byte);
      procedure set_crb(data:byte);
      procedure update_pa;
      procedure update_pb;
      procedure clock_ta;
      procedure clock_tb;
      procedure serial_output;
      procedure update_interrupt;
      procedure clock_pipeline;
  end;

var
  mos6526_0,mos6526_1:mos6526_chip;

implementation
const
  PRA_=0;
	PRB_=1;
	DDRA_=2;
	DDRB_=3;
	TA_LO_=4;
	TA_HI_=5;
	TB_LO_=6;
	TB_HI_=7;
	TOD_10THS=8;
	TOD_SEC=9;
	TOD_MIN=$A;
	TOD_HR=$B;
	SDR_=$C;
	ICR_=$D;
  IMR_=ICR_;
	CRA_=$E;
	CRB_=$F;
  ICR_TA=$01;
  ICR_TB=$02;
  ICR_ALARM=$04;
  ICR_SP=$08;
  ICR_FLAG=$10;
  CRA_INMODE_PHI2=0;
	CRA_INMODE_CNT=1;
  CRB_INMODE_PHI2=0;
	CRB_INMODE_CNT=1;
	CRB_INMODE_TA=2;
	CRB_INMODE_CNT_TA=3;

constructor mos6526_chip.create(clock:dword);
begin
  self.clock:=clock;
end;

destructor mos6526_chip.free;
begin
end;

procedure mos6526_chip.change_calls(pa_read,pb_read:cpu_inport_call;pa_write,pb_write,irq_call:cpu_outport_call);
begin
  self.pa_read:=pa_read;
  self.pb_read:=pb_read;
  self.pa_write:=pa_write;
  self.pb_write:=pb_write;
  self.irq_call:=irq_call;
end;

procedure mos6526_chip.reset;
begin
  self.tod_stopped:=true;
  self.tod_latched:=false;self.tod_latch:=0;self.tod_count:=0;
  self.joystick1:=$ff;self.joystick2:=$ff;
  self.cra:=0;
  self.crb:=0;
  self.alarm:=0;
  self.tod:=$01000000;
  self.ta_pb6:=0;
  self.tb_pb7:=0;
  self.ta_out:=0;
	self.tb_out:=0;
  self.pra:=0;
	self.prb:=0;
	self.ddra:=0;
	self.ddrb:=0;
  self.pa:=$ff;
	self.pb:=$ff;
  self.pa_in:=$ff;
  self.pb_in:=$ff;
  self.imr:=0;
  self.icr:=0;
  self.ir0:=0;
  self.ir1:=0;
  self.irq:=false;
  self.bits:=0;
  self.ta_latch:=$ffff;
  self.tb_latch:=$ffff;
  self.load_a0:=0;
  self.load_a1:=0;
  self.load_a2:=0;
  self.load_b0:=0;
  self.load_b1:=0;
  self.load_b2:=0;
  self.ta:=0;
  self.tb:=0;
  self.pc:=1;
  self.count_a0:=0;
  self.count_a1:=0;
  self.count_a2:=0;
  self.count_a3:=0;
  self.oneshot_a0:=0;
  self.count_b0:=0;
  self.count_b1:=0;
  self.count_b2:=0;
  self.count_b3:=0;
  self.oneshot_b0:=0;
  self.icr_read:=false;
  self.cnt:=1;
  self.flag:=1;
  if Assigned(self.irq_call) then self.irq_call(CLEAR_LINE);
  self.update_pa;self.update_pb;
end;

procedure mos6526_chip.sync(frame:word);
var
  f:word;
begin
  for f:=1 to frame do begin
    if (self.pc=0) then begin
  		self.pc:=1;
      //MessageDlg('writepc', mtInformation,[mbOk], 0);
  		//self.write_pc(self.pc);
  	end;
  	self.clock_ta;
  	self.serial_output;
  	self.clock_tb;
  	self.update_pb;
  	self.update_interrupt;
  	self.clock_pipeline;
  end;
end;

procedure mos6526_chip.clock_ta;
begin
	if (self.count_a3<>0) then self.ta:=self.ta-1;
	self.ta_out:=byte((self.count_a2<>0) and (self.ta=0));
	if (self.ta_out<>0) then begin
		self.ta_pb6:=not(self.ta_pb6);
		if (((self.cra and 8)<>0) or (self.oneshot_a0<>0)) then begin
			self.cra:=self.cra and $fe;
			self.count_a0:=0;
      self.count_a1:=0;
      self.count_a2:=0;
    end;
		self.load_a1:=1;
	end;
	if (self.load_a1<>0) then begin
		self.count_a2:=0;
		self.ta:=self.ta_latch;
	end;
end;

procedure mos6526_chip.clock_tb;
begin
	if (self.count_b3<>0) then self.tb:=self.tb-1;
	self.tb_out:=byte((self.count_b2<>0) and (self.tb=0));
	if (self.tb_out<>0) then begin
		self.tb_pb7:=not(self.tb_pb7);
		if (((self.crb and 8)<>0) or (self.oneshot_b0<>0)) then begin
			self.crb:=self.crb and $fe;
			self.count_b0:=0;
      self.count_b1:=0;
      self.count_b2:=0;
		end;
		self.load_b1:=1;
	end;
	if (self.load_b1<>0) then begin
		self.count_b2:=0;
    self.tb:=self.tb_latch;
	end;
end;

procedure mos6526_chip.serial_output;
begin
	//if ((self.ta_out<>0) and ((self.cra and $40)<>0)) then MessageDlg('serial write', mtInformation,[mbOk], 0);
end;

procedure mos6526_chip.update_interrupt;
begin
	if (not(self.irq) and (self.ir1<>0)) then begin
		if addr(self.irq_call)<>nil then self.irq_call(ASSERT_LINE);
		self.irq:=true;
	end;
	if (self.ta_out<>0) then self.icr:=self.icr or ICR_TA;
	if ((self.tb_out<>0) and not(self.icr_read)) then self.icr:=self.icr or ICR_TB;
	self.icr_read:=false;
end;

procedure mos6526_chip.clock_pipeline;
begin
	// timer A pipeline
	self.count_a3:=self.count_a2;
	if ((self.cra and $20)=CRA_INMODE_PHI2) then self.count_a2:=1;
	self.count_a2:=self.count_a2 and (self.cra and 1);
	self.count_a1:=self.count_a0;
	self.count_a0:=0;
	self.load_a2:=self.load_a1;
	self.load_a1:=self.load_a0;
	self.load_a0:=(self.cra and $10) shr 4;
	self.cra:=self.cra and not($10);
	self.oneshot_a0:=(self.cra and 8) shr 3;
	// timer B pipeline
	self.count_b3:=self.count_b2;
	case ((self.crb and $60) shr 5) of
	  CRB_INMODE_PHI2:self.count_b2:=1;
	  CRB_INMODE_TA:self.count_b2:=self.ta_out;
	  CRB_INMODE_CNT_TA:self.count_b2:=byte((self.ta_out<>0) and (self.cnt<>0));
  end;
	self.count_b2:=self.count_b2 and (self.crb and 1);
	self.count_b1:=self.count_b0;
	self.count_b0:=0;
	self.load_b2:=self.load_b1;
	self.load_b1:=self.load_b0;
	self.load_b0:=(self.crb and $10) shr 4;
	self.crb:=self.crb and not($10);
	self.oneshot_b0:=(self.crb and 8) shr 3;
	// interrupt pipeline
	if (self.ir0<>0) then self.ir1:=1;
  if (self.icr and self.imr)<>0 then self.ir0:=1
    else self.ir0:=0;
end;

procedure mos6526_chip.update_pa;
var
  pa:byte;
begin
	pa:=self.port_a_pins;
	if (self.pa<>pa) then begin
		self.pa:=pa;
		if addr(self.pa_write)<>nil then self.pa_write(pa);
	end;
end;

procedure mos6526_chip.update_pb;
var
  pb,pb6,pb7:byte;
begin
	pb:=self.port_b_pins;
	if (self.cra and 2)<>0 then begin
		if (self.cra and 4)<>0 then pb6:=self.ta_pb6
      else pb6:=self.ta_out;
		pb:=pb and not($40);
		pb:=pb or (pb6 shl 6);
  end;
	if (self.crb and 2)<>0 then begin
		if (self.crb and 4)<>0 then pb7:=self.tb_pb7
      else pb7:=self.tb_out;
		pb:=pb and not($80);
		pb:=pb or (pb7 shl 7);
	end;
	if (self.pb<>pb) then begin
    if addr(self.pb_write)<>nil then self.pb_write(pb);
		self.pb:=pb;
	end;
end;

procedure mos6526_chip.write_tod(offset,data:byte);
var
  shift:byte;
begin
	shift:=8*offset;
	if (self.crb and $80)<>0 then self.alarm:=(self.alarm and not($ff shl shift)) or (dword(data) shl shift)
	  else self.tod:=(self.tod and not($ff shl shift)) or (dword(data) shl shift);
end;

procedure mos6526_chip.set_cra(data:byte);
begin
	if (((self.cra and 1)=0) and ((data and 1)<>0)) then self.ta_pb6:=1;
	// switching to serial output mode causes sp to go high?
	if (((self.cra and $40)=0) and ((data and $40)<>0)) then begin
		self.bits:=0;
    {$IFDEF DEBUG}MessageDlg('writesp 1', mtInformation,[mbOk], 0);{$ENDIF}
		//m_write_sp(1);
	end;
	// lower sp again when switching back to input?
	if (((self.cra and $40)<>0) and ((data and $40)=0)) then begin
		self.bits:=0;
    {$IFDEF DEBUG}MessageDlg('writesp 0', mtInformation,[mbOk], 0);{$ENDIF}
		//m_write_sp(0);
	end;
	self.cra:=data;
	self.update_pb;
end;

function mos6526_chip.port_a_pins:byte;
begin
  port_a_pins:=(pra and ddra) or not ddra;
end;
function mos6526_chip.port_b_pins:byte;
begin
  port_b_pins:=(prb and ddrb) or not ddrb;
end;
procedure mos6526_chip.flag_w(valor:byte);
begin
  valor:=valor and 1;
  if (self.flag<>0) and (valor=0) then self.icr:=self.icr or ICR_FLAG;
  self.flag:=valor;
end;

procedure mos6526_chip.clock_tod;
var tenth,sec,min,hour,pm:byte;divisor:integer;
  function next_bcd(v:byte):byte;
  begin
    inc(v);if (v and $f)>9 then inc(v,6);next_bcd:=v;
  end;
begin
  if tod_stopped then exit;
  if (cra and $80)<>0 then divisor:=5 else divisor:=6;
  inc(tod_count);if tod_count<divisor then exit;tod_count:=0;
  tenth:=next_bcd(tod and $f);sec:=(tod shr 8) and $7f;
  min:=(tod shr 16) and $7f;hour:=(tod shr 24) and $9f;
  if tenth>=$10 then begin
    tenth:=0;sec:=next_bcd(sec);
    if sec>=$60 then begin
      sec:=0;min:=next_bcd(min);
      if min>=$60 then begin
        min:=0;pm:=hour and $80;hour:=hour and $1f;
        if hour=$11 then begin hour:=$12;pm:=pm xor $80;end
          else if hour=$12 then hour:=1 else hour:=next_bcd(hour);
        hour:=hour or pm;
      end;
    end;
  end;
  tod:=dword(tenth) or (dword(sec) shl 8) or
       (dword(min) shl 16) or (dword(hour) shl 24);
  if tod=alarm then icr:=icr or ICR_ALARM;
end;

procedure mos6526_chip.set_crb(data:byte);
begin
	if (((self.crb and 1)=0) and ((data and $1)<>0)) then self.tb_pb7:=1;
	self.crb:=data;
	self.update_pb;
end;

function mos6526_chip.read(direccion:byte):byte;
var
  res,tempb,pb6,pb7:byte;
begin
res:=0;
case (direccion and $f) of
  PRA_:begin
        if addr(self.pa_read)<>nil then tempb:=self.pa_read
          else tempb:=$ff;
        res:=tempb and self.port_a_pins;
		    self.pa_in:=res;
  end;
  PRB_:begin
    if addr(self.pb_read)<>nil then tempb:=self.pb_read
          else tempb:=$ff;
    res:=tempb and self.port_b_pins;
		self.pb_in:=res;
		if (self.cra and $2)<>0 then begin
      if (self.cra and $4)<>0 then pb6:=self.ta_pb6
        else pb6:=self.ta_out;
			res:=res and not($40);
			res:=res or (pb6 shl 6);
		end;
		if (self.crb and $2)<>0 then begin
      if (self.crb and 4)<>0 then pb7:=self.tb_pb7
        else pb7:=self.tb_out;
			res:=res and not($80);
			res:=res or (pb7 shl 7);
		end;
		self.pc:=0;
		//m_write_pc(m_pc);
    end;
  DDRA_:res:=self.ddra;
	DDRB_:res:=self.ddrb;
  TA_LO_:res:=self.ta and $ff;
  TA_HI_:res:=self.ta shr 8;
  TB_LO_:res:=self.tb and $ff;
  TB_HI_:res:=self.tb shr 8;
  ICR_:begin
    res:=(self.ir1 shl 7) or self.icr;
    //if self.icr<>0 then begin
    //  read:=res;
    //  exit
    //end;
		self.icr_read:=true;
		self.ir0:=0;
		self.ir1:=0;
		self.icr:=0;
		self.irq:=false;
		if addr(self.irq_call)<>nil then self.irq_call(CLEAR_LINE);
  end;
  TOD_HR:begin
    if not tod_latched then begin tod_latch:=tod;tod_latched:=true;end;
    res:=tod_latch shr 24;
  end;
  TOD_MIN:if tod_latched then res:=(tod_latch shr 16) and $7f else res:=(tod shr 16) and $7f;
  TOD_SEC:if tod_latched then res:=(tod_latch shr 8) and $7f else res:=(tod shr 8) and $7f;
  TOD_10THS:begin
    if tod_latched then res:=tod_latch and $f else res:=tod and $f;
    tod_latched:=false;
  end;
  CRA_:res:=self.cra;
  CRB_:res:=self.crb;
  {$IFDEF DEBUG}else MessageDlg('read mos6526 desconocido '+inttohex(direccion,4), mtInformation,[mbOk], 0);{$ENDIF}
end;
  read:=res;
end;

procedure mos6526_chip.write(direccion,valor:byte);
begin
case (direccion and $f) of
  PRA_:begin
		    self.pra:=valor;
		    self.update_pa;
      end;
  PRB_:begin
		    self.prb:=valor;
		    self.update_pb;
        self.pc:=0;
        //self.writepc
      end;
  DDRA_:begin
          self.ddra:=valor;
		      self.update_pa;
        end;
  DDRB_:begin
          self.ddrb:=valor;
		      self.update_pb;
        end;
  TA_LO_:begin
          self.ta_latch:=(self.ta_latch and $ff00) or valor;
		      if (self.load_a2<>0) then self.ta:=(self.ta and $ff00) or valor;
        end;
  TA_HI_:begin
          self.ta_latch:=(valor shl 8) or (self.ta_latch and $ff);
		      if ((self.cra and 1)=0) then self.load_a0:=1;
		      if ((self.cra and $8)<>0) then begin
			      self.ta:=self.ta_latch;
			      self.set_cra(self.cra or 1);
          end;
          if (self.load_a2<>0) then self.ta:=(valor shl 8) or (self.ta and $ff);
        end;
  TB_LO_:begin
		      self.tb_latch:= (self.tb_latch and $ff00) or valor;
		      if (self.load_b2<>0) then self.tb:=(self.tb and $ff00) or valor;
         end;
	TB_HI_:begin
		      self.tb_latch:= (valor shl 8) or (self.tb_latch and $ff);
		      if ((self.crb and 1)=0) then self.load_b0:=1;
		      if ((self.crb and $8)<>0) then begin
            self.tb:=self.tb_latch;
			      self.set_crb(self.crb or 1);
          end;
		      if (self.load_b2<>0) then self.tb:=(valor shl 8) or (self.tb and $ff);
         end;
  TOD_10THS:begin
    self.write_tod(0,valor and $f);
    if (crb and $80)=0 then begin tod_stopped:=false;tod_count:=0;end;
  end;
  TOD_SEC:self.write_tod(1,valor and $7f);
  TOD_MIN:self.write_tod(2,valor and $7f);
  TOD_HR:begin
    self.write_tod(3,valor and $9f);
    if (crb and $80)=0 then tod_stopped:=true;
  end;
  IMR_:begin //Mascara de las IRQs
        //Si el bit 7 es 0 --> Lo que esté a 1 lo desabilito
        //Si el bit 7 es 1 --> Lo que esté a 1 lo habilito
		    if (valor and $80)<>0 then self.imr:=self.imr or (valor and $1f)
      		else self.imr:=self.imr and not(valor and $1f);
        //Alguna IRQ?
		    if (not(self.irq) and ((self.icr and self.imr)<>0)) then self.ir0:=1;
      end;
  CRA_:self.set_cra(valor);
  CRB_:self.set_crb(valor);
  {$IFDEF DEBUG}else MessageDlg('write mos6526 desconocido '+inttohex(direccion,4), mtInformation,[mbOk], 0);{$ENDIF}
end;
end;

end.
