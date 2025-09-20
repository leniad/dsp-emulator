unit m6805;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     dialogs,sysutils,timer_engine,main_engine,cpu_misc;
const
  tipo_m6805=0;
  tipo_m68705=1;
  tipo_hd63705=2;

type
        band_m6805=record
                h,i,n,z,c:boolean;
        end;
        reg_m6805=record
                pc:word;
                sp,sp_mask,sp_low:word;
                cc:band_m6805;
                a,x:byte;
        end;
        preg_m6805=^reg_m6805;
        cpu_m6805=class(cpu_class)
            constructor create(clock:dword;frames_div:word;tipo_cpu:byte);
            destructor free;
          public
            procedure run(maximo:single);
            procedure reset;
            procedure irq_request(irq,valor:byte);
          private
            r:preg_m6805;
            pedir_irq:array[0..9] of byte;
            irq_pending:boolean;
            tipo_cpu:byte;
            function dame_pila:byte;
            procedure pon_pila(valor:byte);
            //procedure putword(direccion:word;valor:word);
            function getword(direccion:word):word;
            procedure pushbyte(valor:byte);
            procedure pushword(valor:word);
            function pullbyte:byte;
            function pullword:word;
        end;
 var
    m6805_0:cpu_m6805;

implementation
const
  dir_mode_6805:array[0..$ff] of byte=(
 //   0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,  //00
      7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,  //10
      3, 0, 3, 0, 3, 3, 3, 3, 0, 0, 3, 3, 0, 0, 3, 3,  //20
      0, 0, 0, 0, 0, 0, 7, 0, 7, 7, 7, 0, 7, 7, 0, 4,  //30
      1, 0, 0, 0, 1, 0, 0, 1, 1, 1, 1, 0, 1, 1, 0, 1,  //40
      0, 0, 0, 0, 1, 0, 0, 0, 1, 1, 1, 0, 1, 1, 0, 1,  //50
      0, 0, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 6, 0, 0, 6,  //60
      0, 0, 0, 0, 0, 0, 9, 0, 0, 0, 0, 0, 0, 0, 0, 0,  //70
      1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,  //80
      0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1,  //90
      3, 3, 0, 3, 3, 0, 3, 0, 3, 0, 0, 3, 0, 3, 3, 0,  //a0
      4, 4, 0, 0, 4, 0, 7, 4, 0, 4, 7, 7, 4, 4, 7, 4,  //b0
      8, 0, 0, 0, 0, 0, 8, 2, 8, 0, 8, 8, 2, 2, 8, 2,  //c0
      0, 5, 5, 0, 5, 0, 5, 5, 5, 5, 0, 5, 5, 0, 0, 0,  //d0
      0, 0, 0, 0, 0, 0, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0,  //e0
      0, 0, 0, 0, 0, 0, 9, 9, 0, 0, 0, 9, 0, 0, 0, 0); //f0

  ciclos_6805:array[0..$ff] of byte=(
      // 0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F */
        10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,
         7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
         4, 0, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
         6, 0, 0, 6, 6, 0, 6, 6, 6, 6, 6, 6, 0, 6, 6, 0,
         4, 0, 0, 4, 4, 0, 4, 4, 4, 4, 4, 0, 4, 4, 0, 4,
         4, 0, 0, 4, 4, 0, 4, 4, 4, 4, 4, 0, 4, 4, 0, 4,
         7, 0, 0, 7, 7, 0, 7, 7, 7, 7, 7, 0, 7, 7, 0, 7,
         6, 0, 0, 6, 6, 0, 6, 6, 6, 6, 6, 0, 6, 6, 0, 6,
         9, 6, 0,11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
         0, 0, 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 2, 2, 0, 2,
         2, 2, 2, 2, 2, 2, 2, 0, 2, 2, 2, 2, 0, 8, 2, 0,
         4, 4, 4, 4, 4, 4, 4, 5, 4, 4, 4, 4, 3, 7, 4, 5,
         5, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 4, 8, 5, 6,
         6, 6, 6, 6, 6, 6, 6, 7, 6, 6, 6, 6, 5, 9, 6, 7,
         5, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5, 5, 4, 8, 5, 6,
         4, 4, 4, 4, 4, 4, 4, 5, 4, 4, 4, 4, 3, 7, 4, 5);

constructor cpu_m6805.create(clock:dword;frames_div:word;tipo_cpu:byte);
begin
getmem(self.r,sizeof(reg_m6805));
fillchar(self.r^,sizeof(reg_m6805),0);
self.numero_cpu:=cpu_main_init(clock div 4);
self.clock:=clock div 4;
self.tipo_cpu:=tipo_cpu;
self.tframes:=(clock/4/frames_div)/llamadas_maquina.fps_max;
end;

destructor cpu_m6805.free;
begin
freemem(self.r);
end;

procedure cpu_m6805.reset;
var
  f:byte;
begin
r.cc.h:=false;
r.cc.i:=true;
r.cc.n:=false;
r.cc.z:=false;
r.cc.c:=false;
self.opcode:=false;
r.pc:=self.getword($fffe);
r.a:=0;
r.x:=0;
self.contador:=0;
r.sp:=$7f;
r.sp_mask:=$7f;
r.sp_low:=$60;
self.change_nmi(CLEAR_LINE);
self.change_reset(CLEAR_LINE);
for f:=0 to 9 do self.pedir_irq[f]:=CLEAR_LINE;
self.irq_pending:=false;
end;

procedure cpu_m6805.irq_request(irq,valor:byte);
begin
self.pedir_irq[irq]:=valor;
if valor<>CLEAR_LINE then self.irq_pending:=true;
end;

function cpu_m6805.dame_pila:byte;
var
  temp:byte;
begin
  temp:=0;
  if r.cc.h then temp:=temp or $10;
  if r.cc.i then temp:=temp or $8;
  if r.cc.n then temp:=temp or 4;
  if r.cc.z then temp:=temp or 2;
  if r.cc.c then temp:=temp or 1;
  dame_pila:=temp;
end;

procedure cpu_m6805.pon_pila(valor:byte);
begin
  r.cc.h:=(valor and $10)<>0;
  r.cc.i:=(valor and $8)<>0;
  r.cc.n:=(valor and 4)<>0;
  r.cc.z:=(valor and 2)<>0;
  r.cc.c:=(valor and 1)<>0;
end;

{procedure cpu_m6805.putword(direccion:word;valor:word);
begin
self.putbyte(direccion,valor shr 8);
self.putbyte(direccion+1,valor and $FF);
end;}

function cpu_m6805.getword(direccion:word):word;
var
  valor:word;
begin
valor:=self.getbyte(direccion) shl 8;
valor:=valor+(self.getbyte(direccion+1));
getword:=valor;
end;

procedure cpu_m6805.pushbyte(valor:byte);
begin
  self.putbyte(r.sp,valor);
  r.sp:=r.sp-1;
  if r.sp<r.sp_low then r.sp:=r.sp_mask;
end;

procedure cpu_m6805.pushword(valor:word);
begin
  self.putbyte(r.sp,valor and $ff);
  r.sp:=r.sp-1;
  if r.sp<r.sp_low then r.sp:=r.sp_mask;
  self.putbyte(r.sp,valor shr 8);
  r.sp:=r.sp-1;
  if r.sp<r.sp_low then r.sp:=r.sp_mask;
end;

function cpu_m6805.pullbyte:byte;
begin
  r.sp:=r.sp+1;
  if r.sp>r.sp_mask then r.sp:=r.sp_low;
  pullbyte:=self.getbyte(r.sp);
end;

function cpu_m6805.pullword:word;
var
  res:word;
begin
  r.sp:=r.sp+1;
  if r.sp>r.sp_mask then r.sp:=r.sp_low;
  res:=self.getbyte(r.sp) shl 8;
  r.sp:=r.sp+1;
  if r.sp>r.sp_mask then r.sp:=r.sp_low;
  res:=res+byte(self.getbyte(r.sp));
  pullword:=res;
end;

procedure cpu_m6805.run(maximo:single);
var
  instruccion,numero,tempb:byte;
  posicion,tempw:word;
begin
self.contador:=0;
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
self.estados_demas:=0;
if self.tipo_cpu=tipo_m68705 then begin
  if (self.irq_pending) then begin
    if not(r.cc.i) then begin
        self.pushword(r.pc);
        self.pushbyte(r.x);
        self.pushbyte(r.a);
        self.pushbyte(self.dame_pila);
        r.cc.i:=true;
        if self.irq_pending then begin  //Req IRQ
          self.irq_pending:=false;
          r.pc:=self.getword($fffa);
        end;{ else begin
          if r.pedir_irq[1] then begin //Timer IRQ
             r.pedir_irq[1]:=false;
             r.pc:=getword($fff8,ll);
          end;
        end; }
        self.estados_demas:=11;
    end;
  end;
end else MessageDlg('IRQ No implementadas '+inttostr(self.numero_cpu), mtInformation,[mbOk], 0);
self.opcode:=true;
instruccion:=self.getbyte(r.pc);
r.pc:=r.pc+1;
self.opcode:=false;
//tipo de paginacion
case dir_mode_6805[instruccion] of
    0:MessageDlg('Num CPU '+inttostr(self.numero_cpu)+' instruccion: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(r.pc-1,10), mtInformation,[mbOk], 0);
    1:;  //inerent
    2:begin //extended
        posicion:=self.getword(r.pc);
        r.pc:=r.pc+2;
        numero:=self.getbyte(posicion);
      end;
    3:begin //immbyte
        numero:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
      end;
    4:begin //direct
        posicion:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
        numero:=self.getbyte(posicion);
      end;
    5:begin  //idx 2 byte
        posicion:=self.getword(r.pc);
        r.pc:=r.pc+2;
        posicion:=posicion+r.x;
        numero:=self.getbyte(posicion);
      end;
    6:begin  //IDX1BYTE
        posicion:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
        posicion:=posicion+r.x;
        numero:=self.getbyte(posicion);
      end;
    7:begin //dirbyte
        posicion:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
        numero:=self.getbyte(posicion);
      end;
    8:begin //extbyte
        posicion:=self.getword(r.pc);
        r.pc:=r.pc+2;
        numero:=self.getbyte(posicion);
      end;
    9:begin
        posicion:=r.x; //idxbyte
        numero:=self.getbyte(posicion);
       end;
end;
case instruccion of
  $00,$02,$04,$06,$08,$0a,$0c,$0e:begin //brset
        tempb:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
	      r.cc.c:=false;
        if ((numero and (1 shl ((instruccion shr 1) and $7)))<>0) then begin
          r.cc.c:=true;
          r.pc:=r.pc+shortint(tempb);
        end;
      end;
  $01,$03,$05,$07,$09,$0b,$0d,$0f:begin //brclr
        tempb:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
	      r.cc.c:=true;
        if ((numero and (1 shl ((instruccion shr 1) and $7)))=0) then begin
          r.cc.c:=false;
          r.pc:=r.pc+shortint(tempb);
        end;
      end;
  $10,$12,$14,$16,$18,$1a,$1c,$1e:begin //bset
        tempb:=numero or (1 shl ((instruccion shr 1) and $7));
        self.putbyte(posicion,tempb);
      end;
  $11,$13,$15,$17,$19,$1b,$1d,$1f:begin //bclr
        tempb:=numero and not(1 shl ((instruccion shr 1) and $7));
        self.putbyte(posicion,tempb);
      end;
  $20:r.pc:=r.pc+shortint(numero); //bra
  $22:if (not(r.cc.z) and not(r.cc.c)) then r.pc:=r.pc+shortint(numero); //bhi
  $24:if not(r.cc.c) then r.pc:=r.pc+shortint(numero); //bcc
  $25:if r.cc.c then r.pc:=r.pc+shortint(numero); //bcs
  $26:if not(r.cc.z) then r.pc:=r.pc+shortint(numero); //bne
  $27:if r.cc.z then r.pc:=r.pc+shortint(numero); //beq
  $2a:if not(r.cc.n) then r.pc:=r.pc+shortint(numero); //bpl
  $2b:if r.cc.n then r.pc:=r.pc+shortint(numero); //bmi
  $2e:if self.tipo_cpu=tipo_hd63705 then begin //bil
        if self.pedir_nmi<>CLEAR_LINE then r.pc:=r.pc+shortint(numero);
      end else begin
        if self.pedir_irq[0]<>CLEAR_LINE then r.pc:=r.pc+shortint(numero);
      end;
  $2f:if self.tipo_cpu=tipo_hd63705 then begin //bhi
        if self.pedir_nmi=CLEAR_LINE then r.pc:=r.pc+shortint(numero);
      end else begin
        if self.pedir_irq[0]=CLEAR_LINE then r.pc:=r.pc+shortint(numero);
      end;
  $36,$66,$76:begin //ror
        if r.cc.c then tempb:=$80
          else tempb:=0;
        r.cc.c:=(numero and $01)<>0;
        tempb:=tempb or (numero shr 1);
        r.cc.z:=(tempb=0);
        r.cc.n:=(tempb and $80)<>0;
        self.putbyte(posicion,tempb);
      end;
  $38:begin //asl
        tempw:=numero shl 1;
        r.cc.z:=(tempw=0);
        r.cc.n:=(tempw and $80)<>0;
        r.cc.c:=(tempw and $100)<>0;
        self.putbyte(posicion,tempw and $ff);
      end;
  $39:begin //rol
        if r.cc.c then tempw:=$01 or (numero shl 1)
          else tempw:=numero shl 1;
        r.cc.z:=(tempw=0);
        r.cc.n:=(tempw and $80)<>0;
        r.cc.c:=(tempw and $100)<>0;
        self.putbyte(posicion,tempw and $ff);
      end;
  $3a:begin //dec
        numero:=numero-1;
        r.cc.z:=(numero=0);
        r.cc.n:=(numero and $80)<>0;
        self.putbyte(posicion,numero);
      end;
  $3c,$6c:begin //inc
        numero:=numero+1;
        r.cc.z:=(numero=0);
        r.cc.n:=(numero and $80)<>0;
        self.putbyte(posicion,numero);
      end;
  $3d:begin //tst
        r.cc.z:=(numero=0);
        r.cc.n:=(numero and $80)<>0;
      end;
  $3f,$6f:begin //clr
        r.cc.n:=false;
        r.cc.c:=false;
        r.cc.z:=true;
        self.putbyte(posicion,0);
      end;
  $40:begin //nega
        tempw:=-r.a;
        r.cc.z:=(tempw=0);
        r.cc.n:=(tempw and $80)<>0;
        r.cc.c:=(tempw and $100)<>0;
        r.a:=tempw;
      end;
  $44:begin //lsra
        r.cc.n:=false;
        r.cc.c:=(r.a and $01)<>0;
        r.a:=r.a shr 1;
        r.cc.z:=(r.a=0);
      end;
  $47:begin  //asra
	      r.cc.c:=(r.a and $01)<>0;
        r.a:=(r.a and $80) or (r.a shr 1);
        r.cc.z:=(r.a=0);
        r.cc.n:=(r.a and $80)<>0;
      end;
  $48:begin //lsla
        tempw:=r.a shl 1;
        r.cc.z:=(tempw=0);
        r.cc.n:=(tempw and $80)<>0;
        r.cc.c:=(tempw and $100)<>0;
        r.a:=tempw;
      end;
  $49:begin //rola
        if r.cc.c then tempw:=$01 or (r.a shl 1)
          else tempw:=r.a shl 1;
        r.cc.z:=(tempw=0);
        r.cc.n:=(tempw and $80)<>0;
        r.cc.c:=(tempw and $100)<>0;
        r.a:=tempw;
      end;
  $4a:begin //deca
        r.a:=r.a-1;
        r.cc.z:=(r.a=0);
        r.cc.n:=(r.a and $80)<>0;
      end;
  $4c:begin  //inca
        r.a:=r.a+1;
        r.cc.z:=(r.a=0);
        r.cc.n:=(r.a and $80)<>0;
      end;
  $4d:begin  //tsta
        r.cc.z:=(r.a=0);
        r.cc.n:=(r.a and $80)<>0;
      end;
  $4f:begin //clra
        r.cc.n:=false;
        r.cc.z:=true;
        r.a:=0;
      end;
  $54:begin //lsrx
        r.cc.n:=false;
        r.cc.c:=(r.x and $01)<>0;
        r.x:=r.x shr 1;
        r.cc.z:=(r.x=0);
      end;
  $58:begin //aslx
	      tempw:=r.x shl 1;
        r.cc.n:=(tempw and $80)<>0;
        r.cc.z:=(tempw=0);
        r.cc.c:=(tempw and $100)<>0;
        r.x:=tempw;
      end;
  $59:begin //rolx
        if r.cc.c then tempw:=$01 or (r.x shl 1)
          else tempw:=r.x shl 1;
        r.cc.n:=(tempw and $80)<>0;
        r.cc.z:=(tempw=0);
        r.cc.c:=(tempw and $100)<>0;
        r.x:=tempw;
      end;
  $5a:begin  //decx
        r.x:=r.x-1;
        r.cc.z:=(r.x=0);
        r.cc.n:=(r.x and $80)<>0;
      end;
  $5c:begin  //incx
        r.x:=r.x+1;
        r.cc.z:=(r.x=0);
        r.cc.n:=(r.x and $80)<>0;
      end;
  $5d:begin //tstx
        r.cc.z:=(r.x=0);
        r.cc.n:=(r.x and $80)<>0;
      end;
  $5f:begin //clrx
        r.x:=0;
        r.cc.z:=true;
        r.cc.n:=false;
        r.cc.c:=false;
      end;
  $80:begin //rti
        self.pon_pila(self.pullbyte);
        r.a:=self.pullbyte;
        r.x:=self.pullbyte;
        r.pc:=self.pullword;
      end;
  $81:r.pc:=self.pullword;  //rts
  $97:r.x:=r.a; //tax
  $98:r.cc.c:=false; //clc
  $99:r.cc.c:=true; //sec
  $9a:r.cc.i:=false; //cli
  $9b:r.cc.i:=true; //sei
  $9c:r.sp:=r.sp_mask;//rsp
  $9d:; //nop
  $9f:r.a:=r.x; //txa
  $a0,$b0,$c0:begin //suba
	      tempw:=r.a-numero;
        r.cc.z:=(tempw=0);
        r.cc.c:=(tempw and $100)<>0;
        r.cc.n:=(tempw and $80)<>0;
        r.a:=tempw;
      end;
  $a1,$b1,$d1:begin //cmpa
        tempw:=r.a-numero;
        r.cc.z:=(tempw=0);
        r.cc.c:=(tempw and $100)<>0;
        r.cc.n:=(tempw and $80)<>0;
      end;
  $d2:begin //sbca
        if r.cc.c then tempw:=r.a-numero-1
          else tempw:=r.a-numero;
        r.cc.z:=(tempw=0);
        r.cc.c:=(tempw and $100)<>0;
        r.cc.n:=(tempw and $80)<>0;
	      r.a:=tempw;
      end;
  $a3:begin //cmpx
        tempw:=r.x-numero;
        r.cc.z:=(tempw=0);
        r.cc.c:=(tempw and $100)<>0;
        r.cc.n:=(tempw and $80)<>0;
      end;
  $a4,$b4,$d4:begin //anda
        r.a:=r.a and numero;
        r.cc.z:=(r.a=0);
        r.cc.n:=(r.a and $80)<>0;
      end;
  $a6,$b6,$c6,$e6,$d6,$f6:begin //lda
        r.a:=numero;
        r.cc.z:=(numero=0);
        r.cc.n:=(numero and $80)<>0;
      end;
  $b7,$c7,$d7,$e7,$f7:begin //sta
        r.cc.z:=(r.a=0);
        r.cc.n:=(r.a and $80)<>0;
        self.putbyte(posicion,r.a);
      end;
  $a8,$c8,$d8:begin //eora
        r.a:=r.a xor numero;
        r.cc.z:=(r.a=0);
        r.cc.n:=(r.a and $80)<>0;
      end;
  $b9,$d9:begin //adca
        if r.cc.c then tempw:=r.a+numero+$01
          else tempw:=r.a+numero;
        r.cc.z:=(tempw=0);
        r.cc.n:=(tempw and $80)<>0;
        r.cc.c:=(tempw and $100)<>0;
        r.cc.h:=((r.a xor numero xor tempw) and $10)<>0;
        r.a:=tempw;
      end;
  $ca,$ba:begin //ora
        r.a:=r.a or numero;
        r.cc.z:=(r.a=0);
        r.cc.n:=(r.a and $80)<>0;
      end;
  $ab,$bb,$cb,$db,$fb:begin //adda
	      tempw:=r.a+numero;
        r.cc.z:=(tempw=0);
        r.cc.n:=(tempw and $80)<>0;
        r.cc.c:=(tempw and $100)<>0;
        r.cc.h:=((r.a xor numero xor tempw) and $10)<>0;
	      r.a:=tempw;
      end;
  $bc,$cc,$dc:r.pc:=posicion; //jmp
  $ad:begin //bsr
        self.pushword(r.pc);
        r.pc:=r.pc+shortint(numero);
      end;
  $bd,$cd:begin //jsr
        self.pushword(r.pc);
        r.pc:=posicion;
      end;
  $ae,$be,$ce:begin //ldx
        r.x:=numero;
        r.cc.z:=(numero=0);
        r.cc.n:=(numero and $80)<>0;
      end;
  $bf,$cf:begin //stx
        r.cc.z:=(r.x=0);
        r.cc.n:=(r.x and $80)<>0;
        self.putbyte(posicion,r.x);
      end;
end; //del case
self.contador:=self.contador+ciclos_6805[instruccion]+self.estados_demas;
timers.update(ciclos_6805[instruccion]+self.estados_demas,self.numero_cpu);
end; //del while
end;

end.
