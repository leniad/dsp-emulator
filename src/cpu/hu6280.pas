unit hu6280;

interface
uses  main_engine,dialogs,sysutils,timer_engine,cpu_misc;

type
        band_h6280=record
                n,o_v,t,brk,dec,int,z,c:boolean;
        end;
        reg_h6280=record
                old_pc,pc:word;
                a,x,y,sp:byte;
                m:array[0..7] of byte;
                p:band_h6280;
        end;
        preg_h6280=^reg_h6280;
        cpu_h6280=class(cpu_class)
            constructor create(clock:dword);
            destructor free;
          public
            getbyte:tgetbyte16;
            putbyte:tputbyte16;
            function get_internal_r:preg_h6280;
            procedure reset;
            procedure run(maximo:single);
            procedure irq_status_w(direccion,valor:byte);
            procedure timer_w(posicion,valor:byte);
            procedure set_irq_line(irqline,state:byte);
            procedure change_ram_calls(getbyte:tgetbyte16;putbyte:tputbyte16);
            procedure change_io_calls(write_port:tputbyte16);
            function irq_status_r(direccion:byte):byte;
            function timer_r:byte;
          private
            r:preg_h6280;
            io_write:tputbyte16;
            clocks_per_cycle:byte;
            timer_status:byte;
            timer_load,timer_value:integer;
            irq_pending:byte;
            irq_state:array[0..2] of byte;
            io_buffer,irq_mask:byte;
            extra_cycles:integer;
            procedure alu_group(op,value:byte;var extra:integer);
            procedure consume_cycles(cycles:integer);
            procedure update_external_timers(cycles:integer);
            function translated(addr:word):dword;
            procedure pon_pila(temp:byte);
            function dame_pila:byte;
            function pull:byte;
            procedure push(valor:byte);
            procedure DO_INTERRUPT(vector:word);
            procedure CHECK_AND_TAKE_IRQ_LINES;
        end;
var
    h6280_0:cpu_h6280;

implementation
  const
  tipo_dir:array[0..255] of byte=(
        1,0,1,2,7,7,7,7,1,2,1,1,5,5,5,7,
        2,10,0,2,7,0,15,7,1,0,1,1,5,8,8,7,
        3,0,1,2,7,7,7,7,1,2,1,1,5,5,5,7,
        2,0,0,1,15,0,15,7,1,0,1,1,8,8,8,7,
        1,0,1,2,2,7,7,7,1,2,1,1,3,0,5,7,
        2,0,0,2,1,0,15,7,1,0,1,1,0,0,8,7,
        1,0,1,0,6,7,7,7,1,2,1,1,13,5,5,7,
        2,10,0,1,4,0,15,7,1,14,1,1,3,8,8,7,
        2,0,1,1,6,6,6,7,1,2,1,1,3,3,3,7,
        2,11,0,2,4,4,6,7,1,16,1,1,3,12,12,7,
        2,0,2,1,7,7,7,7,1,2,1,1,5,5,5,7,
        2,10,9,2,15,15,6,7,1,14,1,1,8,8,14,7,
        2,0,1,1,7,7,7,7,1,2,1,1,5,5,5,7,
        2,10,9,1,1,15,15,7,1,14,1,1,0,8,8,7,
        2,0,0,1,7,7,7,7,1,2,1,1,5,5,5,7,
        2,10,0,1,1,15,15,7,1,14,1,1,0,8,8,7); //F0

  estados_t:array[0..255] of byte=(
      //0 1 2 3 4 5 6 7 8 9 a b c d e f
        8,7,3,5,6,4,6,7,3,2,2,2,7,5,7,6, //00
        2,7,7,5,6,4,6,7,2,5,2,2,7,5,7,6, //10
        7,7,3,5,4,4,6,7,4,2,2,2,5,5,7,6, //20
        2,7,7,2,4,4,6,7,2,5,2,2,5,5,7,6, //30
        7,7,3,4,8,4,6,7,3,2,2,2,4,5,7,6, //40
        2,7,7,5,3,4,6,7,2,5,3,2,2,5,7,6, //50
        7,7,2,4,4,4,6,7,4,2,2,2,7,5,7,6, //60
        2,7,7,0,4,4,6,7,2,5,4,2,7,5,7,6, //70
        2,7,2,7,4,4,4,7,2,2,2,2,5,5,5,6, //80
        2,7,7,8,4,4,4,7,2,5,2,2,5,5,5,6, //90
        2,7,2,7,4,4,4,7,2,2,2,2,5,5,5,6, //a0
        2,7,7,8,4,4,4,7,2,5,2,2,5,5,5,6, //b0
        2,7,2,0,4,4,6,7,2,2,2,2,5,5,7,6, //c0
        2,7,7,0,3,4,6,7,2,5,3,2,2,5,7,6, //d0
        2,7,2,0,4,4,6,7,2,2,2,2,5,5,7,6, //e0
        2,7,7,0,2,4,6,7,2,5,4,2,2,5,7,6);//f0

constructor cpu_h6280.create(clock:dword);
begin
getmem(self.r,sizeof(reg_h6280));
fillchar(self.r^,sizeof(reg_h6280),0);
self.numero_cpu:=cpu_main_init(clock);
self.clock:=clock;
self.io_write:=nil;
self.tframes:=(clock/llamadas_maquina.scanlines)/llamadas_maquina.fps_max;
end;

destructor cpu_h6280.free;
begin
freemem(self.r);
end;

function cpu_h6280.irq_status_r(direccion:byte):byte;
var
  estado:byte;
begin
  case direccion and 3 of
    2:irq_status_r:=(self.irq_mask and 7) or (self.io_buffer and $f8);
    3:begin
        estado:=0;
        if self.irq_state[1]<>CLEAR_LINE then estado:=estado or 1;
        if self.irq_state[0]<>CLEAR_LINE then estado:=estado or 2;
        if self.irq_state[2]<>CLEAR_LINE then estado:=estado or 4;
        irq_status_r:=estado or (self.io_buffer and $f8);
      end;
    else irq_status_r:=self.io_buffer;
  end;
end;

function cpu_h6280.timer_r:byte;
begin
  timer_r:=byte((self.timer_value shr 10) and $7f) or (self.io_buffer and $80);
end;

procedure cpu_h6280.change_io_calls(write_port:tputbyte16);
begin
  self.io_write:=write_port;
end;

procedure cpu_h6280.alu_group(op,value:byte;var extra:integer);
var
  a,b,res,lo,hi:integer;
  target:dword;
  use_t:boolean;
begin
 a:=r.a;
 b:=value;
 target:=(r.m[1] shl 13) or r.x;
 use_t:=r.p.t and (op in[0,1,2,3,7]);
 if use_t then begin
    a:=self.getbyte(target);
    inc(extra,3);
 end;
 r.p.t:=false;
 case op of
   0:res:=a or b;
   1:res:=a and b;
   2:res:=a xor b;
   3:begin
     res:=a+b+byte(r.p.c);
     if not r.p.dec then r.p.o_v:=((not(a xor b) and (a xor res)) and $80)<>0;
     if r.p.dec then begin
       lo:=(a and 15)+(b and 15)+byte(r.p.c);
       hi:=(a and $f0)+(b and $f0);
       if lo>9 then inc(lo,6);if lo>$f then inc(hi,$10);
       if hi>$90 then inc(hi,$60);
       res:=(hi and $f0) or (lo and 15);
       r.p.c:=hi>$ff;
       inc(extra);
     end else r.p.c:=res>$ff;
   end;
   5:res:=b;
   6:begin
        res:=a-b;
        r.p.c:=a>=b;
        r.p.z:=(res and $ff)=0;
        r.p.n:=(res and $80)<>0;
        exit;
     end;
   7:begin
     res:=a-b-(1-byte(r.p.c));
     if not r.p.dec then r.p.o_v:=(((a xor b) and (a xor res)) and $80)<>0;
     if r.p.dec then begin
       lo:=(a and 15)-(b and 15)-(1-byte(r.p.c));
       hi:=(a and $f0)-(b and $f0);
       if lo<0 then begin
          dec(lo,6);
          dec(hi,$10);
       end;
       if hi<0 then dec(hi,$60);
       r.p.c:=res>=0;
       res:=(hi and $f0) or (lo and 15);
       inc(extra);
     end else r.p.c:=res>=0;
   end;
   else exit;
 end;
 res:=res and $ff;
 r.p.z:=res=0;
 r.p.n:=(res and $80)<>0;
 if use_t then self.putbyte(target,res)
    else r.a:=res;
end;

procedure cpu_h6280.change_ram_calls(getbyte:tgetbyte16;putbyte:tputbyte16);
begin
  self.getbyte:=getbyte;
  self.putbyte:=putbyte;
end;

procedure cpu_h6280.timer_w(posicion,valor:byte);
begin
	self.io_buffer:=valor;
	case (posicion and 1) of
		0:begin // Counter preload
			  self.timer_load:=((valor and 127)+1)*1024;
      end;
		1:begin // Counter enable
			  if (valor and 1)<>0 then begin // stop -> start causes reload */
          if self.timer_status=0 then self.timer_value:=self.timer_load;
			  end;
			  self.timer_status:=valor and 1;
      end;
end;
end;

procedure cpu_h6280.set_irq_line(irqline,state:byte);
begin
	if (irqline=INPUT_LINE_NMI) then begin
		if (state<>ASSERT_LINE) then exit;
		self.nmi_state:=state;
	end else if (irqline<3) then begin
		// If the state has not changed, just return */
		if (self.irq_state[irqline]=state) then exit;
	    self.irq_state[irqline]:=state;
	end;
  if (self.irq_pending=0) then self.irq_pending:=2;
end;

procedure cpu_h6280.irq_status_w(direccion,valor:byte);
begin
	self.io_buffer:=valor;
	case (direccion and 3) of
		  2:begin // Write irq mask */
			    self.irq_mask:=valor and $7;
			    if (self.irq_pending=0) then self.irq_pending:=2;
        end;
		  3:self.set_irq_line(2,CLEAR_LINE); // Timer irq ack */
    end;
end;

function cpu_h6280.translated(addr:word):dword;
begin
  translated:=((r.m[addr shr 13] shl 13) or (addr and $1fff));
end;

function cpu_h6280.get_internal_r:preg_h6280;
begin
  result:=self.r;
end;

procedure cpu_h6280.reset;
begin
  // Reset the mapper before fetching the reset vector.
  FillChar(r^,SizeOf(reg_h6280),0);
  self.extra_cycles:=0;
  r.p.int:=true;
  r.p.brk:=true;
  // stack starts at 0x01ff */
  r.sp:=$ff;
  // read the reset vector into PC */
  r.pc:=self.getbyte(self.translated($fffe))+(self.getbyte(self.translated($ffff)) shl 8);
  // CPU starts in low speed mode */
  self.clocks_per_cycle:=4;
  // timer off by default */
  self.timer_status:=0;
  self.timer_load:=128*1024;
  // clear pending interrupts */
  self.irq_state[0]:=CLEAR_LINE;
  self.irq_state[1]:=CLEAR_LINE;
  self.irq_state[2]:=CLEAR_LINE;
  self.nmi_state:=CLEAR_LINE;
  self.irq_pending:=0;
  self.irq_mask:=0;
  self.io_buffer:=0;
  self.timer_value:=0;
end;

procedure cpu_h6280.pon_pila(temp:byte);
begin
  r.p.n:=(temp and $80)<>0;
  r.p.o_v:=(temp and $40)<>0;
  r.p.t:=(temp and $20)<>0;
  r.p.brk:=(temp and $10)<>0;
  r.p.dec:=(temp and 8)<>0;
  r.p.int:=(temp and 4)<>0;
  r.p.z:=(temp and 2)<>0;
  r.p.c:=(temp and 1)<>0;
end;

function cpu_h6280.dame_pila:byte;
var
  temp:byte;
begin
  temp:=0;
  if r.p.n then temp:=temp or $80;
  if r.p.o_v then temp:=temp or $40;
  if r.p.t then temp:=temp or $20;
  if r.p.brk then temp:=temp or $10;
  if r.p.dec then temp:=temp or 8;
  if r.p.int then temp:=temp or 4;
  if r.p.z then temp:=temp or 2;
  if r.p.c then temp:=temp or 1;
  dame_pila:=temp;
end;

function cpu_h6280.pull:byte;
begin
  r.sp:=r.sp+1;
  pull:=self.getbyte((r.m[1] shl 13) or $100 or r.sp);
end;

procedure cpu_h6280.push(valor:byte);
begin
  self.putbyte((r.m[1] shl 13) or $100 or r.sp,valor);
  r.sp:=r.sp-1;
end;

procedure cpu_h6280.consume_cycles(cycles:integer);
begin
  self.contador:=self.contador+cycles;
  self.timer_value:=self.timer_value-cycles;
end;

procedure cpu_h6280.update_external_timers(cycles:integer);
var
  chunk:word;
begin
  while cycles>0 do begin
    if cycles>32 then chunk:=32 else chunk:=cycles;
    timers.update(chunk,self.numero_cpu);
    cycles:=cycles-chunk;
  end;
end;

procedure cpu_h6280.do_interrupt(vector:word);
begin
	self.consume_cycles(7*self.clocks_per_cycle);
  self.extra_cycles:=self.extra_cycles+(7*self.clocks_per_cycle);
	self.PUSH(r.pc shr 8);
	self.PUSH(r.pc and $ff);
  r.p.brk:=false;
	self.PUSH(self.dame_pila);
	r.P.int:=true;
  r.p.dec:=false;
  r.pc:=self.getbyte(self.translated(vector))+(self.getbyte(self.translated(vector+1)) shl 8);
end;

procedure cpu_h6280.CHECK_AND_TAKE_IRQ_LINES;
begin
if (self.nmi_state<>CLEAR_LINE) then begin
		self.nmi_state:=CLEAR_LINE;
		self.DO_INTERRUPT($fffc);
end else if not(r.p.int) then begin
  if ((self.irq_state[2]<>CLEAR_LINE) and ((self.irq_mask and $4)=0)) then begin
			self.DO_INTERRUPT($fffa);
      if self.irq_state[2]=HOLD_LINE then self.irq_state[2]:=CLEAR_LINE;
	end	else if ((self.irq_state[0]<>CLEAR_LINE) and ((self.irq_mask and $2)=0)) then begin
			self.DO_INTERRUPT($fff8);
      if self.irq_state[0]=HOLD_LINE then self.irq_state[0]:=CLEAR_LINE;
			//(*cpustate->irq_callback)(cpustate->device, 0);
		end else if ((self.irq_state[1]<>CLEAR_LINE) and ((self.irq_mask and $1)=0)) then begin
			self.DO_INTERRUPT($fff6);
      if self.irq_state[1]=HOLD_LINE then self.irq_state[1]:=CLEAR_LINE;
			//(*cpustate->irq_callback)(cpustate->device, 1);
    end;
end;
end;

procedure cpu_h6280.run(maximo:single);
var
  instruccion,numero,tempb,c:byte;
  from,to_,hi,lo,sum:word;
  estados_demas,tempc:integer;
  instruction_speed:byte;
  regular,store_op:boolean;
  mode,regop:byte;
  posicion:parejas;
  length:dword;
begin
self.contador:=0;
if self.irq_pending=2 then self.irq_pending:=self.irq_pending-1;
while self.contador<maximo do begin
instruction_speed:=self.clocks_per_cycle;
self.extra_cycles:=0;
r.old_pc:=r.pc;
estados_demas:=0;
self.opcode:=true;
instruccion:=self.getbyte(self.translated(r.pc));
self.opcode:=false;
r.pc:=r.pc+1;
regular:=((instruccion and 3)=1) and (instruccion<>$89);
regular:=regular or ((instruccion and $1f)=$12);
store_op:=(instruccion shr 5)=4;
if regular then begin
 mode:=instruccion and $1f;
 case mode of
   $01:begin
     tempb:=byte(self.getbyte(self.translated(r.pc))+r.x);inc(r.pc);
     posicion.l:=self.getbyte((r.m[1]shl 13)or tempb);
     posicion.h:=self.getbyte((r.m[1]shl 13)or byte(tempb+1));
   end;
   $05,$15:begin
     tempb:=self.getbyte(self.translated(r.pc));
     inc(r.pc);
     if mode=$15 then tempb:=byte(tempb+r.x);
     posicion.w:=$2000 or tempb;
   end;
   $09:begin
          numero:=self.getbyte(self.translated(r.pc));
          inc(r.pc);
       end;
   $0d,$19,$1d:begin
     posicion.l:=self.getbyte(self.translated(r.pc));
     posicion.h:=self.getbyte(self.translated(word(r.pc+1)));
     inc(r.pc,2);
     if mode=$19 then posicion.w:=word(posicion.w+r.y);
     if mode=$1d then posicion.w:=word(posicion.w+r.x);
   end;
   $11,$12:begin
     tempb:=self.getbyte(self.translated(r.pc));inc(r.pc);
     posicion.l:=self.getbyte((r.m[1] shl 13) or tempb);
     posicion.h:=self.getbyte((r.m[1] shl 13) or byte(tempb+1));
     if mode=$11 then posicion.w:=word(posicion.w+r.y);
   end;
 end;
 if(mode<>$09) and not store_op then numero:=self.getbyte(self.translated(posicion.w));
    end else if instruccion in[$03,$13,$23] then begin
                numero:=self.getbyte(self.translated(r.pc));
                inc(r.pc);
end else case tipo_dir[instruccion] of
  0:MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(r.old_pc,10), mtInformation,[mbOk], 0);
  1:; //Implicito
  2:begin  //IMM
     numero:=self.getbyte(self.translated(r.pc));
     r.pc:=r.pc+1;
  end;
  3:begin //ABS
     posicion.l:=self.getbyte(self.translated(r.pc));
     posicion.h:=self.getbyte(self.translated(r.pc+1));
     r.pc:=r.pc+2;
    end;
  4:begin //ZPX
     posicion.l:=self.getbyte(self.translated(r.pc))+r.x;
     posicion.h:=0;
     r.pc:=r.pc+1;
    end;
  5:begin //ABS con get
     posicion.l:=self.getbyte(self.translated(r.pc));
     posicion.h:=self.getbyte(self.translated(r.pc+1));
     r.pc:=r.pc+2;
     numero:=self.getbyte(self.translated(posicion.w));
    end;
  6:begin //ZPG
     posicion.l:=self.getbyte(self.translated(r.pc));
     posicion.h:=0;
     r.pc:=r.pc+1;
    end;
  7:begin //ZPG con get
     posicion.l:=self.getbyte(self.translated(r.pc));
     posicion.h:=0;
     r.pc:=r.pc+1;
     numero:=self.getbyte((r.m[1] shl 13) or (posicion.w and $1fff));
    end;
  8:begin //ABX con get
     posicion.l:=self.getbyte(self.translated(r.pc));
     posicion.h:=self.getbyte(self.translated(r.pc+1));
     r.pc:=r.pc+2;
     posicion.w:=posicion.w+r.x;
     numero:=self.getbyte(self.translated(posicion.w));
    end;
  9:begin //ZPI con get
     numero:=self.getbyte(self.translated(r.pc));
     r.pc:=r.pc+1;
     posicion.l:=self.getbyte((r.m[1] shl 13) or numero);
     numero:=numero+1;
     posicion.h:=self.getbyte((r.m[1] shl 13) or numero);
     numero:=self.getbyte(self.translated(posicion.w));
    end;
 $a:begin //IDY con get
     numero:=self.getbyte(self.translated(r.pc));
     r.pc:=r.pc+1;
     posicion.l:=self.getbyte((r.m[1] shl 13) or numero);
     numero:=numero+1;
     posicion.h:=self.getbyte((r.m[1] shl 13) or numero);
     posicion.w:=posicion.w+r.y;
     numero:=self.getbyte(self.translated(posicion.w));
    end;
 $b:begin //IDY
     numero:=self.getbyte(self.translated(r.pc));
     r.pc:=r.pc+1;
     posicion.l:=self.getbyte((r.m[1] shl 13) or numero);
     numero:=numero+1;
     posicion.h:=self.getbyte((r.m[1] shl 13) or numero);
     posicion.w:=posicion.w+r.y;
    end;
 $c:begin //ABX
     posicion.l:=self.getbyte(self.translated(r.pc));
     posicion.h:=self.getbyte(self.translated(r.pc+1));
     r.pc:=r.pc+2;
     posicion.w:=posicion.w+r.x;
    end;
 $d:begin //IND
     hi:=self.getbyte(self.translated(r.pc));
     hi:=hi or (self.getbyte(self.translated(r.pc+1)) shl 8);
     r.pc:=r.pc+2;
     posicion.l:=self.getbyte(self.translated(hi));
     posicion.h:=self.getbyte(self.translated(hi+1));
    end;
 $e:begin //ABY con get
     posicion.l:=self.getbyte(self.translated(r.pc));
     posicion.h:=self.getbyte(self.translated(r.pc+1));
     r.pc:=r.pc+2;
     posicion.w:=posicion.w+r.y;
     numero:=self.getbyte(self.translated(posicion.w));
    end;
 $f:begin //ZPX con get
     posicion.l:=self.getbyte(self.translated(r.pc))+r.x;
     posicion.h:=0;
     r.pc:=r.pc+1;
     numero:=self.getbyte((r.m[1] shl 13) or (posicion.w and $ff));
    end;
 $10:begin //ABY
     posicion.l:=self.getbyte(self.translated(r.pc));
     posicion.h:=self.getbyte(self.translated(r.pc+1));
     r.pc:=r.pc+2;
     posicion.w:=posicion.w+r.y;
    end;
end;
if regular then begin
 if store_op then begin
      r.p.t:=false;
      self.putbyte(self.translated(posicion.w),r.a);
 end else self.alu_group(instruccion shr 5,numero,estados_demas);
end else case instruccion of
  $00:begin //brk
        r.p.t:=false;
        r.pc:=r.pc+1;
        self.PUSH(r.pc shr 8);
	      self.PUSH(r.pc and $ff);
	      self.PUSH(self.dame_pila);
	      r.P.int:=true;
        r.p.dec:=false;
        r.pc:=self.getbyte(self.translated($fff6))+(self.getbyte(self.translated($fff7)) shl 8);
      end;
  $02:begin //sxy
        r.p.t:=false;
        tempb:=r.x;
        r.x:=r.y;
        r.y:=tempb;
      end;
  $03,$13,$23:begin
    r.p.t:=false;
    regop:=0;
    if instruccion=$13 then regop:=2
        else if instruccion=$23 then regop:=3;
    if Assigned(self.io_write) then self.io_write(regop,numero)
        else self.putbyte($1fe000+regop,numero);
  end;
  $04:begin //tsb zp
        r.p.t:=false;
        r.p.n:=(numero and $80)<>0;
        r.p.o_v:=(numero and $40)<>0;
        r.p.z:=((numero or r.a)=0);
        numero:=numero or r.a;
        self.putbyte(((r.m[1] shl 13) or (posicion.w and $1fff)),numero);
      end;
  $05,$09,$0d,$11,$1d:if r.p.t then begin	 //ora
        MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' ORA+T. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0);
	    end else begin
		    r.a:=r.a or numero;
		    r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $06,$16,$0e,$1e:begin //asl memory
        r.p.t:=false;
        r.p.c:=(numero and $80)<>0;
        numero:=numero shl 1;
	      r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
        self.putbyte(((r.m[1] shl 13) or (posicion.w and $1fff)),numero);
      end;
  $07,$17,$27,$37,$47,$57,$67,$77:begin  //rmb0-7
        r.p.t:=false;
        numero:=numero and not(1 shl ((instruccion shr 4) and $7));
        self.putbyte((r.m[1] shl 13) or (posicion.w and $1fff),numero);
      end;
  $08:begin //php
        r.p.t:=false;
        self.push(self.dame_pila);
      end;
  $0a:begin //asl a
        r.p.t:=false;
        r.p.c:=(r.a and $80)<>0;
        r.a:=r.a shl 1;
	      r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $0b,$1b,$2b,$33,$3b,$4b,$5b,$6b,$7b,$8b,$9b,$ab,$bb,$cb,$db,$eb,$fb:r.p.t:=false; //nop
  $0f,$1f,$2f,$3f,$4f,$5f,$6f,$7f:begin //bbr
        r.p.t:=false;
        tempb:=self.getbyte(self.translated(r.pc));
        r.pc:=r.pc+1;
        if (numero and (1 shl ((instruccion shr 4) and $7)))=0 then begin
          estados_demas:=2;
          r.pc:=r.pc+shortint(tempb);
        end;
      end;
  $10:begin  //bpl
        r.p.t:=false;
        if not(r.p.n) then begin
          estados_demas:=2;
          r.pc:=r.pc+shortint(numero);
        end;
      end;
  $14,$1c,$0c:begin // TRB / TSB absolute
    r.p.t:=false;
    r.p.n:=(numero and $80)<>0;
    r.p.o_v:=(numero and $40)<>0;
    if instruccion=$0c then numero:=numero or r.a
        else numero:=numero and not r.a;
    r.p.z:=numero=0;
    if instruccion=$14 then self.putbyte((r.m[1] shl 13) or (posicion.w and $ff),numero)
        else self.putbyte(self.translated(posicion.w),numero);
  end;
  $18:begin //clc
        r.p.t:=false;
        r.p.c:=false;
      end;
  $1a:begin //ina
        r.p.t:=false;
        r.a:=r.a+1;
        r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $20:begin //jsr
        r.p.t:=false;
        r.pc:=r.pc-1;
        self.push(r.pc shr 8);
        self.push(r.pc and $ff);
        r.pc:=posicion.w;
      end;
  $22:begin //sax
        r.p.t:=false;
        tempb:=r.x;
        r.x:=r.a;
        r.a:=tempb;
      end;
  $24,$2c,$34,$3c,$89:begin
    r.p.t:=false;r.p.z:=(r.a and numero)=0;
    r.p.n:=(numero and $80)<>0;
    r.p.o_v:=(numero and $40)<>0;
  end;
  $25,$29,$2d,$3d:if r.p.t then begin //and
        MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' AND+T. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0);
	    end else begin
    		r.a:=r.a and numero;
		    r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $26,$36,$2e,$3e:begin //rol memory
        r.p.t:=false;
        if r.p.c then hi:=(numero shl 1) or 1
          else hi:=numero shl 1;
        r.p.c:=(hi and $100)<>0;
        numero:=hi and $ff;
        r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
        if(instruccion and $0f)=6 then self.putbyte((r.m[1]shl 13)or(posicion.w and $ff),numero)else self.putbyte(self.translated(posicion.w),numero);
      end;
  $28:begin //plp
        self.pon_pila(self.pull);
        r.p.brk:=true;
        if (self.irq_pending=0) then self.irq_pending:=2;
      end;
  $2a:begin
    r.p.t:=false;
    hi:=(word(r.a) shl 1) or byte(r.p.c);
    r.p.c:=(hi and $100)<>0;
    r.a:=hi and $ff;
    r.p.z:=r.a=0;
    r.p.n:=(r.a and $80)<>0;
  end;
  $30:begin //bmi
        r.p.t:=false;
        if r.p.n then begin
          estados_demas:=2;
          r.pc:=r.pc+shortint(numero);
        end;
      end;
  $38:begin //sec
        r.p.t:=false;
        r.p.c:=true;
      end;
  $3a:begin //dea
        r.p.t:=false;
        r.a:=r.a-1;
        r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $40:begin  //rti
        self.pon_pila(self.pull);
        r.p.brk:=true;
        tempb:=self.pull;
        r.pc:=tempb;
        tempb:=self.pull;
        r.pc:=r.pc or (word(tempb) shl 8);
      	if (self.irq_pending=0) then self.irq_pending:=2;
      end;
  $42:begin //say
        r.p.t:=false;
        tempb:=r.y;
        r.y:=r.a;
        r.a:=tempb;
      end;
  $43:begin //tma
        r.p.t:=false;
        if (numero and $01)<>0 then r.a:=r.m[0];
        if (numero and $02)<>0 then r.a:=r.m[1];
        if (numero and $04)<>0 then r.a:=r.m[2];
        if (numero and $08)<>0 then r.a:=r.m[3];
        if (numero and $10)<>0 then r.a:=r.m[4];
        if (numero and $20)<>0 then r.a:=r.m[5];
        if (numero and $40)<>0 then r.a:=r.m[6];
        if (numero and $80)<>0 then r.a:=r.m[7];
      end;
  $44:begin //bsr
        r.p.t:=false;
        self.push((r.pc-1) shr 8);
        self.push((r.pc-1) and $ff);
        r.pc:=r.pc+shortint(numero);
      end;
  $45,$49:if r.p.t then begin //eor
        MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' EOR+T. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0);
      end else begin
        r.a:=r.a xor numero;
        r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $46,$56,$4e,$5e:begin //lsr memory
        r.p.t:=false;
        r.p.c:=(numero and 1)<>0;
        numero:=numero shr 1;
        r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
        self.putbyte(((r.m[1] shl 13) or (posicion.w and $1fff)),numero);
      end;
  $48:begin //pha
        r.p.t:=false;
        self.PUSH(r.a);
      end;
  $4a:begin //lsr a
        r.p.t:=false;
        r.p.c:=(r.a and 1)<>0;
        r.a:=r.a shr 1;
        r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $4c,$6c:begin //jmp
        r.p.t:=false;
	      r.pc:=posicion.w;
      end;
  $50:if not(r.p.o_v) then begin //bvc
          estados_demas:=2;
          r.pc:=r.pc+shortint(numero);
      end;
  $53:begin //tam
        r.p.t:=false;
        if (numero and $01)<>0 then r.m[0]:=r.a;
        if (numero and $02)<>0 then r.m[1]:=r.a;
        if (numero and $04)<>0 then r.m[2]:=r.a;
        if (numero and $08)<>0 then r.m[3]:=r.a;
        if (numero and $10)<>0 then r.m[4]:=r.a;
        if (numero and $20)<>0 then r.m[5]:=r.a;
        if (numero and $40)<>0 then r.m[6]:=r.a;
        if (numero and $80)<>0 then r.m[7]:=r.a;
      end;
  $54:begin
        r.p.t:=false;
        self.clocks_per_cycle:=4;
      end;
  $58:begin //cli
        r.p.t:=false;
        if r.p.int then begin
          r.p.int:=false;
          if (self.irq_pending=0) then self.irq_pending:=2;
        end;
      end;
  $5a:begin //phy
        r.p.t:=false;
        self.PUSH(r.y);
      end;
  $60:begin //rts
        r.p.t:=false;
        tempb:=self.pull;
        r.pc:=tempb;
        tempb:=self.pull;
        r.pc:=r.pc or (word(tempb) shl 8);
        r.pc:=r.pc+1;
      end;
  $62:begin //cla
        r.p.t:=false;
        r.a:=0;
      end;
  $64,$74:begin //stz zp
        r.p.t:=false;
        self.putbyte(((r.m[1] shl 13) or (posicion.w and $1fff)),0);
      end;
  $65,$69,$6d,$71,$79,$7d:begin //adc
        if r.p.t then begin
          MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' ADC+T. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0);
	      end else begin
      		if r.p.dec then begin
            if r.p.c then c:=1
              else c:=0;
      			lo:=(r.a and $0f)+(numero and $0f)+c;
      			hi:=(r.a and $f0)+(numero and $f0);
      			r.p.c:=false;
      			if (lo>$09) then begin
      				hi:=hi+$10;
      				lo:=lo+06;
			      end;
      			if (hi>$90) then hi:=hi+$60;
      			if (hi and $ff00)<>0 then r.p.c:=true;
      			r.a:=(lo and $0f)+(hi and $f0);
            estados_demas:=1;
		      end else begin
      			if r.p.c then c:=1
              else c:=0;
      			sum:=r.a+numero+c;
            r.p.o_v:=false;
            r.p.c:=false;
      			if (not(r.a xor numero) and (r.a xor sum) and $80)<>0	then r.p.o_v:=true;
      			if (sum and $ff00)<>0 then r.p.c:=true;
      			r.a:=sum and $ff;
		      end;
		      r.p.z:=(r.a=0);
          r.p.n:=(r.a and $80)<>0;
	      end;
      end;
  $66,$76,$6e,$7e:begin //ror memory
        r.p.t:=false;
        if r.p.c then hi:=$100 or numero
          else hi:=numero;
        r.p.c:=(numero and 1)<>0;
        numero:=hi shr 1;
        r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
        if(instruccion and $0f)=6 then self.putbyte((r.m[1]shl 13)or(posicion.w and $ff),numero)else self.putbyte(self.translated(posicion.w),numero);
      end;
  $68:begin //pla
        r.p.t:=false;
        r.a:=self.pull;
        r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $6a:begin //ror
        r.p.t:=false;
        if r.p.c then hi:=$100 or r.a
          else hi:=r.a;
        r.p.c:=(r.a and 1)<>0;
        r.a:=hi shr 1;
        r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $70:if r.p.o_v then begin //bvs
          estados_demas:=2;
          r.pc:=r.pc+shortint(numero);
      end;
  $73:begin //tii
        r.p.t:=false;
	      from:=self.getbyte(self.translated(r.pc))+(self.getbyte(self.translated(r.pc+1)) shl 8);
	      to_:=self.getbyte(self.translated(r.pc+2))+(self.getbyte(self.translated(r.pc+3)) shl 8);
	      length:=self.getbyte(self.translated(r.pc+4))+(self.getbyte(self.translated(r.pc+5)) shl 8);
	      r.pc:=r.pc+6;
	      if (length=0) then length:=$10000;
        estados_demas:=(6*length)+17;
	      while (length<>0) do begin
          length:=length-1;
          numero:=self.getbyte(self.translated(from));
          self.putbyte(self.translated(to_),numero);
		      to_:=to_+1;
		      from:=from+1;
	      end;
      end;
  $78:begin //sei
        r.p.t:=false;
        r.p.int:=true;
      end;
  $7a:begin //ply
        r.p.t:=false;
        r.y:=self.pull;
        r.p.z:=(r.y=0);
        r.p.n:=(r.y and $80)<>0;
      end;
  $7c:begin //jmp ind+x
        r.p.t:=false;
        posicion.w:=posicion.w+r.x;
        r.pc:=self.getbyte(self.translated(posicion.w));
        r.pc:=r.pc or (self.getbyte(self.translated(posicion.w+1)) shl 8);
      end;
  $80:begin //bra
        r.p.t:=false;
        estados_demas:=2;
        r.pc:=r.pc+shortint(numero);
      end;
  $82:begin  //clx
        r.p.t:=false;
        r.x:=0;
      end;
  $83,$a3:begin // TST #imm,zp / zp,X
        r.p.t:=false;
        tempb:=self.getbyte(self.translated(r.pc));
        inc(r.pc);
        c:=self.getbyte(self.translated(r.pc));
        inc(r.pc);
        if instruccion=$a3 then c:=byte(c+r.x);
        numero:=self.getbyte((r.m[1]shl 13)or c);
        r.p.z:=(tempb and numero)=0;
        r.p.n:=(numero and $80)<>0;
        r.p.o_v:=(numero and $40)<>0;
  end;
  $84,$94:begin //sty zp
        r.p.t:=false;
        self.putbyte((r.m[1] shl 13) or (posicion.w and $1fff),r.y);
      end;
  $85,$95:begin //sta zp
        r.p.t:=false;
        self.putbyte((r.m[1] shl 13) or (posicion.w and $1fff),r.a);
      end;
  $86:begin //stx zp
        r.p.t:=false;
        self.putbyte((r.m[1] shl 13) or (posicion.w and $1fff),r.x);
      end;
  $87,$97,$a7,$b7,$c7,$d7,$e7,$f7:begin //smb0-7
        r.p.t:=false;
        numero:=numero or (1 shl ((instruccion shr 4) and $7));
        self.putbyte((r.m[1] shl 13) or (posicion.w and $1fff),numero);
      end;
  $88:begin //dey
        r.p.t:=false;
	      r.y:=r.y-1;
        r.p.z:=(r.y=0);
        r.p.n:=(r.y and $80)<>0;
      end;
  $8a:begin  //txa
        r.p.t:=false;
        r.a:=r.x;
        r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $8c:begin //sty
        r.p.t:=false;
        self.putbyte(self.translated(posicion.w),r.y);
      end;
  $8d,$91,$99,$9d:begin //sta
        r.p.t:=false;
        self.putbyte(self.translated(posicion.w),r.a);
      end;
  $8e:begin //stx
        r.p.t:=false;
        self.putbyte(self.translated(posicion.w),r.x);
      end;
  $8f,$9f,$af,$bf,$cf,$df,$ef,$ff:begin //bbs
        r.p.t:=false;
        tempb:=self.getbyte(self.translated(r.pc));
        r.pc:=r.pc+1;
        if (numero and (1 shl ((instruccion shr 4) and $7)))<>0 then begin
          estados_demas:=2;
          r.pc:=r.pc+shortint(tempb);
        end;
      end;
  $90:begin  //bcc
        r.p.t:=false;
        if not(r.p.c) then begin
          estados_demas:=2;
          r.pc:=r.pc+shortint(numero);
        end;
      end;
  $93:begin //tst
        r.p.t:=false;
        posicion.l:=self.getbyte(self.translated(r.pc));
        posicion.h:=self.getbyte(self.translated(r.pc+1));
        r.pc:=r.pc+2;
        tempb:=self.getbyte(self.translated(posicion.w));
		    r.p.n:=(tempb and $80)<>0;
        r.p.o_v:=(tempb and $40)<>0;
		    r.p.z:=(tempb and numero)=0;
      end;
  $96,$b6:begin
        tempb:=byte(posicion.w+r.y);
        r.p.t:=false;
        if instruccion=$96 then self.putbyte((r.m[1] shl 13) or tempb,r.x)
          else begin
                  r.x:=self.getbyte((r.m[1] shl 13) or tempb);
                  r.p.z:=r.x=0;
                  r.p.n:=(r.x and $80)<>0;
               end;
  end;
  $98:begin //tya
        r.p.t:=false;
        r.a:=r.y;
        r.p.z:=(r.a=0);
        r.p.n:=(r.a and $80)<>0;
      end;
  $9a:begin //txs
        r.p.t:=false;
        r.sp:=r.x;
      end;
  $9c,$9e:begin //stz
        r.p.t:=false;
        self.putbyte(self.translated(posicion.w),0);
      end;
  $a0,$a4,$ac,$b4,$bc:begin  //ldy
        r.p.t:=false;
	      r.y:=numero;
        r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
      end;
  $a2,$a6,$ae,$be:begin  //ldx
        r.p.t:=false;
	      r.x:=numero;
        r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
      end;
  $a5,$a9,$ad,$b1,$b2,$b5,$b9,$bd:begin  //lda
        r.p.t:=false;
	      r.a:=numero;
        r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
      end;
  $a8:begin //tay
        r.p.t:=false;
	      r.y:=r.a;
        r.p.z:=(r.y=0);
        r.p.n:=(r.y and $80)<>0;
      end;
  $aa:begin //tax
        r.p.t:=false;
	      r.x:=r.a;
        r.p.z:=(r.x=0);
        r.p.n:=(r.x and $80)<>0;
      end;
  $b0:begin //bcs
        r.p.t:=false;
        if r.p.c then begin
          estados_demas:=2;
          r.pc:=r.pc+shortint(numero);
        end;
      end;
  $b3:begin //tst abx
        r.p.t:=false;
        posicion.l:=self.getbyte(self.translated(r.pc));
        posicion.h:=self.getbyte(self.translated(r.pc+1));
        r.pc:=r.pc+2;
        tempb:=self.getbyte(self.translated(posicion.w+r.x));
		    r.p.n:=(tempb and $80)<>0;
        r.p.o_v:=(tempb and $40)<>0;
		    r.p.z:=(tempb and numero)=0;
      end;
  $b8:begin
        r.p.t:=false;
        r.p.o_v:=false;
      end;
  $ba:begin
          r.p.t:=false;
          r.x:=r.sp;
          r.p.z:=r.x=0;
          r.p.n:=(r.x and $80)<>0;
      end;
  $c0,$c4,$cc:begin //cpy
        r.p.t:=false;
        r.p.c:=(r.y>=numero);
        r.p.z:=(((r.y-numero) and $ff)=0);
        r.p.n:=((r.y-numero) and $80)<>0;
      end;
  $c2:begin //cly
        r.p.t:=false;
        r.y:=0;
      end;
  $c3,$d3,$e3:begin // TDD / TIN / TIA
    r.p.t:=false;from:=self.getbyte(self.translated(r.pc))or(word(self.getbyte(self.translated(word(r.pc+1))))shl 8);
    to_:=self.getbyte(self.translated(word(r.pc+2)))or(word(self.getbyte(self.translated(word(r.pc+3))))shl 8);
    length:=self.getbyte(self.translated(word(r.pc+4)))or(word(self.getbyte(self.translated(word(r.pc+5))))shl 8);inc(r.pc,6);
    if length=0 then length:=$10000;estados_demas:=17+6*length;numero:=0;
    while length<>0 do begin
      if instruccion=$e3 then self.putbyte(self.translated(word(to_+numero)),self.getbyte(self.translated(from)))
        else self.putbyte(self.translated(to_),self.getbyte(self.translated(from)));
      if instruccion=$c3 then begin from:=word(from-1);to_:=word(to_-1);end
        else begin from:=word(from+1);if instruccion=$e3 then numero:=numero xor 1;end;
      dec(length);
    end;
  end;
  $c5,$c9,$cd,$d1,$d2,$d5,$d9,$dd:begin  //cmp
        r.p.t:=false;
        r.p.c:=(r.a>=numero);
        r.p.z:=(((r.a-numero) and $ff)=0);
        r.p.n:=((r.a-numero) and $80)<>0;
      end;
  $c6,$d6:begin //dec zpg
        r.p.t:=false;
        numero:=numero-1;
        r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
        self.putbyte((r.m[1] shl 13) or (posicion.w and $1fff),numero);
      end;
  $c8:begin //iny
        r.p.t:=false;
        r.y:=r.y+1;
        r.p.z:=(r.y=0);
        r.p.n:=(r.y and $80)<>0;
      end;
  $ca:begin //dex
        r.p.t:=false;
	      r.x:=r.x-1;
        r.p.z:=(r.x=0);
        r.p.n:=(r.x and $80)<>0;
      end;
  $ce,$de:begin //dec
        r.p.t:=false;
        numero:=numero-1;
        r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
        self.putbyte(self.translated(posicion.w),numero);
      end;
  $d0:begin //bne
        r.p.t:=false;
        if not(r.p.z) then begin
          estados_demas:=2;
          r.pc:=r.pc+shortint(numero);
        end;
      end;
  $d4:self.clocks_per_cycle:=1;  //csh
  $d8:begin  //cld
        r.p.t:=false;
        r.p.dec:=false;
      end;
  $da:begin //phx
        r.p.t:=false;
        self.PUSH(r.x);
      end;
  $e0,$e4,$ec:begin  //cpx
        r.p.t:=false;
        r.p.c:=(r.x>=numero);
        r.p.z:=(((r.x-numero) and $ff)=0);
        r.p.n:=((r.x-numero) and $80)<>0;
      end;
  $e5,$e9,$ed,$f1,$f5,$fd:begin //sbc
       if r.p.t then begin
		      MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' SBC+T. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0);
	     end else begin
          if r.p.dec then begin
            if r.p.c then c:=0
              else c:=1;
			      sum:=r.a-numero-c;
      			lo:=(r.a and $0f)-(numero and $0f)-c;
      			hi:=(r.a and $f0)-(numero and $f0);
            r.p.c:=false;
      			if (lo and $f0)<>0 then lo:=lo-6;
      			if (lo and $80)<>0 then hi:=hi-$10;
      			if (hi and $0f00)<>0 then hi:=hi-$60;
      			if ((sum and $ff00)=0) then r.p.c:=true;
      			r.a:=(lo and $0f)+(hi and $f0);
      			estados_demas:=1;
		      end else begin
      			if r.p.c then c:=0
              else c:=1;
      			sum:=r.a-numero-c;
            r.p.o_v:=false;
            r.p.c:=false;
      			if ((r.a xor numero) and (r.a xor sum) and $80)<>0 then r.p.o_v:=true;
      			if ((sum and $ff00)=0) then r.p.c:=true;
      			r.a:=sum and $ff;
		      end;
          r.p.z:=(r.a=0);
          r.p.n:=(r.a and $80)<>0;
	     end;
      end;
  $e6,$f6:begin //inc zpg
        r.p.t:=false;
        numero:=numero+1;
        r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
        self.putbyte((r.m[1] shl 13) or (posicion.w and $1fff),numero);
      end;
  $e8:begin //inx
        r.p.t:=false;
        r.x:=r.x+1;
        r.p.z:=(r.x=0);
        r.p.n:=(r.x and $80)<>0;
      end;
  $ea:r.p.t:=false; //nop
  $ee,$fe:begin //inc
        r.p.t:=false;
        numero:=numero+1;
        r.p.z:=(numero=0);
        r.p.n:=(numero and $80)<>0;
        self.putbyte(self.translated(posicion.w),numero);
      end;
  $f0:begin //beq
        r.p.t:=false;
        if r.p.z then begin
          estados_demas:=2;
          r.pc:=r.pc+shortint(numero);
        end;
      end;
  $f3:begin //tai
        r.p.t:=false;
        from:=self.getbyte(self.translated(r.pc))+(self.getbyte(self.translated(r.pc+1)) shl 8);
	      to_:=self.getbyte(self.translated(r.pc+2))+(self.getbyte(self.translated(r.pc+3)) shl 8);
	      length:=self.getbyte(self.translated(r.pc+4))+(self.getbyte(self.translated(r.pc+5)) shl 8);
	      r.pc:=r.pc+6;
	      numero:=0;
	      if (length=0) then length:=$10000;
	      estados_demas:=(6*length)+17;
	      while (length<>0) do begin
          self.putbyte(self.translated(to_),self.getbyte(self.translated(from+numero)));
		      to_:=to_+1;
		      numero:=numero xor 1;
          length:=length-1;
	      end;
      end;
  $f4:r.p.t:=true;
  $f8:begin //sed
        r.p.t:=false;
        r.p.dec:=true;
      end;
  $fa:begin //plx
        r.p.t:=false;
        r.x:=self.pull;
        r.p.z:=(r.x=0);
        r.p.n:=(r.x and $80)<>0;
      end;
end;  //del case instruccion
tempc:=(estados_t[instruccion]+estados_demas)*instruction_speed;
self.consume_cycles(tempc);
//IRQ's
if (self.irq_pending<>0) then begin
  if (self.irq_pending=1) then begin
    if not(r.p.int) then begin
					self.irq_pending:=self.irq_pending-1;
					self.CHECK_AND_TAKE_IRQ_LINES;
    end;
  end else begin
    self.irq_pending:=self.irq_pending-1;
  end;
end;
// Check internal timer */
if (self.timer_status<>0) then begin
  if (self.timer_value<=0) then begin
				if (self.irq_pending=0) then self.irq_pending:=1;
				while (self.timer_value<=0) do self.timer_value:=self.timer_value+self.timer_load;
				self.set_irq_line(2,ASSERT_LINE);
  end;
end;
self.update_external_timers(tempc+self.extra_cycles);
end;
end;

end.
