unit z80_sp;

interface
uses main_engine,nz80,z80daisy,vars_hide;

type
 tretraso=procedure(direccion:word);
 tretraso_puerto=procedure(direccion:word);
 cpu_z80_sp=class(cpu_z80)
    public
      procedure run(maximo:integer);
      procedure change_retraso_call(retraso:tretraso;retraso_puerto:tretraso_puerto);
      function get_pc:word;
    private
      retraso:tretraso;
      retraso_puerto:tretraso_puerto;
      procedure call_irq;
      function spec_getbyte(posicion:word):byte;
      procedure spec_putbyte(posicion:word;valor:byte);
      function spec_inbyte(posicion:word):byte;
      procedure spec_outbyte(posicion:word;valor:byte);
      //Resto opcodes
      procedure exec_cb_sp;
      procedure exec_dd_fd_sp(tipo:boolean);
      procedure exec_dd_cb_sp(tipo:boolean);
      procedure exec_ed_sp;
    end;

var
  spec_z80:cpu_z80_sp;

implementation
uses spectrum_misc;

procedure cpu_z80_sp.change_retraso_call(retraso:tretraso;retraso_puerto:tretraso_puerto);
begin
  self.retraso:=retraso;
  self.retraso_puerto:=retraso_puerto;
end;

function cpu_z80_sp.get_pc:word;
begin
  get_pc:=self.r.pc;
end;

procedure cpu_z80_sp.spec_outbyte(posicion:word;valor:byte);
begin
self.out_port(posicion,valor);
self.retraso_puerto(posicion);
end;

function cpu_z80_sp.spec_inbyte(posicion:word):byte;
begin
spec_inbyte:=self.in_port(posicion);
self.retraso_puerto(posicion);
end;

procedure cpu_z80_sp.spec_putbyte(posicion:word;valor:byte);
begin
self.putbyte(posicion,valor);
self.retraso(posicion);
self.contador:=self.contador+3;
end;

function cpu_z80_sp.spec_getbyte(posicion:word):byte;
begin
spec_getbyte:=self.getbyte(posicion);
self.retraso(posicion);
self.contador:=self.contador+3;
end;

procedure cpu_z80_sp.call_irq;
var
  posicion:word;
begin
self.r.halt_opcode:=false;
if not(r.iff1) then exit; //se esta ejecutando otra
r.r:=((r.r+1) and $7f) or (r.r and $80);
dec(r.sp,2);
self.putbyte(r.sp+1,r.pc shr 8);
self.putbyte(r.sp,r.pc and $ff);
r.IFF2:= false;
r.IFF1:= False;
Case r.im of
        0:begin //12t
              r.pc:= $38;
              self.contador:=self.contador+12;
            end;
        1:begin //13t
              r.pc:= $38;
              self.contador:=self.contador+13;
            end;
        2:begin //19t
                if self.daisy then posicion:=z80daisy_ack
                    else posicion:=self.im2_lo;
                posicion:=posicion or (r.i shl 8);
                r.pc:=self.getbyte(posicion)+(self.getbyte(posicion+1) shl 8);
                self.contador:=self.contador+19;
        end;
end;
r.wz:=r.pc;
self.pedir_irq:=CLEAR_LINE;
end;

procedure cpu_z80_sp.run(maximo:integer);
var
 instruccion,temp:byte;
 posicion:parejas;
 ban_temp:band_z80;
 pcontador:byte;
 irq_temp:boolean;
 cantidad_t:word;
begin
irq_temp:=false;
while self.contador<maximo do begin
pcontador:=self.contador;
if not(self.after_ei) then begin
  if self.daisy then irq_temp:=z80daisy_state;
  if (irq_temp or (self.pedir_irq<>CLEAR_LINE)) then self.call_irq;
end else self.after_ei:=false;
if self.r.halt_opcode then r.pc:=r.pc-1;
self.retraso(r.pc);inc(self.contador,4);
instruccion:=self.getbyte(r.pc);
r.pc:=r.pc+1;
r.r:=((r.r+1) and $7f) or (r.r and $80);
case instruccion of
        $00,$40,$49,$52,$5b,$64,$6d,$7f:{nop >4t<};
        $01:begin {ld BC,nn >10t<}
                r.bc.l:=spec_getbyte(r.pc);
                r.bc.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
            end;
        $02:begin {ld (BC),A >7t<}
                 spec_putbyte(r.bc.w,r.a);
                 r.wz:=((r.bc.w+1) and $ff) or (r.a shl 8);
            end;
        $03:begin  {inc BC >6t<}
              self.contador:=self.contador+2;
              r.bc.w:=r.bc.w+1;
            end;
        $04:r.bc.h:=inc_8(r.bc.h); //inc B >4t<
        $05:r.bc.h:=dec_8(r.bc.h); //dec B >4t<
        $06:begin {ld B,n >7t<}
                r.bc.h:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $07:begin   //rlca >4t<}
               r.f.c:=(r.a and $80)<>0;
               r.a:=(r.a shl 1) or byte(r.f.c);
               r.f.bit5:=(r.a and $20)<>0;
               r.f.bit3:=(r.a and 8)<>0;
               r.f.h:=false;
               r.f.n:=false;
            end;
        $08:begin { ex AF,AF' >4t<}
                ban_temp:=r.f;
                r.f:=r.f2;
                r.f2:=ban_temp;
                temp:=r.a;
                r.a:=r.a2;
                r.a2:=temp;
            end;
        $09:begin {add HL,BC >11t<}
                self.contador:=self.contador+7;
                r.hl.w:=add_16(r.hl.w,r.bc.w);
            end;
        $0a:begin {ld A,(BC) >7t<}
                 r.a:=spec_getbyte(r.bc.w);
                 r.wz:=r.bc.w+1;
            end;
        $0b:begin {dec BC >6t<}
                self.contador:=self.contador+2;
                dec(r.bc.w);
            end;
        $0c:r.bc.l:=inc_8(r.bc.l); {inc C >4t<}
        $0d:r.bc.l:=dec_8(r.bc.l); {dec C >4t<}
        $0e:begin {ld C,n >7t<}
                r.bc.l:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $0f:begin   {rrca >4t<}
                r.f.c:=(r.a and 1)<>0;
                r.a:=(r.a shr 1) or (byte(r.f.c) shl 7);
                r.f.bit5:=(r.a and $20) <>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.h:=false;
                r.f.n:=false;
            end;
        $10:begin {dnjz (PC+e) >8t o 13t<}
                self.contador:=self.contador+1;
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                r.bc.h:=r.bc.h-1;
                if r.bc.h<>0 then begin
                  //pc-1 esta asi por la memoria contenida!!
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  r.pc:=r.pc+shortint(temp);
                  r.wz:=r.pc;
                end;
            end;
        $11:begin {ld DE,nn >10t<}
                r.de.l:=spec_getbyte(r.pc);
                r.de.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
            end;
        $12:begin {ld (DE),A >7t<}
                spec_putbyte(r.de.w,r.a);
                r.wz:=((r.de.w+1) and $ff) or (r.a shl 8);
            end;
        $13:begin {inc DE >6t<}
                self.contador:=self.contador+2;
                inc(r.de.w);
            end;
        $14:r.de.h:=inc_8(r.de.h); //inc D >4t<
        $15:r.de.h:=dec_8(r.de.h); //dec D >4t<
        $16:begin {ld D,n >7t<}
                r.de.h:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $17:begin  //rla >4t<
                r.f.h:=(r.a and $80)<>0;
                r.a:=(r.a shl 1) or byte(r.f.c);
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.c:=r.f.h;
                r.f.h:=false;
                r.f.n:=false;
            end;
        $18:begin   {jr e >12t<}
                temp:=spec_getbyte(r.pc);
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                r.pc:=r.pc+1+shortint(temp);
                r.wz:=r.pc;
            end;
        $19:begin  //add HL,DE >11t<
                self.contador:=self.contador+7;
                r.hl.w:=add_16(r.hl.w,r.de.w);
            end;
        $1a:begin  {ld A,(DE) >7t<}
                r.a:=spec_getbyte(r.de.w);
                r.wz:=r.de.w+1;
            end;
        $1b:begin {dec DE >6t<}
                self.contador:=self.contador+2;
                dec(r.de.w);
            end;
        $1c:r.de.l:=inc_8(r.de.l); //inc E >4t<
        $1d:r.de.l:=dec_8(r.de.l); //dec E >4t<
        $1e:begin {ld E,n >7t<}
                r.de.l:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $1f:begin {rra >4t<}
                r.f.h:=(r.a and 1)<>0;
                r.a:=(r.a shr 1) or (byte(r.f.c) shl 7);
                r.f.n:=false;
                r.f.c:=r.f.h;
                r.f.h:=false;
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
            end;
        $20:begin  //jr NZ,(PC+e) >7t o 12t<
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                if not(r.f.z) then begin
                  //Por la memoria contenida
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  r.pc:=r.pc+shortint(temp);
                  r.wz:=r.pc;
                end;
            end;
        $21:begin {ld HL,nn >10t<}
                r.hl.l:=spec_getbyte(r.pc);
                r.hl.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
            end;
        $22:begin {ld (nn),HL >16t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                spec_putbyte(posicion.w,r.hl.l);
                spec_putbyte(posicion.w+1,r.hl.h);
                r.wz:=posicion.w+1;
            end;
        $23:begin  {inc HL >6t<}
                self.contador:=self.contador+2;
                inc(r.hl.w);
            end;
        $24:r.hl.h:=inc_8(r.hl.h); //inc H >4t<
        $25:r.hl.h:=dec_8(r.hl.h); //dec H >4t<
        $26:begin {ld H,n >7t<}
                r.hl.h:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $27:begin   {daa >4t<}
                temp:=0;
                If (r.f.h Or ((r.a And $0F)> 9)) Then temp:=temp or 6;
                If (r.f.c Or (r.a > $9F)) Then temp:=temp or $60;
                If ((r.a > $8F) And ((r.a And $0F) > 9)) Then temp:=temp or $60;
                If (r.a > $99) Then r.f.c:=True;
                If r.f.n Then begin
                        r.f.h:=(((r.a and $0f)-(temp and $0f)) and $10)<>0;
                        r.a:=r.a-temp;
                end else begin
                        r.f.h:=(((r.a and $0f)+(temp and $0f)) and $10)<>0;
                        r.a:=r.a+temp;
                end;
                r.f.p_v:=paridad[r.a];
                r.f.s:=(r.a and $80) <>0;
                r.f.z:=(r.a=0);
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
            end;
        $28:begin //jr Z,(PC+e) >7t o 12t<
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                if r.f.z then begin
                  //Por la memoria contenida!
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  r.pc:=r.pc+shortint(temp);
                  r.wz:=r.pc;
                end;
            end;
        $29:begin  //add HL,HL >11t<
                self.contador:=self.contador+7;
                r.hl.w:=add_16(r.hl.w,r.hl.w);
            end;
        $2a:begin  {ld HL,(nn) >16t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                r.hl.l:=spec_getbyte(posicion.w);
                r.hl.h:=spec_getbyte(posicion.w+1);
                r.wz:=posicion.w+1;
            end;
        $2b:begin   {dec HL >6t<}
                self.contador:=self.contador+2;
                dec(r.hl.w);
            end;
        $2c:r.hl.l:=inc_8(r.hl.l); //inc L >4t<
        $2d:r.hl.l:=dec_8(r.hl.l); //dec L >4t<
        $2e:begin {ld L,n >7t<}
                r.hl.l:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $2f:begin {cpl >4t<}
                r.a:=r.a xor $FF;
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.h:=true;
                r.f.n:=true;
            end;
        $30:begin //jr NC,(PC+e) >7t o 12t<
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                if not(r.f.c) then begin
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  r.pc:=r.pc+shortint(temp);
                  r.wz:=r.pc;
                end;
            end;
        $31:begin {ld SP,nn >10t<}
                r.sp:=spec_getbyte(r.pc)+(spec_getbyte(r.pc+1) shl 8);
                r.pc:=r.pc+2;
            end;
        $32:begin {ld (nn),A >13t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                spec_putbyte(posicion.w,r.a);
                r.wz:=((posicion.w+1) and $ff) or (r.a shl 8);
            end;
        $33:begin  {inc SP >6t<}
                self.contador:=self.contador+2;
                inc(r.sp);
            end;
        $34:begin  //inc (HL) >11t<
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                spec_putbyte(r.hl.w,inc_8(temp));
            end;
        $35:begin  {dec (HL) >11t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                spec_putbyte(r.hl.w,dec_8(temp));
            end;
        $36:begin {ld (HL),n >10t<}
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                spec_putbyte(r.hl.w,temp);
            end;
        $37:begin  {scf >4t<}
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.c:=true;
                r.f.h:=false;
                r.f.n:=false;
            end;
        $38:begin //jr C,(PC+e) >7t o 12t<
              temp:=spec_getbyte(r.pc);
              r.pc:=r.pc+1;
              if r.f.c then begin
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  self.retraso(r.pc-1);self.contador:=self.contador+1;
                  r.pc:=r.pc+shortint(temp);
                  r.wz:=r.pc;
              end;
            end;
        $39:begin //add HL,SP >11t<
                self.contador:=self.contador+7;
                r.hl.w:=add_16(r.hl.w,r.sp);
            end;
        $3a:begin {ld A,(nn) >13<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                r.a:=spec_getbyte(posicion.w);
                r.wz:=posicion.w+1;
            end;
        $3b:begin   {dec SP >6t<}
              self.contador:=self.contador+2;
              r.sp:=r.sp-1;
           end;
        $3c:r.a:=inc_8(r.a); //inc A >4t<
        $3d:r.a:=dec_8(r.a); //dec A >4t<
        $3e:begin {ld A,n >7t<}
                r.a:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $3f:begin   {ccf >4t<}
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.h:=r.f.c;
                r.f.n:=false;
                r.f.c:=not(r.f.c);
            end;
        {'$'40: igual que el nop ld B,B}
        $41:r.bc.h:=r.bc.l; {ld B,C >4t<}
        $42:r.bc.h:=r.de.h; {ld B,D >4t<}
        $43:r.bc.h:=r.de.l; {ld B,E >4t<}
        $44:r.bc.h:=r.hl.h; {ld B,H >4t<}
        $45:r.bc.h:=r.hl.l; {ld B,L >4t<}
        $46:r.bc.h:=spec_getbyte(r.hl.w); {ld B,(HL) >7t<}
        $47:r.bc.h:=r.a; {ld B,A >4t<}
        $48:r.bc.l:=r.bc.h; {ld C,B >4t<}
        {'$'49: igual que el nop ld C,C}
        $4a:r.bc.l:=r.de.h; {ld C,D >4t<}
        $4b:r.bc.l:=r.de.l; {ld C,E >4t<}
        $4c:r.bc.l:=r.hl.h; {ld C,H >4t<}
        $4d:r.bc.l:=r.hl.l; {ld C,L >4t<}
        $4e:r.bc.l:=spec_getbyte(r.hl.w); {ld C,(HL) >7t<}
        $4f:r.bc.l:=r.a; {ld C,A >4t<}
        $50:r.de.h:=r.bc.h; {ld D,B >4t<}
        $51:r.de.h:=r.bc.l; {ld D,C >4t<}
        {'$'52 igual que el nop ld D,D}
        $53:r.de.h:=r.de.l; {ld D,E >4t<}
        $54:r.de.h:=r.hl.h; {ld D,H >4t<}
        $55:r.de.h:=r.hl.l; {ld D,L >4t<}
        $56:r.de.h:=spec_getbyte(r.hl.w); {ld D,(HL) >7t<}
        $57:r.de.h:=r.a; {ld D,A >4t<}
        $58:r.de.l:=r.bc.h; {ld E,B >4t<}
        $59:r.de.l:=r.bc.l; {ld E,C >4t<}
        $5a:r.de.l:=r.de.h; {ld E,D >4t<}
        {'$'5b igual que el nop ld E,E}
        $5c:r.de.l:=r.hl.h; {ld E,H >4t<}
        $5d:r.de.l:=r.hl.l; {ld E,L >4t<}
        $5e:r.de.l:=spec_getbyte(r.hl.w); {ld E,(HL) >7t<}
        $5f:r.de.l:=r.a; {ld E,A >4t<}
        $60:r.hl.h:=r.bc.h; {ld H,B >4t<}
        $61:r.hl.h:=r.bc.l; {ld H,C >4t<}
        $62:r.hl.h:=r.de.h; {ld H,D >4t<}
        $63:r.hl.h:=r.de.l; {ld H,E >4t<}
        {'$'64: igual que el nop ld H,H}
        $65:r.hl.h:=r.hl.l; {ld H,L >4t<}
        $66:r.hl.h:=spec_getbyte(r.hl.w); {ld H,(HL) >7t<}
        $67:r.hl.h:=r.a; {ld H,A >4t<}
        $68:r.hl.l:=r.bc.h; {ld L,B >4t<}
        $69:r.hl.l:=r.bc.l; {ld L,C >4t<}
        $6a:r.hl.l:=r.de.h; {ld L,D >4t<}
        $6b:r.hl.l:=r.de.l; {ld L,E >4t<}
        $6c:r.hl.l:=r.hl.h; {ld L,H >4t<}
        {'$'6d: igual que el nop ld L,L}
        $6e:r.hl.l:=spec_getbyte(r.hl.w); {ld L,(HL) >7t<}
        $6f:r.hl.l:=r.a; {ld L,A >4t<}
        $70:spec_putbyte(r.hl.w,r.bc.h); {ld (HL),B >7t<}
        $71:spec_putbyte(r.hl.w,r.bc.l); {ld (HL),C >7t<}
        $72:spec_putbyte(r.hl.w,r.de.h); {ld (HL),D >7t<}
        $73:spec_putbyte(r.hl.w,r.de.l); {ld (HL),E >7t<}
        $74:spec_putbyte(r.hl.w,r.hl.h); {ld (HL),H >7t<}
        $75:spec_putbyte(r.hl.w,r.hl.l); {ld (HL),L >7t<}
        $76:self.r.halt_opcode:=true; {halt >4t<}
        $77:spec_putbyte(r.hl.w,r.a); {ld (HL),A >7t<}
        $78:r.a:=r.bc.h; {ld A,B >4t<}
        $79:r.a:=r.bc.l; {ld A,C >4t<}
        $7a:r.a:=r.de.h; {ld A,D >4t<}
        $7b:r.a:=r.de.l; {ld A,E >4t<}
        $7c:r.a:=r.hl.h; {ld A,H >4t<}
        $7d:r.a:=r.hl.l; {ld A,L >4t<}
        $7e:r.a:=spec_getbyte(r.hl.w); {ld A,(HL) >7t<}
        {'$'7f: igual que el nop ld A,A}
        $80:add_8(r.bc.h); {add A,B >4t<}
        $81:add_8(r.bc.l); {add A,C >4t<}
        $82:add_8(r.de.h); {add A,D >4t<}
        $83:add_8(r.de.l); {add A,E >4t<}
        $84:add_8(r.hl.h); {add A,H >4t<}
        $85:add_8(r.hl.l); {add A,L >4t<}
        $86:add_8(spec_getbyte(r.hl.w));  {add A,(HL) >7t<}
        $87:add_8(r.a); {add A,A >4t<}
        $88:adc_8(r.bc.h); {adc A,B >4t<}
        $89:adc_8(r.bc.l); {adc A,C >4t<}
        $8a:adc_8(r.de.h); {adc A,D >4t<}
        $8b:adc_8(r.de.l); {adc A,E >4t<}
        $8c:adc_8(r.hl.h); {adc A,H >4t<}
        $8d:adc_8(r.hl.l); {adc A,L >4t<}
        $8e:adc_8(spec_getbyte(r.hl.w)); {adc A,(HL) >7t<}
        $8f:adc_8(r.a); {adc A,A >4t<}
        $90:sub_8(r.bc.h); {sub B >4t<}
        $91:sub_8(r.bc.l); {sub C >4t<}
        $92:sub_8(r.de.h); {sub D >4t<}
        $93:sub_8(r.de.l); {sub E >4t<}
        $94:sub_8(r.hl.h); {sub H >4t<}
        $95:sub_8(r.hl.l); {sub L >4t<}
        $96:sub_8(spec_getbyte(r.hl.w)); {sub (HL) >4t<}
        $97:sub_8(r.a); {sub A  >4t<}
        $98:sbc_8(r.bc.h); {sbc A,B >4t<}
        $99:sbc_8(r.bc.l); {sbc A,C >4t<}
        $9a:sbc_8(r.de.h); {sbc A,D >4t<}
        $9b:sbc_8(r.de.l); {sbc A,E >4t<}
        $9c:sbc_8(r.hl.h); {sbc A,H >4t<}
        $9d:sbc_8(r.hl.l); {sbc A,L >4t<}
        $9e:sbc_8(spec_getbyte(r.hl.w)); {sbc A,(HL) >7t<}
        $9f:sbc_8(r.a); {sbc A,A >4t<}
        $a0:and_a(r.bc.h);  {and A,B >4t<}
        $a1:and_a(r.bc.l);  {and A,C >4t<}
        $a2:and_a(r.de.h);  {and A,D >4t<}
        $a3:and_a(r.de.l); {and A,E >4t<}
        $a4:and_a(r.hl.h); {and A,H >4t<}
        $a5:and_a(r.hl.l); {and A,L >4t<}
        $a6:and_a(spec_getbyte(r.hl.w)); {and A,(HL) >7t<}
        $a7:and_a(r.a); {and A,A >4t<}
        $a8:xor_a(r.bc.h); {xor A,B >4t<}
        $a9:xor_a(r.bc.l); {xor A,C >4t<}
        $aa:xor_a(r.de.h); {xor A,D >4t<}
        $ab:xor_a(r.de.l); {xor A,E >4t<}
        $ac:xor_a(r.hl.h); {xor A,H >4t<}
        $ad:xor_a(r.hl.l); {xor A,L >4t<}
        $ae:xor_a(spec_getbyte(r.hl.w)); {xor A,(HL) >7t<}
        $af:begin {xor A,A >4t<}
                r.a:=0;
                r.f.s:=false;
                r.f.z:=true;
                r.f.bit5:=false;
                r.f.h:=false;
                r.f.bit3:=false;
                r.f.p_v:=true;
                r.f.n:=false;
                r.f.c:=false;
             end;
        $b0:or_a(r.bc.h); {or B >4t<}
        $b1:or_a(r.bc.l); {or C >4t<}
        $b2:or_a(r.de.h); {or D >4t<}
        $b3:or_a(r.de.l); {or E >4t<}
        $b4:or_a(r.hl.h); {or H >4t<}
        $b5:or_a(r.hl.l); {or L >4t<}
        $b6:or_a(spec_getbyte(r.hl.w));   {or (HL) >7t<}
        $b7:or_a(r.a); {or A >4t<}
        $b8:cp_a(r.bc.h); {cp B >4t<}
        $b9:cp_a(r.bc.l); {cp C >4t<}
        $ba:cp_a(r.de.h); {cp D >4t<}
        $bb:cp_a(r.de.l); {cp E >4t<}
        $bc:cp_a(r.hl.h); {cp H >4t<}
        $bd:cp_a(r.hl.l); {cp L >4t<}
        $be:cp_a(spec_getbyte(r.hl.w)); {cp (HL) >7t<}
        $bf:cp_a(r.a); {cp A >4t<}
        $c0:begin {ret NZ >5t o 10t<}
              self.contador:=self.contador+1;
              if not(r.f.z) then begin
                  self.retraso(r.sp);self.contador:=self.contador+3;
                  self.retraso(r.sp+1);self.contador:=self.contador+3;
                  r.pc:=self.pop_sp;
                  r.wz:=r.pc;
              end;
             end;
        $c1:begin  //pop BC  >10t<
              self.retraso(r.sp);self.contador:=self.contador+3;
              self.retraso(r.sp+1);self.contador:=self.contador+3;
              r.bc.w:=pop_sp;
            end;
        $c2:begin //jp NZ,nn >10t<
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                if not(r.f.z) then r.pc:=posicion.w
                   else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $c3:begin //jp nn >10t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=posicion.w;
                r.wz:=posicion.w;
             end;
        $c4:begin {call NZ,nn >10t o 17t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                if not(r.f.z) then begin
                  self.retraso(r.pc);self.contador:=self.contador+1;
                  self.retraso(r.sp-1);self.contador:=self.contador+3;
                  self.retraso(r.sp-2);self.contador:=self.contador+3;
                  push_sp(r.pc);
                  r.pc:=posicion.w;
                end;
                r.wz:=r.pc;
             end;
        $c5:begin {push BC >11t<}
              self.contador:=self.contador+1;
              self.retraso(r.sp-1);self.contador:=self.contador+3;
              self.retraso(r.sp-2);self.contador:=self.contador+3;
              push_sp(r.bc.w);
            end;
        $c6:begin {add A,n >7t<}
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                add_8(temp);
             end;
        $c7:begin  {rst 00H >11t<}
                self.contador:=self.contador+1;
                self.retraso(r.sp-1);self.contador:=self.contador+3;
                self.retraso(r.sp-2);self.contador:=self.contador+3;
                push_sp(r.pc);
                r.pc:=0;
                r.wz:=0;
             end;
        $c8:begin {ret Z >5t o 11t<}
              self.contador:=self.contador+1;
              if r.f.z then begin
                  self.retraso(r.sp);self.contador:=self.contador+3;
                  self.retraso(r.sp+1);self.contador:=self.contador+3;
                  r.pc:=pop_sp;
                  r.wz:=r.pc;
              end;
            end;
        $c9:begin //ret >10t<
              self.retraso(r.sp);self.contador:=self.contador+3;
              self.retraso(r.sp+1);self.contador:=self.contador+3;
              r.pc:=pop_sp;
              r.wz:=r.pc;
            end;
        $ca:begin {jp Z,nn >10t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                if r.f.z then r.pc:=posicion.w
                   else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $cb:self.exec_cb_sp;
        $cc:begin {call Z,nn >10t o 17t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                if r.f.z then begin
                  self.retraso(r.pc);inc(self.contador);
                  self.retraso(r.sp-1);inc(self.contador,3);
                  self.retraso(r.sp-2);inc(self.contador,3);
                  push_sp(r.pc);
                  r.pc:=posicion.w;
                end;
                r.wz:=r.pc;
            end;
        $cd:begin   {call nn >17t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.wz:=posicion.w;
                r.pc:=r.pc+2;
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.sp-1);inc(self.contador,3); 
                self.retraso(r.sp-2);inc(self.contador,3);
                push_sp(r.pc);
                r.pc:=posicion.w;
             end;
        $ce:begin   {adc A,n >7t<}
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                adc_8(temp);
             end;
        $cf:begin  {rst 08H >11t<}
                self.contador:=self.contador+1;
                self.retraso(r.sp-1);inc(self.contador,3);
                self.retraso(r.sp-2);inc(self.contador,3); 
                push_sp(r.pc);
                r.pc:=$8;
                r.wz:=$8;
             end;
        $d0:begin {ret NC >5t o 11t<}
              self.contador:=self.contador+1;
              if not(r.f.c) then begin
                  self.retraso(r.sp);self.contador:=self.contador+3;
                  self.retraso(r.sp+1);self.contador:=self.contador+3;
                  r.pc:=pop_sp;
                  r.wz:=r.pc;
              end;
             end;
        $d1:begin  //pop DE >10t<
              self.retraso(r.sp);self.contador:=self.contador+3;
              self.retraso(r.sp+1);self.contador:=self.contador+3;
              r.de.w:=pop_sp;
            end;
        $d2:begin //jp NC,nn >10t<
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                if not(r.f.c) then r.pc:=posicion.w
                   else r.pc:=r.pc+2;
                r.wz:=r.pc;
             end;
        $d3:begin //out (n),A >11t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=r.a;
                r.pc:=r.pc+1;
                spec_outbyte(posicion.w,r.a);
                r.wz:=((posicion.l+1) and $ff) or (r.a shl 8);
             end;
        $d4:begin {call NC,nn >10t o 17t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                if not(r.f.c) then begin
                  self.retraso(r.pc);self.contador:=self.contador+1;
                  self.retraso(r.sp-1);self.contador:=self.contador+3;
                  self.retraso(r.sp-2);self.contador:=self.contador+3;
                  push_sp(r.pc);
                  r.pc:=posicion.w;
                end;
                r.wz:=r.pc;
             end;
        $d5:begin  {push DE >11t<}
              inc(self.contador);
              self.retraso(r.sp-1);self.contador:=self.contador+3;
              self.retraso(r.sp-2);self.contador:=self.contador+3;
              push_sp(r.de.w);
            end;
        $d6:begin {sub n >7t<}
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                sub_8(temp);
             end;
        $d7:begin  {rst 10H >11t<}
                self.contador:=self.contador+1;
                self.retraso(r.sp-1);self.contador:=self.contador+3;
                self.retraso(r.sp-2);self.contador:=self.contador+3;
                push_sp(r.pc);
                r.pc:=$10;
                r.wz:=$10;
             end;
        $d8:begin {ret C >5t o 11t<}
              self.contador:=self.contador+1;
              if r.f.c then begin
                  self.retraso(r.sp);self.contador:=self.contador+3;
                  self.retraso(r.sp+1);self.contador:=self.contador+3;
                  r.pc:=pop_sp;
                  r.wz:=r.pc;
              end;
            end;
        $d9:begin {exx >4t<}
                posicion:=r.bc;
                r.bc:=r.bc2;
                r.bc2:=posicion;
                posicion:=r.de;
                r.de:=r.de2;
                r.de2:=posicion;
                posicion:=r.hl;
                r.hl:=r.hl2;
                r.hl2:=posicion;
             end;
        $da:begin  {jp C,nn >10t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                if r.f.c then r.pc:=posicion.w
                   else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $db:begin  {in A,(n) >11t<}
             posicion.l:=spec_getbyte(r.pc);
             r.pc:=r.pc+1;
             posicion.h:=r.a;
             r.a:=spec_inbyte(posicion.w);
             r.wz:=posicion.w+1;
             end;
        $dc:begin  {call C,nn >10t o 17t<}
              posicion.l:=spec_getbyte(r.pc);
              posicion.h:=spec_getbyte(r.pc+1);
              r.pc:=r.pc+2;
              if r.f.c then begin
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.sp-1);self.contador:=self.contador+3;
                self.retraso(r.sp-2);self.contador:=self.contador+3;
                push_sp(r.pc);
                r.pc:=posicion.w;
              end;
              r.wz:=r.pc;
             end;
        $dd:self.exec_dd_fd_sp(true);
        $de:begin {sbc A,n >7t<}
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                sbc_8(temp);
            end;
        $df:begin  {rst 18H >11t<}
                self.contador:=self.contador+1;
                self.retraso(r.sp-1);self.contador:=self.contador+3;
                self.retraso(r.sp-2);self.contador:=self.contador+3;
                push_sp(r.pc);
                r.pc:=$18;
                r.wz:=$18;
             end;
        $e0:begin {ret PO >5t o 11t<}
              self.contador:=self.contador+1;
              if not(r.f.p_v) then begin
                  self.retraso(r.sp);self.contador:=self.contador+3;
                  self.retraso(r.sp+1);self.contador:=self.contador+3;
                  r.pc:=pop_sp;
                  r.wz:=r.pc;
              end;
             end;
        $e1:begin {pop HL >10t<}
              self.retraso(r.sp);self.contador:=self.contador+3;
              self.retraso(r.sp+1);self.contador:=self.contador+3;
              r.hl.w:=pop_sp;
            end;
        $e2:begin  {jp PO,nn >10t<}
              posicion.l:=spec_getbyte(r.pc);
              posicion.h:=spec_getbyte(r.pc+1);
              if not(r.f.p_v) then r.pc:=posicion.w
                 else r.pc:=r.pc+2;
              r.wz:=r.pc;
            end;
        $e3:begin   {ex (sp),hl >19t<}
                self.retraso(r.sp);self.contador:=self.contador+3;
                self.retraso(r.sp+1);self.contador:=self.contador+4;
                posicion.w:=pop_sp;
                push_sp(r.hl.w);
                self.retraso(r.sp);self.contador:=self.contador+3;
                self.retraso(r.sp+1);self.contador:=self.contador+3;
                self.retraso(r.sp+1);self.contador:=self.contador+1;
                self.retraso(r.sp+1);self.contador:=self.contador+1;
                r.hl:=posicion;
                r.wz:=posicion.w;
             end;
        $e4:begin  {call PO,nn >10 o 17t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                if not(r.f.p_v) then begin
                  self.retraso(r.pc);self.contador:=self.contador+1;
                  self.retraso(r.sp-1);self.contador:=self.contador+3;
                  self.retraso(r.sp-2);self.contador:=self.contador+3;
                  push_sp(r.pc);
                  r.pc:=posicion.w;
                end;
                r.wz:=r.pc;
             end;
        $e5:begin  //push HL >11t<
              self.contador:=self.contador+1;
              push_sp(r.hl.w);
              self.retraso(r.sp);self.contador:=self.contador+3;
              self.retraso(r.sp+1);self.contador:=self.contador+3;
            end;
        $e6:begin {and A,n >7t<}
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                and_a(temp);
             end;
        $e7:begin  {rst 20H >11t<}
                self.contador:=self.contador+1;
                self.retraso(r.sp-1);self.contador:=self.contador+3;
                self.retraso(r.sp-2);self.contador:=self.contador+3;
                push_sp(r.pc);
                r.pc:=$20;
                r.wz:=$20;
             end;
        $e8:begin {ret PE >5t o 11t<}
                self.contador:=self.contador+1;
                if r.f.p_v then begin
                    self.retraso(r.sp);self.contador:=self.contador+3;
                    self.retraso(r.sp+1);self.contador:=self.contador+3;
                    r.pc:=pop_sp;
                    r.wz:=r.pc;
                end;
             end;
        $e9:r.pc:=r.hl.w; {jp (HL) >4t<}
        $ea:begin {jp PE,nn >10t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                if r.f.p_v then r.pc:=posicion.w
                   else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $eb:begin { ex DE,HL >4t<}
                posicion:=r.de;
                r.de:=r.hl;
                r.hl:=posicion;
             end;
        $ec:begin  {call PE,nn >10t o 17t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                if r.f.p_v then begin
                  self.retraso(r.pc);self.contador:=self.contador+1;
                  self.retraso(r.sp-1);self.contador:=self.contador+3;
                  self.retraso(r.sp-2);self.contador:=self.contador+3;
                  push_sp(r.pc);
                  r.pc:=posicion.w;
                end;
                r.wz:=r.pc;
             end;
        $ed:self.exec_ed_sp;
        $ee:begin  {xor A,n >7t<}
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                xor_a(temp);
              end;
        $ef:begin  {rst 28H >11t<}
                self.contador:=self.contador+1;
                self.retraso(r.sp-1);self.contador:=self.contador+3;
                self.retraso(r.sp-2);self.contador:=self.contador+3;
                push_sp(r.pc);
                r.pc:=$28;
                r.wz:=$28;
             end;
        $f0:begin {ret NP >5t o 11t<}
              self.contador:=self.contador+1;
              if not(r.f.s) then begin
                  self.retraso(r.sp);self.contador:=self.contador+3;
                  self.retraso(r.sp+1);self.contador:=self.contador+3;
                  r.pc:=pop_sp;
                  r.wz:=r.pc;
              end;
             end;
        $f1:begin  {pop AF >10t<}
                self.retraso(r.sp);self.contador:=self.contador+3;
                self.retraso(r.sp+1);self.contador:=self.contador+3;
                posicion.w:=pop_sp;
                r.a:=posicion.h;
                r.f.s:=(posicion.l and 128)<>0;
                r.f.z:=(posicion.l and 64)<>0;
                r.f.bit5:=(posicion.l and 32)<>0;
                r.f.h:=(posicion.l and 16)<>0;
                r.f.bit3:=(posicion.l and 8)<>0;
                r.f.p_v:=(posicion.l and 4)<>0;
                r.f.n:=(posicion.l and 2)<>0;
                r.f.c:=(posicion.l and 1)<>0;
                end;
        $f2:begin {jp P,nn >10t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                if not(r.f.s) then r.pc:=posicion.w
                   else r.pc:=r.pc+2;
                r.wz:=r.pc;
             end;
        $f3:begin {di >4t<}
                r.iff1:=false;
                r.iff2:=false;
              end;
        $f4:begin {call P,nn >10t o 17t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                if not(r.f.s) then begin
                  self.retraso(r.pc);self.contador:=self.contador+1;
                  self.retraso(r.sp-1);self.contador:=self.contador+3;
                  self.retraso(r.sp-2);self.contador:=self.contador+3;
                  push_sp(r.pc);
                  r.pc:=posicion.w;
                end;
                r.wz:=r.pc;
             end;
        $f5:begin  {push AF >11t<}
                posicion.h:=r.a;
                posicion.l:=byte(r.f.s) shl 7;
                posicion.l:=posicion.l or (byte(r.f.z) shl 6);
                posicion.l:=posicion.l or (byte(r.f.bit5) shl 5);
                posicion.l:=posicion.l or (byte(r.f.h) shl 4);
                posicion.l:=posicion.l or (byte(r.f.bit3) shl 3);
                posicion.l:=posicion.l or (byte(r.f.p_v) shl 2);
                posicion.l:=posicion.l or (byte(r.f.n) shl 1);
                posicion.l:=posicion.l or byte(r.f.c);
                self.contador:=self.contador+1;
                self.retraso(r.sp-1);self.contador:=self.contador+3;
                self.retraso(r.sp-2);self.contador:=self.contador+3;
                push_sp(posicion.w);
             end;
        $f6:begin {or n >7t<}
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                or_a(temp);
             end;
        $f7:begin  {rst 30H >11t<}
                self.contador:=self.contador+1;
                self.retraso(r.sp-1);self.contador:=self.contador+3;
                self.retraso(r.sp-2);self.contador:=self.contador+3;
                push_sp(r.pc);
                r.pc:=$30;
                r.wz:=$30;
             end;
        $f8:begin {ret M >5t o 11t<}
              self.contador:=self.contador+1;
              if r.f.s then begin
                 self.retraso(r.sp);self.contador:=self.contador+3;
                 self.retraso(r.sp+1);self.contador:=self.contador+3;
                 r.pc:=pop_sp;
                 r.wz:=r.pc;
              end;
             end;
        $f9:begin  {ld SP,HL >6t<}
              self.contador:=self.contador+2;
              r.sp:=r.hl.w;
            end;
        $fa:begin {jp M,nn >10t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                if r.f.s then r.pc:=posicion.w
                   else r.pc:=r.pc+2;
                r.wz:=r.pc;
            end;
        $fb:begin   {ei >4t<}
                r.iff1:=true;
                r.iff2:=true;
                self.after_ei:=true;
             end;
        $fc:begin {call M,nn >10t o 17t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                if r.f.s then begin
                  self.retraso(r.pc);self.contador:=self.contador+1;
                  self.retraso(r.sp-1);self.contador:=self.contador+3;
                  self.retraso(r.sp-2);self.contador:=self.contador+3;
                  push_sp(r.pc);
                  r.pc:=posicion.w;
                end;
                r.wz:=r.pc;
             end;
        $fd:self.exec_dd_fd_sp(false);
        $fe:begin  {cp n >7t<}
                temp:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
                cp_a(temp);
            end;
        $ff:begin  {rst 38H >11t<}
                self.contador:=self.contador+1;
                self.retraso(r.sp-1);self.contador:=self.contador+3;
                self.retraso(r.sp-2);self.contador:=self.contador+3;
                push_sp(r.pc);
                r.pc:=$38;
                r.wz:=$38;
             end;
  end; {del case}
  cantidad_t:=self.contador-pcontador;
  spectrum_despues_instruccion(cantidad_t);
end; {del while}
end;

procedure cpu_z80_sp.exec_cb_sp;
var
        instruccion,temp:byte;
begin
self.retraso(r.pc);self.contador:=self.contador+4;
instruccion:=self.getbyte(r.pc);
r.pc:=r.pc+1;
r.r:=((r.r+1) and $7f) or (r.r and $80);
case instruccion of
        $00:rlc_8(@r.bc.h); {rlc B >8t<}
        $01:rlc_8(@r.bc.l); {rlc C >8t<}
        $02:rlc_8(@r.de.h); {rlc D >8t<}
        $03:rlc_8(@r.de.l); {rlc E >8t<}
        $04:rlc_8(@r.hl.h); {rlc H >8t<}
        $05:rlc_8(@r.hl.l); {rlc L >8t<}
        $06:begin {rlc (HL) >15t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                rlc_8(@temp);
                spec_putbyte(r.hl.w,temp);
            end;
        $07:rlc_8(@r.a); {rlc A >8t<}
        $08:rrc_8(@r.bc.h); {rlc B >8t<}
        $09:rrc_8(@r.bc.l); {rlc C >8t<}
        $0a:rrc_8(@r.de.h); {rlc D >8t<}
        $0b:rrc_8(@r.de.l); {rlc E >8t<}
        $0c:rrc_8(@r.hl.h); {rlc H >8t<}
        $0d:rrc_8(@r.hl.l); {rlc L >8t<}
        $0e:begin {rlc (HL) >15t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                rrc_8(@temp);
                spec_putbyte(r.hl.w,temp);
            end;
        $0f:rrc_8(@r.a); {rlc A >8t<}
        $10:rl_8(@r.bc.h); {rl B >8t<}
        $11:rl_8(@r.bc.l); {rl C >8t<}
        $12:rl_8(@r.de.h); {rl D >8t<}
        $13:rl_8(@r.de.l); {rl E >8t<}
        $14:rl_8(@r.hl.h); {rl H >8t<}
        $15:rl_8(@r.hl.l); {rl L >8t<}
        $16:begin {rl (HL) >15t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                rl_8(@temp);
                spec_putbyte(r.hl.w,temp);
            end;
        $17:rl_8(@r.a); {rl A >8t<}
        $18:rr_8(@r.bc.h); {rr B >8t<}
        $19:rr_8(@r.bc.l); {rr C >8t<}
        $1a:rr_8(@r.de.h); {rr D >8t<}
        $1b:rr_8(@r.de.l); {rr E >8t<}
        $1c:rr_8(@r.hl.h); {rr H >8t<}
        $1d:rr_8(@r.hl.l); {rr L >8t<}
        $1e:begin {rr (HL) >15t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                rr_8(@temp);
                spec_putbyte(r.hl.w,temp);
            end;
        $1f:rr_8(@r.a); {rr A >8t<}
        $20:sla_8(@r.bc.h); {sla B >8t<}
        $21:sla_8(@r.bc.l); {sla C >8t<}
        $22:sla_8(@r.de.h); {sla D >8t<}
        $23:sla_8(@r.de.l); {sla E >8t<}
        $24:sla_8(@r.hl.h); {sla H >8t<}
        $25:sla_8(@r.hl.l); {sla L >8t<}
        $26:begin {sla (HL) >15t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                sla_8(@temp);
                spec_putbyte(r.hl.w,temp);
            end;
        $27:sla_8(@r.a); {sla A >8t<}
        $28:r.bc.h:=sra_8(r.bc.h); //sra B >8t<
        $29:r.bc.l:=sra_8(r.bc.l); //sra C >8t<
        $2a:r.de.h:=sra_8(r.de.h); //sra D >8t<
        $2b:r.de.l:=sra_8(r.de.l); //sra E >8t<
        $2c:r.hl.h:=sra_8(r.hl.h); //sra H >8t<
        $2d:r.hl.l:=sra_8(r.hl.l); //sra L >8t<
        $2e:begin //sra (HL) >15t<
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                temp:=sra_8(temp);
                spec_putbyte(r.hl.w,temp);
            end;
        $2f:r.a:=sra_8(r.a); //sra A >8t<
        $30:sll_8(@r.bc.h); {sll B >8t<}
        $31:sll_8(@r.bc.l); {sll C >8t<}
        $32:sll_8(@r.de.h); {sll D >8t<}
        $33:sll_8(@r.de.l); {sll E >8t<}
        $34:sll_8(@r.hl.h); {sll H >8t<}
        $35:sll_8(@r.hl.l); {sll L >8t<}
        $36:begin  {sll (HL)}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                sll_8(@temp);
                spec_putbyte(r.hl.w,temp);
            end;
        $37:sll_8(@r.a); {sll a >8t<}
        $38:srl_8(@r.bc.h); {srl B >8t<}
        $39:srl_8(@r.bc.l); {srl C >8t<}
        $3a:srl_8(@r.de.h); {srl D >8t<}
        $3b:srl_8(@r.de.l); {srl E >8t<}
        $3c:srl_8(@r.hl.h); {srl H >8t<}
        $3d:srl_8(@r.hl.l); {srl L >8t<}
        $3e:begin  {srl (HL) >15t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                srl_8(@temp);
                spec_putbyte(r.hl.w,temp);
            end;
        $3f:srl_8(@r.a); {srl a >8t<}
        $40:bit_8(0,r.bc.h); {bit 0,B >8t<}
        $41:bit_8(0,r.bc.l); {bit 0,C >8t<}
        $42:bit_8(0,r.de.h); {bit 0,D >8t<}
        $43:bit_8(0,r.de.l); {bit 0,E >8t<}
        $44:bit_8(0,r.hl.h); {bit 0,H >8t<}
        $45:bit_8(0,r.hl.l); {bit 0,L >8t<}
        $46:begin  {bit 0,(HL) >12t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                bit_8(0,temp);
                r.f.bit5:=(r.wz and $20)<>0;
                r.f.bit3:=(r.wz and 8)<>0;
            end;
        $47:bit_8(0,r.a); {bit 0,A >8t<}
        $48:bit_8(1,r.bc.h); {bit 1,B >8t<}
        $49:bit_8(1,r.bc.l); {bit 1,C >8t<}
        $4a:bit_8(1,r.de.h); {bit 1,D >8t<}
        $4b:bit_8(1,r.de.l); {bit 1,E >8t<}
        $4c:bit_8(1,r.hl.h); {bit 1,H >8t<}
        $4d:bit_8(1,r.hl.l); {bit 1,L >8t<}
        $4e:begin  {bit 1,(HL) >12t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                bit_8(1,temp);
                r.f.bit5:=(r.wz and $20)<>0;
                r.f.bit3:=(r.wz and 8)<>0;
            end;
        $4f:bit_8(1,r.a); {bit 1,A >8t<}
        $50:bit_8(2,r.bc.h); {bit 2,B >8t<}
        $51:bit_8(2,r.bc.l); {bit 2,C >8t<}
        $52:bit_8(2,r.de.h); {bit 2,D >8t<}
        $53:bit_8(2,r.de.l);  {bit 2,E >8t<}
        $54:bit_8(2,r.hl.h);  {bit 2,H >8t<}
        $55:bit_8(2,r.hl.l);  {bit 2,L >8t<}
        $56:begin  {bit 2,(HL) >12t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                bit_8(2,temp);
                r.f.bit5:=(r.wz and $20)<>0;
                r.f.bit3:=(r.wz and 8)<>0;
            end;
        $57:bit_8(2,r.a); {bit 2,A >8t<}
        $58:bit_8(3,r.bc.h); {bit 3,B >8t<}
        $59:bit_8(3,r.bc.l); {bit 3,C >8t<}
        $5a:bit_8(3,r.de.h); {bit 3,D >8t<}
        $5b:bit_8(3,r.de.l); {bit 3,E >8t<}
        $5c:bit_8(3,r.hl.h); {bit 3,H >8t<}
        $5d:bit_8(3,r.hl.l); {bit 3,L >8t<}
        $5e:begin  {bit 3,(HL) >12t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                bit_8(3,temp);
                r.f.bit5:=(r.wz and $20)<>0;
                r.f.bit3:=(r.wz and 8)<>0;
            end;
        $5f:bit_8(3,r.a); {bit 3,A >8t<}
        $60:bit_8(4,r.bc.h); {bit 4,B >8t<}
        $61:bit_8(4,r.bc.l); {bit 4,C >8t<}
        $62:bit_8(4,r.de.h); {bit 4,D >8t<}
        $63:bit_8(4,r.de.l); {bit 4,E >8t<}
        $64:bit_8(4,r.hl.h); {bit 4,H >8t<}
        $65:bit_8(4,r.hl.l); {bit 4,L >8t<}
        $66:begin  {bit 4,(HL) >12t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                bit_8(4,temp);
                r.f.bit5:=(r.wz and $20)<>0;
                r.f.bit3:=(r.wz and 8)<>0;
            end;
        $67:bit_8(4,r.a); {bit 4,A >8t<}
        $68:bit_8(5,r.bc.h); {bit 5,B >8t<}
        $69:bit_8(5,r.bc.l); {bit 5,C >8t<}
        $6a:bit_8(5,r.de.h); {bit 5,D >8t<}
        $6b:bit_8(5,r.de.l); {bit 5,E >8t<}
        $6c:bit_8(5,r.hl.h); {bit 5,H >8t<}
        $6d:bit_8(5,r.hl.l); {bit 5,L >8t<}
        $6e:begin  {bit 5,(HL) >12t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                bit_8(5,temp);
                r.f.bit5:=(r.wz and $20)<>0;
                r.f.bit3:=(r.wz and 8)<>0;
            end;
        $6f:bit_8(5,r.a); {bit 5,A >8t<}
        $70:bit_8(6,r.bc.h); {bit 6,B >8t<}
        $71:bit_8(6,r.bc.l); {bit 6,C >8t<}
        $72:bit_8(6,r.de.h); {bit 6,D >8t<}
        $73:bit_8(6,r.de.l); {bit 6,E >8t<}
        $74:bit_8(6,r.hl.h); {bit 6,H >8t<}
        $75:bit_8(6,r.hl.l); {bit 6,L >8t<}
        $76:begin  {bit 6,(HL) >12t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                bit_8(6,temp);
                r.f.bit5:=(r.wz and $20)<>0;
                r.f.bit3:=(r.wz and 8)<>0;
            end;
        $77:bit_8(6,r.a);  {bit 6,A >8t<}
        $78:bit_7(r.bc.h); {bit 7,B >8t<}
        $79:bit_7(r.bc.l); {bit 7,C >8t<}
        $7a:bit_7(r.de.h); {bit 7,D >8t<}
        $7b:bit_7(r.de.l); {bit 7,E >8t<}
        $7c:bit_7(r.hl.h); {bit 7,H >8t<}
        $7d:bit_7(r.hl.l); {bit 7,L >8t<}
        $7e:begin  {bit 7,(HL) >12t<}
                temp:=spec_getbyte(r.hl.w);
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                bit_7(temp);
                r.f.bit5:=(r.wz and $20)<>0;
                r.f.bit3:=(r.wz and 8)<>0;
            end;
        $7f:bit_7(r.a); {bit 7,A >8t<}
        $80:r.bc.h:=(r.bc.h and $fe); {res 0,B >8t<}
        $81:r.bc.l:=(r.bc.l and $fe); {res 0,C >8t<}
        $82:r.de.h:=(r.de.h and $fe); {res 0,D >8t<}
        $83:r.de.l:=(r.de.l and $fe); {res 0,E >8t<}
        $84:r.hl.h:=(r.hl.h and $fe); {res 0,H >8t<}
        $85:r.hl.l:=(r.hl.l and $fe); {res 0,L >8t<}
        $86:begin  {res 0,(hl) >15t<}
                  temp:=(spec_getbyte(r.hl.w) and $fe);
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $87:r.a:=r.a and $fe; {res 0,A >8t<}
        $88:r.bc.h:=r.bc.h and $fd; {res 1,B >8t<}
        $89:r.bc.l:=r.bc.l and $fd; {res 1,C >8t<}
        $8a:r.de.h:=r.de.h and $fd; {res 1,D >8t<}
        $8b:r.de.l:=r.de.l and $fd; {res 1,E >8t<}
        $8c:r.hl.h:=r.hl.h and $fd; {res 1,H >8t<}
        $8d:r.hl.l:=r.hl.l and $fd; {res 1,L >8t<}
        $8e:begin  {res 1,(hl) >15t<}
                  temp:=(spec_getbyte(r.hl.w) and $fd);
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $8f:r.a:=r.a and $fd; {res 1,A >8t<}
        $90:r.bc.h:=r.bc.h and $fb; {res 2,B >8t<}
        $91:r.bc.l:=r.bc.l and $fb; {res 2,C >8t<}
        $92:r.de.h:=r.de.h and $fb; {res 2,D >8t<}
        $93:r.de.l:=r.de.l and $fb; {res 2,E >8t<}
        $94:r.hl.h:=r.hl.h and $fb; {res 2,H >8t<}
        $95:r.hl.l:=r.hl.l and $fb; {res 2,L >8t<}
        $96:begin  {res 2,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) and $fb;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $97:r.a:=r.a and $fb; {res 2,A}
        $98:r.bc.h:=r.bc.h and $f7; {res 3,B >8t<}
        $99:r.bc.l:=r.bc.l and $f7; {res 3,C >8t<}
        $9a:r.de.h:=r.de.h and $f7; {res 3,D >8t<}
        $9b:r.de.l:=r.de.l and $f7; {res 3,E >8t<}
        $9c:r.hl.h:=r.hl.h and $f7; {res 3,H >8t<}
        $9d:r.hl.l:=r.hl.l and $f7; {res 3,L >8t<}
        $9e:begin  {res 3,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) and $f7;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $9f:r.a:=r.a and $f7; {res 3,A}
        $a0:r.bc.h:=r.bc.h and $ef; {res 4,B >8t<}
        $a1:r.bc.l:=r.bc.l and $ef; {res 4,C >8t<}
        $a2:r.de.h:=r.de.h and $ef; {res 4,D >8t<}
        $a3:r.de.l:=r.de.l and $ef; {res 4,E >8t<}
        $a4:r.hl.h:=r.hl.h and $ef; {res 4,H >8t<}
        $a5:r.hl.l:=r.hl.l and $ef; {res 4,L >8t<}
        $a6:begin  {res 4,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) and $ef;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $a7:r.a:=r.a and $ef; {res 4,A >8t<}
        $a8:r.bc.h:=r.bc.h and $df; {res 5,B >8t<}
        $a9:r.bc.l:=r.bc.l and $df; {res 5,C >8t<}
        $aa:r.de.h:=r.de.h and $df; {res 5,D >8t<}
        $ab:r.de.l:=r.de.l and $df; {res 5,E >8t<}
        $ac:r.hl.h:=r.hl.h and $df; {res 5,H >8t<}
        $ad:r.hl.l:=r.hl.l and $df; {res 5,L >8t<}
        $ae:begin  {res 5,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) and $df;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $af:r.a:=r.a and $df; {res 5,A >8t<}
        $b0:r.bc.h:=r.bc.h and $bf; {res 6,B >8t<}
        $b1:r.bc.l:=r.bc.l and $bf; {res 6,C >8t<}
        $b2:r.de.h:=r.de.h and $bf; {res 6,D >8t<}
        $b3:r.de.l:=r.de.l and $bf; {res 6,E >8t<}
        $b4:r.hl.h:=r.hl.h and $bf; {res 6,H >8t<}
        $b5:r.hl.l:=r.hl.l and $bf; {res 6,L >8t<}
        $b6:begin  {res 6,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) and $bf;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $b7:r.a:=r.a and $bf; {res 6,A >8t<}
        $b8:r.bc.h:=r.bc.h and $7f; {res 7,B >8t<}
        $b9:r.bc.l:=r.bc.l and $7f; {res 7,C >8t<}
        $ba:r.de.h:=r.de.h and $7f; {res 7,D >8t<}
        $bb:r.de.l:=r.de.l and $7f; {res 7,E >8t<}
        $bc:r.hl.h:=r.hl.h and $7f; {res 7,H >8t<}
        $bd:r.hl.l:=r.hl.l and $7f; {res 7,L >8t<}
        $be:begin  {res 7,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) and $7f;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $bf:r.a:=r.a and $7f; {res 7,A >8t<}
        $c0:r.bc.h:=r.bc.h or $1; {set 0,B >8t<}
        $c1:r.bc.l:=r.bc.l or $1; {set 0,C >8t<}
        $c2:r.de.h:=r.de.h or $1; {set 0,D >8t<}
        $c3:r.de.l:=r.de.l or $1; {set 0,E >8t<}
        $c4:r.hl.h:=r.hl.h or $1; {set 0,H >8t<}
        $c5:r.hl.l:=r.hl.l or $1; {set 0,L >8t<}
        $c6:begin  {set 0,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) or 1;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $c7:r.a:=r.a or $1; {set 0,A >8t<}
        $c8:r.bc.h:=r.bc.h or $2; {set 1,B >8t<}
        $c9:r.bc.l:=r.bc.l or $2; {set 1,C >8t<}
        $ca:r.de.h:=r.de.h or $2; {set 1,D >8t<}
        $cb:r.de.l:=r.de.l or $2; {set 1,E >8t<}
        $cc:r.hl.h:=r.hl.h or $2; {set 1,H >8t<}
        $cd:r.hl.l:=r.hl.l or $2; {set 1,L >8t<}
        $ce:begin  {set 1,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) or 2;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $cf:r.a:=r.a or $2; {set 1,A >8t<}
        $d0:r.bc.h:=r.bc.h or $4; {set 2,B >8t<}
        $d1:r.bc.l:=r.bc.l or $4; {set 2,C >8t<}
        $d2:r.de.h:=r.de.h or $4; {set 2,D >8t<}
        $d3:r.de.l:=r.de.l or $4; {set 2,E >8t<}
        $d4:r.hl.h:=r.hl.h or $4; {set 2,H >8t<}
        $d5:r.hl.l:=r.hl.l or $4; {set 2,L >8t<}
        $d6:begin  {set 2,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) or 4;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $d7:r.a:=r.a or $4; {set 2,A >8t<}
        $d8:r.bc.h:=r.bc.h or $8; {set 3,B >8t<}
        $d9:r.bc.l:=r.bc.l or $8; {set 3,C >8t<}
        $da:r.de.h:=r.de.h or $8; {set 3,D >8t<}
        $db:r.de.l:=r.de.l or $8; {set 3,E >8t<}
        $dc:r.hl.h:=r.hl.h or $8; {set 3,H >8t<}
        $dd:r.hl.l:=r.hl.l or $8; {set 3,L >8t<}
        $de:begin  {set 3,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) or 8;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $df:r.a:=r.a or $8; {set 3,A >8t<}
        $e0:r.bc.h:=r.bc.h or $10; {set 4,B >8t<}
        $e1:r.bc.l:=r.bc.l or $10; {set 4,C >8t<}
        $e2:r.de.h:=r.de.h or $10; {set 4,D >8t<}
        $e3:r.de.l:=r.de.l or $10; {set 4,E >8t<}
        $e4:r.hl.h:=r.hl.h or $10; {set 4,H >8t<}
        $e5:r.hl.l:=r.hl.l or $10; {set 4,L >8t<}
        $e6:begin  {set 4,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) or $10;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $e7:r.a:=r.a or $10; {set 4,A >8t<}
        $e8:r.bc.h:=r.bc.h or $20; {set 5,B >8t<}
        $e9:r.bc.l:=r.bc.l or $20; {set 5,C >8t<}
        $ea:r.de.h:=r.de.h or $20; {set 5,D >8t<}
        $eb:r.de.l:=r.de.l or $20; {set 5,E >8t<}
        $ec:r.hl.h:=r.hl.h or $20; {set 5,H >8t<}
        $ed:r.hl.l:=r.hl.l or $20; {set 5,L >8t<}
        $ee:begin  {set 5,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) or $20;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $ef:r.a:=r.a or $20; {set 5,A >8t<}
        $f0:r.bc.h:=r.bc.h or $40; {set 6,B >8t<}
        $f1:r.bc.l:=r.bc.l or $40; {set 6,C >8t<}
        $f2:r.de.h:=r.de.h or $40; {set 6,D >8t<}
        $f3:r.de.l:=r.de.l or $40; {set 6,E >8t<}
        $f4:r.hl.h:=r.hl.h or $40; {set 6,H >8t<}
        $f5:r.hl.l:=r.hl.l or $40; {set 6,L >8t<}
        $f6:begin  {set 6,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) or $40;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $f7:r.a:=r.a or $40; {set 6,A >8t<}
        $f8:r.bc.h:=r.bc.h or $80; {set 7,B >8t<}
        $f9:r.bc.l:=r.bc.l or $80; {set 7,C >8t<}
        $fa:r.de.h:=r.de.h or $80; {set 7,D >8t<}
        $fb:r.de.l:=r.de.l or $80; {set 7,E >8t<}
        $fc:r.hl.h:=r.hl.h or $80; {set 7,H >8t<}
        $fd:r.hl.l:=r.hl.l or $80; {set 7,L >8t<}
        $fe:begin  {set 7,(HL) >15t<}
                  temp:=spec_getbyte(r.hl.w) or $80;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  spec_putbyte(r.hl.w,temp);
             end;
        $ff:r.a:=r.a or $80; {set 7,A >8t<}
end;
end;

procedure cpu_z80_sp.exec_dd_fd_sp(tipo:boolean);
var
 instruccion,temp:byte;
 temp2:word;
 registro:pparejas;
 posicion:parejas;
begin
if tipo then registro:=@r.ix else registro:=@r.iy;
temp2:=registro.w;
self.retraso(r.pc);self.contador:=self.contador+4;
instruccion:=self.getbyte(r.pc);
r.pc:=r.pc+1;
r.r:=((r.r+1) and $7f) or (r.r and $80);
case instruccion of
        $09:begin  //add IX,BC >15t<
              self.contador:=self.contador+7;
              registro.w:=add_16(registro.w,r.bc.w);
            end;
        $19:begin  //add IX,DE >15t<
              self.contador:=self.contador+7;
              registro.w:=add_16(registro.w,r.de.w);
            end;
        $21:begin {ld IX,nn >14t<}
                registro.l:=spec_getbyte(r.pc);
                registro.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
            end;
        $22:begin {ld (nn),IX >20t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                spec_putbyte(posicion.w,registro.l);
                spec_putbyte(posicion.w+1,registro.h);
                r.wz:=posicion.w+1;
            end;
        $23:begin  {inc IX >10t<}
              self.contador:=self.contador+2;
              inc(registro.w);
            end;
        $24:begin  //inc IXh >9t<
                registro.h:=inc_8(registro.h);
                inc(self.contador);
            end;
        $25:begin //dec IXh >9t<
                registro.h:=dec_8(registro.h);
                inc(self.contador);
            end;
        $26:begin  {ld IXh,n >11t<}
                registro.h:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $29:begin //add IX,IX >15t<
                inc(self.contador,7);
                registro.w:=add_16(registro.w,registro.w);
            end;
        $2a:begin {ld (IX,(nn) >20t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                registro.l:=spec_getbyte(posicion.w);
                registro.h:=spec_getbyte(posicion.w+1);
                r.wz:=posicion.w+1;
            end;
        $2b:begin {dec IX >10t<}
                inc(self.contador,2);
                dec(registro.w);
            end;
        $2c:begin  //inc IXl >9t<
                registro.l:=inc_8(registro.l);
                inc(self.contador);
            end;
        $2d:begin  //dec IXl >9t<
                registro.l:=dec_8(registro.l);
                inc(self.contador);
            end;
        $2e:begin  {ld IXl,n >11t<}
                registro.l:=spec_getbyte(r.pc);
                r.pc:=r.pc+1;
            end;
        $34:begin {inc (IX+d) >23t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                r.pc:=r.pc+1;
                temp:=spec_getbyte(temp2);
                self.retraso(temp2);self.contador:=self.contador+1;
                spec_putbyte(temp2,inc_8(temp));
            end;
        $35:begin {dec (IX+d) >23t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                r.pc:=r.pc+1;
                temp:=spec_getbyte(temp2);
                self.retraso(temp2);self.contador:=self.contador+1;
                spec_putbyte(temp2,dec_8(temp));
           end;
        $36:begin {ld (IX+d),n >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                r.pc:=r.pc+1;
                temp:=spec_getbyte(r.pc);
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                r.pc:=r.pc+1;
                spec_putbyte(temp2,temp);
            end;
        $39:begin //add IX,SP >15t<
                self.contador:=self.contador+7;
                registro.w:=add_16(registro.w,r.sp);
            end;
        $44:begin  {ld B,IXh >9t<}
                r.bc.h:=registro^.h;
                self.contador:=self.contador+1;
            end;
        $45:begin  {ld B,IXl >9t<}
                r.bc.h:=registro^.l;
                self.contador:=self.contador+1;
            end;
        $46:begin {ld B,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                r.pc:=r.pc+1;
                r.bc.h:=spec_getbyte(temp2);
            end;
        $4c:begin  {ld C,IXh >9t<}
                r.bc.l:=registro^.h;
                self.contador:=self.contador+1;
            end;
        $4d:begin  {ld C,IXl >9t<}
                r.bc.l:=registro^.l;
                self.contador:=self.contador+1;
            end;
        $4e:begin {ld C,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                r.pc:=r.pc+1;
                r.bc.l:=spec_getbyte(temp2);
            end;
        $54:begin   {ld D,IXh >9t<}
                r.de.h:=registro^.h;
                self.contador:=self.contador+1;
            end;
        $55:begin   {ld D,IXl >9t<}
                r.de.h:=registro^.l;
                self.contador:=self.contador+1;
            end;
        $56:begin {ld D,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                r.pc:=r.pc+1;
                r.de.h:=spec_getbyte(temp2);
            end;
        $5c:begin {ld E,IXh >9t<}
                r.de.l:=registro^.h;
                self.contador:=self.contador+1;
            end;
        $5d:begin   {ld E,IXh >9t<}
                r.de.l:=registro^.l;
                self.contador:=self.contador+1;
            end;
        $5e:begin {ld E,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                self.retraso(r.pc);self.contador:=self.contador+1;
                r.pc:=r.pc+1;
                r.de.l:=spec_getbyte(temp2);
            end;
        $60:begin   {ld IXh,B >9t<}
              registro^.h:=r.bc.h;
              inc(self.contador);
            end;
        $61:begin {ld IXh,C >9t<}
              registro^.h:=r.bc.l;
              inc(self.contador);
            end;
        $62:begin   {ld IXh,D >9t<}
              registro^.h:=r.de.h;
              inc(self.contador); 
            end;
        $63:begin   {ld IXh,E >9t<}
              registro^.h:=r.de.l;
              inc(self.contador); 
            end;
        $64:inc(self.contador); {ld IXh,IXh >9t>}
        $65:begin   {ld IXh,IXl >9t<}
              registro^.h:=registro^.l;
              inc(self.contador);
            end;
        $66:begin {ld H,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                r.pc:=r.pc+1;
                r.hl.h:=spec_getbyte(temp2);
            end;
        $67:begin   {ld IXh,A >9t<}
              registro^.h:=r.a;
              inc(self.contador); 
            end;
        $68:begin   {ld IXl,B >9t<}
              registro^.l:=r.bc.h;
              inc(self.contador);
            end;
        $69:begin   {ld IXl,C >9t<}
              registro^.l:=r.bc.l;
              inc(self.contador);
            end;
        $6a:begin   {ld IXl,D >9t<}
              registro^.l:=r.de.h;
              inc(self.contador); 
            end;
        $6b:begin   {ld IXl,E >9t<}
              registro^.l:=r.de.l;
              inc(self.contador); 
            end;
        $6c:begin   {ld IXl,IXh >9t<}
              registro^.l:=registro^.h;
              inc(self.contador); 
            end;
        $6d:inc(self.contador); {ld IXl,IXl >9t<}
        $6e:begin {ld L,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                r.pc:=r.pc+1;
                r.hl.l:=spec_getbyte(temp2);
            end;
        $6f:begin  {ld IXl,A >9t<}
                registro^.l:=r.a;
                inc(self.contador); 
            end;
        $70:begin {ld (IX+d),B >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                r.pc:=r.pc+1;
                spec_putbyte(temp2,r.bc.h);
            end;
        $71:begin {ld (IX+d),C >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                r.pc:=r.pc+1;
                spec_putbyte(temp2,r.bc.l);
            end;
        $72:begin {ld (IX+d),D >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                r.pc:=r.pc+1;
                spec_putbyte(temp2,r.de.h);
            end;
        $73:begin {ld (IX+d),E >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador); 
                r.pc:=r.pc+1;
                spec_putbyte(temp2,r.de.l);
            end;
        $74:begin {ld (IX+d),H >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                r.pc:=r.pc+1;
                spec_putbyte(temp2,r.hl.h);
            end;
        $75:begin {ld (IX+d),L >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                r.pc:=r.pc+1;
                spec_putbyte(temp2,r.hl.l);
            end;
        $77:begin {ld (IX+d),A >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador);
                r.pc:=r.pc+1;
                spec_putbyte(temp2,r.a);
            end;
        $7c:begin   {ld A,IXh >9t<}
                r.a:=registro^.h;
                inc(self.contador);
            end;
        $7d:begin {ld A,IXl >9t<}
                r.a:=registro^.l;
                inc(self.contador); 
            end;
        $7e:begin {ld A,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador);
                r.pc:=r.pc+1;
                r.a:=spec_getbyte(temp2);
            end;
        $84:begin   {add A,IXh >9t<}
              add_8(registro.h);
              inc(self.contador);
            end;
        $85:begin   {add A,IXl >9t<}
              add_8(registro.l);
              inc(self.contador); 
            end;
        $86:begin {add A,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador);
                r.pc:=r.pc+1;
                temp:=spec_getbyte(temp2);
                add_8(temp);
            end;
        $8c:begin   {adc A,IXh >9t<}
                adc_8(registro^.h);
                inc(self.contador);
            end;
        $8d:begin   {adc A,IXl >9t<}
                adc_8(registro^.l);
                inc(self.contador); 
            end;
        $8e:begin {adc A,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                r.pc:=r.pc+1;
                temp:=spec_getbyte(temp2);
                adc_8(temp);
        end;
        $94:begin  {sub IXh >9t<}
                sub_8(registro^.h);
                inc(self.contador);
            end;
        $95:begin  {sub IXh >9t<}
                sub_8(registro^.l);
                inc(self.contador);
            end;
        $96:begin {sub (IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador);
                r.pc:=r.pc+1;
                temp:=spec_getbyte(temp2);
                sub_8(temp);
        end;
        $9c:begin  {sbc IXh >9t<}
                sbc_8(registro^.h);
                inc(self.contador);
            end;
        $9d:begin  {sbc IXl >9t<}
                sbc_8(registro^.l);
                inc(self.contador); 
            end;
        $9e:begin {sbc (IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador);
                r.pc:=r.pc+1;
                temp:=spec_getbyte(temp2);
                sbc_8(temp);
        end;
        $a4:begin  {and IXh >9t<}
                and_a(registro^.h);
                inc(self.contador);
            end;
        $a5:begin  {and IXl >9t<}
                and_a(registro^.l);
                inc(self.contador);
            end;
        $a6:begin {and A,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador); 
                r.pc:=r.pc+1;
                temp:=spec_getbyte(temp2);
                and_a(temp);
        end;
        $ac:begin  {xor IXh >9t<}
                xor_a(registro^.h);
                inc(self.contador);
            end;
        $ad:begin  {xor IXl >9t<}
                xor_a(registro^.l);
                inc(self.contador); 
            end;
        $ae:begin {xor A,(IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                r.pc:=r.pc+1;
                temp:=spec_getbyte(temp2);
                xor_a(temp);
              end;
        $b4:begin   {or IXh >9t<}
                or_a(registro^.h);
                inc(self.contador);
            end;
        $b5:begin   {or IXl >9t<}
                or_a(registro^.l);
                inc(self.contador);
            end;
        $b6:begin  {or (IX+d) >19t<}
                 temp2:=temp2+shortint(spec_getbyte(r.pc));
                 r.wz:=temp2;
                 self.retraso(r.pc);inc(self.contador); 
                 self.retraso(r.pc);inc(self.contador); 
                 self.retraso(r.pc);inc(self.contador); 
                 self.retraso(r.pc);inc(self.contador); 
                 self.retraso(r.pc);inc(self.contador); 
                 r.pc:=r.pc+1;
                 temp:=spec_getbyte(temp2);
                 or_a(temp);
             end;
        $bc:begin  {cp IXh >9t<}
                cp_a(registro^.h);
                inc(self.contador);
            end;
        $bd:begin  {cp IXl >9t<}
                cp_a(registro^.l);
                inc(self.contador);
            end;
        $be:begin {cp (IX+d) >19t<}
                temp2:=temp2+shortint(spec_getbyte(r.pc));
                r.wz:=temp2;
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador);
                self.retraso(r.pc);inc(self.contador); 
                self.retraso(r.pc);inc(self.contador); 
                r.pc:=r.pc+1;
                temp:=spec_getbyte(temp2);
                cp_a(temp);
        end;
        $cb:self.exec_dd_cb_sp(tipo);
        $e1:begin
                self.retraso(r.sp);inc(self.contador,3);
                self.retraso(r.sp+1);inc(self.contador,3);
                registro.w:=pop_sp;  {pop IX >14t<}
            end;
        $e3:begin   {ex (SP),IX >23t<}
                self.retraso(r.sp);inc(self.contador,3);
                self.retraso(r.sp+1);inc(self.contador,3);
                posicion.w:=pop_sp;
                self.retraso(r.sp+1);inc(self.contador);
                push_sp(registro.w);
                self.retraso(r.sp+1);inc(self.contador,3);
                self.retraso(r.sp);inc(self.contador,3);
                self.retraso(r.sp);inc(self.contador);
                self.retraso(r.sp);inc(self.contador);
                registro.w:=posicion.w;
                r.wz:=posicion.w;
             end;
        $e5:begin  {push IX >15t<}
                inc(self.contador);
                self.retraso(r.sp-1);inc(self.contador,3);
                self.retraso(r.sp-2);inc(self.contador,3);
                push_sp(registro.w);
            end;
        $e9:r.pc:=registro.w; {jp IX >8t<}
        $f9:begin {ld SP,IX >10t<}
              inc(self.contador,2);
              r.sp:=registro.w;
            end;
        else dec(r.pc);
end;
end;

procedure cpu_z80_sp.exec_dd_cb_sp(tipo:boolean);
var
 tempb,instruccion:byte;
 temp2:word;
begin
if tipo then temp2:=r.ix.w else temp2:=r.iy.w;
self.retraso(r.pc);inc(self.contador,3);
instruccion:=self.getbyte(r.pc);
r.pc:=r.pc+1;
self.retraso(r.pc);inc(self.contador,3);
temp2:=temp2+shortint(instruccion);
r.wz:=temp2;
instruccion:=self.getbyte(r.pc);
self.retraso(r.pc);inc(self.contador);
self.retraso(r.pc);inc(self.contador);
r.pc:=r.pc+1;       //>16t<
case instruccion of
        $00:begin {ld B,rlc (IX+d) >23t<}
                r.bc.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rlc_8(@r.bc.h);
                spec_putbyte(temp2,r.bc.h);
            end;
        $01:begin {ld C,rlc (IX+d) >23t<}
                r.bc.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rlc_8(@r.bc.l);
                spec_putbyte(temp2,r.bc.l);
            end;
        $02:begin {ld D,rlc (IX+d) >23t<}
                r.de.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rlc_8(@r.de.h);
                spec_putbyte(temp2,r.de.h);
            end;
        $03:begin {ld E,rlc (IX+d) >23t<}
                r.de.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rlc_8(@r.de.l);
                spec_putbyte(temp2,r.de.l);
            end;
        $04:begin {ld H,rlc (IX+d) >23t<}
                r.hl.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rlc_8(@r.hl.h);
                spec_putbyte(temp2,r.hl.h);
            end;
        $05:begin {ld L,rlc (IX+d) >23t<}
                r.hl.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rlc_8(@r.hl.l);
                spec_putbyte(temp2,r.hl.l);
            end;
        $06:begin {rlc (IX+d) >23t<}
                tempb:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rlc_8(@tempb);
                spec_putbyte(temp2,tempb);
            end;
        $07:begin {ld A,rlc (IX+d) >23t<}
                r.a:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rlc_8(@r.a);
                spec_putbyte(temp2,r.a);
            end;
        $08:begin {ld B,rrc (IX+d) >23t<}
                r.bc.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rrc_8(@r.bc.h);
                spec_putbyte(temp2,r.bc.h);
            end;
        $09:begin {ld C,rrc (IX+d) >23t<}
                r.bc.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rrc_8(@r.bc.l);
                spec_putbyte(temp2,r.bc.l);
            end;
        $0a:begin {ld D,rrc (IX+d) >23t<}
                r.de.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rrc_8(@r.de.h);
                spec_putbyte(temp2,r.de.h);
            end;
        $0b:begin {ld E,rrc (IX+d) >23t<}
                r.de.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rrc_8(@r.de.l);
                spec_putbyte(temp2,r.de.l);
            end;
        $0c:begin {ld H,rrc (IX+d) >23t<}
                r.hl.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rrc_8(@r.hl.h);
                spec_putbyte(temp2,r.hl.h);
            end;
        $0d:begin {ld L,rlc (IX+d) >23t<}
                r.hl.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rrc_8(@r.hl.l);
                spec_putbyte(temp2,r.hl.l);
            end;
        $0e:begin   {rrc (IX+d)}
                tempb:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rrc_8(@tempb);
                spec_putbyte(temp2,tempb);
            end;
        $0f:begin {ld A,rrc (IX+d)}
                r.a:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rrc_8(@r.a);
                spec_putbyte(temp2,r.a);
            end;
        $10:begin {ld B,rl (IX+d)}
                r.bc.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rl_8(@r.bc.h);
                spec_putbyte(temp2,r.bc.h);
            end;
        $11:begin {ld C,rl (IX+d)}
                r.bc.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rl_8(@r.bc.l);
                spec_putbyte(temp2,r.bc.l);
            end;
        $12:begin {ld D,rl (IX+d)}
                r.de.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rl_8(@r.de.h);
                spec_putbyte(temp2,r.de.h);
            end;
        $13:begin {ld E,rl (IX+d)}
                r.de.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rl_8(@r.de.l);
                spec_putbyte(temp2,r.de.l);
            end;
        $14:begin {ld H,rl (IX+d)}
                r.hl.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rl_8(@r.hl.h);
                spec_putbyte(temp2,r.hl.h);
            end;
        $15:begin {ld L,rlc (IX+d)}
                r.hl.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rl_8(@r.hl.l);
                spec_putbyte(temp2,r.hl.l);
            end;
        $16:begin {rl (IX+d)}
                tempb:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rl_8(@tempb);
                spec_putbyte(temp2,tempb);
            end;
        $17:begin {ld A,rl (IX+d)}
                r.a:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rl_8(@r.a);
                spec_putbyte(temp2,r.a);
            end;
        $18:begin {ld B,rr (IX+d)}
                r.bc.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rr_8(@r.bc.h);
                spec_putbyte(temp2,r.bc.h);
            end;
        $19:begin {ld C,rr (IX+d)}
                r.bc.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rr_8(@r.bc.l);
                spec_putbyte(temp2,r.bc.l);
            end;
        $1a:begin {ld D,rr (IX+d)}
                r.de.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rr_8(@r.de.h);
                spec_putbyte(temp2,r.de.h);
            end;
        $1b:begin {ld E,rr (IX+d)}
                r.de.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rr_8(@r.de.l);
                spec_putbyte(temp2,r.de.l);
            end;
        $1c:begin {ld H,rr (IX+d)}
                r.hl.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rr_8(@r.hl.h);
                spec_putbyte(temp2,r.hl.h);
            end;
        $1d:begin {ld L,rr (IX+d)}
                r.hl.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rr_8(@r.hl.l);
                spec_putbyte(temp2,r.hl.l);
            end;
        $1e:begin  {rr (IX+d)}
                tempb:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rr_8(@tempb);
                spec_putbyte(temp2,tempb);
            end;
        $1f:begin {ld A,rr (IX+d)}
                r.a:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rr_8(@r.a);
                spec_putbyte(temp2,r.a);
            end;
        $20:begin {ld B,sla (IX+d)}
                r.bc.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sla_8(@r.bc.h);
                spec_putbyte(temp2,r.bc.h);
            end;
        $21:begin {ld C,sla (IX+d)}
                r.bc.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sla_8(@r.bc.l);
                spec_putbyte(temp2,r.bc.l);
            end;
        $22:begin {ld D,sla (IX+d)}
                r.de.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sla_8(@r.de.h);
                spec_putbyte(temp2,r.de.h);
            end;
        $23:begin {ld E,sla (IX+d)}
                r.de.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                rlc_8(@r.de.l);
                spec_putbyte(temp2,r.de.l);
            end;
        $24:begin {ld H,sla (IX+d)}
                r.hl.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sla_8(@r.hl.h);
                spec_putbyte(temp2,r.hl.h);
            end;
        $25:begin {ld L,sla (IX+d)}
                r.hl.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sla_8(@r.hl.l);
                spec_putbyte(temp2,r.hl.l);
            end;
        $26:begin  {sla (IX+d)}
                tempb:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sla_8(@tempb);
                spec_putbyte(temp2,tempb);
            end;
        $27:begin {ld A,sla (IX+d)}
                r.a:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sla_8(@r.a);
                spec_putbyte(temp2,r.a);
            end;
        $28:begin //ld B,sra (IX+d)
                r.bc.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                r.bc.h:=sra_8(r.bc.h);
                spec_putbyte(temp2,r.bc.h);
            end;
        $29:begin //ld C,sra (IX+d)
                r.bc.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                r.bc.l:=sra_8(r.bc.l);
                spec_putbyte(temp2,r.bc.l);
            end;
        $2a:begin //ld D,sra (IX+d)
                r.de.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                r.de.h:=sra_8(r.de.h);
                spec_putbyte(temp2,r.de.h);
            end;
        $2b:begin //ld E,sra (IX+d)
                r.de.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                r.de.l:=sra_8(r.de.l);
                spec_putbyte(temp2,r.de.l);
            end;
        $2c:begin //ld H,sra (IX+d)
                r.hl.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                r.hl.h:=sra_8(r.hl.h);
                spec_putbyte(temp2,r.hl.h);
            end;
        $2d:begin //ld L,sra (IX+d)
                r.hl.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                r.hl.l:=sra_8(r.hl.l);
                spec_putbyte(temp2,r.hl.l);
            end;
        $2e:begin  {sra (IX+d)}
                tempb:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                tempb:=sra_8(tempb);
                spec_putbyte(temp2,tempb);
            end;
        $2f:begin {ld A,sra (IX+d)}
                r.a:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                r.a:=sra_8(r.a);
                spec_putbyte(temp2,r.a);
            end;
        $30:begin {ld B,sll (IX+d)}
                r.bc.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sll_8(@r.bc.h);
                spec_putbyte(temp2,r.bc.h);
            end;
        $31:begin {ld C,sll (IX+d)}
                r.bc.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sll_8(@r.bc.l);
                spec_putbyte(temp2,r.bc.l);
            end;
        $32:begin {ld D,sll (IX+d)}
                r.de.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sll_8(@r.de.h);
                spec_putbyte(temp2,r.de.h);
            end;
        $33:begin {ld E,sll (IX+d)}
                r.de.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sll_8(@r.de.l);
                spec_putbyte(temp2,r.de.l);
            end;
        $34:begin {ld H,sll (IX+d)}
                r.hl.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sll_8(@r.hl.h);
                spec_putbyte(temp2,r.hl.h);
            end;
        $35:begin {ld L,sll (IX+d)}
                r.hl.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sll_8(@r.hl.l);
                spec_putbyte(temp2,r.hl.l);
            end;
        $36:begin {sll (IX+d)}
                tempb:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sll_8(@tempb);
                spec_putbyte(temp2,tempb);
            end;
        $37:begin {ld A,sll (IX+d)}
                r.a:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                sll_8(@r.a);
                spec_putbyte(temp2,r.a);
            end;
        $38:begin {ld B,srl (IX+d)}
                r.bc.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                srl_8(@r.bc.h);
                spec_putbyte(temp2,r.bc.h);
            end;
        $39:begin {ld C,srl (IX+d)}
                r.bc.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                srl_8(@r.bc.l);
                spec_putbyte(temp2,r.bc.l);
            end;
        $3a:begin {ld D,srl (IX+d)}
                r.de.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                srl_8(@r.de.h);
                spec_putbyte(temp2,r.de.h);
            end;
        $3b:begin {ld E,srl (IX+d)}
                r.de.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                srl_8(@r.de.l);
                spec_putbyte(temp2,r.de.l);
            end;
        $3c:begin {ld H,srl (IX+d)}
                r.hl.h:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                srl_8(@r.hl.h);
                spec_putbyte(temp2,r.hl.h);
            end;
        $3d:begin {ld L,srl (IX+d)}
                r.hl.l:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                srl_8(@r.hl.l);
                spec_putbyte(temp2,r.hl.l);
            end;
        $3e:begin  {srl (IX+d)}
                tempb:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                srl_8(@tempb);
                spec_putbyte(temp2,tempb);
            end;
        $3f:begin {ld A,srl (IX+d)}
                r.a:=spec_getbyte(temp2);
                self.retraso(temp2);inc(self.contador);
                srl_8(@r.a);
                spec_putbyte(temp2,r.a);
            end;
        $40..$47:begin {bit 0,(IX+d)}
                 tempb:=spec_getbyte(temp2);
                 self.retraso(temp2);inc(self.contador);
                 bit_8(0,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $48..$4f:begin {bit 1,(IX+d)}
                 tempb:=spec_getbyte(temp2);
                 self.retraso(temp2);inc(self.contador);
                 bit_8(1,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $50..$57:begin {bit 2,(IX+d)}
                 tempb:=spec_getbyte(temp2);
                 self.retraso(temp2);inc(self.contador);
                 bit_8(2,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $58..$5f:begin {bit 3,(IX+d)}
                 tempb:=spec_getbyte(temp2);
                 self.retraso(temp2);inc(self.contador);
                 bit_8(3,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $60..$67:begin {bit 4,(IX+d)}
                 tempb:=spec_getbyte(temp2);
                 self.retraso(temp2);inc(self.contador);
                 bit_8(4,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $68..$6f:begin {bit 5,(IX+d)}
                 tempb:=spec_getbyte(temp2);
                 self.retraso(temp2);inc(self.contador);
                 bit_8(5,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $70..$77:begin {bit 6,(IX+d)}
                 tempb:=spec_getbyte(temp2);
                 self.retraso(temp2);inc(self.contador);
                 bit_8(6,tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $78..$7f:begin {bit 7,(IX+d)}
                 tempb:=spec_getbyte(temp2);
                 self.retraso(temp2);inc(self.contador);
                 bit_7(tempb);
                 r.f.bit5:=(temp2 and $2000)<>0;
                 r.f.bit3:=(temp2 and $800)<>0;
            end;
        $80:begin {ld B,res 0,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) and $fe;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $81:begin {ld C,res 0,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) and $fe;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $82:begin {ld D,res 0,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) and $fe;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $83:begin {ld E,res 0,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) and $fe;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $84:begin {ld H,res 0,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) and $fe;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $85:begin {ld L,res 0,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) and $fe;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $86:begin {res 0,(IX+d)}
                 tempb:=spec_getbyte(temp2) and $fe;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
            end;
        $87:begin		// LD A,RES 0,(REGISTER+dd) */
                  r.a:=spec_getbyte(temp2) and $fe;
                  self.retraso(temp2);inc(self.contador);
                  spec_putbyte(temp2,r.a);
            end;
        $88:begin		// LD B,RES 1,(REGISTER+dd) */
                  r.bc.h:=spec_getbyte(temp2) and $fd;
                  self.retraso(temp2);inc(self.contador);
                  spec_putbyte(temp2,r.bc.h);
            end;
        $89:begin		// LD C,RES 1,(REGISTER+dd) */
                  r.bc.l:=spec_getbyte(temp2) and $fd;
                  self.retraso(temp2);inc(self.contador);
                  spec_putbyte(temp2,r.bc.l);
            end;
        $8a:begin		// LD D,RES 1,(REGISTER+dd) */
                  r.de.h:=spec_getbyte(temp2) and $fd;
                  self.retraso(temp2);inc(self.contador);
                  spec_putbyte(temp2,r.de.h);
            end;
        $8b:begin		// LD E,RES 1,(REGISTER+dd) */
                  r.de.l:=spec_getbyte(temp2) and $fd;
                  self.retraso(temp2);inc(self.contador);
                  spec_putbyte(temp2,r.de.l);
            end;
        $8c:begin		// LD H,RES 1,(REGISTER+dd) */
                  r.hl.h:=spec_getbyte(temp2) and $fd;
                  self.retraso(temp2);inc(self.contador);
                  spec_putbyte(temp2,r.hl.h);
            end;
        $8d:begin		// LD L,RES 1,(REGISTER+dd) */
                  r.hl.l:=spec_getbyte(temp2) and $fd;
                  self.retraso(temp2);inc(self.contador);
                  spec_putbyte(temp2,r.hl.l);
            end;
        $8e:begin {res 1,(IX+d)}
                 tempb:=spec_getbyte(temp2) and $fd;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
            end;
        $8f:begin {ld A,res 1,(IX+d)}
                 r.a:=spec_getbyte(temp2) and $fd;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $90:begin {ld B,res 2,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) and $fb;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $91:begin {ld C,res 2,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) and $fb;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $92:begin {ld D,res 2,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) and $fb;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $93:begin {ld E,res 2,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) and $fb;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $94:begin {ld H,res 2,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) and $fb;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $95:begin {ld L,res 2,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) and $fb;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $96:begin {res 2,(IX+d)}
                 tempb:=spec_getbyte(temp2) and $fb;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
            end;
        $97:begin {ld A,res 2,(IX+d)}
                 r.a:=spec_getbyte(temp2) and $fb;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $98:begin {ld B,res 3,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) and $f7;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $99:begin {ld C,res 3,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) and $f7;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $9a:begin {ld D,res 3,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) and $f7;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $9b:begin {ld E,res 3,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) and $f7;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $9c:begin {ld H,res 3,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) and $f7;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $9d:begin {ld L,res 3,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) and $f7;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $9e:begin {res 3,(IX+d)}
                 tempb:=spec_getbyte(temp2) and $f7;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
            end;
        $9f:begin {ld A,res 3,(IX+d)}
                 r.a:=spec_getbyte(temp2) and $f7;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $a0:begin {ld B,res 4,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) and $ef;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $a1:begin {ld C,res 4,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) and $ef;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $a2:begin {ld D,res 4,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) and $ef;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $a3:begin {ld E,res 4,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) and $ef;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $a4:begin {ld H,res 4,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) and $ef;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $a5:begin {ld L,res 4,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) and $ef;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $a6:begin {res 4,(IX+d)}
                 tempb:=spec_getbyte(temp2) and $ef;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
            end;
        $a7:begin {ld A,res 4,(IX+d)}
                 r.a:=spec_getbyte(temp2) and $ef;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $a8:begin {ld B,res 5,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) and $df;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $a9:begin {ld C,res 5,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) and $df;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $aa:begin {ld D,res 5,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) and $df;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $ab:begin {ld E,res 5,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) and $df;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $ac:begin {ld H,res 5,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) and $df;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $ad:begin {ld L,res 5,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) and $df;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $ae:begin {res 5,(IX+d)}
                 tempb:=spec_getbyte(temp2) and $df;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
            end;
        $af:begin {ld A,res 5,(IX+d)}
                 r.a:=spec_getbyte(temp2) and $df;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $b0:begin {ld B,res 6,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) and $bf;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $b1:begin {ld C,res 6,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) and $bf;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $b2:begin {ld D,res 6,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) and $bf;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $b3:begin {ld E,res 6,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) and $bf;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $b4:begin {ld H,res 6,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) and $bf;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $b5:begin {ld L,res 6,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) and $bf;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $b6:begin {res 6,(IX+d)}
                 tempb:=spec_getbyte(temp2) and $bf;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
            end;
        $b7:begin {ld A,res 6,(IX+d)}
                 r.a:=spec_getbyte(temp2) and $bf;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $b8:begin {ld B,res 7,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) and $7f;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $b9:begin {ld C,res 7,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) and $7f;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $ba:begin {ld D,res 7,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) and $7f;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $bb:begin {ld E,res 7,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) and $7f;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $bc:begin {ld H,res 7,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) and $7f;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $bd:begin {ld L,res 7,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) and $7f;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $be:begin {res 7,(IX+d)}
                 tempb:=spec_getbyte(temp2) and $7f;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
            end;
        $bf:begin {ld A,res 7,(IX+d)}
                 r.a:=spec_getbyte(temp2) and $7f;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $c0:begin {ld B,set 0,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) or 1;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $c1:begin {ld C,set 0,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) or 1;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $c2:begin {ld D,set 0,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) or 1;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $c3:begin {ld E,set 0,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) or 1;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $c4:begin {ld H,set 0,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) or 1;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $c5:begin {ld L,set 0,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) or 1;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $c6:begin {set 0,(IX+d)}
                 tempb:=spec_getbyte(temp2) or 1;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
              end;
        $c7:begin {ld A,set 0,(IX+d)}
                 r.a:=spec_getbyte(temp2) or 1;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $c8:begin {ld B,set 1,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) or 2;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $c9:begin {ld C,set 1,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) or 2;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $ca:begin {ld D,set 1,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) or 2;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $cb:begin {ld E,set 1,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) or 2;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $cc:begin {ld H,set 1,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) or 2;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $cd:begin {ld L,set 1,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) or 2;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $ce:begin {set 1,(IX+d)}
                 tempb:=spec_getbyte(temp2) or 2;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
              end;

        $cf:begin {ld A,set 1,(IX+d)}
                 r.a:=spec_getbyte(temp2) or 2;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $d0:begin {ld B,set 2,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) or 4;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $d1:begin {ld C,set 2,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) or 4;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $d2:begin {ld D,set 2,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) or 4;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $d3:begin {ld E,set 2,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) or 4;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $d4:begin {ld H,set 2,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) or 4;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $d5:begin {ld L,set 2,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) or 4;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $d6:begin {set 2,(IX+d)}
                 tempb:=spec_getbyte(temp2) or 4;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
              end;
        $d7:begin {ld A,set 2,(IX+d)}
                 r.a:=spec_getbyte(temp2) or 4;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $d8:begin {ld B,set 3,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) or 8;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $d9:begin {ld C,set 3,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) or 8;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $da:begin {ld D,set 3,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) or 8;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $db:begin {ld E,set 3,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) or 8;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $dc:begin {ld H,set 3,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) or 8;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $dd:begin {ld L,set 3,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) or 8;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $de:begin {set 3,(IX+d)}
                 tempb:=spec_getbyte(temp2) or 8;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
              end;
        $df:begin {ld A,set 3,(IX+d)}
                 r.a:=spec_getbyte(temp2) or 8;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $e0:begin {ld B,set 4,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) or $10;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $e1:begin {ld C,set 4,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) or $10;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $e2:begin {ld D,set 4,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) or $10;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $e3:begin {ld E,set 4,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) or $10;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $e4:begin {ld H,set 4,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) or $10;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $e5:begin {ld L,set 4,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) or $10;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $e6:begin {set 4,(IX+d)}
                 tempb:=spec_getbyte(temp2) or $10;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
              end;
        $e7:begin {ld A,set 4,(IX+d)}
                 r.a:=spec_getbyte(temp2) or $10;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $e8:begin {ld B,set 5,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) or $20;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $e9:begin {ld C,set 5,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) or $20;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $ea:begin {ld D,set 5,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) or $20;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $eb:begin {ld E,set 5,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) or $20;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $ec:begin {ld H,set 5,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) or $20;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $ed:begin {ld L,set 5,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) or $20;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $ee:begin {set 5,(IX+d)}
                 tempb:=spec_getbyte(temp2) or $20;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
              end;
        $ef:begin {ld A,set 5,(IX+d)}
                 r.a:=spec_getbyte(temp2) or $20;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $f0:begin {ld B,set 6,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) or $40;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $f1:begin {ld C,set 6,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) or $40;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $f2:begin {ld D,set 6,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) or $40;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $f3:begin {ld E,set 6,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) or $40;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $f4:begin {ld H,set 6,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) or $40;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $f5:begin {ld L,set 6,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) or $40;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $f6:begin {set 6,(IX+d)}
                 tempb:=spec_getbyte(temp2) or $40;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
              end;
        $f7:begin {ld A,set 6,(IX+d)}
                 r.a:=spec_getbyte(temp2) or $40;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
        $f8:begin {ld B,set 7,(IX+d)}
                 r.bc.h:=spec_getbyte(temp2) or $80;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.h);
            end;
        $f9:begin {ld C,set 7,(IX+d)}
                 r.bc.l:=spec_getbyte(temp2) or $80;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.bc.l);
            end;
        $fa:begin {ld D,set 7,(IX+d)}
                 r.de.h:=spec_getbyte(temp2) or $80;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.h);
            end;
        $fb:begin {ld E,set 7,(IX+d)}
                 r.de.l:=spec_getbyte(temp2) or $80;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.de.l);
            end;
        $fc:begin {ld H,set 7,(IX+d)}
                 r.hl.h:=spec_getbyte(temp2) or $80;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.h);
            end;
        $fd:begin {ld L,set 7,(IX+d)}
                 r.hl.l:=spec_getbyte(temp2) or $80;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.hl.l);
            end;
        $fe:begin {set 7,(IX+d)}
                 tempb:=spec_getbyte(temp2) or $80;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,tempb);
              end;
        $ff:begin {ld A,set 7,(IX+d)}
                 r.a:=spec_getbyte(temp2) or $80;
                 self.retraso(temp2);inc(self.contador);
                 spec_putbyte(temp2,r.a);
            end;
  end;
end;

procedure cpu_z80_sp.exec_ed_sp;
var
        instruccion,temp,temp2,temp3:byte;
        tempw:word;
        posicion:parejas;
begin
self.retraso(r.pc);self.contador:=self.contador+4;
instruccion:=self.getbyte(r.pc);
r.pc:=r.pc+1;
r.r:=((r.r+1) and $7f) or (r.r and $80);
case instruccion of
        $40:begin {in B,(c) >12t<}
                r.bc.h:=spec_inbyte(r.bc.w);
                r.f.z:=(r.bc.h=0);
                r.f.s:=(r.bc.h And $80)<>0;
                r.f.bit3:=(r.bc.h And 8)<>0;
                r.f.bit5:=(r.bc.h And $20)<>0;
                r.f.p_v:=paridad[r.bc.h];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $41:spec_outbyte(r.bc.w,r.bc.h); {out (C),B >12t<}
        $42:begin  //sbc HL,BC >15t<
              self.contador:=self.contador+7;
              r.hl.w:=sbc_hl(r.bc.w);
            end;
        $43:begin {ld (nn),BC >20t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                spec_putbyte(posicion.w,r.bc.l);
                spec_putbyte(posicion.w+1,r.bc.h);
                r.wz:=posicion.w+1;
            end;
        $44,$4c,$54,$5c,$64,$6c,$74,$7c:begin  {neg >8t<}
                temp:=r.a;
                r.a:=0;
                sub_8(temp);
            end;
        $45,$55,$65,$75:begin  {retn >12t<}
                self.retraso(r.sp);self.contador:=self.contador+3;
                self.retraso(r.sp+1);self.contador:=self.contador+3;
                r.pc:=pop_sp;
                r.wz:=r.pc;
                r.iff1:=r.iff2;
            end;
        $46,$4e,$66,$6e:r.im:=0; {im 0 >8t<}
        $47:begin   {ld I,A >9t<}
              self.contador:=self.contador+1;
              r.i:=r.a;
            end;
        $48:begin {in C,(C) >12t<}
                r.bc.l:=spec_inbyte(r.bc.w);
                r.f.z:=(r.bc.l=0);
                r.f.s:=(r.bc.l And $80) <> 0;
                r.f.bit3:=(r.bc.l And 8) <> 0;
                r.f.bit5:=(r.bc.l And $20) <> 0;
                r.f.p_v:=paridad[r.bc.l];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $49:spec_outbyte(r.bc.w,r.bc.l); {out (C),C >12t<}
        $4a:begin  //adc HL,BC >15t<
              self.contador:=self.contador+7;
              r.hl.w:=adc_hl(r.bc.w);
            end;
        $4b:begin  {ld BC,(nn) >20t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                r.bc.l:=spec_getbyte(posicion.w);
                r.bc.h:=spec_getbyte(posicion.w+1);
                r.wz:=posicion.w+1;
            end;
        //4c: neg
        $4d,$5d,$6d,$7d:begin   {reti}
                r.iff1:=r.iff2;
                self.retraso(r.sp);self.contador:=self.contador+3;
                self.retraso(r.sp+1);self.contador:=self.contador+3;
                r.pc:=pop_sp;
                r.wz:=r.pc;
                if self.daisy then z80daisy_reti;
            end;
        //4e: im 0
        $4f:begin  {ld R,A >9t<}
              self.contador:=self.contador+1;
              r.r:=r.a;
            end;
        $50:begin {in D,(c) >12t<}
                r.de.h:=spec_inbyte(r.bc.w);
                r.f.z:=(r.de.h=0);
                r.f.s:=(r.de.h And $80) <> 0;
                r.f.bit3:=(r.de.h And 8) <> 0;
                r.f.bit5:=(r.de.h And $20) <> 0;
                r.f.p_v:=paridad[r.de.h];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $51:spec_outbyte(r.bc.w,r.de.h); {out (C),D >12t<}
        $52:begin //sbc HL,DE >15t<
              self.contador:=self.contador+7;
              r.hl.w:=sbc_hl(r.de.w);
            end;
        $53:begin {ld (nn),DE >20t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                spec_putbyte(posicion.w,r.de.l);
                spec_putbyte(posicion.w+1,r.de.h);
                r.wz:=posicion.w+1;
            end;
        {54: neg
        $55:retn}
        $56,$76:r.im:=1; {im 1 >8t<}
        $57:begin  {ld A,I >9t<}
                self.contador:=self.contador+1;
                r.a:=r.i;
                r.f.s:=(r.a and $80)<>0;
                r.f.z:=(r.a=0);
                r.f.bit5:=(r.a and $20)<>0;
                r.f.h:=false;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.p_v:=r.iff2;
                r.f.n:=false;
            end;
        $58:begin  {in E,(C) >12t<}
                r.de.l:=spec_inbyte(r.bc.w);
                r.f.z:=(r.de.l=0);
                r.f.s:=(r.de.l And $80) <> 0;
                r.f.bit3:=(r.de.l And 8) <> 0;
                r.f.bit5:=(r.de.l And $20) <> 0;
                r.f.p_v:=paridad[r.de.l];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $59:spec_outbyte(r.bc.w,r.de.l); {out (C),E >12t<}
        $5a:begin //adc HL,DE >15t<
              self.contador:=self.contador+7;
              r.hl.w:=adc_hl(r.de.w);
            end;
        $5b:begin  {ld DE,(nn) >20t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                r.de.l:=spec_getbyte(posicion.w);
                r.de.h:=spec_getbyte(posicion.w+1);
                r.wz:=posicion.w+1;
            end;
        {5c:neg
        5d:retn}
        $5e,$7e:r.im:=2; {im 2 >8t<}
        $5f:begin  {ld A,R >9t<}
                self.contador:=self.contador+1;
                r.a:=r.r;
                r.f.h:=false;
                r.f.n:=false;
                r.f.p_v:=r.iff2;
                r.f.bit5:=(r.a and $20)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.s:=(r.a and $80)<>0;
                r.f.z:=(r.a=0);
            end;
        $60:begin  {in H,(c) >12t<}
                r.hl.h:=spec_inbyte(r.bc.w);
                r.f.z:=(r.hl.h=0);
                r.f.s:=(r.hl.h And $80) <> 0;
                r.f.bit3:=(r.hl.h And 8) <> 0;
                r.f.bit5:=(r.hl.h And $20) <> 0;
                r.f.p_v:=paridad[r.hl.h];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $61:spec_outbyte(r.bc.w,r.hl.h); {out (C),H >12t<}
        $62:begin  //sbc HL,HL >15t<
                self.contador:=self.contador+7;
                r.hl.w:=sbc_hl(r.hl.w);
            end;
        $63:begin {ld (nn),HL >20t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                spec_putbyte(posicion.w,r.hl.l);
                spec_putbyte(posicion.w+1,r.hl.h);
                r.wz:=posicion.w+1;
            end;
        {64:neg
        $65:retn
        $66:im 0}
        $67:begin {rrd >18t<}
                temp2:=spec_getbyte(r.hl.w);
                r.wz:=r.hl.w+1;
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                temp:=(r.a and $f)*16;
                r.a:=(r.a and $f0)+ (temp2 and $f);
                temp2:=(temp2 div 16) + temp;
                spec_putbyte(r.hl.w,temp2);
                r.f.s:=(r.a and $80)<>0;
                r.f.z:=(r.a=0);
                r.f.bit5:=(r.a and $20)<>0;
                r.f.h:=false;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.p_v:=paridad[r.a];
                r.f.n:=false;
            end;
        $68:begin {in L,(c) >12t<}
                r.hl.l:=spec_inbyte(r.bc.w);
                r.f.z:=(r.hl.l=0);
                r.f.s:=(r.hl.l And $80) <> 0;
                r.f.bit3:=(r.hl.l And 8) <> 0;
                r.f.bit5:=(r.hl.l And $20) <> 0;
                r.f.p_v:=paridad[r.hl.l];
                r.f.n:=false;
                r.f.h:=false;
             end;
        $69:spec_outbyte(r.bc.w,r.hl.l); {out (C),L >12t<}
        $6a:begin  //adc HL,HL >15t<
                self.contador:=self.contador+7;
                r.hl.w:=adc_hl(r.hl.w);
            end;
        $6b:begin  {ld HL,(nn) >20t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                r.hl.l:=spec_getbyte(posicion.w);
                r.hl.h:=spec_getbyte(posicion.w+1);
                r.wz:=posicion.w+1;
            end;
        {6c:neg
        $6d:retn
        $6e:im 0}
        $6f:begin  {rld >18t<}
                temp2:=spec_getbyte(r.hl.w);
                r.wz:=r.hl.w+1;
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                self.retraso(r.hl.w);self.contador:=self.contador+1;
                temp:=r.a and $0f;
                r.a:=(r.a  and $F0)+ (temp2 div 16);
                temp2:=(temp2*16) + temp;
                spec_putbyte(r.hl.w,temp2);
                r.f.s:=(r.a and $80)<>0;
                r.f.z:=(r.a=0);
                r.f.bit5:=(r.a and $20)<>0;
                r.f.h:=false;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.p_v:=paridad[r.a];
                r.f.n:=false;
            end;
        $70:begin  {in (C) >12t<}
                temp:=spec_inbyte(r.bc.w);
                r.f.z:=(temp=0);
                r.f.s:=(temp And $80) <> 0;
                r.f.bit3:=(temp And 8) <> 0;
                r.f.bit5:=(temp And $20) <> 0;
                r.f.p_v:=paridad[temp];
                r.f.n:=false;
                r.f.h:=false;
            end;
        $71:spec_outbyte(r.bc.w,0); {out (C),0 >12t<}
        $72:begin  //sbc HL,SP >15t<
              self.contador:=self.contador+7;
              r.hl.w:=sbc_hl(r.sp);
            end;
        $73:begin {ld (nn),SP >20t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                spec_putbyte(posicion.w,r.sp and $ff);
                spec_putbyte(posicion.w+1,r.sp shr 8);
                r.wz:=posicion.w+1;
            end;
        {74:neg
        $75:retn
        $76:im 1
        $77:nop*2}
        $78:begin       {in A,(C) >12t<}
                r.a:=spec_inbyte(r.bc.w);
                r.f.z:=(r.a=0);
                r.f.s:=(r.a and $80)<>0;
                r.f.bit3:=(r.a and 8)<>0;
                r.f.bit5:=(r.a and $20)<>0;
                r.f.p_v:=paridad[r.a];
                r.f.n:=false;
                r.f.h:=false;
                r.wz:=r.bc.w+1;
            end;
        $79:begin {out (C),A >12t<}
                spec_outbyte(r.bc.w,r.a);
                r.wz:=r.bc.w+1;
            end;
        $7a:begin  //adc HL,SP >15t<
              self.contador:=self.contador+7;
              r.hl.w:=adc_hl(r.sp);
            end;
        $7b:begin  {ld SP,(nn) >20t<}
                posicion.l:=spec_getbyte(r.pc);
                posicion.h:=spec_getbyte(r.pc+1);
                r.pc:=r.pc+2;
                r.sp:=spec_getbyte(posicion.w)+(spec_getbyte(posicion.w+1) shl 8);
                r.wz:=posicion.w+1;
            end;
        {7c:neg
        $7d:retn
        $7e:im 2
        $7f..9c:nop*2}
        $a0:begin   {ldi >16t<}
                 temp:=spec_getbyte(r.hl.w);
                 r.bc.w:=r.bc.w-1;
                 spec_putbyte(r.de.w,temp);
                 self.retraso(r.de.w);self.contador:=self.contador+1;
                 self.retraso(r.de.w);self.contador:=self.contador+1;
                 r.de.w:=r.de.w+1;
                 r.hl.w:=r.hl.w+1;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=false;
                 r.f.h:=false;
                 temp:=temp+r.a;
                 r.f.bit5:=(temp and 2)<>0;
                 r.f.bit3:=(temp and 8)<>0;
            end;
        $a1:begin  //cpi el primer programa que lo usa una demo!!!
                 //08 de feb 2003 >16t<
                 temp2:=spec_getbyte(r.hl.w);
                 temp:=r.a-temp2;
                 temp3:=r.a xor temp2 xor temp;
                 r.wz:=r.wz+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 r.hl.w:=r.hl.w+1;
                 r.bc.w:=r.bc.w-1;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=true;
                 r.f.s:=(temp and $80) <>0;
                 r.f.z:=(temp=0);
                 r.f.h:=(temp3 and 16) <> 0;
                 r.f.bit5:=((temp-((temp3 and 16) shr 4)) and 2)<>0;
                 r.f.bit3:=((temp-((temp3 shr 4) and 1)) and 8)<>0;
             end;
        $a2:begin  //ini
                 self.contador:=self.contador+1;
                 temp:=spec_inbyte(r.bc.w);
                 spec_putbyte(r.hl.w,temp);
                 r.wz:=r.bc.w+1;
                 r.bc.h:=r.bc.h-1;
                 r.hl.w:=r.hl.w+1;
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.bc.l+1;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
            end;
        $a3:begin //outi el primer programa que lo usa una demo!!!
                 //08 de feb 2003 >16t<
                 self.contador:=self.contador+1;
                 temp:=spec_getbyte(r.hl.w);
                 r.bc.h:=r.bc.h-1;
                 r.wz:=r.bc.w+1;
                 spec_outbyte(r.bc.w,temp);
                 r.hl.w:=r.hl.w+1;
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.hl.l;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
             end;
        // $a4..$a7:nop*2
        $a8:begin  {ldd >16t<}
                temp:=spec_getbyte(r.hl.w);
                r.bc.w:=r.bc.w-1;
                spec_putbyte(r.de.w,temp);
                self.retraso(r.de.w);self.contador:=self.contador+1;
                self.retraso(r.de.w);self.contador:=self.contador+1;
                r.de.w:=r.de.w-1;
                r.hl.w:=r.hl.w-1;
                r.f.p_v:=(r.bc.w<>0);
                temp:=temp+r.a;
                r.f.bit5:=(temp and 2)<>0;
                r.f.bit3:=(temp and 8)<>0;
                r.f.n:=false;
                r.f.h:=false;
            end;
        $a9:begin //cpd el primer juego que la usa Ace 2
                 //20-09-04 >16t<
                 temp2:=spec_getbyte(r.hl.w);
                 temp:=r.a-temp2;
                 temp3:=r.a xor temp2 xor temp;
                 r.wz:=r.wz-1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 r.hl.w:=r.hl.w-1;
                 r.bc.w:=r.bc.w-1;
                 r.f.s:=(temp and $80) <>0;
                 r.f.z:=(temp=0);
                 r.f.h:=(temp3 and 16) <> 0;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=true;
                 r.f.bit5:=((temp-((temp3 and 16) shr 4)) and 2)<>0;
                 r.f.bit3:=((temp-((temp3 shr 4) and 1)) and 8)<>0;
           end;
        $aa:begin  //ind  >16t<
                 self.contador:=self.contador+1;
                 temp:=spec_inbyte(r.bc.w);
                 spec_putbyte(r.hl.w,temp);
                 r.wz:=r.bc.w-1;
                 r.bc.h:=r.bc.h-1;
                 r.hl.w:=r.hl.w-1;
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.bc.l-1;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
            end;
        $ab:begin   {outd >16t<}
                 self.contador:=self.contador+1;
                 temp:=spec_getbyte(r.hl.w);
                 r.bc.h:=r.bc.h-1;
                 r.wz:=r.bc.w-1;
                 spec_outbyte(r.bc.w,temp);
                 r.hl.w:=r.hl.w-1;
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.hl.l;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
            end;
        {ac..$af:nop*2}
        $b0:begin {ldir >16t o 21t<}
                 temp:=spec_getbyte(r.hl.w);
                 spec_putbyte(r.de.w,temp);
                 self.retraso(r.de.w);self.contador:=self.contador+1;
                 self.retraso(r.de.w);self.contador:=self.contador+1;
                 r.bc.w:=r.bc.w-1;
                 if (r.bc.w<>0) then begin
                        self.retraso(r.de.w);self.contador:=self.contador+1;
                        self.retraso(r.de.w);self.contador:=self.contador+1;
                        self.retraso(r.de.w);self.contador:=self.contador+1;
                        self.retraso(r.de.w);self.contador:=self.contador+1;
                        self.retraso(r.de.w);self.contador:=self.contador+1;
                        r.pc:=r.pc-2;
                        r.wz:=r.pc+1;
                 end;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=false;
                 r.f.h:=false;
                 temp:=temp+r.a;
                 r.f.bit5:=(temp and 2)<>0;
                 r.f.bit3:=(temp and 8)<>0;
                 r.hl.w:=r.hl.w+1;
                 r.de.w:=r.de.w+1;
             end;
        $b1:begin  {cpir >16t o 21t<}
                 temp2:=spec_getbyte(r.hl.w);
                 temp:=r.a-temp2;
                 temp3:=r.a xor temp2 xor temp;
                 r.wz:=r.wz+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 r.bc.w:=r.bc.w-1;
                 r.f.s:=(temp and $80) <>0;
                 r.f.z:=(temp=0);
                 r.f.h:=(temp3 and 16) <> 0;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=true;
                 r.f.bit5:=((temp-((temp3 and 16) shr 4)) and 2)<>0;
                 r.f.bit3:=((temp-((temp3 shr 4) and 1)) and 8)<>0;
                 If (r.f.p_v And not(r.f.z)) then begin
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        r.pc:=r.pc-2;
                        r.wz:=r.pc+1;
                 end;
                 r.hl.w:=r.hl.w+1;
            end;
        $b2:begin		// inir
                 self.contador:=self.contador+1;
                 temp:=spec_inbyte(r.bc.w);
                 spec_putbyte(r.hl.w,temp);
                 r.wz:=r.bc.w+1;
                 r.bc.h:=r.bc.h-1;
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.bc.l+1;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
                 if r.bc.h<>0 then begin
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  r.pc:=r.pc-2;
                end;
                r.hl.w:=r.hl.w+1;
        end;
        $b3:begin //otir añadido el dia 18-09-04 >16t o 21t<
                self.contador:=self.contador+1;
                temp:=spec_getbyte(r.hl.w);
                r.bc.h:=r.bc.h-1;
                r.wz:=r.bc.w+1;
                spec_outbyte(r.bc.w,temp);
                r.f.n:=(temp and $80)<>0;
                tempw:=temp+r.hl.l;
                r.f.h:=(tempw and $100)<>0;
                r.f.c:=(tempw and $100)<>0;
                r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                r.f.z:=(r.bc.h=0);
                r.f.bit5:=(r.bc.h and $20)<>0;
                r.f.bit3:=(r.bc.h and 8)<>0;
                r.f.z:=(r.bc.h and $80)<>0;
                if r.bc.h<>0 then begin
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  self.retraso(r.hl.w);self.contador:=self.contador+1;
                  r.pc:=r.pc-2;
                end;
                r.hl.w:=r.hl.w+1;
            end;
        { $b4..$b7:nop*2}
        $b8:begin {lddr >16t o 21t<}
                 temp:=spec_getbyte(r.hl.w);
                 spec_putbyte(r.de.w,temp);
                 self.retraso(r.de.w);self.contador:=self.contador+1;
                 self.retraso(r.de.w);self.contador:=self.contador+1;
                 r.bc.w:=r.bc.w-1;
                 if (r.bc.w<>0) then begin
                        self.retraso(r.de.w);self.contador:=self.contador+1;
                        self.retraso(r.de.w);self.contador:=self.contador+1;
                        self.retraso(r.de.w);self.contador:=self.contador+1;
                        self.retraso(r.de.w);self.contador:=self.contador+1;
                        self.retraso(r.de.w);self.contador:=self.contador+1;
                        r.pc:=r.pc-2;
                        r.wz:=r.pc+1;
                 end;
                 r.f.p_v:=(r.bc.w<>0);
                 temp:=temp+r.a;
                 r.f.bit5:=(temp and 2)<>0;
                 r.f.bit3:=(temp and 8)<>0;
                 r.f.n:=false;
                 r.f.h:=false;
                 r.hl.w:=r.hl.w-1;
                 r.de.w:=r.de.w-1;
             end;
        $b9:begin   {cpdr >16t o 21t<}
                 temp2:=spec_getbyte(r.hl.w);
                 temp:=r.a-temp2;
                 temp3:=r.a xor temp2 xor temp;
                 r.wz:=r.wz-1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 self.retraso(r.hl.w);self.contador:=self.contador+1;
                 r.bc.w:=r.bc.w-1;
                 r.f.s:=(temp and $80) <>0;
                 r.f.z:=(temp=0);
                 r.f.h:=(temp3 and 16) <> 0;
                 r.f.p_v:=(r.bc.w<>0);
                 r.f.n:=true;
                 r.f.bit5:=((temp-((temp3 and 16) shr 4)) and 2)<>0;
                 r.f.bit3:=((temp-((temp3 shr 4) and 1)) and 8)<>0;
                 if r.f.p_v and not(r.f.z) then begin
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        r.pc:=r.pc-2;
                        r.wz:=r.pc+1;
                 end;
                 r.hl.w:=r.hl.w-1;
             end;
        $ba:begin  //indr  >16t<
                 self.contador:=self.contador+1;
                 temp:=spec_inbyte(r.bc.w);
                 spec_putbyte(r.hl.w,temp);
                 r.wz:=r.bc.w-1;
                 r.bc.h:=r.bc.h-1;
                 r.f.n:=(temp and $80)<>0;
                 tempw:=temp+r.bc.l-1;
                 r.f.h:=(tempw and $100)<>0;
                 r.f.c:=(tempw and $100)<>0;
                 r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                 r.f.z:=(r.bc.h=0);
                 r.f.bit5:=(r.bc.h and $20)<>0;
                 r.f.bit3:=(r.bc.h and 8)<>0;
                 r.f.s:=(r.bc.h and $80)<>0;
                 if (r.bc.h<>0) then begin
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        self.retraso(r.hl.w);self.contador:=self.contador+1;
                        r.pc:=r.pc-2;
                 end;
                 r.hl.w:=r.hl.w-1;
            end;
        $bb:begin //otdr
                self.contador:=self.contador+1;
                temp:=spec_getbyte(r.hl.w);
                r.bc.h:=r.bc.h-1;
                r.wz:=r.bc.w-1;
                spec_outbyte(r.bc.w,temp);
                r.f.n:=(temp and $80)<>0;
                tempw:=temp+r.hl.l;
                r.f.h:=(tempw and $100)<>0;
                r.f.c:=(tempw and $100)<>0;
                r.f.p_v:=paridad[(tempw and $7) xor r.bc.h];
                r.f.z:=(r.bc.h=0);
                r.f.bit5:=(r.bc.h and $20)<>0;
                r.f.bit3:=(r.bc.h and 8)<>0;
                r.f.s:=(r.bc.h and $80)<>0;
                if (r.bc.h<>0) then begin
                    self.retraso(r.hl.w);self.contador:=self.contador+1;
                    self.retraso(r.hl.w);self.contador:=self.contador+1;
                    self.retraso(r.hl.w);self.contador:=self.contador+1;
                    self.retraso(r.hl.w);self.contador:=self.contador+1;
                    self.retraso(r.hl.w);self.contador:=self.contador+1;
                    r.pc:=r.pc-2;
                end;
                r.hl.w:=r.hl.w-1;
            end;
        $fb:main_vars.mensaje_principal:='Instruccion no implmentada EDFB';
end;
end;

end.
