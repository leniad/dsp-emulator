unit hd6309;

interface
uses {$IFDEF WINDOWS}windows,{$ENDIF}
     main_engine,dialogs,cpu_misc,m6809;

type
        //MD_EM	$01	 Execution mode
        //MD_FM	$02  FIRQ mode
        //MD_II	$40	 Illegal instruction
        //MD_DZ	$80	 Division by zero
        band_hd6309=record
                md_em,md_fm,md_ii,md_dz:boolean;
        end;
        Parejas_hd6309=record
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
                constructor create(clock:dword;frames_div:word);
                destructor free;
            public
                procedure reset;
                procedure run(maximo:single);
                procedure change_ram_calls(getbyte:tgetbyte;putbyte:tputbyte);
                procedure change_irq(estado:byte);
                procedure change_firq(estado:byte);
                procedure change_nmi(estado:byte);
            private
                r:preg_hd6309;
                internal_m6809:cpu_m6809;
                procedure putword(direccion:word;valor:word);
                function getword(direccion:word):word;
                function dame_pila:byte;
                procedure pon_pila(valor:byte);
        end;

var
    main_hd6309:cpu_hd6309;

implementation

constructor cpu_hd6309.create(clock:dword;frames_div:word);
begin
getmem(self.r,sizeof(reg_hd6309));
fillchar(self.r^,sizeof(reg_hd6309),0);
self.numero_cpu:=cpu_quantity;
self.clock:=clock div 4;
self.tframes:=(clock/4/frames_div)/llamadas_maquina.fps_max;
cpu_quantity:=cpu_quantity+1;
self.internal_m6809:=cpu_m6809.create(clock div 4,frames_div);
end;

procedure cpu_hd6309.change_ram_calls(getbyte:tgetbyte;putbyte:tputbyte);
begin
  self.getbyte:=getbyte;
  self.putbyte:=putbyte;
  self.internal_m6809.change_ram_calls(getbyte,putbyte);
end;

destructor cpu_hd6309.free;
begin
self.internal_m6809.free;
freemem(self.r);
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
self.internal_m6809.reset;
end;

procedure cpu_hd6309.putword(direccion:word;valor:word);
begin
self.putbyte(direccion,valor shr 8);
self.putbyte(direccion+1,valor and $FF);
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

procedure cpu_hd6309.change_irq(estado:byte);
begin
if r.cc2.md_em then self.pedir_irq:=estado
   else self.internal_m6809.change_irq(estado);
end;

procedure cpu_hd6309.change_firq(estado:byte);
begin
if r.cc2.md_em then self.pedir_firq:=estado
   else self.internal_m6809.change_firq(estado);
end;

procedure cpu_hd6309.change_nmi(estado:byte);
begin
if r.cc2.md_em then begin
   if estado=CLEAR_LINE then begin
      self.pedir_nmi:=CLEAR_LINE;
      self.nmi_state:=CLEAR_LINE;
   end else begin
      self.pedir_nmi:=estado;
   end;
end else self.internal_m6809.change_nmi(estado);
end;

procedure cpu_hd6309.run(maximo:single);
begin
if self.r.cc2.md_em then begin //Modo nativo
  MessageDlg('HD6309 Nativo!!', mtInformation,[mbOk], 0);
end else begin //Modo M6809
  self.internal_m6809.contador:=self.contador;
  self.internal_m6809.run(maximo);
  self.contador:=self.internal_m6809.contador;
end;
end;

end.
