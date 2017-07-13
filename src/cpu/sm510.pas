unit sm510;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     dialogs,sysutils,timer_engine,main_engine,cpu_misc;

type
        twrite_X=procedure(valor:byte);
        twrite_lcd=procedure(valor:byte;offset:word);
        tread_X=function:byte;
        reg_sm510=record
                pc:word;
                old_pc:word;
	        acc,bl,bm,w,r,r_out:byte;
                c:boolean;
        end;
        preg_sm510=^reg_sm510;
        cpu_sm510=class(cpu_class)
                constructor create(clock:dword;type_:byte;frames:single);
                destructor free;
            public
                procedure run(maximo:single);
                procedure reset;
                procedure change_io_calls(read_b,read_k:tread_X;write_s,write_r:twrite_X;write_sega,write_segb,write_segc,write_segbs:twrite_lcd);
                function get_rom_addr:pbyte;
                procedure set_input_line(line,state:byte);
            private
                r:preg_sm510;
                skip,halt_,sbm,k_active,bp,bc,one_s:boolean;
                clk_div,prgmask,datamask,datawidth:integer;
                op,prev_op,div_:word;
                l,x,y,melody_rd,melody_step_count,melody_duty_count,melody_duty_index,melody_address,stack_levels,tipo:byte;
                stack:array[0..3] of word; // max 4
                rom:array[0..$fff] of byte;
                ram:array[0..$7f] of byte;
                read_b,read_ba,read_k:tread_X;
                write_s,write_r:twrite_X;
                write_sega,write_segb,write_segc,write_segbs:twrite_lcd;
                div_timer,lcd_timer:byte;
                procedure increment_pc;
                function wake_me_up:boolean;
                procedure do_branch(pu,pm,pl:byte);
                procedure push_stack;
                procedure pop_stack;
                procedure op_exc;
                procedure op_incb;
                procedure op_decb;
                function ram_r:byte;
                procedure ram_w(valor:byte);
                procedure update_w_latch;
                procedure clock_melody;
                function get_lcd_row(column:byte;ram:pbyte):word;
        end;
const
  SM_510=0;
  SM510_INPUT_LINE_K=0;
  SM510_PORT_SEGA=$00;
	SM510_PORT_SEGB=$04;
	SM510_PORT_SEGBS=$08;
	SM510_PORT_SEGC=$0c;
var
  sm510_0:cpu_sm510;

implementation

procedure div_timer_cb_0;
begin
  sm510_0.div_:=(sm510_0.div_+1) and $7fff;
  if (sm510_0.div_=0) then sm510_0.one_s:=true;
  sm510_0.clock_melody;
end;

procedure lcd_timer_cb_0;
var
  h,bs:byte;
begin
  	// 4 columns
	for h:=0 to 3 do begin
		// 16 segments per row from upper part of RAM
		if @sm510_0.write_sega<>nil then sm510_0.write_sega(h or SM510_PORT_SEGA,sm510_0.get_lcd_row(h,@sm510_0.ram[$60]));
		if @sm510_0.write_segb<>nil then sm510_0.write_segb(h or SM510_PORT_SEGB,sm510_0.get_lcd_row(h,@sm510_0.ram[$70]));
		if @sm510_0.write_segc<>nil then sm510_0.write_segc(h or SM510_PORT_SEGC,sm510_0.get_lcd_row(h,nil));
		// bs output from L/X and Y regs
    if @sm510_0.write_segbs<>nil then begin
		  bs:=((sm510_0.l shr h) and 1) or (((sm510_0.x*2) shr h) and 2);
      if (sm510_0.bc or not(sm510_0.bp)) then sm510_0.write_segbs(h or SM510_PORT_SEGBS,0)
        else sm510_0.write_segbs(h or SM510_PORT_SEGBS,bs);
    end;
	end;
end;

constructor cpu_sm510.create(clock:dword;type_:byte;frames:single);
begin
getmem(self.r,sizeof(reg_sm510));
fillchar(self.r^,sizeof(reg_sm510),0);
self.numero_cpu:=cpu_main_init(clock);
self.clock:=clock div 2;
self.tframes:=clock/2/llamadas_maquina.fps_max/frames;
self.div_timer:=init_timer(self.numero_cpu,clock/clock,div_timer_cb_0,true);
self.lcd_timer:=init_timer(self.numero_cpu,clock/$200,lcd_timer_cb_0,true);
self.r.pc:=0;
self.r.old_pc:=0;
self.op:=0;
self.prev_op:=0;
self.r.acc:=0;
self.r.bl:=0;
self.r.bm:=0;
self.sbm:=false;
self.r.c:=false;
self.skip:=false;
self.r.w:=0;
self.r.r:=0;
self.r.r_out:=0;
self.div_:=0;
self.one_s:=false;
self.k_active:=false;
self.l:=0;
self.x:=0;
self.y:=0;
self.bp:=false;
self.bc:=false;
self.halt_:=false;
self.melody_rd:=0;
self.melody_step_count:=0;
self.melody_duty_count:=0;
self.melody_duty_index:=0;
self.melody_address:=0;
self.clk_div:=2; // 16kHz
self.tipo:=type_;
case type_ of
  SM_510:begin
            self.prgmask:=$fff;
            self.datamask:=$7f;
            self.datawidth:=7;
            self.stack_levels:=2;
         end;
end;
self.read_b:=nil;
self.read_k:=nil;
self.write_s:=nil;
self.write_r:=nil;
self.write_sega:=nil;
self.write_segb:=nil;
self.write_segc:=nil;
self.write_segbs:=nil;
end;

destructor cpu_sm510.free;
begin
freemem(self.r);
end;

procedure cpu_sm510.reset;
begin
self.skip:=false;
self.halt_:=false;
self.sbm:=false;
self.op:=0;
self.prev_op:=0;
do_branch(3,7,0);
self.r.old_pc:=self.r.pc;
// lcd is on (Bp on, BC off, bs(y) off)
self.bp:=true;
self.bc:=false;
self.y:=0;
self.r.r:=0;
self.r.r_out:=0;
if @self.write_r<>nil then self.write_r(0);
end;

procedure cpu_sm510.change_io_calls(read_b,read_k:tread_X;write_s,write_r:twrite_X;write_sega,write_segb,write_segc,write_segbs:twrite_lcd);
begin
  self.read_b:=read_b;
  self.read_k:=read_k;
  self.write_s:=write_s;
  self.write_r:=write_r;
  self.write_sega:=write_sega;
  self.write_segb:=write_segb;
  self.write_segc:=write_segc;
  self.write_segbs:=write_segbs;
end;

function cpu_sm510.get_rom_addr:pbyte;
begin
  get_rom_addr:=@self.rom[0];
end;

procedure cpu_sm510.set_input_line(line,state:byte);
begin
  if (line<>SM510_INPUT_LINE_K) then exit;
  self.k_active:=state<>0;
end;

procedure cpu_sm510.clock_melody;
var
  out_:byte;
begin
	// buzzer from divider, R2 inverse phase
	out_:=(self.div_ shr 2) and 1;
	out_:=out_ or ((out_ shl 1) xor 2);
	out_:=out_ and self.r.r;
	// output to R pin
	if (out_<>self.r.r_out) then begin
		self.write_r(out_);
		self.r.r_out:=out_;
	end;
end;

function cpu_sm510.get_lcd_row(column:byte;ram:pbyte):word;
var
  rowdata:word;
  i:byte;
  val_ram:byte;
begin
	// output 0 if lcd blackpate/bleeder is off, or in case row doesn't exist
	if ((ram=nil) or self.bc or not(self.bp)) then begin
		get_lcd_row:=0;
    exit;
  end;
	rowdata:=0;
	for i:=0 to $f do begin
    val_ram:=ram[i];
    rowdata:=rowdata or (((val_ram shr column) and 1) shl i);
  end;
	get_lcd_row:=rowdata;
end;

//opcodes
procedure cpu_sm510.do_branch(pu,pm,pl:byte);
begin
	// set new PC(Pu/Pm/Pl)
	self.r.pc:=(((pu shl 10) and $c00) or ((pm shl 6) and $3c0) or (pl and $03f)) and self.prgmask;
end;

//run
procedure cpu_sm510.increment_pc;
var
  feed:byte;
begin
	// PL(program counter low 6 bits) is a simple LFSR: newbit = (bit0==bit1)
	// PU,PM(high bits) specify page, PL specifies steps within page
	if ((self.r.pc shr 1 xor self.r.pc) and 1)<>0 then feed:=0
    else feed:=$20;
	self.r.pc:= feed or (self.r.pc shr 1 and $1f) or (self.r.pc and not($3f));
end;

procedure cpu_sm510.push_stack;
var
  i:byte;
begin
	for i:=self.stack_levels downto 1 do self.stack[i]:=self.stack[i-1];
	self.stack[0]:=self.r.pc;
end;

procedure cpu_sm510.pop_stack;
var
  i:byte;
begin
	self.r.pc:=self.stack[0] and self.prgmask;
	for i:=0 to (self.stack_levels-1) do self.stack[i]:=self.stack[i+1];
end;

procedure cpu_sm510.op_exc;
var
  a:byte;
begin
	a:=self.r.acc;
	self.r.acc:=self.ram_r;
	self.ram_w(a);
	self.r.bm:=self.r.bm xor (self.op and 3);
end;

procedure cpu_sm510.op_decb;
begin
  self.r.bl:=(self.r.bl-1) and $f;
  self.skip:=(self.r.bl=$f);
end;

procedure cpu_sm510.op_incb;
begin
   self.r.bl:=(self.r.bl+1) and $f;
   self.skip:=(self.r.bl=0);
end;

function cpu_sm510.ram_r:byte;
var
  bmh:integer;
  address:byte;
begin
	if self.sbm then bmh:=1 shl (self.datawidth-1)
    else bmh:=0; // from SBM
	address:= (bmh or self.r.bm shl 4 or self.r.bl) and self.datamask;
	ram_r:=self.ram[address] and $f;
end;

procedure cpu_sm510.ram_w(valor:byte);
var
  bmh:integer;
  address:byte;
begin
	if self.sbm then bmh:=1 shl (self.datawidth-1)
    else bmh:=0; // from SBM
	address:=(bmh or self.r.bm shl 4 or self.r.bl) and self.datamask;
	self.ram[address]:=valor and $f;
end;

function cpu_sm510.wake_me_up:boolean;
begin
	// in halt mode, wake up after 1S signal or K input
	if (self.k_active or self.one_s) then begin
		// note: official doc warns that Bl/Bm and the stack are undefined
		// after waking up, but we leave it unchanged
		self.halt_:=false;
		self.do_branch(1,0,0);
		// standard_irq_callback(0); !!!!!!!!!!!!!!!!!!1
		wake_me_up:=true;
	end else begin
		wake_me_up:=false;
  end;
end;

procedure cpu_sm510.update_w_latch;
begin
case self.tipo of
     SM_510:if @self.write_s<>nil then self.write_s(self.r.w);
end;
end;

function bitmask(param:word):byte;
begin //bitmask from immediate opcode param
   bitmask:=1 shl (param and 3);
end;

procedure cpu_sm510.run(maximo:single);
var
  param,tempb:byte;
begin
self.contador:=0;
while self.contador<maximo do begin
if (self.halt_ and not(self.wake_me_up)) then begin
  // got nothing to do
  self.contador:=trunc(maximo);
  exit;
end;
estados_demas:=1;
self.r.old_pc:=self.r.pc;
self.prev_op:=self.op;
self.op:=self.rom[r.pc];
self.increment_pc;
self.opcode:=false;
if (self.skip) then begin
  self.skip:=false;
  self.op:=0; // fake nop
end else begin
  case (self.op and $f0) of
    $20:if ((self.op and not($f))<>(self.prev_op and not($f))) then self.r.acc:=self.op and $f; // LAX x: load ACC with immediate value, skip any next LAX
    $30:begin // ADX x: add immediate value to ACC, skip next on carry except if x = 10
	     self.r.acc:=self.r.acc+(self.op and $f);
	     self.skip:=(((self.op and $f)<>10) and ((self.r.acc and $10)<>0));
	     self.r.acc:=self.r.acc and $f;
        end;
    $40:begin	// LB x: load BM/BL with 4-bit immediate value (partial)
	        self.r.bm:=(self.r.bm and 4) or (self.op and 3);
	        if (self.op and $c)<>0 then self.r.bl:=(self.op shr 2 and 3) or $c
               else self.r.bl:=(self.op shr 2 and 3);
        end;
    $80,$90,$a0,$b0:self.r.pc:=(self.r.pc and not($3f)) or (self.op and $3f);	// T xy: jump(transfer) within current page
    $c0,$d0,$e0,$f0:begin // TM x: indirect subroutine call, pointers(IDX) are in page 0
	                    estados_demas:=2;
                      self.push_stack;
	                    tempb:=self.rom[self.op and $3f];
	                    self.do_branch(tempb shr 6 and 3,4,tempb and $3f);
                    end;
    else case (self.op and $fc) of
		  $04:self.ram_w(self.ram_r and not(bitmask(self.op))); // RM x: reset RAM bit
		  $0c:self.ram_w(self.ram_r or bitmask(self.op)); // SM x: set RAM bit
		  $10:begin // EXC x: exchange ACC with RAM, xor BM with x
            tempb:=self.r.acc;
            self.r.acc:=self.ram_r;
            self.ram_w(tempb);
            self.r.bm:=self.r.bm xor (self.op and 3);
          end;
		  $14:begin // EXCI x: EXC x, INCB
            self.op_exc;
            self.op_incb;
          end;
		  $18:begin  // LDA x: load ACC with RAM, xor BM with x
            self.r.acc:=self.ram_r;
            self.r.bm:=self.r.bm xor (self.op and 3);
          end;
		  $1c:begin // EXCD x: EXC x, DECB
            self.op_exc;
            self.op_decb;
          end;
      $54:self.skip:=(self.ram_r and bitmask(self.op))<>0;// TMI x: skip next if RAM bit is set
		  $70,$74,$78:begin // TL xyz: long jump
                      estados_demas:=2;
                      param:=self.rom[r.pc];
		                  self.increment_pc;
                      self.do_branch(param shr 6 and 3,self.op and $f,param and $3f);
                  end;
      $7c:begin // TML xyz: long call
                      estados_demas:=2;
                      param:=self.rom[r.pc];
		                  self.increment_pc;
	                    self.push_stack;
	                 do_branch(param shr 6 and 3,self.op and 3,param and $3f);
                      end;
                  else case self.op of
                        $00:; // SKIP: no operation
                        $01:self.bp:=(self.r.acc and 1)<>0; // ATBP: output ACC to BP(internal LCD backplate signal)
                        $02:; // SBM: set BM high bit for next opcode - se hace al final de los opcodes
                        $03:self.r.pc:=(self.r.old_pc and not($f)) or self.r.acc; // ATPL: load Pl(PC low bits) with ACC
                        $08:self.r.acc:=(self.r.acc+self.ram_r) and $f; // ADD: add RAM to ACC
                        $09:begin // ADD11: add RAM and carry to ACC and carry, skip next on carry
	                            self.r.acc:=self.r.acc+self.ram_r+byte(self.r.c);
	                            self.r.c:=(self.r.acc and $10)<>0;
	                            self.skip:=self.r.c;
	                            self.r.acc:=self.r.acc and $f;
                            end;
                        $0a:self.r.acc:=self.r.acc xor $f;// COMA: complement ACC
                        $0b:begin // EXBLA: exchange BL with ACC
	                        tempb:=self.r.acc;
	                        self.r.acc:=self.r.bl;
	                        self.r.bl:=tempb;
                            end;
                        $51:if @self.read_b<>nil then self.skip:=(self.read_b<>0) // TB: skip next if B(beta) pin is set
                               else self.skip:=true;
                        $52:self.skip:=not(self.r.c); // TC: skip next if no carry
                        $53:self.skip:=(self.r.acc=self.ram_r); // TAM: skip next if ACC equals RAM
                        $58:begin // TIS: skip next if 1S(gamma flag) is clear, reset it after
	                            self.skip:=not(self.one_s);
	                            self.one_s:=false;
                            end;
                        $59:self.l:=self.r.acc; // ATL: output ACC to L
                        $5a:self.skip:=(self.r.acc=0); // TA0: skip next if ACC is clear
                        $5b:self.skip:=(self.r.acc=self.r.bl); // TABL: skip next if ACC equals BL
                        $5d:self.halt_:=true;	// CEND: stop clock (halt the cpu and go into low-power mode)
                        $5e:if @self.read_ba<>nil then self.skip:=(self.read_ba<>0) // TAL: skip next if BA pin is set
                               else self.skip:=true;
                        $5f:begin // LBL xy: load BM/BL with 8-bit immediate value
                               estados_demas:=2;
                               param:=self.rom[r.pc];
		                           self.increment_pc;
                               self.r.bl:=param and $f;
	                             self.r.bm:=(param and self.datamask) shr 4;
                            end;
                        $60:self.y:=self.r.acc; // ATFC: output ACC to Y
                        $61:self.r.r:=self.r.acc; // ATR: output ACC to R
                        $62:begin // WR: shift 0 into W
	                            self.r.w:=((self.r.w shl 1) and $ff) or 0;
	                            self.update_w_latch;
                            end;
                        $63:begin // WS: shift 1 into W
	                            self.r.w:=((self.r.w shl 1) and $ff) or  1;
	                            self.update_w_latch;
                            end;
                        $64:self.op_incb; // INCB: increment BL, skip next on overflow
                        $65:self.div_:=0; // IDIV: reset divider
                        $66:self.r.c:=false; // RC: reset carry
                        $67:self.r.c:=true; // SC: set carry
                        $68:self.skip:=(self.div_ and $4000)<>0; // TF1: skip next if divider F1(d14) is set
                        $69:self.skip:=(self.div_ and $800)<>0; // TF4: skip next if divider F4(d11) is set
                        $6a:if @self.read_k<>nil then self.r.acc:=self.read_k and $f // KTA: input K to ACC
                               else self.r.acc:=$f;
                        $6b:begin // ROT: rotate ACC right through carry
	                            tempb:=self.r.acc and 1;
	                            self.r.acc:=(self.r.acc shr 1) or (byte(self.r.c) shl 3);
	                            self.r.c:=(tempb<>0);
                            end;
                        $6c:self.op_decb; // DECB: decrement BL, skip next on overflow
                        $6d:halt(0); //op_bdc
                        $6e:self.pop_stack; // RTN0: return from subroutine
                        $6f:begin // RTN1: return from subroutine, skip next
	                            self.pop_stack;
	                            self.skip:=true;
                            end;
                        else MessageDlg('Num CPU '+inttostr(self.numero_cpu)+' instruccion: '+inttohex(self.op,2)+' desconocida. PC='+inttohex(self.r.old_pc-1,10), mtInformation,[mbOk], 0);
                  end;
    end;
  end;
end;
self.sbm:=(self.op=$02);
self.contador:=self.contador+estados_demas;
update_timer(estados_demas,self.numero_cpu);
end;
end;

end.
