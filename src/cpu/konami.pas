unit konami;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,dialogs,sysutils,timer_engine,vars_hide,m6809;

type
        tset_lines=procedure (valor:byte);
        cpu_konami=class(cpu_class)
            constructor create(clock:dword;frames_div:word);
            destructor free;
          public
            //IRQ's
            procedure reset;
            procedure run(maximo:single);
            procedure change_irq(estado:byte);
            procedure change_firq(estado:byte);
            procedure change_set_lines(tset_lines_call:tset_lines);
          private
            //Registros
            r:preg_m6809;
            pedir_nmi,pedir_firq,pedir_irq,nmi_state:byte;
            set_lines_call:tset_lines;
            //Llamadas a RAM
            procedure putword(direccion:word;valor:word);
            function getword(direccion:word):word;
            //Llamadas IRQ
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

const
     estados_t:array[0..255] of byte=(
    //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
      0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 5, 0, 4, 0,  // 0
      2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,  // 10
      2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,  // 20
      2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 8, 6,  // 30
      4, 3, 4, 3, 4, 3, 4, 3, 4, 3, 5, 3, 5, 3, 5, 3,  // 40
      5, 3, 5, 3, 5, 4, 5, 4, 3, 3, 3, 3, 3, 0, 0, 0,  // 50
      3, 3, 3, 3, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,  // 60
      3, 3, 3, 3, 0, 3, 3, 3, 0, 0, 0, 0, 0, 0, 0, 0,  // 70
      1, 1, 4, 2, 2, 4, 2, 2, 4, 2, 2, 4, 2, 2, 4, 4,  // 80
      2, 2, 4, 2, 2, 4, 2, 2, 4, 2, 2, 4, 2, 2, 4, 4,  // 90
      2, 2, 4, 2, 0, 0, 2, 0, 1, 5, 7, 9, 3, 0, 2, 0,  // A0
      3, 2, 2,11,21,10, 0, 0, 2, 0, 0, 0, 0, 0, 2, 0,  // B0
      0, 0, 2, 2, 2, 2, 0, 2, 0, 2, 2, 2, 2, 2, 2, 0,  // C0
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // D0
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  // E0
      0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0); // F0

    paginacion:array[0..255] of byte=(
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
       $f,$f,$f,$f,$f,$f,$f,$f, 4, 4, 4, 4, 2,$f, 2,$f,  //00
        2, 2, 6, 6, 2, 2, 6, 6, 2, 2, 6, 6, 2, 2, 6, 6,  //10
        2, 2, 6, 6, 2, 2, 6, 6, 2, 2, 6, 6, 2, 2, 6, 6,  //20
        2, 2, 6, 6, 2, 2, 6, 6, 2, 6, 4, 4, 2, 2, 2, 2,  //30
        3, 9, 3, 9, 3, 9, 3, 9, 3, 9, 3, 9, 3, 9, 3, 9,  //40
        3, 9, 3, 9, 3, 9, 3, 9, 4, 4, 4, 4, 4,$f,$f,$f,  //50
        2, 2, 2, 2,$f, 2, 2, 2, 3, 3, 3, 3,$f, 3, 3, 3,  //60
        2, 2, 2, 2,$f, 2, 2, 2, 3, 3, 3, 3,$f, 3, 3, 3,  //70
        0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0,  //80
        0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0, 0, 4, 0,  //90
        0, 0, 4, 4,$f,$f, 4,$f, 4, 4, 2, 3, 2,$f, 0,$f,  //a0
        0, 0, 0, 0, 0, 0, 0,$f, 2,$f,$f,$f,$f,$f, 2,$f,  //b0
       $f,$f, 0, 4, 0, 4,$f, 4,$f, 4, 0, 4, 0, 0, 0, 0,  //c0
        0,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,  //d0
       $f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,  //e0
       $f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f,$f); //f0

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

procedure cpu_konami.change_set_lines(tset_lines_call:tset_lines);
begin
     self.set_lines_call:=tset_lines_call;
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
self.pedir_irq:=CLEAR_LINE;
self.pedir_firq:=CLEAR_LINE;
self.nmi_state:=CLEAR_LINE;
r.cwai:=false;
r.pila_init:=false;
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

procedure trf(r:preg_m6809;valor:byte);
var
  temp:word;
begin
case (valor and $7) of
    $0:temp:=r.d.a; //A
    $1:temp:=r.d.b; //B
    $2:temp:=r.x; //X
    $3:temp:=r.y; //Y
    $4:temp:=r.s; //S
    $5:temp:=r.u; //U
end;
case ((valor shr 4) and 7) of
    $0:r.d.a:=temp; //A
    $1:r.d.b:=temp;  //B
    $2:r.x:=temp; //X
    $3:r.y:=temp; //Y
    $4:r.s:=temp; //S
    $5:r.u:=temp; //U
end;
end;

procedure trf_ex(r:preg_m6809;valor:byte);
var
  temp1,temp2:word;
begin
case (valor and $7) of
    $0:temp1:=r.d.a; //A
    $1:temp1:=r.d.b;  //B
    $2:temp1:=r.x; //X
    $3:temp1:=r.y; //Y
    $4:temp1:=r.s; //S
    $5:temp1:=r.u; //U
end;
case ((valor shr 4) and 7) of
    $0:temp2:=r.d.a; //A
    $1:temp2:=r.d.b;  //B
    $2:temp2:=r.x; //X
    $3:temp2:=r.y; //Y
    $4:temp2:=r.s; //S
    $5:temp2:=r.u; //U
end;
case (valor and $7) of
    $0:r.d.a:=temp2; //A
    $1:r.d.b:=temp2;  //B
    $2:r.x:=temp2; //X
    $3:r.y:=temp2; //Y
    $4:r.s:=temp2; //S
    $5:r.u:=temp2; //U
end;
case ((valor shr 4) and 7) of
    $0:r.d.a:=temp1; //A
    $1:r.d.b:=temp1;  //B
    $2:r.x:=temp1; //X
    $3:r.y:=temp1; //Y
    $4:r.s:=temp1; //S
    $5:r.u:=temp1; //U
end;
end;

function cpu_konami.get_indexed:word;
var
  iindexed,temp:byte;
  origen:pparejas;
  direccion,temp2:word;
begin
iindexed:=self.getbyte(r.pc); //Hay que añadir 1 estado por cojer un byte...
r.pc:=r.pc+1;
case (iindexed and $70) of
  $20:origen:=@r.x;
  $30:origen:=@r.y;
  $50:origen:=@r.u;
  $60:origen:=@r.s;
  $70:origen:=@r.pc;
end;
case (iindexed and $f7) of
      7:begin // =
          direccion:=self.getword(r.pc);
          r.pc:=r.pc+2;
          self.estados_demas:=self.estados_demas+1+2;
        end;
      $20,$30,$50,$60,$70:begin  //reg+
          direccion:=origen.w;
          origen.w:=origen.w+1;
          self.estados_demas:=self.estados_demas+1+2;
      end;
      $21,$31,$51,$61,$71:begin  //reg++
          direccion:=origen.w;
          origen.w:=origen.w+2;
          self.estados_demas:=self.estados_demas+1+3;
      end;
      $22,$32,$52,$62,$72:begin  //-reg
          origen.w:=origen.w-1;
          direccion:=origen.w;
          self.estados_demas:=self.estados_demas+1+3;
      end;
      $23,$33,$53,$63,$73:begin //--reg
          origen.w:=origen.w-2;
          direccion:=origen.w;
          self.estados_demas:=self.estados_demas+1+3;
      end;
      $24,$34,$54,$64,$74:begin  //reg + deplazamiento 8bits
          direccion:=origen.w;
          temp:=self.getbyte(r.pc);
          r.pc:=r.pc+1;
          direccion:=direccion+shortint(temp);
          self.estados_demas:=self.estados_demas+1+2;
      end;
      $25,$35,$55,$65,$75:begin  //reg + deplazamiento 16bits
          direccion:=origen.w;
          temp2:=self.getword(r.pc);
          r.pc:=r.pc+2;
          direccion:=direccion+smallint(temp2);
          self.estados_demas:=self.estados_demas+5+1;
      end;
      $26,$36,$56,$66,$76:begin // =
          direccion:=origen.w;
          self.estados_demas:=self.estados_demas+1;
        end;
      $c4:begin
          direccion:=(self.r.dp shl 8)+self.getbyte(r.pc);
          r.pc:=r.pc+1;
          self.estados_demas:=self.estados_demas+1+1;
      end;
      $a0,$b0,$d0,$e0,$f0:begin // reg + r.d.a
          direccion:=origen.w+shortint(r.d.a);
          self.estados_demas:=self.estados_demas+1+1;
        end;

      $a1,$b1,$d1,$e1,$f1:begin //reg + r.d.b
          direccion:=origen.w+shortint(r.d.b);
          self.estados_demas:=self.estados_demas+1+1;
        end;
      $a7,$b7,$d7,$e7,$f7:begin //reg + r.d.w
          direccion:=origen.w+smallint(r.d.w);
          self.estados_demas:=self.estados_demas+1+4;
         end;
      else  MessageDlg('Indexed desconocido. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
end;
if (iindexed and $8)<>0 then begin
     direccion:=self.getword(direccion);
     self.estados_demas:=self.estados_demas+2;
end;
get_indexed:=direccion;
end;

//Functions
{$I m6809.inc}

procedure cpu_konami.run(maximo:single);
var
  tempb,tempb2,cf,instruccion,numero:byte;
  tempw:word;
  templ:dword;
  posicion:parejas;
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
self.estados_demas:=0;
if ((self.pedir_firq<>CLEAR_LINE) and not(r.cc.f)) then self.estados_demas:=self.call_firq
       else if ((self.pedir_irq<>CLEAR_LINE) and not(r.cc.i)) then self.estados_demas:=self.call_irq;
if r.cwai then begin
  self.contador:=trunc(maximo);
  exit;
end;
self.opcode:=true;
instruccion:=self.getbyte(r.pc);
r.pc:=r.pc+1;
self.opcode:=false;
case paginacion[instruccion] of
     0:; //implicito 0T
     2:begin  //inmediato byte
        numero:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
      end;
     3:begin  //EXTENDED 3T
         posicion.w:=self.getword(r.pc);
         r.pc:=r.pc+2;
      end;
     4:posicion.w:=self.get_indexed; //INDEXED Los estados T son variables
     6:numero:=self.getbyte(get_indexed); //indexado indirecto byte
     9:posicion.w:=self.getword(get_indexed); //indexado indirecto word
     $f:MessageDlg('Konami CPU '+inttostr(self.numero_cpu)+' instruccion: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(r.pc,10)+' OLD_PC='+inttohex(self.r.old_pc,10), mtInformation,[mbOk], 0)
end; //del case!!
case instruccion of
     $08:begin //leax 2T
            r.x:=posicion.w;
            r.cc.z:=(r.x=0);
          end;
     $09:begin //leay 2T
            r.y:=posicion.w;
            r.cc.z:=(r.y=0);
          end;
     $0a:r.u:=posicion.w; //leau 2T
     $0b:r.s:=posicion.w; //leas 2T
     $0c:begin //pshs 5T
            if (numero and $80)<>0 then begin
              self.push_sw(r.pc);
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $40)<>0 then begin
              self.push_sw(r.u);
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $20)<>0 then begin
              self.push_sw(r.y);
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $10)<>0 then begin
              self.push_sw(r.x);
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $8)<>0 then begin
              self.push_s(r.dp);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $4)<>0 then begin
              self.push_s(r.d.b);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $2)<>0 then begin
              self.push_s(r.d.a);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $1)<>0 then begin
              self.push_s(dame_pila(self.r));
              self.estados_demas:=self.estados_demas+1;
            end;
      end;
     $0e:begin //puls 4T
            if (numero and $1)<>0 then begin
              pon_pila(self.r,self.pop_s);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $2)<>0 then begin
              r.d.a:=self.pop_s;
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $4)<>0 then begin
              r.d.b:=self.pop_s;
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $8)<>0 then begin
              r.dp:=self.pop_s;
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $10)<>0 then begin
              r.x:=self.pop_sw;
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $20)<>0 then begin
              r.y:=self.pop_sw;
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $40)<>0 then begin
              r.u:=self.pop_sw;
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $80)<>0 then begin
              r.pc:=self.pop_sw;
              self.estados_demas:=self.estados_demas+2;
            end;
      end;
     $10,$12:r.d.a:=m680x_ld_st8(numero,@r.cc);  //lda 1T
     $11,$13:r.d.b:=m680x_ld_st8(numero,@r.cc);  //ldb 1T
     $14,$16:r.d.a:=m680x_add8(r.d.a,numero,@r.cc);  //adda 1T
     $15,$17:r.d.b:=m680x_add8(r.d.b,numero,@r.cc);  //addb 1T
     $18,$1a:r.d.a:=m680x_adc(r.d.a,numero,@r.cc);  //adca 1T
     $19,$1b:r.d.b:=m680x_adc(r.d.b,numero,@r.cc);  //adcb 1T
     $1c,$1e:r.d.a:=m680x_sub8(r.d.a,numero,@r.cc);  //suba 1T
     $1d,$1f:r.d.b:=m680x_sub8(r.d.b,numero,@r.cc);  //subb 1T
     $20,$22:r.d.a:=m680x_sbc(r.d.a,numero,@r.cc);  //sbca 1T
     $21,$23:r.d.b:=m680x_sbc(r.d.b,numero,@r.cc);  //sbcb 1T
     $24,$26:r.d.a:=m680x_and(r.d.a,numero,@r.cc);  //anda 1T
     $25,$27:r.d.b:=m680x_and(r.d.b,numero,@r.cc);  //andb 1T
     $28,$2a:m680x_and(r.d.a,numero,@r.cc);  //bita 1T
     $29,$2b:m680x_and(r.d.b,numero,@r.cc);  //bitb 1T
     $2c,$2e:r.d.a:=m680x_eor(r.d.a,numero,@r.cc);  //eora 1T
     $2d,$2f:r.d.b:=m680x_eor(r.d.b,numero,@r.cc);  //eorb 1T
     $30,$32:r.d.a:=m680x_or(r.d.a,numero,@r.cc);  //ora 1T
     $31,$33:r.d.b:=m680x_or(r.d.b,numero,@r.cc);  //orb 1T
     $34,$36:m680x_sub8(r.d.a,numero,@r.cc);  //cmpa 1T
     $35,$37:m680x_sub8(r.d.b,numero,@r.cc);  //cmpb 1T
     $38,$39:if @self.set_lines_call<>nil then self.set_lines_call(numero);
     $3a:self.putbyte(posicion.w,m680x_ld_st8(r.d.a,@r.cc));  //sta 1T
     $3b:self.putbyte(posicion.w,m680x_ld_st8(r.d.b,@r.cc));  //stb 1T
     $3c:begin //andcc  3T
            tempb:=dame_pila(self.r) and numero;
            pon_pila(self.r,tempb);
         end;
     $3d:begin //orcc 3T
            tempb:=dame_pila(self.r) or numero;
            pon_pila(self.r,tempb);
         end;
     $3e:trf_ex(self.r,numero); //exg 8T
     $3f:trf(self.r,numero); //trf 4T
     $40,$41:r.d.w:=m680x_ld_st16(posicion.w,@r.cc);  //ldd 2T
     $42,$43:r.x:=m680x_ld_st16(posicion.w,@r.cc);  //ldx 2T
     $44,$45:r.y:=m680x_ld_st16(posicion.w,@r.cc);  //ldy 2T
     $46,$47:r.u:=m680x_ld_st16(posicion.w,@r.cc);  //ldu 2T
     $48,$49:r.s:=m680x_ld_st16(posicion.w,@r.cc);  //lds 2T
     $4a,$4b:m680x_sub16(r.d.w,posicion.w,@r.cc);  //cmpd
     $4c,$4d:m680x_sub16(r.x,posicion.w,@r.cc);  //cmpx
     $4e,$4f:m680x_sub16(r.y,posicion.w,@r.cc);  //cmpy
     $50,$51:m680x_sub16(r.u,posicion.w,@r.cc);  //cmpu
     $52,$53:m680x_sub16(r.s,posicion.w,@r.cc);  //cmps
     $54,$55:r.d.w:=m680x_add16(r.d.w,posicion.w,@r.cc); //addd 2T
     $56,$57:r.d.w:=m680x_sub16(r.d.w,posicion.w,@r.cc); //subd 2T
     $58:self.putword(posicion.w,m680x_ld_st16(r.d.w,@r.cc)); //std
     $59:self.putword(posicion.w,m680x_ld_st16(r.x,@r.cc)); //stx
     $5a:self.putword(posicion.w,m680x_ld_st16(r.y,@r.cc)); //sty
     $5b:self.putword(posicion.w,m680x_ld_st16(r.u,@r.cc)); //stu
     $5c:self.putword(posicion.w,m680x_ld_st16(r.s,@r.cc)); //sts
     $60:r.pc:=r.pc+shortint(numero); //bra 3T
     $61:if not(r.cc.c or r.cc.z) then r.pc:=r.pc+shortint(numero);  //bhi 3T
     $62:if not(r.cc.c) then r.pc:=r.pc+shortint(numero);  //bcc 3T
     $63:if not(r.cc.z) then r.pc:=r.pc+shortint(numero); //bne 3T
     $65:if not(r.cc.n) then r.pc:=r.pc+shortint(numero); //bpl 3T
     $66:if (not(r.cc.n)=not(r.cc.v)) then r.pc:=r.pc+shortint(numero);//bge 3T
     $67:if ((not(r.cc.n)=not(r.cc.v)) and not(r.cc.z)) then r.pc:=r.pc+shortint(numero); //bgt 3T
     $68:r.pc:=r.pc++smallint(posicion.w); //lbra 3T
     $69:if not(r.cc.c or r.cc.z) then r.pc:=r.pc+smallint(posicion.w);  //lbhi 3T
     $6a:if not(r.cc.c) then r.pc:=r.pc+smallint(posicion.w);  //lbcc 3T
     $6b:if not(r.cc.z) then r.pc:=r.pc+smallint(posicion.w); //lbne 3T
     $6d:if not(r.cc.n) then r.pc:=r.pc+smallint(posicion.w); //lbpl 3T
     $6e:if (not(r.cc.n)=not(r.cc.v)) then r.pc:=r.pc+smallint(posicion.w);//lbge 3T
     $6f:if not((not(r.cc.n)=not(r.cc.v)) and not(r.cc.z)) then r.pc:=r.pc+smallint(posicion.w); //lbgt 3T
     $70:; //brn 3T
     $71:if (r.cc.c or r.cc.z) then r.pc:=r.pc+shortint(numero); //bls 3T
     $72:if r.cc.c then r.pc:=r.pc+shortint(numero); //bcs 3T
     $73:if r.cc.z then r.pc:=r.pc+shortint(numero); //beq 3T
     $75:if r.cc.n then r.pc:=r.pc+shortint(numero); //bmi 3T
     $76:if (not(r.cc.n)=not(r.cc.v)) then r.pc:=r.pc+shortint(numero);//blt 3T
     $77:if not((not(r.cc.n)=not(r.cc.v)) and not(r.cc.z)) then r.pc:=r.pc+shortint(numero); //ble 3T
     $78:; //lbrn 3T
     $79:if (r.cc.c or r.cc.z) then r.pc:=r.pc+smallint(posicion.w); //lbls 3T
     $7a:if r.cc.c then r.pc:=r.pc+smallint(posicion.w); //lbcs 3T
     $7b:if r.cc.z then r.pc:=r.pc+smallint(posicion.w); //lbeq 3T
     $7d:if r.cc.n then r.pc:=r.pc+smallint(posicion.w); //lbmi 3T
     $7e:if (not(r.cc.n)=not(r.cc.v)) then r.pc:=r.pc+smallint(posicion.w);//lblt 3T
     $7f:if not((not(r.cc.n)=not(r.cc.v)) and not(r.cc.z)) then r.pc:=r.pc+smallint(posicion.w); //lble 3T
     $80:begin //clra 2T
            r.d.a:=0;
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false;
          end;
     $81:begin //clrb 2T
            r.d.b:=0;
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false;
          end;
     $82:begin //clr 4T
          self.putbyte(posicion.w,0);
          r.cc.n:=false;
          r.cc.v:=false;
          r.cc.c:=false;
          r.cc.z:=true;
      end;
     $83:r.d.a:=m680x_com(r.d.a,@r.cc); //coma 2T
     $84:r.d.b:=m680x_com(r.d.b,@r.cc); //comb 2T
     $85:self.putbyte(posicion.w,m680x_com(self.getbyte(posicion.w),@r.cc)); //com 4T
     $86:r.d.a:=m680x_neg(r.d.a,@r.cc); //nega 2T
     $87:r.d.b:=m680x_neg(r.d.b,@r.cc); //negb 2T
     $88:self.putbyte(posicion.w,m680x_neg(self.getbyte(posicion.w),@r.cc)); //neg 4T
     $89:r.d.a:=m680x_inc(r.d.a,@r.cc); //inca 2T
     $8a:r.d.b:=m680x_inc(r.d.b,@r.cc); //incb 2T
     $8b:self.putbyte(posicion.w,m680x_inc(self.getbyte(posicion.w),@r.cc)); //inc 4T
     $8c:r.d.a:=m680x_dec(r.d.a,@r.cc); //deca 2T
     $8d:r.d.b:=m680x_dec(r.d.b,@r.cc); //decb 2T
     $8e:self.putbyte(posicion.w,m680x_dec(self.getbyte(posicion.w),@r.cc)); //dec 4T
     $8f:r.pc:=self.pop_sw; //rts 4T
     $90:m680x_tst(r.d.a,@r.cc); //tsta 2T
     $91:m680x_tst(r.d.b,@r.cc); //tstb 2T
     $92:m680x_tst(self.getbyte(posicion.w),@r.cc); //tst 3T
     $93:r.d.a:=m680x_lsr(r.d.a,@r.cc); //lsra 2T
     $94:r.d.b:=m680x_lsr(r.d.b,@r.cc); //lsrb 2T
     $95:self.putbyte(posicion.w,m680x_lsr(self.getbyte(posicion.w),@r.cc)); //lsr 4T
     $96:r.d.a:=m680x_ror(r.d.a,@r.cc); //rora 2T
     $97:r.d.b:=m680x_ror(r.d.b,@r.cc); //rorb 2T
     $98:self.putbyte(posicion.w,m680x_ror(self.getbyte(posicion.w),@r.cc)); //ror 4T
     $99:r.d.a:=m680x_asr(r.d.a,@r.cc); //asra 2T
     $9a:r.d.b:=m680x_asr(r.d.b,@r.cc); //asrb 2T
     $9b:self.putbyte(posicion.w,m680x_asr(self.getbyte(posicion.w),@r.cc)); //asr 4T
     $9c:r.d.a:=m680x_asl(r.d.a,@r.cc); //asla 2T
     $9d:r.d.b:=m680x_asl(r.d.b,@r.cc); //aslb 2T
     $9e:self.putbyte(posicion.w,m680x_asl(self.getbyte(posicion.w),@r.cc)); //asl 4T
     $9f:begin  //rti 4T
          pon_pila(self.r,self.pop_s);
          if r.cc.e then begin //13 T
            self.estados_demas:=self.estados_demas+9;
            r.d.a:=self.pop_s;
            r.d.b:=self.pop_s;
            r.dp:=self.pop_s;
            r.x:=self.pop_sw;
            r.y:=self.pop_sw;
            r.u:=self.pop_sw;
          end;
          r.pc:=self.pop_sw;
      end;
     $a0:r.d.a:=m680x_rol(r.d.a,@r.cc); //rola 2T
     $a1:r.d.b:=m680x_rol(r.d.b,@r.cc); //rolb 2T
     $a2:self.putbyte(posicion.w,m680x_rol(self.getbyte(posicion.w),@r.cc)); //rol 4T
     $a3:self.putword(posicion.w,m680x_lsr16(self.getword(posicion.w),@r.cc)); //lsr16
     $a6:self.putword(posicion.w,m680x_asl16(self.getword(posicion.w),@r.cc)); //asl16
     $a8:r.pc:=posicion.w;  //jmp 1T
     $a9:begin //jsr 5T
            self.push_sw(r.pc);
            r.pc:=posicion.w;
      end;
     $aa:begin  //bsr 7T
            self.push_sw(r.pc);
            r.pc:=r.pc+shortint(numero);
      end;
     $ab:begin  //lbsr 9T
            self.push_sw(r.pc);
            r.pc:=r.pc+smallint(posicion.w);
            self.contador:=self.contador+1;
      end;
     $ac:begin //decbjnz
          r.d.b:=m680x_dec(r.d.b,@r.cc);
          if not(r.cc.z) then r.pc:=r.pc+shortint(numero);
         end;
     $b0:r.x:=r.x+r.d.b;  //abx 3T
     $b1:begin //daa 2T
            cf:=0;
            tempb:=r.d.a and $f0;
            tempb2:=r.d.a and $0f;
	    if ((tempb2>$09) or r.cc.h) then cf:=cf or $06;
	    if ((tempb>$80) and (tempb2>$09)) then cf:=cf or $60;
	    if ((tempb>$90) or r.cc.c) then cf:=cf or $60;
	    tempw:=cf+r.d.a;
	    r.cc.v:=false;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.c:=r.cc.c or ((tempw and $100)<>0);
	    r.d.a:=tempw;
          end;
     $b2:begin //sex 2T
          if (r.d.b and $80)<>0 then r.d.a:=$ff
              else r.d.a:=0;
          r.cc.n:=(r.d.w and $8000)<>0;
          r.cc.z:=(r.d.w=0);
         end;
     $b3:begin  //mul 11T
          r.d.w:=r.d.a*r.d.b;
          r.cc.c:=(r.d.w and $80)<>0;
          r.cc.z:=(r.d.w=0);
      end;
     $b4:begin //lmul 21
          templ:=r.x*r.y;
          r.x:=templ shr 16;
          r.y:=templ and $ffff;
          r.cc.z:=(templ=0);
          r.cc.c:=(templ and $8000)<>0;
         end;
     $b5:begin //divx 10
          if r.d.b<>0 then begin
             tempw:=r.x div r.d.b;
             tempb:=r.x mod r.d.b;
          end else begin
             tempw:=0;
             tempb:=0;
          end;
          r.x:=tempw;
          r.d.b:=tempb;
          r.cc.c:=(tempw and $80)<>0;
          r.cc.z:=(tempw=0);
         end;
     $b6:while (r.u<>0) do begin //bmove
            tempb:=self.getbyte(r.y);
            r.y:=r.y+1;
            self.putbyte(r.x,tempb);
            r.x:=r.x+1;
            r.u:=r.u-1;
            self.estados_demas:=self.estados_demas+3;
         end;
     $b8:r.d.w:=m680x_lsrd(r.d.w,numero,@r.cc);  //lsrd
     $be:if (numero<>0) then begin  //asld
            if (r.d.w and ($10000 shr numero))<>0 then r.cc.c:=true
               else r.cc.c:=false;
             r.d.w:=r.d.w shl numero;
             r.cc.n:=(r.d.w and $8000)<>0;
             r.cc.z:=(r.d.w=0);
             r.cc.v:=((0 xor r.d.w xor r.d.w xor (r.d.w shr 1)) and $8000)<>0;
         end;
     $c2:begin //clrd
            r.d.w:=0;
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false;
         end;
     $c3:begin //clr16
            self.putword(posicion.w,0);
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false;
         end;
     $c4:r.d.w:=m680x_neg16(r.d.w,@r.cc); // negd
     $c5:self.putword(posicion.w,m680x_neg16(self.getword(posicion.w),@r.cc)); // neg16
     $c7:self.putword(posicion.w,m680x_inc16(self.getword(posicion.w),@r.cc)); //inc16
     $c9:self.putword(posicion.w,m680x_dec16(self.getword(posicion.w),@r.cc)); //dec16
     $ca:m680x_tst16(r.d.w,@r.cc); //tstd
     $cb:m680x_tst16(self.getword(posicion.w),@r.cc);
     $cc:r.d.a:=m680x_abs(r.d.a,@r.cc); //absa
     $cd:r.d.b:=m680x_abs(r.d.b,@r.cc); //absb
     $ce:r.d.w:=m680x_abs16(r.d.w,@r.cc);
     $cf:while (r.u<>0) do begin //bset
            self.putbyte(r.x,r.d.a);
            r.x:=r.x+1;
            r.u:=r.u-1;
            self.estados_demas:=self.estados_demas+2;
         end;
     $d0:while (r.u<>0) do begin //bset2
            self.putword(r.x,r.d.w);
            r.x:=r.x+2;
            r.u:=r.u-1;
            self.estados_demas:=self.estados_demas+3;
         end;
end;
tempw:=estados_t[instruccion]+self.estados_demas;
self.contador:=self.contador+tempw;
update_timer(tempw,self.numero_cpu);
end; //Del while
end;

end.
