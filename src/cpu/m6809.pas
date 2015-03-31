unit m6809;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,dialogs,sysutils,timer_engine,vars_hide;

type
        band_m6809=record
                e,f,h,i,n,z,v,c:boolean;
        end;
        reg_m6809=record
                d:parejas680X;
                pc,u,s,x,y:word;
                dp:byte;
                cc:band_m6809;
                cwai,sync,pila_init:boolean;
        end;
        preg_m6809=^reg_m6809;
        cpu_m6809=class(cpu_class)
            constructor create(clock:dword;frames_div:word);
            procedure free;
            destructor destroy;
          public
            //IRQ's
            pedir_nmi,pedir_firq,pedir_irq,nmi_state:byte;
            procedure reset;
            procedure run(maximo:single);
            procedure clear_nmi;
            function save_snapshot(data:pbyte):word;
            procedure load_snapshot(data:pbyte);
          private
            //Registros
            r:preg_m6809;
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

const
    estados_t:array[0..255] of byte=(
      //0 1 2 3 4 5 6 7 8 9 a b c d e f
      6,0,0,6,6,0,6,6,6,6,6,0,6,6,3,6,    //00
      0,0,2,4,0,0,5,9,0,2,3,0,3,2,8,6,    //10
      3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,    //20
      4,4,4,4,5,5,5,5,0,5,3,6,20,11,0,19, //30
      2,0,0,2,2,0,2,2,2,2,2,0,2,2,0,2,    //40
      2,0,0,2,2,0,2,2,2,2,2,0,2,2,0,2,    //50
      6,0,0,6,6,0,6,6,6,6,6,0,6,6,3,6,    //60
      7,0,0,7,7,0,7,7,7,7,7,0,7,7,4,7,    //70
      2,2,2,4,2,2,2,2,2,2,2,2,4,7,3,0,    //80
      4,4,4,6,4,4,4,4,4,4,4,4,6,7,5,5,    //90
      4,4,4,6,4,4,4,4,4,4,4,4,6,7,5,5,    //A0
      5,5,5,7,5,5,5,5,5,5,5,5,7,8,6,6,    //B0
      2,2,2,4,2,2,2,2,2,2,2,2,3,0,3,3,    //C0
      4,4,4,6,4,4,4,4,4,4,4,4,5,5,5,5,    //D0
      4,4,4,6,4,4,4,4,4,4,4,4,5,5,5,5,    //E0
      5,5,5,7,5,5,5,5,5,5,5,5,6,6,6,6);   //F0

    paginacion:array[0..255] of byte=(
      //0  1  2  3  4  5  6  7  8  9  a  b  c  d  e  f
        1,$f, 0, 1, 1,$f, 1, 1, 1, 1, 1,$f, 1, 1, 1, 1,  //00
        0, 0, 0, 0,$f,$f, 3, 3,$f, 0, 2,$f, 2, 0, 2, 2,  //10
        2, 2, 2, 2, 2, 2, 2, 2,$f,$f, 2, 2, 2, 2, 2, 2,  //20
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

    estados_t_ea:array[0..255] of byte=(
      //0 1 2 3 4 5 6 7 8 9 a b c d e f
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
        2,3,2,3,0,1,1,0,1,4,0,4,1,5,0,5,
        5,6,5,6,3,4,4,0,4,7,0,7,4,8,0,8,
        2,3,2,3,0,1,1,0,1,4,0,4,1,5,0,5,
        5,6,5,6,3,4,4,0,4,7,0,7,4,8,0,8,
        2,3,2,3,0,1,1,0,1,4,0,4,1,5,0,3,
        5,6,5,6,3,4,4,0,4,7,0,7,4,8,0,8,
        2,3,2,3,0,1,1,0,1,4,0,4,1,5,0,5,
        4,6,5,6,3,4,4,0,4,7,0,7,4,8,0,8);

    m6809t_1X:array[0..255] of byte=(
      //0 1 2 3 4 5 6 7 8 9 a b c d e f
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //00
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //10
        0,5,5,5,5,5,5,5,5,5,5,5,5,5,5,5,  //20
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,20, //30
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //40
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //50
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //60
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //70
        0,0,0,5,0,0,0,0,0,0,0,0,5,0,4,4,  //80
        0,0,0,7,0,0,0,0,0,0,0,0,7,0,6,6,  //90
        0,0,0,7,0,0,0,0,0,0,0,0,7,0,6,6,  //a0
        0,0,0,8,0,0,0,0,0,0,0,0,8,0,7,7,  //b0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,  //c0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,  //d0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,6,  //e0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,7); //f0

    pag_1X:array[0..255] of byte=(
      //0 1 2 3 4 5 6 7 8 9 a b c d e f
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //00
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //10
        0,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,  //20
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //30
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //40
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //50
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //60
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,  //70
        0,0,0,3,0,0,0,0,0,0,0,0,3,0,3,3,  //80
        0,0,0,5,0,0,0,0,0,0,0,0,5,0,5,1,  //90
        0,0,0,6,0,0,0,0,0,0,0,0,6,0,6,4,  //a0
        0,0,0,7,0,0,0,0,0,0,0,0,7,0,7,3,  //b0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,  //c0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,5,1,  //d0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,6,4,  //e0
        0,0,0,0,0,0,0,0,0,0,0,0,0,0,7,3); //f0

var
  main_m6809,snd_m6809,misc_m6809:cpu_m6809;

implementation

constructor cpu_m6809.create(clock:dword;frames_div:word);
begin
getmem(self.r,sizeof(reg_m6809));
fillchar(self.r^,sizeof(reg_m6809),0);
self.numero_cpu:=cpu_quantity;
self.clock:=clock;
self.tframes:=(clock/frames_div)/llamadas_maquina.fps_max;
cpu_quantity:=cpu_quantity+1;
end;

destructor cpu_m6809.Destroy;
begin
freemem(self.r);
self.r:=nil;
end;

procedure cpu_m6809.Free;
begin
  if Self.r<>nil then Destroy;
end;

function cpu_m6809.save_snapshot(data:pbyte):word;
var
  temp:pbyte;
  size:word;
begin
  temp:=data;
  temp^:=pedir_nmi;inc(temp);size:=1;
  temp^:=pedir_firq;inc(temp);size:=size+1;
  temp^:=pedir_irq;inc(temp);size:=size+1;
  temp^:=nmi_state;inc(temp);size:=size+1;
  copymemory(temp,self.r,sizeof(reg_m6809));size:=size+sizeof(reg_m6809);
  save_snapshot:=size;
end;

procedure cpu_m6809.load_snapshot(data:pbyte);
var
  temp:pbyte;
begin
  temp:=data;
  pedir_nmi:=temp^;inc(temp);
  pedir_firq:=temp^;inc(temp);
  pedir_irq:=temp^;inc(temp);
  nmi_state:=temp^;inc(temp);
  copymemory(self.r,temp,sizeof(reg_m6809));
end;

procedure cpu_m6809.putword(direccion:word;valor:word);
begin
self.putbyte(direccion,valor shr 8);
self.putbyte(direccion+1,valor and $FF);
end;

function cpu_m6809.getword(direccion:word):word;
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

procedure cpu_m6809.reset;
begin
self.opcode:=false;
r.pc:=self.getword($FFFE);
r.d.w:=0;
r.x:=0;
r.y:=0;
self.contador:=0;
r.u:=0;
r.s:=0;
pon_pila(self.r,$50);
self.pedir_nmi:=CLEAR_LINE;
self.pedir_irq:=CLEAR_LINE;
self.pedir_firq:=CLEAR_LINE;
self.nmi_state:=CLEAR_LINE;
r.cwai:=false;
r.sync:=false;
r.pila_init:=false;
end;

procedure cpu_m6809.clear_nmi;
begin
  self.pedir_nmi:=CLEAR_LINE;
  self.nmi_state:=CLEAR_LINE;
end;

procedure cpu_m6809.push_s(reg:byte);
begin
r.s:=r.s-1;
self.putbyte(r.s,reg);
end;

function cpu_m6809.pop_s:byte;
begin
pop_s:=self.getbyte(r.s);
r.s:=r.s+1;
end;

procedure cpu_m6809.push_sw(reg:word);
begin
r.s:=r.s-2;
self.putbyte(r.s+1,reg and $FF);
self.putbyte(r.s,(reg shr 8));
end;

function cpu_m6809.pop_sw:word;
var
  temp:word;
begin
temp:=self.getbyte(r.s) shl 8;
temp:=temp or self.getbyte(r.s+1);
r.s:=r.s+2;
pop_sw:=temp;
end;

procedure cpu_m6809.push_u(reg:byte);
begin
r.u:=r.u-1;
self.putbyte(r.u,reg);
end;

function cpu_m6809.pop_u:byte;
begin
pop_u:=self.getbyte(r.u);
r.u:=r.u+1;
end;

procedure cpu_m6809.push_uw(reg:word);
begin
r.u:=r.u-2;
self.putbyte(r.u+1,reg and $FF);
self.putbyte(r.u,(reg shr 8));
end;

function cpu_m6809.pop_uw:word;
var
  temp:word;
begin
temp:=self.getbyte(r.u) shl 8;
temp:=temp or self.getbyte(r.u+1);
r.u:=r.u+2;
pop_uw:=temp;
end;

function cpu_m6809.call_nmi:byte;
begin
call_nmi:=0;
if self.nmi_state<>CLEAR_LINE then exit;
if not(r.pila_init) then exit;
if r.cwai then begin
  r.cwai:=false;
  call_nmi:=7;
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

function cpu_m6809.call_irq:byte;
begin
if r.cwai then begin
  r.cwai:=false;
  call_irq:=7;
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

function cpu_m6809.call_firq:byte;
begin
if r.cwai then begin
  r.cwai:=false;
  call_firq:=7;
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

function cpu_m6809.get_indexed:word;
var
  iindexed,temp:byte;
  origen:pparejas;
  direccion,temp2:word;
begin
iindexed:=self.getbyte(r.pc);
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
      end;
      1:begin  //reg++
          direccion:=origen.w;
          origen.w:=origen.w+2;
      end;
      2:begin  //-reg
          origen.w:=origen.w-1;
          direccion:=origen.w;
      end;
      3:begin //--reg
          origen.w:=origen.w-2;
          direccion:=origen.w;
      end;
      4:direccion:=origen.w;  // =
      5:direccion:=origen.w+shortint(r.d.b);  //reg + r.d.b
      6:direccion:=origen.w+shortint(r.d.a);  // reg + r.d.a
      7:MessageDlg('Indexed 7 desconocido. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
      8:begin  //reg + deplazamiento 8bits
          temp:=self.getbyte(r.pc);
          r.pc:=r.pc+1;
          direccion:=origen.w+shortint(temp);
      end;
      9:begin  //reg + deplazamiento 16bits
          temp2:=self.getword(r.pc);
          r.pc:=r.pc+2;
          direccion:=origen.w+smallint(temp2);
      end;
      $a:MessageDlg('Indexed $a desconocido. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
      $b:direccion:=origen.w+smallint(r.d.w); //reg + r.d.w
      $c:MessageDlg('Indexed $c desconocido. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
      $d:begin  //pc + desplazamiento 16 bits
          temp2:=self.getword(r.pc);
          r.pc:=r.pc+2;
          direccion:=r.pc+temp2;
      end;
      $f:begin
          direccion:=self.getword(r.pc);
          r.pc:=r.pc+2;
      end
  end;
  if (iindexed and $10)<>0 then direccion:=self.getword(direccion);
end else begin
  temp:=iindexed and $1f;
  if (temp and $10)=0 then direccion:=origen.w+(temp and $f)
    else direccion:=origen.w-(16-(temp and $f));
end;
self.estados_demas:=estados_t_ea[iindexed];
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

procedure cpu_m6809.run(maximo:single);
var
    instruccion,temp,temp2,numero,instruccion2,cf:byte;
    tempw:word;
    templ:dword;
    posicion:parejas;
begin
self.contador:=0;
while self.contador<maximo do begin
if self.pedir_reset<>CLEAR_LINE then begin
  self.reset;
  self.pedir_reset:=ASSERT_LINE;
  self.contador:=trunc(maximo);
  exit;
end;
self.estados_demas:=0;
if ((self.pedir_firq<>CLEAR_LINE) or (self.pedir_irq<>CLEAR_LINE) or (self.pedir_nmi<>CLEAR_LINE)) then r.sync:=false;
if self.pedir_nmi<>CLEAR_LINE then self.estados_demas:=self.call_nmi
  else if ((self.pedir_firq<>CLEAR_LINE) and not(r.cc.f)) then self.estados_demas:=self.call_firq
       else if ((self.pedir_irq<>CLEAR_LINE) and not(r.cc.i)) then self.estados_demas:=self.call_irq;
if (r.cwai or r.sync) then begin
  self.contador:=trunc(maximo);
  exit;
end;
self.opcode:=true;
instruccion:=self.getbyte(r.pc);
r.pc:=r.pc+1;
self.opcode:=false;
//tipo de paginacion
case paginacion[instruccion] of
    0:; //implicito
    1:begin //direct page
        posicion.h:=r.dp;
        posicion.l:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
      end;
    2:begin  //inmediato byte
        numero:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
      end;
    3:begin  //extendido
         posicion.w:=self.getword(r.pc);
         r.pc:=r.pc+2;
      end;
    4:posicion.w:=self.get_indexed;
    5:begin //direct page indirecto byte
        posicion.h:=r.dp;
        posicion.l:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
        numero:=self.getbyte(posicion.w);
      end;
    6:begin //indexado indirecto byte
        numero:=self.getbyte(get_indexed);
    end;
    7:begin  //extendido indirecto byte
         posicion.w:=self.getword(r.pc);
         r.pc:=r.pc+2;
         numero:=self.getbyte(posicion.w);
      end;
    8:begin //direct page indirecto word
        posicion.h:=r.dp;
        posicion.l:=self.getbyte(r.pc);
        r.pc:=r.pc+1;
        posicion.w:=self.getword(posicion.w);
      end;
    9:begin //indexado indirecto word
        posicion.w:=self.getword(get_indexed);
      end;
    $a:begin  //extendido indirecto word
         posicion.w:=self.getword(r.pc);
         r.pc:=r.pc+2;
         posicion.w:=self.getword(posicion.w);
      end;
    else MessageDlg('Num CPU'+inttostr(self.numero_cpu)+' instruccion: '+inttohex(instruccion,2)+' desconocida. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0)
end;
case instruccion of
      $0,$60,$70:begin  //neg
            temp:=self.getbyte(posicion.w);
            tempw:=-temp;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.c:=(tempw and $100)<>0;
            r.cc.v:=(((0 xor temp xor tempw xor (tempw shr 1)) and $80))<>0;
            self.putbyte(posicion.w,tempw);
      end;
      $2:; //ilegal!
      $3,$63,$73:begin  //com
            temp:=not(self.getbyte(posicion.w));
            r.cc.v:=false;
            r.cc.c:=true;
            r.cc.n:=(temp and $80)<>0;
            r.cc.z:=(temp=0);
            self.putbyte(posicion.w,temp);
      end;
      $4,$64,$74:begin  //lsr
            temp:=self.getbyte(posicion.w);
            r.cc.c:=(temp and $1)<>0;
            temp:=temp shr 1;
            r.cc.z:=(temp=0);
            r.cc.n:=false;
            self.putbyte(posicion.w,temp);
      end;
      $6,$66,$76:begin  //ror
            temp:=self.getbyte(posicion.w);
            if r.cc.c then temp2:=(temp shr 1) or $80
              else temp2:=temp shr 1;
            r.cc.c:=(temp and $1)<>0;
            r.cc.n:=(temp2 and $80)<>0;
            r.cc.z:=(temp2=0);
            self.putbyte(posicion.w,temp2);
      end;
      $7,$67,$77:begin  //asr
            temp:=self.getbyte(posicion.w);
            temp2:=(temp and $80) or (temp shr 1);
            r.cc.c:=(temp and $1)<>0;
            r.cc.n:=(temp2 and $80)<>0;
            r.cc.z:=(temp2=0);
            self.putbyte(posicion.w,temp2);
      end;
      $8,$68,$78:begin  //asl
            temp:=self.getbyte(posicion.w);
            tempw:=temp shl 1;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.c:=(tempw and $100)<>0;
            r.cc.v:=((temp xor temp xor tempw xor (tempw shr 1)) and $80)<>0;
            self.putbyte(posicion.w,tempw);
      end;
      $9,$69,$79:begin  //rol
            temp:=self.getbyte(posicion.w);
            if r.cc.c then tempw:=(temp shl 1) or 1
              else tempw:=(temp shl 1);
            r.cc.c:=(tempw and $100)<>0;
            r.cc.v:=((temp xor temp xor tempw xor (tempw shr 1)) and $80)<>0;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            self.putbyte(posicion.w,tempw);
      end;
      $a,$6a,$7a:begin  //dec
            temp:=self.getbyte(posicion.w)-1;
            r.cc.z:=(temp=0);
            r.cc.n:=(temp and $80)<>0;
            r.cc.v:=(temp=$7f);
            self.putbyte(posicion.w,temp);
      end;
      $c,$6c,$7c:begin  //inc
            temp:=self.getbyte(posicion.w)+1;
            r.cc.z:=(temp=0);
            r.cc.n:=(temp and $80)<>0;
            r.cc.v:=(temp=$80);
            self.putbyte(posicion.w,temp);
      end;
      $d,$6d,$7d:begin //tst
            temp:=self.getbyte(posicion.w);
            r.cc.v:=false;
            r.cc.n:=(temp and $80)<>0;
            r.cc.z:=(temp=0);
      end;
      $e,$6e,$7e:r.pc:=posicion.w;  //jmp
      $f,$6f,$7f:begin //clr
          //self.getbyte(posicion.w);
          self.putbyte(posicion.w,0);
          r.cc.n:=false;
          r.cc.v:=false;
          r.cc.c:=false;
          r.cc.z:=true;
      end;
      $10:begin  //Intrucciones $10XX
            self.opcode:=true;
            instruccion2:=self.getbyte(r.pc);
            self.opcode:=false;
            r.pc:=r.pc+1;
            case pag_1X[instruccion2] of
                0:MessageDlg('Num CPU '+inttostr(self.numero_cpu)+' instruccion $10: '+inttohex(instruccion2,2)+' desconocida. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
                1:begin //direct page
                    posicion.h:=r.dp;
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=r.pc+1;
                  end;
                3:begin  //extendido
                     posicion.w:=self.getword(r.pc);
                     r.pc:=r.pc+2;
                  end;
                4:posicion.w:=self.get_indexed;
                5:begin //direct page word
                    posicion.h:=r.dp;
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=r.pc+1;
                    posicion.w:=self.getword(posicion.w);
                  end;
                6:posicion.w:=self.getword(self.get_indexed); //indexado word
                7:begin  //extendido word
                     posicion.w:=self.getword(r.pc);
                     r.pc:=r.pc+2;
                     posicion.w:=self.getword(posicion.w);
                  end;
            end;
            case instruccion2 of
              $22:if not(r.cc.c or r.cc.z) then begin //lbhi
                    r.pc:=r.pc+smallint(posicion.w);
                    self.contador:=self.contador+1;
                  end;
              $23:if (r.cc.c or r.cc.z) then begin //bls
                    r.pc:=r.pc+smallint(posicion.w);
                    self.contador:=self.contador+1;
                  end;
              $24:if not(r.cc.c) then begin //lbcc
                    r.pc:=r.pc+smallint(posicion.w);
                    self.contador:=self.contador+1;
                  end;
              $25:if r.cc.c then begin //lbcs
                    r.pc:=r.pc+smallint(posicion.w);
                    self.contador:=self.contador+1;
                  end;
              $26:if not(r.cc.z) then begin //lbne
                    r.pc:=r.pc+smallint(posicion.w);
                    self.contador:=self.contador+1;
                  end;
              $27:if r.cc.z then begin //lbeq
                    r.pc:=r.pc+smallint(posicion.w);
                    self.contador:=self.contador+1;
                  end;
              $2a:if not(r.cc.n) then begin //lbpl
                    r.pc:=r.pc+smallint(posicion.w);
                    self.contador:=self.contador+1;
                  end;
              $2b:if r.cc.n then begin //bmi
                    r.pc:=r.pc+smallint(posicion.w);
                    self.contador:=self.contador+1;
                  end;
              $2c:if not(r.cc.n xor r.cc.v) then begin //bge
                    r.pc:=r.pc+smallint(posicion.w);
                    self.contador:=self.contador+1;
                  end;
              $83,$93,$a3,$b3:begin  //cmpd
                                templ:=r.d.w-posicion.w;
                                r.cc.c:=(templ and $10000)<>0;
                                r.cc.n:=(templ and $8000)<>0;
                                r.cc.z:=((templ and $ffff)=0);
                                r.cc.v:=((r.d.w xor posicion.w xor templ xor (templ shr 1)) and $8000)<>0;
                              end;
              $8c,$9c,$ac,$bc:begin  //CMPY
                                templ:=r.y-posicion.w;
                                r.cc.c:=(templ and $10000)<>0;
                                r.cc.n:=(templ and $8000)<>0;
                                r.cc.z:=((templ and $ffff)=0);
                                r.cc.v:=((r.y xor posicion.w xor templ xor (templ shr 1)) and $8000)<>0;
                              end;
              $8e,$9e,$ae,$be:begin  //LDY
                    r.y:=posicion.w;
                    r.cc.n:=(r.y and $8000)<>0;
                    r.cc.z:=(r.y=0);
                    r.cc.v:=false;
                  end;
              $9f,$af,$bf:begin //STY
                    r.cc.n:=(r.y and $8000)<>0;
                    r.cc.z:=(r.y=0);
                    r.cc.v:=false;
                    self.putword(posicion.w,r.y);
                  end;
              $ce,$de,$ee,$fe:begin  //LDS
                    r.s:=posicion.w;
                    r.cc.n:=(r.s and $8000)<>0;
                    r.cc.z:=(r.s=0);
                    r.cc.v:=false;
                    r.pila_init:=true;
                  end;
              $df,$ef,$ff:begin //sts
                    r.cc.n:=(r.s and $8000)<>0;
                    r.cc.z:=(r.s=0);
                    r.cc.v:=false;
                    self.putword(posicion.w,r.s);
                end
            end;
            self.estados_demas:=self.estados_demas+m6809t_1X[instruccion2];
          end;
      $11:begin
            self.opcode:=true;
            instruccion2:=self.getbyte(r.pc);
            self.opcode:=false;
            r.pc:=r.pc+1;
            case pag_1X[instruccion2] of
                0:MessageDlg('Instruccion $11: '+inttohex(instruccion2,2)+' desconocida. PC='+inttohex(r.pc,10), mtInformation,[mbOk], 0);
                1:begin //direct page
                    posicion.h:=r.dp;
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=r.pc+1;
                  end;
                3:begin  //extendido
                     posicion.w:=self.getword(r.pc);
                     r.pc:=r.pc+2;
                  end;
                4:posicion.w:=self.get_indexed;
                5:begin //direct page word
                    posicion.h:=r.dp;
                    posicion.l:=self.getbyte(r.pc);
                    r.pc:=r.pc+1;
                    posicion.w:=self.getword(posicion.w);
                  end;
                6:posicion.w:=self.getword(self.get_indexed); //indexado word
                7:begin  //extendido word
                     posicion.w:=self.getword(r.pc);
                     r.pc:=r.pc+2;
                     posicion.w:=self.getword(posicion.w);
                  end;
            end;
            case instruccion2 of
              $83,$93,$a3,$b3:begin  //cmpu
                                templ:=r.u-posicion.w;
                                r.cc.c:=(templ and $10000)<>0;
                                r.cc.n:=(templ and $8000)<>0;
                                r.cc.z:=((templ and $ffff)=0);
                                r.cc.v:=((r.u xor posicion.w xor templ xor (templ shr 1)) and $8000)<>0;
                              end;
              $8c:begin //cmps
                    templ:=r.s-posicion.w;
                    r.cc.c:=(templ and $10000)<>0;
                    r.cc.n:=(templ and $8000)<>0;
                    r.cc.z:=((templ and $ffff)=0);
                    r.cc.v:=((r.s xor posicion.w xor templ xor (templ shr 1)) and $8000)<>0;
                  end;
            end;
            self.estados_demas:=self.estados_demas+m6809t_1X[instruccion2];
          end;
      $12:; //nop
      $13:begin //sync
            r.sync:=true;
            self.contador:=trunc(maximo);
            exit;
          end;
      $16:begin //lbra
            r.pc:=r.pc+smallint(posicion.w);
            self.contador:=self.contador+1;
          end;
      $17:begin  //lbsr
            self.push_sw(r.pc);
            r.pc:=r.pc+smallint(posicion.w);
            self.contador:=self.contador+1;
      end;
      $19:begin //daa
            cf:=0;
            temp:=r.d.a and $f0;
            temp2:=r.d.a and $0f;
	          if ((temp2>$09) or r.cc.h) then cf:=cf or $06;
	          if ((temp>$80) and (temp2>$09)) then cf:=cf or $60;
	          if ((temp>$90) or r.cc.c) then cf:=cf or $60;
	          tempw:=cf+r.d.a;
	          r.cc.v:=false;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.c:=r.cc.c or ((tempw and $100)<>0);
	          r.d.a:=tempw;
          end;
      $1a:begin //orcc
            temp:=dame_pila(self.r) or numero;
            pon_pila(self.r,temp);
          end;
      $1c:begin //andcc
            temp:=dame_pila(self.r) and numero;
            pon_pila(self.r,temp);
          end;
      $1d:begin //sex
            if (r.d.b and $80)<>0 then r.d.a:=$ff
              else r.d.a:=0;
            r.cc.n:=(r.d.w and $8000)<>0;
            r.cc.z:=(r.d.w=0);
      end;
      $1e:trf_ex(self.r,numero); //exg
      $1f:trf(self.r,numero); //trf
      $20:r.pc:=r.pc+shortint(numero); //bra
      $21:; //brn
      $22:if not(r.cc.c or r.cc.z) then r.pc:=r.pc+shortint(numero);  //bhi
      $23:if (r.cc.c or r.cc.z) then r.pc:=r.pc+shortint(numero); //bls
      $24:if not(r.cc.c) then r.pc:=r.pc+shortint(numero);  //bcc
      $25:if r.cc.c then r.pc:=r.pc+shortint(numero); //bcs
      $26:if not(r.cc.z) then r.pc:=r.pc+shortint(numero); //bne
      $27:if r.cc.z then r.pc:=r.pc+shortint(numero); //beq
      $2a:if not(r.cc.n) then r.pc:=r.pc+shortint(numero); //bpl
      $2b:if r.cc.n then r.pc:=r.pc+shortint(numero); //bmi
      $2c:if not(r.cc.n xor r.cc.v) then r.pc:=r.pc+shortint(numero);//bge
      $2d:if (r.cc.n xor r.cc.v) then r.pc:=r.pc+shortint(numero);//blt
      $2e:if not((r.cc.n xor r.cc.v) or r.cc.z) then r.pc:=r.pc+shortint(numero); //bgt
      $2f:if ((r.cc.n xor r.cc.v) or r.cc.z) then r.pc:=r.pc+shortint(numero); //ble
      $30:begin //leax
            r.x:=posicion.w;
            r.cc.z:=(r.x=0);
          end;
      $31:begin //leay
            r.y:=posicion.w;
            r.cc.z:=(r.y=0);
          end;
      $32:r.s:=posicion.w; //leas
      $33:r.u:=posicion.w; //leau
      $34:begin //pshs
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
      $35:begin //puls
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
      $36:begin //pshu
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
              self.push_u(r.d.b);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $2)<>0 then begin
              self.push_u(r.d.a);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $1)<>0 then begin
              self.push_u(dame_pila(self.r));
              self.estados_demas:=self.estados_demas+1;
            end;
      end;
      $37:begin //pulu
            if (numero and $1)<>0 then begin
              pon_pila(self.r,self.pop_u);
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $2)<>0 then begin
              r.d.a:=self.pop_u;
              self.estados_demas:=self.estados_demas+1;
            end;
            if (numero and $4)<>0 then begin
              r.d.b:=self.pop_u;
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
      $39:r.pc:=self.pop_sw; //rts
      $3a:r.x:=r.x+r.d.b;  //abx
      $3b:begin  //rti
          pon_pila(self.r,self.pop_s);
          if r.cc.e then begin
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
      $3c:begin //cwai
          pon_pila(self.r,dame_pila(self.r) and numero);
          r.cc.e:=true;
          self.push_sw(r.pc);
          self.push_sw(r.u);
          self.push_sw(r.y);
          self.push_sw(r.x);
          self.push_s(r.dp);
          self.push_s(r.d.b);
          self.push_s(r.d.a);
          self.push_s(dame_pila(self.r));
          r.cwai:=true;
      end;
      $3d:begin  //mul
          r.d.w:=r.d.a*r.d.b;
          r.cc.c:=(r.d.w and $80)<>0;
          r.cc.z:=(r.d.w=0);
      end;
      $40:begin //nega
            tempw:=-r.d.a;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.c:=(tempw and $100)<>0;
            r.cc.v:=(((0 xor r.d.a xor tempw xor (tempw shr 1)) and $80))<>0;
            r.d.a:=tempw;
          end;
      $43:begin  //coma
            r.d.a:=not(r.d.a);
            r.cc.v:=false;
            r.cc.c:=true;
            r.cc.n:=(r.d.a and $80)<>0;
            r.cc.z:=(r.d.a=0);
          end;
      $44:begin //lsra
            r.cc.c:=(r.d.a and $1)<>0;
            temp:=r.d.a shr 1;
            r.cc.z:=(temp=0);
            r.cc.n:=false;
            r.d.a:=temp;
          end;
      $46:begin //rora
            if r.cc.c then temp:=(r.d.a shr 1) or $80
              else temp:=r.d.a shr 1;
            r.cc.c:=(r.d.a and $1)<>0;
            r.cc.n:=(temp and $80)<>0;
            r.cc.z:=(temp=0);
            r.d.a:=temp;
          end;
      $47:begin //asra
            temp:=(r.d.a and $80) or (r.d.a shr 1);
            r.cc.c:=(r.d.a and $1)<>0;
            r.cc.n:=(temp and $80)<>0;
            r.cc.z:=(temp=0);
            r.d.a:=temp;
          end;
      $48:begin //asla
            tempw:=r.d.a shl 1;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.c:=(tempw and $100)<>0;
            r.cc.v:=((r.d.a xor r.d.a xor tempw xor (tempw shr 1)) and $80)<>0;
            r.d.a:=tempw;
          end;
      $49:begin  //rola
            if r.cc.c then tempw:=(r.d.a shl 1) or 1
              else tempw:=(r.d.a shl 1);
            r.cc.c:=(tempw and $100)<>0;
            r.cc.v:=((r.d.a xor r.d.a xor tempw xor (tempw shr 1)) and $80)<>0;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.d.a:=tempw;
          end;
      $4a:begin //deca
            r.d.a:=r.d.a-1;
            r.cc.z:=(r.d.a=0);
            r.cc.n:=(r.d.a and $80)<>0;
            r.cc.v:=(r.d.a=$7f);
          end;
      $4c:begin //inca
            r.d.a:=r.d.a+1;
            r.cc.z:=(r.d.a=0);
            r.cc.n:=(r.d.a and $80)<>0;
            r.cc.v:=(r.d.a=$80);
          end;
      $4d:begin //tsta
            r.cc.v:=false;
            r.cc.n:=(r.d.a and $80)<>0;
            r.cc.z:=(r.d.a=0);
          end;
      $4f:begin //clra
            r.d.a:=0;
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false;
          end;
      $50:begin  //negb
            tempw:=-r.d.b;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.c:=(tempw and $100)<>0;
            r.cc.v:=(((0 xor r.d.b xor tempw xor (tempw shr 1)) and $80))<>0;
            r.d.b:=tempw;
          end;
      $53:begin  //comb
            r.d.b:=not(r.d.b);
            r.cc.v:=false;
            r.cc.c:=true;
            r.cc.n:=(r.d.b and $80)<>0;
            r.cc.z:=(r.d.b=0);
          end;
      $54:begin   //lsrb
            r.cc.c:=(r.d.b and $1)<>0;
            temp:=r.d.b shr 1;
            r.cc.z:=(temp=0);
            r.cc.n:=false;
            r.d.b:=temp;
          end;
      $56:begin  //rorb
            if r.cc.c then temp:=(r.d.b shr 1) or $80
              else temp:=r.d.b shr 1;
            r.cc.c:=(r.d.b and $1)<>0;
            r.cc.n:=(temp and $80)<>0;
            r.cc.z:=(temp=0);
            r.d.b:=temp;
          end;
      $57:begin  //asrb
            temp:=(r.d.b and $80) or (r.d.b shr 1);
            r.cc.c:=(r.d.b and $1)<>0;
            r.cc.n:=(temp and $80)<>0;
            r.cc.z:=(temp=0);
            r.d.b:=temp;
          end;
      $58:begin  //aslb
            tempw:=r.d.b shl 1;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.c:=(tempw and $100)<>0;
            r.cc.v:=((r.d.b xor r.d.b xor tempw xor (tempw shr 1)) and $80)<>0;
            r.d.b:=tempw;
          end;
      $59:begin  //rolb
            if r.cc.c then tempw:=(r.d.b shl 1) or 1
              else tempw:=(r.d.b shl 1);
            r.cc.c:=(tempw and $100)<>0;
            r.cc.v:=((r.d.b xor r.d.b xor tempw xor (tempw shr 1)) and $80)<>0;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.d.b:=tempw;
          end;
      $5a:begin  //decb
            r.d.b:=r.d.b-1;
            r.cc.z:=(r.d.b=0);
            r.cc.n:=(r.d.b and $80)<>0;
            r.cc.v:=(r.d.b=$7f);
          end;
      $5c:begin  //incb
            r.d.b:=r.d.b+1;
            r.cc.z:=(r.d.b=0);
            r.cc.n:=(r.d.b and $80)<>0;
            r.cc.v:=(r.d.b=$80);
          end;
      $5d:begin //tstb
           r.cc.v:=false;
           r.cc.n:=(r.d.b and $80)<>0;
           r.cc.z:=(r.d.b=0);
      end;
      $5f:begin //clrb
            r.d.b:=0;
            r.cc.z:=true;
            r.cc.n:=false;
            r.cc.v:=false;
            r.cc.c:=false;
          end;
      $80,$90,$a0,$b0:begin   //suba
            tempw:=r.d.a-numero;
            r.cc.c:=(tempw and $100)<>0;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.v:=(((r.d.a xor numero xor tempw xor (tempw shr 1)) and $80))<>0;
            r.d.a:=tempw;
          end;
      $81,$91,$a1,$b1:begin  //cmpa
            tempw:=r.d.a-numero;
            r.cc.c:=(tempw and $100)<>0;
            r.cc.n:=(tempw and $80)<>0;
            r.cc.z:=((tempw and $ff)=0);
            r.cc.v:=(((r.d.a xor numero xor tempw xor (tempw shr 1)) and $80))<>0;
          end;
      $82,$92,$a2,$b2:begin  //sbca
                          if r.cc.c then tempw:=r.d.a-numero-1
                            else tempw:=r.d.a-numero;
                          r.cc.c:=(tempw and $100)<>0;
                          r.cc.n:=(tempw and $80)<>0;
                          r.cc.z:=((tempw and $ff)=0);
                          r.cc.v:=(((r.d.a xor numero xor tempw xor (tempw shr 1)) and $80))<>0;
                          r.d.a:=tempw;
                      end;
      $83,$93,$a3,$b3:begin //subd
                          templ:=r.d.w-posicion.w;
                          r.cc.c:=(templ and $10000)<>0;
                          r.cc.n:=(templ and $8000)<>0;
                          r.cc.z:=((templ and $ffff)=0);
                          r.cc.v:=((r.d.w xor posicion.w xor templ xor (templ shr 1)) and $8000)<>0;
                          r.d.w:=templ;
                      end;
      $84,$94,$a4,$b4:begin  //anda
                        r.d.a:=r.d.a and numero;
                        r.cc.n:=(r.d.a and $80)<>0;
                        r.cc.z:=(r.d.a=0);
                        r.cc.v:=false;
                      end;
      $85,$95,$a5,$b5:begin  //bita
                        temp:=r.d.a and numero;
                        r.cc.n:=(temp and $80)<>0;
                        r.cc.z:=(temp=0);
                        r.cc.v:=false;
                      end;
      $86,$96,$a6,$b6:begin  //lda
            r.d.a:=numero;
            r.cc.v:=false;
            r.cc.n:=(r.d.a and $80)<>0;
            r.cc.z:=(r.d.a=0);
          end;
      $97,$a7,$b7:begin  //sta
            r.cc.n:=(r.d.a and $80)<>0;
            r.cc.z:=(r.d.a=0);
            r.cc.v:=false;
            self.putbyte(posicion.w,r.d.a);
          end;
      $88,$98,$a8,$b8:begin //eora
                        r.d.a:=r.d.a xor numero;
                        r.cc.n:=(r.d.a and $80)<>0;
                        r.cc.z:=(r.d.a=0);
                        r.cc.v:=false;
                      end;
      $89,$99,$a9,$b9:begin  //adca
                        if r.cc.c then tempw:=r.d.a+numero+1
                          else tempw:=r.d.a+numero;
                        r.cc.c:=(tempw and $100)<>0;
                        r.cc.h:=((r.d.a xor numero xor tempw) and $10)<>0;
                        r.cc.n:=(tempw and $80)<>0;
                        r.cc.z:=((tempw and $ff)=0);
                        r.cc.v:=(((r.d.a xor numero xor tempw xor (tempw shr 1)) and $80))<>0;
                        r.d.a:=tempw;
                      end;
      $8a,$9a,$aa,$ba:begin  //ora
                          r.d.a:=r.d.a or numero;
                          r.cc.n:=(r.d.a and $80)<>0;
                          r.cc.z:=(r.d.a=0);
                          r.cc.v:=false;
                      end;
      $8b,$9b,$ab,$bb:begin  //adda
                        tempw:=r.d.a+numero;
                        r.cc.c:=(tempw and $100)<>0;
                        r.cc.h:=((r.d.a xor numero xor tempw) and $10)<>0;
                        r.cc.n:=(tempw and $80)<>0;
                        r.cc.z:=((tempw and $ff)=0);
                        r.cc.v:=(((r.d.a xor numero xor tempw xor (tempw shr 1)) and $80))<>0;
                        r.d.a:=tempw;
                      end;
      $8c,$9c,$ac,$bc:begin   //cmpx
                        templ:=r.x-posicion.w;
                        r.cc.c:=(templ and $10000)<>0;
                        r.cc.n:=(templ and $8000)<>0;
                        r.cc.z:=((templ and $ffff)=0);
                        r.cc.v:=((r.x xor posicion.w xor templ xor (templ shr 1)) and $8000)<>0;
                      end;
      $8d:begin  //bsr
            self.push_sw(r.pc);
            r.pc:=r.pc+shortint(numero);
      end;
      $9d,$ad,$bd:begin //jsr
            self.push_sw(r.pc);
            r.pc:=posicion.w;
      end;
      $8e,$9e,$ae,$be:begin  //ldx
            r.x:=posicion.w;
            r.cc.n:=(r.x and $8000)<>0;
            r.cc.z:=(r.x=0);
            r.cc.v:=false;
          end;
      $9f,$af,$bf:begin //stx
            r.cc.n:=(r.x and $8000)<>0;
            r.cc.z:=(r.x=0);
            r.cc.v:=false;
            self.putword(posicion.w,r.x);
      end;
      $c0,$d0,$e0,$f0:begin  //subb
                          tempw:=r.d.b-numero;
                          r.cc.c:=(tempw and $100)<>0;
                          r.cc.n:=(tempw and $80)<>0;
                          r.cc.z:=((tempw and $ff)=0);
                          r.cc.v:=(((r.d.b xor numero xor tempw xor (tempw shr 1)) and $80))<>0;
                          r.d.b:=tempw;
                      end;
      $c1,$d1,$e1,$f1:begin //cmpb
                          tempw:=r.d.b-numero;
                          r.cc.c:=(tempw and $100)<>0;
                          r.cc.n:=(tempw and $80)<>0;
                          r.cc.z:=((tempw and $ff)=0);
                          r.cc.v:=(((r.d.b xor numero xor tempw xor (tempw shr 1)) and $80))<>0;
                      end;
      $c2,$d2,$e2,$f2:begin //sbcb
                          if r.cc.c then tempw:=r.d.b-numero-1
                            else tempw:=r.d.b-numero;
                          r.cc.c:=(tempw and $100)<>0;
                          r.cc.n:=(tempw and $80)<>0;
                          r.cc.z:=((tempw and $ff)=0);
                          r.cc.v:=(((r.d.b xor numero xor tempw xor (tempw shr 1)) and $80))<>0;
                          r.d.b:=tempw;
                      end;
      $c3,$d3,$e3,$f3:begin  //addd
                        templ:=r.d.w+posicion.w;
                        r.cc.c:=(templ and $10000)<>0;
                        r.cc.n:=(templ and $8000)<>0;
                        r.cc.z:=((templ and $ffff)=0);
                        r.cc.v:=((r.d.w xor posicion.w xor templ xor (templ shr 1)) and $8000)<>0;
                        r.d.w:=templ;
                      end;
      $c4,$d4,$e4,$f4:begin  //andb
                          r.d.b:=r.d.b and numero;
                          r.cc.n:=(r.d.b and $80)<>0;
                          r.cc.z:=(r.d.b=0);
                          r.cc.v:=false;
                      end;
      $c5,$d5,$e5,$f5:begin  //bitb
                        temp:=r.d.b and numero;
                        r.cc.n:=(temp and $80)<>0;
                        r.cc.z:=(temp=0);
                        r.cc.v:=false;
                      end;
      $c6,$d6,$e6,$f6:begin //ldb
            r.d.b:=numero;
            r.cc.n:=(r.d.b and $80)<>0;
            r.cc.z:=(r.d.b=0);
            r.cc.v:=false;
          end;
      $d7,$e7,$f7:begin  //stb
            r.cc.n:=(r.d.b and $80)<>0;
            r.cc.z:=(r.d.b=0);
            r.cc.v:=false;
            self.putbyte(posicion.w,r.d.b);
      end;
      $c8,$d8,$e8,$f8:begin  //eorb
                          r.d.b:=r.d.b xor numero;
                          r.cc.n:=(r.d.b and $80)<>0;
                          r.cc.z:=(r.d.b=0);
                          r.cc.v:=false;
                      end;
      $c9,$d9,$e9,$f9:begin  //adcb
                          if r.cc.c then tempw:=r.d.b+numero+1
                            else tempw:=r.d.b+numero;
                          r.cc.c:=(tempw and $100)<>0;
                          r.cc.h:=((r.d.b xor numero xor tempw) and $10)<>0;
                          r.cc.n:=(tempw and $80)<>0;
                          r.cc.z:=((tempw and $ff)=0);
                          r.cc.v:=(((r.d.b xor numero xor tempw xor (tempw shr 1)) and $80))<>0;
                          r.d.b:=tempw;
                      end;
      $ca,$da,$ea,$fa:begin  //orb
                          r.d.b:=r.d.b or numero;
                          r.cc.n:=(r.d.b and $80)<>0;
                          r.cc.z:=(r.d.b=0);
                          r.cc.v:=false;
                      end;
      $cb,$db,$eb,$fb:begin  //addb
                         tempw:=r.d.b+numero;
                         r.cc.c:=(tempw and $100)<>0;
                         r.cc.h:=((r.d.b xor numero xor tempw) and $10)<>0;
                         r.cc.n:=(tempw and $80)<>0;
                         r.cc.z:=((tempw and $ff)=0);
                         r.cc.v:=(((r.d.b xor numero xor tempw xor (tempw shr 1)) and $80))<>0;
                         r.d.b:=tempw;
                      end;
      $cc,$dc,$ec,$fc:begin  //ldd
            r.d.w:=posicion.w;
            r.cc.n:=(r.d.w and $8000)<>0;
            r.cc.z:=(r.d.w=0);
            r.cc.v:=false;
          end;
      $dd,$ed,$fd:begin  //std
            r.cc.n:=(r.d.w and $8000)<>0;
            r.cc.z:=(r.d.w=0);
            r.cc.v:=false;
            self.putword(posicion.w,r.d.w);
      end;
      $ce,$de,$ee,$fe:begin  //ldu
            r.u:=posicion.w;
            r.cc.n:=(r.u and $8000)<>0;
            r.cc.z:=(r.u=0);
            r.cc.v:=false;
          end;
      $df,$ef,$ff:begin //sdu
            r.cc.n:=(r.u and $8000)<>0;
            r.cc.z:=(r.u=0);
            r.cc.v:=false;
            self.putword(posicion.w,r.u);
      end;
end; //del case!!
tempw:=estados_t[instruccion]+self.estados_demas;
self.contador:=self.contador+tempw;
update_timer(tempw,self.numero_cpu);
end; //del while!!
end;

end.
