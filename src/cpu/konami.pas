unit konami;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,dialogs,sysutils,timer_engine,vars_hide,m6809;

type
        cpu_konami=class(cpu_class)
            constructor create(clock:dword;frames_div:word);
            destructor free;
          public
            //IRQ's
            procedure reset;
            procedure run(maximo:single);
            procedure change_irq(estado:byte);
            procedure change_firq(estado:byte);
            procedure change_nmi(estado:byte);
          private
            //Registros
            r:preg_m6809;
            pedir_nmi,pedir_firq,pedir_irq,nmi_state:byte;
            //Llamadas a RAM
            procedure putword(direccion:word;valor:word);
            function getword(direccion:word):word;
            //Llamadas IRQ
            function call_nmi:byte;
            function call_irq:byte;
            function call_firq:byte;
            //Misc Func
            function get_indexed:word;
            //Push & pop
            procedure push_s(reg:byte);
            function pop_s:byte;
            procedure push_sw(reg:word);
            function pop_sw:word;
            procedure push_u(reg:byte);
            function pop_u:byte;
            procedure push_uw(reg:word);
            function pop_uw:word;
        end;

var
  main_konami:cpu_konami;

implementation

constructor cpu_konami.create(clock:dword;frames_div:word);
begin
getmem(self.r,sizeof(reg_m6809));
fillchar(self.r^,sizeof(reg_m6809),0);
self.numero_cpu:=cpu_quantity;
self.clock:=clock;
self.tframes:=(clock/frames_div)/llamadas_maquina.fps_max;
cpu_quantity:=cpu_quantity+1;
end;

destructor cpu_konami.free;
begin
freemem(self.r);
end;

procedure cpu_konami.putword(direccion:word;valor:word);
begin
self.putbyte(direccion,valor shr 8);
self.putbyte(direccion+1,valor and $FF);
end;

function cpu_konami.getword(direccion:word):word;
var
  valor:word;
begin
valor:=self.getbyte(direccion) shl 8;
getword:=valor+(self.getbyte(direccion+1));
end;

function dame_pila(r:preg_m6809):byte;inline;
var
  temp:byte;
begin
  temp:=0;
  if r.cc.e then temp:=temp or $80;
  if r.cc.f then temp:=temp or $40;
  if r.cc.h then temp:=temp or $20;
  if r.cc.i then temp:=temp or $10;
  if r.cc.n then temp:=temp or 8;
  if r.cc.z then temp:=temp or 4;
  if r.cc.v then temp:=temp or 2;
  if r.cc.c then temp:=temp or 1;
  dame_pila:=temp;
end;

procedure pon_pila(r:preg_m6809;valor:byte);inline;
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

procedure cpu_konami.reset;
begin
self.opcode:=false;
r.pc:=self.getword($FFFE);
r.dp:=0;
self.contador:=0;
pon_pila(self.r,$50);
self.pedir_nmi:=CLEAR_LINE;
self.pedir_irq:=CLEAR_LINE;
self.pedir_firq:=CLEAR_LINE;
self.nmi_state:=CLEAR_LINE;
r.cwai:=false;
r.pila_init:=false;
end;

procedure cpu_konami.change_nmi(estado:byte);
begin
if estado=CLEAR_LINE then begin
  self.pedir_nmi:=CLEAR_LINE;
  self.nmi_state:=CLEAR_LINE;
end else begin
  self.pedir_nmi:=estado;
end;
end;

procedure cpu_konami.change_irq(estado:byte);
begin
  self.pedir_irq:=estado;
end;

procedure cpu_konami.change_firq(estado:byte);
begin
  self.pedir_firq:=estado;
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
self.putbyte(r.s+1,reg and $FF);
self.putbyte(r.s,(reg shr 8));
end;

function cpu_konami.pop_sw:word;
var
  temp:word;
begin
temp:=self.getbyte(r.s) shl 8;
temp:=temp or self.getbyte(r.s+1);
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
self.putbyte(r.u+1,reg and $FF);
self.putbyte(r.u,(reg shr 8));
end;

function cpu_konami.pop_uw:word;
var
  temp:word;
begin
temp:=self.getbyte(r.u) shl 8;
temp:=temp or self.getbyte(r.u+1);
r.u:=r.u+2;
pop_uw:=temp;
end;

function cpu_konami.call_nmi:byte;
begin
call_nmi:=0;
if self.nmi_state<>CLEAR_LINE then exit;
if not(r.pila_init) then exit;
if r.cwai then begin  //Si el estado es cwai, ya he metido en la pila todo...
  r.cwai:=false;
  call_nmi:=6;
end else begin
  self.push_sw(r.pc);
  self.push_sw(r.u);
  self.push_sw(r.y);
  self.push_sw(r.x);
  self.push_s(r.dp);
  self.push_s(r.d.b);
  self.push_s(r.d.a);
  r.cc.e:=true;
  self.push_s(dame_pila(self.r));
  call_nmi:=19;
end;
r.cc.i:=true;
r.cc.f:=true;
r.pc:=self.getword($FFFC);
if (self.pedir_nmi=PULSE_LINE) then self.pedir_nmi:=CLEAR_LINE;
if (self.pedir_nmi=ASSERT_LINE) then self.nmi_state:=ASSERT_LINE;
end;

function cpu_konami.call_irq:byte;
begin
if r.cwai then begin
  r.cwai:=false;
  call_irq:=6;
end else begin
  self.push_sw(r.pc);
  self.push_sw(r.u);
  self.push_sw(r.y);
  self.push_sw(r.x);
  self.push_s(r.dp);
  self.push_s(r.d.b);
  self.push_s(r.d.a);
  r.cc.e:=true;
  self.push_s(dame_pila(self.r));
  call_irq:=19;
end;
r.pc:=self.getword($FFF8);
r.cc.i:=true;
if self.pedir_irq=HOLD_LINE then self.pedir_irq:=CLEAR_LINE;
end;

function cpu_konami.call_firq:byte;
begin
if r.cwai then begin
  r.cwai:=false;
  call_firq:=6;
end else begin
  r.cc.e:=false;
  self.push_sw(r.pc);
  self.push_s(dame_pila(self.r));
  call_firq:=10;
end;
r.cc.f:=true;
r.cc.i:=true;
r.pc:=self.getword($FFF6);
if self.pedir_firq=HOLD_LINE then self.pedir_firq:=CLEAR_LINE;
end;

function cpu_konami.get_indexed:word;
var
  iindexed,temp:byte;
  origen:pparejas;
  direccion,temp2:word;
begin
iindexed:=self.getbyte(r.pc); //Hay que añadir 1 estado por cojer un byte...
r.pc:=r.pc+1;
case (iindexed and $60) of
  $00:origen:=@r.x;
  $20:origen:=@r.y;
  $40:origen:=@r.u;
  $60:origen:=@r.s;
end;
if (iindexed and $80)<>0 then begin
  case (iindexed and $f) of
      0:begin  //reg+
          direccion:=origen.w;
          origen.w:=origen.w+1;
          self.estados_demas:=self.estados_demas+3+1;
      end;
      1:begin  //reg++
          direccion:=origen.w;
          origen.w:=origen.w+2;
          self.estados_demas:=self.estados_demas+4+1;
      end;
      2:begin  //-reg
          origen.w:=origen.w-1;
          direccion:=origen.w;
          self.estados_demas:=self.estados_demas+3+1;
      end;
      3:begin //--reg
          origen.w:=origen.w-2;
          direccion:=origen.w;
          self.estados_demas:=self.estados_demas+4+1;
      end;
      4:begin // =
          direccion:=origen.w;
          self.estados_demas:=self.estados_demas+1+1;
        end;
      5:begin //reg + r.d.b
          direccion:=origen.w+shortint(r.d.b);
          self.estados_demas:=self.estados_demas+2+1;
        end;
      6:begin // reg + r.d.a
          direccion:=origen.w+shortint(r.d.a);
          self.estados_demas:=self.estados_demas+2+1;
        end;
      7:MessageDlg('Indexed 7 desconocido. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
      8:begin  //reg + deplazamiento 8bits
          temp:=self.getbyte(r.pc);
          r.pc:=r.pc+1;
          direccion:=origen.w+shortint(temp);
          self.estados_demas:=self.estados_demas+2+1;
      end;
      9:begin  //reg + deplazamiento 16bits
          temp2:=self.getword(r.pc);
          r.pc:=r.pc+2;
          direccion:=origen.w+smallint(temp2);
          self.estados_demas:=self.estados_demas+5+1;
      end;
      $a:MessageDlg('Indexed $a desconocido. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
      $b:begin //reg + r.d.w
          direccion:=origen.w+smallint(r.d.w);
          self.estados_demas:=self.estados_demas+5+1;
         end;
      $c:MessageDlg('Indexed $c desconocido. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
      $d:begin  //pc + desplazamiento 16 bits
          temp2:=self.getword(r.pc);
          r.pc:=r.pc+2;
          direccion:=r.pc+temp2;
          self.estados_demas:=self.estados_demas+6+1;
      end;
      $f:begin  //pc
          direccion:=self.getword(r.pc);
          r.pc:=r.pc+2;
          self.estados_demas:=self.estados_demas+3+1;
      end
  end;
  if (iindexed and $10)<>0 then begin
     direccion:=self.getword(direccion);
     self.estados_demas:=self.estados_demas+2;
  end;
end else begin
  temp:=iindexed and $f;
  if (iindexed and $10)=0 then direccion:=origen.w+temp
    else direccion:=origen.w-(16-temp);
  self.estados_demas:=self.estados_demas+2+1;
end;
get_indexed:=direccion;
end;

procedure trf(r:preg_m6809;valor:byte);inline;
var
  temp:word;
begin
if ((valor xor (valor shr 4)) and $08)<>0 then begin
  temp:=$ff
end else begin
  case (valor shr 4) of
    $0:temp:=r.d.w; //D
    $1:temp:=r.x;  //X
    $2:temp:=r.y; //Y
    $3:temp:=r.u; //U
    $4:temp:=r.s; //S
    $5:temp:=r.pc; //pc
    $8:temp:=r.d.a; //a
    $9:temp:=r.d.b; //b
    $a:temp:=dame_pila(r);  //cc
    $b:temp:=r.dp; //dp
  end;
end;
case (valor and 15) of
    $0:r.d.w:=temp; //D
    $1:r.x:=temp;  //X
    $2:r.y:=temp; //Y
    $3:r.u:=temp; //U
    $4:r.s:=temp; //S
    $5:r.pc:=temp; //pc
    $8:r.d.a:=temp; //a
    $9:r.d.b:=temp; //b
    $a:pon_pila(r,temp);  //cc
    $b:r.dp:=temp; //dp
end;
end;

procedure trf_ex(r:preg_m6809;valor:byte);inline;
var
  temp1,temp2:word;
begin
if ((valor xor (valor shr 4)) and $08)<>0 then begin
    temp1:=$ff;
    temp2:=$ff;
end else begin
  case (valor shr 4) of
    $0:temp1:=r.d.w; //D
    $1:temp1:=r.x;  //X
    $2:temp1:=r.y; //Y
    $3:temp1:=r.u; //U
    $4:temp1:=r.s; //S
    $5:temp1:=r.pc; //pc
    $8:temp1:=r.d.a; //a
    $9:temp1:=r.d.b; //b
    $a:temp1:=dame_pila(r);  //cc
    $b:temp1:=r.dp; //dp
  end;
  case (valor and 15) of
    $0:temp2:=r.d.w; //D
    $1:temp2:=r.x;  //X
    $2:temp2:=r.y; //Y
    $3:temp2:=r.u; //U
    $4:temp2:=r.s; //S
    $5:temp2:=r.pc; //pc
    $8:temp2:=r.d.a; //a
    $9:temp2:=r.d.b; //b
    $a:temp2:=dame_pila(r);  //cc
    $b:temp2:=r.dp; //dp
  end;
end;
case (valor shr 4) of
    $0:r.d.w:=temp2; //D
    $1:r.x:=temp2;  //X
    $2:r.y:=temp2; //Y
    $3:r.u:=temp2; //U
    $4:r.s:=temp2; //S
    $5:r.pc:=temp2; //pc
    $8:r.d.a:=temp2; //a
    $9:r.d.b:=temp2; //b
    $a:pon_pila(r,temp2);  //cc
    $b:r.dp:=temp2; //dp
end;
case (valor and 15) of
    $0:r.d.w:=temp1; //D
    $1:r.x:=temp1;  //X
    $2:r.y:=temp1; //Y
    $3:r.u:=temp1; //U
    $4:r.s:=temp1; //S
    $5:r.pc:=temp1; //pc
    $8:r.d.a:=temp1; //a
    $9:r.d.b:=temp1; //b
    $a:pon_pila(r,temp1);  //cc
    $b:r.dp:=temp1; //dp
end;
end;

//Functions
{$I m6809.inc}

procedure cpu_konami.run(maximo:single);
var
  tempb,instruccion:byte;
  tempw:word;
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
self.estados_demas:=0;
if self.pedir_nmi<>CLEAR_LINE then self.estados_demas:=self.call_nmi
  else if ((self.pedir_firq<>CLEAR_LINE) and not(r.cc.f)) then self.estados_demas:=self.call_firq
       else if ((self.pedir_irq<>CLEAR_LINE) and not(r.cc.i)) then self.estados_demas:=self.call_irq;
if r.cwai then begin
  self.contador:=trunc(maximo);
  exit;
end;
self.opcode:=true;
instruccion:=self.getbyte(r.pc);
r.pc:=r.pc+1;
self.opcode:=false;
//case paginacion[instruccion] of

//end; //del case!!
//tempw:=estados_t[instruccion]+self.estados_demas;
self.contador:=self.contador+tempw;
update_timer(tempw,self.numero_cpu);
end; //Del while
end;

end.
