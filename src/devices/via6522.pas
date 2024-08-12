unit via6522;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}main_engine,sysutils,dialogs,lib_sdl2,timer_engine;

type
  tin_handler=function:byte;
  tout_handler=procedure(valor:byte);
  via6522_chip=class
      constructor create(numero_cpu:byte;clock:dword);
      destructor free;
    public
      joystick1,joystick2:byte;
      procedure reset;
      function read(direccion:byte):byte;
      procedure write(direccion,valor:byte);
      procedure change_calls(in_a,in_b:tin_handler;out_a,out_b,irq_set,ca2_set,cb2_set:tout_handler);
      procedure write_pa(valor:byte);
      procedure update_timers(estados:word);
      procedure set_pb_line(line:byte;state:boolean);
      procedure write_cb1(state:boolean);
    private
      t1_pb7,sr,pcr,acr,ier,ifr:byte;
      out_a,out_b,in_a,in_b,ddr_a,ddr_b,latch_a,latch_b:byte;
      out_ca2,out_cb1,out_cb2,in_cb2:byte;
      t1_active,t2_active:boolean;
      t1ll,t1lh,t2ll,t2lh:byte;
      t1cl,t1ch,t2cl,t2ch:byte;
      shift_counter:byte;
      in_a_handler,in_b_handler:tin_handler;
      irq_handler,ca2_handler,cb1_handler,cb2_handler,out_a_handler,out_b_handler:tout_handler;
      in_cb1,shift_timer,shift_irq_enabled:boolean;
      shift_irq_contador:integer;
      time1,time2,clock:word;
      timer1,timer2:byte;
      procedure clr_pa_int;
      procedure clr_pb_int;
      procedure set_int(valor:byte);
      procedure clear_int(valor:byte);
      procedure output_irq;
      function input_pa:byte;
      function input_pb:byte;
      procedure output_pa;
      procedure output_pb;
      function get_counter1_value:word;
      procedure counter2_decrement;
      procedure shift_in;
  end;

var
  via6522_0:via6522_chip;

implementation
const
  VIA_PB = 0;
	VIA_PA = 1;
	VIA_DDRB = 2;
	VIA_DDRA = 3;
	VIA_T1CL = 4;
	VIA_T1CH = 5;
	VIA_T1LL = 6;
	VIA_T1LH = 7;
	VIA_T2CL = 8;
	VIA_T2CH = 9;
	VIA_SR = 10;
	VIA_ACR = 11;
	VIA_PCR = 12;
	VIA_IFR = 13;
	VIA_IER = 14;
	VIA_PANH = 15;
  INT_CA2=$01;
  INT_CA1=$02;
  INT_SR =$04;
  INT_CB2=$08;
  INT_CB1=$10;
  INT_T2 =$20;
  INT_T1 =$40;
  INT_ANY=$80;
  IFR_DELAY=3;

//Macros
function PB_LATCH_ENABLE(valor:byte):boolean;
begin
  PB_LATCH_ENABLE:=(valor and 2)<>0;
end;

function T1_SET_PB7(valor:byte):boolean;
begin
  T1_SET_PB7:=(valor and $80)<>0;
end;

function CB2_IND_IRQ(valor:byte):boolean;
begin
  CB2_IND_IRQ:=(valor and $a0)=$20;
end;

function CB2_PULSE_OUTPUT(valor:byte):boolean;
begin
  CB2_PULSE_OUTPUT:=(valor and $e0)=$a0;
end;

function CB2_AUTO_HS(valor:byte):boolean;
begin
  CB2_AUTO_HS:=(valor and $c0)=$80;
end;

function CA2_FIX_OUTPUT(valor:byte):boolean;
begin
   CA2_FIX_OUTPUT:=(valor and $0c)=$0c;
end;

function CB2_FIX_OUTPUT(valor:byte):boolean;
begin
  CB2_FIX_OUTPUT:=(valor and $c0)=$c0;
end;

function CA2_OUTPUT_LEVEL(valor:byte):byte;
begin
  CA2_OUTPUT_LEVEL:=(valor and $02) shr 1;
end;

function CB2_OUTPUT_LEVEL(valor:byte):byte;
begin
  CB2_OUTPUT_LEVEL:=(valor and $20) shr 5;
end;

function SR_DISABLED(valor:byte):boolean;
begin
  SR_DISABLED:=(valor and $1c)=0;
end;

function SI_EXT_CONTROL(valor:byte):boolean;
begin
  SI_EXT_CONTROL:=(valor and $1c)=$0c;
end;

function SO_EXT_CONTROL(valor:byte):boolean;
begin
  SO_EXT_CONTROL:=(valor and $1c)=$1c;
end;

function T1_CONTINUOUS(valor:byte):boolean;
begin
  T1_CONTINUOUS:=(valor and $40)<>0;
end;

function SI_T2_CONTROL(valor:byte):boolean;
begin
  SI_T2_CONTROL:=(valor and $1c)=$04;
end;

function SI_O2_CONTROL(valor:byte):boolean;
begin
  SI_O2_CONTROL:=(valor and $1c)=$08;
end;

function T2_COUNT_PB6(valor:byte):boolean;
begin
  T2_COUNT_PB6:=(valor and $20)<>0;
end;

function CB1_LOW_TO_HIGH(valor:byte):boolean;
begin
  CB1_LOW_TO_HIGH:=(valor and $10)<>0;
end;

function CB1_HIGH_TO_LOW(valor:byte):boolean;
begin
  CB1_HIGH_TO_LOW:=(valor and $10)=0;
end;

function PA_LATCH_ENABLE(valor:byte):boolean;
begin
  PA_LATCH_ENABLE:=(valor and 1)<>0;
end;

function CA2_PULSE_OUTPUT(valor:byte):boolean;
begin
  CA2_PULSE_OUTPUT:=((valor and $0e)=$0a);
end;

function CA2_AUTO_HS(valor:byte):boolean;
begin
  CA2_AUTO_HS:=(valor and $0c)=$08;
end;

function CA2_IND_IRQ(valor:byte):boolean;
begin
  CA2_IND_IRQ:=(valor and $0a)=$02;
end;

function SO_O2_CONTROL(valor:byte):boolean;
begin
  SO_O2_CONTROL:=((valor and $1c)=$18);
end;

function SO_T2_RATE(valor:byte):boolean;
begin
  SO_T2_RATE:=((valor and $1c)=$10);
end;

function SO_T2_CONTROL(valor:byte):boolean;
begin
  SO_T2_CONTROL:=((valor and $1c)=$14);
end;

procedure timer1_0_tick;
begin
if T1_CONTINUOUS(via6522_0.acr) then begin
  via6522_0.t1_pb7:=not(via6522_0.t1_pb7) and 1;
  timers.timer[via6522_0.timer1].time_final:=via6522_0.t1ll+(via6522_0.t1lh shl 8)+IFR_DELAY;
end else begin
  via6522_0.t1_pb7:=1;
  via6522_0.t1_active:=false;
  timers.enabled(via6522_0.timer1,false);
end;
if T1_SET_PB7(via6522_0.acr) then via6522_0.output_pb;
via6522_0.set_int(INT_T1);
end;

procedure timer2_0_tick;
begin
timers.enabled(via6522_0.timer2,false);
via6522_0.t2_active:=false;
via6522_0.set_int(INT_T2);
via6522_0.time2:=0;
end;

constructor via6522_chip.create(numero_cpu:byte;clock:dword);
begin
  self.clock:=clock;
  self.in_a_handler:=nil;
  self.in_b_handler:=nil;
  self.out_a_handler:=nil;
  self.out_b_handler:=nil;
  self.irq_handler:=nil;
  self.ca2_handler:=nil;
  self.cb2_handler:=nil;
  self.timer1:=timers.init(numero_cpu,1,timer1_0_tick,nil,false);
  self.timer2:=timers.init(numero_cpu,1,timer2_0_tick,nil,false);
end;

destructor via6522_chip.free;
begin
end;

procedure via6522_chip.reset;
begin
  self.out_a:=0;
	self.out_ca2:=1;
	self.ddr_a:=0;
	self.latch_a:=0;
	self.out_b:=0;
	self.out_cb1:=1;
	self.out_cb2:=1;
	self.ddr_b:=0;
	self.latch_b:=0;
	self.t1cl:=0;
	self.t1ch:=0;
	self.t2cl:=0;
	self.t2ch:=0;
	self.pcr:=0;
	self.acr:=0;
	self.ier:=0;
	self.ifr:=0;
	self.t1_active:=false;
	self.t1_pb7:=1;
  timers.enabled(via6522_0.timer1,false);
  timers.enabled(via6522_0.timer2,false);
	self.t2_active:=false;
  self.in_cb1:=false;
	self.shift_counter:=0;
  self.in_cb2:=0;
  shift_irq_contador:=0;
  time1:=0;
  time2:=0;
  self.t1ll:=$f3; // via at 0x9110 in vic20 show these values
	self.t1lh:=$b5; // ports are not written by kernel!
	self.t2ll:=$ff; // taken from vice
	self.t2lh:=$ff;
	self.output_pa;
	self.output_pb;
	if @self.ca2_handler<>nil then self.ca2_handler(out_ca2);
	if @self.cb1_handler<>nil then self.cb1_handler(out_cb1);
	if @self.cb2_handler<>nil then self.cb2_handler(out_cb2);
  shift_timer:=false;
end;

procedure via6522_chip.change_calls(in_a,in_b:tin_handler;out_a,out_b,irq_set,ca2_set,cb2_set:tout_handler);
begin
  self.in_a_handler:=in_a;
  self.in_b_handler:=in_b;
  self.out_a_handler:=out_a;
  self.out_b_handler:=out_b;
  self.irq_handler:=irq_set;
  self.ca2_handler:=ca2_set;
  self.cb2_handler:=cb2_set;
end;

procedure via6522_chip.update_timers(estados:word);
begin
  if shift_irq_enabled then begin
    self.shift_irq_contador:=self.shift_irq_contador-estados;
    if self.shift_irq_contador<=0 then begin
      shift_irq_enabled:=false;
      self.set_int(INT_SR);  // triggered from shift_in or shift_out on the last rising edge
    end;
  end;
  self.time2:=self.time2+estados;
  self.time1:=self.time1+estados;
end;

procedure via6522_chip.set_pb_line(line:byte;state:boolean);
begin
	if state then
    self.in_b:=self.in_b or (1 shl line)
	else begin
		if ((line=6) and ((self.in_b and $40)<>0)) then counter2_decrement;
		self.in_b:=self.in_b and not(1 shl line);
	end;
end;

procedure via6522_chip.output_pa;
var
  res:byte;
begin
	res:=(self.out_a and self.ddr_a) or not(self.ddr_a);
	if @self.out_a_handler<>nil then self.out_a_handler(res);
end;

procedure via6522_chip.write_pa(valor:byte);
begin
	self.in_a:=valor;
end;

procedure via6522_chip.shift_in;
begin
	// Only shift in data on raising edge
	if ((self.shift_counter and 1)=0) then begin
		self.sr:=(self.sr shl 1) or (self.in_cb2 and 1);
		if ((self.shift_counter=0) and not(SR_DISABLED(self.acr))) then begin
      self.shift_irq_contador:=2; // Delay IRQ 2 edges for all shift INs (mode 1-3)
      self.shift_irq_enabled:=true;
		end;
	end;
	self.shift_counter:=(self.shift_counter-1) and $0f; // Count all edges
end;


procedure via6522_chip.write_cb1(state:boolean);
begin
	if (self.in_cb1<>state) then begin
		self.in_cb1:=state;
		if ((self.in_cb1 and CB1_LOW_TO_HIGH(self.pcr)) or (not(self.in_cb1) and CB1_HIGH_TO_LOW(self.pcr))) then begin
			if (PB_LATCH_ENABLE(self.acr)) then self.latch_b:=self.input_pb;
			self.set_int(INT_CB1);
			if ((self.out_cb2=0) and CB2_AUTO_HS(self.pcr)) then begin
				self.out_cb2:=1;
				self.cb2_handler(1);
			end;
		end;
		// The shifter shift is not controlled by PCR
		if (SO_EXT_CONTROL(self.acr)) then MessageDlg('shift_out', mtInformation,[mbOk], 0) //shift_out
		  else if (SI_EXT_CONTROL(self.acr) or SR_DISABLED(self.acr)) then self.shift_in;
	end;
end;

function via6522_chip.input_pa:byte;
var
  res:byte;
begin
	// HACK: port a in the real 6522 does not mask off the output pins, but you can't trust handlers.
	if (@self.in_a_handler<>nil) then res:=(self.in_a and not(self.ddr_a) and self.in_a_handler) or (self.out_a and self.ddr_a)
	  else res:=(self.out_a or not(self.ddr_a)) and self.in_a;
  input_pa:=res;
end;

function via6522_chip.input_pb:byte;
var
  pb:byte;
begin
	pb:=self.in_b and not(self.ddr_b);
	if ((self.ddr_b<>$ff) and (@self.in_b_handler<>nil)) then pb:=pb and self.in_b_handler;
	pb:=pb or (self.out_b and self.ddr_b);
	if T1_SET_PB7(self.acr) then pb:=(pb and $7f) or ((self.t1_pb7 and 1) shl 7);
	input_pb:=pb;
end;

procedure via6522_chip.output_pb;
var
  res:byte;
begin
	res:=(self.out_b and self.ddr_b) or not(self.ddr_b);
	if T1_SET_PB7(self.acr) then res:=(res and $7f) or ((self.t1_pb7 and 1) shl 7);
	if @self.out_b_handler<>nil then self.out_b_handler(res);
end;

procedure via6522_chip.clr_pa_int;
begin
  if not(CA2_IND_IRQ(self.pcr)) then self.clear_int(INT_CA1 or INT_CA2)
    else self.clear_int(INT_CA1)
end;

procedure via6522_chip.clr_pb_int;
begin
  if not(CB2_IND_IRQ(self.pcr)) then self.clear_int(INT_CB1 or INT_CB2)
    else self.clear_int(INT_CB1)
end;

procedure via6522_chip.set_int(valor:byte);
begin
	if ((self.ifr and valor)=0) then begin
		self.ifr:=self.ifr or valor;
		self.output_irq;
  end;
end;

procedure via6522_chip.clear_int(valor:byte);
begin
	if (self.ifr and valor)<>0 then begin
		self.ifr:=self.ifr and not(valor);
		self.output_irq;
	end;
end;

procedure via6522_chip.output_irq;
begin
	if (self.ier and self.ifr and $7f)<>0 then begin
		if (self.ifr and INT_ANY)=0 then begin
			self.ifr:=self.ifr or INT_ANY;
			self.irq_handler(ASSERT_LINE);
		end;
	end else begin
		if (self.ifr and INT_ANY)<>0 then begin
			self.ifr:=self.ifr and not(INT_ANY);
			self.irq_handler(CLEAR_LINE);
		end;
	end;
end;

procedure via6522_chip.counter2_decrement;
begin
	if not(T2_COUNT_PB6(self.acr)) then exit;
	// count down on T2CL
  self.t2cl:=self.t2cl-1;
	if (self.t2cl<>0) then exit;
	// borrow from T2CH
  self.t2ch:=self.t2ch-1;
	if (self.t2ch<>0) then exit;
	// underflow causes only one interrupt between T2CH writes
	if self.t2_active then begin
    timers.enabled(via6522_0.timer2,false);
		self.t2_active:=false;
		self.set_int(INT_T2);
	end;
end;

function via6522_chip.read(direccion:byte):byte;
var
  res:byte;
begin
  res:=0;
  direccion:=direccion and $f;
  case direccion of
    VIA_PB:begin // update the input
		          if (not(PB_LATCH_ENABLE(self.acr)) and ((self.ifr and INT_CB1)<>0)) then res:=self.latch_b
                else res:=self.input_pb;
			        self.CLR_PB_INT;
           end;
    VIA_PA:begin // update the input
		          if (not(PA_LATCH_ENABLE(self.acr)) and ((self.ifr and INT_CA1)<>0)) then res:=self.latch_a
                else res:=self.input_pa;
			        self.CLR_PA_INT;
			        if ((self.out_ca2<>0) and (CA2_PULSE_OUTPUT(self.pcr) or CA2_AUTO_HS(self.pcr))) then begin
				        self.out_ca2:=0;
				        if @self.ca2_handler<>nil then self.ca2_handler(self.out_ca2);
              end;
			        if (CA2_PULSE_OUTPUT(self.pcr)) then MessageDlg('Mierda timer VIA_PA R', mtInformation,[mbOk], 0);//m_ca2_timer->adjust(clocks_to_attotime(1));
            end;
    VIA_DDRB:res:=self.ddr_b;
    VIA_DDRA:res:=self.ddr_a;
    VIA_T1CL:begin
			          clear_int(INT_T1);
		            res:=get_counter1_value and $ff;
             end;
    VIA_T1CH:res:=get_counter1_value shr 8;
    VIA_T1LL:res:=self.t1ll;
	  VIA_T1LH:res:=self.t1lh;
    VIA_T2CL:begin
			          clear_int(INT_T2);
		            if (self.t2_active and timers.timer[self.timer2].enabled) then begin
                  res:=trunc(timers.timer[self.timer2].time_final-timers.timer[self.timer2].actual_time) and $ff;
                end else begin
                    if T2_COUNT_PB6(self.acr) then res:=self.t2cl
                      else res:=((($10000-time2) and $ffff)-1) and $ff;
                  end;
              end;
    VIA_T2CH:if (self.t2_active and timers.timer[self.timer2].enabled) then begin
			          res:=trunc(timers.timer[self.timer2].time_final-timers.timer[self.timer2].actual_time) shr 8;
             end else begin
                if (T2_COUNT_PB6(self.acr)) then res:=self.t2ch
                  else res:=((($10000-time2) and $ffff)-1) shr 8;
			       end;
    VIA_SR:begin
		          res:=self.sr;
		          if (not(SI_EXT_CONTROL(self.acr) or SO_EXT_CONTROL(self.acr))) then begin
			          self.out_cb1:=1;
			          if @self.cb1_handler<>nil then self.cb1_handler(self.out_cb1);
			          self.shift_counter:=$0f;
              end else if self.in_cb1 then self.shift_counter:=$0f
                          else self.shift_counter:=$10;
              self.clear_int(INT_SR);
		          if (SI_O2_CONTROL(self.acr) or SO_O2_CONTROL(self.acr)) then MessageDlg('Mierda timer VIA_SR R', mtInformation,[mbOk], 0)//m_shift_timer->adjust(clocks_to_attotime(6) / 2); // 6 edges to cb2 change from start of write
		            else if (SI_T2_CONTROL(self.acr) or SO_T2_CONTROL(self.acr)) then MessageDlg('Mierda timer VIA_SR R2', mtInformation,[mbOk], 0) //m_shift_timer->adjust(clocks_to_attotime(m_t2ll + 2) / 2);
		                 else if not(SO_T2_RATE(self.acr)) then ;//MessageDlg('Mierda timer VIA_SR W3', mtInformation,[mbOk], 0);//m_shift_timer->adjust(attotime::never); // In case we change mode before counter expire}
            end;
    VIA_ACR:res:=self.acr;
    VIA_PCR:res:=self.pcr;
    VIA_IER:res:=self.ier or $80;
    VIA_IFR:res:=self.ifr;
    VIA_PANH:if (not(PA_LATCH_ENABLE(self.acr)) and ((self.ifr and INT_CA1)<>0)) then res:=self.latch_a
              else res:=self.input_pa;
    else MessageDlg('Read: '+inttohex(direccion,2), mtInformation,[mbOk], 0);
  end;
  read:=res;
end;

function via6522_chip.get_counter1_value:word;
var
  val:word;
begin
	if self.t1_active then val:=trunc(timers.timer[self.timer1].actual_time)-IFR_DELAY
	  else val:=$ffff-(time1*1000);
	get_counter1_value:=val;
end;

procedure via6522_chip.write(direccion,valor:byte);
var
  tword:word;
begin
  direccion:=direccion and $f;
  case direccion of
    VIA_PB:begin
		          self.out_b:=valor;
		          if (self.ddr_b<>0) then self.output_pb;
		          self.CLR_PB_INT;
		          if ((self.out_cb2<>0) and (CB2_PULSE_OUTPUT(self.pcr) or (CB2_AUTO_HS(self.pcr)))) then begin
			          self.out_cb2:=0;
        			  self.cb2_handler(self.out_cb2);
		          end;
		          if CB2_PULSE_OUTPUT(self.pcr) then MessageDlg('Mierda timer VIA_PB W', mtInformation,[mbOk], 0);//self.cb2_timer->adjust(clocks_to_attotime(1));
		       end;
    VIA_PA:begin
		          self.out_a:=valor;
		          if (self.ddr_a<>0) then self.output_pa;
		          self.CLR_PA_INT;
		          if ((self.out_ca2<>0) and (CA2_PULSE_OUTPUT(self.pcr) or CA2_AUTO_HS(self.pcr))) then begin
                self.out_ca2:=0;
			          if @self.ca2_handler<>nil then self.ca2_handler(self.out_ca2);
              end;
		          if (CA2_PULSE_OUTPUT(self.pcr)) then MessageDlg('Mierda timer VIA_PA W', mtInformation,[mbOk], 0);//m_ca2_timer->adjust(clocks_to_attotime(1));
            end;
    VIA_DDRB:if (valor<>self.ddr_b) then begin
			          self.ddr_b:=valor;
			          self.output_pb;
             end;
    VIA_DDRA:if (self.ddr_a<>valor) then begin
			          self.ddr_a:=valor;
			          self.output_pa;
		         end;
    VIA_T1CL,VIA_T1LL:self.t1ll:=valor;
    VIA_T1CH:begin
		            self.t1ch:=valor;
                self.t1lh:=valor;
		            self.t1cl:=self.t1ll;
		            self.clear_int(INT_T1);
		            self.t1_pb7:=0;
		            if T1_SET_PB7(self.acr) then self.output_pb;
                timers.timer[self.timer1].time_final:=self.t1ll+(self.t1lh shl 8)+IFR_DELAY;
                timers.enabled(self.timer1,true);
                timers.reset(self.timer1);
		            self.t1_active:=true;
              end;
    VIA_T1LH:begin
                self.t1lh:=valor;
		            self.clear_int(INT_T1);
            end;
    VIA_T2CL:self.t2ll:=valor;
	  VIA_T2CH:begin
		            self.t2ch:=valor;
                self.t2lh:=valor;
		            self.t2cl:=self.t2ll;
		            self.clear_int(INT_T2);
		            if not(T2_COUNT_PB6(self.acr)) then begin
                  timers.timer[self.timer2].time_final:=self.t2ll+(self.t2lh shl 8)+IFR_DELAY;
                  timers.enabled(self.timer2,true);
                  timers.reset(self.timer2);
                end else time2:=0;
                self.t2_active:=true;
            end;
    VIA_SR:begin
		          self.sr:=valor;
		          if not(SI_EXT_CONTROL(self.acr) or SO_EXT_CONTROL(self.acr)) then begin
			          self.out_cb1:=1;
			          if @self.cb1_handler<>nil then self.cb1_handler(self.out_cb1);
			          self.shift_counter:=$0f;
              end else if self.in_cb1 then self.shift_counter:=$0f
                          else self.shift_counter:=$10;
              self.clear_int(INT_SR);
		          if (SO_O2_CONTROL(self.acr) or SI_O2_CONTROL(self.acr)) then MessageDlg('Mierda timer VIA_SR W', mtInformation,[mbOk], 0)//m_shift_timer->adjust(clocks_to_attotime(6) / 2); // 6 edges to cb2 change from start of write
		            else if (SO_T2_RATE(self.acr) or SO_T2_CONTROL(self.acr) or SI_T2_CONTROL(self.acr)) then MessageDlg('Mierda timer VIA_SR W2', mtInformation,[mbOk], 0) //m_shift_timer->adjust(clocks_to_attotime(m_t2ll + 2) / 2);
		                    else ;//MessageDlg('Mierda timer VIA_SR W3', mtInformation,[mbOk], 0);//m_shift_timer->adjust(attotime::never); // In case we change mode before counter expire
            end;
    VIA_ACR:begin
              tword:=get_counter1_value;
			        self.acr:=valor;
			        self.output_pb;
			        if (SR_DISABLED(self.acr) or SI_EXT_CONTROL(self.acr) or SO_EXT_CONTROL(self.acr)) then shift_timer:=false;
			        if (T1_CONTINUOUS(self.acr)) then begin
                timers.timer[self.timer1].time_final:=tword+IFR_DELAY;
                timers.enabled(self.timer1,true);
                timers.reset(self.timer1);
				        self.t1_active:=true;
              end;
			        if (SI_T2_CONTROL(self.acr) or SI_O2_CONTROL(self.acr) or SI_EXT_CONTROL(self.acr)) then begin
				        self.out_cb2:=1;
				        self.cb2_handler(self.out_cb2);
			        end;
            end;
    VIA_PCR:begin
                self.pcr:=valor;
		            if (CA2_FIX_OUTPUT(valor) and (self.out_ca2<>CA2_OUTPUT_LEVEL(valor))) then begin
			              self.out_ca2:=CA2_OUTPUT_LEVEL(valor);
			              if @self.ca2_handler<>nil then self.ca2_handler(self.out_ca2);
		            end;
		            if (CB2_FIX_OUTPUT(valor) and (self.out_cb2<>CB2_OUTPUT_LEVEL(valor))) then begin
			              self.out_cb2:=CB2_OUTPUT_LEVEL(valor);
			              if @self.cb2_handler<>nil then self.cb2_handler(self.out_cb2);
                end;
            end;
    VIA_IFR:self.clear_int(valor and $7f);
    VIA_IER:begin
		            if (valor and $80)<>0 then self.ier:=self.ier or (valor and $7f)
                  else self.ier:=self.ier and not(valor and $7f);
		            self.output_irq;
            end;
    VIA_PANH:begin
		            self.out_a:=valor;
		            if (self.ddr_a<>0) then self.output_pa;
		          end;
  else MessageDlg('Write: '+inttohex(direccion,2), mtInformation,[mbOk], 0);
  end;
end;

end.
