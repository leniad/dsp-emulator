function sshr(num:integer;fac:byte):integer;
begin
  if num<0 then sshr:=-(abs(num) shr fac)
    else sshr:=num shr fac;
end;

function m680x_neg(valor:byte;cc:pband_m6809):byte;
var
  tempw:word;
begin
tempw:=-valor;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
cc.c:=(tempw and $100)<>0;
cc.v:=((0 xor valor xor tempw xor (tempw shr 1)) and $80)<>0;
m680x_neg:=tempw;
end;

function m680x_com(valor:byte;cc:pband_m6809):byte;
var
  temp:byte;
begin
temp:=not(valor);
cc.v:=false;
cc.c:=true;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
m680x_com:=temp;
end;

function m680x_lsr(valor:byte;cc:pband_m6809):byte;
var
  temp:byte;
begin
temp:=valor shr 1;
cc.z:=(temp=0);
cc.n:=false;
cc.c:=(valor and $1)<>0;
m680x_lsr:=temp;
end;

function m680x_ror(valor:byte;cc:pband_m6809):byte;
var
  temp:byte;
begin
temp:=(valor shr 1) or (byte(cc.c) shl 7);
cc.c:=(valor and $1)<>0;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
m680x_ror:=temp;
end;

function m680x_asr(valor:byte;cc:pband_m6809):byte;
var
  temp:byte;
begin
temp:=(valor and $80) or (valor shr 1);
cc.c:=(valor and $1)<>0;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
m680x_asr:=temp;
end;

function m680x_asl(valor:byte;cc:pband_m6809):byte;
var
  tempw:word;
begin
tempw:=valor shl 1;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
cc.c:=(tempw and $100)<>0;
cc.v:=((valor xor valor xor tempw xor (tempw shr 1)) and $80)<>0;
m680x_asl:=tempw;
end;

function m680x_rol(valor:byte;cc:pband_m6809):byte;
var
  tempw:word;
begin
tempw:=(valor shl 1) or byte(cc.c);
cc.c:=(valor and $80)<>0;
cc.v:=((valor xor valor xor tempw xor (tempw shr 1)) and $80)<>0;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
m680x_rol:=tempw;
end;

function m680x_dec(valor:byte;cc:pband_m6809):byte;
var
  tempw:word;
begin
tempw:=valor-1;
cc.z:=((tempw and $ff)=0);
cc.n:=(tempw and $80)<>0;
cc.v:=((valor xor 1 xor tempw xor (tempw shr 1)) and $80)<>0;
m680x_dec:=tempw;
end;

function m680x_inc(valor:byte;cc:pband_m6809):byte;
var
  tempw:word;
begin
tempw:=valor+1;
cc.z:=((tempw and $ff)=0);
cc.n:=(tempw and $80)<>0;
cc.v:=((valor xor 1 xor tempw xor (tempw shr 1)) and $80)<>0;
m680x_inc:=tempw;
end;

procedure m680x_tst(valor:byte;cc:pband_m6809);
begin
cc.v:=((0 xor valor xor valor xor (valor shr 1)) and $80)<>0;
cc.n:=(valor and $80)<>0;
cc.z:=(valor=0);
end;

function m680x_sub8(sub1,sub2:byte;cc:pband_m6809):byte;
var
  tempw:word;
begin
tempw:=sub1-sub2;
cc.c:=(tempw and $100)<>0;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
cc.v:=(((sub1 xor sub2 xor tempw xor (tempw shr 1)) and $80))<>0;
m680x_sub8:=tempw;
end;

function m680x_sub16(sub1,sub2:word;cc:pband_m6809):word;
var
  templ:dword;
begin
templ:=sub1-sub2;
cc.c:=(templ and $10000)<>0;
cc.n:=(templ and $8000)<>0;
cc.z:=(templ and $ffff)=0;
cc.v:=((sub1 xor sub2 xor templ xor (templ shr 1)) and $8000)<>0;
m680x_sub16:=templ;
end;

function m680x_sbc(sub1,sub2:byte;cc:pband_m6809):byte;
var
  tempw:word;
begin
tempw:=sub1-sub2-byte(cc.c);
cc.c:=(tempw and $100)<>0;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
cc.v:=(((sub1 xor sub2 xor tempw xor (tempw shr 1)) and $80))<>0;
m680x_sbc:=tempw;
end;

function m680x_and(valor1,valor2:byte;cc:pband_m6809):byte;
var
  temp:byte;
begin
temp:=valor1 and valor2;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
cc.v:=false;
m680x_and:=temp;
end;

function m680x_eor(valor1,valor2:byte;cc:pband_m6809):byte;
var
  temp:byte;
begin
temp:=valor1 xor valor2;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
cc.v:=false;
m680x_eor:=temp;
end;

function m680x_adc(valor1,valor2:byte;cc:pband_m6809):byte;
var
  tempw:word;
begin
tempw:=valor1+valor2+byte(cc.c);
cc.c:=(tempw and $100)<>0;
cc.h:=((valor1 xor valor2 xor tempw) and $10)<>0;
cc.n:=(tempw and $80)<>0;
cc.z:=(tempw and $ff)=0;
cc.v:=((valor1 xor valor2 xor tempw xor (tempw shr 1)) and $80)<>0;
m680x_adc:=tempw;
end;

function m680x_or(valor1,valor2:byte;cc:pband_m6809):byte;
var
  temp:byte;
begin
temp:=valor1 or valor2;
cc.n:=(temp and $80)<>0;
cc.z:=(temp=0);
cc.v:=false;
m680x_or:=temp;
end;

function m680x_add8(valor1,valor2:byte;cc:pband_m6809):byte;
var
  tempw:word;
begin
tempw:=valor1+valor2;
cc.c:=(tempw and $100)<>0;
cc.h:=((valor1 xor valor2 xor tempw) and $10)<>0;
cc.n:=(tempw and $80)<>0;
cc.z:=((tempw and $ff)=0);
cc.v:=(((valor1 xor valor2 xor tempw xor (tempw shr 1)) and $80))<>0;
m680x_add8:=tempw;
end;

function m680x_add16(add1,add2:word;cc:pband_m6809):word;
var
  templ:dword;
begin
templ:=add1+add2;
cc.c:=(templ and $10000)<>0;
cc.n:=(templ and $8000)<>0;
cc.z:=((templ and $ffff)=0);
cc.v:=((add1 xor add2 xor templ xor (templ shr 1)) and $8000)<>0;
m680x_add16:=templ;
end;

function m680x_ld_st8(valor:byte;cc:pband_m6809):byte;
begin
cc.n:=(valor and $80)<>0;
cc.z:=(valor=0);
cc.v:=((0 xor valor xor valor xor (valor shr 1)) and $80)<>0;
m680x_ld_st8:=valor;
end;

function m680x_ld_st16(valor:word;cc:pband_m6809):word;
begin
cc.n:=(valor and $8000)<>0;
cc.z:=(valor=0);
cc.v:=((0 xor valor xor valor xor (valor shr 1)) and $8000)<>0;
m680x_ld_st16:=valor;
end;

//Exclusivas del HD6309
function hd6309_com16(valor:word;cc:pband_m6809):word;
var
  temp:word;
begin
temp:=not(valor);
cc.v:=false;
cc.c:=true;
cc.n:=(temp and $8000)<>0;
cc.z:=(temp=0);
hd6309_com16:=temp;
end;

function hd6309_add8(valor1,valor2:byte;cc:pband_m6809):byte;
var
  tempw:word;
begin
tempw:=valor1+valor2;
cc.c:=(tempw and $100)<>0;
cc.n:=(tempw and $80)<>0;
cc.z:=((tempw and $ff)=0);
cc.v:=(((valor1 xor valor2 xor tempw xor (tempw shr 1)) and $80))<>0;
hd6309_add8:=tempw;
end;

//KONAMI
function m680x_neg16(valor:word;cc:pband_m6809):word;
var
  templ:dword;
begin
templ:=-valor;
cc.n:=(templ and $8000)<>0;
cc.z:=(templ and $ffff)=0;
cc.c:=(templ and $10000)<>0;
cc.v:=((0 xor valor xor templ xor (templ shr 1)) and $8000)<>0;
m680x_neg16:=templ;
end;

function m680x_inc16(valor:word;cc:pband_m6809):word;
var
  templ:dword;
begin
templ:=valor+1;
cc.c:=(templ and $10000)<>0;
cc.z:=((templ and $ffff)=0);
cc.n:=(templ and $8000)<>0;
cc.v:=((valor xor 1 xor templ xor (templ shr 1)) and $8000)<>0;
m680x_inc16:=templ;
end;

function m680x_dec16(valor:word;cc:pband_m6809):word;
var
  templ:dword;
begin
templ:=valor-1;
cc.c:=(templ and $10000)<>0;
cc.z:=((templ and $ffff)=0);
cc.n:=(templ and $8000)<>0;
cc.v:=((valor xor 1 xor templ xor (templ shr 1)) and $8000)<>0;
m680x_dec16:=templ;
end;

procedure m680x_tst16(valor:word;cc:pband_m6809);
begin
cc.v:=((0 xor valor xor valor xor (valor shr 1)) and $8000)<>0;
cc.n:=(valor and $8000)<>0;
cc.z:=(valor=0);
end;

function m680x_lsrd(valor:word;numero:byte;cc:pband_m6809):word;
var
   tempw:word;
begin
tempw:=valor;
if (numero<>0) then begin
   cc.c:=(valor and (1 shl (numero-1)))<>0;
   if numero<16 then tempw:=valor shr numero
      else tempw:=0;
   cc.n:=(tempw and $8000)<>0;
   cc.z:=(tempw=0);
end;
m680x_lsrd:=tempw;
end;

function m680x_asld(valor:word;numero:byte;cc:pband_m6809):word;
var
   tempw:word;
begin
tempw:=valor;
if (numero<>0) then begin  //asld
   cc.c:=(valor and ($10000 shr numero))<>0;
   if numero<16 then tempw:=valor shl numero
      else tempw:=0;
   cc.n:=(valor and $8000)<>0;
   cc.z:=(valor=0);
   cc.v:=((0 xor tempw xor tempw xor (tempw shr 1)) and $8000)<>0;
end;
m680x_asld:=tempw;
end;

function m680x_lsr16(valor:word;cc:pband_m6809):word;
var
   tempw:word;
begin
tempw:=valor shr 1;
cc.n:=false;
cc.z:=(tempw=0);
cc.c:=(valor and 1)<>0;
m680x_lsr16:=tempw;
end;

function m680x_asl16(valor:word;cc:pband_m6809):word;
var
  templ:dword;
begin
templ:=valor shl 1;
cc.n:=(templ and $8000)<>0;
cc.z:=(templ and $ffff)=0;
cc.c:=(templ and $10000)<>0;
cc.v:=((valor xor valor xor templ xor (templ shr 1)) and $8000)<>0;
m680x_asl16:=templ;
end;

function m680x_asr16(valor:word;cc:pband_m6809):word;
var
  tempw:word;
begin
tempw:=(valor shr 1) or (valor and $8000);
cc.n:=(tempw and $8000)<>0;
cc.z:=(tempw=0);
cc.c:=(valor and $1)<>0;
m680x_asr16:=tempw;
end;

function m680x_abs16(valor:word;cc:pband_m6809):word;
var
  tempw:word;
begin
tempw:=abs(smallint(valor));
cc.c:=false;
cc.v:=((0 xor valor xor tempw xor (tempw shr 1)) and $8000)<>0;
cc.n:=(tempw and $8000)<>0;
cc.z:=(tempw=0);
m680x_abs16:=tempw;
end;

function m680x_abs8(valor:byte;cc:pband_m6809):byte;
var
  tempb:byte;
begin
tempb:=abs(shortint(valor));
cc.c:=false;
cc.v:=((0 xor valor xor tempb xor (tempb shr 1)) and $80)<>0;
cc.n:=(tempb and $80)<>0;
cc.z:=(tempb=0);
m680x_abs8:=tempb;
end;

function m680x_asrd(valor:word;numero:byte;cc:pband_m6809):word;
var
   tempw:word;
begin
tempw:=valor;
if (numero<>0) then begin
   cc.c:=(valor and (1 shl (numero-1)))<>0;
   if numero<16 then tempw:=sshr(smallint(valor),numero)
      else if (smallint(valor)<0) then tempw:=$ffff
           else tempw:=0;
   cc.n:=(tempw and $8000)<>0;
   cc.z:=(tempw=0);
end;
m680x_asrd:=tempw;
end;

