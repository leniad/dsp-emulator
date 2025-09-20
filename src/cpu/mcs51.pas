unit mcs51;
interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     dialogs,sysutils,timer_engine,main_engine,cpu_misc;

type
        band_mcs51=record
                p,o,r_bank0,r_bank1,u,a,c:boolean;
        end;
        reg_mcs51=record
                pc:word;
                psw:band_mcs51;
        end;
        preg_mcs51=^reg_mcs51;
        cpu_mcs51=class(cpu_class)
                constructor create(tipo:byte;clock:dword;frames_div:word);
                destructor free;
            public
                procedure run(maximo:single);
                procedure reset;
                procedure change_irq0(state:byte);
                procedure change_irq1(state:byte);
                procedure change_io_calls(in_port0,in_port1,in_port2,in_port3:cpu_inport_call;out_port0,out_port1,out_port2,out_port3:cpu_outport_call);
                function get_rom_addr:pbyte;
                function save_snapshot(data:pbyte):word;
                procedure load_snapshot(data:pbyte);
                procedure set_port_forced_input(port,valor:byte);
            private
                r:preg_mcs51;
                pedir_irq0,pedir_irq1:byte;
                calc_parity,rwm:boolean;
                t0_cnt,t1_cnt:word;
                ram,sfr:array[0..$ff] of byte;
                rom:array[0..$1fff] of byte;
                irq_prio:array[0..7] of byte;
                features,num_interrupts,irq_active:byte;
                cur_irq_prio:shortint;
                last_line_state:dword;
                in_port0,in_port1,in_port2,in_port3:cpu_inport_call;
                out_port0,out_port1,out_port2,out_port3:cpu_outport_call;
                forced_input:array[0..3] of byte;
                function dame_pila:byte;
                procedure pon_pila(valor:byte);
                procedure do_add_flags(a,data,c:byte);
                procedure do_sub_flags(a,data,c:byte);
                procedure	update_irq_prio(ipl,iph:byte);
                procedure iram_w(pos,valor:byte);
                function iram_r(pos:byte):byte;
                procedure iram_iw(pos,valor:byte);
                function iram_ir(pos:byte):byte;
                procedure update_timer_t0(cycles:byte);
                procedure update_timer_t1(cycles:byte);
                procedure update_timer_t2(cycles:byte);
                function bit_address_r(pos:byte):byte;
                procedure bit_address_w(pos,bit:byte);
                procedure pop_pc;
                procedure push_pc;
                procedure clear_irqs;
                function evalue_irq:byte;
                function r_reg(addr:byte):byte;
                procedure set_reg(addr,valor:byte);
        end;
const
  I8X51=0;
  I8X52=1;
  I8XC51=2;
  I8XC52=3;

var
  mcs51_0:cpu_mcs51;

implementation
const
  ciclos_mcs51:array[0..$ff] of byte=(
         1,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,
         2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,
	       2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,
	       2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,
       	 2,2,1,2,1,1,1,1,1,1,1,1,1,1,1,1,
	       2,2,1,2,1,1,1,1,1,1,1,1,1,1,1,1,
         2,2,1,2,1,1,1,1,1,1,1,1,1,1,1,1,
         2,2,2,2,1,2,1,1,1,1,1,1,1,1,1,1,
	       2,2,2,2,4,2,2,2,2,2,2,2,2,2,2,2,
	       2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,
	       2,2,1,2,4,1,2,2,2,2,2,2,2,2,2,2,
	       2,2,1,1,2,2,2,2,2,2,2,2,2,2,2,2,
	       2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
	       2,2,1,1,1,2,1,1,2,2,2,2,2,2,2,2,
	       2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,
	       2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1);

  //SFM memory pos
  ADDR_PSW=$d0;
	ADDR_ACC=$e0;
	ADDR_B  =$f0;
	ADDR_P0	=$80;
	ADDR_SP	=$81;
	ADDR_DPL=$82;
	ADDR_DPH=$83;
	ADDR_PCON=$87;
	ADDR_TCON=$88;
	ADDR_TMOD=$89;
	ADDR_TL0=$8a;
	ADDR_TL1=$8b;
	ADDR_TH0=$8c;
	ADDR_TH1=$8d;
	ADDR_P1	=$90;
	ADDR_SCON=$98;
	ADDR_SBUF=$99;
	ADDR_P2	=$a0;
	ADDR_IE	=$a8;  //Activar/desactivar interrupciones
	ADDR_P3	=$b0;
	ADDR_IP	=$b8;  //Prioridad en las IRQ
  // 8052 Only registers
	ADDR_T2CON  = $c8;
	ADDR_RCAP2L = $ca;
	ADDR_RCAP2H = $cb;
	ADDR_TL2    = $cc;
	ADDR_TH2    = $cd;

	// 80C52 Only registers
	ADDR_IPH    = $b7;
	ADDR_SADDR  = $a9;
	ADDR_SADEN  = $b9;

	// DS5002FP
	ADDR_CRCR   = $c1;
	ADDR_CRCL   = $c2;
	ADDR_CRCH   = $c3;
	ADDR_MCON   = $c6;
	ADDR_TA     = $c7;
	ADDR_RNR    = $cf;
	ADDR_RPCTL  = $d8;
	ADDR_RPS    = $da;

  //vectors
  V_RESET=$000;	// power on address
	V_IE0  =$003;	// External Interrupt 0
	V_TF0	 =$00b;	// Timer 0 Overflow
	V_IE1	 =$013;	// External Interrupt 1
	V_TF1	 =$01b;	// Timer 1 Overflow
	V_RITI =$023;	// Serial Receive/Transmit
  //IRQs
  MCS51_INT0_LINE=0;
  MCS51_INT1_LINE=1;

  //Features
  FEATURE_I8052=1;
  FEATURE_I80C52=2;
  FEATURE_CMOS=4;

constructor cpu_mcs51.create(tipo:byte;clock:dword;frames_div:word);
begin
getmem(self.r,sizeof(reg_mcs51));
fillchar(self.r^,sizeof(reg_mcs51),0);
self.clock:=clock div 12;
self.numero_cpu:=cpu_main_init(clock div 12);
self.tframes:=(clock/12/frames_div)/llamadas_maquina.fps_max;
self.in_port0:=nil;
self.in_port1:=nil;
self.in_port2:=nil;
self.in_port3:=nil;
self.out_port0:=nil;
self.out_port1:=nil;
self.out_port2:=nil;
self.out_port3:=nil;
case tipo of
  I8X51:begin
          self.num_interrupts:=5;
          self.features:=0;
        end;
  I8X52:begin
          self.num_interrupts:=6;
          self.features:=FEATURE_I8052;
        end;
  I8XC51:begin
            self.num_interrupts:=5;
            self.features:=FEATURE_CMOS;
         end;
  I8XC52:begin
            self.num_interrupts:=6;
            self.features:=FEATURE_I8052 or FEATURE_I80C52 or FEATURE_CMOS;
         end;
end;
if ((tipo=I8X52) or (tipo=I8XC52)) then self.num_interrupts:=6
  else self.num_interrupts:=5;
end;

destructor cpu_mcs51.free;
begin
freemem(self.r);
end;

procedure cpu_mcs51.change_io_calls(in_port0,in_port1,in_port2,in_port3:cpu_inport_call;out_port0,out_port1,out_port2,out_port3:cpu_outport_call);
begin
  self.in_port0:=in_port0;
  self.in_port1:=in_port1;
  self.in_port2:=in_port2;
  self.in_port3:=in_port3;
  self.out_port0:=out_port0;
  self.out_port1:=out_port1;
  self.out_port2:=out_port2;
  self.out_port3:=out_port3;
end;

procedure cpu_mcs51.set_port_forced_input(port,valor:byte);
begin
  self.forced_input[port]:=valor;
end;

function cpu_mcs51.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
begin
  temp:=data;
  copymemory(temp,self.r,sizeof(reg_mcs51));inc(temp,sizeof(reg_mcs51));size:=sizeof(reg_mcs51);
  copymemory(temp,@self.ram[0],$100);inc(temp,$100);size:=size+$100;
  copymemory(temp,@self.sfr[0],$100);inc(temp,$100);size:=size+$100;
  copymemory(temp,@self.irq_prio[0],8);inc(temp,8);size:=size+8;
  copymemory(temp,@self.t0_cnt,2);inc(temp,2);size:=size+2;
  copymemory(temp,@self.t1_cnt,2);inc(temp,2);size:=size+2;
  copymemory(temp,@self.cur_irq_prio,sizeof(shortint));inc(temp,sizeof(shortint));size:=size+sizeof(shortint);
  temp^:=self.pedir_irq0;inc(temp);size:=size+1;
  temp^:=self.pedir_irq1;inc(temp);size:=size+1;
  temp^:=byte(self.calc_parity);inc(temp);size:=size+1;
  temp^:=byte(self.rwm);inc(temp);size:=size+1;
  temp^:=self.num_interrupts;inc(temp);size:=size+1;
  temp^:=self.irq_active;
  save_snapshot:=size;
end;

procedure cpu_mcs51.load_snapshot(data:pbyte);
var
  temp:pbyte;
begin
  temp:=data;
  copymemory(self.r,temp,sizeof(reg_mcs51));inc(temp,sizeof(reg_mcs51));
  copymemory(@self.ram[0],temp,$100);inc(temp,$100);
  copymemory(@self.sfr[0],temp,$100);inc(temp,$100);
  copymemory(@self.irq_prio[0],temp,8);inc(temp,8);
  copymemory(@self.t0_cnt,temp,2);inc(temp,2);
  copymemory(@self.t1_cnt,temp,2);inc(temp,2);
  copymemory(@self.cur_irq_prio,temp,sizeof(shortint));inc(temp,sizeof(shortint));
  self.pedir_irq0:=temp^;inc(temp);
  self.pedir_irq1:=temp^;inc(temp);
  self.calc_parity:=(temp^<>0);inc(temp);
  self.rwm:=(temp^<>0);inc(temp);
  self.num_interrupts:=temp^;inc(temp);
  self.irq_active:=temp^;
end;

function cpu_mcs51.get_rom_addr:pbyte;
begin
  get_rom_addr:=@self.rom[0];
end;

function get_bit(r,n:byte):byte;
begin
  get_bit:=(r shr n) and 1;
end;

procedure set_bit(num:pbyte;pos,valor:byte);
var
  tempb:byte;
begin
 tempb:=not(1 shl pos);
 num^:=(num^ and tempb) or (valor shl pos);
end;

procedure cpu_mcs51.change_irq0(state:byte);
var
  new_state,tr_state:dword;
begin
new_state:=(self.last_line_state and $fffffffe) or byte(state<>CLEAR_LINE);
// detect 0->1 transitions
tr_state:=(not(self.last_line_state)) and new_state;
if (state<>CLEAR_LINE) then begin
  //Need cleared->active line transition? (Logical 1-0 Pulse on the line) - CLEAR->ASSERT Transition since INT0 active lo!
	if GET_BIT(self.sfr[ADDR_TCON],0)<>0 then begin
		if (GET_BIT(tr_state,MCS51_INT0_LINE))<>0 then SET_BIT(@self.sfr[ADDR_TCON],1,1);
  end else begin
    SET_BIT(@self.sfr[ADDR_TCON],1,1);     //Nope, just set it..
  end;
end	else begin
  if GET_BIT(self.sfr[ADDR_TCON],0)=0 then SET_BIT(@self.sfr[ADDR_TCON],1,0); // clear if level triggered
end;
self.last_line_state:=new_state;
self.pedir_irq0:=state;
end;

procedure cpu_mcs51.change_irq1(state:byte);
var
  new_state,tr_state:dword;
begin
new_state:=(self.last_line_state and $fffffffd) or (byte(state<>CLEAR_LINE) shl 1);
// detect 0->1 transitions
tr_state:=(not(self.last_line_state)) and new_state;
if (state<>CLEAR_LINE) then begin
				//Need cleared->active line transition? (Logical 1-0 Pulse on the line) - CLEAR->ASSERT Transition since INT1 active lo!
				if GET_BIT(self.sfr[ADDR_TCON],2)<>0 then begin
					if GET_BIT(tr_state,MCS51_INT1_LINE)<>0 then begin
            SET_BIT(@self.sfr[ADDR_TCON],3,1);
          end;
        end else begin
					SET_BIT(@self.sfr[ADDR_TCON],3,1);     //Nope, just set it..
        end;
end else begin
  if GET_BIT(self.sfr[ADDR_TCON],2)=0 then SET_BIT(@self.sfr[ADDR_TCON],3,0);  // clear if level triggered
end;
self.last_line_state:=new_state;
self.pedir_irq1:=state;
end;

procedure cpu_mcs51.reset;
begin
  fillchar(self.ram[0],$100,0);
  fillchar(self.sfr[0],$100,0);
  self.forced_input[0]:=0;
  self.forced_input[1]:=0;
  self.forced_input[2]:=0;
  self.forced_input[3]:=0;
  r.pc:=V_RESET;
  self.sfr[ADDR_SP]:=$7;
  self.pon_pila(0);
  self.calc_parity:=false;
  self.rwm:=false;
  self.sfr[ADDR_ACC]:=0;
  self.sfr[ADDR_B]:=0;
  self.sfr[ADDR_IP]:=0;
  self.sfr[ADDR_IE]:=0;
  // set the port configurations to all 1's
  self.sfr[ADDR_P3]:=$ff;
  if @self.out_port3<>nil then self.out_port3($ff);
  self.sfr[ADDR_P2]:=$ff;
  if @self.out_port2<>nil then self.out_port2($ff);
  self.sfr[ADDR_P1]:=$ff;
  if @self.out_port1<>nil then self.out_port1($ff);
  self.sfr[ADDR_P0]:=$ff;
  if @self.out_port0<>nil then self.out_port0($ff);
  self.pedir_irq0:=CLEAR_LINE;
  self.pedir_irq1:=CLEAR_LINE;
  self.irq_active:=0;
  self.cur_irq_prio:=-1;
  // 8052 Only registers
  if (self.features and FEATURE_I8052)<>0 then begin
		self.sfr[ADDR_T2CON]:=0;
		self.sfr[ADDR_RCAP2L]:=0;
		self.sfr[ADDR_RCAP2H]:=0;
		self.sfr[ADDR_TL2]:=0;
		self.sfr[ADDR_TH2]:=0;
	end;
	// 80C52 Only registers
	if (self.features and FEATURE_I80C52)<>0 then begin
		self.sfr[ADDR_IPH]:=0;
		update_irq_prio(self.sfr[ADDR_IP],self.sfr[ADDR_IPH]);
		self.sfr[ADDR_SADDR]:=0;
		self.sfr[ADDR_SADEN]:=0;
	end;
end;

function cpu_mcs51.dame_pila:byte;
var
  temp:byte;
begin
  temp:=0;
  if r.psw.c then temp:=temp or $80;
  if r.psw.a then temp:=temp or $40;
  if r.psw.u then temp:=temp or $20;
  if r.psw.r_bank0 then temp:=temp or $10;
  if r.psw.r_bank1 then temp:=temp or 8;
  if r.psw.o then temp:=temp or 4;
  if r.psw.p then temp:=temp or 1;
  dame_pila:=temp;
  self.calc_parity:=true;
end;

procedure cpu_mcs51.pon_pila(valor:byte);
begin
  r.psw.c:=(valor and $80)<>0;
  r.psw.a:=(valor and $40)<>0;
  r.psw.u:=(valor and $20)<>0;
  r.psw.r_bank0:=(valor and $10)<>0;
  r.psw.r_bank1:=(valor and 8)<>0;
  r.psw.o:=(valor and 4)<>0;
  r.psw.p:=(valor and 1)<>0;
  self.sfr[ADDR_PSW]:=valor;
end;

procedure cpu_mcs51.do_add_flags(a,data,c:byte);
var
  result:word;
  result1:smallint;
begin
	result:=a+data+c;
	result1:=shortint(a)+shortint(data)+c;
  r.psw.c:=(result and $100)<>0;
	result:=(a and $0f)+(data and $0f)+c;
  r.psw.a:=(result and $10)<>0;
  r.psw.o:=(result1<-128) or (result1>127);
  self.sfr[ADDR_PSW]:=self.dame_pila;
  self.calc_parity:=true;
end;

procedure cpu_mcs51.do_sub_flags(a,data,c:byte);
var
  result:word;
  result1:smallint;
begin
	result:=a-(data+c);
	result1:=shortint(a)-shortint(data+c);
	r.psw.c:=(result and $100)<>0;
  result:=(a and $0f)-(data and $0f)+c;
  r.psw.a:=(result and $10)<>0;
  r.psw.o:=(result1<-128) or (result1>127);
  self.sfr[ADDR_PSW]:=self.dame_pila;
  self.calc_parity:=true;
end;

// Check and update status of serial port
procedure	cpu_mcs51.update_irq_prio(ipl,iph:byte);
var
  i:byte;
begin
	for i:=0 to 7 do self.irq_prio[i]:=((ipl shr i) and 1) or (((iph shr i ) and 1) shl 1);
end;

procedure cpu_mcs51.iram_w(pos,valor:byte);
begin
  case pos of
    0..$7f:begin
            self.ram[pos]:=valor;
            exit;
           end;
    ADDR_ACC:self.calc_parity:=true;
    ADDR_PSW:begin
                self.pon_pila(valor);
                self.calc_parity:=true;
             end;
    ADDR_P0:if @self.out_port0<>nil then self.out_port0(valor);
    ADDR_P1:if @self.out_port1<>nil then self.out_port1(valor);
    ADDR_P2:if @self.out_port2<>nil then self.out_port2(valor);
    ADDR_P3:if @self.out_port3<>nil then self.out_port3(valor);
    ADDR_IP:self.update_irq_prio(valor,0);
  end;
  self.sfr[pos]:=valor;
end;

function cpu_mcs51.iram_r(pos:byte):byte;
var
  res:byte;
begin
  res:=$ff;
  case pos of
    $0..$7f:res:=self.ram[pos];
    ADDR_SP,ADDR_ACC,ADDR_PSW,ADDR_B,ADDR_DPL,ADDR_DPH,ADDR_TCON,ADDR_TMOD,ADDR_IE,ADDR_IP:res:=self.sfr[pos];
    ADDR_P0:if self.rwm then res:=self.sfr[ADDR_P0]
            else if @self.in_port0<>nil then res:=(self.sfr[ADDR_P0] or self.forced_input[0]) and self.in_port0;
    ADDR_P1:if self.rwm then res:=self.sfr[ADDR_P1]
            else if @self.in_port1<>nil then res:=(self.sfr[ADDR_P1] or self.forced_input[1]) and self.in_port1;
    ADDR_P2:if self.rwm then res:=self.sfr[ADDR_P2]
            else if @self.in_port2<>nil then res:=(self.sfr[ADDR_P2] or self.forced_input[2]) and self.in_port2;
    ADDR_P3:if self.rwm then res:=self.sfr[ADDR_P3]
            else begin
                    if @self.in_port3<>nil then res:=(self.sfr[ADDR_P3] or self.forced_input[3]) and self.in_port3;
                    if self.pedir_irq0<>CLEAR_LINE then res:=res and $fb;
                    if self.pedir_irq1<>CLEAR_LINE then res:=res and $f7;
            end;
    else MessageDlg('Num CPU '+inttostr(self.numero_cpu)+' iram_r desconocida: '+inttohex(pos,2)+' desconocida. PC='+inttohex(r.pc-1,10), mtInformation,[mbOk], 0);
  end;
  iram_r:=res;
end;

function cpu_mcs51.iram_ir(pos:byte):byte;
begin
  if (self.features and FEATURE_I8052)<>0 then iram_ir:=self.ram[pos]
    else if pos<$80 then iram_ir:=self.ram[pos]
      else iram_ir:=$ff;
end;

procedure cpu_mcs51.iram_iw(pos,valor:byte);
begin
  if (self.features and FEATURE_I8052)<>0 then self.ram[pos]:=valor
    else if pos<$80 then self.ram[pos]:=valor;
end;

procedure cpu_mcs51.update_timer_t0(cycles:byte);
var
  mode:byte;
  count,delta:dword;
begin
	mode:=(GET_BIT(self.sfr[ADDR_TMOD],1) shl 1) or GET_BIT(self.sfr[ADDR_TMOD],0);
	if (GET_BIT(self.sfr[ADDR_TCON],4))<>0 then begin
		// counter / external input
    if GET_BIT(self.sfr[ADDR_TMOD],2)<>0 then delta:=self.t0_cnt
      else delta:=cycles;
		// taken, reset
		self.t0_cnt:=0;
		if ((GET_BIT(self.sfr[ADDR_TMOD],3)<>0) and (GET_BIT(self.sfr[ADDR_TCON],1)=0)) then delta:=0;
    case mode of
      0:begin  // 13 Bit Timer Mode
          count:=((self.sfr[ADDR_TH0] shl 5) or (self.sfr[ADDR_TL0] and $1f));
          count:=count+delta;
	  			if (count and $ffffe000)<>0 then SET_BIT(@self.sfr[ADDR_TCON],5,1);
		  		self.sfr[ADDR_TH0]:=(count shr 5) and $ff;
			  	self.sfr[ADDR_TL0]:=count and $1f ;
        end;
      1:begin  // 16 Bit Timer Mode
          count:=(self.sfr[ADDR_TH0] shl 8) or self.sfr[ADDR_TL0];
  			  count:=count+delta;
	  		  if (count and $ffff0000)<>0 then SET_BIT(@self.sfr[ADDR_TCON],5,1);
		  		self.sfr[ADDR_TH0]:=(count shr 8) and $ff;
			  	self.sfr[ADDR_TL0]:=count and $ff ;
        end;
      2:begin //8 bit Autoreload
          count:=self.sfr[ADDR_TL0]+delta;
					if (count and $ffffff00)<>0 then begin
            SET_BIT(@self.sfr[ADDR_TCON],5,1);
					  count:=count+self.sfr[ADDR_TH0];
          end;
 					// Update new values of the counter
					self.sfr[ADDR_TL0]:=count and $ff;
        end;
      3:begin	// Split Timer 1
				  count:=self.sfr[ADDR_TL0]+delta;
				  if (count and $ffffff00 )<>0 then SET_BIT(@self.sfr[ADDR_TCON],5,1);
				  self.sfr[ADDR_TL0]:=count and $ff;
        end;
    end;
  end;
  if (GET_BIT(self.sfr[ADDR_TCON],6))<>0 then begin
    case mode of
      3:begin	// Split Timer 2
          count:=self.sfr[ADDR_TH0]+cycles;
			    if (count and $ffffff00)<>0 then SET_BIT(@self.sfr[ADDR_TCON],7,1);
			    self.sfr[ADDR_TH0]:=count and $ff;
        end;
    end;
  end;
end;

procedure cpu_mcs51.update_timer_t1(cycles:byte);
var
  mode,mode_0:byte;
  count,delta,overflow:dword;
begin
	mode:=((get_bit(self.sfr[ADDR_TMOD],5) shl 1) or (get_bit(self.sfr[ADDR_TMOD],4)));
	mode_0:=((get_bit(self.sfr[ADDR_TMOD],1) shl 1) or (get_bit(self.sfr[ADDR_TMOD],0)));
	if (mode_0<>3) then begin
		if (get_bit(self.sfr[ADDR_TCON],6))<>0 then begin
			// counter / external input
      if (get_bit(self.sfr[ADDR_TMOD],6))<>0 then delta:=self.t1_cnt
        else delta:=cycles;
			// taken, reset
			self.t1_cnt:=0;
			if ((get_bit(self.sfr[ADDR_TMOD],7)<>0) and (get_bit(self.sfr[ADDR_TCON],3)=0)) then delta:=0;
      overflow:=0;
			case mode of
        0:begin  // 13 Bit Timer Mode
            count:=((self.sfr[ADDR_TH1] shl 5) or (self.sfr[ADDR_TL1] and $1f));
  					count:=count+delta;
	  				overflow:=count and $ffffe000;
		  			self.sfr[ADDR_TH1]:=(count shr 5) and $ff;
			  		self.sfr[ADDR_TL1]:=count and $1f ;
          end;
        1:begin  // 16 Bit Timer Mode
            count:=(self.sfr[ADDR_TH1] shl 8) or self.sfr[ADDR_TL1];
  					count:=count+delta;
	  				overflow:=count and $ffff0000;
		  			self.sfr[ADDR_TH1]:=(count shr 8) and $ff;
			  		self.sfr[ADDR_TL1]:=count and $ff ;
          end;
        2:begin //8 bit Autoreload
            count:=self.sfr[ADDR_TL1]+delta;
					  overflow:=count and $ffffff00;
					  if (overflow<>0) then count:=count+self.sfr[ADDR_TH1];
 					  // Update new values of the counter
					  self.sfr[ADDR_TL1]:=count and $ff;
          end;
        3:;
      end;
      if (overflow<>0) then begin
        set_bit(@self.sfr[ADDR_TCON],7,1);
        //if overflow<>0 then MessageDlg('Num CPU '+inttostr(self.numero_cpu)+' Timer 1 Serial. PC='+inttohex(r.pc-1,10), mtInformation,[mbOk], 0);
				//transmit_receive(1);
      end
    end
 end else begin
    delta:=cycles;
    overflow:=0;
		// taken, reset
		self.t1_cnt:=0;
    case mode of
        0:begin  // 13 Bit Timer Mode
            count:=((self.sfr[ADDR_TH1] shl 5) or (self.sfr[ADDR_TL1] and $1f));
  					count:=count+delta;
	  				overflow:=count and $ffffe000;
		  			self.sfr[ADDR_TH1]:=(count shr 5) and $ff;
			  		self.sfr[ADDR_TL1]:=count and $1f ;
          end;
        1:begin  // 16 Bit Timer Mode
            count:=(self.sfr[ADDR_TH1] shl 8) or self.sfr[ADDR_TL1];
  					count:=count+delta;
	  				overflow:=count and $ffff0000;
		  			self.sfr[ADDR_TH1]:=(count shr 8) and $ff;
			  		self.sfr[ADDR_TL1]:=count and $ff ;
          end;
        2:begin //8 bit Autoreload
            count:=self.sfr[ADDR_TL1]+delta;
					  overflow:=count and $ffffff00;
					  if (overflow<>0) then count:=count+self.sfr[ADDR_TH1];
 					  // Update new values of the counter
					  self.sfr[ADDR_TL1]:=count and $ff;
          end;
        3:;
    end;
    //if overflow<>0 then MessageDlg('Num CPU '+inttostr(self.numero_cpu)+' Timer 1 Serial. PC='+inttohex(r.pc-1,10), mtInformation,[mbOk], 0); //transmit_recive(1);
 end;
end;

procedure cpu_mcs51.update_timer_t2(cycles:byte);
begin
if (get_bit(self.sfr[ADDR_T2CON],2))<>0 then begin
end;
end;

function cpu_mcs51.bit_address_r(pos:byte):byte;
var
	mask:byte;
  tempw:byte;
	bit_pos:byte;	// distance between bit addressable words
					      // 1 for normal bits, 8 for sfr bit addresses
begin
	//User defined bit addresses 0x20-0x2f (values are 0x0-0x7f)
	if (pos<$80) then tempw:=((pos and $78) shr 3)+$20
	  else tempw:=((pos and $78) shr 3)*8+$80;
  bit_pos:=pos and $7;
  mask:=($1 shl bit_pos);
  bit_address_r:=((self.IRAM_R(tempw) and mask) shr bit_pos);
end;

procedure cpu_mcs51.bit_address_w(pos,bit:byte);
var
  tempw:word;
  bit_pos,res,mask:byte;
begin
  if (pos<$80) then tempw:=((pos and $78) shr 3)+$20
    else tempw:=((pos and $78) shr 3)*8+$80;
  bit_pos:=pos and $07;
  bit:=(bit and $01) shl bit_pos;
  mask:=not(1 shl bit_pos);
  res:=self.iram_r(tempw) and mask;
  res:=res or bit;
  self.iram_w(tempw,res);
end;

procedure cpu_mcs51.pop_pc;
var
  tempsp:byte;
begin
  tempsp:=self.sfr[ADDR_SP];
	r.pc:=self.iram_ir(tempsp) shl 8;
  tempsp:=tempsp-1;
	r.pc:=r.pc or self.iram_ir(tempsp);
	self.sfr[ADDR_SP]:=tempsp-1;
end;

procedure cpu_mcs51.push_pc;
var
  tempsp:byte;
begin
  tempsp:=self.sfr[ADDR_SP]+1;
	self.iram_iw(tempsp,(r.pc and $ff));
  tempsp:=tempsp+1;
	self.iram_iw(tempsp,r.pc shr 8);
  self.sfr[ADDR_SP]:=tempsp;
end;

procedure cpu_mcs51.clear_irqs;
begin
  if (self.cur_irq_prio>=0) then self.irq_active:=self.irq_active and not(1 shl self.cur_irq_prio);
	if (self.irq_active and 4)<>0 then self.cur_irq_prio:=2
  	else if (self.irq_active and 2)<>0 then self.cur_irq_prio:=1
	    else if (self.irq_active and 1)<>0 then self.cur_irq_prio:=0
	      else self.cur_irq_prio:=-1;
end;

function cpu_mcs51.evalue_irq:byte;
var
  ints,int_vec,int_mask:byte;
  priority_request,i:integer;
begin
	ints:=get_bit(self.sfr[ADDR_TCON],1) or (get_bit(self.sfr[ADDR_TCON],5) shl 1) or
        (get_bit(self.sfr[ADDR_TCON],3) shl 2) or (get_bit(self.sfr[ADDR_TCON],7) shl 3);
			  //((GET_RI|GET_TI)<<4)); de momento paso de la transmision en serie...
	int_vec:=0;
	priority_request:=-1;
	//If All Inerrupts Disabled or no pending abort..
  if get_bit(self.sfr[ADDR_IE],7)<>0 then int_mask:=self.sfr[ADDR_IE]
    else int_mask:=0;
  if (self.features and FEATURE_I8052)<>0 then ints:=ints or ((get_bit(self.sfr[ADDR_T2CON],7) or get_bit(self.sfr[ADDR_T2CON],6)) shl 5);
  // mask out interrupts not enabled
  ints:=ints and int_mask;
	if (ints=0) then begin
      evalue_irq:=0;
      if self.pedir_irq0=HOLD_LINE then self.last_line_state:=self.last_line_state and $fffffffe;
      if self.pedir_irq1=HOLD_LINE then self.last_line_state:=self.last_line_state and $fffffffd;
      exit;
  end;
	for i:=0 to (self.num_interrupts-1) do begin
		if (ints and (1 shl i))<>0 then begin
			if (self.irq_prio[i] > priority_request) then begin
				priority_request:=self.irq_prio[i];
				int_vec:=(i shl 3) or 3;
			end;
		end;
	end;
	// Skip the interrupt request if currently processing interrupt
  // and the new request does not have a higher priority
	if ((self.irq_active<>0) and (priority_request<=self.cur_irq_prio)) then begin
    evalue_irq:=0;
    if self.pedir_irq0=HOLD_LINE then self.last_line_state:=self.last_line_state and $fffffffe;
    if self.pedir_irq1=HOLD_LINE then self.last_line_state:=self.last_line_state and $fffffffd;
    exit;
  end;
	// indicate we took the external IRQ
  case int_vec of
		V_IE0:begin
            // Hack to work around polling latency issue with JB INT0
            if ((self.rom[r.pc]=$20) and (self.rom[r.pc+1]=$b2)) then r.pc:=r.pc+3;
            //if (mcs51_state->irq_callback != NULL) then (*mcs51_state->irq_callback)(mcs51_state->device, 0);
          end;
    V_IE1:begin
            // Hack to work around polling latency issue with JB INT1
            if ((self.rom[r.pc]=$20) and (self.rom[r.pc+1]=$b3)) then r.pc:=r.pc+3;
            //if (mcs51_state->irq_callback != NULL) then (*mcs51_state->irq_callback)(mcs51_state->device, 1);
    end;
  end;
	//Save current pc to stack, set pc to new interrupt vector
	self.push_pc;
	r.pc:=int_vec;
	// interrupts take 24 cycles
	evalue_irq:=2;
	//Set current Irq & Priority being serviced
	self.cur_irq_prio:=priority_request;
	self.irq_active:=self.irq_active or (1 shl priority_request);
	//Clear any interrupt flags that should be cleared since we're servicing the irq!
	case int_vec of
		V_IE0:begin
			      //External Int Flag only cleared when configured as Edge Triggered..
			      if get_bit(self.sfr[ADDR_TCON],0)<>0 then set_bit(@self.sfr[ADDR_TCON],1,0);
            if self.pedir_irq0=HOLD_LINE then self.change_irq0(CLEAR_LINE);
          end;
		V_TF0:begin
      			//Timer 0 - Always clear Flag
			      set_bit(@self.sfr[ADDR_TCON],5,0);
          end;
		V_IE1:begin
			      //External Int Flag only cleared when configured as Edge Triggered..
			      if get_bit(self.sfr[ADDR_TCON],2)<>0 then SET_BIT(@self.sfr[ADDR_TCON],3,0);
            if self.pedir_irq1=HOLD_LINE then self.change_irq1(CLEAR_LINE);
          end;
		V_TF1:begin
			      //Timer 1 - Always clear Flag
            SET_BIT(@self.sfr[ADDR_TCON],7,0);
          end;
		V_RITI:; // no flags are cleared, TI and RI remain set until reset by software
  end;
end;

function cpu_mcs51.r_reg(addr:byte):byte;
begin
  r_reg:=self.ram[addr or (self.sfr[ADDR_PSW] and $18)];
end;

procedure cpu_mcs51.set_reg(addr,valor:byte);
begin
  self.ram[addr or (self.sfr[ADDR_PSW] and $18)]:=valor;
end;

procedure cpu_mcs51.run(maximo:single);
var
  f,instruccion,pos,tempb,tempb2,estados_demas:byte;
  tempw:word;
begin
self.contador:=0;
while self.contador<maximo do begin
if self.pedir_halt<>CLEAR_LINE then begin
  self.contador:=trunc(maximo);
  exit;
end;
//Calcular la paridad si cambia r.a
if self.calc_parity then begin
  tempb:=0;
	tempb2:=self.sfr[ADDR_ACC];
	for f:=0 to 7 do begin
		tempb:=tempb xor (tempb2 and 1);
		tempb2:=tempb2 shr 1;
	end;
  r.psw.p:=(tempb and 1)<>0;
  self.sfr[ADDR_PSW]:=self.dame_pila;
  self.calc_parity:=false;
end;
estados_demas:=self.evalue_irq;
self.opcode:=true;
instruccion:=self.rom[r.pc];
r.pc:=r.pc+1;
self.opcode:=false;
case instruccion of
  $00:; //nop
  $01,$21,$41,$61:begin //ajmp
        tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      r.pc:=(r.pc and $f800) or ((instruccion and $e0) shl 3) or tempb;
      end;
  $02:r.pc:=(self.rom[r.pc] shl 8)+self.rom[r.pc+1]; //ljmp
  $03:begin //rr_a
        tempb:=self.sfr[ADDR_ACC];
        self.sfr[ADDR_ACC]:=(tempb shr 1) or ((tempb and 1) shl 7);
        self.calc_parity:=true;
      end;
  $04:begin //inc_a
        self.sfr[ADDR_ACC]:=self.sfr[ADDR_ACC]+1;
        self.calc_parity:=true;
      end;
  $05:begin //inc_mem
        self.rwm:=true;
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      tempb:=self.IRAM_R(pos);
	      self.IRAM_W(pos,tempb+1);
        self.rwm:=false;
      end;
  $06,$07:begin //inc_ir
        pos:=self.r_reg(instruccion and $1);
        tempb:=self.iram_ir(pos);
        self.iram_iw(pos,tempb+1);
      end;
  $08..$0f:begin //inc_r
        tempb:=self.r_reg(instruccion and $7);
        self.set_reg(instruccion and $7,tempb+1);
      end;
  $10:begin //jbc
        self.rwm:=true;
        pos:=self.rom[r.pc];
	      tempb:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
	      if self.bit_address_r(pos)<>0	then begin
      		r.pc:=r.pc+shortint(tempb);
      		self.bit_address_w(pos,0);
      	end;
        self.rwm:=false;
      end;
  $11,$31,$51,$71,$91,$b1:begin //acall
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      self.PUSH_PC;
	      r.pc:=(r.pc and $f800) or ((instruccion and $e0) shl 3) or pos;
      end;
  $12:begin //lcall
	      tempb:=self.rom[r.pc];
        tempb2:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
	      self.PUSH_PC;
	      r.pc:=(tempb shl 8) or tempb2;
      end;
  $13:begin //rrc_a
        tempb:=self.sfr[ADDR_ACC];
	      self.sfr[ADDR_ACC]:=(tempb shr 1) or (byte(r.psw.c) shl 7);
        r.psw.c:=(tempb and 1)<>0;
        self.sfr[ADDR_psw]:=self.dame_pila;
      end;
  $14:begin //dec_a
        self.sfr[ADDR_ACC]:=self.sfr[ADDR_ACC]-1;
        self.calc_parity:=true;
      end;
  $15:begin  //dec_mem
        self.rwm:=true;
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      tempb:=self.IRAM_R(pos);
	      self.IRAM_W(pos,tempb-1);
        self.rwm:=false;
      end;
  $16,$17:begin //dec_ir
        pos:=self.r_reg(instruccion and $1);
        tempb:=self.iram_ir(pos);
        self.iram_iw(pos,tempb-1);
      end;
  $18..$1f:begin //dec_r
        tempb:=self.r_reg(instruccion and $7);
        self.set_reg(instruccion and $7,tempb-1);
      end;
  $20:begin //jb
        pos:=self.rom[r.pc];
        tempb:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
        if self.bit_address_r(pos)<>0 then r.pc:=r.pc+shortint(tempb);
      end;
  $22:self.pop_pc;  //ret
  $23:begin //rl_a
        tempb:=(self.sfr[ADDR_ACC] and $80) shr 7;
	      tempb2:=self.sfr[ADDR_ACC] shl 1;
        self.sfr[ADDR_ACC]:=tempb2 or tempb;
        self.calc_parity:=true;
      end;
  $24:begin //add_a_byte
        tempb2:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      tempb:=self.sfr[ADDR_ACC]+tempb2;
	      self.DO_ADD_FLAGS(self.sfr[ADDR_ACC],tempb2,0);
        self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
      end;
  $25:begin //add_a_mem
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      tempb2:=self.IRAM_R(pos);
	      tempb:=self.sfr[ADDR_ACC]+tempb2;
	      self.DO_ADD_FLAGS(self.sfr[ADDR_ACC],tempb2,0);
        self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
      end;
  $28..$2f:begin //add_a_r
        tempb2:=R_REG(instruccion and $7);
        tempb:=self.sfr[ADDR_ACC]+tempb2;
	      DO_ADD_FLAGS(self.sfr[ADDR_ACC],tempb2,0);
	      self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
      end;
  $30:begin //jnb
        pos:=self.rom[r.pc];
	      tempb:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
	      if (self.bit_address_r(pos)=0) then r.pc:=r.pc+shortint(tempb);
      end;
  $32:begin //RETI
    	  self.pop_pc;
	      self.clear_irqs;
      end;
  $33:begin //rlc_a
         tempb:=self.sfr[ADDR_ACC];
         self.sfr[ADDR_ACC]:=(tempb shl 1) or byte(r.psw.c);
         r.psw.c:=(tempb and $80)<>0;
         self.sfr[ADDR_psw]:=self.dame_pila;
      end;
  $35:begin //addc_a_mem
         pos:=self.rom[r.pc];
         r.pc:=r.pc+1;
	       tempb2:=self.IRAM_R(pos);
	       tempb:=self.sfr[ADDR_ACC]+tempb2+byte(r.psw.c);
	       self.DO_ADD_FLAGS(self.sfr[ADDR_ACC],tempb2,byte(r.psw.c));
	       self.sfr[ADDR_ACC]:=tempb;
         self.calc_parity:=true;
      end;
  $38..$3f:begin //addc_a_r
         tempb2:=R_REG(instruccion and $7);
	       tempb:=self.sfr[ADDR_ACC]+tempb2+byte(r.psw.c);
	       self.DO_ADD_FLAGS(self.sfr[ADDR_ACC],tempb2,byte(r.psw.c));
	       self.sfr[ADDR_ACC]:=tempb;
         self.calc_parity:=true;
      end;
  $40:begin //jc
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        if r.psw.c then r.pc:=r.pc+shortint(pos);
      end;
  $43:begin  //orl_mem_byte
        self.rwm:=true;
        pos:=self.rom[r.pc];
	      tempb2:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
	      tempb:=self.IRAM_R(pos);
	      self.IRAM_W(pos,tempb or tempb2);
        self.rwm:=false;
      end;
  $44:begin //orl_a_byte
        tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      self.sfr[ADDR_ACC]:=self.sfr[ADDR_ACC] or tempb;
        self.calc_parity:=true;
      end;
  $45:begin  //orl_a_mem
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        tempb:=self.IRAM_R(pos);
        self.sfr[ADDR_ACC]:=self.sfr[ADDR_ACC] or tempb;
        self.calc_parity:=true;
      end;
  $48..$4f:begin //orl_a_r
        tempb:=self.r_reg(instruccion and $7);
	      self.sfr[ADDR_ACC]:=self.sfr[ADDR_ACC] or tempb;
        self.calc_parity:=true;
      end;
  $50:begin //jnc
        tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      if not(r.psw.c) then r.pc:=r.pc+shortint(tempb);
      end;
  $53:begin  //anl_mem_byte
        self.rwm:=true;
        pos:=self.rom[r.pc];
        tempb2:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
        tempb:=self.IRAM_R(pos);
        self.IRAM_W(pos,tempb and tempb2);
        self.rwm:=false;
      end;
  $54:begin  //anl_a_byte
	      tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
        self.sfr[ADDR_ACC]:=self.sfr[ADDR_ACC] and tempb;
        self.calc_parity:=true;
  end;
  $55:begin //anl_a_mem
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      tempb:=self.IRAM_R(pos);
        self.sfr[ADDR_ACC]:=self.sfr[ADDR_ACC] and tempb;
        self.calc_parity:=true;
      end;
  $60:begin //jz
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      if (self.sfr[ADDR_ACC]=0) then r.pc:=r.pc+shortint(pos);
      end;
  $62:begin //xrl_mem_a
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      tempb:=IRAM_R(pos);
	      self.IRAM_W(pos,tempb xor self.sfr[ADDR_ACC]);
      end;
  $63:begin //xrl_mem_byte
        pos:=self.rom[r.pc];
        tempb:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
	      tempb2:=self.IRAM_R(pos);
	      self.IRAM_W(pos,tempb2 xor tempb);
      end;
  $64:begin //xrl_a_byte
        tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      self.sfr[ADDR_ACC]:=self.sfr[ADDR_ACC] xor tempb;
        self.calc_parity:=true;
      end;
  $65:begin //xrl_a_ir
        tempb:=self.iram_ir(r_reg(instruccion and 1));
	      self.sfr[ADDR_ACC]:=self.sfr[ADDR_ACC] xor tempb;
        self.calc_parity:=true;
      end;
  $68..$6f:begin //xrl_a_r
        tempb:=self.r_reg(instruccion and $7);
	      self.sfr[ADDR_ACC]:=self.sfr[ADDR_ACC] xor tempb;
        self.calc_parity:=true;
      end;
  $70:begin //jnz
        tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      if (self.sfr[ADDR_ACC]<>0) then r.pc:=r.pc+shortint(tempb);
      end;
  $74:begin //mov_a_byte
        tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
        self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
      end;
  $75:begin //mov_mem_byte
        pos:=self.rom[r.pc];
        tempb:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
        self.iram_w(pos,tempb);
      end;
  $76,$77:begin  //mov_ir_byte
        tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
        self.iram_iw(self.r_reg(instruccion and $1),tempb);
      end;
  $78..$7f:begin //mov_r_byte
        tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
        self.set_reg(instruccion and $7,tempb);
      end;
  $80:begin //sjmp
        tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
        r.pc:=r.pc+shortint(tempb);
      end;
  $83:begin //movc_a_iapc
        tempb:=self.rom[r.pc+self.sfr[ADDR_ACC]];
	      self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
      end;
  $84:begin //div ab
        if( self.sfr[ADDR_B]=0) then begin
          //Overflow flag is set!
          r.psw.o:=true;
		      //Really the values are undefined according to the manual, but we'll just leave them as is..
		      //SET_ACC(0xff);
		      //SFR_W(B,0xff);
	      end else begin
		      tempb:=self.sfr[ADDR_ACC] div self.sfr[ADDR_B];
		      tempb2:=self.sfr[ADDR_ACC] mod self.sfr[ADDR_B];
		      //A gets quotient byte, B gets remainder byte
		      self.sfr[ADDR_ACC]:=tempb;
	  	    self.sfr[ADDR_B]:=tempb2;
		      //Overflow flag is cleared
		      r.psw.o:=false;
	      end;
	      //Carry Flag is always cleared
        r.psw.c:=false;
        self.sfr[ADDR_PSW]:=self.dame_pila;
      end;
  $85:begin //mov_mem_mem
	      tempb:=self.rom[r.pc];
        tempb2:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
	      self.IRAM_W(tempb2,self.IRAM_R(tempb));
      end;
  $86,$87:begin //mov_mem_ir
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        self.IRAM_W(pos,self.iram_ir(self.r_reg(instruccion and $1)));
      end;
  $88..$8f:begin //mov_mem_r
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      self.IRAM_W(pos,self.r_reg(instruccion and $7));
      end;
  $90:begin //mov_dptr_byte
	      self.sfr[ADDR_DPH]:=self.rom[r.pc];
	      self.sfr[ADDR_DPL]:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
      end;
  $92:begin //mov_bitaddr_c
        self.rwm:=true;
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      self.bit_address_w(pos,byte(r.psw.c));
        self.rwm:=false;
      end;
  $93:begin //movc_a_iadptr
        tempw:=(self.sfr[ADDR_DPH] shl 8)+self.sfr[ADDR_DPL];
	      tempb:=self.rom[self.sfr[ADDR_ACC]+tempw];
        self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
      end;
  $94:begin //subb_a_byte
        tempb2:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      tempb:=self.sfr[ADDR_ACC]-tempb2-byte(r.psw.c);
	      self.DO_SUB_FLAGS(self.sfr[ADDR_ACC],tempb2,byte(r.psw.c));
        self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
      end;
  $95:begin //subb_a_mem
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        tempb2:=IRAM_R(pos);
	      tempb:=self.sfr[ADDR_ACC]-tempb2-byte(r.psw.c);
        self.DO_SUB_FLAGS(self.sfr[ADDR_ACC],tempb2,byte(r.psw.c));
        self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
      end;
  $98..$9f:begin //subb_a_r
        tempb2:=self.r_reg(instruccion and $7);
	      tempb:=self.sfr[ADDR_ACC]-tempb2-byte(r.psw.c);
        self.DO_SUB_FLAGS(self.sfr[ADDR_ACC],tempb2,byte(r.psw.c));
	      self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
        end;
  $a2:begin  //mov_c_bitaddr
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        r.psw.c:=self.bit_address_r(pos)<>0;
        self.sfr[ADDR_PSW]:=self.dame_pila;
      end;
  $a3:begin  //inc_dptr
      tempw:=((self.sfr[ADDR_DPH] shl 8)+self.sfr[ADDR_DPL])+1;
      self.sfr[ADDR_DPH]:=tempw shr 8;
	    self.sfr[ADDR_DPL]:=tempw and $ff;
  end;
  $a4:begin //mul_ab
        tempw:=self.sfr[ADDR_ACC]*self.sfr[ADDR_B];
	      //A gets lo bits, B gets hi bits of result
	      self.sfr[ADDR_B]:=(tempw and $ff00) shr 8;
	      self.sfr[ADDR_ACC]:=tempw and $ff;
	      //Set flags
	      r.psw.o:=(tempw and $100)<>0;
	      r.psw.c:=false;
        self.sfr[ADDR_PSW]:=self.dame_pila;
      end;
  $a6,$a7:begin //mov_ir_mem
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      self.iram_iw(self.r_reg(instruccion and $1),self.IRAM_R(pos));
      end;
  $a8..$af:begin //mov_r_mem
        tempb:=self.rom[r.pc];
        r.pc:=r.pc+1;
        self.set_reg(instruccion and $7,self.iram_r(tempb));
      end;
  $b2:begin  //cpl_bitaddr
        self.rwm:=true;
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      tempb:=(not(self.bit_address_r(pos))) and 1;
	      self.bit_address_w(pos,tempb);
        self.rwm:=false;
      end;
  $b3:begin //cpl_c
        r.psw.c:=not(r.psw.c);
        self.sfr[ADDR_psw]:=self.dame_pila;
      end;
  $b4:begin  //cjne_a_byte
        tempb:=self.rom[r.pc];
	      pos:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
	      if (self.sfr[ADDR_ACC]<>tempb) then r.pc:=r.pc+shortint(pos);
	      //Set carry flag to 1 if 1st compare value is < 2nd compare value
        r.psw.c:=self.sfr[ADDR_ACC]<tempb;
        self.sfr[ADDR_psw]:=self.dame_pila;
      end;
  $b8..$bf:begin //cjne_r_byte
        tempb:=self.rom[r.pc];
	      pos:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
	      tempb2:=self.r_reg(instruccion and $7);
	      if(tempb2<>tempb) then r.pc:=r.pc+shortint(pos);
	      //Set carry flag to 1 if 1st compare value is < 2nd compare value
	      r.psw.c:=(tempb2<tempb);
        self.sfr[ADDR_PSW]:=self.dame_pila;
      end;
  $c0:begin //push
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        tempb:=self.sfr[ADDR_SP]+1;
	      self.sfr[ADDR_SP]:=tempb;
	      self.IRAM_iW(tempb,self.IRAM_R(pos));
      end;
  $c2:begin //clr_bitaddr
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        self.rwm:=true;
        self.bit_address_w(pos,0);
        self.rwm:=false;
      end;
  $c3:begin //clr_c
        r.psw.c:=false;
        self.sfr[ADDR_psw]:=self.dame_pila;
      end;
  $c4:begin //swap_a
        tempb:=(self.sfr[ADDR_ACC] and $f) shl 4;
	      tempb2:=(self.sfr[ADDR_ACC] and $f0) shr 4;
        self.sfr[ADDR_ACC]:=tempb or tempb2;
        self.calc_parity:=true;
      end;
  $c5:begin //xch_a_mem
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      tempb2:=self.iram_r(pos);
	      tempb:=self.sfr[ADDR_ACC];
	      self.sfr[ADDR_ACC]:=tempb2;
        self.calc_parity:=true;
        self.iram_w(pos,tempb);
      end;
  $c8..$cf:begin //xch_a_r
        tempb2:=self.r_reg(instruccion and $7);
	      tempb:=self.sfr[ADDR_ACC];
	      self.sfr[ADDR_ACC]:=tempb2;
        self.calc_parity:=true;
	      self.set_reg(instruccion and $7,tempb);
  end;
  $d0:begin //pop
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        self.IRAM_W(pos,self.IRAM_R(self.sfr[ADDR_SP]));
	      self.sfr[ADDR_SP]:=self.sfr[ADDR_SP]-1;
      end;
  $d2:begin //setb_bitaddr
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        self.rwm:=true;
        self.bit_address_w(pos,1);
        self.rwm:=false;
      end;
  $d4:begin //da_a
        tempw:=self.sfr[ADDR_ACC];
	      if (r.psw.a or ((tempw and $0f)>$09)) then tempw:=tempw+$06;
	      if (r.psw.c or ((tempw and $f0)>$90) or ((tempw and $ff00)<>0)) then tempw:=tempw+$60;
	      self.sfr[ADDR_ACC]:=tempw and $ff;
        self.calc_parity:=true;
	      if(tempw and $ff00)<>0 then begin
          r.psw.c:=true;
          self.sfr[ADDR_psw]:=self.dame_pila;
        end;
      end;
  $d5:begin //djnz_mem
        self.rwm:=true;
        pos:=self.rom[r.pc];
	      tempb:=self.rom[r.pc+1];
        r.pc:=r.pc+2;
	      self.IRAM_W(pos,self.IRAM_R(pos)-1);
	      if (self.IRAM_R(pos)<>0) then r.pc:=r.pc+shortint(tempb);
        self.rwm:=false;
      end;
  $d8..$df:begin //djnz_r
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        tempb:=self.r_reg(instruccion and $7)-1;
        self.set_reg(instruccion and $7,tempb);
        if tempb<>0 then r.pc:=r.pc+shortint(pos);
      end;
  $e0:begin //movx_a_idptr
         //ERAM_ADDR
         tempw:=(self.sfr[ADDR_DPH] shl 8)+self.sfr[ADDR_DPL];
         if @self.getbyte<>nil then tempb:=self.getbyte(tempw)
          else tempb:=$ff;
	       self.sfr[ADDR_ACC]:=tempb;
         self.calc_parity:=true;
      end;
  $e2,$e3:begin //movx_a_ir
        //ERAM_ADDR
        tempw:=(self.sfr[ADDR_P2] shl 8)+R_REG(instruccion and $1);
        if @self.getbyte<>nil then tempb:=self.getbyte(tempw)
          else tempb:=$ff;
        self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
      end;
  $e4:begin  //clr_a
        self.sfr[ADDR_ACC]:=0;
        self.calc_parity:=true;
      end;
  $e5:begin //mov_a_mem
        pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
        self.sfr[ADDR_ACC]:=self.iram_r(pos);
        self.calc_parity:=true;
      end;
  $e6,$e7:begin //mov_a_ir
            self.sfr[ADDR_ACC]:=self.iram_ir(self.r_reg(instruccion and $1));
            self.calc_parity:=true;
          end;
  $e8..$ef:begin //mov_a_r
            self.sfr[ADDR_ACC]:=self.r_reg(instruccion and $7);
            self.calc_parity:=true;
          end;
  $f0:begin //movx_idptr_a
          //ERAM_ADDR
          tempw:=(self.sfr[ADDR_DPH] shl 8)+self.sfr[ADDR_DPL];
	        if @self.putbyte<>nil then self.putbyte(tempw,self.sfr[ADDR_ACC]);
      end;
  $f2,$f3:begin //movx_ir_a
          //ERAM_ADDR
          tempw:=(self.sfr[ADDR_P2] shl 8)+R_REG(instruccion and $1);
	        if @self.putbyte<>nil then self.putbyte(tempw,self.sfr[ADDR_ACC]);
      end;
  $f4:begin //cpl_a
        tempb:=not(self.sfr[ADDR_ACC]) and $ff;
        self.sfr[ADDR_ACC]:=tempb;
        self.calc_parity:=true;
      end;
  $f5:begin //mov_mem_a
    	  pos:=self.rom[r.pc];
        r.pc:=r.pc+1;
	      self.iram_w(pos,self.sfr[ADDR_ACC]);
      end;
  $f6..$f7:self.iram_iw(self.r_reg(instruccion and $1),self.sfr[ADDR_ACC]);  //mov_ir_a
  $f8..$ff:self.set_reg(instruccion and $7,self.sfr[ADDR_ACC]); //mov_r_a
    else MessageDlg('Num CPU '+inttostr(self.numero_cpu)+' instruccion: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(r.pc-1,10), mtInformation,[mbOk], 0);
end;
tempb:=ciclos_mcs51[instruccion]+estados_demas;
self.contador:=self.contador+tempb;
self.update_timer_t0(tempb);
self.update_timer_t1(tempb);
if (self.features and FEATURE_I8052)<>0 then self.update_timer_t2(tempb);
timers.update(tempb,self.numero_cpu);
end; //del while
end;

end.
