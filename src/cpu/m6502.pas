unit M6502;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,dialogs,sysutils,timer_engine;

type
        band_m6502=record
                n,o_v,t,brk,dec,int,z,c:boolean;
        end;
        reg_m6502=record
                old_pc,pc:word;
                a,x,y:byte;
                sp:byte;
                p:band_m6502;
        end;
        preg_m6502=^reg_m6502;
        cpu_m6502=class(cpu_class)
            constructor Create(clock:dword;frames_div:word;cpu_type:byte);
            procedure Free;
            destructor Destroy;
          public
            after_ei:boolean;
            pedir_nmi,pedir_irq,nmi_state:byte;
            tipo_cpu:byte;
            procedure reset;
            procedure run(maximo:single);
            procedure clear_nmi;
            procedure change_io_calls(in_port0,in_port1:cpu_inport_call);
            function get_internal_r:preg_m6502;
          private
            //Internal Regs
            r:preg_m6502;
            //RAM calls/IO Calls
            in_port0,in_port1:cpu_inport_call;
            read_dummy:boolean;
            //IRQ
            function call_nmi:byte;
            function call_irq:byte;
        end;
const
  TCPU_M6502=0;
  TCPU_DECO16=1;
  TCPU_NES=2;

var
  main_m6502,snd_m6502:cpu_m6502;

implementation
const
        tipo_dir:array[0..255] of byte=(
      //0  1  2  3 4  5 6 7 8  9 a b c  d e f
        0,$a, 0,$a,7, 7,7,7,0, 1,0,1,2, 2,2,2,  //00
       $d,$b, 0,$b,8, 8,8,8,0, 6,0,6,5, 5,4,5,  //10
        0,$a, 0,$a,7, 7,7,7,0, 1,0,1,2, 2,2,2,  //20
       $d,$b, 0,$b,8, 8,8,8,0, 6,0,6,5, 5,4,5,  //30
        0,$a, 0,$a,7, 7,7,7,0, 1,0,1,2, 2,2,2,  //40
       $d,$b, 0,$b,8, 8,8,8,0, 6,0,6,5, 5,4,5,  //50
        0,$a, 0,$a,7, 7,7,7,0, 1,0,1,0, 2,2,2,  //60
       $d,$b, 0,$b,8, 8,8,8,0, 6,0,6,5, 5,4,5,  //70
       $d,$a, 1,$a,7, 7,7,7,0, 1,0,1,2, 2,2,2,  //80
       $d,$b, 0,$b,8, 8,9,9,0, 6,0,6,2, 4,5,5,  //90
        1,$a, 1, 0,7, 7,7,0,0, 1,0,0,2, 2,2,0,  //A0
       $d,$b, 0, 0,8, 8,9,0,0, 6,0,0,5, 5,6,0,  //B0
        1,$a, 1,$a,7, 7,7,0,0, 1,0,0,2, 2,2,2,  //C0
       $d,$b, 0,$b,8, 8,8,0,0, 6,0,6,5, 5,4,5,  //D0
        1,$a, 1,$a,7, 7,7,0,0, 1,0,1,2, 2,2,2,  //E0
       $d,$b, 0,$b,8, 8,8,0,0, 6,0,6,5, 5,4,5); //F0

        estados_t:array[0..1,0..255] of byte=((
        //M6502 + NES
        7, 6, 1, 8, 3, 3, 5, 5, 3, 2, 2, 2, 4, 4, 6, 6,
        2, 5, 1, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7,
        6, 6, 1, 8, 3, 3, 5, 5, 4, 2, 2, 2, 4, 4, 6, 6,
        2, 5, 1, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7,
        6, 6, 1, 8, 3, 3, 5, 5, 3, 2, 2, 2, 3, 4, 6, 6,
        2, 5, 1, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7,
        6, 6, 1, 8, 3, 3, 5, 5, 4, 2, 2, 2, 5, 4, 6, 6,
        2, 5, 1, 8, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7,
        2, 6, 2, 6, 3, 3, 3, 3, 2, 2, 2, 2, 4, 4, 4, 4,
        2, 6, 1, 6, 4, 4, 4, 4, 2, 5, 2, 5, 5, 5, 5, 5,
        2, 6, 2, 6, 3, 3, 3, 3, 2, 2, 2, 2, 4, 4, 4, 4,
        2, 5, 1, 5, 4, 4, 4, 4, 2, 4, 2, 4, 4, 4, 4, 4,
        2, 6, 2, 7, 3, 3, 5, 5, 2, 2, 2, 2, 4, 4, 6, 6,
        2, 5, 1, 7, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7,
        2, 6, 2, 7, 3, 3, 5, 5, 2, 2, 2, 2, 4, 4, 6, 6,
        2, 5, 1, 7, 4, 4, 6, 6, 2, 4, 2, 7, 4, 4, 7, 7),(
        //DECO16
        7, 6, 2, 2, 2, 3, 5, 2, 3, 2, 2, 2, 4, 4, 6, 2,  //0
        2, 5, 2, 2, 2, 4, 6, 2, 2, 4, 2, 2, 4, 4, 7, 2,  //1
        6, 6, 2, 2, 3, 3, 5, 2, 4, 2, 2, 2, 4, 4, 6, 2,  //2
        2, 5, 2, 2, 2, 4, 6, 2, 2, 4, 2, 2, 4, 4, 7, 1,  //3
        6, 6, 2, 2, 2, 3, 5, 2, 3, 2, 2, 1, 3, 4, 6, 2,  //4
        2, 5, 2, 2, 2, 4, 6, 2, 2, 4, 3, 2, 2, 4, 7, 2,  //5
        6, 6, 2, 2, 2, 3, 5, 2, 4, 2, 2, 2, 5, 4, 6, 2,  //6
        2, 5, 2, 2, 2, 4, 6, 2, 2, 4, 4, 2, 6, 4, 7, 2,  //7
        2, 6, 2, 2, 3, 3, 3, 2, 2, 2, 2, 2, 4, 4, 4, 1,  //8
        2, 6, 2, 2, 4, 4, 4, 2, 2, 5, 2, 2, 4, 5, 5, 2,  //9
        2, 6, 2, 2, 3, 3, 3, 2, 2, 2, 2, 2, 4, 4, 4, 2,  //a
        2, 5, 2, 2, 4, 4, 4, 2, 2, 4, 2, 1, 4, 4, 4, 2,  //b
        2, 6, 2, 2, 3, 3, 5, 2, 2, 2, 2, 2, 4, 4, 6, 2,  //c
        2, 5, 2, 2, 2, 4, 6, 2, 2, 4, 3, 2, 2, 4, 7, 2,  //d
        2, 6, 2, 2, 3, 3, 5, 2, 2, 2, 2, 2, 4, 4, 6, 2,  //e
        2, 5, 2, 2, 2, 4, 6, 2, 2, 4, 4, 2, 2, 4, 7, 2));
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f

constructor cpu_m6502.Create(clock:dword;frames_div:word;cpu_type:byte);
begin
getmem(self.r,sizeof(reg_m6502));
fillchar(self.r^,sizeof(reg_m6502),0);
self.numero_cpu:=cpu_quantity;
self.clock:=clock;
self.tipo_cpu:=cpu_type;
self.tframes:=(clock/frames_div)/llamadas_maquina.fps_max;
self.in_port0:=nil;
self.in_port1:=nil;
cpu_quantity:=cpu_quantity+1;
end;

destructor cpu_m6502.Destroy;
begin
freemem(self.r);
end;

procedure cpu_m6502.Free;
begin
  self.Destroy;
end;

procedure cpu_m6502.change_io_calls(in_port0,in_port1:cpu_inport_call);
begin
  self.in_port0:=in_port0;
  self.in_port1:=in_port1;
end;

function cpu_m6502.get_internal_r:preg_m6502;
begin
  get_internal_r:=self.r;
end;

procedure pon_pila(r:preg_m6502;valor:byte);inline;
begin
  r.p.n:=(valor and $80)<>0;
  r.p.o_v:=(valor and $40)<>0;
  r.p.dec:=(valor and 8)<>0;
  r.p.int:=(valor and 4)<>0;
  r.p.z:=(valor and 2)<>0;
  r.p.c:=(valor and 1)<>0;
end;

function dame_pila(r:preg_m6502):byte;inline;
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

procedure cpu_m6502.reset;
begin
case self.tipo_cpu of
  TCPU_M6502,TCPU_NES:r.pc:=self.getbyte($FFFC)+(self.getbyte($FFFD) shl 8);
  TCPU_DECO16:r.pc:=self.getbyte($FFF1)+(self.getbyte($FFF0) shl 8);
end;
r.a:=0;
r.x:=0;
r.y:=0;
r.sp:=$FD;
self.contador:=0;
r.p.n:=false;
r.p.o_v:=false;
r.p.t:=true;
r.p.brk:=true;
r.p.dec:=false;
r.p.int:=true;
r.p.z:=false;
r.p.c:=false;
self.after_ei:=false;
self.pedir_nmi:=CLEAR_LINE;
self.pedir_irq:=CLEAR_LINE;
self.nmi_state:=CLEAR_LINE;
self.pedir_reset:=CLEAR_LINE;
end;

procedure cpu_m6502.clear_nmi;
begin
  self.pedir_nmi:=CLEAR_LINE;
  self.nmi_state:=CLEAR_LINE;
end;

function cpu_m6502.call_nmi:byte;
begin
call_nmi:=0;
if self.nmi_state<>CLEAR_LINE then exit;
self.putbyte($100+r.sp,r.pc shr 8);
r.sp:=r.sp-1;
self.putbyte($100+r.sp,r.pc and $ff);
r.sp:=r.sp-1;
self.putbyte($100+r.sp,(dame_pila(self.r) and $df));
r.sp:=r.sp-1;
r.p.int:=true;
case self.tipo_cpu of
  TCPU_M6502,TCPU_NES:r.pc:=self.getbyte($FFFA)+(self.getbyte($FFFB) shl 8);
  TCPU_DECO16:r.pc:=self.getbyte($FFF7)+(self.getbyte($FFF6) shl 8);
end;
call_nmi:=7;
if (self.pedir_nmi=PULSE_LINE) then self.pedir_nmi:=CLEAR_LINE;
if (self.pedir_nmi=ASSERT_LINE) then self.nmi_state:=ASSERT_LINE;
end;

function cpu_m6502.call_irq:byte;
begin
if r.p.int then begin
  call_irq:=0;
  exit;
end;
self.putbyte($100+r.sp,r.pc shr 8);
r.sp:=r.sp-1;
self.putbyte($100+r.sp,r.pc and $ff);
r.sp:=r.sp-1;
self.putbyte($100+r.sp,(dame_pila(self.r) and $df));
r.sp:=r.sp-1;
r.p.int:=true;
case self.tipo_cpu of
  TCPU_M6502,TCPU_NES:r.pc:=self.getbyte($FFFE)+(self.getbyte($FFFF) shl 8);
  TCPU_DECO16:r.pc:=self.getbyte($FFF3)+(self.getbyte($FFF2) shl 8);
end;
call_irq:=7;
if self.pedir_irq=HOLD_LINE then self.pedir_irq:=CLEAR_LINE;
end;

procedure sbc(r:preg_m6502;numero,tipo_cpu:byte);
var
  carry,al,ah:byte;
  diff:word;
begin
if (r.p.dec and (tipo_cpu<>TCPU_NES)) then begin
  if r.p.c then carry:=1 else carry:=0;
  diff:=r.a-numero-carry;
  al:=(r.a and 15)-(numero and 15)-carry;
  if (shortint(al)<0) then al:=al-6;
  ah:=(r.a shr 4)-(numero shr 4)-byte((shortint(al)<0));
  r.p.z:=(diff and $ff)=0;
  if not(r.p.z) then r.p.n:=(diff and $80)<>0
    else r.p.n:=false;
  r.p.o_v:=((r.a xor numero) and (r.a xor diff) and $80)<>0;
  r.p.c:=(diff and $ff00)=0;
  if (shortint(ah)<0) then ah:=ah-6;
  r.a:=(ah shl 4) or (al and 15);
end else begin
  if not(r.p.c) then diff:=r.a-numero-1
    else diff:=r.a-numero;
  r.p.o_v:=((r.a xor numero) and (r.a xor diff) and $80)<>0;
  r.p.c:=(diff and $ff00)=0;
  r.a:=diff and $FF;
  r.p.z:=(r.a=0);
  if not(r.p.z) then r.p.n:=(r.a and $80)<>0
    else r.p.n:=false;
end;
end;

procedure adc(r:preg_m6502;numero,tipo_cpu:byte);
var
  al,ah,carry:byte;
  tempw:word;
begin
if (r.p.dec and (tipo_cpu<>TCPU_NES)) then begin
  if r.p.c then carry:=1 else carry:=0;
    al:=(r.a and 15)+(numero and 15)+carry;
	  if (al>9) then al:=al+6;
	  ah:=(r.a shr 4)+(numero shr 4)+byte(al>15);
	  r.p.z:=((r.a+numero+carry) and $ff)=0;
	  if not(r.p.z) then r.p.n:=(ah and 8)<>0;
	  r.p.o_v:=(not(r.a xor numero) and (r.a xor (ah shl 4)) and $80)<>0;
	  if (ah>9) then ah:=ah+6;
	  r.p.c:=(ah>15);
	  r.a:=(ah shl 4) or (al and 15);
  end else begin
    if r.p.c then tempw:=r.a+numero+1
      else tempw:=r.a+numero;
    r.p.o_v:=(not(r.a xor numero) and (r.a xor tempw) and $80)<>0;
    r.p.c:=(tempw and $ff00)<>0;
    r.a:=tempw and $ff;
    r.p.z:=(r.a=0);
    if not(r.p.z) then r.p.n:=(r.a and $80)<>0
      else r.p.n:=false;
  end;
end;

procedure cpu_m6502.run(maximo:single);
var
    instruccion,numero,tempb,carry:byte;
    tempw,posicion:word;
begin
self.contador:=0;
while self.contador<maximo do begin
if self.pedir_reset<>CLEAR_LINE then begin
  self.reset;
  self.pedir_reset:=ASSERT_LINE;
  self.contador:=trunc(maximo);
  exit;
end;
r.old_pc:=r.pc;
self.read_dummy:=false;
if not(self.after_ei) then begin
  if (self.pedir_nmi<>CLEAR_LINE) then self.estados_demas:=self.call_nmi
    else if (self.pedir_irq<>CLEAR_LINE) then self.estados_demas:=self.call_irq
      else self.estados_demas:=0;
end;
self.after_ei:=false;
self.opcode:=true;
instruccion:=self.getbyte(r.pc);
self.opcode:=false;
r.pc:=r.pc+1;
case tipo_dir[instruccion] of
        $00:;  //**implicito
        $01:begin //IMM
                posicion:=r.pc;
                r.pc:=r.pc+1;
          end;
        $02:begin //absoluto opcode+direccion 16bits (rev)
                posicion:=self.getbyte(r.pc);
                posicion:=posicion or (self.getbyte(r.pc+1) shl 8);
                r.pc:=r.pc+2;
            end;
        $03:begin  //desconocido!!!! -> MAL
                MessageDlg('Modo dir. mal, instruccion: '+inttohex(instruccion,2)+'. PC='+inttostr(r.pc), mtInformation,[mbOk], 0)
            end;
        $04:begin //absoluto indexado por X no page cross
                posicion:=self.getbyte(r.pc);
                posicion:=posicion+(self.getbyte(r.pc+1) shl 8)+r.x;
                r.pc:=r.pc+2;
            end;
        $05:begin //absoluto indexado por X (rev)
                posicion:=self.getbyte(r.pc)+(self.getbyte(r.pc+1) shl 8);
                case instruccion of
                  $1f,$3f,$5f,$7f:;
                  else if (((posicion+r.x) xor posicion) and $ff00)<>0 then self.estados_demas:=self.estados_demas+1;
                end;
                posicion:=posicion+r.x;
                r.pc:=r.pc+2;
            end;
        $06:begin //absoluto indexado por Y (rev)
                posicion:=self.getbyte(r.pc)+(self.getbyte(r.pc+1) shl 8);
                case instruccion of
                  $1b,$3b,$5b,$7b,$99:;
                  else if (((posicion+r.y) xor posicion) and $ff00)<>0 then self.estados_demas:=self.estados_demas+1;
                end;
                posicion:=posicion+r.y;
                r.pc:=r.pc+2;
            end;
        $07:begin //pagina 0  opcode+direccion 8bits (rev)
                posicion:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $08:begin  //pagina cero indexado por X (rev)
                tempb:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                posicion:=(tempb+r.x) and $ff;
            end;
        $09:begin  //pagina cero indexado por Y (rev)
                tempb:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                posicion:=(tempb+r.y) and $ff;
            end;
        $0a:begin //indirecto indexado por X (rev)
                tempb:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                tempb:=tempb+r.x;
                posicion:=self.getbyte(tempb) or (self.getbyte((tempb+1) and $ff) shl 8);
            end;
        $0b:begin  //indirecto indexado por Y (rev)
                tempb:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                posicion:=self.getbyte(tempb);
                posicion:=posicion or (self.getbyte((tempb+1) and $ff) shl 8);
                case instruccion of
                  $13,$33,$53,$73,$93,$91:;
                  else if (((posicion+r.y) xor posicion) and $ff00)<>0 then self.estados_demas:=self.estados_demas+1;
                end;
                posicion:=posicion+r.y;
            end;
        $0c:begin //indexado pagina 0 opcode+puntero 8bits (rev)
                tempb:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
                posicion:=self.getbyte(tempb);
                posicion:=posicion+(self.getbyte((tempb+1) and $ff) shl 8);
            end;
        $0d:begin //relativo
                numero:=self.getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
end;                // del tipo de direccionamiento
case instruccion of
      $00:begin  //brk
            r.pc:=r.pc+1;
            self.putbyte($100+r.sp,r.pc shr 8);
            r.sp:=r.sp-1;
            self.putbyte($100+r.sp,r.pc and $ff);
            r.sp:=r.sp-1;
            self.putbyte($100+r.sp,dame_pila(self.r) or $10);
            r.sp:=r.sp-1;
            r.p.int:=true;
            r.p.brk:=true;
            case self.tipo_cpu of
              TCPU_M6502,TCPU_NES:r.pc:=self.getbyte($FFFE)+(self.getbyte($FFFF) shl 8);
              TCPU_DECO16:r.pc:=self.getbyte($FFF3)+(self.getbyte($FFF2) shl 8);
            end;
          end;
      $01,$05,$09,$0d,$11,$15,$19,$1d:begin //ORA
            r.a:=r.a or self.getbyte(posicion);
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
          end;
      $03,$07,$0f,$13,$17,$1b,$1f:begin //SLO
            tempb:=self.getbyte(posicion);
            self.putbyte(posicion,tempb); // <-- Fallo de la CPU
            r.p.c:=(tempb and $80)<>0;
            tempb:=tempb shl 1;
            r.a:=r.a or tempb;
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
            self.putbyte(posicion,tempb);
          end;
      $04,$0c,$14,$1a,$1c,$34,$3a,$3c,$44,$54,$5a,$5c,$64,$74,$7a,$7c,$80,$82,$89,$c2,$d4,$da,$dc,$e2,$ea,$f4,$fa,$fc:self.getbyte(r.pc);  // <-- Fallo CPU NOP
      $06,$0e,$16,$1e:begin //asl
                tempb:=self.getbyte(posicion);
                self.putbyte(posicion,tempb); // <-- Fallo de la CPU
                r.p.c:=(tempb and $80)<>0;
                tempb:=tempb shl 1;
                r.p.z:=(tempb=0);
                r.p.n:=(tempb and $80)<>0;
                self.putbyte(posicion,tempb);
          end;
      $08:begin //PHP
            self.getbyte(r.pc);  // <-- Fallo CPU
            tempb:=dame_pila(self.r);
            tempb:=tempb or $20 or $10;
            self.putbyte($100+r.sp,tempb);
            r.sp:=r.sp-1;
          end;
      $0a:begin //asl A
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.p.c:=(r.a and $80)<>0;
            r.a:=r.a shl 1;
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
          end;
      $0b,$2b:begin //anc
            r.a:=r.a and self.getbyte(posicion);
            if r.p.c then carry:=1 else carry:=0;
            r.p.c:=(r.a and $80)<>0;
            r.a:=(r.a shl 1) or carry;
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
          end;
      $10:if not(r.p.n) then begin //BPL salta si n false
              if ((r.pc+shortint(numero)) and $ff00)<>(r.pc and $ff00) then self.estados_demas:=self.estados_demas+2
                else self.estados_demas:=self.estados_demas+1;
              r.pc:=r.pc+shortint(numero);
          end;
      $18:begin //CLC
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.p.c:=false;
          end;
      $20:begin // JSR absoluto
            tempb:=self.getbyte(r.pc);
            r.pc:=r.pc+1;
            self.putbyte($100+r.sp,r.pc shr 8);
            r.sp:=r.sp-1;
            self.putbyte($100+r.sp,r.pc and $ff);
            r.sp:=r.sp-1;
            r.pc:=(self.getbyte(r.pc) shl 8) or tempb;
          end;
      $21,$25,$29,$2d,$31,$35,$39,$3d:begin  //AND
            r.a:=r.a and self.getbyte(posicion);
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
        end;
      $23,$27,$2f,$33,$37,$3b,$3f:begin //RLA
            tempb:=self.getbyte(posicion);
            self.putbyte(posicion,tempb); // <-- Fallo de la CPU
            if r.p.c then tempw:=(tempb shl 1)+1
              else tempw:=tempb shl 1;
            r.p.c:=(tempw and $100)<>0;
            r.a:=r.a and (tempw and $ff);
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
            self.putbyte(posicion,tempw and $ff);
          end;
      $24,$2c:begin  //BIT
            numero:=self.getbyte(posicion);
            r.p.z:=(r.a and numero)=0;
            r.p.n:=(numero and $80)<>0;
            r.p.o_v:=(numero and $40)<>0;
        end;
      $26,$2e,$36,$3e:begin //ROL
            tempb:=self.getbyte(posicion);
            self.putbyte(posicion,tempb);  // <-- Fallo CPU
            if r.p.c then carry:=1 else carry:=0;
            r.p.c:=(tempb and $80)<>0;
            tempb:=(tempb shl 1) or carry;
            r.p.z:=(tempb=0);
            r.p.n:=(tempb and $80)<>0;
            self.putbyte(posicion,tempb);
         end;
      $28:begin  //PLP
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.sp:=r.sp+1;
            tempb:=self.getbyte($100+r.sp);
            pon_pila(self.r,tempb);
            self.after_ei:=true;
          end;
      $2a:begin //ROL A
            self.getbyte(r.pc);  // <-- Fallo CPU
            if r.p.c then carry:=1 else carry:=0;
            r.p.c:=(r.a and $80)<>0;
            r.a:=(r.a shl 1) or carry;
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
          end;
      $30:if r.p.n then begin  //BMI salta si n false
              if ((r.pc+shortint(numero)) and $ff00)<>(r.pc and $ff00) then self.estados_demas:=self.estados_demas+2
                else self.estados_demas:=self.estados_demas+1;
              r.pc:=r.pc+shortint(numero);
          end;
      $38:begin  //SEC
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.p.c:=true;
          end;
      $40:begin //RTI
                r.sp:=r.sp+1;
                pon_pila(self.r,self.getbyte($100+r.sp));
                r.sp:=r.sp+1;
                r.pc:=self.getbyte($100+r.sp);
                r.sp:=r.sp+1;
                r.pc:=r.pc or (self.getbyte($100+r.sp) shl 8);
                self.after_ei:=false;
          end;
      $41,$45,$49,$4d,$51,$55,$59,$5d:begin //EOR
            r.a:=r.a xor self.getbyte(posicion);
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
          end;
      $43,$47,$4f,$53,$57,$5b,$5f:begin //SRE
            tempb:=self.getbyte(posicion);
            self.putbyte(posicion,tempb); // <-- Fallo de la CPU
            r.p.c:=(tempb and $1)<>0;
            tempb:=tempb shr 1;
            r.a:=r.a xor tempb;
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
            self.putbyte(posicion,tempb);
          end;
      $46,$4e,$56,$5e:begin  //LSR
            tempb:=self.getbyte(posicion);
            self.putbyte(posicion,tempb);  // <-- Fallo CPU
            r.p.c:=(tempb and $1)<>0;
            tempb:=tempb shr 1;
            r.p.z:=(tempb=0);
            r.p.n:=false;
            self.putbyte(posicion,tempb);
          end;
      $48:begin  //PHA
            self.getbyte(r.pc);  // <-- Fallo CPU
            self.putbyte($100+r.sp,r.a);
            r.sp:=r.sp-1;
          end;
      $4a:begin  //LSR A
             self.getbyte(r.pc);  // <-- Fallo CPU
             r.p.c:=(r.a and $1)<>0;
             r.a:=r.a shr 1;
             r.p.z:=(r.a=0);
             r.p.n:=false;
          end;
      $4b:case self.tipo_cpu of
            TCPU_M6502,TCPU_NES:begin //alr
                                  r.p.c:=(r.a and $1)<>0;
                                  r.a:=r.a and self.getbyte(posicion);
                                  r.p.c:=(r.a and $1)<>0;
                                  r.a:=r.a shr 1;
                                  r.p.z:=(r.a=0);
                                  r.p.n:=false;
                                end;
            TCPU_DECO16:begin
                          r.pc:=r.pc+1;
                          if @self.in_port1<>nil then r.a:=self.in_port1;
                       end;
          end;
      $4c:r.pc:=posicion; //JMP absoluto
      $50:if not(r.p.o_v) then begin  //BVC salta si Overflow false
             if ((r.pc+shortint(numero)) and $ff00)<>(r.pc and $ff00) then self.estados_demas:=self.estados_demas+2
                else self.estados_demas:=self.estados_demas+1;
             r.pc:=r.pc+shortint(numero);
          end;
      $58:begin  //CLI
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.p.int:=false;
            self.after_ei:=true;
          end;
      $60:begin  //RTS
             r.sp:=r.sp+1;
             r.pc:=self.getbyte($100+r.sp);
             r.sp:=r.sp+1;
             r.pc:=r.pc or (self.getbyte($100+r.sp) shl 8);
             r.pc:=r.pc+1;
           end;
      $61,$65,$69,$6d,$71,$75,$79,$7d:begin  //ADC
             numero:=self.getbyte(posicion);
             adc(self.r,numero,self.tipo_cpu);
           end;
      $63,$67,$6f,$73,$77,$7b,$7f:begin //RRA
            tempb:=self.getbyte(posicion);
            self.putbyte(posicion,tempb); // <-- Fallo de la CPU
            if r.p.c then tempw:=tempb or $100
              else tempw:=tempb;
            r.p.c:=(tempb and $1)<>0;
            tempw:=tempw shr 1;
            adc(self.r,tempw,self.tipo_cpu);
            self.putbyte(posicion,tempw and $ff);
          end;
      $66,$6e,$76,$7e:begin //ROR
              tempb:=self.getbyte(posicion);
              self.putbyte(posicion,tempb); // <-- Fallo CPU
              if r.p.c then carry:=$80 else carry:=0;
              r.p.c:=(tempb and $1)<>0;
              tempb:=(tempb shr 1) or carry;
              r.p.z:=(tempb=0);
              r.p.n:=(tempb and $80)<>0;
              self.putbyte(posicion,tempb);
         end;
      $68:begin //PLA
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.sp:=r.sp+1;
            r.a:=self.getbyte($100+r.sp);
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
          end;
      $6a:begin  //ROR A
            self.getbyte(r.pc);  // <-- Fallo CPU
            if r.p.c then carry:=$80 else carry:=0;
            r.p.c:=(r.a and $1)<>0;
            r.a:=(r.a shr 1) or carry;
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
          end;
      $6b:begin  //arr
            r.a:=r.a and self.getbyte(posicion);
            if r.p.c then carry:=$80 else carry:=0;
            r.p.c:=(r.a and $1)<>0;
            r.a:=(r.a shr 1) or carry;
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
          end;
      $6c:begin  //jmp rel
            //abs
            posicion:=self.getbyte(r.pc);
            posicion:=posicion+(self.getbyte(r.pc+1) shl 8);
            r.pc:=self.getbyte(posicion);
            r.pc:=r.pc or (self.getbyte((((posicion+1) and $00FF) or (posicion and $FF00))) shl 8);
          end;
      $70:if r.p.o_v then begin //BVS salta si Overflow true
            if ((r.pc+shortint(numero)) and $ff00)<>(r.pc and $ff00) then self.estados_demas:=self.estados_demas+2
                else self.estados_demas:=self.estados_demas+1;
            r.pc:=r.pc+shortint(numero);
          end;
      $78:begin  //SEI
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.p.int:=true;
            self.after_ei:=true;
          end;
      $81,$85,$8d,$91,$95,$99,$9d:self.putbyte(posicion,r.a); //STA
      $83,$87,$8f,$97:self.putbyte(posicion,r.a and r.x); //sax
      $84,$8c,$94:self.putbyte(posicion,r.y); //STY
      $86,$8e,$96:self.putbyte(posicion,r.x); //STX
      $88:begin  //DEY
             self.getbyte(r.pc);  // <-- Fallo CPU
             r.y:=r.y-1;
             r.p.z:=(r.y=0);
             r.p.n:=(r.y and $80)<>0;
           end;
      $8a:begin //TXA
             self.getbyte(r.pc);  // <-- Fallo CPU
             r.a:=r.x;
             r.p.z:=(r.a=0);
             r.p.n:=(r.a and $80)<>0;
           end;
      $8b:begin //XAA
             r.a:=r.x and self.getbyte(posicion);
             r.p.z:=(r.a=0);
             r.p.n:=(r.a and $80)<>0;
           end;
      $90:if not(r.p.c) then begin  //BCC salta si c false
             if ((r.pc+shortint(numero)) and $ff00)<>(r.pc and $ff00) then self.estados_demas:=self.estados_demas+2
                else self.estados_demas:=self.estados_demas+1;
             r.pc:=r.pc+shortint(numero);
          end;
      $93,$9f:self.putbyte(posicion,r.a and r.x and tempb); //ahx
      $98:begin  //TYA
             self.getbyte(r.pc);  // <-- Fallo CPU
             r.a:=r.y;
             r.p.z:=(r.a=0);
             r.p.n:=(r.a and $80)<>0;
           end;
      $9A:begin  //TXS
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.sp:=r.x;
          end;
      $A0,$a4,$ac,$b4,$bc:begin //LDY
             r.y:=self.getbyte(posicion);
             r.p.z:=(r.y=0);
             r.p.n:=(r.y and $80)<>0;
           end;
      $A1,$a5,$a9,$ad,$b1,$b5,$b9,$bd:begin //LDA
            r.a:=self.getbyte(posicion);
            r.p.z:=(r.a=0);
            r.p.n:=(r.a and $80)<>0;
          end;
      $A2,$a6,$ae,$b6,$be:begin //LDX
             r.x:=self.getbyte(posicion);
             r.p.z:=(r.x=0);
             r.p.n:=(r.x and $80)<>0;
           end;
      $A8:begin  //TAY
             self.getbyte(r.pc);  // <-- Fallo CPU
             r.y:=r.a;
             r.p.z:=(r.y=0);
             r.p.n:=(r.y and $80)<>0;
           end;
      $AA:begin  //TAX
             self.getbyte(r.pc);  // <-- Fallo CPU
             r.x:=r.a;
             r.p.z:=(r.x=0);
             r.p.n:=(r.x and $80)<>0;
           end;
      $B0:if r.p.c then begin  //BCS salta si c true
              if ((r.pc+shortint(numero)) and $ff00)<>(r.pc and $ff00) then self.estados_demas:=self.estados_demas+2
                else self.estados_demas:=self.estados_demas+1;
              r.pc:=r.pc+shortint(numero);
          end;
      $B8:begin  //CLV
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.p.o_v:=false;
          end;
      $BA:begin  //TSX
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.x:=r.sp;
            r.p.z:=(r.x=0);
            r.p.n:=(r.x and $80)<>0;
          end;
      $C0,$C4,$CC:begin //CPY
            tempw:=r.y-self.getbyte(posicion);
            r.p.c:=(tempw and $100)=0;
            r.p.z:=(tempw and $ff)=0;
            r.p.n:=(tempw and $80)<>0;
           end;
      $c1,$c5,$c9,$cd,$d1,$d5,$d9,$dd:begin  //CMA
             tempw:=r.a-self.getbyte(posicion);
             r.p.c:=(tempw and $100)=0;
             r.p.z:=(tempw and $ff)=0;
             r.p.n:=(tempw and $80)<>0;
          end;
      $c3,$cf,$d3,$db,$df:begin //DCP
            tempb:=self.getbyte(posicion);
            self.putbyte(posicion,tempb); // <-- Fallo de la CPU
            tempb:=tempb-1;
            if r.a>=tempb then r.p.c:=true
              else r.p.c:=false;
            r.p.z:=((r.a-tempb) and $ff)=0;
            r.p.n:=((r.a-tempb) and $80)<>0;
            self.putbyte(posicion,tempb);
          end;
      $C6,$ce,$d6,$de:begin   //DEC
            tempb:=self.getbyte(posicion);
            self.putbyte(posicion,tempb); // <-- Fallo CPU
            tempb:=tempb-1;
            r.p.z:=(tempb=0);
            r.p.n:=(tempb and $80)<>0;
            self.putbyte(posicion,tempb);
           end;
      $C8:begin  //INY
             self.getbyte(r.pc);  // <-- Fallo CPU
             r.y:=r.y+1;
             r.p.z:=(r.y=0);
             r.p.n:=(r.y and $80)<>0;
           end;
      $CA:begin  //DEX
             self.getbyte(r.pc);  // <-- Fallo CPU
             r.x:=r.x-1;
             r.p.z:=(r.x=0);
             r.p.n:=(r.x and $80)<>0;
           end;
      $D0:if not(r.p.z) then begin   //BNE si z false
              if ((r.pc+shortint(numero)) and $ff00)<>(r.pc and $ff00) then self.estados_demas:=self.estados_demas+2
                else self.estados_demas:=self.estados_demas+1;
              r.pc:=r.pc+shortint(numero);
          end;
      $D8:begin  //CLD
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.p.dec:=false;
          end;
      $E0,$e4,$ec:begin  //CPX
              tempw:=r.x-self.getbyte(posicion);
              r.p.c:=(tempw and $100)=0;
              r.p.z:=(tempw and $ff)=0;
              r.p.n:=(tempw and $80)<>0;
          end;
      $E1,$e5,$e9,$eb,$ed,$f1,$f5,$f9,$fd:begin  //SBC
              numero:=self.getbyte(posicion);
              sbc(self.r,numero,self.tipo_cpu);
          end;
      $e3,$ef,$f3,$fb,$ff:begin  //ISB
             tempb:=self.getbyte(posicion);
             self.putbyte(posicion,tempb);
             tempb:=tempb+1;
             sbc(self.r,tempb,self.tipo_cpu);
             self.putbyte(posicion,tempb);
          end;
      $E6,$ee,$F6,$fe:begin  //INC
             tempb:=self.getbyte(posicion);
             self.putbyte(posicion,tempb);  // <-- Fallo CPU
             tempb:=tempb+1;
             r.p.z:=(tempb=0);
             r.p.n:=(tempb and $80)<>0;
             self.putbyte(posicion,tempb);
           end;
      $E8:begin  //INX
             self.getbyte(r.pc);  // <-- Fallo CPU
             r.x:=r.x+1;
             r.p.z:=(r.x=0);
             r.p.n:=(r.x and $80)<>0;
           end;
      $F0:if r.p.z then begin  //BEQ salta si z true
              if ((r.pc+shortint(numero)) and $ff00)<>(r.pc and $ff00) then self.estados_demas:=self.estados_demas+2
                else self.estados_demas:=self.estados_demas+1;
              r.pc:=r.pc+shortint(numero);
          end;
      $F8:begin  //SED
            self.getbyte(r.pc);  // <-- Fallo CPU
            r.p.dec:=true;
          end;
      else
        MessageDlg('CPU: '+inttohex(self.numero_cpu,1)+' Instruccion: $'+inttohex(instruccion,2)+' desconocida. PC='+inttohex(r.old_pc,4), mtInformation,[mbOk], 0)
end; //del case!!
tempw:=estados_t[self.tipo_cpu and $1,instruccion]+self.estados_demas;
self.contador:=self.contador+tempw;
update_timer(tempw,self.numero_cpu);
end; //del while!!
end;

end.
