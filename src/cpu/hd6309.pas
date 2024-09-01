unit hd6309;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,dialogs,cpu_misc,sysutils,timer_engine;

type
        //MD_EM	$01	 Execution mode
        //MD_FM	$02  FIRQ mode
        //MD_II	$40	 Illegal instruction
        //MD_DZ	$80	 Division by zero
        band_hd6309=record
                md_em,md_fm,md_ii,md_dz:boolean;
        end;
        band_m6809=record
                e,f,h,i,n,z,v,c:boolean;
        end;
        pband_m6809=^band_m6809;
        parejas_hd6309=record
          case byte of
             0:(b,a,f,e:byte);
             1:(d,w:word);
             2:(l:dword);
        end;
        reg_hd6309=record
                q:parejas_hd6309;
                pc,old_pc,u,s,x,y:word;
                dp:byte;
                cc:band_m6809;
                cc2:band_hd6309;
                cwai,sync,pila_init:boolean;
        end;
        preg_hd6309=^reg_hd6309;
        cpu_hd6309=class(cpu_class)
                constructor create(clock:dword;frames_div:word;tipo:byte);
                destructor free;
            public
                procedure reset;
                procedure run(maximo:single);
                procedure change_firq(estado:byte);
            private
                r:preg_hd6309;
                procedure putword(direccion:word;valor:word);
                function getword(direccion:word):word;
                function dame_pila:byte;
                procedure pon_pila(valor:byte);
                //Llamadas IRQ
                function call_nmi:byte;
                function call_irq:byte;
                function call_firq:byte;
                //Misc Func
                function get_indexed:word;
                procedure trf(valor:byte);
                procedure trf_ex(valor:byte);
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
    hd6309_0,hd6309_1:cpu_hd6309;

const
    TCPU_HD6309=0;
    TCPU_HD6309E=1;

implementation

const
    estados_t:array[0..255] of byte=(
    //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
      6, 6, 6, 6, 6, 0, 6, 6, 6, 6, 6, 0, 6, 3, 3, 6,  // 0 Direct 2T MODO EA *
      0, 0, 2, 4, 0, 0, 4, 9, 0, 2, 3, 0, 3, 2, 8, 6,  // 10 *
      3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,  // 20 Branch *
      2, 2, 2, 2, 5, 4, 5, 4, 0, 4, 3, 4,16,11, 0, 0,  // 30 *
      2, 0, 0, 2, 2, 0, 2, 2, 2, 2, 1, 0, 1, 2, 0, 1,  // 40 reg A MODO A *
      2, 0, 0, 2, 2, 0, 2, 2, 2, 2, 1, 0, 1, 2, 0, 1,  // 50 reg B MODO B *
      4, 0, 0, 4, 4, 0, 4, 4, 4, 4, 4, 0, 4, 4, 1, 4,  // 60 Indexed MODO EA *
      7, 0, 0, 7, 7, 0, 7, 7, 7, 7, 7, 0, 7, 7, 4, 7,  // 70 Extended 3T MODO EA *
      2, 2, 2, 5, 2, 2, 2, 0, 2, 2, 2, 2, 5, 7, 4, 0,  // 80 MODO IMM *
      4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 4, 7, 7, 6, 6,  // 90 Direct 2T MODO EA *
      2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 3, 5, 3, 3,  // A0 Indexed MODO EA *
      5, 5, 5, 8, 5, 5, 5, 5, 5, 5, 5, 5, 8, 8, 7, 7,  // B0 Extended 3T MODO EA *
      2, 2, 2, 5, 2, 2, 2, 0, 2, 2, 2, 2, 4, 0, 4, 0,  // C0 MODO IMM *
      4, 4, 4, 7, 4, 4, 4, 4, 4, 4, 4, 4, 6, 6, 6, 6,  // D0 Direct 2T MODO EA
      2, 2, 2, 4, 2, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3,  // E0 Indexed MODO EA
      5, 5, 5, 8, 5, 5, 5, 5, 5, 5, 5, 5, 7, 7, 7, 7); // F0 Extended 3T MODO EA}

    paginacion:array[0..255] of byte=(
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
        1, 1, 1, 1, 1,$f, 1, 1, 1, 1, 1,$f, 1, 1, 1, 1,  //00
        0, 0, 0, 0,$f,$f, 3, 3,$f, 0, 2,$f, 2, 0, 2, 2,  //10
        2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,  //20
        4, 4, 4, 4, 2, 2, 2, 2,$f, 0, 0, 0, 2, 0,$f,$f,  //30
        0,$f,$f, 0, 0,$f, 0, 0, 0, 0, 0,$f, 0, 0,$f, 0,  //40
        0,$f,$f, 0, 0,$f, 0, 0, 0, 0, 0,$f, 0, 0,$f, 0,  //50
        4,$f,$f, 4, 4,$f, 4, 4, 4, 4, 4,$f, 4, 4, 4, 4,  //60
        3,$f,$f, 3, 3,$f, 3, 3, 3, 3, 3,$f, 3, 3, 3, 3,  //70
        2, 2, 2, 3, 2, 2, 2,$f, 2, 2, 2, 2, 3, 2, 3,$f,  //80
        5, 5, 5, 8, 5, 5, 5, 1, 5, 5, 5, 5, 8, 1, 8, 1,  //90
        6, 6, 6, 9, 6, 6, 6, 4, 6, 6, 6, 6, 9, 4, 9, 4,  //a0
        7, 7, 7,$a, 7, 7, 7, 3, 7, 7, 7, 7,$a, 3,$a, 3,  //b0
        2, 2, 2, 3, 2, 2, 2,$f, 2, 2, 2, 2, 3,$f, 3,$f,  //c0
        5, 5, 5, 8, 5, 5, 5, 1, 5, 5, 5, 5, 8, 1, 8, 1,  //d0
        6, 6, 6, 9, 6, 6, 6, 4, 6, 6, 6, 6, 9, 4, 9, 4,  //e0
        7, 7, 7,$a, 7, 7, 7, 3, 7, 7, 7, 7,$a, 3,$a, 3); //f0

    hd6309t_1X:array[0..255] of byte=(
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f  Instrucciones $10 (+1)
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 0
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 10
        0, 0, 5, 5, 5, 5, 5, 5, 0, 0, 5, 5, 5, 5, 5, 5, // 20
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 30
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 40
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 50
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 60
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, // 70
        0, 0, 0, 5, 0, 0, 0, 0, 0, 0, 0, 0, 5, 0, 4, 0, // 80
        0, 0, 0, 7, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 6, 6, // 90
        0, 0, 0, 5, 0, 0, 4, 0, 0, 0, 0, 0, 5, 0, 4, 4, // a0
        0, 0, 0, 8, 0, 0, 0, 0, 0, 0, 0, 0, 8, 0, 7, 7, // b0
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 0, // c0
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 6, 6, // d0
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4, 4, // e0
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 7);// f0

    pag_1X:array[0..255] of byte=(
      //0 1 2 3 4 5 6 7 8 9 a b c d e f
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //00
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //10
        0,0,3,3,3,3,3,3,0,0,3,3,3,3,3,3,  //20
        0,0,0,0,0,0,0,0,0,0,0,0,8,8,0,0,  //30
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //40
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //50
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //60
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //70
        0,0,0,3,0,0,0,0,0,0,0,0,3,0,3,0,  //80
        0,0,0,5,0,0,0,0,0,0,0,0,5,0,5,1,  //90
        0,0,0,6,0,0,6,0,0,0,0,0,6,0,6,4,  //a0
        0,0,0,7,0,0,0,0,0,0,0,0,7,0,7,3,  //b0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,  //c0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,1,  //d0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,4,  //e0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,3); //f0

constructor cpu_hd6309.create(clock:dword;frames_div:word;tipo:byte);
begin
getmem(self.r,sizeof(reg_hd6309));
fillchar(self.r^,sizeof(reg_hd6309),0);
case tipo of
  TCPU_HD6309:clock:=clock div 4;
  TCPU_HD6309E:;
end;
self.numero_cpu:=cpu_main_init(clock);
self.clock:=clock;
self.tframes:=(clock/frames_div)/llamadas_maquina.fps_max;
end;

destructor cpu_hd6309.free;
begin
freemem(self.r);
end;

procedure cpu_hd6309.putword(direccion:word;valor:word);
begin
self.putbyte(direccion,valor shr 8);
self.putbyte(direccion+1,valor and $ff);
end;

function cpu_hd6309.getword(direccion:word):word;
var
  valor:word;
begin
valor:=self.getbyte(direccion) shl 8;
valor:=valor+(self.getbyte(direccion+1));
getword:=valor;
end;

function cpu_hd6309.dame_pila:byte;
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

procedure cpu_hd6309.pon_pila(valor:byte);
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

procedure cpu_hd6309.reset;
begin
self.opcode:=false;
r.pc:=self.getword($FFFE);
r.q.l:=0;
r.x:=0;
r.y:=0;
self.contador:=0;
r.u:=0;
r.s:=0;
r.dp:=0;
self.pon_pila($50);
self.r.cc2.md_em:=false;
self.r.cc2.md_fm:=false;
self.r.cc2.md_ii:=false;
self.r.cc2.md_dz:=false;
self.change_nmi(CLEAR_LINE);
self.change_irq(CLEAR_LINE);
self.change_firq(CLEAR_LINE);
r.cwai:=false;
r.sync:=false;
r.pila_init:=false;
end;

procedure cpu_hd6309.change_firq(estado:byte);
begin
  self.pedir_firq:=estado
end;

procedure cpu_hd6309.push_s(reg:byte);
begin
r.s:=r.s-1;
self.putbyte(r.s,reg);
end;

function cpu_hd6309.pop_s:byte;
begin
pop_s:=self.getbyte(r.s);
r.s:=r.s+1;
end;

procedure cpu_hd6309.push_sw(reg:word);
begin
r.s:=r.s-2;
self.putbyte(r.s+1,reg and $FF);
self.putbyte(r.s,(reg shr 8));
end;

function cpu_hd6309.pop_sw:word;
var
  temp:word;
begin
temp:=self.getbyte(r.s) shl 8;
temp:=temp or self.getbyte(r.s+1);
r.s:=r.s+2;
pop_sw:=temp;
end;

procedure cpu_hd6309.push_u(reg:byte);
begin
r.u:=r.u-1;
self.putbyte(r.u,reg);
end;

function cpu_hd6309.pop_u:byte;
begin
pop_u:=self.getbyte(r.u);
r.u:=r.u+1;
end;

procedure cpu_hd6309.push_uw(reg:word);
begin
r.u:=r.u-2;
self.putbyte(r.u+1,reg and $FF);
self.putbyte(r.u,(reg shr 8));
end;

function cpu_hd6309.pop_uw:word;
var
  temp:word;
begin
temp:=self.getbyte(r.u) shl 8;
temp:=temp or self.getbyte(r.u+1);
r.u:=r.u+2;
pop_uw:=temp;
end;

function cpu_hd6309.call_nmi:byte;
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
  self.push_s(r.q.b);
  self.push_s(r.q.a);
  r.cc.e:=true;
  self.push_s(self.dame_pila);
  call_nmi:=19;
end;
r.cc.i:=true;
r.cc.f:=true;
r.pc:=self.getword($FFFC);
if (self.pedir_nmi=PULSE_LINE) then self.pedir_nmi:=CLEAR_LINE;
if (self.pedir_nmi=ASSERT_LINE) then self.nmi_state:=ASSERT_LINE;
end;

function cpu_hd6309.call_irq:byte;
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
  self.push_s(r.q.b);
  self.push_s(r.q.a);
  r.cc.e:=true;
  self.push_s(self.dame_pila);
  call_irq:=19;
end;
r.pc:=self.getword($FFF8);
r.cc.i:=true;
if self.pedir_irq=HOLD_LINE then self.pedir_irq:=CLEAR_LINE;
end;

function cpu_hd6309.call_firq:byte;
begin
if r.cwai then begin
  r.cwai:=false;
  call_firq:=6;
end else begin
  r.cc.e:=false;
  self.push_sw(r.pc);
  self.push_s(self.dame_pila);
  call_firq:=10;
end;
r.cc.f:=true;
r.cc.i:=true;
r.pc:=self.getword($FFF6);
if self.pedir_firq=HOLD_LINE then self.pedir_firq:=CLEAR_LINE;
end;

function cpu_hd6309.get_indexed:word;
var
  iindexed,temp:byte;
  origen:pword;
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
          direccion:=origen^;
          origen^:=origen^+1;
          self.estados_demas:=self.estados_demas+3+1;
      end;
      1:begin  //reg++
          direccion:=origen^;
          origen^:=origen^+2;
          self.estados_demas:=self.estados_demas+4+1;
      end;
      2:begin  //-reg
          origen^:=origen^-1;
          direccion:=origen^;
          self.estados_demas:=self.estados_demas+3+1;
      end;
      3:begin //--reg
          origen^:=origen^-2;
          direccion:=origen^;
          self.estados_demas:=self.estados_demas+4+1;
      end;
      4:begin // =
          direccion:=origen^;
          self.estados_demas:=self.estados_demas+1+1;
        end;
      5:begin //reg + r.q.b
          direccion:=origen^+shortint(r.q.b);
          self.estados_demas:=self.estados_demas+2+1;
        end;
      6:begin // reg + r.d.a
          direccion:=origen^+shortint(r.q.a);
          self.estados_demas:=self.estados_demas+2+1;
        end;
      7:MessageDlg('Indexed 7 desconocido. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
      8:begin  //reg + deplazamiento 8bits
          temp:=self.getbyte(r.pc);
          r.pc:=r.pc+1;
          direccion:=origen^+shortint(temp);
          self.estados_demas:=self.estados_demas+2+1;
      end;
      9:begin  //reg + deplazamiento 16bits
          temp2:=self.getword(r.pc);
          r.pc:=r.pc+2;
          direccion:=origen^+smallint(temp2);
          self.estados_demas:=self.estados_demas+5+1;
      end;
      $a:MessageDlg('Indexed $a desconocido. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
      $b:begin //reg + r.d.w
          direccion:=origen^+smallint(r.q.d);
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
  if (iindexed and $10)=0 then direccion:=origen^+temp
    else direccion:=origen^-(16-temp);
  self.estados_demas:=self.estados_demas+2+1;
end;
get_indexed:=direccion;
end;

procedure cpu_hd6309.trf(valor:byte);
var
  temp:word;
begin
if ((valor xor (valor shr 4)) and $08)<>0 then begin
  temp:=$ff
end else begin
  case (valor shr 4) of
    $0:temp:=r.q.d; //D
    $1:temp:=r.x;  //X
    $2:temp:=r.y; //Y
    $3:temp:=r.u; //U
    $4:temp:=r.s; //S
    $5:temp:=r.pc; //pc
    $8:temp:=r.q.a; //a
    $9:temp:=r.q.b; //b
    $a:temp:=self.dame_pila;  //cc
    $b:temp:=r.dp; //dp
  end;
end;
case (valor and 15) of
    $0:r.q.d:=temp; //D
    $1:r.x:=temp;  //X
    $2:r.y:=temp; //Y
    $3:r.u:=temp; //U
    $4:r.s:=temp; //S
    $5:r.pc:=temp; //pc
    $8:r.q.a:=temp; //a
    $9:r.q.b:=temp; //b
    $a:self.pon_pila(temp);  //cc
    $b:r.dp:=temp; //dp
end;
end;

procedure cpu_hd6309.trf_ex(valor:byte);
var
  temp1,temp2:word;
begin
if ((valor xor (valor shr 4)) and $08)<>0 then begin
    temp1:=$ff;
    temp2:=$ff;
end else begin
  case (valor shr 4) of
    $0:temp1:=r.q.d; //D
    $1:temp1:=r.x;  //X
    $2:temp1:=r.y; //Y
    $3:temp1:=r.u; //U
    $4:temp1:=r.s; //S
    $5:temp1:=r.pc; //pc
    $8:temp1:=r.q.a; //a
    $9:temp1:=r.q.b; //b
    $a:temp1:=self.dame_pila;  //cc
    $b:temp1:=r.dp; //dp
  end;
  case (valor and 15) of
    $0:temp2:=r.q.d; //D
    $1:temp2:=r.x;  //X
    $2:temp2:=r.y; //Y
    $3:temp2:=r.u; //U
    $4:temp2:=r.s; //S
    $5:temp2:=r.pc; //pc
    $8:temp2:=r.q.a; //a
    $9:temp2:=r.q.b; //b
    $a:temp2:=self.dame_pila;  //cc
    $b:temp2:=r.dp; //dp
  end;
end;
case (valor shr 4) of
    $0:r.q.d:=temp2; //D
    $1:r.x:=temp2;  //X
    $2:r.y:=temp2; //Y
    $3:r.u:=temp2; //U
    $4:r.s:=temp2; //S
    $5:r.pc:=temp2; //pc
    $8:r.q.a:=temp2; //a
    $9:r.q.b:=temp2; //b
    $a:self.pon_pila(temp2);  //cc
    $b:r.dp:=temp2; //dp
end;
case (valor and 15) of
    $0:r.q.d:=temp1; //D
    $1:r.x:=temp1;  //X
    $2:r.y:=temp1; //Y
    $3:r.u:=temp1; //U
    $4:r.s:=temp1; //S
    $5:r.pc:=temp1; //pc
    $8:r.q.a:=temp1; //a
    $9:r.q.b:=temp1; //b
    $a:self.pon_pila(temp1);  //cc
    $b:r.dp:=temp1; //dp
end;
end;

//Opcodes
{$I m6809.inc}

procedure cpu_hd6309.run(maximo:single);
var
  instruccion,temp,temp2,numero,instruccion2,cf:byte;
  tempw,posicion:word;
begin
self.contador:=0;
while self.contador<maximo do begin
if self.pedir_reset<>CLEAR_LINE then begin
  temp:=self.pedir_reset;
  self.reset;
  if temp=ASSERT_LINE then begin
    self.pedir_reset:=ASSERT_LINE;
    self.contador:=trunc(maximo);
    exit;
  end;
end;
self.r.old_pc:=self.r.pc;
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
//tipo de paginacion
case paginacion[instruccion] of
    0:; //implicito 0T
    1:begin //DIRECT  2T
        posicion:=(r.dp shl 8)+self.getbyte(r.pc);
        r.pc:=r.pc+1;
      end;
    2:begin  //inmediato byte
        numero:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
      end;
    3:begin  //EXTENDED 3T
         posicion:=self.getword(r.pc);
         r.pc:=r.pc+2;
      end;
    4:posicion:=self.get_indexed; //INDEXED Los estados T son variables
    5:begin //direct page indirecto byte
        posicion:=(r.dp shl 8)+self.getbyte(r.pc);
        r.pc:=r.pc+1;
        numero:=self.getbyte(posicion);
      end;
    6:numero:=self.getbyte(get_indexed); //indexado indirecto byte
    7:begin  //extendido indirecto byte
         posicion:=self.getword(r.pc);
         r.pc:=r.pc+2;
         numero:=self.getbyte(posicion);
      end;
    8:begin //direct page indirecto word
        posicion:=(r.dp shl 8)+self.getbyte(r.pc);
        r.pc:=r.pc+1;
        posicion:=self.getword(posicion);
      end;
    9:posicion:=self.getword(get_indexed); //indexado indirecto word
    $a:begin  //extendido indirecto word
         posicion:=self.getword(r.pc);
         r.pc:=r.pc+2;
         posicion:=self.getword(posicion);
      end;
    else MessageDlg('Num CPU'+inttostr(self.numero_cpu)+' instruccion: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(r.pc,10)+' OLD_PC='+inttohex(self.r.old_pc,10), mtInformation,[mbOk], 0)
end;
case instruccion of
      $0,$1,$60,$70:self.putbyte(posicion,m680x_neg(self.getbyte(posicion),@r.cc));  //neg 4T
      $2,$3,$63,$73:self.putbyte(posicion,m680x_com(self.getbyte(posicion),@r.cc)); //com 4T ($2 es ilegal!!)
      $4,$64,$74:self.putbyte(posicion,m680x_lsr(self.getbyte(posicion),@r.cc)); //lsr 4T
      $6,$66,$76:self.putbyte(posicion,m680x_ror(self.getbyte(posicion),@r.cc)); //ror 4T
      $7,$67,$77:self.putbyte(posicion,m680x_asr(self.getbyte(posicion),@r.cc)); //asr 4T
      $8,$68,$78:self.putbyte(posicion,m680x_asl(self.getbyte(posicion),@r.cc)); //asl 4T
      $9,$69,$79:self.putbyte(posicion,m680x_rol(self.getbyte(posicion),@r.cc)); //rol 4T
      $a,$6a,$7a:self.putbyte(posicion,m680x_dec(self.getbyte(posicion),@r.cc)); //dec 4T
      $c,$6c,$7c:self.putbyte(posicion,m680x_inc(self.getbyte(posicion),@r.cc)); //inc 4T
      $d,$6d,$7d:m680x_tst(self.getbyte(posicion),@r.cc); //tst 3T
      $e,$6e,$7e:r.pc:=posicion;  //jmp 1T
      $f,$6f,$7f:begin //clr 4T
          self.putbyte(posicion,0);
          r.cc.n:=false;
          r.cc.v:=false;
          r.cc.c:=false;
          r.cc.z:=true;
      end;
      $10,$11:begin  //Intrucciones $10 y $11
            self.opcode:=true;
            instruccion2:=self.getbyte(r.pc);
            self.opcode:=false;
            r.pc:=r.pc+1;
            case pag_1X[instruccion2] of
                0:MessageDlg('Num CPU '+inttostr(self.numero_cpu)+' instruccion '+inttohex(instruccion,2)+': '+inttohex(instruccion2,2)+' desconocida. PC='+inttohex(r.old_pc,10), mtInformation,[mbOk], 0);
                1:begin //direct page
                    posicion:=(r.dp shl 8)+self.getbyte(r.pc);
                    r.pc:=r.pc+1;
                  end;
                3:begin  //extendido
                     posicion:=self.getword(r.pc);
                     r.pc:=r.pc+2;
                  end;
                4:posicion:=self.get_indexed;
                5:begin //direct page word
                    posicion:=(r.dp shl 8)+self.getbyte(r.pc);
                    r.pc:=r.pc+1;
                    posicion:=self.getword(posicion);
                  end;
                6:posicion:=self.getword(self.get_indexed); //indexado word
                7:begin  //extendido word
                     posicion:=self.getword(r.pc);
                     r.pc:=r.pc+2;
                     posicion:=self.getword(posicion);
                  end;
                8:; //Direct
            end;
            if instruccion=$10 then begin
              case instruccion2 of
                $22:if not(r.cc.c or r.cc.z) then begin //lbhi
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $23:if (r.cc.c or r.cc.z) then begin //bls
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $24:if not(r.cc.c) then begin //lbcc
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $25:if r.cc.c then begin //lbcs
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $26:if not(r.cc.z) then begin //lbne
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $27:if r.cc.z then begin //lbeq
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $2a:if not(r.cc.n) then begin //lbpl
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $2b:if r.cc.n then begin //bmi
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $2c:if (r.cc.n=r.cc.v) then begin //bge
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $2d:if not(r.cc.n=r.cc.v) then begin //bnge
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $2e:if ((r.cc.n=r.cc.v) and not(r.cc.z)) then begin  //lbgt
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $2f:if not((r.cc.n=r.cc.v) and not(r.cc.z)) then begin //ble
                      r.pc:=r.pc+smallint(posicion);
                      self.estados_demas:=self.estados_demas+1;
                    end;
                $83,$93,$a3,$b3:m680x_sub16(r.q.d,posicion,@r.cc);  //cmpd
                $8c,$9c,$ac,$bc:m680x_sub16(r.y,posicion,@r.cc);  //cmpy
                $8e,$9e,$ae,$be:r.y:=m680x_ld_st16(posicion,@r.cc);  //LDY
                $9f,$af,$bf:self.putword(posicion,m680x_ld_st16(r.y,@r.cc)); //STY
                $a6:r.q.w:=m680x_ld_st16(posicion,@r.cc); //hd6309 ldw
                $ce,$de,$ee,$fe:begin  //LDS
                                  r.s:=m680x_ld_st16(posicion,@r.cc);
                                  r.pila_init:=true;
                                end;
                $df,$ef,$ff:self.putword(posicion,m680x_ld_st16(r.s,@r.cc)); //sts
              end;
            end else begin
                 case instruccion2 of
                   $3c,$3d:MessageDlg('Num CPU'+inttostr(self.numero_cpu)+'Intento de cambiar a HD6309!!. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
                   $83,$93,$a3,$b3:m680x_sub16(r.u,posicion,@r.cc);  //cmpu
                   $8c:m680x_sub16(r.s,posicion,@r.cc); //cmps
                 end;
            end;
            self.estados_demas:=self.estados_demas+hd6309t_1X[instruccion2];
          end;
      $12:; //nop 2T
      $13:if ((self.pedir_firq=CLEAR_LINE) and (self.pedir_irq=CLEAR_LINE) and (self.pedir_nmi=CLEAR_LINE)) then r.pc:=r.pc-1; //sync 4T
      $16:begin //lbra 5T
            r.pc:=r.pc+smallint(posicion);
            self.estados_demas:=self.estados_demas+1;
          end;
      $17:begin  //lbsr 9T
            self.push_sw(r.pc);
            r.pc:=r.pc+smallint(posicion);
          end;
      $19:begin //daa 2T
            cf:=0;
            temp:=r.q.a and $f0;
            temp2:=r.q.a and $0f;
	          if ((temp2>$09) or r.cc.h) then cf:=cf or $06;
	          if ((temp>$80) and (temp2>$09)) then cf:=cf or $60;
	          if ((temp>$90) or r.cc.c) then cf:=cf or $60;
	          tempw:=cf+r.q.a;
	          r.cc.v:=false;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.c:=r.cc.c or ((tempw and $100)<>0);
	          r.q.a:=tempw;
          end;
      $1a:begin //orcc 3T
            temp:=self.dame_pila or numero;
            self.pon_pila(temp);
          end;
      $1c:begin //andcc  3T
            temp:=self.dame_pila and numero;
            self.pon_pila(temp);
          end;
      $1d:begin //sex 2T
            r.q.a:=$ff*(r.q.b shr 7);
            r.cc.n:=(r.q.d and $8000)<>0;
            r.cc.z:=(r.q.d=0);
      end;
      $1e:self.trf_ex(numero); //exg 8T
      $1f:self.trf(numero); //trf 4T
      $20:r.pc:=r.pc+shortint(numero); //bra 3T
      $21:; //brn 3T
      $22:if not(r.cc.c or r.cc.z) then r.pc:=r.pc+shortint(numero);  //bhi 3T
      $23:if (r.cc.c or r.cc.z) then r.pc:=r.pc+shortint(numero); //bls 3T
      $24:if not(r.cc.c) then r.pc:=r.pc+shortint(numero);  //bcc 3T
      $25:if r.cc.c then r.pc:=r.pc+shortint(numero); //bcs 3T
      $26:if not(r.cc.z) then r.pc:=r.pc+shortint(numero); //bne 3T
      $27:if r.cc.z then r.pc:=r.pc+shortint(numero); //beq 3T
      $28:if not(r.cc.v) then r.pc:=r.pc+shortint(numero); //bvc 3T
      $29:if r.cc.v then r.pc:=r.pc+shortint(numero); //bvs 3T
      $2a:if not(r.cc.n) then r.pc:=r.pc+shortint(numero); //bpl 3T
      $2b:if r.cc.n then r.pc:=r.pc+shortint(numero); //bmi 3T
      $2c:if (not(r.cc.n)=not(r.cc.v)) then r.pc:=r.pc+shortint(numero);//bge 3T
      $2d:if not(not(r.cc.n)=not(r.cc.v)) then r.pc:=r.pc+shortint(numero);//blt 3T
      $2e:if ((not(r.cc.n)=not(r.cc.v)) and not(r.cc.z)) then r.pc:=r.pc+shortint(numero); //bgt 3T
      $2f:if not((not(r.cc.n)=not(r.cc.v)) and not(r.cc.z)) then r.pc:=r.pc+shortint(numero); //ble 3T
      $30:begin //leax 2T
            r.x:=posicion;
            r.cc.z:=(r.x=0);
          end;
      $31:begin //leay 2T
            r.y:=posicion;
            r.cc.z:=(r.y=0);
          end;
      $32:r.s:=posicion; //leas 2T
      $33:r.u:=posicion; //leau 2T
      $34:begin //pshs 5T
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
              self.push_s(r.q.b);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $2)<>0 then begin
              self.push_s(r.q.a);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $1)<>0 then begin
              self.push_s(self.dame_pila);
              self.estados_demas:=self.estados_demas+1;
            end;
      end;
      $35:begin //puls 4T
            if (numero and $1)<>0 then begin
              self.pon_pila(self.pop_s);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $2)<>0 then begin
              r.q.a:=self.pop_s;
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $4)<>0 then begin
              r.q.b:=self.pop_s;
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
      $36:begin //pshu 5T
            if (numero and $80)<>0 then begin
              self.push_uw(r.pc);
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $40)<>0 then begin
              self.push_uw(r.s);
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $20)<>0 then begin
              self.push_uw(r.y);
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $10)<>0 then begin
              self.push_uw(r.x);
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $8)<>0 then begin
              self.push_u(r.dp);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $4)<>0 then begin
              self.push_u(r.q.b);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $2)<>0 then begin
              self.push_u(r.q.a);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $1)<>0 then begin
              self.push_u(self.dame_pila);
              self.estados_demas:=self.estados_demas+1;
            end;
      end;
      $37:begin //pulu 4T
            if (numero and $1)<>0 then begin
              self.pon_pila(self.pop_u);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $2)<>0 then begin
              r.q.a:=self.pop_u;
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $4)<>0 then begin
              r.q.b:=self.pop_u;
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $8)<>0 then begin
              r.dp:=self.pop_u;
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $10)<>0 then begin
              r.x:=self.pop_uw;
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $20)<>0 then begin
              r.y:=self.pop_uw;
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $40)<>0 then begin
              r.s:=self.pop_uw;
              self.estados_demas:=self.estados_demas+2;
            end;
            if (numero and $80)<>0 then begin
              r.pc:=self.pop_uw;
              self.estados_demas:=self.estados_demas+2;
            end;
      end;
      $39:r.pc:=self.pop_sw; //rts 4T
      $3a:r.x:=r.x+r.q.b;  //abx 3T
      $3b:begin  //rti 4T
          self.pon_pila(self.pop_s);
          if r.cc.e then begin //13 T
            self.estados_demas:=self.estados_demas+9;
            r.q.a:=self.pop_s;
            r.q.b:=self.pop_s;
            r.dp:=self.pop_s;
            r.x:=self.pop_sw;
            r.y:=self.pop_sw;
            r.u:=self.pop_sw;
          end;
          r.pc:=self.pop_sw;
      end;
      $3c:begin //cwai 16T
          self.pon_pila(self.dame_pila and numero);
          r.cc.e:=true;
          self.push_sw(r.pc);
          self.push_sw(r.u);
          self.push_sw(r.y);
          self.push_sw(r.x);
          self.push_s(r.dp);
          self.push_s(r.q.b);
          self.push_s(r.q.a);
          self.push_s(self.dame_pila);
          r.cwai:=true;
      end;
      $3d:begin  //mul 11T
          r.q.d:=r.q.a*r.q.b;
          r.cc.c:=(r.q.d and $80)<>0;
          r.cc.z:=(r.q.d=0);
      end;
      $40:r.q.a:=m680x_neg(r.q.a,@r.cc); //nega 2T
      $43:r.q.a:=m680x_com(r.q.a,@r.cc);  //coma 2T
      $44:r.q.a:=m680x_lsr(r.q.a,@r.cc); //lsra 2T
      $46:r.q.a:=m680x_ror(r.q.a,@r.cc); //rora 2T
      $47:r.q.a:=m680x_asr(r.q.a,@r.cc); //asra 2T
      $48:r.q.a:=m680x_asl(r.q.a,@r.cc); //asla 2T
      $49:r.q.a:=m680x_rol(r.q.a,@r.cc);  //rola 2T
      $4a:r.q.a:=m680x_dec(r.q.a,@r.cc); //deca 2T
      $4c:r.q.a:=m680x_inc(r.q.a,@r.cc); //inca 2T
      $4d:m680x_tst(r.q.a,@r.cc); //tsta 2T
      $4f:begin //clra 2T
            r.q.a:=0;
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false;
          end;
      $50:r.q.b:=m680x_neg(r.q.b,@r.cc);  //negb 2T
      $53:r.q.b:=m680x_com(r.q.b,@r.cc);  //comb 2T
      $54:r.q.b:=m680x_lsr(r.q.b,@r.cc);   //lsrb 2T
      $56:r.q.b:=m680x_ror(r.q.b,@r.cc); //rorb 2T
      $57:r.q.b:=m680x_asr(r.q.b,@r.cc);  //asrb 2T
      $58:r.q.b:=m680x_asl(r.q.b,@r.cc);  //aslb 2T
      $59:r.q.b:=m680x_rol(r.q.b,@r.cc);  //rolb 2T
      $5a:r.q.b:=m680x_dec(r.q.b,@r.cc);  //decb 2T
      $5c:r.q.b:=m680x_inc(r.q.b,@r.cc);  //incb 2T
      $5d:m680x_tst(r.q.b,@r.cc); //tstb 2T
      $5f:begin //clrb 2T
            r.q.b:=0;
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false;
          end;
      $80,$90,$a0,$b0:r.q.a:=m680x_sub8(r.q.a,numero,@r.cc);   //suba 1T
      $81,$91,$a1,$b1:m680x_sub8(r.q.a,numero,@r.cc);  //cmpa 1T
      $82,$92,$a2,$b2:r.q.a:=m680x_sbc(r.q.a,numero,@r.cc);  //sbca 1T
      $83,$93,$a3,$b3:r.q.d:=m680x_sub16(r.q.d,posicion,@r.cc); //subd 2T
      $84,$94,$a4,$b4:r.q.a:=m680x_and(r.q.a,numero,@r.cc);  //anda 1T
      $85,$95,$a5,$b5:m680x_and(r.q.a,numero,@r.cc);  //bita 1T
      $86,$96,$a6,$b6:r.q.a:=m680x_ld_st8(numero,@r.cc);  //lda 1T
          $97,$a7,$b7:self.putbyte(posicion,m680x_ld_st8(r.q.a,@r.cc));  //sta 1T
      $88,$98,$a8,$b8:r.q.a:=m680x_eor(r.q.a,numero,@r.cc); //eora 1T
      $89,$99,$a9,$b9:r.q.a:=m680x_adc(r.q.a,numero,@r.cc);  //adca 1T
      $8a,$9a,$aa,$ba:r.q.a:=m680x_or(r.q.a,numero,@r.cc);  //ora 1T
      $8b,$9b,$ab,$bb:r.q.a:=m680x_add8(r.q.a,numero,@r.cc);  //adda 1T
      $8c,$9c,$ac,$bc:m680x_sub16(r.x,posicion,@r.cc);   //cmpx 2T
      $8d:begin  //bsr 7T
            self.push_sw(r.pc);
            r.pc:=r.pc+shortint(numero);
      end;
          $9d,$ad,$bd:begin //jsr 5T
            self.push_sw(r.pc);
            r.pc:=posicion;
      end;
      $8e,$9e,$ae,$be:r.x:=m680x_ld_st16(posicion,@r.cc);  //ldx 2T
          $9f,$af,$bf:self.putword(posicion,m680x_ld_st16(r.x,@r.cc)); //stx 2T
      $c0,$d0,$e0,$f0:r.q.b:=m680x_sub8(r.q.b,numero,@r.cc);  //subb 1T
      $c1,$d1,$e1,$f1:m680x_sub8(r.q.b,numero,@r.cc); //cmpb 1T
      $c2,$d2,$e2,$f2:r.q.b:=m680x_sbc(r.q.b,numero,@r.cc); //sbcb 1T
      $c3,$d3,$e3,$f3:r.q.d:=m680x_add16(r.q.d,posicion,@r.cc);  //addd 2T
      $c4,$d4,$e4,$f4:r.q.b:=m680x_and(r.q.b,numero,@r.cc);  //andb 1T
      $c5,$d5,$e5,$f5:m680x_and(r.q.b,numero,@r.cc);  //bitb 1T
      $c6,$d6,$e6,$f6:r.q.b:=m680x_ld_st8(numero,@r.cc); //ldb 1T
          $d7,$e7,$f7:self.putbyte(posicion,m680x_ld_st8(r.q.b,@r.cc));  //stb 1T
      $c8,$d8,$e8,$f8:r.q.b:=m680x_eor(r.q.b,numero,@r.cc);  //eorb 1T
      $c9,$d9,$e9,$f9:r.q.b:=m680x_adc(r.q.b,numero,@r.cc);  //adcb 1T
      $ca,$da,$ea,$fa:r.q.b:=m680x_or(r.q.b,numero,@r.cc);  //orb 1T
      $cb,$db,$eb,$fb:r.q.b:=m680x_add8(r.q.b,numero,@r.cc);  //addb 1T
      $cc,$dc,$ec,$fc:r.q.d:=m680x_ld_st16(posicion,@r.cc);  //ldd 2T
          $dd,$ed,$fd:self.putword(posicion,m680x_ld_st16(r.q.d,@r.cc));  //std 2T
      $ce,$de,$ee,$fe:r.u:=m680x_ld_st16(posicion,@r.cc);  //ldu 2t
          $df,$ef,$ff:self.putword(posicion,m680x_ld_st16(r.u,@r.cc)); //sdu 2T
end; //del case!!
tempw:=estados_t[instruccion]+self.estados_demas;
self.contador:=self.contador+tempw;
timers.update(tempw,self.numero_cpu);
end; //del while!!
end;

end.
