procedure bit_8(r:npreg_z80;bit,valor:byte);inline;
begin
r.f.h:=true;
r.f.n:=false;
r.f.s:=false;
r.f.z:=not((valor and (1 shl bit))<>0);
r.f.p_v:=r.f.z;
r.f.bit5:=(valor and $20)<>0;
r.f.bit3:=(valor and 8)<>0;
end;

procedure bit_7(r:npreg_z80;valor:byte);inline;
begin
r.f.z:=not((valor and $80)<>0);
r.f.h:=true;
r.f.n:=false;
r.f.p_v:=r.f.z;
r.f.s:=(valor and $80)<>0;
r.f.bit5:=(valor and $20)<>0;
r.f.bit3:=(valor and 8)<>0;
end;

procedure add_8(r:npreg_z80;valor:byte);inline;
var
  temp:byte;
begin
 temp:=r.a+valor;
 r.f.p_v:=(((r.a Xor (Not (valor))) And $0ffff) And (r.a Xor temp) And $80) <> 0;
 r.f.h :=(((r.a And 15) + (valor And 15)) And 16) <> 0;
 r.f.s:= (temp and $80) <>0;
 r.f.z:=(temp=0);
 r.f.bit5:=(temp and $20) <>0;
 r.f.bit3:=(temp and 8) <>0;
 r.f.n:=false;
 r.f.c:=((r.a+valor) and $100)<>0;
 r.a:=temp;
end;

procedure adc_8(r:npreg_z80;valor:byte);inline;
var
  carry,temp:byte;
begin
 if r.f.c then carry:=1 else carry:=0;
 temp:=r.a+valor+carry;
 r.f.p_v:=(((r.a Xor (Not valor)) And $0ffff) And ((r.a Xor temp) And 128)) <> 0;
 r.f.h :=(((r.a And 15) + (valor And 15) + carry) And 16) <> 0;
 r.f.s:= (temp and $80) <>0; {modificar signo}
 r.f.z:=(temp=0); {modificar si es zero}
 r.f.bit5:=(temp and 32) <>0;
 r.f.bit3:=(temp and 8) <>0;
 r.f.n:=false; {la bandera de suma}
 r.f.c:=((r.a+valor+carry) and $100)<>0;       {modificar carry}
 r.a:=temp;
end;

procedure sub_8(r:npreg_z80;valor:byte);inline;
var
  temp,temp2:integer;
begin
 temp2:=r.a-valor;
 temp:=temp2 and $FF;
 r.f.h:=(((r.a and $0f) - (valor and $0f)) and $10) <> 0;
 r.f.p_v:=(((r.a xor valor) and (r.a xor temp)) and 128) <>0; {desbordamiento}
 r.f.s:= (temp and $80) <>0; {modificar signo}
 r.f.z:=(temp=0); {modificar si es zero}
 r.f.bit5:=(temp and 32) <>0;
 r.f.bit3:=(temp and 8) <> 0;
 r.f.n:=true; {la bandera de resta}
 r.f.c:=(temp2 and $100)<>0;  {carry}
 r.a:=temp;
end;

procedure sbc_8(r:npreg_z80;valor:byte);inline;
var
  carry,temp:byte;
begin
 if r.f.c then carry:=1 else carry:=0;
 temp:=r.a-valor-carry;
 r.f.h:=(((r.a and $0f) - (valor and $0f) - carry) and $10) <> 0;
 r.f.p_v:=(((r.a xor valor) and (r.a xor temp)) and $80) <>0; {desbordamiento}
 r.f.s:= (temp and $80) <>0; {modificar signo}
 r.f.z:=(temp=0); {modificar si es zero}
 r.f.bit5:=(temp and $20) <>0;
 r.f.bit3:=(temp and 8) <>0;
 r.f.n:=true; {la bandera de resta}
 r.f.c:=((r.a-valor-carry) and $100)<>0;       {modificar carry}
 r.a:=temp;
end;

procedure dec_8(r:npreg_z80;reg:pbyte);inline;
begin
 r.f.h:=(((reg^ and $0F)-1) and $10)<>0; {bit de signo nibble}
 r.f.p_v:=(reg^=$80); {desbordamiento}
 reg^:=reg^-1;
 r.f.s:= (reg^ and $80)<>0; {modificar signo}
 r.f.z:=(reg^=0); {modificar si es zero}
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
 r.f.n:=true; {la bandera de resta}
end;

procedure inc_8(r:npreg_z80;reg:pbyte);inline;
begin
 r.f.h:=(((reg^ and $0F)+1) and $10) <> 0; {bit de signo nibble}
 r.f.p_v:=(reg^=$7f); {desbordamiento}
 reg^:=reg^+1;
 r.f.s:=(reg^ and $80)<>0; {modificar signo}
 r.f.z:=(reg^=0); {modificar si es zero}
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
 r.f.n:=false; {la bandera de suma}
end;

procedure add_16(r:npreg_z80;reg:pparejas;valor:word);inline;
var
  temp:word;
begin
  temp:=reg^.w+valor;
  r.f.bit3:=(temp And $800)<>0;
  r.f.bit5:=(temp And $2000)<>0;
  r.f.c:=((reg^.w+valor) And $10000)<>0;
  r.f.h:=(((reg^.w And $0FFF)+(valor And $0FFF)) And $1000)<>0;
  r.f.n:=False;
  reg^.w:=temp;
end;

procedure adc_16(r:npreg_z80;reg:pparejas;valor:word);inline;
var
  temp:parejas;
  carry:byte;
begin
 if r.f.c then carry:=1 else carry:=0;
 temp.w:=reg.w+valor+carry;
 r.f.p_v := ((reg.w Xor ((Not valor) And $0FFFF)) And (reg.w Xor temp.w) And $8000) <> 0;
 r.f.h := (((reg.w And $0FFF) + (valor And $0FFF) + carry) And $1000) <> 0;
 r.f.s:= (temp.h and 128) <> 0;
 r.f.z:=(temp.w=0);
 r.f.bit5:=(temp.h and 32) <> 0;
 r.f.bit3:=(temp.h and 8) <> 0;
 r.f.n:=false;
 r.f.c:=((reg.w+valor+carry) and $10000)<>0;
 reg^.w:=temp.w;
end;

procedure sbc_16(r:npreg_z80;reg:pparejas;valor:word);inline;
var
  carry:byte;
  temp:word;
begin
if r.f.c Then carry:=1 else carry:=0;
temp:= reg^.w - valor - carry;
r.f.s:=(temp And $8000) <> 0;
r.f.bit3:=(temp And $800) <> 0;
r.f.bit5:=(temp And $2000) <> 0;
r.f.z:=(temp = 0);
r.f.c:=((reg^.w - valor - carry) And $10000) <> 0;
r.f.P_V:=((reg^.w Xor valor) And (reg^.w Xor temp) And $8000) <> 0;
r.f.h:= (((reg^.w And $0FFF) - (valor And $0FFF) - carry) And $1000) <> 0;
r.f.n:=True;
reg^.w:=temp;
end;

procedure and_a(r:npreg_z80;valor:byte);inline;
begin
 r.a:=r.a and valor;
 r.f.s:=(r.a and $80)<>0; {modificar signo}
 r.f.z:=(r.a=0); {modificar si es zero}
 r.f.bit5:=(r.a and $20) <> 0;
 r.f.h:=true; {bit de signo nibble}
 r.f.bit3:=(r.a and 8) <> 0;
 r.f.p_v:=paridad[r.a]; {modificar si paridad}
 r.f.n:=false; {la bandera de suma}
 r.f.c:=false; {modificar carry}
end;

procedure or_a(r:npreg_z80;valor:byte);inline;
begin
 r.a:=r.a or valor;
 r.f.s:=(r.a and $80) <> 0; {modificar signo}
 r.f.z:=(r.a=0); {modificar si es zero}
 r.f.bit5:=(r.a and $20) <> 0;
 r.f.h:=false; {bit de signo nibble}
 r.f.bit3:=(r.a and 8) <> 0;
 r.f.p_v:=paridad[r.a]; {modificar si paridad}
 r.f.n:=false; {la bandera de suma}
 r.f.c:=false; {modificar carry}
end;

procedure xor_a(r:npreg_z80;valor:byte);inline;
begin
 r.a:=r.a xor valor;
 r.f.s:=(r.a and $80)<>0; {modificar signo}
 r.f.z:=(r.a=0); {modificar si es zero}
 r.f.bit5:=(r.a and $20) <> 0;
 r.f.h:= false; {bit de signo nibble}
 r.f.bit3:=(r.a and 8) <> 0 ;
 r.f.p_v:=paridad[r.a]; {modificar si paridad}
 r.f.n:=false; {la bandera de suma}
 r.f.c:=false; {modificar carry}
end;

procedure cp_a(r:npreg_z80;valor:byte);inline;
var
  temp:byte;
begin
 temp:=r.a-valor;
 r.f.s:=(temp and $80) <>0; {modificar signo}
 r.f.z:=(temp=0); {modificar si es zero}
 r.f.bit5:=(valor and $20)<>0;
 r.f.h:=(((r.a and $0F) - (valor and $0F)) and $10) <> 0;
 r.f.bit3:=(valor and 8)<>0;
 r.f.p_v:=((r.a xor valor) and (r.a xor temp) and $80) <>0; {desbordamiento}
 r.f.n:=true; {la bandera de resta}
 r.f.c:=(r.a-valor)<0;  {carry}
end;

procedure sra_8(r:npreg_z80;reg:pbyte);inline;
begin
 r.f.c:=(reg^ and $1)<>0;
 reg^:=(reg^ shr 1) or (reg^ and $80);
 r.f.h:=false;
 r.f.n:=false;
 r.f.p_v:=paridad[reg^];
 r.f.s:=(reg^ and $80)<>0;
 r.f.z:=(reg^=0);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
end;

procedure sla_8(r:npreg_z80;reg:pbyte);inline;
begin
 r.f.c:=(reg^ and $80)<>0;
 reg^:=reg^ shl 1;
 r.f.h:=false;
 r.f.n:=false;
 r.f.p_v:=paridad[reg^];
 r.f.s:=(reg^ and $80)<>0;
 r.f.z:=(reg^=0);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
end;

procedure sll_8(r:npreg_z80;reg:pbyte);inline;
begin
 r.f.c:=(reg^ and $80)<>0;
 reg^:=(reg^ shl 1) or 1;
 r.f.h:=false;
 r.f.n:=false;
 r.f.p_v:=paridad[reg^];
 r.f.s:=(reg^ and $80)<>0;
 r.f.z:=(reg^=0);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
end;

procedure srl_8(r:npreg_z80;reg:pbyte);inline;
begin
 r.f.h:=false;
 r.f.n:=false;
 r.f.c:=(reg^ and 1)<>0;
 reg^:=reg^ shr 1;
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
 r.f.p_v:=paridad[reg^];
 r.f.z:=(reg^=0);
 r.f.s:=(reg^ and $80)<>0;
end;

procedure rlc_8(r:npreg_z80;reg:pbyte);inline;
begin
 r.f.c:=(reg^ and $80)<>0;
 if r.f.c then reg^:=((reg^ shl 1) or 1) else reg^:=reg^ shl 1;
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
 r.f.p_v:=paridad[reg^];
 r.f.h:=false;
 r.f.n:=false;
 r.f.z:=(reg^=0);
 r.f.s:=(reg^ and $80)<>0;
end;

procedure rr_8(r:npreg_z80;reg:pbyte);inline;
begin
 r.f.n:=r.f.c;
 r.f.c:=(reg^ and 1)<>0;
 if r.f.n then reg^:=((reg^ shr 1) or $80) else reg^:=(reg^ shr 1);
 r.f.h:=false;
 r.f.n:=false;
 r.f.p_v:=paridad[reg^];
 r.f.s:=(reg^ and $80)<>0;
 r.f.z:=(reg^=0);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
end;

procedure rrc_8(r:npreg_z80;reg:pbyte);inline;
begin
 r.f.c:=(reg^ and $1)<>0;
 if r.f.c then reg^:=((reg^ shr 1) or $80) else reg^:=(reg^ shr 1);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
 r.f.p_v:=paridad[reg^];
 r.f.h:=false;
 r.f.n:=false;
 r.f.z:=(reg^=0);
 r.f.s:=(reg^ and $80)<>0;
end;

procedure rl_8(r:npreg_z80;reg:pbyte);inline;
begin
 r.f.n:=r.f.c;
 r.f.c:=(reg^ and $80)<>0;
 if r.f.n then reg^:=((reg^ shl 1) or 1) else reg^:=reg^ shl 1;
 r.f.h:=false;
 r.f.n:=false;
 r.f.p_v:=paridad[reg^];
 r.f.s:=(reg^ and $80)<>0;
 r.f.z:=(reg^=0);
 r.f.bit5:=(reg^ and $20)<>0;
 r.f.bit3:=(reg^ and 8)<>0;
end;
