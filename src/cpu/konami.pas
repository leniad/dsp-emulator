unit konami;
interface
uses main_engine,dialogs,sysutils,cpu_misc;

type
        band_konami=record
                e,f,h,i,n,z,v,c:boolean;
        end;
        pband_konami=^band_konami;
        reg_konami=record
                d:parejas680X;
                old_pc,pc,u,s,x,y:word;
                dp:byte;
                cc:band_konami;
                cwai,pila_init:boolean;
        end;
        preg_konami=^reg_konami;

        tset_lines=procedure (valor:byte);
        cpu_konami=class(cpu_class)
          public
            constructor create(clock:dword);
            destructor free;
            procedure change_firq(estado:byte);
            procedure change_nmi(estado:byte);
            procedure reset;
            procedure run(maximo:single);
            procedure change_set_lines(tset_lines_call:tset_lines);
            function save_snapshot(data:pbyte):word;
            procedure load_snapshot(data:pbyte);
          private
            r:preg_konami;
            ciclos_extra:integer;
            clock_remainder,prefetch_opcode,indexed_postbyte:byte;
            prefetch_valid:boolean;
            set_lines_call:tset_lines;
            dp_exgtfr_low:byte;
            procedure consume_cycles(cycles:integer);
            function call_nmi:byte;
            procedure putword(direccion:word;valor:word);
            function getword(direccion:word):word;
            procedure push_s(reg:byte);
            function pop_s:byte;
            procedure push_sw(reg:word);
            function pop_sw:word;
            procedure push_u(reg:byte);
            function pop_u:byte;
            procedure push_uw(reg:word);
            function pop_uw:word;
            function dame_pila:byte;
            procedure pon_pila(valor:byte);
            //Llamadas IRQ
            function call_irq:byte;
            function call_firq:byte;
            //Misc Func
            function get_indexed:word;
            function read_trf_reg(codigo:byte):word;
            procedure write_trf_reg(codigo:byte;valor:word);
            procedure trf(valor:byte);
            procedure trf_ex(valor:byte);
        end;

var
  konami_0:cpu_konami;

implementation
uses timer_engine;

const
  // Small population-count table for PSH/PUL masks.
  konami_bit_count:array[0..15] of byte=(0,1,1,2,1,2,2,3,1,2,2,3,2,3,3,4);

    paginacion:array[0..255] of byte=(
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
       $f,$f,$f,$f,$f,$f,$f,$f, 4, 4, 4, 4, 2, 2, 2, 2,  //00
        2, 2, 6, 6, 2, 2, 6, 6, 2, 2, 6, 6, 2, 2, 6, 6,  //10
        2, 2, 6, 6, 2, 2, 6, 6, 2, 2, 6, 6, 2, 2, 6, 6,  //20
        2, 2, 6, 6, 2, 2, 6, 6, 2, 6, 4, 4, 2, 2, 2, 2,  //30
        3, 9, 3, 9, 3, 9, 3, 9, 3, 9, 3, 9, 3, 9, 3, 9,  //40
        3, 9, 3, 9, 3, 9, 3, 9, 4, 4, 4, 4, 4,$f,$f,$f,  //50
        2, 2, 2, 2,$f, 2, 2, 2, 3, 3, 3, 3,$f, 3, 3, 3,  //60
        2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3,$f, 3, 3, 3,  //70
        0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0,  //80
        0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0,  //90
        0, 0, 4, 4,$f, 4, 4,$f, 4, 4, 2, 3, 2, 2, 0,$f,  //a0
        0, 0, 0, 0, 0, 0, 0,$f, 2,$f,$f,$f, 2,$f, 2,$f,  //b0
       $f,$f, 0, 4, 0, 4, 4, 4,$f, 4, 0, 4, 0, 0, 0, 0,  //c0
        0,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,  //d0
       $f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,  //e0
       $f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f); //f0

constructor cpu_konami.create(clock:dword);
begin
  getmem(self.r,sizeof(reg_konami));
  fillchar(self.r^,sizeof(reg_konami),0);
  self.dp_exgtfr_low:=0;
  self.clock_remainder:=0;
  self.prefetch_opcode:=0;
  self.prefetch_valid:=false;
  clock:=clock div 4;
  self.numero_cpu:=cpu_main_init(clock);
  self.clock:=clock;
  self.tframes:=(clock/llamadas_maquina.scanlines)/llamadas_maquina.fps_max;
end;

procedure cpu_konami.reset;
begin
self.opcode:=false;
r.pc:=self.getword($fffe);
r.dp:=0;
self.contador:=0;
self.pon_pila($50);
self.pedir_nmi:=CLEAR_LINE;
self.nmi_state:=CLEAR_LINE;
self.change_irq(CLEAR_LINE);
self.change_firq(CLEAR_LINE);
r.cwai:=false;
r.pila_init:=false;
  self.dp_exgtfr_low:=0;
  self.clock_remainder:=0;
  self.prefetch_opcode:=0;
  self.prefetch_valid:=false;
end;

function cpu_konami.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
begin
  temp:=data;
  temp^:=self.pedir_nmi;inc(temp);
  temp^:=self.pedir_firq;inc(temp);
  temp^:=self.pedir_irq;inc(temp);
  temp^:=self.nmi_state;inc(temp);
  CopyMemory(temp,self.r,SizeOf(reg_konami));
  inc(temp,SizeOf(reg_konami));
  temp^:=self.dp_exgtfr_low;inc(temp);
  temp^:=self.clock_remainder;inc(temp);
  temp^:=self.prefetch_opcode;inc(temp);
  temp^:=byte(self.prefetch_valid);
  save_snapshot:=4+SizeOf(reg_konami)+4;
end;

procedure cpu_konami.load_snapshot(data:pbyte);
var
  temp:pbyte;
begin
  temp:=data;
  self.pedir_nmi:=temp^;inc(temp);
  self.pedir_firq:=temp^;inc(temp);
  self.pedir_irq:=temp^;inc(temp);
  self.nmi_state:=temp^;inc(temp);
  CopyMemory(self.r,temp,SizeOf(reg_konami));
  inc(temp,SizeOf(reg_konami));
  self.dp_exgtfr_low:=temp^;inc(temp);
  self.clock_remainder:=temp^ and 3;inc(temp);
  self.prefetch_opcode:=temp^;inc(temp);
  self.prefetch_valid:=temp^<>0;
end;

destructor cpu_konami.free;
begin
freemem(self.r);
end;

procedure cpu_konami.change_firq(estado:byte);
begin
  self.pedir_firq:=estado;
end;

procedure cpu_konami.putword(direccion:word;valor:word);
begin
self.putbyte(direccion,valor shr 8);
self.putbyte(word((integer(direccion)+1) and $ffff),valor and $FF);
end;

function cpu_konami.getword(direccion:word):word;
var
  valor:word;
begin
valor:=self.getbyte(direccion) shl 8;
getword:=valor+(self.getbyte(word((integer(direccion)+1) and $ffff)));
end;

function cpu_konami.dame_pila:byte;
var
  temp:byte;
begin
  temp:=byte(r.cc.e) shl 7;
  temp:=temp or (byte(r.cc.f) shl 6);
  temp:=temp or (byte(r.cc.h) shl 5);
  temp:=temp or (byte(r.cc.i) shl 4);
  temp:=temp or (byte(r.cc.n) shl 3);
  temp:=temp or (byte(r.cc.z) shl 2);
  temp:=temp or (byte(r.cc.v) shl 1);
  dame_pila:=temp or byte(r.cc.c);
end;

procedure cpu_konami.pon_pila(valor:byte);
begin
  r.cc.e:=(valor and $80)<>0;
  r.cc.f:=(valor and $40)<>0;
  r.cc.h:=(valor and $20)<>0;
  r.cc.i:=(valor and $10)<>0;
  r.cc.n:=(valor and 8)<>0;
  r.cc.z:=(valor and 4)<>0;
  r.cc.v:=(valor and 2)<>0;
  r.cc.c:=(valor and 1)<>0;
end;

procedure cpu_konami.push_s(reg:byte);
begin
r.s:=r.s-1;
self.putbyte(r.s,reg);
end;

function cpu_konami.pop_s:byte;
begin
pop_s:=self.getbyte(r.s);
r.s:=r.s+1;
end;

procedure cpu_konami.push_sw(reg:word);
begin
r.s:=r.s-2;
self.putbyte(word((integer(r.s)+1) and $ffff),reg and $ff);
self.putbyte(r.s,(reg shr 8));
end;

function cpu_konami.pop_sw:word;
var
  temp:word;
begin
temp:=self.getbyte(r.s) shl 8;
temp:=temp or self.getbyte(word((integer(r.s)+1) and $ffff));
r.s:=r.s+2;
pop_sw:=temp;
end;

procedure cpu_konami.push_u(reg:byte);
begin
r.u:=r.u-1;
self.putbyte(r.u,reg);
end;

function cpu_konami.pop_u:byte;
begin
pop_u:=self.getbyte(r.u);
r.u:=r.u+1;
end;

procedure cpu_konami.push_uw(reg:word);
begin
r.u:=r.u-2;
self.putbyte(word((integer(r.u)+1) and $ffff),reg and $ff);
self.putbyte(r.u,(reg shr 8));
end;

function cpu_konami.pop_uw:word;
var
  temp:word;
begin
temp:=self.getbyte(r.u) shl 8;
temp:=temp or self.getbyte(word((integer(r.u)+1) and $ffff));
r.u:=r.u+2;
pop_uw:=temp;
end;

procedure cpu_konami.consume_cycles(cycles:integer);
var chunk:word;
begin
  self.contador:=self.contador+cycles;
  while cycles>0 do begin
    if cycles>32 then chunk:=32 else chunk:=cycles;
    timers.update(chunk,self.numero_cpu);
    dec(cycles,chunk);
  end;
end;

procedure cpu_konami.change_nmi(estado:byte);
begin
  if estado=CLEAR_LINE then self.nmi_state:=CLEAR_LINE
  else begin
    if (self.nmi_state=CLEAR_LINE) and r.pila_init then
      self.pedir_nmi:=estado;
    self.nmi_state:=estado;
  end;
end;

function cpu_konami.call_nmi:byte;
begin
  self.push_sw(r.pc); self.push_sw(r.u); self.push_sw(r.y);
  self.push_sw(r.x); self.push_s(r.dp); self.push_s(r.d.b);
  self.push_s(r.d.a); r.cc.e:=true; self.push_s(self.dame_pila);
  r.cc.f:=true; r.cc.i:=true;
  r.pc:=self.getword($fffc);
  if self.pedir_nmi<>ASSERT_LINE then self.nmi_state:=CLEAR_LINE;
  self.pedir_nmi:=CLEAR_LINE;
  call_nmi:=19;
end;

procedure cpu_konami.change_set_lines(tset_lines_call:tset_lines);
begin
  self.set_lines_call:=tset_lines_call;
end;

function cpu_konami.call_irq:byte;
begin
self.push_sw(r.pc);
self.push_sw(r.u);
self.push_sw(r.y);
self.push_sw(r.x);
self.push_s(r.dp);
self.push_s(r.d.b);
self.push_s(r.d.a);
r.cc.e:=true;
self.push_s(self.dame_pila);
call_irq:=19;
r.pc:=self.getword($fff8);
r.cc.i:=true;
if self.pedir_irq=HOLD_LINE then self.pedir_irq:=CLEAR_LINE;
end;

function cpu_konami.call_firq:byte;
begin
r.cc.e:=false;
self.push_sw(r.pc);
self.push_s(self.dame_pila);
call_firq:=10;
r.cc.f:=true;
r.cc.i:=true;
r.pc:=self.getword($fff6);
if self.pedir_firq=HOLD_LINE then self.pedir_firq:=CLEAR_LINE;
end;

function cpu_konami.read_trf_reg(codigo:byte):word;
begin
  case (codigo and 7) of
    $0:read_trf_reg:=$1000 or r.d.a; //A (bit alto fijo al leerlo como palabra)
    $1:read_trf_reg:=r.d.w; //D
    $2:read_trf_reg:=r.x; //X
    $3:read_trf_reg:=r.y; //Y
    $4:read_trf_reg:=(word(r.dp) shl 8) or self.dp_exgtfr_low; //DP extendido
    $5:read_trf_reg:=r.u; //U
    $6:read_trf_reg:=r.s; //S
    $7:read_trf_reg:=r.pc; //PC
  else
    read_trf_reg:=0;
  end;
end;

procedure cpu_konami.write_trf_reg(codigo:byte;valor:word);
begin
  case (codigo and 7) of
    $0:r.d.a:=byte(valor); //A toma el byte bajo
    $1:r.d.b:=byte(valor); //D al leer; B al escribir
    $2:r.x:=valor; //X
    $3:r.y:=valor; //Y
    $4:begin //DP extendido
         r.dp:=byte(valor shr 8);
         self.dp_exgtfr_low:=byte(valor);
       end;
    $5:r.u:=valor; //U
    $6:r.s:=valor; //S
    $7:r.pc:=valor; //PC
  end;
end;

procedure cpu_konami.trf(valor:byte);
var
  codigo_origen,codigo_destino:byte;
  valor_origen:word;
begin
  codigo_origen:=valor and 7;
  codigo_destino:=(valor shr 4) and 7;
  valor_origen:=self.read_trf_reg(codigo_origen);
  self.write_trf_reg(codigo_destino,valor_origen);
end;

procedure cpu_konami.trf_ex(valor:byte);
var
  codigo_origen,codigo_destino:byte;
  valor_origen,valor_destino:word;
  exchange_pc_x:boolean;
  old_opcode:byte;
begin
  codigo_origen:=valor and 7;
  codigo_destino:=(valor shr 4) and 7;
  valor_origen:=self.read_trf_reg(codigo_origen);
  exchange_pc_x:=((codigo_origen=7) and (codigo_destino=2)) or
                 ((codigo_origen=2) and (codigo_destino=7));
  old_opcode:=0;
  if exchange_pc_x then begin
    self.opcode:=true;
    old_opcode:=self.getbyte(r.pc);
    self.opcode:=false;
  end;
  valor_destino:=self.read_trf_reg(codigo_destino);
  self.write_trf_reg(codigo_origen,valor_destino);
  self.write_trf_reg(codigo_destino,valor_origen);
  if exchange_pc_x then begin
    self.prefetch_opcode:=old_opcode;
    self.prefetch_valid:=true;
  end;
end;

function cpu_konami.get_indexed:word;
var
  iindexed,temp:byte;
  origen:pword;
  direccion,temp2:word;
begin
iindexed:=self.getbyte(r.pc);
self.indexed_postbyte:=iindexed; //Hay que añadir 1 estado por cojer un byte...
r.pc:=r.pc+1;
case (iindexed and $70) of
  $20:origen:=@r.x;
  $30:origen:=@r.y;
  $50:origen:=@r.u;
  $60:origen:=@r.s;
  $70:origen:=@r.pc;
end;
direccion:=$ffff;
case (iindexed and $f7) of
      7:begin // =
          direccion:=self.getword(r.pc);
          r.pc:=r.pc+2;
          self.ciclos_extra:=self.ciclos_extra+1+2;
        end;
      $20,$30,$50,$60,$70:begin  //reg+
          direccion:=origen^;
          origen^:=origen^+1;
          self.ciclos_extra:=self.ciclos_extra+1+2;
      end;
      $21,$31,$51,$61,$71:begin  //reg++
          direccion:=origen^;
          origen^:=origen^+2;
          self.ciclos_extra:=self.ciclos_extra+1+3;
      end;
      $22,$32,$52,$62,$72:begin  //-reg
          origen^:=origen^-1;
          direccion:=origen^;
          self.ciclos_extra:=self.ciclos_extra+1+3;
      end;
      $23,$33,$53,$63,$73:begin //--reg
          origen^:=origen^-2;
          direccion:=origen^;
          self.ciclos_extra:=self.ciclos_extra+1+3;
      end;
      $24,$34,$54,$64,$74:begin  //reg + deplazamiento 8bits
          direccion:=origen^;
          temp:=self.getbyte(r.pc);
          r.pc:=r.pc+1;
          direccion:=direccion+shortint(temp);
          self.ciclos_extra:=self.ciclos_extra+1+2;
      end;
      $25,$35,$55,$65,$75:begin  //reg + deplazamiento 16bits
          direccion:=origen^;
          temp2:=self.getword(r.pc);
          r.pc:=r.pc+2;
          direccion:=direccion+smallint(temp2);
          self.ciclos_extra:=self.ciclos_extra+5+1;
      end;
      $26,$36,$56,$66,$76:begin // =
          direccion:=origen^;
          self.ciclos_extra:=self.ciclos_extra+1;
        end;
      $c4:begin
          direccion:=(self.r.dp shl 8)+self.getbyte(r.pc);
          r.pc:=r.pc+1;
          self.ciclos_extra:=self.ciclos_extra+1+1;
      end;
      $a0,$b0,$d0,$e0,$f0:begin // reg + r.d.a
          direccion:=origen^+shortint(r.d.a);
          self.ciclos_extra:=self.ciclos_extra+1+1;
        end;

      $a1,$b1,$d1,$e1,$f1:begin //reg + r.d.b
          direccion:=origen^+shortint(r.d.b);
          self.ciclos_extra:=self.ciclos_extra+1+1;
        end;
      $a7,$b7,$d7,$e7,$f7:begin //reg + r.d.w
          direccion:=origen^+smallint(r.d.w);
          self.ciclos_extra:=self.ciclos_extra+1+4;
         end;
      $a2,$b2,$d2,$e2,$f2:begin //reg + r.x
          direccion:=origen^+smallint(r.x);
          self.ciclos_extra:=self.ciclos_extra+1+4;
         end;
      $a3,$b3,$d3,$e3,$f3:begin //reg + r.y
          direccion:=origen^+smallint(r.y);
          self.ciclos_extra:=self.ciclos_extra+1+4;
         end;
      $a5,$b5,$d5,$e5,$f5:begin //reg + r.u
          direccion:=origen^+smallint(r.u);
          self.ciclos_extra:=self.ciclos_extra+1+4;
         end;
      $a6,$b6,$d6,$e6,$f6:begin //reg + r.s
          direccion:=origen^+smallint(r.s);
          self.ciclos_extra:=self.ciclos_extra+1+4;
         end;
      else  MessageDlg('Indexed desconocido. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
end;
if (iindexed and $8)<>0 then begin
     direccion:=self.getword(direccion);
     self.ciclos_extra:=self.ciclos_extra+2;
end;
get_indexed:=direccion;
end;

function konami_sshr(num:integer;fac:byte):integer;
begin
  if num>=0 then konami_sshr:=num shr fac
  else konami_sshr:=not ((not num) shr fac);
end;

function konami_neg(valor:byte;cc:pband_konami):byte;
var
  tempw:word;
begin
tempw:=-valor;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
cc.c:=(tempw and $100)<>0;
cc.v:=((0 xor valor xor tempw xor (tempw shr 1)) and $80)<>0;
konami_neg:=tempw;
end;

function konami_com(valor:byte;cc:pband_konami):byte;
var
  temp:byte;
begin
temp:=not(valor);
cc.v:=false;
cc.c:=true;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
konami_com:=temp;
end;

function konami_lsr(valor:byte;cc:pband_konami):byte;
var
  temp:byte;
begin
temp:=valor shr 1;
cc.z:=(temp=0);
cc.n:=false;
cc.c:=(valor and $1)<>0;
konami_lsr:=temp;
end;

function konami_ror(valor:byte;cc:pband_konami):byte;
var
  temp:byte;
begin
temp:=(valor shr 1) or (byte(cc.c) shl 7);
cc.c:=(valor and $1)<>0;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
konami_ror:=temp;
end;

function konami_asr(valor:byte;cc:pband_konami):byte;
var
  temp:byte;
begin
temp:=(valor and $80) or (valor shr 1);
cc.c:=(valor and $1)<>0;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
konami_asr:=temp;
end;

function konami_asl(valor:byte;cc:pband_konami):byte;
var
  tempw:word;
begin
tempw:=valor shl 1;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
cc.c:=(tempw and $100)<>0;
cc.v:=((valor xor valor xor tempw xor (tempw shr 1)) and $80)<>0;
konami_asl:=tempw;
end;

function konami_rol(valor:byte;cc:pband_konami):byte;
var old_carry:boolean; value:byte;
begin
  old_carry:=cc.c;
  value:=byte(((integer(valor) shl 1) or byte(old_carry)) and $ff);
  cc.c:=(valor and $80)<>0;
  if not old_carry then cc.z:=value=0;
  konami_rol:=value;
end;

function konami_dec(valor:byte;cc:pband_konami):byte;
var
  tempw:word;
begin
tempw:=valor-1;
cc.z:=((tempw and $ff)=0);
cc.n:=(tempw and $80)<>0;
cc.v:=((valor xor 1 xor tempw xor (tempw shr 1)) and $80)<>0;
konami_dec:=tempw;
end;

function konami_inc(valor:byte;cc:pband_konami):byte;
var
  tempw:word;
begin
tempw:=valor+1;
cc.z:=((tempw and $ff)=0);
cc.n:=(tempw and $80)<>0;
cc.v:=((valor xor 1 xor tempw xor (tempw shr 1)) and $80)<>0;
konami_inc:=tempw;
end;

procedure konami_tst(valor:byte;cc:pband_konami);
begin
cc.v:=((0 xor valor xor valor xor (valor shr 1)) and $80)<>0;
cc.n:=(valor and $80)<>0;
cc.z:=(valor=0);
end;

function konami_sub8(sub1,sub2:byte;cc:pband_konami):byte;
var
  tempw:word;
begin
tempw:=sub1-sub2;
cc.c:=(tempw and $100)<>0;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
cc.v:=(((sub1 xor sub2 xor tempw xor (tempw shr 1)) and $80))<>0;
konami_sub8:=tempw;
end;

function konami_sub16(sub1,sub2:word;cc:pband_konami):word;
var
  templ:dword;
begin
templ:=sub1-sub2;
cc.c:=(templ and $10000)<>0;
cc.n:=(templ and $8000)<>0;
cc.z:=(templ and $ffff)=0;
cc.v:=((sub1 xor sub2 xor templ xor (templ shr 1)) and $8000)<>0;
konami_sub16:=templ;
end;

function konami_sbc(sub1,sub2:byte;cc:pband_konami):byte;
var
  tempw:word;
begin
tempw:=sub1-sub2-byte(cc.c);
cc.c:=(tempw and $100)<>0;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
cc.v:=(((sub1 xor sub2 xor tempw xor (tempw shr 1)) and $80))<>0;
konami_sbc:=tempw;
end;

function konami_and(valor1,valor2:byte;cc:pband_konami):byte;
var
  temp:byte;
begin
temp:=valor1 and valor2;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
cc.v:=false;
konami_and:=temp;
end;

function konami_eor(valor1,valor2:byte;cc:pband_konami):byte;
var
  temp:byte;
begin
temp:=valor1 xor valor2;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
cc.v:=false;
konami_eor:=temp;
end;

function konami_adc(valor1,valor2:byte;cc:pband_konami):byte;
var
  tempw:word;
begin
tempw:=valor1+valor2+byte(cc.c);
cc.c:=(tempw and $100)<>0;
cc.h:=((valor1 xor valor2 xor tempw) and $10)<>0;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
cc.v:=((valor1 xor valor2 xor tempw xor (tempw shr 1)) and $80)<>0;
konami_adc:=tempw;
end;

function konami_or(valor1,valor2:byte;cc:pband_konami):byte;
var
  temp:byte;
begin
temp:=valor1 or valor2;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
cc.v:=false;
konami_or:=temp;
end;

function konami_add8(valor1,valor2:byte;cc:pband_konami):byte;
var
  tempw:word;
begin
tempw:=valor1+valor2;
cc.c:=(tempw and $100)<>0;
cc.h:=((valor1 xor valor2 xor tempw) and $10)<>0;
cc.n:=(tempw and $80)<>0;
cc.z:=((tempw and $ff)=0);
cc.v:=(((valor1 xor valor2 xor tempw xor (tempw shr 1)) and $80))<>0;
konami_add8:=tempw;
end;

function konami_add16(add1,add2:word;cc:pband_konami):word;
var
  templ:dword;
begin
templ:=add1+add2;
cc.c:=(templ and $10000)<>0;
cc.n:=(templ and $8000)<>0;
cc.z:=((templ and $ffff)=0);
cc.v:=((add1 xor add2 xor templ xor (templ shr 1)) and $8000)<>0;
konami_add16:=templ;
end;

function konami_ld_st8(valor:byte;cc:pband_konami):byte;
begin
cc.n:=(valor and $80)<>0;
cc.z:=(valor=0);
cc.v:=((0 xor valor xor valor xor (valor shr 1)) and $80)<>0;
konami_ld_st8:=valor;
end;

function konami_ld_st16(valor:word;cc:pband_konami):word;
begin
cc.n:=(valor and $8000)<>0;
cc.z:=(valor=0);
cc.v:=((0 xor valor xor valor xor (valor shr 1)) and $8000)<>0;
konami_ld_st16:=valor;
end;

function konami_neg16(valor:word;cc:pband_konami):word;
var
  templ:dword;
begin
templ:=-valor;
cc.n:=(templ and $8000)<>0;
cc.z:=(templ and $ffff)=0;
cc.c:=(templ and $10000)<>0;
cc.v:=((0 xor valor xor templ xor (templ shr 1)) and $8000)<>0;
konami_neg16:=templ;
end;

function konami_inc16(valor:word;cc:pband_konami):word;
var
  templ:dword;
begin
templ:=valor+1;
cc.c:=(templ and $10000)<>0;
cc.z:=((templ and $ffff)=0);
cc.n:=(templ and $8000)<>0;
cc.v:=((valor xor 1 xor templ xor (templ shr 1)) and $8000)<>0;
konami_inc16:=templ;
end;

function konami_dec16(valor:word;cc:pband_konami):word;
var
  templ:dword;
begin
templ:=valor-1;
cc.c:=(templ and $10000)<>0;
cc.z:=((templ and $ffff)=0);
cc.n:=(templ and $8000)<>0;
cc.v:=((valor xor 1 xor templ xor (templ shr 1)) and $8000)<>0;
konami_dec16:=templ;
end;

function konami_lsrd(valor:word;numero:byte;cc:pband_konami):word;
var tempw:word; i:integer;
begin
  tempw:=valor;
  for i:=1 to (numero and $0f) do tempw:=tempw shr 1;
  cc.n:=(tempw and $8000)<>0;
  cc.z:=tempw=0; cc.v:=false; cc.c:=false;
  konami_lsrd:=tempw;
end;

function konami_asld(valor:word;numero:byte;cc:pband_konami):word;
var tempw:word; i:integer;
begin
  tempw:=valor;
  for i:=1 to (numero and $0f) do tempw:=(integer(tempw) shl 1) and $ffff;
  cc.n:=(tempw and $8000)<>0;
  cc.z:=tempw=0; cc.v:=false; cc.c:=false;
  konami_asld:=tempw;
end;

function konami_lsr16(valor:word;cc:pband_konami):word;
var
   tempw:word;
begin
tempw:=valor shr 1;
cc.n:=false;
cc.z:=(tempw=0);
cc.c:=(valor and 1)<>0;
konami_lsr16:=tempw;
end;

function konami_asl16(valor:word;cc:pband_konami):word;
var
  templ:dword;
begin
templ:=valor shl 1;
cc.n:=(templ and $8000)<>0;
cc.z:=(templ and $ffff)=0;
cc.c:=(templ and $10000)<>0;
cc.v:=((valor xor valor xor templ xor (templ shr 1)) and $8000)<>0;
konami_asl16:=templ;
end;

function konami_asr16(valor:word;cc:pband_konami):word;
var
  tempw:word;
begin
tempw:=(valor shr 1) or (valor and $8000);
cc.n:=(tempw and $8000)<>0;
cc.z:=(tempw=0);
cc.c:=(valor and $1)<>0;
konami_asr16:=tempw;
end;

function konami_abs16(valor:word;cc:pband_konami):word;
var value:word;
begin
  cc.c:=(valor and $8000)<>0;
  cc.v:=valor=$8000;
  if cc.c then value:=(-integer(valor)) and $ffff else value:=valor;
  cc.n:=(value and $8000)<>0; cc.z:=value=0;
  konami_abs16:=value;
end;

function konami_abs8(valor:byte;cc:pband_konami):byte;
var value:byte;
begin
  cc.c:=(valor and $80)<>0;
  cc.v:=valor=$80;
  if cc.c then value:=(-integer(valor)) and $ff else value:=valor;
  cc.n:=(value and $80)<>0; cc.z:=value=0;
  konami_abs8:=value;
end;

function konami_asrd(valor:word;numero:byte;cc:pband_konami):word;
var tempw:word; i:integer;
begin
  tempw:=valor;
  for i:=1 to (numero and $0f) do tempw:=(tempw shr 1) or (tempw and $8000);
  cc.n:=(tempw and $8000)<>0;
  cc.z:=tempw=0; cc.v:=false; cc.c:=false;
  konami_asrd:=tempw;
end;

procedure cpu_konami.run(maximo:single);
var
  tempb,instruccion,numero:byte;
  tempw,posicion:word;
  cycles:integer;
  templ:dword;
  low_correction,high_correction:byte;
  old_carry,carry_out:boolean;
begin
self.contador:=0;
while self.contador<maximo do begin
if self.pedir_reset<>CLEAR_LINE then begin
  tempb:=self.pedir_reset;
  self.reset;
  if tempb=ASSERT_LINE then self.pedir_reset:=ASSERT_LINE;
  self.contador:=trunc(maximo);
  exit;
end;
self.r.old_pc:=self.r.pc;
self.ciclos_extra:=0;
if (self.pedir_nmi<>CLEAR_LINE) and r.pila_init then self.ciclos_extra:=self.call_nmi
else if ((self.pedir_firq<>CLEAR_LINE) and not(r.cc.f)) then self.ciclos_extra:=self.call_firq
       else if ((self.pedir_irq<>CLEAR_LINE) and not(r.cc.i)) then self.ciclos_extra:=self.call_irq;
if self.ciclos_extra<>0 then begin
  self.consume_cycles(self.ciclos_extra);
  continue;
end;
self.opcode:=true;
if self.prefetch_valid then begin
  instruccion:=self.prefetch_opcode;
  self.prefetch_valid:=false;
end else instruccion:=self.getbyte(r.pc);
r.pc:=r.pc+1;
self.opcode:=false;
self.indexed_postbyte:=0;
case paginacion[instruccion] of
     0:; //implicito 0T
     2:begin  //inmediato byte
        numero:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
      end;
     3:begin  //EXTENDED 3T
         posicion:=self.getword(r.pc);
         r.pc:=r.pc+2;
      end;
     4:posicion:=self.get_indexed; //INDEXED Los estados T son variables
     6:numero:=self.getbyte(get_indexed); //indexado indirecto byte
     9:posicion:=self.getword(get_indexed); //indexado indirecto word
     $f:MessageDlg('Konami CPU '+inttostr(self.numero_cpu)+' instruccion: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(r.pc,10)+' OLD_PC='+inttohex(self.r.old_pc,10), mtInformation,[mbOk], 0)
end; //del case!!
cycles:=0;
case instruccion of
     $08:begin
       if self.indexed_postbyte=$07 then cycles:=20
       else cycles:=4*(2+self.ciclos_extra);
       //leax
            r.x:=posicion;
            r.cc.z:=(r.x=0); 
     end;
     $09:begin
       if self.indexed_postbyte=$07 then cycles:=20
       else cycles:=4*(2+self.ciclos_extra);
       //leay
            r.y:=posicion;
            r.cc.z:=(r.y=0); 
     end;
     $0a:begin
       if self.indexed_postbyte=$07 then cycles:=20
       else cycles:=4*(2+self.ciclos_extra);
       r.u:=posicion; //leau
     end;
     $0b:begin
       if self.indexed_postbyte=$07 then cycles:=20
       else cycles:=4*(2+self.ciclos_extra);
       r.s:=posicion; r.pila_init:=true;  //leas
     end;
     $0c:begin
       cycles:=21+3*konami_bit_count[numero and 15]+7*konami_bit_count[numero shr 4];
       //pshs
            if (numero and $80)<>0 then begin
              self.push_sw(r.pc);
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $40)<>0 then begin
              self.push_sw(r.u);
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $20)<>0 then begin
              self.push_sw(r.y);
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $10)<>0 then begin
              self.push_sw(r.x);
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $8)<>0 then begin
              self.push_s(r.dp);
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $4)<>0 then begin
              self.push_s(r.d.b);
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $2)<>0 then begin
              self.push_s(r.d.a);
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $1)<>0 then begin
              self.push_s(self.dame_pila);
              self.ciclos_extra:=self.ciclos_extra+1;
            end; 
     end;
     $0d:begin
       cycles:=21+3*konami_bit_count[numero and 15]+7*konami_bit_count[numero shr 4];
       //pshu
            if (numero and $80)<>0 then begin
              self.push_uw(r.pc);
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $40)<>0 then begin
              self.push_uw(r.s);
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $20)<>0 then begin
              self.push_uw(r.y);
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $10)<>0 then begin
              self.push_uw(r.x);
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $8)<>0 then begin
              self.push_u(r.dp);
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $4)<>0 then begin
              self.push_u(r.d.b);
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $2)<>0 then begin
              self.push_u(r.d.a);
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $1)<>0 then begin
              self.push_u(self.dame_pila);
              self.ciclos_extra:=self.ciclos_extra+1;
            end; 
     end;
     $0e:begin
       cycles:=20+4*konami_bit_count[numero and 15]+8*konami_bit_count[(numero shr 4) and 7]+7*((numero shr 7) and 1);
       //puls
            if (numero and $1)<>0 then begin
              self.pon_pila(self.pop_s);
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $2)<>0 then begin
              r.d.a:=self.pop_s;
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $4)<>0 then begin
              r.d.b:=self.pop_s;
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $8)<>0 then begin
              r.dp:=self.pop_s;
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $10)<>0 then begin
              r.x:=self.pop_sw;
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $20)<>0 then begin
              r.y:=self.pop_sw;
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $40)<>0 then begin
              r.u:=self.pop_sw;
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $80)<>0 then begin
              r.pc:=self.pop_sw;
              self.ciclos_extra:=self.ciclos_extra+2;
            end; 
     end;
     $0f:begin
       cycles:=20+4*konami_bit_count[numero and 15]+8*konami_bit_count[(numero shr 4) and 7]+7*((numero shr 7) and 1);
       //pulu
            if (numero and $1)<>0 then begin
              self.pon_pila(self.pop_u);
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $2)<>0 then begin
              r.d.a:=self.pop_u;
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $4)<>0 then begin
              r.d.b:=self.pop_u;
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $8)<>0 then begin
              r.dp:=self.pop_u;
              self.ciclos_extra:=self.ciclos_extra+1;
            end;
            if (numero and $10)<>0 then begin
              r.x:=self.pop_uw;
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $20)<>0 then begin
              r.y:=self.pop_uw;
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $40)<>0 then begin
              r.s:=self.pop_uw;
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
            if (numero and $80)<>0 then begin
              r.pc:=self.pop_uw;
              self.ciclos_extra:=self.ciclos_extra+2;
            end;
     end;
     $10,$12:begin
       if instruccion=$10 then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.a:=konami_ld_st8(numero,@r.cc);  //lda
     end;
     $11,$13:begin
       if instruccion=$11 then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.b:=konami_ld_st8(numero,@r.cc);  //ldb
     end;
     $14,$16:begin
       if instruccion=$14 then begin
         cycles:=8;
       end else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.a:=konami_add8(r.d.a,numero,@r.cc);  //adda
     end;
     $15,$17:begin
       if instruccion=$15 then begin
         cycles:=8;
       end else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.b:=konami_add8(r.d.b,numero,@r.cc);  //addb
     end;
     $18,$1a:begin
       if instruccion=$18 then begin
         cycles:=8;
       end else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.a:=konami_adc(r.d.a,numero,@r.cc);  //adca
     end;
     $19,$1b:begin
       if instruccion=$19 then begin
         cycles:=8;
       end else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.b:=konami_adc(r.d.b,numero,@r.cc);  //adcb
     end;
     $1c,$1e:begin
       if instruccion=$1c then begin
         cycles:=8;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.a:=konami_sub8(r.d.a,numero,@r.cc);  //suba
     end;
     $1d,$1f:begin
       if instruccion=$1d then begin
         cycles:=8;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.b:=konami_sub8(r.d.b,numero,@r.cc);  //subb
     end;
     $20,$22:begin
       if instruccion=$20 then begin
         cycles:=8;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.a:=konami_sbc(r.d.a,numero,@r.cc);  //sbca
     end;
     $21,$23:begin
       if instruccion=$21 then begin
         cycles:=8;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.b:=konami_sbc(r.d.b,numero,@r.cc);  //sbcb
     end;
     $24,$26:begin
       if instruccion=$24 then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=22
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.a:=konami_and(r.d.a,numero,@r.cc);  //anda
     end;
     $25,$27:begin
       if instruccion=$25 then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=22
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.b:=konami_and(r.d.b,numero,@r.cc);  //andb
     end;
     $28,$2a:begin
       if instruccion=$28 then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=22
         else cycles:=4*(2+self.ciclos_extra);
       end;
       konami_and(r.d.a,numero,@r.cc);  //bita
     end;
     $29,$2b:begin
       if instruccion=$29 then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=22
         else cycles:=4*(2+self.ciclos_extra);
       end;
       konami_and(r.d.b,numero,@r.cc);  //bitb
     end;
     $2c,$2e:begin
       if instruccion=$2c then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=22
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.a:=konami_eor(r.d.a,numero,@r.cc);  //eora
     end;
     $2d,$2f:begin
       if instruccion=$2d then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=22
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.b:=konami_eor(r.d.b,numero,@r.cc);  //eorb
     end;
     $30,$32:begin
       if instruccion=$30 then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=22
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.a:=konami_or(r.d.a,numero,@r.cc);  //ora
     end;
     $31,$33:begin
       if instruccion=$31 then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=22
         else cycles:=4*(2+self.ciclos_extra);
       end;
       r.d.b:=konami_or(r.d.b,numero,@r.cc);  //orb
     end;
     $34,$36:begin
       if instruccion=$34 then begin
         cycles:=8;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       konami_sub8(r.d.a,numero,@r.cc);  //cmpa
     end;
     $35,$37:begin
       if instruccion=$35 then begin
         cycles:=8;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=21
         else cycles:=4*(2+self.ciclos_extra);
       end;
       konami_sub8(r.d.b,numero,@r.cc);  //cmpb
     end;
     $38,$39:begin
       if instruccion=$38 then begin
         cycles:=9;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=22
         else cycles:=4*(2+self.ciclos_extra);
       end;
       if @self.set_lines_call<>nil then self.set_lines_call(numero);
     end;
     $3a:begin
       if self.indexed_postbyte=$07 then cycles:=22
       else cycles:=4*(2+self.ciclos_extra);
       self.putbyte(posicion,konami_ld_st8(r.d.a,@r.cc));  //sta
     end;
     $3b:begin
       if self.indexed_postbyte=$07 then cycles:=22
       else cycles:=4*(2+self.ciclos_extra);
       self.putbyte(posicion,konami_ld_st8(r.d.b,@r.cc));  //stb
     end;
     $3c:begin
       cycles:=9;
       //andcc
            tempb:=self.dame_pila and numero;
            self.pon_pila(tempb); 
     end;
     $3d:begin
       cycles:=9;
       //orcc
            tempb:=self.dame_pila or numero;
            self.pon_pila(tempb); 
     end;
     $3e,$3f:begin
       if instruccion=$3e then begin
         cycles:=4*(8+self.ciclos_extra);
         if (numero and $80)=0 then begin
           if (((numero shr 4) and 7)<=5) and ((numero and 7)<=5) then cycles:=8;
           if numero=$26 then cycles:=8;
         end else if numero in [$a3,$a6,$a7] then cycles:=8;
       end
       else begin
         cycles:=4*(6+self.ciclos_extra);
         if (numero and $80)=0 then begin
           if (((numero shr 4) and 7)<=5) and ((numero and 7)<=5) then cycles:=8;
         end else if numero=$a3 then cycles:=8;
       end;
       if (numero and $80)<>0 then self.trf(numero)
             else self.trf_ex(numero);
     end;
     $40,$41:begin
       if instruccion=$40 then begin
         cycles:=12;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(3+self.ciclos_extra);
       end;
       r.d.w:=konami_ld_st16(posicion,@r.cc);  //ldd
     end;
     $42,$43:begin
       if instruccion=$42 then begin
         cycles:=12;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(3+self.ciclos_extra);
       end;
       r.x:=konami_ld_st16(posicion,@r.cc);  //ldx
     end;
     $44,$45:begin
       if instruccion=$44 then begin
         cycles:=12;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(3+self.ciclos_extra);
       end;
       r.y:=konami_ld_st16(posicion,@r.cc);  //ldy
     end;
     $46,$47:begin
       if instruccion=$46 then begin
         cycles:=12;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(3+self.ciclos_extra);
       end;
       r.u:=konami_ld_st16(posicion,@r.cc);  //ldu
     end;
     $48,$49:begin
       if instruccion=$48 then begin
         cycles:=12;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(3+self.ciclos_extra);
       end;
       r.s:=konami_ld_st16(posicion,@r.cc); r.pila_init:=true;   //lds
     end;
     $4a,$4b:begin
       if instruccion=$4a then begin
         cycles:=13;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(3+self.ciclos_extra);
       end;
       konami_sub16(r.d.w,posicion,@r.cc);  //cmpd
     end;
     $4c,$4d:begin
       if instruccion=$4c then begin
         cycles:=12;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(3+self.ciclos_extra);
       end;
       konami_sub16(r.x,posicion,@r.cc);  //cmpx
     end;
     $4e,$4f:begin
       if instruccion=$4e then begin
         cycles:=12;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(3+self.ciclos_extra);
       end;
       konami_sub16(r.y,posicion,@r.cc);  //cmpy
     end;
     $50,$51:begin
       if instruccion=$50 then begin
         cycles:=12;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(3+self.ciclos_extra);
       end;
       konami_sub16(r.u,posicion,@r.cc);  //cmpu
     end;
     $52,$53:begin
       if instruccion=$52 then begin
         cycles:=12;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(3+self.ciclos_extra);
       end;
       konami_sub16(r.s,posicion,@r.cc);  //cmps
     end;
     $54,$55:begin
       if instruccion=$54 then begin
         cycles:=13;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(4+self.ciclos_extra);
       end;
       r.d.w:=konami_add16(r.d.w,posicion,@r.cc); //addd
     end;
     $56,$57:begin
       if instruccion=$56 then begin
         cycles:=13;
       end
       else begin
         if self.indexed_postbyte=$07 then cycles:=25
         else cycles:=4*(4+self.ciclos_extra);
       end;
       r.d.w:=konami_sub16(r.d.w,posicion,@r.cc); //subd
     end;
     $58:begin
       if self.indexed_postbyte=$07 then cycles:=26
       else cycles:=4*(3+self.ciclos_extra);
       self.putword(posicion,konami_ld_st16(r.d.w,@r.cc)); //std
     end;
     $59:begin
       if self.indexed_postbyte=$07 then cycles:=26
       else cycles:=4*(3+self.ciclos_extra);
       self.putword(posicion,konami_ld_st16(r.x,@r.cc)); //stx
     end;
     $5a:begin
       if self.indexed_postbyte=$07 then cycles:=26
       else cycles:=4*(3+self.ciclos_extra);
       self.putword(posicion,konami_ld_st16(r.y,@r.cc)); //sty
     end;
     $5b:begin
       if self.indexed_postbyte=$07 then cycles:=26
       else cycles:=4*(3+self.ciclos_extra);
       self.putword(posicion,konami_ld_st16(r.u,@r.cc)); //stu
     end;
     $5c:begin
       if self.indexed_postbyte=$07 then cycles:=26
       else cycles:=4*(3+self.ciclos_extra);
       self.putword(posicion,konami_ld_st16(r.s,@r.cc)); //sts
     end;
     $60:begin
       cycles:=11;
       r.pc:=r.pc+shortint(numero); //bra
     end;
     $61:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if not(r.cc.c or r.cc.z) then cycles:=13 else cycles:=7;
       end;
       if not(r.cc.c or r.cc.z) then r.pc:=r.pc+shortint(numero);  //bhi
     end;
     $62:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if not r.cc.c then cycles:=11 else cycles:=7;
       end;
       if not(r.cc.c) then r.pc:=r.pc+shortint(numero);  //bcc
     end;
     $63:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if not r.cc.z then cycles:=11 else cycles:=7;
       end;
       if not(r.cc.z) then r.pc:=r.pc+shortint(numero); //bne
     end;
     $65:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if not r.cc.n then cycles:=11 else cycles:=7;
       end;
       if not(r.cc.n) then r.pc:=r.pc+shortint(numero); //bpl
     end;
     $66:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if (r.cc.n=r.cc.v) then cycles:=13 else cycles:=9;
       end;
       if (r.cc.n=r.cc.v) then r.pc:=r.pc+shortint(numero);//bge
     end;
     $67:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if ((r.cc.n=r.cc.v) and not r.cc.z) then cycles:=15 else cycles:=11;
       end;
       if ((r.cc.n=r.cc.v) and not(r.cc.z)) then r.pc:=r.pc+shortint(numero); //bgt
     end;
     $68:begin
       cycles:=13;
       r.pc:=r.pc+smallint(posicion); //lbra
     end;
     $69:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if not(r.cc.c or r.cc.z) then cycles:=15 else cycles:=7;
       end;
       if not(r.cc.c or r.cc.z) then r.pc:=r.pc+smallint(posicion);  //lbhi
     end;
     $6a:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if not r.cc.c then cycles:=13 else cycles:=7;
       end;
       if not(r.cc.c) then r.pc:=r.pc+smallint(posicion);  //lbcc
     end;
     $6b:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if not r.cc.z then cycles:=13 else cycles:=7;
       end;
       if not(r.cc.z) then r.pc:=r.pc+smallint(posicion); //lbne
     end;
     $6d:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if not r.cc.n then cycles:=13 else cycles:=7;
       end;
       if not(r.cc.n) then r.pc:=r.pc+smallint(posicion); //lbpl
     end;
     $6e:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if (r.cc.n=r.cc.v) then cycles:=15 else cycles:=9;
       end;
       if (r.cc.n=r.cc.v) then r.pc:=r.pc+smallint(posicion);//lbge
     end;
     $6f:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if ((r.cc.n=r.cc.v) and not r.cc.z) then cycles:=17 else cycles:=11;
       end;
       if ((r.cc.n=r.cc.v) and not(r.cc.z)) then r.pc:=r.pc+smallint(posicion); //lbgt
     end;
     $70:begin
       cycles:=6;
       ; //brn
     end;
     $71:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if (r.cc.c or r.cc.z) then cycles:=11 else cycles:=9;
       end;
       if (r.cc.c or r.cc.z) then r.pc:=r.pc+shortint(numero); //bls
     end;
     $72:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if r.cc.c then cycles:=11 else cycles:=7;
       end;
       if r.cc.c then r.pc:=r.pc+shortint(numero); //bcs
     end;
     $73:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if r.cc.z then cycles:=11 else cycles:=7;
       end;
       if r.cc.z then r.pc:=r.pc+shortint(numero); //beq
     end;
     $74:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if r.cc.v then cycles:=11 else cycles:=7;
       end;
       if r.cc.v then r.pc:=r.pc+shortint(numero); //bvs
     end;
     $75:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if r.cc.n then cycles:=11 else cycles:=7;
       end;
       if r.cc.n then r.pc:=r.pc+shortint(numero); //bmi
     end;
     $76:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if (r.cc.n<>r.cc.v) then cycles:=12 else cycles:=9;
       end;
       if not(r.cc.n=r.cc.v) then r.pc:=r.pc+shortint(numero);//blt
     end;
     $77:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin
         if not((r.cc.n=r.cc.v) and not r.cc.z) then cycles:=14 else cycles:=11;
       end;
       if not((r.cc.n=r.cc.v) and not(r.cc.z)) then r.pc:=r.pc+shortint(numero); //ble
     end;
     $78:begin
       cycles:=7;
       ; //lbrn
     end;
     $79:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if (r.cc.c or r.cc.z) then cycles:=13 else cycles:=10;
       end;
       if (r.cc.c or r.cc.z) then r.pc:=r.pc+smallint(posicion); //lbls
     end;
     $7a:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if r.cc.c then cycles:=13 else cycles:=8;
       end;
       if r.cc.c then r.pc:=r.pc+smallint(posicion); //lbcs
     end;
     $7b:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if r.cc.z then cycles:=13 else cycles:=8;
       end;
       if r.cc.z then r.pc:=r.pc+smallint(posicion); //lbeq
     end;
     $7d:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if r.cc.n then cycles:=13 else cycles:=8;
       end;
       if r.cc.n then r.pc:=r.pc+smallint(posicion); //lbmi
     end;
     $7e:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if (r.cc.n<>r.cc.v) then cycles:=14 else cycles:=10;
       end;
       if not(r.cc.n=r.cc.v) then r.pc:=r.pc+smallint(posicion);//lblt
     end;
     $7f:begin
       cycles:=4*(4+self.ciclos_extra);
       if posicion=0 then begin
         if not((r.cc.n=r.cc.v) and not r.cc.z) then cycles:=16 else cycles:=12;
       end;
       if not((r.cc.n=r.cc.v) and not(r.cc.z)) then r.pc:=r.pc+smallint(posicion); //lble
     end;
     $80:begin
       cycles:=4;
       //clra
            r.d.a:=0;
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false; 
     end;
     $81:begin
       cycles:=4;
       //clrb
            r.d.b:=0;
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false; 
     end;
     $82:begin
       if self.indexed_postbyte=$07 then cycles:=22
       else cycles:=4*(4+self.ciclos_extra);
       //clr
          self.putbyte(posicion,0);
          r.cc.n:=false;
          r.cc.v:=false;
          r.cc.c:=false;
          r.cc.z:=true; 
     end;
     $83:begin
       cycles:=4;
       r.d.a:=konami_com(r.d.a,@r.cc); //coma
     end;
     $84:begin
       cycles:=4;
       r.d.b:=konami_com(r.d.b,@r.cc); //comb
     end;
     $85:begin
       if self.indexed_postbyte=$07 then cycles:=25
       else cycles:=4*(4+self.ciclos_extra);
       self.putbyte(posicion,konami_com(self.getbyte(posicion),@r.cc)); //com
     end;
     $86:begin
       cycles:=5;
       r.d.a:=konami_neg(r.d.a,@r.cc); //nega
     end;
     $87:begin
       cycles:=5;
       r.d.b:=konami_neg(r.d.b,@r.cc); //negb
     end;
     $88:begin
       if self.indexed_postbyte=$07 then cycles:=25
       else cycles:=4*(4+self.ciclos_extra);
       self.putbyte(posicion,konami_neg(self.getbyte(posicion),@r.cc));  //neg
     end;
     $89:begin
       cycles:=4;
       r.d.a:=konami_inc(r.d.a,@r.cc); //inca
     end;
     $8a:begin
       cycles:=4;
       r.d.b:=konami_inc(r.d.b,@r.cc); //incb
     end;
     $8b:begin
       if self.indexed_postbyte=$07 then cycles:=25
       else cycles:=4*(4+self.ciclos_extra);
       self.putbyte(posicion,konami_inc(self.getbyte(posicion),@r.cc)); //inc
     end;
     $8c:begin
       cycles:=4;
       r.d.a:=konami_dec(r.d.a,@r.cc); //deca
     end;
     $8d:begin
       cycles:=4;
       r.d.b:=konami_dec(r.d.b,@r.cc); //decb
     end;
     $8e:begin
       if self.indexed_postbyte=$07 then cycles:=25
       else cycles:=4*(4+self.ciclos_extra);
       self.putbyte(posicion,konami_dec(self.getbyte(posicion),@r.cc)); //dec
     end;
     $8f:begin
       cycles:=14;
       r.pc:=self.pop_sw; //rts
     end;
     $90:begin
       cycles:=4;
       konami_tst(r.d.a,@r.cc); //tsta
     end;
     $91:begin
       cycles:=4;
       konami_tst(r.d.b,@r.cc); //tstb
     end;
     $92:begin
       cycles:=4*(4+self.ciclos_extra);
       if (self.indexed_postbyte and $f0) in [$20,$30,$50,$60] then begin
         case self.indexed_postbyte and 7 of
           0,2,4,6:cycles:=16;
           1,3:cycles:=17;
           5:cycles:=22;
         end;
         if ((self.indexed_postbyte and 7)<>7) and ((self.indexed_postbyte and 8)<>0) then inc(cycles,7);
       end else case self.indexed_postbyte of
         $07:cycles:=21; $c4:cycles:=19; $cc:cycles:=26; $0f:cycles:=28;
         $a0,$b0,$e0,$f0,$f1:cycles:=18;
         $d0,$e7,$f7:cycles:=20;
         $a8,$b8,$e8,$f8,$f9:cycles:=25;
         $d8,$ef,$ff:cycles:=27;
         $76,$70:cycles:=16; $71:cycles:=17;
         $78:cycles:=23; $79:cycles:=24; $74:cycles:=21; $75:cycles:=22;
         $7c:cycles:=28; $7d:cycles:=29;
       end;
       konami_tst(self.getbyte(posicion),@r.cc); //tst
     end;
     $93:begin
       cycles:=4;
       r.d.a:=konami_lsr(r.d.a,@r.cc); //lsra
     end;
     $94:begin
       cycles:=4;
       r.d.b:=konami_lsr(r.d.b,@r.cc); //lsrb
     end;
     $95:begin
       if self.indexed_postbyte=$07 then cycles:=25
       else cycles:=4*(4+self.ciclos_extra);
       self.putbyte(posicion,konami_lsr(self.getbyte(posicion),@r.cc)); //lsr
     end;
     $96:begin
       cycles:=4;
       r.d.a:=konami_ror(r.d.a,@r.cc); //rora
     end;
     $97:begin
       cycles:=4;
       r.d.b:=konami_ror(r.d.b,@r.cc); //rorb
     end;
     $98:begin
       if self.indexed_postbyte=$07 then cycles:=25
       else cycles:=4*(4+self.ciclos_extra);
       self.putbyte(posicion,konami_ror(self.getbyte(posicion),@r.cc)); //ror
     end;
     $99:begin
       cycles:=4;
       r.d.a:=konami_asr(r.d.a,@r.cc); //asra
     end;
     $9a:begin
       cycles:=4;
       r.d.b:=konami_asr(r.d.b,@r.cc); //asrb
     end;
     $9b:begin
       if self.indexed_postbyte=$07 then cycles:=25
       else cycles:=4*(4+self.ciclos_extra);
       self.putbyte(posicion,konami_asr(self.getbyte(posicion),@r.cc)); //asr
     end;
     $9c:begin
       cycles:=4;
       r.d.a:=konami_asl(r.d.a,@r.cc); //asla
     end;
     $9d:begin
       cycles:=4;
       r.d.b:=konami_asl(r.d.b,@r.cc); //aslb
     end;
     $9e:begin
       if self.indexed_postbyte=$07 then cycles:=25
       else cycles:=4*(4+self.ciclos_extra);
       self.putbyte(posicion,konami_asl(self.getbyte(posicion),@r.cc)); //asl
     end;
     $9f:begin
       
       //rti
          self.pon_pila(self.pop_s);
          if r.cc.e then begin //13 T
            self.ciclos_extra:=self.ciclos_extra+9;
            r.d.a:=self.pop_s;
            r.d.b:=self.pop_s;
            r.dp:=self.pop_s;
            r.x:=self.pop_sw;
            r.y:=self.pop_sw;
            r.u:=self.pop_sw;
          end;
          r.pc:=self.pop_sw; 
       if r.cc.e then cycles:=63 else cycles:=21;
     end;
     $a0:begin
       cycles:=4;
       r.d.a:=konami_rol(r.d.a,@r.cc); //rola
     end;
     $a1:begin
       cycles:=4;
       r.d.b:=konami_rol(r.d.b,@r.cc); //rolb
     end;
     $a2:begin
       if self.indexed_postbyte=$07 then cycles:=26
       else cycles:=4*(4+self.ciclos_extra);
       self.putbyte(posicion,konami_rol(self.getbyte(posicion),@r.cc)); //rol
     end;
     $a3:begin
       if self.indexed_postbyte=$07 then cycles:=35
       else cycles:=4*(2+self.ciclos_extra);
       self.putword(posicion,konami_lsr16(self.getword(posicion),@r.cc)); //lsr16
     end;
     $a5:begin
       if self.indexed_postbyte=$07 then cycles:=35
       else cycles:=4*(2+self.ciclos_extra);
       self.putword(posicion,konami_asr16(self.getword(posicion),@r.cc)); //asr16
     end;
     $a6:begin
       if self.indexed_postbyte=$07 then cycles:=34
       else cycles:=4*(2+self.ciclos_extra);
       self.putword(posicion,konami_asl16(self.getword(posicion),@r.cc)); //asl16
     end;
     $a8:begin
       if self.indexed_postbyte=$07 then cycles:=17
       else cycles:=4*(1+self.ciclos_extra);
       r.pc:=posicion;  //jmp
     end;
     $a9:begin
       if self.indexed_postbyte=$07 then cycles:=27
       else cycles:=4*(5+self.ciclos_extra);
       //jsr
            self.push_sw(r.pc);
            r.pc:=posicion; 
     end;
     $aa:begin
       cycles:=19;
       //bsr
            self.push_sw(r.pc);
            r.pc:=r.pc+shortint(numero); 
     end;
     $ab:begin
       cycles:=21;
       //lbsr
            self.push_sw(r.pc);
            r.pc:=r.pc+smallint(posicion); 
     end;
     $ac:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin if r.d.b=1 then cycles:=9 else cycles:=13; end;
       //decbjnz
          tempw:=r.d.b-1;
          r.cc.z:=((tempw and $ff)=0);
          r.cc.n:=(tempw and $80)<>0;
          r.cc.v:=((r.d.b xor 1 xor tempw xor (tempw shr 1)) and $80)<>0;
          r.d.b:=tempw;
          if not(r.cc.z) then r.pc:=r.pc+shortint(numero); 
     end;
     $ad:begin
       cycles:=4*(3+self.ciclos_extra);
       if numero=0 then begin if r.x=1 then cycles:=9 else cycles:=13; end;
       //decxjnz
          templ:=r.x-1;
          r.cc.z:=((templ and $ffff)=0);
          r.cc.n:=(templ and $8000)<>0;
          r.cc.v:=((r.x xor 1 xor templ xor (templ shr 1)) and $8000)<>0;
          r.x:=templ;
          if not(r.cc.z) then r.pc:=r.pc+shortint(numero); 
     end;
     $b0:begin
       cycles:=4;
       r.x:=r.x+r.d.b;  //abx
     end;
     $b1:begin
       cycles:=8;
       if r.d.a in [$00,$0a,$a0,$ff] then begin
         cycles:=14;
         if r.cc.h then dec(cycles,3) else if (r.d.a and 15)>9 then dec(cycles);
         if r.cc.c then dec(cycles,3) else if r.d.a>$99 then dec(cycles);
       end;
       //daa
            tempb:=r.d.a;
            old_carry:=r.cc.c;
            low_correction:=0;
            high_correction:=0;
            if (r.cc.h or ((tempb and $0f)>9)) then low_correction:=$06;
            if (old_carry or (tempb>$99)) then high_correction:=$60;
            tempw:=tempb+low_correction+high_correction;
            carry_out:=tempw>$ff;
            r.d.a:=tempw;
            r.cc.h:=(((tempb and $0f)+low_correction)>$0f);
            r.cc.n:=false;
            r.cc.z:=false;
            r.cc.v:=false;
            r.cc.c:=old_carry xor carry_out;
            if high_correction=0 then begin
              r.cc.n:=(r.d.a and $80)<>0;
              r.cc.z:=(r.d.a=0);
            end; 
     end;
     $b2:begin
       cycles:=4;
       //sex
          r.d.a:=$ff*(r.d.b shr 7);
          r.cc.n:=(r.d.w and $8000)<>0;
          r.cc.z:=(r.d.w=0);
          r.cc.v:=false; 
     end;
     $b3:begin
       cycles:=16;
       //mul
          r.d.w:=r.d.a*r.d.b;
          r.cc.c:=(r.d.w and $80)<>0;
          r.cc.z:=(r.d.w=0); 
     end;
     $b4:begin
       cycles:=23;
       //lmul 21
          templ:=r.x*r.y;
          r.x:=templ shr 16;
          r.y:=templ and $ffff;
          r.cc.z:=(templ=0); 
     end;
     $b5:begin
       
       //divx 10
          if r.d.b<>0 then begin
             tempw:=r.x div r.d.b;
             cycles:=25+(tempw and 1);
             tempb:=r.x mod r.d.b;
          end else begin
             cycles:=26-((r.x shr 15) and 1);
             tempw:=$ffff;
             tempb:=r.x and $ff;
          end;
          r.x:=tempw;
          r.d.b:=tempb;
          r.cc.n:=(r.x and $8000)<>0;
          r.cc.z:=(r.x=0);
     end;
     $b6:begin
       if r.u<>0 then cycles:=7+8*integer(r.u)
       else cycles:=4*(1+2*65536);
       repeat //bmove
              tempb:=self.getbyte(r.y);
              r.y:=r.y+1;
              self.putbyte(r.x,tempb);
              r.x:=r.x+1;
              r.u:=word((integer(r.u)-1) and $ffff);
              self.ciclos_extra:=self.ciclos_extra+2;
         until r.u=0; r.cc.z:=true; 
     end;
     $b8:begin
       cycles:=15+(numero and 15);
       r.d.w:=konami_lsrd(r.d.w,numero,@r.cc);  //lsrd
     end;
     $bc:begin
       cycles:=17+(numero and 15);
       r.d.w:=konami_asrd(r.d.w,numero,@r.cc);  //asrd
     end;
     $be:begin
       cycles:=30-(numero and 15);
       if cycles<2+(numero and 15) then cycles:=2+(numero and 15);
       r.d.w:=konami_asld(r.d.w,numero,@r.cc);  //asld
     end;
     $c2:begin
       cycles:=4;
       //clrd
            r.d.w:=0;
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false; 
     end;
     $c3:begin
       if self.indexed_postbyte=$07 then cycles:=26
       else cycles:=4*(2+self.ciclos_extra);
       //clr16
            self.putword(posicion,0);
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false; 
     end;
     $c4:begin
       cycles:=7;
       r.d.w:=konami_neg16(r.d.w,@r.cc); // negd
     end;
     $c5:begin
       if self.indexed_postbyte=$07 then cycles:=33
       else cycles:=4*(2+self.ciclos_extra);
       self.putword(posicion,konami_neg16(self.getword(posicion),@r.cc)); // neg16
     end;
     $c6:begin
       cycles:=6;
       r.d.w:=konami_inc16(r.d.w,@r.cc); //incd
     end;
     $c7:begin
       if self.indexed_postbyte=$07 then cycles:=33
       else cycles:=4*(2+self.ciclos_extra);
       self.putword(posicion,konami_inc16(self.getword(posicion),@r.cc)); //inc16
     end;
     $c9:begin
       if self.indexed_postbyte=$07 then cycles:=33
       else cycles:=4*(2+self.ciclos_extra);
       self.putword(posicion,konami_dec16(self.getword(posicion),@r.cc)); //dec16
     end;
     $ca:begin
       cycles:=5;
       //tstd
          r.cc.n:=(r.d.w and $8000)<>0;
          r.cc.z:=(r.d.w=0);
          r.cc.v:=false; 
     end;
     $cb:begin
       if self.indexed_postbyte=$07 then cycles:=25
       else cycles:=4*(2+self.ciclos_extra);
       //tst16
          tempw:=self.getword(posicion);
          r.cc.n:=(tempw and $8000)<>0;
          r.cc.z:=(tempw=0);
          r.cc.v:=false; 
     end;
     $cc:begin
       cycles:=5;
       r.d.a:=konami_abs8(r.d.a,@r.cc); //absa
     end;
     $cd:begin
       cycles:=5;
       r.d.b:=konami_abs8(r.d.b,@r.cc); //absb
     end;
     $ce:begin
       cycles:=8;
       r.d.w:=konami_abs16(r.d.w,@r.cc); //absd
     end;
     $cf:begin
       if r.u<>0 then cycles:=7+4*integer(r.u)
       else cycles:=4*(1+2*65536);
       repeat //bset
            self.putbyte(r.x,r.d.a);
            r.x:=r.x+1;
            r.u:=word((integer(r.u)-1) and $ffff);
            self.ciclos_extra:=self.ciclos_extra+2;
         until r.u=0; r.cc.z:=true; 
     end;
     $d0:begin
       if r.u<>0 then cycles:=7+8*integer(r.u)
       else cycles:=4*(1+3*65536);
       repeat //bset2
            self.putword(r.x,r.d.w);
            r.x:=r.x+2;
            r.u:=word((integer(r.u)-1) and $ffff);
            self.ciclos_extra:=self.ciclos_extra+3;
         until r.u=0; r.cc.z:=true;
     end;
     $ae:cycles:=4; // Existing implicit NOP; no flag/register effects.

end;
inc(cycles,self.clock_remainder);
self.clock_remainder:=cycles and 3;
self.consume_cycles(cycles div 4);
end; //Del while
end;

end.
