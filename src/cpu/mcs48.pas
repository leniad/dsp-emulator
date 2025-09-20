unit mcs48;
interface
//{$define DEBUG}
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     dialogs,sysutils,timer_engine,main_engine,cpu_misc,i8243;

type
        band_mcs48=record
                bit1,bit2,bit4,unk,b,f,a,c:boolean;
        end;
        reg_mcs48=record
                pc:word;
                old_pc:word;
                psw:band_mcs48;
                a,p1,p2:byte;
                r0,r1,r2,r3,r4,r5,r6,r7:pbyte;
                a11:word;
        end;
        preg_mcs48=^reg_mcs48;
        cpu_mcs48=class(cpu_class)
                constructor create(clock:dword;frames_div:word;chip_type:byte);
                destructor free;
            public
                //N7751 port extender
                i8243:i8243_chip;
                procedure run(maximo:single);
                procedure reset;
                procedure change_io_calls(in_port:tgetbyte;out_port:tputbyte;ext_inport:tgetbyte;ext_outport:tputbyte);
                function get_rom_addr:pbyte;
                function upi41_master_r(direccion:byte):byte;
                procedure upi41_master_w(direccion,valor:byte);
            private
                r:preg_mcs48;
                rom:array[0..$7ff] of byte;
                ram:array[0..$ff] of byte;
                timer:byte;              // 8-bit timer
                prescaler:byte;          // 5-bit timer prescaler
                t1_history:byte;         // 8-bit history of the T1 input
                sts:byte;                // 4-bit status register + OBF/IBF flags (UPI-41 only)
                dbbi:byte;               // 8-bit input data buffer (UPI-41 only)
                dbbo:byte;               // 8-bit output data buffer (UPI-41 only)
                feature_mask:byte;
                irq_polled,tirq_enabled,xirq_enabled,timer_flag,flags_enabled,dma_enabled,irq_in_progress,timer_overflow:boolean;
	              timecount_enabled:byte;
                ram_mask:byte;
                rom_mask:word;
                chip_type:byte;
                f1:boolean;
                in_port,ext_inport:tgetbyte;
                out_port,ext_outport:tputbyte;
                function test_r(valor:byte):byte;
                function bus_r:byte;
                procedure bus_w(valor:byte);
                function port_r(port_num:byte):byte;
                procedure port_w(port_num,valor:byte);
                procedure update_regptr;
                function read_rom(direccion:word):byte;
                function check_irqs:byte;
                procedure push_pc_psw;
                procedure burn_cycles(count:byte);
                function dame_pila:byte;
                procedure pon_pila(valor:byte);
                function p2_mask:byte;
                procedure add(valor:byte);
                procedure addc(valor:byte);
                procedure expander_operation(operation,port:byte);
                procedure cond(test:boolean);
                function read_byte(direccion:word):byte;
        end;

const
  I8039=0;
  I8035=1;
  N7751=2;
  I8042=3;
  //Ports
  MCS48_PORT_P0=$100;
  MCS48_PORT_P1=$101;
  MCS48_PORT_P2=$102;
  MCS48_PORT_T0=$110;
  MCS48_PORT_T1=$111;
  MCS48_PORT_BUS=$120;
  MCS48_PORT_PROG=$121;     // PROG line to 8243 expander
  // status bits (UPI-41)
  STS_IBF=$02;
  STS_OBF=$01;
  TIMER_ENABLED=01;
  COUNTER_ENABLED=02;
  // port 2 bits (UPI-41)
  P2_OBF=$10;
  P2_NIBF=$20;
  P2_DRQ=$40;
  P2_NDACK=$80;
  // feature masks
  MCS48_FEATURE=$01;
  UPI41_FEATURE=$02;
  ciclos_mcs48:array[0..$ff] of byte=(
//0 1 2 3 4 5 6 7 8 9 a b c d e f
  1,0,2,2,2,1,0,1,2,2,2,0,0,0,0,0, //00
  1,1,2,2,2,1,2,1,1,1,1,1,1,1,1,1, //10
  0,0,2,2,2,1,2,1,1,1,1,1,1,1,1,1, //20
  0,0,2,0,2,1,2,1,0,2,2,0,2,2,2,2, //30
  1,1,1,2,2,1,2,1,1,1,1,1,1,1,1,1, //40
  0,0,2,2,2,1,2,1,1,1,1,1,1,1,1,1, //50
  1,1,1,0,2,1,0,1,1,1,1,1,1,1,1,1, //60
  1,1,2,0,2,1,2,1,1,1,1,1,1,1,1,1, //70
  2,2,0,2,2,1,2,0,0,2,2,0,0,0,0,0, //80
  1,0,2,2,2,1,2,1,0,2,2,0,0,0,0,0, //90
  1,1,0,2,2,1,0,0,1,1,1,1,1,1,1,1, //a0
  2,2,2,2,2,1,1,2,2,2,2,2,2,2,2,2, //b0
  0,0,0,0,2,1,2,1,1,1,1,1,1,1,1,1, //c0
  0,0,2,2,2,1,2,1,1,1,1,1,1,1,1,1, //d0
  0,0,0,2,2,1,2,1,2,2,2,2,2,2,2,2, //e0
  1,1,2,0,2,1,2,1,1,1,1,1,1,1,1,1);//f0
var
  mcs48_0:cpu_mcs48;

implementation

constructor cpu_mcs48.create(clock:dword;frames_div:word;chip_type:byte);
begin
getmem(self.r,sizeof(reg_mcs48));
fillchar(self.r^,sizeof(reg_mcs48),0);
self.numero_cpu:=cpu_main_init(clock div 15);
self.clock:=clock div 15;
self.tframes:=(clock/15/frames_div)/llamadas_maquina.fps_max;
self.in_port:=nil;
self.out_port:=nil;
self.ext_inport:=nil;
self.ext_outport:=nil;
self.chip_type:=chip_type;
case chip_type of
  I8035:begin
          self.rom_mask:=0;
          self.ram_mask:=$3f;
        end;
  I8039:begin
          self.rom_mask:=0;
          self.ram_mask:=$7f;
        end;
  N7751:begin //i8048 clon
          self.rom_mask:=$3ff;
          self.ram_mask:=$3f;
          self.i8243:=i8243_chip.create;
        end;
  I8042:begin
          self.rom_mask:=$7ff;
          self.ram_mask:=$7f;
        end;
  else MessageDlg('Unkown CPU MCS48', mtInformation,[mbOk], 0);
end;
end;

destructor cpu_mcs48.free;
begin
freemem(self.r);
if self.chip_type=N7751 then begin
  self.i8243.free;
  self.i8243:=nil;
end;
end;

procedure cpu_mcs48.change_io_calls(in_port:tgetbyte;out_port:tputbyte;ext_inport:tgetbyte;ext_outport:tputbyte);
begin
  self.in_port:=in_port;
  self.out_port:=out_port;
  self.ext_inport:=ext_inport;
  self.ext_outport:=ext_outport;
end;

function cpu_mcs48.get_rom_addr:pbyte;
begin
  get_rom_addr:=@self.rom[0];
end;

function cpu_mcs48.dame_pila:byte;
var
  temp:byte;
begin
  temp:=0;
  if r.psw.c then temp:=temp or $80;
  if r.psw.a then temp:=temp or $40;
  if r.psw.f then temp:=temp or $20;
  if r.psw.b then temp:=temp or $10;
  if r.psw.unk then temp:=temp or 8;
  if r.psw.bit4 then temp:=temp or 4;
  if r.psw.bit2 then temp:=temp or 2;
  if r.psw.bit1 then temp:=temp or 1;
  dame_pila:=temp;
end;

procedure cpu_mcs48.pon_pila(valor:byte);
begin
  r.psw.c:=(valor and $80)<>0;
  r.psw.a:=(valor and $40)<>0;
  r.psw.f:=(valor and $20)<>0;
  r.psw.b:=(valor and $10)<>0;
  r.psw.unk:=(valor and 8)<>0;
  r.psw.bit4:=(valor and 4)<>0;
  r.psw.bit2:=(valor and 2)<>0;
  r.psw.bit1:=(valor and 1)<>0;
end;

procedure cpu_mcs48.reset;
begin
  self.r.pc:=0;
  self.r.psw.c:=false;
  self.r.psw.a:=false;
  self.r.psw.b:=false;
  self.r.psw.f:=false;
  self.r.psw.bit1:=false;
  self.r.psw.bit2:=false;
  self.r.psw.bit4:=false;
  self.r.psw.unk:=false;
  self.update_regptr;
  self.f1:=false;
  self.r.a11:=0;
  self.dbbo:=$ff;
  self.bus_w($ff);
  self.r.p1:=$ff;
  self.r.p2:=$ff;
  port_w(1,self.r.p1);
  port_w(2,self.r.p2);
  self.tirq_enabled:=false;
  self.xirq_enabled:=false;
  self.timecount_enabled:=0;
  self.timer_flag:=false;
  self.sts:=0;
  self.flags_enabled:=false;
  self.dma_enabled:=false;
  //confirmed from interrupt logic description
  self.irq_in_progress:=false;
  self.timer_overflow:=false;
  self.irq_polled:=false;
  self.pedir_irq:=CLEAR_LINE;
  self.change_reset(CLEAR_LINE);
  if self.chip_type=N7751 then self.i8243.reset;
end;

function cpu_mcs48.upi41_master_r(direccion:byte):byte;
begin
  // if just reading the status, return it
	if ((direccion and 1)<>0) then begin
    	upi41_master_r:=(self.sts and $f3) or (byte(self.f1)*8) or (byte(self.r.psw.f)*4);
      exit;
  end;
	// if the output buffer was full, it gets cleared now
	if (self.sts and STS_OBF)<>0 then begin
		self.sts:=self.sts and not(STS_OBF);
		if (self.flags_enabled) then begin
      self.r.p2:=self.r.p2 and not(P2_OBF);
			port_w(2,self.r.p2);
    end;
  end;
	upi41_master_r:=self.dbbo;
end;

procedure cpu_mcs48.upi41_master_w(direccion,valor:byte);
begin
  // data always goes to the input buffer
	self.dbbi:=valor;
	// set the appropriate flags
	if ((self.sts and STS_IBF)=0) then begin
		self.sts:=self.sts or STS_IBF;
		if (self.flags_enabled) then begin
      self.r.p2:=self.r.p2 and not(P2_NIBF);
			port_w(2, self.r.p2);
    end;
	end;
	// set F1 accordingly
	self.f1:=(direccion and $1)<>0;
end;

function cpu_mcs48.test_r(valor:byte):byte;
begin
  if addr(self.in_port)<>nil then test_r:=self.in_port(MCS48_PORT_T0+valor)
    else test_r:=$ff;
end;

function cpu_mcs48.bus_r:byte;
begin
  if addr(self.in_port)<>nil then bus_r:=self.in_port(MCS48_PORT_BUS);
end;

procedure cpu_mcs48.bus_w(valor:byte);
begin
  if addr(self.out_port)<>nil then self.out_port(MCS48_PORT_BUS,valor);
end;

function cpu_mcs48.port_r(port_num:byte):byte;
begin
  if addr(self.in_port)<>nil then port_r:=self.in_port(MCS48_PORT_P0+port_num);
end;

procedure cpu_mcs48.port_w(port_num,valor:byte);
begin
  if addr(self.out_port)<>nil then self.out_port(MCS48_PORT_P0+port_num,valor);
end;

procedure cpu_mcs48.expander_operation(operation,port:byte);
begin
  // put opcode/data on low 4 bits of P2
  self.r.p2:=(self.r.p2 and $f0) or (operation shl 2) or (port and 3);
  self.port_w(2,self.r.p2);
  // generate high-to-low transition on PROG line
  if addr(self.out_port)<>nil then self.out_port(MCS48_PORT_PROG,0);
  // transfer data on low 4 bits of P2
  if (operation<>MCS48_EXPANDER_OP_READ) then begin
    self.r.p2:=(self.r.p2 and $f0) or (self.r.a and $f);
    self.port_w(2,self.r.p2);
  end else begin
      // place P20-P23 in input mode
      self.r.p2:=self.r.p2 or $0f;
      self.port_w(2,self.r.p2);
      // input data to lower 4 bits of A (upper 4 bits are cleared)
      self.r.a:=self.port_r(2) and $0f;
  end;
  // generate low-to-high transition on PROG line
  if addr(self.out_port)<>nil then self.out_port(MCS48_PORT_PROG,1);
end;

procedure cpu_mcs48.update_regptr;
begin
  if self.r.psw.b then begin
    r.r0:=@self.ram[24];
    r.r1:=@self.ram[25];
    r.r2:=@self.ram[26];
    r.r3:=@self.ram[27];
    r.r4:=@self.ram[28];
    r.r5:=@self.ram[29];
    r.r6:=@self.ram[30];
    r.r7:=@self.ram[31];
  end else begin
    r.r0:=@self.ram[0];
    r.r1:=@self.ram[1];
    r.r2:=@self.ram[2];
    r.r3:=@self.ram[3];
    r.r4:=@self.ram[4];
    r.r5:=@self.ram[5];
    r.r6:=@self.ram[6];
    r.r7:=@self.ram[7];
  end;
end;

function cpu_mcs48.read_rom(direccion:word):byte;
begin
  if self.rom_mask<>0 then read_rom:=self.rom[direccion and self.rom_mask]
    else read_rom:=self.getbyte(direccion);
  r.pc:=((r.pc+1) and $7ff) or (r.pc and $800);
end;

function cpu_mcs48.read_byte(direccion:word):byte;
begin
  if self.rom_mask<>0 then read_byte:=self.rom[direccion and self.rom_mask]
    else read_byte:=self.getbyte(direccion);
end;

procedure cpu_mcs48.push_pc_psw;
var
  sp,pila:byte;
begin
  pila:=self.dame_pila;
	sp:=pila and $7;
	self.ram[8+2*sp]:=self.r.pc;
	self.ram[9+2*sp]:=((self.r.pc shr 8) and $0f) or (pila and $f0);
	self.pon_pila((pila and $f0) or ((sp+1) and $7));
end;

function cpu_mcs48.check_irqs:byte;
begin
  check_irqs:=0;
  // if something is in progress, we do nothing
  if self.irq_in_progress then exit;
  // external interrupts take priority
  if (((self.pedir_irq<>CLEAR_LINE) or ((self.sts and STS_IBF)<>0)) and self.xirq_enabled) then begin
     // indicate we took the external IRQ
     // !!!!!!!!!!!!!! --> standard_irq_callback(0);
     check_irqs:=2;
     self.irq_in_progress:=true;
     // force JNI to be taken (hack)
     if self.irq_polled then begin
        self.r.pc:=((self.r.old_pc+1) and $7ff) or (self.r.old_pc and $800);
        self.cond(true);
     end;
     // transfer to location 0x03
     self.push_pc_psw;
     self.r.pc:=$03;
  // timer overflow interrupts follow
  end else if (self.timer_overflow and self.tirq_enabled) then begin
      //!!!!!!!!!!!!!!standard_irq_callback(1, m_pc);
      check_irqs:=2;
      self.irq_in_progress:=true;
      // transfer to location 0x07
      self.push_pc_psw;
      self.r.pc:=$07;
      // timer overflow flip-flop is reset once taken
      self.timer_overflow:=false;
  end;
end;

procedure cpu_mcs48.burn_cycles(count:byte);
var
  timerover:boolean;
  oldtimer,f:byte;
begin
	timerover:=false;
	// if the timer is enabled, accumulate prescaler cycles
	if (self.timecount_enabled=TIMER_ENABLED) then begin
		oldtimer:=self.timer;
		self.prescaler:=self.prescaler+count;
		self.timer:=self.timer+(self.prescaler shr 5);
		self.prescaler:=self.prescaler and $1f;
		timerover:=((oldtimer<>0) and (self.timer=0));
	end else begin
	  // if the counter is enabled, poll the T1 test input once for each cycle
	  if (self.timecount_enabled=COUNTER_ENABLED) then begin
	    for f:=0 to (count-1) do begin
		    self.t1_history:=(self.t1_history shl 1) or (self.test_r(1) and 1);
			  if ((self.t1_history and 3)=2) then begin
          self.timer:=self.timer+1;
          timerover:=(self.timer=0);
        end;
      end;
    end;
  end;
	// if either source caused a timer overflow, set the flags
	if timerover then begin
		self.timer_flag:=true;
		// according to the docs, if an overflow occurs with interrupts disabled, the overflow is not stored
		if (self.tirq_enabled) then self.timer_overflow:=true;
	end;
end;

function cpu_mcs48.p2_mask:byte;
var
  res:byte;
begin
	res:=$ff;
	if ((self.feature_mask and UPI41_FEATURE)=0) then begin
    p2_mask:=res;
    exit;
  end;
	if (self.flags_enabled) then res:=res and not(P2_OBF or P2_NIBF);
	if (self.dma_enabled) then res:=res and not(P2_DRQ or P2_NDACK);
	p2_mask:=res;
end;

procedure cpu_mcs48.add(valor:byte);
var
  tempw,tempw2:word;
begin
  tempw:=self.r.a+valor;
  tempw2:=(self.r.a and $0f)+(valor and $0f);
  self.r.psw.a:=(tempw2 and $10)<>0;
  self.r.psw.c:=(tempw and $100)<>0;
  self.r.a:=tempw;
end;

procedure cpu_mcs48.addc(valor:byte);
var
  tempw,tempw2:word;
  carry:byte;
begin
  carry:=byte(r.psw.c);
  tempw:=self.r.a+valor+carry;
  tempw2:=(self.r.a and $0f)+(valor and $0f)+carry;
  self.r.psw.a:=(tempw2 and $10)<>0;
  self.r.psw.c:=(tempw and $100)<>0;
  self.r.a:=tempw;
end;

procedure cpu_mcs48.cond(test:boolean);
var
  tempw:word;
begin
tempw:=(r.pc and $f00) or self.read_rom(r.pc);
if test then r.pc:=tempw;
end;

procedure cpu_mcs48.run(maximo:single);
var
  tempb:byte;
  tempw:word;
  instruccion,estados_demas:byte;
begin
self.contador:=0;
self.update_regptr;
while self.contador<maximo do begin
if self.pedir_reset<>CLEAR_LINE then begin
  tempb:=self.pedir_reset;
  self.reset;
  if tempb=ASSERT_LINE then begin
    self.pedir_reset:=ASSERT_LINE;
    self.contador:=trunc(maximo);
    exit;
  end;
end;
estados_demas:=self.check_irqs;
r.old_pc:=r.pc;
instruccion:=self.read_rom(r.pc);
self.opcode:=false;
case instruccion of
  $00:; //nop
  $02:if self.chip_type=I8042 then begin //out_dbb_a
          // copy to the DBBO and update the bit in STS
	        self.dbbo:=self.r.a;
	        self.sts:=self.sts or STS_OBF;
	        // if P2 flags are enabled, update the state of P2
	        if (self.flags_enabled and ((self.r.p2 and P2_OBF)=0)) then begin
            self.r.p2:=self.r.p2 or P2_OBF;
            self.port_w(2,self.r.p2);
          end;
         end else begin //outl_bus_a
          MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: $02 outl_bus_a no implementada. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0)
         end;
  $03:self.add(self.read_rom(r.pc)); //add_a_n
  $04,$24,$44,$64,$84,$a4,$c4,$e4:begin  //jmp_XX
        tempb:=self.read_rom(r.pc);
        if self.irq_in_progress then tempw:=0
          else tempw:=self.r.a11;
        self.r.pc:=tempb or tempw or ((instruccion shr 5) shl 8);
    end;
  $05:self.xirq_enabled:=true; //en_i
  $07:r.a:=r.a-1; //dec_a
  $08:if self.chip_type=I8042 then {$ifdef DEBUG}MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: $8 ilegal I8042. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0){$endif}
         else r.a:=self.bus_r; //ins_a_bus
  $09:r.a:=self.port_r(1) and r.p1; //in_a_p1
  $0a:r.a:=self.port_r(2) and r.p2; //in_a_p2
  $10:self.ram[r.r0^ and self.ram_mask]:=self.ram[r.r0^ and self.ram_mask]+1; //inc_xr0
  $11:self.ram[r.r1^ and self.ram_mask]:=self.ram[r.r1^ and self.ram_mask]+1; //inc_xr1
  $12:self.cond((r.a and 1)<>0); //jb_0
  $13:self.addc(self.read_rom(r.pc)); //addc_a_n
  $14,$34,$54,$74,$94,$b4,$d4,$f4:begin //call_XX
        tempb:=self.read_rom(r.pc);
        self.push_pc_psw;
        if self.irq_in_progress then tempw:=0
          else tempw:=self.r.a11;
        self.r.pc:=tempb or tempw or ((instruccion shr 5) shl 8);
      end;
  $15:self.xirq_enabled:=false; //dis_i
  $16:begin //jtf
        self.cond(self.timer_flag);
        self.timer_flag:=false;
      end;
  $17:r.a:=r.a+1; //inc_a
  $18:r.r0^:=r.r0^+1; //inc_r0
  $19:r.r1^:=r.r1^+1; //inc_r1
  $1a:r.r2^:=r.r2^+1; //inc_r2
  $1b:r.r3^:=r.r3^+1; //inc_r3
  $1c:r.r4^:=r.r4^+1; //inc_r4
  $1d:r.r5^:=r.r5^+1; //inc_r5
  $1e:r.r6^:=r.r6^+1; //inc_r6
  $1f:r.r7^:=r.r7^+1; //inc_r7
  $22:if self.chip_type=I8042 then begin //in_a_dbb
          // acknowledge the IBF IRQ and clear the bit in STS
	        //if ((self.sts and STS_IBF)<>0) then
          // !!!!!!!!!!standard_irq_callback(UPI41_INPUT_IBF);
	        self.sts:=self.sts and not(STS_IBF);
	        // if P2 flags are enabled, update the state of P2
	        if (self.flags_enabled and ((self.r.p2 and P2_NIBF)=0)) then begin
            self.r.p2:=self.r.p2 or P2_NIBF;
		        port_w(2,self.r.p2);
          end;
	        self.r.a:=self.dbbi;
         end else begin //ilegal
          MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: $22 ilegal!. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0)
         end;
  $23:r.a:=self.read_rom(r.pc); //mov_a_n
  $25:self.tirq_enabled:=true; //en_tcnti
  $26:self.cond((self.test_r(0)=0));  //jnt_0
  $27:r.a:=0; //clr_a
  $28:begin //xch_a_r0
        tempb:=r.a;
        r.a:=r.r0^;
        r.r0^:=tempb;
      end;
  $29:begin //xch_a_r1
        tempb:=r.a;
        r.a:=r.r1^;
        r.r1^:=tempb;
      end;
  $2a:begin //xch_a_r2
        tempb:=r.a;
        r.a:=r.r2^;
        r.r2^:=tempb;
      end;
  $2b:begin //xch_a_r3
        tempb:=r.a;
        r.a:=r.r3^;
        r.r3^:=tempb;
      end;
  $2c:begin //xch_a_r4
        tempb:=r.a;
        r.a:=r.r4^;
        r.r4^:=tempb;
      end;
  $2d:begin //xch_a_r5
        tempb:=r.a;
        r.a:=r.r5^;
        r.r5^:=tempb;
      end;
  $2e:begin //xch_a_r6
        tempb:=r.a;
        r.a:=r.r6^;
        r.r6^:=tempb;
      end;
  $2f:begin //xch_a_r7
        tempb:=r.a;
        r.a:=r.r7^;
        r.r7^:=tempb;
      end;
  $32:self.cond((r.a and 2)<>0);  //jb_1
  $35:begin //dis_tcnti
        self.tirq_enabled:=false;
        self.timer_overflow:=false;
      end;
  $36:self.cond(self.test_r(0)<>0);  //jt_0
  $37:r.a:=r.a xor $ff; //cpl_a
  $39:begin //outl_p1_a
        self.r.p1:=self.r.a;
        self.port_w(1,self.r.p1);
      end;
  $3a:begin //outl_p2_a
        tempb:=self.p2_mask;
        self.r.p2:=(self.r.p2 and not(tempb)) or (self.r.a and tempb);
        self.port_w(2,self.r.p2);
      end;
  $3c:self.expander_operation(MCS48_EXPANDER_OP_WRITE,4);
  $3d:self.expander_operation(MCS48_EXPANDER_OP_WRITE,5);
  $3e:self.expander_operation(MCS48_EXPANDER_OP_WRITE,6);
  $3f:self.expander_operation(MCS48_EXPANDER_OP_WRITE,7);
  $40:self.r.a:=self.r.a or self.ram[r.r0^ and self.ram_mask]; //orl_a_xr0
  $41:self.r.a:=self.r.a or self.ram[r.r1^ and self.ram_mask]; //orl_a_xr1
  $42:r.a:=self.timer; //mov_a_t
  $43:r.a:=r.a or self.read_rom(r.pc); //orl_a_n
  $45:begin //strt_cnt
        if (self.timecount_enabled<>COUNTER_ENABLED) then self.t1_history:=self.test_r(1);
	      self.timecount_enabled:=COUNTER_ENABLED;
      end;
  $46:self.cond(self.test_r(1)=0);  //jnt_1
  $47:r.a:=(r.a shl 4) or (r.a shr 4); //swap_a
  $48:r.a:=r.a or r.r0^; //orl_a_r0
  $49:r.a:=r.a or r.r1^; //orl_a_r1
  $4a:r.a:=r.a or r.r2^; //orl_a_r2
  $4b:r.a:=r.a or r.r3^; //orl_a_r3
  $4c:r.a:=r.a or r.r4^; //orl_a_r4
  $4d:r.a:=r.a or r.r5^; //orl_a_r5
  $4e:r.a:=r.a or r.r6^; //orl_a_r6
  $4f:r.a:=r.a or r.r7^; //orl_a_r7
  $52:self.cond((r.a and 4)<>0);  //jb_2
  $53:self.r.a:=self.r.a and self.read_rom(r.pc); //anl_a_n
  $55:begin  //strt_t
        self.timecount_enabled:=TIMER_ENABLED;
        self.prescaler:=0;
      end;
  $56:self.cond(self.test_r(1)<>0);  //jt_1
  $57:begin //da_a
        if (((self.r.a and $f)>$9) or self.r.psw.a) then begin
          if (self.r.a>$f9) then self.r.psw.c:=true;
          self.r.a:=self.r.a+$06;
	      end;
	      if (((self.r.a and $f0)>$90) or self.r.psw.c) then begin
	        self.r.a:=self.r.a+$60;
	        self.r.psw.c:=true;
	      end;
      end;
  $58:r.a:=r.a and r.r0^; //anl_a_r0
  $59:r.a:=r.a and r.r1^; //anl_a_r1
  $5a:r.a:=r.a and r.r2^; //anl_a_r2
  $5b:r.a:=r.a and r.r3^; //anl_a_r3
  $5c:r.a:=r.a and r.r4^; //anl_a_r4
  $5d:r.a:=r.a and r.r5^; //anl_a_r5
  $5e:r.a:=r.a and r.r6^; //anl_a_r6
  $5f:r.a:=r.a and r.r7^; //anl_a_r7
  $60:self.add(self.ram[self.r.r0^ and self.ram_mask]); //add_a_xr0
  $61:self.add(self.ram[self.r.r1^ and self.ram_mask]); //add_a_xr1
  $62:self.timer:=r.a; //mov_t_a
  $65:self.timecount_enabled:=0; //stop_tcnt
  $67:begin //rrc_a
        tempb:=r.a;
        r.a:=(r.a shr 1) or (byte(r.psw.c) shl 7);
        r.psw.c:=(tempb and 1)<>0;
      end;
  $68:self.add(r.r0^); //add_a_r0
  $69:self.add(r.r1^); //add_a_r1
  $6a:self.add(r.r2^); //add_a_r2
  $6b:self.add(r.r3^); //add_a_r3
  $6c:self.add(r.r4^); //add_a_r4
  $6d:self.add(r.r5^); //add_a_r5
  $6e:self.add(r.r6^); //add_a_r6
  $6f:self.add(r.r7^); //add_a_r7
  $70:self.addc(self.ram[r.r0^ and self.ram_mask]);  //adc_a_xr0
  $71:self.addc(self.ram[r.r1^ and self.ram_mask]);  //adc_a_xr1
  $72:self.cond((r.a and 8)<>0);  //jb_3
  $75:if self.chip_type<>N7751 then{$ifdef DEBUG}MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: $75 desconocida. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0){$endif};
  $76:self.cond(self.f1);  //jf1
  $77:r.a:=(r.a shr 1) or (r.a shl 7); //rr_a
  $78:self.addc(r.r0^); //adc_a_r0
  $79:self.addc(r.r1^); //adc_a_r1
  $7a:self.addc(r.r2^); //adc_a_r2
  $7b:self.addc(r.r3^); //adc_a_r3
  $7c:self.addc(r.r4^); //adc_a_r4
  $7d:self.addc(r.r5^); //adc_a_r5
  $7e:self.addc(r.r6^); //adc_a_r6
  $7f:self.addc(r.r7^); //adc_a_r7
  $80:if self.chip_type=I8042 then {$ifdef DEBUG}MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: $80 ilegal I8042. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0){$endif}
         else if addr(self.ext_inport)<>nil then self.r.a:=self.ext_inport(self.r.r0^) //movx_a_xr0
          else self.r.a:=$ff;
  $81:if self.chip_type=I8042 then {$ifdef DEBUG}MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: $81 ilegal I8042. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0){$endif}
         else if addr(self.ext_inport)<>nil then self.r.a:=self.ext_inport(self.r.r1^) //movx_a_xr1
          else self.r.a:=$ff;
  $83:begin //ret
        tempb:=(self.dame_pila-1) and $7;
	      r.pc:=self.ram[8+2*tempb];
	      r.pc:=r.pc or (self.ram[9+2*tempb] shl 8);
	      if self.irq_in_progress then r.pc:=r.pc and $7ff
           else r.pc:=r.pc and $fff;
	      self.pon_pila((self.dame_pila and $f0) or tempb);
      end;
  $85:r.psw.f:=false; //clr_f0
  $86:if self.chip_type=I8042 then begin
            self.cond((self.sts and STS_OBF)<>0);
         end else begin //jni
              self.irq_polled:=(self.pedir_irq<>CLEAR_LINE);
              self.cond(self.pedir_irq<>CLEAR_LINE);
         end;
  $89:begin //orl_p1_n
        self.r.p1:=self.r.p1 or self.read_rom(r.pc);
        self.port_w(1,self.r.p1);
      end;
  $8a:begin //orl_p2_n
        self.r.p2:=self.r.p2 or (self.read_rom(r.pc) and self.p2_mask);
        self.port_w(2,self.r.p2);
      end;
  $90:if self.chip_type=I8042 then begin //mov_sts_a
            self.sts:=(self.sts and $0f) or (self.r.a and $f0);
         end else begin //movx_xr0_a
          estados_demas:=estados_demas+1;
          if addr(self.ext_outport)<>nil then self.ext_outport(self.r.r0^,self.r.a);
         end;
  $92:self.cond((r.a and $10)<>0);  //jb_4
  $93:begin //retr
        // implicitly clear the IRQ in progress flip flop
	      self.irq_in_progress:=false;
        tempb:=(self.dame_pila-1) and $7;
	      r.pc:=self.ram[8+2*tempb];
	      r.pc:=r.pc or (self.ram[9+2*tempb] shl 8);
	      self.pon_pila(((r.pc shr 8) and $f0) or tempb);
	      r.pc:=r.pc and $fff;
	      self.update_regptr;
      end;
  $95:r.psw.f:=not(r.psw.f); //cpl_f0
  $96:self.cond(r.a<>0);  //jnz
  $97:r.psw.c:=false; //clr_c
  $99:begin //anl_p1_n
        r.p1:=r.p1 and self.read_rom(r.pc);
        self.port_w(1,r.p1);
      end;
  $9a:begin //anl_p2_n
        r.p2:=r.p2 and (self.read_rom(r.pc) or not(self.p2_mask));
        self.port_w(2,r.p2);
      end;
  $a0:self.ram[self.r.r0^ and self.ram_mask]:=self.r.a; //mov_xr0_a
  $a1:self.ram[self.r.r1^ and self.ram_mask]:=self.r.a; //mov_xr1_a
  $a3:r.a:=self.read_byte((r.pc and $f00) or r.a); //movp_a_xa
  $a5:self.f1:=false; //clr_f1
  $a8:r.r0^:=r.a; //mov_r0_a
  $a9:r.r1^:=r.a; //mov_r1_a
  $aa:r.r2^:=r.a; //mov_r2_a
  $ab:r.r3^:=r.a; //mov_r3_a
  $ac:r.r4^:=r.a; //mov_r4_a
  $ad:r.r5^:=r.a; //mov_r5_a
  $ae:r.r6^:=r.a; //mov_r6_a
  $af:r.r7^:=r.a; //mov_r7_a
  $b0:self.ram[self.r.r0^ and self.ram_mask]:=self.read_rom(self.r.pc);  //mov_xr0_n
  $b1:self.ram[self.r.r1^ and self.ram_mask]:=self.read_rom(self.r.pc);  //mov_xr1_n
  $b2:self.cond((r.a and $20)<>0);  //jb_5
  $b3:begin //jmpp_xa
        self.r.pc:=self.r.pc and $f00;
        self.r.pc:=self.r.pc or self.read_byte(self.r.pc or self.r.a);
      end;
  $b5:self.f1:=not(self.f1); //cpl_f1
  $b6:self.cond(r.psw.f); //jf0
  $b8:self.r.r0^:=self.read_rom(r.pc); //mov_r0_n
  $b9:self.r.r1^:=self.read_rom(r.pc); //mov_r1_n
  $ba:self.r.r2^:=self.read_rom(r.pc); //mov_r1_n
  $bb:self.r.r3^:=self.read_rom(r.pc); //mov_r3_n
  $bc:self.r.r4^:=self.read_rom(r.pc); //mov_r4_n
  $bd:self.r.r5^:=self.read_rom(r.pc); //mov_r5_n
  $be:self.r.r6^:=self.read_rom(r.pc); //mov_r6_n
  $bf:self.r.r7^:=self.read_rom(r.pc); //mov_r7_n
  $c5:begin //sel_rb0
        r.psw.b:=false;
        self.update_regptr;
      end;
  $c6:self.cond(r.a=0);  //jz
  $c7:self.r.a:=self.dame_pila or 8;//mov_a_psw
  $c8:r.r0^:=r.r0^-1; //dec_r0
  $c9:r.r1^:=r.r1^-1; //dec_r1
  $ca:r.r2^:=r.r2^-1; //dec_r2
  $cb:r.r3^:=r.r3^-1; //dec_r3
  $cc:r.r4^:=r.r4^-1; //dec_r4
  $cd:r.r5^:=r.r5^-1; //dec_r5
  $ce:r.r6^:=r.r6^-1; //dec_r6
  $cf:r.r7^:=r.r7^-1; //dec_r7
  $d2:self.cond((r.a and $40)<>0);  //jb_6
  $d3:r.a:=r.a xor self.read_rom(r.pc); //xrl_a_n
  $d5:begin  //sel_rb1
        r.psw.b:=true;
        self.update_regptr;
      end;
  $d6:if self.chip_type=I8042 then begin //jnibf
        self.irq_polled:=(self.sts and STS_IBF)<>0;
        self.cond((self.sts and STS_IBF)=0);
      end else {$ifdef DEBUG}MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: $d6 ilegal. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0){$endif};
  $d7:begin //mov_psw_a
        self.pon_pila(self.r.a and $f7);
        self.update_regptr;
      end;
  $d8:r.a:=r.a xor r.r0^; //xrl_a_r0
  $d9:r.a:=r.a xor r.r1^; //xrl_a_r1
  $da:r.a:=r.a xor r.r2^; //xrl_a_r2
  $db:r.a:=r.a xor r.r3^; //xrl_a_r3
  $dc:r.a:=r.a xor r.r4^; //xrl_a_r4
  $dd:r.a:=r.a xor r.r5^; //xrl_a_r5
  $de:r.a:=r.a xor r.r6^; //xrl_a_r6
  $df:r.a:=r.a xor r.r7^; //xrl_a_r7
  $e3:r.a:=self.read_byte($300 or r.a);  //movp3_a_xa
  $e5:if self.chip_type=I8042 then begin
         {$ifdef DEBUG}MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: $e5 en dma I8042. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0){$endif}
         end else self.r.a11:=0;   //sel_mb0
  $e6:self.cond(not(r.psw.c));  //jnc
  $e7:r.a:=(r.a shl 1) or (r.a shr 7); //rl_a
  $e8:begin //djnz_r0
        r.r0^:=r.r0^-1;
        self.cond(r.r0^<>0);
      end;
  $e9:begin //djnz_r1
        r.r1^:=r.r1^-1;
        self.cond(r.r1^<>0);
      end;
  $ea:begin //djnz_r2
        r.r2^:=r.r2^-1;
        self.cond(r.r2^<>0);
      end;
  $eb:begin //djnz_r3
        r.r3^:=r.r3^-1;
        self.cond(r.r3^<>0);
      end;
  $ec:begin //djnz_r4
        r.r4^:=r.r4^-1;
        self.cond(r.r4^<>0);
      end;
  $ed:begin //djnz_r5
        r.r5^:=r.r5^-1;
        self.cond(r.r5^<>0);
      end;
  $ee:begin //djnz_r6
        r.r6^:=r.r6^-1;
        self.cond(r.r6^<>0);
      end;
  $ef:begin //djnz_r7
        r.r7^:=r.r7^-1;
        self.cond(r.r7^<>0);
      end;
  $f0:r.a:=self.ram[r.r0^ and self.ram_mask]; //mov_a_xr0
  $f1:r.a:=self.ram[r.r1^ and self.ram_mask]; //mov_a_xr1
  $f2:self.cond((r.a and $80)<>0);  //jb_7
  $f5:if self.chip_type=I8042 then begin
         {$ifdef DEBUG}MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: $f5 en flags I8042. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0){$endif}
         end else r.a11:=$800; //sel_mb1
  $f6:self.cond(r.psw.c);  //jc
  $f7:begin //rlc_a
        tempb:=r.a;
        r.a:=(r.a shl 1) or byte(r.psw.c);
        r.psw.c:=(tempb and $80)<>0;
      end;
  $f8:self.r.a:=self.r.r0^; //mov_a_r0
  $f9:self.r.a:=self.r.r1^; //mov_a_r1
  $fa:self.r.a:=self.r.r2^; //mov_a_r2
  $fb:self.r.a:=self.r.r3^; //mov_a_r3
  $fc:self.r.a:=self.r.r4^; //mov_a_r4
  $fd:self.r.a:=self.r.r5^; //mov_a_r5
  $fe:self.r.a:=self.r.r6^; //mov_a_r6
  $ff:self.r.a:=self.r.r7^; //mov_a_r7
  else MessageDlg('Num CPU '+inttostr(self.numero_cpu)+' instruccion: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(r.pc-1,10)+' '+inttohex(r.old_pc,10),mtInformation,[mbOk], 0);
end;
{$ifdef DEBUG}if ciclos_mcs48[instruccion]=0 then
        MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: '+inttohex(instruccion,2)+' con T cero. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0);{$endif}
tempb:=ciclos_mcs48[instruccion]+estados_demas;
self.contador:=self.contador+tempb;
if (self.timecount_enabled<>0) then burn_cycles(tempb);
timers.update(tempb,self.numero_cpu);
end;
end;

end.
