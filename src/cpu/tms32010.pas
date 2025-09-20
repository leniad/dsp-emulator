unit tms32010;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,dialogs,sysutils,vars_hide,cpu_misc;

type
        band_tms32010=record
                ov,ovm,int:boolean;
                dp_reg:boolean;
                arp_reg:byte;
        end;
        reg_tms32010=record
                pc:parejas;
                sp:array[0..3] of word;
                str:band_tms32010;
                acc,oldacc,alu:dparejas;
                preg,treg:dword;
                ar:array[0..1] of word;
        end;
        preg_tms32010=^reg_tms32010;
        type_bio=function:boolean;
        cpu_tms32010=class(cpu_class)
                constructor create(clock:dword);
                destructor free;
            public
                procedure run(maximo:single);
                procedure reset;
                procedure change_io_calls(in_bio:type_bio;in_port0,in_port1,in_port2,in_port3,in_port4,in_port5,in_port6,in_port7:cpu_inport_call16;out_port0,out_port1,out_port2,out_port3,out_port4,out_port5,out_port6,out_port7:cpu_outport_call16);
                function get_rom_addr:pbyte;
            private
                r:preg_tms32010;
                memaccess:word;
                rom:array[0..$fff] of word;
                ram:array[0..$ff] of word;
                in_bio:type_bio;
                in_port:array[0..7] of cpu_inport_call16;
                out_port:array[0..7] of cpu_outport_call16;
                procedure push_stack(valor:word);
                function pop_stack:word;
                procedure calculate_add_overflow(addval:longint);
                procedure calculate_sub_overflow(subval:longint);
                procedure update_ar(valor:byte);
                procedure update_arp(valor:byte);
                procedure putdata(valor:word;instruccion:byte);
                procedure putdata_sar(ar:byte;instruccion:byte);
                procedure getdata(instruccion,shift:byte;signext:boolean);
                function ext_irq:byte;
        end;

var
    tms32010_0:cpu_tms32010;

implementation
const
  ciclos_tms:array[0..$ff] of byte=(
    	 // 0 1 2 3 4 5 6 7 8 9 A B C D E F
          1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
          1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
          1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
          1,1,0,0,0,0,0,0,1,1,0,0,0,0,0,0,
          2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,
          1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,
          1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,1,
          1,1,0,0,0,0,0,0,1,1,1,1,1,3,1,0,
          1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
          1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
          0,0,0,0,2,2,2,0,2,2,2,2,2,2,2,2);

constructor cpu_tms32010.create(clock:dword);
begin
getmem(self.r,sizeof(reg_tms32010));
fillchar(self.r^,sizeof(reg_tms32010),0);
self.numero_cpu:=cpu_main_init(clock div 4);
self.in_bio:=nil;
self.in_port[0]:=nil;
self.in_port[1]:=nil;
self.in_port[2]:=nil;
self.in_port[3]:=nil;
self.in_port[4]:=nil;
self.in_port[5]:=nil;
self.in_port[6]:=nil;
self.in_port[7]:=nil;
self.out_port[0]:=nil;
self.out_port[1]:=nil;
self.out_port[2]:=nil;
self.out_port[3]:=nil;
self.out_port[4]:=nil;
self.out_port[5]:=nil;
self.out_port[6]:=nil;
self.out_port[7]:=nil;
self.clock:=clock div 4;
self.tframes:=(clock/4/llamadas_maquina.scanlines)/llamadas_maquina.fps_max;
end;

destructor cpu_tms32010.free;
begin
freemem(self.r);
end;

procedure cpu_tms32010.reset;
begin
self.opcode:=false;
r.pc.w:=0;
r.acc.l:=0;
r.sp[0]:=0;
r.sp[1]:=0;
r.sp[2]:=0;
r.sp[3]:=0;
self.change_irq(CLEAR_LINE);
self.change_halt(CLEAR_LINE);
r.str.arp_reg:=0;
end;

procedure cpu_tms32010.change_io_calls(in_bio:type_bio;in_port0,in_port1,in_port2,in_port3,in_port4,in_port5,in_port6,in_port7:cpu_inport_call16;out_port0,out_port1,out_port2,out_port3,out_port4,out_port5,out_port6,out_port7:cpu_outport_call16);
begin
  self.in_bio:=in_bio;
  self.in_port[0]:=in_port0;
  self.in_port[1]:=in_port1;
  self.in_port[2]:=in_port2;
  self.in_port[3]:=in_port3;
  self.in_port[4]:=in_port4;
  self.in_port[5]:=in_port5;
  self.in_port[6]:=in_port6;
  self.in_port[7]:=in_port7;
  self.out_port[0]:=out_port0;
  self.out_port[1]:=out_port1;
  self.out_port[2]:=out_port2;
  self.out_port[3]:=out_port3;
  self.out_port[4]:=out_port4;
  self.out_port[5]:=out_port5;
  self.out_port[6]:=out_port6;
  self.out_port[7]:=out_port7;
end;

function cpu_tms32010.get_rom_addr:pbyte;
begin
  get_rom_addr:=@self.rom[0];
end;

procedure cpu_tms32010.push_stack(valor:word);
begin
r.sp[0]:=r.sp[1];
r.sp[1]:=r.sp[2];
r.sp[2]:=r.sp[3];
r.sp[3]:=valor;
end;

function cpu_tms32010.pop_stack:word;
var
  ret:word;
begin
  ret:=r.sp[3];
	r.sp[3]:=r.sp[2];
	r.sp[2]:=r.sp[1];
	r.sp[1]:=r.sp[0];
	pop_stack:=ret;
end;

procedure cpu_tms32010.calculate_add_overflow(addval:longint);
var
  temp:longint;
begin
  temp:=longint(not(r.oldacc.l xor addval) and (r.oldacc.l xor r.acc.l));
  if temp<0 then begin
    r.str.ov:=true;
    if r.str.ovm then begin
      if longint(r.oldacc.l)<0 then r.acc.l:=$80000000
        else r.acc.l:=$7fffffff;
    end;
	end;
end;

procedure cpu_tms32010.calculate_sub_overflow(subval:longint);
var
  temp:longint;
begin
  temp:=longint((r.oldacc.l xor subval) and (r.oldacc.l xor r.acc.l));
  if temp<0 then begin
    r.str.ov:=true;
    if r.str.ovm then begin
      if longint(r.oldacc.l)<0 then r.acc.l:=$80000000
        else r.acc.l:=$7fffffff;
    end;
	end;
end;

procedure cpu_tms32010.update_ar(valor:byte);
var
  tmp:word;
begin
	if (valor and $30)<>0 then begin
		tmp:=r.ar[r.str.arp_reg];
		if (valor and $20)<>0 then tmp:=tmp+1;
		if (valor and $10)<>0 then tmp:=tmp-1;
    r.ar[r.str.arp_reg]:=(r.ar[r.str.arp_reg] and $fe00) or (tmp and $01ff);
	end;
end;

procedure cpu_tms32010.update_arp(valor:byte);
begin
	if (valor and $08)=0 then r.str.arp_reg:=(valor and $01);
end;

procedure cpu_tms32010.putdata(valor:word;instruccion:byte);
begin
  if (instruccion and $80)<>0 then begin //ind
    self.memaccess:=r.ar[r.str.arp_reg];
    self.update_ar(instruccion);
		self.update_arp(instruccion);
  end	else self.memaccess:=instruccion and $7f;
  self.ram[self.memaccess]:=valor;
end;

procedure cpu_tms32010.putdata_sar(ar:byte;instruccion:byte);
begin
  if (instruccion and $80)<>0 then begin //ind
    self.memaccess:=r.ar[r.str.arp_reg];
    self.update_ar(instruccion);
		self.update_arp(instruccion);
  end	else self.memaccess:=instruccion and $7f;
  self.ram[self.memaccess]:=r.ar[ar];
end;

procedure cpu_tms32010.getdata(instruccion,shift:byte;signext:boolean);
begin
  if (instruccion and $80)<>0 then self.memaccess:=r.ar[r.str.arp_reg]
    else self.memaccess:=instruccion and $7f;
	r.alu.l:=word(self.ram[self.memaccess]);
	if signext then r.alu.l:=smallint(r.alu.l);
  r.alu.l:=r.alu.l shl shift;
  if (instruccion and $80)<>0 then begin
    self.update_ar(instruccion);
		self.update_arp(instruccion);
  end
end;

function cpu_tms32010.ext_irq:byte;
var
  ret:byte;
begin
ret:=0;
if not(r.str.int) then begin
    self.change_irq(CLEAR_LINE);
    r.str.int:=true;
		self.push_stack(r.pc.w);
		r.pc.w:=$0002;
		ret:=3;	// 3 cycles used due to PUSH and DINT operation ? */
end;
ext_irq:=ret;
end;

procedure cpu_tms32010.run(maximo:single);
var
  instruccion:parejas;
  f,tempw:word;
begin
self.contador:=0;
while self.contador<maximo do begin
if self.pedir_halt<>CLEAR_LINE then begin
  tempw:=trunc(maximo);
  for f:=1 to tempw do begin
    self.contador:=self.contador+1;
    //if @self.despues_instruccion<>nil then self.despues_instruccion(1);
    //timers.update(1,self.numero_cpu);
    if self.pedir_halt=CLEAR_LINE then break;
  end;
  if self.pedir_halt<>CLEAR_LINE then exit;
end;
self.estados_demas:=0;
self.opcode:=true;
instruccion.w:=self.rom[r.pc.w];
self.opcode:=false;
//comprobar irq's
if (self.pedir_irq<>CLEAR_LINE) then begin
  if ((instruccion.h<>$6d) and ((instruccion.h and $e0)<>$80) and (instruccion.w<>$7f82)) then begin
      self.estados_demas:=self.ext_irq;
      self.opcode:=true;
      instruccion.w:=self.rom[r.pc.w];
      self.opcode:=false;
  end;
end;
r.pc.w:=r.pc.w+1;
case instruccion.h of
  $00..$0f:begin  //add_sh
              r.oldacc.l:=r.acc.l;
              self.getdata(instruccion.l,instruccion.h and $f,true);
              r.acc.l:=r.acc.l+r.alu.l;
              self.calculate_add_overflow(r.alu.l);
           end;
  $10..$1f:begin //sub_sh
              r.oldacc.l:=r.acc.l;
              self.getdata(instruccion.l,instruccion.h and $f,true);
              r.acc.l:=r.acc.l-r.alu.l;
              self.calculate_sub_overflow(r.alu.l);
           end;
  $20..$2f:begin //lac_sh
              self.getdata(instruccion.l,instruccion.h and $f,true);
	            r.acc.l:=r.alu.l;
           end;
  $30:self.putdata_sar(0,instruccion.l); //sar_ar0
  $31:self.putdata_sar(1,instruccion.l); //sar_ar1
  $32..$37,$3a..$3f,$51..$57,$72..$77,$a0..$f3,$f7:MessageDlg('Intruccion ilegal!!! DSP '+inttostr(r.pc.w), mtInformation,[mbOk], 0);
  $38:begin  //lar ar0
          self.getdata(instruccion.l,0,false);
          r.ar[0]:=r.alu.wl;
      end;
  $39:begin  //lar ar1
          self.getdata(instruccion.l,0,false);
          r.ar[1]:=r.alu.wl;
      end;
  $40..$47:begin  //in_p
              r.alu.l:=self.in_port[instruccion.h and $7];
              self.putdata(r.alu.wl,instruccion.l);
           end;
  $48..$4f:begin  //out_p
              self.getdata(instruccion.l,0,false);
              if @self.out_port[instruccion.h and 7]<>nil then self.out_port[instruccion.h and 7](r.alu.wl)
                else MessageDlg('OUT sin funcion! '+inttostr(instruccion.h and 7), mtInformation,[mbOk], 0);
      end;
  $50:self.putdata(r.acc.wl,instruccion.l);  //sacl
  $58..$5f:begin //sach_sh
              r.alu.l:=(r.acc.l shl (instruccion.h and $7));
              self.putdata(r.alu.wh,instruccion.l);
           end;
  $60:begin  //addh
        r.oldacc.l:=r.acc.l;
        self.getdata(instruccion.l,0,false);
        r.acc.wh:=r.acc.wh+r.alu.wl;
	      if (smallint((not(r.oldacc.wh xor r.ALU.wh)) and (r.oldacc.wh xor r.acc.wh)) < 0) then begin
      		r.str.ov:=true;
      		if r.str.ovm then begin
            if (smallint(r.oldacc.wh)<0) then r.ACC.wh:=$8000
              else r.ACC.wh:=$7fff;
          end;
	      end;
      end;
  $61:begin //adds
        r.oldacc.l:=r.acc.l;
        self.getdata(instruccion.l,0,false);
        r.acc.l:=r.acc.l+r.alu.l;
        self.calculate_add_overflow(r.alu.l);
      end;
  $62:begin  //subh
        r.oldacc.l:=r.acc.l;
        self.getdata(instruccion.l,16,false);
        r.acc.l:=r.acc.l-r.alu.l;
        self.calculate_sub_overflow(r.alu.l);
      end;
  $63:begin //subs
        r.oldacc.l:=r.acc.l;
        self.getdata(instruccion.l,0,false);
        r.acc.l:=r.acc.l-r.alu.l;
        self.calculate_sub_overflow(r.alu.l);
      end;
  $65:begin  //zalh
        self.getdata(instruccion.l,0,false);
        r.acc.wh:=r.alu.wl;
        r.acc.wl:=$0000;
      end;
  $66:begin //zals
        self.getdata(instruccion.l,0,false);
        r.acc.wl:=r.alu.wl;
        r.acc.wh:=$0000;
      end;
  $67:begin //tblr
	      r.alu.l:=self.rom[r.acc.wl];
        self.putdata(r.alu.wl,instruccion.l);
        r.sp[0]:=r.sp[1];
      end;
  $68:if (instruccion.l and $80)<>0 then begin //larp_mar
		    self.update_ar(instruccion.l);
		    self.update_arp(instruccion.l);
	    end;
  $69:begin //dmov
         self.getdata(instruccion.l,0,false);
         self.ram[self.memaccess+1]:=r.alu.wl;
      end;
  $6a:begin //lt
        self.getdata(instruccion.l,0,false);
        r.treg:=r.alu.l;
      end;
  $6d:begin //mpy
        self.getdata(instruccion.l,0,false);
        r.preg:=smallint(r.alu.wl)*smallint(r.treg);
	      if (r.preg=$40000000) then r.preg:=$c0000000;
      end;
  $6e:r.str.dp_reg:=(instruccion.l and 1)<>0; //ldpk
  $70:r.ar[0]:=instruccion.l; //lark0
  $71:r.ar[1]:=instruccion.l; //lark1
  $78:begin  //xor
        self.getdata(instruccion.l,0,false);
        r.acc.l:=r.acc.l xor r.alu.l;
      end;
  $79:begin //and
        self.getdata(instruccion.l,0,false);
        r.acc.l:=r.acc.l and r.alu.l;
      end;
  $7a:begin  //or
        self.getdata(instruccion.l,0,false);
        r.acc.l:=r.acc.l or r.alu.l;
      end;
  $7e:r.acc.l:=instruccion.l; //lack
  $7f:begin //el $7f es compuesto
        self.estados_demas:=self.estados_demas+1;
        case instruccion.l of
          $80:; //nop
          $81:r.str.int:=true; //dint
          $82:r.str.int:=false;  //eint
          $88:if (longint(r.acc.l)<0) then begin //abst
                r.acc.l:=-r.acc.l;
		            if (r.str.ovm and (r.acc.l=$80000000)) then r.acc.l:=r.acc.l-1;
              end;
          $89:r.acc.l:=0; //zac
          $8a:r.str.ovm:=false;  //rovm
          $8c:begin //cala
                self.push_stack(r.pc.w);
                r.pc.w:=r.acc.wl;
              end;
          $8d:r.pc.w:=self.pop_stack; //ret
          $8e:r.acc.l:=r.preg; //pac
            else MessageDlg('Intruccion desconocida $7f DSP '+inttostr(r.pc.w-1), mtInformation,[mbOk], 0);
        end;
      end;
  $80..$9f:r.preg:=smallint(r.treg)*(smallint(instruccion.l shl 3) shr 3); //mpyk
  $f4:begin //banz
        if (r.ar[r.str.arp_reg] and $01ff)<>0 then begin
          r.pc.w:=self.rom[r.pc.w];
          self.estados_demas:=self.estados_demas+1;
        end else r.pc.w:=r.pc.w+1;
	      r.alu.wl:=r.ar[r.str.arp_reg];
        r.alu.wl:=r.alu.wl-1;
        r.ar[r.str.arp_reg]:=(r.ar[r.str.arp_reg] and $fe00) or (r.alu.wl and $1ff);
      end;
  $f5:if r.str.ov then begin  //bv
          r.pc.w:=self.rom[r.pc.w];
          r.str.ov:=false;
          self.estados_demas:=self.estados_demas+1;
	    end	else r.pc.w:=r.pc.w+1;
  $f6:if self.in_bio then begin  //bioz
          r.pc.w:=self.rom[r.pc.w];
          self.estados_demas:=self.estados_demas+1;
      end else r.pc.w:=r.pc.w+1;
  $f8:begin //call
        r.pc.w:=r.pc.w+1;
	      self.push_stack(r.pc.w);
        r.pc.w:=self.rom[r.pc.w-1];
      end;
  $f9:r.pc.w:=self.rom[r.pc.w]; //br
  $fa:if longint(r.acc.l)<0 then begin //blz
          r.pc.w:=self.rom[r.pc.w];
          self.estados_demas:=self.estados_demas+1;
      end else r.pc.w:=r.pc.w+1;
  $fb:if (longint(r.acc.l)<=0) then begin //blez
          r.pc.w:=self.rom[r.pc.w];
          self.estados_demas:=self.estados_demas+1;
      end else r.pc.w:=r.pc.w+1;
  $fc:if longint(r.acc.l)>0 then begin  //bgz
          r.pc.w:=self.rom[r.pc.w];
          self.estados_demas:=self.estados_demas+1;
        end else r.pc.w:=r.pc.w+1;
  $fd:if longint(r.acc.l)>=0 then begin //bgez
          r.pc.w:=self.rom[r.pc.w];
          self.estados_demas:=self.estados_demas+1;
      end else r.pc.w:=r.pc.w+1;
  $fe:if (r.acc.l<>0) then begin  //bnz
          r.pc.w:=self.rom[r.pc.w];
          self.estados_demas:=self.estados_demas+1;
      end else r.pc.w:=r.pc.w+1;
  $ff:if (r.acc.l=0) then begin  //bz
          r.pc.w:=self.rom[r.pc.w];
          self.estados_demas:=self.estados_demas+1;
      end else r.pc.w:=r.pc.w+1;
  else MessageDlg('Intruccion desconocida DSP '+inttohex(r.pc.w-1,10), mtInformation,[mbOk], 0);
end; //del case
self.contador:=self.contador+ciclos_tms[instruccion.h]+self.estados_demas;
end; //del while!
end;

end.
